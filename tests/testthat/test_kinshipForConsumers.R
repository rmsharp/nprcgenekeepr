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
## identical().
##
## Session 9b (owner pick S1064; design sections 6.1, 7.1 item 6 and 8): the
## four reads that need every animal take kinshipFor too, and ask it for every
## animal (ids = NULL) when the user asks: Summary Statistics' kinship CSV and
## relationship downloads, and Marker Genetics' Kinship Comparison and
## Realized Relatedness tables. Nothing of the whole colony's size is kept for
## them between clicks; appServer keeps no shared matrix.

## Slow shiny-module integration tests; skip on CRAN as the module tests do.
## They run on CI and locally.
testthat::skip_on_cran()

## examplePed(), exampleFull(), exampleLivingIds() and outcome() are in
## helper-perfCampaign.R.

## A kinshipFor that records each set of ids it is asked for, a request for
## every animal (ids = NULL) included. It applies the twins and overrides it
## is given, as appServer's provider does.
recordingProvider <- function(ped, twinRelations = NULL, overrides = NULL) {
  asked <- list()
  list(
    provider = function(ids = NULL) {
      asked <<- c(asked, list(ids))
      kinshipForAnimals(ped, ids, twinRelations = twinRelations,
                        overrides = overrides)
    },
    asked = function() asked
  )
}

## A module's arguments without the ones a run does not pass, so a run given
## only today's matrix passes no kinshipFor at all.
passedArgs <- function(args) args[!vapply(args, is.null, logical(1L))]

## The kinship sources a session-9b run hands a module, as `source` says:
## "matrix" (today's whole matrix, built by `todays()`), "provider", "both" or
## "neither"; a source not handed over is left out.
kinshipArgs <- function(source, todays, provider) {
  passedArgs(list(
    kinshipMatrix = if (source %in% c("matrix", "both")) todays(),
    kinshipFor = if (source %in% c("provider", "both")) provider
  ))
}

