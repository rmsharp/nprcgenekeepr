## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #137 Slice 1 (RED): checkTwinRelations(ped, twinRelations) validates a twin/zygosity
# sidecar table (id1, id2, code) against kinship2's own five relation-validation rules (design
# doc docs/planning/issue137-twin-zygosity-pedigree-diagram-plan.md sec 2.1/D4, independently
# confirmed by deparsing kinship2::pedigree()'s installed source): both ids must exist in `ped`
# and differ (universal, all codes); MZ/DZ additionally require the pair to already share both
# `sire` and `dam` in `ped`; MZ additionally requires matching `sex`; UZ has no such
# precondition. `code`'s domain is kinship2's own literal twin-code labels, "MZ twin"/"DZ
# twin"/"UZ twin" (D2) -- the 4th, non-twin "spouse" code is out of scope for #137 (sec 1.3).
# Mirrors checkKinshipOverrides()'s own naming/structure pattern (D3).

# A small pedigree exercising every rule this validator must enforce:
#   F1 (M), F2 (F), F3 (F) -- unrelated founders
#   S1 (F), S2 (F) -- full siblings of F1 x F2, same sex (valid MZ pair)
#   S3 (M) -- half-sibling of S1/S2, shares sire F1 only, not dam (F3 instead of F2)
#   S4 (M) -- full sibling of S1/S2 (shares both F1, F2), but sex differs from S1
#   U1 (M) -- child of F3 x F2, shares no parent with S1 (unrelated by parentage)
i137BasePed <- function() {
  data.frame(
    id   = c("F1", "F2", "F3", "S1", "S2", "S3", "S4", "U1"),
    sire = c(NA,   NA,   NA,   "F1", "F1", "F1", "F1", "F3"),
    dam  = c(NA,   NA,   NA,   "F2", "F2", "F3", "F2", "F2"),
    sex  = c("M",  "F",  "F",  "F",  "F",  "M",  "M",  "M"),
    stringsAsFactors = FALSE
  )
}

validI137TwinRelations <- function() {
  data.frame(
    id1 = c("S1", "S1"),
    id2 = c("S2", "U1"),
    code = c("MZ twin", "UZ twin"),
    stringsAsFactors = FALSE
  )
}

test_that("checkTwinRelations accepts a valid twinRelations frame", {
  expect_error(checkTwinRelations(i137BasePed(), validI137TwinRelations()), NA)
})

test_that("checkTwinRelations returns id1/id2 coerced to character", {
  out <- checkTwinRelations(i137BasePed(), validI137TwinRelations())
  expect_s3_class(out, "data.frame")
  expect_type(out$id1, "character")
  expect_type(out$id2, "character")
})

test_that("checkTwinRelations stops when a required column is missing", {
  bad <- validI137TwinRelations()
  bad$code <- NULL
  expect_error(checkTwinRelations(i137BasePed(), bad), "missing")
})

test_that("checkTwinRelations stops on a self-pair (id1 == id2)", {
  bad <- data.frame(id1 = "S1", id2 = "S1", code = "UZ twin", stringsAsFactors = FALSE)
  expect_error(checkTwinRelations(i137BasePed(), bad), "differ")
})

test_that("checkTwinRelations stops when an id is not present in ped", {
  bad <- data.frame(id1 = "S1", id2 = "NOTANID", code = "UZ twin", stringsAsFactors = FALSE)
  expect_error(checkTwinRelations(i137BasePed(), bad), "not found in the pedigree")
})

test_that("checkTwinRelations stops on an out-of-domain code value", {
  bad <- data.frame(id1 = "S1", id2 = "S2", code = "spouse", stringsAsFactors = FALSE)
  expect_error(checkTwinRelations(i137BasePed(), bad), "must be one of")
})

test_that("checkTwinRelations stops on an MZ/DZ pair not sharing sire and dam", {
  mz <- data.frame(id1 = "S1", id2 = "S3", code = "MZ twin", stringsAsFactors = FALSE)
  expect_error(checkTwinRelations(i137BasePed(), mz), "share both sire and dam")
  dz <- data.frame(id1 = "S1", id2 = "S3", code = "DZ twin", stringsAsFactors = FALSE)
  expect_error(checkTwinRelations(i137BasePed(), dz), "share both sire and dam")
})

test_that("checkTwinRelations stops on an MZ pair with mismatched sex", {
  bad <- data.frame(id1 = "S1", id2 = "S4", code = "MZ twin", stringsAsFactors = FALSE)
  expect_error(checkTwinRelations(i137BasePed(), bad), "matching sex")
})

test_that("checkTwinRelations accepts a UZ pair with no shared-parent precondition", {
  ok <- data.frame(id1 = "S1", id2 = "U1", code = "UZ twin", stringsAsFactors = FALSE)
  expect_error(checkTwinRelations(i137BasePed(), ok), NA)
})

test_that("checkTwinRelations accepts a valid MZ pair (shared parents and sex)", {
  ok <- data.frame(id1 = "S1", id2 = "S2", code = "MZ twin", stringsAsFactors = FALSE)
  expect_error(checkTwinRelations(i137BasePed(), ok), NA)
})
