## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #152 Slice 4): obfuscateGenotypeMatrix(genotypeMatrix, map) de-
## identifies a buildMarkerGenotypeMatrix()-shaped wide genotype matrix (rows
## = individual ids, columns = loci) by remapping its rownames through the
## same alias vector obfuscatePed(..., map = TRUE) already returns (design
## doc section 3 D7). Genotype/allele cell values are never perturbed -- D7
## is explicit that there is no scientifically-valid "obfuscation" of an
## allele call, so the only real protection is which people see the file at
## all (the confirm-gate/labeling pattern shipped at a future Slice 5, not a
## data transform here). This function exactly mirrors
## obfuscateTwinRelations()'s/obfuscateLdBlocks()'s pattern: any id present
## in the matrix but absent from `map` stops loudly rather than silently
## dropping or leaking it.

library(testthat)

i152GenotypeMatrix <- function() {
  matrix(
    c("A/A", "A/B", "B/B", "A/A", NA_character_, "A/B"),
    nrow = 3L, ncol = 2L,
    dimnames = list(c("A01", "A02", "A03"), c("L1", "L2"))
  )
}

i152GenotypeMap <- function() {
  c(A01 = "ALIAS1", A02 = "ALIAS2", A03 = "ALIAS3")
}

test_that("obfuscateGenotypeMatrix remaps rownames (ids) through map; genotype values and colnames unchanged", {
  out <- obfuscateGenotypeMatrix(i152GenotypeMatrix(), i152GenotypeMap())
  expect_equal(rownames(out), c("ALIAS1", "ALIAS2", "ALIAS3"))
  expect_equal(colnames(out), c("L1", "L2"))
  expect_equal(unname(out), unname(i152GenotypeMatrix()))
  expect_equal(dim(out), dim(i152GenotypeMatrix()))
})

test_that("obfuscateGenotypeMatrix stops loudly on an id absent from map", {
  incompleteMap <- i152GenotypeMap()[c("A01", "A02")] # A03 deliberately missing
  expect_error(
    obfuscateGenotypeMatrix(i152GenotypeMatrix(), incompleteMap),
    "not found"
  )
})

test_that("obfuscateGenotypeMatrix round-trips through the same map obfuscatePed(..., map = TRUE) returns", {
  ped <- data.frame(
    id = c("A01", "A02", "A03"),
    sire = rep(NA_character_, 3L),
    dam = rep(NA_character_, 3L),
    sex = c("M", "F", "M"),
    stringsAsFactors = FALSE
  )
  obfuscated <- obfuscatePed(ped, map = TRUE)
  out <- obfuscateGenotypeMatrix(i152GenotypeMatrix(), obfuscated$map)
  expect_false(any(grepl("A0[1-3]", rownames(out))))
})
