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

## ---------------------------------------------------------------------------
## Rebuilt series (S1039; issue #170, Slice 3, design B3)
## ---------------------------------------------------------------------------
##
## Snapshots that backfillColonySnapshots() rebuilds from studbook dates are
## filed under their own rule, "reconstructedLiving", and must not be mistaken
## for ones recorded at the time. The chart draws that rule's line dashed (the
## recorded rules stay solid) and the plot carries a one-line caption saying
## so. The caption's wording is the owner's; these tests pin its key words.

## The x positions (days since 1970-01-01) and line types of every line the
## plot draws for one metric, however many layers draw them.
drawnLines <- function(p) {
  lineLayers <- layersWithGeom(p, "GeomLine")
  do.call(rbind, lapply(lineLayers, function(i) {
    layerData <- ggplot2::layer_data(p, i)
    data.frame(
      x = as.numeric(layerData$x),
      linetype = as.character(layerData$linetype),
      stringsAsFactors = FALSE
    )
  }))
}
isDashed <- function(linetype) linetype %in% c("dashed", "2")
isSolid <- function(linetype) linetype %in% c("solid", "1")

mixedRulesHistory <- function() {
  checkSnapshotHistory(rbind(
    makeSnapshotRow("2024-01-01", "wholePedigree"),
    makeSnapshotRow("2025-01-01", "wholePedigree"),
    makeSnapshotRow("2020-01-01", "reconstructedLiving"),
    makeSnapshotRow("2021-01-01", "reconstructedLiving"),
    makeSnapshotRow("2022-01-01", "reconstructedLiving"),
    makeSnapshotRow("2024-01-01", "focalPopulation"),
    makeSnapshotRow("2025-01-01", "focalPopulation")
  ))
}

test_that("the reconstructedLiving line is dashed and recorded lines stay solid", {
  p <- plotSnapshotTrends(mixedRulesHistory(), metrics = "fe")
  lines <- drawnLines(p)
  rebuilt <- as.numeric(as.Date(c("2020-01-01", "2021-01-01", "2022-01-01")))
  expect_identical(nrow(lines), 7L)
  expect_identical(sort(lines$x[isDashed(lines$linetype)]), rebuilt)
  recorded <- as.numeric(as.Date(c("2024-01-01", "2025-01-01")))
  expect_identical(sort(lines$x[isSolid(lines$linetype)]), sort(c(recorded, recorded)))
})

test_that("a history with no reconstructed rows draws every line solid", {
  p <- plotSnapshotTrends(validatedSnapshotHistory(), metrics = "fe")
  lines <- drawnLines(p)
  expect_gt(nrow(lines), 0L)
  expect_true(all(isSolid(lines$linetype)))
})

test_that("the caption says the dashed lines are rebuilt, not recorded at the time", {
  p <- plotSnapshotTrends(mixedRulesHistory(), metrics = "fe")
  expect_false(is.null(p$labels$caption))
  expect_match(p$labels$caption, "Dashed", fixed = TRUE)
  expect_match(p$labels$caption, "rebuilt", fixed = TRUE)
  expect_match(p$labels$caption, "not recorded", fixed = TRUE)
  expect_match(p$labels$caption, "birth and exit dates", fixed = TRUE)
})

test_that("a history with no reconstructed rows has no rebuilt caption", {
  clean <- checkSnapshotHistory(rbind(
    makeSnapshotRow("2026-01-15"),
    makeSnapshotRow("2026-07-15")
  ))
  expect_null(plotSnapshotTrends(clean, metrics = "fe")$labels$caption)
  p <- plotSnapshotTrends(validatedSnapshotHistory(), metrics = "fe")
  expect_false(grepl("rebuilt", p$labels$caption, fixed = TRUE))
})

test_that("the rebuilt note and the provenance note share one caption", {
  history <- checkSnapshotHistory(rbind(
    makeSnapshotRow("2020-01-01", "reconstructedLiving", guIter = 1000L),
    makeSnapshotRow("2021-01-01", "reconstructedLiving", guIter = 1000L),
    makeSnapshotRow("2022-01-01", "reconstructedLiving", guIter = 2000L)
  ))
  caption <- plotSnapshotTrends(history, metrics = "fe")$labels$caption
  expect_match(caption, "guIter", fixed = TRUE)
  expect_match(caption, "Dashed", fixed = TRUE)
  expect_match(caption, "rebuilt", fixed = TRUE)
})

test_that("a rebuilt series of one point and a recorded series still plot", {
  history <- checkSnapshotHistory(rbind(
    makeSnapshotRow("2020-01-01", "reconstructedLiving"),
    makeSnapshotRow("2024-01-01", "wholePedigree"),
    makeSnapshotRow("2025-01-01", "wholePedigree")
  ))
  p <- plotSnapshotTrends(history, metrics = "fe")
  expect_s3_class(p, "ggplot")
  expect_error(ggplot2::ggplot_build(p), NA)
  pointLayers <- layersWithGeom(p, "GeomPoint")
  expect_identical(nrow(ggplot2::layer_data(p, pointLayers[1L])), 3L)
  ## one point has no line to dash; the two recorded points keep their solid one
  lines <- drawnLines(p)
  expect_identical(nrow(lines), 2L)
  expect_true(all(isSolid(lines$linetype)))
})

test_that("the rebuilt note and the provenance note sit on separate lines", {
  ## Seen S1039 in the real app (browser picture of the finished panel): with
  ## both notes on one line the caption was longer than the plot and its start
  ## ran off the left edge, so each note gets a line of its own.
  history <- checkSnapshotHistory(rbind(
    makeSnapshotRow("2020-01-01", "reconstructedLiving", guIter = 1000L),
    makeSnapshotRow("2021-01-01", "reconstructedLiving", guIter = 1000L),
    makeSnapshotRow("2022-01-01", "reconstructedLiving", guIter = 2000L)
  ))
  caption <- plotSnapshotTrends(history, metrics = "fe")$labels$caption
  noteLines <- strsplit(caption, "\n", fixed = TRUE)[[1L]]
  expect_length(noteLines, 2L)
  expect_match(noteLines[[1L]], "Triangle points", fixed = TRUE)
  expect_match(noteLines[[2L]], "Dashed", fixed = TRUE)
  expect_lte(max(nchar(noteLines)), 120L)
})
