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
import type { RequestUser } from '../../modules/auth/auth.types';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import {
  CreateClosureRequestDto,
  CreateDataExportRequestDto,
  UpdateAccountProfileDto,
  UpdateCommunicationPreferencesDto,
} from './account.dto';
import { AccountService } from './account.service';
import { ExportRequestNotFoundException } from './account.types';

@Controller('account')
@UseGuards(AuthGuard)
export class AccountController {
  constructor(private readonly accountService: AccountService) {}

  @Get('restriction-status')
  async getRestrictionStatus(@Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.accountService.getRestrictionStatus(userId);
    return successResponse(data, getCorrelationId(req));
  }

  @Get('profile')
  async getProfile(@Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.accountService.getProfile(userId);
    return successResponse(data, getCorrelationId(req));
  }

  @Patch('profile')
  @HttpCode(HttpStatus.OK)
  async updateProfile(
    @Body() body: UpdateAccountProfileDto,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.accountService.updateProfile(userId, body);
    return successResponse(data, getCorrelationId(req));
  }

  @Get('communication-preferences')
  async getCommunicationPreferences(@Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.accountService.getCommunicationPreferences(userId);
    return successResponse(data, getCorrelationId(req));
  }

  @Patch('communication-preferences')
  @HttpCode(HttpStatus.OK)
  async updateCommunicationPreferences(
    @Body() body: UpdateCommunicationPreferencesDto,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.accountService.updateCommunicationPreferences(userId, body);
    return successResponse(data, getCorrelationId(req));
  }

  @Post('data-export-requests')
  @HttpCode(HttpStatus.CREATED)
  async createDataExportRequest(
    @Body() _body: CreateDataExportRequestDto,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const correlationId = getCorrelationId(req);
    const data = await this.accountService.createDataExportRequest(userId, correlationId);
    return successResponse(data, correlationId);
  }

  @Get('data-export-requests/:requestId')
  async getDataExportRequest(
    @Param('requestId') requestId: string,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.accountService.getDataExportRequest(userId, requestId);
    if (!data) throw new ExportRequestNotFoundException();
    return successResponse(data, getCorrelationId(req));
  }

  @Post('closure-requests')
  @HttpCode(HttpStatus.CREATED)
  async createClosureRequest(
    @Body() body: CreateClosureRequestDto,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const correlationId = getCorrelationId(req);
    const data = await this.accountService.createClosureRequest(userId, body, correlationId);
    return successResponse(data, correlationId);
  }

  @Get('closure-request')
  async getClosureRequest(@Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.accountService.getClosureRequest(userId);
    return successResponse(
      { status: data?.status ?? null, request: data },
      getCorrelationId(req),
    );
  }
}
