"""Convert Unlimited HTML tables to the shared document contract.
No model calls, numeric coercion, HTML execution, or cross-page column inference.
Unknown structures remain tables so downstream completeness checks fail closed.
"""
import re
from html.parser import HTMLParser

HEADER = {
    'name': r'(?:test(?: name)?|investigations?|parameters?|analyte)',
    'value': r'(?:results?|observed value)',
    'unit': r'(?:units?|uom)',
    'range': r'(?:biological ref\.? interval|biological reference interval|reference range|ref\.? range)',
    'method': r'method',
}

class Tables(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.blocks = []
        self.table = None
        self.row = None
        self.cell = None
        self.span = 1
        self.ambiguous = False
        self.outside = []

    def flush_text(self):
        text = re.sub(r'\s+', ' ', ''.join(self.outside)).strip()
        if text:
            self.blocks.append(('text', text))
        self.outside = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'table':
            self.flush_text()
            self.table = []
        elif tag == 'tr' and self.table is not None:
            self.row = []
        elif tag in ('td', 'th') and self.row is not None:
            self.cell = []
            try:
                self.span = max(1, min(100, int(attrs.get('colspan', 1))))
                self.ambiguous = int(attrs.get('rowspan', 1)) != 1
            except ValueError:
                self.span, self.ambiguous = 1, True
        elif tag == 'br':
            self.handle_data(' ')

    def handle_data(self, data):
        if self.cell is not None:
            self.cell.append(data)
        elif self.table is None:
            self.outside.append(data)

    def handle_endtag(self, tag):
        if tag in ('td', 'th') and self.cell is not None:
            self.row.append({'content': re.sub(r'\s+', ' ', ''.join(self.cell)).strip(),
                             'ambiguous': self.ambiguous})
            self.row.extend({'content': ''} for _ in range(self.span - 1))
            self.cell = None
        elif tag == 'tr' and self.row is not None:
            self.table.append({'cells': self.row})
            self.row = None
        elif tag == 'table' and self.table is not None:
            self.blocks.append(('table', self.table))
            self.table = None


def strip_markers(text):
    # Strip annotation tokens as data, never evaluate generated coordinates.
    return re.sub(r'<\|(?:ref|det)\|>.*?<\|/(?:ref|det)\|>', '', text, flags=re.S)


def adapt(text):
    parser = Tables()
    parser.feed(strip_markers(text))
    parser.flush_text()
    kids = []
    schema = None
    heading = ''
    for kind, value in parser.blocks:
        if kind == 'text':
            heading = value
            if len(value) > 250 or re.search(r'interpretation|reference (?:chart|table)|explanation|end of report', value, re.I):
                schema = None
            kids.append({'type': 'text', 'content': value, 'page number': 1})
            continue
        rows = value
        if not rows:
            continue
        full = ' '.join(c['content'] for r in rows for c in r['cells'])
        # Keep patient metadata in the document, not as an unmapped lab table.
        if re.search(r'patient information|sample information|client/location information', full, re.I):
            kids.append({'type': 'text', 'content': full, 'page number': 1})
            schema = None
            continue
        # Interpretation matrices are explanatory prose, not patient observations.
        boundary = next((i for i, r in enumerate(rows) if any(
            re.search(r'suggested interpretation|interpretation.*pattern', c['content'], re.I)
            for c in r['cells'])), None)
        if boundary is not None:
            kids.append({'type': 'text', 'content': ' '.join(c['content'] for r in rows[boundary:] for c in r['cells']), 'page number': 1})
            rows = rows[:boundary]
            if not rows:
                schema = None
                continue
        if re.search(r'peripheral smear examination', heading, re.I) and all(len(r['cells']) == 2 for r in rows):
            rows = [{'cells': [{'content': 'Test Name'}, {'content': 'Result'}]}] + rows
        # A paired differential/absolute header supplies two observations per row.
        # Only split cells whose entire value/unit/range syntax is recognized.
        paired = any(re.search(r'absolute count', c['content'], re.I) for r in rows for c in r['cells'])
        if paired and schema and all(k in schema[0] for k in ('name', 'value', 'unit', 'range')):
            cols, width = schema
            converted = []
            absolute_index = None
            for r in rows:
                cells = r['cells']
                labels = [c['content'] for c in cells]
                absolute_header = next((i for i, t in enumerate(labels) if re.fullmatch(r'absolute count', t, re.I)), None)
                if absolute_header is not None:
                    absolute_index = absolute_header
                    continue
                if absolute_index is None and len(cells) == width + 1 and not labels[cols['range']]:
                    converted.append({'cells': cells[:cols['range']] + cells[cols['range']+1:]})
                    continue
                if absolute_index is not None and len(cells) > absolute_index:
                    relative = re.fullmatch(r'(%)[ ]+(.+)', labels[cols['unit']])
                    absolute = re.fullmatch(r'(\d+(?:\.\d+)?)\s+(/(?:cmm|uL|µL))\s+(.+)', labels[absolute_index])
                    if relative and absolute:
                        base = [{'content': ''} for _ in range(width)]
                        for key in ('name', 'value', *(['method'] if 'method' in cols else [])):
                            base[cols[key]] = cells[cols[key]]
                        base[cols['unit']] = {'content': relative[1]}
                        base[cols['range']] = {'content': relative[2]}
                        converted.append({'cells': base, 'sourceText': ' | '.join(labels)})
                        other = [dict(c) for c in base]
                        other[cols['name']] = {'content': labels[cols['name']] + ' absolute'}
                        other[cols['value']] = {'content': absolute[1]}
                        other[cols['unit']] = {'content': absolute[2]}
                        other[cols['range']] = {'content': absolute[3]}
                        converted.append({'cells': other, 'sourceText': ' | '.join(labels)})
                        continue
                converted.append(r)
            rows = converted
        first = [c['content'] for c in rows[0]['cells']]
        previous_schema = schema
        detected, suffixes = {}, {}
        for i, cell in enumerate(first):
            for key, pattern in HEADER.items():
                m = re.fullmatch(pattern + r'(?:\s+(.*))?', cell, re.I)
                if m:
                    if key in detected:
                        detected = {}
                        break
                    detected[key] = i
                    suffixes[key] = m[1] or ''
                    break
        if 'name' in detected and 'value' in detected:
            schema = (detected, len(first))
            header = [''] * len(first)
            for key, i in detected.items():
                header[i] = {'name':'Test Name','value':'Result','unit':'Unit','range':'Reference Range','method':'Method'}[key]
            # A merged header/first observation is split only when both are explicit.
            if suffixes.get('name') and suffixes.get('value'):
                first_data = list(first)
                for key, i in detected.items():
                    first_data[i] = suffixes[key]
                rows = [{'cells':[{'content': c} for c in first_data]}] + rows[1:]
            else:
                rows = rows[1:]
            rows = [{'cells':[{'content': c} for c in header]}] + rows
        elif schema and all(len(r['cells']) == schema[1] for r in rows):
            detected = schema[0]
            header = [''] * schema[1]
            for key, i in detected.items():
                header[i] = {'name':'Test Name','value':'Result','unit':'Unit','range':'Reference Range','method':'Method'}[key]
            rows = [{'cells':[{'content': c} for c in header]}] + rows
        else:
            # Unknown/headerless layouts are deliberately retained for review.
            schema = None
        if schema and schema[1] == 2 and previous_schema:
            schema = previous_schema
        kids.append({'type': 'table', 'rows': rows, 'page number': 1,
                     'extractionEngine': 'unlimited-v1', 'sourceHeading': heading})
    return {'type': 'document', 'kids': kids,
            'extractionIncomplete': parser.table is not None or parser.cell is not None}
