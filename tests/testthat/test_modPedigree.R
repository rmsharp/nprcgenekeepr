# Tests for modPedigree.R - Pedigree Browser Shiny Module

test_that("modPedigreeUI returns a shiny.tag object", {
  ui <- modPedigreeUI("test")
  expect_true(inherits(ui, "shiny.tag"))
})

test_that("modPedigreeUI contains expected heading", {
  ui <- modPedigreeUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("Pedigree Browser", ui_html))
})

test_that("modPedigreeUI has focal animal section", {
  ui <- modPedigreeUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("Focal Animals", ui_html))
  expect_true(grepl("focalAnimalIds", ui_html))
  expect_true(grepl("focalAnimalFile", ui_html))
  expect_true(grepl("updateFocalAnimals", ui_html))
  expect_true(grepl("clearFocalAnimals", ui_html))
})

test_that("modPedigreeUI has display options", {
  ui <- modPedigreeUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("Display Options", ui_html))
  expect_true(grepl("displayUnknownIds", ui_html))
  expect_true(grepl("trimPedigree", ui_html))
})

test_that("modPedigreeUI has export button", {
  ui <- modPedigreeUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("exportPedigree", ui_html))
  expect_true(grepl("Export Pedigree", ui_html))
})

test_that("modPedigreeUI has pedigree table output", {
  ui <- modPedigreeUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("pedigreeTable", ui_html))
})

test_that("modPedigreeUI uses correct namespace", {
  ui <- modPedigreeUI("pedNS")
  ui_html <- as.character(ui)

  expect_true(grepl("pedNS-focalAnimalIds", ui_html))
  expect_true(grepl("pedNS-updateFocalAnimals", ui_html))
  expect_true(grepl("pedNS-displayUnknownIds", ui_html))
})

test_that("modPedigreeUI includes guidance HTML content", {
  ui <- modPedigreeUI("test")
  ui_html <- as.character(ui)

  # Check for actual content from the guidance HTML
  expect_true(grepl("processed pedigree file", ui_html, ignore.case = TRUE) ||
                grepl("Ego ID", ui_html))
})

test_that("modPedigreeServer returns expected reactive list", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = c("A", "B", "C", "D", "E"),
    sire = c(NA, NA, "A", "A", "B"),
    dam = c(NA, NA, "B", NA, NA),
    sex = c("M", "F", "F", "M", "F"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook }),
      config = NULL
    ),
    {
      # Initialize required inputs
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )

      # Check return value structure
      result <- session$getReturned()
      expect_true(is.list(result))

      expect_true("pedigree" %in% names(result))
      expect_true("focalAnimals" %in% names(result))
      expect_true("nAnimals" %in% names(result))
      expect_true("isReady" %in% names(result))

      # Each component should be reactive
      expect_true(is.function(result$pedigree))
      expect_true(is.function(result$focalAnimals))
      expect_true(is.function(result$nAnimals))
      expect_true(is.function(result$isReady))
    }
  )
})

test_that("modPedigreeServer returns correct pedigree data", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = c("A", "B", "C", "U1", "U2"),
    sire = c(NA, NA, "A", NA, NA),
    dam = c(NA, NA, "B", NA, NA),
    sex = c("M", "F", "F", "M", "F"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook }),
      config = NULL
    ),
    {
      # With unknown IDs displayed
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )

      result <- session$getReturned()
      ped <- result$pedigree()

      expect_equal(nrow(ped), 5)
      expect_true(all(c("A", "B", "C", "U1", "U2") %in% ped$id))
    }
  )
})

test_that("modPedigreeServer filters unknown IDs correctly", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = c("A", "B", "C", "U1", "U2"),
    sire = c(NA, NA, "A", NA, NA),
    dam = c(NA, NA, "B", NA, NA),
    sex = c("M", "F", "F", "M", "F"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook }),
      config = NULL
    ),
    {
      # With unknown IDs hidden
      session$setInputs(
        displayUnknownIds = FALSE,
        trimPedigree = FALSE
      )

      result <- session$getReturned()
      ped <- result$pedigree()

      expect_equal(nrow(ped), 3)
      expect_true(all(c("A", "B", "C") %in% ped$id))
      expect_false(any(c("U1", "U2") %in% ped$id))
    }
  )
})

test_that("modPedigreeServer returns correct animal count", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = paste0("Animal", 1:10),
    sire = rep(NA, 10),
    dam = rep(NA, 10),
    sex = rep(c("M", "F"), 5),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook }),
      config = NULL
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )

      result <- session$getReturned()
      expect_equal(result$nAnimals(), 10)
    }
  )
})

test_that("modPedigreeServer focal animals starts empty", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook }),
      config = NULL
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )

      result <- session$getReturned()
      focal <- result$focalAnimals()

      expect_equal(length(focal), 0)
      expect_true(is.character(focal))
    }
  )
})

test_that("modPedigreeServer isReady returns correct status", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook }),
      config = NULL
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )

      result <- session$getReturned()
      expect_true(result$isReady())
    }
  )
})
