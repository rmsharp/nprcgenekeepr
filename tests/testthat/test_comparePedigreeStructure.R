## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Tests for .extractKinship2Structure() -- Track A of the kinship2
## structural/topological comparison design (docs/planning/
## pedigree-diagram-kinship2-structural-comparison-plan.md sections 3.1/4.1).
## A pure, internal function with ZERO kinship2 dependency: it reads only
## plain id/findex/mindex vectors, so any list shaped like a kinship2
## `pedigree` object (or a hand-built stand-in) works without kinship2
## installed. Re-implements kinship2's own align.pedigree() spouselist
## derivation verbatim (plan section 1.1) -- not invented logic.
##
## Track A: .extractKinship2Structure() -- see above.
##
## Track B (this section): .extractNprcStructure() -- the nprcgenekeepr-side
## counterpart, plan sections 3.2/4.2. Input is makePedigreeMatingLayout()'s
## own direct-style return value (list(nodes, edges, duplicateToReal));
## output is the SAME shape as Track A's (list(parentChildEdges, matePairs)),
## deliberately -- .comparePedigreeStructures() (Track C) is agnostic to
## which side is kinship2 vs. nprcgenekeepr. Also includes the D-2
## edgeStyle-invariance property test: a second, test-file-only extraction
## from "rectilinear"-style output (walking __drop_/__bar_/__proj_/__jog_
## waypoint chains) must recover the identical relationship set as
## .extractNprcStructure() does from "direct"-style output on the same
## fixture -- proving D-2's foundational claim, not merely assuming it.
##
## .comparePedigreeStructures() (Track C) remains out of scope here (plan
## section 5's strict A->B->C->D order) and will get its own test_that()
## blocks, or its own file, in a future session.

## ---- test helpers (not exported, local to this file) -------------------

## Combine parentChildEdges rows into one comparable key per row, so
## assertions don't depend on row order (the algorithm builds father rows
## then mother rows; a future refactor is free to change that order).
.pcKeys <- function(pc) paste(pc$child, pc$parent, pc$role, sep = "|")

## Named vector of nChildren by unordered parent pair, for order-independent
## matePairs assertions.
.mateNChildren <- function(mp) {
  key <- paste(pmin(mp$parent1, mp$parent2), pmax(mp$parent1, mp$parent2),
               sep = "|")
  stats::setNames(mp$nChildren, key)
}

## ---- input contract / return shape --------------------------------------

test_that(
  ".extractKinship2Structure returns a list with parentChildEdges/matePairs",
  {
  ped <- list(id = c("F1", "M1", "C1"), findex = c(0L, 0L, 1L),
              mindex = c(0L, 0L, 2L))
  result <- .extractKinship2Structure(ped)
  expect_true(is.list(result))
  expect_setequal(names(result), c("parentChildEdges", "matePairs"))
  expect_true(is.data.frame(result$parentChildEdges))
  expect_true(is.data.frame(result$matePairs))
  expect_setequal(names(result$parentChildEdges), c("child", "parent",
                                                      "role"))
  expect_setequal(names(result$matePairs), c("parent1", "parent2",
                                              "nChildren"))
})

## ---- founder-only: no known parents at all ------------------------------

test_that(
  ".extractKinship2Structure gives a lone founder zero edges and zero
   mate pairs", {
  ped <- list(id = "F1", findex = 0L, mindex = 0L)
  result <- .extractKinship2Structure(ped)
  expect_equal(nrow(result$parentChildEdges), 0L)
  expect_equal(nrow(result$matePairs), 0L)
})

## ---- single-known-parent: father-only and mother-only, never both -------

test_that(
  ".extractKinship2Structure gives a single-known-parent child exactly
   one edge, and contributes no mate pair", {
  ## C1's father (F1) is known, mother is not; C2's mother (M1) is known,
  ## father is not -- neither child has "both" parents known.
  ped <- list(id = c("F1", "M1", "C1", "C2"),
              findex = c(0L, 0L, 1L, 0L),
              mindex = c(0L, 0L, 0L, 2L))
  result <- .extractKinship2Structure(ped)
  expect_setequal(.pcKeys(result$parentChildEdges),
                   c("C1|F1|father", "C2|M1|mother"))
  expect_equal(nrow(result$parentChildEdges), 2L)
  expect_equal(nrow(result$matePairs), 0L)
})

## ---- multi-mate individual + shared-parent nChildren dedup --------------

