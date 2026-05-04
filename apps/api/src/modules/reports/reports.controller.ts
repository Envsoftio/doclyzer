import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Query,
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

  @Get('lab-trends')
  async getLabTrends(
    @Query('profileId') profileId: string | undefined,
    @Query('parameterName') parameterName: string | undefined,
    @Req() req: Request,
  ): Promise<object> {
    if (!profileId) {
      throw new BadRequestException({
        code: 'PROFILE_ID_REQUIRED',
        message: 'profileId query parameter is required',
      });
    }
    const { id: userId } = req.user as RequestUser;
    const data = await this.reportsService.getLabTrends(
      userId,
      profileId,
      parameterName,
    );
    return successResponse(data, getCorrelationId(req));
  }

  @Get()
  async listReports(
    @Query('profileId') profileId: string | undefined,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.reportsService.listReports(userId, profileId);
    return successResponse({ reports: data }, getCorrelationId(req));
  }

  @Get('recycle-bin')
  async listRecycleBin(
    @Query('profileId') profileId: string | undefined,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.reportsService.listRecycleBin(userId, profileId);
    return successResponse({ reports: data }, getCorrelationId(req));
  }

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
        const isPdfType = ALLOWED_CONTENT_TYPES.includes(
          file.mimetype as 'application/pdf',
        );
        const isOctetStreamWithPdfName =
          file.mimetype === 'application/octet-stream' &&
          /\.pdf$/i.test(file.originalname ?? '');
        if (!isPdfType && !isOctetStreamWithPdfName) {
          cb(new Error('Only PDF files are allowed'), false);
          return;
        }
        cb(null, true);
      },
      limits: { fileSize: MAX_REPORT_SIZE_BYTES },
    }),
  )
  async uploadReport(
    @Req() req: Request,
    @Query('duplicateAction') duplicateAction?: string,
  ): Promise<object> {
    const file = (req as Request & { file?: Express.Multer.File }).file;
    if (!file) {
      throw new BadRequestException({
        code: REPORT_FILE_REQUIRED,
        message: 'Missing file. Use multipart field "file".',
      });
    }
    this.authService.enforceRateLimit('report-upload', getClientIp(req), 10);
    const { id: userId } = req.user as RequestUser;
    const options =
      duplicateAction === 'upload_anyway'
        ? { duplicateAction: 'upload_anyway' as const }
        : undefined;
    const mimetype =
      file.mimetype === 'application/octet-stream' &&
      /\.pdf$/i.test(file.originalname ?? '')
        ? 'application/pdf'
        : (file.mimetype ?? 'application/pdf');
    const data = await this.reportsService.uploadReport(
      userId,
      {
        buffer: file.buffer,
        originalname: file.originalname ?? 'report.pdf',
        mimetype,
        size: file.size ?? 0,
      },
      options,
      getCorrelationId(req),
    );
    return successResponse(data, getCorrelationId(req));
  }

  @Get(':id/attempts')
  async getProcessingAttempts(
    @Param('id') reportId: string,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.reportsService.getProcessingAttempts(
      userId,
      reportId,
    );
    return successResponse({ attempts: data }, getCorrelationId(req));
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
    const hasNonAscii = Array.from(originalFileName).some(
      (char) => char.charCodeAt(0) > 0x7f,
    );
    const disposition = hasNonAscii
      ? `inline; filename="${safeName}"; filename*=UTF-8''${encodeURIComponent(originalFileName)}`
      : `inline; filename="${safeName}"`;
    res.setHeader('Content-Disposition', disposition);
    res.setHeader('Content-Type', contentType);
    return new StreamableFile(buffer);
  }

  @Post(':id/reassign')
  async reassignReport(
    @Param('id') reportId: string,
    @Body() body: { targetProfileId?: string },
    @Req() req: Request,
  ): Promise<object> {
    if (!body?.targetProfileId) {
      throw new BadRequestException({
        code: 'TARGET_PROFILE_ID_REQUIRED',
        message: 'targetProfileId is required in request body.',
      });
    }
    const { id: userId } = req.user as RequestUser;
    const data = await this.reportsService.reassignReport(
      userId,
      reportId,
      body.targetProfileId,
    );
    return successResponse(data, getCorrelationId(req));
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
    @Query('force') force: string | undefined,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.reportsService.retryParse(
      userId,
      reportId,
      { force: force === 'true' },
      getCorrelationId(req),
    );
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

  @Delete(':id')
  async deleteReport(
    @Param('id') reportId: string,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.reportsService.moveToRecycleBin(userId, reportId);
    return successResponse(data, getCorrelationId(req));
  }

  @Post(':id/restore')
  async restoreReport(
    @Param('id') reportId: string,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.reportsService.restoreFromRecycleBin(
      userId,
      reportId,
    );
    return successResponse(data, getCorrelationId(req));
  }
}
