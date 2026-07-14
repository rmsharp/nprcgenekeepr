# Cross-cutting guard test for the Shiny module contract (issue #122 Phase 5).
# See docs/architecture/module-contract.md for the full contract. This file
# mechanically enforces rule 2 -- every mod*Server returns a NAMED LIST OF
# REACTIVES whose elements are all functions -- for every module in the
# package, in one place, so a future module can't quietly ship a violation.
#
# Per-module test files already spot-check parts of this (e.g.
# test_modInput.R, test_modGeneticDiversity.R), but none of them are
# exhaustive or uniform across all 10 modules. This file is the single source
# of truth for the return-shape contract; it does not replace those files'
# behavioral tests.
#
# Minimal reactive(NULL) fixtures are deliberate: this test checks SHAPE, not
# business logic, so upstream data readiness is irrelevant -- every mod*Server
# constructs its returned list unconditionally, before any inner reactive is
# ever forced.

moduleContractServers <- list(
  modInput = list(
    server = modInputServer,
    args = list(),
    names = c("cleanedStudbook", "genotypeData", "qcSummary", "minSireAge",
              "minDamAge", "isReady", "debugMode", "changedCols", "errorLst",
              "pedigreeFileName")
  ),
  modPedigree = list(
    server = modPedigreeServer,
    args = list(studbook = shiny::reactive(NULL)),
    names = c("pedigree", "processedPedigree", "focalAnimals", "nAnimals",
              "populationCount", "isReady")
  ),
  modGeneticValue = list(
    server = modGeneticValueServer,
    args = list(pedigree = shiny::reactive(NULL)),
    names = c("geneticValues", "topAnimals", "nAnalyzed", "kinshipMatrix",
              "kinshipOverrides", "founderStats", "maleFounders",
              "femaleFounders")
  ),
  modSummaryStats = list(
    server = modSummaryStatsServer,
    args = list(geneticValues = shiny::reactive(NULL),
                pedigree = shiny::reactive(NULL)),
    names = c("summaryData", "relationships", "relationClasses",
              "firstOrderCounts", "mkSummary", "guSummary", "mkHistogram",
              "zscoreHistogram", "guHistogram", "meanKinshipBoxPlot",
              "zscoreBoxPlot", "guBoxPlot")
  ),
  modORIPReporting = list(
    server = modORIPReportingServer,
    args = list(pedigree = shiny::reactive(NULL),
                geneticValues = shiny::reactive(NULL)),
    names = c("colonySummary")
  ),
  modBreedingGroups = list(
    server = modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive(NULL)),
    names = c("groups", "nGroups", "score", "unassigned", "groupKinship")
  ),
  modPyramid = list(
    server = modPyramidServer,
    args = list(pedigreeData = shiny::reactive(NULL)),
    names = c("pedigree", "animalCount")
  ),
  modGeneticDiversity = list(
    server = modGeneticDiversityServer,
    args = list(groups = shiny::reactive(NULL),
                pedigree = shiny::reactive(NULL),
                geneticValues = shiny::reactive(NULL),
                kinshipMatrix = shiny::reactive(NULL)),
    names = c("stats", "heatmap")
  ),
  modPotentialParents = list(
    server = modPotentialParentsServer,
    args = list(),
    names = c("potentialParents", "tableData", "gestationDefault")
  )
)

for (moduleName in names(moduleContractServers)) {
  local({
    name <- moduleName
    spec <- moduleContractServers[[name]]

    test_that(paste0(name, "Server's return matches the module contract",
                      " (named list of reactives)"), {
      skip_if_not_installed("shiny")

      shiny::testServer(spec$server, args = spec$args, {
        result <- session$getReturned()

        expect_true(is.list(result))
        expect_named(result, spec$names, ignore.order = TRUE)
        for (elementName in names(result)) {
          expect_true(
            is.function(result[[elementName]]),
            info = paste0(name, "Server$", elementName,
                          " must be a reactive (a function)")
          )
        }
      })
    })
  })
}

test_that(paste0("modGvAndBgDescServer's bare NULL return is the documented",
                  " contract exception"), {
  skip_if_not_installed("shiny")

  # See docs/architecture/module-contract.md's "Documented exceptions":
  # this module is genuinely stateless (informational-only tab, no reactive
  # state to expose) -- the guard test carves it out explicitly rather than
  # silently.
  shiny::testServer(modGvAndBgDescServer, args = list(), {
    result <- session$getReturned()
    expect_null(result)
  })
})
