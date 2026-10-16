"""Conservative Surya 2 HTML -> shared report-parser document contract."""
import re
from bs4 import BeautifulSoup

HEADERS = ['Test Name', 'Result', 'Flag', 'Unit', 'Ref Range']
NUMBER = r'[<>≤≥]?[=]?\s*[+-]?(?:\d{1,3}(?:,\d{3})+|\d+)(?:\.\d+)?'
VALUE = re.compile(rf'^(?:{NUMBER}(?:\s*[HL*])?|\d+(?:\.\d+)?\s*[-–]\s*\d+(?:\.\d+)?|\d+:\d+|[+]{{1,4}}|negative|positive|non[- ]?reactive|reactive|nil|trace|normal|absent|present|not detected|detected|no growth|sterile|clear|cloudy|turbid|pale yellow|yellow|amber|straw)$', re.I)
FLAG = re.compile(r'^(?:high|low|H|L)$', re.I)
STOP = re.compile(r'interpretation|expected values|reference values|comments|clinical applications', re.I)


# Semantic column roles; neither laboratory names nor analyte names are encoded.
COLUMN_LABELS = {
    'name': r'test(?: name| description)?|investigation(?:s| name)?|parameter(?:s| name)?|analyte|analyte name|component|examination|assay',
    'value': r'result(?:s)?|value(?:s)?|observed value(?:s)?|test result|observed result|observation|patient result',
    'flag': r'flag(?:s)?|abnormal flag|status',
    'unit': r'unit(?:s)?|uom|units of measurement',
    'range': r'ref(?:erence)?(?: range| interval| values?)?|normal (?:range|interval|values?)|bio(?:logical)? ref(?:erence)? (?:range|interval)|biological reference interval|reference limits',
}
ROLES = ['name', 'value', 'flag', 'unit', 'range']


def header_mapping(row):
    mapping = {}
    duplicate = False
    for index, cell in enumerate(row):
        label = re.sub(r'[.():]', '', cell.lower())
        label = re.sub(r'\s+', ' ', label).strip()
        for role, pattern in COLUMN_LABELS.items():
            if re.fullmatch(pattern, label):
                duplicate |= role in mapping
                mapping[role] = index
    if 'name' in mapping and 'value' in mapping:
        # Extra historical/date result columns cannot be silently ignored.
        historical = any(re.search(r'previous|prior|historical|current|\b20\d{2}\b', c, re.I) for c in row)
        return ('ambiguous' if duplicate or historical else 'valid'), mapping
    if 'name' in mapping:
        return 'unsupported', mapping
    return None, mapping


def is_candidate(row):
    return (len(row) > 1 and any(VALUE.fullmatch(c) for c in row)
            and any(any(ch.isalpha() for ch in c) and not VALUE.fullmatch(c) for c in row))


def canonical_row(row, mapping, width, explicit, warnings):
    if len(row) != width:
        # Only reconstruct a missing blank flag in a detached table. Other
        # missing cells could shift a range or a historical result into Value.
        if not explicit and len(row) == width - 1 and 'flag' in mapping:
            row = row[:mapping['flag']] + [''] + row[mapping['flag']:]
        else:
            warnings.append('ambiguous_row_width')
            return None
    values = [row[mapping[role]] if role in mapping else '' for role in ROLES]
    name, value, flag, unit, reference = values
    if not any(ch.isalpha() for ch in name) or not VALUE.fullmatch(value):
        warnings.append('unsupported_result_row')
        return None
    if flag and not FLAG.fullmatch(flag) and flag not in ('*', '!', '↑', '↓'):
        warnings.append('unsupported_flag')
        return None
    if re.fullmatch(r'high|low', unit, re.I):
        if flag:
            warnings.append('conflicting_flag_and_unit')
            return None
        warnings.append('flag_moved_from_unit')
        values[2], values[3] = unit, ''
    return values


def text(node):
    return re.sub(r'\s+([⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻])', r'\1', re.sub(r'\s+', ' ', node.get_text(' ', strip=True))).strip()


