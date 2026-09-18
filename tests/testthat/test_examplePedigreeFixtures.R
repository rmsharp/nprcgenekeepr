## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Structural regression pins for the 5 bundled exemplar pedigrees
## (inst/extdata/examples/example_pedigree_{consanguinity,linebreeding,
## backcross,first_cousin,half_sib}.csv -- authored and ground-truth-verified
## S691, owner visual gate APPROVED "all 5 legible" in both edgeStyles,
## shipped byte-identical S692). Each pedigree holds exactly one classic
## complex mating structure. These tests load the SHIPPED copies through
## system.file() -- the same route users take -- and pin what the owner
## approved:
##   * fixture preconditions: CSV shape, literal NA founder parents, and
##     every kinship/inbreeding value exact to theory;
##   * structural layout facts in both edgeStyles: node/edge counts, which
##     animals are drawn twice, which union carries the consanguineous
##     marker, the (child, sire, dam) edge trace, and routing-net
##     confinement.
## Raw x-positions are deliberately NOT pinned: they are order-sensitive
## and would break on any legitimate ordering change (S688/S690 precedent).
## A count pin failing here means the drawing of a reviewed structure
## changed -- re-measure by running the engine and get the new render
## re-reviewed before updating the pin; never hand-derive a new value.

## ---- test helpers (not exported, local to this file) ------------------

.readExemplarPedigree <- function(name) {
  path <- system.file("extdata", "examples",
                      sprintf("example_pedigree_%s.csv", name),
                      package = "nprcgenekeepr")
  utils::read.csv(path, stringsAsFactors = FALSE)
}

