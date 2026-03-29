import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ShareLinkEntity } from '../../database/entities/share-link.entity';
import { RestrictionEntity } from '../../database/entities/restriction.entity';
import { UserEntity } from '../../database/entities/user.entity';
import { AuthService } from '../auth/auth.service';
import { AuditIncidentService } from './audit-incident.service';
import type {
  SetAccountSuspensionDto,
  SetAccountRestrictionDto,
  SetShareLinkSuspensionDto,
} from './risk-containment.dto';
import type { RiskContainmentResult } from './risk-containment.types';
import {
  RiskContainmentInvalidStateTransitionException,
  RiskContainmentTargetNotFoundException,
} from './risk-containment.types';

@Injectable()
export class RiskContainmentService {
  constructor(
    @InjectRepository(ShareLinkEntity)
    private readonly shareLinkRepo: Repository<ShareLinkEntity>,
    @InjectRepository(RestrictionEntity)
    private readonly restrictionRepo: Repository<RestrictionEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    private readonly authService: AuthService,
    private readonly auditIncidentService: AuditIncidentService,
  ) {}

  async setShareLinkSuspension(input: {
    actorUserId: string;
    correlationId: string;
    shareLinkId: string;
    dto: SetShareLinkSuspensionDto;
  }): Promise<RiskContainmentResult> {
    const { actorUserId, correlationId, shareLinkId, dto } = input;
    const link = await this.shareLinkRepo.findOne({
      where: { id: shareLinkId },
    });
    if (!link) {
      throw new RiskContainmentTargetNotFoundException(
        'share_link',
        shareLinkId,
      );
    }

    const nextIsActive = !dto.suspended;
    const changed = link.isActive !== nextIsActive;
    if (changed) {
      link.isActive = nextIsActive;
      await this.shareLinkRepo.save(link);
    }

    const actedAt = new Date().toISOString();
    const state = dto.suspended ? 'success' : 'reverted';
    await this.auditIncidentService.recordAuditAction({
      actorUserId,
      correlationId,
      dto: {
        action: dto.suspended ? 'SHARE_LINK_SUSPENDED' : 'SHARE_LINK_RESTORED',
        target: `share_link:${link.id}`,
        outcome: state,
        reasonCode: dto.reasonCode,
        description: dto.note,
        metadata: {
          targetType: 'share_link',
          suspended: dto.suspended,
          changed,
          shareLinkId: link.id,
        },
      },
    });

    return {
      state,
      targetType: 'share_link',
      targetId: link.id,
      suspended: dto.suspended,
      changed,
      actedAt,
    };
  }

  async setAccountSuspension(input: {
    actorUserId: string;
    correlationId: string;
    targetUserId: string;
    dto: SetAccountSuspensionDto;
  }): Promise<RiskContainmentResult> {
    const { actorUserId, correlationId, targetUserId, dto } = input;
    const user = await this.userRepo.findOne({ where: { id: targetUserId } });
    if (!user) {
      throw new RiskContainmentTargetNotFoundException('account', targetUserId);
    }
    let restriction = await this.restrictionRepo.findOne({
      where: { userId: targetUserId },
    });
    const nextRestricted = dto.suspended;
    const wasRestricted = restriction?.isRestricted ?? false;
    const changed = wasRestricted !== nextRestricted;

    if (!restriction) {
      restriction = this.restrictionRepo.create({
        userId: targetUserId,
        isRestricted: nextRestricted,
        restrictedReviewMode: false,
        restrictedUntil: null,
        rationale: dto.rationale ?? null,
        nextSteps: dto.nextSteps ?? null,
      });
    } else {
      restriction.isRestricted = nextRestricted;
      restriction.restrictedReviewMode = false;
      restriction.restrictedUntil = null;
      restriction.rationale = nextRestricted ? (dto.rationale ?? null) : null;
      restriction.nextSteps = nextRestricted ? (dto.nextSteps ?? null) : null;
    }
    await this.restrictionRepo.save(restriction);

    if (dto.suspended) {
      await this.authService.revokeAllSessionsForUser(targetUserId);
    }

    const actedAt = new Date().toISOString();
    const state = dto.suspended ? 'success' : 'reverted';
    await this.auditIncidentService.recordAuditAction({
      actorUserId,
      correlationId,
      dto: {
        action: dto.suspended ? 'ACCOUNT_SUSPENDED' : 'ACCOUNT_RESTORED',
        target: `account:${targetUserId}`,
        outcome: state,
        reasonCode: dto.reasonCode,
        description: dto.suspended
          ? dto.rationale
          : 'Account suspension removed',
        metadata: {
          targetType: 'account',
          suspended: dto.suspended,
          changed,
          rationaleProvided: Boolean(dto.rationale),
          nextStepsProvided: Boolean(dto.nextSteps),
        },
      },
    });

    return {
      state,
      targetType: 'account',
      targetId: targetUserId,
      suspended: dto.suspended,
      changed,
      actedAt,
    };
  }

