## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Is an animal a breeding-age female?
#'
#' The one place the Genetic Diversity cells say who counts as a breeding-age
#' female: a female whose known age is at least \code{minAge}, or a female with
#' no birth date that the pedigree lists as a dam
#' (\code{\link{isCountedMotherWithoutBirthDate}}). The Production count of
#' dams and the Inbreeding count of females both use it, so the two cells
#' cannot disagree about who is in the count.
#'
#' @param id character vector of animal IDs.
#' @param sex character vector of sex codes, the same length as \code{id}.
#' @param age numeric vector of ages in years, the same length as \code{id};
#' \code{NA} where the animal has no birth date.
#' @param minAge numeric minimum age in years for a female of known age.
#' @param damIds character vector of the IDs listed as a dam in the pedigree.
#' @return A logical vector the length of \code{id}: \code{TRUE} for a
#' breeding-age female. It is \code{NA}, not \code{FALSE}, where the answer is
#' unknown: a blank \code{sex}, or a female with no age that the offspring rule
#' does not count. \code{NA} means not counted; callers drop it with
#' \code{na.rm = TRUE} or \code{which()}.
#' @noRd
isBreedingAgeFemale <- function(id, sex, age, minAge, damIds) {
  (sex == sexCodes[["female"]] & age >= minAge) |
    isCountedMotherWithoutBirthDate(id, sex, is.na(age), damIds)
}
