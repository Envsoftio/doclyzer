export const ACCOUNT_SUSPENDED = 'ACCOUNT_SUSPENDED' as const;

export const ACCOUNT_SUSPENDED_RESTRICTED_ACTIONS = [
  'upload_report',
  'view_timeline',
  'manage_sharing',
  'manage_profiles',
  'update_account_profile',
] as const;
