# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CRP 241 — Confounding in Regression Analysis
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Audience: Physician learners with little or no programming experience.
# Goal: Learn to identify and adjust for confounding variables in regression
#       analysis. You'll see how a third variable can distort the relationship
#       between an exposure and outcome, and learn how regression "adjusts"
#       for confounders to reveal the true association.
#
# How to use this script
# - You can run the script line-by-line (recommended for learning) or run the
#   whole file. Lines starting with # are comments that explain what is
#   happening; they are not executed by R.
# - This script does not change your data; it only reads data and makes plots
#   and summaries.
#
# Quick cheat sheet (printable)
# - What is confounding?
#   - A third variable (confounder) is associated with BOTH the exposure and
#     outcome, creating a spurious or distorted association between them.
# - Checking for confounding
#   - Step 1: Is the potential confounder associated with the exposure?
#   - Step 2: Is the potential confounder associated with the outcome?
#   - If YES to both, it may be a confounder.
# - How regression adjusts
#   - "Adjusting" means including the confounder in the regression model.
#   - The adjusted coefficient tells you the exposure-outcome relationship
#     after accounting for the confounder.
#   - This is like comparing within strata (e.g., comparing males to males,
#     females to females) and averaging the results.
# - Key comparison
#   - Unadjusted model: exposure only (may be biased by confounding)
#   - Adjusted model: exposure + confounder (accounts for confounding)
# - Important note
#   - t-tests with equal variances give the same answer as simple linear
#     regression when comparing two groups. But only regression can adjust
#     for confounders!
#
# ================================================================================
# EXAMPLE 1: FEV1 and Genetic Variation — Is Sex a Confounder?
# ================================================================================
#
# Study background:
# A study was conducted to determine if there was an association between a
# genetic variant and forced expiratory volume in one second (FEV1) in
# patients with COPD. FEV1 measures lung function (in liters); lower values
# indicate worse lung function. Genotypes of interest were wild type vs.
# mutant (i.e., heterozygous or homozygous for the risk allele). Sex at birth
# was also recorded. 100 patients were randomly selected from the researchers'
# clinical practice.
#
# Clinical question:
# Does this genetic variant affect lung function (FEV1)? If we see a
# difference in FEV1 between wild type and mutant genotypes, is it real or
# could it be explained by sex differences (since males and females have
# different lung capacities)?
#
# Data Dictionary:
# 1.  FEV1      forced expiratory volume in one second (liters)
# 2.  GENO      patient genotypes (1 = Mutant; 0 = Wild Type)
# 3.  SEX       patient sex at birth (1 = Female; 0 = Male)

# ------------------------------------------------------------------------------------
# Loading and examining the data
#
# This section downloads the FEV1 genetic variation dataset and examines its
# structure and content.

# Download and load the FEV1 genotype dataset from the course website
# - This creates a data frame called 'fgdata' in your R environment.
# - The dataset contains 100 observations (patients) with 3 variables.
load(url("https://www.duke.edu/~sgrambow/crp241data/fev1_geno.RData"))

# Examine the structure of the dataset
# - str() shows variable names, types (numeric, integer), and first few values
# - This helps confirm the data loaded correctly and variables are coded as
#   expected (e.g., GENO and SEX should be 0 or 1).
str(fgdata) 

# Get summary statistics for all variables
# - summary() provides min, 1st quartile, median, mean, 3rd quartile, and max
# - For FEV1: you'll see the range of lung function values (in liters)
# - For GENO and SEX: you'll see the mean, which tells you the proportion
#   coded as 1 (e.g., mean of 0.5 = 50% mutant, 50% wild type)
summary(fgdata) 


# ------------------------------------------------------------------------------------
# Creating labeled versions of coded variables
#
# Right now, SEX and GENO are coded as numbers (0/1), which is fine for
# analysis but hard to interpret in tables and plots. We'll create "factor"
# versions with text labels to make output more readable.

