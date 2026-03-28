import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import {
  SuperadminAdminActionTokenDto,
  SuperadminMfaVerifyDto,
} from './auth.dto';
import type { RequestUser } from './auth.types';
import { SuperadminAuthService } from './superadmin-auth.service';
import { SuperadminGuard } from './superadmin.guard';

function getClientIp(req: Request): string {
  const forwarded = req.header('x-forwarded-for');
  if (forwarded) return forwarded.split(',')[0].trim();
  return req.ip ?? 'unknown';
}

@Controller('auth/superadmin')
@UseGuards(AuthGuard, SuperadminGuard)
export class SuperadminAuthController {
  constructor(private readonly superadminAuthService: SuperadminAuthService) {}

  @Post('elevation/challenge')
  @HttpCode(HttpStatus.OK)
  async startChallenge(@Req() req: Request): Promise<object> {
    const userId = (req as Request & { user: RequestUser }).user.id;
    const sessionId =
      (req as Request & { currentSessionId?: string | null })
        .currentSessionId ?? 'unknown-session';
    const riskFingerprint = this.superadminAuthService.buildRiskFingerprint({
      explicitRiskPosture: req.header('x-risk-posture'),
      userAgent: req.header('user-agent'),
      ipAddress: getClientIp(req),
    });
    const data = await this.superadminAuthService.beginChallenge({
      userId,
      sessionId,
      correlationId: getCorrelationId(req),
      riskFingerprint,
    });
    return successResponse(data, getCorrelationId(req));
  }

  @Post('elevation/verify')
  @HttpCode(HttpStatus.OK)
  async verifyChallenge(
    @Req() req: Request,
    @Body() body: SuperadminMfaVerifyDto,
  ): Promise<object> {
    const userId = (req as Request & { user: RequestUser }).user.id;
    const riskFingerprint = this.superadminAuthService.buildRiskFingerprint({
      explicitRiskPosture: req.header('x-risk-posture'),
      userAgent: req.header('user-agent'),
      ipAddress: getClientIp(req),
    });
    const data = await this.superadminAuthService.verifyChallenge({
      userId,
      challengeId: body.challengeId,
      mfaCode: body.mfaCode,
      riskFingerprint,
      correlationId: getCorrelationId(req),
    });
    return successResponse(data, getCorrelationId(req));
  }

  @Post('elevation/token')
  @HttpCode(HttpStatus.OK)
  async issueAdminActionToken(
    @Req() req: Request,
    @Body() body: SuperadminAdminActionTokenDto,
  ): Promise<object> {
    const userId = (req as Request & { user: RequestUser }).user.id;
    const sessionId =
      (req as Request & { currentSessionId?: string | null })
        .currentSessionId ?? 'unknown-session';
    const riskFingerprint = this.superadminAuthService.buildRiskFingerprint({
      explicitRiskPosture: req.header('x-risk-posture'),
      userAgent: req.header('user-agent'),
      ipAddress: getClientIp(req),
    });
    const data = await this.superadminAuthService.issueAdminActionToken({
      userId,
      challengeId: body.challengeId,
      sessionId,
      correlationId: getCorrelationId(req),
      riskFingerprint,
    });
    return successResponse(data, getCorrelationId(req));
  }
}
