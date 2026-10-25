## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 5, founder statistics"
## (owner pick S1058; plan docs/planning/performance-memory-campaign-plan.md,
## Phase 5 and section 5.1). calcFounderContributions() filled each
## descendant's row of founder contributions by name, three name lookups an
## animal, and calcRetention() and calcFGSE() each scanned every gene-drop
## iteration with apply() and %in%; reportGV() did both twice, once for
## calcFEFG() and once for calcFGSE(). On the synthetic 10,000-animal colony
## (6,090 rows after the app's trim) calcFEFG() and calcFGSE() took 1.19 and
## 1.18 s (S1058). founderContributionMatrix() fills the rows a generation at
## a time by position, retainedFounderAlleles() scans the iterations with
## match(), and reportGV() builds both once for its two numbers.
##
## The owner's rulings: every result stays exactly today's for the same inputs
## and seed (D1), the exported functions keep their arguments and results
## (D3), and an input the fast code was not built for runs today's code
## unchanged (owner ruling S1058, as in Phases 1-4), so it gives today's
## result, or today's error, by construction. So each block compares the new
## code with frozen copies of today's functions (helper-perfReference.R) using
## identical().

## The plan's grid: three shipped pedigrees (the genotyped one with its double
## codes as shipped and with integer copies) and the example's analysis set.
## qcPed and pedWithGenotype have no population column, so every animal is in
## the population, as getGVPopulation() makes it.
founderGridInputs <- function() {
  withPopulation <- function(ped) {
    ped$population <- getGVPopulation(ped, NULL)
    ped
  }
  genotype <- getGVGenotype(nprcgenekeepr::pedWithGenotype)
  genotyped <- withPopulation(nprcgenekeepr::pedWithGenotype)
  list(
    list(name = "lacy1989Ped", ped = nprcgenekeepr::lacy1989Ped,
         genotype = NULL, n = 50L),
    list(name = "qcPed", ped = withPopulation(nprcgenekeepr::qcPed),
         genotype = NULL, n = 50L),
    list(name = "pedWithGenotype (double codes)", ped = genotyped,
         genotype = genotype, n = 50L),
    list(name = "pedWithGenotype (integer codes)", ped = genotyped,
         genotype = integerCodes(genotype), n = 50L),
    list(name = "example (app trim)", ped = exampleAnalysisPed(),
         genotype = NULL, n = 20L)
  )
}

founderSeeds <- c(1L, 7L, 2026L)

## The 15 cases of the grid (5 inputs, 3 seeds): a pedigree and its gene-drop
## table. Built once.
founderGrid <- local({
  cases <- NULL
  function() {
    if (is.null(cases)) {
      cases <<- unlist(lapply(founderGridInputs(), function(input) {
        lapply(founderSeeds, function(seed) {
          ped <- input$ped
          list(
            label = sprintf("%s, seed %d", input$name, seed), ped = ped,
            alleles = withr::with_seed(seed, geneDrop(
              ped$id, ped$sire, ped$dam, ped$gen, genotype = input$genotype,
              n = input$n
            ))
          )
        })
      }), recursive = FALSE)
    }
    cases
  }
})

## Each founder function and its frozen copy, called with (ped, alleles).
founderFunctions <- function() {
  list(
    calcFounderContributions = list(
      new = function(ped, alleles) calcFounderContributions(ped, "calcFEFG"),
      today = function(ped, alleles) {
        calcFounderContributionsReference(ped, "calcFEFG")
      }
    ),
    calcRetention = list(new = calcRetention, today = calcRetentionReference),
    calcFE = list(new = function(ped, alleles) calcFE(ped),
                  today = function(ped, alleles) calcFEReference(ped)),
    calcFG = list(new = calcFG, today = calcFGReference),
    calcFEFG = list(new = calcFEFG, today = calcFEFGReference),
    calcFGSE = list(new = calcFGSE, today = calcFGSEReference),
    founderStatistics = list(new = founderStatistics,
                             today = todaysFounderStatistics)
  )
}

## What reportGV() got from today's two calls in a row: calcFEFG()'s list and
## calcFGSE()'s number, with outcome() collecting both calls' warnings in
## order, or the first error either gives. founderStatistics() builds both from
## one contribution build and one scan.
todaysFounderStatistics <- function(ped, alleles) {
  list(feFg = calcFEFGReference(ped, alleles),
       fgSE = calcFGSEReference(ped, alleles))
}

## outcome() under a time limit, so a broken fast path that loops fails the
## comparison instead of hanging the test.
boundedOutcome <- function(f, args) {
  setTimeLimit(elapsed = 30, transient = TRUE)
  on.exit(setTimeLimit(elapsed = Inf), add = TRUE)
  outcome(f, args)
}

