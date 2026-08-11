## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## Issue #151 Slice 2 RED: tests for modMatePairUI()/modMatePairServer(), the
## new Shiny module wrapping reportMatePairs() (Slice 1), written against a
## module that does not exist yet. See
## docs/planning/issue151-individual-mate-pair-analysis-plan.md Section 4
## (Interface catalog) and Section 5 (Slice 2 test list, D2-D6) for the
## contract these tests assert. The named-list-of-reactives shape check
## itself (module-contract.md rule 2) lives in test_moduleContract.R, not
## duplicated here (mirrors test_modMarkerGenetics.R's own precedent).
##
## Slow shiny-module integration tests (many shiny::testServer() calls); skip
## on CRAN to keep check elapsed time within limits (mirrors
## test_modBreedingGroups.R's own precedent). The core reportMatePairs()
## function has its own fast, always-run unit tests
## (test_reportMatePairs.R).
testthat::skip_on_cran()

## Fixture: 6 unrelated founders (3 M, 3 F) -- deliberately simple (kinship 0
## among all pairs) so every test's expectations are about ELIGIBILITY
## (population scope / age / exclude-list), not about kinship values, which
## Slice 1's own test_reportMatePairs.R already covers. M2 carries a real
## exit date (not "alive"); M3 is under the default minAge = 1 floor. Ages
## and exits chosen so the "allAlive"/"topRanked"/"custom" population-scope
## sources each produce a different, deterministic candidate set.
matePairPed <- function() {
  data.frame(
    id = c("M1", "F1", "M2", "F2", "M3", "F3"),
    sire = NA_character_,
    dam = NA_character_,
    sex = c("M", "F", "M", "F", "M", "F"),
    age = c(10, 10, 10, 10, 0.5, 10),
    exit = as.Date(c(NA, NA, "2020-01-01", NA, NA, NA)),
    stringsAsFactors = FALSE
  )
}

matePairKmat <- function(ped) {
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  kinship(ped$id, ped$sire, ped$dam, ped$gen)
}

pairKey <- function(pairsFrame) {
  paste(pairsFrame$sireId, pairsFrame$damId, sep = "|")
}

## Ranked report order matters for the "topRanked" population source (mirrors
## modBreedingGroupsServer's own "geneticValues()$id in report order" reading,
## R/modBreedingGroups.R:297-299) -- also the fixture for the D7 column-
## vocabulary wiring test (sireIndivMeanKin/sireGu/damIndivMeanKin/damGu must
## come from THESE values, proving modMatePairServer wraps the flat report in
## list(report = ...) before calling reportMatePairs(); an unwrapped data.frame
## has `$report` == NULL, per R's own `$` semantics on a data.frame, so this
## would silently regress to all-NA columns instead of an error).
matePairGvReport <- function() {
  data.frame(
    id = c("F1", "M1", "F2", "M2", "F3", "M3"),
    indivMeanKin = c(0.05, 0.06, 0.07, 0.08, 0.09, 0.10),
    gu = c(12, 13, 14, 15, 16, 17),
    stringsAsFactors = FALSE
  )
}

test_that("modMatePairUI returns a tagList with the expected namespaced controls", {
  ui_html <- as.character(modMatePairUI("mp"))

  expect_true(grepl("mp-populationSource", ui_html))
  expect_true(grepl("mp-minAge", ui_html))
  expect_true(grepl("mp-analyze", ui_html))
  expect_true(grepl("mp-pairsTable", ui_html))
  expect_true(grepl("mp-excludedTable", ui_html))
  expect_true(grepl("mp-downloadPairs", ui_html))
})

test_that("modMatePairServer is not ready and pairs()/excluded() halt before analyze is clicked", {
  skip_if_not_installed("shiny")

  ped <- matePairPed()
  kmat <- matePairKmat(ped)

  shiny::testServer(
    modMatePairServer,
    args = list(
      pedigree = shiny::reactive(ped),
      kinshipMatrix = shiny::reactive(kmat),
      markerKinshipMatrix = shiny::reactive(NULL),
      geneticValues = shiny::reactive(NULL)
    ),
    {
      result <- session$getReturned()
      expect_false(result$isReady())
      expect_error(result$pairs(), class = "shiny.silent.error")
      expect_error(result$excluded(), class = "shiny.silent.error")
    }
  )
})

