## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S985; BACKLOG.md:156, found S983): groupAddAssign(harem = TRUE) with a
## non-zero sexRatio ran without a message and formed groups of one or two
## animals. fillGroupMembers() takes every potential sire out of the pool for a
## harem, so fillGroupMembersWithSexRatio() has no male to add, and its
## removeGroupIfNoAvailableAnimals(grpNum, availableMales) drops every group
## after the first placement.
## On the 332 living animals of the example pedigree (threshold 0.25, minimum
## age 1, 5 iterations), 3 groups and a ratio of 5 formed sizes 1, 1 and 2 in
## 5 of 5 seeds, one animal beyond the three sires; 1 group gave 2 animals in 3
## of 3 seeds; ratios 1 and 20 gave the same shape in 3 of 3 seeds. A harem
## alone formed about 70 animals per group and a ratio of 5 alone formed 81 to
## 90 animals per group with 14 or 15 males, so only the combination fails. The
## app cannot reach it (its radio takes Harem or Custom, never both), and the
## Breeding Groups article already says harem and sexRatio "are alternative
## strategies -- use one or the other".
## The owner ruled (S985): the combination stops, before anything is formed,
## with a message that names both settings and the ratio given, as exhaustive
## mode already does for the settings it cannot take.
##
## The pedigree is small and built by haremFixturePedigree()
## (helper-haremPedigree.R, shared with test_haremPartialSeeds.R): six
## unrelated adult males M1-M5 and MR, eight unrelated adult females F1-F8, and
## FR, a young female whose sire is MR (kinship 0.25, at the Max kinship used
## below). Female-female kinship is ignored (the app's setting).
##
## Guards that pass at HEAD and must still pass: a harem alone and a ratio
## alone form the same groups for the same seed, exhaustive mode keeps its own
## messages, and too few males still stops with the existing message.

stopPedData <- haremFixturePedigree()
stopKmat <- haremFixtureKinship(stopPedData)
stopFemales <- paste0("F", 1:8)

formHaremRatio <- function(sexRatio, numGp = 3L, seed = 1L, harem = TRUE,
                           currentGroups = list(character(0L)),
                           candidates = stopPedData$id, ...) {
  set_seed(seed)
  groupAddAssign(
    candidates = candidates, kmat = stopKmat, ped = stopPedData,
    currentGroups = currentGroups, threshold = 0.25,
    ignore = list(c("F", "F")), minAge = 1, iter = 5L, numGp = numGp,
    harem = harem, sexRatio = sexRatio, ...
  )
}

## The message of the stop, or NA_character_ when the run did not stop (the
## failing expectation says so).
stopMessage <- function(...) {
  res <- tryCatch(formHaremRatio(...), error = function(e) e)
  if (inherits(res, "error")) conditionMessage(res) else NA_character_
}

## The formed groups, each sorted, without the unused-animals box.
formedGroups <- function(res, numGp) {
  lapply(res$group[seq_len(numGp)], sort)
}

test_that(paste(
  "a harem with a custom sex ratio stops and the message names both",
  "settings and the ratio given"
), {
  for (ratio in c(0.5, 2, 5, 20)) {
    for (numGp in c(1L, 3L)) {
      info <- paste0("sexRatio ", ratio, ", ", numGp, " group(s)")
      msg <- stopMessage(ratio, numGp = numGp)
      expect_false(is.na(msg), info = paste(info, "- the run did not stop"))
      if (is.na(msg)) next
      expect_match(msg, "harem", fixed = TRUE, info = info)
      expect_match(msg, "sexRatio", fixed = TRUE, info = info)
      expect_match(msg, as.character(ratio), fixed = TRUE, info = info)
    }
  }
})

test_that("a seeded male does not let a harem take a custom sex ratio", {
  seeds <- list("M1", character(0L), character(0L))
  for (seed in 1L:3L) {
    info <- paste("seed", seed)
    msg <- stopMessage(5, seed = seed, currentGroups = seeds)
    expect_false(is.na(msg), info = paste(info, "- the run did not stop"))
    if (is.na(msg)) next
    expect_match(msg, "harem", fixed = TRUE, info = info)
    expect_match(msg, "sexRatio", fixed = TRUE, info = info)
  }
})

