## EMu Data Prep Script -- Collections Dashboard
# Setup "Where" data

print(paste(date(), "-- ...finished binding Cat & Acc data.    Starting dash021Where.R"))

# point to csv's directory
setwd(paste0(origdir,"/data01raw"))


print(paste("... ",substr(date(), 12, 19), "- cleaning WHERE data..."))

# Clean 'Where' data [plus pre-concatenated AccGeography values] ####

AccGeographyLUT <- read.csv(file="AccGeographyLUT.csv", stringsAsFactors = F)
AccGeographyLUT <- unique(AccGeographyLUT)

# setup clean columns
FullDash2$cleanDarCountry <- FullDash2$DarCountry
FullDash2$cleanAccLocality <- FullDash2$AccLocality
FullDash2$cleanAccGeography <- FullDash2$AccGeography
FullDash2$cleanDarContinent <- FullDash2$DarContinent
FullDash2$cleanDarWaterBody <- FullDash2$DarWaterBody
FullDash2$cleanDarContinentOcean <- ""

FullDash2$cleanDarContinentOcean[which(FullDash2$DarContinentOcean!=FullDash2$DarContinent
                                       & FullDash2$DarContinentOcean!=FullDash2$DarWaterBody)] <-
  FullDash2$DarContinentOcean[which(FullDash2$DarContinentOcean!=FullDash2$DarContinent
                                    & FullDash2$DarContinentOcean!=FullDash2$DarWaterBody)]

# FullDash2$cleanDarContinentOcean[which((FullDash2$DarContinent!="" & FullDash2$DarWaterBody!="")
#                                             & (str_detect(FullDash2$DarContinentOcean, coll(FullDash2$DarContinent))<1
#                                                | str_detect(FullDash2$DarContinentOcean, coll(FullDash2$DarWaterBody))<1))] <-
#   FullDash2$DarContinentOcean[which((FullDash2$DarContinent!="" & FullDash2$DarWaterBody!="")
#                                       & (str_detect(FullDash2$DarContinentOcean, coll(FullDash2$DarContinent))>0
#                                       | str_detect(FullDash2$DarContinentOcean, coll(FullDash2$DarWaterBody))>0))]


AccGeographyLUT$WhereLUT <- AccGeographyLUT$WhereLUT

date()
CleanCols <- c("cleanDarCountry", "cleanAccGeography", "cleanDarContinent",
               "cleanDarContinentOcean", "cleanDarWaterBody")

FullDash2[,(colnames(FullDash2) %in% CleanCols)] <- sapply(FullDash2[,(colnames(FullDash2) %in% CleanCols)],
                                                           textClean, 
                                                           keepApostrophe=T)
FullDash2$cleanAccLocality <- sapply(FullDash2$cleanAccLocality, textClean, keepApostrophe = F)
AccGeographyLUT$WhereLUT <- sapply(AccGeographyLUT$WhereLUT, textClean, keepApostrophe = F)
# FullDash2$cleanDarCountry <- gsub("\\[|\\]|[(,)&?!=;/:#\"*]|[-]|[0-9]", " ", FullDash2$DarCountry)
# FullDash2$cleanAccLocality <- gsub("[[:punct:]]|[0-9]", " ", FullDash2$AccLocality)
# FullDash2$cleanAccGeography <- gsub("\\[|\\]|[(,)&?!=;/:#\"*]|[-]|[0-9]", " ", FullDash2$AccGeography)
# FullDash2$cleanDarContinent <- gsub("\\[|\\]|[(,)&?!=;/:#\"*]|[-]|[0-9]", " ", FullDash2$DarContinent)
# FullDash2$cleanDarContinentOcean <- gsub("\\[|\\]|[(,)&?!=;/:#\"*]|[-]|[0-9]", " ", FullDash2$DarContinentOcean)
# FullDash2$cleanDarWaterBody <- gsub("\\[|\\]|[(,)&?!=;/:#\"*]|[-]|[0-9]", " ", FullDash2$DarWaterBody)
# AccGeographyLUT$WhereLUT <- gsub("\\[|\\]|[(,)&?!=;/:#\"*]|[-]|[0-9]", " ", AccGeographyLUT$WhereLUT)

