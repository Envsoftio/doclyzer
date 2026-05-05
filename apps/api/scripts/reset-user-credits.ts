/**
 * Reset user report usage and/or wallet credits.
 *
 * Defaults to DRY RUN. Add --apply to execute updates.
 *
 * Examples:
 *   npm run credits:reset -- --email you@example.com --scope reports --apply
 *   npm run credits:reset -- --user-id <uuid> --scope wallet --credit-balance 0 --apply
 *   npm run credits:reset -- --email you@example.com --scope both --credit-balance 100
 */

import { AppDataSource } from '../src/database/data-source';

type Scope = 'reports' | 'wallet' | 'both';

interface CliArgs {
  userId?: string;
  email?: string;
  scope: Scope;
  apply: boolean;
  creditBalance: string;
}

function parseArgs(argv: string[]): CliArgs {
  let userId: string | undefined;
  let email: string | undefined;
  let scope: Scope = 'reports';
  let apply = false;
  let creditBalance = '0';

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    const next = argv[i + 1];

    if (arg === '--user-id' && next) {
      userId = next.trim();
      i++;
      continue;
    }
    if (arg === '--email' && next) {
      email = next.trim().toLowerCase();
      i++;
      continue;
    }
    if (arg === '--scope' && next) {
      if (next === 'reports' || next === 'wallet' || next === 'both') {
        scope = next;
      } else {
        throw new Error(`Invalid --scope "${next}". Use reports|wallet|both`);
      }
      i++;
      continue;
    }
    if (arg === '--credit-balance' && next) {
      creditBalance = next.trim();
      if (!/^\d+(\.\d{1,2})?$/.test(creditBalance)) {
        throw new Error(
          'Invalid --credit-balance value. Use numeric value like 0 or 25.50',
        );
      }
      i++;
      continue;
    }
    if (arg === '--apply') {
      apply = true;
      continue;
    }
  }

  if (!userId && !email) {
    throw new Error('Provide either --user-id <uuid> or --email <email>');
  }

  return { userId, email, scope, apply, creditBalance };
}

async function resolveUserId(input: {
  userId?: string;
  email?: string;
}): Promise<{ userId: string; email: string }> {
  if (input.userId) {
    const rows: Array<{ id: string; email: string }> = await AppDataSource.query(
      `SELECT id, email FROM users WHERE id = $1 LIMIT 1`,
      [input.userId],
    );
    if (rows.length === 0) {
      throw new Error(`No user found for user_id=${input.userId}`);
    }
    return { userId: rows[0].id, email: rows[0].email };
  }

  const rows: Array<{ id: string; email: string }> = await AppDataSource.query(
    `SELECT id, email FROM users WHERE lower(email) = lower($1) LIMIT 1`,
    [input.email],
  );
  if (rows.length === 0) {
    throw new Error(`No user found for email=${input.email}`);
  }
  return { userId: rows[0].id, email: rows[0].email };
}

async function run(): Promise<void> {
  const args = parseArgs(process.argv.slice(2));
  await AppDataSource.initialize();

  try {
    const user = await resolveUserId({ userId: args.userId, email: args.email });

    console.log(`\nTarget user: ${user.email} (${user.userId})`);
    console.log(`Scope: ${args.scope}`);
    console.log(`Mode: ${args.apply ? 'APPLY' : 'DRY RUN'}\n`);

    if (args.scope === 'reports' || args.scope === 'both') {
      const beforeRows: Array<{ count: string }> = await AppDataSource.query(
        `SELECT COUNT(*)::text AS count
         FROM reports
         WHERE user_id = $1
           AND status = 'parsed'
           AND deleted_at IS NULL`,
        [user.userId],
      );
      const before = Number(beforeRows[0]?.count ?? '0');
      console.log(`Parsed active reports (counted usage): ${before}`);

      if (args.apply) {
        const updatedRows: Array<{ count: string }> = await AppDataSource.query(
          `WITH updated AS (
             UPDATE reports
             SET deleted_at = NOW(),
                 purge_after_at = NOW() + INTERVAL '30 days',
                 updated_at = NOW()
             WHERE user_id = $1
               AND status = 'parsed'
               AND deleted_at IS NULL
             RETURNING id
           )
           SELECT COUNT(*)::text AS count FROM updated`,
          [user.userId],
        );
        console.log(`Archived parsed reports: ${updatedRows[0]?.count ?? '0'}`);
      } else {
        console.log('Would archive parsed reports to reset report usage to zero.');
      }
      console.log('');
    }

    if (args.scope === 'wallet' || args.scope === 'both') {
      const beforeRows: Array<{ credit_balance: string }> =
        await AppDataSource.query(
          `SELECT credit_balance::text
           FROM user_entitlements
           WHERE user_id = $1
           LIMIT 1`,
          [user.userId],
        );
      if (beforeRows.length === 0) {
        throw new Error(
          `No entitlement row found for user_id=${user.userId}. User may need entitlement provisioning first.`,
        );
      }
      const before = beforeRows[0].credit_balance;
      console.log(`Wallet credit balance (before): ${before}`);
      console.log(`Wallet credit balance (target): ${args.creditBalance}`);

      if (args.apply) {
        await AppDataSource.query(
          `UPDATE user_entitlements
           SET credit_balance = $2,
               last_change_reason = 'manual_credit_reset_script',
               last_change_at = NOW(),
               updated_at = NOW()
           WHERE user_id = $1`,
          [user.userId, args.creditBalance],
        );
      } else {
        console.log('Would update user_entitlements.credit_balance.');
      }

      const afterRows: Array<{ credit_balance: string }> =
        await AppDataSource.query(
          `SELECT credit_balance::text
           FROM user_entitlements
           WHERE user_id = $1
           LIMIT 1`,
          [user.userId],
        );
      console.log(`Wallet credit balance (after): ${afterRows[0].credit_balance}`);
      console.log('');
    }

    console.log(
      args.apply
        ? 'Completed.'
        : 'Dry run completed. Re-run with --apply to persist changes.',
    );
  } finally {
    await AppDataSource.destroy();
  }
}

run().catch((error: unknown) => {
  const err = error as Error;
  console.error(`Reset script failed: ${err.message ?? String(error)}`);
  process.exit(1);
});

