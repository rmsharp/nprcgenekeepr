## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' The kinship matrix a tab was given, if any
#'
#' Internal helper for the app's tabs (performance and memory campaign Phase
#' 9; design docs/planning/app-kinship-memory-design.md section 6.1). A tab
#' takes its kinship from a handed-in \code{kinshipMatrix} reactive first,
#' then from \code{kinshipFor}, the app's provider, asked for \code{ids}. A
#' source that is \code{NULL}, raises an error or returns \code{NULL} counts
#' as none, so the caller can go on to its own fallback.
#'
#' @param kinshipMatrix a reactive returning a kinship matrix, or \code{NULL}.
#' @param kinshipFor a function of a character vector of animal IDs that
#'   returns their kinship matrix, or \code{NULL}.
#' @param ids the animals to ask \code{kinshipFor} for; \code{NULL} (the
#'   default) means every animal.
#' @return The matrix of the first source that gives one, or \code{NULL}.
#' @noRd
kinshipFromSources <- function(kinshipMatrix, kinshipFor, ids = NULL) {
  kmat <- if (is.null(kinshipMatrix)) {
    NULL
  } else {
    tryCatch(kinshipMatrix(), error = function(e) NULL)
  }
  if (is.null(kmat) && !is.null(kinshipFor)) {
    kmat <- tryCatch(kinshipFor(ids), error = function(e) NULL)
  }
  kmat
}
