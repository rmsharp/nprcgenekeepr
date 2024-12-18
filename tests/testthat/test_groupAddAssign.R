#' Copyright(c) 2017-2020 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("groupAddAssign")
library(testthat)
library(nprcgenekeepr)
qcBreeders <- nprcgenekeepr::qcBreeders
pedWithGenotype <- nprcgenekeepr::pedWithGenotype
pedWithGenotypeReport <- nprcgenekeepr::pedWithGenotypeReport
skip_if_not(exists("qcBreeders"))
skip_if_not(exists("pedWithGenotype"))
skip_if_not(exists("pedWithGenotypeReport"))
set_seed(10)
test_that("groupAddAssign forms the correct groups", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  currentGroups <- list(1)
  currentGroups[[1]] <- qcBreeders[1:3]
  groupAddTest <- groupAddAssign(
    candidates = qcBreeders,
    currentGroups = currentGroups,
    kmat = pedWithGenotypeReport$kinship,
    ped = pedWithGenotype,
    ignore = NULL, minAge = 1, numGp = 1,
    harem = FALSE, sexRatio = 0, withKin = FALSE)
  expect_equal(length(groupAddTest$group[[1]]), 11)
  expect_equal(length(groupAddTest$group[[2]]), 14)
  #expect_equal(length(groupAddTest$group[[2]]), 10)
  expect_null(groupAddTest$groupKin[[1]])
}
)
set_seed(10)
test_that("groupAddAssign (numGp = 2) forms the correct groups", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  groupAssignTest <- groupAddAssign(
    candidates = qcBreeders,
    currentGroups = character(0),
    kmat = pedWithGenotypeReport$kinship,
    ped = pedWithGenotype,
    ignore = NULL,
    minAge = 1,
    numGp = 2,
    harem = FALSE,
    sexRatio = 0,
    withKin = FALSE
  )
  expect_equal(length(groupAssignTest$group[[1]]), 9)
  #expect_equal(length(groupAssignTest$group[[2]]), 10)
  expect_equal(length(groupAssignTest$group[[2]]), 9)
  expect_null(groupAssignTest$groupKin[[1]])
})
set_seed(10)
test_that(paste0("groupAddAssign (numGp = 1) forms the correct groups with ",
                 "kinship matrices"),
          {
            skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
            currentGroups <- list(1)
            currentGroups[[1]] <- qcBreeders[1:3]
            groupAddKTest <- groupAddAssign(
              candidates = qcBreeders,
              currentGroups = currentGroups,
              kmat = pedWithGenotypeReport$kinship,
              ped = pedWithGenotype,
              ignore = NULL,
              minAge = 1,
              numGp = 1,
              harem = FALSE,
              sexRatio = 0,
              withKin = TRUE
            )
            expect_equal(length(groupAddKTest$group[[1]]), 11)
            expect_equal(length(groupAddKTest$group[[2]]), 14)
            #expect_equal(length(groupAddKTest$group[[2]]), 10)
          })
set_seed(10)
test_that("groupAddAssign forms the correct groups with kinship matrices", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  groupAssignKTest <- groupAddAssign(
    candidates = qcBreeders,
    currentGroups = character(0),
    kmat = pedWithGenotypeReport$kinship,
    ped = pedWithGenotype,
    ignore = NULL,
    minAge = 1,
    numGp = 2,
    harem = FALSE,
    sexRatio = 0,
    withKin = TRUE
  )
  expect_equal(length(groupAssignKTest$group[[1]]), 9)
  expect_equal(length(groupAssignKTest$group[[2]]), 9)
  #expect_equal(length(groupAssignKTest$group[[2]]), 10)
  expect_equal(length(groupAssignKTest$groupKin[[1]]), 81)
})
set_seed(10)
noSires <- removePotentialSires(qcBreeders, minAge = 2,
                                pedWithGenotype)
sires <- getPotentialSires(qcBreeders, minAge = 2, pedWithGenotype)

test_that(paste0(
  "groupAddAssign fails when no potential sires exist for harem creation"
),
{
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  expect_error(
    groupAddAssign(
      candidates = noSires,
      currentGroups = character(0),
      kmat = pedWithGenotypeReport$kinship,
      ped = pedWithGenotype,
      ignore = NULL,
      minAge = 1,
      numGp = 2,
      harem = TRUE,
      sexRatio = 0,
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
      currentGroups = character(0),
      kmat = pedWithGenotypeReport$kinship,
      ped = pedWithGenotype,
      ignore = NULL,
      minAge = 1,
      numGp = 2,
      harem = TRUE,
      sexRatio = 0,
      withKin = TRUE
    )
    expect_true(length(group) == 3)
    expect_equal(sum(seq_along(group[[1]][[3]])[group[[1]][[3]] %in% sires]), 0)
    expect_equal(sum(seq_along(group[[1]][[3]])[group[[1]][[2]] %in% sires]), 1)
  }
)
test_that(
  paste0(
    "groupAddAssign fails when there are more groups with seed animals that ",
    "the number of groups to be formed"
  ),
  {
    skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
    currentGroups <- list(3)
    currentGroups[[1]] <- qcBreeders[1:3]
    currentGroups[[2]] <- qcBreeders[4:6]
    currentGroups[[3]] <- qcBreeders[7:9]
    expect_error(
      groupAddAssign(
        candidates = noSires,
        currentGroups = currentGroups,
        kmat = pedWithGenotypeReport$kinship,
        ped = pedWithGenotype,
        ignore = NULL,
        minAge = 1,
        numGp = 2,
        harem = FALSE,
        sexRatio = 0,
        withKin = TRUE
      )
    )
  }
)
