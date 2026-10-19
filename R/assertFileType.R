## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Assert that a file type is one known type
#'
#' The internal check that stops \code{saveDataframesAsFiles()} and
#' \code{makeExamplePedigreeFile()} before they write anything when
#' \code{fileType} is not exactly one of \code{"txt"}, \code{"csv"} or
#' \code{"excel"}. Written in the style of \code{assertRequiredColsPresent()},
#' except that the error keeps the calling function as its call, so the console
#' still reads "Error in saveDataframesAsFiles(...)".
#'
#' @param fileType the value given for the file type.
#' @param call the call to report in the error; the function that called
#' \code{assertFileType()}.
#' @return \code{invisible(NULL)} if \code{fileType} is one of the three types.
#' @noRd
assertFileType <- function(fileType, call = sys.call(-1L)) {
  if (!(length(fileType) == 1L && fileType %in% c("txt", "csv", "excel"))) {
    stop(simpleError(
      paste0("fileType must be one of \"txt\", \"csv\" or \"excel\" (a single ",
             "value)."),
      call = call
    ))
  }
  invisible(NULL)
}
