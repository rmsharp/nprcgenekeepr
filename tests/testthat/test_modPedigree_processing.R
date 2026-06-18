# Tests for modPedigree.R - Pedigree Processing Pipeline
# These tests verify the integration of setPopulation(), trimPedigree(),
# findPedigreeNumber(), and findGeneration() with modPedigreeServer

# Slow shiny-module integration tests (many shiny::testServer() calls); skip on
# CRAN to keep check elapsed time within limits. They still run on CI and
# locally. The analytical functions exercised here have their own unit tests.
testthat::skip_on_cran()

# ============================================================================
# Tests for setPopulation Integration
# ============================================================================

test_that("modPedigreeServer adds population column to pedigree", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = c("A", "B", "C", "D", "E"),
    sire = c(NA, NA, "A", "A", "B"),
    dam = c(NA, NA, "B", NA, NA),
    sex = c("M", "F", "F", "M", "F"),
    gen = c(0L, 0L, 1L, 1L, 1L),
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
      ped <- result$pedigree()

      # Pedigree should have population column
      expect_true("population" %in% names(ped))
    }
  )
})

test_that("modPedigreeServer sets all animals as population when no focal animals", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    gen = c(0L, 0L, 1L),
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
      ped <- result$pedigree()

      # With no focal animals, all should be marked as population
      expect_true("population" %in% names(ped))
      expect_true(all(ped$population))
    }
  )
})

test_that("modPedigreeServer sets only focal animals as population", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = c("A", "B", "C", "D", "E"),
    sire = c(NA, NA, "A", "A", "B"),
    dam = c(NA, NA, "B", NA, NA),
    sex = c("M", "F", "F", "M", "F"),
    gen = c(0L, 0L, 1L, 1L, 1L),
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
        focalAnimalIds = "C, D"
      )

      session$setInputs(updateFocalAnimals = 1)

      result <- session$getReturned()
      ped <- result$pedigree()

      # Only C and D should be marked as population
      expect_true("population" %in% names(ped))
      expect_true(ped$population[ped$id == "C"])
      expect_true(ped$population[ped$id == "D"])
      expect_false(ped$population[ped$id == "A"])
      expect_false(ped$population[ped$id == "B"])
      expect_false(ped$population[ped$id == "E"])
    }
  )
})

# ============================================================================
# Tests for trimPedigree Integration
# ============================================================================

test_that("modPedigreeServer trimPedigree includes ancestors of focal animals", {
  skip_if_not_installed("shiny")

  # Create pedigree: A and B are parents of C
  test_studbook <- data.frame(
    id = c("A", "B", "C", "D", "E"),
    sire = c(NA, NA, "A", "A", "B"),
    dam = c(NA, NA, "B", NA, NA),
    sex = c("M", "F", "F", "M", "F"),
    gen = c(0L, 0L, 1L, 1L, 1L),
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
        focalAnimalIds = "C"  # Only C as focal
      )

      session$setInputs(updateFocalAnimals = 1)
      session$setInputs(trimPedigree = TRUE)

      result <- session$getReturned()
      ped <- result$pedigree()

      # Should include C and its parents A and B (ancestors)
      expect_true("C" %in% ped$id)
      expect_true("A" %in% ped$id)  # sire of C
      expect_true("B" %in% ped$id)  # dam of C
      # D and E are not ancestors of C, so should be excluded
      expect_false("D" %in% ped$id)
      expect_false("E" %in% ped$id)
    }
  )
})

test_that("modPedigreeServer trimPedigree includes grandparents", {
  skip_if_not_installed("shiny")

  # Create 3-generation pedigree
  test_studbook <- data.frame(
    id = c("GP1", "GP2", "GP3", "GP4", "P1", "P2", "Child"),
    sire = c(NA, NA, NA, NA, "GP1", "GP3", "P1"),
    dam = c(NA, NA, NA, NA, "GP2", "GP4", "P2"),
    sex = c("M", "F", "M", "F", "M", "F", "F"),
    gen = c(0L, 0L, 0L, 0L, 1L, 1L, 2L),
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
        focalAnimalIds = "Child"
      )

      session$setInputs(updateFocalAnimals = 1)
      session$setInputs(trimPedigree = TRUE)

      result <- session$getReturned()
      ped <- result$pedigree()

      # Should include Child, parents P1 and P2, and grandparents
      expect_true("Child" %in% ped$id)
      expect_true("P1" %in% ped$id)
      expect_true("P2" %in% ped$id)
      expect_true("GP1" %in% ped$id)
      expect_true("GP2" %in% ped$id)
      expect_true("GP3" %in% ped$id)
      expect_true("GP4" %in% ped$id)
      expect_equal(nrow(ped), 7)
    }
  )
})

