## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 6, kinship memory"
## (owner pick S1059; plan docs/planning/performance-memory-campaign-plan.md,
## Phase 6 and section 5.1). kinship() filled an (n + 1) x (n + 1) matrix, row
## n + 1 standing in for every missing parent, then copied its n x n block, so
## its peak was about twice its result. kinMatrix2LongForm() built its m^2 rows
## through as.data.frame() and stack(): 979 MB at its peak for a 313 MB result
## on the example's 3,694 animals (S1059). getAnimalsWithHighKinship() built
## that whole long form only to keep the pairs above a threshold: 1,259 MB for
## a 10.7 MB result. kinship() now fills one n x n matrix, with a vector for
## the missing-parent row; kinMatrix2LongForm() builds its three columns
## directly; and getAnimalsWithHighKinship() starts from the cells at or above
## the threshold (highKinshipPairs()).
##
## The owner's rulings: every result stays exactly today's for the same inputs
## (D1), the exported functions keep their arguments and results (D3), and an
## input the new code was not built for runs today's code unchanged (owner
## ruling S1059, as in Phases 1-5), so it gives today's result, or today's
## error, by construction. So each block compares the new code with frozen
## copies of today's functions (helper-perfReference.R) using identical().

## A seeded pedigree of n animals in birth order: a fifth are founders, each
## later animal draws a sire and a dam from the animals before it, one parent
## in ten is left unknown, and one animal in twenty has an unknown sex ("U" or
## NA), the cases that reach the missing-parent row on the X chromosome.
seededPedigree <- function(n, seed) {
  withr::with_seed(seed, {
    id <- sprintf("A%03d", seq_len(n))
    founders <- max(2L, n %/% 5L)
    sire <- dam <- rep(NA_character_, n)
    sex <- sample(c("M", "F"), n, replace = TRUE)
    sex[seq_len(founders)] <- rep(c("M", "F"), length.out = founders)
    for (i in seq.int(founders + 1L, n)) {
      males <- which(sex[seq_len(i - 1L)] == "M")
      females <- which(sex[seq_len(i - 1L)] == "F")
      sire[i] <- id[males[sample.int(length(males), 1L)]]
      dam[i] <- id[females[sample.int(length(females), 1L)]]
      if (stats::runif(1L) < 0.1) sire[i] <- NA
      if (stats::runif(1L) < 0.1) dam[i] <- NA
    }
    unknown <- stats::runif(n) < 0.05
    sex[unknown] <- sample(c("U", NA), sum(unknown), replace = TRUE)
    list(id = id, sire = sire, dam = dam,
         gen = findGeneration(id, sire, dam), sex = sex)
  })
}

kinshipSeeds <- c(1L, 7L, 2026L)

## The kinship() calls of one seeded pedigree: both chromosome types, declared
## MZ twins (a chained pair, so the correction runs through its union-find),
## and the generation numbers bent in each way the depth loop reads them.
seededKinshipCases <- function(seed) {
  p <- seededPedigree(40L, seed)
  base <- list(p$id, p$sire, p$dam, p$gen)
  x <- list(chrtype = "x", sex = p$sex)
  kids <- which(!is.na(p$sire) & !is.na(p$dam))
  twins <- data.frame(id1 = p$id[kids[1L:2L]], id2 = p$id[kids[2L:3L]],
                      code = "MZ twin", stringsAsFactors = FALSE)
  shuffled <- withr::with_seed(seed, sample(p$gen))
  selfSire <- replace(p$sire, 40L, p$id[40L])
  absentDam <- replace(p$dam, 39L, "nobody")
  cases <- list(
    autosome = base,
    x = c(base, x),
    `MZ twins` = c(base, list(twinRelations = twins)),
    `MZ twins, x` = c(base, list(twinRelations = twins), x),
    `generations shuffled` = list(p$id, p$sire, p$dam, shuffled),
    `generations shuffled, x` = c(list(p$id, p$sire, p$dam, shuffled), x),
    `generations + 0.5` = list(p$id, p$sire, p$dam, p$gen + 0.5),
    `generations doubled` = list(p$id, p$sire, p$dam, p$gen * 2L),
    `all generation 0` = list(p$id, p$sire, p$dam, 0L * p$gen),
    `all generation 1` = list(p$id, p$sire, p$dam, 0L * p$gen + 1L),
    `all generation 1, x` = c(list(p$id, p$sire, p$dam, 0L * p$gen + 1L), x),
    `own sire` = list(p$id, selfSire, p$dam, p$gen),
    `own sire, x` = c(list(p$id, selfSire, p$dam, p$gen), x),
    `dam not in the pedigree` = list(p$id, p$sire, absentDam, p$gen),
    `generations as text` = list(p$id, p$sire, p$dam, as.character(p$gen)),
    `ids as factors` = list(factor(p$id), factor(p$sire), factor(p$dam), p$gen),
    `every sex unknown, x` = c(base, list(chrtype = "x", sex = rep(NA, 40L))),
    `chrtype "X"` = c(base, list(chrtype = "X", sex = p$sex))
  )
  names(cases) <- sprintf("seed %d, %s", seed, names(cases))
  cases
}

