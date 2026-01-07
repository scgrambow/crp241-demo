# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CRP 245 — Review of Linear Regression
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Audience: Physician learners with little or no programming experience.
# Goal: This analysis examines the relationship between alcohol consumption 
#       patterns (frequency) and body mass index (BMI) using data from the 
#       BRFSS survey in North Carolina. You will learn to visualize 
#       relationships, quantify them with correlation, and model them 
#       using linear regression for both group-level and individual-
#       level predictions.
#
# How to use this script:
# - Run the script line-by-line or as a whole.
# - Comments (lines starting with #) explain the clinical and statistical 
#   rationale for each step.
# - Key findings are summarized in "CLINICAL INTERPRETATION" blocks.
#
# Data Description:
# - Dataset: brfssm1d1 (subset of BRFSS NC data)
# - Study Sample: n=1,759 NC residents who are non-heavy drinkers.
# - Primary Outcome: BMI (kg/m²)
# - Primary Predictor: DAYS.DRINKING (frequency of alcohol use in past 30 days)
#
# ================================================================================
# 1. SETUP: CHECK AND LOAD PACKAGES
# ================================================================================
# Following repo conventions, we check if required packages are installed before
# loading them. For this script, we primarily use base R and standard stats.

# Check for and install 'stats' (usually built-in, but following pattern)
if (!requireNamespace("stats", quietly = TRUE)) {
  install.packages("stats")
}
library(stats)

# Check for and install 'graphics' for plotting
if (!requireNamespace("graphics", quietly = TRUE)) {
  install.packages("graphics")
}
library(graphics)

# ================================================================================
# 2. LOAD DATA
# ================================================================================
# We load the processed BRFSS dataset directly from the course website.

# Download and load the data file = brfssm1d1
load(url("https://www.duke.edu/~sgrambow/crp241data/brfssm1d1.RData"))

# Verify data loaded correctly and check basic characteristics
# - summary() provides min, 1st quartile, median, mean, 3rd quartile, and max
# - NOTE: Observe the 'NA' count in the BMI variable (63 missing values). 
#   These are handled automatically in summaries but require attention in
#   modeling.
summary(brfssm1d1)

# ================================================================================
# 3. EXPLORE: VISUALIZATION AND CORRELATION
# ================================================================================

# ---Question 1--- #
# VISUALIZATION OF BMI AND DRINKING FREQUENCY RELATIONSHIP
# Clinical Question: Do patients who drink more frequently tend to have 
# different BMI values?
# Statistical Approach: Create a scatterplot to visualize the relationship.

# Creating the plot with DAYS.DRINKING (predictor) on x-axis and BMI on y-axis
plot(brfssm1d1$DAYS.DRINKING, brfssm1d1$BMI,
     main = "BMI vs. Drinking Frequency",
     xlab = "Days Drinking (Past 30 Days)",
     ylab = "BMI (kg/m²)")

# STATISTICAL INTERPRETATION OF THE SCATTERPLOT:
# 1. Overall Pattern: Points spread between BMI ~16-56.
# 2. Distribution: Most points cluster in BMI range 20-35. More data points at 
#    lower drinking frequencies (left side).
# 3. Features: Slight downward tilt; several outlier points with high BMI (>45).
# 4. Vertical Striping: Due to drinking days being measured in whole numbers.

# CLINICAL INTERPRETATION:
# - Most patients drink on relatively few days per month.
# - BMI values mostly fall in the overweight or obese range.
# - The relationship appears weak—knowing drinking frequency alone is not a 
#   strong clinical predictor of a patient's BMI.

# Alternative R Syntax using the "formula" notation (~):
plot(brfssm1d1$BMI ~ brfssm1d1$DAYS.DRINKING,
     main = "BMI vs. Drinking Frequency (Formula Notation)",
     xlab = "Days Drinking (Past 30 Days)",
     ylab = "BMI (kg/m²)")

# QUANTIFYING THE RELATIONSHIP (CORRELATION)
# Range: -1 to +1 (0 = no linear relationship; +/-1 = perfect relationship)

# Handling missing values is crucial for a complete dataset calculation
cor(brfssm1d1$DAYS.DRINKING, brfssm1d1$BMI, use = "complete.obs")

# STATISTICAL INTERPRETATION:
# - Correlation = -0.12.
# - Negative sign indicates an inverse relationship (as drinking days 
#   increase, BMI tends to slightly decrease).

