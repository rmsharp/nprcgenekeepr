## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Convert a pedigree data frame into visNetwork-ready diagram data
#'
#' Builds the node and edge tables consumed by \code{visNetwork::visNetwork()}
#' from a pedigree data frame: one node per individual, sex-coded to a node
#' shape, positioned by generation; one directed edge per known sire and one
#' per known dam, pointing from parent to child.
#'
#' @param ped data frame with \code{id}, \code{sire}, \code{dam}, \code{sex},
#'   and \code{gen} columns (\code{sire}/\code{dam} \code{NA} for unknown
#'   parents; \code{gen} an integer generation number, 0 for founders, as
#'   produced by \code{\link{findGeneration}}).
#' @return A list with two data frames: \code{nodes} (\code{id}, \code{label},
#'   \code{shape}, \code{level}, \code{title}) and \code{edges} (\code{from},
#'   \code{to}). \code{title} is an HTML hover-tooltip string (issue #135)
#'   giving ID, sex, generation, sire, and dam.
#'
#' @examples
#' library(nprcgenekeepr)
#' diagramData <- makePedigreeDiagramData(nprcgenekeepr::examplePedigree)
#'
#' @export
makePedigreeDiagramData <- function(ped) {
  if (!is.data.frame(ped)) {
    stop("makePedigreeDiagramData() requires 'ped' to be a data frame.")
  }
  required <- c("id", "sire", "dam", "sex", "gen")
  missingCols <- setdiff(required, names(ped))
  if (length(missingCols) > 0L) {
    stop("makePedigreeDiagramData() requires 'ped' to have columns: ",
         paste(required, collapse = ", "), ". Missing: ",
         paste(missingCols, collapse = ", "))
  }

  shapeMap <- c(F = "dot", M = "square", H = "star", U = "triangle")
  shapes <- unname(shapeMap[as.character(ped$sex)])
  shapes[is.na(shapes)] <- "diamond"

  # Same sex vocabulary as the Diagram tab's own shape-to-sex legend (issue
  # #132, R/modPedigree.R) -- an unmapped sex code falls back to its
  # "Other / Unrecorded" label, not just "diamond" shape.
  sexLabelMap <- c(F = "Female", M = "Male", H = "Hermaphrodite",
                    U = "Unknown")
  sexLabels <- unname(sexLabelMap[as.character(ped$sex)])
  sexLabels[is.na(sexLabels)] <- "Other / Unrecorded"

  sireLabels <- ifelse(is.na(ped$sire), "Unknown", .escapeHtml(ped$sire))
  damLabels <- ifelse(is.na(ped$dam), "Unknown", .escapeHtml(ped$dam))

  titles <- sprintf(
    paste0("<b>ID:</b> %s<br><b>Sex:</b> %s<br><b>Generation:</b> %s",
           "<br><b>Sire:</b> %s<br><b>Dam:</b> %s"),
    .escapeHtml(ped$id), sexLabels, ped$gen, sireLabels, damLabels
  )

  nodes <- data.frame(
    id = ped$id,
    label = ped$id,
    shape = shapes,
    level = ped$gen,
    title = titles,
    stringsAsFactors = FALSE
  )

  hasSire <- !is.na(ped$sire)
  hasDam <- !is.na(ped$dam)
  edges <- data.frame(
    from = c(ped$sire[hasSire], ped$dam[hasDam]),
    to = c(ped$id[hasSire], ped$id[hasDam]),
    stringsAsFactors = FALSE
  )

  list(nodes = nodes, edges = edges)
}

#' Escape HTML special characters for use in a vis.js node tooltip
#'
#' vis.js renders a node's \code{title} field as innerHTML, so raw
#' \code{&}/\code{<}/\code{>} characters in an id/sire/dam value would
#' otherwise corrupt the tooltip markup (issue #135).
#'
#' @param x character vector.
#' @return character vector with \code{&}, \code{<}, \code{>} escaped.
#' @noRd
.escapeHtml <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x
}

