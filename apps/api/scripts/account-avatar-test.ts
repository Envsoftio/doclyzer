import 'reflect-metadata';
import assert from 'node:assert/strict';
import { ConfigService } from '@nestjs/config';
import {
  DeleteObjectCommand,
  ListObjectVersionsCommand,
  PutObjectCommand,
} from '@aws-sdk/client-s3';
import { B2FileStorageService } from '../src/common/storage/b2-file-storage.service';
import { AccountService } from '../src/modules/account/account.service';

async function main() {
  const storage = new B2FileStorageService(
    new ConfigService({
      storage: {
        b2KeyId: 'test',
        b2ApplicationKey: 'test',
        b2Bucket: 'test',
        b2Endpoint: 'https://s3.us-west-004.backblazeb2.com',
        b2Region: 'us-west-004',
      },
    }),
  );
  const calls: any[] = [];
  let failPut = false;
  (storage as any).client = {
    send: async (command: any) => {
      calls.push(command);
      if (command instanceof ListObjectVersionsCommand)
        return command.input.KeyMarker
          ? { Versions: [{ Key: 'avatars/user/photo', VersionId: 'old-2' }] }
          : {
              Versions: [
                { Key: 'avatars/user/photo', VersionId: 'old-1' },
                { Key: 'avatars/user/photo-other', VersionId: 'unrelated' },
              ],
              DeleteMarkers: [
                { Key: 'avatars/user/photo', VersionId: 'marker' },
              ],
              IsTruncated: true,
              NextKeyMarker: 'avatars/user/photo',
              NextVersionIdMarker: 'old-1',
            };
      if (command instanceof PutObjectCommand && failPut)
        throw new Error('synthetic failure');
      return { VersionId: 'new' };
    },
  };
  await storage.upload('avatars/user/photo', Buffer.from('new'), 'image/png', {
    singleVersion: true,
  });
  assert.deepEqual(
    calls
      .filter((c) => c instanceof DeleteObjectCommand)
      .map((c) => c.input.VersionId),
    ['old-1', 'marker', 'old-2'],
  );
  assert(
    calls.findIndex((c) => c instanceof PutObjectCommand) <
      calls.findIndex((c) => c instanceof DeleteObjectCommand),
  );
  calls.length = 0;
  failPut = true;
  await assert.rejects(
    storage.upload('avatars/user/photo', Buffer.from('bad'), 'image/png', {
      singleVersion: true,
    }),
  );
  assert(
    !calls.some((c) => c instanceof DeleteObjectCommand),
    'failed upload must keep the current photo',
  );
  calls.length = 0;
  await storage.delete('avatars/user/photo', { allVersions: true });
  assert.equal(calls.filter((c) => c instanceof DeleteObjectCommand).length, 3);
  assert(
    calls
      .filter((c) => c instanceof DeleteObjectCommand)
      .every((c) => c.input.VersionId),
  );

  const user = { id: 'user', avatarUrl: 'avatars/user.jpg' };
  const uploads: any[] = [];
  const manager = {
    findOne: async (_entity: any, options: any) => {
      assert.equal(options.lock.mode, 'pessimistic_write');
      return user;
    },
    save: async () => user,
  };
  const service = Object.create(AccountService.prototype) as AccountService;
  Object.assign(service, {
    userRepo: { manager: { transaction: async (fn: any) => fn(manager) } },
    fileStorage: {
      upload: async (...args: any[]) => {
        uploads.push(args);
        return args[0];
      },
      delete: async () =>
        assert.fail('replacement must never delete its stable key'),
    },
    getProfile: async () => user,
  });
  await service.updateAvatar('user', Buffer.from('one'), 'image/jpeg');
  await service.updateAvatar('user', Buffer.from('two'), 'image/png');
  assert(
    uploads.every(
      (args) => args[0] === 'avatars/user.jpg' && args[3].singleVersion,
    ),
  );
  assert.equal(uploads[1][2], 'image/png');
  console.log(
    'Avatar regressions passed: stable key, format changes, row lock, version cleanup, upload failure and scoped deletion.',
  );
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
