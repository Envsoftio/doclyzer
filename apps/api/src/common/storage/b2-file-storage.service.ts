import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  DeleteObjectCommand,
  GetObjectCommand,
  PutObjectCommand,
  S3Client,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import type { StorageConfig } from '../../config/storage.config';
import type { FileStorageService } from './file-storage.interface';
import {
  FileStorageException,
  FILE_STORAGE_DELETE_FAILED,
  FILE_STORAGE_GET_URL_FAILED,
  FILE_STORAGE_UPLOAD_FAILED,
  StorageConfigurationException,
} from './file-storage.types';

@Injectable()
export class B2FileStorageService implements FileStorageService {
  private readonly client: S3Client;
  private readonly bucket: string;

  constructor(private readonly configService: ConfigService) {
    const storage = this.configService.get<StorageConfig>('storage');
    if (
      !storage?.b2KeyId ||
      !storage?.b2ApplicationKey ||
      !storage?.b2Bucket ||
      !storage?.b2Endpoint
    ) {
      throw new StorageConfigurationException(
        'B2 storage requires B2_KEY_ID, B2_APPLICATION_KEY, B2_BUCKET_NAME, B2_ENDPOINT',
      );
    }
    this.bucket = storage.b2Bucket;
    this.client = new S3Client({
      endpoint: storage.b2Endpoint,
      region: storage.b2Region,
      forcePathStyle: true,
      credentials: {
        accessKeyId: storage.b2KeyId,
        secretAccessKey: storage.b2ApplicationKey,
      },
    });
  }

  async upload(
    key: string,
    buffer: Buffer,
    contentType?: string,
  ): Promise<string> {
    try {
      await this.client.send(
        new PutObjectCommand({
          Bucket: this.bucket,
          Key: key,
          Body: buffer,
          ContentType: contentType ?? 'application/octet-stream',
        }),
      );
      return key;
    } catch {
      throw new FileStorageException(
        FILE_STORAGE_UPLOAD_FAILED,
        'Failed to upload file to storage',
      );
    }
  }

  async delete(key: string): Promise<void> {
    try {
      await this.client.send(
        new DeleteObjectCommand({
          Bucket: this.bucket,
          Key: key,
        }),
      );
    } catch {
      throw new FileStorageException(
        FILE_STORAGE_DELETE_FAILED,
        'Failed to delete file from storage',
      );
    }
  }

  async getSignedUrl(key: string, expiresInSeconds = 300): Promise<string> {
    try {
      const command = new GetObjectCommand({
        Bucket: this.bucket,
        Key: key,
      });
      return await getSignedUrl(this.client, command, {
        expiresIn: expiresInSeconds,
      });
    } catch {
      throw new FileStorageException(
        FILE_STORAGE_GET_URL_FAILED,
        'Failed to generate signed URL',
      );
    }
  }
}
