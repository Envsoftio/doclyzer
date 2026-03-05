import { Injectable, NotFoundException } from '@nestjs/common';
import { AuthService } from '../auth/auth.service';
import type { UpdateAccountProfileDto } from './account.dto';
import type { AccountProfile } from './account.types';

@Injectable()
export class AccountService {
  constructor(private readonly authService: AuthService) {}

  getProfile(userId: string): AccountProfile {
    const user = this.authService.findUserById(userId);
    if (!user) {
      throw new NotFoundException({
        code: 'ACCOUNT_NOT_FOUND',
        message: 'Account not found',
      });
    }
    return {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      createdAt: user.createdAt,
    };
  }

  updateProfile(userId: string, dto: UpdateAccountProfileDto): AccountProfile {
    const user = this.authService.findUserById(userId);
    if (!user) {
      throw new NotFoundException({
        code: 'ACCOUNT_NOT_FOUND',
        message: 'Account not found',
      });
    }
    if (dto.displayName !== undefined) {
      this.authService.updateUser(userId, { displayName: dto.displayName });
    }
    return {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      createdAt: user.createdAt,
    };
  }
}
