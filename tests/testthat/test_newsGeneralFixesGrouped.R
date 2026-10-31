## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## The newest NEWS block follows the Shiny app (owner rulings, S1099). S1024
## grouped 45 "Fixed:" items into seven "Fixed (<area>):" bullets. S1099 replaces
## those: a change stands in the section of the tab it belongs to, the sections
## run in the app's tab order (R/appUI.R), and "## General Fixes" keeps only what
## belongs to no tab, as three groups of nested bullets.
##
## A fix to something new in this release gets no line (owner ruling, S1022): no
## release had the bug. So the Download Audit Manifest, Marker Genetics export
## preview, isReady, reportMatePairs() and markerRealizedRelatednessVariance()
## fixes are barred from the places S1024's grouping put them.
##
## The sentences are the owner's to approve at the RED to GREEN gate, so this
## file pins what a section must carry, not its prose. NEWS.Rmd and NEWS.md are
## build-ignored, so every block that reads them skips inside an R CMD check
## tarball. sourceLines(), plainText() and expectNames() are in
## helper-pageText.R; newsTopBlock(), newsSectionLines() and newsEntries() are in
## helper-newsBlocks.R.

library(testthat)

newsFiles <- c("NEWS.Rmd", "NEWS.md")

## The sections of the block, in the app's tab order. Kinship follows the Diagram
## because its twin file is uploaded there; Speed and Memory and General Fixes
## belong to no tab.
appOrder <- c(
  "Input",
  "Pedigree Diagram",
  "Kinship & Pedigree Calculations",
  "Age-Sex Pyramid",
  "Genetic Value Analysis",
  "Summary Statistics",
  "Breeding Group Formation",
  "Mate Pair Analysis",
  "Genetic Diversity",
  "Marker Genetics",
  "MHC Haplotype Reporting",
  "Cross-Center Identity Matching",
  "De-Identified Export",
  "Potential Parents",
  "Longitudinal Monitoring",
  "Speed and Memory",
  "General Fixes"
)

## The tabs that had no section before S1099.
newTabSections <- c("Input", "Age-Sex Pyramid", "Summary Statistics",
                    "Genetic Diversity", "Potential Parents")

## The groups of "## General Fixes", in order.
fixGroups <- c("Configuration file", "Installation and example files",
               "Script functions")

## The first words of the bullets that keep their openings, as plainText() reads
## them (backticks dropped), by the section that holds them.
keptOpenings <- list(
  "Input" = c(
    "New: the Input tab now warns when animals",
    "New: the Input tab now warns when an animal",
    "New placeholder column:",
    "New: with \"Pedigree(s) and genotypes in one file\", the Input tab now reads"
  ),
  "Potential Parents" = c(
    "Changed: Potential Parents (getPotentialParents()) lists candidates only",
    "New: each Potential Parents result (getPotentialParents()) now says where"
  )
)

## The facts each section or group must carry.
factsByHome <- list(
  "Input" = c(
    "every invalid date",
    "convertFromCenter()",
    "geographicorigin",
    "recordstatus",
    "checkRequiredCols()",
    "fixColumnNames()",
    "Records Processed",
    "Display Unknown IDs",
    "addUIds()",
    "female sire",
    "empty cell",
    "OTHER instead of UNKNOWN",
    "genotype file was not used"
  ),
  "Age-Sex Pyramid" = "Download Plot",
  "Genetic Value Analysis" = c(
    "Founder genome equivalents",
    "readKinshipOverrides()",
    "regional settings"
  ),
  "Summary Statistics" = "character(0)",
  "Breeding Group Formation" = c(
    "ends the session",
    "form the groups again"
  ),
  "Genetic Diversity" = c(
    "no breeding-age females",
    "no offspring",
    "2.5 times",
    "kmat is missing kinship"
  ),
  "Potential Parents" = "too close in time",
  "Configuration file" = c(
    "paste-your-labkey-api-key-here",
    "subscript out of bounds",
    "/My Folder/EHR",
    "apiKey",
    "exampleNprcgenekeeprConfig"
  ),
  "Installation and example files" = c(
    "shinyBS",
    "deidentified_jmac_ped.csv"
  ),
  "Script functions" = c(
    "removeUnknownAnimals()",
    "infinite recursion",
    "argument is of length zero",
    "getLkDirectAncestors()",
    "gen or sex",
    "gvaConvergence()",
    "convertRelationships()",
    "calcGUSE()",
    "create_wkbk()",
    "obfuscateDate()",
    "setExit()",
    "get_elapsed_time_str()"
  )
)

