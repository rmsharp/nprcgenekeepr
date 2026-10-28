## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "The performance campaign's nine fallbacks" (owner pick S1083,
## ruling "Text at the start"). A studbook whose ids are numbers (read.csv()
## reads number ids as integers) or factors names the same animals as one
## whose ids are text, but convertRelationships() and
## markerRealizedRelatednessVariance() sent it to today's code, which looks a
## parent's row up by its position: 64 of this file's 78 pairs got the wrong
## name with number ids, every pair of grandparents' kinds was "Other" with
## factor ids (36 s for 60 of the example's animals), and groupAddAssign()
## stopped with "subscript out of bounds". Each function now turns id, sire and
## dam, and the ids or candidates it is given, into text where it starts, so
## each must give exactly the text's answer, from the new code.

## Twelve animals over three generations whose ids are numbers that are not
## their row numbers, with every kind of pair convertRelationships() names
## but "Other": parents and offspring, full and half siblings, grandparents,
## full and other cousins, full and other avuncular pairs.
numberStudbook <- function() {
  ped <- data.frame(
    id = 101L:112L,
    sire = c(NA, NA, NA, NA, 101L, 101L, 101L, 103L, 105L, 105L, 107L, 107L),
    dam = c(NA, NA, NA, NA, 102L, 102L, 104L, 104L, 108L, 108L, 106L, 108L),
    sex = c("M", "F", "M", "F", "M", "F", "M", "F", "M", "F", "M", "F"),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  ped
}

## The example studbook as the app holds it, its ids, sires and dams renamed
## to numbers that are not row numbers (10000 plus a shuffled position): as
## numbers, as text and as factors, with the text's kinship matrix. Built once.
exampleIdVariants <- local({
  variants <- NULL
  function() {
    if (is.null(variants)) {
      ped <- exampleLivingPed()
      number <- withr::with_seed(7L, 10000L + sample.int(nrow(ped)))
      names(number) <- ped$id
      numbers <- ped
      for (h in c("id", "sire", "dam")) {
        numbers[[h]] <- unname(number[ped[[h]]])
      }
      text <- toCharacter(numbers)
      variants <<- list(number = numbers, text = text,
                        factor = pedIdsAsFactors(text),
                        kmat = pedigreeKinship(text))
    }
    variants
  }
})

## Today's code stopped: a call that reaches it fails instead of answering.
stopTodaysRelationships <- function(env = parent.frame()) {
  local_mocked_bindings(
    convertRelationshipsGeneral = function(...) {
      stop("today's convertRelationships() code ran")
    },
    .env = env
  )
}

test_that("convertRelationships() names number and factor ids as their text", {
  ped <- numberStudbook()
  text <- toCharacter(ped)
  kmat <- pedigreeKinship(text)
  expected <- convertRelationships(kmat, text)
  expect_identical(
    c(table(expected$relation)),
    c(`Avuncular - Other` = 5L, `Full-Avuncular` = 3L, `Full-Cousins` = 2L,
      `Full-Siblings` = 2L, `Grandparent-Grandchild` = 14L,
      `Half-Siblings` = 6L, `No Relation` = 18L, `Parent-Offspring` = 16L,
      Self = 12L)
  )
  ids <- c(105L, 108L, 109L, 110L, 111L, 112L)
  someIds <- convertRelationships(kmat, text, ids = as.character(ids))
  stopTodaysRelationships()
  expect_identical(convertRelationships(kmat, ped), expected)
  expect_identical(convertRelationships(kmat, pedIdsAsFactors(ped)), expected)
  expect_identical(convertRelationships(kmat, ped, ids = ids), someIds)
  expect_identical(convertRelationships(kmat, pedIdsAsFactors(ped),
                                        ids = factor(ids)), someIds)
})

test_that("convertRelationships() takes the example's number and factor ids as text", {
  ex <- exampleIdVariants()
  ids <- ex$text$id[ex$text$population][1L:60L]
  expected <- convertRelationships(ex$kmat, ex$text, ids = ids)
  stopTodaysRelationships()
  expect_identical(convertRelationships(ex$kmat, ex$number,
                                        ids = as.integer(ids)), expected)
  expect_identical(convertRelationships(ex$kmat, ex$factor, ids = ids),
                   expected)
})

test_that(paste("markerRealizedRelatednessVariance() gives number and factor",
                "ids the text's rows, without the table of every pair"), {
  ped <- numberStudbook()
  text <- toCharacter(ped)
  kmat <- pedigreeKinship(text)
  expected <- markerRealizedRelatednessVariance(kmat, text, nChr = 20L,
                                                mapLength = 28)
  expect_identical(nrow(expected), 24L)
  ex <- exampleIdVariants()
  ids <- ex$text$id[ex$text$population][1L:60L]
  expectedExample <- markerRealizedRelatednessVariance(
    ex$kmat, ex$text, nChr = 20L, mapLength = 28, ids = ids
  )
  ## The fallback for a pedigree its parent-link build is not made for runs
  ## convertRelationships() on every pair.
  local_mocked_bindings(convertRelationships = function(...) {
    stop("convertRelationships() ran on every pair")
  })
  stopTodaysRelationships()
  expect_identical(markerRealizedRelatednessVariance(kmat, ped, nChr = 20L,
                                                     mapLength = 28),
                   expected)
  expect_identical(markerRealizedRelatednessVariance(kmat, pedIdsAsFactors(ped),
                                                     nChr = 20L,
                                                     mapLength = 28),
                   expected)
  expect_identical(markerRealizedRelatednessVariance(
    ex$kmat, ex$number, nChr = 20L, mapLength = 28, ids = as.integer(ids)
  ), expectedExample)
  expect_identical(markerRealizedRelatednessVariance(
    ex$kmat, ex$factor, nChr = 20L, mapLength = 28, ids = factor(ids)
  ), expectedExample)
})

test_that("groupAddAssign() fills groups from number and factor ids as from text", {
  ex <- exampleIdVariants()
  candidates <- ex$text$id[isLivingAnimal(ex$text)][1L:120L]
  fill <- function(candidates, ped, sexRatio, currentGroups) {
    withr::with_seed(1L, groupAddAssign(
      candidates, ex$kmat, ped, currentGroups = currentGroups, iter = 5L,
      numGp = 3L, sexRatio = sexRatio
    ))
  }
  cases <- list(
    `no sex ratio` = list(sexRatio = 0, seeds = list(character(0L))),
    `sex ratio 1` = list(sexRatio = 1, seeds = list(character(0L))),
    `a seeded group` = list(sexRatio = 0, seeds = list(candidates[1L:2L]))
  )
  expected <- lapply(cases, function(case) {
    fill(candidates, ex$text, case$sexRatio, case$seeds)
  })
  local_mocked_bindings(
    fillGroupMembersGeneral = function(...) {
      stop("today's fillGroupMembers() code ran")
    },
    fillGroupMembersWithSexRatioGeneral = function(...) {
      stop("today's fillGroupMembersWithSexRatio() code ran")
    }
  )
  for (name in names(cases)) {
    case <- cases[[name]]
    expect_identical(
      fill(as.integer(candidates), ex$number, case$sexRatio,
           lapply(case$seeds, as.integer)),
      expected[[name]], info = paste("number ids,", name)
    )
    expect_identical(
      fill(factor(candidates), ex$factor, case$sexRatio,
           lapply(case$seeds, factor)),
      expected[[name]], info = paste("factor ids,", name)
    )
  }
})

test_that("makeCEPH() gives number and factor ids the text's pedigree", {
  ped <- numberStudbook()
  text <- toCharacter(ped)
  expected <- makeCEPH(text$id, text$sire, text$dam)
  expect_identical(expected[["109"]],
                   list(parents = c("105", "108"), pgp = c("101", "102"),
                        mgp = c("103", "104")))
  expect_identical(makeCEPH(ped$id, ped$sire, ped$dam), expected)
  factors <- pedIdsAsFactors(ped)
  expect_identical(makeCEPH(factors$id, factors$sire, factors$dam), expected)
})
