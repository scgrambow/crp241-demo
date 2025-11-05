# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~ CRP 241 Confounding~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ------------------------------------------------------------------------------------
# Example 1

# FEV1 and Genetic Variation: 
# A study was conducted to determine if there was an 
# association between a genetic variant and forced 
# expiratory volume in one second (FEV1) in patients 
# with COPD. FEV1 was measured in liters. Genotypes 
# of interest were wild type vs. mutant (i.e. heterozygous 
# or homozygous for risk allele). Sex at birth was also recorded. 
# 100 patients were randomly selected from the researchers
# clinical practice. 

# Data Dictionary: 
# 1.  FEV1      forced expiratory volume in one second (liters)
# 2.  GENO      patient genotypes (1 = Mutant; 0 = Wild Type)
# 3.	SEX       patient sex at birth (1 = Female; 0 = Male)

# Download and load the lead dataset used in lecture: 
load(url("http://www.duke.edu/~sgrambow/crp241data/fev1_geno.RData"))

# examine the data
# provides structure of variables in data frame
str(fgdata) 
# provides descriptive summaries by variable
summary(fgdata) 


# Add labels to sex and genotype variables 
# to make ouptut easier to interpret
fgdata$fSEX <- factor(fgdata$SEX,labels=c('Male','Female'))
fgdata$fGENO <- factor(fgdata$GENO,labels=c('Wild Type','Mutant'))

# check labels and coding
str(fgdata)
# Recall: SEX     patient sex at birth (1 = Female; 0 = Male)
table(fgdata$fSEX,fgdata$SEX)
# Recall: GENO      patient genotypes (1 = Mutant; 0 = Wild Type)
table(fgdata$fGENO,fgdata$GENO)

# Is sex a confounder of the relationship between FEV1 
# and genotype? 
# Checking confounder criteria
# Is sex associated with covariate (genotype)
# - Check distribution of sex by each genotype
table(fgdata$fSEX,fgdata$fGENO)                  # Counts
prop.table(table(fgdata$fSEX,fgdata$fGENO),2)    # Proportions among genotype

# ANSWER: 38% vs. 66% females among patients with 
#         Wild Type vs. Mutant genotype

# Is sex associated with outcome?
# - Check distribution of FEV1 by each genotype
boxplot(fgdata$FEV1~fgdata$fSEX,
        ylab='FEV1 Level (liters)')

# Boxplots of PEAKVO212 by treatment arm
boxplot(fgdata$FEV1~fgdata$fSEX,
        main='FEV1 by Genotype',
        ylab='FEV1 Level (liters)',
        xlab=c('Genotype'),
        col=c('sienna','lightblue'),
        range=0)
# overlay individual data points
stripchart(fgdata$FEV1~fgdata$fSEX,method = "jitter", 
           pch=16,vertical = TRUE,add=TRUE)
# overlay means
# subset data frame to males and females
males <- subset(fgdata,fSEX=='Male')
females <- subset(fgdata,fSEX=='Female')

# get means by sex
mean.males <- mean(males$FEV1)
mean.females <- mean(females$FEV1)

# store as vectors
sex.means <- c(mean.males,mean.females)

#add points()
points(sex.means,cex=1.7,pch=16,col="dark orange")

# boxplot suggests there are differences
# in distribution of FEV1 by Sex

# lets create genotype subsets for 
# calculations of means by genotype
wild <-subset(fgdata,fGENO == 'Wild Type')
mutant <-subset(fgdata,fGENO == 'Mutant')
# get means
mean.wild <- mean(wild$FEV1)
mean.mutant <- mean(mutant$FEV1)

# (1) Two Sample T-test Analysis
#     - Assuming population variances are equal 
# we assume equal variances to show equivalence
# with simple linear regression which assumes
# equal variances
t.test(fgdata$FEV1~fgdata$GENO,var.equal=T)
# calculate difference in gentoype means
mean.wild - mean.mutant

# ANSWER -- difference in means is 0.4168

# Now lets look at the same data and analyze
# using simple linear regression

# (2) Unadjusted Linear Regression Analysis
ufit <- lm(FEV1 ~ GENO, data=fgdata)
summary(ufit)
confint(ufit)
# ANOVA Table for ufit
summary(aov(ufit))

# note that the slope coefficient is -0.41683
# which is equal to the difference in the means 
# that was found with the t-test. The only difference
# is that the linear regression is taking the 
# difference in the opposite direction
# mean.mutant - mean.wild
mean.mutant - mean.wild

# KEY POINT
# t-test with equal variances and simple 
# linear regression yield same answer!

# Now lets adjust for SEX
# we cannot do this with t-test
# Only with Regression!

# (3) Adjusted Linear Regression Analysis
afit <- lm(FEV1 ~ GENO + SEX, data=fgdata)
summary(afit)
confint(afit)
# ANOVA Table for afit
summary(aov(afit))


# Now lets explore what regression is actually doing...

# (4) Stratified Analysis 
# analyzing data by SEX using subsets 
# males and females from above
# lets look at mean FEV1 by genotype within SEX
females.mutant <- subset(females,fGENO=='Mutant')
females.wild <- subset(females,fGENO=='Wild Type')
# get means
mean.females.mutant <- mean(females.mutant$FEV1)
mean.females.wild <- mean(females.wild$FEV1)