test_that("a ratio of either sign other than zero stops a harem", {
  msg <- stopMessage(-1)
  expect_false(is.na(msg), info = "sexRatio -1 - the run did not stop")
  if (!is.na(msg)) {
    expect_match(msg, "harem", fixed = TRUE)
    expect_match(msg, "sexRatio", fixed = TRUE)
  }
})

test_that("the stop comes before any group is formed", {
  testthat::local_mocked_bindings(
    fillGroupMembers = function(...) stop("fillGroupMembers was reached"),
    .package = "nprcgenekeepr"
  )
  msg <- stopMessage(5)
  expect_false(is.na(msg), info = "the run did not stop")
  if (!is.na(msg)) {
    expect_false(grepl("was reached", msg, fixed = TRUE),
      info = paste("the stop came after forming began:", msg)
    )
    expect_match(msg, "sexRatio", fixed = TRUE)
  }
})

test_that("a harem alone forms one-male harems with the same groups as before", {
  expected <- list(
    `1` = list(
      c("F2", "F3", "F6", "M5"), c("F7", "F8", "FR", "M3"),
      c("F1", "F4", "F5", "MR")
    ),
    `2` = list(
      c("F2", "F3", "M3"), c("F5", "F7", "M5"),
      c("F1", "F4", "F6", "F8", "FR", "M1")
    )
  )
  for (seed in 1L:2L) {
    res <- formHaremRatio(0, numGp = 3L, seed = seed)
    found <- formedGroups(res, 3L)
    expect_true(sameGroups(found, expected[[as.character(seed)]]),
      info = paste("seed", seed)
    )
    expect_equal(
      vapply(found, function(g) sum(grepl("^M", g)), integer(1L)),
      c(1L, 1L, 1L),
      info = paste("seed", seed)
    )
  }
})

test_that("a custom sex ratio alone forms the same groups as before", {
  expected <- list(
    `1` = list(
      c("F1", "F4", "F5", "M1", "M3", "MR"),
      c("F3", "F8", "M2", "M4", "M5")
    ),
    `2` = list(
      c("F7", "FR", "M3", "M4", "M5"),
      c("F2", "F3", "M1", "M2", "MR")
    )
  )
  for (seed in 1L:2L) {
    res <- formHaremRatio(1, numGp = 2L, seed = seed, harem = FALSE)
    expect_true(
      sameGroups(formedGroups(res, 2L), expected[[as.character(seed)]]),
      info = paste("seed", seed)
    )
  }
})

test_that("exhaustive mode keeps its own messages for harem and for a ratio", {
  expect_error(
    formHaremRatio(5, numGp = 1L, exhaustive = TRUE),
    "Exhaustive mode does not support harem group formation."
  )
  expect_error(
    formHaremRatio(5, numGp = 1L, harem = FALSE, exhaustive = TRUE),
    "Exhaustive mode does not support a non-zero sexRatio (got sexRatio = 5).",
    fixed = TRUE
  )
})

test_that("too few males in the pool still stops with the existing message", {
  expect_error(
    formHaremRatio(0, candidates = c("M1", stopFemales)),
    "form 3 harems with only 1 males at least 1 years old in the list"
  )
})

test_that(paste(
  "a harem with a custom sex ratio and too few males stops on the ratio",
  "first"
), {
  ## The settings are wrong whatever the pool holds, so the stop that names
  ## them comes before the one that counts the males.
  msg <- stopMessage(5, candidates = c("M1", stopFemales))
  expect_false(is.na(msg), info = "the run did not stop")
  if (!is.na(msg)) {
    expect_match(msg, "sexRatio", fixed = TRUE)
    expect_false(grepl("males at least", msg, fixed = TRUE), info = msg)
  }
})
