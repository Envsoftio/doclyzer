import { BadRequestException } from '@nestjs/common';

export const FILE_STORAGE_UPLOAD_FAILED = 'FILE_STORAGE_UPLOAD_FAILED';
export const FILE_STORAGE_DELETE_FAILED = 'FILE_STORAGE_DELETE_FAILED';
export const FILE_STORAGE_GET_FAILED = 'FILE_STORAGE_GET_FAILED';
export const FILE_STORAGE_GET_URL_FAILED = 'FILE_STORAGE_GET_URL_FAILED';
export const FILE_STORAGE_CONFIG_INVALID = 'FILE_STORAGE_CONFIG_INVALID';

export class FileStorageException extends BadRequestException {
  constructor(code: string, message: string) {
    super({ code, message });
  }
}

export class StorageConfigurationException extends BadRequestException {
  constructor(message: string) {
    super({ code: FILE_STORAGE_CONFIG_INVALID, message });
  }
}
