## collections-dashboard-prep
#
# Import Visitor data from EMu - Consultations (efmnhrepatriation)
#
# 1) In EMu, retrieve Consultation records for dashboard, 
#       05-May-2017 dataset includes all efmnhrepatriation records where:
#           InfRecordType = \"Research Visit\"
#
# 2) Report them out with "VisitorDays" report
##       - see collections-dashboard "Help" page for details on which fields are included in report
##       - If under 200k records, report all at one time.
##       - Don't rename reported files. Keep them together in one folder.
#
# 3) Run this script  
#       - NOTE: May need to re-set working directory to folder containing reported csv's
#         (see lines 21 & 22)

print(paste(date(), "-- ...finished setting up Loan data.  Starting dash027VisitPrep.R"))


# point to the directory containing the set of "Group" csv's from EMu
setwd(paste0(origdir,"/data01raw/emuConsult"))


# Import raw EMu Accession data ####
Visits1 <- read.csv(file="efmnhrep.csv", stringsAsFactors = F)
VisParties <- read.csv(file="ResResea.csv", stringsAsFactors = F)
VisDepts <- read.csv(file="SecDepar.csv", stringsAsFactors = F)

# Count Number of attached parties
VisParties <- VisParties[,-1]
VisPartiesCount <- dplyr::count(VisParties, efmnhrepatriation_key)
colnames(VisPartiesCount)[2] <- "PartiesCount"

# Prep/Spread department table
VisDepts$SecDepar_ROW <- sequence(rle(as.character(VisDepts$efmnhrepatriation_key))$lengths)
VisDepts <- VisDepts[,-1]
VisDepts <- tidyr::spread(VisDepts, SecDepar_ROW, SecDepartment, sep="_")
VisDepts <- unite(VisDepts, SecDepar, SecDepar_ROW_1:SecDepar_ROW_3, sep=" | ")

# Map departments
VisDepts$DarCollectionCode <- ""

VisDepts$DarCollectionCode[which(grepl("Anthropology", VisDepts$SecDepar)>0)] <- "Anthropology"

VisDepts$DarCollectionCode[which(grepl("Botany", VisDepts$SecDepar)>0)] <- "Botany"

VisDepts$DarCollectionCode[which(grepl("Geology", VisDepts$SecDepar)>0)] <- "Geology"
VisDepts$DarCollectionCode[which(grepl("Fossil Vertebrates", VisDepts$SecDepar)>0)] <- "Fossil Vertebrates"
VisDepts$DarCollectionCode[which(grepl("Fossil Invertebrates", VisDepts$SecDepar)>0)] <- "Fossil Invertebrates"
VisDepts$DarCollectionCode[which(grepl("Paleobotany", VisDepts$SecDepar)>0)] <- "Paleobotany"

VisDepts$DarCollectionCode[which(grepl("Amphibians", VisDepts$SecDepar)>0)] <- "Amphibians and Reptiles"
VisDepts$DarCollectionCode[which(grepl("Birds", VisDepts$SecDepar)>0)] <- "Birds"
VisDepts$DarCollectionCode[which(grepl("Fishes", VisDepts$SecDepar)>0)] <- "Fishes"
VisDepts$DarCollectionCode[which(grepl("Mammals", VisDepts$SecDepar)>0)] <- "Mammals"
VisDepts$DarCollectionCode[which(grepl("Insects", VisDepts$SecDepar)>0)] <- "Insects"
VisDepts$DarCollectionCode[which(grepl("Invertebrate Zoology", VisDepts$SecDepar)>0)] <- "Invertebrate Zoology"

# Filter out non-S&E-hosted visits [also -- Check that all collections are included above]
VisDepts <- VisDepts[which(nchar(VisDepts$DarCollectionCode)>0),]


# Merge tables
Visits2 <- merge(Visits1, VisPartiesCount, by="efmnhrepatriation_key", all.x=T)
Visits3 <- merge(Visits2, VisDepts, by="efmnhrepatriation_key", all.x=T)

# Merge Visitor numbers
Visits3$VisitorCount <- rowSums(Visits3[,c("ResNoOfVisitors","PartiesCount")], na.rm=T)
Visits3$VisitorCount[which(Visits3$VisitorCount<1)] <- 1

# Determine # of days in visit
Visits3$DateStart <- as.Date(Visits3$ResCommencementDate)
Visits3$DateEnd <- as.Date(Visits3$ResCompletionDate)
Visits3$VisitDayCount <- (Visits3$DateEnd+1) - Visits3$DateStart

# Determine visits as # visitors per day
Visits3$VisitsPerDay <- as.numeric(Visits3$VisitorCount * Visits3$VisitDayCount)


# Count Visits per day per collection per year
Visits3$DateStartYear <- substr(Visits3$ResCommencementDate,1,4)
Visits4 <- Visits3[which(Visits3$DateStartYear>2000 & nchar(Visits3$DateStartYear)>0
                         & is.na(Visits3$DarCollectionCode)==F
                         & Visits3$VisitsPerDay>0),]

Visits4count <- dplyr::count(Visits4, DateStartYear, DarCollectionCode)


# Sum visits
Visits4sum <- aggregate(Visits4$VisitsPerDay, list(Visits4$DateStartYear, Visits4$DarCollectionCode), sum)


Visits4sum <- LoanSum[which(LoanSum$x>0),]
Visits4count <- LoanCount[which(LoanCount$n>0 & is.na(LoanCount$n)==F),]

colnames(Visits4sum) = c("VisitYear","DarCollectionCode","SumVisits")
colnames(Visits4count) = c("VisitYear","DarCollectionCode","CountVisits")

# This can be exported for full count & sum dataset
VisitSumCount <- merge(Visits4sum, Visits4count, by=c("VisitYear","DarCollectionCode"),all=T)


setwd(origdir)
