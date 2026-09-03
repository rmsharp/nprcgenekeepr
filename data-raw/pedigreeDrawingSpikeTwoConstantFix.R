## SPIKE (Session 669): does the S668 census's recommended two-constant fix
## resolve classes (a)/(b) without regressing others?
##
## docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-02.md, Recommendation 1:
## "spike the two-constant change (recentre every union on its mate midpoint;
## 1.0-unit spousal separation for every pair) and re-run the census -- if
## (a)+(b) fall to ~24 with no other class rising, (A) is three bounded
## changes from a clean production drawing; if it cascades into Tier 1, that
## is the evidence for (C)."
##
## This is a MEASUREMENT SPIKE, not an implementation. Owner-confirmed via
## AskUserQuestion (S669): throwaway script, no production R/ change, no TDD
## gate -- matching S668's own owner-confirmed audit-workstream precedent.
## `R/makePedigreeDiagramData.R` is untouched by this script; git status/git
## diff on R/ stay clean. The two constants live inside the internal
## .positionMatingUnitForest() (R/makePedigreeDiagramData.R:759-1529), so this
## script defines .positionMatingUnitForestSpike() -- a full copy of that
## function's CURRENT (post-S667/S668) source with exactly 3 mechanical edits,
## called out below and printed by this script's own header at runtime so the
## diff is never just asserted -- and reuses everything else (fixtures, the
## six census detectors, node helpers, kinship2Baseline) verbatim from
## data-raw/pedigreeDrawingErrorCensus.R (copied, not sourced, so this file
## has no runtime dependency on that one and can be deleted once the owner's
## A-vs-C decision is made).
##
## The 3 edits to .positionMatingUnitForest()'s copied body:
##   1. derivedX()'s non-qualifying branch: `minSep * 0.4` -> `minSep` (full
##      1.0-unit spousal separation for every B1/duplicate mate, not just
##      qualifying ones -- those already got full minSep via
##      b1AnchorRelativeX(), S647/S665/S666).
##   2. A NEW final recenter pass, inserted after Tier 3 and every
##      collision-avoidance/proximity pass (so both sides' FINAL drawn x are
##      known), that sets EVERY xDerivable unit's x to the mean of its two
##      sides' final positions -- generalizing the qualifying-only recenter
##      Track 7 Phase 1 shipped and S652 reverted (see the "lived here"
##      comment block at R/makePedigreeDiagramData.R:1229-1247) to every unit,
##      matching the census's "recentre EVERY union" wording (not "every
##      qualifying union").
##   3. The recursive self-call (disconnected-component separation, S667) is
##      renamed from `.positionMatingUnitForest(...)` to
##      `.positionMatingUnitForestSpike(...)` so a multi-family fixture's
##      per-component recursion also uses the spiked engine, not the shipped
##      one -- otherwise only the top-level call would be spiked and every
##      real multi-family fixture (Track B shrunk, the real 375) would
##      silently fall back to shipped behavior for each component.
##
## Run from the package root (build-ignored, matches the census script's own
## convention):
##   Rscript data-raw/pedigreeDrawingSpikeTwoConstantFix.R
##
## Prints a BEFORE (shipped) / AFTER (spiked) scoreboard per fixture and
## writes every spiked-run finding row to the CSV named in findingsCsv below.

suppressMessages(pkgload::load_all(".", quiet = TRUE))

findingsCsv <- file.path("docs", "audits",
  "PEDIGREE_DRAWING_SPIKE_TWO_CONSTANT_FIX_2026-09-02_findings.csv")

xScale <- 120L
yScale <- 150L
minSepRaw <- 1L
minSepPx <- minSepRaw * xScale
eps <- 1e-9

## ---- fixtures (verbatim copy from pedigreeDrawingErrorCensus.R) ----------

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

pedD1 <- data.frame(
  id   = c("F1", "M1", "A1", "S1", "K1", "K2", "K3", "K4", "F2", "M2", "B1"),
  sire = c(NA, NA, "F1", NA, "S1", "S1", "S1", "S1", NA, NA, "F2"),
  dam  = c(NA, NA, "M1", NA, "A1", "A1", "A1", "A1", NA, NA, "M2"),
  sex  = c("M", "F", "F", "M", "M", "F", "M", "F", "M", "F", "M"),
  stringsAsFactors = FALSE
)
pedD1$gen <- findGeneration(pedD1$id, pedD1$sire, pedD1$dam)
pedD2 <- data.frame(
  id   = c("A1", "A2", "A3", "B1", "B2", "B3", "C1", "C2", "C3"),
  sire = c(NA, NA, "A1", NA, NA, "B1", NA, NA, "C1"),
  dam  = c(NA, NA, "A2", NA, NA, "B2", NA, NA, "C2"),
  sex  = c("M", "F", "F", "M", "F", "M", "M", "F", "F"),
  stringsAsFactors = FALSE
)
pedD2$gen <- findGeneration(pedD2$id, pedD2$sire, pedD2$dam)
pedD3 <- data.frame(
  id   = c("A1", "A2", "A3", "B1", "B2", "B3", "B4", "B5"),
  sire = c(NA, NA, "A1", NA, NA, "B1", "B3", NA),
  dam  = c(NA, NA, "A2", NA, NA, "B2", "B5", NA),
  sex  = c("M", "F", "F", "M", "F", "M", "F", "F"),
  stringsAsFactors = FALSE
)
pedD3$gen <- findGeneration(pedD3$id, pedD3$sire, pedD3$dam)

fixtures <- list(
  "Track B full" = pedB,
  "Track B shrunk" = pedBShrunk,
  "Track C" = pedC,
  "Real 375" = pedReal,
  D1 = pedD1,
  D2 = pedD2,
  D3 = pedD3
)

## ---- SPIKE ENGINE: .positionMatingUnitForestSpike() ----------------------
## Full copy of R/makePedigreeDiagramData.R's .positionMatingUnitForest()
## (as of commit b8ae2114, S668 close-out) with exactly the 3 edits called
## out in the header above, marked "## SPIKE EDIT" inline at each site.

