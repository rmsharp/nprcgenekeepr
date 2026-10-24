## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Inputs and messages shared by the performance and memory campaign's tests
## (docs/planning/performance-memory-campaign-plan.md, section 5): the
## equivalence tests (test_rareAlleleCounts.R, test_geneDropEquivalence.R,
## test_convertRelationshipsEquivalence.R) and the opt-in budget tests
## (test_perfBudget_*.R). The frozen copies of today's
## functions are in helper-perfReference.R.

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

## The relationship table's input for the example's first `n` animals: their
## rows and columns of the whole pedigree's kinship matrix, and the whole
## pedigree (tools/perf/harness.R convertRelationshipsScenario()).
exampleRelationsInput <- function(n) {
  colony <- exampleColony()
  ids <- rownames(colony$kmat)[seq_len(n)]
  list(kmat = colony$kmat[ids, ids], ped = colony$ped)
}

## The value, error message and warnings of one call, from a fixed seed: the
## equivalence tests compare today's function and the new code on unusual
## inputs with it (test_rareAlleleCounts.R has its own one-argument outcome()).
outcome <- function(f, args) {
  warnings <- character()
  withr::with_seed(1L, tryCatch(
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