# # Extra cleanup for demo; should probably pare this back for dev
# FullDash2$cleanDarCountry <- gsub("[\\]", " ", FullDash2$cleanDarCountry)
# FullDash2$cleanDarWaterBody <- gsub("[\\]", " ", FullDash2$cleanDarWaterBody)
# FullDash2$cleanAccLocality <- gsub("[\\]", " ", FullDash2$cleanAccLocality)
# FullDash2$cleanAccGeography <- gsub("[\\]", " ", FullDash2$cleanAccGeography)
# AccGeographyLUT$WhereLUT <- gsub("[\\]", " ", AccGeographyLUT$WhereLUT) 

# FullDash2$cleanDarCountry <- gsub("UK-", "United Kingdom ", FullDash2$cleanDarCountry, ignore.case=T)
# FullDash2$cleanDarCountry <- gsub(" UK$", "United Kingdom", FullDash2$cleanDarCountry, ignore.case=T)
# FullDash2$cleanAccLocality <- gsub("UK-", "United Kingdom ", FullDash2$cleanAccLocality, ignore.case=T)
# FullDash2$cleanAccGeography <- gsub("UK-", "United Kingdom ", FullDash2$cleanAccGeography, ignore.case=T)
# FullDash2$cleanAccLocality <- gsub("UK-", "United Kingdom ", FullDash2$cleanAccLocality, ignore.case=T)

date()
CleanWords <- c("cleanDarCountry", "cleanAccGeography", "cleanAccLocality")
FullDash2[,colnames(FullDash2) %in% CleanWords] <- sapply(FullDash2[,colnames(FullDash2) %in% CleanWords], wordCut)
AccGeographyLUT$WhereLUT <- sapply(AccGeographyLUT$WhereLUT, wordCut)
date()
# CutFirst <- c("^[Aa] ","^[Aa]bout ","^[Tt]he ")
# CutWords <- c(" a "," about "," an "," and "," as "," be ",
#               " for "," from "," in "," of "," on "," or ",
#               " s "," the "," to "," with ")
# FullDash2$cleanDarCountry <- gsub(paste(CutFirst, collapse="|"), " ", FullDash2$cleanDarCountry, ignore.case = T)
# FullDash2$cleanAccLocality <- gsub(paste(CutFirst, collapse="|"), " ", FullDash2$cleanAccLocality, ignore.case = T)
# FullDash2$cleanAccGeography <- gsub(paste(CutFirst, collapse="|"), " ", FullDash2$cleanAccGeography, ignore.case = T)
# AccGeographyLUT$WhereLUT <- gsub(paste(CutFirst, collapse="|"), " ", AccGeographyLUT$WhereLUT, ignore.case = T)
# FullDash2$cleanDarCountry <- gsub(paste(CutWords, collapse="|"), " ", FullDash2$cleanDarCountry, ignore.case = T)
# FullDash2$cleanAccLocality <- gsub(paste0(CutWords, collapse="|"), " ", FullDash2$cleanAccLocality, ignore.case = T)
# FullDash2$cleanAccGeography <- gsub(paste0(CutWords, collapse="|"), " ", FullDash2$cleanAccGeography, ignore.case = T)
# AccGeographyLUT$WhereLUT <- gsub(paste0(CutWords, collapse="|"), " ", AccGeographyLUT$WhereLUT, ignore.case = T)

FullDash2[,c("cleanAccLocality","cleanAccGeography")] <- sapply(FullDash2[,c("cleanAccLocality","cleanAccGeography")],
                                                                function (x) gsub(" [[:alpha:]]{1} ", " ", x, ignore.case = T))
AccGeographyLUT$WhereLUT <- gsub(" [[:alpha:]]{1} ", " ", AccGeographyLUT$WhereLUT, ignore.case = T)

date()
CleanSpace <- c("cleanDarCountry", "cleanAccLocality", "cleanAccGeography",
                "cleanDarContinent", "cleanDarContinentOcean", "cleanDarWaterBody")
FullDash2[,colnames(FullDash2) %in% CleanSpace] <- sapply(FullDash2[,colnames(FullDash2) %in% CleanSpace], spaceClean)
AccGeographyLUT$WhereLUT <- sapply(AccGeographyLUT$WhereLUT, spaceClean)

