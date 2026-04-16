import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Query,
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
  EmergencyAccountSuspendDto,
  EmergencyShareLinkSuspendDto,
  EmergencyActionTimelineQueryDto,
} from './emergency-containment.dto';
import { EmergencyContainmentService } from './emergency-containment.service';

/**
 * Emergency containment endpoints.
 *
 * All actions require:
 *  1. Valid session (AuthGuard)
 *  2. Superadmin role (SuperadminGuard)
 *  3. Mandatory auditNote in request body (enforced in DTOs + service layer)
 *
 * Emergency events are persisted as immutable, tamper-evident audit records
 * using the existing SuperadminActionAuditEventEntity chain, prefixed EMERGENCY_*
 * so they are independently queryable via the timeline endpoint.
 */
@Controller('admin/emergency')
@UseGuards(AuthGuard, SuperadminGuard)
export class EmergencyContainmentController {
  constructor(private readonly emergencyService: EmergencyContainmentService) {}

  /**
   * Emergency suspend or unsuspend an account.
   * POST body must include a mandatory auditNote (≥10 chars).
   */
  @Patch('accounts/:userId/suspension')
  async emergencyAccountSuspension(
    @Req() req: Request,
    @Param('userId') userId: string,
    @Body() dto: EmergencyAccountSuspendDto,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.emergencyService.emergencySuspendAccount({
      actorUserId,
      correlationId,
      targetUserId: userId,
      dto,
    });
    return successResponse(data, correlationId);
  }

  /**
   * Emergency suspend or unsuspend a share link.
   * Mandatory auditNote required; elevated privilege enforced via token guard.
   */
  @Patch('share-links/:shareLinkId/suspension')
  async emergencyShareLinkSuspension(
    @Req() req: Request,
    @Param('shareLinkId') shareLinkId: string,
    @Body() dto: EmergencyShareLinkSuspendDto,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.emergencyService.emergencySuspendShareLink({
      actorUserId,
      correlationId,
      shareLinkId,
      dto,
    });
    return successResponse(data, correlationId);
  }

  /**
   * Query the immutable emergency action timeline.
   * Results are sorted by performedAt DESC and include tamper-evidence hashes.
   * Optionally filter by target account/share-link and time window.
   */
  @Get('timeline')
  async emergencyTimeline(
    @Req() req: Request,
    @Query() query: EmergencyActionTimelineQueryDto,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const data = await this.emergencyService.queryEmergencyTimeline(query);
    return successResponse(data, correlationId);
  }
}
