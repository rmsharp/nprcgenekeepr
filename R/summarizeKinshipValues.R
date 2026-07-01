## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Summarize imputed kinship values
#'
#' Makes a data.frame object containing simulated kinship summary statistics
#' using the counts of kinship values list from \code{countKinshipValues}.
#'
#' @param countedKValues list object from countKinshipValues function that
#' containes the lists \code{kinshipIds}, \code{kinshipValues},
#' and \code{kinshipCounts}.
#' @return a data.frame with one row of summary statistics for each imputed
#' kinship value. The columns are as follows:
#'  \code{id_1},
#'  \code{id_2},
#'  \code{min},
#'  \code{secondQuartile},
#'  \code{mean},
#'  \code{median},
#'  \code{thirdQuartile},
#'  \code{max}, and
#'  \code{sd}.
#'
#'  The five-number-summary columns are taken from
#'  \code{\link[stats]{fivenum}}: \code{secondQuartile} is the lower hinge
#'  (\code{fivenum()[2]}, approximately the first quartile) and
#'  \code{thirdQuartile} is the upper hinge (\code{fivenum()[4]}, approximately
#'  the third quartile).
#'
#' @importFrom stats fivenum sd
#' @export
#' @examples
#' ped <- nprcgenekeepr::smallPed
#' simParent_1 <- list(
#'   id = "A",
#'   sires = c("s1_1", "s1_2", "s1_3"),
#'   dams = c("d1_1", "d1_2", "d1_3", "d1_4")
#' )
#' simParent_2 <- list(
#'   id = "B",
#'   sires = c("s1_1", "s1_2", "s1_3"),
#'   dams = c("d1_1", "d1_2", "d1_3", "d1_4")
#' )
#' simParent_3 <- list(
#'   id = "E",
#'   sires = c("A", "C", "s1_1"),
#'   dams = c("d3_1", "B")
#' )
#' simParent_4 <- list(
#'   id = "J",
#'   sires = c("A", "C", "s1_1"),
#'   dams = c("d3_1", "B")
#' )
#' simParent_5 <- list(
#'   id = "K",
#'   sires = c("A", "C", "s1_1"),
#'   dams = c("d3_1", "B")
#' )
#' simParent_6 <- list(
#'   id = "N",
#'   sires = c("A", "C", "s1_1"),
#'   dams = c("d3_1", "B")
#' )
#' allSimParents <- list(
#'   simParent_1, simParent_2, simParent_3,
#'   simParent_4, simParent_5, simParent_6
#' )
#'
#' extractKinship <- function(simKinships, id1, id2, simulation) {
#'   ids <- dimnames(simKinships[[simulation]])[[1]]
#'   simKinships[[simulation]][
#'     seq_along(ids)[ids == id1],
#'     seq_along(ids)[ids == id2]
#'   ]
#' }
#'
#' extractKValue <- function(kValue, id1, id2, simulation) {
#'   kValue[
#'     kValue$id_1 == id1 & kValue$id_2 == id2,
#'     paste0("sim_", simulation)
#'   ]
#' }
#'
#' n <- 10
#' simKinships <- createSimKinships(ped, allSimParents, pop = ped$id, n = n)
#' kValues <- kinshipMatricesToKValues(simKinships)
#' extractKValue(kValues, id1 = "A", id2 = "F", simulation = 1:n)
#' counts <- countKinshipValues(kValues)
#' stats <- summarizeKinshipValues(counts)
summarizeKinshipValues <- function(countedKValues) {
  if (!all(is.element(names(countedKValues), c(
    "kIds", "kValues",
    "kCounts"
  )))) {
    stop("summarizeKinshipValues received wrong object", call. = TRUE)
  }
  rows <- vector("list", length(countedKValues$kIds))

  for (i in seq_along(countedKValues$kIds)) {
    numbers <- rep(
      unlist(countedKValues$kValues[i]),
      unlist(countedKValues$kCounts[i])
    )
    # Skip entries with NA values
    if (any(is.na(numbers), is.na(mean(numbers)))) {
      next
    }
    tukeys <- fivenum(numbers)
    rows[[i]] <- data.frame(
      id_1 = countedKValues$kIds[[i]][1L],
      id_2 = countedKValues$kIds[[i]][2L],
      min = tukeys[1L],
      secondQuartile = tukeys[2L],
      mean = mean(numbers),
      median = tukeys[3L],
      thirdQuartile = tukeys[4L],
      max = tukeys[5L],
      sd = sd(numbers)
    )
  }
  # Bind once (O(n) instead of the previous O(n^2) rbind-in-loop). rbind()
  # drops the NULL entries left by skipped (NA) rows; an all-skipped input
  # yields NULL, which we restore to the empty-data.frame() contract.
  stats <- do.call(rbind, rows)
  if (is.null(stats)) {
    stats <- data.frame()
  }
  stats
}
