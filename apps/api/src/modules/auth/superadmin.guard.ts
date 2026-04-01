import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import type { Request } from 'express';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserEntity } from '../../database/entities/user.entity';
import { AUTHZ_SUPERADMIN_REQUIRED } from './auth.types';
import type { RequestUser } from './auth.types';

@Injectable()
export class SuperadminGuard implements CanActivate {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest<Request>();
    const requestUser = (req as Request & { user?: RequestUser }).user;
    if (!requestUser?.id) {
      throw new UnauthorizedException({
        code: 'AUTH_UNAUTHORIZED',
        message: 'Authentication required',
      });
    }

    const user = await this.userRepo.findOne({ where: { id: requestUser.id } });
    if (!user || user.role !== 'superadmin') {
      throw new ForbiddenException({
        code: AUTHZ_SUPERADMIN_REQUIRED,
        message: 'Superadmin role is required for this operation',
      });
    }

    return true;
  }
}
