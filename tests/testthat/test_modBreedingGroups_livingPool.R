## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

library(testthat)
library(nprcgenekeepr)

## Breeding Groups draws its animals from living animals only (S939; owner-
## ruled S938, BACKLOG.md "Breeding Groups should build its pool from living
## animals only"). One internal rule, isLivingAnimal(), says who is alive:
##   - a pedigree with a Status column: an animal is alive when its Status is
##     ALIVE, whatever its exit date says (a placeholder has Status UNKNOWN and
##     no exit date, so an exit-date test alone would keep it);
##   - a pedigree with no Status column: an animal with no exit date is alive
##     (the owner's pick at the S939 Pre-RED gate; the Genetic Value tab's own
##     fallback and the effective-size helpers count the same way);
##   - a pedigree with neither column: everyone counts, so the pool is as before.
## The module applies it to the raw pool BEFORE the top-N or floor cut, for
## every source ("Top ranked", "Upload list", "All available"). Animals typed
## into a seed group are the user's own choice and stay accepted.

# =============================================================================
# The rule: isLivingAnimal(ped)
# =============================================================================

test_that("with a Status column only ALIVE counts, as a factor or text", {
  status <- c("ALIVE", "DECEASED", "SHIPPED", "UNKNOWN")
  asFactor <- data.frame(
    id = letters[1:4],
    status = factor(status, levels = status)
  )
  asText <- data.frame(id = letters[1:4], status = status)

  expect_identical(isLivingAnimal(asFactor), c(TRUE, FALSE, FALSE, FALSE))
  expect_identical(isLivingAnimal(asText), c(TRUE, FALSE, FALSE, FALSE))
})

test_that("a Status column wins over the exit date", {
  ped <- data.frame(
    id = letters[1:3],
    status = c("ALIVE", "UNKNOWN", "DECEASED"),
    exit = as.Date(c("2020-01-01", NA, NA))
  )

  # ALIVE with an exit date still counts; a placeholder (UNKNOWN, no exit
  # date) and a DECEASED animal with no exit date do not.
  expect_identical(isLivingAnimal(ped), c(TRUE, FALSE, FALSE))
})

test_that("a missing Status is not alive, and the answer is never NA", {
  ped <- data.frame(id = letters[1:3], status = c("ALIVE", NA, "ALIVE"))

  expect_identical(isLivingAnimal(ped), c(TRUE, FALSE, TRUE))
})

test_that("with no Status column an animal with no exit date is alive", {
  ped <- data.frame(
    id = letters[1:3],
    exit = as.Date(c(NA, "2020-01-01", NA))
  )

  expect_identical(isLivingAnimal(ped), c(TRUE, FALSE, TRUE))
})

test_that("with neither a Status nor an exit column everyone counts", {
  ped <- data.frame(id = letters[1:4], sex = c("M", "F", "M", "F"))

  expect_identical(isLivingAnimal(ped), rep(TRUE, 4L))
})

test_that("an empty pedigree gives an empty logical vector", {
  ped <- data.frame(
    id = character(0L),
    status = character(0L)
  )

  expect_identical(isLivingAnimal(ped), logical(0L))
})

# =============================================================================
# The module: Breeding Groups' pool
#
# groups() plus unassigned() are exactly the candidate ids that reached
# groupAddAssign() (modBreedingGroups.R: `unassignedIds <- setdiff(
# candidateIds, assignedIds)`), so their union is a deterministic proxy for
# "which animals were in the pool" whatever the stochastic group assignment.
# =============================================================================

# Fourteen animals, alternating M / F. A1-A8 are alive; A9-A10 are deceased;
# A11-A12 are shipped; A13-A14 are placeholders (Status UNKNOWN, no exit date).
lpPed <- function() {
  status <- c(rep("ALIVE", 8L), "DECEASED", "DECEASED", "SHIPPED", "SHIPPED",
              "UNKNOWN", "UNKNOWN")
  data.frame(
    id = paste0("A", 1:14),
    sire = NA_character_,
    dam = NA_character_,
    sex = rep(c("M", "F"), length.out = 14L),
    birth = as.Date("2015-01-01") - (1:14) * 90L,
    exit = as.Date(c(rep(NA, 8L), rep("2020-06-01", 4L), NA, NA)),
    status = factor(status,
                    levels = c("ALIVE", "DECEASED", "SHIPPED", "UNKNOWN")),
    stringsAsFactors = FALSE
  )
}
lpLiving <- paste0("A", 1:8)

# The ids that reached groupAddAssign(), run once with the given inputs.
lpCandidates <- function(ped, geneticValues = NULL, ...) {
  out <- NULL
  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ ped }),
      geneticValues = if (is.null(geneticValues)) {
        NULL
      } else {
        shiny::reactive({ geneticValues })
      }
    ),
    {
      session$setInputs(nGroups = 2, maxKinship = 0.25, sexRatio = "none",
                        ...)
      session$setInputs(formGroups = 1)
      result <- session$getReturned()
      out <<- list(
        candidates = sort(c(unlist(result$groups()), result$unassigned())),
        unassigned = result$unassigned(),
        groups = result$groups()
      )
    }
  )
  out
}

test_that("All available forms groups from living animals only", {
  skip_on_cran()

  got <- lpCandidates(lpPed(), animalSource = "all")

  expect_setequal(got$candidates, lpLiving)
  # Not even the unassigned list names an animal that is not alive.
  expect_false(any(paste0("A", 9:14) %in% got$unassigned))
})

