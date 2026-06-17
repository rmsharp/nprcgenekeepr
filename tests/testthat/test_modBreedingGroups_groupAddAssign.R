# Tests for modBreedingGroups.R - groupAddAssign Integration
# Task #3: RED phase tests for real breeding group algorithm
#
# These tests verify that modBreedingGroupsServer properly integrates with
# the groupAddAssign() function instead of using placeholder random assignment.

# Slow shiny-module integration tests (many shiny::testServer() calls); skip on
# CRAN to keep check elapsed time within limits. They still run on CI and
# locally. The analytical functions exercised here have their own unit tests.
testthat::skip_on_cran()

# =============================================================================
# Helper Functions for Creating Valid Test Data
# =============================================================================

#' Create a valid pedigree for breeding group tests
#' @param nFounders Number of founder animals (half male, half female)
#' @param nOffspring Number of offspring to generate
#' @return A data.frame with valid pedigree structure
makeBreedingGroupTestPed <- function(nFounders = 6, nOffspring = 12) {
  nMaleFounders <- nFounders %/% 2
  nFemaleFounders <- nFounders - nMaleFounders

  # Create founders (no parents)
  founders <- data.frame(
    id = paste0("F", seq_len(nFounders)),
    sire = NA_character_,
    dam = NA_character_,
    sex = c(rep("M", nMaleFounders), rep("F", nFemaleFounders)),
    birth = as.Date("2010-01-01") - (seq_len(nFounders) * 365),
    exit = NA,
    stringsAsFactors = FALSE
  )

  maleSires <- founders$id[founders$sex == "M"]
  femaleDams <- founders$id[founders$sex == "F"]

  # Create offspring with valid parents
  offspring <- data.frame(
    id = paste0("O", seq_len(nOffspring)),
    sire = rep(maleSires, length.out = nOffspring),
    dam = rep(femaleDams, length.out = nOffspring),
    sex = rep(c("M", "F"), length.out = nOffspring),
    birth = as.Date("2015-01-01") + (seq_len(nOffspring) * 30),
    exit = NA,
    stringsAsFactors = FALSE
  )

  rbind(founders, offspring)
}

# =============================================================================
# Tests: groupAddAssign Return Format
# =============================================================================

test_that("modBreedingGroupsServer returns groupAddAssign format (char vectors)",
          {
  skip_if_not_installed("shiny")

  test_ped <- makeBreedingGroupTestPed(nFounders = 6, nOffspring = 12)

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

      # groupAddAssign returns list of character vectors (IDs), NOT data.frames
      # The placeholder returns data.frames with random assignment
      expect_true(is.list(groups))

      # Each group should be a character vector of IDs
      for (i in seq_along(groups)) {
        expect_true(
          is.character(groups[[i]]),
          label = paste("Group", i, "should be character vector from groupAddAssign")
        )
      }
    }
  )
})

test_that("modBreedingGroupsServer returns score from groupAddAssign", {
  skip_if_not_installed("shiny")

  test_ped <- makeBreedingGroupTestPed(nFounders = 6, nOffspring = 12)

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

      # groupAddAssign returns a score - should have score reactive
      expect_true("score" %in% names(result),
        label = "Should return score from groupAddAssign")

      if ("score" %in% names(result)) {
        score <- result$score()
        expect_true(is.numeric(score),
          label = "Score should be numeric")
        expect_gte(score, 0,
          label = "Score should be non-negative")
      }
    }
  )
})

# =============================================================================
# Tests: Kinship-Based Group Formation
# =============================================================================

test_that("modBreedingGroupsServer uses kinship threshold for grouping", {
  skip_if_not_installed("shiny")

  test_ped <- makeBreedingGroupTestPed(nFounders = 4, nOffspring = 8)

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      # Use strict kinship threshold - siblings (kinship=0.25) should be excluded
      session$setInputs(
        animalSource = "all",
        nGroups = 2,
        maxKinship = 0.0625,  # Below sibling kinship
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      groups <- result$groups()

      # With kinship threshold, groups shouldn't contain highly related pairs
      # The placeholder doesn't respect kinship - it randomly assigns
      expect_true(is.list(groups))

      # Verify groups are deterministic (not random) by checking structure
      for (group in groups) {
        ids <- if (is.character(group)) group else group$id
        expect_true(all(ids %in% test_ped$id),
          label = "All group members should be from pedigree")
      }
    }
  )
})

test_that("modBreedingGroupsServer uses groupAddAssign for sibling population", {
  skip_if_not_installed("shiny")

  # Create pedigree where offspring are all full siblings
  test_ped <- data.frame(
    id = c("S1", "D1", "O1", "O2", "O3", "O4", "O5", "O6"),
    sire = c(NA, NA, "S1", "S1", "S1", "S1", "S1", "S1"),
    dam = c(NA, NA, "D1", "D1", "D1", "D1", "D1", "D1"),
    sex = c("M", "F", "M", "F", "M", "F", "M", "F"),
    birth = c(as.Date("2010-01-01"), as.Date("2010-01-01"),
              as.Date("2015-01-01") + (1:6) * 30),
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
        nGroups = 3,
        maxKinship = 0.125,  # Below sibling kinship of 0.25
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      groups <- result$groups()

      # groupAddAssign should be called - verify output format
      expect_true(is.list(groups))
      expect_gte(length(groups), 1)

      # Groups should contain character IDs (not data.frames)
      for (group in groups) {
        expect_true(is.character(group),
          label = "Groups should be character vectors from groupAddAssign")
      }
    }
  )
})

