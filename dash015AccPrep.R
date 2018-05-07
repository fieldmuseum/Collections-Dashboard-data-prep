## collections-dashboard-prep
#  Prep accessions data from EMu for dashboard-prep
#
# 1) In EMu, retrieve Accession records for dashboard, 
#       06-Apr-2017 dataset includes all efmnhtransactions records where:
#           AccAccessionNo = \*
#
# 2) Report them out with "Dashboard v2" report
#       - see collections-dashboard "Help" page for details on which fields are included in report
#       - If under 200k records, report all at one time.
#       - Don't rename reported files. Keep them together in one folder.
#
# 3) Run this script  
#       - NOTE: May need to re-set working directory to folder containing reported csv's
#         (see lines 22 & 23)

print(paste(date(), "-- ...finished importing Cat data.  Starting dash015AccPrep.R"))

detach("package:plyr")  # comment this out if plyr/dplyr functions misbehave


# point to the directory containing the set of "Group" csv's from EMu
setwd(paste0(origdir,"/data01raw/emuAcc"))


# Import raw EMu Accession data ####
Acc1 <- read.csv(file="efmnhtra.csv", stringsAsFactors = F)
Acc2 <- read.csv(file="Group1.csv", stringsAsFactors = F)
Acc2 <- Acc2[,2:NCOL(Acc2)]

Acc <- merge(Acc1, Acc2, by="efmnhtransactions_key", all.x=T)

Acc3 <- read.csv(file="PriAcces.csv", stringsAsFactors = F)
Acc3 <- Acc3[,2:NCOL(Acc3)]
colnames(Acc3[4]) <- "CatIRN"

# proxy for CatCatalog 
AccCat <- Acc[,c("efmnhtransactions_key","AccCatalogue","AccTotalItems","AccTotalObjects","AccCount")]
Acc3 <- merge(AccCat, Acc3, by="efmnhtransactions_key", all.x=T)
Acc3 <- unique(Acc3)

# Calculate Accession Totals
Acc3$CalAccSum <- as.integer(0)
Acc3$CalAccSum[which(Acc3$DarBasisOfRecord=="Lot" | Acc3$DarBasisOfRecord=="Preserved Specimen" | Acc3$DarBasisOfRecord=="Artefact")] <- Acc3$AccTotalItems[which(Acc3$DarBasisOfRecord=="Lot" | Acc3$DarBasisOfRecord=="Preserved Specimen" | Acc3$DarBasisOfRecord=="Artefact")]
Acc3$CalAccSum[which(Acc3$DarBasisOfRecord=="Specimen" && Acc3$AccCatalogue!="Botany")] <- Acc3$AccTotalObjects[which(Acc3$DarBasisOfRecord=="Specimen" && Acc3$AccCatalogue!="Botany")]
Acc3$CalAccSum[which(Acc3$AccCatalogue=="Botany")] <- Acc3$AccCount[which(Acc3$AccCatalogue=="Botany")]
Acc3$CalAccSum[which(is.na(Acc3$CalAccSum)==TRUE)] <- 0

# since Accession records without attached Cat records have no DarBasisOfRecord field, need this (at least as proxy for now):
Acc3$CalAccSum[which(Acc3$CalAccSum==0 & Acc3$AccTotalItems>0)] <- Acc3$AccTotalItems[which(Acc3$CalAccSum==0 & Acc3$AccTotalItems>0)]


# Split Botany from AGZ to summarize by "sum" (Botany) versus max
Acc3accBot <- Acc3[which(Acc3$AccCatalogue=="Botany"),]
Acc3accAGZ <- Acc3[which(Acc3$AccCatalogue!="Botany"),]

Acc3accBotTot <- Acc3accBot %>% group_by(efmnhtransactions_key) %>% summarise(AccTotal = sum(as.numeric(CalAccSum)))
Acc3accAGZTot <- Acc3accAGZ %>% group_by(efmnhtransactions_key) %>% summarise(AccTotal = max(as.numeric(CalAccSum)))