expectFounderOutcomes <- function(cases, functions = founderFunctions()) {
  for (case in cases) {
    for (fn in names(functions)) {
      args <- list(case$ped, case$alleles)
      expect_identical(
        boundedOutcome(functions[[fn]]$new, args),
        boundedOutcome(functions[[fn]]$today, args),
        info = sprintf("%s, %s", fn, case$label)
      )
    }
  }
}

test_that("the founder functions give today's results on the grid", {
  expectFounderOutcomes(founderGrid())
})

test_that("on the grid the founder functions never run today's slow code", {
  local_mocked_bindings(
    founderContributionMatrixGeneral = function(...) {
      stop("today's contribution fill ran on an ordinary pedigree")
    },
    retainedFounderAllelesGeneral = function(...) {
      stop("today's retention scan ran on a gene-drop table")
    }
  )
  expectFounderOutcomes(founderGrid())
})

test_that("all 3,694 example animals give today's founder numbers", {
  ped <- exampleLivingPed()
  ped$population <- TRUE
  alleles <- withr::with_seed(1L, geneDrop(
    ped$id, ped$sire, ped$dam, ped$gen, n = 100L
  ))
  case <- list(label = "example, all 3,694 animals, seed 1", ped = ped,
               alleles = alleles)
  local_mocked_bindings(
    founderContributionMatrixGeneral = function(...) {
      stop("today's contribution fill ran on an ordinary pedigree")
    },
    retainedFounderAllelesGeneral = function(...) {
      stop("today's retention scan ran on a gene-drop table")
    }
  )
  expectFounderOutcomes(list(case), founderFunctions()[
    c("calcFounderContributions", "calcFEFG", "calcFGSE")
  ])
})

## ---- Unusual inputs ---------------------------------------------------------

## The pedigree cases, each a change to lacy1989Ped, and the code each is
## expected to run in the contribution fill: "today's" (the unchanged copy),
## "new", or "none" when the call stops before the fill.
oddPedCases <- function() {
  base <- nprcgenekeepr::lacy1989Ped
  changed <- function(column, rows, value) {
    base[[column]][rows] <- value
    base
  }
  factors <- base
  factors$id <- factor(factors$id)
  factors$sire <- factor(factors$sire)
  factors$dam <- factor(factors$dam)
  list(
    plain = list(ped = base, path = "new"),
    `factor ids` = list(ped = factors, path = "new"),
    `gen as double` = list(
      ped = changed("gen", seq_len(7L), as.double(base$gen)), path = "new"
    ),
    `gen all 0` = list(ped = changed("gen", seq_len(7L), 0L), path = "new"),
    `no population column` = list(
      ped = base[, setdiff(names(base), "population")], path = "new"
    ),
    `population all FALSE` = list(
      ped = changed("population", seq_len(7L), FALSE), path = "new"
    ),
    `population as 0 and 1` = list(
      ped = changed("population", seq_len(7L), as.integer(base$population)),
      path = "new"
    ),
    `population NA` = list(ped = changed("population", 6L, NA), path = "new"),
    `one animal` = list(ped = base[1L, ], path = "new"),
    `gen NA` = list(ped = changed("gen", 3L, NA), path = "today's"),
    `gen as text` = list(
      ped = changed("gen", seq_len(7L), as.character(base$gen)),
      path = "today's"
    ),
    `gen as a factor` = list(
      ped = changed("gen", seq_len(7L), factor(base$gen)), path = "today's"
    ),
    `gen 1.5` = list(ped = changed("gen", 6L, 1.5), path = "today's"),
    `parent in the child's generation` = list(
      ped = changed("gen", c(6L, 7L), 1L), path = "today's"
    ),
    `parent in a later generation` = list(ped = changed("gen", 4L, 3L),
                                          path = "today's"),
    `own sire` = list(ped = changed("sire", 6L, "F"), path = "today's"),
    `sire not in the pedigree` = list(ped = changed("sire", 6L, "Z"),
                                      path = "today's"),
    `no-parent animal at generation 1` = list(ped = changed("gen", 5L, 1L),
                                              path = "today's"),
    `duplicated id` = list(ped = rbind(base, base[6L, ]), path = "today's"),
    `empty id` = list(ped = changed("id", 7L, ""), path = "today's"),
    `missing id` = list(ped = changed("id", 7L, NA), path = "today's"),
    `zero rows` = list(ped = base[0L, ], path = "today's"),
    `a list` = list(ped = as.list(base), path = "today's"),
    `NULL` = list(ped = NULL, path = "today's"),
    `partial parentage` = list(ped = changed("dam", 6L, NA), path = "none"),
    `a matrix` = list(ped = as.matrix(base), path = "none")
  )
}