test_that("populationSource = 'allAlive' scopes to ids with no recorded exit date", {
  skip_if_not_installed("shiny")

  ped <- matePairPed()
  kmat <- matePairKmat(ped)

  shiny::testServer(
    modMatePairServer,
    args = list(
      pedigree = shiny::reactive(ped),
      kinshipMatrix = shiny::reactive(kmat),
      markerKinshipMatrix = shiny::reactive(NULL),
      geneticValues = shiny::reactive(NULL)
    ),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1)
      session$setInputs(analyze = 1)

      result <- session$getReturned()
      expect_true(result$isReady())
      pairs <- result$pairs()

      # M2 has a real exit date -- never appears once scoped to "alive"
      expect_false(any(pairs$sireId == "M2" | pairs$damId == "M2"))
      # M1/F1/F2/F3 are all alive and >= minAge -- M1 x F2 must appear
      expect_true(any(pairs$sireId == "M1" & pairs$damId == "F2"))
    }
  )
})

test_that("populationSource = 'topRanked' scopes to the top N ids in geneticValues report order", {
  skip_if_not_installed("shiny")

  ped <- matePairPed()
  kmat <- matePairKmat(ped)
  gv <- matePairGvReport()

  shiny::testServer(
    modMatePairServer,
    args = list(
      pedigree = shiny::reactive(ped),
      kinshipMatrix = shiny::reactive(kmat),
      markerKinshipMatrix = shiny::reactive(NULL),
      geneticValues = shiny::reactive(gv)
    ),
    {
      # Top 2 of matePairGvReport()'s own order are F1, M1 -- the only
      # opposite-sex pair reachable from a 2-id population is F1 x M1.
      session$setInputs(populationSource = "topRanked", nTopAnimals = 2,
                        minAge = 1)
      session$setInputs(analyze = 1)

      result <- session$getReturned()
      pairs <- result$pairs()

      expect_identical(nrow(pairs), 1L)
      expect_identical(pairs$sireId, "M1")
      expect_identical(pairs$damId, "F1")
    }
  )
})

test_that("populationSource = 'custom' scopes to the pasted id list", {
  skip_if_not_installed("shiny")

  ped <- matePairPed()
  kmat <- matePairKmat(ped)

  shiny::testServer(
    modMatePairServer,
    args = list(
      pedigree = shiny::reactive(ped),
      kinshipMatrix = shiny::reactive(kmat),
      markerKinshipMatrix = shiny::reactive(NULL),
      geneticValues = shiny::reactive(NULL)
    ),
    {
      # comma/space/newline-delimited, mirroring modBreedingGroupsServer's own
      # seed-textarea id-parsing convention (R/modBreedingGroups.R:380).
      session$setInputs(populationSource = "custom",
                        customPopulationIds = "M1, F1\nF3",
                        minAge = 1)
      session$setInputs(analyze = 1)

      result <- session$getReturned()
      pairs <- result$pairs()

      expect_true(all(pairs$sireId %in% c("M1", "F1", "F3")))
      expect_true(all(pairs$damId %in% c("M1", "F1", "F3")))
      expect_true(any(pairs$sireId == "M1" & pairs$damId == "F1"))
      expect_true(any(pairs$sireId == "M1" & pairs$damId == "F3"))
    }
  )
})

test_that("the default minAge floor excludes an under-age individual with the 'under minimum age' reason", {
  skip_if_not_installed("shiny")

  ped <- matePairPed()
  kmat <- matePairKmat(ped)

  shiny::testServer(
    modMatePairServer,
    args = list(
      pedigree = shiny::reactive(ped),
      kinshipMatrix = shiny::reactive(kmat),
      markerKinshipMatrix = shiny::reactive(NULL),
      geneticValues = shiny::reactive(NULL)
    ),
    {
      # M3 (age 0.5) is included in population scope but fails minAge = 1.
      session$setInputs(populationSource = "custom",
                        customPopulationIds = "M3 F3",
                        minAge = 1)
      session$setInputs(analyze = 1)

      result <- session$getReturned()
      pairs <- result$pairs()
      excluded <- result$excluded()

      expect_false(any(pairs$sireId == "M3" | pairs$damId == "M3"))
      m3Excluded <- excluded[excluded$sireId == "M3" | excluded$damId == "M3", ]
      expect_true(nrow(m3Excluded) > 0L)
      expect_true(all(m3Excluded$reason == "under minimum age"))
    }
  )
})

