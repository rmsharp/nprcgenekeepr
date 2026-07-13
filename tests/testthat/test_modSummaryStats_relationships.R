# Tests for modSummaryStats.R - Relationship Functionality Integration
# Task #5: Implement relationship designation system

# =============================================================================
# Helper Functions
# =============================================================================

#' Create a valid test pedigree with proper parent-child relationships
#' @param nFounders Number of founder animals (half male, half female)
#' @param nOffspring Number of offspring
#' @return A data.frame with proper pedigree structure
makeRelationshipTestPed <- function(nFounders = 4, nOffspring = 6) {
  nMaleFounders <- nFounders %/% 2
  nFemaleFounders <- nFounders - nMaleFounders

  # Create founders
  founders <- data.frame(
    id = paste0("F", seq_len(nFounders)),
    sire = NA_character_,
    dam = NA_character_,
    sex = c(rep("M", nMaleFounders), rep("F", nFemaleFounders)),
    birth = as.Date("2010-01-01") - (seq_len(nFounders) * 365),
    exit = NA,
    stringsAsFactors = FALSE
  )

  # Create offspring with valid parent assignments
  offspring <- data.frame(
    id = paste0("O", seq_len(nOffspring)),
    sire = rep(paste0("F", seq_len(nMaleFounders)), length.out = nOffspring),
    dam = rep(paste0("F", (nMaleFounders + 1):nFounders), length.out = nOffspring),
    sex = rep(c("M", "F"), length.out = nOffspring),
    birth = as.Date("2015-01-01") + (seq_len(nOffspring) * 30),
    exit = NA,
    stringsAsFactors = FALSE
  )

  ped <- rbind(founders, offspring)
  ped$gen <- nprcgenekeepr::findGeneration(ped$id, ped$sire, ped$dam)
  ped
}

#' Create test genetic values data
#' @param ids Character vector of IDs
#' @return A data.frame with genetic value columns
makeTestGeneticValues <- function(ids) {
  n <- length(ids)
  data.frame(
    id = ids,
    indivMeanKin = runif(n, 0.1, 0.4),
    gu = runif(n, 0.5, 0.9),
    stringsAsFactors = FALSE
  )
}

# =============================================================================
# Tests for relationships reactive
# =============================================================================

test_that("modSummaryStatsServer returns relationships reactive", {
  skip_if_not_installed("shiny")

  test_ped <- makeRelationshipTestPed()
  test_gv <- makeTestGeneticValues(test_ped$id)
  test_kmat <- nprcgenekeepr::kinship(test_ped$id, test_ped$sire, test_ped$dam, test_ped$gen,
                       sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      result <- session$getReturned()

      # Should have relationships reactive
      expect_true("relationships" %in% names(result))
      expect_true(is.function(result$relationships))
    }
  )
})

test_that("relationships reactive returns correct structure from convertRelationships", {
  skip_if_not_installed("shiny")

  test_ped <- makeRelationshipTestPed()
  test_gv <- makeTestGeneticValues(test_ped$id)
  test_kmat <- nprcgenekeepr::kinship(test_ped$id, test_ped$sire, test_ped$dam, test_ped$gen,
                       sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      result <- session$getReturned()
      rels <- result$relationships()

      # Should be a data frame with correct columns
      expect_true(is.data.frame(rels))
      expect_true("id1" %in% names(rels))
      expect_true("id2" %in% names(rels))
      expect_true("kinship" %in% names(rels))
      expect_true("relation" %in% names(rels))
    }
  )
})

test_that("relationships reactive detects parent-offspring relationships", {
  skip_if_not_installed("shiny")

  test_ped <- makeRelationshipTestPed()
  test_gv <- makeTestGeneticValues(test_ped$id)
  test_kmat <- nprcgenekeepr::kinship(test_ped$id, test_ped$sire, test_ped$dam, test_ped$gen,
                       sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      result <- session$getReturned()
      rels <- result$relationships()

      # Should detect parent-offspring relationships
      expect_true("Parent-Offspring" %in% rels$relation)
    }
  )
})

