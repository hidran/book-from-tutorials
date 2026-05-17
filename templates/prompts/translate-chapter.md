# Prompt template: Traduzione capitolo IT → EN (o qualunque coppia)

Per dispatchare subagent paralleli che traducono capitoli da una lingua all'altra.

---

## Variabili

- `<SOURCE_LANG>` — es. "Italian"
- `<TARGET_LANG>` — es. "American English"
- `<SOURCE_PATH>` — es. `book/manuscript/parte-3/cap-08.md`
- `<TARGET_PATH>` — es. `book-en/manuscript/parte-3/cap-08.md`
- `<CHAPTER_TITLE_EN>` — titolo capitolo nella lingua target

---

## Prompt

```
Traduci il Capitolo da <SOURCE_PATH> in <TARGET_LANG> e salvalo in <TARGET_PATH>.

## Regole CRITICHE

- DO NOT commit.
- DO NOT toccare alcun file ad eccezione di <TARGET_PATH>.
- Preserva TUTTA la struttura markdown/pandoc: fenced divs ::: {.chapter-opener},
  callouts ::: {.callout .callout-*}, image refs ![](figures/...){#fig:N-N width=100%},
  italic captions, code blocks ```.
- I path delle immagini restano IDENTICI (le figure sono condivise tra edizioni via symlink).
  Traduci SOLO le caption (es. "Figura 1.1: ..." → "Figure 1.1: ...").

## Titolo capitolo nella lingua target

# <CHAPTER_TITLE_EN>

## Translation hints (sostituisci secondo necessità)

| Source | Target |
|---|---|
| Premessa: [titolo] | Setting the stage: [title] |
| [Numero].X [titolo] | [Number].X [title] |
| Esercizio proposto | Exercise |
| Prossimo capitolo | Next chapter |
| Tempo stimato | Estimated time |
| Branch GitHub di partenza | Starter GitHub branch |
| Capitolo N | Chapter N |
| Parte N | Part N |

## Callout box labels (translate)

| Source | Target |
|---|---|
| 💡 Suggerimento | 💡 Tip |
| ⚠️ Attenzione | ⚠️ Warning |
| 🔧 Sotto il cofano | 🔧 Under the hood |
| 📝 Esempio | 📝 Example |
| 🔁 Prompt riusabile | 🔁 Reusable prompt |
| Cosa imparerai | What you'll learn |
| Prerequisiti | Prerequisites |
| Riepilogo del capitolo | Chapter summary |

## Cosa NON tradurre

- Comandi shell (`npm install`, `git commit`, `claude /help`, ecc.)
- Nomi di file e path (`src/index.js`, ecc.)
- Identificatori di codice (variabili, funzioni, classi)
- Nomi prodotti / framework (NestJS, Claude Code, Anthropic, Photogallery, ecc.)
- Pandoc fenced div classes
- Image refs (path resta identico)

## Cosa SÌ tradurre

- Tutta la prosa
- Commenti dentro i code blocks (se in lingua sorgente)
- Prompt esempio dentro i code blocks (se sono istruzioni a Claude in lingua sorgente)
- Caption delle figure
- Cross-references ("Cap. 8" → "Chapter 8")
- Currency: € → $ per US, £ per UK
- Date format: usa ISO 2026-05-18 (universale)

## Adattamenti culturali

- Idiomi: traduci natural, non letterale
- Esempi business: se nomi di aziende sono troppo localizzati per il target market,
  sostituiscili con equivalenti riconoscibili (es. "Spryker" → "Shopify" per US)
- Currency: $9.99 per US, €9.99 per IT, £8.99 per UK
- Misure: usa unità SI universalmente o adatta a target (oz/lb per US, kg/g per resto)

## Tono

- <TARGET_LANG>, seconda persona ("you")
- Stessa voce e ritmo del sorgente
- NON rendere "più formale" — preserva il registro originale
- NON espandere o tagliare contenuto

## Status report

End con:
DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED

Poi:
1. Word count del file scritto (e ratio vs sorgente: tipicamente EN è 5-10% più corto di IT)
2. Conferma no git ops
3. Conferma solo il file target è stato toccato
4. Eventuali adattamenti culturali fatti (lista)
5. Decisioni di traduzione non ovvie (es. "tradotto X come Y perché...")
```

---

## Dispatch in parallelo

Per tradurre 16 capitoli + front matter + 5 appendici:

```
Wave 1: 4 subagent in parallelo → front matter + cap 1 + cap 2 + cap 3
Wave 2: 4 subagent → cap 4-7
Wave 3: 4 subagent → cap 8-11
Wave 4: 4 subagent → cap 12-15
Wave 5: 4 subagent → cap 16 + appendici A + B + (C+D+E insieme)
```

Tempo totale: ~85 min per 98k parole IT → EN (vs ~15h sequenziale).

---

## Quality check post-traduzione

Prima di committare:

1. **Build EPUB EN** e verifica `epubcheck` → 0 errori
2. **Read random sample** (3 capitoli): traduzione fluente? Idiomi naturali?
3. **Grep for unfinished**: cerca rimaste in lingua sorgente
   ```bash
   # Cerca parole italiane comuni in book-en/
   grep -rn '\bcapitolo\b\|\bperché\b\|\busiamo\b' book-en/manuscript/ | head
   ```
4. **Native editor pass** (opzionale ma raccomandato per pubblicazione): ~$200-400 su Reedsy/Upwork per pass su tutto il libro
