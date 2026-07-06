# Tests for issue #111 slice 8: coverage backfill for modGeneticValue.R. These
# shiny::testServer tests drive the residual uncovered branches that the two
# existing suites do not reach: the kinship-override warning handler, the
# empty-probands fallback, and several defensive report-shape guards reached via
# a mocked reportGV. Slow (testServer); skip on CRAN, mirroring
# test_modGeneticValue.R.

testthat::skip_on_cran()

# Minimal valid pedigree: founders (first half male) + offspring with valid
# sire/dam references, enough to survive trimPedigree()/findGeneration().
mkCovPed <- function(nF = 6L, nO = 14L) {
  nM <- nF %/% 2L
  founders <- data.frame(
    id = paste0("F", seq_len(nF)),
    sire = NA_character_, dam = NA_character_,
    sex = c(rep("M", nM), rep("F", nF - nM)),
    stringsAsFactors = FALSE
  )
  mF <- founders$id[founders$sex == "M"]
  fF <- founders$id[founders$sex == "F"]
  off <- data.frame(
    id = paste0("O", seq_len(nO)),
    sire = rep(mF, length.out = nO),
    dam = rep(fF, length.out = nO),
    sex = rep(c("M", "F"), length.out = nO),
    stringsAsFactors = FALSE
  )
  rbind(founders, off)
}

# The data.frame shiny's fileInput hands the server for an uploaded file.
covFileInfo <- function(path) {
  data.frame(name = basename(path), size = 1L, type = "text/csv",
             datapath = path, stringsAsFactors = FALSE)
}

# A minimal reportGV-shaped return whose report data.frame the caller supplies,
# so a mocked reportGV can drive the gvResults()/gvSummary defensive branches
# without running the real gene-drop analysis.
covFakeReport <- function(report) {
  list(report = report, kinship = matrix(0, 2L, 2L), gu = data.frame(),
       fe = 1, fg = 1, fgSE = NULL, total = 2L,
       nMaleFounders = 1L, nFemaleFounders = 1L,
       maleFounders = data.frame(), femaleFounders = data.frame())
}

# ---------------------------------------------------------------------------
# kinshipOverrideData(): the > 0.5 warning handler
# ---------------------------------------------------------------------------
test_that(paste("modGeneticValueServer muffles a > 0.5 kinship-override warning",
                "and still applies the override (D6)"), {
  skip_if_not_installed("shiny")

  # checkKinshipOverrides() warns on an off-diagonal kinship > 0.5 (valid only
  # for inbred pairs). The module's warning handler surfaces it as a
  # showNotification and muffles it, keeping the validated override -- the GV
  # run is never aborted (D6). Reading kinshipOverrideData() exercises that
  # handler without needing reportGV.
  ovrCsv <- tempfile(fileext = ".csv")
  on.exit(unlink(ovrCsv), add = TRUE)
  writeLines(c("id1,id2,kinship", "F1,F2,0.6"), ovrCsv)

  shiny::testServer(
    modGeneticValueServer,
    args = list(pedigree = shiny::reactive({ mkCovPed() })),
    {
      session$setInputs(kinshipOverrideFile = covFileInfo(ovrCsv))
      # The warning is muffled inside the module, so none escapes here.
      expect_no_warning(ov <- kinshipOverrideData())
      expect_s3_class(ov, "data.frame")
      expect_equal(nrow(ov), 1L)
      expect_equal(ov$kinship, 0.6)
    }
  )
})

