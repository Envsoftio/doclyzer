import { Controller, Get, Query, Req, UseGuards } from '@nestjs/common';
import type { Request } from 'express';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import type { RequestUser } from '../auth/auth.types';
import { SuperadminGuard } from '../auth/superadmin.guard';
import { EmailAdminService } from './email-admin.service';
import {
  EmailDeliveryAnalyticsQueryDto,
  EmailSendingHistoryQueryDto,
} from './email-admin.dto';

@Controller('admin/email')
@UseGuards(AuthGuard, SuperadminGuard)
export class EmailAdminController {
  constructor(private readonly emailAdminService: EmailAdminService) {}

  @Get('queue-status')
  async getQueueStatus(@Req() req: Request): Promise<object> {
    const correlationId = getCorrelationId(req);
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.emailAdminService.getQueueStatus({
      actorUserId,
      correlationId,
    });
    return successResponse(data, correlationId);
  }

  @Get('delivery-analytics')
  async getDeliveryAnalytics(
    @Req() req: Request,
    @Query() query: EmailDeliveryAnalyticsQueryDto,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.emailAdminService.getDeliveryAnalytics({
      actorUserId,
      correlationId,
      query,
    });
    return successResponse(data, correlationId);
  }

  @Get('sending-history')
  async getSendingHistory(
    @Req() req: Request,
    @Query() query: EmailSendingHistoryQueryDto,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.emailAdminService.getSendingHistory({
      actorUserId,
      correlationId,
      query,
    });
    return successResponse(data, correlationId);
  }
}
