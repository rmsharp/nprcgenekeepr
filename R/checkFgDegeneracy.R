#' Founder-genome-equivalent degeneracy guard
#'
## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Part of the Genetic Value Analysis
#'
#' Shared check (issue #82) for the silent-collapse degeneracy in
#' \code{\link{calcFG}}, \code{\link{calcFEFG}}, and \code{calcFGSE}: a
#' contributing founder (\code{p > 0}) retained in zero gene-drop iterations
#' (\code{r == 0}) gives \code{p^2 / 0 = Inf}, which \code{na.rm} does not strip
#' (it removes only \code{NaN}), so the sum is \code{Inf} and \code{FG} silently
#' collapses to 0. This detects the case -- matching founders by NAME, since
#' \code{r} is id-sorted while \code{p} is in \code{getFounders()} order -- and
#' issues a warning so the three callers can return \code{NA} instead.
#'
#' @param p named numeric vector of founder mean contributions.
#' @param r named numeric vector of founder mean retentions.
#' @return \code{TRUE} (after issuing a warning) when a contributing founder has
#' zero retention; otherwise \code{FALSE}.
#' @noRd
checkFgDegeneracy <- function(p, r) {
  r <- r[names(p)] # align retention to contributions by NAME (Dragon D-3)
  if (any(!is.na(p) & p > 0L & !is.na(r) & r == 0L)) {
    warning(
      "Founder genome equivalents undefined: founder(s) with positive ",
      "contribution were retained in 0 of the gene-drop iterations; ",
      "raise the number of iterations (K)."
    )
    return(TRUE)
  }
  FALSE
}
