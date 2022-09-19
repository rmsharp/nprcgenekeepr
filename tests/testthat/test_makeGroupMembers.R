#' Copyright(c) 2017-2022 R. Mark Sharp
# This file is part of nprcgenekeepr
context("makeGroupMembers")
library(testthat)
library(nprcgenekeepr)
qcBreeders <- nprcgenekeepr::qcBreeders
pedWithGenotype <- nprcgenekeepr::pedWithGenotype
pedWithGenotypeReport <- nprcgenekeepr::pedWithGenotypeReport
skip_if_not(exists("qcBreeders"))
skip_if_not(exists("pedWithGenotype"))
skip_if_not(exists("pedWithGenotypeReport"))
set_seed(10)
test_that(paste0("makeGroupMembers fails when more than one potential sire ",
                 "exists in currentGroup and harem == TRUE."), {
  currentGroups <- list(1)
  currentGroups[[1]] <- qcBreeders
  expect_error(makeGroupMembers(
    numGp = 3, currentGroups = currentGroups,
    candidates = qcBreeders, ped = pedWithGenotype, harem = TRUE,
    minAge = 2), paste0("User selected to form harems with more than one ",
                        "male, There are 3 at least 2 years old in the ",
                        "current group."))
}
)

test_that(paste0("makeGroupMembers fails when the number of potential sires ",
                 "in candidates is less than the number of groups being ",
                 "formed, there is not a current group, and harem == TRUE."), {
  noSires <- removePotentialSires(ids = qcBreeders, minAge = 2,
                                  ped = pedWithGenotype)
  currentGroups <- list(1)
  expect_error(makeGroupMembers(
    numGp = 3, currentGroups = character(0),
    candidates = noSires,
    ped = pedWithGenotype, harem = TRUE,
    minAge = 2), paste0("User selected to form harems in 3 groups with only ",
                        "0 males at least 2 years old in the list of ",
                        "candidates."))
}
)

test_that(paste0(
  "makeGroupMembers initializes groupMembers correctly when the number of ",
  "potential sires in currentGroup is one and the candidate animals contain ",
  "one or more potential sires and harem == TRUE."), {
    currentGroups <- list(1)
    noSires <- removePotentialSires(ids = qcBreeders, minAge = 2,
                                    ped = pedWithGenotype)
    sires <- getPotentialSires(qcBreeders, minAge = 2, ped = pedWithGenotype)
    currentGroups[[1]] <- c(noSires[1:10], sires[1])
    candidates <- c(noSires[11:length(noSires)], sires[-1])
    groupMembers <- makeGroupMembers(
      numGp = 1, currentGroups = currentGroups, candidates = candidates,
      ped = pedWithGenotype, harem = TRUE, minAge = 2)
    expect_true(length(groupMembers) == 1)
    expect_equal(groupMembers[[1]], currentGroups[[1]])
  }
)
test_that(paste0(
  "makeGroupMembers initializes groupMembers correctly when ",
  "harem == TRUE, there are no animals in the currentGroup and the candidate ",
  "animals contain numGp or more potential sires"), {
    currentGroups <- character(0)
    candidates <- qcBreeders
    groupMembers <- makeGroupMembers(
      numGp = 3, currentGroups = currentGroups,
      candidates = candidates,
      ped = pedWithGenotype, harem = TRUE,
      minAge = 2)
    expect_true(length(groupMembers) == 3)
    expect_true(inherits(groupMembers[[1]][1], "character"))
    expect_equal(length(groupMembers[[1]][1]), 1)
  }
)
test_that(paste0(
  "makeGroupMembers initializes groupMembers correctly when the number of ",
  "potential sires in currentGroup is zero and the candidate animals contain ",
  "one or more potential sires"), {
    currentGroups <- list(1)
    noSires <- removePotentialSires(ids = qcBreeders, minAge = 2,
                                    ped = pedWithGenotype)
    sires <- getPotentialSires(qcBreeders, minAge = 2, ped = pedWithGenotype)
    currentGroups[[1]] <- c(noSires[1:10])
    candidates <- c(noSires[11:length(noSires)], sires)
    groupMembers <- makeGroupMembers(
      numGp = 1, currentGroups = currentGroups,
      candidates = candidates,
      ped = pedWithGenotype, harem = TRUE,
      minAge = 2)
    expect_equal(length(groupMembers), 1)
    expect_equal(length(groupMembers[[1]]), 11)
    expect_equal(groupMembers[[1]][-1],
                 c("Q0RGP7", "C1ICXL", "2KULR3", "RI0O7F", "7M51X5", "170ZTZ",
                   "CFPEEU", "CQC133", "ZC5SCR", "218FOV"))
  }
)
test_that(paste0(
  "makeGroupMembers initializes groupMembers correctly when the number of ",
  "potential sires in currentGroup is 1 and the candidate animals contain ",
  "no potential sires"), {
    currentGroups <- list(1)
    noSires <- removePotentialSires(ids = qcBreeders, minAge = 2,
                                    ped = pedWithGenotype)
    sires <- getPotentialSires(qcBreeders, minAge = 2, ped = pedWithGenotype)
    currentGroups[[1]] <- c(noSires[1:10], sires[1])
    candidates <- noSires[11:length(noSires)]
    groupMembers <- makeGroupMembers(
      numGp = 1, currentGroups = currentGroups,
      candidates = candidates,
      ped = pedWithGenotype, harem = TRUE,
      minAge = 2)
    expect_equal(length(groupMembers), 1)
    expect_equal(length(groupMembers[[1]]), 11)
    expect_equal(groupMembers[[1]], c(noSires[1:10], sires[1]))
  }
)

