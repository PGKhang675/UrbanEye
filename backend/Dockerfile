FROM python:3.10-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# System libs for opencv/faiss
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 libglib2.0-0 libgomp1 curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /code

COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# App + baked-in model checkpoints (~190MB in app/models_data/).
# NOTE: *.pt/*.index are gitignored, so hosted builds (Railway/Render)
# won't have them — entrypoint.sh downloads them from $MODEL_BASE_URL
# if missing. For local builds with the files present, COPY bakes them in.
COPY app ./app
COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

EXPOSE 8000

CMD ["./entrypoint.sh"]
