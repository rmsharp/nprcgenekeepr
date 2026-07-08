## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Count each individual's rare alleles per simulation
#'
#' Part of Genetic Value Analysis
#'
#' @param alleles a matrix with \{V1 ... Vn, id, parent\} providing the alleles
#' an animal received during each simulation.
#' The first n columns provide the alleles; the final two columns provide the
#' animal ID and the parent the allele came from.
#' @inheritParams calcGU
#' @param byID logical variable of length 1 that is passed through to
#' eventually be used by \code{alleleFreq()}, which calculates the count of each
#'  allele in the provided vector. If \code{byID} is TRUE and ids are provided,
#'  the function will only count the unique alleles for an individual
#'   (homozygous alleles will be counted as 1).
#' @return A matrix with named rows indicating the number of unique alleles
#'   an animal had during each round of simulation (indicated in columns).
#'
#' @references Ballou JD, Lacy RC.  1995. Identifying genetically important
#' individuals for management of genetic variation in pedigreed populations,
#' p 77-111. In: Ballou JD, Gilpin M, Foose TJ, editors.
#' Population management for survival and recovery. New York (NY):
#' Columbia University Press.
#' @references MacCluer JW, et al. 1986. Pedigree analysis by computer
#' simulation. Zoo Biology 5:147-160.
#' @family genetic value analysis
#' @export
#' @examples
#' library(nprcgenekeepr)
#' rare <- calcA(nprcgenekeepr::ped1Alleles, threshold = 3, byID = FALSE)
calcA <- function(alleles, threshold = 1L, byID = FALSE) {
  ids <- alleles$id
  alleles <- alleles[, !(names(alleles) %in% c("id", "parent"))]

  countRare <- function(a) {
    if (byID) {
      f <- alleleFreq(a, ids)
    } else {
      f <- alleleFreq(a)
    }
    rareAlleles <- f$allele[f$freq <= threshold]
    a <- (a %in% rareAlleles)
    tapply(a, ids, sum)
  }

  apply(alleles, 2L, countRare)
}
