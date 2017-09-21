
library(jsonlite)
# fileNames <- list()

# fileNames[1] <- "/Users/jmiller/Desktop/opm-federal-employment-data/data/1973-09-to-2014-06/dod/status/Status_DoD_1973_12.txt"
#fileNames[2] <- "/Users/jmiller/Desktop/opm-federal-employment-data/data/1973-09-to-2014-06/dod/status/Status_DoD_1974_03.txt"



# print(file.names)
# k = 0
# for(i in 1:length(file.names)){
#   #print(substring(file.names[i], 16, 19))
#   uhhh <- grep(paste("1973", collapse = ""), file.names)
#   #print(uhhh)
#   #fuckDick = list()
#   if (grepl("1973", file.names[i]) == TRUE) {
#   }
# }

#year_files <- grep(paste("Status_Non_DoD_", "1973", "_[01][3692].txt", sep = ""), file.names, perl = TRUE, value = TRUE)

# for(i in 1:length(fuckDick)){
#   print(fuckDick[i])
# }
#year_files <- grepl("1973", file.names)
#print(year_files)

baptize <- function(fileName, dat_header, agency_trans_table, education_trans_table, agencyFilter, trash) {
  print('in function')
  filePath = "/Volumes/Seagate Backup Plus Drive/Data Mining/opm-federal-employment-data/data/1973-09-to-2014-06/dod/status"
  realFileName = paste(filePath,fileName, sep="")
  raw <- readLines(fileNames)

  #get numbers necessary from header file
  dat <- t(sapply(raw, FUN = function(x) trimws(substring(x, dat_header[,2], dat_header[,3]))))
  dimnames(dat) <- NULL
  dat <- as.data.frame(dat)

  #name columns
  colnames(dat) <- dat_header[,1]
  dat <- dat[grep(paste(agencyFilter, collapse = '|'), dat$Agency),]
  dat$Pay <- as.numeric(as.character(dat$Pay))
  dat$Age <- as.numeric(substring(as.character(dat$Age), 1, 2))



  startLength <- length(dat$PseudoID)

  #pull out duplicate
  n_occur <- data.frame(table(dat$PseudoID))
  dupTable <- dat[dat$PseudoID %in% n_occur$Var1[n_occur$Freq > 1],]

  #order duplicates by id, age, agency, and pay.
  #first i remove the lower age, then the lower salary if pseudoID is the same
  orderedDupTable <- dupTable[order(dupTable$PseudoID, -dupTable$Age, dupTable$Agency, dupTable$Pay),]

  gottaGo <- as.numeric(rownames(orderedDupTable[duplicated(orderedDupTable$PseudoID),]))

  dat <- dat[!(as.numeric(rownames(dat)) %in% gottaGo),]

  #pull duplicates out again
  n_occur <- data.frame(table(dat$PseudoID))
  dupTable <- dat[dat$PseudoID %in% n_occur$Var1[n_occur$Freq > 1],]
  orderedDupTable <- dupTable[order(dupTable$PseudoID, dupTable$Agency, -dupTable$Pay),]
  gottaGo <- as.numeric(rownames(orderedDupTable[duplicated(orderedDupTable$PseudoID, orderedDupTable$Agency),]))
  dat <- dat[!(as.numeric(rownames(dat)) %in% gottaGo),]

  lengthDiff <- startLength - length(dat$PseudoID)
  print(paste("Removed",toString(lengthDiff),"duplicates from",startLength,"total entries.", sep=" "))


  m <- match(dat$Education, education_trans_table$education_ID)
  dat$EducationName <-  education_trans_table$education_name[m]



  m <- match(dat$Agency, agency_trans_table$agency_ID)
  dat$AgencyName <-  agency_trans_table$agency_name[m]

  #single out all the nA's
  dat$Station <- as.numeric(as.character(dat$Station))
  dat$SupervisoryStatus <- as.numeric(as.character(dat$SupervisoryStatus))
  dat$Appointment <- as.numeric(as.character(dat$Appointment))
  dat$Schedule <- as.numeric(as.character(dat$Schedule))
  dat$Education <- as.numeric(as.character(dat$Education))
  dat$Pay <- as.numeric(as.character(dat$Pay))
  dat$Age <- replace(dat$Age, dat$Age == "UNSP",NA)
  dat$Age <- as.numeric(as.character(dat$Age))


  #for age and pa replace the NA with the median (imputation)
  dat$Age[is.na(dat$Age)] <- with(dat, ave(Age, length(dat$Age), FUN = function(x) median(x, na.rm = TRUE)))[is.na(dat$Age)]
  dat$Pay[is.na(dat$Pay)] <- with(dat, ave(Pay, length(dat$Pay), FUN = function(x) median(x, na.rm = TRUE)))[is.na(dat$Pay)]

  # dat$Fulltime <- FALSE
  # dat$Fulltime[dat$Schedule == "F" | dat$Schedule == "G"] <- TRUE
  # dat$Seasonal <- FALSE
  # dat$Seasonal[dat$Schedule %in% c("G", "J", "Q", "T")] <- TRUE

  return(dat)
  #write.csv(dat, file = "/Users/jmiller/Projects/dataMining/projectOne/rCode/gah.csv", sep = "")
  }