#' Transform a pedigree into a mating-unit forest (Option 2 layout, D1/D2)
#'
#' Internal helper for the kinship2-parity pedigree layout (Pedigree
#' Diagram Option 2,
#' \code{docs/planning/pedigree-diagram-option2-layout-design-plan.md}).
#' Performs the CraneFoot-style transformation (Makinen et al. 2005):
#' collapses every distinct \code{(sire, dam)} pair with at least one
#' recorded child into its own mating-unit node, re-parents every such
#' child to a single edge from that mating unit (instead of two edges to
#' sire and dam), and creates a duplicate node for every individual
#' occurrence beyond their own first (free) mating-unit occurrence --
#' resolving both multi-mate/half-sib fan-out and inbreeding-loop safety
#' via the same mechanism (D1). Anchor selection (D2) is deterministic,
#' not searched: prefer a non-founder parent over a founder; if tied,
#' prefer the parent with fewer total distinct mating units; remaining
#' ties broken by ascending id sort. A rare structural collision (both
#' parents of a shared mating unit already anchor a different,
#' earlier-processed unit) is resolved by letting one individual anchor a
#' second unit, matching D3 step 2's own documented allowance for this
#' case (verified against the real, bundled 375-individual fixture at
#' design time -- see the design doc's Session 459 corrections to its
#' own \sQuote{Impact Analysis} and \sQuote{Here be dragons} sections).
#'
#' This function computes structure only -- it assigns no x/y
#' coordinates. It is consumed by a future positioning function (D3, a
#' separate implementation slice).
#'
#' @param ped data frame with \code{id}, \code{sire}, \code{dam}, \code{sex},
#'   and \code{gen} columns, same contract as
#'   \code{\link{makePedigreeDiagramData}}. No real \code{id} may start
#'   with the reserved \code{"__union_"} or \code{"__dup_"} prefixes.
#' @return A list with three data frames: \code{matingUnits} (\code{id},
#'   \code{sire}, \code{dam}, \code{anchor}, \code{nonAnchor}, \code{gen});
#'   \code{duplicates} (\code{id}, \code{realId}, \code{matingUnitId});
#'   \code{childEdges} (\code{from}, \code{to} -- \code{from} is a
#'   mating-unit id, or a single known parent's real id under the D5
#'   partial-parentage fallback).
#' @noRd
.buildMatingUnitForest <- function(ped) {
  if (!is.data.frame(ped)) {
    stop(".buildMatingUnitForest() requires 'ped' to be a data frame.")
  }
  required <- c("id", "sire", "dam", "sex", "gen")
  missingCols <- setdiff(required, names(ped))
  if (length(missingCols) > 0L) {
    stop(".buildMatingUnitForest() requires 'ped' to have columns: ",
         toString(required), ". Missing: ", toString(missingCols))
  }

  ids <- as.character(ped$id)
  reserved <- grepl("^__union_|^__dup_", ids)
  if (any(reserved)) {
    stop(".buildMatingUnitForest() found real id(s) using the reserved ",
         "'__union_'/'__dup_' prefix, which must be unique to ",
         "package-generated nodes: ", toString(ids[reserved]))
  }

  sire <- as.character(ped$sire)
  dam <- as.character(ped$dam)
  hasSire <- !is.na(sire)
  hasDam <- !is.na(dam)
  hasBoth <- hasSire & hasDam
  genOf <- stats::setNames(ped$gen, ids)

  # D1 step 1: identify mating units, ordered by first-appearance row
  # order (matching D4's "data row order" determinism precedent). A
  # control-character separator (never a legal pedigree id character)
  # guarantees paste0("AB", "C") and paste0("A", "BC") key differently.
  pairKey <- rep(NA_character_, length(ids))
  pairKey[hasBoth] <- paste(sire[hasBoth], dam[hasBoth], sep = "\u0001")
  uniqueKeys <- unique(pairKey[hasBoth])
  nUnits <- length(uniqueKeys)

  if (nUnits == 0L) {
    matingUnits <- data.frame(id = character(), sire = character(),
                               dam = character(), anchor = character(),
                               nonAnchor = character(), gen = integer(),
                               stringsAsFactors = FALSE)
    duplicates <- data.frame(id = character(), realId = character(),
                              matingUnitId = character(),
                              stringsAsFactors = FALSE)
  } else {
    firstRow <- match(uniqueKeys, pairKey)
    unitSire <- sire[firstRow]
    unitDam <- dam[firstRow]
    unionIds <- sprintf("__union_%d", seq_len(nUnits))

    mateCountTab <- table(c(unitSire, unitDam))
    isFounderOf <- function(x) {
      idx <- match(x, ids)
      !hasSire[idx] & !hasDam[idx]
    }

    # D2: deterministic anchor preference between 2 candidates -- prefer
    # non-founder, then fewer total mating units, then ascending id.
    preferAnchor <- function(a, b) {
      fa <- isFounderOf(a)
      fb <- isFounderOf(b)
      if (fa != fb) return(!fa)
      ca <- mateCountTab[[a]]
      cb <- mateCountTab[[b]]
      if (ca != cb) return(ca < cb)
      a < b
    }

    parentIds <- unique(c(unitSire, unitDam))
    used <- stats::setNames(rep(FALSE, length(parentIds)), parentIds)
    anchorOf <- character(nUnits)
    nonAnchorOf <- character(nUnits)
    for (u in seq_len(nUnits)) {
      p1 <- unitSire[u]
      p2 <- unitDam[u]
      p1Used <- used[[p1]]
      p2Used <- used[[p2]]
      # p1Used-xor-p2Used: the unused one wins by elimination. Otherwise
      # (neither used -- the normal case -- or both already used
      # elsewhere -- the rare collision D3 step 2 explicitly allows) the
      # same D2 comparison decides, since preferAnchor() doesn't consult
      # "used" status at all.
      winner <- if (p1Used && !p2Used) {
        p2
      } else if (p2Used && !p1Used) {
        p1
      } else if (preferAnchor(p1, p2)) {
        p1
      } else {
        p2
      }
      used[[winner]] <- TRUE
      anchorOf[u] <- winner
      nonAnchorOf[u] <- if (identical(winner, p1)) p2 else p1
    }

    matingUnits <- data.frame(
      id = unionIds, sire = unitSire, dam = unitDam,
      anchor = anchorOf, nonAnchor = nonAnchorOf,
      gen = pmax(genOf[unitSire], genOf[unitDam]),
      stringsAsFactors = FALSE
    )

    # Duplicate assignment: an individual who never anchors any of their
    # own mating units gets their first (deterministic-order) non-anchor
    # occurrence for free; every occurrence beyond that -- and every
    # non-anchor occurrence at all, once they DO anchor somewhere -- is
    # duplicated. Combinatorially, exactly (mateCount - 1) duplicates per
    # individual in the common case; the rare double-anchor collision
    # above grants an extra free slot to whoever it affects.
    hasAnchorAnywhere <- stats::setNames(parentIds %in% unique(anchorOf),
                                   parentIds)
    freeConsumed <- stats::setNames(rep(FALSE, length(parentIds)), parentIds)
    dupCounter <- stats::setNames(rep(0L, length(parentIds)), parentIds)
    dupId <- character()
    dupRealId <- character()
    dupUnitId <- character()
    for (u in seq_len(nUnits)) {
      for (p in c(unitSire[u], unitDam[u])) {
        if (identical(anchorOf[u], p)) next
        needsDuplicate <- if (hasAnchorAnywhere[[p]]) {
          TRUE
        } else if (freeConsumed[[p]]) {
          TRUE
        } else {
          freeConsumed[[p]] <- TRUE
          FALSE
        }
        if (needsDuplicate) {
          dupCounter[[p]] <- dupCounter[[p]] + 1L
          dupId <- c(dupId, sprintf("__dup_%s_%d", p, dupCounter[[p]]))
          dupRealId <- c(dupRealId, p)
          dupUnitId <- c(dupUnitId, unionIds[u])
        }
      }
    }
    duplicates <- data.frame(id = dupId, realId = dupRealId,
                              matingUnitId = dupUnitId,
                              stringsAsFactors = FALSE)
  }

  # D1 step 3 / D5: re-parent children with both parents known to their
  # mating unit (single edge); children with exactly one known parent
  # keep today's direct one-edge fallback; a 0-parent founder gets no
  # incoming edge.
  unitOfRow <- rep(NA_character_, length(ids))
  if (nUnits > 0L) {
    unitOfRow[hasBoth] <- matingUnits$id[match(pairKey[hasBoth], uniqueKeys)]
  }
  oneParent <- xor(hasSire, hasDam)
  childEdges <- data.frame(
    from = c(unitOfRow[hasBoth],
             ifelse(hasSire[oneParent], sire[oneParent], dam[oneParent])),
    to = c(ids[hasBoth], ids[oneParent]),
    stringsAsFactors = FALSE
  )

  list(matingUnits = matingUnits, duplicates = duplicates,
       childEdges = childEdges)
}