.positionMatingUnitForestSpike <- function(ped, forest) {
  if (!is.data.frame(ped)) {
    stop(".positionMatingUnitForestSpike() requires 'ped' to be a data frame.")
  }
  required <- c("id", "sire", "dam", "sex", "gen")
  missingCols <- setdiff(required, names(ped))
  if (length(missingCols) > 0L) {
    stop(".positionMatingUnitForestSpike() requires 'ped' to have columns: ",
         toString(required), ". Missing: ", toString(missingCols))
  }

  ped$gen[is.na(ped$gen)] <- 0L
  minSep <- 1L
  .kMaxIndividualPush <- 2L

  components <- .forestComponents(ped, forest)
  if (length(components) > 1L) {
    perComponent <- lapply(components, function(members) {
      ## SPIKE EDIT 3: recurse into the SPIKE engine, not the shipped one --
      ## otherwise a multi-family fixture's per-component recursion would
      ## silently fall back to shipped behavior for every component.
      .positionMatingUnitForestSpike(
        ped[as.character(ped$id) %in% members, , drop = FALSE],
        .subsetForest(forest, members)
      )
    })
    return(.packComponents(perComponent, minSep))
  }

  matingUnits <- forest$matingUnits
  duplicates <- forest$duplicates
  childEdges <- forest$childEdges
  unitIds <- matingUnits$id
  realIds <- as.character(ped$id)
  genOf <- stats::setNames(ped$gen, realIds)
  sireOf <- stats::setNames(as.character(ped$sire), realIds)
  damOf <- stats::setNames(as.character(ped$dam), realIds)
  sexOf <- stats::setNames(as.character(ped$sex), realIds)
  anchorOf <- stats::setNames(matingUnits$anchor, unitIds)
  nonAnchorOf <- stats::setNames(matingUnits$nonAnchor, unitIds)

  directChildrenOf <- function(id) {
    childEdges$to[childEdges$from == id & childEdges$from %in% realIds]
  }
  hasOwnDirectChild <- function(id) length(directChildrenOf(id)) > 0L
  unitChildrenOf <- function(id) {
    myUnits <- unitIds[!is.na(anchorOf) & anchorOf == id]
    if (length(myUnits) == 0L) return(character(0L))
    unlist(lapply(myUnits, function(u) childEdges$to[childEdges$from == u]),
           use.names = FALSE)
  }
  childrenOf <- function(id) c(directChildrenOf(id), unitChildrenOf(id))

  hasParentEdge <- function(id) !is.na(sireOf[[id]]) || !is.na(damOf[[id]])
  anchoredUnits <- matingUnits[!is.na(matingUnits$anchor), , drop = FALSE]
  everAnchor <- unique(anchoredUnits$anchor)
  nonAnchorSides <- c(anchoredUnits$sire, anchoredUnits$dam)
  neverAnchorIds <- setdiff(unique(nonAnchorSides), everAnchor)
  b1Ids <- Filter(function(id) {
    id %in% realIds && !hasOwnDirectChild(id) && !hasParentEdge(id)
  }, neverAnchorIds)

  qualifies <- function(unitId) {
    p <- anchorOf[[unitId]]
    m <- nonAnchorOf[[unitId]]
    if (is.na(p) || is.na(m)) return(FALSE)
    sireId <- matingUnits$sire[matingUnits$id == unitId]
    damId <- matingUnits$dam[matingUnits$id == unitId]
    if (!(sireId %in% realIds) || !(damId %in% realIds)) return(FALSE)
    mateCountP <- sum(anchoredUnits$sire == p | anchoredUnits$dam == p)
    mateCountM <- sum(anchoredUnits$sire == m | anchoredUnits$dam == m)
    unambiguousOppositeSex <-
      (identical(sexOf[[p]], "M") && identical(sexOf[[m]], "F")) ||
      (identical(sexOf[[p]], "F") && identical(sexOf[[m]], "M"))
    mateCountP == 1L && mateCountM == 1L && !hasOwnDirectChild(p) &&
      unambiguousOppositeSex
  }

  founderIds <- Filter(function(id) !hasParentEdge(id), realIds)
  orphanUnitIds <- unitIds[is.na(anchorOf)]
  orphanChildIds <- if (length(orphanUnitIds) > 0L) {
    unique(unlist(lapply(orphanUnitIds, function(u) {
      childEdges$to[childEdges$from == u]
    }), use.names = FALSE))
  } else {
    character(0L)
  }
  rootIds <- union(setdiff(founderIds, b1Ids), orphanChildIds)

  forestChildrenOf <- .buildForestChildrenOf(rootIds, childrenOf,
                                              superRootId = "__super_root__")
  tier1X <- .positionTreeApportion("__super_root__", forestChildrenOf)
  tier1X <- tier1X[names(tier1X) != "__super_root__"]

  dispGenOf <- genOf[names(tier1X)]
  sweepMinSepBackstop <- function() {
    for (g in sort(unique(dispGenOf))) {
      rowIds <- names(tier1X)[dispGenOf == g]
      if (length(rowIds) < 2L) next
      rowIds <- rowIds[order(tier1X[rowIds], rowIds, method = "radix")]
      for (i in 2L:length(rowIds)) {
        prevX <- tier1X[[rowIds[i - 1L]]]
        if (tier1X[[rowIds[i]]] < prevX + minSep) {
          tier1X[[rowIds[i]]] <<- prevX + minSep
        }
      }
    }
  }
  sweepMinSepBackstop()

  subtreeIds <- function(id) {
    kids <- childrenOf(id)
    c(id, unlist(lapply(kids, subtreeIds), use.names = FALSE))
  }
  correctableUnitIds <- Filter(
    function(u) qualifies(u) && nonAnchorOf[[u]] %in% b1Ids,
    intersect(anchoredUnits$id, unique(childEdges$from))
  )
  correctionOrder <- correctableUnitIds[
    order(genOf[anchorOf[correctableUnitIds]], correctableUnitIds,
          method = "radix")
  ]
  for (u in correctionOrder) {
    p <- anchorOf[[u]]
    m <- nonAnchorOf[[u]]
    sign <- if (identical(sexOf[[p]], "F") &&
                  identical(sexOf[[m]], "M")) -1L else 1L
    kids <- childEdges$to[childEdges$from == u]
    if (hasParentEdge(p)) {
      mateFresh <- tier1X[[p]] + sign * minSep
      trueMid <- mean(c(tier1X[[p]], mateFresh))
      delta <- trueMid - mean(tier1X[kids])
      ids <- unlist(lapply(kids, subtreeIds), use.names = FALSE)
      tier1X[ids] <- tier1X[ids] + delta
    } else {
      childrenMean <- mean(tier1X[kids])
      mateRaw <- tier1X[[p]] + sign * minSep
      shift <- childrenMean - mean(c(tier1X[[p]], mateRaw))
      tier1X[[p]] <- tier1X[[p]] + shift
    }
  }
  sweepMinSepBackstop()

  unitX <- stats::setNames(rep(NA_real_, length(unitIds)), unitIds)
  xDerivableUnits <- matingUnits[matingUnits$id %in%
                                    unique(childEdges$from), , drop = FALSE]
  for (u in xDerivableUnits$id) {
    kids <- childEdges$to[childEdges$from == u]
    unitX[[u]] <- mean(tier1X[kids])
  }

  b1AnchorRelativeX <- function(unitId, memberId) {
    p <- anchorOf[[unitId]]
    sign <- if (identical(sexOf[[p]], "F") &&
                  identical(sexOf[[memberId]], "M")) -1L else 1L
    unname(tier1X[[p]]) + sign * minSep
  }
  ## SPIKE EDIT 1: full minSep (was minSep * 0.4) for every non-qualifying
  ## B1/duplicate mate -- the census's "1.0-unit spousal separation for
  ## every pair."
  derivedX <- function(unitId, memberId, isB1) {
    if (isB1 && qualifies(unitId)) {
      b1AnchorRelativeX(unitId, memberId)
    } else {
      unname(unitX[[unitId]]) + minSep
    }
  }

  b1UnitOf <- stats::setNames(character(length(b1Ids)), b1Ids)
  for (fp in b1Ids) {
    ownUnits <- matingUnits$id[matingUnits$sire == fp | matingUnits$dam == fp]
    dupUnits <- duplicates$matingUnitId[duplicates$realId == fp]
    b1UnitOf[[fp]] <- setdiff(ownUnits, dupUnits)[1L]
  }

  .deCollideIndividualPoints <- function(ids, gens,
                                          seedIndividuals = numeric(0L),
                                          pushSign = NULL) {
    x <- tier3X[ids]
    names(x) <- ids
    if (is.null(pushSign)) {
      pushSign <- stats::setNames(rep(1L, length(ids)), ids)
    }
    for (g in sort(unique(gens))) {
      theseIds <- ids[gens == g]
      seedGen <- tier3Gen[names(seedIndividuals)] == g
      individualOccupied <- c(tier1X[dispGenOf == g], seedIndividuals[seedGen])
      individualOccupied <- individualOccupied[!is.na(individualOccupied)]
      unionOccupied <- unitX[unitIds[matingUnits$gen == g]]
      unionOccupied <- unionOccupied[!is.na(unionOccupied)]
      theseIds <- theseIds[order(x[theseIds], theseIds, method = "radix")]
      placedThisGen <- numeric(0L)
      for (i in seq_along(theseIds)) {
        forbidden <- c(individualOccupied, placedThisGen)
        x0 <- x[[theseIds[i]]]
        rawX0 <- x0
        sign <- pushSign[[theseIds[i]]]
        if (any(abs(x0 - forbidden) < 1e-9)) {
          k <- 1L
          repeat {
            candPref <- x0 + sign * k * minSep
            if (!any(abs(candPref - forbidden) < 1e-9)) {
              x0 <- candPref
              break
            }
            candOther <- x0 - sign * k * minSep
            if (!any(abs(candOther - forbidden) < 1e-9)) {
              x0 <- candOther
              break
            }
            if (k >= .kMaxIndividualPush) {
              x0 <- rawX0
              break
            }
            k <- k + 1L
          }
        }
        if (!isTRUE(all.equal(x0, rawX0)) || !any(abs(x0 - forbidden) < 1e-9)) {
          repeat {
            tiesIndividual <- any(abs(x0 - forbidden) < 1e-9)
            tiesUnion <- any(abs(x0 - unionOccupied) < 1e-9)
            if (!tiesIndividual && !tiesUnion) break
            x0 <- x0 + sign * (if (tiesIndividual) minSep else 1e-3)
          }
        }
        x[[theseIds[i]]] <- x0
        placedThisGen <- c(placedThisGen, x0)
      }
    }
    x
  }

  tier3X <- stats::setNames(numeric(length(b1Ids)), b1Ids)
  tier3Gen <- stats::setNames(integer(length(b1Ids)), b1Ids)
  b1PushSign <- stats::setNames(rep(1L, length(b1Ids)), b1Ids)
  for (fp in b1Ids) {
    unitId <- b1UnitOf[[fp]]
    tier3X[[fp]] <- derivedX(unitId, fp, isB1 = TRUE)
    tier3Gen[[fp]] <- unname(matingUnits$gen[matingUnits$id == unitId])
    if (qualifies(unitId)) {
      p <- anchorOf[[unitId]]
      b1PushSign[[fp]] <- if (identical(sexOf[[p]], "F") &&
                                identical(sexOf[[fp]], "M")) -1L else 1L
    }
  }
  if (length(b1Ids) > 0L) {
    tier3X[b1Ids] <-
      .deCollideIndividualPoints(b1Ids, tier3Gen[b1Ids], pushSign = b1PushSign)
  }

  unionClearanceIndividual <- (25L + 6L) / 120L
  unionClearanceUnion <- (6L + 6L) / 120L
  individualClearance <- (25L + 25L) / 120L
  .kMaxUnionPush <- 5L
  .kMaxB1ProximityPush <- 2L

  if (length(b1Ids) > 0L) {
    for (g in sort(unique(tier3Gen[b1Ids]))) {
      theseIds <- b1Ids[tier3Gen[b1Ids] == g]
      theseIds <- theseIds[order(tier3X[theseIds], theseIds, method = "radix")]
      pushedThisGen <- numeric(0L)
      for (fp in theseIds) {
        ownAnchor <- anchorOf[[b1UnitOf[[fp]]]]
        forbidden <- c(tier1X[dispGenOf == g], pushedThisGen)
        forbidden <- forbidden[!is.na(forbidden) &
                                  names(forbidden) != ownAnchor]
        x0 <- tier3X[[fp]]
        if (length(forbidden) > 0L &&
              any(abs(x0 - forbidden) < individualClearance)) {
          rawX0 <- x0
          sign <- b1PushSign[[fp]]
          k <- 1L
          repeat {
            candPref <- rawX0 + sign * k * individualClearance
            if (!any(abs(candPref - forbidden) < individualClearance)) {
              x0 <- candPref
              break
            }
            candOther <- rawX0 - sign * k * individualClearance
            if (!any(abs(candOther - forbidden) < individualClearance)) {
              x0 <- candOther
              break
            }
            if (k >= .kMaxB1ProximityPush) {
              x0 <- rawX0
              break
            }
            k <- k + 1L
          }
          tier3X[[fp]] <- x0
        }
        pushedThisGen <- c(pushedThisGen, stats::setNames(tier3X[[fp]], fp))
      }
    }
  }

  if (nrow(xDerivableUnits) > 0L) {
    ord <- order(xDerivableUnits$gen, xDerivableUnits$id, method = "radix")
    orderedUnits <- xDerivableUnits[ord, , drop = FALSE]
    placedAtGen <- list()
    for (i in seq_len(nrow(orderedUnits))) {
      u <- orderedUnits$id[i]
      g <- as.character(orderedUnits$gen[i])
      b1AtGen <- tier3X[b1Ids[tier3Gen[b1Ids] == orderedUnits$gen[i]]]
      individualOccupied <- c(tier1X[dispGenOf == orderedUnits$gen[i]],
                               b1AtGen)
      individualOccupied <- individualOccupied[!is.na(individualOccupied)]
      ownParents <- c(anchorOf[[u]], nonAnchorOf[[u]])
      individualOccupiedForPush <- individualOccupied[
        !(names(individualOccupied) %in% ownParents)]
      unionOccupied <- placedAtGen[[g]]
      collidesIndiv <- function(x0) {
        length(individualOccupiedForPush) > 0L &&
          any(abs(x0 - individualOccupiedForPush) < unionClearanceIndividual)
      }
      collidesUnion <- function(x0) {
        length(unionOccupied) > 0L &&
          any(abs(x0 - unionOccupied) < unionClearanceUnion)
      }
      collides <- function(x0) collidesIndiv(x0) || collidesUnion(x0)
      x0 <- unitX[[u]]
      rawX0 <- x0
      if (collides(x0)) {
        k <- 1L
        repeat {
          candPref <- rawX0 + k * unionClearanceIndividual
          if (!collides(candPref)) {
            x0 <- candPref
            break
          }
          candOther <- rawX0 - k * unionClearanceIndividual
          if (!collides(candOther)) {
            x0 <- candOther
            break
          }
          if (k >= .kMaxUnionPush) {
            x0 <- rawX0
            break
          }
          k <- k + 1L
        }
      }
      occupied <- c(individualOccupied, unionOccupied)
      while (length(occupied) > 0L && any(abs(occupied - x0) < 1e-9)) {
        x0 <- x0 + 1e-3
      }
      unitX[[u]] <- x0
      placedAtGen[[g]] <- c(placedAtGen[[g]], unname(x0))
    }
  }

  dupIds <- if (nrow(duplicates) > 0L) duplicates$id else character(0L)
  if (length(dupIds) > 0L) {
    tier3X <- c(tier3X, stats::setNames(numeric(length(dupIds)), dupIds))
    tier3Gen <- c(tier3Gen, stats::setNames(integer(length(dupIds)), dupIds))
    for (i in seq_len(nrow(duplicates))) {
      dupId <- duplicates$id[i]
      unitId <- duplicates$matingUnitId[i]
      tier3X[[dupId]] <- derivedX(unitId, duplicates$realId[i], isB1 = FALSE)
      tier3Gen[[dupId]] <- unname(matingUnits$gen[matingUnits$id == unitId])
    }
    tier3X[dupIds] <-
      .deCollideIndividualPoints(dupIds, tier3Gen[dupIds],
                                  seedIndividuals = tier3X[b1Ids])

    for (dupId in dupIds) {
      unitId <- duplicates$matingUnitId[duplicates$id == dupId]
      g <- tier3Gen[[dupId]]
      unrelatedUnionsAtGen <- unitX[xDerivableUnits$id[
        xDerivableUnits$gen == g & xDerivableUnits$id != unitId]]
      unrelatedUnionsAtGen <- unrelatedUnionsAtGen[!is.na(unrelatedUnionsAtGen)]
      ownParents <- c(anchorOf[[unitId]], nonAnchorOf[[unitId]])
      unrelatedIndividualsAtGen <- c(tier1X[dispGenOf == g],
                                      tier3X[b1Ids[tier3Gen[b1Ids] == g]])
      unrelatedIndividualsAtGen <- unrelatedIndividualsAtGen[
        !is.na(unrelatedIndividualsAtGen) &
          !(names(unrelatedIndividualsAtGen) %in% ownParents)]
      if (length(unrelatedUnionsAtGen) == 0L &&
            length(unrelatedIndividualsAtGen) == 0L) next
      collidesUnrelatedUnion <- function(x0) {
        any(abs(x0 - unrelatedUnionsAtGen) < unionClearanceIndividual)
      }
      collidesUnrelatedIndividual <- function(x0) {
        length(unrelatedIndividualsAtGen) > 0L &&
          any(abs(x0 - unrelatedIndividualsAtGen) < individualClearance)
      }
      collides <- function(x0) {
        collidesUnrelatedUnion(x0) || collidesUnrelatedIndividual(x0)
      }
      x0 <- tier3X[[dupId]]
      if (collides(x0)) {
        rawX0 <- x0
        k <- 1L
        repeat {
          cand <- rawX0 + k * unionClearanceIndividual
          if (!collides(cand)) {
            x0 <- cand
            break
          }
          if (k >= .kMaxUnionPush) {
            x0 <- rawX0
            break
          }
          k <- k + 1L
        }
        tier3X[[dupId]] <- x0
      }
    }
  }
  tier3Ids <- c(b1Ids, dupIds)

  ## SPIKE EDIT 2: universal union recenter, generalizing the S652-reverted
  ## Track 7 Phase 1 mechanism (previously qualifying-only) to EVERY
  ## xDerivable unit -- "recentre EVERY union on its mate midpoint" (census
  ## Recommendation 1), not just the 34/237 qualifying ones S666 already
  ## handles via the correction pass above. Runs here, after Tier 3 and every
  ## collision-avoidance/proximity pass, so both sides' FINAL drawn x are
  ## known (mirrors where the deleted Phase 1 loop itself ran, per the
  ## R/makePedigreeDiagramData.R:1229-1247 comment block).
  sideFinalX <- function(realId, unitId) {
    if (is.na(realId)) return(NA_real_)
    if (realId %in% names(tier1X)) return(unname(tier1X[[realId]]))
    dupHit <- if (nrow(duplicates) > 0L) {
      duplicates$id[duplicates$realId == realId &
                       duplicates$matingUnitId == unitId]
    } else {
      character(0L)
    }
    if (length(dupHit) > 0L) return(unname(tier3X[[dupHit[[1L]]]]))
    if (realId %in% b1Ids && identical(b1UnitOf[[realId]], unitId)) {
      return(unname(tier3X[[realId]]))
    }
    NA_real_
  }
  for (u in xDerivableUnits$id) {
    aSide <- sideFinalX(anchorOf[[u]], u)
    mSide <- sideFinalX(nonAnchorOf[[u]], u)
    if (!is.na(aSide) && !is.na(mSide)) {
      unitX[[u]] <- (aSide + mSide) / 2L
    }
  }

  genuineIds <- names(tier1X)
  ids <- c(genuineIds, unitIds, tier3Ids)
  x <- c(unname(tier1X[genuineIds]), unname(unitX[unitIds]),
         unname(tier3X[tier3Ids]))
  gen <- c(unname(dispGenOf[genuineIds]), unname(matingUnits$gen),
           unname(tier3Gen[tier3Ids]))
  data.frame(id = ids, x = x, gen = gen, stringsAsFactors = FALSE)
}

