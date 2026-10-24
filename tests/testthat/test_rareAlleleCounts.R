## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 1, genome uniqueness"
## (owner pick S1053; plan docs/planning/performance-memory-campaign-plan.md,
## Phase 1 and section 5.1). calcGU() and calcGUSE() each counted every
## animal's rare alleles with table() and tapply() once per gene-drop
## iteration, and reportGV() built that count twice: 2.94 of the 3.28 seconds
## of the Genetic Value analysis on the example (docs/audits/
## PERF_BASELINE_2026-10-24.md). rareAlleleCounts() counts them once, fast, and
## guFromRare() and guSEFromRare() build the two tables from that one count.
##
## The owner's rulings: every result stays exactly today's for the same inputs
## and seed (D1), and the exported functions keep their arguments and results
## (D3). So each block compares the new code with frozen copies of today's
## functions (helper-perfReference.R) using identical(). The fast count is for
## tables shaped like geneDrop()'s; any other table goes through today's count
## unchanged (owner ruling S1053), so it gives today's result, or today's
## error, by construction.

## The example studbook as the app trims it for the Genetic Value analysis
## (R/modPedigree.R, then R/modGeneticValue.R; tools/perf/harness.R
## appAnalysisPed() does the same, but tools/ is not in a built package, and
## these tests must run on every CI platform). Built once per file run.
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

integerCodes <- function(genotype) {
  genotype$first <- as.integer(genotype$first)
  genotype$second <- as.integer(genotype$second)
  genotype
}

## The plan's grid: four shipped pedigrees (the genotyped one with its double
## codes as shipped and with integer copies) and the example's analysis set,
## cut to the probands as reportGV() cuts it.
gridInputs <- function() {
  ex <- exampleAnalysisPed()
  genotype <- getGVGenotype(nprcgenekeepr::pedWithGenotype)
  list(
    list(name = "lacy1989Ped", ped = nprcgenekeepr::lacy1989Ped,
         genotype = NULL, n = 50L, pop = NULL),
    list(name = "qcPed", ped = nprcgenekeepr::qcPed,
         genotype = NULL, n = 50L, pop = NULL),
    list(name = "pedWithGenotype (double codes)",
         ped = nprcgenekeepr::pedWithGenotype,
         genotype = genotype, n = 50L, pop = NULL),
    list(name = "pedWithGenotype (integer codes)",
         ped = nprcgenekeepr::pedWithGenotype,
         genotype = integerCodes(genotype), n = 50L, pop = NULL),
    list(name = "example (app trim)", ped = ex, genotype = NULL, n = 20L,
         pop = as.character(ex$id[ex$population]))
  )
}

gridSeeds <- c(1L, 7L, 2026L)

dropTable <- function(input, seed) {
  ped <- input$ped
  alleles <- withr::with_seed(seed, geneDrop(
    ped$id, ped$sire, ped$dam, ped$gen, genotype = input$genotype,
    n = input$n
  ))
  if (!is.null(input$pop)) {
    alleles <- alleles[alleles$id %in% input$pop, ]
  }
  alleles
}

## The 15 gene-drop tables of the grid (5 inputs, 3 seeds), built once.
gridTables <- local({
  tables <- NULL
  function() {
    if (is.null(tables)) {
      inputs <- gridInputs()
      tables <<- unlist(lapply(inputs, function(input) {
        lapply(gridSeeds, function(seed) {
          list(label = sprintf("%s, seed %d", input$name, seed),
               alleles = dropTable(input, seed))
        })
      }), recursive = FALSE)
    }
    tables
  }
})

