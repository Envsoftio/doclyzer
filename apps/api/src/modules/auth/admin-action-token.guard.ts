import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import type { Request } from 'express';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { SuperadminAuthService } from './superadmin-auth.service';
import type { RequestUser } from './auth.types';

const ADMIN_ACTION_TOKEN_HEADER = 'x-admin-action-token';

@Injectable()
export class AdminActionTokenGuard implements CanActivate {
  constructor(private readonly superadminAuthService: SuperadminAuthService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context
      .switchToHttp()
      .getRequest<
        Request & { user?: RequestUser; currentSessionId?: string }
      >();
    const userId = req.user?.id;
    const sessionId = req.currentSessionId;
    const adminActionToken = req.header(ADMIN_ACTION_TOKEN_HEADER);

    if (!userId || !sessionId || !adminActionToken) {
      throw new UnauthorizedException({
        code: 'AUTH_MFA_CHALLENGE_REQUIRED',
        message: 'Admin action token is required for this operation',
      });
    }

    const riskFingerprint = this.superadminAuthService.buildRiskFingerprint({
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'],
    });

    await this.superadminAuthService.validateAdminActionToken({
      userId,
      sessionId,
      adminActionToken,
      correlationId: getCorrelationId(req),
      riskFingerprint,
    });

    return true;
  }
}
