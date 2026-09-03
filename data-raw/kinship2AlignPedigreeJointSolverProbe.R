## Empirical probe of kinship2::align.pedigree()'s joint-positioning mechanism
## (Session 670) -- backs docs/research/
## kinship2-alignped4-joint-positioning-mechanism-2026-09-03.md.
##
## Verifies, by RUNNING kinship2 (not just reading its source), the claims the
## report makes about *why* align.pedigree() does not hit the same-tier
## cascade S669's spike found in this project's own sequential engine:
##
##   1. alignped4() (the QP step) is called EXACTLY ONCE per pedigree, across
##      ALL rows/levels and ALL weakly-connected families simultaneously --
##      never once per row or once per family. Traced via trace()/untrace().
##   2. The QP's per-row adjacency constraint (>= 1 unit between consecutive
##      same-row points, in the order alignped1/2/3 already fixed) is a HARD
##      linear constraint fed to quadprog::solve.QP, not a hoped-for side
##      effect of penalty weights -- so the achieved minimum same-row gap
##      cannot drop below 1 unit regardless of how the objective's spousal/
##      parent-child weights (the `align` argument) are set. Verified by
##      sweeping align=c(a, b) over 4 orders of magnitude on the two fixtures
##      that stress this project's own engine hardest (Track C, the real 375)
##      and confirming the minimum same-row gap never drops below 1 - eps.
##   3. QP problem size (n = total plotted points across every row; ncon =
##      n + number of levels) reported per fixture, to give the report a
##      concrete sense of tractability at this project's real scale.
##
## Throwaway, matching the S667/S668/S669 audit-workstream precedent: no
## production R/ change, no TDD gate (owner-confirmed via AskUserQuestion).
## Reuses the fixture definitions and kinship2-prep helper (fixParents +
## sex-role swap) from data-raw/pedigreeDrawingErrorCensus.R verbatim
## (copied, not sourced -- this script has no runtime dependency on that
## one, matching the spike script's own convention).
##
## Run from the package root:
##   Rscript data-raw/kinship2AlignPedigreeJointSolverProbe.R
## Requires kinship2 installed locally (not a package dependency -- Suggests
## only, matching the census/spike/fidelity scripts' own convention).

if (!requireNamespace("kinship2", quietly = TRUE)) {
  stop("kinship2 not installed -- this probe requires it (Suggests-only, ",
    "matching the kinship2FidelityValidation script's own convention).")
}

## ---- fixtures (verbatim from data-raw/pedigreeDrawingErrorCensus.R) ------

suppressMessages(pkgload::load_all(".", quiet = TRUE))

pedB <- data.frame(
  id   = c("P1", "P2", "P3", "P4", "P5", "P6",
           "C1", "C2", "C3", "C4", "C4a",
           "G3", "M1", "L1", "L2", "L3"),
  sire = c(NA, NA, NA, NA, NA, NA,
           "P1", "P1", "P1", "P3", "C4",
           NA, "P1", "M1", "M1", "M1"),
  dam  = c(NA, NA, NA, NA, NA, NA,
           "P2", "P2", "P2", "P4", "P6",
           NA, "P2", "G3", "G3", "G3"),
  sex  = c("M", "F", "M", "F", "F", "F",
           "F", "M", "F", "M", "F",
           "F", "M", "F", "M", "M"),
  stringsAsFactors = FALSE
)
pedB$gen <- findGeneration(pedB$id, pedB$sire, pedB$dam)
genotypedB <- c(P1 = TRUE, P2 = TRUE, P3 = FALSE, P4 = FALSE, P5 = TRUE,
  P6 = TRUE, C1 = TRUE, C2 = FALSE, C3 = TRUE, C4 = TRUE, C4a = TRUE,
  G3 = FALSE, M1 = TRUE, L1 = TRUE, L2 = TRUE, L3 = TRUE)[pedB$id]
