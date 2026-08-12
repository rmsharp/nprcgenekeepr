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
#' @seealso \code{\link{checkMarkerGenotypeFile}},
#' \code{\link{buildMarkerGenotypeMatrix}}, \code{\link{kinship}}
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
  nLoci <- ncol(genotypeMatrix)

  kmat <- diag(0.5, n, n)
  dimnames(kmat) <- list(ids, ids)

  if (n < 2L) {
    return(kmat)
  }

  ## Vectorized matrix algebra (issue #152 Slice 2, D5), replacing the
  ## previous O(n^2*L) nested-pair loop. Every intermediate quantity below
  ## (nAaI, nAaJ, nAaAa, nAAaa) is an exact integer count of 0/1 indicators,
  ## so this reproduces the original loop's output bit-for-bit (integer
  ## addition is associative regardless of summation order) -- proven by
  ## the golden-master regression test in test_markerKinship.R.
  alleles <- strsplit(genotypeMatrix, "/", fixed = TRUE)
  a1 <- vapply(alleles, function(a) {
    if (length(a) != 2L) NA_character_ else a[1L]
  }, character(1L))
  a2 <- vapply(alleles, function(a) {
    if (length(a) != 2L) NA_character_ else a[2L]
  }, character(1L))
  het <- a1 != a2
  genotyped <- !is.na(genotypeMatrix)

  Hz <- matrix(ifelse(is.na(het), 0L, het), nrow = n, ncol = nLoci)
  Gz <- matrix(as.numeric(genotyped), nrow = n, ncol = nLoci)

  ## Per-locus reference allele -- the alphabetically first allele observed
  ## at that locus (an arbitrary but locus-internally-consistent choice; it
  ## need not match any biological "reference," only be applied identically
  ## to both members of every pair at that locus). Used only to encode a
  ## 0/1/2 reference-allele dose per cell, letting "opposite homozygotes"
  ## (N_AAaa) reduce to two more integer-count matrix products.
  refAllele <- vapply(seq_len(nLoci), function(l) {
    obs <- genotypeMatrix[, l]
    obs <- obs[!is.na(obs)]
    calls <- unique(unlist(strsplit(obs, "/", fixed = TRUE)))
    if (length(calls) == 0L) NA_character_ else sort(calls)[1L]
  }, character(1L))
  refVec <- as.vector(matrix(refAllele, nrow = n, ncol = nLoci, byrow = TRUE))
  dose <- (a1 == refVec) + (a2 == refVec)
  dose <- matrix(dose, nrow = n, ncol = nLoci)
  Z0 <- matrix(ifelse(is.na(dose), 0L, dose == 0L), nrow = n, ncol = nLoci)
  Z2 <- matrix(ifelse(is.na(dose), 0L, dose == 2L), nrow = n, ncol = nLoci)

  A <- Hz %*% t(Gz)     # A[i, j] = N_Aa(i), restricted to loci shared with j
  nAaAaMat <- Hz %*% t(Hz)
  nAAaaMat <- Z0 %*% t(Z2) + Z2 %*% t(Z0)
  nAaIMat <- A
  nAaJMat <- t(A)
  nMinMat <- pmin(nAaIMat, nAaJMat)

  phi <- 0.5 + (2L * nAaAaMat - 4L * nAAaaMat - nAaIMat - nAaJMat) /
    (4L * nMinMat)

  ## Undefined-kinship pairs (nMin == 0): preserve the original loop's
  ## per-pair warning (naming the ids, in i-then-j nested-loop order) and
  ## NA result, rather than a single vectorized warning that would lose
  ## both the per-pair message and the original ordering.
  undefined <- which(nMinMat == 0L & upper.tri(nMinMat), arr.ind = TRUE)
  if (nrow(undefined) > 0L) {
    undefined <- undefined[order(undefined[, "row"], undefined[, "col"]),
                            , drop = FALSE]
    for (k in seq_len(nrow(undefined))) {
      i <- undefined[k, "row"]
      j <- undefined[k, "col"]
      warning("markerKinship: '", ids[i], "' and '", ids[j], "' share no ",
              "heterozygous locus between them; kinship is undefined for ",
              "this pair (returning NA).")
      phi[i, j] <- NA_real_
      phi[j, i] <- NA_real_
    }
  }

  diag(phi) <- 0.5
  dimnames(phi) <- list(ids, ids)
  phi
}
