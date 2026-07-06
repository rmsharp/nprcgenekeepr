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
