# 05 · Edizioni multilingua

Pubblicare la stessa opera in più lingue (es. IT + EN) condividendo asset (figure, build pipeline) e mantenendo manuscript separati.

---

## Struttura raccomandata

```
my-book/
├── book/                          ← edizione primaria (es. italiana)
│   ├── manuscript/
│   ├── figures/                   ← CANONICA: qui vivono le PNG reali
│   ├── styles/  (kindle.css + metadata.yaml IT)
│   ├── scripts/
│   └── build/
├── book-en/                       ← edizione secondaria (es. inglese)
│   ├── manuscript/                ← traduzioni
│   ├── figures/                   ← SYMLINK a ../book/figures/cap-NN
│   ├── styles/  (kindle.css + metadata.yaml EN)
│   ├── scripts/                   ← stessi script
│   └── build/
└── AMAZON-LISTING.md              ← metadata KDP per ENTRAMBE le edizioni
```

**Insight chiave**: le figure (screenshot) sono **language-neutral** nella maggioranza dei casi (terminali, codice, diagrammi). Non duplicarle: usa symlink.

---

## Setup edizione secondaria

```bash
cd my-book
mkdir -p book-en/manuscript/{00-front-matter,parte-1,parte-2,zz-back-matter}
mkdir -p book-en/{figures,styles,scripts,build}

# Copia gli script (sono identici)
cp book/scripts/*.sh book-en/scripts/

# Copia CSS (uguale per entrambe le edizioni)
cp book/styles/kindle.css book-en/styles/

# Metadata EN: copia + traduci titolo/sottotitolo/descrizione
cp book/styles/metadata.yaml book-en/styles/metadata.yaml
# Apri ed edita: title, subtitle, language: en-US, etc.

# Figure: symlink (NO copia)
for n in $(seq -f "%02g" 1 16); do
  ln -s "../../book/figures/cap-$n" "book-en/figures/cap-$n"
done

# .gitignore
cp book/.gitignore book-en/.gitignore

# Git init separato
cd book-en && git init && git config user.name "..." && git config user.email "..."
xattr -w com.dropbox.ignored 1 .git  # se in Dropbox
```

---

## Workflow traduzione

Usa subagent paralleli (vedi `templates/prompts/translate-chapter.md`).

Wave tipico per 16 capitoli + front matter + 5 appendici:

| Wave | Contenuti | Subagent paralleli | Tempo |
|---|---|---|---|
| 1 | Front matter + cap. 1-3 | 4 | ~10 min |
| 2 | Cap. 4-7 | 4 | ~15 min |
| 3 | Cap. 8-11 | 4 | ~20 min |
| 4 | Cap. 12-15 | 4 | ~20 min |
| 5 | Cap. 16 + appendici A+B + C+D+E | 3 | ~15 min |
| 6 | Build EPUB + DOCX | sequenziale | ~5 min |

**Totale**: ~85 min per 98k parole IT → EN.

---

## Cose da tradurre (e cose da NON tradurre)

### Tradurre

- Tutto il testo prosa
- Headings di sezione: "Premessa" → "Setting the stage"
- Box labels: "Cosa imparerai" → "What you'll learn", "Suggerimento" → "Tip", etc.
- Caption figure: "Figura 1.1: ..." → "Figure 1.1: ..."
- Cross-references: "Cap. 8" → "Chapter 8", "Parte V" → "Part V"
- Italian prompts inside code blocks (es. "Leggi il file e dimmi..." → "Read the file and tell me...")
- Currency: €/$ secondo target market
- Titoli e descrizioni KDP

### NON tradurre

- Comandi shell (`npm install`, `git commit`, `claude /help`, ecc.)
- Nomi di file e path (`src/index.js`, `package.json`, ecc.)
- Identificatori di codice (variabili, funzioni)
- Nomi prodotti (`Claude Code`, `Anthropic`, `Photogallery`, `Fluent AI Pro`, `NestJS`, etc.)
- Image refs (path `figures/cap-NN/...` resta uguale)
- Pandoc fenced div classes (`::: {.chapter-opener}`)

---

## Convenzioni per coppie IT/EN

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

Memorizza questa tabella nel prompt template e i traduttori saranno consistent.

---

## Build separato per edizione

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

I due EPUB sono indipendenti. Ognuno ha proprio metadata, proprio TOC, propria descrizione.

---

## KDP: 2 ASIN separati

Amazon richiede un ASIN diverso per ogni lingua. Conseguenze:

- ❌ NON puoi caricare due lingue sotto un singolo prodotto
- ✅ Crea 2 listing separati con stessa cover (testo localizzato)
- ✅ Linka i due ASIN via "Other formats" nella product page
- ✅ Pricing indipendente per ogni edizione

### Recensioni separate

Le recensioni su Amazon.it (IT edition) non appaiono su Amazon.com (EN edition) e viceversa. È un disincentivo a tradurre se hai già 100 recensioni 5★ in IT — ma è anche un'opportunità di "ripartire pulito" sul mercato EN dove magari ti reposizioni.

### Author Central

Amazon.com (US/UK) e Amazon.it (IT) hanno **due Author Central separati**. Configura entrambi con bio nelle lingue native.

---

## Discrepanze culturali

Adatta, non solo traduci:

- **Currency**: usa $ per US, € per IT/EU, £ per UK
- **Date format**: ISO 2026-05-18 funziona universalmente; evita MM/DD/YYYY (US) vs DD/MM/YYYY (IT)
- **Esempi business**: nomi di aziende reali → usa quelle riconosciute dal target market (es. "Spryker" è noto in DACH/IT enterprise, meno in US — sostituisci con "Shopify" o "Stripe" per US)
- **Pricing**: $9.99 (US) ≠ €9.99 (IT) ≠ £8.99 (UK). KDP gestisce conversion automatic ma settare a mano dà royalty migliori
- **Idioms**: "menare il can per l'aia" → "beat around the bush", "fare i conti con" → "deal with"

---

## Quando vale la pena tradurre

Tradurre 98k parole costa:
- ~$30-50 in API calls (Sonnet)
- ~15-30 ore di review umana (per produzione qualità)
- ~$200-400 per native editor pass (raccomandato per EN)

**ROI tipico**:
- Mercato IT: 10-30 copie/mese → €70-200 royalty
- Mercato US: 30-100 copie/mese → $200-700 royalty
- Mercato UK: 10-30 copie/mese → £60-180 royalty

In un anno di vendite la sola edizione US ripaga di gran lunga il costo di traduzione.

**NON tradurre** se:
- Audience è esclusivamente di nicchia in 1 lingua
- Il contenuto è troppo localizzato (es. tax/legal per IT)
- Manca tempo per gestire 2 author profiles, 2 review streams, 2 KDP pages

---

## Vedi anche

- `templates/prompts/translate-chapter.md` — prompt template per traduzione
- `docs/04-build-and-publish.md` — KDP setup