# CLINICAL SIGNIFICANCE:
# - Only about 1.4% of BMI variation is explained by drinking frequency 
#   (calculated as -0.12 squared = 0.014).
# - Other factors (diet, genetics, exercise) are likely more important.

# ================================================================================
# 4. MODEL/TEST: LINEAR REGRESSION
# ================================================================================

# ---Question 2--- #
# STATISTICAL MODELING OF BMI AND DRINKING FREQUENCY
# Clinical Question: Is there statistical evidence that drinking frequency 
# is associated with BMI, accounting for random variation?
# Statistical Approach: Fit a linear regression model.

# Fit the linear regression model
bmi.fit <- lm(BMI ~ DAYS.DRINKING, data = brfssm1d1)
summary(bmi.fit)

# UNDERSTANDING THE REGRESSION OUTPUT:
# 1. Intercept (28.38): The predicted BMI when drinking days = 0. This falls 
#    in the "overweight" category (25-29.9).
# 2. Slope (-0.097): For each additional drinking day, BMI decreases by 
#    0.097 units on average.
# 3. P-value (< 0.001): Indicates a statistically significant association 
#    between drinking frequency and BMI.
# 4. Residual Standard Error (5.757): Typical deviation from predicted values. 
#    Clinical predictions can be off by ~6 BMI units.

# ================================================================================
# 5. INTERPRET/CONCLUDE: ESTIMATION AND PREDICTION
# ================================================================================

# ---Question 3--- #
# MAGNITUDE OF THE RELATIONSHIP
# Clinical Question: What's the expected BMI difference between a patient who 
# drinks on 10 days/month versus 20 days/month?

# Calculate using the slope coefficient (multiply by 10-day difference)
bmi.fit$coefficients[2] * 10

# Calculate 95% Confidence Interval for a 10-day difference:
confint(bmi.fit)[2, ] * 10

# CLINICAL INTERPRETATION:
# - For a 10-day increase in drinking frequency, we expect average BMI to be 
#   about 0.97 units lower.
# - We are 95% confident the true difference lies between -1.35 and -0.60 units.
# - Context: A 1-unit BMI change is modest (roughly 7 lbs for a 5'10" person).

# ---Question 4--- #
# PREDICTING MEAN BMI (GROUP AVERAGE)
# Clinical Question: What BMI would we expect, on average, for patients 
# who drink on 25 days per month?

# Using R's predict function with a 95% Confidence Interval (CI)
predict(bmi.fit, data.frame(DAYS.DRINKING=25), interval = "confidence")

# CLINICAL INTERPRETATION:
# - Point Estimate: Expected average BMI is 25.95.
# - Clinical Context: This falls near the low end of the "overweight" category.
# - The narrow CI (25.17, 26.72) suggests high confidence in the average 
#   value for this specific drinking pattern.

# ---Question 5--- #
# PREDICTING INDIVIDUAL BMI (PATIENT LEVEL)
# Clinical Question: How precisely can we predict BMI for a specific patient 
# who drinks on 25 days per month?

# Using a 95% Prediction Interval (PI) for an individual case
predict(bmi.fit, data.frame(DAYS.DRINKING=25), interval = "predict")

# CLINICAL INTERPRETATION OF PREDICTION INTERVALS:
# - 95% Prediction Interval: (14.63, 37.26).
# - Clinical Insight: This interval is extremely wide (spanning ~22 BMI units).
# - Counseling Point: We cannot accurately predict an individual's BMI 
#   based on drinking frequency alone. It spans categories from 
#   underweight to severe obesity.

# ---Question 6--- #
# GENERALIZABILITY (EXTERNAL VALIDITY)
# Clinical Question: Can we apply these findings to patients outside NC?

# CLINICAL CONSIDERATIONS:
# - Results apply specifically to North Carolina populations.
# - Factors like regional culture, socioeconomic status, and local alcohol 
#   policies may influence the relationship in other areas.

# ---Question 7--- #
# LIMITATIONS OF MODEL EXTRAPOLATION
# Clinical Question: Can we use this model for patients drinking more 
# than 30 days/month?

# IMPORTANT CLINICAL LIMITATIONS:
# - Data Constraints: The study only measured 0-30 days.
# - Warning: Do not extrapolate beyond the observed data range (0-30 days). 
#   Doing so could lead to incorrect clinical conclusions.

# ================================================================================
# END OF PROGRAM
# ================================================================================
