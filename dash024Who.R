## EMu Data Prep Script -- Collections Dashboard
# Setup "When" data

print(paste(date(), "-- ...finished setting up WHEN.   Starting dash024Who.R"))

# point to csv's directory
setwd(paste0(origdir,"/data01raw"))


#  Who ####
#  1-Who: Clean "Who" fields

WhoDashBU <- FullDash3[,c("irn", "RecordType","DarInstitutionCode", 
                          "DesEthnicGroupSubgroup_tab", 
                          "AccDescription", "AccDescription2", # might need to cut these?
                          "EcbNameOfObject")]
WhoDash <- WhoDashBU


print(paste("... ",substr(date(), 12, 19), "- cleaning WHO data..."))

date() 
WhoDash[,3:NCOL(WhoDash)] <- sapply(WhoDash[,3:NCOL(WhoDash)], function (x) gsub("^NA$|^'| a |[/()?]|\\[\\]|probably", " ", x, ignore.case = T))
WhoDash[,3:NCOL(WhoDash)] <- sapply(WhoDash[,3:NCOL(WhoDash)], function (x) gsub(",| - |;", " | ", x))
WhoDash[,3:NCOL(WhoDash)] <- sapply(WhoDash[,3:NCOL(WhoDash)], function (x) gsub("\\s+", " ", x))
WhoDash[,3:NCOL(WhoDash)] <- sapply(WhoDash[,3:NCOL(WhoDash)], function (x) gsub("^\\s+|\\s+$", "", x))
WhoDash[,3:NCOL(WhoDash)] <- sapply(WhoDash[,3:NCOL(WhoDash)], function (x) gsub("^NA$|^NANA$", "", x, ignore.case = T))
date()


WhoDash$DesEthnicGroupSubgroup_tab <- gsub("^Na ", "North American ", WhoDash$DesEthnicGroupSubgroup_tab, ignore.case = T)
WhoDash$DesEthnicGroupSubgroup_tab[which(substr(WhoDash$DesEthnicGroupSubgroup_tab,1,1)!="!")] <- sapply(WhoDash$DesEthnicGroupSubgroup_tab[which(substr(WhoDash$DesEthnicGroupSubgroup_tab,1,1)!="!")], simpleCap)

print(paste("... ",substr(date(), 12, 19), "- building WHO lookup table..."))

#  2-Wh0 LUTs ####
# unsplit = 2907
WhoLUT <- data.frame("WhoLUT" = WhoDash$DesEthnicGroupSubgroup_tab[which(nchar(WhoDash$DesEthnicGroupSubgroup_tab)>1 & is.na(WhoDash$DesEthnicGroupSubgroup_tab)==F )], stringsAsFactors = F)
WhoLUT <- strsplit(WhoLUT$WhoLUT, "\\|")
WhoLUT <- data.frame("WhoLUT" = unlist(WhoLUT), stringsAsFactors = F)
WhoLUT$WhoLUT <- gsub("^\\s+|\\s+$", "", WhoLUT$WhoLUT)
WhoCount <- dplyr::count(WhoLUT, WhoLUT)
WhoCount <- WhoCount[which(WhoCount$n > 2),]
WhoLUT <- data.frame("WhoLUT" = unique(WhoLUT[which((WhoLUT$WhoLUT %in% WhoCount$WhoLUT) &
                                                      nchar(WhoLUT$WhoLUT)>1),]),
                     stringsAsFactors = F)
WhoLUT <- data.frame("WhoLUT"=WhoLUT[order(WhoLUT$WhoLUT),], stringsAsFactors = F)


print(paste("... ",substr(date(), 12, 19), "- back to cleaning WHO -- next step takes ~30min..."))


WhoDash$EcbNameOfObject[is.na(WhoDash$EcbNameOfObject)==T] <- ""

WhoDash <- separate(WhoDash, EcbNameOfObject, c("EcbNam1","EcbNam2","EcbNam3","EcbNam4","EcbNam5","EcbNam6"), remove=F)


WhoDash$AccDescription[is.na(WhoDash$AccDescription)==T] <- ""
WhoDash$AccDescription <- gsub("\\|| ", " | ", WhoDash$AccDescription)
WhoDash$AccDescription <- sapply (WhoDash$AccDescription, simpleCap)
date()

WhoDash$AccDescription2[is.na(WhoDash$AccDescription2)==T] <- ""
#WhoDash$AccDescription2 <- gsub("[[:punct:]]", " ", WhoDash$AccDescription2)
WhoDash$AccDescription2 <- gsub("[[:digit:]]+", " ", WhoDash$AccDescription2)
WhoDash$AccDescription2 <- gsub(paste(CutFirst, collapse="|"), " ", WhoDash$AccDescription2, ignore.case = T)
WhoDash$AccDescription2 <- gsub(paste0(CutWords, collapse="|"), " ", WhoDash$AccDescription2, ignore.case = T)
WhoDash$AccDescription2 <- gsub(" [[:alpha:]]{1} ", " ", WhoDash$AccDescription2, ignore.case = T)
WhoDash$AccDescription2 <- gsub("^\\s+|\\s+$", "", WhoDash$AccDescription2)
WhoDash$AccDescription2 <- gsub("\\s+", " ", WhoDash$AccDescription2)
WhoDash$AccDescription2 <- gsub(" ", " | ", WhoDash$AccDescription2)
WhoDash$AccDescription2 <- gsub("(\\|\\s+)+", "| ", WhoDash$AccDescription2)
WhoDash$AccDescription2 <- sapply (WhoDash$AccDescription2, simpleCap)
date()

