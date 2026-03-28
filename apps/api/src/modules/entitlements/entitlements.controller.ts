import {
  Body,
  Controller,
  Get,
  Param,
  Put,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import type { RequestUser } from '../auth/auth.types';
import { SuperadminGuard } from '../auth/superadmin.guard';
import { UpdatePlanConfigDto } from './entitlements.dto';
import { EntitlementsService } from './entitlements.service';

@Controller('entitlements')
@UseGuards(AuthGuard)
export class EntitlementsController {
  constructor(private readonly entitlementsService: EntitlementsService) {}

  @Get('summary')
  async getSummary(@Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.entitlementsService.getEntitlementSummary(userId);
    return successResponse(data, getCorrelationId(req));
  }

  @Get('admin/plan-configs')
  @UseGuards(AuthGuard, SuperadminGuard)
  async listPlanConfigs(@Req() req: Request): Promise<object> {
    const data = await this.entitlementsService.listPlanConfigurations();
    return successResponse(
      {
        state: 'success',
        plans: data,
      },
      getCorrelationId(req),
    );
  }

  @Put('admin/plan-configs/:planId')
  @UseGuards(AuthGuard, SuperadminGuard)
  async updatePlanConfig(
    @Req() req: Request,
    @Param('planId') planId: string,
    @Body() dto: UpdatePlanConfigDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.entitlementsService.updatePlanConfiguration({
      actorUserId,
      planId,
      dto,
      correlationId: getCorrelationId(req),
    });
    return successResponse(data, getCorrelationId(req));
  }
}
