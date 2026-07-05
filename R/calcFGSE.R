## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Calculate the standard error of founder genome equivalents
#'
#' Part of the Genetic Value Analysis
#'
#' Founder genome equivalents (\code{\link{calcFG}}) is a Monte Carlo estimate:
#' \code{FG = 1 / sum(p^2 / r)}, where the founder contributions \code{p} are
#' deterministic but the mean allelic retention values \code{r}
#' (\code{\link{calcRetention}}) are averages over the gene-drop iterations, so
#' \code{FG} carries sampling error that shrinks as the number of iterations
#' grows. Unlike genome uniqueness (a mean, whose standard error is a column
#' variance), \code{FG} is a nonlinear function of \code{r}, so its standard
#' error is obtained by the delta method (first-order linearization).
#'
#' With \code{S = sum(p_f^2 / r_f)} and \code{FG = 1 / S}, the gradient is
#' \code{dFG/dr_f = FG^2 * p_f^2 / r_f^2}. Writing \code{R} for the founder-by-
#' iteration retention matrix (each column an independent gene drop), the
#' influence series \code{y_k = sum_f (dFG/dr_f) * R[f, k]} has
#' \code{sd(y) / sqrt(K)} equal to the full delta-method standard error,
#' including the within-iteration covariance among founders. This influence form
#' is used because it folds in that covariance automatically and never forms the
#' founder-by-founder covariance matrix.
#'
#' Founders are matched between \code{p} and \code{r} by name (not position), so
#' the result is correct even when the founders are not in sorted pedigree
#' order.
#'
#' A contributing founder (\code{p > 0}) that is retained in zero of the
#' iterations (\code{r == 0}) makes \code{FG} undefined (the same
#' degeneracy that \code{\link{calcFG}} now reports as \code{NA}); in that
#' case this function returns \code{NA} with a warning advising more
#' iterations. Founders that do not contribute to the current population
#' (\code{p == 0}) are dropped, so the standard error refers to exactly the
#' founder set \code{FG} is computed from.
#'
#' @param ped the pedigree information in datatable format.  Pedigree
#' (req. fields: id, sire, dam, gen, population).
#' The pedigree must have no partial parentage (every animal has both parents
#' known or both unknown); \code{calcFGSE} stops with an error otherwise.
#' @param alleles dataframe containing an \code{AlleleTable}: one column per
#' gene-drop iteration, followed by an \code{id} column and a \code{parent}
#' column. Produced by \code{geneDrop()}; the same input
#' \code{\link{calcFG}} takes.
#' @return A single numeric value: the Monte Carlo sampling standard error
#' of the colony founder-genome-equivalent estimate, on the same scale as
#' \code{\link{calcFG}}. \code{NA} (with a warning) when a contributing founder
#' has zero retention.
#'
#' @seealso \code{\link{calcFG}}, \code{\link{calcFEFG}},
#' \code{\link{calcRetention}}, \code{\link{calcGUSE}}, \code{\link{reportGV}}
#' @family genetic value analysis
#' @export
#' @examples
#' library(nprcgenekeepr)
#' data("lacy1989Ped")
#' data("lacy1989PedAlleles")
#' calcFGSE(lacy1989Ped, lacy1989PedAlleles)
calcFGSE <- function(ped, alleles) {
  ## Founder contributions (deterministic) and the toCharacter()-coerced
  ## pedigree, shared with calcFG()/calcFEFG() via calcFounderContributions().
  fc <- calcFounderContributions(ped, "calcFG")
  pedc <- fc$ped
  founders <- getFounders(pedc)
  descendants <- pedc$id[pedc$population & !(pedc$id %in% founders)]

  ## Rebuild the per-iteration retention matrix calcRetention() averages: for
  ## each founder allele copy, a 0/1 indicator of presence among the descendant
  ## alleles in each iteration column.
  founderAlleles <- alleles[alleles$id %in% founders, c("id", "V1")]
  colnames(founderAlleles) <- c("id", "allele")
  descAlleles <- alleles[
    alleles$id %in% descendants,
    !(colnames(alleles) %in% c("id", "parent"))
  ]
  retained <- apply(descAlleles, 2L, function(a) founderAlleles$allele %in% a)
  storage.mode(retained) <- "numeric"
  ## Collapse the two copies per founder: F x K matrix in {0, 0.5, 1}; its row
  ## means equal calcRetention() and its rows are founder-id-sorted.
  retentionMatrix <- rowsum(retained, founderAlleles$id) / 2L
  rhat <- rowMeans(retentionMatrix)
  p <- fc$p[names(rhat)] # align contributions to retention rows by NAME
  k <- ncol(retentionMatrix)

  ## Hard-fail: a contributing founder retained in zero drops leaves FG
  ## (and its gradient) undefined -- return NA rather than a finite SE for
  ## a collapsed FG.
  if (checkFgDegeneracy(p, rhat)) {
    return(NA_real_)
  }

  ## Drop non-contributing (p == 0 -> 0/0) and any missing-retention founders so
  ## the SE refers to the same founder set as FG.
  keep <- !is.na(rhat) & rhat > 0L & !is.na(p)
  fg <- 1L / sum((p[keep]^2L) / rhat[keep])
  gradient <- numeric(length(rhat))
  gradient[keep] <- fg^2L * (p[keep]^2L) / (rhat[keep]^2L)
  influence <- as.numeric(crossprod(gradient, retentionMatrix)) # length K
  stats::sd(influence) / sqrt(k)
}
