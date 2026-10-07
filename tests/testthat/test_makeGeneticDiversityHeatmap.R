## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Tests for makeGeneticDiversityHeatmap() -- issue #112 Slice S1.
## Input contract: a data frame whose first column is the breeding-group
## label and whose remaining columns are per-metric colour indices in
## {1, 2, 3} (1 = red/problem, 2 = yellow/watch, 3 = green/healthy).

## A 3-group x 4-metric fixture with a known mix of colour indices.
## Flattened column-major, the counts are 1 -> 3, 2 -> 5, 3 -> 4.
statsFixture <- data.frame(
  group = c("Group_1", "Group_2", "Group_3"),
  Value = c(1, 2, 3),
  Origin = c(3, 3, 1),
  Production = c(2, 2, 2),
  Inbreeding = c(3, 1, 2),
  stringsAsFactors = FALSE
)

test_that("makeGeneticDiversityHeatmap returns a ggplot object", {
  p <- makeGeneticDiversityHeatmap(statsFixture)
  expect_s3_class(p, "ggplot")
})

test_that("makeGeneticDiversityHeatmap draws a geom_tile layer", {
  p <- makeGeneticDiversityHeatmap(statsFixture)
  expect_s3_class(p$layers[[1]]$geom, "GeomTile")
})

test_that("makeGeneticDiversityHeatmap renders one tile per cell", {
  p <- makeGeneticDiversityHeatmap(statsFixture)
  ## 3 groups x 4 metric columns = 12 tiles.
  expect_equal(nrow(ggplot2::layer_data(p, 1L)), 12L)
})

test_that("makeGeneticDiversityHeatmap is agnostic to metric count", {
  ## A 2-group x 5-metric matrix (e.g. once a Flags column is added) must
  ## render 10 tiles -- the renderer is not hard-coded to a column count.
  stats5 <- data.frame(
    group = c("Corral_1", "Corral_2"),
    Value = c(1, 3),
    Origin = c(2, 2),
    Production = c(3, 1),
    Inbreeding = c(1, 2),
    Flags = c(3, 3),
    stringsAsFactors = FALSE
  )
  p <- makeGeneticDiversityHeatmap(stats5)
  expect_equal(nrow(ggplot2::layer_data(p, 1L)), 10L)
})

test_that("makeGeneticDiversityHeatmap maps colorIndex to red/yellow/green", {
  p <- makeGeneticDiversityHeatmap(statsFixture)
  fills <- ggplot2::layer_data(p, 1L)$fill
  ## Exactly the three stoplight colours appear (discrete, not a gradient).
  expect_setequal(unique(fills), c("red", "yellow", "green"))
  ## Per-colour tile counts match the colour-index counts in the fixture.
  fillCounts <- table(fills)
  expect_equal(as.integer(fillCounts[["red"]]), 3L)
  expect_equal(as.integer(fillCounts[["yellow"]]), 5L)
  expect_equal(as.integer(fillCounts[["green"]]), 4L)
})

test_that("makeGeneticDiversityHeatmap maps each index to its own colour", {
  ## Single-value inputs prove the mapping directly, without position math.
  redOnly <- data.frame(group = "G", a = 1, b = 1, stringsAsFactors = FALSE)
  yellowOnly <- data.frame(group = "G", a = 2, b = 2, stringsAsFactors = FALSE)
  greenOnly <- data.frame(group = "G", a = 3, b = 3, stringsAsFactors = FALSE)
  redFill <- ggplot2::layer_data(makeGeneticDiversityHeatmap(redOnly), 1L)$fill
  yelFill <-
    ggplot2::layer_data(makeGeneticDiversityHeatmap(yellowOnly), 1L)$fill
  grnFill <- ggplot2::layer_data(makeGeneticDiversityHeatmap(greenOnly), 1L)$fill
  expect_true(all(redFill == "red"))
  expect_true(all(yelFill == "yellow"))
  expect_true(all(grnFill == "green"))
})

test_that("makeGeneticDiversityHeatmap uses a discrete fill scale", {
  p <- makeGeneticDiversityHeatmap(statsFixture)
  ## A discrete (manual) scale -- not a continuous gradient that would ramp
  ## 1/2/3 through interpolated colours.
  expect_s3_class(p$scales$get_scales("fill"), "ScaleDiscrete")
})

test_that("makeGeneticDiversityHeatmap preserves metric and group order", {
  p <- makeGeneticDiversityHeatmap(statsFixture)
  ## Metric columns keep their input order along the x axis.
  expect_identical(
    levels(p$data$metric),
    c("Value", "Origin", "Production", "Inbreeding")
  )
  ## All groups are represented on the y axis.
  expect_setequal(
    as.character(unique(p$data$group)),
    c("Group_1", "Group_2", "Group_3")
  )
})

test_that("makeGeneticDiversityHeatmap handles a single 1x1 cell", {
  one <- data.frame(group = "Group_1", Value = 2, stringsAsFactors = FALSE)
  p <- makeGeneticDiversityHeatmap(one)
  ld <- ggplot2::layer_data(p, 1L)
  expect_equal(nrow(ld), 1L)
  expect_identical(ld$fill, "yellow")
})

test_that("makeGeneticDiversityHeatmap rejects a no-metric data frame", {
  labelOnly <- data.frame(group = c("Group_1", "Group_2"),
                          stringsAsFactors = FALSE)
  expect_error(makeGeneticDiversityHeatmap(labelOnly), "metric column")
})

