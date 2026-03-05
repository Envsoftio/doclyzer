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
    Pick<
      ProfilesService,
      'getProfiles' | 'createProfile' | 'updateProfile' | 'activateProfile'
    >
  >;

  beforeEach(() => {
    profilesService = {
      getProfiles: jest.fn(),
      createProfile: jest.fn(),
      updateProfile: jest.fn(),
      activateProfile: jest.fn(),
    };
    controller = new ProfilesController(
      profilesService as unknown as ProfilesService,
    );
  });

  describe('getProfiles', () => {
    it('delegates to ProfilesService.getProfiles and wraps in success envelope', () => {
      profilesService.getProfiles.mockReturnValue([mockProfile]);
      const result = controller.getProfiles(makeReq()) as {
        success: boolean;
        data: ProfileWithActive[];
        correlationId: string;
      };
      expect(result.success).toBe(true);
      expect(result.data).toEqual([mockProfile]);
      expect(result.correlationId).toBe('test-cid');
      expect(profilesService.getProfiles).toHaveBeenCalledWith('user-1');
    });
  });

  describe('createProfile', () => {
    it('delegates to ProfilesService.createProfile and returns created profile', () => {
      profilesService.createProfile.mockReturnValue(mockProfile);
      const result = controller.createProfile(
        { name: 'Vishnu' },
        makeReq(),
      ) as {
        success: boolean;
        data: ProfileWithActive;
      };
      expect(result.success).toBe(true);
      expect(result.data).toEqual(mockProfile);
      expect(profilesService.createProfile).toHaveBeenCalledWith('user-1', {
        name: 'Vishnu',
      });
    });

    it('propagates exceptions from service', () => {
      profilesService.createProfile.mockImplementation(() => {
        throw new Error('unexpected');
      });
      expect(() =>
        controller.createProfile({ name: 'Vishnu' }, makeReq()),
      ).toThrow(Error);
    });
  });

  describe('updateProfile', () => {
    it('delegates to ProfilesService.updateProfile with userId and profileId', () => {
      const updated = { ...mockProfile, name: 'Vishnu Updated' };
      profilesService.updateProfile.mockReturnValue(updated);
      const result = controller.updateProfile(
        'profile-1',
        { name: 'Vishnu Updated' },
        makeReq(),
      ) as { success: boolean; data: ProfileWithActive };
      expect(result.success).toBe(true);
      expect(result.data.name).toBe('Vishnu Updated');
      expect(profilesService.updateProfile).toHaveBeenCalledWith(
        'user-1',
        'profile-1',
        { name: 'Vishnu Updated' },
      );
    });

    it('propagates exceptions from service', () => {
      profilesService.updateProfile.mockImplementation(() => {
        throw new Error('not found');
      });
      expect(() =>
        controller.updateProfile('bad-id', { name: 'X' }, makeReq()),
      ).toThrow();
    });
  });

  describe('activateProfile', () => {
    it('delegates to ProfilesService.activateProfile and returns full profile list', () => {
      profilesService.activateProfile.mockReturnValue([mockProfile]);
      const result = controller.activateProfile('profile-1', makeReq()) as {
        success: boolean;
        data: ProfileWithActive[];
      };
      expect(result.success).toBe(true);
      expect(result.data).toEqual([mockProfile]);
      expect(profilesService.activateProfile).toHaveBeenCalledWith(
        'user-1',
        'profile-1',
      );
    });

    it('propagates exceptions from service', () => {
      profilesService.activateProfile.mockImplementation(() => {
        throw new Error('not found');
      });
      expect(() => controller.activateProfile('bad-id', makeReq())).toThrow();
    });
  });
});
