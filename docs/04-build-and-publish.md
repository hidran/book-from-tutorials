# 04 · Build & Publish

Da markdown a EPUB validato + DOCX paperback + upload KDP.

---

## Pipeline build

```
manuscript/*.md  ──┐
                   │  pandoc 3.x
styles/kindle.css ─┤  +
                   │  styles/metadata.yaml
figures/cap-*/*.png─┘
                   │
                   ▼
              ┌─────────┐
              │ EPUB3   │  ← per Kindle
              │ DOCX    │  ← per paperback (impagina in Word)
              └─────────┘
                   │
                   ▼
              epubcheck → 0 errors / 0 warnings
                   │
                   ▼
              Kindle Previewer 3 (QA manuale)
                   │
                   ▼
              KDP upload
```

---

## Build EPUB

```bash
./scripts/build-epub.sh
```

Lo script:
1. Trova tutti i `.md` sotto `manuscript/`
2. Li ordina alfabeticamente (per questo abbiamo `00-front-matter/` e `zz-back-matter/`)
3. Li passa a pandoc con `--metadata-file=styles/metadata.yaml` e `--css=styles/kindle.css`
4. Produce `build/manuscript.epub`

### Sorting di pandoc

Pandoc concatena i file nell'ordine in cui glieli passi. Lo script usa `find ... | sort`, che ordina ASCII-betico.

| Prefisso cartella | Sort ASCII | Posizione nel libro |
|---|---|---|
| `00-front-matter/` | per primo | inizio (prefazione, etc.) |
| `parte-1/` ... `parte-5/` | in mezzo | capitoli |
| `zz-back-matter/` | per ultimo | fine (appendici) |

**Bug comune**: chiamare la cartella `99-back-matter/`. ASCII `9` (0x39) < `p` (0x70), quindi `99-back-matter` finisce PRIMA di `parte-1/` → appendici a inizio libro. Usa `zz-` per sicurezza.

---

## Validazione

```bash
./scripts/validate.sh
```

Esegue `epubcheck` (il validator ufficiale W3C / IDPF). Output desiderato:

```
Messages: 0 fatals / 0 errors / 0 warnings / 0 infos
✓ EPUB valido — pronto per upload KDP
```

**Errori più comuni** e come correggerli:

| Errore | Causa | Fix |
|---|---|---|
| `FATAL: The string "--" is not permitted within comments` | Commento HTML con `--` (es. `<!-- foo --bar -->`) | Riformula evitando doppio dash |
| `ERROR: Referenced resource ... could not be found` | Image ref a file inesistente | Verifica `figures/cap-NN/...` esista |
| `ERROR: Fragment identifier is not defined` | `[#fig:5]` ma figura 5 non esiste | Aggiungi figura o rimuovi link |
| `WARNING: 'a' tag uses 'name' attribute` | Pandoc vecchio | Upgrade a pandoc 3.x |

---

## Build DOCX (paperback)

```bash
./scripts/build-paperback.sh
```

Produce `build/manuscript.docx`. **Non è print-ready** — è il punto di partenza per impagination in Word.

### Impaginazione Word per KDP 6×9"

Apri il DOCX e:

1. **Page setup**: `Layout → Size → Custom → 6" × 9"` (15.24 × 22.86 cm)
2. **Margini**: `Layout → Margins → Custom`:
   - Interno (gutter): 0.75"
   - Esterno: 0.5"
   - Sopra: 0.5"
   - Sotto: 0.5"
3. **Headers/footers**:
   - Numero pagina in basso al centro
   - Header sinistra (pagine pari): nome libro
   - Header destra (pagine dispari): titolo capitolo
   - Diversa per prima pagina (frontespizio senza numero)
4. **Stili paragrafo**:
   - H1 (capitoli) → page break prima, font sans-serif bold
   - Body → serif (Bookerly / Georgia / Garamond)
   - Code → monospace (Source Code Pro)
5. **Export**: `File → Export → Create PDF` → quality "Standard" o "Print" (300 DPI)

Salva in `build/manuscript-print.pdf`.

Tempo: ~2-3 ore di lavoro Word per un libro da 400 pagine.

**Alternative consigliate** per saltare Word:
- **Affinity Publisher** ($69 una tantum): import DOCX, layout pro, export PDF/X-1a
- **LaTeX**: per chi ha confidenza, qualità tipografica eccelsa
- **Vellum** (solo macOS, $250): drag-and-drop, per chi paga la velocità

---

