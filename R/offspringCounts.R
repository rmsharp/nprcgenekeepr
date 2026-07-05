## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Tabulate offspring counts, optionally by population
#'
#' Optionally find the number that are part of the population of interest.
#'
#' @param probands character vector of egos for which offspring should be
#' counted.
#' @param ped the pedigree information in datatable format.  Pedigree
#' (req. fields: id, sire, dam, gen, population).
#' This is the complete pedigree.
#' @param considerPop logical value indication whether or not the number of
#' offspring that are part of the focal population are to be counted?
#' Default is \code{FALSE}.
#' @return A dataframe containing the column \code{totalOffspring} (and
#' \code{livingOffspring} when \code{considerPop} is \code{TRUE}), with the
#' animal ids as the data frame row names.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' examplePedigree <- nprcgenekeepr::examplePedigree
#' breederPed <- qcStudbook(examplePedigree,
#'   minParentAge = 2,
#'   reportChanges = FALSE,
#'   reportErrors = FALSE
#' )
#' focalAnimals <- breederPed$id[!(is.na(breederPed$sire) &
#'   is.na(breederPed$dam)) &
#'   is.na(breederPed$exit)]
#' ped <- setPopulation(ped = breederPed, ids = focalAnimals)
#' trimmedPed <- trimPedigree(focalAnimals, breederPed)
#' probands <- ped$id[ped$population]
#' counts <- offspringCounts(probands, ped)
offspringCounts <- function(probands, ped, considerPop = FALSE) {
  totalOffspring <- findOffspring(probands, ped)
  results <- as.data.frame(totalOffspring)

  if (considerPop && !is.null(ped$population)) {
    pop <- ped[ped$population, ]
    livingOffspring <- findOffspring(probands, pop)
    results <- cbind(results, livingOffspring)
  }
  results
}
