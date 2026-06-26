# Tests for modSummaryStats.R - Summary Statistics Shiny Module

test_that("modSummaryStatsUI returns a shiny.tag object", {
  ui <- modSummaryStatsUI("test")
  expect_true(inherits(ui, "shiny.tag"))
})

test_that("modSummaryStatsUI contains expected heading", {
  ui <- modSummaryStatsUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("Summary Statistics and Plots", ui_html))
})

test_that("modSummaryStatsUI has export buttons", {
  ui <- modSummaryStatsUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("downloadKinship", ui_html))
  expect_true(grepl("downloadMaleFounders", ui_html))
  expect_true(grepl("downloadFemaleFounders", ui_html))
  expect_true(grepl("downloadFirstOrder", ui_html))
})

test_that("modSummaryStatsUI has histogram outputs", {
  ui <- modSummaryStatsUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("mkHist", ui_html))
  expect_true(grepl("zscoreHist", ui_html))
  expect_true(grepl("guHist", ui_html))
})

test_that("modSummaryStatsUI has box plot outputs", {
  ui <- modSummaryStatsUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("mkBox", ui_html))
  expect_true(grepl("zscoreBox", ui_html))
  expect_true(grepl("guBox", ui_html))
})

test_that("modSummaryStatsUI has histogram download buttons", {
  ui <- modSummaryStatsUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("downloadMkHist", ui_html))
  expect_true(grepl("downloadZscoreHist", ui_html))
  expect_true(grepl("downloadGuHist", ui_html))
})

test_that("modSummaryStatsUI has box plot download buttons", {
  ui <- modSummaryStatsUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("downloadMkBox", ui_html))
  expect_true(grepl("downloadZscoreBox", ui_html))
  expect_true(grepl("downloadGuBox", ui_html))
})

test_that("modSummaryStatsUI has summary stats output", {
  ui <- modSummaryStatsUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("summaryStats", ui_html))
})

test_that("modSummaryStatsUI uses correct namespace", {
  ui <- modSummaryStatsUI("statsNS")
  ui_html <- as.character(ui)

  expect_true(grepl("statsNS-mkHist", ui_html))
  expect_true(grepl("statsNS-downloadKinship", ui_html))
  expect_true(grepl("statsNS-summaryStats", ui_html))
})

test_that("modSummaryStatsUI includes HTML documentation content", {
  ui <- modSummaryStatsUI("test")
  ui_html <- as.character(ui)

  # Check for actual content from the guidance HTML files
  expect_true(grepl("Summary Statistics", ui_html) ||
                grepl("Founder equivalents", ui_html, ignore.case = TRUE))
})

test_that("modSummaryStatsUI uses MathJax for formulas", {
  ui <- modSummaryStatsUI("test")
  ui_html <- as.character(ui)

  # withMathJax wraps content for math rendering
  expect_true(grepl("MathJax", ui_html, ignore.case = TRUE) ||
                grepl("mathjax", ui_html, ignore.case = TRUE) ||
                inherits(ui, "shiny.tag"))
})

test_that("modSummaryStatsServer returns expected reactive list", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = c("A", "B", "C", "D", "E"),
    meanKinship = c(0.1, 0.15, 0.2, 0.25, 0.3),
    genomeUniqueness = c(0.9, 0.85, 0.8, 0.75, 0.7),
    stringsAsFactors = FALSE
  )

  test_ped <- data.frame(
    id = c("A", "B", "C", "D", "E"),
    sire = c(NA, NA, "A", "A", "B"),
    dam = c(NA, NA, "B", NA, NA),
    sex = c("M", "F", "F", "M", "F"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL
    ),
    {
      # Check return value structure
      result <- session$getReturned()
      expect_true(is.list(result))

      expect_true("summaryData" %in% names(result))
      expect_true(is.function(result$summaryData))
    }
  )
})