# Create a labeled version of the SEX variable
# - factor() converts numeric codes to a categorical variable with labels
# - SEX = 0 becomes "Male"; SEX = 1 becomes "Female"
# - The new variable fSEX will display as "Male" or "Female" in tables/plots
fgdata$fSEX <- factor(fgdata$SEX,labels=c('Male','Female'))

# Create a labeled version of the GENO variable
# - GENO = 0 becomes "Wild Type"; GENO = 1 becomes "Mutant"
# - The new variable fGENO will display as "Wild Type" or "Mutant"
fgdata$fGENO <- factor(fgdata$GENO,labels=c('Wild Type','Mutant'))

# Verify the structure of the dataset with the new labeled variables
# - You should now see fSEX and fGENO as "Factor" variables with 2 levels
str(fgdata)

# Double-check that the labels match the numeric codes correctly
# - This cross-tabulation shows how the labeled variable (rows) corresponds
#   to the numeric variable (columns)
# Recall: SEX = 0 is Male, SEX = 1 is Female
table(fgdata$fSEX,fgdata$SEX)

# Recall: GENO = 0 is Wild Type, GENO = 1 is Mutant
table(fgdata$fGENO,fgdata$GENO)

# ------------------------------------------------------------------------------------
# Step 1: Checking if sex is a confounder
#
# For sex to be a confounder of the genotype-FEV1 relationship, sex must be
# associated with BOTH genotype (the exposure) AND FEV1 (the outcome).
# Let's check each criterion.
#
# Criterion 1: Is sex associated with genotype (the exposure)?
# - If the distribution of males and females differs between genotype groups,
#   then sex is associated with genotype.
# - We'll examine this using a cross-tabulation (contingency table).

# Create a cross-tabulation of sex by genotype (counts)
# - Rows = sex (Male, Female)
# - Columns = genotype (Wild Type, Mutant)
# - Each cell shows the count of patients in that sex-genotype combination
table(fgdata$fSEX,fgdata$fGENO)

# Convert counts to proportions within each genotype group
# - The argument "2" means calculate proportions by column (genotype)
# - This shows the percentage of males and females within each genotype
# - If proportions are similar (e.g., 50% female in both groups), sex is NOT
#   associated with genotype; if different, sex IS associated with genotype
prop.table(table(fgdata$fSEX,fgdata$fGENO),2)

# What to look for in the output:
# - Compare the proportion of females in Wild Type vs. Mutant groups
# - Example: 38% female in Wild Type vs. 66% female in Mutant
# - This difference suggests sex IS associated with genotype (Criterion 1 met)

# ------------------------------------------------------------------------------------
# Criterion 2: Is sex associated with FEV1 (the outcome)?
#
# Now we check if FEV1 differs between males and females. If it does, then
# sex is associated with the outcome.
# - We'll use boxplots to visualize the distribution of FEV1 by sex.

# Create a simple boxplot of FEV1 by sex
# - The ~ symbol means "by" (FEV1 by sex groups)
# - Boxplot shows median (middle line), quartiles (box edges), and range
#   (whiskers)
boxplot(fgdata$FEV1~fgdata$fSEX,
        ylab='FEV1 Level (liters)')

# Create an enhanced boxplot with titles, colors, and overlaid data
# - main: adds a title to the plot
# - ylab/xlab: labels for y-axis and x-axis
# - col: colors for each box (sienna for males, light blue for females)
# - range=0: extends whiskers to min/max (no outlier cutoff)
boxplot(fgdata$FEV1~fgdata$fSEX,
        main='FEV1 by Sex',
        ylab='FEV1 Level (liters)',
        xlab=c('Sex'),
        col=c('sienna','lightblue'),
        range=0)

# Overlay individual data points on the boxplot
# - stripchart() adds dots for each patient's FEV1 value
# - method="jitter": spreads points horizontally to avoid overlap
# - vertical=TRUE: aligns points with the vertical boxplot
# - add=TRUE: adds points to the existing plot (doesn't create a new plot)
stripchart(fgdata$FEV1~fgdata$fSEX,method = "jitter", 
           pch=16,vertical = TRUE,add=TRUE)

