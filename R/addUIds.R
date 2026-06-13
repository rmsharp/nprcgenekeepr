#' Eliminates partial parentage situations by adding unique placeholder
#' IDs for the unknown parent.
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' This must be run prior to \code{addParents} since the IDs made herein are
#' used by \code{addParents}
#'
#' The generated placeholder IDs default to the form \code{Unnnn} (a leading
#' "U" plus a zero-padded integer), so they are alphanumeric and never contain a
#' period ("."), honoring the ID rule enforced at data input by
#' \code{\link{qcStudbook}}. The format is configurable via
#' \code{\link{setAutoIdFormat}} (default \code{"U\%04d"}).
#'
#' @return The updated pedigree with partial parentage removed.
#'
#' @param ped datatable that is the `Pedigree`. It contains pedigree
#' information. The fields \code{sire} and \code{dam} are required.
#' @param format \code{sprintf} template for the generated placeholder IDs;
#' defaults to \code{\link{getAutoIdFormat}()} (\code{"U\%04d"}).
#' @export
#' @examples
#' pedTwo <- data.frame(
#'   id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
#'   sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
#'   dam = c("d0", "d0", "d4", NA, "d1", "d2", "d2", "d2"),
#'   sex = c("M", "F", "M", "F", "F", "F", "F", "M"),
#'   stringsAsFactors = FALSE
#' )
#' newPed <- addUIds(pedTwo)
#' newPed[newPed$id == "s1", ]
#' pedThree <-
#'   data.frame(
#'     id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
#'     sire = c("s0", "s0", "s4", NA, "s1", "s1", "s2", "s2"),
#'     dam = c(NA, "d0", "d4", NA, "d1", "d2", "d2", "d2"),
#'     sex = c("M", "F", "M", "F", "F", "F", "F", "M"),
#'     stringsAsFactors = FALSE
#'   )
#' newPed <- addUIds(pedThree)
#' newPed[newPed$id == "s1", ]
addUIds <- function(ped, format = getAutoIdFormat()) {
  s <- which(is.na(ped$sire) & !is.na(ped$dam))
  d <- which(!is.na(ped$sire) & is.na(ped$dam))

  if (identical(s, integer(0L))) {
    k <- 0L
  } else {
    k <- length(s)
    sireIds <- sprintf(format, 1L:k)
    ped[s, "sire"] <- sireIds
  }

  if (!identical(d, integer(0L))) {
    m <- k + 1L
    n <- k + length(d)
    damIds <- sprintf(format, m:n)
    ped[d, "dam"] <- damIds
  }

  ped
}
