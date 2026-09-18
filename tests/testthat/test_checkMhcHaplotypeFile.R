## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #148 Slice 1): checkMhcHaplotypeFile() validates the wide
## per-animal MHC haplotype designation table (id, haplotype1, haplotype2;
## one row per animal) -- design plan D2, ratified S704
## (docs/planning/issue148-mhc-haplotype-reporting-plan.md sec 4). A new,
## sibling input family: the marker long-format validators
## (checkMarkerGenotypeFile()/checkLinkageMarkerGenotypeFile()/
## checkSequenceGenotypeFile()) and the biallelic gate are untouched and
## never adjacent -- the wide format has no locus column to count alleles
## over. NA/empty cells PASS validation (missing calls are the statistics
## layer's concern, plan sec 4); a trailing "?" is likewise not validation's
## business (the parse rule's, D3).
##
## Fixture: a small synthetic 4-animal table covering a homozygote, an
## uncertain call, and an NA (missing) call, plus the bundled real pair
## (rhesusGenotypes, 31 animals) -- plan sec 5 Slice 1 fixtures, Dragons
## 6/7.

mhcGenotype <- data.frame(
  id = c("A1", "A2", "A3", "A4"),
  haplotype1 = c("H01", "H02", "H03?", NA),
  haplotype2 = c("H01", "H04", "H05", "H06"),
  stringsAsFactors = FALSE
)

test_that("checkMhcHaplotypeFile allows a correctly-formed wide table", {
  checked <- checkMhcHaplotypeFile(mhcGenotype)
  expect_s3_class(checked, "data.frame")
  expect_identical(names(checked), c("id", "haplotype1", "haplotype2"))
  expect_identical(nrow(checked), 4L)
  ## A homozygote (A1), an uncertain call (A3), and a missing call (A4)
  ## all pass validation unchanged -- values preserved, not rewritten.
  expect_identical(checked$haplotype1, mhcGenotype$haplotype1)
  expect_identical(checked$haplotype2, mhcGenotype$haplotype2)
})

test_that("checkMhcHaplotypeFile accepts the bundled rhesusGenotypes data", {
  ## The real colony file (id, first_name, second_name) loads unchanged --
  ## column names are not prescribed, only forced (plan D2).
  checked <- checkMhcHaplotypeFile(nprcgenekeepr::rhesusGenotypes)
  expect_identical(names(checked), c("id", "haplotype1", "haplotype2"))
  expect_identical(nrow(checked), 31L)
  expect_true("A004_B002" %in% checked$haplotype1)
  expect_true("A008_B015b?" %in% checked$haplotype2)
})

test_that("checkMhcHaplotypeFile accepts a case-variant id first column", {
  idCase <- mhcGenotype
  names(idCase) <- c("ID", "first_name", "second_name")
  checked <- checkMhcHaplotypeFile(idCase)
  expect_identical(names(checked), c("id", "haplotype1", "haplotype2"))
})

test_that("checkMhcHaplotypeFile requires exactly three columns", {
  expect_error(
    checkMhcHaplotypeFile(mhcGenotype[, c("id", "haplotype1")]),
    "MHC haplotype file must have exactly three columns",
    fixed = TRUE
  )
  fourCol <- cbind(mhcGenotype,
                   extra = c("x", "x", "x", "x"),
                   stringsAsFactors = FALSE)
  expect_error(
    checkMhcHaplotypeFile(fourCol),
    "MHC haplotype file must have exactly three columns",
    fixed = TRUE
  )
})

test_that("checkMhcHaplotypeFile requires 'id' as the first column", {
  badGenotype <- mhcGenotype
  names(badGenotype) <- c("animal", "haplotype1", "haplotype2")
  expect_error(
    checkMhcHaplotypeFile(badGenotype),
    "MHC haplotype file must have 'id' as the first column.",
    fixed = TRUE
  )
})

test_that("checkMhcHaplotypeFile rejects duplicate id rows", {
  ## One row per animal is the format's row-identity rule (plan sec 4) --
  ## the wide-format counterpart of the marker family's id x locus
  ## duplicate check.
  dupGenotype <- rbind(mhcGenotype, mhcGenotype[2L, ])
  expect_error(
    checkMhcHaplotypeFile(dupGenotype),
    "duplicate",
    ignore.case = TRUE
  )
  expect_error(checkMhcHaplotypeFile(dupGenotype), "A2", fixed = TRUE)
})
