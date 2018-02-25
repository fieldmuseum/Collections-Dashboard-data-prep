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


# Setup sample raw Catalogue data
SampleGroupC <- c(1321,1:5,656944:656946,537448:537450,867365:867370,2099480,2099482,2668290:2668296,54463,50771,136283,2788069,2388945)
CatDash03Samp1 <- CatDash2[which(CatDash2$irn %in% SampleGroupC),]


CatDash2 <- unique(CatDash2)
#check <- dplyr::count(CatDash3, irn)


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
CatDash3$MulHasMultiMedia <- gsub("N","0",CatDash3$MulHasMultiMedia)
CatDash3$MulHasMultiMedia[which(is.na(CatDash3$MulHasMultiMedia)==T)] <- "0"
CatDash3$DarImageURL <- as.integer(CatDash3$MulHasMultiMedia)


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

CatDash3$ClaRank <- simpleCap(CatDash3$ClaRank)

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



# Map Acc fields to Cat fields
AccDash2 <- as.data.frame(cbind("irn" = AccDash1$irn,
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
                                "RecordType" = "Accession",
                                "AccTotal" = AccDash1$AccTotal,
                                "Backlog" = AccDash1$backlog),
                                "DarInstitutionCode" = "FMNH",  # AccDash1$DarInstitutionCode,
                          stringsAsFactors=F)

AccDash2$DarIndividualCount <- as.numeric(AccDash2$DarIndividualCount)

print(paste("... ", substr(date(), 12, 19), "- binding catalogue & accession records..."))

# bind catalog and backlog records
FullDash <- plyr::rbind.fill(CatDash3, AccDash2)


print(paste("... ",substr(date(), 12, 19), "- cleaning up full data table..."))

# cleanup import
rm(CatDash2, AccDash1)
FullDash2 <- unique(FullDash)


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
FullDash2$DarCountry[which(FullDash2$DarCountry=="NA")] = NA
FullDash2$DarScientificName[which(FullDash2$DarScientificName=="NA")] = NA
FullDash2$DarMonthCollected[which(FullDash2$DarMonthCollected=="NA")] = NA
FullDash2$DarCatalogNumber[which(FullDash2$DarCatalogNumber=="NA")] = NA
FullDash2$DarCollector[which(FullDash2$DarCollector=="NA")] = NA
FullDash2$DarImageURL[which(FullDash2$DarImageURL=="NA")] = NA
FullDash2$DarLatitude[which(FullDash2$DarLatitude=="NA")] = NA
FullDash2$DarLongitude[which(FullDash2$DarLongitude=="NA")] = NA

# Calculate number of Darwin Core fields filled
FullDash2$CatQual <- 5 - (is.na(FullDash2$DarCountry)  # need to update with DarStateProvince
                          +is.na(FullDash2$DarMonthCollected)
                          +is.na(FullDash2$DarCatalogNumber)
                          +is.na(FullDash2$DarCollector)
                          +as.numeric(!FullDash2$TaxIDRank %in% c("Family", "Genus", "Species")))

FullDash2$Quality[which(FullDash2$RecordType=="Catalog")] <- 6
FullDash2$Quality[which(FullDash2$RecordType=="Catalog" & FullDash2$CatQual>0)] <- 7
FullDash2$Quality[which(FullDash2$RecordType=="Catalog" & FullDash2$CatQual>2 & (is.na(FullDash2$DarLatitude)+(1-FullDash2$DarImageURL))<2)] <- 8
FullDash2$Quality[which(FullDash2$RecordType=="Catalog" & FullDash2$CatQual==5 & (is.na(FullDash2$DarLatitude)+(1-FullDash2$DarImageURL))==0)] <- 9


# Quality Summary Count Export ####
QualityFull <- dplyr::count(FullDash2, Quality)
colnames(QualityFull)[1] <- "QualityRank"

QualityCatDar <- dplyr::count(FullDash2[which(FullDash2$RecordType=="Catalog"),], CatQual)
colnames(QualityCatDar)[1] <- "DarFieldsFilled"

Log020FullBind <- warnings()

setwd(origdir)
