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
