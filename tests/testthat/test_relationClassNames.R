## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# NEW-19: convertRelationships() gives the 11 relationship names and
# makeRelationClassesTable() lists them to put its rows in order. Both read the
# names from one internal list, relationClassNames, so a name cannot drift in
# one place and silently drop pairs from the table.

expectedNames <- c(
  "Self", "Parent-Offspring", "Full-Siblings", "Half-Siblings",
  "Grandparent-Grandchild", "Full-Cousins", "Cousin - Other",
  "Full-Avuncular", "Avuncular - Other", "Other", "No Relation"
)
expectedKeys <- c(
  "self", "parentOffspring", "fullSiblings", "halfSiblings",
  "grandparentGrandchild", "fullCousins", "cousinOther",
  "fullAvuncular", "avuncularOther", "other", "noRelation"
)
# 11 labels none of which is a real relationship name
swappedNames <- stats::setNames(sprintf("Class%02d", 1:11), expectedKeys)

ped <- nprcgenekeepr::smallPed
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
rel <- convertRelationships(kmat, ped)
# what each pair of rel is called when the list holds the swapped labels
swappedRelation <- unname(swappedNames[match(rel$relation, expectedNames)])

test_that("relationClassNames holds the 11 names in the table's display order", {
  expect_identical(
    relationClassNames,
    stats::setNames(expectedNames, expectedKeys)
  )
})

test_that("every name convertRelationships() gives is in the list and all 11 are given", {
  expect_true(all(rel$relation %in% relationClassNames))
  expect_setequal(unique(rel$relation), unname(relationClassNames))
})

test_that("convertRelationships() takes each name from the list", {
  testthat::local_mocked_bindings(
    relationClassNames = swappedNames,
    .package = "nprcgenekeepr"
  )
  swappedRel <- convertRelationships(kmat, ped)
  expect_identical(swappedRel$relation, swappedRelation)
  expect_identical(swappedRel[, c("id1", "id2", "kinship")],
                   rel[, c("id1", "id2", "kinship")])
})

test_that("makeRelationClassesTable() takes its names and their order from the list", {
  swappedKin <- rel
  swappedKin$relation <- swappedRelation
  testthat::local_mocked_bindings(
    relationClassNames = swappedNames,
    .package = "nprcgenekeepr"
  )
  tbl <- makeRelationClassesTable(swappedKin)
  expect_identical(
    as.character(tbl[["Relationship Class"]]),
    unname(swappedNames[-1L])
  )
  expect_false(swappedNames[["self"]] %in% tbl[["Relationship Class"]])
  expect_identical(tbl$Frequency, c(19L, 4L, 7L, 13L, 2L, 3L, 6L, 10L, 4L, 68L))
})
