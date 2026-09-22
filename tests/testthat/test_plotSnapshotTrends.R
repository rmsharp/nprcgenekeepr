## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #167 Slice 3: plotSnapshotTrends(history, metrics = NULL) draws the
# longitudinal trend view of a validated snapshot history (plan section 5
# Slice 3; D4/D6). Owner decisions (S759, pre-RED): it returns ONE ggplot
# object, faceted per metric (free y scales), x = snapshotDate, one colored
# series per membershipRule (D3 grouping); SE ribbons appear exactly on the
# two metrics whose sampling standard errors the schema carries (fg +/-
# fgSE, meanGu +/- meanGuSE); points whose provenance (guIter, guThresh,
# packageVersion) changed relative to the same rule's previous snapshot are
# drawn with a distinct shape and the plot carries a caption naming the
# changed fields (D4 flag-don't-refuse, made visible). metrics = NULL means
# the 18 metric columns (colony scalars + aggregates); the 3 composition
# counts are plottable on request (Dragon 3 churn visibility). Verification
# is structural ggplot inspection (house mold,
# test_makeGeneticDiversityHeatmap.R; vdiffr is not in Suggests) -- the
# recorded S759 choice; Slice 4's live render is the first human-eyes
# surface (plan section 5).

validatedSnapshotHistory <- function() {
  checkSnapshotHistory(read.csv(system.file(
    "extdata", "examples", "example_snapshot_history.csv",
    package = "nprcgenekeepr"
  ), stringsAsFactors = FALSE))
}

## The 18 metric columns (schema order): the 9 reportGV() colony scalars and
## the 9 Summary Statistics aggregates. Composition counts excluded here.
trendMetrics <- c(
  "fe", "fg", "fgSE", "neGD", "neSexRatio", "neVariance",
  "nMaleFounders", "nFemaleFounders", "nFounders",
  "meanIndivMeanKin", "medianIndivMeanKin", "skewnessIndivMeanKin",
  "kurtosisIndivMeanKin", "meanGu", "medianGu", "meanGuSE",
  "skewnessGu", "kurtosisGu"
)

## One plausible snapshot row with controllable provenance fields.
makeSnapshotRow <- function(snapshotDate,
                            membershipRule = "wholePedigree",
                            packageVersion = "2.0.0.9000",
                            guIter = 10000L,
                            guThresh = 3L) {
  data.frame(
    schemaVersion = 1L,
    snapshotDate = as.Date(snapshotDate),
    packageVersion = packageVersion,
    membershipRule = membershipRule,
    guIter = guIter,
    guThresh = guThresh,
    nAnimals = 390L,
    nMales = 130L,
    nFemales = 260L,
    fe = 14.9,
    fg = 9.1,
    fgSE = 0.13,
    neGD = 44.2,
    neSexRatio = 231.1,
    neVariance = 198.3,
    nMaleFounders = 12L,
    nFemaleFounders = 24L,
    nFounders = 36L,
    meanIndivMeanKin = 0.0798,
    medianIndivMeanKin = 0.0781,
    skewnessIndivMeanKin = 0.38,
    kurtosisIndivMeanKin = 2.8,
    meanGu = 0.229,
    medianGu = 0.221,
    meanGuSE = 0.0027,
    skewnessGu = 0.3,
    kurtosisGu = 3.0,
    stringsAsFactors = FALSE
  )
}

## Indices of the layers drawn with the given geom class.
layersWithGeom <- function(p, geomClass) {
  which(vapply(p$layers, function(layer) {
    inherits(layer$geom, geomClass)
  }, logical(1L)))
}

test_that("plotSnapshotTrends returns a ggplot object with line and point layers", {
  p <- plotSnapshotTrends(validatedSnapshotHistory())
  expect_s3_class(p, "ggplot")
  expect_true(length(layersWithGeom(p, "GeomLine")) >= 1L)
  expect_true(length(layersWithGeom(p, "GeomPoint")) >= 1L)
})

test_that("plotSnapshotTrends defaults to one facet per metric, schema order", {
  p <- plotSnapshotTrends(validatedSnapshotHistory())
  layout <- ggplot2::ggplot_build(p)$layout$layout
  expect_identical(length(unique(layout$PANEL)), 18L)
  expect_identical(as.character(layout$metric), trendMetrics)
})

test_that("plotSnapshotTrends facets only the requested metrics", {
  p <- plotSnapshotTrends(validatedSnapshotHistory(),
    metrics = c("fe", "meanGu")
  )
  layout <- ggplot2::ggplot_build(p)$layout$layout
  expect_identical(length(unique(layout$PANEL)), 2L)
  expect_setequal(as.character(layout$metric), c("fe", "meanGu"))
})

test_that("composition counts are plottable on request", {
  p <- plotSnapshotTrends(validatedSnapshotHistory(), metrics = "nAnimals")
  layout <- ggplot2::ggplot_build(p)$layout$layout
  expect_identical(length(unique(layout$PANEL)), 1L)
  expect_identical(as.character(layout$metric), "nAnimals")
})

test_that("plotSnapshotTrends stops on an unknown metric", {
  expect_error(
    plotSnapshotTrends(validatedSnapshotHistory(), metrics = "bogus"),
    "bogus"
  )
})

