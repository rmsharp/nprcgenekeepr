## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 9, the app's memory:
## implementation, session 9a" (owner pick S1063; design
## docs/planning/app-kinship-memory-design.md sections 6.1 and 7.1 item 6;
## D5 ruled (c) S1062). Breeding Groups, Genetic Diversity and Mate Pair each
## need the kinship of a few animals: the candidates plus any seed animals,
## the formed groups' members, and the Mate Pair population. Today each is
## handed the app's whole kinship matrix. Under D5 (c) each module server
## takes an optional kinshipFor: a function of the ids it needs that returns
## their kinship (in the app, kinshipForAnimals() on the current pedigree,
## R/appServer.R). A handed-in kinshipMatrix still comes first, so scripts and
## the module tests that pass one keep today's behavior.
##
## Each test runs a module under testServer() twice, once given today's whole
## matrix and once given kinshipFor, and compares what it produced with
## identical(). The 9b modules (Summary Statistics, Marker Genetics) are not
## here yet.

## Slow shiny-module integration tests; skip on CRAN as the module tests do.
## They run on CI and locally.
testthat::skip_on_cran()

## examplePed(), exampleFull() and exampleLivingIds() are in
## helper-perfCampaign.R.

## A kinshipFor that records each set of ids it is asked for, a request for
## every animal (ids = NULL) included.
recordingProvider <- function(ped) {
  asked <- list()
  list(
    provider = function(ids = NULL) {
      asked <<- c(asked, list(ids))
      kinshipForAnimals(ped, ids)
    },
    asked = function() asked
  )
}

## The value of one call, or the message of the error it raised.
valueOrError <- function(f) {
  tryCatch(f(), error = function(e) list(error = conditionMessage(e)))
}

## ---------------------------------------------------------------------------
## Breeding Groups
## ---------------------------------------------------------------------------

## One Form Groups click on the example's living animals ("all" source, 3
## groups, kinship limit 0.25, kinship shown) from a fixed seed: what
## groupAddAssign() returned and the kinship matrix the run kept.
formGroupsRun <- function(seed, harem = FALSE, kinshipMatrix = NULL,
                          kinshipFor = NULL, seedAnimals = character(0L)) {
  ped <- examplePed()
  run <- list()
  realGroupAddAssign <- groupAddAssign
  testthat::local_mocked_bindings(
    groupAddAssign = function(...) {
      run$result <<- realGroupAddAssign(...)
      run$result
    },
    .package = "nprcgenekeepr"
  )
  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive(ped),
      geneticValues = NULL,
      kinshipMatrix = kinshipMatrix,
      kinshipFor = kinshipFor
    ),
    {
      session$setInputs(
        animalSource = "all",
        nGroups = 3L,
        maxKinship = 0.25,
        sexRatio = if (harem) "harem" else "none",
        withKinship = TRUE,
        seedGroups = length(seedAnimals) > 0L,
        curGrp1 = toString(seedAnimals)
      )
      withr::with_seed(seed, session$setInputs(formGroups = 1L),
                       .rng_kind = "Mersenne-Twister",
                       .rng_normal_kind = "Inversion",
                       .rng_sample_kind = "Rejection")
      run$kept <<- groupResults()$kmat
    }
  )
  run
}

test_that(paste("Breeding Groups forms the same groups from its own animals'",
                "kinship as from the whole matrix, for seeds 1, 7 and 2026,",
                "plain and harem (design 7.1 item 6)"), {
  full <- exampleFull()
  for (seed in c(1L, 7L, 2026L)) {
    for (harem in c(FALSE, TRUE)) {
      info <- sprintf("seed %d, harem %s", seed, harem)
      viaMatrix <- formGroupsRun(seed, harem,
                                 kinshipMatrix = shiny::reactive(full))
      viaProvider <- formGroupsRun(
        seed, harem, kinshipFor = recordingProvider(examplePed())$provider
      )
      expect_false(is.null(viaMatrix$result), info = info)
      expect_identical(viaProvider$result, viaMatrix$result, info = info)
    }
  }
})

