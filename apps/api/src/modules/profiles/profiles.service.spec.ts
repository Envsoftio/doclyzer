import type { Repository } from 'typeorm';
import { ProfileLimitExceededException } from './exceptions/profile-limit-exceeded.exception';
import { ProfileNotFoundException } from './exceptions/profile-not-found.exception';
import { ProfilesService } from './profiles.service';
import { ProfileEntity } from '../../database/entities/profile.entity';
import type { EntitlementsService } from '../entitlements/entitlements.service';

function makeProfileRepo(): jest.Mocked<Repository<ProfileEntity>> {
  const store: ProfileEntity[] = [];
  let idCounter = 1;

  return {
    find: jest.fn(({ where }: { where: { userId: string } }) =>
      store.filter((p) => p.userId === where.userId),
    ),
    findOne: jest.fn(
      ({ where }: { where: { id?: string; userId?: string } }) =>
        store.find(
          (p) =>
            (!where.id || p.id === where.id) &&
            (!where.userId || p.userId === where.userId),
        ) ?? null,
    ),
    count: jest.fn(
      ({ where }: { where: { userId: string } }) =>
        store.filter((p) => p.userId === where.userId).length,
    ),
    create: jest.fn(
      (data: Partial<ProfileEntity>) => ({ ...data }) as ProfileEntity,
    ),
    save: jest.fn((entity: ProfileEntity) => {
      const existing = store.findIndex((p) => p.id === entity.id);
      if (existing >= 0) {
        store[existing] = entity;
        return entity;
      }
      const uuidSuffix = idCounter.toString(16).padStart(12, '0');
      const id = `00000000-0000-4000-8000-${uuidSuffix}`;
      idCounter += 1;
      const saved = {
        ...entity,
        id,
        createdAt: new Date(),
        updatedAt: new Date(),
      } as ProfileEntity;
      store.push(saved);
      return saved;
    }),
    delete: jest.fn(({ id, userId }: { id?: string; userId?: string }) => {
      const idx = store.findIndex(
        (p) => (!id || p.id === id) && (!userId || p.userId === userId),
      );
      if (idx >= 0) store.splice(idx, 1);
      return { affected: 1 };
    }),
    update: jest.fn(
      (
        criteria: string | { userId?: string; id?: string },
        partial: Partial<ProfileEntity>,
      ) => {
        store.forEach((p) => {
          const matchId =
            typeof criteria === 'string'
              ? p.id === criteria
              : !criteria.id || p.id === criteria.id;
          const matchUser =
            typeof criteria === 'string'
              ? true
              : !criteria.userId || p.userId === criteria.userId;
          if (matchId && matchUser) Object.assign(p, partial);
        });
        return { affected: 1 };
      },
    ),
  } as unknown as jest.Mocked<Repository<ProfileEntity>>;
}

function createService(maxProfiles = 2): ProfilesService {
  const entitlementsService = {
    getMaxProfiles: jest.fn().mockReturnValue(maxProfiles),
  } as unknown as EntitlementsService;
  return new ProfilesService(makeProfileRepo(), entitlementsService);
}

describe('ProfilesService', () => {
  let service: ProfilesService;

  beforeEach(() => {
    service = createService(2);
  });

  describe('getProfiles', () => {
    it('returns empty array for new user', async () => {
      const profiles = await service.getProfiles('user-1');
      expect(profiles).toEqual([]);
    });
  });

  describe('createProfile', () => {
    it('creates a profile with id and createdAt', async () => {
      const profile = await service.createProfile('user-1', { name: 'Vishnu' });
      expect(profile.id).toBeTruthy();
      expect(profile.name).toBe('Vishnu');
      expect(profile.createdAt).toBeTruthy();
      expect(profile.userId).toBe('user-1');
      expect(profile.dateOfBirth).toBeNull();
      expect(profile.relation).toBeNull();
    });

    it('first created profile is auto-activated', async () => {
      const profile = await service.createProfile('user-1', { name: 'Vishnu' });
      expect(profile.isActive).toBe(true);
    });

    it('second created profile is not active', async () => {
      await service.createProfile('user-1', { name: 'Vishnu' });
      const second = await service.createProfile('user-1', { name: 'Amma' });
      expect(second.isActive).toBe(false);
    });

    it('stores optional fields', async () => {
      const profile = await service.createProfile('user-1', {
        name: 'Amma',
        dateOfBirth: '1960-05-15',
        relation: 'parent',
      });
      expect(profile.dateOfBirth).toBe('1960-05-15');
      expect(profile.relation).toBe('parent');
    });

    it('throws ProfileLimitExceededException at limit', async () => {
      const freeService = createService(1);
      await freeService.createProfile('user-1', { name: 'Vishnu' });
      await expect(
        freeService.createProfile('user-1', { name: 'Amma' }),
      ).rejects.toThrow(ProfileLimitExceededException);
    });
  });

  describe('updateProfile', () => {
    it('updates name', async () => {
      const profile = await service.createProfile('user-1', { name: 'Vishnu' });
      const updated = await service.updateProfile('user-1', profile.id, {
        name: 'Vishnu Updated',
      });
      expect(updated.name).toBe('Vishnu Updated');
    });

    it('throws ProfileNotFoundException for unknown id', async () => {
      await expect(
        service.updateProfile('user-1', 'nonexistent', { name: 'X' }),
      ).rejects.toThrow(ProfileNotFoundException);
    });
  });

  describe('deleteProfile', () => {
    it('throws ProfileNotFoundException for unknown id', async () => {
      await expect(
        service.deleteProfile('user-1', 'nonexistent'),
      ).rejects.toThrow(ProfileNotFoundException);
    });
  });
});
