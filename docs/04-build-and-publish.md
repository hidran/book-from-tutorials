# 04 · Build & Publish

From Markdown to a validated EPUB + DOCX paperback + KDP upload.

---

## Build pipeline

```
manuscript/*.md  ──┐
                   │  pandoc 3.x
styles/kindle.css ─┤  +
                   │  styles/metadata.yaml
figures/cap-*/*.png─┘
                   │
                   ▼
              ┌─────────┐
              │ EPUB3   │  ← for Kindle
              │ DOCX    │  ← for paperback (lay out in Word)
              └─────────┘
                   │
                   ▼
              epubcheck → 0 errors / 0 warnings
                   │
                   ▼
              Kindle Previewer 3 (manual QA)
                   │
                   ▼
              KDP upload
```

---

## Build EPUB

```bash
./scripts/build-epub.sh
```

The script:
1. Finds all `.md` files under `manuscript/`
2. Sorts them alphabetically (which is why we have `00-front-matter/` and `zz-back-matter/`)
3. Passes them to pandoc with `--metadata-file=styles/metadata.yaml` and `--css=styles/kindle.css`
4. Produces `build/manuscript.epub`

### Pandoc sorting

Pandoc concatenates files in the order you pass them. The script uses `find ... | sort`, which sorts ASCII-betically.

| Folder prefix | ASCII sort | Position in book |
|---|---|---|
| `00-front-matter/` | first | beginning (preface, etc.) |
| `parte-1/` ... `parte-5/` | in the middle | chapters |
| `zz-back-matter/` | last | end (appendices) |

**Common bug**: naming the folder `99-back-matter/`. ASCII `9` (0x39) < `p` (0x70), so `99-back-matter` ends up BEFORE `parte-1/` → appendices appear at the start of the book. Use `zz-` to be safe.

---

## Validation

```bash
./scripts/validate.sh
```

Runs `epubcheck` (the official W3C / IDPF validator). Desired output:

```
Messages: 0 fatals / 0 errors / 0 warnings / 0 infos
✓ Valid EPUB — ready for KDP upload
```

**Most common errors** and how to fix them:

| Error | Cause | Fix |
|---|---|---|
| `FATAL: The string "--" is not permitted within comments` | HTML comment containing `--` (e.g. `<!-- foo --bar -->`) | Rewrite the comment to avoid the double dash |
| `ERROR: Referenced resource ... could not be found` | Image ref pointing to a nonexistent file | Verify that `figures/cap-NN/...` exists |
| `ERROR: Fragment identifier is not defined` | `[#fig:5]` but figure 5 doesn't exist | Add the figure or remove the link |
| `WARNING: 'a' tag uses 'name' attribute` | Outdated pandoc version | Upgrade to pandoc 3.x |

---

## Build DOCX (paperback)

```bash
./scripts/build-paperback.sh
```

Produces `build/manuscript.docx`. **This is not print-ready** — it's the starting point for layout work in Word.

### Word layout for KDP 6×9"

Open the DOCX and:

1. **Page setup**: `Layout → Size → Custom → 6" × 9"` (15.24 × 22.86 cm)
2. **Margins**: `Layout → Margins → Custom`:
   - Gutter margin: 0.75"
   - Outside: 0.5"
   - Top: 0.5"
   - Bottom: 0.5"
3. **Headers (page number + chapter)**:
   - Page number centered in the footer
   - Left header (even pages): book title
   - Right header (odd pages): chapter title
   - Different first page (title page has no number)
4. **Paragraph styles**:
   - H1 (chapters) → page break before, bold sans-serif font
   - Body → serif (Bookerly / Georgia / Garamond)
   - Code → monospace (Source Code Pro)
5. **Export print-ready PDF**: `File → Export → Create PDF` → quality "Standard" or "Print" (300 DPI)

Save to `build/manuscript-print.pdf`.

Time estimate: ~2–3 hours of Word work for a 400-page book.

**Recommended alternatives** to skip Word:
- **Affinity Publisher** ($69 one-time): import DOCX, pro layout, export PDF/X-1a
- **LaTeX**: excellent typographic quality for those comfortable with it
- **Vellum** (macOS only, $250): drag-and-drop, for those who value speed