## The gene-drop table cases, each a change to a drop on lacy1989Ped, and the
## code each is expected to run in the retention scan.
oddAlleleCases <- function() {
  ped <- nprcgenekeepr::lacy1989Ped
  al <- withr::with_seed(1L, geneDrop(ped$id, ped$sire, ped$dam, ped$gen,
                                      n = 20L))
  iter <- grep("^V", names(al))
  eachIteration <- function(f) {
    a <- al
    for (j in iter) {
      a[[j]] <- f(a[[j]])
    }
    a
  }
  negativeZero <- al
  negativeZero$V2 <- as.double(negativeZero$V2)
  negativeZero$V2[negativeZero$V2 == 1] <- -0
  negativeZero$V2[1L] <- 0
  naFounder <- al
  naFounder$V1[1L] <- NA
  naDescendant <- al
  naDescendant$V3[nrow(al)] <- NA
  factorIds <- al
  factorIds$id <- factor(factorIds$id)
  founders <- c("A", "B", "E")
  ## every descendant carries founder A's first allele in every iteration, so
  ## B and E contribute but are retained in none: FG and its SE are NA, each
  ## with a warning
  lost <- al
  lost[!(lost$id %in% founders), iter] <- 1L
  ## V1 stays numbers and one other iteration column does not
  oneColumn <- function(f) {
    a <- al
    a$V2 <- f(a$V2)
    a
  }
  list(
    plain = list(alleles = al, path = "new"),
    `double values` = list(alleles = eachIteration(as.double), path = "new"),
    `an extra numeric column` = list(alleles = cbind(al, sex = 1L),
                                     path = "new"),
    `no descendant rows` = list(alleles = al[al$id %in% founders, ],
                                path = "new"),
    `factor ids` = list(alleles = factorIds, path = "new"),
    `rows shuffled` = list(
      alleles = al[withr::with_seed(2L, sample(nrow(al))), ], path = "new"
    ),
    `-0 and 0` = list(alleles = negativeZero, path = "new"),
    `values above 2e9` = list(
      alleles = eachIteration(function(v) v + 2e9), path = "new"
    ),
    `one iteration` = list(alleles = al[, c("V1", "id", "parent")],
                           path = "today's"),
    `no founder rows` = list(alleles = al[!(al$id %in% founders), ],
                             path = "today's"),
    `one founder row` = list(alleles = al[-(2:6), ], path = "today's"),
    `text values` = list(alleles = eachIteration(as.character),
                         path = "today's"),
    `factor values` = list(alleles = eachIteration(factor), path = "today's"),
    `logical values` = list(alleles = eachIteration(function(v) v > 3L),
                            path = "today's"),
    `Date values` = list(alleles = eachIteration(as.Date), path = "today's"),
    `a missing founder allele` = list(alleles = naFounder, path = "today's"),
    `a missing descendant allele` = list(alleles = naDescendant,
                                         path = "today's"),
    `no iterations` = list(alleles = al[, c("id", "parent")], path = "none"),
    `no V1 column` = list(
      alleles = stats::setNames(al, sub("^V", "X", names(al))), path = "none"
    ),
    `NULL` = list(alleles = NULL, path = "none"),
    `a list` = list(alleles = as.list(al), path = "none"),
    `a matrix` = list(alleles = as.matrix(al), path = "none"),
    `contributing founders lost` = list(alleles = lost, path = "new"),
    `one text column` = list(alleles = oneColumn(as.character),
                             path = "today's"),
    `one factor column` = list(alleles = oneColumn(factor), path = "today's"),
    `one logical column` = list(alleles = oneColumn(function(v) v > 3L),
                                path = "today's"),
    `one Date column` = list(alleles = oneColumn(as.Date), path = "today's")
  )
}

test_that("unusual pedigrees give today's value, error and warnings", {
  ped <- nprcgenekeepr::lacy1989Ped
  alleles <- withr::with_seed(1L, geneDrop(ped$id, ped$sire, ped$dam, ped$gen,
                                           n = 20L))
  cases <- lapply(names(oddPedCases()), function(name) {
    list(label = name, ped = oddPedCases()[[name]]$ped, alleles = alleles)
  })
  expectFounderOutcomes(cases)
})

test_that("unusual gene-drop tables give today's value, error and warnings", {
  ped <- nprcgenekeepr::lacy1989Ped
  cases <- lapply(names(oddAlleleCases()), function(name) {
    list(label = name, ped = ped, alleles = oddAlleleCases()[[name]]$alleles)
  })
  expectFounderOutcomes(cases, founderFunctions()[
    c("calcRetention", "calcFG", "calcFEFG", "calcFGSE", "founderStatistics")
  ])
})

