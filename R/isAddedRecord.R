## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Which records are "added"?
#'
#' The one place that says which records are placeholders made for parents
#' that have no record of their own: only the exact status \code{"added"} is
#' special. An \code{NA}, blank or unrecognized status is a real animal.
#' \code{convertDate}, \code{removeDuplicates}, \code{removeUnknownAnimals}
#' and \code{correctParentSex} all ask it, so the rule cannot drift between
#' them.
#'
#' It returns a logical mask, never an index. A negative subscript built from
#' an index that can be empty (\code{ped[-which(mask), ]}) drops every row
#' when nothing is added, while \code{ped[!mask, ]} keeps them all.
#'
#' @param recordStatus vector of record statuses (character, factor or
#' logical), or \code{NULL} when there is no \code{recordStatus} column.
#' @param n integer length of the result when \code{recordStatus} is
#' \code{NULL}; it is not used otherwise. Defaults to
#' \code{length(recordStatus)}.
#' @return A logical vector with no \code{NA}: \code{TRUE} where the status is
#' exactly \code{"added"}. A \code{NULL} status means no record is known to be
#' added, so it returns \code{n} \code{FALSE} values.
#'
#' @noRd
isAddedRecord <- function(recordStatus, n = length(recordStatus)) {
  if (is.null(recordStatus)) {
    return(rep(FALSE, n))
  }
  !is.na(recordStatus) & recordStatus == "added"
}
