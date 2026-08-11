## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Check a long-format multi-locus marker genotype file, multiallelic-tolerant
#'
#' Validates the structure of a long-format marker genotype table (one row
#' per \code{id} x \code{locus}), the same schema
#' \code{\link{checkMarkerGenotypeFile}} checks -- but, unlike that function,
#' does not require every locus to be biallelic. This is a new, sibling
#' validator for the linkage-aware and haplotype-block metrics family (issue
#' #153): real colony marker panels (e.g. microsatellite/STR panels) are
#' routinely multiallelic, a data shape the KING-robust kinship estimator
#' checked by \code{\link{checkMarkerGenotypeFile}} cannot represent, but
#' which \code{\link{buildMarkerGenotypeMatrix}} pivots without error.
#' \code{\link{checkMarkerGenotypeFile}} itself, and everything downstream of
#' it (\code{\link{markerKinship}}), is untouched by this function.
#'
#' @details
#' All of \code{\link{checkMarkerGenotypeFile}}'s structural checks are
#' retained -- exactly four columns, \code{id} as the first column, no
#' duplicate \code{id} x \code{locus} rows -- except the per-locus
#' more-than-two-distinct-alleles rejection, which is deliberately omitted.
#'
#' @param genotype dataframe with long-format marker genotype data: exactly
#' four columns, \code{id}, \code{locus}, \code{allele1}, \code{allele2} (one
#' row per individual x locus).
#' @return The genotype dataframe, checked to ensure the column count,
#' first-column identity, and row uniqueness are all valid. The returned
#' dataframe has its column names forced to \code{c("id", "locus", "allele1",
#' "allele2")}.
#'
#' @seealso \code{\link{checkMarkerGenotypeFile}},
#' \code{\link{buildMarkerGenotypeMatrix}}
#' @export
#' @examples
#' library(nprcgenekeepr)
#' markerGenotype <- data.frame(
#'   id = c("W", "X", "Y", "Z"),
#'   locus = c("L1", "L1", "L1", "L1"),
#'   allele1 = c("A", "A", "A", "A"),
#'   allele2 = c("B", "C", "A", "D"),
#'   stringsAsFactors = FALSE
#' )
#' checkLinkageMarkerGenotypeFile(markerGenotype)
checkLinkageMarkerGenotypeFile <- function(genotype) {
  cols <- names(genotype)
  if (length(cols) != 4L) {
    stop("Marker genotype file must have exactly four columns: id, locus, ",
         "allele1, allele2.")
  }
  if (!grepl("id", cols[1L], ignore.case = TRUE)) {
    stop("Marker genotype file must have 'id' as the first column.")
  }
  names(genotype) <- c("id", "locus", "allele1", "allele2")

  isDupe <- duplicated(genotype[c("id", "locus")])
  if (any(isDupe)) {
    dupes <- unique(paste(genotype$id[isDupe], genotype$locus[isDupe],
                           sep = " x "))
    stop("Marker genotype file has duplicate id x locus row(s): ",
         toString(dupes), ".")
  }

  genotype
}
