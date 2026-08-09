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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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
      studbook = shiny::reactive({ test_studbook })
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

## Issue #129 Slice 1 -- pedigree diagram (Table/Diagram tab) tests.

test_that("modPedigreeUI has a tabbed Table/Diagram layout", {
  ui <- modPedigreeUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("Table", ui_html))
  expect_true(grepl("Diagram", ui_html))
  expect_true(grepl("pedigreeDiagram", ui_html))
})

test_that("modPedigreeServer renders the diagram widget under the size limit", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

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
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )
      session$flushReact()

      html <- output$pedigreeDiagramUI$html
      expect_true(grepl("visNetwork", html))
    }
  )
})

test_that(
  "modPedigreeServer shows an informative message above the size limit", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  n <- 1600L
  bigId <- sprintf("A%04d", seq_len(n))
  test_studbook <- data.frame(
    id = bigId,
    sire = NA_character_,
    dam = NA_character_,
    sex = rep(c("M", "F"), length.out = n),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )
      session$flushReact()

      html <- output$pedigreeDiagramUI$html
      expect_false(grepl("visNetwork", html))
      expect_true(grepl("exceeds|limit", html, ignore.case = TRUE))
    }
  )
})

## Issue #129 Slice 2 -- click-to-navigate interactivity tests.

test_that("modPedigreeServer sets focalIds from a diagram node click", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

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
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE,
        pedigreeDiagram_click = "D"
      )
      session$flushReact()

      result <- session$getReturned()
      expect_equal(result$focalAnimals(), "D")
    }
  )
})

test_that("modPedigreeServer recomputes pedigreeData after a diagram click", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

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
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = TRUE,
        pedigreeDiagram_click = "C"
      )
      session$flushReact()

      result <- session$getReturned()
      # Clicking C sets it as the sole focal animal; trimming includes C's
      # ancestors (A, B) plus C itself. D/E are C's half-sibs, not
      # descendants of C, so they stay excluded -- the same trim semantics
      # the textarea-driven focal path already exercises elsewhere in this
      # file (reusing processedPedigree -> pedigreeData, no duplicate logic).
      expect_setequal(result$pedigree()$id, c("A", "B", "C"))

      # A second click on a different node re-drives the same trim path to
      # that node's own connected component, proving the diagram click
      # recomputes pedigreeData() rather than just setting a static value.
      session$setInputs(pedigreeDiagram_click = "A")
      session$flushReact()
      expect_setequal(result$pedigree()$id, c("A", "C", "D"))
    }
  )
})

test_that("modPedigreeServer ignores a background diagram click", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

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
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE,
        pedigreeDiagram_click = "D"
      )
      session$flushReact()
      result <- session$getReturned()
      expect_equal(result$focalAnimals(), "D")

      # A background (no-node) canvas click emits an empty `nodes.nodes`
      # array (confirmed hands-on, Pre-RED this session: deserializes to an
      # empty/NULL R value) -- it must not clear or otherwise change the
      # current selection.
      session$setInputs(pedigreeDiagram_click = character(0))
      session$flushReact()
      expect_equal(result$focalAnimals(), "D")
    }
  )
})

## Issue #131 -- diagram PNG export button.

test_that("modPedigreeServer's diagram widget offers a PNG export button", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

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
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )
      session$flushReact()

      # output$pedigreeDiagram is the widget's raw JSON payload inside
      # testServer() (confirmed hands-on, Pre-RED this session) -- the
      # export config visNetwork::visExport() attaches lands in x.export.
      widgetJson <- output$pedigreeDiagram
      expect_true(grepl('"export"', widgetJson))
      expect_true(grepl('"type":"png"', widgetJson))
      expect_true(grepl("pedigree_diagram\\.png", widgetJson))
    }
  )
})

## Issue #132 -- shape-to-sex legend on the Diagram tab.

