#!/bin/sh
# Railway/Render entrypoint: download model checkpoints if missing,
# then start uvicorn on the platform-provided $PORT.
set -e

MODELS_DIR="/code/app/models_data"
BASE_URL="${MODEL_BASE_URL:-}"

need="damaged_sign_detection/yolov26_1_class.pt damaged_sign_detection/EffnetV2_multilabel.pth damaged_sign_detection/traffic_signs_3.index damaged_sign_detection/traffic_signs_metadata_3.json rubbish_detection/stage1_best.pt rubbish_detection/stage2_best.pt"

missing=0
for f in $need; do
  if [ ! -f "$MODELS_DIR/$f" ]; then
    missing=1
    echo "missing: $f"
  fi
done

if [ "$missing" = "1" ]; then
  if [ -z "$BASE_URL" ]; then
    echo "ERROR: model files missing under $MODELS_DIR and \$MODEL_BASE_URL is not set."
    echo "Upload the 6 files to a Railway volume mounted at /code/app/models_data,"
    echo "or set MODEL_BASE_URL to a direct-download base URL containing them."
    exit 1
  fi
  echo "downloading models from $BASE_URL ..."
  for f in $need; do
    mkdir -p "$MODELS_DIR/$(dirname "$f")"
    curl -fL "$BASE_URL/$f" -o "$MODELS_DIR/$f"
  done
fi

echo "models OK, starting API on port ${PORT:-8000}"
exec uvicorn app.main:app --host 0.0.0.0 --port "${PORT:-8000}"
