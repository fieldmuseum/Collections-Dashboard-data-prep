## collections-dashboard-prep
#  Prep accessions data from EMu for dashboard-prep
#
# 1) In EMu, retrieve Accession records for dashboard, 
#       05-May-2017 dataset includes all efmnhtransactions records retrieved in this query:
#
        # select all
        # from efmnhtransactions
        # where true and
        # (
        #   (TraTransactionType contains 'incoming')
        #   or
        #   (TraTransactionType contains 'outgoing')
        # )
        # or
        # (
        #   (LoaLoanType contains 'incoming')
        #   or
        #   (LoaLoanType contains 'outgoing')
        # )
        # or
        # (TraTransactionType contains '\"Exhibit Loan\"')
        # or
        # (LoaLoanType contains '\"Exhibit Loan\"')
#
# 2) Report them out with "DashboardTran" report
#       - see collections-dashboard "Help" page for details on which fields are included in report
#       - If under 200k records, report all at one time.
#       - Don't rename reported files. Keep them together in one folder.
#
# 3) Run this script  
#       - NOTE: May need to re-set working directory to folder containing reported csv's
#         (see lines 59 & 60)
#


# Filter to only include records where:
#   - date => 2005
#   - Transaction (or Loan) Type = incoming or outgoing  
#        (exhibitions may be included later)
#   - Counts use Items not "Object" fields


print(paste(date(), "-- ...finished setting up Experience data.  Starting dash026LoansPrep.R"))


# point to the directory containing the set of "Group" csv's from EMu
setwd(paste0(origdir,"/data01raw/emuLoans"))


# Import raw EMu Accession data ####
Loan1 <- read.csv(file="efmnhtra.csv", stringsAsFactors = F)

# Ignore these for now -- but here in case detail is needed later
#temp = list.files(path=".", pattern=".csv")
#list2env(
#  lapply(setNames(temp, make.names(temp)), 
#         read.csv), envir = .GlobalEnv)

##  May need to convert efmnhtra.csv fields to as.character if import in batch

##Group1.csv <- Group1.csv[,-1]
##Group1.csv$row <- sequence(rle(as.character(InvCount.csv$efmnhtransactions_key))$lengths)
##Group1.csv <- spread(InvCount.csv, row, InvCount, sep="_")
#
#InvCount.csv <- InvCount.csv[,-1]
#InvDescr.csv <- InvDescr.csv[,-1]
#InvGeogr.csv <- InvGeogr.csv[,-1]
#InvTrans.csv <- InvTrans.csv[,-1]
#
#InvCount.csv$row <- sequence(rle(as.character(InvCount.csv$efmnhtransactions_key))$lengths)
#InvCount1 <- spread(InvCount.csv, row, InvCount, sep="_")
##InvCount1$sumInv <- summarise(InvCount1, sumItems = row_1+row_2+row_3+row_4+row_5)
#
#InvDescr.csv$row <- sequence(rle(as.character(InvDescr.csv$efmnhtransactions_key))$lengths)
#InvDescr1 <- spread(InvDescr.csv, row, InvDescription, sep="_")
#
#InvGeogr.csv$row <- sequence(rle(as.character(InvGeogr.csv$efmnhtransactions_key))$lengths)
#InvGeogr1 <- spread(InvGeogr.csv, row, InvGeography, sep="_")
#
#InvTrans.csv$row <- sequence(rle(as.character(InvTrans.csv$efmnhtransactions_key))$lengths)
#InvTrans1 <- spread(InvTrans.csv, row, InvTransactionType, sep="_")

Loan1$ObcTotalItems[which(is.na(Loan1$ObcTotalItems)==T)] <- 0
Loan1$ObuTotalItems[which(is.na(Loan1$ObuTotalItems)==T)] <- 0
Loan1$ObuTotalItems[which(is.na(Loan1$ObuTotalItems)==T)] <- 0

Loan1$LoanYear <- as.integer(substr(Loan1$TraDateProcessed, 1, 4))
Loan1 <- Loan1[which(Loan1$LoanYear>2004 & Loan1$LoanYear<2030),]

LoanSum <- aggregate(Loan1$TraTotalItemsLoaned, list(Loan1$LoanYear, Loan1$AccCatalogue), sum)
LoanCount <- dplyr::count(Loan1, AccCatalogue, LoanYear)

LoanSum2 <- LoanSum[which(LoanSum$x>0),]
LoanCount2 <- LoanCount[which(LoanCount$n>0 & is.na(LoanCount$n)==F),]

colnames(LoanSum2) = c("LoanYear","DarCollectionCode","SumItems")
colnames(LoanCount2) = c("DarCollectionCode","LoanYear","CountLoans")

# This can be exported for full count & sum dataset
LoanSumCount <- merge(LoanSum2, LoanCount2, by=c("LoanYear","DarCollectionCode"),all=T)


## This would be an alternate data structure (in case Pete needs particular setup for particular chart)
# LoanCount3 <- spread(LoanCount2, LoanYear, CountLoans)


setwd(origdir)
