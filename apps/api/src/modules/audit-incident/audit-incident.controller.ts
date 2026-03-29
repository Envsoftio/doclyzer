import {
  Body,
  Controller,
  Get,
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
import { AdminActionTokenGuard } from '../auth/admin-action-token.guard';
import { SuperadminGuard } from '../auth/superadmin.guard';
import { AuditIncidentService } from './audit-incident.service';
import {
  AuditActionCreateDto,
  AuditActionQueryDto,
} from './audit-incident.dto';

@Controller('admin/audit')
@UseGuards(AuthGuard, SuperadminGuard, AdminActionTokenGuard)
export class AuditIncidentController {
  constructor(private readonly auditService: AuditIncidentService) {}

  @Post('actions')
  async recordAction(
    @Req() req: Request,
    @Body() dto: AuditActionCreateDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const correlationId = getCorrelationId(req);
    const data = await this.auditService.recordAuditAction({
      actorUserId,
      correlationId,
      dto,
    });
    return successResponse(data, correlationId);
  }

  @Get('actions')
  async listActions(
    @Req() req: Request,
    @Query() query: AuditActionQueryDto,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const data = await this.auditService.searchAuditActions(query);
    return successResponse(data, correlationId);
  }
}
