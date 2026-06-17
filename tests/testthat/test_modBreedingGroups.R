# Tests for modBreedingGroups.R - Breeding Group Formation Shiny Module

# Slow shiny-module integration tests (many shiny::testServer() calls); skip on
# CRAN to keep check elapsed time within limits. They still run on CI and
# locally. The analytical functions exercised here have their own unit tests.
testthat::skip_on_cran()

test_that("modBreedingGroupsUI returns a shiny.tag object", {
  ui <- modBreedingGroupsUI("test")
  expect_true(inherits(ui, "shiny.tag"))
})
test_that("modBreedingGroupsUI contains expected elements", {
  ui <- modBreedingGroupsUI("test")
  ui_html <- as.character(ui)

  # Check for main heading

  expect_true(grepl("Breeding Group Formation", ui_html))

  # Check for configuration panel elements
  expect_true(grepl("Configuration", ui_html))
  expect_true(grepl("animalSource", ui_html))
  expect_true(grepl("nGroups", ui_html))
  expect_true(grepl("maxKinship", ui_html))
  expect_true(grepl("sexRatio", ui_html))

  # Check for action button
 expect_true(grepl("formGroups", ui_html))

  # Check for tabs
  expect_true(grepl("Groups", ui_html))
  expect_true(grepl("Statistics", ui_html))
})

test_that("modBreedingGroupsUI uses correct namespace", {
  ui <- modBreedingGroupsUI("myNamespace")
  ui_html <- as.character(ui)

  # Input IDs should be namespaced
  expect_true(grepl("myNamespace-animalSource", ui_html))
  expect_true(grepl("myNamespace-nGroups", ui_html))
  expect_true(grepl("myNamespace-formGroups", ui_html))
})

test_that("modBreedingGroupsUI includes guidance HTML content", {
  ui <- modBreedingGroupsUI("test")
  ui_html <- as.character(ui)

 # Check for content from the guidance HTML file
  expect_true(grepl("group formation simulation", ui_html, ignore.case = TRUE) ||
                grepl("Kinship and Age Thresholds", ui_html))
})

test_that("modBreedingGroupsServer returns expected reactive list", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({
        data.frame(
          id = c("A", "B", "C", "D", "E"),
          sire = c(NA, NA, "A", "A", "B"),
          dam = c(NA, NA, "B", NA, NA),
          sex = c("M", "F", "F", "M", "F"),
          stringsAsFactors = FALSE
        )
      }),
      geneticValues = NULL
    ),
    {
      # Check that return value is a list with expected components
      result <- session$getReturned()
      expect_true(is.list(result))
      expect_true("groups" %in% names(result))
      expect_true("nGroups" %in% names(result))
      expect_true("unassigned" %in% names(result))

      # Each component should be reactive
      expect_true(is.function(result$groups))
      expect_true(is.function(result$nGroups))
      expect_true(is.function(result$unassigned))
    }
  )
})

test_that("modBreedingGroupsServer handles different animal sources", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:10),
    sire = c(rep(NA, 5), paste0("Animal", 1:5)),
    dam = c(rep(NA, 5), paste0("Animal", 6:10)),
    sex = rep(c("M", "F"), 5),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      # Test with "all" animal source
      session$setInputs(animalSource = "all")
      expect_equal(input$animalSource, "all")

      # Test with numeric inputs
      session$setInputs(nGroups = 5)
      expect_equal(input$nGroups, 5)

      session$setInputs(maxKinship = 0.15)
      expect_equal(input$maxKinship, 0.15)
    }
  )
})

# =============================================================================
# Server Tests - Group Formation Event
# =============================================================================

test_that("modBreedingGroupsServer forms groups on button click", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:20),
    sire = rep(NA, 20),
    dam = rep(NA, 20),
    sex = rep(c("M", "F"), 10),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      # Set inputs
      session$setInputs(
        animalSource = "all",
        nGroups = 3,
        maxKinship = 0.25,
        sexRatio = "none"
      )

      # Trigger group formation
      session$setInputs(formGroups = 1)

      # Check that groups were formed
      result <- session$getReturned()
      groups <- result$groups()

      expect_true(is.list(groups))
      expect_equal(length(groups), 3)
    }
  )
})

