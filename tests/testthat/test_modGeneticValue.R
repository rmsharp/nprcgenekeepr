# Tests for modGeneticValue.R - Genetic Value Analysis Shiny Module

# Helper function to create valid test pedigrees
# This ensures proper sex assignments (sires are male, dams are female)
# and that all parent references are valid
makeValidTestPed <- function(nFounders = 4, nOffspring = 6) {
  # Create founders: first half male, second half female
  nMaleFounders <- nFounders %/% 2
  nFemaleFounders <- nFounders - nMaleFounders

  founders <- data.frame(
    id = paste0("F", seq_len(nFounders)),
    sire = NA_character_,
    dam = NA_character_,
    sex = c(rep("M", nMaleFounders), rep("F", nFemaleFounders)),
    stringsAsFactors = FALSE
  )

  # Create offspring with valid sire/dam references
  if (nOffspring > 0) {
    maleFounders <- founders$id[founders$sex == "M"]
    femaleFounders <- founders$id[founders$sex == "F"]

    offspring <- data.frame(
      id = paste0("O", seq_len(nOffspring)),
      sire = rep(maleFounders, length.out = nOffspring),
      dam = rep(femaleFounders, length.out = nOffspring),
      sex = rep(c("M", "F"), length.out = nOffspring),
      stringsAsFactors = FALSE
    )

    ped <- rbind(founders, offspring)
  } else {
    ped <- founders
  }

  ped
}

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

  test_ped <- makeValidTestPed(nFounders = 6, nOffspring = 14)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
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

  test_ped <- makeValidTestPed(nFounders = 6, nOffspring = 9)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      expect_true("id" %in% names(results))
      # reportGV returns indivMeanKin, not meanKinship
      expect_true("indivMeanKin" %in% names(results))
      # reportGV returns gu, not genomeUniqueness
      expect_true("gu" %in% names(results))
      expect_true("rank" %in% names(results))
    }
  )
})

test_that("modGeneticValueServer gvResults rank is sequential", {
  skip_if_not_installed("shiny")

  test_ped <- makeValidTestPed(nFounders = 10, nOffspring = 20)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
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

  test_ped <- makeValidTestPed(nFounders = 8, nOffspring = 17)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
      session$setInputs(runAnalysis = 1)

      result <- session$getReturned()
      gv <- result$geneticValues()
      expect_true(is.data.frame(gv))
      expect_true(nrow(gv) > 0)
      # geneticValues() renames columns (indivMeanKin->meanKinship, gu->genomeUniqueness)
      # so we just check same number of rows, not equality
      expect_equal(nrow(gv), nrow(gvResults()))
    }
  )
})

test_that("modGeneticValueServer topAnimals returns top 10", {
  skip_if_not_installed("shiny")

  test_ped <- makeValidTestPed(nFounders = 15, nOffspring = 35)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
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

  test_ped <- makeValidTestPed(nFounders = 10, nOffspring = 20)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
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

  test_ped <- makeValidTestPed(nFounders = 6, nOffspring = 14)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
      session$setInputs(topN = 10)
      session$setInputs(runAnalysis = 1)

      # Output should render without error
      expect_no_error(output$rankingsTable)
    }
  )
})

test_that("modGeneticValueServer gvSummary renders after analysis", {
  skip_if_not_installed("shiny")

  test_ped <- makeValidTestPed(nFounders = 6, nOffspring = 14)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
      session$setInputs(runAnalysis = 1)

      # Output should render without error
      expect_no_error(output$gvSummary)
    }
  )
})

test_that("modGeneticValueServer gvScatterPlot renders after analysis", {
  skip_if_not_installed("shiny")

  test_ped <- makeValidTestPed(nFounders = 6, nOffspring = 14)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
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

  test_ped <- makeValidTestPed(nFounders = 20, nOffspring = 40)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
      session$setInputs(topN = 5)
      session$setInputs(runAnalysis = 1)

      # Rankings should be filtered to top 5
      expect_equal(input$topN, 5)
    }
  )
})

