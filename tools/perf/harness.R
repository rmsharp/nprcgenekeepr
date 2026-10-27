## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## The measuring harness of the performance and memory campaign
## (docs/planning/performance-memory-campaign-plan.md, Phase 0 and Appendix A).
## It measures the elapsed time, the peak memory and the result size of one
## call, and runs the 20 scenarios behind the plan's section 3, one per row,
## with the inputs and settings S1050 measured them with.
##
## This file only defines functions. tools/perf/run.R loads the package with
## pkgload::load_all() and sources this file into an environment whose parent
## is the package namespace; tests/testthat/test_perfHarness.R does the same.
## tools/ is kept out of the built package (.Rbuildignore).
##
## A scenario run with `quick = TRUE` makes the same calls on a small stand-in
## (a 150-animal synthetic colony, few iterations). Its rows say "quick" in
## their input, so a quick run is never taken for a baseline.

## ---- Measuring one call ----------------------------------------------------

## The memory in use, and the peak since the last gc(reset = TRUE), in Mb, from
## a gc() result. R 4.6 adds a "limit (Mb)" column before "max used", so both
## columns are found by name, and the Mb figure is the column after each.
usedMb <- function(g) {
  sum(g[, mbColumnAfter(g, "used")])
}

maxUsedMb <- function(g) {
  sum(g[, mbColumnAfter(g, "max used")])
}

mbColumnAfter <- function(g, name) {
  col <- which(colnames(g) == name)
  if (length(col) != 1L) {
    stop("the gc() result has no '", name, "' column", call. = FALSE)
  }
  col + 1L
}

## The elapsed seconds, the peak memory above the starting point (Mb) and the
## size of the result (Mb) of one expression, plus its value. The expression is
## forced inside the timed window, once. The peak is a high-water mark sampled
## at garbage collections: a lower bound, and noisy (plan section 2).
measure <- function(expr) {
  base <- usedMb(gc(reset = TRUE))
  started <- proc.time()[["elapsed"]]
  value <- expr
  seconds <- proc.time()[["elapsed"]] - started
  peakMb <- maxUsedMb(gc()) - base
  list(seconds = seconds, peakMb = peakMb,
       resultMb = as.numeric(utils::object.size(value)) / 2L^20L,
       value = value)
}

## Run `code` after set.seed(seed), then put the caller's random-number state
## back as it was (or remove it, when there was none).
withSeed <- function(seed, code) {
  hadSeed <- exists(".Random.seed", envir = globalenv(), inherits = FALSE)
  if (hadSeed) {
    oldSeed <- get(".Random.seed", envir = globalenv(), inherits = FALSE)
  }
  on.exit({
    if (hadSeed) {
      # nolint next: object_name_linter. R fixes the name.
      assign(".Random.seed", oldSeed, envir = globalenv())
    } else if (exists(".Random.seed", envir = globalenv(), inherits = FALSE)) {
      rm(".Random.seed", envir = globalenv())
    }
  }, add = TRUE)
  set.seed(seed)
  code
}

## ---- Inputs ----------------------------------------------------------------

