#' Identifies the founders in a pedigree
#'
## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Part of Pedigree Curation
#'
#' A founder is an animal whose sire and dam are both unknown (\code{NA}).
#' Animals with exactly one known parent (partial parentage) are
#' \strong{not} founders.
#'
#' @return A logical vector with one element per row of \code{ped} that is
#' \code{TRUE} for each animal whose sire and dam are both \code{NA}. The
#' result never contains \code{NA}.
#'
#' @param ped a pedigree \code{data.frame} with (at least) the columns
#' \code{sire} and \code{dam}.
#' @export
#' @seealso \code{\link{getFounders}} for the founder \code{id} values.
#' @examples
#' library(nprcgenekeepr)
#' ped <- data.frame(
#'   id = c("A", "B", "C", "D", "E", "F", "G"),
#'   sire = c(NA, NA, "A", "A", NA, "D", "D"),
#'   dam = c(NA, NA, "B", "B", NA, "E", "E"),
#'   stringsAsFactors = FALSE
#' )
#' isFounder(ped)
isFounder <- function(ped) {
  is.na(ped$sire) & is.na(ped$dam)
}
