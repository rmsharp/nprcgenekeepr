## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

ped <- nprcgenekeepr::qcPed
ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen,
  sparse = FALSE
)
ids <- ped$id[c(189L, 192L, 194L, 195L)]
ncols <- ncol(kmat)
nrows <- nrow(kmat)
kmatFiltered <- filterKinMatrix(ids, kmat)
test_that("filterKinMatrix retains the correct rows and columns", {
  expect_equal(kmatFiltered[1L, 2L], kmat[189L, 192L])
  expect_equal(kmatFiltered[1L, 3L], kmat[189L, 194L])
  expect_equal(kmatFiltered[1L, 4L], kmat[189L, 195L])
  expect_equal(kmatFiltered[2L, 3L], kmat[192L, 194L])
})
ids <- c(
  "C1ICXL", "2KULR3", "RI0O7F", "7M51X5", "170ZTZ", "Y7PPEZ",
  "CFPEEU", "ZC5SCR", "218FOV", "2IXJ2N", "CAST4W", "JGPN6K", "HOYW0S",
  "DD1U77", "0DAV0I", "HLI95R", "TZ5NUB", "DR5GXB", "EUG3WE", "FHV13N",
  "OUM6QF", "6Z7MD9", "309VM2", "8KM1MP", "I9TQ0T", "INGWI7"
)

kmatFiltered <- filterKinMatrix(ids, kmat)
test_that("filterKinMatrix leaves the correct rows", {
  expect_length(ids, nrow(kmatFiltered))
  expect_length(ids, ncol(kmatFiltered))
  expect_identical(
    kmat[
      (seq_len(nrow(kmat)))[rownames(kmat) %in% ids[20L:23L]],
      (seq_len(ncol(kmat)))[colnames(kmat) %in% ids[20L:23L]]
    ],
    kmatFiltered[20L:23L, 20L:23L]
  )
})

# S923 (BACKLOG finding of S918): given one id the function returned the bare
# number 0.5, not the matrix its help page promises, so every caller that read
# the result as a matrix (convertRelationships(), reportMatePairs()) failed or
# answered nonsense. A matrix is returned however many ids match.
smallPed <- nprcgenekeepr::smallPed
smallKmat <- kinship(smallPed$id, smallPed$sire, smallPed$dam, smallPed$gen,
  sparse = FALSE
)
expectOneAnimalMatrix <- function(m) {
  expect_true(is.matrix(m))
  expect_identical(dim(m), c(1L, 1L))
  expect_identical(dimnames(m), list("A", "A"))
  expect_identical(m["A", "A"], smallKmat["A", "A"])
}

test_that("filterKinMatrix gives a 1 x 1 matrix named for the animal when one id is given", {
  expectOneAnimalMatrix(filterKinMatrix("A", smallKmat))
})

test_that("filterKinMatrix gives that 1 x 1 matrix when one id is in the matrix and one is not", {
  expectOneAnimalMatrix(filterKinMatrix(c("A", "ZZZ"), smallKmat))
})

test_that("filterKinMatrix gives that 1 x 1 matrix when the same id is given twice", {
  expectOneAnimalMatrix(filterKinMatrix(c("A", "A"), smallKmat))
})

# Recorded, not changed by S923: no matching id gives an empty matrix.
test_that("filterKinMatrix gives a 0 x 0 matrix when no id is in the matrix", {
  none <- filterKinMatrix("ZZZ", smallKmat)
  expect_true(is.matrix(none))
  expect_identical(dim(none), c(0L, 0L))
})
