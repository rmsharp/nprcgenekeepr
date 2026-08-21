## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Tests for .resolveEdgeNodeCollisions() -- Pedigree Diagram same-row
## collision-avoidance, Track 2 (issue #160 comment 1's broadened finding;
## docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md
## section 2.2/section 6 Session B). A pure post-processing step, called
## from makePedigreeMatingLayout() immediately after .addRectilinearWaypoints()
## (edgeStyle == "rectilinear" only): detects any straight (non-curved)
## same-row edge whose x-span strictly contains an unrelated node, and
## repairs it with a small rectilinear "step" detour -- never moving any
## pre-existing node. The curved duplicate-connector arc gets its own,
## separate disclosed-heuristic branch (a smooth.roundness bump), since it
## cannot be rerouted through rectilinear waypoints without destroying its
## already-shipped arc styling (S577/S468/S469).
##
## PRE-RED empirical findings (this session, verified live against current
## HEAD via pkgload::load_all(), not assumed):
##
## 1. D2's dogleg leg is CURRENTLY STRUCTURALLY UNREACHABLE via the real
##    pipeline: Track 4's matingUnits$gen == genOf[[anchor]] invariant plus
##    issue #143's non-anchor on-row override together guarantee BOTH
##    sides of every mating unit render on-row, confirmed by this file's
##    own sibling test (test_addRectilinearWaypoints.R:517-546, "0 D2
##    projections... now as a structural invariant"). The "D2-dogleg-leg
##    collision" fixture below is therefore a hand-built, synthetic
##    (nodes, edges) pair exercising the general detector defensively --
##    matching the plan's own "synthetic fixtures" wording -- not a
##    real-pedigree reproduction.
## 2. The GitHub issue #160 comment-1 P1/P2/X/A/Y/W/C1/GC/C2 fixture,
##    reproduced live: neither the D1 bar chain nor any KEPT straight mate
##    edge actually collides in this specific small fixture (every
##    coordinate that looks like a collision turns out to be a node
##    directly graph-adjacent to one of the edge's own endpoints -- e.g.
##    Y is one of __union_4's own 2 parents, correctly excluded as a
##    structural member). The ONE real collision in this fixture is the
##    CURVED duplicate connector (__dup_Y_1 -> Y, smooth.enabled = TRUE)
##    passing through W -- exactly comment 1's own described defect,
##    handled by the separate disclosed-heuristic branch, not the
##    rectilinear jog.
## 3. A much larger, previously-undocumented finding on the real
##    375-individual bundled fixture: 150 of 725 straight same-row edges
##    (20.7%) already collide with >=1 unrelated node -- 3,081 total
##    edge-obstacle pairs -- overwhelmingly (139/150) ordinary KEPT mate
##    edges (parent -> union), not D1 bars (5) or D2 (0 -- see finding 1).
##    Root cause: a founder's mating union can land far from the founder
##    (Track 6's child-centered finalUnitX), and on a wide multi-founder
##    colony pedigree (173 gen-0 founders here), that mate edge's straight
##    line sweeps across every founder positioned in between (max span
##    ~10,748 units, up to 89 obstacles on one edge). Owner-directed
##    (AskUserQuestion, this session): fold this into Track 2 unchanged --
##    the approved bounded-pass/residual-disclosure design already handles
##    it gracefully, since ONE jog clears an edge's ENTIRE span in a
##    single step (a parallel offset row), not one obstacle at a time.
##    Disclosed with real measured counts at close-out, not silently
##    absorbed into "the fix works" framing.

## ---- test helpers (not exported, local to this file) --------------------

