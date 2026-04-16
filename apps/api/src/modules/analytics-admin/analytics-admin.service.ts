import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Between, In, Repository } from 'typeorm';
import { CoreProductAnalyticsQueryDto } from './analytics-admin.dto';
import {
  AnalyticsBaselineRangeException,
  AnalyticsInvalidDateRangeException,
  CoreProductAnalyticsMetric,
  CoreProductAnalyticsMonetizationMetric,
  CoreProductAnalyticsResponse,
  CoreProductAnalyticsRetentionSlice,
  CoreProductAnalyticsSlice,
  SystemDashboardProductSlice,
  SystemDashboardResponse,
} from './analytics-admin.types';
import { OrderEntity } from '../../database/entities/order.entity';
import { ProfileEntity } from '../../database/entities/profile.entity';
import {
  ReportEntity,
  type ReportStatus,
} from '../../database/entities/report.entity';
import { SessionEntity } from '../../database/entities/session.entity';
import { ShareAccessEventEntity } from '../../database/entities/share-access-event.entity';
import { ShareLinkEntity } from '../../database/entities/share-link.entity';
import { SubscriptionEntity } from '../../database/entities/subscription.entity';
import { SuperadminAuthAuditEventEntity } from '../../database/entities/superadmin-auth-audit-event.entity';
import { UserEntity } from '../../database/entities/user.entity';
import { AnalyticsGovernanceService } from './analytics-governance.service';
import { EntitlementsService } from '../entitlements/entitlements.service';
import { AuditIncidentService } from '../audit-incident/audit-incident.service';
import { SuspiciousActivityService } from '../audit-incident/suspicious-activity.service';

const PIPELINE_STATUSES: ReportStatus[] = ['uploading', 'queued', 'parsing'];
const PARSED_STATUS: ReportStatus[] = ['parsed'];
const FAILURE_STATUSES: ReportStatus[] = [
  'failed_transient',
  'failed_terminal',
];
const MONETIZATION_STATUSES = ['paid', 'reconciled'];
const SUBSCRIPTION_ACTIVE_STATUSES = ['active'];

interface DateRange {
  start: Date;
  end: Date;
}

