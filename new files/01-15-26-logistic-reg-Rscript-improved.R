# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CRP 245 — Review of Logistic Regression
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Audience: Physician learners with little or no programming experience.
# Goal: This analysis examines prostate cancer patient data to understand how 
#       serum acid phosphatase levels might predict lymph node involvement. 
#       You will learn to visualize binary outcomes, fit logistic regression
#       models, and interpret odds ratios in a clinical context.
#
# Study Background:
# When a patient is diagnosed with prostate cancer, an important question in 
# deciding on a treatment strategy is whether or not the cancer has spread to 
# neighboring lymph nodes. This relationship is important because lymph node 
# status influences treatment decisions and prognosis. In this study, several 
# possible predictor variables were measured before surgery for a sample of 
# 53 prostate cancer patients. The patients then had surgery to determine 
# nodal involvement.
#
# How to use this script:
# - Run the script line-by-line or as a whole.
# - Comments (lines starting with #) explain the clinical and statistical 
#   rationale for each step.
# - Key findings are summarized in "CLINICAL INTERPRETATION" blocks.
#
# Data Dictionary:
# - X: Patient No
# - Xray: Measure of the seriousness of cancer taken from an X-ray reading 
#         (1 = more severe; 0 = less severe)
# - Grade: Dichotomized tumor measure (1 = more serious; 0 = less serious)
# - Stage: Dichotomized tumor measure (1 = more serious; 0 = less serious)
# - Age: Age at diagnosis (years)
# - Acid: Serum acid phosphatase level (x 100)
# - Nodes: Lymph node involvement found at surgery (1 = present; 0 = absent)
#
# ================================================================================
# 1. SETUP: CHECK AND LOAD PACKAGES
# ================================================================================
# We check if required packages are installed before loading them.

# Check for and install 'stats' (built-in, but following pattern)
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
# We load the prostate cancer dataset directly from the course website.

# Load required data into a dataframe called 'prostate_node'
load(url("https://www.duke.edu/~sgrambow/crp241data/prostate_node.RData"))

# Verify data loaded correctly and check basic characteristics
# - summary() provides descriptive statistics for all variables
summary(prostate_node)

# STATISTICAL INTERPRETATION:
# - Study Sample: n = 53 patients.
# - Acid phosphatase (Acid) ranges from 40 to 187 with a median of 65.
# - Nodal involvement (Nodes) mean of 0.3774 indicates ~38% (20/53) prevalence.
# - No missing values (NAs) are present in the key variables for this analysis.

# CLINICAL INTERPRETATION:
# - The dataset represents a group of prostate cancer patients with a moderate
#   prevalence of lymph node spread.
# - Acid phosphatase levels show a right-skewed distribution (mean > median).

# ================================================================================
# 3. EXPLORE: VISUALIZATION
# ================================================================================

# ---Question 1---
# VISUALIZATION OF NODAL INVOLVEMENT AND ACID PHOSPHATASE
# Clinical Question: Is there evidence of an association between nodal 
# involvement and serum acid phosphatase level?

# Create visualization to show data distribution
# We plot Acid (predictor) on x-axis and Nodes (outcome) on y-axis
plot(prostate_node$Acid, prostate_node$Nodes, 
     main = "Nodal Involvement vs. Acid Phosphatase",
     xlab = "Serum Acid Phosphatase (x 100)",
     ylab = "Nodal Involvement (1=Present, 0=Absent)",
     cex = 2, pch = 1, col = "blue")

# STATISTICAL INTERPRETATION:
# - The scatterplot shows binary outcomes (0 and 1) on the y-axis.
# - Patients with nodal involvement (1) appear somewhat more concentrated 
#   at higher acid phosphatase levels compared to those without (0).
# - Traditional linear trends are hard to see because the outcome is discrete.

# CLINICAL INTERPRETATION:
# - While there is a visual suggestion that higher acid phosphatase may correlate
#   with nodal involvement, the overlap is significant.
# - We need formal modeling to quantify the strength of this association.

# ================================================================================
# 4. MODEL: LOGISTIC REGRESSION
# ================================================================================

# ---Question 2---
# TESTING FOR ASSOCIATION
# Clinical Question: Is there statistically significant evidence of an 
# association at the 0.05 level?

# Fit logistic regression model
# NOTE: family='binomial' is essential for logistic regression
acid.fit <- glm(Nodes ~ Acid, data=prostate_node, family='binomial')

# Display model results
summary(acid.fit)

