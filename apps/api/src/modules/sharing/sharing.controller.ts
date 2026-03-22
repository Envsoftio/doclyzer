import {
  BadRequestException, Body, Controller, Delete, Get, HttpCode,
  HttpStatus, Param, Patch, Post, Put, Query, Req, UseGuards
} from '@nestjs/common';
import type { Request } from 'express';
import type { RequestUser } from '../auth/auth.types';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import { SharingService } from './sharing.service';
import { EXPIRY_MUST_BE_FUTURE, PROFILE_ID_REQUIRED } from './sharing.types';

@Controller('sharing')
@UseGuards(AuthGuard)
export class SharingController {
  constructor(private readonly sharingService: SharingService) {}

  @Post('links')
  @HttpCode(HttpStatus.CREATED)
  async createShareLink(
    @Body() body: { profileId?: string; expiresAt?: string },
    @Req() req: Request,
  ): Promise<object> {
    if (!body?.profileId) {
      throw new BadRequestException({ code: PROFILE_ID_REQUIRED, message: 'profileId is required' });
    }
    const { id: userId } = req.user as RequestUser;
    let expiresAt: Date | undefined;
    if (body.expiresAt) {
      expiresAt = new Date(body.expiresAt);
      if (isNaN(expiresAt.getTime())) {
        throw new BadRequestException({ code: EXPIRY_MUST_BE_FUTURE, message: 'expiresAt must be a valid ISO datetime' });
      }
    }
    const data = await this.sharingService.createShareLink(userId, body.profileId, 'all', expiresAt);
    return successResponse(data, getCorrelationId(req));
  }

  @Get('links')
  async listShareLinks(
    @Query('profileId') profileId: string | undefined,
    @Req() req: Request,
  ): Promise<object> {
    if (!profileId) {
      throw new BadRequestException({ code: PROFILE_ID_REQUIRED, message: 'profileId is required' });
    }
    const { id: userId } = req.user as RequestUser;
    const data = await this.sharingService.listShareLinks(userId, profileId);
    return successResponse(data, getCorrelationId(req));
  }

  @Delete('links/:id')
  @HttpCode(HttpStatus.OK)
  async revokeShareLink(
    @Param('id') linkId: string,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    await this.sharingService.revokeShareLink(userId, linkId);
    return successResponse(null, getCorrelationId(req));
  }

  @Patch('links/:id/expiry')
  async updateExpiry(
    @Param('id') linkId: string,
    @Body() body: { expiresAt: string | null },
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    let expiresAt: Date | null = null;
    if (body.expiresAt) {
      expiresAt = new Date(body.expiresAt);
      if (isNaN(expiresAt.getTime())) {
        throw new BadRequestException({ code: EXPIRY_MUST_BE_FUTURE, message: 'expiresAt must be a valid ISO datetime' });
      }
    }
    const data = await this.sharingService.updateExpiry(userId, linkId, expiresAt);
    return successResponse(data, getCorrelationId(req));
  }

  @Get('links/:id/access-events')
  async listAccessEvents(
    @Param('id') linkId: string,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.sharingService.listAccessEvents(userId, linkId);
    return successResponse(data, getCorrelationId(req));
  }

  @Get('policy')
  async getSharePolicy(@Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.sharingService.getPolicy(userId);
    return successResponse(data, getCorrelationId(req));
  }

  @Put('policy')
  async upsertSharePolicy(
    @Body() body: { defaultExpiresInDays: number | null },
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.sharingService.upsertPolicy(userId, body.defaultExpiresInDays ?? null);
    return successResponse(data, getCorrelationId(req));
  }
}
