import { InMemoryFileStorageService } from './in-memory-file-storage.service';

describe('InMemoryFileStorageService', () => {
  let service: InMemoryFileStorageService;

  beforeEach(() => {
    service = new InMemoryFileStorageService();
  });

  it('uploads and returns key', async () => {
    const key = await service.upload('avatars/user-1.jpg', Buffer.from('test'));
    expect(key).toBe('avatars/user-1.jpg');
  });

  it('getSignedUrl returns data URL for stored key', async () => {
    const buf = Buffer.from('hello');
    await service.upload('avatars/user-1.jpg', buf);
    const url = await service.getSignedUrl('avatars/user-1.jpg');
    expect(url).toMatch(/^data:application\/octet-stream;base64,/);
    expect(Buffer.from(url.split(',')[1], 'base64').toString()).toBe('hello');
  });

  it('getSignedUrl returns empty string for missing key', async () => {
    const url = await service.getSignedUrl('missing');
    expect(url).toBe('');
  });

  it('delete removes key', async () => {
    await service.upload('avatars/user-1.jpg', Buffer.from('test'));
    await service.delete('avatars/user-1.jpg');
    const url = await service.getSignedUrl('avatars/user-1.jpg');
    expect(url).toBe('');
  });
});
