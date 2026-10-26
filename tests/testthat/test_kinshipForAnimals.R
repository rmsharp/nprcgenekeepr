## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 9, the app's memory:
## implementation, session 9a" (owner pick S1063; design
## docs/planning/app-kinship-memory-design.md sections 4, 6.1 and 7.1; D5
## ruled (c) S1062). The app keeps one kinship matrix of every animal for the
## whole session (R/appServer.R sharedKinshipMatrix: 104.6 MB on the example,
## 764.2 MB on a synthetic 10,000-animal colony). Under D5 (c) each tab
## computes kinship for its own animals plus their ancestors when the user
## asks, through the internal helper kinshipForAnimals(). A pair's kinship
## depends only on the two animals' ancestors, so the values are today's
## exactly (design section 4.2: identical() on 12 sets).
##
## "Today" is the app's formula: the whole pedigree's kinship with the twin
## declarations, then the Genetic Value tab's overrides applied, cut to the
## set. Three rules keep the subset's values identical (design section 4.3;
## the third as the owner ruled at S1063's approach question): trim with
## getProbandPedigree(); keep MZ twins by group, not by pair; and compute with
## the animals the override file names as well, apply every override as
## today, then cut to the set, so that every value, message, warning and
## error is today's (measured S1063 on four override cases).

## The example studbook as the app holds it after upload (all 3,694 animals,
## the living ones the population) and its whole kinship matrix:
## helper-perfCampaign.R's exampleLivingPed() and exampleColony().
examplePed <- function() exampleLivingPed()
exampleFull <- function() exampleColony()$kmat
exampleLivingIds <- function() {
  ped <- examplePed()
  ped$id[isLivingAnimal(ped)]
}

## The whole pedigree's kinship, with gen computed when absent as
## sharedKinshipMatrix does (R/appServer.R).
wholeKinship <- function(ped, twinRelations = NULL) {
  if (!"gen" %in% names(ped)) {
    ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  }
  kinship(ped$id, ped$sire, ped$dam, ped$gen, twinRelations = twinRelations)
}

## Today's value from the whole pedigree's matrix: the overrides applied, then
## the matrix cut to the set (all of it for ids = NULL).
cutToday <- function(full, ids = NULL, overrides = NULL) {
  kmat <- applyKinshipOverridesToMatrix(full, overrides)
  if (is.null(ids)) kmat else filterKinMatrix(ids, kmat)
}

## The value, messages, warnings and error message of one call.
kinshipOutcome <- function(f) {
  messages <- character()
  warnings <- character()
  value <- tryCatch(
    withCallingHandlers(
      f(),
      message = function(m) {
        messages <<- c(messages, conditionMessage(m))
        invokeRestart("muffleMessage")
      },
      warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) list(error = conditionMessage(e))
  )
  list(value = value, messages = messages, warnings = warnings)
}

## How many animals each kinship() call is given while f() runs.
kinshipCallSizes <- function(f) {
  sizes <- integer()
  realKinship <- kinship
  testthat::local_mocked_bindings(
    kinship = function(id, ...) {
      sizes <<- c(sizes, length(id))
      realKinship(id, ...)
    },
    .package = "nprcgenekeepr"
  )
  f()
  sizes
}

## Three full siblings with offspring of their own, as stand-ins for twins
## (design section 4.2): kinship() checks only that a declared pair's ids are
## present, so any pair can be declared.
twinStandIns <- function(ped) {
  known <- !is.na(ped$sire) & !is.na(ped$dam)
  ids <- ped$id[known]
  family <- paste(ped$sire, ped$dam)[known]
  hasOffspring <- ids %in% c(ped$sire, ped$dam)
  siblings <- split(ids[hasOffspring], family[hasOffspring])
  siblings <- siblings[lengths(siblings) >= 3L]
  siblings[[1L]][1:3]
}
offspringOf <- function(ped, ids) ped$id[ped$sire %in% ids | ped$dam %in% ids]
twinRows <- function(id1, id2, code = "MZ twin") {
  data.frame(id1 = id1, id2 = id2, code = rep(code, length.out = length(id1)),
             stringsAsFactors = FALSE)
}

