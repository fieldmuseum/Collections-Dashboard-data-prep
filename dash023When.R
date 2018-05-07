## EMu Data Prep Script -- Collections Dashboard
# Setup "When" data

print(paste(date(), "-- ...finished setting up WHAT.   Starting dash023When.R"))

# point to csv's directory
setwd(paste0(origdir,"/data01raw"))


# Add Collection URLs (from enarratives) ####
setwd(paste0(origdir,"/supplementary"))
collURL <- read.csv(file="CollDashEd.csv", stringsAsFactors = F)
setwd(paste0(origdir,"/data01raw"))

collURL <- collURL[,c("DesSubjects", "MulIdentifier")] 
colnames(collURL)[1] <- "DarCollectionCode"
colnames(collURL)[2] <- "URL"
collURL$DarInstitutionCode = "FMNH"

# Also need to filter by Institution
FullDash5csv <- merge(FullDash4csv, collURL, by=c("DarCollectionCode", "DarInstitutionCode"), all.x=T)


#  WhenAge LUTs ####
#  1-When: Clean "When" fields

WhenDash <- FullDash3[,c("DarGlobalUniqueIdentifier", "RecordType", "DarInstitutionCode", 
                         "DarEarliestEon", "DarEarliestEra", "DarEarliestPeriod",
                         "DarEarliestEpoch", "DarEarliestAge", "AttPeriod_tab"
                         # "DarYearCollected"
                         # "AccDescription", "AccDescription2"
                         )]


print(paste("... ",substr(date(), 12, 19), "- cleaning WHEN data fields..."))

date() 
WhenDash[,4:NCOL(WhenDash)] <- sapply(WhenDash[,4:NCOL(WhenDash)], function (x) gsub("[[:punct:]]", " ", x))
WhenDash[,4:NCOL(WhenDash)] <- sapply(WhenDash[,4:NCOL(WhenDash)], function (x) gsub("\\s+", " ", x))
WhenDash[,4:NCOL(WhenDash)] <- sapply(WhenDash[,4:NCOL(WhenDash)], function (x) gsub("^\\s+|\\s+$", "", x))
date()


WhenDash$AttPeriod_tab <- sapply (WhenDash$AttPeriod_tab, simpleCap)
WhenDash$AttPeriod_tab <- gsub("^Na$", "", WhenDash$AttPeriod_tab)
WhenDash$AttPeriod_tab[which(grepl("[Dd]ynasty", WhenDash$AttPeriod_tab)<1 & grepl("\\d+th |\\d+nd |\\d+st ", WhenDash$AttPeriod_tab)>0)] <- gsub("th|nd|st", "00", WhenDash$AttPeriod_tab[which(grepl("[Dd]ynasty", WhenDash$AttPeriod_tab)<1 & grepl("\\d+th |\\d+nd |\\d+st ", WhenDash$AttPeriod_tab)>0)])
#WhenDash$AttPeriod_tab <- gsub(" Century| Cent$| Cent | c$| C$", "", WhenDash$AttPeriod_tab)
WhenDash$AttPeriod_tab <- gsub(" A D$", " Ad", WhenDash$AttPeriod_tab)
WhenDash$AttPeriod_tab <- gsub(" B C$", " Bc", WhenDash$AttPeriod_tab)
date()


#  2-When: calculate numeric date
#WhenDash$DateFrom <- as.numeric(WhenDash$AttPeriod_tab)
WhenDash$Date <- as.numeric(0)
WhenDash$Date[which(grepl("[Dd]ynasty", WhenDash$AttPeriod_tab)<1)] <- gsub("[[:alpha:]]", "", WhenDash$AttPeriod_tab[which(grepl("[Dd]ynasty", WhenDash$AttPeriod_tab)<1)])
WhenDash$Date[which(grepl("\\d{3,4}", WhenDash$AttPeriod_tab)>0)] <- gsub("[[:alpha:]]", "", WhenDash$AttPeriod_tab[which(grepl("\\d{3,4}", WhenDash$AttPeriod_tab)>0)])