test_that(
  ".extractKinship2Structure counts nChildren once per distinct mate pair,
   not once per child", {
  ## P1 has two distinct mates: P2 (3 shared children) and P3 (1 child).
  ped <- list(
    id = c("P1", "P2", "P3", "C1", "C2", "C3", "C4"),
    findex = c(0L, 0L, 0L, 1L, 1L, 1L, 1L),
    mindex = c(0L, 0L, 0L, 2L, 2L, 2L, 3L)
  )
  result <- .extractKinship2Structure(ped)
  expect_equal(nrow(result$matePairs), 2L)
  expect_equal(.mateNChildren(result$matePairs),
               c("P1|P2" = 3L, "P1|P3" = 1L))
  expect_equal(nrow(result$parentChildEdges), 8L)  # 4 father + 4 mother rows
})

## ---- combined 7-subject/2-mating fixture --------------------------------

test_that(
  ".extractKinship2Structure handles a combined multi-mating fixture
   (7 subjects, 2 real mate pairs, differing nChildren)", {
  ## Founders A, B, C, D. A x B -> X (1 child). C x D -> Y, Z (2 children).
  ped <- list(
    id = c("A", "B", "C", "D", "X", "Y", "Z"),
    findex = c(0L, 0L, 0L, 0L, 1L, 3L, 3L),
    mindex = c(0L, 0L, 0L, 0L, 2L, 4L, 4L)
  )
  result <- .extractKinship2Structure(ped)

  ## Founders never appear as a child.
  expect_false(any(c("A", "B", "C", "D") %in% result$parentChildEdges$child))

  expect_setequal(.pcKeys(result$parentChildEdges), c(
    "X|A|father", "X|B|mother",
    "Y|C|father", "Y|D|mother",
    "Z|C|father", "Z|D|mother"
  ))
  expect_equal(nrow(result$parentChildEdges), 6L)

  expect_equal(nrow(result$matePairs), 2L)
  expect_equal(.mateNChildren(result$matePairs),
               c("A|B" = 1L, "C|D" = 2L))
})

## ===========================================================================
## Track B: .extractNprcStructure() (plan sections 3.2/4.2)
## ===========================================================================
##
## Input is makePedigreeMatingLayout(ped, edgeStyle = "direct",
## twinRelations = NULL)'s own return value. Output shape is IDENTICAL to
## Track A's -- list(parentChildEdges = data.frame(child, parent),
## matePairs = data.frame(parent1, parent2, nChildren)) -- deliberately, so
## Track C's comparator is agnostic to which side is which.

## ---- test helpers (not exported, local to this file) --------------------

## Same canonicalization idea as .pcKeys()/.mateNChildren() above, adapted to
## Track B's own (child, parent) / (parent1, parent2, nChildren) shape (no
## `role` column here -- father/mother is not part of this output contract).
.pcKeysB <- function(pc) paste(pc$child, pc$parent, sep = "|")
.mateKeysB <- function(mp) {
  paste(pmin(mp$parent1, mp$parent2), pmax(mp$parent1, mp$parent2),
        mp$nChildren, sep = "|")
}

## Founders A, B, C, D. A x B -> X (1 child). C x D -> Y, Z (2 children).
## The SAME relationships as Track A's own combined 7-subject fixture
## (above) -- reused deliberately for cross-track consistency, this time as
## a ped data.frame (id/sire/dam/sex/gen) so it can be run through the real
## makePedigreeMatingLayout().
.ped7Fixture <- function() {
  data.frame(
    id   = c("A", "B", "C", "D", "X", "Y", "Z"),
    sire = c(NA, NA, NA, NA, "A", "C", "C"),
    dam  = c(NA, NA, NA, NA, "B", "D", "D"),
    sex  = c("M", "F", "M", "F", "F", "F", "M"),
    gen  = c(0L, 0L, 0L, 0L, 1L, 1L, 1L),
    stringsAsFactors = FALSE
  )
}

## The plan's own §1.4 "Track C" dogleg fixture (9 subjects), reused
## verbatim from test_makePedigreeMatingLayout.R:1276-1283 /
## data-raw/kinship2FidelityValidation.R:234-241 (as `pedC`). A x X -> C1
## duplicates A (A's OTHER mate is Y); A x Y -> GC is a real consanguineous
## union (A and Y are half-siblings via P1/P2) -- the richest small fixture
## available: exercises duplicateToReal resolution AND a multi-mate
## individual in one shot.
.pedTrackCFixture <- function() {
  data.frame(
    id   = c("P1", "P2", "A", "Y", "X", "W", "C1", "C2", "GC"),
    sire = c(NA, NA, "P1", "P1", NA, NA, "A", "Y", "A"),
    dam  = c(NA, NA, "P2", "P2", NA, NA, "X", "W", "Y"),
    sex  = c("M", "F", "M", "F", "F", "M", "F", "M", "M"),
    gen  = c(0L, 0L, 1L, 1L, 3L, 1L, 4L, 2L, 2L),
    stringsAsFactors = FALSE
  )
}

