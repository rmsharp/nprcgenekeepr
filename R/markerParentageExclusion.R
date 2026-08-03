## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Flag Mendelian-inconsistent recorded parents from marker genotypes
#'
#' For each animal in \code{pedigree} with a recorded dam and/or sire that is
#' also genotyped, compares the animal's marker genotype to that recorded
#' parent's, locus by locus, and counts loci at which no shared allele is
#' possible under simple Mendelian inheritance ("opposite homozygotes" --
#' the animal and the candidate parent are each homozygous for a
#' \emph{different} allele). Aggregates to a per-pair exclusion count and a
#' \code{flagged} decision, directly targeting the issue's named ~5%
#' dam-misidentification problem: a recorded parent whose genotype evidence
#' contradicts the pedigree.
#'
#' @details
#' A locus contributes to the exclusion count only when both the animal and
#' the candidate parent are genotyped there \emph{and} both are homozygous
#' for different alleles -- the same "informative conflict" definition
#' verified against the ICAR/ISAG cattle-SNP parentage-verification standard
#' at this function's Pre-RED (a heterozygous genotype at either individual
#' is never, by itself, Mendelian-inconsistent with a biallelic parent
#' genotype). Loci where either individual is not genotyped are excluded
#' from both the numerator and the denominator.
#'
#' \code{maxExclusions} is the maximum number of Mendelian-inconsistent loci
#' \emph{tolerated} before a recorded parent is flagged as excluded (i.e.
#' flagging requires \code{exclusionCount > maxExclusions}) -- a single
#' mismatching locus is not, by itself, evidence the recorded parent is
#' wrong, since ordinary genotyping error or mutation can produce an
#' isolated conflict even for a true parent-offspring pair. The default of
#' \code{2} (flag only at 3 or more inconsistent loci) is grounded in
#' Cifuentes et al. (2006) and the real captive-macaque-colony parentage
#' precedent of de Groot et al. (2025), both cited below -- it is a raw
#' locus count calibrated to small/moderate marker panels and typical
#' genotyping error rates reported in that literature; it does not scale
#' with the number of loci actually typed or with this package's
#' (currently unmeasured) per-locus genotyping-error rate, so panels much
#' larger or noisier than that should retune \code{maxExclusions} rather
#' than rely on the shipped default.
#'
#' When an animal and its recorded parent share zero jointly-genotyped loci,
#' the exclusion count is undefined; that pair's \code{exclusionCount} and
#' \code{flagged} are \code{NA} and a warning names the pair (mirroring
#' \code{\link{markerKinship}}'s precedent for the same kind of
#' no-shared-evidence case). A recorded parent that is \code{NA} (unknown)
#' or that has no row in \code{genotypeMatrix} (never genotyped) is silently
#' skipped -- no row is emitted for that pair, since there is no genotype
#' evidence to check.
#'
#' @param genotypeMatrix a character matrix as returned by
#' \code{\link{buildMarkerGenotypeMatrix}}: rows are individual \code{id}s,
#' columns are loci, and each cell is that individual's two alleles at that
#' locus, sorted and joined by \code{"/"} (or \code{NA} if not genotyped at
#' that locus).
#' @param pedigree a data frame with (at least) columns \code{id},
#' \code{sire}, and \code{dam} -- the standard pedigree shape used
#' throughout this package. \code{sire}/\code{dam} may be \code{NA} for an
#' unrecorded parent.
#' @param maxExclusions integer; the maximum number of Mendelian-
#' inconsistent loci tolerated before a recorded parent is flagged as
#' excluded. Default \code{2L} (flag only at 3 or more).
#' @return A data frame, one row per (offspring, recorded-parent) pair for
#' which both individuals are genotyped, with columns \code{id} (the
#' offspring), \code{parentId}, \code{role} (\code{"dam"} or \code{"sire"}),
#' \code{exclusionCount}, \code{nLoci} (the number of jointly-genotyped loci
#' the count is based on), and \code{flagged} (the canonical boolean
#' vocabulary, matching \code{reportGV()}'s \code{flagged} column). A pair
#' with an unrecorded or ungenotyped parent has no row at all. A data frame
#' with zero rows (but the full column shape) is returned when no pair is
#' checkable.
#'
#' @references Cifuentes, L. O., Martinez, E. H., Acuna, M. P., & Jonquera,
#' H. G. (2006). Probability of exclusion in paternity testing: time to
#' reassess. \emph{Journal of Forensic Sciences}, 51(2), 349-350.
#' \doi{10.1111/j.1556-4029.2006.00046.x}
#'
#' de Groot, N. G., de Vos-Rouweler, A. J. M., Heijmans, C. M. C., et al.
#' (2025). Genetic Conservation and Population Management of Non-Human
#' Primates: Parentage Determination Using Seven Microsatellite-Based
#' Multiplexes. \emph{Ecology and Evolution}, 15(4), e71216.
#' \doi{10.1002/ece3.71216}
#'
#' @seealso \code{\link{checkMarkerGenotypeFile}},
#' \code{\link{buildMarkerGenotypeMatrix}}, \code{\link{markerKinship}}
#' @export
#' @examples
#' library(nprcgenekeepr)
#' markerGenotype <- data.frame(
#'   id = c("A", "A", "B", "B"),
#'   locus = c("L1", "L2", "L1", "L2"),
#'   allele1 = c("A", "A", "A", "A"),
#'   allele2 = c("A", "B", "B", "B"),
#'   stringsAsFactors = FALSE
#' )
#' genotypeMatrix <- buildMarkerGenotypeMatrix(markerGenotype)
#' pedigree <- data.frame(id = "B", sire = NA_character_, dam = "A",
#'                         stringsAsFactors = FALSE)
#' markerParentageExclusion(genotypeMatrix, pedigree)
markerParentageExclusion <- function(genotypeMatrix, pedigree,
                                      maxExclusions = 2L) {
  emptyResult <- function() {
    data.frame(id = character(0L), parentId = character(0L),
               role = character(0L), exclusionCount = integer(0L),
               nLoci = integer(0L), flagged = logical(0L),
               stringsAsFactors = FALSE)
  }

  isHet <- function(genoRow) {
    vapply(strsplit(genoRow, "/", fixed = TRUE), function(a) {
      if (length(a) != 2L) NA else a[1L] != a[2L]
    }, logical(1L))
  }

  rows <- list()
  for (i in seq_len(nrow(pedigree))) {
    id <- pedigree$id[i]
    if (!(id %in% rownames(genotypeMatrix))) {
      next
    }
    genoOffspring <- genotypeMatrix[id, ]
    hetOffspring <- isHet(genoOffspring)

    for (role in c("dam", "sire")) {
      parent <- pedigree[[role]][i]
      if (is.na(parent) || !(parent %in% rownames(genotypeMatrix))) {
        next
      }

      genoParent <- genotypeMatrix[parent, ]
      hetParent <- isHet(genoParent)

      shared <- !is.na(genoOffspring) & !is.na(genoParent)
      nLoci <- sum(shared)

      if (nLoci == 0L) {
        warning("markerParentageExclusion: '", id, "' and '", parent,
                "' (", role, ") share no shared genotyped loci; exclusion ",
                "count is undefined for this pair (returning NA).")
        exclusionCount <- NA_integer_
        flagged <- NA
      } else {
        exclusionCount <- sum(!hetOffspring[shared] & !hetParent[shared] &
                                 genoOffspring[shared] != genoParent[shared])
        flagged <- exclusionCount > maxExclusions
      }

      rows[[length(rows) + 1L]] <- data.frame(
        id = id, parentId = parent, role = role,
        exclusionCount = exclusionCount, nLoci = nLoci, flagged = flagged,
        stringsAsFactors = FALSE
      )
    }
  }

  if (length(rows) == 0L) {
    return(emptyResult())
  }
  do.call(rbind, rows)
}
