## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Compute per-animal observed heterozygosity from marker genotypes
#'
#' Computes, for each individual, the fraction of its genotyped (non-missing)
#' loci at which it is heterozygous -- the standard "individual/multilocus
#' heterozygosity" statistic conventionally reported per animal (as opposed
#' to the per-locus population framing, which this function does not
#' compute; see \code{\link{markerExpectedHeterozygosity}} for the
#' population-level counterpart). A raw empirical proportion, not an
#' estimate of a hidden population parameter, so no bias correction applies.
#'
#' @param genotypeMatrix a character matrix as returned by
#' \code{\link{buildMarkerGenotypeMatrix}}: rows are individual \code{id}s,
#' columns are loci, and each cell is that individual's two alleles at that
#' locus, sorted and joined by \code{"/"} (or \code{NA} if not genotyped at
#' that locus).
#' @return A named numeric vector, one observed-heterozygosity value per
#' \code{id} (names taken from \code{rownames(genotypeMatrix)}), each in
#' \code{[0, 1]}. An individual with no non-missing loci returns \code{NA}.
#'
#' @references Nei, M. (1973). Analysis of gene diversity in subdivided
#' populations. \emph{Proceedings of the National Academy of Sciences USA},
#' 70(12), 3321-3323. \doi{10.1073/pnas.70.12.3321}
#'
#' @seealso \code{\link{markerExpectedHeterozygosity}},
#' \code{\link{buildMarkerGenotypeMatrix}}, \code{\link{markerKinship}}
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
#' genotypeMatrix <- buildMarkerGenotypeMatrix(markerGenotype)
#' markerObservedHeterozygosity(genotypeMatrix)
markerObservedHeterozygosity <- function(genotypeMatrix) {
  ids <- rownames(genotypeMatrix)
  nLoci <- ncol(genotypeMatrix)

  alleles <- strsplit(genotypeMatrix, "/")
  het <- vapply(alleles, function(a) {
    if (length(a) != 2L) NA else a[1L] != a[2L]
  }, logical(1L))
  hetMat <- matrix(het, nrow = length(ids), ncol = nLoci,
                    dimnames = dimnames(genotypeMatrix))

  apply(hetMat, 1L, function(row) {
    nonMissing <- row[!is.na(row)]
    if (length(nonMissing) == 0L) {
      return(NA_real_)
    }
    sum(nonMissing) / length(nonMissing)
  })
}

#' Compute per-locus and population-wide expected heterozygosity from marker genotypes
#'
#' Computes Nei's gene diversity (the standard \eqn{He = 1 - \sum p_i^2}
#' form, where \eqn{p_i} is the population frequency of allele \eqn{i} at a
#' locus) for each locus from the non-missing genotype calls at that locus,
#' plus the unweighted mean across loci as a population-wide summary. This
#' is the plain (uncorrected) estimator -- the small-sample-size-corrected
#' variant (Nei & Roychoudhury 1974) is not computed here.
#'
#' @param genotypeMatrix a character matrix as returned by
#' \code{\link{buildMarkerGenotypeMatrix}}: rows are individual \code{id}s,
#' columns are loci, and each cell is that individual's two alleles at that
#' locus, sorted and joined by \code{"/"} (or \code{NA} if not genotyped at
#' that locus).
#' @return A list with two elements: \code{perLocus}, a named numeric vector
#' of expected heterozygosity per locus (names taken from
#' \code{colnames(genotypeMatrix)}); and \code{meanHe}, the unweighted mean
#' of \code{perLocus} across all loci.
#'
#' @references Nei, M. (1973). Analysis of gene diversity in subdivided
#' populations. \emph{Proceedings of the National Academy of Sciences USA},
#' 70(12), 3321-3323. \doi{10.1073/pnas.70.12.3321}
#'
#' @seealso \code{\link{markerObservedHeterozygosity}},
#' \code{\link{buildMarkerGenotypeMatrix}}, \code{\link{markerKinship}}
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
#' genotypeMatrix <- buildMarkerGenotypeMatrix(markerGenotype)
#' markerExpectedHeterozygosity(genotypeMatrix)
markerExpectedHeterozygosity <- function(genotypeMatrix) {
  loci <- colnames(genotypeMatrix)

  perLocus <- vapply(loci, function(locus) {
    col <- genotypeMatrix[, locus]
    col <- col[!is.na(col)]
    alleleCalls <- unlist(strsplit(col, "/"))
    freqs <- table(alleleCalls) / length(alleleCalls)
    1 - sum(freqs^2)
  }, numeric(1L))
  names(perLocus) <- loci

  list(perLocus = perLocus, meanHe = mean(perLocus))
}
