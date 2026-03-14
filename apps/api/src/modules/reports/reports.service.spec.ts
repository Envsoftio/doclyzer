import { ConfigService } from '@nestjs/config';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Test, TestingModule } from '@nestjs/testing';
import { ReportEntity } from '../../database/entities/report.entity';
import { ReportLabValueEntity } from '../../database/entities/report-lab-value.entity';
import { ReportsService } from './reports.service';
import { ProfilesService } from '../profiles/profiles.service';
import { FILE_STORAGE } from '../../common/storage/storage.module';
import type { FileStorageService } from '../../common/storage/file-storage.interface';
import { ProfileNotFoundException } from '../profiles/exceptions/profile-not-found.exception';
import { ReportUploadException } from './exceptions/report-upload.exception';
import { ReportDuplicateDetectedException } from './exceptions/report-duplicate-detected.exception';
import { ReportFileUnavailableException } from './exceptions/report-file-unavailable.exception';
import { ReportNotFoundException } from './exceptions/report-not-found.exception';
import {
  REPORT_ALREADY_PARSED,
  REPORT_NO_ACTIVE_PROFILE,
} from './reports.types';

const pdfBuffer = Buffer.from('%PDF-1.4 fake pdf content');

function makeFileStorage(): jest.Mocked<FileStorageService> {
  return {
    upload: jest.fn().mockResolvedValue('reports/u1/p1/r1.pdf'),
    delete: jest.fn().mockResolvedValue(undefined),
    get: jest.fn().mockResolvedValue(Buffer.from('%PDF-1.4')),
    getSignedUrl: jest.fn().mockResolvedValue('https://example.com/signed'),
  };
}

function makeProfilesService(): jest.Mocked<
  Pick<ProfilesService, 'getActiveProfileId' | 'getProfile'>
> {
  return {
    getActiveProfileId: jest.fn().mockResolvedValue('profile-1'),
    getProfile: jest
      .fn()
      .mockResolvedValue({ id: 'profile-1', userId: 'user-1' }),
  };
}

function makeReportRepo() {
  const save = jest.fn().mockImplementation(async (e: ReportEntity) => e);
  const create = jest
    .fn()
    .mockImplementation((data: Partial<ReportEntity>) => ({
      ...data,
      id: data.id ?? 'report-1',
    }));
  const findOne = jest.fn();
  const find = jest.fn().mockResolvedValue([]);
  return { save, create, findOne, find };
}

function makeReportLabValueRepo() {
  const find = jest.fn().mockResolvedValue([]);
  return { find };
}

