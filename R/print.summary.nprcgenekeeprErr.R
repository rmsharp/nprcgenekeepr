## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Print an nprcgenekeepr summary object
#'
#' @param x object of class summary.nprcgenekeeprErr (from
#'   \code{summary()} of a studbook error list) or summary.nprcgenekeeprGV
#'   (from \code{summary()} of a genetic value report)
#' @param ... further arguments passed to the \code{print()} call for the
#'   suspicious-parents table (and ignored by the GV method)
#' @return The summary object, returned invisibly after it is printed.
#'
#' @importFrom stringi stri_c
#' @rdname print
#' @method print summary.nprcgenekeeprErr
#' @export
#' @examples
#' library(nprcgenekeepr)
#' errorLst <- qcStudbook(nprcgenekeepr::pedInvalidDates,
#'   reportChanges = TRUE, reportErrors = TRUE
#' )
#' summary(errorLst)
print.summary.nprcgenekeeprErr <- function(x, ...) {
  txt <- x
  for (x in txt$txt) {
    cat(x, "\n")
  }
  if (nrow(txt$sp) > 0L) {
    cat(stri_c(
      "Animal records where parent records are suspicious because ",
      "of dates.\n",
      "One or more parents appear too young at time of birth.\n"
    ))
    print(txt$sp, digits = 2L, row.names = TRUE, ...)
  }
  # Deliberately does not call NextMethod; this method fully formats its own
  # output and returns the summary object invisibly.
  invisible(txt)
}
#' @return The summary object, returned invisibly after it is printed.
#' @rdname print
#' @method print summary.nprcgenekeeprGV
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::pedGood
#' ped <- suppressWarnings(qcStudbook(ped, reportErrors = FALSE))
#' summary(reportGV(ped, guIter = 10))
print.summary.nprcgenekeeprGV <- function(x, ...) {
  for (line in x) {
    cat(line, "\n")
  }
  # Deliberately does not call NextMethod; this method fully formats its own
  # output and returns the summary object invisibly.
  invisible(x)
}
