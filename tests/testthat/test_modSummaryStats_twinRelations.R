# Tests for BL-N Slice 3 (twinRelations-into-kinship() plan, docs/planning/
# twin-relations-kinship-computation-plan.md sec 4): a declared MZ-twin pair
# threaded into the summary-stats module's FALLBACK kinship recompute
# (modSummaryStats.R getKinshipMatrix(), the kinship() path -- the primary
# path whenever the shared appServer kinship reactive is unavailable).
# Mirrors test_modSummaryStats_kinshipOverrides.R's fixture/testServer shape
# exactly -- the closest existing precedent for a second, optional reactive
# parameter threaded into this same helper.

testthat::skip_on_cran()

# Reuses test_kinship.R's own fam1 fixture (subjects 8/9 declared MZ twins,
# 10 a child of twin 8 -- the propagation case) and test_reportGV.R's own
# Slice 2 sex-column extension, so the ground-truth values (0.5, 0.28125)
# are pinned identically across every slice's own test suite.
twinSsPed <- function() {
  ped <- data.frame(
    id   = as.character(1:10),
    sire = c(NA, NA, "1", "1", NA, NA, "3", "6", "6", "8"),
    dam  = c(NA, NA, "2", "2", NA, NA, "5", "4", "4", "7"),
    sex  = c("M", "F", "M", "F", "M", "F", "F", "M", "M", "F"),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  ped
}

twinSsTwins <- function() {
  data.frame(id1 = "8", id2 = "9", code = "MZ twin", stringsAsFactors = FALSE)
}

# Extract the single long-form relationship row for an unordered pair
# (mirrors test_modSummaryStats_kinshipOverrides.R's own pairRow() helper).
pairRow <- function(rel, a, b) {
  rel[(rel$id1 == a & rel$id2 == b) | (rel$id1 == b & rel$id2 == a), ,
      drop = FALSE]
}

test_that(paste("modSummaryStatsServer applies twinRelations on the",
                "fallback recompute (Slice 3)"), {
  skip_if_not_installed("shiny")
  test_ped <- twinSsPed()

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ NULL }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL,                        # force the fallback path
      twinRelations = shiny::reactive({ twinSsTwins() })
    ),
    {
      km <- getKinshipMatrix()
      expect_equal(km["8", "9"], 0.5)
      expect_equal(km["9", "10"], 0.28125)
    }
  )
})

test_that(paste("modSummaryStatsServer relationship table reflects the",
                "twin-corrected kinship value (Slice 3)"), {
  skip_if_not_installed("shiny")
  test_ped <- twinSsPed()

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ NULL }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL,
      twinRelations = shiny::reactive({ twinSsTwins() })
    ),
    {
      rel <- relationshipData()
      row <- pairRow(rel, "8", "9")
      expect_equal(nrow(row), 1L)
      expect_equal(row$kinship, 0.5)
    }
  )
})

test_that(paste("modSummaryStatsServer fallback is byte-identical with no",
                "twinRelations (backward compatibility, Slice 3)"), {
  skip_if_not_installed("shiny")
  test_ped <- twinSsPed()

  expected <- kinship(test_ped$id, test_ped$sire, test_ped$dam, test_ped$gen,
                      sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ NULL }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL,
      twinRelations = shiny::reactive({ NULL })
    ),
    {
      km <- getKinshipMatrix()
      expect_equal(km, expected)
      expect_equal(km["8", "9"], 0.25)
    }
  )
})