  async setAccountRestriction(input: {
    actorUserId: string;
    correlationId: string;
    targetUserId: string;
    dto: SetAccountRestrictionDto;
  }): Promise<RiskContainmentResult> {
    const { actorUserId, correlationId, targetUserId, dto } = input;
    const user = await this.userRepo.findOne({ where: { id: targetUserId } });
    if (!user) {
      throw new RiskContainmentTargetNotFoundException('account', targetUserId);
    }

    let restrictedUntil: Date | null = null;
    if (dto.restrictedUntil) {
      restrictedUntil = new Date(dto.restrictedUntil);
      if (isNaN(restrictedUntil.getTime())) {
        throw new RiskContainmentInvalidStateTransitionException(
          'restrictedUntil must be a valid ISO datetime',
        );
      }
      if (restrictedUntil.getTime() <= Date.now()) {
        throw new RiskContainmentInvalidStateTransitionException(
          'restrictedUntil must be in the future',
        );
      }
    }

    let restriction = await this.restrictionRepo.findOne({
      where: { userId: targetUserId },
    });

    const nextMode = dto.mode;
    const nextRestricted = nextMode === 'suspended';
    const nextReviewMode = nextMode === 'review';

    const previousMode = restriction?.isRestricted
      ? 'suspended'
      : restriction?.restrictedReviewMode
        ? 'review'
        : 'none';

    if (!restriction && nextMode === 'none') {
      const actedAt = new Date().toISOString();
      await this.auditIncidentService.recordAuditAction({
        actorUserId,
        correlationId,
        dto: {
          action: 'ACCOUNT_RESTRICTION_REMOVED',
          target: `account:${targetUserId}`,
          outcome: 'reverted',
          reasonCode: dto.reasonCode,
          description: 'Account restriction removed',
          metadata: {
            targetType: 'account',
            restrictionMode: nextMode,
            previousMode,
            changed: false,
            restrictedUntil: null,
            rationaleProvided: Boolean(dto.rationale),
            nextStepsProvided: Boolean(dto.nextSteps),
          },
        },
      });
      return {
        state: 'reverted',
        targetType: 'account',
        targetId: targetUserId,
        suspended: false,
        changed: false,
        actedAt,
        restrictionMode: 'none',
        restrictedUntil: null,
      };
    }

    const changed =
      !restriction ||
      restriction.isRestricted !== nextRestricted ||
      restriction.restrictedReviewMode !== nextReviewMode ||
      (restriction.restrictedUntil?.toISOString() ?? null) !==
        (restrictedUntil?.toISOString() ?? null) ||
      (restriction.rationale ?? null) !== (dto.rationale ?? null) ||
      (restriction.nextSteps ?? null) !== (dto.nextSteps ?? null);

    if (!restriction) {
      restriction = this.restrictionRepo.create({
        userId: targetUserId,
        isRestricted: nextRestricted,
        restrictedReviewMode: nextReviewMode,
        restrictedUntil,
        rationale:
          nextMode === 'none' ? null : (dto.rationale ?? null),
        nextSteps:
          nextMode === 'none' ? null : (dto.nextSteps ?? null),
      });
    } else {
      restriction.isRestricted = nextRestricted;
      restriction.restrictedReviewMode = nextReviewMode;
      restriction.restrictedUntil = restrictedUntil;
      restriction.rationale =
        nextMode === 'none' ? null : (dto.rationale ?? null);
      restriction.nextSteps =
        nextMode === 'none' ? null : (dto.nextSteps ?? null);
    }
    await this.restrictionRepo.save(restriction);

    if (nextRestricted) {
      await this.authService.revokeAllSessionsForUser(targetUserId);
    }

    const actedAt = new Date().toISOString();
    const state = nextMode === 'none' ? 'reverted' : 'success';

    await this.auditIncidentService.recordAuditAction({
      actorUserId,
      correlationId,
      dto: {
        action:
          nextMode === 'none'
            ? 'ACCOUNT_RESTRICTION_REMOVED'
            : nextMode === 'review'
              ? 'ACCOUNT_REVIEW_MODE_ENABLED'
              : 'ACCOUNT_RESTRICTION_ENABLED',
        target: `account:${targetUserId}`,
        outcome: state,
        reasonCode: dto.reasonCode,
        description:
          nextMode === 'none'
            ? 'Account restriction removed'
            : dto.rationale,
        metadata: {
          targetType: 'account',
          restrictionMode: nextMode,
          previousMode,
          changed,
          restrictedUntil: restrictedUntil?.toISOString() ?? null,
          rationaleProvided: Boolean(dto.rationale),
          nextStepsProvided: Boolean(dto.nextSteps),
        },
      },
    });

    return {
      state,
      targetType: 'account',
      targetId: targetUserId,
      suspended: nextRestricted,
      changed,
      actedAt,
      restrictionMode: nextMode,
      restrictedUntil: restrictedUntil?.toISOString() ?? null,
    };
  }
}
