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

@Injectable()
export class SuperadminGuard implements CanActivate {
  constructor(private readonly superadminAuthService: SuperadminAuthService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest<Request>();
    const requestUser = (req as Request & { user?: RequestUser }).user;
    if (!requestUser?.id) {
      throw new UnauthorizedException({
        code: 'AUTH_UNAUTHORIZED',
        message: 'Authentication required',
      });
    }

    await this.superadminAuthService.assertSuperadmin(
      requestUser.id,
      getCorrelationId(req),
    );
    return true;
  }
}
