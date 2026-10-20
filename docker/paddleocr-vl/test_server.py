"""Service contract tests that do not load model weights or patient data."""
import io
import json
import unittest
from pathlib import Path
from unittest.mock import patch

from fastapi import HTTPException
from fastapi.testclient import TestClient
from PIL import Image
import pypdfium2 as pdfium

import server


class ServiceTests(unittest.TestCase):
    def test_image_limits(self):
        image = Image.new('RGB', (20, 20), 'white')
        output = io.BytesIO()
        image.save(output, format='PNG')
        self.assertEqual(server.file_type(output.getvalue()), '.png')
        with self.assertRaises(HTTPException):
            server.file_type(b'not an image')

    def test_single_pdf_page_only(self):
        document = pdfium.PdfDocument.new()
        document.new_page(200, 200)
        output = io.BytesIO()
        document.save(output)
        data = output.getvalue()
        self.assertEqual(server.file_type(data), '.pdf')
        document.new_page(200, 200)
        output = io.BytesIO()
        document.save(output)
        with self.assertRaises(HTTPException):
            server.file_type(output.getvalue())

    def test_deadline_and_child_response(self):
        def fake_run(args, **kwargs):
            self.assertEqual(kwargs['timeout'], 60)
            Path(args[-1]).write_text(json.dumps({'parsing_res_list': []}))
        with patch.object(server.subprocess, 'run', side_effect=fake_run):
            self.assertEqual(server.supervised(b'page', '.png'), {'parsing_res_list': []})
        with patch.object(server.subprocess, 'run', side_effect=__import__('subprocess').TimeoutExpired('worker', 60)):
            with self.assertRaises(HTTPException) as result:
                server.supervised(b'page', '.png')
        self.assertEqual(result.exception.status_code, 504)

    def test_authenticated_http_boundary(self):
        image = Image.new('RGB', (20, 20), 'white')
        output = io.BytesIO()
        image.save(output, format='PNG')
        with patch.object(server, 'API_KEY', 'private-test-key'), patch.object(
            server, 'supervised', return_value={'parsing_res_list': []}
        ):
            client = TestClient(server.app)
            self.assertEqual(client.post('/v1/parse/page', content=output.getvalue()).status_code, 403)
            accepted = client.post('/v1/parse/page', content=output.getvalue(), headers={'x-api-key': 'private-test-key'})
            self.assertEqual(accepted.status_code, 200)
            self.assertEqual(accepted.json(), {'parsing_res_list': []})
            invalid = client.post('/v1/parse/page', content=b'bad', headers={'x-api-key': 'private-test-key'})
            self.assertEqual(invalid.status_code, 422)


if __name__ == '__main__':
    unittest.main()
