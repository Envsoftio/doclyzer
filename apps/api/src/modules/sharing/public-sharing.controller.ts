import { Body, Controller, Get, Param, Post, Req, Res } from '@nestjs/common';
import type { Request, Response } from 'express';
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

  @Post(':token/unlock')
  async unlockPublicShareData(
    @Param('token') token: string,
    @Body() body: { accessCode?: string },
    @Req() req: Request,
  ): Promise<object> {
    const data = await this.sharingService.getPublicShareData(token, body?.accessCode);
    return successResponse(data, getCorrelationId(req));
  }

  @Post(':token/reports/:reportId/original')
  async downloadSharedOriginal(
    @Param('token') token: string,
    @Param('reportId') reportId: string,
    @Body() body: { accessCode?: string },
    @Res() response: Response,
  ): Promise<void> {
    const file = await this.sharingService.getSharedOriginal(
      token,
      reportId,
      body?.accessCode,
    );
    response.status(200);
    response.setHeader('Content-Type', file.contentType);
    response.setHeader('Content-Disposition',
      `attachment; filename*=UTF-8''${encodeURIComponent(file.fileName)}`);
    response.setHeader('Cache-Control', 'no-store');
    response.end(file.data);
  }
}
