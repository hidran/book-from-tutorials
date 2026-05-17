#!/usr/bin/env bash
# Estrae uno o più frame da un video MP4 a timestamp specifici.
#
# Uso:
#   ./extract-frames.sh <video.mp4> <output_dir> <timestamp1> [timestamp2 ...]
#
# Esempio:
#   ./extract-frames.sh "../../claude code intro.mp4" ../figures/raw/cap-01 \
#       00:01:23 00:03:45 00:05:10
#
# Genera frame_001.png, frame_002.png, ecc. in <output_dir>.
# Risoluzione preservata dal sorgente. Qualità massima (-q:v 2).

set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Uso: $0 <video.mp4> <output_dir> <timestamp1> [timestamp2 ...]" >&2
  echo "Timestamp formato: HH:MM:SS (es. 00:01:23)" >&2
  exit 1
fi

VIDEO="$1"
OUTDIR="$2"
shift 2

if [[ ! -f "$VIDEO" ]]; then
  echo "ERROR: video non trovato: $VIDEO" >&2
  exit 1
fi

mkdir -p "$OUTDIR"

idx=1
for ts in "$@"; do
  out_file=$(printf "%s/frame_%03d.png" "$OUTDIR" "$idx")
  echo "Estraendo $ts -> $out_file"
  ffmpeg -ss "$ts" -i "$VIDEO" -frames:v 1 -q:v 2 -y "$out_file" 2>&1 | tail -2
  idx=$((idx + 1))
done

echo ""
echo "Estratti $((idx - 1)) frame in $OUTDIR"
ls -la "$OUTDIR"