test_that("Upload list forms groups from living animals only", {
  skip_on_cran()

  # Today "Upload list" behaves exactly like "All available" (it has no upload
  # control), so the living rule must reach it too.
  got <- lpCandidates(lpPed(), animalSource = "custom")

  expect_setequal(got$candidates, lpLiving)
})

test_that("Top ranked takes the best living animals, not the first minus the dead", {
  skip_on_cran()

  # The report puts every animal that is not alive first, as the real app's
  # default run does. Cutting to the first 5 and then dropping the dead would
  # leave nobody; the rule runs first, so the first 5 LIVING animals in report
  # order are the pool.
  gv <- data.frame(
    id = c(paste0("A", 9:14), "A5", "A2", "A8", "A1", "A7", "A3", "A6", "A4"),
    value = "High Value",
    stringsAsFactors = FALSE
  )

  got <- lpCandidates(lpPed(), geneticValues = gv,
                      animalSource = "topRanked", inclusionCriterion = "topN",
                      nTopAnimals = 5)

  expect_setequal(got$candidates, c("A5", "A2", "A8", "A1", "A7"))
})

test_that("the genetic-value floor skips animals that are not alive", {
  skip_on_cran()

  # A9 (deceased), A11 (shipped) and A13 (placeholder) pass the floor on value
  # alone. A6-A8, A10, A12 and A14 are absent from the report (the floor drops
  # them already); A2 and A5 are Low Value.
  gv <- data.frame(
    id = c("A1", "A2", "A3", "A4", "A5", "A9", "A11", "A13"),
    value = c("High Value", "Low Value", "Undetermined", "High Value",
              "Low Value", "High Value", "High Value", "High Value"),
    stringsAsFactors = FALSE
  )

  got <- lpCandidates(lpPed(), geneticValues = gv,
                      animalSource = "topRanked",
                      inclusionCriterion = "valueFloor", nTopAnimals = 2)

  expect_setequal(got$candidates, c("A1", "A3", "A4"))
})

test_that("with no Status column the exit date says who is alive", {
  skip_on_cran()

  ped <- lpPed()
  ped$status <- NULL

  got <- lpCandidates(ped, animalSource = "all")

  # No exit date: A1-A8 and the two placeholders (which, with no Status, look
  # like any animal with no exit date).
  expect_setequal(got$candidates, paste0("A", c(1:8, 13:14)))
})

test_that("with neither a Status nor an exit column the pool is every animal", {
  skip_on_cran()

  # Green-at-HEAD coverage (NOT a RED): a pedigree that cannot say who is alive
  # is left alone, so the pool is as it was before the living rule.
  ped <- lpPed()
  ped$status <- NULL
  ped$exit <- NULL

  got <- lpCandidates(ped, animalSource = "all")

  expect_setequal(got$candidates, paste0("A", 1:14))
})

test_that("a typed seed animal that is not alive is still accepted", {
  skip_on_cran()

  # Green-at-HEAD coverage (NOT a RED): A9 is deceased, but a seed is the
  # user's own choice and is not drawn from the pool, so the rule leaves it.
  set.seed(42)
  got <- lpCandidates(lpPed(), animalSource = "all", seedGroups = TRUE,
                      curGrp1 = "A9")

  expect_gt(length(got$groups), 0L)
  expect_true("A9" %in% got$groups[[1L]])
})

# Groups cannot be formed when nobody is alive: the tab says so in plain words
# and forms nothing (it does not fail inside the formation step).
lpNotices <- function(ped, env = parent.frame()) {
  rec <- new.env()
  rec$notes <- list()
  rec$texts <- function() {
    vapply(rec$notes, function(n) n$text, character(1L))
  }
  rec$types <- function() {
    vapply(rec$notes, function(n) n$type, character(1L))
  }
  testthat::local_mocked_bindings(
    showNotification = function(ui, ..., type = "default") {
      rec$notes[[length(rec$notes) + 1L]] <- list(
        text = as.character(ui), type = type
      )
      invisible("note-id")
    },
    .package = "nprcgenekeepr", .env = env
  )
  rec
}

test_that("with nobody alive the tab says so and forms no groups", {
  skip_on_cran()

  ped <- lpPed()
  ped$status <- factor(rep("DECEASED", 14L),
                       levels = c("ALIVE", "DECEASED", "SHIPPED", "UNKNOWN"))
  rec <- lpNotices(ped)

  got <- lpCandidates(ped, animalSource = "all")

  expect_length(got$groups, 0L)
  expect_length(got$unassigned, 0L)
  expect_length(rec$notes, 1L)
  expect_identical(rec$types(), "error")
  expect_true(any(grepl("None of the 14 animals", rec$texts(), fixed = TRUE)))
  expect_true(any(grepl("alive", rec$texts(), fixed = TRUE)))
})

test_that("a blank Status column means nobody is alive, whatever the exit date", {
  skip_on_cran()

  # Status wins over the exit date at the module level too: a file whose
  # Status is all UNKNOWN has no living animal, even though no exit date is set.
  ped <- lpPed()
  ped$status <- factor(rep("UNKNOWN", 14L),
                       levels = c("ALIVE", "DECEASED", "SHIPPED", "UNKNOWN"))
  ped$exit <- as.Date(NA)
  rec <- lpNotices(ped)

  got <- lpCandidates(ped, animalSource = "all")

  expect_length(got$groups, 0L)
  expect_length(rec$notes, 1L)
  expect_true(any(grepl("None of the 14 animals", rec$texts(), fixed = TRUE)))
})
