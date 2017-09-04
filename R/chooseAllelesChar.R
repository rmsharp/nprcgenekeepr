#' Combines two vectors of alleles
#'
#' Combines two vectors by randomly selecting one allele
#' or the other at each position. Alleles may be of any class that
#' does not require attributes as the vectors are combined with \code{c()}.
#'
#' @param a1 vector with first parent alleles for each individual
#' @param a2 vector with second parent alleles for each individual
#' \code{a1} and \code{a2} are equal length vectors of alleles for one
#' individual
#'
#' @return An integer vector with the result of sampling from \code{a1}
#' and \code{a2} according to Mendelian inheritance.
#' @export
chooseAllelesChar <- function(a1, a2) {
  s = sample(1:(2 * length(a1)), replace = FALSE)
  return(c(a1, a2)[s])
}