AttPerLUT <- data.frame("AttPer" = levels(as.factor(WhenDash$AttPeriod_tab[which(WhenDash$DateFrom==0)])))
AttCheck <- dplyr::count(WhenDash, AttPeriod_tab)
AttCheck2 <- AttCheck[which(AttCheck$AttPeriod_tab %in% AttPerLUT$AttPer),]

WhenDash$Date <- gsub("\\s+", " ", WhenDash$Date)
WhenDash$Date <- gsub("^\\s+|\\s+$", "", WhenDash$Date)

WhenDash <- WhenDash %>% separate(Date, c("DateFrom", "DateTo"), sep=" ", extra="merge")
# Warnings about "Missing pieces filled with 'NA'" are normal here.

WhenDash$DateFrom <- as.numeric(WhenDash$DateFrom)  # Warning about "NAs introduced by coercion" is normal. 
WhenDash$DateTo <- as.numeric(WhenDash$DateTo)      # Warning about "NAs introduced by coercion" is normal.
WhenDash$DateFrom[which(grepl("[Bb]c", WhenDash$AttPeriod_tab)>0)] <- -1 * WhenDash$DateFrom[which(grepl("[Bb]c", WhenDash$AttPeriod_tab)>0)]
WhenDash$DateTo[which(grepl("[Bb]c", WhenDash$AttPeriod_tab)>0)] <- -1 * WhenDash$DateTo[which(grepl("[Bb]c", WhenDash$AttPeriod_tab)>0)]
print("Warning about 'Missing pieces filled with NA' is normal here")


AttPerLUT <- as.data.frame(levels(as.factor(WhenDash$AttPeriod_tab[which((abs(WhenDash$DateFrom + WhenDash$DateTo)<1 | is.na(WhenDash$DateFrom)+is.na(WhenDash$DateTo)==2) & nchar(WhenDash$AttPeriod_tab)>2)])))
AttPerLUT2 <- dplyr::count(WhenDash, AttPeriod_tab)
AttPerLUT2 <- AttPerLUT2[which(AttPerLUT2$n>100),]

# # # # # # # # 

# 00 -- TOO MUCH; one more pass to clean AttPeriod_tab -- WD$AttPeriod_tab[which(grepl(kinda matches WhenLUT)>0] -- leave messy data as is

# 0 -- merge geo & anthro Chrono & AttPer fields --> one column, WhenAge

WhenDash$DarEarliestEon[which(nchar(WhenDash$DarEarliestEon)<3)] = NA
WhenDash$DarEarliestEra[which(nchar(WhenDash$DarEarliestEra)<3)] = NA
WhenDash$DarEarliestPeriod[which(nchar(WhenDash$DarEarliestPeriod)<3)] = NA
WhenDash$DarEarliestEpoch[which(nchar(WhenDash$DarEarliestEpoch)<3)] = NA
WhenDash$DarEarliestAge[which(nchar(WhenDash$DarEarliestAge)<3)] = NA
WhenDash$col <- 0
WhenDash$col <- is.na(WhenDash$DarEarliestEon) + is.na(WhenDash$DarEarliestEra) + is.na(WhenDash$DarEarliestPeriod) + is.na(WhenDash$DarEarliestEpoch) + is.na(WhenDash$DarEarliestAge)
WhenDash$WhenAge <- ""
WhenDash$WhenAge[which(WhenDash$col==0)] <- WhenDash$DarEarliestAge[which(WhenDash$col==0)]
WhenDash$WhenAge[which(WhenDash$col==1)] <- WhenDash$DarEarliestEpoch[which(WhenDash$col==1)]
WhenDash$WhenAge[which(WhenDash$col==2)] <- WhenDash$DarEarliestPeriod[which(WhenDash$col==2)]
WhenDash$WhenAge[which(WhenDash$col==3)] <- WhenDash$DarEarliestEra[which(WhenDash$col==3)]
WhenDash$WhenAge[which(WhenDash$col==4)] <- WhenDash$DarEarliestEon[which(WhenDash$col==4)]

