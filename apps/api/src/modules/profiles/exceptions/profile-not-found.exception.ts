import { NotFoundException } from '@nestjs/common';
import { PROFILE_NOT_FOUND } from '../profiles.types';

export class ProfileNotFoundException extends NotFoundException {
  constructor() {
    super({ code: PROFILE_NOT_FOUND, message: 'Profile not found' });
  }
}
