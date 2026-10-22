import importlib.util
import io
from pathlib import Path
import unittest
import tempfile
from unittest.mock import patch
from PIL import Image, ImageDraw

spec = importlib.util.spec_from_file_location('table_ocr', Path(__file__).with_name('tesseract-table.py'))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

class TablePreprocessTest(unittest.TestCase):
    def test_removes_rules_but_preserves_decimal_and_short_signs(self):
        image = Image.new('RGB', (800, 1000), 'white')
        draw = ImageDraw.Draw(image)
        draw.line((20, 100, 780, 100), fill='black', width=2)
        draw.line((100, 50, 100, 900), fill='black', width=2)
        draw.rectangle((240, 240, 243, 243), fill='black')  # decimal point
        draw.line((300, 240, 315, 240), fill='black', width=2)  # minus sign
        result = module.remove_rules(image)
        self.assertEqual(result.getpixel((200, 100)), (255, 255, 255))
        self.assertEqual(result.getpixel((100, 600)), (255, 255, 255))
        self.assertEqual(result.getpixel((241, 241)), (0, 0, 0))
        self.assertEqual(result.getpixel((305, 240)), (0, 0, 0))
        self.assertEqual(image.getpixel((200, 100)), (0, 0, 0))

    def test_cli_options_before_input_image_are_preserved(self):
        with tempfile.TemporaryDirectory() as folder:
            path = str(Path(folder) / 'input.png')
            image = Image.new('RGB', (800, 1000), 'white')
            ImageDraw.Draw(image).line((20, 100, 780, 100), fill='black', width=2)
            image.save(path)
            def invoke(args):
                self.assertEqual(args[:3], ['/usr/bin/tesseract', '-l', 'eng'])
                self.assertEqual(args[4:], ['stdout', 'tsv'])
                self.assertNotEqual(args[3], path)
                with Image.open(args[3]) as prepared:
                    self.assertEqual(prepared.getpixel((200, 100)), (255, 255, 255))
                return 0
            with patch.object(module.sys, 'argv', ['wrapper', '-l', 'eng', path, 'stdout', 'tsv']), patch.object(module.subprocess, 'call', side_effect=invoke):
                self.assertEqual(module.main(), 0)

    def test_sparse_osd_defaults_upright_without_preprocessing(self):
        with tempfile.TemporaryDirectory() as folder:
            path = str(Path(folder) / 'sparse.png')
            Image.new('RGB', (100, 100), 'white').save(path)
            args = ['--psm', '0', '-l', 'osd', path, 'stdout']
            output = io.StringIO()
            failure = module.subprocess.CompletedProcess(
                args, 1, b'', b'Too few characters. Skipping this page\nError during processing.\n'
            )
            with patch.object(module.sys, 'argv', ['wrapper', *args]), patch.object(module.sys, 'stdout', output), patch.object(module.subprocess, 'run', return_value=failure) as run:
                self.assertEqual(module.main(), 0)
            run.assert_called_once_with(['/usr/bin/tesseract', *args], capture_output=True)
            self.assertEqual(output.getvalue(), 'Orientation in degrees: 0\n')

    def test_other_osd_failures_are_not_hidden(self):
        args = ['--psm', '0', '-l', 'osd', '/missing.png', 'stdout']
        failure = module.subprocess.CompletedProcess(args, 2, b'', b'Cannot read input file')
        stdout = io.TextIOWrapper(io.BytesIO())
        stderr_bytes = io.BytesIO()
        stderr = io.TextIOWrapper(stderr_bytes)
        with patch.object(module.sys, 'argv', ['wrapper', *args]), patch.object(module.sys, 'stdout', stdout), patch.object(module.sys, 'stderr', stderr), patch.object(module.subprocess, 'run', return_value=failure):
            self.assertEqual(module.main(), 2)
        self.assertEqual(stderr_bytes.getvalue(), b'Cannot read input file')

if __name__ == '__main__': unittest.main()
