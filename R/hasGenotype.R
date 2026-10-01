## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Check for genotype data in dataframe
#'
#' Checks to ensure the content and structure are appropriate for genotype
#' data are in the dataframe and ready for the \code{geneDrop} function by
#' already being mapped to numbers (integer codes are expected, but any numeric
#' value passes) and placed in columns named \code{first} and \code{second}. Only the \code{id} column is matched loosely (any
#' column whose lower-cased name contains \code{"id"}). The allele columns
#' must be named exactly \code{first} and \code{second} and be numeric; no
#' check is made of the values' range, so negative, missing or very large
#' numbers still give \code{TRUE}.
#'
#' @param genotype dataframe with genotype data
#' @return A logical value representing whether or not the data.frame passed in
#' contains genotypic data that can be used. Columns named \code{First} or
#' \code{Second} (other cases) give \code{FALSE}.
#'
#' @importFrom stringi stri_detect_fixed
#' @export
#' @examples
#' library(nprcgenekeepr)
#' rhesusPedigree <- nprcgenekeepr::rhesusPedigree
#' rhesusGenotypes <- nprcgenekeepr::rhesusGenotypes
#' pedWithGenotypes <- addGenotype(
#'   ped = rhesusPedigree,
#'   genotype = rhesusGenotypes
#' )
#' hasGenotype(pedWithGenotypes)
hasGenotype <- function(genotype) {
  cols <- names(genotype)
  if (length(cols) < 3L) {
    FALSE # "Genotype file must have at least three columns
  } else if (!any(stri_detect_fixed(tolower(cols), "id"))) {
    FALSE # "Genotype must have 'id' as a column.")
  } else if (!any(tolower(cols) == "first")) {
    FALSE # "Genotype must have a column named 'first'
  } else if (!any(tolower(cols) == "second")) { # nolint: if_not_else_linter
    FALSE # "Genotype  must have a column named 'second'
  } else if (!any(is.numeric(genotype$first))) {
    FALSE # genotype representation (indirection) should be integer
    # at this point
  } else if (!any(is.numeric(genotype$second))) { # nolint: if_not_else_linter
    FALSE # genotype representation (indirection) should be integer
  } else {
    TRUE
  }
}
