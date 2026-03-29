import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  AnalyticsGovernanceValidationDto,
  GovernanceRecordsExportDto,
  GovernanceRecordsQueryDto,
} from './analytics-governance.dto';
import {
  ANALYTICS_GOVERNANCE_INVALID_CURSOR,
  ANALYTICS_GOVERNANCE_INVALID_QUERY_WINDOW,
  ANALYTICS_GOVERNANCE_PHI_VIOLATION,
  ANALYTICS_GOVERNANCE_QUERY_WINDOW_TOO_BROAD,
  ANALYTICS_GOVERNANCE_REVIEW_REQUIRED,
  ANALYTICS_GOVERNANCE_UNAUTHORIZED_SCOPE,
  AnalyticsGovernanceInvalidCursorException,
  AnalyticsGovernanceInvalidQueryWindowException,
  AnalyticsGovernancePhiViolationException,
  AnalyticsGovernanceQueryWindowTooBroadException,
  AnalyticsGovernanceReviewRequest,
  AnalyticsGovernanceUnauthorizedScopeException,
  AnalyticsGovernanceValidationResult,
  AnalyticsGovernanceViolation,
  GovernanceRecord,
  GovernanceRecordType,
  GovernanceRecordsExportResult,
  GovernanceRecordsQueryResult,
} from './analytics-governance.types';
import { AnalyticsGovernanceReviewEntity } from '../../database/entities/analytics-governance-review.entity';
import { AnalyticsTaxonomyFieldEntity } from '../../database/entities/analytics-taxonomy-field.entity';
import { ConsentRecordEntity } from '../../database/entities/consent-record.entity';
import { ShareAccessEventEntity } from '../../database/entities/share-access-event.entity';
import { ShareLinkEntity } from '../../database/entities/share-link.entity';
import { SuperadminAuthAuditEventEntity } from '../../database/entities/superadmin-auth-audit-event.entity';
import { UserSharePolicyEntity } from '../../database/entities/user-share-policy.entity';

const MAX_QUERY_WINDOW_DAYS = 31;
const MAX_UNSCOPED_WINDOW_DAYS = 3;
const DEFAULT_LIMIT = 50;
const MAX_LIMIT = 100;
const PHI_SAFE_EXCLUDED_EXPORT_FIELDS = [
  'phiPayloadBody',
  'rawDocumentContent',
];

interface QueryWindow {
  start: Date;
  end: Date;
}

interface QueryCursor {
  occurredAt: string;
  tieBreaker: string;
}

interface QueryFilters {
  recordType: GovernanceRecordType | 'all';
  userId: string | null;
  profileId: string | null;
  shareLinkId: string | null;
}

@Injectable()
export class AnalyticsGovernanceService {
  private readonly logger = new Logger(AnalyticsGovernanceService.name);

  constructor(
    @InjectRepository(AnalyticsTaxonomyFieldEntity)
    private readonly taxonomyRepo: Repository<AnalyticsTaxonomyFieldEntity>,
    @InjectRepository(AnalyticsGovernanceReviewEntity)
    private readonly reviewRepo: Repository<AnalyticsGovernanceReviewEntity>,
    @InjectRepository(SuperadminAuthAuditEventEntity)
    private readonly auditRepo: Repository<SuperadminAuthAuditEventEntity>,
    @InjectRepository(ShareAccessEventEntity)
    private readonly shareAccessRepo: Repository<ShareAccessEventEntity>,
    @InjectRepository(ShareLinkEntity)
    private readonly shareLinkRepo: Repository<ShareLinkEntity>,
    @InjectRepository(ConsentRecordEntity)
    private readonly consentRepo: Repository<ConsentRecordEntity>,
    @InjectRepository(UserSharePolicyEntity)
    private readonly policyRepo: Repository<UserSharePolicyEntity>,
  ) {}