# FullDash2$cleanDarCountry <- gsub("\\s+", " ", FullDash2$cleanDarCountry)
# FullDash2$cleanAccLocality <- gsub("\\s+", " ", FullDash2$cleanAccLocality)
# FullDash2$cleanAccGeography <- gsub("\\s+", " ", FullDash2$cleanAccGeography)
# FullDash2$cleanDarContinent <- gsub("\\s+", " ", FullDash2$cleanDarContinent)
# FullDash2$cleanDarContinentOcean <- gsub("\\s+", " ", FullDash2$cleanDarContinentOcean)
# FullDash2$cleanDarWaterBody <- gsub("\\s+", " ", FullDash2$cleanDarWaterBody)
# AccGeographyLUT$WhereLUT <- gsub("\\s+", " ", AccGeographyLUT$WhereLUT)
# 
# FullDash2$cleanDarCountry <- gsub("^\\s+|\\s+$", "", FullDash2$cleanDarCountry)
# FullDash2$cleanAccLocality <- gsub("^\\s+|\\s+$", "", FullDash2$cleanAccLocality)
# FullDash2$cleanAccGeography <- gsub("^\\s+|\\s+$", "", FullDash2$cleanAccGeography)
# FullDash2$cleanDarContinent <- gsub("^\\s+|\\s+$", "", FullDash2$cleanDarContinent)
# FullDash2$cleanDarContinentOcean <- gsub("^\\s+|\\s+$", "", FullDash2$cleanDarContinentOcean)
# FullDash2$cleanDarWaterBody <- gsub("^\\s+|\\s+$", "", FullDash2$cleanDarWaterBody)
# AccGeographyLUT$WhereLUT <- gsub("^\\s+|\\s+$", "", AccGeographyLUT$WhereLUT)

FullDash2$cleanAccLocality <- gsub(" ", " | ", FullDash2$cleanAccLocality)
FullDash2$cleanAccGeography <- gsub(" ", " | ", FullDash2$cleanAccGeography)
AccGeographyLUT$WhereLUT <- gsub(" ", " | ", AccGeographyLUT$WhereLUT)


print(paste("... ",substr(date(), 12, 19), "- really cleaning WHERE data (starting simpleCap)..."))

# CleanCap <- c("cleanDarCountry", "cleanAccLocality", "cleanAccGeography",
#               "cleanDarContinent", "cleanDarContinentOcean", "cleanDarWaterBody")
# FullDash2[,colnames(FullDash2) %in% CleanCap] <- sapply(FullDash2[,colnames(FullDash2) %in% CleanCap], simpleCap)


FullDash2$cleanDarCountry <- sapply (FullDash2$cleanDarCountry, simpleCap)
FullDash2$cleanAccLocality <- sapply (FullDash2$cleanAccLocality, simpleCap)
FullDash2$cleanAccGeography <- sapply (FullDash2$cleanAccGeography, simpleCap)
print(paste("... ",substr(date(), 12, 19), "- still cleaning WHERE data..."))
FullDash2$cleanDarContinent <- sapply (FullDash2$cleanDarContinent, simpleCap)
FullDash2$cleanDarContinentOcean <- sapply (FullDash2$cleanDarContinentOcean, simpleCap)
FullDash2$cleanDarWaterBody <- sapply (FullDash2$cleanDarWaterBody, simpleCap)
date()

AccGeographyLUT$WhereLUT <- sapply (AccGeographyLUT$WhereLUT, simpleCap)

