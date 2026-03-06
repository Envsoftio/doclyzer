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
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';
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
import { PasswordRecoveryService } from './password-recovery.service';

function getClientIp(req: Request): string {
  const forwarded = req.header('x-forwarded-for');
  if (forwarded) {
    return forwarded.split(',')[0].trim();
  }
  return req.ip ?? 'unknown';
}

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly recoveryService: PasswordRecoveryService,
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
  async login(@Body() body: LoginDto, @Req() req: Request): Promise<object> {
    this.authService.enforceRateLimit('login', getClientIp(req));
    const ip = getClientIp(req);
    const userAgent = req.headers['user-agent'] ?? 'Unknown';
    const data = await this.authService.login(body, ip, userAgent);
    return successResponse(data, getCorrelationId(req));
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  logout(@Req() req: Request): object {
    const authorizationHeader = req.header('authorization');
    const accessToken = this.extractBearerToken(authorizationHeader);
    this.authService.logout(accessToken);
    return successResponse({ revoked: true }, getCorrelationId(req));
  }

  @Get('sessions')
  @UseGuards(AuthGuard)
  getSessions(@Req() req: Request): object {
    const userId = (req as Request & { user: RequestUser }).user.id;
    const currentSessionId = (req as Request & { currentSessionId?: string | null })
      .currentSessionId ?? null;
    const sessions = this.authService.getSessions(userId, currentSessionId);
    return successResponse(sessions, getCorrelationId(req));
  }

  @Delete('sessions/:sessionId')
  @UseGuards(AuthGuard)
  revokeSession(
    @Req() req: Request,
    @Param('sessionId') sessionId: string,
  ): object {
    const userId = (req as Request & { user: RequestUser }).user.id;
    this.authService.revokeSession(
      userId,
      sessionId,
      getCorrelationId(req),
    );
    return successResponse(null, getCorrelationId(req));
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  refresh(@Body() body: RefreshDto, @Req() req: Request): object {
    const data = this.authService.refresh(body.refreshToken);
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

  private extractBearerToken(authorizationHeader?: string): string {
    if (!authorizationHeader) {
      throw new UnauthorizedException({
        code: 'AUTH_TOKEN_REQUIRED',
        message: 'Authorization bearer token is required',
      });
    }

    const [scheme, token] = authorizationHeader.split(' ');
    if (scheme !== 'Bearer' || !token) {
      throw new UnauthorizedException({
        code: 'AUTH_TOKEN_REQUIRED',
        message: 'Authorization bearer token is required',
      });
    }

    return token;
  }
}
