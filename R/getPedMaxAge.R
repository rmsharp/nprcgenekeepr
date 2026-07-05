## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get the maximum age of any animal in the pedigree
#'
#' Returns the maximum age among all animals in the pedigree that
#' have a non-NA age. Because ages are computed for deceased animals
#' (age at exit) as well, the maximum can reflect a deceased animal.
#'
#' @inheritParams reportGV
#' @return Numeric value representing the maximum age of animals in the
#' pedigree.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' examplePedigree <- nprcgenekeepr::examplePedigree
#' ped <- qcStudbook(examplePedigree,
#'   minParentAge = 2,
#'   reportChanges = FALSE,
#'   reportErrors = FALSE
#' )
#' getPedMaxAge(ped)
getPedMaxAge <- function(ped) {
  max(ped$age, na.rm = TRUE)
}