## Fixes to things 2.0.0 never had (R/modMarkerGenetics.R, reportMatePairs() and
## markerRealizedRelatednessVariance() are absent at the v2.0.0 tag). The Mate Pair
## and Marker Genetics sections describe the features themselves, so the bar reads
## only the places these fixes would have moved to.
neverShipped <- c(
  "Download Audit Manifest",
  "de-identified export preview",
  "isReady",
  "reportMatePairs()",
  "markerRealizedRelatednessVariance()"
)

## The names of the sections of the newest version block, in file order.
newsSectionNames <- function(lines) {
  block <- newsTopBlock(lines)$lines
  trimws(sub("^## ", "", grep("^## ", block, value = TRUE)))
}

## The first line of each top-level bullet of some lines, without its "- ".
topBullets <- function(lines) {
  sub("^- ", "", grep("^- ", lines, value = TRUE))
}

## The lines nested under one top-level bullet, up to the next top-level bullet.
groupLines <- function(lines, group) {
  at <- which(lines == paste("-", group))
  if (length(at) == 0L) {
    return(character(0L))
  }
  rest <- lines[-seq_len(at[1L])]
  nextTop <- grep("^- ", rest)
  if (length(nextTop) > 0L) {
    rest <- rest[seq_len(nextTop[1L] - 1L)]
  }
  rest
}

## The first line of each bullet nested one level, without its "  - ".
nestedBullets <- function(lines) {
  sub("^  - ", "", grep("^  - ", lines, value = TRUE))
}

## The lines of a section of the block or of a group of General Fixes.
homeLines <- function(lines, home) {
  if (home %in% fixGroups) {
    return(groupLines(newsSectionLines(lines, "General Fixes"), home))
  }
  newsSectionLines(lines, home)
}

## The readers, on small invented files -------------------------------------

invented <- c(
  "# nprcgenekeepr 9.9 (development version)",
  "",
  "## First",
  "",
  "- Fixed: one",
  "  continued here",
  "",
  "## General Fixes",
  "",
  "- Group one",
  "  - Fixed: two",
  "    continued here",
  "  - Fixed: three",
  "- Group two",
  "",
  "# nprcgenekeepr 9.8 (20200101)",
  "",
  "## Older",
  "",
  "- Fixed: an older release"
)

test_that("the section reader gives the newest block's names and lines", {
  expect_identical(newsSectionNames(invented), c("First", "General Fixes"))
  expect_identical(newsSectionLines(invented, "First"),
                   c("", "- Fixed: one", "  continued here", ""))
  expect_identical(newsSectionLines(invented, "Older"), character(0L))
  expect_identical(newsSectionNames(character(0L)), character(0L))
})

test_that("the group reader gives the lines under one top-level bullet", {
  section <- newsSectionLines(invented, "General Fixes")
  expect_identical(topBullets(section), c("Group one", "Group two"))
  expect_identical(nestedBullets(groupLines(section, "Group one")),
                   c("Fixed: two", "Fixed: three"))
  expect_identical(groupLines(section, "Group two"), "")
  expect_identical(groupLines(section, "No such group"), character(0L))
})

test_that("the fact table names only sections and groups, each fact once", {
  expect_true(all(names(factsByHome) %in% c(appOrder, fixGroups)))
  expect_true(all(names(keptOpenings) %in% appOrder))
  expect_true(all(newTabSections %in% appOrder))
  allFacts <- unlist(factsByHome, use.names = FALSE)
  expect_false(anyDuplicated(allFacts) > 0L)
  expect_false(any(neverShipped %in% allFacts))
})

