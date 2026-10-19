import {
  Controller,
  Get,
  Post,
  Param,
  Req,
  Res,
  UseGuards,
  UseInterceptors,
  HttpCode,
  ServiceUnavailableException,
  BadRequestException,
  NotFoundException,
  HttpException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import { ConfigService } from '@nestjs/config';
import type { Request, Response } from 'express';
import { randomUUID } from 'node:crypto';
import { DataSource } from 'typeorm';
import { isUUID } from 'class-validator';
import { AuthGuard } from '../../../common/guards/auth.guard';
import { FILE_STORAGE } from '../../../common/storage/storage.module';
import { Inject } from '@nestjs/common';
import type { FileStorageService } from '../../../common/storage/file-storage.interface';
import { AuthService } from '../../auth/auth.service';
import { ProfilesService } from '../../profiles/profiles.service';
import { UsageLimitsService } from '../../entitlements/usage-limits.service';
import { ReportAdmissionService } from './report-admission.service';
import { ReportStreamService } from './report-stream.service';
import { processingSettings } from './processing-settings';
import {
  retryReportProcessing,
  cancelReportProcessing,
} from './report-lifecycle';
import { MAX_REPORT_SIZE_BYTES } from '../reports.types';

@Controller('reports/processing')
@UseGuards(AuthGuard)
export class ReportProcessingController {
  constructor(
    private readonly db: DataSource,
    private readonly config: ConfigService,
    @Inject(FILE_STORAGE) private readonly storage: FileStorageService,
    private readonly profiles: ProfilesService,
    private readonly usage: UsageLimitsService,
    private readonly auth: AuthService,
    private readonly stream: ReportStreamService,
  ) {}
  private user(req: Request) {
    return (req.user as { id: string }).id;
  }
  private id(id: string) {
    if (!isUUID(id))
      throw new BadRequestException({ code: 'REPORT_ID_INVALID' });
    return id;
  }
  @Get('capabilities') capabilities() {
    const s = processingSettings(this.config);
    return {
      data: {
        schemaVersion: 1,
        acceptance: s.admission && s.runtime,
        events: s.runtime,
      },
    };
  }
  @Post('uploads')
  @HttpCode(202)
  @UseInterceptors(
    FileInterceptor('file', {
      storage: memoryStorage(),
      limits: { fileSize: MAX_REPORT_SIZE_BYTES },
    }),
  )
  async uploadReport(@Req() req: Request) {
    const settings = processingSettings(this.config);
    if (!settings.runtime || !settings.admission)
      throw new ServiceUnavailableException({ code: 'REPORT_ASYNC_DISABLED' });
    const health = await this.db.query(
      "SELECT DISTINCT role FROM report_process_health WHERE heartbeat_at>clock_timestamp()-interval '30 seconds'",
    );
    if (
      !['worker', 'dispatcher'].every((role) =>
        health.some((row: { role: string }) => row.role === role),
      )
    )
      throw new ServiceUnavailableException({
        code: 'REPORT_PROCESSORS_UNAVAILABLE',
      });
    const userId = this.user(req);
    this.auth.enforceRateLimit('report-upload-v2', userId, 10);
    const file = req.file;
    if (!file) throw new BadRequestException({ code: 'REPORT_FILE_REQUIRED' });
    const profileId =
      typeof req.body?.profileId === 'string'
        ? req.body.profileId
        : await this.profiles.getActiveProfileId(userId);
    if (!profileId)
      throw new BadRequestException({ code: 'REPORT_NO_ACTIVE_PROFILE' });
    await this.usage.getPlanLimits(userId);
    const admission = new ReportAdmissionService(
      this.db,
      this.storage,
      settings.policy,
    );
    const result = await admission.accept({
      userId,
      profileId,
      idempotencyKey: req.header('idempotency-key') ?? '',
      file,
    });
    return {
      data: {
        ...result,
        contractVersion: 2,
        statusUrl: `/v1/reports/processing/status/${result.reportId}`,
        fileName: file.originalname,
        contentType: file.mimetype,
        sizeBytes: file.size,
      },
    };
  }
  @Get('snapshot') async snapshot(@Req() req: Request) {
    this.auth.enforceRateLimit('report-snapshot', this.user(req), 60);
    return { data: await this.stream.snapshot(this.user(req)) };
  }
  @Get('status/:id') async status(
    @Req() req: Request,
    @Param('id') id: string,
  ) {
    const [r] = await this.db.query(
      `SELECT id AS "reportId",profile_id AS "profileId",processing_version AS version,processing_state AS status,processing_stage AS stage,
      processing_error_code AS "errorCode",processing_retry_at AS "retryAt",summary_status AS "summaryStatus" FROM reports WHERE id=$1 AND user_id=$2 AND deleted_at IS NULL AND processing_generation>0`,
      [this.id(id), this.user(req)],
    );
    if (!r) throw new NotFoundException();
    return { data: r };
  }
  @Post(':id/retry') @HttpCode(202) async retry(
    @Req() req: Request,
    @Param('id') id: string,
  ) {
    this.stream.assertEnabled();
    this.auth.enforceRateLimit('report-retry', this.user(req), 10);
    await retryReportProcessing(
      this.db,
      this.user(req),
      this.id(id),
      processingSettings(this.config).policy,
    );
    return this.status(req, id);
  }
  @Post(':id/cancel') async cancel(
    @Req() req: Request,
    @Param('id') id: string,
  ) {
    this.stream.assertEnabled();
    await cancelReportProcessing(this.db, this.user(req), this.id(id), false);
    return this.status(req, id);
  }
  @Post(':id/summary/retry') @HttpCode(202) async retrySummary(
    @Req() req: Request,
    @Param('id') id: string,
  ) {
    this.stream.assertEnabled();
    this.auth.enforceRateLimit('report-summary-retry', this.user(req), 5);
    if (!this.config.get<boolean>('reports.reportSummaryEnabled'))
      throw new ServiceUnavailableException({
        code: 'REPORT_SUMMARY_DISABLED',
      });
    await this.status(req, id);
    const [inbox] = await this.db.query(
      `SELECT i.id FROM report_inbox i JOIN reports r ON r.id=i.report_id AND r.processing_generation=i.generation
      WHERE r.id=$1 AND r.user_id=$2 AND r.processing_state='ready' AND r.deleted_at IS NULL`,
      [id, this.user(req)],
    );
    if (!inbox) throw new BadRequestException({ code: 'REPORT_NOT_READY' });
    await this.db.transaction(async (m) => {
      await m.query(
        `INSERT INTO report_delivery_intents(id,inbox_id,channel,target,expires_at) VALUES($1,$2,'summary','report',clock_timestamp()+interval '1 day')
        ON CONFLICT(inbox_id,channel,target) DO UPDATE SET state='pending',attempts=0,available_at=clock_timestamp(),expires_at=clock_timestamp()+interval '1 day'
        WHERE report_delivery_intents.state IN ('failed','accepted','skipped') OR (report_delivery_intents.state='pending' AND report_delivery_intents.available_at>clock_timestamp())`,
        [randomUUID(), inbox.id],
      );
      await m.query(
        "UPDATE reports SET summary_status='pending' WHERE id=$1 AND user_id=$2",
        [id, this.user(req)],
      );
    });
    return { data: { summaryStatus: 'pending' } };
  }
  @Post(':id/acknowledge') async acknowledge(
    @Req() req: Request,
    @Param('id') id: string,
  ) {
    await this.status(req, id);
    await this.db.transaction(async (m) => {
      await m.query(
        'UPDATE reports SET processing_acknowledged_at=clock_timestamp() WHERE id=$1 AND user_id=$2',
        [id, this.user(req)],
      );
      await m.query(
        'UPDATE report_inbox SET read_at=clock_timestamp() WHERE report_id=$1 AND user_id=$2 AND read_at IS NULL',
        [id, this.user(req)],
      );
    });
    return { data: { acknowledged: true } };
  }
  @Get('inbox') async inbox(@Req() req: Request) {
    this.stream.assertEnabled();
    return {
      data: {
        items: await this.db.query(
          `SELECT i.*,r.profile_id FROM report_inbox i JOIN reports r ON r.id=i.report_id WHERE i.user_id=$1 AND r.deleted_at IS NULL ORDER BY i.created_at DESC LIMIT 100`,
          [this.user(req)],
        ),
      },
    };
  }
  @Get('events') async events(@Req() req: Request, @Res() res: Response) {
    this.stream.assertEnabled();
    const user = this.user(req);
    this.auth.enforceRateLimit('report-stream', user, 30);
    const session = (req as Request & { currentSessionId?: string })
      .currentSessionId;
    if (!session) throw new NotFoundException();
    const connection = randomUUID();
    await this.db.transaction(async (m) => {
      await m.query('SELECT id FROM users WHERE id=$1 FOR NO KEY UPDATE', [
        user,
      ]);
      await m.query(
        'DELETE FROM report_sse_connections WHERE user_id=$1 AND expires_at<clock_timestamp()',
        [user],
      );
      const [{ count }] = await m.query(
        'SELECT count(*)::integer AS count FROM report_sse_connections WHERE user_id=$1',
        [user],
      );
      if (count >= 6)
        throw new HttpException({ code: 'REPORT_STREAM_LIMIT' }, 429);
      await m.query(
        `INSERT INTO report_sse_connections VALUES($1,$2,clock_timestamp()+interval '30 seconds')`,
        [connection, user],
      );
    });
    res.status(200).set({
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache, no-store, no-transform',
      Connection: 'keep-alive',
      'X-Accel-Buffering': 'no',
    });
    res.flushHeaders();
    let cursor =
      req.header('last-event-id') ??
      (typeof req.query.cursor === 'string' ? req.query.cursor : '0');
    let busy = false,
      closed = false,
      sentHeartbeat = 0,
      delivered = 0;
    const start = Date.now();
    const close = () => {
      if (closed) return;
      closed = true;
      clearInterval(timer);
      this.stream.wake.off(user, wake);
      res.end();
      void this.db
        .query('DELETE FROM report_sse_connections WHERE id=$1', [connection])
        .catch(() => {});
    };
    const write = (frame: string) => {
      if (!res.write(frame)) close();
    };
    const pump = async () => {
      if (busy || closed) return;
      busy = true;
      try {
        // Recheck revocation independently of any auth session cache, at most 2s.
        const [valid] = await this.db.query(
          `SELECT s.id FROM sessions s WHERE s.id=$1 AND s.user_id=$2 AND s.expires_at>clock_timestamp()
        AND NOT EXISTS(SELECT 1 FROM restrictions x WHERE x.user_id=$2 AND (x.is_restricted OR x.restricted_review_mode) AND (x.restricted_until IS NULL OR x.restricted_until>clock_timestamp()))`,
          [session, user],
        );
        if (!valid || Date.now() - start > 300000) {
          close();
          return;
        }
        await this.db.query(
          `UPDATE report_sse_connections SET expires_at=clock_timestamp()+interval '30 seconds' WHERE id=$1`,
          [connection],
        );
        const page = await this.stream.replay(user, cursor);
        if (page.reset) {
          write(
            'event: report.reset\ndata: {"schemaVersion":1,"reason":"cursor_unavailable"}\n\n',
          );
          close();
          return;
        }
        for (const event of page.events) {
          if (closed) break;
          write(
            `id: ${event.cursor}\nevent: report.status_changed\ndata: ${JSON.stringify(event)}\n\n`,
          );
          cursor = event.cursor;
          if (++delivered >= 10000) {
            write('event: report.reset\ndata: {"reason":"catchup_limit"}\n\n');
            close();
            break;
          }
        }
        if (Date.now() - sentHeartbeat > 10000) {
          write(': heartbeat\n\n');
          sentHeartbeat = Date.now();
        }
        if (page.events.length === 100 && !closed) setImmediate(wake);
      } catch {
        close();
      } finally {
        busy = false;
      }
    };
    const wake = () => {
      void pump();
    };
    const timer = setInterval(wake, 2000);
    this.stream.wake.on(user, wake);
    res.on('close', close);
    wake();
  }
}
