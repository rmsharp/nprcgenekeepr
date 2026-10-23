## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# S1045: trendPlotLayout(width, nPanels = 18L) is the rule the Genetic-Health
# Trends tab uses to lay out its chart for the width of the plot box: how many
# panel columns, and how tall the picture is. The owner chose "columns follow
# the window width" at the S1045 approach question (over always 3 columns and
# over thinning the labels only).
#
# Measured in S1045 on the app's own history (3 recorded and 4 rebuilt
# snapshots, 18 panels) with a red panel border read from the real app's
# picture: the plot box is 437, 570, 770 and 903 pixels wide in 700-, 900-,
# 1200- and 1400-pixel windows; the legend takes 115 pixels; the longest panel
# title is 94 pixels; a column needs about 150 pixels (the title, the y-axis
# labels and the gap). So the columns are floor((width - 115) / 150), kept
# between 2 and 5, and each row of panels is 130 pixels high with 80 pixels
# for the x-axis title and the caption. At five columns and four rows that is
# the 600 pixels the box has always had, so a wide window looks as before.

test_that("the rule gives the measured columns and heights for the app's plot widths", {
  cases <- data.frame(
    width = c(437, 570, 600, 770, 903),
    ncol = c(2L, 3L, 3L, 4L, 5L),
    height = c(1250L, 860L, 860L, 730L, 600L)
  )
  for (i in seq_len(nrow(cases))) {
    layout <- trendPlotLayout(cases$width[[i]])
    expect_identical(layout$ncol, cases$ncol[[i]], info = cases$width[[i]])
    expect_identical(layout$height, cases$height[[i]], info = cases$width[[i]])
  }
})

test_that("the columns change exactly at 115 + 150 * k pixels", {
  edges <- data.frame(
    width = c(414, 415, 564, 565, 714, 715, 864, 865),
    ncol = c(2L, 2L, 2L, 3L, 3L, 4L, 4L, 5L)
  )
  for (i in seq_len(nrow(edges))) {
    expect_identical(trendPlotLayout(edges$width[[i]])$ncol, edges$ncol[[i]],
                     info = edges$width[[i]])
  }
})

test_that("the rule never uses fewer than 2 or more than 5 columns", {
  expect_identical(trendPlotLayout(1)$ncol, 2L)
  expect_identical(trendPlotLayout(100)$ncol, 2L)
  expect_identical(trendPlotLayout(100)$height, 1250L)
  expect_identical(trendPlotLayout(2000)$ncol, 5L)
  expect_identical(trendPlotLayout(2000)$height, 600L)
})

test_that("an unknown or unusable width keeps today's layout", {
  ## clientData holds no width before the first draw and a hidden box can
  ## report 0; the chart is then the one ggplot2 lays out, in the 600 pixels
  ## the box has always had.
  for (bad in list(NULL, NA, NaN, Inf, 0, -5, "wide", c(500, 600), TRUE)) {
    layout <- trendPlotLayout(bad)
    expect_null(layout$ncol)
    expect_identical(layout$height, 600L)
  }
})

test_that("the height is 130 pixels a row plus 80 for the panel count it is given", {
  expect_identical(trendPlotLayout(437, nPanels = 3L)$height, 340L)
  expect_identical(trendPlotLayout(903, nPanels = 3L)$height, 210L)
  expect_identical(trendPlotLayout(903, nPanels = 6L)$height, 340L)
})

test_that("the default panel count is the number of panels the chart draws by default", {
  drawn <- nlevels(plotSnapshotTrends(checkSnapshotHistory(read.csv(
    system.file("extdata", "examples", "example_snapshot_history.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )))$data$metric)
  expect_identical(eval(formals(trendPlotLayout)$nPanels), drawn)
})
