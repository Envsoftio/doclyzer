import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { createHash } from 'node:crypto';
import type { SelectQueryBuilder } from 'typeorm';
import { DataSource, Repository } from 'typeorm';
import {
  AuditActionCreateDto,
  AuditActionQueryDto,
} from './audit-incident.dto';
import {
  AuditActionRecord,
  AuditActionSearchResult,
  AuditIncidentPersistenceException,
  AuditMetadata,
  AuditMetadataValue,
  DEFAULT_AUDIT_PAGE_LIMIT,
  MAX_AUDIT_PAGE_LIMIT,
} from './audit-incident.types';
import { SuperadminActionAuditEventEntity } from '../../database/entities/superadmin-action-audit-event.entity';

// Fixed integer key used for the PostgreSQL advisory lock that serialises tamper-chain writes.
const AUDIT_CHAIN_ADVISORY_LOCK = 7354219;

@Injectable()
export class AuditIncidentService {
  private readonly logger = new Logger(AuditIncidentService.name);

  constructor(
    @InjectRepository(SuperadminActionAuditEventEntity)
    private readonly auditRepo: Repository<SuperadminActionAuditEventEntity>,
    private readonly dataSource: DataSource,
  ) {}

  async recordAuditAction(input: {
    actorUserId: string;
    correlationId: string;
    dto: AuditActionCreateDto;
  }): Promise<AuditActionRecord> {
    const { actorUserId, correlationId, dto } = input;
    const performedAt = new Date();
    const sanitizedTarget = this.sanitizeTarget(dto.target, dto.sensitive);
    const metadata = this.buildMetadataPayload(dto);

    try {
      const saved = await this.dataSource.transaction(async (manager) => {
        // Serialise concurrent tamper-chain writes with a PostgreSQL advisory lock.
        // This guarantees that sequence numbers are gap-free and each hash correctly
        // references its predecessor, preventing broken chains under concurrent load.
        await manager.query('SELECT pg_advisory_xact_lock($1)', [
          AUDIT_CHAIN_ADVISORY_LOCK,
        ]);

        const repo = manager.getRepository(SuperadminActionAuditEventEntity);
        const lastEvent = await repo.findOne({
          order: { tamperSequence: 'DESC' },
          select: ['tamperSequence', 'tamperHash'],
        });
        const sequence = (lastEvent?.tamperSequence ?? 0) + 1;
        const previousHash = lastEvent?.tamperHash ?? null;
        const tamperHash = this.computeTamperHash({
          previousHash,
          sequence,
          actorUserId,
          action: dto.action,
          target: sanitizedTarget,
          outcome: dto.outcome,
          correlationId,
          performedAt,
          metadata,
        });
        const entity = repo.create({
          actorUserId,
          action: dto.action,
          target: sanitizedTarget,
          sensitiveTarget: Boolean(dto.sensitive),
          outcome: dto.outcome,
          correlationId,
          metadata,
          tamperHash,
          tamperPrevHash: previousHash,
          tamperSequence: sequence,
          performedAt,
        });
        return await repo.save(entity);
      });
      return this.mapToRecord(saved);
    } catch (error) {
      this.handlePersistenceFailure(
        {
          actorUserId,
          correlationId,
          dto,
          performedAt,
        },
        error,
      );
      throw new AuditIncidentPersistenceException();
    }
  }

