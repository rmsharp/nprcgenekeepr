# Pedigree Diagram: Provisional Order for the QP Joint Solver (Phase A Seeding) — Design

**Date:** 2026-09-04 (Session 676) · **Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`
**Trigger:** `BACKLOG.md` Up Next design item (found S675, directly under item 1): every residual
left after Migration Path Phase 3 of the QP joint-solver plan
(`docs/planning/pedigree-diagram-joint-qp-solver-plan.md`) is invariant to the QP's floors and
weights and traces to the provisional left-to-right order Phase A hands the QP as a fixed input
(Decision 1 of that plan; `PROJECT_LEARNINGS.md` Learning 727).
**Scope:** Design only. No production `R/`/`tests/` change ships this session — the candidate
rules were measured through a temporary, `getOption()`-gated spike in `R/` (Learning 721/725
precedent), reverted clean before close-out; the full diff is preserved at §Appendix for the
implementing sessions to re-derive under TDD, never to paste. Per the S675 mandate this design
adds **no objective term and tunes no weight** (Learnings 723/727: neither can move an
order-bound residual).
**Decisions below are recommendations, not yet owner-ratified** — this session ran autonomously;
each implementing session's own PRE-RED `AskUserQuestion` gate is where ratification happens,
with this document's measurements as the decision input.

---

## Context

### Problem statement

`.solveJointQP()` (Decision 1 of the QP plan) honours the provisional left-to-right row order
Phase A produces: within each `gen` row, node ids sorted by `provisionalPos$x` (ties by id,
radix) become a fixed chain of hard adjacent-pair constraints. The provisional **magnitudes**
are discarded; only the **rank** survives. But Phase A's seed formulas were designed as *final
positions for the old one-way engine*, not as an order-optimizing input:

| Node kind | Current seed | Where |
|---|---|---|
| genuine individual | Tier-1 BJL `tier1X` (+ S666 conditional shift, both `sweepMinSepBackstop()` passes) | `R/makePedigreeDiagramData.R:937–1042` |
| union | `mean(tier1X[children])` | `:1063` |
| B1 free-pass mate | `qualifies(u)` ? `anchor ± minSep` : `unitX + 0.4·minSep` | `:1093–1106`, `:1174` |
| duplicate | `unitX + 0.4·minSep` | `:1185` |

Three residual classes on the real 375 fixture under S675's engine, all order-driven
(Learning 727's floor sweep: invariant across three floor sets while class (a) went 90 → 0):

1. **Census class (b), 47 same-row off-centre unions** — measured breakdown this session
   (harness validated bit-for-bit against S675's committed numbers first): 28 belong to one-unit
   anchors, 11 to two-unit anchors whose units both seed on one side, 8 to polygamous (3+-unit)
   anchors; 13 of the 47 are "outside-mate-span" (the dot cannot even reach the span — a pure
   rank defect), max deviation **25 raw units**.
2. **Same-row edge crossings** — census c1Pre 86 colliding edges / 1,730 edge-obstacle pairs,
   267 jog repairs, class (c2) 587.
3. **312 D1 sibship-bar x-overlaps** (`test_addRectilinearWaypoints.R:749` pin) — the union dot
   (drop point) is pulled to its parents' midpoint (Decision 4 term 3) while its rank — and its
   children — sit at the children's mean, so bars extend across other sibships.

### What the QP actually needs from an order (the order-stage contract)

Within one row, the QP preserves rank exactly, so:

- **Necessary for a centred dot:** `rank(anchor) < rank(union) < rank(mate-node)` (or mirrored).
  A dot ranked outside its mates' span can never render inside it — the 13 "outside-mate-span"
  rows are this, mechanically.
- **Sufficient (cheaply reachable):** the triple is *locally contiguous* — nothing else ranked
  between anchor and mate-node. The floors then admit the exact centred geometry
  (`minSep/2` + `minSep/2`), and the objective's term 3 lands the dot on the midpoint.
- **When the rendered mate is far away** (a B2 mate under her own parents), contiguity is
  impossible by construction, and Learning 723 showed the deviation is then constraint-bound —
  no seed formula fixes it. Only changing *which node renders as the mate at this unit*
  (duplication) does.

So the design space has exactly two levers, and they are different in kind: **(i) seed values
that give the QP a locally-contiguous anchor–union–mate rank order** wherever the mate-node is
placeable, and **(ii) a duplication policy that makes the mate-node placeable** where the real
node is not. kinship2's own Phase A uses both (spouse placed adjacent by `alignped1`; a spouse
with her own parents plotted twice), which is why its drawings have neither residual class.

---

## Evidence — spike measurements (this session, real 375 fixture)

Method: candidate rules implemented behind a temporary `getOption("nprcgenekeepr.orderSeedSpike")`
hook in `R/` (edit-directly-and-revert, Learning 721; reverted clean, QP suite re-run green),
measured through a scratchpad copy of `data-raw/pedigreeDrawingErrorCensus.R` (CSV redirected,
kinship2 baseline skipped, fixtures Track B shrunk / Track C / Real 375) plus a
Learning-727-style breakdown script and the bar-overlap metric replicated from
`test_addRectilinearWaypoints.R:686–706`. **Baseline (`off`) reproduced S675's committed census
row exactly** (b 47, c2 587, e 56, jogs 267, bars 312, width 13,680 px, 102 duplicates) before
any candidate was trusted.

| Real 375 | dups | jogs | (b) | c1Pre edges | c1Pre pairs | (c2) | (d) | (e) | bars | width px |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| baseline (S675 engine) | 102 | 267 | 47 | 86 | 1,730 | 587 | 0 | 56 | 312 | 13,680 |
| seeding only (final rule) | 102 | 326 | 30 | 137 | — | 804 | 0 | 56 | 487 | 13,680 |
| duplication only | 170 | 183 | 56 | 24 | — | 94 | 0 | 0 | 240 | 13,680 |
| **both (recommended)** | **170** | **165** | **12** | **10** | **13** | **116** | **1** | **0** | **234** | **13,710** |

(c1Post = 0 and classes (a)/(f) = 0 in every variant; width essentially unchanged everywhere.)

Key findings, each measured rather than assumed:

- **The two levers are complementary, and seeding *without* duplication is a net edge-class
  regression** (jogs +22%, c2 +37%, bars +56%): without duplication, a far-away-B2-mate's union
  seeded at the true midpoint ranks — and then renders — in the middle of the long span, over
  other subtrees, stretching drop lines and bars. This fixes the migration-path order:
  **duplication ships first** (every class improves or holds), seeding second.
- **Combined result:** (b) 47 → 12 — and of the 12, five are ≤ 2.4e-6 px solver-precision dust
  (the census (b) gate is `1e-6` px; Learning 726's exact epsilon class), three belong to one
  3-unit anchor (`WCPXHD` — the structural polygamous case, §Alternatives), and four are
  ~0.5-raw local-crowding cases in marry-in chains. Max deviation 25 → **1.0 raw**;
  "outside-mate-span" 13 → **0**. Edge classes: pre-repair colliding edges 86 → 10 (obstacle
  pairs 1,730 → 13), jogs 267 → 165, c2 587 → 116, bars 312 → 234.
- **Class (e) 56 → 0 is a designed consequence, not a side effect** — see Decision 2 and the
  Impact Analysis: the *rendered* mate at every unit is now on the union's own row, so the D2
  dogleg stops firing; every real individual still renders on its own `gen` row (the QP plan's
  Decision 5 row policy is untouched).
- **Track C's Learning-723 residual resolves**: the one constraint-bound off-centre union
  (`__union_3`, 0.4667 raw, weight-invariant up to `wUnion = 5000`) reads 0 under either lever —
  confirming it was an order problem all along.
- **The five kinship2-bit-exact packing fixtures are byte-identical under the full candidate**
  (Track B shrunk/full, D1, D2, D3 — positions compared at 1e-9): the S675 parity pins are
  untouched. The pinned-test blast radius is bounded to Track C, the real-375 pins, and the
  forest-builder tests.
- **Iteration history that produced the final seeding rule** (each step measured; kept here so
  the implementing session does not re-discover them): fixed `anchor ± minSep` insets tie with
  genuine founders' integer positions and interleave (70 off-centre rows); an ε-inset
  (`0.9·minSep`) fixes ties but two anchors closer than `2 × 0.9` with inward-facing mates
  **overshoot across each other into inverted nesting** (A₁ U₁ M₂ M₁ U₂ A₂) — diagnosed from
  the provisional-seed dump, not the QP (rank inversion inside the QP is impossible); the
  gap-proportional inset (Decision 1's `min(0.9·minSep, 0.45·gap)`) removes the overshoot class
  entirely (40 → 12).
- **Overview renders** (baseline vs candidate, chromote, same viewport) show the mid-generation
  rows resolving from a continuous tangle of long mate-lines and orange jog patches into legible
  local anchor–dot–mate triples; produced this session for the record (scratchpad artifacts,
  shared with the owner in the session report; the implementing sessions re-render for their own
  visual-review gates).

---

## Decision

### Decision 1 — Order-consistent seeding (seed each node at the QP's own ideal point)

Replace the union/B1/duplicate *seed* formulas (their magnitudes are discarded — this changes
rank only) with seeds at the position the QP's objective will pull each node toward:

For each anchored unit `u` with a real anchor `a`, processed per anchor with that anchor's units
ordered by their children's mean (`unitX`, ties by id radix):

1. **Side.** One unit: the side of the unit's own children's mean relative to `tier1X[a]`
   (falls back to the existing sex rule — female anchor + male mate goes left — on an exact
   tie). Two units: leftmost-children unit left, the other right (one mate-pair flanks each
   side, kinship2's `lspouse`/`rspouse` split). Three or more: first two as above; extras keep
   their current children's-mean seeds — the structural polygamous case (§Alternatives).
2. **Gap-proportional inset.** `gap` = distance from `tier1X[a]` to the nearest same-row genuine
   node on the chosen side (from the post-S666 `tier1X`, the unit's own `gen` row);
   `mateOff = min(0.9·minSep, 0.45·gap)`, `unionOff = mateOff / 2`. The `0.9` keeps a seed
   strictly inside the anchor's own ≥ `minSep` gap so it can never tie a genuine node's integer
   position; the `0.45·gap` cap keeps two facing insets from overshooting across each other
   (both failure modes measured — §Evidence). No neighbour on that side ⇒ `mateOff = 0.9·minSep`.
3. **Seeds.** Rendered mate-node placeable (a B1 individual or a `__dup_*` node):
   `seed(mate) = tier1X[a] + side·mateOff`, `seed(union) = tier1X[a] + side·unionOff`.
   Rendered mate genuine (its own Tier-1 position): `seed(union) = midpoint(tier1X[a],
   tier1X[mate])` — under Decision 2 this branch survives only for same-row B1-shaped mates
   never duplicated, but it must exist for Phase 2 to be shippable independently of Phase 1.
   Orphan units (anchor `NA`, issue #154) keep the children's-mean seed unchanged.

Tier 1 (BJL + `sweepMinSepBackstop()` + the S666 conditional shift) is **untouched** — genuine
individuals' seeds and ranks are exactly today's. `qualifies()` keeps its current role in the
S666 pass; the Tier-3 *seed* formulas no longer consult it (the seeding above applies to every
anchored unit uniformly — the spike measured no need for the old gate once magnitudes stopped
mattering).

### Decision 2 — Duplication policy: a B2-shaped non-anchor is always duplicated

In `.buildMatingUnitForest()`'s duplicate assignment (`R/makePedigreeDiagramData.R:509–541`),
the free (un-duplicated) non-anchor occurrence is granted **only to a B1-shaped individual** —
no parent edge and no own single-parent direct child, i.e. the same structural test Phase A's
`b1Ids` applies (`:884–886`), evaluated from `ped` at forest-build time. A B2-shaped non-anchor
(own parent edge, or own direct child) gets a `__dup_*` node at **every** non-anchor occurrence;
her real node keeps rendering on its own `gen` row under her own parents, connected to each
duplicate by the existing curved duplicate connector (`:1910`'s established convention — no new
render mechanism).

This is kinship2's own answer (a marry-in spouse with her own parents is plotted twice), sized
by kinship2's own baseline: 170 duplicates vs kinship2's 145 on the same fixture (baseline 102).
Measured consequences: the mate-node at every unit becomes locally placeable (enabling
Decision 1's contiguity), class (e) empties (no rendered side node is off-row any more — the D2
dogleg becomes dead in practice, though the code stays, unchanged, for robustness), and the
edge classes collapse (§Evidence). One new class (d) "adjacent" case appears
(`__dup_QZVTGJ_1` lands `minSep` from its own real occurrence with nothing between) — the
kinship2 `alignped3` collapse-when-adjacent refinement is deliberately **not** designed here
(§Open Questions).

### Decision 3 — Phase order: duplication first, then seeding

The ablation row "seeding only" (§Evidence) shows seeding without duplication ships a
significant edge-class regression; "duplication only" improves or holds every class. Phases in
the Migration Path are therefore ordered duplication → seeding, each independently shippable and
each leaving the diagram no worse than its predecessor ("if I stop here, something works",
failure mode #25's test).

### Decision 4 — Explicit non-changes (the mandate's fence)

- **No objective term is added, no weight is tuned** (S675's mandate; Learnings 723/727). The
  known tension between term 4 (`wDup` pulls a duplicate toward its real occurrence) and term 1
  (spousal pull toward the anchor) for the new spouse-duplicates is *flagged* for the
  implementing session's own RED sweep (the Decision 4 "weights are starting values" precedent
  in the QP plan), not resolved here — at the defaults it produced exactly one (d) case.
- **Row policy unchanged** (QP plan Decision 5): every *real* individual renders on the same
  `gen` row it does today. Class (e)'s emptying is a change in which *node* renders at the unit
  (a same-row duplicate instead of a projection to an off-row real node), not in any
  individual's row.
- **Tier 1 BJL, `.forestComponents()`/`.packComponents()`, `.solveJointQP()` itself, the floors,
  `.addRectilinearWaypoints()`, `.resolveEdgeNodeCollisions()`** — all untouched.
- **Sibling order within a sibship** (which child of a union sits leftmost) is not redesigned —
  kinship2's `autohint` analogue (shift a marry-out child to its sibship's near edge) is the
  natural *next* order refinement if the residual c2 116 / bars 234 warrant it (§Open Questions).

---

## Rationale

- **It fixes the defect where it lives.** Learning 727 proved the residuals are order-bound;
  this design changes only the order-determining inputs (seed ranks and node population) and
  nothing about how positions are solved — the exact separation Decision 1 of the QP plan drew.
- **It is kinship2's own two mechanisms, transplanted to this engine's own structures** — spouse
  adjacency from `alignped1`'s `nid[lev,] <- c(lspouse, x, rspouse)` and its left/right split;
  duplication-when-the-spouse-has-parents from kinship2's plotting model — without porting the
  fragile part (§Alternatives, alignped1–3/autohint port).
- **Measured, not predicted.** Every number in §Evidence is a run against the real fixture with
  the harness first validated against S675's committed baseline. The one prediction-shaped
  claim the spike could not test — pinned-suite blast radius — was bounded by direct
  position-identity comparison on the five parity fixtures.
- **Bounded residual, honestly disclosed.** The endpoint is (b) ≈ 7 real cases (3 on one
  polygamous anchor, 4 local crowding, plus ~5 epsilon-dust rows the census's own 1e-6 px gate
  counts), not 0 — a structural floor kinship2 itself shares (its polygamous drawings span
  marriage lines across intermediate spouses too).

---

## Alternatives Considered

| Alternative | Pros | Cons | Why rejected |
|---|---|---|---|
| **Port kinship2's `alignped1`–`alignped3` + `autohint` outright as the order stage** | Maximum-fidelity parity; one lineage of order heuristics | Replaces the freshly-stabilized Tier-1 BJL + S666/S667 machinery wholesale (every pinned fixture re-derived, including the five that this design provably leaves byte-identical); and **kinship2's own `autohint` punts on this very fixture** — S670's probe hit its "Unexpected result in autohint" fallback (`order = 1:n`) on the real 375 at every tested weight | Rejected. The port buys the reference's own degradation on the exact data that matters, at maximal blast radius; the two mechanisms that make kinship2's orders good are extracted instead (Decisions 1–2). |
| **Seeding only (no duplication)** | No node-population change; smallest diff; forest builder untouched | Ships jogs +22%, c2 +37%, bars +56% (measured, §Evidence); far-away-mate (b) cases stay constraint-bound | Rejected as an endpoint; survives as Phase 2 of the recommended design, shippable only after Phase 1. |
| **Duplication only (no seeding)** | Single biggest edge-class win; smallest (b)-risk | (b) worsens 47 → 56 (duplicates placed by the old `unitX + 0.4` seed land off-centre or outside the span) | Rejected as an endpoint; survives as Phase 1 — every census class improves or holds, so it ships cleanly alone. |
| **Anchor-side duplication for polygamous (3+-unit) anchors** | Could take (b) to ~4 | A new mechanism (duplicating the *anchor* side, which no render/census/QP path resolves today — `.nonAnchorNodeResolver()` is non-anchor-only by construction); kinship2 does not do it either (its polygamous marriage lines span intermediate spouses) | Deferred, not designed. The 3–5 residual rows are the accepted structural floor, disclosed; revisit only if the owner's visual review flags them. |
| **A post-hoc nesting-repair pass (detect inverted mate nesting, swap seeds) instead of gap-proportional insets** | Simpler seed formula | A second, order-fixing mechanism layered after the first — the exact one-way-pass shape the QP migration just removed (S670 §2.3) | Rejected; the gap-proportional inset achieves the same result inside the one seeding rule. |
| **Widen the census (b) epsilon to hide solver dust** | 12 → ~7 immediately | Weakens the measuring tool for every future session (Learning 726 rejected the same move for class (a)) | Rejected; dust rows are disclosed instead and the detector question is left to §Open Questions. |

---

## Evidence-Based Inventory

Grep-run this session (post-revert line numbers, current `master` at `c3f18a83`):

**Code the design changes:**
```
R/makePedigreeDiagramData.R:509–541    .buildMatingUnitForest() duplicate assignment
                                        (Decision 2's edit site — the free-occurrence grant)
R/makePedigreeDiagramData.R:1058–1064  Tier 2 unitX <- mean(tier1X[children]) (seed role replaced
                                        by Decision 1 for anchored units; kept for orphan units)
R/makePedigreeDiagramData.R:1093–1106  b1AnchorRelativeX()/derivedX() (Tier-3 seed formulas
                                        Decision 1 supersedes)
R/makePedigreeDiagramData.R:1170–1189  tier3X/tier3Gen seed loops (B1 + duplicates)
R/makePedigreeDiagramData.R:1202       provisionalPos assembly (unchanged contract, changed values)
```

**Code the design must NOT break (verified untouched by the spike):**
```
R/makePedigreeDiagramData.R:937–1042   Tier 1 backstops + S666 conditional shift (genuine seeds)
R/makePedigreeDiagramData.R:1289+      .solveJointQP() (consumes provisionalPos; no signature change)
R/makePedigreeDiagramData.R:719–725    .nonAnchorNodeResolver() (already resolves any dup the new
                                        policy creates — no change needed, confirmed by the spike)
R/makePedigreeDiagramData.R:1910       curved duplicate-connector render convention (absorbs the
                                        +68 duplicates with no new mechanism)
```

**Test surface (blast radius):** `test_buildMatingUnitForest.R` (444 lines; 12 duplicate-count
reference sites — Decision 2 changes duplicate populations, so its expectations are re-derived
in Phase 1), `test_positionMatingUnitForest.R` (2,694), `test_solveJointQP.R` (424),
`test_makePedigreeMatingLayout.R` (1,637), `test_addRectilinearWaypoints.R` (876; the :749
bar pin), `test_resolveEdgeNodeCollisions.R` (629; the 266/2,549 collision pin) — 6,704 lines
total, the same surface Phase 3 re-derived once already. **Bounding result:** Track B
full/shrunk and D1–D3 positions are byte-identical under the full candidate (§Evidence), so
their kinship2-parity pins do not move; the re-derivation load is the real-375 pins, Track C,
and the forest-builder expectations.

**Other `__dup_*` consumers checked:** `R/comparePedigreeStructure.R:115,133,205` (resolves/
excludes duplicates by prefix — count-agnostic), `R/modPedigree.R:784,819` (prefix exclusions —
count-agnostic), tooltip/genotype joins key off `realId` resolution. No consumer assumes a
duplicate count or a one-free-occurrence policy. Issue #138's 1,500-node cap: 375-fixture node
count rises ~68 (rendered nodes actually *fell* 1,792 → 1,600 — fewer waypoint nodes); the cap
check runs on the same population it does today.

---

## Migration Path

Each phase is a separate implementation session, full RED→GREEN→REFACTOR per `CLAUDE.md`'s TDD
contract, PRE-RED-gated by `AskUserQuestion` (which also ratifies this design's corresponding
decision). **Do not bundle phases** (FM #18). Expected census values below are this session's
spike measurements — the implementing session re-measures rather than trusts them (Learning 720's
reflex), but a materially different number is a red flag, not an amendment.

### Phase 1 — Duplication policy (Decision 2 alone)

**What DONE looks like:** `.buildMatingUnitForest()` grants the free non-anchor occurrence only
to B1-shaped individuals; forest tests re-derived; real-375 and Track C pins re-derived; owner
visual review of the regenerated real-fixture render (engine-output change ⇒ the S666/S667
visual-gate precedent applies).
**Verification commands:** census re-run — Real 375 expect ≈ (dups 170, jogs 183, b 56, c1Pre
24 edges, c2 94, d 0, e **0**, f 0, a 0, width 13,680); Track B shrunk/full, D1–D3 byte-identical
(this design's own bounding measurement says they must be — any drift is a defect, not
re-derivation); Track C +1 duplicate. Full clean regression + `lintr::lint_package()` 0.
**Session boundary:** close out here.

### Phase 2 — Order-consistent seeding (Decision 1)

**What DONE looks like:** the Tier-2/Tier-3 seed formulas replaced per Decision 1 (side rule,
gap-proportional insets, midpoint branch for genuine mates); real-375/Track C pins re-derived;
owner visual review.
**Verification commands:** census re-run — Real 375 expect ≈ (b 12 — of which ~5 are ≤ 2.4e-6 px
dust and 3 sit on the one 3-unit anchor, jogs 165, c1Pre 10, c2 116, d ≤ 1, e 0, bars 234, width
13,710); packing fixtures again byte-identical; Track C b = 0. The RED phase should also assert
the two structural properties directly (cheaper to debug than census counts): no anchored unit's
dot ranks outside its rendered mates' span, and no two facing mate seeds invert nesting.
**Session boundary:** close out here.

### Phase 3 — Docs & follow-ups (may fold into Phase 2's close-out if scope allows)

`NEWS.Rmd` plain-language entry (S628 criterion) covering both phases; regenerate the committed
reference images (`data-raw/kinship2FidelityValidation.R`) and Diagram-tab screenshots;
`BACKLOG.md` item marked DONE; decide/record the §Open Questions dispositions that surfaced
during implementation.

---

## Impact Analysis

### What changes
- Which node renders as the mate at ~68 units (a same-row `__dup_*` instead of a projection to
  the off-row real node) — class (e) 56 → 0, the D2 dogleg no longer fires in practice.
- Duplicate population 102 → 170 (kinship2's own: 145) and its curved connectors (cCurved
  chord-heuristic rows 1,750 → 1,996 — more arcs, each shorter-lived clutter than the mate-lines
  they replace; the owner's Phase 1 visual review is the arbiter).
- Union/B1/duplicate provisional seeds (rank only — magnitudes were already discarded).
- The real-375 and Track C pinned values; forest-builder duplicate expectations.

### What does NOT change
- `.positionMatingUnitForest()`/`makePedigreeMatingLayout()` signatures and return contracts;
  the QP formulation (floors, terms, weights) in full; row assignment of every real individual;
  Tier-1 BJL and component packing (five parity fixtures byte-identical); the jog-repair and
  waypoint layers' code.

### What might break (risk assessment)
- **Duplicate-count-sensitive UI affordances** — anything presenting "N animals" from rendered
  nodes must keep resolving through `realIdOf`-style exclusion (the checked consumers already
  do; a Phase 1 grep for new consumers since this inventory is cheap insurance).
- **`wDup` vs term-1 tension on spouse-duplicates** (§Open Questions): at defaults it produced
  exactly one (d)-adjacent case; a future weight change could tip more. Phase 1's RED sweep
  covers it (the QP plan's own "sweep new-term weights before locking" precedent).
- **Marry-in chains** (an anchor whose mate's duplicate belongs to a unit whose anchor is
  itself a mate elsewhere) are where the 4 residual crowding cases live; the seeding rule's
  per-anchor independence means it cannot make them worse than baseline (measured), but Phase 2
  should keep them in its RED fixtures (`__union_97/128/179/228` are the concrete cases).
- **Census (b) dust rows** — the 1e-6 px gate counts ≤ 2.4e-6 px solver shortfalls once
  deviations this small become reachable; a "must be ≤ N" acceptance criterion should either
  exclude sub-solver-precision rows explicitly or use the Learning-726 two-assertion pattern.

---

## Verification Plan

- **Census as the acceptance gate** at every phase (its own Recommendation 2), with this
  document's measured per-phase expectations as targets and the byte-identity of the five
  packing fixtures as a hard invariant.
- **Structural RED assertions** (Phase 2): rank-betweenness of every anchored dot; no facing-seed
  nesting inversion — direct tests of the order-stage contract, not just census deltas.
- **Owner visual review before each phase's close-out** (S666/S667 precedent; this session's
  overview render pair previews the endpoint).
- **Full clean regression + lint** at each phase boundary, per `CLAUDE.md` Build/Test/Verify.

---

## Open Questions for a Future Session

1. **Collapse-when-adjacent for duplicates** — kinship2's `alignped3` merges a duplicate whose
   two occurrences become column-adjacent; this design accepts the one measured (d)-adjacent
   case instead. Worth designing only if Phase 1's visual review finds the adjacent-dup pattern
   confusing (it is one node pair today).
2. **`wDup` applicability to spouse-duplicates** — exclude the new duplicates from term 4, keep
   them at the default weight, or re-weight: an implementing-session RED-sweep decision, fenced
   out of this design by the no-weight-tuning mandate.
3. **Sibling order within sibships** (the `autohint` shift analogue): the remaining c2 116 /
   bars 234 are partly children ranked far from their union's now-mate-adjacent dot. A third
   order lever, not designed here — measure whether the owner cares after Phase 2 ships.
4. **Polygamous anchors** (3–5 residual (b) rows on one anchor): anchor-side duplication is the
   only full fix and needs its own design (resolver, census, QP-term treatment for an
   anchor-side node). kinship2 parity does not require it.
5. **Census (b) detector epsilon** — whether to adopt the Learning-726 two-assertion pattern
   inside the census itself for class (b), now that sub-precision deviations are its dominant
   residual rows on a healthy layout.

### Dispositions (recorded S681, 2026-09-08 — the design's Phase 3 close-out)

1. **Collapse-when-adjacent** — NOT PURSUED. Phase 1's owner visual review (S678) and
   Phase 2's substantive review round (S679) raised no adjacent-duplicate confusion; census
   (d) stood at 1 at defaults after Phase 2. Revisit only if a future visual review flags it.
2. **wDup applicability to spouse-duplicates** — PROMOTED to its own `BACKLOG.md` Up Next
   item (S679, owner visual-gate finding: term 4 drags marry-in triples ~950 px; measured
   → ~60 px headroom under `wDup = 0`). The fenced RED-sweep decision now carries its own
   PRE-RED gate requirement amending the S675 no-weight-tuning mandate.
3. **Sibling order within sibships** — OPEN, deliberately unmeasured. The Phase 2 endpoint
   beat this design's own prediction (c2 105 vs 116, bars 233 vs 234), and the one structure
   the owner flagged at the Phase 2 visual gate root-caused to Q2 (wDup), not sibling order.
   Measure owner appetite only after the wDup item ships.
4. **Polygamous anchors** — ACCEPTED RESIDUAL. The 3 class-(b) rows on `WCPXHD` are named in
   `test_positionMatingUnitForest.R`'s disclosed-residual set (S679 RED); a full fix needs
   its own anchor-side-duplication design; kinship2 parity does not require it.
5. **Census (b) detector epsilon** — OPEN, no dedicated session. The Learning-726
   two-assertion pattern already guards the test side (S679 RED); the census script still
   counts ~5 sub-precision dust rows in (b) at the endpoint. Adopt inside the census the
   next time `data-raw/pedigreeDrawingErrorCensus.R` is touched for its own reasons.

---

## Appendix — spike reference implementation

The exact gated diff measured this session (variants: `s2` = Decision 2 alone, `s4nd` =
Decision 1 alone, `s4` = both; `off` = baseline) is preserved at
`scratchpad/orderSpikeDiff.patch` for this session's record and reproduced in essence here.
**It is a measurement instrument, not shippable code** — the implementing sessions re-derive
under TDD with proper naming, docs, and no option gate. Core of the seeding rule (Decision 1),
as measured:

```r
## per anchor a, units us ordered by unitX (children's mean), id radix ties
for (k in seq_along(us)) {
  u <- us[k]; nn <- resolveNnode(nonAnchorOf[[u]], u)
  side <- if (length(us) == 1L) childSideOrSexRule(u, a)
          else if (k == 1L) -1 else if (k == 2L) 1 else 0   # 3rd+: keep old seed
  if (side == 0) next
  gap <- distanceToNearestSameRowGenuine(a, side)           # from post-S666 tier1X
  mateOff <- min(0.9 * minSep, 0.45 * gap); unionOff <- mateOff / 2
  if (nnIsGenuine(nn)) {
    unitX[[u]] <- (tier1X[[a]] + tier1X[[nn]]) / 2          # far/near genuine mate
  } else if (nnIsRendered(nn)) {                            # B1 or __dup_* node
    tier3X[[nn]] <- tier1X[[a]] + side * mateOff
    unitX[[u]]  <- tier1X[[a]] + side * unionOff
  } else {                                                  # dangling, unrendered
    unitX[[u]]  <- tier1X[[a]] + side * unionOff
  }
}
```

Duplication policy (Decision 2), as measured: in `.buildMatingUnitForest()`'s assignment loop,
`needsDuplicate` is forced `TRUE` when the non-anchor is B2-shaped —
`hasParentEdge(p) || hasOwnSingleParentDirectChild(p)` computed from `ped` — before the
existing `hasAnchorAnywhere`/`freeConsumed` logic runs.
