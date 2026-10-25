## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Founder equivalents, founder genome equivalents and FG's standard error
#'
#' What \code{reportGV()} reports from \code{calcFEFG()} and \code{calcFGSE()},
#' with the founder contributions and the retention scan each built once for
#' both (performance plan Phase 5, H8): the same numbers, warnings and errors,
#' in the same order, as the two calls.
#'
#' @param ped the pedigree, as \code{calcFEFG()} takes it.
#' @param alleles the gene-drop table, as \code{calcFEFG()} takes it.
#' @return A list: \code{feFg}, \code{calcFEFG()}'s list, and \code{fgSE},
#' \code{calcFGSE()}'s number.
#' @noRd
founderStatistics <- function(ped, alleles) {
  fc <- calcFounderContributions(ped, "calcFEFG")
  scan <- founderRetentionScan(fc$ped, alleles)
  r <- meanRetention(scan)
  feFg <- feFgFromRetention(fc$p, r)
  fgSE <- fgSEFromScan(fc$p, scan)
  list(feFg = feFg, fgSE = fgSE)
}
