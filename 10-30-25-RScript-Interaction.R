# ~~~~~~~~~~~~~~~~~~~~~~~~~
# ~ CRP 241 Interaction    ~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~

# ------------------------------------------------------------------------------------
# Example 1

# FEV1 and Smoking Status: 
# A study was conducted to determine if there was an association 
# between smoking status and forced expiratory volume in one 
# second (FEV1) in patients with COPD.FEV1 was measured in liters. 
# Smoking groups of interest were smokers (current,recent, or 
# former smokers) vs. non- smokers. Whether or not a patient was 65
# years or older was also recorded. 200 patients were randomly 
# selected from the researchers' clinical practice. 

# Data Dictionary: 
# 1.  FEV1      forced expiratory volume in one second (liters)
# 2.  SMOKING   patient smoking status (1 = Current/recent/former 
#                                      smoker; 0 = Non-smoker)
# 3.	AGE65     patient age (1 = Age >= 65 years; 0 = Age < 65 years)

# Download and load the lead dataset used in lecture: 
load(url("https://www.duke.edu/~sgrambow/crp241data/fev1_smoking.RData"))

# examine the data
str(fsdata)
summary(fsdata)

# lets subset the data by age and by 
# smoking status

# subset by age
old   <- subset(fsdata,AGE65==1)
young <- subset(fsdata,AGE65==0)

# let's look at some quick summary stats 
# by AGE and SMOKING status
# FEV1 by AGE65
by(fsdata$FEV1,fsdata$AGE65,summary) 
# FEV1 by SMOKING
by(fsdata$FEV1,fsdata$SMOKING,summary) 

# (1) Two Sample T-test Analysis in Entire Cohort 
#     - Assuming population variances are equal 

t.test(fsdata$FEV1~fsdata$SMOKING,var.equal=T)
3.233291 - 3.920575 

# (2) Two Sample T-test Analysis Stratified by Age 

# - (2a) Among Age < 65 years
by(young$FEV1,young$SMOKING,summary) 
summary(young$FEV1)

t.test(young$FEV1~young$SMOKING,var.equal=T)
3.604099 - 3.961962

# - (2b) Among Age >= 65 years
by(old$FEV1,old$SMOKING,summary) 
summary(old$FEV1)

t.test(old$FEV1~old$SMOKING,var.equal=T)
2.862483 - 3.879188

# (3) Linear Regression Analysis with Interaction Term
ifit <- lm(FEV1~SMOKING + AGE65 + SMOKING*AGE65,data=fsdata)
summary(ifit)

# (4) Linear Regression Analysis Stratified by Age 


# - (4a) Among Age < 65 years
yfit <- lm(FEV1~SMOKING,data=young)
summary(yfit)
confint(yfit)

# - (4b) Among Age >= 65 years
ofit <- lm(FEV1~SMOKING,data=old)
summary(ofit)
confint(ofit)

# (5) Linear Regression Analysis Ignoring Age
ufit <- lm(FEV1~SMOKING,data=fsdata)
summary(ufit)
confint(ufit)

# ------------------------------------------------------------------------------------
# Example 2

# Low Birth Weight Data: 
# A study was performed at Baystate Medical Center, 
# Springfield, Massachusetts, to understand the variables 
# that are related to  the likelihood of a mother giving 
# birth to a baby with low-birth weight (defined as a baby 
# weighing less than 2500g). 189 mothers were randomly 
# selected to partcipate in the study. 

# Data Dictionary: 
# There are numerous variables in the dataset but those of interest for the 
# current exercise include:
# 1.  bwt     birth weight of baby (grams)
# 2.  age     age of mother during pregnancy (years)
# 3.  smoke   smoking status of mother during pregnancy 
#     (1 = smoker; 0 = non-smoker)

# Download and load the lead dataset used in lecture: 
load(url("https://www.duke.edu/~sgrambow/crp241data/bwdata.RData"))

# Question 1: 
# Is there evidence of an association between a mother's age 
# during pregnancy and a baby's birth weight? Perform a 
# hypothesis test. 
fit1 <- lm(bwt ~ age, data=bwdata)
summary(fit1)

# Question 2: 
# Create a figure to describe the relationship examined in 
# Question 1. 
plot(bwdata$age,bwdata$bwt,
     xlab='Mothers Age During Pregnancy (age)',
     ylab='Babys Birth Weight (grams)',
     cex=2)
abline(fit1,lwd=3)

# Question 3: 
# Is there evidence that the association between a mother's 
# age during pregnancy and a baby's birth weight depends on 
# the mother's smoking status during 
# pregnancy? Perform a hypothesis test. 
fit2 <- lm(bwt ~ age + smoke + age*smoke, data=bwdata)
summary(fit2)

# Question 4: 
# Modify the figure created in Question 2 to describe the 
# relationship examined in Question 3. Using this figure, 
# describe the observed effect modification, 
# if one exists. 
smoker    <- subset(bwdata,smoke==1)
nonsmoker <- subset(bwdata,smoke==0)

fit3 <- lm(bwt ~ age, data=smoker)
summary(fit3)
confint(fit3)

fit4 <- lm(bwt ~ age, data=nonsmoker)
summary(fit4)
confint(fit4)

plot(nonsmoker$age,nonsmoker$bwt,
     xlab='Mothers Age During Pregnancy (age)',
     ylab='Babys Birth Weight (grams)',
     col='royalblue',cex=2)
points(smoker$age,smoker$bwt,
       col='sienna3',pch=19,cex=2)
abline(fit4,col='royalblue',lty=2,lwd=3)
abline(fit3,col='sienna3',lwd=3)
legend('topleft',c('Smoker','Non-Smoker'),
       col=c('sienna3','royalblue'),
       lty=c(1,2),lwd=2,horiz=T)

# ------------------------------------------------------------------------------------
# End of Program