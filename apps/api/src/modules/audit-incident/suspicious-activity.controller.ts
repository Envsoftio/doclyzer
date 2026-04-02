import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
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
  SuspiciousActivityIngestDto,
  SuspiciousActivityQueueQueryDto,
  SuspiciousActivityStatusUpdateDto,
} from './suspicious-activity.dto';
import { SuspiciousActivityService } from './suspicious-activity.service';

@Controller('admin/risk')
@UseGuards(AuthGuard, SuperadminGuard)
export class SuspiciousActivityController {
  constructor(
    private readonly suspiciousActivityService: SuspiciousActivityService,
  ) {}

  @Post('suspicious-activity')
  async ingestSuspiciousActivity(
    @Req() req: Request,
    @Body() dto: SuspiciousActivityIngestDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const correlationId = getCorrelationId(req);
    const data = await this.suspiciousActivityService.ingestSignal({
      actorUserId,
      correlationId,
      dto,
    });
    return successResponse(data, correlationId);
  }

  @Get('suspicious-activity')
  async listSuspiciousActivityQueue(
    @Req() req: Request,
    @Query() query: SuspiciousActivityQueueQueryDto,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const data = await this.suspiciousActivityService.listQueue(query);
    return successResponse(data, correlationId);
  }

  @Get('suspicious-activity-queue')
  async listSuspiciousActivityQueueAlias(
    @Req() req: Request,
    @Query() query: SuspiciousActivityQueueQueryDto,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const data = await this.suspiciousActivityService.listQueue(query);
    return successResponse(data, correlationId);
  }

  @Patch('suspicious-activity/:queueItemId/status')
  async updateSuspiciousActivityStatus(
    @Req() req: Request,
    @Param('queueItemId') queueItemId: string,
    @Body() dto: SuspiciousActivityStatusUpdateDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const correlationId = getCorrelationId(req);
    const data = await this.suspiciousActivityService.updateStatus({
      actorUserId,
      correlationId,
      queueItemId,
      dto,
    });
    return successResponse(data, correlationId);
  }
}
