# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CRP 245 — Survival Analysis: Kaplan-Meier Method
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Audience: Physician learners with little or no programming experience.
# Goal: This analysis demonstrates survival analysis using the Kaplan-Meier 
#       method to analyze outcomes in ovarian cancer patients. You will learn to 
#       handle censored data, visualize survival curves, and interpret 
#       clinical probabilities such as median survival time.
#
# Study Background:
# This analysis uses data from a randomized clinical trial comparing two 
# treatments for advanced ovarian carcinoma (stages IIIB and IV). 
# 1. Control arm: cyclophosphamide alone (1 g/m2)
# 2. Treatment arm: cyclophosphamide (500 mg/m2) + adriamycin (40 mg/m2)
# Both treatments were given by IV injection every 3 weeks.
#
# How to use this script:
# - Run the script line-by-line or as a whole.
# - Comments (lines starting with #) explain the clinical and statistical 
#   rationale for each step.
# - Key findings are summarized in "CLINICAL INTERPRETATION" blocks.
#
# Data Dictionary:
# - futime: Time from randomization until death or last follow-up (days)
# - fustat: Patient status (1 = died; 0 = still alive/censored)
# - age: Patient age at diagnosis (years)
# - resid.ds: Whether residual disease was present (1 = no; 2 = yes)
# - rx: Treatment group (0 = cyclophosphamide alone; 1 = cyclo + adriamycin)
# - ecog.ps: Performance status (1 = better functioning; 2 = worse)
#
# ================================================================================
# 1. SETUP: CHECK AND LOAD PACKAGES
# ================================================================================
# We check if required packages are installed before loading them.

# Check for and install 'survival' for core analysis
if (!requireNamespace("survival", quietly = TRUE)) {
  install.packages("survival")
}
library(survival)

# Check for and install 'survminer' for enhanced plots
if (!requireNamespace("survminer", quietly = TRUE)) {
  install.packages("survminer")
}
library(survminer)

# Check for and install 'graphics' for basic plotting
if (!requireNamespace("graphics", quietly = TRUE)) {
  install.packages("graphics")
}
library(graphics)

# ================================================================================
# 2. LOAD DATA
# ================================================================================

# Download and load the trial data into 'ovarian2'
load(url("https://www.duke.edu/~sgrambow/crp241data/ovarian2.RData"))

# Verify data structure and check for missing values
# - NOTE: Observe the distribution of 'fustat' (survival status).
summary(ovarian2)

# STATISTICAL INTERPRETATION:
# - Study Sample: n = 26 patients (small sample size).
# - Median age is 56.5 years.
# - 'fustat' indicates that 12 patients experienced the event (died) while
#   14 were censored (still alive at last follow-up).
# - No missing values (NAs) were found in the clinical variables.

# CLINICAL INTERPRETATION:
# - This is a small dataset from an advanced ovarian cancer trial.
# - Survival analysis is necessary because over half the patients were censored 
#   (status=0), meaning we don't know their exact time of death.

# ================================================================================
# 3. EXPLORE: VISUALIZING SURVIVAL TIMES
# ================================================================================

# View distribution of follow-up times for the whole cohort
hist(ovarian2$futime, main = 'Survival Times (All Subjects)', xlab = 'Days')

# View distribution by event status
par(mfrow=c(1,2)) # Side-by-side plots
hist(ovarian2$futime[ovarian2$fustat == 1], main = 'Deaths', xlab = 'Days')
hist(ovarian2$futime[ovarian2$fustat == 0], main = 'Censored', xlab = 'Days')
par(mfrow=c(1,1)) # Reset plot layout

# CLINICAL INTERPRETATION:
# - Deaths occur throughout the study period.
# - Censoring events (patients still alive) also occur at various times, often 
#   at later intervals. This "mix" of data is why we use Kaplan-Meier rather 
#   than simple averages.

# ================================================================================
# 4. MODEL: KAPLAN-MEIER SURVIVAL ESTIMATES
# ================================================================================

# ---Question 1---
# SURVIVAL ESTIMATES TABLE
# Clinical Question: What is the probability of survival at specific timepoints?

# Create the KM survival object
fit.km <- survfit(Surv(futime, fustat) ~ 1, data=ovarian2)

# Default output (only shows times with deaths)
summary(fit.km)

# Full output (including censoring events)
summary(fit.km, censor=TRUE)

# STATISTICAL INTERPRETATION:
# - At 59 days: First death occurs; survival probability drops to 96.2%.
# - At 365 days (1 year): Cumulative survival probability is 73.1% (95% CI: 
#   57.9% - 92.3%).
# - The Standard Error increases as fewer patients remain "at risk" over time.

# CLINICAL INTERPRETATION:
# - In this trial, approximately 3 out of 4 patients survived at least one year.
# - The wide confidence intervals reflect the small sample size (n=26).

# ---Question 2---
# KAPLAN-MEIER SURVIVAL CURVE PLOTS
# Clinical Question: How does the probability of survival decline over time?

# Professional KM plot with Risk Table
ggsurvplot(fit.km, data = ovarian2, 
           risk.table = TRUE,
           main = "Survival Probability: Advanced Ovarian Cancer",
           xlab = "Days Since Randomization",
           ylab = "Survival Probability",
           legend.title = "Cohort Average")

# Alternative: Cumulative Incidence (Probability of Death)
ggsurvplot(fit.km, data = ovarian2, 
           fun = "event",
           risk.table = TRUE,
           main = "Cumulative Incidence of Death",
           xlab = "Days Since Randomization",
           ylab = "Probability of Death")

# CLINICAL INTERPRETATION:
# - The KM curve shows a steady decline in survival over the first 800 days.
# - The "Risk Table" is critical: it shows how many patients the model is 
#   basing its estimates on at each interval. By day 800, only 5 patients
#   remain at risk.

# ================================================================================
# 5. INTERPRET: CLINICAL PROBABILITIES AND MEDIAN SURVIVAL
# ================================================================================

# ---Questions 3 & 4---
# SURVIVAL AT SPECIFIC CLINICAL INTERVALS
# Q3: Probability of surviving at least 2 years (730 days)?
summary(fit.km, times = 730)$surv

# Q4: Probability of dying before 6 months (180 days)?
1 - summary(fit.km, times = 180)$surv

# STATISTICAL INTERPRETATION:
# - 2-Year Survival: Estimate = 49.7% (about 50%).
# - 6-Month Mortality: Estimate = 11.5%.

# CLINICAL INTERPRETATION:
# - Roughly half of the patients in this clinical population survived to the 
#   2-year mark.
# - Early mortality (before 6 months) was relatively low at 11.5%.

# ---Question 5---
# MEDIAN SURVIVAL TIME
# Clinical Question: At what timepoint have 50% of the patients died?

# Get median survival and confidence interval
summary(fit.km)$table

# Plot showing horizontal/vertical lines at the median point
ggsurvplot(fit.km, data = ovarian2, 
           risk.table = TRUE, 
           surv.median.line = "hv")

# STATISTICAL INTERPRETATION:
# - Median survival = 638 days.
# - 95% Confidence Interval = [464, Not Estimable].
# - Note: The upper bound is "NA" because the survival curve never drops 
#   low enough for the upper library to reach a definitive limit.

# CLINICAL INTERPRETATION:
# - The "typical" patient in this trial survived for 638 days (approx 1.75 yrs).
# - This is a key metric used in medical literature to compare treatments.

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# End of Program
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
