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
import { AnalyticsAdminService } from './analytics-admin.service';
import { AnalyticsGovernanceService } from './analytics-governance.service';
import {
  AnalyticsGovernanceValidationDto,
  GovernanceRecordsExportDto,
  GovernanceRecordsQueryDto,
} from './analytics-governance.dto';
import { CoreProductAnalyticsQueryDto } from './analytics-admin.dto';

@Controller('admin/analytics')
@UseGuards(AuthGuard, SuperadminGuard, AdminActionTokenGuard)
export class AnalyticsAdminController {
  constructor(
    private readonly analyticsAdminService: AnalyticsAdminService,
    private readonly analyticsGovernanceService: AnalyticsGovernanceService,
  ) {}

  @Get('core-product')
  async getCoreProductMetrics(
    @Req() req: Request,
    @Query() query: CoreProductAnalyticsQueryDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const correlationId = getCorrelationId(req);
    const data = await this.analyticsAdminService.getCoreProductAnalytics({
      actorUserId,
      correlationId,
      query,
    });
    return successResponse(data, correlationId);
  }

  @Post('governance/validate')
  async validateGovernance(
    @Req() req: Request,
    @Body() dto: AnalyticsGovernanceValidationDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const correlationId = getCorrelationId(req);
    const data = await this.analyticsGovernanceService.validateInstrumentation({
      actorUserId,
      correlationId,
      dto,
    });
    return successResponse(data, correlationId);
  }

  @Get('governance/records')
  async queryGovernanceRecords(
    @Req() req: Request,
    @Query() query: GovernanceRecordsQueryDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const correlationId = getCorrelationId(req);
    const data = await this.analyticsGovernanceService.queryGovernanceRecords({
      actorUserId,
      correlationId,
      query,
    });
    return successResponse(data, correlationId);
  }

  @Post('governance/records/export')
  async exportGovernanceRecords(
    @Req() req: Request,
    @Body() dto: GovernanceRecordsExportDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const correlationId = getCorrelationId(req);
    const data = await this.analyticsGovernanceService.exportGovernanceRecords({
      actorUserId,
      correlationId,
      dto,
    });
    return successResponse(data, correlationId);
  }
}