## The kinship() grid: the shipped pedigrees, the example as the app trims it
## and whole, the twin fixtures of test_kinship.R, one animal, and the seeded
## pedigrees. Built once.
kinshipGrid <- local({
  cases <- NULL
  function() {
    if (is.null(cases)) {
      args <- function(p, ...) list(p$id, p$sire, p$dam, p$gen, ...)
      lacy <- nprcgenekeepr::lacy1989Ped
      qc <- qcStudbook(nprcgenekeepr::qcPed, minSireAge = 2L, minDamAge = 2L,
                       reportChanges = FALSE, reportErrors = FALSE)
      genotyped <- nprcgenekeepr::pedWithGenotype
      genotyped$gen <- findGeneration(genotyped$id, genotyped$sire,
                                      genotyped$dam)
      trim <- exampleAnalysisPed()
      fam1 <- data.frame(
        id = as.character(1L:10L),
        sire = c(NA, NA, "1", "1", NA, NA, "3", "6", "6", "8"),
        dam = c(NA, NA, "2", "2", NA, NA, "5", "4", "4", "7"),
        sex = c("M", "F", "M", "F", "F", "M", "F", "M", "M", "F"),
        stringsAsFactors = FALSE
      )
      fam1$gen <- findGeneration(fam1$id, fam1$sire, fam1$dam)
      twins89 <- data.frame(id1 = "8", id2 = "9", code = "MZ twin",
                            stringsAsFactors = FALSE)
      cases <<- c(
        list(
          lacy1989Ped = args(lacy),
          qcPed = args(qc),
          `qcPed, x` = args(qc, chrtype = "x", sex = qc$sex),
          pedWithGenotype = args(genotyped),
          `example (app trim)` = args(trim),
          `example (app trim), x` = args(trim, chrtype = "x", sex = trim$sex),
          `example (all 3,694)` = args(exampleLivingPed()),
          `fam1, MZ twins` = args(fam1, twinRelations = twins89),
          `fam1, MZ twins, x` = args(fam1, twinRelations = twins89,
                                     chrtype = "x", sex = fam1$sex),
          `one founder` = list("A", NA, NA, 0L),
          `one animal, parents not in the pedigree` = list("A", "S", "D", 1L),
          `one male, x` = list("A", NA, NA, 0L, chrtype = "x", sex = "M"),
          `one animal of unknown sex, x` = list("A", NA, NA, 0L,
                                                chrtype = "x", sex = "U")
        ),
        unlist(lapply(kinshipSeeds, seededKinshipCases), recursive = FALSE)
      )
    }
    cases
  }
})

