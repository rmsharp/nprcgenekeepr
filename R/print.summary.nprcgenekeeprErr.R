## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' print.summary.nprcgenekeepr print.summary.nprcgenekeeprGV
#'
#' @return An object to send to the generic print function
#'
#' @rdname print
#' @method print summary.nprcgenekeeprErr
#' @param x object of class summary.nprcgenekeeprErr and class list
#' @param ... additional arguments for the \code{summary.default} statement
#' @importFrom stringi stri_c
#' @export
#' @examples
#' library(nprcgenekeepr)
#' errorLst <- qcStudbook(nprcgenekeepr::pedInvalidDates,
#'   reportChanges = TRUE, reportErrors = TRUE
#' )
#' summary(errorLst)
print.summary.nprcgenekeeprErr <- function(x, ...) {
  cl <- oldClass(x)
  txt <- x
  for (x in txt$txt) {
    cat(x, "\n")
  }
  if (nrow(txt$sp) > 0L) {
    cat(stri_c(
      "Animal records where parent records are suspicous because ",
      "of dates.\n",
      "One or more parents appear too young at time of birth.\n"
    ))
    print(txt$sp, digits = 2L, row.names = TRUE, ...)
  }
  oldClass(txt) <- cl[cl != "nprcgenekeeprErr"]
  # Deliberately does not call NextMethod; this method fully formats its own
  # output and returns the reclassified object invisibly.
  invisible(txt)
}
#' @rdname print
#' @return object to send to generic print function
#' @method print summary.nprcgenekeeprGV
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::pedGood
#' ped <- suppressWarnings(qcStudbook(ped, reportErrors = FALSE))
#' summary(reportGV(ped, guIter = 10))
print.summary.nprcgenekeeprGV <- function(x, ...) {
  cl <- oldClass(x)
  for (line in x) {
    cat(line, "\n")
  }
  oldClass(x) <- cl[cl != "nprcgenekeeprGV"]
  # Deliberately does not call NextMethod; this method fully formats its own
  # output and returns the reclassified object invisibly.
  invisible(x)
}
