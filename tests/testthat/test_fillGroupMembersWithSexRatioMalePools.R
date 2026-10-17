## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## S1008 (BACKLOG.md:166; docs-audit part 2, slice 6e finding CJ3; the owner
## ruled S1004: fix, and answered the PRE-RED scope question "leave them out
## too"). With a sex ratio set, fillGroupMembersWithSexRatio() built its
## "female" pool as every candidate that was not a potential sire, and a
## potential sire is a male with a birth date who is at least `minAge` old
## (getPotentialSires()). So a male younger than `minAge`, and a male with no
## birth date, were placed in a group as if they were not male, while
## calculateSexRatio() counted them as males: the ratio asked for was not the
## ratio the group had. The rule now: a male is placed only as a known adult
## male; a younger male or one with no birth date is left out (it ends in the
## "Unused animals" box); females and animals of unknown sex are placed as
## before.
##
## The pedigree is built here, so none of this depends on the bundled data
## (no bundled file has a living male under a year old; two have 43 living
## males with no birth date). It holds 4 adult males, 3 males 110 days old, 3
## males with no birth date, 10 females and 1 animal of unknown sex, none of
## them related, so the kinship step plays no part. The first four blocks fail
## until the fix; the last two pass before and after it and keep the fix from
## taking the wrong animals (the females and the unknown-sex animal stay in, and
## the age line stays `minAge`).

malePoolPedigree <- function() {
  today <- Sys.Date()
  adultMales <- paste0("AM", 1:4)
  youngMales <- paste0("YM", 1:3)
  undatedMales <- paste0("NM", 1:3)
  females <- sprintf("F%02d", 1:10)
  unknown <- "U01"
  ped <- data.frame(
    id = c(adultMales, youngMales, undatedMales, females, unknown),
    sire = NA_character_,
    dam = NA_character_,
    sex = c(rep("M", 10L), rep("F", 10L), "U"),
    stringsAsFactors = FALSE
  )
  ped$birth <- c(
    rep(today - 5L * 365L, 4L),
    rep(today - 110L, 3L),
    rep(as.Date(NA), 3L),
    rep(today - 4L * 365L, 10L),
    today - 3L * 365L
  )
  ped
}

malePoolIds <- list(
  adultMales = paste0("AM", 1:4),
  youngMales = paste0("YM", 1:3),
  undatedMales = paste0("NM", 1:3),
  females = sprintf("F%02d", 1:10),
  unknown = "U01"
)

## `runs` fills of two groups from every animal in the pedigree.
fillRuns <- function(minAge = 1.0, sexRatio = 2.0, runs = 40L) {
  ped <- malePoolPedigree()
  candidates <- ped$id
  kin <- addAnimalsWithNoRelative(list(), candidates)
  numGp <- 2L
  set_seed(20261017L)
  lapply(seq_len(runs), function(i) {
    fillGroupMembersWithSexRatio(
      candidates, rep(list(character(0L)), numGp), makeGroupNum(numGp),
      kin, ped, minAge, numGp, sexRatio
    )
  })
}

placedIn <- function(runs) unique(unlist(runs))

test_that("a male younger than minAge is never placed when a sex ratio is set", {
  placed <- placedIn(fillRuns())
  expect_equal(intersect(placed, malePoolIds$youngMales), character(0L))
})

test_that("a male with no birth date is never placed when a sex ratio is set", {
  placed <- placedIn(fillRuns())
  expect_equal(intersect(placed, malePoolIds$undatedMales), character(0L))
})

## An absolute margin, not `tolerance =` (relative to the value found): 40 runs
## of two groups asked for 2.0 gave a mean of 1.43 before the fix and 1.78
## after it.
test_that("the ratio a group has is the ratio that was asked for", {
  ped <- malePoolPedigree()
  runs <- fillRuns(sexRatio = 2.0)
  shown <- unlist(lapply(runs, function(groups) {
    vapply(groups, calculateSexRatio, numeric(1L), ped = ped)
  }))
  expect_lt(abs(mean(shown) - 2.0), 0.35)
})

## Before the fix 16 of the 80 groups held no known adult male: their "males"
## were the young and undated ones, placed through the female pool.
test_that("every group gets at least one known adult male", {
  runs <- fillRuns()
  adultsPerGroup <- unlist(lapply(runs, function(groups) {
    vapply(groups, function(g) sum(g %in% malePoolIds$adultMales), integer(1L))
  }))
  expect_true(all(adultsPerGroup >= 1L))
})

test_that("females and the animal of unknown sex are still placed", {
  placed <- placedIn(fillRuns())
  expect_true(all(c(malePoolIds$females, malePoolIds$unknown) %in% placed))
})

test_that("the age line is minAge: at 0.1 years a 110-day-old male is placed", {
  placed <- placedIn(fillRuns(minAge = 0.1))
  expect_true(all(malePoolIds$youngMales %in% placed))
})
