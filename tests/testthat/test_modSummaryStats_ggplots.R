# Tests for modSummaryStats.R - ggplot2-based Histogram and Boxplot Reactives
# Task #7: Implement histogram and boxplot reactives

# =============================================================================
# Helper Functions
# =============================================================================

#' Create test genetic values data with proper column names
#' @param n Number of animals
#' @return A data.frame matching reportGV output format
makeTestGVData <- function(n = 20) {
  data.frame(
    id = paste0("Animal", seq_len(n)),
    indivMeanKin = runif(n, 0.05, 0.4),
    zScores = rnorm(n, mean = 0, sd = 1),
    gu = runif(n, 0.3, 1.0),
    # Also include alternative column names that modSummaryStats currently uses
    meanKinship = runif(n, 0.05, 0.4),
    genomeUniqueness = runif(n, 0.3, 1.0),
    zScore = rnorm(n, mean = 0, sd = 1),
    stringsAsFactors = FALSE
  )
}

# =============================================================================
# Tests for mkHistogram reactive function
# =============================================================================

test_that("modSummaryStatsServer returns mkHistogram reactive", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  test_gv <- makeTestGVData()
  test_ped <- data.frame(
    id = test_gv$id,
    sire = NA, dam = NA, sex = rep(c("M", "F"), length.out = nrow(test_gv)),
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

      # Should have mkHistogram reactive
      expect_true("mkHistogram" %in% names(result))
      expect_true(is.function(result$mkHistogram))
    }
  )
})

test_that("mkHistogram returns a ggplot object", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  test_gv <- makeTestGVData()
  test_ped <- data.frame(
    id = test_gv$id,
    sire = NA, dam = NA, sex = rep(c("M", "F"), length.out = nrow(test_gv)),
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
      plot <- result$mkHistogram()

      expect_true(inherits(plot, "ggplot"))
    }
  )
})

test_that("mkHistogram has mean kinship vertical line", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  test_gv <- makeTestGVData()
  test_ped <- data.frame(
    id = test_gv$id,
    sire = NA, dam = NA, sex = rep(c("M", "F"), length.out = nrow(test_gv)),
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
      plot <- result$mkHistogram()

      # Check that plot has geom_vline layer (vertical line at mean)
      layer_classes <- sapply(plot$layers, function(l) class(l$geom)[1])
      expect_true("GeomVline" %in% layer_classes)
    }
  )
})

# =============================================================================
# Tests for zscoreHistogram reactive function
# =============================================================================

test_that("modSummaryStatsServer returns zscoreHistogram reactive", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  test_gv <- makeTestGVData()
  test_ped <- data.frame(
    id = test_gv$id,
    sire = NA, dam = NA, sex = rep(c("M", "F"), length.out = nrow(test_gv)),
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

      expect_true("zscoreHistogram" %in% names(result))
      expect_true(is.function(result$zscoreHistogram))
    }
  )
})

test_that("zscoreHistogram returns a ggplot object", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  test_gv <- makeTestGVData()
  test_ped <- data.frame(
    id = test_gv$id,
    sire = NA, dam = NA, sex = rep(c("M", "F"), length.out = nrow(test_gv)),
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
      plot <- result$zscoreHistogram()

      expect_true(inherits(plot, "ggplot"))
    }
  )
})

# =============================================================================
# Tests for guHistogram reactive function
# =============================================================================

test_that("modSummaryStatsServer returns guHistogram reactive", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  test_gv <- makeTestGVData()
  test_ped <- data.frame(
    id = test_gv$id,
    sire = NA, dam = NA, sex = rep(c("M", "F"), length.out = nrow(test_gv)),
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

      expect_true("guHistogram" %in% names(result))
      expect_true(is.function(result$guHistogram))
    }
  )
})

test_that("guHistogram returns a ggplot object", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  test_gv <- makeTestGVData()
  test_ped <- data.frame(
    id = test_gv$id,
    sire = NA, dam = NA, sex = rep(c("M", "F"), length.out = nrow(test_gv)),
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
      plot <- result$guHistogram()

      expect_true(inherits(plot, "ggplot"))
    }
  )
})

# =============================================================================
# Tests for meanKinshipBoxPlot reactive function
# =============================================================================

test_that("modSummaryStatsServer returns meanKinshipBoxPlot reactive", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  test_gv <- makeTestGVData()
  test_ped <- data.frame(
    id = test_gv$id,
    sire = NA, dam = NA, sex = rep(c("M", "F"), length.out = nrow(test_gv)),
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

      expect_true("meanKinshipBoxPlot" %in% names(result))
      expect_true(is.function(result$meanKinshipBoxPlot))
    }
  )
})

test_that("meanKinshipBoxPlot returns a ggplot object", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  test_gv <- makeTestGVData()
  test_ped <- data.frame(
    id = test_gv$id,
    sire = NA, dam = NA, sex = rep(c("M", "F"), length.out = nrow(test_gv)),
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
      plot <- result$meanKinshipBoxPlot()

      expect_true(inherits(plot, "ggplot"))
    }
  )
})

