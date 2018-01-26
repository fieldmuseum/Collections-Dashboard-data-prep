
#[1] "D:/colldash2/collprep"
setwd("./output/")
quickDash <- read.csv("FullDash13.csv", stringsAsFactors = F)
qDchina <- quickDash[which("China" %in% quickDash$Where),]
qDchina <- quickDash[which(grep("China", quickDash$Where)>0,]
#Error: unexpected ']' in "qDchina <- quickDash[which(grep("China", quickDash$Where)>0,]"
#qDchina <- quickDash[which(grep("China", quickDash$Where)>0),]
#View(qDchina)

#NROW(qDchina[which(nchar(qDchina$Who)>0),])
#[1] 261
write.csv(qDchina$Who, file="qDchinaWho.csv", row.names = F, na="")
qDchinaWho <- (qDchina$Who[which(nchar(qDchina$Who)>0)])
write.csv(qDchinaWho, file="qDchinaWho.csv", row.names = F, na="")

write.csv(qDchinaWho, file="qDchinaWho.csv", row.names = F, na="")
write.table(qDchinaWho, file="qDchinaWho.txt", row.names = F, col.names = F, na="")
qDchina <- quickDash[which(nchar(quickDash$Who)>0),]
write.table(quickDash, file="qDallWho.txt", row.names = F, col.names=F,na="")

write.table(quickDash$Who, file="qDallWho.txt", row.names = F, col.names=F,na="")
write.table(qDchina$Who, file="qDallWho.txt", row.names = F, col.names=F,na="")
qdAllCount <- dplyr::count(qDchina, Who)

qdAll2 <- qDchina$Who
qdAll2 <- strsplit(qdAll2, " | ")
qdAll2 <- unlist(qdAll2)
qdAll2 <- data.frame("WhoCount" = qdAll2, stringsAsFactors = F)
qdAllCount2 <- dplyr::count(qdAll2, WhoCount)

qdAll3 <- data.frame("WhoCount" = qdAll2[which(nchar(qdAll2$WhoCount)>1),], stringsAsFactors = F)

qdAllCount3 <- dplyr::count(qdAll3, WhoCount)

write.table(qdAllCount3,file="qdAll3.txt",quote=F,row.names = F,col.names = F,sep=",",na="")
qdAll4 <- as.list(qdAll3)
write.table(qdAll4,file="AllWhoList4.txt",quote=F,row.names = F,col.names = F,sep=",",na="")