test_that("plotSnapshotTrends stops on an empty metric selection", {
  expect_error(
    plotSnapshotTrends(validatedSnapshotHistory(), metrics = character(0L)),
    "metric"
  )
})

test_that("plotSnapshotTrends stops when fewer than two snapshots exist", {
  ## A trend needs at least 2 points -- the message says so (plan catalog).
  history <- validatedSnapshotHistory()
  expect_error(plotSnapshotTrends(history[0L, ]), "2")
  expect_error(plotSnapshotTrends(history[1L, ]), "2")
})

test_that("SE ribbons appear exactly on fg and meanGu", {
  p <- plotSnapshotTrends(validatedSnapshotHistory())
  ribbonLayers <- layersWithGeom(p, "GeomRibbon")
  expect_true(length(ribbonLayers) >= 1L)
  ribbonMetrics <- unique(unlist(lapply(ribbonLayers, function(i) {
    as.character(p$layers[[i]]$data$metric)
  })))
  expect_setequal(ribbonMetrics, c("fg", "meanGu"))
})

test_that("no ribbon layer is drawn when no ribbon metric is requested", {
  p <- plotSnapshotTrends(validatedSnapshotHistory(), metrics = "fe")
  expect_identical(length(layersWithGeom(p, "GeomRibbon")), 0L)
})

test_that("the fg ribbon spans fg plus and minus fgSE", {
  ## Single-rule history so the ribbon rows are one ordered series; values
  ## hand-copied from the fixture's three wholePedigree rows.
  history <- validatedSnapshotHistory()
  history <- history[history$membershipRule == "wholePedigree", ]
  p <- plotSnapshotTrends(history, metrics = "fg")
  ribbonLayers <- layersWithGeom(p, "GeomRibbon")
  expect_identical(length(ribbonLayers), 1L)
  ribbonData <- ggplot2::layer_data(p, ribbonLayers[1L])
  ribbonData <- ribbonData[order(ribbonData$x), ]
  expect_equal(ribbonData$ymin, c(8.6 - 0.21, 8.8 - 0.2, 9.0 - 0.14))
  expect_equal(ribbonData$ymax, c(8.6 + 0.21, 8.8 + 0.2, 9.0 + 0.14))
})

test_that("the meanGu ribbon spans meanGu plus and minus meanGuSE", {
  history <- validatedSnapshotHistory()
  history <- history[history$membershipRule == "wholePedigree", ]
  p <- plotSnapshotTrends(history, metrics = "meanGu")
  ribbonLayers <- layersWithGeom(p, "GeomRibbon")
  expect_identical(length(ribbonLayers), 1L)
  ribbonData <- ggplot2::layer_data(p, ribbonLayers[1L])
  ribbonData <- ribbonData[order(ribbonData$x), ]
  expect_equal(
    ribbonData$ymin,
    c(0.213 - 0.0041, 0.219 - 0.004, 0.224 - 0.0028)
  )
  expect_equal(
    ribbonData$ymax,
    c(0.213 + 0.0041, 0.219 + 0.004, 0.224 + 0.0028)
  )
})

test_that("each membership rule draws its own colored series", {
  p <- plotSnapshotTrends(validatedSnapshotHistory(), metrics = "fe")
  pointLayers <- layersWithGeom(p, "GeomPoint")
  pointData <- ggplot2::layer_data(p, pointLayers[1L])
  ## 3 wholePedigree points + 1 focalPopulation point, two colors.
  expect_identical(nrow(pointData), 4L)
  expect_identical(length(unique(pointData$colour)), 2L)
})

test_that("provenance-change points are marked and captioned", {
  ## In the fixture's wholePedigree series, 2025-07-15 changed
  ## packageVersion and 2026-01-15 changed guIter and packageVersion,
  ## relative to each previous same-rule snapshot; the first snapshot of
  ## each rule has no previous to differ from. So 2 of the 4 points are
  ## provenance-change points, drawn with their own shape.
  p <- plotSnapshotTrends(validatedSnapshotHistory(), metrics = "fe")
  pointLayers <- layersWithGeom(p, "GeomPoint")
  pointData <- ggplot2::layer_data(p, pointLayers[1L])
  shapeCounts <- table(pointData$shape)
  expect_identical(length(shapeCounts), 2L)
  expect_setequal(as.integer(shapeCounts), c(2L, 2L))
  ## The caption names every changed provenance field (D4 visibility).
  expect_true(grepl("guIter", p$labels$caption))
  expect_true(grepl("packageVersion", p$labels$caption))
})

test_that("a clean history draws no provenance annotation", {
  history <- checkSnapshotHistory(rbind(
    makeSnapshotRow("2026-01-15"),
    makeSnapshotRow("2026-07-15")
  ))
  p <- plotSnapshotTrends(history, metrics = "fe")
  pointLayers <- layersWithGeom(p, "GeomPoint")
  pointData <- ggplot2::layer_data(p, pointLayers[1L])
  expect_identical(length(unique(pointData$shape)), 1L)
  expect_null(p$labels$caption)
})

test_that("plotSnapshotTrends stops on a malformed history", {
  expect_error(plotSnapshotTrends(data.frame(x = 1)), "must have columns")
})
