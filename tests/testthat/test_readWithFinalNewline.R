## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## CRAN plan Phase 1 (docs/planning/cran-3.0.0-submission-plan.md): CRAN's
## linux-arm64 check fails test_modInput_incomplete_final_line.R. S1093 found
## the cause in R itself: utils' readtablehead() (src/library/utils/src/io.c,
## `char c2 = (char) scanchar(...)`, R 4.4 through R-devel) stores the
## character after a closing quote in a `char`. Where `char` is unsigned, as on
## Linux ARM64, end-of-file (-1) becomes byte 0xFF, so read.csv() and
## read.table() read a file whose last value is quoted and that has no final
## newline with "\xff" on the end of that value ("SHIPPED\xff"). A file that
## ends in a newline cannot meet it, so readWithFinalNewline() hands the reader
## a temporary copy with the newline added when the file has none, and every
## read.csv()/read.table() of a file in R/ goes through it (owner ruling S1093:
## every file reader, not only the app's upload). On macOS and x86-64 `char` is
## signed, so these tests show the contract there; the ARM64 behavior itself
## is checked in the linux/arm64 container. writeExactly() is in
## helper-exactFile.R.

## A reader that records the path it is given and that file's bytes.
recordPath <- function(path, ...) {
  list(path = path, bytes = readBin(path, "raw", file.info(path)$size))
}

test_that("a quoted last value with no final newline is read exactly, with no warning", {
  f <- writeExactly('id,sex\n"A1","M"')
  expect_no_warning(
    ped <- nprcgenekeepr:::readWithFinalNewline(f, read.csv,
                                                stringsAsFactors = FALSE)
  )
  expect_identical(ped$id, "A1")
  expect_identical(ped$sex, "M")

  f2 <- writeExactly('id,sex\n"A1","M"\n"B2","F"')
  ped2 <- nprcgenekeepr:::readWithFinalNewline(f2, read.table, header = TRUE,
                                               sep = ",",
                                               stringsAsFactors = FALSE)
  expect_identical(ped2$sex, c("M", "F"))
})

test_that("a file with no final newline reaches the reader as a copy that ends in one", {
  text <- 'id,sex\n"A1","M"'
  f <- writeExactly(text)
  seen <- nprcgenekeepr:::readWithFinalNewline(f, recordPath)
  expect_false(identical(seen$path, f))
  expect_identical(seen$bytes, c(charToRaw(text), as.raw(0x0a)))
})

test_that("the user's file is left byte for byte as it was", {
  text <- 'id,sex\n"A1","M"'
  f <- writeExactly(text)
  nprcgenekeepr:::readWithFinalNewline(f, read.csv)
  expect_identical(readBin(f, "raw", file.info(f)$size), charToRaw(text))
})

test_that("a file that ends in a newline, or is empty, reaches the reader as is", {
  for (text in c('id,sex\n"A1","M"\n', 'id,sex\r\n"A1","M"\r\n', "")) {
    f <- writeExactly(text)
    seen <- nprcgenekeepr:::readWithFinalNewline(f, recordPath)
    expect_identical(seen$path, f, info = encodeString(text))
  }
})

test_that("a missing file or a URL reaches the reader as is, so its own error is unchanged", {
  missing <- file.path(tempdir(), "noSuchPedigree.csv")
  expect_identical(
    nprcgenekeepr:::readWithFinalNewline(missing, function(path, ...) path),
    missing
  )
  url <- "https://example.org/pedigree.csv"
  expect_identical(
    nprcgenekeepr:::readWithFinalNewline(url, function(path, ...) path),
    url
  )
  expect_identical(
    tryCatch(suppressWarnings(nprcgenekeepr:::readWithFinalNewline(missing,
                                                                   read.csv)),
             error = conditionMessage),
    tryCatch(suppressWarnings(read.csv(missing)), error = conditionMessage)
  )
})

## read.csv() opens a compressed file as text, and a compressed file's last
## byte is not a newline; a newline added after bzip2 or xz data breaks the read
## ("appears not to be compressed by bzip2", "lzma decoding result 10"; S1093),
## so a compressed file must reach the reader as is.
test_that("a compressed file reaches the reader as is and reads as before", {
  writers <- c("gzfile", "bzfile", "xzfile")
  if (exists("zstdfile")) writers <- c(writers, "zstdfile")
  for (writer in writers) {
    f <- tempfile(fileext = ".csv")
    con <- get(writer)(f, "wb")
    writeLines(c("id,sex", '"A1","M"'), con)
    close(con)
    seen <- nprcgenekeepr:::readWithFinalNewline(f, recordPath)
    expect_identical(seen$path, f, info = writer)
    expect_identical(
      nprcgenekeepr:::readWithFinalNewline(f, read.csv,
                                           stringsAsFactors = FALSE),
      read.csv(f, stringsAsFactors = FALSE),
      info = writer
    )
  }
})

test_that("extra arguments reach the reader", {
  f <- writeExactly('a;b\n1;"x"')
  got <- nprcgenekeepr:::readWithFinalNewline(f, read.table, header = TRUE,
                                              sep = ";",
                                              stringsAsFactors = FALSE)
  expect_identical(names(got), c("a", "b"))
  expect_identical(got$b, "x")
})

test_that("the temporary copy is removed after reading, even when the reader fails", {
  f <- writeExactly('id,sex\n"A1","M"')
  seen <- nprcgenekeepr:::readWithFinalNewline(f, recordPath)
  expect_false(file.exists(seen$path))

  failedPath <- NULL
  expect_error(
    nprcgenekeepr:::readWithFinalNewline(f, function(path, ...) {
      failedPath <<- path
      stop("reader failed")
    }),
    "reader failed"
  )
  expect_false(identical(failedPath, f))
  expect_false(file.exists(failedPath))
})

test_that("no read.csv() or read.table() call in R/ bypasses readWithFinalNewline()", {
  rDir <- testthat::test_path("..", "..", "R")
  skip_if(!rSourceAvailable(rDir),
          "R/ source not available (installed package)")
  offenders <- character(0)
  for (f in list.files(rDir, pattern = "\\.[Rr]$", full.names = TRUE)) {
    lines <- readLines(f, warn = FALSE)
    code <- !grepl("^\\s*#", lines)
    hits <- which(code & grepl("\\bread\\.(csv|table)\\s*\\(", lines))
    offenders <- c(offenders, sprintf("%s:%d", basename(f), hits))
  }
  expect_identical(
    offenders, character(0),
    info = paste0(
      "Read the file through readWithFinalNewline(fileName, read.csv, ...) ",
      "instead (Linux ARM64 reads a quoted last value with no final newline ",
      "with a stray 0xFF byte):\n", paste(offenders, collapse = "\n")
    )
  )
})
