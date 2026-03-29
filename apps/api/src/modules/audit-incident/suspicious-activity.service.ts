import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { createHash } from 'node:crypto';
import { DataSource, Repository } from 'typeorm';
import { SuspiciousActivityQueueItemEntity } from '../../database/entities/suspicious-activity-queue-item.entity';
import { AuditIncidentService } from './audit-incident.service';
import type {
  SuspiciousActivityContainmentSuggestion,
  SuspiciousActivityIngestResult,
  SuspiciousActivityQueueItem,
  SuspiciousActivityQueueResult,
  SuspiciousActivitySeverity,
  SuspiciousActivityStatus,
  SuspiciousActivityStatusUpdateResult,
} from './suspicious-activity.types';
import {
  SUSPICIOUS_ACTIVITY_SEVERITIES,
  SUSPICIOUS_ACTIVITY_STATUSES,
  SuspiciousActivityInvalidTransitionException,
  SuspiciousActivityQueueNotFoundException,
} from './suspicious-activity.types';
import type {
  SuspiciousActivityContainmentSuggestionDto,
  SuspiciousActivityIngestDto,
  SuspiciousActivityQueueQueryDto,
  SuspiciousActivityStatusUpdateDto,
} from './suspicious-activity.dto';

const DEFAULT_QUEUE_LIMIT = 50;
const MAX_QUEUE_LIMIT = 100;
const AUTO_CONTAINMENT_THRESHOLD = 85;

const STATUS_TRANSITIONS: Record<SuspiciousActivityStatus, SuspiciousActivityStatus[]> =
  {
    open: ['in_review', 'resolved'],
    in_review: ['open', 'resolved'],
    resolved: [],
  };

const SEVERITY_RANK: Record<SuspiciousActivitySeverity, number> = {
  low: 1,
  medium: 2,
  high: 3,
  critical: 4,
};

@Injectable()
export class SuspiciousActivityService {
  constructor(
    @InjectRepository(SuspiciousActivityQueueItemEntity)
    private readonly queueRepo: Repository<SuspiciousActivityQueueItemEntity>,
    private readonly dataSource: DataSource,
    private readonly auditIncidentService: AuditIncidentService,
  ) {}

  async ingestSignal(input: {
    actorUserId: string;
    correlationId: string;
    dto: SuspiciousActivityIngestDto;
  }): Promise<SuspiciousActivityIngestResult> {
    const detectedAt = input.dto.detectedAt
      ? new Date(input.dto.detectedAt)
      : new Date();
    const dedupeKey = this.buildDedupeKey(input.dto);
    const initialSuggestion = this.resolveSuggestion(input.dto);

    const { entity, action } = await this.dataSource.transaction(
      async (manager) => {
        const repo = manager.getRepository(SuspiciousActivityQueueItemEntity);

        if (input.dto.idempotencyKey) {
          const existingByKey = await repo.findOne({
            where: { idempotencyKey: input.dto.idempotencyKey },
          });
          if (existingByKey) {
            return { entity: existingByKey, action: 'deduped' as const };
          }
        }

        const existing = await repo
          .createQueryBuilder('queue')
          .setLock('pessimistic_write')
          .where('queue.dedupe_key = :dedupeKey', { dedupeKey })
          .andWhere('queue.status IN (:...statuses)', {
            statuses: ['open', 'in_review'],
          })
          .orderBy('queue.last_detected_at', 'DESC')
          .getOne();

        if (existing) {
          const updated = this.applyDedupeUpdate({
            entity: existing,
            incoming: input.dto,
            detectedAt,
            suggestion: initialSuggestion,
          });
          const saved = await repo.save(updated);
          return { entity: saved, action: 'deduped' as const };
        }

        const created = repo.create({
          targetType: input.dto.targetType,
          targetId: input.dto.targetId,
          signalType: input.dto.signalType,
          ruleCode: input.dto.ruleCode,
          severity: input.dto.severity,
          status: 'open',
          confidenceScore: input.dto.confidenceScore,
          detectionSummary: input.dto.detectionSummary ?? null,
          detectionCount: 1,
          firstDetectedAt: detectedAt,
          lastDetectedAt: detectedAt,
          suggestedContainment: initialSuggestion,
          dedupeKey,
          idempotencyKey: input.dto.idempotencyKey ?? null,
          metadata: input.dto.metadata ?? null,
          reviewedAt: null,
          resolvedAt: null,
          resolutionNotes: null,
        });
        const saved = await repo.save(created);
        return { entity: saved, action: 'created' as const };
      },
    );

    await this.recordAudit({
      actorUserId: input.actorUserId,
      correlationId: input.correlationId,
      action:
        action === 'created'
          ? 'SUSPICIOUS_ACTIVITY_SIGNAL_INGESTED'
          : 'SUSPICIOUS_ACTIVITY_SIGNAL_DEDUPED',
      target: `${entity.targetType}:${entity.targetId}`,
      outcome: 'success',
      metadata: {
        queueItemId: entity.id,
        ruleCode: entity.ruleCode,
        signalType: entity.signalType,
        severity: entity.severity,
        status: entity.status,
        detectionCount: entity.detectionCount,
        suggestedContainment: Boolean(entity.suggestedContainment),
      },
    });

    return {
      state: 'success',
      action,
      item: this.mapQueueItem(entity),
    };
  }