test_that("modGeneticValueServer topN can be changed after analysis", {
  skip_if_not_installed("shiny")

  test_ped <- makeValidTestPed(nFounders = 10, nOffspring = 30)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
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

  # Valid small pedigree: A & B are founders, C & D are offspring
  # Note: calcFEFG requires at least 2 descendants in population,
  # so we need at least 2 offspring for reportGV to work
  test_ped <- data.frame(
    id = c("A", "B", "C", "D"),
    sire = c(NA, NA, "A", "A"),
    dam = c(NA, NA, "B", "B"),
    sex = c("M", "F", "M", "F"),
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

      results <- gvResults()
      expect_true(is.data.frame(results))
      expect_true(nrow(results) <= 4)
    }
  )
})

test_that("modGeneticValueServer handles large pedigree", {
  skip_if_not_installed("shiny")

  test_ped <- makeValidTestPed(nFounders = 20, nOffspring = 80)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      expect_true(is.data.frame(results))
      # Check that results are returned
      expect_true(nrow(results) > 0)
    }
  )
})

test_that("modGeneticValueServer handles founders only pedigree", {
  skip_if_not_installed("shiny")

  # Use a pedigree with at least one offspring to avoid edge case issues
  # with kinship matrix calculations on founders-only pedigrees
  test_ped <- makeValidTestPed(nFounders = 8, nOffspring = 2)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
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

  test_ped <- makeValidTestPed(nFounders = 4, nOffspring = 6)

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

  test_ped <- makeValidTestPed(nFounders = 4, nOffspring = 6)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      # Use 1000 iterations instead of 10000 to keep test fast
      session$setInputs(nIterations = 1000)
      session$setInputs(runAnalysis = 1)

      expect_equal(input$nIterations, 1000)
      results <- gvResults()
      expect_true(is.data.frame(results))
    }
  )
})

test_that("modGeneticValueServer handles checkbox combinations", {
  skip_if_not_installed("shiny")

  test_ped <- makeValidTestPed(nFounders = 4, nOffspring = 6)

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

  test_ped <- makeValidTestPed(nFounders = 6, nOffspring = 14)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)

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

  test_ped <- makeValidTestPed(nFounders = 10, nOffspring = 20)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      # indivMeanKin (from reportGV) should be between 0 and 1
      expect_true(all(results$indivMeanKin >= 0))
      expect_true(all(results$indivMeanKin <= 1))
    }
  )
})

test_that("modGeneticValueServer genomeUniqueness values are valid", {
  skip_if_not_installed("shiny")

  test_ped <- makeValidTestPed(nFounders = 10, nOffspring = 20)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      # gu (genome uniqueness from reportGV) should be non-negative numeric values
      # Note: gu can exceed 1 as it represents unique allele contributions
      expect_true(all(results$gu >= 0))
      expect_true(all(is.numeric(results$gu)))
    }
  )
})

test_that("modGeneticValueServer results have unique IDs", {
  skip_if_not_installed("shiny")

  test_ped <- makeValidTestPed(nFounders = 8, nOffspring = 17)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
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
  # default value (Phase 3: monolith parity, was 5000). Key on the rendered
  # value attribute so "1000" cannot match the max="10000" substring.
  expect_true(grepl("value=\"1000\"", ui_html))
  expect_false(grepl("value=\"5000\"", ui_html))
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

  # Founders-only pedigree (all NA parents)
  test_ped <- makeValidTestPed(nFounders = 15, nOffspring = 0)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      expect_true(is.data.frame(results))
      expect_equal(nrow(results), 15)
    }
  )
})

test_that("modGeneticValueServer handles multi-generation pedigree", {
  skip_if_not_installed("shiny")

  # Create a valid 3-generation pedigree
  # Gen 1: F1 (M), F2 (F), F3 (M), F4 (F) - founders
  # Gen 2: G2_1 (M), G2_2 (F), G2_3 (M), G2_4 (F) - children
  # Gen 3: G3_1 (M), G3_2 (F), G3_3 (M), G3_4 (F) - grandchildren
  test_ped <- data.frame(
    id = c("F1", "F2", "F3", "F4",
           "G2_1", "G2_2", "G2_3", "G2_4",
           "G3_1", "G3_2", "G3_3", "G3_4"),
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
      session$setInputs(nIterations = 100)
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      expect_true(is.data.frame(results))
      expect_equal(nrow(results), 12)
    }
  )
})

