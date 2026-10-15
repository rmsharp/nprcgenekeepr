## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## S998 (BACKLOG.md docs-audit part 2, slice 6d candidate CB1; the owner chose
## "both cases, one sentence" at the PRE-RED scope question). With "Pedigree(s)
## and genotypes in separate files" the Input tab dropped a genotype file the
## genotype check refuses without a word to the user, and a genotype file that
## could not be read at all stopped the observer, which ends the session.
## Measured S998 before any change (the real app, the bundled 375-animal MHC
## pedigree, headless Chrome; the module for the other files):
##
##   genotype file                              QC Summary         what happened
##   a good file                                375 / 0 / 1, green genotypes merged
##   two columns (the check refuses it)         the same words     genotypes dropped, no word
##   first column not an id / a column named
##     first / an allele of 20000 (the check)   the same (module)  genotypes dropped, no word
##   one short row (cannot be read)             nothing; the page  session ended (Shiny's
##                                              greys out          disconnected overlay)
##
## The fix says one sentence under the three boxes, in the same blue box the
## one-file mode uses (storedResults()$genotypeNote, test_modInputOneFileGenotypes.R):
##   "The genotype file was not used, so no genotypes are used. Reason: <why>"
## <why> is the condition's own message, with a full stop added when it has
## none; a warning or an error from the genotype check drops the file as before
## (a warning while only reading the file does not); an empty message leaves the
## sentence without "Reason:". The pedigree is still processed, and Errors and
## Warnings do not move. Blocks that guard what must not change (a good file,
## the pedigree-only mode) pass before the change and have to keep passing.

testthat::skip_on_cran()

notUsed <- "The genotype file was not used, so no genotypes are used."

expectedNote <- function(reason) paste(notUsed, "Reason:", reason)

## Write `lines` to a temporary CSV and return its path.
writeLinesTemp <- function(lines) {
  path <- tempfile(fileext = ".csv")
  writeLines(lines, path)
  path
}

## A genotype file for the eight animals of helper-oneFileGenotypes.R.
goodGenotypeLines <- c(
  "id,first_name,second_name",
  paste(oneFileIds, c("A", "B", "A", "B", "C", "C", "A", "B"),
        c("B", "C", "C", "A", "A", "B", "B", "C"), sep = ",")
)

## Run the Input module on the eight-animal pedigree, with the genotype file at
## `genotypePath` (none when NULL), in `mode`, and return what a user gets: the
## cleaned studbook, the genotype extract, the QC Summary's line, the error and
## warning tables and the rendered QC Summary as one HTML string.
runSeparate <- function(genotypePath = NULL,
                        mode = "separatePedGenoFile") {
  pedPath <- tempfile(fileext = ".csv")
  utils::write.csv(oneFileWith(), pedPath, row.names = FALSE)
  pedUpload <- if (identical(mode, "pedFile")) {
    "pedigreeFileOne"
  } else {
    "pedigreeFileThree"
  }
  out <- NULL
  shiny::testServer(modInputServer, args = list(), {
    session$setInputs(fileContent = mode, fileType = "fileTypeExcel",
                      separator = ",", minSireAge = "0.1", minDamAge = "0.1")
    upload <- list(list(name = basename(pedPath), datapath = pedPath))
    names(upload) <- pedUpload
    do.call(session$setInputs, upload)
    if (!is.null(genotypePath)) {
      session$setInputs(genotypeFile = list(name = basename(genotypePath),
                                            datapath = genotypePath))
    }
    session$setInputs(getData = 1)
    session$flushReact()
    stored <- tryCatch(storedResults(), error = function(e) NULL)
    result <- session$getReturned()
    out <<- list(
      cleaned = tryCatch(result$cleanedStudbook(), error = function(e) NULL),
      genotype = tryCatch(result$genotypeData(), error = function(e) NULL),
      note = stored$genotypeNote,
      errors = stored$errors,
      warnings = stored$warnings,
      html = paste(as.character(output$qcSummaryUI), collapse = "")
    )
  })
  out
}

## The pedigree-only run: the Errors and Warnings a pedigree gives with no
## genotype file in play.
pedigreeOnly <- runSeparate(mode = "pedFile")

## What a user must get when the genotype file is not used: the sentence in the
## blue box, the pedigree processed as before, the genotypes left out.
expectNotUsed <- function(res, note) {
  expect_identical(res$note, note)
  expect_match(res$html, "alert alert-info", fixed = TRUE)
  expect_match(res$html, htmltools::htmlEscape(note), fixed = TRUE)
  expect_null(res$genotype)
  expect_equal(nrow(res$cleaned), length(oneFileIds))
  expect_false(any(c("first", "second") %in% names(res$cleaned)))
  expect_equal(nrow(res$errors), 0L)
  expect_equal(nrow(res$warnings), nrow(pedigreeOnly$warnings))
}

test_that("a good genotype file is merged and the QC Summary has no line about it", {
  res <- runSeparate(writeLinesTemp(goodGenotypeLines))
  expect_null(res$note)
  expect_false(grepl("alert-info", res$html, fixed = TRUE))
  expect_true(all(c("first", "second") %in% names(res$cleaned)))
  expect_false(is.null(res$genotype))
})

test_that("a genotype file with fewer than three columns is named in the QC Summary", {
  res <- runSeparate(writeLinesTemp(c("id,first_name", "s1,A", "d1,B")))
  expectNotUsed(
    res, expectedNote("Genotype file must have at least three columns."))
})