## ---- pipeline replicas ----------------------------------------------------
## runPipeline() = shipped (BEFORE); runPipelineSpike() = spiked (AFTER).
## Both otherwise identical, both self-checked: BEFORE against the exported
## function's own output (must match, or the census itself would have been
## measuring the wrong drawing); AFTER against BEFORE, printing how many
## nodes actually MOVED (never assumed -- a "0 moved" spike run would mean
## the edits are inert, not that the fixture is unaffected).

runPipeline <- function(ped) {
  isolated <- nprcgenekeepr:::.findIsolatedIds(ped)
  ped <- ped[!ped$id %in% isolated, , drop = FALSE]
  forest <- nprcgenekeepr:::.buildMatingUnitForest(ped)
  pos <- nprcgenekeepr:::.positionMatingUnitForest(ped, forest)
  direct <- suppressMessages(makePedigreeMatingLayout(ped,
    edgeStyle = "direct"))
  waypoints <- nprcgenekeepr:::.addRectilinearWaypoints(direct$nodes,
    direct$edges, forest, pos)
  resolved <- nprcgenekeepr:::.resolveEdgeNodeCollisions(waypoints$nodes,
    waypoints$edges)
  shipped <- suppressWarnings(suppressMessages(
    makePedigreeMatingLayout(ped, edgeStyle = "rectilinear")))
  stopifnot(
    identical(shipped$nodes[, c("id", "x", "y")],
      resolved$nodes[, c("id", "x", "y")]),
    identical(shipped$edges[, c("from", "to")],
      resolved$edges[, c("from", "to")])
  )
  list(ped = ped, isolated = isolated, forest = forest, pos = pos,
    preNodes = waypoints$nodes, preEdges = waypoints$edges,
    nodes = resolved$nodes, edges = resolved$edges,
    residuals = resolved$residuals)
}

