## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get the population of interest for the Genetic Value analysis
#'
#' If user has limited the population of interest by defining \code{pop},
#' that information is incorporated via the \code{ped$population} column.
#'
#' @inheritParams reportGV
#' @param pop character vector with animal IDs to consider as the population of
#' interest. The default is NULL.
#' @return A logical vector corresponding to the IDs in the vector of
#' animal IDs provided to the function in \code{pop}.
#'
#' @export
#' @examples
#' ## Example from Analysis of Founder Representation in Pedigrees: Founder
#' ## Equivalents and Founder Genome Equivalents.
#' ## Zoo Biology 8:111-123, (1989) by Robert C. Lacy
#' library(nprcgenekeepr)
#' ped <- data.frame(
#'   id = c("A", "B", "C", "D", "E", "F", "G"),
#'   sire = c(NA, NA, "A", "A", NA, "D", "D"),
#'   dam = c(NA, NA, "B", "B", NA, "E", "E"),
#'   stringsAsFactors = FALSE
#' )
#' ped["gen"] <- findGeneration(ped$id, ped$sire, ped$dam)
#' ped$population <- getGVPopulation(ped, NULL)
getGVPopulation <- function(ped, pop) {
  if (!is.null(pop)) {
    ped$population <- FALSE
    ped$population[ped$id %in% pop] <- TRUE
  } else if (is.null(ped$population)) {
    ped$population <- TRUE
  }
  ped$population
}
