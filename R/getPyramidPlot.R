#' Creates a pyramid plot of the pedigree provided.
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of mprcgenekeepr
#' The pedigree provided must have columns: \code{sex} and either \code{age}
#' or \code{birth} (with optional \code{exit} or \code{exit_date}).
#' If \code{age} is not present, it will be calculated from \code{birth}.
#'
#' @return The return value of par("mar") when the function was called.
#'
#' @param ped dataframe with pedigree data.
#' @param binWidth integer width of age bins in years. Default is 2.
#' @param ageUnit character either "years" or "months" for age display.
#'   Default is "years".
#' @param colorScheme character color scheme for the plot. Either "default"
#'   (blue/red) or "viridis". Default is "default".
#' @param showCounts logical whether to show count values on bars.
#'   Default is TRUE.
#' @param ageLabelCex numeric character expansion factor for age labels.
#'   Default is 1.0.
#' @importFrom lubridate now interval duration
#' @importFrom plotrix color.gradient
#' @importFrom stringi stri_c
#' @importFrom graphics par
#' @export
#' @examples
#' library(mprcgenekeepr)
#' data(qcPed)
#' getPyramidPlot(qcPed)
#' getPyramidPlot(qcPed, binWidth = 5, colorScheme = "viridis")
getPyramidPlot <- function(ped = NULL, binWidth = 2L, ageUnit = "years",
                           colorScheme = "default", showCounts = TRUE,
                           ageLabelCex = 1.0) {
  if (is.null(ped)) {
    ped <- getPyramidAgeDist()
  }
  opar <- par(no.readonly = TRUE)
  on.exit(par(opar))
  par(bg = "#FFF8DC")

  # Convert binWidth to integer
  binWidth <- as.integer(binWidth)
  if (binWidth < 1L) binWidth <- 1L

  # Make a copy of ped to avoid modifying the original
  pedWork <- ped

  # Calculate ages if not present in data
  if (!"age" %in% names(pedWork)) {
    # Need birth column to calculate ages
    if ("birth" %in% names(pedWork)) {
      currentTime <- now()
      # Determine which column indicates animal is deceased
      exitCol <- if ("exit" %in% names(pedWork)) "exit" else
        if ("exit_date" %in% names(pedWork)) "exit_date" else NULL

      # Calculate age for living animals (no exit date)
      if (!is.null(exitCol)) {
        livingMask <- is.na(pedWork[[exitCol]]) & !is.na(pedWork$birth)
        deceasedMask <- !is.na(pedWork[[exitCol]]) & !is.na(pedWork$birth)

        pedWork$age <- NA_real_

        if (any(livingMask)) {
          pedWork$age[livingMask] <- interval(
            start = pedWork$birth[livingMask],
            end = currentTime
          ) / duration(num = 1L, units = "years")
        }

        if (any(deceasedMask)) {
          pedWork$age[deceasedMask] <- interval(
            start = pedWork$birth[deceasedMask],
            end = pedWork[[exitCol]][deceasedMask]
          ) / duration(num = 1L, units = "years")
        }
      } else {
        # No exit column, assume all are living
        pedWork$age <- interval(
          start = pedWork$birth,
          end = currentTime
        ) / duration(num = 1L, units = "years")
      }
    }
  }

  # Filter to living animals only (those without exit date)
  if ("exit" %in% names(pedWork)) {
    pedWork <- pedWork[is.na(pedWork$exit), ]
  } else if ("exit_date" %in% names(pedWork)) {
    pedWork <- pedWork[is.na(pedWork$exit_date), ]
  }

  # Convert ages to months if requested
  if (ageUnit == "months" && "age" %in% names(pedWork)) {
    pedWork$age <- pedWork$age * 12
  }

  maxAge <- getPedMaxAge(pedWork)

  axModulas <- 5L
  upperAges <- seq(
    binWidth,
    makeRoundUp(maxAge, binWidth), binWidth
  )
  lowerAges <- upperAges - binWidth

  bins <- fillBins(pedWork, lowerAges, upperAges)
  maxAx <- max(getMaxAx(bins, axModulas))

  # Create age labels with appropriate unit suffix
  if (ageUnit == "months") {
    ageLabels <- stri_c(lowerAges, " - ", upperAges - 1L, " mo")
  } else {
    ageLabels <- stri_c(lowerAges, " - ", upperAges - 1L, " yr")
  }

  # Set colors based on colorScheme
  if (colorScheme == "viridis") {
    mcol <- color.gradient(0.3, 0.5, 0.2)
    fcol <- color.gradient(0.5, 0.2, 0.6)
  } else {
    # default blue/red
    mcol <- color.gradient(0L, 0L, 0.5)
    fcol <- color.gradient(1L, 0.5, 0.5)
  }

  currentDate <- now()
  axBy <- maxAx / axModulas
  axGap <- axBy * 0.6
  ## The following values have worked well for chimpanzees:
  ## gap=40, laxlab = seq(0, 100, by = 10), and raxlab = seq(0, 100, by = 10)
  gap <- axGap
  laxlab <- seq(0L, maxAx, by = axBy)
  raxlab <- seq(0L, maxAx, by = axBy)
  agePyramidPlot(
    bins$males, bins$females, ageLabels, mcol, fcol,
    laxlab, raxlab, gap, currentDate, showCounts = showCounts,
    ageLabelCex = ageLabelCex
  )
}
