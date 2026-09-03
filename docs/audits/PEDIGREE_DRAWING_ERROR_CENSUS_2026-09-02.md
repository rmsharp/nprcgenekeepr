# Pedigree-Drawing Error Census — Every Fixture, Six Error Classes

**Date:** 2026-09-02 · **Session:** S668 · **Type:** measurement audit (no code changes to the
package; a new `data-raw/` scoreboard script and this report)

**Audited:** the pedigree diagram `makePedigreeMatingLayout(edgeStyle = "rectilinear")` draws
(the Diagram tab's default), for every fixture this project uses to judge drawing fidelity.

**Question asked (`BACKLOG.md` Up Next, owner-directed S667 via `AskUserQuestion`):** after
~24 sessions of one-defect-at-a-time fixes to the layout engine, every current drawing still has
multiple visible errors. Before deciding between (A) more per-defect fixes and (C) a joint
solver, count the errors of each class on every fixture and attribute each class to its
mechanism — so the decision rests on measurements, not impressions. **The decision itself is
not made here** (Recommendations, below).

**How to reproduce:** `Rscript data-raw/pedigreeDrawingErrorCensus.R` from the package root.
It prints the scoreboard and every per-fixture table below and writes every finding row —
2,734 of them, with ids — to
[`PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-02_findings.csv`](PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-02_findings.csv)
beside this report. It needs no Chrome; kinship2 (installed locally, never a dependency) is
optional and only feeds the baseline section.

---

## Audit Summary

- **Scope:** 7 fixtures — Track B full (16 subjects, 1 suppressed as isolated), Track B shrunk
  (8), Track C (9), the real 375-animal bundled rhesus pedigree
  (`inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv`), and S667's synthetic multi-family
  fixtures D1 (11), D2 (9), D3 (8). The three Track fixtures are verbatim from
  `data-raw/kinship2FidelityValidation.R`; D1–D3 verbatim from
  `tests/testthat/test_positionMatingUnitForest.R`.
- **Criteria:** six error classes, each with an exact geometric predicate on the rendered
  node/edge tables (px, using the render layer's own constants: 25 px symbol radius, 6 px union
  dot, `xScale` 120, `yScale` 150, `minSep` 1 unit = 120 px):

  | Class | Predicate |
  |---|---|
  | (a) overlapping symbols | two visible nodes on one rendered row, centre distance < sum of radii |
  | (b) union dot off the mate midpoint | \|x(union) − mean(x(anchor node), x(mate node at this unit))\| > 1e-6, both mates on the union's row; sub-classed *on-a-mate* (< 31 px from a mate's centre), *outside-mate-span*, *off-centre* |
  | (c) edge through an unrelated symbol | c1: same-row straight edge with a visible unrelated node strictly inside its x-span (the production repair pass's own predicate), before and after that pass; c2: any straight edge, any orientation, passing inside a visible unrelated node's disc; curved duplicate connectors: chord inside a symbol (heuristic, arc not modelled) |
  | (d) duplicate vs its own real occurrence | same row and < 50 px (overlap), or ≤ 120 px with nothing between (adjacent) |
  | (e) mate off its union's row | the drawn node of either mate on a different row than the union; founder / non-founder |
  | (f) family interleaving | on any one row, two families' x-intervals overlap, or two nodes of different families < `minSep` apart |

  "Unrelated" for (c) excludes the edge's own endpoints and any node graph-adjacent to one of
  them (a bar never flags its own child, a union never flags its own parents) — the same
  exclusion the production pass uses. Every measurement is written fresh in the script,
  independent of the pinned test helpers (owner-directed).
- **Coverage:** 7 of 7 fixtures, all six classes on each (100%). Direct edge style not
  separately censused — node positions are identical between styles; only (c) differs, and the
  rectilinear style is what the app draws by default.
- **Finding count:** 2 critical (structural, formula-level), 2 moderate, 3 minor, 1 incidental.

## Scoreboard

Counts are finding rows (pairs, units, or unit-sides as the class dictates); ids for every row
are in the CSV.

| Fixture | Indiv. | Units | Dups | Families | Jogs | (a) | (b) | (c1) pre → post | (c2) | (c) curved chord | (d) | (e) | (f) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Track B full | 15 | 4 | 0 | 2 | 0 | 0 | 0 | 0 → 0 | 0 | 0 | 0 | 0 | 0 |
| Track B shrunk | 8 | 3 | 0 | 2 | 0 | 0 | 0 | 0 → 0 | 0 | 0 | 0 | 0 | 0 |
| Track C | 9 | 4 | 2 | 1 | 0 | **5** | **3** | 0 → 0 | 0 | 0 | **1** | 0 | 0 |
| Real 375 | 375 | 237 | 102 | 5 | 89 | **288** | **168** | 84 → 0 | **414** | 1,743 (47 connectors) | 0 | **56** | 0 |
| D1 | 11 | 3 | 0 | 2 | 0 | 0 | 0 | 0 → 0 | 0 | 0 | 0 | 0 | 0 |
| D2 | 9 | 3 | 0 | 3 | 0 | 0 | 0 | 0 → 0 | 0 | 0 | 0 | 0 | 0 |
| D3 | 8 | 3 | 0 | 2 | 0 | 0 | 0 | 0 → 0 | 0 | 0 | 0 | 0 | 0 |

The real fixture's pipeline also reports 47 `curved-heuristic` residuals of its own (the
roundness bump applied to duplicate connectors), 0 `straight-residual`. Edge-to-edge touches
(distance exactly equal to the radius sum): 0 on every fixture at the script's 1e-9 tolerance
— S667's floating-point tie (`BH6ZQK`/`8933XB`, d − clearance = −6e-16) is a touch, not an
overlap, and is correctly not counted.

