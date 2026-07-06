# Coverage backfill for modBreedingGroups.R (issue #111, slice 10). Drives the
# branches the happy-path suites never reach: the geneticValues-supplied
# kinship matrix, the NULL-groupResults guards in the returned reactives, and
# the currentGroups truncation guard. Group formation is slow, so skip on CRAN
# (still measured under covr, which sets NOT_CRAN=true).

testthat::skip_on_cran()

covBgPed <- function(n = 14L) {
  ped <- data.frame(
    id = paste0("A", seq_len(n)),
    sire = NA_character_, dam = NA_character_,
    sex = rep(c("M", "F"), length.out = n),
    birth = as.Date("2015-01-01") - seq_len(n) * 90L,
    exit = as.Date(NA),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  ped
}

test_that("getKinshipMatrix uses a geneticValues-supplied kinship matrix", {
  skip_if_not_installed("shiny")

  ped <- covBgPed(14L)
  kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ ped }),
      geneticValues = shiny::reactive({ list(id = ped$id, kinship = kmat) })
    ),
    {
      session$setInputs(
        animalSource = "all", nGroups = 2, maxKinship = 0.25,
        sexRatio = "none"
      )
      session$setInputs(formGroups = 1)

      groups <- session$getReturned()$groups()
      expect_true(is.list(groups))
      # getKinshipMatrix returned the supplied matrix verbatim (the
      # geneticValues branch), not a fresh pedigree recompute.
      expect_identical(groupResults()$kmat, kmat)
    }
  )
})

test_that("returned reactives are inert before any groups are formed", {
  skip_if_not_installed("shiny")

  ped <- covBgPed(14L)

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ ped }),
      geneticValues = NULL
    ),
    {
      # groupResults() is NULL until formGroups fires, so score/unassigned/
      # groupKinship must return their NULL-guard defaults.
      r <- session$getReturned()
      expect_equal(r$score(), 0L)
      expect_identical(r$unassigned(), character(0L))
      expect_null(r$groupKinship())
    }
  )
})

test_that("currentGroups is truncated when numGp is below its length", {
  skip_if_not_installed("shiny")

  ped <- covBgPed(14L)

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ ped }),
      geneticValues = NULL
    ),
    {
      # nGroups = 0 (below the UI min of 1) makes the unseeded currentGroups
      # (length 1) exceed numGp (0), exercising the truncation guard.
      # Formation then degenerates to no groups without an uncaught error.
      session$setInputs(
        animalSource = "all", nGroups = 0, maxKinship = 0.25,
        sexRatio = "none", seedGroups = FALSE
      )
      # The degenerate numGp = 0 also makes the downstream formation warn
      # ("items to replace"); the guard at L269 itself is clean, so suppress
      # the incidental warning from the degenerate input.
      suppressWarnings(session$setInputs(formGroups = 1))

      groups <- session$getReturned()$groups()
      expect_true(is.list(groups))
      expect_length(groups, 0L)
    }
  )
})
