import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ShareLinkEntity } from '../../database/entities/share-link.entity';
import { UserEntity } from '../../database/entities/user.entity';
import { AuditIncidentService } from './audit-incident.service';
import { RiskContainmentService } from './risk-containment.service';
import { RiskContainmentTargetNotFoundException } from './risk-containment.types';
import type {
  EmergencyAccountSuspendDto,
  EmergencyShareLinkSuspendDto,
  EmergencyActionTimelineQueryDto,
} from './emergency-containment.dto';
import {
  EMERGENCY_ACTION_PREFIX,
  EmergencyActionNoteRequiredException,
} from './emergency-containment.types';
import type {
  EmergencyContainmentResult,
  EmergencyContainmentState,
  EmergencyActionTimelineResult,
  EmergencyAuditRecord,
} from './emergency-containment.types';
import type { AuditActionOutcome } from './audit-incident.types';
import type { RiskContainmentState } from './risk-containment.types';

const DEFAULT_PAGE_LIMIT = 20;
const MAX_PAGE_LIMIT = 100;

@Injectable()
export class EmergencyContainmentService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(ShareLinkEntity)
    private readonly shareLinkRepo: Repository<ShareLinkEntity>,
    private readonly riskContainmentService: RiskContainmentService,
    private readonly auditIncidentService: AuditIncidentService,
  ) {}

  async emergencySuspendAccount(input: {
    actorUserId: string;
    correlationId: string;
    targetUserId: string;
    dto: EmergencyAccountSuspendDto;
  }): Promise<EmergencyContainmentResult> {
    const { actorUserId, correlationId, targetUserId, dto } = input;

    this.assertAuditNote(dto.auditNote);

    const user = await this.userRepo.findOne({ where: { id: targetUserId } });
    if (!user) {
      throw new RiskContainmentTargetNotFoundException('account', targetUserId);
    }

    const result = await this.riskContainmentService.setAccountSuspension({
      actorUserId,
      correlationId,
      targetUserId,
      dto: {
        suspended: dto.suspended,
        rationale: dto.auditNote,
        reasonCode: dto.reasonCode,
      },
    });

    // Record additional emergency-prefixed audit event for dedicated timeline queryability
    const action = dto.suspended
      ? `${EMERGENCY_ACTION_PREFIX}ACCOUNT_SUSPEND`
      : `${EMERGENCY_ACTION_PREFIX}ACCOUNT_UNSUSPEND`;

    await this.auditIncidentService.recordAuditAction({
      actorUserId,
      correlationId,
      dto: {
        action,
        target: `account:${targetUserId}`,
        outcome: toAuditOutcome(result.state),
        reasonCode: dto.reasonCode,
        description: dto.auditNote,
        metadata: {
          targetUserId,
          suspended: dto.suspended,
          changed: result.changed,
          emergencyAction: true,
          auditNoteLength: dto.auditNote.length,
        },
      },
    });

    return {
      state: toEmergencyState(result.state),
      targetType: 'account',
      targetId: targetUserId,
      action,
      changed: result.changed,
      actedAt: result.actedAt,
    };
  }

  async emergencySuspendShareLink(input: {
    actorUserId: string;
    correlationId: string;
    shareLinkId: string;
    dto: EmergencyShareLinkSuspendDto;
  }): Promise<EmergencyContainmentResult> {
    const { actorUserId, correlationId, shareLinkId, dto } = input;

    this.assertAuditNote(dto.auditNote);

    const link = await this.shareLinkRepo.findOne({
      where: { id: shareLinkId },
    });
    if (!link) {
      throw new RiskContainmentTargetNotFoundException(
        'share_link',
        shareLinkId,
      );
    }

    const result = await this.riskContainmentService.setShareLinkSuspension({
      actorUserId,
      correlationId,
      shareLinkId,
      dto: {
        suspended: dto.suspended,
        note: dto.auditNote,
        reasonCode: dto.reasonCode,
      },
    });

    const action = dto.suspended
      ? `${EMERGENCY_ACTION_PREFIX}SHARE_LINK_SUSPEND`
      : `${EMERGENCY_ACTION_PREFIX}SHARE_LINK_UNSUSPEND`;

    await this.auditIncidentService.recordAuditAction({
      actorUserId,
      correlationId,
      dto: {
        action,
        target: `share_link:${shareLinkId}`,
        outcome: toAuditOutcome(result.state),
        reasonCode: dto.reasonCode,
        description: dto.auditNote,
        metadata: {
          shareLinkId,
          suspended: dto.suspended,
          changed: result.changed,
          emergencyAction: true,
          auditNoteLength: dto.auditNote.length,
        },
      },
    });

    return {
      state: toEmergencyState(result.state),
      targetType: 'share_link',
      targetId: shareLinkId,
      action,
      changed: result.changed,
      actedAt: result.actedAt,
    };
  }

  async queryEmergencyTimeline(
    query: EmergencyActionTimelineQueryDto,
  ): Promise<EmergencyActionTimelineResult> {
    const page = query.page ?? 1;
    const limit = Math.min(query.limit ?? DEFAULT_PAGE_LIMIT, MAX_PAGE_LIMIT);

    const target = query.targetUserId
      ? `account:${query.targetUserId}`
      : query.targetShareLinkId
        ? `share_link:${query.targetShareLinkId}`
        : undefined;

    const result = await this.auditIncidentService.searchAuditActions({
      action: EMERGENCY_ACTION_PREFIX,
      target,
      minTimestamp: query.minTimestamp,
      maxTimestamp: query.maxTimestamp,
      page,
      limit,
    });

    return {
      items: result.items.map(
        (r): EmergencyAuditRecord => ({
          id: r.id,
          actorUserId: r.actorUserId,
          action: r.action,
          target: r.target,
          outcome: r.outcome,
          correlationId: r.correlationId,
          auditNote:
            typeof r.metadata?.description === 'string'
              ? r.metadata.description
              : null,
          performedAt: r.performedAt,
          tamperEvidence: r.tamperEvidence,
        }),
      ),
      total: result.total,
      page: result.page,
      limit: result.limit,
    };
  }

  private assertAuditNote(note: string | undefined): void {
    if (!note || note.trim().length < 10) {
      throw new EmergencyActionNoteRequiredException();
    }
  }
}

function toAuditOutcome(state: RiskContainmentState): AuditActionOutcome {
  if (state === 'pending') return 'failure';
  return state;
}

function toEmergencyState(state: RiskContainmentState): EmergencyContainmentState {
  if (state === 'pending') return 'failure';
  return state;
}
