## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S984; BACKLOG.md:156, found S983): with Harem selected, a male typed
## into some groups' Seed animals boxes but not all of them stopped the run
## with "subscript out of bounds", or, for a male in the last box only, formed
## harems that had no male at all. initializeHaremGroups() sampled sires only
## when NO seeded group held a male, so a group without a seeded male got no
## sire: a short list (the crash) or an empty hole (the sireless harem).
## The owner ruled (S984): every group with no seeded male is given a sire
## sampled from the candidates, exactly as every group is when none is seeded.
## A group whose seed animals include a male keeps him as its sire.
##
## On the example pedigree, 3 harems, 12 seeding patterns tried: 4 ran (no
## male seeded, or a male in every box), 7 stopped, 1 ran with two harems
## that had no male. The real app showed both: a male in Group 1's box only
## gave "Could not form breeding groups. Error: subscript out of bounds", and
## a male in Group 3's box only gave Groups 1 and 2 with 0 males each.
##
## The pedigree is small and built here. Six unrelated adult males M1-M5 and
## MR, eight unrelated adult females F1-F8, and FR, a young female whose sire
## is MR (kinship 0.25, at the Max kinship used below), so a seeded FR keeps
## MR out of the pool. Female-female kinship is ignored (the app's setting).
##
## Guards that pass at HEAD and must still pass: the same-seed groups for no
## seeded male and for a male in every group stay as HEAD gave them, too few
## males still stops with the existing message, and two males in one seed
## group still stops.

partialPed <- function() {
  ids <- c("M1", "M2", "M3", "M4", "M5", "MR", paste0("F", 1:8), "FR")
  raw <- data.frame(
    id = ids,
    sire = c(rep(NA, 14), "MR"),
    dam = c(rep(NA, 14), "F8"),
    sex = c(rep("M", 6), rep("F", 9)),
    birth = c(rep("2005-01-01", 14), "2010-01-01"),
    stringsAsFactors = FALSE
  )
  suppressWarnings(qcStudbook(raw, reportChanges = FALSE, reportErrors = FALSE))
}

partialPedData <- partialPed()
partialKmat <- kinship(
  partialPedData$id, partialPedData$sire, partialPedData$dam,
  partialPedData$gen,
  sparse = FALSE
)
allMales <- partialPedData$id[partialPedData$sex == "M"]
allFemales <- paste0("F", 1:8)

formPartial <- function(currentGroups, seed, candidates = partialPedData$id,
                        numGp = 3L) {
  set_seed(seed)
  groupAddAssign(
    candidates = candidates, kmat = partialKmat, ped = partialPedData,
    currentGroups = currentGroups, threshold = 0.25,
    ignore = list(c("F", "F")), minAge = 1, iter = 5L, numGp = numGp,
    harem = TRUE
  )
}

## The result of a run, or NULL when it stopped (the failing expectation says so)
tryForm <- function(currentGroups, seed, ...) {
  res <- tryCatch(
    formPartial(currentGroups, seed, ...),
    error = function(e) e
  )
  if (inherits(res, "error")) {
    return(NULL)
  }
  res
}

nMales <- function(group) sum(group %in% allMales)

## The formed harems are the first numGp groups; the last box is the unused
## animals.
haremGroups <- function(res, numGp = 3L) res$group[seq_len(numGp)]

sameGroups <- function(found, expected) {
  length(found) == length(expected) &&
    all(mapply(
      function(f, e) setequal(f, e) && length(f) == length(e),
      found, expected
    ))
}

partialSeedPatterns <- list(
  `male in group 1 only` = list("M1", character(0), character(0)),
  `male in group 2 only` = list(character(0), "M1", character(0)),
  `male in group 3 only` = list(character(0), character(0), "M1"),
  `males in groups 1 and 2` = list("M1", "M2", character(0)),
  `male in 1, females in 3` = list("M1", character(0), c("F1", "F2")),
  `male in 1, females in 2` = list("M1", c("F1", "F2"), character(0)),
  `male with a female in 1` = list(c("M1", "F1"), character(0), character(0))
)

test_that(paste(
  "a male seeded in only some harems no longer stops the run, and each",
  "harem holds exactly one male"
), {
  for (label in names(partialSeedPatterns)) {
    for (seed in 1L:3L) {
      info <- paste0(label, ", seed ", seed)
      res <- tryForm(partialSeedPatterns[[label]], seed)
      expect_false(is.null(res), info = paste(info, "- the run stopped"))
      if (is.null(res)) next
      expect_equal(
        vapply(haremGroups(res), nMales, integer(1L)), c(1L, 1L, 1L),
        info = info
      )
    }
  }
})

test_that("seeded animals stay in the group whose box they were typed in", {
  for (label in names(partialSeedPatterns)) {
    seeds <- partialSeedPatterns[[label]]
    for (seed in 1L:2L) {
      info <- paste0(label, ", seed ", seed)
      res <- tryForm(seeds, seed)
      expect_false(is.null(res), info = paste(info, "- the run stopped"))
      if (is.null(res)) next
      for (i in seq_along(seeds)) {
        expect_true(all(seeds[[i]] %in% res$group[[i]]),
          info = paste(info, "- group", i)
        )
      }
    }
  }
})

test_that(paste(
  "a male seeded only in the last group no longer leaves the earlier",
  "harems without a male"
), {
  for (seed in 1L:4L) {
    res <- tryForm(partialSeedPatterns[["male in group 3 only"]], seed)
    expect_false(is.null(res), info = paste("seed", seed))
    if (is.null(res)) next
    expect_equal(nMales(res$group[[1L]]), 1L, info = paste("group 1, seed", seed))
    expect_equal(nMales(res$group[[2L]]), 1L, info = paste("group 2, seed", seed))
    expect_true(
      "M1" %in% res$group[[3L]] && nMales(res$group[[3L]]) == 1L,
      info = paste("group 3 keeps its seeded male, seed", seed)
    )
  }
})

