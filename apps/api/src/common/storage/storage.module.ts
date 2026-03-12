import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import type { StorageConfig } from '../../config/storage.config';
import { B2FileStorageService } from './b2-file-storage.service';
import { InMemoryFileStorageService } from './in-memory-file-storage.service';

export const FILE_STORAGE = 'FILE_STORAGE';

@Module({
  imports: [ConfigModule],
  providers: [
    {
      provide: FILE_STORAGE,
      useFactory: (config: ConfigService) => {
        const storage = config.get<StorageConfig>('storage');
        const useB2 =
          !storage?.b2Disabled &&
          storage?.b2KeyId &&
          storage?.b2ApplicationKey &&
          storage?.b2Bucket &&
          storage?.b2Endpoint;
        return useB2
          ? new B2FileStorageService(config)
          : new InMemoryFileStorageService();
      },
      inject: [ConfigService],
    },
  ],
  exports: [FILE_STORAGE],
})
export class StorageModule {}
