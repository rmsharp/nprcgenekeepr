## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Check a long-format sequence-derived marker genotype file
#'
#' Validates the structure of a long-format marker genotype table (one row
#' per \code{id} x \code{locus}), the same schema
#' \code{\link{checkMarkerGenotypeFile}} checks -- but sized and hardened for
#' sequence-derived panels (issue #152): a soft, overridable warning above a
#' sparse/GBS-scale panel-size ceiling, and an explicit rejection of a
#' literal \code{"."} allele value (VCF's missing-genotype placeholder),
#' rather than silently counting it as a real allele. Optionally
#' cross-validates an accompanying locus-metadata sidecar by reusing
#' \code{\link{checkLocusMetadata}}, rather than reinventing that check.
#'
#' @details
#' All of \code{\link{checkMarkerGenotypeFile}}'s structural checks are
#' retained -- exactly four columns, \code{id} as the first column, no
#' duplicate \code{id} x \code{locus} rows, and the same biallelic-only
#' rejection the KING-robust kinship estimator (Manichaikul et al. 2010)
#' requires. Two rules are new: a literal \code{"."} allele value is rejected
#' before the biallelic count is even checked, so a curator sees the correct,
#' actionable error rather than a misleading "more than two alleles" report
#' (a genotype-preprocessing pipeline emitting VCF-style missingness that was
#' never converted to \code{NA} is a real, anticipated failure mode -- see
#' Danecek et al. 2011 for the VCF missing-genotype convention this guards
#' against); and a locus count above \code{maxLoci} produces a
#' \code{warning()}, not a \code{stop()} -- the "right" ceiling for this
#' package's own vectorized implementations is not yet empirically known, so
#' a hard stop would risk blocking legitimate data.
#'
#' @param genotype dataframe with long-format marker genotype data: exactly
#' four columns, \code{id}, \code{locus}, \code{allele1}, \code{allele2} (one
#' row per individual x locus).
#' @param locusMetadata optional dataframe with locus metadata (see
#' \code{\link{checkLocusMetadata}}): \code{locus}, \code{chrom}, \code{pos},
#' and optionally \code{cM}, one row per locus. When supplied, is validated
#' via \code{\link{checkLocusMetadata}} -- its own violations propagate
#' unchanged. Defaults to \code{NULL} (no sidecar to validate).
#' @param maxLoci numeric scope-tier ceiling (default \code{50000L}, this
#' package's own sparse/GBS-scale target ceiling) above which a locus count
#' triggers a \code{warning()} rather than a \code{stop()}.
#' @return The genotype dataframe, checked to ensure the column count,
#' first-column identity, per-locus allele count, absence of a literal
#' \code{"."} placeholder, and row uniqueness are all valid. The returned
#' dataframe has its column names forced to \code{c("id", "locus", "allele1",
#' "allele2")}.
#'
#' @references Manichaikul, A., Mychaleckyj, J. C., Rich, S. S., Daly, K.,
#' Sale, M., & Chen, W.-M. (2010). Robust relationship inference in
#' genome-wide association studies. \emph{Bioinformatics}, 26(22), 2867-2873.
#' \doi{10.1093/bioinformatics/btq559}
#' @references Danecek, P., et al. (2011). The variant call format and
#' VCFtools. \emph{Bioinformatics}, 27(15), 2156-2158.
#' \doi{10.1093/bioinformatics/btr330}
#'
#' @seealso \code{\link{checkMarkerGenotypeFile}},
#' \code{\link{checkLinkageMarkerGenotypeFile}},
#' \code{\link{checkLocusMetadata}}, \code{\link{buildMarkerGenotypeMatrix}}
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
#' checkSequenceGenotypeFile(markerGenotype)
checkSequenceGenotypeFile <- function(genotype, locusMetadata = NULL,
                                       maxLoci = 50000L) {
  cols <- names(genotype)
  if (length(cols) != 4L) {
    stop("Marker genotype file must have exactly four columns: id, locus, ",
         "allele1, allele2.")
  }
  if (!grepl("id", cols[1L], ignore.case = TRUE)) {
    stop("Marker genotype file must have 'id' as the first column.")
  }
  names(genotype) <- c("id", "locus", "allele1", "allele2")

  isDupe <- duplicated(genotype[c("id", "locus")])
  if (any(isDupe)) {
    dupes <- unique(paste(genotype$id[isDupe], genotype$locus[isDupe],
                           sep = " x "))
    stop("Marker genotype file has duplicate id x locus row(s): ",
         toString(dupes), ".")
  }

  ## A literal "." (the VCF missing-genotype placeholder, Danecek et al.
  ## 2011) reaching this validator is an upstream-preprocessing contract
  ## violation -- surface it loudly, before the biallelic-count check below
  ## can mistake it for a real 3rd allele.
  isDotAllele <- genotype$allele1 == "." | genotype$allele2 == "."
  isDotAllele[is.na(isDotAllele)] <- FALSE
  if (any(isDotAllele)) {
    offending <- unique(paste(genotype$id[isDotAllele],
                               genotype$locus[isDotAllele], sep = " x "))
    stop("Marker genotype file uses a literal '.' as an allele value (the ",
         "VCF missing-genotype placeholder) at id x locus row(s): ",
         toString(offending), ". Convert missing genotypes to NA before ",
         "uploading.")
  }

  alleleCounts <- tapply(
    c(genotype$allele1, genotype$allele2),
    rep(genotype$locus, 2L),
    function(a) length(unique(a[!is.na(a)]))
  )
  offendingLoci <- names(alleleCounts)[alleleCounts > 2L]
  if (length(offendingLoci) > 0L) {
    stop("Marker genotype file has one or more loci with more than two ",
         "distinct alleles (the KING-robust estimator requires biallelic ",
         "markers): ", toString(offendingLoci), ".")
  }

  nLoci <- length(unique(genotype$locus))
  if (nLoci > maxLoci) {
    warning("Marker genotype file has ", nLoci, " loci, above the ",
            "recommended panel-size ceiling of ", maxLoci, " (see issue ",
            "#152's design doc D1) -- performance at this scale is not ",
            "yet validated.")
  }

  if (!is.null(locusMetadata)) {
    checkLocusMetadata(locusMetadata)
  }

  genotype
}
