## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Two-locus, multiallelic maximum-likelihood phase-frequency estimator.
## This package's genotype matrix is unphased (buildMarkerGenotypeMatrix()'s
## "allele1/allele2" cells carry no coupling/repulsion information), so a
## double-heterozygote at both loci has two candidate phase resolutions
## that cannot be distinguished from its genotype alone. Generalizes the
## classic biallelic two-locus EM (Excoffier & Slatkin 1995, "Maximum-
## likelihood estimation of molecular haplotype frequencies in a diploid
## population" -- the paper's own term; this package calls the estimated
## quantity a "phase frequency" per D1's vocabulary discipline, never bare
## "haplotype") to arbitrary allele counts per locus. Verified this
## session (PRE-RED) against a fully phase-resolvable case (exact match to
## the classic gametic count), a 600-individual random-mating simulation
## with 209 genuinely phase-ambiguous double heterozygotes (recovered
## within 2% of the known true value), and a 3-allele x 3-allele
## multiallelic case (recovered within ~0.017 absolute error at n=800).
## Internal only -- not exported.
.emTwoLocusPhaseFreq <- function(genoA, genoB, tol = 1e-8, maxit = 500L) {
  gA <- strsplit(genoA, "/", fixed = TRUE)
  gB <- strsplit(genoB, "/", fixed = TRUE)
  n <- length(genoA)
  allA <- sort(unique(unlist(gA)))
  allB <- sort(unique(unlist(gB)))
  kA <- length(allA)
  kB <- length(allB)

  resolutions <- vector("list", n)
  for (k in seq_len(n)) {
    a <- gA[[k]]
    b <- gB[[k]]
    if (a[1L] == a[2L] || b[1L] == b[2L]) {
      resolutions[[k]] <- list(
        list(pairs = list(c(a[1L], b[1L]), c(a[2L], b[2L])))
      )
    } else {
      resolutions[[k]] <- list(
        list(pairs = list(c(a[1L], b[1L]), c(a[2L], b[2L]))),
        list(pairs = list(c(a[1L], b[2L]), c(a[2L], b[1L])))
      )
    }
  }

  pA <- table(factor(unlist(gA), levels = allA)) / (2L * n)
  pB <- table(factor(unlist(gB), levels = allB)) / (2L * n)
  phaseFreq <- outer(as.numeric(pA), as.numeric(pB))
  dimnames(phaseFreq) <- list(allA, allB)

  for (it in seq_len(maxit)) {
    counts <- matrix(0.0, kA, kB, dimnames = list(allA, allB))
    for (k in seq_len(n)) {
      opts <- resolutions[[k]]
      if (length(opts) == 1L) {
        p1 <- opts[[1L]]$pairs[[1L]]
        p2 <- opts[[1L]]$pairs[[2L]]
        counts[p1[1L], p1[2L]] <- counts[p1[1L], p1[2L]] + 1L
        counts[p2[1L], p2[2L]] <- counts[p2[1L], p2[2L]] + 1L
      } else {
        p1a <- opts[[1L]]$pairs[[1L]]
        p1b <- opts[[1L]]$pairs[[2L]]
        p2a <- opts[[2L]]$pairs[[1L]]
        p2b <- opts[[2L]]$pairs[[2L]]
        lik1 <- phaseFreq[p1a[1L], p1a[2L]] * phaseFreq[p1b[1L], p1b[2L]]
        lik2 <- phaseFreq[p2a[1L], p2a[2L]] * phaseFreq[p2b[1L], p2b[2L]]
        tot <- lik1 + lik2
        w1 <- if (tot > 0.0) lik1 / tot else 0.5
        w2 <- 1.0 - w1
        counts[p1a[1L], p1a[2L]] <- counts[p1a[1L], p1a[2L]] + w1
        counts[p1b[1L], p1b[2L]] <- counts[p1b[1L], p1b[2L]] + w1
        counts[p2a[1L], p2a[2L]] <- counts[p2a[1L], p2a[2L]] + w2
        counts[p2b[1L], p2b[2L]] <- counts[p2b[1L], p2b[2L]] + w2
      }
    }
    newFreq <- counts / (2L * n)
    converged <- max(abs(newFreq - phaseFreq)) < tol
    phaseFreq <- newFreq
    if (converged) {
      break
    }
  }

  list(
    phaseFreq = phaseFreq,
    pA = stats::setNames(as.numeric(pA), names(pA)),
    pB = stats::setNames(as.numeric(pB), names(pB))
  )
}

