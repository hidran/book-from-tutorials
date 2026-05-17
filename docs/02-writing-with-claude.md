# 02 · Writing Chapters with Claude Code

The heart of the workflow: how to use Claude Code (and its subagents) to turn raw articles into book chapters.

---

## Anatomy of a chapter

Every chapter in the book follows a recurring structure (~20–25 pages, typically 4,000–5,000 words):

```
┌─────────────────────────────────────────────────┐
│ 1. OPENING (1 page)                             │
│    ├─ Chapter title                             │
│    ├─ Box "What you'll learn" (3–5 bullets)     │
│    └─ Box "Prerequisites"                       │
├─────────────────────────────────────────────────┤
│ 2. NARRATIVE INTRO (1 page, written from scratch)│
│    Hook to previous chapter + why now           │
├─────────────────────────────────────────────────┤
│ 3. BODY (15–20 pages — adapted articles)        │
│    Numbered H2 sections (X.1, X.2, ...)         │
│    with screenshots, snippets, callouts         │
├─────────────────────────────────────────────────┤
│ 4. RECAP (1 page, written from scratch)         │
│    "Summary" box + "Reusable prompt" box        │
├─────────────────────────────────────────────────┤
│ 5. EXERCISE (1 page, written from scratch)      │
│    Guided task + starting GitHub branch         │
├─────────────────────────────────────────────────┤
│ 6. NEXT CHAPTER (½ page)                        │
│    Transition teaser                            │
└─────────────────────────────────────────────────┘
```

Sections 2, 4, 5, and 6 are **written from scratch** (Claude writes them from zero). Section 3 is the **adaptation** of the source articles.

---

## Subagent-Driven Pattern

To write N chapters quickly, use **parallel subagents**.

Important constraint: each subagent writes a DIFFERENT file and does NOT commit. The orchestrator commits in batch at the end.

### Wave dispatcher

```bash
# In an interactive Claude Code session (or scripted via Claude API):
```

```text
Dispatch 4 subagents in parallel. Each one writes ONE specific chapter:

Subagent 1: write book/manuscript/parte-1/cap-02.md by reading articles/PE-02.md
  Target: 4000–5000 words. Standard anatomy.
  DO NOT commit.

Subagent 2: write book/manuscript/parte-2/cap-03.md by reading articles/PE-02.md (CSV part) + articles/PE-03.md
  Target: 4500–5500 words.
  DO NOT commit.

Subagent 3: write book/manuscript/parte-2/cap-04.md by reading articles/WS-01.md
  Target: 3500–4500 words.
  DO NOT commit.

Subagent 4: write book/manuscript/parte-2/cap-05.md by reading articles/PE-04.md + articles/PE-09.md
  Target: 4500–5500 words.
  DO NOT commit.

After all subagents finish, I will commit in a single commit "feat(plan-2): write 4 chapters".
```

### Execution time

For a wave of 4 chapters:
- Sequential: ~20–30 min
- Parallel (4 simultaneous subagents): ~5–10 min

For 16 chapters across 4 waves: **~30 min in parallel** vs ~2 hours sequentially.

---

## Prompt template for chapter writing

Use `templates/prompts/article-to-chapter.md` as your base. Adapt it for your specific chapter.

Key elements of the prompt:

1. **Critical rules**: DO NOT commit, explicit target file path
2. **Sources**: list of articles to read with full paths
3. **Target word count**: with a realistic range for the chapter type
4. **Required outline**: opener + premise + N numbered sections + recap + exercise + teaser
5. **Translation table**: how to adapt "in this lesson/video" → "in this chapter"
6. **Callout labels**: 💡 Tip, ⚠️ Warning, 🔁 Reusable prompt
7. **Code blocks**: preserve code snippets intact
8. **Status reporting**: format DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED

---

## Handling "thin" articles

Real problem: some source articles are 1,300–1,500 words. For a 4,500-word chapter, you're missing ~3,000 words.

**Strategies:**

1. **From-scratch expansion** (recommended for intro chapters)
   - Add sections the article doesn't cover: troubleshooting, optimal setup, guided walkthrough
   - Use the prompt `templates/prompts/chapter-expansion.md`
   - Typical result: add 3 sections × 600 words = +1,800 words

2. **Merging adjacent articles**
   - e.g., cap-02 = PE-02 (general part) + PE-03 (introductory part)
   - Reduces the number of chapters but makes each one richer

3. **Accept shorter chapters**
   - Update the spec with realistic ranges by chapter type:
     - Intro/light: 2,500–3,500 words (10–14 pages)
     - Standard: 3,500–5,000 (14–20 pages)
     - Heavy: 5,000–7,000 (20–28 pages)
     - Core of the book: 7,000–9,000 (28–36 pages)

---

## Iteration: what to do when a chapter falls short

Pattern seen in the original book: Chapter 1 came out at 2,500 words (target was 4,500), and the test reader asked "only 11 pages?".

Solution applied:
1. Identified: PE-01 was thin, missing sections on Installation + Environment setup + Guided first prompt
2. Added 3 new sections (~2,000 words) with a single prompt to the subagent
3. Re-build + QA Kindle Previewer → 18–20 pages
4. ✓ accepted

Time: ~15 minutes for expansion, +1 build cycle.

Lesson: **iterate fast**, don't wait until you have "the perfect plan".

---

## Tone and voice

Calibrate the initial prompt for the tone you want:

| Tone | When | Example prompt |
|---|---|---|
| Direct, second person | Intermediate tech tutorial | "American English, second person 'you', intermediate developer" |
| More formal, third person | Enterprise manual | "Formal English, third person, professional audience" |
| Casual, inclusive first person | Self-help, opinion | "English, mix of first/second person, conversational" |

In the Claude Code book we used the first option. Maintaining consistency is critical: if you shift tone in chapter 3, readers will feel it.

---

## Anti-patterns to avoid

- ❌ **Commit per chapter from parallel subagents** → git race condition
- ❌ **Subagent reads "the entire project"** → wasted tokens, hallucinations
- ❌ **Prompt without a word count target** → inconsistent chapter lengths
- ❌ **Skipping the "do not" rules in the prompt** ("do not write invented example code") → fabricated stacks that don't exist
- ❌ **Validating only at end of production** → pandoc bugs discovered after 16 chapters
- ✅ **Cumulative validation after each wave** → immediate fixes

---

## Human approval

The AI writes. **You** decide whether it's good. Mandatory review checkpoints:

1. **After the first pilot chapter** → verify anatomy + tone
2. **After each writing wave** → read the generated chapters, flag issues
3. **Before the final build** → cumulative read
4. **After QA Kindle Previewer** → read on a simulated device

Don't skip these checkpoints to "go faster". The cost of a poorly written book is one-star reviews for life.

---

## See also

- `templates/prompts/article-to-chapter.md` — complete prompt template
- `templates/prompts/chapter-expansion.md` — prompt for expanding thin chapters
- `templates/prompts/translate-chapter.md` — prompt for IT → EN translation
