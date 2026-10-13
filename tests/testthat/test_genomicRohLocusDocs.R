## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S978; BACKLOG.md:139, S976 audit finding 2, the owner's S976 ruling
## "warn and show a notice"): the help of computeGenomicROH() said that a
## full-coverage locus of the locus file that is absent from the genotype
## matrix "is excluded silently (only matrix loci lacking full coverage
## warn)". That was true of the code and is now the behavior the owner ruled
## wrong: the function warns, naming those loci, and the Genomic ROH tab shows
## a notice above its table (test_computeGenomicROH.R and
## test_modMarkerGenetics.R pin both).
##
## The rule is stated in four places, read here: the generated man page, its
## roxygen block in R/, the guide's Genomic ROH paragraph and NEWS.Rmd's
## Genomic ROH bullet. The sentences are the owner's to approve (at the RED to
## GREEN gate, as at S971 and S977), so these blocks pin what the help may no
## longer say and one short phrase per place that states the rule, not prose:
## "not columns of genotypeMatrix" in the two help places (they speak of the
## matrix) and "not in the genotype file" in the guide and NEWS (they speak of
## the file). All four sources sit outside a built package, so the blocks skip
## there (sourceLines() in helper-pageText.R) and run from the source tree.

## The text from the first `from` to just before the next `to` after it, or
## NA (`to` may also stand earlier in the page, as "Script users:" does in
## NEWS.Rmd).
between <- function(text, from, to) {
  start <- regexpr(from, text, fixed = TRUE)[[1L]]
  if (start < 0L) {
    return(NA_character_)
  }
  rest <- substring(text, start)
  end <- regexpr(to, rest, fixed = TRUE)[[1L]]
  if (end < 0L) {
    return(NA_character_)
  }
  substr(rest, 1L, end - 1L)
}

rohPlaces <- helpPlaces("computeGenomicROH", "computeGenomicROH.R")
manPage <- rohPlaces[["man page"]]
roxygenBlock <- rohPlaces[["roxygen block"]]

guideParagraph <- function() {
  between(plainSource("vignettes", "articles", "colony-manager-guide.qmd"),
          "A seventh Genomic ROH (F_ROH) tab",
          "Like the Linkage and LD Block Metrics tab, any export")
}
newsBullet <- function() {
  between(plainSource("NEWS.Rmd"),
          "Genomic ROH (F_ROH) shows the sequence-based",
          "Script users:")
}

## Sanity checks on the four readers (green at HEAD): each finds the text the
## RED tests below are about, so a reader that finds nothing cannot pass them.
test_that("the readers find the Genomic ROH help, guide paragraph and NEWS bullet", {
  skipUnlessHelpInSourceTree(rohPlaces)
  ## A sentence both help places keep before and after the change.
  keeps <- "comparable across a cohort only when the same loci are used"
  expect_match(manPage(), keeps, fixed = TRUE)
  expect_match(roxygenBlock(), keeps, fixed = TRUE)
  expect_match(guideParagraph(), "F_ROH is the proportion of the genome",
               fixed = TRUE)
  expect_match(newsBullet(), "de-identified export", fixed = TRUE)
})

## The failing tests (RED at HEAD).
for (place in c("man page", "roxygen block")) {
  test_that(paste0("the computeGenomicROH ", place, " says a locus-file locus the matrix lacks is warned about, not excluded silently"), {
    skipUnlessHelpInSourceTree(rohPlaces)
    text <- if (place == "man page") manPage() else roxygenBlock()
    expect_false(grepl("excluded silently", text, fixed = TRUE), info = text)
    expect_match(text, "not columns of genotypeMatrix", fixed = TRUE,
                 info = text)
  })
}

test_that("the guide's Genomic ROH paragraph says the tab names locus-file loci that are not in the genotype file", {
  expect_match(guideParagraph(), "not in the genotype file", fixed = TRUE)
})

test_that("NEWS.Rmd's Genomic ROH bullet says the tab names locus-file loci that are not in the genotype file", {
  expect_match(newsBullet(), "not in the genotype file", fixed = TRUE)
})
