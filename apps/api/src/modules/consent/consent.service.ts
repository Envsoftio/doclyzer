import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConsentRecordEntity } from '../../database/entities/consent-record.entity';
import type {
  ConsentStatus,
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

  constructor(
    @InjectRepository(ConsentRecordEntity)
    private readonly consentRepo: Repository<ConsentRecordEntity>,
  ) {}

  async getStatus(userId: string): Promise<ConsentStatus> {
    const records = await this.consentRepo.find({ where: { userId } });

    const policies: PolicyStatusItem[] = ConsentService.CURRENT_POLICIES.map(
      (def) => {
        const record = records.find(
          (r) => r.policyType === def.type && r.policyVersion === def.version,
        );
        const accepted = record !== undefined;
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

    return { policies, hasPending: policies.some((p) => !p.accepted) };
  }

  async acceptPolicies(
    userId: string,
    policyTypes: string[],
  ): Promise<ConsentStatus> {
    for (const policyType of policyTypes) {
      const def = ConsentService.CURRENT_POLICIES.find(
        (p) => p.type === policyType,
      );
      if (!def) continue;

      const existing = await this.consentRepo.findOne({
        where: { userId, policyType: def.type },
      });

      if (existing) {
        await this.consentRepo.update(existing.id, {
          policyVersion: def.version,
          acceptedAt: new Date(),
        });
      } else {
        await this.consentRepo.save(
          this.consentRepo.create({
            userId,
            policyType: def.type,
            policyVersion: def.version,
            acceptedAt: new Date(),
          }),
        );
      }
    }

    return this.getStatus(userId);
  }
}
