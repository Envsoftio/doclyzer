import { ForbiddenException } from '@nestjs/common';
import { PROFILE_LIMIT_EXCEEDED } from '../profiles.types';

export class ProfileLimitExceededException extends ForbiddenException {
  constructor() {
    super({
      code: PROFILE_LIMIT_EXCEEDED,
      message: 'Free plan allows 1 profile. Upgrade to add more.',
    });
  }
}
