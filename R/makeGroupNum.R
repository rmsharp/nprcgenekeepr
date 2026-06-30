## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Convenience function to make the initial grpNum list
#'
#' @return Initial grpNum list
#'
#' @param numGp integer value indicating the number of groups that should be
#' formed from the list of IDs. Default is 1.
#' @export
makeGroupNum <- function(numGp) {
  grpNum <- list()
  grpNum[1L:numGp] <- 1L:numGp
  grpNum
}

#' Deprecated alias for makeGroupNum
#'
#' \code{makeGrpNum} has been renamed to \code{\link{makeGroupNum}} for
#' consistency with \code{\link{makeGroupMembers}}. It remains as a deprecated
#' wrapper that issues a warning and then calls \code{makeGroupNum}.
#'
#' @return Initial grpNum list
#'
#' @param numGp integer value indicating the number of groups that should be
#' formed from the list of IDs. Default is 1.
#' @seealso \code{\link{makeGroupNum}}
#' @export
makeGrpNum <- function(numGp) {
  .Deprecated("makeGroupNum")
  makeGroupNum(numGp)
}
