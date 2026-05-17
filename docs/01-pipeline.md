# 01 · La pipeline end-to-end

Dal video MP4 al file EPUB validato in 10 passaggi.

```
┌─────────────────┐
│  videos/*.mp4   │  Input: video tutorial registrati
└────────┬────────┘
         │ (1) Whisper / TechSmith Audiate
         ▼
┌─────────────────┐
│ transcripts/    │  Trascrizioni grezze (.txt, una per video)
│   *.txt         │
└────────┬────────┘
         │ (2) Claude Code: pulizia + struttura
         ▼
┌─────────────────┐
│ articles/       │  Articoli Markdown puliti (1 per video)
│   PE-XX.md      │
└────────┬────────┘
         │ (3) Mapping articoli → capitoli (manuale)
         ▼
┌─────────────────┐
│ book/           │  Bootstrap del libro
│   manuscript/   │
└────────┬────────┘
         │ (4) Claude Code subagents: scrittura capitoli
         ▼
┌─────────────────┐
│ manuscript/     │  Capitoli completi con placeholder figure
│   parte-*/*.md  │
└────────┬────────┘
         │ (5) ffmpeg: estrazione frame dai video
         │ (6) Visual review + selezione
         ▼
┌─────────────────┐
│ figures/        │  Screenshot finali in cap-NN/
│   cap-XX/*.png  │
└────────┬────────┘
         │ (7) Claude Code: sostituzione placeholder con image refs
         ▼
┌─────────────────┐
│ build/          │  Pandoc → EPUB + DOCX
│  manuscript.epub│
│  manuscript.docx│
└────────┬────────┘
         │ (8) epubcheck: validazione
         │ (9) Kindle Previewer: QA visiva
         │ (10) Word: impagina DOCX → PDF print-ready
         ▼
┌─────────────────┐
│ Amazon KDP      │  Upload eBook + paperback
└─────────────────┘
```

---

## 1. Trascrizione

Due opzioni:

**Opzione A — TechSmith Audiate** ($199 una tantum)

Audiate trascrive con qualità professionale ed è integrato in Camtasia. La trascrizione è leggibile e già divisa in frasi. Ideale se hai già la suite TechSmith.

**Opzione B — Whisper (gratuito, open source)**

OpenAI Whisper è gratis, gira localmente o su API:

```bash
# Localmente (gratis ma richiede CPU/GPU)
pip install -U openai-whisper
whisper videos/lezione-01.mp4 --model medium --language Italian --output_dir transcripts/

# Via API (a pagamento ma più veloce)
curl https://api.openai.com/v1/audio/transcriptions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F file=@videos/lezione-01.mp4 \
  -F model=whisper-1 \
  -F language=it
```

Lo script `scripts/transcribe-batch.sh` automatizza Whisper su una cartella di video.

**Qualità tipica** (italiano tecnico, audio pulito):
- Audiate: ~95% accurato, frasi ben spezzate
- Whisper `large-v3`: ~92% accurato, qualche errore su gergo tecnico
- Whisper `medium`: ~88% accurato, OK per first draft

---

## 2. Trascrizione → Articolo

Le trascrizioni grezze sono parlato ("ehm... diciamo che... allora..."). Vanno trasformate in articoli leggibili. Usa Claude Code con il prompt `templates/prompts/transcript-to-article.md`:

```bash
cd ~/my-book
claude
# > "Leggi transcripts/lezione-01.txt. Trasforma in articolo Markdown in articles/PE-01-intro.md
#    seguendo le regole in /Users/hidranarias/book-from-tutorials/templates/prompts/transcript-to-article.md.
#    Mantieni il tono autoriale, rimuovi disfluenze, struttura in sezioni H2."
```

Tempo: ~5 minuti per articolo da 10 minuti di video. Costo Claude: ~$0.05 con Sonnet.

Output tipico: ~1000-2000 parole per articolo da 10-15 minuti video.

---

## 3. Mapping articoli → capitoli

Decisione editoriale umana. Dato un set di N articoli:

1. Crea un file `CHAPTER-MAPPING.csv` con colonne: `articolo, parole, parte_libro, capitolo_libro, ordine, tipo`
2. Raggruppa per tema
3. Stima la lunghezza per capitolo: alcuni capitoli hanno 1 articolo, altri 3-5
4. Verifica equilibrio: cap. intro ~10-14 pagine, standard ~14-20, cuore libro 28-36

