# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CRP 245 — Cox Proportional Hazards Regression
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Audience: Physician learners with little or no programming experience.
# Goal: This analysis demonstrates Cox Proportional Hazards (Cox PH) regression
#       using data from the CGD clinical trial. You will learn to estimate
#       hazard ratios, interpret treatment effects, assess associations with
#       continuous and categorical predictors, and create survival visualizations.
#
# Study Background:
# This analysis uses data from a randomized, double-blind, placebo-controlled
# clinical trial investigating the efficacy of recombinant gamma interferon
# (IFN-γ) in preventing serious infections among patients with chronic
# granulomatous disease (CGD). CGD is a rare inherited immunodeficiency
# characterized by recurrent life-threatening bacterial and fungal infections.
#
# - CGD affects approximately 1 in 200,000 individuals.
# - The primary endpoint is time to first serious infection from study entry.
# - The trial randomized patients 1:1 to either placebo or gamma interferon.
#
# CLINICAL QUESTIONS TO BE ANSWERED:
# Q1: What is the hazard ratio and 95% CI comparing placebo vs. gamma interferon?
# Q2: Is there an association between sex and infection risk?
# Q3: Create and interpret Kaplan-Meier plots stratified by sex
# Q4: Is there an association between age and infection risk?
# Q5: What is the hazard ratio for a 5-year increase in age?
#
# How to use this script:
# - Run the script line-by-line or as a whole.
# - Comments (lines starting with #) explain the clinical and statistical 
#   rationale for each step.
# - Key findings are summarized in "CLINICAL INTERPRETATION" blocks.
#
# Data Dictionary:
# - id: Patient identification number
# - center: Enrollment center
# - random: Date of randomization
# - treat: Treatment group (0 = placebo; 1 = gamma interferon)
# - sex: Patient sex (0 = male; 1 = female)
# - age: Patient age at enrollment (years)
# - height: Height (cm)
# - weight: Weight (kg)
# - inherit: Mode of inheritance (X-linked or autosomal recessive)
# - steression steroids: Use of corticosteroids at entry (1 = yes; 0 = no)
# - propylac: Using prophylactic antibiotics at entry (1 = yes; 0 = no)
# - hos.cat: Pattern of hospitalization in prior year
# - tstart: Start of follow-up interval (days)
# - tstop: End of follow-up interval (days) — TIME TO EVENT
# - status: Event indicator (1 = infection occurred; 0 = censored)
# - enum: Event number (for recurrent events, we use first event only)
#
# ================================================================================
# 1. SETUP: CHECK AND LOAD PACKAGES
# ================================================================================
# We check if required packages are installed before loading them.
# These packages provide specialized tools for survival analysis.

# Check for and install 'survival' for core survival analysis functions
# NOTE: The survival package contains essential functions for Cox regression:
#   - Surv(): Creates a survival object from time and status variables
#   - coxph(): Fits the Cox Proportional Hazards model
#   - survfit(): Calculates Kaplan-Meier survival estimates
if (!requireNamespace("survival", quietly = TRUE)) {
  install.packages("survival")
}
library(survival)

# Check for and install 'survminer' for enhanced survival plots
# NOTE: survminer provides publication-quality Kaplan-Meier plots through 
# the ggsurvplot() function, including risk tables and confidence intervals.
if (!requireNamespace("survminer", quietly = TRUE)) {
  install.packages("survminer")
}
library(survminer)

# ================================================================================
# 2. LOAD DATA
# ================================================================================
# Download and load the CGD trial data from the course website.

load(url("https://www.duke.edu/~sgrambow/crp241data/cgd.RData"))

# ================================================================================
# 3. INITIAL DATA EXPLORATION
# ================================================================================
# Before modeling, we examine the data structure and summary statistics.

# str() displays the data structure including variable types
# This is essential to understand how variables are coded (numeric vs. factor)
str(cgd)

# summary() provides descriptive statistics for all variables
# For numeric variables: min, max, quartiles, mean
# For factors: count per category
summary(cgd)

# STATISTICAL INTERPRETATION:
# - Sample Size: n = 128 patients (unique patient records)
# - Treatment Distribution: 49.2% gamma interferon, 50.8% placebo
# - Sex Distribution: 81.3% male, 18.7% female
# - Age: Median 12 years (range: 1-44 years) — this is a pediatric population
# - Event Rate: 44 infections observed (34.4% experienced the primary endpoint)
# - Follow-up Time: Median 269 days (range: 4-388 days)

# CLINICAL INTERPRETATION:
# - CGD predominantly affects males (X-linked inheritance pattern)
# - The young median age (12 years) reflects that CGD often presents in childhood
# - This is a well-powered trial with balanced treatment arms
# - With 34% event rate, we have sufficient events for Cox regression analysis

# ================================================================================
# 4. VISUALIZE: INITIAL KAPLAN-MEIER CURVES BY TREATMENT
# ================================================================================
# Before Cox regression, we visually explore survival differences.

