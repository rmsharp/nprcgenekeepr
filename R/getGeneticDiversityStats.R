## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Assemble breeding-group genetic diversity heat-map statistics
#'
#' @details For each breeding group this builds the heat-map color indices by
#' calling the per-group providers: Value from \code{getProportionLow}, Origin
#' from \code{getIndianOriginStatus}, Production from
#' \code{getProductionStatus}, and Inbreeding from
#' \code{getKinshipWithMaleStatus}. The result is the group-by-metric data
#' frame consumed by \code{\link{makeGeneticDiversityHeatmap}}: the first
#' column holds the group label and each remaining column holds a color index
#' (1 red, 2 yellow, 3 green).
#'
#' Age is derived from each member's birth date using \code{currentDate}
#' rather than read from a possibly-absent \code{age} column, so the age
#' filters and the production birth window share one reference date.
#' Genetic-value labels of \code{"Undetermined"} are dropped before the Value
#' proportion is taken. A group with no assessed value, and a group whose
#' Inbreeding metric is undefined (no breeding-age females), are both scored
#' red so that missing data is surfaced rather than shown as healthy green.
#' When the pedigree has no \code{ancestry} column the Origin metric cannot be
#' computed and its column is omitted.
#'
#' @param groups List of character vectors of animal IDs, one per breeding
#' group (for example the \code{groups} returned by
#' \code{modBreedingGroupsServer}). If the list is named, the names become the
#' group row labels; otherwise labels are \code{"Group 1"}, \code{"Group 2"},
#' and so on.
#' @param ped Dataframe that is the \code{Pedigree}. The \code{id}, \code{dam},
#' \code{sex}, \code{birth}, and \code{exit} columns are required; an optional
#' \code{ancestry} column enables the Origin metric.
#' @param geneticValues Dataframe of the genetic value report (for example
#' \code{reportGV(ped)$report}). The \code{id} and \code{value} columns are
#' required; \code{value} holds the labels produced by \code{rankSubjects}
#' (\code{"Low Value"}, \code{"High Value"}, \code{"Undetermined"}).
#' @param kmat Square kinship matrix whose row and column names are animal IDs
#' and that covers every member of every group (for example the matrix
#' returned by \code{\link{kinship}}).
#' @param housing Character housing type passed to \code{getProductionStatus},
#' either \code{"shelter_pens"} or \code{"corral"}. Length 1 (applied to every
#' group) or one value per group. Defaults to \code{"shelter_pens"}.
#' @param currentDate Date used to derive age and the production birth window.
#' Defaults to \code{Sys.Date()}.
#' @return A data frame with one row per group: the first column \code{group}
#' holds the group label and each remaining column (\code{Value},
#' \code{Origin} when available, \code{Production}, \code{Inbreeding}) holds an
#' integer color index in \code{c(1, 2, 3)}.
#'
#' @importFrom lubridate duration interval
#' @export
getGeneticDiversityStats <- function(groups, ped, geneticValues, kmat,
                                     housing = "shelter_pens",
                                     currentDate = Sys.Date()) {
  if (!is.list(groups) || length(groups) == 0L) {
    stop("getGeneticDiversityStats() requires at least one group.")
  }
  requiredPed <- c("id", "dam", "sex", "birth", "exit")
  if (!all(requiredPed %in% names(ped))) {
    missingCol <- requiredPed[!requiredPed %in% names(ped)]
    stop("ped is missing required column(s): ", toString(missingCol))
  }
  requiredGv <- c("id", "value")
  if (!all(requiredGv %in% names(geneticValues))) {
    missingCol <- requiredGv[!requiredGv %in% names(geneticValues)]
    stop("geneticValues is missing required column(s): ", toString(missingCol))
  }
  if (length(housing) != 1L && length(housing) != length(groups)) {
    stop("housing must have length 1 or length(groups).")
  }
  allMembers <- unlist(groups, use.names = FALSE)
  if (!all(allMembers %in% ped$id)) {
    missingId <- unique(allMembers[!allMembers %in% ped$id])
    stop("ped has no rows for group member(s): ", toString(missingId))
  }
  housing <- rep_len(housing, length(groups))
  labels <- names(groups)
  if (is.null(labels) || !all(nzchar(labels))) {
    labels <- paste("Group", seq_along(groups))
  }
  hasAncestry <- "ancestry" %in% names(ped)

  rows <- lapply(seq_along(groups), function(i) {
    members <- groups[[i]]
    subped <- ped[ped$id %in% members, ]
    subped$age <- as.numeric(
      interval(start = subped$birth, end = currentDate) /
        duration(num = 1L, units = "years")
    )
    vals <- geneticValues$value[geneticValues$id %in% members]
    vals <- vals[vals != "Undetermined"]
    valueIndex <- if (length(vals) == 0L) {
      1L
    } else {
      getProportionLow(vals)$colorIndex
    }
    productionIndex <- getProductionStatus(
      subped[, c("id", "dam", "sex", "age", "birth", "exit")],
      minDamAge = 3L, housing = housing[[i]], currentDate = currentDate
    )$colorIndex
    grp <- data.frame(id = subped$id, sex = subped$sex, age = subped$age,
                      stringsAsFactors = FALSE)
    inbreedingIndex <- getKinshipWithMaleStatus(grp, kmat)$colorIndex
    if (is.na(inbreedingIndex)) {
      inbreedingIndex <- 1L
    }
    row <- list(Value = valueIndex, Production = productionIndex,
                Inbreeding = inbreedingIndex)
    if (hasAncestry) {
      row$Origin <- getIndianOriginStatus(subped$ancestry)$colorIndex
    }
    row
  })

  stats <- data.frame(group = labels, stringsAsFactors = FALSE)
  stats$Value <- vapply(rows, function(r) r$Value, integer(1L))
  if (hasAncestry) {
    stats$Origin <- vapply(rows, function(r) r$Origin, integer(1L))
  }
  stats$Production <- vapply(rows, function(r) r$Production, integer(1L))
  stats$Inbreeding <- vapply(rows, function(r) r$Inbreeding, integer(1L))
  stats
}
