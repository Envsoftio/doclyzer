"""Replay retained OCR output without loading a model or copying report data to the repo.
Usage: python docker/unlimited/replay.py /path/to/trial-directory
Then: node <trial>/extract.cjs <trial>/unlimited-adapted-*.json
"""
import argparse
import json
from pathlib import Path
from adapter import adapt

if __name__ == '__main__':
    args = argparse.ArgumentParser()
    args.add_argument('directory', type=Path)
    directory = args.parse_args().directory
    sources = sorted(directory.glob('unlimited-page*/result.md'))
    for source in sources:
        page = int(source.parent.name.removeprefix('unlimited-page'))
        output = adapt(source.read_text())
        (directory / f'unlimited-adapted-{page}.json').write_text(json.dumps(output))
    print(f'Adapted {len(sources)} pages; source content was not logged.')
