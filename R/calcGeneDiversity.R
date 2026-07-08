## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Calculate gene diversity from founder genome equivalents
#'
#' Part of the Genetic Value Analysis
#'
#' Gene diversity is the expected heterozygosity retained relative to the
#' founding gene pool, \code{GD = 1 - 1 / (2 * FG)}, where \code{FG} is the
#' founder genome equivalents (see \code{\link{calcFG}}). It summarizes how
#' much of the founders' allelic diversity still survives: 0 means none is
#' retained, and it approaches (never reaches) 1 as \code{FG} grows.
#'
#' \code{GD} is a diversity proportion, not a count of effective individuals,
#' and it is computed over the same analysis set as \code{FG}. \code{NA}
#' propagates: when \code{FG} is \code{NA} (the zero-retention degeneracy
#' \code{calcFG()} reports), \code{GD} is \code{NA}.
#'
#' @param fg Founder genome equivalents scalar, as returned by \code{calcFG()}
#' or the \code{$FG} element of \code{calcFEFG()}. \code{NA} yields \code{NA}.
#' @return The gene diversity \code{GD = 1 - 1 / (2 * fg)}: a single number in
#' \code{[0, 1)}, or \code{NA} when \code{fg} is \code{NA}.
#' @family genetic value analysis
#' @export
#' @examples
#' calcGeneDiversity(20) # 0.975
#' calcGeneDiversity(52.75) # gene diversity at the qcPed FG
calcGeneDiversity <- function(fg) {
  1L - 1L / (2L * fg)
}
