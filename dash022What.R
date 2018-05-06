## EMu Data Prep Script -- Collections Dashboard
# Setup "What" data

print(paste(date(), "-- ...finished setting up WHERE.  Starting dash022What.R"))

# point to csv's directory
setwd(paste0(origdir,"/data01raw"))


#  What LUTs ####
#  1-What: Merge Comm & Sci Names ####
setwd(paste0(origdir,"/supplementary"))
ItisComName <- read.csv(file="WhatComNames.csv", encoding="UTF-8", stringsAsFactors = F)
setwd(paste0(origdir,"/data01raw"))

ItisKeep <- c("English","unspecified")
ItisComName <- ItisComName[which(ItisComName$language %in% ItisKeep),]
ItisComName <- ItisComName[,c("complete_name","vernacular_name")]
colnames(ItisComName) <- c("DarOrder", "ComName2")

#  2-What: Prep/Gather "What" fields ####
ItisComName2 <- ItisComName[order(ItisComName$DarOrder),]
ItisComName2$ordseq <- sequence(rle(as.character(ItisComName2$DarOrder))$lengths)
ItisComName3 <- spread(ItisComName2, ordseq, ComName2, sep="_")
ItisComName4 <- unite(ItisComName3, "ComNam2", ordseq_1:ordseq_7, sep=" | ", remove=TRUE)
ItisComName4 <- ItisComName4[,1:2]
#ItisComName4$ComNam2 <- sapply(ItisComName4$ComNam2, simpleCap)
ItisComName4$ComNam2 <- gsub("\\| NA", "", ItisComName4$ComNam2)
ItisComName4$ComNam2 <- gsub("\\s+", " ", ItisComName4$ComNam2)
ItisComName4$ComNam2 <- sapply(ItisComName4$ComNam2, simpleCap)

#WhatDash4 <- FullDash4[,c("irn", "RecordType", "What", "DarOrder")]
WhatDash4 <- FullDash3[,c("DarGlobalUniqueIdentifier", # "RecordType","DarInstitutionCode", 
                          "DarScientificName", "DarOrder",
                          "DarCollectionCode", "ComName_tab", "DesMaterials_tab",
                          "EcbNameOfObject",
                          "AccDescription","AccDescription2", "DarRelatedInformation")]

WhatDash4 <- merge(WhatDash4, ItisComName4, by="DarOrder", all.x=T)
WhatDash4 <- WhatDash4[,c(2,3,1,4:NCOL(WhatDash4))]


print(paste("... ",substr(date(), 12, 19), "- cleaning WHAT data..."))

#  3-What: Clean "What" fields ####
date()
WhatDash4[,3:NCOL(WhatDash4)] <- sapply(WhatDash4[,3:NCOL(WhatDash4)], function (x) gsub("\\[|\\]|[(,)#$%&+<>?@^{~}!=;/:\"*]|[-]|[0-9]", " ", x))
WhatDash4[,3:NCOL(WhatDash4)] <- sapply(WhatDash4[,3:NCOL(WhatDash4)], function (x) gsub("\\s+", " ", x))
WhatDash4[,3:NCOL(WhatDash4)] <- sapply(WhatDash4[,3:NCOL(WhatDash4)], function (x) gsub("^\\s+|\\s+$", "", x))
date()



WhatDash4$DarCollectionCode <- gsub("Invertebrate Zoology", "Invertebrates", WhatDash4$DarCollectionCode)
WhatDash4$DarCollectionCode <- gsub("and", "", WhatDash4$DarCollectionCode)
WhatDash4$DarCollectionCode <- gsub("\\|| ", " | ", WhatDash4$DarCollectionCode)
WhatDash4$DarCollectionCode <- gsub("Physical \\| Geology", "Physical Geology", WhatDash4$DarCollectionCode)