test_that("modBreedingGroupsServer forms groups with topRanked source", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:30),
    sire = rep(NA, 30),
    dam = rep(NA, 30),
    sex = rep(c("M", "F"), 15),
    stringsAsFactors = FALSE
  )

  test_gv <- data.frame(
    id = paste0("Animal", 1:30),
    meanKinship = runif(30, 0.05, 0.4),
    genomeUniqueness = runif(30, 0.5, 1.0),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = shiny::reactive({ test_gv })
    ),
    {
      session$setInputs(
        animalSource = "topRanked",
        nTopAnimals = 20,
        nGroups = 4,
        maxKinship = 0.25,
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      groups <- result$groups()

      expect_true(is.list(groups))
      expect_equal(length(groups), 4)
    }
  )
})

# =============================================================================
# Server Tests - Input Variations
# =============================================================================

test_that("modBreedingGroupsServer handles minimum number of groups", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:10),
    sire = rep(NA, 10),
    dam = rep(NA, 10),
    sex = rep(c("M", "F"), 5),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all",
        nGroups = 1,
        maxKinship = 0.25,
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      expect_equal(result$nGroups(), 1)
    }
  )
})

test_that("modBreedingGroupsServer handles maximum number of groups", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:50),
    sire = rep(NA, 50),
    dam = rep(NA, 50),
    sex = rep(c("M", "F"), 25),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all",
        nGroups = 20,
        maxKinship = 0.25,
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      expect_equal(result$nGroups(), 20)
    }
  )
})

test_that("modBreedingGroupsServer handles different maxKinship values", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:15),
    sire = rep(NA, 15),
    dam = rep(NA, 15),
    sex = rep(c("M", "F", "M"), 5),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      # Test with low kinship threshold
      session$setInputs(
        animalSource = "all",
        nGroups = 3,
        maxKinship = 0.05,
        sexRatio = "none"
      )
      expect_equal(input$maxKinship, 0.05)

      # Test with high kinship threshold
      session$setInputs(maxKinship = 0.45)
      expect_equal(input$maxKinship, 0.45)
    }
  )
})

test_that("modBreedingGroupsServer handles harem sex ratio", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:20),
    sire = rep(NA, 20),
    dam = rep(NA, 20),
    sex = rep(c("M", "F"), 10),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all",
        nGroups = 3,
        maxKinship = 0.25,
        sexRatio = "harem"
      )

      expect_equal(input$sexRatio, "harem")

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      expect_true(is.list(result$groups()))
    }
  )
})

test_that("modBreedingGroupsServer handles custom sex ratio", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:20),
    sire = rep(NA, 20),
    dam = rep(NA, 20),
    sex = rep(c("M", "F"), 10),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all",
        nGroups = 3,
        maxKinship = 0.25,
        sexRatio = "custom"
      )

      expect_equal(input$sexRatio, "custom")

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      expect_true(is.list(result$groups()))
    }
  )
})

test_that("modBreedingGroupsServer handles none sex ratio", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:15),
    sire = rep(NA, 15),
    dam = rep(NA, 15),
    sex = rep(c("M", "F", "M"), 5),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all",
        nGroups = 2,
        maxKinship = 0.25,
        sexRatio = "none"
      )

      expect_equal(input$sexRatio, "none")
    }
  )
})

# =============================================================================
# Server Tests - Group Statistics
# =============================================================================

test_that("modBreedingGroupsServer calculates group statistics", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:20),
    sire = rep(NA, 20),
    dam = rep(NA, 20),
    sex = rep(c("M", "F"), 10),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all",
        nGroups = 3,
        maxKinship = 0.25,
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      # groupStats output should be renderable
      expect_no_error(output$groupStats)
    }
  )
})