**The two owner-reviewed Track B images and all three synthetic multi-family fixtures are
clean on every class.** Every error in the census is on Track C and the real fixture — and on
the real fixture 264 of the 288 class-(a) rows and 132 of the 168 class-(b) rows come from just
two formulas (Findings #1 and #2).

### Real 375 breakdown (the script's own table, `### Breakdown`)

| Class | Subclass | Relation / note | n | Median value |
|---|---|---|---|---|
| a | overlap | own-union, individual–union | 163 | 0.12 px |
| a | overlap | mates, individual–duplicate | 85 | 48.12 px |
| a | overlap | mates, individual–individual | 28 | 48.00 px |
| a | overlap | mates, duplicate–individual | 5 | 12 px |
| a | overlap | own-union, union–individual | 3 | 17 px |
| a | overlap | unrelated, duplicate–individual | 3 | 12 px |
| a | overlap | unrelated, duplicate–union | 1 | 10 px |
| b | on-a-mate | genuine mate, anchor not a founder | 56 | −0.1995 units |
| b | on-a-mate | B1 mate, anchor a founder | 40 | −0.1995 |
| b | on-a-mate | B1 mate, anchor not a founder | 33 | −0.1995 |
| b | on-a-mate | genuine mate, anchor a founder | 3 | −0.1995 |
| b | off-centre | B1 / genuine | 14 / 7 | 0.21 / 0.05 |
| b | outside-mate-span | B1 / genuine | 10 / 5 | −0.45 / −0.70 |
| c | c2 horizontal, offset row (jogged edge) | waypoint–waypoint–individual / –duplicate | 300 / 72 | 9 px |
| c | c2 vertical | 9 note-kinds | 32 | 0–22 px |
| c | c2 horizontal, symbol row | mate edge vs the other mate's node | 10 | 12 px |
| c | curved chord (heuristic) | 6 note-kinds | 1,743 | — |
| e | non-founder mate off the union's row | all on the non-anchor side; 26/23/6/1 units at 1/2/3/4 rows | 56 | 2 rows |

---

## Method

1. Read `makePedigreeMatingLayout()`, `.buildMatingUnitForest()`, `.positionMatingUnitForest()`'s
   contract, `.addRectilinearWaypoints()`'s bar-row placement, and
   `.resolveEdgeNodeCollisions()`'s jog geometry in `R/makePedigreeDiagramData.R`, then the
   test-local measurement helpers (`test_positionMatingUnitForest.R:20-120, 1197-1215`,
   `test_resolveEdgeNodeCollisions.R:60-108`) as the geometric reference — before writing any
   detector.
2. Wrote `data-raw/pedigreeDrawingErrorCensus.R`: replicates the exported function's pipeline
   step by step (isolated-id pre-filter → forest → positions → direct layout → waypoints →
   repair) so the pre-repair state and the pass's own residuals are visible, and **asserts the
   replica's final node/edge tables are identical to the exported function's own rectilinear
   output** for every fixture (`stopifnot()` in `runPipeline()`) — the census describes the
   drawing the app shows, not a look-alike. Its family partition is cross-checked by count
   against the engine's `.forestComponents()`.
3. Ran it three times: run 1 exposed two definitional errors in the script itself, fixed before
   any number was trusted — class (e) counted each unit twice (one row per off-row side plus one
   per unit), and class (f) compared whole-extent x-ranges, which kinship2's own per-row contour
   packing legitimately lets *touch* (Track B full's two families touch at one x; D1's test
   proves per-row packing is the rule). Run 2 = the numbers here; run 3 (after lint-only edits)
   is byte-identical to run 2 apart from one wording change.
4. Verified the two dominant attributions against the engine directly, not the CSV alone
   (`.positionMatingUnitForest()` raw positions on the real fixture): every union counted as
   "on its anchor" sits exactly `+0.001` from its anchor, whose x is exactly `(min + max) / 2`
   of that unit's children (157 of 157 — a tie, not a near miss), and every "mates 48 px apart"
   pair is exactly 0.400 or 0.401 raw units apart (85 + 22 = 107; see Findings #1/#2). A first
   draft of Finding #1 had claimed each such union sits at the *mean* of its children's x; the
   probe refuted that (0 of 157 — the engine's midpoint is the extremes' midpoint, not the
   mean) and the claim was replaced by the measured one.
5. Compared against the S470 founder-positioning audit's metric and the S595/S667 counts
   already pinned in the test suite (Comparison, below).

---

## Findings

### Finding #1: The union dot is drawn ON its anchor parent's symbol for 157 of 237 real-fixture units (66%) — Tier 2's child-midpoint formula lands on the anchor's own Tier-1 x
- **Severity:** Critical (the single largest class; the exact defect the owner ruled an error in
  S664, fixed in S666 for the 60 "qualifying" units only)
- **Location:** `R/makePedigreeDiagramData.R`, `.positionMatingUnitForest()` Tier 2
  (`x_raw = midpoint(real children's FINAL Tier-1 x)` for every anchored unit) and Tier 1's
  BJL apportioning, which centres a parent over the same children; S652's scoped revert of the
  anchor/mate-midpoint recentre (issue #166) and S666's conditional shift, gated on
  `qualifies()` + `nonAnchorOf %in% b1Ids` (60/237).
- **Description:** 163 individual–union and 3 union–individual class-(a) rows are "own-union";
  157 of them are at 0.12 px (0.001 raw units — the exact-tie sweep's deterministic epsilon).
  Probed directly on raw positions, all 157 of 157: the anchor sits exactly at
  `(min + max) / 2` of the unit's own children's x (Tier 1 centres a parent over its children),
  the union sits at that same midpoint `+ 0.001` (Tier 2's child-midpoint formula, tied with
  the anchor, separated only by the exact-tie sweep's epsilon), and 153 of the 157 anchors have
  exactly one mating unit — the ordinary case. The 6-px dot therefore renders in the middle of
  the 50-px parent symbol. The same 157 + the shifted
  qualifying units' residue account for 132 of the 168 class-(b) rows (*on-a-mate*, 107 of
  them at |dev| = 0.1995 = half the 0.4-unit mate offset of Finding #2).
- **Evidence:** Track C shows it at small scale — `A`/`__union_4` and `X`/`__union_2` at
  0.12 px (the committed `trackC-nprc-rectilinear.png`, dot centred on the square/circle);
  real fixture: `Breakdown` rows 1 and 5. kinship2's own layout of the same 375 animals has
  0 same-row placements closer than 1 unit (Baseline, below).
- **Impact:** the mate line and the child drop appear to originate from one parent's body
  rather than from between the pair — the visual reading S664 called wrong — on two-thirds of
  the units of a production-sized pedigree.
- **Recommendation:** whichever path is chosen, this is one formula, not a search failure: for
  the 177 non-qualifying units the union's x follows the children while the parents are placed
  independently. Either recentre the union on the mate midpoint for every unit (the S646/S652
  "drop the gate" alternative, deferred then for cascade risk that this census cannot rule out
  — it must be re-measured), or let a joint solver place parents and union together.
- **What prevents the dot from simply being placed halfway between the mates (owner's
  question, this session):** nothing structural. The dot's x is one assignment in Tier 2, and
  a hard rule "never inside a parent symbol" is a one-line guard. What stopped it being done
  for every unit is that the dot's x plays two roles at once: it is the mate-line junction
  (which should be between the mates) *and* the top of the children's drop line (which Tier 1
  has placed above the children's centre, at the anchor's own x). Because the mate is bolted on
  *after* the tree at anchor + 0.4, the mate midpoint is 0.2 units (24 px) right of the
  children's centre, so moving the dot there makes the vertical drop off-centre by 24 px in the
  rectilinear style — or, to keep the drop centred, the parents must shift left (S666's root
  case) or the children right (S666's non-root case), which is the move S646 confined to
  "qualifying" pairs because shifting a genuine, tree-positioned mate can break Tier 1's
  spacing, and S652 (issue #166) reverted for the rest rather than accept the off-centre drop.
  kinship2 has no such trade-off because it places parents and children together. The census's
  Recommendation 1 is exactly to try the all-units change and measure what it costs.

### Finding #2: Mates are drawn 0.4 units apart, so two 50-px symbols overlap by 2 px in 107 real-fixture pairs (+2 on Track C) — the non-qualifying B1/duplicate offset `minSep * 0.4`
- **Severity:** Critical (every non-qualifying mated pair; on the real fixture 85 pairs involve
  a duplicate node at 0.401 units and 22 pairs two real nodes at 0.400 — 107 in all, measured on
  raw positions)
- **Location:** `.positionMatingUnitForest()` Tier 3 — `derivedX()`'s B1 branch offset
  (`minSep * 0.4` for a non-qualifying pair; S647 widened it to `minSep` for qualifying pairs
  only, `docs/planning/pedigree-diagram-track7-mate-spacing-plan.md` §4/§8) and the duplicate
  offset `unitX[[itsOwnUnion]] + minSep * 0.4`.
- **Description:** 107 class-(a) *mates* rows at 48.00 or 48.12 px (0.400 / 0.401 units; the
  0.001 is again the tie epsilon). Symbol radius 25 px → 2 px of overlap at the edge. Probed
  directly on raw positions: the mate node placed at each unit sits 0.400 or 0.401 from the
  anchor for exactly these units.
- **Evidence:** Track C `A`/`__dup_Y_1` and `X`/`__dup_A_1` at 48.12 px (visible in
  `trackC-nprc-rectilinear.png` as touching symbols); real fixture `Breakdown` rows 2–3.
  kinship2 places every spouse pair exactly 1.000 apart on all seven fixtures.
- **Impact:** every non-qualifying mated pair reads as a single merged blob at the app's default
  zoom; combined with Finding #1 the dot sits on one half of the blob.
- **Recommendation:** same fork as Finding #1 — the 0.4 constant was chosen when the union
  stood between the mates; with the union on the anchor, 0.4 is the whole spousal separation.

### Finding #3: The same-row repair pass satisfies its own predicate but not the symbol — 33 of 89 jog repairs still cross the symbol they were jogged around
- **Severity:** Moderate
- **Location:** `.resolveEdgeNodeCollisions()` — `jogFraction <- 0.15`, `jogY = level *
  0.15 * localGap`, where `localGap` is the nearest *other* distinct y (the sibship-bar row,
  60 px from a child row).
- **Description:** c1 goes 84 colliding edges / 1,544 obstacle pairs → 0 after the pass. But
  c2 finds 372 waypoint–waypoint (jog level) segments inside a symbol: 220 at 9 px from the
  obstacle's centre (level 1: 0.15 × 60), 136 at 18 px (level 2), 13 at 13.5 px (rows whose
  nearest other row is 90 px away), 2 at 15, 1 at 23.7 — all inside the 25-px radius. The pass
  moves the line off the obstacle's *centre line*, which is what its predicate tests, but not
  out of its *disc*. Jogs on every row 0–7 (13/62/64/78/69/47/30/9 pairs).
- **Evidence:** CSV subclass `c2-horizontal-offset-row`; a jog-level segment at 9 px cannot
  clear a 25-px symbol by construction.
- **Impact:** the 84 pre-repair collisions are visually still there for 33 edges — the repair
  hides them from the test suite's metric, not from the viewer.
- **Recommendation:** parameter-level: the offset must exceed the symbol radius (≥ 26 px; the
  band to the bar row is 60 px, so one or two levels fit), and c2 — not c1 — should be the
  acceptance metric. Independent of the A/C decision.

### Finding #4: 36 unions sit off-centre or outside the mate span by up to 16.5 units — the unions whose genuine parents Tier 1 placed far apart
- **Severity:** Moderate
- **Location:** Tier 2 (union at child midpoint) with both parents genuine tree nodes positioned
  independently.
- **Description:** 21 *off-centre* + 15 *outside-mate-span*; five with |dev| > 1 unit, the
  largest `__union_232` (`ZZMDQ0`/`RK53PX`, mate span 34 units, dot 16.5 from the midpoint) and
  `__union_199` (span 11.9, dot −6.4). These long mate lines are what sweeps the row: they are
  the source of the 84 pre-repair c1 collisions (S595 diagnosed the same mechanism at 150/725
  edges before the union-side pushes) and of the 47 curved-heuristic residuals' crowded rows.
- **Impact:** a mate line crossing dozens of unrelated founders on a wide founder row.
- **Recommendation:** structural — the same fork as #1: either parents move toward their union
  (cascades into Tier 1's spacing) or the union is not tied to the children.

### Finding #5: 56 units (24%) have a non-founder mate drawn 1–4 rows away from the union, with a dogleg — a row-policy difference from kinship2, not a founder defect
- **Severity:** Minor / policy decision
- **Location:** `matingUnits$gen = pmax(sire gen, dam gen)`; a genuine (B2) non-anchor mate
  keeps its own `ped$gen` row; `.addRectilinearWaypoints()` D2 draws the 56 `__proj_` doglegs.
- **Description:** all 56 off-row mates are non-anchor, non-founder, real nodes (never a
  duplicate) 1/2/3/4 rows above the union (26/23/6/1). Founders: **0** — S470's 147/237
  wrong-row parent occurrences (57 on duplicates, 90 on free-pass founders) are down to 56,
  all in the case S470 did not name: a mate who has parents of their own and therefore a
  generation of their own. kinship2's `kindepth(align = TRUE)` moves the shallower spouse down
  to the deeper one's row where it can. Row = `findGeneration()` is a deliberate feature of this
  package's diagram (the tooltip shows it), so this is the owner's call, not a bug to fix
  silently.
- **Evidence:** CSV class `e`; the 56 unit ids: `__union_103`, `_109`, `_117`, `_119`, `_121`,
  `_131`, `_134`, `_135`, `_137`, `_138`, `_139`, `_140`, `_143`, `_145`, `_146`, `_147`,
  `_152`, `_158`, `_161`, `_163`, `_166`, `_167`, `_168`, `_169`, `_171`, `_172`, `_175`,
  `_176`, `_177`, `_179`, `_182`, `_185`, `_186`, `_188`, `_196`, `_198`, `_203`, `_206`,
  `_208`, `_211`, `_212`, `_213`, `_214`, `_216`, `_218`, `_219`, `_220`, `_222`, `_225`,
  `_226`, `_228`, `_229`, `_230`, `_231`, `_234`, `_235`. Note the test-suite comment that
  "0 D2 projections" is a structural invariant (`test_resolveEdgeNodeCollisions.R:20-29`) is
  stale for this fixture — see the incidental finding.
- **Impact:** 56 dogleg mate lines, 25 of whose vertical legs pass through a symbol on an
  intermediate row (c2-vertical rows involving `__proj_`).

### Finding #6: 24 residual class-(a) overlaps are the search-level residue the local passes have been shifting for ~24 sessions
- **Severity:** Minor individually; structurally the most telling
- **Description:** after Findings #1/#2's 264 formula rows, 24 remain: 11 mate pairs pushed
  *closer* than 0.4 units by a later pass (12–42 px: `WDUGSA`/`RYP77M`, `8THU85`/`P49ZD1`,
  `QL6GH4`/`3PD3U5`, `RJHF0G`/`Y7IUMX`, `WCPXHD`/`31UG06`, `8LKBV9`/`8P17E3`,
  `__dup_G8EBU9_1`/`8LKBV9`, and four duplicate–real mate pairs at 12 px); 9 union dots
  partly on their own parent after a Phase 2 push (2–20 px: `__union_126`/`QL6GH4`,
  `__union_44`/`Y7IUMX`, `__union_29`/`C6E1D9`, `__union_112`/`WCPXHD`, `__union_83`,
  `__union_46`, `__union_76`, `__union_36`, `__union_189`); 4 unrelated —
  `__dup_SLN0TF_1`/`8933XB` 21.9 px, `__dup_L31S6S_5`/`M0YNUR` 12, `__dup_L31S6S_3`/`UCXEK5`
  11.9, `__dup_WDBGPF_2`/`__union_43` 10 — exactly S667's four disclosed genuine overlaps.
- **Impact:** each is a pair one pass moved and another pass could not move back (the
  rightward-only, capped pushes); the count has been 19 → 0 → 1 → 5 → 24-by-this-metric across
  S662–S667 depending on which metric each session pinned.

### Finding #7: Track C draws a duplicate right beside its real occurrence (class d) — and its 5-row spread is the fixture's own hand-set generations, not the engine
- **Severity:** Minor
- **Description:** `__dup_Y_1` is 71.9 px from `Y` on row 1 with nothing between — the
  connector arc joins two adjacent copies of the same animal. Real fixture: 0 (the S660
  duplicate-vs-unrelated fix and the arc-direction fix hold).
- **The owner's own reading of `trackC-nprc-rectilinear.png` (this session):** beside the
  three classes above, the drawing spans five rows where kinship2's spans three — `X` and `C1`
  sit two rows below `A`, with `A` duplicated down to `X`'s row. Measured: the fixture assigns
  `gen = 3` to the founder `X` and `gen = 4` to `C1` by hand (it was built to exercise dogleg
  propagation of the consanguinity marker, `test_makePedigreeMatingLayout.R`); with
  `findGeneration()` (what the app computes) `X` is gen 0, the engine anchors `A` over `X`,
  and the same pedigree draws on **3 rows** — `X A Y W` (+ dup-`Y`) on one row, `C1 GC C2`
  below — exactly kinship2's row assignment. The rows-drawn column in the baseline table
  records this for every fixture (real 375: 9 rows both ways). So the row spread is not an
  engine defect; the dot-on-parent and 0.4-unit mate overlap in the same image are (Findings
  #1/#2), and with correct generations `X` and `A` land 0.1 units apart — the crowding gets
  worse, not better.

### Incidental (out of scope, not fixed — `PROJECT_LEARNINGS.md` Learning 382 precedent)
- `tests/testthat/test_resolveEdgeNodeCollisions.R:20-29` states D2 dogleg projections are
  "CURRENTLY STRUCTURALLY UNREACHABLE via the real pipeline" and cites
  `test_addRectilinearWaypoints.R:517-546`; the real fixture renders 56 `__proj_` nodes today.
  The comment (and possibly that test's own framing) is stale. Filed as `BACKLOG.md`
  Housekeeping; the pinned tests were deliberately not touched this session.

---

## Items Audited

| Fixture | Source | Real / synthetic | Status | Findings |
|---|---|---|---|---|
| Track B full | `data-raw/kinship2FidelityValidation.R` | synthetic (kinship2 supplement) | clean | — |
| Track B shrunk | same, via `shrinkPedigree()` | synthetic | clean | — |
| Track C | same | synthetic | 5 (a), 3 (b), 1 (d) | #1, #2, #7 |
| Real 375 | `obfuscated_rhesus_mhc_ped.csv` | real (obfuscated rhesus colony) | 288 (a), 168 (b), 414 c2, 56 (e) | #1–#6 |
| D1, D2, D3 | `test_positionMatingUnitForest.R` | synthetic | clean | — |

## Structural Observations

- **Two formulas explain 92% of class (a) and 79% of class (b) on the production fixture**
  (264/288, 132/168): Tier 2 puts the union at the children's midpoint (which Tier 1 has
  already given to the anchor), and Tier 3 puts the non-qualifying mate 0.4 units from the
  anchor. Both are constants chosen when the union stood *between* the mates (pre-S652) and
  never revisited after the scoped revert moved it onto the anchor. They are not search
  failures; a joint solver is not needed to change a constant — but the S646 plan explicitly
  deferred exactly this change for cascade risk, and that risk is the unmeasured part.
- **The residue (Finding #6) is where the local-pass approach has plateaued:** 24 pairs, each
  the product of one capped, unidirectional push landing on another's territory. Every session
  since S662 has re-pinned a different count of these; none has driven it to zero and held.
- **Two "resolved" metrics are resolved only on paper:** the c1 repair (Finding #3) and the
  curved-connector roundness bump (47 residuals, effect unverified) both satisfy a predicate the
  viewer does not see. c2 is the honest metric and should replace c1 in the test suite's
  baselines when the next fix lands.
- **What is genuinely fixed and holds:** family interleaving (S667) — 0 on all seven fixtures
  per row; founders on the wrong row (S470's 90 free-pass cases) — 0; duplicate-vs-real
  adjacency on the real fixture — 0; the two owner-reviewed Track B drawings — clean on all six
  classes.

## kinship2 baseline (the (C) alternative, measured on the same fixtures)

| Fixture | Rows drawn (ours / kinship2) | Our duplicates | kinship2 duplicates | Our (a) | kinship2 same-row pairs < 1 unit | Note |
|---|---|---|---|---|---|---|
| Track B full | 3 / 3 | 0 | 0 | 0 | 0 | min gap 1.000 |
| Track B shrunk | 3 / 3 | 0 | 0 | 0 | 0 | min gap 1.000 |
| Track C | **5 / 3** | 2 | 1 | 5 | 0 | 1 sire/dam pair swapped for kinship2's sex-role check (`C2`'s sire `Y` is F); the 5 rows are the fixture's hand-set `gen` (see Finding #7) |
| Real 375 | 9 / 9 | 102 | **145** | 288 | **0** | min gap 1.000; kinship2 warns `Unexpected result in autohint, please contact developer` but completes |
| D1 / D2 / D3 | 3 / 3, 2 / 2, 3 / 3 | 0 | 0 | 0 | 0 | min gap 1.000 |

`align.pedigree()` achieves zero symbol crowding on every fixture by construction, at the cost
of 43 more duplicate nodes than this engine draws on the real pedigree (145 vs 102), a
pre-processing layer this package would own (dangling parents as founders, sex-role swaps,
the one-parent case via `fixParents()`), and an `autohint` warning on this very fixture. It
has no union-dot concept (mate line from the midpoint) and no per-generation row policy
(Finding #5 would change behaviour). Its x positions could be consumed while keeping this
package's node/edge tables and rendering, as the BACKLOG item sketches.

## Comparison with Prior Audits

| Metric | Prior | Now (S668) | Trend |
|---|---|---|---|
| Parent occurrence on a row ≠ its unit's row, real fixture (S470 audit) | 147 / 237 (62%); 90 founders + 57 duplicates | 56 / 237 (24%); 0 founders, 0 duplicates, 56 genuine non-founder mates | improved; residue is a policy case S470 did not name |
| Same-row straight-edge collisions before repair (S595 finding 3) | 150 edges / 3,081 pairs | 84 / 1,544 | improved; but 33 of the 89 repairs still cross the symbol (new metric) |
| Individual-vs-individual / duplicate near-misses, real fixture (S667 disclosure) | 4 genuine + 1 tie | the same 4 (`__dup_SLN0TF_1`, `__dup_L31S6S_5`, `__dup_L31S6S_3`, `__dup_WDBGPF_2`), tie correctly excluded; plus 20 mate/own-union overlaps outside S667's metric | consistent; the census metric is wider |
| Family interleaving (S667) | 4 small families interleaved; min cross-family gap 0.4167 | 0 on all fixtures | fixed, holds |
| Union dot on the parent symbol (S664 owner finding) | "every union" on Track B full | 0 on Track B; 157 / 237 on the real fixture | fixed where reviewed; unfixed on 66% of production units |

## Recommendations

1. **Make the A-vs-C decision from this table, in a dedicated session** (owner's decision;
   `BACKLOG.md` Up Next carries it as DECISION NEEDED). The census supports these statements:
   - The two critical classes are **formula constants, not search failures** — a bounded
     per-defect fix exists (recentre every union on its mate midpoint; 1.0-unit spousal
     separation for every pair). What it costs is unknown: S646 deferred it for cascade risk
     into Tier 1, and no one has measured that. **Before choosing (A), spike exactly that change
     and re-run the census** — if (a)+(b) fall to ~24 without (c)/(f) rising, (A) is three
     bounded changes away from a clean production drawing (this, Finding #3's jog offset, and
     the residue).
   - The **residue (Finding #6) and the long-mate-line class (Finding #4) are the joint
     problem** — mates, unions and duplicates positioned after the tree with capped pushes. If
     the spike above shows cascades, that is the evidence for (C): kinship2 is at 0 on every
     fixture and its cost (43 more duplicates, a GPL import or a permission route, a
     pre-processing layer, the autohint warning) is now quantified rather than assumed.
   - Finding #5 (row = generation vs kinship2's spouse-alignment) is a **policy choice** that
     (C) would silently change; decide it explicitly either way.
2. **Adopt `data-raw/pedigreeDrawingErrorCensus.R` as the acceptance gate for every further
   layout change:** a change is done when its class count drops and no other class rises,
   measured by c2 (not c1) for edges. Consider pinning the scoreboard row for the real fixture
   as a test once the numbers are meant to hold.
3. **Housekeeping (filed, not fixed):** the stale "0 D2 projections" comment in
   `test_resolveEdgeNodeCollisions.R:20-29`.
