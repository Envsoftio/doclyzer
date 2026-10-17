import { hash } from 'bcryptjs';
import { UserEntity } from '../entities/user.entity';
import { AppDataSource } from '../data-source';

/**
 * Seed script to create a superadmin user.
 * Usage: npx ts-node src/database/seeds/superadmin.seed.ts
 */
async function seedSuperadmin() {
  const dataSource = AppDataSource;

  if (!dataSource.isInitialized) {
    await dataSource.initialize();
  }

  const userRepo = dataSource.getRepository(UserEntity);

  const email = 'vishnu@envsoft.io';
  const password = 'Demo@123';

  // Check if user already exists
  const existingUser = await userRepo.findOne({ where: { email } });
  if (existingUser) {
    const passwordHash = await hash(password, 10);
    await userRepo.update(existingUser.id, {
      role: 'superadmin',
      emailVerified: true,
      passwordHash,
    });
    await dataSource.query(
      `INSERT INTO "accounts" (
        "user_id", "provider_id", "account_id", "password_hash"
      ) VALUES ($1::uuid, 'credential', $1::text, $2)
      ON CONFLICT ("provider_id", "account_id")
      DO UPDATE SET "password_hash" = EXCLUDED."password_hash",
                    "updated_at" = now()`,
      [existingUser.id, passwordHash],
    );
    console.log(`✓ Updated existing superadmin credentials and role.`);
    await dataSource.destroy();
    return;
  }

  // Hash password
  const passwordHash = await hash(password, 10);

  // Create superadmin user
  const user = userRepo.create({
    email,
    passwordHash,
    emailVerified: true,
    displayName: 'Superadmin',
    role: 'superadmin',
  });

  const savedUser = await userRepo.save(user);
  await dataSource.query(
    `INSERT INTO "accounts" (
      "user_id", "provider_id", "account_id", "password_hash"
    ) VALUES ($1::uuid, 'credential', $1::text, $2)`,
    [savedUser.id, passwordHash],
  );
  console.log(`✓ Superadmin user created successfully!`);
  console.log(`  Email: ${email}`);
  console.log(`  Password: ${password}`);
  console.log(`  Role: superadmin`);

  await dataSource.destroy();
}

seedSuperadmin().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
