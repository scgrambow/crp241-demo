# ~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~ CRP 241
# ~ Change Scores and ANCOVA
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ------------------------------------------------------------------------------------
# Cholesterol Data Example: 
# Data was obtained from a study conducted to examine 
# the relationship between total serum cholesterol 
# levels and heart attacks among subjects who experienced 
# a recent ACS event. A total of 28 subjects were 
# recruited for the study. Each subject had their 
# cholesterol levels measured at 2 days, 4 days, 
# and 14 days post heart attack.

# Load the data: 
load(url("http://www.duke.edu/~sgrambow/crp241data/cholesterol-paired.RData"))

# Data Set: cholesterol.paired

# Data Dictionary: 
# (1) patient    patient identifier 
# (2) DAY2       total serum cholesterol (mg/dL) 
#                measured 2 days post-MI
# (3) DAY4       total serum cholesterol (mg/dL) 
#                measured 4 days post-MI
# (4) DAY14      total serum cholesterol (mg/dL) 
#                measured 14 days post-MI
# (5) DAY14MSNG  binary flag for DAY14 missingness 
#                (1 = missing vs. 0 = non-missing)

# Compute summary statistics for paired differences: 
# What is the difference between the next 
# command and the one below it?

# paired.diff <- cholesterol.paired$DAY4-cholesterol.paired$DAY2
cholesterol.paired$paired.diff <- cholesterol.paired$DAY4-
                                  cholesterol.paired$DAY2
summary(cholesterol.paired$paired.diff)

# - Histogram of paired differences:
hist(cholesterol.paired$paired.diff,freq=FALSE,
     main='4Days vs. 2Days Post-MI Differences',
     ylab='Proportion',
     xlab='Day4 - Day 2 Differences in Cholesterol',
     col=('lightblue'))

# - Boxplot of paired differences: 
boxplot(cholesterol.paired$paired.diff,
        main='4Days vs. 2Days Post-MI Differences',
        ylab='cholesterol levels',
        col='sienna',
        range=0)
# overlay individual data points
stripchart(cholesterol.paired$paired.diff,
           method = "jitter", pch=16,vertical = TRUE,add=TRUE)
# overlay mean
points(mean(cholesterol.paired$paired.diff),cex=1.7,pch=16,col="orange")

# Plot paired data to see what the individual 
# pairs look like
library(PairedData)

# create paired data object needed for plots
pairs <- with(cholesterol.paired,paired(DAY2,DAY4))

# we create two plots
# the first is a Mcneil plot. This plot shows
# each subject on a row and displays each component
# measure of the paired calculation so you can see
# the magnitude of change for each pair
plot(pairs, type = "McNeil")

# The second plot is a profile plot that 
# The second plot is a profile plot. It is a boxplot that 
# shows a line between each of your paired groups. 
# If most of the lines go one way, then it is likely that 
# one group is consistently higher than the other 
plot(pairs, type = "profile")

# - Compute 95% CI for paired mean diff, test stat,and p-value:
t.test(cholesterol.paired$DAY4,cholesterol.paired$DAY2,paired=TRUE)

# OR Alternatively (and equivalently)
t.test(cholesterol.paired$paired.diff)

# - What if we (incorrectly) used the two sample t-test instead?
t.test(cholesterol.paired$DAY4,cholesterol.paired$DAY2)
mean(cholesterol.paired$DAY4)-mean(cholesterol.paired$DAY2)

# ------------------------------------------------------------------------------------
########################################################
# Example: The Acupuncture Dataset -- needle.RData
# Key Variables
# group	           = 0 is control, 1 is acupuncture
# pk1	             = severity score (baseline)
# pk2	             = severity score posttreatment
# pk5	             = severity score (one year followup)
# ChangeFrom.pk1   = change in severity score (pk1-pk5)
# f1 heache frequency at baseline
# f1cat This is a categorized version of f1 with 
#      low = frequency <= 33rd percentile = 12
#      med = frequency > 33rd percentile = 12 
#            and <= 67th percentile = 19
#     high = frequency > 67th percentile = 19
#
########################################################

# Download and load the file
load(url("http://www.duke.edu/~sgrambow/crp245data/needle.RData"))
              
