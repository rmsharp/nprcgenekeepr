## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# nolint start: object_name_linter
ped <- nprcgenekeepr::smallPed
simParent_1 <- list(
  id = "A",
  sires = c("s1_1", "s1_2", "s1_3"),
  dams = c("d1_1", "d1_2", "d1_3", "d1_4")
)
simParent_2 <- list(
  id = "B",
  sires = c("s1_1", "s1_2", "s1_3"),
  dams = c("d1_1", "d1_2", "d1_3", "d1_4")
)
simParent_3 <- list(
  id = "E",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
simParent_4 <- list(
  id = "J",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
simParent_5 <- list(
  id = "K",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
simParent_6 <- list(
  id = "N",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
allSimParents <- list(
  simParent_1, simParent_2, simParent_3,
  simParent_4, simParent_5, simParent_6
)

extractKinship <- function(simKinships, id1, id2) {
  vapply(simKinships,
    function(x) {
      x[
        seq_along(ped$id)[ped$id == id1],
        seq_along(ped$id)[ped$id == id2]
      ]
    },
    FUN.VALUE = numeric(1L)
  )
}

set_seed(seed = 1L)
n <- 10L
simKinships <- createSimKinships(ped, allSimParents, pop = ped$id, n = n)
test_EN <- extractKinship(simKinships, "E", "N")
test_BN <- extractKinship(simKinships, "B", "N")
test_JN <- extractKinship(simKinships, "J", "N")
test_KN <- extractKinship(simKinships, "K", "N")
test_BK <- extractKinship(simKinships, "B", "K")
test_EK <- extractKinship(simKinships, "E", "K")
# nolint end: object_name_linter

test_that("createSimKinships creates the correct kinship matrices structure", {
  expect_equal(length(simKinships), n)
  expect_equal(length(simKinships[[1L]]), 17L * 17L)
  expect_equal(nrow(simKinships[[1L]]), 17L)
  ## Re-baselined S277: makeSimPed now preserves A's known sire Q (#31),
  ## shifting this characterization vector.
  expect_equal(test_EN, c(0.0, 0.0, 0.125, 0.0, 0.0, 0.125, 0.0, 0.0, 0.125,
                          0.125))
})

test_that("createSimKinships does not mutate the caller's pedigree (NEW-53)", {
  ## NEW-53: createSimKinships must not flip the caller's data.frame to a
  ## data.table by reference (setDT at createSimKinships.R:50).
  pedDF <- as.data.frame(nprcgenekeepr::smallPed)
  expect_identical(class(pedDF), "data.frame") # precondition
  localParents <- list(
    list(id = "A", sires = c("s1_1", "s1_2"), dams = c("d1_1", "d1_2"))
  )
  set_seed(seed = 1L)
  invisible(createSimKinships(pedDF, localParents, pop = pedDF$id, n = 2L))
  expect_false(inherits(pedDF, "data.table"))
  expect_identical(class(pedDF), "data.frame")
})

# ---------------------------------------------------------------------------
# BL-N Slice 2 (twinRelations-into-kinship() plan, docs/planning/
# twin-relations-kinship-computation-plan.md sec 4): createSimKinships()
# threads an optional twinRelations = NULL parameter straight through to its
# internal kinship() call (sec 2.4 call site #3) on every simulated pedigree.
# allSimParents = list() means makeSimPed() has nothing to impute, so every
# simulated pedigree is identical to the input (sec 2.6: a twin pair with
# known recorded parents passes through unchanged) -- the returned matrices
# reproduce the Slice 1 ground-truth values (test_kinship.R) directly.
# ---------------------------------------------------------------------------
twinSimPed <- data.frame(
  id   = as.character(1:10),
  sire = c(NA, NA, "1", "1", NA, NA, "3", "6", "6", "8"),
  dam  = c(NA, NA, "2", "2", NA, NA, "5", "4", "4", "7"),
  stringsAsFactors = FALSE
)
twinSimPed$gen <- findGeneration(twinSimPed$id, twinSimPed$sire, twinSimPed$dam)
twinSimTwins <- data.frame(id1 = "8", id2 = "9", code = "MZ twin",
  stringsAsFactors = FALSE)

test_that("createSimKinships threads twinRelations into every simulated kinship matrix (Slice 2)", {
  sk <- createSimKinships(twinSimPed,
    allSimParents = list(), pop = twinSimPed$id,
    n = 2L, twinRelations = twinSimTwins
  )
  for (kmat in sk) {
    expect_equal(kmat["8", "9"], 0.5)
    expect_equal(kmat["9", "10"], 0.28125)
  }
})

test_that("createSimKinships without twinRelations is unaffected (backward compatibility, Slice 2)", {
  sk <- createSimKinships(twinSimPed,
    allSimParents = list(), pop = twinSimPed$id, n = 2L
  )
  expect_equal(sk[[1L]]["8", "9"], 0.25)
})
