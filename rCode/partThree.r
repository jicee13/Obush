# library(gdata)
library(rpart)
library("rpart.plot")
library(caret)
library(FSelector)
library(randomForest)
library("party")
library(RWeka)
library(arules)
library(arulesViz)
library(ROCR)

dat = read.csv("/Users/jmiller/Projects/dataMining/projectOne/rCode/projectTwoClean/2001-clean.csv", header=TRUE, sep=",")

dat2 <- dat


dat2$SupervisoryStatus <- as.numeric(as.character(dat2$SupervisoryStatus))
dat2$Station <- as.numeric(as.character(dat2$Station))
dat2$Education <- as.numeric(as.character(dat2$Education))
dat2$Age <- as.numeric(substr(dat2$Age, start = 1, stop = 2))
dat2$LOS <- as.numeric(sub("-.*|\\+|<", "", dat2$LOS))


agencies <- names(which(table(dat2$AgencyName)>10000))

# #dat3 is our datafram used for the first transaction
# dat3 <- dat2
#
# dat3$SupervisoryStatus <- NULL
# dat3$Station <- NULL
# dat3$OccTrans <- NULL
# dat3$EducationName <- NULL
# dat3$Occupation <- NULL
# dat3$States <- NULL
# dat3$Category <- NULL
# dat3$X <- NULL
# dat3$AgencyName <- NULL
# dat3$Agency <- NULL
#
# dat3$Pay <- cut(dat3$Pay,
#   breaks = c(0, 50000, 75000, 100000 ,Inf),
#   labels = c("<50k", "50-75k", "75k-100k", ">100k"))
#
# dat_set1 <- dat3[dat3$Pay == ">100k",]
# dat_set2 <- dat3[dat3$Pay == "<50k",]
# dat_1_2 <- rbind(dat_set1, dat_set2)
#
# dat_1_2$LOS <- discretize(dat_1_2$LOS, method = "frequency")
# dat_1_2$Education <- discretize(dat_1_2$Education, method = "frequency")
# dat_1_2$Age <- discretize(dat_1_2$Age, method = "frequency")
#
# dat_set1 <- dat_1_2[dat_1_2$Pay == ">100k",]
# dat_set2 <- dat_1_2[dat_1_2$Pay == "<50k",]
#
# trans1 <- as(dat_set1, "transactions")
# trans2 <- as(dat_set2, "transactions")
#
# print(summary(trans2))
# itemFrequencyPlot(trans2, topN = 10)


#dat4 is our datafram used for the first transaction
dat4 <- dat2
dat4$Education <- cut(dat4$Education,
  breaks = c(0, 6, 12, 13 ,Inf),
  labels = c("High School or less", "Some College", "Bachelor's", "Post Bach"))

dat4$SupervisoryStatus <- NULL
#dat4$Station <- NULL
dat4$OccTrans <- NULL
dat4$EducationName <- NULL
#dat4$Occupation <- NULL
#dat4$States <- NULL
# dat4$Category <- NULL
dat4$X <- NULL
# dat4$AgencyName <- NULL
dat4$Agency <- NULL

dat_set1 <- dat4[dat4$Education == "Bachelor's",]
dat_set2 <- dat4[dat4$Education == "Some College",]
dat_1_2 <- rbind(dat_set1, dat_set2)

dat_1_2$LOS <- discretize(dat_1_2$LOS, method = "frequency")
dat_1_2$Pay <- discretize(dat_1_2$Pay, method = "frequency")
dat_1_2$Age <- discretize(dat_1_2$Age, method = "frequency")
dat_1_2$Station <- discretize(dat_1_2$Station, method = "frequency")


dat_set1 <- dat_1_2[dat_1_2$Education == "Bachelor's",]
dat_set2 <- dat_1_2[dat_1_2$Education == "Some College",]

trans1 <- as(dat_set1, "transactions")
trans2 <- as(dat_set2, "transactions")

# print(summary(trans2))
itemFrequencyPlot(trans2, topN = 10)

is <- apriori(trans2, parameter=list(target="frequent", support=0.1))
is <- sort(is, by="support")
print('first')
print(inspect(head(is, n=10)))
barplot(table(size(is)), xlab="itemset size", ylab="count")
dev.new()
is_max <- is[is.maximal(is)]
print('second')
print(inspect(head(sort(is_max, by="support"))))
barplot(table(size(is_max)), xlab="itemset size", ylab="count")
dev.new()
is_closed <- is[is.closed(is)]
print('third')
print(inspect(head(sort(is_closed, by="support"))))
barplot(table(size(is_closed)), xlab="itemset size", ylab="count")
dev.new()

barplot(c(
  frequent=length(is),
  closed=length(is_closed),
  maximal=length(is_max)
  ), ylab="count", xlab="itemsets")

rules <- apriori(trans1, parameter=list(support=0.1, confidence=.8))
print(summary(rules))
rules <- sort(rules, by="lift")
inspect(head(rules, n=10))

r <- sample(rules, 30)
q <- interestMeasure(r, measure = c("supp", "confidence", "lift"),
  transactions = trans2, reuse = FALSE)
diff <- (quality(r)[,-4] - q)/quality(r)[,-4]
print(diff)
print(inspect(r[which(diff$supp > 0.2 & diff$supp!=1)]))
print(inspect(r[which(diff$supp < -0.1)]))
print(inspect(r[which(diff$lift > 0.1)]))
print(inspect(r[which(diff$lift < -0.1)]))
r <- apriori(trans2)
interestMeasure(rules[1:10], measure=c("phi", "gini"),
  trans=trans1)
quality(rules) <- cbind(quality(rules),
  interestMeasure(rules, measure=c("phi", "gini"),
    trans=trans1))

plot(rules)
dev.new()
plot(rules, method="grouped")
dev.new()
plot(rules, method="paracoord")
