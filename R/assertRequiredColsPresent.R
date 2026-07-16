## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Assert that a set of required columns is present
#'
#' Issue #123 (XARCH-5) Phase 1: the internal explicit validator wired at the
#' 3 silent-drop sites (\code{reportGV.R:211}, \code{qcStudbook.R:316},
#' \code{gvaConvergence.R:161}) where an unguarded
#' \code{intersect(<cols>, names(ped))} would otherwise silently drop a
#' required column with no diagnostic. Mirrors the already-tested
#' \code{checkKinshipOverrides()} \code{setdiff()}+\code{stop()} idiom.
#'
#' @param availableCols character vector of column names actually present.
#' @param required character vector of column names that must be present.
#' @param where character(1) label identifying the call site, named in the
#' error message (e.g. \code{"reportGV(ped)"}).
#' @return \code{invisible(NULL)} if all \code{required} columns are present.
#' @noRd
assertRequiredColsPresent <- function(availableCols, required, where) {
  missing <- setdiff(required, availableCols)
  if (length(missing) > 0L) {
    stop("nprcgenekeepr: required column(s) missing in ", where, ": ",
         toString(missing), ".", call. = FALSE)
  }
  invisible(NULL)
}
