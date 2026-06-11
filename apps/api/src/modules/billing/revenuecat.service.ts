import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class RevenueCatService {
  private readonly logger = new Logger(RevenueCatService.name);

  constructor(private readonly configService: ConfigService) {}

  verifyWebhookAuthorization(authorizationHeader: string | null): boolean {
    const expected = this.configService.get<string>(
      'revenueCat.webhookAuthorization',
      '',
    );
    if (!expected.trim()) {
      this.logger.warn('RevenueCat webhook authorization is not configured');
      return false;
    }

    return authorizationHeader === expected;
  }
}
