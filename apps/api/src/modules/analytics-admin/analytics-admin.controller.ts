import {
  Body,
  Controller,
  Get,
  Param,
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
import { AnalyticsAdminService } from './analytics-admin.service';
import { AnalyticsGovernanceService } from './analytics-governance.service';
import { UserActivityService } from './user-activity.service';
import {
  AnalyticsGovernanceValidationDto,
  GovernanceRecordsExportDto,
  GovernanceRecordsQueryDto,
} from './analytics-governance.dto';
import { CoreProductAnalyticsQueryDto, UserDirectoryQueryDto } from './analytics-admin.dto';

@Controller('admin/analytics')
@UseGuards(AuthGuard, SuperadminGuard)
export class AnalyticsAdminController {
  constructor(
    private readonly analyticsAdminService: AnalyticsAdminService,
    private readonly analyticsGovernanceService: AnalyticsGovernanceService,
    private readonly userActivityService: UserActivityService,
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

  @Get('user-activity')
  async getUserActivityMetrics(@Req() req: Request): Promise<object> {
    const correlationId = getCorrelationId(req);
    const data = await this.userActivityService.getUserActivityMetrics();
    return successResponse(data, correlationId);
  }

  @Get('users')
  async getUserDirectory(
    @Query() query: UserDirectoryQueryDto,
    @Req() req: Request,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const data = await this.userActivityService.getUserDirectory(query);
    return successResponse(data, correlationId);
  }

  @Get('users/:userId')
  async getUserWorkbench(
    @Param('userId') userId: string,
    @Req() req: Request,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const data = await this.userActivityService.getUserWorkbench(userId);
    return successResponse(data, correlationId);
  }

  @Get('files/pipeline-status')
  async getFilePipelineStatus(@Req() req: Request): Promise<object> {
    const correlationId = getCorrelationId(req);
    const data = await this.userActivityService.getFilePipelineStatus();
    return successResponse(data, correlationId);
  }
}
