#' Create Genetic Summary Statistics HTML Table
#'
## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Generates an HTML table displaying summary statistics (Min, Q1, Mean,
#' Median, Q3, Max) for mean kinship and genome uniqueness values.
#'
#' @return Character string containing HTML table markup.
#'
#' @param geneticValues data.frame containing genetic value columns:
#'   \itemize{
#'     \item \code{meanKinship} - Mean kinship coefficients
#'     \item \code{genomeUniqueness} - Genome uniqueness values
#'   }
#'
#' @examples
#' \dontrun{
#' gv <- data.frame(
#'   meanKinship = c(0.1, 0.2, 0.3, 0.4, 0.5),
#'   genomeUniqueness = c(0.9, 0.8, 0.7, 0.6, 0.5)
#' )
#' html <- makeGeneticSummaryTable(gv)
#' }
#'
#' @seealso \code{\link{makeFounderStatsTable}} for founder statistics
#' @export
makeGeneticSummaryTable <- function(geneticValues) {
  # Handle NULL or empty input
  if (is.null(geneticValues) || nrow(geneticValues) == 0L) {
    return("<p>No genetic value data available</p>")
  }

  # Calculate summary statistics for mean kinship
  mk <- geneticValues$meanKinship
  mkSum <- if (!is.null(mk) && length(mk) > 0L) {
    summary(mk, na.rm = TRUE)
  } else {
    rep(NA, 6L)
  }

  # Calculate summary statistics for genome uniqueness
  gu <- geneticValues$genomeUniqueness
  guSum <- if (!is.null(gu) && length(gu) > 0L) {
    summary(gu, na.rm = TRUE)
  } else {
    rep(NA, 6L)
  }

  # Helper to format values
  fmt <- function(x, digits = 4L) {
    if (is.na(x)) return("N/A")
    sprintf(paste0("%.", digits, "f"), x)
  }

  # Build HTML table
  html <- paste0(
    '<table class="table table-condensed table-bordered">',
    "<thead>",
    "<tr>",
    "<th></th>",
    "<th>Min</th>",
    "<th>1st Quartile</th>",
    "<th>Mean</th>",
    "<th>Median</th>",
    "<th>3rd Quartile</th>",
    "<th>Max</th>",
    "</tr>",
    "</thead>",
    "<tbody>",
    "<tr>",
    "<td><strong>Mean Kinship</strong></td>",
    "<td>", fmt(mkSum["Min."]), "</td>",
    "<td>", fmt(mkSum["1st Qu."]), "</td>",
    "<td>", fmt(mkSum["Mean"]), "</td>",
    "<td>", fmt(mkSum["Median"]), "</td>",
    "<td>", fmt(mkSum["3rd Qu."]), "</td>",
    "<td>", fmt(mkSum["Max."]), "</td>",
    "</tr>",
    "<tr>",
    "<td><strong>Genome Uniqueness</strong></td>",
    "<td>", fmt(guSum["Min."]), "</td>",
    "<td>", fmt(guSum["1st Qu."]), "</td>",
    "<td>", fmt(guSum["Mean"]), "</td>",
    "<td>", fmt(guSum["Median"]), "</td>",
    "<td>", fmt(guSum["3rd Qu."]), "</td>",
    "<td>", fmt(guSum["Max."]), "</td>",
    "</tr>",
    "</tbody>",
    "</table>"
  )

  html
}
