## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## S1008 (BACKLOG.md:166; slice 6e finding CJ3, ruled S1004; the owner's PRE-RED
## answer: a male with no birth date is left out too). The same rule as
## test_fillGroupMembersWithSexRatioMalePools.R, one level up and on real data:
## the public function the Form Groups button calls, groupAddAssign(), on the
## bundled `qcPed`. Of its 89 living animals 54 are males, and 43 of those have
## no birth date (11 are at least a year old; none is younger). Two groups with
## 3 females per male asked used to put about 41 of those undated males in the
## groups, as if they were not male, and the groups came out near 0.7 females
## per male. With the rule, a group holds only males with a known age of at
## least `minAge`, and every male left out is in the last box, "Unused
## animals" (the group after the formed ones).
##
## The last three blocks fail until the fix. The first passes now: it checks
## that the file really holds living males with no birth date, so the others
## cannot pass for want of a case.

sexRatioRunOnQcPed <- local({
  cache <- NULL
  function() {
    if (is.null(cache)) {
      ped <- nprcgenekeepr::qcPed
      living <- ped$id[isLivingAnimal(ped)]
      kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
      set_seed(20261017L)
      cache <<- list(
        ped = ped,
        living = living,
        result = groupAddAssign(
          living, kmat, ped,
          threshold = 0.015625, minAge = 1.0, iter = 5L, numGp = 2L,
          sexRatio = 3, maxCandidates = 2L
        )
      )
    }
    cache
  }
})

## Every formed group (not the last, "Unused animals" box) of every retained
## solution, as one vector of ids.
formedGroupIds <- function(run, numGp = 2L) {
  unlist(lapply(run$result$candidates, function(solution) {
    solution$group[seq_len(numGp)]
  }))
}

livingMaleIds <- function(run, birthKnown) {
  ped <- run$ped
  male <- ped$id[ped$sex == sexCodes[["male"]]]
  hasBirth <- !is.na(ped$birth[match(male, ped$id)])
  intersect(run$living, male[hasBirth == birthKnown])
}

test_that("the bundled qcPed has living males with no birth date to test with", {
  run <- sexRatioRunOnQcPed()
  expect_equal(length(livingMaleIds(run, birthKnown = FALSE)), 43L)
  expect_equal(length(livingMaleIds(run, birthKnown = TRUE)), 11L)
})

test_that("groupAddAssign places no male who has no birth date", {
  run <- sexRatioRunOnQcPed()
  placed <- formedGroupIds(run)
  expect_equal(
    intersect(placed, livingMaleIds(run, birthKnown = FALSE)),
    character(0L)
  )
})

test_that("every male groupAddAssign places is at least minAge years old", {
  run <- sexRatioRunOnQcPed()
  placed <- unique(formedGroupIds(run))
  male <- placed[run$ped$sex[match(placed, run$ped$id)] == sexCodes[["male"]]]
  age <- getCurrentAge(run$ped$birth[match(male, run$ped$id)])
  expect_true(all(!is.na(age) & age >= 1.0))
})

test_that("each living male with no birth date is in the Unused animals box", {
  run <- sexRatioRunOnQcPed()
  unused <- run$result$group[[3L]]
  expect_true(all(livingMaleIds(run, birthKnown = FALSE) %in% unused))
})
