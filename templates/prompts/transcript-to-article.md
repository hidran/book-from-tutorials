# Prompt template: Trascrizione → Articolo Markdown

Copia questo prompt in Claude Code per trasformare una trascrizione grezza in un articolo Markdown leggibile.

---

## Variabili da sostituire

- `<TRANSCRIPT_PATH>` — path del file `.txt` della trascrizione
- `<OUTPUT_PATH>` — path dove salvare l'articolo `.md`
- `<TITLE_HINT>` — titolo provvisorio dell'articolo (sarà l'H1)
- `<LANGUAGE>` — lingua dell'articolo (es. "italiano", "American English")

---

## Prompt

```
Trasforma la trascrizione grezza in <TRANSCRIPT_PATH> in un articolo Markdown pulito
e leggibile, e salvalo in <OUTPUT_PATH>.

## Regole di trasformazione

1. RIMUOVI:
   - Disfluenze del parlato ("ehm", "diciamo", "allora", "ok", ripetizioni)
   - Frasi mai concluse o che cambiano direzione a metà
   - Riferimenti a slide non visibili al lettore ("come vedete qui", "in questa schermata")
   - Sigle / saluti / chiusure tipiche dei video ("ciao a tutti", "ci vediamo nella prossima")

2. CONSERVA:
   - Comandi shell, snippet di codice, output di terminale (precisi al carattere)
   - Esempi concreti
   - Nomi propri (prodotti, persone, framework)
   - L'opinione e le decisioni dell'autore
   - Aneddoti che danno valore

3. RISTRUTTURA:
   - Aggiungi heading H2 per ogni macro-argomento (3-7 sezioni per articolo)
   - Spezza paragrafi lunghi in paragrafi 2-4 righe
   - Numero step in liste ordinate quando ci sono passaggi sequenziali
   - Bullet list per enumerazioni
   - Inline code per nomi di file, comandi, identificatori

4. TONO:
   - <LANGUAGE>, seconda persona ("tu apri il terminale", non "si apre il terminale")
   - Diretto e pratico, senza fronzoli
   - Conserva la voce dell'autore (non rendere "accademico" un autore che è "diretto")

## Struttura dell'articolo

```markdown
---
title: "<TITLE_HINT>"
subtitle: "[se utile]"
author: "[nome autore]"
---

# <TITLE_HINT>

## Introduzione

[1-2 paragrafi: cosa fa questo articolo, cosa imparerà il lettore]

## [Sezione 1: macro-argomento]

[corpo]

## [Sezione 2: macro-argomento]

[corpo]

...

## Takeaway

- [bullet 1]
- [bullet 2]
- [bullet 3]

---
*Prossimo argomento: [accenno breve]*
```

## Vincoli

- Lunghezza target: 1200-1800 parole (depending on transcript length)
- Non inventare contenuto che non è nella trascrizione
- Se la trascrizione contiene errori tecnici evidenti (es. "Phyton" invece di "Python"),
  correggili silenziosamente
- Se trovi qualcosa di ambiguo, contrassegnalo con `<!-- TODO: verificare -->`

## Output

Salva direttamente in <OUTPUT_PATH>. Riporta:
- Word count finale
- Numero sezioni H2
- Eventuali TODO inseriti
- Suggerimento per il prossimo articolo (cosa potrebbe seguire logicamente)
```

---

## Note d'uso

**Per Whisper output**: Whisper tipicamente produce testo senza punteggiatura forte. Aggiungi al prompt: "Aggiungi punteggiatura corretta dove manca (Whisper la omette spesso)".

**Per Audiate output**: Audiate divide bene in frasi ma può lasciare disfluenze. Aggiungi: "Rimuovi disfluenze ma rispetta la struttura delle frasi già presente".

**Quality check**: dopo che Claude scrive l'articolo, **leggilo tutto**. Se in 5 minuti di lettura non trovi nulla che ti sembri "non come l'avresti detto tu", l'articolo è pronto. Se trovi 3+ cose, dispatcha un round di refinement con feedback specifico.
