import unittest
from fastapi.testclient import TestClient
from server import app, lock

class ServerTests(unittest.TestCase):
    def test_health_and_bad_pdf(self):
        with TestClient(app) as client:
            self.assertEqual(client.get('/health').status_code, 200)
            response = client.post('/v1/convert/pdf', content=b'not a PDF')
            self.assertEqual(response.status_code, 422)
            self.assertNotIn('not a PDF', response.text)
            self.assertFalse(lock.locked())

    def test_size_limit(self):
        import server
        old = server.MAX_BYTES
        try:
            server.MAX_BYTES = 10
            with TestClient(app) as client:
                self.assertEqual(client.post('/v1/convert/pdf', content=b'x'*11).status_code, 413)
        finally:
            server.MAX_BYTES = old

    def test_timeout_kills_worker_and_releases_lock(self):
        import asyncio
        import io
        from unittest.mock import patch, AsyncMock
        import pypdfium2 as pdfium
        class Process:
            returncode = None
            killed = False
            async def wait(self):
                if self.returncode is None:
                    await asyncio.sleep(60)
                return self.returncode
            def kill(self):
                self.killed = True
                self.returncode = -9
        process = Process()
        with pdfium.PdfDocument.new() as doc:
            doc.new_page(100, 100).close()
            data = io.BytesIO()
            doc.save(data)
        with patch.dict('os.environ', {'SURYA_INFERENCE_URL': 'http://local.invalid/v1'}), \
             patch('server.TIMEOUT', 0.01), \
             patch('server.asyncio.create_subprocess_exec', AsyncMock(return_value=process)):
            with TestClient(app) as client:
                self.assertEqual(client.post('/v1/convert/pdf', content=data.getvalue()).status_code, 504)
        self.assertTrue(process.killed)
        self.assertFalse(lock.locked())

if __name__ == '__main__':
    unittest.main()
