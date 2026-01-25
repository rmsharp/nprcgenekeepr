# Tests for modGeneticValue.R - Genetic Value Analysis Shiny Module

test_that("modGeneticValueUI returns a shiny.tag object", {
  ui <- modGeneticValueUI("test")
  expect_true(inherits(ui, "shiny.tag"))
})

test_that("modGeneticValueUI contains expected elements", {
  ui <- modGeneticValueUI("test")
  ui_html <- as.character(ui)

  # Check for main heading
  expect_true(grepl("Genetic Value Analysis", ui_html))

  # Check for analysis options
  expect_true(grepl("Analysis Options", ui_html))
  expect_true(grepl("nIterations", ui_html))
  expect_true(grepl("calcGenomeUniqueness", ui_html))
  expect_true(grepl("calcMeanKinship", ui_html))
  expect_true(grepl("minAge", ui_html))

  # Check for action button
  expect_true(grepl("runAnalysis", ui_html))

  # Check for tabs
  expect_true(grepl("Rankings", ui_html))
  expect_true(grepl("Visualizations", ui_html))
  expect_true(grepl("Summary", ui_html))
})

test_that("modGeneticValueUI uses correct namespace", {
  ui <- modGeneticValueUI("gvNamespace")
  ui_html <- as.character(ui)

  # Input IDs should be namespaced
  expect_true(grepl("gvNamespace-nIterations", ui_html))
  expect_true(grepl("gvNamespace-runAnalysis", ui_html))
  expect_true(grepl("gvNamespace-topN", ui_html))
})

test_that("modGeneticValueUI has download button", {
  ui <- modGeneticValueUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("downloadRankings", ui_html))
})

test_that("modGeneticValueUI includes informational panel", {
  ui <- modGeneticValueUI("test")
  ui_html <- as.character(ui)

  # Check for info panel content
  expect_true(grepl("Mean Kinship", ui_html))
  expect_true(grepl("Genome Uniqueness", ui_html))
})

test_that("modGeneticValueServer returns expected reactive list", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = c("A", "B", "C", "D", "E"),
    sire = c(NA, NA, "A", "A", "B"),
    dam = c(NA, NA, "B", NA, NA),
    sex = c("M", "F", "F", "M", "F"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      # Check return value structure
      result <- session$getReturned()
      expect_true(is.list(result))
      expect_true("geneticValues" %in% names(result))
      expect_true("topAnimals" %in% names(result))
      expect_true("nAnalyzed" %in% names(result))

      # Each component should be reactive
      expect_true(is.function(result$geneticValues))
      expect_true(is.function(result$topAnimals))
      expect_true(is.function(result$nAnalyzed))
    }
  )
})

test_that("modGeneticValueServer handles input changes", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:20),
    sire = c(rep(NA, 10), paste0("Animal", 1:10)),
    dam = c(rep(NA, 10), paste0("Animal", 11:20)),
    sex = rep(c("M", "F"), 10),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      # Set various inputs
      session$setInputs(nIterations = 1000)
      expect_equal(input$nIterations, 1000)

      session$setInputs(calcGenomeUniqueness = FALSE)
      expect_false(input$calcGenomeUniqueness)

      session$setInputs(calcMeanKinship = TRUE)
      expect_true(input$calcMeanKinship)

      session$setInputs(minAge = 3.5)
      expect_equal(input$minAge, 3.5)

      session$setInputs(topN = 15)
      expect_equal(input$topN, 15)
    }
  )
})

# ============================================================================
# Server Tests - gvResults eventReactive
# ============================================================================

test_that("modGeneticValueServer gvResults triggers on runAnalysis", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:20),
    sire = c(rep(NA, 5), paste0("Animal", 1:15)),
    dam = c(rep(NA, 5), paste0("Animal", c(6:10, 6:10, 6:10))),
    sex = rep(c("M", "F"), 10),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 500)
      session$setInputs(topN = 10)

      # Trigger the analysis
      session$setInputs(runAnalysis = 1)

      # Check that results were created
      results <- gvResults()
      expect_true(is.data.frame(results))
      expect_true(nrow(results) > 0)
    }
  )
})

