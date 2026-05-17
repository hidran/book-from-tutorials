#!/usr/bin/env bash
# Batch transcription of MP4 videos to TXT transcripts using OpenAI Whisper.
#
# Usage:
#   ./transcribe-batch.sh <videos_dir> <transcripts_dir> [model] [language]
#
# Example:
#   ./transcribe-batch.sh videos/ transcripts/ medium Italian
#   ./transcribe-batch.sh videos/ transcripts/ large-v3 English
#
# Requirements:
#   pip install -U openai-whisper
#   (or use whisper-cpp / mlx-whisper / faster-whisper if you prefer)
#
# Skips already-transcribed videos (idempotent).

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <videos_dir> <transcripts_dir> [model=medium] [language=Italian]" >&2
  echo "" >&2
  echo "Models available (quality → speed):" >&2
  echo "  tiny   - fast, low quality (~1x realtime)" >&2
  echo "  base   - good compromise (~2x realtime)" >&2
  echo "  small  - medium quality (~3x realtime)" >&2
  echo "  medium - high quality (~5x realtime) ← default" >&2
  echo "  large-v3 - best quality (~10x realtime, requires GPU)" >&2
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
    echo "   ✓ Done — $words words in $txt_out"
    COUNT=$((COUNT + 1))
  else
    echo "   ✗ Failed — $txt_out not created" >&2
  fi
done

echo ""
echo "=== Summary ==="
echo "Transcribed: $COUNT"
echo "Skipped (already exist): $SKIPPED"
echo "Output in: $TRANSCRIPTS_DIR"
