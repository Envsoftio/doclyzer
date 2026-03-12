import { Injectable, Logger } from '@nestjs/common';
import type { FileStorageService } from './file-storage.interface';

@Injectable()
export class InMemoryFileStorageService implements FileStorageService {
  private readonly logger = new Logger(InMemoryFileStorageService.name);
  private readonly store = new Map<string, Buffer>();

  constructor() {
    this.logger.warn(
      'Using in-memory file storage (B2 disabled or not configured). Files are not persisted.',
    );
  }

  // eslint-disable-next-line @typescript-eslint/no-unused-vars -- interface requires param; stub ignores
  upload(key: string, buffer: Buffer, _contentType?: string): Promise<string> {
    this.store.set(key, Buffer.from(buffer));
    return Promise.resolve(key);
  }

  delete(key: string): Promise<void> {
    this.store.delete(key);
    return Promise.resolve();
  }

  async getSignedUrl(key: string): Promise<string> {
    const buffer = this.store.get(key);
    if (!buffer) {
      return '';
    }
    const base64 = buffer.toString('base64');
    return Promise.resolve(`data:application/octet-stream;base64,${base64}`);
  }
}
