## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Estimate pairwise kinship directly from marker genotypes (KING-robust)
#'
#' Estimates a marker-based kinship matrix, independent of pedigree, using
#' the "between-family" KING-robust estimator of Manichaikul et al. (2010),
#' Equation 11 -- the estimator KING, PLINK2, \code{SNPRelate::snpgdsIBDKING},
#' and \code{GENESIS::kingToMatrix} all implement under the name
#' "KING-robust". Unlike \code{\link{kinship}} (which is purely
#' pedigree-derived), this function never looks at parentage -- it is a
#' genotype-only check, matching the issue's own framing of an independent
#' relatedness estimate.
#'
#' @details
#' For a pair of individuals \eqn{i, j}, over the loci genotyped in both:
#' \deqn{\hat\phi_{ij} = 0.5 + \frac{2 N_{AaAa} - 4 N_{AAaa} - N_{Aa}^{(i)} - N_{Aa}^{(j)}}{4 \min(N_{Aa}^{(i)}, N_{Aa}^{(j)})}}
#' where \eqn{N_{AaAa}} counts loci at which both individuals are
#' heterozygous, \eqn{N_{AAaa}} counts loci at which they have opposite
#' homozygous genotypes (identity-by-state 0), and \eqn{N_{Aa}^{(i)}}/
#' \eqn{N_{Aa}^{(j)}} count each individual's own heterozygous loci (all
#' restricted to the shared, jointly-non-missing locus set). The estimator
#' requires biallelic markers (see \code{\link{checkMarkerGenotypeFile}}) and
#' is not bounded below by zero -- a negative estimate is informative (more
#' divergent ancestry than the reference sample), not an error, and is not
#' clipped.
#'
#' The diagonal is set to \code{0.5} by definition (self-kinship), matching
#' \code{\link{kinship}}'s convention, rather than evaluated from the formula
#' above -- which divides by zero whenever an individual has no heterozygous
#' loci at all.
#'
#' When neither individual in a pair has a shared heterozygous locus (the
#' formula's denominator is zero), the pair's kinship is undefined; that
#' pair's entry is \code{NA} and a warning names the pair.
#'
#' @param genotypeMatrix a character matrix as returned by
#' \code{\link{buildMarkerGenotypeMatrix}}: rows are individual \code{id}s,
#' columns are loci, and each cell is that individual's two alleles at that
#' locus, sorted and joined by \code{"/"} (or \code{NA} if not genotyped at
#' that locus).
#' @return A numeric \code{id} x \code{id} matrix (symmetric, diagonal
#' \code{0.5}), the same shape \code{\link{kinship}} returns.
#'
#' @references Manichaikul, A., Mychaleckyj, J. C., Rich, S. S., Daly, K.,
#' Sale, M., & Chen, W.-M. (2010). Robust relationship inference in
#' genome-wide association studies. \emph{Bioinformatics}, 26(22), 2867-2873.
#' \doi{10.1093/bioinformatics/btq559}
#'
#' @seealso \code{\link{checkMarkerGenotypeFile}}, \code{\link{buildMarkerGenotypeMatrix}},
#' \code{\link{kinship}}
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
#' markerKinship(genotypeMatrix)
markerKinship <- function(genotypeMatrix) {
  ids <- rownames(genotypeMatrix)
  n <- length(ids)

  alleles <- strsplit(genotypeMatrix, "/")
  het <- vapply(alleles, function(a) {
    if (length(a) != 2L) NA else a[1L] != a[2L]
  }, logical(1L))
  hetMat <- matrix(het, nrow = n, ncol = ncol(genotypeMatrix),
                    dimnames = dimnames(genotypeMatrix))

  kmat <- diag(0.5, n, n)
  dimnames(kmat) <- list(ids, ids)

  if (n < 2L) {
    return(kmat)
  }

  for (i in seq_len(n - 1L)) {
    for (j in (i + 1L):n) {
      shared <- !is.na(genotypeMatrix[i, ]) & !is.na(genotypeMatrix[j, ])
      hetI <- hetMat[i, shared]
      hetJ <- hetMat[j, shared]
      genoI <- genotypeMatrix[i, shared]
      genoJ <- genotypeMatrix[j, shared]

      nAaI <- sum(hetI)
      nAaJ <- sum(hetJ)
      nAaAa <- sum(hetI & hetJ)
      nAAaa <- sum(!hetI & !hetJ & genoI != genoJ)

      nMin <- min(nAaI, nAaJ)
      if (nMin == 0L) {
        warning("markerKinship: '", ids[i], "' and '", ids[j], "' share no ",
                "heterozygous locus between them; kinship is undefined for ",
                "this pair (returning NA).")
        phi <- NA_real_
      } else {
        phi <- 0.5 + (2L * nAaAa - 4L * nAAaa - nAaI - nAaJ) / (4L * nMin)
      }
      kmat[i, j] <- phi
      kmat[j, i] <- phi
    }
  }
  kmat
}
