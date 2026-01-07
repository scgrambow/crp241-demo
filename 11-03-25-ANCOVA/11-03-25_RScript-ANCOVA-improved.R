# ============================================================================
# CRP 241 — Change Scores and ANCOVA (Improved Script)
# ============================================================================
# Audience: Physician learners (minimal programming experience)
# Learning Goals:
#   1. Understand paired (within-subject) comparisons and change scores.
#   2. Interpret paired t-test output and visualize within-patient change.
#   3. Distinguish change score analysis from ANCOVA adjustment.
#   4. Fit and interpret ANCOVA vs. simple and multiple linear regression.
#   5. Recognize when an interaction (non‑parallel slopes) model is needed.
# Data Description:
#   This script uses two example datasets loaded from course URLs:
#     (a) cholesterol.paired – cholesterol at Day 2, 4, 14 post MI (N=28)
#     (b) needle – baseline (pk1), posttreatment (pk2), and 1‑yr (pk5)
#         severity scores plus treatment group and change scores.
# How to Run:
#   Run line by line. Each block is preceded by a purpose comment and followed
#   by brief statistical + clinical interpretations. Logic & variable names
#   match the original script. Required packages auto‑install if missing.
# Packages Used:
#   PairedData (paired plots), HH (ANCOVA diagnostic plots), stats (base)
# ----------------------------------------------------------------------------
# SECTION 1. Setup
# ----------------------------------------------------------------------------

# Purpose: Ensure required packages are available and loaded (auto‑install if
# missing) without interrupting flow for learners.
required_pkgs <- c("PairedData", "HH")
for (p in required_pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) install.packages(p)
  library(p, character.only = TRUE)
}

# ----------------------------------------------------------------------------
# SECTION 2. Example 1 – Cholesterol Paired Differences (Change Scores)
# ----------------------------------------------------------------------------
# Purpose: Load acute coronary syndrome (ACS) cholesterol dataset and review
# paired comparison concepts (DAY4 vs DAY2) before modeling.
load(url("http://www.duke.edu/~sgrambow/crp241data/cholesterol-paired.RData"))
# Data object: cholesterol.paired

# Purpose: Inspect variable meanings for clinical orientation.
# (patient, DAY2, DAY4, DAY14, DAY14MSNG) – see original comments retained.

# Purpose: Compute paired difference (DAY4 - DAY2) and store in data frame.
cholesterol.paired$paired.diff <- cholesterol.paired$DAY4 - cholesterol.paired$DAY2
# Interpretation (stat): Creates a numeric vector of within‑patient change.
# Interpretation (clinical): Positive values mean cholesterol rose between
# day 2 and day 4; negative values indicate early decline post MI.

# Purpose: Summarize distribution of paired differences.
summary(cholesterol.paired$paired.diff)
# Interpretation (stat): Shows central tendency (median/mean) and spread.
# Interpretation (clinical): Helps gauge typical short‑term change magnitude.

# Purpose: Visualize distribution of paired differences (shape/outliers).
hist(cholesterol.paired$paired.diff, freq = FALSE,
     main = "4 vs 2 Days Post‑MI: Cholesterol Differences",
     ylab = "Density", xlab = "DAY4 - DAY2 (mg/dL)", col = "lightblue")
# Interpretation (stat): Shape suggests normality suitability for paired t‑test.
# Interpretation (clinical): Pattern shows whether most patients improve or worsen.

# Purpose: Boxplot with individual points & mean overlay for paired differences.
boxplot(cholesterol.paired$paired.diff,
        main = "Paired Cholesterol Change (Day4 - Day2)",
        ylab = "Change (mg/dL)", col = "sienna", range = 0)
stripchart(cholesterol.paired$paired.diff, method = "jitter", pch = 16,
           vertical = TRUE, add = TRUE)
points(mean(cholesterol.paired$paired.diff), cex = 1.7, pch = 16, col = "orange")
# Interpretation (stat): Mean point contextualizes skew/outliers vs box metrics.
# Interpretation (clinical): Identifies variability in early lipid response.

# Purpose: Create paired data object for specialized visualization.
pairs <- with(cholesterol.paired, paired(DAY2, DAY4))
# Interpretation (stat): Object encodes two linked measures for each subject.
# Interpretation (clinical): Facilitates per‑patient trajectory viewing.

# Purpose: McNeil plot (lines per subject show both measures side‑by‑side).
plot(pairs, type = "McNeil")
# Interpretation (stat): Parallel vertical segments; spread hints variance.
# Interpretation (clinical): Quickly shows patients trending up or down.

# Purpose: Profile plot (lines connecting paired measures per subject).
plot(pairs, type = "profile")
# Interpretation (stat): Majority of line directions indicate systematic change.
# Interpretation (clinical): Consistent direction supports a true physiologic shift.