test_that("relationships reactive detects sibling relationships", {
  skip_if_not_installed("shiny")

  # Create pedigree with full siblings (same sire and dam)
  ped <- data.frame(
    id = c("S1", "D1", "C1", "C2", "C3"),
    sire = c(NA, NA, "S1", "S1", "S1"),
    dam = c(NA, NA, "D1", "D1", "D1"),
    sex = c("M", "F", "M", "F", "M"),
    stringsAsFactors = FALSE
  )
  ped$gen <- nprcgenekeepr::findGeneration(ped$id, ped$sire, ped$dam)

  test_gv <- makeTestGeneticValues(ped$id)
  test_kmat <- nprcgenekeepr::kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      result <- session$getReturned()
      rels <- result$relationships()

      # Should detect full-sibling relationships
      expect_true("Full-Siblings" %in% rels$relation)
    }
  )
})

test_that("relationships reactive detects half-sibling relationships", {
  skip_if_not_installed("shiny")

  # Create pedigree with half siblings (same sire, different dam)
  ped <- data.frame(
    id = c("S1", "D1", "D2", "C1", "C2"),
    sire = c(NA, NA, NA, "S1", "S1"),
    dam = c(NA, NA, NA, "D1", "D2"),
    sex = c("M", "F", "F", "M", "F"),
    stringsAsFactors = FALSE
  )
  ped$gen <- nprcgenekeepr::findGeneration(ped$id, ped$sire, ped$dam)

  test_gv <- makeTestGeneticValues(ped$id)
  test_kmat <- nprcgenekeepr::kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      result <- session$getReturned()
      rels <- result$relationships()

      # Should detect half-sibling relationships
      expect_true("Half-Siblings" %in% rels$relation)
    }
  )
})

# =============================================================================
# Tests for relationClasses reactive
# =============================================================================

test_that("modSummaryStatsServer returns relationClasses reactive", {
  skip_if_not_installed("shiny")

  test_ped <- makeRelationshipTestPed()
  test_gv <- makeTestGeneticValues(test_ped$id)
  test_kmat <- nprcgenekeepr::kinship(test_ped$id, test_ped$sire, test_ped$dam, test_ped$gen,
                       sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      result <- session$getReturned()

      # Should have relationClasses reactive
      expect_true("relationClasses" %in% names(result))
      expect_true(is.function(result$relationClasses))
    }
  )
})

test_that("relationClasses reactive returns correct structure from makeRelationClassesTable", {
  skip_if_not_installed("shiny")

  test_ped <- makeRelationshipTestPed()
  test_gv <- makeTestGeneticValues(test_ped$id)
  test_kmat <- nprcgenekeepr::kinship(test_ped$id, test_ped$sire, test_ped$dam, test_ped$gen,
                       sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      result <- session$getReturned()
      classes <- result$relationClasses()

      # Should be a data frame with correct columns
      expect_true(is.data.frame(classes))
      expect_true("Relationship Class" %in% names(classes))
      expect_true("Frequency" %in% names(classes))
    }
  )
})

test_that("relationClasses reactive excludes Self relationships", {
  skip_if_not_installed("shiny")

  test_ped <- makeRelationshipTestPed()
  test_gv <- makeTestGeneticValues(test_ped$id)
  test_kmat <- nprcgenekeepr::kinship(test_ped$id, test_ped$sire, test_ped$dam, test_ped$gen,
                       sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      result <- session$getReturned()
      classes <- result$relationClasses()

      # Self should not appear in relationship classes table
      expect_false("Self" %in% classes$`Relationship Class`)
    }
  )
})

# =============================================================================
# Tests for firstOrderCounts reactive
# =============================================================================

