# Prompt template: Transcript → Markdown Article

Copy this prompt into Claude Code to transform a raw transcript into a readable Markdown article.

---

## Variables to substitute

- `<TRANSCRIPT_PATH>` — path to the transcript `.txt` file
- `<OUTPUT_PATH>` — path where the `.md` article will be saved
- `<TITLE_HINT>` — working title of the article (will become the H1)
- `<LANGUAGE>` — language of the article (e.g. "American English", "Italian")

---

## Prompt

```
Transform the raw transcript in <TRANSCRIPT_PATH> into a clean, readable Markdown article
and save it to <OUTPUT_PATH>.

## Transformation rules

1. REMOVE:
   - Speech disfluencies ("uh", "um", "so", "okay", repetitions)
   - Unfinished sentences or ones that change direction mid-way
   - References to slides the reader cannot see ("as you can see here", "on this screen")
   - Intros / greetings / outros typical of videos ("hey everyone", "see you in the next one")

2. PRESERVE:
   - Shell commands, code snippets, terminal output (character-perfect)
   - Concrete examples
   - Proper nouns (products, people, frameworks)
   - The author's opinions and decisions
   - Anecdotes that add value

3. RESTRUCTURE:
   - Add H2 headings for each macro-topic (3–7 sections per article)
   - Break long paragraphs into 2–4 line paragraphs
   - Number steps in ordered lists when there are sequential actions
   - Bullet lists for enumerations
   - Inline code for file names, commands, identifiers

4. TONE:
   - <LANGUAGE>, second person ("you open the terminal", not "one opens the terminal")
   - Direct and practical, no filler
   - Preserve the author's voice (don't make a "straight-talking" author sound "academic")

## Article structure

```markdown
---
title: "<TITLE_HINT>"
subtitle: "[if useful]"
author: "[author name]"
---

# <TITLE_HINT>

## Introduction

[1–2 paragraphs: what this article covers, what the reader will learn]

## [Section 1: macro topic]

[body]

## [Section 2: macro topic]

[body]

...

## Takeaways

- [bullet 1]
- [bullet 2]
- [bullet 3]

---
*Next topic: [brief hint]*
```

## Constraints

- Target length: 1200–1800 words (depending on transcript length)
- Do not invent content that is not in the transcript
- If the transcript contains obvious technical errors (e.g. "Phyton" instead of "Python"),
  fix them silently
- If you find something ambiguous, flag it with `<!-- TODO: verify -->`

## Output

Save directly to <OUTPUT_PATH>. Report:
- Final word count
- Number of H2 sections
- Any TODOs inserted
- Suggestion for the next article (what could logically follow)
```

---

## Usage notes

**For Whisper output**: Whisper typically produces text with little or no punctuation. Add to the prompt: "Add correct punctuation where missing (Whisper often omits it)".

**For Audiate output**: Audiate splits into sentences well but may leave disfluencies. Add: "Remove disfluencies but respect the sentence structure already present".

**Quality check**: after Claude writes the article, **read the whole thing**. If in 5 minutes of reading you don't find anything that feels "not how you would have said it", the article is ready. If you find 3+ things, dispatch a refinement round with specific feedback.
