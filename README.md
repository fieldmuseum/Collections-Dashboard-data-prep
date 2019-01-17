# Collections-Dashboard-data-prep
These scripts prepare EMu and GBIF collections data for a Collections Dashboard.

Catalogue/Specimen records are combined with Accession/Storage Unit records to count catalogued and backlogged items in the collections.

## How to use these scripts
1. Clone repo locally.
2. Match raw catalog dataset structure to /data01raw/CatDash03bu.csv
3. Match raw accessions dataset structure to /data01raw/AccBacklogBU.csv
4. Retrieve GBIF datasets as DwC Archive files in /data01raw/CatDwC/
4. Run the prep scripts by running `Master.R`

To run Master.R in the RStudio console:
- First, type `setwd("path/to/local/repo")` to set the working directory.
- Second, type `Master.R` to run the prep scripts.


### Notes about fields in the raw input data
Datasets here were exported from the FMNH EMu collections database. Darwin Core fields were used when possible, but not all fields mapped directly to Darwin Core fields.  For example, "description" fields in accession records often includes information about "Where" as well as about "What".

#### The full list of ecatalogue fields is as follows:
_Core and Quality-related fields:_
 - irn
 - DarGlobalUniqueIdentifier
 - CatDepartment
 - DarCatalogNumber
 - DarInstitutionCode
 - DarCollectionCode
 - AdmDateInserted
 - AdmDateModified
 - DarIndividualCount
 - DarBasisOfRecord
 - DarImageURL
 - MulHasMultiMedia
 - DarCollector
 - CatLegalStatus
 - DarStateProvince
 
_Where-related fields:_
 - DarLatitude
 - DarLongitude
 - DarCountry
 - DarContinent
 - DarContinentOcean
 - DarWaterBody
  
_Who-related fields:_
 - DesEthnicGroupSubgroup_tab
 
_What-related fields:_
 - EcbNameOfObject
 - DesMaterials_tab
 - DarOrder
 - DarScientificName
 - IdeTaxonRef_tab.ClaRank
 - IdeTaxonRef_tab.ComName_tab
 - DarRelatedInformation
 - CatProject_tab
 - IdeFiledAs_tab (to be added)
 
_WhenAge-related fields:_
 - DarEarliestAge
 - DarEarliestEon
 - DarEarliestEpoch
 - DarEarliestEra
 - DarEarliestPeriod
 - AttPeriod_tab
 - DarYearCollected
 - DarMonthCollected

#### The full list of efmnhtransactions (accession record) fields is as follows:
_Count-related fields (used for calculating backlogged items):_
 - irn = internal record number; unique identifier for an accession record in the FMNH collection management system
 - AccCatalogue = FMNH Collection area for the accession
 - AccTotalItems = Total number of specimens (natural history) or objects (cultural)
 - AccTotalObjects = Total number of lots
 - AccCount_tab = The number of pieces in the lot per geographical region
 (Excluded from dashboard v3)
 - (PriAccessionNumberRef.CatCatalog = FMNH Collection area for a catalogue record associated with the accession)
 - (PriAccessionNumberRef.DarIndividualCount = dwc:individualCount for the associated catalogue record)
 - (PriAccessionNumberRef.irn = internal record number for the associated catalogue record)
 - (PriAccessionNumberRef.DarBasisOfRecord = dwc:basisOfRecord for the associated catalogue record)
 - (PriAccessionNumberRef.CatItemsInv = Total number of specimens or objects represented by the associated catalogue record)
 
_What- & Who-related fields:_
 - AccDescription_tab 
 - AccAccessionDescription 

_Where-related fields:_
 - AccGeography_tab = geographic coverage of the accession
 - AccLocality = specific locality related to the accession
 - AccCollectionEventRef.ColSiteRef.LocContinent_tab
 - AccCollectionEventRef.ColSiteRef.LocCountry_tab
 - AccCollectionEventRef.ColSiteRef.LocOcean_tab

