## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S1024, BACKLOG.md:168): the "## General Fixes" part of the newest NEWS
## block listed 45 separate "Fixed:" items (17,752 B). The owner asked that bug
## fixes be grouped instead of listed one by one and ruled "One bullet per
## area" (S1024): at most one "Fixed (<area>):" bullet for each of seven areas.
## The "New" and "Changed" bullets stay as they are. Each former item keeps one
## named fact (a function, a screen term, a file name) in the bullet of its
## area, so grouping loses nothing; the sentences themselves are the owner's to
## approve at the RED to GREEN gate, so this file pins only what a sentence
## must carry.
##
## NEWS.Rmd and NEWS.md are build-ignored, so every block that reads them skips
## inside an R CMD check tarball. sourceLines() and plainText() are in
## helper-pageText.R; newsTopBlock() and newsEntries() are in
## helper-newsBlocks.R.

library(testthat)

newsFiles <- c("NEWS.Rmd", "NEWS.md")

## The seven areas the owner approved (S1024).
fixAreas <- c(
  "pedigree checks and Potential Parents",
  "Breeding Groups and Genetic Diversity",
  "Genetic Value",
  "genotype files",
  "scripts",
  "configuration file",
  "other tabs and the example file"
)

## The bullets that are not "Fixed:" items and stay as they are: the first
## words of each, as plainText() reads them (backticks dropped).
keptBullets <- c(
  "New: the Input tab now warns when animals",
  "New: the Input tab now warns when an animal",
  "New placeholder column:",
  "A placeholder value other than TRUE, FALSE, 1, 0 or blank stops the check",
  "Changed: Potential Parents (getPotentialParents()) lists candidates only",
  "New: each Potential Parents result (getPotentialParents()) now says where",
  "New: with \"Pedigree(s) and genotypes in one file\", the Input tab now reads"
)

## One fact per former "Fixed:" item: factArea is the index into fixAreas of
## the bullet that must hold it, factText the phrase. The empty-cell item
## ("empty cell") also owns "OTHER instead of UNKNOWN", the tail that stood
## after it as a bullet of its own.
factArea <- c(
  2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 7, 2, 2, 1, 1, 1, 1, 1, 4,
  3, 3, 7, 4, 4, 3, 5, 5, 5, 5, 5, 1, 1, 5, 5, 5, 7, 6, 6, 6,
  6, 6, 1, 5, 5, 5
)
factText <- c(
  "Download Audit Manifest",
  "no breeding-age females",
  "ends the session",
  "no offspring",
  "2.5 times",
  "every invalid date",
  "convertFromCenter()",
  "geographicorigin",
  "recordstatus",
  "checkRequiredCols()",
  "fixColumnNames()",
  "Download Plot",
  "kmat is missing kinship",
  "form the groups again",
  "Records Processed",
  "Display Unknown IDs",
  "female sire",
  "empty cell",
  "OTHER instead of UNKNOWN",
  "genotype file was not used",
  "Founder genome equivalents",
  "readKinshipOverrides()",
  "deidentified_jmac_ped.csv",
  "de-identified export preview",
  "isReady",
  "regional settings",
  "removeUnknownAnimals()",
  "infinite recursion",
  "argument is of length zero",
  "getLkDirectAncestors()",
  "convertRelationships()",
  "addUIds()",
  "too close in time",
  "gen or sex",
  "gvaConvergence()",
  "calcGUSE()",
  "character(0)",
  "paste-your-labkey-api-key-here",
  "subscript out of bounds",
  "/My Folder/EHR",
  "apiKey",
  "exampleNprcgenekeeprConfig",
  "get_elapsed_time_str()",
  "create_wkbk()",
  "obfuscateDate()",
  "setExit()"
)

## The lines of the "## General Fixes" part of the newest version block (see
## newsTopBlock() in helper-newsBlocks.R), up to the next "## ".
newsGeneralFixesLines <- function(lines) {
  block <- newsTopBlock(lines)$lines
  start <- grep("^## General Fixes\\s*$", block)
  if (length(start) == 0L) {
    return(character(0L))
  }
  rest <- block[-seq_len(start[1L])]
  nextHead <- grep("^## ", rest)
  if (length(nextHead) > 0L) {
    rest <- rest[seq_len(nextHead[1L] - 1L)]
  }
  rest
}

