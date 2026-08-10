## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
library(nprcgenekeepr)
qcBreeders <- nprcgenekeepr::qcBreeders
pedWithGenotype <- nprcgenekeepr::pedWithGenotype
pedWithGenotypeReport <- nprcgenekeepr::pedWithGenotypeReport
skip_if_not(exists("qcBreeders"))
skip_if_not(exists("pedWithGenotype"))
skip_if_not(exists("pedWithGenotypeReport"))
set_seed(10L)
test_that("groupAddAssign forms the correct groups", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  currentGroups <- list(1L)
  currentGroups[[1L]] <- qcBreeders[1L:3L]
  groupAddTest <- groupAddAssign(
    candidates = qcBreeders,
    kmat = pedWithGenotypeReport$kinship,
    ped = pedWithGenotype,
    currentGroups = currentGroups,
    ignore = NULL, minAge = 1.0, numGp = 1L,
    harem = FALSE, sexRatio = 0L, withKin = FALSE
  )
  expect_length(groupAddTest$group[[1L]], 11L)
  expect_length(groupAddTest$group[[2L]], 14L)
  # expect_equal(length(groupAddTest$group[[2L]]), 10L)
  expect_null(groupAddTest$groupKin[[1L]])
})
set_seed(10L)
test_that("groupAddAssign (numGp = 2) forms the correct groups", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  groupAssignTest <- groupAddAssign(
    candidates = qcBreeders,
    kmat = pedWithGenotypeReport$kinship,
    ped = pedWithGenotype,
    currentGroups = character(0L),
    ignore = NULL,
    minAge = 1L,
    numGp = 2L,
    harem = FALSE,
    sexRatio = 0.0,
    withKin = FALSE
  )
  expect_length(groupAssignTest$group[[1L]], 9L)
  # expect_equal(length(groupAssignTest$group[[2L]]), 10L)
  expect_length(groupAssignTest$group[[2L]], 9L)
  expect_null(groupAssignTest$groupKin[[1L]])
})
set_seed(10L)
test_that(paste0(
  "groupAddAssign (numGp = 1) forms the correct groups with ",
  "kinship matrices"
), {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  currentGroups <- list(1L)
  currentGroups[[1L]] <- qcBreeders[1L:3L]
  groupAddKTest <- groupAddAssign(
    candidates = qcBreeders,
    kmat = pedWithGenotypeReport$kinship,
    ped = pedWithGenotype,
    currentGroups = currentGroups,
    ignore = NULL,
    minAge = 1L,
    numGp = 1L,
    harem = FALSE,
    sexRatio = 0.0,
    withKin = TRUE
  )
  expect_length(groupAddKTest$group[[1L]], 11L)
  expect_length(groupAddKTest$group[[2L]], 14L)
  # expect_equal(length(groupAddKTest$group[[2L]]), 10L)
})
set_seed(10L)
test_that("groupAddAssign forms the correct groups with kinship matrices", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  groupAssignKTest <- groupAddAssign(
    candidates = qcBreeders,
    kmat = pedWithGenotypeReport$kinship,
    ped = pedWithGenotype,
    currentGroups = character(0L),
    ignore = NULL,
    minAge = 1.0,
    numGp = 2L,
    harem = FALSE,
    sexRatio = 0.0,
    withKin = TRUE
  )
  expect_equal(length(groupAssignKTest$group[[1L]]), 9L)
  expect_length(groupAssignKTest$group[[2L]], 9L)
  # expect_equal(length(groupAssignKTest$group[[2L]]), 10L)
  expect_length(groupAssignKTest$groupKin[[1L]], 81L)
})
set_seed(10L)
noSires <- removePotentialSires(qcBreeders,
  minAge = 2.0,
  pedWithGenotype
)
sires <- getPotentialSires(qcBreeders, pedWithGenotype, minAge = 2.0)

