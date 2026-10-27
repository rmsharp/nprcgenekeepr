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

## The lines of a plot's caption (one element per drawn line).
captionLines <- function(p) {
  strsplit(p$labels$caption, "\n", fixed = TRUE)[[1L]]
}

## Each caption line's width in inches, measured with the pdf device's built-in
## Helvetica metrics, which give the same answer on every platform (a png
## device would use whatever font the machine has).
captionLineWidthsInches <- function(p) {
  element <- ggplot2::calc_element("plot.caption", p$theme)
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  vapply(captionLines(p), function(line) {
    grid::convertWidth(
      grid::grobWidth(grid::textGrob(
        line, gp = grid::gpar(fontsize = element$size,
                              fontfamily = element$family)
      )),
      "in", valueOnly = TRUE
    )
  }, numeric(1L), USE.NAMES = FALSE)
}

## The plot's gtable, built on a null device so that no Rplots.pdf is left in
## the test folder.
plotGrob <- function(p) {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  ggplot2::ggplotGrob(p)
}

## The grid ggplot2 lays the panels out in: the number of columns and rows.
panelGrid <- function(p) {
  layout <- ggplot2::ggplot_build(p)$layout$layout
  c(cols = max(layout$COL), rows = max(layout$ROW))
}

## Whether each text grob under the bottom axes asks the drawing device to
## drop labels that would overlap one another (one logical per text grob).
axisLabelOverlapFlags <- function(p) {
  gt <- plotGrob(p)
  flags <- logical(0L)
  collect <- function(x) {
    if (inherits(x, "text")) {
      flags <<- c(flags, isTRUE(x$check.overlap))
    }
    if (inherits(x, "gTree")) {
      lapply(x$children, collect)
    }
    if (inherits(x, "gtable")) {
      lapply(x$grobs, collect)
    }
    invisible(NULL)
  }
  lapply(gt$grobs[grepl("^axis-b", gt$layout$name)], collect)
  flags
}

## Three rebuilt snapshots made with one set of settings: the caption is the
## rebuilt note alone.
rebuiltOnlyHistory <- function() {
  checkSnapshotHistory(rbind(
    makeSnapshotRow("2020-01-01", "reconstructedLiving"),
    makeSnapshotRow("2021-01-01", "reconstructedLiving"),
    makeSnapshotRow("2022-01-01", "reconstructedLiving")
  ))
}

## Three rebuilt snapshots, the last made with a different guIter: the caption
## holds the provenance note and the rebuilt note.
rebuiltWithGuIterChangeHistory <- function() {
  checkSnapshotHistory(rbind(
    makeSnapshotRow("2020-01-01", "reconstructedLiving", guIter = 1000L),
    makeSnapshotRow("2021-01-01", "reconstructedLiving", guIter = 1000L),
    makeSnapshotRow("2022-01-01", "reconstructedLiving", guIter = 2000L)
  ))
}

