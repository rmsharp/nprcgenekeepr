## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Is an animal alive?
#'
#' The one place Breeding Groups says who is alive, so its pool holds only
#' animals that can breed. A pedigree with a \code{status} column is judged by
#' it alone: an animal is alive when its status is \code{ALIVE}, whatever its
#' exit date says (a placeholder has status \code{UNKNOWN} and no exit date, so
#' an exit-date test alone would keep it). A pedigree with no \code{status}
#' column is judged by its \code{exit} column: an animal with no exit date is
#' alive, the way the Genetic Value tab's own fallback and
#' \code{getLivingBreeders()} count. A pedigree with neither column cannot say
#' who is alive, so every animal counts.
#'
#' @param ped Pedigree data.frame, with or without a \code{status} column
#' (standardized codes, see \code{\link{convertStatusCodes}}) and an \code{exit}
#' column.
#' @return A logical vector with one element per row of \code{ped}: \code{TRUE}
#' for an animal that is alive, \code{FALSE} otherwise, never \code{NA}.
#' @noRd
isLivingAnimal <- function(ped) {
  if ("status" %in% names(ped)) {
    status <- ped[["status"]]
    !is.na(status) & status == "ALIVE"
  } else if ("exit" %in% names(ped)) {
    is.na(ped[["exit"]])
  } else {
    rep(TRUE, nrow(ped))
  }
}
