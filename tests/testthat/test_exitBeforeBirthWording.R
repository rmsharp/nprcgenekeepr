## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S982; BACKLOG.md:156): the Input tab warns when an animal's death or
## departure date is earlier than its birth date (test_getExitBeforeBirthWarning.R,
## test_runQcStudbook.R, test_modInput_qcStudbook.R). The manual's list of what
## the Warnings tab shows, the colony manager guide's account of the Input
## tab's checks, and the release notes must say so.
##
## The sentences are the owner's to approve at the RED to GREEN gate (as at
## S971, S977, S978, S979, S980 and S981), so each block pins only what a
## sentence has to carry: in one stretch of text around the words "death or
## departure" it says "warn", "birth date" and "earlier" or "before". The rest
## of the wording is free. No page says "death or departure" at HEAD, so no
## block passes before the sentences are written.
##
## The four pages sit outside a built package (.Rbuildignore'd), so each block
## skips where its page is absent and runs from the source tree.

sayingTheWarning <- function(text) {
  starts <- gregexpr("death or departure", text, fixed = TRUE)[[1L]]
  starts <- starts[starts > 0L]
  any(vapply(starts, function(p) {
    around <- substr(text, max(1L, p - 300L), p + 400L)
    grepl("warn", around, ignore.case = TRUE) &&
      grepl("birth date", around, fixed = TRUE) &&
      grepl("earlier|before", around)
  }, logical(1L)))
}

exitWarningPages <- list(
  "colony manager guide" = c("vignettes", "articles", "colony-manager-guide.qmd"),
  "manual's Warnings list" = c("vignettes", "manual_components", "_input.Rmd"),
  "NEWS.Rmd" = "NEWS.Rmd",
  "NEWS.md" = "NEWS.md"
)

## Sanity check on the readers (green at HEAD, and kept by GREEN): each finds
## its page and the words around which the sentences will go, so a reader that
## finds nothing cannot pass the blocks below.
test_that("the readers find the four pages", {
  for (place in c("colony manager guide", "manual's Warnings list")) {
    text <- do.call(plainSource, as.list(exitWarningPages[[place]]))
    expect_match(text, "no birth date", fixed = TRUE, info = place)
    expect_match(text, "warning", ignore.case = TRUE, info = place)
  }
  for (place in c("NEWS.Rmd", "NEWS.md")) {
    text <- do.call(plainSource, as.list(exitWarningPages[[place]]))
    expect_match(text, "no birth date", fixed = TRUE, info = place)
  }
})

## The reader itself accepts a sentence that carries the three things and
## refuses ones that do not (green at HEAD).
test_that("the wording reader accepts a sentence that carries what it must and no other", {
  expect_true(sayingTheWarning(paste(
    "The Warnings tab also lists animals with a death or departure before",
    "their birth date, so their age is zero or negative."
  )))
  expect_false(sayingTheWarning("A warning about a death or departure date."))
  expect_false(sayingTheWarning(paste(
    "Animals with no birth date get a warning; a death is a death."
  )))
  expect_false(sayingTheWarning(paste(
    "A death or departure before the birth date is recorded."
  )))
})

## The failing tests (RED at HEAD).
for (place in names(exitWarningPages)) {
  test_that(paste0("the ", place, " says the Input tab warns about a death ",
                   "or departure before the birth date"), {
    text <- do.call(plainSource, as.list(exitWarningPages[[place]]))
    expect_true(sayingTheWarning(text), info = place)
  })
}
