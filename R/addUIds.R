#' Eliminates partial parentage situations by adding unique placeholder
#' IDs for the unknown parent.
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' This must be run prior to \code{addParents} since the IDs made herein are
#' used by \code{addParents}
#'
#' @return The updated pedigree with partial parentage removed.
#'
#' @examples
#' \donttest{
#' pedTwo <- data.frame(id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
#'                      sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
#'                      dam = c("d0", "d0", "d4", NA, "d1", "d2", "d2", "d2"),
#'                      sex = c("M", "F", "M", "F", "F", "F", "F", "M"),
#'                      stringsAsFactors = FALSE)
#' newPed <- addUIds(pedTwo)
#' newPed[newPed$id == "s1", ]
#' pedThree <-
#'   data.frame(id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
#'              sire = c("s0", "s0", "s4", NA, "s1", "s1", "s2", "s2"),
#'              dam = c(NA, "d0", "d4", NA, "d1", "d2", "d2", "d2"),
#'              sex = c("M", "F", "M", "F", "F", "F", "F", "M"),
#'              stringsAsFactors = FALSE)
#' newPed <- addUIds(pedThree)
#' newPed[newPed$id == "s1", ]
#' }
#'
#' @param ped datatable that is the `Pedigree`. It contains pedigree
#' information. The fields \code{sire} and \code{dam} are required.
#' @export
addUIds <- function(ped) {
  s <- which(is.na(ped$sire) & !is.na(ped$dam))
  d <- which(!is.na(ped$sire) & is.na(ped$dam))

  if (!identical(s, integer(0))) {
    k <- length(s)
    sireIds <- paste("U", sprintf("%04d", 1:k), sep = "")
    ped[s, "sire"] <- sireIds
  } else {
    k <- 0
  }

  if (!identical(d, integer(0))) {
    m <- k + 1
    n <- k + length(d)
    damIds <- paste("U", sprintf("%04d", m:n), sep = "")
    ped[d, "dam"] <- damIds
  }

  return(ped)
}
