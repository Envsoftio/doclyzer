import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import type { Request } from 'express';

interface JwtPayload {
  sub: string;
  sessionId: string;
}

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private readonly jwtService: JwtService) {}

  canActivate(context: ExecutionContext): boolean {
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

    try {
      const payload = this.jwtService.verify<JwtPayload>(token);
      (req as Request & { user: { id: string } }).user = { id: payload.sub };
      (req as Request & { currentSessionId?: string }).currentSessionId =
        payload.sessionId;
      return true;
    } catch {
      throw new UnauthorizedException({
        code: 'AUTH_UNAUTHORIZED',
        message: 'Authentication required',
      });
    }
  }
}