# Create subsets of the data for males and females separately
# - This allows us to calculate sex-specific summary statistics
males <- subset(fgdata,fSEX=='Male')
females <- subset(fgdata,fSEX=='Female')

# Calculate the mean FEV1 for males
mean.males <- mean(males$FEV1)

# Calculate the mean FEV1 for females
mean.females <- mean(females$FEV1)

# Store both means in a vector for plotting
# - This creates a vector: c(mean for males, mean for females)
sex.means <- c(mean.males,mean.females)

# Add the mean values as large orange dots on the boxplot
# - points() adds symbols to an existing plot
# - cex=1.7: makes points larger (1.7x default size)
# - pch=16: solid circle symbol
# - The position matches the boxplot x-axis (male = 1, female = 2)
points(sex.means,cex=1.7,pch=16,col="dark orange")

# What to look for in the output:
# - Do the boxplots overlap or are they clearly separated?
# - Are the mean values (orange dots) noticeably different?
# - If yes, sex IS associated with FEV1 (Criterion 2 met)
# - If BOTH criteria are met, sex may be a confounder!

# ------------------------------------------------------------------------------------
# Preparing for the main analysis
#
# Before we examine the genotype-FEV1 relationship, let's create subsets by
# genotype and calculate mean FEV1 for each group. This helps us understand
# the unadjusted (crude) association before we adjust for sex.

# Create a subset of patients with Wild Type genotype
wild <-subset(fgdata,fGENO == 'Wild Type')

# Create a subset of patients with Mutant genotype
mutant <-subset(fgdata,fGENO == 'Mutant')

# Calculate mean FEV1 for Wild Type patients
mean.wild <- mean(wild$FEV1)

# Calculate mean FEV1 for Mutant patients
mean.mutant <- mean(mutant$FEV1)

# ------------------------------------------------------------------------------------
# Analysis 1: Two-sample t-test (unadjusted comparison)
#
# This is the traditional approach to comparing two groups. We'll use a
# t-test with equal variances assumed to compare mean FEV1 between genotypes.
# Important: This does NOT adjust for sex; it's the crude comparison.

# Perform a two-sample t-test comparing FEV1 between genotypes
# - var.equal=T: assumes equal variances in both groups (similar to what
#   linear regression assumes)
# - The ~ symbol means "by" (FEV1 by GENO groups)
t.test(fgdata$FEV1~fgdata$GENO,var.equal=T)

# What to look for in the output:
# - Mean in group 0 (Wild Type) and mean in group 1 (Mutant)
# - Difference in means
# - 95% confidence interval for the difference
# - p-value: Is the difference statistically significant?

# Calculate the difference in means manually for comparison
# - Positive value means Wild Type has higher mean FEV1 than Mutant
mean.wild - mean.mutant

# Note: The difference is approximately 0.4168 liters

# ------------------------------------------------------------------------------------
# Analysis 2: Simple linear regression (unadjusted comparison)
#
# Now we'll analyze the same comparison using simple linear regression.
# This shows that t-tests and simple linear regression are equivalent when
# comparing two groups!

# Fit a simple linear regression model: FEV1 as outcome, GENO as predictor
# - lm() fits a linear model
# - FEV1 ~ GENO means "FEV1 is explained by GENO"
# - The model estimates: FEV1 = intercept + (slope × GENO)
ufit <- lm(FEV1 ~ GENO, data=fgdata)

# Display the regression results
# - Intercept: mean FEV1 for Wild Type (GENO = 0)
# - Slope for GENO: change in mean FEV1 for Mutant vs. Wild Type
# - R-squared: proportion of variation in FEV1 explained by genotype
# - p-value for GENO: tests if genotype is associated with FEV1
summary(ufit)