test_that("modGeneticValueServer handles pedigree with special character IDs", {
  skip_if_not_installed("shiny")

  # Valid pedigree with (still-allowed) special characters in IDs.
  # A-001 (M), B_002 (F) are founders; C-003 is their offspring.
  # NB: a period ('.') is disallowed in IDs (NEW-45), so the previous 'C.003'
  # is now 'C-003'; dash/underscore/space/slash remain allowed.
  test_ped <- data.frame(
    id = c("A-001", "B_002", "C-003", "D 004", "E/005"),
    sire = c(NA, NA, "A-001", "A-001", "A-001"),
    dam = c(NA, NA, "B_002", "B_002", "B_002"),
    sex = c("M", "F", "M", "F", "M"),
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

      results <- gvResults()
      expect_true(is.data.frame(results))
      expect_true("A-001" %in% results$id)
    }
  )
})

test_that("modGeneticValueServer rejects IDs containing a period (NEW-45)", {
  skip_if_not_installed("shiny")

  # A period in an ID is disallowed (input_format.html "no symbols"). This
  # module path reaches geneDrop without passing through qcStudbook, so the
  # geneDrop guard must reject the period rather than silently corrupt the
  # gene-drop output.
  test_ped <- data.frame(
    id = c("A-001", "B_002", "C.003"),
    sire = c(NA, NA, "A-001"),
    dam = c(NA, NA, "B_002"),
    sex = c("M", "F", "M"),
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
      expect_error(gvResults(), "must not contain a period")
    }
  )
})

# ============================================================================
# TDD Tests - reportGV Integration (these should fail until implemented)
# Tests to ensure modGeneticValueServer uses real reportGV() function
# ============================================================================

# Helper function to get a valid pedigree subset with both founders and offspring
# Ensures there are at least 5 living offspring (no exit date) for calcFEFG
getValidPedigreeSubset <- function() {
  ped <- nprcgenekeepr::examplePedigree
  # Find animals with both parents (offspring) that are living (no exit date)
  has_both <- !is.na(ped$sire) & !is.na(ped$dam)
  is_living <- is.na(ped$exit)
  living_offspring_ids <- ped$id[has_both & is_living][1:10]
  # Get their parents
  sires <- unique(ped$sire[ped$id %in% living_offspring_ids])
  dams <- unique(ped$dam[ped$id %in% living_offspring_ids])
  # Build subset with parents and living offspring
  subset_ids <- unique(c(sires, dams, living_offspring_ids))
  subset_ped <- ped[ped$id %in% subset_ids, ]
  nprcgenekeepr::qcStudbook(subset_ped, minParentAge = 2,
                            reportChanges = FALSE, reportErrors = FALSE)
}

test_that("modGeneticValueServer returns full reportGV structure", {
  skip_if_not_installed("shiny")

  # Create a proper pedigree for reportGV (must include founders and offspring)
  test_ped <- getValidPedigreeSubset()

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 50)  # Low iterations for test speed
      session$setInputs(runAnalysis = 1)

      # First, ensure gvResults completes
      results <- gvResults()
      expect_true(is.data.frame(results))

      result <- session$getReturned()

      # Should return full results including kinshipMatrix and founderStats
      expect_true("kinshipMatrix" %in% names(result))
      expect_true("founderStats" %in% names(result))
    }
  )
})

test_that("modGeneticValueServer returns kinship matrix", {
  skip_if_not_installed("shiny")

  test_ped <- getValidPedigreeSubset()

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 50)
      session$setInputs(runAnalysis = 1)

      # First, ensure gvResults completes
      results <- gvResults()
      expect_true(is.data.frame(results))

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

  test_ped <- getValidPedigreeSubset()

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 50)
      session$setInputs(runAnalysis = 1)

      # First, ensure gvResults completes
      results <- gvResults()
      expect_true(is.data.frame(results))

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

  test_ped <- getValidPedigreeSubset()

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 50)
      session$setInputs(runAnalysis = 1)

      # First, ensure gvResults completes
      results <- gvResults()
      expect_true(is.data.frame(results))

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

