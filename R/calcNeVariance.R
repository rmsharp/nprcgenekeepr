## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Calculate the variance effective population size
#'
#' Part of the Genetic Value Analysis
#'
#' The variance effective size measures the diversity lost to unequal family
#' sizes -- typically the dominant reducer of effective size in a harem colony,
#' where a few breeders produce most of the offspring. It is the mean-adjusted
#' Crow & Kimura (1970) form
#'
#' \deqn{N_e = \frac{N \bar{k} - 1}{\bar{k} - 1 + V_k / \bar{k}}}
#'
#' where \code{N} is the number of current living breeders, \eqn{\bar{k}} the
#' mean number of lifetime offspring among them, and \eqn{V_k} the variance of
#' those offspring counts. This general form makes no constant-size assumption
#' and reduces to the classic \code{(4N - 2) / (Vk + 2)} at exact replacement
#' (\eqn{\bar{k} = 2}); it is preferred over that bare form, which assumes
#' \eqn{\bar{k} \approx 2} and misstates the effective size when the mean
#' family size departs from replacement.
#'
#' The breeders are the current living breeders of \code{ped} (living animals
#' that appear as a sire or dam, excluding auto-generated unknown parents),
#' independent of which animals are selected as probands -- a different
#' population than the analysis-set founder statistics (\code{\link{calcFE}},
#' \code{\link{calcFG}}, \code{\link{calcGeneDiversity}}). Unlike the sex-ratio
#' effective size (\code{\link{calcNeSexRatio}}), breeders of every sex are
#' counted. When fewer than two living breeders are present the variance is
#' undefined and the result is \code{NA}.
#'
#' Like all effective-size estimators this idealizes a Wright-Fisher population
#' (constant size, discrete generations, random union of gametes); a managed
#' colony departs from those assumptions, so read the result as a
#' family-size-variance index rather than a literal head count.
#'
#' @param ped Pedigree data.frame with \code{id}, \code{sire}, and \code{dam};
#' \code{exit} is used to identify living animals when present.
#' @return The variance effective size, a single number; \code{NA} when there
#' are fewer than two living breeders.
#' @references Crow, J. F. and Kimura, M. (1970) \emph{An Introduction to
#' Population Genetics Theory}. Harper and Row, New York.
#' @family genetic value analysis
#' @seealso \code{\link{calcNeSexRatio}}, \code{\link{calcGeneDiversity}}
#' @export
#' @examples
#' ped <- data.frame(
#'   id = c("s1", "d1", "k1", "k2", "k3"),
#'   sire = c(NA, NA, "s1", "s1", "s1"),
#'   dam = c(NA, NA, "d1", "d1", "d1"),
#'   sex = c("M", "F", "M", "F", "F"),
#'   exit = c(NA, NA, NA, NA, NA),
#'   stringsAsFactors = FALSE
#' )
#' calcNeVariance(ped) # 2 breeders, equal families: (2*3-1)/(3-1) = 2.5
calcNeVariance <- function(ped) {
  breeders <- getLivingBreeders(ped)
  n <- length(breeders)
  if (n < 2L) {
    return(NA_real_)
  }
  counts <- findOffspring(breeders, ped)
  kbar <- mean(counts)
  vk <- stats::var(counts)
  (n * kbar - 1.0) / (kbar - 1.0 + vk / kbar)
}
