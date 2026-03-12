import { Inject, Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { isUUID } from 'class-validator';
import { Repository } from 'typeorm';
import { AccountPreferenceEntity } from '../../database/entities/account-preference.entity';
import { RestrictionEntity } from '../../database/entities/restriction.entity';
import { DataExportRequestEntity } from '../../database/entities/data-export-request.entity';
import { ClosureRequestEntity } from '../../database/entities/closure-request.entity';
import { ProfileEntity } from '../../database/entities/profile.entity';
import { ConsentRecordEntity } from '../../database/entities/consent-record.entity';
import { UserEntity } from '../../database/entities/user.entity';
import { AuthService } from '../auth/auth.service';
import type { FileStorageService } from '../../common/storage/file-storage.interface';
import { FILE_STORAGE } from '../../common/storage/storage.module';
import type {
  UpdateAccountProfileDto,
  UpdateCommunicationPreferencesDto,
  CreateClosureRequestDto,
} from './account.dto';
import type {
  AccountProfile,
  CommunicationPreferences,
  DataExportRequest,
  ClosureRequest,
  RestrictionStatus,
} from './account.types';
import {
  COMM_PREF_CATEGORY,
  ClosureConfirmationRequiredException,
} from './account.types';

@Injectable()
export class AccountService {
  private readonly logger = new Logger(AccountService.name);

  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(AccountPreferenceEntity)
    private readonly prefRepo: Repository<AccountPreferenceEntity>,
    @InjectRepository(RestrictionEntity)
    private readonly restrictionRepo: Repository<RestrictionEntity>,
    @InjectRepository(DataExportRequestEntity)
    private readonly exportRepo: Repository<DataExportRequestEntity>,
    @InjectRepository(ClosureRequestEntity)
    private readonly closureRepo: Repository<ClosureRequestEntity>,
    @InjectRepository(ProfileEntity)
    private readonly profileRepo: Repository<ProfileEntity>,
    @InjectRepository(ConsentRecordEntity)
    private readonly consentRepo: Repository<ConsentRecordEntity>,
    private readonly authService: AuthService,
    @Inject(FILE_STORAGE) private readonly fileStorage: FileStorageService,
  ) {}

  async getRestrictionStatus(userId: string): Promise<RestrictionStatus> {
    const entry = await this.restrictionRepo.findOne({ where: { userId } });
    if (!entry || !entry.isRestricted) return { isRestricted: false };
    return {
      isRestricted: true,
      rationale: entry.rationale ?? undefined,
      nextSteps: entry.nextSteps ?? undefined,
    };
  }

  async getProfile(userId: string): Promise<AccountProfile> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException({
        code: 'ACCOUNT_NOT_FOUND',
        message: 'Account not found',
      });
    }
    let avatarUrl: string | null = null;
    if (user.avatarUrl) {
      avatarUrl = await this.fileStorage.getSignedUrl(user.avatarUrl, 300);
    }
    return {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      avatarUrl,
      createdAt: user.createdAt,
    };
  }

  async getCommunicationPreferences(
    userId: string,
  ): Promise<CommunicationPreferences> {
    const pref = await this.prefRepo.findOne({ where: { userId } });
    const productEnabled = pref?.productEmailsEnabled ?? true;
    return {
      preferences: [
        {
          category: COMM_PREF_CATEGORY.SECURITY,
          enabled: true,
          mandatory: true,
        },
        {
          category: COMM_PREF_CATEGORY.COMPLIANCE,
          enabled: true,
          mandatory: true,
        },
        {
          category: COMM_PREF_CATEGORY.PRODUCT,
          enabled: productEnabled,
          mandatory: false,
        },
      ],
    };
  }

  async updateCommunicationPreferences(
    userId: string,
    dto: UpdateCommunicationPreferencesDto,
  ): Promise<CommunicationPreferences> {
    let pref = await this.prefRepo.findOne({ where: { userId } });
    if (!pref) {
      pref = this.prefRepo.create({ userId, productEmailsEnabled: true });
    }
    if (dto.productEmails !== undefined)
      pref.productEmailsEnabled = dto.productEmails;
    await this.prefRepo.save(pref);
    return this.getCommunicationPreferences(userId);
  }

  async updateProfile(
    userId: string,
    dto: UpdateAccountProfileDto,
  ): Promise<AccountProfile> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException({
        code: 'ACCOUNT_NOT_FOUND',
        message: 'Account not found',
      });
    }
    if (dto.displayName !== undefined) user.displayName = dto.displayName;
    if (dto.avatarUrl !== undefined) {
      if (user.avatarUrl) {
        await this.fileStorage.delete(user.avatarUrl);
      }
      user.avatarUrl = dto.avatarUrl;
    }
    await this.userRepo.save(user);
    return this.getProfile(userId);
  }

  async updateAvatar(
    userId: string,
    avatarStorageKey: string,
  ): Promise<AccountProfile> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException({
        code: 'ACCOUNT_NOT_FOUND',
        message: 'Account not found',
      });
    }
    if (user.avatarUrl) {
      await this.fileStorage.delete(user.avatarUrl);
    }
    user.avatarUrl = avatarStorageKey;
    await this.userRepo.save(user);
    return this.getProfile(userId);
  }

  async createDataExportRequest(
    userId: string,
    correlationId: string,
  ): Promise<DataExportRequest> {
    const entity = this.exportRepo.create({
      userId,
      status: 'pending',
      completedAt: null,
      downloadUrl: null,
      failureReason: null,
    });
    const saved = await this.exportRepo.save(entity);

    this.logger.log(
      JSON.stringify({
        action: 'DATA_EXPORT_REQUESTED',
        requestId: saved.id,
        correlationId,
      }),
    );
    return this.toExportDto(saved);
  }

  async getDataExportRequest(
    userId: string,
    requestId: string,
  ): Promise<DataExportRequest | null> {
    if (!isUUID(requestId)) return null;
    const entity = await this.exportRepo.findOne({
      where: { id: requestId, userId },
    });
    if (!entity) return null;

    if (entity.status === 'pending') {
      const user = await this.userRepo.findOne({ where: { id: userId } });
      const profiles = await this.profileRepo.find({
        where: { userId },
        order: { createdAt: 'ASC' },
      });
      const consentRecords = await this.consentRepo.find({
        where: { userId },
        order: { acceptedAt: 'ASC' },
      });
      const exportPayload = user
        ? {
            profile: {
              id: user.id,
              email: user.email,
              displayName: user.displayName,
              createdAt: user.createdAt,
            },
            profiles: profiles.map((profile) => ({
              id: profile.id,
              name: profile.name,
              dateOfBirth: profile.dateOfBirth,
              relation: profile.relation,
              isActive: profile.isActive,
              createdAt: profile.createdAt,
            })),
            consentRecords: consentRecords.map((record) => ({
              id: record.id,
              policyType: record.policyType,
              policyVersion: record.policyVersion,
              acceptedAt: record.acceptedAt,
            })),
          }
        : null;

      entity.status = exportPayload ? 'completed' : 'failed';
      entity.completedAt = exportPayload ? new Date() : null;
      entity.downloadUrl = exportPayload
        ? `data:application/json;base64,${Buffer.from(JSON.stringify(exportPayload)).toString('base64')}`
        : null;
      entity.failureReason = exportPayload ? null : 'USER_NOT_FOUND';
      await this.exportRepo.save(entity);
    }
    return this.toExportDto(entity);
  }

  async createClosureRequest(
    userId: string,
    dto: CreateClosureRequestDto,
    correlationId: string,
  ): Promise<ClosureRequest> {
    if (!dto.confirmClosure) throw new ClosureConfirmationRequiredException();

    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (user?.avatarUrl) {
      await this.fileStorage.delete(user.avatarUrl);
    }

    const entity = this.closureRepo.create({
      userId,
      status: 'completed',
      message:
        'Your account is scheduled for closure. You will lose access to all data.',
    });
    const saved = await this.closureRepo.save(entity);
    if (user) {
      user.avatarUrl = null;
      await this.userRepo.save(user);
    }
    await this.authService.revokeAllSessionsForUser(userId);

    this.logger.log(
      JSON.stringify({
        action: 'CLOSURE_COMPLETED',
        requestId: saved.id,
        correlationId,
      }),
    );
    return this.toClosureDto(saved);
  }

  async getClosureRequest(userId: string): Promise<ClosureRequest | null> {
    const entity = await this.closureRepo.findOne({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
    if (!entity) return null;
    return this.toClosureDto(entity);
  }

  private toExportDto(e: DataExportRequestEntity): DataExportRequest {
    return {
      requestId: e.id,
      userId: e.userId,
      status: e.status,
      createdAt: e.createdAt.toISOString(),
      completedAt: e.completedAt?.toISOString(),
      downloadUrl: e.downloadUrl ?? undefined,
      failureReason: e.failureReason ?? undefined,
    };
  }

  private toClosureDto(e: ClosureRequestEntity): ClosureRequest {
    return {
      requestId: e.id,
      userId: e.userId,
      status: e.status as 'pending' | 'completed',
      createdAt: e.createdAt.toISOString(),
      message: e.message ?? '',
    };
  }
}
