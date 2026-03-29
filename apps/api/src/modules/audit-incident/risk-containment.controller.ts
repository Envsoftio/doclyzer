import { Body, Controller, Param, Patch, Req, UseGuards } from '@nestjs/common';
import type { Request } from 'express';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import type { RequestUser } from '../auth/auth.types';
import { AdminActionTokenGuard } from '../auth/admin-action-token.guard';
import { SuperadminGuard } from '../auth/superadmin.guard';
import {
  SetAccountSuspensionDto,
  SetAccountRestrictionDto,
  SetShareLinkSuspensionDto,
} from './risk-containment.dto';
import { RiskContainmentService } from './risk-containment.service';

@Controller('admin/risk-controls')
@UseGuards(AuthGuard, SuperadminGuard, AdminActionTokenGuard)
export class RiskContainmentController {
  constructor(
    private readonly riskContainmentService: RiskContainmentService,
  ) {}

  @Patch('share-links/:shareLinkId/suspension')
  async setShareLinkSuspension(
    @Req() req: Request,
    @Param('shareLinkId') shareLinkId: string,
    @Body() dto: SetShareLinkSuspensionDto,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.riskContainmentService.setShareLinkSuspension({
      actorUserId,
      correlationId,
      shareLinkId,
      dto,
    });
    return successResponse(data, correlationId);
  }

  @Patch('accounts/:userId/suspension')
  async setAccountSuspension(
    @Req() req: Request,
    @Param('userId') userId: string,
    @Body() dto: SetAccountSuspensionDto,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.riskContainmentService.setAccountSuspension({
      actorUserId,
      correlationId,
      targetUserId: userId,
      dto,
    });
    return successResponse(data, correlationId);
  }

  @Patch('accounts/:userId/restriction')
  async setAccountRestriction(
    @Req() req: Request,
    @Param('userId') userId: string,
    @Body() dto: SetAccountRestrictionDto,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.riskContainmentService.setAccountRestriction({
      actorUserId,
      correlationId,
      targetUserId: userId,
      dto,
    });
    return successResponse(data, correlationId);
  }
}
