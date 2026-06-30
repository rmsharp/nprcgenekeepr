## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Calculates founder Equivalents
#'
#' Part of the Genetic Value Analysis
#'
#' The pedigree must have no partial parentage (every animal has both parents
#' known or both unknown); \code{calcFE} stops with an error otherwise.
#'
#' @return The founder equivalents \code{FE = 1 / sum(p ^ 2)}, where \code{p}
#' is the vector of founder mean contributions to the current descendants.
#'
#' @param ped the pedigree information in datatable format.  Pedigree
#' (req. fields: id, sire, dam, gen, population).
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
#' pedFactors <- data.frame(
#'   id = c("A", "B", "C", "D", "E", "F", "G"),
#'   sire = c(NA, NA, "A", "A", NA, "D", "D"),
#'   dam = c(NA, NA, "B", "B", NA, "E", "E"),
#'   stringsAsFactors = TRUE
#' )
#' pedFactors["gen"] <- findGeneration(
#'   pedFactors$id, pedFactors$sire,
#'   pedFactors$dam
#' )
#' pedFactors$population <- getGVPopulation(pedFactors, NULL)
#' fe <- calcFE(ped)
#' feFactors <- calcFE(pedFactors)
calcFE <- function(ped) {
  ## Founder-contribution algorithm + partial-parentage guard are shared with
  ## calcFG()/calcFEFG() via calcFounderContributions() (NEW-13/NEW-23).
  1L / sum(calcFounderContributions(ped, "calcFE")$p^2L) # nolint: object_usage_linter
}
