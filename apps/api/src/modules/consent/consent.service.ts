import { Injectable } from '@nestjs/common';
import type {
  ConsentStatus,
  PolicyAcceptanceRecord,
  PolicyDefinition,
  PolicyStatusItem,
} from './consent.types';

@Injectable()
export class ConsentService {
  static readonly CURRENT_POLICIES: PolicyDefinition[] = [
    {
      type: 'terms',
      version: '1.0.0',
      title: 'Terms of Service',
      url: '/legal/terms',
    },
    {
      type: 'privacy',
      version: '1.0.0',
      title: 'Privacy Policy',
      url: '/legal/privacy',
    },
  ];

  private readonly acceptances = new Map<string, PolicyAcceptanceRecord>();

  getStatus(userId: string): ConsentStatus {
    const policies: PolicyStatusItem[] = ConsentService.CURRENT_POLICIES.map(
      (def) => {
        const key = `${userId}:${def.type}`;
        const record = this.acceptances.get(key);
        const accepted = record !== undefined && record.version === def.version;
        return {
          type: def.type,
          version: def.version,
          title: def.title,
          url: def.url,
          accepted,
          acceptedAt: accepted ? record.acceptedAt : null,
        };
      },
    );

    return {
      policies,
      hasPending: policies.some((p) => !p.accepted),
    };
  }

  acceptPolicies(userId: string, policyTypes: string[]): ConsentStatus {
    for (const policyType of policyTypes) {
      const def = ConsentService.CURRENT_POLICIES.find(
        (p) => p.type === policyType,
      );
      if (!def) continue;

      const key = `${userId}:${policyType}`;
      this.acceptances.set(key, {
        userId,
        policyType: def.type,
        version: def.version,
        acceptedAt: new Date(),
      });
    }

    return this.getStatus(userId);
  }
}