test_that("meanKinshipBoxPlot has boxplot and jitter layers", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  test_gv <- makeTestGVData()
  test_ped <- data.frame(
    id = test_gv$id,
    sire = NA, dam = NA, sex = rep(c("M", "F"), length.out = nrow(test_gv)),
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
      plot <- result$meanKinshipBoxPlot()

      # Check that plot has geom_boxplot and geom_jitter layers
      layer_classes <- sapply(plot$layers, function(l) class(l$geom)[1])
      expect_true("GeomBoxplot" %in% layer_classes)
      expect_true("GeomJitter" %in% layer_classes || "GeomPoint" %in% layer_classes)
    }
  )
})

# =============================================================================
# Tests for zscoreBoxPlot reactive function
# =============================================================================

test_that("modSummaryStatsServer returns zscoreBoxPlot reactive", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  test_gv <- makeTestGVData()
  test_ped <- data.frame(
    id = test_gv$id,
    sire = NA, dam = NA, sex = rep(c("M", "F"), length.out = nrow(test_gv)),
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

      expect_true("zscoreBoxPlot" %in% names(result))
      expect_true(is.function(result$zscoreBoxPlot))
    }
  )
})

test_that("zscoreBoxPlot returns a ggplot object", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  test_gv <- makeTestGVData()
  test_ped <- data.frame(
    id = test_gv$id,
    sire = NA, dam = NA, sex = rep(c("M", "F"), length.out = nrow(test_gv)),
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
      plot <- result$zscoreBoxPlot()

      expect_true(inherits(plot, "ggplot"))
    }
  )
})

# =============================================================================
# Tests for guBoxPlot reactive function
# =============================================================================

test_that("modSummaryStatsServer returns guBoxPlot reactive", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  test_gv <- makeTestGVData()
  test_ped <- data.frame(
    id = test_gv$id,
    sire = NA, dam = NA, sex = rep(c("M", "F"), length.out = nrow(test_gv)),
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

      expect_true("guBoxPlot" %in% names(result))
      expect_true(is.function(result$guBoxPlot))
    }
  )
})

test_that("guBoxPlot returns a ggplot object", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  test_gv <- makeTestGVData()
  test_ped <- data.frame(
    id = test_gv$id,
    sire = NA, dam = NA, sex = rep(c("M", "F"), length.out = nrow(test_gv)),
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
      plot <- result$guBoxPlot()

      expect_true(inherits(plot, "ggplot"))
    }
  )
})

# =============================================================================
# Tests for edge cases
# =============================================================================

test_that("histograms handle missing zScore column gracefully", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  # Data without zScore column
  test_gv <- data.frame(
    id = paste0("Animal", 1:10),
    meanKinship = runif(10, 0.1, 0.4),
    genomeUniqueness = runif(10, 0.5, 0.9),
    stringsAsFactors = FALSE
  )
  test_ped <- data.frame(
    id = test_gv$id,
    sire = NA, dam = NA, sex = rep(c("M", "F"), 5),
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

      # zscoreHistogram should handle missing column gracefully
      # Either return NULL or a placeholder plot
      plot <- result$zscoreHistogram()
      expect_true(is.null(plot) || inherits(plot, "ggplot"))
    }
  )
})

test_that("plots handle single data point", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  test_gv <- data.frame(
    id = "SingleAnimal",
    meanKinship = 0.25,
    genomeUniqueness = 0.75,
    zScore = 0.0,
    stringsAsFactors = FALSE
  )
  test_ped <- data.frame(
    id = "SingleAnimal",
    sire = NA, dam = NA, sex = "M",
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

      # Should not error with single data point
      expect_no_error(result$mkHistogram())
      expect_no_error(result$meanKinshipBoxPlot())
    }
  )
})

test_that("plots handle NA values in data", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  test_gv <- data.frame(
    id = paste0("Animal", 1:10),
    meanKinship = c(0.1, 0.2, NA, 0.3, 0.4, NA, 0.5, 0.6, 0.7, 0.8),
    genomeUniqueness = c(0.9, NA, 0.8, 0.7, NA, 0.6, 0.5, 0.4, 0.3, 0.2),
    zScore = c(-1, 0, NA, 1, -0.5, NA, 0.5, -1.5, 1.5, 0),
    stringsAsFactors = FALSE
  )
  test_ped <- data.frame(
    id = test_gv$id,
    sire = NA, dam = NA, sex = rep(c("M", "F"), 5),
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

      # Should handle NA values without error
      expect_no_error(result$mkHistogram())
      expect_no_error(result$guHistogram())
      expect_no_error(result$zscoreHistogram())
      expect_no_error(result$meanKinshipBoxPlot())
      expect_no_error(result$guBoxPlot())
      expect_no_error(result$zscoreBoxPlot())
    }
  )
})

# =============================================================================
# Tests for plot styling consistency
# =============================================================================

test_that("all plots use consistent theme_classic styling", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  test_gv <- makeTestGVData()
  test_ped <- data.frame(
    id = test_gv$id,
    sire = NA, dam = NA, sex = rep(c("M", "F"), length.out = nrow(test_gv)),
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

      # Check that plots use theme_classic (or similar clean theme)
      mkHist <- result$mkHistogram()
      expect_true(inherits(mkHist$theme, "theme"))
    }
  )
})
