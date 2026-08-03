## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Check a long-format multi-locus marker genotype file
#'
#' Validates the structure and legal domain of a long-format marker
#' genotype table (one row per \code{id} x \code{locus}), the input format
#' for the marker-based (KING-robust) kinship estimator
#' (\code{\link{markerKinship}}). This is a new, sibling schema to the
#' single-locus \code{first_name}/\code{second_name} genotype format checked
#' by \code{\link{checkGenotypeFile}} -- that function, and everything
#' downstream of it (\code{\link{addGenotype}},
#' \code{\link{geneDrop}}), is untouched by this one.
#'
#' @details
#' The KING-robust kinship estimator (Manichaikul et al. 2010) is defined
#' for biallelic markers only -- every genotype is classified as
#' homozygous-reference, heterozygous, or homozygous-alternate, with no
#' representation for a third allele at a locus. A locus with more than two
#' distinct alleles observed anywhere in the input is therefore rejected
#' outright, rather than silently producing an uninterpretable kinship
#' estimate.
#'
#' @param genotype dataframe with long-format marker genotype data: exactly
#' four columns, \code{id}, \code{locus}, \code{allele1}, \code{allele2} (one
#' row per individual x locus).
#' @return The genotype dataframe, checked to ensure the column count,
#' first-column identity, per-locus allele count, and row uniqueness are all
#' valid. The returned dataframe has its column names forced to
#' \code{c("id", "locus", "allele1", "allele2")}.
#'
#' @references Manichaikul, A., Mychaleckyj, J. C., Rich, S. S., Daly, K.,
#' Sale, M., & Chen, W.-M. (2010). Robust relationship inference in
#' genome-wide association studies. \emph{Bioinformatics}, 26(22), 2867-2873.
#' \doi{10.1093/bioinformatics/btq559}
#'
#' @seealso \code{\link{buildMarkerGenotypeMatrix}}, \code{\link{markerKinship}}
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
#' checkMarkerGenotypeFile(markerGenotype)
checkMarkerGenotypeFile <- function(genotype) {
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

  alleleCounts <- tapply(
    c(genotype$allele1, genotype$allele2),
    rep(genotype$locus, 2L),
    function(a) length(unique(a[!is.na(a)]))
  )
  offendingLoci <- names(alleleCounts)[alleleCounts > 2L]
  if (length(offendingLoci) > 0L) {
    stop("Marker genotype file has one or more loci with more than two ",
         "distinct alleles (the KING-robust estimator requires biallelic ",
         "markers): ", toString(offendingLoci), ".")
  }

  genotype
}
