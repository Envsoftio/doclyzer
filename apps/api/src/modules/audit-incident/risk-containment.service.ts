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
  SetShareLinkSuspensionDto,
} from './risk-containment.dto';
import type { RiskContainmentResult } from './risk-containment.types';
import { RiskContainmentTargetNotFoundException } from './risk-containment.types';

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
        rationale: dto.rationale ?? null,
        nextSteps: dto.nextSteps ?? null,
      });
    } else {
      restriction.isRestricted = nextRestricted;
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
}
