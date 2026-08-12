## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #152 Slice 5): obfuscateGenomicROH(rohTable, map) de-identifies
## a computeGenomicROH() result table (design doc section 3 D7: "any
## sequence-derived export -- raw genotype matrix AND derived summary
## tables (kinship/heterozygosity/Fst/F_ROH) -- routes through a new de-
## identification primitive"). computeGenomicROH()'s output is a plain
## per-individual data.frame keyed by a single `id` column (id, nSegments,
## totalRohLength, fRoh) -- a different shape from every existing
## obfuscate*() sibling (obfuscateGenotypeMatrix() remaps rownames;
## obfuscateTwinRelations() remaps id1/id2; obfuscateLdBlocks() remaps a
## comma-joined idsUsed column), so none of them fit directly. This
## function mirrors their shared pattern exactly: any id present in the
## table but absent from `map` stops loudly rather than silently dropping
## or leaking it; every non-id column is unchanged.

library(testthat)

i152RohTable <- function() {
  data.frame(
    id = c("I1", "I2", "I3"),
    nSegments = c(1L, 0L, 1L),
    totalRohLength = c(1100000, 0, 2000000),
    fRoh = c(11 / 29, 0, 20 / 29),
    stringsAsFactors = FALSE
  )
}

i152RohMap <- function() {
  c(I1 = "ALIAS1", I2 = "ALIAS2", I3 = "ALIAS3")
}

test_that("obfuscateGenomicROH remaps the id column through map; every other column is unchanged", {
  out <- obfuscateGenomicROH(i152RohTable(), i152RohMap())
  expect_identical(out$id, c("ALIAS1", "ALIAS2", "ALIAS3"))
  expect_identical(names(out), names(i152RohTable()))
  expect_equal(out$nSegments, i152RohTable()$nSegments)
  expect_equal(out$totalRohLength, i152RohTable()$totalRohLength)
  expect_equal(out$fRoh, i152RohTable()$fRoh)
  expect_equal(nrow(out), nrow(i152RohTable()))
})

test_that("obfuscateGenomicROH stops loudly on an id absent from map", {
  incompleteMap <- i152RohMap()[c("I1", "I2")] # I3 deliberately missing
  expect_error(
    obfuscateGenomicROH(i152RohTable(), incompleteMap),
    "not found"
  )
})

test_that("obfuscateGenomicROH round-trips through the same map obfuscatePed(..., map = TRUE) returns", {
  ped <- data.frame(
    id = c("I1", "I2", "I3"),
    sire = rep(NA_character_, 3L),
    dam = rep(NA_character_, 3L),
    sex = c("M", "F", "M"),
    stringsAsFactors = FALSE
  )
  obfuscated <- obfuscatePed(ped, map = TRUE)
  out <- obfuscateGenomicROH(i152RohTable(), obfuscated$map)
  expect_false(any(grepl("^I[1-3]$", out$id)))
})