## A synthetic colony, labelled synthetic wherever it is cited (no real
## studbook above 3,694 animals is in the repository). Founders, then births
## spread over `years`; 1 male in 6 breeds; parents 3.5 to 20 years older than
## their offspring; death at 1 to 25 years, so the recent animals are alive.
## The founders are at least 20, so the smallest colony is 21 animals.
synthColony <- function(n, seed = 1L, years = 45L, foundFrac = 0.06) {
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n != round(n) ||
        n < 21L) {
    stop("synthColony(): n must be a whole number of at least 21 ",
         "(20 founders and one offspring)", call. = FALSE)
  }
  n <- as.integer(n)
  withSeed(seed, {
    nF <- max(20L, round(n * foundFrac))
    birth <- c(stats::runif(nF, 0L, 4L),
               sort(stats::runif(n - nF, 4L, years)))
    sex <- sample(c("M", "F"), n, replace = TRUE)
    id <- sprintf("S%06d", seq_len(n))
    sire <- dam <- rep(NA_character_, n)
    breederM <- sex == "M" & stats::runif(n) < 1L / 6L
    for (i in (nF + 1L):n) {
      elig <- which(birth >= birth[i] - 20L & birth <= birth[i] - 3.5)
      m <- elig[breederM[elig]]
      f <- elig[sex[elig] == "F"]
      if (length(m) == 0L || length(f) == 0L) next
      sire[i] <- id[m[sample.int(length(m), 1L)]]
      dam[i] <- id[f[sample.int(length(f), 1L)]]
    }
    exitT <- birth + stats::runif(n, 1L, 25L)
    exitT[exitT > years] <- NA
    origin <- as.Date("1975-01-01")
    data.frame(id = id, sire = sire, dam = dam, sex = sex,
               birth = origin + round(birth * 365.25),
               exit = origin + round(exitT * 365.25),
               stringsAsFactors = FALSE)
  })
}

## The app's path up to reportGV(): QC, the living animals as the population
## (R/modPedigree.R), pedigree numbers, generations, then the trim to the
## analysis population (R/modGeneticValue.R). `everyone = TRUE` puts every
## animal in the population ("example (all 3694)" in the plan).
appAnalysisPed <- function(raw, trim = TRUE, everyone = FALSE) {
  sb <- qcStudbook(raw, minSireAge = 2L, minDamAge = 2L,
                   reportChanges = FALSE, reportErrors = FALSE)
  ped <- setPopulation(sb, sb$id[isLivingAnimal(sb)])
  ped$pedNum <- findPedigreeNumber(ped$id, ped$sire, ped$dam)
  if (!"gen" %in% names(ped)) {
    ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  }
  if (everyone) {
    ped$population <- TRUE
  }
  if (trim) {
    ped <- trimToAnalysisPopulation(ped)
  }
  ped
}

quickLabel <- "synthetic 150 (quick)"
quickColony <- function() synthColony(150L, seed = 1L)

## The raw studbook of an input and its label: the 150-animal stand-in when
## `quick`, else the real one, which `readRaw()` reads only then.
rawInput <- function(quick, label, readRaw) {
  if (quick) {
    return(list(label = quickLabel, raw = quickColony()))
  }
  list(label = label, raw = readRaw())
}

## An input is a list(label, ped): its raw studbook, put through `prepare()`.
pedInput <- function(quick, label, readRaw, prepare) {
  input <- rawInput(quick, label, readRaw)
  list(label = input$label, ped = prepare(input$raw))
}

readExample <- function() nprcgenekeepr::examplePedigree

## The de-identified Japanese macaque studbook, read as the plan's section 2
## says: blank cells as NA.
readJmac <- function() {
  utils::read.csv(system.file("extdata", "examples",
                              "deidentified_jmac_ped.csv",
                              package = "nprcgenekeepr"),
                  na.strings = c("", "NA"), stringsAsFactors = FALSE)
}

exampleTrim <- function(quick) {
  pedInput(quick, "example (app trim)", readExample, appAnalysisPed)
}

exampleAll <- function(quick) {
  pedInput(quick, "example (all 3694)", readExample, function(raw) {
    appAnalysisPed(raw, trim = FALSE, everyone = TRUE)
  })
}

## The living animals as the population, untrimmed: the pedigree whose kinship
## the relationship table and the long form were measured on.
exampleLiving <- function(quick) {
  pedInput(quick, "example (all 3694)", readExample, function(raw) {
    appAnalysisPed(raw, trim = FALSE)
  })
}

synthetic10000 <- function(quick) {
  pedInput(quick, "synthetic 10000",
           function() synthColony(10000L, seed = 1L), appAnalysisPed)
}

