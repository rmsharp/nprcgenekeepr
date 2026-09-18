## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' List the animals carrying each MHC haplotype
#'
#' Builds the carrier detail table for a wide per-animal MHC haplotype
#' designation file (the \code{\link{checkMhcHaplotypeFile}} format): one
#' row per (haplotype x carrying animal), so a colony manager can go from
#' "which haplotypes are rare" (\code{\link{mhcHaplotypeFrequency}}'s
#' summary) to "which animals do I manage." A homozygous animal appears
#' once per haplotype. The haplotype universe is the summary's -- the
#' distinct \emph{certain} haplotypes -- so a label observed only as
#' uncertain calls has no carrier rows, matching the summary's own
#' exclude-and-disclose rule.
#'
#' @details
#' The \code{uncertain} column is a per-(haplotype x animal) disclosure:
#' \code{FALSE} when the animal has at least one certain call of that
#' haplotype, \code{TRUE} when its carriage is only provisional (every
#' call it has of that haplotype carries the trailing-\code{?} uncertain
#' marker). Provisional carriers are listed here -- for a rare haplotype,
#' a provisionally typed carrier is exactly what a manager wants to see --
#' but they are never counted in \code{\link{mhcHaplotypeFrequency}}'s
#' \code{nCarriers} or its rare-flag arithmetic. Retaining animals that
#' carry rare variants is a distinct management objective from
#' maintaining heterozygosity (Allendorf 1986; Lacy, Ballou & Pollak
#' 2012), which is what a per-animal carrier list is for.
#'
#' @param genotype dataframe with wide-format MHC haplotype data as
#' validated by \code{\link{checkMhcHaplotypeFile}} (which this function
#' re-runs defensively): columns \code{id}, \code{haplotype1},
#' \code{haplotype2}, one row per animal.
#' @param rareOnly logical; when \code{TRUE} (the default) only the
#' haplotypes \code{\link{mhcHaplotypeFrequency}} flags rare at the given
#' thresholds are listed, when \code{FALSE} every summary haplotype is.
#' @param rareFrequencyThreshold single non-negative number, passed to
#' \code{\link{mhcHaplotypeFrequency}}. Default \code{0.01}.
#' @param rareCarrierThreshold single non-negative number, passed to
#' \code{\link{mhcHaplotypeFrequency}}. Default \code{2L}.
#' @return A dataframe with columns \code{haplotype} (character),
#' \code{id} (character), and \code{uncertain} (logical), one row per
#' (haplotype x carrying animal), ordered by haplotype then id.
#'
#' @references Allendorf, F. W. (1986). Genetic drift and the loss of
#' alleles versus heterozygosity. \emph{Zoo Biology}, 5(2), 181-190.
#' \doi{10.1002/zoo.1430050212}
#' @references Lacy, R. C., Ballou, J. D., & Pollak, J. P. (2012). PMx:
#' software package for demographic and genetic analysis and management
#' of pedigreed populations. \emph{Methods in Ecology and Evolution},
#' 3(2), 433-437. \doi{10.1111/j.2041-210X.2011.00148.x}
#'
#' @seealso \code{\link{mhcHaplotypeFrequency}},
#' \code{\link{checkMhcHaplotypeFile}}, \code{\link{rhesusGenotypes}}
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ## Carriers of the rare haplotypes, at the default thresholds
#' rareCarriers <- mhcHaplotypeCarriers(rhesusGenotypes)
#' head(rareCarriers)
#' ## Every haplotype's carriers
#' allCarriers <- mhcHaplotypeCarriers(rhesusGenotypes, rareOnly = FALSE)
mhcHaplotypeCarriers <- function(genotype, rareOnly = TRUE,
                                 rareFrequencyThreshold = 0.01,
                                 rareCarrierThreshold = 2L) {
  frequency <- mhcHaplotypeFrequency(genotype, rareFrequencyThreshold,
                                     rareCarrierThreshold)
  wanted <- frequency$summary$haplotype
  if (rareOnly) {
    wanted <- wanted[frequency$summary$isRare]
  }

  calls <- .parseMhcHaplotypeCalls(checkMhcHaplotypeFile(genotype))
  present <- calls[!calls$missing & calls$haplotype %in% wanted, ,
                   drop = FALSE]
  ## One row per (haplotype x animal); provisional iff the animal has no
  ## certain call of that haplotype. Keys use the ASCII unit separator,
  ## which cannot collide with printable label/id text.
  pairKey <- paste(present$haplotype, present$id, sep = "\037")
  firstOfPair <- !duplicated(pairKey)
  certainKeys <- unique(pairKey[!present$uncertain])
  carriers <- data.frame(
    haplotype = present$haplotype[firstOfPair],
    id = present$id[firstOfPair],
    uncertain = !(pairKey[firstOfPair] %in% certainKeys),
    stringsAsFactors = FALSE
  )
  carriers <- carriers[order(carriers$haplotype, carriers$id), ,
                       drop = FALSE]
  rownames(carriers) <- NULL
  carriers
}
