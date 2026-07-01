## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Make the initial grpNum list
#'
#' @param numGp integer value indicating the number of groups that should be
#' formed from the list of IDs. Default is 1.
#' @return Initial grpNum list
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ## Create the initial grpNum list for three groups
#' grpNum <- makeGroupNum(numGp = 3L)
#' grpNum
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
#' @param numGp integer value indicating the number of groups that should be
#' formed from the list of IDs. Default is 1.
#' @return Initial grpNum list
#'
#' @seealso \code{\link{makeGroupNum}}
#' @export
makeGrpNum <- function(numGp) {
  .Deprecated("makeGroupNum")
  makeGroupNum(numGp)
}