# Calculate 95% confidence intervals for the intercept and slope
# - These tell you the uncertainty around the mean difference
confint(ufit)

# Display the ANOVA table for the regression model
# - Tests the overall significance of the model
# - F-statistic and p-value: Is the model with GENO better than a model
#   with no predictors?
summary(aov(ufit))

# Calculate the difference in means in the opposite direction
# - Regression compares Mutant (1) to Wild Type (0), so the sign is reversed
# - This should equal the slope coefficient (with opposite sign)
mean.mutant - mean.wild

# KEY TEACHING POINT:
# The slope coefficient from regression (-0.41683) equals the difference in
# means from the t-test (0.4168), just with opposite sign. A t-test with
# equal variances and simple linear regression give the SAME answer when
# comparing two groups. The advantage of regression: we can adjust for
# confounders (which we can't do with a t-test)!

# ------------------------------------------------------------------------------------
# Analysis 3: Multiple linear regression (adjusted comparison)
#
# Now we adjust for sex by including it in the regression model alongside
# genotype. This controls for sex and gives us the genotype-FEV1 association
# within sex groups (like comparing males to males, females to females).
# Important: We CANNOT do this with a t-test! This is why regression is so
# powerful.

# Fit a multiple linear regression model: FEV1 ~ GENO + SEX
# - The model estimates: FEV1 = intercept + (slope₁ × GENO) + (slope₂ × SEX)
# - Slope for GENO: effect of genotype on FEV1, adjusted for sex
# - Slope for SEX: effect of sex on FEV1, adjusted for genotype
afit <- lm(FEV1 ~ GENO + SEX, data=fgdata)

# Display the adjusted regression results
# - Intercept: mean FEV1 for Wild Type males (GENO=0, SEX=0)
# - Slope for GENO: change in mean FEV1 for Mutant vs. Wild Type, holding
#   sex constant (this is the adjusted effect we care about!)
# - Slope for SEX: change in mean FEV1 for females vs. males, holding
#   genotype constant
# - Compare the GENO coefficient here to the unadjusted model (ufit)
summary(afit)

# Calculate 95% confidence intervals for all coefficients
# - These show the uncertainty around each adjusted effect
confint(afit)

# Display the ANOVA table for the adjusted model
# - This shows how much variation each variable explains
# - Compare the p-values for GENO and SEX
summary(aov(afit))

# What to look for in the output:
# - Did the GENO coefficient change from the unadjusted model?
# - If yes, sex was confounding the genotype-FEV1 relationship
# - The adjusted coefficient is the "true" effect after removing the
#   distortion caused by sex differences between genotype groups


# ------------------------------------------------------------------------------------
# Understanding how "adjusting" works: Stratified analysis
#
# This section demonstrates what regression is doing "behind the scenes" when
# it adjusts for a confounder. We'll manually calculate the genotype effect
# within each sex group, then average them. This approximates what the
# adjusted regression coefficient represents.

# Analysis 4: Manual stratified analysis (comparing within sex groups)
# 
# We already created subsets for males and females earlier. Now we'll further
# subdivide by genotype to calculate sex-specific mean differences.

# Create subsets of females by genotype
females.mutant <- subset(females,fGENO=='Mutant')
females.wild <- subset(females,fGENO=='Wild Type')

# Calculate mean FEV1 for Mutant females
mean.females.mutant <- mean(females.mutant$FEV1)

# Calculate mean FEV1 for Wild Type females
mean.females.wild <- mean(females.wild$FEV1)

# Display the means for females
mean.females.mutant
mean.females.wild

# Calculate the difference in mean FEV1 between Mutant and Wild Type females
# - This is the genotype effect AMONG FEMALES ONLY
mean.females.mutant - mean.females.wild

# What to look for:
# - This difference represents the genotype effect in females, free from
#   confounding by sex (since we're only looking at one sex)

# ------------------------------------------------------------------------------------
# Now repeat the same analysis for males

