## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #148 Slice 3): obfuscateMhcHaplotypes(carriers, map) -- the
## MHC de-identification primitive (design plan D6, ratified S704).
## Contract (plan sec 4 row 5): aliases the id column of a
## mhcHaplotypeCarriers() table (haplotype, id, uncertain) through the
## same alias vector obfuscatePed(..., map = TRUE) already returns; the
## obfuscateTwinRelations() mold. stop() on any id absent from the map --
## never silently drop or leak a real id. Haplotype labels stay
## byte-identical: there is no validity-preserving obfuscation of an MHC
## type (D6), so even a map key that collides with a haplotype label
## must never touch the haplotype column. The uncertain disclosure
## column passes through unchanged.

i148CarriersFixture <- function() {
  data.frame(
    haplotype = c("H01", "H01", "H02", "H02"),
    id = c("A1", "A2", "A2", "A3"),
    uncertain = c(FALSE, FALSE, FALSE, TRUE),
    stringsAsFactors = FALSE
  )
}

i148Map <- function() {
  c(A1 = "ALIAS1", A2 = "ALIAS2", A3 = "ALIAS3")
}

test_that("obfuscateMhcHaplotypes remaps id through map; haplotype and uncertain pass through", {
  out <- obfuscateMhcHaplotypes(i148CarriersFixture(), i148Map())
  expect_identical(out$id, c("ALIAS1", "ALIAS2", "ALIAS2", "ALIAS3"))
  expect_identical(out$haplotype, c("H01", "H01", "H02", "H02"))
  expect_identical(out$uncertain, c(FALSE, FALSE, FALSE, TRUE))
  expect_identical(names(out), c("haplotype", "id", "uncertain"))
})

test_that("a map key colliding with a haplotype label never remaps the haplotype column", {
  ## D6: haplotype labels are byte-identical in the output even when the
  ## map could alias one -- only id is ever remapped.
  collidingMap <- c(i148Map(), H01 = "LEAKED", H02 = "LEAKED")
  out <- obfuscateMhcHaplotypes(i148CarriersFixture(), collidingMap)
  expect_identical(out$haplotype, c("H01", "H01", "H02", "H02"))
  expect_false("LEAKED" %in% out$haplotype)
})

test_that("obfuscateMhcHaplotypes stops loudly on an id absent from map", {
  incompleteMap <- i148Map()[c("A1", "A2")] # A3 deliberately missing
  expect_error(
    obfuscateMhcHaplotypes(i148CarriersFixture(), incompleteMap),
    "not found in the de-identification map"
  )
  expect_error(
    obfuscateMhcHaplotypes(i148CarriersFixture(), incompleteMap),
    "A3"
  )
})

test_that("a zero-row carriers table passes through with structure intact", {
  empty <- i148CarriersFixture()[0L, , drop = FALSE]
  out <- obfuscateMhcHaplotypes(empty, i148Map())
  expect_identical(nrow(out), 0L)
  expect_identical(names(out), c("haplotype", "id", "uncertain"))
})

test_that("the bundled real pair round-trips with no real id surviving", {
  ## The 61-row rareOnly = FALSE carrier table (pin measured S706).
  ## A full synthetic map covering every carrier id: after aliasing, no
  ## original id remains, the haplotype column is byte-identical, and
  ## 0F4FY1's sole provisional row is still uncertain = TRUE under its
  ## alias.
  all <- mhcHaplotypeCarriers(rhesusGenotypes, rareOnly = FALSE)
  realIds <- unique(all$id)
  fullMap <- stats::setNames(sprintf("OBF%03d", seq_along(realIds)),
                             realIds)
  out <- obfuscateMhcHaplotypes(all, fullMap)
  expect_identical(nrow(out), 61L)
  expect_identical(out$haplotype, all$haplotype)
  expect_false(any(out$id %in% realIds))
  expect_identical(out$uncertain[out$id == fullMap[["0F4FY1"]]],
                   all$uncertain[all$id == "0F4FY1"])
  expect_identical(sum(out$uncertain), 1L)
})