## IMPORTANT (found live, this session): makePedigreeMatingLayout() calls
## .positionMatingUnitForest() INTERNALLY (R/makePedigreeDiagramData.R:1682)
## to build its own 'direct'-style nodes/edges -- calling the exported
## function directly, as the census script's runPipeline() does, therefore
## re-derives positions via the SHIPPED engine regardless of any 'pos' this
## script computes separately. A first draft of this script computed 'pos'
## via .positionMatingUnitForestSpike() but still called the exported
## makePedigreeMatingLayout() for the 'direct' step -- the six detectors
## showed byte-identical before/after counts on every fixture despite nodes
## visibly moving (nMoved > 0), which is exactly what that bug produces:
## the moved 'pos' was computed but never actually reached the rendered
## nodes. Caught by checking nMoved against the class counts BEFORE trusting
## either, not by assuming a "no effect" result was itself the finding.
##
## Fix: temporarily replace the namespace's OWN .positionMatingUnitForest
## binding with the spike engine (assignInNamespace(), restored via
## on.exit() before this function returns either way) so every internal
## caller -- makePedigreeMatingLayout() included -- uses the spike engine
## for the duration of this one pipeline run. Verified directly (interactive
## probe, not assumed) that assignInNamespace() takes effect on a
## pkgload::load_all()-loaded package and that a call made from INSIDE an
## already-defined package function (not just top-level script code) picks
## up the patched binding.
runPipelineSpike <- function(ped, baseline) {
  isolated <- nprcgenekeepr:::.findIsolatedIds(ped)
  ped <- ped[!ped$id %in% isolated, , drop = FALSE]
  forest <- nprcgenekeepr:::.buildMatingUnitForest(ped)
  origPositionFn <- nprcgenekeepr:::.positionMatingUnitForest
  assignInNamespace(".positionMatingUnitForest",
    .positionMatingUnitForestSpike, ns = "nprcgenekeepr")
  on.exit(assignInNamespace(".positionMatingUnitForest", origPositionFn,
    ns = "nprcgenekeepr"), add = TRUE)
  pos <- nprcgenekeepr:::.positionMatingUnitForest(ped, forest)
  direct <- suppressMessages(makePedigreeMatingLayout(ped,
    edgeStyle = "direct"))
  waypoints <- nprcgenekeepr:::.addRectilinearWaypoints(direct$nodes,
    direct$edges, forest, pos)
  resolved <- nprcgenekeepr:::.resolveEdgeNodeCollisions(waypoints$nodes,
    waypoints$edges)
  ## Self-check: 'direct' and the manually-replicated 'resolved' must agree
  ## with a fresh rectilinear call made WHILE STILL PATCHED -- confirms this
  ## replica is internally consistent with the (patched) engine, the same
  ## discipline runPipeline() applies to the shipped engine above. This is
  ## NOT a "matches production" check (by design, the spike diverges from
  ## production) -- it only rules out a replica bug independent of the
  ## engine swap itself.
  rectilinearWhilePatched <- suppressWarnings(suppressMessages(
    makePedigreeMatingLayout(ped, edgeStyle = "rectilinear")))
  stopifnot(
    identical(rectilinearWhilePatched$nodes[, c("id", "x", "y")],
      resolved$nodes[, c("id", "x", "y")]),
    identical(rectilinearWhilePatched$edges[, c("from", "to")],
      resolved$edges[, c("from", "to")])
  )
  common <- intersect(pos$id, baseline$pos$id)
  movedIds <- common[abs(pos$x[match(common, pos$id)] -
    baseline$pos$x[match(common, baseline$pos$id)]) > 1e-9]
  list(ped = ped, isolated = isolated, forest = forest, pos = pos,
    preNodes = waypoints$nodes, preEdges = waypoints$edges,
    nodes = resolved$nodes, edges = resolved$edges,
    residuals = resolved$residuals, nMoved = length(movedIds))
}