test_that("modBreedingGroupsServer renders groups display", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:15),
    sire = rep(NA, 15),
    dam = rep(NA, 15),
    sex = rep(c("M", "F", "M"), 5),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all",
        nGroups = 2,
        maxKinship = 0.25,
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      # groupsDisplay output should be renderable
      expect_no_error(output$groupsDisplay)
    }
  )
})

# =============================================================================
# Server Tests - Return Values
# =============================================================================

test_that("modBreedingGroupsServer groups reactive returns correct structure", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:20),
    sire = rep(NA, 20),
    dam = rep(NA, 20),
    sex = rep(c("M", "F"), 10),
    birth = as.Date("2015-01-01"),
    exit = NA,
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all",
        nGroups = 4,
        maxKinship = 0.25,
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      groups <- result$groups()

      # groupAddAssign returns list of character vectors (IDs)
      expect_true(is.list(groups))
      for (group in groups) {
        expect_true(is.character(group),
          label = "Each group should be a character vector of IDs")
        expect_true(all(group %in% test_ped$id),
          label = "All group IDs should exist in pedigree")
      }
    }
  )
})

test_that("modBreedingGroupsServer nGroups reactive matches requested groups", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:25),
    sire = rep(NA, 25),
    dam = rep(NA, 25),
    sex = rep(c("M", "F", "M", "F", "M"), 5),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all",
        nGroups = 5,
        maxKinship = 0.25,
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      expect_equal(result$nGroups(), 5)
    }
  )
})

test_that("modBreedingGroupsServer unassigned reactive returns character vector", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:10),
    sire = rep(NA, 10),
    dam = rep(NA, 10),
    sex = rep(c("M", "F"), 5),
    birth = as.Date("2015-01-01"),
    exit = NA,
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all",
        nGroups = 2,
        maxKinship = 0.25,
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      # unassigned returns character vector (possibly empty) of unassigned IDs
      expect_true(is.character(result$unassigned()))
    }
  )
})

# =============================================================================
# Server Tests - Edge Cases
# =============================================================================

test_that("modBreedingGroupsServer handles small pedigree", {
  skip_if_not_installed("shiny")

  # Valid pedigree with 4 founders and 6 offspring
  test_ped <- data.frame(
    id = c("F1", "F2", "F3", "F4", paste0("O", 1:6)),
    sire = c(NA, NA, NA, NA, "F1", "F1", "F3", "F3", "F1", "F3"),
    dam = c(NA, NA, NA, NA, "F2", "F2", "F4", "F4", "F2", "F4"),
    sex = c("M", "F", "M", "F", "M", "F", "M", "F", "M", "F"),
    birth = as.Date("2015-01-01"),
    exit = NA,
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all",
        nGroups = 1,
        maxKinship = 0.25,
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      expect_gte(result$nGroups(), 1)
    }
  )
})

test_that("modBreedingGroupsServer handles large pedigree", {
  skip_on_cran()
  skip_if_not_installed("shiny")

  n <- 200
  test_ped <- data.frame(
    id = paste0("Animal", seq_len(n)),
    sire = rep(NA, n),
    dam = rep(NA, n),
    sex = rep(c("M", "F"), length.out = n),
    birth = as.Date("2015-01-01"),
    exit = NA,
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all",
        nGroups = 10,
        maxKinship = 0.25,
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      expect_equal(result$nGroups(), 10)
    }
  )
})

test_that("modBreedingGroupsServer handles all male pedigree", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Male", 1:10),
    sire = rep(NA, 10),
    dam = rep(NA, 10),
    sex = rep("M", 10),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all",
        nGroups = 2,
        maxKinship = 0.25,
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      groups <- result$groups()

      # Should still form groups even with all males
      expect_true(is.list(groups))
    }
  )
})

