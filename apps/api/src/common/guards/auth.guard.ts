import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import type { Request } from 'express';
import { Repository } from 'typeorm';
import { SessionEntity } from '../../database/entities/session.entity';

interface JwtPayload {
  sub: string;
  sessionId: string;
}

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(
    private readonly jwtService: JwtService,
    @InjectRepository(SessionEntity)
    private readonly sessionRepo: Repository<SessionEntity>,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest<Request>();
    const authHeader = req.header('authorization');
    const handler =
      typeof context.getHandler === 'function' ? context.getHandler() : null;
    const handlerName = handler?.name;
    const revokedCodeAllowed = handlerName === 'logout';

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

      const now = new Date();
      const session = await this.sessionRepo.findOne({
        where: { id: payload.sessionId },
        select: ['userId', 'expiresAt'],
      });
      const expiresAt = session?.expiresAt ?? null;
      if (
        !session ||
        session.userId !== payload.sub ||
        !expiresAt ||
        expiresAt <= now
      ) {
        throw new UnauthorizedException({
          code: revokedCodeAllowed
            ? 'AUTH_SESSION_REVOKED'
            : 'AUTH_UNAUTHORIZED',
          message: revokedCodeAllowed
            ? 'Session has been revoked'
            : 'Authentication required',
        });
      }

      (req as Request & { user: { id: string } }).user = { id: payload.sub };
      (req as Request & { currentSessionId?: string }).currentSessionId =
        payload.sessionId;
      return true;
    } catch (err: unknown) {
      if (err instanceof UnauthorizedException) throw err;
      throw new UnauthorizedException({
        code: 'AUTH_UNAUTHORIZED',
        message: 'Authentication required',
      });
    }
  }
}
