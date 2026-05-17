# CLAUDE.md — Project memory for `book-from-tutorials`

This file is loaded automatically by Claude Code when you run `claude` in this directory. It tells me what this repo is and how to help you.

> **Cross-tool agents**: this file is also valid `AGENTS.md` format (see https://agents.md/). It's mirrored as `AGENTS.md` for Cursor / Aider / other AI coding assistants.

---

## What this repo is

A **toolkit** to produce sellable Kindle books from a corpus of video tutorials. It is **not a book itself** — it's the pipeline + scripts + docs + templates + prompts you USE to build books somewhere else.

Pipeline: `videos → transcripts → articles → chapters → EPUB + paperback → KDP`.

Distilled from the production of *Claude Code: The Practical Guide* (~98,000 words, 16 chapters, IT + EN editions).

---

## Tech stack

| Layer | Tools |
|---|---|
| Pipeline | Bash scripts (POSIX-friendly) |
| Build | Pandoc 3.x → EPUB3 + DOCX |
| Validation | epubcheck 5.x |
| Screenshots | ffmpeg 8.x |
| Transcription | OpenAI Whisper (local or API) |
| QA | Kindle Previewer 3 (manual, Amazon-provided) |
| Source format | Markdown + pandoc fenced divs |
| Manuscript layout | `manuscript/00-front-matter/` + `parte-N/` + `zz-back-matter/` (sort order matters) |

> ⚠️ `zz-back-matter/` (not `99-back-matter/`) — because ASCII `9` < `p`, so `99-` would sort BEFORE `parte-1/`, putting appendices at the start of the book.

---

## Project structure

```
book-from-tutorials/
├── CLAUDE.md / AGENTS.md           ← this file (project memory)
├── README.md                       ← user-facing entry point
├── LICENSE                         ← MIT
├── .claude/                        ← Claude Code project config
│   ├── commands/                   ← custom slash commands (/new-book, /write-chapter, ...)
│   ├── agents/                     ← specialized subagents (chapter-writer, transcript-cleaner, ...)
│   └── settings.json               ← permissions, hooks
├── docs/                           ← 5 in-depth workflow guides
│   ├── 01-pipeline.md
│   ├── 02-writing-with-claude.md
│   ├── 03-screenshots.md
│   ├── 04-build-and-publish.md
│   └── 05-multi-edition.md
├── scripts/                        ← pipeline scripts (executable)
│   ├── setup-book-repo.sh          ← bootstrap a new book
│   ├── transcribe-batch.sh         ← Whisper batch
│   ├── extract-frames.sh           ← ffmpeg screenshots
│   ├── build-epub.sh               ← pandoc → EPUB3
│   ├── build-paperback.sh          ← pandoc → DOCX
│   └── validate.sh                 ← epubcheck wrapper
└── templates/
    ├── book/                       ← skeleton of a new book (copied by setup-book-repo.sh)
    ├── prompts/                    ← prompt templates for Claude Code
    │   ├── transcript-to-article.md
    │   ├── article-to-chapter.md
    │   ├── chapter-expansion.md
    │   └── translate-chapter.md
    └── plans/
        └── plan-pilot-template.md
```

---

## What users ask, and how to help

### "I want to start a new book"

1. Suggest `./scripts/setup-book-repo.sh ~/my-book "Title" "Author" en-US`
2. Point them at `README.md` quick start
3. Point them at `docs/01-pipeline.md` for the end-to-end flow

### "Help me write a chapter"

1. Use the `/write-chapter` slash command (in `.claude/commands/`)
2. Or dispatch the `chapter-writer` subagent
3. Or manually use `templates/prompts/article-to-chapter.md`

### "My chapter is too short"

Reference `templates/prompts/chapter-expansion.md` — add sections from scratch (troubleshooting, optimal setup, guided walkthrough). Don't pad existing content.

### "Translate my chapter to English"

Use `templates/prompts/translate-chapter.md`. Standard label translations are already mapped (Cosa imparerai → What you'll learn, etc.).

### "How do I build the EPUB?"

```bash
cd <user-book-dir>
./scripts/build-epub.sh
./scripts/validate.sh   # must report 0 errors / 0 warnings
./scripts/build-paperback.sh
```

### "How do I publish to KDP?"

`docs/04-build-and-publish.md` § KDP. Generate metadata via the included `AMAZON-LISTING.md` template (see Claude Code book companion repos for a worked example).

### "Add a new feature to the toolkit"

This means modifying THIS repo. See conventions below.

---

## Conventions when modifying the toolkit

### Bash scripts
- Shebang: `#!/usr/bin/env bash` (not `/bin/bash` — macOS ships ancient bash 3.2)
- `set -euo pipefail` at the top
- Use `$(cd "$(dirname "$0")/.." && pwd)` to get the project root
- Echo helpful progress messages (use `→`, `✓`, `✗`, `⚠`)
- Errors to stderr: `echo "..." >&2`
- Exit codes: 0 success, 1 user error, 2 system error
- Naming: kebab-case (`extract-frames.sh`, not `extract_frames.sh`)
- All scripts must pass `bash -n script.sh` (syntax check)

### Markdown
- GFM compatible (works on GitHub) AND pandoc-compatible (no GFM-exclusive features in `templates/book/`)
- Fenced code blocks tagged with language: `` ```bash ``, `` ```python ``
- Tables use pipe syntax with header separators
- Headings: ATX style (`#` not `===`)
- American English in docs and toolkit content
- Second-person "you" — direct, practical

### File organization
- `templates/book/` is what `setup-book-repo.sh` copies into a user's new book. **Don't break it.** Always test by running `./scripts/setup-book-repo.sh /tmp/test-book ...` after changes.
- `templates/prompts/` are copy-pasteable into Claude Code. Variable placeholders use `<UPPERCASE_KEBAB>` (e.g., `<CHAPTER_TITLE>`).

### Italian artifacts (intentional)
- The `templates/book/manuscript/parte-1/cap-01.md` skeleton uses Italian directory/file names (`parte-1/`, `cap-01.md`) because they are the established convention from the source book. The CONTENT is English, the file names are Italian. **Don't rename them.**

---

## Things to NOT do

- ❌ Don't add npm/Python/Ruby dependencies — this is a Bash + pandoc + ffmpeg toolkit. Adding language runtimes would balloon the install footprint.
- ❌ Don't break `templates/book/` skeleton — it's the bootstrap source.
- ❌ Don't commit large binary files (screenshots, EPUBs, DOCXs). Those live in user book repos and companion repos, not here.
- ❌ Don't replace pandoc with a custom solution. Pandoc is battle-tested and the right call.
- ❌ Don't translate documentation away from American English without explicit user request.
- ❌ Don't auto-commit. Always show diff and let user approve.

---

## Test before committing changes to the toolkit

```bash
# 1. Bash syntax
for f in scripts/*.sh; do bash -n "$f" || echo "SYNTAX ERROR: $f"; done

# 2. setup-book-repo.sh still works
rm -rf /tmp/toolkit-smoke-test
./scripts/setup-book-repo.sh /tmp/toolkit-smoke-test "Smoke Test" "Tester" en-US
[ -d /tmp/toolkit-smoke-test/manuscript ] || echo "FAIL: manuscript missing"
[ -f /tmp/toolkit-smoke-test/styles/metadata.yaml ] || echo "FAIL: metadata missing"
[ -x /tmp/toolkit-smoke-test/scripts/build-epub.sh ] || echo "FAIL: scripts not executable"

# 3. Templates pass minimal pandoc smoke test
cd /tmp/toolkit-smoke-test && pandoc manuscript/parte-1/cap-01.md -o /tmp/smoke.html && echo "✓ pandoc render OK"
```

---

## Custom commands available

In an interactive Claude Code session in this repo:

- `/new-book` — bootstrap a new book project
- `/write-chapter` — dispatch the chapter-writer agent
- `/translate-chapter` — translate a chapter to another language
- `/expand-chapter` — expand a thin chapter with from-scratch sections
- `/extract-frames` — extract video screenshots via ffmpeg
- `/build-book` — run the full build + validate pipeline

Defined in `.claude/commands/*.md`. Modify them if your workflow differs.

---

## Specialized agents

- `chapter-writer` — writes a book chapter from source articles following the standard anatomy
- `transcript-cleaner` — turns a raw Whisper transcript into a readable article
- `chapter-translator` — translates a chapter to a target language preserving pandoc structure

Defined in `.claude/agents/*.md`. The orchestrator (you, Claude) dispatches these via the Agent tool.

---

## Reference book (worked example)

The book this toolkit was distilled from:

- **Claude Code: la guida pratica** (IT) — https://www.amazon.it/dp/...
- **Claude Code: The Practical Guide** (EN) — https://www.amazon.com/dp/...
- Companion repos:
  - https://github.com/hidran/fluentaipro-claude-andingpage (landing page, Cap. 10)
  - https://github.com/hidran/claude-code-book-photogallery (Photogallery, cap. 11-16)

---

**Last updated:** 2026-05-18 · Author: Hidran Arias