test_that("modBreedingGroupsServer handles all female pedigree", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Female", 1:10),
    sire = rep(NA, 10),
    dam = rep(NA, 10),
    sex = rep("F", 10),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all",
        nGroups = 2,
        maxKinship = 0.25,
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      groups <- result$groups()

      # Should still form groups even with all females
      expect_true(is.list(groups))
    }
  )
})

# =============================================================================
# Server Tests - nTopAnimals Parameter
# =============================================================================

test_that("modBreedingGroupsServer respects nTopAnimals parameter", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:50),
    sire = rep(NA, 50),
    dam = rep(NA, 50),
    sex = rep(c("M", "F"), 25),
    stringsAsFactors = FALSE
  )

  test_gv <- data.frame(
    id = paste0("Animal", 1:50),
    meanKinship = runif(50, 0.05, 0.4),
    genomeUniqueness = runif(50, 0.5, 1.0),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = shiny::reactive({ test_gv })
    ),
    {
      session$setInputs(
        animalSource = "topRanked",
        nTopAnimals = 10,
        nGroups = 2,
        maxKinship = 0.25,
        sexRatio = "none"
      )

      expect_equal(input$nTopAnimals, 10)
    }
  )
})

test_that("modBreedingGroupsServer handles minimum nTopAnimals", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:20),
    sire = rep(NA, 20),
    dam = rep(NA, 20),
    sex = rep(c("M", "F"), 10),
    stringsAsFactors = FALSE
  )

  test_gv <- data.frame(
    id = paste0("Animal", 1:20),
    meanKinship = runif(20, 0.05, 0.4),
    genomeUniqueness = runif(20, 0.5, 1.0),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = shiny::reactive({ test_gv })
    ),
    {
      session$setInputs(
        animalSource = "topRanked",
        nTopAnimals = 5,
        nGroups = 1,
        maxKinship = 0.25,
        sexRatio = "none"
      )

      expect_equal(input$nTopAnimals, 5)
    }
  )
})

test_that("modBreedingGroupsServer handles maximum nTopAnimals", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:100),
    sire = rep(NA, 100),
    dam = rep(NA, 100),
    sex = rep(c("M", "F"), 50),
    stringsAsFactors = FALSE
  )

  test_gv <- data.frame(
    id = paste0("Animal", 1:100),
    meanKinship = runif(100, 0.05, 0.4),
    genomeUniqueness = runif(100, 0.5, 1.0),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = shiny::reactive({ test_gv })
    ),
    {
      session$setInputs(
        animalSource = "topRanked",
        nTopAnimals = 100,
        nGroups = 5,
        maxKinship = 0.25,
        sexRatio = "none"
      )

      expect_equal(input$nTopAnimals, 100)
    }
  )
})

# =============================================================================
# Server Tests - Multiple Group Formations
# =============================================================================

test_that("modBreedingGroupsServer handles multiple group formations", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:30),
    sire = rep(NA, 30),
    dam = rep(NA, 30),
    sex = rep(c("M", "F"), 15),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      # First formation
      session$setInputs(
        animalSource = "all",
        nGroups = 3,
        maxKinship = 0.25,
        sexRatio = "none"
      )
      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      expect_equal(result$nGroups(), 3)

      # Second formation with different parameters
      session$setInputs(nGroups = 5)
      session$setInputs(formGroups = 2)

      expect_equal(result$nGroups(), 5)
    }
  )
})

# =============================================================================
# Server Tests - Boundary Kinship Values
# =============================================================================

test_that("modBreedingGroupsServer handles zero kinship threshold", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:10),
    sire = rep(NA, 10),
    dam = rep(NA, 10),
    sex = rep(c("M", "F"), 5),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all",
        nGroups = 2,
        maxKinship = 0,
        sexRatio = "none"
      )

      expect_equal(input$maxKinship, 0)
    }
  )
})

test_that("modBreedingGroupsServer handles maximum kinship threshold", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:10),
    sire = rep(NA, 10),
    dam = rep(NA, 10),
    sex = rep(c("M", "F"), 5),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all",
        nGroups = 2,
        maxKinship = 0.5,
        sexRatio = "none"
      )

      expect_equal(input$maxKinship, 0.5)
    }
  )
})

