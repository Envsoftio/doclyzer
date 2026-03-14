export interface FileStorageService {
  upload(key: string, buffer: Buffer, contentType?: string): Promise<string>;
  delete(key: string): Promise<void>;
  get(key: string): Promise<Buffer>;
  getSignedUrl(key: string, expiresInSeconds?: number): Promise<string>;
}
