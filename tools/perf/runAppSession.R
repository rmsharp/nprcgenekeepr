## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Run the scripted app session once (tools/perf/appSession.R):
##
##   Rscript tools/perf/runAppSession.R <run label> <out.csv>
##
## from the project root, with Chrome installed and renv's library holding
## shinytest2. It starts the app on the source tree
## (tools/perf/appSession/app.R), takes the design's ten steps, prints one
## line a step (seconds, the app's resident memory, the kinship calls the step
## made), then what the steps left on the page and DONE, and writes the steps'
## table to <out.csv>. Phase 0's recipe takes three runs and reports each
## step's median (docs/audits/PERF_BASELINE_2026-10-24.md section 4). With
## the wrong number of arguments it prints this usage and exits with status 2.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) {
  writeLines("usage: Rscript tools/perf/runAppSession.R <run label> <out.csv>")
  quit(save = "no", status = 2L)
}
script <- sub("^--file=", "",
              grep("^--file=", commandArgs(FALSE), value = TRUE)[[1L]])
here <- dirname(normalizePath(script))

## The app's process inherits these: which tree to load, and where to log.
## This script's whole run is their scope, so they are set, not scoped.
Sys.setenv(NPRC_PERF_PKG = normalizePath(file.path(here, "..", "..")), # nolint: undesirable_function_linter
           NPRC_PERF_KINSHIP_LOG = tempfile("kinship-", fileext = ".log"),
           NOT_CRAN = "true")

session <- new.env()
sys.source(file.path(here, "appSession.R"), envir = session)
result <- session$runAppSession(
  appDir = file.path(here, "appSession"),
  runLabel = args[[1L]],
  logFile = Sys.getenv("NPRC_PERF_KINSHIP_LOG"),
  progress = function(row) {
    cat(sprintf("STEP %-44s rss %7.1f MB %7.1f s\n", row$step, row$rssMb,
                row$seconds))
    if (nzchar(row$kinshipCalls)) {
      cat("    ", gsub("; ", "\n     ", row$kinshipCalls, fixed = TRUE), "\n")
    }
  }
)
print(result$shown)
utils::write.csv(result$table, args[[2L]], row.names = FALSE)
cat("DONE\n")
