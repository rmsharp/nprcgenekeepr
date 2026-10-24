## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' E2E Test for the performance and memory campaign's Phase 3, the
#' relationship table (owner pick S1055; plan docs/planning/performance-
#' memory-campaign-plan.md, Phase 3, "DONE when ... both downloads finish on
#' the example in the app"). Summary Statistics' "Download relationships" and
#' "Download relationship classes" both build convertRelationships()'s table
#' of every pair of the current pedigree: 6,824,665 pairs for
#' ExamplePedigree.csv (3,694 animals), which never finished before Phase 3
#' (today's code took 66 s on the first 600 animals alone; S1055).
#'
#' shinytest2's get_download() waits for a download with no time limit, so
#' each download is fetched here from its link with a limit of 120 s, and a
#' download that does not finish in time fails the test instead of hanging it.
#' The class counts are today's rules' counts for the example: a scratch run
#' of today's code, with only its result preallocated, gave them for all
#' 6,824,665 pairs (S1055).
library(testthat)

## Fetch a download from its link, waiting at most `seconds`. Returns the
## file's path, or NULL with a failed expectation tagged `what`.
fetchDownloadWithin <- function(app, outputId, seconds, what) {
  href <- tryCatch(
    app$get_js(sprintf("$('#%s').attr('href')", outputId)),
    error = function(e) NA_character_
  )
  hasLink <- is.character(href) && length(href) == 1L && !is.na(href) &&
    nzchar(href)
  expect_true(hasLink, info = paste("download link present:", what))
  if (!hasLink) {
    return(NULL)
  }
  url <- paste0(sub("/+$", "", app$get_url()), "/", sub("^/+", "", href))
  path <- tempfile(fileext = ".csv")
  withr::local_options(timeout = seconds)
  started <- proc.time()[["elapsed"]]
  status <- tryCatch(
    utils::download.file(url, path, mode = "wb", quiet = TRUE),
    error = function(e) conditionMessage(e),
    warning = function(w) conditionMessage(w)
  )
  elapsed <- proc.time()[["elapsed"]] - started
  finished <- identical(status, 0L) && file.exists(path)
  expect_true(finished, info = sprintf(
    "download finishes within %d s: %s (%.0f s; %s)", seconds, what,
    elapsed, toString(status)
  ))
  if (!finished) {
    return(NULL)
  }
  path
}

## The number of lines in a file, counted in blocks of bytes: the
## relationships file is about 223 MB.
countFileLines <- function(path) {
  con <- file(path, "rb")
  on.exit(close(con), add = TRUE)
  lines <- 0
  repeat {
    block <- readBin(con, "raw", 16777216L)
    if (length(block) == 0L) {
      break
    }
    lines <- lines + sum(block == as.raw(10L))
  }
  lines
}

test_that(
  "E2E: both relationship downloads finish on the example pedigree, with
   every pair and today's class counts", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ss_relationship_downloads")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "examples", "ExamplePedigree.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture, timeout = 120000)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Summary Statistics")
  if (!success) skip("Could not navigate to Summary Statistics tab")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  relationships <- fetchDownloadWithin(
    app, "summaryStats-downloadRelationships", 120L, "relationships"
  )
  if (is.null(relationships)) {
    return(invisible())
  }
  header <- readLines(relationships, n = 1L)
  expect_identical(header, '"id1","id2","kinship","relation"')
  ## a header and one line per pair: 3,694 x 3,695 / 2 pairs
  expect_identical(countFileLines(relationships), 1 + 6824665)

  classes <- fetchDownloadWithin(
    app, "summaryStats-downloadRelationClasses", 120L, "relationship classes"
  )
  if (is.null(classes)) {
    return(invisible())
  }
  counts <- utils::read.csv(classes, check.names = FALSE,
                            stringsAsFactors = FALSE)
  expect_identical(names(counts), c("Relationship Class", "Frequency"))
  expect_identical(counts[["Relationship Class"]], c(
    "Parent-Offspring", "Full-Siblings", "Half-Siblings",
    "Grandparent-Grandchild", "Full-Cousins", "Cousin - Other",
    "Full-Avuncular", "Avuncular - Other", "Other", "No Relation"
  ))
  expect_identical(counts[["Frequency"]], c(
    4052L, 68L, 9166L, 4875L, 603L, 25773L, 258L, 24948L, 426573L, 6324655L
  ))
  ## every pair but the 3,694 Self pairs
  expect_identical(sum(counts[["Frequency"]]), 6824665L - 3694L)

  logs <- app$get_logs()
  errors <- logs[logs$level == "throw", ]
  expect_equal(nrow(errors), 0L, info = "No console errors")
})