## A single founder, no mates, no children -- makePedigreeMatingLayout()
## itself cannot build this layout (a currently-existing, pre-existing bug,
## unrelated to this plan: it crashes on ANY pedigree with zero total
## parent-child edges, "arguments imply differing number of rows: 0, 1",
## found incidentally this session -- reported, not fixed here). Hand-built
## directly in .extractNprcStructure()'s own input-contract shape instead,
## matching Track A's own founder-only fixture precedent (a hand-built
## plain list, never routed through kinship2::pedigree()).
.emptyLayoutFixture <- function() {
  list(
    nodes = data.frame(id = "F1", stringsAsFactors = FALSE),
    edges = data.frame(from = character(), to = character(),
                        dashes = logical(), smooth.type = character(),
                        stringsAsFactors = FALSE),
    duplicateToReal = stats::setNames(character(0), character(0))
  )
}

## ---- the D-2 property test's own second implementation -------------------
##
## Walks makePedigreeMatingLayout(ped, edgeStyle = "rectilinear")'s waypoint
## edges to recover the SAME real-individual-level relationship set
## .extractNprcStructure() reads directly off "direct"-style output. Exists
## ONLY to cross-check D-2's invariance claim (plan section 2, D-2's
## "Required verification, not an assumption" note) -- deliberately
## test-file-local, not production code, and not vectorized/hardened to
## production standard (plan section 4.2: "it need not be
## production-quality or reused anywhere else").
##
## The three waypoint families route differently, but all reduce to one
## shape once collapsed:
##   - __jog_<n>_a/__jog_<n>_b (.resolveEdgeNodeCollisions()): a simple
##     pass-through splice, u -> j1 -> j2 -> v replacing a single logical
##     edge u -> v. Always exactly 1 incoming + 1 outgoing edge per jog
##     node (verified directly against the real 375-individual fixture's
##     154 jog waypoints this session) -- collapsed first, unconditionally,
##     before anything else runs.
##   - __proj_<side>_<unit> (.addRectilinearWaypoints() D2, mate-line
##     dogleg): always a standalone 2-edge unit (side -> proj -> union),
##     never chained to another __drop_/__bar_/__proj_ node directly.
##   - __drop_<fromId> / __bar_<kid> (.addRectilinearWaypoints() D1,
##     sibship bar): a connected chain per sibling group, attached to
##     fromId via the drop node and to each kid via its own bar node.
## After jog-collapse, both families reduce to "one real/union parent-side
## terminal in, one-or-more real/union child-side terminals out" per
## connected component of waypoint nodes -- discovered by edge DIRECTION
## (a terminal -> waypoint edge is the parent-side attachment; a
## waypoint -> terminal edge is a child-side attachment), not by parsing
## node-id substrings (dropId/barId ids embed fromId/kid, but a general
## graph-based recovery needs no such assumption and stays correct if the
## naming ever changes).
.extractNprcStructureFromWaypoints <- function(layout) {
  e <- layout$edges[, c("from", "to", "dashes", "smooth.type")]
  e$from <- as.character(e$from)
  e$to <- as.character(e$to)
  duplicateToReal <- layout$duplicateToReal
  resolveId <- function(id) {
    hit <- match(id, names(duplicateToReal))
    ifelse(is.na(hit), id, unname(duplicateToReal[hit]))
  }

  isJog <- function(x) grepl("^__jog_", x)
  isWaypoint <- function(x) grepl("^__drop_|^__bar_|^__proj_", x)

  ## Step 1: collapse __jog_ pass-through pairs (always exactly 1 incoming +
  ## 1 outgoing edge, by .resolveEdgeNodeCollisions()'s own construction).
  repeat {
    jogIds <- unique(c(e$from[isJog(e$from)], e$to[isJog(e$to)]))
    if (length(jogIds) == 0L) break
    j <- jogIds[[1L]]
    inRow <- which(e$to == j)
    outRow <- which(e$from == j)
    newRow <- e[inRow, , drop = FALSE]
    newRow$to <- e$to[outRow]
    e <- rbind(e[-c(inRow, outRow), , drop = FALSE], newRow)
  }

  ## Dup connectors (dashed real<->duplicate arcs) are never routed through
  ## any waypoint family in either edgeStyle -- excluded here exactly as in
  ## .extractNprcStructure()'s own isDupEdge marker.
  isDupEdge <- e$dashes & !is.na(e$smooth.type) & e$smooth.type == "curvedCW"
  e <- e[!isDupEdge, , drop = FALSE]

  ## Step 2: connected components over waypoint<->waypoint edges only (the
  ## D1 horizontal chain; a D2 __proj_ node has none, so it is always its
  ## own singleton component).
  wpNodes <- unique(c(e$from[isWaypoint(e$from)], e$to[isWaypoint(e$to)]))
  parent <- stats::setNames(wpNodes, wpNodes)
  find <- function(x) {
    while (!identical(parent[[x]], x)) x <- parent[[x]]
    x
  }
  wpwp <- e[isWaypoint(e$from) & isWaypoint(e$to), , drop = FALSE]
  if (nrow(wpwp) > 0L) {
    for (i in seq_len(nrow(wpwp))) {
      ra <- find(wpwp$from[[i]])
      rb <- find(wpwp$to[[i]])
      if (!identical(ra, rb)) parent[[ra]] <- rb
    }
  }
  compOf <- stats::setNames(vapply(wpNodes, find, character(1L)), wpNodes)

  ## Step 3: external attachments -- one endpoint a waypoint node, the
  ## other a terminal (real/dup/union id). Edge direction discriminates
  ## parent-side (terminal -> waypoint) from child-side (waypoint ->
  ## terminal), matching childEdges'/mateEdges' own "from" = source
  ## convention in makePedigreeDiagramData.R.
  ext <- e[xor(isWaypoint(e$from), isWaypoint(e$to)), , drop = FALSE]
  parentSide <- list()
  childSide <- list()
  if (nrow(ext) > 0L) {
    for (i in seq_len(nrow(ext))) {
      f <- ext$from[[i]]
      t <- ext$to[[i]]
      if (isWaypoint(f)) {
        comp <- compOf[[f]]
        childSide[[comp]] <- c(childSide[[comp]], t)
      } else {
        comp <- compOf[[t]]
        parentSide[[comp]] <- c(parentSide[[comp]], f)
      }
    }
  }

  ## Step 4: classify each component -- a single child-side terminal that
  ## is itself a union id is a recovered (dogleg'd) mate edge; anything
  ## else is a recovered (D1) sibling group's child edges.
  recoveredMate <- list()
  recoveredChild <- list()
  for (comp in names(childSide)) {
    p <- parentSide[[comp]]
    ch <- childSide[[comp]]
    if (length(ch) == 1L && grepl("^__union_", ch)) {
      recoveredMate[[length(recoveredMate) + 1L]] <-
        data.frame(from = p, to = ch, stringsAsFactors = FALSE)
    } else {
      recoveredChild[[length(recoveredChild) + 1L]] <- data.frame(
        from = rep(p, length(ch)), to = ch, stringsAsFactors = FALSE)
    }
  }

  ## Step 5: pool with any edges that stayed direct (a same-gen mate edge
  ## never gets a D2 dogleg at all).
  keptMate <- e[!isWaypoint(e$from) & grepl("^__union_", e$to),
                c("from", "to")]
  keptChild <- e[!isWaypoint(e$from) & !isWaypoint(e$to) &
                   !grepl("^__union_", e$to), c("from", "to")]
  mateEdges <- rbind(keptMate, do.call(rbind, recoveredMate))
  childEdges <- rbind(keptChild, do.call(rbind, recoveredChild))
  if (is.null(mateEdges)) {
    mateEdges <- data.frame(from = character(), to = character(),
                             stringsAsFactors = FALSE)
  }
  if (is.null(childEdges)) {
    childEdges <- data.frame(from = character(), to = character(),
                              stringsAsFactors = FALSE)
  }

  ## Step 6: from here on, identical to .extractNprcStructure()'s own
  ## downstream assembly (matePairs grouping, parentChildEdges expansion) --
  ## see that function for the production version of this logic.
  mateEdges$parent <- resolveId(mateEdges$from)
  bySplit <- split(mateEdges$parent, mateEdges$to)
  matePairs <- do.call(rbind, lapply(names(bySplit), function(u) {
    parents <- bySplit[[u]]
    if (length(parents) < 2L) return(NULL)
    data.frame(parent1 = parents[[1L]], parent2 = parents[[2L]],
               unionId = u, stringsAsFactors = FALSE)
  }))
  if (is.null(matePairs)) {
    matePairs <- data.frame(parent1 = character(), parent2 = character(),
                             unionId = character(), stringsAsFactors = FALSE)
  }

  isUnionSourced <- grepl("^__union_", childEdges$from)
  unionChild <- childEdges[isUnionSourced, ]
  directChild <- childEdges[!isUnionSourced, ]
  pcFromUnion <- if (nrow(unionChild) > 0L) {
    matchIdx <- match(unionChild$from, matePairs$unionId)
    data.frame(child = rep(resolveId(unionChild$to), 2L),
               parent = c(matePairs$parent1[matchIdx],
                          matePairs$parent2[matchIdx]),
               stringsAsFactors = FALSE)
  } else {
    data.frame(child = character(), parent = character(),
               stringsAsFactors = FALSE)
  }
  pcFromDirect <- if (nrow(directChild) > 0L) {
    data.frame(child = resolveId(directChild$to),
               parent = resolveId(directChild$from),
               stringsAsFactors = FALSE)
  } else {
    data.frame(child = character(), parent = character(),
               stringsAsFactors = FALSE)
  }
  parentChildEdges <- rbind(pcFromUnion, pcFromDirect)

  nChildrenByUnion <- table(unionChild$from)
  matePairs$nChildren <- as.integer(nChildrenByUnion[matePairs$unionId])
  matePairs$unionId <- NULL

  list(parentChildEdges = parentChildEdges, matePairs = matePairs)
}

