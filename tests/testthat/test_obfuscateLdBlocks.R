## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #153 Slice 4): obfuscateLdBlocks(ldBlockResult, map) de-
## identifies a markerLdBlock() result table (D9) -- routing any exported
## block/LD statistic through the same curator-controlled de-
## identification gate issue #150 already established, since a joint
## (multi-locus) statistic carries MORE identifying power than a
## single-locus one, not less (sec 2.15; Lin, Owen & Altman 2004; Erlich &
## Narayanan 2014). markerLdBlock()'s own output is a per-locus-pair
## population statistic with no id columns UNLESS founder-restricted, in
## which case its `idsUsed` column (comma-joined ids) is the only place
## real ids can leak. This function remaps that column through `map`,
## exactly mirroring obfuscateTwinRelations()'s pattern: a row whose
## idsUsed is NA passes through unchanged; any id present but absent from
## `map` stops loudly rather than silently dropping or leaking it.

library(testthat)

i153LdBlockResultFrame <- function() {
  data.frame(
    locus1 = c("STR01", "STR03"),
    locus2 = c("STR02", "STR04"),
    chrom = c("1", "2"),
    Dprime = c(0.714286, 0.662317),
    r2 = c(0.682540, 0.498590),
    nUsed = c(5L, 10L),
    idsUsed = c("A01,A02,A03,A04,A05", NA_character_),
    caveat = rep("Descriptive statistic only.", 2L),
    stringsAsFactors = FALSE
  )
}

i153LdBlockMap <- function() {
  c(A01 = "ALIAS1", A02 = "ALIAS2", A03 = "ALIAS3", A04 = "ALIAS4",
    A05 = "ALIAS5")
}

test_that("obfuscateLdBlocks remaps idsUsed ids through map; other columns unchanged", {
  out <- obfuscateLdBlocks(i153LdBlockResultFrame(), i153LdBlockMap())
  expect_equal(out$idsUsed[1L], "ALIAS1,ALIAS2,ALIAS3,ALIAS4,ALIAS5")
  expect_equal(out$locus1, c("STR01", "STR03"))
  expect_equal(out$Dprime, c(0.714286, 0.662317), tolerance = 1e-6)
  expect_equal(out$r2, c(0.682540, 0.498590), tolerance = 1e-6)
  expect_equal(out$caveat, rep("Descriptive statistic only.", 2L))
})

test_that("obfuscateLdBlocks leaves a row with idsUsed = NA unchanged", {
  out <- obfuscateLdBlocks(i153LdBlockResultFrame(), i153LdBlockMap())
  expect_true(is.na(out$idsUsed[2L]))
})

test_that("obfuscateLdBlocks stops loudly on an id absent from map", {
  bad <- i153LdBlockResultFrame()
  incompleteMap <- i153LdBlockMap()[c("A01", "A02", "A03", "A04")] # A05 missing
  expect_error(obfuscateLdBlocks(bad, incompleteMap), "not found")
})

test_that("obfuscateLdBlocks round-trips through the same map obfuscatePed(..., map = TRUE) returns", {
  ped <- data.frame(
    id = c("A01", "A02", "A03", "A04", "A05"),
    sire = rep(NA_character_, 5L),
    dam = rep(NA_character_, 5L),
    sex = c("M", "F", "M", "F", "M"),
    stringsAsFactors = FALSE
  )
  obfuscated <- obfuscatePed(ped, map = TRUE)
  out <- obfuscateLdBlocks(i153LdBlockResultFrame(), obfuscated$map)
  expect_false(any(grepl("A0[1-5]", out$idsUsed[1L])))
})
