# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~ CRP 241                  ~
# ~ Simple Linear Regression ~
# ~                          ~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Body Fat Data:
# Percentage of body fat, age, weight, height, and ten body circumference 
# measurements (e.g., abdomen, neck, ankle, etc.) are recorded for 252 men. 
# Body fat is estimated through an underwater weighing technique. 

# There are numerous variables in the lead dataset but those of interest for 
# the current exercise include:
# 1.  brobf  : % Body Fat
# 2.  abdmn  : Abdomen Circumference (cm)
# 3.  neck   : Neck Circumference (cm)
# 4.  ankle  : Ankel Circumference (cm)
# 5.  height : Height (in)

## Download and load the data file = bpdata
load(url("https://www.duke.edu/~sgrambow/crp241data/bodyfat.RData"))

# ------------------------------------------------------------------------------------
# Describing the data

# - Summary statistics 
# Reponse/outcome/dependent variable
summary(bodyfat$brobf)      
# Covariate/explanatory/predictor/independent variable
summary(bodyfat$abdmn)    

# - Scatter plot to examine covariation 
plot(x=bodyfat$abdmn,y=bodyfat$brobf,
     main='Scatter Plot of % Body Fat vs. Abdomen Circ', 
     ylab='% Body Fat',
     xlab='Abdomen Circumference (cm)',
     cex=1.5,pch=19,col='blue')
# add a smoothed curve to
lines(lowess(bodyfat$abdmn,bodyfat$brobf),col="orange",lwd=2)
# ------------------------------------------------------------------------------------
# Fitting the simple linear regression model 
# Model: % Body Fat ~ Abdomen Circ 
fit <- lm(brobf ~ abdmn,data=bodyfat)
# Nice Summary Output of Regression model
# parameters and tests
summary(fit)
# Include confidence limits for regression parameters
confint(fit)

# ANOVA table for Simple Linear Regression
# More in a supplementary video about this
# this can be used to test the fit of the entire 
# model 
summary(aov(fit))

# ------------------------------------------------------------------------------------
# Plot the regression line
# 1. % Body Fat vs. Abdomen Circumference
# Add regression line to scatter plot
plot(x=bodyfat$abdmn,y=bodyfat$brobf,
     main='Scatter Plot of % Body Fat vs. Abdomen Circ', 
     ylab='% Body Fat',
     xlab='Abdomen Circumference (cm)',
     cex=1.5,pch=19,col='blue')
abline(fit,lty=1,col='red',lwd=2)

# add point 39 to highlight where it is
# possibly a problematic point?
points(148.1,33.8,cex=3,pch=1,col='red')

# what about the short person?
points(104.3,31.7,cex=3,pch=1,col='orange')

# ------------------------------------------------------------------------------------
# Using the simple linear regression model for ... 

# (1) Estimate the mean % body fat among men whose 
#     abdomen circumference is 100 cm

# Option 1: Do "by hand" 
-35.2 + (100*0.58489) 

# Option 2: Use predict() function 
predict(fit,newdata=data.frame(abdmn=100),interval='conf')

# (2) Estimate the % body fat for a new observation 
#     whose abdomen circumference is 100 cm

# Option 1: Do "by hand" 
-35.2 + (100*0.58489) 

# Option 2: Use predict() function 
predict(fit,newdata=data.frame(abdmn=100),interval='pred')

# - Visualization of estimation vs. prediction 
# - Create scatter plot of X vs. Y
plot(x=bodyfat$abdmn,y=bodyfat$brobf,col='blue',pch=19,cex=1.5)
# - Add the fitted regression line (black line)
abline(fit,lwd=2,col='red')

# - Add mean estimate for abdmn (red star)
beta0 <- fit$coefficients[1] # intercept
beta1 <- fit$coefficients[2] # slope
points(100,(beta0 + (100*beta1) ),pch='*',col='red',cex=3)
# - Add confidence bands for all mean estimates 
lines(seq(70,140,by=1),
      predict(fit,newdata=data.frame(abdmn=seq(70,140,by=1)),interval='conf')[,2],
      col='red',lty=2,lwd=2)
lines(seq(70,140,by=1),
      predict(fit,newdata=data.frame(abdmn=seq(70,140,by=1)),interval='conf')[,3],
      col='red',lty=2,lwd=2)

# - Add prediction for abdmn=100 (magenta star)
points(100,(beta0 + (100*beta1) ),pch='*',col='magenta',cex=3)
# - Add confidence bands for all predictions 
lines(seq(70,140,by=1),
      predict(fit,newdata=data.frame(abdmn=seq(70,140,by=1)),interval='pred')[,2],
      col='magenta',lty=2,lwd=2)
lines(seq(70,140,by=1),
      predict(fit,newdata=data.frame(abdmn=seq(70,140,by=1)),interval='pred')[,3],
      col='magenta',lty=2,lwd=2)

# ---------------------------------------------------------
# Checking the assumptions of the simple linear regression model 