## ---- input contract / return shape --------------------------------------

test_that(
  ".extractNprcStructure returns a list with parentChildEdges/matePairs", {
  layout <- nprcgenekeepr:::makePedigreeMatingLayout(.ped7Fixture(),
                                                       edgeStyle = "direct")
  result <- .extractNprcStructure(layout)
  expect_true(is.list(result))
  expect_setequal(names(result), c("parentChildEdges", "matePairs"))
  expect_true(is.data.frame(result$parentChildEdges))
  expect_true(is.data.frame(result$matePairs))
  expect_setequal(names(result$parentChildEdges), c("child", "parent"))
  expect_setequal(names(result$matePairs),
                   c("parent1", "parent2", "nChildren"))
})

## ---- founder-only: no known parents at all ------------------------------

test_that(
  ".extractNprcStructure gives a lone founder zero edges and zero mate
   pairs", {
  result <- .extractNprcStructure(.emptyLayoutFixture())
  expect_equal(nrow(result$parentChildEdges), 0L)
  expect_equal(nrow(result$matePairs), 0L)
})

## ---- D5 single-known-parent fallback -------------------------------------

test_that(
  ".extractNprcStructure gives a single-known-parent child exactly one
   direct (non-union-sourced) edge, and contributes no mate pair", {
  ped <- data.frame(
    id = c("F1", "M1", "C1"), sire = c(NA, NA, "F1"), dam = c(NA, NA, NA),
    sex = c("M", "F", "F"), gen = c(0L, 0L, 1L), stringsAsFactors = FALSE
  )
  layout <- nprcgenekeepr:::makePedigreeMatingLayout(ped,
                                                       edgeStyle = "direct")
  result <- .extractNprcStructure(layout)
  expect_equal(.pcKeysB(result$parentChildEdges), "C1|F1")
  expect_equal(nrow(result$matePairs), 0L)
})

