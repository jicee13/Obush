

baptize <- function(fileName, dat_header, agency_trans_table, education_trans_table, agencyFilter, trash, nsftp_trans_table, payPlan_trans_table, supervisor_trans_table, schdule_trans_table, state_trans_table, appt_trans_table, occ_trans_table) {
  print('in function')
  filePath = "/Volumes/Seagate\ Backup\ Plus\ Drive/Data\ Mining/opm-federal-employment-data/data/1973-09-to-2014-06/non-dod/status/"
  #filePath = "https://archive.org/download/opm-federal-employment-data/data/1973-09-to-2014-06/dod/status/"
  print(fileName)
  realFileName = paste(filePath,fileName, sep="")
  raw <- readLines(realFileName)

  #get numbers necessary from header file
  dat <- t(sapply(raw, FUN = function(x) trimws(substring(x, dat_header[,2], dat_header[,3]))))
  dimnames(dat) <- NULL
  dat <- as.data.frame(dat)

  #name columns
  colnames(dat) <- dat_header[,1]
  #dat <- dat[grep(paste(agencyFilter, collapse = '|'), dat$Agency),]
  dat$Pay <- as.numeric(as.character(dat$Pay))
  dat$Age <- as.numeric(substring(as.character(dat$Age), 1, 2))



  startLength <- length(dat$PseudoID)

  #pull out duplicates
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

  # Calculate # of duplicates removed
  lengthDiff <- startLength - length(dat$PseudoID)
  print(paste("Removed",toString(lengthDiff),"duplicates from",startLength,"total entries.", sep=" "))

  # Create new columns for all parsed names mapped to variables
  m <- match(dat$Education, education_trans_table$education_ID)
  dat$EducationName <-  education_trans_table$education_name[m]

  m <- match(dat$Agency, agency_trans_table$agency_ID)
  dat$AgencyName <-  agency_trans_table$agency_name[m]

  m <- match(dat$NSFTP, nsftp_trans_table$nsftp_ID)
  dat$NSFTPTrans <-  nsftp_trans_table$nsftp_name[m]

  m <- match(dat$PayPlan, payPlan_trans_table$payPlan_ID)
  dat$PayPlanTrans <-  payPlan_trans_table$payPlan_name[m]

  m <- match(dat$SupervisoryStatus, supervisor_trans_table$supervisor_ID)
  dat$PayPlanTrans <-  supervisor_trans_table$supervisor_name[m]

  m <- match(dat$Schedule, schdule_trans_table$schedule_ID)
  dat$ScheduleTrans <-  schdule_trans_table$schedule_name[m]

  m <- match(dat$Station, state_trans_table$state_ID)
  dat$States <-  state_trans_table$state_name[m]

  m <- match(dat$Appointment, appt_trans_table$appt_ID)
  dat$ApptTrans <-  appt_trans_table$appt_name[m]

  m <- match(dat$Occupation, occ_trans_table$occ_ID)
  dat$OccTrans <-  occ_trans_table$occ_name[m]

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

  return(dat)
  }


generalPath = "/Volumes/Seagate Backup Plus Drive/Data Mining/opm-federal-employment-data/data/"



fileNames <- paste(generalPath,"1973-09-to-2014-06/dod/status/Status_DoD_1973_09.txt", sep="")
agencyFile <- paste(generalPath,"1973-09-to-2014-06/SCTFILE.TXT", sep="")
educationFile <- paste(generalPath,"2014-09-to-2016-09/dod/translations/Education20Translation.txt", sep="")

# Translate all .txt files containing mapping to the decoding of variables
agency_trans <- readLines(agencyFile, n=1000)
agency_ID <- sapply(agency_trans, FUN = function(x) substring(x, 3,6))
agency_name <- trimws(sapply(agency_trans, FUN = function(x) substring(x, 36,75)))
agency_trans_table <- data.frame(agency_ID = agency_ID, agency_name = agency_name)

education_trans <- readLines(educationFile)
education_ID <- sapply(education_trans, FUN = function(x) substring(x, 1,2))
education_name <- trimws(sapply(education_trans, FUN = function(x) substring(x, 29,103)))
education_trans_table <- data.frame(education_ID = education_ID, education_name = education_name)

nsftp_trans <- readLines('/Volumes/Seagate Backup Plus Drive/Data Mining/opm-federal-employment-data/data/2014-09-to-2016-09/non-dod/translations/NSFTP%20Translation.txt')
nsftp_ID <- sapply(nsftp_trans, FUN = function(x) substring(x, 1,1))
nsftp_name <- trimws(sapply(nsftp_trans, FUN = function(x) substring(x, 20,103)))
nsftp_trans_table <- data.frame(nsftp_ID = nsftp_ID, nsftp_name = nsftp_name)