---

## KDP — Kindle Direct Publishing

### Account setup (one-time)

1. Create an account at https://kdp.amazon.com (free)
2. Tax info: W-8BEN if you reside outside the US
3. Bank account for royalties (IBAN works)
4. Author Central profile: https://author.amazon.com

### eBook upload

1. KDP dashboard → **+ Create** → **Kindle eBook**
2. **Book details**: copy from `AMAZON-LISTING.md` (see below)
3. **Content**:
   - Upload `build/manuscript.epub`
   - Upload cover JPEG 1600×2560 RGB
   - Online preview → verify navigation
4. **Rights and pricing**:
   - Primary market: Amazon.com (EN) or Amazon.it (IT)
   - Royalty: 70% (requires price in the $2.99–$9.99 range)
   - Price: $9.99 / €9.99 (sweet spot for 70% royalty)
5. **KDP Select**: No (wide distribution)
6. **DRM**: No
7. **Publish** → Amazon review 24–72 h

### Paperback upload

From the published eBook → **Create paperback** (inherits metadata):

1. **Print options**:
   - Trim size: 6" × 9"
   - Bleed: Yes
   - Paper: white or cream
   - Cover finish: matte or glossy
2. **Content**:
   - Upload `build/manuscript-print.pdf` (laid out in Word)
   - Upload cover PDF (KDP provides a template sized to your exact page count)
3. **ISBN**: Free KDP ISBN (KDP assigns one at no cost)
4. **Price**: $29.99 / €27.99 (calculate royalty with the KDP Pricing Calculator)
5. **Publish** → review 72 h

### AMAZON-LISTING.md file

Create this file with all copy-pasteable metadata:

```markdown
# Amazon KDP Listing

## Title
[Your title]

## Subtitle
[Your compelling subtitle]

## Author
[Your name]

## Description (HTML, max ~4000 char)
<h2>Hook in 2-3 lines</h2>
<p>Book description...</p>
<h2>What you'll learn</h2>
<ul><li>Bullet 1</li>...</ul>
...

## Categories (2 max)
1. [Primary category]
2. [Secondary category]

## Keywords (7 max)
[keyword 1]
[keyword 2]
...

## Pricing
eBook: $9.99
Paperback: $29.99
```

For a complete version, see the `AMAZON-LISTING.md` file in the original Claude Code book repo.

---

## Pricing strategies

| Tier | Range | Royalty | When to use |
|---|---|---|---|
| **Low eBook** | $0.99 – $2.98 | 35% | Promotional launch, fast volume |
| **Standard eBook** | $2.99 – $9.99 | **70%** ⭐ | Default for tech books — sweet spot |
| **Premium eBook** | $10+ | 35% | Reference bible, complete edition, niche audience |
| **Paperback** | POD cost + $5–10 margin | varies | Standard for tech books |
| **Hardcover** | POD cost + $10–15 margin | varies | Collector's edition |

Real-world example: for a 390-page tech book:
- eBook $9.99 → $6.99 royalty per copy (70%)
- Paperback $29.99 → ~$8 royalty (KDP POD print cost ~$10)

---

## KDP categories

Each book can be assigned to **2 categories** at creation. After publishing you can request up to **10 categories** by contacting KDP Support — it's worth doing to maximize visibility.

Find the right category using the **Kindle Bestsellers**: browse https://www.amazon.com/Best-Sellers-Kindle-Store/zgbs/digital-text and see where your competitors are placed.

---

## Launch

Week 1: publish the primary edition (e.g., English).
Weeks 2–3: collect early reviews (ask 5–10 beta readers).
Week 4: launch the secondary edition (e.g., another language).
Months 2–3: AMS (Amazon Marketing Services) ads $10–30/day.
Month 6: analyze sales + consider a v1.1 update.

---

## See also

- `docs/05-multi-edition.md` — managing parallel IT + EN editions
- `templates/book/styles/metadata.yaml.template` — pandoc metadata template
- Original repo: https://github.com/hidran (look for Claude Code book companions)