## Runs makePedigreeMatingLayout() and returns every warning it raised, so
## tests can pin the exact warning set instead of suppressing it blindly.
.layoutCapturingWarnings <- function(ped, edgeStyle) {
  warnings <- character()
  layout <- withCallingHandlers(
    makePedigreeMatingLayout(ped, edgeStyle = edgeStyle),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  list(layout = layout, warnings = warnings)
}

.realIds <- function(ids, layout) {
  d2r <- layout$duplicateToReal
  ifelse(ids %in% names(d2r), unname(d2r[ids]), ids)
}

## Reconstructs every (child, sire, dam) triple from an edgeStyle = "direct"
## layout's parent -> union -> child edges, resolving __dup_* occurrences to
## their real ids. badUnions lists any union not drawn with exactly one
## male and one female parent.
.traceDirectTriples <- function(ped, layout) {
  e <- layout$edges
  isUnion <- function(x) startsWith(x, "__union_")
  mate <- e[isUnion(e$to) & !isUnion(e$from), ]
  child <- e[isUnion(e$from) & !isUnion(e$to), ]
  triples <- list()
  badUnions <- character()
  for (u in unique(c(mate$to, child$from))) {
    parents <- .realIds(mate$from[mate$to == u], layout)
    sex <- ped$sex[match(parents, ped$id)]
    sire <- parents[sex %in% "M"]
    dam <- parents[sex %in% "F"]
    if (length(parents) != 2L || length(sire) != 1L || length(dam) != 1L) {
      badUnions <- c(badUnions, u)
      next
    }
    for (k in .realIds(child$to[child$from == u], layout)) {
      triples[[length(triples) + 1L]] <-
        data.frame(id = k, sire = sire, dam = dam, stringsAsFactors = FALSE)
    }
  }
  traced <- do.call(rbind, c(
    list(data.frame(id = character(), sire = character(),
                    dam = character(), stringsAsFactors = FALSE)),
    triples))
  traced <- traced[order(traced$id), , drop = FALSE]
  rownames(traced) <- NULL
  list(triples = traced, badUnions = badUnions)
}

## Waypoint node kinds the rectilinear router currently emits. A new kind
## would silently escape the net-confinement check below, so the tests
## also pin that no other "__" node kind appears.
.kExemplarWaypointPattern <- "^__(bar|drop|jog)_"

## Contracts each chain of rectilinear waypoint nodes into one routing net
## and checks that every net attaches to exactly one union and, among
## animals, to exactly that union's own children (taken from the direct
## layout) -- in these layouts parents join their union directly, so a net
## reaching a parent or an unrelated animal is a routing defect. Also
## checks that every union with children is reached by a net. Returns the
## net count and any violations.
.rectilinearNetViolations <- function(layoutR, layoutD) {
  isWp <- function(x) grepl(.kExemplarWaypointPattern, x)
  eD <- layoutD$edges
  childEdges <- eD[startsWith(eD$from, "__union_") &
                     !startsWith(eD$to, "__union_"), ]
  unionIds <- unique(childEdges$from)
  children <- lapply(setNames(unionIds, unionIds), function(u) {
    sort(unique(.realIds(childEdges$to[childEdges$from == u], layoutD)))
  })
  e <- layoutR$edges
  wpNodes <- unique(c(e$from[isWp(e$from)], e$to[isWp(e$to)]))
  wpEdges <- e[isWp(e$from) & isWp(e$to), ]
  net <- setNames(seq_along(wpNodes), wpNodes)
  repeat {
    changed <- FALSE
    for (i in seq_len(nrow(wpEdges))) {
      a <- net[[wpEdges$from[i]]]
      b <- net[[wpEdges$to[i]]]
      if (a != b) {
        net[net == b] <- a
        changed <- TRUE
      }
    }
    if (!changed) break
  }
  boundary <- e[xor(isWp(e$from), isWp(e$to)), ]
  violations <- character()
  reached <- character()
  for (n in unique(net)) {
    members <- names(net)[net == n]
    touched <- unique(c(boundary$to[boundary$from %in% members],
                        boundary$from[boundary$to %in% members]))
    unions <- touched[startsWith(touched, "__union_")]
    if (length(unions) != 1L) {
      violations <- c(violations, sprintf(
        "net {%s} attaches to %d unions", paste(members, collapse = ","),
        length(unions)))
      next
    }
    reached <- c(reached, unions)
    attached <- sort(unique(.realIds(setdiff(touched, unions), layoutR)))
    expected <- if (unions %in% names(children)) {
      children[[unions]]
    } else {
      character()
    }
    if (!identical(attached, expected)) {
      violations <- c(violations, sprintf(
        "net of %s attaches [%s] but the union's children are [%s]", unions,
        paste(attached, collapse = ","), paste(expected, collapse = ",")))
    }
  }
  unreached <- setdiff(unionIds, reached)
  if (length(unreached) > 0L) {
    violations <- c(violations, sprintf(
      "unions with children reached by no routing net: [%s]",
      paste(unreached, collapse = ",")))
  }
  list(nNets = length(unique(net)), violations = violations)
}

## The mate-line edges drawn with the consanguineous marker (Okabe-Ito
## vermillion, width 4).
.consanguineousEdges <- function(layout) {
  layout$edges[layout$edges$color %in% "#D55E00", , drop = FALSE]
}

## ---- expectations (ground truth from S691's verified authoring) ----------
## pairs: kinship coefficient phi for named pairs; inbred: inbreeding
## coefficient F = 2 * phi(i, i) - 1, exact to theory. consanguineousMating
## is c(sire, dam) of the one mating the diagram must mark. Layout counts
## were measured through the engine on the shipped CSVs (S692 re-verified,
## S693 re-measured), never hand-derived.

.exemplarSpecs <- list(
  consanguinity = list(
    nRows = 14L, nFounders = 4L,
    pairs = list(c("CS1", "CD1", 0.25)),
    inbred = c(CI1 = 0.25, CI2 = 0.25),
    consanguineousMating = c("CS1", "CD1"),
    duplicated = "CS1",
    directNodes = 19L, directEdges = 19L,
    rectilinearNodes = 33L, rectilinearEdges = 33L,
    rectilinearCollisionWarning = FALSE
  ),
  linebreeding = list(
    nRows = 14L, nFounders = 5L,
    pairs = list(c("LA1", "LB1", 0.125), c("LB2", "LA2", 0.03125)),
    inbred = c(LL1 = 0.03125, LL2 = 0.03125, LL3 = 0.03125),
    consanguineousMating = c("LB2", "LA2"),
    duplicated = c("LB2", "LK"),
    directNodes = 21L, directEdges = 21L,
    rectilinearNodes = 35L, rectilinearEdges = 35L,
    ## CHANGED S715 (TRUE -> FALSE): arc-verified roundness selection --
    ## this fixture's 2 chord-flagged connectors resolve to 1 TRUE
    ## arc-disc collision (the other was a chord false positive), which
    ## the roundness ladder fully clears, so no residual warning fires.
    ## Re-render owner-reviewed at the S715 GREEN gate.
    rectilinearCollisionWarning = FALSE
  ),
  backcross = list(
    nRows = 11L, nFounders = 3L,
    pairs = list(c("BP", "BR", 0.25)),
    inbred = c(BC1 = 0.25, BC2 = 0.25, BC3 = 0.25),
    consanguineousMating = c("BP", "BR"),
    duplicated = "BP",
    directNodes = 15L, directEdges = 15L,
    rectilinearNodes = 26L, rectilinearEdges = 26L,
    rectilinearCollisionWarning = FALSE
  ),
  first_cousin = list(
    nRows = 12L, nFounders = 4L,
    pairs = list(c("FS1", "FS2", 0.25), c("FC1", "FC2", 0.0625)),
    inbred = c(FF1 = 0.0625, FF2 = 0.0625),
    consanguineousMating = c("FC1", "FC2"),
    duplicated = "FC2",
    directNodes = 17L, directEdges = 17L,
    ## CHANGED S696 (rectilinearEdges 33 -> 31): the ascender-stub
    ## direct rejoin replaces riser + descent with one segment at each
    ## of this fixture's 2 bypassed bar points (its 2 jog corridors both
    ## rejoin a bar point holding only its kid's descent). Node count is
    ## unchanged -- the bypassed bar points stay, unreferenced.
    ## Re-measured through the engine, re-render owner-reviewed S696.
    rectilinearNodes = 33L, rectilinearEdges = 31L,
    rectilinearCollisionWarning = FALSE
  ),
  half_sib = list(
    nRows = 12L, nFounders = 4L,
    pairs = list(c("HA1", "HB1", 0.125)),
    inbred = c(HC1 = 0.125, HC2 = 0.125),
    consanguineousMating = c("HA1", "HB1"),
    duplicated = c("HB1", "HS"),
    directNodes = 18L, directEdges = 18L,
    rectilinearNodes = 30L, rectilinearEdges = 30L,
    ## CHANGED S715 (TRUE -> FALSE): arc-verified roundness selection --
    ## both of this fixture's 2 TRUE arc-disc collisions are fully
    ## cleared by the roundness ladder, so no residual warning fires.
    ## Re-render owner-reviewed at the S715 GREEN gate.
    rectilinearCollisionWarning = FALSE
  )
)

## ---- fixture preconditions -----------------------------------------------

test_that(
  "each exemplar pedigree CSV ships, loads via system.file(), and keeps
   literal NA founder parents (no \"\" phantom-parent ids -- the S691
   na = \"\" round-trip defect class, Learning 744)", {
  for (name in names(.exemplarSpecs)) {
    spec <- .exemplarSpecs[[name]]
    ped <- .readExemplarPedigree(name)
    expect_identical(names(ped), c("id", "sire", "dam", "sex", "gen"),
                     info = name)
    expect_identical(nrow(ped), spec$nRows, info = name)
    expect_false(anyDuplicated(ped$id) > 0L, info = name)
    expect_false(any(ped$sire %in% ""), info = name)
    expect_false(any(ped$dam %in% ""), info = name)
    expect_identical(is.na(ped$sire), is.na(ped$dam), info = name)
    expect_identical(sum(is.na(ped$sire)), spec$nFounders, info = name)
    expect_true(all(ped$sire[!is.na(ped$sire)] %in% ped$id), info = name)
    expect_true(all(ped$dam[!is.na(ped$dam)] %in% ped$id), info = name)
    expect_true(all(ped$sex[match(ped$sire[!is.na(ped$sire)], ped$id)] == "M"),
                info = name)
    expect_true(all(ped$sex[match(ped$dam[!is.na(ped$dam)], ped$id)] == "F"),
                info = name)
    expect_identical(ped$gen,
                     as.integer(findGeneration(ped$id, ped$sire, ped$dam)),
                     info = name)
  }
})

test_that(
  "each exemplar pedigree's kinship and inbreeding values are exact to
   theory, and every animal outside the one consanguineous mating's
   offspring has F = 0", {
  for (name in names(.exemplarSpecs)) {
    spec <- .exemplarSpecs[[name]]
    ped <- .readExemplarPedigree(name)
    kmat <- as.matrix(kinship(ped$id, ped$sire, ped$dam, ped$gen))
    for (p in spec$pairs) {
      expect_equal(kmat[p[1L], p[2L]], as.numeric(p[3L]),
                   info = sprintf("%s: phi(%s, %s)", name, p[1L], p[2L]))
    }
    inbreeding <- setNames(2 * diag(kmat) - 1, ped$id)
    expect_equal(inbreeding[names(spec$inbred)], spec$inbred, info = name)
    others <- setdiff(ped$id, names(spec$inbred))
    expect_true(all(abs(inbreeding[others]) < 1e-12), info = name)
  }
})

test_that(
  "the linebreeding exemplar's common ancestor LK reaches the inbred
   offspring through two distinct lines of descent (what makes it
   linebreeding rather than a single close mating)", {
  ped <- .readExemplarPedigree("linebreeding")
  ancestorsOf <- function(x) {
    found <- character()
    frontier <- x
    while (length(frontier) > 0L) {
      rows <- match(frontier, ped$id)
      parents <- c(ped$sire[rows], ped$dam[rows])
      parents <- setdiff(parents[!is.na(parents)], found)
      found <- c(found, parents)
      frontier <- parents
    }
    found
  }
  lkChildren <- ped$id[ped$sire %in% "LK" | ped$dam %in% "LK"]
  lines <- lkChildren[lkChildren %in% ancestorsOf("LL1")]
  expect_identical(sort(lines), c("LA1", "LB1"))
})