# - How does "adjusting" work
#Mean difference among females
mean.females.mutant
mean.females.wild
mean.females.mutant - mean.females.wild


# Mean difference among males
males.mutant <- subset(males,fGENO=='Mutant')
males.wild <- subset(males,fGENO=='Wild Type')
# get means
mean.males.mutant <- mean(males.mutant$FEV1)
mean.males.wild <- mean(males.wild$FEV1)

# - How does "adjusting" work
#Mean difference among females
mean.males.mutant
mean.males.wild
mean.males.mutant - mean.males.wild

# now lets calculate the 
# Average of strata-differences 
((mean.females.mutant - mean.females.wild) +
    (mean.males.mutant - mean.males.wild)) / 2
         
# - (4a) Unadjusted Linear Regression Analysis Among Females
ffit <- lm(FEV1 ~ GENO, data=females)
summary(ffit)
confint(ffit)

# Note that the slope coefficient equals the difference
# in means between the genotypes among females

# - (4a) Unadjusted Linear Regression Analysis Among Males
mfit <- lm(FEV1 ~ GENO, data=males)
summary(mfit)
confint(mfit)

# Note that the slope coefficient equals the difference
# in means between the genotypes among males

# ------------------------------------------------------------------------------------
# Example 2

# Lead Study Data: 
# A study was performed of the effects of exposure to lead on the 
# psychological and neurological well-being of children.  The data
# for this study are provided in the lead Dataset, posted on the 
# course web site.  In summary, a group of children living near a 
# lead smelter in El Paso, Texas, were identified and their blood 
# levels of lead were measured.  

# An exposed group of 36 children were identified who had blood-lead 
# levels >= 40 ug/ml.  This group is defined by the variable 
# Group = 2.  A control group of 66 children were also identified 
# who had blood-lead levels <40 ug/ml.  This group is identified 
# by the variable GROUP = 1. All children lived in close proximity 
# to the lead smelter.  

# One of the key outcome variables studied was the number of finger-wrist 
# taps in the dominant hand (#taps in one ten second trial), a measure of 
# neurological function (MAXFWT).

# Data Dictionary: 
# There are numerous variables in the lead dataset but those of 
# interest for the current exercise include:
# 1.  ageyrs    age of child in years xx.xx
# 2.  Group     exposure group (1= Control, 2= Exposed)
# 3.	maxfwt    finger-wrist tapping test in dominant hand 
#                (max of right and left hands)

# Download and load the lead dataset used in lecture: 
load(url("http://www.duke.edu/~sgrambow/crp241data/lead.RData"))

# Note: Missing values in maxfwt are coded as a 99. 
#       - Recode as an NA so that R treats them correctly as missing values.
lead$maxfwt[lead$maxfwt==99] <- NA

# Question 1: 
# Is age a confounder of the relationship between lead exposure and the 
# score of the finger-wrist tapping test?

#ANSWERS:
# examining association between AGE and MAXFWT 
# using scatterplot and pearson correlation coefficient
plot(lead$ageyrs,lead$maxfwt)
cor.test(lead$ageyrs,lead$maxfwt)

# examining association between AGE and GROUP 
# using boxplot, comparison of summary statistics and t-test
# equivalently, one could use SLR to compare AGE and GROUP as well
# since we now know it is equivalent to t-test
boxplot(lead$ageyrs~lead$Group,
main="age dist by exposure 1= Control, 2= Exposed")

by(lead$ageyrs,lead$Group,summary)

t.test(lead$ageyrs~lead$Group,var.equal=T)
9.327-8.270

summary(lm(lead$ageyrs~lead$Group))

# Question 2: 
# Estimate the unadjusted association between lead exposure and the 
# score of the finger-wrist tapping test. Is it statistically significant?

#ANSWER
# we can use SLR as in example 1 to examine
# the unadjusted relationship between group and maxfwt
ufit <- lm(maxfwt ~ Group, data=lead)
summary(ufit)

# Question 3: 
# Estimate the association between lead exposure and the score of the 
# finger-wrist tapping test adjusted for age. Is it statistically significant?

#ANSWER
# we can use adjusted linear regression as in example 1 to examine
# the relationship between maxfwt and group, adjusted for age
afit <- lm(maxfwt ~ Group + ageyrs, data=lead)
summary(afit)

# Question 4: 
# What is the impact of adjusting for age on the conclusions of the analysis?

#ANSWER
# as discussed, the parameter estimate for Group is attenuated when age is 
# included in the model, going from -7.009 in the unadjusted model to -4.85 
# in the adjusted model. Given that the controls were on 
# average about 1 year older than the exposed group, and the 
# developmental advantage this might convey, the attenuating effect 
# observed makes sense.

# Question 5: 
# How were the missing values handled in the regression analysis?

# ANSWER
# After converting the missing values from 99 to NA so R correctly recognizes
# them as missing, the lm function simply 'kicks out' or excludes any 
# observation that is missing for any variable included in the regression
# model.  This is the usual default approach in most software packages
# Note that this can result in bias if the missingness is 'informative'
# or nonrandom.

# ------------------------------------------------------------------------------------
# End of Program