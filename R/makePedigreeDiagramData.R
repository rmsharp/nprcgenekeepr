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