## ---- node helpers (verbatim copy) -----------------------------------------

nodeKind <- function(ids) {
  kind <- rep("individual", length(ids))
  kind[startsWith(ids, "__union_")] <- "union"
  kind[startsWith(ids, "__dup_")] <- "duplicate"
  kind[grepl("^__(drop|bar|proj|jog)_", ids)] <- "waypoint"
  kind
}

realIdOf <- function(ids, forest) {
  out <- ids
  dupIdx <- match(ids, forest$duplicates$id)
  isDup <- !is.na(dupIdx)
  out[isDup] <- forest$duplicates$realId[dupIdx[isDup]]
  out[nodeKind(ids) %in% c("union", "waypoint")] <- NA_character_
  out
}

pairKey <- function(a, b) {
  paste(sort(c(a, b)), collapse = "")
}

pairRelation <- function(a, b, forest) {
  mu <- forest$matingUnits
  mateKeys <- unlist(Map(pairKey, mu$sire, mu$dam), use.names = FALSE)
  ka <- nodeKind(a)
  kb <- nodeKind(b)
  ra <- realIdOf(a, forest)
  rb <- realIdOf(b, forest)
  unionParents <- function(u) {
    row <- mu[mu$id == u, , drop = FALSE]
    c(row$sire, row$dam)
  }
  if (ka == "union" && kb == "union") {
    "union-union"
  } else if (ka == "union") {
    if (rb %in% unionParents(a)) "own-union" else "unrelated"
  } else if (kb == "union") {
    if (ra %in% unionParents(b)) "own-union" else "unrelated"
  } else if (identical(ra, rb)) {
    "self-duplicate"
  } else if (pairKey(ra, rb) %in% mateKeys) {
    "mates"
  } else {
    "unrelated"
  }
}