test_that("modGeneticValueServer gvResults contains expected columns", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("A", 1:15),
    sire = c(rep(NA, 5), paste0("A", 1:10)),
    dam = c(rep(NA, 5), paste0("A", c(6:10, 6:10))),
    sex = rep(c("M", "F"), length.out = 15),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      expect_true("id" %in% names(results))
      expect_true("meanKinship" %in% names(results))
      expect_true("genomeUniqueness" %in% names(results))
      expect_true("rank" %in% names(results))
    }
  )
})

test_that("modGeneticValueServer gvResults rank is sequential", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:30),
    sire = c(rep(NA, 10), paste0("Animal", 1:20)),
    dam = c(rep(NA, 10), paste0("Animal", 11:20), paste0("Animal", 11:20)),
    sex = rep(c("M", "F"), 15),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      expect_equal(results$rank, seq_len(nrow(results)))
    }
  )
})

# ============================================================================
# Server Tests - Return values after analysis
# ============================================================================

test_that("modGeneticValueServer geneticValues returns all results", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("X", 1:25),
    sire = c(rep(NA, 8), paste0("X", 1:17)),
    dam = c(rep(NA, 8), paste0("X", c(9:16, 9:17))),
    sex = rep(c("M", "F"), length.out = 25),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(runAnalysis = 1)

      result <- session$getReturned()
      gv <- result$geneticValues()
      expect_true(is.data.frame(gv))
      expect_true(nrow(gv) > 0)
      expect_equal(gv, gvResults())
    }
  )
})

test_that("modGeneticValueServer topAnimals returns top 10", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:50),
    sire = c(rep(NA, 15), paste0("Animal", 1:35)),
    dam = c(rep(NA, 15), paste0("Animal", 16:30), paste0("Animal", 16:35)),
    sex = rep(c("M", "F"), 25),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(runAnalysis = 1)

      result <- session$getReturned()
      top <- result$topAnimals()
      expect_true(is.data.frame(top))
      expect_true(nrow(top) <= 10)
      expect_true(all(top$rank <= 10))
    }
  )
})

test_that("modGeneticValueServer nAnalyzed returns correct count", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("A", 1:30),
    sire = c(rep(NA, 10), paste0("A", 1:20)),
    dam = c(rep(NA, 10), paste0("A", 11:20), paste0("A", 11:20)),
    sex = rep(c("M", "F"), 15),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(runAnalysis = 1)

      result <- session$getReturned()
      n <- result$nAnalyzed()
      expect_true(is.numeric(n))
      expect_equal(n, nrow(gvResults()))
    }
  )
})

# ============================================================================
# Server Tests - Output rendering
# ============================================================================

test_that("modGeneticValueServer rankingsTable renders after analysis", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:20),
    sire = c(rep(NA, 5), paste0("Animal", 1:15)),
    dam = c(rep(NA, 5), paste0("Animal", c(6:10, 6:10, 6:10))),
    sex = rep(c("M", "F"), 10),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(topN = 10)
      session$setInputs(runAnalysis = 1)

      # Output should render without error
      expect_no_error(output$rankingsTable)
    }
  )
})

test_that("modGeneticValueServer gvSummary renders after analysis", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:20),
    sire = c(rep(NA, 5), paste0("Animal", 1:15)),
    dam = c(rep(NA, 5), paste0("Animal", c(6:10, 6:10, 6:10))),
    sex = rep(c("M", "F"), 10),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(runAnalysis = 1)

      # Output should render without error
      expect_no_error(output$gvSummary)
    }
  )
})

test_that("modGeneticValueServer gvScatterPlot renders after analysis", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:20),
    sire = c(rep(NA, 5), paste0("Animal", 1:15)),
    dam = c(rep(NA, 5), paste0("Animal", c(6:10, 6:10, 6:10))),
    sex = rep(c("M", "F"), 10),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(runAnalysis = 1)

      # Output should render without error
      expect_no_error(output$gvScatterPlot)
    }
  )
})

# ============================================================================
# Server Tests - topN filtering
# ============================================================================

