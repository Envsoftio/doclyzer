import { BadRequestException, NotFoundException } from '@nestjs/common';

export enum ServiceIncidentErrorCode {
  SERVICE_INCIDENT_NOT_FOUND = 'SERVICE_INCIDENT_NOT_FOUND',
  SERVICE_INCIDENT_INVALID_STATUS = 'SERVICE_INCIDENT_INVALID_STATUS',
}

export class ServiceIncidentNotFoundException extends NotFoundException {
  constructor(message?: string) {
    super({
      code: ServiceIncidentErrorCode.SERVICE_INCIDENT_NOT_FOUND,
      message: message ?? 'Service incident not found',
    });
  }
}

export class ServiceIncidentInvalidStatusException extends BadRequestException {
  constructor(message?: string) {
    super({
      code: ServiceIncidentErrorCode.SERVICE_INCIDENT_INVALID_STATUS,
      message: message ?? 'Invalid incident status transition',
    });
  }
}
