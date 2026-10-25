## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## BACKLOG.md "Performance and memory campaign: Phase 7, the diagram's solver"
## (owner pick S1060; plan docs/planning/performance-memory-campaign-plan.md,
## Phase 7 and section 5.1). .solveJointQP() handed quadprog::solve.QP() one
## dense column per separation constraint, n entries long with two of them
## nonzero, so the solver's sums ran over every node for every constraint:
## 11.3 s of the 13.2 s the example's diagram took (S1060; 708 animals, one
## solve over 1,489 nodes). It now hands quadprog::solve.QP.compact() each
## constraint's two entries, listed in the order of their rows. The two
## routines differ only in those sums, and the dense one adds a column's
## nonzero entries in row order, so the compact one adds the same numbers in
## the same order: 3.0 s with identical positions (a prototype, S1060).
##
## The owner's rulings: every result stays exactly today's (D1), and an input
## the new code was not built for runs today's code unchanged (owner ruling
## S1059, as in Phases 1-6). Here that is a quadratic or a floor with a
## missing or infinite number: today's solve.QP() stops on it with an error
## that names the argument by its position ("arg 1", "arg 9"), and the compact
## routine numbers its arguments differently. The owner also kept today's
## t(pmat) %*% pmat (S1060): crossprod() was slower on this Mac and would run
## a different BLAS routine on CI's Ubuntu runners. So each block compares the
## new code with the frozen copy (helper-perfReference.R) using identical().

## A seeded pedigree of n animals in birth order for the diagram: a fifth are
## founders, each later animal draws a sire from the males and a dam from the
## females before it, so parents mate more than once and the layout makes
## duplicate nodes; one parent in ten is left unknown and one animal in twenty
## has an unknown sex.
seededDiagramPed <- function(n, seed) {
  withr::with_seed(seed, {
    founders <- max(2L, n %/% 5L)
    id <- sprintf("A%03d", seq_len(n))
    sex <- rep(c("M", "F"), length.out = n)
    sex[sample.int(n, max(1L, n %/% 20L))] <- "U"
    sex[1L:2L] <- c("M", "F")
    sire <- rep(NA_character_, n)
    dam <- rep(NA_character_, n)
    for (i in seq.int(founders + 1L, n)) {
      males <- which(sex[seq_len(i - 1L)] == "M")
      females <- which(sex[seq_len(i - 1L)] == "F")
      if (stats::runif(1L) >= 0.1) {
        sire[i] <- id[males[sample.int(length(males), 1L)]]
      }
      if (stats::runif(1L) >= 0.1) {
        dam[i] <- id[females[sample.int(length(females), 1L)]]
      }
    }
    ped <- data.frame(id = id, sire = sire, dam = dam, sex = sex,
                      stringsAsFactors = FALSE)
    ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
    ped
  })
}

## The pedigrees of the grid: the shipped ones (lacy1989Ped has no sex column,
## so its sires are given "M", its dams "F" and the rest "U"), the bundled
## 375-animal rhesus fixture the diagram tests pin, the issue #154 orphan unit,
## and seeded pedigrees.
diagramGridPeds <- function() {
  lacy <- lacy1989Ped
  lacy$sex <- ifelse(lacy$id %in% lacy$sire, "M",
                     ifelse(lacy$id %in% lacy$dam, "F", "U"))
  peds <- list(
    `lacy1989Ped, sexes added` = lacy,
    qcPed = qcPed,
    pedWithGenotype = pedWithGenotype,
    `the rhesus fixture` = read.csv(
      system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                  package = "nprcgenekeepr"),
      stringsAsFactors = FALSE
    ),
    `an orphan mating unit` = data.frame(
      id = "CHILD", sire = "DANGLING_SIRE", dam = "DANGLING_DAM", sex = "F",
      gen = 0L, stringsAsFactors = FALSE
    )
  )
  for (seed in c(1L, 7L, 2026L)) {
    peds[[sprintf("seeded, 40 animals, seed %d", seed)]] <-
      seededDiagramPed(40L, seed)
  }
  peds[["seeded, 12 animals, seed 1"]] <- seededDiagramPed(12L, 1L)
  peds[["seeded, 150 animals, seed 7"]] <- seededDiagramPed(150L, 7L)
  peds
}

## Every .solveJointQP() call the grid's diagrams make (17, from 2 to 733
## nodes, S1060), and today's outcome of each. Built once.
diagramSolverGrid <- local({
  peds <- diagramGridPeds()
  grid <- list()
  for (name in names(peds)) {
    calls <- diagramSolverCalls(peds[[name]])
    for (i in seq_along(calls)) {
      grid[[sprintf("%s, call %d", name, i)]] <- calls[[i]]
    }
  }
  grid
})
diagramSolverToday <- lapply(diagramSolverGrid, function(args) {
  outcome(solveJointQPReference, args)
})

