#' Copyright(c) 2017-2022 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("fillGroupMembers")


test_that("fillGroupMembers adds animals in the specified sex ratio", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "msharp")
  examplePedigree <- nprcgenekeepr::examplePedigree
  set_seed(10)
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

  ignore <- NULL
  minAge <- 1
  harem <- FALSE
  numGp <- 1
  withKin <- FALSE

  sexRatio <- 0
  groupMembers <- fillGroupMembers(candidates, currentGroups, kin, ped, harem,
                                   minAge, numGp, sexRatio)
  expect_equal(groupMembers[[1]][1:3], c("N54ICI", "VJ08BW", "2ZMHG7"))
  expect_equal(calculateSexRatio(groupMembers[[1]], ped), 52.5,
               tolerance = .1, scale = 1)
  sexRatio <- 1
  groupMembers <- fillGroupMembers(candidates, currentGroups, kin, ped, harem,
                                   minAge, numGp, sexRatio)
  expect_equal(groupMembers[[1]][1:4],
               c("N54ICI", "VJ08BW", "2ZMHG7", "CS23RV"))
  expect_equal(calculateSexRatio(groupMembers[[1]], ped), 1.0,
               tolerance = .1, scale = 1)
})

