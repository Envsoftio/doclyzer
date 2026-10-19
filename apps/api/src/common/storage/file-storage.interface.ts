export interface FileStorageService {
  /** Async acceptance requires an explicitly durable adapter. */
  readonly durability?: 'durable' | 'ephemeral';
  upload(key: string, buffer: Buffer, contentType?: string): Promise<string>;
  delete(key: string): Promise<void>;
  get(key: string): Promise<Buffer>;
  getSignedUrl(key: string, expiresInSeconds?: number): Promise<string>;
}
