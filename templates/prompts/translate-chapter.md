# Prompt template: Chapter translation (any source → target language pair)

For dispatching parallel subagents that translate chapters from one language to another.

---

## Variables

- `<SOURCE_LANG>` — e.g. "Italian"
- `<TARGET_LANG>` — e.g. "American English"
- `<SOURCE_PATH>` — e.g. `book/manuscript/part-3/ch-08.md`
- `<TARGET_PATH>` — e.g. `book-en/manuscript/part-3/ch-08.md`
- `<CHAPTER_TITLE_EN>` — chapter title in the target language

---

## Prompt

```
Translate the chapter at <SOURCE_PATH> into <TARGET_LANG> and save it to <TARGET_PATH>.

## CRITICAL rules

- DO NOT commit.
- DO NOT touch any file except <TARGET_PATH>.
- Preserve ALL markdown/pandoc structure: fenced divs ::: {.chapter-opener},
  callouts ::: {.callout .callout-*}, image refs ![](figures/...){#fig:N-N width=100%},
  italic captions, code blocks ```.
- Image paths remain IDENTICAL (figures are shared between editions via symlink).
  Translate ONLY the captions (e.g. "Figura 1.1: ..." → "Figure 1.1: ...").

## Chapter title in the target language

# <CHAPTER_TITLE_EN>

## Translation hints (substitute as needed)

| Source | Target |
|---|---|
| Premessa: [title] | Setting the stage: [title] |
| [Number].X [title] | [Number].X [title] |
| Esercizio proposto | Exercise |
| Prossimo capitolo | Next chapter |
| Tempo stimato | Estimated time |
| Branch GitHub di partenza | Starter GitHub branch |
| Capitolo N | Chapter N |
| Parte N | Part N |

## Callout box labels (translate)

| Source | Target |
|---|---|
| 💡 Suggerimento | 💡 Tip |
| ⚠️ Attenzione | ⚠️ Warning |
| 🔧 Sotto il cofano | 🔧 Under the hood |
| 📝 Esempio | 📝 Example |
| 🔁 Prompt riusabile | 🔁 Reusable prompt |
| Cosa imparerai | What you'll learn |
| Prerequisiti | Prerequisites |
| Riepilogo del capitolo | Chapter summary |

## What NOT to translate

- Shell commands (`npm install`, `git commit`, `claude /help`, etc.)
- File names and paths (`src/index.js`, etc.)
- Code identifiers (variables, functions, classes)
- Product / framework names (NestJS, Claude Code, Anthropic, etc.)
- Pandoc fenced div classes
- Image refs (path stays identical)

## What TO translate

- All prose
- Comments inside code blocks (if in the source language)
- Example prompts inside code blocks (if they are instructions to Claude in the source language)
- Figure captions
- Cross-references ("Cap. 8" → "Chapter 8")
- Currency: adapt to target market (e.g. € → $ for US, £ for UK)
- Date format: use ISO (e.g. 2026-05-18) — universally unambiguous

## Cultural adaptations

- Idioms: translate naturally, not literally
- Business examples: if company names are too localized for the target market,
  replace them with recognizable equivalents (e.g. a hyper-local retailer → an equivalent well-known brand in the target region)
- Currency: $9.99 for US, €9.99 for EU, £8.99 for UK
- Measurements: use SI units universally, or adapt to target (oz/lb for US, kg/g elsewhere)

## Tone

- <TARGET_LANG>, second person ("you")
- Same voice and rhythm as the source
- Do NOT make it "more formal" — preserve the original register
- Do NOT expand or cut content

## Status report

End with:
DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED

Then:
1. Word count of the written file (and ratio vs. source: typically <TARGET_LANG> is 5–10% shorter than the source)
2. Confirmation of no git ops
3. Confirmation that only the target file was touched
4. Any cultural adaptations made (list)
5. Non-obvious translation decisions (e.g. "translated X as Y because...")
```

---

## Parallel dispatch

To translate 16 chapters + front matter + 5 appendices:

```
Wave 1: 4 subagents in parallel → front matter + ch 1 + ch 2 + ch 3
Wave 2: 4 subagents → ch 4–7
Wave 3: 4 subagents → ch 8–11
Wave 4: 4 subagents → ch 12–15
Wave 5: 4 subagents → ch 16 + appendix A + B + (C+D+E together)
```

Total time: ~85 min for 98k words source → target (vs. ~15h sequential).

---

## Post-translation quality check

Before committing:

1. **Build target EPUB** and verify `epubcheck` → 0 errors
2. **Read a random sample** (3 chapters): is the translation fluent? Are idioms natural?
3. **Grep for unfinished**: search for words remaining in the source language
   ```bash
   # Search for common source-language words in the target manuscript directory
   grep -rn '\bcapitolo\b\|\bperché\b\|\busiamo\b' book-en/manuscript/ | head
   ```
4. **Native editor pass** (optional but recommended for publication): ~$200–400 on Reedsy/Upwork for a full-book pass
