---
description: Build EPUB + DOCX and validate with epubcheck
---

Run the full build + validate pipeline for the current book.

## Steps

1. Verify you're in a book directory (must contain `manuscript/` and `scripts/`)
2. Run `./scripts/build-epub.sh`
3. Run `./scripts/validate.sh` — must show `0 fatals / 0 errors / 0 warnings`
4. If validation fails: read the error output, identify the problem, propose fix
5. Run `./scripts/build-paperback.sh`
6. Report sizes:
   - `build/manuscript.epub` (target: <50 MB)
   - `build/manuscript.docx`
7. Suggest next steps:
   - Open EPUB in Kindle Previewer 3 for visual QA
   - Open DOCX in Word for paperback layout

## Common errors to fix

- **`FATAL: The string "--" is not permitted within comments`**: an HTML comment contains `--`. Find with:
  ```bash
  grep -rnE '<!--[^>]*-{2,}[^>]*-->' manuscript/
  ```
  Rephrase to avoid double-dashes.

- **`ERROR: Referenced resource ... could not be found`**: an `![](figures/...)` points to a missing file. Find with:
  ```bash
  for ref in $(grep -roh 'figures/cap-[^)]*\.png' manuscript/); do
    [ -f "$ref" ] || echo "MISSING: $ref"
  done
  ```

- **`ERROR: Fragment identifier is not defined`**: cross-reference to an anchor that doesn't exist. Usually `[#fig:N]` pointing to a removed figure.

- **`[WARNING] Could not fetch resource ../../figures/...`**: image path is relative to `.md` file but should be relative to `book/`. Change `../../figures/cap-NN/` to `figures/cap-NN/`.

## QA checklist after build

- [ ] EPUB validates clean (0 errors)
- [ ] Open in Kindle Previewer → switch between Paperwhite, Fire HD, iOS App
- [ ] TOC navigable from home
- [ ] Callout boxes render with backgrounds
- [ ] Code blocks don't exceed screen width on phone
- [ ] All figures visible (test grayscale on Paperwhite)
- [ ] Emoji in callouts render correctly (or fall back to text labels)

## Don't commit the build outputs by default

`build/manuscript.epub` and `build/manuscript.docx` are gitignored. Commit them only as snapshots at major milestones (e.g., pre-publish), not on every build.
