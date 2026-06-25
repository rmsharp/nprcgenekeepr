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

test_that("modPedigreeServer parses focal animal IDs from text area", {
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
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE,
        focalAnimalIds = "A, B, C"
      )

      # Trigger the update
      session$setInputs(updateFocalAnimals = 1)

      result <- session$getReturned()
      focal <- result$focalAnimals()

      expect_equal(length(focal), 3)
      expect_true(all(c("A", "B", "C") %in% focal))
    }
  )
})

test_that("modPedigreeServer parses focal IDs with various separators", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = paste0("Animal", 1:5),
    sire = rep(NA, 5),
    dam = rep(NA, 5),
    sex = rep("M", 5),
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
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE
      )

      # Test newline-separated IDs
      session$setInputs(focalAnimalIds = "Animal1\nAnimal2\nAnimal3")
      session$setInputs(updateFocalAnimals = 1)

      result <- session$getReturned()
      focal <- result$focalAnimals()

      expect_equal(length(focal), 3)
      expect_true(all(c("Animal1", "Animal2", "Animal3") %in% focal))
    }
  )
})

test_that("modPedigreeServer parses focal IDs with semicolon separator", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = paste0("ID", 1:5),
    sire = rep(NA, 5),
    dam = rep(NA, 5),
    sex = rep("M", 5),
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
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE,
        focalAnimalIds = "ID1;ID2;ID3"
      )

      session$setInputs(updateFocalAnimals = 1)

      result <- session$getReturned()
      focal <- result$focalAnimals()

      expect_equal(length(focal), 3)
      expect_true(all(c("ID1", "ID2", "ID3") %in% focal))
    }
  )
})

test_that("modPedigreeServer clearFocalAnimals clears IDs when TRUE", {
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
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE,
        focalAnimalIds = "A, B"
      )

      # First add some focal animals
      session$setInputs(updateFocalAnimals = 1)

      result <- session$getReturned()
      expect_equal(length(result$focalAnimals()), 2)

      # Now set clearFocalAnimals to TRUE and trigger update
      session$setInputs(clearFocalAnimals = TRUE)
      session$setInputs(updateFocalAnimals = 2)

      # Focal animals should now be cleared
      focal <- result$focalAnimals()
      expect_equal(length(focal), 0)
    }
  )
})

test_that("modPedigreeServer trims pedigree based on focal animals", {
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
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE,
        focalAnimalIds = "A, C"
      )

      # Add focal animals
      session$setInputs(updateFocalAnimals = 1)

      # Now enable trim
      session$setInputs(trimPedigree = TRUE)

      result <- session$getReturned()
      ped <- result$pedigree()

      # With trimming enabled, should include focal animals, their ancestors,
      # AND their descendants. A and C are focal; B is dam of C (ancestor);
      # D is a child of A (descendant). E is a half-sib of C (collateral) and
      # not a descendant of any focal animal, so it is excluded.
      expect_equal(nrow(ped), 4)
      expect_true(all(c("A", "B", "C", "D") %in% ped$id))
      expect_false("E" %in% ped$id)
    }
  )
})

test_that("modPedigreeServer handles empty focal animal text", {
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
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE,
        focalAnimalIds = ""
      )

      session$setInputs(updateFocalAnimals = 1)

      result <- session$getReturned()
      focal <- result$focalAnimals()

      # Empty text should result in no focal animals
      expect_equal(length(focal), 0)
    }
  )
})

test_that("modPedigreeServer handles whitespace-only focal animal text", {
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
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE,
        focalAnimalIds = "   \n\t  "
      )

      session$setInputs(updateFocalAnimals = 1)

      result <- session$getReturned()
      focal <- result$focalAnimals()

      # Whitespace-only should result in no focal animals
      expect_equal(length(focal), 0)
    }
  )
})

test_that("modPedigreeServer trims whitespace from focal IDs", {
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
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE,
        focalAnimalIds = "  A  ,  B  ,  C  "
      )

      session$setInputs(updateFocalAnimals = 1)

      result <- session$getReturned()
      focal <- result$focalAnimals()

      expect_equal(length(focal), 3)
      # IDs should be trimmed, not have extra whitespace
      expect_true("A" %in% focal)
      expect_true("B" %in% focal)
      expect_true("C" %in% focal)
      expect_false("  A  " %in% focal)
    }
  )
})

