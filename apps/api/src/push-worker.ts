import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { PushCampaignService } from './modules/notifications/push-campaign.service';
async function main() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const service = app.get(PushCampaignService);
  let stopped = false,
    nextRetention = 0;
  process.once('SIGTERM', () => {
    stopped = true;
  });
  process.once('SIGINT', () => {
    stopped = true;
  });
  try {
    while (!stopped) {
      try {
        await service.tick();
        if (Date.now() > nextRetention) {
          await service.retain();
          nextRetention = Date.now() + 3600000;
        }
      } catch {
        console.error('PUSH_WORKER_ITERATION_FAILED');
      }
      if (!stopped) await new Promise((resolve) => setTimeout(resolve, 1000));
    }
  } finally {
    await app.close();
  }
}
void main().catch(() => {
  console.error('PUSH_WORKER_STARTUP_FAILED');
  process.exitCode = 1;
});