  async validateInstrumentation(input: {
    actorUserId: string;
    correlationId: string;
    dto: AnalyticsGovernanceValidationDto;
  }): Promise<AnalyticsGovernanceValidationResult> {
    const eventName = input.dto.eventName.trim();
    const normalizedFields = input.dto.fields.map((field) => ({
      name: field.name.trim(),
      classification: field.classification,
    }));

    const taxonomyRows = await this.taxonomyRepo.find({ where: { eventName } });
    const allowedFields = new Map(
      taxonomyRows.map((row) => [row.fieldName.toLowerCase(), row]),
    );

    const pendingReviews = await this.reviewRepo.find({
      where: { eventName, status: 'pending' },
    });
    const pendingFieldKeys = new Set(
      pendingReviews.map((review) => review.fieldName.toLowerCase()),
    );

    const violations: AnalyticsGovernanceViolation[] = [];
    const reviewRequests: AnalyticsGovernanceReviewRequest[] = [];
    const reviewEntities: AnalyticsGovernanceReviewEntity[] = [];

    for (const field of normalizedFields) {
      const fieldKey = field.name.toLowerCase();
      const existing = allowedFields.get(fieldKey);

      if (
        field.classification === 'phi' ||
        existing?.classification === 'phi'
      ) {
        violations.push({
          field: field.name,
          classification: field.classification,
          code: ANALYTICS_GOVERNANCE_PHI_VIOLATION,
          hint: 'Strip PHI content from analytics payloads or move it into a vetted, non-sensitive event.',
        });
        continue;
      }

      const isAllowed = existing?.allowList;
      if (isAllowed || pendingFieldKeys.has(fieldKey)) {
        continue;
      }

      reviewRequests.push({
        field: field.name,
        classification: field.classification,
        reason:
          'Instrumentation change introduced a new field that is not on the allow-list.',
      });

      reviewEntities.push(
        this.reviewRepo.create({
          eventName,
          fieldName: field.name,
          classification: field.classification,
          status: 'pending',
          details: input.dto.changeSummary ?? null,
        }),
      );
    }

    if (violations.length > 0) {
      await this.recordAudit({
        actorUserId: input.actorUserId,
        correlationId: input.correlationId,
        action: 'PHI_ANALYTICS_GOVERNANCE_VALIDATE',
        target: eventName,
        outcome: 'failure',
        errorCode: ANALYTICS_GOVERNANCE_PHI_VIOLATION,
        metadata: {
          state: 'blocked',
          fieldCount: normalizedFields.length,
          reviewCount: reviewRequests.length,
        },
      });
      throw new AnalyticsGovernancePhiViolationException({
        violations,
        remediationHints: violations.map((item) => item.hint),
      });
    }

    if (reviewEntities.length > 0) {
      await this.reviewRepo.save(reviewEntities);
    }

    const validationResult: AnalyticsGovernanceValidationResult = {
      state: reviewRequests.length ? 'review_required' : 'approved',
      message: reviewRequests.length
        ? 'New instrumentation fields require governance review before they can be published.'
        : 'Instrumentation passes PHI-safe governance checks.',
      reviewRequests: reviewRequests.length ? reviewRequests : undefined,
    };

    await this.recordAudit({
      actorUserId: input.actorUserId,
      correlationId: input.correlationId,
      action: 'PHI_ANALYTICS_GOVERNANCE_VALIDATE',
      target: eventName,
      outcome: 'success',
      errorCode: reviewRequests.length
        ? ANALYTICS_GOVERNANCE_REVIEW_REQUIRED
        : null,
      metadata: {
        state: reviewRequests.length ? 'review_required' : 'passed',
        fieldCount: normalizedFields.length,
        reviewCount: reviewRequests.length,
      },
    });

    return validationResult;
  }

  async queryGovernanceRecords(input: {
    actorUserId: string;
    correlationId: string;
    query: GovernanceRecordsQueryDto;
  }): Promise<GovernanceRecordsQueryResult> {
    const filters = this.buildFilters(input.query);

    try {
      const window = this.parseWindow(
        input.query.windowStart,
        input.query.windowEnd,
      );
      const cursor = this.parseCursor(input.query.cursor);
      this.assertScopeConstraints(filters, window);
      const limit = this.resolveLimit(input.query.limit);

      const allRecords = await this.readMergedRecords({
        filters,
        window,
        queryCorrelationId: input.correlationId,
      });

      const cursorFiltered = this.applyCursor(allRecords, cursor);
      const pageRecords = cursorFiltered.slice(0, limit);
      const hasNextPage = cursorFiltered.length > limit;
      const lastRecord = pageRecords.at(-1);
      const nextCursor =
        hasNextPage && lastRecord
          ? this.encodeCursor({
              occurredAt: lastRecord.occurredAt,
              tieBreaker: this.buildTieBreaker(lastRecord),
            })
          : null;

      await this.recordAudit({
        actorUserId: input.actorUserId,
        correlationId: input.correlationId,
        action: 'GOVERNANCE_RECORDS_QUERY',
        target: 'access_share_consent_policy_records',
        outcome: 'success',
        errorCode: null,
        metadata: {
          recordCount: pageRecords.length,
          hasNextPage,
          recordType: filters.recordType,
          userScoped: Boolean(filters.userId),
          profileScoped: Boolean(filters.profileId),
          shareLinkScoped: Boolean(filters.shareLinkId),
        },
      });

      return {
        state: 'success',
        records: pageRecords,
        pageInfo: {
          limit,
          hasNextPage,
          nextCursor,
          windowStart: window.start.toISOString(),
          windowEnd: window.end.toISOString(),
        },
      };
    } catch (error) {
      const { errorCode, outcome } = this.resolveQueryFailure(error);
      await this.recordAudit({
        actorUserId: input.actorUserId,
        correlationId: input.correlationId,
        action: 'GOVERNANCE_RECORDS_QUERY',
        target: 'access_share_consent_policy_records',
        outcome,
        errorCode,
        metadata: {
          recordType: filters.recordType,
          userScoped: Boolean(filters.userId),
          profileScoped: Boolean(filters.profileId),
          shareLinkScoped: Boolean(filters.shareLinkId),
        },
      });
      throw error;
    }
  }

