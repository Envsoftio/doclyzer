import 'reflect-metadata';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { ConfigService } from '@nestjs/config';
import { ListObjectVersionsCommand, S3Client } from '@aws-sdk/client-s3';
import { B2FileStorageService } from '../src/common/storage/b2-file-storage.service';

async function main() {
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
  const key = `avatars/verification-${randomUUID()}/photo`;
  const png = Buffer.from(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
    'base64',
  );
  const list = () =>
    client.send(
      new ListObjectVersionsCommand({ Bucket: config.b2Bucket, Prefix: key }),
    );
  try {
    await storage.upload(key, png, 'image/png', { singleVersion: true });
    const first = (await list()).Versions?.find(
      (v) => v.Key === key,
    )?.VersionId;
    assert(first);
    await storage.upload(key, png, 'image/png', { singleVersion: true });
    const versions = await list();
    const exact = versions.Versions?.filter((v) => v.Key === key) ?? [];
    assert.equal(exact.length, 1);
    assert.notEqual(exact[0].VersionId, first);
    assert.equal(
      (versions.DeleteMarkers ?? []).filter((v) => v.Key === key).length,
      0,
    );
    assert.deepEqual(await storage.get(key), png);
    const response = await fetch(await storage.getSignedUrl(key));
    assert(response.ok);
    assert.equal(response.headers.get('content-type'), 'image/png');
    console.log(
      'Live B2 passed: two uploads, one retained version, signed image readable.',
    );
  } finally {
    await storage.delete(key, { allVersions: true });
    const remaining = await list();
    assert.equal(
      (remaining.Versions ?? []).filter((v) => v.Key === key).length,
      0,
    );
    console.log('Synthetic B2 photo and all versions removed.');
    client.destroy();
  }
}
main().catch(() => {
  console.error(
    'Live B2 verification failed; check storage permissions/configuration.',
  );
  process.exitCode = 1;
});
