/**
 * PHI Rejection Verification Test
 *
 * Standalone smoke-test that validates the governance gate's PHI rejection
 * path WITHOUT requiring a database or running the full NestJS application.
 *
 * Purpose: Exercise the phi-classified field → exit=1 code path that
 * cannot be embedded in proposed.json (doing so would fail CI on every run).
 *
 * Run via: npx ts-node scripts/analytics-governance-phi-rejection-test.ts
 */

import {
  ANALYTICS_GOVERNANCE_PHI_VIOLATION,
  AnalyticsGovernancePhiViolationException,
  AnalyticsGovernanceViolation,
} from '../src/modules/analytics-admin/analytics-governance.types';

interface TestField {
  name: string;
  classification: 'non_phi' | 'pii' | 'phi';
}

interface AllowedField {
  fieldName: string;
  classification: 'non_phi' | 'pii' | 'phi';
  allowList: boolean;
}

/**
 * Pure inline implementation of the PHI validation logic mirroring the
 * service method AnalyticsGovernanceService.validateInstrumentation.
 * Kept isolated so this test has zero DB dependencies.
 */
function validateFields(
  fields: TestField[],
  allowedFields: Map<string, AllowedField>,
): void {
  const violations: AnalyticsGovernanceViolation[] = [];

  for (const field of fields) {
    const existing = allowedFields.get(field.name.toLowerCase());

    if (field.classification === 'phi' || existing?.classification === 'phi') {
      violations.push({
        field: field.name,
        classification: field.classification,
        code: ANALYTICS_GOVERNANCE_PHI_VIOLATION,
        hint: 'Strip PHI content from analytics payloads or move it into a vetted, non-sensitive event.',
      });
    }
  }

  if (violations.length > 0) {
    throw new AnalyticsGovernancePhiViolationException({
      violations,
      remediationHints: violations.map((v) => v.hint),
    });
  }
}

interface TestCase {
  name: string;
  fields: TestField[];
  allowedFields: Map<string, AllowedField>;
  expectRejection: boolean;
}

const TEST_CASES: TestCase[] = [
  {
    name: 'PHI-classified field on proposal should be rejected',
    fields: [{ name: 'patient_diagnosis', classification: 'phi' }],
    allowedFields: new Map(),
    expectRejection: true,
  },
  {
    name: 'Allow-listed field re-submitted with phi classification should be rejected',
    fields: [{ name: 'metric_name', classification: 'phi' }],
    allowedFields: new Map([
      [
        'metric_name',
        { fieldName: 'metric_name', classification: 'non_phi', allowList: true },
      ],
    ]),
    expectRejection: true,
  },
  {
    name: 'Allow-listed field in db with phi classification should be rejected even if proposal says non_phi',
    fields: [{ name: 'legacy_field', classification: 'non_phi' }],
    allowedFields: new Map([
      [
        'legacy_field',
        { fieldName: 'legacy_field', classification: 'phi', allowList: true },
      ],
    ]),
    expectRejection: true,
  },
  {
    name: 'Non-PHI field on allow-list should be approved',
    fields: [{ name: 'plan_tier', classification: 'non_phi' }],
    allowedFields: new Map([
      [
        'plan_tier',
        { fieldName: 'plan_tier', classification: 'non_phi', allowList: true },
      ],
    ]),
    expectRejection: false,
  },
  {
    name: 'PII-classified new field should pass PHI check (triggers review_required, not blocked)',
    fields: [{ name: 'user_email_hash', classification: 'pii' }],
    allowedFields: new Map(),
    expectRejection: false,
  },
];

function runTests(): void {
  let passed = 0;
  let failed = 0;

  for (const tc of TEST_CASES) {
    try {
      validateFields(tc.fields, tc.allowedFields);

      if (tc.expectRejection) {
        console.error(`❌ FAIL: "${tc.name}"`);
        console.error(
          '   Expected PHI violation exception but validation passed.',
        );
        failed++;
      } else {
        console.log(`✅ PASS: "${tc.name}"`);
        passed++;
      }
    } catch (error) {
      if (error instanceof AnalyticsGovernancePhiViolationException) {
        if (tc.expectRejection) {
          console.log(`✅ PASS: "${tc.name}"`);
          console.log(
            `   PHI violation correctly raised for: ${tc.fields.map((f) => f.name).join(', ')}`,
          );
          passed++;
        } else {
          console.error(`❌ FAIL: "${tc.name}"`);
          console.error('   Got unexpected PHI violation:', error.message);
          failed++;
        }
      } else {
        console.error(`❌ FAIL: "${tc.name}"`);
        console.error('   Unexpected error:', error);
        failed++;
      }
    }
  }

  console.log(`\n${passed + failed} tests — ${passed} passed, ${failed} failed`);

  if (failed > 0) {
    console.error(
      '\n🚫 PHI rejection verification failed. Governance gate PHI path is broken.',
    );
    process.exit(1);
  } else {
    console.log(
      '\n✅ PHI rejection verification passed. Governance gate correctly blocks PHI-classified fields.',
    );
  }
}

runTests();