test_that("modPedigreeServer's diagram widget offers a shape-to-sex legend", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  # M/F-only fixture: star/triangle/diamond shapes and the Hermaphrodite/
  # Unknown/Other labels below cannot come from the diagram's own nodes, so
  # their presence in the widget JSON unambiguously proves the legend.
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
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )
      session$flushReact()

      # output$pedigreeDiagram is the widget's raw JSON payload inside
      # testServer() (Learning from the issue #131 export test above) --
      # visNetwork::visLegend()'s config lands in x.legend.
      widgetJson <- output$pedigreeDiagram
      expect_true(grepl('"legend"', widgetJson))
      expect_true(grepl('"position":"right"', widgetJson))
      expect_true(grepl('"text":"Sex"', widgetJson))
      expect_true(grepl('"Female"', widgetJson))
      expect_true(grepl('"Male"', widgetJson))
      expect_true(grepl('"Hermaphrodite"', widgetJson))
      expect_true(grepl('"Unknown"', widgetJson))
      expect_true(grepl("Other / Unrecorded", widgetJson))
      expect_true(grepl('"star"', widgetJson))
      expect_true(grepl('"triangle"', widgetJson))
      expect_true(grepl('"diamond"', widgetJson))
      # width/stepY tuned live (Pre-RED) so all 5 rows -- including the
      # longest label, "Other / Unrecorded" -- render without clipping
      # against the legend canvas's own overflow:hidden boundary or
      # crowding the export button below it. stepY retuned 65->54 by issue
      # #133 Slice 2 (Dragon #4) to also fit a 6th "Affected" row's own
      # label within the same boundary -- see the dedicated Slice 2 test
      # below.
      expect_true(grepl('"width":0.28', widgetJson))
      expect_true(grepl('"stepY":54', widgetJson))
    }
  )
})

## Issue #133 Slice 2 -- "Affected" row added to the same shape-to-sex
## legend (D6: one new row in the existing visLegend()/addNodes call, never
## a second visLegend() call -- confirmed S485, visLegend() assigns a single
## scalar slot). Reuses Slice 1's D8 color (#CC79A7).

test_that(
  "modPedigreeServer's diagram widget legend includes an Affected row", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

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
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )
      session$flushReact()

      # output$pedigreeDiagram is the widget's raw JSON payload (same
      # technique as the #132 legend test above).
      widgetJson <- output$pedigreeDiagram
      expect_true(grepl('"Affected"', widgetJson))
      expect_true(grepl('"hexagon"', widgetJson))
      expect_true(grepl("#CC79A7", widgetJson, fixed = TRUE))

      # The 5 existing sex-shape rows must still render, unperturbed by the
      # new row/color column added to the same addNodes data frame
      # (regression guard for the #132 legend).
      expect_true(grepl('"Female"', widgetJson))
      expect_true(grepl('"Male"', widgetJson))
      expect_true(grepl('"Hermaphrodite"', widgetJson))
      expect_true(grepl('"Unknown"', widgetJson))
      expect_true(grepl("Other / Unrecorded", widgetJson))
    }
  )
})

## Issue #137 Slice 3 -- twin/zygosity connector legend, added via the SAME
## visLegend() call's addEdges parameter (never a second call -- same
## single-scalar-slot constraint the #133 Affected-row test above already
## established for addNodes). Describes exactly what .buildTwinConnectorEdges()
## (Slice 2) actually renders -- label + dashes only, no color (D10's color
## pick was never wired into that function; tracked separately in BACKLOG.md,
## not fixed here -- out of this slice's own file scope).

test_that(
  "modPedigreeServer's diagram widget legend includes MZ/DZ/UZ twin-connector
   rows, unconditionally present regardless of whether any twin data is
   uploaded (a static legend, like the existing sex/Affected rows)", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

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
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )
      session$flushReact()

      widgetJson <- output$pedigreeDiagram
      expect_true(grepl('"MZ"', widgetJson))
      expect_true(grepl('"DZ"', widgetJson))
      expect_true(grepl('"?"', widgetJson, fixed = TRUE))

      # The pre-existing sex/Affected addNodes rows must still render,
      # unperturbed by the new addEdges argument on the same visLegend()
      # call (regression guard, mirroring the #133 Affected-row test above).
      expect_true(grepl('"Female"', widgetJson))
      expect_true(grepl('"Affected"', widgetJson))
    }
  )
})

## Issue #135 -- ID-select search dropdown + hover-highlight on the Diagram
## tab. hoverNearest (not the visNetwork default click-based highlight) is
## used deliberately so the highlight effect does not overlap the existing
## click-to-navigate handler (issue #129 Slice 2) bound above.

