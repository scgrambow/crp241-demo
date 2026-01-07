# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~ CRP 245 Review Linear Reg ~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# STUDY CONTEXT AND POPULATION
# This analysis examines the relationship between alcohol consumption patterns
# and body mass index (BMI) using data from the BRFSS survey in North Carolina.
# 
# Key Points About the Study Population:
# - Starting population: 437,436 total BRFSS respondents
# - Focused on NC residents only: 4,729 people
# - Further restricted to:
#   * People who consumed at least one alcoholic drink in past 30 days (n=2,084)
#   * Only low-quantity (non-heavy) alcohol drinkers (n=1,759)
#
# Variables in Analysis:
# 1. Primary Outcome: 
#    BMI (kg/m²) - clinical measure of body composition
#    Normal range: 18.5-24.9, Overweight: 25-29.9, Obese: ≥30
#
# 2. Primary Predictor:
#    DAYS.DRINKING - Number of days with alcohol consumption in past 30 days
#    Clinical relevance: Measures frequency (not quantity) of alcohol consumption
#
# 3. Other Variables Available for Further Analysis:
#    - AGE (years, capped at 80+)
#    - SLEEP (average hours/24hr period)
#    - EXERCISE.YN (1=Yes, 2=No for past month)
#    - FEMALE (0=Male, 1=Female at birth)
#    
## Download and load the data file = brfssm1d1
load(url("https://www.duke.edu/~sgrambow/crp241data/brfssm1d1.RData"))

# INITIAL DATA EXPLORATION
# Let's first look at the basic characteristics of our study population
summary(brfssm1d1)

# ---Question 1--- #
# VISUALIZATION OF BMI AND DRINKING FREQUENCY RELATIONSHIP
# Clinical Question: Do patients who drink more frequently tend to have different BMI values?
# Statistical Approach: Create a scatterplot to visualize any potential relationship

# Creating the plot with drinking frequency on x-axis (predictor) and BMI on y-axis (outcome)
plot(brfssm1d1$DAYS.DRINKING,brfssm1d1$BMI)

# DETAILED INTERPRETATION OF THE SCATTERPLOT:
# 1. Overall Pattern:
#    - Points spread between BMI ~16-56 on y-axis
#    - Drinking frequency ranges from 0-30 days on x-axis
#    - Most points cluster in BMI range of 20-35
#    - More data points at lower drinking frequencies (left side of plot)
#
# 2. Visual Features to Notice:
#    - Slight downward tilt to the cloud of points
#    - Dense concentration of points in the lower drinking days (1-10 days)
#    - More scattered/sparse data for higher drinking frequencies
#    - Several outlier points with very high BMI values (>45)
#    - Some vertical striping due to drinking days being whole numbers
#
# 3. Data Distribution:
#    - Not all drinking frequencies equally represented
#    - More variation in BMI at lower drinking frequencies
#    - Fewer observations at higher drinking frequencies (>20 days)
#
# 4. Clinical Relevance:
#    - Most patients drink on relatively few days per month
#    - BMI values mostly fall in overweight/obese range
#    - Relationship appears weak - knowing drinking frequency alone
#      wouldn't help much in predicting a patient's BMI
#
# 2. Alternative R Syntax: 
#    The following format uses the "formula" notation (~) which you'll see often in R:
plot(brfssm1d1$BMI ~ brfssm1d1$DAYS.DRINKING)

# 3. Quantifying the Relationship:
#    We can calculate the correlation coefficient to measure the strength 
#    of the linear relationship between BMI and drinking frequency
#    Range: -1 to +1, where:
#    - Values close to 0 indicate weak relationship
#    - -1 indicates perfect negative relationship
#    - +1 indicates perfect positive relationship

# First attempt (doesn't handle missing values):
cor(brfssm1d1$DAYS.DRINKING,brfssm1d1$BMI)
# Proper calculation accounting for missing values:
cor(brfssm1d1$DAYS.DRINKING,brfssm1d1$BMI,use = "complete.obs")