b1IdsOf <- function(ped, forest) {
  realIds <- as.character(ped$id)
  mu <- forest$matingUnits[!is.na(forest$matingUnits$anchor), , drop = FALSE]
  everAnchor <- unique(mu$anchor)
  neverAnchor <- setdiff(unique(c(mu$sire, mu$dam)), everAnchor)
  ce <- forest$childEdges
  hasDirectChild <- neverAnchor %in% ce$from[ce$from %in% realIds]
  sireOf <- stats::setNames(as.character(ped$sire), realIds)
  damOf <- stats::setNames(as.character(ped$dam), realIds)
  hasParent <- !is.na(sireOf[neverAnchor]) | !is.na(damOf[neverAnchor])
  hasParent[is.na(hasParent)] <- FALSE
  neverAnchor[neverAnchor %in% realIds & !hasDirectChild & !hasParent]
}

isFounder <- function(ids, ped) {
  idx <- match(ids, as.character(ped$id))
  out <- is.na(ped$sire[idx]) & is.na(ped$dam[idx])
  out[is.na(idx)] <- NA
  out
}

sideNodeOf <- function(realId, unitId, forest) {
  d <- forest$duplicates
  hit <- d$id[d$realId == realId & d$matingUnitId == unitId]
  if (length(hit) > 0L) hit[[1L]] else realId
}

emptyFindings <- function() {
  data.frame(class = character(), subclass = character(),
    idA = character(), idB = character(), idC = character(),
    row = numeric(), value = numeric(), limit = numeric(),
    relation = character(), note = character(),
    stringsAsFactors = FALSE)
}

finding <- function(class, subclass, idA, idB = NA_character_,
                    idC = NA_character_, row = NA_real_, value = NA_real_,
                    limit = NA_real_, relation = NA_character_,
                    note = NA_character_) {
  data.frame(class = class, subclass = subclass, idA = idA, idB = idB,
    idC = idC, row = row, value = value, limit = limit,
    relation = relation, note = note, stringsAsFactors = FALSE)
}

bindFindings <- function(rows) {
  if (length(rows) == 0L) emptyFindings() else do.call(rbind, rows)
}

## ---- detectors (verbatim copy) --------------------------------------------

censusOverlaps <- function(nodes, forest) {
  vis <- nodes[nodes$size > 0L, , drop = FALSE]
  rows <- list()
  for (y in unique(vis$y)) {
    r <- vis[vis$y == y, , drop = FALSE]
    r <- r[order(r$x), , drop = FALSE]
    n <- nrow(r)
    if (n < 2L) next
    for (i in seq_len(n - 1L)) {
      for (j in (i + 1L):n) {
        d <- r$x[j] - r$x[i]
        if (d >= 2L * max(vis$size)) break
        lim <- r$size[i] + r$size[j]
        if (d < lim - eps) {
          sub <- "overlap"
        } else if (abs(d - lim) < 1e-6) {
          sub <- "touch"
        } else {
          next
        }
        rows[[length(rows) + 1L]] <- finding("a", sub, r$id[i], r$id[j],
          row = y / yScale, value = d, limit = lim,
          relation = pairRelation(r$id[i], r$id[j], forest),
          note = paste(nodeKind(r$id[i]), nodeKind(r$id[j]), sep = "-"))
      }
    }
  }
  bindFindings(rows)
}

censusUnionCentring <- function(nodes, forest, ped) {
  mu <- forest$matingUnits
  xOf <- stats::setNames(nodes$x, nodes$id)
  yOf <- stats::setNames(nodes$y, nodes$id)
  b1 <- b1IdsOf(ped, forest)
  dotClear <- 25L + 6L
  rows <- list()
  for (u in seq_len(nrow(mu))) {
    if (is.na(mu$anchor[u])) next
    unit <- mu$id[u]
    a <- sideNodeOf(mu$anchor[u], unit, forest)
    m <- sideNodeOf(mu$nonAnchor[u], unit, forest)
    if (!all(c(a, m, unit) %in% names(xOf))) next
    if (yOf[[a]] != yOf[[unit]] || yOf[[m]] != yOf[[unit]]) next
    mid <- (xOf[[a]] + xOf[[m]]) / 2L
    dev <- xOf[[unit]] - mid
    if (abs(dev) < 1e-6) next
    lo <- min(xOf[[a]], xOf[[m]])
    hi <- max(xOf[[a]], xOf[[m]])
    sub <- if (abs(xOf[[unit]] - xOf[[a]]) < dotClear ||
                 abs(xOf[[unit]] - xOf[[m]]) < dotClear) {
      "on-a-mate"
    } else if (xOf[[unit]] < lo || xOf[[unit]] > hi) {
      "outside-mate-span"
    } else {
      "off-centre"
    }
    mateKind <- if (mu$nonAnchor[u] %in% b1) "B1" else "genuine"
    rows[[length(rows) + 1L]] <- finding("b", sub, unit, a, m,
      row = yOf[[unit]] / yScale, value = dev / xScale,
      limit = (hi - lo) / xScale,
      relation = mateKind,
      note = sprintf("anchor founder: %s",
        isFounder(mu$anchor[u], ped)))
  }
  bindFindings(rows)
}

adjacencyOf <- function(edges) {
  split(c(edges$to, edges$from), c(edges$from, edges$to))
}

isCurved <- function(edges) {
  if ("smooth.enabled" %in% names(edges)) {
    se <- edges$smooth.enabled
    !is.na(se) & se
  } else {
    rep(FALSE, nrow(edges))
  }
}

sameRowInteriorHits <- function(nodes, edges) {
  xOf <- as.list(stats::setNames(nodes$x, nodes$id))
  yOf <- as.list(stats::setNames(nodes$y, nodes$id))
  vis <- nodes[nodes$size > 0L, , drop = FALSE]
  byRow <- split(vis$id, vis$y)
  adj <- adjacencyOf(edges)
  curved <- isCurved(edges)
  rows <- list()
  for (i in seq_len(nrow(edges))) {
    f <- edges$from[[i]]
    t <- edges$to[[i]]
    yf <- yOf[[f]]
    yt <- yOf[[t]]
    if (is.null(yf) || is.null(yt) || !isTRUE(yf == yt)) next
    cands <- setdiff(byRow[[as.character(yf)]], c(f, t))
    if (length(cands) == 0L) next
    cx <- unlist(xOf[cands])
    lo <- min(xOf[[f]], xOf[[t]])
    hi <- max(xOf[[f]], xOf[[t]])
    inside <- cands[cx > lo & cx < hi]
    inside <- setdiff(inside, union(adj[[f]], adj[[t]]))
    for (o in inside) {
      rows[[length(rows) + 1L]] <- finding("c",
        if (curved[[i]]) "c-curved-chord" else "c1-samerow-interior",
        f, t, o, row = yf / yScale,
        note = paste(nodeKind(f), nodeKind(t), nodeKind(o), sep = "-"))
    }
  }
  bindFindings(rows)
}