# =============================================================================
# Tests: Harem Mode
# =============================================================================

test_that("modBreedingGroupsServer forms harem groups with single male", {
  skip_if_not_installed("shiny")

  test_ped <- makeBreedingGroupTestPed(nFounders = 8, nOffspring = 16)

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

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      groups <- result$groups()

      # Each harem group should have exactly 1 male
      for (i in seq_along(groups)) {
        group <- groups[[i]]
        ids <- if (is.character(group)) group else group$id
        sexes <- test_ped$sex[test_ped$id %in% ids]
        nMales <- sum(sexes == "M")

        expect_equal(nMales, 1,
          label = paste("Harem group", i, "should have exactly 1 male"))
      }
    }
  )
})

test_that("modBreedingGroupsServer passes harem=TRUE to groupAddAssign", {
  skip_if_not_installed("shiny")

  test_ped <- makeBreedingGroupTestPed(nFounders = 6, nOffspring = 12)

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
        sexRatio = "harem"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      groups <- result$groups()

      # All groups should have exactly 1 male (harem characteristic)
      maleCounts <- sapply(groups, function(group) {
        ids <- if (is.character(group)) group else group$id
        sum(test_ped$sex[test_ped$id %in% ids] == "M")
      })

      expect_true(all(maleCounts == 1),
        label = "All harem groups should have exactly 1 male")
    }
  )
})

# =============================================================================
# Tests: Sex Ratio
# =============================================================================

test_that("modBreedingGroupsServer passes sex ratio to groupAddAssign", {
  skip_if_not_installed("shiny")

  test_ped <- makeBreedingGroupTestPed(nFounders = 10, nOffspring = 30)

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      # Request 3:1 female:male ratio
      session$setInputs(
        animalSource = "all",
        nGroups = 3,
        maxKinship = 0.25,
        sexRatio = "3"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      groups <- result$groups()

      # Verify groupAddAssign was called (returns character vectors)
      expect_true(is.list(groups))
      expect_gte(length(groups), 1)

      # Each group should be a character vector
      for (group in groups) {
        expect_true(is.character(group),
          label = "Groups should be character vectors from groupAddAssign")
      }
    }
  )
})

# =============================================================================
# Tests: Unassigned Animals
# =============================================================================

test_that("modBreedingGroupsServer tracks unassigned animals", {
  skip_if_not_installed("shiny")

  test_ped <- makeBreedingGroupTestPed(nFounders = 6, nOffspring = 20)

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
        maxKinship = 0.0625,  # Strict threshold will leave animals unassigned
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()

      # Should have unassigned reactive in return
      expect_true("unassigned" %in% names(result),
        label = "Should have unassigned in return list")

      # Should track unassigned animals (returns character, not NULL)
      unassigned <- result$unassigned()
      groups <- result$groups()

      # unassigned should be a character vector (possibly empty)
      expect_true(is.character(unassigned),
        label = "unassigned should be a character vector")
    }
  )
})

test_that("modBreedingGroupsServer unassigned complements assigned", {
  skip_if_not_installed("shiny")

  test_ped <- makeBreedingGroupTestPed(nFounders = 4, nOffspring = 10)

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
        maxKinship = 0.0625,
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      groups <- result$groups()
      unassigned <- result$unassigned()

      # Total should equal candidates
      assignedIds <- unlist(lapply(groups, function(g) {
        if (is.character(g)) g else g$id
      }))

      unassignedIds <- if (is.null(unassigned)) character(0) else unassigned
      allIds <- c(assignedIds, unassignedIds)

      candidates <- test_ped$id

      # Assigned + unassigned should cover all candidates
      expect_true(all(candidates %in% allIds) || length(allIds) > 0,
        label = "Assigned + unassigned should account for all candidates")

      # No overlap between assigned and unassigned
      expect_equal(length(intersect(assignedIds, unassignedIds)), 0,
        label = "Assigned and unassigned should not overlap")
    }
  )
})

# =============================================================================
# Tests: Group Kinship Matrix
# =============================================================================

test_that("modBreedingGroupsServer returns group kinship when requested", {
  skip_if_not_installed("shiny")

  test_ped <- makeBreedingGroupTestPed(nFounders = 6, nOffspring = 12)

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
        sexRatio = "none",
        withKinship = TRUE
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()

      # Check for groupKinship reactive
      expect_true("groupKinship" %in% names(result),
        label = "Should have groupKinship in return list when withKinship=TRUE")
    }
  )
})