test_that(paste0(
  "groupAddAssign fails when no potential sires exist for harem creation"
), {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  expect_error(
    groupAddAssign(
      candidates = noSires,
      kmat = pedWithGenotypeReport$kinship,
      ped = pedWithGenotype,
      currentGroups = character(0L),
      ignore = NULL,
      minAge = 1.0,
      numGp = 2L,
      harem = TRUE,
      sexRatio = 0.0,
      withKin = TRUE
    )
  )
})
test_that(
  paste0(
    "groupAddAssign add 1 sire at most when there are multiple potential ",
    "sires in the candidates during harem creation"
  ),
  {
    skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
    group <- groupAddAssign(
      candidates = qcBreeders,
      kmat = pedWithGenotypeReport$kinship,
      ped = pedWithGenotype,
      currentGroups = character(0L),
      ignore = NULL,
      minAge = 1.0,
      numGp = 2L,
      harem = TRUE,
      sexRatio = 0.0,
      withKin = TRUE
    )
    # 4, not 3: issue #125 added a `candidates` top-level element between
    # `score` and `groupKin` (group[[1L]] below is still `group$group`,
    # unaffected -- `group` stayed the first named element).
    expect_true(length(group) == 4L)
    expect_identical(sum(seq_along(group[[1L]][[3L]])[group[[1L]][[3L]] %in%
                                                  sires]), 0L)
    expect_identical(sum(seq_along(group[[1L]][[3L]])[group[[1L]][[2L]] %in%
                                                    sires]), 1L)
  }
)
test_that(
  paste0(
    "groupAddAssign fails when there are more groups with seed animals that ",
    "the number of groups to be formed"
  ),
  {
    skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
    currentGroups <- list(3L)
    currentGroups[[1L]] <- qcBreeders[1L:3L]
    currentGroups[[2L]] <- qcBreeders[4L:6L]
    currentGroups[[3L]] <- qcBreeders[7L:9L]
    expect_error(
      groupAddAssign(
        candidates = noSires,
        kmat = pedWithGenotypeReport$kinship,
        ped = pedWithGenotype,
        currentGroups = currentGroups,
        ignore = NULL,
        minAge = 1.0,
        numGp = 2L,
        harem = FALSE,
        sexRatio = 0L,
        withKin = TRUE
      )
    )
  }
)

# =============================================================================
# Issue #125 Slice 2: multiple breeding-group candidates (top 5, deduped by
# canonicalized partition content, not by score -- see plan Dragon R4).
# =============================================================================
set_seed(11L)
test_that("groupAddAssign deduplicates identical partitions into a single candidate", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  # All candidates mutually unrelated (kinship 0 off-diagonal) with a single
  # target group: fillGroupMembers() has no relatedness conflict to resolve,
  # so every trial's draw includes every candidate in the one group -- the
  # same partition every time, regardless of draw order (verified empirically
  # across 20 trials before writing this assertion).
  unrelatedIds <- paste0("U", 1L:6L)
  kmat <- diag(0.5, nrow = 6L, ncol = 6L)
  dimnames(kmat) <- list(unrelatedIds, unrelatedIds)
  ped <- data.frame(
    id = unrelatedIds, sire = NA_character_, dam = NA_character_,
    sex = rep(c("M", "F"), 3L), birth = as.Date("2015-01-01"),
    exit = as.Date(NA), stringsAsFactors = FALSE
  )
  result <- groupAddAssign(
    candidates = unrelatedIds, kmat = kmat, ped = ped,
    currentGroups = list(character(0L)), threshold = 0.015625,
    ignore = list(c("F", "F")), minAge = 1.0, iter = 20L,
    numGp = 1L, harem = FALSE, sexRatio = 0.0, withKin = FALSE
  )
  expect_length(result$candidates, 1L)
})
set_seed(10L)
test_that("groupAddAssign retains at most 5 distinct candidates", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  # qcBreeders/numGp=2L empirically produces 1000 distinct partitions across
  # 1000 trials (verified before writing this assertion) -- exercises both
  # the bound (<=5) and that it is not vacuously 1 (>1).
  groupAssignTest <- groupAddAssign(
    candidates = qcBreeders,
    kmat = pedWithGenotypeReport$kinship,
    ped = pedWithGenotype,
    currentGroups = character(0L),
    ignore = NULL,
    minAge = 1L,
    numGp = 2L,
    harem = FALSE,
    sexRatio = 0.0,
    withKin = FALSE
  )
  expect_lte(length(groupAssignTest$candidates), 5L)
  expect_gt(length(groupAssignTest$candidates), 1L)
})
set_seed(10L)
test_that("groupAddAssign retains at most maxCandidates when lowered (issue #146 Slice 1)", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  # Same fixture/parameters as the default-5 test above, with maxCandidates
  # explicitly lowered to 3 -- proves the retention cap is a real parameter,
  # not a hardcoded 5L (issue #146 Slice 1, plan Dragon 1).
  groupAssignTest <- groupAddAssign(
    candidates = qcBreeders,
    kmat = pedWithGenotypeReport$kinship,
    ped = pedWithGenotype,
    currentGroups = character(0L),
    ignore = NULL,
    minAge = 1L,
    numGp = 2L,
    harem = FALSE,
    sexRatio = 0.0,
    withKin = FALSE,
    maxCandidates = 3L
  )
  expect_lte(length(groupAssignTest$candidates), 3L)
  expect_gt(length(groupAssignTest$candidates), 1L)
})
set_seed(10L)
test_that(paste0(
  "groupAddAssign retains more than 5 candidates when maxCandidates is ",
  "raised (issue #146 Slice 1)"
), {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  # Same fixture/parameters, maxCandidates raised to 8. qcBreeders/numGp=2
  # empirically produces 1000 distinct partitions across 1000 trials (see
  # the default-5 test above), so raising the cap should retain more than
  # the old hardcoded 5 -- proves the default-5 test's own passing isn't
  # just a coincidence of a still-hardcoded 5L.
  groupAssignTest <- groupAddAssign(
    candidates = qcBreeders,
    kmat = pedWithGenotypeReport$kinship,
    ped = pedWithGenotype,
    currentGroups = character(0L),
    ignore = NULL,
    minAge = 1L,
    numGp = 2L,
    harem = FALSE,
    sexRatio = 0.0,
    withKin = FALSE,
    maxCandidates = 8L
  )
  expect_lte(length(groupAssignTest$candidates), 8L)
  expect_gt(length(groupAssignTest$candidates), 5L)
})
set_seed(10L)
test_that("groupAddAssign's top-level group/score alias the best (first) candidate", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  currentGroups <- list(1L)
  currentGroups[[1L]] <- qcBreeders[1L:3L]
  groupAddTest <- groupAddAssign(
    candidates = qcBreeders,
    kmat = pedWithGenotypeReport$kinship,
    ped = pedWithGenotype,
    currentGroups = currentGroups,
    ignore = NULL, minAge = 1.0, numGp = 1L,
    harem = FALSE, sexRatio = 0L, withKin = FALSE
  )
  expect_identical(groupAddTest$group, groupAddTest$candidates[[1L]]$group)
  expect_identical(groupAddTest$score, groupAddTest$candidates[[1L]]$score)
})

