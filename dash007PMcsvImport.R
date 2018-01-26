## collections-dashboard-prep
#  Prep Penn Museum catalogue data
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

print(paste(date(), "-- Starting Penn Museum data import -- dash007PMcsvImport.R"))


# point to the directory containg the set of "Group" csv's from EMu
setwd(paste0(origdir,"/data01raw/PM20180121/"))

PennList = list.files(pattern="all.*.csv$")
CatPenn01 <- do.call(rbind, lapply(PennList, read.csv, stringsAsFactors = F))

setwd(paste0(origdir,"/data01raw/emuCat"))  # up to /collprep/data01raw/

colnames(CatPenn01)[1] <- "irn"

CatPenn02 <- CatPenn01[order(CatPenn01$irn),]
CatPenn02 <- unique(CatPenn02)
rm(CatPenn01)

# Remove duplicate irn's
CatIRNcount <- NROW(levels(as.factor(CatPenn02$irn)))

CatPenn02$IRNseq <- sequence(rle(as.character(CatPenn02$irn))$lengths)

#CatPenn03 <- CatPenn02[which(nchar(as.character(CatPenn02$DarGlobalUniqueIdentifier)) > 3 & CatPenn02$IRNseq == 1),]
CatPenn03 <- CatPenn02[which(CatPenn02$IRNseq == 1),]
CatCheck <- CatPenn02[which(CatPenn02$IRNseq > 1),]

CatPenn03 <- dplyr::select(CatPenn03, -IRNseq)

CatPenn04 <- data.frame(
  "Group1_key" = CatPenn03$irn,
  "ecatalogue_key" = "",
  "irn" = paste0("PM",CatPenn03$irn),
  "DarGlobalUniqueIdentifier" = CatPenn03$url,
  "AdmDateInserted" = "",
  "AdmDateModified" = "",
  "DarImageURL" = "",
  "DarIndividualCount" = "",
  "DarBasisOfRecord" = "Artefact",
  "DarLatitude" = "",
  "DarLongitude" = "",
  "DarCountry" = CatPenn03$provenience,
  "DarContinent" = CatPenn03$curatorial_section,
  "DarContinentOcean" = CatPenn03$culture_area,
  "DarWaterBody" = "",
  "DarCollectionCode" = "Anthropology",
  "DarEarliestAge" = "",
  "DarEarliestEon" = "",
  "DarEarliestEpoch" = "",
  "DarEarliestEra" = "",
  "DarEarliestPeriod" = CatPenn03$date_made_early,
  "AttPeriod_tab" = CatPenn03$period,
  "DesEthnicGroupSubgroup_tab" = CatPenn03$culture,
  "DesMaterials_tab" = CatPenn03$material,
  "DarOrder" = "",
  "DarScientificName" = "",
  "ClaRank" = "",
  "ComName_tab" = "",
  "DarRelatedInformation" = paste(CatPenn03$native_name, 
                                  CatPenn03$description,
                                  CatPenn03$technique,
                                  CatPenn03$iconography,
                                  sep = " | "),
  "CatProject_tab" = paste(CatPenn03$accession_credit_line,
                           CatPenn03$creator,
                           sep = " | "),
  "DarYearCollected" = "",
  "DarMonthCollected" = "",
  "EcbNameOfObject" = CatPenn03$object_name,
  "CatLegalStatus" = "",
  "CatDepartment" = "",
  "DarCatalogNumber" = CatPenn03$object_number,
  "DarCollector" = "",
  "MulHasMultiMedia" = "",
  "DarStateProvince" = CatPenn03$provenience,
  "DarInstitutionCode" = "PM",
  stringsAsFactors = F
)

# write the lumped/full/single CSV back out
write.csv(CatPenn04, file="GroupPenn.csv", row.names = F, na="")

setwd(origdir)  # up to /collprep/