test_that("modPedigreeServer deduplicates focal animal IDs", {
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
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE,
        focalAnimalIds = "A, A, B, B, C"
      )

      session$setInputs(updateFocalAnimals = 1)

      result <- session$getReturned()
      focal <- result$focalAnimals()

      # Duplicates should be removed
      expect_equal(length(focal), 3)
    }
  )
})

test_that("modPedigreeServer handles tab-separated focal IDs", {
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
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE,
        focalAnimalIds = "A\tB\tC"
      )

      session$setInputs(updateFocalAnimals = 1)

      result <- session$getReturned()
      focal <- result$focalAnimals()

      expect_equal(length(focal), 3)
      expect_true(all(c("A", "B", "C") %in% focal))
    }
  )
})

test_that("modPedigreeServer trim with no focal animals shows full pedigree", {
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
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = TRUE,  # Trim enabled but no focal animals
        clearFocalAnimals = FALSE,
        focalAnimalIds = ""
      )

      result <- session$getReturned()
      ped <- result$pedigree()

      # With no focal animals, trimPedigree should show full pedigree
      expect_equal(nrow(ped), 5)
    }
  )
})

test_that("modPedigreeServer focal animal file handling", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = c("A", "B", "C", "D", "E"),
    sire = c(NA, NA, "A", "A", "B"),
    dam = c(NA, NA, "B", NA, NA),
    sex = c("M", "F", "F", "M", "F"),
    stringsAsFactors = FALSE
  )

  # Create a temporary CSV file with focal animal IDs
  temp_file <- tempfile(fileext = ".csv")
  write.csv(data.frame(id = c("A", "B")), temp_file, row.names = FALSE)

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook }),
      config = NULL
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE,
        focalAnimalIds = ""
      )

      # Simulate file upload
      session$setInputs(
        focalAnimalFile = list(
          datapath = temp_file,
          name = "focal_animals.csv"
        )
      )

      session$setInputs(updateFocalAnimals = 1)

      result <- session$getReturned()
      focal <- result$focalAnimals()

      expect_equal(length(focal), 2)
      expect_true(all(c("A", "B") %in% focal))
    }
  )

  # Clean up
  unlink(temp_file)
})

test_that("modPedigreeServer combines text and file focal IDs", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = c("A", "B", "C", "D", "E"),
    sire = c(NA, NA, "A", "A", "B"),
    dam = c(NA, NA, "B", NA, NA),
    sex = c("M", "F", "F", "M", "F"),
    stringsAsFactors = FALSE
  )

  # Create temp file with some IDs
  temp_file <- tempfile(fileext = ".csv")
  write.csv(data.frame(id = c("D", "E")), temp_file, row.names = FALSE)

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook }),
      config = NULL
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE,
        focalAnimalIds = "A, B, C"
      )

      # Simulate file upload
      session$setInputs(
        focalAnimalFile = list(
          datapath = temp_file,
          name = "focal_animals.csv"
        )
      )

      session$setInputs(updateFocalAnimals = 1)

      result <- session$getReturned()
      focal <- result$focalAnimals()

      # Should have IDs from both text and file, deduplicated
      expect_equal(length(focal), 5)
      expect_true(all(c("A", "B", "C", "D", "E") %in% focal))
    }
  )

  unlink(temp_file)
})

test_that("modPedigreeServer handles trim with non-matching focal IDs", {
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
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE,
        focalAnimalIds = "X, Y, Z"  # IDs that don't exist in pedigree
      )

      session$setInputs(updateFocalAnimals = 1)

      # Enable trim
      session$setInputs(trimPedigree = TRUE)

      result <- session$getReturned()
      ped <- result$pedigree()

      # No matching focal animals should result in full pedigree
      expect_equal(nrow(ped), 3)
    }
  )
})

# ---------------------------------------------------------------------------
# Issue #1: "Clear Focal Animals" must also forget the uploaded file and the
# typed text, so neither is silently re-read on the next "Update Focal Animals"
# click, and the file-input widget (with its displayed file name) is reset.
# ---------------------------------------------------------------------------

