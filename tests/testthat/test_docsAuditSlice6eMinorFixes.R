## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## S1016 (BACKLOG.md docs-audit part 2; the 13 "small and clearly wrong"
## findings of the slice 6e re-check, S1003,
## docs/audits/DOCS_AUDIT_PART2_SLICE_6E_RECHECK_2026-10-15.md, "The remaining
## 39 minor findings"). Each case was measured against the code at S1016 and
## the owner took "fix all 13 as listed" at the S1016 scope question. The
## order is the report's.
##
##   CL10 the printed summary says "suspicous".
##   CL6  get_elapsed_time_str() rounds the seconds after it has split off the
##        minutes: 59.6 s is "60 seconds.".
##   CL7  withinIntegerRange() sends a number too big for an integer to the
##        minimum; the maximum is the answer.
##   CL2  create_wkbk() into a missing folder returns TRUE and writes nothing.
##   CL3  a fileType that is not one known type stops with a message about "the
##        condition" (saveDataframesAsFiles() and makeExamplePedigreeFile()
##        share the check).
##   CE3  obfuscateDate(): an NA minDate stops; a minDate that no draw can
##        reach never ends; the length message names the wrong argument.
##   CE6  checkCrossCenterMapping() stops with resolveCrossCenterIds()'s name.
##   CE7  an NA id stops obfuscateId() and obfuscatePed() with "missing value
##        where TRUE/FALSE needed".
##   CK1  makeExamplePedigreeFile()'s default file is examplePedigree.csv for
##        every file type.
##   CK2  focalAnimals$id is a factor, examplePedigree$id a character, and the
##        help says neither.
##   CL1  dataframe2string()'s zero-row and zero-column text ends in a
##        backslash and an n (two characters).
##   CL5  setExit() finds Death and Departure in any case but reads them in
##        lower case.
##   CJ8  makeGeneticDiversityHeatmap() draws repeated group labels on one row.
##
## Blocks marked "(green at HEAD)" pass before the fix; they pin what stays.

## sourceLines(), plainText(), expectWording(), helpPlaces() and
## skipUnlessHelpInSourceTree() are in helper-pageText.R.

## Runs `expr` and gives up with an error after `seconds` of wall-clock time,
## so a loop that never ends fails its block instead of hanging the run.
withinSeconds <- function(expr, seconds = 5) {
  setTimeLimit(elapsed = seconds, transient = TRUE)
  on.exit(setTimeLimit(elapsed = Inf, transient = TRUE), add = TRUE)
  expr
}

## The message of the error `expr` stops with ("" when it does not stop).
errorMessage <- function(expr) {
  tryCatch({
    expr
    ""
  }, error = function(e) conditionMessage(e))
}

## -- CL10 --------------------------------------------------------------------

errorSummary <- function() {
  summary(suppressWarnings(qcStudbook(nprcgenekeepr::pedOne,
                                      reportErrors = TRUE)))
}

test_that("CL10: the printed summary spells 'suspicious'", {
  errSummary <- errorSummary()
  expect_gt(nrow(errSummary$sp), 0L)
  out <- capture.output(print(errSummary))
  expect_true(any(grepl(
    "parent records are suspicious because of dates", out, fixed = TRUE
  )))
  expect_false(any(grepl("suspicous", out, fixed = TRUE)))
})

test_that("CL10: both print methods return the summary object with its class
          (green at HEAD)", {
  errSummary <- errorSummary()
  invisible(capture.output(returned <- print(errSummary)))
  expect_identical(class(returned), class(errSummary))
  expect_identical(returned$sp, errSummary$sp)

  gvSummary <- structure(list("first line", "second line"),
                         class = "summary.nprcgenekeeprGV")
  invisible(capture.output(returned <- print(gvSummary)))
  expect_identical(class(returned), class(gvSummary))
})

## -- CL6 ---------------------------------------------------------------------

## What get_elapsed_time_str() says when `seconds` have passed.
elapsedText <- function(seconds) {
  skip_if_not_installed("mockery")
  clock <- function(elapsed) {
    structure(c(user.self = 0, sys.self = 0, elapsed = elapsed,
                user.child = 0, sys.child = 0), class = "proc_time")
  }
  mockery::stub(get_elapsed_time_str, "proc.time", clock(seconds))
  get_elapsed_time_str(clock(0))
}

