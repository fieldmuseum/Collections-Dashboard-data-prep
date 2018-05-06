## EMu Data Prep Script -- Collections Dashboard
# Final prep & export of full dashboard dataset

print(paste(date(), "-- ...finished setting up Ecoregion data.  Starting final prep - dash030FullExport.R"))

# point to csv's directory
setwd(paste0(origdir,"/supplementary"))


# Merge Department column
Depts <- read.csv(file="Departments.csv", stringsAsFactors = F)
#FullDash8csv$DarCollectionCode <- sapply(FullDash8csv$DarCollectionCode, function(x) simpleCap(x))
FullDash8csv <- merge(FullDash8, Depts, by=c("DarCollectionCode"), all.x=T)
rm(Depts)


# Merge DarIndividualCount to count # catalogged items in results
DarIndivCount <- CatDash3[,c("DarGlobalUniqueIdentifier", "DarIndividualCount")]
FullDash8csv <- merge(FullDash8csv, DarIndivCount, by=c("DarGlobalUniqueIdentifier"), all.x=T)
FullDash8csv$DarIndividualCount[which(FullDash8csv$RecordType=="Catalog" & is.na(FullDash8csv$DarIndividualCount)==T)] <- 1
FullDash8csv$DarIndividualCount[which(FullDash8csv$RecordType=="Accession")] <- 0
rm(DarIndivCount)


# Setup final data frame for export
FullDash9csv <- FullDash8csv[,c("DarGlobalUniqueIdentifier","DarLatitude","DarLongitude","Where",
                                "Quality","RecordType","Backlog","TaxIDRank",
                                "What","DarCollectionCode", "HasMM", "URL",
                                "WhenAge", "WhenAgeFrom", "WhenAgeTo","DarYearCollected",
                                "WhenOrder", "WhenTimeLabel", "WhenAgeMid",
                                "Department", "DarIndividualCount", "Who",
                                "DarInstitutionCode", "Bioregion"
                                )]

FullDash9csv$DarYearCollected <- as.numeric(FullDash9csv$DarYearCollected)


# Last Check/Clean ####
# Should be consolidated in separate cleaning-script/functions
FullDash9csv$What <- gsub("\\|\\s+NA\\s+\\||\\|\\s+NANA\\s+\\|", "|", FullDash9csv$What, ignore.case = T)
FullDash9csv$What <- gsub("NANA", "", FullDash9csv$What, ignore.case = F)
FullDash9csv$What <- gsub("^NA\\s+|\\s+NA$|^NANA\\s+|\\s+NANA$|\\s+\\|\\s+$", "", FullDash9csv$What, ignore.case = T)
FullDash9csv$What <- gsub("\\|\\s+NA\\s+|\\s+NA\\s+\\|", "", FullDash9csv$What, ignore.case = T)
FullDash9csv$What <- gsub("(\\|\\s+)+", "| ", FullDash9csv$What, ignore.case = T)
FullDash9csv$What <- gsub("(\\s+\\|)+", " |", FullDash9csv$What, ignore.case = T)
FullDash9csv$Where <- gsub("(\\|\\s+)+", "| ", FullDash9csv$Where, ignore.case = T)
FullDash9csv$Where <- gsub("(\\s+\\|)+", " |", FullDash9csv$Where, ignore.case = T)
FullDash9csv$Where <- gsub(" Usa ", " U.S.A. ", FullDash9csv$Where, ignore.case = T)
FullDash9csv$What <- gsub("\\| and \\|", "", FullDash9csv$What, ignore.case = T)
FullDash9csv$Who <- gsub("^ $|^NA$", "", FullDash9csv$Who, ignore.case = T)
FullDash9csv$Who <- gsub("^NA\\s+\\|\\s+", "", FullDash9csv$Who, ignore.case = F)
FullDash9csv$Who <- gsub("\\s+\\|\\s+NA$|\\s+\\|\\s+NA\\s+|^\\s+\\|\\s+|\\s+\\|\\s+$", "", FullDash9csv$Who, ignore.case = F)
FullDash9csv$WhenAge <- gsub("^NA$", "", FullDash9csv$WhenAge, ignore.case = F)

FullDash9csv[,c("What","WhenAge", "Where", "Who", "Bioregion")] <- sapply(FullDash9csv[,c("What","WhenAge", "Where", "Who", "Bioregion")],
                                                                          function (x) gsub("^\\s*(\\|\\s*)*|(\\s*\\|)*\\s*$", "", x))

