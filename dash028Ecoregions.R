# Setup to map countries/continents/oceans to Ecoregions

print(paste(date(), "-- ...finished setting up Visitor data.   Starting dash028Ecoregions.R"))


# Add separate columns for DarCountry & DarContinentOcean
DarCtryContOcean <- FullDash2[,c("DarGlobalUniqueIdentifier",
                                 "cleanDarCountry","cleanDarContinentOcean",
                                 "cleanAccGeography", "cleanAccLocality"
                                 )]

DarCtryContOcean[,2:NCOL(DarCtryContOcean)] <- sapply(DarCtryContOcean[,2:NCOL(DarCtryContOcean)],
                                                      function(x) gsub("(NA)+","",x))

# Only using first value from pipe-delimited Accession Geography fields (to simplify merge)
DarCtryContOcean[,4:NCOL(DarCtryContOcean)] <- sapply(DarCtryContOcean[,4:NCOL(DarCtryContOcean)],
                                                      function(x) gsub("\\s+\\|.*","",x))


# Set up merge-column for WWF/ESRI Ecoregion data
DarCtryContOcean$CountryOcean <- DarCtryContOcean$cleanDarCountry
#DarCtryContOcean$CountryOcean[which(nchar(DarCtryContOcean$CountryOcean)<1)] <- DarCtryContOcean$cleanDarContinentOcean[which(nchar(DarCtryContOcean$CountryOcean)<1)]
DarCtryContOcean$CountryOcean[which(nchar(DarCtryContOcean$CountryOcean)<1)] <- DarCtryContOcean$cleanAccGeography[which(nchar(DarCtryContOcean$CountryOcean)<1)]
DarCtryContOcean$CountryOcean[which(nchar(DarCtryContOcean$CountryOcean)<1)] <- DarCtryContOcean$cleanAccLocality[which(nchar(DarCtryContOcean$CountryOcean)<1)]


# Import Ecoregion/Realms-Country/Ocean join-tables
setwd(paste0(origdir, "/supplementary"))
Ecoregions <- read.csv("EcoRegionCountries.csv", stringsAsFactors = F)
#WWFtoESRI <- read.csv("EcoRegionWWF_ESRI.csv", stringsAsFactors = F)

Ecoregions <- unique(Ecoregions[which(nchar(Ecoregions$CountryOcean)>0),c("CountryOcean","EcoRegionsEnvironment")])
Ecocheck <- dplyr::count(Ecoregions, CountryOcean)
if (max(Ecocheck$n>1)) {
  Ecoregions <- Ecoregions[order(Ecoregions$CountryOcean),]
  Ecoregions$seq <- sequence(rle(as.character(Ecoregions$CountryOcean))$lengths)
  Ecoregions <- spread(Ecoregions, seq, EcoRegionsEnvironment, fill="", sep="_")
  Ecoregions <- unite(Ecoregions, EcoRegionsEnvironment, seq_1:seq_2, sep = " | ")
}

colnames(Ecoregions)[2] <- "Bioregion"

Ecoregions$CountryOcean <- tolower(Ecoregions$CountryOcean)
DarCtryContOcean$CountryOcean <- tolower(DarCtryContOcean$CountryOcean)

DarCtryContOcean <- merge(DarCtryContOcean, Ecoregions, by=c("CountryOcean"), all.x=T)
DarCtryContOcean <- DarCtryContOcean[,c("DarGlobalUniqueIdentifier","Bioregion")]
DarCtryContOcean$Bioregion[which(is.na(DarCtryContOcean$Bioregion)==T)] <- ""

#DarCtryContOcean <- unite(DarCtryContOcean, Bioregion, cleanDarCountry:cleanAccLocality, sep=" | ")
#DarCtryContOcean$Bioregion <- gsub("(\\|\\s+)+", "| ", DarCtryContOcean$Bioregion)
#DarCtryContOcean$Bioregion <- gsub("^\\s+\\|\\s+$|^\\s+\\||\\|\\s+$", "", DarCtryContOcean$Bioregion)
#DarCtryContOcean$Bioregion <- gsub("^\\s+|\\s+$", "", DarCtryContOcean$Bioregion)


FullDash8 <- merge(FullDash7csv, DarCtryContOcean, by=c("DarGlobalUniqueIdentifier"), all.x=T)

Log028Ecoregions <- warnings()

setwd(origdir)

##install.packages("curl")
#library(curl)
#curl::curl_download("http://assets.worldwildlife.org/publications/15/files/original/official_teow.zip?1349272619", destfile = "official.zip")
#unzip("official.zip")
#shpfile <- "official/wwf_terr_ecos.shp"

##install.packages("geojsonio")
##install.packages("rgdal")
#library(geojsonio)
#shp <- geojsonio::geojson_read("official/wwf_terr_ecos.shp", method = "local", what = "sp")

