type JsonObject = Record<string, unknown>;

function object(value: unknown): JsonObject {
  return value && typeof value === 'object' && !Array.isArray(value)
    ? (value as JsonObject)
    : {};
}

export function isDoclingDocument(value: unknown): boolean {
  const doc = object(value);
  return (
    doc.schema_name === 'DoclingDocument' &&
    Array.isArray(doc.texts) &&
    Array.isArray(doc.tables)
  );
}

/** Adapt native Docling JSON to the parser's existing node/table contract.
 * Keep sparse columns in place. Never shift a result into an empty cell.
 */
export function adaptDoclingDocument(input: unknown): unknown {
  if (!isDoclingDocument(input)) return input;
  const doc = object(input);
  const provenance = (item: JsonObject): JsonObject => {
    const prov = object(Array.isArray(item.prov) ? item.prov[0] : undefined);
    const box = object(prov.bbox);
    const page = object(object(doc.pages)[String(prov.page_no)]);
    const height = object(page.size).height;
    const { l, t, r, b } = box;
    if (
      ![l, t, r, b].every((n) => typeof n === 'number' && Number.isFinite(n))
    ) {
      return { 'page number': prov.page_no };
    }
    // Existing spatial extraction uses a bottom-left origin.
    const topLeft = box.coord_origin === 'TOPLEFT';
    if (topLeft && typeof height !== 'number')
      return { 'page number': prov.page_no };
    return {
      'page number': prov.page_no,
      'bounding box': topLeft
        ? [
            l,
            (height as number) - (t as number),
            r,
            (height as number) - (b as number),
          ]
        : [l, t, r, b],
    };
  };
  const texts: JsonObject[] = (doc.texts as unknown[]).map((value) => {
    const item = object(value);
    return {
      type: item.label ?? 'text',
      content: item.text,
      ...provenance(item),
    };
  });
  const tables = (doc.tables as unknown[]).map((value) => {
    const item = object(value);
    const data = object(item.data);
    const count = data.num_cols;
    const rowCount = data.num_rows;
    // Bound allocation for malformed/untrusted parser output.
    if (
      !Number.isInteger(count) ||
      !Number.isInteger(rowCount) ||
      (count as number) < 1 ||
      (count as number) > 100 ||
      (rowCount as number) < 1 ||
      (rowCount as number) > 10000 ||
      (count as number) * (rowCount as number) > 100000
    ) {
      return { type: 'table', rows: [], ...provenance(item) };
    }
    const rows = Array.from({ length: rowCount as number }, () => ({
      cells: Array.from(
        { length: count as number },
        (): JsonObject => ({ content: '' }),
      ),
    }));
    for (const value of Array.isArray(data.table_cells)
      ? data.table_cells
      : []) {
      const cell = object(value);
      const row = cell.start_row_offset_idx;
      const col = cell.start_col_offset_idx;
      const endRow = cell.end_row_offset_idx;
      const endCol = cell.end_col_offset_idx;
      if (
        ![row, col, endRow, endCol].every(Number.isInteger) ||
        (row as number) < 0 ||
        (col as number) < 0 ||
        (endRow as number) > rows.length ||
        (endCol as number) > (count as number) ||
        (endRow as number) <= (row as number) ||
        (endCol as number) <= (col as number)
      )
        continue;
      const merged =
        (endRow as number) - (row as number) > 1 ||
        (endCol as number) - (col as number) > 1;
      for (let y = row as number; y < (endRow as number); y++) {
        for (let x = col as number; x < (endCol as number); x++) {
          const existing = rows[y].cells[x];
          rows[y].cells[x] = {
            content: typeof cell.text === 'string' ? cell.text : '',
            // Merged/overlapping data cells must not become multiple observations.
            ambiguous: merged || existing.occupied === true,
            occupied: true,
            columnHeader: cell.column_header === true,
          };
        }
      }
    }
    return { type: 'table', rows, ...provenance(item) };
  });
  // A layout model can leave a small lab table as independent text blocks.
  // Recover only rows aligned with explicit column headers on the SAME page.
  // Require an isolated numeric result plus a unit or reference cell; prose and
  // reference-only interpretation tables must never become observations.
  const spatial: JsonObject[] = [...texts];
  for (const value of doc.tables as unknown[]) {
    const item = object(value);
    const prov = object(Array.isArray(item.prov) ? item.prov[0] : undefined);
    const data = object(item.data);
    for (const value of Array.isArray(data.table_cells)
      ? data.table_cells
      : []) {
      const cell = object(value);
      if (cell.start_row_offset_idx !== 0) continue;
      spatial.push({
        type: 'header',
        content: cell.text,
        ...provenance({ prov: [{ page_no: prov.page_no, bbox: cell.bbox }] }),
      });
    }
  }
  const box = (item: JsonObject): number[] | undefined =>
    Array.isArray(item['bounding box'])
      ? (item['bounding box'] as number[])
      : undefined;
  const recovered: JsonObject[] = [];
  for (const header of spatial) {
    if (!/^test name$/i.test(String(header.content)) || !box(header)) continue;
    const page = header['page number'];
    const hbox = box(header)!;
    const headerAt = (pattern: RegExp) =>
      spatial.find(
        (node) =>
          node['page number'] === page &&
          box(node) &&
          Math.abs(box(node)![1] - hbox[1]) < 5 &&
          pattern.test(String(node.content)),
      );
    const resultHeader = headerAt(/^results?$/i);
    const unitHeader = headerAt(/^(units?|uom)$/i);
    const rangeHeader = headerAt(
      /^(ref(?:erence)? range|reference interval)$/i,
    );
    const combinedHeader = headerAt(
      /^(?:flag\s+)?unit\s+ref(?:erence)? range$/i,
    );
    if (!resultHeader || ((!unitHeader || !rangeHeader) && !combinedHeader))
      continue;
    const resultX = box(resultHeader)![0];
    const unitX = unitHeader ? box(unitHeader)![0] : undefined;
    const rangeX = rangeHeader ? box(rangeHeader)![0] : undefined;
    if (!(hbox[0] < resultX)) continue;
    if (
      unitX !== undefined &&
      rangeX !== undefined &&
      !(resultX < unitX && unitX < rangeX)
    )
      continue;
    const pageTexts = texts.filter(
      (node) => node['page number'] === page && box(node),
    );
    const rows: JsonObject[] = [];
    for (const name of pageTexts) {
      const nb = box(name)!;
      if (
        nb[1] >= hbox[1] ||
        Math.abs(nb[0] - hbox[0]) > 12 ||
        nb[2] >= resultX ||
        typeof name.content !== 'string' ||
        !/[A-Za-z]/.test(name.content) ||
        /\b(method|sample|interpretation|comment)\b/i.test(name.content) ||
        name.content.length > 100
      )
        continue;
      const aligned = (x: number) =>
        pageTexts.filter(
          (node) =>
            Math.abs(box(node)![0] - x) < 12 &&
            Math.abs(box(node)![1] - nb[1]) < 4,
        );
      const results = aligned(resultX);
      let units = unitX === undefined ? [] : aligned(unitX);
      let ranges = rangeX === undefined ? [] : aligned(rangeX);
      if ((unitX === undefined || rangeX === undefined) && combinedHeader) {
        const right = pageTexts
          .filter(
            (node) =>
              box(node)![0] > resultX + 30 &&
              Math.abs(box(node)![1] - nb[1]) < 4 &&
              !/^(high|low|h|l)$/i.test(String(node.content)),
          )
          .sort((a, b) => box(a)![0] - box(b)![0]);
        // The grouped header establishes the order; require two isolated cells.
        if (
          right.length !== 2 ||
          !/^[A-Za-zµμ%][A-Za-zµμ0-9/^%.²³ -]*$/.test(
            String(right[0].content),
          ) ||
          !/^[<>≤≥=\s\d.,–-]+$/.test(String(right[1].content))
        )
          continue;
        units = [right[0]];
        ranges = [right[1]];
      }
      if (
        results.length !== 1 ||
        units.length > 1 ||
        ranges.length > 1 ||
        (units.length === 0 && ranges.length === 0) ||
        !/^(?:[<>]=?|[≤≥])?\s*[-+]?\d[\d,]*(?:\.\d+)?$/.test(
          String(results[0].content),
        )
      )
        continue;
      rows.push({
        cells: [
          name,
          results[0],
          units[0] ?? { content: '' },
          ranges[0] ?? { content: '' },
        ],
      });
    }
    if (rows.length)
      recovered.push({
        type: 'table',
        'page number': page,
        rows: [
          {
            cells: ['Test Name', 'Result', 'Unit', 'Ref Range'].map(
              (content) => ({ content }),
            ),
          },
          ...rows,
        ],
      });
  }
  return { type: 'document', kids: [...texts, ...tables, ...recovered] };
}