# INTERPRETING THE CORRELATION:
# 1. Raw Numbers:
#    - Correlation = -0.12
#    - Negative sign indicates inverse relationship
#    - Value close to 0 indicates weak relationship
#
# 2. From the Output:
#    - First correlation attempt returns NA due to missing values
#    - Second attempt with missing data handled properly shows correlation of -0.12
#    - This matches what we see in the scatterplot
#
# 3. Clinical Significance:
#    - Only about 1.4% of BMI variation explained by drinking frequency
#      (square the correlation: -0.12 × -0.12 = 0.014)
#    - While statistically significant, may not be clinically meaningful
#    - Other factors likely more important for weight management counseling

# When looking at regression results ahead, students should note:
# - The weak correlation suggests regression will show small effects
# - The spread of points suggests prediction intervals will be wide
# - The density of points varies across drinking frequencies, which
#   affects precision of estimates at different frequencies

# ---Question 2--- #
# STATISTICAL MODELING OF BMI AND DRINKING FREQUENCY
# Clinical Question: Is there statistical evidence that drinking frequency 
# is associated with BMI, accounting for random variation?
# Statistical Approach: Fit a linear regression model and test significance at α=0.05

# Fit the linear regression model
bmi.fit <- lm(BMI ~ DAYS.DRINKING, data=brfssm1d1)
summary(bmi.fit)

# INTERPRETATION OF REGRESSION OUTPUT DISPLAY:
# 1. Key Elements in Output Table:
#    Coefficients:
#                Estimate  Std Error  t-value   Pr(>|t|)    
#    Intercept   28.38158   0.18121  156.625   < 2e-16 ***
#    DAYS.DRINK  -0.09742   0.01931   -5.044   5.04e-07 ***
#
#    Residual standard error: 5.757 on 1694 degrees of freedom
#    Multiple R-squared: 0.0148
#
# 2. Understanding Each Component:
#    a) Intercept (28.38):
#       - Represents predicted BMI when drinking days = 0
#       - Clinically interpretable: expected BMI for non-drinkers
#       - Falls in "overweight" BMI category (25-29.9)
#
#    b) DAYS.DRINKING coefficient (-0.097):
#       - For each additional drinking day, BMI decreases by 0.097 units
#       - Example: 10 more drinking days → BMI lower by about 1 unit
#       - The p-value for the slope coefficient is < 0.001, indicating a
#         statistical significant association.
#
#    c) Standard Errors:
#       - Intercept: 0.18 (precise estimate of baseline BMI)
#       - DAYS.DRINKING: 0.019 (precise estimate of slope)
#
#    d) Residual Standard Error (5.757):
#       - Typical deviation of observed BMIs from predicted values
#       - Clinical context: Predictions can be off by ~6 BMI units
#       - Shows why individual predictions will be imprecise

# ---Question 3--- #
# ESTIMATING THE MAGNITUDE OF THE BMI-DRINKING RELATIONSHIP
# Clinical Question: What's the expected BMI difference between a patient who 
# drinks on 10 days/month versus one who drinks on 20 days/month?

# METHOD 1: Calculate using the slope coefficient
# - Multiply slope by 10 (because we're looking at a 10-day difference)
bmi.fit$coefficients*10
# Alternative manual calculation:
-0.09742*10

# CLINICAL INTERPRETATION OF POINT ESTIMATE:
# - For a 10-day increase in monthly drinking frequency, we expect BMI 
#   to be about 0.97 units lower on average
# - Example: A patient drinking on 20 days/month would be predicted to have
#   a BMI about 1 unit lower than a similar patient drinking on 10 days/month
# - Context: A 1-unit change in BMI is relatively modest
#   (e.g., for a 5'10" person, it represents about 7 pounds)

# Calculating 95% Confidence Interval for a 10-day difference:
confint(bmi.fit)*10

