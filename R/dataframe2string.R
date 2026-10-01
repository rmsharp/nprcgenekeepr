## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Convert a data frame to a character vector
#'
#' Adapted from print.data.frame
#'
#' @param object dataframe
#' Rows are joined with newline characters, so the result is one string.
#'
#' @param ... currently unused; accepted for compatibility with print methods.
#' @param digits the minimum number of significant digits to be used:
#' see print.default.
#' @param addRowNames single logical value. If \code{TRUE} (the default), the
#'  row names of the data frame are printed. Any other value, including a
#'  character vector, is treated as \code{FALSE}.
#' @return A character vector of length one holding the text representation of
#' the data.frame provided to the function, with rows separated by newline
#' characters.
#'
#' @importFrom stringi stri_length
#' @importFrom stringi stri_pad_both
#' @export
#' @examples
#' library(nprcgenekeepr)
#' dataframe2string(nprcgenekeepr::pedOne)
dataframe2string <- function(object, ..., digits = NULL, addRowNames = TRUE) {
  nRows <- length(row.names(object))
  if (length(object) == 0L) {
    paste0(
      sprintf(
        ngettext(
          nRows, "data frame with 0 columns and %d row",
          "data frame with 0 columns and %d rows"
        ),
        nRows
      ),
      "\\n"
    )
  } else if (nRows == 0L) {
    gettext("<0 rows> (or 0-length row names)\\n")
  } else {
    # get text-formatted version of the data.frame
    m <- as.matrix(format.data.frame(object,
      digits = digits,
      na.encode = TRUE
    ))
    # define rowNames (if required)
    if (isTRUE(addRowNames)) {
      rowNames <- dimnames(object)[[1L]]
      # add empty header (used with column headers)
      rowNames <- c("", rowNames)
    }
    # add column headers
    m <- rbind(dimnames(m)[[2L]], m)
    # add row headers
    if (isTRUE(addRowNames)) {
      m <- cbind(rowNames, m)
    }
    # max-length per-column
    maxLen <- apply(apply(m, c(1L, 2L), stri_length), 2L, max,
      na.rm = TRUE
    )

    # add right padding
    ##  t is needed because "If each call to FUN returns a vector
    ##  of length n, then apply returns an array of dimension
    ##  c(n, dim(X)[MARGIN])"
    m <- t(apply(m, 1L, stri_pad_both, width = maxLen))
    # merge columns
    m <- apply(m, 1L, paste, collapse = "")
    # merge rows (and return)
    paste(m, collapse = "\n")
  }
}