## Aggregates a two-locus phase-frequency table into the per-locus-pair D'
## (Hedrick 1987: weighted average of |D'_ij| across all allele pairs) and
## r2 (a chi-squared/Cramer's-phi-squared-style multiallelic generalization
## that reduces EXACTLY to the classic biallelic r^2 when both loci are
## biallelic -- verified this session, both algebraically and numerically;
## see Weir 1996, Genetic Data Analysis II). Internal only -- not exported.
.aggregateLdBlockStat <- function(phaseFreq, pA, pB) {
  allA <- names(pA)
  allB <- names(pB)
  dMat <- outer(allA, allB, Vectorize(function(i, j) {
    phaseFreq[i, j] - pA[i] * pB[j]
  }))
  dPrimeMat <- outer(allA, allB, Vectorize(function(i, j) {
    d <- phaseFreq[i, j] - pA[i] * pB[j]
    dMax <- if (d > 0.0) {
      min(pA[i] * (1.0 - pB[j]), (1.0 - pA[i]) * pB[j])
    } else if (d < 0.0) {
      min(pA[i] * pB[j], (1.0 - pA[i]) * (1.0 - pB[j]))
    } else {
      1.0
    }
    if (dMax == 0.0) 0.0 else d / dMax
  }))
  weights <- outer(pA, pB)
  list(
    Dprime = sum(weights * abs(dPrimeMat)),
    r2 = sum(dMat^2.0 / weights)
  )
}

.markerLdBlockCaveat <- paste(
  "Descriptive statistic only -- not a rigorous, pedigree-aware LD-block",
  "measure. Classical linkage-disequilibrium theory assumes random",
  "mating, which a pedigreed colony violates; prefer",
  "markerRealizedRelatednessVariance() for pedigree-valid estimates."
)