WhenDash$AttPeriod_tab[which(nchar(WhenDash$AttPeriod_tab)<2 | WhenDash$AttPeriod_tab=="NANA")] = NA
WhenDash$WhenAge[which(is.na(WhenDash$AttPeriod_tab)==F)] <- WhenDash$AttPeriod_tab[which(is.na(WhenDash$AttPeriod_tab)==F)]


# Add in / Fix up When-Dates
# fill in missing dates by:


print(paste("... ",substr(date(), 12, 19), "- building WHEN lookup table..."))

# Merge WhenLUTs ####
setwd(paste0(origdir,"/supplementary"))
AgeAnthroLUT <- read.csv(file="WhenAttPerLUT.csv", stringsAsFactors = F)
AgeGeoLUT <- read.csv(file="WhenChronoLUTemu.csv", stringsAsFactors = F)
setwd(paste0(origdir,"/data01raw"))

AgeGeoLUT$Eon[which(nchar(AgeGeoLUT$Eon)<1)] = NA
AgeGeoLUT$Era[which(nchar(AgeGeoLUT$Era)<1)] = NA
AgeGeoLUT$Period[which(nchar(AgeGeoLUT$Period)<1)] = NA
AgeGeoLUT$Epoch[which(nchar(AgeGeoLUT$Epoch)<1)] = NA
AgeGeoLUT$Age[which(nchar(AgeGeoLUT$Age)<1)] = NA
AgeGeoLUT$col <- 0
AgeGeoLUT$col <- is.na(AgeGeoLUT$Eon) + is.na(AgeGeoLUT$Era) + is.na(AgeGeoLUT$Period) + is.na(AgeGeoLUT$Epoch) + is.na(AgeGeoLUT$Age)
AgeGeoLUT$WhenLUT <- ""
AgeGeoLUT$WhenLUT[which(AgeGeoLUT$col==0)] <- AgeGeoLUT$Age[which(AgeGeoLUT$col==0)]
AgeGeoLUT$WhenLUT[which(AgeGeoLUT$col==1)] <- AgeGeoLUT$Epoch[which(AgeGeoLUT$col==1)]
AgeGeoLUT$WhenLUT[which(AgeGeoLUT$col==2)] <- AgeGeoLUT$Period[which(AgeGeoLUT$col==2)]
AgeGeoLUT$WhenLUT[which(AgeGeoLUT$col==3)] <- AgeGeoLUT$Era[which(AgeGeoLUT$col==3)]
AgeGeoLUT$WhenLUT[which(AgeGeoLUT$col==4)] <- AgeGeoLUT$Eon[which(AgeGeoLUT$col==4)]

AgeGeoLUT2 <- unique(AgeGeoLUT[which(is.na(AgeGeoLUT$WhenLUT)==F),c("WhenLUT", "DateFrom", "DateTo")])
AgeGeoLUT2$DateFrom[which(AgeGeoLUT2$WhenLUT=="Eoarchean")] <- -4000000000
AgeGeoLUT2$DateFrom[which(AgeGeoLUT2$WhenLUT=="Archean")] <- -4000000000
AgeGeoLUT2$WhenLUT <- sapply(AgeGeoLUT2$WhenLUT, function (x) gsub("[[:punct:]]", " ", x))
AgeGeoLUT2$WhenLUT <- sapply(AgeGeoLUT2$WhenLUT, function (x) gsub("\\s+", " ", x))
AgeGeoLUT2$WhenLUT <- sapply(AgeGeoLUT2$WhenLUT, function (x) gsub("^\\s+|\\s+$", " ", x))


#AttPeriodLUT <- data.frame("WhenLUT" = levels(as.factor(WhenDash$AttPeriod_tab)), stringsAsFactors = F)
#AttPeriodLUT <- unique(AttPeriodLUT)

