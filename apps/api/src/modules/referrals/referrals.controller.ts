import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Put,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';
import { AuthGuard } from '../../common/guards/auth.guard';
import { SuperadminGuard } from '../auth/superadmin.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import type { RequestUser } from '../auth/auth.types';
import { ApplyReferralCodeDto, UpdateReferralPolicyDto } from './referrals.dto';
import { ReferralsService } from './referrals.service';

@Controller('referrals')
@UseGuards(AuthGuard)
export class ReferralsController {
  constructor(private readonly referralsService: ReferralsService) {}

  @Get('me')
  async getReferralDashboard(@Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.referralsService.getReferralDashboard(userId);
    return successResponse(data, getCorrelationId(req));
  }

  @Post('apply')
  @HttpCode(HttpStatus.OK)
  async applyReferralCode(
    @Body() body: ApplyReferralCodeDto,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.referralsService.applyReferralCode({
      inviteeUserId: userId,
      referralCode: body.referralCode,
      correlationId: getCorrelationId(req),
    });
    return successResponse(data, getCorrelationId(req));
  }
}

@Controller('admin/referrals')
@UseGuards(AuthGuard, SuperadminGuard)
export class ReferralsAdminController {
  constructor(private readonly referralsService: ReferralsService) {}

  @Get('policy')
  async getPolicy(@Req() req: Request): Promise<object> {
    return successResponse(
      await this.referralsService.getAdminReferralPolicy(),
      getCorrelationId(req),
    );
  }

  @Put('policy')
  async updatePolicy(
    @Req() req: Request,
    @Body() dto: UpdateReferralPolicyDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    return successResponse(
      await this.referralsService.updateReferralPolicy(actorUserId, dto),
      getCorrelationId(req),
    );
  }
}
