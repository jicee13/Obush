
library(jsonlite)
# fileNames <- list()
fileNames <- "/Users/jmiller/Desktop/opm-federal-employment-data/data/1973-09-to-2014-06/dod/status/Status_DoD_1973_09.txt"
# fileNames[1] <- "/Users/jmiller/Desktop/opm-federal-employment-data/data/1973-09-to-2014-06/dod/status/Status_DoD_1973_12.txt"
#fileNames[2] <- "/Users/jmiller/Desktop/opm-federal-employment-data/data/1973-09-to-2014-06/dod/status/Status_DoD_1974_03.txt"
agencyFile <- "/Users/jmiller/Desktop/opm-federal-employment-data/data/1973-09-to-2014-06/SCTFILE.TXT"
educationFile <- "/Users/jmiller/Desktop/opm-federal-employment-data/data/2014-09-to-2016-09/dod/translations/Education20Translation.txt"
ugh = c()

# for(item in fileNames) {
raw <- readLines(fileNames, n=100)

dat_header <- read.csv("/Users/jmiller/Projects/dataMining/projectOne/rCode/headers.csv", header = TRUE)
# dat_header

dat <- t(sapply(raw, FUN = function(x) trimws(substring(x, dat_header[,2], dat_header[,3]))))
dimnames(dat) <- NULL
dat <- as.data.frame(dat)

# ok <- unique( dat[ , 1 ] )


colnames(dat) <- dat_header[,1]
dat$Pay <- as.numeric(as.character(dat$Pay))
dat$Age <- as.numeric(substring(as.character(dat$Age), 1, 2))

startLength <- length(dat$PseudoID)



n_occur <- data.frame(table(dat$PseudoID))
dupTable <- dat[dat$PseudoID %in% n_occur$Var1[n_occur$Freq > 1],]
  # dupTable <- split(dat, f=dat$PseudoID)

  orderedDupTable <- dupTable[order(dupTable$PseudoID, -dupTable$Age, dupTable$Agency, dupTable$Pay),]

  gottaGo <- as.numeric(rownames(orderedDupTable[duplicated(orderedDupTable$PseudoID),]))

  #removed and duplicates that had lower ages and kept older age (most recent)
  dat <- dat[!(as.numeric(rownames(dat)) %in% gottaGo),]

  #pull duplicates out again
  n_occur <- data.frame(table(dat$PseudoID))
  dupTable <- dat[dat$PseudoID %in% n_occur$Var1[n_occur$Freq > 1],]
  orderedDupTable <- dupTable[order(dupTable$PseudoID, dupTable$Agency, -dupTable$Pay),]
  gottaGo <- as.numeric(rownames(orderedDupTable[duplicated(orderedDupTable$PseudoID, orderedDupTable$Agency),]))
  dat <- dat[!(as.numeric(rownames(dat)) %in% gottaGo),]

  lengthDiff <- startLength - length(dat$PseudoID)
  print(paste("Removed",toString(lengthDiff),"duplicates.", sep=" "))

  agency_trans <- readLines(agencyFile)
  agency_ID <- sapply(agency_trans, FUN = function(x) substring(x, 3,6))
  agency_name <- trimws(sapply(agency_trans, FUN = function(x) substring(x, 36,75)))
  

  education_trans <- readLines(educationFile)
  education_ID <- sapply(education_trans, FUN = function(x) substring(x, 1,2))
  education_name <- trimws(sapply(education_trans, FUN = function(x) substring(x, 29,103)))


  education_trans_table <- data.frame(education_ID = education_ID, education_name = education_name)
  m <- match(dat$Education, education_trans_table$education_ID)
  dat$EducationName <-  education_trans_table$education_name[m]

  agency_trans_table <- data.frame(agency_ID = agency_ID, agency_name = agency_name)
  m <- match(dat$Agency, agency_trans_table$agency_ID)
  dat$AgencyName <-  agency_trans_table$agency_name[m]
  print(agency_trans_table)

  dat$Fulltime <- FALSE
  dat$Fulltime[dat$Schedule == "F" | dat$Schedule == "G"] <- TRUE
  dat$Seasonal <- FALSE
  dat$Seasonal[dat$Schedule %in% c("G", "J", "Q", "T")] <- TRUE
  # ugh[length(ugh) + 1] <- dat
# }

#print(toJSON(summary(dat$AgencyName), pretty = TRUE))
write.table(summary(dat$AgencyName), file = "/Users/jmiller/Projects/dataMining/projectOne/rCode/dataexp.txt")
ok <- as.data.frame.matrix(read.table("/Users/jmiller/Projects/dataMining/projectOne/rCode/dataexp.txt"))
print(rownames(ok[1]))
