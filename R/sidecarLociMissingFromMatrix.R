## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Locus-file loci that a genotype matrix lacks
#'
#' The loci of the locus metadata file that have full coverage (a chromosome
#' and a position) and are not columns of the genotype matrix, in locus-file
#' order. These are the loci \code{computeGenomicROH} leaves out of the genome
#' length every animal's F_ROH is divided by. It is one function so that the
#' warning \code{computeGenomicROH} raises and the notice the Genomic ROH tab
#' shows name the same loci. A locus without a position never enters that
#' genome length, so its absence is not reported.
#'
#' @param genotypeMatrix a character matrix as returned by
#' \code{buildMarkerGenotypeMatrix}; only its column names are read.
#' @param locusMetadata the output of \code{checkLocusMetadata}, which carries
#' the \code{coverage} column.
#' @return A character vector of locus names, empty when the matrix holds every
#' full-coverage locus.
#'
#' @noRd
sidecarLociMissingFromMatrix <- function(genotypeMatrix, locusMetadata) {
  fullLoci <- locusMetadata$locus[locusMetadata$coverage == "full"]
  fullLoci[!fullLoci %in% colnames(genotypeMatrix)]
}

#' Name the first few loci of a long list
#'
#' Up to \code{maxNamed} loci joined by commas; a longer list names the first
#' \code{maxNamed} and then says how many more there are, so a 1,000-locus
#' locus file against a 12-locus genotype file does not name 988 loci.
#'
#' @param loci a character vector of locus names.
#' @param maxNamed the most loci to name. Default \code{10L}.
#' @return A single string such as \code{"L2, L4, L6"} or
#' \code{"L03, ..., L12, and 2 more"}.
#'
#' @noRd
nameLoci <- function(loci, maxNamed = 10L) {
  if (length(loci) <= maxNamed) {
    return(toString(loci))
  }
  paste0(toString(loci[seq_len(maxNamed)]), ", and ",
         length(loci) - maxNamed, " more")
}
