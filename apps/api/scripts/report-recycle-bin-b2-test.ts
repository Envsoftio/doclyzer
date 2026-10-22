import 'reflect-metadata';
import { strict as assert } from 'node:assert';
import { randomUUID } from 'node:crypto';
import { ConfigService } from '@nestjs/config';
import { ListObjectVersionsCommand, S3Client } from '@aws-sdk/client-s3';
import { B2FileStorageService } from '../src/common/storage/b2-file-storage.service';

async function main(): Promise<void> {
  process.loadEnvFile('../../.env');
  assert.notEqual(process.env.B2_DISABLED, 'true', 'B2 must be enabled');
  const config = {
    b2KeyId: process.env.B2_KEY_ID!,
    b2ApplicationKey: process.env.B2_APPLICATION_KEY!,
    b2Bucket: process.env.B2_BUCKET_NAME!,
    b2Endpoint: process.env.B2_ENDPOINT!,
    b2Region: process.env.B2_REGION ?? 'us-west-002',
  };
  const storage = new B2FileStorageService(
    new ConfigService({ storage: config }),
  );
  const client = new S3Client({
    endpoint: config.b2Endpoint,
    region: config.b2Region,
    forcePathStyle: true,
    credentials: {
      accessKeyId: config.b2KeyId,
      secretAccessKey: config.b2ApplicationKey,
    },
  });
  const key = `reports/verification-${randomUUID()}/synthetic.pdf`;
  const content = Buffer.from('synthetic recycle-bin B2 verification');
  const listExactVersions = async (): Promise<number> => {
    const page = await client.send(
      new ListObjectVersionsCommand({ Bucket: config.b2Bucket, Prefix: key }),
    );
    return [...(page.Versions ?? []), ...(page.DeleteMarkers ?? [])].filter(
      (item) => item.Key === key,
    ).length;
  };
  try {
    await storage.upload(key, content, 'application/pdf');
    await storage.upload(key, content, 'application/pdf');
    assert.deepEqual(await storage.get(key), content);
    assert((await listExactVersions()) >= 2);
    // A prior plain delete creates a marker in versioned B2; purge must remove it too.
    await storage.delete(key);
    assert((await listExactVersions()) >= 3);
    await storage.delete(key, { allVersions: true });
    assert.equal(await listExactVersions(), 0);
    process.stdout.write('Live B2 report file and every version deleted\n');
  } finally {
    try {
      await storage.delete(key, { allVersions: true });
    } catch (error) {
      process.stderr.write(`Synthetic B2 key may remain: ${key}\n`);
      throw error;
    } finally {
      client.destroy();
    }
  }
}

main().catch(() => {
  process.stderr.write('Live B2 report deletion check failed\n');
  process.exitCode = 1;
});
