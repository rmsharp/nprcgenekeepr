#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("convertRelationships")
library(testthat)
ped <- nprcgenekeepr::smallPed
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
ids <- c("A", "B", "D", "E", "F", "G", "I", "J", "L", "M", "O", "P")
relIds <- convertRelationships(kmat, ped, ids)
rel <- convertRelationships(kmat, ped, updateProgress = function() {})
ped <- nprcgenekeepr::qcPed
bkmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen,
                 sparse = FALSE)
relBIds <- convertRelationships(bkmat, ped, c("4LFS70", "DD1U77"))
test_that("convertRelationships makes correct transformations", {
  expect_equal(relIds$id1[relIds$id1 %in% rel$id1], relIds$id1)
  expect_true(all(rel$id1[rel$id1 %in% relIds$id1] %in% relIds$id1))
  expect_equal(rel$kinship[rel$id1 == "A" & rel$id2 == "D"], 0.25)
  expect_equal(rel$relation[rel$id1 == "D" & rel$id2 == "G"],
               "Parent-Offspring")
  expect_equal(rel$relation[rel$id1 == "C" & rel$id2 == "I"],
               "Half-Siblings")
  expect_equal(rel$relation[rel$id1 == "C" & rel$id2 == "J"],
               "No Relation")
  expect_equal(rel$relation[rel$id1 == "C" & rel$id2 == "C"],
               "Self")
  expect_equal(rel$relation[rel$id1 == "C" & rel$id2 == "G"],
               "Full-Avuncular")
  expect_equal(relIds$relation[relIds$id1 == "A" & relIds$id2 == "B"],
               "No Relation")
  expect_equal(relIds$relation[relIds$id1 == "A" & relIds$id2 == "F"],
               "Grandparent-Grandchild")
  expect_equal(relIds$relation[relIds$id1 == "F" & relIds$id2 == "G"],
               "Full-Siblings")
  expect_equal(relIds$relation[relIds$id1 == "F" & relIds$id2 == "I"],
               "Avuncular - Other")
  expect_equal(relIds$relation[relIds$id1 == "F" & relIds$id2 == "L"],
               "Full-Cousins")
  expect_equal(rel$relation[rel$id1 == "L" & rel$id2 == "P"],
               "Cousin - Other")
  expect_equal(relBIds$relation[relBIds$id1 == "4LFS70" &
                                  relBIds$id2 == "DD1U77"], "Other")
})
