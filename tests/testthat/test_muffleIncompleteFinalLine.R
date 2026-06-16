## Tests for muffleIncompleteFinalLine() and its use in the package file readers.
##
## Issue #4: reading an animal list / pedigree file that has no trailing newline
## emits "incomplete final line found by readTableHeader on '...'" even though
## every row (including the last) is read correctly. The helper muffles ONLY that
## one warning; every other warning still propagates to the caller.

## Write `text` to a temp file with NO trailing newline (the issue #4 condition).
write_no_final_newline <- function(text, ext = ".csv") {
  stopifnot(!grepl("\n$", text))
  f <- tempfile(fileext = ext)
  con <- file(f, "wb")
  on.exit(close(con))
  writeBin(charToRaw(text), con)
  f
}

## Collect every warning message emitted while evaluating `expr` (muffling them so
## the test itself stays quiet); tolerates an error in `expr` and returns the
## character vector of warning messages seen.
captured_warnings <- function(expr) {
  warns <- character(0)
  withCallingHandlers(
    tryCatch(force(expr), error = function(e) NULL),
    warning = function(w) {
      warns <<- c(warns, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  warns
}

test_that(paste(
  "muffleIncompleteFinalLine suppresses the incomplete-final-line warning",
  "and preserves every row"
), {
  f <- write_no_final_newline("id,sire,dam\nA,,\nB,A,\nC,A,B")
  expect_no_warning(
    nprcgenekeepr:::muffleIncompleteFinalLine(
      read.table(f, header = TRUE, sep = ",", stringsAsFactors = FALSE)
    )
  )
  ped <- suppressWarnings(
    nprcgenekeepr:::muffleIncompleteFinalLine(
      read.table(f, header = TRUE, sep = ",", stringsAsFactors = FALSE)
    )
  )
  expect_equal(nrow(ped), 3L)
  expect_equal(ped[[1L]], c("A", "B", "C"))
})

test_that("muffleIncompleteFinalLine still lets unrelated warnings propagate", {
  expect_warning(
    nprcgenekeepr:::muffleIncompleteFinalLine(
      warning("a totally unrelated problem")
    ),
    "unrelated problem"
  )
})

test_that("muffleIncompleteFinalLine returns expr's value unchanged with no warning", {
  expect_equal(nprcgenekeepr:::muffleIncompleteFinalLine(1L + 1L), 2L)
  expect_identical(nprcgenekeepr:::muffleIncompleteFinalLine("ok"), "ok")
})

test_that("getPedigree() reads a no-trailing-newline file: no warning, all rows (#4)", {
  f <- write_no_final_newline("id,sire,dam\nA,,\nB,,\nC,A,B")
  expect_no_warning(getPedigree(f))
  expect_equal(nrow(suppressWarnings(getPedigree(f))), 3L)
})

test_that("getGenotypes() reads a no-trailing-newline file: no warning, all rows (#4)", {
  f <- write_no_final_newline("id,first,second\nA,101,102\nB,103,104\nC,105,106")
  expect_no_warning(getGenotypes(f))
  expect_equal(nrow(suppressWarnings(getGenotypes(f))), 3L)
})

test_that("getFocalAnimalPed() does not emit the incomplete-final-line warning (#4)", {
  ## The post-read LabKey call returns an error list without a configured DB; we
  ## only assert that the read no longer emits the incomplete-final-line warning
  ## (the unrelated "configuration file is missing" warning is expected here).
  f <- write_no_final_newline("id\nA\nB\nC")
  warns <- captured_warnings(getFocalAnimalPed(f))
  expect_false(any(grepl("incomplete final line", warns, fixed = TRUE)))
})

test_that("modInputServer() routes its uploaded-file reads through the muffler (#4)", {
  ## readDataFile() is a closure inside the server; assert structurally that the
  ## server body wraps its reads in muffleIncompleteFinalLine.
  body_src <- paste(deparse(body(modInputServer)), collapse = "\n")
  expect_match(body_src, "muffleIncompleteFinalLine", fixed = TRUE)
})