test_that("modPedigreeServer cleared file is not re-read on the next update", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    stringsAsFactors = FALSE
  )

  temp_file <- tempfile(fileext = ".csv")
  write.csv(data.frame(id = c("A", "B")), temp_file, row.names = FALSE)

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook }),
      config = NULL
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE,
        focalAnimalIds = "",
        focalAnimalFile = list(datapath = temp_file, name = "focal.csv")
      )
      session$setInputs(updateFocalAnimals = 1)

      result <- session$getReturned()
      expect_equal(length(result$focalAnimals()), 2)

      # Clear, then update with the clear box checked.
      session$setInputs(clearFocalAnimals = TRUE)
      session$setInputs(updateFocalAnimals = 2)
      expect_equal(length(result$focalAnimals()), 0)

      # Uncheck clear; the file input still holds the same file (the browser
      # has not been reset). The next update must NOT re-read the cleared file.
      session$setInputs(clearFocalAnimals = FALSE)
      session$setInputs(updateFocalAnimals = 3)
      expect_equal(length(result$focalAnimals()), 0)
    }
  )

  unlink(temp_file)
})

test_that("modPedigreeServer cleared text is not re-read on the next update", {
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
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE,
        focalAnimalIds = "A, B"
      )
      session$setInputs(updateFocalAnimals = 1)

      result <- session$getReturned()
      expect_equal(length(result$focalAnimals()), 2)

      session$setInputs(clearFocalAnimals = TRUE)
      session$setInputs(updateFocalAnimals = 2)
      expect_equal(length(result$focalAnimals()), 0)

      # Uncheck clear; the textarea still holds the same text. The next update
      # must NOT re-read the cleared text.
      session$setInputs(clearFocalAnimals = FALSE)
      session$setInputs(updateFocalAnimals = 3)
      expect_equal(length(result$focalAnimals()), 0)
    }
  )
})

test_that("modPedigreeUI delegates the focal file input to a dynamic uiOutput", {
  skip_if_not_installed("shiny")

  ui_html <- as.character(modPedigreeUI("test"))

  # The file input is rendered server-side (via renderUI) so it can be reset
  # without a client-side dependency; it is no longer a static widget.
  expect_false(grepl("type=\"file\"", ui_html, fixed = TRUE))
  # A uiOutput placeholder for the dynamic file input is present.
  expect_true(grepl("focalAnimalFileUI", ui_html))
})

test_that("modPedigreeServer loads a newly chosen file after a clear", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = c("A", "B", "C", "D"),
    sire = c(NA, NA, "A", "A"),
    dam = c(NA, NA, "B", "B"),
    sex = c("M", "F", "F", "M"),
    stringsAsFactors = FALSE
  )

  file1 <- tempfile(fileext = ".csv")
  write.csv(data.frame(id = c("A", "B")), file1, row.names = FALSE)
  file2 <- tempfile(fileext = ".csv")
  write.csv(data.frame(id = c("C", "D")), file2, row.names = FALSE)

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook }),
      config = NULL
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE,
        focalAnimalIds = "",
        focalAnimalFile = list(datapath = file1, name = "file1.csv")
      )
      session$setInputs(updateFocalAnimals = 1)
      result <- session$getReturned()
      expect_equal(length(result$focalAnimals()), 2)

      session$setInputs(clearFocalAnimals = TRUE)
      session$setInputs(updateFocalAnimals = 2)
      expect_equal(length(result$focalAnimals()), 0)

      # Choose a different file; it must load normally after the clear.
      session$setInputs(
        clearFocalAnimals = FALSE,
        focalAnimalFile = list(datapath = file2, name = "file2.csv")
      )
      session$setInputs(updateFocalAnimals = 3)
      focal <- result$focalAnimals()
      expect_equal(length(focal), 2)
      expect_true(all(c("C", "D") %in% focal))
    }
  )

  unlink(c(file1, file2))
})

test_that("modPedigreeServer loads newly typed text after a clear", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = c("A", "B", "C", "D"),
    sire = c(NA, NA, "A", "A"),
    dam = c(NA, NA, "B", "B"),
    sex = c("M", "F", "F", "M"),
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
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE,
        focalAnimalIds = "A, B"
      )
      session$setInputs(updateFocalAnimals = 1)
      result <- session$getReturned()
      expect_equal(length(result$focalAnimals()), 2)

      session$setInputs(clearFocalAnimals = TRUE)
      session$setInputs(updateFocalAnimals = 2)
      expect_equal(length(result$focalAnimals()), 0)

      # Type new IDs; they must load normally after the clear.
      session$setInputs(
        clearFocalAnimals = FALSE,
        focalAnimalIds = "C, D"
      )
      session$setInputs(updateFocalAnimals = 3)
      focal <- result$focalAnimals()
      expect_equal(length(focal), 2)
      expect_true(all(c("C", "D") %in% focal))
    }
  )
})
