## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Convenience function to make the initial available animal list
#'
#' @param candidates character vector of IDs of the animals available for
#' use in the group.
#' @param numGp integer value indicating the number of groups that should be
#' formed from the list of IDs. Default is 1.
#' @return Initial available animals list
#'
#' @noRd
makeAvailable <- function(candidates, numGp) {
  available <- list()
  for (i in 1L:numGp) {
    available[[i]] <- candidates
  }
  available
}
