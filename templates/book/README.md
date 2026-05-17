# [Titolo libro] — Manuscript

Cartella di lavoro per il libro Kindle prodotto con [book-from-tutorials](https://github.com/hidran/book-from-tutorials).

## Build

```bash
./scripts/build-epub.sh        # EPUB (Kindle)
./scripts/build-paperback.sh   # DOCX (paperback, da impaginare in Word)
./scripts/validate.sh          # epubcheck
```

## Struttura

- `videos/` — video sorgente .mp4
- `transcripts/` — trascrizioni .txt (output di Whisper / Audiate)
- `articles/` — articoli .md (uno per video, leggibili come blog post)
- `manuscript/` — sorgenti markdown del libro
  - `00-front-matter/` — copertina, frontespizio, copyright, prefazione, come leggere
  - `parte-N/cap-NN.md` — capitoli
  - `zz-back-matter/` — appendici
- `figures/cap-NN/` — screenshot finali (PNG)
- `styles/` — CSS Kindle + metadata YAML pandoc
- `scripts/` — pipeline scripts (extract-frames, build-epub, build-paperback, validate)
- `build/` — output EPUB + DOCX (gitignored)

## Workflow

1. Metti i video in `videos/`
2. Trascrivi: `./scripts/transcribe-batch.sh videos/ transcripts/`
3. Genera articoli con Claude Code (vedi prompt template)
4. Mappa articoli → capitoli (decisione editoriale)
5. Scrivi capitoli con subagent paralleli
6. Estrai screenshot: `./scripts/extract-frames.sh videos/X.mp4 figures/raw/cap-NN 00:01:30 ...`
7. Inserisci `![Caption](figures/cap-NN/...)` nei capitoli
8. Build + validate
9. Upload KDP

Vedi documentazione completa: https://github.com/hidran/book-from-tutorials
