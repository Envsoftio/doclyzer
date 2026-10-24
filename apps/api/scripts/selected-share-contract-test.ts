import 'reflect-metadata';
import assert from 'node:assert/strict';
import { BadRequestException, ForbiddenException } from '@nestjs/common';
import type { FindOperator } from 'typeorm';
import { SharingService } from '../src/modules/sharing/sharing.service';
import { ShareLinkNotFoundException } from '../src/modules/sharing/exceptions/share-link-not-found.exception';

const userId = '11111111-1111-4111-8111-111111111111';
const profileId = '22222222-2222-4222-8222-222222222222';
const reportId = '33333333-3333-4333-8333-333333333333';
const otherReportId = '44444444-4444-4444-8444-444444444444';
const labValueId = '66666666-6666-4666-8666-666666666666';
const createdAt = new Date('2026-10-24T12:00:00Z');

let link: Record<string, unknown> | undefined;
let publicReportWhere: Record<string, unknown> | undefined;
let publicValueWhere: Record<string, unknown> | undefined;
const accessEvents: Array<{ outcome: string }> = [];
const manager = {
  create: (_entity: unknown, value: Record<string, unknown>) => ({
    ...value,
    id: '55555555-5555-4555-8555-555555555555',
    createdAt,
    isActive: true,
  }),
  save: async (value: Record<string, unknown>) => {
    link = value;
    return value;
  },
};

const shareLinkRepo = {
  manager: { transaction: async (fn: (value: typeof manager) => Promise<unknown>) => fn(manager) },
  findOne: async () => link,
  find: async () => link ? [link] : [],
};
const reportRepo = {
  findOne: async () => ({
    id: reportId,
    userId,
    profileId,
    originalFileStorageKey: 'reports/original.pdf',
    contentType: 'application/pdf',
    originalFileName: 'CBC.pdf',
  }),
  find: async (options: { where: Record<string, unknown>; select: string[] }) => {
    if (options.select.length > 1) {
      // Public retrieval is checked below; the fake returns only the allowed report.
      publicReportWhere = options.where;
      const savedReport = {
        id: reportId, profileId, originalFileName: 'CBC.pdf', status: 'parsed',
        summary: 'Unselected result in summary', createdAt,
        structuredReport: {
          sections: [{ tests: [
            { parameterName: 'Hemoglobin', value: '14', unit: 'g/dL', referenceRange: '12-16', isAbnormal: false },
            { parameterName: 'Ambiguous', value: '5', unit: 'mg/L', referenceRange: '4-6' },
            { parameterName: 'Ambiguous', value: '5', unit: 'mg/L', referenceRange: '5-7' },
            { parameterName: 'Reviewed', value: '5', unit: 'mg/L', referenceRange: '4-6' },
          ] }],
        },
      };
      if (options.where.id) return [savedReport];
      return [savedReport, {
        id: otherReportId, profileId, originalFileName: 'Structured.pdf',
        status: 'parsed', summary: null, createdAt,
        structuredReport: {
          sections: [{ tests: [{
            parameterName: 'Structured only', value: '15', unit: 'U/L',
            sampleDate: '2026-10-20', referenceRange: '10-20',
          }] }],
        },
      }];
    }
    const ids = (options.where.id as FindOperator<string[]>).value;
    return ids.length === 1 && ids[0] === reportId ? [{ id: reportId }] : [];
  },
};

const service = new SharingService(
  shareLinkRepo as never,
  {} as never,
  reportRepo as never,
  {
    find: async (options: { where: Record<string, unknown>; select?: string[] }) => {
      if (options.select?.length === 1) {
        const ids = (options.where.id as FindOperator<string[]>).value;
        return ids.length === 1 && ids[0] === labValueId ? [{ id: labValueId }] : [];
      }
      publicValueWhere = options.where;
      return options.where.id
        ? [{ id: labValueId, reportId, parameterName: 'HbA1c', value: '5.8', unit: '%', sampleDate: '2026-10-20', referenceRange: '4.0&#x2d;5.6' }]
        : [
            { reportId, parameterName: 'Hemoglobin', value: '14', unit: 'g/dL', sampleDate: '2026-10-20', referenceRange: null, reviewVersion: 0 },
            { reportId, parameterName: 'Unclear result', value: '<5', unit: 'mg/L', sampleDate: null, referenceRange: '0-10' },
            { reportId, parameterName: 'Ambiguous', value: '5', unit: 'mg/L', sampleDate: null, referenceRange: null, reviewVersion: 0 },
            { reportId, parameterName: 'Reviewed', value: '5', unit: 'mg/L', sampleDate: null, referenceRange: null, reviewVersion: 1 },
            { reportId, parameterName: 'Range in unit', value: '5', unit: '4-6', sampleDate: null, referenceRange: null, reviewVersion: 0 },
          ];
    },
  } as never,
  {
    create: (value: unknown) => value,
    save: async (value: { outcome: string }) => { accessEvents.push(value); },
    count: async () => accessEvents.filter((event) => event.outcome === 'access_code_rejected').length,
  } as never,
  { getProfile: async () => ({ name: 'Priya' }) } as never,
  { get: () => 'https://example.test' } as never,
  {
    getPlanLimits: async () => ({}),
    lockEntitlementForUpdate: async () => undefined,
    getShareLinkUsage: async () => ({ current: 0, limit: 3 }),
  } as never,
  { get: async () => Buffer.from('original') } as never,
);

