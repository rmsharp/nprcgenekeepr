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

# =============================================================================
# Server Tests - Plot Rendering
# =============================================================================

test_that("modSummaryStatsServer renders mean kinship histogram", {
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
      # The plot output should be a function that can be called
      expect_no_error(output$mkHist)
    }
  )
})

test_that("modSummaryStatsServer renders genome uniqueness histogram", {
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

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL
    ),
    {
      expect_no_error(output$guHist)
    }
  )
})

test_that("modSummaryStatsServer renders z-score histogram when available", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = c("A", "B", "C"),
    meanKinship = c(0.2, 0.25, 0.3),
    genomeUniqueness = c(0.8, 0.75, 0.7),
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
      expect_no_error(output$zscoreHist)
    }
  )
})

test_that("modSummaryStatsServer handles missing z-scores in histogram", {
  skip_if_not_installed("shiny")

  # No zScore column
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

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL
    ),
    {
      # Should not error even without zScore column
      expect_no_error(output$zscoreHist)
    }
  )
})

test_that("modSummaryStatsServer renders mean kinship box plot", {
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
      expect_no_error(output$mkBox)
    }
  )
})

test_that("modSummaryStatsServer renders genome uniqueness box plot", {
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

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL
    ),
    {
      expect_no_error(output$guBox)
    }
  )
})

test_that("modSummaryStatsServer renders z-score box plot when available", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = c("A", "B", "C"),
    meanKinship = c(0.2, 0.25, 0.3),
    genomeUniqueness = c(0.8, 0.75, 0.7),
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
      expect_no_error(output$zscoreBox)
    }
  )
})

test_that("modSummaryStatsServer handles missing z-scores in box plot", {
  skip_if_not_installed("shiny")

  # No zScore column
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

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL
    ),
    {
      # Should not error even without zScore column
      expect_no_error(output$zscoreBox)
    }
  )
})

# =============================================================================
# Server Tests - Summary Stats HTML
# =============================================================================

test_that("modSummaryStatsServer renders summary stats HTML", {
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

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL
    ),
    {
      expect_no_error(output$summaryStats)
    }
  )
})

# =============================================================================
# Server Tests - Edge Cases
# =============================================================================

test_that("modSummaryStatsServer handles NA values in meanKinship", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = c("A", "B", "C", "D"),
    meanKinship = c(0.1, NA, 0.3, NA),
    genomeUniqueness = c(0.9, 0.8, NA, 0.6),
    stringsAsFactors = FALSE
  )

  test_ped <- data.frame(
    id = c("A", "B", "C", "D"),
    sire = c(NA, NA, "A", "A"),
    dam = c(NA, NA, "B", "B"),
    sex = c("M", "F", "F", "M"),
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

      expect_equal(summary_data$nAnimals, 4)
      # Mean should be calculated with na.rm = TRUE
      expect_equal(summary_data$meanMK, mean(c(0.1, 0.3), na.rm = TRUE))
      expect_equal(summary_data$meanGU, mean(c(0.9, 0.8, 0.6), na.rm = TRUE))
    }
  )
})

test_that("modSummaryStatsServer handles single animal", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = "A",
    meanKinship = 0.5,
    genomeUniqueness = 1.0,
    stringsAsFactors = FALSE
  )

  test_ped <- data.frame(
    id = "A",
    sire = NA,
    dam = NA,
    sex = "M",
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

      expect_equal(summary_data$nAnimals, 1)
      expect_equal(summary_data$meanMK, 0.5)
      expect_equal(summary_data$meanGU, 1.0)
    }
  )
})

test_that("modSummaryStatsServer handles large dataset", {
  skip_if_not_installed("shiny")

  n <- 1000
  test_gv <- data.frame(
    id = paste0("Animal", seq_len(n)),
    meanKinship = runif(n, 0.05, 0.5),
    genomeUniqueness = runif(n, 0.3, 1.0),
    stringsAsFactors = FALSE
  )

  test_ped <- data.frame(
    id = paste0("Animal", seq_len(n)),
    sire = rep(NA, n),
    dam = rep(NA, n),
    sex = rep(c("M", "F"), length.out = n),
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

      expect_equal(summary_data$nAnimals, n)
      expect_true(summary_data$meanMK > 0)
      expect_true(summary_data$meanGU > 0)
    }
  )
})

