## Pedigree-drawing error census across every fixture (Session 668)
##
## Measures, for every pedigree-diagram fixture this project draws, how many
## drawing errors of each of six classes the CURRENT engine produces, and
## which node/edge ids they involve -- so the decision between "keep fixing
## one defect per session" and "move to a joint solver" (BACKLOG.md Up Next,
## owner-directed S667) can be made from counts, not impressions.
##
## The six classes (BACKLOG.md, S667):
##   (a) overlapping symbols -- two VISIBLE nodes on one rendered row whose
##       centre distance is below the sum of their radii (25 px for a real
##       or duplicate individual, 6 px for a mating-union dot; xScale 120,
##       the same render-layer constants makePedigreeMatingLayout() uses);
##   (b) a mating-union dot not centred between its two mates (the anchor's
##       node and the non-anchor's node at THIS unit -- the duplicate placed
##       there when one exists, else the real node), when both mates share
##       the union's row;
##   (c) an edge passing through an unrelated symbol -- c1: the same-row
##       straight-edge strict-interior predicate the production repair pass
##       uses, before and after that pass; c2: a general segment-vs-disc
##       test on every straight edge of any orientation (catches a jogged
##       edge that still crosses the symbol it was jogged around, a vertical
##       drop through an intermediate row, ...); plus the curved duplicate
##       connectors, whose chord is checked as a disclosed heuristic;
##   (d) a duplicate drawn overlapping (< 50 px) or adjacent to (same row,
##       <= minSep, nothing between) its own real occurrence;
##   (e) a mate drawn on a row other than its union's row (and the two
##       mates of one union on different rows), founder or not;
##   (f) family interleaving -- weakly-connected components whose x-ranges
##       overlap, or two nodes of different families closer than minSep on
##       one row.
##
## Every measurement here is written fresh and independently of the
## test-local helpers in tests/testthat/test_positionMatingUnitForest.R and
## test_resolveEdgeNodeCollisions.R (owner-directed S668: do not touch the
## pinned tests); those helpers were read as the reference for the geometry
## only. The pipeline is replicated step by step from makePedigreeMatingLayout()
## (isolated-id pre-filter, forest, positions, direct layout, rectilinear
## waypoints, collision repair) so the repair pass's own residuals and the
## pre-repair state are visible; the replica's final nodes/edges are asserted
## identical to the exported function's own rectilinear output.
##
## Run from the package root (build-ignored; not part of R CMD check,
## matching data-raw/kinship2FidelityValidation.R's own convention):
##   Rscript data-raw/pedigreeDrawingErrorCensus.R
##
## Prints a markdown scoreboard + per-fixture offending-id tables to the
## console (transcribed into docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_
## 2026-09-02.md) and writes every finding row to the CSV named in
## findingsCsv below. kinship2 is OPTIONAL: when it is installed locally
## (never a package dependency -- see the fidelity script's header), a
## kinship2 baseline is computed for the same fixtures so class (a) can be
## compared against what align.pedigree() itself achieves. No Chrome needed.

suppressMessages(pkgload::load_all(".", quiet = TRUE))

findingsCsv <- file.path("docs", "audits",
  "PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-02_findings.csv")

## Render-layer constants, mirrored from makePedigreeMatingLayout() (the
## script reads the radii off nodes$size directly; these two are only
## needed to convert between raw layout units and pixels).
xScale <- 120L
yScale <- 150L
minSepRaw <- 1L          # .positionMatingUnitForest()'s minSep
minSepPx <- minSepRaw * xScale
eps <- 1e-9

## ---- fixtures ------------------------------------------------------------

## Track B full: verbatim from data-raw/kinship2FidelityValidation.R (itself
## verbatim from tests/testthat/test_shrinkPedigree.R, sex added there).
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

## Track C: verbatim from data-raw/kinship2FidelityValidation.R.
pedC <- data.frame(
  id   = c("P1", "P2", "A", "Y", "X", "W", "C1", "C2", "GC"),
  sire = c(NA, NA, "P1", "P1", NA, NA, "A", "Y", "A"),
  dam  = c(NA, NA, "P2", "P2", NA, NA, "X", "W", "Y"),
  sex  = c("M", "F", "M", "F", "F", "M", "F", "M", "M"),
  gen  = c(0L, 0L, 1L, 1L, 3L, 1L, 4L, 2L, 2L),
  stringsAsFactors = FALSE
)

