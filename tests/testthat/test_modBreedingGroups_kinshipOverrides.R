# Tests for issue #13 Slice 3: outside-information kinship overrides applied on
# the breeding-group module's FALLBACK kinship recompute (modBreedingGroups.R
# getKinshipMatrix(), the kinship() path taken when no Genetic Value output is
# available). Overrides must reach the matrix that feeds group formation
# regardless of tab order. Slow shiny-module integration tests; skip on CRAN,
# mirroring test_modBreedingGroups.R.

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

test_that(paste("modBreedingGroupsServer applies a kinship override on the",
                "fallback recompute (no GV output)"), {
  skip_if_not_installed("shiny")
  test_ped <- makeOverridePed()

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL,                       # force the fallback kinship()
      kinshipOverrides = shiny::reactive({ ovrFrame("F1", "F2", 0.4) })
    ),
    {
      km <- getKinshipMatrix(pedigree(), geneticValues, kinshipOverrides())
      expect_equal(km["F1", "F2"], 0.4)
      expect_equal(km["F2", "F1"], 0.4)           # symmetric write
    }
  )
})

test_that(paste("modBreedingGroupsServer fallback is byte-identical with no",
                "override (D10)"), {
  skip_if_not_installed("shiny")
  test_ped <- makeOverridePed()

  expected_ped <- test_ped
  expected_ped$gen <- findGeneration(expected_ped$id, expected_ped$sire,
                                     expected_ped$dam)
  expected <- kinship(expected_ped$id, expected_ped$sire, expected_ped$dam,
                      expected_ped$gen)

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL,
      kinshipOverrides = shiny::reactive({ NULL })
    ),
    {
      km <- getKinshipMatrix(pedigree(), geneticValues, kinshipOverrides())
      expect_equal(km, expected)
    }
  )
})

test_that(paste("modBreedingGroupsServer warn-drops an override id absent from",
                "the matrix and does not abort (D5)"), {
  skip_if_not_installed("shiny")
  test_ped <- makeOverridePed()

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL,
      kinshipOverrides = shiny::reactive({ ovrFrame("F1", "GHOST", 0.2) })
    ),
    {
      expect_warning(
        km <- getKinshipMatrix(pedigree(), geneticValues, kinshipOverrides())
      )
      expect_true(is.matrix(km))
      expect_true("F1" %in% rownames(km))
      expect_false("GHOST" %in% rownames(km))
    }
  )
})
