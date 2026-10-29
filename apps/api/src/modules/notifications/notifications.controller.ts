import { PushCampaignService } from './push-campaign.service';
import {
  PushCampaignDto,
  SchedulePushCampaignDto,
  PushRecipientEventDto,
} from './push-campaign.dto';
import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
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
  constructor(
    private readonly notificationsService: NotificationsService,
    private readonly campaigns: PushCampaignService,
  ) {}

  @Get('inbox')
  async getInbox(@Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.notificationsService.getInbox(userId);
    return successResponse(data, getCorrelationId(req));
  }

  @Post('inbox/:source/:id/read')
  async markInboxRead(
    @Req() req: Request,
    @Param('source') source: string,
    @Param('id', new ParseUUIDPipe()) id: string,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.notificationsService.markInboxRead(
      userId,
      source,
      id,
    );
    return successResponse(data, getCorrelationId(req));
  }

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

  @Post('events')
  async event(@Req() req: Request, @Body() dto: PushRecipientEventDto) {
    return successResponse(
      await this.campaigns.recordEvent((req.user as RequestUser).id, dto),
      getCorrelationId(req),
    );
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
  constructor(
    private readonly notificationsService: NotificationsService,
    private readonly campaigns: PushCampaignService,
  ) {}

  @Get('campaigns')
  async campaignsList(@Req() req: Request) {
    return successResponse(await this.campaigns.list(), getCorrelationId(req));
  }
  @Post('campaigns')
  async campaignCreate(@Req() req: Request, @Body() dto: PushCampaignDto) {
    return successResponse(
      await this.campaigns.create((req.user as RequestUser).id, dto),
      getCorrelationId(req),
    );
  }
  @Patch('campaigns/:id')
  async campaignUpdate(
    @Req() req: Request,
    @Param('id', new ParseUUIDPipe()) id: string,
    @Body() dto: PushCampaignDto,
  ) {
    return successResponse(
      await this.campaigns.update((req.user as RequestUser).id, id, dto),
      getCorrelationId(req),
    );
  }
  @Get('campaigns/:id/preview')
  async campaignPreview(
    @Req() req: Request,
    @Param('id', new ParseUUIDPipe()) id: string,
  ) {
    return successResponse(
      await this.campaigns.preview(id),
      getCorrelationId(req),
    );
  }
  @Get('campaigns/:id/analytics')
  async campaignAnalytics(
    @Req() req: Request,
    @Param('id', new ParseUUIDPipe()) id: string,
  ) {
    return successResponse(
      await this.campaigns.analytics(id),
      getCorrelationId(req),
    );
  }
  @Post('campaigns/:id/schedule')
  async campaignSchedule(
    @Req() req: Request,
    @Param('id', new ParseUUIDPipe()) id: string,
    @Body() dto: SchedulePushCampaignDto,
  ) {
    return successResponse(
      await this.campaigns.schedule((req.user as RequestUser).id, id, dto),
      getCorrelationId(req),
    );
  }
  @Post('campaigns/:id/test')
  async campaignTest(
    @Req() req: Request,
    @Param('id', new ParseUUIDPipe()) id: string,
  ) {
    return successResponse(
      await this.campaigns.test((req.user as RequestUser).id, id),
      getCorrelationId(req),
    );
  }
  @Post('campaigns/:id/cancel')
  async campaignCancel(
    @Req() req: Request,
    @Param('id', new ParseUUIDPipe()) id: string,
  ) {
    return successResponse(
      await this.campaigns.cancel((req.user as RequestUser).id, id),
      getCorrelationId(req),
    );
  }
  @Delete('campaigns/:id')
  async campaignDelete(
    @Req() req: Request,
    @Param('id', new ParseUUIDPipe()) id: string,
  ) {
    return successResponse(
      await this.campaigns.remove((req.user as RequestUser).id, id),
      getCorrelationId(req),
    );
  }
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
