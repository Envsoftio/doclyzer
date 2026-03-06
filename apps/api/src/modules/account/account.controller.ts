import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Patch,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';
import type { RequestUser } from '../../modules/auth/auth.types';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import { UpdateAccountProfileDto } from './account.dto';
import { AccountService } from './account.service';

@Controller('account')
@UseGuards(AuthGuard)
export class AccountController {
  constructor(private readonly accountService: AccountService) {}

  @Get('profile')
  getProfile(@Req() req: Request): object {
    const { id: userId } = req.user as RequestUser;
    const data = this.accountService.getProfile(userId);
    return successResponse(data, getCorrelationId(req));
  }

  @Patch('profile')
  @HttpCode(HttpStatus.OK)
  updateProfile(
    @Body() body: UpdateAccountProfileDto,
    @Req() req: Request,
  ): object {
    const { id: userId } = req.user as RequestUser;
    const data = this.accountService.updateProfile(userId, body);
    return successResponse(data, getCorrelationId(req));
  }
}
