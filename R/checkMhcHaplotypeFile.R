## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Check a wide-format MHC haplotype designation file
#'
#' Validates the structure of a wide per-animal MHC haplotype designation
#' table: exactly three columns -- \code{id} plus the animal's two named
#' haplotype designations, one row per animal. This is the explicit input
#' designation for MHC haplotype reporting (issue #148): a curator
#' designates data as MHC by supplying it through this format, and no MHC
#' semantics are ever inferred from locus or column names (the format has
#' no locus names). A new, sibling input family: the long-format marker
#' validators (\code{\link{checkMarkerGenotypeFile}},
#' \code{\link{checkLinkageMarkerGenotypeFile}},
#' \code{\link{checkSequenceGenotypeFile}}) and the single-locus
#' \code{\link{checkGenotypeFile}} path are untouched by this one.
#'
#' @details
#' Column names are not prescribed: the first column must be id-like
#' (case-insensitive match on \code{"id"}) and is forced to \code{id}; the
#' second and third are forced to \code{haplotype1} and \code{haplotype2},
#' so a colony file with, e.g., \code{first_name}/\code{second_name}
#' headers (the bundled \code{\link{rhesusGenotypes}} shape) loads
#' unchanged. \code{NA}/empty cells pass validation -- a missing call is
#' the statistics layer's concern, not a structural error. A trailing
#' \code{?} on a designation (an uncertain, provisional call) is likewise
#' not validation's business; see the issue #148 design plan's D3 parse
#' rule. Haplotype designations are otherwise opaque labels: never parsed,
#' split, or matched against MHC region names.
#'
#' @param genotype dataframe with wide-format MHC haplotype data: exactly
#' three columns, \code{id}, \code{haplotype1}, \code{haplotype2} (one row
#' per animal; any column names, see Details).
#' @return The genotype dataframe, checked to ensure the column count,
#' first-column identity, and row uniqueness are all valid. The returned
#' dataframe has its column names forced to \code{c("id", "haplotype1",
#' "haplotype2")}.
#'
#' @seealso \code{\link{rhesusGenotypes}},
#' \code{\link{checkMarkerGenotypeFile}}
#' @export
#' @examples
#' library(nprcgenekeepr)
#' checked <- checkMhcHaplotypeFile(rhesusGenotypes)
#' head(checked)
checkMhcHaplotypeFile <- function(genotype) {
  cols <- names(genotype)
  if (length(cols) != 3L) {
    stop("MHC haplotype file must have exactly three columns: id, ",
         "haplotype1, haplotype2.")
  }
  if (!grepl("id", cols[1L], ignore.case = TRUE)) {
    stop("MHC haplotype file must have 'id' as the first column.")
  }
  names(genotype) <- c("id", "haplotype1", "haplotype2")

  isDupe <- duplicated(genotype$id)
  if (any(isDupe)) {
    dupes <- unique(genotype$id[isDupe])
    stop("MHC haplotype file has duplicate id row(s): ",
         toString(dupes), ".")
  }

  genotype
}