test_that("modSummaryStatsServer returns firstOrderCounts reactive", {
  skip_if_not_installed("shiny")

  test_ped <- makeRelationshipTestPed()
  test_gv <- makeTestGeneticValues(test_ped$id)
  test_kmat <- nprcgenekeepr::kinship(test_ped$id, test_ped$sire, test_ped$dam, test_ped$gen,
                       sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      result <- session$getReturned()

      # Should have firstOrderCounts reactive
      expect_true("firstOrderCounts" %in% names(result))
      expect_true(is.function(result$firstOrderCounts))
    }
  )
})

test_that("firstOrderCounts reactive returns correct structure from countFirstOrder", {
  skip_if_not_installed("shiny")

  test_ped <- makeRelationshipTestPed()
  test_gv <- makeTestGeneticValues(test_ped$id)
  test_kmat <- nprcgenekeepr::kinship(test_ped$id, test_ped$sire, test_ped$dam, test_ped$gen,
                       sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      result <- session$getReturned()
      counts <- result$firstOrderCounts()

      # Should be a data frame with correct columns
      expect_true(is.data.frame(counts))
      expect_true("id" %in% names(counts))
      expect_true("parents" %in% names(counts))
      expect_true("offspring" %in% names(counts))
      expect_true("siblings" %in% names(counts))
      expect_true("total" %in% names(counts))
    }
  )
})

test_that("firstOrderCounts correctly counts parent relationships", {
  skip_if_not_installed("shiny")

  # Simple pedigree: parents S1, D1 and offspring C1
  ped <- data.frame(
    id = c("S1", "D1", "C1"),
    sire = c(NA, NA, "S1"),
    dam = c(NA, NA, "D1"),
    sex = c("M", "F", "M"),
    stringsAsFactors = FALSE
  )
  ped$gen <- nprcgenekeepr::findGeneration(ped$id, ped$sire, ped$dam)

  test_gv <- makeTestGeneticValues(ped$id)
  test_kmat <- nprcgenekeepr::kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      result <- session$getReturned()
      counts <- result$firstOrderCounts()

      # C1 should have 2 parents in the pedigree
      c1_row <- counts[counts$id == "C1", ]
      expect_equal(c1_row$parents, 2)
    }
  )
})

test_that("firstOrderCounts correctly counts offspring relationships", {
  skip_if_not_installed("shiny")

  # Simple pedigree: parent S1 with 3 offspring
  ped <- data.frame(
    id = c("S1", "D1", "C1", "C2", "C3"),
    sire = c(NA, NA, "S1", "S1", "S1"),
    dam = c(NA, NA, "D1", "D1", "D1"),
    sex = c("M", "F", "M", "F", "M"),
    stringsAsFactors = FALSE
  )
  ped$gen <- nprcgenekeepr::findGeneration(ped$id, ped$sire, ped$dam)

  test_gv <- makeTestGeneticValues(ped$id)
  test_kmat <- nprcgenekeepr::kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      result <- session$getReturned()
      counts <- result$firstOrderCounts()

      # S1 should have 3 offspring in the pedigree
      s1_row <- counts[counts$id == "S1", ]
      expect_equal(s1_row$offspring, 3)
    }
  )
})

test_that("firstOrderCounts correctly counts sibling relationships", {
  skip_if_not_installed("shiny")

  # Full siblings: C1, C2, C3 have same parents
  ped <- data.frame(
    id = c("S1", "D1", "C1", "C2", "C3"),
    sire = c(NA, NA, "S1", "S1", "S1"),
    dam = c(NA, NA, "D1", "D1", "D1"),
    sex = c("M", "F", "M", "F", "M"),
    stringsAsFactors = FALSE
  )
  ped$gen <- nprcgenekeepr::findGeneration(ped$id, ped$sire, ped$dam)

  test_gv <- makeTestGeneticValues(ped$id)
  test_kmat <- nprcgenekeepr::kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      result <- session$getReturned()
      counts <- result$firstOrderCounts()

      # C1 should have 2 siblings (C2 and C3)
      c1_row <- counts[counts$id == "C1", ]
      expect_equal(c1_row$siblings, 2)
    }
  )
})

