# Tests for modBreedingGroups.R - Breeding Group Formation Shiny Module

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

      # Each group should be a data frame with expected columns
      for (group in groups) {
        expect_true(is.data.frame(group))
        expect_true("group" %in% names(group))
        expect_true("id" %in% names(group))
        expect_true("sex" %in% names(group))
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

test_that("modBreedingGroupsServer unassigned reactive returns NULL initially", {
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
        maxKinship = 0.25,
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      # Current implementation returns NULL for unassigned
      expect_null(result$unassigned())
    }
  )
})

# =============================================================================
# Server Tests - Edge Cases
# =============================================================================

test_that("modBreedingGroupsServer handles small pedigree", {
  skip_if_not_installed("shiny")

  test_ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
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

test_that("modBreedingGroupsServer handles large pedigree", {
  skip_if_not_installed("shiny")

  n <- 200
  test_ped <- data.frame(
    id = paste0("Animal", seq_len(n)),
    sire = rep(NA, n),
    dam = rep(NA, n),
    sex = rep(c("M", "F"), length.out = n),
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
