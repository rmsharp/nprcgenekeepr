## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Calculate allelic retention
#'
#' Part of Genetic Value Analysis
#'
#' @param ped the pedigree information in datatable format.  Pedigree
#' (req. fields: id, sire, dam, population).
#'
#' It is assumed that the pedigree has no partial parentage. When the
#' \code{population} column is missing or has no \code{TRUE} values, there
#' are no descendants and every retention value is 0.
#' @param alleles dataframe of containing an \code{AlleleTable}. This is a
#' table of allele information produced by \code{geneDrop()}.
#' @return A named one-dimensional array with one value per founder: the
#' proportion of the gene-drop simulations (a number from 0 to 1, not a count)
#' in which the founder's allele is retained in the population's descendants.
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
