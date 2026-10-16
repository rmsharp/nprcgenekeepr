## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## S1006 RED (BACKLOG.md:166; slice 6e Finding 2, N1; the owner ruled S1004 to
## fix it and chose, at the S1006 scope question, "one sentence only"):
## reportMatePairs() dropped only male-male and female-female pairs, so an
## animal whose sex is not "M" or "F" ("U" unknown, "H" hermaphrodite) was
## listed as a dam, or as the sire when the matrix put it first, and was paired
## with itself (R/reportMatePairs.R:198-211). The fix pairs only animals
## recorded as male or female. An animal left out appears in neither table (the
## Excluded reasons stay the three they were); the Mate Pair page says how many
## were left out (test_modMatePair.R), and a small internal function lists
## them, matePairLeftOutIds(), so the function and the page cannot disagree.
##
## Fixture: four unrelated founders recorded M or F and three animals that are
## not (U, H and a blank sex, which qcStudbook() never leaves but a script can).
## Every kinship is 0, so the tests are about who is paired, not about kinship.

unsexedPed <- function() {
  data.frame(
    id = c("M1", "M2", "F1", "F2", "U1", "H1", "N1"),
    sire = NA_character_,
    dam = NA_character_,
    sex = c("M", "M", "F", "F", "U", "H", NA),
    age = 10,
    stringsAsFactors = FALSE
  )
}

unsexedKmat <- function(ped) {
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  kinship(ped$id, ped$sire, ped$dam, ped$gen)
}

keyOf <- function(pairsFrame) {
  paste(pairsFrame$sireId, pairsFrame$damId, sep = "|")
}

leftOut <- c("U1", "H1", "N1")

test_that("the pairs are male x female only when some animals are not recorded as male or female", {
  ped <- unsexedPed()
  res <- reportMatePairs(ped, unsexedKmat(ped), minAge = 1)

  expect_setequal(keyOf(res$pairs), c("M1|F1", "M1|F2", "M2|F1", "M2|F2"))
  expect_identical(nrow(res$pairs), 4L)
  expect_true(all(ped$sex[match(res$pairs$sireId, ped$id)] %in% "M"))
  expect_true(all(ped$sex[match(res$pairs$damId, ped$id)] %in% "F"))
})

test_that("no animal is paired with itself", {
  ped <- unsexedPed()
  res <- reportMatePairs(ped, unsexedKmat(ped), minAge = 1)

  expect_false(any(res$pairs$sireId == res$pairs$damId))
})

test_that("an animal left out appears in neither table and the excluded reasons stay the same", {
  ped <- unsexedPed()
  res <- reportMatePairs(ped, unsexedKmat(ped), minAge = 1, exclude = "M2")

  expect_setequal(keyOf(res$pairs), c("M1|F1", "M1|F2"))
  expect_setequal(keyOf(res$excluded), c("M2|F1", "M2|F2"))
  expect_setequal(unique(res$excluded$reason), "user-excluded")
  shown <- c(res$pairs$sireId, res$pairs$damId,
             res$excluded$sireId, res$excluded$damId)
  expect_false(any(leftOut %in% shown))
})

test_that("a population naming one unsexed animal pairs only the animals recorded male or female", {
  ped <- unsexedPed()
  res <- reportMatePairs(ped, unsexedKmat(ped), minAge = 1,
                         populationIds = c("M1", "F1", "U1"))

  expect_identical(keyOf(res$pairs), "M1|F1")
})

test_that("a population of only unsexed animals gives the usual empty result, not an error", {
  ped <- unsexedPed()
  res <- reportMatePairs(ped, unsexedKmat(ped), minAge = 1,
                         populationIds = c("U1", "H1"))

  expect_named(res, c("pairs", "excluded"))
  expect_identical(nrow(res$pairs), 0L)
  expect_identical(nrow(res$excluded), 0L)
  expectedCols <- c("sireId", "damId", "kinship", "markerKinship",
                    "sireIndivMeanKin", "sireGu", "damIndivMeanKin", "damGu")
  expect_identical(names(res$pairs), expectedCols)
})

test_that("an id the kinship matrix holds but the pedigree does not list is left out without an error", {
  ped <- unsexedPed()[1:4, ]
  kmat <- unsexedKmat(ped)
  pedWithoutF2 <- ped[ped$id != "F2", ]
  res <- reportMatePairs(pedWithoutF2, kmat, minAge = 1)

  expect_setequal(keyOf(res$pairs), c("M1|F1", "M2|F1"))
})

## -- the list of animals left out -------------------------------------------

test_that("matePairLeftOutIds() lists every animal not recorded as male or female", {
  ped <- unsexedPed()
  ids <- matePairLeftOutIds(ped, unsexedKmat(ped))

  expect_setequal(ids, leftOut)
  expect_length(ids, 3L)
})

test_that("matePairLeftOutIds() counts only the animals of the population", {
  ped <- unsexedPed()
  kmat <- unsexedKmat(ped)

  expect_setequal(
    matePairLeftOutIds(ped, kmat, populationIds = c("M1", "U1", "N1")),
    c("U1", "N1")
  )
  expect_identical(
    matePairLeftOutIds(ped, kmat, populationIds = character(0L)),
    character(0L)
  )
  expect_identical(
    matePairLeftOutIds(ped, kmat, populationIds = c("M1", "ZZ")),
    character(0L)
  )
})

test_that("matePairLeftOutIds() is empty when every animal is recorded male or female", {
  ped <- unsexedPed()[1:4, ]

  expect_identical(matePairLeftOutIds(ped, unsexedKmat(ped)), character(0L))
})

test_that("matePairLeftOutIds() counts an id the pedigree does not list", {
  ped <- unsexedPed()
  kmat <- unsexedKmat(ped)
  ids <- matePairLeftOutIds(ped[ped$id != "F2", ], kmat)

  expect_setequal(ids, c("F2", leftOut))
})

## -- the help ----------------------------------------------------------------

mateHelpPlaces <- helpPlaces("reportMatePairs", "reportMatePairs.R")
helpSentences <- c(
  "Only animals recorded as male (\"M\") or female (\"F\") are paired.",
  "appears in neither pairs nor excluded"
)

for (place in names(mateHelpPlaces)) {
  test_that(paste0("the reportMatePairs() help says who is left out (", place, ")"), {
    skipUnlessHelpInSourceTree(mateHelpPlaces)
    text <- mateHelpPlaces[[place]]()
    expectWording(text, now = helpSentences, gone = character(0L))
  })
}