test_that("a genotype file whose first column is not an id is named in the QC Summary", {
  res <- runSeparate(writeLinesTemp(
    c("animal,first_name,second_name", "s1,A,B", "d1,B,C")))
  expectNotUsed(
    res, expectedNote("Genotype file must have 'id' as the first column."))
})

test_that("a genotype file with a column named first is named in the QC Summary", {
  res <- runSeparate(writeLinesTemp(c("id,first,second", "s1,1,2", "d1,2,3")))
  expectNotUsed(
    res,
    expectedNote(
      "Genotype file cannot have a column named 'first' or 'second'."))
})

test_that("a genotype file with an allele above 10000 is named in the QC Summary", {
  res <- runSeparate(writeLinesTemp(
    c("id,first_name,second_name", "s1,20000,B", "d1,A,C")))
  expectNotUsed(
    res,
    expectedNote(paste0("Possible collision on allele(s) interpreted as a ",
                        "number > 10000: 20000 in column 'first_name'.")))
})

test_that("a genotype file with a short row no longer ends the run and is named in the QC Summary", {
  res <- runSeparate(writeLinesTemp(
    c("id,first_name,second_name", "s1,A,B", "d1,C")))
  expectNotUsed(res, expectedNote("line 2 did not have 3 elements."))
})

test_that("a warning from the genotype check drops the file with the same sentence", {
  local_mocked_bindings(
    checkGenotypeFile = function(genotype) warning("odd value in the file")
  )
  res <- runSeparate(writeLinesTemp(goodGenotypeLines))
  expectNotUsed(res, expectedNote("odd value in the file."))
})

test_that("a reason with no words leaves the sentence without 'Reason:'", {
  local_mocked_bindings(
    checkGenotypeFile = function(genotype) stop("")
  )
  res <- runSeparate(writeLinesTemp(goodGenotypeLines))
  expectNotUsed(res, notUsed)
})

## A guard added at GREEN (S998), not a RED block (a mutation run found it
## missing): a reason that already ends in "?" or "!" gets no full stop added.
test_that("a reason that already ends in a question mark gets no full stop added", {
  local_mocked_bindings(
    checkGenotypeFile = function(genotype) stop("what is in this file?")
  )
  res <- runSeparate(writeLinesTemp(goodGenotypeLines))
  expectNotUsed(res, expectedNote("what is in this file?"))
})

## A guard added at GREEN (S998), not a RED block: it passes before and after
## the change. A warning while only reading a file has never dropped it (the
## read sat outside the tryCatch); the new tryCatch around the read catches
## errors only, so it must stay that way.
test_that("a warning while only reading the genotype file does not drop it", {
  local_mocked_bindings(
    getGenotypes = function(fileName, sep = ",") {
      warning("harmless note while reading")
      data.frame(id = oneFileIds,
                 first_name = c("A", "B", "A", "B", "C", "C", "A", "B"),
                 second_name = c("B", "C", "C", "A", "A", "B", "B", "C"),
                 stringsAsFactors = FALSE)
    }
  )
  res <- suppressWarnings(runSeparate(writeLinesTemp(goodGenotypeLines)))
  expect_null(res$note)
  expect_false(grepl("alert-info", res$html, fixed = TRUE))
  expect_true(all(c("first", "second") %in% names(res$cleaned)))
  expect_false(is.null(res$genotype))
})

test_that("the pedigree-only mode says nothing about a genotype file left in the box", {
  res <- runSeparate(writeLinesTemp(c("id,first_name", "s1,A", "d1,B")),
                     mode = "pedFile")
  expect_null(res$note)
  expect_false(grepl("alert-info", res$html, fixed = TRUE))
  expect_equal(nrow(res$cleaned), length(oneFileIds))
  expect_equal(nrow(res$warnings), nrow(pedigreeOnly$warnings))
})

## The help said a refused file "is dropped without a message". Scoped to the
## genotypeData item so a mention elsewhere on the page cannot make it pass
## (Learning 89). Reads the generated man page and the R source (source/dev
## context; under an installed package neither exists and the blocks skip).
manPath <- testthat::test_path("..", "..", "man", "modInputServer.Rd")
sourcePath <- testthat::test_path("..", "..", "R", "modInput.R")

## The genotypeData item of the return list, white space collapsed.
genotypeDataItem <- function(lines) {
  text <- paste(sub("^#' ?", "", lines), collapse = " ")
  text <- trimws(gsub("\\s+", " ", text))
  item <- regmatches(
    text,
    regexpr("\\\\item \\\\code\\{genotypeData\\}.*?\\\\item \\\\code\\{qcSummary\\}",
            text, perl = TRUE))
  if (length(item)) item else NA_character_
}

expectHelpSaysWhy <- function(item) {
  expect_false(is.na(item))
  expect_false(grepl("without a message", item, fixed = TRUE))
  expect_match(item, "cannot be read", fixed = TRUE)
  expect_match(item, "QC Summary", fixed = TRUE)
}

test_that("the man page says the QC Summary names a genotype file that was not used", {
  skip_if(!file.exists(manPath), "man/modInputServer.Rd not available")
  expectHelpSaysWhy(genotypeDataItem(readLines(manPath, warn = FALSE)))
})

test_that("the roxygen block says the QC Summary names a genotype file that was not used", {
  skip_if(!file.exists(sourcePath), "R/modInput.R not available")
  lines <- readLines(sourcePath, warn = FALSE)
  expectHelpSaysWhy(genotypeDataItem(lines[grepl("^#'", lines)]))
})
