FROM python:3.12-slim AS llama-build
RUN apt-get update && apt-get install -y --no-install-recommends git cmake build-essential libcurl4-openssl-dev && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/ggml-org/llama.cpp /llama && cd /llama && git checkout 620d2225c \
    && cmake -B build -DCMAKE_BUILD_TYPE=Release -DGGML_NATIVE=OFF -DGGML_OPENMP=OFF -DLLAMA_BUILD_TESTS=OFF -DLLAMA_BUILD_EXAMPLES=OFF \
    && cmake --build build --target llama-server -j2

FROM python:3.12-slim
RUN apt-get update && apt-get install -y --no-install-recommends libcurl4 libgomp1 libgl1 libglib2.0-0 && rm -rf /var/lib/apt/lists/*
COPY --from=llama-build /llama/build/bin/ /usr/local/lib/llama/
ENV PATH="/usr/local/lib/llama:${PATH}" LD_LIBRARY_PATH=/usr/local/lib/llama HF_HOME=/cache/huggingface HF_HUB_DISABLE_XET=1
WORKDIR /app
COPY docker/surya/requirements.txt .
RUN pip install --no-cache-dir torch==2.14.1+cpu torchvision==0.29.1+cpu --index-url https://download.pytorch.org/whl/cpu \
    && pip install --no-cache-dir -r requirements.txt
COPY docker/surya/*.py ./
RUN useradd --create-home worker && mkdir /cache && chown worker /cache
USER worker
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "5003", "--workers", "1", "--no-access-log"]