rhesus <- function(quick) {
  pedInput(quick, "rhesus 375", function() nprcgenekeepr::rhesusPedigree,
           function(raw) {
             qcStudbook(raw, reportChanges = FALSE, reportErrors = FALSE)
           })
}

## The jmac studbook is QC'd with no minimum parent age (the plan's section 2).
jmac <- function(quick) {
  pedInput(quick, "jmac 2590", readJmac, function(raw) {
    qcStudbook(raw, minSireAge = 0L, minDamAge = 0L, reportChanges = FALSE,
               reportErrors = FALSE)
  })
}

## ---- Scenarios -------------------------------------------------------------

measurementRow <- function(input, label, m) {
  data.frame(input = input, label = label, seconds = m$seconds,
             peakMb = m$peakMb, resultMb = m$resultMb,
             stringsAsFactors = FALSE)
}

## A pedigree's kinship matrix, from its id, sire, dam and gen columns.
pedKinship <- function(ped, sparse = FALSE) {
  kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = sparse)
}

## reportGV()'s expensive stages, one at a time, in reportGV()'s order, at
## threshold 4 with byID = TRUE (the plan's section 3.1).
runStages <- function(input, iter) {
  ped <- input$ped
  probands <- as.character(ped$id[ped$population])
  row <- function(label, m) measurementRow(input$label, label, m)
  k <- measure(pedKinship(ped))
  kp <- measure(filterKinMatrix(probands, k$value))
  rows <- list(row("kinship (analysis pedigree)", k),
               row("filterKinMatrix (probands)", kp))
  rm(k, kp)
  invisible(gc())
  drop <- withSeed(20261024L, measure(
    geneDrop(ped$id, ped$sire, ped$dam, ped$gen, n = iter)
  ))
  alleles <- drop$value
  rows <- c(rows, list(row(sprintf("geneDrop (n = %d)", iter), drop)))
  rm(drop)
  stages <- list(
    calcGU = function() {
      calcGU(alleles, threshold = 4L, byID = TRUE, pop = probands)
    },
    calcGUSE = function() {
      calcGUSE(alleles, threshold = 4L, byID = TRUE, pop = probands)
    },
    calcFEFG = function() calcFEFG(ped, alleles),
    calcFGSE = function() calcFGSE(ped, alleles),
    offspringCounts = function() {
      offspringCounts(probands, ped, considerPop = TRUE)
    }
  )
  for (stage in names(stages)) {
    rows <- c(rows, list(row(stage, measure(stages[[stage]]()))))
  }
  do.call(rbind, rows)
}

gvIterations <- function(quick) if (quick) 10L else 1000L

reportGVScenario <- function(quick) {
  input <- exampleTrim(quick)
  iter <- gvIterations(quick)
  m <- withSeed(20261024L, measure(
    reportGV(input$ped, guIter = iter, guThresh = 4L, byID = TRUE)
  ))
  measurementRow(input$label, sprintf("reportGV (n = %d)", iter), m)
}

gvStagesScenario <- function(inputOf) {
  function(quick) runStages(inputOf(quick), gvIterations(quick))
}

## The relationship table on the first n animals of the full kinship matrix.
convertRelationshipsScenario <- function(n) {
  function(quick) {
    input <- exampleLiving(quick)
    ped <- input$ped
    kFull <- pedKinship(ped)
    size <- if (quick) 20L else n
    ids <- rownames(kFull)[seq_len(size)]
    m <- measure(convertRelationships(kFull[ids, ids], ped))
    measurementRow(input$label,
                   sprintf("convertRelationships (first %d animals)", size), m)
  }
}

kinMatrix2LongFormScenario <- function(removeDups) {
  function(quick) {
    input <- exampleLiving(quick)
    kFull <- pedKinship(input$ped)
    m <- measure(kinMatrix2LongForm(kFull, removeDups = removeDups))
    measurementRow(input$label,
                   sprintf("kinMatrix2LongForm (removeDups = %s)", removeDups),
                   m)
  }
}

