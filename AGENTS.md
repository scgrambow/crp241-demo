# CRP241 Repo – Agents Instructions (for GPT-based VS Code agents)

This file mirrors our Copilot instructions for use with other VS Code agent
extensions (e.g., GPT-based Codex plugins). It's model-agnostic and focused on
the workflow faculty can reuse to transform R teaching scripts into physician-
friendly materials.

> **Note for Copilot users:** If you're using GitHub Copilot Chat, it will auto-discover `.github/copilot-instructions.md` instead. This file mirrors that content in a model-agnostic format.

Assumptions

- Your agent can read a project‑scoped Markdown instruction file, or you can
  paste this content into the agent’s system prompt/config.
- R and Quarto are installed locally; the agent can run terminal commands when
  asked (optional).

Canonical examples live in `examples/`:

- `*-original.R`: starting point
- `*.R`: improved, documented script (logic unchanged)
- `*-tutorial.qmd`: rich Quarto tutorial

Audience of materials: physicians (not coders). Use basic functions, short
sentences, and wrap text to <=80 characters.

---

## What to do on request

When asked to “improve this script” or “create the tutorial,” the agent should:

1) Improved R script

- Keep original logic, variable names, and outputs intact.
- Handle packages automatically: for any used package, first check with
  `requireNamespace("<pkg>", quietly = TRUE)` and install only if missing via
  `install.packages("<pkg>")`; then `library(<pkg>)`.
- Add a top header (title, audience, learning goals, data description, how to
  run).
- Use numbered sections: Setup; Load data; Explore; Model/Test; Interpret/
  Conclude.
- Precede each executable line or coherent block with a plain-English why/what
  comment (<=80 chars where practical).
- After each result/plot, add a short statistical and a clinical interpretation.
- Distinguish strictly between **sample** statistics and **population**
  parameters in all phrasing.
- Explicitly note the frequency of missing values (`NA`s) and explain how they
  are handled (e.g., `na.rm = TRUE`, `use = "complete.obs"`).
- Prefer base R + `readr`, `dplyr`, `ggplot2`, `stats` only.
- Output filename: drop `-original` (e.g., `X-original.R` → `X.R`), else append
  `-improved.R`.

1) Quarto tutorial (`.qmd`)

- YAML front matter (dual formats) mirroring `examples/10-27-25-confounding-tutorial.qmd`:
  - html:
    - `toc: true`, `toc-depth: 3`, `toc-location: left`
    - `code-fold: false`, `code-tools: true`, `code-line-numbers: true`
    - `theme: cosmo`, `embed-resources: true`, `number-sections: true`
  - pdf:
    - `toc: true`, `number-sections: true`, `colorlinks: true`, engine
      `xelatex`
- Include the same package check‑install pattern in the Setup chunk so the
  tutorial runs without manual edits.
- Structure: introduction (unnumbered), then section‑by‑section flow mirroring
  the improved script. Use callouts generously:
  - `callout-note` for Learning Objectives, Interpretation, Key Points
  - `callout-tip` for Clinical Analogy/Clinical Interpretation/Practice
  - `callout-important` for Critical/Key Teaching Points OR **Programming/
    Technical Notes** (e.g., handling missing data).
  - `callout-warning` for data cleaning and pitfalls
- Use descriptive chunk labels and figure sizes when helpful.
- Use `knitr::kable()` for small tables; add captions and striped/hover classes.
- Suppress non‑teaching messages (`message: false`, `warning: false`).
- Output filename: `<ROOT>-tutorial.qmd` next to the script. A single Quarto
  render should produce both HTML and PDF.

Acceptance checks

- Improved script: header present; <=80-char comments; one line/block
  explanation; stat+clinical interpretations; logic unchanged; numbered
  sections.
- Data verification: confirm key summary statistics (e.g., means, counts of
  missing values) match the actual dataset provided.
- Tutorial: renders with left TOC and numbered sections; mirrored code;
  stat+clinical notes for outputs.
- Tutorial styling: HTML uses theme cosmo, code tools on, code line numbers on,
  code folding off; tables have captions and striped/hover classes; callouts
  used for objectives, key points, interpretation, clinical notes, warnings.
- Package handling: scripts/tutorials auto‑check for required packages and
  install only when missing; then load.
- Tutorial YAML defines both html and pdf formats so a single render outputs
  both.

---

## Minimal prompts you can use (for agents)

- With the original script open: "Improve this R script per repo instructions.
  Don’t change logic. Save next to it (drop -original)."
- With the improved script open: "Create the Quarto tutorial per repo
  instructions and save as <ROOT>-tutorial.qmd."
- To validate both: "Validate and polish per repo checks (<=80 chars, stat+
  clinical notes, renderable tutorial)."
- Optional: "Render the tutorial now and show me the output(s)."

Notes for agent setup

- If your agent supports project-scoped instruction files, place this `AGENTS.md`
  at the repository root (or the location the extension scans). Otherwise, copy
  these instructions into the agent's system prompt/config for this workspace.
- Rendering requires local Quarto; the agent may need permission to run
  terminal commands.
