#!/usr/bin/env bash
# Valida l'EPUB con epubcheck (richiesto da Amazon KDP).

set -euo pipefail

BOOK_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$BOOK_DIR"

EPUB="build/manuscript.epub"

if [[ ! -f "$EPUB" ]]; then
  echo "ERROR: $EPUB non esiste. Esegui prima ./scripts/build-epub.sh" >&2
  exit 1
fi

echo "Validating $EPUB con epubcheck..."
echo ""

if epubcheck "$EPUB"; then
  echo ""
  echo "✓ EPUB valido — pronto per upload KDP"
else
  echo ""
  echo "✗ EPUB ha errori — vedere output sopra"
  exit 1
fi
