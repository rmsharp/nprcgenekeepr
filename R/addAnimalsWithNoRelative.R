## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Add an NA value for animals with no relative
#'
#' This allows \code{kin} to be used with \code{setdiff} when there are no
#' relatives otherwise an error would occur because
#' \code{kin[['animal_with_no_relative']]} would not be found. See the
#' following: in \strong{groupAddAssign}
#'
#'     available[[i]] <- setdiff(available[[i]], kin[[id]])
#'
#' @param kin named list of high-kinship relatives, as produced by
#' \code{getAnimalsWithHighKinship}, where each name is an animal Id and
#' each value is a character vector of the Ids sharing a kinship value at
#' or above the threshold.
#' @param candidates character vector of IDs of the animals available for
#' use in the group.
#' @return The named list of high-kinship relatives (one element per
#' animal Id, each value a character vector of that Id's high-kinship
#' relatives) with an added element set to \code{NA} for each candidate
#' that has no relative.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' qcPed <- nprcgenekeepr::qcPed
#' ped <- qcStudbook(qcPed,
#'   minParentAge = 2.0, reportChanges = FALSE,
#'   reportErrors = FALSE
#' )
#' kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
#' currentGroups <- list(1L)
#' currentGroups[[1]] <- examplePedigree$id[1:3]
#' candidates <- examplePedigree$id[examplePedigree$status == "ALIVE"]
#' threshold <- 0.015625
#' kin <- getAnimalsWithHighKinship(kmat, ped, threshold, currentGroups,
#'   ignore = list(c("F", "F")), minAge = 1.0
#' )
#' # Filtering out candidates related to current group members
#' conflicts <- unique(c(
#'   unlist(kin[unlist(currentGroups)]),
#'   unlist(currentGroups)
#' ))
#' candidates <- setdiff(candidates, conflicts)
#' kin <- addAnimalsWithNoRelative(kin, candidates)
#' length(kin) # should be 259
#' kin[["0DAV0I"]] # should have 34 IDs
addAnimalsWithNoRelative <- function(kin, candidates) {
  # adding animals with no relatives
  for (cand in setdiff(candidates, names(kin))) {
    kin[[cand]] <- NA
  }
  kin
}
