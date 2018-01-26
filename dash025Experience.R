## collections-dashboard-prep
#
# Import Research/Experience data from EMu - Parties (eparties)
#
# 1) In EMu, retrieve Parties records for dashboard, 
#       08-May-2017 dataset includes all eparties records where:
#           AddEMuUserID = \*  [plus manual selection/cleanup?]
#
# 2) Report them out (with which report?)
##       - see collections-dashboard "Help" page for details on which fields are included in report [NEED TO ADD]
##       - If under 200k records, report all at one time.
##       - Don't rename reported files. Keep them together in one folder.
#
# 3) Run this script  
#       - NOTE: May need to re-set working directory to folder containing reported csv's
#         (see lines 22 & 23)


print(paste(date(), "-- ...finished setting up WHO.    Starting dash025Experience.R"))


# point to the directory containing the set of "Group" csv's from EMu
setwd(paste0(origdir,"/data01raw/emuPartiesExp"))


# Import Parties data ####
Exper1 <- read.csv(file="research_experience.csv", stringsAsFactors = F)


# Map Department & Division to DarCollectionCode values
CollectionCodes <- as.character(levels(as.factor(FullDash7csv$DarCollectionCode)))
CollectionCodes <- append(CollectionCodes, "Media")

Exper1$CollectionCodes <- "Other"
Exper1$CollectionCodes[which(Exper1$NamDepartment %in% CollectionCodes)] <- Exper1$NamDepartment[which(Exper1$NamDepartment %in% CollectionCodes)]
Exper1$CollectionCodes[which(Exper1$NamBranch %in% CollectionCodes)] <- Exper1$NamBranch[which(Exper1$NamBranch %in% CollectionCodes)]
Exper1$CollectionCodes[which("RRC" %in% Exper1$EMu.Group)] <- "Botany"
Exper1$CollectionCodes[which("Library" %in% Exper1$NamDepartment)] <- "Media"


# For each CollectionCode, count # people in each role (NamRoles_tab) [or position?]
NonStaff <- c("Volunteer", "Intern")
CollStaff <- c("Assistant", "Manager", "Registrar", "Technician", "Specialist")
RschStaff <- c("Curator", "Researcher", "Post Doc")

Exper1$Role <- "Other Support"
Exper1$Role[which(grepl(paste0(RschStaff, collapse="|"), paste(Exper1$NamRoles_tab, Exper1$NamPosition))>0)] <- "Research Staff"
Exper1$Role[which(grepl(paste0(CollStaff, collapse="|"), paste(Exper1$NamRoles_tab, Exper1$NamPosition))>0)] <- "Collections Staff"
Exper1$Role[which(grepl(paste0(NonStaff, collapse="|"), paste(Exper1$NamRoles_tab, Exper1$NamPosition))>0)] <- "Volunteer/Intern"


# For each CollectionCode, count # people in each role (NamRoles_tab) [or position?]
Exper2 <- dplyr::count(Exper1, CollectionCodes, Role)


setwd(origdir)
