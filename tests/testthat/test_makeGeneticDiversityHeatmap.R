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
  withNA <- data.frame(group = c("Group_1", "Group_2"),
                       Value = c(1, NA), stringsAsFactors = FALSE)
  expect_error(makeGeneticDiversityHeatmap(withNA), "colorIndex")
})

test_that("makeGeneticDiversityHeatmap rejects non-data-frame input", {
  expect_error(makeGeneticDiversityHeatmap(list(a = 1)), "data frame")
  expect_error(makeGeneticDiversityHeatmap(matrix(1:4, nrow = 2)), "data frame")
})
