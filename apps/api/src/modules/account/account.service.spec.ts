import { BadRequestException, NotFoundException } from '@nestjs/common';
import { AccountService } from './account.service';
import { AuthService } from '../auth/auth.service';
import type { AuthUser } from '../auth/auth.types';
import { COMM_PREF_CATEGORY } from './account.types';

const baseUser: AuthUser = {
  id: 'user-1',
  email: 'test@example.com',
  passwordHash: 'hash',
  displayName: null,
  createdAt: new Date('2026-01-01'),
};

describe('AccountService', () => {
  let service: AccountService;
  let authService: jest.Mocked<
    Pick<AuthService, 'findUserById' | 'updateUser' | 'revokeAllSessionsForUser'>
  >;

  beforeEach(() => {
    authService = {
      findUserById: jest.fn(),
      updateUser: jest.fn(),
      revokeAllSessionsForUser: jest.fn(),
    };
    service = new AccountService(authService as unknown as AuthService);
  });

  describe('getProfile', () => {
    it('returns AccountProfile for a known user', () => {
      authService.findUserById.mockReturnValue({ ...baseUser });
      const profile = service.getProfile('user-1');
      expect(profile).toEqual({
        id: 'user-1',
        email: 'test@example.com',
        displayName: null,
        createdAt: baseUser.createdAt,
      });
    });

    it('throws NotFoundException for unknown user', () => {
      authService.findUserById.mockReturnValue(undefined);
      expect(() => service.getProfile('unknown')).toThrow(NotFoundException);
    });
  });

  describe('updateProfile', () => {
    it('updates displayName and returns updated profile', () => {
      const user = { ...baseUser };
      authService.findUserById.mockReturnValue(user);
      authService.updateUser.mockImplementation((id, patch) => {
        if (patch.displayName !== undefined)
          user.displayName = patch.displayName;
      });

      const updated = service.updateProfile('user-1', { displayName: 'Alice' });
      expect(authService.updateUser).toHaveBeenCalledWith('user-1', {
        displayName: 'Alice',
      });
      expect(updated.displayName).toBe('Alice');
    });

    it('clears displayName when null is passed', () => {
      const user = { ...baseUser, displayName: 'Alice' };
      authService.findUserById.mockReturnValue(user);
      authService.updateUser.mockImplementation((_, patch) => {
        if (patch.displayName !== undefined)
          user.displayName = patch.displayName;
      });

      const updated = service.updateProfile('user-1', { displayName: null });
      expect(authService.updateUser).toHaveBeenCalledWith('user-1', {
        displayName: null,
      });
      expect(updated.displayName).toBeNull();
    });

    it('does not call updateUser when dto is empty', () => {
      authService.findUserById.mockReturnValue({ ...baseUser });
      service.updateProfile('user-1', {});
      expect(authService.updateUser).not.toHaveBeenCalled();
    });

    it('throws NotFoundException for unknown user', () => {
      authService.findUserById.mockReturnValue(undefined);
      expect(() =>
        service.updateProfile('unknown', { displayName: 'X' }),
      ).toThrow(NotFoundException);
    });
  });

  describe('getCommunicationPreferences', () => {
    it('returns defaults for user with no stored prefs', () => {
      const result = service.getCommunicationPreferences('user-1');
      expect(result.preferences).toHaveLength(3);

      const security = result.preferences.find(
        (p) => p.category === COMM_PREF_CATEGORY.SECURITY,
      )!;
      expect(security.enabled).toBe(true);
      expect(security.mandatory).toBe(true);

      const compliance = result.preferences.find(
        (p) => p.category === COMM_PREF_CATEGORY.COMPLIANCE,
      )!;
      expect(compliance.enabled).toBe(true);
      expect(compliance.mandatory).toBe(true);

      const product = result.preferences.find(
        (p) => p.category === COMM_PREF_CATEGORY.PRODUCT,
      )!;
      expect(product.enabled).toBe(true);
      expect(product.mandatory).toBe(false);
    });

    it('returns stored prefs when present', () => {
      service.updateCommunicationPreferences('user-1', { productEmails: false });
      const result = service.getCommunicationPreferences('user-1');
      const product = result.preferences.find(
        (p) => p.category === COMM_PREF_CATEGORY.PRODUCT,
      )!;
      expect(product.enabled).toBe(false);
    });
  });

  describe('updateCommunicationPreferences', () => {
    it('updates only the product category', () => {
      const result = service.updateCommunicationPreferences('user-1', {
        productEmails: false,
      });
      const product = result.preferences.find(
        (p) => p.category === COMM_PREF_CATEGORY.PRODUCT,
      )!;
      expect(product.enabled).toBe(false);
    });

    it('leaves mandatory categories enabled even if client sends false', () => {
      const result = service.updateCommunicationPreferences('user-1', {});
      const security = result.preferences.find(
        (p) => p.category === COMM_PREF_CATEGORY.SECURITY,
      )!;
      const compliance = result.preferences.find(
        (p) => p.category === COMM_PREF_CATEGORY.COMPLIANCE,
      )!;
      expect(security.enabled).toBe(true);
      expect(compliance.enabled).toBe(true);
    });

    it('does not change product if productEmails not in dto', () => {
      service.updateCommunicationPreferences('user-1', { productEmails: false });
      const result = service.updateCommunicationPreferences('user-1', {});
      const product = result.preferences.find(
        (p) => p.category === COMM_PREF_CATEGORY.PRODUCT,
      )!;
      expect(product.enabled).toBe(false);
    });
  });

  describe('createDataExportRequest', () => {
    it('creates a pending export request and returns it', () => {
      const req = service.createDataExportRequest('user-1', 'cid-1');
      expect(req.requestId).toBeDefined();
      expect(req.userId).toBe('user-1');
      expect(req.status).toBe('pending');
      expect(req.createdAt).toBeDefined();
    });

    it('stores request accessible by requestId', () => {
      const req = service.createDataExportRequest('user-1', 'cid-1');
      authService.findUserById.mockReturnValue({ ...baseUser });
      const fetched = service.getDataExportRequest('user-1', req.requestId);
      expect(fetched).not.toBeNull();
      expect(fetched!.requestId).toBe(req.requestId);
    });
  });

  describe('getDataExportRequest', () => {
    it('returns null for unknown requestId', () => {
      const result = service.getDataExportRequest('user-1', 'nonexistent-id');
      expect(result).toBeNull();
    });

    it('returns null when requestId belongs to a different user', () => {
      const req = service.createDataExportRequest('user-1', 'cid-1');
      const result = service.getDataExportRequest('user-2', req.requestId);
      expect(result).toBeNull();
    });

    it('transitions status to completed on first GET and includes downloadUrl', () => {
      const req = service.createDataExportRequest('user-1', 'cid-1');
      authService.findUserById.mockReturnValue({ ...baseUser });
      const fetched = service.getDataExportRequest('user-1', req.requestId);
      expect(fetched!.status).toBe('completed');
      expect(fetched!.downloadUrl).toBeDefined();
      expect(fetched!.completedAt).toBeDefined();
    });

    it('subsequent GET returns completed status', () => {
      const req = service.createDataExportRequest('user-1', 'cid-1');
      authService.findUserById.mockReturnValue({ ...baseUser });
      service.getDataExportRequest('user-1', req.requestId);
      const second = service.getDataExportRequest('user-1', req.requestId);
      expect(second!.status).toBe('completed');
    });

    it('sets status to failed with failureReason when user is not found at export time', () => {
      const req = service.createDataExportRequest('user-1', 'cid-1');
      authService.findUserById.mockReturnValue(undefined);
      const fetched = service.getDataExportRequest('user-1', req.requestId);
      expect(fetched!.status).toBe('failed');
      expect(fetched!.failureReason).toBe('USER_NOT_FOUND');
      expect(fetched!.downloadUrl).toBeUndefined();
    });
  });

  describe('createClosureRequest', () => {
    it('creates a closure request when confirmClosure is true and marks it completed', () => {
      const req = service.createClosureRequest(
        'user-1',
        { confirmClosure: true },
        'cid-1',
      );
      expect(req.requestId).toBeDefined();
      expect(req.userId).toBe('user-1');
      expect(req.status).toBe('completed');
      expect(req.message).toBeDefined();
      expect(authService.revokeAllSessionsForUser).toHaveBeenCalledWith('user-1');
    });

    it('throws BadRequestException when confirmClosure is false', () => {
      expect(() =>
        service.createClosureRequest('user-1', { confirmClosure: false }, 'cid-1'),
      ).toThrow(BadRequestException);
    });
  });

  describe('getClosureRequest', () => {
    it('returns null when no closure request exists', () => {
      expect(service.getClosureRequest('user-1')).toBeNull();
    });

    it('returns the closure request after it is created', () => {
      service.createClosureRequest('user-1', { confirmClosure: true }, 'cid-1');
      const req = service.getClosureRequest('user-1');
      expect(req).not.toBeNull();
      expect(req!.userId).toBe('user-1');
    });
  });

  describe('getRestrictionStatus', () => {
    it('returns isRestricted false when user is not in restriction store', () => {
      const result = service.getRestrictionStatus('user-1');
      expect(result).toEqual({ isRestricted: false });
    });

    it('returns full payload when user is restricted', () => {
      // Directly seed the private store via type cast for testing
      const store = (service as unknown as { restrictionStore: Map<string, { rationale: string; nextSteps: string; restrictedActions?: string[] }> }).restrictionStore;
      store.set('user-1', {
        rationale: 'Suspicious activity detected',
        nextSteps: 'Contact support at support@doclyzer.com',
        restrictedActions: ['upload', 'share'],
      });

      const result = service.getRestrictionStatus('user-1');
      expect(result.isRestricted).toBe(true);
      expect(result.rationale).toBe('Suspicious activity detected');
      expect(result.nextSteps).toBe('Contact support at support@doclyzer.com');
      expect(result.restrictedActions).toEqual(['upload', 'share']);
    });

    it('returns isRestricted false when entry exists but rationale is empty', () => {
      const store = (service as unknown as { restrictionStore: Map<string, { rationale: string; nextSteps: string; restrictedActions?: string[] }> }).restrictionStore;
      store.set('user-1', { rationale: '', nextSteps: 'Wait for review' });

      const result = service.getRestrictionStatus('user-1');
      expect(result).toEqual({ isRestricted: false });
    });

    it('returns isRestricted false when entry exists but nextSteps is empty', () => {
      const store = (service as unknown as { restrictionStore: Map<string, { rationale: string; nextSteps: string; restrictedActions?: string[] }> }).restrictionStore;
      store.set('user-1', { rationale: 'Policy violation', nextSteps: '' });

      const result = service.getRestrictionStatus('user-1');
      expect(result).toEqual({ isRestricted: false });
    });

    it('returns full payload without restrictedActions when not set', () => {
      const store = (service as unknown as { restrictionStore: Map<string, { rationale: string; nextSteps: string; restrictedActions?: string[] }> }).restrictionStore;
      store.set('user-1', {
        rationale: 'Policy violation',
        nextSteps: 'Wait for review',
      });

      const result = service.getRestrictionStatus('user-1');
      expect(result.isRestricted).toBe(true);
      expect(result.rationale).toBe('Policy violation');
      expect(result.nextSteps).toBe('Wait for review');
      expect(result.restrictedActions).toBeUndefined();
    });
  });
});
