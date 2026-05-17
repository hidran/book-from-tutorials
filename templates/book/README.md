# [Book title] — Manuscript

Working folder for the Kindle book produced with [book-from-tutorials](https://github.com/hidran/book-from-tutorials).

## Build

```bash
./scripts/build-epub.sh        # EPUB (Kindle)
./scripts/build-paperback.sh   # DOCX (paperback, to be typeset in Word)
./scripts/validate.sh          # epubcheck
```

## Structure

- `videos/` — source video files .mp4
- `transcripts/` — transcripts .txt (output from Whisper / Audiate)
- `articles/` — articles .md (one per video, readable as blog posts)
- `manuscript/` — markdown source files for the book
  - `00-front-matter/` — cover, title page, copyright, preface, how to read
  - `parte-N/cap-NN.md` — chapters
  - `zz-back-matter/` — appendices
- `figures/cap-NN/` — final screenshots (PNG)
- `styles/` — Kindle CSS + pandoc YAML metadata
- `scripts/` — pipeline scripts (extract-frames, build-epub, build-paperback, validate)
- `build/` — EPUB + DOCX output (gitignored)

## Workflow

1. Place videos in `videos/`
2. Transcribe: `./scripts/transcribe-batch.sh videos/ transcripts/`
3. Generate articles with Claude Code (see prompt template)
4. Map articles → chapters (editorial decision)
5. Write chapters with parallel subagents
6. Extract screenshots: `./scripts/extract-frames.sh videos/X.mp4 figures/raw/cap-NN 00:01:30 ...`
7. Insert `![Caption](figures/cap-NN/...)` in chapters
8. Build + validate
9. Upload to KDP

See full documentation: https://github.com/hidran/book-from-tutorials