Acc3accTot <- rbind(Acc3accBotTot, Acc3accAGZTot)


# Calculate Catalogged Totals
Acc3$CalCatSum <- as.integer(0)
Acc3$CalCatSum[which(Acc3$DarBasisOfRecord=="Lot" | Acc3$DarBasisOfRecord=="Preserved Specimen")] <- Acc3$DarIndividualCount[which(Acc3$DarBasisOfRecord=="Lot" | Acc3$DarBasisOfRecord=="Preserved Specimen")]
Acc3$CalCatSum[which(Acc3$DarBasisOfRecord=="Artefact")] <- Acc3$CatItemsInv[which(Acc3$DarBasisOfRecord=="Artefact")]
Acc3$CalCatSum[which(Acc3$DarBasisOfRecord=="Specimen" && Acc3$AccCatalogue!="Botany")] <- 1
Acc3$CalCatSum[which(Acc3$AccCatalogue=="Botany")] <- 1
Acc3$CalCatSum[which(is.na(Acc3$CalCatSum)==TRUE)] <- 0


Acc3catTot <- Acc3 %>% group_by(efmnhtransactions_key) %>% summarise(CatTotal = sum(CalCatSum))


# Merge calculations
Acc3tot <- merge(Acc3accTot, Acc3catTot, by = "efmnhtransactions_key")

Acc <- merge(Acc, Acc3tot, by="efmnhtransactions_key", all.x=T)

Acc$backlog <- Acc$AccTotal - Acc$CatTotal
#write.csv(Acc, file="AccBacklog.csv", row.names = F)

# check for duplicates
check <- count(Acc, irn)
check <- check[which(check$n>1),]
check2 <- Acc[which(Acc$irn %in% check$irn),]


# filter out negative backlog values (which count as "catalogged above level 8/7/etc")
AccBL1 <- Acc[which(Acc$backlog >= 0),]

# Export ACC WhereLUTs ... RE-IMPORT to Catalog-Dashboard script
AccGeographyLUT <- as.data.frame(cbind("WhereLUT"=as.character(AccBL1$AccGeography)), stringsAsFactors = F)
AccGeographyLUT <- unique(AccGeographyLUT)

#setwd("C:\\Users\\kwebbink\\Desktop\\IPTdashbdTest")
setwd(paste0(origdir,"/data01raw"))  # up to /collprep/data01raw/
write.csv(AccGeographyLUT, file="AccGeographyLUT.csv", row.names = F)

#setwd("C:\\Users\\kwebbink\\Desktop\\IPTdashbdTest\\accessions")


# check & split duplicate Botany records
checkBL <- count(AccBL1, irn)
checkBL <- checkBL[which(checkBL$n>1),]
AccBL1mult <- AccBL1[which(AccBL1$irn %in% checkBL$irn),]
AccBL1sing <- AccBL1[which(!AccBL1$irn %in% checkBL$irn),]


# spread & concat (Desc + Geog) & re-merge duplicates
AccBL1mult <- AccBL1mult[order(AccBL1mult$irn),]

# concatenate Descriptions
AccBL1multDesc <- AccBL1mult[,c("irn", "AccDescription")]
AccBL1multDesc <- unique(AccBL1multDesc[which(nchar(as.character(AccBL1multDesc$AccDescription))>0),])
AccBL1multDesc$AccDescription <- as.character(AccBL1multDesc$AccDescription)
AccBL1multDesc$irnseq <- paste0("seq", sequence(rle(as.character(AccBL1multDesc$irn))$lengths))
AccBL1multDesc2 <- spread(AccBL1multDesc, irnseq, AccDescription)

