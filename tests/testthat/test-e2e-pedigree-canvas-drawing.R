## S1076 -- the Diagram's pixel tests run twice, once in the default Chrome
## and once in a Chrome that draws its canvas on the CPU (owner ruling S1067;
## owner pick S1076, "Pixel tests, every run"; see
## test_pixelTestsBothDrawings.R). local_cpu_canvas_chrome()
## (helper-shinytest2.R) is how the second run gets its Chrome; the first
## three tests check that helper on its own, the last that pixel_test_that()
## runs its second test under it. Chrome itself says how it draws a canvas:
## its SystemInfo "2d_canvas" status reads "enabled" for the GPU (this Mac's
## default) and "disabled_software" with --disable-accelerated-2d-canvas.

test_that(
  "an app started under local_cpu_canvas_chrome() runs in a Chrome that draws
   its canvas on the CPU", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  local_cpu_canvas_chrome()
  ## The app is stopped when local() ends, before the Chrome it runs in is
  ## closed at the end of the test.
  local({
    app <- create_app_driver(app_dir, "e2e_canvas_drawing_cpu")
    on.exit(app$stop(), add = TRUE)
    expect_identical(
      chrome_canvas_drawing(app$get_chromote_session()$parent), "CPU"
    )
  })
})

test_that(
  "when the code that called local_cpu_canvas_chrome() ends, the default
   Chrome is the one from before and still running, and the CPU one is
   closed", {
  skip_if_not_installed("chromote")
  skip_on_cran()
  create_test_app()

  before <- chromote::default_chromote_object()
  cpu <- local({
    local_cpu_canvas_chrome()
    chromote::default_chromote_object()
  })
  expect_false(identical(cpu, before))
  expect_identical(chromote::default_chromote_object(), before)
  expect_true(before$is_alive())
  expect_false(cpu$is_alive())
})

test_that(
  "local_cpu_canvas_chrome() stops with an error, and leaves the default
   Chrome in place, when the Chrome it starts still draws on the GPU", {
  skip_if_not_installed("chromote")
  skip_on_cran()
  create_test_app()
  skip_if(chrome_canvas_drawing() == "CPU",
          paste("The default Chrome draws its canvas on the CPU here, so no",
                "Chrome on this machine draws on the GPU"))

  before <- chromote::default_chromote_object()
  expect_error(
    local(local_cpu_canvas_chrome(args = chromote::default_chrome_args())),
    "GPU"
  )
  expect_identical(chromote::default_chromote_object(), before)
})

## S1076 mutation gaps: a CPU-drawing test that never switched Chrome, and a
## drawing check stuck on "CPU" (which skips every CPU-drawing test), passed
## every test above. This one reads Chrome's own 2d_canvas status, not
## chrome_canvas_drawing(), inside each of the two tests pixel_test_that()
## declares.

test_that(
  "where the default Chrome draws on the GPU, pixel_test_that() runs its first
   test in that Chrome and its second in one that draws on the CPU", {
  skip_if_not_installed("chromote")
  skip_on_cran()
  create_test_app()
  canvas_status <- function() {
    chromote::default_chromote_object()$SystemInfo$getInfo()$gpu$featureStatus[[
      "2d_canvas"]]
  }
  skip_if(!identical(canvas_status(), "enabled"),
          "The default Chrome draws its canvas on the CPU here")

  seen <- character()
  declared <- run_declared(pixel_test_that("a pixel test", {
    seen <<- c(seen, canvas_status())
    testthat::succeed()
  }))
  expect_identical(declared$skipped, c(FALSE, FALSE))
  expect_identical(seen, c("enabled", "disabled_software"))
})
