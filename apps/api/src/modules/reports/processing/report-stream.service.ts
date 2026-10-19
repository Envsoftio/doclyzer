import { Injectable, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { DataSource } from 'typeorm';
import { Client } from 'pg';
import { EventEmitter } from 'node:events';
import { processingSettings } from './processing-settings';
@Injectable()
export class ReportStreamService {
  readonly wake = new EventEmitter();
  private listener: Client | null = null;
  private reconnect: NodeJS.Timeout | null = null;
  private stopped = false;
  constructor(
    private readonly db: DataSource,
    private readonly config: ConfigService,
  ) {
    this.wake.setMaxListeners(0);
  }
  onModuleInit() {
    if (
      processingSettings(this.config).runtime &&
      processingSettings(this.config).role === 'api'
    )
      void this.listen();
  }
  onModuleDestroy() {
    this.stopped = true;
    if (this.reconnect) clearTimeout(this.reconnect);
    void this.listener?.end().catch(() => {});
  }
  private async listen() {
    if (this.stopped) return;
    const client = new Client({
      connectionString: this.config.get<string>('DATABASE_URL'),
    });
    this.listener = client;
    let retried = false;
    const retry = () => {
      if (retried || this.stopped) return;
      retried = true;
      void client.end().catch(() => {});
      this.reconnect = setTimeout(() => void this.listen(), 5000);
    };
    client.on('error', retry);
    client.on('end', retry);
    client.on('notification', (n) => {
      if (n.payload) this.wake.emit(n.payload);
    });
    try {
      await client.connect();
      await client.query('LISTEN report_events');
    } catch {
      retry();
    }
  }
  assertEnabled() {
    if (!processingSettings(this.config).runtime)
      throw new ServiceUnavailableException({ code: 'REPORT_ASYNC_DISABLED' });
  }
  async snapshot(userId: string) {
    this.assertEnabled();
    return this.db.transaction('REPEATABLE READ', async (m) => {
      const [cursor] = await m.query(
        'SELECT last_cursor FROM report_event_cursors WHERE user_id=$1',
        [userId],
      );
      const reports = await m.query(
        `SELECT id AS "reportId",profile_id AS "profileId",processing_version AS version,processing_generation AS generation,
        processing_state AS status,processing_stage AS stage,processing_error_code AS "errorCode",processing_retry_at AS "retryAt",
        processing_acknowledged_at AS "acknowledgedAt" FROM reports WHERE user_id=$1 AND deleted_at IS NULL AND processing_generation>0`,
        [userId],
      );
      return { schemaVersion: 1, cursor: cursor?.last_cursor ?? '0', reports };
    });
  }
  async replay(userId: string, cursor: string) {
    if (!/^(0|[1-9][0-9]{0,18})$/.test(cursor))
      return { reset: true, events: [] };
    return this.db.transaction('REPEATABLE READ', async (m) => {
      const [watermark] = await m.query(
        'SELECT * FROM report_event_cursors WHERE user_id=$1',
        [userId],
      );
      if (
        BigInt(cursor) < BigInt(watermark?.retained_after ?? 0) ||
        BigInt(cursor) > BigInt(watermark?.last_cursor ?? 0)
      )
        return { reset: true, events: [] };
      const events = await m.query(
        `SELECT cursor,report_id AS "reportId",profile_id AS "profileId",generation,version,status,stage,schema_version AS "schemaVersion"
        FROM report_processing_events WHERE user_id=$1 AND cursor>$2 ORDER BY cursor LIMIT 100`,
        [userId, cursor],
      );
      return { reset: false, events };
    });
  }
}