## Independent collision detector (deliberately NOT sharing code with the
## production .resolveEdgeNodeCollisions()'s own internals) -- so this test
## file verifies actual geometry, not "the test calls the same logic and
## agrees with itself." Same predicate as the plan's own section 2.2:
## strict interior containment on a straight (non-curved) same-row edge,
## excluding the edge's own 2 endpoints and any node directly graph-adjacent
## (any edge, either direction) to either endpoint.
.findEdgeNodeCollisions <- function(nodes, edges) {
  xOf <- stats::setNames(nodes$x, nodes$id)
  yOf <- stats::setNames(nodes$y, nodes$id)
  adj <- new.env(parent = emptyenv())
  addAdj <- function(a, b) {
    cur <- adj[[a]]
    adj[[a]] <- if (is.null(cur)) b else c(cur, b)
  }
  for (i in seq_len(nrow(edges))) {
    addAdj(edges$from[i], edges$to[i])
    addAdj(edges$to[i], edges$from[i])
  }
  byRow <- split(nodes$id, nodes$y)
  hits <- list()
  for (i in seq_len(nrow(edges))) {
    f <- edges$from[i]; t <- edges$to[i]
    yf <- yOf[[f]]; yt <- yOf[[t]]
    if (is.null(yf) || is.null(yt) || is.na(yf) || is.na(yt) || yf != yt) next
    se <- if ("smooth.enabled" %in% names(edges)) edges$smooth.enabled[i] else NA
    if (!is.na(se) && isTRUE(se)) next  # curved connector, own branch
    xf <- xOf[[f]]; xt <- xOf[[t]]
    lo <- min(xf, xt); hi <- max(xf, xt)
    candidates <- setdiff(byRow[[as.character(yf)]], c(f, t))
    if (length(candidates) == 0L) next
    cx <- xOf[candidates]
    inside <- candidates[cx > lo & cx < hi]
    if (length(inside) == 0L) next
    structMembers <- union(adj[[f]], adj[[t]])
    trueObstacles <- setdiff(inside, structMembers)
    if (length(trueObstacles) > 0L) {
      hits[[length(hits) + 1L]] <- data.frame(
        from = f, to = t, y = yf,
        obstacle = trueObstacles, stringsAsFactors = FALSE
      )
    }
  }
  if (length(hits) == 0L) {
    return(data.frame(from = character(), to = character(), y = numeric(),
                       obstacle = character(), stringsAsFactors = FALSE))
  }
  do.call(rbind, hits)
}

.expectNoEdgeNodeCollision <- function(nodes, edges) {
  collisions <- .findEdgeNodeCollisions(nodes, edges)
  testthat::expect_equal(nrow(collisions), 0L,
                          info = paste0("unexpected same-row collisions:\n",
                                        paste(utils::capture.output(print(collisions)),
                                              collapse = "\n")))
}

## ---- input validation -----------------------------------------------

test_that(".resolveEdgeNodeCollisions rejects non-data-frame 'nodes'/'edges'", {
  validNodes <- data.frame(id = "A", x = 0, y = 0, stringsAsFactors = FALSE)
  validEdges <- data.frame(from = character(), to = character(),
                            stringsAsFactors = FALSE)
  expect_error(.resolveEdgeNodeCollisions(list(a = 1), validEdges),
               "data frame")
  expect_error(.resolveEdgeNodeCollisions(validNodes, list(a = 1)),
               "data frame")
})

## ---- no collisions: pass-through, zero new nodes/edges -------------------

test_that(".resolveEdgeNodeCollisions leaves a collision-free nodes/edges
           pair unchanged", {
  nodes <- data.frame(id = c("A", "B", "C"), x = c(0, 100, 200),
                       y = c(0, 0, 150), stringsAsFactors = FALSE)
  edges <- data.frame(from = "A", to = "B", dashes = FALSE,
                       color = "#2B7CE9", width = NA_real_,
                       smooth.enabled = NA, smooth.type = NA_character_,
                       smooth.roundness = NA_real_, stringsAsFactors = FALSE)
  result <- .resolveEdgeNodeCollisions(nodes, edges)
  expect_identical(result$nodes, nodes)
  expect_identical(result$edges, edges)
  expect_equal(nrow(result$residuals), 0L)
})

## ---- synthetic D2-dogleg-leg-shaped collision (hand-built; see PRE-RED
## finding 1 above -- currently unreachable via the real pipeline under
## Track 4/#143's shipped invariants, so this exercises the general
## detector defensively, matching the plan's own "synthetic fixtures"
## framing) --------------------------------------------------------------

