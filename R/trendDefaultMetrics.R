## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Metrics the trend chart draws by default
#'
#' Single source of truth for the metric columns
#' \code{\link{plotSnapshotTrends}} draws, one panel each, when no
#' \code{metrics} are named, and whose count \code{trendPlotLayout} reads to
#' size the chart. Internal helper constant -- the chart and the layout rule
#' both read it from here, so a metric added to the default set cannot leave
#' the layout counting the old number of panels.
#' @noRd
trendDefaultMetrics <- c(
  "fe", "fg", "fgSE", "neGD", "neSexRatio", "neVariance",
  "nMaleFounders", "nFemaleFounders", "nFounders",
  "meanIndivMeanKin", "medianIndivMeanKin", "skewnessIndivMeanKin",
  "kurtosisIndivMeanKin", "meanGu", "medianGu", "meanGuSE",
  "skewnessGu", "kurtosisGu"
)
