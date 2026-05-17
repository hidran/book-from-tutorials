---
description: Extract candidate screenshots from a video at evenly-spaced timestamps
argument-hint: <video-path> <chapter-number> [num-frames]
---

Extract candidate frames from a video for use as chapter screenshots. Defaults to 4 frames at 20%/45%/70%/90% of the video duration.

## Steps

1. Parse arguments: `$ARGUMENTS` should contain video path and chapter number
2. If missing, ask:
   - Video path (e.g., `videos/lesson-01.mp4`)
   - Chapter number (e.g., `1` → outputs to `figures/raw/cap-01/`)
   - Number of candidate frames (default: 4)
3. Verify the video file exists
4. Get duration with `ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 <video>`
5. Compute evenly-spaced timestamps (e.g., 20%, 45%, 70%, 90%)
6. Run `./scripts/extract-frames.sh <video> figures/raw/cap-<NN> <ts1> <ts2> <ts3> <ts4>`
7. Read each generated PNG with the Read tool (multimodal vision)
8. Report what each frame contains, suggest which 2-3 are best for the chapter
9. Wait for user to confirm selection, then:
   - Rename selected frames with descriptive names: `figures/cap-<NN>/fig-01-<description>.png`
   - Clean up `figures/raw/cap-<NN>/`
10. Suggest the markdown image refs to add to the chapter:
    ```markdown
    ![Caption](figures/cap-<NN>/fig-01-<name>.png){#fig:NN-1 width=100%}

    *Figure NN.1: <descriptive caption>*
    ```

## Tips

- Frames at 20% / 45% / 70% / 90% usually catch the chapter's key moments
- If a frame is black or mid-transition, re-extract with ±2 second offset
- Don't pick visually similar frames — diversity > quantity
- For chapters without source video: suggest ASCII art (see `docs/03-screenshots.md` § ASCII art)

## Output paths

- Raw candidates: `figures/raw/cap-<NN>/frame_001.png`, `frame_002.png`, ...
- Final selected: `figures/cap-<NN>/fig-01-<description>.png`, `fig-02-<description>.png`, ...
- Naming convention: kebab-case, max 30 chars, descriptive

After selection, remind the user to update the chapter's `<!-- FIGURE: ... -->` placeholders with the real image references.
