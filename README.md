# CRP241 Demo — Physician‑Friendly R + Quarto Tutorials (Public Demo)

Public demo disclaimer

- This repository is a public demonstration for teaching purposes in an
  introductory statistics course for physicians (CRP 241).
- Content is simplified and not intended as clinical guidance or production
  code. There is no PHI in this repository.
- You are welcome to explore and adapt, but please review and validate for
  your own context.

## Purpose

Show faculty how to use GitHub, VS Code, and GitHub Copilot to transform R
teaching scripts into clear, physician‑friendly materials. The demo focuses on
the workflow (repo setup, Copilot Chat prompts, file creation, Quarto render)
that faculty can reuse across their own courses.

Note: The resulting materials (improved scripts and tutorials) are written for
physician learners: short sentences, basic functions, and clinical context.

## Who this demo is for

- Faculty, instructors, and biostatisticians who teach with R and want to
  modernize their workflow using GitHub + VS Code + Copilot.
- The examples come from CRP 241; you can adapt the same process to your
  own course materials.

## What's inside

- examples/
  - `*-original.R`: starting script
  - `*.R`: improved, documented script (logic unchanged)
  - `*-tutorial.qmd`: rich Quarto tutorial (HTML + PDF)
- .github/
  - `copilot-instructions.md`: house rules for GitHub Copilot Chat (auto-discovered)
- `AGENTS.md`: model-agnostic version of the instructions for non-Copilot AI agents
- Issue templates in `.github/ISSUE_TEMPLATE/` for requesting improved scripts
- Top-level scripts and tutorials created during demos
- `tutorial-video-github-vs-code.md`: link to a recorded walkthrough
- `11-03-25_RScript-ANCOVA.R`: intentionally unmodified script for practice

## AI Agent Instructions (Why Two Files?)

This repository includes **two instruction files** that mirror each other in content but serve different tools:

1. **`.github/copilot-instructions.md`** — Auto-discovered by GitHub Copilot Chat
   - Uses Copilot-specific language ("Copilot should...")
   - Automatically loaded when you use Copilot Chat in this workspace
   - Recommended for users with GitHub Copilot

2. **`AGENTS.md`** — Model-agnostic version for other AI coding assistants
   - Uses generic language ("the agent should...")
   - Can be referenced by GPT-based VS Code extensions or other AI tools
   - Can be pasted into system prompts if your agent doesn't auto-discover files

**Why both?** To maximize accessibility for faculty using different AI tools while maintaining a single source of truth for the workflow. Both files define the same two-step process (improve script → generate tutorial) but target different audiences.

## Audience and style of the materials

- Target audience for the materials: physicians (not coders/statisticians)
- Keep functions basic: base R + readr, dplyr, ggplot2, stats
- Wrap text to ≤80 characters; use short sentences
- Explain each line/block in plain English
- Add both statistical and clinical interpretations after results/plots

## How the workflow works

The repository includes Copilot instructions that automate a two‑step flow:

1) Improve an R script
   - Keep original logic, variable names, models, and outputs intact
   - Add a header (title, audience, learning goals, data description, how to
     run)
   - Use numbered sections: Setup; Load data; Explore; Model/Test;
     Interpret/Conclude
   - Precede each line/block with a plain‑English explanation
   - Auto‑handle packages: if missing, install, then load (via
     `requireNamespace()` + `install.packages()` → `library()`)
   - Save as `*.R` (drop `-original`) or `*-improved.R`

2) Generate a Quarto tutorial (`.qmd`)
   - Dual formats from one render:
     - HTML: left TOC, depth 3, theme cosmo, code tools on, code line numbers
       on, code folding off, embed resources
     - PDF: xelatex, color links, numbered sections
   - Structure mirrors the improved script; use callouts generously:
     - callout‑note: Learning Objectives, Interpretation, Key Points
     - callout‑tip: Clinical Analogy/Interpretation/Practice
     - callout‑important: Critical/Key Teaching Points
     - callout‑warning: Data cleaning and pitfalls
   - Use `knitr::kable()` for small tables with captions and striped/hover
     classes
   - Suppress non‑teaching messages (message: false, warning: false)

## What Copilot can do (end‑to‑end via chat)

Copilot Chat can run this whole process through natural language dialogue:

- Set up the repository instructions based on your examples
- Improve R scripts (logic unchanged) and save the annotated versions
- Generate matching Quarto tutorials next to each script
- Render tutorials to HTML and PDF by running Quarto in a terminal
- Open rendered HTML for quick preview (optional)
- Iterate on edits (“tighten section 3”, “add a callout for pitfalls”, etc.)

Prerequisites

- GitHub account and Git installed
- VS Code with the GitHub Copilot Chat extension
- R installed locally
- Quarto installed locally
- Internet access for first‑time package installs in scripts/tutorials

Copilot takes care of file creation, edits, and running renders — you provide
plain‑English prompts.

## Quick start (with Copilot Chat)

Copilot Chat automatically uses `.github/copilot-instructions.md` when you're in this workspace.

- Open an original script (e.g., `examples/...-original.R`) and say:
  "Improve this R script per repo instructions. Don't change logic. Save next
  to it (drop -original)."
- Then open the improved script and say:
  "Create the Quarto tutorial per repo instructions and save as
  <ROOT>-tutorial.qmd."
- Ask Copilot to render it for you:
  "Render the tutorial now."

## Quick start (with other AI agents)

If you're using a different AI coding assistant:

1. Point your agent to `AGENTS.md` (if it supports project-scoped instruction files)
2. Or copy the content from `AGENTS.md` into your agent's system prompt/config
3. Use the same natural language prompts as above

The workflow is identical — only the discovery mechanism differs.

## Try it yourself: ANCOVA demo

We purposely left `11-03-25_RScript-ANCOVA.R` unmodified so you can practice
the workflow end-to-end:

**With Copilot Chat:**
- Open `11-03-25_RScript-ANCOVA.R` and say:
  "Improve this R script per repo instructions. Don't change logic. Save next
  to it (drop -original)."
- Then open the improved script and say:
  "Create the Quarto tutorial per repo instructions and save as
  11-03-25_RScript-ANCOVA-tutorial.qmd."
- Optional: "Render the tutorial now."

**With other agents:**
- Ensure your agent has loaded `AGENTS.md` (or paste its content into your
  agent's system prompt)
- Use the same prompts as above

## Render tutorials locally

From the repo root, render both HTML and PDF with a single command:

```bash
quarto render <PATH>/<ROOT>-tutorial.qmd
```

Notes

- Requires R and Quarto. First‑time PDF render may install TinyTeX/LaTeX.
- Scripts/tutorials auto‑install missing R packages as needed.

## Acceptance checks (for consistency)

- Improved script
  - Header present; ≤80‑char comments; numbered sections
  - One explanation per line/block; stat + clinical interpretations
  - Logic unchanged; script executable
- Tutorial
  - Left TOC and numbered sections; style matches examples (cosmo theme,
    code tools on, code line numbers on, code folding off)
  - Mirrored code; stat + clinical notes for outputs
  - Dual output (HTML + PDF) from one render

## Video tutorial

See `tutorial-video-github-vs-code.md` for the YouTube link (placeholder until
the upload is finalized).

Note on interaction style

- In the video, prompts to Copilot are dictated via the Wispr voice‑to‑text
  app. Spoken instructions are transcribed and then sent to Copilot Chat. If
  you hear speech rather than typing, that’s expected.

## License

See `LICENSE` for terms. Educational/demo content — validate for your use.
