import { ProfileLimitExceededException } from './exceptions/profile-limit-exceeded.exception';
import { ProfileNotFoundException } from './exceptions/profile-not-found.exception';
import { ProfilesService } from './profiles.service';
import type { EntitlementsService } from '../entitlements/entitlements.service';

function createService(maxProfiles = 2): ProfilesService {
  const entitlementsService = {
    getMaxProfiles: jest.fn().mockReturnValue(maxProfiles),
  } as unknown as EntitlementsService;
  return new ProfilesService(entitlementsService);
}

describe('ProfilesService', () => {
  let service: ProfilesService;

  beforeEach(() => {
    service = createService(2);
  });

  describe('getProfiles', () => {
    it('returns empty array for new user', () => {
      const profiles = service.getProfiles('user-1');
      expect(profiles).toEqual([]);
    });
  });

  describe('createProfile', () => {
    it('creates a profile with generated id and createdAt', () => {
      const profile = service.createProfile('user-1', { name: 'Vishnu' });
      expect(profile.id).toBeTruthy();
      expect(profile.name).toBe('Vishnu');
      expect(profile.createdAt).toBeTruthy();
      expect(profile.userId).toBe('user-1');
      expect(profile.dateOfBirth).toBeNull();
      expect(profile.relation).toBeNull();
    });

    it('first created profile is auto-activated (isActive: true)', () => {
      const profile = service.createProfile('user-1', { name: 'Vishnu' });
      expect(profile.isActive).toBe(true);
    });

    it('second created profile is not active by default', () => {
      service.createProfile('user-1', { name: 'Vishnu' });
      const second = service.createProfile('user-1', { name: 'Amma' });
      expect(second.isActive).toBe(false);
    });

    it('first profile remains active after second is created', () => {
      const first = service.createProfile('user-1', { name: 'Vishnu' });
      service.createProfile('user-1', { name: 'Amma' });
      const profiles = service.getProfiles('user-1');
      const firstUpdated = profiles.find((p) => p.id === first.id)!;
      expect(firstUpdated.isActive).toBe(true);
    });

    it('stores optional fields when provided', () => {
      const profile = service.createProfile('user-1', {
        name: 'Amma',
        dateOfBirth: '1960-05-15',
        relation: 'parent',
      });
      expect(profile.dateOfBirth).toBe('1960-05-15');
      expect(profile.relation).toBe('parent');
    });

    it('profiles from different users are isolated', () => {
      service.createProfile('user-1', { name: 'Vishnu' });
      const user2Profiles = service.getProfiles('user-2');
      expect(user2Profiles).toHaveLength(0);
    });

    it('throws ProfileLimitExceededException when free tier and already at 1 profile', () => {
      const freeService = createService(1);
      freeService.createProfile('user-1', { name: 'Vishnu' });
      expect(() =>
        freeService.createProfile('user-1', { name: 'Amma' }),
      ).toThrow(ProfileLimitExceededException);
    });
  });

  describe('activateProfile', () => {
    it('switches active profile and returns full updated list', () => {
      const first = service.createProfile('user-1', { name: 'Vishnu' });
      const second = service.createProfile('user-1', { name: 'Amma' });
      const result = service.activateProfile('user-1', second.id);
      const updatedFirst = result.find((p) => p.id === first.id)!;
      const updatedSecond = result.find((p) => p.id === second.id)!;
      expect(updatedFirst.isActive).toBe(false);
      expect(updatedSecond.isActive).toBe(true);
    });

    it('throws ProfileNotFoundException for non-existent profile id', () => {
      expect(() => service.activateProfile('user-1', 'nonexistent-id')).toThrow(
        ProfileNotFoundException,
      );
    });

    it('throws ProfileNotFoundException when profile belongs to a different user', () => {
      const profile = service.createProfile('user-1', { name: 'Vishnu' });
      expect(() => service.activateProfile('user-2', profile.id)).toThrow(
        ProfileNotFoundException,
      );
    });
  });

  describe('deleteProfile', () => {
    it('deletes a profile and returns updated list without it', () => {
      const first = service.createProfile('user-1', { name: 'Vishnu' });
      const second = service.createProfile('user-1', { name: 'Amma' });
      const result = service.deleteProfile('user-1', second.id);
      expect(result).toHaveLength(1);
      expect(result[0].id).toBe(first.id);
    });

    it('deleting the active profile sets another profile as active', () => {
      const first = service.createProfile('user-1', { name: 'Vishnu' });
      service.createProfile('user-1', { name: 'Amma' });
      const result = service.deleteProfile('user-1', first.id);
      expect(result).toHaveLength(1);
      expect(result[0].isActive).toBe(true);
    });

    it('deleting the only profile returns empty list and clears active', () => {
      const only = service.createProfile('user-1', { name: 'Vishnu' });
      const result = service.deleteProfile('user-1', only.id);
      expect(result).toHaveLength(0);
      const after = service.getProfiles('user-1');
      expect(after).toHaveLength(0);
    });

    it('deleting a non-active profile preserves the existing active profile', () => {
      const first = service.createProfile('user-1', { name: 'Vishnu' });
      const second = service.createProfile('user-1', { name: 'Amma' });
      const result = service.deleteProfile('user-1', second.id);
      const active = result.find((p) => p.id === first.id)!;
      expect(active.isActive).toBe(true);
    });

    it('throws ProfileNotFoundException for non-existent profile id', () => {
      expect(() =>
        service.deleteProfile('user-1', 'nonexistent-id'),
      ).toThrow(ProfileNotFoundException);
    });

    it('throws ProfileNotFoundException when profile belongs to a different user', () => {
      const profile = service.createProfile('user-1', { name: 'Vishnu' });
      expect(() => service.deleteProfile('user-2', profile.id)).toThrow(
        ProfileNotFoundException,
      );
    });
  });

  describe('updateProfile', () => {
    it('updates name and reflects in getProfiles', () => {
      const profile = service.createProfile('user-1', { name: 'Vishnu' });
      const updated = service.updateProfile('user-1', profile.id, {
        name: 'Vishnu Updated',
      });
      expect(updated.name).toBe('Vishnu Updated');

      const profiles = service.getProfiles('user-1');
      expect(profiles[0].name).toBe('Vishnu Updated');
    });

    it('updates optional fields', () => {
      const profile = service.createProfile('user-1', { name: 'Amma' });
      const updated = service.updateProfile('user-1', profile.id, {
        dateOfBirth: '1960-05-15',
        relation: 'parent',
      });
      expect(updated.dateOfBirth).toBe('1960-05-15');
      expect(updated.relation).toBe('parent');
    });

    it('preserves existing fields when only partial update provided', () => {
      const profile = service.createProfile('user-1', {
        name: 'Amma',
        relation: 'parent',
      });
      const updated = service.updateProfile('user-1', profile.id, {
        name: 'Amma Edited',
      });
      expect(updated.relation).toBe('parent');
    });

    it('preserves isActive state after update', () => {
      const profile = service.createProfile('user-1', { name: 'Vishnu' });
      const updated = service.updateProfile('user-1', profile.id, {
        name: 'Vishnu Updated',
      });
      expect(updated.isActive).toBe(true);
    });

    it('throws ProfileNotFoundException for non-existent profile id', () => {
      expect(() =>
        service.updateProfile('user-1', 'nonexistent-id', { name: 'New' }),
      ).toThrow(ProfileNotFoundException);
    });

    it('throws ProfileNotFoundException when profile belongs to a different user', () => {
      const profile = service.createProfile('user-1', { name: 'Vishnu' });
      expect(() =>
        service.updateProfile('user-2', profile.id, { name: 'Hacked' }),
      ).toThrow(ProfileNotFoundException);
    });
  });
});
