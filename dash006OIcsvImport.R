## collections-dashboard-prep
#  Prep Oriental Institute catalogue data
#
# 1) Retrieve latest Penn Museum CSV dataset for "All" collections from:
#       https://www.penn.museum/collections/objects/data.php
#
# 2) Move zipped CSV to "/data01raw" folder within this project directory.
# 3) Unzip to a folder labelled "PM[YYYYMMDD]" -- e.g., "PM20180121"
#           NOTE - Check that Penn's CSV-naming convention matches "all-YYYYMMDD.csv"
#
# 3) Run this script  
#       - NOTE: May need to re-set working directory to folder containing PM csv's
#         (see lines 23 & 24)

print(paste(date(), "-- Starting OI Museum data import -- dash006OIcsvImport.R"))


# point to the directory containg the set of "Group" csv's from EMu
setwd(paste0(origdir,"/data01raw/OI20180206"))

OIList = list.files(pattern="OI.*.csv$")
CatOI01 <- do.call(rbind, lapply(OIList, read.csv, stringsAsFactors = F))

setwd(paste0(origdir,"/data01raw/emuCat"))

CatOI02 <- CatOI01[order(CatOI01$irn),-c(1:2)]
CatOI02 <- unique(CatOI02)
rm(CatOI01)


# split out each of the Multivalue fields 
  # - Multimedia
  CatOI_MM <- unique(CatOI02[,c("irn", "irn.1", "DetResourceType", "MulIdentifier")])
  CatOI_MM$IRNseq <- sequence(rle(as.character(CatOI_MM$irn))$lengths)
  
  # build MM URL
  
  # spread MM
  CatOI_MMs <- spread(CatOI_MM, IRNseq, mmURL, fill="")
  
  # [repeat MM/multi-value spread for these 3 fields:]
  # - ProAlternateNames
  CatOI_names <- unique(CatOI02[,c("irn", "ProAlternateNames")])
  
  # - ColClassification
  CatOI_class <- unique(CatOI02[,c("irn", "ColClassification")])
  
  # - CatDescription
  CatOI_desc <- unique(CatOI02[,c("irn", "CatDescription")])

  

# build list of columns to drop
drops <- c("irn.1","DetResourceType","MulIdentifier",
           "ProAlternateNames", "ColClassification", "CatDescription")

CatOIunique <- unique(CatOI02[,!(names(CatOI02) %in% drops)])

# Remove duplicate irn's
# NOTE - for Egypt 2018-feb dataset, should have 59301 unique obj records
CatIRNcount <- NROW(levels(as.factor(CatOI02$irn)))





#CatOI03 <- CatOI02[which(nchar(as.character(CatOI02$DarGlobalUniqueIdentifier)) > 3 & CatOI02$IRNseq == 1),]
CatOI03 <- CatOI02[which(CatOI02$IRNseq == 1),]
CatCheck <- CatOI02[which(CatOI02$IRNseq > 1),]

CatOI03 <- dplyr::select(CatOI03, -IRNseq)

CatOI04 <- data.frame(
  "Group1_key" = CatOI03$irn,
  "ecatalogue_key" = "",
  "irn" = paste0("OI",CatOI03$irn),
  "DarGlobalUniqueIdentifier" = CatOI03$url,
  "AdmDateInserted" = "",
  "AdmDateModified" = "",
  "DarImageURL" = "",
  "DarIndividualCount" = "",
  "DarBasisOfRecord" = "Artefact",
  "DarLatitude" = "",
  "DarLongitude" = "",
  "DarCountry" = CatOI03$provenience,
  "DarContinent" = CatOI03$curatorial_section,
  "DarContinentOcean" = CatOI03$culture_area,
  "DarWaterBody" = "",
  "DarCollectionCode" = "Anthropology",
  "DarEarliestAge" = "",
  "DarEarliestEon" = "",
  "DarEarliestEpoch" = "",
  "DarEarliestEra" = "",
  "DarEarliestPeriod" = CatOI03$date_made_early,
  "AttPeriod_tab" = CatOI03$period,
  "DesEthnicGroupSubgroup_tab" = CatOI03$culture,
  "DesMaterials_tab" = CatOI03$material,
  "DarOrder" = "",
  "DarScientificName" = "",
  "ClaRank" = "",
  "ComName_tab" = "",
  "DarRelatedInformation" = paste(CatOI03$native_name, 
                                  CatOI03$description,
                                  CatOI03$technique,
                                  CatOI03$iconography,
                                  sep = " | "),
  "CatProject_tab" = paste(CatOI03$accession_credit_line,
                           CatOI03$creator,
                           sep = " | "),
  "DarYearCollected" = "",
  "DarMonthCollected" = "",
  "EcbNameOfObject" = CatOI03$object_name,
  "CatLegalStatus" = "",
  "CatDepartment" = "",
  "DarCatalogNumber" = CatOI03$object_number,
  "DarCollector" = "",
  "MulHasMultiMedia" = "",
  "DarStateProvince" = CatOI03$provenience,
  "DarInstitutionCode" = "OI",
  stringsAsFactors = F
)

# write the lumped/full/single CSV back out
write.csv(CatOI04, file="GroupOI.csv", row.names = F, na="")

setwd(origdir)  # up to /collprep/
