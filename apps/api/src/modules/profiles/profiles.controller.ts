import {
  Body,
  Controller,
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
import type { AuthUser } from '../auth/auth.types';
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
  getProfiles(@Req() req: Request): object {
    const { id: userId } = req.user as AuthUser;
    const data = this.profilesService.getProfiles(userId);
    return successResponse(data, getCorrelationId(req));
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  createProfile(@Body() body: CreateProfileDto, @Req() req: Request): object {
    const { id: userId } = req.user as AuthUser;
    const data = this.profilesService.createProfile(userId, body);
    return successResponse(data, getCorrelationId(req));
  }

  @Patch(':id')
  updateProfile(
    @Param('id') profileId: string,
    @Body() body: UpdateProfileDto,
    @Req() req: Request,
  ): object {
    const { id: userId } = req.user as AuthUser;
    const data = this.profilesService.updateProfile(userId, profileId, body);
    return successResponse(data, getCorrelationId(req));
  }

  @Post(':id/activate')
  @HttpCode(HttpStatus.OK)
  activateProfile(@Param('id') profileId: string, @Req() req: Request): object {
    const { id: userId } = req.user as AuthUser;
    const data = this.profilesService.activateProfile(userId, profileId);
    return successResponse(data, getCorrelationId(req));
  }
}
