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
         toString(required), ". Missing: ",
         toString(missingCols))
  }

  shapeMap <- c(F = "dot", M = "square", H = "star", U = "triangle")
  shapes <- unname(shapeMap[as.character(ped$sex)])
  shapes[is.na(shapes)] <- "diamond"

  # nolint start: commented_code_linter, nonportable_path_linter.
  # Same sex vocabulary as the Diagram tab's own shape-to-sex legend (issue
  # #132, R/modPedigree.R) -- an unmapped sex code falls back to its
  # "Other / Unrecorded" label, not just "diamond" shape.
  sexLabelMap <- c(F = "Female", M = "Male", H = "Hermaphrodite",
                    U = "Unknown")
  sexLabels <- unname(sexLabelMap[as.character(ped$sex)])
  sexLabels[is.na(sexLabels)] <- "Other / Unrecorded"
  # nolint end

  sireLabels <- ifelse(is.na(ped$sire), "Unknown", .escapeHtml(ped$sire))
  damLabels <- ifelse(is.na(ped$dam), "Unknown", .escapeHtml(ped$dam))

  titles <- sprintf(
    paste0("<b>ID:</b> %s<br><b>Sex:</b> %s<br><b>Generation:</b> %s",
           "<br><b>Sire:</b> %s<br><b>Dam:</b> %s"),
    .escapeHtml(ped$id), sexLabels, ped$gen, sireLabels, damLabels
  )

  # Issue #133 (D1-D8): affected is an OPTIONAL logical column (kinship2
  # naming parity). Absent column => zero change to output below (D1/§4
  # backward-compat contract). Coerce defensively via as.logical() rather
  # than assume a clean logical input -- affected is not yet a
  # qcStudbook()-recognized column, so a raw CSV import could hand it a
  # character/other value; anything that doesn't parse becomes NA, matching
  # kinship2's own NA-tolerant contract rather than erroring.
  hasAffected <- "affected" %in% names(ped)
  if (hasAffected) {
    affected <- as.logical(ped$affected)
    titles <- paste0(titles,
                      sprintf("<br><b>Affected:</b> %s",
                              .affectedLabel(affected)))
  }

  nodes <- data.frame(
    id = ped$id,
    label = ped$id,
    shape = shapes,
    level = ped$gen,
    title = titles,
    stringsAsFactors = FALSE
  )
  if (hasAffected) {
    # D3 Option 1: single dominant-trait color, only affected == TRUE gets
    # a fill (D8 color, Okabe-Ito reddish-purple -- colorblind-safe,
    # distinct from both the GVA heatmap's red/yellow/green risk convention
    # and the existing #2B7CE9 waypoint-edge blue). FALSE/NA leave
    # color.background NA, i.e. vis.js's own default.
    nodes$color.background <- .affectedColor(affected)
  }

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

#' Map an affected-status vector to a vis.js node fill color (issue #133 D8)
#'
#' \code{TRUE} gets the D8 accent color; \code{FALSE}/\code{NA} leave no
#' override (vis.js's own default). Shared by both
#' \code{\link{makePedigreeDiagramData}} and
#' \code{\link{makePedigreeMatingLayout}} (a small pure leaf utility, unlike
#' the two functions' own deliberately-duplicated node-building logic --
#' same sharing precedent as \code{.escapeHtml()} above).
#'
#' @param affected logical vector, \code{NA} allowed.
#' @return character vector, \code{NA_character_} where no color override
#'   applies.
#' @noRd
.affectedColor <- function(affected) {
  ifelse(!is.na(affected) & affected, "#CC79A7", NA_character_)
}

