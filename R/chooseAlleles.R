## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Combine two allele vectors by Mendelian sampling
#'
#' @param a1 integer vector with the alleles of one parent, one per simulated
#' iteration
#' @param a2 integer vector with the other alleles of the same parent, one per
#' simulated iteration. \code{a1} and \code{a2} are expected to be equal length
#' vectors; if they are not, the shorter is recycled silently.
#' @return An integer vector with the result of sampling from \code{a1}
#' and \code{a2} according to Mendelian inheritance.
#'
#' @export
#' @examples
#' chooseAlleles(0L:4L, 5L:9L)
chooseAlleles <- function(a1, a2) {
  s1 <- sample(c(0L, 1L), length(a1), replace = TRUE)
  s2 <- 1L - s1

  (a1 * s1) + (a2 * s2)
}
