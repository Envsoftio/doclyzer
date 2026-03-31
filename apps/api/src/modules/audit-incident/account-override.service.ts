import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AccountOverrideEntity } from '../../database/entities/account-override.entity';
import { UserEntity } from '../../database/entities/user.entity';
import { ACCOUNT_SUSPENDED_RESTRICTED_ACTIONS } from '../../common/restriction/restriction.constants';
import { AuditIncidentService } from './audit-incident.service';
import type {
  CreateAccountOverrideDto,
  RevokeAccountOverrideDto,
} from './account-override.dto';
import type {
  AccountOverrideRecord,
  AccountOverrideListResult,
  AccountOverrideActionResult,
} from './account-override.types';
import {
  AccountOverrideNotFoundException,
  AccountOverrideInvalidExpiryException,
  AccountOverrideInvalidActionsException,
} from './account-override.types';
import { RiskContainmentTargetNotFoundException } from './risk-containment.types';

// All valid overrideable actions. Overrides must target a subset of these.
const OVERRIDEABLE_ACTIONS: ReadonlySet<string> = new Set(
  ACCOUNT_SUSPENDED_RESTRICTED_ACTIONS,
);

@Injectable()
export class AccountOverrideService {
  constructor(
    @InjectRepository(AccountOverrideEntity)
    private readonly overrideRepo: Repository<AccountOverrideEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    private readonly auditIncidentService: AuditIncidentService,
  ) {}

  async createOverride(input: {
    actorUserId: string;
    correlationId: string;
    targetUserId: string;
    dto: CreateAccountOverrideDto;
  }): Promise<AccountOverrideActionResult> {
    const { actorUserId, correlationId, targetUserId, dto } = input;

    const user = await this.userRepo.findOne({ where: { id: targetUserId } });
    if (!user) {
      throw new RiskContainmentTargetNotFoundException('account', targetUserId);
    }

    // Validate all requested actions are overrideable
    const invalidActions = dto.overriddenActions.filter(
      (a) => !OVERRIDEABLE_ACTIONS.has(a),
    );
    if (invalidActions.length > 0) {
      throw new AccountOverrideInvalidActionsException(
        `Unknown actions: ${invalidActions.join(', ')}. Valid actions: ${[...OVERRIDEABLE_ACTIONS].join(', ')}`,
      );
    }

    const expiresAt = new Date(dto.expiresAt);
    if (isNaN(expiresAt.getTime())) {
      throw new AccountOverrideInvalidExpiryException(
        'expiresAt must be a valid ISO datetime',
      );
    }
    if (expiresAt.getTime() <= Date.now()) {
      throw new AccountOverrideInvalidExpiryException(
        'expiresAt must be in the future',
      );
    }

    const entity = this.overrideRepo.create({
      userId: targetUserId,
      overriddenActions: dto.overriddenActions,
      expiresAt,
      isActive: true,
      reason: dto.reason ?? null,
      createdByUserId: actorUserId,
      revokedAt: null,
      revokedByUserId: null,
      revokedReason: null,
    });
    const saved = await this.overrideRepo.save(entity);

    const actedAt = new Date().toISOString();
    await this.auditIncidentService.recordAuditAction({
      actorUserId,
      correlationId,
      dto: {
        action: 'ACCOUNT_OVERRIDE_CREATED',
        target: `account:${targetUserId}`,
        outcome: 'success',
        description: dto.reason,
        metadata: {
          overrideId: saved.id,
          targetUserId,
          overriddenActions: dto.overriddenActions.join(','),
          expiresAt: expiresAt.toISOString(),
          reasonProvided: Boolean(dto.reason),
        },
      },
    });

    return {
      state: 'success',
      overrideId: saved.id,
      userId: targetUserId,
      changed: true,
      actedAt,
    };
  }

  async listOverrides(targetUserId: string): Promise<AccountOverrideListResult> {
    const entities = await this.overrideRepo.find({
      where: { userId: targetUserId },
      order: { createdAt: 'DESC' },
    });
    return { overrides: entities.map((e) => this.toRecord(e)) };
  }