## ---- edgeStyle = "direct" ------------------------------------------------

test_that(
  "each exemplar pedigree's direct layout keeps the owner-approved
   structure: node/edge counts, which animals are drawn twice, no isolated
   ids, and no warnings", {
  for (name in names(.exemplarSpecs)) {
    spec <- .exemplarSpecs[[name]]
    ped <- .readExemplarPedigree(name)
    run <- .layoutCapturingWarnings(ped, "direct")
    layout <- run$layout
    expect_identical(run$warnings, character(), info = name)
    expect_identical(nrow(layout$nodes), spec$directNodes, info = name)
    expect_identical(nrow(layout$edges), spec$directEdges, info = name)
    expect_length(layout$isolatedIds, 0L)
    expect_true(all(ped$id %in% layout$nodes$id), info = name)
    dupNodes <- layout$nodes$id[startsWith(layout$nodes$id, "__dup_")]
    expect_identical(sort(names(layout$duplicateToReal)), sort(dupNodes),
                     info = name)
    expect_identical(sort(unname(layout$duplicateToReal)), spec$duplicated,
                     info = name)
  }
})

test_that(
  "each exemplar pedigree's direct layout marks exactly one union as
   consanguineous -- the expected mating, whose children are exactly the
   inbred animals (including the subtle F = 1/32 linebred case)", {
  for (name in names(.exemplarSpecs)) {
    spec <- .exemplarSpecs[[name]]
    ped <- .readExemplarPedigree(name)
    layout <- makePedigreeMatingLayout(ped, edgeStyle = "direct")
    marked <- .consanguineousEdges(layout)
    expect_identical(nrow(marked), 2L, info = name)
    expect_true(all(marked$width == 4), info = name)
    unionId <- unique(marked$to)
    expect_length(unionId, 1L)
    expect_true(all(startsWith(unionId, "__union_")), info = name)
    expect_identical(sort(.realIds(marked$from, layout)),
                     sort(spec$consanguineousMating), info = name)
    childEdges <- layout$edges[layout$edges$from %in% unionId, ]
    expect_identical(sort(.realIds(childEdges$to, layout)),
                     sort(names(spec$inbred)), info = name)
  }
})