# =============================================================================
# Phase 5 - Group Detail tab: viewGrp selector, per-group member + kinship
# views, and downloadGroup / downloadGroupKin handlers (parity with monolith
# server.r:1196-1297). Founders give a deterministic kinship submatrix
# (0.5 diagonal / 0 off-diagonal) so assertions are deterministic despite the
# stochastic MIS formation; content assertions key on the ACTUAL formed group.
# =============================================================================

# Founders-with-birth fixture: addSexAndAgeToGroup needs ped$birth (getCurrentAge)
makeBgViewPed <- function(n = 14L) {
  data.frame(
    id = paste0("A", seq_len(n)),
    sire = NA_character_,
    dam = NA_character_,
    sex = rep(c("M", "F"), length.out = n),
    birth = as.Date("2015-01-01") - seq_len(n) * 90L,
    exit = as.Date(NA),
    stringsAsFactors = FALSE
  )
}

test_that("modBreedingGroupsUI has Group Detail tab with selector, views, downloads", {
  ui_html <- as.character(modBreedingGroupsUI("bg"))

  expect_true(grepl("Group Detail", ui_html))
  expect_true(grepl("bg-viewGrp", ui_html))
  expect_true(grepl("bg-groupMemberTable", ui_html))
  expect_true(grepl("bg-groupKinTable", ui_html))
  expect_true(grepl("Export Current Group", ui_html))
  expect_true(grepl("Export Current Group Kinship", ui_html))
})

test_that("downloadGroup writes the selected group's annotated members", {
  skip_if_not_installed("shiny")

  test_ped <- makeBgViewPed(14L)

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all", nGroups = 3, maxKinship = 0.25,
        sexRatio = "none"
      )
      session$setInputs(formGroups = 1)
      session$setInputs(viewGrp = "1")

      grp1 <- session$getReturned()$groups()[[1L]]

      path <- output$downloadGroup
      df <- utils::read.csv(path, check.names = FALSE,
                            stringsAsFactors = FALSE)

      expect_equal(colnames(df), c("Ego ID", "Sex", "Age in Years"))
      expect_setequal(as.character(df[["Ego ID"]]), grp1)
      expect_true(all(df[["Sex"]] %in% c("M", "F")))
      expect_true(is.numeric(df[["Age in Years"]]))
      expect_true(all(df[["Age in Years"]] > 0))
    }
  )
})

test_that("downloadGroupKin writes the group's kinship submatrix (== filterKinMatrix)", {
  skip_if_not_installed("shiny")

  test_ped <- makeBgViewPed(14L)

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all", nGroups = 3, maxKinship = 0.25,
        sexRatio = "none"
      )
      session$setInputs(formGroups = 1)
      session$setInputs(viewGrp = "1")

      grp1 <- session$getReturned()$groups()[[1L]]

      path <- output$downloadGroupKin
      km <- utils::read.csv(path, row.names = 1, check.names = FALSE)

      expect_equal(nrow(km), length(grp1))
      expect_equal(ncol(km), length(grp1))
      expect_setequal(rownames(km), grp1)
      expect_setequal(colnames(km), grp1)

      # Equivalence to filterKinMatrix on the full kinship matrix (the dragon):
      p2 <- test_ped
      p2$gen <- findGeneration(p2$id, p2$sire, p2$dam)
      fullk <- kinship(p2$id, p2$sire, p2$dam, p2$gen)
      expected <- as.matrix(filterKinMatrix(grp1, fullk))
      got <- as.matrix(km)[rownames(expected), colnames(expected), drop = FALSE]
      expect_equal(round(unname(got), 6), round(unname(expected), 6))
    }
  )
})

