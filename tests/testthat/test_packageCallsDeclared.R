## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## CRAN 3.0.0 plan Phase 4a (docs/planning/cran-3.0.0-submission-plan.md): a
## default install brings in Depends and Imports, not Suggests, so a package that
## R/ calls with no guard has to be in Imports. S1098 measured what happens
## otherwise: with shinyBS absent, appUI() stops with "there is no package called
## 'shinyBS'" and the whole app fails to start.

pkgRoot <- testthat::test_path("..", "..")

## packageCallsIn() on one piece of R source.
callsInSource <- function(source) {
  path <- tempfile(fileext = ".R")
  on.exit(unlink(path))
  writeLines(source, path)
  packageCallsIn(path)
}

test_that("packageCallsIn() finds calls with the line and package of each", {
  calls <- callsInSource(c("x <- 1", "y <- foo::bar()", "z <- baz:::qux()"))
  expect_identical(calls$line, c(2L, 3L))
  expect_identical(calls$pkg, c("foo", "baz"))
  expect_identical(calls$guarded, c(FALSE, FALSE))
})

test_that("packageCallsIn() finds a call whose package name is quoted", {
  expect_identical(callsInSource("\"foo\"::bar()")$pkg, "foo")
})

test_that("packageCallsIn() does not take a comment or a string for a call", {
  expect_identical(nrow(callsInSource("# foo::bar()")), 0L)
  expect_identical(nrow(callsInSource("y <- \"foo::bar()\"")), 0L)
  expect_identical(nrow(callsInSource("#' @importFrom foo::bar")), 0L)
})

test_that("packageCallsIn() returns no rows for a file with no code", {
  calls <- callsInSource("")
  expect_identical(nrow(calls), 0L)
  expect_named(calls, c("line", "pkg", "guarded"))
})

test_that("packageCallsIn() accepts a call in the branch that asks for its package", {
  guarded <- c(
    "if (requireNamespace(\"foo\")) foo::bar()",
    "if (requireNamespace(\"foo\", quietly = TRUE)) foo::bar()",
    "if (requireNamespace('foo', quietly = TRUE)) { foo::bar() }",
    "f <- function() { if (requireNamespace(\"foo\")) { g(h(foo::bar())) } }"
  )
  for (source in guarded) {
    expect_true(callsInSource(source)$guarded, info = source)
  }
})

test_that("packageCallsIn() rejects a condition that does not protect the call", {
  unguarded <- c(
    "if (requireNamespace(\"other\")) foo::bar()",
    "if (!requireNamespace(\"foo\")) foo::bar()",
    "if (requireNamespace(\"foo\")) 1 else foo::bar()",
    "if (isTRUE(x)) foo::bar()",
    "if (foo::bar()) 1"
  )
  for (source in unguarded) {
    expect_false(callsInSource(source)$guarded, info = source)
  }
})

test_that("undeclaredPackageCalls() leaves out declared, base, guarded and self", {
  calls <- data.frame(
    line = 1:5,
    pkg = c("missing", "listed", "stats", "nprcgenekeepr", "optional"),
    guarded = c(FALSE, FALSE, FALSE, FALSE, TRUE)
  )
  left <- undeclaredPackageCalls(calls, declared = "listed")
  expect_identical(left$pkg, "missing")
  expect_identical(left$line, 1L)
})

test_that("every package R/ calls is in Imports, or the call is guarded", {
  rDir <- file.path(pkgRoot, "R")
  skip_if_not(rSourceAvailable(rDir), "R/ not available (installed package)")
  declared <- c(readDescriptionField("Depends"), readDescriptionField("Imports"))
  files <- list.files(rDir, pattern = "\\.[Rr]$", full.names = TRUE)
  found <- unlist(lapply(files, function(path) {
    bad <- undeclaredPackageCalls(packageCallsIn(path), declared)
    if (nrow(bad) > 0L) paste0(basename(path), ":", bad$line, " ", bad$pkg)
  }))
  expect_identical(as.character(found), character(),
    info = paste(found, collapse = "\n")
  )
})
