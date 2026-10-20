import { BadRequestException, ConflictException, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { DataSource } from 'typeorm';
import { PDFDocument } from 'pdf-lib';
import { parseVlTablePage, type VlTableCandidate } from '../geometry/vl-table';
import { ReportNotFoundException } from '../exceptions/report-not-found.exception';
import { isUUID } from 'class-validator';
import { randomUUID } from 'node:crypto';
import { ReportLabValueEntity } from '../../../database/entities/report-lab-value.entity';
import { loadObservationRules, normalizeObservation } from '../observation-normalizer';
import { adaptPaddle, adaptNativeWords, bounds, type PageEvidence } from '../geometry/evidence';
import { parseGeometry } from '../geometry/lab-parser';
import type { OcrOutput } from '../report-ocr-cascade';

type PageStatus = { page: number; status: 'parsed' | 'failed'; reason?: string; candidateCount: number };
type Review = { action: 'confirmed' | 'corrected' | 'unreadable' | 'added'; page?: number; testRaw: string; resultRaw: string | null; unitRaw: string | null; rangeRaw: string | null; sourceInspected: true; reviewedAt: string };

@Injectable()
export class ReportVlShadowService {
  private readonly log = new Logger(ReportVlShadowService.name);
  constructor(private readonly db: DataSource, private readonly config: ConfigService) {}

  async capture(reportId: string, generation: number, sourceBytes: Buffer, signal: AbortSignal, cascade?: OcrOutput, contentType = 'application/pdf'): Promise<void> {
    const reviewPages = (cascade?.parsedJson as { reviewPages?: Record<string, { visual?: OcrOutput }> } | undefined)?.reviewPages ?? {};
    const useVl = this.config.get<string>('REPORT_VL_SHADOW_ENABLED') === 'true';
    if (!useVl && !Object.keys(reviewPages).length) return;
    const base = this.config.get<string>('REPORT_VL_BASE_URL');
    const key = this.config.get<string>('REPORT_VL_API_KEY');
    if (useVl && (!base || !key || !/^http:\/\/[a-z0-9.-]+(?::\d+)?\/?$/i.test(base))) {
      this.log.warn('REPORT_VL_SHADOW_CONFIG_INVALID');
    }
    const pdf = contentType === 'application/pdf' ? await PDFDocument.load(sourceBytes) : null;
    const pageCount = pdf?.getPageCount() ?? 1;
    const candidates: VlTableCandidate[] = [];
    const pageStatus: PageStatus[] = [];
    const rawOutput: unknown[] = [];
    for (let page = 0; page < pageCount; page++) {
      if (signal.aborted) return;
      const paddlePage = (reviewPages[String(page + 1)]?.visual?.parsedJson as { paddlePage?: {
        page_width: number; page_height: number; dpi: number;
        native_words: Parameters<typeof adaptNativeWords>[0];
        paddle: Parameters<typeof adaptPaddle>[0];
        model_version: string; paddleocr_version: string; docling_parse_version: string;
      } } | undefined)?.paddlePage;
      let geometryRaw: unknown = null;
      if (paddlePage) {
        try {
          const pageId = `${reportId}:page:${page + 1}`;
          const tokens = adaptPaddle(paddlePage.paddle, {
            documentId: reportId, pageId,
            engineVersion: paddlePage.paddleocr_version, modelVersion: paddlePage.model_version,
            preprocessingId: `render:${paddlePage.dpi}dpi`,
            workingToOriginal: [72 / paddlePage.dpi, 0, 0, 72 / paddlePage.dpi, 0, 0],
          });
          const native = adaptNativeWords(paddlePage.native_words, {
            documentId: reportId, pageId, pageHeight: paddlePage.page_height,
            engineVersion: paddlePage.docling_parse_version,
          });
          const evidence: PageEvidence = {
            document_id: reportId, page_id: pageId, page_number: page + 1,
            width: paddlePage.page_width, height: paddlePage.page_height,
            source_ref: 'original_upload', render_ref: 'original_upload',
            route: native.length ? 'hybrid' : 'ocr', tokens,
            failed_regions: [], raw_output_ref: `${pageId}:raw`,
          };
          const parsed = parseGeometry([evidence], [pageId]);
          parsed.candidates.forEach((candidate, row) => {
            const box = bounds(candidate.sourcePolygon);
            candidates.push({
              id: `p${page}-t1000-r${row}`, page, table: 1000, row,
              testRaw: candidate.testRaw, resultRaw: candidate.resultRaw,
              unitRaw: candidate.unitRaw, rangeRaw: candidate.rangeRaw,
              tableBox: [box.left, box.top, box.right, box.bottom],
              pageWidth: paddlePage.page_width, pageHeight: paddlePage.page_height,
              status: 'needs_review', reviewReasons: candidate.reviewReasons,
              machineEligible: false, sourcePolygon: candidate.sourcePolygon,
              evidence: candidate.evidence, readings: candidate.readings,
            });
          });
          geometryRaw = { source: 'PP-OCRv5', paddlePage, evidence, native, parsed };
        } catch {
          this.log.warn(JSON.stringify({ action: 'REPORT_PADDLE_GEOMETRY_FAILED', page }));
        }
      }
      if (!useVl || !base || !key) {
        pageStatus.push({ page, status: geometryRaw ? 'parsed' : 'failed', reason: geometryRaw ? undefined : 'paddle_page_unavailable',
          candidateCount: candidates.filter((c) => c.page === page).length });
        rawOutput.push({ geometry: geometryRaw, vl: null });
        continue;
      }
      try {
        let bytes: Uint8Array = sourceBytes;
        if (pdf) {
          const single = await PDFDocument.create();
          const [source] = await single.copyPages(pdf, [page]);
          single.addPage(source);
          bytes = await single.save();
        }
        if (bytes.length > 10 * 1024 * 1024) throw new Error('PAGE_BYTE_LIMIT');
        const response = await fetch(`${base.replace(/\/$/, '')}/v1/parse/page`, {
          method: 'POST', headers: { 'content-type': contentType, 'x-api-key': key },
          body: Buffer.from(bytes), signal: AbortSignal.any([signal, AbortSignal.timeout(65_000)]),
        });
        if (!response.ok) throw new Error(`HTTP_${response.status}`);
        const reader = response.body?.getReader();
        if (!reader) throw new Error('EMPTY_RESPONSE');
        const chunks: Buffer[] = [];
        let size = 0;
        while (true) {
          const { done, value } = await reader.read();
          if (done) break;
          size += value.length;
          if (size > 5 * 1024 * 1024) { await reader.cancel(); throw new Error('RESULT_BYTE_LIMIT'); }
          chunks.push(Buffer.from(value));
        }
        const raw: unknown = JSON.parse(Buffer.concat(chunks).toString('utf8'));
        const found = parseVlTablePage(raw, page);
        candidates.push(...found);
        pageStatus.push({ page, status: 'parsed', candidateCount: found.length });
        rawOutput.push({ geometry: geometryRaw, vl: raw });
      } catch (error) {
        const reason = error instanceof Error && /PAGE_BYTE_LIMIT/.test(error.message) ? 'page_byte_limit' : 'vl_page_failed';
        pageStatus.push({ page, status: 'failed', reason, candidateCount: 0 });
        rawOutput.push({ geometry: geometryRaw, vl: null });
        this.log.warn(JSON.stringify({ action: 'REPORT_VL_SHADOW_PAGE_FAILED', page, reason }));
      }
    }
    if (signal.aborted) return;
    await this.db.query(`INSERT INTO report_vl_shadows (report_id, processing_generation, candidates, page_status, raw_output)
      SELECT id,$2,$3::jsonb,$4::jsonb,$5::jsonb FROM reports WHERE id=$1 AND processing_generation=$2 AND deleted_at IS NULL
      ON CONFLICT (report_id) DO UPDATE SET processing_generation=excluded.processing_generation,
      candidates=excluded.candidates, page_status=excluded.page_status, raw_output=excluded.raw_output,
      reviews='{}'::jsonb, applied='{}'::jsonb, review_version=0, updated_at=now()
      WHERE (report_vl_shadows.processing_generation < excluded.processing_generation AND report_vl_shadows.applied = '{}'::jsonb)
         OR (report_vl_shadows.processing_generation = excluded.processing_generation AND report_vl_shadows.review_version = 0 AND report_vl_shadows.applied = '{}'::jsonb)`,
    [reportId, generation, JSON.stringify(candidates), JSON.stringify(pageStatus), JSON.stringify(rawOutput)]);
  }

  async get(userId: string, reportId: string): Promise<object> {
    if (!isUUID(reportId)) throw new ReportNotFoundException();
    const [row] = await this.db.query(`SELECT v.candidates,v.page_status,v.reviews,v.applied,v.review_version
      FROM report_vl_shadows v JOIN reports r ON r.id=v.report_id
      WHERE r.id=$1 AND r.user_id=$2 AND r.deleted_at IS NULL`, [reportId, userId]);
    if (row) return { candidates: row.candidates, pageStatus: row.page_status, reviews: row.reviews, applied: row.applied, reviewVersion: row.review_version, status: row.page_status.some((p: PageStatus) => p.status === 'failed') ? 'partial' : 'needs_review' };
    const [report] = await this.db.query('SELECT id FROM reports WHERE id=$1 AND user_id=$2 AND deleted_at IS NULL', [reportId, userId]);
    if (!report) throw new ReportNotFoundException();
    return { candidates: [], pageStatus: [], reviews: {}, applied: {}, reviewVersion: 0, status: 'unavailable' };
  }

  async review(userId: string, reportId: string, candidateId: string, input: {
    expectedVersion?: number; action?: string; sourceInspected?: boolean;
    testRaw?: string; resultRaw?: string | null; unitRaw?: string | null; rangeRaw?: string | null;
  }): Promise<object> {
    if (!isUUID(reportId) || !/^p\d+-t\d+-r\d+$/.test(candidateId)) throw new ReportNotFoundException();
    if (!Number.isInteger(input?.expectedVersion) || !['confirmed', 'corrected', 'unreadable'].includes(input?.action ?? '') || input?.sourceInspected !== true)
      throw new BadRequestException('Review requires action, version and source inspection');
    const runner = this.db.createQueryRunner();
    await runner.connect();
    await runner.startTransaction();
    try {
      const [row] = await runner.query(`SELECT v.* FROM report_vl_shadows v JOIN reports r ON r.id=v.report_id
        WHERE r.id=$1 AND r.user_id=$2 AND r.deleted_at IS NULL FOR UPDATE OF v`, [reportId, userId]);
      if (!row) throw new ReportNotFoundException();
      if (row.review_version !== input.expectedVersion) throw new ConflictException('Review changed elsewhere');
      const candidate = (row.candidates as VlTableCandidate[]).find((c) => c.id === candidateId);
      if (!candidate) throw new ReportNotFoundException();
      if ((row.applied as Record<string, string>)[candidateId]) throw new ConflictException('Applied results are immutable; correct the report result instead');
      const field = (value: unknown, max: number): string | null => {
        if (value == null) return null;
        if (typeof value !== 'string' || value.length > max) throw new BadRequestException('Invalid review field');
        return value.trim() || null;
      };
      const action = input.action as Review['action'];
      const review: Review = {
        action, testRaw: field(input.testRaw ?? candidate.testRaw, 256) ?? '',
        resultRaw: field(input.resultRaw === undefined ? candidate.resultRaw : input.resultRaw, 512),
        unitRaw: field(input.unitRaw === undefined ? candidate.unitRaw : input.unitRaw, 64),
        rangeRaw: field(input.rangeRaw === undefined ? candidate.rangeRaw : input.rangeRaw, 256),
        sourceInspected: true, reviewedAt: new Date().toISOString(),
      };
      if (action !== 'unreadable' && (!review.testRaw || !review.resultRaw)) throw new BadRequestException('Test and result required');
      const reviews = { ...(row.reviews as Record<string, Review>), [candidateId]: review };
      await runner.query(`UPDATE report_vl_shadows SET reviews=$2::jsonb,review_version=review_version+1,updated_at=now() WHERE report_id=$1`, [reportId, JSON.stringify(reviews)]);
      await runner.commitTransaction();
      return { reviews, reviewVersion: row.review_version + 1 };
    } catch (error) {
      await runner.rollbackTransaction();
      throw error;
    } finally {
      await runner.release();
    }
  }

  async addMissed(userId: string, reportId: string, input: {
    expectedVersion?: number; sourceInspected?: boolean; page?: number;
    testRaw?: string; resultRaw?: string; unitRaw?: string | null; rangeRaw?: string | null;
  }): Promise<object> {
    if (!isUUID(reportId)) throw new ReportNotFoundException();
    const page = input?.page;
    if (!Number.isInteger(input?.expectedVersion) || !Number.isInteger(page) || (page as number) < 0 || input?.sourceInspected !== true ||
      !input.testRaw?.trim() || input.testRaw.length > 256 || !input.resultRaw?.trim() || input.resultRaw.length > 512 ||
      (input.unitRaw != null && input.unitRaw.length > 64) || (input.rangeRaw != null && input.rangeRaw.length > 256))
      throw new BadRequestException('Invalid missed observation');
    const runner = this.db.createQueryRunner();
    await runner.connect();
    await runner.startTransaction();
    try {
      const [row] = await runner.query(`SELECT v.* FROM report_vl_shadows v JOIN reports r ON r.id=v.report_id
        WHERE r.id=$1 AND r.user_id=$2 AND r.deleted_at IS NULL FOR UPDATE OF v`, [reportId, userId]);
      if (!row) throw new ReportNotFoundException();
      if (row.review_version !== input.expectedVersion) throw new ConflictException('Review changed elsewhere');
      if (!(row.page_status as PageStatus[]).some((status) => status.page === page)) throw new BadRequestException('Page is outside report');
      const id = `manual-${randomUUID()}`;
      const review: Review = { action: 'added', page, testRaw: input.testRaw.trim(), resultRaw: input.resultRaw.trim(),
        unitRaw: input.unitRaw?.trim() || null, rangeRaw: input.rangeRaw?.trim() || null,
        sourceInspected: true, reviewedAt: new Date().toISOString() };
      const reviews = { ...(row.reviews as Record<string, Review>), [id]: review };
      await runner.query(`UPDATE report_vl_shadows SET reviews=$2::jsonb,review_version=review_version+1,updated_at=now() WHERE report_id=$1`, [reportId, JSON.stringify(reviews)]);
      await runner.commitTransaction();
      return { reviews, reviewVersion: row.review_version + 1 };
    } catch (error) {
      await runner.rollbackTransaction();
      throw error;
    } finally {
      await runner.release();
    }
  }

  /** Only an explicit, source-inspected review can enter ordinary report results. */
  async applyReviewed(userId: string, reportId: string, candidateId: string, expectedVersion: number): Promise<object> {
    if (!isUUID(reportId) || !/^(?:p\d+-t\d+-r\d+|manual-[\da-f-]{36})$/.test(candidateId)) throw new ReportNotFoundException();
    if (!Number.isSafeInteger(expectedVersion) || expectedVersion < 0) throw new BadRequestException('Review version required');
    const runner = this.db.createQueryRunner();
    await runner.connect();
    await runner.startTransaction();
    try {
      const [row] = await runner.query(`SELECT v.*,r.processing_state,r.status AS report_status FROM report_vl_shadows v JOIN reports r ON r.id=v.report_id
        WHERE r.id=$1 AND r.user_id=$2 AND r.deleted_at IS NULL FOR UPDATE OF v,r`, [reportId, userId]);
      if (!row) throw new ReportNotFoundException();
      if (row.review_version !== expectedVersion) throw new ConflictException('Review changed elsewhere');
      const applied = row.applied as Record<string, string>;
      if (applied[candidateId]) {
        await runner.commitTransaction();
        return { labValueId: applied[candidateId], reviewVersion: row.review_version };
      }
      if (!['ready', 'needs_attention', 'failed'].includes(row.processing_state) && row.report_status !== 'parsed') throw new ConflictException('Report processing is not finished');
      const review = (row.reviews as Record<string, Review>)[candidateId];
      if (!review || !review.sourceInspected || review.action === 'unreadable' || !review.testRaw || !review.resultRaw)
        throw new BadRequestException('Source-confirmed result required');
      const candidate = (row.candidates as VlTableCandidate[]).find((c) => c.id === candidateId);
      if (!candidate && !candidateId.startsWith('manual-')) throw new ReportNotFoundException();
      if (candidate && candidate.status !== 'needs_review') throw new ConflictException('Candidate state changed');
      const rules = await loadObservationRules((sql) => runner.query(sql));
      const normalized = normalizeObservation({ parameterName: review.testRaw, value: review.resultRaw, unit: review.unitRaw, corrected: true }, rules);
      const [order] = await runner.query('SELECT COALESCE(max(sort_order),-1)+1 AS next FROM report_lab_values WHERE report_id=$1', [reportId]);
      const lab = runner.manager.getRepository(ReportLabValueEntity).create({
        reportId,
        parameterName: review.testRaw,
        originalParameterName: candidate?.testRaw ?? review.testRaw,
        value: review.resultRaw,
        rawResult: candidate?.resultRaw ?? review.resultRaw,
        unit: review.unitRaw,
        originalUnit: candidate?.unitRaw ?? review.unitRaw,
        sampleDate: null,
        originalSampleDate: null,
        collectionDateSource: 'unknown',
        extractionSource: 'paddleocr_vl_review',
        reviewVersion: 1,
        referenceRange: review.rangeRaw,
        sourceSnapshot: { engine: candidate?.table === 1000 ? 'PP-OCRv5' : 'PaddleOCR-VL-1.6', candidateId, page: candidate?.page ?? review.page,
          tableBox: candidate?.tableBox ?? null, modelPrediction: candidate ?? null,
          reviewerDecision: review, interpretationReady: false },
        identityEvidence: null,
        sortOrder: Number(order.next),
        ...normalized,
        reviewState: 'verified',
      });
      await runner.manager.getRepository(ReportLabValueEntity).save(lab);
      await runner.query(`UPDATE report_vl_shadows SET applied=$2::jsonb,updated_at=now() WHERE report_id=$1`,
        [reportId, JSON.stringify({ ...applied, [candidateId]: lab.id })]);
      await runner.query(`UPDATE reports SET summary=NULL,summary_status='not_requested' WHERE id=$1`, [reportId]);
      await runner.query('DELETE FROM report_result_insights WHERE report_id=$1', [reportId]);
      await runner.commitTransaction();
      return { labValueId: lab.id, reviewVersion: row.review_version };
    } catch (error) {
      await runner.rollbackTransaction();
      throw error;
    } finally {
      await runner.release();
    }
  }
}