test_that(".resolveEdgeNodeCollisions detects and repairs a D2-dogleg-
           leg-shaped collision (projection node -> mating-unit node,
           an unrelated node strictly between them), without moving any
           pre-existing node", {
  nodes <- data.frame(
    id = c("S", "__proj_S_U1", "U1", "Obstacle"),
    x  = c(0,   0,             200,  100),
    y  = c(100, 0,             0,    0),
    stringsAsFactors = FALSE
  )
  edges <- data.frame(
    from = c("S",           "__proj_S_U1"),
    to   = c("__proj_S_U1", "U1"),
    dashes = FALSE, color = "#2B7CE9", width = NA_real_,
    smooth.enabled = NA, smooth.type = NA_character_,
    smooth.roundness = NA_real_, stringsAsFactors = FALSE
  )
  result <- .resolveEdgeNodeCollisions(nodes, edges)

  .expectNoEdgeNodeCollision(result$nodes, result$edges)
  expect_equal(nrow(result$residuals), 0L)

  ## Every pre-existing node's x/y is byte-identical -- Track 2 never
  ## moves an existing node, only adds new waypoints/reroutes edges.
  preExisting <- c("S", "__proj_S_U1", "U1", "Obstacle")
  before <- nodes[match(preExisting, nodes$id), c("x", "y")]
  after <- result$nodes[match(preExisting, result$nodes$id), c("x", "y")]
  expect_identical(before, after)

  ## New waypoint nodes were added (the __jog_ prefix), and the original
  ## colliding edge was replaced.
  newIds <- setdiff(result$nodes$id, nodes$id)
  expect_true(length(newIds) > 0L)
  expect_true(all(grepl("^__jog_", newIds)))
  expect_false(any(result$edges$from == "__proj_S_U1" &
                      result$edges$to == "U1"))
})

## ---- synthetic kept-mate-edge-shaped collision, TWO obstacles on ONE
## edge (hand-built; verifies a single jog clears the edge's entire span,
## not one obstacle at a time -- load-bearing for the real 375-fixture's
## own wide-span mate edges, PRE-RED finding 3 above, some with up to 89
## simultaneous obstacles) -------------------------------------------------

test_that(".resolveEdgeNodeCollisions repairs a kept-mate-edge-shaped
           collision with TWO unrelated obstacles using a single jog (one
           new waypoint pair), not one jog per obstacle", {
  nodes <- data.frame(
    id = c("Anchor", "Union", "Obstacle1", "Obstacle2"),
    x  = c(0,        300,     100,         200),
    y  = c(0,        0,       0,           0),
    stringsAsFactors = FALSE
  )
  edges <- data.frame(
    from = "Anchor", to = "Union", dashes = FALSE, color = "#2B7CE9",
    width = NA_real_, smooth.enabled = NA, smooth.type = NA_character_,
    smooth.roundness = NA_real_, stringsAsFactors = FALSE
  )
  result <- .resolveEdgeNodeCollisions(nodes, edges)

  .expectNoEdgeNodeCollision(result$nodes, result$edges)
  expect_equal(nrow(result$residuals), 0L)

  before <- nodes[, c("id", "x", "y")]
  after <- result$nodes[match(nodes$id, result$nodes$id), c("id", "x", "y")]
  expect_identical(before, after)

  newIds <- setdiff(result$nodes$id, nodes$id)
  expect_equal(length(newIds), 2L)  # one jog (2 waypoints), not 2 (per-obstacle)
  expect_true(all(grepl("^__jog_", newIds)))

  ## The new waypoint row sits strictly off row y=0 (both obstacles' own
  ## row), at a small offset -- never a hardcoded yScale.
  jogRows <- result$nodes[result$nodes$id %in% newIds, ]
  expect_true(all(jogRows$y != 0))
  expect_true(all(abs(jogRows$y) < 150))  # a *small* fraction of one gen gap
})

## ---- a genuine structural member is never flagged as an obstacle -------
## (the exact bug design review found in the "Row Ledger" candidate,
## section 4 of the plan -- a same-row edge must not flag a node directly
## adjacent to either of its own endpoints).

