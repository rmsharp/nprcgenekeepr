## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S977; BACKLOG.md:139, S976 audit findings 1 and 7): the help of
## buildMarkerGenotypeMatrix() said a record with a missing allele "gives the
## string "NA/NA" (not NA)", and the help of markerExpectedHeterozygosity()
## said a locus with no genotyped individual "gets 1 ... not NA, and that value
## is included in meanHe". Both were true of the code and are now the two
## behaviors the owner ruled wrong (S976): a missing allele is a missing
## genotype (NA), and a locus nobody is typed at has no expected
## heterozygosity (NA), left out of the mean. The help is read in the two
## places it lives: the generated man page and the roxygen block in R/.
##
## The assertions name what the help must no longer say, plus the two short
## phrases ("missing allele gives NA", "no genotyped individual gets NA") that
## state the new rule; the rest of each sentence is free. Both readers need the
## source tree (man/ and R/ do not exist under an installed package) and skip
## without it.

manText <- function(topic) {
  path <- testthat::test_path("..", "..", "man", paste0(topic, ".Rd"))
  if (!file.exists(path)) {
    return(NA_character_)
  }
  collapseSpace(paste(unlist(tools::parse_Rd(path)), collapse = ""))
}

## Every roxygen line of R/<file>.R with the `#'` prefix and the \code{}
## markup removed, white space collapsed.
roxygenText <- function(file) {
  path <- testthat::test_path("..", "..", "R", file)
  if (!file.exists(path)) {
    return(NA_character_)
  }
  lines <- readLines(path, warn = FALSE)
  text <- sub("^#' ?", "", lines[startsWith(lines, "#'")])
  collapseSpace(gsub("\\\\code\\{([^}]*)\\}", "\\1", paste(text, collapse = " ")))
}

collapseSpace <- function(x) trimws(gsub("\\s+", " ", x))

skipUnlessSourceTree <- function() {
  testthat::skip_if(
    is.na(manText("buildMarkerGenotypeMatrix")) ||
      is.na(roxygenText("buildMarkerGenotypeMatrix.R")),
    "man/*.Rd or R/*.R not available (installed package)"
  )
}

builderPlaces <- list(
  "man page" = function() manText("buildMarkerGenotypeMatrix"),
  "roxygen block" = function() roxygenText("buildMarkerGenotypeMatrix.R")
)

heterozygosityPlaces <- list(
  "man page" = function() manText("markerExpectedHeterozygosity"),
  "roxygen block" = function() roxygenText("markerHeterozygosity.R")
)

## Sanity checks on the four readers (green at HEAD): they find the sentences
## the RED tests below are about, so a reader that finds nothing cannot pass.
test_that("the readers find the builder's and the heterozygosity function's help", {
  skipUnlessSourceTree()
  for (read in builderPlaces) {
    expect_match(read(), "no genotype record at that locus", fixed = TRUE)
  }
  for (read in heterozygosityPlaces) {
    expect_match(read(), "no genotyped individual", fixed = TRUE)
  }
})

## The failing tests (RED at HEAD).
for (place in names(builderPlaces)) {
  test_that(paste0("the builder's ", place, " says a missing allele gives NA, not the text \"NA/NA\""), {
    skipUnlessSourceTree()
    text <- builderPlaces[[place]]()
    expect_false(grepl("NA/NA", text, fixed = TRUE), info = text)
    expect_match(text, "missing allele gives NA", fixed = TRUE, info = text)
  })
}

for (place in names(heterozygosityPlaces)) {
  test_that(paste0("the expected-heterozygosity ", place, " says an untyped locus gets NA and is left out of meanHe"), {
    skipUnlessSourceTree()
    text <- heterozygosityPlaces[[place]]()
    expect_false(grepl("gets 1", text, fixed = TRUE), info = text)
    expect_false(grepl("included in meanHe", text, fixed = TRUE), info = text)
    expect_match(text, "no genotyped individual gets NA", fixed = TRUE, info = text)
  })
}
