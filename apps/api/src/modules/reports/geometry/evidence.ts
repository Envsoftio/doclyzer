/** Source coordinates are top-left page pixels. A transform maps working-image
 * coordinates back to the original page; never infer character boxes from text. */
export type Point = [number, number];
export type Polygon = [Point, Point, Point, Point];
export type Affine = [number, number, number, number, number, number];
export type EvidenceEngine = 'paddleocr' | 'docling-parse' | 'tesseract';
export interface EvidenceToken {
  token_id: string;
  document_id: string;
  page_id: string;
  text_raw: string;
  polygon_original: Polygon;
  engine: EvidenceEngine;
  engine_version: string;
  model_version: string | null;
  confidence_raw: number | null;
  preprocessing_id: string | null;
  crop_id: string | null;
}
export interface PageEvidence {
  document_id: string;
  page_id: string;
  page_number: number;
  width: number;
  height: number;
  source_ref: string;
  render_ref: string | null;
  route: 'native' | 'ocr' | 'hybrid' | 'unprocessed';
  tokens: EvidenceToken[];
  failed_regions: string[];
  raw_output_ref: string | null;
}
export const IDENTITY: Affine = [1, 0, 0, 1, 0, 0];
export function transformPoint(
  [x, y]: Point,
  [a, b, c, d, e, f]: Affine,
): Point {
  return [a * x + c * y + e, b * x + d * y + f];
}
export function transformPolygon(polygon: Polygon, matrix: Affine): Polygon {
  return polygon.map((point) => transformPoint(point, matrix)) as Polygon;
}
function validPolygon(value: unknown): value is Polygon {
  return (
    Array.isArray(value) &&
    value.length === 4 &&
    value.every(
      (p) =>
        Array.isArray(p) &&
        p.length === 2 &&
        p.every((n) => typeof n === 'number' && Number.isFinite(n)),
    )
  );
}
function token(
  input: Omit<EvidenceToken, 'polygon_original'> & {
    polygon_original: unknown;
  },
): EvidenceToken {
  if (
    !validPolygon(input.polygon_original) ||
    typeof input.text_raw !== 'string'
  )
    throw new Error('Invalid OCR evidence');
  if (
    input.confidence_raw !== null &&
    (!Number.isFinite(input.confidence_raw) ||
      input.confidence_raw < 0 ||
      input.confidence_raw > 1)
  )
    throw new Error('Invalid OCR confidence');
  return input as EvidenceToken;
}
export interface PaddleRaw {
  rec_texts: string[];
  rec_scores: number[];
  rec_polys: unknown[];
}
/** Paddle's rec_* arrays are aligned. Reject mismatched arrays instead of
 * pairing filtered recognition text with dt_polys. */
export function adaptPaddle(
  raw: PaddleRaw,
  meta: {
    documentId: string;
    pageId: string;
    engineVersion: string;
    modelVersion: string;
    preprocessingId: string | null;
    workingToOriginal: Affine;
  },
): EvidenceToken[] {
  if (
    !Array.isArray(raw.rec_texts) ||
    !Array.isArray(raw.rec_scores) ||
    !Array.isArray(raw.rec_polys) ||
    raw.rec_texts.length !== raw.rec_scores.length ||
    raw.rec_texts.length !== raw.rec_polys.length
  )
    throw new Error('Paddle recognition arrays are not aligned');
  return raw.rec_texts.map((text, i) => {
    if (!validPolygon(raw.rec_polys[i]))
      throw new Error('Invalid Paddle polygon');
    return token({
      token_id: `${meta.pageId}:paddle:${i}`,
      document_id: meta.documentId,
      page_id: meta.pageId,
      text_raw: text,
      polygon_original: transformPolygon(
        raw.rec_polys[i],
        meta.workingToOriginal,
      ),
      engine: 'paddleocr',
      engine_version: meta.engineVersion,
      model_version: meta.modelVersion,
      confidence_raw: raw.rec_scores[i],
      preprocessing_id: meta.preprocessingId,
      crop_id: null,
    });
  });
}
export interface NativeWord {
  text: string;
  bbox: [number, number, number, number];
  coord_origin: 'TOPLEFT' | 'BOTTOMLEFT';
}
export function adaptNativeWords(
  words: NativeWord[],
  meta: {
    documentId: string;
    pageId: string;
    pageHeight: number;
    engineVersion: string;
  },
): EvidenceToken[] {
  return words.map((word, i) => {
    const [l, t, r, b] = word.bbox;
    const y0 = word.coord_origin === 'BOTTOMLEFT' ? meta.pageHeight - t : t;
    const y1 = word.coord_origin === 'BOTTOMLEFT' ? meta.pageHeight - b : b;
    return token({
      token_id: `${meta.pageId}:native:${i}`,
      document_id: meta.documentId,
      page_id: meta.pageId,
      text_raw: word.text,
      polygon_original: [
        [l, y0],
        [r, y0],
        [r, y1],
        [l, y1],
      ],
      engine: 'docling-parse',
      engine_version: meta.engineVersion,
      model_version: null,
      confidence_raw: null,
      preprocessing_id: null,
      crop_id: null,
    });
  });
}
export function adaptTesseractTsv(
  tsv: string,
  meta: {
    documentId: string;
    pageId: string;
    engineVersion: string;
    cropId: string;
    cropToOriginal: Affine;
  },
): EvidenceToken[] {
  const lines = tsv.trim().split(/\r?\n/);
  const header = lines.shift()?.split('\t') ?? [];
  const cols = ['level', 'left', 'top', 'width', 'height', 'conf', 'text'];
  if (!cols.every((c) => header.includes(c)))
    throw new Error('Invalid Tesseract TSV');
  return lines.flatMap((line, i) => {
    const cells = line.split('\t');
    const get = (key: string) => cells[header.indexOf(key)] ?? '';
    if (get('level') !== '5' || !get('text').trim()) return [];
    const [x, y, w, h, conf] = ['left', 'top', 'width', 'height', 'conf'].map(
      (c) => Number(get(c)),
    );
    if (![x, y, w, h, conf].every(Number.isFinite) || w <= 0 || h <= 0)
      return [];
    return [
      token({
        token_id: `${meta.pageId}:tesseract:${meta.cropId}:${i}`,
        document_id: meta.documentId,
        page_id: meta.pageId,
        text_raw: get('text'),
        polygon_original: transformPolygon(
          [
            [x, y],
            [x + w, y],
            [x + w, y + h],
            [x, y + h],
          ],
          meta.cropToOriginal,
        ),
        engine: 'tesseract',
        engine_version: meta.engineVersion,
        model_version: 'eng',
        confidence_raw: conf < 0 ? null : conf / 100,
        preprocessing_id: null,
        crop_id: meta.cropId,
      }),
    ];
  });
}
export function bounds(p: Polygon) {
  const xs = p.map((v) => v[0]);
  const ys = p.map((v) => v[1]);
  return {
    left: Math.min(...xs),
    right: Math.max(...xs),
    top: Math.min(...ys),
    bottom: Math.max(...ys),
    cx: (Math.min(...xs) + Math.max(...xs)) / 2,
    cy: (Math.min(...ys) + Math.max(...ys)) / 2,
  };
}