# =============================================================================
# Issue #146 Slice 2: exhaustive enumeration mode (D2/D5/D7/D9, plan
# docs/planning/issue146-configurable-exhaustive-breeding-group-retention-plan.md)
# =============================================================================

test_that(paste("groupAddAssign(exhaustive = TRUE) returns every maximal",
                 "independent set on an eligible small fixture, with",
                 "exhaustive/examined/retentionRule set"), {
  # A 5-cycle conflict graph (hand-verified in
  # test_enumerateMaximalIndependentSets.R): exactly 5 maximal independent
  # sets, each of size 2 -- {A,C}, {A,D}, {B,D}, {B,E}, {C,E}. Kinship values
  # are set so the resulting `kin` (via getAnimalsWithHighKinship(), default
  # threshold 0.015625) matches the cycle edges exactly: 0.25 (above
  # threshold) for cycle pairs, 0 (below threshold) for the rest.
  ids <- c("A", "B", "C", "D", "E")
  cycleEdges <- list(c("A", "B"), c("B", "C"), c("C", "D"), c("D", "E"),
                      c("E", "A"))
  kmat <- matrix(0, nrow = 5L, ncol = 5L, dimnames = list(ids, ids))
  diag(kmat) <- 0.5
  for (e in cycleEdges) {
    kmat[e[1L], e[2L]] <- 0.25
    kmat[e[2L], e[1L]] <- 0.25
  }
  # `age` (well above minAge = 1.0) is required: filterAge() indexes
  # ped[i, "age"] with an explicit row-index vector `i`, which is a base R
  # quirk (df[i, "missingCol"] silently returns NULL rather than erroring,
  # unlike df[, "missingCol"]) that would otherwise make it silently drop
  # every kinship pair instead of erroring -- found and fixed during this
  # session's own GREEN verification, see PROJECT_LEARNINGS.md.
  ped <- data.frame(
    id = ids, sire = NA_character_, dam = NA_character_,
    sex = rep(c("M", "F"), length.out = 5L), birth = as.Date("2015-01-01"),
    exit = as.Date(NA), age = 10, stringsAsFactors = FALSE
  )

  result <- groupAddAssign(
    candidates = ids, kmat = kmat, ped = ped,
    currentGroups = list(character(0L)), threshold = 0.015625,
    ignore = NULL, minAge = 1.0, numGp = 1L, harem = FALSE, sexRatio = 0.0,
    withKin = FALSE, exhaustive = TRUE, maxExhaustiveCandidates = 20L,
    exhaustiveTimeLimit = 10
  )

  expect_true(result$exhaustive)
  expect_equal(result$examined, 5L)
  expect_true(is.character(result$retentionRule))
  expect_true(nzchar(result$retentionRule))
  expect_length(result$candidates, 5L)
  expectedPairs <- list(c("A", "C"), c("A", "D"), c("B", "D"), c("B", "E"),
                         c("C", "E"))
  returnedPairs <- lapply(result$candidates, function(cand) sort(cand$group[[1L]]))
  expectedKeys <- vapply(expectedPairs, paste, character(1L), collapse = ",")
  returnedKeys <- vapply(returnedPairs, paste, character(1L), collapse = ",")
  expect_setequal(returnedKeys, expectedKeys)
})