FullDash9csv$WhenAge[which(is.na(FullDash9csv$WhenAge)==T)] <- ""
FullDash9csv$Who[which(is.na(FullDash9csv$Who)==T)] <- ""
FullDash9csv$Where[which(is.na(FullDash9csv$Where)==T)] <- ""

print(paste(date(), "-- ...finished full-data prep; starting sample-data prep."))


# Prep sample dataset ####

FullDashSample1 <- FullDash9csv[which(((FullDash9csv$DarGlobalUniqueIdentifier %in% SampleGroupC) & FullDash9csv$RecordType=="Catalog") |
                                       ((FullDash9csv$DarGlobalUniqueIdentifier %in% SampleGroupA) & FullDash9csv$RecordType=="Accession")),]

# Scrub out irn's and other identifiers
ScrubCat <- data.frame("DarGlobalUniqueIdentifier" = CatDash03Samp1[,c("DarGlobalUniqueIdentifier")], stringsAsFactors = F)
ScrubCat$irnScrub <- seq(12345,by=1,length.out = NROW(ScrubCat))
ScrubCat$GUIDScrub <- seq(1234,by=1,length.out = NROW(ScrubCat))
ScrubCat$GUIDScrub <- paste0("a",ScrubCat$irnScrub,"bc-1234-5a67-a123-a1bc23de", ScrubCat$GUIDScrub)

ScrubAcc <- data.frame("DarGlobalUniqueIdentifier" = AccBacklogSamp1[,c("DarGlobalUniqueIdentifier")], stringsAsFactors = F)
ScrubAcc$irnScrub <- seq(54321,by=1,length.out = NROW(ScrubAcc))
ScrubAcc$GUIDScrub <- seq(1234,by=1,length.out = NROW(ScrubAcc))
ScrubAcc$GUIDScrub <- paste0("a",ScrubAcc$irnScrub,"bc-1234-5a67-a123-a1bc23de", ScrubAcc$GUIDScrub)

ScrubFull <- rbind(ScrubCat[,c("DarGlobalUniqueIdentifier","GUIDScrub","irnScrub")], 
                   ScrubAcc[,c("DarGlobalUniqueIdentifier","GUIDScrub","irnScrub")])

# merge
AccBacklogSamp <- merge(AccBacklogSamp1, ScrubAcc, by="DarGlobalUniqueIdentifier", all.x=T)
CatDash03Samp <- merge(CatDash03Samp1, ScrubCat, by="DarGlobalUniqueIdentifier", all.x=T)
# # FIX THIS
FullDashSample <- merge(FullDashSample1, ScrubFull, by="DarGlobalUniqueIdentifier", all.x=T)

# scrub id #s
AccBacklogSamp$DarGlobalUniqueIdentifier <- AccBacklogSamp$GUIDScrub
AccBacklogSamp$irn <- AccBacklogSamp$irnScrub
AccBacklogSamp <- select(AccBacklogSamp, -c(irnScrub, GUIDScrub))
AccBacklogSamp$AccAccessionDescription <- gsub("[[:digit:]]","5", AccBacklogSamp$AccAccessionDescription)
AccBacklogSamp$AccCatalogueNo <- gsub("[[:digit:]]", "5", AccBacklogSamp$AccCatalogueNo)
AccBacklogSamp$AccDescription <- gsub("[[:digit:]]", "5", AccBacklogSamp$AccDescription)

CatDash03Samp$DarGlobalUniqueIdentifier <- CatDash03Samp$GUIDScrub
CatDash03Samp$irn <- CatDash03Samp$irnScrub
CatDash03Samp <- select(CatDash03Samp, -c(irnScrub, GUIDScrub))
CatDash03Samp$DarCatalogNumber <- gsub("[[:digit:]]","5", CatDash03Samp$DarCatalogNumber)
CatDash03Samp$DarImageURL <- gsub("[[:digit:]]","5", CatDash03Samp$DarImageURL)
CatDash03Samp$DarLatitude <- as.integer(CatDash03Samp$DarLatitude)
CatDash03Samp$DarLongitude <- as.integer(CatDash03Samp$DarLongitude)

