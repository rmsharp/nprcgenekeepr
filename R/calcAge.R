## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Calculate animal ages
#'
#' Part of Pedigree Curation
#'
#' Given vectors of birth and exit dates, calculate an individuals age. If no
#' exit date is provided, the calculation is based on the current date.
#'
#' @param birth Date vector of birth dates
#' @param exit Date vector of exit dates.
#'
#' @return A numeric vector (\code{NA} allowed) indicating age in decimal years
#' from "birth" to "exit" or the current date if "exit" is NA.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' qcPed <- nprcgenekeepr::qcPed
#' originalAge <- qcPed$age ## ages calculated at time of data collection
#' currentAge <- calcAge(qcPed$birth, qcPed$exit) ## assumes no changes in
#' ## colony
calcAge <- function(birth, exit) {
  if (length(birth) == 0L) {
    return(birth)
  }
  exit[is.na(exit)] <- Sys.Date()
  round((as.double(exit - birth) / 365.25), 1L)
}