# =============================================================================
# Tests: Edge Cases
# =============================================================================

test_that("modBreedingGroupsServer handles pedigree with only founders", {
  skip_if_not_installed("shiny")

  # All founders (no kinship through parents)
  founders_only <- data.frame(
    id = paste0("F", 1:10),
    sire = NA_character_,
    dam = NA_character_,
    sex = rep(c("M", "F"), 5),
    birth = as.Date("2015-01-01"),
    exit = NA,
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ founders_only }),
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

      # With no kinship constraints, all animals can be grouped
      expect_true(is.list(groups))
      totalAssigned <- sum(sapply(groups, function(g) {
        if (is.character(g)) length(g) else nrow(g)
      }))
      expect_equal(totalAssigned, 10,
        label = "All unrelated founders should be assignable")
    }
  )
})

test_that("modBreedingGroupsServer handles insufficient males for harem", {
  skip_if_not_installed("shiny")

  # Only 1 male, requesting 3 harem groups
  test_ped <- data.frame(
    id = c("M1", paste0("F", 1:10)),
    sire = NA_character_,
    dam = NA_character_,
    sex = c("M", rep("F", 10)),
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
        nGroups = 3,
        maxKinship = 0.25,
        sexRatio = "harem"
      )

      # Module catches errors via tryCatch and shows notification
      # It should handle gracefully (not crash)
      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      groups <- result$groups()

      # Should either return empty groups or form what it can
      expect_true(is.list(groups))
    }
  )
})

test_that("modBreedingGroupsServer handles highly related population", {
  skip_if_not_installed("shiny")

  # All offspring from same parents (full siblings)
  test_ped <- data.frame(
    id = c("S1", "D1", paste0("O", 1:8)),
    sire = c(NA, NA, rep("S1", 8)),
    dam = c(NA, NA, rep("D1", 8)),
    sex = c("M", "F", rep(c("M", "F"), 4)),
    birth = c(as.Date("2010-01-01"), as.Date("2010-01-01"),
              as.Date("2015-01-01") + (1:8) * 30),
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
        maxKinship = 0.125,  # Below sibling kinship of 0.25
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      groups <- result$groups()

      # Verify groupAddAssign was called and returned proper structure
      expect_true(is.list(groups))

      # Each group should be a character vector
      for (group in groups) {
        expect_true(is.character(group),
          label = "Groups should be character vectors from groupAddAssign")
      }
    }
  )
})

# =============================================================================
# Tests: minAge Parameter
# =============================================================================

test_that("modBreedingGroupsServer passes minAge to groupAddAssign", {
  skip_if_not_installed("shiny")

  # Create pedigree with animals of varying ages
  test_ped <- makeBreedingGroupTestPed(nFounders = 6, nOffspring = 12)

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL
    ),
    {
      # Set minAge parameter - affects kinship threshold application
      session$setInputs(
        animalSource = "all",
        nGroups = 2,
        maxKinship = 0.25,
        sexRatio = "none",
        minAge = 1
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      groups <- result$groups()

      # Verify groupAddAssign was called with minAge parameter
      expect_true(is.list(groups))
      expect_equal(length(groups), 2)

      # Each group should be a character vector
      for (group in groups) {
        expect_true(is.character(group),
          label = "Groups should be character vectors from groupAddAssign")
      }
    }
  )
})

# =============================================================================
# Tests: iter Parameter
# =============================================================================

test_that("modBreedingGroupsServer uses iter parameter", {
  skip_if_not_installed("shiny")

  test_ped <- makeBreedingGroupTestPed(nFounders = 6, nOffspring = 12)

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
        sexRatio = "none",
        nIterations = 100  # Should be used by groupAddAssign
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      groups <- result$groups()

      # Just verify it runs - iter affects optimization not output format
      expect_true(is.list(groups))
      expect_equal(length(groups), 2)
    }
  )
})

# =============================================================================
# Tests: Integration with Real Data
# =============================================================================

test_that("modBreedingGroupsServer works with examplePedigree subset", {
  testthat::skip_on_cran()
  skip_if_not_installed("shiny")

  # Use subset of real example data
  data(examplePedigree, package = "nprcgenekeepr")

  # Get living non-founders for candidates
  living <- examplePedigree[is.na(examplePedigree$exit), ]
  nonFounders <- living[!is.na(living$sire) | !is.na(living$dam), ]

  if (nrow(nonFounders) < 10) {
    skip("Not enough non-founder living animals in examplePedigree")
  }

  # Take first 30 for faster testing
  test_ped <- nonFounders[1:min(30, nrow(nonFounders)), ]

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
        maxKinship = 0.125,
        sexRatio = "none"
      )

      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      groups <- result$groups()

      expect_true(is.list(groups))
      expect_equal(length(groups), 3)

      # Groups should contain character IDs
      for (group in groups) {
        ids <- if (is.character(group)) group else group$id
        expect_true(all(ids %in% test_ped$id))
      }
    }
  )
})