## The real 375-animal bundled fixture.
pedReal <- utils::read.csv(
  system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
    package = "nprcgenekeepr"),
  stringsAsFactors = FALSE
)

## D1/D2/D3: verbatim from tests/testthat/test_positionMatingUnitForest.R
## ("S667 RED" section).
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

## ---- pipeline replica ----------------------------------------------------

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
  ## Self-check: the replica must reproduce the exported function's own
  ## rectilinear output exactly, or every number below describes a
  ## different drawing than the one the app shows.
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

## ---- node helpers --------------------------------------------------------

nodeKind <- function(ids) {
  kind <- rep("individual", length(ids))
  kind[startsWith(ids, "__union_")] <- "union"
  kind[startsWith(ids, "__dup_")] <- "duplicate"
  kind[grepl("^__(drop|bar|proj|jog)_", ids)] <- "waypoint"
  kind
}

## The real individual a drawn node stands for (NA for a union/waypoint).
realIdOf <- function(ids, forest) {
  out <- ids
  dupIdx <- match(ids, forest$duplicates$id)
  isDup <- !is.na(dupIdx)
  out[isDup] <- forest$duplicates$realId[dupIdx[isDup]]
  out[nodeKind(ids) %in% c("union", "waypoint")] <- NA_character_
  out
}

pairKey <- function(a, b) {
  paste(sort(c(a, b)), collapse = "")
}

## How two drawn nodes relate, for root-cause attribution of a collision.
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

## Free-pass ("B1") individuals: never anchor a unit, have no own parent
## edge and no own single-parent (D5) child -- the non-anchor mates Tier 3
## positions by formula rather than Tier 1's tree. Same predicate the
## engine's own tests use (test_positionMatingUnitForest.R, S662 section),
## restated here independently.
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

## The drawn node standing for each side of a unit: the duplicate placed at
## THIS unit when there is one, else the real node (mirrors the mateEdges
## resolution in makePedigreeMatingLayout()).
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

## ---- class (a): overlapping symbols -------------------------------------

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

## ---- class (b): union dot not centred between its mates -----------------

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

## ---- class (c): edges through unrelated symbols -------------------------

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

## c1: same-row straight edge with a visible, unrelated node strictly
## inside its x-span (the production repair pass's own predicate,
## reimplemented here).
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

## c2: any straight (non-curved) edge segment, any orientation, passing
## inside the disc of a visible node that is neither an endpoint nor
## graph-adjacent to one.
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

## ---- class (d): duplicate vs its own real occurrence --------------------

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

## ---- class (e): mate on a row other than its union's --------------------

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

## ---- class (f): family interleaving --------------------------------------

## Weakly-connected components of the drawn graph (real ids + unit ids
## joined by unit <-> parent and by every child edge; duplicates ride with
## their unit), in ped row order of first real member. Independent
## union-find, cross-checked against the engine's own helper by count.
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

## Interleaving is judged PER ROW, the way kinship2 packs families (per-row
## contour, not whole extent -- a shallow family may legitimately tuck in
## above a wide deep row of its neighbour, test D1): on any one row, two
## families' x-intervals must not overlap, and two nodes of different
## families must be at least minSep apart.
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

## ---- kinship2 baseline (optional) ---------------------------------------

## What kinship2::align.pedigree() itself achieves on the same pedigree:
## symbol placements per row (its duplicates), and how many adjacent
## same-row placements sit closer than its own unit spacing of 1 -- the
## nearest analogue of class (a). Dangling parents are added as founders
## (role-typed sex) and a sire/dam pair whose recorded sexes are reversed
## is swapped for kinship2's dadid-male/momid-female check, as
## data-raw/kinship2FidelityValidation.R does for Track C; anything else
## kinship2 rejects is reported as n/a with its own message.
kinship2Baseline <- function(ped) {
  if (!requireNamespace("kinship2", quietly = TRUE)) {
    return(list(ok = FALSE, note = "kinship2 not installed"))
  }
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
  res <- tryCatch({
    fixed <- kinship2::fixParents(id = id, dadid = sire, momid = dam,
      sex = sexCode, missid = NA_character_)
    kPed <- kinship2::pedigree(id = fixed$id, dadid = fixed$dadid,
      momid = fixed$momid, sex = fixed$sex, missid = NA_character_)
    al <- kinship2::align.pedigree(kPed)
    placed <- 0L
    tight <- 0L
    minGap <- Inf
    for (r in seq_len(nrow(al$nid))) {
      keep <- al$nid[r, ] > 0L
      placed <- placed + sum(keep)
      xs <- sort(al$pos[r, keep])
      if (length(xs) >= 2L) {
        gaps <- diff(xs)
        tight <- tight + sum(gaps < 1L - 1e-6)
        minGap <- min(minGap, gaps)
      }
    }
    list(ok = TRUE, nIndividuals = length(fixed$id),
      nAdded = length(fixed$id) - nrow(ped),
      nSwapped = sum(swap), placements = placed,
      duplicates = placed - length(fixed$id), tightPairs = tight,
      minGap = minGap, rows = nrow(al$nid), note = "")
  }, error = function(e) {
    list(ok = FALSE, note = conditionMessage(e))
  })
  res
}

