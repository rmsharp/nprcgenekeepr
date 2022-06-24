#' Get offspring to corresponding animal IDs provided
#'
## Copyright(c) 2017-2022 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' @return A character vector containing all of the ancestor IDs for all of the
#' IDs provided in the second argument \code{ids}. All ancestors are combined
#' and duplicates are removed.
#'
#' @examples
#' library(nprcgenekeepr)
#' \donttest{
#' pedOne <- nprcgenekeepr::pedOne
#' names(pedOne) <- c("id", "sire", "dam", "sex", "birth")
#' getOffspring(pedOne, c("s1", "d2"))
#' }
#' @param pedSourceDf dataframe with pedigree structure having at least the
#' columns id, sire, and dam.
#' @param ids character vector of animal IDs
#' @export
getOffspring <- function(pedSourceDf, ids) {
  unique(c(pedSourceDf$id[(is.element(pedSourceDf$sire, ids) &
                                 !is.na(pedSourceDf$sire))],
           pedSourceDf$id[(is.element(pedSourceDf$dam, ids) &
                                !is.na(pedSourceDf$dam))]))
}