## Inputs kinship()'s new code was not built for, and inputs it checks the way
## today's code does: each must give today's value, error and warnings.
oddKinshipCases <- function() {
  p <- seededPedigree(12L, 1L)
  list(
    `sparse = TRUE` = list(p$id, p$sire, p$dam, p$gen, sparse = TRUE),
    `sparse = TRUE, x` = list(p$id, p$sire, p$dam, p$gen, sparse = TRUE,
                              chrtype = "x", sex = p$sex),
    `sparse = NA` = list(p$id, p$sire, p$dam, p$gen, sparse = NA),
    `sparse = 0` = list(p$id, p$sire, p$dam, p$gen, sparse = 0L),
    `no animals` = list(character(0L), character(0L), character(0L),
                        integer(0L)),
    `a missing generation` = list(p$id, p$sire, p$dam,
                                  replace(p$gen, 3L, NA)),
    `one generation short` = list(p$id, p$sire, p$dam, p$gen[-1L]),
    `one sire short` = list(p$id, p$sire[-1L], p$dam, p$gen),
    `one dam short` = list(p$id, p$sire, p$dam[-1L], p$gen),
    `no generations` = list(p$id, p$sire, p$dam, NULL),
    `generations as a list` = list(p$id, p$sire, p$dam, as.list(p$gen)),
    `generations as a function` = list(p$id, p$sire, p$dam, function() 1L)
  )
}

## Inputs of the ordinary shape that today's code stops on or reads in its own
## way (a missing id is matched by a missing parent): the new code must give
## the same message or matrix.
checkedKinshipCases <- function() {
  p <- seededPedigree(12L, 1L)
  list(
    `a duplicated id` = list(c(p$id[1L], p$id[-12L]), p$sire, p$dam, p$gen),
    `an unknown chrtype` = list(p$id, p$sire, p$dam, p$gen, chrtype = "y"),
    `x without a sex` = list(p$id, p$sire, p$dam, p$gen, chrtype = "x"),
    `x with a short sex` = list(p$id, p$sire, p$dam, p$gen, chrtype = "x",
                                sex = "M"),
    `a twin not in the pedigree` = list(
      p$id, p$sire, p$dam, p$gen,
      twinRelations = data.frame(id1 = "zz", id2 = p$id[2L], code = "MZ twin")
    ),
    `a missing id` = list(replace(p$id, 2L, NA), p$sire, p$dam, p$gen)
  )
}

expectSameOutcomes <- function(cases, new, today) {
  for (name in names(cases)) {
    expect_identical(outcome(new, cases[[name]]),
                     outcome(today, cases[[name]]), info = name)
  }
}

test_that("kinship() gives today's matrix on the grid", {
  expectSameOutcomes(kinshipGrid(), kinship, kinshipReference)
})

test_that("on the grid kinship() never runs today's code", {
  local_mocked_bindings(kinshipGeneral = function(...) {
    stop("today's kinship() ran on an ordinary input")
  })
  expectSameOutcomes(kinshipGrid(), kinship, kinshipReference)
})

test_that("unusual kinship() inputs give today's value, error and warnings", {
  expectSameOutcomes(oddKinshipCases(), kinship, kinshipReference)
  expectSameOutcomes(checkedKinshipCases(), kinship, kinshipReference)
})

test_that("unusual kinship() inputs run today's code and the others the new", {
  local_mocked_bindings(kinshipGeneral = function(...) "today's code")
  for (name in names(oddKinshipCases())) {
    expect_identical(do.call(kinship, oddKinshipCases()[[name]]),
                     "today's code", info = name)
  }
  for (name in names(checkedKinshipCases())) {
    expect_false(identical(outcome(kinship, checkedKinshipCases()[[name]]),
                           list(value = "today's code",
                                warnings = character(0L))),
                 info = name)
  }
})

## The kinship matrices the long-form tests read: one per grid case but the
## whole example (its long form is 13.6 million rows; the opt-in budget test
## reads it), plus slices of the example's matrix (rectangular, one cell) and
## one of all NA.
longFormMatrices <- local({
  mats <- NULL
  function() {
    if (is.null(mats)) {
      grid <- kinshipGrid()
      keep <- !grepl("all 3,694", names(grid), fixed = TRUE)
      fromGrid <- lapply(grid[keep], function(args) {
        do.call(kinshipReference, args)
      })
      trim <- fromGrid[["example (app trim)"]]
      mats <<- c(fromGrid, list(
        `example (app trim), first 40 rows` = trim[1L:40L, ],
        `example (app trim), first 25 columns` = trim[, 1L:25L],
        `example (app trim), one cell` = trim[1L, 1L, drop = FALSE],
        `example, first 300 animals` = exampleRelationsInput(300L)$kmat,
        `all NA` = trim[1L:30L, 1L:30L] * NA
      ))
    }
    mats
  }
})

