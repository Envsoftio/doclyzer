import type { ReportStatus } from '../../database/entities/report.entity';

export type { ReportStatus };

export const REPORT_NOT_FOUND = 'REPORT_NOT_FOUND';
export const REPORT_FILE_UNAVAILABLE = 'REPORT_FILE_UNAVAILABLE';
export const REPORT_ALREADY_PARSED = 'REPORT_ALREADY_PARSED';
export const REPORT_NO_ACTIVE_PROFILE = 'REPORT_NO_ACTIVE_PROFILE';
export const REPORT_FILE_REQUIRED = 'REPORT_FILE_REQUIRED';
export const REPORT_FILE_EMPTY = 'REPORT_FILE_EMPTY';
export const REPORT_FILE_TOO_LARGE = 'REPORT_FILE_TOO_LARGE';
export const REPORT_FILE_TYPE_UNSUPPORTED = 'REPORT_FILE_TYPE_UNSUPPORTED';
export const REPORT_DUPLICATE_DETECTED = 'REPORT_DUPLICATE_DETECTED';
export const REPORT_CONTENT_NOT_RECOGNIZED = 'REPORT_CONTENT_NOT_RECOGNIZED';
export const REPORT_LIMIT_EXCEEDED = 'REPORT_LIMIT_EXCEEDED';

export interface DuplicateReportInfo {
  id: string;
  originalFileName: string;
  createdAt: string;
}

export const MAX_REPORT_SIZE_BYTES = 10 * 1024 * 1024; // 10 MB
export const ALLOWED_CONTENT_TYPES = ['application/pdf'] as const;
export const ALLOWED_IMAGE_CONTENT_TYPES = ['image/jpeg', 'image/png'] as const;
export const ALLOWED_UPLOAD_CONTENT_TYPES = [
  ...ALLOWED_CONTENT_TYPES,
  ...ALLOWED_IMAGE_CONTENT_TYPES,
] as const;
