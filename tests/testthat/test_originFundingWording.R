## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:84 (owner-reported S930, decided S952): only version one of the
## package was developed at the Oregon National Primate Research Center and
## paid for by NIH grants P51 RR13986 and P51 OD011092, yet the pages that
## state the origin and the funding said the whole work was supported. The
## owner ruled two changes, wherever each sentence appears:
##
##  1. "The goal of nprcgenekeepr is to implement genetic tools for colony
##     management" becomes "The primary goal of nprcgenekeepr ...".
##  2. "This work has been supported in part by NIH grants ..." becomes "Work
##     on this package up to and including version 1.0 was supported in part
##     by NIH grants ...", the same two grants to the same two centers.
##
## Where the sentences are: the colony manager guide (the goal sentence once,
## the grant sentence twice), the engineering article (grant), the manual
## introduction (both; README.md is knitted from it, so it is checked too) and
## the project overview in CLAUDE.md (grant).
##
## S953 finished the rest, one sentence per place as the owner approved: the
## About tab in the app (the "Initially conceived and developed" line and the
## grant sentence above), the DESCRIPTION funder entries (each centre's name
## alone, with its grant and "work up to and including version 1.0" as the
## comment, and the package man page generated from them) and the three spots
## in the outreach plan. Not covered, by the owner's scope: "initially conceived
## and developed" at ONPRC in the guide, the manual introduction and README.md,
## which already fits version one.
##
## Every file read here sits outside a built package (.Rbuildignore'd or not
## installed), so each block skips where its file is absent and runs from the
## source tree, where the close-out suite runs. Emphasis marks (`, *, _) and
## line breaks do not count as a difference.

pkg_root <- testthat::test_path("..", "..")

## pageText(), occurrences() and expectWording() live in helper-pageText.R.

primaryGoal <- "The primary goal of nprcgenekeepr is to implement"
oldGoal <- "The goal of nprcgenekeepr is to implement"

versionOneGrants <- paste(
  "Work on this package up to and including version 1.0 was supported in",
  "part by NIH grants P51 RR13986 to the Southwest National Primate Research",
  "Center and P51 OD011092 to the Oregon National Primate Research Center."
)
oldGrants <- "This work has been supported in part by NIH grants"

expectPrimaryGoal <- function(text) {
  expect_equal(occurrences(text, primaryGoal), 1L)
  expect_equal(occurrences(text, oldGoal), 0L)
}

expectVersionOneGrants <- function(text, n) {
  expect_equal(occurrences(text, versionOneGrants), n)
  expect_equal(occurrences(text, oldGrants), 0L)
}

test_that("the guide's purpose section says the primary goal", {
  guide <- pageText("vignettes", "articles", "colony-manager-guide.qmd")
  expectPrimaryGoal(guide)
  expect_equal(
    occurrences(guide, paste(primaryGoal, "genetic tools for colony",
                             "management")), 1L)
})

test_that("the manual introduction says the primary goal", {
  expectPrimaryGoal(pageText("vignettes", "manual_components",
                             "_introduction.Rmd"))
})

test_that("README.md says the primary goal", {
  expectPrimaryGoal(pageText("README.md"))
})

test_that("both of the guide's acknowledgments say version 1.0 and earlier", {
  expectVersionOneGrants(
    pageText("vignettes", "articles", "colony-manager-guide.qmd"), 2L)
})

test_that("the engineering article's acknowledgment says version 1.0 and earlier", {
  expectVersionOneGrants(
    pageText("vignettes", "articles", "engineering-the-2.0.0-release.qmd"),
    1L)
})

test_that("the manual introduction's acknowledgment says version 1.0 and earlier", {
  expectVersionOneGrants(
    pageText("vignettes", "manual_components", "_introduction.Rmd"), 1L)
})

test_that("README.md's acknowledgment says version 1.0 and earlier", {
  expectVersionOneGrants(pageText("README.md"), 1L)
})

test_that("the CLAUDE.md overview's acknowledgment says version 1.0 and earlier", {
  expectVersionOneGrants(pageText("CLAUDE.md"), 1L)
})

## ---- S953: the About tab, the DESCRIPTION funders, the outreach plan --------

## The About tab's own panel, as the app draws it, with the tags removed.
aboutPanelText <- function() {
  html <- paste(as.character(appUI()), collapse = " ")
  panel <- regmatches(
    html, regexpr("(?s)About GeneKeepR</h3>.*?</div>", html, perl = TRUE))
  if (length(panel) == 0L) panel <- ""
  expect_true(nzchar(panel), info = "appUI() has no About panel")
  gsub("\\s+", " ", gsub("<[^>]+>", " ", panel))
}

initiallyDeveloped <- paste(
  "Initially conceived and developed at Oregon National Primate Research",
  "Center."
)

test_that("the About tab says the package was initially conceived and developed at ONPRC", {
  expectWording(aboutPanelText(), initiallyDeveloped,
                "Developed at Oregon National Primate Research Center")
})

test_that("the About tab's acknowledgment says version 1.0 and earlier", {
  expectWording(aboutPanelText(), versionOneGrants, "Funded by NIH grants")
})

