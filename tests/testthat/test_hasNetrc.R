## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## Issue #111 coverage backfill: hasNetrc() detects an Rlabkey-usable netrc
## file. The Windows branch (line 22, filename "_netrc") never ran because the
## CI/dev host is not Windows; the function deliberately takes homeDir and
## sysname arguments so both OS branches are testable. It is @noRd, so reach it
## with ::: . NETRC is forced empty so the env-var short-circuit does not mask
## the home-directory lookup.

test_that("hasNetrc finds a Windows '_netrc' file in the home directory", {
  withr::local_envvar(c(NETRC = ""))
  d <- withr::local_tempdir()
  file.create(file.path(d, "_netrc"))
  expect_true(nprcgenekeepr:::hasNetrc(homeDir = d, sysname = "Windows"))
  ## A '.netrc' file does not satisfy the Windows branch.
  expect_false(nprcgenekeepr:::hasNetrc(homeDir = withr::local_tempdir(),
                                        sysname = "Windows"))
})

test_that("hasNetrc finds a non-Windows '.netrc' file in the home directory", {
  withr::local_envvar(c(NETRC = ""))
  d <- withr::local_tempdir()
  file.create(file.path(d, ".netrc"))
  expect_true(nprcgenekeepr:::hasNetrc(homeDir = d, sysname = "Linux"))
  expect_false(nprcgenekeepr:::hasNetrc(homeDir = withr::local_tempdir(),
                                        sysname = "Linux"))
})

test_that("hasNetrc honors the NETRC environment variable first", {
  nf <- withr::local_tempfile()
  file.create(nf)
  withr::local_envvar(c(NETRC = nf))
  ## Even with an empty home directory, the NETRC env var wins.
  expect_true(nprcgenekeepr:::hasNetrc(homeDir = withr::local_tempdir(),
                                       sysname = "Linux"))
})