#' Position a mating-unit forest (Option 2 layout, D3/D4/D5)
#'
#' Internal helper for the kinship2-parity pedigree layout (Pedigree
#' Diagram Option 2,
#' \code{docs/planning/pedigree-diagram-option2-layout-design-plan.md}).
#' Consumes \code{\link{.buildMatingUnitForest}}'s structural output
#' (D1/D2) and assigns final \code{x}/\code{gen} coordinates to every
#' node: a simplified Reingold-Tilford/Walker-style recursive
#' contour-merge (D3), founders ordered by their input row order (D4),
#' and the D5 one-known-parent fallback attaching directly (no
#' synthesized mating unit).
#'
#' Contour occupancy is tracked per absolute real \code{gen}, not
#' recursive tree depth, because a node's vertical position is always
#' its real \code{gen} (D3 step 6), which can differ from recursive
#' tree depth once a duplicate or "free" non-anchor individual is
#' attached deep inside another individual's own subtree -- a genuine
#' tree cannot hit this (an ancestor and its descendant are never at
#' the same depth), but this forest can, since
#' \code{\link{.buildMatingUnitForest}} deliberately re-attaches
#' individuals who belong to more than one mating unit.
#'
#' A non-anchor individual who never anchors any mating unit of their
#' own and has no directly-known (D5) child gets their one mating-unit
#' occurrence "for free" (\code{\link{.buildMatingUnitForest}} creates
#' no duplicate node for it). Such an individual is not an independent
#' tree root -- they belong to that one mating unit -- so they are
#' folded into its own children-merge as a genuine, width-reserving
#' leaf (offset to one side, matching D3 step 5's treatment of true
#' duplicate nodes), rather than positioned from an untethered offset
#' that could coincide with an unrelated node elsewhere in the forest.
#'
#' Even with gen-indexed contours, an ancestor's own position can still
#' exactly coincide with a nested duplicate/free-pass descendant's
#' position at the same gen (the envelope-based contour merge only
#' guarantees non-overlap between sibling subtrees, not between a node
#' and an arbitrarily-deep descendant re-attached at the node's own
#' gen). A final deterministic pass nudges any such exact coincidence
#' apart, for real-individual/mating-unit nodes only -- duplicate nodes
#' keep D3 step 5's own accepted "contribute no width" trade-off,
#' matching kinship2's own documented "not always successfully
#' collapsed" duplicate placement.
#'
#' @param ped data frame with \code{id}, \code{sire}, \code{dam},
#'   \code{sex}, and \code{gen} columns, same contract as
#'   \code{\link{makePedigreeDiagramData}}.
#' @param forest the list returned by \code{\link{.buildMatingUnitForest}}
#'   for this same \code{ped}.
#' @return A data frame with one row per node (\code{id}, \code{x},
#'   \code{gen}): every real individual in \code{ped}, every duplicate
#'   node in \code{forest$duplicates}, and every mating-unit node in
#'   \code{forest$matingUnits}.
#' @noRd
.positionMatingUnitForest <- function(ped, forest) {
  if (!is.data.frame(ped)) {
    stop(".positionMatingUnitForest() requires 'ped' to be a data ",
         "frame.")
  }
  required <- c("id", "sire", "dam", "sex", "gen")
  missingCols <- setdiff(required, names(ped))
  if (length(missingCols) > 0L) {
    stop(".positionMatingUnitForest() requires 'ped' to have columns: ",
         toString(required), ". Missing: ", toString(missingCols))
  }

  matingUnits <- forest$matingUnits
  duplicates <- forest$duplicates
  childEdges <- forest$childEdges
  unitIds <- matingUnits$id
  realIds <- as.character(ped$id)
  genOf <- stats::setNames(ped$gen, realIds)
  unitGenOf <- stats::setNames(matingUnits$gen, unitIds)
  maxGen <- max(ped$gen, if (nrow(matingUnits) > 0L) {
    matingUnits$gen
  } else {
    0L
  })
  minSep <- 1L

  ## D3 contour-merge machinery: occupancy tracked per absolute gen
  ## (0..maxGen), not relative recursive depth -- see @noRd above.
  leafContour <- function(gen) {
    left <- rep(Inf, maxGen + 1L)
    right <- rep(-Inf, maxGen + 1L)
    left[gen + 1L] <- 0L
    right[gen + 1L] <- 0L
    list(x = 0L, contour = list(left = left, right = right))
  }

  mergeSubtrees <- function(subResults) {
    n <- length(subResults)
    xs <- numeric(n)
    contour <- subResults[[1L]]$contour
    if (n > 1L) {
      for (i in 2L:n) {
        ci <- subResults[[i]]$contour
        finite <- is.finite(contour$right) & is.finite(ci$left)
        shift <- minSep
        if (any(finite)) {
          needed <- max(contour$right[finite] - ci$left[finite] +
                          minSep)
          shift <- max(shift, needed)
        }
        xs[i] <- shift
        contour <- list(left = pmin(contour$left, ci$left + shift),
                         right = pmax(contour$right, ci$right + shift))
      }
    }
    list(xs = xs, contour = contour)
  }

  finalizeNode <- function(merged, ownGen) {
    xs <- merged$xs
    ownX <- (xs[1L] + xs[length(xs)]) / 2L
    shiftAmt <- -ownX
    contour <- list(left = merged$contour$left + shiftAmt,
                     right = merged$contour$right + shiftAmt)
    contour$left[ownGen + 1L] <- min(contour$left[ownGen + 1L], 0L)
    contour$right[ownGen + 1L] <- max(contour$right[ownGen + 1L], 0L)
    list(ownX = ownX, childOffsets = xs - ownX, contour = contour)
  }

  ## Individuals whose one non-anchor occurrence is "free" (no
  ## duplicate node): never anchor anywhere, no D5 direct child of
  ## their own. They fold into their one unit's children-merge as an
  ## extra width-reserving leaf instead of being an independent root.
  everAnchor <- unique(matingUnits$anchor)
  nonAnchorSides <- c(matingUnits$sire, matingUnits$dam)
  neverAnchorIds <- setdiff(unique(nonAnchorSides), everAnchor)
  hasOwnDirectChild <- function(id) {
    any(childEdges$from == id & !(childEdges$from %in% unitIds))
  }
  freePassIds <- Filter(function(id) !hasOwnDirectChild(id),
                         neverAnchorIds)
  freePassUnitOf <- stats::setNames(character(length(freePassIds)),
                                     freePassIds)
  for (fp in freePassIds) {
    ownUnits <- matingUnits$id[matingUnits$sire == fp |
                                 matingUnits$dam == fp]
    dupUnits <- duplicates$matingUnitId[duplicates$realId == fp]
    freePassUnitOf[[fp]] <- setdiff(ownUnits, dupUnits)[1L]
  }
  freePassOfUnit <- split(names(freePassUnitOf), freePassUnitOf)

  ## Recursive descent (post-order): mating units recurse into their
  ## real children (plus any free-pass non-anchor parent, D3 step 5);
  ## individuals recurse into the mating units they anchor plus any D5
  ## direct child of their own.
  relNode <- new.env(parent = emptyenv())

  positionUnit <- function(unitId) {
    kidIds <- childEdges$to[childEdges$from == unitId]
    fpHere <- freePassOfUnit[[unitId]]
    subIds <- c(fpHere, kidIds)  # free-pass parent leftmost
    subResults <- lapply(subIds, function(sid) {
      if (!is.null(fpHere) && sid %in% fpHere) {
        leafContour(genOf[[sid]])
      } else {
        positionIndividual(sid)
      }
    })
    fin <- finalizeNode(mergeSubtrees(subResults), unitGenOf[[unitId]])
    relNode[[unitId]] <- list(childIds = subIds,
                               childOffsets = fin$childOffsets)
    list(x = fin$ownX, contour = fin$contour)
  }

  positionIndividual <- function(id) {
    unitSub <- matingUnits$id[matingUnits$anchor == id]
    directSub <- childEdges$to[childEdges$from == id &
                                  !(childEdges$from %in% unitIds)]
    subIds <- c(unitSub, directSub)
    if (length(subIds) == 0L) {
      relNode[[id]] <- list(childIds = character(0L),
                             childOffsets = numeric(0L))
      return(leafContour(genOf[[id]]))
    }
    subResults <- lapply(subIds, function(sid) {
      if (sid %in% unitIds) positionUnit(sid) else positionIndividual(sid)
    })
    fin <- finalizeNode(mergeSubtrees(subResults), genOf[[id]])
    relNode[[id]] <- list(childIds = subIds,
                           childOffsets = fin$childOffsets)
    list(x = fin$ownX, contour = fin$contour)
  }

  ## D4: founders (no incoming parent edge), ordered by input row
  ## order, excluding free-pass-only individuals (they attach to their
  ## one unit above, not as an independent root).
  hasParentEdge <- realIds %in% childEdges$to
  founderIds <- realIds[!hasParentEdge]
  rootIds <- setdiff(founderIds, freePassIds)
  rootIds <- rootIds[order(match(rootIds, realIds))]

  rootResults <- lapply(rootIds, positionIndividual)
  rootMerge <- mergeSubtrees(rootResults)

  ## Top-down pass: accumulate absolute x from the relative offsets
  ## recorded above.
  absX <- new.env(parent = emptyenv())
  assignAbs <- function(id, base) {
    absX[[id]] <- base
    node <- relNode[[id]]
    if (!is.null(node) && length(node$childIds) > 0L) {
      for (i in seq_along(node$childIds)) {
        assignAbs(node$childIds[i], base + node$childOffsets[i])
      }
    }
  }
  for (i in seq_along(rootIds)) {
    assignAbs(rootIds[i], rootMerge$xs[i])
  }

  realX <- vapply(realIds, function(i) absX[[i]], numeric(1L))

  ## D3 step 5 / step 4: duplicate nodes are offset adjacent to their
  ## mating unit's PROVISIONAL x (pre-finalization, children-driven);
  ## each mating unit's FINAL x is then the midpoint of its 2 parents.
  unitProvX <- stats::setNames(
    vapply(unitIds, function(u) absX[[u]], numeric(1L)), unitIds
  )

  dupX <- numeric(nrow(duplicates))
  if (nrow(duplicates) > 0L) {
    dupX <- unname(unitProvX[duplicates$matingUnitId]) + minSep * 0.4
  }

  finalUnitX <- numeric(nrow(matingUnits))
  if (nrow(matingUnits) > 0L) {
    for (i in seq_len(nrow(matingUnits))) {
      anchorX <- realX[[matingUnits$anchor[i]]]
      dupRow <- which(duplicates$matingUnitId == matingUnits$id[i])
      nonAnchorX <- if (length(dupRow) == 1L) {
        dupX[dupRow]
      } else {
        realX[[matingUnits$nonAnchor[i]]]
      }
      finalUnitX[i] <- (anchorX + nonAnchorX) / 2L
    }
  }

  nodes <- data.frame(
    id = c(realIds, duplicates$id, unitIds),
    x = c(unname(realX), dupX, finalUnitX),
    gen = c(unname(genOf[realIds]), unname(genOf[duplicates$realId]),
            matingUnits$gen),
    stringsAsFactors = FALSE
  )

  ## Final de-collision pass (real-individual/mating-unit nodes only):
  ## an ancestor's own point can exactly coincide with a nested
  ## duplicate/free-pass descendant's point at the same gen (see
  ## @noRd above); nudge apart deterministically, in (gen, id) order.
  isDuplicate <- nodes$id %in% duplicates$id
  nonDupIdx <- which(!isDuplicate)
  ord <- order(nodes$gen[nonDupIdx], nodes$id[nonDupIdx])
  nonDupIdx <- nonDupIdx[ord]
  seenAtGen <- new.env(parent = emptyenv())
  for (i in nonDupIdx) {
    genKey <- as.character(nodes$gen[i])
    used <- seenAtGen[[genKey]]
    x <- nodes$x[i]
    while (!is.null(used) && any(abs(used - x) < 1e-9)) {
      x <- x + 1e-3
    }
    nodes$x[i] <- x
    seenAtGen[[genKey]] <- c(used, x)
  }

  nodes
}
