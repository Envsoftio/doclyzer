import { NotFoundException } from '@nestjs/common';
import type { Request } from 'express';
import { AccountController } from './account.controller';
import { AccountService } from './account.service';
import type { AuthUser } from '../auth/auth.types';
import type { AccountProfile } from './account.types';

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
  let accountService: jest.Mocked<Pick<AccountService, 'getProfile' | 'updateProfile'>>;

  beforeEach(() => {
    accountService = {
      getProfile: jest.fn(),
      updateProfile: jest.fn(),
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
        throw new NotFoundException({ code: 'ACCOUNT_NOT_FOUND', message: 'Account not found' });
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
        throw new NotFoundException({ code: 'ACCOUNT_NOT_FOUND', message: 'Account not found' });
      });
      expect(() =>
        controller.updateProfile({ displayName: 'X' }, makeReq()),
      ).toThrow(NotFoundException);
    });
  });
});