describe('ReportsService', () => {
  let service: ReportsService;
  let fileStorage: ReturnType<typeof makeFileStorage>;
  let profilesService: ReturnType<typeof makeProfilesService>;
  let reportRepo: ReturnType<typeof makeReportRepo>;
  let reportLabValueRepo: ReturnType<typeof makeReportLabValueRepo>;

  beforeEach(async () => {
    fileStorage = makeFileStorage();
    profilesService = makeProfilesService();
    reportRepo = makeReportRepo();
    reportLabValueRepo = makeReportLabValueRepo();
    reportRepo.findOne.mockResolvedValue(null);

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ReportsService,
        {
          provide: getRepositoryToken(ReportEntity),
          useValue: {
            create: reportRepo.create,
            save: reportRepo.save,
            findOne: reportRepo.findOne,
            find: reportRepo.find,
          },
        },
        {
          provide: getRepositoryToken(ReportLabValueEntity),
          useValue: { find: reportLabValueRepo.find },
        },
        { provide: ProfilesService, useValue: profilesService },
        { provide: FILE_STORAGE, useValue: fileStorage },
        {
          provide: ConfigService,
          useValue: { get: jest.fn().mockReturnValue(false) },
        },
      ],
    }).compile();

    service = module.get(ReportsService);
  });

  it('uploads report successfully when user has active profile', async () => {
    const result = await service.uploadReport('user-1', {
      buffer: pdfBuffer,
      originalname: 'lab-report.pdf',
      mimetype: 'application/pdf',
      size: pdfBuffer.length,
    });

    expect(result.reportId).toBeTruthy();
    expect(result.profileId).toBe('profile-1');
    expect(result.fileName).toBe('lab-report.pdf');
    expect(result.contentType).toBe('application/pdf');
    expect(result.sizeBytes).toBe(pdfBuffer.length);
    expect(result.status).toBe('parsed');

    expect(reportRepo.findOne).toHaveBeenCalledWith({
      where: { profileId: 'profile-1', contentHash: expect.any(String) },
    });
    expect(fileStorage.upload).toHaveBeenCalledWith(
      expect.stringMatching(/^reports\/user-1\/profile-1\/[a-f0-9-]+\.pdf$/),
      pdfBuffer,
      'application/pdf',
    );
    expect(reportRepo.save).toHaveBeenCalled();
    expect(reportRepo.create).toHaveBeenCalledWith(
      expect.objectContaining({ contentHash: expect.any(String) }),
    );
  });

  it('uploads with status content_not_recognized when stub indicates not a health report', async () => {
    const configGet = jest.fn().mockImplementation((key: string) => {
      if (key === 'reports.parseStubFail') return true;
      if (key === 'reports.parseStubContentNotRecognized') return true;
      return false;
    });
    const module = await Test.createTestingModule({
      providers: [
        ReportsService,
        {
          provide: getRepositoryToken(ReportEntity),
          useValue: {
            create: reportRepo.create,
            save: reportRepo.save,
            findOne: reportRepo.findOne,
            find: reportRepo.find,
          },
        },
        {
          provide: getRepositoryToken(ReportLabValueEntity),
          useValue: { find: reportLabValueRepo.find },
        },
        { provide: ProfilesService, useValue: profilesService },
        { provide: FILE_STORAGE, useValue: fileStorage },
        { provide: ConfigService, useValue: { get: configGet } },
      ],
    }).compile();
    const svc = module.get(ReportsService);

    const result = await svc.uploadReport('user-1', {
      buffer: pdfBuffer,
      originalname: 'brochure.pdf',
      mimetype: 'application/pdf',
      size: pdfBuffer.length,
    });
    expect(result.status).toBe('content_not_recognized');
    expect(reportRepo.save).toHaveBeenCalledWith(
      expect.objectContaining({ status: 'content_not_recognized' }),
    );
  });

  it('returns duplicate info when same profile has report with same content hash', async () => {
    const existingEntity = {
      id: 'existing-report-id',
      profileId: 'profile-1',
      originalFileName: 'same.pdf',
      createdAt: new Date('2026-01-15T12:00:00.000Z'),
    } as ReportEntity;
    reportRepo.findOne.mockResolvedValue(existingEntity);

    await expect(
      service.uploadReport('user-1', {
        buffer: pdfBuffer,
        originalname: 'same.pdf',
        mimetype: 'application/pdf',
        size: pdfBuffer.length,
      }),
    ).rejects.toThrow(ReportDuplicateDetectedException);

    expect(reportRepo.findOne).toHaveBeenCalledWith({
      where: { profileId: 'profile-1', contentHash: expect.any(String) },
    });
    expect(fileStorage.upload).not.toHaveBeenCalled();
    expect(reportRepo.save).not.toHaveBeenCalled();
  });

  it('creates report when duplicateAction is upload_anyway despite same hash', async () => {
    const existingEntity = {
      id: 'existing-report-id',
      profileId: 'profile-1',
      originalFileName: 'same.pdf',
      createdAt: new Date('2026-01-15T12:00:00.000Z'),
    } as ReportEntity;
    reportRepo.findOne.mockResolvedValue(existingEntity);

    const result = await service.uploadReport(
      'user-1',
      {
        buffer: pdfBuffer,
        originalname: 'same.pdf',
        mimetype: 'application/pdf',
        size: pdfBuffer.length,
      },
      { duplicateAction: 'upload_anyway' },
    );

    expect(result.reportId).toBeTruthy();
    expect(result.profileId).toBe('profile-1');
    expect(fileStorage.upload).toHaveBeenCalled();
    expect(reportRepo.save).toHaveBeenCalled();
    expect(reportRepo.create).toHaveBeenCalledWith(
      expect.objectContaining({ contentHash: expect.any(String) }),
    );
  });

  it('rejects upload when user has no active profile', async () => {
    profilesService.getActiveProfileId.mockResolvedValue(null);

    const err = await service
      .uploadReport('user-1', {
        buffer: pdfBuffer,
        originalname: 'x.pdf',
        mimetype: 'application/pdf',
        size: pdfBuffer.length,
      })
      .catch((e) => e);
    expect(err).toBeInstanceOf(ReportUploadException);
    expect(err.getResponse()).toMatchObject({ code: REPORT_NO_ACTIVE_PROFILE });

    expect(fileStorage.upload).not.toHaveBeenCalled();
    expect(reportRepo.save).not.toHaveBeenCalled();
  });

  it('rejects empty file', async () => {
    await expect(
      service.uploadReport('user-1', {
        buffer: Buffer.alloc(0),
        originalname: 'x.pdf',
        mimetype: 'application/pdf',
        size: 0,
      }),
    ).rejects.toThrow(ReportUploadException);

    expect(fileStorage.upload).not.toHaveBeenCalled();
    expect(reportRepo.save).not.toHaveBeenCalled();
  });

  it('rejects file exceeding max size', async () => {
    const huge = Buffer.alloc(11 * 1024 * 1024);

    await expect(
      service.uploadReport('user-1', {
        buffer: huge,
        originalname: 'x.pdf',
        mimetype: 'application/pdf',
        size: huge.length,
      }),
    ).rejects.toThrow(ReportUploadException);

    expect(fileStorage.upload).not.toHaveBeenCalled();
    expect(reportRepo.save).not.toHaveBeenCalled();
  });

  it('rejects non-PDF content type', async () => {
    await expect(
      service.uploadReport('user-1', {
        buffer: pdfBuffer,
        originalname: 'x.jpg',
        mimetype: 'image/jpeg',
        size: pdfBuffer.length,
      }),
    ).rejects.toThrow(ReportUploadException);

    expect(fileStorage.upload).not.toHaveBeenCalled();
    expect(reportRepo.save).not.toHaveBeenCalled();
  });

  it('does not insert DB row when storage upload fails', async () => {
    fileStorage.upload.mockRejectedValue(new Error('Storage failed'));

    await expect(
      service.uploadReport('user-1', {
        buffer: pdfBuffer,
        originalname: 'x.pdf',
        mimetype: 'application/pdf',
        size: pdfBuffer.length,
      }),
    ).rejects.toThrow();

    expect(reportRepo.save).not.toHaveBeenCalled();
  });

  it('deletes storage file when save fails after upload', async () => {
    reportRepo.save.mockRejectedValue(new Error('DB error'));

    await expect(
      service.uploadReport('user-1', {
        buffer: pdfBuffer,
        originalname: 'x.pdf',
        mimetype: 'application/pdf',
        size: pdfBuffer.length,
      }),
    ).rejects.toThrow('DB error');

    expect(fileStorage.upload).toHaveBeenCalled();
    expect(fileStorage.delete).toHaveBeenCalledWith(
      expect.stringMatching(/^reports\/user-1\/profile-1\/[a-f0-9-]+\.pdf$/),
    );
  });

  it('normalizes empty originalFileName to report.pdf', async () => {
    const result = await service.uploadReport('user-1', {
      buffer: pdfBuffer,
      originalname: '   ',
      mimetype: 'application/pdf',
      size: pdfBuffer.length,
    });
    expect(result.fileName).toBe('report.pdf');
    expect(reportRepo.create).toHaveBeenCalledWith(
      expect.objectContaining({ originalFileName: 'report.pdf' }),
    );
  });

  describe('getReport', () => {
    const validReportId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';

    it('returns report for owner', async () => {
      const entity = {
        id: validReportId,
        userId: 'u1',
        profileId: 'p1',
        originalFileName: 'x.pdf',
        contentType: 'application/pdf',
        sizeBytes: 100,
        status: 'queued',
        createdAt: new Date('2026-01-01'),
      } as ReportEntity;
      reportRepo.findOne.mockResolvedValue(entity);

      const result = await service.getReport('u1', validReportId);
      expect(result.id).toBe(validReportId);
      expect(result.profileId).toBe('p1');
      expect(result.status).toBe('queued');
      expect(result.extractedLabValues).toEqual([]);
      expect(reportLabValueRepo.find).toHaveBeenCalledWith({
        where: { reportId: validReportId },
        order: { sortOrder: 'ASC', parameterName: 'ASC' },
      });
    });

    it('throws ReportNotFoundException when report not found', async () => {
      reportRepo.findOne.mockResolvedValue(null);

      await expect(
        service.getReport('u1', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'),
      ).rejects.toThrow(ReportNotFoundException);
    });

    it('throws ReportNotFoundException for invalid UUID format', async () => {
      await expect(service.getReport('u1', 'not-a-uuid')).rejects.toThrow(
        ReportNotFoundException,
      );
      expect(reportRepo.findOne).not.toHaveBeenCalled();
    });

    it('throws when report belongs to another user', async () => {
      reportRepo.findOne.mockResolvedValue(null);

      await expect(
        service.getReport('u1', 'b2c3d4e5-f6a7-8901-bcde-f12345678901'),
      ).rejects.toThrow(ReportNotFoundException);
    });

    it('returns extractedLabValues when present', async () => {
      const entity = {
        id: validReportId,
        userId: 'u1',
        profileId: 'p1',
        originalFileName: 'x.pdf',
        contentType: 'application/pdf',
        sizeBytes: 100,
        status: 'parsed',
        createdAt: new Date('2026-01-01'),
      } as ReportEntity;
      reportRepo.findOne.mockResolvedValue(entity);
      const labEntities = [
        {
          parameterName: 'HbA1c',
          value: '5.8',
          unit: '%',
          sampleDate: '2026-01-01',
          sortOrder: 0,
        },
        {
          parameterName: 'Glucose',
          value: '98',
          unit: 'mg/dL',
          sampleDate: null,
          sortOrder: 1,
        },
      ] as ReportLabValueEntity[];
      reportLabValueRepo.find.mockResolvedValue(labEntities);

      const result = await service.getReport('u1', validReportId);
      expect(result.extractedLabValues).toHaveLength(2);
      expect(result.extractedLabValues[0]).toEqual({
        parameterName: 'HbA1c',
        value: '5.8',
        unit: '%',
        sampleDate: '2026-01-01',
      });
      expect(result.extractedLabValues[1]).toEqual({
        parameterName: 'Glucose',
        value: '98',
        unit: 'mg/dL',
      });
    });
  });

  describe('retryParse', () => {
    const validReportId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';

    it('returns updated report for owner when parse succeeds', async () => {
      const entity = {
        id: validReportId,
        userId: 'u1',
        profileId: 'p1',
        originalFileName: 'x.pdf',
        contentType: 'application/pdf',
        sizeBytes: 100,
        status: 'unparsed',
        originalFileStorageKey: 'reports/u1/p1/r1.pdf',
        createdAt: new Date('2026-01-01'),
      } as ReportEntity;
      reportRepo.findOne.mockResolvedValue(entity);

      const result = await service.retryParse('u1', validReportId);
      expect(result.id).toBe(validReportId);
      expect(result.status).toBe('parsed');
      expect(fileStorage.get).toHaveBeenCalledWith('reports/u1/p1/r1.pdf');
      expect(reportRepo.save).toHaveBeenCalled();
    });

    it('throws ReportNotFoundException when report not found', async () => {
      reportRepo.findOne.mockResolvedValue(null);

      await expect(service.retryParse('u1', validReportId)).rejects.toThrow(
        ReportNotFoundException,
      );
      expect(fileStorage.get).not.toHaveBeenCalled();
    });

    it('throws BadRequestException with REPORT_ALREADY_PARSED when status is parsed', async () => {
      const entity = {
        id: validReportId,
        userId: 'u1',
        profileId: 'p1',
        status: 'parsed',
        originalFileStorageKey: 'reports/u1/p1/r1.pdf',
      } as ReportEntity;
      reportRepo.findOne.mockResolvedValue(entity);

      await expect(
        service.retryParse('u1', validReportId),
      ).rejects.toMatchObject({
        response: { code: REPORT_ALREADY_PARSED },
      });
      expect(fileStorage.get).not.toHaveBeenCalled();
    });

    it('keeps file on parse failure (stub returns unparsed)', async () => {
      const configGet = jest.fn().mockImplementation((key: string) => {
        if (key === 'reports.parseStubFail') return true;
        if (key === 'reports.parseStubRetrySucceeds') return false;
        if (key === 'reports.parseStubContentNotRecognized') return false;
        return false;
      });
      const module = await Test.createTestingModule({
        providers: [
          ReportsService,
          {
            provide: getRepositoryToken(ReportEntity),
            useValue: {
              create: reportRepo.create,
              save: reportRepo.save,
              findOne: reportRepo.findOne,
              find: reportRepo.find,
            },
          },
          {
            provide: getRepositoryToken(ReportLabValueEntity),
            useValue: { find: reportLabValueRepo.find },
          },
          { provide: ProfilesService, useValue: profilesService },
          { provide: FILE_STORAGE, useValue: fileStorage },
          { provide: ConfigService, useValue: { get: configGet } },
        ],
      }).compile();
      const svc = module.get(ReportsService);

      const entity = {
        id: validReportId,
        userId: 'u1',
        profileId: 'p1',
        originalFileName: 'x.pdf',
        contentType: 'application/pdf',
        sizeBytes: 100,
        status: 'failed_terminal',
        originalFileStorageKey: 'reports/u1/p1/r1.pdf',
        createdAt: new Date('2026-01-01'),
      } as ReportEntity;
      reportRepo.findOne.mockResolvedValue(entity);

      const result = await svc.retryParse('u1', validReportId);
      expect(result.status).toBe('unparsed');
      expect(fileStorage.delete).not.toHaveBeenCalled();
    });
  });

  describe('keepFile', () => {
    const validReportId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';

    it('sets status to unparsed for owner', async () => {
      const entity = {
        id: validReportId,
        userId: 'u1',
        profileId: 'p1',
        originalFileName: 'x.pdf',
        contentType: 'application/pdf',
        sizeBytes: 100,
        status: 'failed_terminal',
        createdAt: new Date('2026-01-01'),
      } as ReportEntity;
      reportRepo.findOne.mockResolvedValue(entity);

      const result = await service.keepFile('u1', validReportId);
      expect(result.status).toBe('unparsed');
      expect(reportRepo.save).toHaveBeenCalledWith(
        expect.objectContaining({ status: 'unparsed' }),
      );
    });

    it('is idempotent when status already unparsed', async () => {
      const entity = {
        id: validReportId,
        userId: 'u1',
        profileId: 'p1',
        status: 'unparsed',
        originalFileName: 'x.pdf',
        contentType: 'application/pdf',
        sizeBytes: 100,
        createdAt: new Date('2026-01-01'),
      } as ReportEntity;
      reportRepo.findOne.mockResolvedValue(entity);

      const result = await service.keepFile('u1', validReportId);
      expect(result.status).toBe('unparsed');
      expect(reportRepo.save).toHaveBeenCalled();
    });

    it('throws BadRequestException when status is parsed', async () => {
      const entity = {
        id: validReportId,
        userId: 'u1',
        profileId: 'p1',
        status: 'parsed',
      } as ReportEntity;
      reportRepo.findOne.mockResolvedValue(entity);

      await expect(service.keepFile('u1', validReportId)).rejects.toMatchObject(
        {
          response: { code: REPORT_ALREADY_PARSED },
        },
      );
    });

    it('sets status to unparsed when current status is content_not_recognized', async () => {
      const entity = {
        id: validReportId,
        userId: 'u1',
        profileId: 'p1',
        originalFileName: 'x.pdf',
        contentType: 'application/pdf',
        sizeBytes: 100,
        status: 'content_not_recognized',
        createdAt: new Date('2026-01-01'),
      } as ReportEntity;
      reportRepo.findOne.mockResolvedValue(entity);

      const result = await service.keepFile('u1', validReportId);
      expect(result.status).toBe('unparsed');
      expect(reportRepo.save).toHaveBeenCalledWith(
        expect.objectContaining({ status: 'unparsed' }),
      );
    });
  });

  describe('getReportFile', () => {
    const validReportId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
    const fileBuffer = Buffer.from('%PDF-1.4 content');

    it('returns buffer and metadata for owner', async () => {
      const entity = {
        id: validReportId,
        userId: 'u1',
        profileId: 'p1',
        originalFileName: 'lab.pdf',
        contentType: 'application/pdf',
        sizeBytes: 100,
        status: 'parsed',
        originalFileStorageKey: 'reports/u1/p1/r1.pdf',
        createdAt: new Date('2026-01-01'),
      } as ReportEntity;
      reportRepo.findOne.mockResolvedValue(entity);
      fileStorage.get.mockResolvedValue(fileBuffer);

      const result = await service.getReportFile('u1', validReportId);
      expect(result.buffer).toEqual(fileBuffer);
      expect(result.contentType).toBe('application/pdf');
      expect(result.originalFileName).toBe('lab.pdf');
      expect(fileStorage.get).toHaveBeenCalledWith('reports/u1/p1/r1.pdf');
    });

    it('throws ReportNotFoundException when report not found', async () => {
      reportRepo.findOne.mockResolvedValue(null);

      await expect(service.getReportFile('u1', validReportId)).rejects.toThrow(
        ReportNotFoundException,
      );
      expect(fileStorage.get).not.toHaveBeenCalled();
    });

    it('throws ReportFileUnavailableException when storage get fails', async () => {
      const entity = {
        id: validReportId,
        userId: 'u1',
        profileId: 'p1',
        originalFileName: 'x.pdf',
        contentType: 'application/pdf',
        sizeBytes: 100,
        status: 'parsed',
        originalFileStorageKey: 'reports/u1/p1/missing.pdf',
        createdAt: new Date('2026-01-01'),
      } as ReportEntity;
      reportRepo.findOne.mockResolvedValue(entity);
      fileStorage.get.mockRejectedValue(new Error('Key not found'));

      await expect(service.getReportFile('u1', validReportId)).rejects.toThrow(
        ReportFileUnavailableException,
      );
    });
  });

  describe('listReportsByProfile', () => {
    it('returns only reports for the given profile ordered by createdAt DESC', async () => {
      const entities = [
        {
          id: 'r2',
          profileId: 'profile-1',
          originalFileName: 'b.pdf',
          contentType: 'application/pdf',
          sizeBytes: 200,
          status: 'parsed',
          createdAt: new Date('2026-01-02T00:00:00.000Z'),
        } as ReportEntity,
        {
          id: 'r1',
          profileId: 'profile-1',
          originalFileName: 'a.pdf',
          contentType: 'application/pdf',
          sizeBytes: 100,
          status: 'queued',
          createdAt: new Date('2026-01-01T00:00:00.000Z'),
        } as ReportEntity,
      ];
      reportRepo.find.mockResolvedValue(entities);

      const result = await service.listReportsByProfile('user-1', 'profile-1');

      expect(profilesService.getProfile).toHaveBeenCalledWith(
        'user-1',
        'profile-1',
      );
      expect(reportRepo.find).toHaveBeenCalledWith({
        where: { profileId: 'profile-1' },
        order: { createdAt: 'DESC' },
      });
      expect(result).toHaveLength(2);
      expect(result[0].id).toBe('r2');
      expect(result[0].originalFileName).toBe('b.pdf');
      expect(result[1].id).toBe('r1');
      expect(result[1].originalFileName).toBe('a.pdf');
    });

    it('throws when user does not own profile', async () => {
      (profilesService.getProfile as jest.Mock).mockRejectedValueOnce(
        new ProfileNotFoundException(),
      );

      await expect(
        service.listReportsByProfile('user-1', 'other-profile-id'),
      ).rejects.toThrow(ProfileNotFoundException);

      expect(reportRepo.find).not.toHaveBeenCalled();
    });
  });

  describe('listReports', () => {
    it('uses profileId when provided', async () => {
      reportRepo.find.mockResolvedValue([]);

      await service.listReports('user-1', 'profile-99');

      expect(profilesService.getProfile).toHaveBeenCalledWith(
        'user-1',
        'profile-99',
      );
      expect(profilesService.getActiveProfileId).not.toHaveBeenCalled();
      expect(reportRepo.find).toHaveBeenCalledWith({
        where: { profileId: 'profile-99' },
        order: { createdAt: 'DESC' },
      });
    });

    it('uses active profile when profileId not provided', async () => {
      profilesService.getActiveProfileId.mockResolvedValue('active-profile-id');
      reportRepo.find.mockResolvedValue([]);

      await service.listReports('user-1');

      expect(profilesService.getActiveProfileId).toHaveBeenCalledWith('user-1');
      expect(profilesService.getProfile).toHaveBeenCalledWith(
        'user-1',
        'active-profile-id',
      );
      expect(reportRepo.find).toHaveBeenCalledWith({
        where: { profileId: 'active-profile-id' },
        order: { createdAt: 'DESC' },
      });
    });

    it('throws REPORT_NO_ACTIVE_PROFILE when no profileId and no active profile', async () => {
      profilesService.getActiveProfileId.mockResolvedValue(null);

      await expect(service.listReports('user-1')).rejects.toThrow(
        ReportUploadException,
      );
      await expect(service.listReports('user-1')).rejects.toMatchObject({
        message: expect.stringContaining('No active profile'),
      });

      expect(profilesService.getProfile).not.toHaveBeenCalled();
      expect(reportRepo.find).not.toHaveBeenCalled();
    });
  });
});