# Create subsets of males by genotype
males.mutant <- subset(males,fGENO=='Mutant')
males.wild <- subset(males,fGENO=='Wild Type')

# Calculate mean FEV1 for Mutant males
mean.males.mutant <- mean(males.mutant$FEV1)

# Calculate mean FEV1 for Wild Type males
mean.males.wild <- mean(males.wild$FEV1)

# Display the means for males
mean.males.mutant
mean.males.wild

# Calculate the difference in mean FEV1 between Mutant and Wild Type males
# - This is the genotype effect AMONG MALES ONLY
mean.males.mutant - mean.males.wild

# What to look for:
# - This difference represents the genotype effect in males, free from
#   confounding by sex

# ------------------------------------------------------------------------------------
# Calculate the average of the sex-specific differences
#
# This is the key to understanding adjustment! When regression "adjusts" for
# sex, it essentially:
# 1. Calculates the genotype effect within each sex group
# 2. Averages these sex-specific effects (weighted by sample size)
# The result approximates the adjusted regression coefficient.

# Average of the two sex-specific differences
# - Add the female difference and male difference, then divide by 2
# - This should be close to the GENO coefficient from the adjusted model
((mean.females.mutant - mean.females.wild) +
    (mean.males.mutant - mean.males.wild)) / 2

# What to look for:
# - Compare this average to the GENO coefficient in the adjusted model (afit)
# - They should be very similar!
# - This demonstrates that "adjusting" means comparing within strata and
#   averaging the results
         
# ------------------------------------------------------------------------------------
# Analysis 4a: Simple linear regression within females only
#
# Instead of calculating means manually, we can fit a simple linear
# regression model within the female subset. This gives us the same genotype
# effect (plus confidence intervals and p-values).

# Fit a simple linear regression model using only female patients
# - This estimates the genotype effect among females
ffit <- lm(FEV1 ~ GENO, data=females)

# Display the regression results for females
# - The slope for GENO is the genotype effect among females only
# - Compare this to the manual calculation above
summary(ffit)

# Calculate 95% confidence intervals for the coefficients
# - This gives uncertainty around the genotype effect in females
confint(ffit)

# Note: The slope coefficient should match the manual calculation
# (mean.females.mutant - mean.females.wild)

# ------------------------------------------------------------------------------------
# Analysis 4b: Simple linear regression within males only
#
# Now fit a simple linear regression model within the male subset.

# Fit a simple linear regression model using only male patients
# - This estimates the genotype effect among males
mfit <- lm(FEV1 ~ GENO, data=males)

# Display the regression results for males
# - The slope for GENO is the genotype effect among males only
# - Compare this to the manual calculation above
summary(mfit)

# Calculate 95% confidence intervals for the coefficients
# - This gives uncertainty around the genotype effect in males
confint(mfit)

# Note: The slope coefficient should match the manual calculation
# (mean.males.mutant - mean.males.wild)

# KEY TEACHING POINT:
# The sex-specific slopes from these stratified regressions (ffit and mfit)
# are averaged (conceptually) in the adjusted multiple regression model (afit).
# This is how regression "adjusts" for confounders: it estimates the
# exposure-outcome relationship within levels of the confounder, then
# combines them into a single adjusted estimate.

