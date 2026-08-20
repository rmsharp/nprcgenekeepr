## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Tests for .positionMatingUnitForestBJL() -- Pedigree Diagram Walker/BJL redesign,
## Phase 2a (adapter mechanics only; docs/planning/pedigree-diagram-walker-bjl-
## apportioning-redesign-plan.md "Phase 2 -- Pedigree adapter, parallel to production,
## A/B verified", as amended by docs/planning/pedigree-diagram-walker-bjl-phase1b-
## mixed-gen-reconciliation.md's S3 mechanism and S8 seam-resolution formula).
##
## Implements the 3-tier reconciliation the design note settles on:
##   Tier 1: genuine-tree BJL (.positionTreeApportion(), Phase 1a, unchanged) via a
##     CHILDREN(individual) accessor that reattaches an anchored union's real
##     children directly onto the anchor (S3.2) -- a mating unit itself is NEVER a
##     tree-recursion node -- terminated by a reinstated, gen-grouped sweepMinSep()
##     backstop (S3.1.1), run ONCE.
##   Tier 2: for every ANCHORED unit, x_raw = midpoint(real children's FINAL Tier-1
##     x), then an exact-tie sweep among unions + genuine nodes at the same gen
##     (S3.3.3/S3.4).
##   Tier 3: for every B1 (true fold-in) or B3 (genuine duplicate) non-anchor
##     occurrence, a derived point off its own unit's FINAL x -- the B1 sub-case
##     folds orderBySex's old post-hoc swap directly into the formula (S8.1):
##       qualifies(U): mateCount(P)==1 && mateCount(M)==1 && !hasOwnDirectChild(P)
##         && sireId/damId %in% realIds && unambiguous opposite sex
##       if qualifies(U): M_repr.x = P.x(FINAL) + sign(M)*minSep*0.4   -- S8's fix:
##         anchored on P's OWN final x, never U.x(FINAL) -- see S8.2's proof of why
##         this is unconditionally correct for any sweepMinSep()-induced drift,
##         where the OLD (U.x(FINAL)-anchored) formula was not.
##       else: M_repr.x = U.x(FINAL) + minSep*0.4   -- unchanged fallback, sign +1.
##     B2 (M has a parent edge or her own D5 direct child) gets NO derived point --
##     the render layer points directly at M's own, already-final genuine x.
##
## Deliberately OUT of THIS session's scope (2a), per the owner-directed split
## documented in SESSION_NOTES.md/BACKLOG.md (Phase 2's own "splittable if too
## large" allowance, parent plan S Migration Path Phase 2): the reusable
## chromote-based live-render helper, and the real 375-individual fixture's own
## zero-coincidence/single-child-union-prevalence measurements -- both deferred to
## a dedicated Phase 2b session. Every fixture below is synthetic or hand-built,
## matching test_positionMatingUnitForest.R's own existing-fixture style. This is a
## real, disclosed gap, not a silent one: Phase 2b still owes the real-fixture A/B
## verification the parent plan's own Verification Plan names as the single most
## important gate in the whole migration.
##
## Oracle provenance for the numerically-exact fixtures below (Tests 1, 2, 5, 6, 11,
## 13, 14, 15): derived this session by actually running Tier 1's own mechanics
## (CHILDREN(individual), .buildForestChildrenOf() + .positionTreeApportion() from
## the existing Phase 1a engine, then a gen-grouped sweepMinSep() backstop copied
## byte-for-byte from R/makePedigreeDiagramData.R's own shipped push semantics
## including its exact order(x, ids, method="radix") tie-break) against each
## fixture -- never hand-derived or guessed, matching C2-3's own "strong, exact-
## value oracle" requirement and this investigation's own established discipline.

## ---- test helpers (not exported, local to this file) ------------------

.nodeKind <- function(ids) {
  ifelse(grepl("^__union_", ids), "union",
         ifelse(grepl("^__dup_", ids), "duplicate", "individual"))
}

## ---- 1. P/C1/P-union-M/C2: individual anchor's CHILDREN() mixes a direct D5 -----
## child and a real union child at the SAME recursion level -- S1(a)'s own fixture.