WhatDash4$AccDesc01 <- WhatDash4$AccDescription
WhatDash4$AccDesc02 <- WhatDash4$AccDescription2
WhatDash4$DarDesc01 <- WhatDash4$DarRelatedInformation
WhatDash4$EcbName   <- WhatDash4$EcbNameOfObject

date()
# # clean punctuation + simpleCap
CleanCols <- c("AccDesc01", "AccDesc02", "DarDesc01", "EcbName", "ComName_tab", "DesMaterials_tab")

WhatDash4[,colnames(WhatDash4) %in% CleanCols] <- sapply(WhatDash4[,colnames(WhatDash4) %in% CleanCols], textClean)
WhatDash4[,colnames(WhatDash4) %in% CleanCols] <- sapply(WhatDash4[,colnames(WhatDash4) %in% CleanCols], wordCut)
WhatDash4[,colnames(WhatDash4) %in% CleanCols] <- sapply(WhatDash4[,colnames(WhatDash4) %in% CleanCols], spaceClean)
WhatDash4[,colnames(WhatDash4) %in% CleanCols] <- sapply(WhatDash4[,colnames(WhatDash4) %in% CleanCols], nanaClean)

WhatDash4$DarScientificName[WhatDash4$DarCollectionCode=="Anthropology"] <- sapply(WhatDash4$DarScientificName[WhatDash4$DarCollectionCode=="Anthropology"], textClean)

date()

# WhatDash4b <- WhatDash4
# WhatDash4b[,colnames(WhatDash4b) %in% CleanCols] <- sapply(WhatDash4b[,colnames(WhatDash4b) %in% CleanCols], function(x) simpleCap(x))
WhatDash4$AccDesc01 <- sapply(WhatDash4$AccDesc01, simpleCap)
WhatDash4$AccDesc02 <- sapply(WhatDash4$AccDesc02, simpleCap)
WhatDash4$DarDesc01 <- sapply(WhatDash4$DarDesc01, simpleCap)
WhatDash4$EcbName   <- sapply(WhatDash4$EcbName, simpleCap)
WhatDash4$DarScientificName[WhatDash4$DarCollectionCode=="Anthropology"] <- sapply(WhatDash4$DarScientificName[WhatDash4$DarCollectionCode=="Anthropology"], simpleCap)
WhatDash4$ComName_tab[which(grepl("`",WhatDash4$ComName_tab)<1)] <- sapply(WhatDash4$ComName_tab[which(grepl("`",WhatDash4$ComName_tab)<1)], simpleCap)
WhatDash4$DesMaterials_tab   <- sapply(WhatDash4$DesMaterials_tab, simpleCap)

date()


#WhatDash4b <- WhatDash4 %>% separate(AccDescription, c("AccDesc01", "AccDesc02", "AccDesc03", "AccDesc04"), 
#                                    sep="\\|", extra="merge", fill="right")

print(paste("... ",substr(date(), 12, 19), "- building WHAT lookup table..."))

#  4-What: Build "What" LUT ####

CollectionLUT <- strsplit(unique(WhatDash4$DarCollectionCode), "\\|")
CollectionLUT <- unlist(CollectionLUT)
CollectionLUT <- gsub("\\s+|^ and $","", CollectionLUT)
CollectionLUT <- data.frame("WhatLUT"=unique(CollectionLUT[which(nchar(CollectionLUT)>2 & is.na(CollectionLUT)==FALSE)]), stringsAsFactors = F)

ComNam1LUT <- strsplit(WhatDash4$ComName_tab, "\\|")
ComNam1LUT <- unlist(ComNam1LUT)
ComNam1LUT <- gsub("\\s+|^ and $|^Na$|^NANA$","", ComNam1LUT)
ComNam1LUT <- data.frame("WhatLUT"=ComNam1LUT[which(nchar(ComNam1LUT)>1 & is.na(ComNam1LUT)==FALSE)], stringsAsFactors = F)
ComNam1count <- dplyr::count(ComNam1LUT, WhatLUT)
ComNam1count <- ComNam1count[which(ComNam1count$n > 5),]
ComNam1LUT <- data.frame("WhatLUT"=unique(ComNam1LUT[which(ComNam1LUT$WhatLUT %in% ComNam1count$WhatLUT),]), stringsAsFactors = F)

