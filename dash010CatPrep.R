## collections-dashboard-prep
#  Prep catalogue data from EMu for dashboard-prep
#
# 1) In EMu, retrieve Catalogue records for dashboard, 
#       06-Apr-2017 dataset includes all ecatalogue records where:
#           + (CatDepartment = "Anthropology" & CatLegalStatus = "Permanent Collection") |
#           + (CatDepartment = "Zoology" | "Botany" | "Geology")  &  AdmPublishWebNoPassword = "Yes"
#
# 2) Report them out with "IPT dashboard" report
#       - see collections-dashboard "Help" page for details on which fields are included in report
#       - Best to report out 200k records at a time.
#       - Rename "Group1.csv" as "Group1_[sequence-number].csv"
#       - Move CSVs to "/data01raw/emuCat" folder within this project directory.
            
#           NOTE - Sequence numbering method does not matter as long as names are unique.
#                - "Group" is the only required term in the CSV filenames.
#
# 3) Run this script  
#       - NOTE: May need to re-set working directory to folder containing "Group" csv's
#         (see lines 23 & 24)

print(paste(date(), "-- Starting Catalog data import -- dash010CatPrep.R"))


# Import the set of "Group" csv's from EMu
# setwd(paste0(origdir,"/data01raw/emuCat/"))

DashList <- list.files(path = "data01raw/emuCat/", pattern="Group.*.csv$")
DashList2 <- paste0("data01raw/emuCat/", DashList)
CatDash01 <- do.call(rbind, lapply(DashList2, read.csv, stringsAsFactors = F, na.strings = ""))


# Set NA's to empty ""
CatDash01[is.na(CatDash01)] <- ""

CatDash02 <- CatDash01[order(CatDash01$DarGlobalUniqueIdentifier, CatDash01$DarCatalogNumber),-c(1,2)]
CatDash03 <- unique(CatDash02)


# Sort out good GUIDs from duplicate/bad GUIDs
CatDash03$seq <- sequence(rle(CatDash03$DarGlobalUniqueIdentifier)$length)

CatDash03guidDup <- CatDash03[which(CatDash03$seq > 1),]
CatDash03guidBad <- CatDash03[which(nchar(CatDash03$DarGlobalUniqueIdentifier)<36),]

CatDash03 <- CatDash03[which(CatDash03$seq == 1
                             & nchar(CatDash03$DarGlobalUniqueIdentifier)==36),]

# Need to keep CatDash02 for something?
rm(CatDash01)


# write out the lumped/full/single CSV backup
write.csv(CatDash03, file="data01raw/CatDash03bu.csv", row.names = F, na="")

# write out the duplicated/bad GUIDs to be checked
write.csv(CatDash03guidDup, file="data03check/CatDash_dupGUID.csv", row.names = F, na="")
write.csv(CatDash03guidBad, file="data03check/CatDash_badGUID.csv", row.names = F, na="")