test_that("CL6: the seconds are rounded before they are split into minutes", {
  expect_identical(elapsedText(59.6), "1 minutes and 0 seconds.")
  expect_identical(elapsedText(119.6), "2 minutes and 0 seconds.")
  expect_identical(elapsedText(3599.6), "1 hours, 0 seconds.")
  expect_identical(elapsedText(3659.6), "1 hours, 1 minutes and 0 seconds.")
})

test_that("CL6: a time that rounds inside its minute reads as before
          (green at HEAD)", {
  expect_identical(elapsedText(0.4), "0 seconds.")
  expect_identical(elapsedText(1), "1 seconds.")
  expect_identical(elapsedText(59.4), "59 seconds.")
  expect_identical(elapsedText(61), "1 minutes and 1 seconds.")
  expect_identical(elapsedText(3600), "1 hours, 0 seconds.")
  expect_identical(elapsedText(3661.4), "1 hours, 1 minutes and 1 seconds.")
  expect_identical(elapsedText(7200.4), "2 hours, 0 seconds.")
})

## -- CL7 ---------------------------------------------------------------------

test_that("CL7: a number too big for an integer is the maximum, one too small
          is the minimum", {
  expect_identical(withinIntegerRange(3e9, 0L, 10L), 10L)
  expect_identical(withinIntegerRange(Inf, 0L, 10L), 10L)
  expect_identical(withinIntegerRange("3000000000", 0L, 10L), 10L)
  expect_identical(withinIntegerRange(3e9, 0L, 10L, na = "min"), 10L)
  expect_identical(withinIntegerRange(-3e9, 0L, 10L, na = "max"), 0L)
  expect_identical(withinIntegerRange(-Inf, 2L, 10L, na = "max"), 2L)
  expect_identical(withinIntegerRange(c(3e9, 4, NA, -3e9), 0L, 10L),
                   c(10L, 4L, 0L, 0L))
})

test_that("CL7: the other values are forced as before (green at HEAD)", {
  expect_identical(withinIntegerRange(-3e9, 0L, 10L), 0L)
  expect_identical(withinIntegerRange(2.6, 0L, 10L), 2L)
  expect_identical(withinIntegerRange(11L, 0L, 10L), 10L)
  expect_identical(withinIntegerRange(NA, 0L, 10L, na = "max"), 10L)
  expect_identical(withinIntegerRange(LETTERS[1L:2L], 3L, 10L), c(3L, 3L))
  expect_identical(withinIntegerRange(2147483647, 0L, 10L), 10L)
})

## -- CL2 ---------------------------------------------------------------------

test_that("CL2: create_wkbk stops, naming the folder, when the folder is
          missing", {
  folder <- file.path(tempfile("noWorkbookFolder"), "deeper")
  workbook <- file.path(folder, "wkbk.xlsx")
  message <- errorMessage(suppressWarnings(
    create_wkbk(workbook, list(data.frame(a = 1L)), "sheet1")
  ))
  expect_match(message, "does not exist", fixed = TRUE)
  ## dirname() is what create_wkbk() prints; on Windows it writes "/" where
  ## tempfile() wrote "\", so compare with it and not with `folder`.
  expect_match(message, dirname(workbook), fixed = TRUE)
  expect_false(file.exists(workbook))
})

test_that("CL2: create_wkbk still writes into a folder that exists
          (green at HEAD)", {
  workbook <- tempfile(fileext = ".xlsx")
  on.exit(unlink(workbook), add = TRUE)
  expect_true(create_wkbk(workbook, list(data.frame(a = 1L)), "sheet1"))
  expect_true(file.exists(workbook))
})

## -- CL3 ---------------------------------------------------------------------

fileTypeMessage <- "fileType must be one of \"txt\", \"csv\" or \"excel\""

test_that("CL3: a fileType that is not one known type stops with one plain
          message", {
  dfList <- list(a = data.frame(x = 1L))
  folder <- tempfile("fileTypeFolder")
  dir.create(folder)
  on.exit(unlink(folder, recursive = TRUE), add = TRUE)
  for (bad in list(c("csv", "txt"), "pdf", character(0L), NA_character_)) {
    label <- paste0("fileType = c(", toString(dQuote(bad, FALSE)), ")")
    expect_match(
      errorMessage(saveDataframesAsFiles(dfList, folder, fileType = bad)),
      fileTypeMessage, fixed = TRUE, info = label
    )
    expect_match(
      errorMessage(makeExamplePedigreeFile(file.path(folder, "ex.csv"),
                                           fileType = bad)),
      fileTypeMessage, fixed = TRUE, info = label
    )
  }
  expect_length(list.files(folder), 0L)
})