async function main() {
  await assert.rejects(
    service.createShareLink(userId, profileId, 'selected_reports', undefined, [otherReportId]),
    BadRequestException,
  );
  assert.equal(link, undefined);
  await assert.rejects(
    service.createShareLink(userId, profileId, 'selected_reports', undefined, ['invalid']),
    BadRequestException,
  );

  const created = await service.createShareLink(
    userId,
    profileId,
    'selected_reports',
    undefined,
    [reportId],
  );
  assert.equal(created.scope, 'selected_reports');
  assert.deepEqual(created.reportIds, [reportId]);

  const publicData = await service.getPublicShareData(created.token);
  assert.equal(publicData.reports.length, 1);
  assert.deepEqual((publicReportWhere?.id as FindOperator<string[]>).value, [reportId]);
  assert.equal(publicReportWhere?.userId, userId);
  assert.equal(publicReportWhere?.profileId, profileId);
  assert.deepEqual(publicData.reports[0].labValues.map((row) => row.rangeStatus), [
    'within',
    'unknown',
    'unknown',
    'unknown',
    'unknown',
  ]);
  assert.deepEqual(publicData.reports[0].labValues.map((row) => row.referenceRange), [
    '12-16',
    '0-10',
    null,
    null,
    '4-6',
  ]);
  assert.equal(publicData.reports[0].labValues[4].unit, null);
  const original = await service.getSharedOriginal(created.token, reportId);
  assert.equal(original.fileName, 'CBC.pdf');
  assert.equal(original.data.toString(), 'original');

  const protectedLink = await service.createShareLink(
    userId,
    profileId,
    'selected_reports',
    undefined,
    [reportId],
    true,
  );
  assert.equal(protectedLink.requiresAccessCode, true);
  assert.match(protectedLink.accessCode ?? '', /^\d{6}$/);
  const listed = await service.listShareLinks(userId, profileId, true);
  assert.equal(listed[0].requiresAccessCode, true);
  assert.equal('accessCode' in listed[0], false);
  await assert.rejects(
    service.getPublicShareData(protectedLink.token),
    ForbiddenException,
  );
  await assert.rejects(
    service.getPublicShareData(protectedLink.token, '0000000'),
    ForbiddenException,
  );
  assert.equal(accessEvents.at(-1)?.outcome, 'access_code_rejected');
  const unlocked = await service.getPublicShareData(
    protectedLink.token,
    protectedLink.accessCode,
  );
  assert.equal(unlocked.reports.length, 1);

  await assert.rejects(
    service.createShareLink(
      userId, profileId, 'selected_results', undefined, [reportId], false, [otherReportId],
    ),
    BadRequestException,
  );
  const selectedResults = await service.createShareLink(
    userId, profileId, 'selected_results', undefined, [reportId], false, [labValueId],
  );
  assert.deepEqual(selectedResults.labValueIds, [labValueId]);
  const narrowPublicData = await service.getPublicShareData(selectedResults.token);
  assert.equal(narrowPublicData.reports[0].summary, null);
  assert.deepEqual((publicValueWhere?.id as FindOperator<string[]>).value, [labValueId]);
  assert.equal(narrowPublicData.reports[0].labValues.length, 1);
  assert.deepEqual(narrowPublicData.reports[0].labValues[0], {
    parameterName: 'HbA1c',
    value: '5.8',
    unit: '%',
    sampleDate: '2026-10-20',
    referenceRange: '4.0-5.6',
    rangeStatus: 'above',
  });
  await assert.rejects(
    service.getSharedOriginal(selectedResults.token, reportId),
    ShareLinkNotFoundException,
  );

  const all = await service.createShareLink(userId, profileId);
  const allPublicData = await service.getPublicShareData(all.token);
  const structuredOnly = allPublicData.reports.find((report) => report.id === otherReportId);
  assert.deepEqual(structuredOnly?.labValues, [{
    parameterName: 'Structured only',
    value: '15',
    unit: 'U/L',
    sampleDate: '2026-10-20',
    referenceRange: '10-20',
    rangeStatus: 'within',
  }]);
}

void main();
