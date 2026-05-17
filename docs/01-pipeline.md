# 01 · The End-to-End Pipeline

From MP4 video to validated EPUB in 10 steps.

```
┌─────────────────┐
│  videos/*.mp4   │  Input: recorded tutorial videos
└────────┬────────┘
         │ (1) Whisper / TechSmith Audiate
         ▼
┌─────────────────┐
│ transcripts/    │  Raw transcripts (.txt, one per video)
│   *.txt         │
└────────┬────────┘
         │ (2) Claude Code: cleanup + structure
         ▼
┌─────────────────┐
│ articles/       │  Clean Markdown articles (1 per video)
│   PE-XX.md      │
└────────┬────────┘
         │ (3) Mapping articles → chapters (manual)
         ▼
┌─────────────────┐
│ book/           │  Book bootstrap
│   manuscript/   │
└────────┬────────┘
         │ (4) Claude Code subagents: chapter writing
         ▼
┌─────────────────┐
│ manuscript/     │  Complete chapters with figure placeholders
│   parte-*/*.md  │
└────────┬────────┘
         │ (5) ffmpeg: frame extraction from videos
         │ (6) Visual review + selection
         ▼
┌─────────────────┐
│ figures/        │  Final screenshots in cap-NN/
│   cap-XX/*.png  │
└────────┬────────┘
         │ (7) Claude Code: replace placeholders with image refs
         ▼
┌─────────────────┐
│ build/          │  Pandoc → EPUB + DOCX
│  manuscript.epub│
│  manuscript.docx│
└────────┬────────┘
         │ (8) epubcheck: validation
         │ (9) Kindle Previewer: visual QA
         │ (10) Word: lay out DOCX → print-ready PDF
         ▼
┌─────────────────┐
│ Amazon KDP      │  Upload eBook + paperback
└─────────────────┘
```

---

## 1. Transcription

Two options:

**Option A — TechSmith Audiate** ($199 one-time)

Audiate transcribes at professional quality and integrates directly with Camtasia. The transcript is readable and already split into sentences. Ideal if you already own the TechSmith suite.

**Option B — Whisper (free, open source)**

OpenAI Whisper is free and runs locally or via API:

```bash
# Locally (free but requires CPU/GPU)
pip install -U openai-whisper
whisper videos/lezione-01.mp4 --model medium --language Italian --output_dir transcripts/

# Via API (paid but faster)
curl https://api.openai.com/v1/audio/transcriptions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F file=@videos/lezione-01.mp4 \
  -F model=whisper-1 \
  -F language=it
```

The `scripts/transcribe-batch.sh` script automates Whisper across a folder of videos.

**Typical quality** (technical Italian, clean audio):
- Audiate: ~95% accurate, sentences cleanly split
- Whisper `large-v3`: ~92% accurate, occasional errors on technical jargon
- Whisper `medium`: ~88% accurate, fine for a first draft

---

## 2. Transcript → Article

Raw transcripts are spoken language ("uh... let's say... so..."). You need to turn them into readable articles. Use Claude Code with the prompt at `templates/prompts/transcript-to-article.md`:

```bash
cd ~/my-book
claude
# > "Read transcripts/lezione-01.txt. Transform it into a Markdown article in articles/PE-01-intro.md
#    following the rules in /Users/hidranarias/book-from-tutorials/templates/prompts/transcript-to-article.md.
#    Keep the authorial tone, remove disfluencies, structure into H2 sections."
```

Time: ~5 minutes per article from a 10-minute video. Claude cost: ~$0.05 with Sonnet.

Typical output: ~1,000–2,000 words per article from a 10–15 minute video.

---

## 3. Mapping articles → chapters

A human editorial decision. Given a set of N articles:

1. Create a `CHAPTER-MAPPING.csv` file with columns: `article, words, book_part, book_chapter, order, type`
2. Group by topic
3. Estimate length per chapter: some chapters draw from 1 article, others from 3–5
4. Check balance: intro chapters ~10–14 pages, standard ~14–20, core chapters 28–36