## Notes about fields in the output "FullDash" dataset
#### Where, What, WhenAge, Who
These fields are prepped in the respective dash02#Where/What/When/Who.R scripts. They broadly accommodate both cultural and natural history datasets, incorporating standard Darwin Core fields when possible.  The input dataset groupings (listed above) indicate which input fields correspond to these output fields.
Note: dash022What.R references the `/supplementary/WhatComNames.csv` lookup to join common names from [ITIS](https://www.itis.gov/) with the specimen dataset (on the DarOrder field).

### 1) Fields prepped in dash020FullBind.R:
#### Quality
A ranking based on the following criteria (poor = 1; good = 9):
 - 1 = Digital accession record exists
 - 2 = Total Object (lots) > 0 OR Total Items (specimens) > 0
 - 3 = Locality Not Null
 - 4 = Catalogue # Not NULL
 - 5 = Reverse attached catalogue records Not NULL
 - 6 = Has Digital Catalogue record
 - 7 = Has _Partial Data_
 - 8 = PriCoordinateIndicator = Yes OR HasMultimedia = Yes
 - 9 = PriCoordinateIndicator = Yes AND HasMultimedia = Yes AND Has _Full Data_ = Yes
 
 _Partial Data_ = Has 3 or 4 of the following:
 - IdeTaxonRef_tab.ClaRank = Family, Genus, Species, Subpecies or Variety
 - DarStateProvince Not NULL
 - DarCollector Not NULL
 - DarYearCollected Not NULL
 - DarCatalogNumber Not NULL
 
 _Full Data_ = Has all 5 of the above
 
#### RecordType
Indicates whether the record is "Catalog" or "Accession" data, and therefore part of the catalogued or backlogged items.
#### DarIndividualCount
The number of items catalogued, from the DarIndividualCount field of a catalogue record.
#### Backlog
The number of items backlogged = the number of catalogued items subtracted from the number accessioned (or inventoried) items.
#### TaxIDRank
The taxonomic level to which a specimen has been identified.
#### HasMM
A binary value where "1" = has Multimedia attached, and "0" = no Multimedia attached.
#### DarInstitutionCode, DarCollectionCode
The name of the institution and collection to which a record belongs. 
NOTE: The donut chart references the `/supplementary/CollectionDomain2.csv` lookup table to group collections into domains. Institutions would be invited to specify their own collection-to-domain mappings. (Standardized vocabulary needed from the community.)

### 2) Extra fields prepped in dash023When.R:
#### Department
The name of the department to which a record belongs. 
NOTE: dash023When.R references the `/supplementary/Departments.csv` lookup table to standardize department names while calculating specimen ages. Institutions would be invited to specify their own collection-to-department mappings. (This vocabulary should be standardized and/or consolidated with CollectionDomain2.csv)
#### URL
Collections listed in summary stats will link to these URLs.
NOTE: dash023When.R references the `/supplementary/CollDashEd.csv` lookup table to link URLs to collections. Institutions would be invited to specify their own collections and corresponding URLs.
#### WhenAgeFrom/To/Mid & DarYearCollected
Numeric values for age of geology specimens & anthropolgy artifacts, or for collection year for botany & zoology specimens. Anthropological and Geological terms are mapped to numeric dates in `/supplementary/WhenAttPerLUT.csv` & `/supplementary/WhenChronoLUTemu.csv`
#### WhenOrder
Ordinal values between 1 and 53 to group numeric ages into time-groups; necessary for chart to function.
#### WhenTimeLabel
Labels corresponding to the 53 "WhenOrder" groups, ranging from 4.6 billion years ago to 2020. Loosely, ranges are grouped by geologic periods/epochs/eras prior to ~18th century dates, and grouped by decade after 18th century dates. Chart labels and corresponding date ranges are listed in `/supplementary/WhenYearRanges2.csv`. Range divisions were chosen in attempt to fit data to the current chart layout, but please tell us if you know of more valid/sensible alternatives.

### 3) Extra fields prepped in dash028Ecoregions.R:
#### Bioregion
dash028Ecoregions.R references the `/supplementary/EcoRegionCountires.csv` lookup table to map specimens to one of the [WWF-defined ecoregions](http://wwf.panda.org/about_our_earth/ecoregions/ecoregion_list/) based on their country or ocean data. Currently, in cases where countries or oceans are in multiple ecoregions, specimens are likewise associated with multiple ecoregions.

## Notes about extra output datasets
#### LUTs (WhatLUTB.csv, WhenAgeLUT.csv, WhereLUT.csv, WhoLUT.csv)
Lookup tables are exported for What, When, Where, and Who fields.  These are used by the dashboard search fields.
#### WhoExperience.csv
A count of individuals in each type of staff role (Collections, Research, Volunteer, Other) in each collection. 
This is produced by the dash025Experience.R script, using the `/data01raw/emuPartiesExp/` dataset (sample data provided), which includes NamDepartment, NamBranch, EMu Group, and NamRoles_tab fields from eparties records for emu-users.

(In EMu/eparties, retrieve EMu user records, and report the above fields)

#### LoanSumCount.csv
A count of total items loaned and total loans per year per collection. 
This is produced by the dash026LoansPrep.R script, using the `/data01raw/emuLoans/` dataset (sample data provided), which includes the following fields from efmnhtransactions records for loans:
- item counts (InvCount_tab, ObcTotalItems, ObcTotalObjects, ObuTotalItems, ObuTotalObjects, TraTotalInvoiceItems, TraTotalItemsLoaned, TraTotalItemsOutstanding)
- loan types (InvTransactionType_tab, LoaLoanType, LoaStatus, TraTransactionType)
- loan dates (TraDateAuthorized, TraDateProcessed)
- department (AccCatalogue, SumDepartment)
- description (InvDescription_tab, InvGeography_tab)

(In EMu/efmnhtransactions, retrieve loan records, and run the "DashboardTrans - Copy" report)

#### VisitSumCount.csv
A count of total visitors and total visits per year per collection. 
This is produced by the dash027VisitPrep.R script, using the `/data01raw/emuConsult/` dataset (sample data provided), which includes the following fields from efmnhrepatriation records for collection visits:
- department (SecDepartment_tab)
- total visitors (ResNoOfVisitors, ResResearchersRef_tab[eparties].NamBriefName)
- dates (ResCommencementDate, ResCompletionDate)
- record type (InfRecordType)

(In EMu/efmnhrepatriation, retrieve research visit records, and run the "VisitorDays - Copy" report)

## Data & Development Acknowledgements
- Development and EMu datasets from the [Field Museum](fielmuseum.org) Technology and Science & Education Departments.
- Many thanks to [Naturalis](http://www.naturalis.nl/en/) -- We hope to incorporate more of the data available through [their API](http://netherlands-biodiversity-api-docs.readthedocs.io/en/latest/api_services_summary.html), but for now are working through their [GBIF IPT](http://www.gbif.org/publisher/396d5f30-dea9-11db-8ab4-b8a03c50a862)
- Many thanks to the Smithsonian [National Museum of Natural History](https://naturalhistory.si.edu/) for sharing data and input.
