# AGENTS.md

Cross-tool instructions for AI coding agents (Cursor, Aider, Codex, etc.) working in this repo.

> **Note**: this file mirrors `CLAUDE.md`. If you're using Claude Code, read `CLAUDE.md` instead (it includes Claude-specific `.claude/commands/` and `.claude/agents/` references). For other tools, read on.

---

## Repo purpose

A **toolkit** to produce sellable Kindle books from video tutorials. Pipeline: videos → transcripts → articles → chapters → EPUB → KDP.

It is **not a book** — it's the scripts, templates, and prompts you use to build books elsewhere.

---

## Tech stack

- Bash (POSIX-friendly)
- Pandoc 3.x (EPUB + DOCX generation)
- ffmpeg 8.x (screenshot extraction)
- OpenAI Whisper (transcription)
- epubcheck 5.x (validation)
- Markdown + pandoc fenced divs (source format)

No Node/Python/Ruby dependencies. Adding them is a deliberate decision that requires user approval.

---

## Project structure

```
book-from-tutorials/
├── README.md
├── CLAUDE.md / AGENTS.md
├── LICENSE
├── docs/         5 workflow guides (01-pipeline through 05-multi-edition)
├── scripts/      bash pipeline (setup-book-repo, transcribe-batch, extract-frames, build-epub, build-paperback, validate)
└── templates/
    ├── book/     skeleton copied by setup-book-repo.sh into a new book
    ├── prompts/  4 prompt templates for AI agents
    └── plans/    execution plan templates
```

---

## Build & test

```bash
# Syntax check all scripts
for f in scripts/*.sh; do bash -n "$f" || echo "SYNTAX ERROR: $f"; done

# Smoke test: bootstrap a new book and verify structure
rm -rf /tmp/toolkit-smoke-test
./scripts/setup-book-repo.sh /tmp/toolkit-smoke-test "Smoke Test" "Tester" en-US
test -d /tmp/toolkit-smoke-test/manuscript || { echo "FAIL"; exit 1; }
test -x /tmp/toolkit-smoke-test/scripts/build-epub.sh || { echo "FAIL"; exit 1; }
echo "✓ smoke test passed"

# Pandoc render of chapter template
cd /tmp/toolkit-smoke-test && pandoc manuscript/parte-1/cap-01.md -o /tmp/smoke.html
```

No automated test suite — this is a build tool, validation is run-and-check.

---

## Code style

### Bash
- Shebang: `#!/usr/bin/env bash`
- `set -euo pipefail` always
- Errors to stderr: `echo "..." >&2`
- Exit codes: 0 success / 1 user error / 2 system error
- Naming: kebab-case (`extract-frames.sh`)

### Markdown
- GFM-compatible AND pandoc-compatible
- ATX headings (`#` not `===`)
- Fenced code blocks with language tags
- American English, second-person "you"

### File organization
- `templates/book/` is the bootstrap skeleton — don't break it
- `templates/prompts/` use `<UPPERCASE_KEBAB>` placeholders for variables

---

## Conventions you must respect

- The book skeleton uses Italian directory names (`parte-1/`, `cap-01.md`) by design — keep them
- The back matter folder is `zz-back-matter/` (not `99-back-matter/`) for ASCII sort correctness
- Pandoc HTML comments must NOT contain `--` (it breaks XML — escape or rephrase)
- Image paths in markdown are RELATIVE TO `book/`, not to the `.md` file
- Default to American English in all docs and toolkit content

---

## Things you must NOT do without explicit approval

- Add language runtime dependencies (no npm/pip/gem)
- Modify the `templates/book/` skeleton structure
- Auto-commit changes (always show diff first)
- Translate docs to non-English languages
- Replace pandoc with a custom solution

---

## Common tasks

### User wants to start a new book

Run `./scripts/setup-book-repo.sh <path> <title> <author> <language>`. Then refer them to `README.md` quick start.

### User wants help writing a chapter

Read `templates/prompts/article-to-chapter.md`. It contains a complete prompt with variables. Substitute the variables and proceed.

### User wants to translate a chapter

Read `templates/prompts/translate-chapter.md`. Standard label translations are mapped.

### User wants to add a new script

1. Create in `scripts/` with `#!/usr/bin/env bash` + `set -euo pipefail`
2. Add usage docstring at top
3. Reference from `docs/01-pipeline.md` if part of the main pipeline
4. Update this `AGENTS.md` "Common tasks" section if user-facing

---

## Reference

Source book this toolkit was distilled from: *Claude Code: The Practical Guide* (Hidran Arias, 2026, KDP).

Last updated: 2026-05-18.