  async listQueue(
    query: SuspiciousActivityQueueQueryDto,
  ): Promise<SuspiciousActivityQueueResult> {
    const page = query.page ?? 1;
    const limit = Math.min(query.limit ?? DEFAULT_QUEUE_LIMIT, MAX_QUEUE_LIMIT);

    const qb = this.queueRepo.createQueryBuilder('queue');
    if (query.status) {
      qb.andWhere('queue.status = :status', { status: query.status });
    }
    if (query.severity) {
      qb.andWhere('queue.severity = :severity', { severity: query.severity });
    }
    if (query.targetType) {
      qb.andWhere('queue.target_type = :targetType', {
        targetType: query.targetType,
      });
    }
    if (query.targetId) {
      qb.andWhere('queue.target_id = :targetId', { targetId: query.targetId });
    }
    if (query.ruleCode) {
      qb.andWhere('queue.rule_code = :ruleCode', { ruleCode: query.ruleCode });
    }
    if (query.minConfidence !== undefined) {
      qb.andWhere('queue.confidence_score >= :minConfidence', {
        minConfidence: query.minConfidence,
      });
    }
    if (query.minDetectedAt) {
      qb.andWhere('queue.last_detected_at >= :minDetectedAt', {
        minDetectedAt: new Date(query.minDetectedAt).toISOString(),
      });
    }
    if (query.maxDetectedAt) {
      qb.andWhere('queue.last_detected_at <= :maxDetectedAt', {
        maxDetectedAt: new Date(query.maxDetectedAt).toISOString(),
      });
    }

    const [items, total] = await qb
      .orderBy('queue.last_detected_at', 'DESC')
      .addOrderBy('queue.created_at', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getManyAndCount();

    return {
      state: 'success',
      items: items.map((item) => this.mapQueueItem(item)),
      page,
      limit,
      total,
    };
  }

  async updateStatus(input: {
    actorUserId: string;
    correlationId: string;
    queueItemId: string;
    dto: SuspiciousActivityStatusUpdateDto;
  }): Promise<SuspiciousActivityStatusUpdateResult> {
    const entity = await this.queueRepo.findOne({
      where: { id: input.queueItemId },
    });

    if (!entity) {
      throw new SuspiciousActivityQueueNotFoundException();
    }

    if (entity.status === input.dto.status) {
      await this.recordAudit({
        actorUserId: input.actorUserId,
        correlationId: input.correlationId,
        action: 'SUSPICIOUS_ACTIVITY_STATUS_UPDATE',
        target: `queue:${entity.id}`,
        outcome: 'success',
        metadata: {
          fromStatus: entity.status,
          toStatus: input.dto.status,
          noOp: true,
        },
      });

      return {
        state: 'success',
        item: this.mapQueueItem(entity),
      };
    }

    if (!this.canTransition(entity.status, input.dto.status)) {
      throw new SuspiciousActivityInvalidTransitionException(
        `Cannot transition from ${entity.status} to ${input.dto.status}`,
      );
    }

    const now = new Date();
    const previousStatus = entity.status;
    entity.status = input.dto.status as SuspiciousActivityStatus;
    if (entity.status === 'in_review') {
      entity.reviewedAt = now;
      entity.resolvedAt = null;
    }
    if (entity.status === 'resolved') {
      entity.resolvedAt = now;
    }
    if (entity.status === 'open') {
      entity.resolvedAt = null;
    }
    if (input.dto.notes) {
      entity.resolutionNotes = input.dto.notes;
    }

    const saved = await this.queueRepo.save(entity);

    await this.recordAudit({
      actorUserId: input.actorUserId,
      correlationId: input.correlationId,
      action: 'SUSPICIOUS_ACTIVITY_STATUS_UPDATE',
      target: `queue:${entity.id}`,
      outcome: 'success',
      metadata: {
        fromStatus: previousStatus,
        toStatus: entity.status,
        severity: entity.severity,
        ruleCode: entity.ruleCode,
        notesPresent: Boolean(input.dto.notes),
      },
    });

    return {
      state: 'success',
      item: this.mapQueueItem(saved),
    };
  }

  private applyDedupeUpdate(input: {
    entity: SuspiciousActivityQueueItemEntity;
    incoming: SuspiciousActivityIngestDto;
    detectedAt: Date;
    suggestion: SuspiciousActivityContainmentSuggestion | null;
  }): SuspiciousActivityQueueItemEntity {
    const { entity, incoming, detectedAt, suggestion } = input;
    entity.detectionCount += 1;
    entity.lastDetectedAt = detectedAt;
    entity.confidenceScore = Math.max(
      entity.confidenceScore,
      incoming.confidenceScore,
    );
    entity.severity = this.pickHigherSeverity(entity.severity, incoming.severity);
    if (!entity.detectionSummary && incoming.detectionSummary) {
      entity.detectionSummary = incoming.detectionSummary;
    }
    if (!entity.metadata && incoming.metadata) {
      entity.metadata = incoming.metadata;
    }
    if (suggestion) {
      entity.suggestedContainment = this.pickStrongerSuggestion(
        entity.suggestedContainment,
        suggestion,
      );
    }
    return entity;
  }

  private pickHigherSeverity(
    current: SuspiciousActivitySeverity,
    incoming: string,
  ): SuspiciousActivitySeverity {
    if (!this.isSeverity(incoming)) {
      return current;
    }
    return SEVERITY_RANK[incoming] > SEVERITY_RANK[current]
      ? incoming
      : current;
  }

  private pickStrongerSuggestion(
    existing: Record<string, string | number | boolean> | null,
    incoming: SuspiciousActivityContainmentSuggestion,
  ): Record<string, string | number | boolean> {
    if (!existing) {
      return incoming;
    }
    const existingScore = Number(existing.confidenceScore ?? 0);
    if (incoming.confidenceScore >= existingScore) {
      return incoming;
    }
    return existing;
  }

  private resolveSuggestion(
    dto: SuspiciousActivityIngestDto,
  ): SuspiciousActivityContainmentSuggestion | null {
    if (dto.suggestedContainment) {
      return this.normalizeSuggestion(dto.suggestedContainment, dto.confidenceScore);
    }
    if (dto.confidenceScore < AUTO_CONTAINMENT_THRESHOLD) {
      return null;
    }
    const action = this.autoSuggestAction(dto.targetType);
    return {
      action,
      reason: 'Confidence threshold exceeded for optional containment suggestion.',
      confidenceScore: dto.confidenceScore,
      autoApplied: false,
    };
  }

  private normalizeSuggestion(
    suggestion: SuspiciousActivityContainmentSuggestionDto,
    fallbackConfidence: number,
  ): SuspiciousActivityContainmentSuggestion {
    return {
      action: suggestion.action,
      reason: suggestion.reason ?? 'Suggested by detection rules.',
      confidenceScore: suggestion.confidenceScore ?? fallbackConfidence,
      autoApplied: false,
    };
  }

  private autoSuggestAction(targetType: string): SuspiciousActivityContainmentSuggestion['action'] {
    const normalized = targetType.trim().toLowerCase();
    if (normalized === 'account' || normalized === 'user') {
      return 'suspend_account';
    }
    if (normalized === 'share_link' || normalized === 'share-link') {
      return 'suspend_share_link';
    }
    return 'require_mfa';
  }

  private buildDedupeKey(dto: SuspiciousActivityIngestDto): string {
    const payload = `${dto.targetType}:${dto.targetId}:${dto.ruleCode}`;
    return createHash('sha256').update(payload).digest('hex');
  }

  private canTransition(
    current: SuspiciousActivityStatus,
    next: string,
  ): boolean {
    if (!this.isStatus(next)) {
      return false;
    }
    return STATUS_TRANSITIONS[current].includes(next);
  }

  private isStatus(value: string): value is SuspiciousActivityStatus {
    return SUSPICIOUS_ACTIVITY_STATUSES.includes(value as SuspiciousActivityStatus);
  }

  private isSeverity(value: string): value is SuspiciousActivitySeverity {
    return SUSPICIOUS_ACTIVITY_SEVERITIES.includes(
      value as SuspiciousActivitySeverity,
    );
  }

  private mapQueueItem(
    entity: SuspiciousActivityQueueItemEntity,
  ): SuspiciousActivityQueueItem {
    return {
      id: entity.id,
      targetType: entity.targetType,
      targetId: entity.targetId,
      signalType: entity.signalType,
      ruleCode: entity.ruleCode,
      severity: entity.severity,
      status: entity.status,
      confidenceScore: entity.confidenceScore,
      detectionSummary: entity.detectionSummary,
      detectionCount: entity.detectionCount,
      firstDetectedAt: entity.firstDetectedAt.toISOString(),
      lastDetectedAt: entity.lastDetectedAt.toISOString(),
      suggestedContainment:
        (entity.suggestedContainment as SuspiciousActivityContainmentSuggestion | null) ??
        null,
      metadata: entity.metadata,
      reviewedAt: entity.reviewedAt ? entity.reviewedAt.toISOString() : null,
      resolvedAt: entity.resolvedAt ? entity.resolvedAt.toISOString() : null,
      resolutionNotes: entity.resolutionNotes,
      createdAt: entity.createdAt.toISOString(),
      updatedAt: entity.updatedAt.toISOString(),
    };
  }

  private async recordAudit(input: {
    actorUserId: string;
    correlationId: string;
    action: string;
    target: string;
    outcome: 'success' | 'failure' | 'denied' | 'reverted';
    metadata: Record<string, string | number | boolean | null> | null;
  }): Promise<void> {
    await this.auditIncidentService.recordAuditAction({
      actorUserId: input.actorUserId,
      correlationId: input.correlationId,
      dto: {
        action: input.action,
        target: input.target,
        outcome: input.outcome,
        metadata: input.metadata ?? undefined,
      },
    });
  }
}
