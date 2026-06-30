## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Evaluate an expression, muffling the "incomplete final line" warning.
#'
#' Runs \code{expr} and suppresses only the
#' \code{"incomplete final line found by readTableHeader"} warning that
#' \code{\link[utils]{read.table}} and \code{\link[utils]{read.csv}} emit
#' when an input file (animal list or pedigree) has no trailing newline.
#' Every row, including the last, is still read correctly, so the warning is
#' noise; all other warnings are left to propagate to the caller.
#'
#' @param expr expression to evaluate, typically a \code{read.table} or
#' \code{read.csv} call.
#' @return The value of \code{expr}.
#'
#' @noRd
muffleIncompleteFinalLine <- function(expr) {
  withCallingHandlers(
    expr,
    warning = function(w) {
      if (grepl("incomplete final line", conditionMessage(w), fixed = TRUE)) {
        invokeRestart("muffleWarning")
      }
    }
  )
}
