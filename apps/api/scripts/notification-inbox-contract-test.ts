import 'reflect-metadata';
import assert from 'node:assert/strict';
import { NotFoundException } from '@nestjs/common';
import { NotificationsService } from '../src/modules/notifications/notifications.service';

const owner = '11111111-1111-4111-8111-111111111111';
const outsider = '22222222-2222-4222-8222-222222222222';
const sourceId = '33333333-3333-4333-8333-333333333333';
const now = new Date('2026-10-24T12:00:00Z');
const queue = {
  id: sourceId,
  emailType: 'report.review_required',
  createdAt: now,
  metadata: { userId: owner, reportId: '44444444-4444-4444-8444-444444444444' },
};
const queries: Array<{ text: string; values: unknown }> = [];
const reads: Array<{ userId: string; sourceType: string; sourceId: string }> = [];

function queryBuilder(items: unknown[]) {
  return {
    innerJoinAndSelect() { return this; },
    where(text: string, values: unknown) { queries.push({ text, values }); return this; },
    andWhere() { return this; },
    orderBy() { return this; },
    take() { return this; },
    async getMany() { return items; },
  };
}

const service = new NotificationsService(
  {} as never,
  {} as never,
  { createQueryBuilder: () => queryBuilder([]), count: async () => 0 } as never,
  {} as never,
  {
    find: async () => [],
    upsert: async (value: { userId: string; sourceType: string; sourceId: string }) => {
      reads.push(value);
    },
  } as never,
  {
    createQueryBuilder: () => queryBuilder([queue]),
    findOne: async () => queue,
  } as never,
  { find: async () => [], count: async () => 0 } as never,
  { findOne: async () => null } as never,
  {} as never,
  {} as never,
  {} as never,
);

async function main() {
  const inbox = await service.getInbox(owner) as {
    items: Array<{ id: string; sourceType: string; title: string; deepLink: string }>;
  };
  assert.equal(inbox.items.length, 1);
  assert.equal(inbox.items[0].sourceType, 'report');
  assert.equal(inbox.items[0].title, 'Your report is ready to review');
  assert.equal(inbox.items[0].deepLink, '/reports/44444444-4444-4444-8444-444444444444');
  assert(queries.some((query) =>
    query.text.includes("metadata ->> 'userId'") &&
    (query.values as { userId?: string }).userId === owner
  ));

  await assert.rejects(
    service.markInboxRead(outsider, 'report', sourceId),
    NotFoundException,
  );
  assert.equal(reads.length, 0);
  await service.markInboxRead(owner, 'report', sourceId);
  assert.deepEqual(reads.map(({ userId, sourceType, sourceId }) => ({
    userId,
    sourceType,
    sourceId,
  })), [{ userId: owner, sourceType: 'report', sourceId }]);
}

void main();
