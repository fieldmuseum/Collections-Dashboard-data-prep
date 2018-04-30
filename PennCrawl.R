# install.packages("Rcrawler")
library("Rcrawler")

# listURLs<-c("http://www.thedermreview.com/la-prairie-reviews/",
#             "http://www.thedermreview.com/arbonne-reviews/",
#             "http://www.thedermreview.com/murad-reviews/")
# 
# Reviews<-ContentScraper(Url = listURLs, 
#                         CssPatterns =c(".entry-title","#comments p"),
#                         ManyPerPattern = TRUE)

PennObjs <- read.csv("data01raw/all-20180422.csv", stringsAsFactors = F)

listURLs2 <- c("https://www.penn.museum/collections/object/371257")

date()
listURLs3 <- PennObjs$url[1:100]

Images <- ContentScraper((Url = listURLs3),
                         XpathPattern=c("//*/div[@class='col-md-4']/a/img/@src"),
                         ManyPerPattern = F)

date()

ImagesUnlist <- unlist(Images)
PennObjBU <- PennObjs[1:100]
PennObjBU$Images <- ImagesUnlist
