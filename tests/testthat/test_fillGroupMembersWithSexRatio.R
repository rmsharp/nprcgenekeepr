#' Copyright(c) 2017-2020 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("fillGroupMembersWithSexRatio")

test_that(
  "fillGroupMembersWithSexRatio adds animals in the specified sex ratio", {
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
  numGp <- 1
  harem <- FALSE
  sexRatio <- 0
  withKin <- FALSE
  groupMembers <- makeGroupMembers(numGp, currentGroups, candidates, ped,
                                   harem = harem,
                                   minAge = minAge)
  groupMembersStart <- groupMembers
  grpNum <- nprcgenekeepr:::makeGrpNum(numGp)

  expect_equal(groupMembers[[1]], c("N54ICI", "VJ08BW", "2ZMHG7"))
  for (i in 1:20) {
    groupMembers <- fillGroupMembersWithSexRatio(
      candidates, groupMembers, grpNum, kin, ped, minAge, numGp, sexRatio = 1)
  }
  expect_equal(calculateSexRatio(groupMembers[[1]], ped), 1.0,
               tolerance = .1, scale = 1)
  groupMembers <- groupMembersStart

  for (i in 1:20) {
    groupMembers <- fillGroupMembersWithSexRatio(
      candidates, groupMembers, grpNum, kin, ped, minAge, numGp, sexRatio = 0.5)
  }
  expect_equal(calculateSexRatio(groupMembers[[1]], ped), 0.5,
               tolerance = .1, scale = 1)
  groupMembers <- groupMembersStart
  for (i in 1:20) {
    groupMembers <- fillGroupMembersWithSexRatio(
      candidates, groupMembers, grpNum, kin, ped, minAge, numGp, sexRatio = 2.0)
  }
  expect_equal(calculateSexRatio(groupMembers[[1]], ped), 2.0,
               tolerance = .1, scale = 1)
  expect_equal(calculateSexRatio(groupMembers[[1]], ped, additionalMales = 0,
                                 additionalFemales = 0), 2.0,
               tolerance = .1, scale = 1)

  })