## A call's value, or its error message, with any warnings it gave.
outcome <- function(expr) {
  warnings <- character(0L)
  value <- withCallingHandlers(
    tryCatch(expr, error = function(e) list(error = conditionMessage(e))),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  list(value = value, warnings = warnings)
}

iterationsOf <- function(alleles) {
  sum(!(colnames(alleles) %in% c("id", "parent")))
}

test_that("rareAlleleCounts() and calcA() give today's count on the grid", {
  for (tab in gridTables()) {
    for (threshold in c(1L, 4L)) {
      for (byID in c(TRUE, FALSE)) {
        info <- sprintf("%s, threshold %d, byID %s", tab$label, threshold,
                        byID)
        expected <- calcAReference(tab$alleles, threshold, byID)
        expect_identical(rareAlleleCounts(tab$alleles, threshold, byID),
                         expected, info = info)
        expect_identical(calcA(tab$alleles, threshold, byID), expected,
                         info = info)
      }
    }
  }
})

test_that("animals carrying two copies of one allele give today's count", {
  ## Few animals in the grid's pedigrees carry two copies of one founder
  ## allele, so dropping the byID correction for them failed only 2 of the
  ## grid's 120 checks (S1053's mutation check). Here every animal, then every
  ## other animal, carries two copies of one allele in every iteration.
  gd <- withr::with_seed(1L, geneDrop(
    qcPed$id, qcPed$sire, qcPed$dam, qcPed$gen, n = 20L
  ))
  iterations <- setdiff(names(gd), c("id", "parent"))
  second <- which(duplicated(gd$id))
  everyAnimal <- gd
  everyAnimal[second, iterations] <- gd[match(gd$id[second], gd$id),
                                        iterations]
  half <- second[gd$id[second] %in% unique(gd$id)[c(TRUE, FALSE)]]
  everyOther <- gd
  everyOther[half, iterations] <- gd[match(gd$id[half], gd$id), iterations]
  tables <- list(`every animal` = everyAnimal,
                 `every other animal` = everyOther)
  for (name in names(tables)) {
    for (threshold in c(1L, 2L, 4L)) {
      for (byID in c(TRUE, FALSE)) {
        info <- sprintf("two copies in %s, threshold %d, byID %s", name,
                        threshold, byID)
        expected <- calcAReference(tables[[name]], threshold, byID)
        expect_identical(rareAlleleCounts(tables[[name]], threshold, byID),
                         expected, info = info)
        expect_identical(calcA(tables[[name]], threshold, byID), expected,
                         info = info)
      }
    }
  }
})

test_that("calcGU(), calcGUSE() and the tables built from one count are today's", {
  ## One seed per input shape: the shipped pedigree, the genotyped one with
  ## double codes, and the example's analysis set.
  tabs <- gridTables()[c(4L, 8L, 15L)]
  for (tab in tabs) {
    alleles <- tab$alleles
    ids <- unique(alleles$id)
    pops <- list(none = NULL, some = ids[c(TRUE, FALSE)], one = ids[1L],
                 nobody = "nobody")
    for (popName in names(pops)) {
      pop <- pops[[popName]]
      sub <- if (is.null(pop)) alleles else alleles[alleles$id %in% pop, ]
      for (threshold in c(1L, 4L)) {
        for (byID in c(TRUE, FALSE)) {
          info <- sprintf("%s, pop %s, threshold %d, byID %s", tab$label,
                          popName, threshold, byID)
          gu <- calcGUReference(alleles, threshold, byID, pop)
          guSE <- calcGUSEReference(alleles, threshold, byID, pop)
          expect_identical(calcGU(alleles, threshold, byID, pop), gu,
                           info = info)
          expect_identical(calcGUSE(alleles, threshold, byID, pop), guSE,
                           info = info)
          rare <- rareAlleleCounts(sub, threshold, byID)
          expect_identical(guFromRare(rare, iterationsOf(alleles)), gu,
                           info = info)
          expect_identical(guSEFromRare(rare, iterationsOf(alleles)), guSE,
                           info = info)
        }
      }
    }
  }
})

test_that("tables not shaped like geneDrop()'s give today's count or error", {
  gd <- withr::with_seed(1L, geneDrop(
    lacy1989Ped$id, lacy1989Ped$sire, lacy1989Ped$dam, lacy1989Ped$gen,
    n = 5L
  ))
  iterations <- setdiff(names(gd), c("id", "parent"))
  missingAlleles <- gd
  missingAlleles$V2[c(1L, 4L)] <- NA
  missingIds <- gd
  missingIds$id[c(1L, 2L)] <- NA
  unusedLevel <- gd
  unusedLevel$id <- factor(unusedLevel$id,
                           levels = c(unique(unusedLevel$id), "ZZZ"))
  fractional <- gd
  fractional[iterations] <- lapply(fractional[iterations], `+`, 0.5)
  ## Above 1e15 a double's 15-digit text form, which today's table() count
  ## matches alleles by, no longer tells neighboring values apart.
  huge <- gd
  huge[iterations] <- lapply(huge[iterations], `+`, 1e15)
  shapes <- list(
    list(name = "zero animals", alleles = gd[0L, ], threshold = 1L),
    list(name = "one iteration", alleles = gd[, c("V1", "id", "parent")],
         threshold = 1L),
    list(name = "an unused factor level", alleles = unusedLevel,
         threshold = 1L),
    list(name = "threshold NA", alleles = gd, threshold = NA),
    list(name = "missing alleles, threshold 1", alleles = missingAlleles,
         threshold = 1L),
    list(name = "missing alleles, threshold 2", alleles = missingAlleles,
         threshold = 2L),
    list(name = "missing alleles, threshold 4", alleles = missingAlleles,
         threshold = 4L),
    list(name = "missing ids", alleles = missingIds, threshold = 1L),
    list(name = "an animal on one row", alleles = gd[-1L, ], threshold = 1L),
    list(name = "fractional alleles", alleles = fractional, threshold = 1L),
    list(name = "doubles of 1e15 or more", alleles = huge, threshold = 4L),
    list(name = "a matrix, not a data frame", alleles = as.matrix(gd),
         threshold = 1L),
    list(name = "a two-number threshold", alleles = gd,
         threshold = c(1L, 4L)),
    list(name = "a text threshold", alleles = gd, threshold = "4")
  )
  for (shape in shapes) {
    for (byID in c(TRUE, FALSE)) {
      info <- sprintf("%s, byID %s", shape$name, byID)
      expected <- outcome(calcAReference(shape$alleles, shape$threshold,
                                         byID))
      expect_identical(
        outcome(rareAlleleCounts(shape$alleles, shape$threshold, byID)),
        expected, info = info
      )
      expect_identical(
        outcome(calcA(shape$alleles, shape$threshold, byID)),
        expected, info = info
      )
    }
  }
})

test_that("geneDrop()'s tables take the fast count, never today's slow one", {
  tabs <- gridTables()[c(1L, 4L, 7L, 10L, 13L)]
  expected <- lapply(tabs, function(tab) {
    list(byID = calcAReference(tab$alleles, 4L, TRUE),
         all = calcAReference(tab$alleles, 4L, FALSE))
  })
  local_mocked_bindings(rareAlleleCountsGeneral = function(...) {
    stop("today's slow count ran on a table shaped like geneDrop()'s")
  })
  for (i in seq_along(tabs)) {
    alleles <- tabs[[i]]$alleles
    expect_identical(rareAlleleCounts(alleles, 4L, TRUE), expected[[i]]$byID,
                     info = tabs[[i]]$label)
    expect_identical(rareAlleleCounts(alleles, 4L, FALSE), expected[[i]]$all,
                     info = tabs[[i]]$label)
  }
})

## Counts the calls to rareAlleleCounts() made while the caller's test runs.
countRareBuilds <- function(envir = parent.frame()) {
  rec <- new.env()
  rec$calls <- 0L
  real <- rareAlleleCounts
  local_mocked_bindings(
    rareAlleleCounts = function(...) {
      rec$calls <- rec$calls + 1L
      real(...)
    },
    .env = envir
  )
  rec
}

test_that("reportGV() gives today's report and builds the count once", {
  ex <- exampleAnalysisPed()
  cases <- list(
    list(name = "qcPed", ped = nprcgenekeepr::qcPed, threshold = 1L,
         byID = TRUE, seed = 1L),
    list(name = "qcPed", ped = nprcgenekeepr::qcPed, threshold = 4L,
         byID = FALSE, seed = 7L),
    list(name = "pedWithGenotype", ped = nprcgenekeepr::pedWithGenotype,
         threshold = 4L, byID = TRUE, seed = 2026L),
    list(name = "pedWithGenotype", ped = nprcgenekeepr::pedWithGenotype,
         threshold = 1L, byID = FALSE, seed = 1L),
    list(name = "example (app trim)", ped = ex, threshold = 4L, byID = TRUE,
         seed = 1L)
  )
  rec <- countRareBuilds()
  for (case in cases) {
    info <- sprintf("%s, threshold %d, byID %s, seed %d", case$name,
                    case$threshold, case$byID, case$seed)
    expected <- withr::with_seed(case$seed, reportGVReference(
      case$ped, guIter = 20L, guThresh = case$threshold, byID = case$byID
    ))
    rec$calls <- 0L
    report <- withr::with_seed(case$seed, reportGV(
      case$ped, guIter = 20L, guThresh = case$threshold, byID = case$byID
    ))
    expect_identical(rec$calls, 1L, info = info)
    expect_identical(report, expected, info = info)
  }
})

test_that("calcGU(), calcGUSE() and gvaConvergence() build the count once", {
  alleles <- gridTables()[[4L]]$alleles
  rec <- countRareBuilds()
  calcGU(alleles, threshold = 4L, byID = TRUE)
  expect_identical(rec$calls, 1L)
  rec$calls <- 0L
  calcGUSE(alleles, threshold = 4L, byID = TRUE)
  expect_identical(rec$calls, 1L)
  rec$calls <- 0L
  gvaConvergence(nprcgenekeepr::qcPed, nMax = 200L, seed = 1L)
  expect_identical(rec$calls, 1L)
})