# ================================================================================
# EXAMPLE 2: Lead Exposure Study — Is Age a Confounder?
# ================================================================================
#
# Study background:
# A study was performed to examine the effects of lead exposure on the
# psychological and neurological well-being of children. Children living near
# a lead smelter in El Paso, Texas, were identified and their blood levels of
# lead were measured. All children lived in close proximity to the smelter.
#
# Study groups:
# - Exposed group (n=36): Children with blood lead levels ≥ 40 μg/ml
#   (Group = 2)
# - Control group (n=66): Children with blood lead levels < 40 μg/ml
#   (Group = 1)
#
# Outcome of interest:
# One key outcome was the finger-wrist tapping test (MAXFWT), which measures
# neurological function. Children tap their finger to their wrist as fast as
# possible for 10 seconds, and the number of taps is counted. This is a
# measure of fine motor coordination and neurological development.
#
# Clinical question:
# Does lead exposure affect neurological function (tapping test score)? If we
# see a difference between exposed and control children, could it be explained
# by age differences (since neurological development changes with age)?
#
# Data Dictionary:
# The dataset contains numerous variables, but those of interest for this
# exercise include:
# 1.  ageyrs    age of child in years (decimal format, e.g., 8.5 years)
# 2.  Group     exposure group (1 = Control, 2 = Exposed)
# 3.  maxfwt    finger-wrist tapping test score in dominant hand
#               (number of taps in 10 seconds; higher = better function)

# ------------------------------------------------------------------------------------
# Loading and cleaning the lead exposure data

# Download and load the lead dataset from the course website
# - This creates a data frame called 'lead' in your R environment
# - The dataset contains 102 children with multiple variables
load(url("https://www.duke.edu/~sgrambow/crp241data/lead.RData"))

# Clean the missing values in the tapping test variable
# - In this dataset, missing values for maxfwt were coded as 99 (a common
#   data entry convention from older studies)
# - We need to convert these 99s to NA (R's missing value code) so that R
#   recognizes them as missing and handles them correctly in analyses
# - The code below finds all values of maxfwt equal to 99 and replaces them
#   with NA
lead$maxfwt[lead$maxfwt==99] <- NA

# Why this matters:
# - If we leave 99 as a number, R will treat it as a real tapping test score,
#   which would severely bias our results (99 taps is impossibly high!)
# - After conversion to NA, R will automatically exclude these observations
#   from analyses

# ------------------------------------------------------------------------------------
# Question 1: Is age a confounder?
#
# For age to be a confounder of the lead exposure-tapping test relationship,
# age must be associated with BOTH exposure group (Group) AND the tapping
# test score (maxfwt). Let's check both criteria.

# ------------------------------------------------------------------------------------
# Criterion 1: Is age associated with the outcome (maxfwt)?
#
# We'll examine whether tapping test scores vary with age using a scatterplot
# and correlation analysis.

# Create a scatterplot of age vs. tapping test score
# - Each dot represents one child
# - If dots show an upward or downward trend, age is associated with maxfwt
plot(lead$ageyrs,lead$maxfwt)

# Calculate Pearson's correlation coefficient between age and tapping score
# - cor.test() tests whether the correlation is significantly different from 0
# - Positive correlation: older children have higher tapping scores
# - Negative correlation: older children have lower tapping scores
# - Output includes: correlation coefficient (r), 95% CI, and p-value
cor.test(lead$ageyrs,lead$maxfwt)

# What to look for:
# - Correlation coefficient (r): strength and direction of linear relationship
#   - Close to 0: weak relationship; close to ±1: strong relationship
# - p-value: Is the correlation statistically significant?
# - If p < 0.05 and r ≠ 0, age IS associated with maxfwt (Criterion 1 met)

# ------------------------------------------------------------------------------------
# Criterion 2: Is age associated with exposure group?
#
# We'll examine whether the exposed and control children differ in age using
# a boxplot, summary statistics, and a t-test. Since we now know t-tests and
# simple linear regression are equivalent, we'll show both approaches.

# Create a boxplot of age by exposure group
# - This visualizes the distribution of age in each group
# - Boxplot shows median, quartiles, and range
boxplot(lead$ageyrs~lead$Group,
main="Age Distribution by Exposure (1= Control, 2= Exposed)")

# Calculate summary statistics for age within each exposure group
# - by() applies summary() separately for each group
# - This shows mean, median, quartiles, min, and max age in each group
by(lead$ageyrs,lead$Group,summary)

# Perform a two-sample t-test comparing age between groups
# - Tests whether mean age differs between control and exposed children
# - var.equal=T: assumes equal variances (same as regression assumption)
t.test(lead$ageyrs~lead$Group,var.equal=T)