test_that(paste("Breeding Groups asks once, for its candidates and seed",
                "animals, and keeps only their kinship"), {
  ped <- examplePed()
  living <- exampleLivingIds()
  ## A seed animal the user types need not be alive (R/modBreedingGroups.R).
  seedAnimals <- c(living[[1L]], ped$id[!isLivingAnimal(ped)][[1L]])
  needed <- union(living, seedAnimals)
  recorder <- recordingProvider(ped)
  viaProvider <- formGroupsRun(1L, kinshipFor = recorder$provider,
                               seedAnimals = seedAnimals)
  viaMatrix <- formGroupsRun(1L, kinshipMatrix = shiny::reactive(exampleFull()),
                             seedAnimals = seedAnimals)
  expect_length(recorder$asked(), 1L)
  expect_setequal(recorder$asked()[[1L]], needed)
  expect_setequal(rownames(viaProvider$kept), needed)
  expect_identical(viaProvider$result, viaMatrix$result)
})

test_that("Breeding Groups uses a handed-in kinshipMatrix before kinshipFor", {
  full <- exampleFull()
  recorder <- recordingProvider(examplePed())
  both <- formGroupsRun(7L, kinshipMatrix = shiny::reactive(full),
                        kinshipFor = recorder$provider)
  matrixOnly <- formGroupsRun(7L, kinshipMatrix = shiny::reactive(full))
  expect_length(recorder$asked(), 0L)
  expect_identical(both$result, matrixOnly$result)
  expect_identical(both$kept, full)
})

## ---------------------------------------------------------------------------
## Genetic Diversity
## ---------------------------------------------------------------------------

diversityGroups <- function() {
  living <- exampleLivingIds()
  list(living[1:10], living[11:25], living[26:40])
}
diversityReport <- function() {
  living <- exampleLivingIds()
  data.frame(id = living,
             value = rep(c("High Value", "Low Value"), length.out = length(living)),
             stringsAsFactors = FALSE)
}

## The Genetic Diversity module's stats() under testServer(), or the message
## of the error it raised.
diversityRun <- function(groups = diversityGroups(), report = diversityReport(),
                         kinshipMatrix = NULL, kinshipFor = NULL) {
  ped <- examplePed()
  stats <- NULL
  shiny::testServer(
    modGeneticDiversityServer,
    args = list(
      groups = shiny::reactive(groups),
      pedigree = shiny::reactive(ped),
      geneticValues = shiny::reactive(report),
      kinshipMatrix = kinshipMatrix,
      kinshipFor = kinshipFor,
      currentDate = as.Date("2020-07-01")
    ),
    {
      stats <<- valueOrError(function() session$getReturned()$stats())
    }
  )
  stats
}

test_that(paste("Genetic Diversity's statistics are the same from its groups'",
                "kinship as from the whole matrix (design 7.1 item 6)"), {
  viaMatrix <- diversityRun(kinshipMatrix = shiny::reactive(exampleFull()))
  viaProvider <- diversityRun(
    kinshipFor = recordingProvider(examplePed())$provider
  )
  expect_s3_class(viaMatrix, "data.frame")
  expect_identical(viaProvider, viaMatrix)
})

test_that(paste("Genetic Diversity asks for kinship only once groups and the",
                "report exist, and then for the group members only"), {
  noGroups <- recordingProvider(examplePed())
  expect_null(diversityRun(groups = NULL, kinshipFor = noGroups$provider))
  expect_length(noGroups$asked(), 0L)

  noReport <- recordingProvider(examplePed())
  expect_null(diversityRun(report = NULL, kinshipFor = noReport$provider))
  expect_length(noReport$asked(), 0L)

  ready <- recordingProvider(examplePed())
  diversityRun(kinshipFor = ready$provider)
  expect_length(ready$asked(), 1L)
  expect_setequal(ready$asked()[[1L]], unique(unlist(diversityGroups())))
})

test_that(paste("a group member missing from the pedigree gives Genetic",
                "Diversity today's error"), {
  groups <- c(diversityGroups(), list(c(exampleLivingIds()[41:45],
                                        "NOT_AN_ID")))
  viaMatrix <- diversityRun(groups = groups,
                            kinshipMatrix = shiny::reactive(exampleFull()))
  viaProvider <- diversityRun(
    groups = groups, kinshipFor = recordingProvider(examplePed())$provider
  )
  expect_false(is.null(viaMatrix$error))
  expect_identical(viaProvider, viaMatrix)
})

