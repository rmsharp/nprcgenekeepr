## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Lay the trend chart out for the width of its plot box
#'
#' Internal rule of the Genetic-Health Trends tab: how many panel columns
#' \code{\link{plotSnapshotTrends}} draws and how tall the picture is, for the
#' width of the box that shows it. Measured in S1045 on the app's own history
#' (18 panels): the box is 437, 570, 770 and 903 pixels wide in windows 700,
#' 900, 1200 and 1400 pixels wide, the legend takes 115 pixels, the longest
#' panel title is 94 pixels, and a column needs about 150 pixels (the title,
#' the y-axis labels and the gap). So the columns are
#' \code{floor((width - 115) / 150)}, kept between 2 and 5, and each row of
#' panels is 130 pixels high with 80 pixels for the x-axis title and the
#' caption. Five columns and four rows come to the 600 pixels the box has
#' always had, so a wide window looks as it did.
#'
#' @param width The width of the plot box in pixels. A single positive finite
#' number; anything else (no width before the first draw, 0 for a hidden box)
#' keeps the layout \pkg{ggplot2} chooses, in 600 pixels.
#' @param nPanels The number of panels the chart draws; the default is the
#' number it draws for its default metrics.
#' @return A list of \code{ncol} (a whole number, or \code{NULL} for
#' \pkg{ggplot2}'s own grid) and \code{height} (a whole number of pixels).
#' @noRd
trendPlotLayout <- function(width, nPanels = 18L) {
  if (!is.numeric(width) || length(width) != 1L || !is.finite(width) ||
        width <= 0L) {
    return(list(ncol = NULL, height = 600L))
  }
  ncol <- as.integer(min(5L, max(2L, floor((width - 115L) / 150L))))
  list(
    ncol = ncol,
    height = as.integer(130L * ceiling(nPanels / ncol) + 80L)
  )
}
