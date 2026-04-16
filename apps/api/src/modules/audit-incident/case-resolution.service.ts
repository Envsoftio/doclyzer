import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import type { SelectQueryBuilder } from 'typeorm';
import { Repository } from 'typeorm';
import { CaseResolutionDocumentEntity } from '../../database/entities/case-resolution-document.entity';
import { UserEntity } from '../../database/entities/user.entity';
import type {
  SubmitResolutionDto,
  ResolutionQueryDto,
} from './case-resolution.dto';
import type {
  CaseResolutionDocument,
  CaseResolutionSubmitResult,
  CaseResolutionListResult,
} from './case-resolution.types';
import {
  CaseResolutionNotFoundException,
  CaseResolutionTargetNotFoundException,
  CaseResolutionInvalidPriorDocumentException,
} from './case-resolution.types';
import { AuditIncidentService } from './audit-incident.service';

const DEFAULT_PAGE_LIMIT = 20;
const MAX_PAGE_LIMIT = 100;

@Injectable()
export class CaseResolutionService {
  constructor(
    @InjectRepository(CaseResolutionDocumentEntity)
    private readonly resolutionRepo: Repository<CaseResolutionDocumentEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    private readonly auditIncidentService: AuditIncidentService,
  ) {}

  /**
   * Submit closure documentation for a restricted account case.
   * Validates required fields (enforced by DTO) and stores an immutable record.
   * If priorDocumentId is provided, validates it belongs to this case and increments version.
   * AC1: outcome documentation stored and linked to audit trail.
   * AC2: required fields enforced by DTO validation (summary, rootCause, userImpact, actionsTaken).
   * AC3: prior closure records remain immutable; new version-linked document is created.
   */
  async submitResolution(input: {
    actorUserId: string;
    correlationId: string;
    targetUserId: string;
    dto: SubmitResolutionDto;
  }): Promise<CaseResolutionSubmitResult> {
    const { actorUserId, correlationId, targetUserId, dto } = input;

    const target = await this.userRepo.findOne({ where: { id: targetUserId } });
    if (!target) {
      throw new CaseResolutionTargetNotFoundException(targetUserId);
    }

    let version = 1;

    if (dto.priorDocumentId) {
      // Validate the prior document exists and belongs to this case
      const priorDoc = await this.resolutionRepo.findOne({
        where: { id: dto.priorDocumentId, targetUserId },
      });
      if (!priorDoc) {
        throw new CaseResolutionInvalidPriorDocumentException(
          dto.priorDocumentId,
        );
      }
      version = priorDoc.version + 1;
    } else {
      // Determine next version from existing docs for this case
      const existingCount = await this.resolutionRepo.count({
        where: { targetUserId },
      });
      version = existingCount + 1;
    }

    const entity = this.resolutionRepo.create({
      targetUserId,
      authorUserId: actorUserId,
      summary: dto.summary,
      rootCause: dto.rootCause,
      userImpact: dto.userImpact,
      actionsTaken: dto.actionsTaken,
      outcome: dto.outcome,
      auditCorrelationId: correlationId,
      priorDocumentId: dto.priorDocumentId ?? null,
      version,
    });

    const saved = await this.resolutionRepo.save(entity);

    // Emit auditable event: actor/action/target/time/outcome — PHI-safe (no user data in metadata)
    await this.auditIncidentService.recordAuditAction({
      actorUserId,
      correlationId,
      dto: {
        action: 'CASE_RESOLUTION_SUBMITTED',
        target: `account:${targetUserId}`,
        outcome: 'success',
        description: `Case closed with outcome: ${dto.outcome}`,
        metadata: {
          resolutionDocumentId: saved.id,
          version: saved.version,
          resolutionOutcome: dto.outcome,
          hasPriorDocument: dto.priorDocumentId ? true : false,
          priorDocumentId: dto.priorDocumentId ?? '',
        },
      },
    });

    return {
      state: 'success',
      document: this.toRecord(saved),
    };
  }

  /**
   * Retrieve a single resolution document by ID.
   * AC4: authorized users can retrieve closure packets by case id.
   */
  async getResolutionById(input: {
    targetUserId: string;
    documentId: string;
  }): Promise<CaseResolutionDocument> {
    const { targetUserId, documentId } = input;
    const entity = await this.resolutionRepo.findOne({
      where: { id: documentId, targetUserId },
    });
    if (!entity) {
      throw new CaseResolutionNotFoundException(documentId);
    }
    return this.toRecord(entity);
  }

  /**
   * List all resolution documents for a case, optionally filtered by date or outcome.
   * AC4: authorized users can retrieve closure packets by case id and date.
   */
  async listResolutions(input: {
    targetUserId: string;
    query: ResolutionQueryDto;
  }): Promise<CaseResolutionListResult> {
    const { targetUserId, query } = input;
    const page = query.page ?? 1;
    const limit = Math.min(query.limit ?? DEFAULT_PAGE_LIMIT, MAX_PAGE_LIMIT);

    const qb = this.resolutionRepo
      .createQueryBuilder('doc')
      .where('doc.target_user_id = :targetUserId', { targetUserId });

    this.applyQueryFilters(qb, query);

    const total = await qb.getCount();
    const items = await qb
      .orderBy('doc.created_at', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();

    return {
      documents: items.map((e) => this.toRecord(e)),
      total,
      page,
      limit,
    };
  }

  private applyQueryFilters(
    qb: SelectQueryBuilder<CaseResolutionDocumentEntity>,
    query: ResolutionQueryDto,
  ): void {
    if (query.outcome) {
      qb.andWhere('doc.outcome = :outcome', { outcome: query.outcome });
    }
    if (query.minDate) {
      qb.andWhere('doc.created_at >= :minDate', {
        minDate: new Date(query.minDate).toISOString(),
      });
    }
    if (query.maxDate) {
      qb.andWhere('doc.created_at <= :maxDate', {
        maxDate: new Date(query.maxDate).toISOString(),
      });
    }
  }

  private toRecord(
    entity: CaseResolutionDocumentEntity,
  ): CaseResolutionDocument {
    return {
      id: entity.id,
      targetUserId: entity.targetUserId,
      authorUserId: entity.authorUserId,
      summary: entity.summary,
      rootCause: entity.rootCause,
      userImpact: entity.userImpact,
      actionsTaken: entity.actionsTaken,
      outcome: entity.outcome as CaseResolutionDocument['outcome'],
      auditCorrelationId: entity.auditCorrelationId,
      priorDocumentId: entity.priorDocumentId,
      version: entity.version,
      createdAt: entity.createdAt.toISOString(),
    };
  }
}
