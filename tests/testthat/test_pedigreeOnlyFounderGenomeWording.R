## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:139 (S975; the owner took "pedigree-only FG" at the PRE-RED
## scope question and the five sentences below at the PRE-RED -> RED gate).
## The behavior is pinned in test_reportGVPedigreeOnlyFounderGenome.R: with
## genotypes, reportGV()'s fg, fgSE and neGD come from a gene drop that
## ignores them. Five places describe those numbers and each must say so:
##
##   article and manual   "Founder genome equivalents, their standard error and
##                        gene diversity ignore the genotypes: they are worked
##                        out from the pedigree alone, so a genotyped animal
##                        never makes them undefined." (once each)
##   article, FG bullet   "(estimated from the same gene drop)" becomes
##                        "(estimated from a gene drop of the pedigree alone)"
##   in-app guidance      "from the same gene-drop simulation" becomes "from a
##                        gene-drop simulation of the pedigree alone, which
##                        ignores genotypes"
##   reportGV() help      "fg, fgSE and neGD come from a gene drop that ignores
##                        genotypes; it is the same gene drop that gives gu when
##                        the pedigree has none." and fgSE "computed from the
##                        same gene drop as fg"
##   NEWS                 "Founder genome equivalents, their standard error and
##                        gene diversity are worked out from the pedigree alone,
##                        so genotypes no longer make them NA."
##
## The pages sit outside a built package (vignettes/ and the package source),
## so each block skips there and runs from the source tree.
## sourceLines(), plainText(), plainSource(), pageText(), expectWording() and
## occurrences() are in helper-pageText.R.

ignoreSentence <- paste(
  "Founder genome equivalents, their standard error and gene diversity",
  "ignore the genotypes: they are worked out from the pedigree alone, so a",
  "genotyped animal never makes them undefined.")

## Roxygen and Rd text as one line: the markup \code{x} and the comment marker
## dropped, so the sentence reads as it is written.
helpText <- function(lines) {
  text <- paste(sub("^#'\\s?", "", lines), collapse = " ")
  text <- gsub("\\\\code\\{([^}]*)\\}", "\\1", text)
  gsub("\\s+", " ", text)
}

test_that("the Genetic Value article says FG, its SE and GD ignore the genotypes", {
  text <- plainSource("vignettes", "articles", "genetic-value-analysis.qmd")
  expectWording(
    text,
    now = c(ignoreSentence, "(estimated from a gene drop of the pedigree alone)"),
    gone = "(estimated from the same gene drop)")
})

test_that("the Genetic Value manual says the same, once", {
  text <- plainSource("vignettes", "manual_components",
                      "_genetic_value_analysis.Rmd")
  expectWording(text, now = ignoreSentence, gone = character(0L))
})

test_that("the in-app guidance says FG comes from a simulation of the pedigree alone", {
  text <- plainSource("inst", "extdata", "ui_guidance", "genetic_value.html",
                      html = TRUE)
  expectWording(
    text,
    now = paste("is likewise an estimate from a gene-drop simulation of the",
                "pedigree alone, which ignores genotypes, so it too is",
                "reported with a sampling standard error"),
    gone = "from the same gene-drop simulation")
})

test_that("the reportGV() help and its man page say fg, fgSE and neGD ignore the genotypes", {
  now <- c(paste("fg, fgSE and neGD come from a gene drop that ignores",
                 "genotypes; it is the same gene drop that gives gu when the",
                 "pedigree has none."),
           "computed from the same gene drop as fg;")
  gone <- "computed from the same gene drop; a single"
  expectWording(helpText(sourceLines("R", "reportGV.R")), now, gone)
  expectWording(helpText(sourceLines("man", "reportGV.Rd")), now, gone)
})

test_that("NEWS says FG, its SE and GD come from the pedigree alone, in the source and the knitted file", {
  now <- paste("Founder genome equivalents, their standard error and gene",
               "diversity are worked out from the pedigree alone, so genotypes",
               "no longer make them NA.")
  expectWording(plainSource("NEWS.Rmd"), now, character(0L))
  expectWording(plainSource("NEWS.md"), now, character(0L))
})
