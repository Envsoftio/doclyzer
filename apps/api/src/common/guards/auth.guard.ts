import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import type { Request } from 'express';
import { Repository } from 'typeorm';
import { RestrictionEntity } from '../../database/entities/restriction.entity';
import {
  ACCOUNT_SUSPENDED,
  ACCOUNT_SUSPENDED_RESTRICTED_ACTIONS,
  RESTRICTED_REVIEW_ERROR_CODES,
  RESTRICTED_REVIEW_MESSAGES,
  type RestrictedReviewAction,
} from '../restriction/restriction.constants';
import { BetterAuthService } from '../../modules/auth/better-auth.service';

interface BetterAuthErrorBody {
  code?: string;
}

interface BetterAuthError extends Error {
  body?: BetterAuthErrorBody;
}

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(
    private readonly betterAuthService: BetterAuthService,
    @InjectRepository(RestrictionEntity)
    private readonly restrictionRepo: Repository<RestrictionEntity>,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest<Request>();
    const handler =
      typeof context.getHandler === 'function' ? context.getHandler() : null;
    const handlerName = handler?.name;
    const controller =
      typeof context.getClass === 'function' ? context.getClass() : null;
    const handlerKey = `${controller?.name ?? 'UnknownController'}.${
      handlerName ?? 'unknown'
    }`;
    const revokedCodeAllowed = handlerName === 'logout';

    const auth = await this.betterAuthService.getAuth();
    const headers = this.betterAuthService.buildHeadersFromRequest(req);

    try {
      const result = await auth.api.getSession({ headers });
      if (!result || !result.session || !result.user) {
        throw new UnauthorizedException({
          code: revokedCodeAllowed
            ? 'AUTH_SESSION_REVOKED'
            : 'AUTH_UNAUTHORIZED',
          message: revokedCodeAllowed
            ? 'Session has been revoked'
            : 'Authentication required',
        });
      }

      (req as Request & { user: { id: string } }).user = { id: result.user.id };
      (req as Request & { currentSessionId?: string }).currentSessionId =
        result.session.id;
      await this.enforceAccountSuspension(
        req,
        result.user.id,
        handlerName,
        handlerKey,
        revokedCodeAllowed,
      );
      return true;
    } catch (err: unknown) {
      const code = this.getBetterAuthErrorCode(err);
      if (code && revokedCodeAllowed) {
        if (code === 'SESSION_EXPIRED' || code === 'INVALID_TOKEN') {
          throw new UnauthorizedException({
            code: 'AUTH_SESSION_REVOKED',
            message: 'Session has been revoked',
          });
        }
      }
      if (err instanceof UnauthorizedException) throw err;
      throw new UnauthorizedException({
        code: 'AUTH_UNAUTHORIZED',
        message: 'Authentication required',
      });
    }
  }

  private getBetterAuthErrorCode(error: unknown): string | null {
    if (!error || typeof error !== 'object') return null;
    const err = error as BetterAuthError;
    if (!err.body || typeof err.body !== 'object') return null;
    return err.body.code ?? null;
  }

  private async enforceAccountSuspension(
    req: Request,
    userId: string,
    handlerName: string | undefined,
    handlerKey: string,
    revokedCodeAllowed: boolean,
  ): Promise<void> {
    if (revokedCodeAllowed || handlerName === 'getRestrictionStatus') {
      return;
    }
    const restriction = await this.restrictionRepo.findOne({
      where: { userId },
    });
    if (!restriction) {
      return;
    }
    if (this.isRestrictionExpired(restriction)) {
      await this.clearExpiredRestriction(restriction);
      return;
    }
    if (!restriction.isRestricted && !restriction.restrictedReviewMode) {
      return;
    }

    if (restriction.isRestricted) {
      throw new ForbiddenException({
        code: ACCOUNT_SUSPENDED,
        message: 'Account is suspended pending superadmin review',
        rationale: restriction.rationale ?? null,
        nextSteps: restriction.nextSteps ?? null,
        restrictedActions: ACCOUNT_SUSPENDED_RESTRICTED_ACTIONS,
        correlationId: (req as Request & { correlationId?: string })
          .correlationId,
      });
    }

    if (restriction.restrictedReviewMode) {
      const action = this.getRestrictedReviewAction(handlerKey);
      if (!action) return;
      throw new ForbiddenException({
        code: RESTRICTED_REVIEW_ERROR_CODES[action],
        message: RESTRICTED_REVIEW_MESSAGES[action],
        restrictedAction: action,
        rationale: restriction.rationale ?? null,
        nextSteps: restriction.nextSteps ?? null,
        correlationId: (req as Request & { correlationId?: string })
          .correlationId,
      });
    }
  }

  private getRestrictedReviewAction(
    handlerKey: string,
  ): RestrictedReviewAction | null {
    return (
      (
        {
          'ReportsController.uploadReport': 'upload_report',
          'ReportsController.listReports': 'view_timeline',
          'ReportsController.getLabTrends': 'view_timeline',
          'ReportsController.getReport': 'view_timeline',
          'ReportsController.getProcessingAttempts': 'view_timeline',
          'ReportsController.getReportFile': 'view_timeline',
          'ProfilesController.createProfile': 'manage_profiles',
          'ProfilesController.updateProfile': 'manage_profiles',
          'ProfilesController.activateProfile': 'manage_profiles',
          'ProfilesController.deleteProfile': 'manage_profiles',
          'SharingController.createShareLink': 'manage_sharing',
          'SharingController.listShareLinks': 'manage_sharing',
          'SharingController.revokeShareLink': 'manage_sharing',
          'SharingController.updateExpiry': 'manage_sharing',
          'SharingController.listAccessEvents': 'manage_sharing',
          'SharingController.getSharePolicy': 'manage_sharing',
          'SharingController.upsertSharePolicy': 'manage_sharing',
          'AccountController.updateProfile': 'update_account_profile',
          'AccountController.uploadAvatar': 'update_account_profile',
        } as Record<string, RestrictedReviewAction>
      )[handlerKey] ?? null
    );
  }

  private isRestrictionExpired(restriction: RestrictionEntity): boolean {
    if (!restriction.restrictedUntil) return false;
    return restriction.restrictedUntil.getTime() <= Date.now();
  }

  private async clearExpiredRestriction(
    restriction: RestrictionEntity,
  ): Promise<void> {
    if (!restriction.isRestricted && !restriction.restrictedReviewMode) {
      return;
    }
    restriction.isRestricted = false;
    restriction.restrictedReviewMode = false;
    restriction.restrictedUntil = null;
    restriction.rationale = null;
    restriction.nextSteps = null;
    await this.restrictionRepo.save(restriction);
  }
}