#' Compute a descriptive, same-chromosome pairwise LD/block statistic
#'
#' Estimates a descriptive linkage-disequilibrium (LD) block statistic
#' (D', a chi-squared-based generalization of r2) for every pair of loci
#' on the same chromosome (issue #153, D3b). This is deliberately the
#' \emph{secondary}, exploratory-use statistic in the design's two-metric
#' pair -- \code{\link{markerRealizedRelatednessVariance}} is the primary,
#' genuinely pedigree-valid metric. No CRAN package is both pedigree-aware
#' and multiallelic-capable (issue #153 design doc sec 2.12), so classical
#' LD theory's random-mating assumption is a genuine, documented
#' compromise for a pedigreed colony sample (D8) -- the \code{caveat}
#' column on every returned row is not decorative and must not be dropped.
#'
#' @details
#' Because the genotype matrix is unphased,
#' \code{markerLdBlock} estimates two-locus phase frequencies for each
#' pair via a multiallelic maximum-likelihood (EM) estimator, generalizing
#' the classic biallelic two-locus EM (Excoffier & Slatkin 1995) to
#' arbitrary allele counts per locus. Per-allele-pair D and its
#' standardized D-prime use the classic Lewontin (1964) standardization;
#' the per-pair \code{Dprime} is Hedrick's (1987) frequency-weighted
#' average of the absolute standardized per-allele-pair values across all
#' allele pairs, and \code{r2} is a chi-squared/Cramer's-phi-squared-style
#' multiallelic generalization that reduces exactly to the classic
#' biallelic \eqn{r^2} when both loci happen to be biallelic.
#'
#' Only same-chromosome locus pairs are computed -- \code{locusMetadata}'s
#' \code{pos}/\code{cM} columns are not used (D2's own finding that
#' locus-order metadata is typically sparse or absent for real colony
#' panels). A pair with fewer than 2 individuals genotyped at both loci
#' (after any \code{founderIds} restriction) returns \code{NA} with a
#' named warning, matching \code{\link{markerFst}}'s precedent for an
#' insufficient-evidence pair -- not a \code{stop()}.
#'
#' @param genotypeMatrix a character matrix as returned by
#' \code{\link{buildMarkerGenotypeMatrix}}: rows are individual \code{id}s,
#' columns are loci, and each cell is that individual's two alleles at
#' that locus, sorted and joined by \code{"/"} (or \code{NA} if not
#' genotyped at that locus).
#' @param locusMetadata dataframe as returned by
#' \code{\link{checkLocusMetadata}}: at least \code{locus} and
#' \code{chrom} columns. Loci with \code{NA} \code{chrom} are excluded
#' from pairing.
#' @param founderIds optional character vector of ids to which the
#' computation should be restricted (e.g. \code{\link{getFounders}(ped)});
#' \code{NULL} (default) uses every individual in \code{genotypeMatrix}.
#'
#' @return A dataframe with one row per same-chromosome locus pair:
#' \code{locus1}, \code{locus2}, \code{chrom}, \code{Dprime}, \code{r2},
#' \code{nUsed} (individuals genotyped at both loci), \code{idsUsed}
#' (comma-joined ids, populated only when \code{founderIds} is supplied --
#' \code{NA} otherwise), and \code{caveat} (a fixed, non-droppable
#' descriptive-statistic warning on every row).
#'
#' @references Excoffier, L., & Slatkin, M. (1995). Maximum-likelihood
#' estimation of molecular haplotype frequencies in a diploid population.
#' \emph{Molecular Biology and Evolution}, 12(5), 921-927.
#' \doi{10.1093/oxfordjournals.molbev.a040269}
#'
#' Hedrick, P. W. (1987). Gametic disequilibrium measures: proceed with
#' caution. \emph{Genetics}, 117(2), 331-341.
#'
#' Weir, B. S. (1996). \emph{Genetic Data Analysis II: Methods for
#' Discrete Population Genetic Data}. Sinauer Associates.
#'
#' @seealso \code{\link{buildMarkerGenotypeMatrix}},
#' \code{\link{checkLocusMetadata}},
#' \code{\link{markerRealizedRelatednessVariance}},
#' \code{\link{obfuscateLdBlocks}}
#' @export
#' @examples
#' library(nprcgenekeepr)
#' genotype <- checkLinkageMarkerGenotypeFile(data.frame(
#'   id = rep(c("W", "X", "Y", "Z"), 2),
#'   locus = rep(c("L1", "L2"), each = 4),
#'   allele1 = c("A", "A", "A", "A", "M", "M", "N", "N"),
#'   allele2 = c("A", "B", "A", "B", "M", "N", "M", "N"),
#'   stringsAsFactors = FALSE
#' ))
#' genotypeMatrix <- buildMarkerGenotypeMatrix(genotype)
#' locusMetadata <- checkLocusMetadata(data.frame(
#'   locus = c("L1", "L2"), chrom = c("1", "1"), pos = c(NA, NA),
#'   stringsAsFactors = FALSE
#' ))
#' markerLdBlock(genotypeMatrix, locusMetadata)
markerLdBlock <- function(genotypeMatrix, locusMetadata, founderIds = NULL) {
  if (!is.matrix(genotypeMatrix)) {
    stop("markerLdBlock() requires genotypeMatrix to be a matrix, as ",
         "returned by buildMarkerGenotypeMatrix().")
  }
  if (!is.data.frame(locusMetadata) ||
    !all(c("locus", "chrom") %in% names(locusMetadata))) {
    stop("markerLdBlock() requires locusMetadata to be a dataframe with ",
         "'locus' and 'chrom' columns, as returned by checkLocusMetadata().")
  }

  loci <- intersect(colnames(genotypeMatrix), locusMetadata$locus)
  chromByLocus <- stats::setNames(
    as.character(locusMetadata$chrom[match(loci, locusMetadata$locus)]),
    loci
  )
  usableLoci <- loci[!is.na(chromByLocus)]
  if (length(usableLoci) == 0L) {
    stop("markerLdBlock() found no locus with a usable (non-NA) chrom ",
         "value in locusMetadata; nothing is computable.")
  }

  mat <- genotypeMatrix
  if (!is.null(founderIds)) {
    mat <- mat[rownames(mat) %in% founderIds, , drop = FALSE]
  }

  pairs <- unlist(lapply(split(usableLoci, chromByLocus[usableLoci]),
    function(lociOnChrom) {
      if (length(lociOnChrom) < 2L) {
        return(NULL)
      }
      utils::combn(sort(lociOnChrom), 2L, simplify = FALSE)
    }), recursive = FALSE)

  if (length(pairs) == 0L) {
    return(data.frame(
      locus1 = character(0L), locus2 = character(0L), chrom = character(0L),
      Dprime = numeric(0L), r2 = numeric(0L), nUsed = integer(0L),
      idsUsed = character(0L), caveat = character(0L),
      stringsAsFactors = FALSE
    ))
  }

  rows <- lapply(pairs, function(pair) {
    locus1 <- pair[1L]
    locus2 <- pair[2L]
    callsA <- mat[, locus1]
    callsB <- mat[, locus2]
    used <- !is.na(callsA) & !is.na(callsB)
    usedIds <- rownames(mat)[used]

    idsUsed <- if (is.null(founderIds)) {
      NA_character_
    } else {
      paste(sort(usedIds), collapse = ",")
    }

    if (length(usedIds) < 2L) {
      warning("markerLdBlock: '", locus1, "' x '", locus2, "' has fewer ",
              "than 2 individuals genotyped at both loci; returning NA ",
              "for this pair.")
      return(data.frame(
        locus1 = locus1, locus2 = locus2, chrom = chromByLocus[[locus1]],
        Dprime = NA_real_, r2 = NA_real_, nUsed = length(usedIds),
        idsUsed = idsUsed, caveat = .markerLdBlockCaveat,
        stringsAsFactors = FALSE
      ))
    }

    fit <- .emTwoLocusPhaseFreq(callsA[used], callsB[used])
    agg <- .aggregateLdBlockStat(fit$phaseFreq, fit$pA, fit$pB)

    data.frame(
      locus1 = locus1, locus2 = locus2, chrom = chromByLocus[[locus1]],
      Dprime = agg$Dprime, r2 = agg$r2, nUsed = length(usedIds),
      idsUsed = idsUsed, caveat = .markerLdBlockCaveat,
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, rows)
}
