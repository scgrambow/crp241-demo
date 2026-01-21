---
project: [Project Name]
status: Initializing
version: 1.0.0
---

# PROJECT REQUIREMENTS DOCUMENT (PRD)

## 1. EXECUTIVE GOAL
- **Primary Objective:** [e.g., Transform R-script 'pilot_data.R' into a physician-facing Quarto tutorial]
- **Target Audience:** Physicians/Clinical Staff (Non-coders)
- **Success Criteria:** A renderable .qmd producing both HTML and PDF.

## 2. AGENT INSTRUCTIONS (BOOTSTRAP)
> **Directive:** Upon reading this PRD, the Agent MUST execute the following:

1. **Initialize Workspace:** Create `/context` directory.
2. **Anchor Memory:** - Create `context/history.md`: Log the receipt of the initial R script.
   - Create `context/future.md`: Map the path to the final Quarto output.
   - Create `context/insights.md`: Document the specific clinical framing chosen for this dataset.
3. **Execution Plan:** Propose a 3-step plan to "Improve" the script per `AGENTS.md` rules.

## 3. SPECIFIC CONSTRAINTS
- **Coding Standard:** Always include the `requireNamespace` check-and-install block.
- **Formatting:** 80-character comment limit; use callouts for clinical interpretations.
- **Privacy:** Process locally via LM Studio (No cloud upload of PII).

## 4. MILESTONES
- [ ] Environment Setup (Agent-led)
- [ ] Improved R-Script (Logic-preserved)
- [ ] Quarto Tutorial Draft
- [ ] PDF/HTML Validation