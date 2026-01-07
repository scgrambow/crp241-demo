# =============================================================
# Title: Interaction (Effect Modification) in Regression (CRP 241)
# Audience: Physicians in an intro statistics course
# Learning goals:
# - Understand what interaction (effect modification) means
# - Recognize when an effect differs across subgroups
# - Use regression with interaction terms to test for effect modification
# - Interpret stratified analyses and visualizations
# Data description:
# - Example 1: FEV1 (liters) in COPD patients by smoking status and age
#   (n=200, from clinical practice)
# - Example 2: Birth weight (grams) by mother's age and smoking status
#   (n=189, from Baystate Medical Center, Springfield, MA)
# How to run:
# - In R, run sections in order. Each step explains why and what it does.
# Wrap: Comments are kept to ≤80 characters for readability.
# =============================================================

# 1) Setup -----------------------------------------------------
# Why: Ensure required packages are available and loaded (none needed
#      beyond base R for this script).
# What: No additional packages required for this analysis.

# 2) Example 1: FEV1 and Smoking in COPD Patients -------------
# Context (stat): Two-sample tests and regression with interaction term.
# Context (clin): COPD patients; smoking damages lungs. Does the effect
#                 of smoking on FEV1 differ by age (<65 vs ≥65)?

# Study background:
# A study examined whether smoking status (current/recent/former vs non-
# smoker) is associated with FEV1 in COPD patients. Age (≥65 vs <65) was
# also recorded. 200 patients were randomly selected from a clinical
# practice.

# Data Dictionary:
# FEV1      forced expiratory volume in one second (liters)
# SMOKING   patient smoking status (1 = current/recent/former smoker;
#           0 = non-smoker)
# AGE65     patient age (1 = age ≥65 years; 0 = age <65 years)

# What: Download and load the FEV1 smoking dataset.
# Why: To access the data for analysis.
load(url("https://www.duke.edu/~sgrambow/crp241data/fev1_smoking.RData"))

# What: Examine the structure of the dataset.
# Why: Verify variable types, coding, and number of observations.
str(fsdata)

# What: Get summary statistics for all variables.
# Why: Understand distributions, check for missing values, and confirm
#      coding (0/1 for binary variables).
summary(fsdata)

# What: Subset the data by age group.
# Why: We will perform stratified analyses to see if the smoking effect
#      differs by age.
old   <- subset(fsdata, AGE65 == 1)
young <- subset(fsdata, AGE65 == 0)

# What: Summary statistics for FEV1 by age group.
# Why: Quick check of FEV1 distribution in each age stratum.
by(fsdata$FEV1, fsdata$AGE65, summary)
# Stat interpretation: Compare mean FEV1 for age <65 vs ≥65.
# Clinical interpretation: Expect older patients to have lower FEV1
# (age-related lung function decline).

# What: Summary statistics for FEV1 by smoking status.
# Why: Quick check of FEV1 distribution by smoking group.
by(fsdata$FEV1, fsdata$SMOKING, summary)
# Stat interpretation: Compare mean FEV1 for smokers vs non-smokers.
# Clinical interpretation: Expect smokers to have lower FEV1 (smoking
# damages airways and lung tissue).

# (1) Two-sample t-test in entire cohort -----------------------
# Why: Test if FEV1 differs by smoking status, ignoring age.
# What: t-test assuming equal variances; compares two groups.
t.test(fsdata$FEV1 ~ fsdata$SMOKING, var.equal = T)

# What: Manually calculate the difference in means.
# Why: Confirm the direction and magnitude of the effect.
3.233291 - 3.920575
# Stat interpretation: Non-smokers have higher mean FEV1 by ~0.69 liters.
# Clinical interpretation: Smoking (current/recent/former) is associated
# with reduced lung function. However, this does not account for age.

# (2) Two-sample t-test stratified by age ----------------------
# Why: Check if the smoking effect differs by age group.

# (2a) Among age <65 years
# What: Summary stats for FEV1 by smoking status in younger group.
# Why: Understand distribution before testing.
by(young$FEV1, young$SMOKING, summary)
summary(young$FEV1)

# What: t-test for smoking effect among younger patients.
# Why: Estimate smoking effect in this age stratum.
t.test(young$FEV1 ~ young$SMOKING, var.equal = T)

# What: Calculate difference in means for younger patients.
3.604099 - 3.961962
# Stat interpretation: Among younger patients, non-smokers have ~0.36
# liters higher FEV1.
# Clinical interpretation: Smoking effect is present but modest in
# younger COPD patients.

