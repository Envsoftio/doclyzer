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
  Req,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';
import type { RequestUser } from '../auth/auth.types';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import { CreateProfileDto, UpdateProfileDto } from './profiles.dto';
import { ProfilesService } from './profiles.service';

@Controller('profiles')
@UseGuards(AuthGuard)
export class ProfilesController {
  constructor(private readonly profilesService: ProfilesService) {}

  @Get()
  async getProfiles(@Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.profilesService.getProfiles(userId);
    return successResponse(data, getCorrelationId(req));
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async createProfile(@Body() body: CreateProfileDto, @Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.profilesService.createProfile(userId, body);
    return successResponse(data, getCorrelationId(req));
  }

  @Patch(':id')
  async updateProfile(
    @Param('id') profileId: string,
    @Body() body: UpdateProfileDto,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.profilesService.updateProfile(userId, profileId, body);
    return successResponse(data, getCorrelationId(req));
  }

  @Post(':id/activate')
  @HttpCode(HttpStatus.OK)
  async activateProfile(@Param('id') profileId: string, @Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.profilesService.activateProfile(userId, profileId);
    return successResponse(data, getCorrelationId(req));
  }

  @Delete(':id')
  async deleteProfile(@Param('id') profileId: string, @Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.profilesService.deleteProfile(userId, profileId);
    return successResponse(data, getCorrelationId(req));
  }
}
