#' Get the maximum age of live animals in the pedigree.
#'
## Copyright(c) 2017-2022 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' @return Numeric value representing the maximum age of animals in the
#' pedigree.
#'
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' examplePedigree <- nprcgenekeepr::examplePedigree
#' ped <- qcStudbook(examplePedigree, minParentAge = 2,
#'                         reportChanges = FALSE,
#'                         reportErrors = FALSE)
#' getPedMaxAge(ped)
#' }
#'
#' @param ped dataframe with pedigree
#' @export
getPedMaxAge <- function(ped) {
  max(ped$age, na.rm = TRUE)
}