def adapt(raw):
    if not isinstance(raw, dict) or len(raw) != 1:
        raise ValueError('Expected one Surya document')
    pages = next(iter(raw.values()))
    if not isinstance(pages, list) or not pages:
        raise ValueError('Missing pages')
    nodes, transcript, warnings = [], [], []
    for page_number, page in enumerate(pages, 1):
        if not isinstance(page.get('blocks'), list) or not page['blocks']:
            raise ValueError('Missing page blocks')
        active = False
        header_seen = False
        mapping = {}
        width = 0
        in_interpretation = False
        for block in page['blocks']:
            if block.get('error'):
                raise ValueError('Partial OCR failure')
            soup = BeautifulSoup(block.get('html', ''), 'html.parser')
            for sup in soup.find_all('sup'):
                value = sup.get_text()
                sup.replace_with(value.translate(str.maketrans('0123456789+-', '⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻')))
            content = text(soup)
            if not content:
                continue
            transcript.append(content)
            # Keep source text for metadata and audit, never HTML for rendering.
            nodes.append({'type': 'text', 'content': content, 'page number': page_number})
            if block.get('label') == 'SectionHeader':
                if STOP.search(content):
                    active = False
                    in_interpretation = True
                elif header_seen and re.search(r'\bsample\s*type', content, re.I):
                    active = True
                    in_interpretation = False
            for table in soup.find_all('table'):
                rows = []
                merged_header = False
                for tr in table.find_all('tr'):
                    cells = tr.find_all(['td', 'th'], recursive=False)
                    if any(int(c.get('colspan', 1)) != 1 or int(c.get('rowspan', 1)) != 1 for c in cells):
                        # Spanning headings are not observations. Never copy a merged result.
                        if header_mapping([text(c) for c in cells])[0]:
                            merged_header = True
                        if any(VALUE.fullmatch(text(c)) for c in cells):
                            warnings.append('merged_result_row')
                        continue
                    rows.append([text(c) for c in cells])
                if merged_header:
                    active = header_seen = False
                    warnings.append('merged_header')
                    continue
                if not rows:
                    continue
                # Metadata and instrument peak tables are not patient observations.
                first_labels = ' '.join(rows[0]).lower()
                if re.search(r'patient name|uhid|sample id|lab no|barcode|peak name|retention time|egfr range', first_labels):
                    continue
                accepted = []
                explicit = False
                for row in rows:
                    kind, detected = header_mapping(row)
                    if kind:
                        explicit = True
                        active = kind == 'valid'
                        in_interpretation = False
                        if active:
                            header_seen = True
                            mapping, width = detected, len(row)
                        else:
                            mapping, width = {}, 0
                            header_seen = False
                            warnings.append('ambiguous_header' if kind == 'ambiguous' else 'unsupported_header')
                        continue
                    if not active:
                        if not in_interpretation and is_candidate(row):
                            warnings.append('unmapped_result_table')
                        continue
                    # Ignore a section title or method-only continuation, but
                    # retain a warning for any unrecognized populated value.
                    value_index = mapping['value']
                    has_value = value_index < len(row) and bool(row[value_index].strip())
                    if not is_candidate(row) and not has_value:
                        continue
                    converted = canonical_row(row, mapping, width, explicit, warnings)
                    if converted:
                        accepted.append(converted)
                if accepted:
                    nodes.append(make_table(accepted, page_number))
            # Recover a paragraph result only with an explicit bold test label and
            # a preceding lab header. Full-match the tail; never scan prose for numbers.
            if active and not soup.find('table') and block.get('label') == 'Text':
                p = soup.find('p')
                bold = p.find(['b', 'strong'], recursive=False) if p else None
                if bold and text(p).startswith(text(bold)):
                    name = text(bold)
                    tail = text(p)[len(name):].strip()
                    match = re.fullmatch(rf'({NUMBER})\s+(?:(High|Low)\s+)?([A-Za-zµμ%][A-Za-z0-9µμ%/^²³.\-]*)(?:\s+([<>≤≥=\d][\d.<>≤≥=\s\-]*))?', tail)
                    if match:
                        value, flag, unit, reference = match.groups()
                        nodes.append(make_table([[name, value, flag or '', unit, reference or '']], page_number))
                    elif re.match(NUMBER, tail):
                        warnings.append('unsupported_result_paragraph')
    return {'text': '\n'.join(transcript), 'parsedJson': {'type': 'document', 'kids': nodes},
            'diagnostics': {'pages': len(pages), 'warnings': warnings}}


def make_table(rows, page):
    return {'type': 'table', 'page number': page,
            'rows': [{'cells': [{'content': c} for c in row]} for row in [HEADERS] + rows]}