Real example (from the original book):

| Ch. | Title | Articles | Source words | Target pages |
|---|---|---|---|---|
| 1 | What is Claude Code | PE-01 | 1,385 | 11–14 |
| 2 | First useful prompts | PE-02 (part 1) | ~600 | 14–20 |
| 11 | Photogallery spec | WS-14+15+16+17 | 7,151 | 28–36 |

See `docs/02-writing-with-claude.md` for how to handle "thin" articles (expanding from scratch).

---

## 4. Writing chapters

Pattern: **subagent-driven development**.

Dispatch 4 subagents in parallel (4 chapters per wave). Each subagent:
- Reads the source articles
- Writes the chapter following the standard anatomy (opener / intro / body / recap / exercise / teaser)
- Does NOT commit (the orchestrator commits in batch)

See `docs/02-writing-with-claude.md` for details + prompt template.

Time: ~3–5 minutes per chapter (in parallel), ~10 minutes to orchestrate a wave.

Cost: ~$2–5 per wave of 4 chapters (Sonnet).

---

## 5-6. Screenshots

For each chapter: 2–4 screenshots extracted from the corresponding video.

```bash
# Extract evenly-spaced candidate frames
./scripts/extract-frames.sh videos/lezione-01.mp4 figures/raw/cap-01 00:01:30 00:05:00 00:09:30 00:13:30

# Open the PNGs, pick the best ones, rename and move them
mv figures/raw/cap-01/frame_001.png figures/cap-01/fig-01-welcome-screen.png
mv figures/raw/cap-01/frame_003.png figures/cap-01/fig-02-help-menu.png

# Cleanup
rm -rf figures/raw/cap-01
```

For chapters without an available video: use ASCII art (see `docs/03-screenshots.md` § ASCII).

---

## 7. Apply image refs in chapters

Written chapters contain `<!-- FIGURE: description -->` placeholders. Replace them with real image refs:

```markdown
<!-- before -->
<!-- FIGURE: Claude terminal just launched -->

<!-- after -->
![Claude terminal just launched with welcome banner.](figures/cap-01/fig-01-welcome-screen.png){#fig:1-1 width=100%}

*Figure 1.1: the opening screen shows the active model, logged-in user, and current project.*
```

To batch this across all chapters, dispatch a subagent (see `templates/prompts/apply-figures.md` if it exists, or adapt accordingly).

---

## 8. Build

```bash
./scripts/build-epub.sh        # → build/manuscript.epub
./scripts/validate.sh          # epubcheck — should show 0 errors / 0 warnings
./scripts/build-paperback.sh   # → build/manuscript.docx
```

See `docs/04-build-and-publish.md` for pandoc details.

---

## 9. Kindle Previewer QA

Manual (~15 min):
1. Open Kindle Previewer 3
2. Open `build/manuscript.epub`
3. Switch "Device" between Paperwhite (e-ink), Fire HD (color LCD), and iOS App
4. Check the TOC, figures, callout boxes, and code blocks
5. Note any issues and iterate fixes

---

## 10. Paperback in Word + KDP

DOCX → Word for 6×9" layout:
- Gutter margin 0.75", outer 0.5"
- Headers (page number + chapter)
- Export print-ready PDF

KDP upload: see `docs/04-build-and-publish.md` § KDP.

---

## Total cost estimate

For a book of ~100k words, 40 source videos, Italian + English:

| Item | Cost |
|---|---|
| TechSmith Audiate (one-time) | $199 or $0 (Whisper) |
| Claude Code subscription / API | $20–40 (one month of work) |
| Affinity Publisher (cover, one-time) | $69 or $13/month Canva Pro |
| KDP eBook + paperback upload | $0 |
| ISBN (KDP free) | $0 |
| **Initial total** | **$0 – $400** |

Typical ROI: 50–150 copies/month at $9.99 = $300–$1,000/month in royalties.
