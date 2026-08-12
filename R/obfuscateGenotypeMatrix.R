## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' De-identify a sequence-scale genotype matrix
#'
#' Remaps the row names (individual \code{id}s) of a
#' \code{\link{buildMarkerGenotypeMatrix}}-shaped wide genotype matrix
#' through the same alias vector \code{\link{obfuscatePed}(..., map =
#' TRUE)} already returns, mirroring \code{\link{obfuscateTwinRelations}}'s
#' and \code{\link{obfuscateLdBlocks}}'s pattern. Genotype/allele values
#' themselves are never perturbed -- unlike a date, there is no
#' scientifically-valid "obfuscation" of an allele call that preserves
#' validity while hiding identity, so the only real protection this
#' primitive provides is which people see the exported file at all (issue
#' #152 Slice 4, design decision D7).
#'
#' A row whose id is absent from \code{map} \code{stop()}s rather than
#' silently dropping or leaking the real id.
#'
#' @param genotypeMatrix a character matrix as returned by
#' \code{\link{buildMarkerGenotypeMatrix}}: rows are individual \code{id}s,
#' columns are loci.
#' @param map named character vector of aliases, keyed by the original id
#' -- the \code{map} element of \code{\link{obfuscatePed}(..., map =
#' TRUE)}'s return value.
#' @return \code{genotypeMatrix} with row names replaced by their aliases;
#' column names and every genotype cell value are unchanged.
#' @family obfuscation
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- data.frame(
#'   id = c("A01", "A02"),
#'   sire = c(NA, NA),
#'   dam = c(NA, NA),
#'   sex = c("M", "F"),
#'   stringsAsFactors = FALSE
#' )
#' genotypeMatrix <- matrix(
#'   c("A/A", "A/B"), nrow = 2L, dimnames = list(c("A01", "A02"), "L1")
#' )
#' obfuscated <- obfuscatePed(ped, map = TRUE)
#' obfuscateGenotypeMatrix(genotypeMatrix, obfuscated$map)
obfuscateGenotypeMatrix <- function(genotypeMatrix, map) {
  ids <- rownames(genotypeMatrix)
  unknown <- setdiff(ids, names(map))
  if (length(unknown) > 0L) {
    stop("Genotype matrix id(s) not found in the de-identification map: ",
      toString(unknown), ".")
  }
  rownames(genotypeMatrix) <- unname(map[ids])
  genotypeMatrix
}