# This only takes the first 6 words, so likely misses a lot of values, but in the interest of time...
WhoDash <- separate(WhoDash, AccDescription, c("Acc1Nam1","Acc1Nam2","Acc1Nam3","Acc1Nam4","Acc1Nam5","Acc1Nam6"), remove=F)
WhoDash <- separate(WhoDash, AccDescription2, c("Acc2Nam1","Acc2Nam2","Acc2Nam3","Acc2Nam4","Acc2Nam5","Acc2Nam6"), remove=F)


print(paste("... ",substr(date(), 12, 19), "- still cleaning WHO -- next step takes ~50min..."))

date()
WhoDashExt <- WhoDash[,c("irn","RecordType","DarInstitutionCode",
                          "EcbNam1","EcbNam2","EcbNam3","EcbNam4","EcbNam5","EcbNam6",
                          "Acc1Nam1","Acc1Nam2","Acc1Nam3","Acc1Nam4","Acc1Nam5","Acc1Nam6",
                          "Acc2Nam1","Acc2Nam2","Acc2Nam3","Acc2Nam4","Acc2Nam5","Acc2Nam6")]

WhoDashExt <- unite(WhoDashExt, RecIRNInst, irn:DarInstitutionCode, sep="_")
#WhoDashExt <- select(WhoDashExt, -c(irn,RecordType))

WhoDashExt2 <- gather(WhoDashExt, RecIRNInst, "Who", EcbNam1:Acc2Nam6)
#WhoDashExt2 <- WhoDashExt2[,c(1,3)]
WhoDashExt2 <- WhoDashExt2[which(nchar(WhoDashExt2$Who)>1),]  # 53,012,686

WhoDashExt2 <- WhoDashExt2[which(WhoDashExt2$Who %in% WhoLUT$WhoLUT),]

WhoDashExt2 <- unique(WhoDashExt2)
WhoDashExt2 <- WhoDashExt2[order(WhoDashExt2$RecIRNInst),]

if(NROW(WhoDashExt2)>0) {
  WhoDashExt2$WhoSeq <- sequence(rle(as.character(WhoDashExt2$RecIRNInst))$lengths)
  WhoDashExt2 <- WhoDashExt2[,c("RecIRNInst","WhoSeq","Who")]
  WhoDashExt3 <- tidyr::spread(WhoDashExt2, WhoSeq, Who, sep="_")
  
  date()
  
  WhoDashExt3 <- separate(WhoDashExt3, RecIRNInst, c("irn","RecordType","DarInstitutionCode"), sep="_")
  # may need to edit next line if WhoSeq_5 isn't last column
  WhoDashExt3 <- unite(WhoDashExt3, WhoExtra, WhoSeq_1:WhoSeq_5, sep = " | ")
  WhoDashExt3$WhoExtra <- gsub("\\s+NA\\s+|\\s+NA$","",WhoDashExt3$WhoExtra)
  WhoDashExt3$WhoExtra <- gsub("(\\|\\s+)+|\\|+","| ",WhoDashExt3$WhoExtra)
  WhoDashExt3$WhoExtra <- gsub("\\s+\\|\\s+$","",WhoDashExt3$WhoExtra)
  
  date()
  
  
  WhoDash2 <- merge(WhoDash, WhoDashExt3, by=c("irn","RecordType","DarInstitutionCode"), all.x=T)
  WhoDash2 <- WhoDash2[,c("irn","RecordType","DarInstitutionCode","DesEthnicGroupSubgroup_tab","WhoExtra")]
  WhoDash2$WhoExtra[which(is.na(WhoDash2$WhoExtra)==T)] <- ""

  #  3-Concat 'Who' data
  WhoDash2 <- unite(WhoDash2, "Who", DesEthnicGroupSubgroup_tab:WhoExtra, sep=" | ", remove=TRUE)

} else {
  
  WhoDash2 <- WhoDash[,c("irn","RecordType","DarInstitutionCode","DarInstitutionCode","DesEthnicGroupSubgroup_tab")]
  #  alt-3-Concat 'Who' data ####
  colnames(WhoDash2)[4] <- "Who"
  
}  


print(paste("... ",substr(date(), 12, 19), "- cleaning WHO data..."))

#  4-Clean united 'Who' data ####
WhoDash2$Who <- gsub("(\\|\\s+)+", "| ", WhoDash2$Who)
WhoDash2$Who <- gsub("\\s+\\|\\s+$|^\\s+\\|\\s+", "", WhoDash2$Who)
#FullDash3 <- subset(FullDash3, select=-c(DarCountry, DarContinent, DarContinentOcean, DarWaterBody, AccLocality, AccGeography))
WhoDash2$Who <- gsub("^\\s+\\|\\s+$", "", WhoDash2$Who)
WhoDash2$Who <- gsub("^NA$|^NA\\s+\\|\\s+|\\s+\\|\\s+NA$", "", WhoDash2$Who)

#  4-Merge WHERE+WHAT+WHEN-WHO ####
FullDash7csv <- merge(FullDash6csv, WhoDash2, by=c("irn","RecordType","DarInstitutionCode"), all.x=T)

Log024Who <- warnings()

setwd(origdir)