# ---------------------------------------------------------------------------
# gvResults(): empty-probands fallback
# ---------------------------------------------------------------------------
test_that(paste("modGeneticValueServer falls back to all ids when the",
                "population column selects none"), {
  skip_if_not_installed("shiny")

  # A pedigree carrying a population column that is all FALSE leaves probands
  # empty; the module must fall back to every id and set population TRUE so the
  # analysis still runs. reportGV is mocked to isolate the pre-analysis branch.
  ped <- mkCovPed()
  ped$population <- FALSE
  local_mocked_bindings(
    reportGV = function(...) covFakeReport(
      data.frame(id = c("A", "B"), indivMeanKin = c(0.1, 0.2),
                 gu = c(0.5, 0.4), value = c("a", "b"),
                 stringsAsFactors = FALSE))
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(pedigree = shiny::reactive({ ped })),
    {
      session$setInputs(nIterations = 100, runAnalysis = 1)
      res <- gvResults()
      expect_s3_class(res, "data.frame")
      expect_setequal(res$id, c("A", "B"))
    }
  )
})

# ---------------------------------------------------------------------------
# gvResults()/gvaView()/geneticValues()/topAnimals(): NULL-report guards
# ---------------------------------------------------------------------------
test_that(paste("modGeneticValueServer returns NULL when reportGV yields no",
                "report, and every consumer guards on it"), {
  skip_if_not_installed("shiny")

  # Defensive edge case: reportGV returns a report of NULL (no expected
  # columns). gvResults() returns it as-is (NULL), and gvaView(),
  # geneticValues(), and topAnimals() each short-circuit to NULL.
  local_mocked_bindings(reportGV = function(...) covFakeReport(NULL))

  shiny::testServer(
    modGeneticValueServer,
    args = list(pedigree = shiny::reactive({ mkCovPed() })),
    {
      session$setInputs(nIterations = 100, runAnalysis = 1)
      expect_null(gvResults())
      expect_null(gvaView())
      out <- session$getReturned()
      expect_null(out$geneticValues())
      expect_null(out$topAnimals())
    }
  )
})

# ---------------------------------------------------------------------------
# gvResults(): demote else-branch when the report has no value column
# ---------------------------------------------------------------------------
test_that(paste("modGeneticValueServer ranks without demotion when the report",
                "has no value column"), {
  skip_if_not_installed("shiny")

  # When reportGV's report lacks a 'value' column, no row can be Undetermined,
  # so the demotion vector is all FALSE and rows keep their genetic-value rank.
  local_mocked_bindings(
    reportGV = function(...) covFakeReport(
      data.frame(id = c("A", "B", "C"), indivMeanKin = c(0.3, 0.1, 0.2),
                 gu = c(0.4, 0.6, 0.5), stringsAsFactors = FALSE))
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(pedigree = shiny::reactive({ mkCovPed() })),
    {
      session$setInputs(nIterations = 100, runAnalysis = 1)
      res <- gvResults()
      expect_equal(nrow(res), 3L)
      expect_false("value" %in% names(res))
      # No demotion -> rank is the plain 1..n genetic-value order.
      expect_equal(res$rank, seq_len(nrow(res)))
    }
  )
})

# ---------------------------------------------------------------------------
# gvSummary: genomeUniquenessSE fallback when guSE is absent
# ---------------------------------------------------------------------------
test_that(paste("modGeneticValueServer gvSummary reports the",
                "genomeUniquenessSE column when guSE is absent"), {
  skip_if_not_installed("shiny")

  # The Summary panel prefers a 'guSE' column but falls back to
  # 'genomeUniquenessSE'; when only the latter is present it reports that
  # column's worst-case (maximum) value.
  local_mocked_bindings(
    reportGV = function(...) covFakeReport(
      data.frame(id = c("A", "B"), indivMeanKin = c(0.1, 0.2),
                 gu = c(0.5, 0.4), genomeUniquenessSE = c(0.01, 0.02),
                 value = c("a", "b"), stringsAsFactors = FALSE))
  )

  shiny::testServer(
    modGeneticValueServer,
    args = list(pedigree = shiny::reactive({ mkCovPed() })),
    {
      session$setInputs(nIterations = 100, runAnalysis = 1)
      tbl <- output$gvSummary
      expect_true(any(grepl("Genome Uniqueness SE", tbl)))
      # max(genomeUniquenessSE) = 0.02 -> "0.0200"
      expect_true(any(grepl("0.0200", tbl)))
    }
  )
})
