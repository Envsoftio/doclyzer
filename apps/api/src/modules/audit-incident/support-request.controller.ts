import {
  Body,
  Controller,
  Get,
  NotFoundException,
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
import {
  CreateSupportRequestDto,
  SupportRequestAdminQueryDto,
} from './support-request.dto';
import { SupportRequestService } from './support-request.service';

@Controller('support-requests')
@UseGuards(AuthGuard)
export class SupportRequestController {
  constructor(private readonly supportRequestService: SupportRequestService) {}

  @Post()
  async createSupportRequest(
    @Req() req: Request,
    @Body() dto: CreateSupportRequestDto,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const correlationId = getCorrelationId(req);
    const data = await this.supportRequestService.createSupportRequest({
      userId,
      dto,
    });
    return successResponse(data, correlationId);
  }
}

@Controller('admin/support-requests')
@UseGuards(AuthGuard, SuperadminGuard)
export class SupportRequestAdminController {
  constructor(private readonly supportRequestService: SupportRequestService) {}

  @Get()
  async listSupportRequests(
    @Req() req: Request,
    @Query() query: SupportRequestAdminQueryDto,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const data = await this.supportRequestService.listSupportRequests(query);
    return successResponse(data, correlationId);
  }

  @Get(':supportRequestId')
  async getSupportRequest(
    @Req() req: Request,
    @Param('supportRequestId') supportRequestId: string,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const data = await this.supportRequestService.getSupportRequestById(
      supportRequestId,
    );
    if (!data) {
      throw new NotFoundException({
        code: 'SUPPORT_REQUEST_NOT_FOUND',
        message: 'Support request not found',
      });
    }
    return successResponse(data, correlationId);
  }
}
