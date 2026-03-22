import { NotFoundException } from '@nestjs/common';
import { SHARE_LINK_NOT_FOUND } from '../sharing.types';

export class ShareLinkNotFoundException extends NotFoundException {
  constructor() {
    super({ code: SHARE_LINK_NOT_FOUND, message: 'Share link not found' });
  }
}