test_that("viewGrp selector switches the displayed group", {
  skip_if_not_installed("shiny")

  test_ped <- makeBgViewPed(14L)

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all", nGroups = 3, maxKinship = 0.25,
        sexRatio = "none"
      )
      session$setInputs(formGroups = 1)
      session$setInputs(viewGrp = "2")

      grp2 <- session$getReturned()$groups()[[2L]]
      df <- utils::read.csv(output$downloadGroup, check.names = FALSE,
                            stringsAsFactors = FALSE)
      expect_setequal(as.character(df[["Ego ID"]]), grp2)
    }
  )
})

test_that("viewGrp out-of-range selection clamps to the last group", {
  skip_if_not_installed("shiny")

  test_ped <- makeBgViewPed(14L)

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all", nGroups = 3, maxKinship = 0.25,
        sexRatio = "none"
      )
      session$setInputs(formGroups = 1)
      session$setInputs(viewGrp = "99")

      gs <- session$getReturned()$groups()
      lastGrp <- gs[[length(gs)]]
      df <- utils::read.csv(output$downloadGroup, check.names = FALSE,
                            stringsAsFactors = FALSE)
      expect_setequal(as.character(df[["Ego ID"]]), lastGrp)
    }
  )
})

# =============================================================================
# Phase 6 - Breeding Groups parity B: seed-group "current groups" widget +
# expose the inert minAge / nIterations / withKinship controls + breeding-sim
# iteration default 1000 -> 10 (monolith gpIter value=10L). Parity with
# monolith server.r:1019-1056 (textAreaWidget/getCurrentGroups) and
# uitpBreedingGroupFormation.R:88-93,152-161. The new UI control ids match the
# ids the server already reads (minAge/nIterations/withKinship), NOT the
# monolith's gpIter/withKin. The founders fixture makeBgViewPed (all unrelated:
# kinship 0.5 diag / 0 off-diag, has birth/exit) makes formation deterministic
# under set.seed across the testServer eventReactive boundary (Learning #26a).
# =============================================================================

test_that("modBreedingGroupsUI exposes seedGroups + minAge/nIterations/withKinship controls", {
  ui_html <- as.character(modBreedingGroupsUI("bg"))

  expect_true(grepl("bg-seedGroups", ui_html))    # R1: seed-group widget gate
  expect_true(grepl("bg-minAge", ui_html))        # R2: previously-inert control
  expect_true(grepl("bg-nIterations", ui_html))   # R2
  expect_true(grepl("bg-withKinship", ui_html))   # R2
})

test_that("modBreedingGroupsUI nIterations default renders value 10, not 1000", {
  ui_html <- as.character(modBreedingGroupsUI("bg"))

  # R3: exact rendered token (avoid the bare-number substring trap, Learning
  # #24b). max="1000000" does not contain value="1000"; value="10" matches only
  # an exact value of 10.
  expect_true(grepl('value="10"', ui_html, fixed = TRUE))
  expect_false(grepl('value="1000"', ui_html, fixed = TRUE))
})

test_that("seed-group widget seeds the specified animals into their group", {
  skip_if_not_installed("shiny")

  test_ped <- makeBgViewPed(14L)

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all", nGroups = 3, maxKinship = 0.25,
        sexRatio = "none", seedGroups = TRUE, curGrp1 = "A1, A2 A3"
      )
      set.seed(42)
      session$setInputs(formGroups = 1)

      # R4: all three seeded animals land in group 1 (deterministic under the
      # seed; at HEAD the seeds are ignored and they do not all land in group 1).
      g <- session$getReturned()$groups()
      expect_true(all(c("A1", "A2", "A3") %in% g[[1L]]))
    }
  )
})

test_that("seed-group widget honors groups beyond the first (not the monolith curGrp1-only bug)", {
  skip_if_not_installed("shiny")

  test_ped <- makeBgViewPed(14L)

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all", nGroups = 3, maxKinship = 0.25,
        sexRatio = "none", seedGroups = TRUE,
        curGrp1 = "A1", curGrp2 = "A2"
      )
      # seed 7: at HEAD (seeds ignored) neither A1 lands in g1 nor A2 in g2, so
      # this fails at HEAD and only passes once both seeds are honored.
      set.seed(7)
      session$setInputs(formGroups = 1)

      # R5: the monolith getCurrentGroups reads only curGrp1 (seq_along bug);
      # the modular widget must honor every seed textarea.
      g <- session$getReturned()$groups()
      expect_true("A1" %in% g[[1L]])
      expect_true("A2" %in% g[[2L]])
    }
  )
})

