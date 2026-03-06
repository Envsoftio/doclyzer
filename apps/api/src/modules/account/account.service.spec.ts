import { NotFoundException } from '@nestjs/common';
import type { Repository } from 'typeorm';
import { AccountService } from './account.service';
import { AuthService } from '../auth/auth.service';
import { UserEntity } from '../../database/entities/user.entity';
import { AccountPreferenceEntity } from '../../database/entities/account-preference.entity';
import { RestrictionEntity } from '../../database/entities/restriction.entity';
import { DataExportRequestEntity } from '../../database/entities/data-export-request.entity';
import { ClosureRequestEntity } from '../../database/entities/closure-request.entity';
import { COMM_PREF_CATEGORY } from './account.types';

function makeRepo(): jest.Mocked<Repository<object>> {
  return {
    findOne: jest.fn(),
    find: jest.fn(),
    save: jest.fn(),
    create: jest.fn((data: unknown) => data),
    delete: jest.fn(),
    update: jest.fn(),
    count: jest.fn(),
  } as unknown as jest.Mocked<Repository<object>>;
}

const baseUser: UserEntity = {
  id: 'user-1',
  email: 'test@example.com',
  passwordHash: 'hash',
  displayName: null,
  createdAt: new Date('2026-01-01'),
  updatedAt: new Date('2026-01-01'),
} as UserEntity;

describe('AccountService', () => {
  let service: AccountService;
  let userRepo: ReturnType<typeof makeRepo>;
  let prefRepo: ReturnType<typeof makeRepo>;
  let restrictionRepo: ReturnType<typeof makeRepo>;
  let exportRepo: ReturnType<typeof makeRepo>;
  let closureRepo: ReturnType<typeof makeRepo>;
  let authService: jest.Mocked<Pick<AuthService, 'revokeAllSessionsForUser'>>;

  beforeEach(() => {
    userRepo = makeRepo();
    prefRepo = makeRepo();
    restrictionRepo = makeRepo();
    exportRepo = makeRepo();
    closureRepo = makeRepo();
    authService = { revokeAllSessionsForUser: jest.fn().mockResolvedValue(undefined) };

    service = new AccountService(
      userRepo as unknown as Repository<UserEntity>,
      prefRepo as unknown as Repository<AccountPreferenceEntity>,
      restrictionRepo as unknown as Repository<RestrictionEntity>,
      exportRepo as unknown as Repository<DataExportRequestEntity>,
      closureRepo as unknown as Repository<ClosureRequestEntity>,
      authService as unknown as AuthService,
    );
  });

  describe('getProfile', () => {
    it('returns AccountProfile for a known user', async () => {
      userRepo.findOne.mockResolvedValue(baseUser);
      const profile = await service.getProfile('user-1');
      expect(profile).toEqual({
        id: 'user-1',
        email: 'test@example.com',
        displayName: null,
        createdAt: baseUser.createdAt,
      });
    });

    it('throws NotFoundException for unknown user', async () => {
      userRepo.findOne.mockResolvedValue(null);
      await expect(service.getProfile('unknown')).rejects.toThrow(NotFoundException);
    });
  });

  describe('updateProfile', () => {
    it('updates displayName and returns updated profile', async () => {
      const user = { ...baseUser };
      userRepo.findOne.mockResolvedValue(user);
      userRepo.save.mockResolvedValue({ ...user, displayName: 'Alice' } as UserEntity);
      const updated = await service.updateProfile('user-1', { displayName: 'Alice' });
      expect(updated.displayName).toBe('Alice');
    });

    it('throws NotFoundException for unknown user', async () => {
      userRepo.findOne.mockResolvedValue(null);
      await expect(service.updateProfile('unknown', { displayName: 'X' })).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('getCommunicationPreferences', () => {
    it('returns defaults for user with no stored prefs', async () => {
      prefRepo.findOne.mockResolvedValue(null);
      const result = await service.getCommunicationPreferences('user-1');
      expect(result.preferences).toHaveLength(3);
      const product = result.preferences.find((p) => p.category === COMM_PREF_CATEGORY.PRODUCT)!;
      expect(product.enabled).toBe(true);
      expect(product.mandatory).toBe(false);
    });

    it('returns stored prefs when present', async () => {
      prefRepo.findOne.mockResolvedValue({ productEmailsEnabled: false } as AccountPreferenceEntity);
      const result = await service.getCommunicationPreferences('user-1');
      const product = result.preferences.find((p) => p.category === COMM_PREF_CATEGORY.PRODUCT)!;
      expect(product.enabled).toBe(false);
    });
  });

  describe('getRestrictionStatus', () => {
    it('returns isRestricted false when no restriction exists', async () => {
      restrictionRepo.findOne.mockResolvedValue(null);
      const result = await service.getRestrictionStatus('user-1');
      expect(result).toEqual({ isRestricted: false });
    });

    it('returns full payload when user is restricted', async () => {
      restrictionRepo.findOne.mockResolvedValue({
        isRestricted: true,
        rationale: 'Suspicious activity',
        nextSteps: 'Contact support',
      } as RestrictionEntity);
      const result = await service.getRestrictionStatus('user-1');
      expect(result.isRestricted).toBe(true);
      expect(result.rationale).toBe('Suspicious activity');
    });
  });

  describe('createClosureRequest', () => {
    it('creates and marks completed, revokes sessions', async () => {
      const saved = {
        id: 'close-1',
        userId: 'user-1',
        status: 'completed',
        message: 'scheduled for closure',
        createdAt: new Date(),
      } as unknown as ClosureRequestEntity;
      closureRepo.save.mockResolvedValue(saved);
      const req = await service.createClosureRequest('user-1', { confirmClosure: true }, 'cid-1');
      expect(req.status).toBe('completed');
      expect(authService.revokeAllSessionsForUser).toHaveBeenCalledWith('user-1');
    });

    it('throws when confirmClosure is false', async () => {
      await expect(
        service.createClosureRequest('user-1', { confirmClosure: false }, 'cid-1'),
      ).rejects.toThrow();
    });
  });
});