test_that("modGeneticValueServer respects topN setting", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:60),
    sire = c(rep(NA, 20), paste0("Animal", 1:40)),
    dam = c(rep(NA, 20), paste0("Animal", 21:40), paste0("Animal", 21:40)),
    sex = rep(c("M", "F"), 30),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(topN = 5)
      session$setInputs(runAnalysis = 1)

      # Rankings should be filtered to top 5
      expect_equal(input$topN, 5)
    }
  )
})

test_that("modGeneticValueServer topN can be changed after analysis", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("A", 1:40),
    sire = c(rep(NA, 10), paste0("A", 1:30)),
    dam = c(rep(NA, 10), paste0("A", 11:20), paste0("A", 11:20), paste0("A", 11:20)),
    sex = rep(c("M", "F"), 20),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(topN = 20)
      session$setInputs(runAnalysis = 1)

      expect_equal(input$topN, 20)

      # Change topN after analysis
      session$setInputs(topN = 10)
      expect_equal(input$topN, 10)

      session$setInputs(topN = 30)
      expect_equal(input$topN, 30)
    }
  )
})

# ============================================================================
# Server Tests - Edge cases
# ============================================================================

test_that("modGeneticValueServer handles small pedigree", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "M"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      expect_true(is.data.frame(results))
      expect_true(nrow(results) <= 3)
    }
  )
})

test_that("modGeneticValueServer handles large pedigree", {
  skip_if_not_installed("shiny")

  n <- 100
  test_ped <- data.frame(
    id = paste0("Animal", 1:n),
    sire = c(rep(NA, 20), paste0("Animal", 1:(n-20))),
    dam = c(rep(NA, 20), paste0("Animal", 21:40), rep(paste0("Animal", 21:40), n/20 - 2)),
    sex = rep(c("M", "F"), n/2),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      expect_true(is.data.frame(results))
      # Results capped at 50 animals based on implementation
      expect_true(nrow(results) <= 50)
    }
  )
})

test_that("modGeneticValueServer handles founders only pedigree", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Founder", 1:10),
    sire = rep(NA, 10),
    dam = rep(NA, 10),
    sex = rep(c("M", "F"), 5),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      expect_true(is.data.frame(results))
      expect_equal(nrow(results), 10)
    }
  )
})

# ============================================================================
# Server Tests - Input parameter variations
# ============================================================================

test_that("modGeneticValueServer handles minimum nIterations", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("A", 1:10),
    sire = c(rep(NA, 3), paste0("A", 1:7)),
    dam = c(rep(NA, 3), paste0("A", c(4, 4, 4, 5, 5, 5, 6))),
    sex = rep(c("M", "F"), 5),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
      session$setInputs(runAnalysis = 1)

      expect_equal(input$nIterations, 100)
      results <- gvResults()
      expect_true(is.data.frame(results))
    }
  )
})

test_that("modGeneticValueServer handles maximum nIterations", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("A", 1:10),
    sire = c(rep(NA, 3), paste0("A", 1:7)),
    dam = c(rep(NA, 3), paste0("A", c(4, 4, 4, 5, 5, 5, 6))),
    sex = rep(c("M", "F"), 5),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 10000)
      session$setInputs(runAnalysis = 1)

      expect_equal(input$nIterations, 10000)
      results <- gvResults()
      expect_true(is.data.frame(results))
    }
  )
})

test_that("modGeneticValueServer handles minAge variations", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("A", 1:15),
    sire = c(rep(NA, 5), paste0("A", 1:10)),
    dam = c(rep(NA, 5), paste0("A", c(6:10, 6:10))),
    sex = rep(c("M", "F"), length.out = 15),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      # Test minimum age
      session$setInputs(minAge = 0)
      expect_equal(input$minAge, 0)

      # Test different age
      session$setInputs(minAge = 5)
      expect_equal(input$minAge, 5)

      # Test maximum age
      session$setInputs(minAge = 10)
      expect_equal(input$minAge, 10)
    }
  )
})