test_that(
  "each exemplar pedigree's direct layout traces back to exactly the CSV's
   (child, sire, dam) relations -- every union drawn with one male and one
   female parent, duplicates resolved to their real ids", {
  for (name in names(.exemplarSpecs)) {
    ped <- .readExemplarPedigree(name)
    layout <- makePedigreeMatingLayout(ped, edgeStyle = "direct")
    traced <- .traceDirectTriples(ped, layout)
    expect_identical(traced$badUnions, character(), info = name)
    expected <- ped[!is.na(ped$sire), c("id", "sire", "dam")]
    expected <- expected[order(expected$id), , drop = FALSE]
    rownames(expected) <- NULL
    expect_identical(traced$triples, expected, info = name)
  }
})

## ---- edgeStyle = "rectilinear" -------------------------------------------

test_that(
  "each exemplar pedigree's rectilinear layout keeps the owner-approved
   structure: node/edge counts, the same drawn-twice animals as the direct
   layout, and only known routing-waypoint node kinds", {
  for (name in names(.exemplarSpecs)) {
    spec <- .exemplarSpecs[[name]]
    ped <- .readExemplarPedigree(name)
    layoutD <- makePedigreeMatingLayout(ped, edgeStyle = "direct")
    layoutR <- .layoutCapturingWarnings(ped, "rectilinear")$layout
    expect_identical(nrow(layoutR$nodes), spec$rectilinearNodes, info = name)
    expect_identical(nrow(layoutR$edges), spec$rectilinearEdges, info = name)
    expect_identical(layoutR$duplicateToReal, layoutD$duplicateToReal,
                     info = name)
    internal <- layoutR$nodes$id[startsWith(layoutR$nodes$id, "__")]
    known <- grepl("^__(union|dup)_", internal) |
      grepl(.kExemplarWaypointPattern, internal)
    expect_identical(internal[!known], character(), info = name)
  }
})

