#' dataframe2string converts a data.frame object to a character vector
#'
## Copyright(c) 2017-2022 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Adapted from print.data.frame
#'
#' @return A character vector representation of the data.frame provided to the
#' function.
#'
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' dataframe2string(nprcgenekeepr::pedOne)
#' }
#'
#' @param object dataframe
#' @param ... optional arguments to print or plot methods.
#' @param digits the minimum number of significant digits to be used:
#' see print.default.
#' @param row.names	logical (or character vector), indicating whether (or what)
#'  row names should be printed.
#' @importFrom stringi stri_length
#' @importFrom stringi stri_pad_both
#' @export
dataframe2string <- function(object, ..., digits = NULL, row.names = TRUE) {
  nRows <- length(row.names(object))
  if (length(object) == 0L) {
    return(paste(
      sprintf(ngettext(nRows, "data frame with 0 columns and %d row",
                       "data frame with 0 columns and %d rows")
              , nRows)
      , "\\n", sep = "")
    )
  } else if (nRows == 0L) {
    return(gettext("<0 rows> (or 0-length row.names)\\n"))
  } else {
    # get text-formatted version of the data.frame
    m <- as.matrix(format.data.frame(object, digits = digits,
                                     na.encode = TRUE))
    # define row-names (if required)
    if (isTRUE(row.names)) {
      rowNames <- dimnames(object)[[1L]]
      if (is.null(rowNames)) {
        # no row header available -> use row numbers
        rowNames <- as.character(seq_len(NROW(m)))
      }
      # add empty header (used with column headers)
      rowNames <- c("", rowNames)
    }
    # add column headers
    m <- rbind(dimnames(m)[[2]], m)
    # add row headers
    if (isTRUE(row.names))
      m <- cbind(rowNames, m)
    # max-length per-column
    maxLen <- apply(apply(m, c(1,2), stri_length), 2, max,
                    na.rm = TRUE)

    # add right padding
    ##  t is needed because "If each call to FUN returns a vector
    ##  of length n, then apply returns an array of dimension
    ##  c(n, dim(X)[MARGIN])"
    m <- t(apply(m, 1, stri_pad_both, width = maxLen))
    # merge columns
    m <- apply(m, 1, paste, collapse = "")
    # merge rows (and return)
    return(paste(m, collapse = "\n"))
  }
}