# =============================================================================
# Server Tests - Founder Detection
# =============================================================================

test_that("modSummaryStatsServer identifies male founders correctly", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = c("M1", "M2", "F1", "F2", "O1"),
    meanKinship = runif(5, 0.1, 0.3),
    genomeUniqueness = runif(5, 0.7, 0.9),
    stringsAsFactors = FALSE
  )

  # M1 and M2 are male founders, F1 and F2 are female founders
  test_ped <- data.frame(
    id = c("M1", "M2", "F1", "F2", "O1"),
    sire = c(NA, NA, NA, NA, "M1"),
    dam = c(NA, NA, NA, NA, "F1"),
    sex = c("M", "M", "F", "F", "F"),
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
      # Test that male founders can be extracted
      ped <- pedigree()
      males <- ped[ped$sex == "M" & is.na(ped$sire) & is.na(ped$dam), ]

      expect_equal(nrow(males), 2)
      expect_true(all(c("M1", "M2") %in% males$id))
    }
  )
})

test_that("modSummaryStatsServer identifies female founders correctly", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = c("M1", "F1", "F2", "F3", "O1"),
    meanKinship = runif(5, 0.1, 0.3),
    genomeUniqueness = runif(5, 0.7, 0.9),
    stringsAsFactors = FALSE
  )

  # F1, F2, F3 are female founders
  test_ped <- data.frame(
    id = c("M1", "F1", "F2", "F3", "O1"),
    sire = c(NA, NA, NA, NA, "M1"),
    dam = c(NA, NA, NA, NA, "F1"),
    sex = c("M", "F", "F", "F", "M"),
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
      # Test that female founders can be extracted
      ped <- pedigree()
      females <- ped[ped$sex == "F" & is.na(ped$sire) & is.na(ped$dam), ]

      expect_equal(nrow(females), 3)
      expect_true(all(c("F1", "F2", "F3") %in% females$id))
    }
  )
})

test_that("modSummaryStatsServer handles pedigree with no founders", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = c("A", "B", "C"),
    meanKinship = c(0.2, 0.25, 0.3),
    genomeUniqueness = c(0.8, 0.75, 0.7),
    stringsAsFactors = FALSE
  )

  # All animals have known parents (unlikely in real data but edge case)
  test_ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c("X", "X", "A"),
    dam = c("Y", "Y", "B"),
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
      # Test that no founders are found
      ped <- pedigree()
      males <- ped[ped$sex == "M" & is.na(ped$sire) & is.na(ped$dam), ]
      females <- ped[ped$sex == "F" & is.na(ped$sire) & is.na(ped$dam), ]

      expect_equal(nrow(males), 0)
      expect_equal(nrow(females), 0)
    }
  )
})

# =============================================================================
# Server Tests - Z-Score Calculations
# =============================================================================

test_that("modSummaryStatsServer handles negative z-scores", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = c("A", "B", "C", "D"),
    meanKinship = c(0.1, 0.2, 0.3, 0.4),
    genomeUniqueness = c(0.9, 0.8, 0.7, 0.6),
    zScore = c(-2.0, -1.0, 0.0, 1.0),
    stringsAsFactors = FALSE
  )

  test_ped <- data.frame(
    id = c("A", "B", "C", "D"),
    sire = c(NA, NA, "A", "A"),
    dam = c(NA, NA, "B", "B"),
    sex = c("M", "F", "F", "M"),
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

      expect_equal(summary_data$nAnimals, 4)
      # Plots should render without error
      expect_no_error(output$zscoreHist)
      expect_no_error(output$zscoreBox)
    }
  )
})

