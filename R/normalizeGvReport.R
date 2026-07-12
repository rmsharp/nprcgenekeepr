## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Normalize a genetic-value report to the canonical column vocabulary
#'
#' The exported \code{reportGV} emits \code{indivMeanKin}/\code{gu}; the
#' exported \code{makeGeneticSummaryTable} historically consumed the renamed
#' \code{meanKinship}/\code{genomeUniqueness}, so composing them silently
#' returned an all-N/A table. This internal seam maps either vocabulary onto
#' \code{reportGV}'s own canonical column names so a consumer needs to read
#' only one. Idempotent: a frame that already carries
#' \code{indivMeanKin}/\code{gu} is returned unchanged. See
#' \code{docs/planning/issue122-module-contract-plan.md} section 4.2.
#'
#' @param gv A data.frame (or \code{NULL}) carrying either the canonical
#'   (\code{indivMeanKin}/\code{gu}) or the renamed
#'   (\code{meanKinship}/\code{genomeUniqueness}) genetic-value columns.
#' @return \code{gv} with \code{indivMeanKin}/\code{gu} column names, or the
#'   input unchanged when neither vocabulary is present.
#' @noRd
normalizeGvReport <- function(gv) {
  if (is.null(gv)) {
    return(gv)
  }
  if (!("indivMeanKin" %in% names(gv)) && "meanKinship" %in% names(gv)) {
    names(gv)[names(gv) == "meanKinship"] <- "indivMeanKin"
  }
  if (!("gu" %in% names(gv)) && "genomeUniqueness" %in% names(gv)) {
    names(gv)[names(gv) == "genomeUniqueness"] <- "gu"
  }
  gv
}