# survfit(): Creates Kaplan-Meier survival estimates
# - Surv(tstop, status): Creates a "survival object" combining time and event
#   - tstop: time to event or censoring
#   - status: 1 = event (infection), 0 = censored (no infection by study end)
# - ~ treat: Stratifies the estimate by treatment group
fit.km <- survfit(Surv(tstop, status) ~ treat, data=cgd)

# ggsurvplot(): Creates publication-quality survival plots
# - legend.labs: Custom labels for the legend
# - risk.table: Adds "Number at Risk" table below the plot
ggsurvplot(fit.km, data=cgd,
           ggtheme = theme_minimal(),
           legend.labs = c("Placebo","Gamma interferon"),
           risk.table = TRUE)

# STATISTICAL INTERPRETATION:
# - The curves separate early and maintain separation throughout follow-up
# - The gamma interferon group shows higher event-free survival probability
# - Risk table shows adequate patients at risk throughout the study period

# CLINICAL INTERPRETATION:
# - Visual inspection strongly suggests a treatment benefit for gamma interferon
# - The "step-like" pattern shows events occurring at discrete time points
# - Patients in the placebo arm appear to experience infections earlier and 
#   more frequently
# - The risk table confirms that patient dropout is not driving the difference

# ================================================================================
# QUESTION 1: Treatment Effect Analysis
# What is the hazard ratio and 95% CI comparing placebo vs. gamma interferon?
# ================================================================================

# coxph(): Fits a Cox Proportional Hazards model
# - This model estimates the "hazard ratio" - the relative risk of the event
# - Unlike Kaplan-Meier, Cox regression can adjust for multiple predictors
# - Surv(tstop, status) ~ treat: Models time-to-infection as a function of treatment
mfit <- coxph(Surv(tstop, status) ~ treat, data=cgd)

# summary(): Displays complete model output including:
# - Coefficients (log hazard ratios)
# - Hazard ratios (exp(coef))
# - Standard errors and p-values
# - 95% Confidence intervals
# - Concordance statistic (model discrimination)
summary(mfit)

# UNDERSTANDING THE OUTPUT:
# The model estimates "treat" (gamma interferon) vs. placebo (reference)
# If we want PLACEBO vs. GAMMA, we need to invert the hazard ratio.

# Calculate hazard ratio for PLACEBO vs. GAMMA (inverting the coefficient)
# Original HR for gamma vs placebo = 0.3349
# Inverted HR for placebo vs gamma = 1/0.3349 = 2.99
1/.3349  # HR = 2.99

# Calculate 95% Confidence Interval bounds (also inverted)
1/.6454  # Lower CI = 1.55
1/.1737  # Upper CI = 5.76

# STATISTICAL INTERPRETATION:
# Model Results:
# - Log hazard coefficient for treat = -1.0940 (SE: 0.3348)
# - This negative coefficient means gamma interferon REDUCES hazard
# - Hazard Ratio (Placebo vs Gamma): 2.99 [95% CI: 1.55, 5.76]
# - P-value = 0.001 (highly statistically significant)
# - Concordance = 0.621 (SE: 0.036) — moderate model discrimination

# CLINICAL INTERPRETATION:
# - Patients on PLACEBO had approximately 3 TIMES the risk of developing 
#   a serious infection compared to those receiving gamma interferon
# - We are 95% confident the true hazard ratio is between 1.55 and 5.76
# - The entire confidence interval is above 1.0, confirming the treatment benefit
# - In clinical terms: For every patient who develops an infection on gamma 
#   interferon, about 3 patients develop infections on placebo
# - This represents a clinically meaningful and statistically significant effect

# ================================================================================
# QUESTION 2: Sex Effect Analysis
# Is there an association between sex and infection risk?
# ================================================================================

# Fit Cox model examining sex effect
# sex = 0 (male) is the reference category; sex = 1 (female) is compared to it
mfit2.cgd <- coxph(Surv(tstop, status) ~ sex, data=cgd)
summary(mfit2.cgd)

# STATISTICAL INTERPRETATION:
# Model Results:
# - Log hazard coefficient for sex = 0.2127 (SE: 0.4123)
# - Hazard Ratio (Male vs Female): exp(0.2127) = 1.24 [95% CI: 0.55, 2.78]
# - P-value = 0.606 (NOT statistically significant at alpha = 0.05)
# - Concordance = 0.507 (SE: 0.031) — essentially no discriminative ability

# CLINICAL INTERPRETATION:
# - Males had a 24% higher point estimate of infection risk compared to females
# - HOWEVER, this difference was NOT statistically significant (p = 0.606)
# - The wide 95% CI [0.55, 2.78] includes 1.0, indicating uncertainty
# - We CANNOT conclude there is a true difference in infection risk by sex
# - The small number of female patients (18.7%) limits statistical power
# - Clinical decision-making should NOT differ based on patient sex in this context

# ================================================================================
# QUESTION 3: Visualizing Sex Effect
# Create and interpret Kaplan-Meier plots stratified by sex
# ================================================================================

# Create Kaplan-Meier survival curves stratified by sex
mfit.sex <- survfit(Surv(tstop, status) ~ sex, data=cgd)

