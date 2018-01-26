# Output for global collections summary
# Institution Data (Name, URI, Lat Long)

# Institution Locality & URI
setwd(paste0(origdir,"/supplementary"))

# retrieved from http://grbio.org/content/data-download-grbio
#GRBioRaw <- read.csv("GRBIObiorepositories.csv", # CURRENT DATASET EXCLUDES 'COOL' URI
GRBioRaw <- read.csv("archived_grbio_institutions.csv", 
                      stringsAsFactors = F,
                      encoding = "UTF-8") # alt'ly, "latin1"

GRBioFull <- GRBioRaw[,c("Institution.Code", "Institution.Name",
                         "Physical.Address.1","Physical.Address.2","Physical.Address.3",
                         "City.Town.1", "State.Province.1", "Country.1", "Postal.Zip.Code.1",
                         "Mailing.Address.1", "Mailing.Address.2", "Mailing.Address.3",
                         "City.Town", "State.Province", "Country", "Postal.Zip.Code",
                         "Cool.URI")]

# setup Address Search fields
# NOTE - NOT (yet?) USING THESE TO RETRIEVE LATLONGs
GRBioFull$fullAddress <- paste0(GRBioFull$Physical.Address.1,
                               GRBioFull$Physical.Address.2, GRBioFull$Physical.Address.3, ", ",
                               GRBioFull$City.Town.1, ", ",
                               GRBioFull$State.Province.1)
                               # GRBioFull$Country.1)

GRBioFull$fullAddressALT <- paste(GRBioFull$Mailing.Address.1,
                                  GRBioFull$Mailing.Address.2, GRBioFull$Mailing.Address.3, ", ",
                                  GRBioFull$City.Town, ", ",
                                  GRBioFull$State.Province, ", ",
                                  GRBioFull$Country)

GRBioFull$NameCityCtry <- paste(GRBioFull$Institution.Name,
                                GRBioFull$City.Town.1,
                                GRBioFull$Country.1)

# clean Address Search fields
GRBioFull$fullAddress <- gsub("\\s+", " ", GRBioFull$fullAddress)
GRBioFull$fullAddress <- gsub("(,\\s+)+", ", ", GRBioFull$fullAddress)
GRBioFull$fullAddress <- gsub("\\s+,", ",", GRBioFull$fullAddress)
GRBioFull$fullAddressALT <- gsub("\\s+", " ", GRBioFull$fullAddressALT)
GRBioFull$fullAddressALT <- gsub("(,\\s+)+", ", ", GRBioFull$fullAddressALT)
GRBioFull$fullAddressALT <- gsub("\\s+,", ",", GRBioFull$fullAddressALT)
GRBioFull$NameCityCtry <- gsub("\\s+", " ", GRBioFull$NameCityCtry)
GRBioFull$NameCityCtry <- gsub(" ", "+", GRBioFull$NameCityCtry)

GRBioFull$fullAddress[which(nchar(GRBioFull$fullAddress)<6)] <- GRBioFull$fullAddressALT[which(nchar(GRBioFull$fullAddress)<6)]


# 11 Institutions to start with
#InstitutionCodes <- c("AMNH", "DMNS", "FMNH", "LACM", "MFN", "MNHN", "NHMD", "NHMUK", "NMNH", "NNM", "RBINS", "RMNHD", "ROM")
#GRBioPart <- GRBioFull[which(GRBioFull$Institution.Code %in% InstitutionCodes),] 

GRBioPart <- GRBioFull


