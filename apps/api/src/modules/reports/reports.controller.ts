import {
  BadRequestException,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Req,
  Res,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { StreamableFile } from '@nestjs/common/file-stream';
import type { Response } from 'express';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import type { Request } from 'express';
import type { Express } from 'express';
import type { RequestUser } from '../auth/auth.types';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import { AuthService } from '../auth/auth.service';
import { ReportsService } from './reports.service';
import {
  ALLOWED_CONTENT_TYPES,
  MAX_REPORT_SIZE_BYTES,
  REPORT_FILE_REQUIRED,
} from './reports.types';

function getClientIp(req: Request): string {
  const forwarded = req.header('x-forwarded-for');
  if (forwarded) return forwarded.split(',')[0].trim();
  return req.ip ?? 'unknown';
}

@Controller('reports')
@UseGuards(AuthGuard)
export class ReportsController {
  constructor(
    private readonly reportsService: ReportsService,
    private readonly authService: AuthService,
  ) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @UseInterceptors(
    FileInterceptor('file', {
      storage: memoryStorage(),
      fileFilter: (_req, file, cb) => {
        if (!file) {
          cb(new Error('No file'), false);
          return;
        }
        if (
          !ALLOWED_CONTENT_TYPES.includes(file.mimetype as 'application/pdf')
        ) {
          cb(new Error('Only PDF files are allowed'), false);
          return;
        }
        cb(null, true);
      },
      limits: { fileSize: MAX_REPORT_SIZE_BYTES },
    }),
  )
  async uploadReport(@Req() req: Request): Promise<object> {
    const file = (req as Request & { file?: Express.Multer.File }).file;
    if (!file) {
      throw new BadRequestException({
        code: REPORT_FILE_REQUIRED,
        message: 'Missing file. Use multipart field "file".',
      });
    }
    this.authService.enforceRateLimit('report-upload', getClientIp(req), 10);
    const { id: userId } = req.user as RequestUser;
    const data = await this.reportsService.uploadReport(userId, {
      buffer: file.buffer,
      originalname: file.originalname ?? 'report.pdf',
      mimetype: file.mimetype ?? 'application/pdf',
      size: file.size ?? 0,
    });
    return successResponse(data, getCorrelationId(req));
  }

  @Get(':id/file')
  async getReportFile(
    @Param('id') reportId: string,
    @Req() req: Request,
    @Res({ passthrough: true }) res: Response,
  ): Promise<StreamableFile> {
    const { id: userId } = req.user as RequestUser;
    const { buffer, contentType, originalFileName } =
      await this.reportsService.getReportFile(userId, reportId);
    const safeName = originalFileName.replace(/[^\w.-]/g, '_');
    // RFC 5987: filename* for non-ASCII; filename for legacy clients
    const hasNonAscii = /[^\x00-\x7F]/.test(originalFileName);
    const disposition = hasNonAscii
      ? `inline; filename="${safeName}"; filename*=UTF-8''${encodeURIComponent(originalFileName)}`
      : `inline; filename="${safeName}"`;
    res.setHeader('Content-Disposition', disposition);
    res.setHeader('Content-Type', contentType);
    return new StreamableFile(buffer);
  }

  @Get(':id')
  async getReport(
    @Param('id') reportId: string,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.reportsService.getReport(userId, reportId);
    return successResponse(data, getCorrelationId(req));
  }

  @Post(':id/retry')
  async retryParse(
    @Param('id') reportId: string,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.reportsService.retryParse(userId, reportId);
    return successResponse(data, getCorrelationId(req));
  }

  @Post(':id/keep-file')
  async keepFile(
    @Param('id') reportId: string,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.reportsService.keepFile(userId, reportId);
    return successResponse(data, getCorrelationId(req));
  }
}