## Which of today's two unchanged copies a call reached, if either: each is
## mocked to note it and stop, so the call ends there. Bounded, and quiet: a
## warning both codes give is not this block's business.
pathTaken <- function(f, args) {
  setTimeLimit(elapsed = 30, transient = TRUE)
  on.exit(setTimeLimit(elapsed = Inf), add = TRUE)
  reached <- character()
  local_mocked_bindings(
    founderContributionMatrixGeneral = function(...) {
      reached <<- c(reached, "contributions")
      stop("today's code")
    },
    retainedFounderAllelesGeneral = function(...) {
      reached <<- c(reached, "retention")
      stop("today's code")
    }
  )
  ran <- suppressWarnings(try(do.call(f, args), silent = TRUE))
  list(reached = reached, stopped = inherits(ran, "try-error"))
}

test_that("ordinary pedigrees run the new fill and the unusual ones today's", {
  ped <- nprcgenekeepr::lacy1989Ped
  alleles <- withr::with_seed(1L, geneDrop(ped$id, ped$sire, ped$dam, ped$gen,
                                           n = 20L))
  for (name in names(oddPedCases())) {
    case <- oddPedCases()[[name]]
    taken <- pathTaken(function(p) calcFounderContributions(p, "calcFEFG"),
                       list(case$ped))
    expect_identical(
      "contributions" %in% taken$reached, identical(case$path, "today's"),
      info = name
    )
    if (identical(case$path, "none")) {
      expect_true(taken$stopped, info = name)
    }
  }
  ## and the scan of an ordinary table, after an ordinary fill, is the new one
  expect_identical(pathTaken(calcFEFG, list(ped, alleles))$reached,
                   character())
})

test_that("ordinary tables run the new scan and the unusual ones today's", {
  ped <- nprcgenekeepr::lacy1989Ped
  for (name in names(oddAlleleCases())) {
    case <- oddAlleleCases()[[name]]
    for (fn in c("calcRetention", "calcFGSE")) {
      taken <- pathTaken(get(fn), list(ped, case$alleles))
      expect_identical(
        taken$reached,
        if (identical(case$path, "today's")) "retention" else character(),
        info = sprintf("%s, %s", fn, name)
      )
      if (identical(case$path, "none")) {
        expect_true(taken$stopped, info = sprintf("%s, %s", fn, name))
      }
    }
  }
})

## ---- reportGV() -------------------------------------------------------------

## Counts the founder-contribution builds and the retention scans made while
## the caller's test runs.
countFounderBuilds <- function(envir = parent.frame()) {
  rec <- new.env()
  rec$contributions <- 0L
  rec$scans <- 0L
  realContributions <- calcFounderContributions
  realScan <- retainedFounderAlleles
  local_mocked_bindings(
    calcFounderContributions = function(...) {
      rec$contributions <- rec$contributions + 1L
      realContributions(...)
    },
    retainedFounderAlleles = function(...) {
      rec$scans <- rec$scans + 1L
      realScan(...)
    },
    .env = envir
  )
  rec
}

test_that("reportGV() gives today's report and builds the founder parts once", {
  cases <- list(
    list(name = "qcPed", ped = nprcgenekeepr::qcPed, seed = 7L),
    ## a genotyped pedigree: its founder numbers come from a second drop
    list(name = "pedWithGenotype", ped = nprcgenekeepr::pedWithGenotype,
         seed = 2026L),
    list(name = "example (app trim)", ped = exampleAnalysisPed(), seed = 1L)
  )
  rec <- countFounderBuilds()
  for (case in cases) {
    info <- sprintf("%s, seed %d", case$name, case$seed)
    expected <- withr::with_seed(case$seed, reportGVReference(
      case$ped, guIter = 20L, guThresh = 4L, byID = TRUE
    ))
    rec$contributions <- 0L
    rec$scans <- 0L
    report <- withr::with_seed(case$seed, reportGV(
      case$ped, guIter = 20L, guThresh = 4L, byID = TRUE
    ))
    expect_identical(rec$contributions, 1L, info = info)
    expect_identical(rec$scans, 1L, info = info)
    expect_identical(report, expected, info = info)
  }
})

test_that("reportGV() on few iterations gives today's result and warnings", {
  ## Few iterations leave a contributing founder retained in none of them, so
  ## FG is NA with a warning from each of the two founder numbers; one
  ## iteration is an error today.
  ped <- nprcgenekeepr::lacy1989Ped
  ped$sex <- rep(c("M", "F"), length.out = nrow(ped))
  for (iterations in c(1L, 2L, 5L)) {
    for (seed in c(1L, 7L)) {
      args <- list(ped, guIter = iterations, guThresh = 1L, byID = TRUE)
      expect_identical(
        outcome(reportGV, args, seed),
        outcome(reportGVReference, args, seed),
        info = sprintf("%d iteration(s), seed %d", iterations, seed)
      )
    }
  }
})
