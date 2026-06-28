# Tests for issue #13 Slice 3: outside-information kinship overrides applied on
# the summary-stats module's FALLBACK kinship recompute (modSummaryStats.R
# getKinshipMatrix(), the kinship() path -- the app always passes
# kinshipMatrix = NULL, so this path always runs). Overrides must reach the
# relationship table and the kinship CSV export. R13 (narrow + document): the
# override moves the kinship VALUE; the relation LABEL stays pedigree-derived.

testthat::skip_on_cran()

# Deterministic pedigree: F1..F6 founders (F1, F2 both-unknown), O1..O6 offspring.
# Mirrors the Slice 2 fixture so kinship() values are stable. O1's sire is F1.
makeOverridePed <- function() {
  data.frame(
    id   = c("F1", "F2", "F3", "F4", "F5", "F6",
             "O1", "O2", "O3", "O4", "O5", "O6"),
    sire = c(NA, NA, NA, NA, NA, NA,
             "F1", "F1", "F2", "F3", "F1", "F2"),
    dam  = c(NA, NA, NA, NA, NA, NA,
             "F4", "F5", "F6", "F4", "F5", "F6"),
    sex  = c("M", "M", "M", "F", "F", "F",
             "M", "F", "M", "F", "M", "F"),
    stringsAsFactors = FALSE
  )
}

ovrFrame <- function(id1, id2, kinship) {
  data.frame(id1 = id1, id2 = id2, kinship = kinship, stringsAsFactors = FALSE)
}

# Extract the single long-form relationship row for an unordered pair.
pairRow <- function(rel, a, b) {
  rel[(rel$id1 == a & rel$id2 == b) | (rel$id1 == b & rel$id2 == a), ,
      drop = FALSE]
}

test_that(paste("modSummaryStatsServer applies a kinship override on the",
                "fallback recompute"), {
  skip_if_not_installed("shiny")
  test_ped <- makeOverridePed()

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ NULL }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL,                        # always the fallback path
      kinshipOverrides = shiny::reactive({ ovrFrame("F1", "F2", 0.4) })
    ),
    {
      km <- getKinshipMatrix()
      expect_equal(km["F1", "F2"], 0.4)
      expect_equal(km["F2", "F1"], 0.4)
    }
  )
})

test_that(paste("modSummaryStatsServer relationship table reflects the override",
                "value"), {
  skip_if_not_installed("shiny")
  test_ped <- makeOverridePed()

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ NULL }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL,
      kinshipOverrides = shiny::reactive({ ovrFrame("F1", "F2", 0.4) })
    ),
    {
      rel <- relationshipData()
      row <- pairRow(rel, "F1", "F2")
      expect_equal(nrow(row), 1L)
      expect_equal(row$kinship, 0.4)
    }
  )
})

test_that(paste("modSummaryStatsServer R13 narrow: an override moves the kinship",
                "VALUE but the relation LABEL stays pedigree-derived"), {
  skip_if_not_installed("shiny")
  test_ped <- makeOverridePed()

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ NULL }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL,
      # F1 is O1's sire -> the pedigree relation is Parent-Offspring. Override the
      # cell to 0.1 (below the natural ~0.25). The kinship value must move; the
      # relation label must NOT (it is pedigree/CEPH-derived, not value-derived).
      kinshipOverrides = shiny::reactive({ ovrFrame("F1", "O1", 0.1) })
    ),
    {
      rel <- relationshipData()
      row <- pairRow(rel, "F1", "O1")
      expect_equal(nrow(row), 1L)
      expect_equal(row$kinship, 0.1)
      expect_equal(row$relation, "Parent-Offspring")
    }
  )
})

test_that(paste("modSummaryStatsServer fallback is byte-identical with no",
                "override (D10)"), {
  skip_if_not_installed("shiny")
  test_ped <- makeOverridePed()

  expected_ped <- test_ped
  expected_ped$gen <- findGeneration(expected_ped$id, expected_ped$sire,
                                     expected_ped$dam)
  expected <- kinship(expected_ped$id, expected_ped$sire, expected_ped$dam,
                      expected_ped$gen, sparse = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive({ NULL }),
      pedigree = shiny::reactive({ test_ped }),
      kinshipMatrix = NULL,
      kinshipOverrides = shiny::reactive({ NULL })
    ),
    {
      km <- getKinshipMatrix()
      expect_equal(km, expected)
    }
  )
})
