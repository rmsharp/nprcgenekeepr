## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Check that a value is a single positive whole number
#'
#' Internal helper shared by \code{\link{createColonySnapshot}} and
#' \code{\link{backfillColonySnapshots}} for their required \code{guIter} and
#' \code{guThresh} arguments.
#'
#' @param value The value to check.
#' @param name The argument's name, for the error message.
#' @param detail Optional text put before the message's closing full stop,
#' for example \code{" (the value the reportGV() call used)"}.
#' @return \code{value} as an integer; stops when it is not a single positive
#' whole number.
#' @noRd
validateWholeCount <- function(value, name, detail = "") {
  if (!is.numeric(value) || length(value) != 1L || is.na(value) ||
      value < 1L || value != as.integer(value)) {
    stop("'", name, "' must be a single positive whole number", detail, ".")
  }
  as.integer(value)
}
