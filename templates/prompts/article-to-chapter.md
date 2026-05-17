# Prompt template: Articoli → Capitolo del libro

Copia (e adatta) questo prompt per dispatchare un subagent che scrive un capitolo a partire dagli articoli sorgente.

---

## Variabili

- `<CHAPTER_NUM>` — numero del capitolo (es. 8)
- `<CHAPTER_TITLE>` — titolo (es. "Skills: da custom command a capacità riusabili")
- `<OUTPUT_PATH>` — es. `book/manuscript/parte-3/cap-08.md`
- `<SOURCE_ARTICLES>` — lista articoli sorgente (es. `articles/PE-08.md`, `articles/WS-02.md`)
- `<WORD_TARGET>` — range (es. "5000-6500" per heavy chapter)
- `<LANGUAGE>` — es. "italiano"

---

## Prompt

```
Scrivi il Capitolo <CHAPTER_NUM> del libro "<TITOLO_LIBRO>" — "<CHAPTER_TITLE>".

## Regole CRITICHE

- DO NOT commit. Solo write del file. L'orchestratore committerà.
- DO NOT toccare file ad eccezione di <OUTPUT_PATH>.
- <LANGUAGE>, seconda persona "tu", target sviluppatore intermedio.
- Usa la sintassi pandoc fenced div ::: {.chapter-opener} ecc. (vedi un capitolo esistente come template)
- Per le figure: inserisci placeholder HTML comment <!-- FIGURE: descrizione -->
  L'orchestratore li sostituirà con vere image refs dopo.

## Contesto

- Working directory: <PATH_LIBRO>
- Reference template (READ first): book/manuscript/parte-1/cap-01.md
- Articoli sorgente (READ all):
<SOURCE_ARTICLES>
- Target word count: <WORD_TARGET>
- Output: <OUTPUT_PATH>

## Outline del capitolo (struttura ANATOMIA STANDARD)

```markdown
# Capitolo <CHAPTER_NUM> — <CHAPTER_TITLE>

::: {.chapter-opener}
**Cosa imparerai**

- [Bullet 1: outcome principale del capitolo]
- [Bullet 2]
- [Bullet 3]
- [Bullet 4]
- [Bullet 5]
:::

::: {.chapter-opener}
**Prerequisiti**

- Capitoli precedenti completati (specifica quali)
- Eventuali strumenti/account richiesti
:::

## Premessa: [HOOK accattivante]
[~300 words ex-novo. Aggancio: perché questo capitolo? Cosa è in gioco? Connessione al capitolo precedente. Anticipo del valore.]

## <N>.1 [Prima sezione macro]
[Dal materiale degli articoli sorgente. Adatta tono. Aggiungi 1-2 placeholder <!-- FIGURE: ... --> dove serve.]

## <N>.2 [Seconda sezione macro]
[...]

...

## <N>.<X> [Ultima sezione macro]
[...]

::: {.chapter-recap}
**Riepilogo del capitolo**

- [Bullet 1]
- [Bullet 2]
- [Bullet 3]
- [Bullet 4]
- [Bullet 5]
:::

::: {.callout .callout-prompt}
**🔁 Prompt riusabile — [Nome breve]**

[Template di prompt copia-incollabile]
:::

### Esercizio proposto

[Walkthrough 4-6 step per applicare il capitolo. Tempo stimato. Branch GitHub di partenza.]

### Prossimo capitolo

[Teaser narrativo di 2-3 righe per il capitolo successivo.]
```

## Vincoli stilistici

- Sezioni H2 numerate (<N>.1, <N>.2, ...)
- Eventuali sotto-sezioni H3 con titolo discorsivo
- Code blocks con tag linguaggio (es. ```bash, ```python)
- Comandi inline in `inline code`
- Niente emoji nel corpo (eccetto callout labels predefiniti)

## Transformations table

| Da (in articoli) | A (nel libro) |
|---|---|
| "in questo video" / "in questa lezione" | "in questo capitolo" |
| "come vedete qui" | rimuovi (lettore non vede) |
| "vedremo nella prossima lezione" | "vedremo nel prossimo capitolo" |
| "Capitolo X" (se già nel testo) | mantieni |
| H2 "Cos'è X" (doppione del titolo capitolo) | rimuovi |

## Callout boxes

Quando appropriato (max 2-3 per capitolo), aggiungi:

- ::: {.callout .callout-tip} con "**💡 [Titolo breve]**" — trick/scorciatoia non ovvia
- ::: {.callout .callout-warning} con "**⚠️ [Titolo breve]**" — errore comune / rischio
- ::: {.callout .callout-deep-dive} con "**🔧 [Titolo breve]**" — approfondimento avanzato
- ::: {.callout .callout-example} con "**📝 [Titolo breve]**" — esempio concreto

## Status report

End con:
DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED

Poi:
1. Word count finale
2. Numero placeholder <!-- FIGURE: ... -->
3. Lista headings H2/H3
4. Conferma "no git ops" eseguite
5. Eventuali deviazioni dall'outline (e perché)
```

---

## Note d'uso

**Per heavy chapter (5000-7000 parole)**: targeta 6-8 sezioni H2 invece di 4-5.

**Per intro/light chapter (2500-3500 parole)**: 3-4 sezioni H2 sono OK.

**Articolo sottile?** Vedi `templates/prompts/chapter-expansion.md` per espandere ex-novo.

**Wave parallelo**: dispatcha più subagent in parallelo, ognuno scrive un capitolo diverso. NON committare in parallelo (race condition git).
