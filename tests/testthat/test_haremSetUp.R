## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Breeding Groups: harem trials redo their set-up work every
## trial" (owner pick S1072; the performance campaign's rules,
## docs/planning/performance-memory-campaign-plan.md sections 5 and 5.1). Each
## harem trial redid the same set-up: which groups still need a sire, the
## potential sires among the candidates and the candidates who are not
## potential sires, each found from the animals' ages through
## getPotentialSires(), about 9 calls a trial, every one asking
## lubridate::today() for the date (70% of a harem run in the S1072 profile).
## Only the draw of the sires differs from trial to trial. groupAddAssign() now
## builds the set-up once per call (makeHaremSetUp()) and each trial draws the
## sires from it (drawHaremGroups()), with the same groups for the same seed:
## test_groupAddAssignEquivalence.R compares groupAddAssign()'s whole result
## with a frozen copy of today's, and the blocks below compare the two helpers
## with today's initializeHaremGroups() and removePotentialSires() on ordinary
## and odd inputs. outcome() (helper-perfCampaign.R) records a call's value or
## error and its warnings under a seed.

seeds <- c(1L, 7L, 2026L)

## How many times groupAddAssign() asks getPotentialSires() for the potential
## sires while it forms 6 harems on the example's candidates. One grouping is
## kept, so the closing unused-animals step asks once for any number of trials.
potentialSireCalls <- function(iter) {
  input <- exampleGroupInput()
  real <- getPotentialSires
  calls <- 0L
  local_mocked_bindings(getPotentialSires = function(...) {
    calls <<- calls + 1L
    real(...)
  })
  withr::with_seed(1L, groupAddAssign(
    input$candidates, input$kmat, input$ped,
    iter = iter, numGp = 6L, harem = TRUE, maxCandidates = 1L
  ))
  calls
}

test_that("a harem run asks for the potential sires as often in 50 trials as in 2", {
  expect_identical(potentialSireCalls(50L), potentialSireCalls(2L))
})

## The start of a harem trial: the groups with their sires drawn, the
## candidates left to place, and the next random number (so a draw too many
## or too few shows). Today's code gets the first two from
## initializeHaremGroups() (its frozen copy, helper-perfReference.R) and
## removePotentialSires(); the new code from one set-up.
haremStartReference <- function(numGp, currentGroups, candidates, ped,
                                minAge) {
  list(
    groupMembers = initializeHaremGroupsReference(numGp, currentGroups,
                                                  candidates, ped, minAge),
    candidates = removePotentialSires(candidates, minAge, ped),
    nextDraw = stats::runif(1L)
  )
}

haremStart <- function(numGp, currentGroups, candidates, ped, minAge) {
  setUp <- nprcgenekeepr:::makeHaremSetUp(numGp, currentGroups, candidates,
                                          ped, minAge)
  list(
    groupMembers = nprcgenekeepr:::drawHaremGroups(setUp, numGp),
    candidates = setUp$nonSires,
    nextDraw = stats::runif(1L)
  )
}