test_that("CL3: each known fileType is still written (green at HEAD)", {
  dfList <- list(a = data.frame(x = 1L))
  folder <- tempfile("fileTypeFolder")
  dir.create(folder)
  on.exit(unlink(folder, recursive = TRUE), add = TRUE)
  for (type in c("csv", "txt", "excel")) {
    files <- saveDataframesAsFiles(dfList, folder, fileType = type)
    expect_true(file.exists(files), info = type)
  }
})

## -- CE3 ---------------------------------------------------------------------

test_that("CE3: an NA minDate is no lower bound", {
  baseDate <- as.Date(c("2020-01-10", "2020-01-10"))
  withr::with_seed(20261019L, {
    obfuscated <- obfuscateDate(baseDate, as.Date(c(NA, "2020-01-08")), 5L)
  })
  expect_s3_class(obfuscated, "Date")
  expect_false(anyNA(obfuscated))
  expect_lte(abs(as.numeric(obfuscated[1L] - baseDate[1L])), 5)
  expect_gte(as.numeric(obfuscated[2L]), as.numeric(as.Date("2020-01-08")))
})

test_that("CE3: a minDate no draw can reach stops and names the element", {
  expected <- paste("minDate is on or after baseDate + maxDelta for element 1,",
                    "so no obfuscated date can be chosen.")
  expect_identical(
    errorMessage(withinSeconds(
      obfuscateDate(as.Date("2020-01-01"), as.Date("2021-01-01"), 5L)
    )),
    expected
  )
  ## equal to the top of the range is as unreachable as past it
  expect_identical(
    errorMessage(withinSeconds(
      obfuscateDate(as.Date("2020-01-01"), as.Date("2020-01-06"), 5L)
    )),
    expected
  )
  expect_match(
    errorMessage(withinSeconds(obfuscateDate(
      as.Date(c("2020-01-01", "2020-01-01")),
      as.Date(c("2019-12-30", "2021-01-01")), 5L
    ))),
    "for element 2,", fixed = TRUE
  )
})

test_that("CE3: the length message names maxDelta", {
  expect_identical(
    errorMessage(obfuscateDate(as.Date(c("2020-01-01", "2020-02-01")),
                               maxDelta = c(1L, 2L, 3L))),
    "Length of maxDelta must be 1 or the same as baseDate."
  )
})

test_that("CE3: a minDate inside the range still binds (green at HEAD)", {
  withr::with_seed(20261019L, {
    draws <- replicate(
      200L,
      obfuscateDate(as.Date("2020-01-10"), as.Date("2020-01-08"), 5L)
    )
  })
  expect_true(all(draws >= as.numeric(as.Date("2020-01-08"))))
})

test_that("CE3: a range of one day returns that day when minDate is on it
          (green at HEAD)", {
  expect_equal(
    withinSeconds(obfuscateDate(as.Date("2020-01-01"), as.Date("2020-01-01"),
                                0L)),
    as.Date("2020-01-01")
  )
})

## -- CE6 ---------------------------------------------------------------------

test_that("CE6: checkCrossCenterMapping names itself in its structural
          errors", {
  goodPed <- data.frame(id = "a", sire = NA_character_, dam = NA_character_,
                        stringsAsFactors = FALSE)
  badPed <- data.frame(x = 1L)
  goodMapping <- data.frame(idA = "a", idB = "b", stringsAsFactors = FALSE)
  expect_match(
    errorMessage(checkCrossCenterMapping(badPed, goodPed, goodMapping)),
    "^checkCrossCenterMapping\\(\\): 'pedA' must contain columns id, sire, ",
    perl = TRUE
  )
  expect_match(
    errorMessage(checkCrossCenterMapping(goodPed, badPed, goodMapping)),
    "^checkCrossCenterMapping\\(\\): 'pedB' must contain columns id, sire, ",
    perl = TRUE
  )
  expect_match(
    errorMessage(checkCrossCenterMapping(goodPed, goodPed, badPed)),
    "^checkCrossCenterMapping\\(\\): 'mapping' must contain columns idA and ",
    perl = TRUE
  )
})

