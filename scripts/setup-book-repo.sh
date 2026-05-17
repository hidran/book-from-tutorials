#!/usr/bin/env bash
# Bootstrap a new book from the templates.
#
# Usage:
#   ./setup-book-repo.sh <book-path> <title> <author> <language>
#
# Example:
#   ./setup-book-repo.sh ~/my-tech-book "My tech book" "Mario Rossi" it-IT
#
# Creates the book/ structure, copies scripts, scaffolds initial files,
# initializes git (Dropbox-safe via xattr if on macOS).

set -euo pipefail

if [[ $# -lt 4 ]]; then
  echo "Usage: $0 <book-path> <title> <author> <language>" >&2
  echo "Example: $0 ~/my-book 'My book' 'Hidran Arias' it-IT" >&2
  exit 1
fi

BOOK_PATH="$1"
BOOK_TITLE="$2"
BOOK_AUTHOR="$3"
BOOK_LANGUAGE="$4"

TOOLKIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "→ Creating book at: $BOOK_PATH"
echo "  Title:    $BOOK_TITLE"
echo "  Author:   $BOOK_AUTHOR"
echo "  Language: $BOOK_LANGUAGE"
echo ""

if [[ -d "$BOOK_PATH" ]]; then
  echo "ERROR: $BOOK_PATH already exists. Choose a different path." >&2
  exit 1
fi

# 1. Copy template structure
mkdir -p "$BOOK_PATH"
cp -R "$TOOLKIT_DIR/templates/book/." "$BOOK_PATH/"

# 2. Create remaining directories
mkdir -p "$BOOK_PATH"/{videos,transcripts,articles,figures,build}

# 3. Copy scripts from toolkit (not symlink — book is portable)
mkdir -p "$BOOK_PATH/scripts"
cp "$TOOLKIT_DIR/scripts/"*.sh "$BOOK_PATH/scripts/"
chmod +x "$BOOK_PATH/scripts/"*.sh

# 4. Customize metadata.yaml
METADATA="$BOOK_PATH/styles/metadata.yaml"
if [[ -f "$BOOK_PATH/styles/metadata.yaml.template" ]]; then
  mv "$BOOK_PATH/styles/metadata.yaml.template" "$METADATA"
fi
sed -i.bak \
  -e "s|^title:.*|title: \"$BOOK_TITLE\"|" \
  -e "s|^author:.*|author: \"$BOOK_AUTHOR\"|" \
  -e "s|^language:.*|language: $BOOK_LANGUAGE|" \
  "$METADATA"
rm -f "$METADATA.bak"

# 5. Git init (Dropbox-safe)
cd "$BOOK_PATH"
git init -q
git config user.name "$BOOK_AUTHOR"
git config user.email "your-email@example.com"

if [[ "$OSTYPE" == darwin* ]] && [[ "$BOOK_PATH" == *Dropbox* ]]; then
  echo "→ Detected Dropbox path on macOS — setting xattr to exclude .git from sync"
  xattr -w com.dropbox.ignored 1 .git
fi

# 6. Initial commit
git add .
git commit -q -m "chore: bootstrap book from template"

# 7. Recap
echo ""
echo "✓ Book scaffold ready at: $BOOK_PATH"
echo ""
echo "Next steps:"
echo "  1. cd $BOOK_PATH"
echo "  2. Put your video tutorials in videos/"
echo "  3. Transcribe: ./scripts/transcribe-batch.sh videos/ transcripts/"
echo "  4. Generate articles with Claude Code (see toolkit docs/02-writing-with-claude.md)"
echo "  5. Write chapters with Claude Code subagents"
echo "  6. Build EPUB: ./scripts/build-epub.sh && ./scripts/validate.sh"
echo ""
echo "Toolkit reference: $TOOLKIT_DIR/README.md"