# STATISTICAL INTERPRETATION:
# - Coefficient (Slope) for Acid = 0.02040.
# - Standard Error = 0.01257.
# - p-value = 0.1045.
# - At alpha = 0.05, we fail to reject the null hypothesis because p > 0.05.

# CLINICAL INTERPRETATION:
# - The p-value of 0.10 indicates that we do not have enough evidence to
#   conclude a statistically significant association between acid phosphatase
#   and nodal involvement in this specific sample.
# - However, the positive coefficient (0.02) suggests a trend: as acid 
#   phosphatase increases, the risk of nodal involvement tends to increase.

# IMPORTANCE OF FAMILY='BINOMIAL':
# If we omit the family argument, R defaults to linear regression (Gaussian),
# which is inappropriate for binary (Yes/No) clinical outcomes.
nofamily.acid.fit <- glm(Nodes ~ Acid, data=prostate_node)
summary(nofamily.acid.fit)

# ================================================================================
# 5. INTERPRET: ODDS RATIOS AND PREDICTIONS
# ================================================================================

# ---Question 3 & 4---
# NATURE OF THE ASSOCIATION AND INTERPRETATION OF SLOPE
# Clinical Question: How much does the risk change for each unit increase?

# Calculate odds ratios by exponentiating the coefficients
exp(acid.fit$coefficients)

# STATISTICAL INTERPRETATION:
# - Intercept (e^-1.927) = 0.145: The odds when Acid = 0 (not clinically useful).
# - Slope (e^0.0204) = 1.0206: The multiplicative change in odds per 1-unit.

# CLINICAL INTERPRETATION:
# - Odds Ratio (OR) = 1.021.
# - For every 1-unit increase in serum acid phosphatase, the odds of nodal 
#   involvement increase by approximately 2.1%.
# - Since the OR > 1, the direction of association is positive (higher risk).

# ---Question 5---
# CLINICALLY MEANINGFUL CHANGE (10-UNIT INCREASE)
# Question: What is the risk associated with a 10-unit increase in Acid?

# Calculate odds ratio and 95% Confidence Interval for a 10-unit increase
exp(10 * acid.fit$coefficients)
exp(10 * confint(acid.fit))

# STATISTICAL INTERPRETATION:
# - Odds Ratio for 10-unit increase = 1.226.
# - 95% Confidence Interval = [0.978, 1.616].

# CLINICAL INTERPRETATION:
# - A 10-unit increase in acid phosphatase is associated with a 23% increase 
#   in the odds of nodal involvement.
# - However, because the 95% CI includes 1.0 (the value of "no effect"), 
#   this 23% increase is not statistically significant at the 5% level.
# - Physician note: Large clinical effects can sometimes be non-significant 
#   if the study sample (n=53) is small.

# ---Question 6---
# PREDICTED PROBABILITY FOR AN INDIVIDUAL PATIENT
# Question: What is the predicted probability for a patient with Acid = 78?

# Calculation using the logistic equation: prob = exp(xb)/(1+exp(xb))
xb <- -1.92703 + (0.02040 * 78)
exp(xb) / (1 + exp(xb))

# Alternate calculation using the built-in predict function
predict(acid.fit, data.frame(Acid=78), type="response")

# CLINICAL INTERPRETATION:
# - For a patient with a serum acid phosphatase level of 78, the model 
#   predicts a 41.7% probability of lymph node involvement.
# - In a clinical setting, this patient would be considered at high risk 
#   (nearly 1 in 2 chance), regardless of statistical significance.

# VISUALIZING THE LOGISTIC CURVE
# Create a sequence of Acid values from the original range (40 to 187)
xAcid <- seq(40, 187, length=100)
# Generate predicted probabilities across that range
yxAcid <- predict(acid.fit, list(Acid=xAcid), type="response")

# Plot raw data with jitter (to prevent overlapping points) and the model curve
plot(prostate_node$Acid, jitter(prostate_node$Nodes, amount=0.05), 
     pch=1, col="blue",
     main = "Logistic Regression: Predicted Probability Curve",
     xlab = "Serum Acid Phosphatase", 
     ylab = "Probability of Nodal Involvement")
lines(xAcid, yxAcid, col="darkred", lwd=2)

# CLINICAL SUMMARY:
# - The "S-curve" shows how the probability of cancer spread rises as the 
#   biomarker level increases.
# - While the trend is clear, wait for larger studies before using this 
#   as a definitive diagnostic tool.

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# End of Program
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
