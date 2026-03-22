import { Controller, Get, Param, Req } from '@nestjs/common';
import type { Request } from 'express';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import { SharingService } from './sharing.service';

@Controller('sharing/public')
export class PublicSharingController {
  constructor(private readonly sharingService: SharingService) {}

  @Get(':token')
  async getPublicShareData(
    @Param('token') token: string,
    @Req() req: Request,
  ): Promise<object> {
    const data = await this.sharingService.getPublicShareData(token);
    return successResponse(data, getCorrelationId(req));
  }
}