## DESCRIPTION's funders, as utils::person() reads them.
descriptionFunders <- function() {
  path <- file.path(pkg_root, "DESCRIPTION")
  skip_if_not(file.exists(path), "DESCRIPTION not present")
  authors <- eval(parse(text = read.dcf(path, fields = "Authors@R")[1L, 1L]))
  isFunder <- vapply(seq_along(authors),
                     function(i) "fnd" %in% authors[i]$role, logical(1L))
  funders <- authors[isFunder]
  data.frame(
    given = vapply(seq_along(funders),
                   function(i) paste(funders[i]$given, collapse = " "), ""),
    comment = vapply(seq_along(funders),
                     function(i) paste(funders[i]$comment, collapse = " "), ""),
    stringsAsFactors = FALSE
  )
}

test_that("DESCRIPTION lists each funder by centre, with the grant and version 1.0 as its comment", {
  funders <- descriptionFunders()
  expect_equal(
    funders$given,
    c("Southwest National Primate Research Center",
      "Oregon National Primate Research Center"))
  expect_equal(
    funders$comment,
    c("NIH grant P51 RR13986, work up to and including version 1.0",
      "NIH grant P51 OD011092, work up to and including version 1.0"))
})

test_that("the package help page, built from DESCRIPTION, lists the funders with version 1.0 and earlier", {
  expectWording(
    pageText("man", "nprcgenekeepr-package.Rd"),
    c("NIH grant P51 RR13986, work up to and including version 1.0",
      "NIH grant P51 OD011092, work up to and including version 1.0"),
    "Southwest National Primate Research Center NIH grant")
})

## The outreach plan: draft text for other centres, three spots.
planFile <- file.path("docs", "planning", "nprc-outreach-announcement-plan.md")
planText <- function() pageText(planFile, unquote = TRUE)

test_that("the outreach plan's opening note says version 1.0 was built at ONPRC", {
  expectWording(
    planText(),
    paste("literally: version 1.0 was built at ONPRC with support in part from",
          "NIH grants P51 RR13986 (Southwest NPRC) and P51 OD011092",
          "(Oregon NPRC), and it operationalizes"),
    "built at ONPRC, funded in part by NIH grants")
})

test_that("the outreach plan's announcement text says version 1.0 and earlier", {
  expectWording(
    planText(),
    paste("The package grew out of work at the Oregon National Primate",
          "Research Center. Work on it up to and including version 1.0 was",
          "supported in part by NIH grants P51 RR13986 (Southwest NPRC) and",
          "P51 OD011092 (Oregon NPRC)."),
    "Research Center and is supported in part by NIH grants")
})

test_that("the outreach plan's one-page summary says version 1.0 and earlier", {
  expectWording(
    planText(),
    paste("Initially built at the Oregon National Primate Research Center;",
          "work up to and including version 1.0 was supported in part by",
          "NIH grants P51 RR13986 (Southwest NPRC) and P51 OD011092",
          "(Oregon NPRC)."),
    paste("Built at the Oregon National Primate Research Center; supported",
          "in part by NIH grants"))
})

## The sweep (owner request, S953): every live page that names a grant number
## says, close by, that the support was for version 1.0 and earlier. Scanned:
## README.md, CLAUDE.md, DESCRIPTION, man/, R/, vignettes/, the in-app help
## pages under inst/extdata/ui_guidance/ and the outreach plan. Not scanned, by
## name: CHANGELOG.md, HANDOFFS.md, SESSION_NOTES.md, PROJECT_LEARNINGS.md,
## BACKLOG.md and docs/archive/ log what was written when, and
## docs/planning/v2-transformation-article-plan.md is the executed plan for the
## engineering article (its two mentions say only that an acknowledgment goes
## in the conclusion).
livePages <- function() {
  under <- function(dir, pattern) {
    full <- file.path(pkg_root, dir)
    if (!dir.exists(full)) return(character(0L))
    file.path(dir, list.files(full, pattern, recursive = TRUE))
  }
  pages <- c("README.md", "CLAUDE.md", "DESCRIPTION", planFile,
             under("man", "\\.Rd$"), under("R", "\\.R$"),
             under("vignettes", "\\.(Rmd|qmd)$"),
             under(file.path("inst", "extdata", "ui_guidance"), "\\.html$"))
  pages[file.exists(file.path(pkg_root, pages))]
}

test_that("every live page that names a grant number says version 1.0 and earlier", {
  skip_if_not(dir.exists(file.path(pkg_root, "vignettes")),
              "source tree not present")
  grantNumber <- "P51 (RR13986|OD011092)"
  unscoped <- character(0L)
  withGrants <- character(0L)
  for (page in livePages()) {
    text <- pageText(page, unquote = TRUE)
    hits <- gregexpr(grantNumber, text)[[1L]]
    if (hits[1L] < 0L) next
    withGrants <- c(withGrants, page)
    for (at in hits) {
      near <- substr(text, max(1L, at - 250L), at + 250L)
      if (!grepl("version 1\\.0", near)) {
        unscoped <- c(unscoped,
                      paste0(page, ": ...", substr(text, max(1L, at - 60L),
                                                   at + 60L), "..."))
      }
    }
  }
  expect_gte(length(withGrants), 9L)
  expect_equal(unscoped, character(0L))
})
