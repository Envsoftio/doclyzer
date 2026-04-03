export const INCIDENT_SEVERITIES = ['major', 'critical'] as const;
export type IncidentSeverity = (typeof INCIDENT_SEVERITIES)[number];

export const INCIDENT_STATUSES = ['active', 'monitoring', 'resolved'] as const;
export type IncidentStatus = (typeof INCIDENT_STATUSES)[number];

export const INCIDENT_SURFACES = [
  'mobile_app',
  'web_share',
  'web_landing',
  'api',
] as const;
export type IncidentSurface = (typeof INCIDENT_SURFACES)[number];

export interface PublicIncidentStatus {
  id: string;
  severity: IncidentSeverity;
  status: IncidentStatus;
  headline: string;
  message: string;
  whatsAffected: string;
  affectedSurfaces: IncidentSurface[];
  startedAt: string;
  updatedAt: string;
  resolvedAt?: string | null;
}
