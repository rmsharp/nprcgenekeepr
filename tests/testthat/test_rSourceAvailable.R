## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## rSourceAvailable() (helper-rSource.R) says whether a folder holds R source.
## A test that scans R/ must run only against a source tree: under covr (the
## test-coverage workflow) the tests run from an installed copy of the package,
## where `../../R` exists but holds only `.rdb`/`.rdx` files, so a
## `dir.exists()` skip lets the scan read nothing and fail (S893 for
## test_sexCodes.R; S1090 for test_roxygenInheritParams.R, run 40822189540).

test_that("rSourceAvailable() is FALSE where there is no R source", {
  base <- tempfile("srcavail")
  dir.create(base)
  on.exit(unlink(base, recursive = TRUE))
  emptyDir <- file.path(base, "empty")
  installedDir <- file.path(base, "installed")
  nestedDir <- file.path(base, "nested")
  dir.create(emptyDir)
  dir.create(installedDir)
  dir.create(file.path(nestedDir, "sub"), recursive = TRUE)
  file.create(file.path(installedDir, c("pkg", "pkg.rdb", "pkg.rdx")))
  file.create(file.path(nestedDir, "sub", "deep.R"))
  expect_false(rSourceAvailable(file.path(base, "absent")))
  expect_false(rSourceAvailable(emptyDir))
  expect_false(rSourceAvailable(installedDir))
  expect_false(rSourceAvailable(nestedDir))
})

test_that("rSourceAvailable() is TRUE where R holds a .R or .r file", {
  base <- tempfile("srcavail")
  dir.create(base)
  on.exit(unlink(base, recursive = TRUE))
  sourceDir <- file.path(base, "source")
  lowerDir <- file.path(base, "lower")
  dir.create(sourceDir)
  dir.create(lowerDir)
  file.create(file.path(sourceDir, c("a.R", "pkg.rdb")))
  file.create(file.path(lowerDir, "b.r"))
  expect_true(rSourceAvailable(sourceDir))
  expect_true(rSourceAvailable(lowerDir))
})
