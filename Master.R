# Run this script to prep a Collections Dashboard dataset.

#origdir <- "D:/CollDashCultural"
origdir <- getwd()

# Instructions
print("Step 1 - Save scripts repo to computer.")
print("Step 2 - Save raw data to sub-folder called 'data01raw'.")
print("Step 3 - ...And supplementary data to sub-folder called 'supplementary'.")
print(paste("Step 3 - Currently, the working directory is set to: ", getwd()))
switchYN <- readline(prompt="Do you need to change the working directory to the folder containing the scripts? (Y/N) ")

if (switchYN=="Y") {
  origdir <- readline(prompt="Enter working directory (e.g., C:/path/to/folder ) ")
  setwd(origdir)
} else if (switchYN=="N") {
  setwd(origdir)
}

if (dir.exists(paste0(origdir,"/output"))==T) {
  print("Step 4 - 'output' directory already set up.")
} else if (dir.exists(paste0(origdir,"/output"))==F) {
  dir.create("./output", showWarnings = T)
  print("Step 4 - 'output' directory created.")
}


sourceDir <- function(path, trace = TRUE, ...) {
  for (nm in list.files(path, pattern = "\\.[Rr]$")) {
    if(trace) cat(nm,":")
    source(file.path(path, nm), ...)
    if(trace) cat("\n")
  }
}

usePackage <- function(p) {
  newPackages <- p[!(p %in% installed.packages()[, "Package"])]
  if(length(newPackages))
    install.packages(newPackages, dependencies = TRUE)
  cat("Packages successfully loaded:\n")
  sapply(p, require, character.only = TRUE, quietly = TRUE)
}

simpleCap <- function(x) {
  s <- strsplit(tolower(x), " ")[[1]]
  paste(toupper(substring(s, 1, 1)), substring(s, 2),
        sep = "", collapse = " ")
}

sourceDir(paste(getwd(),"/functions",sep=""))

usePackage("tidyr")
usePackage("plyr")
usePackage("dplyr")
usePackage("purrr")


# Select which scripts to run
DarYN <- readline(prompt="Do you need to import a Darwin Core archive? (Y/N) ")
AccYN <- readline(prompt="Do you need to import accession (backlog) dataset/s? (Y/N) ")


# Run selected scripts
if (DarYN=="Y") { source("dash005DarPrep.R") }

# Added OI recordset import 06-feb-2018
# ( CSV from Foy's shared XLSX report )
source("dash006OIcsvImport.R")

# Added Penn-Museum recordset import 26-jan-2018
# ( https://www.penn.museum/collections/objects/data.php )
source("dash007PMcsvImport.R")

# if (!file.exists("data01raw/CatDash03bu.csv")) { source("dash010CatPrep.R") }
source("dash010CatPrep.R")
if (AccYN=="Y") { source("dash015AccPrep.R") }

source("dash020FullBind.R")
source("dash021Where.R")
source("dash022What.R")
source("dash023When.R")
source("dash024Who.R")

# Added these [May-2017]:
source("dash025Experience.R")
source("dash026LoansPrep.R")
source("dash027VisitPrep.R")
source("dash028Ecoregions.R")

source("dash030FullExport.R")

# Institution summaries?
#source("dash050InstData.R")