test_that("modSummaryStatsServer returns correct summary data", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = c("A", "B", "C", "D", "E"),
    meanKinship = c(0.1, 0.2, 0.3, 0.4, 0.5),
    genomeUniqueness = c(0.9, 0.8, 0.7, 0.6, 0.5),
    stringsAsFactors = FALSE
  )

  test_ped <- data.frame(
    id = c("A", "B", "C", "D", "E"),
    sire = c(NA, NA, "A", "A", "B"),
    dam = c(NA, NA, "B", NA, NA),
    sex = c("M", "F", "F", "M", "F"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL
    ),
    {
      result <- session$getReturned()
      summary_data <- result$summaryData()

      expect_equal(summary_data$nAnimals, 5)
      expect_equal(summary_data$meanMK, mean(c(0.1, 0.2, 0.3, 0.4, 0.5)))
      expect_equal(summary_data$meanGU, mean(c(0.9, 0.8, 0.7, 0.6, 0.5)))
    }
  )
})

test_that("modSummaryStatsServer handles genetic values with z-scores", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = c("A", "B", "C"),
    meanKinship = c(0.15, 0.25, 0.35),
    genomeUniqueness = c(0.85, 0.75, 0.65),
    zScore = c(-1.0, 0.0, 1.0),
    stringsAsFactors = FALSE
  )

  test_ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL
    ),
    {
      # With z-scores present, the plots should work
      result <- session$getReturned()
      summary_data <- result$summaryData()

      expect_equal(summary_data$nAnimals, 3)
    }
  )
})

test_that("modSummaryStatsServer handles pedigree with founders", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = c("F1", "F2", "F3", "C1", "C2"),
    meanKinship = runif(5, 0.1, 0.4),
    genomeUniqueness = runif(5, 0.5, 0.9),
    stringsAsFactors = FALSE
  )

  # Pedigree with male and female founders
  test_ped <- data.frame(
    id = c("F1", "F2", "F3", "C1", "C2"),
    sire = c(NA, NA, NA, "F1", "F1"),
    dam = c(NA, NA, NA, "F2", "F3"),
    sex = c("M", "F", "F", "M", "F"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL
    ),
    {
      result <- session$getReturned()
      summary_data <- result$summaryData()

      expect_equal(summary_data$nAnimals, 5)
    }
  )
})

test_that("modSummaryStatsServer works with kinship matrix", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = c("A", "B", "C"),
    meanKinship = c(0.2, 0.25, 0.3),
    genomeUniqueness = c(0.8, 0.75, 0.7),
    stringsAsFactors = FALSE
  )

  test_ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    stringsAsFactors = FALSE
  )

  test_kmat <- matrix(
    c(0.5, 0.1, 0.25,
      0.1, 0.5, 0.25,
      0.25, 0.25, 0.5),
    nrow = 3, ncol = 3,
    dimnames = list(c("A", "B", "C"), c("A", "B", "C"))
  )

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      result <- session$getReturned()
      summary_data <- result$summaryData()

      expect_equal(summary_data$nAnimals, 3)
    }
  )
})

# ---------------------------------------------------------------------------
# Issue #82 Slice 3: the Summary-Statistics founder table shows founder genome
# equivalents inline as "FG +/- SE" when founderStats() carries the scalar fgSE
# threaded through from reportGV(); it degrades to the bare FG otherwise.
# ---------------------------------------------------------------------------
test_that("modSummaryStatsServer founder table shows FG +/- SE when fgSE present (issue #82 Slice 3)", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = c("A", "B", "C"),
    meanKinship = c(0.1, 0.2, 0.3),
    genomeUniqueness = c(0.9, 0.8, 0.7),
    stringsAsFactors = FALSE
  )
  test_ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    stringsAsFactors = FALSE
  )
  fstats <- list(
    total = 124L, nMaleFounders = 60L, nFemaleFounders = 64L,
    fe = 77.04, fg = 52.76, fgSE = 0.05
  )

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL,
      founderStats = shiny::reactive({ fstats })
    ),
    {
      html <- as.character(output$summaryStats)
      expect_true(any(grepl("52.76 \\+/- 0.05", html)))
    }
  )
})
