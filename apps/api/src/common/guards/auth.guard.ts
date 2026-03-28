import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import type { Request } from 'express';
import { BetterAuthService } from '../../modules/auth/better-auth.service';

interface BetterAuthErrorBody {
  code?: string;
}

interface BetterAuthError extends Error {
  body?: BetterAuthErrorBody;
}

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private readonly betterAuthService: BetterAuthService) {}

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
}
