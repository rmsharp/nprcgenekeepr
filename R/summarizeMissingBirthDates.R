## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Summarize the animals in breeding groups that have no birth date
#'
#' Counts, for the Genetic Diversity tab's note, the animals in the groups
#' that have no birth date and how the Production cell treats the females among
#' them: a female with no birth date counts as a breeding-age mother only when
#' the pedigree lists an offspring for her, looked up in the whole pedigree
#' (not only in the groups).
#'
#' @param groups list of character vectors of animal IDs, one per breeding
#' group.
#' @param ped data frame that is the pedigree. The \code{id}, \code{dam},
#' \code{sex} and \code{birth} columns are required.
#' @return A list of five integers: \code{animals} (group members with no
#' birth date), \code{total} (group members), \code{females} (females among
#' those with no birth date), \code{femalesCounted} (of those, the ones the
#' pedigree lists as a dam) and \code{femalesLeftOut} (the rest).
#' @noRd
summarizeMissingBirthDates <- function(groups, ped) {
  members <- unique(unlist(groups, use.names = FALSE))
  inGroups <- ped[ped$id %in% members, ]
  noBirth <- inGroups[is.na(inGroups$birth), ]
  nFemales <- length(which(noBirth$sex == sexCodes[["female"]]))
  counted <- sum(
    isCountedMotherWithoutBirthDate(noBirth$id, noBirth$sex,
                                    is.na(noBirth$birth), ped$dam),
    na.rm = TRUE
  )
  list(
    animals = nrow(noBirth),
    total = length(unique(inGroups$id)),
    females = nFemales,
    femalesCounted = counted,
    femalesLeftOut = nFemales - counted
  )
}

#' The sentence the Genetic Diversity tab shows about animals with no birth date
#'
#' @param summary list returned by \code{summarizeMissingBirthDates()}.
#' @return A character vector of length 1.
#' @noRd
makeBirthDateNoteText <- function(summary) {
  paste0(
    summary$animals, " of the ", summary$total, " animals in these groups ",
    if (summary$animals == 1L) "has" else "have",
    " no birth date, so their age is unknown. In the Production ",
    "column, a female with no birth date counts as a breeding-age ",
    "female only when the pedigree lists an offspring for her (",
    summary$femalesCounted, " counted, ", summary$femalesLeftOut, " left out)."
  )
}