ComNam2LUT <- strsplit(WhatDash4$ComNam2, "\\|")
ComNam2LUT <- unlist(ComNam2LUT)
ComNam2LUT <- data.frame("WhatLUT"=ComNam2LUT[which(nchar(ComNam2LUT)>1 & is.na(ComNam2LUT)==FALSE)], stringsAsFactors = F)
ComNam2count <- dplyr::count(ComNam2LUT, WhatLUT)
ComNam2count <- ComNam2count[which(ComNam2count$n > 5),]
ComNam2LUT <- data.frame("WhatLUT"=unique(ComNam2LUT[which(ComNam2LUT$WhatLUT %in% ComNam2LUT$WhatLUT),]), stringsAsFactors = F)

DarOrderLUT <- data.frame("WhatLUT"=WhatDash4$DarOrder)
DarOrdCount <- dplyr::count(DarOrderLUT, WhatLUT)
DarOrdCount <- DarOrdCount[which(DarOrdCount$n > 10),]
DarOrderLUT <- data.frame("WhatLUT"=unique(DarOrderLUT[which(DarOrderLUT$WhatLUT %in% DarOrdCount$WhatLUT),]))

DesMaterialsLUT <- strsplit(WhatDash4$DesMaterials_tab, "\\|")
DesMaterialsLUT <- unlist(DesMaterialsLUT)
DesMaterialsLUT <- data.frame("WhatLUT"=DesMaterialsLUT[which(nchar(DesMaterialsLUT)>2 & is.na(DesMaterialsLUT)==FALSE)], stringsAsFactors = F)
DesMaterCount <- dplyr::count(DesMaterialsLUT, WhatLUT)
DesMaterCount <- DesMaterCount[which(DesMaterCount$n > 40),]
DesMaterialsLUT <- data.frame("WhatLUT"=unique(DesMaterialsLUT[which(DesMaterialsLUT$WhatLUT %in% DesMaterCount$WhatLUT),]))

AccDescriptionLUT <- strsplit(WhatDash4$AccDesc01, "\\|")
AccDescriptionLUT <- unlist(AccDescriptionLUT)
AccDescriptionLUT <- data.frame("WhatLUT"=AccDescriptionLUT[which(nchar(AccDescriptionLUT)>2 & is.na(AccDescriptionLUT)==FALSE)], stringsAsFactors = F)
AccDesCount <- dplyr::count(AccDescriptionLUT, WhatLUT)
AccDesCount <- AccDesCount[which(AccDesCount$n < 500 & AccDesCount$n > 5),]
AccDescriptionLUT <- data.frame("WhatLUT"=unique(AccDescriptionLUT[which(AccDescriptionLUT$WhatLUT %in% AccDesCount$WhatLUT),]), stringsAsFactors = F)

AccDescription2LUT <- strsplit(WhatDash4$AccDesc02, "\\|")
AccDescription2LUT <- unlist(AccDescription2LUT)
AccDescription2LUT <- data.frame("WhatLUT"=AccDescription2LUT[which(nchar(AccDescription2LUT)>2 & is.na(AccDescription2LUT)==FALSE)], stringsAsFactors = F)
AccDes2Count <- dplyr::count(AccDescription2LUT, WhatLUT)
AccDes2Count <- AccDes2Count[which(AccDes2Count$n < 1000 & AccDes2Count$n > 40),]
AccDescription2LUT <- data.frame("WhatLUT"=unique(AccDescription2LUT[which(AccDescription2LUT$WhatLUT %in% AccDes2Count$WhatLUT),]), stringsAsFactors = F)