## Group formation as the tutorial sets it up: the living animals with a
## recorded parent, trimmed to their ancestors; candidates born before 2013
## and alive; 6 groups.
groupAddAssignScenario <- function(iter, harem) {
  function(quick) {
    input <- rawInput(quick, "example", readExample)
    sb <- qcStudbook(input$raw, minSireAge = 2L, minDamAge = 2L,
                     reportChanges = FALSE, reportErrors = FALSE)
    focal <- sb$id[!(is.na(sb$sire) & is.na(sb$dam)) & is.na(sb$exit)]
    tped <- trimPedigree(focal, sb)
    tk <- pedKinship(tped)
    cand <- tped$id[!is.na(tped$birth) & tped$birth < as.Date("2013-01-01") &
                      is.na(tped$exit)]
    trials <- if (quick) 2L else iter
    m <- withSeed(1L, measure(
      groupAddAssign(cand, tk, tped, iter = trials, numGp = 6L, harem = harem)
    ))
    measurementRow(sprintf("%s, %d candidates", input$label, length(cand)),
                   sprintf("groupAddAssign (6 %s, %d trials)",
                           if (harem) "harems" else "groups", trials),
                   m)
  }
}

## The layout's notes (animals left out, edges it could not clear) are about
## the drawing, not the measurement, so they are kept off the console.
diagramScenario <- function(inputOf, style) {
  function(quick) {
    input <- inputOf(quick)
    m <- measure(suppressMessages(suppressWarnings(
      makePedigreeMatingLayout(input$ped, edgeStyle = style)
    )))
    measurementRow(input$label,
                   sprintf("makePedigreeMatingLayout (%s)", style), m)
  }
}

backfillScenario <- function(quick) {
  input <- jmac(quick)
  dates <- if (quick) {
    as.Date("2015-01-01")
  } else {
    as.Date(c("2000-01-01", "2010-01-01", "2018-07-01"))
  }
  iter <- gvIterations(quick)
  m <- withSeed(3L, measure(suppressWarnings(
    backfillColonySnapshots(input$ped, dates = dates, guIter = iter,
                            guThresh = 4L)
  )))
  measurementRow(input$label,
                 sprintf("backfillColonySnapshots (%d dates x %d)",
                         length(dates), iter), m)
}

gvaConvergenceScenario <- function(quick) {
  input <- exampleTrim(quick)
  nMax <- if (quick) 50L else 3000L
  m <- withSeed(5L, measure(
    gvaConvergence(input$ped, nMax = nMax, guThresh = 4L)
  ))
  measurementRow(input$label, sprintf("gvaConvergence (nMax = %d)", nMax), m)
}

kinshipSparseScenario <- function(inputOf) {
  function(quick) {
    input <- inputOf(quick)
    m <- measure(pedKinship(input$ped, sparse = TRUE))
    measurementRow(input$label, "kinship (sparse = TRUE)", m)
  }
}

## One scenario per row of the plan's section 3, in its order.
scenarioRegistry <- function() {
  list(
    `reportGV-example` = reportGVScenario,
    `gvStages-example` = gvStagesScenario(exampleTrim),
    `gvStages-all` = gvStagesScenario(exampleAll),
    `gvStages-synthetic10000` = gvStagesScenario(synthetic10000),
    `convertRelationships-150` = convertRelationshipsScenario(150L),
    `convertRelationships-300` = convertRelationshipsScenario(300L),
    `convertRelationships-600` = convertRelationshipsScenario(600L),
    `kinMatrix2LongForm-all` = kinMatrix2LongFormScenario(FALSE),
    `kinMatrix2LongForm-all-removeDups` = kinMatrix2LongFormScenario(TRUE),
    `groupAddAssign-10` = groupAddAssignScenario(10L, harem = FALSE),
    `groupAddAssign-1000` = groupAddAssignScenario(1000L, harem = FALSE),
    `groupAddAssign-harem-10` = groupAddAssignScenario(10L, harem = TRUE),
    `groupAddAssign-harem-1000` = groupAddAssignScenario(1000L, harem = TRUE),
    `diagram-rhesus-direct` = diagramScenario(rhesus, "direct"),
    `diagram-rhesus-rectilinear` = diagramScenario(rhesus, "rectilinear"),
    `diagram-example-direct` = diagramScenario(exampleTrim, "direct"),
    `backfill-jmac` = backfillScenario,
    `gvaConvergence-example` = gvaConvergenceScenario,
    `kinshipSparse-example` = kinshipSparseScenario(exampleTrim),
    `kinshipSparse-all` = kinshipSparseScenario(exampleAll)
  )
}

