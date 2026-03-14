import { NotFoundException } from '@nestjs/common';
import type { Repository } from 'typeorm';
import { AccountService } from './account.service';
import { AuthService } from '../auth/auth.service';
import { UserEntity } from '../../database/entities/user.entity';
import { AccountPreferenceEntity } from '../../database/entities/account-preference.entity';
import { RestrictionEntity } from '../../database/entities/restriction.entity';
import { DataExportRequestEntity } from '../../database/entities/data-export-request.entity';
import { ClosureRequestEntity } from '../../database/entities/closure-request.entity';
import { ProfileEntity } from '../../database/entities/profile.entity';
import { ConsentRecordEntity } from '../../database/entities/consent-record.entity';
import { COMM_PREF_CATEGORY } from './account.types';
import type { FileStorageService } from '../../common/storage/file-storage.interface';

function makeFileStorage(): jest.Mocked<FileStorageService> {
  return {
    upload: jest.fn().mockResolvedValue('avatars/user-1.jpg'),
    delete: jest.fn().mockResolvedValue(undefined),
    getSignedUrl: jest.fn().mockResolvedValue('https://example.com/signed'),
  };
}

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
  avatarUrl: null,
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
  let profileRepo: ReturnType<typeof makeRepo>;
  let consentRepo: ReturnType<typeof makeRepo>;
  let authService: jest.Mocked<Pick<AuthService, 'revokeAllSessionsForUser'>>;
  let fileStorage: ReturnType<typeof makeFileStorage>;

  beforeEach(() => {
    userRepo = makeRepo();
    prefRepo = makeRepo();
    restrictionRepo = makeRepo();
    exportRepo = makeRepo();
    closureRepo = makeRepo();
    profileRepo = makeRepo();
    consentRepo = makeRepo();
    authService = {
      revokeAllSessionsForUser: jest.fn().mockResolvedValue(undefined),
    };
    fileStorage = makeFileStorage();

    service = new AccountService(
      userRepo as unknown as Repository<UserEntity>,
      prefRepo as unknown as Repository<AccountPreferenceEntity>,
      restrictionRepo as unknown as Repository<RestrictionEntity>,
      exportRepo as unknown as Repository<DataExportRequestEntity>,
      closureRepo as unknown as Repository<ClosureRequestEntity>,
      profileRepo as unknown as Repository<ProfileEntity>,
      consentRepo as unknown as Repository<ConsentRecordEntity>,
      authService as unknown as AuthService,
      fileStorage,
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
        avatarUrl: null,
        createdAt: baseUser.createdAt,
      });
    });

    it('throws NotFoundException for unknown user', async () => {
      userRepo.findOne.mockResolvedValue(null);
      await expect(service.getProfile('unknown')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('resolves avatar storage key to signed URL', async () => {
      const userWithAvatar = { ...baseUser, avatarUrl: 'avatars/user-1.jpg' };
      userRepo.findOne.mockResolvedValue(userWithAvatar);
      fileStorage.getSignedUrl.mockResolvedValue(
        'https://signed.example/avatar',
      );
      const profile = await service.getProfile('user-1');
      expect(profile.avatarUrl).toBe('https://signed.example/avatar');
      // eslint-disable-next-line @typescript-eslint/unbound-method -- jest mock assertion
      expect(fileStorage.getSignedUrl).toHaveBeenCalledWith(
        'avatars/user-1.jpg',
        300,
      );
    });
  });

  describe('updateProfile', () => {
    it('updates displayName and returns updated profile', async () => {
      const user = { ...baseUser };
      userRepo.findOne.mockResolvedValue(user);
      userRepo.save.mockResolvedValue({
        ...user,
        displayName: 'Alice',
      } as UserEntity);
      const updated = await service.updateProfile('user-1', {
        displayName: 'Alice',
      });
      expect(updated.displayName).toBe('Alice');
    });

    it('clears avatar when avatarUrl is null and deletes old key', async () => {
      const userWithAvatar = {
        ...baseUser,
        avatarUrl: 'avatars/user-1.jpg',
      } as UserEntity;
      userRepo.findOne.mockResolvedValue(userWithAvatar);
      userRepo.save.mockResolvedValue({
        ...userWithAvatar,
        avatarUrl: null,
      } as UserEntity);
      fileStorage.getSignedUrl.mockResolvedValue('https://example.com/signed');

      await service.updateProfile('user-1', { avatarUrl: null });

      // eslint-disable-next-line @typescript-eslint/unbound-method -- jest mock assertion
      expect(fileStorage.delete).toHaveBeenCalledWith('avatars/user-1.jpg');
      // eslint-disable-next-line @typescript-eslint/unbound-method -- jest mock assertion
      expect(userRepo.save).toHaveBeenCalledWith(
        expect.objectContaining({ avatarUrl: null }),
      );
    });

    it('throws NotFoundException for unknown user', async () => {
      userRepo.findOne.mockResolvedValue(null);
      await expect(
        service.updateProfile('unknown', { displayName: 'X' }),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('getCommunicationPreferences', () => {
    it('returns defaults for user with no stored prefs', async () => {
      prefRepo.findOne.mockResolvedValue(null);
      const result = await service.getCommunicationPreferences('user-1');
      expect(result.preferences).toHaveLength(3);
      const product = result.preferences.find(
        (p) => p.category === COMM_PREF_CATEGORY.PRODUCT,
      )!;
      expect(product.enabled).toBe(true);
      expect(product.mandatory).toBe(false);
    });

    it('returns stored prefs when present', async () => {
      prefRepo.findOne.mockResolvedValue({
        productEmailsEnabled: false,
      } as AccountPreferenceEntity);
      const result = await service.getCommunicationPreferences('user-1');
      const product = result.preferences.find(
        (p) => p.category === COMM_PREF_CATEGORY.PRODUCT,
      )!;
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
      const req = await service.createClosureRequest(
        'user-1',
        { confirmClosure: true },
        'cid-1',
      );
      expect(req.status).toBe('completed');
      expect(authService.revokeAllSessionsForUser).toHaveBeenCalledWith(
        'user-1',
      );
    });

    it('throws when confirmClosure is false', async () => {
      await expect(
        service.createClosureRequest(
          'user-1',
          { confirmClosure: false },
          'cid-1',
        ),
      ).rejects.toThrow();
    });

    it('deletes avatar from storage when user has avatarUrl', async () => {
      const userWithAvatar = {
        ...baseUser,
        avatarUrl: 'avatars/user-1.jpg',
      } as UserEntity;
      userRepo.findOne.mockResolvedValue(userWithAvatar);
      closureRepo.save.mockResolvedValue({
        id: 'close-1',
        userId: 'user-1',
        status: 'completed',
        message: 'scheduled for closure',
        createdAt: new Date(),
      } as unknown as ClosureRequestEntity);
      fileStorage.getSignedUrl.mockResolvedValue('https://example.com/signed');

      await service.createClosureRequest(
        'user-1',
        { confirmClosure: true },
        'cid-1',
      );

      expect(fileStorage.delete).toHaveBeenCalledWith('avatars/user-1.jpg');
    });
  });
});