DesDarRelatedLUT <- strsplit(WhatDash4$DarDesc01, " |\\|")
DesDarRelatedLUT <- unlist(DesDarRelatedLUT)
DesDarRelatedLUT <- data.frame("WhatLUT"=DesDarRelatedLUT[which(nchar(DesDarRelatedLUT)>2 & is.na(DesDarRelatedLUT)==FALSE)], stringsAsFactors = F)
DarRelatCount <- dplyr::count(DesDarRelatedLUT, WhatLUT)
DarRelatCount <- DarRelatCount[which(DarRelatCount$n > 80),]
DesDarRelatedLUT <- data.frame("WhatLUT"=unique(DesDarRelatedLUT[which(DesDarRelatedLUT$WhatLUT %in% DarRelatCount$WhatLUT),]), stringsAsFactors=F)

EcbNameLUT <- strsplit(WhatDash4$EcbName, " |\\|")
EcbNameLUT <- unlist(EcbNameLUT)
EcbNameLUT <- gsub("\\s+|^and$|^of$|^Na$|^NANA$","", EcbNameLUT)
EcbNameLUT <- data.frame("WhatLUT"=EcbNameLUT[which(nchar(EcbNameLUT)>2 & is.na(EcbNameLUT)==FALSE)], stringsAsFactors = F)
EcbNameCount <- dplyr::count(EcbNameLUT, WhatLUT)
EcbNameCount <- EcbNameCount[which(EcbNameCount$n > 5),]
EcbNameLUT <- data.frame("WhatLUT"=unique(EcbNameLUT[which(EcbNameLUT$WhatLUT %in% EcbNameCount$WhatLUT),]), stringsAsFactors=F)

OIwhatLUT <- data.frame("WhatLUT"=unique(gsub("\\d+|^\\s+|\\s+$", "", OIlut_what)), stringsAsFactors = F)
OIwhatLUT$WhatLUT <- sapply(OIwhatLUT$WhatLUT, simpleCap)
OIwhatLUT <- unique(OIwhatLUT)
# rbind unique cleaned lists from each field to one WhatLUT

WhatLUT <- rbind(OIwhatLUT, # might need ot exclude this one; it's LONG
                 CollectionLUT, ComNam1LUT, ComNam2LUT, DarOrderLUT, AccDescriptionLUT, AccDescription2LUT, DesDarRelatedLUT, EcbNameLUT)
WhatLUT$WhatLUT <- as.character(WhatLUT$WhatLUT)
WhatLUT$WhatLUT <- sapply (WhatLUT$WhatLUT, simpleCap)
WhatLUT <- unique(WhatLUT)

WhatLUT2 <- as.data.frame(WhatLUT[which(!WhatLUT$WhatLUT %in% WhereLUTall$WhereLutClean),])

DesEthGroup <- levels(as.factor(FullDash3$DesEthnicGroupSubgroup_tab))
DesEthGroup <- sapply(DesEthGroup, simpleCap)
WhatLUT3 <- as.data.frame(WhatLUT2[which(!WhatLUT2[,1] %in% DesEthGroup),])

WhatLUT4 <- WhatLUT3
WhatLUT4[,1] <- gsub("[[:punct:]]", "", WhatLUT4[,1])
WhatLUT4 <- unique(WhatLUT4)

Chronostrat <- as.list(unique(FullDash3$DarEarliestAge), unique(FullDash3$DarEarliestEon), unique(FullDash3$DarEarliestEpoch), unique(FullDash3$DarEarliestEra), unique(FullDash3$DarEarliestPeriod))
Chronostrat <- gsub("/", " ", Chronostrat)
Chronostrat <- gsub("\\s+", " ", Chronostrat)
Chronostrat <- strsplit(Chronostrat," ")
Chronostrat <- unique(unlist(Chronostrat))

