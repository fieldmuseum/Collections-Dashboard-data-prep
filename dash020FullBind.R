## EMu Data Prep Script -- Collections Dashboard
# Merge Accession & Catalogue data from EMu

print(paste(date(), "-- ...finished importing Cat & Acc data.  Starting dash020FullBind.R"))


# Import GBIF Catalog data ####
if (exists("DWC2")==TRUE) {
  DWC3 <- DWC2
  rm(DWC2)
}


# Import raw EMu data ####

# point to csv's directory
setwd(paste0(origdir,"/data01raw"))

if (exists("CatDash03")==TRUE) {
  CatDash2 <- CatDash03
} else {
  CatDash2 <- read.csv(file="CatDash03bu.csv", stringsAsFactors = F, na.strings = "", encoding="latin1")
}

# Fix DarInstitutionCode for FMNH Collections # TEMP FIX # # # #
CatDash2$DarInstitutionCode[which(is.na(CatDash2$DarInstitutionCode)==T)] <- "FMNH" 
CatDash2$DarInstitutionCode[which(CatDash2$DarInstitutionCode=="FALSE" | CatDash2$DarInstitutionCode=="F")] <- "FMNH"

CatDash2 <- unique(CatDash2)
#check <- dplyr::count(CatDash3, irn)


# Setup sample raw Catalogue data
CatDash03Samp1 <- rbind(
  CatDash2[(CatDash2$DarInstitutionCode=="PM"),][c(3:6,200:205),], # 8005:8010,99905:9990
  CatDash2[(CatDash2$DarInstitutionCode=="PM" & CatDash2$WhenAgeFrom>0),][c(5:9),],
  CatDash2[(CatDash2$DarInstitutionCode=="OI"),][c(3:6,200:205),],
  CatDash2[(CatDash2$DarInstitutionCode=="OI" & CatDash2$WhenAgeFrom>0),][c(5:9),],
  CatDash2[(CatDash2$DarInstitutionCode=="FMNH" & CatDash2$RecordType=="Catalog"),][c(305:312),],
  CatDash2[(CatDash2$DarInstitutionCode=="FMNH" & CatDash2$DarCollectionCode=="Anthropology"),][c(130:134),],
  CatDash2[(CatDash2$DarInstitutionCode=="FMNH" & CatDash2$DarCollectionCode=="Anthropology" & CatDash2$WhenAgeFrom>0),][c(10:14),]
)
SampleGroupC <- CatDash03Samp1$DarGlobalUniqueIdentifier


# Bind GBIF and EMu Catalog data + GBIF-backlog data if present ####

library("plyr")

if (exists("DWC2_Back")==T) {
  
  # Combine Accession + Catalogue datasets
  # CatDash3 <- plyr::rbind.fill(CatDash2, DWC3, DWC2_Back) # typo?
  CatDash3 <- plyr::rbind.fill(CatDash2, DWC2_Back)
  
} else if (exists("DwC3")==T) {

  CatDash3 <- rbind(CatDash2, DWC3)

} else {
  
  CatDash3 <- CatDash2

  }

# Fix for OI & PM ####
CatDash3$MulHasMultiMedia <- gsub("Y","1",CatDash3$MulHasMultiMedia)
CatDash3$MulHasMultiMedia[which(nchar(CatDash3$DarImageURL)>1)] <- "1"
CatDash3$MulHasMultiMedia <- gsub("N","0",CatDash3$MulHasMultiMedia)
CatDash3$MulHasMultiMedia[which(is.na(CatDash3$MulHasMultiMedia)==T)] <- "0"
# CatDash3$DarImageURL <- as.integer(CatDash3$MulHasMultiMedia)  # need this?


# Add/Adjust columns for Quality calculation
CatDash3$DarIndividualCount <- as.numeric(CatDash3$DarIndividualCount)  # NA's from coercion are ok here

# Is this right?
if (is.character(CatDash3$RecordType)==F) {
  CatDash3$RecordType <- "Catalog"
  # CatDash3$RecordType[which(is.na(CatDash3$RecordType)==T)] <- "Catalog"
} else {
  CatDash3$RecordType[which(is.na(CatDash3$RecordType)==T)] <- "Catalog"
}

species <- c("Species","Subspecies","Variety","Subvariety","Form","Subform","Proles","Aberration")
genus <- c("Genus","Subgenus","Section","Subsection")
family <- c("Family","Subfamily","Tribe","Subtribe")
order <- c("Order","Suborder","Infraorder","Superfamily")
class <- c("Class","Subclass","Superorder")
phylum <- c("Phylum","Subphylum","Division")

CatDash3$ClaRank <- sapply(CatDash3$ClaRank, simpleCap)

