## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Trim a pedigree to a group's ancestors
#'
#' Filters a pedigree down to the provided group (the probands) and all of
#' their ancestors, removing unnecessary individuals from the studbook. By
#' default only that filtering is done. Uninformative founders are removed
#' only when \code{removeUninformative = TRUE}, and single parents are added
#' back only when both \code{removeUninformative} and \code{addBackParents}
#' are \code{TRUE}.
#'
#' @param probands a character vector with the list of animals whose ancestors
#' should be included in the final pedigree.
#' @param ped datatable that is the \code{Pedigree}. It contains pedigree
#' information. The fields \code{id}, \code{sire} and \code{dam} are
#' required.
#' @param removeUninformative logical defaults to \code{FALSE}. If set to
#' \code{TRUE}, uninformative founders are removed.
#'
#' Founders (having unknown sire and dam) that appear only one time in a
#' pedigree are uninformative and can be removed from a pedigree without loss
#' of information.
#' @param addBackParents logical defaults to \code{FALSE}. If set to
#' \code{TRUE}, the function adds back single parents to the \code{p} dataframe
#' when one parent is known. It is ignored unless
#' \code{removeUninformative = TRUE}.
#' The function \code{addBackSecondParents} uses the \code{ped} dataframe,
#' which has full complement of parents and the
#' \code{p} dataframe, which has all uninformative parents removed to add
#' back single parents to the \code{p} dataframe.
#' @return A pedigree containing the probands and all of their ancestors.
#' Uninformative founders are removed only when \code{removeUninformative}
#' is \code{TRUE}, and single parents are added back only when
#' \code{addBackParents} is also \code{TRUE}.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' examplePedigree <- nprcgenekeepr::examplePedigree
#' breederPed <- qcStudbook(examplePedigree,
#'   minSireAge = 2,
#'   minDamAge = 2,
#'   reportChanges = FALSE,
#'   reportErrors = FALSE
#' )
#' focalAnimals <- breederPed$id[!(is.na(breederPed$sire) &
#'   is.na(breederPed$dam)) &
#'   is.na(breederPed$exit)]
#' breederPed <- setPopulation(ped = breederPed, ids = focalAnimals)
#' trimmedPed <- trimPedigree(focalAnimals, breederPed)
#' trimmedPedInformative <- trimPedigree(focalAnimals, breederPed,
#'   removeUninformative = TRUE
#' )
#' nrow(breederPed)
#' nrow(trimmedPed)
#' nrow(trimmedPedInformative)
trimPedigree <- function(probands, ped, removeUninformative = FALSE,
                         addBackParents = FALSE) {
  ped <- getProbandPedigree(probands, ped)
  if (removeUninformative) {
    p <- removeUninformativeFounders(ped)
    if (addBackParents) {
      p <- addBackSecondParents(p, ped)
    }
  } else {
    p <- ped
  }
  p
}