# FullDash2$cleanDarCountry <- gsub("United States| Usa |^Usa$| Us | U S A |^Us$", "U.S.A.", FullDash2$cleanDarCountry, ignore.case=T)
# FullDash2$cleanDarCountry <- gsub("U\\.s\\.a(\\.|)", "U.S.A.", FullDash2$cleanDarCountry, ignore.case=T)
# FullDash2$cleanDarCountry <- gsub("U\\.s\\.s\\.r", "U.S.S.R", FullDash2$cleanDarCountry, ignore.case=T)
# FullDash2$cleanDarCountry <- gsub("U\\.s\\.", "U.S.", FullDash2$cleanDarCountry, ignore.case=T)
# FullDash2$cleanDarCountry <- gsub("NANA|^Na$", "", FullDash2$cleanDarCountry, ignore.case=T)
# FullDash2$cleanDarCountry <- gsub("\\.\\.", ".", FullDash2$cleanDarCountry, ignore.case=T)
# 
# FullDash2$cleanAccLocality <- gsub("United States| Usa |^Usa$| Us | U S A |^Us$", "U.S.A.", FullDash2$cleanAccLocality, ignore.case=T)
# FullDash2$cleanAccLocality <- gsub("U\\.s\\.a(\\.|)", "U.S.A.", FullDash2$cleanAccLocality, ignore.case=T)
# FullDash2$cleanAccLocality <- gsub("U\\.s\\.s\\.r", "U.S.S.R", FullDash2$cleanAccLocality, ignore.case=T)
# FullDash2$cleanAccLocality <- gsub("U\\.s\\.", "U.S.", FullDash2$cleanAccLocality, ignore.case=T)
# FullDash2$cleanAccLocality <- gsub("NANA|^Na$", "", FullDash2$cleanAccLocality, ignore.case=F)
# FullDash2$cleanAccLocality <- gsub("\\.\\.", ".", FullDash2$cleanAccLocality, ignore.case=T)
# 
# FullDash2$cleanAccGeography <- gsub("United States| Usa |^Usa$| Us |^Us$", "U.S.A.", FullDash2$cleanAccGeography, ignore.case=T)
# FullDash2$cleanAccGeography <- gsub("U\\.s\\.a(\\.|)", "U.S.A.", FullDash2$cleanAccGeography, ignore.case=T)
# FullDash2$cleanAccGeography <- gsub("U\\.s\\.s\\.r", "U.S.S.R", FullDash2$cleanAccGeography, ignore.case=T)
# FullDash2$cleanAccGeography <- gsub("U\\.s\\.", "U.S.", FullDash2$cleanAccGeography, ignore.case=T)
# FullDash2$cleanAccGeography <- gsub("NANA|^Na$", "", FullDash2$cleanAccGeography, ignore.case=F)
# FullDash2$cleanAccGeography <- gsub("\\.\\.", ".", FullDash2$cleanAccGeography, ignore.case=T)
# date()
# 
# AccGeographyLUT$WhereLUT <- gsub("United States| Usa |^Usa$| Us |^Us$", "U.S.A.", AccGeographyLUT$WhereLUT, ignore.case=T)
# AccGeographyLUT$WhereLUT <- gsub("U\\.s\\.a(\\.|)", "U.S.A.", AccGeographyLUT$WhereLUT, ignore.case=T)
# AccGeographyLUT$WhereLUT <- gsub("U\\.s\\.s\\.r", "U.S.S.R", AccGeographyLUT$WhereLUT, ignore.case=T)
# AccGeographyLUT$WhereLUT <- gsub("U\\.s\\.", "U.S.", AccGeographyLUT$WhereLUT, ignore.case=T)
# AccGeographyLUT$WhereLUT <- gsub("NANA|^Na$", "", AccGeographyLUT$WhereLUT, ignore.case=F)
# AccGeographyLUT$WhereLUT <- gsub("\\.\\.", ".", AccGeographyLUT$WhereLUT, ignore.case=T)


print(paste("... ",substr(date(), 12, 19), "- uniting WHERE data..."))

# Concat 'Where' data ####
FullDash3 <- unite(FullDash2, "Where", cleanDarCountry:cleanDarWaterBody, sep=" | ", remove=TRUE)
FullDash3 <- subset(FullDash3, select=-c(DarCountry, DarContinent, DarContinentOcean, DarWaterBody, AccLocality, AccGeography))

print(paste("... ",substr(date(), 12, 19), "- final cleanup for united WHERE data..."))

FullDash3$Where <- sapply(FullDash3$Where, finalClean)
FullDash3$Where[which(grepl("[[:alpha:]]",FullDash3$Where)<1)] <- ""



FullDash3$HasMM <- as.integer(FullDash3$MulHasMultiMedia)
FullDash3$irn <- as.integer(FullDash3$irn)
FullDash3$Backlog <- as.integer(FullDash3$Backlog)

FullDash3 <- unique(FullDash3[which(nchar(FullDash3$DarGlobalUniqueIdentifier)>2),])
#FullDash3csv <- FullDash3csv[order(-rank(FullDash3$RecordType),FullDash3$irn),]

#NROW(FullDash3csv[which(FullDash3csv$Backlog>0),])


