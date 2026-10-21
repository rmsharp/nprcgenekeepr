## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## S1025 (BACKLOG.md docs-audit part 2; the owner: "finish the items left in the
## section beginning on line 16"). The six wrong or missing lines that item
## still carried in its help and examples. Each was measured against the code
## at S1025; at the scope question the owner took "give them the default of 1"
## for DA1 (the other choice was to change the sentence).
##
##   DA1 makeGroupNum() and its alias makeGrpNum() say numGp "Default is 1"
##       but have no default, so calling either with no number stops.
##   DA2 the examples of fillGroupMembersWithSexRatio(), groupAddAssign(),
##       getPedMaxAge() and setPopulation() pass the deprecated minParentAge
##       to qcStudbook() (the backlog named the first two; a scan of the
##       examples of all 267 man pages found the other two).
##   DA3 getGeneticDiversityStats() is exported with no example.
##   DA4 the savePlotToFile() example sits in \dontrun and writes to the
##       working directory.
##   DA5 the Genetic Value help names "the Summary Statistics relationship
##       table", which that tab never shows; the table is the one the Export
##       All Relationships button writes.
##   DA6 NEWS.Rmd and NEWS.md say what DA1 changed.
##
## Blocks marked "(green at HEAD)" pass before the fix; they pin what stays.

## sourceLines(), plainText(), expectNames(), occurrences(), manText(),
## roxygenText(), helpPlaces() and skipUnlessHelpInSourceTree() are in
## helper-pageText.R; newsTopBlock() and newsEntries() are in
## helper-newsBlocks.R.

## The code of the example section of a man page (tools::Rd2ex() output), one
## string per line; character(0) for a page with no example. `rd` is the path.
exampleLinesOf <- function(rd) {
  out <- tempfile(fileext = ".R")
  on.exit(unlink(out), add = TRUE)
  suppressMessages(tools::Rd2ex(rd, out))
  if (file.exists(out)) readLines(out, warn = FALSE) else character(0L)
}

## The example code of the man page of `topic`; skips where man/ is absent (an
## installed package).
exampleLines <- function(topic) {
  rd <- testthat::test_path("..", "..", "man", paste0(topic, ".Rd"))
  skip_if_not(file.exists(rd), "man/*.Rd not available (installed package)")
  exampleLinesOf(rd)
}

## Runs the lines in a fresh child of the global environment and gives the
## value of the last one.
runExample <- function(code) {
  eval(parse(text = code), envir = new.env(parent = globalenv()))
}

## -- DA1 ---------------------------------------------------------------------

test_that("DA1: makeGroupNum() and makeGrpNum() with no number make one group", {
  expect_identical(makeGroupNum(), list(1L))
  expect_warning(g <- makeGrpNum(), "makeGroupNum")
  expect_identical(g, list(1L))
})

test_that("DA1: the default of numGp is the integer 1 in both usages", {
  expect_identical(formals(makeGroupNum)$numGp, 1L)
  expect_identical(formals(makeGrpNum)$numGp, 1L)
  for (topic in c("makeGroupNum", "makeGrpNum")) {
    page <- manText(topic)
    skip_if(is.na(page), "man/*.Rd not available (installed package)")
    expect_true(grepl(paste0(topic, "(numGp = 1L)"), page, fixed = TRUE),
                info = topic)
  }
})

test_that("DA1: a number given still makes that many groups (green at HEAD)", {
  expect_identical(makeGroupNum(3L), list(1L, 2L, 3L))
  expect_identical(makeGroupNum(1L), list(1L))
  expect_warning(g <- makeGrpNum(2L), "makeGroupNum")
  expect_identical(g, list(1L, 2L))
})

test_that("DA1: the help keeps saying 'Default is 1', now true (green at HEAD)", {
  for (topic in c("makeGroupNum", "makeGrpNum")) {
    page <- manText(topic)
    skip_if(is.na(page), "man/*.Rd not available (installed package)")
    expect_equal(occurrences(page, "Default is 1."), 1L, info = topic)
  }
  source <- roxygenText("makeGroupNum.R")
  skip_if(is.na(source), "R/*.R not available (installed package)")
  expect_equal(occurrences(source, "Default is 1."), 2L)
})

## -- DA2 ---------------------------------------------------------------------

test_that("DA2: no example on any man page passes the deprecated minParentAge", {
  dir <- testthat::test_path("..", "..", "man")
  skip_if_not(dir.exists(dir), "man/ not available (installed package)")
  pages <- list.files(dir, pattern = "[.]Rd$", full.names = TRUE)
  expect_gt(length(pages), 200L)
  naming <- Filter(function(rd) {
    any(grepl("minParentAge", exampleLinesOf(rd), fixed = TRUE))
  }, pages)
  expect_identical(sort(basename(naming)), character(0L))
})