test_that("modPedigreeServer trimPedigree handles multiple focal animals", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = c("A", "B", "C", "D", "E", "F"),
    sire = c(NA, NA, "A", "B", NA, NA),
    dam = c(NA, NA, NA, NA, NA, NA),
    sex = c("M", "M", "F", "F", "M", "F"),
    gen = c(0L, 0L, 1L, 1L, 0L, 0L),
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
        focalAnimalIds = "C, D"
      )

      session$setInputs(updateFocalAnimals = 1)
      session$setInputs(trimPedigree = TRUE)

      result <- session$getReturned()
      ped <- result$pedigree()

      # Should include C, D and their ancestors A, B
      expect_true(all(c("A", "B", "C", "D") %in% ped$id))
      # E and F are not related to C or D
      expect_false("E" %in% ped$id)
      expect_false("F" %in% ped$id)
    }
  )
})

test_that("modPedigreeServer trimPedigree includes descendants of focal animals", {
  skip_if_not_installed("shiny")

  # D is the focal animal. A and B are D's parents (ancestors). GC is D's
  # child by E (a descendant). C is D's sibling and E is D's mate (collaterals).
  test_studbook <- data.frame(
    id = c("A", "B", "C", "D", "E", "GC"),
    sire = c(NA, NA, "A", "A", NA, "D"),
    dam = c(NA, NA, "B", "B", NA, "E"),
    sex = c("M", "F", "F", "M", "F", "F"),
    gen = c(0L, 0L, 1L, 1L, 0L, 2L),
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
        focalAnimalIds = "D"
      )

      session$setInputs(updateFocalAnimals = 1)
      session$setInputs(trimPedigree = TRUE)

      result <- session$getReturned()
      ped <- result$pedigree()

      # Ancestors of D still included
      expect_true("D" %in% ped$id)
      expect_true("A" %in% ped$id) # sire of D
      expect_true("B" %in% ped$id) # dam of D
      # Descendant of D now included (the new behavior)
      expect_true("GC" %in% ped$id) # child of D
    }
  )
})

test_that("modPedigreeServer trimPedigree is strict-lineal: excludes siblings and mates", {
  skip_if_not_installed("shiny")

  # Same structure: focal D. Strict-lineal keeps ancestors {A,B} and
  # descendants {GC}, but excludes the sibling C and the mate E (collaterals).
  test_studbook <- data.frame(
    id = c("A", "B", "C", "D", "E", "GC"),
    sire = c(NA, NA, "A", "A", NA, "D"),
    dam = c(NA, NA, "B", "B", NA, "E"),
    sex = c("M", "F", "F", "M", "F", "F"),
    gen = c(0L, 0L, 1L, 1L, 0L, 2L),
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
        focalAnimalIds = "D"
      )

      session$setInputs(updateFocalAnimals = 1)
      session$setInputs(trimPedigree = TRUE)

      result <- session$getReturned()
      ped <- result$pedigree()

      # Lineal animals present
      expect_true(all(c("A", "B", "D", "GC") %in% ped$id))
      # Collaterals excluded
      expect_false("C" %in% ped$id) # sibling of D
      expect_false("E" %in% ped$id) # mate of D
    }
  )
})

# ============================================================================
# Tests for findPedigreeNumber Integration
# ============================================================================

test_that("modPedigreeServer adds pedNum column", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    gen = c(0L, 0L, 1L),
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
      ped <- result$pedigree()

      # Should have pedNum column
      expect_true("pedNum" %in% names(ped))
    }
  )
})

test_that("modPedigreeServer pedNum identifies separate pedigrees", {
  skip_if_not_installed("shiny")

  # Two unconnected pedigrees
  test_studbook <- data.frame(
    id = c("A1", "B1", "C1", "A2", "B2", "C2"),
    sire = c(NA, NA, "A1", NA, NA, "A2"),
    dam = c(NA, NA, "B1", NA, NA, "B2"),
    sex = c("M", "F", "F", "M", "F", "F"),
    gen = c(0L, 0L, 1L, 0L, 0L, 1L),
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
      ped <- result$pedigree()

      # Should have pedNum column with 2 different values
      expect_true("pedNum" %in% names(ped))
      expect_equal(length(unique(ped$pedNum)), 2)

      # Animals in same pedigree should have same pedNum
      ped1_ids <- c("A1", "B1", "C1")
      ped2_ids <- c("A2", "B2", "C2")

      ped1_nums <- unique(ped$pedNum[ped$id %in% ped1_ids])
      ped2_nums <- unique(ped$pedNum[ped$id %in% ped2_ids])

      expect_equal(length(ped1_nums), 1)
      expect_equal(length(ped2_nums), 1)
      expect_true(ped1_nums != ped2_nums)
    }
  )
})

# ============================================================================
# Tests for generation column
# ============================================================================

test_that("modPedigreeServer preserves or adds gen column", {
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
      ped <- result$pedigree()

      # Should have gen column
      expect_true("gen" %in% names(ped))
    }
  )
})

