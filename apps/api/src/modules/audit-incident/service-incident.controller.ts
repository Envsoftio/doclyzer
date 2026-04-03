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

import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import { AuthGuard } from '../../common/guards/auth.guard';
import { SuperadminGuard } from '../auth/superadmin.guard';
import { ServiceIncidentService } from './service-incident.service';
import {
  CreateServiceIncidentDto,
  ResolveServiceIncidentDto,
} from './service-incident.dto';

@Controller('incidents')
export class ServiceIncidentPublicController {
  constructor(private readonly serviceIncidentService: ServiceIncidentService) {}

  @Get('active')
  async getActiveIncident(@Req() req: Request): Promise<object> {
    const correlationId = getCorrelationId(req);
    const data = await this.serviceIncidentService.getCurrentPublicIncident();
    return successResponse(data, correlationId);
  }
}

@Controller('admin/incidents')
@UseGuards(AuthGuard, SuperadminGuard)
export class ServiceIncidentAdminController {
  constructor(private readonly serviceIncidentService: ServiceIncidentService) {}

  @Post()
  async upsertIncident(
    @Req() req: Request,
    @Body() dto: CreateServiceIncidentDto,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const data = await this.serviceIncidentService.upsertIncident(dto);
    return successResponse(data, correlationId);
  }

  @Patch(':id/resolve')
  async resolveIncident(
    @Req() req: Request,
    @Param('id') id: string,
    @Body() dto: ResolveServiceIncidentDto,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const data = await this.serviceIncidentService.resolveIncident(id, dto);
    return successResponse(data, correlationId);
  }
}
