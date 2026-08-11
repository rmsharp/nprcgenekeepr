## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Check a locus-metadata sidecar table and classify per-locus coverage
#'
#' Validates the structure of a locus-metadata sidecar table (\code{locus},
#' \code{chrom}, \code{pos}, and optionally \code{cM}) -- the schema
#' introduced by issue #152's own design decision and reused verbatim by
#' issue #153 -- and classifies each locus into one of three coverage
#' tiers, following a PLINK-style three-state coverage model:
#' \code{"full"} (both \code{chrom} and \code{pos} present; \code{cM} is
#' optional even within \code{"full"}), \code{"partial"} (exactly one of
#' \code{chrom}/\code{pos} present), or \code{"none"} (neither present).
#'
#' @details
#' A locus-metadata table has one row per locus (not per individual x
#' locus, unlike \code{\link{checkMarkerGenotypeFile}}'s genotype table).
#' Real curated marker panels typically supply little to no locus-order
#' metadata -- this function reports coverage explicitly per locus rather
#' than requiring complete metadata before any downstream use.
#'
#' @param locusMetadata dataframe with locus metadata: three or four
#' columns, \code{locus}, \code{chrom}, \code{pos}, and optionally
#' \code{cM} (one row per locus).
#' @return The locus-metadata dataframe, checked to ensure the column
#' count, first-column identity, and row uniqueness are all valid, with a
#' new \code{coverage} column appended (\code{"full"}/\code{"partial"}/
#' \code{"none"}). The returned dataframe has \code{locus} and \code{chrom}
#' coerced to character.
#'
#' @references Purcell, S., Neale, B., Todd-Brown, K., Thomas, L., Ferreira,
#' M. A. R., Bender, D., Maller, J., Sklar, P., de Bakker, P. I. W., Daly,
#' M. J., & Sham, P. C. (2007). PLINK: a tool set for whole-genome
#' association and population-based linkage analyses. \emph{American
#' Journal of Human Genetics}, 81(3), 559-575. \doi{10.1086/519795}
#'
#' @seealso \code{\link{checkMarkerGenotypeFile}}
#' @export
#' @examples
#' library(nprcgenekeepr)
#' locusMetadata <- data.frame(
#'   locus = c("L1", "L2", "L3"),
#'   chrom = c("1", "1", NA),
#'   pos = c(1000000, NA, NA),
#'   stringsAsFactors = FALSE
#' )
#' checkLocusMetadata(locusMetadata)
checkLocusMetadata <- function(locusMetadata) {
  cols <- names(locusMetadata)
  if (!(length(cols) %in% c(3L, 4L))) {
    stop("Locus metadata must have three or four columns: locus, chrom, ",
         "pos, and optionally cM.")
  }
  if (!grepl("locus", cols[1L], ignore.case = TRUE)) {
    stop("Locus metadata must have 'locus' as the first column.")
  }
  if (length(cols) == 4L) {
    names(locusMetadata) <- c("locus", "chrom", "pos", "cM")
  } else {
    names(locusMetadata) <- c("locus", "chrom", "pos")
  }

  isDupe <- duplicated(locusMetadata$locus)
  if (any(isDupe)) {
    dupes <- unique(locusMetadata$locus[isDupe])
    stop("Locus metadata has duplicate locus value(s): ",
         toString(dupes), ".")
  }

  locusMetadata$locus <- as.character(locusMetadata$locus)
  locusMetadata$chrom <- as.character(locusMetadata$chrom)

  hasChrom <- !is.na(locusMetadata$chrom)
  hasPos <- !is.na(locusMetadata$pos)
  ## A lookup table indexed by how many of chrom/pos are present (0, 1, or
  ## 2), avoiding a nested ifelse() (nested_ifelse_linter).
  nMetadata <- as.integer(hasChrom) + as.integer(hasPos)
  locusMetadata$coverage <- c("none", "partial", "full")[nMetadata + 1L]

  locusMetadata
}
