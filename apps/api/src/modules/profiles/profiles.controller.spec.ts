import type { Request } from 'express';
import type { AuthUser } from '../auth/auth.types';
import type { ProfileWithActive } from './profiles.types';
import { ProfilesController } from './profiles.controller';
import { ProfilesService } from './profiles.service';

const mockUser: AuthUser = {
  id: 'user-1',
  email: 'test@example.com',
  passwordHash: 'hash',
  displayName: null,
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

const mockProfile: ProfileWithActive = {
  id: 'profile-1',
  userId: 'user-1',
  name: 'Vishnu',
  dateOfBirth: null,
  relation: null,
  createdAt: '2026-03-06T00:00:00.000Z',
  isActive: true,
};

describe('ProfilesController', () => {
  let controller: ProfilesController;
  let profilesService: jest.Mocked<
    Pick<ProfilesService, 'getProfiles' | 'createProfile' | 'updateProfile' | 'activateProfile' | 'deleteProfile'>
  >;

  beforeEach(() => {
    profilesService = {
      getProfiles: jest.fn(),
      createProfile: jest.fn(),
      updateProfile: jest.fn(),
      activateProfile: jest.fn(),
      deleteProfile: jest.fn(),
    };
    controller = new ProfilesController(profilesService as unknown as ProfilesService);
  });

  describe('getProfiles', () => {
    it('wraps in success envelope', async () => {
      profilesService.getProfiles.mockResolvedValue([mockProfile]);
      const result = (await controller.getProfiles(makeReq())) as {
        success: boolean;
        data: ProfileWithActive[];
        correlationId: string;
      };
      expect(result.success).toBe(true);
      expect(result.data).toEqual([mockProfile]);
      expect(profilesService.getProfiles).toHaveBeenCalledWith('user-1');
    });
  });

  describe('createProfile', () => {
    it('returns created profile', async () => {
      profilesService.createProfile.mockResolvedValue(mockProfile);
      const result = (await controller.createProfile({ name: 'Vishnu' }, makeReq())) as {
        success: boolean;
        data: ProfileWithActive;
      };
      expect(result.success).toBe(true);
      expect(result.data).toEqual(mockProfile);
      expect(profilesService.createProfile).toHaveBeenCalledWith('user-1', { name: 'Vishnu' });
    });

    it('propagates exceptions from service', async () => {
      profilesService.createProfile.mockRejectedValue(new Error('unexpected'));
      await expect(controller.createProfile({ name: 'Vishnu' }, makeReq())).rejects.toThrow(Error);
    });
  });

  describe('updateProfile', () => {
    it('delegates to ProfilesService.updateProfile', async () => {
      const updated = { ...mockProfile, name: 'Vishnu Updated' };
      profilesService.updateProfile.mockResolvedValue(updated);
      const result = (await controller.updateProfile('profile-1', { name: 'Vishnu Updated' }, makeReq())) as {
        success: boolean;
        data: ProfileWithActive;
      };
      expect(result.success).toBe(true);
      expect(result.data.name).toBe('Vishnu Updated');
    });
  });

  describe('activateProfile', () => {
    it('returns full profile list', async () => {
      profilesService.activateProfile.mockResolvedValue([mockProfile]);
      const result = (await controller.activateProfile('profile-1', makeReq())) as {
        success: boolean;
        data: ProfileWithActive[];
      };
      expect(result.success).toBe(true);
      expect(result.data).toEqual([mockProfile]);
    });
  });

  describe('deleteProfile', () => {
    it('returns updated list', async () => {
      profilesService.deleteProfile.mockResolvedValue([]);
      const result = (await controller.deleteProfile('profile-1', makeReq())) as {
        success: boolean;
        data: ProfileWithActive[];
      };
      expect(result.success).toBe(true);
      expect(result.data).toEqual([]);
    });
  });
});