test_that(
  "the rectilinear collision warning is pinned deliberately: no warning
   for any of the five exemplars", {
  ## Found S692 (2026-09-16), pinned S693 (2026-09-17): the linebreeding and
  ## half-sib rectilinear layouts each reported 2 unresolved same-row
  ## edge-node collisions. The warning was already present when the owner
  ## approved these exact renders as legible at S691's visual gate, so it
  ## was pinned as accepted behavior, not suppressed. If a routing change
  ## resolves (or adds) collisions, this test fails on purpose: re-render,
  ## get the drawing re-reviewed, then update the expectation.
  ## CHANGED S715: arc-verified roundness selection retires the chord
  ## heuristic -- of the 4 pinned residuals, 1 was a chord false positive
  ## and the other 3 TRUE arc-disc collisions are fully cleared by the
  ## roundness ladder, so all five exemplars now render warning-free
  ## (specs' rectilinearCollisionWarning flipped to FALSE; renders
  ## owner-re-reviewed at the S715 GREEN gate per the rule above).
  for (name in names(.exemplarSpecs)) {
    spec <- .exemplarSpecs[[name]]
    ped <- .readExemplarPedigree(name)
    warnings <- .layoutCapturingWarnings(ped, "rectilinear")$warnings
    if (spec$rectilinearCollisionWarning) {
      expect_length(warnings, 1L)
      expect_match(warnings,
        paste0("^makePedigreeMatingLayout\\(\\): 2 same-row edge-node ",
               "collision\\(s\\) could not be fully resolved"),
        info = name)
    } else {
      expect_identical(warnings, character(), info = name)
    }
  }
})

test_that(
  "each exemplar pedigree's rectilinear layout keeps the consanguineous
   marker on the same mating as the direct layout", {
  for (name in names(.exemplarSpecs)) {
    spec <- .exemplarSpecs[[name]]
    ped <- .readExemplarPedigree(name)
    layoutR <- .layoutCapturingWarnings(ped, "rectilinear")$layout
    marked <- .consanguineousEdges(layoutR)
    expect_identical(nrow(marked), 2L, info = name)
    expect_true(all(marked$width == 4), info = name)
    expect_length(unique(marked$to), 1L)
    expect_true(all(startsWith(marked$to, "__union_")), info = name)
    expect_identical(sort(.realIds(marked$from, layoutR)),
                     sort(spec$consanguineousMating), info = name)
  }
})

test_that(
  "each exemplar pedigree's rectilinear routing nets each carry one union's
   descent to exactly that union's own children -- no sibship bar or drop
   line attaches a parent or an unrelated animal, and no union is left
   unrouted", {
  for (name in names(.exemplarSpecs)) {
    ped <- .readExemplarPedigree(name)
    layoutD <- makePedigreeMatingLayout(ped, edgeStyle = "direct")
    layoutR <- .layoutCapturingWarnings(ped, "rectilinear")$layout
    nets <- .rectilinearNetViolations(layoutR, layoutD)
    expect_gt(nets$nNets, 0L)
    expect_identical(nets$violations, character(), info = name)
  }
})