# Start setting up export CSV ####
# FullDash7csv <- FullDash3[,c("irn","DarLatitude","DarLongitude","Where","CatFull","DarIndividualCount","Backlog")]
FullDash3csv <- FullDash3[,c("DarGlobalUniqueIdentifier","DarLatitude","DarLongitude","Where",
                             "Quality","RecordType","Backlog","TaxIDRank",
                             "DarCollectionCode","HasMM",
                             "DarInstitutionCode")]

print(paste("... ",substr(date(), 12, 19), "- set integer fields (irn, HasMM, Backlog)..."))
# # FullDash3csv$Where <- gsub(" \\|  \\|  \\|  \\|  \\| ", "", FullDash3csv$Where)
# FullDash3csv$Where <- gsub("(\\s+\\|)+", " |", FullDash3csv$Where)
# # FullDash3csv$Where <- gsub("( |)NANA \\|", "", FullDash3csv$Where)
# FullDash3csv$Where <- gsub("NANA| Na$", "", FullDash3csv$Where)
# FullDash3csv$Where <- gsub("\\s+Na\\s+", " ", FullDash3csv$Where)
# FullDash3csv$Where <- gsub("\\s+", " ", FullDash3csv$Where)
# #FullDash3csv$Where <- gsub("\\|\\s+\\|","",FullDash3csv$Where)
# FullDash3csv$Where <- gsub("(\\|\\s+\\|)+","|",FullDash3csv$Where)
# FullDash3csv$Where[which(grepl("[[:alpha:]]",FullDash3csv$Where)<1)] <- ""



# TEMP WHERE EXPORT ####
#write.csv(FullDash3csv, file = "FullDash6.csv", na="NULL", row.names = FALSE)


print(paste("... ",substr(date(), 12, 19), "- building WHERE lookup table..."))
# Build Where LUTs ####

WhereLUT1 <- data.frame("WhereLUT" = levels(as.factor(FullDash2$cleanDarContinent)), stringsAsFactors = F)
WhereLUT2 <- data.frame("WhereLUT" = levels(as.factor(FullDash2$cleanDarContinentOcean)), stringsAsFactors = F)

WhereLUT3 <- data.frame("WhereLUT" = FullDash2$cleanDarCountry[which(nchar(FullDash2$cleanDarCountry)>1)], stringsAsFactors = F)
WhereLUT3$WhereLUT[which(grepl("[[:alpha:]]",WhereLUT3$WhereLUT)<1)] <- ""
WhereL3count <- dplyr::count(WhereLUT3, WhereLUT)
WhereL3count <- WhereL3count[which(WhereL3count$n>150),]
WhereLUT3 <- unique(WhereLUT3[which(WhereLUT3$WhereLUT %in% WhereL3count$WhereLUT),])
WhereLUT3 <- strsplit(as.character(WhereLUT3), split="\\|")
WhereLUT3 <- data.frame("WhereLUT" = unique(unlist(WhereLUT3)), stringsAsFactors = F)
WhereLUT3$WhereLUT <- sapply(WhereLUT3$WhereLUT, simpleCap)  # does this LUT-cleanup break matches to record data?

WhereLUT4 <- data.frame("WhereLUT" = levels(as.factor(FullDash2$cleanDarWaterBody)), stringsAsFactors = F)

#WhereLUT5 <- data.frame("WhereLUT" = levels(as.factor(FullDash2$cleanAccLocality)), stringsAsFactors = F)
WhereLUT5 <- strsplit(FullDash2$cleanAccLocality[which(nchar(FullDash2$cleanAccLocality)>2)], "\\|")
WhereLUT5$WhereLUT <- gsub(paste(CutFirst, collapse="|"), "", WhereLUT5$WhereLUT, ignore.case = T)
CutWordsNoSpace <- gsub("\\s+", "", CutWords)
WhereLUT5$WhereLUT <- gsub(paste(CutWordsNoSpace, collapse="|"), "", WhereLUT5$WhereLUT, ignore.case = T)
WhereLUT5 <- unlist(WhereLUT5)
WhereLUT5 <- gsub("\\s+", "", WhereLUT5)
WhereLUT5 <- gsub("^Usa$|^Ussr$", "", WhereLUT5)
WhereLUT5 <- data.frame("WhereLUT"=WhereLUT5[which(nchar(WhereLUT5)>2 & is.na(WhereLUT5)==FALSE)], stringsAsFactors = F)
WhereL5count <- dplyr::count(WhereLUT5, WhereLUT)
WhereL5count <- WhereL5count[which(WhereL5count$n > 5),]
WhereLUT5 <- data.frame("WhereLUT"=unique(WhereLUT5[which(WhereLUT5$WhereLUT %in% WhereL5count$WhereLUT),]))

