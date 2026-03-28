import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Req,
  Res,
  UseGuards,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import {
  ForgotPasswordDto,
  LoginDto,
  RefreshDto,
  RegisterDto,
  ResetPasswordDto,
} from './auth.dto';
import type { RequestUser } from './auth.types';
import { AuthService } from './auth.service';
import { BetterAuthService } from './better-auth.service';
import { PasswordRecoveryService } from './password-recovery.service';

function getClientIp(req: Request): string {
  const forwarded = req.header('x-forwarded-for');
  if (forwarded) return forwarded.split(',')[0].trim();
  return req.ip ?? 'unknown';
}

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly recoveryService: PasswordRecoveryService,
    private readonly betterAuthService: BetterAuthService,
  ) {}

  @Post('register')
  async register(
    @Body() body: RegisterDto,
    @Req() req: Request,
  ): Promise<object> {
    this.authService.enforceRateLimit('register', getClientIp(req), 20);
    const data = await this.authService.register(body);
    return successResponse(data, getCorrelationId(req));
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(
    @Body() body: LoginDto,
    @Req() req: Request,
    @Res({ passthrough: true }) res: Response,
  ): Promise<object> {
    this.authService.enforceRateLimit('login', getClientIp(req));
    const { data, headers } = await this.authService.login(
      body,
      this.betterAuthService.buildHeadersFromRequest(req),
    );
    this.applyAuthHeaders(res, headers);
    return successResponse(data, getCorrelationId(req));
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard)
  async logout(
    @Req() req: Request,
    @Res({ passthrough: true }) res: Response,
  ): Promise<object> {
    const headers = this.betterAuthService.buildHeadersFromRequest(req);
    const responseHeaders = await this.authService.logout(headers);
    this.applyAuthHeaders(res, responseHeaders);
    return successResponse({ revoked: true }, getCorrelationId(req));
  }

  @Get('sessions')
  @UseGuards(AuthGuard)
  async getSessions(@Req() req: Request): Promise<object> {
    const userId = (req as Request & { user: RequestUser }).user.id;
    const currentSessionId =
      (req as Request & { currentSessionId?: string | null })
        .currentSessionId ?? null;
    const sessions = await this.authService.getSessions(
      userId,
      currentSessionId,
    );
    return successResponse(sessions, getCorrelationId(req));
  }

  @Delete('sessions/:sessionId')
  @UseGuards(AuthGuard)
  async revokeSession(
    @Req() req: Request,
    @Param('sessionId') sessionId: string,
  ): Promise<object> {
    const userId = (req as Request & { user: RequestUser }).user.id;
    await this.authService.revokeSession(
      userId,
      sessionId,
      getCorrelationId(req),
    );
    return successResponse(null, getCorrelationId(req));
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  async refresh(
    @Body() body: RefreshDto,
    @Req() req: Request,
    @Res({ passthrough: true }) res: Response,
  ): Promise<object> {
    this.authService.enforceRateLimit('refresh', getClientIp(req));
    const headers = this.betterAuthService.buildHeadersFromRequest(req);
    headers.set('authorization', `Bearer ${body.refreshToken}`);
    const { data, headers: responseHeaders } = await this.authService.refresh(
      body.refreshToken,
      headers,
    );
    this.applyAuthHeaders(res, responseHeaders);
    return successResponse(data, getCorrelationId(req));
  }

  @Post('forgot-password')
  @HttpCode(HttpStatus.OK)
  async forgotPassword(
    @Body() body: ForgotPasswordDto,
    @Req() req: Request,
  ): Promise<object> {
    const clientIp = getClientIp(req);
    this.authService.enforceRateLimit('forgot-password', clientIp, 20);
    this.authService.enforceRateLimit('forgot-password-account', body.email, 5);
    const data = await this.recoveryService.requestReset(body.email);
    return successResponse(data, getCorrelationId(req));
  }

  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  async resetPassword(
    @Body() body: ResetPasswordDto,
    @Req() req: Request,
  ): Promise<object> {
    const data = await this.recoveryService.confirmReset(
      body.token,
      body.newPassword,
    );
    return successResponse(data, getCorrelationId(req));
  }

  private applyAuthHeaders(res: Response, headers: Headers | null): void {
    if (!headers) return;
    const setCookies = this.betterAuthService.extractSetCookie(headers);
    if (setCookies.length > 0) {
      res.setHeader('set-cookie', setCookies);
    }
    const authToken = headers.get('set-auth-token');
    if (authToken) {
      res.setHeader('set-auth-token', authToken);
    }
    const exposeHeaders = headers.get('access-control-expose-headers');
    if (exposeHeaders) {
      res.setHeader('access-control-expose-headers', exposeHeaders);
    }
  }
}
