## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Tests for .enumerateMaximalIndependentSets() -- issue #146 Slice 2
## (docs/planning/issue146-configurable-exhaustive-breeding-group-retention-plan.md
## D4/D5, interface catalog). Consumes the same `kin`-shaped conflict adjacency
## list getAnimalsWithHighKinship()/addAnimalsWithNoRelative() already build
## (plan Sec 2.3) -- no complement graph is materialized. Signature:
## .enumerateMaximalIndependentSets(candidates, kin, cap, deadline) ->
## list(sets = <list of character vectors>, examined = <integer>,
## truncated = <logical>).

## ---- test helpers (not exported, local to this file) --------------------

## Brute-force reference: every maximal independent set of the conflict graph
## described by `kin`, computed by exhaustive subset enumeration. Only used
## against small (n <= 8) fixtures in this file -- 2^n subsets is trivial at
## that size. Independent of, and not derived from, the algorithm under test.
.referenceMaximalIndependentSets <- function(ids, kin) {
  n <- length(ids)
  allSets <- list()
  for (mask in seq_len(2L^n) - 1L) {
    bits <- as.logical(intToBits(mask))[seq_len(n)]
    subset <- ids[bits]
    if (length(subset) == 0L) next
    independent <- TRUE
    for (i in seq_along(subset)) {
      conflicts <- kin[[subset[i]]]
      if (!is.null(conflicts) && !all(is.na(conflicts)) &&
          any(subset[-i] %in% conflicts)) {
        independent <- FALSE
        break
      }
    }
    if (independent) allSets[[length(allSets) + 1L]] <- sort(subset)
  }
  isMaximal <- vapply(allSets, function(s) {
    !any(vapply(allSets, function(t) {
      length(t) > length(s) && all(s %in% t)
    }, logical(1L)))
  }, logical(1L))
  allSets[isMaximal]
}

## Order-independent set-of-sets equality: every element of `actual` (sorted)
## must appear exactly once among `expected` (sorted), and vice versa.
.expectSameSets <- function(actual, expected) {
  actualKeys <- vapply(actual, function(s) paste(sort(s), collapse = ","),
                        character(1L))
  expectedKeys <- vapply(expected, function(s) paste(sort(s), collapse = ","),
                          character(1L))
  expect_setequal(actualKeys, expectedKeys)
  expect_length(actualKeys, length(expectedKeys))
}

## ---- exhaustive-completion correctness: hand-verified 5-cycle fixture ---

## Conflict graph is a 5-cycle A-B-C-D-E-A. A 5-cycle's complement is also a
## 5-cycle (5-cycles are self-complementary), giving exactly 5 maximal
## independent sets, each of size 2 -- one per non-adjacent pair: {A,C},
## {A,D}, {B,D}, {B,E}, {C,E}. Verified by hand before writing this test (not
## generated from .referenceMaximalIndependentSets(), which is exercised
## separately below).
test_that(paste(".enumerateMaximalIndependentSets finds all 5 maximal",
                 "independent sets of a hand-verified 5-cycle conflict graph"), {
  ids <- c("A", "B", "C", "D", "E")
  kin <- list(
    A = c("B", "E"), B = c("A", "C"), C = c("B", "D"),
    D = c("C", "E"), E = c("D", "A")
  )
  expected <- list(c("A", "C"), c("A", "D"), c("B", "D"), c("B", "E"),
                    c("C", "E"))

  result <- .enumerateMaximalIndependentSets(
    candidates = ids, kin = kin, cap = 20L,
    deadline = Sys.time() + 10
  )

  expect_false(result$truncated)
  expect_equal(result$examined, 5L)
  .expectSameSets(result$sets, expected)
})

## ---- deadline-truncation: graceful degradation, never stop()s -----------

test_that(paste(".enumerateMaximalIndependentSets truncates gracefully when",
                 "the deadline has already elapsed, without erroring"), {
  ids <- c("A", "B", "C", "D", "E")
  kin <- list(
    A = c("B", "E"), B = c("A", "C"), C = c("B", "D"),
    D = c("C", "E"), E = c("D", "A")
  )

  result <- NULL
  expect_no_error(
    result <- .enumerateMaximalIndependentSets(
      candidates = ids, kin = kin, cap = 20L,
      deadline = Sys.time() - 1 # already elapsed
    )
  )

  expect_true(result$truncated)
  expect_true(is.numeric(result$examined) || is.integer(result$examined))
  expect_gte(result$examined, 0L)
  expect_lte(result$examined, 5L) # can't exceed the true total for this graph
})

## ---- density robustness: correctness is not tied to a density heuristic -

## Sparse graph: 8 candidates, a perfect matching (4 conflict edges only) --
## 16 maximal independent sets (pick one of each matched pair), each size 4.
## Dense graph: 8 candidates, every pair conflicts except one -- 7 maximal
## independent sets (the one non-conflicting pair, plus one singleton for
## each of the remaining 6 candidates). Both are cross-checked against
## .referenceMaximalIndependentSets() (brute force), not hand-derived counts,
## so this test does not depend on the hand arithmetic above being right --
## it is an independent correctness check. A generous deadline (5s) is used
## so neither case is truncated; this asserts CORRECTNESS at both densities,
## not runtime (plan Sec 2.10/Dragon 3: the sparser graph is the
## combinatorially harder one, the opposite of what "fewer conflicts should
## mean less work" suggests -- a truncation-based or density-heuristic
## implementation could silently under-enumerate the sparse case).
test_that(paste(".enumerateMaximalIndependentSets is correct at both low and",
                 "high conflict-graph density (not tied to a density",
                 "heuristic, plan Sec 2.10/Dragon 3)"), {
  sparseIds <- paste0("S", 1L:8L)
  sparseKin <- list(
    S1 = "S2", S2 = "S1", S3 = "S4", S4 = "S3",
    S5 = "S6", S6 = "S5", S7 = "S8", S8 = "S7"
  )
  denseIds <- paste0("D", 1L:8L)
  denseKin <- lapply(stats::setNames(denseIds, denseIds), function(id) {
    setdiff(denseIds, id)
  })
  # The one designated non-conflicting pair: remove D2 from D1's conflict
  # list and vice versa.
  denseKin$D1 <- setdiff(denseKin$D1, "D2")
  denseKin$D2 <- setdiff(denseKin$D2, "D1")

  sparseResult <- .enumerateMaximalIndependentSets(
    candidates = sparseIds, kin = sparseKin, cap = 20L,
    deadline = Sys.time() + 5
  )
  denseResult <- .enumerateMaximalIndependentSets(
    candidates = denseIds, kin = denseKin, cap = 20L,
    deadline = Sys.time() + 5
  )

  sparseExpected <- .referenceMaximalIndependentSets(sparseIds, sparseKin)
  denseExpected <- .referenceMaximalIndependentSets(denseIds, denseKin)

  expect_false(sparseResult$truncated)
  expect_false(denseResult$truncated)
  # The counter-intuitive headline finding itself, asserted structurally:
  # the sparser graph has MORE maximal independent sets, not fewer.
  expect_gt(length(sparseExpected), length(denseExpected))
  .expectSameSets(sparseResult$sets, sparseExpected)
  .expectSameSets(denseResult$sets, denseExpected)
})