WhenAgeLUT <- rbind(AgeGeoLUT2, AgeAnthroLUT)
WhenAgeLUT <- unique(WhenAgeLUT)
WhenAgeLUTcheck <- dplyr::count(WhenAgeLUT, WhenLUT)
WhenAgeLUTcheck <- WhenAgeLUTcheck[which(WhenAgeLUTcheck$n>1),]
WhenAgeLUT <- WhenAgeLUT[order(WhenAgeLUT$WhenLUT),]
WhenAgeLUT$seq <- sequence(rle(as.character(WhenAgeLUT$WhenLUT))$lengths)
WhenAgeLUT <- WhenAgeLUT[which(WhenAgeLUT$seq==1),]
WhenAgeLUT <- WhenAgeLUT[,-4]
WhenAgeLUT$WhenLUT <- sapply (WhenAgeLUT$WhenLUT, simpleCap)



WhenDash2 <- merge(WhenDash, WhenAgeLUT, by.x="WhenAge", by.y="WhenLUT", all.x=T)

NROW(WhenDash2[which(abs(WhenDash2$DateFrom.x)<1),])
NROW(WhenDash2[which(abs(WhenDash2$DateTo.x)<1),])

WhenDash2$DateFrom.x[which(abs(WhenDash2$DateFrom.x)<1 | is.na(WhenDash2$DateFrom.x)==T)] <- WhenDash2$DateFrom.y[which(abs(WhenDash2$DateFrom.x)<1  | is.na(WhenDash2$DateFrom.x)==T)]
WhenDash2$DateTo.x[which(abs(WhenDash2$DateTo.x)<1 | is.na(WhenDash2$DateTo.x)==T)] <- WhenDash2$DateTo.y[which(abs(WhenDash2$DateTo.x)<1 | is.na(WhenDash2$DateTo.x)==T)]
WhenDash2$DateFrom.x[which((abs(WhenDash2$DateFrom.x)<1 | is.na(WhenDash2$DateFrom.x)==T) & abs(WhenDash2$DateTo.x)>0)] <- WhenDash2$DateTo.x[which((abs(WhenDash2$DateFrom.x)<1 | is.na(WhenDash2$DateFrom.x)==T) & abs(WhenDash2$DateTo.x)>0)]

WhenDash2$DateTo.x[which(abs(WhenDash2$DateFrom.x)>0 & abs(WhenDash2$DateTo.x)<1)] <- WhenDash2$DateFrom.x[which(abs(WhenDash2$DateFrom.x)>0 & abs(WhenDash2$DateTo.x)<1)]
#WhenDash2$DateFrom.x[which(abs(WhenDash2$DateTo.x)>0 & abs(WhenDash2$DateTo.x)<1)] <- WhenDash2$DateFrom.x[which(abs(WhenDash2$DateFrom.x)>0 & abs(WhenDash2$DateTo.x)<1)]

NROW(WhenDash2[which(abs(WhenDash2$DateFrom.x)<1),])
NROW(WhenDash2[which(abs(WhenDash2$DateTo.x)<1),])

WhenDash2$WhenAgeFrom <- WhenDash2$DateFrom.x
WhenDash2$WhenAgeTo <- WhenDash2$DateTo.x


#WhenDash3 <- unite(WhenDash2, "WhenAge", DarEarliestEon:AccDescription2, sep=" | ", remove=TRUE)
WhenDash3 <- unite(WhenDash2, "WhenAge2", DarEarliestEon:AttPeriod_tab, sep=" | ", remove=TRUE)
WhenDash3 <- WhenDash3[,c("DarGlobalUniqueIdentifier", "WhenAge2", "WhenAgeFrom", "WhenAgeTo")]
colnames(WhenDash3)[2] <- "WhenAge"

