## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Build script for the `exampleNprcgenekeeprConfig` data object: the lines of
#' the shipped example configuration file, so that
#' `data("exampleNprcgenekeeprConfig")` shows the same notes and settings as
#' `inst/extdata/examples/example_nprcgenekeepr_config`. README.md and the
#' manual tell users to open it with `View()`. Before this script the object
#' was a hand-made older copy (34 lines against the shipped 87) that repeated
#' the notes' wrong sentences; `test_configFileNotes.R` fails when the two
#' differ. Re-run after any change to the example file. Idempotent.
#'
#' Run from the package root:
#'   Rscript data-raw/exampleNprcgenekeeprConfig.R
exampleNprcgenekeeprConfig <- readLines(
  file.path("inst", "extdata", "examples", "example_nprcgenekeepr_config"),
  warn = FALSE
)
save(exampleNprcgenekeeprConfig,
  file = file.path("data", "exampleNprcgenekeeprConfig.RData"),
  compress = "xz"
)