## ---- reporting -----------------------------------------------------------

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
  if (nrow(df) > maxRows) {
    cat(sprintf("\n... %d more row(s) in %s\n", nrow(df) - maxRows,
      findingsCsv))
  }
  cat("\n")
  invisible(NULL)
}

countBy <- function(f, cls) {
  sum(f$class == cls)
}

## ---- run -----------------------------------------------------------------

allFindings <- list()
summaryRows <- list()
maxDetailRows <- 40L

for (name in names(fixtures)) {
  cat("\n\n## Fixture:", name, "\n\n")
  p <- runPipeline(fixtures[[name]])
  nodes <- p$nodes
  forest <- p$forest
  comps <- drawnComponents(p$ped, forest)
  engineComps <- nprcgenekeepr:::.forestComponents(p$ped, forest)
  stopifnot(length(comps) == length(engineComps))

  fa <- censusOverlaps(nodes, forest)
  fb <- censusUnionCentring(nodes, forest, p$ped)
  c1Pre <- sameRowInteriorHits(p$preNodes, p$preEdges)
  c1Pre <- c1Pre[c1Pre$subclass == "c1-samerow-interior", , drop = FALSE]
  fcRow <- sameRowInteriorHits(nodes, p$edges)
  fcSeg <- segmentDiscHits(nodes, p$edges)
  fd <- censusDuplicatePlacement(nodes, forest)
  fe <- censusMateRows(nodes, forest, p$ped)
  ff <- censusInterleaving(p$pos, comps)

  f <- rbind(fa, fb, fcRow, fcSeg, fd, fe, ff)
  f$fixture <- rep(name, nrow(f))
  allFindings[[name]] <- f

  k2 <- kinship2Baseline(p$ped)
  nJogs <- sum(startsWith(nodes$id, "__jog_")) %/% 2L

  summaryRows[[name]] <- data.frame(
    fixture = name,
    individuals = nrow(p$ped),
    suppressed = length(p$isolated),
    units = nrow(forest$matingUnits),
    duplicates = nrow(forest$duplicates),
    families = length(comps),
    jogs = nJogs,
    residuals = nrow(p$residuals),
    a = sum(fa$subclass == "overlap"),
    aTouch = sum(fa$subclass == "touch"),
    b = nrow(fb),
    c1Pre = nrow(unique(c1Pre[, c("idA", "idB")])),
    c1Post = nrow(unique(fcRow[fcRow$subclass == "c1-samerow-interior",
      c("idA", "idB")])),
    c2 = nrow(fcSeg),
    cCurved = sum(fcRow$subclass == "c-curved-chord"),
    d = nrow(fd),
    e = sum(fe$subclass != "mates-on-different-rows"),
    f = nrow(ff),
    rows = length(unique(nodes$y[nodes$size > 0L])),
    k2Rows = if (isTRUE(k2$ok)) k2$rows else NA_integer_,
    k2Dups = if (isTRUE(k2$ok)) k2$duplicates else NA_integer_,
    k2Tight = if (isTRUE(k2$ok)) k2$tightPairs else NA_integer_,
    k2Note = if (isTRUE(k2$ok)) {
      sprintf("%d added, %d swapped, min gap %.3f", k2$nAdded, k2$nSwapped,
        k2$minGap)
    } else {
      k2$note
    },
    stringsAsFactors = FALSE
  )

  residualKinds <- if (nrow(p$residuals) > 0L) {
    toString(sprintf("%d %s", as.integer(table(p$residuals$kind)),
      names(table(p$residuals$kind))))
  } else {
    "none"
  }
  cat(sprintf(paste0("%d individuals drawn (%d suppressed as isolated), ",
    "%d mating units, %d duplicates, %d families, %d nodes rendered, ",
    "%d jog repairs, pipeline residuals: %s.\n\n"),
    nrow(p$ped), length(p$isolated), nrow(forest$matingUnits),
    nrow(forest$duplicates), length(comps), nrow(nodes), nJogs,
    residualKinds))

  if (nrow(f) > 0L) {
    cat("### Breakdown\n\n")
    fb0 <- f
    fb0$relation[is.na(fb0$relation)] <- ""
    fb0$note[is.na(fb0$note)] <- ""
    fb0$value[is.na(fb0$value)] <- 0L
    brk <- stats::aggregate(value ~ class + subclass + relation + note,
      data = fb0, FUN = length)
    names(brk)[names(brk) == "value"] <- "n"
    med <- stats::aggregate(value ~ class + subclass + relation + note,
      data = fb0, FUN = stats::median)
    names(med)[names(med) == "value"] <- "medianValue"
    brk <- merge(brk, med)
    brk <- brk[order(brk$class, brk$subclass, -brk$n), , drop = FALSE]
    mdTable(brk)
  }

  show <- function(title, df, cols) {
    cat("### ", title, " -- ", nrow(df), "\n\n", sep = "")
    mdTable(df[, cols, drop = FALSE], maxRows = maxDetailRows)
  }
  show("(a) overlapping symbols", fa,
    c("subclass", "idA", "idB", "note", "relation", "row", "value", "limit"))
  show("(b) union dot off the mate midpoint (raw units; limit = mate span)",
    fb, c("subclass", "idA", "idB", "idC", "relation", "note", "row",
      "value", "limit"))
  cat(sprintf("(c1 before the repair pass: %d colliding edge(s), %d ",
    nrow(unique(c1Pre[, c("idA", "idB")])), nrow(c1Pre)),
    "edge-obstacle pair(s))\n\n", sep = "")
  show("(c) same-row interior + curved chord, AFTER the repair pass", fcRow,
    c("subclass", "idA", "idB", "idC", "note", "row"))
  show("(c2) segment inside a symbol disc, any orientation (px)", fcSeg,
    c("subclass", "idA", "idB", "idC", "note", "row", "value", "limit"))
  show("(d) duplicate overlapping or adjacent to its real occurrence (px)",
    fd, c("subclass", "idA", "idB", "idC", "row", "value", "limit"))
  show("(e) mate off its union's row (gens)", fe,
    c("subclass", "idA", "idB", "idC", "row", "value"))
  show("(f) family interleaving (raw units)", ff,
    c("subclass", "idA", "idB", "note", "row", "value", "limit"))
  if (isTRUE(k2$ok)) {
    cat(sprintf(paste0("kinship2 baseline: %d individuals (%d dangling ",
      "parents added, %d sire-dam pairs swapped), %d placements = %d ",
      "duplicates, %d same-row adjacent pairs closer than 1 unit, ",
      "min gap %.4f, %d rows (this engine draws %d symbol rows).\n\n"),
      k2$nIndividuals, k2$nAdded, k2$nSwapped, k2$placements,
      k2$duplicates, k2$tightPairs, k2$minGap, k2$rows,
      length(unique(nodes$y[nodes$size > 0L]))))
  } else {
    cat("kinship2 baseline: n/a --", k2$note, "\n\n")
  }
}

cat("\n\n## Scoreboard\n\n")
summaryDf <- do.call(rbind, summaryRows)
mdTable(summaryDf[, c("fixture", "individuals", "units", "duplicates",
  "families", "jogs", "residuals", "a", "aTouch", "b", "c1Pre", "c1Post",
  "c2", "cCurved", "d", "e", "f")])
cat("\n### kinship2 baseline\n\n")
mdTable(summaryDf[, c("fixture", "rows", "k2Rows", "duplicates", "k2Dups",
  "a", "k2Tight", "k2Note")])

findings <- do.call(rbind, allFindings)
findings <- findings[, c("fixture", setdiff(names(findings), "fixture"))]
utils::write.csv(findings, findingsCsv, row.names = FALSE)
cat(sprintf("\n%d finding row(s) written to %s\n", nrow(findings),
  findingsCsv))