## The bullets of some lines, each as plain text without its "- " (see
## newsEntries() in helper-newsBlocks.R).
newsBullets <- function(lines) {
  entries <- newsEntries(list(start = 1L, lines = lines))
  vapply(entries$text, plainText, character(1L), USE.NAMES = FALSE)
}

## The area in "Fixed (<area>): ..."; NA for a bullet written another way.
fixedLabel <- function(text) {
  found <- regmatches(text, regexec("^Fixed \\(([^)]+)\\):", text))
  vapply(found, function(x) {
    if (length(x) == 2L) x[[2L]] else NA_character_
  }, character(1L))
}

## The "Fixed" bullets of the General Fixes part of one news file.
fixedBulletsOf <- function(file) {
  bullets <- newsBullets(newsGeneralFixesLines(sourceLines(file)))
  bullets[startsWith(bullets, "Fixed")]
}

## The reader, on small invented files ------------------------------------

invented <- c(
  "# nprcgenekeepr 9.9 (development version)",
  "",
  "## General Fixes",
  "",
  "- Fixed (scripts): `one`",
  "  continued here",
  "",
  "- New: two",
  "",
  "## Other",
  "",
  "- Fixed: not read",
  "",
  "# nprcgenekeepr 9.8 (20200101)",
  "",
  "## General Fixes",
  "",
  "- Fixed: an older release"
)

test_that("the reader gives the newest block's General Fixes bullets, joined", {
  expect_identical(newsBullets(newsGeneralFixesLines(invented)),
                   c("Fixed (scripts): one continued here", "New: two"))
})

test_that("the reader gives nothing without a heading, a part or a bullet", {
  expect_identical(newsGeneralFixesLines(character(0L)), character(0L))
  expect_identical(newsGeneralFixesLines(c("# nprcgenekeepr 1", "text")),
                   character(0L))
  expect_identical(newsGeneralFixesLines(c("# nprcgenekeepr 1",
                                           "## General Fixes")),
                   character(0L))
  expect_identical(newsBullets(character(0L)), character(0L))
  expect_identical(newsBullets(c("text", "  indented")), character(0L))
})

test_that("the label is the area in brackets, NA for any other opening", {
  expect_identical(fixedLabel(c("Fixed (scripts): x", "Fixed: x", "New: x",
                                "Fixed (two words): y")),
                   c("scripts", NA, NA, "two words"))
  expect_identical(fixedLabel(character(0L)), character(0L))
})

test_that("the fact table is well formed", {
  expect_length(factText, length(factArea))
  expect_true(all(factArea %in% seq_along(fixAreas)))
  expect_false(anyDuplicated(factText) > 0L)
  expect_false(anyDuplicated(fixAreas) > 0L)
})

## The real files -----------------------------------------------------------

test_that("General Fixes holds only 'Fixed (area):' bullets, one per area", {
  for (file in newsFiles) {
    fixed <- fixedBulletsOf(file)
    labels <- fixedLabel(fixed)
    expect_true(length(fixed) > 0L, info = file)
    expect_false(anyNA(labels),
                 info = paste(file, "has a Fixed bullet with no area"))
    expect_true(all(labels %in% fixAreas),
                info = paste(file, "has an area that is not one of the seven"))
    expect_false(anyDuplicated(labels[!is.na(labels)]) > 0L,
                 info = paste(file, "has two bullets for one area"))
  }
})

test_that("the New and Changed bullets of General Fixes stay, once each", {
  for (file in newsFiles) {
    bullets <- newsBullets(newsGeneralFixesLines(sourceLines(file)))
    for (opening in keptBullets) {
      expect_equal(sum(startsWith(bullets, opening)), 1L,
                   info = paste(file, opening))
    }
  }
})

test_that("every former item's fact is still in General Fixes", {
  for (file in newsFiles) {
    section <- plainText(newsGeneralFixesLines(sourceLines(file)))
    expectNames(section, factText, where = file)
  }
})

test_that("each fact stands in the one bullet of its area", {
  for (file in newsFiles) {
    fixed <- fixedBulletsOf(file)
    labels <- fixedLabel(fixed)
    for (k in seq_along(factText)) {
      area <- fixAreas[factArea[k]]
      inArea <- fixed[!is.na(labels) & labels == area]
      expect_true(length(inArea) == 1L &&
                    grepl(factText[k], inArea, fixed = TRUE),
                  info = paste(file, area, factText[k]))
    }
  }
})