test_that(".positionMatingUnitForestBJL positions an anchor whose CHILDREN() mixes
           a direct D5 child and a real mating-unit child: the anchor's own x is
           the exact midpoint of BOTH children's final x (computed directly from
           those children, not stated in terms of the union), and the union's own
           x_raw independently equals its one real child's x (S1(a)/S3.2)", {
  ped <- data.frame(
    id = c("ANCH", "MATE", "C1", "C2"),
    sire = c(NA, NA, "ANCH", "ANCH"), dam = c(NA, NA, NA, "MATE"),
    sex = c("M", "F", "M", "F"), gen = c(0L, 0L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForestBJL(ped, forest)

  anchX <- pos$x[pos$id == "ANCH"]
  c1X <- pos$x[pos$id == "C1"]
  c2X <- pos$x[pos$id == "C2"]
  expect_equal(anchX, (c1X + c2X) / 2, tolerance = 1e-9)

  unitId <- forest$matingUnits$id[1L]
  unitX <- pos$x[pos$id == unitId]
  expect_equal(unitX, c2X, tolerance = 1e-9)  # union's one real child == its own x
})

## ---- 2. Mating unit with >=3 real children + a true B1 free-pass mate -----------

test_that(".positionMatingUnitForestBJL positions a >=3-child union's x as the exact
           midpoint of all 3 real children, and its B1 free-pass mate's derived
           point at U.x(FINAL) + minSep*0.4 (S2, S8.1's unchanged fallback branch --
           qualifies() holds here too since the anchor is male, so sign=+1 matches
           the fallback exactly)", {
  ped <- data.frame(
    id = c("ANCH", "MATE", "C1", "C2", "C3"),
    sire = c(NA, NA, "ANCH", "ANCH", "ANCH"),
    dam = c(NA, NA, "MATE", "MATE", "MATE"),
    sex = c("M", "F", "F", "M", "F"), gen = c(0L, 0L, 1L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForestBJL(ped, forest)

  unitId <- forest$matingUnits$id[1L]
  unitX <- pos$x[pos$id == unitId]
  kidsX <- pos$x[pos$id %in% c("C1", "C2", "C3")]
  ## Tolerance, not exact equality: ANCH's own CHILDREN() set here is
  ## EXACTLY this union's real children, so her Tier-1 x and the union's
  ## Tier-2 raw midpoint coincide exactly at the same gen -- Tier 2's own
  ## exact-tie sweep (S3.4) legitimately nudges the union by +1e-3.
  expect_equal(unitX, mean(kidsX), tolerance = 2e-3)

  expect_equal(nrow(forest$duplicates), 0L)  # MATE is B1, not B3 -- no __dup_ row
  ## This union QUALIFIES (S8.1): ANCH male, mateCount 1 each, no direct
  ## child, unambiguous sex -- so MATE's derived point is anchored on
  ## ANCH's own Tier-1 x directly (S8's own fix), NOT on the union's own
  ## (nudged) x -- the two differ by exactly the 1e-3 nudge above, which
  ## is precisely the point: qualifying B1 derivation is immune to a
  ## union-level nudge because it never reads the union's x at all.
  anchX <- pos$x[pos$id == "ANCH"]
  mateX <- pos$x[pos$id == "MATE"]
  expect_equal(mateX, anchX + 0.4, tolerance = 1e-9)
})

## ---- 3. A B3 duplicate occurrence anchoring elsewhere in a different branch -----

test_that(".positionMatingUnitForestBJL gives a genuine B3 duplicate a derived
           point off its OWN mating unit's x, byte-identical in formula to a B1
           free-pass point (S3.3.1a: B3 is never gated the way B1 is)", {
  ## D anchors D x G (both gen1 vs G's gen0 -- D wins). D ALSO mates with E,
  ## but E is deeper (gen2, her own 2-generation ancestry) and so E, not D,
  ## anchors D x E -- D is duplicated there instead (matching the real
  ## GA204Z/8LKBV9 precedent: an individual can legitimately anchor some of
  ## his own mating units and be duplicated at others, never a uniform rule).
  ped2 <- data.frame(
    id = c("F1", "F2", "D", "G", "F3", "EGP1", "EGP2", "E", "H"),
    sire = c(NA, NA, "F1", NA, "D", NA, NA, "EGP1", "D"),
    dam = c(NA, NA, "F2", NA, "G", NA, NA, "EGP2", "E"),
    sex = c("M", "F", "M", "F", "M", "M", "F", "F", "M"),
    gen = c(0L, 0L, 1L, 0L, 1L, 0L, 0L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped2)
  expect_equal(nrow(forest$duplicates), 1L)
  dupRow <- forest$duplicates[1L, ]
  expect_equal(dupRow$realId, "D")

  pos <- .positionMatingUnitForestBJL(ped2, forest)
  dupUnitX <- pos$x[pos$id == dupRow$matingUnitId]
  dupX <- pos$x[pos$id == dupRow$id]
  expect_equal(dupX, dupUnitX + 0.4, tolerance = 1e-9)
  ## D's own genuine (anchored-unit-derived) position is untouched by the dup.
  expect_false(is.na(pos$x[pos$id == "D"]))
})

## ---- 4. Forest roots spanning 2+ gens under the synthetic super-root ------------
## S1(d)/S3.1.1's own backstop: a caller-supplied 'gen' disagreeing with the
## structural recursion depth (legal -- .positionMatingUnitForest()'s own
## contract takes 'gen' as caller-supplied, validated against nothing).

test_that(".positionMatingUnitForestBJL's sweepMinSep() backstop separates 2
           independent forest roots forced to the SAME rendered gen despite one
           being, structurally, several recursion levels deeper (S1(d), general
           case of S3.1.1's own F0/D/C mechanism)", {
  ped <- data.frame(
    id = c("F0", "D", "C", "R2"),
    sire = c(NA, "F0", "S", NA), dam = c(NA, NA, "D", NA),
    sex = c("M", "F", "M", "F"),
    gen = c(0L, 1L, 0L, 0L),  # C's true recursion depth is 2; rendered gen forced 0
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForestBJL(ped, forest)
  gen0 <- pos[.nodeKind(pos$id) == "individual" & pos$gen == 0L, ]
  expect_true(nrow(gen0) >= 2L)
  gaps <- diff(sort(gen0$x))
  expect_true(all(gaps >= 1L - 1e-6),
              info = paste("gen-0 x values:", paste(sort(gen0$x), collapse = ", ")))
})

## ---- 5. A grandchild simultaneously a reattached real child AND her own -----
## qualifying orderBySex anchor (P role) -- S8's formula must read her Tier-1
## FINAL x, not a relative/pre-super-root-accumulation intermediate.

test_that(".positionMatingUnitForestBJL correctly folds a grandchild's own
           qualifying union into S8's formula, reading her Tier-1 FINAL x (a
           reattached real child 2 recursion levels deep) as P.x, not a stale
           intermediate", {
  ped <- data.frame(
    id = c("GGP1", "GGP2", "GP", "GPMATE", "GX", "Y", "Z"),
    sire = c(NA, NA, "GGP1", NA, "GPMATE", NA, "GX"),
    dam = c(NA, NA, "GGP2", NA, "GP", NA, "Y"),
    sex = c("M", "F", "F", "M", "F", "M", "F"),
    gen = c(0L, 0L, 1L, 0L, 2L, 0L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForestBJL(ped, forest)

  gxUnit <- forest$matingUnits$id[forest$matingUnits$anchor == "GX" &
                                     !is.na(forest$matingUnits$anchor)]
  expect_equal(length(gxUnit), 1L)  # GX (deeper gen) anchors her own union, not Y

  gxX <- pos$x[pos$id == "GX"]
  yX <- pos$x[pos$id == "Y"]
  expect_equal(yX, gxX - 0.4, tolerance = 1e-9)  # F anchor, M mate -> sign = -1
  expect_true(yX < gxX)
})

## ---- 6. WCPXHD-shaped hub (mateCount(P)==1 gate excludes the fold-in formula) ---

test_that(".positionMatingUnitForestBJL's qualifies() mateCount(M)==1 conjunct
           (S8.2/S8.5) correctly EXCLUDES a 5-union hub from the fold-in formula
           at every one of her mates' unions -- each B1/B3 representative sits
           near its OWN union's x, not clustered near a single shared anchor
           point (S8.2's own load-bearing-gate finding)", {
  nMates <- 5L
  ped <- data.frame(
    id = c("HUB", paste0("MATE", seq_len(nMates)), paste0("KID", seq_len(nMates))),
    sire = c(NA, rep(NA, nMates), rep("HUB", nMates)),
    dam = c(NA, rep(NA, nMates), paste0("MATE", seq_len(nMates))),
    sex = c("M", rep("F", nMates), rep("M", nMates)),
    gen = c(0L, rep(0L, nMates), rep(1L, nMates)),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  expect_equal(nrow(forest$matingUnits), nMates)
  expect_true(all(forest$matingUnits$anchor != "HUB"))  # HUB loses every tie
  expect_equal(nrow(forest$duplicates), nMates - 1L)    # 1 B1 primary + 4 B3 dups

  pos <- .positionMatingUnitForestBJL(ped, forest)
  hubReps <- pos$x[pos$id == "HUB" |
                      (grepl("^__dup_HUB_", pos$id))]
  expect_equal(length(hubReps), nMates)
  ## NOT clustered: if the gate were bypassed, all 5 would sit within
  ## +-minSep*0.4 of one shared point. They must instead span roughly the
  ## full width of the 5 unions' own spread.
  expect_true(diff(range(hubReps)) > 1L)
})

## ---- 7/8. hasOwnDirectChild(M) forces B2 in EVERY non-anchor occurrence ---------

test_that(".positionMatingUnitForestBJL classifies a founder with her own D5
           direct child as B2 in a separate non-anchor union occurrence: no
           derived point, exactly one write to her own genuine position (S3.3.1,
           S3.3.2)", {
  ped <- data.frame(
    id = c("MOM", "DAD", "OWNCHILD", "OTHERANCH", "SHAREDKID"),
    sire = c(NA, NA, "MOM", NA, "OTHERANCH"),
    dam = c(NA, NA, NA, NA, "MOM"),
    sex = c("F", "M", "F", "M", "F"),
    gen = c(0L, 0L, 1L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  expect_equal(nrow(forest$duplicates), 0L)  # B2 never gets a __dup_ entry either

  pos <- .positionMatingUnitForestBJL(ped, forest)
  momRows <- pos[pos$id == "MOM", ]
  expect_equal(nrow(momRows), 1L)   # exactly one write to MOM's position
  expect_false(is.na(momRows$x))
  expect_false(any(grepl("^__dup_MOM_", pos$id)))
})

## ---- 9. A B2 non-anchor party (own parent edge) excludes reordering entirely ----

test_that(".positionMatingUnitForestBJL's qualifies() gate excludes a B2 non-anchor
           party (her own real parent edge, S1060's !hasParentEdge(M) conjunct)
           from the fold-in formula entirely -- neither party's position is
           altered by the union (S3.1.2 Step 3, S8's B2/B3 untouched-by-S8 note)", {
  ped <- data.frame(
    id = c("GP1", "GP2", "MOM", "XGF1", "XGF2", "XPAR", "X", "C"),
    sire = c(NA, NA, "GP1", NA, NA, "XGF1", "XPAR", "X"),
    dam = c(NA, NA, "GP2", NA, NA, NA, NA, "MOM"),
    sex = c("M", "F", "F", "M", "F", "M", "M", "F"),
    gen = c(0L, 0L, 1L, 0L, 0L, 1L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  unitId <- forest$matingUnits$id[forest$matingUnits$sire == "X" |
                                     forest$matingUnits$dam == "X"]
  expect_equal(forest$matingUnits$anchor[forest$matingUnits$id == unitId], "X")
  expect_equal(forest$matingUnits$nonAnchor[forest$matingUnits$id == unitId], "MOM")
  expect_equal(nrow(forest$duplicates), 0L)

  pos <- .positionMatingUnitForestBJL(ped, forest)
  momRows <- pos[pos$id == "MOM", ]
  expect_equal(nrow(momRows), 1L)  # exactly one write to MOM's position (S9)
  expect_false(is.na(momRows$x))
})

## ---- 10. Tier-2's exact-tie sweep resolves a union/genuine-node coincidence -----
## before Tier 3 reads it -- a general property check (S3.4/S3.4.1-3), not a
## single hand-verified numeric collision.

test_that(".positionMatingUnitForestBJL has no exact x/gen coincidence among
           individual + union + duplicate nodes together on a moderately complex
           multi-branch synthetic fixture, confirming Tier 2's own exact-tie sweep
           (unions vs. genuine nodes, unions vs. unions) actually fires before
           Tier 3 reads any union's x (S3.4)", {
  ped <- data.frame(
    id = c("A1", "A2", "B1", "B2", "C1", "C2",
           "KA", "KB1", "KB2", "KC"),
    sire = c(NA, NA, NA, NA, NA, NA, "A1", "B1", "B1", "C1"),
    dam = c(NA, NA, NA, NA, NA, NA, "A2", "B2", "B2", "C2"),
    sex = c("M", "F", "M", "F", "M", "F", "F", "M", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 0L, 0L, 1L, 1L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForestBJL(ped, forest)
  nonDup <- pos[.nodeKind(pos$id) != "duplicate", ]
  key <- paste(round(nonDup$x, 6), nonDup$gen)
  expect_false(any(duplicated(key)))
})

## ---- 11. Anchor P (female, qualifying) with a true B1 mate M --------------------

test_that(".positionMatingUnitForestBJL leaves a qualifying female anchor's own x
           unmodified and derives her B1 mate's point at P.x(FINAL) - minSep*0.4,
           strictly left of P (S8.1, sign = -1 for F-anchor/M-mate)", {
  ped <- data.frame(
    id = c("ANCHF", "MATEM", "C1"),
    sire = c(NA, NA, "MATEM"), dam = c(NA, NA, "ANCHF"),
    sex = c("F", "M", "F"), gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForestBJL(ped, forest)

  anchX <- pos$x[pos$id == "ANCHF"]
  c1X <- pos$x[pos$id == "C1"]
  expect_equal(anchX, c1X, tolerance = 1e-9)  # sole child -> anchor unmodified

  mateX <- pos$x[pos$id == "MATEM"]
  expect_equal(mateX, anchX - 0.4, tolerance = 1e-9)
  expect_true(mateX < anchX)
})

## ---- 12. A B2 worked example: qualifying-SHAPED union, non-anchor has her own --
## parent edge -- excluded from reordering, neither position touched.

test_that(".positionMatingUnitForestBJL excludes a qualifying-shaped union from
           reordering when the non-anchor party is B2 (her own parent edge):
           neither party's x differs from its own untouched genuine/derived
           value (S3.1.2 Step 3)", {
  ## MIA has her own parent edge (GP1 x GP2), so she is B2 whenever she is a
  ## non-anchor party. YALE is given her own 2-generation ancestry so YALE
  ## (deeper) anchors the YALE x MIA union and MIA becomes the non-anchor --
  ## the qualifying-SHAPED union whose non-anchor party is actually B2.
  ped2 <- data.frame(
    id = c("GP1", "GP2", "MIA", "YGF1", "YGF2", "YPAR", "YALE", "KID"),
    sire = c(NA, NA, "GP1", NA, NA, "YGF1", "YPAR", "YALE"),
    dam = c(NA, NA, "GP2", NA, NA, "YGF2", NA, "MIA"),
    sex = c("M", "F", "F", "M", "F", "M", "M", "M"),
    gen = c(0L, 0L, 1L, 0L, 0L, 1L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest2 <- .buildMatingUnitForest(ped2)
  unitId2 <- forest2$matingUnits$id[forest2$matingUnits$sire == "YALE" |
                                       forest2$matingUnits$dam == "YALE"]
  expect_equal(forest2$matingUnits$anchor[forest2$matingUnits$id == unitId2], "YALE")
  expect_equal(forest2$matingUnits$nonAnchor[forest2$matingUnits$id == unitId2], "MIA")
  expect_equal(nrow(forest2$duplicates), 0L)  # B2 never gets a __dup_ entry

  pos2 <- .positionMatingUnitForestBJL(ped2, forest2)
  miaRows <- pos2[pos2$id == "MIA", ]
  expect_equal(nrow(miaRows), 1L)
  expect_false(is.na(miaRows$x))
})

## ---- 13. F0/D/[S(dangling) x D]/C -- S3.1.1's own required counter-example ------

test_that(".positionMatingUnitForestBJL's reinstated sweepMinSep() backstop
           separates a founder from her own grandchild (reachable only through a
           dangling co-parent) by at least minSep, even though both collapse to
           the identical relative x under the genuine-tree recursion alone
           (S3.1.1's own F0/D/C counter-example, executed)", {
  ped <- data.frame(
    id = c("F0", "D", "C"),
    sire = c(NA, "F0", "S"), dam = c(NA, NA, "D"),
    sex = c("M", "F", "M"), gen = c(0L, 1L, NA_integer_),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForestBJL(ped, forest)
  f0X <- pos$x[pos$id == "F0"]
  cX <- pos$x[pos$id == "C"]
  expect_equal(pos$gen[pos$id == "C"], 0L)  # NA forced to 0 -- collides with F0
  expect_true(abs(cX - f0X) >= 1L - 1e-6,
              info = paste("F0.x=", f0X, "C.x=", cX))
})

## ---- 14. THE regression test: sweepMinSep() moves a qualifying union's own ------
## real child -- S7's counter-example, now expected to PASS under S8's fix.

test_that(".positionMatingUnitForestBJL's S8 fix holds even when sweepMinSep()
           is forced to move a qualifying union's own real child (S7's exact
           counter-example shape, S8.2's proof): the fold-in formula still
           correctly places the B1 mate strictly left of the anchor, because it
           reads P.x directly rather than the drifted U.x(FINAL)", {
  ped <- data.frame(
    id = c("ANCHF", "MATEM", "C1", "AG"),
    sire = c(NA, NA, "MATEM", "Z"), dam = c(NA, NA, "ANCHF", "C1"),
    sex = c("F", "M", "F", "M"),
    gen = c(0L, 0L, 1L, 1L),  # AG's TRUE recursion depth is 2 -- forced to 1
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  unitId <- forest$matingUnits$id[1L]
  pos <- .positionMatingUnitForestBJL(ped, forest)

  anchX <- pos$x[pos$id == "ANCHF"]
  c1X <- pos$x[pos$id == "C1"]
  unitX <- pos$x[pos$id == unitId]
  ## Confirm this fixture actually exercises the seam: C1 was pushed, so the
  ## union's FINAL x has drifted away from the anchor's own x (the exact
  ## condition S7 found broke the OLD U.x(FINAL)-anchored formula).
  expect_true(abs(unitX - anchX) > 0.4 + 1e-9,
              info = paste("unitX=", unitX, "anchX=", anchX, "-- fixture did not",
                            "force the intended drift; re-check the collider"))

  mateX <- pos$x[pos$id == "MATEM"]
  expect_equal(mateX, anchX - 0.4, tolerance = 1e-9)  # S8: anchored on P.x, not U.x
  expect_true(mateX < anchX)
})

## ---- 15. Obligation 1 (S8.4): sweepMinSep() pushes P HERSELF, not just her -----
## children -- P.x must be read post-sweep, never a pre-sweep intermediate.

test_that(".positionMatingUnitForestBJL reads the anchor's own x from its
           genuinely final, post-sweepMinSep() value when the backstop pushes the
           anchor herself (not her children) -- S8.4 Obligation 1's own required
           regression case", {
  ped <- data.frame(
    id = c("ANCHF", "MATEM", "C1", "AA"),
    sire = c(NA, NA, "MATEM", "Z"), dam = c(NA, NA, "ANCHF", "C1"),
    sex = c("F", "M", "F", "M"),
    gen = c(0L, 0L, 1L, 0L),  # AA's TRUE recursion depth is 3 -- forced to 0
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForestBJL(ped, forest)

  anchX <- pos$x[pos$id == "ANCHF"]
  c1X <- pos$x[pos$id == "C1"]
  ## Confirm the fixture actually pushed the ANCHOR (not C1): the anchor's own
  ## x must have moved off the union's raw child-midpoint (c1X, since C1 is the
  ## union's only child and was itself untouched).
  expect_true(abs(anchX - c1X) > 1e-9,
              info = paste("anchX=", anchX, "c1X=", c1X, "-- fixture did not",
                            "push the anchor; re-check the collider"))

  mateX <- pos$x[pos$id == "MATEM"]
  ## A careless implementation reading a pre-sweep P.x intermediate (== c1X,
  ## since pre-sweep the anchor and her only child coincide) would compute
  ## mateX = c1X - 0.4, not anchX - 0.4. Assert the POST-sweep value was used.
  expect_equal(mateX, anchX - 0.4, tolerance = 1e-9)
  expect_false(isTRUE(all.equal(mateX, c1X - 0.4)))
})

## ---- Property tests (parent plan's own Phase 2 "What DONE looks like") ---------

test_that(".positionMatingUnitForestBJL guarantees at least minSep between every
           pair of same-generation REAL individual nodes on the real
           GA204Z/8LKBV9 loop fixture (the same multi-anchor fixture the OLD
           function's own sweepMinSep regression test uses) -- the
           property-level successor to that test, real-375-fixture
           measurement explicitly deferred to Phase 2b. A B1 derived point
           can share its underlying individual's own real id with a genuine
           node (S3.3.1), so this fixture is deliberately one where no B1
           occurrence exists at all (8LKBV9's only non-anchor occurrence is
           a B3 __dup_ marker, unambiguously excluded by id prefix) --
           keeping .nodeKind()'s id-pattern classification reliable here", {
  ped <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  expect_equal(nrow(forest$duplicates), 1L)  # 8LKBV9's own B3 marker, confirmed
  expect_equal(forest$duplicates$realId, "8LKBV9")
  pos <- .positionMatingUnitForestBJL(ped, forest)
  ## A B1/B2 non-anchor party's derived/genuine point can share its own
  ## real id with what .nodeKind() classifies as a plain "individual" node
  ## (S3.3.1) -- e.g. 8DKELJ/G8EBU9/8P17E3 here are each B1, not part of
  ## this fixture's own duplicate count. sweepMinSep()'s backstop only
  ## guarantees separation among genuine Tier-1 nodes (real individuals
  ## who are never a "nonAnchor" of any unit), so exclude every id that
  ## IS a nonAnchor anywhere, rather than trust id-pattern alone.
  nonAnchorIds <- unique(forest$matingUnits$nonAnchor[
    !is.na(forest$matingUnits$nonAnchor)])
  indiv <- pos[.nodeKind(pos$id) == "individual" & !(pos$id %in% nonAnchorIds), ]
  for (g in sort(unique(indiv$gen))) {
    xs <- sort(indiv$x[indiv$gen == g])
    if (length(xs) < 2L) next
    expect_true(all(diff(xs) >= 1L - 1e-6),
                info = paste("gen", g, "x values:", paste(xs, collapse = ", ")))
  }
})

test_that(".positionMatingUnitForestBJL: every ANCHORED mating unit's x equals the
           exact midpoint of its own real children's final x -- one formula, no
           OR-branches, no clamp exceptions, including a single-child union
           (Track 3's parent-span clamp and Track 6's finalUnitX override are both
           gone by construction under 2b)", {
  ped <- data.frame(
    id = c("P1", "P2", "C1", "C2", "C3", "P3", "P4", "C4"),
    sire = c(NA, NA, "P1", "P1", "P1", NA, NA, "P3"),
    dam = c(NA, NA, "P2", "P2", "P2", NA, NA, "P4"),
    sex = c("M", "F", "M", "F", "M", "M", "F", "F"),
    gen = c(0L, 0L, 1L, 1L, 1L, 0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForestBJL(ped, forest)
  anchored <- forest$matingUnits[!is.na(forest$matingUnits$anchor), , drop = FALSE]
  for (i in seq_len(nrow(anchored))) {
    unitId <- anchored$id[i]
    kids <- forest$childEdges$to[forest$childEdges$from == unitId]
    ## Tolerance, not exact equality: each anchor here has no OTHER
    ## CHILDREN() besides this one union's real children, so the anchor's
    ## own Tier-1 x and the union's raw midpoint coincide exactly at the
    ## same gen -- Tier 2's own exact-tie sweep (S3.4) legitimately nudges
    ## the union by +1e-3 in that case (see Test 2's own fixture/comment).
    expect_equal(pos$x[pos$id == unitId], mean(pos$x[pos$id %in% kids]),
                 tolerance = 2e-3, info = unitId)
  }
})

test_that(".positionMatingUnitForestBJL produces exactly nrow(ped) +
           nrow(forest$duplicates) + nrow(forest$matingUnits) rows, with no NA x
           or gen, on a fixture combining several of the classification cases
           above (structural parity with the OLD function's own output contract)", {
  ped <- data.frame(
    id = c("A1", "A2", "B", "C1", "C2", "D", "E"),
    sire = c(NA, NA, "A1", "A1", "A1", NA, "D"),
    dam = c(NA, NA, "A2", "A2", "A2", NA, "B"),
    sex = c("M", "F", "F", "M", "F", "M", "M"),
    gen = c(0L, 0L, 1L, 1L, 1L, 0L, 2L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForestBJL(ped, forest)
  expect_equal(nrow(pos),
               nrow(ped) + nrow(forest$duplicates) + nrow(forest$matingUnits))
  expect_false(any(is.na(pos$x)))
  expect_false(any(is.na(pos$gen)))
})
