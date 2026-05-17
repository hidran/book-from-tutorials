---
description: Draft a book chapter from one or more source articles
argument-hint: <chapter-number> <target-path> <source-articles>
---

Dispatch the `chapter-writer` agent to draft a chapter following the standard anatomy.

## Steps

1. Parse arguments: `$ARGUMENTS` should contain chapter number, target path, and source article(s)
2. If missing, ask the user for:
   - Chapter number (e.g., `8`)
   - Chapter title (e.g., `"Skills: from custom command to reusable capability"`)
   - Target file path (e.g., `book/manuscript/parte-3/cap-08.md`)
   - Source article(s) (e.g., `articles/PE-08.md`, `articles/WS-02.md`)
   - Target word count range (default: 3500-5000 for standard chapter)
   - Language (default: detect from existing chapters)
3. Read `templates/prompts/article-to-chapter.md` to load the standard prompt template
4. Read the reference chapter (`book/manuscript/parte-1/cap-01.md` or any existing one) for tone/style
5. Substitute the variables in the prompt template
6. Dispatch the `chapter-writer` agent (or use the Agent tool with `general-purpose`) with the substituted prompt
7. Verify the agent's output: word count in range, all `<<<...>>>` placeholders replaced, `<!-- FIGURE: ... -->` placeholders present
8. DO NOT commit — show the diff and let the user approve

## Notes

- The agent must NOT commit (orchestrator commits in batch)
- Multiple chapters can be written in parallel by dispatching multiple agents — but each writes a DIFFERENT file
- After writing: run `./scripts/build-epub.sh && ./scripts/validate.sh` to verify the chapter integrates cleanly

## Chapter type → word count

| Type | Range | Pages |
|---|---|---|
| Intro/light | 2500-3500 | 10-14 |
| Standard | 3500-5000 | 14-20 |
| Heavy | 5000-7000 | 20-28 |
| Core (long project chapters) | 7000-9000 | 28-36 |

If source articles are too thin to reach the target, use `/expand-chapter` afterward instead of padding.