generalPath = "/Volumes/Seagate Backup Plus Drive/Data Mining/opm-federal-employment-data/data/"
fileNames <- paste(generalPath,"1973-09-to-2014-06/dod/status/Status_DoD_1973_09.txt", sep="")
agencyFile <- paste(generalPath,"1973-09-to-2014-06/SCTFILE.TXT", sep="")
educationFile <- paste(generalPath,"2014-09-to-2016-09/dod/translations/Education20Translation.txt", sep="")

agency_trans <- readLines(agencyFile, n=1000)
agency_ID <- sapply(agency_trans, FUN = function(x) substring(x, 3,6))
agency_name <- trimws(sapply(agency_trans, FUN = function(x) substring(x, 36,75)))
agency_trans_table <- data.frame(agency_ID = agency_ID, agency_name = agency_name)

education_trans <- readLines(educationFile)
education_ID <- sapply(education_trans, FUN = function(x) substring(x, 1,2))
education_name <- trimws(sapply(education_trans, FUN = function(x) substring(x, 29,103)))
education_trans_table <- data.frame(education_ID = education_ID, education_name = education_name)

#fuck <- sapply(fileNames, dat_header, agencyFile, educationFile, FUN = baptize())


agencyFilter <- c("AGEP", "AHEP", "AGHS", "AHHS",
                      "AGDN", "AHDN", "AGED", "AHED",
                      "AGDJ", "AHDJ", "AGDD", "AHDD",
                      "AGEM", "AHEM", "AGGS", "AHGS",
                      "AGTD", "AHTD", "AGNN", "AHNN",
                      "AGOI", "AHOI", "AGSP", "AHSP",
                      "AGTR07", "AGTR93", "AGVA", "AHVA")
agencyFilter <- lapply(agencies_to_save, FUN = function(x) substring(x, 3,6))

#path = "/Users/jmiller/Projects/dataMining/projectOne/rCode/testData"
path = "/Volumes/Seagate Backup Plus Drive/Data Mining/opm-federal-employment-data/data/1973-09-to-2014-06/non-dod/status"
cleanPath = "/Users/jmiller/Projects/dataMining/projectOne/rCode/cleanData/"
file.names <- dir(path, pattern =".txt")

trash = c("#########","UNSP","*","**","*********")

yearsIWant = c(2001:2014)

dat_header <- read.csv("/Users/jmiller/Projects/dataMining/projectOne/rCode/headers.csv", header = TRUE)

for(i in 1:length(yearsIWant)){
    filesThisYear <- grep(yearsIWant[i], file.names, value = TRUE)
    combinedData <- do.call(rbind, lapply(filesThisYear, dat_header, agency_trans_table, education_trans_table,agencyFilter, FUN = baptize))
    print(paste("writing file for ",yearsIWant[i], sep=""))
    write.csv(combinedData, file = paste(cleanPath, yearsIWant[i], "_PURE.csv", sep = ""))
}
#
#
# fuck <- baptize(fileNames, dat_header, agency_trans_table, education_trans_table, agencies_to_save, trash)
# print("writing file now")
# write.csv(fuck, file = paste(cleanPath, "TEST_PURE.csv", sep = ""))