## test_kinship.R's fam1: subjects 8 and 9 full siblings declared MZ twins, 10
## a child of twin 8.
fam1 <- function() {
  ped <- data.frame(
    id   = as.character(1:10),
    sire = c(NA, NA, "1", "1", NA, NA, "3", "6", "6", "8"),
    dam  = c(NA, NA, "2", "2", NA, NA, "5", "4", "4", "7"),
    sex  = c("M", "F", "M", "F", "F", "M", "F", "M", "M", "F"),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  ped
}

test_that(paste("kinship of a set of the example's animals is today's",
                "(design 7.1 item 1)"), {
  ped <- examplePed()
  full <- exampleFull()
  living <- exampleLivingIds()
  drawn <- withr::with_seed(1L, sample(ped$id, 100L),
                            .rng_kind = "Mersenne-Twister",
                            .rng_normal_kind = "Inversion",
                            .rng_sample_kind = "Rejection")
  sets <- list(
    firstTwentyLiving = living[1:20],
    allLiving = living,
    hundredDrawnDeadIncluded = drawn,
    noExitDate = ped$id[is.na(ped$exit)],
    everyAnimal = ped$id
  )
  for (name in names(sets)) {
    expect_identical(kinshipForAnimals(ped, sets[[name]]),
                     filterKinMatrix(sets[[name]], full), info = name)
  }
})

test_that("with no ids asked for it is the whole pedigree's kinship", {
  expect_identical(kinshipForAnimals(examplePed()), exampleFull())
})

test_that(paste("kinship of sets of qcPed and lacy1989Ped is today's",
                "(design 7.1 item 1)"), {
  for (name in c("qcPed", "lacy1989Ped")) {
    ped <- getExportedValue("nprcgenekeepr", name)
    full <- wholeKinship(ped)
    sets <- list(
      everyAnimal = ped$id,
      firstHalf = ped$id[seq_len(nrow(ped) %/% 2L)],
      lastThree = utils::tail(ped$id, 3L)
    )
    expect_identical(kinshipForAnimals(ped), full, info = name)
    for (set in names(sets)) {
      expect_identical(kinshipForAnimals(ped, sets[[set]]),
                       filterKinMatrix(sets[[set]], full),
                       info = paste(name, set))
    }
  }
})

test_that(paste("kinship is computed on the set and its ancestors only,",
                "never on the whole pedigree"), {
  ped <- examplePed()
  set <- exampleLivingIds()[1:20]
  sizes <- kinshipCallSizes(function() kinshipForAnimals(ped, set))
  expect_identical(sizes, nrow(getProbandPedigree(set, ped)))
  expect_lt(sizes, nrow(ped))
})

test_that(paste("an MZ twin pair gives today's kinship whichever twins and",
                "offspring are in the set (design 7.1 item 2)"), {
  ped <- examplePed()
  living <- exampleLivingIds()
  twins <- twinStandIns(ped)
  twinA <- twins[[1L]]
  twinB <- twins[[2L]]
  pair <- twinRows(twinA, twinB)
  full <- wholeKinship(ped, pair)
  sets <- list(
    bothTwins = c(twinA, twinB, living[1:20]),
    oneOffspringOfEach = c(offspringOf(ped, twinA)[[1L]],
                           offspringOf(ped, twinB)[[1L]]),
    oneTwinAndItsOffspring = c(twinA, offspringOf(ped, twinA))
  )
  for (name in names(sets)) {
    expect_identical(kinshipForAnimals(ped, sets[[name]], twinRelations = pair),
                     filterKinMatrix(sets[[name]], full), info = name)
  }
})

test_that(paste("a chain of MZ declarations is kept by group, not by pair",
                "(design 7.1 item 2: A-B and B-C make A-C identical too)"), {
  ped <- examplePed()
  twins <- twinStandIns(ped)
  twinA <- twins[[1L]]
  twinC <- twins[[3L]]
  chain <- twinRows(twins[1:2], twins[2:3])
  full <- wholeKinship(ped, chain)
  sets <- list(
    firstAndLastTwin = c(twinA, twinC),
    oneOffspringOfFirstAndLast = c(offspringOf(ped, twinA)[[1L]],
                                   offspringOf(ped, twinC)[[1L]])
  )
  for (name in names(sets)) {
    expect_identical(kinshipForAnimals(ped, sets[[name]], twinRelations = chain),
                     filterKinMatrix(sets[[name]], full), info = name)
  }
})

test_that(paste("fam1's twin correction reaches a set holding 10 and 9 but",
                "not 8 (design 7.1 item 2)"), {
  ped <- fam1()
  twins <- twinRows("8", "9")
  full <- wholeKinship(ped, twins)
  for (set in list(c("9", "10"), "10", c("10", "9", "5"))) {
    expect_identical(kinshipForAnimals(ped, set, twinRelations = twins),
                     filterKinMatrix(set, full), info = toString(set))
  }
  expect_identical(kinshipForAnimals(ped, c("9", "10"),
                                     twinRelations = twins)["9", "10"],
                   0.28125)
})

test_that("no twin rows, or a table of none, gives the same as no twins", {
  ped <- examplePed()
  set <- exampleLivingIds()[1:20]
  noTwins <- twinRows(character(0L), character(0L))
  expect_identical(kinshipForAnimals(ped, set, twinRelations = noTwins),
                   filterKinMatrix(set, exampleFull()))
})

test_that(paste("DZ and UZ rows naming an animal outside the set change",
                "nothing and raise nothing (design 7.1 item 3)"), {
  ped <- examplePed()
  twins <- twinStandIns(ped)
  set <- c(twins[[1L]], exampleLivingIds()[1:5])
  for (code in c("DZ twin", "UZ twin")) {
    rows <- twinRows(twins[[1L]], twins[[2L]], code = code)
    expect_identical(
      kinshipOutcome(function() {
        kinshipForAnimals(ped, set, twinRelations = rows)
      }),
      list(value = filterKinMatrix(set, exampleFull()),
           messages = character(), warnings = character()),
      info = code
    )
  }
})

test_that(paste("an MZ declaration naming an animal not in the pedigree",
                "stops with today's error"), {
  ped <- examplePed()
  set <- exampleLivingIds()[1:20]
  rows <- twinRows(twinStandIns(ped)[[1L]], "NOT_AN_ID")
  today <- kinshipOutcome(function() {
    filterKinMatrix(set, wholeKinship(ped, rows))
  })
  expect_true(is.list(today$value) && !is.null(today$value$error))
  expect_identical(
    kinshipOutcome(function() {
      kinshipForAnimals(ped, set, twinRelations = rows)
    }),
    today
  )
})

test_that(paste("overrides give today's values, messages, warnings and",
                "errors, whichever animals they name (design 7.1 item 4,",
                "owner ruling S1063)"), {
  ped <- examplePed()
  full <- exampleFull()
  living <- exampleLivingIds()
  set <- living[1:20]
  outside <- setdiff(living, set)[1:2]
  overrides <- function(id1, id2, kinship) {
    data.frame(id1 = id1, id2 = id2, kinship = kinship,
               stringsAsFactors = FALSE)
  }
  cases <- list(
    insideTheSet = overrides(set[[1L]], set[[2L]], 0.01),
    oneOutsideTheSet = overrides(c(set[[1L]], outside[[1L]]),
                                 c(set[[2L]], outside[[2L]]), c(0.01, 0.02)),
    anIdNotInThePedigree = overrides(c(set[[1L]], "NOT_AN_ID"),
                                     c(set[[2L]], set[[3L]]), c(0.01, 0.02)),
    aboveItsCeilingOutsideTheSet = overrides(c(set[[1L]], outside[[1L]]),
                                             c(set[[2L]], outside[[2L]]),
                                             c(0.01, 0.9)),
    aboveItsCeilingInsideTheSet = overrides(set[[1L]], set[[2L]], 0.9)
  )
  for (name in names(cases)) {
    expect_identical(
      kinshipOutcome(function() {
        kinshipForAnimals(ped, set, overrides = cases[[name]])
      }),
      kinshipOutcome(function() cutToday(full, set, cases[[name]])),
      info = name
    )
  }
})

test_that(paste("an override naming animals outside the set adds those",
                "animals and their ancestors to the computation, and no",
                "more"), {
  ped <- examplePed()
  living <- exampleLivingIds()
  set <- living[1:20]
  outside <- setdiff(living, set)[1:2]
  rows <- data.frame(id1 = outside[[1L]], id2 = outside[[2L]], kinship = 0.02,
                     stringsAsFactors = FALSE)
  sizes <- kinshipCallSizes(function() {
    suppressMessages(kinshipForAnimals(ped, set, overrides = rows))
  })
  expect_identical(sizes,
                   nrow(getProbandPedigree(c(set, outside), ped)))
})

test_that(paste("rows and columns come back in pedigree order, whatever the",
                "order of the ids asked for (design 7.1 item 5)"), {
  ped <- examplePed()
  set <- rev(exampleLivingIds()[1:20])
  asked <- c(set, set[1:3])
  result <- kinshipForAnimals(ped, asked)
  expect_identical(rownames(result), ped$id[ped$id %in% set])
  expect_identical(colnames(result), rownames(result))
  expect_identical(result, filterKinMatrix(asked, exampleFull()))
})

test_that("no animals asked for gives today's empty matrix, quietly", {
  ped <- examplePed()
  expect_identical(
    kinshipOutcome(function() kinshipForAnimals(ped, character(0L))),
    list(value = filterKinMatrix(character(0L), exampleFull()),
         messages = character(), warnings = character())
  )
})

test_that("ids missing from the pedigree are left out quietly, as today", {
  ped <- examplePed()
  asked <- c(exampleLivingIds()[1:5], "NOT_AN_ID", NA)
  expect_identical(
    kinshipOutcome(function() kinshipForAnimals(ped, asked)),
    list(value = filterKinMatrix(asked, exampleFull()),
         messages = character(), warnings = character())
  )
})

test_that("one founder gives today's 1 x 1 matrix", {
  ped <- examplePed()
  founder <- ped$id[is.na(ped$sire) & is.na(ped$dam)][[1L]]
  expect_identical(kinshipForAnimals(ped, founder),
                   filterKinMatrix(founder, exampleFull()))
})

test_that("a pedigree without a gen column gives today's values", {
  ped <- examplePed()
  ped$gen <- NULL
  set <- exampleLivingIds()[1:20]
  expect_identical(kinshipForAnimals(ped, set),
                   filterKinMatrix(set, exampleFull()))
})

test_that("the result is a base numeric matrix", {
  result <- kinshipForAnimals(examplePed(), exampleLivingIds()[1:20])
  expect_true(is.matrix(result))
  expect_true(is.double(result))
  expect_false(isS4(result))
})
