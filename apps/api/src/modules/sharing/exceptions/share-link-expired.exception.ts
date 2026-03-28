import { HttpException, HttpStatus } from '@nestjs/common';
import { SHARE_LINK_EXPIRED_OR_REVOKED } from '../sharing.types';

export class ShareLinkExpiredException extends HttpException {
  constructor() {
    super(
      {
        code: SHARE_LINK_EXPIRED_OR_REVOKED,
        message: 'This share link has expired or been revoked',
      },
      HttpStatus.GONE,
    );
  }
}
