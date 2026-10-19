import unittest
from adapter import adapt

class AdapterTests(unittest.TestCase):
    def test_merged_first_result(self):
        d = adapt('<table><tr><td>Test Hemoglobin</td><td>Result 14.5</td><td>Unit g/dL</td></tr><tr><td>MCV</td><td>90.3</td><td>fL</td></tr></table>')
        rows=d['kids'][0]['rows']
        self.assertEqual([c['content'] for c in rows[0]['cells']], ['Test Name','Result','Unit'])
        self.assertEqual(rows[1]['cells'][1]['content'], '14.5')
    def test_unknown_and_truncated(self):
        d=adapt('<table><tr><td>Unknown</td><td>123</td></tr></table>')
        self.assertEqual(d['kids'][0]['rows'][0]['cells'][0]['content'],'Unknown')
        self.assertTrue(adapt('<table><tr><td>unfinished')['extractionIncomplete'])
    def test_spans_never_shift_cells(self):
        d=adapt('<table><tr><td colspan="2">Heading</td><td>Value</td></tr><tr><td rowspan="2">A</td><td>1</td></tr></table>')
        rows=d['kids'][0]['rows']
        self.assertEqual(rows[0]['cells'][2]['content'],'Value')
        self.assertTrue(rows[1]['cells'][0]['ambiguous'])
    def test_paired_counts_and_smear(self):
        d=adapt('<table><tr><td>Test</td><td>Method</td><td>Result</td><td>Unit</td><td>Reference Range</td></tr><tr><td>Marker</td><td>Counting</td><td>5</td><td>%</td><td>0 - 10</td></tr></table>'
            '<table><tr><td colspan="5">Differential Count</td><td>Absolute Count</td></tr><tr><td>Novel cell</td><td>Microscopy</td><td>12</td><td>% 0 - 20</td><td></td><td>120 /cmm 0 - 200</td></tr></table>'
            'Peripheral Smear Examination<table><tr><td>RBC Morphology</td><td>Normal morphology</td></tr></table>')
        tables=[n for n in d['kids'] if n['type']=='table']
        rows=tables[1]['rows']
        self.assertEqual(rows[1]['cells'][2]['content'],'12')
        self.assertEqual(rows[2]['cells'][0]['content'],'Novel cell absolute')
        self.assertEqual(rows[2]['cells'][2]['content'],'120')
        self.assertEqual(tables[2]['rows'][0]['cells'][1]['content'],'Result')

    def test_interpretation_resets_inherited_columns(self):
        d=adapt('<table><tr><td>Test</td><td>Result</td></tr><tr><td>Marker</td><td>7</td></tr></table>Interpretation<table><tr><td>Low</td><td>5</td></tr><tr><td>High</td><td>10</td></tr></table>')
        tables=[n for n in d['kids'] if n['type']=='table']
        self.assertEqual(tables[1]['rows'][0]['cells'][0]['content'], 'Low')

    def test_coordinates_are_data(self):
        d=adapt('<|ref|>text<|/ref|><|det|>__import__("os").system("false")<|/det|>hello')
        self.assertEqual(d['kids'][0]['content'],'hello')

if __name__ == '__main__': unittest.main()