payPlan_trans <- readLines('/Volumes/Seagate Backup Plus Drive/Data Mining/opm-federal-employment-data/data/2014-09-to-2016-09/non-dod/translations/Pay%20Plan%20Translation.txt')
payPlan_ID <- sapply(payPlan_trans, FUN = function(x) substring(x, 1,2))
payPlan_name <- trimws(sapply(payPlan_trans, FUN = function(x) substring(x, 26,90)))
payPlan_trans_table <- data.frame(payPlan_ID = payPlan_ID, payPlan_name = payPlan_name)

supervisor_trans <- readLines('/Volumes/Seagate Backup Plus Drive/Data Mining/opm-federal-employment-data/data/2014-09-to-2016-09/non-dod/translations/Supervisory%20Status%20Translation.txt')
supervisor_ID <- sapply(supervisor_trans, FUN = function(x) substring(x, 1,1))
supervisor_name <- trimws(sapply(supervisor_trans, FUN = function(x) substring(x, 26,90)))
supervisor_trans_table <- data.frame(supervisor_ID = supervisor_ID, supervisor_name = supervisor_name)

schedule_trans <- readLines('/Volumes/Seagate Backup Plus Drive/Data Mining/opm-federal-employment-data/data/2014-09-to-2016-09/non-dod/translations/Work%20Schedule%20Translation.txt')
schedule_ID <- sapply(schedule_trans, FUN = function(x) substring(x, 1,1))
schedule_name <- trimws(sapply(schedule_trans, FUN = function(x) substring(x, 28,90)))
schdule_trans_table <- data.frame(schedule_ID = schedule_ID, schedule_name = schedule_name)

state_trans <- readLines('/Volumes/Seagate Backup Plus Drive/Data Mining/opm-federal-employment-data/data/2014-09-to-2016-09/non-dod/translations/State%20Translations.txt')
state_ID <- sapply(state_trans, FUN = function(x) substring(x, 1,2))
state_name <- trimws(sapply(state_trans, FUN = function(x) substring(x, 35,90)))
state_trans_table <- data.frame(state_ID = state_ID, state_name = state_name)

appt_trans <- readLines('/Volumes/Seagate Backup Plus Drive/Data Mining/opm-federal-employment-data/data/2014-09-to-2016-09/non-dod/translations/TOA%20Translation.txt')
appt_ID <- sapply(appt_trans, FUN = function(x) substring(x, 1,2))
appt_name <- trimws(sapply(appt_trans, FUN = function(x) substring(x, 28,90)))
appt_trans_table <- data.frame(appt_ID = appt_ID, appt_name = appt_name)

occ_trans <- readLines('/Volumes/Seagate Backup Plus Drive/Data Mining/opm-federal-employment-data/data/2014-09-to-2016-09/non-dod/translations/occupationTranslations.txt')
occ_ID <- sapply(occ_trans, FUN = function(x) substring(x, 1,2))
occ_name <- trimws(sapply(occ_trans, FUN = function(x) substring(x, 5,70)))
occ_trans_table <- data.frame(occ_ID = occ_ID, occ_name = occ_name)


# Only record data on these agencies
agencyFilter <- c("AGEP", "AHEP", "AGHS", "AHHS",
                      "AGDN", "AHDN", "AGED", "AHED",
                      "AGDJ", "AHDJ", "AGDD", "AHDD",
                      "AGEM", "AHEM", "AGGS", "AHGS",
                      "AGTD", "AHTD", "AGNN", "AHNN",
                      "AGOI", "AHOI", "AGSP", "AHSP",
                      "AGTR07", "AGTR93", "AGVA", "AHVA")
agencyFilter <- lapply(agencyFilter, FUN = function(x) substring(x, 3,6))

path = "/Volumes/Seagate Backup Plus Drive/Data Mining/opm-federal-employment-data/data/1973-09-to-2014-06/non-dod/status"
cleanPath = "/Users/jmiller/Projects/dataMining/projectOne/rCode/newCleanData/"
file.names <- dir(path, pattern =".txt")


# Strings to be replaced
trash = c("#########","UNSP","*","**","*********")

yearsIWant = c(2005:2012)

dat_header <- read.csv("/Users/jmiller/Projects/dataMining/projectOne/rCode/headers.csv", header = TRUE)

for(i in 1:length(yearsIWant)){
  filesThisYear <- grep(yearsIWant[i], file.names, value = TRUE)
  for(j in 1:length(filesThisYear)){
    # For every year I specify, pass file name to function and write clean data to CSV
    print(paste("starting ",filesThisYear[j], sep=""))
    dataToWrite <- baptize(filesThisYear[j], dat_header, agency_trans_table, education_trans_table, agencyFilter, trash, nsftp_trans_table,payPlan_trans_table, supervisor_trans_table, schdule_trans_table, state_trans_table, appt_trans_table, occ_trans_table)
    print(paste("writing file for ",filesThisYear[j], sep=""))
    write.csv(dataToWrite, file = paste(cleanPath, filesThisYear[j], "_PURE.csv", sep = ""))
  }
}