test_that("the exclude-list textarea drops listed ids with the 'user-excluded' reason", {
  skip_if_not_installed("shiny")

  ped <- matePairPed()
  kmat <- matePairKmat(ped)

  shiny::testServer(
    modMatePairServer,
    args = list(
      pedigree = shiny::reactive(ped),
      kinshipMatrix = shiny::reactive(kmat),
      markerKinshipMatrix = shiny::reactive(NULL),
      geneticValues = shiny::reactive(NULL)
    ),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1,
                        useExcludeList = TRUE, excludeIds = "F1")
      session$setInputs(analyze = 1)

      result <- session$getReturned()
      pairs <- result$pairs()
      excluded <- result$excluded()

      expect_false(any(pairs$sireId == "F1" | pairs$damId == "F1"))
      f1Excluded <- excluded[excluded$sireId == "F1" | excluded$damId == "F1", ]
      expect_true(nrow(f1Excluded) > 0L)
      # any(), not all(): "allAlive" also includes M3 (age 0.5), so an
      # M3 x F1 pair is independently excluded for "under minimum age" before
      # ever reaching the user-exclude screen (same per-pair-not-per-
      # individual reason semantics test_reportMatePairs.R already
      # established for reportMatePairs() itself). F1's OWN exclusion still
      # must produce at least one "user-excluded" row.
      expect_true(any(f1Excluded$reason == "user-excluded"))
      expect_true(all(f1Excluded$reason %in% c(
        "under minimum age", "user-excluded"
      )))
    }
  )
})

test_that("an unchecked exclude-list toggle applies no user exclusions, even with stale text present", {
  skip_if_not_installed("shiny")

  ped <- matePairPed()
  kmat <- matePairKmat(ped)

  shiny::testServer(
    modMatePairServer,
    args = list(
      pedigree = shiny::reactive(ped),
      kinshipMatrix = shiny::reactive(kmat),
      markerKinshipMatrix = shiny::reactive(NULL),
      geneticValues = shiny::reactive(NULL)
    ),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1,
                        useExcludeList = FALSE, excludeIds = "F1")
      session$setInputs(analyze = 1)

      pairs <- session$getReturned()$pairs()
      expect_true(any(pairs$sireId == "M1" & pairs$damId == "F1"))
    }
  )
})

test_that("markerKinship is NA when markerKinshipMatrix is NULL (no genotype file uploaded yet)", {
  skip_if_not_installed("shiny")

  ped <- matePairPed()
  kmat <- matePairKmat(ped)

  shiny::testServer(
    modMatePairServer,
    args = list(
      pedigree = shiny::reactive(ped),
      kinshipMatrix = shiny::reactive(kmat),
      markerKinshipMatrix = shiny::reactive(NULL),
      geneticValues = shiny::reactive(NULL)
    ),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1)
      session$setInputs(analyze = 1)

      pairs <- session$getReturned()$pairs()
      expect_true(all(is.na(pairs$markerKinship)))
    }
  )
})

test_that("markerKinship is populated from markerKinshipMatrix when both ids are genotyped", {
  skip_if_not_installed("shiny")

  ped <- matePairPed()
  kmat <- matePairKmat(ped)
  markerKmat <- matrix(
    c(0.5, 0.12, 0.12, 0.5),
    nrow = 2L, ncol = 2L,
    dimnames = list(c("M1", "F1"), c("M1", "F1"))
  )

  shiny::testServer(
    modMatePairServer,
    args = list(
      pedigree = shiny::reactive(ped),
      kinshipMatrix = shiny::reactive(kmat),
      markerKinshipMatrix = shiny::reactive(markerKmat),
      geneticValues = shiny::reactive(NULL)
    ),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1)
      session$setInputs(analyze = 1)

      pairs <- session$getReturned()$pairs()
      m1f1 <- pairs[pairs$sireId == "M1" & pairs$damId == "F1", ]
      expect_identical(nrow(m1f1), 1L)
      expect_identical(m1f1$markerKinship, markerKmat["M1", "F1"])

      # M2 x F2 -- neither genotyped -- stays NA, not dropped.
      m2f2 <- pairs[pairs$sireId == "M2" & pairs$damId == "F2", ]
      expect_identical(nrow(m2f2), 0L) # M2 not alive, correctly absent
    }
  )
})