## The real files -----------------------------------------------------------

test_that("the newest NEWS block's sections run in the app's tab order", {
  for (file in newsFiles) {
    expect_identical(newsSectionNames(sourceLines(file)), appOrder, info = file)
  }
})

## The owner's request (S1099): the block opens by saying where its tabs are
## explained and how to get there. The guide is website-only (.Rbuildignore), so
## the installed tutorial is named too.
test_that("the block opens by saying where the tabs are explained", {
  for (file in newsFiles) {
    lines <- newsTopBlock(sourceLines(file))$lines
    firstSection <- grep("^## ", lines)[1L]
    opening <- plainText(lines[seq_len(firstSection - 1L)])
    expectNames(opening, c(
      "https://rmsharp.github.io/nprcgenekeepr/articles/colony-manager-guide.html",
      "Help tab",
      "Online Documentation",
      "Purpose, Approach, and a Colony Manager's Guide to Practice",
      "vignette(\"a2interactive\", package = \"nprcgenekeepr\")"
    ), where = file)
  }
})

test_that("General Fixes holds the three groups that belong to no tab", {
  for (file in newsFiles) {
    section <- newsSectionLines(sourceLines(file), "General Fixes")
    expect_identical(topBullets(section), fixGroups, info = file)
  }
})

test_that("no bullet of the block uses the old 'Fixed (area):' opening", {
  for (file in newsFiles) {
    block <- newsTopBlock(sourceLines(file))$lines
    expect_identical(grep("^\\s*- Fixed \\(", block, value = TRUE),
                     character(0L), info = file)
  }
})

test_that("each new tab section's bullets open New, Changed or Fixed", {
  for (file in newsFiles) {
    for (tab in newTabSections) {
      bullets <- topBullets(newsSectionLines(sourceLines(file), tab))
      expect_gt(length(bullets), 0L, label = paste(file, tab))
      expect_true(all(grepl("^(New|Changed|Fixed)\\b", bullets)),
                  info = paste(file, tab))
    }
  }
})

test_that("General Fixes' nested bullets say Fixed, or lead with a function", {
  for (file in newsFiles) {
    section <- newsSectionLines(sourceLines(file), "General Fixes")
    for (group in c("Configuration file", "Installation and example files")) {
      bullets <- nestedBullets(groupLines(section, group))
      expect_gt(length(bullets), 0L, label = paste(file, group))
      expect_true(all(startsWith(bullets, "Fixed: ")), info = paste(file, group))
    }
    scripts <- nestedBullets(groupLines(section, "Script functions"))
    expect_gt(length(scripts), 0L, label = paste(file, "Script functions"))
    expect_true(all(startsWith(scripts, "`")), info = file)
  }
})

test_that("the kept bullets open once each, in their sections", {
  for (file in newsFiles) {
    for (home in names(keptOpenings)) {
      entries <- newsEntries(list(
        start = 1L, lines = newsSectionLines(sourceLines(file), home)
      ))
      bullets <- vapply(entries$text, plainText, character(1L),
                        USE.NAMES = FALSE)
      for (opening in keptOpenings[[home]]) {
        expect_equal(sum(startsWith(bullets, opening)), 1L,
                     info = paste(file, home, opening))
      }
    }
  }
})

test_that("each fact stands in its section or group", {
  for (file in newsFiles) {
    lines <- sourceLines(file)
    for (home in names(factsByHome)) {
      text <- plainText(homeLines(lines, home))
      expectNames(text, factsByHome[[home]], where = paste(file, home))
    }
  }
})

test_that("fixes to things 2.0.0 never had are not listed", {
  for (file in newsFiles) {
    lines <- sourceLines(file)
    for (home in c("Input", "Genetic Value Analysis", "Summary Statistics",
                   "Breeding Group Formation", "Genetic Diversity",
                   "General Fixes")) {
      text <- plainText(newsSectionLines(lines, home))
      for (phrase in neverShipped) {
        expect_false(grepl(phrase, text, fixed = TRUE),
                     info = paste(file, home, phrase))
      }
    }
  }
})