## Two recorded snapshots that differ in all three provenance fields: the
## caption is the provenance note naming all three, its longest form.
allFieldsChangedHistory <- function() {
  checkSnapshotHistory(rbind(
    makeSnapshotRow("2020-01-01"),
    makeSnapshotRow("2021-01-01", packageVersion = "2.1.0", guIter = 2000L,
                    guThresh = 4L)
  ))
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
  ## genome uniqueness as a percentage, as corrected S1071 (see
  ## test_exampleSnapshotHistoryValues.R)
  expect_equal(
    ribbonData$ymin,
    c(21.3 - 0.41, 21.9 - 0.40, 22.4 - 0.28)
  )
  expect_equal(
    ribbonData$ymax,
    c(21.3 + 0.41, 21.9 + 0.40, 22.4 + 0.28)
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
  history <- rebuiltWithGuIterChangeHistory()
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

test_that("the provenance note and the rebuilt note each start a line of their own and are cut to short lines", {
  ## Seen S1039 in the real app (browser picture of the finished panel): with
  ## both notes on one line the caption was longer than the plot and its start
  ## ran off the left edge, so each note gets a line of its own. S1044: one
  ## line per note was still longer than a narrow plot (the app's plot is 437
  ## pixels wide in a 700-pixel window), so each note is also cut into two
  ## lines of at most 70 characters. The sentences are pinned as they stand,
  ## so a cut that drops or changes a word fails; an owner's wording change
  ## edits them here.
  history <- rebuiltWithGuIterChangeHistory()
  noteLines <- captionLines(plotSnapshotTrends(history, metrics = "fe"))
  expect_length(noteLines, 4L)
  if (length(noteLines) == 4L) {
    expect_match(noteLines[[1L]], "^Triangle points")
    expect_match(noteLines[[3L]], "^Dashed")
    expect_identical(
      paste(noteLines[1:2], collapse = " "),
      paste("Triangle points changed provenance (guIter) relative to the",
            "previous same-rule snapshot.")
    )
    expect_identical(
      paste(noteLines[3:4], collapse = " "),
      paste("Dashed lines are rebuilt from studbook birth and exit dates and",
            "today's parentage, not recorded at the time.")
    )
  }
  expect_lte(max(nchar(noteLines)), 70L)
})

test_that("a note on its own is cut into two lines of at most 70 characters", {
  ## The rebuilt note alone (108 characters) and the longest provenance note,
  ## the one naming all three settings (113 characters).
  for (history in list(rebuiltOnlyHistory(), allFieldsChangedHistory())) {
    noteLines <- captionLines(plotSnapshotTrends(history, metrics = "fe"))
    expect_length(noteLines, 2L)
    expect_lte(max(nchar(noteLines)), 70L)
  }
})

test_that("the caption is left-aligned to the whole picture, not right-aligned to the panel", {
  ## ggplot2 right-aligns a caption to the panel by default, so a caption
  ## longer than the panel and the legend leaves ran off the picture's left
  ## edge. Left-aligned to the plot, its start is always on the picture. The
  ## built table's outer margin and empty y-title columns lie outside the
  ## caption (S1044 first wrote "spans every column", which ggplot2 never
  ## builds), so the check is relative: the caption starts at or before the
  ## leftmost axis or panel column and ends at or after the legend's column.
  ## Measured on the old settings (position "panel", alignment 1): false for 1,
  ## 3 and 18 panels.
  for (metrics in list("fe", c("fe", "fg", "meanGu"))) {
    p <- plotSnapshotTrends(rebuiltOnlyHistory(), metrics = metrics)
    layout <- plotGrob(p)$layout
    cell <- layout[layout$name == "caption", ]
    expect_equal(nrow(cell), 1L)
    expect_lte(cell$l, min(layout$l[grepl("^(panel|axis-l)", layout$name)]))
    expect_gte(cell$r, layout$l[layout$name == "guide-box-right"])
    expect_equal(ggplot2::calc_element("plot.caption", p$theme)$hjust, 0)
  }
})

test_that("the widest caption line fits a figure five inches wide", {
  ## Five inches is 360 pixels at the app's 72 dpi, narrower than the plot in a
  ## 700-pixel window. Before S1044 the longest line was 6.47 inches wide.
  marginInches <- 2 * 5.5 / 72
  for (history in list(rebuiltOnlyHistory(), allFieldsChangedHistory())) {
    widths <- captionLineWidthsInches(
      plotSnapshotTrends(history, metrics = "fe")
    )
    expect_lte(max(widths) + marginInches, 5)
  }
})

## -- S1045: the number of panel columns and the year labels -----------------
## Seen in the real app (the BACKLOG item found in S1044's pictures): the plot is
## as wide as the browser gives it (437 pixels in a 700-pixel window), 18
## panels in 5 columns are then 22 pixels wide, the longest panel title is 94
## pixels, and 15 of the 18 titles lose letters (7 of 18 at 570 pixels). The
## cure is fewer columns when the plot is narrow, so the chart takes the
## number of columns as an argument, and the Genetic-Health Trends tab
## chooses it from its plot's width (test_trendPlotLayout.R). The year labels
## collide for a separate reason: a one-year history labels its x axis
## "Oct 2024", "Jan 2025" and so on (36 pixels each) and collided at every
## width measured, so the labels that would overlap are dropped everywhere.

test_that("ncol sets the number of panel columns", {
  history <- validatedSnapshotHistory()
  for (n in c(1L, 2, 3L, 5)) {
    grid <- panelGrid(plotSnapshotTrends(history, ncol = n))
    expect_equal(grid[["cols"]], n)
    expect_equal(grid[["rows"]], ceiling(18 / n))
  }
})

test_that("without ncol the grid is the one ggplot2 chooses: 5 columns for 18 panels, 3 for 3", {
  history <- validatedSnapshotHistory()
  expect_identical(panelGrid(plotSnapshotTrends(history))[["cols"]], 5L)
  expect_identical(
    panelGrid(plotSnapshotTrends(history, ncol = NULL))[["cols"]], 5L
  )
  expect_identical(
    panelGrid(plotSnapshotTrends(history, metrics = c("fe", "fg", "meanGu"),
                                 ncol = NULL))[["cols"]],
    3L
  )
})

test_that("an ncol above the number of panels draws one column for each panel", {
  grid <- panelGrid(plotSnapshotTrends(
    validatedSnapshotHistory(), metrics = c("fe", "fg", "meanGu"), ncol = 5L
  ))
  expect_identical(grid[["cols"]], 3L)
  expect_identical(grid[["rows"]], 1L)
})

test_that("ncol must be a single positive whole number", {
  history <- validatedSnapshotHistory()
  for (bad in list(0, -1, 2.5, NA, NA_integer_, "2", c(2L, 3L), TRUE)) {
    expect_error(
      plotSnapshotTrends(history, ncol = bad),
      "'ncol' must be a single positive whole number",
      fixed = TRUE
    )
  }
})

test_that("the year labels under the panels drop labels that would overlap", {
  ## Today none of the label text asks the device to drop a colliding label
  ## (0 of 5 for the 18-panel chart); with the setting every one does.
  history <- validatedSnapshotHistory()
  for (metrics in list(NULL, "fe", c("fe", "fg", "meanGu"))) {
    flags <- axisLabelOverlapFlags(plotSnapshotTrends(history,
                                                      metrics = metrics))
    expect_gt(length(flags), 0L)
    expect_true(all(flags))
  }
})

## -- S1049: a blank value is left out without a warning ---------------------
## Measured S1049 on the shipped Japanese macaque example (3 dates, 10 gene-drop
## iterations): the 2010 snapshot has fg, fgSE and neGD blank (founders kept in
## 0 of 10 iterations, which the build already says in a warning of its own).
## Drawing the chart then gave three console warnings, "Removed 1 row ..." from
## geom_ribbon and "Removed 3 rows ..." from geom_line and geom_point, for a
## picture that is the same with or without them (the saved PNG is
## byte-identical). The build, or the analysis that recorded the history, has
## already said the value is blank, so the chart leaves it out quietly.

## The warnings that drawing the chart for `history` raises. ggplot2 removes
## blank values when it draws, not when it builds, so the chart is drawn.
warningsOfDrawing <- function(history, metrics = NULL) {
  seen <- character(0L)
  withCallingHandlers(
    plotGrob(plotSnapshotTrends(history, metrics = metrics)),
    warning = function(w) {
      seen <<- c(seen, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  seen
}

## Three yearly snapshots of one rule, with the `blank` columns left blank in
## the snapshots numbered `rows`.
historyWithBlanks <- function(blank, rows) {
  snapshots <- rbind(
    makeSnapshotRow("2020-01-01"), makeSnapshotRow("2021-01-01"),
    makeSnapshotRow("2022-01-01")
  )
  snapshots[rows, blank] <- NA_real_
  checkSnapshotHistory(snapshots)
}

test_that("a history with no blank value draws with no warning", {
  ## the control for the test below: the harness itself raises nothing
  expect_identical(
    warningsOfDrawing(historyWithBlanks(character(0L), integer(0L))),
    character(0L)
  )
})

test_that("a blank value is left out of the drawing without a warning", {
  ## the last snapshot, the middle one (the line breaks there), the first, and
  ## the two metrics that carry a shaded band (fg with fgSE, meanGu with
  ## meanGuSE), also with only the band's width blank
  cases <- list(
    list(blank = c("fg", "fgSE", "neGD"), rows = 3L),
    list(blank = c("fg", "fgSE", "neGD"), rows = 2L),
    list(blank = "fe", rows = 1L),
    list(blank = c("meanGu", "meanGuSE"), rows = 3L),
    list(blank = "fgSE", rows = 3L)
  )
  for (case in cases) {
    expect_identical(
      warningsOfDrawing(historyWithBlanks(case$blank, case$rows),
                        metrics = c("fe", "fg", "neGD", "meanGu")),
      character(0L),
      info = paste(toString(case$blank), "blank in snapshot", case$rows)
    )
  }
})
