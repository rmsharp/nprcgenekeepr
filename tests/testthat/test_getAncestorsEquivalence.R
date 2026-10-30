## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Prepare the 3.0.0 CRAN submission", plan Phase 2 (owner pick
## S1095, "Example+loops+skip 315"; docs/planning/cran-3.0.0-submission-plan.md
## section 3.4). The ancestor walk behind getAncestors(), findLoops() and
## countLoops() searched every id of the tree at each step (`id %in%
## names(ptree)`), so findLoops() and countLoops() on the shipped example took
## about 1.0 and 1.3 s, twice their 2.0.0 time (S1095, this Mac). S1095 has the
## walk look each animal up once. The owner's pick keeps every result, so each
## block compares the walk with a frozen copy of today's
## (getAncestorsOnPathReference(), helper-perfReference.R) using identical(),
## the error message included (outcome(), helper-perfCampaign.R).

## The walk's outcome for each id of a tree, today's code and the new.
walkOutcomes <- function(ids, ptree) {
  list(
    new = lapply(ids, function(id) {
      outcome(.getAncestorsOnPath, list(id, ptree, character(0L)))
    }),
    reference = lapply(ids, function(id) {
      outcome(getAncestorsOnPathReference, list(id, ptree, character(0L)))
    })
  )
}

test_that("the ancestor walk gives today's answer for every animal of the example", {
  ptree <- createPedTree(nprcgenekeepr::examplePedigree)
  got <- walkOutcomes(names(ptree), ptree)
  expect_identical(got$new, got$reference)
})

test_that("the ancestor walk gives today's answer for every animal of qcPed after qcStudbook()", {
  ped <- qcStudbook(nprcgenekeepr::qcPed, minSireAge = 0, minDamAge = 0,
                    reportChanges = FALSE, reportErrors = FALSE)
  ptree <- createPedTree(ped)
  got <- walkOutcomes(names(ptree), ptree)
  expect_identical(got$new, got$reference)
})

## Trees the package does not build itself, each walked from every id it holds
## and from ids it does not: NA, an absent id, "", numbers (which `[[` reads as
## positions) and a factor.
oddTrees <- function() {
  factorPed <- data.frame(
    id = c("a", "b", "c", "d"),
    sire = factor(c(NA, NA, "a", "c")),
    dam = factor(c(NA, NA, "b", "b"))
  )
  list(
    smallPedTree = nprcgenekeepr::smallPedTree,
    numberIds = list(`1` = list(sire = NA, dam = NA),
                     `2` = list(sire = NA, dam = NA),
                     `3` = list(sire = 1, dam = 2),
                     `4` = list(sire = 3, dam = 2)),
    factorParents = createPedTree(factorPed),
    nullEntry = list(a = list(sire = "b", dam = NA), b = NULL),
    emptyName = list(a = list(sire = "", dam = NA),
                     list(sire = NA, dam = NA)),
    cycle = list(a = list(sire = "b", dam = NA),
                 b = list(sire = "a", dam = NA)),
    duplicateNames = list(a = list(sire = "b", dam = NA),
                          b = list(sire = NA, dam = "c"),
                          b = list(sire = "x", dam = NA))
  )
}

test_that("the ancestor walk gives today's answer or error on trees the package does not build", {
  trees <- oddTrees()
  for (name in names(trees)) {
    ptree <- trees[[name]]
    ids <- c(as.list(names(ptree)),
             list(NA_character_, "zz", "", 3, 4, 99, factor("c")))
    got <- walkOutcomes(ids, ptree)
    expect_identical(got$new, got$reference, label = name)
  }
})