# (2b) Among age ≥65 years
# What: Summary stats for FEV1 by smoking status in older group.
# Why: Understand distribution before testing.
by(old$FEV1, old$SMOKING, summary)
summary(old$FEV1)

# What: t-test for smoking effect among older patients.
# Why: Estimate smoking effect in this age stratum.
t.test(old$FEV1 ~ old$SMOKING, var.equal = T)

# What: Calculate difference in means for older patients.
2.862483 - 3.879188
# Stat interpretation: Among older patients, non-smokers have ~1.02
# liters higher FEV1.
# Clinical interpretation: Smoking effect is larger (nearly 3× bigger)
# in older COPD patients. This suggests interaction (effect modification):
# the smoking effect depends on age.

# (3) Linear regression with interaction term ------------------
# Why: Formally test if the smoking effect differs by age using an
#      interaction term (SMOKING*AGE65).
# What: Fit a model with main effects and interaction.
ifit <- lm(FEV1 ~ SMOKING + AGE65 + SMOKING*AGE65, data = fsdata)
summary(ifit)

# Stat interpretation: If the interaction term (SMOKING:AGE65) is
# statistically significant (p < 0.05), the smoking effect differs by age.
# Clinical interpretation: A significant interaction means we should report
# smoking effects separately for each age group, not pooled. The stratified
# results (2a, 2b) show the age-specific effects.

# (4) Linear regression stratified by age ----------------------
# Why: Quantify the smoking effect within each age stratum using regression.
#      Compare to t-test results (should match).

# (4a) Among age <65 years
# What: Fit simple linear regression: FEV1 ~ SMOKING in younger patients.
# Why: Estimate the smoking effect and 95% CI for this age group.
yfit <- lm(FEV1 ~ SMOKING, data = young)
summary(yfit)
confint(yfit)
# Stat interpretation: Slope for SMOKING is the difference in mean FEV1
# (smokers - non-smokers). Should match t-test result from (2a).
# Clinical interpretation: In younger COPD patients, smoking is associated
# with a modest reduction in FEV1. CI tells us uncertainty around the effect.

# (4b) Among age ≥65 years
# What: Fit simple linear regression: FEV1 ~ SMOKING in older patients.
# Why: Estimate the smoking effect and 95% CI for this age group.
ofit <- lm(FEV1 ~ SMOKING, data = old)
summary(ofit)
confint(ofit)
# Stat interpretation: Slope for SMOKING should match t-test from (2b).
# Clinical interpretation: In older COPD patients, smoking is associated
# with a much larger reduction in FEV1. The effect is nearly triple that
# in younger patients, suggesting age modifies the smoking effect.

# (5) Linear regression ignoring age ---------------------------
# Why: Show the overall (unadjusted) smoking effect, pooling age groups.
# What: Fit simple linear regression: FEV1 ~ SMOKING in entire cohort.
ufit <- lm(FEV1 ~ SMOKING, data = fsdata)
summary(ufit)
confint(ufit)
# Stat interpretation: This is the crude smoking effect, averaging across
# age groups. Should match t-test result from (1).
# Clinical interpretation: This pooled estimate masks the age-specific
# effects. If interaction is present, stratified results are more informative.

# 3) Example 2: Birth Weight and Mother's Age -----------------
# Context (stat): Simple regression, interaction, and stratified analysis.
# Context (clin): Low birth weight (<2500g) is a risk factor for infant
#                 morbidity and mortality. Does mother's age affect birth
#                 weight? Does smoking modify this relationship?

# Study background:
# A study at Baystate Medical Center examined variables related to low birth
# weight. 189 mothers were randomly selected.

# Data Dictionary:
# bwt     birth weight of baby (grams)
# age     age of mother during pregnancy (years)
# smoke   smoking status of mother during pregnancy (1 = smoker;
#         0 = non-smoker)

# What: Download and load the birth weight dataset.
# Why: To access the data for analysis.
load(url("https://www.duke.edu/~sgrambow/crp241data/bwdata.RData"))

# Question 1: Is there evidence of an association between mother's age
#             and baby's birth weight?
# Why: Understand if maternal age predicts birth weight overall.
# What: Fit simple linear regression: bwt ~ age.
fit1 <- lm(bwt ~ age, data = bwdata)
summary(fit1)
# Stat interpretation: Slope for age is the change in birth weight (grams)
# per 1-year increase in mother's age. Check p-value for significance.
# Clinical interpretation: If positive, older mothers have heavier babies
# (on average). If negative, younger mothers have heavier babies. Consider
# biological plausibility and confounding.

