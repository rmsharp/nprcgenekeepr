#' Calculates the mean kinship for each animal in a kinship matrix
#'
#' The mean kinship of animal \emph{i} is \deqn{MK_i = \Sigma f_ij / N},
#' in which the summation is over all animals, \emph{j}, including the kinship
#' of animal \emph{i} to itself.
#'
#' @param kmat a numeric matrix of pairwise kinship coefficients.
#' Animal IDs are the row and column names.
#'
#' @return A named numeric vecter of average kinship coefficients for each
#' animal ID. Elements are named with the IDs from the columns of kmat.
#' @export
meanKinship <- function(kmat) {
  return(colMeans(kmat, na.rm = TRUE))
}