segmentDistance <- function(px, py, x1, y1, x2, y2) {
  dx <- x2 - x1
  dy <- y2 - y1
  len2 <- dx * dx + dy * dy
  tt <- if (len2 == 0L) {
    rep(0L, length(px))
  } else {
    pmin(1L, pmax(0L, ((px - x1) * dx + (py - y1) * dy) / len2))
  }
  sqrt((px - (x1 + tt * dx))^2L + (py - (y1 + tt * dy))^2L)
}

segmentDiscHits <- function(nodes, edges) {
  xOf <- as.list(stats::setNames(nodes$x, nodes$id))
  yOf <- as.list(stats::setNames(nodes$y, nodes$id))
  vis <- nodes[nodes$size > 0L, , drop = FALSE]
  symbolRows <- unique(vis$y)
  adj <- adjacencyOf(edges)
  curved <- isCurved(edges)
  rows <- list()
  for (i in seq_len(nrow(edges))) {
    if (curved[[i]]) next
    f <- edges$from[[i]]
    t <- edges$to[[i]]
    if (is.null(xOf[[f]]) || is.null(xOf[[t]])) next
    x1 <- xOf[[f]]
    y1 <- yOf[[f]]
    x2 <- xOf[[t]]
    y2 <- yOf[[t]]
    rmax <- max(vis$size)
    box <- vis$x >= min(x1, x2) - rmax & vis$x <= max(x1, x2) + rmax &
      vis$y >= min(y1, y2) - rmax & vis$y <= max(y1, y2) + rmax
    cand <- vis[box, , drop = FALSE]
    cand <- cand[!cand$id %in% c(f, t, adj[[f]], adj[[t]]), , drop = FALSE]
    if (nrow(cand) == 0L) next
    d <- segmentDistance(cand$x, cand$y, x1, y1, x2, y2)
    hit <- d < cand$size - eps
    if (!any(hit)) next
    orient <- if (y1 == y2) {
      if (y1 %in% symbolRows) "horizontal-on-symbol-row" else
        "horizontal-offset-row"
    } else if (x1 == x2) {
      "vertical"
    } else {
      "diagonal"
    }
    for (k in which(hit)) {
      rows[[length(rows) + 1L]] <- finding("c", paste0("c2-", orient),
        f, t, cand$id[k], row = cand$y[k] / yScale, value = d[k],
        limit = cand$size[k],
        note = paste(nodeKind(f), nodeKind(t), nodeKind(cand$id[k]),
          sep = "-"))
    }
  }
  bindFindings(rows)
}

censusDuplicatePlacement <- function(nodes, forest) {
  d <- forest$duplicates
  xOf <- stats::setNames(nodes$x, nodes$id)
  yOf <- stats::setNames(nodes$y, nodes$id)
  vis <- nodes[nodes$size > 0L, , drop = FALSE]
  rows <- list()
  for (i in seq_len(nrow(d))) {
    dup <- d$id[i]
    real <- d$realId[i]
    if (!all(c(dup, real) %in% names(xOf))) next
    if (yOf[[dup]] != yOf[[real]]) next
    dist <- abs(xOf[[dup]] - xOf[[real]])
    lo <- min(xOf[[dup]], xOf[[real]])
    hi <- max(xOf[[dup]], xOf[[real]])
    between <- vis$id[vis$y == yOf[[dup]] & vis$x > lo & vis$x < hi]
    sub <- if (dist < 2L * 25L - eps) {
      "overlap"
    } else if (dist <= minSepPx + eps && length(between) == 0L) {
      "adjacent"
    } else {
      NA_character_
    }
    if (is.na(sub)) next
    rows[[length(rows) + 1L]] <- finding("d", sub, dup, real,
      idC = d$matingUnitId[i], row = yOf[[dup]] / yScale,
      value = dist, limit = minSepPx, relation = "self-duplicate")
  }
  bindFindings(rows)
}

censusMateRows <- function(nodes, forest, ped) {
  mu <- forest$matingUnits
  yOf <- stats::setNames(nodes$y, nodes$id)
  rows <- list()
  for (u in seq_len(nrow(mu))) {
    if (is.na(mu$anchor[u])) next
    unit <- mu$id[u]
    sides <- c(anchor = mu$anchor[u], nonAnchor = mu$nonAnchor[u])
    sideNodes <- vapply(sides, sideNodeOf, character(1L), unitId = unit,
      forest = forest)
    present <- sideNodes[sideNodes %in% names(yOf)]
    if (length(present) == 0L || !unit %in% names(yOf)) next
    for (s in names(present)) {
      node <- present[[s]]
      offBy <- (yOf[[node]] - yOf[[unit]]) / yScale
      if (offBy == 0L) next
      f <- isFounder(sides[[s]], ped)
      rows[[length(rows) + 1L]] <- finding("e",
        if (isTRUE(f)) "founder-off-union-row" else "nonfounder-off-union-row",
        unit, node, idC = s, row = yOf[[unit]] / yScale, value = offBy)
    }
    if (length(present) == 2L && yOf[[present[[1L]]]] != yOf[[present[[2L]]]]) {
      rows[[length(rows) + 1L]] <- finding("e", "mates-on-different-rows",
        unit, present[[1L]], present[[2L]], row = yOf[[unit]] / yScale,
        value = (yOf[[present[[1L]]]] - yOf[[present[[2L]]]]) / yScale)
    }
  }
  bindFindings(rows)
}

drawnComponents <- function(ped, forest) {
  realIds <- as.character(ped$id)
  ids <- c(realIds, forest$matingUnits$id)
  parent <- stats::setNames(ids, ids)
  find <- function(i) {
    while (parent[[i]] != i) {
      i <- parent[[i]]
    }
    i
  }
  unite <- function(a, b) {
    ra <- find(a)
    rb <- find(b)
    if (ra != rb) parent[[ra]] <<- rb
  }
  mu <- forest$matingUnits
  for (u in seq_len(nrow(mu))) {
    for (p in c(mu$sire[u], mu$dam[u])) {
      if (p %in% ids) unite(mu$id[u], p)
    }
  }
  ce <- forest$childEdges
  for (e in seq_len(nrow(ce))) {
    if (ce$from[e] %in% ids && ce$to[e] %in% ids) unite(ce$from[e], ce$to[e])
  }
  roots <- vapply(ids, find, character(1L))
  comps <- split(ids, roots)
  firstRow <- vapply(comps, function(m) {
    min(match(m, realIds), na.rm = TRUE)
  }, numeric(1L))
  comps <- unname(comps[order(firstRow)])
  d <- forest$duplicates
  lapply(comps, function(m) c(m, d$id[d$matingUnitId %in% m]))
}