AccBL1multDesc2$AccDesConcat <- ""
date()
for (j in 1:NROW(AccBL1multDesc2)) {
  for (i in 2:(NCOL(AccBL1multDesc2)-1)) {
    AccBL1multDesc2$AccDesConcat[j] <- paste0(AccBL1multDesc2$AccDesConcat[j]," | ",AccBL1multDesc2[j,i])
  }}
date()
AccBL1multDesc2$AccDesConcat <- gsub(" \\| NA", "", substr(AccBL1multDesc2$AccDesConcat, 4, nchar(AccBL1multDesc2$AccDesConcat)), ignore.case = T)

AccBL1multDesc2 <- AccBL1multDesc2[,c("irn","AccDesConcat")]


# concatenate Geography
AccBL1multGeo <- AccBL1mult[,c("irn", "AccGeography")]
AccBL1multGeo <- unique(AccBL1multGeo[which(nchar(as.character(AccBL1multGeo$AccGeography))>1),])
AccBL1multGeo$AccGeography <- as.character(AccBL1multGeo$AccGeography)
AccBL1multGeo$irnseq <- paste0("seq", sequence(rle(as.character(AccBL1multGeo$irn))$lengths))
AccBL1multGeo2 <- spread(AccBL1multGeo, irnseq, AccGeography)

AccBL1multGeo2$AccGeogConcat <- ""
date()
for (j in 1:NROW(AccBL1multGeo2)) {
  for (i in 2:(NCOL(AccBL1multGeo2)-1)) {
    AccBL1multGeo2$AccGeogConcat[j] <- paste0(AccBL1multGeo2$AccGeogConcat[j]," | ",AccBL1multGeo2[j,i])
  }}
date()
AccBL1multGeo2$AccGeogConcat <- gsub(" \\| NA", "", substr(AccBL1multGeo2$AccGeogConcat, 4, nchar(AccBL1multGeo2$AccGeogConcat)), ignore.case = T)

AccBL1multGeo2 <- AccBL1multGeo2[,c("irn","AccGeogConcat")]

# merge concatenated Geo & Desc
AccBL1multGD <- merge(AccBL1multDesc2, AccBL1multGeo2, all.x=T, all.y=T)

# merge to full dup-dataset
AccBL1mult2 <- merge(AccBL1mult, AccBL1multGD, by="irn", all.x=TRUE)
AccBL1mult2$AccDescription <- AccBL1mult2$AccDesConcat
AccBL1mult2$AccGeography <- AccBL1mult2$AccGeogConcat



#  If add AccCatalogueNo field:  ####
#  May NEED TO ADJUST column numbers in the rbind section below


# rbind dup & single datasets back together
AccBL1mult3 <- AccBL1mult2[,-c(18:19)]
AccBL1mult3 <- unique(AccBL1mult3)

AccBL2 <- rbind(AccBL1sing, AccBL1mult3)

#AccBL3 <- as.data.frame(cbind("irn" = AccBL2$irn,
#                                 "DarLatitude" = as.numeric(0),
#                                 "DarLongitude" = as.numeric(0),
#                                 "DarGlobalUniqueIdentifier" = "",
#                                 "AccGeo" = AccBL2$AccGeography,
#                                 "AccDesConcat" = paste(AccBL2$AccAccessionDescription, "|", AccBL2$AccDescription)
#                                 ))

AccBasOfRec <- Acc3[,c(1,9)]
AccBasOfRec <- unique(AccBasOfRec)

AccBL3 <- merge(AccBL2, AccBasOfRec, by="efmnhtransactions_key", all.x=T)

# Memory cleanup
rm(Acc, Acc1, Acc2)

rm(list = c(ls(pattern = "Acc3"),
            ls(pattern = "AccBL1"),
            ls(pattern = "AccBL2"))) 


# subset only the columns needed for subsequent calculations
AccBL3 <- AccBL3[,-1]

# export &/or prep for rbind with cat data
write.csv(AccBL3, file="AccBacklogBU.csv", row.names = F, na = "")

setwd(origdir)  # up to /collprep/
