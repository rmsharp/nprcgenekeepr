#' Add genotype data to pedigree file
#'
## Copyright(c) 2017-2023 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Assumes genotype has been opened by \code{checkGenotypeFile}
#'
#' @return A pedigree object with genotype data added.
#'
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' rhesusPedigree <- nprcgenekeepr::rhesusPedigree
#' rhesusGenotypes <- nprcgenekeepr::rhesusGenotypes
#' pedWithGenotypes <- addGenotype(
#'   ped = rhesusPedigree,
#'   genotype = rhesusGenotypes
#' )
#' }
#'
#' @param ped pedigree dataframe. \code{ped} is to be provided by
#' \code{qcStudbook} so it is not checked.
#' @param genotype genotype dataframe. \code{genotype} is to be provided by
#' \code{checkGenotypeFile} so it is not checked.
#' @export
addGenotype <- function(ped, genotype) {
  genotypeNames <- names(genotype)[2:3]
  geno <- sort(unique(c(
    genotype[, genotypeNames[1]],
    genotype[, genotypeNames[2]]
  )))
  genoDict <- seq_along(geno) + 10000
  names(genoDict) <- geno
  genotype <- cbind(genotype,
    first = as.integer(genoDict[genotype[, 2]]),
    second = as.integer(genoDict[genotype[, 3]])
  )
  newPed <- merge(ped, genotype, by = "id", all = TRUE)
  newPed
}