## The reactive appServer's shared matrix was before Phase 9b: the whole
## pedigree's kinship with the twins, then the overrides applied
## (R/appServer.R sharedKinshipMatrix). It is built when it is read, so an
## override error is raised there, as it was in the app.
todaysMatrix <- function(ped, twinRelations = NULL, overrides = NULL) {
  shiny::reactive({
    gen <- if ("gen" %in% names(ped)) {
      ped$gen
    } else {
      findGeneration(ped$id, ped$sire, ped$dam)
    }
    kmat <- kinship(ped$id, ped$sire, ped$dam, gen,
                    twinRelations = twinRelations)
    applyKinshipOverridesToMatrix(kmat, overrides)
  })
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

## ---------------------------------------------------------------------------
## Summary Statistics (session 9b)
## ---------------------------------------------------------------------------

## The three downloads that need kinship: the kinship CSV, and the
## relationships and relationship classes built from the same matrix.
kinshipDownloads <- c("downloadKinship", "downloadRelationships",
                      "downloadRelationClasses")

## test_kinship.R's fam1: 8 and 9 declared MZ twins, 10 a child of 8.
fam1Ped <- function() {
  data.frame(
    id   = as.character(1:10),
    sire = c(NA, NA, "1", "1", NA, NA, "3", "6", "6", "8"),
    dam  = c(NA, NA, "2", "2", NA, NA, "5", "4", "4", "7"),
    stringsAsFactors = FALSE
  )
}

## qcPed's first two founders, with an override of their kinship.
qcPedFounderOverride <- function(kinship) {
  ped <- nprcgenekeepr::qcPed
  founders <- ped$id[is.na(ped$sire) & is.na(ped$dam)]
  data.frame(id1 = founders[[1L]], id2 = founders[[2L]], kinship = kinship,
             stringsAsFactors = FALSE)
}

## The pedigrees the downloads are compared on (qcPed has 280 animals).
summaryCases <- function() {
  list(
    plain = list(ped = nprcgenekeepr::qcPed),
    override = list(ped = nprcgenekeepr::qcPed,
                    overrides = qcPedFounderOverride(0.1)),
    mzTwins = list(ped = fam1Ped(),
                   twinRelations = data.frame(id1 = "8", id2 = "9",
                                              code = "MZ twin",
                                              stringsAsFactors = FALSE))
  )
}

## Clicks `downloads` in one Summary Statistics session, in order. Each file
## is the outcome() of reading it (its bytes, or its error, and the warnings
## raised); `asked` is what the provider was asked for. `source` is the
## kinship the module is handed: today's whole matrix, the provider, or both.
## The module gets the case's twins and overrides as appServer gives them.
summaryRun <- function(case, source, downloads = kinshipDownloads) {
  recorder <- recordingProvider(case$ped, case$twinRelations, case$overrides)
  files <- list()
  args <- c(
    list(geneticValues = shiny::reactive(NULL),
         pedigree = shiny::reactive(case$ped)),
    kinshipArgs(source, function() {
      todaysMatrix(case$ped, case$twinRelations, case$overrides)
    }, recorder$provider),
    passedArgs(list(
      kinshipOverrides = if (!is.null(case$overrides)) {
        shiny::reactive(case$overrides)
      },
      twinRelations = if (!is.null(case$twinRelations)) {
        shiny::reactive(case$twinRelations)
      }
    ))
  )
  suppressMessages(shiny::testServer(modSummaryStatsServer, args = args, {
    for (download in downloads) {
      files[[length(files) + 1L]] <<- outcome(function() {
        path <- output[[download]]
        readBin(path, "raw", file.size(path))
      }, list())
    }
  }))
  list(files = files, asked = recorder$asked())
}

test_that(paste("Summary Statistics' three kinship downloads are the same",
                "bytes from kinshipFor as from the whole matrix: plain, with",
                "an override and with an MZ twin pair (design 7.1 item 6)"), {
  cases <- summaryCases()
  for (name in names(cases)) {
    viaMatrix <- summaryRun(cases[[name]], "matrix")
    viaProvider <- summaryRun(cases[[name]], "provider")
    for (file in viaMatrix$files) {
      expect_type(file$value, "raw")
      expect_gt(length(file$value), 0L)
    }
    expect_identical(viaProvider$files, viaMatrix$files, info = name)
  }
})

test_that(paste("each kinship CSV download asks kinshipFor for every animal,",
                "again at a second click: no matrix is kept between clicks"), {
  run <- summaryRun(summaryCases()$plain, "provider",
                    downloads = c("downloadKinship", "downloadKinship"))
  expect_type(run$files[[1L]]$value, "raw")
  expect_identical(run$files[[2L]], run$files[[1L]])
  expect_identical(run$asked, list(NULL, NULL))
})

test_that(paste("the relationship downloads ask kinshipFor for every animal",
                "once: the relationship table they share stays kept",
                "(BACKLOG.md 'Summary Statistics keeps the whole relationship",
                "table', left as it is)"), {
  run <- summaryRun(summaryCases()$plain, "provider",
                    downloads = c("downloadRelationships",
                                  "downloadRelationClasses",
                                  "downloadRelationships"))
  expect_type(run$files[[1L]]$value, "raw")
  expect_identical(run$asked, list(NULL))
})

test_that("Summary Statistics uses a handed-in kinshipMatrix before kinshipFor", {
  case <- summaryCases()$override
  both <- summaryRun(case, "both")
  expect_length(both$asked, 0L)
  expect_identical(both$files, summaryRun(case, "matrix")$files)
})

test_that(paste("an override above its pair's ceiling gives each kinship",
                "download today's error and warnings"), {
  ## One download a session: every click recomputes now, so a second click
  ## repeats the warning that today's kept matrix raised only once.
  case <- list(ped = nprcgenekeepr::qcPed,
               overrides = qcPedFounderOverride(0.9))
  for (download in kinshipDownloads) {
    viaMatrix <- summaryRun(case, "matrix", downloads = download)
    viaProvider <- summaryRun(case, "provider", downloads = download)
    expect_match(viaMatrix$files[[1L]]$error, "above the maximum",
                 fixed = TRUE, info = download)
    expect_identical(viaProvider$files, viaMatrix$files, info = download)
  }
})

## ---------------------------------------------------------------------------
## Marker Genetics (session 9b)
## ---------------------------------------------------------------------------

markerPed <- function() nprcgenekeepr::qcPed

## A genotype file of three living qcPed animals and one id the pedigree does
## not hold (its pedigree mean kinship is NA): 12 biallelic loci drawn from a
## fixed seed with the RNG kinds pinned. Written once, on first use.
markerGenotypeFile <- local({
  path <- NULL
  function() {
    if (is.null(path)) {
      ped <- markerPed()
      ids <- c(ped$id[is.na(ped$exit)][1:3], "NOT_AN_ID")
      genotypes <- withr::with_seed(3L, {
        do.call(rbind, lapply(ids, function(id) {
          data.frame(id = id, locus = paste0("L", 1:12),
                     allele1 = sample(c("A", "B"), 12L, replace = TRUE),
                     allele2 = sample(c("A", "B"), 12L, replace = TRUE),
                     stringsAsFactors = FALSE)
        }))
      }, .rng_kind = "Mersenne-Twister", .rng_normal_kind = "Inversion",
      .rng_sample_kind = "Rejection")
      path <<- tempfile(fileext = ".csv")
      utils::write.csv(genotypes, path, row.names = FALSE)
    }
    path
  }
})

## One Marker Genetics session: `inputs` set first, the genotype file
## uploaded when `upload`, then each of `tables` read in order (each the
## outcome() of reading it). `asked` is what the provider was asked for, and
## `source` is the kinship the module is handed, as in summaryRun().
markerRun <- function(source, ped = markerPed(), inputs = list(),
                      upload = TRUE, tables = c("comparison", "realized")) {
  recorder <- recordingProvider(markerPed())
  read <- list(comparison = function(result) result$comparisonTable(),
               realized = function(result) result$realizedRelatednessTable())
  out <- list()
  args <- c(
    kinshipArgs(source, function() todaysMatrix(markerPed()),
                recorder$provider),
    list(pedigree = shiny::reactive(ped))
  )
  shiny::testServer(modMarkerGeneticsServer, args = args, {
    result <- session$getReturned()
    if (length(inputs) > 0L) {
      do.call(session$setInputs, inputs)
    }
    if (upload) {
      session$setInputs(genotypeFile = list(name = "markers.csv",
                                            datapath = markerGenotypeFile()))
    }
    for (table in tables) {
      out[[length(out) + 1L]] <<- outcome(read[[table]], list(result))
    }
  })
  list(tables = stats::setNames(out, tables), asked = recorder$asked())
}

test_that(paste("Marker Genetics' comparison and Realized Relatedness tables",
                "are the same from kinshipFor as from the whole matrix",
                "(design 7.1 item 6)"), {
  viaMatrix <- markerRun("matrix")
  viaProvider <- markerRun("provider")
  comparison <- viaMatrix$tables$comparison$value
  expect_s3_class(comparison, "data.frame")
  expect_identical(is.na(comparison$indivMeanKin), c(FALSE, FALSE, FALSE, TRUE))
  expect_s3_class(viaMatrix$tables$realized$value, "data.frame")
  expect_identical(viaProvider$tables, viaMatrix$tables)
})

test_that(paste("the Kinship Comparison asks kinshipFor for every animal once",
                "a genotype file is uploaded, and nothing before"), {
  before <- markerRun("provider", upload = FALSE, tables = "comparison")
  expect_null(before$tables$comparison$value)
  expect_length(before$asked, 0L)

  ## No pedigree, so only the comparison can ask: testServer() draws every
  ## output after the upload, the Realized Relatedness table included, which
  ## the app draws only while its tab is open.
  after <- markerRun("provider", ped = NULL,
                     tables = c("comparison", "comparison"))
  expect_s3_class(after$tables$comparison$value, "data.frame")
  expect_identical(after$asked, list(NULL))
})

test_that(paste("Realized Relatedness asks kinshipFor for every animal once,",
                "and nothing while the pedigree or its two inputs are not",
                "usable"), {
  ready <- markerRun("provider", upload = FALSE, tables = "realized")
  expect_s3_class(ready$tables$realized$value, "data.frame")
  expect_identical(ready$asked, list(NULL))

  notReady <- list(
    noPedigree = list(ped = NULL),
    zeroChromosomes = list(inputs = list(nChr = 0L, mapLength = 28)),
    noChromosomeCount = list(inputs = list(nChr = NA, mapLength = 28)),
    negativeMapLength = list(inputs = list(nChr = 20L, mapLength = -1))
  )
  for (name in names(notReady)) {
    run <- do.call(markerRun, c(list(source = "provider", upload = FALSE,
                                     tables = "realized"), notReady[[name]]))
    expect_null(run$tables$realized$value, info = name)
    expect_null(run$tables$realized$error, info = name)
    expect_length(run$asked, 0L)
  }
})

test_that("Marker Genetics uses a handed-in kinshipMatrix before kinshipFor", {
  both <- markerRun("both")
  expect_length(both$asked, 0L)
  expect_identical(both$tables, markerRun("matrix")$tables)
})

test_that(paste("Marker Genetics given neither kinship source shows no",
                "pedigree mean kinship and no Realized Relatedness table"), {
  run <- markerRun("neither")
  expect_s3_class(run$tables$comparison$value, "data.frame")
  expect_true(all(is.na(run$tables$comparison$value$indivMeanKin)))
  expect_null(run$tables$realized$value)
})
