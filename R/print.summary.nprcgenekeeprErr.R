#' print.summary.nprcgenekeepr print.summary.nprcgenekeeprGV
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' @return An object to send to the generic print function
#'
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' errorLst <- qcStudbook(nprcgenekeepr::pedInvalidDates,
#'                        reportChanges = TRUE, reportErrors = TRUE)
#' summary(errorLst)
#' }
#'
#' @rdname print
#' @method print summary.nprcgenekeeprErr
#' @param x object of class summary.nprcgenekeeprErr and class list
#' @param ... additional arguments for the \code{summary.default} statement
#' @importFrom stringi stri_c
#' @export
print.summary.nprcgenekeeprErr <- function(x, ...) {
  cl <- oldClass(x)
  txt <- x
  #cat("This is a summary printout from nprcgenekeepr\n\n")
  for (x in txt$txt) {
    cat(x, "\n")
  }
  if (nrow(txt$sp) > 0) {
    cat(stri_c("Animal records where parent records are suspicous because ",
               "of dates.\n",
               "One or more parents appear too young at time of birth.\n"))
    print(txt$sp, digits = 2, row.names = TRUE, ...)
  }
  oldClass(txt) <- cl[cl != "nprcgenekeeprErr"]
  #NextMethod("print")
  invisible(txt)
}
#' @rdname print
#' @return object to send to generic print function
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::pedGood
#' ped <- suppressWarnings(qcStudbook(ped, reportErrors = FALSE))
#' summary(reportGV(ped, guIter = 10))
#' }
#'
#' @method print summary.nprcgenekeeprGV
#' @export
print.summary.nprcgenekeeprGV <- function(x, ...) {
  cl <- oldClass(x)
  #cat("This is a summary printout from nprcgenekeeprGV\n\n")
  for (line in x) {
    cat(line, "\n")
  }
  oldClass(x) <- cl[cl != "nprcgenekeeprGV"]
  #NextMethod("print")
  invisible(x)
}
