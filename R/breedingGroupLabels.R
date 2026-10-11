## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Names of the boxes Breeding Groups shows
#'
#' The one place Breeding Groups names its boxes, so the Groups heading, the
#' Statistics row and the Group Detail selector agree. Every box is "Group i",
#' except that when some animals fit no group the last box holds them and is
#' called "Unused animals" (it is not a group).
#'
#' @param n Integer number of boxes the selected candidate grouping has,
#' counting the last box of unused animals when there is one.
#' @param hasUnused Logical, \code{TRUE} when the last of the \code{n} boxes
#' holds the animals that fit no group. Anything other than \code{TRUE} is
#' treated as \code{FALSE}.
#' @return A character vector of length \code{n}: \code{"Group 1"} ...
#' \code{"Group n"}, with the last element \code{"Unused animals"} when
#' \code{hasUnused} is \code{TRUE}.
#' @noRd
breedingGroupLabels <- function(n, hasUnused = FALSE) {
  labels <- paste("Group", seq_len(n))
  if (isTRUE(hasUnused) && n >= 1L) {
    labels[n] <- "Unused animals"
  }
  labels
}
