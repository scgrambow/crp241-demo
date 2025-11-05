# CRP241 Repo – Copilot Instructions (Auto-discovered)

This repository defines house rules for improving R scripts and generating matching Quarto tutorials for a physician audience. Copilot Chat should follow these instructions when you ask to improve a script or create a tutorial.

The canonical examples live in `examples/`:

- `*-original.R`: starting point
- `*.R`: improved, documented script (logic unchanged)
- `*-tutorial.qmd`: rich Quarto tutorial

Audience: physicians (not coders). Use basic functions, short sentences, and wrap text to ≤80 characters.

---

## What to do on request

When the user asks to “improve this script” or “create the tutorial,” Copilot should:

1) Improved R script

- Keep original logic, variable names, and outputs intact.
- Handle packages automatically: for any used package, first check with
  `requireNamespace("<pkg>", quietly = TRUE)` and `install.packages("<pkg>")`
  only if missing; then `library(<pkg>)`.
- Add a top header (title, audience, learning goals, data description, how to run).
- Use numbered sections: Setup; Load data; Explore; Model/Test; Interpret/Conclude.
- Precede each executable line or coherent block with a plain-English why/what comment.
- After each result/plot, add a short statistical and a clinical interpretation.
- Prefer base R + `readr`, `dplyr`, `ggplot2`, `stats` only.
- Output filename: drop `-original` (e.g., `X-original.R` → `X.R`), else append `-improved.R`.

1) Quarto tutorial (`.qmd`)

- YAML front matter (dual formats) to mimic `examples/10-27-25-confounding-tutorial.qmd`:
  - html:
    - `toc: true`, `toc-depth: 3`, `toc-location: left`
    - `code-fold: false`, `code-tools: true`, `code-line-numbers: true`
    - `theme: cosmo`, `embed-resources: true`, `number-sections: true`
  - pdf:
    - `toc: true`, `number-sections: true`, `colorlinks: true`, engine `xelatex`
- Include the same package check-install pattern in the Setup chunk so the
  tutorial runs without manual edits.
- Structure: introduction (unnumbered), then section-by-section flow that mirrors the
  improved script. Use callouts generously:
  - `callout-note` for Learning Objectives, Interpretation, Key Points
  - `callout-tip` for Clinical Analogy/Clinical Interpretation/Practice
  - `callout-important` for Critical/Key Teaching Points
  - `callout-warning` for data cleaning and pitfalls
- Use descriptive chunk labels and add figure sizes when helpful.
- Use `knitr::kable()` for small summary tables; add captions and striped/hover table classes.
- Suppress non-teaching messages (`message: false`, `warning: false`).
- Output filename: `<ROOT>-tutorial.qmd` next to the script. A single `quarto render`
  should produce both HTML and PDF.

Acceptance checks

- Improved script: header present; ≤80-char comments; one line/block explanation; stat+clinical interpretations; logic unchanged; numbered sections.
- Tutorial: renders with left TOC and numbered sections; mirrored code; stat+clinical notes for outputs.
- Tutorial styling: html uses theme cosmo, code tools on, code line numbers on, code folding off; tables have captions and striped/hover classes; callouts are used for objectives, key points, interpretation, clinical notes, warnings.
- Package handling: scripts/tutorials auto-check for required packages and install only when missing; then load.
- Tutorial YAML defines both html and pdf formats so a single render outputs both.

---

## Minimal prompts you can use

- With the original script open: “Improve this R script per repo instructions. Don’t change logic. Save next to it (drop -original).”
- With the improved script open: “Create the Quarto tutorial per repo instructions and save as <ROOT>-tutorial.qmd.”
- To validate both: “Validate and polish per repo checks (≤80 chars, stat+clinical notes, renderable tutorial).”

Copilot should infer missing details from this file and the examples. Only ask for clarifications if the script path or data source is ambiguous.

---

## Reference (full details)

If needed, see `.github/COPILOT_INSTRUCTIONS.md` for extended guidance, examples, and longer prompt templates.
