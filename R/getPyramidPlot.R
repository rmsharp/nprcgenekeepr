## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Create an age-sex pyramid plot of a pedigree
#'
#' The pedigree provided must have the following columns: \code{sex} and
#' \code{age}. This needs to be augmented to allow pedigrees structures that
#' are provided by the nprcgenekeepr package.
#'
#' @inheritParams reportGV
#' @param binWidth numeric bin width for age groups (default 2).
#' @param ageUnit character either "years" (default) or "months".
#' @param colorScheme character color scheme: "default" (blue/pink) or
#'   "viridis" (colorblind-friendly).
#' @param showCounts logical whether to show count values on bars
#'   (default TRUE).
#' @param ageLabelCex numeric expansion factor for age labels (default 1.0).
#' @return The return value of par("mar") when the function was called.
#'
#' @importFrom lubridate now
#' @importFrom plotrix color.gradient pyramid.plot
#' @importFrom stringi stri_c
#' @importFrom graphics par
#' @export
#' @examples
#' library(nprcgenekeepr)
#' data(qcPed)
#' getPyramidPlot(qcPed)
#' getPyramidPlot(qcPed, binWidth = 5, colorScheme = "viridis")
getPyramidPlot <- function(ped = NULL, binWidth = 2L, ageUnit = "years",
                           colorScheme = "default", showCounts = TRUE,
                           ageLabelCex = 1.0) {
  if (is.null(ped)) {
    ped <- getPyramidAgeDist()
  }


  # Convert age to months if requested
  if (ageUnit == "months" && "age" %in% names(ped)) {
    ped$age <- ped$age * 12.0
  }

  opar <- par(no.readonly = TRUE) # nolint: undesirable_function_linter
  on.exit(par(opar)) # nolint: undesirable_function_linter
  par(bg = "#FFF8DC") # nolint: undesirable_function_linter

  # Ensure binWidth is at least 1

binWidth <- max(1L, as.integer(binWidth))

  axModulas <- 5L
  maxAge <- getPedMaxAge(ped)

  # Handle case where maxAge might be very small or zero
  if (is.na(maxAge) || maxAge < binWidth) {
    maxAge <- binWidth
  }

  upperAges <- seq(
    binWidth,
    makeRoundUp(maxAge, binWidth), binWidth
  )
  lowerAges <- upperAges - binWidth

  bins <- fillBins(ped, lowerAges, upperAges)
  maxAx <- max(getMaxAx(bins, axModulas))

  # Create age labels with appropriate unit
  ageUnitLabel <- if (ageUnit == "months") "mo" else "yr"
  ageLabels <- stri_c(lowerAges, "-", upperAges - 1L)

  # Set colors based on color scheme
  if (colorScheme == "viridis") {
    # Colorblind-friendly colors
    mcol <- color.gradient(0.267, 0.329, 0.416)  # viridis blue-ish
    fcol <- color.gradient(0.741, 0.639, 0.173)  # viridis yellow-ish
  } else {
    # Default blue/pink
    mcol <- color.gradient(0L, 0L, 0.5)
    fcol <- color.gradient(1L, 0.5, 0.5)
  }

  currentDate <- now()
  axBy <- maxAx / axModulas
  axGap <- axBy * 0.6
  gap <- axGap
  laxlab <- seq(0L, maxAx, by = axBy)
  raxlab <- seq(0L, maxAx, by = axBy)

  # Call pyramid.plot directly with additional parameters
  pyramid.plot(
    lx = bins$males,
    rx = bins$females,
    labels = ageLabels,
    main = stri_c(
      "Total on ",
      lubridate::year(currentDate),
      "-",
      lubridate::month(currentDate, label = TRUE),
      "-",
      lubridate::day(currentDate),
      ": ",
      sum(c(bins$males, bins$females))
    ),
    top.labels = c(
      stri_c("Male = ", sum(bins$males)),
      paste0("Age (", ageUnitLabel, ")"),
      stri_c("Female = ", sum(bins$females))
    ),
    lxcol = mcol,
    rxcol = fcol,
    laxlab = laxlab,
    raxlab = raxlab,
    gap = gap,
    unit = "Number of Animals",
    show.values = showCounts,
    ndig = 0L,
    labelcex = ageLabelCex
  )
}
