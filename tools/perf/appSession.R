## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## The scripted app session of the performance and memory campaign (design
## docs/planning/app-kinship-memory-design.md section 8; owner ruling F6,
## S1062). It drives the running app through the steps of the design's
## section 2.1 table and records, after each step, the app process's resident
## memory and every kinship() and convertRelationships() call the app made in
## that step (tools/perf/appSession/app.R traces them). Phase 0's session
## (docs/audits/PERF_BASELINE_2026-10-24.md Appendix A) is its first five
## steps; S1062 added the Genetic Diversity, Mate Pair and Marker Genetics
## steps and the trace.
##
## Run it with tools/perf/runAppSession.R. It needs Chrome (shinytest2), so it
## is not a ratchet gate: tests/testthat/test_perfAppSession.R checks only that
## it parses and lists its steps. This file only defines functions, so the
## test can read it with sys.source().

## The example studbook the session uploads, from the source tree the runner
## names in NPRC_PERF_PKG.
appSessionPedigreeFile <- function() {
  file.path(Sys.getenv("NPRC_PERF_PKG"), "inst", "extdata", "examples",
            "ExamplePedigree.csv")
}

## Wait until the app has been idle for `ms` milliseconds.
appSessionWait <- function(app, ms = 1500L) {
  app$wait_for_idle(duration = ms, timeout = 900000L)
}

## Open a page of the app's top navigation bar.
appSessionOpen <- function(app, tab, ms = 1500L) {
  app$set_inputs(mainNavbar = tab)
  appSessionWait(app, ms)
}

## One function of the running AppDriver per row of the design's section 2.1
## table, in its order.
appSessionSteps <- list(
  "app started" = function(app) invisible(NULL),
  "upload + QC" = function(app) {
    app$upload_file(`dataInput-pedigreeFileOne` = appSessionPedigreeFile())
    app$click("dataInput-getData")
    appSessionWait(app, 3000L)
  },
  "open Genetic Diversity (no groups)" = function(app) {
    appSessionOpen(app, "Genetic Diversity")
  },
  "Genetic Value run (1,000 iterations)" = function(app) {
    app$set_inputs(mainNavbar = "Genetic Value Analysis")
    app$set_inputs(`geneticValue-nIterations` = 1000L)
    app$click("geneticValue-runAnalysis")
    appSessionWait(app, 2000L)
  },
  "open Summary Statistics" = function(app) {
    appSessionOpen(app, "Summary Statistics", 2000L)
  },
  "Breeding Groups: Form Groups (defaults)" = function(app) {
    app$set_inputs(mainNavbar = "Breeding Groups")
    app$click("breedingGroups-formGroups")
    appSessionWait(app, 2000L)
  },
  "open Genetic Diversity (groups formed)" = function(app) {
    appSessionOpen(app, "Genetic Diversity")
  },
  "Mate Pair: Find Eligible Pairs (defaults)" = function(app) {
    app$set_inputs(mainNavbar = "Mate Pair Analysis")
    app$click("matePair-analyze")
    appSessionWait(app, 2000L)
  },
  "open Marker Genetics" = function(app) {
    appSessionOpen(app, "Marker Genetics")
  },
  "open its Linkage and LD Block Metrics tab" = function(app) {
    app$click(selector = "a[data-value='Linkage and LD Block Metrics']")
    appSessionWait(app, 3000L)
  }
)

## What the steps left on the page, so a step that silently did nothing shows.
appSessionShown <- function(app) {
  count <- function(selector) {
    app$get_js(sprintf("document.querySelectorAll(\"%s\").length", selector))
  }
  text <- function(selector) {
    app$get_js(sprintf("(document.querySelector(\"%s\") || {innerText: ''})%s",
                       selector, ".innerText"))
  }
  c(
    rankingsRows = count("#geneticValue-rankingsTable tbody tr"),
    summaryPlots = count(paste("#summaryStats-mkHist img,",
                               "#summaryStats-zscoreHist img,",
                               "#summaryStats-guHist img")),
    groupsTables = count("#breedingGroups-groupsDisplay table"),
    heatmapImages = count("#geneticDiversity-heatmap img"),
    matePairs = text("#matePair-pairsTable .dataTables_info"),
    realizedRelatedness = text(paste("#markerGenetics-realizedRelatednessTable",
                                     ".dataTables_info"))
  )
}

## The app's R process: the one listening on the app's port.
appSessionPid <- function(app) {
  port <- sub(".*:([0-9]+).*", "\\1", app$get_url())
  system2("lsof", c("-nP", paste0("-iTCP:", port), "-sTCP:LISTEN", "-t"),
          stdout = TRUE)[[1L]]
}

## That process's resident memory, in MB.
appSessionRssMb <- function(pid) {
  as.numeric(system2("ps", c("-o", "rss=", "-p", pid), stdout = TRUE)) / 1024.0
}

## Run every step once on the app in `appDir`: a data frame with one row a
## step (its seconds, including the quiet wait after it, the app's resident
## memory after it, and the kinship calls the app logged to `logFile` during
## it), and what the steps left on the page. `progress` gets each row.
runAppSession <- function(appDir, runLabel, logFile, progress = identity) {
  if (file.exists(logFile)) {
    file.remove(logFile)
  }
  app <- shinytest2::AppDriver$new(appDir, name = "perf_app_session",
                                   height = 900L, width = 1400L,
                                   load_timeout = 180000L, timeout = 900000L,
                                   screenshot_args = FALSE)
  on.exit(app$stop(), add = TRUE)
  pid <- appSessionPid(app)
  seen <- 0L
  rows <- vector("list", length(appSessionSteps))
  for (i in seq_along(appSessionSteps)) {
    started <- proc.time()[["elapsed"]]
    appSessionSteps[[i]](app)
    seconds <- proc.time()[["elapsed"]] - started
    logged <- if (file.exists(logFile)) readLines(logFile) else character(0L)
    calls <- logged[seq_along(logged) > seen]
    seen <- length(logged)
    rows[[i]] <- data.frame(run = runLabel, step = names(appSessionSteps)[[i]],
                            seconds = round(seconds, 1L),
                            rssMb = round(appSessionRssMb(pid), 1L),
                            kinshipCalls = paste(calls, collapse = "; "),
                            stringsAsFactors = FALSE)
    progress(rows[[i]])
  }
  list(table = do.call(rbind, rows), shown = appSessionShown(app))
}
