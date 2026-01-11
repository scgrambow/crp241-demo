# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~ CRP 245 Review Logistic Reg ~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Clinical Context:
# This analysis examines prostate cancer patient data to understand how 
# serum acid phosphatase levels might predict lymph node involvement. 
# This relationship is important because lymph node status influences 
# treatment decisions and prognosis.

# Data Description:
# - Sample: 53 prostate cancer patients
# - Key Variables:
#   * Nodes: Lymph node involvement (1 = present, 0 = absent)
#   * Acid: Serum acid phosphatase level (x 100)
#   * Additional variables include X-ray findings, tumor grade, disease stage, and age

# Load required data
load(url("https://www.duke.edu/~sgrambow/crp241data/prostate_node.RData"))

# ---Question 1--- 
# Is there evidence of an association between nodal involvement and serum acid 
# phosphatase level?
# Create a scatterplot to address this question.

# First, let's examine the data distribution
summary(prostate_node)

# Key findings from summary:
# - Acid phosphatase ranges from 40 to 187 (median = 65)
# - About 38% of patients have nodal involvement (mean = 0.3774)
# - No missing values in key variables

# Create visualization to show data distribution
plot(prostate_node$Acid,prostate_node$Nodes,cex=3) # Basic plot

# ---Question 2--- 
# Is there evidence of an association between serum acid phosphatase and nodal 
# involvement at significance level 0.05? 

# Fit logistic regression model
acid.fit <- glm(Nodes ~ Acid, data=prostate_node, family='binomial')
summary(acid.fit)

# Clinical Interpretation of Results:
# - Coefficient for Acid = 0.02040 (p = 0.1045) represents change in log odds
# - Interpretation on log odds scale: For each 1-unit increase in acid phosphatase,
#   the log odds of nodal involvement increase by 0.02040
# - While this scale is not intuitive, positive values mean increased risk
# - At α = 0.05, we cannot conclude there is a statistically significant association
# - The positive coefficient indicates higher nodal involvement
#   with increasing acid phosphatase levels

# Important Note: If we forget to specify family='binomial', R will run linear 
# regression instead of logistic regression, which is inappropriate for 
# binary outcomes
nofamily.acid.fit <- glm(Nodes ~ Acid,data=prostate_node)
summary(nofamily.acid.fit)

# ---Question 3--- 
# Nature of the association between acid phosphatase and nodal involvement

# Calculate odds ratios by exponentiating coefficients
acid.fit$coefficients
exp(acid.fit$coefficients)

# Clinical Interpretation:
# - Odds ratio = 1.0206 for each 1-unit increase in acid phosphatase
# - This means the odds of nodal involvement increase by about 2.1% for each 
#   unit increase in acid phosphatase
# - Direction is positive: higher acid phosphatase associated with higher 
#   probability of nodal involvement

# ---Question 4--- 
# Interpretation of the slope coefficient

# Key model output:
# Coefficient = 0.02040 (log-odds scale)
# Odds ratio = 1.0206

# Clinical Interpretation:
# - For each 1-unit increase in acid phosphatase:
#   * Log-odds of nodal involvement increase by 0.02040
#   * Odds of nodal involvement multiply by 1.0206 (increase by 2.06%)
# - This represents the change in risk for a very small change in acid phosphatase

# ---Question 5--- 
# Calculate odds ratio for a clinically meaningful change (10 units)

# Calculate odds ratio for 10-unit increase
exp(10*acid.fit$coefficients)
exp(10*confint(acid.fit))

# Clinical Interpretation:
# - OR = 1.23 (95% CI: 0.98 to 1.62) for a 10-unit increase
# - Clinical Translation: The odds of nodal involvement are 23% higher for each
#   10-unit increase in acid phosphatase
# - However, the confidence interval includes 1, aligning with our earlier
#   finding of non-significance at 0.05

# ---Question 6--- 
# Predict probability of nodal involvement for acid phosphatase = 78

# Calculate predicted probability
xb <- -1.92703 + (0.02040*78)
exp(xb)/(1+exp(xb))

# Alternate calculation using predict function
predict(acid.fit,data.frame(Acid=78),type="response")

# Clinical Interpretation:
# - For a patient with acid phosphatase = 78:
#   * Predicted probability of nodal involvement = 41.7%
# - This means among patients with this acid phosphatase level,
#   we expect about 42% to have nodal involvement

# Visualize the relationship across all possible values
# Create sequence of acid phosphatase values
xAcid <- seq(40,187,length=100)
yxAcid <- predict(acid.fit,list(Acid=xAcid),type="response")

# Create plots showing both raw data and predicted probabilities
plot(prostate_node$Acid,jitter(prostate_node$Nodes),pch=1,col="blue",
     xlab="Serum Acid Phosphatase",ylab="Prob(Nodal Involvement)")
lines(xAcid,yxAcid,col="dark red",lwd=2)

# End of Program
