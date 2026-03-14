import { Injectable, Logger } from '@nestjs/common';
import type { FileStorageService } from './file-storage.interface';
import {
  FileStorageException,
  FILE_STORAGE_GET_FAILED,
} from './file-storage.types';

@Injectable()
export class InMemoryFileStorageService implements FileStorageService {
  private readonly logger = new Logger(InMemoryFileStorageService.name);
  private readonly store = new Map<string, Buffer>();

  constructor() {
    const isProduction = process.env.NODE_ENV === 'production';
    this.logger.warn(
      'Using in-memory file storage (B2 disabled or not configured). Files are not persisted.',
    );
    if (isProduction) {
      this.logger.error(
        'PRODUCTION: B2 storage is disabled or misconfigured. Uploaded files will be lost on restart. Configure B2_KEY_ID, B2_APPLICATION_KEY, B2_BUCKET_NAME, B2_ENDPOINT.',
      );
    }
  }

  // eslint-disable-next-line @typescript-eslint/no-unused-vars -- interface requires param; stub ignores
  upload(key: string, buffer: Buffer, _contentType?: string): Promise<string> {
    this.store.set(key, Buffer.from(buffer));
    return Promise.resolve(key);
  }

  async get(key: string): Promise<Buffer> {
    const buffer = this.store.get(key);
    if (!buffer) {
      throw new FileStorageException(
        FILE_STORAGE_GET_FAILED,
        'File not found in storage',
      );
    }
    return Promise.resolve(Buffer.from(buffer));
  }

  delete(key: string): Promise<void> {
    this.store.delete(key);
    return Promise.resolve();
  }

  // eslint-disable-next-line @typescript-eslint/no-unused-vars -- in-memory stub ignores expiry
  async getSignedUrl(key: string, _expiresInSeconds?: number): Promise<string> {
    const buffer = this.store.get(key);
    if (!buffer) {
      return '';
    }
    const base64 = buffer.toString('base64');
    return Promise.resolve(`data:application/octet-stream;base64,${base64}`);
  }
}