# Now examine regression diagnostics for this model
# Using  Linear Regression Model above -- fit
#
# single command to produce suggested diagnostic plots
plot(fit)

# this will produce 4 plots
# 1. Residuals vs fitted to check linearity
# 2. Normal Q-Q to check normality of residuals
# 3. Scale-Location to check constant variance
# 4. Residuals vs Leverage to check for influential points

# To get all plots on one figure
par(mfrow=c(2,2)) # Change the panel layout to 2 x 2
plot(fit)
par(mfrow=c(1,1)) # Change back to 1 x 1

bodyfat_no39 <- bodyfat[-39,]
# - Use the function lm() to fit the linear regression model
fit_no39 <- lm(brobf~abdmn,data=bodyfat_no39)
summary(fit_no39)
confint(fit_no39)
# Add regression line to scatter plot
plot(x=bodyfat_no39$abdmn,y=bodyfat_no39$brobf,
     main='Scatter Plot of % Body Fat vs. Abdomen Circ', 
     ylab='% Body Fat',
     xlab='Abdomen Circumference (cm)',
     col='blue',pch=19,cex=1.5)
abline(fit,lty=1,col='black',lwd=2)

# what is predicted % body fat for men with 100 cm adbmn 
# for the model without point 39
predict(fit_no39,newdata=data.frame(abdmn=100),interval='conf')

# what is predicted % body fat for men with 100 cm adbmn 
# for the model with point 39
predict(fit,newdata=data.frame(abdmn=100),interval='conf')


# use qqplot() function from Car Package
# for a slightly nicer qq plot
# QQ-plots are ubiquitous in statistics. Most people 
# use them in a single, simple way: fit a linear regression 
# model, check if the points lie approximately on the line, 
# and if they don't, your residuals aren't Gaussian and 
# thus your errors aren't either. So standard confidence
# intervals and p-values may be invalid.
# 

library(car)
qqPlot(fit, main="Q-Q Plot") # from car package

# ------------------------------------------------------------------------------------

# How is the simple linear regression model really fit?
# just showing what is happening with regression
# not part of actual analysis 
fit <- lm(brobf ~ abdmn,data=bodyfat)
# - Create scatter plot of X vs. Y
plot(x=bodyfat$abdmn,y=bodyfat$brobf,cex=1.5,pch=19,col='blue')
# - Add the fitted regression line (black line)
abline(fit,lwd=2,col='red')
# - Add lines to represent residuals for two data points 
#   (red lines and red stars)
beta0 <- fit$coefficients[1]
beta1 <- fit$coefficients[2]
# highlight point (104.5, 16.9)
points(104.5,(16.9),pch=1,col='red',cex=3)
points(104.5,(beta0+(beta1*104.5)),pch='*',col='red',cex=3)
segments(104.5,16.9,104.5,(beta0+(beta1*104.5)),col='red',lty=2)

# highlight point (122.1,45.1)
points(122.1,(45.1),pch=1,col='red',cex=3)
points(122.1,(beta0+(beta1*122.1)),pch='*',col='red',cex=3)
segments(122.1,45.1,122.1,(beta0+(beta1*122.1)),col='red',lty=2)
# -----------------------------------------------------------------------------------

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~      Sample showing regression diagnostics             ~
# ~      for SLR with curvilinear data pattern            ~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Author -- Megan Neely, PhD (with some modifications from Steve)

# Download and load the linearity dataset: 
load(url("http://www.duke.edu/~sgrambow/crp241data/linearity.RData"))


# Plot the data to see the relationship between x and y: 
# - The dots represent the observed data, which contain noise (i.e. error)
#   we are trying to estimate using the data (i.e. via regression)
plot( linearity$x,linearity$y,pch=19,main='Scatterplot for X & Y',
      xlab='X',
      ylab='Y')


# What happens if we "fit a line" to the data to estimate the relationship 
# between x and y?
# - That is, we fit a linear regression line and assume the relationship 
#   between x and y is linear?
# (1) Fit the regression line
#     - NOTE: p-value for x is greater than 0.05; says there is no relationship 
#             between x and y, but we know that is not true from looking at the 
#             data. Happens because this analysis ignored the non-linear 
#             relationship between x and y. 
#     - the estimated slope is -0.07 and associated p-value is 0.15
fit <- lm(y~x,data=linearity) 
summary(fit)

# (2) Plot the fitted regression line (blue) and again the data (dots) 
#     
plot( linearity$x,linearity$y,pch=19,main='Scatterplot for X & Y with 
      Simple Linear Regression Line', xlab='X', ylab='Y')
abline(fit,col='blue',lty=2, lwd=2)

# check the diagnostics
par(mfrow=c(2,2)) # Change the panel layout to 2 x 2
plot(fit)
par(mfrow=c(1,1)) # Change back to 1 x 1
# You can see a clear curvilinear pattern in the Residuals vs Fitted plot suggesting
# a problem with linearity.
# End of Program




# End Program