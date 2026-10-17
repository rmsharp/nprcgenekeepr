## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Convert from-center information to a logical value
#'
#' Part of Pedigree Curation
#'
#'
#' @param fromCenter character or logical vector or NA indicating whether or
#' not the animal is from the center.
#' @return A logical vector specifying TRUE if an animal
#' is from the center otherwise FALSE. An \code{NA} input stays \code{NA}.
#' A value is read only when the whole text, ignoring case and any spaces
#' around it, is \code{y}, \code{yes}, \code{t} or \code{true} (TRUE), or
#' \code{n}, \code{no}, \code{f} or \code{false} (FALSE). Any other value,
#' such as \code{"unknown"}, \code{"maybe"}, a number such as \code{1L} or an
#' empty string, stops with an error naming the offending rows.
#'
#' @importFrom stringi stri_c stri_detect_fixed
#' @export
#' @examples
#' original <- c(
#'   "y", "yes", "Y", "Yes", "YES", "n", "N", "No", "NO", "no",
#'   "t", "T", "True", "true", "TRUE", "f", "F", "false", "False",
#'   "FALSE"
#' )
#' convertFromCenter(original)
convertFromCenter <- function(fromCenter) {
  trueValues <- c("Y", "YES", "T", "TRUE")
  falseValues <- c("N", "NO", "F", "FALSE")

  if (!is.logical(fromCenter)) {
    # Only a whole value counts, ignoring case and surrounding space. An NA is
    # missing, not an offending value.
    text <- toupper(trimws(as.character(fromCenter)))
    isTrue <- text %in% trueValues
    isFalse <- text %in% falseValues
    unrecognized <- !is.na(text) & !isTrue & !isFalse
    if (any(unrecognized)) {
      stop(
        "fromCenter field has ambiguous values in row(s) ",
        get_and_or_list(which(unrecognized))
      )
    }
    isTrue[is.na(text)] <- NA
    fromCenter <- isTrue
  }
  fromCenter
}
