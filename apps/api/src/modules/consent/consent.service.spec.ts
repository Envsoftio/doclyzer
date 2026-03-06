import { Repository } from 'typeorm';
import { ConsentRecordEntity } from '../../database/entities/consent-record.entity';
import { ConsentService } from './consent.service';

function makeRepo(overrides: Partial<Record<keyof Repository<ConsentRecordEntity>, jest.Mock>> = {}) {
  return {
    find: jest.fn().mockResolvedValue([]),
    findOne: jest.fn().mockResolvedValue(null),
    create: jest.fn((dto) => dto),
    save: jest.fn().mockResolvedValue(undefined),
    update: jest.fn().mockResolvedValue(undefined),
    ...overrides,
  } as unknown as Repository<ConsentRecordEntity>;
}

describe('ConsentService', () => {
  let service: ConsentService;
  let repo: ReturnType<typeof makeRepo>;

  beforeEach(() => {
    repo = makeRepo();
    service = new ConsentService(repo as unknown as Repository<ConsentRecordEntity>);
  });

  describe('getStatus', () => {
    it('returns all policies not accepted and hasPending true for new user', async () => {
      const status = await service.getStatus('user-1');
      expect(status.hasPending).toBe(true);
      expect(status.policies).toHaveLength(2);
      for (const policy of status.policies) {
        expect(policy.accepted).toBe(false);
        expect(policy.acceptedAt).toBeNull();
      }
    });
  });

  describe('acceptPolicies', () => {
    it('accepting terms and privacy → hasPending false', async () => {
      const records: ConsentRecordEntity[] = [];
      (repo.find as jest.Mock).mockImplementation(async () => records);
      (repo.findOne as jest.Mock).mockImplementation(async ({ where }: { where: { policyType: string } }) =>
        records.find((r) => r.policyType === where.policyType) ?? null,
      );
      (repo.save as jest.Mock).mockImplementation(async (r) => { records.push(r as ConsentRecordEntity); return r; });

      await service.acceptPolicies('user-1', ['terms', 'privacy']);
      const status = await service.getStatus('user-1');
      expect(status.hasPending).toBe(false);
      for (const policy of status.policies) {
        expect(policy.accepted).toBe(true);
      }
    });

    it('accepting terms only → privacy still pending', async () => {
      const records: ConsentRecordEntity[] = [];
      (repo.find as jest.Mock).mockImplementation(async () => records);
      (repo.findOne as jest.Mock).mockImplementation(async () => null);
      (repo.save as jest.Mock).mockImplementation(async (r) => { records.push(r as ConsentRecordEntity); return r; });

      await service.acceptPolicies('user-1', ['terms']);
      const status = await service.getStatus('user-1');
      expect(status.hasPending).toBe(true);
      const terms = status.policies.find((p) => p.type === 'terms')!;
      const privacy = status.policies.find((p) => p.type === 'privacy')!;
      expect(terms.accepted).toBe(true);
      expect(privacy.accepted).toBe(false);
    });

    it('acceptance record stores correct policyType and version', async () => {
      const records: ConsentRecordEntity[] = [];
      (repo.find as jest.Mock).mockImplementation(async () => records);
      (repo.findOne as jest.Mock).mockImplementation(async () => null);
      (repo.save as jest.Mock).mockImplementation(async (r) => {
        const record = { ...(r as ConsentRecordEntity), acceptedAt: new Date() };
        records.push(record);
        return record;
      });

      const before = new Date();
      await service.acceptPolicies('user-2', ['terms']);
      const after = new Date();
      const status = await service.getStatus('user-2');
      const terms = status.policies.find((p) => p.type === 'terms')!;
      expect(terms.accepted).toBe(true);
      expect(terms.acceptedAt).not.toBeNull();
      expect(terms.acceptedAt!.getTime()).toBeGreaterThanOrEqual(before.getTime());
      expect(terms.acceptedAt!.getTime()).toBeLessThanOrEqual(after.getTime());
      expect(terms.version).toBe('1.0.0');
    });

    it('re-accepting a policy updates the existing record', async () => {
      const records: ConsentRecordEntity[] = [];
      (repo.find as jest.Mock).mockImplementation(async () => records);
      (repo.findOne as jest.Mock).mockImplementation(async () =>
        records.find((r) => r.policyType === 'terms') ?? null,
      );
      (repo.save as jest.Mock).mockImplementation(async (r) => { records.push(r as ConsentRecordEntity); return r; });
      (repo.update as jest.Mock).mockImplementation(async (_id: string, patch: Partial<ConsentRecordEntity>) => {
        const idx = records.findIndex((r) => r.policyType === 'terms');
        if (idx !== -1) Object.assign(records[idx], patch);
      });

      await service.acceptPolicies('user-3', ['terms']);
      const first = (await service.getStatus('user-3')).policies.find((p) => p.type === 'terms')!.acceptedAt;

      await service.acceptPolicies('user-3', ['terms']);
      const second = (await service.getStatus('user-3')).policies.find((p) => p.type === 'terms')!.acceptedAt;

      expect(second!.getTime()).toBeGreaterThanOrEqual(first!.getTime());
    });
  });

  describe('version mismatch', () => {
    it('accepted 1.0.0 but current bumped to 1.1.0 → accepted: false', async () => {
      const records: ConsentRecordEntity[] = [
        { id: 'r1', userId: 'user-4', policyType: 'terms', policyVersion: '1.0.0', acceptedAt: new Date() } as ConsentRecordEntity,
        { id: 'r2', userId: 'user-4', policyType: 'privacy', policyVersion: '1.0.0', acceptedAt: new Date() } as ConsentRecordEntity,
      ];
      (repo.find as jest.Mock).mockResolvedValue(records);

      const originalTerms = ConsentService.CURRENT_POLICIES[0];
      ConsentService.CURRENT_POLICIES[0] = { ...originalTerms, version: '1.1.0' };

      try {
        const status = await service.getStatus('user-4');
        const terms = status.policies.find((p) => p.type === 'terms')!;
        expect(terms.accepted).toBe(false);
        expect(status.hasPending).toBe(true);
      } finally {
        ConsentService.CURRENT_POLICIES[0] = originalTerms;
      }
    });
  });
});
