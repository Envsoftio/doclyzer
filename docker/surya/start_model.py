"""Download the benchmarked model revision, then exec the local model server."""
import os
from huggingface_hub import hf_hub_download

repo = 'datalab-to/surya-ocr-2-gguf'
revision = '6a3a4c30e5e74446d4f8b6afd05b2f2da970f470'
model = hf_hub_download(repo, 'surya-2.gguf', revision=revision)
projector = hf_hub_download(repo, 'surya-2-mmproj.gguf', revision=revision)
os.execvp('llama-server', ['llama-server', '-m', model, '--mmproj', projector,
    '--host', os.getenv('SURYA_MODEL_HOST', '127.0.0.1'), '--port', '8080', '--parallel', '1', '--ctx-size', '32768',
    '--threads', os.getenv('SURYA_MODEL_THREADS', '4'),
    '--threads-batch', os.getenv('SURYA_MODEL_THREADS', '4'),
    '--alias', 'datalab-to/surya-ocr-2', '--jinja'])
