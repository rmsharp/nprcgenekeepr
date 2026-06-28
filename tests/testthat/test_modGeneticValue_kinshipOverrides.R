# Tests for issue #13 Slice 2: outside-information kinship overrides uploaded in
# the Genetic Value tab. The module reads an id1,id2,kinship file and threads it
# into reportGV(kinshipOverrides = ...). Slow (reportGV); skip on CRAN, mirroring
# test_modGeneticValue.R.

testthat::skip_on_cran()

# Deterministic small pedigree: F1..F3 male founders, F4..F6 female founders,
# O1..O6 offspring. F1 and F2 are both-unknown founders (no issue-#9 one-unknown
# correction), so an override on the (F1, F2) cell moves F1's mean kinship
# deterministically -- mean kinship is read straight off the kinship matrix, not
# from the (random) gene-drop, so the assertion is stable.
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

# Build the data.frame shiny's fileInput hands the server for an uploaded file.
fileInfo <- function(path) {
  data.frame(
    name = basename(path), size = 1L, type = "text/csv",
    datapath = path, stringsAsFactors = FALSE
  )
}

f1MeanKin <- function(rpt) {
  rpt$indivMeanKin[rpt$id == "F1"]
}

test_that(paste("modGeneticValueServer applies an uploaded kinship override and",
                "raises the overridden animal's mean kinship"), {
  skip_if_not_installed("shiny")
  test_ped <- makeOverridePed()

  ovrCsv <- tempfile(fileext = ".csv")
  on.exit(unlink(ovrCsv), add = TRUE)
  writeLines(c("id1,id2,kinship", "F1,F2,0.4"), ovrCsv)

  shiny::testServer(
    modGeneticValueServer,
    args = list(pedigree = shiny::reactive({ test_ped })),
    {
      session$setInputs(nIterations = 100, topN = 10)

      # Baseline: no override file uploaded.
      session$setInputs(runAnalysis = 1)
      baseline <- gvResults()
      baseKin <- f1MeanKin(baseline)

      # Upload a valid override raising the (F1, F2) kinship to 0.4.
      session$setInputs(kinshipOverrideFile = fileInfo(ovrCsv))
      session$setInputs(runAnalysis = 2)
      overridden <- gvResults()
      ovrKin <- f1MeanKin(overridden)

      expect_true(is.data.frame(overridden))
      expect_false(isTRUE(all.equal(baseKin, ovrKin)))
      expect_gt(ovrKin, baseKin)
    }
  )
})

test_that(paste("modGeneticValueServer accepts an override file carrying a",
                "missingSideFor column (issue #95 option C upload path)"), {
  skip_if_not_installed("shiny")
  test_ped <- makeOverridePed()

  ovrCsv <- tempfile(fileext = ".csv")
  on.exit(unlink(ovrCsv), add = TRUE)
  # 4-column file: the optional missingSideFor column must ride through
  # readKinshipOverrides (check.names = FALSE) and checkKinshipOverrides into
  # reportGV without breaking the upload path. F1/F2 are both-unknown, so the
  # missing-side classification is a no-op here; the point is the new column is
  # accepted and the matrix override still applies (F1's mean kinship rises).
  writeLines(c("id1,id2,kinship,missingSideFor", "F1,F2,0.4,"), ovrCsv)

  shiny::testServer(
    modGeneticValueServer,
    args = list(pedigree = shiny::reactive({ test_ped })),
    {
      session$setInputs(nIterations = 100, topN = 10)
      session$setInputs(runAnalysis = 1)
      baseKin <- f1MeanKin(gvResults())

      session$setInputs(kinshipOverrideFile = fileInfo(ovrCsv))
      session$setInputs(runAnalysis = 2)
      overridden <- gvResults()

      expect_true(is.data.frame(overridden))
      expect_gt(f1MeanKin(overridden), baseKin)
    }
  )
})

test_that("modGeneticValueServer ignores a malformed override file (non-fatal, D5)", {
  skip_if_not_installed("shiny")
  test_ped <- makeOverridePed()

  badCsv <- tempfile(fileext = ".csv")
  on.exit(unlink(badCsv), add = TRUE)
  # Missing the required 'kinship' column -> checkKinshipOverrides() stop()s; the
  # module must catch it and continue (never abort the GV run -- D5).
  writeLines(c("id1,id2", "F1,F2"), badCsv)

  shiny::testServer(
    modGeneticValueServer,
    args = list(pedigree = shiny::reactive({ test_ped })),
    {
      session$setInputs(nIterations = 100, topN = 10)

      session$setInputs(runAnalysis = 1)
      cleanKin <- f1MeanKin(gvResults())

      session$setInputs(kinshipOverrideFile = fileInfo(badCsv))
      session$setInputs(runAnalysis = 2)
      bad <- gvResults()

      expect_true(is.data.frame(bad) && nrow(bad) > 0L)
      expect_equal(f1MeanKin(bad), cleanKin)
    }
  )
})

test_that("modGeneticValueServer is unaffected when no override file is uploaded (D10)", {
  skip_if_not_installed("shiny")
  test_ped <- makeOverridePed()

  shiny::testServer(
    modGeneticValueServer,
    args = list(pedigree = shiny::reactive({ test_ped })),
    {
      session$setInputs(nIterations = 100, topN = 10)
      session$setInputs(runAnalysis = 1)
      res <- gvResults()
      expect_true(is.data.frame(res))
      expect_true(all(c("id", "indivMeanKin") %in% names(res)))
      expect_true(nrow(res) > 0L)
    }
  )
})