## KDP — Kindle Direct Publishing

### Account setup (una tantum)

1. Crea account su https://kdp.amazon.com (free)
2. Tax info: W-8BEN se residente fuori USA
3. Bank account per royalty (IBAN funziona)
4. Author Central profilo: https://author.amazon.com

### Upload eBook

1. KDP dashboard → **+ Create** → **Kindle eBook**
2. **Dettagli libro**: copia da `AMAZON-LISTING.md` (vedi sotto)
3. **Contenuto**:
   - Upload `build/manuscript.epub`
   - Upload cover JPEG 1600×2560 RGB
   - Preview online → verifica navigazione
4. **Diritti e prezzi**:
   - Mercato primario: Amazon.com (EN) o Amazon.it (IT)
   - Royalty: 70% (richiede prezzo nel range $2.99-$9.99)
   - Prezzo: $9.99 / €9.99 (sweet spot 70% royalty)
5. **KDP Select**: No (wide distribution)
6. **DRM**: No
7. **Pubblica** → review Amazon 24-72h

### Upload paperback

Dal libro eBook pubblicato → **Create paperback** (eredita metadata):

1. **Print options**:
   - Trim size: 6" × 9"
   - Bleed: Yes
   - Paper: white o cream
   - Cover finish: matte o glossy
2. **Contenuto**:
   - Upload `build/manuscript-print.pdf` (impaginato in Word)
   - Upload cover PDF (KDP fornisce template per le dimensioni esatte basate su # pagine)
3. **ISBN**: Free KDP ISBN (KDP ne assegna uno gratuito)
4. **Prezzo**: $29.99 / €27.99 (calcola royalty con KDP Pricing Calculator)
5. **Pubblica** → review 72h

### File AMAZON-LISTING.md

Crea questo file con tutti i metadati copia-incollabili:

```markdown
# Amazon KDP Listing

## Title
[Il tuo titolo]

## Subtitle
[Il tuo sottotitolo accattivante]

## Author
[Il tuo nome]

## Description (HTML, max ~4000 char)
<h2>Hook in 2-3 righe</h2>
<p>Descrizione del libro...</p>
<h2>Cosa imparerai</h2>
<ul><li>Bullet 1</li>...</ul>
...

## Categories (2 max)
1. [Categoria principale]
2. [Categoria secondaria]

## Keywords (7 max)
[keyword 1]
[keyword 2]
...

## Pricing
eBook: $9.99
Paperback: $29.99
```

Per una versione completa vedi il file `AMAZON-LISTING.md` nel repo originale del libro Claude Code.

---

## Strategie di pricing

| Modello | Range | Royalty | Quando usarlo |
|---|---|---|---|
| **eBook basso** | $0.99 - $2.98 | 35% | Lancio promozionale, vendita rapida |
| **eBook standard** | $2.99 - $9.99 | **70%** ⭐ | Default per tech book — sweet spot |
| **eBook premium** | $10+ | 35% | Bibbia tecnica, edizione completa, audience verticale |
| **Paperback** | costo POD + €5-10 margine | dipende | Standard per tech book |
| **Hardcover** | costo POD + €10-15 margine | dipende | Collector's edition |

Esempio reale: per un libro tech a 390 pagine:
- eBook €9.99 → €6.99 royalty per copia (70%)
- Paperback €27.99 → ~€8 royalty (KDP POD calcolato a ~€10 costo stampa)

---

## Categorie KDP

Ogni libro può essere assegnato a **2 categorie** alla creazione. Dopo la pubblicazione puoi richiedere fino a **10 categorie** contattando KDP Support — vale la pena per massimizzare visibilità.

Trova la giusta categoria con il **Kindle Bestsellers**: naviga in https://www.amazon.com/Best-Sellers-Kindle-Store/zgbs/digital-text e identifica dove i tuoi competitor sono posizionati.

---

## Lancio

Settimana 1: pubblica edizione primaria (es. italiana).
Settimana 2-3: raccogli prime recensioni (chiedi a 5-10 lettori di prova).
Settimana 4: lancia edizione secondaria (es. inglese).
Mese 2-3: AMS (Amazon Marketing Services) ads $10-30/giorno.
Mese 6: analizza vendite + considera v1.1 update.

---

## Vedi anche

- `docs/05-multi-edition.md` — gestire edizioni IT + EN parallele
- `templates/book/styles/metadata.yaml.template` — template metadata pandoc
- Repo originale: https://github.com/hidran (cerca i companion del libro Claude Code)
