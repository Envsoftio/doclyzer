import { NotFoundException } from '@nestjs/common';
import type { Request } from 'express';
import { AccountController } from './account.controller';
import { AccountService } from './account.service';
import type { AuthUser } from '../auth/auth.types';
import type {
  AccountProfile,
  CommunicationPreferences,
  DataExportRequest,
  ClosureRequest,
  RestrictionStatus,
} from './account.types';
import { COMM_PREF_CATEGORY, ExportRequestNotFoundException } from './account.types';

const mockUser: AuthUser = {
  id: 'user-1',
  email: 'test@example.com',
  passwordHash: 'hash',
  displayName: 'Alice',
  createdAt: new Date('2026-01-01'),
};

const mockProfile: AccountProfile = {
  id: 'user-1',
  email: 'test@example.com',
  displayName: 'Alice',
  createdAt: new Date('2026-01-01'),
};

function makeReq(overrides: Partial<Request> = {}): Request {
  return {
    user: mockUser,
    correlationId: 'test-cid',
    header: () => undefined,
    ...overrides,
  } as unknown as Request;
}

describe('AccountController', () => {
  let controller: AccountController;
  let accountService: jest.Mocked<
    Pick<
      AccountService,
      | 'getProfile'
      | 'updateProfile'
      | 'getCommunicationPreferences'
      | 'updateCommunicationPreferences'
      | 'createDataExportRequest'
      | 'getDataExportRequest'
      | 'createClosureRequest'
      | 'getClosureRequest'
      | 'getRestrictionStatus'
    >
  >;

  beforeEach(() => {
    accountService = {
      getProfile: jest.fn(),
      updateProfile: jest.fn(),
      getCommunicationPreferences: jest.fn(),
      updateCommunicationPreferences: jest.fn(),
      createDataExportRequest: jest.fn(),
      getDataExportRequest: jest.fn(),
      createClosureRequest: jest.fn(),
      getClosureRequest: jest.fn(),
      getRestrictionStatus: jest.fn(),
    };
    controller = new AccountController(
      accountService as unknown as AccountService,
    );
  });

  describe('getProfile', () => {
    it('returns a success envelope with the profile', () => {
      accountService.getProfile.mockReturnValue(mockProfile);
      const result = controller.getProfile(makeReq()) as {
        success: boolean;
        data: AccountProfile;
      };
      expect(result.success).toBe(true);
      expect(result.data).toEqual(mockProfile);
      expect(accountService.getProfile).toHaveBeenCalledWith('user-1');
    });

    it('propagates NotFoundException from service', () => {
      accountService.getProfile.mockImplementation(() => {
        throw new NotFoundException({
          code: 'ACCOUNT_NOT_FOUND',
          message: 'Account not found',
        });
      });
      expect(() => controller.getProfile(makeReq())).toThrow(NotFoundException);
    });
  });

  describe('updateProfile', () => {
    it('returns a success envelope with the updated profile', () => {
      const updated: AccountProfile = { ...mockProfile, displayName: 'Bob' };
      accountService.updateProfile.mockReturnValue(updated);
      const result = controller.updateProfile(
        { displayName: 'Bob' },
        makeReq(),
      ) as { success: boolean; data: AccountProfile };
      expect(result.success).toBe(true);
      expect(result.data.displayName).toBe('Bob');
      expect(accountService.updateProfile).toHaveBeenCalledWith('user-1', {
        displayName: 'Bob',
      });
    });

    it('returns updated profile with null displayName when cleared', () => {
      const updated: AccountProfile = { ...mockProfile, displayName: null };
      accountService.updateProfile.mockReturnValue(updated);
      const result = controller.updateProfile(
        { displayName: null },
        makeReq(),
      ) as { success: boolean; data: AccountProfile };
      expect(result.success).toBe(true);
      expect(result.data.displayName).toBeNull();
    });

    it('propagates NotFoundException from service', () => {
      accountService.updateProfile.mockImplementation(() => {
        throw new NotFoundException({
          code: 'ACCOUNT_NOT_FOUND',
          message: 'Account not found',
        });
      });
      expect(() =>
        controller.updateProfile({ displayName: 'X' }, makeReq()),
      ).toThrow(NotFoundException);
    });
  });

  describe('getCommunicationPreferences', () => {
    const mockPrefs: CommunicationPreferences = {
      preferences: [
        { category: COMM_PREF_CATEGORY.SECURITY, enabled: true, mandatory: true },
        { category: COMM_PREF_CATEGORY.COMPLIANCE, enabled: true, mandatory: true },
        { category: COMM_PREF_CATEGORY.PRODUCT, enabled: true, mandatory: false },
      ],
    };

    it('returns a success envelope with preferences', () => {
      accountService.getCommunicationPreferences.mockReturnValue(mockPrefs);
      const result = controller.getCommunicationPreferences(makeReq()) as {
        success: boolean;
        data: CommunicationPreferences;
        correlationId: string;
      };
      expect(result.success).toBe(true);
      expect(result.data.preferences).toHaveLength(3);
      expect(result.correlationId).toBe('test-cid');
      expect(accountService.getCommunicationPreferences).toHaveBeenCalledWith('user-1');
    });
  });

  describe('updateCommunicationPreferences', () => {
    const updatedPrefs: CommunicationPreferences = {
      preferences: [
        { category: COMM_PREF_CATEGORY.SECURITY, enabled: true, mandatory: true },
        { category: COMM_PREF_CATEGORY.COMPLIANCE, enabled: true, mandatory: true },
        { category: COMM_PREF_CATEGORY.PRODUCT, enabled: false, mandatory: false },
      ],
    };

    it('returns a success envelope with updated preferences', () => {
      accountService.updateCommunicationPreferences.mockReturnValue(updatedPrefs);
      const result = controller.updateCommunicationPreferences(
        { productEmails: false },
        makeReq(),
      ) as { success: boolean; data: CommunicationPreferences; correlationId: string };
      expect(result.success).toBe(true);
      const product = result.data.preferences.find(
        (p) => p.category === COMM_PREF_CATEGORY.PRODUCT,
      )!;
      expect(product.enabled).toBe(false);
      expect(result.correlationId).toBe('test-cid');
      expect(accountService.updateCommunicationPreferences).toHaveBeenCalledWith(
        'user-1',
        { productEmails: false },
      );
    });
  });

  describe('createDataExportRequest', () => {
    const mockExportRequest: DataExportRequest = {
      requestId: 'req-1',
      userId: 'user-1',
      status: 'pending',
      createdAt: '2026-03-06T00:00:00.000Z',
    };

    it('returns a success envelope with the export request', () => {
      accountService.createDataExportRequest.mockReturnValue(mockExportRequest);
      const result = controller.createDataExportRequest({}, makeReq()) as {
        success: boolean;
        data: DataExportRequest;
      };
      expect(result.success).toBe(true);
      expect(result.data.requestId).toBe('req-1');
      expect(result.data.status).toBe('pending');
      expect(accountService.createDataExportRequest).toHaveBeenCalledWith(
        'user-1',
        'test-cid',
      );
    });
  });

  describe('getDataExportRequest', () => {
    const mockExportRequest: DataExportRequest = {
      requestId: 'req-1',
      userId: 'user-1',
      status: 'completed',
      createdAt: '2026-03-06T00:00:00.000Z',
      completedAt: '2026-03-06T00:00:01.000Z',
      downloadUrl: 'data:application/json;base64,abc',
    };

    it('returns a success envelope with the export request when found', () => {
      accountService.getDataExportRequest.mockReturnValue(mockExportRequest);
      const result = controller.getDataExportRequest('req-1', makeReq()) as {
        success: boolean;
        data: DataExportRequest;
      };
      expect(result.success).toBe(true);
      expect(result.data.status).toBe('completed');
      expect(accountService.getDataExportRequest).toHaveBeenCalledWith(
        'user-1',
        'req-1',
      );
    });

    it('throws ExportRequestNotFoundException when not found', () => {
      accountService.getDataExportRequest.mockReturnValue(null);
      expect(() =>
        controller.getDataExportRequest('unknown-id', makeReq()),
      ).toThrow(ExportRequestNotFoundException);
    });
  });

  describe('createClosureRequest', () => {
    const mockClosureRequest: ClosureRequest = {
      requestId: 'close-1',
      userId: 'user-1',
      status: 'pending',
      createdAt: '2026-03-06T00:00:00.000Z',
      message: 'Your account is scheduled for closure. You will lose access to all data.',
    };

    it('returns a success envelope with the closure request', () => {
      accountService.createClosureRequest.mockReturnValue(mockClosureRequest);
      const result = controller.createClosureRequest(
        { confirmClosure: true },
        makeReq(),
      ) as { success: boolean; data: ClosureRequest };
      expect(result.success).toBe(true);
      expect(result.data.requestId).toBe('close-1');
      expect(result.data.message).toContain('closure');
      expect(accountService.createClosureRequest).toHaveBeenCalledWith(
        'user-1',
        { confirmClosure: true },
        'test-cid',
      );
    });
  });

  describe('getRestrictionStatus', () => {
    it('returns success envelope with isRestricted false for unrestricted user', () => {
      const mockStatus: RestrictionStatus = { isRestricted: false };
      accountService.getRestrictionStatus.mockReturnValue(mockStatus);
      const result = controller.getRestrictionStatus(makeReq()) as {
        success: boolean;
        data: RestrictionStatus;
        correlationId: string;
      };
      expect(result.success).toBe(true);
      expect(result.data.isRestricted).toBe(false);
      expect(result.correlationId).toBe('test-cid');
      expect(accountService.getRestrictionStatus).toHaveBeenCalledWith('user-1');
    });

    it('returns success envelope with full payload for restricted user', () => {
      const mockStatus: RestrictionStatus = {
        isRestricted: true,
        rationale: 'Suspicious activity',
        nextSteps: 'Contact support',
        restrictedActions: ['upload'],
      };
      accountService.getRestrictionStatus.mockReturnValue(mockStatus);
      const result = controller.getRestrictionStatus(makeReq()) as {
        success: boolean;
        data: RestrictionStatus;
      };
      expect(result.success).toBe(true);
      expect(result.data.isRestricted).toBe(true);
      expect(result.data.rationale).toBe('Suspicious activity');
      expect(result.data.nextSteps).toBe('Contact support');
      expect(result.data.restrictedActions).toEqual(['upload']);
    });
  });

  describe('getClosureRequest', () => {
    it('returns status null when no closure request exists', () => {
      accountService.getClosureRequest.mockReturnValue(null);
      const result = controller.getClosureRequest(makeReq()) as {
        success: boolean;
        data: { status: null; request: null };
      };
      expect(result.success).toBe(true);
      expect(result.data.status).toBeNull();
    });

    it('returns closure request status when one exists', () => {
      const mockClosureRequest: ClosureRequest = {
        requestId: 'close-1',
        userId: 'user-1',
        status: 'pending',
        createdAt: '2026-03-06T00:00:00.000Z',
        message: 'Your account is scheduled for closure.',
      };
      accountService.getClosureRequest.mockReturnValue(mockClosureRequest);
      const result = controller.getClosureRequest(makeReq()) as {
        success: boolean;
        data: { status: string; request: ClosureRequest };
      };
      expect(result.success).toBe(true);
      expect(result.data.status).toBe('pending');
    });
  });
});
