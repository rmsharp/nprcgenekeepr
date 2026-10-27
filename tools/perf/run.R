## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Run one measuring scenario of the performance and memory campaign:
##
##   Rscript tools/perf/run.R <scenario> [--quick] [--runs N]
##
## from the project root (a ratchet gate's command runs there). It loads the
## package from the source tree, runs the scenario (tools/perf/harness.R) and
## prints one line per measured call, then SECONDS= and PEAK_MB= for the gates
## in methodology/.quality-gates.json; with --runs N it runs the scenario N
## times and SECONDS= and PEAK_MB= are the medians. With no name, a wrong one
## or a bad --runs value it prints the scenario names and exits with status 2.

script <- sub("^--file=", "",
              grep("^--file=", commandArgs(FALSE), value = TRUE)[[1L]])
here <- dirname(normalizePath(script))
suppressMessages(pkgload::load_all(file.path(here, "..", ".."), quiet = TRUE))

perf <- new.env(parent = asNamespace("nprcgenekeepr"))
sys.source(file.path(here, "harness.R"), envir = perf)
result <- perf$runMain(commandArgs(trailingOnly = TRUE))
writeLines(result$lines)
quit(save = "no", status = result$status)