  async searchAuditActions(
    query: AuditActionQueryDto,
  ): Promise<AuditActionSearchResult> {
    const page = query.page ?? 1;
    const limit = Math.min(
      query.limit ?? DEFAULT_AUDIT_PAGE_LIMIT,
      MAX_AUDIT_PAGE_LIMIT,
    );
    const qb = this.auditRepo.createQueryBuilder('audit');
    this.applyFilters(qb, query);
    const total = await qb.getCount();
    const items = await qb
      .orderBy('audit.performed_at', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();

    return {
      items: items.map((event) => this.mapToRecord(event)),
      total,
      page,
      limit,
    };
  }

  private mapToRecord(
    entity: SuperadminActionAuditEventEntity,
  ): AuditActionRecord {
    return {
      id: entity.id,
      actorUserId: entity.actorUserId,
      action: entity.action,
      target: entity.target,
      sensitiveTarget: entity.sensitiveTarget,
      outcome: entity.outcome,
      correlationId: entity.correlationId,
      metadata: entity.metadata,
      performedAt: entity.performedAt.toISOString(),
      tamperEvidence: {
        hash: entity.tamperHash,
        previousHash: entity.tamperPrevHash,
        sequence: entity.tamperSequence,
      },
    };
  }

  private sanitizeTarget(target: string, sensitive?: boolean): string {
    if (!sensitive) return target;
    return this.maskSensitiveString(target);
  }

  private buildMetadataPayload(
    dto: AuditActionCreateDto,
  ): AuditMetadata | null {
    const metadata: AuditMetadata = {};
    if (dto.metadata) {
      for (const [key, value] of Object.entries(dto.metadata)) {
        const normalized = this.normalizeMetadataValue(value);
        if (normalized !== null) {
          metadata[key] = normalized;
        }
      }
    }
    if (dto.reasonCode) {
      metadata.reasonCode = dto.reasonCode;
    }
    if (dto.description) {
      metadata.description = dto.description;
    }
    if (!Object.keys(metadata).length) {
      return null;
    }
    if (dto.sensitive) {
      return Object.fromEntries(
        Object.entries(metadata).map(([key, value]) => [
          key,
          typeof value === 'string' ? this.maskSensitiveString(value) : value,
        ]),
      ) as AuditMetadata;
    }
    return metadata;
  }

  private maskSensitiveString(value: string): string {
    if (!value) {
      return '****';
    }
    const prefix = value.slice(0, 4);
    const masked = '*'.repeat(Math.max(value.length - prefix.length, 1));
    return `${prefix}${masked}`;
  }

  private normalizeMetadataValue(value: unknown): AuditMetadataValue | null {
    if (value === null || value === undefined) {
      return null;
    }
    if (
      typeof value === 'string' ||
      typeof value === 'number' ||
      typeof value === 'boolean'
    ) {
      return value;
    }
    try {
      return JSON.stringify(value);
    } catch {
      return null;
    }
  }

  private computeTamperHash(args: {
    previousHash: string | null;
    sequence: number;
    actorUserId: string;
    action: string;
    target: string;
    outcome: string;
    correlationId: string;
    performedAt: Date;
    metadata: AuditMetadata | null;
  }): string {
    const {
      previousHash,
      sequence,
      actorUserId,
      action,
      target,
      outcome,
      correlationId,
      performedAt,
      metadata,
    } = args;
    const payload = [
      sequence,
      previousHash ?? '',
      actorUserId,
      action,
      target,
      outcome,
      correlationId,
      performedAt.toISOString(),
      JSON.stringify(metadata ?? {}),
    ].join('|');
    return createHash('sha256').update(payload).digest('hex');
  }

  private handlePersistenceFailure(
    context: {
      actorUserId: string;
      correlationId: string;
      dto: AuditActionCreateDto;
      performedAt: Date;
    },
    error: unknown,
  ): void {
    const errorMessage =
      error instanceof Error ? error.message : 'unknown error';
    this.logger.error('Audit event persistence failed', {
      actorUserId: context.actorUserId,
      action: context.dto.action,
      outcome: context.dto.outcome,
      correlationId: context.correlationId,
      performedAt: context.performedAt.toISOString(),
      error: errorMessage,
    });
    this.logger.warn('Audit integrity alert emitted via fallback', {
      actorUserId: context.actorUserId,
      outcome: context.dto.outcome,
      correlationId: context.correlationId,
    });
  }

  private applyFilters(
    qb: SelectQueryBuilder<SuperadminActionAuditEventEntity>,
    query: AuditActionQueryDto,
  ): void {
    if (query.actorUserId) {
      qb.andWhere('audit.actor_user_id = :actorUserId', {
        actorUserId: query.actorUserId,
      });
    }
    if (query.action) {
      qb.andWhere('audit.action ILIKE :action', {
        action: `%${query.action.trim()}%`,
      });
    }
    if (query.target) {
      qb.andWhere('audit.target ILIKE :target', {
        target: `%${query.target.trim()}%`,
      });
    }
    if (query.outcome) {
      qb.andWhere('audit.outcome = :outcome', { outcome: query.outcome });
    }
    if (query.minTimestamp) {
      qb.andWhere('audit.performed_at >= :minTimestamp', {
        minTimestamp: new Date(query.minTimestamp).toISOString(),
      });
    }
    if (query.maxTimestamp) {
      qb.andWhere('audit.performed_at <= :maxTimestamp', {
        maxTimestamp: new Date(query.maxTimestamp).toISOString(),
      });
    }
  }
}
