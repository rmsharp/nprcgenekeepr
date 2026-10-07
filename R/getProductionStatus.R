## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get production status of group
#'
#' @details Description of how Production and Production Status (color) is
#' calculated.
#' \enumerate{
#' \item  Births = count of all animals in the group born in the two calendar
#'        years ending the year before \code{currentDate} (January 1 of
#'        \code{currentYear - 2} through December 31 of
#'        \code{currentYear - 1}) that lived at least 30 days.
#' \item  Dams = count of all females in the group at least
#'        \code{minDamAge} years old (default 3), plus the females in the group
#'        with no birth date (so no age) that the pedigree lists as a dam,
#'        which is looked up in \code{damIds}. A female with no birth date and
#'        no offspring, a female whose known age is below \code{minDamAge}, and
#'        an animal with a blank sex are not counted.
#' \item  Production = Births / Dams
#' \item  Production Status (color)
#'     \enumerate{
#'     \item  Shelter and pens
#'         \enumerate{
#'         \item   Production < 0.6; Red
#'         \item   Production >= 0.6 and Production <= 0.63; Yellow
#'         \item   Production > 0.63; Green
#'     }
#'     \item  Corrals
#'         \enumerate{
#'         \item   Production < 0.5; Red
#'         \item   Production >= 0.5 and Production <= 0.53; Yellow
#'         \item   Production > 0.53; Green
#'         }
#'     }
#'  }
#'
#' This code may need to be modified to allow the user to supply a list
#' of IDs to include as group members. Currently each animal in the
#' provided pedigree (\code{ped}) is considered to be a member of the
#' group.
#' @param ped Dataframe that is the \code{Pedigree}. It contains pedigree
#' information. The \code{id}, \code{dam}, \code{sex} and \code{age}
#' (in years) columns are required.
#' @param minDamAge numeric minimum age in years for a female to be counted
#' as a breeding-capacity dam in the production ratio. Defaults to 3, a
#' demographic threshold distinct from the quality-control parent-age floor.
#' A female with no birth date has no age to compare with it; see
#' \code{damIds}.
#' @param minParentAge Deprecated scalar minimum dam age. Supplying it sets
#' \code{minDamAge}; use \code{minDamAge} instead.
#' @param maxOffspringAge Numeric values to set the maximum age in years for
#' an animal to be counted as birth in calculation of production status
#' ratio.
#' @param housing character vector of length 1 having the housing type, which
#' is either \emph{"shelter_pens"} or \emph{"corral"}.
#' @param currentDate Date to be used for calculating age. Defaults to
#'        \code{Sys.Date()}.
#' @param damIds character vector of the IDs listed as a dam anywhere in the
#' pedigree, not only in \code{ped} (the group), so a mother whose offspring
#' are in another group is still found. A female with no birth date counts as
#' a breeding-age dam only when her ID is in it. Defaults to the dams listed in
#' \code{ped}.
#' @return A list with \code{production} -- ratio of the number of births that
#' lived at least 30 days to the number of breeding-age females (those >=
#' \code{minDamAge} years of age, plus the counted females with no birth date,
#' see \code{damIds}) -- plus \code{color} and \code{colorIndex}. When the group
#' has no such females the ratio is undefined: all three are \code{NA}
#' (deliberately not green, to avoid reporting missing data as a healthy
#' condition).
#'
#' @importFrom lubridate as.duration ddays interval mdy year
#' @importFrom lifecycle deprecated is_present deprecate_warn
#' @noRd
getProductionStatus <- function(ped, minDamAge = 3L,
                                minParentAge = lifecycle::deprecated(),
                                maxOffspringAge = NULL,
                                housing = "shelter_pens",
                                currentDate = Sys.Date(),
                                damIds = ped$dam) {
  if (lifecycle::is_present(minParentAge)) {
    lifecycle::deprecate_warn(
      when = "2.0.0",
      what = "getProductionStatus(minParentAge)",
      details = "Use minDamAge instead."
    )
    ## Production status is females-only, so the legacy scalar sets the dam
    ## floor; a supplied minParentAge overrides the minDamAge default.
    if (!is.null(minParentAge)) minDamAge <- minParentAge
  }
  expectedCols <- c("id", "dam", "sex", "age")
  if (!all(expectedCols %in%
    names(ped))) {
    missingCol <- expectedCols[!expectedCols %in% names(ped)]
    stop("ped is missing: ", missingCol)
  }
  ## A female of known age counts when she is at least minDamAge. A female with
  ## no birth date counts only when she is listed in damIds (the whole
  ## pedigree's dams). An NA from a blank sex is dropped, not counted.
  ## damIds is first read here, before ped is reduced below.
  isFemale <- ped$sex == sexCodes[["female"]]
  nDam <- sum(isFemale & ped$age >= minDamAge,
              isCountedMotherWithoutBirthDate(ped$id, ped$sex, is.na(ped$age),
                                              damIds),
              na.rm = TRUE)
  if (is.null(maxOffspringAge)) {
    # nolint start: nonportable_path_linter
    maxOffspringAge <- mdy(paste0("1/1/", year(currentDate) - 2L))
    startDate <- mdy(paste0("1/1/", year(currentDate) - 2L))
    endDate <- mdy(paste0("12/31/", year(currentDate) - 1L))
    # nolint end:
  }
  ped <- ped[!(is.na(ped$birth) | is.na(ped$exit)), ]
  nOffspring <-
    nrow(ped[ped$birth >= startDate &
      ped$birth <= endDate &
      as.numeric(as.duration(
        interval(ped$birth, ped$exit)
      ) / ddays(1L)) >= 30L, ])
  if (nDam > 0L) {
    production <- nOffspring / nDam
  } else {
    production <- NA
  }

  if (housing == "shelter_pens") {
    if (is.na(production)) {
      color <- NA_character_
      colorIndex <- NA_integer_
    } else if (production > 0.63) {
      color <- "green"
      colorIndex <- 3L
    } else if (production < 0.6) {
      color <- "red"
      colorIndex <- 1L
    } else if (production >= 0.6 && production <= 0.63) {
      color <- "yellow"
      colorIndex <- 2L
    }
  } else if (housing == "corral") {
    if (is.na(production)) {
      color <- NA_character_
      colorIndex <- NA_integer_
    } else if (production > 0.53) {
      color <- "green"
      colorIndex <- 3L
    } else if (production < 0.5) {
      color <- "red"
      colorIndex <- 1L
    } else if (production >= 0.5 && production <= 0.53) {
      color <- "yellow"
      colorIndex <- 2L
    }
  } else {
    stop(
      "Undefined housing type in getProduction status is: ",
      housing
    )
  }
  list(production = production, color = color, colorIndex = colorIndex)
}