# Purpose: Paired t‑test for Day4 vs Day2 cholesterol.
t.test(cholesterol.paired$DAY4, cholesterol.paired$DAY2, paired = TRUE)
# Interpretation (stat): Tests mean of paired.diff against zero.
# Interpretation (clinical): Significant result implies real short‑term change.

# Purpose: Equivalent paired t‑test using difference vector directly.
t.test(cholesterol.paired$paired.diff)
# Interpretation (stat): Same estimate & CI; confirms equivalence of formulations.
# Interpretation (clinical): Reinforces concept of analyzing change explicitly.

# Purpose: (Incorrect) two‑sample t‑test ignoring pairing for contrast.
t.test(cholesterol.paired$DAY4, cholesterol.paired$DAY2)
mean(cholesterol.paired$DAY4) - mean(cholesterol.paired$DAY2)
# Interpretation (stat): Wider SE; loses within‑subject correlation efficiency.
# Interpretation (clinical): May mislead by understating precision of change.

# ----------------------------------------------------------------------------
# SECTION 3. Example 2 – Acupuncture Study (Change Scores vs ANCOVA)
# ----------------------------------------------------------------------------
# Purpose: Load treatment (acupuncture vs control) severity score dataset.
load(url("http://www.duke.edu/~sgrambow/crp245data/needle.RData"))
# Data object: needle

# Purpose: Quick summaries of baseline, follow‑up, and change variables.
summary(needle$pk1); summary(needle$pk5); summary(needle$ChangeFrom.pk1)
# Interpretation (stat): Provides central tendency & variability pre/post/change.
# Interpretation (clinical): Assesses symptom burden and improvement magnitude.

# Purpose: Split data by treatment group for groupwise summaries.
Treat <- subset(needle, needle$fgroup == "Treat")
Control <- subset(needle, needle$fgroup == "Control")
# Interpretation (stat): Subsets allow direct group comparisons.
# Interpretation (clinical): Facilitates evaluation of intervention effect.

# Purpose: Summaries by group at baseline (pk1).
summary(Treat$pk1); summary(Control$pk1)
# Interpretation (stat): Baseline comparability check.
# Interpretation (clinical): Imbalance could bias post‑treatment comparison.

# Purpose: Summaries by group at 12 months (pk5).
summary(Treat$pk5); summary(Control$pk5)
# Interpretation (stat): Endline severity distribution.
# Interpretation (clinical): Lower scores indicate sustained improvement.

# Purpose: Summaries of change from baseline.
summary(Treat$ChangeFrom.pk1); summary(Control$ChangeFrom.pk1)
# Interpretation (stat): Direction/magnitude of improvement or worsening.
# Interpretation (clinical): Larger negative (if pk1 - pk5) indicates benefit.

# Purpose: Boxplots for baseline scores by group.
boxplot(pk1 ~ fgroup, data = needle,
        main = "Baseline Score (pk1) by Group",
        ylab = "pk1 Severity")
# Interpretation (stat): Visual baseline comparability.
# Interpretation (clinical): Ensures fair starting point for outcome judging.

# Purpose: Boxplots for 12 month scores by group.
boxplot(pk5 ~ fgroup, data = needle,
        main = "12‑Month Score (pk5) by Group",
        ylab = "pk5 Severity")
# Interpretation (stat): Post intervention distribution differences.
# Interpretation (clinical): Lower medians suggest sustained therapy effect.

# Purpose: Boxplots of change scores by group.
boxplot(ChangeFrom.pk1 ~ fgroup, data = needle,
        main = "Change from Baseline to 12 Months",
        ylab = "pk1 - pk5 Change")
# Interpretation (stat): Spread & central change by group.
# Interpretation (clinical): Larger improvement cluster favors treatment.

# Purpose: Paired data object for baseline vs one‑year severity.
needle.pairs <- with(needle, paired(pk1, pk5))
# Interpretation (stat): Encodes longitudinal pair for each subject.
# Interpretation (clinical): Tracks individual progression over time.

# Purpose: McNeil plot for severity change trajectories.
plot(needle.pairs, type = "McNeil")
# Interpretation (stat): Vertical alignment shows paired magnitude.
# Interpretation (clinical): Patterns highlight heterogeneity of response.

# Purpose: Profile plot connecting baseline to follow‑up per subject.
plot(needle.pairs, type = "profile")
# Interpretation (stat): Parallel shifts imply consistent direction.
# Interpretation (clinical): Downward lines may reflect symptom relief trend.

