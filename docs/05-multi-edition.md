# 05 · Multi-Language Editions

Publish the same work in multiple languages (e.g., IT + EN) by sharing assets (figures, build pipeline) while keeping separate manuscripts.

---

## Recommended structure

```
my-book/
├── book/                          ← primary edition (e.g., Italian)
│   ├── manuscript/
│   ├── figures/                   ← CANONICAL: this is where real PNGs live
│   ├── styles/  (kindle.css + metadata.yaml IT)
│   ├── scripts/
│   └── build/
├── book-en/                       ← secondary edition (e.g., English)
│   ├── manuscript/                ← translations
│   ├── figures/                   ← SYMLINK to ../book/figures/cap-NN
│   ├── styles/  (kindle.css + metadata.yaml EN)
│   ├── scripts/                   ← same scripts
│   └── build/
└── AMAZON-LISTING.md              ← KDP metadata for BOTH editions
```

**Key insight**: figures (screenshots) are **language-neutral** in the vast majority of cases (terminals, code, diagrams). Don't duplicate them — use symlinks.

---

## Secondary edition setup

```bash
cd my-book
mkdir -p book-en/manuscript/{00-front-matter,parte-1,parte-2,zz-back-matter}
mkdir -p book-en/{figures,styles,scripts,build}

# Copy the scripts (they are identical)
cp book/scripts/*.sh book-en/scripts/

# Copy CSS (same for both editions)
cp book/styles/kindle.css book-en/styles/

# EN metadata: copy + translate title/subtitle/description
cp book/styles/metadata.yaml book-en/styles/metadata.yaml
# Open and edit: title, subtitle, language: en-US, etc.

# Figures: symlink (NO copy)
for n in $(seq -f "%02g" 1 16); do
  ln -s "../../book/figures/cap-$n" "book-en/figures/cap-$n"
done

# .gitignore
cp book/.gitignore book-en/.gitignore

# Separate git init
cd book-en && git init && git config user.name "..." && git config user.email "..."
xattr -w com.dropbox.ignored 1 .git  # if on Dropbox
```

---

## Translation workflow

Use parallel subagents (see `templates/prompts/translate-chapter.md`).

Typical wave breakdown for 16 chapters + front matter + 5 appendices:

| Wave | Contents | Parallel subagents | Time |
|---|---|---|---|
| 1 | Front matter + ch. 1-3 | 4 | ~10 min |
| 2 | Ch. 4-7 | 4 | ~15 min |
| 3 | Ch. 8-11 | 4 | ~20 min |
| 4 | Ch. 12-15 | 4 | ~20 min |
| 5 | Ch. 16 + appendices A+B + C+D+E | 3 | ~15 min |
| 6 | Build EPUB + DOCX | sequential | ~5 min |

**Total**: ~85 min for 98k words IT → EN.

---

## What to translate (and what NOT to translate)

### Translate

- All prose text
- Section headings: "Premessa" → "Setting the stage"
- Box labels: "Cosa imparerai" → "What you'll learn", "Suggerimento" → "Tip", etc.
- Figure captions: "Figura 1.1: ..." → "Figure 1.1: ..."
- Cross-references: "Cap. 8" → "Chapter 8", "Parte V" → "Part V"
- Italian prompts inside code blocks (e.g., "Leggi il file e dimmi..." → "Read the file and tell me...")
- Currency: €/$ according to target market
- KDP titles and descriptions

### Do NOT translate

- Shell commands (`npm install`, `git commit`, `claude /help`, etc.)
- File names and paths (`src/index.js`, `package.json`, etc.)
- Code identifiers (variables, functions)
- Product names (`Claude Code`, `Anthropic`, `Photogallery`, `Fluent AI Pro`, `NestJS`, etc.)
- Image refs (path `figures/cap-NN/...` stays the same)
- Pandoc fenced div classes (`::: {.chapter-opener}`)

---

## Conventions for IT/EN pairs

| Italiano | American English |
|---|---|
| Capitolo N | Chapter N |
| Parte N | Part N |
| Premessa | Setting the stage |
| Cosa imparerai | What you'll learn |
| Prerequisiti | Prerequisites |
| Riepilogo del capitolo | Chapter summary |
| Esercizio proposto | Exercise |
| Prossimo capitolo | Next chapter |
| Branch GitHub di partenza | Starter GitHub branch |
| Tempo stimato | Estimated time |
| 💡 Suggerimento | 💡 Tip |
| ⚠️ Attenzione | ⚠️ Warning |
| 🔧 Sotto il cofano | 🔧 Under the hood |
| 📝 Esempio | 📝 Example |
| 🔁 Prompt riusabile | 🔁 Reusable prompt |

Memorize this table in the prompt template and your translators will stay consistent.

---

## Separate build per edition

```bash
# IT
cd book
./scripts/build-epub.sh
./scripts/validate.sh

# EN
cd ../book-en
./scripts/build-epub.sh
./scripts/validate.sh
```

The two EPUBs are independent. Each has its own metadata, its own TOC, its own description.

---

## KDP: 2 separate ASINs

Amazon requires a different ASIN for each language. Consequences:

- ❌ You CANNOT upload two languages under a single product
- ✅ Create 2 separate listings with the same cover (localized text)
- ✅ Link the two ASINs via "Other formats" on the product page
- ✅ Independent pricing for each edition

### Separate reviews

Reviews on Amazon.it (IT edition) do not appear on Amazon.com (EN edition) and vice versa. This is a disincentive to translate if you already have 100 five-star reviews in Italian — but it's also an opportunity to "start fresh" in the EN market where you might reposition yourself.

### Author Central

Amazon.com (US/UK) and Amazon.it (IT) have **two separate Author Central accounts**. Configure both with bios in the native languages.

---

## Cultural discrepancies

Adapt, don't just translate:

- **Currency**: use $ for US, € for IT/EU, £ for UK
- **Date format**: ISO 2026-05-18 works universally; avoid MM/DD/YYYY (US) vs DD/MM/YYYY (IT)
- **Business examples**: real company names → use ones recognized by the target market (e.g., "Spryker" is well known in DACH/IT enterprise, less so in the US — replace with "Shopify" or "Stripe" for US)
- **Pricing**: $9.99 (US) ≠ €9.99 (IT) ≠ £8.99 (UK). KDP handles conversion automatically but setting prices manually gives better royalties
- **Idioms**: "menare il can per l'aia" → "beat around the bush", "fare i conti con" → "deal with"

---

## When translation is worth it

Translating 98k words costs:
- ~$30-50 in API calls (Sonnet)
- ~15-30 hours of human review (for production quality)
- ~$200-400 for a native editor pass (recommended for EN)

**Typical ROI**:
- IT market: 10-30 copies/month → €70-200 royalty
- US market: 30-100 copies/month → $200-700 royalty
- UK market: 10-30 copies/month → £60-180 royalty

Over a year of sales, the US edition alone will more than cover the cost of translation.

**Do NOT translate** if:
- Your audience is exclusively niche in 1 language
- The content is too localized (e.g., tax/legal for IT)
- You don't have time to manage 2 author profiles, 2 review streams, 2 KDP pages

---

## See also

- `templates/prompts/translate-chapter.md` — prompt template for translation
- `docs/04-build-and-publish.md` — KDP setup
