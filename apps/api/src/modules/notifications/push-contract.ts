import { BadRequestException } from '@nestjs/common';
const uuid =
  '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}';
export function validatePushDestination(path?: string | null): string {
  if (!path) return '/notifications';
  if (
    !/^\/(notifications|reports|account)$/.test(path) &&
    !new RegExp(`^/reports/${uuid}$`).test(path)
  )
    throw new BadRequestException('Unsupported notification destination');
  return path;
}
// All campaign messages are marketing. A caller cannot label a broadcast security to bypass consent.
export const eligibleMarketingSql = `d.active AND d.notification_permission IN ('authorized','provisional')
  AND d.last_seen_at > now()-interval '90 days'
  AND COALESCE((d.preferences->>'marketing')::boolean,false)
  AND COALESCE(p.marketing_push_enabled,false)`;