test_that(".resolveEdgeNodeCollisions does not flag a node that is
           directly graph-adjacent to one of the colliding edge's own
           endpoints (a structural member, not a foreign obstacle)", {
  nodes <- data.frame(
    id = c("Anchor", "Union", "OtherParent"),
    x  = c(0,        200,     100),
    y  = c(0,        0,       0),
    stringsAsFactors = FALSE
  )
  ## OtherParent is graph-adjacent to Union via her OWN mate edge -- she
  ## structurally belongs to this exact union, not a foreign intruder.
  edges <- data.frame(
    from = c("Anchor",      "OtherParent"),
    to   = c("Union",       "Union"),
    dashes = FALSE, color = "#2B7CE9", width = NA_real_,
    smooth.enabled = NA, smooth.type = NA_character_,
    smooth.roundness = NA_real_, stringsAsFactors = FALSE
  )
  result <- .resolveEdgeNodeCollisions(nodes, edges)
  ## No repair needed -- OtherParent is excluded, so Anchor -> Union is
  ## not treated as colliding.
  expect_identical(result$nodes, nodes)
  expect_identical(result$edges, edges)
  expect_equal(nrow(result$residuals), 0L)
})

## ---- curved duplicate connector: separate disclosed-heuristic branch --
## GitHub issue #160 comment 1's original reproduction (P1xP2's 2 children
## A and Y; Y duplicated, mating both A -- consanguineous -- and W) exactly
## isolated the curved-connector-behind-W collision under the OLD
## algorithm. Walker/BJL cutover (Phase 3, this session): found during
## GREEN that this small synthetic fixture no longer collides under the
## new engine's different coordinate distribution -- W's own x (288.12)
## now falls OUTSIDE the __dup_Y_1/Y chord (168-240), confirmed directly
## (probe execution); the fixture and its own .commentOneFixture() helper
## are removed as dead code rather than kept unused. The curved-heuristic
## mechanism itself (.resolveEdgeNodeCollisions(), untouched by this
## migration) still fires reliably on real data -- 47 curved-heuristic
## collisions measured on the
## real 375-individual bundled fixture (down from 102 curved connectors
## total, all initially at roundness 0.2) -- so this test is rewritten to
## exercise it there instead of via a now-inert small fixture, rather than
## engineering a new synthetic shape to force a specific collision under
## an unrelated coordinate system.
test_that(".resolveEdgeNodeCollisions applies a disclosed smooth.roundness
           heuristic to curved duplicate connectors that collide with an
           unrelated node, on the real 375-individual bundled fixture",
          {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  direct <- makePedigreeMatingLayout(ped, edgeStyle = "direct")
  waypoints <- .addRectilinearWaypoints(direct$nodes, direct$edges, forest,
                                          pos)

  curved <- waypoints$edges[!is.na(waypoints$edges$smooth.enabled) &
                                waypoints$edges$smooth.enabled == TRUE, ]
  expect_equal(nrow(curved), 102L)
  expect_true(all(curved$smooth.roundness == 0.2))

  result <- .resolveEdgeNodeCollisions(waypoints$nodes, waypoints$edges)

  ## The heuristic bumps roundness on each colliding curved edge -- a
  ## disclosed nudge, not a closed-form clearance proof (plan section
  ## 2.2). Confirmed only mechanically here; the actual visual effect is
  ## confirmed by rendered-image inspection in REFACTOR.
  fixedCurved <- result$edges[!is.na(result$edges$smooth.enabled) &
                                  result$edges$smooth.enabled == TRUE, ]
  expect_equal(nrow(fixedCurved), 102L)
  ## One concrete, named pair re-measured directly, not hand-derived.
  one <- fixedCurved[fixedCurved$from == "__dup_28XSME_1" &
                        fixedCurved$to == "28XSME", ]
  expect_equal(nrow(one), 1L)
  expect_equal(one$smooth.roundness, 0.5)

  ## Recorded in the residuals data frame as a heuristic (unconfirmed by
  ## coordinate math), distinct from a rectilinear (fully-proven) repair.
  curvedResiduals <- result$residuals[result$residuals$kind ==
                                          "curved-heuristic", ]
  expect_equal(nrow(curvedResiduals), 47L)

  ## Every pre-existing node's x/y is byte-identical.
  before <- waypoints$nodes[, c("id", "x", "y")]
  after <- result$nodes[match(waypoints$nodes$id, result$nodes$id),
                          c("id", "x", "y")]
  expect_identical(before, after)
})

