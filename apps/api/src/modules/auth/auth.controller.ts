import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Post,
  Req,
  UnauthorizedException,
} from '@nestjs/common';
import type { Request } from 'express';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import { AuthService } from './auth.service';
import type { LoginRequest, RegisterRequest } from './auth.types';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  async register(
    @Body() body: RegisterRequest,
    @Req() req: Request,
  ): Promise<object> {
    this.authService.enforceRateLimit('register', req.ip ?? 'unknown');
    const data = await this.authService.register(body);
    return successResponse(data, getCorrelationId(req));
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(
    @Body() body: LoginRequest,
    @Req() req: Request,
  ): Promise<object> {
    this.authService.enforceRateLimit('login', req.ip ?? 'unknown');
    const data = await this.authService.login(body);
    return successResponse(data, getCorrelationId(req));
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  async logout(@Req() req: Request): Promise<object> {
    const authorizationHeader = req.header('authorization');
    const accessToken = this.extractBearerToken(authorizationHeader);
    await this.authService.logout(accessToken);
    return successResponse({ revoked: true }, getCorrelationId(req));
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
