## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Inputs and messages shared by the performance and memory campaign's tests
## (docs/planning/performance-memory-campaign-plan.md, section 5): the
## equivalence tests (test_rareAlleleCounts.R, test_geneDropEquivalence.R,
## test_convertRelationshipsEquivalence.R) and the opt-in budget tests
## (test_perfBudget_*.R), test_groupAddAssignEquivalence.R and
## test_founderStatsEquivalence.R and test_diagramSolverEquivalence.R, the
## founder table's allocation counts
## (test_calcFounderContributions_tableOnce.R), the app-memory tests
## (test_kinshipForAnimals.R, test_kinshipForConsumers.R) and
## the measuring tools' tests (test_perfHarness.R, test_perfAppSession.R). The
## frozen copies of today's functions are in helper-perfReference.R.

## The example studbook QC'd as the app does, with the living animals as the
## population, untrimmed (all 3,694 animals): R/modPedigree.R's path, which
## tools/perf/harness.R appAnalysisPed() also takes, but tools/ is not in a
## built package, and these tests must run on every CI platform. Built once,
## on first use.
exampleLivingPed <- local({
  ped <- NULL
  function() {
    if (is.null(ped)) {
      sb <- qcStudbook(nprcgenekeepr::examplePedigree,
                       minSireAge = 2L, minDamAge = 2L,
                       reportChanges = FALSE, reportErrors = FALSE)
      p <- setPopulation(sb, sb$id[isLivingAnimal(sb)])
      p$pedNum <- findPedigreeNumber(p$id, p$sire, p$dam)
      if (!"gen" %in% names(p)) {
        p$gen <- findGeneration(p$id, p$sire, p$dam)
      }
      ped <<- p
    }
    ped
  }
})

## The example studbook as the app trims it for the Genetic Value analysis
## (R/modGeneticValue.R). Built once, on first use.
exampleAnalysisPed <- local({
  ped <- NULL
  function() {
    if (is.null(ped)) {
      ped <<- trimToAnalysisPopulation(exampleLivingPed())
    }
    ped
  }
})

## The example studbook as the app's Summary Statistics sees it, untrimmed,
## with the kinship matrix of the whole pedigree (R/appServer.R
## sharedKinshipMatrix; tools/perf/harness.R exampleLiving() and pedKinship()
## do the same for the relationship-table rows). Built once, on first use.
exampleColony <- local({
  colony <- NULL
  function() {
    if (is.null(colony)) {
      p <- exampleLivingPed()
      colony <<- list(
        ped = p,
        kmat = kinship(p$id, p$sire, p$dam, p$gen, sparse = FALSE)
      )
    }
    colony
  }
})

## The same pedigree as the app holds it after upload, its whole kinship
## matrix and its living animals, for the app-memory tests (Phase 9).
examplePed <- function() exampleLivingPed()
exampleFull <- function() exampleColony()$kmat
exampleLivingIds <- function() {
  ped <- examplePed()
  ped$id[isLivingAnimal(ped)]
}

## tools/ and BACKLOG.md are build-ignored, so the measuring tools' tests skip
## outside the source tree (tools/perf/ is not in a built package).
skipUnlessSourceTree <- function() {
  skip_if_not(file.exists(testthat::test_path("..", "..", "BACKLOG.md")),
              "not the source tree: tools/perf/ is not in a built package")
}

## The relationship table's input for the example's first `n` animals: their
## rows and columns of the whole pedigree's kinship matrix, and the whole
## pedigree (tools/perf/harness.R convertRelationshipsScenario()).
exampleRelationsInput <- function(n) {
  colony <- exampleColony()
  ids <- rownames(colony$kmat)[seq_len(n)]
  list(kmat = colony$kmat[ids, ids], ped = colony$ped)
}

