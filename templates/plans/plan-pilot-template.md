# Plan template: Pilot Pipeline (Plan 1)

Template of the first execution plan: book bootstrap + end-to-end pilot chapter. Adapt it to your book.

---

## Plan objective

Validate the pipeline (markdown → validated EPUB) by producing ONE complete pilot chapter.

Estimated time: **~10-12h**.

Output:
- `book/` with complete structure
- 1 chapter (Ch. 1) written with 4 figures
- EPUB validated by `epubcheck`
- DOCX paperback first draft
- Visual QA on Kindle Previewer 3

---

## Task

### Task 1 — Bootstrap the `book/` structure (30 min)
- Create folders `manuscript/{00-front-matter, part-1, ..., zz-back-matter}`, `figures/`, `styles/`, `scripts/`, `build/`
- `.gitignore` (exclude `build/`, `figures/raw/`, `node_modules/`)
- `README.md` (skeleton)
- `git init` (Dropbox-safe if applicable: `xattr -w com.dropbox.ignored 1 .git`)
- Commit: `chore: bootstrap book directory structure`

### Task 2 — Toolchain (15 min)
- Verify/install: pandoc 3.x, ffmpeg, epubcheck
- Manual: install Kindle Previewer 3 from Amazon
- Document versions in `scripts/TOOLCHAIN.md`
- Commit: `docs: document required toolchain versions`

### Task 3-6 — Pipeline scripts (1h)
- `scripts/extract-frames.sh` (ffmpeg wrapper)
- `scripts/build-epub.sh` (pandoc → EPUB3)
- `scripts/build-paperback.sh` (pandoc → DOCX)
- `scripts/validate.sh` (epubcheck wrapper)
- `chmod +x` on all of them
- Commit for each: `feat: add <script>`

### Task 7 — Styles (45 min)
- `styles/kindle.css` with callout, code blocks, figure, headings
- `styles/metadata.yaml` with title, author, language, keywords
- Commit: `feat: add Kindle EPUB stylesheet and metadata`

### Task 8 — Front matter skeleton (30 min)
- 5 files in `00-front-matter/`: cover, title page, copyright, preface stub, how-to-read stub
- Commit: `feat: add front matter skeleton`

### Task 9 — Scaffold Chapter 1 (30 min)
- `part-1/cap-01.md` with anatomy: opener / intro / numbered sections (placeholder `<<<...>>>`) / recap / exercise / teaser
- Commit: `feat(cap-01): scaffold chapter 1`

### Task 10 — Populate Chapter 1 from article (1h)
- Sub-task for Claude: read `articles/PE-01.md`, replace placeholders with adapted content
- Word count target: 3500-5500 (intro chapter)
- Commit: `feat(cap-01): populate chapter body from PE-01`

### Task 11 — Extract 4 screenshots (1h)
- Identify timestamps in source video (manual)
- `./scripts/extract-frames.sh videos/cap-01.mp4 figures/raw/cap-01 <ts1> <ts2> <ts3> <ts4>`
- Review candidates, select the best ones
- Promote to `figures/cap-01/fig-NN-name.png`
- Insert `![Caption](figures/cap-01/...)` in markdown
- Commit: `feat(cap-01): add 4 screenshots`

### Task 12 — Build EPUB + validate (15 min)
- `./scripts/build-epub.sh`
- `./scripts/validate.sh` → must show 0 errors / 0 warnings
- If errors: fix + re-build (fast cycles)
- Commit: `build(cap-01): pilot EPUB build validated`

### Task 13 — Build DOCX paperback (10 min)
- `./scripts/build-paperback.sh`
- Open `build/manuscript.docx` in Word for smoke test (NO final layout)
- Commit: `build(cap-01): pilot DOCX paperback build`

### Task 14 — QA on Kindle Previewer (manual, 15 min)
- Open EPUB in Kindle Previewer 3
- Test on 3 devices: Paperwhite (e-ink), Fire HD (LCD), iOS App
- Note any visual issues
- Commit (if fixes needed): `fix(cap-01): apply Kindle Previewer QA findings`

### Task 15 — Retrospective (15 min)
- Write `PILOT-RETROSPECTIVE.md` with:
  - Actual time vs estimated
  - What worked well
  - What was difficult
  - Adjustments for subsequent plans
- Commit: `docs: capture pilot retrospective`

---

## Plan 1 completion criteria

- [ ] Valid EPUB from `epubcheck` (0 errors, 0 warnings)
- [ ] DOCX opens correctly in Word
- [ ] Kindle Previewer QA passed on 3 simulated devices
- [ ] Chapter 1 has complete anatomy (opener / intro / sections / recap / exercise / teaser)
- [ ] 4 screenshots inserted with captions
- [ ] Retrospective written with real data

---

## Next plans (after pilot)

- **Plan 2**: chapters 2-9 (Parts I-III) — 4 waves of parallel subagents
- **Plan 3**: chapters 10-16 (Parts IV-V, core of book) — 4 waves
- **Plan 4**: complete front matter + 5 appendices
- **Plan 5**: final build + cover + KDP handoff

Total estimate for 5 plans: ~80h.
