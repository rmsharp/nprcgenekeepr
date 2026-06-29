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

extractKinship <- function(simKinships, id1, id2, simulation) {
  ids <- dimnames(simKinships[[simulation]])[[1L]]
  simKinships[[simulation]][
    seq_along(ids)[ids == id1],
    seq_along(ids)[ids == id2]
  ]
}

extractKValue <- function(kValue, id1, id2, simulation) {
  kValue[kValue$id_1 == id1 & kValue$id_2 == id2, paste0("sim_", simulation)]
}
extractKValue <- function(kValue, id1, id2, simulation) {
  kValue[id_1 == id1 & id_2 == id2, paste0("sim_", simulation),
         with = FALSE][[1L]]
}
# nolint end: object_name_linter
set_seed(seed = 1L)
n <- 10L
simKinships <- createSimKinships(ped, allSimParents, pop = ped$id, n = n)
kValues <- kinshipMatricesToKValues(simKinships)
counts <- countKinshipValues(kValues)
simKinships <- createSimKinships(ped, allSimParents, pop = ped$id, n = n)
kValues <- kinshipMatricesToKValues(simKinships)
cummulatedCounts <- countKinshipValues(kValues, counts)

test_that("countKinshipValues detects contaminated ID list", {
  counts$kIds[[1L]] <- c("badID_1", "badID_2")
  suppressWarnings(expect_error(
    countKinshipValues(kValues, counts),
    "ID pairs in simulated pedigrees do not match:"
  ))
})
test_that("countKinshipValues makes correct structure", {
  expect_length(counts, 3L)
  expect_equal(names(counts), c("kIds", "kValues", "kCounts"))
  expect_length(counts$kIds, 153L)
})

test_that("countKinshipValues counts kinship values correctly", {
  expect_equal(counts$kCounts[[10L]], c(6L, 4L))
  expect_equal(counts$kValues[[7L]], c(0.125, 0.25))
  expect_identical(as.character(counts$kIds[[3L]]), c("A", "C"))
})

test_that("countKinshipValues makes correct structure", {
  expect_length(cummulatedCounts, 3L)
  expect_identical(names(cummulatedCounts), c("kIds", "kValues", "kCounts"))
  expect_length(cummulatedCounts$kIds, 153L)
})

test_that("countKinshipValues counts kinship values correctly", {
  expect_equal(cummulatedCounts$kCounts[[10]], c(14L, 6L))
  expect_equal(cummulatedCounts$kValues[[7]], c(0.125, 0.25))
  expect_identical(as.character(cummulatedCounts$kIds[[3L]]), c("A", "C"))
})

# Regression test for NEW-15. When a later simulation batch introduced kinship
# values not present in the accumulated set, countKinshipValues wrote the new
# counts to `countDiffs[index]` using the OUTER loop variable (the row index)
# instead of a per-value position. That overwrote a single slot (and, for any
# row index > 1, wrote out of bounds), corrupting the counts and desynchronising
# the lengths of kValues and kCounts. The buggy branch is only reached when
# setdiff(new values, accumulated values) is non-empty -- a case the seed-based
# fixtures above never produce, which is why the bug went undetected.
test_that("countKinshipValues merges new kinship values into correct slots", {
  ## Batch 1: two ID pairs, four simulations, a single kinship value per pair.
  ##   (A, B) -> 0.25  x4 ; (A, C) -> 0.125 x4
  batchOne <- data.table::data.table(
    id_1  = c("A", "A"),
    id_2  = c("B", "C"),
    sim_1 = c(0.25, 0.125),
    sim_2 = c(0.25, 0.125),
    sim_3 = c(0.25, 0.125),
    sim_4 = c(0.25, 0.125)
  )
  ## Batch 2: same pairs, each introducing previously unseen kinship values.
  ##   (A, B) gains TWO new values (0.0625, 0.125) -> exposes the same-slot
  ##          overwrite at row index 1.
  ##   (A, C) gains ONE new value (0.0625) at row index 2 -> exposes the
  ##          out-of-bounds write that desynchronises the list lengths.
  batchTwo <- data.table::data.table(
    id_1  = c("A", "A"),
    id_2  = c("B", "C"),
    sim_1 = c(0.0625, 0.0625),
    sim_2 = c(0.125,  0.0625),
    sim_3 = c(0.25,   0.125),
    sim_4 = c(0.25,   0.125)
  )

  accumulated <- countKinshipValues(batchOne)
  merged <- countKinshipValues(batchTwo, accumulated)

  ## kValues and kCounts must stay the same length for every pair.
  expect_equal(lengths(merged$kValues), lengths(merged$kCounts))

  ## Pair (A, B): 0.25 accumulates 4 + 2 = 6; each new value occurs once.
  expect_identical(as.character(merged$kIds[[1L]]), c("A", "B"))
  expect_equal(merged$kValues[[1L]], c(0.25, 0.0625, 0.125))
  expect_equal(merged$kCounts[[1L]], c(6, 1, 1))

  ## Pair (A, C): 0.125 accumulates 4 + 2 = 6; new value 0.0625 occurs twice.
  expect_identical(as.character(merged$kIds[[2L]]), c("A", "C"))
  expect_equal(merged$kValues[[2L]], c(0.125, 0.0625))
  expect_equal(merged$kCounts[[2L]], c(6, 2))

  ## Every observation is retained: batch1 (4) + batch2 (4) = 8 per pair.
  expect_equal(sum(merged$kCounts[[1L]]), 8)
  expect_equal(sum(merged$kCounts[[2L]]), 8)
})
