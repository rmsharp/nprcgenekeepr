## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Pivot a long-format marker genotype table into a wide genotype matrix
#'
#' Converts a validated long-format marker genotype table (see
#' \code{\link{checkMarkerGenotypeFile}}) into a wide \code{id} x
#' \code{locus} character matrix, the input shape \code{\link{markerKinship}}
#' consumes.
#'
#' @details
#' Row and column order follow first appearance in \code{genotype}, not a
#' string sort -- a string sort would place \code{"L10"} before
#' \code{"L2"} for any panel with more than nine loci, silently scrambling
#' locus order.
#'
#' @param genotype dataframe with long-format marker genotype data, as
#' returned by \code{\link{checkMarkerGenotypeFile}}: columns \code{id},
#' \code{locus}, \code{allele1}, \code{allele2}.
#' @return A character matrix with one row per unique \code{id} and one
#' column per unique \code{locus}. Each cell holds that individual's two
#' alleles at that locus, sorted alphabetically and joined by \code{"/"}
#' (e.g. \code{"A/B"}), or \code{NA} when that individual has no genotype
#' record at that locus.
#'
#' @seealso \code{\link{checkMarkerGenotypeFile}}, \code{\link{markerKinship}}
#' @export
#' @examples
#' library(nprcgenekeepr)
#' markerGenotype <- data.frame(
#'   id = c("A", "A", "B", "B"),
#'   locus = c("L1", "L2", "L1", "L2"),
#'   allele1 = c("A", "A", "A", "A"),
#'   allele2 = c("A", "B", "B", "B"),
#'   stringsAsFactors = FALSE
#' )
#' buildMarkerGenotypeMatrix(markerGenotype)
buildMarkerGenotypeMatrix <- function(genotype) {
  ids <- unique(genotype$id)
  loci <- unique(genotype$locus)

  mat <- matrix(NA_character_, nrow = length(ids), ncol = length(loci),
                dimnames = list(ids, loci))

  lo <- pmin(genotype$allele1, genotype$allele2)
  hi <- pmax(genotype$allele1, genotype$allele2)
  # A "lo/hi" genotype string, not a file path -- file.path() doesn't apply.
  genoStr <- paste0(lo, "/", hi) # nolint: paste_linter.

  mat[cbind(match(genotype$id, ids), match(genotype$locus, loci))] <- genoStr
  mat
}
