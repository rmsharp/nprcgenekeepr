#' Calculates Founder Genome Equivalents
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Part of the Genetic Value Analysis
#'
#' @return The founder genome equivalents,
#' \code{FG = 1 / sum( (p ^ 2) / r)} where \code{p} is the vector of founder
#' mean contributions to the current descendants and \code{r} is the mean
#' number of founder alleles retained in the gene dropping experiment.
#'
#' Returns \code{NA} with a warning when a contributing founder (\code{p > 0}) is
#' retained in zero of the gene-drop iterations (\code{r == 0}): that term is
#' \code{p^2 / 0 = Inf}, which would otherwise collapse \code{FG} silently to 0.
#' Raise the number of iterations. See \code{\link{calcFGSE}} for the sampling
#' standard error of \code{FG}.
#'
#' @param ped the pedigree information in datatable format.  Pedigree
#' (req. fields: id, sire, dam, gen, population).
#' The pedigree must have no partial parentage (every animal has both parents
#' known or both unknown); \code{calcFG} stops with an error otherwise.
#' @param alleles dataframe contains an \code{AlleleTable}. This is a
#' table of allele information produced by \code{geneDrop()}.
#' @export
#' @examples
#' ## Example from Analysis of Founder Representation in Pedigrees: Founder
#' ## Equivalents and Founder Genome Equivalents.
#' ## Zoo Biology 8:111-123, (1989) by Robert C. Lacy
#'
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
#' alleles <- geneDrop(ped$id, ped$sire, ped$dam, ped$gen,
#'   genotype = NULL,
#'   n = 1000, updateProgress = NULL
#' )
#' allelesFactors <- geneDrop(pedFactors$id, pedFactors$sire, pedFactors$dam,
#'   pedFactors$gen,
#'   genotype = NULL, n = 1000,
#'   updateProgress = NULL
#' )
#' fg <- calcFG(ped, alleles)
#' fgFactors <- calcFG(pedFactors, allelesFactors)
calcFG <- function(ped, alleles) {
  ## Founder-contribution algorithm + partial-parentage guard are shared with
  ## calcFE()/calcFEFG() via calcFounderContributions() (NEW-13/NEW-23). fc$ped
  ## is the toCharacter()-coerced pedigree, fed to calcRetention() as before.
  fc <- calcFounderContributions(ped, "calcFG") # nolint: object_usage_linter
  r <- calcRetention(fc$ped, alleles)
  ## Align retention to contributions by NAME before dividing (issue #86,
  ## Dragon D-3): calcRetention() returns r id-sorted (tapply) while fc$p is in
  ## getFounders() pedigree-row order, so a positional p^2 / r pairs the wrong
  ## founders -- a silently wrong FG (e.g. a collapse to 0) on any pedigree whose
  ## founders are not already in sorted id order.
  r <- r[names(fc$p)]
  ## Hard-fail (NA + warning) the silent FG collapse when a contributing founder
  ## is retained in zero drops; the point estimate is unchanged otherwise.
  if (checkFgDegeneracy(fc$p, r)) {
    return(NA_real_)
  }
  1L / sum((fc$p^2L) / r, na.rm = TRUE)
}
