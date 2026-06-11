import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { AuthGuard } from '../../common/guards/auth.guard';
import { successResponse } from '../../common/response-envelope';
import type { RequestUser } from '../auth/auth.types';
import { SuperadminGuard } from '../auth/superadmin.guard';
import {
  AdminPushBroadcastDto,
  PushAuditQueryDto,
  PushOpenDto,
  RegisterDeviceTokenDto,
  UpdateDeviceTokenPreferencesDto,
} from './notifications.dto';
import { NotificationsService } from './notifications.service';

@Controller('notifications')
@UseGuards(AuthGuard)
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get('device-tokens')
  async listDeviceTokens(@Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.notificationsService.listDeviceTokens(userId);
    return successResponse(data, getCorrelationId(req));
  }

  @Post('device-tokens')
  @HttpCode(HttpStatus.CREATED)
  async registerDeviceToken(
    @Req() req: Request,
    @Body() dto: RegisterDeviceTokenDto,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.notificationsService.registerDeviceToken(
      userId,
      dto,
    );
    return successResponse(data, getCorrelationId(req));
  }

  @Patch('device-tokens/:id/preferences')
  async updateDeviceTokenPreferences(
    @Req() req: Request,
    @Param('id') deviceTokenId: string,
    @Body() dto: UpdateDeviceTokenPreferencesDto,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.notificationsService.updateDeviceTokenPreferences(
      userId,
      deviceTokenId,
      dto,
    );
    return successResponse(data, getCorrelationId(req));
  }

  @Delete('device-tokens/:id')
  @HttpCode(HttpStatus.OK)
  async deactivateDeviceToken(
    @Req() req: Request,
    @Param('id') deviceTokenId: string,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.notificationsService.deactivateDeviceToken(
      userId,
      deviceTokenId,
    );
    return successResponse(data, getCorrelationId(req));
  }

  @Post('push-open')
  @HttpCode(HttpStatus.CREATED)
  async trackPushOpen(
    @Req() req: Request,
    @Body() dto: PushOpenDto,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.notificationsService.trackPushOpen(userId, dto);
    return successResponse(data, getCorrelationId(req));
  }
}

@Controller('admin/notifications')
@UseGuards(AuthGuard, SuperadminGuard)
export class NotificationsAdminController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get('metrics')
  async getMetrics(@Req() req: Request): Promise<object> {
    const data = await this.notificationsService.getMetrics();
    return successResponse(data, getCorrelationId(req));
  }

  @Get('push/audit')
  async getPushAudit(
    @Req() req: Request,
    @Query() query: PushAuditQueryDto,
  ): Promise<object> {
    const data = await this.notificationsService.getPushAudit(query);
    return successResponse(data, getCorrelationId(req));
  }

  @Post('push/dry-run')
  async dryRunPush(
    @Req() req: Request,
    @Body() dto: AdminPushBroadcastDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const correlationId = getCorrelationId(req);
    const data = await this.notificationsService.dryRunAdminPush({
      actorUserId,
      correlationId,
      dto,
    });
    return successResponse(data, correlationId);
  }

  @Post('push/send')
  async sendPush(
    @Req() req: Request,
    @Body() dto: AdminPushBroadcastDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const correlationId = getCorrelationId(req);
    const data = await this.notificationsService.sendAdminPush({
      actorUserId,
      correlationId,
      dto,
    });
    return successResponse(data, correlationId);
  }
}