test_that("CE6: resolveCrossCenterIds keeps its own name (green at HEAD)", {
  goodPed <- data.frame(id = "a", sire = NA_character_, dam = NA_character_,
                        stringsAsFactors = FALSE)
  badPed <- data.frame(x = 1L)
  goodMapping <- data.frame(idA = "a", idB = "b", stringsAsFactors = FALSE)
  expect_match(
    errorMessage(resolveCrossCenterIds(badPed, goodPed, goodMapping)),
    "^resolveCrossCenterIds\\(\\): 'pedA' must contain columns id, sire, ",
    perl = TRUE
  )
  expect_match(
    errorMessage(resolveCrossCenterIds(goodPed, goodPed, badPed)),
    "^resolveCrossCenterIds\\(\\): 'mapping' must contain columns idA and ",
    perl = TRUE
  )
})

## -- CE7 ---------------------------------------------------------------------

naIdPedigree <- function() {
  data.frame(
    id = c("A1", NA, "C3"), sire = c(NA, NA, "A1"), dam = c(NA, NA, NA),
    sex = c("M", "F", "M"),
    birth = as.Date(c("2000-01-01", "2000-01-02", "2001-01-01")),
    stringsAsFactors = FALSE
  )
}

test_that("CE7: an NA id stops obfuscateId and obfuscatePed with a plain
          message naming the position", {
  expect_identical(
    errorMessage(obfuscateId(c("A1", NA))),
    "id must not contain NA; found at position(s): 2"
  )
  expect_identical(
    errorMessage(obfuscateId(c(NA, "A1", NA))),
    "id must not contain NA; found at position(s): 1, 3"
  )
  expect_identical(
    errorMessage(obfuscatePed(naIdPedigree())),
    "id must not contain NA; found at position(s): 2"
  )
})

test_that("CE7: an NA sire or dam and an empty id still work (green at HEAD)", {
  ped <- naIdPedigree()
  ped$id[2L] <- "B2"
  expect_identical(names(obfuscatePed(ped)), names(ped))
  expect_identical(obfuscateId(character(0L)), setNames(character(0L),
                                                        character(0L)))
})

## -- CK1 ---------------------------------------------------------------------

## The three default files makeExamplePedigreeFile() can write into the
## session's temporary directory, removed before and after each block.
defaultExampleFiles <- function() {
  file.path(tempdir(), paste0("examplePedigree.", c("csv", "txt", "xlsx")))
}

test_that("CK1: the default file name follows the file type", {
  unlink(defaultExampleFiles())
  on.exit(unlink(defaultExampleFiles()), add = TRUE)
  expect_identical(basename(makeExamplePedigreeFile(fileType = "csv")),
                   "examplePedigree.csv")
  expect_identical(basename(makeExamplePedigreeFile(fileType = "txt")),
                   "examplePedigree.txt")
  excelFile <- makeExamplePedigreeFile(fileType = "excel")
  expect_identical(basename(excelFile), "examplePedigree.xlsx")
  expect_true(file.exists(excelFile))
  expect_identical(nrow(readExcelPOSIXToCharacter(excelFile)),
                   nrow(nprcgenekeepr::examplePedigree))
})

test_that("CK1: the help names the three default files", {
  places <- helpPlaces("makeExamplePedigreeFile", "makeExamplePedigreeFile.R")
  skipUnlessHelpInSourceTree(places)
  for (read in places) {
    expectWording(
      read(),
      now = "examplePedigree.csv, examplePedigree.txt or examplePedigree.xlsx",
      gone = character(0L)
    )
  }
})

test_that("CK1: a file given by name is written where it is told
          (green at HEAD)", {
  target <- tempfile(fileext = ".tsv")
  on.exit(unlink(target), add = TRUE)
  expect_identical(makeExamplePedigreeFile(target, fileType = "txt"), target)
  expect_true(file.exists(target))
})

## -- CK2 ---------------------------------------------------------------------

test_that("CK2: the data are as the help will say (green at HEAD)", {
  expect_true(is.factor(nprcgenekeepr::focalAnimals$id))
  expect_true(is.character(nprcgenekeepr::examplePedigree$id))
})

