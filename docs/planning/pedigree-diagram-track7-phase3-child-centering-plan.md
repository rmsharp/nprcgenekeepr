# Track 7 Phase 3: Restoring Straight/Centered Descent Lines for Qualifying Unions

**Date:** 2026-08-29 · **Session:** S651 · **Type:** architecture/design document
(`docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`) — planning session, no
implementation this session, matching this project's established precedent for
pedigree-positioning decisions (the same workstream used for the Track 7 mate-spacing plan
itself, `docs/planning/pedigree-diagram-track7-mate-spacing-plan.md`).

**Tracks:** [issue #166](https://github.com/rmsharp/nprcgenekeepr/issues/166) — filed by a
2026-08-29 audit workflow from a finding the Track 7 Phase 1 design session itself disclosed
but did not fix (`pedigree-diagram-track7-mate-spacing-plan.md` §11, "5th finding," found by
the owner 2026-08-27). Standing top-priority pedigree-drawing-fidelity item (`BACKLOG.md`,
S643).

**Design RATIFIED S651, 2026-08-29 (owner-picked via `AskUserQuestion`, presented with §2's full
3-option evidence, including this document's own adversarial re-verification findings): Option 1
(§2.1, scoped revert).** Implementation (TDD RED→GREEN→REFACTOR, §5 Migration Path) is READY for
a future session — not attempted this session, per this project's standing "plan is the
deliverable, implementation is a separate session" rule (`SESSION_RUNNER.md` Planning Sessions).

---

## 1. Context

### 1.1 Problem statement

Track 7 Phase 1 (S647) fixed two named defects in the original BACKLOG item: "the mating-unit
marker (dot) renders on the sire's own symbol instead of centered between sire and dam" and
"mates are not visibly spread apart, unlike kinship2." Its mechanism was two independent
changes, both gated to a `qualifies()` subset of mating units (monogamous anchor, childless
"free-pass" mate, unambiguous opposite-sex pairing — 34/237 anchored units on the real
375-individual bundled fixture):

1. **Widen the mate's own offset** (`derivedX()`'s B1 branch, `R/makePedigreeDiagramData.R:812-818`)
   from `minSep * 0.4` to a full `minSep` — moves the free-pass mate's own rendered position
   farther from the anchor.
2. **Recenter the union's own `x`** (`R/makePedigreeDiagramData.R:973-979`) at the true
   anchor/mate midpoint — moves the union DOT itself to sit visibly between the two parent
   symbols, instead of on/near the anchor.

Change (2) is what issue #166 traces the defect to. It overwrites Tier 2's own
`unitX[[u]] <- mean(tier1X[kids])` (`:764-765`) — a value with no relationship to the union's
parents at all — with a value that has no relationship to the union's *children*. Two visible
consequences, both already documented with committed screenshot evidence
(`vignettes/articles/kinship2-fidelity-validation-img/trackB-nprc-full.png` vs.
`trackB-kinship2-full.png`):

- **Single-child qualifying unions get a right-angle dogleg instead of a straight drop.**
  Before Track 7, a single-child union's `x` was *always* exactly its one child's `x` (the mean
  of one value) — the descent line was always a straight vertical drop, matching kinship2's own
  rendering exactly. Track 7's recenter formula has no relationship to the child's position, so
  `.addRectilinearWaypoints()`'s D1 sibship-bar mechanism (`:1735-1759`) correctly inserts a
  jog to connect the union's new `x` to the child's unchanged `x`.
- **Multi-child qualifying unions get an off-center sibship bar.** The bar's drop point (at the
  union's `x`) no longer lands at the true mean of its children's positions.

### 1.2 Hard constraint: a full non-rigid-layout replacement is already closed as infeasible

[Issue #159](https://github.com/rmsharp/nprcgenekeepr/issues/159) investigated exactly this
class of tension — this project's Walker/BJL engine positions children first, top-down,
recursively, and (unlike kinship2's `alignped4()`, which solves for every individual's position
in one joint constrained optimization) can never move an already-placed child to reconcile it
with a parent decision made later. Three independently-designed non-rigid-layout candidates
(a bounded-lookahead contour-merge, a barycenter/median relaxation, and an adaptation of
`igraph::layout_with_sugiyama()`, a proven CRAN implementation) were each prototyped and
**each regressed the real 375-individual fixture** on every measured axis (edge count exceeding
threshold, max offset, layout width, and — for the sugiyama candidate — edge crossings, its own
optimization objective), via three distinct failure mechanisms. Closed 2026-08-15 as inherent:
"three independent paradigms converging on the same real-fixture failure is sufficient evidence
the current rigid-subtree layout is a reasonable local optimum for this project's real,
highly-connected pedigree data."

**This design does not reopen that investigation.** Every option below operates entirely within
the existing rigid, sequential (children-positioned-first) architecture — no candidate proposes
moving a child, adopting a joint solver, or porting kinship2's actual mechanism. §4 Alternatives
documents why a full port was already rejected at the Track 7 Phase 1 design stage too (its own
Alternative C).

### 1.3 kinship2 reference: how the "joint solve" actually reconciles this (from source, not inference)

Read `alignped4.R` (kinship2's default QP-based positioning solver) directly. Two relevant
findings:

- **kinship2 has no separate "couple center" variable.** Every data structure indexes one
  individual per cell; wherever it needs a couple's shared center it computes it on the fly as
  `x_dad + 0.5` (`alignped4.R:33-35`, `besthint.R:49-50`) — never stored, never decoupled from
  the individuals' own positions.
- **The single-child straight-line guarantee is an emergent property of moving the CHILD, not a
  hard rule.** The QP's parent-child centering term (`alignped4.R:24-37`) is a soft penalty
  applied simultaneously to parent and child columns in one shared least-squares system — for an
  isolated only-child couple, at the optimum, `x_child == x_dad + 0.5` exactly, because the
  solver is free to move the child to close that residual. Nothing in kinship2 special-cases
  `k==1`; the exact alignment holds only "when nothing else touches `x_child`" (no grandchildren,
  no same-level crowding) — kinship2 tolerates a small offset for a single child too, whenever
  competing terms exist.

**This confirms the structural diagnosis in issue #166 and the Track 7 plan's own §11:**
kinship2's straight-drop guarantee comes from adjusting the child, which this project's
architecture cannot do (§1.2). There is no clever local trick that reconciles the union's
recentered `x` with its children's `x` without either (a) moving the child (excluded by §1.2),
or (b) inserting a rectilinear jog somewhere between the union symbol and the child — which
does not eliminate the defect, only relocates it (verified directly: `.addRectilinearWaypoints()`
constructs the union→drop segment as pure vertical only when the drop point shares the union's
own `x`; any decoupled "descent origin" distinct from the union's rendered `x` reintroduces
exactly the same jog one level down the path, just at a different height. No design below
proposes this decoupling for that reason.)

### 1.4 The decision space is a hard binary, not a tunable spectrum — proven empirically

Issue #166's own recommendation offers "post-adjust... to stay within some bounded distance of
its children's mean" as one candidate direction. **A live measurement (below) shows this does not
work as a graduated dial for this specific problem — it collapses to a binary choice.**

Measured live (`pkgload::load_all()` + `.buildMatingUnitForest()` + `.positionMatingUnitForest()`,
called directly, not read from a script's prior output — same discipline as the Track 7 plan's own
methodology, §12.1) against the real 375-individual bundled fixture
(`inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv`, 237 anchored mating units):

**Finding A — divergence between the shipped (Track-7-recentered) `x` and children's mean, for
all 34 qualifying units with ≥1 child (33 single-child, 1 two-child):**

| | Min | Median | Mean | Max |
|---|---|---|---|---|
| `|finalX − childrenMeanX|` (raw units) | 0.242 | 0.500 | 0.648 | 2.275 |

23/33 single-child cases sit at *exactly* `0.5` (`minSep/2`, the base recenter formula's own
magnitude with no collision-avoidance push involved). 7 cases are larger (up to 2.275) — traced
(via `trace()` environment capture on a live call, not re-derived by hand) to Track 7 Phase 2's
own collision-avoidance push (`R/makePedigreeDiagramData.R:1007-1094`) additionally moving the
union to avoid an exact-position collision with an unrelated individual or union node in 5/7
cases; the other 2 inherit a small pre-existing Tier-3 de-collision epsilon from their own mate's
point, unrelated to Track 7. **A cap set at or above `0.5` (the dominant case) would do nothing
for the majority, headline complaint** (the "normal," non-collision-driven single-child dogleg);
a cap well below `0.5` approaches full reversion without committing to it, at real implementation
cost (a new empirically-tuned constant, its own live-render verification pass — matching the
3-iteration tuning cost Track 7 Phase 1's own individual-push cap required, §3.3 Alternative C
below) for an outcome partway between the two clean options.

**Finding B — proves reverting Track 7's recenter exactly reintroduces the ORIGINAL defect it
fixed, not merely "moves it closer":**

For every one of the 34 qualifying units, `mean(tier1X[kids])` (Tier 2's pre-Track-7 value) was
measured against `tier1X[[anchor]]` (the anchor's own Tier-1 position):

```
|childrenMeanX - anchorX| across all 34 qualifying units: min = 0, median = 0, mean = 0, max = 0
```

**Exact equality, to floating-point precision (bitwise, not `all.equal`-tolerance), for all
34/34 units on the real fixture — not approximate.** This is not a coincidence: the
`qualifies()` gate requires `mateCountP == 1` (the anchor has *exactly* one mating union). Tier
1's own tree-apportioning algorithm (`.positionTreeApportion()`) computes an individual's `x` as
a function of its own descendant subtree — for an anchor with only one union, that subtree *is*
this union's children, so the anchor's `x` and this union's children-mean are the same
recursively-propagated quantity at the apportioning stage. (Confirmed independently in the
existing synthetic unit test `test_positionMatingUnitForest.R:73-93` — a 3-child trio where the
comment already states "P1 stays at its own tier1X (1.0, centered over its 3 children by BJL's
own Tier-1 apportioning)," i.e. the same identity, by construction, in a hand-checkable example.)

**Adversarially re-verified (independent workflow, S651) — CONFIRMED-WITH-CAVEAT, not an
unconditional algorithmic law.** An independent re-derivation (its own script, environment
capture verified bitwise-identical to the real function's actual internal state, not a
re-implementation) reproduced the 34/34 exact-zero result precisely, and additionally proved
the mechanism algebraically for `.positionTreeApportion()`'s own pre-sweep stage (a
`prelim - mod` invariant that survives every later shift). **But it also found the equality is
contingent on `sweepMinSep()`** (the gen-grouped minimum-separation backstop applied to
`tier1X` *after* apportioning, `:738-749`) **never engaging one of these 34 anchors' own
generation row — which happens to be true on the real fixture (confirmed: `sweepMinSep()` moves
0 of 308 individuals there, so it is inert by construction for this specific fixture, not proven
harmless in general) but is not a property the algorithm guarantees.** A hand-built, 54-row
synthetic pedigree run through the real, unmodified `.buildMatingUnitForest()` +
`.positionMatingUnitForest()` pipeline exhibits a genuinely qualifying anchor whose row *does*
trigger `sweepMinSep()` (crowded by an unrelated same-generation individual) — post-sweep,
`tier1X[[anchor]]` and `mean(tier1X[kids])` diverge by `-0.125`, well beyond any floating-point
tolerance. **This does not change the recommendation** (§2.4 is scoped to this project's own
standard verification fixture, matching every prior Track 7 session's own precedent of measuring
against the real 375-individual bundled fixture as the decision-relevant case), but it means
Option 1's "exactly reverts to the original, already-tested pre-Track-7 value" framing (§2.1)
holds as measured fact on the real fixture, not as a proof that no fixture could ever show a
qualifying union settling at a small, nonzero offset from its own children's mean post-`sweepMinSep()`
— itself a strictly smaller residual than today's `minSep/2`-or-larger divergence, and still
fully consistent with pre-Track-7 shipped behavior (this exact contingency already existed,
unremarked, in every session before Track 7 Phase 1 ever ran). Noted here for honesty, per this
project's own "measured, not guessed" discipline — not a blocker.

**Consequence:** any correction that pulls a qualifying union's `x` back toward its children's
mean walks it, exactly, back onto its own anchor's `x` — the precise "dot renders on the sire's
own symbol" defect Track 7 Phase 1 was built to fix. There is no intermediate value that
achieves partial descent-line fidelity without proportionally re-approaching that same original
defect, because for this specific subset the two reference points (anchor `x`, children mean)
are not merely correlated — they are identical. The decision is which of the two mutually
exclusive visual properties to keep for these 34 units: **descent-line straightness/centering,
or union-dot centering between the two parents.** §2 evaluates this trade-off directly; it is
not resolved by picking a magic-number cap.

---

## 2. Decision space

Three options, evaluated below. §2.4 states a recommendation; ratification is via
`AskUserQuestion`, matching this project's established pattern for exactly this class of
subjective visual trade-off (e.g. issue #161's "keep the dot" decision, Track 7 Phase 1/2's own
alternatives-then-ratify structure).

### 2.1 Option 1 — Scoped revert: remove the union-recenter step only, keep the mate-widening step

**Mechanism:** delete the Track 7 Phase 1 recenter loop
(`R/makePedigreeDiagramData.R:973-979`) entirely. `unitX[[unitId]]` for every unit — qualifying
or not — reverts to Tier 2's unconditional `mean(tier1X[kids])`, exactly as it was before Track
7 Phase 1. **Track 7 Phase 1's *other* change (the widened `minSep` B1 offset in `derivedX()`,
`:812-818`) is left completely unchanged** — the free-pass mate still renders a full `minSep`
from the anchor. Track 7 Phase 2 (the union-vs-node collision-avoidance push, `:981-1094`) is
also left completely unchanged; it operates on whatever `unitX[[u]]` value it is handed and does
not care how that value was derived.

**Effect:**
- Fully and exactly eliminates issue #166's defect for all 34 qualifying units (straight drops,
  centered bars — Finding B proves the reverted value is bit-identical to the pre-Track-7,
  kinship2-matching one).
- Keeps Track 7's headline "mates are not visibly spread apart" fix completely intact — the two
  parent *symbols* stay visibly separated; only the small union-dot *marker* reverts to sitting
  on/near the anchor for these 34 units.
- Re-introduces the *original* Track 7 Phase 1 complaint ("dot renders on the sire's own
  symbol") for exactly these 34 units. This is a real, disclosed trade-off, not a side effect to
  hide — the dot is a small, low-stakes visual element (already established by issue #161's own
  "keep vs. hide the dot" resolution, which the owner settled by direct visual comparison
  without much at stake either way).

**Collision-avoidance interaction — argued and grounded, not just asserted:** reverting does not
introduce a new interaction class. Every qualifying union will now land *exactly* on its own
anchor's `x` — but this is the *same* exact-coincidence case the shipped code already has
dedicated, tested handling for: `R/makePedigreeDiagramData.R:1039-1041` explicitly excludes a
union's own anchor/non-anchor from Phase 2's *push*-search occupied set (a union sitting exactly
on its own anchor is expected, not something to push away from), while the unconditional
"residual small-epsilon pass" (`:1079-1090`, which uses the *unfiltered* occupied set) still
applies its existing `1e-3` nudge to break the exact tie — the same mechanism already
responsible for "~150 exact ties" the codebase's own comments describe as *already present and
handled* pre-Track-7. Reverting does not create a new code path; it restores the exact numerical
condition (union `x` == anchor `x`) the pre-existing epsilon-nudge machinery was built for
before Track 7 ever existed. What *can* change: Phase 2's collision-avoidance push starts its
search from a different point (`anchorX` instead of the Track-7-recentered value) for these 34
units, which can change *which* unrelated node a push resolves a collision against. This needs
re-measurement (§5), not a new design.

**Adversarially re-verified (independent workflow, S651) — CONFIRMED, plus new measured data.**
An independent read of `:940-1094` confirmed the anchor/non-anchor exclusion (`:1039-1041`) and
the unconditional unfiltered epsilon pass (`:1079-1090`) work exactly as described. It then went
further and *simulated* a full revert against the real fixture (a patched copy of
`.positionMatingUnitForest()`, environment-parented to the real package so every helper is
identical; read-only, no source file touched) to measure collision impact directly rather than
argue it abstractly:

- **0 new individual-vs-union collisions, 0 new union-vs-union collisions** — the union-vs-union
  scenario this design's own reasoning did not explicitly rule out (could two reverted unions
  collide with *each other*?) was checked directly and does not occur on the real fixture.
- **Union-vs-duplicate residual: 4 → 3 net, but not zero-churn at the identity level** — the
  already-disclosed, pre-existing residual (`:1043-1047`'s own comment; `BACKLOG.md`
  Housekeeping) shifts composition: 1 genuinely new case (`__union_14`, one of the 34 qualifying
  units, newly 0.0843 raw units from duplicate node `__dup_L31S6S_3`) and 2 pre-existing cases
  resolve (`__union_19`, `__union_181`). This is a new *instance* of an already-known interaction
  class (duplicate positions aren't yet computed when Phase 2's sweep runs, a genuine data
  dependency — same root cause the Track 7 plan's own §12.11 already disclosed), not a new class
  of risk. No non-qualifying union anywhere in the 237 changed collision status.
- **Push-search activity, post-revert:** 14/237 units (not only the 34 qualifying ones) trigger
  Phase 2's collision push after reverting; all 14 resolve at `k ∈ {1, 2}` — none reach
  `.kMaxUnionPush = 5`'s fallback-to-epsilon path.

This is genuinely reassuring evidence beyond what §2.1's own textual argument claimed — the one
class of interaction the original reasoning did not explicitly address (union-vs-union, among
the reverted set) measures zero, and the one residual that does shift is confined to an
already-disclosed, already-tracked interaction class, not a new failure mode. §5 step 2's
mandatory live-render check remains the gate for the actual implementing session to reconfirm
this on its own working tree, not a substitute for it.

### 2.2 Option 2 — Accept and formally close as a disclosed, permanent limitation

**Mechanism:** no code change. Document the tension in
`vignettes/articles/kinship2-fidelity-validation.qmd` (matching the existing disclosed-caveat
convention already used for the union-vs-duplicate-proximity residual and the `__jog_*`
waypoint-styling gap), close issue #166 citing this design document and issue #159's own
"closed as inherent" precedent directly.

**Effect:** zero implementation risk, zero test churn, zero verification cost. Leaves the
dogleg/off-center-bar fully visible on all 34 qualifying units, permanently, as a known
trade-off of Track 7 Phase 1's own recenter — consistent messaging with issue #159's own
adjacent "rigid-subtree layout has real, accepted limits" verdict.

### 2.3 Option 3 (not recommended) — Numeric-tuned partial clamp

**Mechanism:** bound `|unitX[[unitId]] - childrenMeanX|` to some empirically-chosen cap `C`,
applied at the recenter site (`:973-979`) *before* Track 7 Phase 2's collision push runs on the
result (so Phase 2's own mechanism is unaffected in kind, only in its starting point — same
reasoning as Option 1's collision-interaction argument in §2.1).

**Why not recommended:** Finding A (§1.4) shows this does not behave as a graduated compromise
for this specific problem. A cap at or above the dominant `0.5` magnitude fixes nothing for the
majority, headline case; a cap meaningfully below `0.5` approaches Option 1's own outcome
without fully committing to it, while adding real cost Option 1 does not have: a new magic
constant requiring its own empirical, live-render-verified tuning pass (mirroring the 3-iteration
convergence-tuning history both Track 7 Phase 1's `.kMaxIndividualPush` and Phase 2's
`.kMaxUnionPush` each needed) for a partial, harder-to-characterize visual outcome ("descent
lines are less kinked, but not straight; the dot is less centered, but not on the anchor either")
that is arguably worse to explain to the owner and to future sessions than either clean
alternative. Included here for completeness — it was seriously considered, not a straw man — and
because it directly answers issue #166's own suggested mitigation with measured evidence rather
than silently dropping it.

### 2.4 Recommendation

**Option 1.** It fully resolves issue #166's own reported defect (not a partial mitigation),
touches strictly less code than the current shipped mechanism (removes 7 lines, adds none), does
not introduce any new tuning constant or new collision-avoidance interaction class (§2.1's
argument, grounded directly in already-shipped, already-tested machinery), and preserves the
half of Track 7 Phase 1's own value (mate separation) that does not structurally conflict with
descent-line fidelity — while being transparent that the other half (dot-exactly-centered) is
traded away for these 34 units specifically. Option 2 remains a legitimate zero-cost fallback if
the owner weighs the dot-centering property more heavily than descent-line straightness; presented
for ratification, not decided unilaterally, per this project's established convention for this
class of visual trade-off.

---

## 3. Rationale

### 3.1 Why this is a design session, not a quick patch

The recenter mechanism (`:973-979`) is read by, or interacts with, at least 10 other locations in
`R/makePedigreeDiagramData.R` (§6.3 lists the decision-relevant subset) and is pinned by numeric
assertions or formula checks in at least 14 test blocks across 4 test files (§6.3, adversarially
re-verified — the original inventory undercounted this), several of which encode the exact
formula this design proposes changing. This matches this project's own established bar for touching
`.positionMatingUnitForest()` — every prior track (1–7) went through a dedicated planning session
first (`SAFEGUARDS.md`'s "never refactor across module boundaries without plan mode," and this
project's own consistent practice, cited by the Track 7 plan's own §2.1).

### 3.2 Why not simply "fix the jog" at the rendering layer

Considered directly (this is the shape of the Track 7 Phase 1 plan's own rejected Alternative D,
§4 below) and rejected for the same reason that document gave: decoupling the union's rendered
(pixel) position from the data-level `x` value edges and tooltips actually reference creates a
*new* class of defect — a drawn symbol that does not match what the underlying coordinate data
says is there. §1.3 additionally shows this specific decoupling would not even eliminate the
jog, only relocate it to a different segment of the same path.

### 3.3 Why the collision-avoidance interaction is treated as a diagnosis, not a footnote

Track 7 Phase 1 and Phase 2 each needed 3+ iterations to get right specifically because a change
to `unitX` cascades into `.addRectilinearWaypoints()`'s D1 sibship-bar construction and
`.resolveEdgeNodeCollisions()`'s same-row detector in ways that are not obvious from the
positioning code alone (Track 7 plan §11's own "third attempt, shipped" history; §12.11's
duplicate-node residual, discovered only by running the real algorithm, not a simulation). This
design does the same live-measurement, source-grounded diagnosis *before* proposing a mechanism,
rather than after — Finding A and Finding B (§1.4) are both live measurements against the real
fixture, and the collision-interaction argument in §2.1 is grounded in specific, cited lines of
already-shipped code, not a plausibility argument.

---

## 4. Alternatives Considered

| Alternative | Pros | Cons | Disposition |
|---|---|---|---|
| **Option 1 — Scoped revert (recommended)** | Fully eliminates the defect; removes code; no new tuning constant; grounded collision-safety argument | Re-introduces the original dot-on-anchor defect for 34 units (disclosed trade-off) | **Recommended**, pending `AskUserQuestion` ratification |
| **Option 2 — Accept and close** | Zero cost, zero risk | Leaves the defect fully visible, permanently | Legitimate fallback |
| **Option 3 — Numeric-tuned partial clamp** | Directly matches issue #166's own suggested wording | Proven (Finding A) not to behave as a useful graduated compromise for this specific problem; adds a tuning constant and its own verification pass for a worse-to-explain outcome | Rejected — evidence-based, not a straw man |
| **Full non-rigid-layout replacement** (join positioning of parents and children) | Would match kinship2 exactly, for every union, not just this subset | Already investigated and closed as infeasible — 3 independent candidates, 3 independent failure mechanisms, all regressing the real fixture (issue #159) | Rejected — out of scope, not reopened |
| **Port kinship2's actual QP solver** | Ground-truth fidelity | Disproportionate architectural paradigm shift, already rejected at Track 7 Phase 1's own design stage (its own Alternative C) for the identical reason | Rejected, same reasoning as precedent |
| **Rendering-only pixel-offset decoupling** (leave `x` unchanged; draw the dot elsewhere) | No data-level change | Decouples drawn position from data `x` (edges/tooltips reference the wrong spot) — the identical rejection Track 7 Phase 1's own Alternative D gave; and (§1.3) does not even eliminate the jog, only relocates it | Rejected, same reasoning as precedent, independently reconfirmed |
| **Conditionally skip recenter only when it would collide** (Track 7 Phase 2's own Alternative E) | Avoids ever moving a union post-recenter | Produces inconsistent per-unit behavior (some qualifying units recenter, others silently don't); does not address the dominant, non-collision-driven case (Finding A) | Rejected, same reasoning as precedent |

---

## 5. Migration Path

Option 1 is a small, contained change with no data migration, no schema change, and no
multi-step cutover — a single-commit, single-session implementation is expected to fit within
one TDD RED→GREEN→REFACTOR cycle. Rollback is trivial (revert one commit; the removed 7 lines
are the entire mechanism).

**Implementation-session steps (for whichever future session picks this up, pending
ratification):**

1. **RED:** update the tests that currently pin the *pre-fix* (Track-7-recentered) formula as
   correct. **Adversarial re-verification (S651) found this list is at least 7 blocks, not the 2
   an initial pass identified** — flip all of them, not just the two most obvious ones:
   `test_positionMatingUnitForest.R:73` (3-child trio, `unionX == 1.5` vs. children mean `1.0`),
   `:227` (the GA204Z/8LKBV9 fixture's own comment: "no longer the midpoint of its children...
   the midpoint of its two PARENTS' x instead"), `:931` (the `checkInvariant()` helper, run
   across 3 fixtures *including the real 375-individual one* — the single most load-bearing of
   the 7, since it's the only place the formula distinction is checked live against real data),
   `:1426` (≥3-child union, explicit "midpoint of its 3 children" framing), `:1919` (P1/P2/C1-C3
   + P3/P4/C4 fixture — note this fixture uses issue #166's own `P3`/`P4`/`C4` ids), and `:2022`
   (pins `nQualifying == 34L` and structures its whole loop around skipping "qualifying" units —
   under a revert, "qualifying" becomes a vacuous concept with no recenter to gate, so this
   test's *structure*, not just a number, needs rewriting). Two further blocks (`~:1790`,
   `:2161`) use inequality bounds rather than exact pins and will likely still pass numerically,
   but their prose is Track-7-specific and will read as stale — reword, don't just leave as-is.
   Add new assertions reproducing issue #166's own named cases (`P3xP4->C4`/`C4xP6->C4a`
   single-child doglegs, `M1xG3`'s off-center bar) if a suitable fixture doesn't already exist —
   confirmed by the same re-verification: no existing `tests/testthat/` fixture currently
   renders/inspects that specific geometry (the full 16-subject Track B fixture *is* duplicated
   verbatim in `test_comparePedigreeStructure.R:1036,1167`, but only for topological/structural
   comparison via `compareAgainstKinship2()` — never for `makePedigreeMatingLayout()`'s own
   x-coordinates or dogleg/bar geometry). The only place this specific geometric evidence
   currently lives is the `.qmd` vignette's committed screenshots.
2. **GREEN:** delete the recenter loop (`R/makePedigreeDiagramData.R:973-979`). Re-run the
   remaining test suite; expect several pinned-count tests to shift (§6 Impact Analysis) —
   re-measure and update each live, not by guessing the new number.
3. **Mandatory live-render regression check** (matching Track 7 Phase 1 §7 / Phase 2 §12.6's
   own established, non-optional verification step): render via the existing `chromote`-based
   live-render helper (`tests/testthat/helper-live-render-positions.R`) at production `xScale`,
   and re-run `.resolveEdgeNodeCollisions()`'s same-row detector before/after, specifically
   checking for any NEW sibship-bar-vs-bar or bar-vs-node overlap the reverted starting points
   introduce via Phase 2's collision-avoidance push landing somewhere different than before.
4. Regenerate and visually re-inspect `trackB-nprc-full.png`/`trackB-nprc-shrunk.png` against
   `trackB-kinship2-full.png` — confirm straight drops for `P3xP4->C4`/`C4xP6->C4a` and a
   centered bar for `M1xG3`, and confirm the union dot's own new position is disclosed
   accurately in the vignette's own prose (the dot now sits on/near the anchor for these 34
   units — update any caption/verdict text claiming otherwise).
5. Full clean regression (`devtools::test()` / this project's established clean-regression-read
   command). `lintr::lint_package()` (loaded first, per `CLAUDE.md`'s Lint checklist).
6. `NEWS.Rmd` entry (plain-language, per `CLAUDE.md`'s checklist) — a user-facing Shiny rendering
   change.

---

## 6. Impact Analysis

### 6.1 What changes

- `R/makePedigreeDiagramData.R`: `.positionMatingUnitForest()` loses 7 lines (the recenter
  loop). No other function's source changes.
- Every qualifying union's rendered `x` (and hence its dot's screen position, its descent
  line's straightness, and its sibship bar's centering) reverts to the pre-Track-7 value.
- The free-pass mate's own rendered position is **unchanged** (Track 7 Phase 1's widened
  `minSep` offset stays).

### 6.2 What does not change

- `.buildMatingUnitForest()`, Tier 1 (`.positionTreeApportion()`), Tier 3
  (`derivedX()`/`b1AnchorRelativeX()`/`.deCollideIndividualPoints()`), and Track 7 Phase 2's
  collision-avoidance push mechanism are all untouched in *kind* — Phase 2 still runs, on
  whatever `unitX` value it is handed.
- `.addRectilinearWaypoints()`, `.resolveEdgeNodeCollisions()`: unchanged code; different
  *inputs* only.
- Non-qualifying units: entirely unaffected (they were never touched by the recenter loop).

### 6.3 Consumer / test inventory (grep-based, per `SESSION_RUNNER.md`'s evidence-based inventory requirement for a plan that changes shared logic)

**Downstream consumers of a qualifying union's `x` inside `R/makePedigreeDiagramData.R`:**

| Location | Effect of reverting |
|---|---|
| `:812-818` `derivedX()`, B3 duplicate branch | A duplicate node representing a qualifying union's non-anchor elsewhere rides along with the reverted value — unchanged mechanism, different number. |
| `:1007-1094` Track 7 Phase 2 push | Reads the (now reverted) `unitX[[u]]` as its search's starting point — mechanism unchanged, starting point moves back to `anchorX` (§2.1's collision-safety argument). |
| `.addRectilinearWaypoints()` D1 (`:1735-1759`) | The mechanism that renders the dogleg — this is the fix site's actual effect; no code change needed here, the input changes. |
| `.addRectilinearWaypoints()` D2 (`:1794-1830`) | Reads a union's *gen* (`yOf[[U]]`) directly, and a parent's `x` — a Track-7-recentered vs. reverted union `x` can change *which side* needs a mate-line dogleg if the union's gen assignment logic itself is untouched (it is) — needs re-measurement, not a mechanism change. |
| `.resolveEdgeNodeCollisions()` (`:2008+`) | Generic same-row detector — consumes whatever `x` a union ends up with; recount, don't guess. |

**Tests asserting a pinned value/formula that would need review — adversarially re-verified
(S651); the original count of 2 "must flip" tests was substantially incomplete.** Independent
re-verification found **at least 7** `test_that()` blocks in `test_positionMatingUnitForest.R`
alone that pin or dynamically assert the Track-7 anchor/mate-midpoint formula and require a real
logic change, not just a new number: lines **73, 227, 931, 1067 (†see note), 1426, 1919, 2022**
— see the Migration Path (§5) RED step above for what each one asserts and why. `:931` is
arguably the single most load-bearing, since it is the only place the formula distinction is
checked live against the real 375-individual fixture and the F1 consanguineous fixture together.
No test in `tests/testthat/` currently exercises the exact committed *geometry* issue #166 names
(straight-vs-dogleg rendering, bar-vs-children-mean deviation) for Track B's full 16-subject
fixture — that evidence lives only in the `.qmd` vignette's committed screenshots; the fixture
itself *is* separately duplicated in `test_comparePedigreeStructure.R:1036,1167`, but only for
topological comparison, never geometry. No currently-passing test already asserts the reverted/
straight behavior for a known-qualifying union (nothing is silently already failing).

Several aggregate pinned-count tests will shift as a side effect and must be re-measured live,
not derived by formula: `test_positionMatingUnitForest.R:425` (`nCollidingNodes == 27L`) **and,
separately (†), `:1067`'s own independently-computed, differently-scoped `27L` assertion** — the
same numeric value from two distinct computations (`:425` excludes duplicate nodes; `:1067` does
not) that the original pass conflated into one citation; both need independent re-measurement.
Also: `:1148`/`:1209` (Track 7 Phase 2's own proximity-count assertions),
`test_addRectilinearWaypoints.R:664` (`oldHits`/`newHits` D1 bar-vs-bar counts, already
explicitly attributed in-comment to the qualifying recenter), `test_makePedigreeMatingLayout.R:593`
(1,474-node count, `__jog_` sub-count already attributed to "widening/recentering 34 qualifying
mating units"), `test_resolveEdgeNodeCollisions.R:399` (107-collision baseline, same
attribution), and **`test_makePedigreeMatingLayout.R:1005`** (a twin-relations fixture pinning
`nrow(connectors) == 5L`, with an explicit in-comment attribution to "S647's capped-search
position changes" — missing from the original inventory entirely).

### 6.4 What might break (risk assessment)

- **Low risk, argued in §2.1:** the exact-coincidence-with-anchor case is pre-existing, tested
  machinery, not a new interaction.
- **Medium, expected, and budgeted-for:** the aggregate pinned-count tests listed in §6.3 will
  need live re-measurement — this is normal test maintenance for this kind of positioning
  change, not a sign of a flawed design (the Track 7 Phase 1/2 sessions each hit and handled
  the same class of count drift).
- **Requires explicit verification, not assumed:** whether Phase 2's collision-avoidance push,
  now starting from `anchorX` instead of the Track-7-recentered value for these 34 units,
  resolves to a *different* set of collisions than today — §5 step 3's mandatory live-render
  check is the gate for this, matching Track 7 Phase 1/2's own established discipline (never
  optional for a change touching this mechanism).

---

## 7. Verification Plan

Reusing this project's own established methodology for this exact function (Track 7 plan §12.6,
itself following §7) — a future implementing session should not invent a new verification
approach:

1. Pre-RED empirical validation: re-run this design's own Finding A/B measurements live against
   the implementation's working tree, confirming the reverted values match children-mean exactly
   for all 34 units (the same identity Finding B already proved holds for the current shipped
   code's own inputs).
2. **Mandatory live-rendered D1/D2 regression check** (not optional — §12.6's own explicit
   framing for exactly this class of change): via the existing `chromote`-based live-render
   helper, checking specifically for new sibship-bar/mate-line collisions the reverted starting
   points introduce.
3. Full clean regression (`devtools::test()` / this project's clean-regression-read command) —
   0 new failures/errors beyond the pre-existing, unrelated `test_wordlist_coverage.R` baseline.
4. Visual re-verification: regenerate and directly inspect (not just re-render)
   `trackB-nprc-full.png`/`trackB-nprc-shrunk.png` against `trackB-kinship2-full.png`.
5. `lintr::lint_package()` (loaded first).
6. `NEWS.Rmd` entry, `CLAUDE.md` checklist.

---

## References

- [issue #166](https://github.com/rmsharp/nprcgenekeepr/issues/166) — this design's own trigger.
- [issue #159](https://github.com/rmsharp/nprcgenekeepr/issues/159) — the closed non-rigid-layout
  investigation this design does not reopen (§1.2).
- [issue #161](https://github.com/rmsharp/nprcgenekeepr/issues/161) — "keep the dot" precedent,
  cited in §2.1/§2.4 for why the dot marker itself is a low-stakes visual element.
- `docs/planning/pedigree-diagram-track7-mate-spacing-plan.md` — Track 7 Phase 1/2's own design
  document; §11's "5th finding" is this design's origin, §4/§12.4 are this design's own
  alternatives-table precedent, §7/§12.6 are this design's own verification-plan precedent.
- `R/makePedigreeDiagramData.R:627-1123` (`.positionMatingUnitForest()`),
  `:1682-1933` (`.addRectilinearWaypoints()`).
- kinship2 source (`scratchpad/alignped4.R`, `align_pedigree.R`, `alignped1-3.R`, `besthint.R`,
  `autohint.R`) — fetched in a prior session's layout-spike research, re-read directly for §1.3.