scenarioNames <- function() names(scenarioRegistry())

## The rows of one scenario: one per measured call, with its scenario name.
runScenario <- function(name, quick = FALSE) {
  registry <- scenarioRegistry()
  if (length(name) != 1L || !name %in% names(registry)) {
    stop("unknown scenario '", toString(name), "'; the scenarios are: ",
         toString(names(registry)), call. = FALSE)
  }
  rows <- registry[[name]](quick)
  cbind(scenario = name, rows, stringsAsFactors = FALSE)
}

## What a gate reads: the scenario's total time and its highest peak.
headline <- function(rows) {
  c(seconds = sum(rows$seconds), peakMb = max(rows$peakMb))
}

## ---- The command line ------------------------------------------------------

## The number of runs a command line asks for, and the command line without
## --runs and its value: 1 run when there is no --runs, else the whole number
## after it, or NA when that value is missing, not a whole number or below 1.
runsArg <- function(args) {
  at <- which(args == "--runs")
  if (length(at) == 0L) {
    return(list(runs = 1L, rest = args))
  }
  value <- if (length(at) == 1L && at < length(args)) args[[at + 1L]] else ""
  runs <- if (grepl("^[0-9]+$", value)) as.integer(value) else NA_integer_
  if (!is.na(runs) && runs < 1L) {
    runs <- NA_integer_
  }
  list(runs = runs, rest = args[-c(at, at + 1L)])
}

## What run.R prints and its exit status, for `Rscript tools/perf/run.R
## <scenario> [--quick] [--runs N]`: one line per measured call, then SECONDS=
## and PEAK_MB= for the gates. With --runs N the scenario runs N times in this
## process, every run's lines are printed, and SECONDS= and PEAK_MB= are the
## medians of the runs' headlines, so one run that a full garbage collection
## falls into does not decide a gate (S1078). A wrong or missing name, or a
## --runs value that is not a whole number above 0, prints the usage and the
## scenario names, with status 2.
runMain <- function(args) {
  usage <- c("Usage: Rscript tools/perf/run.R <scenario> [--quick] [--runs N]",
             "Scenarios:", paste0("  ", scenarioNames()))
  runs <- runsArg(args)
  quick <- "--quick" %in% runs$rest
  name <- setdiff(runs$rest, "--quick")
  if (is.na(runs$runs) || length(name) != 1L) {
    return(list(lines = usage, status = 2L))
  }
  if (!name %in% scenarioNames()) {
    return(list(lines = c(sprintf("Unknown scenario: %s", name), usage),
                status = 2L))
  }
  each <- lapply(seq_len(runs$runs), function(i) {
    runScenario(name, quick = quick)
  })
  rows <- do.call(rbind, each)
  tops <- vapply(each, headline, c(seconds = 0.0, peakMb = 0.0))
  lines <- c(
    sprintf("%-28s %-44s %9.2f s  peak %8.1f MB  result %8.1f MB",
            rows$input, rows$label, rows$seconds, rows$peakMb, rows$resultMb),
    sprintf("SECONDS=%.2f", stats::median(tops["seconds", ])),
    sprintf("PEAK_MB=%.1f", stats::median(tops["peakMb", ]))
  )
  list(lines = lines, status = 0L)
}