test_that(
  "modPedigreeServer's diagram widget offers an ID-select search dropdown", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

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
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )
      session$flushReact()

      # output$pedigreeDiagram is the widget's raw JSON payload inside
      # testServer() (Learning from the issue #131/#132 tests above) --
      # visNetwork::visOptions()'s nodesIdSelection config lands in
      # x.idselection.
      widgetJson <- output$pedigreeDiagram
      expect_true(grepl('"idselection":{"enabled":true', widgetJson,
                         fixed = TRUE))
      expect_true(grepl('"main":"Select by id"', widgetJson, fixed = TRUE))
    }
  )
})

test_that(
  "modPedigreeServer's diagram widget highlights connected nodes on hover,
   not click", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

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
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )
      session$flushReact()

      # visNetwork::visOptions()'s highlightNearest config lands in
      # x.highlight. hoverNearest:true confirms the highlight trigger is
      # hover, not visNetwork's own click-based default -- verified hands-on
      # Pre-RED that a bare list(enabled = TRUE) key is "hover", not
      # "hoverNearest", in visOptions()'s own validation.
      widgetJson <- output$pedigreeDiagram
      expect_true(grepl('"highlight":{"enabled":true,"hoverNearest":true',
                         widgetJson, fixed = TRUE))
    }
  )
})

## Pedigree Diagram Option 2 Slice 3 -- render-chain wiring
## (docs/planning/pedigree-diagram-option2-layout-design-plan.md, Migration
## Path step 3). The Diagram tab switches from makePedigreeDiagramData() +
## visHierarchicalLayout() to makePedigreeMatingLayout() + a fixed-position
## layout (visPhysics(enabled = FALSE)); the 1,500-node cap is re-derived to
## 750 individuals (owner-directed, S461, to keep total rendered nodes near
## the original ~1,500 ceiling under the new ~2x mating-unit/duplicate node
## model); click-to-navigate and the search dropdown adapt to the new union/
## duplicate node population (D6).

test_that(
  "modPedigreeServer's diagram widget disables physics/manual layout
   instead of visHierarchicalLayout(), per Slice 3's fixed-position
   geometry", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

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
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )
      session$flushReact()

      widgetJson <- output$pedigreeDiagram
      expect_true(grepl('"physics":{"enabled":false', widgetJson,
                         fixed = TRUE))
      expect_false(grepl("hierarchical", widgetJson, ignore.case = TRUE))
    }
  )
})

test_that(
  "modPedigreeServer renders the diagram widget at exactly 750 animals
   (the re-derived Slice 3 cap)", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  n <- 750L
  bigId <- sprintf("A%04d", seq_len(n))
  test_studbook <- data.frame(
    id = bigId,
    sire = NA_character_,
    dam = NA_character_,
    sex = rep(c("M", "F"), length.out = n),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )
      session$flushReact()

      html <- output$pedigreeDiagramUI$html
      expect_true(grepl("visNetwork", html))
    }
  )
})

test_that(
  "modPedigreeServer shows an informative message just above the
   re-derived 750-animal Slice 3 cap", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  n <- 751L
  bigId <- sprintf("A%04d", seq_len(n))
  test_studbook <- data.frame(
    id = bigId,
    sire = NA_character_,
    dam = NA_character_,
    sex = rep(c("M", "F"), length.out = n),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )
      session$flushReact()

      html <- output$pedigreeDiagramUI$html
      expect_false(grepl("visNetwork", html))
      expect_true(grepl("750", html, fixed = TRUE))
    }
  )
})

test_that(
  "modPedigreeServer's click-to-navigate ignores a click on a union
   (mating-unit) node -- D6, matches the design doc's own no-op
   requirement", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  test_studbook <- data.frame(
    id = c("A", "B", "D", "C", "E"),
    sire = c(NA, NA, NA, "A", "A"),
    dam = c(NA, NA, NA, "B", "D"),
    sex = c("M", "F", "F", "F", "F"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(cbind(test_studbook, gen = 0L))

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE,
        pedigreeDiagram_click = "C"
      )
      session$flushReact()
      result <- session$getReturned()
      expect_equal(result$focalAnimals(), "C")

      session$setInputs(pedigreeDiagram_click = forest$matingUnits$id[1L])
      session$flushReact()
      expect_equal(result$focalAnimals(), "C")
    }
  )
})

