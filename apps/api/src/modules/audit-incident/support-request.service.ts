import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SupportRequestEntity } from '../../database/entities/support-request.entity';
import type {
  CreateSupportRequestDto,
  SupportRequestAdminQueryDto,
} from './support-request.dto';
import {
  SupportRequestContextException,
  SupportRequestDetail,
  SupportRequestListItem,
  SupportRequestListResult,
  SupportRequestStatus,
  SUPPORT_ACTION_TYPES,
  SUPPORT_REQUEST_STATUSES,
} from './support-request.types';

const DEFAULT_SUPPORT_PAGE_LIMIT = 20;
const MAX_SUPPORT_PAGE_LIMIT = 100;

@Injectable()
export class SupportRequestService {
  constructor(
    @InjectRepository(SupportRequestEntity)
    private readonly supportRepo: Repository<SupportRequestEntity>,
  ) {}

  async createSupportRequest(input: {
    userId: string;
    dto: CreateSupportRequestDto;
  }): Promise<{ id: string; correlationId: string }> {
    const { userId, dto } = input;
    const actionCorrelationId =
      dto.context.correlationId?.trim() || dto.context.clientActionId?.trim();

    if (!actionCorrelationId) {
      throw new SupportRequestContextException();
    }

    const entityIds = this.sanitizeEntityIds(dto.context.entityIds);
    const metadata = this.sanitizeMetadata(dto.context.metadata);

    const saved = await this.supportRepo.save(
      this.supportRepo.create({
        userId,
        actionType: dto.context.actionType,
        correlationId: actionCorrelationId,
        clientActionId: dto.context.clientActionId?.trim() ?? null,
        errorCode: dto.context.errorCode?.trim() ?? null,
        errorMessage: dto.errorMessage?.trim() ?? null,
        entityIds,
        userMessage: dto.userMessage?.trim() ?? null,
        status: 'open',
        metadata,
      }),
    );

    return { id: saved.id, correlationId: saved.correlationId };
  }

  async listSupportRequests(
    query: SupportRequestAdminQueryDto,
  ): Promise<SupportRequestListResult> {
    const page = query.page ?? 1;
    const limit = Math.min(
      query.limit ?? DEFAULT_SUPPORT_PAGE_LIMIT,
      MAX_SUPPORT_PAGE_LIMIT,
    );
    const qb = this.supportRepo.createQueryBuilder('support');

    if (query.status && SUPPORT_REQUEST_STATUSES.includes(query.status)) {
      qb.andWhere('support.status = :status', { status: query.status });
    }
    if (query.actionType && SUPPORT_ACTION_TYPES.includes(query.actionType)) {
      qb.andWhere('support.action_type = :actionType', {
        actionType: query.actionType,
      });
    }
    if (query.userId) {
      qb.andWhere('support.user_id = :userId', { userId: query.userId });
    }
    if (query.correlationId) {
      qb.andWhere('support.correlation_id = :correlationId', {
        correlationId: query.correlationId,
      });
    }
    if (query.clientActionId) {
      qb.andWhere('support.client_action_id = :clientActionId', {
        clientActionId: query.clientActionId,
      });
    }

    const total = await qb.getCount();
    const items = await qb
      .orderBy('support.created_at', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();

    return {
      items: items.map((item) => this.mapListItem(item)),
      total,
      page,
      limit,
    };
  }

  async getSupportRequestById(
    id: string,
  ): Promise<SupportRequestDetail | null> {
    const entity = await this.supportRepo.findOne({ where: { id } });
    return entity ? this.mapDetail(entity) : null;
  }

  private mapListItem(entity: SupportRequestEntity): SupportRequestListItem {
    return {
      id: entity.id,
      userId: entity.userId,
      actionType: entity.actionType as SupportRequestListItem['actionType'],
      correlationId: entity.correlationId,
      status: entity.status as SupportRequestStatus,
      createdAt: entity.createdAt.toISOString(),
    };
  }

  private mapDetail(entity: SupportRequestEntity): SupportRequestDetail {
    return {
      ...this.mapListItem(entity),
      clientActionId: entity.clientActionId,
      errorCode: entity.errorCode,
      errorMessage: entity.errorMessage,
      entityIds: entity.entityIds,
      userMessage: entity.userMessage,
    };
  }

  private sanitizeEntityIds(
    entityIds?: Record<string, string>,
  ): Record<string, string> | null {
    if (!entityIds) return null;
    const sanitized: Record<string, string> = {};
    const allowedKeys = ['reportId', 'shareLinkId', 'profileId'];
    for (const key of allowedKeys) {
      const value = entityIds[key];
      if (typeof value === 'string' && value.trim().length > 0) {
        sanitized[key] = value.trim();
      }
    }
    return Object.keys(sanitized).length ? sanitized : null;
  }

  private sanitizeMetadata(
    metadata?: Record<string, string | number | boolean | null>,
  ): Record<string, string | number | boolean> | null {
    if (!metadata) return null;
    const sanitized: Record<string, string | number | boolean> = {};
    const allowedKeys = ['appVersion', 'platform', 'surface'];
    for (const key of allowedKeys) {
      const value = metadata[key];
      if (
        typeof value === 'string' ||
        typeof value === 'number' ||
        typeof value === 'boolean'
      ) {
        sanitized[key] = value;
      }
    }
    return Object.keys(sanitized).length ? sanitized : null;
  }
}
