# Prompt template: Espansione capitolo sottile

Quando un capitolo scritto risulta sotto-target (es. 2500 parole su target 4500), espandilo con sezioni ex-novo invece di "padding" l'esistente.

---

## Variabili

- `<CHAPTER_PATH>` — file capitolo da espandere
- `<CURRENT_WORDS>` — word count attuale
- `<TARGET_WORDS>` — target da raggiungere
- `<MISSING_TOPICS>` — lista topic che mancano nel capitolo

---

## Prompt

```
Espandi il Capitolo in <CHAPTER_PATH> da <CURRENT_WORDS> a ~<TARGET_WORDS> parole
aggiungendo sezioni ex-novo.

## Regole

- DO NOT commit.
- DO NOT toccare file ad eccezione di <CHAPTER_PATH>.
- Preserva intatta la struttura esistente: opener, premessa, sezioni numerate esistenti,
  recap, esercizio, teaser prossimo capitolo.
- Aggiungi NUOVE sezioni numerate (es. se cap ha 1.1-1.3, aggiungi 1.4, 1.5, 1.6
  ed eventualmente sposta la sezione "Roadmap" a 1.7).

## Topic da coprire nelle nuove sezioni

<MISSING_TOPICS>

Esempi tipici di topic "ex-novo" che funzionano:
- Sezione "Troubleshooting" dentro un capitolo Installazione/Setup
- Sezione "Setup ottimale dell'ambiente" con consigli su terminale, shell, dotfiles
- Sezione "Walkthrough guidato" con un mini-esempio end-to-end
- Sezione "Confronto con alternative" che colloca il tool in contesto
- Sezione "Pattern avanzati" che aggiunge profondità
- Sezione "Pricing/costi" se rilevante
- Sezione "Pitfalls comuni" con 3-5 errori e fix

## Vincoli stilistici

- Stesso tono e voce delle sezioni esistenti
- Numerazione coerente
- Aggiungi 1-2 placeholder <!-- FIGURE: ... --> nelle nuove sezioni se servono
- Aggiungi 1 callout box per sezione nuova (es. ::: {.callout .callout-tip})
- Aggiorna il box "Cosa imparerai" all'inizio aggiungendo i nuovi outcome

## Status report

End con:
DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED

Poi:
1. Word count finale (e delta vs prima)
2. Nuove sezioni H2 aggiunte (con titoli)
3. Numero placeholder <!-- FIGURE: ... --> aggiunti
4. Conferma no git ops
5. Eventuali topic che NON sei riuscito a coprire (e perché)
```

---

## Esempio reale

Nel libro Claude Code originale, il Cap. 1 venne fuori a 2508 parole (target era 4500). Espansione applicata:

- **§ 1.2.1 Troubleshooting installazione** (~500 words) — EACCES, PATH, Apple Silicon, WSL
- **§ 1.4 Setup ottimale dell'ambiente** (~700 words) — iTerm2/Warp, zsh/fish, Starship, alias
- **§ 1.5 Il tuo primo prompt guidato** (~800 words) — walkthrough end-to-end argparse

Risultato: 2508 → 4744 parole (~18-20 pagine, dentro target).

Tempo: ~15 minuti per espansione + 1 build cycle.

---

## Quando NON espandere

Se l'articolo sorgente è davvero sottile e il capitolo è genuinamente breve (es. cap. intro di poche pagine), **accetta la lunghezza** invece di gonfiare.

Aggiorna invece lo spec del libro con range realistici per tipologia:
- Intro/light: 2500-3500 parole (10-14 pagine)
- Standard: 3500-5000 (14-20 pagine)
- Heavy: 5000-7000 (20-28 pagine)
- Cuore libro: 7000-9000 (28-36 pagine)
