## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #130 Slice 1): buildMarkerGenotypeMatrix() pivots a validated
## D1 long-format table (id, locus, allele1, allele2) into a wide id x locus
## character matrix -- one cell per (id, locus), holding the two alleles
## sorted alphabetically and joined by "/" (e.g. "A/B"), or NA when that
## individual has no genotype record at that locus. Row/column order follows
## first-appearance in the input (mirroring kinship()'s own input-order
## convention, not a string sort -- "L10" sorts before "L2" as a string,
## which would silently scramble locus order for >9 loci).

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

test_that("buildMarkerGenotypeMatrix produces the correct shape and dimnames", {
  mat <- buildMarkerGenotypeMatrix(markerGenotype)
  expect_true(is.matrix(mat))
  expect_identical(dim(mat), c(3L, 10L))
  expect_identical(rownames(mat), c("P", "C", "U"))
  expect_identical(colnames(mat), paste0("L", 1L:10L))
})

test_that("buildMarkerGenotypeMatrix sorts each cell's two alleles alphabetically", {
  mat <- buildMarkerGenotypeMatrix(markerGenotype)
  expect_identical(mat["P", "L1"], "A/A")
  expect_identical(mat["P", "L2"], "A/B")
  expect_identical(mat["P", "L4"], "B/B")
  expect_identical(mat["C", "L1"], "A/B")
  expect_identical(mat["C", "L10"], "A/A")
  expect_identical(mat["U", "L8"], "B/B")
  expect_identical(mat["U", "L10"], "B/B")
})

test_that("buildMarkerGenotypeMatrix cells are NA for a missing id x locus", {
  ## Drop P's L5 record entirely -- P is simply not genotyped at that locus.
  sparse <- markerGenotype[!(markerGenotype$id == "P" & markerGenotype$locus == "L5"), ]
  mat <- buildMarkerGenotypeMatrix(sparse)
  expect_true(is.na(mat["P", "L5"]))
  ## Every other cell is unaffected by the one dropped row.
  expect_identical(mat["C", "L5"], "A/A")
  expect_identical(mat["U", "L5"], "A/B")
})