Esempio reale (dal libro originale):

| Cap. | Titolo | Articoli | Parole sorgente | Pagine target |
|---|---|---|---|---|
| 1 | Cos'è Claude Code | PE-01 | 1385 | 11-14 |
| 2 | Primi prompt utili | PE-02 (parte 1) | ~600 | 14-20 |
| 11 | Photogallery spec | WS-14+15+16+17 | 7151 | 28-36 |

Vedi `docs/02-writing-with-claude.md` per come gestire articoli "sottili" (espansione ex-novo).

---

## 4. Scrittura capitoli

Pattern: **subagent-driven development**.

Dispatcha 4 subagent in parallelo (4 capitoli per wave). Ogni subagent:
- Legge gli articoli sorgente
- Scrive il capitolo seguendo l'anatomia standard (opener / intro / body / recap / esercizio / teaser)
- NON committa (l'orchestratore committa in batch)

Vedi `docs/02-writing-with-claude.md` per dettagli + prompt template.

Tempo: ~3-5 minuti per capitolo (in parallelo), ~10 minuti per orchestrazione di un wave.

Cost: ~$2-5 per wave di 4 capitoli (Sonnet).

---

## 5-6. Screenshot

Per ogni capitolo: 2-4 screenshot estratti dal video corrispondente.

```bash
# Estrai frame candidati evenly-spaced
./scripts/extract-frames.sh videos/lezione-01.mp4 figures/raw/cap-01 00:01:30 00:05:00 00:09:30 00:13:30

# Apri i PNG, scegli i migliori, rinomina e sposta
mv figures/raw/cap-01/frame_001.png figures/cap-01/fig-01-welcome-screen.png
mv figures/raw/cap-01/frame_003.png figures/cap-01/fig-02-help-menu.png

# Cleanup
rm -rf figures/raw/cap-01
```

Per capitoli senza video disponibile: usa ASCII art (vedi `docs/03-screenshots.md` § ASCII).

---

## 7. Apply image refs nei capitoli

I capitoli scritti hanno placeholder `<!-- FIGURE: descrizione -->`. Sostituiscili con vere image refs:

```markdown
<!-- prima -->
<!-- FIGURE: terminale Claude appena avviato -->

<!-- dopo -->
![Terminale Claude appena avviato con welcome banner.](figures/cap-01/fig-01-welcome-screen.png){#fig:1-1 width=100%}

*Figura 1.1: la schermata iniziale mostra modello attivo, utente loggato, e progetto corrente.*
```

Per fare batch su tutti i capitoli, dispatcha un subagent (vedi `templates/prompts/apply-figures.md` se esistente, o adatta).

---

## 8. Build

```bash
./scripts/build-epub.sh        # → build/manuscript.epub
./scripts/validate.sh          # epubcheck — deve mostrare 0 errors / 0 warnings
./scripts/build-paperback.sh   # → build/manuscript.docx
```

Vedi `docs/04-build-and-publish.md` per dettagli pandoc.

---

## 9. QA Kindle Previewer

Manuale (~15 min):
1. Apri Kindle Previewer 3
2. Open `build/manuscript.epub`
3. Cambia "Device" tra Paperwhite (e-ink), Fire HD (LCD colori), iOS App
4. Verifica TOC, figure, callout box, codice
5. Annota problemi e itera fix

---

## 10. Paperback Word + KDP

DOCX → Word per impagination a 6×9":
- Margini gutter 0.75", esterno 0.5"
- Headers (numero pagina + cap)
- Export PDF print-ready

KDP upload: vedi `docs/04-build-and-publish.md` § KDP.

---

## Stima di costo totale

Per un libro da ~100k parole, 40 video sorgente, IT + EN:

| Voce | Costo |
|---|---|
| TechSmith Audiate (una tantum) | $199 oppure $0 (Whisper) |
| Claude Code subscription / API | $20-40 (mese di lavoro) |
| Affinity Publisher (copertina, una tantum) | $69 oppure $13/mese Canva Pro |
| KDP eBook + paperback upload | $0 |
| ISBN (KDP free) | $0 |
| **TOTALE iniziale** | **$0 - $400** |

ROI tipico: 50-150 copie/mese a $9.99 = $300-1000/mese di royalty.
