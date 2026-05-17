# 02 · Scrivere capitoli con Claude Code

Il cuore del workflow: come usare Claude Code (e i suoi subagent) per trasformare articoli grezzi in capitoli da libro.

---

## Anatomia di un capitolo

Ogni capitolo del libro segue una struttura ricorrente (~20-25 pagine, 4000-5000 parole tipiche):

```
┌─────────────────────────────────────────────────┐
│ 1. APERTURA (1 pagina)                          │
│    ├─ Titolo capitolo                           │
│    ├─ Box "Cosa imparerai" (3-5 bullet)         │
│    └─ Box "Prerequisiti"                        │
├─────────────────────────────────────────────────┤
│ 2. INTRO NARRATIVA (1 pagina, ex-novo)          │
│    Aggancio al cap. precedente + perché ora     │
├─────────────────────────────────────────────────┤
│ 3. CORPO (15-20 pagine — articoli adattati)     │
│    Sezioni H2 numerate (X.1, X.2, ...)          │
│    con screenshot, snippet, callout             │
├─────────────────────────────────────────────────┤
│ 4. RECAP (1 pagina, ex-novo)                    │
│    Box "Riepilogo" + box "Prompt riusabile"     │
├─────────────────────────────────────────────────┤
│ 5. ESERCIZIO PROPOSTO (1 pagina, ex-novo)       │
│    Compito guidato + branch GitHub di partenza  │
├─────────────────────────────────────────────────┤
│ 6. PROSSIMO CAPITOLO (½ pagina)                 │
│    Teaser di transizione                        │
└─────────────────────────────────────────────────┘
```

I punti 2, 4, 5, 6 sono **ex-novo** (Claude li scrive da zero). Il punto 3 è l'**adattamento** degli articoli sorgente.

---

## Pattern Subagent-Driven

Per scrivere N capitoli velocemente, usa **subagent paralleli**.

Vincolo importante: ogni subagent scrive un file DIVERSO e NON committa. L'orchestratore committa in batch alla fine.

### Wave dispatcher

```bash
# In una sessione Claude Code interattiva (oppure scripted via Claude API):
```

```text
Dispatcha 4 subagent in parallelo. Ognuno scrive UN capitolo specifico:

Subagent 1: scrivi book/manuscript/parte-1/cap-02.md leggendo articles/PE-02.md
  Target: 4000-5000 parole. Anatomia standard.
  NON committare.

Subagent 2: scrivi book/manuscript/parte-2/cap-03.md leggendo articles/PE-02.md (parte CSV) + articles/PE-03.md
  Target: 4500-5500 parole.
  NON committare.

Subagent 3: scrivi book/manuscript/parte-2/cap-04.md leggendo articles/WS-01.md
  Target: 3500-4500 parole.
  NON committare.

Subagent 4: scrivi book/manuscript/parte-2/cap-05.md leggendo articles/PE-04.md + articles/PE-09.md
  Target: 4500-5500 parole.
  NON committare.

Dopo che tutti hanno finito, io committerò in un singolo commit "feat(plan-2): write 4 chapters".
```

### Tempo di esecuzione

Per wave di 4 capitoli:
- Sequenziale: ~20-30 min
- Parallelo (4 subagent simultanei): ~5-10 min

Per 16 capitoli in 4 wave: **~30 min in parallelo** vs ~2 ore sequenziale.

---

## Prompt template per scrittura capitolo

Usa `templates/prompts/article-to-chapter.md` come base. Adatta per il tuo capitolo specifico.

Elementi chiave del prompt:

1. **Critical rules**: DO NOT commit, file path target esplicito
2. **Sources**: lista articoli da leggere con path completi
3. **Target word count**: con range realistico per tipo di capitolo
4. **Outline obbligatorio**: opener + premessa + N sezioni numerate + recap + esercizio + teaser
5. **Translation table**: come adattare "in questa lezione/video" → "in questo capitolo"
6. **Callout labels**: 💡 Suggerimento, ⚠️ Attenzione, 🔁 Prompt riusabile
7. **Code blocks**: preservare snippet di codice intatti
8. **Status reporting**: format DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED

