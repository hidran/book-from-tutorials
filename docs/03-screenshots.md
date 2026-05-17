# 03 · Screenshot dai video

Pipeline ffmpeg per estrarre figure dai video tutorial, selezione visiva, e applicazione nel manuscript.

---

## Strategia di estrazione

Per ogni capitolo serve 2-5 screenshot che illustrino i momenti chiave.

**Approccio efficiente** (vs guess-and-check):

1. Estrai 4-6 frame candidati a **timestamp evenly-spaced** (20%, 45%, 70%, 90% della durata)
2. Visualizza tutti i candidati
3. Seleziona i 2-4 migliori
4. Se nessuno funziona: ri-estrai a timestamp diversi

Questo è 5-10x più veloce di "individuo l'esatto frame voluto" perché spesso il frame ideale è vicino a quello evenly-spaced.

---

## Script extract-frames.sh

```bash
./scripts/extract-frames.sh <video.mp4> <output_dir> <ts1> [ts2 ...]
```

Esempio:

```bash
./scripts/extract-frames.sh videos/cap-01-intro.mp4 figures/raw/cap-01 \
  00:01:30 00:05:00 00:09:30 00:13:30
```

Genera `frame_001.png`, `frame_002.png`, ecc. in `figures/raw/cap-01/`. Risoluzione preservata dal sorgente. Qualità massima (`-q:v 2`).

### Batch su tutti i capitoli

```bash
# Loop per estrarre 4 frame da N video, mappati a N capitoli
for n in 01 02 03 04 05; do
  video="videos/cap-$n.mp4"
  [ -f "$video" ] || continue
  duration=$(ffprobe -v error -show_entries format=duration \
    -of default=noprint_wrappers=1:nokey=1 "$video" | awk '{print int($1)}')
  for pct in 20 45 70 90; do
    ts=$((duration * pct / 100))
    h=$((ts/3600)); m=$(((ts%3600)/60)); s=$((ts%60))
    timestamp=$(printf "%02d:%02d:%02d" $h $m $s)
    mkdir -p "figures/raw/cap-$n"
    ./scripts/extract-frames.sh "$video" "figures/raw/cap-$n" "$timestamp"
  done
done
```

---

## Selezione visiva

Apri i PNG candidati e scegli i migliori. Criteri:

- ✅ **Contenuto leggibile**: testo terminale chiaro, non sfocato, non in transizione
- ✅ **Significativo**: mostra un momento chiave del workflow (es. output di un comando, configurazione, errore)
- ✅ **Self-contained**: comprensibile senza dover vedere il video
- ❌ **Vuoto / quasi vuoto**: terminale appena aperto, schermata di caricamento
- ❌ **Duplicato**: due frame quasi identici → tieni solo 1
- ❌ **Cursore in posizione strana**: copre informazioni

---

## Convenzione di naming

Promuovi i frame selezionati con nomi descrittivi:

```bash
# Da: figures/raw/cap-01/frame_003.png (timestamp 00:09:30)
# A:   figures/cap-01/fig-01-welcome-screen.png

cp figures/raw/cap-01/frame_003.png figures/cap-01/fig-01-welcome-screen.png
cp figures/raw/cap-01/frame_004.png figures/cap-01/fig-02-help-menu.png

# Cleanup raw dopo conferma
rm -rf figures/raw/cap-01
```

Formato nome consigliato: `fig-NN-descrizione-breve.png`
- `NN` = numero progressivo nel capitolo (01, 02, ...)
- `descrizione-breve` = kebab-case, max 30 caratteri

---

## Apply nei capitoli

I capitoli scritti hanno placeholder `<!-- FIGURE: descrizione -->`. Sostituiscili con:

```markdown
![Schermata di benvenuto Claude Code con il modello attivo e la cartella corrente.](figures/cap-01/fig-01-welcome-screen.png){#fig:1-1 width=100%}

*Figura 1.1: appena lanci `claude` vedi modello attivo, organizzazione, e progetto corrente.*
```

