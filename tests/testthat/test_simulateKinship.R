## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# NEW-50 (PED_GV audit, Decision record 8, docs/audits/
# PED_GV_AUDIT_TRIAGE_2026-09-26.md): createSimKinships() and
# cumulateSimKinships() share one internal helper, .simulateKinship(), for the
# step they used to repeat: draw one simulated pedigree with makeSimPed(), then
# compute its kinship matrix. Each function keeps its own loop.
#
# RED phase (S887): the helper tests and the delegation tests fail until the
# helper exists and both functions call it. The tie test and the n = 0 test
# pass today on purpose: they pin the behavior the change must not alter.

ped <- nprcgenekeepr::smallPed
allSimParents <- list(
  list(
    id = "A",
    sires = c("s1_1", "s1_2", "s1_3"),
    dams = c("d1_1", "d1_2", "d1_3", "d1_4")
  ),
  list(
    id = "B",
    sires = c("s1_1", "s1_2", "s1_3"),
    dams = c("d1_1", "d1_2", "d1_3", "d1_4")
  ),
  list(id = "E", sires = c("A", "C", "s1_1"), dams = c("d3_1", "B")),
  list(id = "J", sires = c("A", "C", "s1_1"), dams = c("d3_1", "B")),
  list(id = "K", sires = c("A", "C", "s1_1"), dams = c("d3_1", "B")),
  list(id = "N", sires = c("A", "C", "s1_1"), dams = c("d3_1", "B"))
)
nIds <- nrow(ped)
## A stand-in for the helper's result: every cell 0.5, so the mean, min and max
## of identical copies are 0.5 and the sample standard deviation is exactly 0.
fakeKmat <- matrix(0.5, nrow = nIds, ncol = nIds)

# ---------------------------------------------------------------------------
# The helper itself
# ---------------------------------------------------------------------------
test_that(".simulateKinship() is kinship() of one makeSimPed() draw (NEW-50)", {
  set_seed(seed = 3L)
  simPed <- makeSimPed(ped, allSimParents)
  expected <- kinship(simPed$id, simPed$sire, simPed$dam, simPed$gen)
  set_seed(seed = 3L)
  expect_equal(.simulateKinship(ped, allSimParents), expected)
})

test_that(".simulateKinship() draws a new pedigree on every call (NEW-50)", {
  set_seed(seed = 3L)
  first <- .simulateKinship(ped, allSimParents)
  second <- .simulateKinship(ped, allSimParents)
  expect_false(isTRUE(all.equal(first, second)))
})

twinPed <- data.frame(
  id   = as.character(1:10),
  sire = c(NA, NA, "1", "1", NA, NA, "3", "6", "6", "8"),
  dam  = c(NA, NA, "2", "2", NA, NA, "5", "4", "4", "7"),
  stringsAsFactors = FALSE
)
twinPed$gen <- findGeneration(twinPed$id, twinPed$sire, twinPed$dam)
twinTwins <- data.frame(
  id1 = "8", id2 = "9", code = "MZ twin",
  stringsAsFactors = FALSE
)

test_that(".simulateKinship() passes twinRelations to kinship() (NEW-50)", {
  ## allSimParents = list() leaves the pedigree as given, so the values are the
  ## ground-truth kinships used by test_kinship.R.
  withTwins <- .simulateKinship(twinPed, list(), twinRelations = twinTwins)
  expect_equal(withTwins["8", "9"], 0.5)
  expect_equal(withTwins["9", "10"], 0.28125)
  expect_equal(.simulateKinship(twinPed, list())["8", "9"], 0.25)
})

## A twin pair that exists in smallPed (siblings C and D), so the real
## kinship() accepts it. The delegation tests pass it through a stand-in helper.
smallPedTwins <- data.frame(
  id1 = "C", id2 = "D", code = "MZ twin",
  stringsAsFactors = FALSE
)

