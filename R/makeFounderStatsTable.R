#' Create Founder Statistics HTML Table
#'
#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
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
  total <- if (!is.null(founderStats$total)) founderStats$total else 0
  nMale <- if (!is.null(founderStats$nMaleFounders)) {
    founderStats$nMaleFounders
  } else {
    0
  }
  nFemale <- if (!is.null(founderStats$nFemaleFounders)) {
    founderStats$nFemaleFounders
  } else {
    0
  }
  fe <- if (!is.null(founderStats$fe)) {
    round(founderStats$fe, 2)
  } else {
    NA
  }
  fg <- if (!is.null(founderStats$fg)) {
    round(founderStats$fg, 2)
  } else {
    NA
  }

  # Build HTML table
  html <- paste0(
    '<table class="table table-condensed table-striped">',
    '<thead>',
    '<tr>',
    '<th>Known Founders</th>',
    '<th>Female Founders</th>',
    '<th>Male Founders</th>',
    '<th>Founder Equivalents (FE)</th>',
    '<th>Founder Genome Equivalents (FG)</th>',
    '</tr>',
    '</thead>',
    '<tbody>',
    '<tr>',
    '<td>', as.character(total), '</td>',
    '<td>', as.character(nFemale), '</td>',
    '<td>', as.character(nMale), '</td>',
    '<td>', ifelse(is.na(fe), "N/A", as.character(fe)), '</td>',
    '<td>', ifelse(is.na(fg), "N/A", as.character(fg)), '</td>',
    '</tr>',
    '</tbody>',
    '</table>'
  )

  html
}
