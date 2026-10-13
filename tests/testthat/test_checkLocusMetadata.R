## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #153 Slice 1 (RED): checkLocusMetadata(locusMetadata) validates the
# locus, chrom, pos[, cM] sidecar table (docs/planning/
# issue153-linkage-haplotype-block-metrics-plan.md sec 4 interface catalog,
# reusing #152's own D3 schema verbatim per D7), classifying each locus into
# a new `coverage` column with D2's literal three-tier definition: "full"
# (chrom AND pos present, cM optional), "partial" (exactly one of chrom/pos
# present), "none" (neither present). Mirrors checkMarkerGenotypeFile()'s
# own structure/error-message conventions (forced column names, fail-fast
# stop() on malformed schema, sec 2.2).
#
# This file also covers Slice 1's second DONE criterion: a new, realistic
# multiallelic STR marker fixture pair (data-raw/generate_str_fixtures.R,
# GREEN work) round-trips through the existing, UNMODIFIED
# buildMarkerGenotypeMatrix() -- proving D4's structural claim (sec 2.2:
# buildMarkerGenotypeMatrix() has no allele-count logic; the biallelic
# restriction lives entirely in checkMarkerGenotypeFile(), deliberately not
# called here) at realistic panel scale, not just the small inline fixture
# above.

mixedCoverageLocusMetadata <- function() {
  data.frame(
    locus = c("L1", "L2", "L3", "L4", "L5"),
    chrom = c("1", "1", "2", NA, NA),
    pos   = c(1000000, NA, 2500000, NA, 500000),
    cM    = c(NA, NA, 5.2, NA, NA),
    stringsAsFactors = FALSE
  )
}

test_that("checkLocusMetadata accepts a valid mixed-coverage locusMetadata frame", {
  expect_error(checkLocusMetadata(mixedCoverageLocusMetadata()), NA)
})

test_that("checkLocusMetadata classifies each locus into the correct D2 coverage tier", {
  out <- checkLocusMetadata(mixedCoverageLocusMetadata())
  expect_s3_class(out, "data.frame")
  expect_identical(
    out$coverage,
    c("full", "partial", "full", "none", "partial")
  )
})

test_that("checkLocusMetadata treats a chrom+pos locus with no cM as 'full' (cM is optional)", {
  ## L1 has chrom + pos but cM = NA -- D2's own literal wording is
  ## "full (chrom+pos[+cM])": the bracket means cM is optional within
  ## "full", not a fourth required field.
  out <- checkLocusMetadata(mixedCoverageLocusMetadata())
  expect_identical(out$coverage[out$locus == "L1"], "full")
})

test_that("checkLocusMetadata accepts a 3-column frame with no cM column at all", {
  noCm <- mixedCoverageLocusMetadata()
  noCm$cM <- NULL
  out <- checkLocusMetadata(noCm)
  expect_identical(names(out), c("locus", "chrom", "pos", "coverage"))
  expect_identical(out$coverage, c("full", "partial", "full", "none", "partial"))
})

test_that("checkLocusMetadata stops when column count is not three or four", {
  tooFew <- mixedCoverageLocusMetadata()[, c("locus", "chrom")]
  expect_error(
    checkLocusMetadata(tooFew),
    "Locus metadata must have three or four columns",
    fixed = TRUE
  )
  tooMany <- mixedCoverageLocusMetadata()
  tooMany$extra <- "x"
  expect_error(
    checkLocusMetadata(tooMany),
    "Locus metadata must have three or four columns",
    fixed = TRUE
  )
})

test_that("checkLocusMetadata stops when the first column is not named 'locus'", {
  bad <- mixedCoverageLocusMetadata()
  names(bad)[1L] <- "marker"
  expect_error(
    checkLocusMetadata(bad),
    "Locus metadata must have 'locus' as the first column.",
    fixed = TRUE
  )
})

test_that("checkLocusMetadata stops on a duplicate locus row", {
  dup <- rbind(mixedCoverageLocusMetadata(), mixedCoverageLocusMetadata()[1L, ])
  expect_error(
    checkLocusMetadata(dup),
    "duplicate",
    ignore.case = TRUE
  )
})

test_that("checkLocusMetadata coerces locus/chrom to character", {
  out <- checkLocusMetadata(mixedCoverageLocusMetadata())
  expect_type(out$locus, "character")
  expect_type(out$chrom, "character")
})

# ---------------------------------------------------------------------------
# Committed STR fixture pair (data-raw/generate_str_fixtures.R, GREEN work):
# realistic multiallelic panel scale, modeled on de Groot et al. 2025's
# panel shape (sec 2.10) -- 12 loci across 8 chromosomes, 10 individuals,
# 8 "full" / 2 "partial" / 2 "none" coverage loci, >= 2 genuinely
# multiallelic (3+ distinct allele) loci.
# ---------------------------------------------------------------------------

