## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Parse per-animal MHC haplotype designations into a long call table
#'
#' Internal parse rule for MHC haplotype reporting (issue #148 design plan
#' D3, ratified S704): \code{NA} or an empty string is a MISSING call; a
#' designation matching \code{^(.+)\\?$} is an UNCERTAIN (provisional)
#' call of the haplotype with the trailing \code{?} stripped; anything
#' else is a certain call. Labels are otherwise opaque (design plan D9):
#' a bare \code{"?"} has no label part to strip, so it is treated as a
#' certain call of the literal label \code{"?"}, not judged. Total
#' function over \code{\link{checkMhcHaplotypeFile}}-validated input --
#' no error paths.
#'
#' @param genotype dataframe as returned by
#' \code{\link{checkMhcHaplotypeFile}}: columns \code{id},
#' \code{haplotype1}, \code{haplotype2}, one row per animal.
#' @return A data.frame with one row per (animal x designation column),
#' i.e. 2 rows per animal: \code{id} (character), \code{haplotype}
#' (character; the designation with any trailing \code{?} stripped, or
#' \code{NA} when missing), \code{uncertain} (logical), \code{missing}
#' (logical).
#' @keywords internal
.parseMhcHaplotypeCalls <- function(genotype) {
  id <- rep(as.character(genotype$id), 2L)
  call <- c(as.character(genotype$haplotype1),
            as.character(genotype$haplotype2))
  isMissing <- is.na(call) | !nzchar(call)
  isUncertain <- !isMissing & grepl("^(.+)\\?$", call)
  haplotype <- call
  haplotype[isMissing] <- NA_character_
  haplotype[isUncertain] <- sub("\\?$", "", haplotype[isUncertain])
  data.frame(
    id = id,
    haplotype = haplotype,
    uncertain = isUncertain,
    missing = isMissing,
    stringsAsFactors = FALSE
  )
}
