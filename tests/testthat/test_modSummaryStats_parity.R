# Phase 1 (Shiny-module conversion plan) — Summary Statistics tab parity.
#
# Discriminating RED tests for four monolith-parity gaps in modSummaryStats
# (see docs/planning/shiny-module-conversion-plan.md Section 9, Phase 1):
#   1. Z-score histogram/boxplot: reportGV emits column "zScores" (plural),
#      but the module checked "zScore" (singular) -> the plots were always
#      NULL. The pre-existing _ggplots tests pass on this bug because their
#      fixture injects BOTH names (Learning #15/#20); these use ONLY "zScores".
#   2. Mean-Kinship / Genome-Uniqueness quartile distribution tables
#      (monolith inst/application/server.r:545-630).
#   3. Founder table (Known/Female/Male counts + FE + FG) on the Summary tab
#      (monolith server.r:558-570), threaded from modGeneticValue's founderStats.
#   4. Kinship-matrix download: a dead button (req() on a NULL kinshipMatrix
#      arg, modSummaryStats.R:596 with appServer.R:278 passing NULL).

# ---- shared fixtures -------------------------------------------------------

# GV data using reportGV's REAL column name "zScores" (plural) and NO
# "zScore" (singular) — exactly what modGeneticValue passes through.
makeParityGV <- function() {
  data.frame(
    id = c("A", "B", "C", "D", "E"),
    meanKinship = c(0.10, 0.15, 0.20, 0.25, 0.30),
    genomeUniqueness = c(0.90, 0.85, 0.80, 0.75, 0.70),
    zScores = c(-1.2, -0.6, 0.0, 0.6, 1.2),
    stringsAsFactors = FALSE
  )
}

# A small, fully-specified pedigree valid for kinship() computation.
makeParityPed <- function() {
  data.frame(
    id = c("A", "B", "C", "D", "E"),
    sire = c(NA, NA, "A", "A", "C"),
    dam = c(NA, NA, "B", "B", "D"),
    sex = c("M", "F", "F", "M", "F"),
    stringsAsFactors = FALSE
  )
}

# founderStats list shaped like modGeneticValue's founderStats reactive,
# using distinctive decimal FE/FG values that cannot collide with the
# quartile/scalar numbers elsewhere in the rendered output.
makeParityFounderStats <- function() {
  list(fe = 12.34, fg = 9.87, total = 23L,
       nMaleFounders = 8L, nFemaleFounders = 15L)
}

# ---- Item 1: z-score plots read the real "zScores" column ------------------

test_that("zscoreHistogram renders from reportGV's real 'zScores' column", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")
  gv <- makeParityGV()
  ped <- makeParityPed()
  # Fixture intent: only the real plural name is present.
  expect_false("zScore" %in% names(gv))
  expect_true("zScores" %in% names(gv))

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive(gv),
      pedigree = shiny::reactive(ped),
      kinshipMatrix = NULL
    ),
    {
      result <- session$getReturned()
      plot <- result$zscoreHistogram()
      expect_false(is.null(plot))
      expect_s3_class(plot, "ggplot")
    }
  )
})

test_that("zscoreBoxPlot renders from reportGV's real 'zScores' column", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")
  gv <- makeParityGV()
  ped <- makeParityPed()

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive(gv),
      pedigree = shiny::reactive(ped),
      kinshipMatrix = NULL
    ),
    {
      result <- session$getReturned()
      plot <- result$zscoreBoxPlot()
      expect_false(is.null(plot))
      expect_s3_class(plot, "ggplot")
    }
  )
})

# ---- Item 2: MK / GU quartile distribution tables --------------------------

test_that("Summary module exposes MK and GU quartile summaries", {
  skip_if_not_installed("shiny")
  gv <- makeParityGV()
  ped <- makeParityPed()

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive(gv),
      pedigree = shiny::reactive(ped),
      kinshipMatrix = NULL
    ),
    {
      result <- session$getReturned()
      expect_true("mkSummary" %in% names(result))
      expect_true("guSummary" %in% names(result))
      expect_equal(result$mkSummary(), summary(gv$meanKinship))
      expect_equal(result$guSummary(), summary(gv$genomeUniqueness))
    }
  )
})

test_that("Summary tab renders the MK/GU quartile distribution tables", {
  skip_if_not_installed("shiny")
  gv <- makeParityGV()
  ped <- makeParityPed()

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive(gv),
      pedigree = shiny::reactive(ped),
      kinshipMatrix = NULL
    ),
    {
      html <- as.character(output$summaryStats$html)
      expect_match(html, "Quartile")
      expect_match(html, "Mean Kinship")
      expect_match(html, "Genome Uniqueness")
    }
  )
})

# ---- Item 3: founder table on the Summary tab ------------------------------

test_that("Summary tab renders the founder table when founderStats is supplied", {
  skip_if_not_installed("shiny")
  gv <- makeParityGV()
  ped <- makeParityPed()
  fs <- makeParityFounderStats()

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive(gv),
      pedigree = shiny::reactive(ped),
      kinshipMatrix = NULL,
      founderStats = shiny::reactive(fs)
    ),
    {
      html <- as.character(output$summaryStats$html)
      expect_match(html, "Founder Equivalents")
      expect_match(html, "Founder Genome Equivalents")
      expect_match(html, "Known Founders")
      expect_match(html, "12.34") # FE rounded to 2 decimals
      expect_match(html, "9.87")  # FG rounded to 2 decimals
    }
  )
})

# ---- Item 4: kinship-matrix download is no longer a dead button ------------

test_that("kinship download writes a non-empty matrix when kinshipMatrix arg is NULL", {
  skip_if_not_installed("shiny")
  gv <- makeParityGV()
  ped <- makeParityPed()

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive(gv),
      pedigree = shiny::reactive(ped),
      kinshipMatrix = NULL
    ),
    {
      # On the current code this throws (req() on the NULL kinshipMatrix arg).
      path <- output$downloadKinship
      expect_true(file.exists(path))
      lines <- readLines(path)
      expect_gt(length(lines), 1L) # header + >= 1 data row
      blob <- paste(lines, collapse = "\n")
      expect_match(blob, "A")
      expect_match(blob, "E")
    }
  )
})