  async exportGovernanceRecords(input: {
    actorUserId: string;
    correlationId: string;
    dto: GovernanceRecordsExportDto;
  }): Promise<GovernanceRecordsExportResult> {
    const queryResult = await this.queryGovernanceRecords({
      actorUserId: input.actorUserId,
      correlationId: input.correlationId,
      query: {
        ...input.dto,
        limit: input.dto.limit ?? MAX_LIMIT,
      },
    });

    const filters = this.buildFilters(input.dto);
    const records = input.dto.includeAuditMetadata
      ? queryResult.records
      : queryResult.records.map((record) => ({
          ...record,
          metadata: this.stripAuditMetadata(record.metadata),
        }));

    await this.recordAudit({
      actorUserId: input.actorUserId,
      correlationId: input.correlationId,
      action: 'GOVERNANCE_RECORDS_EXPORT',
      target: 'access_share_consent_policy_records',
      outcome: 'success',
      errorCode: null,
      metadata: {
        recordCount: records.length,
        includedAuditMetadata: Boolean(input.dto.includeAuditMetadata),
      },
    });

    return {
      state: 'success',
      generatedAt: new Date().toISOString(),
      records,
      metadata: {
        queryCorrelationId: input.correlationId,
        excludedSensitiveFields: PHI_SAFE_EXCLUDED_EXPORT_FIELDS,
        filterSummary: {
          recordType: filters.recordType,
          userId: filters.userId,
          profileId: filters.profileId,
          shareLinkId: filters.shareLinkId,
          windowStart: queryResult.pageInfo.windowStart,
          windowEnd: queryResult.pageInfo.windowEnd,
        },
      },
    };
  }

  private buildFilters(query: GovernanceRecordsQueryDto): QueryFilters {
    return {
      recordType: query.recordType ?? 'all',
      userId: query.userId?.trim() ?? null,
      profileId: query.profileId?.trim() ?? null,
      shareLinkId: query.shareLinkId?.trim() ?? null,
    };
  }

  private resolveLimit(limit?: number): number {
    if (!limit) {
      return DEFAULT_LIMIT;
    }
    return Math.min(Math.max(limit, 1), MAX_LIMIT);
  }

  private parseWindow(startValue: string, endValue: string): QueryWindow {
    const start = new Date(startValue);
    const end = new Date(endValue);
    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
      throw new AnalyticsGovernanceInvalidQueryWindowException(
        'windowStart and windowEnd must be valid ISO dates',
      );
    }
    if (start >= end) {
      throw new AnalyticsGovernanceInvalidQueryWindowException(
        'windowStart must be before windowEnd',
      );
    }

    const durationMs = end.getTime() - start.getTime();
    const maxWindowMs = MAX_QUERY_WINDOW_DAYS * 24 * 60 * 60 * 1000;
    if (durationMs > maxWindowMs) {
      throw new AnalyticsGovernanceQueryWindowTooBroadException(
        `window cannot exceed ${MAX_QUERY_WINDOW_DAYS} days`,
      );
    }