## ---- 7-subject fixture: same relationships as Track A's own -------------

test_that(
  ".extractNprcStructure handles the 7-subject/2-mating fixture (no
   duplicates, no consanguinity) -- same relationships as Track A's own
   combined fixture", {
  layout <- nprcgenekeepr:::makePedigreeMatingLayout(.ped7Fixture(),
                                                       edgeStyle = "direct")
  result <- .extractNprcStructure(layout)

  expect_setequal(.pcKeysB(result$parentChildEdges), c(
    "X|A", "X|B", "Y|C", "Y|D", "Z|C", "Z|D"
  ))
  expect_equal(nrow(result$parentChildEdges), 6L)

  expect_setequal(.mateKeysB(result$matePairs), c("A|B|1", "C|D|2"))
  expect_equal(nrow(result$matePairs), 2L)
})

## ---- 9-subject Track C fixture: duplicates + consanguinity --------------

test_that(
  ".extractNprcStructure resolves duplicateToReal correctly and reports a
   real consanguineous union on the Track C dogleg fixture", {
  layout <- nprcgenekeepr:::makePedigreeMatingLayout(.pedTrackCFixture(),
                                                       edgeStyle = "direct")
  ## The layout genuinely duplicates A (multi-mate: X and Y) -- confirms
  ## the fixture itself still exercises duplicateToReal before trusting
  ## the extraction result below.
  expect_true(any(grepl("^__dup_A_", names(layout$duplicateToReal))))

  result <- .extractNprcStructure(layout)
  ## Every parentChildEdges/matePairs id is a REAL individual id -- never
  ## a __dup_/__union_ synthetic id (duplicateToReal resolution applied).
  reserved <- "^__dup_|^__union_"
  expect_false(any(grepl(reserved, result$parentChildEdges$child)))
  expect_false(any(grepl(reserved, result$parentChildEdges$parent)))
  expect_false(any(grepl(reserved, result$matePairs$parent1)))
  expect_false(any(grepl(reserved, result$matePairs$parent2)))

  expect_setequal(.pcKeysB(result$parentChildEdges), c(
    "A|P1", "Y|P1", "A|P2", "Y|P2",
    "C1|X", "C1|A", "C2|W", "C2|Y", "GC|A", "GC|Y"
  ))
  expect_equal(nrow(result$parentChildEdges), 10L)

  expect_setequal(.mateKeysB(result$matePairs),
                   c("P1|P2|2", "A|X|1", "W|Y|1", "A|Y|1"))
  expect_equal(nrow(result$matePairs), 4L)
})