affectedB <- c(P1 = NA, P2 = NA, P3 = NA, P4 = NA, P5 = NA, P6 = NA,
  C1 = FALSE, C2 = NA, C3 = TRUE, C4 = TRUE, C4a = TRUE, G3 = NA,
  M1 = TRUE, L1 = NA, L2 = FALSE, L3 = TRUE)[pedB$id]
pedBShrunk <- shrinkPedigree(pedB, genotypedB, affected = affectedB,
  maxBits = 1L)$ped
pedBShrunk$gen <- findGeneration(pedBShrunk$id, pedBShrunk$sire,
  pedBShrunk$dam)

pedC <- data.frame(
  id   = c("P1", "P2", "A", "Y", "X", "W", "C1", "C2", "GC"),
  sire = c(NA, NA, "P1", "P1", NA, NA, "A", "Y", "A"),
  dam  = c(NA, NA, "P2", "P2", NA, NA, "X", "W", "Y"),
  sex  = c("M", "F", "M", "F", "F", "M", "F", "M", "M"),
  gen  = c(0L, 0L, 1L, 1L, 3L, 1L, 4L, 2L, 2L),
  stringsAsFactors = FALSE
)

pedReal <- utils::read.csv(
  system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
    package = "nprcgenekeepr"),
  stringsAsFactors = FALSE
)

fixtures <- list(
  "Track B full" = pedB,
  "Track B shrunk" = pedBShrunk,
  "Track C" = pedC,
  "Real 375" = pedReal
)

## ---- kinship2-prep helper (verbatim from pedigreeDrawingErrorCensus.R) ---

prepKinship2Pedigree <- function(ped) {
  id <- as.character(ped$id)
  sire <- as.character(ped$sire)
  dam <- as.character(ped$dam)
  sex <- as.character(ped$sex)
  dangling <- setdiff(c(sire[!is.na(sire)], dam[!is.na(dam)]), id)
  if (length(dangling) > 0L) {
    dSex <- rep("F", length(dangling))
    dSex[dangling %in% sire] <- "M"
    id <- c(id, dangling)
    sire <- c(sire, rep(NA_character_, length(dangling)))
    dam <- c(dam, rep(NA_character_, length(dangling)))
    sex <- c(sex, dSex)
  }
  sexOf <- stats::setNames(sex, id)
  swap <- !is.na(sire) & !is.na(dam) & sexOf[sire] == "F" & sexOf[dam] == "M"
  swap[is.na(swap)] <- FALSE
  tmp <- sire[swap]
  sire[swap] <- dam[swap]
  dam[swap] <- tmp
  sexCode <- c(M = 1L, F = 2L)[sex]
  sexCode[is.na(sexCode)] <- 3L
  fixed <- kinship2::fixParents(id = id, dadid = sire, momid = dam,
    sex = sexCode, missid = NA_character_)
  kinship2::pedigree(id = fixed$id, dadid = fixed$dadid,
    momid = fixed$momid, sex = fixed$sex, missid = NA_character_)
}

## ---- probe 1: call count + problem size, via a package-local trace -------

callLog <- new.env()
callLog$n <- 0L
callLog$sizes <- list()

## trace() on a namespace-internal function requires where=asNamespace(...).
## The tracer records (n variables, n constraints, n levels) each call, then
## lets the real body run via `print = FALSE` + an untouched original.
alignped4Orig <- get("alignped4", envir = asNamespace("kinship2"))
tracedAlignped4 <- function(rval, spouse, level, width, align) {
  callLog$n <- callLog$n + 1L
  nVars <- sum(rval$n)
  nLevels <- nrow(rval$nid)
  callLog$sizes[[callLog$n]] <- c(variables = nVars, levels = nLevels,
    constraints = nVars + nLevels)
  alignped4Orig(rval, spouse, level, width, align)
}
assignInNamespace("alignped4", tracedAlignped4, ns = "kinship2")
on.exit(assignInNamespace("alignped4", alignped4Orig, ns = "kinship2"),
  add = TRUE)

