export const ACCOUNT_SUSPENDED = 'ACCOUNT_SUSPENDED' as const;

export const ACCOUNT_SUSPENDED_RESTRICTED_ACTIONS = [
  'upload_report',
  'view_timeline',
  'manage_sharing',
  'manage_profiles',
  'update_account_profile',
] as const;

export const RESTRICTED_REVIEW_ACTIONS = [
  'upload_report',
  'view_timeline',
  'manage_sharing',
  'manage_profiles',
  'update_account_profile',
] as const;

export type RestrictedReviewAction = (typeof RESTRICTED_REVIEW_ACTIONS)[number];

export const RESTRICTED_REVIEW_ERROR_CODES: Record<
  RestrictedReviewAction,
  string
> = {
  upload_report: 'REVIEW_MODE_UPLOAD_REPORT_BLOCKED',
  view_timeline: 'REVIEW_MODE_TIMELINE_BLOCKED',
  manage_sharing: 'REVIEW_MODE_SHARING_BLOCKED',
  manage_profiles: 'REVIEW_MODE_PROFILES_BLOCKED',
  update_account_profile: 'REVIEW_MODE_ACCOUNT_UPDATE_BLOCKED',
} as const;

export const RESTRICTED_REVIEW_MESSAGES: Record<
  RestrictedReviewAction,
  string
> = {
  upload_report: 'Report uploads are temporarily paused during review.',
  view_timeline: 'Timeline access is temporarily paused during review.',
  manage_sharing: 'Sharing actions are temporarily paused during review.',
  manage_profiles: 'Profile management is temporarily paused during review.',
  update_account_profile:
    'Account profile updates are temporarily paused during review.',
} as const;
