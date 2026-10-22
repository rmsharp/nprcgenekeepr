## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Slim inst/doc/ by moving the three html_document vignettes to
## rmarkdown::html_vignette" (owner pick S1035, scope "Light template only").
## a2interactive, gvaConvergence and simulatedKValues declared
## `output: html_document` with `df_print: paged`, which embeds the whole
## Bootstrap + jQuery + pagedtable framework in each built page. Measured S1035
## on clean `git archive HEAD` builds: the source tarball is 3,971,754 B today
## and 3,180,806 B with the three on the light template and `df_print: kable`
## (-0.79 MB); inst/doc/ goes from 4.54 MB to about 2.4 MB.
##
## Two header settings have to travel with the move, both measured S1035:
##  - `df_print: paged` is accepted under html_vignette, but the built page
##    carries the table data without the script that draws it, so a table would
##    not show. `kable` draws plain HTML tables (about 23 in a2interactive).
##  - html_vignette defaults to 3 x 3 inch figures: a2interactive's two plots
##    fell from 1344 x 960 px to 288 x 288 px. fig_width 7 and fig_height 5 keep
##    them a readable size.
## The website is not affected (pkgdown builds each article with its own
## settings and ignores this header).
##
## The pages sit outside a built package, so these blocks skip there and run
## from the source tree (sourceLines(), helper-pageText.R).

light <- "rmarkdown::html_vignette"
guides <- c("a2interactive", "gvaConvergence", "simulatedKValues")

## The YAML front matter of a page, read from its lines: the text between the
## first two "---" lines. list() when the page has no front matter.
frontMatter <- function(lines) {
  fences <- which(trimws(lines) == "---")
  if (length(fences) < 2L) {
    return(list())
  }
  yaml::yaml.load(paste(lines[(fences[1L] + 1L):(fences[2L] - 1L)],
                        collapse = "\n"))
}

## The output formats a page's header declares, in order, as a named list:
## the name is the format, the value its options (list() when the header gives
## none). Three shapes occur in vignettes/: `output: fmt` (a plain value), a
## mapping (`output:` then `fmt:` with or without options) and a list
## (`output:` then `- fmt` lines).
outputFormats <- function(lines) {
  output <- frontMatter(lines)$output
  if (is.character(output) && is.null(names(output))) {
    output <- stats::setNames(vector("list", length(output)), output)
  }
  lapply(output, function(options) if (is.list(options)) options else list())
}

## The first output format of a page: the one R CMD build renders into inst/doc.
firstFormat <- function(lines) names(outputFormats(lines))[1L]

test_that("the header reader handles each shape a vignette header takes", {
  plain <- c("---", "title: x", paste("output:", light), "---", "text")
  expect_identical(names(outputFormats(plain)), light)
  expect_identical(outputFormats(plain)[[light]], list())

  mapping <- c("---", "output:", paste0("  ", light, ":"), "    df_print: kable",
               "    fig_width: 7", "  pdf_document: default", "---")
  expect_identical(names(outputFormats(mapping)), c(light, "pdf_document"))
  expect_identical(outputFormats(mapping)[[light]]$df_print, "kable")
  expect_equal(outputFormats(mapping)[[light]]$fig_width, 7)
  expect_identical(firstFormat(mapping), light)

  sequence <- c("---", "output:", paste("  -", light), "  - rmarkdown::pdf_document",
                "---")
  expect_identical(names(outputFormats(sequence)),
                   c(light, "rmarkdown::pdf_document"))

  expect_identical(outputFormats(c("---", "title: x", "---")), list())
  expect_null(firstFormat(c("no front matter here")))
  expect_identical(frontMatter(c("---", "only one fence")), list())
})

test_that("the three guides ship with the light vignette template", {
  for (guide in guides) {
    lines <- sourceLines("vignettes", paste0(guide, ".Rmd"))
    expect_identical(firstFormat(lines), light, info = guide)
    expect_false("html_document" %in% names(outputFormats(lines)), info = guide)
  }
})

test_that("the three guides print data frames with kable, never paged", {
  for (guide in guides) {
    lines <- sourceLines("vignettes", paste0(guide, ".Rmd"))
    expect_identical(outputFormats(lines)[[light]]$df_print, "kable",
                     info = guide)
  }
})

test_that("a2interactive keeps its plots at 7 x 5 inches and its PDF format", {
  lines <- sourceLines("vignettes", "a2interactive.Rmd")
  options <- outputFormats(lines)[[light]]
  expect_equal(options$fig_width, 7)
  expect_equal(options$fig_height, 5)
  expect_identical(names(outputFormats(lines))[2L], "pdf_document")
})

test_that("every vignette that is built into inst/doc uses the light template", {
  vigDir <- file.path(testthat::test_path("..", ".."), "vignettes")
  skip_if_not(dir.exists(vigDir), "vignettes/ not present")
  pages <- list.files(vigDir, pattern = "^[^_].*[.]Rmd$")
  built <- Filter(function(page) {
    any(grepl("VignetteEngine", readLines(file.path(vigDir, page), warn = FALSE),
              fixed = TRUE))
  }, pages)
  expect_true(all(c(paste0(guides, ".Rmd"), "a3manual.Rmd") %in% built))

  heavy <- Filter(function(page) {
    !identical(firstFormat(readLines(file.path(vigDir, page), warn = FALSE)),
               light)
  }, built)
  expect_identical(heavy, character(0),
                   info = paste("not on the light template:",
                                paste(heavy, collapse = ", ")))
})