# Question 2: Create a figure to describe the relationship.
# Why: Visualize the linear relationship between age and birth weight.
# What: Scatterplot with fitted regression line.
plot(bwdata$age, bwdata$bwt,
     xlab = 'Mothers Age During Pregnancy (years)',
     ylab = 'Babys Birth Weight (grams)',
     cex = 2)
abline(fit1, lwd = 3)
# Stat interpretation: Line slope shows the direction and strength of the
# association. Scatter shows variability around the line.
# Clinical interpretation: Visual check for linearity and outliers. Does
# the relationship look plausible clinically?

# Question 3: Does the association between age and birth weight depend on
#             smoking status (effect modification)?
# Why: Test if smoking modifies the age-birth weight relationship.
# What: Fit regression with interaction: bwt ~ age + smoke + age*smoke.
fit2 <- lm(bwt ~ age + smoke + age*smoke, data = bwdata)
summary(fit2)
# Stat interpretation: If age:smoke interaction term is significant
# (p < 0.05), the slope for age differs by smoking status.
# Clinical interpretation: Significant interaction means the effect of
# maternal age on birth weight differs between smokers and non-smokers.
# We should report age effects separately for each group.

# Question 4: Modify the figure to show effect modification.
# Why: Visualize how the age-birth weight relationship differs by smoking.
# What: Subset data by smoking status and fit separate regressions.

# What: Subset data by smoking status.
# Why: To fit separate models and plot separate lines.
smoker    <- subset(bwdata, smoke == 1)
nonsmoker <- subset(bwdata, smoke == 0)

# What: Fit regression among smokers.
# Why: Estimate age effect in smokers.
fit3 <- lm(bwt ~ age, data = smoker)
summary(fit3)
confint(fit3)
# Stat interpretation: Slope for age among smokers.
# Clinical interpretation: How does maternal age affect birth weight in
# mothers who smoke?

# What: Fit regression among non-smokers.
# Why: Estimate age effect in non-smokers.
fit4 <- lm(bwt ~ age, data = nonsmoker)
summary(fit4)
confint(fit4)
# Stat interpretation: Slope for age among non-smokers.
# Clinical interpretation: How does maternal age affect birth weight in
# mothers who do not smoke?

# What: Create a scatterplot with separate lines for smokers and non-smokers.
# Why: Show visually how the age-birth weight relationship differs by
#      smoking status (effect modification).
plot(nonsmoker$age, nonsmoker$bwt,
     xlab = 'Mothers Age During Pregnancy (years)',
     ylab = 'Babys Birth Weight (grams)',
     col = 'royalblue', cex = 2)
points(smoker$age, smoker$bwt,
       col = 'sienna3', pch = 19, cex = 2)
abline(fit4, col = 'royalblue', lty = 2, lwd = 3)
abline(fit3, col = 'sienna3', lwd = 3)
legend('topleft', c('Smoker', 'Non-Smoker'),
       col = c('sienna3', 'royalblue'),
       lty = c(1, 2), lwd = 2, horiz = T)
# Stat interpretation: Different slopes indicate interaction. Parallel lines
# would indicate no interaction (same age effect in both groups).
# Clinical interpretation: If lines have different slopes, maternal age
# affects birth weight differently in smokers vs non-smokers. For example,
# if the slope is steeper in non-smokers, older non-smoking mothers have
# heavier babies, but this benefit is reduced or absent in smokers. Smoking
# may blunt the positive effect of maternal age on fetal growth.

# 4) Interpret and conclude ------------------------------------
# Summary (stat):
# - Interaction occurs when the effect of one variable depends on another.
# - Test with an interaction term in regression; if p < 0.05, interaction
#   is present.
# - Stratified analyses and plots show the group-specific effects.

# Summary (clinical):
# - Example 1: Smoking's impact on FEV1 is larger in older COPD patients.
#   Age modifies the smoking effect. Report effects separately by age.
# - Example 2: Maternal age's effect on birth weight may differ by smoking
#   status. Smoking could reduce the benefit of older maternal age on fetal
#   growth.
# - Always consider biological plausibility when interpreting interactions.
#   Not all statistical interactions are clinically meaningful.

# --------------------------------------------------
# End of Program