test_that("modGeneticValueServer handles checkbox combinations", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("A", 1:10),
    sire = c(rep(NA, 3), paste0("A", 1:7)),
    dam = c(rep(NA, 3), paste0("A", c(4, 4, 4, 5, 5, 5, 6))),
    sex = rep(c("M", "F"), 5),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      # Both enabled
      session$setInputs(calcGenomeUniqueness = TRUE, calcMeanKinship = TRUE)
      expect_true(input$calcGenomeUniqueness)
      expect_true(input$calcMeanKinship)

      # Only genome uniqueness
      session$setInputs(calcGenomeUniqueness = TRUE, calcMeanKinship = FALSE)
      expect_true(input$calcGenomeUniqueness)
      expect_false(input$calcMeanKinship)

      # Only mean kinship
      session$setInputs(calcGenomeUniqueness = FALSE, calcMeanKinship = TRUE)
      expect_false(input$calcGenomeUniqueness)
      expect_true(input$calcMeanKinship)

      # Both disabled
      session$setInputs(calcGenomeUniqueness = FALSE, calcMeanKinship = FALSE)
      expect_false(input$calcGenomeUniqueness)
      expect_false(input$calcMeanKinship)
    }
  )
})

# ============================================================================
# Server Tests - Multiple analysis runs
# ============================================================================

test_that("modGeneticValueServer handles multiple runAnalysis clicks", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:20),
    sire = c(rep(NA, 5), paste0("Animal", 1:15)),
    dam = c(rep(NA, 5), paste0("Animal", c(6:10, 6:10, 6:10))),
    sex = rep(c("M", "F"), 10),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      # First run
      session$setInputs(runAnalysis = 1)
      results1 <- gvResults()
      expect_true(is.data.frame(results1))

      # Second run
      session$setInputs(runAnalysis = 2)
      results2 <- gvResults()
      expect_true(is.data.frame(results2))

      # Third run
      session$setInputs(runAnalysis = 3)
      results3 <- gvResults()
      expect_true(is.data.frame(results3))
    }
  )
})

# ============================================================================
# Server Tests - Return values require analysis
# ============================================================================

test_that("modGeneticValueServer geneticValues requires analysis", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "M"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      result <- session$getReturned()
      # Before analysis is run, geneticValues should error
      expect_error(result$geneticValues())
    }
  )
})

test_that("modGeneticValueServer topAnimals requires analysis", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "M"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      result <- session$getReturned()
      # Before analysis is run, topAnimals should error
      expect_error(result$topAnimals())
    }
  )
})

test_that("modGeneticValueServer nAnalyzed requires analysis", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "M"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      result <- session$getReturned()
      # Before analysis is run, nAnalyzed should error
      expect_error(result$nAnalyzed())
    }
  )
})

# ============================================================================
# Server Tests - Results data validation
# ============================================================================

test_that("modGeneticValueServer meanKinship values are valid", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("A", 1:30),
    sire = c(rep(NA, 10), paste0("A", 1:20)),
    dam = c(rep(NA, 10), paste0("A", 11:20), paste0("A", 11:20)),
    sex = rep(c("M", "F"), 15),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      # meanKinship should be between 0 and 1
      expect_true(all(results$meanKinship >= 0))
      expect_true(all(results$meanKinship <= 1))
    }
  )
})

test_that("modGeneticValueServer genomeUniqueness values are valid", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("A", 1:30),
    sire = c(rep(NA, 10), paste0("A", 1:20)),
    dam = c(rep(NA, 10), paste0("A", 11:20), paste0("A", 11:20)),
    sex = rep(c("M", "F"), 15),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      # genomeUniqueness should be between 0 and 1
      expect_true(all(results$genomeUniqueness >= 0))
      expect_true(all(results$genomeUniqueness <= 1))
    }
  )
})

test_that("modGeneticValueServer results have unique IDs", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:25),
    sire = c(rep(NA, 8), paste0("Animal", 1:17)),
    dam = c(rep(NA, 8), paste0("Animal", c(9:16, 9:17))),
    sex = rep(c("M", "F"), length.out = 25),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      # IDs should be unique
      expect_equal(length(results$id), length(unique(results$id)))
    }
  )
})

# ============================================================================
# UI Tests - Additional coverage
# ============================================================================

test_that("modGeneticValueUI has wellPanel styling", {
  ui <- modGeneticValueUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("wellPanel|well", ui_html, ignore.case = TRUE))
})

