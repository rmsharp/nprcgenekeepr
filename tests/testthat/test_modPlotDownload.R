# Tests for Plot Download Handler Improvements
# Task #11: Improve plot download handlers

# =============================================================================
# Tests for savePlotToFile helper function
# =============================================================================

test_that("savePlotToFile function exists", {
  expect_true(exists("savePlotToFile"))
})

test_that("savePlotToFile handles PNG format", {
  skip_if_not_installed("ggplot2")
  skip_if_not(exists("savePlotToFile"))

  # Create a simple test plot
  p <- ggplot2::ggplot(data.frame(x = 1:10, y = 1:10),
                        ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_point()

  temp_file <- tempfile(fileext = ".png")
  on.exit(unlink(temp_file), add = TRUE)

  result <- savePlotToFile(p, temp_file, format = "png")

  expect_true(file.exists(temp_file))
  expect_true(file.size(temp_file) > 0)
})

test_that("savePlotToFile handles PDF format", {
  skip_if_not_installed("ggplot2")
  skip_if_not(exists("savePlotToFile"))

  p <- ggplot2::ggplot(data.frame(x = 1:10, y = 1:10),
                        ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_point()

  temp_file <- tempfile(fileext = ".pdf")
  on.exit(unlink(temp_file), add = TRUE)

  result <- savePlotToFile(p, temp_file, format = "pdf")

  expect_true(file.exists(temp_file))
  expect_true(file.size(temp_file) > 0)
})

test_that("savePlotToFile returns TRUE on success", {
  skip_if_not_installed("ggplot2")
  skip_if_not(exists("savePlotToFile"))

  p <- ggplot2::ggplot(data.frame(x = 1:10, y = 1:10),
                        ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_point()

  temp_file <- tempfile(fileext = ".png")
  on.exit(unlink(temp_file), add = TRUE)

  result <- savePlotToFile(p, temp_file)

  expect_true(result)
})

test_that("savePlotToFile returns FALSE on NULL plot", {
  skip_if_not(exists("savePlotToFile"))

  temp_file <- tempfile(fileext = ".png")
  on.exit(unlink(temp_file), add = TRUE)

  result <- savePlotToFile(NULL, temp_file)

  expect_false(result)
})

test_that("savePlotToFile uses high DPI by default", {
  skip_if_not(exists("savePlotToFile"))

  # Check function signature includes dpi parameter
  args <- formals(savePlotToFile)
  expect_true("dpi" %in% names(args))

  # Default should be publication quality (150+)
  expect_true(args$dpi >= 150 || is.null(args$dpi))
})

# =============================================================================
# Tests for download handler error handling
# =============================================================================

test_that("plot download handlers handle missing data gracefully", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  # Check that handlers include error handling
  server_source <- deparse(modSummaryStatsServer)
  server_text <- paste(server_source, collapse = "\n")

  # Download handlers should have some form of null checking
  expect_true(grepl("if.*null|is\\.null|tryCatch", server_text,
                    ignore.case = TRUE))
})

test_that("z-score plot handlers check for missing column", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  # The z-score handlers should check for NULL plot
  server_source <- deparse(modSummaryStatsServer)
  server_text <- paste(server_source, collapse = "\n")

  # Z-score download should check if plot is NULL
  expect_true(grepl("zscoreHistogramPlot.*null|zscoreBoxPlotGG.*null",
                    server_text, ignore.case = TRUE))
})

# =============================================================================
# Tests for modSummaryStats download handlers
# =============================================================================

test_that("modSummaryStatsServer has histogram download handlers", {
  skip_if_not_installed("shiny")

  server_source <- deparse(modSummaryStatsServer)
  server_text <- paste(server_source, collapse = "\n")

  expect_true(grepl("downloadMkHist", server_text))
  expect_true(grepl("downloadZscoreHist", server_text))
  expect_true(grepl("downloadGuHist", server_text))
})

test_that("modSummaryStatsServer has boxplot download handlers", {
  skip_if_not_installed("shiny")

  server_source <- deparse(modSummaryStatsServer)
  server_text <- paste(server_source, collapse = "\n")

  expect_true(grepl("downloadMkBox", server_text))
  expect_true(grepl("downloadZscoreBox", server_text))
  expect_true(grepl("downloadGuBox", server_text))
})

test_that("download handlers use ggplot2::ggsave", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  server_source <- deparse(modSummaryStatsServer)
  server_text <- paste(server_source, collapse = "\n")

  # Should use ggsave for plot export
  expect_true(grepl("ggsave|savePlotToFile", server_text))
})

test_that("download filenames include date", {
  skip_if_not_installed("shiny")

  server_source <- deparse(modSummaryStatsServer)
  server_text <- paste(server_source, collapse = "\n")

  # Filenames should include Sys.Date() for uniqueness
  expect_true(grepl("Sys\\.Date", server_text))
})

# =============================================================================
# Tests for plot quality settings
# =============================================================================

test_that("plot exports use reasonable dimensions", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  server_source <- deparse(modSummaryStatsServer)
  server_text <- paste(server_source, collapse = "\n")

  # Should specify width and height
  expect_true(grepl("width\\s*=", server_text))
  expect_true(grepl("height\\s*=", server_text))
})

test_that("plot exports specify DPI", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  server_source <- deparse(modSummaryStatsServer)
  server_text <- paste(server_source, collapse = "\n")

  # Should specify dpi for quality control
  expect_true(grepl("dpi\\s*=", server_text))
})

# =============================================================================
# Tests for pyramid plot download (modPyramid)
# =============================================================================

test_that("modPyramidServer has pyramid plot download", {
  skip_if_not_installed("shiny")

  expect_true(exists("modPyramidServer"))

  server_source <- deparse(modPyramidServer)
  server_text <- paste(server_source, collapse = "\n")

  # Should have download handler for pyramid plot
  expect_true(grepl("download", server_text, ignore.case = TRUE))
})

# =============================================================================
# Tests for data export handlers
# =============================================================================

test_that("modSummaryStatsServer has CSV export handlers", {
  skip_if_not_installed("shiny")

  server_source <- deparse(modSummaryStatsServer)
  server_text <- paste(server_source, collapse = "\n")

  # Should have CSV exports for kinship matrix and founders
  expect_true(grepl("downloadKinship", server_text))
  expect_true(grepl("downloadMaleFounders", server_text))
  expect_true(grepl("downloadFemaleFounders", server_text))
})

test_that("CSV exports use write.csv", {
  skip_if_not_installed("shiny")

  server_source <- deparse(modSummaryStatsServer)
  server_text <- paste(server_source, collapse = "\n")

  # Should use write.csv for CSV exports
  expect_true(grepl("write\\.csv", server_text))
})
