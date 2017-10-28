# library(gdata)
library(rpart)
library("rpart.plot")
library(caret)
library(FSelector)
library(randomForest)
library("party")
library(RWeka)

dat = read.csv("/Users/jmiller/Projects/dataMining/projectOne/rCode/projectTwoClean/2001-clean.csv", header=TRUE, sep=",")

dat2 <- dat

dat2$SupervisoryStatus <- as.numeric(as.character(dat2$SupervisoryStatus))
dat2$Station <- as.numeric(as.character(dat2$Station))
dat2$Education <- as.numeric(as.character(dat2$Education))
dat2$Age <- as.numeric(substr(dat2$Age, start = 1, stop = 2))
dat2$LOS <- as.numeric(sub("-.*|\\+|<", "", dat2$LOS))
dat2$Pay <- cut(dat2$Pay,
  breaks = c(0, 50000, 75000, 100000 ,Inf),
  labels = c("<50k", "50-75k", "75k-100k", ">100k"))

agencies <- names(which(table(dat2$AgencyName)>10000))


dat2$LOS <- cut(dat2$LOS,
  breaks = c(0, 1, 7, 12 ,Inf),
  labels = c("< 1","1-7","7-12","12+"))




dat3 <- dat2[dat2$AgencyName %in% agencies, ]
# get rid of unused agency levels
dat3$AgencyName <- factor(dat3$AgencyName)
dat3$Agency <- factor(dat3$Agency)

# myData <- c('Education','LOS','Pay','Age','SupervisoryStatus')
myData <- c('Education','Pay','Age','LOS','SupervisoryStatus','Station')
new <- dat3[myData]
print(nrow(new))
print(ncol(new))
# print(summary(new))


# Determine the important features for specific attribute.
# Just specify the attribute in the first argument of chi.squared
weights <- chi.squared(SupervisoryStatus ~ ., data=new)
print(weights)

o <- order(weights$attr_importance)
dotchart(weights$attr_importance[o], labels = rownames(weights)[o],
  xlab = "Importance")

# print(dim(dat3))

sample_ID <- sample(1:nrow(dat3), size = 10000)
dat4 <- dat3[sample_ID, ]

# model <- rpart(Pay ~ Age + Education, data = dat4)


#
# ############## RPART For Pay ###################
fit <- train(Pay ~ Age + Education + LOS, data = dat4 , method = "rpart",
  na.action = na.pass,
  trControl = trainControl(method = "cv", number = 10),
  tuneLength=10)

rpart.plot(fit$finalModel, extra = 2, under = TRUE, varlen=0, faclen=0)

print(varImp(fit))

testing <- dat3[-sample_ID, ]
testing <- testing[sample(1:nrow(testing), size = 1000), ]

pred <- predict(fit, newdata = testing, na.action = na.pass)
print(head(pred))

print(confusionMatrix(data = pred, testing$Pay))
# ####################################################

############### Neural Net for Pay ###############

nnetFit <- train(Pay ~ Age + Education + LOS, method = "nnet", data = dat4,
    tuneLength = 5,  na.action = na.pass,
    trControl = trainControl(
        method = "cv"),
  trace = FALSE)

  print(nnetFit)
  print(nnetFit$finalModel)

#####################################################################

################# Random Forest for Pay #################

C45Fit <- train(Pay ~ Age + Education + LOS, method = "J48", data = dat4,
    tuneLength = 5,na.action = na.pass,
    trControl = trainControl(
        method = "cv"))
print(C45Fit)

###################################################



############## MODEL OF LOS ###################
fit <- train(LOS ~ Age + Pay, data = dat4 , method = "rpart",
  na.action = na.omit,
  trControl = trainControl(method = "cv", number = 10),
  tuneLength=10)

rpart.plot(fit$finalModel, extra = 1, under = TRUE, varlen=0, faclen=0)

print(varImp(fit))

testing <- dat3[-sample_ID, ]
testing <- testing[sample(1:nrow(testing), size = 1000), ]

pred <- predict(fit, newdata = testing, na.action = na.pass)
print(head(pred))

print(confusionMatrix(data = pred, testing$LOS))
####################################################


############## C Tree for SupervisoryStatus #######################

x <- ctree(SupervisoryStatus ~ Pay  + LOS, data=dat4)
plot(x, type="simple")

#####################################################################