CatDash3$TaxIDRank <- ""
CatDash3$TaxIDRank[which(CatDash3$ClaRank %in% species)] <- "Species"
CatDash3$TaxIDRank[which(CatDash3$ClaRank %in% genus)] <- "Genus"
CatDash3$TaxIDRank[which(CatDash3$ClaRank %in% family)] <- "Family"
CatDash3$TaxIDRank[which(CatDash3$ClaRank %in% order)] <- "Order"
CatDash3$TaxIDRank[which(CatDash3$ClaRank %in% class)] <- "Class"
CatDash3$TaxIDRank[which(CatDash3$ClaRank %in% phylum)] <- "Phylum"
CatDash3$TaxIDRank[which(CatDash3$ClaRank == "Kingdom")] <- "Kingdom"



# Import Accession data ####

if (exists("AccBL3")==TRUE) {
  AccDash1 <- AccBL3
} else {
  AccDash1 <- read.csv(file="AccBacklogBU.csv", stringsAsFactors = F, na.strings = "", encoding="latin1")
}


# # # # # DarInstitutionCode
# NOTE ####
# - This is temporary; appropriate field should be part of imported dataset
AccDash1$DarInstitutionCode <- "FMNH"


# Setup Sample Raw Accession data
SampleGroupA <- c(10576,44071,38855,46333,47764,31971,26200,20714,29028,26226,24962,20453,36113,11339)
AccBacklogSamp1 <- AccDash1[which(AccDash1$irn %in% SampleGroupA),]
AccBacklogSamp1$DarGlobalUniqueIdentifier <-  paste(AccBacklogSamp1$DarInstitutionCode,
                                                    "accession-irn",
                                                    AccBacklogSamp1$irn,
                                                    sep="-")
SampleGroupA <- AccBacklogSamp1$DarGlobalUniqueIdentifier


# Map Acc fields to Cat fields
AccDash2 <- data.frame("irn" = AccDash1$irn,
                       "DarGlobalUniqueIdentifier" = paste(AccDash1$DarInstitutionCode,
                                                           "accession-irn",
                                                           AccDash1$irn,
                                                           sep="-"),
                       # ADD AdmDateInserted + Modified
                       "DarImageURL" = "",
                       "DarCountry" = AccDash1$LocCountry_tab,
                       "DarContinent" = AccDash1$LocContinent_tab,
                       "DarWaterBody" = AccDash1$LocOcean_tab,
                       "DarCollectionCode" = AccDash1$AccCatalogue,
                       # "DesKDescription0" = paste(AccDash1$AccAccessionDescription,"|",AccDash1$AccDescription),
                       "AccDescription" = AccDash1$AccDescription,
                       "AccDescription2" = AccDash1$AccAccessionDescription,
                       "DarIndividualCount"= as.numeric(AccDash1$CatTotal),
                       # "AccTotalObjects"= AccDash1$AccTotalObjects,
                       # "AccTotBothItOb"= as.integer(0),
                       # "AccTotalObjects" = AccDash1$AccTotalObjects,
                       "AccLocality" = AccDash1$AccLocality,
                       "AccGeography" = AccDash1$AccGeography,
                       "AccCatalogueNo" = AccDash1$AccCatalogueNo,
                       "MulHasMultiMedia" = "0",
                       "RecordType" = "Accession",
                       "AccTotal" = AccDash1$AccTotal,
                       "Backlog" = AccDash1$backlog,
                       "DarInstitutionCode" = AccDash1$DarInstitutionCode,  # "FMNH",
                       stringsAsFactors=F)

AccDash2$DarIndividualCount <- as.numeric(AccDash2$DarIndividualCount)

print(paste("... ", substr(date(), 12, 19), "- binding catalogue & accession records..."))

# bind catalog and backlog records
FullDash <- plyr::rbind.fill(CatDash3, AccDash2)

print(paste("... ",substr(date(), 12, 19), "- cleaning up full data table..."))

# cleanup import
FullDash1 <- unique(FullDash)

# check duplicate GUIDs [first instance is kept; subsequent are removed]] ####
# keep first instance:
FullGUIDcount <- dplyr::count(FullDash1, DarGlobalUniqueIdentifier)

FullDash1 <- FullDash1[order(FullDash1$DarGlobalUniqueIdentifier, FullDash1$DarCatalogNumber),]
FullDash1$GUIDseq <- sequence(rle(as.character(FullDash1$DarGlobalUniqueIdentifier))$lengths)

FullDash2 <- FullDash1[which(FullDash1$GUIDseq == 1),]
FullDash2 <- dplyr::select(FullDash2, -GUIDseq)

# remove subsequent duplicate GUIDs ####
FullCheck <- dplyr::count(FullDash1, DarGlobalUniqueIdentifier)
FullCheckGUID <- FullCheck[FullCheck$n>1,]
FullCheckAll <- FullDash1[which(FullDash1$DarGlobalUniqueIdentifier %in% FullCheckGUID$DarGlobalUniqueIdentifier),]

