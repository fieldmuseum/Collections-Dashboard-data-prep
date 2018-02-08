# Capitalizes first letter in each word in a string
# from Andrie - http://stackoverflow.com/a/6364905

simpleCap <- function(x) {
  s <- strsplit(tolower(x), " ")[[1]]
  paste(toupper(substring(s, 1, 1)), substring(s, 2),
        sep = "", collapse = " ")
}