# 📕 Book from Tutorials

**Trasforma una serie di video tutorial in un libro vendibile su Amazon Kindle** — pipeline completa: video → trascrizione → articoli → capitoli → EPUB + paperback → KDP.

Questo toolkit nasce dall'esperienza reale di pubblicare *Claude Code: la guida pratica* — un libro di ~98.000 parole, 16 capitoli, 5 appendici, edizioni IT + EN — partendo da 40 video Camtasia.

---

## 🎯 Cosa ottieni

Dato un set di video tutorial come input, alla fine del processo hai:

- **EPUB validato** (passa `epubcheck`, pronto per Kindle)
- **DOCX impaginabile** in Word per il paperback POD
- **Edizioni multilingua** (es. italiano + inglese) condividendo le stesse figure
- **Companion repos GitHub** mappati capitolo per capitolo
- **Metadati KDP completi** (titolo, sottotitolo, descrizione HTML, categorie, keyword) copia-incollabili nel form Amazon

Tempo realistico per un libro di ~400 pagine partendo da 40 video: **~80h di lavoro umano**, di cui ~30% gestione + 70% lavoro AI-assistito.

---

## 🧠 Filosofia: AI-assisted, human-directed

Il principio guida è **non delegare la comprensione** all'AI. L'AI scrive, organizza, traduce. Tu decidi:
- Cosa va in che capitolo
- Quando un capitolo è "abbastanza"
- Quali screenshot sono significativi
- Quale tono mantenere
- Cosa vendere e come

Il toolkit incarna questa divisione del lavoro: prompt strutturati, subagent dispatching, e checkpoint umani in punti chiave (selezione screenshot, QA su Kindle Previewer, scelta copertina).

---

## 🚀 Quick start

### Prerequisiti

```bash
# macOS via Homebrew
brew install pandoc ffmpeg epubcheck
brew install --cask kindle-previewer  # opzionale ma raccomandato

# Linux
sudo apt install pandoc ffmpeg
# epubcheck: https://github.com/w3c/epubcheck/releases
# Kindle Previewer: solo macOS/Windows
```

Hai bisogno anche di **Claude Code** installato (`npm install -g @anthropic-ai/claude-code`).

### Crea il tuo primo libro

```bash
# 1. Clona questo repo
git clone https://github.com/hidran/book-from-tutorials.git
cd book-from-tutorials

# 2. Bootstrap un nuovo libro nella tua cartella di lavoro
./scripts/setup-book-repo.sh ~/my-book "Il mio libro" "Hidran Arias" it-IT
cd ~/my-book

# 3. Metti i tuoi video .mp4 in videos/

# 4. Trascrivi (richiede Whisper o trascrizioni esistenti)
./scripts/transcribe-batch.sh videos/ transcripts/

# 5. Usa Claude Code per trasformare trascrizioni in articoli
# (segue il workflow in docs/02-writing-with-claude.md)
claude
# > "Leggi transcripts/lezione-01.txt e crealo come articolo Markdown in articles/PE-01-intro.md"

# 6. Usa Claude Code per scrivere i capitoli (vedi docs/02-writing-with-claude.md)

# 7. Estrai screenshot dai video
./scripts/extract-frames.sh videos/lezione-01.mp4 figures/raw/cap-01 00:01:30 00:05:00

# 8. Build EPUB + DOCX
./scripts/build-epub.sh
./scripts/build-paperback.sh
./scripts/validate.sh

# 9. Upload su KDP usando i metadata in AMAZON-LISTING.md
```

Tempo totale prima EPUB di prova: **~2 ore** se hai già trascrizioni + 1 video di esempio.

---

## 📚 Documentazione

