## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Group members that have no row in the pedigree
#'
#' The one definition of "a formed group holds an animal the pedigree lacks":
#' \code{\link{getGeneticDiversityStats}} stops on it, and the Genetic
#' Diversity page and the Breeding Groups Groups, Statistics and Group Detail
#' pages say so in one sentence (through
#' \code{.anyGroupMemberMissingFromPedigree}), so they cannot disagree.
#'
#' @param groups list of character vectors of animal IDs.
#' @param ped data frame with an \code{id} column.
#' @return character vector of the distinct member IDs with no row in
#'   \code{ped} (zero length when every member has one).
#' @noRd
.groupMembersMissingFromPedigree <- function(groups, ped) {
  members <- unlist(groups, use.names = FALSE)
  unique(members[!members %in% ped$id])
}

#' Does a formed group hold an animal the pedigree lacks?
#'
#' The yes/no form of \code{.groupMembersMissingFromPedigree}, for the pages
#' that show a sentence in place of tables. Either argument may be \code{NULL}
#' (no groups formed yet, no pedigree loaded), which is "no".
#'
#' @param groups list of character vectors of animal IDs, or \code{NULL}.
#' @param ped data frame with an \code{id} column, or \code{NULL}.
#' @return \code{TRUE} or \code{FALSE}.
#' @noRd
.anyGroupMemberMissingFromPedigree <- function(groups, ped) {
  !is.null(groups) && !is.null(ped) &&
    length(.groupMembersMissingFromPedigree(groups, ped)) > 0L
}
