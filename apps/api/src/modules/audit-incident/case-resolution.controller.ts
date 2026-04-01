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
import { CaseResolutionService } from './case-resolution.service';
import { ResolutionQueryDto, SubmitResolutionDto } from './case-resolution.dto';

@Controller('admin/accounts/:userId/resolutions')
@UseGuards(AuthGuard, SuperadminGuard)
export class CaseResolutionController {
  constructor(
    private readonly caseResolutionService: CaseResolutionService,
  ) {}

  /**
   * POST /admin/accounts/:userId/resolutions
   * Submit closure documentation for a restricted account case.
   * AC1: outcome documentation stored and linked to audit trail.
   * AC2: required fields validated; missing fields block submission.
   */
  @Post()
  async submitResolution(
    @Req() req: Request,
    @Param('userId') targetUserId: string,
    @Body() dto: SubmitResolutionDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const correlationId = getCorrelationId(req);
    const data = await this.caseResolutionService.submitResolution({
      actorUserId,
      correlationId,
      targetUserId,
      dto,
    });
    return successResponse(data, correlationId);
  }

  /**
   * GET /admin/accounts/:userId/resolutions
   * List all closure packets for a case, filterable by date and outcome.
   * AC4: authorized users can retrieve closure packets by case id and date.
   */
  @Get()
  async listResolutions(
    @Req() req: Request,
    @Param('userId') targetUserId: string,
    @Query() query: ResolutionQueryDto,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const data = await this.caseResolutionService.listResolutions({
      targetUserId,
      query,
    });
    return successResponse(data, correlationId);
  }

  /**
   * GET /admin/accounts/:userId/resolutions/:documentId
   * Retrieve a specific closure packet by document ID.
   * AC4: authorized users can retrieve closure packets by case id.
   */
  @Get(':documentId')
  async getResolution(
    @Req() req: Request,
    @Param('userId') targetUserId: string,
    @Param('documentId') documentId: string,
  ): Promise<object> {
    const correlationId = getCorrelationId(req);
    const data = await this.caseResolutionService.getResolutionById({
      targetUserId,
      documentId,
    });
    return successResponse(data, correlationId);
  }
}
