"""Synthetic contract tests; no inference quality claims."""
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import fitz
import server


def synthetic_pdf():
    doc = fitz.open()
    page = doc.new_page(width=300, height=400)
    page.insert_text((20, 30), 'Test Result')
    data = doc.tobytes()
    doc.close()
    return data


class FakeResult:
    json = {'res': {'rec_texts': ['12.8'], 'rec_scores': [0.75],
                    'rec_polys': [[[10, 20], [40, 20], [40, 30], [10, 30]]]}}


class FakeOCR:
    def predict(self, image, text_rec_score_thresh):
        assert Path(image).exists()
        assert text_rec_score_thresh == 0.0
        return [FakeResult()]


class ServerTests(unittest.TestCase):
    def test_native_and_aligned_ocr_contract(self):
        with patch.object(server, 'get_ocr', return_value=FakeOCR()):
            result = server.read_one_page(synthetic_pdf())
        self.assertTrue(result['native_words'])
        self.assertEqual(result['paddle']['rec_texts'], ['12.8'])
        self.assertEqual(len(result['paddle']['rec_polys']), len(result['paddle']['rec_scores']))
        self.assertEqual(result['page_width'], 300)

    def test_supervisor_returns_child_result(self):
        value = {'page_width': 300, 'paddle': {'rec_texts': []}}
        class FakeStdin:
            def write(self, command):
                import json
                _, _, result_path = json.loads(command)
                Path(result_path).write_text(json.dumps(value))
            def flush(self):
                pass
            def close(self):
                pass
        class FakeStdout:
            def readline(self):
                return 'OK\n'
            def close(self):
                pass
        class FakeProcess:
            stdin = FakeStdin()
            stdout = FakeStdout()
            def poll(self):
                return None
            def terminate(self):
                pass
            def wait(self, timeout=None):
                return 0
        server.stop_worker()
        with patch.object(server.subprocess, 'Popen', return_value=FakeProcess()) as spawn:
            with patch.object(server.select, 'select', return_value=([FakeProcess.stdout], [], [])):
                self.assertEqual(server.run_supervised(b'pdf'), value)
                self.assertEqual(server.run_supervised(b'pdf'), value)
        self.assertEqual(spawn.call_count, 1)
        server.stop_worker()

    def test_timeout_restarts_supervised_worker(self):
        from fastapi import HTTPException
        server.stop_worker()
        with patch.object(server.subprocess, 'Popen') as spawn:
            spawn.return_value.poll.return_value = None
            with patch.object(server.select, 'select', return_value=([], [], [])):
                with self.assertRaises(HTTPException) as error:
                    server.run_supervised(b'pdf')
        self.assertEqual(error.exception.status_code, 504)
        self.assertIsNone(server._worker)

    def test_native_words_have_top_left_coordinates(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / 'source.pdf'
            path.write_bytes(synthetic_pdf())
            words = server.native_words(path, 400)
        self.assertTrue(words)
        self.assertEqual(words[0]['coord_origin'], 'TOPLEFT')
        self.assertLess(words[0]['bbox'][1], 100)


if __name__ == '__main__':
    unittest.main()