test_that("makeGeneticDiversityHeatmap rejects indices outside 1:3", {
  bad <- data.frame(group = c("Group_1", "Group_2"),
                    Value = c(1, 4), stringsAsFactors = FALSE)
  expect_error(makeGeneticDiversityHeatmap(bad), "colorIndex")
  zero <- data.frame(group = c("Group_1", "Group_2"),
                     Value = c(1, 0), stringsAsFactors = FALSE)
  expect_error(makeGeneticDiversityHeatmap(zero), "colorIndex")
})

test_that("makeGeneticDiversityHeatmap draws an NA index grey, not an error", {
  ## An undefined metric (e.g. Production with no dams) is NA, not a verdict.
  withNA <- data.frame(group = c("Group_1", "Group_2"),
                       Value = c(1, NA), Production = c(NA, 3),
                       stringsAsFactors = FALSE)
  p <- expect_no_error(makeGeneticDiversityHeatmap(withNA))
  tiles <- ggplot2::layer_data(p, 1L)
  expect_equal(nrow(tiles), 4L)
  expect_equal(sum(tiles$fill == "grey"), 2L)
  expect_setequal(unique(tiles$fill), c("red", "green", "grey"))
})

test_that("makeGeneticDiversityHeatmap accepts an all-NA metric column", {
  allNA <- data.frame(group = c("G1", "G2"), Production = c(NA_integer_, NA),
                      stringsAsFactors = FALSE)
  p <- expect_no_error(makeGeneticDiversityHeatmap(allNA))
  expect_true(all(ggplot2::layer_data(p, 1L)$fill == "grey"))
})

test_that("makeGeneticDiversityHeatmap rejects non-data-frame input", {
  expect_error(makeGeneticDiversityHeatmap(list(a = 1)), "data frame")
  expect_error(makeGeneticDiversityHeatmap(matrix(1:4, nrow = 2)), "data frame")
})

## ---- Readable labels (S934) -------------------------------------------------
## The column names were slanted at 45 degrees, so the top edge of the drawing
## cut them off ("Va", "Or", "Pro", "Inb"), and both sets of names were drawn at
## 8.8 pt beside tiles hundreds of pixels wide. The names are written level,
## centred over their column, in bold, at a size that can be read: 22 pt, 2.5
## times the 8.8 pt default (the owner's estimate of what the labels need).
## These tests read the settings the plot ends up with once its theme is
## resolved.

labelSettings <- function(p, element) {
  ggplot2::calc_element(element, p$theme)
}

## Data frames of different shapes: the label settings must not depend on the
## data.
labelFixtures <- list(
  "four metrics" = statsFixture,
  "five metrics" = data.frame(
    group = c("Corral_1", "Corral_2"),
    Value = c(1, 3),
    Origin = c(2, 2),
    Production = c(3, 1),
    Inbreeding = c(1, 2),
    Flags = c(3, 3),
    stringsAsFactors = FALSE
  ),
  "one group and one metric" = data.frame(
    group = "Group_1", Value = 2, stringsAsFactors = FALSE
  ),
  "an undefined cell" = data.frame(
    group = c("Group_1", "Group_2"),
    Value = c(1, NA),
    Production = c(NA, 3),
    stringsAsFactors = FALSE
  )
)

test_that("makeGeneticDiversityHeatmap writes the column names level", {
  p <- makeGeneticDiversityHeatmap(statsFixture)
  expect_equal(labelSettings(p, "axis.text.x.top")$angle, 0)
})

test_that("makeGeneticDiversityHeatmap centres each column name over its column", {
  p <- makeGeneticDiversityHeatmap(statsFixture)
  expect_equal(labelSettings(p, "axis.text.x.top")$hjust, 0.5)
})

test_that("makeGeneticDiversityHeatmap writes the column names in bold", {
  p <- makeGeneticDiversityHeatmap(statsFixture)
  expect_identical(labelSettings(p, "axis.text.x.top")$face, "bold")
})

test_that("makeGeneticDiversityHeatmap draws the column names at least 22 pt", {
  p <- makeGeneticDiversityHeatmap(statsFixture)
  expect_gte(labelSettings(p, "axis.text.x.top")$size, 22)
})

test_that("makeGeneticDiversityHeatmap draws the group names at least 22 pt", {
  p <- makeGeneticDiversityHeatmap(statsFixture)
  expect_gte(labelSettings(p, "axis.text.y")$size, 22)
})

test_that("makeGeneticDiversityHeatmap keeps the column names above the grid", {
  p <- makeGeneticDiversityHeatmap(statsFixture)
  expect_identical(p$scales$get_scales("x")$position, "top")
})

test_that("makeGeneticDiversityHeatmap labels do not depend on the data shape", {
  for (shape in names(labelFixtures)) {
    p <- makeGeneticDiversityHeatmap(labelFixtures[[shape]])
    col <- labelSettings(p, "axis.text.x.top")
    row <- labelSettings(p, "axis.text.y")
    expect_equal(col$angle, 0, info = shape)
    expect_equal(col$hjust, 0.5, info = shape)
    expect_identical(col$face, "bold", info = shape)
    expect_gte(col$size, 22)
    expect_gte(row$size, 22)
  }
})