## Group formation as the tutorial sets it up (tools/perf/harness.R
## groupAddAssignScenario(), the ratchet gate perf_groupAddAssign_1000_seconds):
## the living animals with a recorded parent, trimmed to their ancestors (704
## animals), with that pedigree's kinship matrix; the candidates are the
## animals born before 2013 and alive (280). Built once, on first use.
exampleGroupInput <- local({
  input <- NULL
  function() {
    if (is.null(input)) {
      sb <- qcStudbook(nprcgenekeepr::examplePedigree,
                       minSireAge = 2L, minDamAge = 2L,
                       reportChanges = FALSE, reportErrors = FALSE)
      focal <- sb$id[!(is.na(sb$sire) & is.na(sb$dam)) & is.na(sb$exit)]
      ped <- trimPedigree(focal, sb)
      input <<- list(
        ped = ped,
        kmat = kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE),
        candidates = ped$id[!is.na(ped$birth) &
                              ped$birth < as.Date("2013-01-01") &
                              is.na(ped$exit)]
      )
    }
    input
  }
})

## The relatives list groupAddAssign() builds with its default settings
## (kinship above 0.015625, female pairs ignored, minimum age 1) and hands to
## fillGroupMembers(): each candidate's relatives among `candidates`.
defaultRelatives <- function(candidates, kmat, ped) {
  addAnimalsWithNoRelative(
    getAnimalsWithHighKinship(filterKinMatrix(candidates, kmat), ped,
                              0.015625, list(character(0L)),
                              list(c("F", "F")), 1.0),
    candidates
  )
}

## The value, error message and warnings of one call, from a fixed seed (1 by
## default): the equivalence tests compare today's function and the new code on
## unusual inputs with it (test_rareAlleleCounts.R has its own one-argument
## outcome()).
outcome <- function(f, args, seed = 1L) {
  warnings <- character()
  withr::with_seed(seed, tryCatch(
    withCallingHandlers(
      list(value = do.call(f, args), warnings = warnings),
      warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) {
      list(error = conditionMessage(e), warnings = warnings)
    }
  ))
}

## Genotype codes as integers: pedWithGenotype ships its codes as doubles, and
## the plan's grid runs both.
integerCodes <- function(genotype) {
  genotype$first <- as.integer(genotype$first)
  genotype$second <- as.integer(genotype$second)
  genotype
}

## The load average, for a budget test's failure message: wall-clock limits
## fail under desktop load.
loadAverage <- function() {
  tryCatch(paste(system2("uptime", stdout = TRUE), collapse = " "),
           error = function(e) "unavailable", warning = function(w) {
             "unavailable"
           })
}

## The .solveJointQP() calls makePedigreeMatingLayout() makes for `ped`, as
## lists of their arguments. The frozen copy answers each call, so the calls
## after the first do not depend on the code under test.
diagramSolverCalls <- function(ped) {
  calls <- list()
  answer <- function(provisionalPos, matingUnits, duplicates, childEdges,
                     ...) {
    calls[[length(calls) + 1L]] <<- list(provisionalPos, matingUnits,
                                         duplicates, childEdges, ...)
    solveJointQPReference(provisionalPos, matingUnits, duplicates,
                          childEdges, ...)
  }
  testthat::with_mocked_bindings(
    suppressMessages(suppressWarnings(
      makePedigreeMatingLayout(ped, edgeStyle = "direct")
    )),
    .solveJointQP = answer, .package = "nprcgenekeepr"
  )
  calls
}

## The penalty table one .solveJointQP() call multiplies by itself (pmat, one
## row per penalty term), read from the frozen copy: its statements up to the
## one that stacks the rows, so the table does not depend on the code under
## test (S1073).
penaltyMatrixOf <- function(args) {
  f <- solveJointQPReference
  steps <- as.list(body(f))
  last <- which(vapply(steps, identical, logical(1L),
                       quote(pmat <- do.call(rbind, pmatRows))))
  stopifnot(length(last) == 1L)
  body(f) <- as.call(c(steps[seq_len(last)], quote(pmat)))
  do.call(f, args)
}
