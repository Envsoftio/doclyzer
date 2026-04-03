import {
  ArrayMinSize,
  ArrayUnique,
  IsArray,
  IsDateString,
  IsIn,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
} from 'class-validator';

import {
  INCIDENT_SEVERITIES,
  INCIDENT_STATUSES,
  INCIDENT_SURFACES,
} from '../../../../../packages/contracts/state/incident-status';

export class CreateServiceIncidentDto {
  @IsOptional()
  @IsUUID()
  incidentId?: string;

  @IsIn(INCIDENT_SEVERITIES)
  severity!: (typeof INCIDENT_SEVERITIES)[number];

  @IsIn(INCIDENT_STATUSES)
  status!: (typeof INCIDENT_STATUSES)[number];

  @IsString()
  @MaxLength(140)
  headline!: string;

  @IsString()
  @MaxLength(600)
  message!: string;

  @IsString()
  @MaxLength(240)
  whatsAffected!: string;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayUnique()
  @IsIn(INCIDENT_SURFACES, { each: true })
  affectedSurfaces!: (typeof INCIDENT_SURFACES)[number][];

  @IsOptional()
  @IsDateString()
  startedAt?: string;
}

export class ResolveServiceIncidentDto {
  @IsOptional()
  @IsDateString()
  resolvedAt?: string;
}
