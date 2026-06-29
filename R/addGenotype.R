#' Add genotype data to pedigree file
#'
## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Assumes genotype has been opened by \code{checkGenotypeFile}
#'
#' @details
#' The two allele columns are coerced to character internally so the name-keyed
#' allele dictionary is both built and indexed by allele label. This keeps the
#' integer encoding consistent even when the allele columns are supplied as
#' factors (a factor would otherwise be indexed by its integer codes).
#'
#' @return A pedigree object with genotype data added.
#'
#' @examples
#' library(nprcgenekeepr)
#' rhesusPedigree <- nprcgenekeepr::rhesusPedigree
#' rhesusGenotypes <- nprcgenekeepr::rhesusGenotypes
#' pedWithGenotypes <- addGenotype(
#'   ped = rhesusPedigree,
#'   genotype = rhesusGenotypes
#' )
#'
#' @param ped pedigree dataframe. \code{ped} is to be provided by
#' \code{qcStudbook} so it is not checked.
#' @param genotype genotype dataframe. \code{genotype} is to be provided by
#' \code{checkGenotypeFile} so it is not checked.
#' @export
addGenotype <- function(ped, genotype) {
  genotypeNames <- names(genotype)[2L:3L]
  # Coerce the two allele columns to character so the name-keyed genoDict is
  # both built and indexed by allele label. A factor column would otherwise be
  # silently indexed by its integer codes, yielding an encoding that is
  # inconsistent between the two columns (and between callers).
  genotype[[genotypeNames[1L]]] <- as.character(genotype[[genotypeNames[1L]]])
  genotype[[genotypeNames[2L]]] <- as.character(genotype[[genotypeNames[2L]]])
  geno <- sort(unique(c(
    genotype[, genotypeNames[1L]],
    genotype[, genotypeNames[2L]]
  )))
  genoDict <- seq_along(geno) + 10000L
  names(genoDict) <- geno
  genotype <- cbind(genotype,
    first = as.integer(genoDict[genotype[, 2L]]),
    second = as.integer(genoDict[genotype[, 3L]])
  )
  newPed <- merge(ped, genotype, by = "id", all = TRUE)
  newPed
}
