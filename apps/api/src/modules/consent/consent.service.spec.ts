import { ConsentService } from './consent.service';

describe('ConsentService', () => {
  let service: ConsentService;

  beforeEach(() => {
    service = new ConsentService();
  });

  describe('getStatus', () => {
    it('returns all policies not accepted and hasPending true for new user', () => {
      const status = service.getStatus('user-1');
      expect(status.hasPending).toBe(true);
      expect(status.policies).toHaveLength(2);
      for (const policy of status.policies) {
        expect(policy.accepted).toBe(false);
        expect(policy.acceptedAt).toBeNull();
      }
    });
  });

  describe('acceptPolicies', () => {
    it('accepting terms and privacy → hasPending false', () => {
      service.acceptPolicies('user-1', ['terms', 'privacy']);
      const status = service.getStatus('user-1');
      expect(status.hasPending).toBe(false);
      for (const policy of status.policies) {
        expect(policy.accepted).toBe(true);
      }
    });

    it('accepting terms only → privacy still pending', () => {
      service.acceptPolicies('user-1', ['terms']);
      const status = service.getStatus('user-1');
      expect(status.hasPending).toBe(true);
      const terms = status.policies.find((p) => p.type === 'terms')!;
      const privacy = status.policies.find((p) => p.type === 'privacy')!;
      expect(terms.accepted).toBe(true);
      expect(privacy.accepted).toBe(false);
    });

    it('acceptance record stores correct userId, policyType, version, acceptedAt', () => {
      const before = new Date();
      service.acceptPolicies('user-2', ['terms']);
      const after = new Date();
      const status = service.getStatus('user-2');
      const terms = status.policies.find((p) => p.type === 'terms')!;
      expect(terms.accepted).toBe(true);
      expect(terms.acceptedAt).not.toBeNull();
      expect(terms.acceptedAt!.getTime()).toBeGreaterThanOrEqual(
        before.getTime(),
      );
      expect(terms.acceptedAt!.getTime()).toBeLessThanOrEqual(after.getTime());
      expect(terms.version).toBe('1.0.0');
    });

    it('re-accepting a policy replaces the previous acceptedAt', () => {
      service.acceptPolicies('user-3', ['terms']);
      const first = service
        .getStatus('user-3')
        .policies.find((p) => p.type === 'terms')!.acceptedAt;

      service.acceptPolicies('user-3', ['terms']);
      const second = service
        .getStatus('user-3')
        .policies.find((p) => p.type === 'terms')!.acceptedAt;

      expect(second!.getTime()).toBeGreaterThanOrEqual(first!.getTime());
    });
  });

  describe('version mismatch', () => {
    it('accepted 1.0.0 but current bumped to 1.1.0 → accepted: false', () => {
      service.acceptPolicies('user-4', ['terms', 'privacy']);

      // Replace the array element rather than mutating its properties so
      // the original object is preserved and restored atomically.
      const originalTerms = ConsentService.CURRENT_POLICIES[0];
      ConsentService.CURRENT_POLICIES[0] = {
        ...originalTerms,
        version: '1.1.0',
      };

      try {
        const status = service.getStatus('user-4');
        const terms = status.policies.find((p) => p.type === 'terms')!;
        expect(terms.accepted).toBe(false);
        expect(status.hasPending).toBe(true);
      } finally {
        ConsentService.CURRENT_POLICIES[0] = originalTerms;
      }
    });
  });
});
