# =============================================================
# Title: Power and Sample Size (CRP 241)
# Audience: Physicians in an intro statistics course
# Learning goals:
# - Know the inputs for power/sample size calculations
# - Use pwr functions for t-tests and two-proportion tests
# - Adjust total enrollment for expected attrition
# Data description:
# - No external dataset is used. We work from assumed inputs
#   (means, SD, proportions) taken from published contexts.
# How to run:
# - In R, install the pwr package if needed, then run sections
#   in order. Each step explains why and what it does.
# Wrap: Comments are kept to ≤80 characters for readability.
# =============================================================

# 1) Setup -----------------------------------------------------
# Why: Ensure required package is available and loaded.
# What: If pwr is missing, install it; otherwise just load it.
if (!requireNamespace("pwr", quietly = TRUE)) install.packages("pwr")

# What: Load the pwr package to access power/sample size helpers.
library(pwr)

# 2) Load data -------------------------------------------------
# Why: This analysis uses no external files. We compute required
#      sample sizes from design inputs (effect size, alpha, power).
# What: Nothing to load; proceed to design inputs and calculations.

# 3) Explore: key quantities and context -----------------------
# Why: Power functions need 3 of 4: effect size, sample size (n),
#      significance level (alpha), and power. We supply three and
#      solve for the fourth. For two-proportion tests, pwr uses
#      Cohen's h (formula below) as the effect size.

# 4) Model/Test: continuous outcome example (ORBITA) -----------
# Context (stat): Two-sample t-test, two-sided alpha=0.05, power=0.80.
# Context (clin): Detect a 30-second improvement in exercise time with
#                 SD=75 seconds. Translate to Cohen's d = 30/75 = 0.4.

# What: Compute required n per group for a two-sample t-test.
# Why: Choose n to detect the minimal clinically important difference.
pwr.t.test(sig.level=0.05, power=0.8, d=0.4,
           type="two.sample", alternative="two.sided")

# Stat interpretation: Output shows n ≈ 99 per group (about 200 total).
# Clinical interpretation: Plan for ~100 patients per arm to detect a
# 30-second difference with 80% power at alpha 0.05.

# Now account for attrition.
# Why: If 33% drop out, only 67% remain; inflate to keep target analyzable
#      sample. Compute total to enroll so final sample ≈ 200.
200/.67
# Stat interpretation: 200 / 0.67 ≈ 298.5; round up to 300 total.
# Clinical interpretation: Enroll ~150 per arm to accommodate attrition.

# 5) Model/Test: binary outcome example (Gulf War) -------------
# Context (stat): Two-sided test of proportions with power=0.95 and
#                 alpha=0.05. Effect size uses Cohen's h.
# Context (clin): Compare p1 = 0.30 vs p2 = 0.15.

# What: Compute Cohen's h for proportions.
# Why: pwr.2p.test expects h = 2*asin(sqrt(p1)) - 2*asin(sqrt(p2)).
h = 2*asin(sqrt(0.30)) - 2*asin(sqrt(0.15))

# What: Compute required n per group for two-proportion test.
# Why: Determine group sizes to detect the specified difference.
pwr.2p.test(h = h, power=0.95, sig.level = 0.05)

# Stat interpretation: n ≈ 196 per group; round to 200 per group.
# Clinical interpretation: Plan for ~400 analyzable participants total.

# Account for 10% attrition to hit 400 analyzable subjects.
# Why: Enroll more so that after 10% loss, ~400 remain.
# What: Compute total enrolled needed and show per-group target.
totalsubjects <- 400/0.90 

totalsubjects

450/2
# Stat interpretation: Total ≈ 444.4 → enroll 450; 225 per group.
# Clinical interpretation: Start with 225 per arm to end near 200 per arm.

# 6) Model/Test: detectable effect (continuous, fixed n) -------
# Context (stat): Two-sample t-test with power=0.90, alpha=0.05,
#                 and n=200 per group; solve for detectable Cohen's d.
# Context (clin): With 200 per arm, how small an effect can we detect?

# What: Solve for d given n, alpha, and power for a two-sample t-test.
# Why: This tells us the minimal detectable effect at the chosen size.
pwr.t.test(power = 0.90, sig.level=0.05, n=200, 
           type="two.sample", alternative="two.sided")

# Stat interpretation: Detectable Cohen's d ≈ 0.32.
# Clinical interpretation: With 200 per arm, we can detect a small-to-
# moderate effect; translate d to a clinically meaningful change using
# the study's SD (delta = d * sigma).

# 7) Interpret and conclude ------------------------------------
# Summary (stat):
# - Continuous outcome: ~100 per arm (200 total) for d=0.4 at 80% power;
#   inflate to ~300 total for 33% attrition.
# - Binary outcome: ~200 per arm (400 total) at 95% power; inflate to
#   ~450 total for 10% attrition.
# - With n=200 per arm, minimal detectable d ≈ 0.32.
# Summary (clinical):
# - Plan enrollment using expected drop-out so the final analyzable
#   sample matches your goals.
# - Express effects in patient-centered units (e.g., seconds, absolute
#   risk difference), not just standardized metrics.
# - Ensure your MCID is agreed upon with clinicians before calculations.

# --------------------------------------------------
# End of Program
