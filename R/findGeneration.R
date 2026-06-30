## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Determines the generation number for each id
#'
#' @description{This loops through the entire pedigree one generation at a
#' time. It finds the zeroth generation during first loop.
#' The first time through this loop no sire or dam is in parents.
#' This means that the animals without a sire and without a dam are
#' assigned to generation 0 and become the first parental generation.
#' The second time through this loop finds all of the animals that do
#' not have a sire or do not have a dam and at least one parent
#' is in the vector of parents defined the first time through.
#' The ids that were not assigned as parents in the previous loop
#' are given the incremented generation number.
#'
#' Subsequent trips in the loop repeat what was done the second time
#' through until no further animals can be added to the \code{nextGen}
#' vector.
#'
#' This does not work if the pedigree does not have all parent IDs as ego IDs.
#' }
#' @return An integer vector indication the generation numbers for each id,
#' starting at 0 for individuals lacking IDs for both parents. Any id that
#' cannot be placed --- e.g. when the pedigree contains a cycle or references
#' a parent ID that is not itself present as an ego ID --- is returned as
#' \code{NA} and triggers a \code{warning} naming the affected ids.
#'
#' @param id character vector with unique identifier for an individual
#' @param sire character vector with unique identifier for an
#' individual's father (\code{NA} if unknown).
#' @param dam character vector with unique identifier for an
#' individual's mother (\code{NA} if unknown).
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::lacy1989Ped[, c("id", "sire", "dam")]
#' ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
#' ped
findGeneration <- function(id, sire, dam) {
  parents <- character(0L)
  gen <- rep(NA, length(id))
  i <- 0L

  repeat {
    cumulativeParents <- id[(is.na(sire) | (sire %in% parents)) &
      (is.na(dam) | (dam %in% parents))]
    nextGen <- setdiff(cumulativeParents, parents)

    if (isEmpty(nextGen)) {
      break
    }

    gen[id %in% nextGen] <- i
    i <- i + 1L

    parents <- cumulativeParents
  }
  if (anyNA(gen)) {
    unplaced <- id[is.na(gen)]
    danglingParents <- setdiff(c(sire[!is.na(sire)], dam[!is.na(dam)]), id)
    msg <- paste0(
      "findGeneration: ", length(unplaced),
      " id(s) could not be assigned a generation; the pedigree may contain ",
      "a cycle or a parent ID absent as an ego ID. Unplaced id(s): ",
      toString(unplaced)
    )
    if (length(danglingParents) > 0L) {
      msg <- paste0(
        msg, ". Parent ID(s) with no record: ",
        toString(danglingParents)
      )
    }
    warning(msg)
  }
  gen
}
