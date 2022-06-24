#' Check for genotype data in dataframe
#'
## Copyright(c) 2017-2022 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Checks to ensure the content and structure are appropriate for genotype
#' data are in the dataframe and ready for the \code{geneDrop} function by
#' already being mapped to integers and placed in columns named \code{first}
#' and \code{second}. These checks are simply based on expected columns
#' and legal domains.
#'
#' @return A logical value representing whether or not the data.frame passed in
#' contains genotypic data that can be used. Non-standard column names are
#' accepted for this assessment.
#'
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' rhesusPedigree <- nprcgenekeepr::rhesusPedigree
#' rhesusGenotypes <- nprcgenekeepr::rhesusGenotypes
#' pedWithGenotypes <- addGenotype(ped = rhesusPedigree,
#'                                genotype = rhesusGenotypes)
#' hasGenotype(pedWithGenotypes)
#' }
#' @param genotype dataframe with genotype data
#' @importFrom stringi stri_detect_fixed
#' @export
hasGenotype <- function(genotype) {
  cols <- names(genotype)
  if (length(cols) < 3) {
    return(FALSE) # "Genotype file must have at least three columns
  } else if (!any(stri_detect_fixed(tolower(cols), "id"))) {
    return(FALSE) # "Genotype must have 'id' as a column.")
  } else if (!any(tolower(cols) %in% "first")) {
    return(FALSE) # "Genotype must have a column named 'first'
  } else if (!any(tolower(cols) %in% "second")) {
    return(FALSE) # "Genotype  must have a column named 'second'
  } else {
    if (!any(class(genotype$first) %in% c("numeric", "integer"))) {
      return(FALSE)  # genotype representation (indirection) should be integer
      # at this point
    } else if (!any(class(genotype$second) %in% c("numeric", "integer"))) {
      return(FALSE)  # genotype representation (indirection) should be integer
    } else {
      return(TRUE)
    }
  }
}
