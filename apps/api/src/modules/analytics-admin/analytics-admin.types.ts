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
