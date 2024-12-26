#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("addAnimalsWithNoRelative")
library(testthat)
library(stringi)
examplePedigree <- nprcgenekeepr::examplePedigree
ped <- qcStudbook(examplePedigree, minParentAge = 2, reportChanges = FALSE,
                 reportErrors = FALSE)
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
currentGroups <- list(1)
currentGroups[[1]] <- examplePedigree$id[1:3]
candidates <- examplePedigree$id[examplePedigree$status == "ALIVE"]
threshold <- 0.015625
kin <- getAnimalsWithHighKinship(kmat, ped, threshold, currentGroups,
                                ignore = list(c("F", "F")), minAge = 1)
# Filtering out candidates related to current group members
conflicts <- unique(c(unlist(kin[unlist(currentGroups)]),
                                unlist(currentGroups)))
candidates <- setdiff(candidates, conflicts)
kin <- addAnimalsWithNoRelative(kin, candidates)

test_that("addAnimalsWithNoRelative adds correct animals", {
  expect_equal(length(kin), 2416)
  expect_equal(length(kin[["1SPLS8"]]), 14)
})
