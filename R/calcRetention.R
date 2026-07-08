## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Calculate allelic retention
#'
#' Part of Genetic Value Analysis
#'
#' @param ped the pedigree information in datatable format.  Pedigree
#' (req. fields: id, sire, dam, gen, population).
#'
#' It is assumed that the pedigree has no partial parentage
#' @param alleles dataframe of containing an \code{AlleleTable}. This is a
#' table of allele information produced by \code{geneDrop()}.
#' @return A vector of the mean number of founder alleles retained in the
#' gene dropping simulation.
#'
#' @references Lacy RC. 1989. Analysis of founder representation in
#' pedigrees: founder equivalents and founder genome equivalents. Zoo Biol
#' 8:111-123.
#' @family genetic value analysis
#' @export
#' @examples
#' library(nprcgenekeepr)
#' data("lacy1989Ped")
#' data("lacy1989PedAlleles")
#' ped <- lacy1989Ped
#' alleles <- lacy1989PedAlleles
#' retention <- calcRetention(ped, alleles)
calcRetention <- function(ped, alleles) {
  # ASSUME: Pedigree has no partial parentage
  founders <- getFounders(ped)
  descendants <- ped$id[ped$population & !(ped$id %in% founders)]

  founders <- alleles[(alleles$id %in% founders), c("id", "V1")]
  colnames(founders) <- c("id", "allele")

  alleles <- alleles[
    (alleles$id %in% descendants),
    !(colnames(alleles) %in% c("id", "parent"))
  ]

  retained <- apply(alleles, 2L, function(a) {
    founders$allele %in% a
  })
  retained <- rowSums(retained, na.rm = TRUE) / ncol(retained)
  founders <- cbind(founders, retained)

  founders <- tapply(founders$retained, founders$id, mean)
  founders
}
