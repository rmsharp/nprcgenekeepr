#' Convenience function to make the initial available animal list
#'
#' @return initial available animals list
#'
#'
#' @param candidates character vector of IDs of the animals available for
#' use in the group.
#' @param numGp integer value indicating the number of groups that should be
#' formed from the list of IDs. Default is 1.
#' @export
makeAvailable <- function(candidates, numGp) {
  available <- list()
  for (i in 1:numGp) {
    available[[i]] <- candidates
  }
  available
}