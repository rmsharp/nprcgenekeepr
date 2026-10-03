## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## S881 (PED-4, NEW-54): getPotentialParents() is split into internal helpers.
## Part 1 pins today's output so the split cannot change it (passes before and
## after, by design: a refactor has no failing behavior test). Part 2 tests each
## helper directly (fails until the helpers exist).

## Part 1: characterization ---------------------------------------------------
pinned <- function(name) {
  readRDS(testthat::test_path("fixtures", paste0("gpp_pinned_", name, ".rds")))
}
rhesusWithCenter <- function() {
  ped <- nprcgenekeepr::rhesusPedigree
  ped$fromCenter <- TRUE
  ped
}

test_that("getPotentialParents output is unchanged: explicit windows and ages", {
  expect_identical(
    getPotentialParents(
      ped = rhesusWithCenter(), minSireAge = 2, minDamAge = 2,
      maxGestationalPeriod = 210L
    ),
    pinned("explicit")
  )
})

test_that("getPotentialParents output is unchanged: species defaults", {
  expect_identical(getPotentialParents(ped = rhesusWithCenter()), pinned("defaults"))
})

test_that("getPotentialParents output is unchanged: deprecated minParentAge", {
  expect_identical(
    suppressWarnings(
      getPotentialParents(
        ped = rhesusWithCenter(), minParentAge = 3,
        maxGestationalPeriod = 210L
      )
    ),
    pinned("deprecated")
  )
  expect_identical(
    suppressWarnings(
      getPotentialParents(
        ped = rhesusWithCenter(), minParentAge = NULL,
        maxGestationalPeriod = 210L
      )
    ),
    pinned("deprecatedNull")
  )
})

test_that("getPotentialParents output is unchanged: mixed species", {
  ped <- rhesusWithCenter()
  ped$species <- rep(c("RHESUS", "COMMON MARMOSET", "BABOON", NA),
    length.out = nrow(ped)
  )
  expect_identical(getPotentialParents(ped = ped), pinned("mixedSpecies"))
})

test_that("getPotentialParents still returns NULL without fromCenter", {
  expect_null(getPotentialParents(ped = nprcgenekeepr::rhesusPedigree))
})

## Part 2: helper unit tests ---------------------------------------------------
helperPed <- function() {
  data.table::data.table(
    id = c("S_OLD", "S_GONE", "S_YOUNG", "D_PROVEN", "D_OPEN", "D_BUSY", "KID"),
    sex = c("M", "M", "M", "F", "F", "F", "M"),
    sire = NA_character_,
    dam = c(NA, NA, NA, NA, NA, NA, NA_character_),
    birth = as.Date("2000-01-01") +
      c(0L, 0L, 3000L, 0L, 0L, 0L, 1000L),
    exit = as.Date(c(NA, "2001-06-01", NA, NA, "2000-06-01", NA, NA))
  )
}

test_that("resolveMinParentAges maps a scalar minParentAge onto unset ages", {
  expect_identical(
    resolveMinParentAges(NULL, NULL, 3),
    list(minSireAge = 3, minDamAge = 3)
  )
  expect_identical(
    resolveMinParentAges(5, NULL, 3),
    list(minSireAge = 5, minDamAge = 3)
  )
  expect_identical(
    resolveMinParentAges(NULL, 4, 3),
    list(minSireAge = 3, minDamAge = 4)
  )
})

test_that("resolveMinParentAges maps NULL minParentAge to no age check", {
  expect_identical(
    resolveMinParentAges(NULL, NULL, NULL),
    list(minSireAge = -Inf, minDamAge = -Inf)
  )
  ## a supplied sex-specific age is overridden by the legacy NULL, as before
  expect_identical(
    resolveMinParentAges(5, 4, NULL),
    list(minSireAge = -Inf, minDamAge = -Inf)
  )
})

test_that("gestationWindows uses one fixed window when supplied", {
  pUnknown <- data.table::data.table(id = c("A", "B", "C"))
  expect_identical(gestationWindows(pUnknown, 210, NULL), rep(210L, 3L))
})

test_that("gestationWindows looks up species windows when not supplied", {
  pUnknown <- data.table::data.table(
    id = c("A", "B"), species = c("CYNOMOLGUS", NA_character_)
  )
  expect_identical(
    gestationWindows(pUnknown, NULL, NULL),
    getSpeciesGestation(pUnknown$species)
  )
  noSpecies <- data.table::data.table(id = c("A", "B"))
  expect_identical(
    gestationWindows(noSpecies, NULL, NULL),
    getSpeciesGestation(rep(NA_character_, 2L))
  )
  expect_identical(
    gestationWindows(pUnknown[0L, ], NULL, NULL),
    getSpeciesGestation(character(0L))
  )
})

