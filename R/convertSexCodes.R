## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Convert a sex indicator to a standardized code
#'
#' Part of Pedigree Curation
#'
#'
#' Standard sex codes are
#' \itemize{
#' \item \code{F} -- replacing "FEMALE" or "2"
#' \item \code{M} -- replacing "MALE" or "1"
#' \item \code{H} -- replacing "HERMAPHRODITE" or "4", if
#' \code{ignoreHerm} == FALSE
#' \item \code{U} -- replacing "HERMAPHRODITE" or "4", if
#' \code{ignoreHerm} == TRUE
#' \item \code{U} -- replacing "UNKNOWN" or "3"
#' \item \code{U} -- replacing a missing, blank or unrecognized value
#' }
#'
#' Case and any spaces around a code are ignored, so \code{" male "} and
#' \code{"M "} both become \code{M}.
#'
#' @param sex character vector or factor of sex codes (see above) for
#' individuals; any other value is treated as unknown.
#' @param ignoreHerm logical flag indicating if hermaphrodites should be
#' treated as unknown sex ("U"), default is \code{TRUE}.
#' @return A single factor with levels \code{F}, \code{M}, \code{H} and
#' \code{U} holding the standardized sex codes after transformation from
#' non-standard codes. Level \code{H} is used only when
#' \code{ignoreHerm = FALSE}.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' original <- c(
#'   "m", "male", "1", "MALE", "M", "F", "f", "female",
#'   "FemAle", "U", "Unknown", "H", "hermaphrodite",
#'   "U", "Unknown", "3", "4"
#' )
#' sexCodes <- convertSexCodes(original)
#' sexCodes
convertSexCodes <- function(sex, ignoreHerm = TRUE) {
  sex <- toupper(trimws(sex))
  sex[sex %in% c("MALE", "M", "1")] <- "M"
  sex[sex %in% c("FEMALE", "F", "2")] <- "F"
  sex[sex %in% c("UNKNOWN", "U", "3")] <- "U"

  if (ignoreHerm) {
    sex[sex %in% c("HERMAPHRODITE", "H", "4")] <- "U"
  } else {
    sex[sex %in% c("HERMAPHRODITE", "H", "4")] <- "H"
  }
  # A missing (NA), blank or unrecognized code is unknown sex.
  sex[!sex %in% c("F", "M", "H", "U")] <- "U"
  sex <- factor(sex, levels = c("F", "M", "H", "U"))
  sex
}
