import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import { AuthService } from '../auth/auth.service';
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
  ExportRequestNotFoundException,
} from './account.types';

@Injectable()
export class AccountService {
  private readonly logger = new Logger(AccountService.name);

  constructor(private readonly authService: AuthService) {}

  private readonly commPrefsStore = new Map<string, { productEmails: boolean }>();
  private readonly restrictionStore = new Map<
    string,
    { rationale: string; nextSteps: string; restrictedActions?: string[] }
  >();
  private readonly exportRequestStore = new Map<string, DataExportRequest>();
  private readonly closureRequestStore = new Map<string, ClosureRequest>();

  getRestrictionStatus(userId: string): RestrictionStatus {
    const entry = this.restrictionStore.get(userId);
    if (!entry || !entry.rationale || !entry.nextSteps) {
      return { isRestricted: false };
    }
    return {
      isRestricted: true,
      rationale: entry.rationale,
      nextSteps: entry.nextSteps,
      ...(entry.restrictedActions ? { restrictedActions: entry.restrictedActions } : {}),
    };
  }

  getProfile(userId: string): AccountProfile {
    const user = this.authService.findUserById(userId);
    if (!user) {
      throw new NotFoundException({
        code: 'ACCOUNT_NOT_FOUND',
        message: 'Account not found',
      });
    }
    return {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      createdAt: user.createdAt,
    };
  }

  getCommunicationPreferences(userId: string): CommunicationPreferences {
    const stored = this.commPrefsStore.get(userId);
    const productEnabled = stored?.productEmails ?? true;
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

  updateCommunicationPreferences(
    userId: string,
    dto: UpdateCommunicationPreferencesDto,
  ): CommunicationPreferences {
    const current = this.commPrefsStore.get(userId) ?? { productEmails: true };
    if (dto.productEmails !== undefined) {
      current.productEmails = dto.productEmails;
    }
    this.commPrefsStore.set(userId, current);
    return this.getCommunicationPreferences(userId);
  }

  updateProfile(userId: string, dto: UpdateAccountProfileDto): AccountProfile {
    const user = this.authService.findUserById(userId);
    if (!user) {
      throw new NotFoundException({
        code: 'ACCOUNT_NOT_FOUND',
        message: 'Account not found',
      });
    }
    if (dto.displayName !== undefined) {
      this.authService.updateUser(userId, { displayName: dto.displayName });
    }
    return {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      createdAt: user.createdAt,
    };
  }

  createDataExportRequest(
    userId: string,
    correlationId: string,
  ): DataExportRequest {
    const requestId = randomUUID();
    const createdAt = new Date().toISOString();
    const request: DataExportRequest = {
      requestId,
      userId,
      status: 'pending',
      createdAt,
    };
    this.exportRequestStore.set(requestId, request);
    this.logger.log(
      JSON.stringify({
        action: 'DATA_EXPORT_REQUESTED',
        userId,
        requestId,
        correlationId,
      }),
    );
    return { ...request };
  }

  getDataExportRequest(
    userId: string,
    requestId: string,
  ): DataExportRequest | null {
    const request = this.exportRequestStore.get(requestId);
    if (!request || request.userId !== userId) {
      return null;
    }
    if (request.status === 'pending') {
      const user = this.authService.findUserById(userId);
      if (!user) {
        request.status = 'failed';
        request.failureReason = 'USER_NOT_FOUND';
        this.exportRequestStore.set(requestId, request);
        this.logger.log(
          JSON.stringify({
            action: 'DATA_EXPORT_FAILED',
            userId,
            requestId,
            reason: 'USER_NOT_FOUND',
          }),
        );
      } else {
        const exportPayload = {
          profile: { id: user.id, email: user.email, displayName: user.displayName, createdAt: user.createdAt },
          profiles: [],
          consentRecords: [],
        };
        const downloadUrl = `data:application/json;base64,${Buffer.from(JSON.stringify(exportPayload)).toString('base64')}`;
        request.status = 'completed';
        request.completedAt = new Date().toISOString();
        request.downloadUrl = downloadUrl;
        this.exportRequestStore.set(requestId, request);
        this.logger.log(
          JSON.stringify({
            action: 'DATA_EXPORT_COMPLETED',
            userId,
            requestId,
          }),
        );
      }
    }
    return { ...request };
  }

  createClosureRequest(
    userId: string,
    dto: CreateClosureRequestDto,
    correlationId: string,
  ): ClosureRequest {
    if (!dto.confirmClosure) {
      throw new ClosureConfirmationRequiredException();
    }
    const requestId = randomUUID();
    const createdAt = new Date().toISOString();
    const message =
      'Your account is scheduled for closure. You will lose access to all data.';
    const request: ClosureRequest = {
      requestId,
      userId,
      status: 'pending',
      createdAt,
      message,
    };
    this.closureRequestStore.set(userId, request);
    this.authService.revokeAllSessionsForUser(userId);
    this.logger.log(
      JSON.stringify({
        action: 'CLOSURE_REQUESTED',
        userId,
        requestId,
        correlationId,
      }),
    );
    request.status = 'completed';
    this.closureRequestStore.set(userId, request);
    this.logger.log(
      JSON.stringify({
        action: 'CLOSURE_COMPLETED',
        userId,
        requestId,
        correlationId,
      }),
    );
    return { ...request };
  }

  getClosureRequest(userId: string): ClosureRequest | null {
    const request = this.closureRequestStore.get(userId);
    return request ? { ...request } : null;
  }
}
