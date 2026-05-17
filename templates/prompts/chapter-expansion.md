# Prompt template: Thin Chapter Expansion

When a written chapter comes in under-target (e.g. 2500 words against a 4500-word target), expand it with fresh sections instead of padding the existing content.

---

## Variables

- `<CHAPTER_PATH>` — chapter file to expand
- `<CURRENT_WORDS>` — current word count
- `<TARGET_WORDS>` — target to reach
- `<MISSING_TOPICS>` — list of topics missing from the chapter

---

## Prompt

```
Expand the chapter at <CHAPTER_PATH> from <CURRENT_WORDS> to ~<TARGET_WORDS> words
by adding brand-new sections.

## Rules

- DO NOT commit.
- DO NOT touch any file except <CHAPTER_PATH>.
- Preserve the existing structure intact: opener, setting-the-stage section, existing numbered
  sections, recap, exercise, next-chapter teaser.
- Add NEW numbered sections (e.g. if the chapter has 1.1–1.3, add 1.4, 1.5, 1.6
  and optionally move the "Roadmap" section to 1.7).

## Topics to cover in the new sections

<MISSING_TOPICS>

Typical examples of fresh topics that work well:
- "Troubleshooting" section inside an Installation/Setup chapter
- "Optimal environment setup" section with terminal, shell, dotfile tips
- "Guided walkthrough" section with a mini end-to-end example
- "Comparison with alternatives" section placing the tool in context
- "Advanced patterns" section adding depth
- "Pricing/costs" section if relevant
- "Common pitfalls" section with 3–5 mistakes and fixes

## Style constraints

- Same tone and voice as the existing sections
- Consistent numbering
- Add 1–2 placeholders <!-- FIGURE: ... --> in the new sections where needed
- Add 1 callout box per new section (e.g. ::: {.callout .callout-tip})
- Update the "What you'll learn" box at the top to include the new outcomes

## Status report

End with:
DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED

Then:
1. Final word count (and delta vs. before)
2. New H2 sections added (with titles)
3. Number of <!-- FIGURE: ... --> placeholders added
4. Confirmation of no git ops
5. Any topics you were unable to cover (and why)
```

---

## Real-world example

In the original Claude Code book, Chapter 1 came out at 2508 words (target was 4500). Expansion applied:

- **§ 1.2.1 Installation troubleshooting** (~500 words) — EACCES, PATH, Apple Silicon, WSL
- **§ 1.4 Optimal environment setup** (~700 words) — iTerm2/Warp, zsh/fish, Starship, aliases
- **§ 1.5 Your first guided prompt** (~800 words) — end-to-end argparse walkthrough

Result: 2508 → 4744 words (~18–20 pages, within target).

Time: ~15 minutes for expansion + 1 build cycle.

---

## When NOT to expand

If the source article is genuinely thin and the chapter is authentically short (e.g. an intro chapter of a few pages), **accept the length** rather than inflating it.

Instead, update the book spec with realistic ranges by type:
- Intro/light: 2500–3500 words (10–14 pages)
- Standard: 3500–5000 (14–20 pages)
- Heavy: 5000–7000 (20–28 pages)
- Core of book: 7000–9000 (28–36 pages)