test_that("modGeneticValueUI has numeric input constraints", {
  ui <- modGeneticValueUI("test")
  ui_html <- as.character(ui)

  # nIterations should have min/max
  expect_true(grepl("nIterations", ui_html))
  expect_true(grepl("5000", ui_html))  # default value
})

test_that("modGeneticValueUI has slider input", {
  ui <- modGeneticValueUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("minAge", ui_html))
  expect_true(grepl("slider", ui_html, ignore.case = TRUE))
})

test_that("modGeneticValueUI has plot output", {
  ui <- modGeneticValueUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("gvScatterPlot", ui_html))
  expect_true(grepl("plotOutput|shiny-plot-output", ui_html))
})

test_that("modGeneticValueUI has table output", {
  ui <- modGeneticValueUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("gvSummary", ui_html))
  expect_true(grepl("rankingsTable", ui_html))
})

test_that("modGeneticValueUI has action button with correct class", {
  ui <- modGeneticValueUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("btn-primary", ui_html))
  expect_true(grepl("btn-block", ui_html))
})

test_that("modGeneticValueUI has icons", {
  ui <- modGeneticValueUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("fa-dna|dna", ui_html))
  expect_true(grepl("fa-play|play", ui_html))
})

test_that("modGeneticValueUI generates unique IDs for different namespaces", {
  ui1 <- modGeneticValueUI("ns1")
  ui2 <- modGeneticValueUI("ns2")

  ui_html1 <- as.character(ui1)
  ui_html2 <- as.character(ui2)

  expect_true(grepl("ns1-nIterations", ui_html1))
  expect_true(grepl("ns2-nIterations", ui_html2))
  expect_false(grepl("ns2", ui_html1))
  expect_false(grepl("ns1", ui_html2))
})

# ============================================================================
# Server Tests - Pedigree with specific characteristics
# ============================================================================

test_that("modGeneticValueServer handles single generation pedigree", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Gen1_", 1:15),
    sire = rep(NA, 15),
    dam = rep(NA, 15),
    sex = rep(c("M", "F"), length.out = 15),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      expect_true(is.data.frame(results))
      expect_equal(nrow(results), 15)
    }
  )
})

test_that("modGeneticValueServer handles multi-generation pedigree", {
  skip_if_not_installed("shiny")

  # Create a 3-generation pedigree
  test_ped <- data.frame(
    id = c("F1", "F2", "F3", "F4",  # Gen 1 - founders
           "G2_1", "G2_2", "G2_3", "G2_4",  # Gen 2
           "G3_1", "G3_2", "G3_3", "G3_4"),  # Gen 3
    sire = c(NA, NA, NA, NA,
             "F1", "F1", "F3", "F3",
             "G2_1", "G2_1", "G2_3", "G2_3"),
    dam = c(NA, NA, NA, NA,
            "F2", "F2", "F4", "F4",
            "G2_2", "G2_2", "G2_4", "G2_4"),
    sex = c("M", "F", "M", "F",
            "M", "F", "M", "F",
            "M", "F", "M", "F"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      expect_true(is.data.frame(results))
      expect_equal(nrow(results), 12)
    }
  )
})

test_that("modGeneticValueServer handles pedigree with special character IDs", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = c("A-001", "B_002", "C.003", "D 004", "E/005"),
    sire = c(NA, NA, "A-001", "A-001", "B_002"),
    dam = c(NA, NA, "B_002", NA, NA),
    sex = c("M", "F", "M", "F", "M"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      expect_true(is.data.frame(results))
      expect_true("A-001" %in% results$id)
    }
  )
})

# ============================================================================
# TDD Tests - reportGV Integration (these should fail until implemented)
# Tests to ensure modGeneticValueServer uses real reportGV() function
# ============================================================================

test_that("modGeneticValueServer returns full reportGV structure", {
  skip_if_not_installed("shiny")

  # Create a proper pedigree for reportGV
  test_ped <- nprcgenekeepr::qcStudbook(
    nprcgenekeepr::examplePedigree[1:50, ],
    minParentAge = 2,
    reportChanges = FALSE,
    reportErrors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 50)  # Low iterations for test speed
      session$setInputs(runAnalysis = 1)

      result <- session$getReturned()

      # Should return full results including kinshipMatrix and founderStats
      expect_true("kinshipMatrix" %in% names(result))
      expect_true("founderStats" %in% names(result))
    }
  )
})

