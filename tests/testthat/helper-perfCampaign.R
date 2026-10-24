## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Inputs and messages shared by the performance and memory campaign's tests
## (docs/planning/performance-memory-campaign-plan.md, section 5): the
## equivalence tests (test_rareAlleleCounts.R, test_geneDropEquivalence.R) and
## the opt-in budget tests (test_perfBudget_*.R). The frozen copies of today's
## functions are in helper-perfReference.R.

## The example studbook as the app trims it for the Genetic Value analysis
## (R/modPedigree.R, then R/modGeneticValue.R; tools/perf/harness.R
## appAnalysisPed() does the same, but tools/ is not in a built package, and
## these tests must run on every CI platform). Built once, on first use.
exampleAnalysisPed <- local({
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
      ped <<- trimToAnalysisPopulation(p)
    }
    ped
  }
})

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
