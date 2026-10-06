## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)
suppressMessages(library(dplyr))

qcPed <- nprcgenekeepr::qcPed
bkmat <- kinship(qcPed$id, qcPed$sire, qcPed$dam, qcPed$gen,
  sparse = FALSE
)
kin <- convertRelationships(bkmat, qcPed)
relClasses <- as.data.frame(makeRelationClassesTable(kin))
relClasses$`Relationship Class` <- as.character(relClasses$`Relationship Class`)
relClassTbl <- kin[!kin$relation == "Self", ] |>
  group_by(relation) |>
  summarise(count = n())
test_that("makeRelationsClasses retains the correct counts", {
  for (rel in relClasses[, "Relationship Class"]) {
    expect_identical(
      relClasses$Frequency[relClasses$`Relationship Class` == rel],
      relClassTbl$count[relClassTbl$relation == rel]
    )
  }
})

# NEW-19: record the table as it is, so moving the names to one list changes
# nothing a user sees.
smallPed <- nprcgenekeepr::smallPed
smallKin <- convertRelationships(
  kinship(smallPed$id, smallPed$sire, smallPed$dam, smallPed$gen,
    sparse = FALSE
  ),
  smallPed
)
smallClasses <- c(
  "Parent-Offspring", "Full-Siblings", "Half-Siblings",
  "Grandparent-Grandchild", "Full-Cousins", "Cousin - Other",
  "Full-Avuncular", "Avuncular - Other", "Other", "No Relation"
)

test_that("makeRelationClassesTable gives its rows in display order for smallPed", {
  tbl <- makeRelationClassesTable(smallKin)
  expect_identical(colnames(tbl), c("Relationship Class", "Frequency"))
  expect_true(is.factor(tbl[["Relationship Class"]]))
  expect_identical(as.character(tbl[["Relationship Class"]]), smallClasses)
  expect_identical(
    tbl$Frequency,
    c(19L, 4L, 7L, 13L, 2L, 3L, 6L, 10L, 4L, 68L)
  )
  expect_identical(
    rownames(tbl),
    c("10", "5", "7", "6", "4", "2", "3", "1", "9", "8")
  )
  expect_identical(sum(tbl$Frequency), sum(smallKin$relation != "Self"))
})

test_that("makeRelationClassesTable leaves out a pair whose name is not listed", {
  kin <- data.frame(
    id1 = letters[1:6], id2 = letters[7:12], kinship = 0.1,
    relation = c(
      "Parent-Offspring", "Full-Siblings", "Full-Siblings",
      "Full-Sibling", "Self", "No Relation"
    ),
    stringsAsFactors = FALSE
  )
  tbl <- makeRelationClassesTable(kin)
  expect_identical(
    as.character(tbl[["Relationship Class"]]),
    c("Parent-Offspring", "Full-Siblings", "No Relation")
  )
  expect_identical(tbl$Frequency, c(1L, 2L, 1L))
})

# Recorded, not endorsed: today the function stops when no pair is left once
# the Self pairs are removed, as with a table of Self pairs only or with no
# rows (found S918). kinship() itself fails on a one-animal pedigree, so the
# app does not reach it; a hand-built table does. NEW-19 does not change it.
test_that("makeRelationClassesTable stops today when only Self pairs are left", {
  selfOnly <- data.frame(
    id1 = c("a", "b"), id2 = c("a", "b"), kinship = 0.5,
    relation = "Self", stringsAsFactors = FALSE
  )
  expect_error(
    makeRelationClassesTable(selfOnly),
    "'names' attribute \\[2\\] must be the same length"
  )
  expect_error(
    makeRelationClassesTable(selfOnly[0, ]),
    "'names' attribute \\[2\\] must be the same length"
  )
})