WhatLUT5 <- data.frame("WhatLUT" = WhatLUT4[,1], stringsAsFactors=F)
WhatLUT5 <- data.frame("WhatLUT" = as.character(WhatLUT5[which(!WhatLUT5$WhatLUT %in% Chronostrat),]), stringsAsFactors = F)

WhatLUT6 <- data.frame("WhatLUT" = WhatLUT5[which(!WhatLUT5$WhatLUT %in% DesMaterialsLUT$WhatLUT),])
WhatLUT6$WhatLUT <- gsub("^\\s+|\\s+$", "", WhatLUT6$WhatLUT)
WhatLUT6 <- unique(WhatLUT6)


# Alternative WhatLUT  (actually only using this WhatLUTB currently)

WhatLUTB <- rbind(OIwhatLUT, # LONG; this one needs to be shortened
                  CollectionLUT, ComNam1LUT, ComNam2LUT, DarOrderLUT, AccDescriptionLUT, AccDescription2LUT, DesDarRelatedLUT) # EcbNameLUT, DesMaterialsLUT
WhatLUTB <- unique(WhatLUTB)
WhatLUTB <- strsplit(as.character(WhatLUTB$WhatLUT), "\\|")
WhatLUTB <- data.frame("WhatLUT"=unique(unlist(WhatLUTB)), stringsAsFactors = F)
WhatLUTB$WhatLUT <- gsub("^\\s+|\\s+$", "", WhatLUTB$WhatLUT)
WhatLUTB <- unique(WhatLUTB)
WhatLUTB <- data.frame("WhatLUT"=WhatLUTB[order(WhatLUTB$WhatLUT),], stringsAsFactors = F)
CutWordsNoSpace <- gsub(" ","",CutWords)
WhatLUTB <- data.frame("WhatLUT"=WhatLUTB[which(!WhatLUTB$WhatLUT %in% CutWordsNoSpace),], stringsAsFactors = F)

WhatLUTB$WhatLUT <- gsub("^and$", "", WhatLUTB$WhatLUT, ignore.case = T)
WhatLUTB$WhatLUT <- gsub("^NA$|^NANA$", "", WhatLUTB$WhatLUT, ignore.case = T)
WhatLUTB <- data.frame("WhatLUT"=WhatLUTB[which(nchar(WhatLUTB$WhatLUT)>1),], stringsAsFactors = F)


print(paste("... ",substr(date(), 12, 19), "- uniting WHAT data..."))

#  5-What: Concat "What" fields ####
WhatDash5 <- unite(WhatDash4, "What", c(DarCollectionCode,
                                        DarOrder,
                                        ComName_tab,
                                        ComNam2,
                                        DesMaterials_tab,
                                        AccDesc01,
                                        AccDesc02,
                                        DarDesc01,
                                        DarScientificName,
                                        EcbName
                                        ), sep=" | ", remove=T) 


WhatDash5$What <- gsub("\\| NA \\|", "|", WhatDash5$What, ignore.case = T)
WhatDash5$What <- gsub("\\| and \\|", "|", WhatDash5$What, ignore.case = T)
WhatDash5$What <- gsub("\\s+", " ", WhatDash5$What)
WhatDash5$What <- gsub("(\\|\\s+)+","| ",WhatDash5$What)

WhatDash5 <- WhatDash5[,c("DarGlobalUniqueIdentifier","What","EcbNameOfObject",
                          "AccDescription","AccDescription2", "DarRelatedInformation")]

FullDash4csv <- merge(FullDash3csv, WhatDash5, by=c("DarGlobalUniqueIdentifier"), all.x=T)

FullDash4csv <- FullDash4csv[,c("DarGlobalUniqueIdentifier","DarLatitude","DarLongitude","Where",
                                "Quality","RecordType","Backlog","TaxIDRank",
                                "What","DarCollectionCode","HasMM",
                                "DarInstitutionCode")]

Log022What <- warnings()

# reset working directory
setwd(origdir)
