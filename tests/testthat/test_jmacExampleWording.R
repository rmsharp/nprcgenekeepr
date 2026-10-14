## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S980; BACKLOG.md:156; the owner's S980 picks "Fix 2 sires, one
## sentence", a NEWS line, and the guide and the manual section): the colony
## manager guide and the manual's "Minimum Parent Age" section tell users how
## to lower the minimum sire and dam ages, but nothing says that the shipped
## Japanese macaque example, deidentified_jmac_ped.csv, needs it: at the default
## 4-year Japanese macaque floor 65 of its mothers (aged 3.43 to 3.99 years at
## the birth) are flagged, and it loads once Minimum Dam Age is 3.4 or lower
## (test_modInput_blankCells.R, which pins both).
##
## The sentences are the owner's to approve at the RED to GREEN gate (as at
## S971, S977, S978 and S979), so each block pins only what a sentence has to
## carry: it names the file, names the Minimum Dam Age box (the manual's own
## words are "minimum dam age", so the match ignores case), and says 3.4, in
## one stretch of text. The rest of the wording is free. The old NEWS line that
## added the file (it names the file and no setting) cannot satisfy a block: a
## block looks at the text around each mention of the file.
##
## The four pages sit outside a built package (.Rbuildignore'd), so each block
## skips where its page is absent and runs from the source tree.

jmacWording <- function(text) {
  starts <- gregexpr("deidentified_jmac_ped.csv", text, fixed = TRUE)[[1L]]
  starts <- starts[starts > 0L]
  vapply(starts, function(p) {
    substr(text, max(1L, p - 400L), p + 600L)
  }, character(1L))
}

sayingTheSetting <- function(text) {
  any(vapply(jmacWording(text), function(around) {
    grepl("minimum dam age", around, ignore.case = TRUE) &&
      grepl("3.4", around, fixed = TRUE)
  }, logical(1L)))
}

jmacPages <- list(
  "colony manager guide" = c("vignettes", "articles", "colony-manager-guide.qmd"),
  "manual's Minimum Parent Age section" = c("vignettes", "manual_components",
                                            "_input.Rmd"),
  "NEWS.Rmd" = "NEWS.Rmd",
  "NEWS.md" = "NEWS.md"
)

## Sanity check on the readers (green at HEAD, and kept by GREEN): each finds
## its page, so a reader that finds nothing cannot pass the blocks below. The
## guide and the manual name the dam-age box; both NEWS files hold the old line
## that added the example.
test_that("the readers find the four pages", {
  for (place in c("colony manager guide",
                  "manual's Minimum Parent Age section")) {
    text <- do.call(plainSource, as.list(jmacPages[[place]]))
    expect_match(text, "minimum dam age", ignore.case = TRUE, info = place)
  }
  for (place in c("NEWS.Rmd", "NEWS.md")) {
    text <- do.call(plainSource, as.list(jmacPages[[place]]))
    expect_match(text, "deidentified_jmac_ped.csv", fixed = TRUE, info = place)
  }
})

## The failing tests (RED at HEAD).
for (place in names(jmacPages)) {
  test_that(paste0("the ", place,
                   " says the jmac example loads once Minimum Dam Age is 3.4"), {
    text <- do.call(plainSource, as.list(jmacPages[[place]]))
    expect_true(sayingTheSetting(text), info = place)
  })
}
