import { BadRequestException } from '@nestjs/common';
import { StreamableFile } from '@nestjs/common/file-stream';
import type { Request } from 'express';
import type { RequestUser } from '../auth/auth.types';
import { ReportNotFoundException } from './exceptions/report-not-found.exception';
import { ReportsController } from './reports.controller';
import { ReportsService } from './reports.service';
import { REPORT_ALREADY_PARSED } from './reports.types';

const pdfBuffer = Buffer.from('%PDF-1.4 fake');
const validReportId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';

function makeReq(overrides: Partial<Request> = {}): Request {
  return {
    user: { id: 'user-1' } as RequestUser,
    correlationId: 'test-cid',
    header: () => undefined,
    ip: '127.0.0.1',
    ...overrides,
  } as unknown as Request;
}

describe('ReportsController', () => {
  let controller: ReportsController;
  let reportsService: jest.Mocked<
    Pick<
      ReportsService,
      'uploadReport' | 'getReport' | 'getReportFile' | 'retryParse' | 'keepFile'
    >
  >;
  let authService: jest.Mocked<
    Pick<import('../auth/auth.service').AuthService, 'enforceRateLimit'>
  >;

  beforeEach(() => {
    reportsService = {
      uploadReport: jest.fn().mockResolvedValue({
        reportId: 'r1',
        profileId: 'p1',
        fileName: 'x.pdf',
        contentType: 'application/pdf',
        sizeBytes: 100,
        status: 'parsed',
      }),
      getReportFile: jest.fn().mockResolvedValue({
        buffer: pdfBuffer,
        contentType: 'application/pdf',
        originalFileName: 'x.pdf',
      }),
      getReport: jest.fn().mockResolvedValue({
        id: validReportId,
        profileId: 'p1',
        originalFileName: 'x.pdf',
        contentType: 'application/pdf',
        sizeBytes: 100,
        status: 'queued',
        createdAt: '2026-01-01T00:00:00.000Z',
      }),
      retryParse: jest.fn().mockResolvedValue({
        id: validReportId,
        profileId: 'p1',
        originalFileName: 'x.pdf',
        contentType: 'application/pdf',
        sizeBytes: 100,
        status: 'parsed',
        createdAt: '2026-01-01T00:00:00.000Z',
      }),
      keepFile: jest.fn().mockResolvedValue({
        id: validReportId,
        profileId: 'p1',
        originalFileName: 'x.pdf',
        contentType: 'application/pdf',
        sizeBytes: 100,
        status: 'unparsed',
        createdAt: '2026-01-01T00:00:00.000Z',
      }),
    };
    authService = { enforceRateLimit: jest.fn() };
    controller = new ReportsController(
      reportsService as unknown as ReportsService,
      authService as unknown as import('../auth/auth.service').AuthService,
    );
  });

  describe('uploadReport', () => {
    it('delegates to service and returns success envelope', async () => {
      const req = makeReq({
        file: {
          buffer: pdfBuffer,
          originalname: 'lab.pdf',
          mimetype: 'application/pdf',
          size: pdfBuffer.length,
        },
      });

      const result = (await controller.uploadReport(req)) as {
        success: boolean;
        data: { reportId: string; profileId: string; fileName: string };
        correlationId: string;
      };
      expect(result.success).toBe(true);
      expect(result.data.reportId).toBeTruthy();
      expect(result.data.profileId).toBe('p1');
      expect(result.correlationId).toBe('test-cid');
      expect(reportsService.uploadReport).toHaveBeenCalledWith(
        'user-1',
        expect.objectContaining({
          buffer: pdfBuffer,
          originalname: 'lab.pdf',
          mimetype: 'application/pdf',
        }),
      );
      expect(authService.enforceRateLimit).toHaveBeenCalledWith(
        'report-upload',
        '127.0.0.1',
        10,
      );
    });

    it('throws BadRequestException when file is missing', async () => {
      const req = makeReq({ file: undefined });

      await expect(controller.uploadReport(req)).rejects.toMatchObject({
        response: {
          code: 'REPORT_FILE_REQUIRED',
          message: expect.stringContaining('Missing file'),
        },
      });
      expect(reportsService.uploadReport).not.toHaveBeenCalled();
    });
  });

  describe('getReportFile', () => {
    it('delegates to service and returns StreamableFile with correct headers', async () => {
      const res = {
        setHeader: jest.fn(),
      } as unknown as import('express').Response;

      const result = await controller.getReportFile(
        validReportId,
        makeReq(),
        res,
      );

      expect(result).toBeInstanceOf(StreamableFile);
      expect(reportsService.getReportFile).toHaveBeenCalledWith(
        'user-1',
        validReportId,
      );
      expect(res.setHeader).toHaveBeenCalledWith(
        'Content-Disposition',
        'inline; filename="x.pdf"',
      );
      expect(res.setHeader).toHaveBeenCalledWith(
        'Content-Type',
        'application/pdf',
      );
    });

    it('propagates 404 when report not found', async () => {
      reportsService.getReportFile.mockRejectedValueOnce(
        new ReportNotFoundException(),
      );
      const res = { setHeader: jest.fn() } as unknown as import('express').Response;

      await expect(
        controller.getReportFile(validReportId, makeReq(), res),
      ).rejects.toThrow(ReportNotFoundException);
    });
  });

  describe('getReport', () => {
    it('delegates to service and returns success envelope', async () => {
      const result = (await controller.getReport(validReportId, makeReq())) as {
        success: boolean;
        data: { id: string; status: string };
      };
      expect(result.success).toBe(true);
      expect(result.data.id).toBe(validReportId);
      expect(result.data.status).toBe('queued');
      expect(reportsService.getReport).toHaveBeenCalledWith(
        'user-1',
        validReportId,
      );
    });
  });

  describe('retryParse', () => {
    it('delegates to service and returns success envelope', async () => {
      const result = (await controller.retryParse(
        validReportId,
        makeReq(),
      )) as { success: boolean; data: { status: string } };
      expect(result.success).toBe(true);
      expect(result.data.status).toBe('parsed');
      expect(reportsService.retryParse).toHaveBeenCalledWith(
        'user-1',
        validReportId,
      );
    });

    it('propagates 404 when report not found', async () => {
      reportsService.retryParse.mockRejectedValueOnce(
        new ReportNotFoundException(),
      );
      await expect(
        controller.retryParse(validReportId, makeReq()),
      ).rejects.toThrow(ReportNotFoundException);
    });

    it('propagates 400 with REPORT_ALREADY_PARSED when report already parsed', async () => {
      reportsService.retryParse.mockRejectedValueOnce(
        new BadRequestException({
          code: REPORT_ALREADY_PARSED,
          message: 'Report is already parsed; nothing to retry or keep.',
        }),
      );
      await expect(
        controller.retryParse(validReportId, makeReq()),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('keepFile', () => {
    it('delegates to service and returns success envelope', async () => {
      const result = (await controller.keepFile(validReportId, makeReq())) as {
        success: boolean;
        data: { status: string };
      };
      expect(result.success).toBe(true);
      expect(result.data.status).toBe('unparsed');
      expect(reportsService.keepFile).toHaveBeenCalledWith(
        'user-1',
        validReportId,
      );
    });

    it('propagates 404 when report not found', async () => {
      reportsService.keepFile.mockRejectedValueOnce(
        new ReportNotFoundException(),
      );
      await expect(
        controller.keepFile(validReportId, makeReq()),
      ).rejects.toThrow(ReportNotFoundException);
    });

    it('propagates 400 with REPORT_ALREADY_PARSED when report already parsed', async () => {
      reportsService.keepFile.mockRejectedValueOnce(
        new BadRequestException({
          code: REPORT_ALREADY_PARSED,
          message: 'Report is already parsed; nothing to retry or keep.',
        }),
      );
      await expect(
        controller.keepFile(validReportId, makeReq()),
      ).rejects.toThrow(BadRequestException);
    });
  });
});
