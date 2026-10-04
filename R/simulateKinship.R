## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' One simulation: a simulated pedigree and its kinship matrix
#'
#' Draws one simulated pedigree with \code{makeSimPed} and returns its kinship
#' matrix. \code{createSimKinships} and \code{cumulateSimKinships} each call it
#' once per simulation, so the two cannot drift apart. The draw comes first and
#' the kinship second; changing that order changes every seeded result.
#'
#' @param ped pedigree the caller has prepared (a data.frame or data.table with
#'        \code{id}, \code{sire}, \code{dam} and \code{gen} columns).
#' @param allSimParents list made up of lists where the internal list has the
#'        offspring ID \code{id}, a vector of representative sires
#'        (\code{sires}), and a vector of representative dams (\code{dams}).
#' @param twinRelations optional data.frame of twin pairs passed to
#'        \code{kinship}; \code{NULL} (the default) means none.
#' @param verbose logical vector of length one that indicates whether to print
#'        a message when a sire or dam is unknown and has no representatives.
#' @return the kinship matrix of one simulated pedigree.
#'
#' @noRd
.simulateKinship <- function(ped, allSimParents, twinRelations = NULL,
                             verbose = FALSE) {
  simPed <- makeSimPed(ped, allSimParents, verbose = verbose)
  kinship(
    simPed$id, simPed$sire,
    simPed$dam, simPed$gen,
    twinRelations = twinRelations
  )
}
