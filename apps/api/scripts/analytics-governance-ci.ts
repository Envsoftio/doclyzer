import { readFile } from 'node:fs/promises';
import { randomUUID } from 'node:crypto';
import { NestFactory } from '@nestjs/core';
import { getRepositoryToken } from '@nestjs/typeorm';
import type { Repository } from 'typeorm';
import { AppModule } from '../src/app.module';
import { AnalyticsGovernanceService } from '../src/modules/analytics-admin/analytics-governance.service';
import type {
  AnalyticsFieldClassification,
  AnalyticsGovernanceValidationResult,
} from '../src/modules/analytics-admin/analytics-governance.types';
import { AnalyticsTaxonomyFieldEntity } from '../src/database/entities/analytics-taxonomy-field.entity';
import { UserEntity } from '../src/database/entities/user.entity';

interface AllowListFieldInput {
  name: string;
  classification: AnalyticsFieldClassification;
  allowList: boolean;
  notes?: string;
}

interface AllowListEventInput {
  eventName: string;
  fields: AllowListFieldInput[];
}

interface AllowListFile {
  events: AllowListEventInput[];
}

interface ProposedFieldInput {
  name: string;
  type: string;
  classification: AnalyticsFieldClassification;
}

interface ProposedEventInput {
  eventName: string;
  changeSummary?: string;
  fields: ProposedFieldInput[];
}

interface ProposedFile {
  events: ProposedEventInput[];
}

const DEFAULT_ALLOWLIST_PATH =
  '.github/analytics-governance/allowlist.json';
const DEFAULT_PROPOSED_PATH =
  '.github/analytics-governance/proposed.json';
const DEFAULT_ACTOR_EMAIL = 'ci-governance@doclyzer.local';

function readJsonFile<T>(path: string): Promise<T> {
  return readFile(path, 'utf8').then((raw) => JSON.parse(raw) as T);
}

async function ensureActor(
  userRepo: Repository<UserEntity>,
  email: string,
): Promise<UserEntity> {
  const existing = await userRepo.findOne({ where: { email } });
  if (existing) {
    if (existing.role !== 'superadmin') {
      await userRepo.update(existing.id, { role: 'superadmin' });
      return { ...existing, role: 'superadmin' };
    }
    return existing;
  }

  const user = userRepo.create({
    email,
    role: 'superadmin',
    emailVerified: true,
    displayName: 'CI Governance Gate',
    passwordHash: null,
  });
  return userRepo.save(user);
}

async function seedAllowList(
  repo: Repository<AnalyticsTaxonomyFieldEntity>,
  allowList: AllowListFile,
): Promise<void> {
  const rows = allowList.events.flatMap((event) =>
    event.fields.map((field) => ({
      eventName: event.eventName,
      fieldName: field.name,
      classification: field.classification,
      allowList: field.allowList,
      notes: field.notes ?? null,
    })),
  );

  if (rows.length === 0) {
    throw new Error('Allow-list file contains no fields to seed.');
  }

  await repo.upsert(rows, ['eventName', 'fieldName']);
}

function formatReviewRequests(
  result: AnalyticsGovernanceValidationResult,
): string {
  if (!result.reviewRequests || result.reviewRequests.length === 0) {
    return 'No review requests reported.';
  }
  return result.reviewRequests
    .map(
      (request) =>
        `- ${request.field}: ${request.reason} (${request.classification})`,
    )
    .join('\n');
}

async function run(): Promise<void> {
  const allowListPath =
    process.env.GOVERNANCE_ALLOWLIST_PATH ?? DEFAULT_ALLOWLIST_PATH;
  const proposedPath =
    process.env.GOVERNANCE_PROPOSED_PATH ?? DEFAULT_PROPOSED_PATH;
  const actorEmail =
    process.env.GOVERNANCE_CI_ACTOR_EMAIL ?? DEFAULT_ACTOR_EMAIL;

  const allowList = await readJsonFile<AllowListFile>(allowListPath);
  const proposed = await readJsonFile<ProposedFile>(proposedPath);

  const app = await NestFactory.createApplicationContext(AppModule, {
    logger: ['error', 'warn'],
  });

  try {
    const taxonomyRepo = app.get<Repository<AnalyticsTaxonomyFieldEntity>>(
      getRepositoryToken(AnalyticsTaxonomyFieldEntity),
    );
    const userRepo = app.get<Repository<UserEntity>>(
      getRepositoryToken(UserEntity),
    );
    const governanceService = app.get(AnalyticsGovernanceService);

    const actor = await ensureActor(userRepo, actorEmail);
    await seedAllowList(taxonomyRepo, allowList);

    let hasFailures = false;

    for (const event of proposed.events) {
      const correlationId = randomUUID();
      const result = await governanceService.validateInstrumentation({
        actorUserId: actor.id,
        correlationId,
        dto: {
          eventName: event.eventName,
          changeSummary: event.changeSummary,
          fields: event.fields,
        },
      });

      if (result.state === 'review_required') {
        hasFailures = true;
        console.error(
          `Governance review required for ${event.eventName}: ${result.message}`,
        );
        console.error(formatReviewRequests(result));
      } else {
        console.log(`Governance approved for ${event.eventName}.`);
      }
    }

    if (hasFailures) {
      process.exitCode = 1;
    }
  } catch (error) {
    const err = error as Error & {
      response?: {
        message?: string;
        details?: {
          violations?: Array<{ field: string; code: string; hint: string }>;
          remediationHints?: string[];
        };
      };
    };
    console.error('Governance gate failed:', err.message);
    if (err.response?.details?.violations?.length) {
      for (const v of err.response.details.violations) {
        console.error(`  PHI violation — field: ${v.field}, code: ${v.code}`);
        console.error(`    Hint: ${v.hint}`);
      }
    } else if (err.response?.message) {
      console.error(err.response.message);
    }
    process.exitCode = 1;
  } finally {
    await app.close().catch((closeErr) => {
      console.error('Failed to close application context:', closeErr);
    });
  }
}

run().catch((error) => {
  console.error('Governance gate crashed:', error);
  process.exit(1);
});
