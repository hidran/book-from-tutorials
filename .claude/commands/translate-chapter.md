---
description: Translate a chapter from source language to target language preserving pandoc structure
argument-hint: <source-path> <target-path> <target-language>
---

Dispatch the `chapter-translator` agent to translate a chapter while preserving all pandoc/markdown structure.

## Steps

1. Parse arguments: `$ARGUMENTS` should contain source path, target path, target language
2. If missing, ask for:
   - Source chapter path (e.g., `book/manuscript/parte-3/cap-08.md`)
   - Target chapter path (e.g., `book-en/manuscript/parte-3/cap-08.md`)
   - Target language (e.g., `American English`, `British English`, `Deutsch`)
   - Chapter title in target language (the agent needs this for the H1)
3. Read `templates/prompts/translate-chapter.md` for the standard translation prompt
4. Substitute variables
5. Dispatch the `chapter-translator` agent
6. Verify output:
   - Same pandoc structure (`::: {.chapter-opener}`, callouts, image refs intact)
   - Image paths UNCHANGED (figures shared via symlink between editions)
   - All `<<<...>>>` and `<!-- FIGURE: ... -->` markers preserved exactly
   - No source-language artifacts left (run `grep -c '<source-language-word>'`)
7. DO NOT commit

## Notes

- Image paths stay identical — the agent translates ONLY the caption text
- Standard label translations (from `templates/prompts/translate-chapter.md`):
  - Cosa imparerai → What you'll learn
  - Premessa → Setting the stage
  - 💡 Suggerimento → 💡 Tip
  - ⚠️ Attenzione → ⚠️ Warning
  - Riepilogo del capitolo → Chapter summary
- Currency adapts: € → $ for US market
- Don't translate: shell commands, code identifiers, product names, file paths

## Parallel translation

To translate multiple chapters in parallel: dispatch one `chapter-translator` agent per chapter (each writes a different target file). Wait for all to finish before committing.
