## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Calculate the standard error of genome uniqueness
#'
#' Part of Genetic Value Analysis
#'
#' Genome uniqueness (\code{\link{calcGU}}) is a Monte Carlo estimate: it is the
#' average, over the gene-drop iterations, of the proportion of an animal's two
#' allele copies that are population-rare. Because it is an average over
#' independent simulated iterations, it carries sampling error that shrinks as
#' the number of iterations grows.
#'
#' For animal \code{i} let \code{m_ik = rare[i, k] / 2} be the per-iteration
#' value in iteration \code{k} (so the mean of \code{m_ik} over the \code{K}
#' iterations equals \code{gu_i / 100}). This function returns the exact
#' Monte Carlo standard error of that mean, on the same percentage scale as
#' \code{\link{calcGU}}:
#'
#' \deqn{guSE_i = 100 \times \sqrt{\frac{var(m_{i\cdot})}{K}}}
#'
#' The standard error is computed from the same per-iteration rare-allele matrix
#' (\code{\link{calcA}}) that \code{\link{calcGU}} averages, so it is correct
#' for any \code{threshold} / \code{byID} without a closed-form approximation.
#' An animal whose rare-allele count does not vary across iterations has a
#' standard error of 0.
#'
#' @param alleles dataframe containing an \code{AlleleTable} (the same input
#' \code{\link{calcGU}} takes): one integer column per gene-drop iteration,
#' followed by an \code{id} column and a \code{parent} column. Produced by
#' \code{geneDrop()}.
#' @inheritParams calcGU
#' @param byID logical variable of length 1 that is passed through to
#' eventually be used by \code{alleleFreq()}, which calculates the count of each
#' allele in the provided vector. If \code{byID} is TRUE and ids are provided,
#' the function will only count the unique alleles for an individual
#' (homozygous alleles will be counted as 1).
#' @param pop character vector with animal IDs to consider as the population of
#' interest, otherwise all animals will be considered. The default is NULL.
#' @return Dataframe \code{rows: id, col: guSE}
#'  A single-column table of genome-uniqueness standard errors as percentages.
#'  Rownames are set to 'id' values that are part of the population.
#'
#' @seealso \code{\link{calcGU}}, \code{\link{calcA}}, \code{\link{reportGV}}
#' @family genetic value analysis
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped1Alleles <- nprcgenekeepr::ped1Alleles
#' guSE <- calcGUSE(ped1Alleles, threshold = 3, byID = FALSE, pop = NULL)
calcGUSE <- function(alleles, threshold = 1L, byID = FALSE, pop = NULL) {
  if (!is.null(pop)) {
    alleles <- alleles[alleles$id %in% pop, ]
  }

  # The per-iteration rare-allele counts calcGU() averages. m_ik = rare[i, k]/2
  # is the iteration-k value whose mean over iterations equals gu_i / 100.
  rare <- calcA(alleles, threshold, byID)
  iterations <- sum(!(colnames(alleles) %in% c("id", "parent")))
  perColumn <- rare / 2L

  # Exact Monte Carlo standard error of the mean, on the gu percentage scale.
  guSE <- sqrt(apply(perColumn, 1L, stats::var) / iterations) * 100L
  guSE <- as.data.frame(guSE)

  guSE
}
