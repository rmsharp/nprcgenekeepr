## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get offspring to corresponding animal IDs provided
#'
#' @param pedSourceDf dataframe with pedigree structure having at least the
#' columns id, sire, and dam.
#' @inheritParams getParents
#' @return A character vector containing all of the offspring IDs for all of the
#' IDs provided in the second argument \code{ids}. All offspring are combined
#' and duplicates are removed.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' pedOne <- nprcgenekeepr::pedOne
#' names(pedOne) <- c("id", "sire", "dam", "sex", "birth")
#' getOffspring(pedOne, c("s1", "d2"))
getOffspring <- function(pedSourceDf, ids) {
  unique(c(
    pedSourceDf$id[(is.element(pedSourceDf$sire, ids) &
      !is.na(pedSourceDf$sire))],
    pedSourceDf$id[(is.element(pedSourceDf$dam, ids) &
      !is.na(pedSourceDf$dam))]
  ))
}
