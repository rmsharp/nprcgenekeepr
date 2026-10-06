## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# S923 (BACKLOG finding of S918): the kinship returned for each group is the
# group's rows and columns of the kinship matrix. For a group of one animal
# filterKinMatrix() gave the bare number 0.5; it is now a 1 x 1 matrix named
# for the animal, as for every other group size.
smallPed <- nprcgenekeepr::smallPed
kmat <- kinship(smallPed$id, smallPed$sire, smallPed$dam, smallPed$gen,
  sparse = FALSE
)

test_that("groupMembersReturn gives a group of one animal its kinship as a named 1 x 1 matrix", {
  out <- groupMembersReturn(
    retained = list(list(groupMembers = list("A"), score = 1)),
    withKin = TRUE, kmat = kmat
  )
  groupKin <- out$groupKin[[1L]]
  expect_true(is.matrix(groupKin))
  expect_identical(dim(groupKin), c(1L, 1L))
  expect_identical(dimnames(groupKin), list("A", "A"))
  expect_identical(groupKin["A", "A"], kmat["A", "A"])
})