## Matrices kinMatrix2LongForm()'s new code was not built for, and odd
## removeDups values: each must give today's value, error and warnings.
oddLongFormCases <- function() {
  k <- kinshipReference(lacy1989Ped$id, lacy1989Ped$sire, lacy1989Ped$dam,
                        lacy1989Ped$gen)
  n <- nrow(k)
  ints <- k * 64L
  storage.mode(ints) <- "integer"
  list(
    `no dimnames` = list(unname(k)),
    `no row names` = list(`rownames<-`(k, NULL)),
    `no column names` = list(`colnames<-`(k, NULL)),
    `duplicated row names` = list(`rownames<-`(k, rep(rownames(k)[1L], n))),
    `duplicated column names` = list(`colnames<-`(k, rep("A", n))),
    `a missing row name` = list(`rownames<-`(k, replace(rownames(k), 2L, NA))),
    `a missing column name` = list(`colnames<-`(k, replace(colnames(k), 2L,
                                                           NA))),
    `an integer matrix` = list(ints),
    `an integer matrix, removeDups` = list(ints, TRUE),
    `a logical matrix` = list(k > 0.1),
    `no cells` = list(k[0L, 0L, drop = FALSE]),
    `no rows` = list(k[0L, , drop = FALSE]),
    `a sparse Matrix` = list(Matrix::Matrix(k, sparse = TRUE)),
    `a data frame` = list(as.data.frame(k)),
    `removeDups = NA` = list(k, NA),
    `removeDups = 1` = list(k, 1L),
    `removeDups = "TRUE"` = list(k, "TRUE")
  )
}

test_that("kinMatrix2LongForm() gives today's long form on the grid", {
  for (name in names(longFormMatrices())) {
    for (removeDups in c(FALSE, TRUE)) {
      args <- list(longFormMatrices()[[name]], removeDups)
      expect_identical(outcome(kinMatrix2LongForm, args),
                       outcome(kinMatrix2LongFormReference, args),
                       info = sprintf("%s, removeDups = %s", name, removeDups))
    }
  }
})

test_that("on the grid kinMatrix2LongForm() never runs today's code", {
  local_mocked_bindings(kinMatrix2LongFormGeneral = function(...) {
    stop("today's kinMatrix2LongForm() ran on an ordinary matrix")
  })
  for (name in names(longFormMatrices())) {
    for (removeDups in c(FALSE, TRUE)) {
      args <- list(longFormMatrices()[[name]], removeDups)
      expect_identical(outcome(kinMatrix2LongForm, args),
                       outcome(kinMatrix2LongFormReference, args),
                       info = sprintf("%s, removeDups = %s", name, removeDups))
    }
  }
})

test_that("unusual matrices give today's long form, error and warnings", {
  expectSameOutcomes(oddLongFormCases(), kinMatrix2LongForm,
                     kinMatrix2LongFormReference)
})

test_that("unusual matrices run today's long form and the others the new", {
  local_mocked_bindings(kinMatrix2LongFormGeneral = function(...) {
    "today's code"
  })
  for (name in names(oddLongFormCases())) {
    expect_identical(do.call(kinMatrix2LongForm, oddLongFormCases()[[name]]),
                     "today's code", info = name)
  }
})

pairThresholds <- c(0, 0.015625, 0.0625, 0.25, 0.5, 2, 1L)

test_that("highKinshipPairs() keeps the pairs today's long form and filter keep", {
  for (name in names(longFormMatrices())) {
    k <- longFormMatrices()[[name]]
    for (threshold in pairThresholds) {
      expect_identical(
        outcome(highKinshipPairs, list(k, threshold)),
        outcome(function(k, threshold) {
          filterThreshold(kinMatrix2LongFormReference(k), threshold)
        }, list(k, threshold)),
        info = sprintf("%s, threshold %s", name, threshold)
      )
    }
  }
})

