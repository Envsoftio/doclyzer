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
    if (existingUser.role !== 'superadmin') {
      await userRepo.update(existingUser.id, { role: 'superadmin' });
      console.log(`✓ Updated existing user role to superadmin.`);
    } else {
      console.log(
        `Superadmin user with email ${email} already exists with correct role.`,
      );
    }
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

  await userRepo.save(user);
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
