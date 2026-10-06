## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Rank animals by genetic value
#'
#' Part of Genetic Value Analysis
#'
#' Adds a \code{rank} column to each data.frame in \code{rpt}: integers from 1
#' to the total number of ranked animals, running on from one tier to the next
#' in the order of the list. Animals in the \code{noParentage} element get an
#' \code{NA} rank. Adds a \code{value} column designating each animal
#' \code{"High Value"}, \code{"Low Value"} (the \code{lowVal} element) or
#' \code{"Undetermined"} (the \code{noParentage} element).
#'
#' @param rpt a named list of data.frames containing genetic value data for the
#' population, as made by the report ordering step. The element names decide
#' the designation: \code{lowVal} and \code{noParentage} as described above,
#' and every other element (for example \code{imports}, \code{lowMk} and
#' \code{highGu}) is \dQuote{High Value}. The tiers separate out the animals
#' that are imports, those with low mean kinship (a mean-kinship z-score at or
#' below \code{zScoreCutoff}), those with high genome uniqueness (\code{gu}
#' above \code{guCutoff}), and the remainder; see \code{\link{reportGV}}.
#'
#' @return A list of dataframes with value and ranking information added.
#' Elements with no rows are returned unchanged.
#'
#' @references Vinson, A. and Raboin, M.J. (2015) "A Practical Approach for
#' Designing Breeding Groups to Maximize Genetic Diversity in a Large Colony
#' of Captive Rhesus Macaques (\emph{Macaca mulatta})" \emph{Journal of the
#' American Association for Laboratory Animal Science}, 2015 Nov, Vol.54(6),
#' pp.700-707.
#' @export
#' @examples
#' library(nprcgenekeepr)
#' finalRpt <- nprcgenekeepr::finalRpt
#' rpt <- rankSubjects(nprcgenekeepr::finalRpt)
#' rpt[["highGu"]][1, "value"]
#' rpt[["highGu"]][1, "rank"]
#' rpt[["lowMk"]][1, "value"]
#' rpt[["lowMk"]][1, "rank"]
#' rpt[["lowVal"]][1, "value"]
#' rpt[["lowVal"]][1, "rank"]
rankSubjects <- function(rpt) {
  rnk <- 1L

  for (i in seq_along(rpt)) {
    if (nrow(rpt[[i]]) == 0L) {
      next
    }

    if (names(rpt[i]) == "lowVal") {
      rpt[[i]][, "value"] <- valueLabels[["lowValue"]]
    } else if (names(rpt[i]) == "noParentage") {
      rpt[[i]][, "value"] <- valueLabels[["undetermined"]]
    } else { # everything else
      rpt[[i]][, "value"] <- valueLabels[["highValue"]]
    }

    if (names(rpt[i]) == "noParentage") {
      rpt[[i]][, "rank"] <- NA
    } else {
      rpt[[i]][, "rank"] <- rnk:(rnk + nrow(rpt[[i]]) - 1L)
      rnk <- rnk + nrow(rpt[[i]])
    }
  }
  rpt
}