## getAnimalsWithHighKinship() as group formation calls it: qcPed's matrix,
## and the tutorial's 280 candidates' rows of their pedigree's matrix
## (groupAddAssign() filters it the same way), with each filter on and off.
highKinshipCases <- function() {
  qc <- qcStudbook(nprcgenekeepr::qcPed, minSireAge = 2L, minDamAge = 2L,
                   reportChanges = FALSE, reportErrors = FALSE)
  qcKmat <- kinshipReference(qc$id, qc$sire, qc$dam, qc$gen)
  group <- exampleGroupInput()
  groupKmat <- group$kmat[group$candidates, group$candidates]
  inputs <- list(
    qcPed = list(kmat = qcKmat, ped = qc,
                 groups = list(nprcgenekeepr::examplePedigree$id[1L:3L])),
    `tutorial candidates` = list(kmat = groupKmat, ped = group$ped,
                                 groups = list(group$candidates[1L:5L]))
  )
  ignores <- list(`F-F` = list(c("F", "F")), none = list(),
                  `F-F and M-M` = list(c("F", "F"), c("M", "M")))
  cases <- list()
  add <- function(input, threshold, ignore, minAge, groups) {
    x <- inputs[[input]]
    current <- if (groups == "groups") x$groups else character(0L)
    name <- sprintf("%s, threshold %s, ignore %s, minAge %s, %s",
                    input, threshold, ignore, minAge, groups)
    cases[[name]] <<- list(x$kmat, x$ped, threshold, current,
                           ignore = ignores[[ignore]], minAge = minAge)
  }
  for (input in names(inputs)) {
    for (threshold in c(0.015625, 0.25)) {
      for (ignore in names(ignores)) {
        for (minAge in c(1, 5)) {
          for (groups in c("groups", "no groups")) {
            add(input, threshold, ignore, minAge, groups)
          }
        }
      }
    }
    ## Every pair (threshold 0) and no pair but an inbred animal's own cell
    ## (threshold 1): the slowest and the emptiest lists.
    add(input, 0, "F-F", 0, "groups")
    add(input, 1, "F-F", 1, "no groups")
  }
  cases
}

test_that("getAnimalsWithHighKinship() gives today's lists", {
  expectSameOutcomes(highKinshipCases(), getAnimalsWithHighKinship,
                     getAnimalsWithHighKinshipReference)
})

test_that("getAnimalsWithHighKinship() does not build the whole long form", {
  local_mocked_bindings(kinMatrix2LongForm = function(...) {
    stop("the whole long form was built")
  })
  expectSameOutcomes(highKinshipCases(), getAnimalsWithHighKinship,
                     getAnimalsWithHighKinshipReference)
})

test_that("an unusual matrix or threshold gives today's lists and errors", {
  qc <- qcStudbook(nprcgenekeepr::qcPed, minSireAge = 2L, minDamAge = 2L,
                   reportChanges = FALSE, reportErrors = FALSE)
  kmat <- kinshipReference(qc$id, qc$sire, qc$dam, qc$gen)
  groups <- list(nprcgenekeepr::examplePedigree$id[1L:3L])
  argsWith <- function(k, threshold) {
    list(k, qc, threshold, groups, ignore = list(c("F", "F")), minAge = 1)
  }
  cases <- list(
    `threshold NA` = argsWith(kmat, NA),
    `two thresholds` = argsWith(kmat, c(0.1, 0.2)),
    `threshold as text` = argsWith(kmat, "0.1"),
    `no threshold` = argsWith(kmat, numeric(0L)),
    `a sparse Matrix` = argsWith(Matrix::Matrix(kmat, sparse = TRUE), 0.1),
    `no dimnames` = argsWith(unname(kmat), 0.1),
    `an integer matrix` = argsWith(`storage.mode<-`(kmat * 64L, "integer"),
                                   2L)
  )
  expectSameOutcomes(cases, getAnimalsWithHighKinship,
                     getAnimalsWithHighKinshipReference)
})
