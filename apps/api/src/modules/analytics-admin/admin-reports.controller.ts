import {
  Controller,
  Get,
  Header,
  Param,
  ParseUUIDPipe,
  Query,
  Req,
  Res,
  StreamableFile,
  UseGuards,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import type { RequestUser } from '../auth/auth.types';
import { SuperadminGuard } from '../auth/superadmin.guard';
import { AdminReportsQueryDto } from './admin-reports.dto';
import { AdminReportsService } from './admin-reports.service';

@Controller('admin/reports')
@UseGuards(AuthGuard, SuperadminGuard)
export class AdminReportsController {
  constructor(private readonly adminReports: AdminReportsService) {}

  @Get()
  @Header('Cache-Control', 'private, no-store')
  async list(@Query() query: AdminReportsQueryDto, @Req() req: Request): Promise<object> {
    return successResponse(await this.adminReports.list(query), getCorrelationId(req));
  }

  @Get(':id')
  @Header('Cache-Control', 'private, no-store')
  async detail(@Param('id', ParseUUIDPipe) id: string, @Req() req: Request): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const correlationId = getCorrelationId(req);
    return successResponse(await this.adminReports.detail(id, actorUserId, correlationId), correlationId);
  }

  @Get(':id/file')
  async file(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: Request,
    @Res({ passthrough: true }) res: Response,
  ): Promise<StreamableFile> {
    const { id: actorUserId } = req.user as RequestUser;
    const file = await this.adminReports.file(id, actorUserId, getCorrelationId(req));
    const previewTypes = new Set(['application/pdf', 'image/jpeg', 'image/png']);
    const contentType = previewTypes.has(file.contentType) ? file.contentType : 'application/octet-stream';
    const safeName = file.originalFileName.replace(/[^\w.-]/g, '_');
    res.setHeader('Cache-Control', 'private, no-store');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('Content-Type', contentType);
    res.setHeader('Content-Disposition', `${contentType === 'application/octet-stream' ? 'attachment' : 'inline'}; filename="${safeName}"`);
    return new StreamableFile(file.buffer);
  }
}
