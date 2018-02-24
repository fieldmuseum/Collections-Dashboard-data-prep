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
OIlist = list.files(pattern="*.csv$")

# # if need to check encoding:
# #  ( thanks to: https://stackoverflow.com/a/4814870/4963125 )
# codepages <- setNames(iconvlist(), iconvlist())
# 
# x <- lapply(codepages, function(enc) try(read.table(OIlist[1],
#                                                     fileEncoding=enc,
#                                                     nrows=3, header=TRUE, sep=",")))
# 
# enc2check <- unique(do.call(rbind, sapply(x, dim)))
# # check values in enc2check; the rowname with both values > 1 should be the encoding you need to use.
# # CP1200 seems to work; alternatively, try UCS-2LE
# # ...otherwise, if UTF-16: https://stat.ethz.ch/R-manual/R-devel/library/base/html/iconv.html

# import files with assigned encoding
list2env(
  lapply(setNames(OIlist, make.names(gsub(".csv$", "_OI", OIlist))), # pretty names break stuff
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


# LUTs Prep ####

# WHAT
# ColClassification
CatOI_class <- unique(OIecatalog[order(OIecatalog$ColClassification),c("ColClassification")])

# CatDescription  # should unlist/break up to make shorter LUT / better search
CatOI_desc <- unique(OIecatalog[order(OIecatalog$CatDescription),c("CatDescription")])

# ProMaterials
CatOI_mate

# CatCollection
CatOI_coll

# InsDialect
CatOI_dial

# InsScript
CatOI_scri


# WHEN
# DatKingRuler # also in WHO-LUT
CatOI_king 

# DatDynasty
CatOI_dyna 

# DatPeriod
CatOI_peri

# DatDateMade
CatOI_made 

# AcqDateReceived
CatOI_rece 


# WHERE
# ProCountry
CatOI_coun 

# ProRegion
CatOI_regi 
# ArcLocus?


# WHO

CatOI_king # also in WHEN-LUT

# ProAlternateNames
CatOI_names <- unique(ProAlter_OI[order(ProAlter_OI$ProAlternateNames),c("ProAlternateNames")])

# ProCulturalAffiliation
CatOI_cult 



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

rm(list = ls(pattern = "*_OI"))
rm(OIlist, OIlist2, OIecatalog,
   oiTable, oiTable2, oiTableSpread)


setwd(paste0(origdir,"/data01raw/emuCat"))

CatOI02 <- OImerged[order(OImerged$irn),-1]
CatOI02 <- unique(CatOI02)
rm(OImerged)

# If need to drop columns &/or re-check uniqueness:
# 
# # build list of columns to drop
# drops <- c("irn.1","DetResourceType","MulIdentifier",
#            "ProAlternateNames", "ColClassification", "CatDescription")
# 
# CatOIunique <- unique(CatOI02[,!(names(CatOI02) %in% drops)])
# 
# # Remove duplicate irn's
# # NOTE - for Egypt 2018-feb dataset, should have 59301 unique obj records
# CatIRNcount <- NROW(levels(as.factor(CatOI02$irn)))


CatOI03 <- data.frame(
  "Group1_key" = CatOI02$irn,
  "ecatalogue_key" = "",
  "irn" = paste0("OI",CatOI02$irn),
  "DarGlobalUniqueIdentifier" = CatOI02$AdmGUIDValue,
  "AdmDateInserted" = CatOI02$AdmDateInserted,
  "AdmDateModified" = CatOI02$AdmDateInserted,
  "DarImageURL" = CatOI02$Media,
  "DarIndividualCount" = "1",
  "DarBasisOfRecord" = "Artefact",
  "DarLatitude" = "",
  "DarLongitude" = "",
  "DarCountry" = CatOI02$ProCountry,
  "DarContinent" = "",
  "DarContinentOcean" = "",
  "DarWaterBody" = "",
  "DarCollectionCode" = "Anthropology",
  "DarEarliestAge" = "",
  "DarEarliestEon" = "",
  "DarEarliestEpoch" = "",
  "DarEarliestEra" = "",
  "DarEarliestPeriod" = CatOI02$DatDateMade,
  "AttPeriod_tab" = CatOI02$DatPeriod,
  "DesEthnicGroupSubgroup_tab" = CatOI02$ProC ,
  "DesMaterials_tab" = CatOI02$material,
  "DarOrder" = "",
  "DarScientificName" = "",
  "ClaRank" = "",
  "ComName_tab" = "",
  "DarRelatedInformation" = paste(CatOI02$native_name, 
                                  CatOI02$description,
                                  CatOI02$technique,
                                  CatOI02$iconography,
                                  sep = " | "),
  "CatProject_tab" = paste(CatOI02$accession_credit_line,
                           CatOI02$creator,
                           sep = " | "),
  "DarYearCollected" = "",
  "DarMonthCollected" = "",
  "EcbNameOfObject" = CatOI02$object_name,
  "CatLegalStatus" = "",
  "CatDepartment" = "",
  "DarCatalogNumber" = CatOI02$object_number,
  "DarCollector" = "",
  "MulHasMultiMedia" = "",
  "DarStateProvince" = CatOI02$provenience,
  "DarInstitutionCode" = "OI",
  stringsAsFactors = F
)

# write the lumped/full/single CSV back out
write.csv(CatOI04, file="GroupOI.csv", row.names = F, na="")

setwd(origdir)  # up to /collprep/