if(NROW(FullCheckGUID)>0) {
  print(paste("Check 'GUIDcheck' CSVs for: ",
              NROW(FullCheckGUID), "duplicate GUIDs in ",
              NROW(FullCheckAll), "records"))
  setwd(paste0(origdir,"/data03check"))
  write.csv(FullCheckAll,"GUIDcheck_dash020.csv", row.names = F, na="")
} else {
    print(paste("No duplicate GUIDs; all clear!"))  # if only...
  }

# FullDash2alt <- FullDash1[!(FullDash1$DarGlobalUniqueIdentifier %in% FullCheckGUID$DarGlobalUniqueIdentifier),] # if need to exclude all duplicates


# Qualilty - rank records ####
FullDash2$Quality <- 1
FullDash2$Quality[which(FullDash2$RecordType=="Accession" & FullDash2$AccTotal>0)] <- 2
FullDash2$Quality[which(FullDash2$RecordType=="Accession" & FullDash2$Quality==2 & (is.na(FullDash2$AccLocality) + is.na(FullDash2$AccGeography) < 2))] <- 3
FullDash2$Quality[which(FullDash2$RecordType=="Accession" & FullDash2$Quality==3 & is.na(FullDash2$AccCatalogueNo)==FALSE)] <- 4
FullDash2$Quality[which(FullDash2$RecordType=="Accession" & FullDash2$Quality>=3 & FullDash2$DarIndividualCount>0)] <- 5

# Set Backlog = 1 for Quality=9 (in order to count minimum #records/backlog)
FullDash2$Backlog[which(FullDash2$Quality==1 & FullDash2$RecordType=="Accession")] <- 1
# Set Backlog = 0 for Catalogue records
FullDash2$Backlog[which(FullDash2$RecordType=="Catalog")] <- 0

# Catalog Partial data measure -- higher = better
FullDash2$DarCountry[which(FullDash2$DarCountry=="NA" | FullDash2$DarCountry=="")] = NA
FullDash2$DarScientificName[which(FullDash2$DarScientificName=="NA" | FullDash2$DarScientificName=="")] = NA
FullDash2$DarMonthCollected[which(FullDash2$DarMonthCollected=="NA" | FullDash2$DarMonthCollected=="")] = NA
FullDash2$DarCatalogNumber[which(FullDash2$DarCatalogNumber=="NA" | FullDash2$DarCatalogNumber=="")] = NA
FullDash2$DarCollector[which(FullDash2$DarCollector=="NA" | FullDash2$DarCollector=="")] = NA
FullDash2$DarImageURL[which(FullDash2$DarImageURL=="NA" | FullDash2$DarImageURL=="")] = NA
FullDash2$DarLatitude[which(FullDash2$DarLatitude=="NA" | FullDash2$DarLatitude=="")] = NA
FullDash2$DarLongitude[which(FullDash2$DarLongitude=="NA" | FullDash2$DarLongitude=="")] = NA

# Calculate number of Darwin Core fields filled
FullDash2$CatQual <- 5 - (is.na(FullDash2$DarCountry)  # need to update with DarStateProvince
                          +is.na(FullDash2$DarMonthCollected)
                          +is.na(FullDash2$DarCatalogNumber)
                          +is.na(FullDash2$DarCollector)
                          +as.numeric(!FullDash2$TaxIDRank %in% c("Family", "Genus", "Species")))

FullDash2$Quality[which(FullDash2$RecordType=="Catalog")] <- 6
FullDash2$Quality[which(FullDash2$RecordType=="Catalog" & FullDash2$CatQual>0)] <- 7
FullDash2$Quality[which(FullDash2$RecordType=="Catalog" & FullDash2$CatQual>2 & (is.na(FullDash2$DarLatitude)+(is.na(FullDash2$DarImageURL)))<2)] <- 8
FullDash2$Quality[which(FullDash2$RecordType=="Catalog" & FullDash2$CatQual==5 & (is.na(FullDash2$DarLatitude)+(is.na(FullDash2$DarImageURL)))==0)] <- 9


# Quality Summary Count Export ####
QualityFull <- dplyr::count(FullDash2, Quality)
colnames(QualityFull)[1] <- "QualityRank"

QualityCatDar <- dplyr::count(FullDash2[which(FullDash2$RecordType=="Catalog"),], CatQual)
colnames(QualityCatDar)[1] <- "DarFieldsFilled"


# Memory cleanup / Garbage Collection ####
rm(CatDash2, AccDash1, FullDash, FullDash1, FullGUIDcount)
rm(list = c(ls(pattern = "^CatDash0[0-9]$"),
            ls(pattern = "^CatOI"),
            ls(pattern = "^OI_"),
            ls(pattern = "^CatPM"),
            ls(pattern = "^FullCheck"))) 

gc()


Log020FullBind <- warnings()

setwd(origdir)
