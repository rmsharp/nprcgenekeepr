## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Make a simulated pedigree from representative sires and dams
#'
#' For each \code{id} in \code{allSimParents} with one or more unknown parents
#' each unknown parent is replaced with a random sire or dam as needed from
#' the corresponding parent vector (\code{sires} or \code{dams}).
#'
#' The algorithm assigns parents randomly from the lists of possible sires and
#' dams and does not prevent a dam from being selected more than once within
#' the same breeding period. While this is probably not introducing a large
#' error, it is not ideal.
#'
#' @param ped pedigree information in data.frame format
#' @param allSimParents list made up of lists where the internal list
#'        has the offspring ID \code{id}, a vector of representative sires
#'        (\code{sires}), and a vector of representative dams (\code{dams}).
#' @param verbose logical vector of length one that indicates whether or not
#'        to print out when an animal is missing a sire or a dam.
#' @return simulated pedigree in data.frame format with the id, sire, and dam.
#'
#' @importFrom data.table as.data.table
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::lacy1989Ped
#' ## For each id below, any unknown sire/dam is replaced by a random
#' ## draw from the supplied representative sires and dams.
#' allSimParents <- list(
#'   list(
#'     id = "A",
#'     sires = c("s1_1", "s1_2", "s1_3"),
#'     dams = c("d1_1", "d1_2", "d1_3", "d1_4")
#'   ),
#'   list(
#'     id = "B",
#'     sires = c("s2_1", "s2_2", "s2_3"),
#'     dams = c("d2_1", "d2_2", "d2_3", "d2_4")
#'   ),
#'   list(
#'     id = "E",
#'     sires = c("s3_1", "s3_2", "s3_3"),
#'     dams = c("d3_1", "d3_2", "d3_3", "d3_4")
#'   )
#' )
#' set.seed(1)
#' simPed <- makeSimPed(ped, allSimParents)
#' simPed
makeSimPed <- function(ped, allSimParents, verbose = FALSE) {
  nIds <- length(allSimParents)
  if (!inherits(ped, "data.table")) {
    ped <- data.table::as.data.table(ped)
  }

  for (i in seq_len(nIds)) {
    if (length(allSimParents[[i]]$sires) == 0L) {
      ped$sire[ped$id == allSimParents[[i]]$id] <- NA
      if (verbose) {
        message("id #", i, " is ", allSimParents[[i]]$id, " and has no sire\n")
      }
    } else {
      ped$sire[ped$id == allSimParents[[i]]$id] <-
        sample(allSimParents[[i]]$sires, size = 1L)
    }
    if (length(allSimParents[[i]]$dams) == 0L) {
      ped$dam[ped$id == allSimParents[[i]]$id] <- NA
      if (verbose) {
        message(
          "id #", i, " is ", allSimParents[[i]]$id,
          " and has no dam\n"
        )
      }
    } else {
      ped$dam[ped$id == allSimParents[[i]]$id] <-
        sample(allSimParents[[i]]$dams, size = 1L)
    }
  }
  ped
}
