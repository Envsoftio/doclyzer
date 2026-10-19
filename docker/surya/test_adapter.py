import unittest
from html import escape
from adapter import adapt, unit_markup

HEADER = '<table><tr><th>Test Name</th><th>Result</th><th>Flag</th><th>Unit</th><th>Ref Range</th></tr></table>'

def block(html, label='Table', **extra):
    return {'html': html, 'label': label, **extra}

def run(blocks, pages=None):
    return adapt({'report': pages or [{'blocks': blocks}]})

def rows(result):
    return [[c['content'] for c in row['cells']] for table in result['parsedJson']['kids'] if table['type'] == 'table' for row in table['rows'][1:]]

class AdapterTests(unittest.TestCase):
    def test_explicit_unit_typography_does_not_guess_digits(self):
        self.assertEqual(unit_markup(r'10^3/\mu\text{L}'), '10^3/µL')
        self.assertEqual(unit_markup(r'10^{3}/\mathrm{uL}'), '10^3/uL')
        self.assertEqual(unit_markup('1043/uL'), '1043/uL')
        self.assertEqual(unit_markup(r'\unknown{L}'), r'\unknown{L}')

    def test_detached_header_and_missing_empty_flag(self):
        out = run([block(HEADER), block('<table><tr><td>Glucose</td><td>84.2</td><td>mg/dL</td><td>70-100</td></tr></table>')])
        self.assertEqual(rows(out), [['Glucose', '84.2', '', 'mg/dL', '70-100']])

    def test_paragraph_and_comparator(self):
        out = run([block(HEADER), block('<p><b>Vitamin X</b> &lt;5 pg/mL 10-40</p>', 'Text')])
        self.assertEqual(rows(out), [['Vitamin X', '<5', '', 'pg/mL', '10-40']])

    def test_flag_is_not_unit(self):
        out = run([block(HEADER), block('<table><tr><td>Ratio</td><td>1.2</td><td></td><td>Low</td><td>2-3</td></tr></table>')])
        self.assertEqual(rows(out)[0][2:4], ['Low', ''])
        self.assertEqual(out['diagnostics']['warnings'], ['flag_moved_from_unit'])

    def test_interpretation_not_observations(self):
        out = run([block(HEADER), block('<h3>Interpretation</h3>', 'SectionHeader'), block('<table><tr><td>Normal</td><td>5</td><td>%</td><td>4-6</td></tr></table>'), block('<p><b>Example</b> 5 mg/dL 1-10</p>', 'Text')])
        self.assertEqual(rows(out), [])

    def test_headers_do_not_cross_pages(self):
        out = run([], [{'blocks': [block(HEADER)]}, {'blocks': [block('<p><b>Vitamin X</b> 5 pg/mL 1-10</p>', 'Text')]}])
        self.assertEqual(rows(out), [])

    def test_merged_cells_are_not_duplicated(self):
        out = run([block(HEADER), block('<table><tr><td>Glucose</td><td rowspan="2">90</td><td></td><td>mg/dL</td><td>70-100</td></tr></table>')])
        self.assertEqual(rows(out), [])

    def test_partial_failure_rejected(self):
        with self.assertRaises(ValueError):
            run([block(HEADER), block('', error=True)])

    def test_superscript(self):
        out = run([block(HEADER), block('<table><tr><td>GFR</td><td>95</td><td></td><td>mL/min/1.73 m<sup>2</sup></td><td>&gt;90</td></tr></table>')])
        self.assertEqual(rows(out)[0][3], 'mL/min/1.73 m²')

    def test_qualitative_result_and_liter_unit(self):
        out = run([block(HEADER), block('<table><tr><td>Protein</td><td>Negative</td><td></td><td></td><td>Negative</td></tr><tr><td>Volume</td><td>2</td><td></td><td>L</td><td>1-3</td></tr></table>')])
        self.assertEqual(rows(out)[0][1], 'Negative')
        self.assertEqual(rows(out)[1][3], 'L')
        self.assertEqual(out['diagnostics']['warnings'], [])

    def test_no_guessing_paragraph_or_short_explicit_row(self):
        out = run([block(HEADER.replace('</table>', '<tr><td>Glucose</td><td>90</td><td>High</td><td>mg/dL</td></tr></table>')), block('<p>Example Glucose 90 mg/dL</p>', 'Text')])
        self.assertEqual(rows(out), [])


    def test_diverse_column_layouts(self):
        cases = [
            (['Investigation', 'Observed Value', 'Units', 'Biological Reference Interval'],
             ['Ferritin', '36', 'ng/mL', '15-150'], ['Ferritin', '36', '', 'ng/mL', '15-150']),
            (['Reference Interval', 'UOM', 'Result', 'Analyte'],
             ['0-5', 'mg/L', '<3', 'CRP'], ['CRP', '<3', '', 'mg/L', '0-5']),
            (['Component', 'Value'], ['Culture', 'No growth'], ['Culture', 'No growth', '', '', '']),
            (['Examination', 'Results', 'Method'], ['Urine RBC', '0-2', 'Microscopy'], ['Urine RBC', '0-2', '', '', '']),
            (['Test Description', 'Units of Measurement', 'Patient Result', 'Reference Limits', 'Flag'],
             ['Antibody', '', '1:80', '<1:40', 'High'], ['Antibody', '1:80', 'High', '', '<1:40']),
            (['Assay', 'Test Result'], ['Protein', '+++'], ['Protein', '+++', '', '', '']),
        ]
        for header, data, expected in cases:
            with self.subTest(header=header):
                html = '<table>' + ''.join('<tr>' + ''.join('<td>' + escape(c) + '</td>' for c in row) + '</tr>' for row in [header, data]) + '</table>'
                out = run([block(html)])
                self.assertEqual(rows(out), [expected])
                self.assertEqual(out['diagnostics']['warnings'], [])

    def test_title_and_repeated_reordered_headers(self):
        html = '<table><tr><td colspan="3">Biochemistry</td></tr><tr><th>Analyte</th><th>Result</th><th>Unit</th></tr><tr><td>Sodium</td><td>140</td><td>mmol/L</td></tr><tr><th>Units</th><th>Investigation</th><th>Observed Value</th></tr><tr><td>mmol/L</td><td>Potassium</td><td>4.1</td></tr></table>'
        self.assertEqual(rows(run([block(html)])), [['Sodium', '140', '', 'mmol/L', ''], ['Potassium', '4.1', '', 'mmol/L', '']])

    def test_ambiguous_history_and_unknown_layout_are_visible(self):
        for header in [ ['Test', 'Result', 'Result'], ['Test', 'Result', 'Previous Result'], ['Test', '2025', '2026'] ]:
            html = '<table><tr>' + ''.join('<th>'+c+'</th>' for c in header) + '</tr><tr><td>Glucose</td><td>80</td><td>95</td></tr></table>'
            out = run([block(html)])
            self.assertEqual(rows(out), [])
            self.assertTrue(out['diagnostics']['warnings'])

    def test_merged_historical_header_does_not_inherit_old_mapping(self):
        out = run([block(HEADER), block('<table><tr><th>Test</th><th colspan="2">Result</th></tr><tr><td>Glucose</td><td>80</td><td>95</td></tr></table>')])
        self.assertEqual(rows(out), [])
        self.assertIn('merged_header', out['diagnostics']['warnings'])

    def test_unknown_row_not_silently_dropped(self):
        out = run([block('<table><tr><th>Test</th><th>Result</th></tr><tr><td>Culture</td><td>Organism identified: example</td></tr></table>')])
        self.assertEqual(rows(out), [])
        self.assertIn('unsupported_result_row', out['diagnostics']['warnings'])

if __name__ == '__main__':
    unittest.main()