# Generate plot with risk table
ggsurvplot(mfit.sex, data=cgd,
           ggtheme=theme_minimal(),
           legend.labs = c("Female","Male"),
           risk.table = TRUE)

# STATISTICAL INTERPRETATION:
# - The survival curves for males and females overlap substantially
# - No consistent pattern of separation between groups
# - Risk table shows the female group (n=24) is much smaller than male (n=104)

# CLINICAL INTERPRETATION:
# - The overlapping curves visually confirm the non-significant Cox result
# - There is no clear evidence that sex predicts infection risk in CGD patients
# - The small female sample means we should interpret this result cautiously
# - Larger studies would be needed to definitively rule out a sex difference

# ================================================================================
# QUESTION 4: Age Effect Analysis
# Is there an association between age and infection risk?
# ================================================================================

# Fit Cox model examining age as a CONTINUOUS predictor
# For continuous predictors, the hazard ratio represents the change per 1-unit
mfit.age <- coxph(Surv(tstop, status) ~ age, data=cgd)
summary(mfit.age)

# STATISTICAL INTERPRETATION:
# Model Results:
# - Log hazard coefficient for age = -0.02121 (SE: 0.01682)
# - Hazard Ratio (per 1-year increase): exp(-0.02121) = 0.979 [95% CI: 0.947, 1.012]
# - P-value = 0.207 (NOT statistically significant at alpha = 0.05)
# - Concordance = 0.570 (SE: 0.048) — weak discriminative ability

# CLINICAL INTERPRETATION:
# - For each 1-year INCREASE in age, the hazard of infection DECREASES by 2.1%
# - This suggests a trend: older patients may be at slightly lower risk
# - HOWEVER, this trend is NOT statistically significant (p = 0.207)
# - The 95% CI [0.947, 1.012] includes 1.0, so we cannot rule out no effect
# - Possible biological rationale: immune systems may mature with age, 
#   providing better defense even in CGD patients

# ================================================================================
# QUESTION 5: Age Effect Over 5 Years
# What is the hazard ratio for a 5-year increase in age?
# ================================================================================

# For continuous predictors, we often want clinically meaningful intervals
# A 1-year change is small; a 5-year change is more clinically relevant

# MATHEMATICAL PRINCIPLE:
# If HR for 1 year = exp(β), then HR for 5 years = exp(5 × β)
# This is because hazards multiply: HR^5 = exp(β)^5 = exp(5β)

# Calculate 5-year age effect
# Coefficient for age = -0.02121
# 5-year log-HR = 5 × (-0.02121) = -0.10605
exp(5 * -0.02121)  # HR = 0.899 (approximately 0.90)

# Calculate 95% Confidence Interval for the 5-year effect
# confint() extracts the confidence interval for the model coefficient
# We multiply by 5 and exponentiate to get the CI for 5-year change
exp(5 * confint(mfit.age))  # 95% CI for 5-year change

# STATISTICAL INTERPRETATION:
# Calculations:
# - 5-year log hazard coefficient = 5 × (-0.02121) = -0.10605
# - Hazard Ratio (per 5-year increase): 0.90 [95% CI: 0.76, 1.06]

# CLINICAL INTERPRETATION:
# - For every 5-year increase in age, the hazard of infection decreases by ~10%
# - Example: A 15-year-old has approximately 10% lower risk than a 10-year-old
# - HOWEVER, this effect remains statistically NON-SIGNIFICANT
# - The 95% CI [0.76, 1.06] crosses 1.0, so we cannot rule out no effect
# - While the direction suggests older patients do better, the evidence is 
#   not strong enough to base clinical decisions on age alone
# - The observed trend may reflect survivor bias (sicker patients may die young)
#   or true immune maturation effects

# ================================================================================
# SUMMARY: KEY FUNCTION REFERENCE
# ================================================================================
#
# Surv(time, status): Creates a "survival object"
#   - time: follow-up time (numeric)
#   - status: event indicator (1 = event, 0 = censored)
#   - This is the LEFT side of survival model formulas
#
# coxph(Surv(time, status) ~ predictors, data): Fits Cox PH model
#   - Returns log hazard ratios (coefficients)
#   - Exponentiate coefficients to get Hazard Ratios
#   - P-values test if HR differs significantly from 1.0
#
# survfit(Surv(time, status) ~ group, data): Kaplan-Meier estimates
#   - Use ~1 for overall (unstratified) estimate
#   - Use ~group to stratify by a categorical variable
#
# ggsurvplot(fit, data): Publication-quality survival plots
#   - risk.table = TRUE: Adds number-at-risk table
#   - legend.labs: Customize legend labels
#
# exp(coefficient): Converts log-HR to Hazard Ratio
#   - HR > 1: increased risk
#   - HR < 1: decreased risk (protective)
#   - HR = 1: no effect
#
# confint(model): Extracts confidence intervals for coefficients
#   - Exponentiate for CI of Hazard Ratio
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# End of Analysis
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