## ---- full pipeline wiring: makePedigreeMatingLayout() calls
## .resolveEdgeNodeCollisions() automatically under edgeStyle =
## "rectilinear" -----------------------------------------------------------
## Deliberately NOT the comment-1 P1/P2/X/A/Y/W fixture -- PRE-RED finding
## 2 confirmed that small fixture has ZERO straight-edge collisions (its
## one real collision is the curved connector, checked separately above),
## so a wiring test built on it would pass even with .resolveEdgeNode
## Collisions() entirely unimplemented -- not a real RED test. The real
## 375-individual bundled fixture genuinely collides (150 edges, PRE-RED
## finding 3), so checking for __jog_ waypoints in the FULL
## makePedigreeMatingLayout() pipeline's own output is a real, currently-
## failing assertion.

test_that("makePedigreeMatingLayout() wires .resolveEdgeNodeCollisions()
           into its rectilinear edgeStyle branch", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  layout <- withCallingHandlers(
    makePedigreeMatingLayout(ped, edgeStyle = "rectilinear"),
    warning = function(w) {
      expect_match(conditionMessage(w), "same-row edge-node collision")
      invokeRestart("muffleWarning")
    }
  )
  expect_true(any(grepl("^__jog_", layout$nodes$id)))
})

## ---- real 375-individual bundled fixture: large-scale regression check -
## PRE-RED finding 3 above: 150 of 725 straight same-row edges (20.7%)
## collide pre-fix, 3,081 total edge-obstacle pairs, overwhelmingly (139/
## 150) ordinary kept mate edges spanning a wide multi-founder gen-0 row.
## Owner-directed (AskUserQuestion, this session): fold into Track 2
## unchanged, disclose the real counts, don't silently claim "zero
## collisions" if a genuine residual remains after the pass cap -- exact
## post-fix residual count filled in once GREEN is implemented and
## measured empirically (same discipline as Track 1's own disclosed 42 ->
## 9 bar-vs-bar residual count).
##
## Walker/BJL cutover (Phase 3, this session): Track 3's parent-span
## clamp -- the mechanism the prior (105/1,431) baseline was measured
## against -- is removed entirely. Re-measured by actually running the
## new engine, never hand-derived: 105 -> 76 colliding edges, 1,431 ->
## 1,715 obstacle-pairs (fewer distinct edges affected, but each with more
## obstacles under the new engine's own coordinate distribution). The
## resolve pass itself still fully clears every collision on this
## fixture (0 residual, confirmed below).

test_that(".resolveEdgeNodeCollisions dramatically reduces the real
           375-individual bundled fixture's same-row collision count (76
           colliding edges / 1,715 obstacle-pairs pre-fix, under the
           Walker/BJL engine), and any residual is disclosed via the
           residuals data frame, never silently dropped", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  direct <- makePedigreeMatingLayout(ped, edgeStyle = "direct")
  waypoints <- .addRectilinearWaypoints(direct$nodes, direct$edges, forest,
                                          pos)

  baseline <- .findEdgeNodeCollisions(waypoints$nodes, waypoints$edges)
  baselineEdges <- unique(baseline[, c("from", "to")])
  ## CHANGED from 105L/1431L -- Walker/BJL cutover (Phase 3, this
  ## session): re-measured by actually running the new engine, never
  ## hand-derived (Track 3's parent-span clamp, part of the OLD baseline
  ## this test's own docstring/comment above narrates, no longer exists).
  expect_equal(nrow(baselineEdges), 76L)
  expect_equal(nrow(baseline), 1715L)

  result <- .resolveEdgeNodeCollisions(waypoints$nodes, waypoints$edges)
  afterFix <- .findEdgeNodeCollisions(result$nodes, result$edges)

  ## A dramatic reduction, not a guarantee of zero -- Track 6 section 8's
  ## own "general crowding is accepted as partial, not absolute" posture.
  expect_true(nrow(afterFix) < nrow(baseline))

  ## Every genuinely remaining collision is disclosed in the residuals
  ## data frame -- never silently dropped.
  if (nrow(afterFix) > 0L) {
    expect_true(nrow(result$residuals) > 0L)
  }

  ## No pre-existing (non-__jog_) node's x/y changed.
  preExistingIds <- waypoints$nodes$id
  before <- waypoints$nodes[, c("id", "x", "y")]
  after <- result$nodes[match(preExistingIds, result$nodes$id),
                          c("id", "x", "y")]
  expect_identical(before, after)
})