WhereLUT6 <- data.frame("WhereLUT" = AccGeographyLUT$WhereLUT, stringsAsFactors = F)
WhereLUT6 <- strsplit(AccGeographyLUT$WhereLUT[which(nchar(AccGeographyLUT$WhereLUT)>2)], "\\|")
WhereLUT6$WhereLUT <- gsub(paste(CutFirst, collapse="|"), "", WhereLUT6$WhereLUT, ignore.case = T)
WhereLUT6$WhereLUT <- gsub(paste(CutWordsNoSpace, collapse="|"), "", WhereLUT6$WhereLUT, ignore.case = T)
WhereLUT6 <- unlist(WhereLUT6)
WhereLUT6 <- gsub("\\s+", "", WhereLUT6)
WhereLUT6 <- gsub("^Usa$|^Ussr$", "", WhereLUT6)
WhereLUT6 <- data.frame("WhereLUT"=WhereLUT6[which(nchar(WhereLUT6)>2 & is.na(WhereLUT6)==FALSE)], stringsAsFactors = F)
WhereL6count <- dplyr::count(WhereLUT6, WhereLUT)
WhereL6count <- WhereL5count[which(WhereL6count$n > 1),]
WhereLUT6 <- data.frame("WhereLUT"=unique(WhereLUT6[which(WhereLUT6$WhereLUT %in% WhereL6count$WhereLUT),]))


WhereLUTall <- rbind(OIlut_where, # need extra cleanup?
                     WhereLUT1, WhereLUT2, WhereLUT3, WhereLUT4, WhereLUT5, WhereLUT6)# ADD AccWhereLUT
#WhereLUTall$WhereLUT[which(substr(WhereLUTall$WhereLUT,1,1)==" ")] <- substr(WhereLUTall$WhereLUT[which(substr(WhereLUTall$WhereLUT,1,1)==" ")],2,nchar(WhereLUTall$WhereLUT[which(substr(WhereLUTall$WhereLUT,1,1)==" ")]))
#WhereLUTall$WhereLUT[which(substr(WhereLUTall$WhereLUT,nchar(WhereLUTall$WhereLUT),nchar(WhereLUTall$WhereLUT))==" ")] <- substr(WhereLUTall$WhereLUT[which(substr(WhereLUTall$WhereLUT,nchar(WhereLUTall$WhereLUT),nchar(WhereLUTall$WhereLUT))==" ")],1,nchar(WhereLUTall$WhereLUT[which(substr(WhereLUTall$WhereLUT,nchar(WhereLUTall$WhereLUT),nchar(WhereLUTall$WhereLUT))==" ")])-1)
WhereLUTall$WhereLUT <- gsub("^\\s+|\\s+$", "", WhereLUTall$WhereLUT)
WhereLUTall$WhereLUT <- gsub("^\\'|\\.|\\'$", "", WhereLUTall$WhereLUT)
WhereLUTall$WhereLUT <- gsub("United States| Usa |^Usa$| Usa$| Us |^Us$| Us$", "U.S.A.", WhereLUTall$WhereLUT, ignore.case=T)
WhereLUTall$WhereLUT <- gsub("NANA|^Na$", "", WhereLUTall$WhereLUT, ignore.case=F)
WhereLUTall$WhereLUT <- gsub("Localities In |No Data|^Aisa$", "", WhereLUTall$WhereLUT, ignore.case=T)
WhereLUTall$WhereLUT[which(grepl("[[:alpha:]]",WhereLUTall$WhereLUT)<1)] <- ""
WhereLUTall <- data.frame("WhereLutClean" = unique(WhereLUTall$WhereLUT[which(nchar(WhereLUTall$WhereLUT)>1)]))
WhereLUTall <- data.frame("WhereLutClean"=as.character(WhereLUTall[order(WhereLUTall$WhereLutClean),]), stringsAsFactors = F)
rm("WhereLUT1", "WhereLUT2", "WhereLUT3", "WhereLUT4", "WhereLUT5", "WhereLUT6")

Log021Where <- warnings()

# reset working directory
setwd(origdir)
