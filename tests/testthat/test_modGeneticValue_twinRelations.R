# Tests for BL-N Slice 3 (twinRelations-into-kinship() plan, docs/planning/
# twin-relations-kinship-computation-plan.md sec 4): unlike kinshipOverrides
# (a file uploaded inside this module's own UI), twinRelations does not
# originate inside modGeneticValueServer() -- it is uploaded on the Diagram
# tab (modPedigree.R) and threaded in from appServer.R as a new, external
# reactive PARAMETER (sec 2.7's own documented reason this departs from the
# kinshipOverrides precedent). Mirrors
# test_modGeneticValue_kinshipOverrides.R's fixture/testServer shape,
# substituting the parameter-injection call shape for the file-upload one.
# Slow (reportGV); skip on CRAN, mirroring test_modGeneticValue.R.

testthat::skip_on_cran()

# Reuses test_kinship.R's own fam1 fixture (subjects 8/9 declared MZ twins,
# 10 a child of twin 8 -- the propagation case) and test_reportGV.R's own
# Slice 2 sex-column extension, so the ground-truth values (0.5, 0.28125)
# are pinned identically across every slice's own test suite.
twinGvModPed <- function() {
  data.frame(
    id   = as.character(1:10),
    sire = c(NA, NA, "1", "1", NA, NA, "3", "6", "6", "8"),
    dam  = c(NA, NA, "2", "2", NA, NA, "5", "4", "4", "7"),
    sex  = c("M", "F", "M", "F", "M", "F", "F", "M", "M", "F"),
    stringsAsFactors = FALSE
  )
}

twinGvModTwins <- function() {
  data.frame(id1 = "8", id2 = "9", code = "MZ twin", stringsAsFactors = FALSE)
}

test_that(paste("modGeneticValueServer accepts an external twinRelations",
                "parameter and threads it into reportGV()'s returned",
                "kinship matrix (Slice 3)"), {
  skip_if_not_installed("shiny")
  test_ped <- twinGvModPed()

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      twinRelations = shiny::reactive({ twinGvModTwins() })
    ),
    {
      session$setInputs(nIterations = 5, topN = 10)
      session$setInputs(runAnalysis = 1)
      km <- fullResults()$kinship
      expect_equal(km["8", "9"], 0.5)
      expect_equal(km["9", "10"], 0.28125)
    }
  )
})

test_that(paste("modGeneticValueServer is unaffected when twinRelations is",
                "the default (backward compatibility, Slice 3)"), {
  skip_if_not_installed("shiny")
  test_ped <- twinGvModPed()

  shiny::testServer(
    modGeneticValueServer,
    args = list(pedigree = shiny::reactive({ test_ped })),
    {
      session$setInputs(nIterations = 5, topN = 10)
      session$setInputs(runAnalysis = 1)
      km <- fullResults()$kinship
      expect_equal(km["8", "9"], 0.25)
      expect_equal(km["9", "10"], 0.15625)
    }
  )
})
