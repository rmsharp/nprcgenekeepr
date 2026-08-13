# Tests for BL-N Slice 3 (twinRelations-into-kinship() plan, docs/planning/
# twin-relations-kinship-computation-plan.md sec 4): a declared MZ-twin pair
# threaded into the breeding-group module's FALLBACK kinship recompute
# (modBreedingGroups.R getKinshipMatrix(), the kinship() path taken when no
# Genetic Value output is available). Mirrors
# test_modBreedingGroups_kinshipOverrides.R's fixture/testServer shape exactly
# -- the closest existing precedent for a second, optional reactive parameter
# threaded into this same helper. Slow shiny-module integration tests; skip on
# CRAN, mirroring test_modBreedingGroups.R.

testthat::skip_on_cran()

# Reuses test_kinship.R's own fam1 fixture (subjects 8/9 declared MZ twins,
# 10 a child of twin 8 -- the propagation case) and test_reportGV.R's own
# Slice 2 sex-column extension, so the ground-truth values (0.5, 0.28125)
# are pinned identically across every slice's own test suite.
twinBgPed <- function() {
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

twinBgTwins <- function() {
  data.frame(id1 = "8", id2 = "9", code = "MZ twin", stringsAsFactors = FALSE)
}

test_that(paste("modBreedingGroupsServer applies twinRelations on the",
                "fallback recompute (no GV output) (Slice 3)"), {
  skip_if_not_installed("shiny")
  test_ped <- twinBgPed()

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL,                       # force the fallback kinship()
      twinRelations = shiny::reactive({ twinBgTwins() })
    ),
    {
      km <- getKinshipMatrix(pedigree(), kinshipMatrix, overrides = NULL,
                             twinRelations = twinRelations())
      expect_equal(km["8", "9"], 0.5)
      expect_equal(km["9", "10"], 0.28125)
    }
  )
})

test_that(paste("modBreedingGroupsServer fallback is byte-identical with no",
                "twinRelations (backward compatibility, Slice 3)"), {
  skip_if_not_installed("shiny")
  test_ped <- twinBgPed()

  expected <- kinship(test_ped$id, test_ped$sire, test_ped$dam, test_ped$gen)

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL,
      twinRelations = shiny::reactive({ NULL })
    ),
    {
      km <- getKinshipMatrix(pedigree(), kinshipMatrix, overrides = NULL,
                             twinRelations = twinRelations())
      expect_equal(km, expected)
      expect_equal(km["8", "9"], 0.25)
    }
  )
})
