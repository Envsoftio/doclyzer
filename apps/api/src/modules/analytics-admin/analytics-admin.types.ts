import { BadRequestException } from '@nestjs/common';

export const ANALYTICS_INVALID_DATE_RANGE = 'ANALYTICS_INVALID_DATE_RANGE';
export const ANALYTICS_BASELINE_DATE_RANGE_REQUIRED =
  'ANALYTICS_BASELINE_DATE_RANGE_REQUIRED';

export class AnalyticsInvalidDateRangeException extends BadRequestException {
  constructor(message: string) {
    super({ code: ANALYTICS_INVALID_DATE_RANGE, message });
  }
}

export class AnalyticsBaselineRangeException extends BadRequestException {
  constructor(message: string) {
    super({
      code: ANALYTICS_BASELINE_DATE_RANGE_REQUIRED,
      message,
    });
  }
}

export interface CoreProductAnalyticsDateRange {
  start: string;
  end: string;
}

export interface CoreProductAnalyticsDataState {
  freshnessTimestamp: string;
  partialState: boolean;
  partialReason: string | null;
}

export interface CoreProductAnalyticsMetric {
  current: number;
  baseline: number;
  delta: number;
  unit: 'count' | 'currency' | 'percent';
  description?: string;
}

export interface CoreProductAnalyticsMonetizationMetric extends CoreProductAnalyticsMetric {
  currency: string;
  orderCount: number;
}

export interface CoreProductAnalyticsSlice {
  stage: string;
  currentValue: number;
  baselineValue: number;
  delta: number;
  unit: 'count' | 'percent';
}

export interface CoreProductAnalyticsRetentionSlice {
  label: string;
  currentRate: number;
  baselineRate: number;
  delta: number;
}

export interface CoreProductAnalyticsResponse {
  currentRange: CoreProductAnalyticsDateRange;
  baselineRange: CoreProductAnalyticsDateRange;
  dataState: CoreProductAnalyticsDataState;
  metrics: {
    signups: CoreProductAnalyticsMetric;
    usage: CoreProductAnalyticsMetric;
    monetization: CoreProductAnalyticsMonetizationMetric;
    behavior: CoreProductAnalyticsMetric;
  };
  funnel: CoreProductAnalyticsSlice[];
  retention: CoreProductAnalyticsRetentionSlice[];
}

export type SystemDashboardProductSlice = 'all' | 'free' | 'paid';

export interface SystemDashboardFilters {
  startDate: string;
  endDate: string;
  geography: string | null;
  productSlice: SystemDashboardProductSlice;
}

export interface SystemDashboardOverviewMetric extends CoreProductAnalyticsMetric {
  label: string;
}

export interface SystemDashboardPaymentSummary {
  creditPacks: {
    revenue: number;
    orderCount: number;
    currency: string;
  };
  subscriptions: {
    total: number;
    active: number;
    new: number;
  };
  refunds: {
    count: number;
    amount: number;
    currency: string;
  };
}

export interface SystemDashboardFileSummary {
  statusCounts: Record<string, number>;
  totalInFlight: number;
  oldestInFlightCreatedAt: string | null;
  failedCount: number;
  parsedCount: number;
}

export interface SystemDashboardGovernanceSummary {
  suspiciousActivity: {
    openCount: number;
    topItems: Array<{
      id: string;
      severity: string;
      status: string;
      detectionSummary: string | null;
      targetType: string;
      targetId: string;
      lastDetectedAt: string;
    }>;
  };
  auditActions: {
    recent: Array<{
      id: string;
      action: string;
      target: string;
      outcome: string;
      performedAt: string;
    }>;
  };
  reviewState: {
    pendingCount: number;
    lastReviewedAt: string | null;
  };
}

export interface SystemDashboardIncidentSummary {
  pipelineFailures: number;
  suspiciousQueue: number;
  recentAuditActions: number;
}

export interface SystemDashboardResponse {
  filters: SystemDashboardFilters;
  dataState: CoreProductAnalyticsDataState;
  overview: {
    users: SystemDashboardOverviewMetric;
    sessions: SystemDashboardOverviewMetric;
    uploads: SystemDashboardOverviewMetric;
    shareLinks: SystemDashboardOverviewMetric;
    processingSuccess: SystemDashboardOverviewMetric;
  };
  activity: {
    funnel: CoreProductAnalyticsSlice[];
    retention: CoreProductAnalyticsRetentionSlice[];
  };
  payments: SystemDashboardPaymentSummary;
  files: SystemDashboardFileSummary;
  governance: SystemDashboardGovernanceSummary;
  incidents: SystemDashboardIncidentSummary;
}