# Calculate the difference in mean age between groups manually
# - Control group (1) mean age: approximately 9.327 years
# - Exposed group (2) mean age: approximately 8.270 years
# - Difference: Control children are about 1 year older on average
9.327-8.270

# Alternative approach: Use simple linear regression to compare age by group
# - This gives the same answer as the t-test (demonstrates equivalence)
# - The slope coefficient represents the difference in mean age between groups
summary(lm(lead$ageyrs~lead$Group))

# What to look for:
# - Are mean ages noticeably different between groups?
# - Is the p-value < 0.05 from the t-test or regression?
# - If yes, age IS associated with exposure group (Criterion 2 met)
# - If BOTH criteria are met, age may be a confounder!

# ------------------------------------------------------------------------------------
# Question 2: Unadjusted association between lead exposure and tapping test
#
# Now we'll estimate the crude (unadjusted) association between lead exposure
# and the tapping test score. This does NOT account for age; it's simply
# comparing the mean tapping scores between exposed and control children.

# Fit a simple linear regression model: maxfwt as outcome, Group as predictor
# - This estimates: maxfwt = intercept + (slope × Group)
# - Intercept: mean tapping score for control children (Group = 1)
# - Slope: difference in mean tapping score for exposed vs. control children
ufit <- lm(maxfwt ~ Group, data=lead)

# Display the regression results
# - Look for the coefficient for Group (the crude association)
# - Is the p-value < 0.05? (Is it statistically significant?)
# - R-squared: proportion of variation in maxfwt explained by exposure alone
summary(ufit)

# What to look for in the output:
# - Coefficient for Group: How much lower (or higher) is the tapping score
#   in exposed children compared to control children?
# - p-value for Group: Is this difference statistically significant?
# - Interpretation: "Exposed children have [coefficient] fewer/more taps on
#   average compared to control children (p = [p-value])"

# ------------------------------------------------------------------------------------
# Question 3: Adjusted association between lead exposure and tapping test
#
# Now we'll adjust for age by including it in the regression model. This
# controls for age differences between groups and gives us the "true"
# association between lead exposure and tapping test score.

# Fit a multiple linear regression model: maxfwt ~ Group + ageyrs
# - The model estimates: maxfwt = intercept + (slope₁ × Group) + (slope₂ × age)
# - Slope for Group: effect of exposure on maxfwt, adjusted for age
# - Slope for ageyrs: effect of age on maxfwt, adjusted for exposure group
afit <- lm(maxfwt ~ Group + ageyrs, data=lead)

# Display the adjusted regression results
# - Coefficient for Group: adjusted association (controlling for age)
# - Compare this to the unadjusted coefficient from ufit
# - Did the coefficient change? By how much?
summary(afit)

# What to look for in the output:
# - Coefficient for Group (adjusted): How much lower (or higher) is the
#   tapping score in exposed children compared to control children of the
#   SAME AGE?
# - p-value for Group: Is this adjusted difference statistically significant?
# - Coefficient for ageyrs: How much does the tapping score change per
#   1-year increase in age (useful for understanding the confounder's effect)
# - Compare the Group coefficient here to the unadjusted model (ufit)

# ------------------------------------------------------------------------------------
# Question 4: Impact of adjusting for age
#
# Comparing the unadjusted and adjusted models reveals the impact of
# confounding by age.

