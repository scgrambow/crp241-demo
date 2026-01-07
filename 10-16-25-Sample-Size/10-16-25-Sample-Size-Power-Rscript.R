# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~ CRP 241| Power and Sample Size ~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Code for Slides ---------------

# If you haven't already installed the 'pwr' package, 
# uncomment the line below and run the code. 
# install.packages('pwr')
library(pwr)

# Key quantities for pwr function
# need to provide 3 of 4 quantities
# Note: The power function for proportion 
# tests wants the effect sizes 
# represented as h (the formula given below).

# Example | ORBITA Trial 
# https://doi.org/10.1016/S0140-6736(17)32714-9
# Sample Size Justification
# We designed ORBITA conservatively, to detect 
# an effect size from invasive PCI of 30 s, 
# smaller than that of a single antianginal agent. 
# We calculated that, from the point of  
# randomisation, a sample size of 100 patients 
# per group had more than 80% power to detect a 
# between-group difference in the increment of 
# exercise duration of 30 seconds, at the 5% 
# significance level, using the two-sample t test 
# of the difference between groups. This calculation 
# assumed a between-patient standard deviation of 
# change in exercise time of 75 s. There have been 
# no previous placebo-controlled trials of PCI. 
# We therefore initially allowed for a one-third 
# dropout rate in the 6-week period of medical 
# optimisation between enrollment and randomisation 
# and therefore planned to enroll 300 patients. 

# key quantities:
# power = 0.80
# alpha or significance level = 0.05
# MCID = 30 s
# SD = 75 s
# ES or d = 30/75 = 0.4
# n we will calculate
pwr.t.test(sig.level=0.05,power=0.8, d=0.4,
           type="two.sample",alternative="two.sided")

# yields 99.08 or 100 per group for a total of 200 

# Now account for attrition:
# Assume 1/3 = 0.33 dropout rate (ISS x .67 = final SS)
# Inflate Sample Size  200/0.67 = 298.5 round up to 300
# So enroll 150 per group
200/.67
# = 298.5075 so round up to 300


# Example | Gulf War Study | Primary Outcome
# key quantities:
# power = 0.95
# MCID -- use p1=0.3 and p2=0.15
# significance level = 0.05
# n: leave unspecified as this is what we 
# want to know
# two-sided test of proportions
# Note: The power function for prop-tests 
# wants the effect sizes represented as h 
# (the formula given below).
h = 2*asin(sqrt(0.30))-2*asin(sqrt(0.15))
pwr.2p.test(h = h, power=0.95, sig.level = 0.05)

# This calculation yields 196.28, which rounds 
# up nicely to 200 per group
# Now incorporate attrition rate of 10%
# we want TOTAL SUBJECTS ENROLLED x 0.90 = 400
totalsubjects <- 400/0.90 
totalsubjects
450/2
# yields 444.44 subjects which rounds up to 
# 450 -- 225 per group!

# Example | Gulf War Study | Secondary Outcomes
# key quantities:
# d = leave this out of function as we want to 
# know this value
# power = 0.90
# n =200 per group (recall we want 200 at END of study)
# significance level = 0.05
# two-sided test 
# use pwr function for t.test
# - Note: The power function for t-tests wants 
# the effect size and variability input as d = delta/sigma, 
# rather than separately. 
pwr.t.test(power = 0.90, sig.level=0.05, n=200, 
           type="two.sample",alternative="two.sided")

# This yields an effect size (d) of 0.32.


 

# --------------------------------------------------
# End of Program

 