if (file.exists("GRBioLatLonA.csv")) {
  
  GRBioLatLonA <- read.csv(file="GRBioLatLonA.csv", stringsAsFactors = F)
  GRBioLatLonA <- merge(GRBioPart, GRBioLatLonA, by="Institution.Code", all.y=T)
  GRBioLatLonA <- GRBioLatLonA[,c("Institution.Code","Institution.Name","lat","lon","Cool.URI")]
  
} else {
  
  #install.packages("devtools")
  library(devtools)
  
  # Note - Lat/Long Data (c) OpenStreetMap constributors, ODbL 1.0. http://www.openstreetmap.org/copyright
  # limit use to 1 request per second
  #devtools::install_github("hrbrmstr/nominatim")
  library(nominatim)
  
  OSMkey = "RqkvMEluAkr4srmZQ2FA7xVJRriCMl6J"

  # Search OSM by Institution.Name ####
  
  # setup dataframe for Lat Longs
  GRBioLatLonA <- data.frame("place_id"=character(),
                             "lat"=numeric(),
                             "lon"=numeric(),
                             "licence"=character(),
                             "type"=character(),
                             "Institution.Code"=character(),
                             stringsAsFactors = F)
  
  # setup dataframe for Errors
  GRBioError <- c()

  for (i in 1:NROW(GRBioPart)) {
    GRBioLatLonB <- osm_search(GRBioPart$Institution.Name[i],
                                email = "magpiedin@gmail.com", 
                                key = OSMkey, 
                                limit = 1)
    
    if (NROW(GRBioLatLonB)==1) {
      GRBioLatLonB <- GRBioLatLonB[,c("place_id","lat","lon","licence","type")]
      GRBioLatLonB$Institution.Code <- GRBioPart$Institution.Code[i]
      GRBioLatLonA <- rbind(GRBioLatLonA, GRBioLatLonB)
      print(paste(GRBioPart$Institution.Code[i], "lat/long added"))
    } else {
      GRBioError <- c(GRBioError, GRBioPart$Institution.Code[i])
      print(paste("error:", NROW(GRBioLatLonB), "lat/long found for", GRBioPart$Institution.Code[i]))
    }
    Sys.sleep(3)
  }
  
  #GRBioError <- GRBioError[which(nchar(GRBioError$Institution.Code)>0),]
  
  #backup
  write.csv(GRBioLatLonA, file="GRBioLatLonA.csv", row.names = F)

  if (NROW(GRBioError)<100) {
    # ...by City.Town ####
    GRBioPart2 <- GRBioPart[which(GRBioPart$Institution.Code %in% GRBioError),]
    
    # Setup df for Lat Longs
    GRBioLatLonA2 <- data.frame("place_id"=character(),
                               "lat"=numeric(),
                               "lon"=numeric(),
                               "licence"=character(),
                               "type"=character(),
                               "Institution.Code"=character(),
                               stringsAsFactors = F)
    
    # setup dataframe for Errors
    GRBioError2 <- c()
    
    # Loop through each institution
    for (i in 1:NROW(GRBioPart2)) {
      GRBioLatLonB2 <- osm_geocode(GRBioPart2$City.Town[i],
                                  email = "magpiedin@gmail.com", 
                                  key = OSMkey, 
                                  limit = 1)
      if (NROW(GRBioLatLonB2)==1) {
        GRBioLatLonB2 <- GRBioLatLonB2[,c("place_id","lat","lon","licence","type")]
        GRBioLatLonB2$Institution.Code <- GRBioPart2$Institution.Code[i]
        GRBioLatLonA2 <- rbind(GRBioLatLonA2, GRBioLatLonB2)
        print(paste(GRBioPart2$Institution.Code[i], "lat/long added"))
      }
      else {
        GRBioError2 <- c(GRBioError2, GRBioPart2$Institution.Code[i])
        print(paste("error:", NROW(GRBioLatLonB2), "lat/long found for", GRBioPart2$Institution.Code[i]))
      }
      Sys.sleep(3)
    }
  }  
}
  
GRBioLatLon11 <- read.csv(file="GRBioInstitutions11.csv", stringsAsFactors = F)


# merge all searches ####
# # # If new search for-loops are added, add them here
if (exists("GRBioLatLonA2")){
  GRBioLatLonAll <- rbind(GRBioLatLonA, GRBioLatLonA2, GRBioLatLon11)  # add GRBioLatLonAll10 HERE + dedup
} else {
  GRBioLatLonAll <- rbind(GRBioLatLonA, GRBioLatLon11)
}
GRBioLatLonAll <- unique(GRBioLatLonAll)
# GRBioLatLonAll10 <- GRBioLatLonAll  # BU


# merge LatLong with other Institution Data
GRBioExport <- merge(GRBioPart, GRBioLatLonAll, by="Institution.Code", all.y=T)


# setup export fields ####
if (NROW(GRBioExport$Institution.Name.x)>0) {
  GRBioExport <- GRBioExport[,c("Institution.Code",
                                "Institution.Name.x",
                                "lat", "lon", "Cool.URI.x")]
  colnames(GRBioExport) <- c("Institution.Code",
                             "Institution.Name",
                             "lat", "lon", "Cool.URI")
} else {
  GRBioExport <- GRBioExport[,c("Institution.Code",
                                "Institution.Name",
                                "lat", "lon", "Cool.URI")]
}

# filter down to ~10 (or ~100?) largest institutions
Institution109 <- c("AMNH", "DMNS", "FMNH", "LACM", "MFN", "MNHN", 
                    "NHMD", "NHMUK", "NMNH", "NNM", "RBINS", "RMNHD", "ROM")
GRBioExport$ShowOnMap <- 0
GRBioExport$ShowOnMap[which(GRBioExport$Institution.Code %in% Institution109)]<- 1


# check for unique Institution Codes
GRcheck <- dplyr::count(GRBioExport, Institution.Code)
GRcheck <- GRcheck[which(GRcheck$n>1),]
GRBioExport2 <- GRBioExport[which(!GRBioExport$Institution.Code %in% GRcheck$Institution.Code),]

## If need to check for unique latlong, too:
#GRBioExport2$latlon <- paste(GRBioExport2$lat, GRBioExport2$lon)
#GRcheck2 <- count(GRBioExport2, latlon)
#GRcheck2 <- GRcheck2[which(GRcheck2$n>1),]


write.csv(GRBioExport2, file="GRBioInstitutions.csv", row.names = F, na="")
