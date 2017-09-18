#' Combines two vectors of alleles by randomly selecting one allele
#' or the other at each position.
#'
#' @param a1 integer vector with first allele for each individual
#' @param a2 integer vector with second allele for each individual
#' \code{a1} and \code{a2} are equal length vectors of alleles for one
#' individual
#'
#' @return An integer vector with the result of sampling from \code{a1}
#' and \code{a2} according to Mendelian inheritance.
#' @export
chooseAlleles <- function(a1, a2) {
  s1 = sample(c(0, 1), length(a1), replace = TRUE)
  s2 = 1 - s1

  return((a1 * s1) + (a2 * s2))
}