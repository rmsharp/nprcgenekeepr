## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #137 Slice 1 (RED): obfuscateTwinRelations(twinRelations, map) de-identifies a twin/
# zygosity sidecar table (id1, id2, code) by remapping id1/id2 through the same `map` alias
# vector obfuscatePed(..., map = TRUE) already returns (design doc sec 2.5/D5) -- obfuscatePed()
# itself operates on exactly one data.frame and structurally cannot reach a second, sidecar
# object. `code` passes through unchanged (it carries no identifying information). A row whose
# id1 or id2 is absent from `map` errors loudly rather than silently dropping or leaking the
# real id -- checkTwinRelations()'s own existence rule should already have excluded that case
# upstream, so this is a defensive check, not the primary validation path.

i137TwinRelationsFrame <- function() {
  data.frame(
    id1 = c("S1", "S1"),
    id2 = c("S2", "U1"),
    code = c("MZ twin", "UZ twin"),
    stringsAsFactors = FALSE
  )
}

i137Map <- function() {
  c(S1 = "ALIAS1", S2 = "ALIAS2", U1 = "ALIAS3")
}

test_that("obfuscateTwinRelations remaps id1/id2 through map; code passes through unchanged", {
  out <- obfuscateTwinRelations(i137TwinRelationsFrame(), i137Map())
  expect_equal(out$id1, c("ALIAS1", "ALIAS1"))
  expect_equal(out$id2, c("ALIAS2", "ALIAS3"))
  expect_equal(out$code, c("MZ twin", "UZ twin"))
})

test_that("obfuscateTwinRelations stops loudly on an id absent from map", {
  bad <- i137TwinRelationsFrame()
  incompleteMap <- i137Map()[c("S1", "S2")] # U1 deliberately missing
  expect_error(obfuscateTwinRelations(bad, incompleteMap), "not found")
})
