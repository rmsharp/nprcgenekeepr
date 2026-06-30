## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Create Founder Statistics HTML Table
#'
#' Generates an HTML table displaying founder statistics including counts
#' of known founders, male founders, female founders, founder equivalents (FE),
#' and founder genome equivalents (FG).
#'
#' @return Character string containing HTML table markup.
#'
#' @param founderStats list containing founder statistics with elements:
#'   \itemize{
#'     \item \code{total} - Total number of known founders
#'     \item \code{nMaleFounders} - Number of male founders
#'     \item \code{nFemaleFounders} - Number of female founders
#'     \item \code{fe} - Founder equivalents
#'     \item \code{fg} - Founder genome equivalents
#'     \item \code{fgSE} - (optional) sampling standard error of \code{fg};
#'       when finite it is shown inline as \code{FG +/- SE}
#'   }
#'
#' @examples
#' \dontrun{
#' stats <- list(
#'   total = 50,
#'   nMaleFounders = 20,
#'   nFemaleFounders = 30,
#'   fe = 25.5,
#'   fg = 22.3
#' )
#' html <- makeFounderStatsTable(stats)
#' }
#'
#' @seealso \code{\link{makeGeneticSummaryTable}} for genetic value summary
#' @seealso \code{\link{calcFE}} for founder equivalents calculation
#' @seealso \code{\link{calcFG}} for founder genome equivalents
#' @export
makeFounderStatsTable <- function(founderStats) {
  # Handle NULL input
  if (is.null(founderStats)) {
    return("<p>No founder statistics available</p>")
  }

  # Extract values with defaults
  total <- if (!is.null(founderStats$total)) founderStats$total else 0L
  nMale <- if (!is.null(founderStats$nMaleFounders)) {
    founderStats$nMaleFounders
  } else {
    0L
  }
  nFemale <- if (!is.null(founderStats$nFemaleFounders)) {
    founderStats$nFemaleFounders
  } else {
    0L
  }
  fe <- if (!is.null(founderStats$fe)) {
    round(founderStats$fe, 2L)
  } else {
    NA
  }
  fg <- if (!is.null(founderStats$fg)) {
    round(founderStats$fg, 2L)
  } else {
    NA
  }
  # Issue #82 Slice 3: append the sampling SE inline after founder genome
  # equivalents when a finite value is supplied; otherwise the bare FG (or N/A).
  fgSE <- if (!is.null(founderStats$fgSE)) founderStats$fgSE else NA
  fgCell <- if (is.na(fg)) {
    "N/A"
  } else if (!is.na(fgSE) && is.finite(fgSE)) {
    sprintf("%.2f +/- %.2f", fg, fgSE) # nolint: nonportable_path_linter.
  } else {
    as.character(fg)
  }

  # Build HTML table
  html <- paste0(
    '<table class="table table-condensed table-striped">',
    "<thead>",
    "<tr>",
    "<th>Known Founders</th>",
    "<th>Female Founders</th>",
    "<th>Male Founders</th>",
    "<th>Founder Equivalents (FE)</th>",
    "<th>Founder Genome Equivalents (FG)</th>",
    "</tr>",
    "</thead>",
    "<tbody>",
    "<tr>",
    "<td>", as.character(total), "</td>",
    "<td>", as.character(nFemale), "</td>",
    "<td>", as.character(nMale), "</td>",
    "<td>", ifelse(is.na(fe), "N/A", as.character(fe)), "</td>",
    "<td>", fgCell, "</td>",
    "</tr>",
    "</tbody>",
    "</table>"
  )

  html
}