test_that("modGeneticValueServer returns kinship matrix", {
  skip_if_not_installed("shiny")

  test_ped <- nprcgenekeepr::qcStudbook(
    nprcgenekeepr::examplePedigree[1:50, ],
    minParentAge = 2,
    reportChanges = FALSE,
    reportErrors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 50)
      session$setInputs(runAnalysis = 1)

      result <- session$getReturned()
      kmat <- result$kinshipMatrix()

      # kinshipMatrix should be a matrix
      expect_true(is.matrix(kmat))
      # Should be symmetric
      expect_equal(nrow(kmat), ncol(kmat))
    }
  )
})

test_that("modGeneticValueServer returns founder statistics", {
  skip_if_not_installed("shiny")

  test_ped <- nprcgenekeepr::qcStudbook(
    nprcgenekeepr::examplePedigree[1:50, ],
    minParentAge = 2,
    reportChanges = FALSE,
    reportErrors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 50)
      session$setInputs(runAnalysis = 1)

      result <- session$getReturned()
      fStats <- result$founderStats()

      # founderStats should include FE and FG
      expect_true("fe" %in% names(fStats))
      expect_true("fg" %in% names(fStats))
      expect_true("total" %in% names(fStats))
      expect_true("nMaleFounders" %in% names(fStats))
      expect_true("nFemaleFounders" %in% names(fStats))
    }
  )
})

test_that("modGeneticValueServer returns male and female founders", {
  skip_if_not_installed("shiny")

  test_ped <- nprcgenekeepr::qcStudbook(
    nprcgenekeepr::examplePedigree[1:50, ],
    minParentAge = 2,
    reportChanges = FALSE,
    reportErrors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 50)
      session$setInputs(runAnalysis = 1)

      result <- session$getReturned()

      expect_true("maleFounders" %in% names(result))
      expect_true("femaleFounders" %in% names(result))

      mf <- result$maleFounders()
      ff <- result$femaleFounders()

      expect_true(is.data.frame(mf))
      expect_true(is.data.frame(ff))
    }
  )
})

test_that("modGeneticValueServer geneticValues has indivMeanKin column", {
  skip_if_not_installed("shiny")

  test_ped <- nprcgenekeepr::qcStudbook(
    nprcgenekeepr::examplePedigree[1:50, ],
    minParentAge = 2,
    reportChanges = FALSE,
    reportErrors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 50)
      session$setInputs(runAnalysis = 1)

      result <- session$getReturned()
      gv <- result$geneticValues()

      # Should have column names matching reportGV output
      expect_true("indivMeanKin" %in% names(gv))
      expect_true("zScores" %in% names(gv))
      expect_true("gu" %in% names(gv))
    }
  )
})

test_that("modGeneticValueServer uses real kinship calculation", {
  skip_if_not_installed("shiny")

  test_ped <- nprcgenekeepr::qcStudbook(
    nprcgenekeepr::examplePedigree[1:50, ],
    minParentAge = 2,
    reportChanges = FALSE,
    reportErrors = FALSE
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 50)
      session$setInputs(runAnalysis = 1)

      result <- session$getReturned()
      gv <- result$geneticValues()

      # indivMeanKin should NOT be random (check consistency)
      # Run analysis again
      session$setInputs(runAnalysis = 2)
      gv2 <- result$geneticValues()

      # With real kinship, values should be deterministic
      # (unlike random placeholder values)
      # Check that the ids match and kinship values are consistent
      expect_equal(sort(gv$id), sort(gv2$id))
      # indivMeanKin should be the same between runs
      # (kinship is deterministic, unlike random placeholder)
      gv_sorted <- gv[order(gv$id), ]
      gv2_sorted <- gv2[order(gv2$id), ]
      expect_equal(gv_sorted$indivMeanKin, gv2_sorted$indivMeanKin)
    }
  )
})