test_that(paste(
  "a sire picked for a group is never a relative of a seeded animal",
  "and is never the seeded male"
), {
  ## FR is seeded in group 2; her sire MR (kinship 0.25) must stay out of
  ## every harem, so the two picked sires come from M2-M5, and M1, seeded in
  ## group 1, is the sire of group 1 only.
  seeds <- list("M1", "FR", character(0))
  for (seed in 1L:6L) {
    info <- paste("seed", seed)
    res <- tryForm(seeds, seed)
    expect_false(is.null(res), info = paste(info, "- the run stopped"))
    if (is.null(res)) next
    harems <- haremGroups(res)
    expect_false("MR" %in% unlist(harems), info = info)
    expect_true("FR" %in% harems[[2L]], info = info)
    sires <- unlist(lapply(harems, function(g) g[g %in% allMales]))
    expect_length(sires, 3L)
    expect_true(all(sires %in% c("M1", "M2", "M3", "M4", "M5")), info = info)
    expect_equal(sum(sires == "M1"), 1L, info = info)
    expect_true("M1" %in% harems[[1L]], info = info)
  }
})

test_that(paste(
  "makeGroupMembers returns a complete list when a male is seeded in only",
  "some groups, and a seeded male in the candidates is used once"
), {
  seeds <- list(
    `male in group 1 only` = list("M1", character(0), character(0)),
    `male in group 3 only` = list(character(0), character(0), "M1")
  )
  for (label in names(seeds)) {
    for (seed in 1L:5L) {
      info <- paste0(label, ", seed ", seed)
      set_seed(seed)
      members <- makeGroupMembers(
        numGp = 3L, currentGroups = seeds[[label]],
        candidates = partialPedData$id, ped = partialPedData, harem = TRUE,
        minAge = 1
      )
      expect_length(members, 3L)
      expect_false(any(vapply(members, is.null, logical(1L))), info = info)
      expect_equal(
        vapply(members, function(m) length(getPotentialSires(m, partialPedData, 1)),
               integer(1L)),
        c(1L, 1L, 1L),
        info = info
      )
      expect_equal(sum(unlist(members) == "M1"), 1L, info = info)
    }
  }
})

test_that(paste(
  "the too-few-males stop counts only the groups that have no seeded male"
), {
  ## Male M1 seeded in group 1, exactly two other males in the pool: groups 2
  ## and 3 take them, so nothing is short.
  pool <- c("M1", "M2", "M3", allFemales)
  res <- tryForm(partialSeedPatterns[["male in group 1 only"]], 1L,
    candidates = pool
  )
  expect_false(is.null(res), info = "one seeded male and two others in the pool")
  if (!is.null(res)) {
    expect_equal(
      sort(unlist(lapply(haremGroups(res), function(g) g[g %in% allMales]))),
      c("M1", "M2", "M3")
    )
  }
  ## A male seeded in every group and no other male in the pool: no group
  ## needs a sire.
  res <- tryForm(list("M1", "M2", "M3"), 1L, candidates = allFemales)
  expect_false(is.null(res), info = "males seeded in all three, none in the pool")
  if (!is.null(res)) {
    expect_equal(
      vapply(haremGroups(res), nMales, integer(1L)), c(1L, 1L, 1L)
    )
  }
})

## ---- Guards: these pass at HEAD and must still pass ----------------------

test_that("with no male seeded the same-seed groups stay as they were", {
  res <- formPartial(list(character(0)), 5L)
  expect_true(sameGroups(
    haremGroups(res),
    list(
      c("F1", "F3", "F7", "M2"), c("F4", "F5", "M4"),
      c("F2", "F6", "F8", "FR", "M5")
    )
  ))
  res <- formPartial(list(c("F1", "F2"), character(0), character(0)), 5L)
  expect_true(sameGroups(
    haremGroups(res),
    list(
      c("F1", "F2", "F3", "F5", "F8", "M2"), c("F4", "F6", "M4"),
      c("F7", "FR", "M5")
    )
  ))
})

test_that("with a male seeded in every group the same-seed groups stay as they were", {
  res <- formPartial(list("M1", "M2", "M3"), 5L)
  expect_true(sameGroups(
    haremGroups(res),
    list(
      c("F2", "F4", "F5", "F6", "F7", "M1"), c("F8", "FR", "M2"),
      c("F1", "F3", "M3")
    )
  ))
  res <- formPartial(list(c("M1", "F1"), "M2", "M3"), 7L)
  expect_true(sameGroups(
    haremGroups(res),
    list(
      c("F1", "F2", "F3", "F4", "F8", "M1"), c("F7", "FR", "M2"),
      c("F5", "F6", "M3")
    )
  ))
})

test_that("too few males in the pool still stops with the existing message", {
  ## M1 seeded in group 1 and one other male in the pool: groups 2 and 3
  ## need two.
  expect_error(
    formPartial(partialSeedPatterns[["male in group 1 only"]], 1L,
      candidates = c("M1", "M2", allFemales)
    ),
    "form 3 harems with only 1 males at least 1 years old in the list"
  )
})

test_that("two males in one seed group still stops with the existing message", {
  expect_error(
    formPartial(list(c("M1", "M2"), character(0), character(0)), 1L),
    "more than one male, There are 2 at least 1 years old in the current group 1"
  )
})