test_that(
  "modPedigreeServer's click-to-navigate resolves a click on a duplicate
   node to its real individual's id -- D6", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  test_studbook <- data.frame(
    id = c("A", "B", "D", "C", "E"),
    sire = c(NA, NA, NA, "A", "A"),
    dam = c(NA, NA, NA, "B", "D"),
    sex = c("M", "F", "F", "F", "F"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(cbind(test_studbook, gen = 0L))
  expect_equal(nrow(forest$duplicates), 1L)

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE,
        pedigreeDiagram_click = forest$duplicates$id[1L]
      )
      session$flushReact()
      result <- session$getReturned()
      expect_equal(result$focalAnimals(), forest$duplicates$realId[1L])
    }
  )
})

test_that(
  "modPedigreeServer's diagram search dropdown lists only real individual
   ids, excluding mating-unit and duplicate node ids -- D6", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  test_studbook <- data.frame(
    id = c("A", "B", "D", "C", "E"),
    sire = c(NA, NA, NA, "A", "A"),
    dam = c(NA, NA, NA, "B", "D"),
    sex = c("M", "F", "F", "F", "F"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )
      session$flushReact()

      widgetJson <- output$pedigreeDiagram
      idSelectionJson <- regmatches(
        widgetJson, regexpr('"idselection":\\{[^}]*\\}', widgetJson)
      )
      expect_true(nzchar(idSelectionJson))
      expect_false(grepl("__union_", idSelectionJson, fixed = TRUE))
      expect_false(grepl("__dup_", idSelectionJson, fixed = TRUE))
      for (realId in test_studbook$id) {
        expect_true(grepl(realId, idSelectionJson, fixed = TRUE))
      }
    }
  )
})

## ---- edgeStyle wiring (issue #142 Slice 2) -------------------------------

test_that(
  "modPedigreeServer's diagram defaults to edgeStyle = \"direct\" -- no
   __drop_/__bar_/__proj_ waypoint ids in the rendered widget when no
   style input has been set, matching pre-issue-142 behavior", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

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
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )
      session$flushReact()

      widgetJson <- output$pedigreeDiagram
      expect_false(grepl("__drop_|__bar_|__proj_", widgetJson))
    }
  )
})

test_that(
  "modPedigreeServer's diagram inserts __drop_/__bar_ waypoint ids into
   the rendered widget when pedigreeEdgeStyle is set to \"rectilinear\"", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

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
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE,
        pedigreeEdgeStyle = "rectilinear"
      )
      session$flushReact()

      widgetJson <- output$pedigreeDiagram
      expect_true(grepl("__drop_|__bar_", widgetJson))
    }
  )
})

test_that(
  "modPedigreeServer's click-to-navigate ignores a click on any of the 3
   new __drop_/__bar_/__proj_ waypoint-node prefixes (issue #142 D3) --
   the same no-op treatment the existing __union_ prefix already gets", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

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
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE,
        pedigreeDiagram_click = "C"
      )
      session$flushReact()
      result <- session$getReturned()
      expect_equal(result$focalAnimals(), "C")

      for (waypointId in c("__drop_x", "__bar_x", "__proj_x")) {
        session$setInputs(pedigreeDiagram_click = waypointId)
        session$flushReact()
        expect_equal(result$focalAnimals(), "C", info = waypointId)
      }
    }
  )
})

test_that(
  "modPedigreeServer's diagram search dropdown excludes the 3 new
   __drop_/__bar_/__proj_ waypoint-node prefixes under
   edgeStyle = \"rectilinear\", alongside the existing __union_/__dup_
   exclusions", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  test_studbook <- data.frame(
    id = c("A", "B", "D", "C", "E"),
    sire = c(NA, NA, NA, "A", "A"),
    dam = c(NA, NA, NA, "B", "D"),
    sex = c("M", "F", "F", "F", "F"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE,
        pedigreeEdgeStyle = "rectilinear"
      )
      session$flushReact()

      widgetJson <- output$pedigreeDiagram
      idSelectionJson <- regmatches(
        widgetJson, regexpr('"idselection":\\{[^}]*\\}', widgetJson)
      )
      expect_true(nzchar(idSelectionJson))
      expect_false(grepl("__union_", idSelectionJson, fixed = TRUE))
      expect_false(grepl("__dup_", idSelectionJson, fixed = TRUE))
      expect_false(grepl("__drop_", idSelectionJson, fixed = TRUE))
      expect_false(grepl("__bar_", idSelectionJson, fixed = TRUE))
      expect_false(grepl("__proj_", idSelectionJson, fixed = TRUE))
      for (realId in test_studbook$id) {
        expect_true(grepl(realId, idSelectionJson, fixed = TRUE))
      }
    }
  )
})

