# Tests for modPyramid.R - issue #111 coverage backfill (slice 5).
#
# The existing test_modPyramid.R exercises the UI, the returned reactives, and
# (via testServer flush cycles) the plot/stats/UI renderers, but never drives
# the downloadPlot handler. That left the download content function body
# (R/modPyramid.R L140, L142-151) uncovered: it only runs when the download is
# invoked. These tests call output$downloadPlot in both plot-height branches so
# the PNG-writing content function runs end to end.

# A minimal age/sex pedigree that getPyramidPlot() renders without warning.
# getPyramidPlot() requires `sex` and `age` columns.
pyramidTestPed <- function() {
  data.frame(
    id = paste0("A", seq_len(12L)),
    sex = rep(c("M", "F"), 6L),
    age = c(0.5, 1.2, 2.5, 3.1, 4.8, 6.0, 7.3, 9.1, 11.0, 12.5, 0.2, 5.5),
    stringsAsFactors = FALSE
  )
}

# TRUE if the first four bytes of `path` are the PNG file signature.
pyramidIsPng <- function(path) {
  sig <- as.raw(c(0x89, 0x50, 0x4E, 0x47))
  identical(readBin(path, what = "raw", n = 4L), sig)
}

test_that("downloadPlot writes a PNG using an explicit plot height", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modPyramidServer,
    args = list(pedigreeData = shiny::reactive(pyramidTestPed())),
    {
      # Non-null branch of `input$plotHeight` in the content function (L140).
      session$setInputs(
        plotHeight = 900L, ageBin = 2L, ageUnit = "years",
        colorScheme = "default", showCounts = TRUE, ageLabelSize = 1.0
      )

      path <- output$downloadPlot

      expect_true(file.exists(path))
      expect_gt(file.size(path), 0)
      expect_true(pyramidIsPng(path))
    }
  )
})

test_that("downloadPlot falls back to the default height when unset", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modPyramidServer,
    args = list(pedigreeData = shiny::reactive(pyramidTestPed())),
    {
      # plotHeight left unset -> `else 600L` branch of L140. The remaining
      # inputs must be set so getPyramidPlot() does not error on NULL.
      session$setInputs(
        ageBin = 2L, ageUnit = "years", colorScheme = "default",
        showCounts = TRUE, ageLabelSize = 1.0
      )

      path <- output$downloadPlot

      expect_true(file.exists(path))
      expect_gt(file.size(path), 0)
      expect_true(pyramidIsPng(path))
    }
  )
})

# Download Plot with nothing loaded (docs-audit part 2 slice 6d, flag CD5).
#
# getPyramidPlot(ped = NULL) draws the packaged example, so with no pedigree
# loaded a click on Download Plot saved a picture of the example (46 animals)
# as if it were the user's colony. The plot, the statistics table and the
# height box on the same tab already stop with req(pedigreeData()); the
# download handler must stop the same way, and must not leave a graphics
# device open when drawing fails.

pyramidDownloadInputs <- list(
  plotHeight = 600L, ageBin = 2L, ageUnit = "years",
  colorScheme = "default", showCounts = TRUE, ageLabelSize = 1.0
)

# Reads output$downloadPlot for a module whose pedigree is the reactive `ped`
# and returns what the handler did: `path`, the saved file (NULL when it
# stopped) and `isPng`, whether that file was a PNG (checked inside the
# session, which deletes its files when it ends); `stopped`, the condition it
# stopped with (NULL when it saved a file); and `leaked`, the graphics devices
# the call left open. Leaked devices are closed here so one failing block
# cannot disturb the next.
pyramidDownload <- function(ped) {
  rec <- new.env()
  before <- as.integer(grDevices::dev.list())
  shiny::testServer(
    modPyramidServer,
    args = list(pedigreeData = ped),
    {
      do.call(session$setInputs, pyramidDownloadInputs)
      result <- tryCatch(output$downloadPlot, error = function(e) e)
      if (inherits(result, "condition")) {
        rec$stopped <- result
      } else {
        rec$path <- result
        rec$isPng <- file.exists(result) && pyramidIsPng(result)
      }
    }
  )
  leaked <- setdiff(as.integer(grDevices::dev.list()), before)
  for (device in leaked) grDevices::dev.off(device)
  list(path = rec$path, isPng = rec$isPng, stopped = rec$stopped,
       leaked = leaked)
}

test_that("downloadPlot saves no picture when no pedigree is loaded", {
  skip_if_not_installed("shiny")

  res <- pyramidDownload(shiny::reactive(NULL))

  expect_s3_class(res$stopped, "shiny.silent.error")
  expect_null(res$path)
})

test_that("downloadPlot still saves a PNG and leaves no device when a pedigree is loaded", {
  skip_if_not_installed("shiny")

  res <- pyramidDownload(shiny::reactive(pyramidTestPed()))

  expect_null(res$stopped)
  expect_true(res$isPng)
  expect_length(res$leaked, 0L)
})

test_that("downloadPlot stops while the module is empty and saves once a pedigree arrives", {
  skip_if_not_installed("shiny")

  ped <- shiny::reactiveVal(NULL)
  rec <- new.env()
  shiny::testServer(
    modPyramidServer,
    args = list(pedigreeData = ped),
    {
      do.call(session$setInputs, pyramidDownloadInputs)
      rec$empty <- tryCatch(output$downloadPlot, error = function(e) e)
      ped(pyramidTestPed())
      session$flushReact()
      loaded <- tryCatch(output$downloadPlot, error = function(e) e)
      rec$loadedIsPng <- is.character(loaded) && pyramidIsPng(loaded)
    }
  )

  expect_s3_class(rec$empty, "shiny.silent.error")
  expect_true(rec$loadedIsPng)
})

test_that("downloadPlot leaves no graphics device open when drawing fails", {
  skip_if_not_installed("shiny")

  testthat::local_mocked_bindings(
    getPyramidPlot = function(...) stop("drawing failed")
  )
  res <- pyramidDownload(shiny::reactive(pyramidTestPed()))

  expect_s3_class(res$stopped, "error")
  expect_match(conditionMessage(res$stopped), "drawing failed", fixed = TRUE)
  expect_length(res$leaked, 0L)
})
