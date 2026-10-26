## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md ("Two @inheritParams lines with nothing to inherit", owner-
## reported S1060, picked S1068): RStudio's Build -> Document (roxygen2 8.0.0)
## printed "In topic 'addParents': @inheritParams failed. All parameters are
## already documented; none remain to be inherited." and the same for
## 'removeUninformativeFounders': each function takes only `ped`, which its own
## @param documents. roxygen2 8.0.0 warns when a help page has @inheritParams
## and its own @param lines already name every argument of its functions.
##
## These tests read the roxygen blocks of R/ the way roxygen2 8.0.0 does and
## fail on any such page (the owner chose a check of every help page over one
## of the two functions, S1068). roxygen2 is a dev-only package, not installed
## where CI runs the tests, so the reader (helper-roxygenBlocks.R) is plain R.
## Each case of the first test was run through
## roxygen2::roc_proc_text(roxygen2::rd_roclet(), ...) in S1068, with a source
## page g(a, b, c) documenting all three; the expected answer is whether
## roxygen printed "@inheritParams failed".

test_that("the reader flags the pages roxygen2 8.0.0 warns about", {
  inherit <- c("#' F", "#' @inheritParams g")
  cases <- list(
    "every argument named" = list(
      TRUE, c(inherit, "#' @param a x", "#' @param b y",
              "f <- function(a, b) NULL")),
    "one argument left to inherit" = list(
      FALSE, c(inherit, "#' @param a x", "f <- function(a, b) NULL")),
    "a comma list names both" = list(
      TRUE, c(inherit, "#' @param a,b x", "f <- function(a, b) NULL")),
    "\\dots names ..." = list(
      TRUE, c(inherit, "#' @param a x", "#' @param \\dots y",
              "f <- function(a, ...) NULL")),
    "@noRd makes no page" = list(
      FALSE, c(inherit, "#' @param a x", "#' @noRd", "f <- function(a) NULL")),
    "@rdname page with an argument left to inherit" = list(
      FALSE, c(inherit, "#' @param a x", "#' @rdname f",
               "f <- function(a) NULL", "#' @rdname f",
               "h <- function(a, b) NULL")),
    "@rdname page with every argument named" = list(
      TRUE, c(inherit, "#' @param a x", "f <- function(a) NULL",
              "#' @rdname f", "#' @param b y", "h <- function(a, b) NULL")),
    "assignment over two lines" = list(
      TRUE, c(inherit, "#' @param a x", "f <-", "  function(a) NULL")),
    "assignment with =" = list(
      TRUE, c(inherit, "#' @param a x", "f = function(a) NULL")),
    "a function with no arguments" = list(
      TRUE, c(inherit, "f <- function() NULL")),
    "no @inheritParams" = list(
      FALSE, c("#' F", "#' @param a x", "f <- function(a) NULL"))
  )
  for (case in names(cases)) {
    expected <- if (cases[[case]][[1L]]) "f" else character(0L)
    expect_identical(emptyInheritParams(cases[[case]][[2L]]), expected,
                     info = case)
  }
})

test_that("no help page in R/ has an @inheritParams with nothing to inherit", {
  rDir <- testthat::test_path("..", "..", "R")
  skip_if_not(dir.exists(rDir), "R/ not available (installed package)")
  files <- list.files(rDir, pattern = "[.]R$", full.names = TRUE)
  found <- lapply(files, function(file) {
    lines <- readLines(file, warn = FALSE)
    empty <- emptyInheritParams(lines)
    list(
      pages = sum(vapply(inheritParamsPages(lines), `[[`, logical(1L),
                         "inherits")),
      empty = if (length(empty) > 0L) {
        paste0(empty, " (R/", basename(file), ")")
      } else {
        character(0L)
      }
    )
  })
  ## The scan reads the package's pages with @inheritParams (36, S1068), so an
  ## empty result is not a scan that found nothing to read.
  expect_gte(sum(vapply(found, `[[`, integer(1L), "pages")), 30L)
  empty <- unlist(lapply(found, `[[`, "empty"))
  expect_identical(empty, character(0L),
                   info = paste("Nothing to inherit:",
                                paste(empty, collapse = ", ")))
})
