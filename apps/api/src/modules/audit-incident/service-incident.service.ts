import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import type { Repository } from 'typeorm';

import type { PublicIncidentStatus } from '../../../../../packages/contracts/state/incident-status';
import { ServiceIncidentEntity } from '../../database/entities/service-incident.entity';
import {
  ServiceIncidentInvalidStatusException,
  ServiceIncidentNotFoundException,
} from './service-incident.types';
import type {
  CreateServiceIncidentDto,
  ResolveServiceIncidentDto,
} from './service-incident.dto';

const ACTIVE_INCIDENT_STATUSES = ['active', 'monitoring'] as const;

@Injectable()
export class ServiceIncidentService {
  constructor(
    @InjectRepository(ServiceIncidentEntity)
    private readonly incidentRepository: Repository<ServiceIncidentEntity>,
  ) {}

  async upsertIncident(
    dto: CreateServiceIncidentDto,
  ): Promise<PublicIncidentStatus> {
    if (!ACTIVE_INCIDENT_STATUSES.includes(dto.status)) {
      throw new ServiceIncidentInvalidStatusException(
        'Active incidents must be in active or monitoring status',
      );
    }

    if (dto.incidentId) {
      const existing = await this.incidentRepository.findOne({
        where: { id: dto.incidentId },
      });
      if (!existing) {
        throw new ServiceIncidentNotFoundException();
      }
      existing.severity = dto.severity;
      existing.status = dto.status;
      existing.headline = dto.headline;
      existing.message = dto.message;
      existing.whatsAffected = dto.whatsAffected;
      existing.affectedSurfaces = dto.affectedSurfaces;
      existing.startedAt = dto.startedAt
        ? new Date(dto.startedAt)
        : existing.startedAt;
      existing.resolvedAt = null;
      const saved = await this.incidentRepository.save(existing);
      return this.toPublicIncident(saved);
    }

    const incident = this.incidentRepository.create({
      severity: dto.severity,
      status: dto.status,
      headline: dto.headline,
      message: dto.message,
      whatsAffected: dto.whatsAffected,
      affectedSurfaces: dto.affectedSurfaces,
      startedAt: dto.startedAt ? new Date(dto.startedAt) : new Date(),
      resolvedAt: null,
    });
    const saved = await this.incidentRepository.save(incident);
    return this.toPublicIncident(saved);
  }

  async resolveIncident(
    incidentId: string,
    dto: ResolveServiceIncidentDto,
  ): Promise<PublicIncidentStatus> {
    const incident = await this.incidentRepository.findOne({
      where: { id: incidentId },
    });
    if (!incident) {
      throw new ServiceIncidentNotFoundException();
    }
    incident.status = 'resolved';
    incident.resolvedAt = dto.resolvedAt
      ? new Date(dto.resolvedAt)
      : new Date();
    const saved = await this.incidentRepository.save(incident);
    return this.toPublicIncident(saved);
  }

  async getCurrentPublicIncident(): Promise<PublicIncidentStatus | null> {
    const incident = await this.incidentRepository
      .createQueryBuilder('incident')
      .where('incident.status IN (:...statuses)', {
        statuses: ACTIVE_INCIDENT_STATUSES,
      })
      .orderBy('incident.updatedAt', 'DESC')
      .getOne();

    if (!incident) {
      return null;
    }

    return this.toPublicIncident(incident);
  }

  private toPublicIncident(
    incident: ServiceIncidentEntity,
  ): PublicIncidentStatus {
    return {
      id: incident.id,
      severity: incident.severity,
      status: incident.status,
      headline: incident.headline,
      message: incident.message,
      whatsAffected: incident.whatsAffected,
      affectedSurfaces: incident.affectedSurfaces,
      startedAt: incident.startedAt.toISOString(),
      updatedAt: incident.updatedAt.toISOString(),
      resolvedAt: incident.resolvedAt?.toISOString() ?? null,
    };
  }
}
