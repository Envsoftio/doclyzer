import { NestFactory } from '@nestjs/core';
import { ConfigService } from '@nestjs/config';
import { DataSource } from 'typeorm';
import { randomUUID } from 'node:crypto';
import { AppModule } from './app.module';
import { ReportWorkerService } from './modules/reports/processing/report-worker.service';
import { ReportDispatcherService } from './modules/reports/processing/report-dispatcher.service';
import { processingSettings } from './modules/reports/processing/processing-settings';
async function main() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const config = app.get(ConfigService),
    settings = processingSettings(config);
  if (!settings.runtime || !['worker', 'dispatcher'].includes(settings.role))
    throw new Error(
      'Set REPORT_ASYNC_RUNTIME_ENABLED=true and REPORT_PROCESS_ROLE=worker or dispatcher',
    );
  const db = app.get(DataSource),
    id = randomUUID(),
    stop = new AbortController();
  const shutdown = () => stop.abort();
  process.once('SIGTERM', shutdown);
  process.once('SIGINT', shutdown);
  const heartbeat = async () => {
    await db.query(
      `INSERT INTO report_process_health(id,role,heartbeat_at) VALUES($1,$2,clock_timestamp()) ON CONFLICT(id) DO UPDATE SET heartbeat_at=clock_timestamp()`,
      [id, settings.role],
    );
  };
  await heartbeat();
  const timer = setInterval(() => void heartbeat().catch(() => {}), 5000);
  try {
    await (
      settings.role === 'worker'
        ? app.get(ReportWorkerService)
        : app.get(ReportDispatcherService)
    ).run(stop.signal);
  } finally {
    clearInterval(timer);
    await db
      .query('DELETE FROM report_process_health WHERE id=$1', [id])
      .catch(() => {});
    await app.close();
  }
}
void main().catch(() => {
  console.error('REPORT_PROCESS_STARTUP_FAILED');
  process.exit(1);
});