# INTERPRETATION OF CONFIDENCE INTERVAL:
# - We are 95% confident that a 10-day increase in drinking frequency is
#   associated with a BMI difference between -1.35 and -0.60 units
# - Clinical Context: Even at the extreme end of our confidence interval,
#   the BMI difference is modest from a clinical perspective

# ---Question 4--- #
# PREDICTING MEAN BMI FOR A SPECIFIC DRINKING PATTERN
# Clinical Question: What BMI would we expect, on average, for patients 
# who drink on 25 days per month?

# METHOD 1: Manual calculation using regression equation
28.38158 + (25*-0.09742)

# METHOD 2: Using R's predict function (preferred method)
predict(bmi.fit,data.frame(DAYS.DRINKING=25))

# Getting the confidence interval for our prediction
predict(bmi.fit,data.frame(DAYS.DRINKING=25),interval = "confidence")

# CLINICAL INTERPRETATION:
# - Point Estimate: Expected average BMI is 25.95 for patients who drink 25 days/month
# - 95% Confidence Interval: (25.17, 26.72)
# - Clinical Context: This predicted BMI falls in the "overweight" category
#   (BMI 25-29.9), but near the lower end of that range
# - The narrow confidence interval suggests we can be fairly confident
#   about our estimate of the average BMI for this drinking pattern

# ---Question 5--- #
# PREDICTING BMI FOR AN INDIVIDUAL PATIENT
# Clinical Question: How precisely can we predict BMI for a specific patient 
# who drinks on 25 days per month?

# Calculate point estimate (same as for population mean)
28.38158 + (25*-0.09742)

# Calculate prediction interval for individual patients
predict(bmi.fit,data.frame(DAYS.DRINKING=25),interval = "predict")

# CLINICAL INTERPRETATION OF PREDICTION INTERVALS:
# - Point Estimate: Same as before (25.95)
# - 95% Prediction Interval: (14.63, 37.26)
# - Clinical Insights:
#   * The very wide interval (spanning over 22 BMI units) shows that drinking
#     frequency alone is a poor predictor of an individual's BMI
#   * For individual patients, we need to consider many other factors
#   * This prediction interval spans all BMI categories from underweight (<18.5)
#     to severe obesity (>35)
#   * The wide interval reinforces that individual patient counseling should
#     not focus solely on drinking frequency when addressing weight management


# CLINICAL APPLICATIONS OF THESE INTERVALS:
# 1. Population Level (Confidence Intervals):
#    - Useful for describing typical BMI patterns
#    - Good for patient education about general trends
#    - Helpful for program planning
#
# 2. Individual Level (Prediction Intervals):
#    - Shows limitation of drinking frequency as BMI predictor
#    - Emphasizes need for comprehensive patient assessment
#    - Demonstrates why individualized counseling needs to
#      consider multiple factors beyond drinking patterns
#      
# ---Question 6--- #
# GENERALIZABILITY OF THE MODEL
# Clinical Question: Can we apply these findings to patients outside North Carolina?

# CLINICAL CONSIDERATIONS FOR EXTERNAL VALIDITY:
# - The model uses NC data only, not the full US BRFSS sample
# - Drinking patterns and their relationship with BMI may vary by:
#   * Geographic region
#   * Cultural factors
#   * Socioeconomic factors
#   * Local policies and attitudes about alcohol
# - Best Practice: Results should be primarily applied to NC populations
#   until validated in other regions

# ---Question 7--- #
# LIMITATIONS OF MODEL EXTRAPOLATION
# Clinical Question: Can we use this model for patients drinking more than 30 days/month?

# IMPORTANT CLINICAL LIMITATIONS:
# 1. Data Constraints:
#    - Study only measured drinking over a 30-day period
#    - No data available beyond 30 days
#
# 2. Clinical Implications:
#    - Model should not be used to make predictions outside the 0-30 day range
#    - Extrapolating beyond observed data could lead to incorrect clinical decisions
#    - When encountering patients with unusual drinking patterns, rely on
#      clinical judgment rather than statistical predictions

# End of Program