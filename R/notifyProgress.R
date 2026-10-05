## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Call the progress function, if one was given
#'
#' The one place that says what to do with an optional progress function.
#' \code{reportGV}, \code{geneDrop}, \code{convertRelationships} and
#' \code{groupAddAssign} each report progress through it, so the rule cannot
#' drift between them. Only \code{NULL} means there is no progress function;
#' anything else that is not a function stops on the first call, as before.
#'
#' The arguments in \code{...} are handed on unevaluated, so with no progress
#' function none of them is ever computed (\code{geneDrop} sends
#' \code{n = nrow(ped)} once per animal). The parameter is named
#' \code{updateProgress}, like the argument it stands for, so that error
#' message names it.
#'
#' @param updateProgress a function, or \code{NULL} for no progress reporting.
#' @param ... arguments the progress function is called with, by name
#' (\code{n}, \code{detail}, \code{value}, \code{reset}); none at all is fine.
#' @return \code{NULL}, invisibly. The progress function's own value is
#' dropped.
#'
#' @noRd
notifyProgress <- function(updateProgress, ...) {
  if (!is.null(updateProgress)) {
    updateProgress(...)
  }
  invisible(NULL)
}