# Key observations:
# - In the unadjusted model (ufit), the coefficient for Group is
#   approximately -7.009
# - In the adjusted model (afit), the coefficient for Group is approximately
#   -4.85
# - The coefficient moved toward zero (was attenuated) after adjusting for age
#
# What does this mean?
# - The unadjusted model overestimated the impact of lead exposure because it
#   didn't account for age differences between groups
# - Control children were on average about 1 year older than exposed children
# - Older children naturally perform better on the tapping test (developmental
#   maturation of fine motor skills)
# - Part of the observed difference in tapping scores was due to age, not lead
#   exposure
# - After adjusting for age (comparing children of the same age), the true
#   effect of lead exposure is smaller (about -4.85 taps)
#
# Clinical interpretation:
# Age was a confounder that exaggerated the apparent effect of lead exposure.
# The adjusted analysis gives a more accurate estimate of lead's impact on
# neurological function. However, even after adjustment, exposed children
# still perform worse on the tapping test, suggesting a real adverse effect
# of lead exposure on neurological development.

# ------------------------------------------------------------------------------------
# Question 5: How are missing values handled in regression?
#
# Understanding missing data handling is important for interpreting results
# and assessing potential bias.

# What R does automatically:
# - After we converted 99 to NA, R recognizes these as missing values
# - The lm() function uses "complete case analysis" (also called "listwise
#   deletion")
# - This means: any observation (child) that is missing ANY variable in the
#   model is excluded from the analysis
# - For example, if a child is missing maxfwt, that child is dropped from
#   both the unadjusted and adjusted models
# - If a child is missing ageyrs, that child is included in the unadjusted
#   model (which doesn't use age) but excluded from the adjusted model
#
# Why this matters:
# - Complete case analysis is the default in most statistical software
# - It's simple and unbiased IF the missing data are "missing completely at
#   random" (MCAR)
# - However, if missingness is related to the outcome or exposure (i.e.,
#   "informative missingness"), complete case analysis can produce biased
#   results
# - Example: If children with very poor neurological function were less able
#   to complete the tapping test (resulting in missing values), excluding
#   them would underestimate the true impact of lead exposure
# - Always consider: Why might data be missing? Is missingness related to
#   the variables in the analysis?
#
# Best practice:
# - Examine patterns of missing data before analysis
# - Report the number of observations excluded due to missing data
# - Consider sensitivity analyses or advanced methods (multiple imputation)
#   if missingness is substantial or potentially informative

# ================================================================================
# Summary and Key Takeaways
# ================================================================================
#
# What you learned in this script:
#
# 1. Confounding basics
#    - A confounder is associated with both the exposure and the outcome
#    - Confounding distorts the true relationship between exposure and outcome
#    - Always check: Is the potential confounder associated with both?
#
# 2. Why regression is powerful
#    - t-tests can compare two groups, but cannot adjust for confounders
#    - Simple linear regression gives the same answer as a t-test when
#      comparing two groups
#    - Multiple linear regression can adjust for confounders by including
#      them in the model alongside the exposure
#
# 3. How adjustment works
#    - "Adjusting" means estimating the exposure effect within levels of the
#      confounder (e.g., within males, within females)
#    - Regression averages these stratum-specific effects to give one adjusted
#      coefficient
#    - This adjusted coefficient is the "true" effect, free from confounding
#
# 4. Interpreting adjusted vs. unadjusted results
#    - Unadjusted: crude association, may be biased by confounding
#    - Adjusted: accounts for confounders, more accurate estimate
#    - Compare coefficients: Did adjustment change the estimate substantially?
#      If yes, confounding was present
#
# 5. Clinical examples
#    - Example 1: Sex confounded the genotype-FEV1 relationship because sex
#      was associated with both genotype and lung function
#    - Example 2: Age confounded the lead exposure-tapping test relationship
#      because age was associated with both exposure group and neurological
#      function
#
# 6. Missing data considerations
#    - R automatically excludes observations with missing values (complete
#      case analysis)
#    - This is unbiased IF missingness is random
#    - Always consider why data might be missing and whether this could bias
#      results
#
# Next steps:
# - Practice identifying potential confounders in your own research
# - Always compare unadjusted and adjusted models to assess confounding
# - Consider creating stratified analyses to understand how adjustment works
# - Think about clinical and biological plausibility when selecting
#   confounders to adjust for
#
# ================================================================================
# End of Program
# ================================================================================