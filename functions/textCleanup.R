# Text cleanup functions

# Trim punctuation ####
textClean <- function (x, keepApostrophe=T) {
  x <- gsub("`", "'", x)
  ifelse(
    keepApostrophe==T,
    x <- gsub("\\[|\\]|[(,)&?!=;/:#\"*]|[-]|[0-9]", " ", x),  # leaves in apostrophes [']
    x <- gsub("[[:punct:]]|[0-9]", " ", x))  # removes all punctuation & numeric values
  x <- gsub("[\\]", " ", x)
  x <- gsub("UK-| UK$", "United Kingdom ", x, ignore.case=T)
  x <- gsub("United States| Usa |^Usa$| Us | U S A |^Us$", "U.S.A.", x, ignore.case=T)
  x <- gsub("U\\.s\\.a(\\.|)", "U.S.A.", x, ignore.case=T)
  x <- gsub("U\\.s\\.s\\.r", "U.S.S.R", x, ignore.case=T)
  x <- gsub("U\\.s\\.", "U.S.", x, ignore.case=T)
  x <- gsub("NANA|^Na$", "", x, ignore.case=T)
  x <- gsub("\\.\\.", ".", x)
}


# Trim non-informative words ####
CutFirst <- c("^[Aa] ","^[Aa]bout ","^[Tt]he ")
CutWords <- c(" a "," about "," an "," and "," as "," be ",
              " for "," from "," in "," of "," on "," or ",
              " s "," the "," to "," with ")

wordCut <- function (x) {
  x <- gsub(paste(CutFirst, collapse="|"), " ", x, ignore.case = T)
  x <- gsub(paste(CutWords, collapse="|"), " ", x, ignore.case = T)
}


# Trim spaces ####
spaceClean <- function (x) {
  x <- gsub("\\s+", " ", x)
  x <- gsub("^\\s+|\\s+$", "", x)
}


# Cleanup Artefacts ####
nanaClean <- function (x) {
  x <- gsub("NANA|^Na$", "", x, ignore.case=T)
  x <- gsub("\\.\\.", ".", x, ignore.case=T)
}


# Final cleanup of combined fields
finalClean <- function (x) {
  x <- gsub("U\\.s\\.a(\\.|)", "U.S.A.", x, ignore.case=T)
  x <- gsub("U\\.s\\.s\\.r", "U.S.S.R", x, ignore.case=T)
  x <- gsub("(\\s+\\|)+", " |", x)
  x <- gsub("NANA| Na$", "", x)
  x <- gsub("\\s+Na\\s+", " ", x)
  x <- gsub("\\s+", " ", x)
  x <- gsub("(\\|\\s+\\|)+|(\\| NA \\|)+|(\\| and \\|)+","|", x)
  x <- gsub("(\\| NA \\|)+", "|", x)
  x <- gsub("(\\|\\s+)+","| ", x)
}



# # Final cleanup of combined fields
# finalClean <- function (x) {
#   x <- gsub("(\\s+\\|)+", " |", x)
#   x <- gsub("NANA| Na$| NA ", "", x)
#   x <- gsub("\\s+Na\\s+", " ", x)
#   x <- gsub("\\s+", " ", x)
#   x <- gsub("(\\|\\s+\\|)+","|", x)
#   x <- gsub("(\\| and \\|)+", "|", x)
#   x <- gsub("(\\|\\s+)+","| ", x)
# }