test_that(".simulateKinship() reports an unknown parent only when verbose (NEW-50)", {
  ## B has an unknown sire and dam; no representatives are supplied for it.
  noRepresentatives <- list(
    list(id = "B", sires = character(0L), dams = character(0L))
  )
  expect_message(
    .simulateKinship(ped, noRepresentatives, verbose = TRUE),
    "is B and has no sire"
  )
  expect_message(.simulateKinship(ped, noRepresentatives), regexp = NA)
})

test_that(".simulateKinship() leaves the pedigree it is given unchanged (NEW-50)", {
  pedDF <- as.data.frame(nprcgenekeepr::smallPed)
  before <- pedDF
  set_seed(seed = 1L)
  invisible(.simulateKinship(pedDF, allSimParents))
  expect_identical(pedDF, before)
  expect_identical(class(pedDF), "data.frame")
})

# ---------------------------------------------------------------------------
# Both functions call the helper
# ---------------------------------------------------------------------------
test_that("createSimKinships() calls the helper once per simulation (NEW-50)", {
  helper <- mockery::mock(fakeKmat, cycle = TRUE)
  mockery::stub(createSimKinships, ".simulateKinship", helper)
  result <- createSimKinships(ped, allSimParents,
    pop = ped$id, n = 3L,
    verbose = TRUE, twinRelations = smallPedTwins
  )
  mockery::expect_called(helper, 3L)
  expect_identical(result, list(fakeKmat, fakeKmat, fakeKmat))
  firstCall <- mockery::mock_args(helper)[[1L]]
  expect_true(firstCall$verbose)
  expect_identical(firstCall$twinRelations, smallPedTwins)
  ## The pedigree is converted once, before the loop, not once per simulation.
  expect_s3_class(firstCall[[1L]], "data.table")
})

test_that("cumulateSimKinships() calls the helper once per simulation (NEW-50)", {
  helper <- mockery::mock(fakeKmat, cycle = TRUE)
  mockery::stub(cumulateSimKinships, ".simulateKinship", helper)
  result <- cumulateSimKinships(ped, allSimParents,
    pop = ped$id, n = 3L,
    twinRelations = smallPedTwins
  )
  mockery::expect_called(helper, 3L)
  expect_equal(result$meanKinship, fakeKmat)
  expect_equal(result$minKinship, fakeKmat)
  expect_equal(result$maxKinship, fakeKmat)
  expect_equal(result$sdKinship, matrix(0, nrow = nIds, ncol = nIds))
  expect_identical(
    mockery::mock_args(helper)[[1L]]$twinRelations, smallPedTwins
  )
})

test_that("neither function calls the helper when n is 0 (NEW-50)", {
  helper <- mockery::mock(fakeKmat, cycle = TRUE)
  mockery::stub(createSimKinships, ".simulateKinship", helper)
  mockery::stub(cumulateSimKinships, ".simulateKinship", helper)
  expect_identical(
    createSimKinships(ped, allSimParents, pop = ped$id, n = 0L),
    list()
  )
  expect_error(
    cumulateSimKinships(ped, allSimParents, pop = ped$id, n = 0L),
    "at least one simulation"
  )
  mockery::expect_called(helper, 0L)
})

# ---------------------------------------------------------------------------
# The two functions still agree (passes before and after the change)
# ---------------------------------------------------------------------------
test_that("cumulateSimKinships() summarizes the matrices createSimKinships() makes under one seed (NEW-50)", {
  n <- 25L
  set_seed(seed = 2L)
  created <- createSimKinships(ped, allSimParents, pop = ped$id, n = n)
  set_seed(seed = 2L)
  cumulated <- cumulateSimKinships(ped, allSimParents, pop = ped$id, n = n)
  expect_equal(cumulated$meanKinship, Reduce(`+`, created) / n)
  expect_equal(cumulated$minKinship, Reduce(pmin, created))
  expect_equal(cumulated$maxKinship, Reduce(pmax, created))
})
