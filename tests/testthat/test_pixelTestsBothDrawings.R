## S1076 -- the Diagram's pixel tests run with both GPU and CPU drawing (owner
## ruling S1067: local runs test with both; owner pick S1076, "Pixel tests,
## every run"). Headless Chrome paints the Diagram's canvas on the GPU on this
## Mac and on the CPU on CI, and a pixel check that passed here failed there for
## five days (S1067, run 40286217416). pixel_test_that() (helper-shinytest2.R)
## declares a browser test twice: as written, in the default Chrome, and again
## in a Chrome started with --disable-accelerated-2d-canvas. These tests start
## no browser: the first two read the browser-test files, the others run
## pixel_test_that() under their own reporter where it starts no Chrome.

## The top-level calls of `file` and the line each starts on.
top_level_calls <- function(file) {
  exprs <- parse(file, keep.source = TRUE)
  list(
    exprs = as.list(exprs),
    lines = vapply(attr(exprs, "srcref"), function(s) s[[1L]], integer(1L))
  )
}

## The name of the function `call` calls ("" when it is not a plain call).
called_name <- function(call) {
  if (is.call(call) && is.name(call[[1L]])) as.character(call[[1L]]) else ""
}

## Whether `call` reads the Diagram's canvas pixels: it calls
## diagram_pixel_js() or names the canvas's getImageData().
reads_pixels <- function(call) {
  "diagram_pixel_js" %in% all.names(call) ||
    any(grepl("getImageData", deparse(call), fixed = TRUE))
}

test_that(
  "every browser test that reads the Diagram's canvas pixels is declared with
   pixel_test_that(), so it also runs with CPU drawing", {
  e2eFiles <- list.files(testthat::test_path(), pattern = "^test-e2e-.*[.]R$",
                         full.names = TRUE)
  expect_gt(length(e2eFiles), 0L)

  plain <- character()
  for (file in e2eFiles) {
    calls <- top_level_calls(file)
    for (i in seq_along(calls$exprs)) {
      call <- calls$exprs[[i]]
      if (called_name(call) == "test_that" && reads_pixels(call)) {
        plain <- c(plain, sprintf("%s:%d", basename(file), calls$lines[[i]]))
      }
    }
  }
  expect_identical(plain, character(),
                   info = "test_that() blocks that read pixels (file:line)")
})

## Without this, renaming diagram_pixel_js() would leave the test above
## finding no pixel test at all and passing.
test_that(
  "the pedigree module's four pixel tests (the deceased slash, the section
   colors, the section edges and the saved page) are declared with
   pixel_test_that()", {
  calls <- top_level_calls(testthat::test_path("test-e2e-pedigree-module.R"))
  declared <- vapply(calls$exprs, function(call) {
    called_name(call) == "pixel_test_that" && reads_pixels(call)
  }, logical(1L))
  expect_gte(sum(declared), 4L)
})

test_that(
  "pixel_test_that() declares a default-drawing test and a CPU-drawing test,
   and without NPRC_RUN_E2E the CPU-drawing test skips before it starts a
   Chrome", {
  skip_if_not_installed("chromote")
  withr::local_envvar(NPRC_RUN_E2E = NA, NOT_CRAN = "true")
  ## A test file that ran earlier in this R session may have started the
  ## default Chrome; what matters is that these tests start none.
  chromeBefore <- chromote::has_default_chromote_object()

  declared <- run_declared(pixel_test_that("a pixel test", expect_true(TRUE)))
  expect_identical(declared$test, c("a pixel test [default drawing]",
                                    "a pixel test [CPU drawing]"))
  expect_identical(declared$skipped, c(FALSE, TRUE))
  expect_match(declared$message[[2L]], "opt-in", fixed = TRUE)
  expect_identical(chromote::has_default_chromote_object(), chromeBefore)
})

test_that(
  "where the default Chrome already draws its canvas on the CPU, as on CI,
   pixel_test_that()'s CPU-drawing test skips and says the first run covered
   it", {
  skip_if_not_installed("chromote")
  withr::local_envvar(NPRC_RUN_E2E = "true", NOT_CRAN = "true")
  chromeBefore <- chromote::has_default_chromote_object()

  ## `drawing` stands in for chrome_canvas_drawing(), so no Chrome is asked.
  declared <- run_declared(pixel_test_that(
    "a pixel test", expect_true(TRUE),
    drawing = function(chromote) "CPU"
  ))
  expect_identical(declared$test, c("a pixel test [default drawing]",
                                    "a pixel test [CPU drawing]"))
  expect_identical(declared$skipped, c(FALSE, TRUE))
  expect_match(declared$message[[2L]], "already draws", fixed = TRUE)
  expect_identical(chromote::has_default_chromote_object(), chromeBefore)
})
