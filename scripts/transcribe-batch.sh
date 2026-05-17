#!/usr/bin/env bash
# Batch transcription dei video MP4 in trascrizioni TXT usando OpenAI Whisper.
#
# Uso:
#   ./transcribe-batch.sh <videos_dir> <transcripts_dir> [model] [language]
#
# Esempio:
#   ./transcribe-batch.sh videos/ transcripts/ medium Italian
#   ./transcribe-batch.sh videos/ transcripts/ large-v3 English
#
# Requisiti:
#   pip install -U openai-whisper
#   (oppure usa whisper-cpp / mlx-whisper / faster-whisper se preferisci)
#
# Salta video già trascritti (idempotente).

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Uso: $0 <videos_dir> <transcripts_dir> [model=medium] [language=Italian]" >&2
  echo "" >&2
  echo "Models disponibili (qualità → velocità):" >&2
  echo "  tiny   - veloce, bassa qualità (~1x realtime)" >&2
  echo "  base   - buon compromesso (~2x realtime)" >&2
  echo "  small  - qualità media (~3x realtime)" >&2
  echo "  medium - qualità alta (~5x realtime) ← default" >&2
  echo "  large-v3 - qualità migliore (~10x realtime, richiede GPU)" >&2
  exit 1
fi

VIDEOS_DIR="$1"
TRANSCRIPTS_DIR="$2"
MODEL="${3:-medium}"
LANGUAGE="${4:-Italian}"

if ! command -v whisper >/dev/null 2>&1; then
  echo "ERROR: whisper not installed. Install with:" >&2
  echo "  pip install -U openai-whisper" >&2
  exit 1
fi

if [[ ! -d "$VIDEOS_DIR" ]]; then
  echo "ERROR: videos directory not found: $VIDEOS_DIR" >&2
  exit 1
fi

mkdir -p "$TRANSCRIPTS_DIR"

COUNT=0
SKIPPED=0
for video in "$VIDEOS_DIR"/*.mp4 "$VIDEOS_DIR"/*.MP4 "$VIDEOS_DIR"/*.mov; do
  [[ -f "$video" ]] || continue

  name=$(basename "$video")
  name="${name%.*}"
  txt_out="$TRANSCRIPTS_DIR/${name}.txt"

  if [[ -f "$txt_out" ]]; then
    echo "⏭  Skipping (already transcribed): $name"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  echo "🎙  Transcribing: $name (model=$MODEL, lang=$LANGUAGE)..."
  whisper "$video" \
    --model "$MODEL" \
    --language "$LANGUAGE" \
    --output_dir "$TRANSCRIPTS_DIR" \
    --output_format txt \
    --verbose False \
    2>&1 | tail -3

  if [[ -f "$txt_out" ]]; then
    words=$(wc -w < "$txt_out" | xargs)
    echo "   ✓ Done — $words parole in $txt_out"
    COUNT=$((COUNT + 1))
  else
    echo "   ✗ Failed — $txt_out non creato" >&2
  fi
done

echo ""
echo "=== Summary ==="
echo "Trascritti: $COUNT"
echo "Saltati (già esistenti): $SKIPPED"
echo "Output in: $TRANSCRIPTS_DIR"
