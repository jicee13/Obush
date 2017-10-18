# library(gdata)
library(rpart)
library("rpart.plot")
library(caret)

dat = read.csv("/Users/jmiller/Projects/dataMining/projectOne/rCode/projectTwoClean/2001-clean.csv", header=TRUE, sep=",", nrows=150000)

dat2 <- dat

dat2$Education <- as.numeric(as.character(dat2$Education))
dat2$Age <- as.numeric(substr(dat2$Age, start = 1, stop = 2))
dat2$LOS <- as.numeric(sub("-.*|\\+|<", "", dat2$LOS))
dat2$Pay <- cut(dat2$Pay,
  breaks = c(0, 50000, 75000, 100000 ,Inf),
  labels = c("<50k", "50-75k", "75k-100k", ">100k"))

agencies <- names(which(table(dat2$AgencyName)>10000))


dat2$LOS <- cut(dat2$LOS,
  breaks = c(0, 1, 3, 5 ,Inf),
  labels = c("< 1","1-2","3-4","5+"))


dat3 <- dat2[dat2$AgencyName %in% agencies, ]
# get rid of unused agency levels
dat3$AgencyName <- factor(dat3$AgencyName)
dat3$Agency <- factor(dat3$Agency)

print(dim(dat3))

sample_ID <- sample(1:nrow(dat3), size = 10000)
dat4 <- dat3[sample_ID, ]

model <- rpart(Pay ~ Age + Education, data = dat4)



############## MODEL DONE IN CLASS###################
# fit <- train(Pay ~ Age + Education + LOS, data = dat4 , method = "rpart",
#   na.action = na.pass,
#   trControl = trainControl(method = "cv", number = 10),
#   tuneLength=10)
#
# rpart.plot(fit$finalModel, extra = 2, under = TRUE, varlen=0, faclen=0)
#
# print(varImp(fit))
#
# testing <- dat3[-sample_ID, ]
# testing <- testing[sample(1:nrow(testing), size = 1000), ]
#
# pred <- predict(fit, newdata = testing, na.action = na.pass)
# print(head(pred))
#
# print(confusionMatrix(data = pred, testing$Pay))
####################################################


############## MODEL OF LOS ###################
fit <- train(LOS ~ Age + Education, data = dat4 , method = "rpart",
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
