## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get IDs of the current living breeders in a pedigree
#'
#' Internal helper shared by the demographic effective-size estimators (see
#' \code{\link{calcNeSexRatio}}). A living breeder is an animal that is living
#' -- \code{is.na(exit)}, or every animal when the pedigree carries no
#' \code{exit} column -- and that appears as a non-\code{NA},
#' non-auto-generated-unknown (non U-id) sire or dam somewhere in \code{ped}.
#' The population is derived from \code{ped} itself, independent of any
#' proband/population selection.
#'
#' @param ped Pedigree data.frame with at least \code{id}, \code{sire}, and
#' \code{dam}; \code{exit} is used to identify living animals when present.
#' @return Character vector of the living-breeder ids (possibly empty).
#' @noRd
getLivingBreeders <- function(ped) {
  living <- if (is.null(ped$exit)) {
    rep(TRUE, nrow(ped))
  } else {
    is.na(ped$exit)
  }
  parentIds <- c(ped$sire, ped$dam)
  parentIds <- parentIds[!is.na(parentIds)]
  parentIds <- parentIds[!isGeneratedUnknownId(parentIds)]
  isBreeder <- ped$id %in% unique(parentIds)
  as.character(ped$id[living & isBreeder])
}
