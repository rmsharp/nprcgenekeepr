## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Is a female with no birth date counted as a breeding-age mother?
#'
#' The one place the rule lives: a female with no birth date counts as a
#' breeding-age mother only when the pedigree lists her as a dam (\code{damIds},
#' the dams of the whole pedigree, not only of her group). The Production
#' count and the Inbreeding count of breeding-age females reach it through
#' \code{isBreedingAgeFemale()}, and the Genetic Diversity note's "counted /
#' left out" numbers use it directly, so the note cannot disagree with the
#' counts.
#'
#' @param id character vector of animal IDs.
#' @param sex character vector of sex codes, the same length as \code{id}.
#' @param birthUnknown logical vector, the same length as \code{id}; \code{TRUE}
#' where the animal has no birth date.
#' @param damIds character vector of the IDs listed as a dam in the pedigree.
#' @return A logical vector the length of \code{id}. It is \code{NA} where
#' \code{sex} is blank; callers drop those with \code{na.rm = TRUE}.
#' @noRd
isCountedMotherWithoutBirthDate <- function(id, sex, birthUnknown, damIds) {
  sex == sexCodes[["female"]] & birthUnknown & id %in% damIds
}