## The arguments of a harem trial's start on the example: ordinary values
## unless named. The odd ones probe each argument the set-up reads.
haremStartCases <- function() {
  ex <- exampleGroupInput()
  cand <- ex$candidates
  sires <- getPotentialSires(cand, ex$ped, 1.0)
  others <- setdiff(cand, sires)
  args <- function(numGp = 6L, currentGroups = list(character(0L)),
                   candidates = cand, ped = ex$ped, minAge = 1.0) {
    list(numGp, currentGroups, candidates, ped, minAge)
  }
  unknownSex <- ex$ped
  unknownSex$sex[unknownSex$id %in% sires[1L:3L]] <- NA
  noBirth <- ex$ped
  noBirth$birth[noBirth$id %in% sires[1L:3L]] <- NA
  factorIds <- ex$ped
  factorIds$id <- factor(factorIds$id)
  list(
    `6 harems` = args(),
    `3 harems, a seeded sire who is also a candidate` = args(
      3L, list(sires[[1L]])
    ),
    `3 harems, a seeded sire who is not a candidate` = args(
      3L, list(sires[[1L]]), candidates = setdiff(cand, sires[[1L]])
    ),
    `3 harems, a seeded group without a sire` = args(3L, list(others[[1L]])),
    `3 harems, a seeded group with two sires` = args(3L, list(sires[1L:2L])),
    `96 harems for 96 sires` = args(96L),
    `97 harems for 96 sires` = args(97L),
    `more seeded groups than harems` = args(
      2L, list(sires[[1L]], others[[1L]], sires[[2L]])
    ),
    `two sires in a seeded group beyond the harems` = args(
      1L, list(others[[1L]], sires[1L:2L])
    ),
    `no current groups` = args(3L, list()),
    `a NULL seed group` = args(3L, list(NULL, sires[[1L]])),
    `number seeds` = args(3L, list(c(1, 2))),
    `1 harem` = args(1L),
    `no harems` = args(0L),
    `minAge 0` = args(minAge = 0),
    `minAge 30` = args(minAge = 30),
    `factor candidates` = args(candidates = factor(cand)),
    `number candidates` = args(candidates = seq_along(cand)),
    `a missing candidate` = args(candidates = c(cand, NA)),
    `repeated candidates` = args(candidates = c(cand, cand[1L:5L])),
    `named candidates` = args(
      candidates = stats::setNames(cand, paste0("n", seq_along(cand)))
    ),
    `no candidates` = args(candidates = character(0L)),
    `unknown sex among the sires` = args(ped = unknownSex),
    `no birth date for some sires` = args(ped = noBirth),
    `pedigree ids as a factor` = args(ped = factorIds)
  )
}

test_that("one set-up and a draw of the sires start a harem trial as today's code does", {
  cases <- haremStartCases()
  for (name in names(cases)) {
    for (seed in seeds) {
      expect_identical(
        outcome(haremStart, cases[[name]], seed),
        outcome(haremStartReference, cases[[name]], seed),
        info = sprintf("%s, seed %d", name, seed)
      )
    }
  }
})

## fillGroupMembers() handed the set-up, as groupAddAssign() now does.
fillWithSetUp <- function(candidates, currentGroups, kin, ped, harem, minAge,
                          numGp, sexRatio) {
  nprcgenekeepr:::fillGroupMembers(
    candidates, currentGroups, kin, ped, harem, minAge, numGp, sexRatio,
    nprcgenekeepr:::makeHaremSetUp(numGp, currentGroups, candidates, ped,
                                   minAge)
  )
}

test_that("fillGroupMembers() fills harems as today's code does, handed the set-up or not", {
  ex <- exampleGroupInput()
  exSire <- getPotentialSires(ex$candidates, ex$ped, 1.0)[[1L]]
  exPool <- setdiff(ex$candidates, exSire)
  breeders <- nprcgenekeepr::qcBreeders
  breedersPed <- nprcgenekeepr::pedWithGenotype
  fillArgs <- function(candidates, kmat, ped, numGp,
                       currentGroups = list(character(0L))) {
    list(candidates, currentGroups, defaultRelatives(candidates, kmat, ped),
         ped, TRUE, 1.0, numGp, 0.0)
  }
  cases <- list(
    `example, 6 harems` = fillArgs(ex$candidates, ex$kmat, ex$ped, 6L),
    `example, 3 harems, one seeded with a sire` = fillArgs(
      exPool, ex$kmat, ex$ped, 3L, list(exSire)
    ),
    `breeders, 2 harems` = fillArgs(
      breeders, nprcgenekeepr::pedWithGenotypeReport$kinship, breedersPed, 2L
    )
  )
  for (name in names(cases)) {
    for (seed in seeds) {
      reference <- outcome(fillGroupMembersReference, cases[[name]], seed)
      expect_identical(outcome(fillWithSetUp, cases[[name]], seed), reference,
                       info = sprintf("%s, handed the set-up, seed %d", name,
                                      seed))
      expect_identical(
        outcome(nprcgenekeepr:::fillGroupMembers, cases[[name]], seed),
        reference,
        info = sprintf("%s, building the set-up, seed %d", name, seed)
      )
    }
  }
})
