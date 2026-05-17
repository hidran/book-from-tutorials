---
description: Bootstrap a new book project from this toolkit
argument-hint: <book-path> <title> <author> <language>
---

Bootstrap a new book project using `scripts/setup-book-repo.sh`.

## Steps

1. Parse the arguments: `$ARGUMENTS` should contain `<book-path> <title> <author> <language>`
2. If any argument is missing, ask the user for it
3. Verify the target directory does not already exist
4. Run `./scripts/setup-book-repo.sh <book-path> <title> <author> <language>`
5. Show the user the next steps (drop videos in `<book-path>/videos/`, run transcribe-batch, etc.)
6. Offer to `cd` into the new book directory and continue from there

## Notes

- Language codes: `en-US`, `it-IT`, `de-DE`, `es-ES`, `fr-FR`, etc.
- The script will:
  - Copy the `templates/book/` skeleton to the target path
  - Copy `scripts/*.sh` to `<path>/scripts/`
  - Substitute title/author/language in `styles/metadata.yaml`
  - Initialize git (Dropbox-safe via xattr on macOS)
  - Create initial commit

## After bootstrap

Suggest the user:
1. Place `.mp4` videos in `videos/`
2. Run `./scripts/transcribe-batch.sh videos/ transcripts/`
3. Use the `/write-chapter` command (or the `chapter-writer` agent) to draft chapters
4. Use `/build-book` to produce the EPUB

Reference: `docs/01-pipeline.md` for the full workflow.