test_that("DA2: the four examples name minSireAge and minDamAge instead", {
  pages <- list(c("fillGroupMembersWithSexRatio",
                  "fillGroupMembersWithSexRatio.R"),
                c("groupAddAssign", "groupAddAssign.R"),
                c("getPedMaxAge", "getPedMaxAge.R"),
                c("setPopulation", "setPopulation.R"))
  for (page in pages) {
    places <- helpPlaces(page[1L], page[2L])
    skipUnlessHelpInSourceTree(places)
    for (where in names(places)) {
      text <- places[[where]]()
      expectNames(text, c("minSireAge = 2", "minDamAge = 2"),
                  where = paste(page[1L], where))
      expect_false(grepl("minParentAge", text, fixed = TRUE),
                   info = paste(page[1L], where))
    }
  }
})

test_that("DA2: the two ages give the result minParentAge gave (green at HEAD)", {
  examplePed <- nprcgenekeepr::examplePedigree
  old <- suppressWarnings(
    qcStudbook(examplePed, minParentAge = 2, reportChanges = FALSE,
               reportErrors = FALSE)
  )
  expect_warning(
    new <- qcStudbook(examplePed, minSireAge = 2, minDamAge = 2,
                      reportChanges = FALSE, reportErrors = FALSE),
    NA
  )
  expect_identical(new, old)
})

## -- DA3 ---------------------------------------------------------------------

test_that("DA3: getGeneticDiversityStats() has an example in both places", {
  expect_gt(length(exampleLines("getGeneticDiversityStats")), 0L)
  source <- roxygenText("getGeneticDiversityStats.R")
  skip_if(is.na(source), "R/*.R not available (installed package)")
  expect_true(grepl("@examples", source, fixed = TRUE))
})

test_that("DA3: the example runs clean and returns the group table", {
  code <- exampleLines("getGeneticDiversityStats")
  expect_gt(length(code), 0L)
  if (length(code) > 0L) {
    expect_warning(value <- runExample(code), NA)
    expect_s3_class(value, "data.frame")
    expect_true(all(c("group", "Value", "Production", "Inbreeding") %in%
                      names(value)))
    expect_gte(nrow(value), 2L)
  }
})

## -- DA4 ---------------------------------------------------------------------

test_that("DA4: the savePlotToFile() example is not in \\dontrun", {
  code <- exampleLines("savePlotToFile")
  expect_gt(length(code), 0L)
  expect_false(any(grepl("Not run", code, fixed = TRUE)))
  expect_true(any(grepl("savePlotToFile(", code, fixed = TRUE)))
})

test_that("DA4: the savePlotToFile() example writes only to temp files", {
  code <- exampleLines("savePlotToFile")
  expect_true(any(grepl("tempfile(", code, fixed = TRUE)))
  workDir <- withr::local_tempdir()
  withr::with_dir(workDir, {
    expect_warning(runExample(code), NA)
  })
  expect_identical(list.files(workDir, all.files = TRUE, no.. = TRUE),
                   character(0L))
})

## -- DA5 ---------------------------------------------------------------------

test_that("DA5: the Genetic Value help names the exported relationship table", {
  ui <- plainText(as.character(modGeneticValueUI("gv")), html = TRUE)
  expectWording(
    ui,
    now = paste(
      "In the relationship table that the Summary Statistics tab exports",
      "(Export All Relationships), the relationship label stays",
      "pedigree-derived, so the label and the overridden value can disagree."
    ),
    gone = "In the Summary Statistics relationship table"
  )
})

test_that("DA5: the button the help names is on the Summary Statistics tab
(green at HEAD)", {
  ui <- plainText(as.character(modSummaryStatsUI("ss")), html = TRUE)
  expect_equal(occurrences(ui, "Export All Relationships"), 1L)
})

## -- DA6 ---------------------------------------------------------------------

test_that("DA6: NEWS.Rmd and NEWS.md say the two functions make one group", {
  for (file in c("NEWS.Rmd", "NEWS.md")) {
    entries <- newsEntries(newsTopBlock(sourceLines(file)))
    scripts <- entries$text[startsWith(entries$text, "Fixed (scripts):")]
    expect_length(scripts, 1L)
    expect_equal(
      occurrences(plainText(scripts),
                  paste("makeGroupNum() and makeGrpNum() make one group when",
                        "called with no number")),
      1L, info = file
    )
  }
})
