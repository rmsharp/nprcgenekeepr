## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md (found S923, widened S925, S926): the paragraph in DESCRIPTION's
## Description field is typed by hand into three more places: the package help
## page (man/nprcgenekeepr-package.Rd), the website home page (_pkgdown.yml,
## home: description:) and the citation abstract (CITATION.cff). S830 reworded
## it in DESCRIPTION and _pkgdown.yml only, and the other two fell behind with
## nothing to say so. These guards fail when a copy no longer says what
## DESCRIPTION says. Line breaks do not count as a difference.
##
## Scope: repo source tree only. _pkgdown.yml and CITATION.cff are
## .Rbuildignore'd and man/*.Rd is not part of an installed package, so each
## test skips where its file is absent.

pkgRoot <- testthat::test_path("..", "..")
descriptionFile <- file.path(pkgRoot, "DESCRIPTION")

collapseWhitespace <- function(x) {
  trimws(gsub("[[:space:]]+", " ", paste(x, collapse = " ")))
}

## The words of `x` from the `i`-th on, at most four of them.
wordsFrom <- function(x, i) {
  paste(x[seq_along(x) >= i & seq_along(x) < i + 4L], collapse = " ")
}

## Says where `copy` first stops saying what `reference` says, so a failure
## names the words that differ instead of printing two 1,100-character lines.
firstDifference <- function(copy, reference) {
  copyWords <- strsplit(copy, " ", fixed = TRUE)[[1L]]
  referenceWords <- strsplit(reference, " ", fixed = TRUE)[[1L]]
  n <- min(length(copyWords), length(referenceWords))
  i <- which(copyWords[seq_len(n)] != referenceWords[seq_len(n)])[1L]
  if (is.na(i)) {
    if (length(copyWords) == length(referenceWords)) {
      return("no difference")
    }
    i <- n + 1L
  }
  paste0(
    "first difference at word ", i, ": copy has '", wordsFrom(copyWords, i),
    "', DESCRIPTION has '", wordsFrom(referenceWords, i), "'"
  )
}

descriptionField <- function() {
  collapseWhitespace(
    read.dcf(descriptionFile, fields = "Description")[1L, 1L]
  )
}

## The paragraph of the help page's \description{} section, with roxygen's
## \url{x} turned back into DESCRIPTION's <x>. "" when the section is absent.
helpPageDescription <- function(rdFile) {
  lines <- readLines(rdFile, warn = FALSE)
  start <- grep("^\\\\description\\{", lines)[1L]
  end <- which(lines == "}" & seq_along(lines) > start)[1L]
  if (is.na(start) || is.na(end)) {
    return("")
  }
  body <- lines[seq_along(lines) > start & seq_along(lines) < end]
  body <- body[!grepl("^\\\\if\\{html\\}", body)]
  collapseWhitespace(gsub("\\\\url\\{([^}]*)\\}", "<\\1>", body))
}

expectCopyMatchesDescription <- function(copy) {
  reference <- descriptionField()
  expect_true(nzchar(reference), info = "DESCRIPTION has no Description")
  expect_true(nzchar(copy), info = "the copy could not be read")
  expect_identical(copy, reference, info = firstDifference(copy, reference))
}

test_that("firstDifference() names the first word where a copy stops matching", {
  expect_identical(firstDifference("a b c", "a b c"), "no difference")
  expect_match(
    firstDifference("a is b c", "a implements b c"),
    "first difference at word 2: copy has 'is b c', DESCRIPTION has 'implements b c'",
    fixed = TRUE
  )
  expect_match(
    firstDifference("a b", "a b c d"),
    "first difference at word 3: copy has '', DESCRIPTION has 'c d'",
    fixed = TRUE
  )
})

test_that("the website home text in _pkgdown.yml says what DESCRIPTION says", {
  pkgdownYml <- file.path(pkgRoot, "_pkgdown.yml")
  skip_if_not(file.exists(pkgdownYml), "_pkgdown.yml absent; guard not applicable")
  skip_if_not(file.exists(descriptionFile), "DESCRIPTION absent; guard not applicable")
  skip_if_not_installed("yaml")

  expectCopyMatchesDescription(
    collapseWhitespace(yaml::read_yaml(pkgdownYml)$home$description)
  )
})

test_that("the citation abstract in CITATION.cff says what DESCRIPTION says", {
  citationCff <- file.path(pkgRoot, "CITATION.cff")
  skip_if_not(file.exists(citationCff), "CITATION.cff absent; guard not applicable")
  skip_if_not(file.exists(descriptionFile), "DESCRIPTION absent; guard not applicable")
  skip_if_not_installed("yaml")

  expectCopyMatchesDescription(
    collapseWhitespace(yaml::read_yaml(citationCff)$abstract)
  )
})

test_that("the package help page says what DESCRIPTION says", {
  helpPage <- file.path(pkgRoot, "man", "nprcgenekeepr-package.Rd")
  skip_if_not(file.exists(helpPage), "man/nprcgenekeepr-package.Rd absent; guard not applicable")
  skip_if_not(file.exists(descriptionFile), "DESCRIPTION absent; guard not applicable")

  expectCopyMatchesDescription(helpPageDescription(helpPage))
})
