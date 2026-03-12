import type { Request } from 'express';
import type { AuthUser } from '../auth/auth.types';
import type { ConsentStatus } from './consent.types';
import { ConsentController } from './consent.controller';
import { ConsentService } from './consent.service';

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

const mockStatus: ConsentStatus = {
  policies: [
    {
      type: 'terms',
      version: '1.0.0',
      title: 'Terms of Service',
      url: '/legal/terms',
      accepted: false,
      acceptedAt: null,
    },
    {
      type: 'privacy',
      version: '1.0.0',
      title: 'Privacy Policy',
      url: '/legal/privacy',
      accepted: false,
      acceptedAt: null,
    },
  ],
  hasPending: true,
};

describe('ConsentController', () => {
  let controller: ConsentController;
  let consentService: jest.Mocked<
    Pick<ConsentService, 'getStatus' | 'acceptPolicies'>
  >;

  beforeEach(() => {
    consentService = {
      getStatus: jest.fn(),
      acceptPolicies: jest.fn(),
    };
    controller = new ConsentController(
      consentService as unknown as ConsentService,
    );
  });

  describe('getStatus', () => {
    it('delegates to ConsentService.getStatus and wraps in success envelope', async () => {
      consentService.getStatus.mockResolvedValue(mockStatus);
      const result = (await controller.getStatus(makeReq())) as {
        success: boolean;
        data: ConsentStatus;
      };
      expect(result.success).toBe(true);
      expect(result.data).toEqual(mockStatus);
      expect(consentService.getStatus).toHaveBeenCalledWith('user-1');
    });
  });

  describe('accept', () => {
    it('delegates to ConsentService.acceptPolicies and returns updated status', async () => {
      const acceptedStatus: ConsentStatus = {
        ...mockStatus,
        policies: mockStatus.policies.map((p) => ({
          ...p,
          accepted: true,
          acceptedAt: new Date(),
        })),
        hasPending: false,
      };
      consentService.acceptPolicies.mockResolvedValue(acceptedStatus);

      const result = (await controller.accept(
        { policyTypes: ['terms', 'privacy'] },
        makeReq(),
      )) as { success: boolean; data: ConsentStatus };

      expect(result.success).toBe(true);
      expect(result.data.hasPending).toBe(false);
      expect(consentService.acceptPolicies).toHaveBeenCalledWith('user-1', [
        'terms',
        'privacy',
      ]);
    });

    it('propagates unexpected exceptions from service', async () => {
      consentService.acceptPolicies.mockRejectedValue(new Error('unexpected'));
      await expect(
        controller.accept({ policyTypes: ['terms'] }, makeReq()),
      ).rejects.toThrow(Error);
    });
  });
});