#' Map an affected-status vector to a human-readable Yes/No/Unknown label
#' (issue #133 D3 Option 0)
#'
#' @param affected logical vector, \code{NA} allowed.
#' @return character vector: \code{"Yes"}, \code{"No"}, or \code{"Unknown"}.
#' @noRd
.affectedLabel <- function(affected) {
  label <- c("No", "Yes")[as.integer(affected) + 1L]
  label[is.na(affected)] <- "Unknown"
  label
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
#' When NEITHER parent of a mating unit has its own row in \code{ped}
#' (both dangling, issue #154), there is no individual to recursively
#' position as anchor -- \code{anchor}/\code{nonAnchor} are \code{NA}
#' rather than an arbitrarily-picked dangling id, and
#' \code{\link{.positionMatingUnitForest}} treats such a unit as its own
#' independent root instead of trying to reach it via a (nonexistent)
#' anchor individual.
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
#'   \code{sire}, \code{dam}, \code{anchor}, \code{nonAnchor} --
#'   \code{anchor}/\code{nonAnchor} both \code{NA} when neither parent has
#'   its own row in \code{ped} --, \code{gen});
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
  reserved <- grepl("^__union_|^__dup_|^__drop_|^__bar_|^__proj_", ids)
  if (any(reserved)) {
    stop(".buildMatingUnitForest() found real id(s) using a reserved ",
         "'__union_'/'__dup_'/'__drop_'/'__bar_'/'__proj_' prefix, which ",
         "must be unique to package-generated nodes: ",
         toString(ids[reserved]))
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
      # A referenced parent with no own row in this (possibly
      # focal-animal-trimmed, addBackParents = FALSE) view has no known
      # -parent information here -- treat as a founder rather than
      # letting NA propagate into a TRUE/FALSE comparison (found live,
      # S461: R/modPedigree.R's own trim feature keeps a blood relative's
      # row but not that relative's own mate's row).
      if (is.na(idx)) return(TRUE)
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
      p1Real <- p1 %in% ids
      p2Real <- p2 %in% ids
      # A dangling parent (no own row here) can never anchor -- there is
      # no individual to recursively position for them (D3 only
      # positions real ids). Their real mate wins outright, regardless of
      # "used" status (found live, S461). When NEITHER parent is real
      # (issue #154), there is no positionable anchor at all -- anchor/
      # nonAnchor are left NA rather than arbitrarily forcing a dangling
      # id into anchor (which .positionMatingUnitForest()'s recursive
      # descent could then never reach).
      winner <- if (!p1Real && !p2Real) {
        NA_character_
      } else if (p1Real != p2Real) {
        if (p1Real) p1 else p2
      } else {
        p1Used <- used[[p1]]
        p2Used <- used[[p2]]
        # p1Used-xor-p2Used: the unused one wins by elimination. Otherwise
        # (neither used -- the normal case -- or both already used
        # elsewhere -- the rare collision D3 step 2 explicitly allows) the
        # same D2 comparison decides, since preferAnchor() doesn't consult
        # "used" status at all.
        if (p1Used && !p2Used) {
          p2
        } else if (p2Used && !p1Used) {
          p1
        } else if (preferAnchor(p1, p2)) {
          p1
        } else {
          p2
        }
      }
      if (!is.na(winner)) {
        used[[winner]] <- TRUE
      }
      anchorOf[u] <- winner
      nonAnchorOf[u] <- if (is.na(winner)) {
        NA_character_
      } else if (identical(winner, p1)) {
        p2
      } else {
        p1
      }
    }

    # A dangling parent's own gen is unknown here -- fall back to
    # whichever known parent's gen is available (na.rm = TRUE). If BOTH
    # are dangling (issue #154), pmax(NA, NA, na.rm = TRUE) returns NA,
    # not -Inf, so both are covered explicitly rather than relying on
    # is.infinite() alone.
    unitGen <- pmax(unname(genOf[unitSire]), unname(genOf[unitDam]),
                     na.rm = TRUE)
    unitGen[is.na(unitGen) | is.infinite(unitGen)] <- 0L

    matingUnits <- data.frame(
      id = unionIds, sire = unitSire, dam = unitDam,
      anchor = anchorOf, nonAnchor = nonAnchorOf,
      gen = unitGen,
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

  ## A real individual with NA gen (issue #154 -- defensive; not currently
  ## reachable via findGeneration()'s own contract) is treated as
  ## generation 0 rather than propagating NA into maxGen/contour indexing
  ## below.
  ped$gen[is.na(ped$gen)] <- 0L

  matingUnits <- forest$matingUnits
  duplicates <- forest$duplicates
  childEdges <- forest$childEdges
  unitIds <- matingUnits$id
  realIds <- as.character(ped$id)
  genOf <- stats::setNames(ped$gen, realIds)

  ## A sire/dam value with no own row in 'ped' (a dangling reference --
  ## e.g. a focal-animal-trimmed pedigree, R/modPedigree.R's own
  ## trimPedigree(..., addBackParents = FALSE), keeps a blood relative's
  ## row but not that relative's own mate's row) has no gen of its own
  ## here. Back-fill from the one mating unit .buildMatingUnitForest()
  ## already knows them by (.buildMatingUnitForest() guarantees such an
  ## individual is never an anchor, so they need only a free-pass/
  ## duplicate leaf gen, never a recursively-positioned one). Found live,
  ## S461.
  danglingIds <- setdiff(c(matingUnits$sire, matingUnits$dam), realIds)
  if (length(danglingIds) > 0L) {
    fallbackGen <- vapply(danglingIds, function(x) {
      matingUnits$gen[matingUnits$sire == x | matingUnits$dam == x][1L]
    }, numeric(1L))
    genOf <- c(genOf, stats::setNames(fallbackGen, danglingIds))
  }

  unitGenOf <- stats::setNames(matingUnits$gen, unitIds)
  maxGen <- max(ped$gen, if (nrow(matingUnits) > 0L) {
    matingUnits$gen
  } else {
    0L
  }, na.rm = TRUE)
  if (!is.finite(maxGen)) maxGen <- 0L
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
  ## Orphan units (issue #154 -- both sire and dam dangling, anchor = NA)
  ## are excluded from the sire/dam pool feeding this: there is no real
  ## anchor to contrast a "non-anchor side" against, and both of an
  ## orphan unit's (dangling) parents are handled instead by that unit's
  ## own root-level positioning below, not as a free-pass leaf of it.
  anchoredUnits <- matingUnits[!is.na(matingUnits$anchor), , drop = FALSE]
  everAnchor <- unique(anchoredUnits$anchor)
  nonAnchorSides <- c(anchoredUnits$sire, anchoredUnits$dam)
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

  ## issue #144 fix: an anchor's EFFECTIVE gen (used for its own contour
  ## row-reservation and, below, its displayed gen) is max(its own raw
  ## ped$gen, the gen of every mating unit it anchors) -- not its raw
  ## ped$gen alone, which mis-positions an anchor whose personal gen is
  ## shallower than a unit it anchors (51/237 real-fixture mating units).
  ## Degrades to genOf[[id]] unchanged for every individual who never
  ## anchors anything (max() over an empty unitGenOf slice plus the scalar
  ## returns the scalar).
  anchorUnitsOf <- split(matingUnits$id, matingUnits$anchor)
  effGenOf <- genOf
  for (aid in names(anchorUnitsOf)) {
    effGenOf[[aid]] <- max(genOf[[aid]], unitGenOf[anchorUnitsOf[[aid]]])
  }

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
        leafContour(unitGenOf[[unitId]])
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
    ## %in%, not == : matingUnits$anchor can be NA for an orphan unit
    ## (issue #154, both parents dangling) -- NA == id is NA, which would
    ## select an NA element from matingUnits$id and recurse into it
    ## indefinitely; id is always a real, non-NA individual here, and
    ## %in% treats an NA anchor as simply "not a match".
    unitSub <- matingUnits$id[matingUnits$anchor %in% id]
    directSub <- childEdges$to[childEdges$from == id &
                                  !(childEdges$from %in% unitIds)]
    subIds <- c(unitSub, directSub)
    if (length(subIds) == 0L) {
      relNode[[id]] <- list(childIds = character(0L),
                             childOffsets = numeric(0L))
      return(leafContour(effGenOf[[id]]))
    }
    subResults <- lapply(subIds, function(sid) {
      if (sid %in% unitIds) positionUnit(sid) else positionIndividual(sid)
    })
    fin <- finalizeNode(mergeSubtrees(subResults), effGenOf[[id]])
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

  ## Orphan units (issue #154 -- both sire and dam dangling, anchor = NA)
  ## have no real anchor individual to be reached through, so they are
  ## positioned as additional top-level roots in their own right, exactly
  ## like a founder individual, via positionUnit() instead of
  ## positionIndividual().
  orphanUnitIds <- matingUnits$id[is.na(matingUnits$anchor)]

  rootResults <- c(lapply(rootIds, positionIndividual),
                    lapply(orphanUnitIds, positionUnit))
  allRootIds <- c(rootIds, orphanUnitIds)
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
  for (i in seq_along(allRootIds)) {
    assignAbs(allRootIds[i], rootMerge$xs[i])
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
      if (is.na(matingUnits$anchor[i])) {
        # Orphan unit (issue #154 -- both parents dangling): no real
        # anchor/non-anchor to average -- its own root-level position
        # (already assigned above via positionUnit()) IS its final x.
        finalUnitX[i] <- unitProvX[[matingUnits$id[i]]]
        next
      }
      anchorX <- realX[[matingUnits$anchor[i]]]
      dupRow <- which(duplicates$matingUnitId == matingUnits$id[i])
      nonAnchorX <- if (length(dupRow) == 1L) {
        dupX[dupRow]
      } else {
        # A free-pass non-anchor (real OR dangling, S461) was positioned
        # via the SAME recursive walk as everything else, but -- unlike a
        # duplicate -- has no forest$duplicates row and is not
        # necessarily in realIds, so it must be read from the
        # unrestricted absX environment, not the realIds-only realX
        # vector.
        absX[[matingUnits$nonAnchor[i]]]
      }
      finalUnitX[i] <- (anchorX + nonAnchorX) / 2L
    }
  }

  # nolint start: commented_code_linter.
  ## D3 step 6 correction (issue #143): every NON-ANCHOR occurrence -- a
  ## free-pass real node or a genuine duplicate -- renders at its own
  ## MATING UNIT's gen, not the underlying individual's global tree-native
  ## gen (which can legitimately differ, e.g. a founder marrying into a
  ## later generation). The intersect(freePassIds, realIds) guard is
  ## required: freePassIds can contain dangling ids (no own row in 'ped',
  ## S461) that are absent from realIds -- indexing dispGenOf by such an id
  ## would silently APPEND rather than error, misaligning it with
  ## realIds/nodes$id.
  # nolint end
  dispGenOf <- genOf[realIds]
  realFreePassIds <- intersect(freePassIds, realIds)
  if (length(realFreePassIds) > 0L) {
    dispGenOf[realFreePassIds] <-
      unname(unitGenOf[freePassUnitOf[realFreePassIds]])
  }
  ## D3 step 6 correction (issue #144): an ANCHOR occurrence renders at its
  ## own EFFECTIVE gen (effGenOf -- max of its raw gen and every unit it
  ## anchors), mirroring the free-pass override above. The
  ## intersect(names(anchorUnitsOf), realIds) guard is defensive (an
  ## anchor is never a dangling id in the current pipeline, by
  ## .buildMatingUnitForest()'s own guard, so this is not currently a live
  ## failure path) but harmless and symmetric with the free-pass guard
  ## above.
  realAnchorIds <- intersect(names(anchorUnitsOf), realIds)
  if (length(realAnchorIds) > 0L) {
    dispGenOf[realAnchorIds] <- unname(effGenOf[realAnchorIds])
  }

  nodes <- data.frame(
    id = c(realIds, duplicates$id, unitIds),
    x = c(unname(realX), dupX, finalUnitX),
    gen = c(unname(dispGenOf), unname(unitGenOf[duplicates$matingUnitId]),
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

#' Combine the Option 2 mating-unit forest into visNetwork-ready diagram data
#'
#' The exported wrapper for the kinship2-parity pedigree layout (Pedigree
#' Diagram Option 2,
#' \code{docs/planning/pedigree-diagram-option2-layout-design-plan.md}).
#' Combines \code{.buildMatingUnitForest()} (D1/D2) and
#' \code{.positionMatingUnitForest()} (D3/D4/D5) into the same
#' \code{list(nodes, edges)} shape \code{\link{makePedigreeDiagramData}}
#' already returns, plus the \code{duplicateNodeId -> realId} lookup table
#' D6 needs. \code{\link{makePedigreeDiagramData}} itself is unaffected --
#' this is an additive sibling function (Migration Path step 2).
#'
#' Mating-unit nodes render as a small, unlabeled dot with an
#' offspring-count tooltip -- visually distinct from the 5 sex-coded
#' shapes without a dedicated legend entry (D6, verified via a live
#' \code{chromote} render this session). Duplicate nodes keep their real
#' individual's own shape/label/tooltip content (plus a duplicate-
#' occurrence cue) so they read as that individual, connected to it by a
#' dashed edge. Edges are direct parent -> mating-unit and mating-unit ->
#' child segments (owner-directed, S461) -- not the fully rectilinear
#' mate-line/sibship-bar waypoint style S457's original Case C2
#' proof-of-concept used; that style is tracked as a deferred, additive
#' follow-up (issue #142) rather than built speculatively here.
#'
#' @param ped data frame with \code{id}, \code{sire}, \code{dam},
#'   \code{sex}, and \code{gen} columns, same contract as
#'   \code{\link{makePedigreeDiagramData}}.
#' @param edgeStyle one of \code{"direct"} (default -- a straight edge from
#'   each parent to their mating unit and from each mating unit to each
#'   child, matching this function's own original, still-default behavior)
#'   or \code{"rectilinear"} (issue #142 -- routes mate-line and sibship-bar
#'   edges through invisible waypoint nodes via
#'   \code{.addRectilinearWaypoints()} so they render as a strict right
#'   angle, kinship2-style, instead of a direct diagonal/straight segment).
#' @return A list with \code{nodes} (\code{id}, \code{label}, \code{shape},
#'   \code{title}, \code{size}, \code{x}, \code{y}), \code{edges}
#'   (\code{from}, \code{to}, \code{dashes}), and \code{duplicateToReal} (a
#'   named character vector, duplicate node id -> real individual id).
#'   Under \code{edgeStyle = "rectilinear"}, \code{nodes} gains
#'   \code{color.background}/\code{color.border} and \code{edges} gains
#'   \code{color} (see \code{.addRectilinearWaypoints()}).
#'
#' @examples
#' library(nprcgenekeepr)
#' layout <- makePedigreeMatingLayout(nprcgenekeepr::examplePedigree)
#'
#' @export
makePedigreeMatingLayout <- function(ped, edgeStyle = c("direct",
                                                          "rectilinear")) {
  if (!is.data.frame(ped)) {
    stop("makePedigreeMatingLayout() requires 'ped' to be a data frame.")
  }
  required <- c("id", "sire", "dam", "sex", "gen")
  missingCols <- setdiff(required, names(ped))
  if (length(missingCols) > 0L) {
    stop("makePedigreeMatingLayout() requires 'ped' to have columns: ",
         toString(required), ". Missing: ", toString(missingCols))
  }
  edgeStyle <- match.arg(edgeStyle)

  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  matingUnits <- forest$matingUnits
  duplicates <- forest$duplicates
  childEdges <- forest$childEdges
  unitIds <- matingUnits$id
  dupIds <- duplicates$id
  realIds <- as.character(ped$id)

  ## Empirically chosen this session via a chromote render of the real
  ## GA204Z/8LKBV9 loop fixture and a wide fan-out fixture -- matches
  ## vis.js's own hierarchical-layout defaults (nodeSpacing ~100,
  ## levelSeparation 150) closely enough to render legibly.
  xScale <- 120L
  yScale <- 150L

  shapeMap <- c(F = "dot", M = "square", H = "star", U = "triangle")
  sexLabelMap <- c(F = "Female", M = "Male", H = "Hermaphrodite",
                    U = "Unknown")
  sexOf <- stats::setNames(as.character(ped$sex), realIds)
  sireOf <- stats::setNames(as.character(ped$sire), realIds)
  damOf <- stats::setNames(as.character(ped$dam), realIds)
  genOf <- stats::setNames(ped$gen, realIds)

  # Issue #133 (D1-D8), independent implementation of the same optional
  # affected contract makePedigreeDiagramData() gets -- this function, not
  # that one, is what the live Diagram tab actually renders
  # (R/modPedigree.R). Coerce defensively via as.logical() (see that
  # function's own comment for why).
  hasAffected <- "affected" %in% names(ped)
  affectedOf <- if (hasAffected) {
    stats::setNames(as.logical(ped$affected), realIds)
  } else {
    NULL
  }
  .affectedColorForVec <- function(ids) {
    .affectedColor(affectedOf[ids])
  }

  .shapeForVec <- function(sexCodes) {
    shapes <- unname(shapeMap[as.character(sexCodes)])
    shapes[is.na(shapes)] <- "diamond"
    shapes
  }
  .titleForIds <- function(ids) {
    sexLabel <- unname(sexLabelMap[sexOf[ids]])
    # nolint start: nonportable_path_linter.
    sexLabel[is.na(sexLabel)] <- "Other / Unrecorded"
    # nolint end
    sireLabel <- ifelse(is.na(sireOf[ids]), "Unknown", .escapeHtml(sireOf[ids]))
    damLabel <- ifelse(is.na(damOf[ids]), "Unknown", .escapeHtml(damOf[ids]))
    title <- sprintf(
      paste0("<b>ID:</b> %s<br><b>Sex:</b> %s<br><b>Generation:</b> %s",
             "<br><b>Sire:</b> %s<br><b>Dam:</b> %s"),
      .escapeHtml(ids), sexLabel, genOf[ids], sireLabel, damLabel
    )
    if (hasAffected) {
      title <- paste0(title,
                       sprintf("<br><b>Affected:</b> %s",
                               .affectedLabel(affectedOf[ids])))
    }
    title
  }

  realNodes <- data.frame(
    id = realIds, label = realIds,
    shape = .shapeForVec(sexOf[realIds]),
    title = .titleForIds(realIds),
    size = 25L, stringsAsFactors = FALSE
  )
  if (hasAffected) {
    realNodes$color.background <- .affectedColorForVec(realIds)
  }

  dupNodes <- if (nrow(duplicates) > 0L) {
    df <- data.frame(
      id = dupIds, label = duplicates$realId,
      shape = .shapeForVec(sexOf[duplicates$realId]),
      title = paste0(.titleForIds(duplicates$realId),
                      "<br><i>(duplicate occurrence)</i>"),
      size = 25L, stringsAsFactors = FALSE
    )
    if (hasAffected) {
      df$color.background <- .affectedColorForVec(duplicates$realId)
    }
    df
  } else {
    df <- data.frame(id = character(), label = character(),
                      shape = character(), title = character(),
                      size = numeric(), stringsAsFactors = FALSE)
    if (hasAffected) df$color.background <- character()
    df
  }

  unitNodes <- if (nrow(matingUnits) > 0L) {
    offspringCount <- vapply(
      unitIds, function(u) sum(childEdges$from == u), integer(1L)
    )
    df <- data.frame(
      id = unitIds, label = "", shape = "dot",
      title = sprintf("%d offspring", offspringCount), size = 6L,
      stringsAsFactors = FALSE
    )
    # A mating union is not an individual -- it never gets affected-status
    # coloring (D4), but the column must still exist here for rbind() to
    # align with realNodes/dupNodes when hasAffected.
    if (hasAffected) df$color.background <- NA_character_
    df
  } else {
    df <- data.frame(id = character(), label = character(),
                      shape = character(), title = character(),
                      size = numeric(), stringsAsFactors = FALSE)
    if (hasAffected) df$color.background <- character()
    df
  }

  nodes <- rbind(realNodes, dupNodes, unitNodes)
  posMatch <- match(nodes$id, pos$id)
  nodes$x <- pos$x[posMatch] * xScale
  nodes$y <- pos$gen[posMatch] * yScale

  ## D6 direct-edge mate lines (owner-directed, S461; issue #142 tracks a
  ## fuller rectilinear waypoint style as a deferred, additive follow-up):
  ## a solid edge from each parent to their mating unit's node, using the
  ## non-anchor parent's DUPLICATE id when one was placed at this unit (the
  ## node actually positioned there) -- plus Slice 1's own child edges, and
  ## a dashed connector from each duplicate to its real individual.
  mateEdges <- if (nrow(matingUnits) > 0L) {
    ## Vectorized lookup: find, for each unit's non-anchor parent, the
    ## duplicate node placed at THIS unit, if any -- falling back to the
    ## plain real id otherwise. No key separator is needed (unlike
    ## .buildMatingUnitForest()'s own pairKey, which joins two ARBITRARY
    ## real ids): matingUnitId always matches the reserved "__union_<n>"
    ## pattern, which no real id may start with, so a plain concatenation
    ## cannot collide across two different (realId, matingUnitId) pairs.
    dupKey <- paste0(duplicates$realId, duplicates$matingUnitId)
    nonAnchorKey <- paste0(matingUnits$nonAnchor, unitIds)
    dupIdx <- match(nonAnchorKey, dupKey)
    nonAnchorNodeIds <- ifelse(is.na(dupIdx), matingUnits$nonAnchor,
                                duplicates$id[dupIdx])
    data.frame(
      from = c(matingUnits$anchor, nonAnchorNodeIds),
      to = rep(unitIds, 2L),
      dashes = FALSE,
      smooth.enabled = NA, smooth.type = NA_character_,
      smooth.roundness = NA_real_,
      stringsAsFactors = FALSE
    )
  } else {
    data.frame(from = character(), to = character(), dashes = logical(),
               smooth.enabled = logical(), smooth.type = character(),
               smooth.roundness = numeric(), stringsAsFactors = FALSE)
  }

  ## Duplicate-node connectors render as a curved arc, not a straight line,
  ## matching the kinship2/reference-pedigree convention (found S468, fixed
  ## S469) -- a per-edge vis.js `smooth` override (verified against the
  ## bundled vis-network.min.js source to genuinely take precedence over
  ## the widget-level `visEdges(smooth = FALSE)` in R/modPedigree.R).
  ## Every other edge leaves these columns NA, inheriting that global
  ## smooth = FALSE default.
  dupEdges <- if (nrow(duplicates) > 0L) {
    data.frame(from = dupIds, to = duplicates$realId, dashes = TRUE,
               smooth.enabled = TRUE, smooth.type = "curvedCW",
               smooth.roundness = 0.2, stringsAsFactors = FALSE)
  } else {
    data.frame(from = character(), to = character(), dashes = logical(),
               smooth.enabled = logical(), smooth.type = character(),
               smooth.roundness = numeric(), stringsAsFactors = FALSE)
  }

  childEdgesOut <- data.frame(childEdges, dashes = FALSE,
                               smooth.enabled = NA, smooth.type = NA_character_,
                               smooth.roundness = NA_real_,
                               stringsAsFactors = FALSE)
  edges <- rbind(childEdgesOut, mateEdges, dupEdges)

  duplicateToReal <- stats::setNames(duplicates$realId, duplicates$id)

  if (edgeStyle == "rectilinear") {
    waypoints <- .addRectilinearWaypoints(nodes, edges, forest, pos)
    nodes <- waypoints$nodes
    edges <- waypoints$edges
  }

  list(nodes = nodes, edges = edges, duplicateToReal = duplicateToReal)
}

#' Insert rectilinear mate-line/sibship-bar waypoint nodes and edges
#' (Pedigree Diagram Option 2, issue #142)
#'
#' Internal helper for the fuller kinship2-style rectilinear mate-line/
#' sibship-bar edge routing
#' (\code{docs/planning/pedigree-diagram-rectilinear-waypoint-design-plan.md}
#' D1/D2/D5). A pure post-processing step: consumes the already-final
#' node/edge tables \code{\link{makePedigreeMatingLayout}} assembles (direct
#' style) plus \code{\link{.buildMatingUnitForest}}'s structural output and
#' \code{\link{.positionMatingUnitForest}}'s coordinates, and returns a new
#' node/edge pair with invisible waypoint nodes inserted so every mate-line
#' and sibship-bar edge routes as a strict right angle instead of a direct
#' diagonal/straight segment. No change to \code{.buildMatingUnitForest()},
#' \code{.positionMatingUnitForest()}, or \code{makePedigreeMatingLayout()}'s
#' own default ("direct") behavior -- this function has no call site yet
#' (Migration Path step 1; the \code{edgeStyle} parameter wiring and
#' \code{R/modPedigree.R} UI control are a later implementation slice).
#'
#' A node with vis.js's own \code{hidden = TRUE} option suppresses every
#' edge connected to it, regardless of the edge's own \code{hidden} setting
#' (confirmed live this session against the actual bundled vis.js source --
#' see the design doc's Session 465 implementation addendum). Waypoint
#' nodes are therefore made invisible via \code{size = 0} plus fully
#' transparent \code{color.background}/\code{color.border}, not
#' \code{hidden = TRUE}. vis.js edges also default to inheriting their
#' color from their own \code{from} node's border color -- every new
#' waypoint-touching edge is given an explicit \code{color} so it does not
#' silently inherit a transparent waypoint's own color.
#'
#' D1 (sibship-bar): for every distinct \code{childEdges$from} value
#' (a mating-unit id, or a single real parent id under D5), adds one
#' invisible "drop" node (at that parent/unit's own x, on the children's
#' shared row) and one invisible "bar-point" node per child (at that
#' child's own x, same row), then connects the sorted-by-x chain of
#' drop/bar-point nodes plus each bar-point down to its child -- replacing
#' the direct parent/unit -> child edge(s).
#'
#' D2 (mate-line dogleg): for each mating unit, checks the anchor side and
#' the resolved non-anchor side (the non-anchor's duplicate node at this
#' unit, if one exists, per the existing \code{mateEdges} resolution --
#' never assumes the anchor is the on-row side) independently; a side
#' already at the unit's own gen keeps its existing direct edge; a side at
#' a different gen gets a new invisible projection node (at that side's own
#' x, on the unit's row) and two edges (side -> projection, projection ->
#' unit) replacing the single direct edge.
#'
#' @param nodes the \code{nodes} data frame from
#'   \code{\link{makePedigreeMatingLayout}} (direct style).
#' @param edges the \code{edges} data frame from
#'   \code{\link{makePedigreeMatingLayout}} (direct style).
#' @param forest the list returned by \code{\link{.buildMatingUnitForest}}
#'   for this same pedigree.
#' @param pos the data frame returned by
#'   \code{\link{.positionMatingUnitForest}} for this same pedigree.
#' @return A list with \code{nodes} and \code{edges}, in the same shape as
#'   \code{\link{makePedigreeMatingLayout}}'s own return value, plus
#'   \code{color.background}/\code{color.border} columns on \code{nodes}
#'   and a \code{color} column on \code{edges} (\code{NA} on every
#'   unaffected existing row).
#' @noRd
.addRectilinearWaypoints <- function(nodes, edges, forest, pos) {
  if (!is.data.frame(nodes)) {
    stop(".addRectilinearWaypoints() requires 'nodes' to be a data frame.")
  }
  if (!is.data.frame(edges)) {
    stop(".addRectilinearWaypoints() requires 'edges' to be a data frame.")
  }
  if (!is.data.frame(pos)) {
    stop(".addRectilinearWaypoints() requires 'pos' to be a data frame.")
  }
  requiredForest <- c("matingUnits", "duplicates", "childEdges")
  missingForest <- setdiff(requiredForest, names(forest))
  if (length(missingForest) > 0L) {
    stop(".addRectilinearWaypoints() requires 'forest' to have components: ",
         toString(requiredForest), ". Missing: ", toString(missingForest))
  }

  matingUnits <- forest$matingUnits
  duplicates <- forest$duplicates
  childEdges <- forest$childEdges

  edgeColor <- "#2B7CE9"
  xOf <- stats::setNames(nodes$x, nodes$id)
  yOf <- stats::setNames(nodes$y, nodes$id)
  genOf <- stats::setNames(pos$gen, pos$id)

  newNodeList <- list()
  newEdgeList <- list()
  dropChildEdge <- rep(FALSE, nrow(edges))

  ## D1: sibship-bar waypoint chain (generalizes to D5 groups, §2.1).
  for (fromId in unique(childEdges$from)) {
    kids <- childEdges$to[childEdges$from == fromId]
    childY <- unname(yOf[[kids[1L]]])
    dropId <- sprintf("__drop_%s", fromId)
    barIds <- sprintf("__bar_%s", kids)

    barPointIds <- c(dropId, barIds)
    barPointX <- c(unname(xOf[[fromId]]), unname(xOf[kids]))
    newNodeList[[length(newNodeList) + 1L]] <- data.frame(
      id = barPointIds, x = barPointX, y = childY, stringsAsFactors = FALSE
    )

    vertEdges <- data.frame(from = c(fromId, barIds), to = c(dropId, kids),
                             stringsAsFactors = FALSE)
    ord <- order(barPointX)
    orderedIds <- barPointIds[ord]
    chainEdges <- if (length(orderedIds) > 1L) {
      data.frame(from = orderedIds[-length(orderedIds)],
                 to = orderedIds[-1L], stringsAsFactors = FALSE)
    } else {
      data.frame(from = character(), to = character(),
                 stringsAsFactors = FALSE)
    }
    newEdgeList[[length(newEdgeList) + 1L]] <- rbind(vertEdges, chainEdges)

    dropChildEdge <- dropChildEdge |
      (edges$from == fromId & edges$to %in% kids)
  }

  ## D2: mate-line dogleg for parents at a different gen than their unit.
  ## sideGen() looks up a side's gen defensively rather than via bare
  ## genOf[[id]] -- a dangling, free-pass (non-duplicated) parent has no
  ## row in 'pos' at all, by .positionMatingUnitForest()'s own contract,
  ## so it has no entry in genOf either (issue #154). NA_real_ signals
  ## "no rendered node for this side" to the loop below, which then skips
  ## the dogleg for it (nothing to project).
  sideGen <- function(id) {
    if (id %in% names(genOf)) unname(genOf[[id]]) else NA_real_
  }
  dropMateEdge <- rep(FALSE, nrow(edges))
  if (nrow(matingUnits) > 0L) {
    dupKey <- paste0(duplicates$realId, duplicates$matingUnitId)
    for (i in seq_len(nrow(matingUnits))) {
      U <- matingUnits$id[i]
      A <- matingUnits$anchor[i]
      ## Orphan unit (issue #154 -- both parents dangling, anchor = NA):
      ## no real anchor/non-anchor side exists to dogleg at all.
      if (is.na(A)) next
      Nreal <- matingUnits$nonAnchor[i]
      dupIdx <- match(paste0(Nreal, U), dupKey)
      Nnode <- if (is.na(dupIdx)) Nreal else duplicates$id[dupIdx]
      Ugen <- matingUnits$gen[i]

      sides <- list(list(nodeId = A, gen = sideGen(A)),
                    list(nodeId = Nnode, gen = sideGen(Nnode)))
      for (side in sides) {
        if (is.na(side$gen)) next
        if (identical(side$gen, Ugen)) next
        projId <- sprintf("__proj_%s_%s", side$nodeId, U)
        newNodeList[[length(newNodeList) + 1L]] <- data.frame(
          id = projId, x = unname(xOf[[side$nodeId]]), y = unname(yOf[[U]]),
          stringsAsFactors = FALSE
        )
        newEdgeList[[length(newEdgeList) + 1L]] <- data.frame(
          from = c(side$nodeId, projId), to = c(projId, U),
          stringsAsFactors = FALSE
        )
        dropMateEdge <- dropMateEdge |
          (edges$from == side$nodeId & edges$to == U)
      }
    }
  }

  keptEdges <- edges[!(dropChildEdge | dropMateEdge), , drop = FALSE]
  keptEdges$color <- rep(NA_character_, nrow(keptEdges))

  ## New waypoint edges never carry the duplicate-node-connector arc (found
  ## S468, fixed S469) -- these NA placeholders keep column alignment with
  ## `keptEdges` (which passed the direct-style `edges`' smooth.* columns
  ## through unchanged) so the rbind() below does not fail with "undefined
  ## columns selected".
  newEdges <- if (length(newEdgeList) > 0L) {
    ne <- do.call(rbind, newEdgeList)
    ne$dashes <- rep(FALSE, nrow(ne))
    ne$color <- rep(edgeColor, nrow(ne))
    ne$smooth.enabled <- NA
    ne$smooth.type <- NA_character_
    ne$smooth.roundness <- NA_real_
    ne
  } else {
    data.frame(from = character(), to = character(), dashes = logical(),
               color = character(), smooth.enabled = logical(),
               smooth.type = character(), smooth.roundness = numeric(),
               stringsAsFactors = FALSE)
  }
  finalEdges <- rbind(keptEdges, newEdges[, names(keptEdges)])

  keptNodes <- nodes
  # nolint start: commented_code_linter.
  # Issue #133: preserve a color.background/color.border already set on the
  # incoming nodes (e.g. Slice 1's own affected-status coloring) instead of
  # blanket-resetting every node to NA -- only add the column fresh when it
  # doesn't already exist, matching this function's pre-#133 behavior
  # exactly for every caller that doesn't pass pre-colored nodes.
  # nolint end
  if (!"color.background" %in% names(keptNodes)) {
    keptNodes$color.background <- rep(NA_character_, nrow(keptNodes))
  }
  if (!"color.border" %in% names(keptNodes)) {
    keptNodes$color.border <- rep(NA_character_, nrow(keptNodes))
  }

  newNodes <- if (length(newNodeList) > 0L) {
    nn <- do.call(rbind, newNodeList)
    nn$label <- rep("", nrow(nn))
    nn$shape <- rep("dot", nrow(nn))
    nn$title <- rep(NA_character_, nrow(nn))
    nn$size <- rep(0L, nrow(nn))
    nn$color.background <- rep("rgba(0,0,0,0)", nrow(nn))
    nn$color.border <- rep("rgba(0,0,0,0)", nrow(nn))
    nn
  } else {
    data.frame(id = character(), x = numeric(), y = numeric(),
               label = character(), shape = character(),
               title = character(), size = integer(),
               color.background = character(), color.border = character(),
               stringsAsFactors = FALSE)
  }
  finalNodes <- rbind(keptNodes, newNodes[, names(keptNodes)])

  list(nodes = finalNodes, edges = finalEdges)
}