# =============================================================================
# Tests for downloadFirstOrder handler (real implementation)
# =============================================================================

test_that("downloadFirstOrder exports real first-order relationship data", {
  skip_if_not_installed("shiny")

  test_ped <- makeRelationshipTestPed()
  test_gv <- makeTestGeneticValues(test_ped$id)
  test_kmat <- nprcgenekeepr::kinship(test_ped$id, test_ped$sire, test_ped$dam, test_ped$gen,
                       sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      # The download handler should exist and produce countFirstOrder output
      # Note: We can't directly test downloadHandler content in testServer,
      # but we can verify the firstOrderCounts reactive works
      result <- session$getReturned()
      counts <- result$firstOrderCounts()

      # Should have data from countFirstOrder, not placeholder
      expect_true(nrow(counts) > 0)
      expect_true(all(c("id", "parents", "offspring", "siblings", "total") %in%
                        names(counts)))
      # Total should equal sum of parents + offspring + siblings
      expect_equal(counts$total, counts$parents + counts$offspring + counts$siblings)
    }
  )
})

# =============================================================================
# Tests for downloadRelationships handler
# =============================================================================

test_that("modSummaryStatsUI has downloadRelationships button", {
  ui <- modSummaryStatsUI("test")
  ui_html <- as.character(ui)

  # Should have a button to download full relationships
  expect_true(grepl("downloadRelationships", ui_html))
})

# =============================================================================
# Tests for downloadRelationClasses handler
# =============================================================================

test_that("modSummaryStatsUI has downloadRelationClasses button", {
  ui <- modSummaryStatsUI("test")
  ui_html <- as.character(ui)

  # Should have a button to download relationship classes summary
  expect_true(grepl("downloadRelationClasses", ui_html))
})

# =============================================================================
# Tests for edge cases
# =============================================================================

test_that("relationships reactive handles NULL kinship matrix gracefully", {
  skip_if_not_installed("shiny")

  test_ped <- makeRelationshipTestPed()
  test_gv <- makeTestGeneticValues(test_ped$id)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL
    ),
    {
      result <- session$getReturned()

      # Should still have relationships reactive even with NULL kinship
      # (module should calculate kinship internally)
      expect_true("relationships" %in% names(result))
    }
  )
})

test_that("relationships reactive handles pedigree with only founders", {
  skip_if_not_installed("shiny")

  # All founders - no parent-child relationships
  ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, NA),
    dam = c(NA, NA, NA),
    sex = c("M", "F", "M"),
    stringsAsFactors = FALSE
  )
  ped$gen <- nprcgenekeepr::findGeneration(ped$id, ped$sire, ped$dam)

  test_gv <- makeTestGeneticValues(ped$id)
  test_kmat <- nprcgenekeepr::kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      result <- session$getReturned()
      rels <- result$relationships()

      # All founders should show "No Relation" between them
      non_self_rels <- rels[rels$relation != "Self", ]
      expect_true(all(non_self_rels$relation == "No Relation"))
    }
  )
})

test_that("firstOrderCounts handles single animal pedigree", {
  skip_if_not_installed("shiny")

  ped <- data.frame(
    id = "A",
    sire = NA,
    dam = NA,
    sex = "M",
    stringsAsFactors = FALSE
  )
  ped$gen <- 0

  test_gv <- makeTestGeneticValues(ped$id)
  # Note: kinship() returns a scalar for single-animal pedigrees, not a matrix
  # Let the module calculate kinship internally

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ ped }),
      kinshipMatrix = NULL  # Let module calculate
    ),
    {
      result <- session$getReturned()
      counts <- result$firstOrderCounts()

      expect_equal(nrow(counts), 1)
      expect_equal(counts$parents[1], 0)
      expect_equal(counts$offspring[1], 0)
      expect_equal(counts$siblings[1], 0)
      expect_equal(counts$total[1], 0)
    }
  )
})

