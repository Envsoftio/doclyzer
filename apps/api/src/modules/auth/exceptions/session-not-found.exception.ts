import { NotFoundException } from '@nestjs/common';
import { SESSION_NOT_FOUND } from '../auth.types';

export class SessionNotFoundException extends NotFoundException {
  constructor() {
    super({ code: SESSION_NOT_FOUND, message: 'Session not found' });
  }
}