censusInterleaving <- function(pos, comps) {
  rows <- list()
  if (length(comps) < 2L) return(emptyFindings())
  compOf <- stats::setNames(rep(seq_along(comps), lengths(comps)),
    unlist(comps))
  pos$comp <- compOf[pos$id]
  for (g in unique(pos$gen)) {
    r <- pos[pos$gen == g, , drop = FALSE]
    r <- r[order(r$x), , drop = FALSE]
    fams <- sort(unique(r$comp))
    if (length(fams) >= 2L) {
      span <- t(vapply(fams, function(k) range(r$x[r$comp == k]),
        numeric(2L)))
      for (i in seq_len(length(fams) - 1L)) {
        for (j in (i + 1L):length(fams)) {
          overlap <- min(span[i, 2L], span[j, 2L]) -
            max(span[i, 1L], span[j, 1L])
          if (overlap > eps) {
            rows[[length(rows) + 1L]] <- finding("f", "row-span-overlap",
              sprintf("family %d", fams[i]), sprintf("family %d", fams[j]),
              row = g, value = overlap,
              note = sprintf("%d vs %d real individuals",
                sum(!startsWith(comps[[fams[i]]], "__")),
                sum(!startsWith(comps[[fams[j]]], "__"))))
          }
        }
      }
    }
    if (nrow(r) < 2L) next
    gaps <- diff(r$x)
    cross <- r$comp[-1L] != r$comp[-nrow(r)]
    tight <- which(cross & gaps < minSepRaw - eps)
    for (k in tight) {
      rows[[length(rows) + 1L]] <- finding("f", "cross-family-row-gap",
        r$id[k], r$id[k + 1L], row = g, value = gaps[k], limit = minSepRaw,
        note = sprintf("families %d and %d", r$comp[k], r$comp[k + 1L]))
    }
  }
  bindFindings(rows)
}

## ---- reporting -------------------------------------------------------------

mdTable <- function(df, maxRows = Inf) {
  if (nrow(df) == 0L) {
    cat("(none)\n\n")
    return(invisible(NULL))
  }
  cols <- names(df)
  fmt <- function(v) {
    if (is.numeric(v)) formatC(v, digits = 4L, format = "fg", flag = "#")
    else as.character(v)
  }
  cells <- vapply(df, function(v) {
    out <- fmt(v)
    out[is.na(v)] <- ""
    out
  }, character(nrow(df)))
  if (is.null(dim(cells))) cells <- matrix(cells, nrow = 1L)
  cat("| ", paste(cols, collapse = " | "), " |\n", sep = "")
  cat("|", paste(rep("---", length(cols)), collapse = "|"), "|\n", sep = "")
  shown <- seq_len(min(nrow(df), maxRows))
  for (i in shown) {
    cat("| ", paste(cells[i, ], collapse = " | "), " |\n", sep = "")
  }
  cat("\n")
  invisible(NULL)
}

## Six-class counts for one already-run pipeline result, matching the
## census's own scoreboard columns.
classCounts <- function(p) {
  nodes <- p$nodes
  forest <- p$forest
  comps <- drawnComponents(p$ped, forest)
  fa <- censusOverlaps(nodes, forest)
  fb <- censusUnionCentring(nodes, forest, p$ped)
  fcRow <- sameRowInteriorHits(nodes, p$edges)
  fcSeg <- segmentDiscHits(nodes, p$edges)
  fd <- censusDuplicatePlacement(nodes, forest)
  fe <- censusMateRows(nodes, forest, p$ped)
  ff <- censusInterleaving(p$pos, comps)
  list(
    a = sum(fa$subclass == "overlap"),
    aTouch = sum(fa$subclass == "touch"),
    b = nrow(fb),
    c2 = nrow(fcSeg),
    cCurved = sum(fcRow$subclass == "c-curved-chord"),
    d = nrow(fd),
    e = sum(fe$subclass != "mates-on-different-rows"),
    f = nrow(ff),
    findings = rbind(fa, fb, fcRow, fcSeg, fd, fe, ff)
  )
}

## ---- run -------------------------------------------------------------------

cat("SPIKE: two-constant fix (census Recommendation 1)\n")
cat("Edit 1: derivedX() non-qualifying branch minSep * 0.4 -> minSep\n")
cat("Edit 2: universal union recenter added after Tier 3 (was qualifying-",
  "only)\n", sep = "")
cat("Edit 3: recursive self-call points at the spike engine\n\n")

allSpikeFindings <- list()
scoreRows <- list()

for (name in names(fixtures)) {
  before <- runPipeline(fixtures[[name]])
  after <- runPipelineSpike(fixtures[[name]], before)
  cb <- classCounts(before)
  ca <- classCounts(after)
  ca$findings$fixture <- rep(name, nrow(ca$findings))
  allSpikeFindings[[name]] <- ca$findings

  scoreRows[[name]] <- data.frame(
    fixture = name,
    nMoved = after$nMoved,
    a_before = cb$a, a_after = ca$a,
    aTouch_before = cb$aTouch, aTouch_after = ca$aTouch,
    b_before = cb$b, b_after = ca$b,
    c2_before = cb$c2, c2_after = ca$c2,
    cCurved_before = cb$cCurved, cCurved_after = ca$cCurved,
    d_before = cb$d, d_after = ca$d,
    e_before = cb$e, e_after = ca$e,
    f_before = cb$f, f_after = ca$f,
    stringsAsFactors = FALSE
  )
}

cat("## Scoreboard: BEFORE (shipped) -> AFTER (spiked)\n\n")
scoreDf <- do.call(rbind, scoreRows)
mdTable(scoreDf)

totBefore <- colSums(scoreDf[, grep("_before$", names(scoreDf))])
totAfter <- colSums(scoreDf[, grep("_after$", names(scoreDf))])
names(totBefore) <- sub("_before$", "", names(totBefore))
names(totAfter) <- sub("_after$", "", names(totAfter))
cat("## Totals across all 7 fixtures\n\n")
cat(sprintf("(a)+(b) before: %d -> after: %d\n",
  totBefore[["a"]] + totBefore[["b"]], totAfter[["a"]] + totAfter[["b"]]))
for (cls in c("a", "aTouch", "b", "c2", "cCurved", "d", "e", "f")) {
  cat(sprintf("  %-8s before: %6d   after: %6d   delta: %+d\n",
    cls, totBefore[[cls]], totAfter[[cls]],
    totAfter[[cls]] - totBefore[[cls]]))
}

spikeFindings <- do.call(rbind, allSpikeFindings)
spikeFindings <- spikeFindings[, c("fixture",
  setdiff(names(spikeFindings), "fixture"))]
utils::write.csv(spikeFindings, findingsCsv, row.names = FALSE)
cat(sprintf("\n%d AFTER finding row(s) written to %s\n",
  nrow(spikeFindings), findingsCsv))