## ---- D-2 edgeStyle-invariance property test ------------------------------

test_that(
  ".extractNprcStructure(direct-style) matches the rectilinear-side
   extraction on the Track C dogleg fixture -- proves D-2's invariance
   claim on a small, hand-verifiable case", {
  ped <- .pedTrackCFixture()
  direct <- nprcgenekeepr:::makePedigreeMatingLayout(ped,
                                                       edgeStyle = "direct")
  rectilinear <- nprcgenekeepr:::makePedigreeMatingLayout(
    ped, edgeStyle = "rectilinear")

  fromDirect <- .extractNprcStructure(direct)
  fromRectilinear <- .extractNprcStructureFromWaypoints(rectilinear)

  expect_setequal(.pcKeysB(fromDirect$parentChildEdges),
                   .pcKeysB(fromRectilinear$parentChildEdges))
  expect_equal(nrow(fromDirect$parentChildEdges),
               nrow(fromRectilinear$parentChildEdges))
  expect_setequal(.mateKeysB(fromDirect$matePairs),
                   .mateKeysB(fromRectilinear$matePairs))
  expect_equal(nrow(fromDirect$matePairs), nrow(fromRectilinear$matePairs))
})

test_that(
  ".extractNprcStructure(direct-style) matches the rectilinear-side
   extraction on the real 375-individual bundled fixture -- the D-8
   toy-AND-real-scale validation discipline (PROJECT_LEARNINGS.md Learning
   596) applied to D-2's own invariance claim, confirmed exercising real
   __proj_ dogleg and __jog_ collision waypoints (not just the D1 sibship
   chains the small fixtures above cover)", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  direct <- nprcgenekeepr:::makePedigreeMatingLayout(ped,
                                                       edgeStyle = "direct")
  rectilinear <- withCallingHandlers(
    nprcgenekeepr:::makePedigreeMatingLayout(ped, edgeStyle = "rectilinear"),
    warning = function(w) {
      expect_match(conditionMessage(w), "same-row edge-node collision")
      invokeRestart("muffleWarning")
    }
  )
  ## Confirm this run actually exercised both waypoint families the small
  ## fixtures above cannot reach -- an empty/mocked/skipped run would pass
  ## the equality checks below vacuously.
  expect_true(any(grepl("^__proj_", rectilinear$nodes$id)))
  expect_true(any(grepl("^__jog_", rectilinear$nodes$id)))

  fromDirect <- .extractNprcStructure(direct)
  fromRectilinear <- .extractNprcStructureFromWaypoints(rectilinear)

  expect_setequal(.pcKeysB(fromDirect$parentChildEdges),
                   .pcKeysB(fromRectilinear$parentChildEdges))
  expect_equal(nrow(fromDirect$parentChildEdges),
               nrow(fromRectilinear$parentChildEdges))
  expect_setequal(.mateKeysB(fromDirect$matePairs),
                   .mateKeysB(fromRectilinear$matePairs))
  expect_equal(nrow(fromDirect$matePairs), nrow(fromRectilinear$matePairs))
})
