# Pedigree Diagram: Same-Row Collision-Avoidance Architecture

**Status:** DESIGN, session S592 (2026-08-15). Not yet implemented — this document is the
deliverable; implementation is 3+ separate sessions (§6).

**Origin:** `BACKLOG.md` "Active" item (found S591, 2026-08-15) — three independent findings from
one day's live kinship2-fidelity review trace to the same underlying gap in
`.positionMatingUnitForest()`/`.addRectilinearWaypoints()`: node/edge placement is computed
locally (per-union, per-child) with no check for what else already occupies that x/y region.
[Issue #160](https://github.com/rmsharp/nprcgenekeepr/issues/160) (sibship-bar and
duplicate-connector lines colliding with unrelated nodes) and the S583 item (a union landing
outside its own parents' span) are two symptoms of this one gap, not two separate bugs.
[Issue #161](https://github.com/rmsharp/nprcgenekeepr/issues/161) (whether to hide the
mating-union marker) was bundled into this planning session's scope by the same `BACKLOG.md`
item as a smaller, related decision — see §2.5.

**Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` (matching this
project's established precedent for pedigree-diagram positioning-algorithm decisions — S572's
Track 4 plan, S576's Track 6 plan, and S588/S589/S590's three layout-feasibility spikes all made
the same call for the same reason: this is a technical/algorithm-correctness decision, not a
panel/visual-arrangement one).

**Method:** Investigated via a 12-agent research/design/judge `Workflow` (2026-08-15) — 5 parallel
research agents (full reads of `.positionMatingUnitForest()`, `.addRectilinearWaypoints()`, a
grep-based call-site inventory, Track 4/6 ratified-invariant extraction, and the 3 prior
layout-feasibility-spike history — §10), 4 independently-designed candidate architectures, and 3
independently-lensed judges (correctness/completeness; architecture-fit/blast-radius;
incremental-deliverability/testability). **No single candidate won on all 3 lenses** — each had a
real, judge-identified flaw (§4). This document synthesizes the highest-scoring, judge-vetted
pieces of each into one phased design rather than adopting any one candidate wholesale.
Owner-ratified via `AskUserQuestion`, same session (§9).

---

## 1. Context

### 1.1 What is already decided (do not re-litigate)

- D1–D6 of the mating-unit-forest transformation and contour-merge positioning algorithm
  (`docs/planning/pedigree-diagram-option2-layout-design-plan.md`) are ratified and shipped; this
  document does not propose replacing the recursive contour-merge itself.
- **Track 4** (`docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md`) ratifies: the
  gen→mateCount→id anchor tie-break (§2.1); `matingUnits$gen == genOf[[anchor]]` unconditionally
  for every mating unit (§2.3/§2.4); anchor selection is fully local, no cross-unit "used" state
  (§2.2/§2.3); any tie-break used must be fixed, deterministic, non-search-based (§1.1); no
  `effGenOf`-style compensating layer (§2.3); `sweepMinSep()` operates on `x` within a row, never
  on `gen` (§1.1, Track3/Track4 orthogonality).
- **Track 6** (`docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md`)
  ratifies: `finalUnitX[U] == (min(x[C]) + max(x[C])) / 2` unconditionally, for every mating unit
  `U` with children `C` (§2.4); `dupX = finalUnitX + minSep * 0.4` (§2.2); the broadened
  exact-coincidence de-collision pass covering real+duplicate+union nodes via a deterministic
  `(gen, id)`-radix-ordered 1e-3 nudge (§2.3); `orderBySex` must run before `finalUnitX`/`dupX` are
  computed (§10 correction 1); any new id-sort must use `method = "radix"`, never locale-dependent
  `order()` (§10 correction 3, `PROJECT_LEARNINGS.md` Learning 585); D1 unconditionally
  waypoint-routes every child edge, D2's dogleg fires purely on `gen` inequality, **never on `x`**
  (§1.1); Track 4 (which `gen` row) and Track 6 (which `x`) are fully orthogonal (§1.1).
- Track 6 §8 ("Explicitly Out of Scope") **already documents general (non-exact) crowding among
  unions/duplicates/reals as an accepted, open gap, not a settled invariant** — "the broadened
  de-collision pass catches *exact* coincidences… but not general crowding… This mirrors the
  project's existing, already-accepted risk posture for union nodes." This document's Tracks 1–3
  are additive work inside that already-acknowledged gap, not a reopening of a settled guarantee
  — except where explicitly flagged as a reopening (Track 3, §2.3).
- **Three prior layout-feasibility investigations** (S588 bounded-lookahead, S589 hand-rolled
  barycenter/median, S590 `igraph::layout_with_sugiyama()`) were all **closed as inherent,
  NOT FEASIBLE** — each improved a small synthetic example but regressed the real 375-individual
  fixture's sibling-compactness/crossing metrics, because each recomputed real/duplicate/union
  node **x** from a different global objective, and a high-mate-count "hub" individual's several
  subtrees compete for space under that objective. **This document does not propose recomputing
  any real/duplicate/union node's x from a new global objective** — every mechanism below is
  either (a) an unconditional geometric guarantee requiring no optimization at all (Track 1), (b)
  a strictly local, per-edge additive waypoint insertion that never moves an existing node (Track
  2), or (c) a strictly local, per-union clamp against that union's own 2 parents with no
  cross-union coupling (Track 3) — structurally immune to the hub-coupling failure mode all three
  prior spikes hit. See §10 for the full prior-investigation history and the cross-cutting
  cautions carried forward from it.

### 1.2 Fresh evidence gathered this session

**Issue #160's 2 originally-reported collisions**, reproduced against `kinship2::sample.ped`
family 2 (`edgeStyle = "rectilinear"`, the shipped default since Track 2/S574):

- **Collision 1:** `204`/`205` are children of `201`×`202` (a sibship bar). `204` separately
  anchors her own mating union with `203`; that union node `__union_2` computes to
  `x = -210` — exactly the midpoint of `204` (`x = -270`) and `205` (`x = -150`) — landing
  directly on the `204`–`205` segment of `201`×`202`'s own sibship bar.
- **Collision 2:** `209`, an unrelated founder marrying in via `208`, has `x = 210`, which falls
  directly on the straight-line path between `__bar_207` (`x = 90`) and `__bar_208` (`x = 390`),
  both part of `201`×`202`'s sibship-bar chain.

**Issue #160 comment 1's broader finding**, on a second (`P1`×`P2` consanguineous) fixture: `Y` is
duplicated (mates both her sibling `A` and a third individual `W`). `Y`'s *real* occurrence
(`x = 255`, near `W`, since `Y` anchors the `Y`×`W` union) — not her *duplicate* occurrence
(`x = 63`, near `A` — the one structurally local to `P1`×`P2`'s own sibship bar) — feeds
`P1`×`P2`'s own `finalUnitX` computation, stretching it to `x = 90`, entirely outside `P1`/`P2`'s
own span `[-195, 0]`. The resulting sibship-bar chain spans `[-75, 255]`, and `W` (`x = 135`) sits
inside it — both the sibship bar **and** `Y`'s own duplicate-connector dashed line run through/
behind `W`'s node. Comment 1's own conclusion: *"the actual root cause is more general: this
renderer has no collision-avoidance for any straight same-row edge — sibship bar or
duplicate-connector alike — against a third node that happens to fall within that edge's x-span."*

**BACKLOG.md's S583 item**: for a union with exactly one child, `finalUnitX[U] == x[thatChild]` —
zero centering benefit while decoupling the union from its own parents' span. Concrete example:
`5A6DFT` (sire, `x = -60`) × `8DKELJ` (dam, `x = 60`), sole child pulls the union to `x = 120`,
entirely outside `[-60, 60]`.

**The root-cause code, verified this session** (full citations in §10's research excerpt):

- `R/makePedigreeDiagramData.R:966-975` (`.positionMatingUnitForest()`) — the `finalUnitX` loop:
  no check anywhere compares a computed union `x` against its own parents' range, and no check
  anywhere compares it against any other already-placed node.
- `R/makePedigreeDiagramData.R:1530-1552` (`.addRectilinearWaypoints()`, D1 loop) — every D1 bar
  waypoint (`__drop_*`, `__bar_*`) is stamped with `y = childY` (line 1532/1539), i.e. **the exact
  same row every real/duplicate/union node at that generation also occupies** — this is the direct
  mechanical cause of both issue #160 collisions.
- The only existing collision-related machinery is (a) the final de-collision pass
  (`:987-1010`), which catches only exact-coincidence (`abs(used - x) < 1e-9`) at the same `gen`,
  and (b) `sweepMinSep()` (`:864-878`), scoped to adjacent real/duplicate nodes only — **neither
  checks whether a third node's `x` falls inside a straight edge's `[min, max]` span**, which is
  the actual issue #160 symptom.
- **No existing test covers a same-row collision case** — confirmed by grep (`§10`); the closest
  existing test (`test_positionMatingUnitForest.R:1061`, "zero exact x/gen coincidence") only
  guards exact numeric ties, and `test_positionMatingUnitForest.R:150-217`'s own docblock records
  that a general geometric minimum-separation check was investigated and found **not** to
  discriminate real collisions from harmless near-misses (300+ close-but-non-identical pairs exist
  in the real 375-individual fixture under every variant) — a load-bearing precedent for why
  Track 2's detection predicate below must use **strict interior containment**, not a distance
  threshold (§2.2).

---

## 2. Decision

Three additive tracks, ordered smallest/most-certain first. Each ships as its own implementation
session (§6). Track 4 (a true root-cause fix, narrower in scope) and issue #161 (a visual-design
question) are explicitly **not** part of this plan's implementation scope — see §2.4/§2.5.

### 2.1 Track 1 — D1 sibship-bar genuine intermediate row

**Closes issue #160's 2 originally-reported collisions, unconditionally, with no detection logic
at all.**

`R/makePedigreeDiagramData.R:1530-1540`'s D1 loop currently stamps every bar waypoint at
`y = childY` (the children's own row). Replace with a single package-wide constant fraction:

```r
sibshipBarFraction <- 0.4   ## single constant, 0 < f < 1
for (fromId in unique(childEdges$from)) {
  kids    <- childEdges$to[childEdges$from == fromId]
  childY  <- unname(yOf[[kids[1L]]])
  parentY <- unname(yOf[[fromId]])
  barY <- if (is.na(childY) || is.na(parentY)) childY else
    childY - (childY - parentY) * sibshipBarFraction   ## CHANGED
  ...
  newNodeList[[...]] <- data.frame(id = barPointIds, x = barPointX, y = barY, ...)  ## CHANGED
}
```

**Why this is a *guarantee*, not a heuristic:** every real/duplicate/union node's `y` is
`pos$gen[...] * yScale` (`yScale <- 150L`, `:1167`) — an exact integer multiple of 150 by
construction. `barY` is a fixed, non-zero, non-one fraction strictly between two such multiples,
so `barY` can never equal `gen * 150` for **any** integer `gen`, for **any** pedigree. This
requires no per-fixture tuning, no candidate search, and no detection step — it is geometrically
impossible for a D1 bar to ever again share a row with a pinned node. Verified directly against
both reported collisions: `__union_2` and `209` are both ordinary pinned nodes, so both are
provably cleared by this change alone.

**Side effect (intended, not a complication):** the previously zero-length `barIds[j] -> kids[j]`
vertical edges become real, visible drop segments from bar to child.

**Scope:** confined to D1 sibship bars specifically. D2's dogleg leg, kept/un-doglegged mate
edges, twin connectors, and the duplicate connector are untouched by Track 1 — Track 2 covers
those.

### 2.2 Track 2 — general same-row detect-and-jog framework

**Closes issue #160 comment 1's broadened finding (the duplicate-connector collision behind `W`)
and proactively covers every other same-row straight-edge type this renderer produces**, per the
research's own inventory (§10): D2's `projId -> U` horizontal dogleg leg (structurally identical
collision risk to the D1 bar, not named in issue #160 at all); a kept/un-doglegged direct mate
edge (the "most common case," per the research); twin/zygosity connectors.

New standalone function, wired into `makePedigreeMatingLayout()` itself (`:1428-1432`, the
existing `if (edgeStyle == "rectilinear")` branch) — **not** bolted onto the Shiny layer only, so
every caller (the app, and any script calling `makePedigreeMatingLayout()` directly per
`vignettes/a2interactive.Rmd`) gets the fix identically:

```r
.resolveEdgeNodeCollisions <- function(nodes, edges) { ... }
```

**Detection predicate (bug-free — see §4 for why this matters):** for each straight
(`smooth.enabled` not `TRUE`) same-row edge, compute its span `[lo, hi] = [min(x1,x2), max(x1,x2)]`
and flag any other node `N` with **strict interior containment** (`lo < x[N] < hi`), **explicitly
excluding**:
1. the edge's own two endpoint ids, and
2. any node that is a structural member of the same union/sibship the span belongs to (so a bar
   never flags its own children).

Both exclusions are required — omitting either reproduces a self-referential false-positive bug
found in one of the 4 candidates during design (§4). The curved duplicate-connector edge
(`smooth.enabled == TRUE`, built at `:1370-1385`) is excluded from the *straight-edge* detection
pass (see below).

**Repair, on a flagged violation:** insert a small local jog — a short vertical step to
`y ± jogY` (a small fraction of one generation's gap, computed empirically from the actual
distinct `y` values present, never a hardcoded `yScale`, so the repair stays correct if
`xScale`/`yScale` are ever retuned), across the obstacle, then back — mirroring the same
insert-a-waypoint-and-bend mechanism D2 already uses, just triggered by point-in-span detection
instead of `gen` mismatch. Bounded to a small fixed number of passes (mirroring the existing
bounded style of the final de-collision loop, `:987-1010`); a residual after the cap is left
unrepaired and counted in an audit-log return value — never silently dropped, never an infinite
loop, consistent with Track 6 §8's own "general crowding is accepted as partial, not absolute"
posture.

**The curved duplicate connector specifically:** do not reroute it through rectilinear waypoints
(that would destroy the already-shipped, separately-tuned `smooth.type = "curvedCW"` arc styling,
S577/S468/S469). Implement the same-row check for it separately (its gen can differ from the real
occurrence's gen, per `:983`, so it is only sometimes same-row) and, if it collides, apply a
disclosed **heuristic** nudge (e.g. increasing `smooth.roundness`) with no closed-form clearance
proof — its correctness must be confirmed by the visual-verification step in §7, not asserted by
coordinate math alone. If that heuristic proves unconvincing under visual verification, this piece
may ship as a documented residual with its own follow-up issue rather than block Track 2's other,
provable pieces.

**Never moves an existing node:** Track 2 only ever adds new synthetic waypoint nodes and
reroutes/adjusts edges — it must never write to any existing node's `x`/`y`, a property checked
explicitly in §7.

### 2.3 Track 3 — parent-span clamp on `finalUnitX` (closes S583)

**This is a deliberate, disclosed reopening of Track 6 §2.4's "unconditionally" wording** — see
§9 for the owner ratification of this specific reopening, and §6 for its own required
implementation-session `AskUserQuestion` gate before any RED test is written (per the TDD
contract's requirement that a decision to reopen a ratified invariant is a scope/approach decision
in its own right, distinct from an ordinary RED→GREEN gate).

Immediately after the existing `finalUnitX` computation (`:966-975`), clamp each union's `x` into
its own two parents' range:

```r
for (i in seq_len(nrow(matingUnits))) {
  uid <- matingUnits$id[i]
  parentX <- nodes$x[match(c(matingUnits$sire[i], matingUnits$dam[i]), nodes$id)]
  lo <- min(parentX); hi <- max(parentX)
  finalUnitX[[uid]] <- min(max(finalUnitX[[uid]], lo), hi)
}
```

Whenever the existing child-centered formula already falls inside `[lo, hi]` (the common,
already-correct case), the clamp is a no-op — byte-identical output. It engages only for the
outlier cases issue #160/S583 found. Verified against S583's own numbers: `5A6DFT`(-60)/
`8DKELJ`(60), single child pulls to 120 → clamped to 60 (inside `[-60, 60]`).

**What Track 3 does *not* fix:** the underlying reason `finalUnitX` computed a bad value in the
first place (the duplicate-occurrence-selection bug behind comment 1's `P1`×`P2` example) — Track
3 cleans up the geometric fallout (brings the union back inside its parents' span) without
correcting which child-occurrence fed the formula. See §2.4.

### 2.4 Deferred, not scheduled: duplicate-occurrence-selection root fix

`childEdges$to` (`:511-516`) always resolves a child role to its one **real** occurrence — a
duplicate node is only ever created for a *parent* role (`:478-499`), never for a child. So when a
child of union `U` is *also* a duplicated individual (mates a co-sibling under `U`), `U`'s
`finalUnitX` computation unconditionally uses that child's real occurrence — wherever their *own*
separately-anchored subtree recursively settled — rather than the occurrence structurally local to
`U`. A narrowly-scoped fix (substitute the locally-relevant duplicate's `x` when a child has a
duplicate tied to a union whose *other* parent is also a child of `U`) was designed and vetted
during this session (Candidate 3's fix (a), §4) — it would bring `P1`×`P2`'s union to `x ≈ -6`
(vs. the clamp's `x = 0`), a materially tighter centering. **Not adopted into this plan's
implementation scope**, because:

- Track 3's clamp alone already resolves the literal S583/comment-1 symptom (union inside its
  parents' span) without it.
- The narrow substitution is itself a semantic extension of Track 6 §2.4's wording ("using each
  child's own final `x`") in a *different* way than Track 3's clamp, and stacking two independent
  reopenings of the same ratified formula in one plan increases review burden for a benefit
  (tighter centering, not correctness) this plan does not need to claim.
- It does not generalize past this one structural pattern (a child mating a co-sibling under the
  same union) — a future session finding a different duplicate-selection error would need its own
  bespoke patch regardless.

Recorded here, matching Track 4 §8's own precedent for "not adopted, not precluded" candidates,
so a future session does not need to rediscover it. See §4 (Candidate 3) for the full mechanism.

### 2.5 Issue #161 — recommend deferring

Owner-ratified (§9): **defer** the decision on hiding the `__union_N` marker (mechanically trivial
— the existing `size = 0` + transparent-color technique already used for D1/D2 waypoints applies
directly) until **after** Tracks 1–3 ship and stabilize. Rationale: hiding the marker changes what
a *residual, still-uncaught* same-row collision even looks like — a bare filled circle currently
gives a small extra visual landmark distinguishing "a mating happened here" from an ordinary
rectilinear bend; removing it before Track 2's detect-and-jog framework is proven on the real
fixture would make any remaining, not-yet-repaired collision *harder* to spot, not easier. Deciding
#161 now would also be scope creep relative to this plan's actual mandate (root-cause
collision-avoidance) — the BACKLOG.md item that bundled #161 into this session's scope itself
called it "a smaller, related decision," not part of the shared root cause.

---

## 3. Rationale

**Why a synthesis, not one of the 4 raw candidates:** each candidate scored well on some judge
lens and poorly on another (full scores in §4):

- **Row Ledger** (a general in-function reactive reservation primitive) scored highest on
  architecture-fit (8.5/10 — the deepest module of the four, fixes the actual exported function
  for every caller) but **lowest-but-one on correctness (5.5/10)**: its own `.reserveSpan()`
  exclusion is keyed only to the caller's own id, not to the children/parent whose already-seeded
  points *define* the span being reserved — so a D1 bar reservation would spuriously "conflict"
  with its own children on nearly every call, a real, unaddressed bug in the design as literally
  specified, not a stylistic nitpick.
- **Post-hoc Repair Pass** scored highest on testability (9/10 — the cleanest, fully-isolated
  session-by-session rollback ladder) and had a bug-free detection predicate, but is wired **only**
  at the Shiny layer (`R/modPedigree.R`), so any script calling `makePedigreeMatingLayout()`
  directly (the documented, exported entry point per `vignettes/a2interactive.Rmd`) still gets
  colliding output — a real completeness gap under the architecture lens (7/10).
- **Direct Three-Point Patch** scored highest on correctness (8.5/10 — its bar-row fix is an
  unconditional geometric guarantee, immune to any detection bug) but **lowest on architecture-fit
  (3.5/10)**: its duplicate-occurrence substitution restructures the ratified `finalUnitX` loop
  into a 4-stage pipeline, breaks ~11 existing golden-value tests, and none of its three fixes
  generalize past their own named symptom (D2/kept-mate/twin edges are explicitly left broken).
- **Row-Scan Detour Routing** was the most balanced (7.5/8.5/6.5 across the three lenses) but its
  own design **self-reports `preservesTrack4And6: false`** for its parent-span clamp, and its
  general-collision detection threshold carries a self-disclosed tuning risk (300+ close-but-
  non-colliding pairs already found in the real fixture).

**This plan takes Track 1 from the Direct Three-Point Patch** (its correctness-lens strength,
without the rest of that candidate's invasive, non-generalizing restructuring), **Track 2's wiring
discipline from Row-Scan Detour Routing** (wired into `makePedigreeMatingLayout()` itself, not
just Shiny — the architecture-lens strength Post-hoc Repair Pass lacked), **Track 2's detection
predicate from a combination of Post-hoc Repair Pass and Row-Scan Detour Routing** (strict
interior containment + explicit endpoint exclusion + explicit structural-member exclusion — the
exact fix all three judges independently named as the transferable correction to Row Ledger's
bug), **Track 2's edge-style-aware repair branching from Post-hoc Repair Pass** (never reroute a
curved edge through rectilinear waypoints), and **Track 3 essentially verbatim from both Direct
Three-Point Patch's fix (c) and Row-Scan Detour Routing's Part 1** (the two candidates converged
independently on the same clamp formula). No mechanism in this plan is untested design-by-
committee invention — every piece is a judge-vetted, coordinate-verified component of an actual
candidate that a real 12-agent workflow produced and scored.

---

## 4. Alternatives Considered

Full mechanisms, migration steps, risks, and verification plans for all four candidates are
preserved verbatim in the workflow transcript
(`/Users/rmsharp/.claude/projects/-Users-rmsharp-Development-nprcgenekeepr/5f68259f-6622-4bdd-8531-d2c60ad9fcb0/subagents/workflows/wf_57184bfd-eb7/journal.jsonl`).
Summary:

| Candidate | Correctness | Architecture | Testability | Why not adopted wholesale |
|---|---|---|---|---|
| **Row Ledger** (shared occupied-interval reservation, reactive, wired into both `.positionMatingUnitForest()` and `.addRectilinearWaypoints()`) | 5.5/10 | 8.5/10 | 8.5/10 | `.reserveSpan()`'s exclusion is keyed to the wrong id — a D1 bar reservation spuriously conflicts with its own already-seeded children, so "most fixtures unchanged" is false as literally specified. The reusable ledger *primitive* and radix-ordering discipline are grafted into Track 2 regardless. |
| **Post-hoc Repair Pass** (pure function appended after `.addRectilinearWaypoints()`, wired only at `R/modPedigree.R`'s Shiny reactive) | 7.5/10 | 7/10 | 9/10 | Fixes only the Shiny call path — any direct script caller of the documented `makePedigreeMatingLayout()` still gets colliding output. Its detection predicate, edge-style-aware repair branching, and exemplary session-boundary discipline are grafted into Track 2. |
| **Direct Three-Point Patch** (local-occurrence substitution + bar-row offset + parent-span clamp, all inside `.positionMatingUnitForest()`/`.addRectilinearWaypoints()`) | 8.5/10 | 3.5/10 | 8.5/10 | Restructures the ratified `finalUnitX` loop into a 4-stage pipeline, breaks ~11 golden-value tests, and none of its 3 fixes generalize past D1/S583. Its bar-row geometric guarantee (Track 1) and parent-span clamp (Track 3) are adopted near-verbatim; its duplicate-occurrence substitution is deferred (§2.4), not adopted. |
| **Row-Scan Detour Routing** (interval-stabbing jog + bounding-interval clamp, wired into `makePedigreeMatingLayout()` itself) | 7.5/10 | 5.5/10 | 6.5/10 | Self-reports `preservesTrack4And6: false`; its own detection-threshold tuning risk is self-disclosed as the biggest risk in the design. Its `makePedigreeMatingLayout()`-level wiring (vs. Shiny-only) and PRE-RED reopening-gate discipline are adopted into Track 2/Track 3. |

Two rejected-and-not-revisited alternatives from the *prior* three layout-feasibility spikes
(S588/S589/S590, closed as inherent before this session began) are explicitly not re-proposed
here: bounded-lookahead tuning of `mergeSubtrees()` (proven structurally incapable of a real fix
— the rigid-subtree model's minimum gap has no slack to recover), and a from-scratch hand-rolled
iterative relaxation without a formal convergence guarantee (hit an undiagnosed convergence
failure at high-mate-count hubs). Neither is a same-row-collision mechanism at all — both
recompute node `x` from a global objective, the exact failure class §1.1 already rules out.

---

## 5. Impact Analysis

| System | Impact | Action Required |
|---|---|---|
| `.positionMatingUnitForest()` (`R/makePedigreeDiagramData.R:584-1106`) | Track 3 only: one new clamp loop after the existing `finalUnitX` computation. Track 1/2 do not touch this function. | Implement Track 3's clamp (its own session, §6). |
| `.addRectilinearWaypoints()` (`R/makePedigreeDiagramData.R:1499-1731`) | Track 1: 2 lines changed (`barY` instead of `childY` for bar-waypoint `y`). Track 2 does not touch this function's body (new logic lives in a separate function called by `makePedigreeMatingLayout()`). | Implement Track 1's `sibshipBarFraction`/`barY` change (its own session, §6). |
| `makePedigreeMatingLayout()` (`R/makePedigreeDiagramData.R:1107-1498`) | Track 2 only: one new call to `.resolveEdgeNodeCollisions()` inside the existing `edgeStyle == "rectilinear"` branch (`:1428-1432`). | Implement Track 2's wiring (its own session, §6). |
| `tests/testthat/test_addRectilinearWaypoints.R` | Track 1 changes the D1 bar's `y` from `childY` to `barY` — ~11 existing golden-value assertions that hardcode `y == childY` for bar points (lines ~93, 156, 219, 244, 283, 323, 379, 434, 475, 503, 541, per the research inventory, §10) must be updated to assert the new, correct `barY` formula. This is **expected, disclosed test churn documenting a real behavior fix**, not a regression — the tests were previously asserting the buggy zero-height-row behavior. | Update in Track 1's own session, same commit as the production change. |
| `tests/testthat/test_positionMatingUnitForest.R` | Track 3 only: the "every mating unit satisfies the [Track 6] invariant" tests (`:986`, `:1019`) currently assert the *unconditional* `finalUnitX` formula; must be updated to accept "formula OR clamped-to-parent-range." | Update in Track 3's own session, gated by its own PRE-RED reopening `AskUserQuestion` (§6). |
| `tests/testthat/test_makePedigreeMatingLayout.R` | Track 3: audit `:428` (the fixed-linear-scale-of-Slice-2's-own-x invariant) for consistency with the clamp. Track 2: a new test file, `test_resolveEdgeNodeCollisions.R`, added; no existing assertion here is expected to change (Track 2 never moves an existing node). | Audit `:428` in Track 3's session; add the new test file in Track 2's session. |
| `R/modPedigree.R` (Shiny `diagramLayout` reactive, `:567-590`) | None — Track 2 is wired into `makePedigreeMatingLayout()` itself, so the Shiny layer needs no separate integration edit; it inherits the fix automatically through its existing call. | None. |
| `vignettes/a2interactive.Rmd` | None to the document itself; its own `makePedigreeMatingLayout()` demonstration now (correctly) produces collision-free output after Tracks 1–2 ship, with no doc change needed to achieve that. | Deferred to the standing `a2interactive.Rmd` checklist (`CLAUDE.md`) if a new parameter is ever added — Tracks 1–3 add no new exported parameter. |
| `vignettes/articles/kinship2-fidelity-validation.qmd` | Possible stale screenshots depicting the old bar-on-row rendering, if any embedded image happens to show a collision. | Check in Track 1's close-out. |
| `NEWS.Rmd` / `CHANGELOG.md` | Entries owed per the standing project checklists. | Add in each track's own close-out. |
| GitHub issue #160 | Closeable once Tracks 1–2 both ship (Track 1 alone closes the 2 originally-reported collisions; comment 1's broader finding needs Track 2). | Close with verification evidence per the standing GitHub issue close-out checklist, after Track 2. |
| `BACKLOG.md` S583 item | Closeable once Track 3 ships. | Close with verification evidence, after Track 3. |

**What does not change:** Track 4's anchor selection, gen-row assignment, and cross-unit-state
elimination (untouched by all 3 tracks); Track 6's `dupX` formula and broadened exact-de-collision
pass (untouched arithmetic — Track 3 only changes *when* `dupX` is computed relative to the new
clamp, never its formula); D1/D2 edge-orthogonality-never-depends-on-`x` (Track 1 changes a
waypoint's `y`, never whether D1 routes; Track 2 changes only which edges get an extra jog
waypoint, never D2's own `gen`-gated dogleg trigger); the recursive contour-merge engine
(`leafContour()`/`mergeSubtrees()`/`finalizeNode()`, `:649-688`) is not read from or written to by
any of the 3 tracks.

---

## 6. Migration Path

Each track is its own implementation session, full `PRE-RED → RED → GREEN → REFACTOR` TDD gates
(`AskUserQuestion` at every transition, per `CLAUDE.md`'s Development Process Contract), full
`devtools::check()`/clean-regression-read per `CLAUDE.md`'s Build/Test/Verify table. Ordered
smallest/most-certain-first, matching this project's own S562 precedent.

### Session A — Track 1 (D1 sibship-bar row offset)

- **PRE-RED:** confirm scope — this session touches only `.addRectilinearWaypoints()`'s D1 loop
  and its own test file; no ratified invariant is reopened (Track 1 changes a synthetic waypoint's
  `y`, never any real/duplicate/union node's `x` or `y`, never `gen`).
- **RED:** add a fixture reproducing issue #160 collision 1 (`204`/`205`/`__union_2` at the exact
  reported coordinates) and collision 2 (`209`/`__bar_207`/`__bar_208`), asserting `barY != childY`
  and `barY` strictly between `parentY` and `childY` for every D1 group; assert no real/duplicate/
  union node's `y` ever equals a bar waypoint's `y`. Update the ~11 existing golden-value tests
  (§5) to assert the new `barY` formula instead of `y == childY`. Confirm all new/updated tests
  fail against current code.
- **GREEN:** implement the `sibshipBarFraction`/`barY` change (§2.1) — minimum code to pass RED.
- **REFACTOR:** `lintr::lint_package()` on touched files; full clean-regression-read, confirm zero
  unexpected failures outside the deliberately-updated golden-value tests; render before/after
  images of the issue #160 fixture and visually confirm the bar no longer passes through
  `__union_2`/`209` (per the standing project/user preference to verify pedigree diagrams visually
  against ground truth, not just coordinate math). `NEWS.Rmd`/`CHANGELOG.md` entries. Check
  `vignettes/articles/kinship2-fidelity-validation.qmd` for stale screenshots.
- **Completion criteria:** both issue #160 originally-reported collisions provably cleared (§7);
  all ~11 updated golden-value tests pass with the new formula; full regression clean; `barY`
  guarantee holds for both `kinship2::sample.ped` family 2 and the real 375-individual bundled
  fixture.
- **Rollback:** revert the D1-loop body + test-file updates; no other file affected.

### Session B — Track 2 (general same-row detect-and-jog)

- **PRE-RED:** confirm scope — new standalone function + one call-site addition in
  `makePedigreeMatingLayout()`; explicitly confirm the curved duplicate-connector gets its own
  disclosed-heuristic branch, not a rectilinear reroute (§2.2).
- **RED:** `tests/testthat/test_resolveEdgeNodeCollisions.R` — reproduce issue #160 comment 1's
  `P1`/`P2`/`A`/`Y`/`W` fixture (the duplicate-connector-behind-`W` case), plus synthetic fixtures
  for a D2-dogleg-leg collision and a kept-mate-edge collision (neither reported yet, but
  structurally identical per the research, §10). Add a `.expectNoEdgeNodeCollision(nodes, edges)`
  helper (mirroring the existing `.expectNoOverlap` helper, `test_positionMatingUnitForest.R:25`).
  Confirm all fail against current code.
- **GREEN:** implement `.resolveEdgeNodeCollisions()` (§2.2) and the one-line call-site addition.
- **REFACTOR:** tune the jog buffer/`jogY` constants against the real 375-individual fixture and
  confirm the trigger count matches the small number of *actual* collisions (not the 300+
  close-but-non-colliding pairs the research already found — this is the single biggest tuning
  risk carried forward from the design candidates, §4); full clean-regression-read; visual
  verification of both the comment-1 fixture and the real fixture; `NEWS.Rmd`/`CHANGELOG.md`
  entries; close issue #160 citing both Session A and Session B's evidence.
- **Completion criteria:** `.expectNoEdgeNodeCollision()` passes for all 3 fixture types (D1
  residuals if any, D2 dogleg, kept-mate-edge) on both the synthetic and real fixtures, or a
  disclosed, counted residual if the iteration cap is hit; no pre-existing node's `x`/`y` changed
  (checked via an explicit `identical()` regression guard, §7); the curved-connector heuristic's
  effect confirmed (or explicitly not confirmed) via rendered-image inspection.
- **Rollback:** revert the new function + the one-line call-site addition; Session A's fix is
  independent and remains shipped.

### Session C — Track 3 (S583 parent-span clamp)

- **PRE-RED (its own explicit scope gate, separate from the ordinary RED→GREEN gate, per the TDD
  contract's requirement that reopening a ratified invariant is a scope decision in its own
  right):** `AskUserQuestion` confirming the owner still accepts clamping `finalUnitX` — reopening
  Track 6 §2.4's "unconditionally" wording to "child-centered, clamped to the union's own 2
  parents' x-range" — as ratified in this planning session (§9), before writing any RED test.
- **RED:** reproduce the exact S583 fixture (`5A6DFT`/`8DKELJ`/single-child) and the "second
  fixture, 3 more times" (`X`/`A`/`Y`/`W` unions) BACKLOG.md names, asserting clamped `x`. Update
  `test_positionMatingUnitForest.R:986`/`:1019` ("every mating unit satisfies the invariant") to
  accept "formula OR clamped-to-parent-range." Audit `test_makePedigreeMatingLayout.R:428`.
- **GREEN:** implement the clamp (§2.3), inserted after `finalUnitX` and before `dupX`'s
  computation (preserving Track 6 §10 correction 1's required ordering — `dupX` must read the
  *final*, i.e. clamped, union `x`).
- **REFACTOR:** full clean-regression-read; re-run the S589/S590 faithful full-pipeline
  measurement (per-child-edge `|childX − finalUnitX|` at the 200-unit threshold, baseline 9/251,
  3.6%, max 4,121.25) to confirm the clamp hasn't meaningfully worsened general child-centering
  quality on the real fixture; `NEWS.Rmd`/`CHANGELOG.md` entries; close the `BACKLOG.md` S583 item.
- **Completion criteria:** both S583 fixtures clamp correctly; the invariant tests pass under the
  revised "formula OR clamped" assertion; the fidelity-metric regression check shows no material
  worsening; full regression clean.
- **Rollback:** revert the clamp loop + test-file updates; Sessions A/B are independent and remain
  shipped.

---

## 7. Verification Plan

**Per-track**, reusing the faithful full-pipeline measurement discipline already established by
the S589/S590 spike documents (never test placement math in isolation from `orderBySex` + Track 6
`finalUnitX`/`dupX` + the final de-collision pass + `.addRectilinearWaypoints()`, since that
combination is what actually ships):

1. **Track 1:** reproduce issue #160 collisions 1 and 2 exactly (§1.2's coordinates); assert
   `barY` is never equal to any pinned node's `y`, for both fixtures and the real 375-individual
   fixture. Assert `__union_2`'s and `209`'s own `x`/`y` are byte-identical before/after (Track 1
   never moves a real/union node, only a synthetic waypoint's `y`).
2. **Track 2:** reproduce the comment-1 `P1`/`P2`/`A`/`Y`/`W` fixture; assert
   `.expectNoEdgeNodeCollision()` passes for the sibship-bar and D2/kept-mate-edge cases. Assert
   every pre-existing node's `x`/`y` is byte-identical before/after, checked via `identical()` over
   the full node table (not just the flagged rows) — the load-bearing "never move an existing
   node" invariant. Explicitly test and document the curved-duplicate-connector heuristic's actual
   effect via a rendered-image check, not coordinate math alone.
3. **Track 3:** reproduce both S583 fixtures; assert `finalUnitX[U] %in% [min(sireX,damX),
   max(sireX,damX)]` for every mating unit in both fixtures. Re-run the S589/S590 faithful metric
   against the real 375-individual fixture and confirm no material regression from baseline
   (9/251, 3.6%, max 4,121.25).
4. **Cross-track, after all 3 ship:** run the full `CLAUDE.md` "Clean regression read" command
   (`NOT_CRAN` set, `load_all()` first, `testthat::test_dir(..., reporter = "silent")`), confirm
   `sum(failed)`/`sum(error)` show zero unexpected new failures outside the deliberately-updated
   golden-value/invariant tests named in §5; re-run every load-bearing test enumerated in the
   research's inventory (§10) individually.
5. **Determinism:** re-run the fixed pipeline under differing `LC_COLLATE` settings (matching the
   Learning 585 precedent) and diff `nodes`/`edges` output byte-for-byte, for any new id-based sort
   Track 2 introduces.
6. **Visual verification** (per the standing project/user preference — `MEMORY.md`'s
   `pedigree-comparison-show-images` and `verify-diagrams-against-ground-truth` notes): render
   before/after images of every reproduction fixture and the real 375-individual fixture via
   `visNetwork`/`chromote`, and programmatically trace every rendered edge's path against the
   underlying pedigree data — not a visual-only eyeball check — confirming no edge passes through
   an unrelated node's bounding box.
7. **Build-equivalent:** `devtools::check()` after each track, 0 errors/0 warnings (ideally 0
   notes), per `CLAUDE.md`'s Build/Test/Verify table.

---

## 8. Explicitly Out of Scope (report, don't fix here — `PROJECT_LEARNINGS.md` Learning 382)

- **Track 4** (duplicate-occurrence-selection root fix, §2.4) — named, evidence-gathered, not
  scheduled. A future session may pick it up as its own planning/implementation pair if tighter
  centering (beyond what Track 3's clamp already achieves) is judged worth a second reopening of
  Track 6 §2.4.
- **Issue #161** (hide the union marker, §2.5) — recommended deferred until Tracks 1–3 ship and
  stabilize.
- **Vertical (same-column) collisions** — a D2 side→`projId` leg, or a D1 drop's vertical segment,
  passing through an unrelated node at a *different* row along its own `x`, is a related but
  distinct problem this plan's same-row (same-`y`) framework does not address.
- **General (non-exact) crowding** among unions/duplicates/reals that doesn't rise to a literal
  same-row edge-span collision — already an accepted, open gap per Track 6 §8, not newly
  introduced or newly closed by this plan.
- **Sibling subtree-width asymmetry** (the S576/S588-investigated, separately-tracked
  `BACKLOG.md` item — 9/251 residual >200-unit edges where sibling subtree sizes differ) — a
  distinct problem from union/edge collision, not addressed here.
- **Two different sibships landing their D1 bars on the identical `barY` row** if their x-ranges
  happen to overlap — Track 1 applies the *same* uniform fraction to every sibship; this is a new,
  low-probability failure mode outside the 4 documented symptoms, not examined in this plan
  (flagged during design review, §4). A future session should check for it empirically against the
  real fixture before considering Track 1 fully closed-out, and file it as its own issue if found.

---

## 9. Owner Ratification Record

Presented via `AskUserQuestion`, 2026-08-15, this session:

- **Architecture (3-track synthesis):** *"Approve 3-track synthesis (Recommended)"* — selected.
  Tracks 1–3 as designed in §2, with Track 4 explicitly deferred (§2.4), are ratified as this
  plan's implementation scope. The alternative "Tracks 1+2 only, hold Track 3" was presented and
  not selected — Track 3's S583-resolving clamp, and its disclosed reopening of Track 6 §2.4, are
  in scope, subject to Session C's own additional PRE-RED confirmation gate (§6) before any RED
  test is written.
- **Issue #161:** *"Recommend deferring (Recommended)"* — selected. The plan document recommends
  deferring the hide-the-marker decision until after Tracks 1–3 ship (§2.5); this is not an
  implementation task in this plan's scope.

---

## 10. Evidence-Based Inventory (grep, per `SESSION_RUNNER.md`'s Planning Sessions discipline)

Full grep output (all call sites of `.positionMatingUnitForest`, `.addRectilinearWaypoints`, and
`makePedigreeMatingLayout` across `R/`, `tests/testthat/`, `vignettes/`, `inst/`), the complete
list of `test_that()` blocks that must not regress, the full Track 4/Track 6 ratified-invariant
extraction, and the full 3-prior-spike history (what was tried, why it was rejected, and the
"order-then-compact" idea named-but-not-pursued by S590) are preserved verbatim in the workflow
transcript's `research` field:
`/Users/rmsharp/.claude/projects/-Users-rmsharp-Development-nprcgenekeepr/5f68259f-6622-4bdd-8531-d2c60ad9fcb0/subagents/workflows/wf_57184bfd-eb7/journal.jsonl`
(also archived at `/Users/rmsharp/.claude/jobs/65b07ece/tmp/research.txt`,
`/Users/rmsharp/.claude/jobs/65b07ece/tmp/candidates.json`, and
`/Users/rmsharp/.claude/jobs/65b07ece/tmp/judges.json` for this session's own record — those job
paths are ephemeral and will not survive past this session; the journal is the durable copy).

**Key file:line anchors used throughout this document** (all verified by direct code read this
session, not assumed):

| Symbol | Location |
|---|---|
| `.positionMatingUnitForest()` | `R/makePedigreeDiagramData.R:584-1106` |
| `makePedigreeMatingLayout()` | `R/makePedigreeDiagramData.R:1107-1498` |
| `.addRectilinearWaypoints()` | `R/makePedigreeDiagramData.R:1499-1731` |
| `.buildMatingUnitForest()` | `R/makePedigreeDiagramData.R:347-520` |
| `finalUnitX` loop (Track 6 §2.4 formula) | `R/makePedigreeDiagramData.R:966-975` |
| `nodes` frame built (no duplicate rows yet) | `R/makePedigreeDiagramData.R:884-889` |
| `childEdges` construction (always real ids) | `R/makePedigreeDiagramData.R:511-516` |
| `duplicates` loop (parent role only) | `R/makePedigreeDiagramData.R:478-499` |
| `dupX` formula (Track 6 §2.2) | `R/makePedigreeDiagramData.R:977-980` (current site; Track 3 moves the computation point, not the formula) |
| Final exact-de-collision pass | `R/makePedigreeDiagramData.R:987-1010` |
| `sweepMinSep()` | `R/makePedigreeDiagramData.R:864-878`, applied `:879-882`, `:1021-1023` |
| Contour-merge engine (untouched by this plan) | `R/makePedigreeDiagramData.R:649-688` |
| D1 sibship-bar `y`-coordinate (Track 1's edit site) | `R/makePedigreeDiagramData.R:1530-1540` |
| D1 bar chain edges | `R/makePedigreeDiagramData.R:1544-1552` |
| D2 dogleg (`projId`, edit-adjacent for Track 2) | `R/makePedigreeDiagramData.R:1579-1628` |
| Duplicate dashed-connector construction | `R/makePedigreeDiagramData.R:1370-1385` |
| `keptEdges`/`finalEdges` assembly (Track 2's call site) | `R/makePedigreeDiagramData.R:1630`, `:1695`; call added at `:1428-1432` |
| `yScale` / `y` assignment | `R/makePedigreeDiagramData.R:1167`, `:1302-1303` |
| Reserved node-id prefixes (existing 5) | `vignettes/a2interactive.Rmd:500` |

---

## References

- `docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md` — Track 4 ratification.
- `docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md` — Track 6
  ratification.
- `docs/planning/pedigree-diagram-sibling-subtree-width-plan.md` /
  `-evidence.qmd` — S588, bounded-lookahead spike (closed as inherent).
- `docs/planning/pedigree-diagram-nonrigid-layout-spike-plan.md` — S589, hand-rolled
  barycenter/median spike (closed as inherent).
- `docs/planning/pedigree-diagram-layout-sugiyama-spike-plan.md` — S590,
  `igraph::layout_with_sugiyama()` spike (closed as inherent).
- [Issue #160](https://github.com/rmsharp/nprcgenekeepr/issues/160) — rectilinear sibship-bar
  false-parentage defect (S591).
- [Issue #161](https://github.com/rmsharp/nprcgenekeepr/issues/161) — mating-union marker
  visibility question (S591).
- `BACKLOG.md` — S583 union-outside-parent-span item; the Active-section root-cause planning item
  this document delivers.
- `PROJECT_LEARNINGS.md` Learning 585 — locale-independent (`radix`) ordering requirement.
