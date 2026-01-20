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
