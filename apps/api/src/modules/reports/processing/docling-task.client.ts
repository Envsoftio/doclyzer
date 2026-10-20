import type { CascadeProgress, OcrOutput } from '../report-ocr-cascade';
import { WebSocket } from 'undici';
import { DataSource } from 'typeorm';
import { isDoclingDocument } from '../docling-document-adapter';
import { ReportLeaseLostError, type ReportJobLease } from './report-job.store';
import type { processingSettings } from './processing-settings';
export class ProcessingFailure extends Error {
  constructor(
    public readonly code:
      | 'INVALID_CONTENT'
      | 'PROVIDER_UNAVAILABLE'
      | 'SOURCE_UNAVAILABLE',
    public readonly retryable = true,
    public readonly retryAfterMs = 0,
  ) {
    super(code);
  }
}
export class DoclingTaskClient {
  constructor(
    private readonly db: DataSource,
    private readonly settings: ReturnType<typeof processingSettings>,
  ) {}
  private async checkpoint(
    lease: ReportJobLease,
    sql: string,
    values: unknown[] = [],
  ): Promise<void> {
    const result = await this.db.query(
      `UPDATE report_processing_jobs SET ${sql}
      WHERE id=$1 AND lease_token=$2 AND state='leased' AND lease_expires_at>clock_timestamp() AND deadline_at>clock_timestamp() RETURNING id`,
      [lease.jobId, lease.token, ...values],
    );
    if (result[1] !== 1) throw new ReportLeaseLostError();
  }
  async convert(
    bytes: Buffer,
    lease: ReportJobLease,
    signal: AbortSignal,
    nativeOnly = false,
  ): Promise<{
    text: string;
    parsedJson: unknown;
    nativeOnly?: boolean;
    cascadeProgress?: CascadeProgress;
  }> {
    const [job] = await this.db.query(
      'SELECT * FROM report_processing_jobs WHERE id=$1',
      [lease.jobId],
    );
    if (job.staged_result) return this.outputs(job.staged_result);
    const instance =
      this.settings.providerInstance + (nativeOnly ? ':native-v1' : '');
    let taskId: string | null = job.provider_task_id;
    if (taskId && job.provider_instance_id !== instance) {
      await this.checkpoint(
        lease,
        'provider_task_id=NULL,provider_missing_count=0',
      );
      taskId = null;
    }
    if (!taskId) {
      if (job.provider_submission_count >= job.max_attempts)
        throw new ProcessingFailure('PROVIDER_UNAVAILABLE', false);
      // Submission is ambiguous until a response is durably checkpointed. Never
      // retry this POST locally; the job attempt/deadline bounds resubmission.
      await this.checkpoint(
        lease,
        'submission_uncertain_at=clock_timestamp(),provider_instance_id=$3,provider_submission_count=provider_submission_count+1',
        [instance],
      );
      const form = new FormData();
      form.append(
        'files',
        new Blob([new Uint8Array(bytes)], { type: 'application/pdf' }),
        'report.pdf',
      );
      form.append('to_formats', 'md');
      form.append('to_formats', 'json');
      form.append('from_formats', 'pdf');
      form.append('do_ocr', String(!nativeOnly));
      form.append('ocr_preset', 'rapidocr');
      form.append('do_table_structure', 'true');
      form.append('table_mode', 'accurate');
      form.append('include_images', 'false');
      form.append('abort_on_error', 'true');
      form.append(
        'document_timeout',
        String(
          Math.max(
            1,
            Math.floor(
              (new Date(job.deadline_at).getTime() - Date.now()) / 1000,
            ),
          ),
        ),
      );
      const result = await this.request('/v1/convert/file/async', signal, {
        method: 'POST',
        body: form,
      });
      if (typeof result.task_id !== 'string' || !result.task_id)
        throw new ProcessingFailure('PROVIDER_UNAVAILABLE');
      taskId = result.task_id;
      await this.checkpoint(
        lease,
        'provider_task_id=$3,submission_uncertain_at=NULL,provider_missing_count=0',
        [taskId],
      );
    }
    while (!signal.aborted) {
      // Socket notifications are hints; reconnect and bounded HTTP reconciliation
      // use the durable task ID. A dropped socket does not resubmit conversion.
      const status = await this.socketStatus(taskId!, signal);
      let task = status;
      if (!task) {
        try {
          task = (
            await this.request(
              `/v1/status/poll/${encodeURIComponent(taskId!)}`,
              signal,
            )
          ).task_status;
        } catch (error) {
          if (error instanceof MissingTask) {
            await this.checkpoint(
              lease,
              'provider_missing_count=provider_missing_count+1',
            );
            const [current] = await this.db.query(
              'SELECT provider_missing_count FROM report_processing_jobs WHERE id=$1',
              [lease.jobId],
            );
            if (current.provider_missing_count >= 2) {
              await this.checkpoint(
                lease,
                'provider_task_id=NULL,provider_missing_count=0',
              );
              return this.convert(bytes, lease, signal, nativeOnly);
            }
          }
          throw new ProcessingFailure('PROVIDER_UNAVAILABLE');
        }
      }
      if (task === 'failure') {
        await this.checkpoint(lease, 'provider_task_id=NULL');
        throw new ProcessingFailure('PROVIDER_UNAVAILABLE');
      }
      if (task === 'success') {
        let result: Record<string, unknown>;
        try {
          result = await this.request(
            `/v1/result/${encodeURIComponent(taskId!)}`,
            signal,
          );
        } catch (error) {
          if (error instanceof MissingTask)
            await this.checkpoint(lease, 'provider_task_id=NULL');
          throw new ProcessingFailure('PROVIDER_UNAVAILABLE');
        }
        result.doclyzer_native_only = nativeOnly;
        const output = this.outputs(result);
        await this.checkpoint(lease, 'staged_result=$3::jsonb', [
          JSON.stringify(result),
        ]);
        return output;
      }
      await new Promise<void>((resolve, reject) => {
        const stop = () => {
          clearTimeout(timer);
          reject(new ReportLeaseLostError());
        };
        const timer = setTimeout(() => {
          signal.removeEventListener('abort', stop);
          resolve();
        }, 1500);
        signal.addEventListener('abort', stop, { once: true });
        if (signal.aborted) stop();
      });
    }
    throw new ReportLeaseLostError();
  }
  async saveCascadeCandidate(
    lease: ReportJobLease,
    page: number,
    engine: 'paddleocr-v5',
    output: OcrOutput,
  ): Promise<void> {
    await this.checkpoint(
      lease,
      `staged_result=jsonb_set(staged_result, '{doclyzer_cascade}',
      COALESCE(staged_result->'doclyzer_cascade','{}'::jsonb) ||
      jsonb_build_object($3::text, COALESCE(staged_result->'doclyzer_cascade'->$3::text,'{}'::jsonb) ||
      jsonb_build_object($4::text,$5::jsonb)))`,
      [String(page), engine, JSON.stringify(output)],
    );
  }
  private outputs(result: Record<string, unknown>): {
    text: string;
    parsedJson: unknown;
    nativeOnly?: boolean;
    cascadeProgress?: CascadeProgress;
  } {
    const document = result.document as Record<string, unknown> | undefined;
    if (
      result.status !== 'success' ||
      !document ||
      typeof document.md_content !== 'string' ||
      !isDoclingDocument(document.json_content)
    ) {
      // Includes partial_success: never declare an incomplete conversion ready.
      throw new ProcessingFailure('INVALID_CONTENT', false);
    }
    return {
      text: document.md_content,
      parsedJson: document.json_content,
      nativeOnly: result.doclyzer_native_only === true,
      cascadeProgress: result.doclyzer_cascade as CascadeProgress | undefined,
    };
  }
  private async request(
    path: string,
    signal: AbortSignal,
    init: RequestInit = {},
  ): Promise<Record<string, any>> {
    let response: Response;
    try {
      response = await fetch(`${this.settings.providerBase}${path}`, {
        ...init,
        headers: {
          ...init.headers,
          ...(this.settings.providerApiKey
            ? { 'X-Api-Key': this.settings.providerApiKey }
            : {}),
        },
        signal: AbortSignal.any([
          signal,
          AbortSignal.timeout(this.settings.providerRequestMs),
        ]),
      });
    } catch {
      throw new ProcessingFailure('PROVIDER_UNAVAILABLE');
    }
    if (response.status === 404) throw new MissingTask();
    if (!response.ok) {
      const hint = response.headers.get('retry-after');
      const delay =
        hint == null
          ? 0
          : /^\d+$/.test(hint)
            ? Number(hint) * 1000
            : Date.parse(hint) - Date.now();
      throw new ProcessingFailure(
        response.status === 422 ? 'INVALID_CONTENT' : 'PROVIDER_UNAVAILABLE',
        response.status !== 422,
        Number.isFinite(delay) ? Math.max(0, delay) : 0,
      );
    }
    const reader = response.body?.getReader();
    if (!reader) throw new ProcessingFailure('PROVIDER_UNAVAILABLE');
    const chunks: Uint8Array[] = [];
    let size = 0;
    try {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        size += value.length;
        if (size > 32 * 1024 * 1024) {
          await reader.cancel();
          throw new ProcessingFailure('INVALID_CONTENT', false);
        }
        chunks.push(value);
      }
      return JSON.parse(Buffer.concat(chunks).toString('utf8'));
    } catch (error) {
      if (error instanceof ProcessingFailure) throw error;
      throw new ProcessingFailure('PROVIDER_UNAVAILABLE');
    }
  }
  private socketStatus(
    taskId: string,
    signal: AbortSignal,
  ): Promise<string | null> {
    // Pinned Docling authenticates WebSockets only through query strings.
    // With API-key auth, use bounded HTTP reconciliation rather than expose keys.
    if (this.settings.providerApiKey) return Promise.resolve(null);
    return new Promise((resolve) => {
      let done = false;
      let socket: WebSocket;
      const finish = (status: string | null) => {
        if (done) return;
        done = true;
        clearTimeout(timer);
        signal.removeEventListener('abort', abort);
        try {
          socket?.close();
        } catch {}
        resolve(status);
      };
      const abort = () => finish(null);
      const timer = setTimeout(() => finish(null), 15000);
      signal.addEventListener('abort', abort, { once: true });
      if (signal.aborted) {
        finish(null);
        return;
      }
      try {
        socket = new WebSocket(
          `${this.settings.providerBase.replace(/^http/, 'ws')}/v1/status/ws/${encodeURIComponent(taskId)}`,
        );
        socket.addEventListener('message', (event) => {
          try {
            const data = JSON.parse(String(event.data));
            if (['success', 'failure'].includes(data.task?.task_status))
              finish(data.task.task_status);
          } catch {
            finish(null);
          }
        });
        socket.addEventListener('error', () => finish(null));
        socket.addEventListener('close', () => finish(null));
      } catch {
        finish(null);
      }
    });
  }
}
class MissingTask extends Error {}