  async revokeOverride(input: {
    actorUserId: string;
    correlationId: string;
    targetUserId: string;
    dto: RevokeAccountOverrideDto;
  }): Promise<AccountOverrideActionResult> {
    const { actorUserId, correlationId, targetUserId, dto } = input;

    const entity = await this.overrideRepo.findOne({
      where: { id: dto.overrideId, userId: targetUserId },
    });
    if (!entity) {
      throw new AccountOverrideNotFoundException(dto.overrideId);
    }

    const actedAt = new Date().toISOString();

    // Idempotent: if already inactive, return reverted without side effects
    if (!entity.isActive) {
      await this.auditIncidentService.recordAuditAction({
        actorUserId,
        correlationId,
        dto: {
          action: 'ACCOUNT_OVERRIDE_REVOKE_NOOP',
          target: `account:${targetUserId}`,
          outcome: 'reverted',
          description: 'Override was already inactive',
          metadata: {
            overrideId: entity.id,
            targetUserId,
            alreadyInactive: true,
          },
        },
      });
      return {
        state: 'reverted',
        overrideId: entity.id,
        userId: targetUserId,
        changed: false,
        actedAt,
      };
    }

    entity.isActive = false;
    entity.revokedAt = new Date(actedAt);
    entity.revokedByUserId = actorUserId;
    entity.revokedReason = dto.revokedReason ?? null;
    await this.overrideRepo.save(entity);

    await this.auditIncidentService.recordAuditAction({
      actorUserId,
      correlationId,
      dto: {
        action: 'ACCOUNT_OVERRIDE_REVOKED',
        target: `account:${targetUserId}`,
        outcome: 'reverted',
        description: dto.revokedReason ?? 'Manual early revocation',
        metadata: {
          overrideId: entity.id,
          targetUserId,
          overriddenActions: entity.overriddenActions.join(','),
          revokedReasonProvided: Boolean(dto.revokedReason),
        },
      },
    });

    return {
      state: 'reverted',
      overrideId: entity.id,
      userId: targetUserId,
      changed: true,
      actedAt,
    };
  }

  /**
   * Returns currently active (non-expired) overrides for a user.
   * Auto-reverts any overrides whose expiresAt has passed (idempotent:
   * only processes isActive=true rows, so re-running produces no duplicates).
   */
  async evaluateActiveOverrides(
    userId: string,
  ): Promise<{ overriddenActions: string[]; overrides: AccountOverrideRecord[] }> {
    const activeEntities = await this.overrideRepo.find({
      where: { userId, isActive: true },
    });

    const now = Date.now();
    const stillActive: AccountOverrideEntity[] = [];

    for (const entity of activeEntities) {
      if (entity.expiresAt.getTime() <= now) {
        // Auto-revert expired override — log outcome
        entity.isActive = false;
        entity.revokedAt = new Date();
        entity.revokedReason = 'auto_expired';
        await this.overrideRepo.save(entity);

        // Use a system-level audit entry (actorUserId = createdByUserId for traceability)
        await this.auditIncidentService.recordAuditAction({
          actorUserId: entity.createdByUserId ?? entity.userId,
          correlationId: `auto-expire-${entity.id}`,
          dto: {
            action: 'ACCOUNT_OVERRIDE_EXPIRED',
            target: `account:${userId}`,
            outcome: 'reverted',
            description: 'Override auto-reverted on expiry',
            metadata: {
              overrideId: entity.id,
              targetUserId: userId,
              overriddenActions: entity.overriddenActions.join(','),
              expiredAt: entity.expiresAt.toISOString(),
            },
          },
        });
      } else {
        stillActive.push(entity);
      }
    }

    // Collect the union of all overridden actions from still-active overrides
    const overriddenActionsSet = new Set<string>();
    for (const entity of stillActive) {
      for (const action of entity.overriddenActions) {
        overriddenActionsSet.add(action);
      }
    }

    return {
      overriddenActions: [...overriddenActionsSet],
      overrides: stillActive.map((e) => this.toRecord(e)),
    };
  }

  private toRecord(entity: AccountOverrideEntity): AccountOverrideRecord {
    return {
      id: entity.id,
      userId: entity.userId,
      overriddenActions: entity.overriddenActions,
      expiresAt: entity.expiresAt.toISOString(),
      isActive: entity.isActive,
      reason: entity.reason,
      createdByUserId: entity.createdByUserId,
      revokedAt: entity.revokedAt?.toISOString() ?? null,
      revokedByUserId: entity.revokedByUserId,
      revokedReason: entity.revokedReason,
      createdAt: entity.createdAt.toISOString(),
      updatedAt: entity.updatedAt.toISOString(),
    };
  }
}