test_that("modPedigreeServer gen column has correct generation numbers", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = c("GP", "P", "Child"),
    sire = c(NA, "GP", "P"),
    dam = c(NA, NA, NA),
    sex = c("M", "M", "M"),
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
      ped <- result$pedigree()

      expect_true("gen" %in% names(ped))

      # Founders should be gen 0
      expect_equal(ped$gen[ped$id == "GP"], 0)
      # P should be gen 1
      expect_equal(ped$gen[ped$id == "P"], 1)
      # Child should be gen 2
      expect_equal(ped$gen[ped$id == "Child"], 2)
    }
  )
})

# ============================================================================
# Tests for processedPedigree reactive
# ============================================================================

test_that("modPedigreeServer returns processedPedigree with all expected columns", {
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

      # Should have processedPedigree reactive
      expect_true("processedPedigree" %in% names(result))

      processed <- result$processedPedigree()

      # Should have all processing columns
      expect_true("population" %in% names(processed))
      expect_true("pedNum" %in% names(processed))
      expect_true("gen" %in% names(processed))
    }
  )
})

test_that("modPedigreeServer processedPedigree updates when focal animals change", {
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
        focalAnimalIds = ""
      )

      result <- session$getReturned()

      # Initially all should be population
      processed1 <- result$processedPedigree()
      expect_true(all(processed1$population))

      # Set focal animals
      session$setInputs(focalAnimalIds = "C")
      session$setInputs(updateFocalAnimals = 1)

      processed2 <- result$processedPedigree()

      # Now only C should be population
      expect_true(processed2$population[processed2$id == "C"])
      expect_false(processed2$population[processed2$id == "D"])
    }
  )
})

# ============================================================================
# Tests for populationCount reactive
# ============================================================================

test_that("modPedigreeServer returns populationCount reactive", {
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
        focalAnimalIds = "C, D"
      )

      session$setInputs(updateFocalAnimals = 1)

      result <- session$getReturned()

      # Should have populationCount reactive
      expect_true("populationCount" %in% names(result))
      expect_equal(result$populationCount(), 2)  # C and D
    }
  )
})

# ============================================================================
# Integration Tests with Real Package Data
# ============================================================================

test_that("modPedigreeServer works with examplePedigree data", {
  skip_if_not_installed("shiny")

  data("examplePedigree", package = "nprcgenekeepr")

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ examplePedigree }),
      config = NULL
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE
      )

      result <- session$getReturned()
      ped <- result$pedigree()

      # Should work with real data
      expect_true(nrow(ped) > 0)
      expect_true("population" %in% names(ped))
      expect_true("pedNum" %in% names(ped))
    }
  )
})

test_that("modPedigreeServer trimPedigree works with examplePedigree", {
  skip_if_not_installed("shiny")

  data("examplePedigree", package = "nprcgenekeepr")

  # Get some IDs from the pedigree to use as focal animals
  focal_ids <- head(examplePedigree$id[!is.na(examplePedigree$sire)], 3)

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ examplePedigree }),
      config = NULL
    ),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = FALSE,
        clearFocalAnimals = FALSE,
        focalAnimalIds = paste(focal_ids, collapse = ", ")
      )

      session$setInputs(updateFocalAnimals = 1)

      # Get count before trimming
      result <- session$getReturned()
      count_before <- result$nAnimals()

      # Enable trimming
      session$setInputs(trimPedigree = TRUE)
      count_after <- result$nAnimals()

      # Trimmed pedigree should be smaller or equal
      expect_lte(count_after, count_before)
      # Should still include focal animals
      ped <- result$pedigree()
      expect_true(all(focal_ids %in% ped$id))
    }
  )
})

# ============================================================================
# Edge Cases
# ============================================================================

test_that("modPedigreeServer handles single animal pedigree", {
  skip_if_not_installed("shiny")

  test_studbook <- data.frame(
    id = "A",
    sire = NA_character_,
    dam = NA_character_,
    sex = "M",
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
      ped <- result$pedigree()

      expect_equal(nrow(ped), 1)
      expect_true("population" %in% names(ped))
      expect_true("pedNum" %in% names(ped))
      expect_true(ped$population[1])
    }
  )
})

test_that("modPedigreeServer handles pedigree with circular reference gracefully", {
  skip_if_not_installed("shiny")

  # This shouldn't happen in real data but test robustness
  test_studbook <- data.frame(
    id = c("A", "B"),
    sire = c("B", "A"),  # Circular!
    dam = c(NA, NA),
    sex = c("M", "M"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPedigreeServer,
    args = list(
      studbook = shiny::reactive({ test_studbook }),
      config = NULL
    ),
    {
      # findGeneration now emits a warning for ids it cannot place (NEW-40);
      # a circular reference is exactly such a case. The module must surface
      # the diagnostic yet still handle it gracefully (warn, do not crash).
      expect_warning(
        session$setInputs(
          displayUnknownIds = TRUE,
          trimPedigree = FALSE
        ),
        regexp = "could not be assigned a generation"
      )

      result <- session$getReturned()

      # Should not crash, should return some result
      expect_no_error(suppressWarnings(result$pedigree()))
    }
  )
})
