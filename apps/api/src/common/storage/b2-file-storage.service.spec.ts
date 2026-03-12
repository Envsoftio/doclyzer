import { ConfigService } from '@nestjs/config';
import { S3Client } from '@aws-sdk/client-s3';
import { mockClient } from 'aws-sdk-client-mock';
import { DeleteObjectCommand, PutObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { B2FileStorageService } from './b2-file-storage.service';
import {
  FileStorageException,
  StorageConfigurationException,
} from './file-storage.types';

const s3Mock = mockClient(S3Client);

jest.mock('@aws-sdk/s3-request-presigner', () => ({
  getSignedUrl: jest.fn().mockResolvedValue('https://signed.example.com/key'),
}));

function makeConfig(overrides: Record<string, unknown> = {}) {
  return {
    get: jest.fn((key: string) => {
      const storage: Record<string, unknown> = {
        b2KeyId: 'key-id',
        b2ApplicationKey: 'app-key',
        b2Bucket: 'my-bucket',
        b2Endpoint: 'https://s3.us-west-002.backblazeb2.com',
        b2Region: 'us-west-002',
        ...overrides,
      };
      return key === 'storage' ? storage : undefined;
    }),
  } as unknown as ConfigService;
}

describe('B2FileStorageService', () => {
  beforeEach(() => {
    s3Mock.reset();
  });

  describe('constructor', () => {
    it('throws StorageConfigurationException when B2 config is missing', () => {
      const config = makeConfig({
        b2KeyId: undefined,
        b2ApplicationKey: undefined,
        b2Bucket: undefined,
        b2Endpoint: undefined,
      });
      expect(() => new B2FileStorageService(config)).toThrow(
        StorageConfigurationException,
      );
    });

    it('instantiates when all config is present', () => {
      const config = makeConfig();
      expect(() => new B2FileStorageService(config)).not.toThrow();
    });
  });

  describe('upload', () => {
    it('sends PutObjectCommand with correct params', async () => {
      const config = makeConfig();
      const service = new B2FileStorageService(config);
      s3Mock.on(PutObjectCommand).resolves({});

      const result = await service.upload(
        'avatars/user-1.jpg',
        Buffer.from('data'),
        'image/jpeg',
      );

      expect(result).toBe('avatars/user-1.jpg');
      const calls = s3Mock.commandCalls(PutObjectCommand);
      expect(calls).toHaveLength(1);
      expect(calls[0].args[0].input).toMatchObject({
        Bucket: 'my-bucket',
        Key: 'avatars/user-1.jpg',
        Body: Buffer.from('data'),
        ContentType: 'image/jpeg',
      });
    });

    it('uses application/octet-stream when contentType omitted', async () => {
      const config = makeConfig();
      const service = new B2FileStorageService(config);
      s3Mock.on(PutObjectCommand).resolves({});

      await service.upload('avatars/user-1.jpg', Buffer.from('data'));

      const calls = s3Mock.commandCalls(PutObjectCommand);
      expect(calls[0].args[0].input.ContentType).toBe(
        'application/octet-stream',
      );
    });

    it('throws FileStorageException on S3 error', async () => {
      const config = makeConfig();
      const service = new B2FileStorageService(config);
      s3Mock.on(PutObjectCommand).rejects(new Error('S3 error'));

      await expect(
        service.upload('avatars/user-1.jpg', Buffer.from('data')),
      ).rejects.toThrow(FileStorageException);
    });
  });

  describe('delete', () => {
    it('sends DeleteObjectCommand with correct params', async () => {
      const config = makeConfig();
      const service = new B2FileStorageService(config);
      s3Mock.on(DeleteObjectCommand).resolves({});

      await service.delete('avatars/user-1.jpg');

      const calls = s3Mock.commandCalls(DeleteObjectCommand);
      expect(calls).toHaveLength(1);
      expect(calls[0].args[0].input).toMatchObject({
        Bucket: 'my-bucket',
        Key: 'avatars/user-1.jpg',
      });
    });

    it('throws FileStorageException on S3 error', async () => {
      const config = makeConfig();
      const service = new B2FileStorageService(config);
      s3Mock.on(DeleteObjectCommand).rejects(new Error('S3 error'));

      await expect(service.delete('avatars/user-1.jpg')).rejects.toThrow(
        FileStorageException,
      );
    });
  });

  describe('getSignedUrl', () => {
    it('returns signed URL from presigner', async () => {
      const config = makeConfig();
      const service = new B2FileStorageService(config);
      (getSignedUrl as jest.Mock).mockResolvedValue(
        'https://signed.example.com/avatars/user-1.jpg',
      );

      const url = await service.getSignedUrl('avatars/user-1.jpg', 300);

      expect(url).toBe('https://signed.example.com/avatars/user-1.jpg');
      expect(getSignedUrl).toHaveBeenCalledWith(
        expect.any(S3Client),
        expect.objectContaining({
          input: { Bucket: 'my-bucket', Key: 'avatars/user-1.jpg' },
        }),
        { expiresIn: 300 },
      );
    });

    it('uses default 300s expiry when not specified', async () => {
      const config = makeConfig();
      const service = new B2FileStorageService(config);
      (getSignedUrl as jest.Mock).mockResolvedValue('https://signed.example/');

      await service.getSignedUrl('avatars/user-1.jpg');

      expect(getSignedUrl).toHaveBeenCalledWith(
        expect.any(S3Client),
        expect.anything(),
        { expiresIn: 300 },
      );
    });

    it('throws FileStorageException when presigner fails', async () => {
      const config = makeConfig();
      const service = new B2FileStorageService(config);
      (getSignedUrl as jest.Mock).mockRejectedValue(
        new Error('Presign failed'),
      );

      await expect(service.getSignedUrl('avatars/user-1.jpg')).rejects.toThrow(
        FileStorageException,
      );
    });
  });
});
