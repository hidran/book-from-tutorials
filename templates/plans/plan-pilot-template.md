# Plan template: Pilot Pipeline (Plan 1)

Template del primo piano di esecuzione: bootstrap del libro + capitolo pilota end-to-end. Adattalo al tuo libro.

---

## Obiettivo del piano

Validare la pipeline (markdown → EPUB validato) producendo UN capitolo pilota completo.

Tempo stimato: **~10-12h**.

Output:
- `book/` con struttura completa
- 1 capitolo (Cap. 1) scritto e con 4 figure
- EPUB validato da `epubcheck`
- DOCX paperback first draft
- QA visiva su Kindle Previewer 3

---

## Task

### Task 1 — Bootstrap struttura `book/` (30 min)
- Crea cartelle `manuscript/{00-front-matter, parte-1, ..., zz-back-matter}`, `figures/`, `styles/`, `scripts/`, `build/`
- `.gitignore` (exclude `build/`, `figures/raw/`, `node_modules/`)
- `README.md` (skeleton)
- `git init` (Dropbox-safe se applicabile: `xattr -w com.dropbox.ignored 1 .git`)
- Commit: `chore: bootstrap book directory structure`

### Task 2 — Toolchain (15 min)
- Verifica/installa: pandoc 3.x, ffmpeg, epubcheck
- Manual: installa Kindle Previewer 3 da Amazon
- Documenta versioni in `scripts/TOOLCHAIN.md`
- Commit: `docs: document required toolchain versions`

### Task 3-6 — Scripts pipeline (1h)
- `scripts/extract-frames.sh` (ffmpeg wrapper)
- `scripts/build-epub.sh` (pandoc → EPUB3)
- `scripts/build-paperback.sh` (pandoc → DOCX)
- `scripts/validate.sh` (epubcheck wrapper)
- `chmod +x` su tutti
- Commit per ognuno: `feat: add <script>`

### Task 7 — Stili (45 min)
- `styles/kindle.css` con callout, code blocks, figure, headings
- `styles/metadata.yaml` con title, author, language, keywords
- Commit: `feat: add Kindle EPUB stylesheet and metadata`

### Task 8 — Front matter skeleton (30 min)
- 5 file in `00-front-matter/`: copertina, frontespizio, copyright, prefazione stub, come-leggere stub
- Commit: `feat: add front matter skeleton`

### Task 9 — Scaffold Capitolo 1 (30 min)
- `parte-1/cap-01.md` con anatomia: opener / intro / sezioni numerate (placeholder `<<<...>>>`) / recap / esercizio / teaser
- Commit: `feat(cap-01): scaffold chapter 1`

### Task 10 — Popolare Cap. 1 da articolo (1h)
- Sub-task per Claude: leggi `articles/PE-01.md`, sostituisci placeholder con contenuto adattato
- Word count target: 3500-5500 (intro chapter)
- Commit: `feat(cap-01): populate chapter body from PE-01`

### Task 11 — Estrarre 4 screenshot (1h)
- Identifica timestamp nel video sorgente (manual)
- `./scripts/extract-frames.sh videos/cap-01.mp4 figures/raw/cap-01 <ts1> <ts2> <ts3> <ts4>`
- Visualizza candidati, seleziona migliori
- Promuovi a `figures/cap-01/fig-NN-nome.png`
- Inserisci `![Caption](figures/cap-01/...)` nel markdown
- Commit: `feat(cap-01): add 4 screenshots`

### Task 12 — Build EPUB + validate (15 min)
- `./scripts/build-epub.sh`
- `./scripts/validate.sh` → deve mostrare 0 errors / 0 warnings
- Se errori: fix + re-build (cicli rapidi)
- Commit: `build(cap-01): pilot EPUB build validated`

### Task 13 — Build DOCX paperback (10 min)
- `./scripts/build-paperback.sh`
- Apri `build/manuscript.docx` in Word per smoke test (NO impagination finale)
- Commit: `build(cap-01): pilot DOCX paperback build`

### Task 14 — QA Kindle Previewer (manual, 15 min)
- Apri EPUB in Kindle Previewer 3
- Test su 3 dispositivi: Paperwhite (e-ink), Fire HD (LCD), iOS App
- Annota problemi visuali
- Commit (se servono fix): `fix(cap-01): apply Kindle Previewer QA findings`

### Task 15 — Retrospettiva (15 min)
- Scrivi `PILOT-RETROSPECTIVE.md` con:
  - Tempo effettivo vs stimato
  - Cosa ha funzionato bene
  - Cosa è stato difficile
  - Aggiustamenti per i piani successivi
- Commit: `docs: capture pilot retrospective`

---

## Criteri di "done" del Plan 1

- [ ] EPUB valido `epubcheck` (0 errors, 0 warnings)
- [ ] DOCX si apre correttamente in Word
- [ ] QA Kindle Previewer passato su 3 dispositivi simulati
- [ ] Capitolo 1 ha anatomia completa (opener / intro / sezioni / recap / esercizio / teaser)
- [ ] 4 screenshot inseriti con caption
- [ ] Retrospettiva scritta con dati reali

---

## Prossimi piani (dopo pilota)

- **Plan 2**: capitoli 2-9 (Parti I-III) — 4 wave di subagent paralleli
- **Plan 3**: capitoli 10-16 (Parti IV-V, cuore libro) — 4 wave
- **Plan 4**: front matter completo + 5 appendici
- **Plan 5**: build finale + copertina + KDP handoff

Stima totale 5 piani: ~80h.