test_that("seed ids not in the pedigree block formation (validate-and-block)", {
  skip_if_not_installed("shiny")

  test_ped <- makeBgViewPed(14L)

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all", nGroups = 3, maxKinship = 0.25,
        sexRatio = "none", seedGroups = TRUE, curGrp1 = "ZZZ_NOT_IN_PED"
      )
      session$setInputs(formGroups = 1)

      # R6 (dragon): a phantom seed id silently survives into the group and
      # crashes the Phase-5 member view (addSexAndAgeToGroup -> getCurrentAge on
      # a length-0 birth). Validate-and-block must abort formation instead.
      g <- session$getReturned()$groups()
      expect_equal(length(g), 0L)
    }
  )
})

test_that("blank seed textareas behave exactly like no seeding", {
  skip_if_not_installed("shiny")

  test_ped <- makeBgViewPed(14L)

  formWith <- function(seedGroups, curGrp1) {
    out <- NULL
    shiny::testServer(
      modBreedingGroupsServer,
      args = list(
        pedigree = shiny::reactive({ test_ped }),
        geneticValues = NULL
      ),
      {
        session$setInputs(
          animalSource = "all", nGroups = 3, maxKinship = 0.25,
          sexRatio = "none", seedGroups = seedGroups, curGrp1 = curGrp1
        )
        set.seed(99)
        session$setInputs(formGroups = 1)
        out <<- lapply(session$getReturned()$groups(), sort)
      }
    )
    out
  }

  # Green-at-HEAD coverage (NOT a RED): a whitespace-only seed must parse to
  # character(0) so formation is identical to the unseeded run at the same seed.
  expect_equal(formWith(TRUE, "   "), formWith(FALSE, ""))
})

test_that("withKinship=TRUE threads through to a non-NULL per-group kinship", {
  skip_if_not_installed("shiny")

  test_ped <- makeBgViewPed(14L)

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      session$setInputs(
        animalSource = "all", nGroups = 3, maxKinship = 0.25,
        sexRatio = "none", withKinship = TRUE
      )
      session$setInputs(formGroups = 1)

      # Green-at-HEAD regression (NOT a RED): the server already reads
      # input$withKinship (L203), so setting it TRUE flips groupKinship()
      # non-NULL even at HEAD. The DISCRIMINATING withKinship RED is the
      # UI-control-presence assertion (R2) above.
      expect_false(is.null(session$getReturned()$groupKinship()))
    }
  )
})

# ============================================================================
# 8e-5: env/option-gated set_seed() determinism hook (issue #40)
# Browser-free (testServer) specification of the Option-A gate placed at the
# top of the breedingGroups eventReactive:
#   seed <- getOption("nprcgenekeepr.bg_seed",
#                     as.integer(Sys.getenv("NPRC_BG_SEED", NA)))
#   if (!is.na(seed)) set_seed(seed)
# Gate unset => no-op => default group-formation path unchanged.
# ============================================================================

