#!/usr/local/bin/python
"""Tesseract table preset: remove only long straight rules, preserving text pixels.

The original PDF is never modified. Forward all CLI options without a shell and
remove the temporary image even when Tesseract fails. Keep OSD on the original
crop; sparse crops cannot supply orientation evidence and default to upright.
"""
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from PIL import Image, ImageDraw


def remove_rules(image):
    original = image.convert('RGB')
    result = original.copy()
    for transpose, minimum in [(False, max(100, original.width // 2)),
                               (True, max(100, original.height // 5))]:
        source = original.transpose(Image.Transpose.TRANSPOSE) if transpose else original
        target = result.transpose(Image.Transpose.TRANSPOSE) if transpose else result
        mask = source.convert('L').point(lambda x: 1 if x < 100 else 0).tobytes()
        pattern = re.compile(b'\x01{' + str(minimum).encode() + b',}')
        draw = ImageDraw.Draw(target)
        for y in range(source.height):
            for match in pattern.finditer(mask[y * source.width:(y + 1) * source.width]):
                draw.line((match.start(), y, match.end() - 1, y), fill='white', width=3)
        result = target.transpose(Image.Transpose.TRANSPOSE) if transpose else target
    return result


def main():
    args = sys.argv[1:]

    def value_after(flag):
        if flag not in args:
            return None
        index = args.index(flag) + 1
        return args[index] if index < len(args) else None

    if value_after('--psm') == '0' and value_after('-l') == 'osd':
        result = subprocess.run(['/usr/bin/tesseract', *args], capture_output=True)
        sparse_crop = (
            result.returncode
            and b'Too few characters. Skipping this page' in result.stderr
            and b'Error during processing.' in result.stderr
        )
        if sparse_crop:
            # Docling already assumes 0 degrees after this OSD error, then runs
            # OCR with the configured language. Return that same default without
            # filling the logs with errors for small table cells.
            sys.stdout.write('Orientation in degrees: 0\n')
            return 0
        sys.stdout.buffer.write(result.stdout)
        sys.stderr.buffer.write(result.stderr)
        return result.returncode
    image_index = next((i for i, arg in enumerate(args) if Path(arg).is_file()), None)
    if image_index is None:
        return subprocess.call(['/usr/bin/tesseract', *args])
    with Image.open(args[image_index]) as image:
        if image.width * image.height > 25_000_000:
            return subprocess.call(['/usr/bin/tesseract', *args])
        with tempfile.TemporaryDirectory(prefix='ocr-table-') as folder:
            path = str(Path(folder) / 'page.png')
            remove_rules(image).save(path)
            args[image_index] = path
            return subprocess.call(['/usr/bin/tesseract', *args])


if __name__ == '__main__':
    sys.exit(main())