**Path note**: usa path relativi a `book/` (es. `figures/cap-NN/...`), MAI relativi al file `.md` (es. NO `../../figures/...`). Il build script di pandoc passa `--resource-path=.:manuscript:figures` per risolvere.

### Batch apply via subagent

Quando hai >10 capitoli con placeholder, dispatcha un subagent:

```text
Per ogni capitolo da cap-02 a cap-16, trova i placeholder <!-- FIGURE: ... -->
nel file .md e sostituiscili in ordine con le immagini disponibili in
book/figures/cap-NN/, usando il pattern markdown standard.

Lista figure disponibili:
- cap-02: fig-01-claude-avviato.png
- cap-03: fig-01-plan-attivato.png, fig-02-piano-completo.png, fig-03-verifica.png
...

NON committare.
```

---

## ASCII art per capitoli senza video

Se un capitolo NON ha video sorgente disponibile (es. argomento solo testuale), genera ASCII art al posto delle screenshot.

Esempio per illustrare un workflow:

````markdown
```
[User Input]
     │
     ▼
[Plan Mode]
     │
     ├─→ [Task 1: Backend]
     ├─→ [Task 2: Frontend]   } parallel
     └─→ [Task 3: Tests]
     │
     ▼
[Code Review]
     │
     ▼
[Deploy]
```

*Figura 7.2: pipeline tipica con 3 task parallelizzabili.*
````

Vantaggio: rendering perfetto anche su e-ink Kindle grayscale, file size minimo.

Limite: solo per concetti astratti / diagrammi. Non sostituisce screenshot di UI reali.

---

## Ottimizzazione per Kindle

### Risoluzione

- **Minimo**: 1280×720 (HD)
- **Raccomandato**: 1920×1080 (FullHD)
- **Massimo utile**: 2560×1440 (oltre = file grande senza beneficio percepibile)

### Compressione

Se i PNG sono >800KB ciascuno, comprimi:

```bash
# macOS: sips (built-in)
for f in figures/cap-*/*.png; do
  size=$(stat -f%z "$f")
  if [ $size -gt 800000 ]; then
    sips -s formatOptions 80 "$f" --out "$f.tmp"
    mv "$f.tmp" "$f"
  fi
done

# Linux: imagemagick
mogrify -quality 80 figures/cap-*/*.png
```

Per un libro tipico (40 figure × 300KB = 12MB), EPUB risultante 20-25MB — ben sotto il limite KDP di 650MB.

### Grayscale per e-ink (opzionale)

Kindle Paperwhite mostra in grayscale. Per assicurarti che le figure siano leggibili anche lì:

```bash
# Test conversione + ispezione manuale
for f in figures/cap-01/*.png; do
  convert "$f" -colorspace Gray "${f%.png}-gray.png"
done
# Apri i -gray.png — sono leggibili? Se sì, lasci le versioni colore (Kindle converte al volo).
# Se no, valuta di aumentare contrast/saturation prima di salvare colore.
```

---

## Troubleshooting

### "Frame estratto è nero"

Causa: timestamp coincide con transizione/fade. Soluzione: ri-estrai con offset ±2 secondi.

### "Pandoc non trova l'immagine"

Errore tipo: `[WARNING] Could not fetch resource ../../figures/cap-01/fig-01.png`

Causa: path nel markdown `../../figures/...` non risolto da pandoc.

Soluzione: cambia in `figures/cap-01/fig-01.png` (relativo a `book/`).

### "EPUB ha errore: 'Referenced resource ... could not be found in the EPUB'"

Causa: image ref nel markdown punta a file inesistente.

Soluzione:
```bash
# Trova tutti i ref a immagini
grep -rn '!\[.*\](figures/' book/manuscript/

# Verifica esistenza di ciascuno
for ref in $(grep -roh 'figures/cap-[^)]*\.png' book/manuscript/); do
  [ -f "book/$ref" ] || echo "MANCANTE: $ref"
done
```

---

## Vedi anche

- `scripts/extract-frames.sh` — il wrapper ffmpeg
- `docs/04-build-and-publish.md` — come pandoc usa le immagini
