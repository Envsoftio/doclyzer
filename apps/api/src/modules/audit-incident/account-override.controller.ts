import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import type { RequestUser } from '../auth/auth.types';

import { SuperadminGuard } from '../auth/superadmin.guard';
import {
  CreateAccountOverrideDto,
  RevokeAccountOverrideDto,
} from './account-override.dto';
import { AccountOverrideService } from './account-override.service';

@Controller('admin/risk-controls/accounts/:userId/overrides')
@UseGuards(AuthGuard, SuperadminGuard)
export class AccountOverrideController {
  constructor(
    private readonly accountOverrideService: AccountOverrideService,
  ) {}

  /**
   * POST /admin/risk-controls/accounts/:userId/overrides
   * Create a time-bound override granting temporary access to restricted actions.
   * Outcomes: success (created), failure (validation error)
   */
  @Post()
  async createOverride(
    @Req() req: Request,
    @Param('userId') userId: string,
    @Body() dto: CreateAccountOverrideDto,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.accountOverrideService.createOverride({
      actorUserId,
      correlationId,
      targetUserId: userId,
      dto,
    });
    return successResponse(data, correlationId);
  }

  /**
   * GET /admin/risk-controls/accounts/:userId/overrides
   * List all overrides for an account (active + history), ordered newest first.
   * Outcomes: success (list returned)
   */
  @Get()
  async listOverrides(
    @Req() req: Request,
    @Param('userId') userId: string,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const data = await this.accountOverrideService.listOverrides(userId);
    return successResponse(data, correlationId);
  }

  /**
   * PATCH /admin/risk-controls/accounts/:userId/overrides/revoke
   * Manually revoke an active override before its scheduled expiry.
   * Outcomes: reverted (deactivated), reverted (already inactive — idempotent)
   */
  @Patch('revoke')
  async revokeOverride(
    @Req() req: Request,
    @Param('userId') userId: string,
    @Body() dto: RevokeAccountOverrideDto,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.accountOverrideService.revokeOverride({
      actorUserId,
      correlationId,
      targetUserId: userId,
      dto,
    });
    return successResponse(data, correlationId);
  }
}