## Unusual inputs, built on the 87-node call of the 40-animal seed-7 pedigree
## (22 duplicate nodes), each with today's solver route as S1060 measured it.
## "dense": a missing or infinite number reaches the solver, so the new code
## must run today's solve.QP(); "compact": the new code's own solve;
## "neither": today's code stops before any solve.
unusualSolverCases <- function() {
  grid <- diagramSolverGrid[grepl("^seeded, 40 animals, seed 7, ",
                                  names(diagramSolverGrid))]
  base <- grid[[which.max(vapply(grid, function(args) nrow(args[[1L]]),
                                 integer(1L)))]][1L:4L]
  pos <- base[[1L]]
  none <- lapply(base[2L:4L], function(d) d[0L, , drop = FALSE])
  withPos <- function(newPos) c(list(newPos), base[2L:4L])
  list(
    `a missing spousal weight` = list(c(base, list(wSpouse = NaN)), "dense"),
    `a negative union weight` = list(c(base, list(wUnion = -1.0)), "dense"),
    `an infinite duplicate weight` = list(c(base, list(wDup = Inf)), "dense"),
    `an infinite spacing` = list(c(base, list(minSep = Inf)), "dense"),
    `a missing spacing` = list(c(base, list(minSep = NA_real_)), "dense"),
    `a NaN spacing` = list(c(base, list(minSep = NaN)), "dense"),
    `an infinite child exponent` = list(c(base, list(alignChild = Inf)),
                                        "compact"),
    `a zero spacing` = list(c(base, list(minSep = 0.0)), "compact"),
    `a negative spacing` = list(c(base, list(minSep = -1.0)), "compact"),
    `a huge spacing` = list(c(base, list(minSep = 1e300)), "compact"),
    `one node` = list(c(list(pos[1L, , drop = FALSE]), none), "compact"),
    `every node in its own row` = list(
      withPos(transform(pos, gen = seq_len(nrow(pos)))), "compact"
    ),
    `a missing x` = list(withPos(transform(pos, x = replace(x, 3L, NA))),
                         "compact"),
    `a spacing as text` = list(c(base, list(minSep = "1")), "neither"),
    `no nodes` = list(c(list(pos[0L, , drop = FALSE]), none), "neither"),
    `a duplicated id` = list(
      withPos(transform(pos, id = replace(id, 2L, id[1L]))), "neither"
    )
  )
}

## Which of quadprog's two solvers .solveJointQP() reached for `args`: each is
## replaced by a stub that records its name and stops. Warnings are muted
## here; the outcome tests compare them with today's.
solversReached <- function(args) {
  reached <- character(0L)
  stopAt <- function(name) {
    function(...) {
      reached <<- c(reached, name)
      stop("stopped at the solver")
    }
  }
  testthat::with_mocked_bindings(
    try(suppressWarnings(do.call(.solveJointQP, args)), silent = TRUE),
    solve.QP = stopAt("dense"), solve.QP.compact = stopAt("compact"),
    .package = "quadprog"
  )
  reached
}

test_that(".solveJointQP() gives today's positions on the grid", {
  for (name in names(diagramSolverGrid)) {
    expect_identical(outcome(.solveJointQP, diagramSolverGrid[[name]]),
                     diagramSolverToday[[name]], info = name)
  }
})

test_that("on the grid .solveJointQP() never runs today's dense solve", {
  local_mocked_bindings(
    solve.QP = function(...) {
      stop("today's dense quadprog::solve.QP() ran on an ordinary input")
    },
    .package = "quadprog"
  )
  for (name in names(diagramSolverGrid)) {
    expect_identical(outcome(.solveJointQP, diagramSolverGrid[[name]]),
                     diagramSolverToday[[name]], info = name)
  }
})

test_that("on the grid .solveJointQP() solves once, with the compact solver", {
  for (name in names(diagramSolverGrid)) {
    expect_identical(solversReached(diagramSolverGrid[[name]]), "compact",
                     info = name)
  }
})

test_that("unusual .solveJointQP() inputs give today's value, error and warnings", {
  cases <- unusualSolverCases()
  for (name in names(cases)) {
    args <- cases[[name]][[1L]]
    expect_identical(outcome(.solveJointQP, args),
                     outcome(solveJointQPReference, args), info = name)
  }
})

test_that("only inputs with a missing or infinite number run today's dense solve", {
  cases <- unusualSolverCases()
  for (name in names(cases)) {
    expected <- switch(cases[[name]][[2L]],
                       dense = "dense", compact = "compact",
                       neither = character(0L))
    expect_identical(solversReached(cases[[name]][[1L]]), expected,
                     info = name)
  }
})