test_that("geneticValues is wrapped as list(report = ...) before reaching reportMatePairs() (D7 wiring)", {
  skip_if_not_installed("shiny")

  ped <- matePairPed()
  kmat <- matePairKmat(ped)
  gv <- matePairGvReport()

  shiny::testServer(
    modMatePairServer,
    args = list(
      pedigree = shiny::reactive(ped),
      kinshipMatrix = shiny::reactive(kmat),
      markerKinshipMatrix = shiny::reactive(NULL),
      geneticValues = shiny::reactive(gv)
    ),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1)
      session$setInputs(analyze = 1)

      pairs <- session$getReturned()$pairs()
      m1f2 <- pairs[pairs$sireId == "M1" & pairs$damId == "F2", ]
      expect_identical(nrow(m1f2), 1L)

      expectedSire <- gv[gv$id == "M1", ]
      expectedDam <- gv[gv$id == "F2", ]
      # If the module ever passed the flat `gv` data.frame straight through
      # instead of list(report = gv), reportMatePairs()'s own
      # `!is.null(geneticValues$report)` guard would see NULL (a data.frame's
      # `$report` accessor returns NULL, not an error) and every one of these
      # would be silently NA instead of a real value.
      expect_identical(m1f2$sireIndivMeanKin, expectedSire$indivMeanKin)
      expect_identical(m1f2$sireGu, expectedSire$gu)
      expect_identical(m1f2$damIndivMeanKin, expectedDam$indivMeanKin)
      expect_identical(m1f2$damGu, expectedDam$gu)
    }
  )
})

test_that("downloadPairs exports the full pairs table when no DT filter is active", {
  skip_if_not_installed("shiny")

  ped <- matePairPed()
  kmat <- matePairKmat(ped)

  shiny::testServer(
    modMatePairServer,
    args = list(
      pedigree = shiny::reactive(ped),
      kinshipMatrix = shiny::reactive(kmat),
      markerKinshipMatrix = shiny::reactive(NULL),
      geneticValues = shiny::reactive(NULL)
    ),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1)
      session$setInputs(analyze = 1)

      pairs <- session$getReturned()$pairs()
      df <- utils::read.csv(output$downloadPairs, stringsAsFactors = FALSE)
      expect_identical(nrow(df), nrow(pairs))
      expect_setequal(pairKey(df), pairKey(pairs))
    }
  )
})

test_that("downloadPairs exports only the DT-filtered rows (Dragon 4)", {
  skip_if_not_installed("shiny")

  ped <- matePairPed()
  kmat <- matePairKmat(ped)

  shiny::testServer(
    modMatePairServer,
    args = list(
      pedigree = shiny::reactive(ped),
      kinshipMatrix = shiny::reactive(kmat),
      markerKinshipMatrix = shiny::reactive(NULL),
      geneticValues = shiny::reactive(NULL)
    ),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1)
      session$setInputs(analyze = 1)

      pairs <- session$getReturned()$pairs()
      stopifnot(nrow(pairs) >= 2L) # fixture sanity: allAlive yields > 1 pair

      # DT's `<id>_rows_all` is a 1-indexed R row-position vector of every row
      # surviving the current search/filter (works identically in server and
      # client DT processing modes). Simulate a filter down to row 1 only.
      session$setInputs(pairsTable_rows_all = 1L)

      df <- utils::read.csv(output$downloadPairs, stringsAsFactors = FALSE)
      expect_identical(nrow(df), 1L)
      expect_identical(pairKey(df), pairKey(pairs[1L, , drop = FALSE]))
    }
  )
})

test_that("a population scope with zero eligible individuals renders an empty, non-crashing result", {
  skip_if_not_installed("shiny")

  ped <- matePairPed()
  kmat <- matePairKmat(ped)

  shiny::testServer(
    modMatePairServer,
    args = list(
      pedigree = shiny::reactive(ped),
      kinshipMatrix = shiny::reactive(kmat),
      markerKinshipMatrix = shiny::reactive(NULL),
      geneticValues = shiny::reactive(NULL)
    ),
    {
      session$setInputs(populationSource = "custom",
                        customPopulationIds = "", minAge = 1)
      expect_no_error(session$setInputs(analyze = 1))

      result <- session$getReturned()
      expect_true(result$isReady())
      expect_identical(nrow(result$pairs()), 0L)
      expectedCols <- c(
        "sireId", "damId", "kinship", "markerKinship",
        "sireIndivMeanKin", "sireGu", "damIndivMeanKin", "damGu"
      )
      expect_true(all(expectedCols %in% names(result$pairs())))
    }
  )
})