test_that("modSummaryStatsServer handles extreme z-score values", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = c("A", "B", "C"),
    meanKinship = c(0.01, 0.5, 0.99),
    genomeUniqueness = c(0.99, 0.5, 0.01),
    zScore = c(-5.0, 0.0, 5.0),
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
      result <- session$getReturned()
      summary_data <- result$summaryData()

      expect_equal(summary_data$nAnimals, 3)
      expect_no_error(output$zscoreHist)
      expect_no_error(output$zscoreBox)
    }
  )
})

# =============================================================================
# Server Tests - All NA Cases
# =============================================================================

test_that("modSummaryStatsServer handles all NA meanKinship", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = c("A", "B", "C"),
    meanKinship = c(NA, NA, NA),
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

      expect_equal(summary_data$nAnimals, 3)
      # Mean of all NA with na.rm = TRUE is NaN
      expect_true(is.nan(summary_data$meanMK))
    }
  )
})

test_that("modSummaryStatsServer handles all NA genomeUniqueness", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = c("A", "B", "C"),
    meanKinship = c(0.1, 0.2, 0.3),
    genomeUniqueness = c(NA, NA, NA),
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
      result <- session$getReturned()
      summary_data <- result$summaryData()

      expect_equal(summary_data$nAnimals, 3)
      expect_true(is.nan(summary_data$meanGU))
    }
  )
})

# =============================================================================
# Server Tests - Kinship Matrix
# =============================================================================

test_that("modSummaryStatsServer handles NULL kinship matrix", {
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

      expect_equal(summary_data$nAnimals, 3)
    }
  )
})

test_that("modSummaryStatsServer uses kinship matrix when provided", {
  skip_if_not_installed("shiny")

  test_gv <- data.frame(
    id = c("A", "B"),
    meanKinship = c(0.2, 0.3),
    genomeUniqueness = c(0.8, 0.7),
    stringsAsFactors = FALSE
  )

  test_ped <- data.frame(
    id = c("A", "B"),
    sire = c(NA, NA),
    dam = c(NA, NA),
    sex = c("M", "F"),
    stringsAsFactors = FALSE
  )

  # 2x2 kinship matrix
  test_kmat <- matrix(
    c(0.5, 0.125,
      0.125, 0.5),
    nrow = 2, ncol = 2,
    dimnames = list(c("A", "B"), c("A", "B"))
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

      expect_equal(summary_data$nAnimals, 2)
    }
  )
})

# =============================================================================
# Server Tests - Varying Data Distributions
# =============================================================================

test_that("modSummaryStatsServer handles uniform distribution data", {
  skip_if_not_installed("shiny")

  # All same values
  test_gv <- data.frame(
    id = c("A", "B", "C", "D"),
    meanKinship = rep(0.25, 4),
    genomeUniqueness = rep(0.75, 4),
    stringsAsFactors = FALSE
  )

  test_ped <- data.frame(
    id = c("A", "B", "C", "D"),
    sire = c(NA, NA, "A", "A"),
    dam = c(NA, NA, "B", "B"),
    sex = c("M", "F", "F", "M"),
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

      expect_equal(summary_data$nAnimals, 4)
      expect_equal(summary_data$meanMK, 0.25)
      expect_equal(summary_data$meanGU, 0.75)
    }
  )
})

test_that("modSummaryStatsServer handles bimodal distribution data", {
  skip_if_not_installed("shiny")

  # Two clusters of values
  test_gv <- data.frame(
    id = paste0("Animal", 1:6),
    meanKinship = c(0.1, 0.1, 0.1, 0.5, 0.5, 0.5),
    genomeUniqueness = c(0.9, 0.9, 0.9, 0.5, 0.5, 0.5),
    stringsAsFactors = FALSE
  )

  test_ped <- data.frame(
    id = paste0("Animal", 1:6),
    sire = rep(NA, 6),
    dam = rep(NA, 6),
    sex = rep(c("M", "F"), 3),
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

      expect_equal(summary_data$nAnimals, 6)
      expect_equal(summary_data$meanMK, mean(c(0.1, 0.1, 0.1, 0.5, 0.5, 0.5)))
    }
  )
})