| Doc | Contenuto |
|---|---|
| [docs/01-pipeline.md](docs/01-pipeline.md) | Pipeline tecnica: video → trascrizione → articolo → capitolo → EPUB |
| [docs/02-writing-with-claude.md](docs/02-writing-with-claude.md) | Pattern subagent-driven, anatomia capitolo, prompt riusabili |
| [docs/03-screenshots.md](docs/03-screenshots.md) | Workflow ffmpeg + selezione + sostituzione placeholder |
| [docs/04-build-and-publish.md](docs/04-build-and-publish.md) | Build pandoc, validazione epubcheck, impaginazione paperback Word |
| [docs/05-multi-edition.md](docs/05-multi-edition.md) | Edizioni IT + EN parallele con figure condivise via symlink |

---

## 📁 Struttura del repo

```
book-from-tutorials/
├── README.md                            ← sei qui
├── LICENSE                              ← MIT
├── docs/                                ← 5 guide approfondite del workflow
├── scripts/                             ← pipeline scripts
│   ├── setup-book-repo.sh               ← bootstrap nuovo libro
│   ├── transcribe-batch.sh              ← Whisper batch
│   ├── extract-frames.sh                ← ffmpeg screenshot
│   ├── build-epub.sh                    ← pandoc → EPUB3
│   ├── build-paperback.sh               ← pandoc → DOCX
│   └── validate.sh                      ← epubcheck wrapper
└── templates/
    ├── book/                            ← skeleton di un nuovo libro
    │   ├── .gitignore
    │   ├── README.md
    │   ├── manuscript/
    │   │   ├── 00-front-matter/         ← copertina, frontespizio, copyright, prefazione, come leggere
    │   │   ├── parte-1/cap-01.md        ← template capitolo
    │   │   └── zz-back-matter/          ← appendici (zz- per sort dopo parte-N)
    │   └── styles/
    │       ├── kindle.css               ← CSS per EPUB
    │       └── metadata.yaml.template   ← pandoc metadata
    ├── prompts/                         ← prompt templates per Claude Code
    │   ├── transcript-to-article.md
    │   ├── article-to-chapter.md
    │   ├── chapter-expansion.md
    │   └── translate-chapter.md
    └── plans/
        └── plan-pilot-template.md       ← template piano di esecuzione
```

---

## 🎓 Storia di origine

Questo toolkit è il distillato del workflow utilizzato per produrre **Claude Code: la guida pratica** (2026, ~390 pagine, IT + EN su KDP). Le scelte tecniche sono il frutto di iterazione reale, non di teoria:

- **Pandoc 3.x** invece di soluzioni custom (battle-tested per EPUB)
- **`zz-back-matter/`** invece di `99-back-matter/` (perché `9` < `p` in ASCII sort)
- **Symlink delle figure** tra edizioni (no duplicazione di MB di PNG)
- **Subagent in waves di 4** per scrivere capitoli in parallelo
- **HTML comment `<!-- FIGURE: ... -->`** come placeholder (no rotture pandoc)
- **Branch GitHub `book/cap-N-stage`** per snapshot didattici nei companion repo

---

## 🤝 Contributi

PR benvenute. Cose dove serve aiuto:

- [ ] Script per Windows (i `.sh` attuali sono Bash/zsh — porting PowerShell utile)
- [ ] Template per altre lingue (DE, FR, ES, PT)
- [ ] Variante con Marp/Quarto invece di pandoc per build alternative
- [ ] Esempi mini-book funzionanti (a partire da video pubblici Creative Commons)
- [ ] Integration tests della pipeline build

Apri una issue prima di lavori grossi per discutere.

---

## 📜 Licenza

MIT — riusa liberamente, attribuzione gradita.

---

## 🔗 Vedi anche

- 📖 **Claude Code: la guida pratica** (libro originale): https://www.amazon.it/dp/...
- 🎓 **Claude Code: The Practical Guide** (EN edition): https://www.amazon.com/dp/...
- 💬 **Discord community** (Claude Code Italia): link al lancio

---

**Aggiornato:** 2026-05-18 · Autore: Hidran Arias
