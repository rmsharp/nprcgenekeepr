## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Read a delimited file through a copy that ends in a newline
#'
#' Calls \code{reader(fileName, ...)}, except that a file with no final
#' newline is read through a temporary copy with one added. Where C's
#' \code{char} is unsigned (Linux on ARM64), \code{\link[utils]{read.table}}
#' and \code{\link[utils]{read.csv}} read a file whose last value is quoted
#' and that has no final newline with a stray 0xFF byte on the end of that
#' value: utils' \code{readtablehead()} (\code{src/library/utils/src/io.c},
#' R 4.4 through R-devel) keeps the character after a closing quote in a
#' \code{char}, so end-of-file becomes 0xFF. A file that ends in a newline
#' cannot meet it. The user's file is never changed, and the copy is removed
#' once it is read. A missing or empty file, and a compressed one (gzip,
#' bzip2, xz or zstd, which R opens as text), goes to \code{reader} as is.
#'
#' @param fileName path of the file to read.
#' @param reader the reading function, \code{read.table} or \code{read.csv}.
#' @param ... further arguments passed to \code{reader}.
#' @return The value of \code{reader}.
#'
#' @noRd
readWithFinalNewline <- function(fileName, reader, ...) {
  if (lacksFinalNewline(fileName)) {
    copy <- tempfile(fileext = ".txt")
    file.copy(fileName, copy)
    cat("\n", file = copy, append = TRUE)
    on.exit(unlink(copy), add = TRUE)
    fileName <- copy
  }
  reader(fileName, ...)
}

#' Read a delimited text file the way the package's file readers do
#'
#' Reads \code{fileName} with \code{\link[utils]{read.table}} through
#' \code{readWithFinalNewline()}: a header row, \code{sep} between values,
#' blank cells and \code{"NA"} read as missing, column names kept as written,
#' and the incomplete final line warning muffled. Shared by
#' \code{getPedigree()}, \code{getGenotypes()}, \code{readTwinRelations()},
#' \code{readAncestryRules()}, \code{readKinshipOverrides()} and
#' \code{readSnapshotHistory()}.
#'
#' @param fileName path of the file to read.
#' @param sep the character between values.
#' @return A data.frame.
#'
#' @noRd
readDelimitedFile <- function(fileName, sep) {
  muffleIncompleteFinalLine(readWithFinalNewline(fileName,
    read.table,
    header = TRUE,
    sep = sep,
    stringsAsFactors = FALSE,
    na.strings = c("", "NA"),
    check.names = FALSE
  ))
}

#' TRUE for an existing, non-empty, uncompressed file whose last byte is not
#' a newline
#'
#' The compression signatures are the ones \code{\link[base]{file}} looks for
#' when it opens a file for reading.
#'
#' @param fileName path of the file.
#' @return \code{TRUE} or \code{FALSE}.
#'
#' @noRd
lacksFinalNewline <- function(fileName) {
  size <- file.info(fileName)$size
  if (is.na(size) || size == 0L) {
    return(FALSE)
  }
  con <- file(fileName, "rb")
  on.exit(close(con))
  start <- readBin(con, "raw", 6L)
  signatures <- list(
    gzip = as.raw(c(0x1f, 0x8b)),
    bzip2 = charToRaw("BZh"),
    xz = as.raw(c(0xfd, 0x37, 0x7a, 0x58, 0x5a, 0x00)),
    zstd = as.raw(c(0x28, 0xb5, 0x2f, 0xfd))
  )
  for (signature in signatures) {
    if (identical(start[seq_along(signature)], signature)) {
      return(FALSE)
    }
  }
  seek(con, size - 1L)
  !identical(readBin(con, "raw", 1L), as.raw(0x0a))
}
