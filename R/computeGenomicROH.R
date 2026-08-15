## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Compute genomic Runs of Homozygosity (ROH) and F_ROH
#'
#' Computes per-individual genomic Runs of Homozygosity (ROH) segments and
#' the genomic inbreeding coefficient F_ROH from a sequence-scale marker
#' genotype matrix (issue #152 Slice 3, design decision D6) -- a
#' sequence-verified inbreeding estimate independent of (often incomplete)
#' pedigree records, complementing rather than duplicating this package's
#' existing pedigree-based kinship/founder metrics.
#'
#' @details
#' Within each chromosome, loci are ordered by \code{pos}. A "run" is a
#' maximal, gapless stretch of homozygous, non-missing genotyped loci --
#' both a heterozygous call and a missing (\code{NA}) call end the current
#' run. A run qualifies as an ROH segment only if it has at least
#' \code{minSnp} loci AND spans at least \code{minBp} base pairs (the
#' field-standard dual threshold, matching PLINK's \code{--homozyg-snp}/
#' \code{--homozyg-kb}, Purcell et al. 2007) -- either condition alone is
#' not sufficient. \code{totalRohLength} sums the qualifying segments'
#' spans across all chromosomes; \code{fRoh} divides that sum by
#' \code{genomeLength}, a single value shared across every individual: the
#' sum, per chromosome, of \code{(max(pos) - min(pos))} among the
#' full-coverage loci in \code{locusMetadata} (Ceballos et al. 2018's
#' \eqn{L_{autosome}} convention). A fixed, shared denominator keeps
#' \code{fRoh} comparable across a cohort and avoids conflating an
#' individual's own missingness with inbreeding.
#'
#' Only loci with full \code{locusMetadata} coverage (both \code{chrom} and
#' \code{pos} present, per \code{\link{checkLocusMetadata}}'s own
#' three-tier classification) can be placed in the ordered walk; a locus
#' lacking full coverage, or entirely absent from \code{locusMetadata}, is
#' excluded from both the walk and the \code{genomeLength} denominator, with
#' a warning naming it -- it is never treated as a run-breaking gap. When
#' every chromosome has at most one full-coverage locus, \code{genomeLength}
#' is 0 and \code{fRoh} is an undefined \code{0/0} ratio: \code{NA} with a
#' warning, not \code{NaN} silently, mirroring \code{\link{markerFst}}'s own
#' undefined-ratio precedent.
#'
#' @param genotypeMatrix a character matrix as returned by
#' \code{\link{buildMarkerGenotypeMatrix}}: rows are individual \code{id}s,
#' columns are loci, and each cell is that individual's two alleles at that
#' locus, sorted and joined by \code{"/"} (e.g. \code{"A/B"}), or \code{NA}
#' if not genotyped at that locus.
#' @param locusMetadata dataframe with locus metadata (see
#' \code{\link{checkLocusMetadata}}): \code{locus}, \code{chrom}, \code{pos},
#' and optionally \code{cM}, one row per locus. Required -- absent or
#' \code{NULL} triggers an early \code{stop()} rather than a silent
#' \code{NA}.
#' @param minSnp integer minimum number of consecutive homozygous loci
#' required for a run to qualify as an ROH segment. Default \code{50L},
#' scaled down from PLINK's own literal default (\code{100}) for this
#' package's sparser sparse/GBS-scale target tier (design doc D1).
#' @param minBp numeric minimum base-pair span (last locus \code{pos} minus
#' first locus \code{pos}) required for a run to qualify as an ROH segment.
#' Default \code{1e6} (1 Mb), matching PLINK's own \code{--homozyg-kb}
#' default and Ceballos et al. (2018)'s commonly-cited ROH-calling
#' threshold.
#' @return A per-individual dataframe: \code{id}, \code{nSegments} (count of
#' qualifying ROH segments), \code{totalRohLength} (their summed bp span),
#' and \code{fRoh} (the genomic inbreeding coefficient, or \code{NA} if
#' \code{genomeLength} is 0).
#'
#' @references Ceballos, F. C., Joshi, P. K., Clark, D. W., Ramsay, M., &
#' Wilson, J. F. (2018). Runs of homozygosity: windows into population
#' history and trait architecture. \emph{Nature Reviews Genetics}, 19(4),
#' 220-234. \doi{10.1038/nrg.2017.109}
#' @references Purcell, S., et al. (2007). PLINK: a tool set for
#' whole-genome association and population-based linkage analyses.
#' \emph{American Journal of Human Genetics}, 81(3), 559-575.
#' \doi{10.1086/519795}
#'
#' @seealso \code{\link{buildMarkerGenotypeMatrix}},
#' \code{\link{checkLocusMetadata}}, \code{\link{checkSequenceGenotypeFile}}
#' @export
#' @examples
#' library(nprcgenekeepr)
#' locusMetadata <- data.frame(
#'   locus = c("L1", "L2", "L3", "L4"),
#'   chrom = c("1", "1", "1", "1"),
#'   pos = c(0, 400000, 900000, 1400000),
#'   stringsAsFactors = FALSE
#' )
#' genotypeMatrix <- matrix(
#'   c("A/A", "A/A", "A/B", "A/A"),
#'   nrow = 1L, dimnames = list("Animal1", locusMetadata$locus)
#' )
#' computeGenomicROH(genotypeMatrix, locusMetadata, minSnp = 2L, minBp = 300000)
computeGenomicROH <- function(genotypeMatrix, locusMetadata,
                               minSnp = 50L, minBp = 1000000.0) {
  if (missing(locusMetadata) || is.null(locusMetadata)) {
    stop("computeGenomicROH() requires a locusMetadata sidecar (locus, ",
         "chrom, pos) -- absent or NULL is not supported.")
  }

  locusMetadata <- checkLocusMetadata(locusMetadata)

  isFull <- locusMetadata$coverage == "full"
  fullLoci <- locusMetadata$locus[isFull]
  droppedLoci <- setdiff(colnames(genotypeMatrix), fullLoci)
  if (length(droppedLoci) > 0L) {
    warning("computeGenomicROH: locus/loci excluded from ROH analysis (no ",
            "full chrom + pos coverage): ", toString(droppedLoci), ".")
  }

  ## Restrict to full-coverage loci actually present in genotypeMatrix,
  ## ordered by chrom then pos within chrom -- genomic order defines a
  ## "run," unlike buildMarkerGenotypeMatrix()'s first-appearance order.
  fullMeta <- locusMetadata[isFull & locusMetadata$locus %in%
                               colnames(genotypeMatrix), , drop = FALSE]
  # NOT the Learning 585 locale-dependent order() defect class: chrom (a
  # character column) IS a locale-sensitive primary sort key here, so
  # fullMeta's own row order does vary by locale -- but the function's
  # RETURNED value does not. chromGroups (below) is built via split(), which
  # groups by chrom value regardless of inter-group order, and WITHIN one
  # chrom's rows the relative order is decided entirely by the numeric `pos`
  # secondary key (locale-independent; equal-string ties don't invoke
  # collation). Confirmed live (withr::with_locale, LC_COLLATE "C" vs.
  # "en_US.UTF-8") that computeGenomicROH()'s output is byte-identical
  # across locales despite fullMeta's own intermediate row order differing
  # (BACKLOG, found S578, investigated S581) -- no method = "radix" needed.
  fullMeta <- fullMeta[order(fullMeta$chrom, fullMeta$pos), , drop = FALSE]

  ## genomeLength: sum, per chromosome, of (max pos - min pos) among the
  ## full-coverage loci -- ONE value, shared by every individual (Ceballos
  ## et al. 2018's L_autosome convention), not recomputed per individual.
  chromSpans <- tapply(fullMeta$pos, fullMeta$chrom,
                        function(p) max(p) - min(p))
  genomeLength <- sum(chromSpans)
  if (genomeLength == 0.0) {
    warning("computeGenomicROH: total genome length covered by full-",
            "coverage loci is 0 (every chromosome has at most one such ",
            "locus) -- fRoh is undefined (returning NA).")
  }

  chromGroups <- split(fullMeta$locus, fullMeta$chrom)
  ids <- rownames(genotypeMatrix)
  nSegments <- stats::setNames(integer(length(ids)), ids)
  totalRohLength <- stats::setNames(numeric(length(ids)), ids)

  for (id in ids) {
    idSegments <- 0L
    idLength <- 0.0
    for (loci in chromGroups) {
      ## `loci` is already pos-ordered within this chromosome (order()
      ## above, preserved by split()).
      calls <- genotypeMatrix[id, loci]
      pos <- fullMeta$pos[match(loci, fullMeta$locus)]

      alleles <- strsplit(calls, "/", fixed = TRUE)
      isHom <- vapply(alleles, function(a) {
        !anyNA(a) && length(a) == 2L && a[1L] == a[2L]
      }, logical(1L))

      runs <- rle(isHom)
      endIdx <- cumsum(runs$lengths)
      startIdx <- endIdx - runs$lengths + 1L
      for (r in seq_along(runs$lengths)) {
        if (!runs$values[r] || runs$lengths[r] < minSnp) next
        span <- pos[endIdx[r]] - pos[startIdx[r]]
        if (span < minBp) next
        idSegments <- idSegments + 1L
        idLength <- idLength + span
      }
    }
    nSegments[[id]] <- idSegments
    totalRohLength[[id]] <- idLength
  }

  fRoh <- if (genomeLength == 0.0) {
    stats::setNames(rep(NA_real_, length(ids)), ids)
  } else {
    totalRohLength / genomeLength
  }

  data.frame(
    id = ids,
    nSegments = unname(nSegments[ids]),
    totalRohLength = unname(totalRohLength[ids]),
    fRoh = unname(fRoh[ids]),
    stringsAsFactors = FALSE,
    row.names = NULL
  )
}
