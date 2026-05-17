# 03 · Screenshots from Videos

ffmpeg pipeline for extracting figures from tutorial videos, visual selection, and applying them in the manuscript.

---

## Extraction strategy

Each chapter needs 2–5 screenshots illustrating the key moments.

**Efficient approach** (vs. guess-and-check):

1. Extract 4–6 candidate frames at **evenly-spaced timestamps** (20%, 45%, 70%, 90% of the duration)
2. View all candidates
3. Select the 2–4 best ones
4. If none work: re-extract at different timestamps

This is 5–10x faster than "find the exact frame I want" because the ideal frame is usually close to the evenly-spaced one.

---

## The extract-frames.sh script

```bash
./scripts/extract-frames.sh <video.mp4> <output_dir> <ts1> [ts2 ...]
```

Example:

```bash
./scripts/extract-frames.sh videos/cap-01-intro.mp4 figures/raw/cap-01 \
  00:01:30 00:05:00 00:09:30 00:13:30
```

Generates `frame_001.png`, `frame_002.png`, etc. in `figures/raw/cap-01/`. Resolution is preserved from the source. Maximum quality (`-q:v 2`).

### Batch across all chapters

```bash
# Loop to extract 4 frames from N videos, mapped to N chapters
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

## Visual selection

Open the candidate PNGs and pick the best ones. Criteria:

- ✅ **Readable content**: clear terminal text, not blurry, not mid-transition
- ✅ **Meaningful**: shows a key moment in the workflow (e.g., command output, configuration, error)
- ✅ **Self-contained**: understandable without watching the video
- ❌ **Empty / nearly empty**: freshly opened terminal, loading screen
- ❌ **Duplicate**: two nearly identical frames → keep only 1
- ❌ **Cursor in an odd position**: covers information

---

## Naming convention

Promote selected frames with descriptive names:

```bash
# From: figures/raw/cap-01/frame_003.png (timestamp 00:09:30)
# To:   figures/cap-01/fig-01-welcome-screen.png

cp figures/raw/cap-01/frame_003.png figures/cap-01/fig-01-welcome-screen.png
cp figures/raw/cap-01/frame_004.png figures/cap-01/fig-02-help-menu.png

# Clean up raw files after confirming
rm -rf figures/raw/cap-01
```

Recommended filename format: `fig-NN-short-description.png`
- `NN` = sequential number within the chapter (01, 02, ...)
- `short-description` = kebab-case, max 30 characters

---

## Apply in chapters

Written chapters have `<!-- FIGURE: description -->` placeholders. Replace them with:

```markdown
![Claude Code welcome screen showing the active model and current folder.](figures/cap-01/fig-01-welcome-screen.png){#fig:1-1 width=100%}

*Figure 1.1: when you launch `claude` you see the active model, organization, and current project.*
```

**Path note**: use paths relative to `book/` (e.g., `figures/cap-NN/...`), NEVER relative to the `.md` file (e.g., NO `../../figures/...`). The pandoc build script passes `--resource-path=.:manuscript:figures` to resolve them.

### Batch apply via subagent

When you have more than 10 chapters with placeholders, dispatch a subagent:

```text
For each chapter from cap-02 to cap-16, find the <!-- FIGURE: ... --> placeholders
in the .md file and replace them in order with the images available in
book/figures/cap-NN/, using the standard markdown pattern.

Available figures list:
- cap-02: fig-01-claude-started.png
- cap-03: fig-01-plan-activated.png, fig-02-complete-plan.png, fig-03-verification.png
...

DO NOT commit.
```

---

## ASCII art for chapters without video

If a chapter has NO source video available (e.g., a text-only topic), generate ASCII art instead of screenshots.

Example to illustrate a workflow:

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

*Figure 7.2: typical pipeline with 3 parallelizable tasks.*
````

Advantage: perfect rendering even on e-ink Kindle grayscale, minimal file size.

Limitation: only for abstract concepts / diagrams. It does not replace screenshots of real UIs.

---

## Kindle optimization

### Resolution

- **Minimum**: 1280×720 (HD)
- **Recommended**: 1920×1080 (Full HD)
- **Maximum useful**: 2560×1440 (beyond this = large file with no perceptible benefit)

### Compression

If PNGs are larger than 800 KB each, compress them:

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

For a typical book (40 figures × 300 KB = 12 MB), the resulting EPUB is 20–25 MB — well under KDP's 650 MB limit.

### Grayscale for e-ink (optional)

Kindle Paperwhite displays in grayscale. To make sure your figures are readable there too:

```bash
# Test conversion + manual inspection
for f in figures/cap-01/*.png; do
  convert "$f" -colorspace Gray "${f%.png}-gray.png"
done
# Open the -gray.png files — are they readable? If yes, keep the color versions (Kindle converts on the fly).
# If not, consider increasing contrast/saturation before saving the color version.
```

---

## Troubleshooting

### 'Extracted frame is black'

**Cause**: the timestamp coincides with a transition/fade. **Solution**: re-extract with a ±2-second offset.

### 'Pandoc can't find the image'

Error message: `[WARNING] Could not fetch resource ../../figures/cap-01/fig-01.png`

**Cause**: the path in the markdown (`../../figures/...`) is not resolved by pandoc.

**Solution**: change it to `figures/cap-01/fig-01.png` (relative to `book/`).

### 'EPUB error: "Referenced resource ... could not be found in the EPUB"'

**Cause**: an image reference in the markdown points to a file that does not exist.

**Solution**:
```bash
# Find all image references
grep -rn '!\[.*\](figures/' book/manuscript/

# Verify each one exists
for ref in $(grep -roh 'figures/cap-[^)]*\.png' book/manuscript/); do
  [ -f "book/$ref" ] || echo "MISSING: $ref"
done
```

---

## See also

- `scripts/extract-frames.sh` — the ffmpeg wrapper
- `docs/04-build-and-publish.md` — how pandoc uses images
