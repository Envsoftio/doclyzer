import { ForbiddenException } from '@nestjs/common';
import { PROFILE_LIMIT_EXCEEDED } from '../profiles.types';

export class ProfileLimitExceededException extends ForbiddenException {
  constructor(limit: number) {
    super({
      code: PROFILE_LIMIT_EXCEEDED,
      message: `Your plan allows ${limit} ${limit === 1 ? 'profile' : 'profiles'}. Upgrade to add more.`,
    });
  }
}