#WhenDash3$WhenAge <- gsub("NA \\| ", "", WhenDash3$WhenAge)
#WhenDash3$WhenAge <- gsub(" \\| NA", "", WhenDash3$WhenAge)
WhenDash3$WhenAge <- gsub("NA", "", WhenDash3$WhenAge)
WhenDash3$WhenAge <- gsub("\\s+", " ", WhenDash3$WhenAge)
WhenDash3$WhenAge <- gsub("^\\s+|\\s+$", "", WhenDash3$WhenAge)
WhenDash3$WhenAge <- gsub("(\\|\\s+)+","| ",WhenDash3$WhenAge)
WhenDash3$WhenAge <- gsub("^\\|\\s+\\|$","",WhenDash3$WhenAge)

# Make sure AgeFrom = Min & AgeTo = Max
WhenDash3$WhenAgeMin <- pmin(WhenDash3$WhenAgeFrom,WhenDash3$WhenAgeTo)
WhenDash3$WhenAgeMax <- pmax(WhenDash3$WhenAgeFrom,WhenDash3$WhenAgeTo)
# Calculate mid-point of Age
WhenDash3$WhenAgeMid <-  WhenDash3$WhenAgeMin + 0.5 * (WhenDash3$WhenAgeMax - WhenDash3$WhenAgeMin)

# Replace From/To data 
WhenDash3$WhenAgeFrom <- WhenDash3$WhenAgeMin
WhenDash3$WhenAgeTo <- WhenDash3$WhenAgeMax
# Drop Min/Max columns
WhenDash3 <- dplyr::select(WhenDash3, -c(WhenAgeMin,WhenAgeMax))


# Include Zoo & Bot collections' ages (from DarYearCollected)
# 1 - Merge Department column
setwd(paste0(origdir, "/supplementary"))
Depts <- read.csv(file="Departments.csv", stringsAsFactors = F)
Depts2 <- CatDash3[,c("DarGlobalUniqueIdentifier","DarCollectionCode","DarYearCollected")]
Depts3 <- merge(Depts2, Depts, by=c("DarCollectionCode"), all.x=T)
Depts3 <- Depts3[,c("DarGlobalUniqueIdentifier","DarYearCollected","Department")]

setwd(paste0(origdir,"/data01raw"))

WhenDash4 <- merge(WhenDash3, Depts3, by=c("DarGlobalUniqueIdentifier"), all.x=T)
rm(Depts, Depts2, Depts3)

#WhenDash4$WhenAge[which(WhenDash4$Department=="Botany" | WhenDash4$Department=="Zoology")] <- WhenDash4$DarYearCollected[which(WhenDash4$Department=="Botany" | WhenDash4$Department=="Zoology")]
WhenDash4$WhenAgeFrom[which(WhenDash4$Department=="Botany" | WhenDash4$Department=="Zoology")] <- WhenDash4$DarYearCollected[which(WhenDash4$Department=="Botany" | WhenDash4$Department=="Zoology")]
WhenDash4$WhenAgeTo[which(WhenDash4$Department=="Botany" | WhenDash4$Department=="Zoology")] <- WhenDash4$DarYearCollected[which(WhenDash4$Department=="Botany" | WhenDash4$Department=="Zoology")]
WhenDash4$WhenAgeMid[which(WhenDash4$Department=="Botany" | WhenDash4$Department=="Zoology")] <- WhenDash4$DarYearCollected[which(WhenDash4$Department=="Botany" | WhenDash4$Department=="Zoology")]


# Add in AgePeriod Order & Name for WhenAge chart
setwd(paste0(origdir, "/supplementary"))
WhenChart <- read.csv("WhenYearRanges2.csv", stringsAsFactors = F)
setwd(paste0(origdir,"/data01raw"))

colnames(WhenChart)[4] <- "TimePeriodName"

WhenDash4$Order <- .bincode(WhenDash4$WhenAgeMid, WhenChart$From, right=F, include.lowest = T)

WhenChart <- WhenChart[,3:4]
WhenDash5 <- merge(WhenDash4, WhenChart, by="Order", all.x=T)
colnames(WhenDash5)[c(1,NCOL(WhenDash5))] <- c("WhenOrder","WhenTimeLabel")

