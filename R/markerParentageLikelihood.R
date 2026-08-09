## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Rank candidate replacement parents by a multilocus likelihood (LOD) score
#'
#' For each recorded parent \code{\link{markerParentageExclusion}} flags as
#' Mendelian-inconsistent with its offspring's marker genotype, ranks
#' candidate replacement parents using a CERVUS-style multilocus
#' likelihood-ratio (LOD) score -- the field's own answer to exactly this
#' problem shape (Meagher & Thompson 1986; operationalized by Marshall,
#' Slate, Kruuk & Pemberton 1998), independently validated as the captive
#' -primate-colony domain's de facto standard by de Groot et al. (2025), a
#' real captive macaque colony precedent already cited by
#' \code{\link{markerParentageExclusion}}. This is a report-only diagnostic:
#' it never writes to \code{pedigree$sire}/\code{pedigree$dam} -- "requires
#' curator review rather than silently rewriting a pedigree," per the
#' issue's own words. \code{markerParentageExclusion()} itself is untouched
#' and remains the independent Mendelian-exclusion check.
#'
#' @details
#' \strong{Formula.} For each jointly-genotyped locus, the per-locus
#' likelihood ratio compares H1 (the candidate is the true parent) against
#' H2 (the candidate is an unrelated individual, drawn at random from the
#' colony-wide reference population) using ordinary Mendelian transmission
#' probabilities and Hardy-Weinberg population genotype frequencies (well
#' -defined because \code{\link{checkMarkerGenotypeFile}} guarantees exactly
#' two alleles per locus). When the offspring's other recorded parent is
#' genotyped and not itself Mendelian-excluded (its own opposite-homozygote
#' count against the offspring does not exceed \code{maxExclusions}), it is
#' incorporated as a known second parent at that locus (a trio likelihood,
#' matching Marshall et al. 1998's own formula, which conditions on a known
#' mother when scoring candidate fathers); otherwise that locus falls back
#' to a candidate-only (dyad) likelihood using the population allele
#' frequency in place of the unknown second parent. \code{LOD} is the sum of
#' per-locus log-likelihood ratios across all jointly-genotyped loci between
#' the offspring and the candidate.
#'
#' \strong{Reference-population allele frequencies are colony-wide}, computed
#' from every non-missing genotype call at that locus in \code{genotypeMatrix}
#' (the same "whatever subset is passed in" convention
#' \code{\link{markerExpectedHeterozygosity}} already uses) -- matching the
#' direct captive-colony precedent of de Groot et al. (2025), who used
#' colony-wide frequencies rather than an external reference population.
#' Structured/inbred captive pedigrees can violate the underlying
#' Hardy-Weinberg assumption, biasing the H2 null; this is a documented
#' limitation, not corrected here.
#'
#' \strong{No simulation-calibrated percentage confidence is reported.} CERVUS
#' -style confidence statistics require ~100,000-simulation Monte Carlo
#' calibration per parameter set -- a materially larger, separable
#' engineering investment. Instead, \code{delta} (the LOD gap to the next
#' -ranked candidate within the same offspring/role group) and
#' \code{nLociUsed} are reported alongside the raw \code{LOD}, explicitly
#' uncalibrated. \strong{A single Mendelian-incompatible (opposite-homozygote)
#' locus drives \code{LOD} to exactly \code{-Inf}} -- a true probability-zero
#' Mendelian impossibility under this no-genotyping-error formula -- which
#' can happen even when \code{excluded} is \code{FALSE} (i.e. the candidate's
#' own opposite-homozygote count is at or below \code{maxExclusions}, the
#' tolerance threshold \code{\link{markerParentageExclusion}} itself uses for
#' ordinary genotyping error): \code{LOD} has no equivalent error tolerance
#' in this formula. A genotyping-error-tolerant extension (Kalinowski, Taper
#' & Marshall 2007) is deliberately deferred, pending independent
#' re-verification of that paper's own eqns 1-2 against its primary source
#' (this session's Pre-RED found a spotted internal inconsistency in that
#' paper's own Appendix, and its 2010 corrigendum was unretrievable).
#'
#' \strong{Small marker panels (2-10 loci) are underpowered.} At this
#' package's realistic panel sizes, LOD-based assignment sits inside the
#' literature's own documented underpowered zone, and a full/half sibling of
#' the true parent can plausibly outrank it. \code{minLoci} is a fixed,
#' literature-informed, user-overridable heuristic (mirroring
#' \code{\link{markerParentageExclusion}}'s own \code{maxExclusions}
#' precedent, not a mathematically-derived cutoff): candidates scored on
#' fewer than \code{minLoci} jointly-genotyped loci are flagged
#' \code{lowPower = TRUE} rather than silently ranked as if fully powered.
#'
#' \strong{Ties} at small panel sizes are surfaced explicitly -- every tied
#' candidate appears as its own row, never silently deduplicated or dropped.
#' Two candidates exactly tied (including two \code{-Inf} values, a real,
#' hand-verified case) report \code{delta = 0} between them, not \code{NaN}.
#'
#' \strong{A candidate/offspring pair sharing zero genotyped loci} is
#' reported, not silently dropped: \code{nLociUsed = 0L},
#' \code{LOD = NA_real_}, \code{lowPower = TRUE}, \code{excluded = NA}
#' (undefined, mirroring \code{\link{markerParentageExclusion}}'s own
#' convention for the same zero-shared-evidence case), with a warning naming
#' the pair.
#'
#' @param genotypeMatrix a character matrix as returned by
#' \code{\link{buildMarkerGenotypeMatrix}}: rows are individual \code{id}s,
#' columns are loci, and each cell is that individual's two alleles at that
#' locus, sorted and joined by \code{"/"} (or \code{NA} if not genotyped at
#' that locus).
#' @param pedigree a data frame with (at least) columns \code{id},
#' \code{sire}, and \code{dam} -- the standard pedigree shape used
#' throughout this package.
#' @param id optional single offspring id to score. When \code{NULL}
#' (together with \code{role}, the default), every (offspring, role) pair
#' \code{\link{markerParentageExclusion}} flags is auto-detected and scored.
#' @param role optional, one of \code{"sire"}/\code{"dam"} -- the recorded
#' -parent slot to score candidates for. Required together with \code{id}
#' when scoring a single slot on demand (e.g. a curator's proactive check on
#' an animal that is not (yet) flagged).
#' @param candidates optional character vector of candidate ids, used only
#' together with an explicit \code{id}/\code{role}. When \code{NULL} (the
#' default), candidates come from \code{\link{getPotentialParents}}'s own
#' \code{sires}/\code{dams} list for that \code{id} (auto-detection always
#' uses this default -- \code{candidates} has no effect in auto-detect mode).
#' @param minLoci integer; candidates scored on fewer than this many jointly
#' -genotyped loci are flagged \code{lowPower = TRUE}. Default \code{4L}.
#' @param maxExclusions integer; passed through to
#' \code{\link{markerParentageExclusion}} for auto-detection, and used
#' identically here for each candidate's own \code{excluded} diagnostic and
#' for deciding whether a genotyped other-parent qualifies for trio
#' conditioning. Default \code{2L}.
#' @return A data frame, one row per (offspring \code{id}, \code{role},
#' \code{candidateId}), ranked by \code{LOD} descending within each
#' (\code{id}, \code{role}) group: \code{id}, \code{role}, \code{candidateId},
#' \code{LOD}, \code{delta} (gap to the next-ranked candidate in the group;
#' \code{NA} for the lowest-ranked row), \code{nLociUsed}, \code{excluded}
#' (the same opposite-homozygote diagnostic
#' \code{\link{markerParentageExclusion}} uses, parameterized against this
#' candidate -- never overloading that function's own \code{flagged}
#' column), \code{lowPower}. A zero-row data
#' frame (full column shape) is returned when no pair is checkable. This
#' function never modifies \code{pedigree}.
#'
#' @references Meagher, T. R., & Thompson, E. (1986). The relationship
#' between single parent and parent pair genetic likelihoods in genealogy
#' reconstruction. \emph{Theoretical Population Biology}, 29(1), 87-106.
#' \doi{10.1016/0040-5809(86)90007-1}
#'
#' Marshall, T. C., Slate, J., Kruuk, L. E. B., & Pemberton, J. M. (1998).
#' Statistical confidence for likelihood-based paternity inference in
#' natural populations. \emph{Molecular Ecology}, 7(5), 639-655.
#' \doi{10.1046/j.1365-294x.1998.00374.x}
#'
#' Kalinowski, S. T., Taper, M. L., & Marshall, T. C. (2007). Revising how
#' the computer program CERVUS accommodates genotyping error increases
#' success in paternity assignment. \emph{Molecular Ecology}, 16(5),
#' 1099-1106. \doi{10.1111/j.1365-294X.2007.03089.x}
#'
#' @seealso \code{\link{markerParentageExclusion}},
#' \code{\link{getPotentialParents}}, \code{\link{buildMarkerGenotypeMatrix}}
#' @export
#' @examples
#' library(nprcgenekeepr)
#' markerGenotype <- data.frame(
#'   id = c("O", "O", "D", "D", "C1", "C1", "C2", "C2"),
#'   locus = c("L1", "L2", "L1", "L2", "L1", "L2", "L1", "L2"),
#'   allele1 = c("A", "A", "A", "A", "A", "A", "B", "B"),
#'   allele2 = c("A", "B", "B", "A", "A", "B", "B", "B"),
#'   stringsAsFactors = FALSE
#' )
#' genotypeMatrix <- buildMarkerGenotypeMatrix(markerGenotype)
#' pedigree <- data.frame(id = "O", sire = "C2", dam = "D",
#'                         stringsAsFactors = FALSE)
#' markerParentageLikelihood(genotypeMatrix, pedigree, id = "O", role = "sire",
#'                            candidates = c("C1", "C2"), minLoci = 1L)
markerParentageLikelihood <- function(genotypeMatrix, pedigree, id = NULL,
                                       role = NULL, candidates = NULL,
                                       minLoci = 4L, maxExclusions = 2L) {
  if (!all(c("id", "sire", "dam") %in% names(pedigree))) {
    stop("markerParentageLikelihood: pedigree must have id, sire, and dam ",
         "columns.")
  }
  if (xor(is.null(id), is.null(role))) {
    stop("markerParentageLikelihood: id and role must both be supplied, or ",
         "both be NULL for auto-detection.")
  }

  emptyResult <- function() {
    data.frame(id = character(0L), role = character(0L),
               candidateId = character(0L), LOD = numeric(0L),
               delta = numeric(0L), nLociUsed = integer(0L),
               excluded = logical(0L), lowPower = logical(0L),
               stringsAsFactors = FALSE)
  }

  lookupCandidates <- function(ppList, targetId, targetRole) {
    if (is.null(ppList)) {
      return(character(0L))
    }
    for (entry in ppList) {
      if (identical(entry$id, targetId)) {
        return(if (targetRole == "sire") entry$sires else entry$dams)
      }
    }
    character(0L)
  }

  scoreOnePair <- function(focalId, focalRole, candidateIds) {
    candidateIds <- candidateIds[candidateIds %in% rownames(genotypeMatrix)]
    if (length(candidateIds) == 0L) {
      return(emptyResult())
    }

    genoOffspring <- genotypeMatrix[focalId, ]

    otherRole <- setdiff(c("sire", "dam"), focalRole)
    pedRow <- pedigree[pedigree$id == focalId, , drop = FALSE]
    otherParent <- if (nrow(pedRow) == 1L) {
      pedRow[[otherRole]][1L]
    } else {
      NA_character_
    }
    trioEligible <- !is.na(otherParent) &&
      (otherParent %in% rownames(genotypeMatrix))
    if (trioEligible) {
      genoOther <- genotypeMatrix[otherParent, ]
      otherCounts <- .markerOppositeHomozygoteCount(genoOffspring, genoOther)
      if (!is.na(otherCounts$exclusionCount) &&
            otherCounts$exclusionCount > maxExclusions) {
        trioEligible <- FALSE
      }
    }

    tOf <- function(genoStr, refAllele) {
      alleles <- strsplit(genoStr, "/", fixed = TRUE)[[1L]]
      mean(alleles == refAllele)
    }
    pTwoGeno <- function(t1, t2, genoStr, refAllele) {
      alleles <- strsplit(genoStr, "/", fixed = TRUE)[[1L]]
      nRef <- sum(alleles == refAllele)
      if (nRef == 2L) {
        t1 * t2
      } else if (nRef == 1L) {
        t1 * (1.0 - t2) + (1.0 - t1) * t2
      } else {
        (1.0 - t1) * (1.0 - t2)
      }
    }

    rows <- vector("list", length(candidateIds))
    for (j in seq_along(candidateIds)) {
      candId <- candidateIds[j]
      genoCandidate <- genotypeMatrix[candId, ]
      counts <- .markerOppositeHomozygoteCount(genoOffspring, genoCandidate)
      exclusionCount <- counts$exclusionCount
      nLociUsed <- counts$nLoci

      if (nLociUsed == 0L) {
        warning("markerParentageLikelihood: '", focalId, "' and '", candId,
                "' share no shared genotyped loci; LOD is undefined for ",
                "this candidate (returning NA).")
        LOD <- NA_real_
        excluded <- NA
      } else {
        used <- !is.na(genoOffspring) & !is.na(genoCandidate)
        loci <- names(genoOffspring)[used]
        logterms <- vapply(loci, function(loc) {
          freqTable <- .markerAlleleFrequencyTable(genotypeMatrix, loc)
          refAllele <- sort(names(freqTable))[1L]
          p <- unname(freqTable[[refAllele]])
          t1 <- tOf(genoCandidate[[loc]], refAllele)
          t2 <- if (trioEligible && !is.na(genoOther[[loc]])) {
            tOf(genoOther[[loc]], refAllele)
          } else {
            p
          }
          h1 <- pTwoGeno(t1, t2, genoOffspring[[loc]], refAllele)
          h2 <- pTwoGeno(p, t2, genoOffspring[[loc]], refAllele)
          log(h1) - log(h2)
        }, numeric(1L))
        LOD <- sum(logterms)
        excluded <- exclusionCount > maxExclusions
      }

      rows[[j]] <- data.frame(
        id = focalId, role = focalRole, candidateId = candId, LOD = LOD,
        nLociUsed = nLociUsed, excluded = excluded,
        lowPower = nLociUsed < minLoci, stringsAsFactors = FALSE
      )
    }
    result <- do.call(rbind, rows)

    ord <- order(-result$LOD, na.last = TRUE)
    result <- result[ord, , drop = FALSE]
    n <- nrow(result)
    delta <- rep(NA_real_, n)
    if (n > 1L) {
      diffs <- result$LOD[seq_len(n - 1L)] - result$LOD[2L:n]
      diffs[is.nan(diffs)] <- 0.0
      delta[seq_len(n - 1L)] <- diffs
    }
    result$delta <- delta
    result[c("id", "role", "candidateId", "LOD", "delta", "nLociUsed",
             "excluded", "lowPower")]
  }

  if (is.null(id)) {
    flags <- markerParentageExclusion(genotypeMatrix, pedigree, maxExclusions)
    flags <- flags[!is.na(flags$flagged) & flags$flagged, , drop = FALSE]
    if (nrow(flags) == 0L) {
      return(emptyResult())
    }
    ppList <- getPotentialParents(pedigree)
    rows <- vector("list", nrow(flags))
    for (i in seq_len(nrow(flags))) {
      fid <- flags$id[i]
      frole <- flags$role[i]
      cand <- lookupCandidates(ppList, fid, frole)
      rows[[i]] <- scoreOnePair(fid, frole, cand)
    }
    result <- do.call(rbind, rows)
  } else {
    candidateIds <- if (!is.null(candidates)) {
      candidates
    } else {
      lookupCandidates(getPotentialParents(pedigree), id, role)
    }
    result <- scoreOnePair(id, role, candidateIds)
  }

  if (is.null(result) || nrow(result) == 0L) {
    return(emptyResult())
  }
  rownames(result) <- NULL
  result
}
