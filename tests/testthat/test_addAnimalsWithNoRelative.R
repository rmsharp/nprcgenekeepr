## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
# addAnimalsWithNoRelative() itself is a trivial NA-fill loop over
# setdiff(candidates, names(kin)) -- its correctness doesn't depend on the
# scale of the upstream kinship computation. Use the same smaller qcPed
# fixture already shipped in this function's own roxygen @examples (280
# rows) instead of the full 3694-row examplePedigree; currentGroups/
# candidates still come from examplePedigree, matching that same shipped
# example exactly. This exercises both branches (NA-fill for a no-relative
# candidate, and pass-through for one with real relatives) in ~0.07s instead
# of ~5.9s, with no loss of what's being verified.
qcPed <- nprcgenekeepr::qcPed
examplePedigree <- nprcgenekeepr::examplePedigree
ped <- qcStudbook(qcPed,
  minParentAge = 2L, reportChanges = FALSE,
  reportErrors = FALSE
)
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
currentGroups <- list(1L)
currentGroups[[1L]] <- examplePedigree$id[1L:3L]
candidates <- examplePedigree$id[examplePedigree$status == "ALIVE"]
threshold <- 0.015625
kin <- getAnimalsWithHighKinship(kmat, ped, threshold, currentGroups,
  ignore = list(c("F", "F")), minAge = 1.0
)
# Filtering out candidates related to current group members
conflicts <- unique(c(
  unlist(kin[unlist(currentGroups)]),
  unlist(currentGroups)
))
candidates <- setdiff(candidates, conflicts)
kin <- addAnimalsWithNoRelative(kin, candidates)

test_that("addAnimalsWithNoRelative adds correct animals", {
  expect_length(kin, 591L)
  # "1SPLS8" has no high-kinship relative at this fixture's scale -- the
  # NA-fill branch addAnimalsWithNoRelative() exists for.
  expect_true(is.na(kin[["1SPLS8"]]))
  # "0DAV0I" has a real relative list -- the pass-through branch. This
  # length matches the value already documented and shipped in this
  # function's own roxygen @examples for the identical fixture.
  expect_length(kin[["0DAV0I"]], 34L)
})
