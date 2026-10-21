import { assertImageResourceLimit } from './image-resource-limit';
import { Inject, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { DataSource } from 'typeorm';
import { PDFDocument } from 'pdf-lib';
import { FILE_STORAGE } from '../../../common/storage/storage.module';
import type { FileStorageService } from '../../../common/storage/file-storage.interface';
import { ReportsService } from '../reports.service';
import {
  ReportJobStore,
  ReportLeaseLostError,
  type ReportJobLease,
} from './report-job.store';
import { ReportAdmissionService } from './report-admission.service';
import { DoclingTaskClient, ProcessingFailure } from './docling-task.client';
import { processingSettings } from './processing-settings';
import { ReportVlShadowService } from './report-vl-shadow.service';
import { reportDeadlineMs } from './report-deadline';
@Injectable()
export class ReportWorkerService {
  private readonly log = new Logger(ReportWorkerService.name);
  constructor(
    private readonly db: DataSource,
    private readonly config: ConfigService,
    private readonly reports: ReportsService,
    private readonly vlShadow: ReportVlShadowService,
    @Inject(FILE_STORAGE) private readonly storage: FileStorageService,
  ) {}
  async onModuleInit(): Promise<void> {
    const settings = processingSettings(this.config);
    if (settings.admission && !settings.runtime)
      throw new Error('Async admission requires runtime');
    if (!settings.runtime) return;
    if (
      this.storage.durability !== 'durable' ||
      this.db.options.extra?.usePgMem
    )
      throw new Error('Async runtime requires durable storage and PostgreSQL');
    await this.db.query('SELECT id FROM report_upload_intents LIMIT 0');
    await this.db.query('SELECT id FROM report_delivery_intents LIMIT 0');
    await this.db.query(
      'SELECT provider_submission_count FROM report_processing_jobs LIMIT 0',
    );
  }
  async run(signal: AbortSignal): Promise<void> {
    const settings = processingSettings(this.config);
    const jobs = new ReportJobStore(this.db, settings.leaseMs);
    const admission = new ReportAdmissionService(
      this.db,
      this.storage,
      settings.policy,
    );
    const provider = new DoclingTaskClient(this.db, settings);
    let nextCleanup = 0;
    const loop = async () => {
      while (!signal.aborted) {
        try {
          if (Date.now() > nextCleanup) {
            nextCleanup = Date.now() + 60000;
            const cleanup = await admission.sweepOrphans();
            if (cleanup.failed)
              this.log.error(
                JSON.stringify({
                  action: 'REPORT_ORPHAN_CLEANUP_FAILED',
                  count: cleanup.failed,
                }),
              );
          }
          const lease = await jobs.claim();
          if (lease) await this.execute(lease, jobs, provider, signal);
          else await new Promise((resolve) => setTimeout(resolve, 1000));
        } catch {
          this.log.error('REPORT_WORKER_ITERATION_FAILED');
          await new Promise((resolve) => setTimeout(resolve, 1000));
        }
      }
    };
    await Promise.all(Array.from({ length: settings.concurrency }, loop));
  }
  private async execute(
    lease: ReportJobLease,
    jobs: ReportJobStore,
    provider: DoclingTaskClient,
    shutdown: AbortSignal,
  ): Promise<void> {
    const settings = processingSettings(this.config);
    const controller = new AbortController();
    let heartbeatBusy = false;
    const beat = setInterval(
      () => {
        if (heartbeatBusy) return;
        heartbeatBusy = true;
        void jobs
          .heartbeat(lease)
          .then((ok) => {
            if (!ok) controller.abort();
          })
          .catch(() => controller.abort())
          .finally(() => {
            heartbeatBusy = false;
          });
      },
      Math.floor(settings.leaseMs / 3),
    );
    let deadline: NodeJS.Timeout | undefined;
    try {
      const [row] = await this.db.query(
        `SELECT r.*,j.deadline_at,j.provider_task_id,j.staged_result,j.submission_uncertain_at FROM reports r JOIN report_processing_jobs j ON j.report_id=r.id WHERE j.id=$1`,
        [lease.jobId],
      );
      if (!row) throw new ReportLeaseLostError();
      deadline = setTimeout(
        () => controller.abort(),
        Math.max(1, new Date(row.deadline_at).getTime() - Date.now()),
      );
      const signal = AbortSignal.any([controller.signal, shutdown]);
      let bytes: Buffer;
      try {
        bytes = await this.storage.get(row.original_file_storage_key);
      } catch {
        throw new ProcessingFailure('SOURCE_UNAVAILABLE');
      }
      let normalized: Awaited<
        ReturnType<ReportsService['normalizeWorkerSource']>
      >;
      let pageCount: number | null = null;
      try {
        assertImageResourceLimit(
          bytes,
          row.content_type,
          settings.maxImagePixels,
        );
        if (row.content_type === 'image/jpeg' || row.content_type === 'image/png') {
          normalized = {
            buffer: bytes, originalname: row.original_file_name,
            mimetype: row.content_type, size: bytes.length, source: 'image',
          };
        } else {
          normalized = await this.reports.normalizeWorkerSource({
            buffer: bytes,
            originalname: row.original_file_name,
            mimetype: row.content_type,
            size: bytes.length,
          });
          const pdf = await PDFDocument.load(normalized.buffer);
          if (pdf.getPageCount() > settings.maxPages)
            throw new Error('PAGE_LIMIT');
          pageCount = pdf.getPageCount();
        }
      } catch (error) {
        if (error instanceof ReportLeaseLostError) throw error;
        throw new ProcessingFailure('INVALID_CONTENT', false);
      }
      if (pageCount !== null) {
        const extended = await jobs.extendDeadline(
          lease,
          reportDeadlineMs(settings.policy, pageCount),
        );
        if (deadline) clearTimeout(deadline);
        deadline = setTimeout(
          () => controller.abort(),
          Math.max(1, extended.getTime() - Date.now()),
        );
      }
      const result = normalized.source === 'image'
        ? await this.reports.extractImageWithPaddle(
            normalized.buffer,
            normalized.mimetype as 'image/jpeg' | 'image/png',
            signal,
          )
        : await (async () => {
            // Match the Docling playground's full-document OCR and table pass.
            const converted = await provider.convert(normalized.buffer, lease, signal);
            if (signal.aborted) throw new ReportLeaseLostError();
            const progress = await provider.loadCascadeProgress(lease, converted.cascadeProgress);
            return this.reports.extractWithOcrCascade(
              normalized.buffer, signal, converted,
              { progress,
                save: (page, engine, output) =>
                  provider.saveCascadeCandidate(lease, page, engine, output) },
            );
          })();
      if (signal.aborted) throw new ReportLeaseLostError();
      try {
        await this.vlShadow.capture(lease.reportId, row.processing_generation, normalized.buffer, signal, result, normalized.mimetype);
      } catch {
        this.log.warn('REPORT_VL_SHADOW_CAPTURE_FAILED');
      }
      if (signal.aborted) throw new ReportLeaseLostError();
      await jobs.setStage(lease, 'normalizing');
      const prepared = await this.reports.prepareWorkerResult(
        lease.reportId,
        normalized.source,
        result.text,
        result.parsedJson,
        row.user_id,
      );
      if (signal.aborted) throw new ReportLeaseLostError();
      await jobs.complete(lease, prepared.outcome, prepared.persist);
    } catch (error) {
      if (
        !(error instanceof ReportLeaseLostError) &&
        !controller.signal.aborted &&
        !shutdown.aborted
      ) {
        const failure =
          error instanceof ProcessingFailure
            ? error
            : new ProcessingFailure('PROVIDER_UNAVAILABLE');
        try {
          await jobs.fail(
            lease,
            failure.code,
            failure.retryable
              ? Math.max(
                  failure.retryAfterMs,
                  Math.floor(
                    Math.min(300000, 2000 * 2 ** lease.attempt) *
                      (0.5 + Math.random() / 2),
                  ),
                )
              : null,
          );
        } catch {
          this.log.warn('REPORT_JOB_FAILURE_COMMIT_UNCERTAIN');
        }
      }
    } finally {
      clearInterval(beat);
      if (deadline) clearTimeout(deadline);
    }
  }
}
