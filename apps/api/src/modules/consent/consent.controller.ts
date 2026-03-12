import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';
import type { RequestUser } from '../auth/auth.types';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import { AcceptPoliciesDto } from './consent.dto';
import { ConsentService } from './consent.service';

@Controller('consent')
@UseGuards(AuthGuard)
export class ConsentController {
  constructor(private readonly consentService: ConsentService) {}

  @Get('status')
  async getStatus(@Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.consentService.getStatus(userId);
    return successResponse(data, getCorrelationId(req));
  }

  @Post('accept')
  @HttpCode(HttpStatus.OK)
  async accept(
    @Body() body: AcceptPoliciesDto,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.consentService.acceptPolicies(
      userId,
      body.policyTypes,
    );
    return successResponse(data, getCorrelationId(req));
  }
}