test_that("Genetic Diversity uses a handed-in kinshipMatrix before kinshipFor", {
  recorder <- recordingProvider(examplePed())
  both <- diversityRun(kinshipMatrix = shiny::reactive(exampleFull()),
                       kinshipFor = recorder$provider)
  expect_length(recorder$asked(), 0L)
  expect_identical(both,
                   diversityRun(kinshipMatrix = shiny::reactive(exampleFull())))
})

test_that("Genetic Diversity waits when given neither kinship source", {
  expect_null(diversityRun())
})

## ---------------------------------------------------------------------------
## Mate Pair
## ---------------------------------------------------------------------------

matePairPed <- function() nprcgenekeepr::qcPed
matePairFull <- function() {
  ped <- matePairPed()
  kinship(ped$id, ped$sire, ped$dam, ped$gen)
}
matePairReport <- function() {
  ped <- matePairPed()
  ids <- ped$id[is.na(ped$exit)][1:30]
  data.frame(id = ids, indivMeanKin = seq(0.01, 0.30, length.out = 30L),
             gu = seq(30, 1, length.out = 30L), stringsAsFactors = FALSE)
}

## One Find Eligible Pairs click on qcPed: the stored report and the count of
## animals left out, or the message of the error it raised.
matePairRun <- function(source, customIds = "", kinshipMatrix = NULL,
                        kinshipFor = NULL) {
  ped <- matePairPed()
  out <- NULL
  shiny::testServer(
    modMatePairServer,
    args = list(
      pedigree = shiny::reactive(ped),
      kinshipMatrix = kinshipMatrix,
      kinshipFor = kinshipFor,
      markerKinshipMatrix = shiny::reactive(NULL),
      geneticValues = shiny::reactive(matePairReport())
    ),
    {
      session$setInputs(populationSource = source, nTopAnimals = 20L,
                        customPopulationIds = customIds, minAge = 1)
      session$setInputs(analyze = 1L)
      out <<- list(report = matchResults(), leftOut = leftOutCount(),
                   ready = session$getReturned()$isReady())
    }
  )
  out
}

test_that(paste("Mate Pair's report is the same from its population's",
                "kinship as from the whole matrix (design 7.1 item 6)"), {
  ped <- matePairPed()
  full <- matePairFull()
  runs <- list(
    allAlive = list(source = "allAlive"),
    topRanked = list(source = "topRanked"),
    customWithAnUnknownId = list(
      source = "custom",
      customIds = paste(c(ped$id[is.na(ped$exit)][1:12], "NOT_AN_ID",
                          ped$id[is.na(ped$exit)][[1L]]), collapse = ", ")
    ),
    customEmpty = list(source = "custom", customIds = "")
  )
  for (name in names(runs)) {
    viaMatrix <- do.call(matePairRun, c(runs[[name]], list(
      kinshipMatrix = shiny::reactive(full)
    )))
    viaProvider <- do.call(matePairRun, c(runs[[name]], list(
      kinshipFor = recordingProvider(ped)$provider
    )))
    expect_true(viaMatrix$ready, info = name)
    expect_identical(viaProvider, viaMatrix, info = name)
  }
})

test_that("Mate Pair asks once, for its population only", {
  ped <- matePairPed()
  recorder <- recordingProvider(ped)
  matePairRun("allAlive", kinshipFor = recorder$provider)
  expect_length(recorder$asked(), 1L)
  expect_setequal(recorder$asked()[[1L]], ped$id[is.na(ped$exit)])
})

test_that("Mate Pair uses a handed-in kinshipMatrix before kinshipFor", {
  full <- matePairFull()
  recorder <- recordingProvider(matePairPed())
  both <- matePairRun("allAlive", kinshipMatrix = shiny::reactive(full),
                      kinshipFor = recorder$provider)
  expect_length(recorder$asked(), 0L)
  expect_identical(both, matePairRun("allAlive",
                                     kinshipMatrix = shiny::reactive(full)))
})

test_that("Mate Pair runs nothing when given neither kinship source", {
  run <- matePairRun("allAlive")
  expect_false(run$ready)
  expect_null(run$report)
})
