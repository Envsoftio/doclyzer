import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { redactSecrets } from '../../common/redact-secrets';
import { ReportsService } from './reports.service';

@Injectable()
export class ReportsRecycleBinCleanupService
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(ReportsRecycleBinCleanupService.name);
  private timer: NodeJS.Timeout | null = null;
  private static readonly RUN_INTERVAL_MS = 6 * 60 * 60 * 1000;

  constructor(private readonly reportsService: ReportsService) {}

  onModuleInit(): void {
    this.timer = setInterval(() => {
      void this.runOnce();
    }, ReportsRecycleBinCleanupService.RUN_INTERVAL_MS);
    this.timer.unref?.();
    void this.runOnce();
  }

  onModuleDestroy(): void {
    if (this.timer) clearInterval(this.timer);
    this.timer = null;
  }

  private async runOnce(): Promise<void> {
    try {
      const deletedCount =
        await this.reportsService.purgeExpiredRecycleBinReports();
      if (deletedCount > 0) {
        this.logger.log(
          `Recycle bin purge removed ${deletedCount} expired report(s).`,
        );
      }
    } catch (err) {
      this.logger.warn(
        redactSecrets(
          `Recycle bin purge failed: ${err instanceof Error ? err.message : String(err)}`,
        ),
      );
    }
  }
}
