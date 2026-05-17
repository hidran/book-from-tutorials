# Prompt template: Articles → Book Chapter

Copy (and adapt) this prompt to dispatch a subagent that writes a chapter from the source articles.

---

## Variables

- `<CHAPTER_NUM>` — chapter number (e.g. 8)
- `<CHAPTER_TITLE>` — title (e.g. "Skills: from custom command to reusable capability")
- `<OUTPUT_PATH>` — e.g. `book/manuscript/part-3/ch-08.md`
- `<SOURCE_ARTICLES>` — list of source articles (e.g. `articles/PE-08.md`, `articles/WS-02.md`)
- `<WORD_TARGET>` — range (e.g. "5000-6500" for a heavy chapter)
- `<LANGUAGE>` — e.g. "American English"

---

## Prompt

```
Write Chapter <CHAPTER_NUM> of the book "<BOOK_TITLE>" — "<CHAPTER_TITLE>".

## CRITICAL rules

- DO NOT commit. Write the file only. The orchestrator will commit.
- DO NOT touch any file except <OUTPUT_PATH>.
- <LANGUAGE>, second person "you", target audience: intermediate developer.
- Use pandoc fenced div syntax ::: {.chapter-opener} etc. (see an existing chapter as a template)
- For figures: insert HTML comment placeholders <!-- FIGURE: description -->
  The orchestrator will replace them with real image refs afterward.

## Context

- Working directory: <BOOK_PATH>
- Reference template (READ first): book/manuscript/part-1/ch-01.md
- Source articles (READ all):
<SOURCE_ARTICLES>
- Target word count: <WORD_TARGET>
- Output: <OUTPUT_PATH>

## Chapter outline (STANDARD ANATOMY structure)

```markdown
# Chapter <CHAPTER_NUM> — <CHAPTER_TITLE>

::: {.chapter-opener}
**What you'll learn**

- [Bullet 1: main outcome of the chapter]
- [Bullet 2]
- [Bullet 3]
- [Bullet 4]
- [Bullet 5]
:::

::: {.chapter-opener}
**Prerequisites**

- Previous chapters completed (specify which)
- Any required tools/accounts
:::

## Setting the stage: [compelling HOOK]
[~300 words, written fresh. Hook: why does this chapter matter? What's at stake? Connection to the previous chapter. Preview of the value.]

## <N>.1 [First macro section]
[From the source article material. Adapt tone. Add 1–2 placeholders <!-- FIGURE: ... --> where needed.]

## <N>.2 [Second macro section]
[...]

...

## <N>.<X> [Last macro section]
[...]

::: {.chapter-recap}
**Chapter summary**

- [Bullet 1]
- [Bullet 2]
- [Bullet 3]
- [Bullet 4]
- [Bullet 5]
:::

::: {.callout .callout-prompt}
**🔁 Reusable prompt — [Short name]**

[Copy-pasteable prompt template]
:::

### Exercise

[Step-by-step walkthrough, 4–6 steps, to apply the chapter. Estimated time. Starter GitHub branch.]

### Next chapter

[2–3 line narrative teaser for the next chapter.]
```

## Style constraints

- H2 sections numbered (<N>.1, <N>.2, ...)
- Optional H3 sub-sections with conversational titles
- Code blocks tagged with language (e.g. ```bash, ```python)
- Inline commands in `inline code`
- No emoji in body text (except predefined callout labels)

## Transformations table

| From (in articles) | To (in book) |
|---|---|
| "in this video" / "in this lesson" | "in this chapter" |
| "as you can see here" | remove (reader can't see) |
| "we'll see in the next lesson" | "we'll see in the next chapter" |
| "Chapter X" (already in text) | keep |
| H2 "What is X" (duplicate of chapter title) | remove |

## Callout boxes

When appropriate (max 2–3 per chapter), add:

- ::: {.callout .callout-tip} with "**💡 [Short title]**" — non-obvious trick/shortcut
- ::: {.callout .callout-warning} with "**⚠️ [Short title]**" — common mistake / risk
- ::: {.callout .callout-deep-dive} with "**🔧 [Short title]**" — advanced deep-dive
- ::: {.callout .callout-example} with "**📝 [Short title]**" — concrete example

## Status report

End with:
DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED

Then:
1. Final word count
2. Number of <!-- FIGURE: ... --> placeholders
3. List of H2/H3 headings
4. Confirmation "no git ops" performed
5. Any deviations from the outline (and why)
```

---

## Usage notes

**For heavy chapters (5000–7000 words)**: target 6–8 H2 sections instead of 4–5.

**For intro/light chapters (2500–3500 words)**: 3–4 H2 sections are fine.

**Thin source article?** See `templates/prompts/chapter-expansion.md` to expand with fresh content.

**Parallel wave**: dispatch multiple subagents in parallel, each writing a different chapter. Do NOT commit in parallel (git race condition).
