## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Read one ISO-8601 date
#'
#' Internal helper shared by \code{\link{createColonySnapshot}} (for
#' \code{snapshotDate}) and \code{\link{backfillColonySnapshots}} (for
#' \code{from} and \code{to}). A \code{Date} round-trips through
#' \code{as.character()} as YYYY-MM-DD, so one coercion path serves both
#' accepted input types.
#'
#' @param value The value to read: a \code{Date} or a YYYY-MM-DD string.
#' @param name The argument's name, for the error message.
#' @return A single \code{Date}; stops, naming the argument, when \code{value}
#' is not exactly one valid date.
#' @noRd
parseIsoDate <- function(value, name) {
  parsed <- as.Date(as.character(value), format = "%Y-%m-%d")
  if (length(parsed) != 1L || is.na(parsed)) {
    stop("'", name, "' must be a single ISO-8601 (YYYY-MM-DD) date.",
      call. = FALSE)
  }
  parsed
}
