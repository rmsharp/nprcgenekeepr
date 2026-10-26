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
## where CI runs the tests, so the reader is plain R. Each case of the first
## test was run through roxygen2::roc_proc_text(roxygen2::rd_roclet(), ...) in
## S1068, with a source page g(a, b, c) documenting all three; the expected
## answer is whether roxygen printed "@inheritParams failed".

## The values of one roxygen tag in a block (lines without the #' prefix).
roxygenTagValues <- function(block, tag) {
  pattern <- paste0("^\\s*@", tag, "(\\s|$)")
  trimws(sub(pattern, "", grep(pattern, block, value = TRUE)))
}

## The argument names a block's own @param lines name: "@param a,b" names both,
## and \dots is `...`.
roxygenParamNames <- function(block) {
  names <- unlist(strsplit(sub("\\s.*$", "", roxygenTagValues(block, "param")),
                           ",", fixed = TRUE))
  names[names == "\\dots"] <- "..."
  names
}

## TRUE when a top-level expression assigns a function (`f <- function(...)`
## or `f = function(...)`, on one line or two).
isFunctionAssignment <- function(expr) {
  is.call(expr) &&
    (identical(expr[[1L]], as.name("<-")) ||
       identical(expr[[1L]], as.name("="))) &&
    is.call(expr[[3L]]) && identical(expr[[3L]][[1L]], as.name("function"))
}

## The help pages of one R file (its lines), each as whether it has
## @inheritParams, its own @param names and its functions' arguments. A block
## is the #' lines between the previous top-level expression and a function;
## blocks join one page by @rdname, else each function is its own page; an
## @noRd block makes no page. Only blocks above a function are read: every
## @inheritParams in R/ sits above one (64 of 64 blocks, S1068).
inheritParamsPages <- function(lines) {
  exprs <- parse(text = lines, keep.source = TRUE)
  refs <- attr(exprs, "srcref")
  pages <- list()
  previousEnd <- 0L
  for (i in seq_along(exprs)) {
    first <- refs[[i]][[1L]]
    above <- lines[seq_len(first - 1L)]
    above <- above[seq_along(above) > previousEnd]
    previousEnd <- refs[[i]][[3L]]
    block <- sub("^#' ?", "", above[startsWith(above, "#'")])
    expr <- exprs[[i]]
    if (length(block) == 0L || length(roxygenTagValues(block, "noRd")) > 0L ||
          !isFunctionAssignment(expr)) {
      next
    }
    page <- c(sub("\\s.*$", "", roxygenTagValues(block, "rdname")),
              as.character(expr[[2L]]))[[1L]]
    old <- pages[[page]]
    pages[[page]] <- list(
      inherits = isTRUE(old$inherits) ||
        length(roxygenTagValues(block, "inheritParams")) > 0L,
      params = c(old$params, roxygenParamNames(block)),
      arguments = c(old$arguments, names(expr[[3L]][[2L]]))
    )
  }
  pages
}

## The pages of one R file (its lines) whose @inheritParams has nothing to
## inherit: their own @param lines name every argument of their functions.
emptyInheritParams <- function(lines) {
  pages <- Filter(function(page) page$inherits, inheritParamsPages(lines))
  empty <- Filter(function(page) {
    length(setdiff(page$arguments, page$params)) == 0L
  }, pages)
  as.character(names(empty))
}

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