@Injectable()
export class AnalyticsAdminService {
  private readonly logger = new Logger(AnalyticsAdminService.name);

  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(SessionEntity)
    private readonly sessionRepo: Repository<SessionEntity>,
    @InjectRepository(ProfileEntity)
    private readonly profileRepo: Repository<ProfileEntity>,
    @InjectRepository(ReportEntity)
    private readonly reportRepo: Repository<ReportEntity>,
    @InjectRepository(OrderEntity)
    private readonly orderRepo: Repository<OrderEntity>,
    @InjectRepository(SubscriptionEntity)
    private readonly subscriptionRepo: Repository<SubscriptionEntity>,
    @InjectRepository(ShareLinkEntity)
    private readonly shareLinkRepo: Repository<ShareLinkEntity>,
    @InjectRepository(ShareAccessEventEntity)
    private readonly shareAccessRepo: Repository<ShareAccessEventEntity>,
    @InjectRepository(SuperadminAuthAuditEventEntity)
    private readonly auditRepo: Repository<SuperadminAuthAuditEventEntity>,
    private readonly governanceService: AnalyticsGovernanceService,
    private readonly entitlementsService: EntitlementsService,
    private readonly auditIncidentService: AuditIncidentService,
    private readonly suspiciousActivityService: SuspiciousActivityService,
  ) {}

  async getCoreProductAnalytics(input: {
    actorUserId: string;
    correlationId: string;
    query: CoreProductAnalyticsQueryDto;
  }): Promise<CoreProductAnalyticsResponse> {
    const { query } = input;
    const currentRange = this.buildRange(query.startDate, query.endDate);
    const baselineRange = this.buildBaselineRange(
      currentRange,
      query.baselineStartDate,
      query.baselineEndDate,
    );

    if (baselineRange.end <= baselineRange.start) {
      throw new AnalyticsBaselineRangeException(
        'Baseline range must end after it starts',
      );
    }

    const [
      currentSignups,
      baselineSignups,
      currentSessions,
      baselineSessions,
      currentProfiles,
      baselineProfiles,
    ] = await Promise.all([
      this.countUsersInRange(currentRange),
      this.countUsersInRange(baselineRange),
      this.countSessionsInRange(currentRange),
      this.countSessionsInRange(baselineRange),
      this.countProfilesInRange(currentRange),
      this.countProfilesInRange(baselineRange),
    ]);

    const [currentActiveUsers, baselineActiveUsers] = await Promise.all([
      this.countDistinctActiveUsers(currentRange),
      this.countDistinctActiveUsers(baselineRange),
    ]);

    const [
      currentParsedReports,
      baselineParsedReports,
      currentFailedReports,
      baselineFailedReports,
    ] = await Promise.all([
      this.countReportsInRange(currentRange, PARSED_STATUS),
      this.countReportsInRange(baselineRange, PARSED_STATUS),
      this.countReportsInRange(currentRange, FAILURE_STATUSES),
      this.countReportsInRange(baselineRange, FAILURE_STATUSES),
    ]);

    const [currentRevenue, baselineRevenue] = await Promise.all([
      this.sumRevenue(currentRange),
      this.sumRevenue(baselineRange),
    ]);

    const partialState = await this.buildPartialState(currentRange);
    const freshnessTimestamp = await this.resolveFreshnessTimestamp();

    const funnel: CoreProductAnalyticsSlice[] = this.buildFunnel(
      {
        signups: currentSignups,
        activeSessions: currentActiveUsers,
        reports: currentParsedReports,
      },
      {
        signups: baselineSignups,
        activeSessions: baselineActiveUsers,
        reports: baselineParsedReports,
      },
    );

    const retention: CoreProductAnalyticsRetentionSlice[] = [
      this.buildRetentionSlice(
        'Returning user ratio',
        currentActiveUsers,
        currentSignups,
        baselineActiveUsers,
        baselineSignups,
      ),
      this.buildRetentionSlice(
        'Reports per active user',
        currentParsedReports,
        currentActiveUsers,
        baselineParsedReports,
        baselineActiveUsers,
      ),
    ];

    const response: CoreProductAnalyticsResponse = {
      currentRange: this.formatRange(currentRange),
      baselineRange: this.formatRange(baselineRange),
      dataState: {
        freshnessTimestamp: freshnessTimestamp.toISOString(),
        partialState: partialState.partialState,
        partialReason: partialState.partialReason,
      },
      metrics: {
        signups: this.buildMetric(
          currentSignups,
          baselineSignups,
          'count',
          'New account signups',
        ),
        usage: this.buildMetric(
          currentSessions,
          baselineSessions,
          'count',
          'Sessions started',
        ),
        monetization: this.buildMonetizationMetric(
          currentRevenue,
          baselineRevenue,
        ),
        behavior: this.buildMetric(
          this.computeBehaviorScore(currentParsedReports, currentFailedReports),
          this.computeBehaviorScore(
            baselineParsedReports,
            baselineFailedReports,
          ),
          'percent',
          'Report processing success rate',
        ),
      },
      funnel,
      retention,
    };

    try {
      await this.recordAudit({
        actorUserId: input.actorUserId,
        correlationId: input.correlationId,
        metadata: {
          signups: currentSignups,
          sessions: currentSessions,
          reportsParsed: currentParsedReports,
          revenue: currentRevenue.total,
          pipelineInFlight: partialState.partialState ? 1 : 0,
          profilesCreated: currentProfiles,
          baselineProfilesCreated: baselineProfiles,
        },
      });
    } catch (err) {
      this.logger.error('Failed to persist analytics view audit event', err);
    }

    return response;
  }

  async getSystemDashboard(input: {
    actorUserId: string;
    correlationId: string;
    query: {
      startDate: string;
      endDate: string;
      geography?: string;
      productSlice?: SystemDashboardProductSlice;
    };
  }): Promise<SystemDashboardResponse> {
    const dashboard = await this.buildSystemDashboard(input.query);

    try {
      await this.recordDashboardAudit({
        actorUserId: input.actorUserId,
        correlationId: input.correlationId,
        metadata: {
          startDate: dashboard.filters.startDate,
          endDate: dashboard.filters.endDate,
          geography: dashboard.filters.geography ?? 'all',
          productSlice: dashboard.filters.productSlice,
          users: dashboard.overview.users.current,
          sessions: dashboard.overview.sessions.current,
          uploads: dashboard.overview.uploads.current,
          shareLinks: dashboard.overview.shareLinks.current,
          revenue: dashboard.payments.creditPacks.revenue,
          suspiciousQueue: dashboard.governance.suspiciousActivity.openCount,
        },
      });
    } catch (err) {
      this.logger.error('Failed to persist system dashboard audit event', err);
    }

    return dashboard;
  }

  async exportSystemDashboard(input: {
    actorUserId: string;
    correlationId: string;
    query: {
      startDate: string;
      endDate: string;
      geography?: string;
      productSlice?: SystemDashboardProductSlice;
    };
    format: 'json' | 'csv';
  }): Promise<{
    format: 'json' | 'csv';
    generatedAt: string;
    filters: SystemDashboardResponse['filters'];
    rows: Array<{ metric_name: string; metric_value: number; plan_tier: string }>;
    csv?: string;
  }> {
    const dashboard = await this.buildSystemDashboard(input.query);
    const rows = this.buildExportRows(dashboard);

    await this.governanceService.validateInstrumentation({
      actorUserId: input.actorUserId,
      correlationId: input.correlationId,
      dto: {
        eventName: 'core_product_metric',
        fields: [
          { name: 'metric_name', type: 'string', classification: 'non_phi' },
          { name: 'metric_value', type: 'number', classification: 'non_phi' },
          { name: 'plan_tier', type: 'string', classification: 'non_phi' },
        ],
        changeSummary: 'System dashboard export',
      },
    });

    try {
      await this.recordDashboardExportAudit({
        actorUserId: input.actorUserId,
        correlationId: input.correlationId,
        metadata: {
          format: input.format,
          metricCount: rows.length,
          startDate: dashboard.filters.startDate,
          endDate: dashboard.filters.endDate,
          geography: dashboard.filters.geography ?? 'all',
          productSlice: dashboard.filters.productSlice,
        },
      });
    } catch (err) {
      this.logger.error('Failed to persist dashboard export audit event', err);
    }

    const generatedAt = new Date().toISOString();
    if (input.format === 'csv') {
      return {
        format: input.format,
        generatedAt,
        filters: dashboard.filters,
        rows,
        csv: this.formatCsv(rows),
      };
    }

    return {
      format: input.format,
      generatedAt,
      filters: dashboard.filters,
      rows,
    };
  }

  private buildRange(startValue: string, endValue: string): DateRange {
    if (!startValue || !endValue) {
      throw new AnalyticsInvalidDateRangeException(
        'startDate and endDate are required',
      );
    }
    const start = new Date(startValue);
    const end = new Date(endValue);
    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
      throw new AnalyticsInvalidDateRangeException('Invalid ISO date values');
    }
    if (start >= end) {
      throw new AnalyticsInvalidDateRangeException(
        'startDate must be before endDate',
      );
    }
    return { start, end };
  }

  private buildBaselineRange(
    currentRange: DateRange,
    baselineStart?: string,
    baselineEnd?: string,
  ): DateRange {
    if ((baselineStart && !baselineEnd) || (!baselineStart && baselineEnd)) {
      throw new AnalyticsBaselineRangeException(
        'Both baseline start and end are required when one is provided',
      );
    }
    if (baselineStart && baselineEnd) {
      return this.buildRange(baselineStart, baselineEnd);
    }
    const duration = currentRange.end.getTime() - currentRange.start.getTime();
    const baselineEndDate = new Date(currentRange.start.getTime());
    const baselineStartDate = new Date(baselineEndDate.getTime() - duration);
    return { start: baselineStartDate, end: baselineEndDate };
  }

  private formatRange(range: DateRange) {
    return {
      start: range.start.toISOString(),
      end: range.end.toISOString(),
    };
  }

  private buildMetric(
    current: number,
    baseline: number,
    unit: 'count' | 'currency' | 'percent',
    description?: string,
  ): CoreProductAnalyticsMetric {
    return {
      current,
      baseline,
      delta: Number((current - baseline).toFixed(2)),
      unit,
      description,
    };
  }

  private buildMonetizationMetric(
    currentRevenue: { total: number; count: number },
    baselineRevenue: { total: number; count: number },
  ): CoreProductAnalyticsMonetizationMetric {
    const delta = Number(
      (currentRevenue.total - baselineRevenue.total).toFixed(2),
    );
    return {
      current: Number(currentRevenue.total.toFixed(2)),
      baseline: Number(baselineRevenue.total.toFixed(2)),
      delta,
      unit: 'currency',
      description: 'Finalized revenue for paid/reconciled orders',
      currency: 'INR',
      orderCount: currentRevenue.count,
    };
  }

  private buildFunnel(
    currentValues: { signups: number; activeSessions: number; reports: number },
    baselineValues: {
      signups: number;
      activeSessions: number;
      reports: number;
    },
  ): CoreProductAnalyticsSlice[] {
    return [
      this.buildSlice('Signups', currentValues.signups, baselineValues.signups),
      this.buildSlice(
        'Active sessions',
        currentValues.activeSessions,
        baselineValues.activeSessions,
      ),
      this.buildSlice(
        'Reports parsed',
        currentValues.reports,
        baselineValues.reports,
      ),
    ];
  }

  private buildSlice(
    stage: string,
    currentValue: number,
    baselineValue: number,
  ): CoreProductAnalyticsSlice {
    return {
      stage,
      currentValue,
      baselineValue,
      delta: currentValue - baselineValue,
      unit: 'count',
    };
  }

  private buildRetentionSlice(
    label: string,
    currentNumerator: number,
    currentDenominator: number,
    baselineNumerator: number,
    baselineDenominator: number,
  ): CoreProductAnalyticsRetentionSlice {
    const currentRate = this.computeRate(currentNumerator, currentDenominator);
    const baselineRate = this.computeRate(
      baselineNumerator,
      baselineDenominator,
    );
    return {
      label,
      currentRate,
      baselineRate,
      delta: Number((currentRate - baselineRate).toFixed(2)),
    };
  }

  private computeRate(numerator: number, denominator: number): number {
    if (denominator <= 0) return 0;
    return Number(((numerator / denominator) * 100).toFixed(2));
  }

  private computeBehaviorScore(success: number, failure: number): number {
    const total = success + failure;
    if (total === 0) return 100;
    return Number(((success / total) * 100).toFixed(2));
  }

  private async countUsersInRange(
    range: DateRange,
    userIds?: string[] | null,
  ): Promise<number> {
    if (userIds && userIds.length === 0) return 0;
    return this.userRepo.count({
      where: {
        ...(userIds?.length ? { id: In(userIds) } : {}),
        createdAt: Between(range.start, range.end),
      },
    });
  }

  private async countSessionsInRange(
    range: DateRange,
    userIds?: string[] | null,
  ): Promise<number> {
    if (userIds && userIds.length === 0) return 0;
    return this.sessionRepo.count({
      where: {
        ...(userIds?.length ? { userId: In(userIds) } : {}),
        createdAt: Between(range.start, range.end),
      },
    });
  }

  private async countProfilesInRange(
    range: DateRange,
    userIds?: string[] | null,
  ): Promise<number> {
    if (userIds && userIds.length === 0) return 0;
    return this.profileRepo.count({
      where: {
        ...(userIds?.length ? { userId: In(userIds) } : {}),
        createdAt: Between(range.start, range.end),
      },
    });
  }

  private async countDistinctActiveUsers(
    range: DateRange,
    userIds?: string[] | null,
  ): Promise<number> {
    if (userIds && userIds.length === 0) return 0;
    const qb = this.sessionRepo
      .createQueryBuilder('session')
      .select('COUNT(DISTINCT session.user_id)', 'count')
      .where('session.created_at >= :start AND session.created_at < :end', {
        start: range.start,
        end: range.end,
      });
    if (userIds?.length) {
      qb.andWhere('session.user_id IN (:...userIds)', { userIds });
    }
    const row = await qb.getRawOne();
    return Number(row?.count ?? 0);
  }

  private async countReportsInRange(
    range: DateRange,
    statuses: ReportStatus[],
    userIds?: string[] | null,
  ): Promise<number> {
    if (statuses.length === 0) return 0;
    if (userIds && userIds.length === 0) return 0;
    return this.reportRepo.count({
      where: {
        status: In(statuses),
        ...(userIds?.length ? { userId: In(userIds) } : {}),
        createdAt: Between(range.start, range.end),
      },
    });
  }

  private async countReportsCreatedInRange(
    range: DateRange,
    userIds?: string[] | null,
  ): Promise<number> {
    if (userIds && userIds.length === 0) return 0;
    return this.reportRepo.count({
      where: {
        ...(userIds?.length ? { userId: In(userIds) } : {}),
        createdAt: Between(range.start, range.end),
      },
    });
  }

  private async sumRevenue(
    range: DateRange,
    userIds?: string[] | null,
  ): Promise<{ total: number; count: number }> {
    if (userIds && userIds.length === 0) {
      return { total: 0, count: 0 };
    }
    const qb = this.orderRepo
      .createQueryBuilder('order')
      .select('COALESCE(SUM(order.final_amount), 0)', 'total')
      .addSelect('COUNT(order.id)', 'count')
      .where('order.status IN (:...statuses)', {
        statuses: MONETIZATION_STATUSES,
      })
      .andWhere('order.created_at >= :start', { start: range.start })
      .andWhere('order.created_at < :end', { end: range.end });
    if (userIds?.length) {
      qb.andWhere('order.user_id IN (:...userIds)', { userIds });
    }
    const row = await qb.getRawOne();

    const total = parseFloat(row?.total ?? '0') || 0;
    return { total, count: Number(row?.count ?? 0) };
  }

  private async buildPartialState(
    range: DateRange,
    userIds?: string[] | null,
  ): Promise<{
    partialState: boolean;
    partialReason: string | null;
  }> {
    if (userIds && userIds.length === 0) {
      return { partialState: false, partialReason: null };
    }
    const pending = await this.reportRepo.count({
      where: {
        status: In(PIPELINE_STATUSES),
        ...(userIds?.length ? { userId: In(userIds) } : {}),
        createdAt: Between(range.start, range.end),
      },
    });
    if (pending === 0) {
      return {
        partialState: false,
        partialReason: null,
      };
    }

    return {
      partialState: true,
      partialReason:
        'Reports are still uploading or parsing; values may shift as pipelines settle',
    };
  }

  private async resolveFreshnessTimestamp(
    userIds?: string[] | null,
  ): Promise<Date> {
    const [reportTimestamp, orderTimestamp] = await Promise.all([
      this.queryLatestReportUpdate(userIds),
      this.queryLatestOrderUpdate(userIds),
    ]);
    const reportMs = reportTimestamp?.getTime() ?? 0;
    const orderMs = orderTimestamp?.getTime() ?? 0;
    const latestMs = Math.max(reportMs, orderMs);
    return latestMs > 0 ? new Date(latestMs) : new Date();
  }

  private async queryLatestReportUpdate(
    userIds?: string[] | null,
  ): Promise<Date | null> {
    if (userIds && userIds.length === 0) return null;
    const qb = this.reportRepo
      .createQueryBuilder('report')
      .select('MAX(report.updated_at)', 'max');
    if (userIds?.length) {
      qb.where('report.user_id IN (:...userIds)', { userIds });
    }
    const row = await qb.getRawOne();
    return row?.max ? new Date(row.max) : null;
  }

  private async queryLatestOrderUpdate(
    userIds?: string[] | null,
  ): Promise<Date | null> {
    if (userIds && userIds.length === 0) return null;
    const qb = this.orderRepo
      .createQueryBuilder('order')
      .select('MAX(order.updated_at)', 'max');
    if (userIds?.length) {
      qb.where('order.user_id IN (:...userIds)', { userIds });
    }
    const row = await qb.getRawOne();
    return row?.max ? new Date(row.max) : null;
  }

  private async recordAudit(input: {
    actorUserId: string;
    correlationId: string;
    metadata: Record<string, number | string | boolean>;
  }): Promise<void> {
    await this.auditRepo.save(
      this.auditRepo.create({
        actorUserId: input.actorUserId,
        action: 'VIEW_CORE_PRODUCT_ANALYTICS',
        target: 'core_product_dashboard',
        outcome: 'success',
        correlationId: input.correlationId,
        challengeId: null,
        errorCode: null,
        metadata: input.metadata,
      }),
    );
    this.logger.log(
      JSON.stringify({
        action: 'VIEW_CORE_PRODUCT_ANALYTICS',
        actorUserId: input.actorUserId,
        correlationId: input.correlationId,
      }),
    );
  }

  private async buildSystemDashboard(query: {
    startDate: string;
    endDate: string;
    geography?: string;
    productSlice?: SystemDashboardProductSlice;
  }): Promise<SystemDashboardResponse> {
    const currentRange = this.buildRange(query.startDate, query.endDate);
    const baselineRange = this.buildBaselineRange(currentRange);
    const productSlice = query.productSlice ?? 'all';
    // Geography is stored in filters for transparency but not applied to queries —
    // user/session/report entities have no geography column yet.
    const geography = query.geography?.trim() || null;
    const userIds = await this.resolveProductSliceUserIds(productSlice);

    const [
      currentUsers,
      baselineUsers,
      currentSessions,
      baselineSessions,
      currentUploads,
      baselineUploads,
      currentShareLinks,
      baselineShareLinks,
      currentActiveUsers,
      baselineActiveUsers,
      currentParsedReports,
      baselineParsedReports,
      currentFailedReports,
      baselineFailedReports,
      currentRevenue,
      baselineRevenue,
    ] = await Promise.all([
      this.countUsersInRange(currentRange, userIds),
      this.countUsersInRange(baselineRange, userIds),
      this.countSessionsInRange(currentRange, userIds),
      this.countSessionsInRange(baselineRange, userIds),
      this.countReportsCreatedInRange(currentRange, userIds),
      this.countReportsCreatedInRange(baselineRange, userIds),
      this.countShareLinksInRange(currentRange, userIds),
      this.countShareLinksInRange(baselineRange, userIds),
      this.countDistinctActiveUsers(currentRange, userIds),
      this.countDistinctActiveUsers(baselineRange, userIds),
      this.countReportsInRange(currentRange, PARSED_STATUS, userIds),
      this.countReportsInRange(baselineRange, PARSED_STATUS, userIds),
      this.countReportsInRange(currentRange, FAILURE_STATUSES, userIds),
      this.countReportsInRange(baselineRange, FAILURE_STATUSES, userIds),
      this.sumRevenue(currentRange, userIds),
      this.sumRevenue(baselineRange, userIds),
    ]);

    const processingSuccessCurrent = this.computeBehaviorScore(
      currentParsedReports,
      currentFailedReports,
    );
    const processingSuccessBaseline = this.computeBehaviorScore(
      baselineParsedReports,
      baselineFailedReports,
    );

    const [partialState, freshnessTimestamp, fileSummary] = await Promise.all([
      this.buildPartialState(currentRange, userIds),
      this.resolveFreshnessTimestamp(userIds),
      this.buildFileSummary(currentRange, userIds),
    ]);

    const funnel = this.buildFunnel(
      {
        signups: currentUsers,
        activeSessions: currentActiveUsers,
        reports: currentParsedReports,
      },
      {
        signups: baselineUsers,
        activeSessions: baselineActiveUsers,
        reports: baselineParsedReports,
      },
    );

    const retention: CoreProductAnalyticsRetentionSlice[] = [
      this.buildRetentionSlice(
        'Returning user ratio',
        currentActiveUsers,
        currentUsers,
        baselineActiveUsers,
        baselineUsers,
      ),
      this.buildRetentionSlice(
        'Reports per active user',
        currentParsedReports,
        currentActiveUsers,
        baselineParsedReports,
        baselineActiveUsers,
      ),
    ];

    const [subscriptionSummary, suspiciousQueue, auditActions, reviewState] =
      await Promise.all([
        this.buildSubscriptionSummary(currentRange, userIds),
        this.suspiciousActivityService.listQueue({
          status: 'open',
          page: 1,
          limit: 5,
          minDetectedAt: currentRange.start.toISOString(),
          maxDetectedAt: currentRange.end.toISOString(),
        }),
        this.auditIncidentService.searchAuditActions({
          page: 1,
          limit: 5,
          minTimestamp: currentRange.start.toISOString(),
          maxTimestamp: currentRange.end.toISOString(),
        }),
        this.governanceService.getReviewStateSummary(),
      ]);

    return {
      filters: {
        startDate: currentRange.start.toISOString(),
        endDate: currentRange.end.toISOString(),
        geography,
        productSlice,
      },
      dataState: {
        freshnessTimestamp: freshnessTimestamp.toISOString(),
        partialState: partialState.partialState,
        partialReason: partialState.partialReason,
        // Geography filtering is not yet applied to queries (no geography column on entities).
        // This flag is surfaced so callers and audit exports can accurately reflect the
        // limitation rather than presenting a geography-filtered view that isn't filtered.
        geographyApplied: false,
      },
      overview: {
        users: {
          ...this.buildMetric(currentUsers, baselineUsers, 'count'),
          label: 'Users',
        },
        sessions: {
          ...this.buildMetric(currentSessions, baselineSessions, 'count'),
          label: 'Sessions',
        },
        uploads: {
          ...this.buildMetric(currentUploads, baselineUploads, 'count'),
          label: 'Uploads',
        },
        shareLinks: {
          ...this.buildMetric(currentShareLinks, baselineShareLinks, 'count'),
          label: 'Share links',
        },
        processingSuccess: {
          ...this.buildMetric(
            processingSuccessCurrent,
            processingSuccessBaseline,
            'percent',
          ),
          label: 'Processing success',
        },
      },
      activity: {
        funnel,
        retention,
      },
      payments: {
        creditPacks: {
          revenue: Number(currentRevenue.total.toFixed(2)),
          orderCount: currentRevenue.count,
          currency: 'INR',
        },
        subscriptions: subscriptionSummary,
        // Refund tracking is not yet modeled in the orders schema (no 'refunded' status or
        // separate refund entity). Returning zeros is correct until refunds are implemented.
        refunds: {
          count: 0,
          amount: 0,
          currency: 'INR',
        },
      },
      files: fileSummary,
      governance: {
        suspiciousActivity: {
          openCount: suspiciousQueue.total,
          topItems: suspiciousQueue.items.map((item) => ({
            id: item.id,
            severity: item.severity,
            status: item.status,
            detectionSummary: item.detectionSummary ?? null,
            targetType: item.targetType,
            targetId: item.targetId,
            lastDetectedAt: item.lastDetectedAt,
          })),
        },
        auditActions: {
          recent: auditActions.items.map((event) => ({
            id: event.id,
            action: event.action,
            target: event.target,
            outcome: event.outcome,
            performedAt: event.performedAt,
          })),
        },
        reviewState,
      },
      incidents: {
        pipelineFailures: currentFailedReports,
        suspiciousQueue: suspiciousQueue.total,
        recentAuditActions: auditActions.items.length,
      },
    };
  }

  private async resolveProductSliceUserIds(
    productSlice: SystemDashboardProductSlice,
  ): Promise<string[] | null> {
    if (productSlice === 'all') return null;
    const userIds = await this.entitlementsService.listUserIdsByTier(productSlice);
    // Performance note: userIds is passed as IN (:...userIds) to every downstream query.
    // At large scale (thousands of paid users) this produces oversized SQL IN clauses.
    // TODO(perf): replace with a correlated subquery JOIN on user_entitlements to avoid
    // materialising the full user ID list in application memory.
    if (userIds.length === 0) return [];
    return userIds;
  }

  private async countShareLinksInRange(
    range: DateRange,
    userIds?: string[] | null,
  ): Promise<number> {
    if (userIds && userIds.length === 0) return 0;
    return this.shareLinkRepo.count({
      where: {
        ...(userIds?.length ? { userId: In(userIds) } : {}),
        createdAt: Between(range.start, range.end),
      },
    });
  }

  private async buildFileSummary(
    range: DateRange,
    userIds?: string[] | null,
  ): Promise<{
    statusCounts: Record<string, number>;
    totalInFlight: number;
    oldestInFlightCreatedAt: string | null;
    failedCount: number;
    parsedCount: number;
  }> {
    if (userIds && userIds.length === 0) {
      return {
        statusCounts: {},
        totalInFlight: 0,
        oldestInFlightCreatedAt: null,
        failedCount: 0,
        parsedCount: 0,
      };
    }

    const qb = this.reportRepo
      .createQueryBuilder('r')
      .select('r.status', 'status')
      .addSelect('COUNT(r.id)', 'count')
      .where('r.created_at >= :start AND r.created_at < :end', {
        start: range.start,
        end: range.end,
      })
      .groupBy('r.status');
    if (userIds?.length) {
      qb.andWhere('r.user_id IN (:...userIds)', { userIds });
    }
    const rows = await qb.getRawMany();

    const statusCounts: Record<string, number> = {};
    for (const row of rows) {
      statusCounts[row.status] = Number(row.count);
    }

    const totalInFlight = PIPELINE_STATUSES.reduce(
      (sum, status) => sum + (statusCounts[status] ?? 0),
      0,
    );

    const failedCount = FAILURE_STATUSES.reduce(
      (sum, status) => sum + (statusCounts[status] ?? 0),
      0,
    );

    const parsedCount = statusCounts.parsed ?? 0;

    const oldestQb = this.reportRepo
      .createQueryBuilder('r')
      .select('MIN(r.created_at)', 'oldest')
      .where('r.status IN (:...statuses)', { statuses: PIPELINE_STATUSES })
      .andWhere('r.created_at >= :start AND r.created_at < :end', {
        start: range.start,
        end: range.end,
      });
    if (userIds?.length) {
      oldestQb.andWhere('r.user_id IN (:...userIds)', { userIds });
    }
    const oldestRow = await oldestQb.getRawOne();

    return {
      statusCounts,
      totalInFlight,
      oldestInFlightCreatedAt: oldestRow?.oldest
        ? new Date(oldestRow.oldest).toISOString()
        : null,
      failedCount,
      parsedCount,
    };
  }

  private async buildSubscriptionSummary(
    range: DateRange,
    userIds?: string[] | null,
  ): Promise<{ total: number; active: number; new: number }> {
    if (userIds && userIds.length === 0) {
      return { total: 0, active: 0, new: 0 };
    }

    // All three counts are scoped to the dashboard date range so that filters
    // refresh all widgets consistently (AC #2). 'total' = all subscriptions created
    // in range; 'active' = active subscriptions created in range; 'new' = same as
    // total (subscriptions created in range are by definition "new").
    const [total, active] = await Promise.all([
      this.countSubscriptions({ range }, userIds),
      this.countSubscriptions({ range, statuses: SUBSCRIPTION_ACTIVE_STATUSES }, userIds),
    ]);

    return { total, active, new: total };
  }

  private async countSubscriptions(
    input: { range?: DateRange; statuses?: string[] },
    userIds?: string[] | null,
  ): Promise<number> {
    if (userIds && userIds.length === 0) return 0;
    const qb = this.subscriptionRepo
      .createQueryBuilder('sub')
      .select('COUNT(sub.id)', 'count');
    let hasWhere = false;
    if (input.range) {
      qb.where('sub.created_at >= :start AND sub.created_at < :end', {
        start: input.range.start,
        end: input.range.end,
      });
      hasWhere = true;
    }
    if (input.statuses?.length) {
      if (hasWhere) {
        qb.andWhere('sub.status IN (:...statuses)', { statuses: input.statuses });
      } else {
        qb.where('sub.status IN (:...statuses)', { statuses: input.statuses });
        hasWhere = true;
      }
    }
    if (userIds?.length) {
      if (hasWhere) {
        qb.andWhere('sub.user_id IN (:...userIds)', { userIds });
      } else {
        qb.where('sub.user_id IN (:...userIds)', { userIds });
        hasWhere = true;
      }
    }
    const row = await qb.getRawOne();
    return Number(row?.count ?? 0);
  }

  private buildExportRows(
    dashboard: SystemDashboardResponse,
  ): Array<{ metric_name: string; metric_value: number; plan_tier: string }> {
    const planTier = dashboard.filters.productSlice;
    return [
      { metric_name: 'users', metric_value: dashboard.overview.users.current, plan_tier: planTier },
      { metric_name: 'sessions', metric_value: dashboard.overview.sessions.current, plan_tier: planTier },
      { metric_name: 'uploads', metric_value: dashboard.overview.uploads.current, plan_tier: planTier },
      { metric_name: 'share_links', metric_value: dashboard.overview.shareLinks.current, plan_tier: planTier },
      { metric_name: 'processing_success_rate', metric_value: dashboard.overview.processingSuccess.current, plan_tier: planTier },
      { metric_name: 'credit_pack_revenue', metric_value: dashboard.payments.creditPacks.revenue, plan_tier: planTier },
      { metric_name: 'credit_pack_orders', metric_value: dashboard.payments.creditPacks.orderCount, plan_tier: planTier },
      { metric_name: 'subscriptions_total', metric_value: dashboard.payments.subscriptions.total, plan_tier: planTier },
      { metric_name: 'subscriptions_active', metric_value: dashboard.payments.subscriptions.active, plan_tier: planTier },
      { metric_name: 'subscriptions_new', metric_value: dashboard.payments.subscriptions.new, plan_tier: planTier },
      { metric_name: 'reports_in_flight', metric_value: dashboard.files.totalInFlight, plan_tier: planTier },
      { metric_name: 'reports_failed', metric_value: dashboard.files.failedCount, plan_tier: planTier },
      { metric_name: 'reports_parsed', metric_value: dashboard.files.parsedCount, plan_tier: planTier },
      { metric_name: 'suspicious_queue_open', metric_value: dashboard.governance.suspiciousActivity.openCount, plan_tier: planTier },
      { metric_name: 'audit_actions_recent', metric_value: dashboard.governance.auditActions.recent.length, plan_tier: planTier },
      { metric_name: 'governance_reviews_pending', metric_value: dashboard.governance.reviewState.pendingCount, plan_tier: planTier },
    ];
  }

  private formatCsv(
    rows: Array<{ metric_name: string; metric_value: number; plan_tier: string }>,
  ): string {
    const header = 'metric_name,metric_value,plan_tier';
    const lines = rows.map(
      (row) => `${row.metric_name},${row.metric_value},${row.plan_tier}`,
    );
    return [header, ...lines].join('\n');
  }

  private async recordDashboardAudit(input: {
    actorUserId: string;
    correlationId: string;
    metadata: Record<string, number | string | boolean>;
  }): Promise<void> {
    await this.auditRepo.save(
      this.auditRepo.create({
        actorUserId: input.actorUserId,
        action: 'VIEW_SYSTEM_DASHBOARD',
        target: 'system_dashboard',
        outcome: 'success',
        correlationId: input.correlationId,
        challengeId: null,
        errorCode: null,
        metadata: input.metadata,
      }),
    );
  }

  private async recordDashboardExportAudit(input: {
    actorUserId: string;
    correlationId: string;
    metadata: Record<string, number | string | boolean>;
  }): Promise<void> {
    await this.auditRepo.save(
      this.auditRepo.create({
        actorUserId: input.actorUserId,
        action: 'EXPORT_SYSTEM_DASHBOARD',
        target: 'system_dashboard',
        outcome: 'success',
        correlationId: input.correlationId,
        challengeId: null,
        errorCode: null,
        metadata: input.metadata,
      }),
    );
  }
}