test_that("CK2: the focalAnimals help says its id column is a factor", {
  places <- helpPlaces("focalAnimals", "data.R")
  skipUnlessHelpInSourceTree(places)
  for (read in places) {
    expectWording(
      read(),
      now = c(paste("The id column is a factor, not a character vector like",
                    "the id column of examplePedigree"),
              "as.character(focalAnimals$id)"),
      gone = character(0L)
    )
  }
})

## -- CL1 ---------------------------------------------------------------------

test_that("CL1: the zero-row and zero-column text has no backslash-n", {
  zeroRows <- dataframe2string(data.frame(a = 1L)[0L, , drop = FALSE])
  zeroColumns <- dataframe2string(data.frame(a = 1L:3L)[, 0L, drop = FALSE])
  zeroBoth <- dataframe2string(data.frame())
  expect_identical(zeroRows, "<0 rows> (or 0-length row names)")
  expect_identical(zeroColumns, "data frame with 0 columns and 3 rows")
  expect_identical(zeroBoth, "data frame with 0 columns and 0 rows")
})

test_that("CL1: a data frame with rows still has none at its end
          (green at HEAD)", {
  text <- dataframe2string(data.frame(a = 1L:2L, b = c("x", "y")))
  expect_length(text, 1L)
  expect_false(endsWith(text, "\n"))
  expect_false(endsWith(text, "\\n"))
  expect_match(text, "\n", fixed = TRUE)
})

## -- CL5 ---------------------------------------------------------------------

## A pedigree whose exit headers are written in `headers` (id first), the
## death and departure dates the same in every spelling.
exitPedigree <- function(headers) {
  dates <- list(
    birth = as.Date(c("2000-01-01", "2001-01-01", "2002-01-01")),
    death = as.Date(c("2010-01-01", NA, "2012-06-01")),
    departure = as.Date(c(NA, "2011-01-01", "2012-03-01"))
  )
  ped <- data.frame(id = c("a", "b", "c"), stringsAsFactors = FALSE)
  for (name in names(headers)) {
    ped[[headers[[name]]]] <- dates[[name]]
  }
  ped
}

test_that("CL5: setExit reads the death and departure columns under the
          names they have", {
  lower <- c(birth = "birth", death = "death", departure = "departure")
  spellings <- list(
    "Death" = c(birth = "Birth", death = "Death"),
    "DEPARTURE" = c(birth = "birth", departure = "DEPARTURE"),
    "Death and Departure" = c(birth = "Birth", death = "Death",
                              departure = "Departure")
  )
  for (label in names(spellings)) {
    headers <- spellings[[label]]
    withExit <- setExit(exitPedigree(headers))
    expect_true("exit" %in% names(withExit), info = label)
    expect_identical(
      withExit$exit,
      setExit(exitPedigree(lower[names(headers)]))$exit,
      info = label
    )
  }
})

test_that("CL5: lower-case headers set the exit as before (green at HEAD)", {
  both <- setExit(exitPedigree(c(birth = "birth", death = "death",
                                 departure = "departure")))
  expect_identical(both$exit,
                   as.Date(c("2010-01-01", "2011-01-01", "2012-03-01")))
  expect_true(all(is.na(setExit(exitPedigree(c(birth = "birth")))$exit)))
})

## -- CJ8 ---------------------------------------------------------------------

test_that("CJ8: repeated group labels stop the heat map and are named", {
  repeated <- data.frame(group = c("G1", "G1", "G2", "G3", "G3"),
                         m1 = c(1L, 2L, 3L, 1L, 2L),
                         m2 = c(3L, 2L, 1L, 2L, 3L),
                         stringsAsFactors = FALSE)
  expect_identical(
    errorMessage(makeGeneticDiversityHeatmap(repeated)),
    paste0("makeGeneticDiversityHeatmap() requires the group labels to be ",
           "unique; repeated: G1, G3.")
  )
})

test_that("CJ8: unique group labels draw one row each (green at HEAD)", {
  unique3 <- data.frame(group = c("G1", "G2", "G3"), m1 = c(1L, 2L, 3L),
                        m2 = c(3L, 2L, 1L), stringsAsFactors = FALSE)
  plot <- makeGeneticDiversityHeatmap(unique3)
  expect_identical(nlevels(plot$data$group), 3L)
  expect_identical(nrow(plot$data), 6L)
})
