# Tests for issue #122 (XARCH-2) Phase 2: modBreedingGroupsServer gains a
# kinshipMatrix reactive param so it can share one full-pedigree kinship
# matrix (hoisted into appServer) with modSummaryStatsServer instead of each
# module independently recomputing it. See
# docs/planning/issue122-module-contract-plan.md section 6 Phase 2.

testthat::skip_on_cran()

makeSharedKinPed <- function() {
  data.frame(
    id   = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam  = c(NA, NA, "B"),
    sex  = c("M", "F", "F"),
    stringsAsFactors = FALSE
  )
}

test_that(paste("modBreedingGroupsServer uses a provided kinshipMatrix",
                "reactive directly (issue #122 Phase 2)"), {
  skip_if_not_installed("shiny")
  test_ped <- makeSharedKinPed()

  # Deliberately NOT the pedigree's own kinship() values, so using the
  # injected matrix is distinguishable from a fresh recompute.
  test_kmat <- matrix(
    c(0.50, 0.11, 0.22,
      0.11, 0.50, 0.22,
      0.22, 0.22, 0.50),
    nrow = 3, ncol = 3,
    dimnames = list(c("A", "B", "C"), c("A", "B", "C"))
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = NULL,
      kinshipMatrix = shiny::reactive({ test_kmat }),
      kinshipOverrides = shiny::reactive({ NULL })
    ),
    {
      km <- getKinshipMatrix(pedigree(), kinshipMatrix, kinshipOverrides())
      expect_equal(km, test_kmat)
    }
  )
})

test_that(paste("modBreedingGroupsServer falls back to pedigree recompute",
                "when kinshipMatrix is NULL (D3 fallback retained)"), {
  skip_if_not_installed("shiny")
  test_ped <- makeSharedKinPed()

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
      kinshipMatrix = NULL,
      kinshipOverrides = shiny::reactive({ NULL })
    ),
    {
      km <- getKinshipMatrix(pedigree(), kinshipMatrix, kinshipOverrides())
      expect_equal(km, expected)
    }
  )
})
