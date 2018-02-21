## collections-dashboard-prep
#  Prep Oriental Institute catalogue data
#
# 1) Retrieve latest OI CSV dataset...
# 2) Move zipped CSV to "/data01raw" folder within this project directory.
# 3) Unzip to a folder labelled "OI[YYYYMMDD]" -- e.g., "OI20180121"
#           NOTE - Check that OI dataset structure is correct
#
# 4) Run this script  
#       - NOTE: May need to re-set working directory to folder containing PM csv's
#         (see lines 23 & 24)

print(paste(date(), "-- Starting OI Museum data import -- dash006OIcsvImport.R"))


# point to the directory containg the set of "Group" csv's from EMu
setwd(paste0(origdir,"/data01raw/OI20180206"))


# make list of files into list of dataframes
OIList = list.files(pattern="*.csv$")

# # if need to check encoding:
# #  ( thanks to: https://stackoverflow.com/a/4814870/4963125 )
# codepages <- setNames(iconvlist(), iconvlist())
# 
# x <- lapply(codepages, function(enc) try(read.table(OIList[1],
#                                                     fileEncoding=enc,
#                                                     nrows=3, header=TRUE, sep=",")))
# 
# enc2check <- unique(do.call(rbind, sapply(x, dim)))
# # check values in enc2check; the rowname with both values > 1 should be the encoding you need to use.
# # CP1200 seems to work; alternatively, try UCS-2LE
# # ...otherwise, if UTF-16: https://stat.ethz.ch/R-manual/R-devel/library/base/html/iconv.html

# import files with assigned encoding
list2env(
  lapply(setNames(OIList, make.names(gsub(".csv$", "_OI", OIList))), # pretty names break stuff
         read.table, 
         fileEncoding="CP1200", 
         header=T, sep=",",
         stringsAsFactors = F),
  envir = .GlobalEnv)

# cleanup empty tables
to.rm <- unlist(eapply(.GlobalEnv, function(x) is.data.frame(x) && NROW(x) < 1))
rm(list = names(to.rm)[to.rm], envir = .GlobalEnv)

# rename catalog 
OIecatalog <- ecatalog_OI
rm(ecatalog_OI)

# prep multimedia tables 
#   Need logic for PDFs?
#   Need to re-export DetResourceType?
MulMulti_OI$mediaURL <- paste0("https://oi-idb-static.uchicago.edu/multimedia/",
                               MulMulti_OI$irn, "/",
                               gsub("*.JPG",".1920x1200.jpg",
                                    MulMulti_OI$MulIdentifier, ignore.case = T))

# For now! (logic for PDFs & videos/DetResourceType should make this just a |-delim list of URLs)
MulMulti_OI <- unite(MulMulti_OI, Media, irn:mediaURL, sep=" | ")


# make a list of the OI dataframes 
#  NOTE - might instead want import CSVs directly into list of dataframes?
OIlist2 <- Filter(function(x) is(x, "data.frame"), mget(ls(pattern = "*_OI")))
# do.call(rbind, as.list(ls(pattern = "*_OI")))


# spread, unite & merge Multi-Value fields

OImerged <- OIecatalog

for (i in seq_along(OIlist2)) {
  oiTable <- OIlist2[[i]][,-1]  # drop the local key field
  oiNames <- colnames(oiTable)
  colnames(oiTable)[2] <- "SpreadVal"
  oiTable <- unique(oiTable)
  oiTable$seq <- sequence(rle(as.character(oiTable[,1]))$lengths)
  oiTableSpread <- spread(oiTable, seq, SpreadVal, fill = "")
  oiTable2 <- unite(oiTableSpread, TabName, -ecatalogue_key, sep = " | ")
  oiTable2$TabName <- gsub("(\\s+\\|)+", " |", oiTable2$TabName)
  oiTable2$TabName <- gsub("(\\s+\\|\\s+)$", "", oiTable2$TabName)
  colnames(oiTable2)[2] <- oiNames[2]
  OImerged <- merge(OImerged, oiTable2, by = "ecatalogue_key", all.x=T)
}




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