# Add/Modify WhenAge for Biological collections; bin by decade
WhenDash5$WhenAge[which(WhenDash5$Department=="Botany" | WhenDash5$Department=="Zoology")] <- WhenDash5$WhenTimeLabel[which(WhenDash5$Department=="Botany" | WhenDash5$Department=="Zoology")]

# Setup bio-Age luts

BioAgeLUT <- data.frame("WhenLUT" = unique(WhenDash5$WhenTimeLabel[which((WhenDash5$Department=="Botany" | WhenDash5$Department=="Zoology")
                                                                        # & WhenDash5$Order>0 
                                                                         & as.numeric(WhenDash5$WhenTimeLabel)>1850
                                                                         & as.numeric(WhenDash5$DarYearCollected)<2018)]), stringsAsFactors = F)
BioAgeLUT$DateFrom <- as.integer(BioAgeLUT$WhenLUT)
BioAgeLUT$DateTo <- as.integer(BioAgeLUT$WhenLUT)


WhenDash5 <- select(WhenDash5, -Department)


WhenDash5$WhenAgeFrom[is.na(WhenDash5$WhenAgeFrom)==T] <- ""
WhenDash5$WhenAgeFrom[which((WhenDash5$WhenAgeFrom)=="NA")] <- ""
WhenDash5$WhenAgeTo[is.na(WhenDash5$WhenAgeTo)==T] <- ""
WhenDash5$WhenAgeTo[which((WhenDash5$WhenAgeTo)=="NA")] <- ""
WhenDash5$WhenAgeMid[is.na(WhenDash5$WhenAgeMid)==T] <- ""
WhenDash5$WhenAgeMid[which((WhenDash5$WhenAgeMid)=="NA")] <- ""

WhenDash5$WhenOrder[is.na(WhenDash5$WhenOrder)==T] <- ""
WhenDash5$WhenOrder[which((WhenDash5$WhenOrder)=="NA")] <- ""

WhenDash5$WhenTimeLabel[is.na(WhenDash5$WhenTimeLabel)==T] <- ""
WhenDash5$WhenTimeLabel[which((WhenDash5$WhenTimeLabel)=="NA")] <- ""

WhenDash5$DarYearCollected[is.na(WhenDash5$DarYearCollected)==T] <- ""
WhenDash5$DarYearCollected[which((WhenDash5$DarYearCollected)=="NA")] <- ""


# Append Bot/Zoo WhenAges to WhenAgeLUT

WhenAgeLUT <- rbind(AgeGeoLUT2, AgeAnthroLUT, BioAgeLUT)
WhenAgeLUT <- unique(WhenAgeLUT)
WhenAgeLUTcheck <- dplyr::count(WhenAgeLUT, WhenLUT)
WhenAgeLUTcheck <- WhenAgeLUTcheck[which(WhenAgeLUTcheck$n>1),]
WhenAgeLUT <- WhenAgeLUT[order(WhenAgeLUT$WhenLUT),]
WhenAgeLUT$seq <- sequence(rle(as.character(WhenAgeLUT$WhenLUT))$lengths)
WhenAgeLUT <- WhenAgeLUT[which(WhenAgeLUT$seq==1),]
WhenAgeLUT <- WhenAgeLUT[,-4]
WhenAgeLUT$WhenLUT <- sapply (WhenAgeLUT$WhenLUT, simpleCap)
WhenAgeLUT <- WhenAgeLUT[order(WhenAgeLUT$WhenLUT),]

# p2 -- &/or re-insert AttPeriod_tab which(grep("\\d{3,4}" ==1) ... smooth that out?


#  3-When: merge WHERE+WHAT+WHEN ####
FullDash6csv <- merge(FullDash5csv, WhenDash5, by=c("DarGlobalUniqueIdentifier"), all.x=T)

# Memory cleanup ####
rm("FullDash4csv", "FullDash5csv")
rm(list = ls(pattern = "WhenDash"))
gc()

Log023When <- warnings()

setwd(origdir)