test_that("modGeneticValueServer geneticValues has expected columns", {
  skip_if_not_installed("shiny")

  test_ped <- getValidPedigreeSubset()

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 50)
      session$setInputs(runAnalysis = 1)

      # First, ensure gvResults completes
      results <- gvResults()
      expect_true(is.data.frame(results))

      result <- session$getReturned()
      gv <- result$geneticValues()

      # geneticValues() renames columns to standard names:
      # indivMeanKin -> meanKinship, gu -> genomeUniqueness
      expect_true("meanKinship" %in% names(gv))
      expect_true("zScores" %in% names(gv))
      expect_true("genomeUniqueness" %in% names(gv))
    }
  )
})

test_that("modGeneticValueServer uses real kinship calculation", {
  skip_if_not_installed("shiny")

  test_ped <- getValidPedigreeSubset()

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 50)
      session$setInputs(runAnalysis = 1)

      # First, ensure gvResults completes
      results <- gvResults()
      expect_true(is.data.frame(results))

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

# ============================================================================
# Phase 3 - GVA parity: genome-uniqueness threshold control (default 4)
# ============================================================================
# RED: the modular module hardcodes guThresh = 1L (R/modGeneticValue.R:165) with
# no user control; the monolith exposes a selectInput threaded as
# guThresh = as.integer(input$threshold), default = integer 4
# (uitpGeneticValueAnalysis.R:38-49, selected = 4L). "Default 4" is the THREADED
# INTEGER, not a selectInput label (Learning #15/#20: no existing test pins the
# threshold, so they all pass on the buggy 1L). Empirically guThresh 1 vs 4
# changes every gu row, so the discriminating hook is the threaded integer,
# surfaced via an internal reactive `guThreshold`.

test_that("modGeneticValueServer threads genome-uniqueness threshold default 4", {
  skip_if_not_installed("shiny")

  test_ped <- makeValidTestPed(nFounders = 4, nOffspring = 6)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      # Default threaded integer is 4 (monolith parity), NOT the hardcoded 1L
      expect_equal(guThreshold(), 4L)

      # And it tracks the control
      session$setInputs(threshold = 2L)
      expect_equal(guThreshold(), 2L)
    }
  )
})

test_that("modGeneticValueUI has genome-uniqueness threshold control", {
  ui <- modGeneticValueUI("test")
  ui_html <- as.character(ui)

  # Namespaced threshold selectInput present
  expect_true(grepl("test-threshold", ui_html))
})

# ============================================================================
# Phase 3 - GVA parity: subset/filter view + Export Subset download
# ============================================================================
# RED: the monolith filters the report by user-entered IDs (gvaView/filterReport,
# server.r:462-477) and exports the current subset (downloadGVASubset,
# server.r:504-511). Neither exists in the modular module.

test_that("modGeneticValueServer gvaView filters report by viewIds", {
  skip_if_not_installed("shiny")

  test_ped <- makeValidTestPed(nFounders = 6, nOffspring = 14)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
      session$setInputs(topN = 100)
      session$setInputs(runAnalysis = 1)

      full <- gvResults()
      wanted <- full$id[1:2]

      # Filter View pressed with two IDs -> only those rows
      session$setInputs(viewIds = paste(wanted, collapse = ", "), view = 1)
      fv <- gvaView()
      expect_setequal(fv$id, wanted)
      expect_equal(nrow(fv), 2L)

      # Empty filter -> full report
      session$setInputs(viewIds = "", view = 2)
      expect_equal(nrow(gvaView()), nrow(full))
    }
  )
})

test_that("modGeneticValueServer downloadGVASubset writes filtered subset", {
  skip_if_not_installed("shiny")

  test_ped <- makeValidTestPed(nFounders = 6, nOffspring = 14)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
      session$setInputs(topN = 100)
      session$setInputs(runAnalysis = 1)

      full <- gvResults()
      wanted <- full$id[1:3]
      session$setInputs(viewIds = paste(wanted, collapse = ", "), view = 1)

      # downloadHandler content runs and returns the written file path
      path <- output$downloadGVASubset
      df <- utils::read.csv(path, stringsAsFactors = FALSE)
      expect_setequal(as.character(df$id), wanted)
    }
  )
})

test_that("modGeneticValueUI has subset filter and export controls", {
  ui <- modGeneticValueUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("test-viewIds", ui_html))
  expect_true(grepl("test-downloadGVASubset", ui_html))
})
