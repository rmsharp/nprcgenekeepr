## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S983; BACKLOG.md:156, found S764): a harem's sire is chosen before the
## fill loop starts, and the loop drops an animal's relatives from a group's
## pool only for animals it places itself, so nobody ever dropped the sire's
## own relatives. On the example pedigree with the app's defaults (3 harems,
## Max kinship 0.25, 10 simulations) 29 of 40 seeded runs put a mother, a
## daughter or a sister of a harem's sire into his harem (41 animals in 120
## harems). The owner ruled (S983): hold the sire to the same rule as every
## other animal, kinship and ancestry together, and when his relatives are
## everyone available the harem is the sire alone (no error).
##
## The pedigree is small and built here, so every block says what it must
## find for any seed:
##   S1 is the sire of the harem. At Max kinship 0.25 his mother F0, full
##   sister FS and daughter D1 are his relatives (kinship 0.25). His
##   half-sister HS is at 0.125, and his daughter J1 is 0.3 years old, under
##   the minimum age of 1, so a pair with her is ignored. U1 and U2 are
##   unrelated females. S2 is a second sire, unrelated to S1, with his own
##   daughter D2.
## Female-female kinship is ignored (the app's setting), so only the sire's
## kinship decides who may join his harem.
##
## Guards that pass at HEAD and must still pass: Max kinship 0.5 excludes no
## one, the relatives of a supplied seed animal stay out of its group, and a
## sire with no relatives in the pool gives the same-seed groups of HEAD.

haremPed <- function() {
  raw <- data.frame(
    id = c(
      "M0", "F0", "F1", "F2", "F3", "S1", "S2", "FS", "HS", "D1", "J1", "D2",
      "U1", "U2"
    ),
    sire = c(
      NA, NA, NA, NA, NA, "M0", NA, "M0", "M0", "S1", "S1", "S2", NA, NA
    ),
    dam = c(
      NA, NA, NA, NA, NA, "F0", NA, "F0", "F2", "F1", "F1", "F3", NA, NA
    ),
    sex = c(
      "M", "F", "F", "F", "F", "M", "M", "F", "F", "F", "F", "F", "F", "F"
    ),
    birth = c(
      "2000-01-01", "2000-01-01", "2000-01-01", "2000-01-01", "2000-01-01",
      "2008-01-01", "2005-01-01", "2008-06-01", "2009-01-01", "2014-01-01",
      format(Sys.Date() - 120L), "2015-01-01", "2003-01-01", "2003-01-01"
    ),
    stringsAsFactors = FALSE
  )
  suppressWarnings(qcStudbook(raw, reportChanges = FALSE,
                              reportErrors = FALSE))
}

haremKmat <- function(ped) {
  kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
}

## S1 and everyone his relatives could be placed with
oneHaremPool <- c("S1", "F0", "FS", "HS", "D1", "J1", "U1", "U2")

formHarems <- function(candidates, ped, kmat, seed, numGp = 1L,
                       threshold = 0.25, minAge = 1, currentGroups = NULL) {
  set_seed(seed)
  arguments <- list(
    candidates = candidates, kmat = kmat, ped = ped, threshold = threshold,
    ignore = list(c("F", "F")), minAge = minAge, iter = 5L, numGp = numGp,
    harem = TRUE
  )
  if (!is.null(currentGroups)) {
    arguments$currentGroups <- currentGroups
  }
  do.call(groupAddAssign, arguments)
}

sameMembers <- function(found, expected) {
  setequal(found, expected) && length(found) == length(expected)
}

test_that("the fill loop keeps a harem sire's mother, full sister and daughter out", {
  ped <- haremPed()
  kmat <- haremKmat(ped)
  kin <- getAnimalsWithHighKinship(
    filterKinMatrix(oneHaremPool, kmat), ped, 0.25, list(character(0L)),
    list(c("F", "F")), 1
  )
  kin <- addAnimalsWithNoRelative(kin, oneHaremPool)
  for (seed in 1L:20L) {
    set_seed(seed)
    group <- nprcgenekeepr:::fillGroupMembers(
      oneHaremPool, list(character(0L)), kin, ped, TRUE, 1, 1L, 0
    )[[1L]]
    expect_false(any(c("F0", "FS", "D1") %in% group),
      info = paste("seed", seed, "group", toString(group))
    )
    expect_true(sameMembers(group, c("S1", "HS", "J1", "U1", "U2")),
      info = paste("seed", seed, "group", toString(group))
    )
  }
})

test_that("groupAddAssign leaves the sire's relatives to the unused animals", {
  ped <- haremPed()
  kmat <- haremKmat(ped)
  for (seed in 1L:5L) {
    res <- formHarems(oneHaremPool, ped, kmat, seed)
    expect_identical(res$group[[1L]][1L], "S1")
    expect_true(sameMembers(res$group[[1L]], c("S1", "HS", "J1", "U1", "U2")),
      info = paste("seed", seed, "group", toString(res$group[[1L]]))
    )
    expect_true(sameMembers(res$group[[2L]], c("F0", "FS", "D1")),
      info = paste("seed", seed, "unused", toString(res$group[[2L]]))
    )
  }
})

test_that("a lower Max kinship also keeps the sire's half-sister out", {
  ped <- haremPed()
  kmat <- haremKmat(ped)
  for (seed in 1L:3L) {
    res <- formHarems(oneHaremPool, ped, kmat, seed, threshold = 0.1)
    expect_true(sameMembers(res$group[[1L]], c("S1", "J1", "U1", "U2")),
      info = paste("seed", seed, "group", toString(res$group[[1L]]))
    )
    expect_true(sameMembers(res$group[[2L]], c("F0", "FS", "HS", "D1")),
      info = paste("seed", seed, "unused", toString(res$group[[2L]]))
    )
  }
})

