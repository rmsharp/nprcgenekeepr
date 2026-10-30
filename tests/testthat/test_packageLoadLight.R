## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Prepare the 3.0.0 CRAN submission", plan Phase 2 (owner pick
## S1096, "Load 2 packages later"; docs/planning/cran-3.0.0-submission-plan.md).
## R CMD check --as-cran collects garbage before each of the package's 216
## help examples (cleanEx() calls showConnections(), which calls gc(), when
## _R_CHECK_CONNECTIONS_LEFT_OPEN_ is set). Matrix and ggplot2, loaded with the
## package, made each collection about 2.5 times slower: 63 s of win-builder's
## 90 s examples step was spent between examples (S1095's a1AV26256EC9), while
## no example uses Matrix and the first that uses ggplot2 is the 140th. The
## package now loads each when it is first needed: kinship(sparse = TRUE) loads
## Matrix, a plot loads ggplot2.

lateLoaded <- c("Matrix", "ggplot2")

test_that("the NAMESPACE imports nothing from Matrix or ggplot2", {
  nsFile <- system.file("NAMESPACE", package = "nprcgenekeepr")
  expect_true(file.exists(nsFile))
  imports <- parseNamespaceFile(basename(dirname(nsFile)),
                                dirname(dirname(nsFile)))$imports
  importedFrom <- vapply(imports, function(imp) {
    if (is.list(imp)) imp[[1L]] else imp
  }, "")
  expect_identical(intersect(lateLoaded, importedFrom), character(0))
})

## pkgload::load_all() loads every package DESCRIPTION imports, whatever the
## NAMESPACE says, so only a fresh R loading the installed package shows what
## loading it loads: R CMD check and CI's R-CMD-check run this block.
test_that("a fresh R loading the installed package leaves Matrix and ggplot2 unloaded", {
  skip_on_covr()
  skip_if(exists(".__DEVTOOLS__", envir = asNamespace("nprcgenekeepr"),
                 inherits = FALSE),
          "loaded by pkgload::load_all(), which loads every Imports package")
  script <- withr::local_tempfile(fileext = ".R")
  writeLines(c(
    "invisible(loadNamespace(\"nprcgenekeepr\"))",
    sprintf("writeLines(c(\"loaded\", intersect(%s, loadedNamespaces())))",
            deparse(lateLoaded))
  ), script)
  withr::local_envvar(R_LIBS = paste(.libPaths(),
                                     collapse = .Platform$path.sep))
  out <- system2(file.path(R.home("bin"), "Rscript"),
                 c("--vanilla", shQuote(script)), stdout = TRUE,
                 stderr = FALSE)
  expect_identical(out, "loaded", info = paste(out, collapse = " | "))
})
