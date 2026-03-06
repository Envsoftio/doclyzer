import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import type { Request } from 'express';
import { AuthService } from '../../modules/auth/auth.service';
import type { RequestUser } from '../../modules/auth/auth.types';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private readonly authService: AuthService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest<Request>();
    const authHeader = req.header('authorization');

    if (!authHeader) {
      throw new UnauthorizedException({
        code: 'AUTH_UNAUTHORIZED',
        message: 'Authentication required',
      });
    }

    const [scheme, token] = authHeader.split(' ');
    if (scheme !== 'Bearer' || !token) {
      throw new UnauthorizedException({
        code: 'AUTH_UNAUTHORIZED',
        message: 'Authentication required',
      });
    }

    const user = await this.authService.validateAccessToken(token);
    (req as Request & { user: RequestUser }).user = { id: user.id };
    (req as Request & { currentSessionId?: string | null }).currentSessionId =
      this.authService.getSessionIdForAccessToken(token) ?? null;
    return true;
  }
}