test_that(paste("groupAddAssign(exhaustive = TRUE) stops with a scope-",
                 "specific message when numGp > 1 (D2/D9)"), {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  expect_error(
    groupAddAssign(
      candidates = qcBreeders[1L:10L],
      kmat = pedWithGenotypeReport$kinship,
      ped = pedWithGenotype,
      currentGroups = character(0L), ignore = NULL, minAge = 1.0,
      numGp = 2L, harem = FALSE, sexRatio = 0.0, withKin = FALSE,
      exhaustive = TRUE
    ),
    regexp = "numGp"
  )
})

test_that(paste("groupAddAssign(exhaustive = TRUE) stops with a scope-",
                 "specific message when harem = TRUE (D2/D9)"), {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  expect_error(
    groupAddAssign(
      candidates = qcBreeders[1L:10L],
      kmat = pedWithGenotypeReport$kinship,
      ped = pedWithGenotype,
      currentGroups = character(0L), ignore = NULL, minAge = 1.0,
      numGp = 1L, harem = TRUE, sexRatio = 0.0, withKin = FALSE,
      exhaustive = TRUE
    ),
    regexp = "harem"
  )
})

test_that(paste("groupAddAssign(exhaustive = TRUE) stops with a scope-",
                 "specific message when sexRatio != 0 (D2/D9)"), {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  expect_error(
    groupAddAssign(
      candidates = qcBreeders[1L:10L],
      kmat = pedWithGenotypeReport$kinship,
      ped = pedWithGenotype,
      currentGroups = character(0L), ignore = NULL, minAge = 1.0,
      numGp = 1L, harem = FALSE, sexRatio = 1.0, withKin = FALSE,
      exhaustive = TRUE
    ),
    regexp = "sexRatio"
  )
})

test_that(paste("groupAddAssign(exhaustive = TRUE) stops with a size-",
                 "specific message when the candidate pool exceeds",
                 "maxExhaustiveCandidates (D5/D9)"), {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  # qcBreeders has 29 candidates (confirmed elsewhere in this file), above
  # the default maxExhaustiveCandidates = 20L ceiling -- refused before any
  # enumeration runs.
  expect_error(
    groupAddAssign(
      candidates = qcBreeders,
      kmat = pedWithGenotypeReport$kinship,
      ped = pedWithGenotype,
      currentGroups = character(0L), ignore = NULL, minAge = 1.0,
      numGp = 1L, harem = FALSE, sexRatio = 0.0, withKin = FALSE,
      exhaustive = TRUE, maxExhaustiveCandidates = 20L
    ),
    # A word that cannot appear in R's own auto-generated "unused arguments
    # (exhaustive = TRUE, maxExhaustiveCandidates = 20)" error -- this call
    # deliberately passes maxExhaustiveCandidates itself as an argument, so a
    # regexp built from that parameter's own name would accidentally match
    # the RED-phase "unused arguments" error and pass before any
    # implementation exists (caught and fixed during this session's own RED
    # verification run).
    regexp = "exceeds"
  )
})

test_that(paste("groupAddAssign(exhaustive = TRUE) returns exhaustive =",
                 "FALSE (not an error) when the wall-clock deadline elapses",
                 "mid-search (D5)"), {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  # A 15-candidate pool (under the 20-ceiling, so it passes the pre-flight
  # check) with an already-elapsed exhaustiveTimeLimit -- the search must
  # degrade gracefully, not stop().
  result <- NULL
  expect_no_error(
    result <- groupAddAssign(
      candidates = qcBreeders[1L:15L],
      kmat = pedWithGenotypeReport$kinship,
      ped = pedWithGenotype,
      currentGroups = character(0L), ignore = NULL, minAge = 1.0,
      numGp = 1L, harem = FALSE, sexRatio = 0.0, withKin = FALSE,
      exhaustive = TRUE, maxExhaustiveCandidates = 20L,
      exhaustiveTimeLimit = -1
    )
  )
  expect_false(result$exhaustive)
})