# Quick summary of key variables
summary(needle$pk1)
summary(needle$pk5)
summary(needle$ChangeFrom.pk1)

# Quick summary of key variables by group
# Subset data into two treatment groups
Treat <- subset(needle,needle$fgroup=="Treat")
Control <- subset(needle,needle$fgroup=="Control")

# Summary of outcome by group at baseline
summary(Treat$pk1)
summary(Control$pk1)

# Summary of outcome by group at 12 months
summary(Treat$pk5)
summary(Control$pk5)

# Summary of Change from baseline in outcome by group
summary(Treat$ChangeFrom.pk1)
summary(Control$ChangeFrom.pk1)

# - Boxpots of key variables by group:
# - Boxplot of pk1: 
boxplot(pk1~fgroup,data=needle,
        main='Boxplots of pk1 by Group',
        ylab='pk1 -- Baseline Score')

# - Boxplot of pk5: 
boxplot(pk5~fgroup,data=needle,
        main='Boxplots of pk5 by Group',
        ylab='pk5 -- 12 month Score')

# - Boxplot of ChangeFrom.pk1: 
boxplot(ChangeFrom.pk1~fgroup,data=needle,
        main='Boxplots of Change from Baseline to 12 months by Group',
        ylab='pk1 - pk5 Change from Baseline to 12 months')

# Plot paired data to see what the individual 
# pairs look like
library(PairedData)

# create paired data object needed for plots
needle.pairs <- with(needle,paired(pk1,pk5))

# we create two plots
# the first is a Mcneil plot. This plot shows
# each subject on a row and displays each component
# measure of the paired calculation so you can see
# the magnitude of change for each pair
plot(needle.pairs, type = "McNeil")

# The second plot is a profile plot that 
# The second plot is a profile plot. It is a boxplot that 
# shows a line between each of your paired groups. 
# If most of the lines go one way, then it is likely that 
# one group is consistently higher than the other 
plot(needle.pairs, type = "profile")

############################
## Analysis
############################


####Change Score - Two Sample t-test assuming equal variances
t.test(needle$ChangeFrom.pk1~needle$fgroup,var.equal=TRUE)
mean(Treat$ChangeFrom.pk1,na.rm=TRUE)-mean(Control$ChangeFrom.pk1,na.rm=TRUE)


####Follow up score - Two Sample t-test assuming equal variances
t.test(needle$pk5~needle$fgroup,var.equal=TRUE)
mean(Control$pk5,na.rm=TRUE)-mean(Treat$pk5,na.rm=TRUE)


####Recall what Simple Linear Regression looks like
lm.slr<-lm(needle$pk5~needle$group)     
summary(lm.slr)
confint(lm.slr)


####ANCOVA model specification
# Here pk5 is the outcome
lm.ancova<-lm(needle$pk5~needle$pk1+needle$group)     
summary(lm.ancova)
confint(lm.ancova)

####ANCOVA model specification
# Here pk1 - pk5 is the outcome
# This alternate specification of the outcome
# yields same result -- difference is one
# of interpretation
lm.ancova<-lm(needle$ChangeFrom.pk1~needle$pk1+needle$group)     
summary(lm.ancova)
confint(lm.ancova)

# Here is a regression model, similar to the ANCOVA model
# above, but this models allows the slope of the baseline
# value, pk1, to vary across treatment groups.
####Multiple linear regression model specification
# Here pk5 is the outcome
# models different slopes for each group
lm.mlr<-lm(needle$pk5~needle$pk1+needle$group
           +needle$pk1*needle$group)     
summary(lm.mlr)

# You can also specify the same model with slightly
# different notation
lm.mlr<-lm(needle$pk5~needle$pk1+needle$pk1*needle$group)     
summary(lm.mlr)



# plotting the ancova model
#install.packages("HH")
library(HH)
# plotting ancova to visaluize homogeneity of slopes assumption
ancovaplot(pk5~pk1+fgroup,data=needle)
# check homogeneity of slopes -- include interaction
ancovaplot(pk5~pk1*fgroup,data=needle)
# what does it look like without ANCOVA -- just comparing means
# for this plot we need to remove missing values to avoid
# error message
complete.needle <- needle[complete.cases(needle),]
ancovaplot(pk5~ fgroup,x=pk1,data=complete.needle)
# End of Program