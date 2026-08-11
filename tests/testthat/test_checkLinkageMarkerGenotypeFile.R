## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #153 Slice 2 (RED): checkLinkageMarkerGenotypeFile() (D4, docs/planning/
# issue153-linkage-haplotype-block-metrics-plan.md sec 4 interface catalog) is a
# new, sibling validator to checkMarkerGenotypeFile() -- same 4-column long-format
# id/locus/allele1/allele2 schema, same column-count/first-column/duplicate-row
# checks retained, but the >2-distinct-alleles-per-locus rejection is deliberately
# OMITTED so real, multiallelic colony STR panels (sec 2.10, de Groot et al. 2025)
# can be ingested. Confirmed via direct code read (R/checkMarkerGenotypeFile.R,
# R/modMarkerGenetics.R) that checkMarkerGenotypeFile() is called only from the
# Shiny upload handlers -- markerKinship()/buildMarkerGenotypeMatrix() have no
# internal dependency on it -- so this new sibling function requires zero edits to
# any existing file; the existing biallelic contract is untouched by construction,
# not just by intent.

markerGenotype <- data.frame(
  id = c(rep("P", 10L), rep("C", 10L), rep("U", 10L)),
  locus = rep(paste0("L", 1L:10L), 3L),
  allele1 = c(
    "A", "A", "A", "B", "A", "A", "B", "A", "A", "A",
    "A", "A", "B", "A", "A", "A", "B", "A", "A", "A",
    "A", "B", "A", "A", "A", "A", "A", "B", "A", "B"
  ),
  allele2 = c(
    "A", "B", "B", "B", "A", "B", "B", "B", "A", "B",
    "B", "A", "B", "B", "A", "B", "B", "B", "B", "A",
    "B", "B", "A", "B", "B", "A", "B", "B", "B", "B"
  ),
  stringsAsFactors = FALSE
)

test_that("checkLinkageMarkerGenotypeFile allows correctly-formed long-format table", {
  checked <- checkLinkageMarkerGenotypeFile(markerGenotype)
  expect_s3_class(checked, "data.frame")
  expect_identical(names(checked), c("id", "locus", "allele1", "allele2"))
  expect_identical(nrow(checked), 30L)
})

test_that("checkLinkageMarkerGenotypeFile requires exactly four columns", {
  expect_error(
    checkLinkageMarkerGenotypeFile(markerGenotype[, c("id", "locus", "allele1")]),
    "Marker genotype file must have exactly four columns",
    fixed = TRUE
  )
})

test_that("checkLinkageMarkerGenotypeFile requires 'id' as the first column", {
  badGenotype <- markerGenotype
  names(badGenotype) <- c("animal", "locus", "allele1", "allele2")
  expect_error(
    checkLinkageMarkerGenotypeFile(badGenotype),
    "Marker genotype file must have 'id' as the first column.",
    fixed = TRUE
  )
})

test_that("checkLinkageMarkerGenotypeFile rejects a duplicate id x locus row", {
  dupGenotype <- rbind(markerGenotype, markerGenotype[1L, ])
  expect_error(
    checkLinkageMarkerGenotypeFile(dupGenotype),
    "duplicate",
    ignore.case = TRUE
  )
})

test_that("checkLinkageMarkerGenotypeFile accepts a locus with more than two alleles, unlike checkMarkerGenotypeFile (D4)", {
  ## The exact fixture shape test_checkMarkerGenotypeFile.R uses to prove
  ## rejection (Dragon P1) -- here proving the opposite: D4's deliberate
  ## relaxation for real multiallelic STR panels.
  triallelic <- rbind(
    markerGenotype,
    data.frame(id = "X", locus = "L1", allele1 = "C", allele2 = "C",
               stringsAsFactors = FALSE)
  )
  expect_error(checkMarkerGenotypeFile(triallelic), "L1", fixed = TRUE)
  expect_error(checkLinkageMarkerGenotypeFile(triallelic), NA)
})

test_that("checkLinkageMarkerGenotypeFile forces output column names, matching checkMarkerGenotypeFile's contract", {
  renamed <- markerGenotype
  names(renamed) <- c("ID", "LOCUS", "ALLELE1", "ALLELE2")
  checked <- checkLinkageMarkerGenotypeFile(renamed)
  expect_identical(names(checked), c("id", "locus", "allele1", "allele2"))
})

# ---------------------------------------------------------------------------
# Committed STR fixture (data-raw/generate_str_fixtures.R, Slice 1): realistic
# multiallelic panel scale, 10 individuals x 12 loci, >= 2 genuinely
# multiallelic (3+ distinct allele) loci -- the D4 contract boundary proven at
# fixture scale, not just the small inline fixture above.
# ---------------------------------------------------------------------------

test_that("the committed STR fixture is accepted by checkLinkageMarkerGenotypeFile but still rejected by checkMarkerGenotypeFile (D4 contract boundary, fixture scale)", {
  genotypePath <- system.file(
    "extdata", "examples", "example_str_marker_genotypes.csv",
    package = "nprcgenekeepr"
  )
  genotype <- read.csv(genotypePath, stringsAsFactors = FALSE)

  ## Unchanged behavior: the existing biallelic validator still rejects this
  ## real multiallelic panel -- the contract Slice 1 already proved and this
  ## slice must not disturb.
  expect_error(checkMarkerGenotypeFile(genotype))

  ## New behavior: the sibling validator accepts it and pivots through the
  ## existing, UNMODIFIED buildMarkerGenotypeMatrix() unchanged.
  checked <- checkLinkageMarkerGenotypeFile(genotype)
  expect_s3_class(checked, "data.frame")
  mat <- buildMarkerGenotypeMatrix(checked)
  expect_identical(dim(mat), c(10L, 12L))
})
