import { NotFoundException } from '@nestjs/common';
import { AccountService } from './account.service';
import { AuthService } from '../auth/auth.service';
import type { AuthUser } from '../auth/auth.types';

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
    Pick<AuthService, 'findUserById' | 'updateUser'>
  >;

  beforeEach(() => {
    authService = {
      findUserById: jest.fn(),
      updateUser: jest.fn(),
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
});