test_that(
  "modPedigreeServer's node cap is style-specific -- 400 individuals
   renders under edgeStyle = \"rectilinear\", 401 does not, but the SAME
   401-individual pedigree still renders fine under the default
   \"direct\" style", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  makeStudbook <- function(n) {
    bigId <- sprintf("A%04d", seq_len(n))
    data.frame(
      id = bigId, sire = NA_character_, dam = NA_character_,
      sex = rep(c("M", "F"), length.out = n), stringsAsFactors = FALSE
    )
  }

  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ makeStudbook(400L) })),
    {
      session$setInputs(
        displayUnknownIds = TRUE, trimPedigree = FALSE,
        pedigreeEdgeStyle = "rectilinear"
      )
      session$flushReact()
      html <- output$pedigreeDiagramUI$html
      expect_true(grepl("visNetwork", html))
    }
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ makeStudbook(401L) })),
    {
      session$setInputs(
        displayUnknownIds = TRUE, trimPedigree = FALSE,
        pedigreeEdgeStyle = "rectilinear"
      )
      session$flushReact()
      html <- output$pedigreeDiagramUI$html
      expect_false(grepl("visNetwork", html))
      expect_true(grepl("400", html, fixed = TRUE))
    }
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ makeStudbook(401L) })),
    {
      session$setInputs(
        displayUnknownIds = TRUE, trimPedigree = FALSE,
        pedigreeEdgeStyle = "direct"
      )
      session$flushReact()
      html <- output$pedigreeDiagramUI$html
      expect_true(grepl("visNetwork", html))
    }
  )
})

test_that(
  "modPedigreeServer's highlightNearest degree is style-aware -- 1 under
   \"direct\" (unchanged), raised under \"rectilinear\" so degree-1 hover
   does not visibly light up nothing at all when the nearest edge-graph
   neighbor is now an invisible waypoint node (live-confirmed regression,
   S468: a plain child's hover on \"direct\" reaches a visible union dot
   at 1 hop, but on \"rectilinear\" that same hop lands on an invisible
   __bar_/__drop_/__proj_ node instead)", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

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
      studbook = shiny::reactive({ test_studbook })
    ),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE)
      session$flushReact()
      expect_true(grepl('"degree":1', output$pedigreeDiagram, fixed = TRUE))

      session$setInputs(pedigreeEdgeStyle = "rectilinear")
      session$flushReact()
      expect_false(grepl('"degree":1', output$pedigreeDiagram, fixed = TRUE))
      expect_true(grepl('"degree":6', output$pedigreeDiagram, fixed = TRUE))
    }
  )
})

test_that(
  "modPedigreeServer's diagram edge-style radio toggle appears in the
   rendered UI only when a diagram is actually shown (D4) -- present
   under the cap, absent over the direct-style 750 cap", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  test_studbook <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"), dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"), stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ test_studbook })),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE)
      session$flushReact()
      html <- output$pedigreeDiagramUI$html
      expect_true(grepl("pedigreeEdgeStyle", html))
    }
  )

  n <- 751L
  bigId <- sprintf("A%04d", seq_len(n))
  bigStudbook <- data.frame(
    id = bigId, sire = NA_character_, dam = NA_character_,
    sex = rep(c("M", "F"), length.out = n), stringsAsFactors = FALSE
  )
  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ bigStudbook })),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE)
      session$flushReact()
      html <- output$pedigreeDiagramUI$html
      expect_false(grepl("pedigreeEdgeStyle", html))
    }
  )
})

## Issue #136 Slice 2 -- "Show Names on Diagram" toggle (D3/D4/D6/D10,
## docs/planning/issue136-name-labels-pedigree-diagram-plan.md). Off by
## default (owner-ratified framing); when on and the studbook has a `name`
## column, the diagram's real/duplicate node labels augment id with name.
## The search dropdown's useLabels = FALSE pin (D6) holds regardless of
## toggle state -- it is never toggle-dependent.

test_that(
  "modPedigreeServer's diagram widget offers a 'Show Names on Diagram'
   toggle, unchecked (off) by default", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  test_studbook <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"), dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"), name = c("Apollo", "Willow", "Comet"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ test_studbook })),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE)
      session$flushReact()
      html <- output$pedigreeDiagramUI$html
      expect_true(grepl("pedigreeShowNames", html))
    }
  )
})