    return { start, end };
  }

  private assertScopeConstraints(
    filters: QueryFilters,
    window: QueryWindow,
  ): void {
    const hasExplicitScope = Boolean(
      filters.userId || filters.profileId || filters.shareLinkId,
    );
    const durationMs = window.end.getTime() - window.start.getTime();
    const unscopedLimitMs = MAX_UNSCOPED_WINDOW_DAYS * 24 * 60 * 60 * 1000;

    if (!hasExplicitScope && durationMs > unscopedLimitMs) {
      throw new AnalyticsGovernanceUnauthorizedScopeException(
        `unscoped queries are limited to ${MAX_UNSCOPED_WINDOW_DAYS} days; provide userId, profileId, or shareLinkId for wider windows`,
      );
    }
  }

  private parseCursor(cursor?: string): QueryCursor | null {
    if (!cursor) {
      return null;
    }

    try {
      const json = Buffer.from(cursor, 'base64').toString('utf8');
      const decoded = JSON.parse(json) as QueryCursor;
      if (!decoded?.occurredAt || !decoded?.tieBreaker) {
        throw new Error('missing fields');
      }
      const occurredAt = new Date(decoded.occurredAt);
      if (Number.isNaN(occurredAt.getTime())) {
        throw new Error('invalid timestamp');
      }
      return {
        occurredAt: occurredAt.toISOString(),
        tieBreaker: decoded.tieBreaker,
      };
    } catch {
      throw new AnalyticsGovernanceInvalidCursorException();
    }
  }

  private encodeCursor(cursor: QueryCursor): string {
    return Buffer.from(JSON.stringify(cursor), 'utf8').toString('base64');
  }

  private applyCursor(
    records: GovernanceRecord[],
    cursor: QueryCursor | null,
  ): GovernanceRecord[] {
    if (!cursor) {
      return records;
    }

    return records.filter((record) => {
      const timestampCompare = record.occurredAt.localeCompare(
        cursor.occurredAt,
      );
      if (timestampCompare < 0) {
        return true;
      }
      if (timestampCompare > 0) {
        return false;
      }
      return this.buildTieBreaker(record) < cursor.tieBreaker;
    });
  }

  private buildTieBreaker(record: GovernanceRecord): string {
    return `${record.occurredAt}:${record.type}:${record.id}`;
  }

  private async readMergedRecords(input: {
    filters: QueryFilters;
    window: QueryWindow;
    queryCorrelationId: string;
  }): Promise<GovernanceRecord[]> {
    const perSourceTake = 300;

    const [accessRecords, shareRecords, consentRecords, policyRecords] =
      await Promise.all([
        this.shouldReadType(input.filters.recordType, 'access')
          ? this.readAccessRecords(input.filters, input.window, perSourceTake)
          : Promise.resolve([]),
        this.shouldReadType(input.filters.recordType, 'share')
          ? this.readShareRecords(input.filters, input.window, perSourceTake)
          : Promise.resolve([]),
        this.shouldReadType(input.filters.recordType, 'consent')
          ? this.readConsentRecords(input.filters, input.window, perSourceTake)
          : Promise.resolve([]),
        this.shouldReadType(input.filters.recordType, 'policy')
          ? this.readPolicyRecords(input.filters, input.window, perSourceTake)
          : Promise.resolve([]),
      ]);

    return [
      ...accessRecords,
      ...shareRecords,
      ...consentRecords,
      ...policyRecords,
    ]
      .sort((a, b) => {
        const timestampCompare = b.occurredAt.localeCompare(a.occurredAt);
        if (timestampCompare !== 0) {
          return timestampCompare;
        }
        return this.buildTieBreaker(b).localeCompare(this.buildTieBreaker(a));
      })
      .map((record) => ({
        ...record,
        correlation: {
          eventCorrelationId: record.correlation.eventCorrelationId,
          queryCorrelationId: input.queryCorrelationId,
        },
      }));
  }

  private shouldReadType(
    selectedType: GovernanceRecordType | 'all',
    currentType: GovernanceRecordType,
  ): boolean {
    return selectedType === 'all' || selectedType === currentType;
  }

  private async readAccessRecords(
    filters: QueryFilters,
    window: QueryWindow,
    take: number,
  ): Promise<GovernanceRecord[]> {
    const qb = this.shareAccessRepo
      .createQueryBuilder('access')
      .innerJoin(ShareLinkEntity, 'link', 'link.id = access.share_link_id')
      .where('access.accessed_at >= :windowStart', {
        windowStart: window.start.toISOString(),
      })
      .andWhere('access.accessed_at <= :windowEnd', {
        windowEnd: window.end.toISOString(),
      })
      .orderBy('access.accessed_at', 'DESC')
      .addOrderBy('access.id', 'DESC')
      .take(take)
      .select([
        'access.id AS id',
        'access.share_link_id AS share_link_id',
        'access.outcome AS outcome',
        'access.accessed_at AS occurred_at',
        'link.user_id AS user_id',
        'link.profile_id AS profile_id',
      ]);

    if (filters.userId) {
      qb.andWhere('link.user_id = :userId', { userId: filters.userId });
    }
    if (filters.profileId) {
      qb.andWhere('link.profile_id = :profileId', {
        profileId: filters.profileId,
      });
    }
    if (filters.shareLinkId) {
      qb.andWhere('access.share_link_id = :shareLinkId', {
        shareLinkId: filters.shareLinkId,
      });
    }

    const rows = await qb.getRawMany<{
      id: string;
      share_link_id: string;
      outcome: string;
      occurred_at: string;
      user_id: string;
      profile_id: string;
    }>();

    return rows.map((row) => ({
      id: row.id,
      type: 'access',
      action: 'SHARE_LINK_ACCESSED',
      outcome: row.outcome === 'expired_or_revoked' ? 'failure' : 'success',
      occurredAt: new Date(row.occurred_at).toISOString(),
      actorUserId: null,
      subjectUserId: row.user_id,
      profileId: row.profile_id,
      shareLinkId: row.share_link_id,
      correlation: {
        eventCorrelationId: null,
        queryCorrelationId: '',
      },
      metadata: {
        sourceOutcome: row.outcome,
      },
    }));
  }

  private async readShareRecords(
    filters: QueryFilters,
    window: QueryWindow,
    take: number,
  ): Promise<GovernanceRecord[]> {
    const qb = this.shareLinkRepo
      .createQueryBuilder('link')
      .where('link.updated_at >= :windowStart', {
        windowStart: window.start.toISOString(),
      })
      .andWhere('link.updated_at <= :windowEnd', {
        windowEnd: window.end.toISOString(),
      })
      .orderBy('link.updated_at', 'DESC')
      .addOrderBy('link.id', 'DESC')
      .take(take);

    if (filters.userId) {
      qb.andWhere('link.user_id = :userId', { userId: filters.userId });
    }
    if (filters.profileId) {
      qb.andWhere('link.profile_id = :profileId', {
        profileId: filters.profileId,
      });
    }
    if (filters.shareLinkId) {
      qb.andWhere('link.id = :shareLinkId', {
        shareLinkId: filters.shareLinkId,
      });
    }

    const rows = await qb.getMany();
    return rows.map((row) => {
      const isCreateEvent = row.createdAt.getTime() === row.updatedAt.getTime();
      const action = isCreateEvent
        ? 'SHARE_LINK_CREATED'
        : 'SHARE_LINK_UPDATED';
      const outcome = row.isActive ? 'success' : 'reverted';

      return {
        id: row.id,
        type: 'share',
        action,
        outcome,
        occurredAt: row.updatedAt.toISOString(),
        actorUserId: null,
        subjectUserId: row.userId,
        profileId: row.profileId,
        shareLinkId: row.id,
        correlation: {
          eventCorrelationId: null,
          queryCorrelationId: '',
        },
        metadata: {
          scope: row.scope,
          isActive: row.isActive,
          expiresAt: row.expiresAt ? row.expiresAt.toISOString() : null,
        },
      } satisfies GovernanceRecord;
    });
  }

  private async readConsentRecords(
    filters: QueryFilters,
    window: QueryWindow,
    take: number,
  ): Promise<GovernanceRecord[]> {
    if (filters.profileId || filters.shareLinkId) {
      return [];
    }

    const qb = this.consentRepo
      .createQueryBuilder('consent')
      .where('consent.accepted_at >= :windowStart', {
        windowStart: window.start.toISOString(),
      })
      .andWhere('consent.accepted_at <= :windowEnd', {
        windowEnd: window.end.toISOString(),
      })
      .orderBy('consent.accepted_at', 'DESC')
      .addOrderBy('consent.id', 'DESC')
      .take(take);

    if (filters.userId) {
      qb.andWhere('consent.user_id = :userId', { userId: filters.userId });
    }

    const rows = await qb.getMany();
    return rows.map((row) => ({
      id: row.id,
      type: 'consent',
      action: 'CONSENT_ACCEPTED',
      outcome: 'success',
      occurredAt: row.acceptedAt.toISOString(),
      actorUserId: null,
      subjectUserId: row.userId,
      profileId: null,
      shareLinkId: null,
      correlation: {
        eventCorrelationId: null,
        queryCorrelationId: '',
      },
      metadata: {
        policyType: row.policyType,
        policyVersion: row.policyVersion,
      },
    }));
  }

  private async readPolicyRecords(
    filters: QueryFilters,
    window: QueryWindow,
    take: number,
  ): Promise<GovernanceRecord[]> {
    if (filters.profileId || filters.shareLinkId) {
      return [];
    }

    const qb = this.policyRepo
      .createQueryBuilder('policy')
      .where('policy.updated_at >= :windowStart', {
        windowStart: window.start.toISOString(),
      })
      .andWhere('policy.updated_at <= :windowEnd', {
        windowEnd: window.end.toISOString(),
      })
      .orderBy('policy.updated_at', 'DESC')
      .addOrderBy('policy.id', 'DESC')
      .take(take);

    if (filters.userId) {
      qb.andWhere('policy.user_id = :userId', { userId: filters.userId });
    }

    const rows = await qb.getMany();
    return rows.map((row) => ({
      id: row.id,
      type: 'policy',
      action: 'SHARE_POLICY_UPDATED',
      outcome: 'success',
      occurredAt: row.updatedAt.toISOString(),
      actorUserId: null,
      subjectUserId: row.userId,
      profileId: null,
      shareLinkId: null,
      correlation: {
        eventCorrelationId: null,
        queryCorrelationId: '',
      },
      metadata: {
        defaultExpiresInDays: row.defaultExpiresInDays,
      },
    }));
  }

  private stripAuditMetadata(
    metadata: Record<string, string | number | boolean | null>,
  ): Record<string, string | number | boolean | null> {
    return Object.fromEntries(
      Object.entries(metadata).filter(
        ([key]) => !key.toLowerCase().includes('audit'),
      ),
    );
  }

  private resolveQueryFailure(error: unknown): {
    errorCode: string;
    outcome: 'failure' | 'denied';
  } {
    if (error instanceof AnalyticsGovernanceUnauthorizedScopeException) {
      return {
        errorCode: ANALYTICS_GOVERNANCE_UNAUTHORIZED_SCOPE,
        outcome: 'denied',
      };
    }
    if (error instanceof AnalyticsGovernanceInvalidQueryWindowException) {
      return {
        errorCode: ANALYTICS_GOVERNANCE_INVALID_QUERY_WINDOW,
        outcome: 'failure',
      };
    }
    if (error instanceof AnalyticsGovernanceQueryWindowTooBroadException) {
      return {
        errorCode: ANALYTICS_GOVERNANCE_QUERY_WINDOW_TOO_BROAD,
        outcome: 'failure',
      };
    }
    if (error instanceof AnalyticsGovernanceInvalidCursorException) {
      return {
        errorCode: ANALYTICS_GOVERNANCE_INVALID_CURSOR,
        outcome: 'failure',
      };
    }

    return {
      errorCode: 'ANALYTICS_GOVERNANCE_QUERY_FAILED',
      outcome: 'failure',
    };
  }

  private async recordAudit(input: {
    actorUserId: string;
    correlationId: string;
    action: string;
    target: string;
    outcome: 'success' | 'failure' | 'denied' | 'reverted';
    errorCode: string | null;
    metadata: Record<string, string | number | boolean | null>;
  }): Promise<void> {
    const audit = this.auditRepo.create({
      actorUserId: input.actorUserId,
      action: input.action,
      target: input.target,
      outcome: input.outcome,
      correlationId: input.correlationId,
      challengeId: null,
      errorCode: input.errorCode,
      metadata: this.toAuditMetadata(input.metadata),
    });

    await this.auditRepo.save(audit);
    this.logger.log(
      JSON.stringify({
        action: audit.action,
        target: audit.target,
        outcome: audit.outcome,
        correlationId: audit.correlationId,
        actorUserId: audit.actorUserId,
      }),
    );
  }

  private toAuditMetadata(
    metadata: Record<string, string | number | boolean | null>,
  ): Record<string, string | number | boolean> | null {
    const filtered = Object.fromEntries(
      Object.entries(metadata).filter(([, value]) => value !== null),
    ) as Record<string, string | number | boolean>;

    if (Object.keys(filtered).length === 0) {
      return null;
    }
    return filtered;
  }
}
