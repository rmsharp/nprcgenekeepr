# Issue #111 coverage backfill for R/modSummaryStats.R.
#
# The existing modSummaryStats suites drive the plot/summary/relationship
# reactives and the returned list, but they never (a) pass a data.table
# pedigree, (b) exercise the boxplot NULL guards, or (c) invoke the download
# handlers via output$downloadX (test_modSummaryStats_relationships.R even
# asserts, incorrectly, that "we can't directly test downloadHandler content
# in testServer"). Only downloadKinship is driven today (parity suite). This
# suite characterizes the remaining behavior, covering the scattered residual
# lines: asDataFrame's data.table branch, the two boxplot NULL guards, and the
# eleven undriven download-handler content/filename bodies.

# ---- shared fixtures -------------------------------------------------------

# Six animals: three founders (one male, two female) and three offspring.
covPed <- function() {
  data.frame(
    id   = c("F1", "F2", "F3", "O1", "O2", "O3"),
    sire = c(NA, NA, NA, "F1", "F1", "F1"),
    dam  = c(NA, NA, NA, "F2", "F3", "F2"),
    sex  = c("M", "F", "F", "M", "F", "M"),
    stringsAsFactors = FALSE
  )
}

# Genetic values carrying meanKinship, genomeUniqueness AND the real plural
# "zScores" column, so the z-score plots are non-NULL and their download
# handlers write real files.
covGV <- function() {
  data.frame(
    id = c("F1", "F2", "F3", "O1", "O2", "O3"),
    meanKinship = c(0.10, 0.15, 0.20, 0.25, 0.30, 0.35),
    genomeUniqueness = c(0.90, 0.85, 0.80, 0.75, 0.70, 0.65),
    zScores = c(-1.2, -0.6, 0.0, 0.6, 1.2, 0.3),
    stringsAsFactors = FALSE
  )
}

# TRUE when the first four bytes of a file are the PNG signature.
isPngFile <- function(path) {
  sig <- readBin(path, what = "raw", n = 4L)
  identical(sig, as.raw(c(137L, 80L, 78L, 71L)))
}

# ---- asDataFrame data.table branch (modSummaryStats.R L350) ----------------

test_that("getKinshipMatrix converts a data.table pedigree to a data.frame", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("data.table")

  dtped <- data.table::as.data.table(covPed())

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive(covGV()),
      pedigree = shiny::reactive(dtped),
      kinshipMatrix = NULL
    ),
    {
      km <- getKinshipMatrix()
      expect_true(is.matrix(km))
      expect_equal(dim(km), c(6L, 6L))
      expect_setequal(rownames(km), covPed()$id)
    }
  )
})

# ---- boxplot NULL guards (modSummaryStats.R L510 and L570) -----------------

test_that("meanKinshipBoxPlot is NULL when the meanKinship column is absent", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  gv <- data.frame(id = c("A", "B", "C"),
                   genomeUniqueness = c(0.9, 0.8, 0.7),
                   stringsAsFactors = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive(gv),
      pedigree = shiny::reactive(covPed()),
      kinshipMatrix = NULL
    ),
    {
      expect_null(session$getReturned()$meanKinshipBoxPlot())
    }
  )
})

test_that("guBoxPlot is NULL when the genomeUniqueness column is absent", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  gv <- data.frame(id = c("A", "B", "C"),
                   meanKinship = c(0.1, 0.2, 0.3),
                   stringsAsFactors = FALSE)

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive(gv),
      pedigree = shiny::reactive(covPed()),
      kinshipMatrix = NULL
    ),
    {
      expect_null(session$getReturned()$guBoxPlot())
    }
  )
})

# ---- founder CSV download handlers (L747-765) ------------------------------

test_that("male/female founder download handlers export founder-only CSVs", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive(covGV()),
      pedigree = shiny::reactive(covPed()),
      kinshipMatrix = NULL
    ),
    {
      # colClasses = "character" stops read.csv's type.convert() from
      # coercing the single-letter sex values ("F" -> logical FALSE).
      males <- read.csv(output$downloadMaleFounders,
                        colClasses = "character")
      # F1 is the only male whose sire and dam are both unknown.
      expect_equal(males$id, "F1")
      expect_true(all(males$sex == "M"))

      females <- read.csv(output$downloadFemaleFounders,
                          colClasses = "character")
      expect_setequal(females$id, c("F2", "F3"))
      expect_true(all(females$sex == "F"))
    }
  )
})

# ---- first-order download handler (L767-776, incl. filename L769) ----------

test_that("first-order download handler exports the per-animal count table", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive(covGV()),
      pedigree = shiny::reactive(covPed()),
      kinshipMatrix = NULL
    ),
    {
      counts <- read.csv(output$downloadFirstOrder,
                         stringsAsFactors = FALSE)
      expect_equal(nrow(counts), 6L)
      expect_true(all(c("id", "parents", "offspring", "siblings", "total")
                      %in% names(counts)))
      expect_equal(counts$total,
                   counts$parents + counts$offspring + counts$siblings)
    }
  )
})

# ---- relationship CSV download handlers (L778-794, incl. filename L788) -----

test_that("relationship download handlers export non-empty CSVs", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive(covGV()),
      pedigree = shiny::reactive(covPed()),
      kinshipMatrix = NULL
    ),
    {
      rels <- read.csv(output$downloadRelationships,
                       stringsAsFactors = FALSE)
      expect_gt(nrow(rels), 0L)
      expect_true(all(c("id1", "id2", "kinship", "relation") %in%
                        names(rels)))

      classes <- read.csv(output$downloadRelationClasses,
                          stringsAsFactors = FALSE)
      expect_gt(nrow(classes), 0L)
      expect_equal(ncol(classes), 2L)
    }
  )
})

# ---- histogram PNG download handlers (L797-822) ----------------------------

test_that("histogram download handlers write valid PNG files", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive(covGV()),
      pedigree = shiny::reactive(covPed()),
      kinshipMatrix = NULL
    ),
    {
      for (out in c(output$downloadMkHist,
                    output$downloadZscoreHist,
                    output$downloadGuHist)) {
        expect_true(file.exists(out))
        expect_gt(file.size(out), 0L)
        expect_true(isPngFile(out))
      }
    }
  )
})

# ---- box plot PNG download handlers (L824-848) -----------------------------

test_that("box plot download handlers write valid PNG files", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive(covGV()),
      pedigree = shiny::reactive(covPed()),
      kinshipMatrix = NULL
    ),
    {
      for (out in c(output$downloadMkBox,
                    output$downloadZscoreBox,
                    output$downloadGuBox)) {
        expect_true(file.exists(out))
        expect_gt(file.size(out), 0L)
        expect_true(isPngFile(out))
      }
    }
  )
})
