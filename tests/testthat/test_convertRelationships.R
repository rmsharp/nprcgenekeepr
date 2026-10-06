## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
ped <- nprcgenekeepr::smallPed
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
ids <- c("A", "B", "D", "E", "F", "G", "I", "J", "L", "M", "O", "P")
relIds <- convertRelationships(kmat, ped, ids)
rel <- convertRelationships(kmat, ped, updateProgress = function() {})
ped <- nprcgenekeepr::qcPed
bkmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen,
  sparse = FALSE
)
relBIds <- convertRelationships(bkmat, ped, c("4LFS70", "DD1U77"))
test_that("convertRelationships makes correct transformations", {
  expect_identical(relIds$id1[relIds$id1 %in% rel$id1], relIds$id1)
  expect_true(all(rel$id1[rel$id1 %in% relIds$id1] %in% relIds$id1))
  expect_equal(rel$kinship[rel$id1 == "A" & rel$id2 == "D"], 0.25)
  expect_identical(
    rel$relation[rel$id1 == "D" & rel$id2 == "G"],
    "Parent-Offspring"
  )
  expect_identical(
    rel$relation[rel$id1 == "C" & rel$id2 == "I"],
    "Half-Siblings"
  )
  expect_identical(
    rel$relation[rel$id1 == "C" & rel$id2 == "J"],
    "No Relation"
  )
  expect_identical(
    rel$relation[rel$id1 == "C" & rel$id2 == "C"],
    "Self"
  )
  expect_identical(
    rel$relation[rel$id1 == "C" & rel$id2 == "G"],
    "Full-Avuncular"
  )
  expect_identical(
    relIds$relation[relIds$id1 == "A" & relIds$id2 == "B"],
    "No Relation"
  )
  expect_identical(
    relIds$relation[relIds$id1 == "A" & relIds$id2 == "F"],
    "Grandparent-Grandchild"
  )
  expect_identical(
    relIds$relation[relIds$id1 == "F" & relIds$id2 == "G"],
    "Full-Siblings"
  )
  expect_identical(
    relIds$relation[relIds$id1 == "F" & relIds$id2 == "I"],
    "Avuncular - Other"
  )
  expect_identical(
    relIds$relation[relIds$id1 == "F" & relIds$id2 == "L"],
    "Full-Cousins"
  )
  expect_identical(
    rel$relation[rel$id1 == "L" & rel$id2 == "P"],
    "Cousin - Other"
  )
  expect_identical(relBIds$relation[relBIds$id1 == "4LFS70" &
    relBIds$id2 == "DD1U77"], "Other")
})

# NEW-19: record how often each of the 11 names is given for smallPed, so
# moving the names to one list changes nothing a user sees.
test_that("convertRelationships gives each of the 11 names for smallPed", {
  counts <- table(rel$relation)
  expect_length(counts, 11L)
  expect_identical(
    as.integer(counts[c(
      "Self", "Parent-Offspring", "Full-Siblings", "Half-Siblings",
      "Grandparent-Grandchild", "Full-Cousins", "Cousin - Other",
      "Full-Avuncular", "Avuncular - Other", "Other", "No Relation"
    )]),
    c(17L, 19L, 4L, 7L, 13L, 2L, 3L, 6L, 10L, 4L, 68L)
  )
})

# S923 (BACKLOG finding of S918): ids that name fewer than two animals in the
# matrix. One animal gives its own Self row, the same row each animal already
# gets when two or more ids are given; no animal gives a table with no rows.
# Before, one id gave a row with id1 "kinMatrix" and id2 1, and no animal
# stopped with "no vector columns were selected".
oneIdPed <- nprcgenekeepr::smallPed
oneIdKmat <- kinship(oneIdPed$id, oneIdPed$sire, oneIdPed$dam, oneIdPed$gen,
  sparse = FALSE
)
aSelfRowOfTwoIds <- {
  twoIds <- convertRelationships(oneIdKmat, oneIdPed, c("A", "B"))
  twoIds[twoIds$id1 == "A" & twoIds$id2 == "A", ]
}
expectAsOwnSelfRow <- function(rel) {
  expect_identical(names(rel), c("id1", "id2", "kinship", "relation"))
  expect_identical(nrow(rel), 1L)
  expect_identical(rel$id1, aSelfRowOfTwoIds$id1)
  expect_identical(rel$id2, aSelfRowOfTwoIds$id2)
  expect_identical(rel$kinship, aSelfRowOfTwoIds$kinship)
  expect_identical(rel$relation, "Self")
}
expectNoRows <- function(rel) {
  expect_identical(names(rel), c("id1", "id2", "kinship", "relation"))
  expect_identical(nrow(rel), 0L)
  expect_identical(
    vapply(rel, class, ""),
    vapply(aSelfRowOfTwoIds, class, "")
  )
}

test_that("convertRelationships gives the animal's own Self row for one id", {
  expectAsOwnSelfRow(convertRelationships(oneIdKmat, oneIdPed, "A"))
})

test_that("convertRelationships gives that Self row when one id is in the matrix and one is not", {
  expectAsOwnSelfRow(convertRelationships(oneIdKmat, oneIdPed, c("A", "ZZZ")))
})

test_that("convertRelationships gives that Self row when the same id is given twice", {
  expectAsOwnSelfRow(convertRelationships(oneIdKmat, oneIdPed, c("A", "A")))
})

test_that("convertRelationships gives a table with no rows when no id is in the matrix", {
  expectNoRows(convertRelationships(oneIdKmat, oneIdPed, "ZZZ"))
})

test_that("convertRelationships gives a table with no rows when the id list is empty", {
  expectNoRows(convertRelationships(oneIdKmat, oneIdPed, character(0L)))
})
