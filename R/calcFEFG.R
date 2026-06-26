#' Calculates Founder Equivalents and Founder Genome Equivalents
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Part of the Genetic Value Analysis
#'
#' @return The list containing the founder equivalents,
#' \code{FE = 1 / sum(p ^ 2)}, and the founder genome equivalents,
#' \code{FG = 1 / sum( (p ^ 2) / r)} where \code{p} is the vector of founder
#' mean contributions to the current descendants and \code{r} is the mean
#' number of founder alleles retained in the gene dropping experiment.
#'
#' \code{FE} is deterministic and always returned. \code{FG} is \code{NA} (with a
#' warning) when a contributing founder (\code{p > 0}) is retained in zero of the
#' gene-drop iterations (\code{r == 0}), which would otherwise collapse \code{FG}
#' silently to 0; raise the number of iterations. See \code{\link{calcFGSE}} for
#' the sampling standard error of \code{FG}.
#'
#' @param ped the pedigree information in datatable format.  Pedigree
#' (req. fields: id, sire, dam, gen, population).
#'
#' The pedigree must have no partial parentage (every animal has both parents
#' known or both unknown); \code{calcFEFG} stops with an error otherwise.
#' @param alleles dataframe contains an \code{AlleleTable}. This is a
#' table of allele information produced by \code{geneDrop()}.
#' @export
#' @examples
#' data(lacy1989Ped)
#' ## Example from Analysis of Founder Representation in Pedigrees: Founder
#' ## Equivalents and Founder Genome Equivalents.
#' ## Zoo Biology 8:111-123, (1989) by Robert C. Lacy
#'
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::lacy1989Ped
#' alleles <- lacy1989PedAlleles
#' pedFactors <- data.frame(
#'   id = as.factor(ped$id),
#'   sire = as.factor(ped$sire),
#'   dam = as.factor(ped$dam),
#'   gen = ped$gen,
#'   population = ped$population,
#'   stringsAsFactors = TRUE
#' )
#' allelesFactors <- geneDrop(pedFactors$id, pedFactors$sire, pedFactors$dam,
#'   pedFactors$gen,
#'   genotype = NULL, n = 1000,
#'   updateProgress = NULL
#' )
#' feFg <- calcFEFG(ped, alleles)
#' feFgFactors <- calcFEFG(pedFactors, allelesFactors)
calcFEFG <- function(ped, alleles) {
  ## Founder-contribution algorithm + partial-parentage guard are shared with
  ## calcFE()/calcFG() via calcFounderContributions() (NEW-13/NEW-23). fc$ped is
  ## the toCharacter()-coerced pedigree, fed to calcRetention() exactly as the
  ## pre-refactor code did.
  fc <- calcFounderContributions(ped, "calcFEFG") # nolint: object_usage_linter
  r <- calcRetention(fc$ped, alleles)
  fe <- 1L / sum(fc$p^2L)
  ## FE is deterministic and always returned; FG hard-fails (NA + warning) on the
  ## same zero-retention silent collapse calcFG guards against.
  if (checkFgDegeneracy(fc$p, r)) {
    return(list(FE = fe, FG = NA_real_))
  }
  list(FE = fe, FG = 1L / sum((fc$p^2L) / r, na.rm = TRUE))
}
