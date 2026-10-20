"""Private, CPU-only PaddleOCR-VL-1.6 feasibility run; no application writes."""
import json
import os
import sys
import time
from pathlib import Path


def cgroup_bytes(filename):
    try:
        value = Path('/sys/fs/cgroup', filename).read_text().strip()
        return int(value) if value != 'max' else None
    except (OSError, ValueError):
        return None


def write_private(path, data):
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, 'w') as handle:
        json.dump(data, handle, indent=2)


def main():
    if len(sys.argv) != 3:
        raise SystemExit('Usage: benchmark.py input.jpg private-output-directory')
    os.umask(0o077)
    source = Path(sys.argv[1])
    output = Path(sys.argv[2])
    if not source.is_file() or source.suffix.lower() not in {'.jpg', '.jpeg', '.png', '.pdf'}:
        raise SystemExit('Input must be an existing image or PDF')
    output.mkdir(mode=0o700, parents=True, exist_ok=True)

    from paddleocr import PaddleOCRVL
    import paddle
    import paddleocr

    started = time.monotonic()
    backend = os.environ.get('LAB_VL_BACKEND')
    server_url = os.environ.get('LAB_VL_SERVER_URL')
    if bool(backend) != bool(server_url):
        raise SystemExit('LAB_VL_BACKEND and LAB_VL_SERVER_URL must be set together')
    pipeline = PaddleOCRVL(
        pipeline_version='v1.6',
        device='cpu',
        cpu_threads=2,
        use_doc_orientation_classify=False,
        use_doc_unwarping=False,
        use_layout_detection=True,
        **({'vl_rec_backend': backend, 'vl_rec_server_url': server_url,
            'vl_rec_api_key': os.environ.get('LAB_VL_API_KEY')}
           if backend else {}),
    )
    initialized = time.monotonic()
    results = pipeline.predict(str(source))
    finished = time.monotonic()
    for result in results:
        result.save_to_json(save_path=str(output))
    write_private(output / 'metrics.json', {
        'model': 'PaddleOCR-VL-1.6',
        'recognition_backend': backend or 'paddle',
        'paddle_version': paddle.__version__,
        'paddleocr_version': paddleocr.__version__,
        'pages': len(results),
        'initialization_seconds': round(initialized - started, 3),
        'inference_seconds': round(finished - initialized, 3),
        'total_seconds': round(finished - started, 3),
        'cgroup_memory_peak_bytes': cgroup_bytes('memory.peak'),
        'cgroup_memory_limit_bytes': cgroup_bytes('memory.max'),
    })
    print(json.dumps({'pages': len(results), 'total_seconds': round(finished - started, 3),
                      'memory_peak_bytes': cgroup_bytes('memory.peak')}))


if __name__ == '__main__':
    main()
