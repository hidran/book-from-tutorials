# 📕 Book from Tutorials

**Turn a series of video tutorials into a sellable Amazon Kindle book** — complete pipeline: videos → transcripts → articles → chapters → EPUB + paperback → KDP.

This toolkit is distilled from the real-world production of *Claude Code: The Practical Guide* — a ~98,000 word book, 16 chapters, 5 appendices, IT + EN editions — starting from 40 Camtasia videos.

---

## 🎯 What you get

Given a set of video tutorials as input, at the end of the process you have:

- **Validated EPUB** (passes `epubcheck`, ready for Kindle)
- **Layout-ready DOCX** for Word paperback POD
- **Multi-language editions** (e.g., Italian + English) sharing the same figures
- **GitHub companion repos** mapped chapter-by-chapter
- **Complete KDP metadata** (title, subtitle, HTML description, categories, keywords) copy-pasteable into the Amazon form

Realistic time for a ~400-page book starting from 40 videos: **~80 hours of human work**, of which ~30% coordination + 70% AI-assisted work.

---

## 🧠 Philosophy: AI-assisted, human-directed

The guiding principle is **do not delegate understanding** to AI. AI writes, organizes, translates. You decide:

- What goes in which chapter
- When a chapter is "enough"
- Which screenshots are meaningful
- What voice to maintain
- What to sell and how

The toolkit encodes this division of labor: structured prompts, subagent dispatching, and human checkpoints at key moments (screenshot selection, Kindle Previewer QA, cover design).

---

## 🚀 Quick start

### Prerequisites

```bash
# macOS via Homebrew
brew install pandoc ffmpeg epubcheck
brew install --cask kindle-previewer  # optional but recommended

# Linux
sudo apt install pandoc ffmpeg
# epubcheck: https://github.com/w3c/epubcheck/releases
# Kindle Previewer: macOS/Windows only
```

You also need **Claude Code** installed (`npm install -g @anthropic-ai/claude-code`).

### Create your first book

```bash
# 1. Clone this repo
git clone https://github.com/hidran/book-from-tutorials.git
cd book-from-tutorials

# 2. Bootstrap a new book in your working directory
./scripts/setup-book-repo.sh ~/my-book "My Book Title" "Your Name" en-US
cd ~/my-book

# 3. Drop your .mp4 videos in videos/

# 4. Transcribe (requires Whisper installed, or pre-existing transcripts)
./scripts/transcribe-batch.sh videos/ transcripts/

# 5. Use Claude Code to turn transcripts into articles
# (follow the workflow in docs/02-writing-with-claude.md)
claude
# > "Read transcripts/lesson-01.txt and write it as a Markdown article in articles/PE-01-intro.md"

# 6. Use Claude Code to write chapters (see docs/02-writing-with-claude.md)

# 7. Extract screenshots from the videos
./scripts/extract-frames.sh videos/lesson-01.mp4 figures/raw/cap-01 00:01:30 00:05:00

# 8. Build EPUB + DOCX
./scripts/build-epub.sh
./scripts/build-paperback.sh
./scripts/validate.sh

# 9. Upload to KDP using the metadata in AMAZON-LISTING.md
```

Total time to your first test EPUB: **~2 hours** if you already have transcripts + 1 sample video.

---

## 📚 Documentation

| Doc | Content |
|---|---|
| [docs/01-pipeline.md](docs/01-pipeline.md) | Technical pipeline: video → transcript → article → chapter → EPUB |
| [docs/02-writing-with-claude.md](docs/02-writing-with-claude.md) | Subagent-driven pattern, chapter anatomy, reusable prompts |
| [docs/03-screenshots.md](docs/03-screenshots.md) | ffmpeg workflow + selection + placeholder replacement |
| [docs/04-build-and-publish.md](docs/04-build-and-publish.md) | Pandoc build, epubcheck validation, Word paperback layout, KDP upload |
| [docs/05-multi-edition.md](docs/05-multi-edition.md) | Parallel IT + EN editions with figures shared via symlinks |

---

## 📁 Repo structure

```
book-from-tutorials/
├── README.md                            ← you are here
├── LICENSE                              ← MIT
├── docs/                                ← 5 in-depth workflow guides
├── scripts/                             ← pipeline scripts
│   ├── setup-book-repo.sh               ← bootstrap a new book
│   ├── transcribe-batch.sh              ← Whisper batch
│   ├── extract-frames.sh                ← ffmpeg screenshots
│   ├── build-epub.sh                    ← pandoc → EPUB3
│   ├── build-paperback.sh               ← pandoc → DOCX
│   └── validate.sh                      ← epubcheck wrapper
└── templates/
    ├── book/                            ← skeleton of a new book
    │   ├── .gitignore
    │   ├── README.md
    │   ├── manuscript/
    │   │   ├── 00-front-matter/         ← cover, title page, copyright, preface, how-to-read
    │   │   ├── parte-1/cap-01.md        ← chapter template
    │   │   └── zz-back-matter/          ← appendices (zz- to sort after parte-N)
    │   └── styles/
    │       ├── kindle.css               ← CSS for EPUB
    │       └── metadata.yaml.template   ← pandoc metadata
    ├── prompts/                         ← prompt templates for Claude Code
    │   ├── transcript-to-article.md
    │   ├── article-to-chapter.md
    │   ├── chapter-expansion.md
    │   └── translate-chapter.md
    └── plans/
        └── plan-pilot-template.md       ← execution plan template
```

---

## 🎓 Origin story

This toolkit is the distillate of the workflow used to produce **Claude Code: The Practical Guide** (2026, ~390 pages, IT + EN on KDP). Technical choices come from real iteration, not theory:

- **Pandoc 3.x** instead of custom solutions (battle-tested for EPUB)
- **`zz-back-matter/`** instead of `99-back-matter/` (because `9` < `p` in ASCII sort)
- **Symlinked figures** between editions (no MB-duplication of PNG files)
- **Subagent waves of 4** to write chapters in parallel
- **HTML comment `<!-- FIGURE: ... -->`** as placeholder (no pandoc breakage)
- **GitHub branches `book/cap-N-stage`** for didactic snapshots in companion repos

---

## 🤝 Contributing

PRs welcome. Areas where help is appreciated:

- [ ] Windows scripts (current `.sh` files are Bash/zsh — PowerShell port useful)
- [ ] Templates for other languages (DE, FR, ES, PT)
- [ ] Variant with Marp/Quarto instead of pandoc for alternative builds
- [ ] Working mini-book examples (starting from public Creative Commons videos)
- [ ] Integration tests for the build pipeline

Open an issue before large changes to discuss.

---

## 📜 License

MIT — reuse freely, attribution appreciated.

---

## 🔗 See also

- 📖 **Claude Code: la guida pratica** (Italian original): https://www.amazon.it/dp/...
- 🎓 **Claude Code: The Practical Guide** (English edition): https://www.amazon.com/dp/...
- 💬 **Discord community** (Claude Code): link at launch

---

**Updated:** 2026-05-18 · Author: Hidran Arias
