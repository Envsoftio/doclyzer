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
    revokedCodeAllowed: boolean,
  ): Promise<void> {
    if (revokedCodeAllowed || handlerName === 'getRestrictionStatus') {
      return;
    }
    const restriction = await this.restrictionRepo.findOne({
      where: { userId, isRestricted: true },
    });
    if (!restriction) {
      return;
    }

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
}
