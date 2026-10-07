## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get kinship-with-male status of a breeding group
#'
#' @details Among the females in a breeding group that are old enough to
#' breed (age >= \code{minFemaleAge}), the fraction that are essentially
#' unrelated (kinship <= \code{threshold}) to at least one breeding-age male
#' (age >= \code{minMaleAge}) in the group. A higher fraction is healthier
#' because more females have an unrelated potential mate; the heat-map color
#' is red (fraction < 0.6), yellow (0.6 <= fraction <= 0.9), or green
#' (fraction > 0.9).
#'
#' When the group has no breeding-age females the denominator is empty and
#' the metric is undefined: \code{fraction}, \code{color}, and
#' \code{colorIndex} are all returned as \code{NA} (deliberately not green,
#' to avoid reporting missing data as a healthy condition).
#'
#' An animal whose age or sex is missing (\code{NA}) cannot be shown to be a
#' breeding-age female or male, so it is left out of both counts, with one
#' exception: a female with no age (no birth date) counts as a breeding-age
#' female when the pedigree lists an offspring for her (\code{damIds}), the
#' same rule the Production cell uses. A male with no age is never counted.
#'
#' @param group Dataframe of the group members. The \code{id}, \code{sex}
#' (\code{"F"}/\code{"M"}), and \code{age} (in years) columns are required.
#' @param kmat Square kinship matrix for the group whose row and column
#' names are the member \code{id}s (for example one element of the
#' \code{groupKinship} list returned by \code{modBreedingGroupsServer}, or
#' the output of \code{\link{kinship}}). Every \code{group$id} must be
#' present in \code{rownames(kmat)}.
#' @param minFemaleAge Numeric minimum age in years for a female to be
#' counted. Defaults to 3.
#' @param minMaleAge Numeric minimum age in years for a male to be counted
#' as a potential mate. Defaults to 5.
#' @param threshold Numeric kinship at or below which a female and male are
#' treated as unrelated. Defaults to 0.015625.
#' @param damIds Character vector of the IDs listed as a dam anywhere in the
#' pedigree, not only in \code{group}. A female with no age counts as a
#' breeding-age female only when her ID is in it. Defaults to none, so a female
#' with no age is left out.
#' @return A list with \code{fraction} -- the proportion of breeding-age
#' females unrelated to at least one breeding-age male; \code{color} -- the
#' heat-map color ("red", "yellow", or "green"); and \code{colorIndex} --
#' the integer 1, 2, or 3 corresponding to red, yellow, and green. All three
#' are \code{NA} when the group has no breeding-age females.
#' @noRd
getKinshipWithMaleStatus <- function(group, kmat, minFemaleAge = 3L,
                                     minMaleAge = 5L,
                                     threshold = 0.015625,
                                     damIds = character(0L)) {
  expectedCols <- c("id", "sex", "age")
  if (!all(expectedCols %in% names(group))) {
    missingCol <- expectedCols[!expectedCols %in% names(group)]
    stop("group is missing: ", missingCol)
  }
  if (!all(group$id %in% rownames(kmat))) {
    missingId <- group$id[!group$id %in% rownames(kmat)]
    stop("kmat is missing kinship for group member(s): ",
         toString(missingId))
  }
  countedWithoutAge <- isCountedMotherWithoutBirthDate(
    group$id, group$sex, is.na(group$age), damIds
  )
  females <- group$id[which((group$sex == sexCodes[["female"]] &
                               group$age >= minFemaleAge) |
                              countedWithoutAge)]
  males <- group$id[which(group$sex == sexCodes[["male"]] &
                            group$age >= minMaleAge)]
  if (length(females) == 0L) {
    return(list(fraction = NA_real_, color = NA_character_,
                colorIndex = NA_integer_))
  }
  if (length(males) == 0L) {
    fraction <- 0.0
  } else {
    hasUnrelatedMale <- vapply(females, function(f) {
      any(kmat[f, males] <= threshold)
    }, logical(1L))
    fraction <- sum(hasUnrelatedMale) / length(females)
  }
  if (fraction < 0.6) {
    color <- "red"
    colorIndex <- 1L
  } else if (fraction <= 0.9) {
    color <- "yellow"
    colorIndex <- 2L
  } else {
    color <- "green"
    colorIndex <- 3L
  }
  list(fraction = fraction, color = color, colorIndex = colorIndex)
}
