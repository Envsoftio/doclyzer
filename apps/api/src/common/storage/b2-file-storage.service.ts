import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  DeleteObjectCommand,
  GetObjectCommand,
  ListObjectVersionsCommand,
  PutObjectCommand,
  S3Client,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { createHash } from 'node:crypto';
import type { StorageConfig } from '../../config/storage.config';
import type { FileStorageService } from './file-storage.interface';
import {
  FileStorageException,
  FILE_STORAGE_DELETE_FAILED,
  FILE_STORAGE_GET_FAILED,
  FILE_STORAGE_GET_URL_FAILED,
  FILE_STORAGE_UPLOAD_FAILED,
  StorageConfigurationException,
} from './file-storage.types';
import { redactSecrets } from '../redact-secrets';

@Injectable()
export class B2FileStorageService implements FileStorageService {
  readonly durability = 'durable' as const;
  private readonly logger = new Logger(B2FileStorageService.name);
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

  private keyFingerprint(key: string): string {
    return createHash('sha256').update(key).digest('hex').slice(0, 12);
  }

  async upload(
    key: string,
    buffer: Buffer,
    contentType?: string,
    options?: { singleVersion?: boolean },
  ): Promise<string> {
    try {
      // Snapshot before PUT: never delete a version created by a later writer.
      // Avatar callers serialize replacements with a database row lock.
      const previous = options?.singleVersion
        ? await this.objectVersions(key)
        : [];
      await this.client.send(
        new PutObjectCommand({
          Bucket: this.bucket,
          Key: key,
          Body: buffer,
          ContentType: contentType ?? 'application/octet-stream',
          ...(options?.singleVersion
            ? { CacheControl: 'private, no-store' }
            : {}),
        }),
      );
      await this.deleteVersions(key, previous);
      return key;
    } catch (err) {
      this.logger.warn(
        redactSecrets(
          `Upload failed for keyFingerprint=${this.keyFingerprint(key)}: ${err instanceof Error ? err.message : String(err)}`,
        ),
      );
      throw new FileStorageException(
        FILE_STORAGE_UPLOAD_FAILED,
        'Failed to upload file to storage',
      );
    }
  }

  private async objectVersions(key: string): Promise<string[]> {
    const versions: string[] = [];
    let keyMarker: string | undefined;
    let versionMarker: string | undefined;
    do {
      const page = await this.client.send(
        new ListObjectVersionsCommand({
          Bucket: this.bucket,
          Prefix: key,
          KeyMarker: keyMarker,
          VersionIdMarker: versionMarker,
        }),
      );
      for (const item of [
        ...(page.Versions ?? []),
        ...(page.DeleteMarkers ?? []),
      ]) {
        if (item.Key === key && item.VersionId) versions.push(item.VersionId);
      }
      if (!page.IsTruncated) break;
      if (!page.NextKeyMarker)
        throw new Error('Missing storage pagination marker');
      keyMarker = page.NextKeyMarker;
      versionMarker = page.NextVersionIdMarker;
    } while (true);
    return versions;
  }

  private async deleteVersions(key: string, versions: string[]): Promise<void> {
    for (const version of versions) {
      await this.client.send(
        new DeleteObjectCommand({
          Bucket: this.bucket,
          Key: key,
          VersionId: version,
        }),
      );
    }
  }

  async get(key: string): Promise<Buffer> {
    try {
      const response = await this.client.send(
        new GetObjectCommand({
          Bucket: this.bucket,
          Key: key,
        }),
      );
      const stream = response.Body;
      if (!stream) {
        throw new FileStorageException(
          FILE_STORAGE_GET_FAILED,
          'Empty response from storage',
        );
      }
      const chunks: Uint8Array[] = [];
      for await (const chunk of stream as AsyncIterable<Uint8Array>) {
        chunks.push(chunk);
      }
      return Buffer.concat(chunks);
    } catch (err) {
      this.logger.warn(
        redactSecrets(
          `Get failed for keyFingerprint=${this.keyFingerprint(key)}: ${err instanceof Error ? err.message : String(err)}`,
        ),
      );
      throw new FileStorageException(
        FILE_STORAGE_GET_FAILED,
        'Failed to get file from storage',
      );
    }
  }

  async delete(
    key: string,
    options?: { allVersions?: boolean },
  ): Promise<void> {
    try {
      if (options?.allVersions) {
        await this.deleteVersions(key, await this.objectVersions(key));
        return;
      }
      await this.client.send(
        new DeleteObjectCommand({
          Bucket: this.bucket,
          Key: key,
        }),
      );
    } catch (err) {
      this.logger.warn(
        redactSecrets(
          `Delete failed for keyFingerprint=${this.keyFingerprint(key)}: ${err instanceof Error ? err.message : String(err)}`,
        ),
      );
      throw new FileStorageException(
        FILE_STORAGE_DELETE_FAILED,
        'Failed to delete file from storage',
      );
    }
  }

  async deletePrefix(prefix: string): Promise<void> {
    if (!prefix || !prefix.endsWith('/'))
      throw new Error('Unsafe storage prefix');
    let keyMarker: string | undefined;
    let versionMarker: string | undefined;
    do {
      const page = await this.client.send(
        new ListObjectVersionsCommand({
          Bucket: this.bucket,
          Prefix: prefix,
          KeyMarker: keyMarker,
          VersionIdMarker: versionMarker,
        }),
      );
      for (const item of [
        ...(page.Versions ?? []),
        ...(page.DeleteMarkers ?? []),
      ]) {
        if (item.Key?.startsWith(prefix) && item.VersionId) {
          await this.client.send(
            new DeleteObjectCommand({
              Bucket: this.bucket,
              Key: item.Key,
              VersionId: item.VersionId,
            }),
          );
        }
      }
      if (!page.IsTruncated) return;
      if (!page.NextKeyMarker)
        throw new Error('Missing storage pagination marker');
      keyMarker = page.NextKeyMarker;
      versionMarker = page.NextVersionIdMarker;
    } while (true);
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
    } catch (err) {
      this.logger.warn(
        redactSecrets(
          `getSignedUrl failed for keyFingerprint=${this.keyFingerprint(key)}: ${err instanceof Error ? err.message : String(err)}`,
        ),
      );
      throw new FileStorageException(
        FILE_STORAGE_GET_URL_FAILED,
        'Failed to generate signed URL',
      );
    }
  }
}