test_that("modBreedingGroupsServer: bg_seed option makes group formation deterministic", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:20),
    sire = rep(NA, 20),
    dam = rep(NA, 20),
    sex = rep(c("M", "F"), 10),
    stringsAsFactors = FALSE
  )
  old_opts <- options(nprcgenekeepr.bg_seed = 42L)
  on.exit(options(old_opts), add = TRUE)
  Sys.unsetenv("NPRC_BG_SEED")

  groupsA <- NULL
  groupsB <- NULL
  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({ test_ped }), geneticValues = NULL),
    {
      session$setInputs(animalSource = "all", nGroups = 3,
                        maxKinship = 0.25, sexRatio = "none")
      session$setInputs(formGroups = 1)
      groupsA <<- session$getReturned()$groups()
    }
  )
  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({ test_ped }), geneticValues = NULL),
    {
      session$setInputs(animalSource = "all", nGroups = 3,
                        maxKinship = 0.25, sexRatio = "none")
      session$setInputs(formGroups = 1)
      groupsB <<- session$getReturned()$groups()
    }
  )

  # Capture must be non-vacuous (a true comparison, not NULL == NULL).
  expect_true(length(groupsA) > 0L)
  expect_identical(groupsA, groupsB)
})

test_that("modBreedingGroupsServer: bg_seed option triggers set_seed with that seed", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:20),
    sire = rep(NA, 20),
    dam = rep(NA, 20),
    sex = rep(c("M", "F"), 10),
    stringsAsFactors = FALSE
  )
  recorder <- new.env(parent = emptyenv())
  recorder$called <- FALSE
  recorder$seed <- NULL
  local_mocked_bindings(
    set_seed = function(seed = 1L) {
      recorder$called <- TRUE
      recorder$seed <- seed
      invisible(NULL)
    }
  )
  old_opts <- options(nprcgenekeepr.bg_seed = 42L)
  on.exit(options(old_opts), add = TRUE)
  Sys.unsetenv("NPRC_BG_SEED")

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({ test_ped }), geneticValues = NULL),
    {
      session$setInputs(animalSource = "all", nGroups = 3,
                        maxKinship = 0.25, sexRatio = "none")
      session$setInputs(formGroups = 1)
      session$getReturned()$groups()
    }
  )

  expect_true(recorder$called)
  expect_equal(recorder$seed, 42L)
})

test_that("modBreedingGroupsServer: no seed set => set_seed is NOT called (default path)", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:20),
    sire = rep(NA, 20),
    dam = rep(NA, 20),
    sex = rep(c("M", "F"), 10),
    stringsAsFactors = FALSE
  )
  recorder <- new.env(parent = emptyenv())
  recorder$called <- FALSE
  local_mocked_bindings(
    set_seed = function(seed = 1L) {
      recorder$called <- TRUE
      invisible(NULL)
    }
  )
  old_opts <- options(nprcgenekeepr.bg_seed = NULL)
  on.exit(options(old_opts), add = TRUE)
  Sys.unsetenv("NPRC_BG_SEED")

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({ test_ped }), geneticValues = NULL),
    {
      session$setInputs(animalSource = "all", nGroups = 3,
                        maxKinship = 0.25, sexRatio = "none")
      session$setInputs(formGroups = 1)
      session$getReturned()$groups()
    }
  )

  expect_false(recorder$called)
})

test_that("modBreedingGroupsServer: NPRC_BG_SEED env var is read when option absent", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = paste0("Animal", 1:20),
    sire = rep(NA, 20),
    dam = rep(NA, 20),
    sex = rep(c("M", "F"), 10),
    stringsAsFactors = FALSE
  )
  recorder <- new.env(parent = emptyenv())
  recorder$called <- FALSE
  recorder$seed <- NULL
  local_mocked_bindings(
    set_seed = function(seed = 1L) {
      recorder$called <- TRUE
      recorder$seed <- seed
      invisible(NULL)
    }
  )
  old_opts <- options(nprcgenekeepr.bg_seed = NULL)
  on.exit(options(old_opts), add = TRUE)
  Sys.setenv(NPRC_BG_SEED = "7")
  on.exit(Sys.unsetenv("NPRC_BG_SEED"), add = TRUE)

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({ test_ped }), geneticValues = NULL),
    {
      session$setInputs(animalSource = "all", nGroups = 3,
                        maxKinship = 0.25, sexRatio = "none")
      session$setInputs(formGroups = 1)
      session$getReturned()$groups()
    }
  )

  expect_true(recorder$called)
  expect_equal(recorder$seed, 7L)
})
