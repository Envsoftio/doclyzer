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
} from './analytics-admin.types';
import { OrderEntity } from '../../database/entities/order.entity';
import { ProfileEntity } from '../../database/entities/profile.entity';
import {
  ReportEntity,
  type ReportStatus,
} from '../../database/entities/report.entity';
import { SessionEntity } from '../../database/entities/session.entity';
import { SuperadminAuthAuditEventEntity } from '../../database/entities/superadmin-auth-audit-event.entity';
import { UserEntity } from '../../database/entities/user.entity';

const PIPELINE_STATUSES: ReportStatus[] = ['uploading', 'queued', 'parsing'];
const PARSED_STATUS: ReportStatus[] = ['parsed'];
const FAILURE_STATUSES: ReportStatus[] = [
  'failed_transient',
  'failed_terminal',
];
const MONETIZATION_STATUSES = ['paid', 'reconciled'];

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
    @InjectRepository(SuperadminAuthAuditEventEntity)
    private readonly auditRepo: Repository<SuperadminAuthAuditEventEntity>,
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

  private async countUsersInRange(range: DateRange): Promise<number> {
    return this.userRepo.count({
      where: {
        createdAt: Between(range.start, range.end),
      },
    });
  }

  private async countSessionsInRange(range: DateRange): Promise<number> {
    return this.sessionRepo.count({
      where: {
        createdAt: Between(range.start, range.end),
      },
    });
  }

  private async countProfilesInRange(range: DateRange): Promise<number> {
    return this.profileRepo.count({
      where: {
        createdAt: Between(range.start, range.end),
      },
    });
  }

  private async countDistinctActiveUsers(range: DateRange): Promise<number> {
    const row = await this.sessionRepo
      .createQueryBuilder('session')
      .select('COUNT(DISTINCT session.user_id)', 'count')
      .where('session.created_at >= :start AND session.created_at < :end', {
        start: range.start,
        end: range.end,
      })
      .getRawOne();
    return Number(row?.count ?? 0);
  }

  private async countReportsInRange(
    range: DateRange,
    statuses: ReportStatus[],
  ): Promise<number> {
    if (statuses.length === 0) return 0;
    return this.reportRepo.count({
      where: {
        status: In(statuses),
        createdAt: Between(range.start, range.end),
      },
    });
  }

  private async sumRevenue(
    range: DateRange,
  ): Promise<{ total: number; count: number }> {
    const row = await this.orderRepo
      .createQueryBuilder('order')
      .select('COALESCE(SUM(order.final_amount), 0)', 'total')
      .addSelect('COUNT(order.id)', 'count')
      .where('order.status IN (:...statuses)', {
        statuses: MONETIZATION_STATUSES,
      })
      .andWhere('order.created_at >= :start', { start: range.start })
      .andWhere('order.created_at < :end', { end: range.end })
      .getRawOne();

    const total = parseFloat(row?.total ?? '0') || 0;
    return { total, count: Number(row?.count ?? 0) };
  }

  private async buildPartialState(range: DateRange): Promise<{
    partialState: boolean;
    partialReason: string | null;
  }> {
    const pending = await this.reportRepo.count({
      where: {
        status: In(PIPELINE_STATUSES),
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

  private async resolveFreshnessTimestamp(): Promise<Date> {
    const [reportTimestamp, orderTimestamp] = await Promise.all([
      this.queryLatestReportUpdate(),
      this.queryLatestOrderUpdate(),
    ]);
    const reportMs = reportTimestamp?.getTime() ?? 0;
    const orderMs = orderTimestamp?.getTime() ?? 0;
    const latestMs = Math.max(reportMs, orderMs);
    return latestMs > 0 ? new Date(latestMs) : new Date();
  }

  private async queryLatestReportUpdate(): Promise<Date | null> {
    const row = await this.reportRepo
      .createQueryBuilder('report')
      .select('MAX(report.updated_at)', 'max')
      .getRawOne();
    return row?.max ? new Date(row.max) : null;
  }

  private async queryLatestOrderUpdate(): Promise<Date | null> {
    const row = await this.orderRepo
      .createQueryBuilder('order')
      .select('MAX(order.updated_at)', 'max')
      .getRawOne();
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
}
