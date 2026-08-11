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
