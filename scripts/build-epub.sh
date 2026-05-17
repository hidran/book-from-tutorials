#!/usr/bin/env bash
# Build EPUB3 del manuscript con pandoc.
#
# Concatena tutti i .md sotto manuscript/ in ordine alfabetico (00-front-matter/,
# parte-1/, parte-2/, ..., 99-back-matter/) e produce build/manuscript.epub.

set -euo pipefail

BOOK_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$BOOK_DIR"

PANDOC="/opt/homebrew/bin/pandoc"

mkdir -p build

# Trova tutti i .md sotto manuscript/ in ordine
MD_FILES=$(find manuscript -name "*.md" | sort)

if [[ -z "$MD_FILES" ]]; then
  echo "ERROR: nessun file .md trovato in manuscript/" >&2
  exit 1
fi

echo "File inclusi nella build:"
echo "$MD_FILES" | sed 's/^/  /'
echo ""

"$PANDOC" \
  --metadata-file=styles/metadata.yaml \
  --css=styles/kindle.css \
  --toc --toc-depth=2 \
  --split-level=1 \
  --resource-path=.:manuscript:figures \
  -o build/manuscript.epub \
  $MD_FILES

echo ""
echo "✓ Build completata: build/manuscript.epub"
ls -lh build/manuscript.epub