test_that("selectPotentialSires keeps males present at conception", {
  ped <- helperPed()
  birth <- as.Date("2002-01-01")
  ## S_GONE exited 2001-06-01, before conception (birth - 210 d = 2001-06-05)
  expect_identical(
    selectPotentialSires(ped, birth, 210L),
    c("S_OLD", "S_YOUNG", "KID")
  )
  ## a longer window reaches back before S_GONE's exit
  expect_identical(
    selectPotentialSires(ped, birth, 250L),
    c("S_OLD", "S_GONE", "S_YOUNG", "KID")
  )
})

test_that("selectPotentialSires returns an empty character vector for no males", {
  ped <- helperPed()[sex == "F", ]
  expect_identical(
    selectPotentialSires(ped, as.Date("2002-01-01"), 210L),
    character(0L)
  )
})

test_that("selectPotentialDams reports the provenBreeder tier", {
  ped <- helperPed()
  ## D_PROVEN has an offspring about a year after the focal birth
  ped <- rbind(ped, data.table::data.table(
    id = "PROVEN_KID", sex = "F", sire = NA_character_, dam = "D_PROVEN",
    birth = as.Date("2003-01-01"), exit = as.Date(NA)
  ))
  ba <- ped[sex == "F" & id != "PROVEN_KID", ]
  res <- selectPotentialDams(ba, as.Date("2002-01-01"), 210L, ped)
  expect_identical(res$ids, "D_PROVEN")
  expect_identical(res$basis, "provenBreeder")
})

test_that("selectPotentialDams falls back to eligibleFemale", {
  ped <- helperPed()
  ba <- ped[sex == "F", ]
  res <- selectPotentialDams(ba, as.Date("2002-01-01"), 210L, ped)
  ## D_OPEN exited 2000-06-01, before the birth, so she is not present
  expect_identical(res$ids, c("D_PROVEN", "D_BUSY"))
  expect_identical(res$basis, "eligibleFemale")
})

test_that("selectPotentialDams excludes a female with a birth inside the window", {
  ped <- helperPed()
  ped <- rbind(ped, data.table::data.table(
    id = "BUSY_KID", sex = "F", sire = NA_character_, dam = "D_BUSY",
    birth = as.Date("2002-03-01"), exit = as.Date(NA)
  ))
  ba <- ped[id %in% c("D_PROVEN", "D_BUSY"), ]
  res <- selectPotentialDams(ba, as.Date("2002-01-01"), 210L, ped)
  expect_identical(res$ids, "D_PROVEN")
})

test_that("selectPotentialDams returns no ids and an NA-safe basis when none remain", {
  ped <- helperPed()
  ba <- ped[id == "D_OPEN", ]
  res <- selectPotentialDams(ba, as.Date("2002-01-01"), 210L, ped)
  expect_identical(res$ids, character(0L))
})

test_that("buildParentEntry lists only the missing parents", {
  focal <- data.table::data.table(id = "K", sire = NA_character_, dam = NA_character_)
  expect_identical(
    buildParentEntry(focal, c("S1", "S2"), c("D1"), "provenBreeder"),
    list(
      id = "K", sires = c("S1", "S2"), dams = "D1",
      damBasis = "provenBreeder"
    )
  )
  knownDam <- data.table::data.table(id = "K", sire = NA_character_, dam = "D9")
  expect_identical(
    buildParentEntry(knownDam, "S1", "D1", "eligibleFemale"),
    list(
      id = "K", sires = "S1", dams = character(0L),
      damBasis = NA_character_
    )
  )
  knownSire <- data.table::data.table(id = "K", sire = "S9", dam = NA_character_)
  expect_identical(
    buildParentEntry(knownSire, "S1", "D1", "eligibleFemale"),
    list(
      id = "K", sires = character(0L), dams = "D1",
      damBasis = "eligibleFemale"
    )
  )
})

test_that("buildParentEntry gives damBasis NA when no dam is listed", {
  focal <- data.table::data.table(id = "K", sire = NA_character_, dam = NA_character_)
  e <- buildParentEntry(focal, "S1", character(0L), "provenBreeder")
  expect_identical(e$dams, character(0L))
  expect_identical(e$damBasis, NA_character_)
})