---

## Gestione articoli "sottili"

Problema reale: alcuni articoli sorgente sono 1300-1500 parole. Per un capitolo da 4500 parole, mancano ~3000 parole.

**Strategie:**

1. **Espansione ex-novo** (raccomandato per cap. intro)
   - Aggiungi sezioni che l'articolo non copre: troubleshooting, setup ottimale, walkthrough guidato
   - Usa il prompt `templates/prompts/chapter-expansion.md`
   - Tipico: aggiungi 3 sezioni × 600 parole = +1800 parole

2. **Fusione di articoli adiacenti**
   - Es. cap-02 = PE-02 (parte generale) + PE-03 (parte introduttiva)
   - Riduce # capitoli ma li rende più ricchi

3. **Accetta capitoli più corti**
   - Aggiorna lo spec con range realistici per tipologia:
     - Intro/light: 2500-3500 parole (10-14 pagine)
     - Standard: 3500-5000 (14-20 pagine)
     - Heavy: 5000-7000 (20-28 pagine)
     - Cuore libro: 7000-9000 (28-36 pagine)

---

## Iterazione: cosa fare se un capitolo non convince

Pattern visto nel libro originale: Cap. 1 venne fuori a 2500 parole (target era 4500), il lettore di prova chiese "solo 11 pagine?".

Soluzione applicata:
1. Identificato: PE-01 era sottile, mancavano sezioni Installazione + Setup ambiente + Primo prompt guidato
2. Aggiunte 3 sezioni nuove (~2000 parole) con un singolo prompt al subagent
3. Re-build + QA Kindle Previewer → 18-20 pagine
4. ✓ accettato

Tempo: ~15 minuti per espansione, +1 build cycle.

Lezione: **iterare in fretta**, non aspettare di avere "il piano perfetto".

---

## Tono e voce

Calibra il prompt iniziale per il tono che vuoi:

| Tono | Quando | Esempio prompt |
|---|---|---|
| Diretto, seconda persona | Tutorial tech intermediate | "Italiano, seconda persona 'tu', sviluppatore intermedio" |
| Più formale, terza persona | Manuale enterprise | "Italiano formale, terza persona, professionista" |
| Casual, prima persona inclusiva | Self-help, opinione | "Italiano, mix prima/seconda persona, conversazionale" |

Nel libro Claude Code abbiamo usato il primo. Mantenere coerenza è critico: se in cap. 3 cambi tono, il lettore lo sente.

---

## Anti-pattern da evitare

- ❌ **Commit per ogni capitolo da subagent in parallelo** → race condition git
- ❌ **Subagent legge "tutto il progetto"** → tokens sprecati, allucinazioni
- ❌ **Prompt senza word count target** → capitoli incoerenti per dimensione
- ❌ **Saltare il "no fai" nel prompt** ("non scrivere codice di esempio inventato") → invenzioni di stack che non esistono
- ❌ **Validare solo a fine produzione** → bug pandoc scoperti a fine 16 capitoli
- ✅ **Validare cumulativo dopo ogni wave** → fix immediati

---

## Approvazione umana

L'AI scrive. **Tu** decidi se va bene. Punti di review obbligatori:

1. **Dopo il primo capitolo pilota** → verifica anatomia + tono
2. **Dopo ogni wave di scrittura** → leggi i capitoli generati, segnala problemi
3. **Prima del build finale** → cumulative read
4. **Dopo QA Kindle Previewer** → leggi su dispositivo simulato

Non saltare questi checkpoint per "andare più veloce". Il costo di un libro scritto male è recensioni a 1 stella per la vita.

---

## Vedi anche

- `templates/prompts/article-to-chapter.md` — prompt template completo
- `templates/prompts/chapter-expansion.md` — prompt per estendere capitoli sottili
- `templates/prompts/translate-chapter.md` — prompt per traduzione IT → EN
