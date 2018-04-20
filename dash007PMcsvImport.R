## collections-dashboard-prep
#  Prep PM Museum catalogue data
#
# 1) Retrieve latest PM Museum CSV dataset for "All" collections from:
#       https://www.PM.museum/collections/objects/data.php
#
# 2) Move zipped CSV to "/data01raw" folder within this project directory.
# 3) Unzip to a folder labelled "PM[YYYYMMDD]" -- e.g., "PM20180121"
#           NOTE - Check that PM's CSV-naming convention matches "all-YYYYMMDD.csv"
#
# 3) Run this script  
#       - NOTE: May need to re-set working directory to folder containing PM csv's
#         (see lines 23 & 24)

print(paste(date(), "-- Starting PM data import -- dash007PMcsvImport.R"))


# point to the directory containg the set of "Group" csv's from EMu
setwd(paste0(origdir,"/data01raw/PM20180121/"))

PMList = list.files(pattern="all.*.csv$")
CatPM01 <- do.call(rbind, lapply(PMList, read.csv, stringsAsFactors = F))

setwd(paste0(origdir,"/data01raw/emuCat"))  # up to /collprep/data01raw/

colnames(CatPM01)[1] <- "irn"

CatPM02 <- CatPM01[order(CatPM01$irn),]
CatPM02 <- unique(CatPM02)
rm(CatPM01)

# Remove duplicate irn's
CatIRNcount <- NROW(levels(as.factor(CatPM02$irn)))

CatPM02$IRNseq <- sequence(rle(as.character(CatPM02$irn))$lengths)

#CatPM03 <- CatPM02[which(nchar(as.character(CatPM02$DarGlobalUniqueIdentifier)) > 3 & CatPM02$IRNseq == 1),]
CatPM03 <- CatPM02[which(CatPM02$IRNseq == 1),]
CatCheck <- CatPM02[which(CatPM02$IRNseq > 1),]

CatPM03 <- dplyr::select(CatPM03, -IRNseq)

CatPM04 <- data.frame(
  "Group1_key" = paste0("PM",CatPM03$irn),
  "ecatalogue_key" = "",
  "irn" = CatPM03$irn,
  "DarGlobalUniqueIdentifier" = CatPM03$url,
  "AdmDateInserted" = "",
  "AdmDateModified" = "",
  "DarImageURL" = "",
  "DarIndividualCount" = "1",
  "DarBasisOfRecord" = "Artefact",
  "DarLatitude" = "",
  "DarLongitude" = "",
  "DarCountry" = gsub("\\|", " | ", CatPM03$provenience), # check if Where LUT tries to build countries with this; if so, need to not use
  "DarContinent" = "",
  "DarContinentOcean" = CatPM03$culture_area,
  "DarWaterBody" = "",
  "DarCollectionCode" = CatPM03$curatorial_section,
  "DarEarliestAge" = "",
  "DarEarliestEon" = "",
  "DarEarliestEpoch" = "",
  "DarEarliestEra" = "",
  "DarEarliestPeriod" = CatPM03$date_made_early,
  "AttPeriod_tab" = CatPM03$period,
  "DesEthnicGroupSubgroup_tab" = CatPM03$culture,
  "DesMaterials_tab" = CatPM03$material,
  "DarOrder" = "",
  "DarScientificName" = "",
  "ClaRank" = "",
  "ComName_tab" = "",
  "DarRelatedInformation" = paste(CatPM03$native_name, 
                                  CatPM03$description,
                                  CatPM03$technique,
                                  CatPM03$iconography,
                                  sep = " | "),
  "CatProject_tab" = paste(CatPM03$accession_credit_line,
                           CatPM03$creator,
                           sep = " | "),
  "DarYearCollected" = "",
  "DarMonthCollected" = "",
  "EcbNameOfObject" = CatPM03$object_name,
  "CatLegalStatus" = "",
  "CatDepartment" = "", # find out what Penn calls it
  "DarCatalogNumber" = CatPM03$object_number,
  "DarCollector" = "",
  "MulHasMultiMedia" = "",
  "DarStateProvince" = "",
  "DarInstitutionCode" = "PM",
  stringsAsFactors = F
)


# # screen duplicate GUIDs ####
# PMcheck <- dplyr::count(CatPM04, DarGlobalUniqueIdentifier)
# PMcheckGUID <- PMcheck[PMcheck$n>1,]
# PMcheckFull <- CatPM04[which(CatPM04$DarGlobalUniqueIdentifier %in% PMcheckGUID$DarGlobalUniqueIdentifier),]
# 
# if(NROW(PMcheckGUID)>0) {
#   print(paste("Check 'PMcheck' CSVs for these records: ",
#               NROW(PMcheckGUID), "duplicate GUIDs in ", 
#               NROW(PMcheckFull), "PM records"))
#   write.csv(PMcheckFull,"PMcheck.csv", row.names = F, na="")
# } else {
#     print(paste("No duplicate PM GUIDs; all clear!"))
#   }
# 
# CatPM05 <- CatPM04[!(CatPM04$DarGlobalUniqueIdentifier %in% PMcheckGUID$DarGlobalUniqueIdentifier),]


# write the lumped/full/single CSV back out
write.csv(CatPM04, file="GroupPM.csv", row.names = F, na="")

setwd(origdir)  # up to /collprep/
