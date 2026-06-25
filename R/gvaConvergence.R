#' Evidence-based advice on the number of gene-drop iterations a pedigree needs
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Part of Genetic Value Analysis
#'
#' Genome uniqueness (\code{\link{calcGU}}) is the only ranked Genetic Value
#' Analysis output that carries Monte Carlo (gene-drop) sampling noise, so the
#' number of iterations a colony actually needs is pedigree-dependent: there is
#' no single universal "right" count. \code{gvaConvergence} answers issue #2's
#' literal ask -- "define reproducible and automate finding the needed number of
#' iterations" -- on the ratified definition that the decision-relevant quantity
#' is the \emph{selection order} (which animals are chosen, and in what order),
#' not the precision of the \code{gu} number itself.
#'
#' Because the \code{n} gene-drop iteration columns are independent and
#' identically distributed replicates, the whole convergence picture is
#' recoverable from a \emph{single} completed gene drop the user already pays
#' for: \code{gvaConvergence} runs one gene drop at \code{nMax}, computes the
#' per-iteration rare-allele matrix once (\code{\link{calcA}}), and for each
#' candidate iteration count \code{N} in \code{grid} splits the columns into two
#' disjoint halves of \code{N} columns each. The two halves are genuinely
#' independent \code{N}-iteration estimates; each is ranked through the same
#' ordering pipeline the report uses, and the two orderings are compared. A run
#' is judged \strong{reproducible at \code{N}} when both
#' \itemize{
#'  \item the top-\code{k} selected animals overlap by at least \code{oMin}
#'    (the same animals are chosen), and
#'  \item the Kendall rank agreement of the commonly-ranked animals is at least
#'    \code{rhoMin} (they come out in the same order).
#' }
#' The recommended iteration count is the smallest \code{N} in \code{grid} at
#' which both criteria hold. The issue #76 de-inflated \code{gu = 0}
#' "Undetermined" set (both parents unknown, no recorded origin) is a policy
#' constant with rank \code{NA}; it is excluded from the order the criteria are
#' computed on and reported separately as \code{nUndetermined}.
#'
#' Because the half-split compares two \code{N}-column runs to \emph{each other}
#' (never to their pooled mean), it is a conservative, self-validating estimate
#' of reproducibility at \code{N}. This changes nothing about seeding: a fixed
#' seed already makes \code{gu} bit-identical run to run; that is
#' reproducibility of the \emph{process}, whereas this function reports the
#' sampling reproducibility of the \emph{estimate}.
#'
#' @return An object of class \code{nprcgenekeeprGVConv}: a list with
#' \itemize{
#'  \item \code{convergence} -- a data.frame with one row per assessed iteration
#'    count: \code{iterations}, \code{topOverlap} (top-\code{k} selected-set
#'    overlap, from 0 to 1), and \code{rankAgreement} (Kendall rank agreement
#'    of the commonly-ranked animals, from -1 to 1).
#'  \item \code{recommendedIter} -- the smallest assessed iteration count
#'    meeting both criteria, or \code{NA} if none did within \code{grid}.
#'  \item \code{converged} -- \code{TRUE} if any assessed count met both
#'    criteria.
#'  \item \code{criteria} -- the \code{k}, \code{oMin}, and \code{rhoMin} used.
#'  \item \code{nRankable} -- the number of probands carrying a (non-\code{NA})
#'    rank that the order metrics are computed on.
#'  \item \code{nUndetermined} -- the count of the excluded issue #76
#'    Undetermined set (2C).
#'  \item \code{nMax} -- the gene-drop budget actually simulated.
#' }
#'
#' @param ped The pedigree information in data.frame format (the same input
#' \code{\link{reportGV}} takes).
#' @param pop Character vector with animal IDs to consider as the population of
#' interest. The default is NULL (all animals).
#' @param nMax Integer gene-drop budget: the number of iteration columns to
#' simulate. Reproducibility is assessed for iteration counts \code{N} with
#' \code{2 * N <= nMax} (each half-split needs \code{2 * N} columns). Default
#' 3000.
#' @param guThresh Integer threshold number of animals for defining a rare
#' (unique) allele, passed to \code{\link{calcGU}} / \code{\link{calcA}}.
#' Default 1.
#' @param byID Logical passed to \code{alleleFreq()} via \code{\link{calcA}}; if
#' TRUE, homozygous alleles are counted once per individual. Default TRUE.
#' @param grid Integer vector of candidate iteration counts to assess. The
#' default builds \code{c(25, 50, 100, 200, 400, 800, 1500)}, keeping only those
#' with \code{2 * N <= nMax}.
#' @param k Integer size of the top-\code{k} selected set compared for overlap.
#' Default 20.
#' @param oMin Numeric minimum top-\code{k} overlap for reproducibility. Default
#' 0.90.
#' @param rhoMin Numeric minimum Kendall rank agreement for reproducibility.
#' Default 0.95.
#' @param seed Optional integer; when supplied, \code{\link{set_seed}} pins the
#' gene-drop RNG so the convergence curve is reproducible. Default NULL.
#' @param updateProgress Function or NULL passed through to \code{geneDrop()} to
#' update a \code{shiny::Progress} object. Default NULL.
#' @param breedingTable,gestationTable,breedingAgeDefault,gestationDefault
#' Optional overrides for the unknown-parent mean-kinship correction, passed
#' through to \code{correctUnknownParentMeanKinship()} exactly as
#' \code{\link{reportGV}} passes them (issue #73 Part 2). NULL uses the bundled
#' defaults.
#' @seealso \code{\link{reportGV}}, \code{\link{calcGU}}, \code{\link{calcGUSE}}
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ## A quick, small illustration (use a larger nMax in practice).
#' conv <- gvaConvergence(nprcgenekeepr::qcPed, nMax = 200L, seed = 1L)
#' conv$convergence
#' conv$recommendedIter
gvaConvergence <- function(ped, pop = NULL, nMax = 3000L, guThresh = 1L,
                           byID = TRUE, grid = NULL, k = 20L, oMin = 0.90,
                           rhoMin = 0.95, seed = NULL, updateProgress = NULL,
                           breedingTable = NULL, gestationTable = NULL,
                           breedingAgeDefault = NULL, gestationDefault = NULL) {
  if (is.null(grid)) {
    grid <- c(25L, 50L, 100L, 200L, 400L, 800L, 1500L)
  }
  grid <- as.integer(grid)
  # Each candidate count N must be a positive integer with both halves in budget
  # (2 * N <= nMax); a 0 would give colsB = 1:0 and a divide-by-zero NaN row, a
  # negative N would error in seq_len().
  grid <- sort(unique(grid[grid >= 1L & 2L * grid <= nMax]))
  if (length(grid) == 0L) {
    stop("gvaConvergence(): no iteration count N in 'grid' satisfies ",
         "1 <= N and 2 * N <= nMax = ", nMax,
         "; increase nMax or adjust 'grid'.")
  }

  # Deterministic ranking scaffold -- the same building blocks reportGV() uses,
  # in the same way (reportGV / calcA / orderReport themselves are unchanged).
  ped$population <- getGVPopulation(ped, pop)
  probands <- as.character(ped$id[ped$population])
  genotype <- getGVGenotype(ped)
  kmat <- filterKinMatrix(probands, kinship(
    ped$id, ped$sire, ped$dam, ped$gen
  ))
  indivMeanKin <- meanKinship(kmat)[probands]
  indivMeanKin <- correctUnknownParentMeanKinship(
    indivMeanKin, ped,
    gestationTable = gestationTable, breedingTable = breedingTable,
    breedingAgeDefault = breedingAgeDefault, gestationDefault = gestationDefault
  )$indivMeanKin
  zScores <- scale(indivMeanKin)

  rownames(ped) <- ped$id
  includeCols <- intersect(getIncludeColumns(), names(ped))
  demographics <- ped[probands, c(includeCols, "sire", "dam")]
  parentage <- classifyParentage(demographics$sire, demographics$dam)
  origin <- if ("origin" %in% names(demographics)) {
    demographics$origin
  } else {
    rep(NA_character_, nrow(demographics))
  }
  # Issue #76 (2C): the de-inflated zero-gu Undetermined set -- excluded from
  # the ranked order, reported separately.
  undetermined <- parentage == "both unknown" & is.na(origin)

  # One gene drop at the budget; the rare matrix computed ONCE. The i.i.d.
  # columns make every nested prefix's gu exact (rowSums of the rare columns),
  # so no re-tabulation per prefix is needed (Finding 7).
  if (!is.null(seed)) {
    set_seed(seed)
  }
  alleles <- geneDrop(
    ids = ped$id, sires = ped$sire, dams = ped$dam, gen = ped$gen,
    genotype = genotype, n = nMax, updateProgress = updateProgress
  )
  alleles <- alleles[alleles$id %in% probands, ]
  rare <- calcA(alleles, threshold = guThresh, byID = byID)[probands, ,
    drop = FALSE
  ]

  # Rank a per-prefix gu vector (probands order) through the real pipeline and
  # return the ordered IDs of the rankable (non-NA rank) animals.
  buildOrder <- function(guVec) {
    guVec[undetermined] <- 0.0
    finalData <- cbind(
      demographics,
      indivMeanKin = indivMeanKin, zScores = zScores,
      gu = guVec, parentage = parentage
    )
    ordered <- orderReport(finalData, ped)
    ranked <- ordered[!is.na(ordered$rank), ]
    as.character(ranked$id[order(ranked$rank)])
  }
  topOverlap <- function(a, b) {
    kk <- min(k, length(a), length(b))
    if (kk == 0L) {
      return(NA_real_)
    }
    length(intersect(utils::head(a, kk), utils::head(b, kk))) / kk
  }
  rankAgreement <- function(a, b) {
    common <- intersect(a, b)
    if (length(common) < 3L) {
      return(NA_real_)
    }
    suppressWarnings(stats::cor(
      match(common, a), match(common, b),
      method = "kendall"
    ))
  }

  iterations <- grid
  overlaps <- numeric(length(grid))
  agreements <- numeric(length(grid))
  nRankable <- NA_integer_
  for (i in seq_along(grid)) {
    n <- grid[i]
    colsA <- seq_len(n)
    colsB <- (n + 1L):(2L * n)
    guA <- rowSums(rare[, colsA, drop = FALSE]) / (2L * n) * 100L
    guB <- rowSums(rare[, colsB, drop = FALSE]) / (2L * n) * 100L
    orderA <- buildOrder(guA)
    orderB <- buildOrder(guB)
    overlaps[i] <- topOverlap(orderA, orderB)
    agreements[i] <- rankAgreement(orderA, orderB)
    nRankable <- length(orderA) # the ranked set is fixed across N
  }

  convergence <- data.frame(
    iterations = iterations, topOverlap = overlaps,
    rankAgreement = agreements
  )
  bothHold <- convergence$topOverlap >= oMin &
    !is.na(convergence$rankAgreement) & convergence$rankAgreement >= rhoMin
  converged <- any(bothHold)
  recommendedIter <- if (converged) {
    convergence$iterations[which(bothHold)[1L]]
  } else {
    NA_integer_
  }

  result <- list(
    convergence = convergence,
    recommendedIter = recommendedIter,
    converged = converged,
    criteria = list(k = k, oMin = oMin, rhoMin = rhoMin),
    nRankable = nRankable,
    nUndetermined = sum(undetermined),
    nMax = as.integer(nMax)
  )
  class(result) <- append(class(result), "nprcgenekeeprGVConv")
  result
}
