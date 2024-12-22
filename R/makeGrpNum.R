#' Convenience function to make the initial grpNum list
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' @return Initial grpNum list
#'
#' @param numGp integer value indicating the number of groups that should be
#' formed from the list of IDs. Default is 1.
#' @noRd
makeGrpNum <- function(numGp) {
  grpNum <- list()
  grpNum[1:numGp] <- 1:numGp
  grpNum
}