cat("## Probe 1: alignped4() (the QP step) call count per fixture\n\n")
cat(sprintf("%-16s %8s %10s %12s %s\n", "Fixture", "families",
  "QP calls", "QP vars(n)", "QP constraints"))
for (nm in names(fixtures)) {
  callLog$n <- 0L
  callLog$sizes <- list()
  kPed <- prepKinship2Pedigree(fixtures[[nm]])
  invisible(kinship2::align.pedigree(kPed))
  ## Weakly-connected component count, for comparison -- reuses this
  ## project's own internal helper (S667's own component partition) so
  ## "families" means the same thing the disconnected-component-separation
  ## report means by it.
  isolated <- nprcgenekeepr:::.findIsolatedIds(fixtures[[nm]])
  pedNoIso <- fixtures[[nm]][!fixtures[[nm]]$id %in% isolated, , drop = FALSE]
  forest <- nprcgenekeepr:::.buildMatingUnitForest(pedNoIso)
  nFamilies <- length(nprcgenekeepr:::.forestComponents(pedNoIso, forest))
  sz <- if (length(callLog$sizes) > 0L) callLog$sizes[[1L]] else
    c(variables = NA, levels = NA, constraints = NA)
  cat(sprintf("%-16s %8d %10d %12.0f %s\n", nm, nFamilies, callLog$n,
    sz["variables"], if (is.na(sz["constraints"])) "n/a" else
      sprintf("%.0f", sz["constraints"])))
}
cat("\n(QP calls == 1 for every fixture confirms alignped4() solves ALL\n",
  "rows and ALL weakly-connected families in a single simultaneous\n",
  "quadprog::solve.QP() call -- not once per row, once per tier, or once\n",
  "per family.)\n\n", sep = "")

## ---- probe 2: sweep align=c(a, b) -- does the achieved min-gap ever drop
##      below the 1-unit hard constraint at any weighting? -----------------

cat("## Probe 2: sweep align=c(a, b) on Track C and the real 375 fixture\n\n")
minGapAtAlign <- function(ped, align) {
  kPed <- prepKinship2Pedigree(ped)
  al <- kinship2::align.pedigree(kPed, align = align)
  minGap <- Inf
  for (r in seq_len(nrow(al$nid))) {
    keep <- al$nid[r, ] > 0L
    xs <- sort(al$pos[r, keep])
    if (length(xs) >= 2L) minGap <- min(minGap, diff(xs))
  }
  minGap
}

sweepVals <- c(0.001, 0.01, 0.1, 1L, 2L, 10L, 100L, 1000L, 10000L)
for (fixNm in c("Track C", "Real 375")) {
  cat(sprintf("### %s\n\n", fixNm))
  cat(sprintf("%12s %12s %10s\n", "align[1]=a", "align[2]=b", "min gap"))
  ## Sweep b (spousal weight) at a fixed a=1.5 (default), then sweep a
  ## (parent-child weight exponent) at a fixed b=2 (default).
  for (b in sweepVals) {
    g <- minGapAtAlign(fixtures[[fixNm]], c(1.5, b))
    cat(sprintf("%12s %12s %10.6f\n", "1.5", format(b), g))
  }
  for (a in sweepVals) {
    g <- minGapAtAlign(fixtures[[fixNm]], c(a, 2L))
    cat(sprintf("%12s %12s %10.6f\n", format(a), "2", g))
  }
  cat("\n")
}
cat("(Every min-gap value above should be >= 1 (the QP's hard per-row\n",
  "constraint), regardless of how far the objective weights are swept --\n",
  "confirming the floor is a CONSTRAINT the solver cannot violate, not a\n",
  "target the objective merely tends toward. Contrast with this project's\n",
  "own sequential engine, S669: widening its spacing/recentring formula\n",
  "is a PENALTY-like local edit with no such hard constraint enforcing\n",
  "global feasibility, which is exactly why it cascaded into new class-(c2)\n",
  "violations instead of staying feasible by construction.)\n", sep = "")