# Need to fix this
FullDashSample$DarGlobalUniqueIdentifier <- FullDashSample$GUIDScrub
FullDashSample <- select(FullDashSample, -GUIDScrub)
FullDashSample$DarLatitude <- as.integer(FullDashSample$DarLatitude)
FullDashSample$DarLongitude <- as.integer(FullDashSample$DarLongitude)


print(paste(date(), "-- ...finished sample-data prep; starting export of final dataset & LUTs."))


# Export full dataset CSV ####
setwd(paste0(origdir,"/output"))

# # TEMP FIX # # # #
# FullDash9csv$DarInstitutionCode[which(is.na(FullDash9csv$DarInstitutionCode)==T)] <- "FMNH" 
# FullDash9csv$DarInstitutionCode[which(FullDash9csv$DarInstitutionCode=="FALSE" | FullDash9csv$DarInstitutionCode=="F")] <- "FMNH"

# Check for duplicates
FullDash9csv <- unique(FullDash9csv)
FullD9_check1 <- dplyr::count(FullDash9csv, DarGlobalUniqueIdentifier)
FullD9_check2 <- FullD9_check1[which(FullD9_check1$n>1),]

if (NROW(FullDash9csv)>0 & NROW(FullD9_check2)==0) {
  write.csv(FullDash9csv, file = "FullDash13.csv", na="", row.names = FALSE)
} else {
  print("Error - Check for duplicate records; FullDash13.csv not exported")
}


# # Dump test dataset for Cultural Collections Dashboard
# # - TO DO: 
# #       - cut rbind with Accessions when those are absent?
# #       - also cut DwC dataset imports when absent?
# 
# FullDash10test <- FullDash9csv[which(FullDash9csv$RecordType=="Catalog" & FullDash9csv$DarCollectionCode=="Anthropology"),]
# write.csv(FullDash10test, file = "FullDash13_10test.csv", na="", row.names = FALSE)


# Export sample dataset CSV ####
if (dir.exists(paste0(origdir,"/outputSample"))==F) {
  setwd(origdir)
  dir.create("./outputSample", showWarnings = T)
  print("'outputSample' directory created.")
}

setwd(paste0(origdir,"/outputSample"))

write.csv(AccBacklogSamp, file = "SampleInput_AccBacklogBU.csv", na="", row.names = FALSE)
write.csv(CatDash03Samp, file = "SampleInput_CatDash03bu.csv", na="", row.names = FALSE)
write.csv(FullDashSample, file = "FullDash_Sample.csv", na="", row.names = FALSE)


#  Who-Staff LUTs ####
setwd(paste0(origdir,"/data01raw"))

Who <- read.csv(file="DirectorsCutWho.csv", stringsAsFactors = F)

Who2 <- gather(Who, "Staff", "count", 2:4)

Who2$Staff <- gsub("\\.1", "", Who2$Staff)
Who2$count <- as.integer(Who2$count)

Who2 <- Who2[order(Who2$Collections),]

setwd(paste0(origdir,"/output"))
write.csv(Who2, file="WhoDash.csv", na = "0", row.names = F)


# Institutional summary output (for Experience, Loans, & Visitor data)
write.csv(Exper2, "WhoExperience.csv", row.names = F)
write.csv(LoanSumCount, "LoanSumCount.csv", row.names = F)
write.csv(VisitSumCount, "VisitSumCount.csv", row.names = F)


# write cleaned lookup tables ####
write.csv(WhereLUTall, file="WhereLUT.csv", row.names=F)
write.csv(WhatLUTB, file="WhatLUTB.csv", row.names=F)
write.csv(WhenAgeLUT, file="WhenAgeLUT.csv", row.names = F)
write.csv(WhoLUT, file="WhoLUT.csv", row.names = F)


# write datasets to check ####
if (dir.exists(paste0(origdir,"/data03check"))==F) {
  setwd(origdir)
  dir.create("./data03check", showWarnings = T)
  print("'data03check' directory created.")
}

setwd(paste0(origdir,"/data03check"))
write.csv(WhenAgeLUTcheck, "WhenAgeLUTcheck.csv", row.names=F)

# write summary stats
write.csv(QualityFull, file="QualityStatsFull.csv", row.names=F)
write.csv(QualityCatDar, file="QualityStatsCatDar.csv", row.names=F)

Log030FullExport <- warnings()

setwd(origdir)

print(paste(date(), "-- Finished exporting full dataset for dashboard."))