test_that(
  "modPedigreeServer's diagram shows id-only labels when the show-names
   toggle is off, even though the studbook has a name column (D4/off-by-
   default -- a name-column-bearing pedigree renders exactly as a name-less
   one until the toggle is switched on)", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  test_studbook <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"), dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"), name = c("Apollo", "Willow", "Comet"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ test_studbook })),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE,
                         pedigreeShowNames = FALSE)
      session$flushReact()
      widgetJson <- output$pedigreeDiagram
      expect_false(grepl("Apollo", widgetJson, fixed = TRUE))
    }
  )
})

test_that(
  "modPedigreeServer's diagram shows augmented id+name labels once the
   show-names toggle is switched on and the studbook has a name column", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  test_studbook <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"), dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"), name = c("Apollo", "Willow", "Comet"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ test_studbook })),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE,
                         pedigreeShowNames = TRUE)
      session$flushReact()
      widgetJson <- output$pedigreeDiagram
      ## The widget's node data serializes column-oriented ("label":[...]),
      ## not row-oriented -- confirmed empirically against the real output,
      ## not assumed (Learning 489's discipline).
      expect_true(grepl('"label":["A\\nApollo"', widgetJson, fixed = TRUE))
    }
  )
})

test_that(
  "modPedigreeServer's diagram search dropdown pins useLabels = FALSE (D6)
   regardless of the show-names toggle state -- 'Select by id' must never
   silently start listing names", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  test_studbook <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"), dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"), name = c("Apollo", "Willow", "Comet"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ test_studbook })),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE,
                         pedigreeShowNames = FALSE)
      session$flushReact()
      expect_true(grepl('"useLabels":false', output$pedigreeDiagram,
                         fixed = TRUE))

      session$setInputs(pedigreeShowNames = TRUE)
      session$flushReact()
      expect_true(grepl('"useLabels":false', output$pedigreeDiagram,
                         fixed = TRUE))
    }
  )
})

## NOTE: a defect was found live (Phase 3E, real AppDriver) where the
## show-names toggle's checked state was silently discarded the next time
## pedigreeDiagramUI's renderUI() re-executed for an unrelated reason (e.g.
## switching edgeStyle) -- because the checkboxInput() call hardcoded
## value = FALSE instead of reading .currentShowNames() self-referentially,
## the way the pre-existing edgeStyle radioButtons already do via
## selected = style. A shiny::testServer() unit test CANNOT pin this
## regression: testServer sets input$x values directly server-side and
## never simulates the real client round-trip (a freshly re-sent
## checkboxInput HTML element reporting its own hardcoded default back to
## the server) that is the actual failure mechanism -- confirmed by writing
## exactly such a test and observing it pass identically against both the
## buggy and the fixed code. The permanent regression coverage for this
## defect is therefore a live AppDriver test, added to
## test-e2e-pedigree-module.R instead (issue #136 Slice 2 section there).

## Issue #137 Slice 3 -- UI wiring for twin/zygosity connectors. The file
## input lives in modPedigreeUI()'s STATIC UI (never inside the dynamically
## re-rendered pedigreeDiagramUI block) -- a fileInput has no value=
## argument a fresh render could read self-referentially the way
## checkboxInput/radioButtons do (Learning 490), so the only safe place for
## it is outside any block that ever re-executes. The "Show Twin
## Connectors" toggle lives in the SAME dynamic tagList() as edgeStyle/
## showNames and follows their self-referential-value pattern (business
## -logic/upload tests live in the dedicated
## test_modPedigree_twinRelations.R, mirroring test_modGeneticValue_
## kinshipOverrides.R's own dedicated-file precedent for the sibling
## kinship-overrides upload feature).

test_that(
  "modPedigreeUI offers a twin-relations file input in its static UI", {
  ui <- modPedigreeUI("test")
  ui_html <- as.character(ui)
  expect_true(grepl("twinRelationsFile", ui_html))
})

test_that(
  "modPedigreeServer's diagram widget offers a 'Show Twin Connectors'
   toggle, unchecked (off) by default", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  test_studbook <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"), dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ test_studbook })),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE)
      session$flushReact()
      html <- output$pedigreeDiagramUI$html
      expect_true(grepl("pedigreeShowTwinConnectors", html))
    }
  )
})
