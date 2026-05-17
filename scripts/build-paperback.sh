#!/usr/bin/env bash
# Build DOCX del manuscript per impaginazione paperback in Word/LibreOffice.

set -euo pipefail

BOOK_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$BOOK_DIR"

PANDOC="/opt/homebrew/bin/pandoc"

mkdir -p build

MD_FILES=$(find manuscript -name "*.md" | sort)

if [[ -z "$MD_FILES" ]]; then
  echo "ERROR: nessun file .md trovato in manuscript/" >&2
  exit 1
fi

echo "File inclusi nella build:"
echo "$MD_FILES" | sed 's/^/  /'
echo ""

REFERENCE_DOC=""
if [[ -f styles/paperback.docx ]]; then
  REFERENCE_DOC="--reference-doc=styles/paperback.docx"
fi

"$PANDOC" \
  --metadata-file=styles/metadata.yaml \
  --toc --toc-depth=2 \
  --resource-path=.:manuscript:figures \
  $REFERENCE_DOC \
  -o build/manuscript.docx \
  $MD_FILES

echo ""
echo "✓ Build completata: build/manuscript.docx"
echo ""
echo "Prossimi step manuali:"
echo "  1. Apri build/manuscript.docx in Word (o LibreOffice)"
echo "  2. Imposta dimensione pagina: 6\" x 9\" (15.24cm x 22.86cm)"
echo "  3. Margini: 0.75\" interno (gutter), 0.5\" esterno/sopra/sotto"
echo "  4. Aggiungi headers (numero pagina + nome capitolo)"
echo "  5. Esporta come PDF print-ready → build/manuscript-print.pdf"
ls -lh build/manuscript.docx
