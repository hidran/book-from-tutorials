---
description: Expand a thin chapter with new from-scratch sections (no padding)
argument-hint: <chapter-path> <target-words> <missing-topics>
---

Expand a chapter that came out below the target word count by adding NEW sections, never padding existing ones.

## When to use

If a chapter is significantly under target (e.g., 2500 words on a 4500-word target), don't pad — add new sections that cover topics the original article missed.

Typical topics to add ex-novo:
- Troubleshooting / common errors
- Optimal environment setup
- Guided walkthrough with worked example
- Comparison with alternatives
- Pricing/cost discussion (if relevant)
- Advanced patterns

## Steps

1. Parse arguments: `$ARGUMENTS` should contain chapter path, target word count, and topics
2. If missing, ask:
   - Chapter path to expand
   - Current word count (or compute via `wc -w <path>`)
   - Target word count
   - Topics to add (3-5 specific topics that fit the chapter)
3. Read `templates/prompts/chapter-expansion.md` for the standard expansion prompt
4. Read the existing chapter to understand its current structure and tone
5. Substitute variables
6. Dispatch a subagent with the expansion prompt
7. Verify:
   - Existing sections preserved intact
   - New sections numbered sequentially (e.g., if original has 1.1-1.3, new are 1.4, 1.5, 1.6)
   - "What you'll learn" box updated with new outcomes
   - Word count delta matches target
8. DO NOT commit

## Real example (from the source book)

Chapter 1 of *Claude Code: The Practical Guide* came in at 2508 words (target 4500). Expansion added:
- § 1.2.1 Installation troubleshooting (~500 words)
- § 1.4 Optimal terminal setup (~700 words)
- § 1.5 Your first guided prompt (~800 words)

Result: 2508 → 4744 words. Time: ~15 minutes.

## When NOT to expand

If the article is genuinely a short topic, accept the shorter chapter and update your spec with realistic ranges:

- Intro/light: 2500-3500 words (10-14 pages)
- Standard: 3500-5000 (14-20)
- Heavy: 5000-7000 (20-28)
- Core: 7000-9000 (28-36)

Not all chapters need to be the same length.