test_that("the committed STR locusMetadata fixture classifies into the realistic 8/2/2 coverage mix", {
  ## No skip_if() guard: system.file() returns "" when the fixture doesn't
  ## exist yet, and read.csv("") errors -- this test must genuinely FAIL at
  ## RED, not skip, until GREEN commits the fixture (data-raw/
  ## generate_str_fixtures.R).
  locusMetadataPath <- system.file(
    "extdata", "examples", "example_locus_metadata.csv",
    package = "nprcgenekeepr"
  )
  locusMetadata <- read.csv(locusMetadataPath, stringsAsFactors = FALSE)
  out <- checkLocusMetadata(locusMetadata)
  expect_identical(nrow(out), 12L)
  expect_identical(
    as.integer(table(out$coverage)[c("full", "partial", "none")]),
    c(8L, 2L, 2L)
  )
})

test_that("the committed STR genotype fixture is genuinely multiallelic and pivots through the existing, unmodified buildMarkerGenotypeMatrix()", {
  ## No skip_if() guard -- same rationale as the test above.
  genotypePath <- system.file(
    "extdata", "examples", "example_str_marker_genotypes.csv",
    package = "nprcgenekeepr"
  )
  genotype <- read.csv(genotypePath, stringsAsFactors = FALSE)
  alleleCounts <- tapply(
    c(genotype$allele1, genotype$allele2),
    rep(genotype$locus, 2L),
    function(a) length(unique(a[!is.na(a)]))
  )
  ## D4's evidence, proven at fixture scale: this file is deliberately NOT
  ## routed through checkMarkerGenotypeFile() (which would reject it), only
  ## through buildMarkerGenotypeMatrix() -- confirming the multiallelic
  ## restriction lives entirely in the validator, not the pivot function.
  expect_gte(sum(alleleCounts > 2L), 2L)

  mat <- buildMarkerGenotypeMatrix(genotype)
  expect_identical(dim(mat), c(10L, 12L))
})

## ---------------------------------------------------------------------
## RED (S979; BACKLOG.md:139, S976 audit finding 6, the owner's S976 ruling
## "treat an empty or all-space chromosome as missing, as the app's reader
## already does", and the S979 Pre-RED answer "missing everywhere"): a blank
## chrom is no chromosome. checkLocusMetadata() counted any non-NA value as
## present, so "" read as a chromosome of its own: coverage "full",
## computeGenomicROH() grouped those loci as chromosome "", and markerLdBlock()
## paired them with each other. Now an empty, all-space or all-tab chrom is
## returned as NA and its locus is read as having no chrom (so "partial" with a
## pos, "none" without one). A script's read.csv() keeps "" in a text column;
## the app's reader already gives NA (S976 probe), so the app does not change.
## ---------------------------------------------------------------------
blankChromLocusMetadata <- function() {
  data.frame(
    locus = c("L1", "L2", "L3", "L4", "L5", "L6"),
    chrom = c("chr1", "", "  ", "\t", NA, "X"),
    pos   = c(100, 200, 300, 400, 500, NA),
    stringsAsFactors = FALSE
  )
}

test_that("checkLocusMetadata reads an empty chrom as missing: partial with a pos, none without", {
  out <- checkLocusMetadata(data.frame(
    locus = c("L1", "L2", "L3"),
    chrom = c("", "", "1"),
    pos = c(100, NA, 300),
    stringsAsFactors = FALSE
  ))
  expect_identical(out$coverage, c("partial", "none", "full"))
})

test_that("checkLocusMetadata reads an all-space or all-tab chrom as missing, like an empty one", {
  out <- checkLocusMetadata(blankChromLocusMetadata())
  expect_identical(
    out$coverage,
    c("full", "partial", "partial", "partial", "partial", "partial")
  )
})

test_that("checkLocusMetadata returns NA, not the blank text, for a blank chrom and leaves real names alone", {
  out <- checkLocusMetadata(blankChromLocusMetadata())
  expect_identical(out$chrom, c("chr1", NA, NA, NA, NA, "X"))
  expect_type(out$chrom, "character")
})

test_that("checkLocusMetadata gives a blank chrom exactly what an NA chrom gets", {
  blank <- blankChromLocusMetadata()
  asNa <- blank
  asNa$chrom[blank$chrom %in% c("", "  ", "\t")] <- NA
  expect_identical(checkLocusMetadata(blank), checkLocusMetadata(asNa))
})

test_that("checkLocusMetadata keeps a chrom with a blank inside or around real text as the name it is", {
  ## Only a chrom that is nothing but white space is missing; "chr 1" and
  ## "1" are names (S976 ruling: "empty or all-space").
  out <- checkLocusMetadata(data.frame(
    locus = c("L1", "L2"),
    chrom = c("chr 1", "1"),
    pos = c(100, 200),
    stringsAsFactors = FALSE
  ))
  expect_identical(out$chrom, c("chr 1", "1"))
  expect_identical(out$coverage, c("full", "full"))
})
