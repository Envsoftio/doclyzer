import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { AccountService } from './account.service';

@Injectable()
export class AccountDeletionCleanupService
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(AccountDeletionCleanupService.name);
  private timer: NodeJS.Timeout | null = null;

  constructor(private readonly accounts: AccountService) {}

  onModuleInit(): void {
    if (
      process.env.REPORT_PROCESS_ROLE &&
      process.env.REPORT_PROCESS_ROLE !== 'api'
    )
      return;
    this.timer = setInterval(() => void this.run(), 60 * 60 * 1000);
    this.timer.unref?.();
    void this.run();
  }

  onModuleDestroy(): void {
    if (this.timer) clearInterval(this.timer);
  }

  private async run(): Promise<void> {
    try {
      const count = await this.accounts.purgeExpiredClosures();
      if (count) this.logger.log(`Purged ${count} expired accounts`);
    } catch (error) {
      this.logger.warn(
        `Account purge sweep failed: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }
}
