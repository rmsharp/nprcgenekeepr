## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Stop unless a rarity threshold is a single non-negative number
#'
#' Shared parameter validation for the issue #148 Slice 2 statistics
#' functions; the message names the offending parameter.
#' @noRd
.checkMhcRareThreshold <- function(value, name) {
  if (!is.numeric(value) || length(value) != 1L || is.na(value) ||
        value < 0.0) {
    stop(name, " must be a single non-negative number.")
  }
}

#' Summarize MHC haplotype frequencies and flag rare haplotypes
#'
#' Computes, from a wide per-animal MHC haplotype designation table (the
#' \code{\link{checkMhcHaplotypeFile}} format), a per-haplotype summary --
#' copy count, carrier count, uncertain-call count, frequency, and a rare
#' flag -- plus the file-level counts that make the frequencies
#' interpretable. Frequencies follow the HLA/NHP-MHC convention of a
#' chromosomes-among-genotyped denominator (Solberg et al. 2008; Doxiadis
#' et al. 2013): the number of \emph{certain} calls, i.e. 2 x animals
#' minus missing minus uncertain calls. Uncertain calls (a trailing
#' \code{?} on a designation) are excluded from copy counts, carrier
#' counts, and frequencies but always disclosed -- per haplotype in
#' \code{nUncertain} and file-wide in \code{counts} -- and a haplotype
#' observed \emph{only} as uncertain calls gets no summary row (it is
#' never counted as a distinct haplotype; it remains visible in the
#' file-level counts).
#'
#' @details
#' A haplotype is flagged rare when its frequency is at or below
#' \code{rareFrequencyThreshold} OR its carrier count is at or below
#' \code{rareCarrierThreshold} -- a dual criterion with direct precedent
#' in the combined frequency and observation-count bins of the CIWD 3.0
#' catalog (Hurley et al. 2020). Each leg is anchored: about 0.01 is the
#' published nonhuman-primate MHC "rare" usage (Kanthaswamy et al. 2026;
#' Doxiadis et al. 2013), and a haplotype carried by two or fewer animals
#' can be lost to two removals regardless of frequency, the
#' allele-retention framing of conservation management. At small colony
#' scale the carrier leg does the flagging (no observed haplotype can
#' have frequency at or below 0.01 when fewer than about 100 chromosomes
#' are genotyped), while at registry scale the frequency leg takes over.
#' Both defaults are working-filter settings, not scientific claims.
#'
#' A homozygous animal contributes two copies and one carrier. Carrier
#' counts include only animals with at least one \emph{certain} call of
#' the haplotype -- an animal whose only call of a haplotype is uncertain
#' is a provisional carrier, listed (and flagged) by
#' \code{\link{mhcHaplotypeCarriers}} but never counted here. Haplotype
#' designations are opaque labels throughout: never split, parsed, or
#' matched against MHC region names (see
#' \code{\link{checkMhcHaplotypeFile}}).
#'
#' @param genotype dataframe with wide-format MHC haplotype data as
#' validated by \code{\link{checkMhcHaplotypeFile}} (which this function
#' re-runs defensively): columns \code{id}, \code{haplotype1},
#' \code{haplotype2}, one row per animal.
#' @param rareFrequencyThreshold single non-negative number; a haplotype
#' with frequency at or below it is flagged rare. Default \code{0.01}.
#' @param rareCarrierThreshold single non-negative number; a haplotype
#' with that many or fewer carriers is flagged rare. Default \code{2L}.
#' @return A list with two elements. \code{summary}: a dataframe with one
#' row per distinct certain haplotype, ordered by haplotype label --
#' \code{haplotype} (character), \code{nCopies} (integer, certain calls),
#' \code{nCarriers} (integer, animals with at least one certain call),
#' \code{nUncertain} (integer, uncertain calls of this haplotype),
#' \code{frequency} (\code{nCopies / denominator}), and \code{isRare}
#' (logical, the dual criterion above). \code{counts}: a one-row
#' dataframe of file-level totals -- \code{nAnimals}, \code{nCalls},
#' \code{nMissing}, \code{nUncertain}, \code{denominator} (all integer).
#'
#' @references Kanthaswamy, S., et al. (2026). Next-generation short-read
#' sequencing reveals impacts on major histocompatibility complex
#' diversity resulting from differences in captive rhesus macaque
#' (\emph{Macaca mulatta}) colony expansion strategies. \emph{American
#' Journal of Primatology}, 88(1), e70108. \doi{10.1002/ajp.70108}
#' @references Hurley, C. K., et al. (2020). Common, intermediate and
#' well-documented HLA alleles in world populations: CIWD version 3.0.0.
#' \emph{HLA}, 95(6), 516-531. \doi{10.1111/tan.13811}
#' @references Solberg, O. D., Mack, S. J., Lancaster, A. K., Single,
#' R. M., Tsai, Y., Sanchez-Mazas, A., & Thomson, G. (2008). Balancing
#' selection and heterogeneity across the classical human leukocyte
#' antigen loci: A meta-analytic review of 497 population studies.
#' \emph{Human Immunology}, 69(7), 443-464.
#' \doi{10.1016/j.humimm.2008.05.001}
#' @references Doxiadis, G. G., et al. (2013). Haplotype diversity
#' generated by ancient recombination-like events in the MHC of Indian
#' rhesus macaques. \emph{Immunogenetics}, 65(8), 569-584.
#' \doi{10.1007/s00251-013-0707-8}
#'
#' @seealso \code{\link{mhcHaplotypeCarriers}},
#' \code{\link{checkMhcHaplotypeFile}}, \code{\link{rhesusGenotypes}}
#' @export
#' @examples
#' library(nprcgenekeepr)
#' result <- mhcHaplotypeFrequency(rhesusGenotypes)
#' head(result$summary)
#' result$counts
mhcHaplotypeFrequency <- function(genotype, rareFrequencyThreshold = 0.01,
                                  rareCarrierThreshold = 2L) {
  .checkMhcRareThreshold(rareFrequencyThreshold, "rareFrequencyThreshold")
  .checkMhcRareThreshold(rareCarrierThreshold, "rareCarrierThreshold")
  genotype <- checkMhcHaplotypeFile(genotype)
  calls <- .parseMhcHaplotypeCalls(genotype)
  certain <- calls[!calls$missing & !calls$uncertain, , drop = FALSE]
  uncertainCalls <- calls[calls$uncertain, , drop = FALSE]
  denominator <- nrow(certain)

  haplotypes <- sort(unique(certain$haplotype))
  nCopies <- vapply(haplotypes, function(h) {
    sum(certain$haplotype == h)
  }, integer(1L), USE.NAMES = FALSE)
  nCarriers <- vapply(haplotypes, function(h) {
    length(unique(certain$id[certain$haplotype == h]))
  }, integer(1L), USE.NAMES = FALSE)
  nUncertain <- vapply(haplotypes, function(h) {
    sum(uncertainCalls$haplotype == h)
  }, integer(1L), USE.NAMES = FALSE)
  frequency <- nCopies / denominator
  isRare <- frequency <= rareFrequencyThreshold |
    nCarriers <= rareCarrierThreshold

  list(
    summary = data.frame(
      haplotype = haplotypes,
      nCopies = nCopies,
      nCarriers = nCarriers,
      nUncertain = nUncertain,
      frequency = frequency,
      isRare = isRare,
      stringsAsFactors = FALSE
    ),
    counts = data.frame(
      nAnimals = nrow(genotype),
      nCalls = nrow(calls),
      nMissing = sum(calls$missing),
      nUncertain = sum(calls$uncertain),
      denominator = denominator,
      stringsAsFactors = FALSE
    )
  )
}