test_that("a minimum age of 0 also keeps the sire's young daughter out", {
  ped <- haremPed()
  kmat <- haremKmat(ped)
  for (seed in 1L:3L) {
    res <- formHarems(oneHaremPool, ped, kmat, seed, minAge = 0)
    expect_true(sameMembers(res$group[[1L]], c("S1", "HS", "U1", "U2")),
      info = paste("seed", seed, "group", toString(res$group[[1L]]))
    )
    expect_true(sameMembers(res$group[[2L]], c("F0", "FS", "D1", "J1")),
      info = paste("seed", seed, "unused", toString(res$group[[2L]]))
    )
  }
})

test_that("a Max kinship above every relationship excludes no one (guard)", {
  ped <- haremPed()
  kmat <- haremKmat(ped)
  for (seed in 1L:3L) {
    res <- formHarems(oneHaremPool, ped, kmat, seed, threshold = 0.5)
    expect_true(sameMembers(res$group[[1L]], oneHaremPool),
      info = paste("seed", seed, "group", toString(res$group[[1L]]))
    )
    expect_true(is.na(res$group[[2L]]))
  }
})

test_that("each of two harems drops only its own sire's relatives", {
  ped <- haremPed()
  kmat <- haremKmat(ped)
  pool <- c("S1", "S2", "F0", "FS", "D1", "HS", "J1", "D2", "U1", "U2")
  kin <- getAnimalsWithHighKinship(
    filterKinMatrix(pool, kmat), ped, 0.25, list(character(0L)),
    list(c("F", "F")), 1
  )
  for (seed in 1L:5L) {
    res <- formHarems(pool, ped, kmat, seed, numGp = 2L)
    groups <- res$group[1L:2L]
    sires <- vapply(groups, function(g) g[1L], character(1L))
    expect_true(setequal(sires, c("S1", "S2")), info = paste("seed", seed))
    for (g in groups) {
      relatives <- kin[[g[1L]]]
      expect_identical(intersect(g[-1L], relatives), character(0L),
        info = paste("seed", seed, "group", toString(g))
      )
    }
    ## S1's relatives can only go to S2's harem, and S2's daughter to S1's
    first <- groups[[which(sires == "S1")]]
    second <- groups[[which(sires == "S2")]]
    expect_true(all(c("F0", "FS", "D1") %in% second),
      info = paste("seed", seed, "S2's group", toString(second))
    )
    expect_true("D2" %in% first,
      info = paste("seed", seed, "S1's group", toString(first))
    )
    expect_false(any(c("F0", "FS", "D1") %in% first))
    expect_false("D2" %in% second)
  }
})

test_that("a harem whose sire is related to every other candidate is the sire alone", {
  ped <- haremPed()
  kmat <- haremKmat(ped)
  for (seed in 1L:3L) {
    res <- formHarems(c("S1", "F0", "FS", "D1"), ped, kmat, seed)
    expect_identical(res$group[[1L]], "S1")
    expect_true(sameMembers(res$group[[2L]], c("F0", "FS", "D1")),
      info = paste("seed", seed, "unused", toString(res$group[[2L]]))
    )
  }
})

test_that("a pool of only males gives harems of the sires alone", {
  ped <- haremPed()
  kmat <- haremKmat(ped)
  res <- tryCatch(
    formHarems(c("S1", "S2"), ped, kmat, 1L, numGp = 2L),
    error = function(e) e
  )
  expect_false(inherits(res, "error"),
    info = if (inherits(res, "error")) conditionMessage(res) else ""
  )
  if (!inherits(res, "error")) {
    expect_identical(lengths(res$group[1L:2L]), c(1L, 1L))
    expect_true(setequal(unlist(res$group[1L:2L]), c("S1", "S2")))
  }
})

test_that("a supplied seed animal's relatives stay out of its group (guard)", {
  ped <- haremPed()
  kmat <- haremKmat(ped)
  for (seed in 1L:3L) {
    res <- formHarems(c("S1", "S2", "HS", "U1", "U2"), ped, kmat, seed,
      currentGroups = list("D2")
    )
    expect_true("D2" %in% res$group[[1L]])
    expect_identical(res$group[[1L]][1L], "S1")
    expect_false("S2" %in% res$group[[1L]])
  }
})

test_that("a sire with no relatives in the pool gives HEAD's same-seed groups (guard)", {
  ped <- haremPed()
  kmat <- haremKmat(ped)
  pool <- c("S1", "S2", "HS", "J1", "U1", "U2")
  ## captured from HEAD (6393282d2) before the fix: nobody in this pool is at
  ## or above 0.25 to either sire, so the fix must not move one draw
  expected <- list(
    "1" = list(c("S1", "U1", "J1"), c("S2", "HS", "U2")),
    "2" = list(c("S2", "U1", "J1"), c("S1", "HS", "U2")),
    "3" = list(c("S2", "J1", "HS"), c("S1", "U1", "U2"))
  )
  for (seed in names(expected)) {
    res <- formHarems(pool, ped, kmat, as.integer(seed), numGp = 2L)
    expect_identical(res$group[1L:2L], expected[[seed]],
      info = paste("seed", seed)
    )
  }
})