# =============================================================================
# Tests with real package data
# =============================================================================

test_that("relationships works with examplePedigree data", {
  skip_if_not_installed("shiny")

  ped <- nprcgenekeepr::examplePedigree[1:100, ]
  ped$gen <- nprcgenekeepr::findGeneration(ped$id, ped$sire, ped$dam)

  test_gv <- makeTestGeneticValues(ped$id)
  test_kmat <- nprcgenekeepr::kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      result <- session$getReturned()
      rels <- result$relationships()

      expect_true(is.data.frame(rels))
      expect_true(nrow(rels) > 0)
    }
  )
})

test_that("firstOrderCounts works with smallPed data", {
  skip_if_not_installed("shiny")

  ped <- nprcgenekeepr::smallPed

  test_gv <- makeTestGeneticValues(ped$id)
  test_kmat <- nprcgenekeepr::kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ ped }),
      kinshipMatrix = shiny::reactive({ test_kmat })
    ),
    {
      result <- session$getReturned()
      counts <- result$firstOrderCounts()

      expect_true(is.data.frame(counts))
      expect_equal(nrow(counts), nrow(ped))
    }
  )
})

# =============================================================================
# Tests for kinship-override flagging (issue #13 item-3 R13, Session 223)
# The app path is kinshipMatrix = NULL (the module recomputes kinship from the
# pedigree and applies overrides). The relationship table's relation LABEL
# stays pedigree-derived while the kinship VALUE is overridden, so overridden
# pairs are flagged with a logical `overridden` column.
# =============================================================================

test_that("relationships output is unchanged when no override supplied (D10)", {
  skip_if_not_installed("shiny")

  # Three unrelated founders -> no pedigree relationships between them.
  ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, NA),
    dam = c(NA, NA, NA),
    sex = c("M", "F", "M"),
    stringsAsFactors = FALSE
  )
  ped$gen <- nprcgenekeepr::findGeneration(ped$id, ped$sire, ped$dam)
  test_gv <- makeTestGeneticValues(ped$id)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ ped }),
      kinshipMatrix = NULL,
      kinshipOverrides = NULL
    ),
    {
      result <- session$getReturned()
      rels <- result$relationships()

      # No override => no flag column; schema is exactly the four base columns.
      expect_false("overridden" %in% names(rels))
      expect_setequal(names(rels), c("id1", "id2", "kinship", "relation"))
    }
  )
})

test_that("a kinship override flags the overridden pair in the table", {
  skip_if_not_installed("shiny")

  ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, NA),
    dam = c(NA, NA, NA),
    sex = c("M", "F", "M"),
    stringsAsFactors = FALSE
  )
  ped$gen <- nprcgenekeepr::findGeneration(ped$id, ped$sire, ped$dam)
  test_gv <- makeTestGeneticValues(ped$id)
  ov <- data.frame(id1 = "A", id2 = "B", kinship = 0.25,
                   stringsAsFactors = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ test_gv }),
      pedigree = shiny::reactive({ ped }),
      kinshipMatrix = NULL,
      kinshipOverrides = shiny::reactive({ ov })
    ),
    {
      result <- session$getReturned()
      rels <- result$relationships()

      expect_true("overridden" %in% names(rels))

      # The A-B pair (either order) is flagged, its value overridden, and its
      # label stays pedigree-derived ("Other": kinship > 0, no pedigree tie).
      isAB <- (rels$id1 == "A" & rels$id2 == "B") |
        (rels$id1 == "B" & rels$id2 == "A")
      ab <- rels[isAB, ]
      expect_equal(nrow(ab), 1)
      expect_true(ab$overridden)
      expect_equal(ab$kinship, 0.25)
      expect_equal(ab$relation, "Other")

      # Every other pair (incl. self rows) is not flagged.
      expect_false(any(rels$overridden[!isAB]))
    }
  )
})