# ----------------------------------------------------------------------------
# SECTION 4. Modeling Approaches – Change Scores vs ANCOVA
# ----------------------------------------------------------------------------
# Purpose: Two‑sample t‑test on change scores comparing mean improvement.
t.test(needle$ChangeFrom.pk1 ~ needle$fgroup, var.equal = TRUE)
mean(Treat$ChangeFrom.pk1, na.rm = TRUE) - mean(Control$ChangeFrom.pk1, na.rm = TRUE)
# Interpretation (stat): Estimates average differential change (Treat - Control).
# Interpretation (clinical): Positive/negative indicates direction of treatment impact.

# Purpose: Two‑sample t‑test comparing follow‑up (pk5) directly.
t.test(needle$pk5 ~ needle$fgroup, var.equal = TRUE)
mean(Control$pk5, na.rm = TRUE) - mean(Treat$pk5, na.rm = TRUE)
# Interpretation (stat): Difference in endline means; ignores baseline levels.
# Interpretation (clinical): Risks confounding if baseline imbalance exists.

# Purpose: Simple linear regression (SLR) pk5 ~ group (unadjusted).
lm.slr <- lm(needle$pk5 ~ needle$group)
summary(lm.slr); confint(lm.slr)
# Interpretation (stat): Slope estimates mean difference (reference vs treatment).
# Interpretation (clinical): Crude effect; may be biased by baseline severity.

# Purpose: ANCOVA model adjusting for baseline severity (pk1).
lm.ancova <- lm(needle$pk5 ~ needle$pk1 + needle$group)
summary(lm.ancova); confint(lm.ancova)
# Interpretation (stat): Group coefficient estimates adjusted treatment effect.
# Interpretation (clinical): Accounts for initial severity improving fairness.

# Purpose: Alternative ANCOVA using change score outcome (pk1 - pk5).
lm.ancova <- lm(needle$ChangeFrom.pk1 ~ needle$pk1 + needle$group)
summary(lm.ancova); confint(lm.ancova)
# Interpretation (stat): Equivalent inference; outcome reframing alters intercept.
# Interpretation (clinical): Focuses on magnitude of improvement factoring baseline.

# Purpose: Multiple linear regression with interaction (non‑parallel slopes).
lm.mlr <- lm(needle$pk5 ~ needle$pk1 + needle$group + needle$pk1 * needle$group)
summary(lm.mlr)
# Interpretation (stat): Interaction term tests homogeneity of slopes.
# Interpretation (clinical): Significant interaction implies treatment effect varies by baseline severity.

# Purpose: Equivalent interaction specification (redundant check).
lm.mlr <- lm(needle$pk5 ~ needle$pk1 + needle$pk1 * needle$group)
summary(lm.mlr)
# Interpretation (stat): Confirms prior model; coefficient stability check.
# Interpretation (clinical): Reinforces slope pattern consistency assessment.

# ----------------------------------------------------------------------------
# SECTION 5. ANCOVA Diagnostics & Visualization
# ----------------------------------------------------------------------------
# Purpose: Use HH::ancovaplot to visualize adjusted relationship & slope parallelism.
ancovaplot(pk5 ~ pk1 + fgroup, data = needle)
# Interpretation (stat): Parallel fitted lines suggest homogeneity of slopes holds.
# Interpretation (clinical): Similar baseline-response gradient across groups.

# Purpose: Include interaction in plot to inspect divergence.
ancovaplot(pk5 ~ pk1 * fgroup, data = needle)
# Interpretation (stat): Visible divergence corroborates interaction test if present.
# Interpretation (clinical): Treatment benefit may depend on initial severity level.

# Purpose: Visualize means only (no adjustment) after removing missing values.
complete.needle <- needle[complete.cases(needle), ]
ancovaplot(pk5 ~ fgroup, x = pk1, data = complete.needle)
# Interpretation (stat): Collapses slope info; highlights crude mean differences.
# Interpretation (clinical): Snapshot view ignoring baseline heterogeneity.

# ----------------------------------------------------------------------------
# SECTION 6. Summary & Clinical Conclusions
# ----------------------------------------------------------------------------
# Key Statistical Points:
#   - Paired analysis leverages within‑subject correlation for precision.
#   - Change score vs ANCOVA: ANCOVA adjusts outcome for baseline; change score
#     directly models difference—often similar if assumptions met.
#   - Interaction term tests whether treatment effect depends on baseline value.
#   - Homogeneity of slopes assumption underlies standard ANCOVA interpretation.
# Clinical Takeaways:
#   - Early cholesterol shifts post MI can be detected reliably with paired tests.
#   - Accounting for baseline severity refines treatment effect estimates.
#   - Non‑parallel slopes suggest tailoring expectations by initial severity.
#   - Visual diagnostics aid in communicating modeling assumptions to clinicians.
# ----------------------------------------------------------------------------
# End of Program
# ----------------------------------------------------------------------------
