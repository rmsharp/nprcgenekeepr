## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md: inst/_pkgdown.yml's curated Reference-page grouping is dead
## configuration -- pkgdown's config resolver only ever reads the root
## _pkgdown.yml (pkgdown::as_pkgdown()$meta), so inst/_pkgdown.yml's grouped
## structure was never used, and had drifted from NAMESPACE besides. These
## guards assert the root config carries a populated, current reference:
## block and that the shadowed duplicate file is gone.
##
## Scope: repo source tree only (root _pkgdown.yml and inst/_pkgdown.yml are
## both .Rbuildignore'd, so neither exists in a built/installed tree).

pkg_root <- testthat::test_path("..", "..")
pkgdown_yml <- file.path(pkg_root, "_pkgdown.yml")
no_pkgdown_yml_msg <- "_pkgdown.yml absent; guard not applicable"

## pkgdown::as_pkgdown() re-parses the package's Rd/NAMESPACE/config surface
## and is this file's dominant cost (~4.4s/call); the 3 tests below all parse
## the same unchanged pkg_root, so compute it once, lazily, after each test's
## own skip guards -- not at file scope, which would run it unconditionally.
.pkgdownConfigCache <- new.env(parent = emptyenv())
getPkgdownConfig <- function() {
  if (is.null(.pkgdownConfigCache$value)) {
    .pkgdownConfigCache$value <- pkgdown::as_pkgdown(pkg_root)
  }
  .pkgdownConfigCache$value
}

test_that("root _pkgdown.yml has a populated reference: block", {
  skip_if_not(file.exists(pkgdown_yml), no_pkgdown_yml_msg)
  skip_if_not_installed("pkgdown")

  pkg <- getPkgdownConfig()
  expect_false(
    is.null(pkg$meta$reference),
    info = paste(
      "root _pkgdown.yml has no reference: key -- pkgdown falls back",
      "to a flat, ungrouped Reference page"
    )
  )
})

test_that("_pkgdown.yml reference: groups cover every current export", {
  skip_if_not(file.exists(pkgdown_yml), no_pkgdown_yml_msg)
  skip_if_not_installed("pkgdown")

  pkg <- getPkgdownConfig()
  grouped <- unique(unlist(lapply(pkg$meta$reference, function(g) {
    gsub("`", "", unlist(g$contents))
  })))
  current_exports <- getNamespaceExports("nprcgenekeepr")
  missing <- setdiff(current_exports, grouped)

  expect_identical(
    missing, character(0),
    info = paste0(
      length(missing), " exported function(s) not covered by any ",
      "_pkgdown.yml reference: group:\n", paste(missing, collapse = ", ")
    )
  )
})

test_that("\"Data objects\" group covers every data/ object", {
  skip_if_not(file.exists(pkgdown_yml), no_pkgdown_yml_msg)
  skip_if_not_installed("pkgdown")

  pkg <- getPkgdownConfig()
  data_group <- Filter(
    function(g) identical(g$title, "Data objects"), pkg$meta$reference
  )
  skip_if(length(data_group) == 0L, "no \"Data objects\" group found")

  grouped_data <- gsub("`", "", unlist(data_group[[1]]$contents))
  current_data <- data(package = "nprcgenekeepr")$results[, "Item"]
  missing <- setdiff(current_data, grouped_data)

  expect_identical(
    missing, character(0),
    info = paste0(
      length(missing), " data object(s) not covered by the ",
      "\"Data objects\" reference: group:\n",
      paste(missing, collapse = ", ")
    )
  )
})

test_that("inst/_pkgdown.yml (shadowed duplicate) no longer exists", {
  expect_false(
    file.exists(file.path(pkg_root, "inst", "_pkgdown.yml")),
    info = paste(
      "inst/_pkgdown.yml is dead configuration (never read by pkgdown",
      "when root _pkgdown.yml exists) and should be deleted, not left",
      "alongside the fixed root config"
    )
  )
})
