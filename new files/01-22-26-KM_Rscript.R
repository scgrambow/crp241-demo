# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CRP 245 Part 1: Survival Analysis of Ovarian Cancer Data  
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# This script demonstrates survival analysis using the Kaplan-Meier method
# to analyze outcomes in ovarian cancer patients. The analysis helps us understand
# how long patients survive after receiving different treatments.
# 

# -----------------------------------------------
# Study Background: 
# This analysis uses data from a randomized clinical trial comparing two treatments
# for advanced ovarian carcinoma (stages IIIB and IV):
# 1. Control arm: cyclophosphamide alone (1 g/m2)
# 2. Treatment arm: cyclophosphamide (500 mg/m2) plus adriamycin (40 mg/m2)
# Both treatments were given by IV injection every 3 weeks.

# Data Dictionary: 
# The dataset (ovarian2) contains the following variables:
# (1) futime:     Time from randomization until death or last follow-up (days)
# (2) fustat:     Patient status (1 = died, 0 = still alive at last follow-up/censored)
# (3) age:        Patient age when starting treatment (years)
# (4) resid.ds:   Whether residual disease was present (1=no, 2=yes)
# (5) rx:         Treatment group (0=control/cyclophosphamide alone, 
#                                1=experimental/cyclophosphamide+adriamycin)
# (6) ecog.ps:    ECOG performance status (1 is better functioning, 
#                 2 is worse functioning)
#                 More info: http://ecog.org/general/perf_stat.html

## Download and load the trial data
load(url("https://www.duke.edu/~sgrambow/crp241data/ovarian2.RData"))

# -----------------------------------------------
# Required R Packages for Survival Analysis 

# We need two key packages:
# 1. 'survival' - Core functions for survival analysis
# 2. 'survminer' - Enhanced visualization of survival curves
# Note: Install packages once, but load them every time using library()

library(survival)   # For survival analysis functions
library(survminer)  # For creating enhanced KM plots

# -----------------------------------------------
# Initial Data Exploration

# First, let's understand our data structure and summary statistics
str(ovarian2)      # Shows data structure
summary(ovarian2)  # Shows summary statistics for each variable

# Visualize survival times using histograms:
# 1. For all patients
hist(ovarian2$futime,
     main = 'Among all subjects',
     breaks = seq(0,1400,by = 200))

# 2. Only for patients who died during the study
hist(ovarian2$futime[ovarian2$fustat == 1],
     main = 'Among subjects who died',
     breaks = seq(0,1400,by = 200))

# 3. Only for patients who were still alive at last follow-up
hist(ovarian2$futime[ovarian2$fustat == 0],
     main = 'Among subjects who were censored',
     breaks = seq(0,1400,by = 200))

# -----------------------------------------------
# QUESTION 1: Kaplan-Meier Survival Estimates Table
# This shows the probability of survival at different time points

# Create the KM survival object
fit.km <- survfit(Surv(futime, fustat) ~ 1, data=ovarian2)

# Get survival estimates
# Note: Default output only shows times when deaths occurred
summary(fit.km)

# Show all time points including censoring events
# Key findings from output:
# - At 59 days: 96.2% survival probability (95% CI: 89.0% - 100%)
# - At 365 days (1 year): 73.1% survival (95% CI: 57.9% - 92.3%)
# - By study end: 49.7% survival (95% CI: 32.8% - 75.2%)
summary(fit.km,censor=TRUE)

# -----------------------------------------------
# QUESTION 2: Kaplan-Meier Survival Curve Plots
# These plots visualize the survival probability over time

# Create several versions of the KM plot, each adding more information:

# 1. Basic plot
plot(fit.km)

# 2. Enhanced plot with better formatting
plot(fit.km, 
     col='blue',lwd=3,
     main='Kaplan Meier Plot',
     xlab='Days Since Enrollment',
     ylab='Survival Probability')

# 3. Plot showing censoring times but no confidence intervals
plot(fit.km,
     col='blue',lwd=3,
     main='Kaplan Meier Plot',
     xlab='Days Since Enrollment',
     ylab='Survival Probability',
     mark.time=TRUE,
     conf.int = FALSE)

# 4. Professional plot with risk table
# The risk table shows number of patients still being followed
ggsurvplot(fit.km, data = ovarian2, 
           risk.table = TRUE)

# 5. Alternative view: Cumulative incidence plot
# Shows probability of death over time instead of survival
ggsurvplot(fit.km, data = ovarian2, 
           fun = "event",
           risk.table = TRUE)

# -----------------------------------------------
# QUESTIONS 3 & 4: Key Clinical Probability Questions

# For these calculations, we need to convert clinical timepoints to days:
# 2 years = 365*2 = 730 days
# 6 months = 30*6 = 180 days

# Q3: Probability of surviving at least 2 years
# Answer: About 49.7% (from KM estimates)
# Verification using R:
summary(fit.km, times = 730)$surv    # Returns 0.497 or 49.7%

# Q4: Probability of dying before 6 months
# Answer: About 11.5% (calculated as 1 - survival probability at 180 days)
# Verification using R:
1 - summary(fit.km, times = 180)$surv    # Returns 0.115 or 11.5%

# -----------------------------------------------
# QUESTION 5: Median Survival Time

# The median survival time is the time point where 50% of patients have died
# Can we estimate it from our data?
# Answer: Yes, because the survival curve crosses 50%
# The median survival time is 638 days (about 1.75 years)
# 95% CI starts at 464 days but upper limit cannot be estimated

# Get the median survival estimate and confidence interval
summary(fit.km)$table 

# Create plot showing the median survival time
ggsurvplot(fit.km, data = ovarian2, 
           risk.table = TRUE, 
           surv.median.line = "hv")    # Adds horizontal and vertical lines at median

# -----------------------------------------------
# End of Program