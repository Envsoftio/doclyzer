import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import type { StorageConfig } from '../../config/storage.config';
import { B2FileStorageService } from './b2-file-storage.service';
import { InMemoryFileStorageService } from './in-memory-file-storage.service';
import { StorageConfigurationException } from './file-storage.types';

export const FILE_STORAGE = 'FILE_STORAGE';

export function createFileStorage(config: ConfigService) {
  const storage = config.get<StorageConfig>('storage');
  const useB2 =
    !storage?.b2Disabled &&
    storage?.b2KeyId &&
    storage?.b2ApplicationKey &&
    storage?.b2Bucket &&
    storage?.b2Endpoint;
  if (!useB2 && process.env.NODE_ENV === 'production') {
    throw new StorageConfigurationException(
      'Production requires configured B2 storage',
    );
  }
  return useB2
    ? new B2FileStorageService(config)
    : new InMemoryFileStorageService();
}

@Module({
  imports: [ConfigModule],
  providers: [
    {
      provide: FILE_STORAGE,
      useFactory: createFileStorage,
      inject: [ConfigService],
    },
  ],
  exports: [FILE_STORAGE],
})
export class StorageModule {}
