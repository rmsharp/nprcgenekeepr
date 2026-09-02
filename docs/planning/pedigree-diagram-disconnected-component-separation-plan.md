# Pedigree Diagram: Disconnected-Component Separation Plan

**Status: SUPERSEDED, same session (2026-09-01, Session 664), before implementation
started.** See
[`pedigree-diagram-parent-symmetric-placement-plan.md`](pedigree-diagram-parent-symmetric-placement-plan.md).

This plan's own root-cause analysis was incomplete: it was written *before* comparing
nprcgenekeepr's coordinates against kinship2's own `align.pedigree()` numbers directly.
That comparison (done immediately afterward, same session, owner-directed) found the same
collision-and-bump symptom occurring in a **fully connected** pedigree with no disconnected
families at all (Track B full's `P3`/`P4`/`C4`/`P6` — see the superseding plan's evidence
table), which this plan's "disconnected components" framing cannot explain. The real,
shared root cause is a more fundamental asymmetry in how a mating pair is placed relative
to their children's center — fixing that may resolve this exact fixture's symptom without
the post-hoc translation pass proposed below. Left in place, unedited beyond this notice,
as the historical record of what was diagnosed first and why it wasn't sufficient — per
this project's own convention of not rewriting a session's prior reasoning after the fact.

**Late update, same session (2026-09-02): this plan's original concern is NOT dead.**
The superseding plan's own "conditional shift" fix, applied naively (each qualifying pair
corrected independently, with no cross-pair awareness) to Track B's **shrunk** fixture —
the exact fixture this plan was originally written against — reintroduced a disconnected-
component visual overlap (`P1×P2`'s union dot landing exactly on `C4`'s position, and vice
versa), because that naive application bypassed the existing collision-avoidance machinery
this plan never proposed touching. See the superseding plan's own "ITEM 4 CONFIRMED TO
FAIL" section. Whether this plan's own post-hoc rigid-translation mechanism (Option C) ends
up being part of the eventual fix, or is superseded by folding component-separation into
the existing collision-avoidance pass instead, is an open question for whichever future
session designs the real fix — not resolved by either plan alone.

**Original status line (superseded):** Fix approach RATIFIED (owner-directed via
`AskUserQuestion`, Session 664, 2026-09-01): **Option C — post-hoc rigid separation of
disconnected components.** Implementation (RED/GREEN/REFACTOR) not yet started; see the
session's own handoff for whether it was picked up same-session or deferred.

**Found:** 2026-09-01, Session 664, live during an owner-directed re-verification of
pedigree-diagram fidelity (the owner had not seen a fresh demonstration in several
sessions and did not accept `BACKLOG.md`'s `[x]` checkboxes as proof on their own).

## Context

### Problem statement

`makePedigreeMatingLayout()` can render two individuals from **completely unrelated,
disconnected pedigree families** as if they were visually connected — a colony manager
looking at the diagram could reasonably conclude two strangers are related when they are
not. This is not a cosmetic nit: pedigree diagrams exist specifically to communicate
relatedness, so a false-looking connection is a correctness defect in the diagram's actual
job, even though the underlying data structure is not corrupted.

**Reproduction:** `data-raw/kinship2FidelityValidation.R`'s Track B "shrunk" fixture (8
survivors of `shrinkPedigree()` on the article's own 16-subject composite pedigree) —
already a committed, run-every-session fixture, not a contrived edge case. Two disconnected
families survive the shrink: `{P1, P2, M1, G3, L3}` and `{C4, P6, C4a}` — there is no sire,
dam, or mate edge of any kind between the two groups. `kinship2::plot.pedigree()` (ground
truth) draws them as two visibly separate blocks with a real gap. `makePedigreeMatingLayout()`
interleaves them column-wise (`P1, C4, P2, P6` left to right) and routes `P1`'s and `C4`'s
respective mate-lines as rectilinear jogs that pass directly under/through the other
family's nodes, at a vertical offset (13.5–27 layout units, node radius ~25 units) far too
small to read as "below" in the rendered image. The result reads as one connected row.

**Confirmed reproducible, not a screenshot flake:** re-rendered twice independently
(`chromote` screenshot), both fresh renders identical in structure. Also confirmed the
*previously committed* evidence image for this exact fixture (`trackB-nprc-shrunk.png`,
committed Session 649, 3 days before this finding) was **additionally** and **separately**
broken — visibly overlapping, unlabeled circles, not even legible — and nobody had reopened
it to look since. Both problems were invisible to every session between S649 and S663
because the only automated check run against this fixture (`compareAgainstKinship2()` /
Track D, `R/comparePedigreeStructure.R`) compares the kinship-graph edge list only, never
physical layout — it correctly reports `identical: TRUE` for this exact broken rendering.

### Root cause (traced against real coordinates, not inferred)

`.buildMatingUnitForest()` classifies every founder with no mating units of their own as a
"B1" (free-pass) individual (`R/makePedigreeDiagramData.R:701-703`) and excludes them from
`rootIds` — the list of tree roots fed to the Buchheim-Junger-Leipert apportioning engine
(`.positionTreeApportion()`). In the shrunk fixture this reduces `rootIds` to just `{P1,
C4}` — each family's *anchor* founder — because `P2`, `P6`, and `G3` are each their family's
non-anchor mate and therefore B1.

`P1` and `C4` are the tree's only two root-level siblings, so the apportioning engine places
them in adjacent columns (abstract x = 0, 1) with no awareness that they belong to different
families — there is no such concept as "family" or "component" anywhere in the algorithm.
Tier 3 then positions each B1 mate via `b1AnchorRelativeX()`
(`R/makePedigreeDiagramData.R:805-810`), which computes `tier1X[[anchor]] + sign * minSep`
— purely relative to the mate's own anchor, blind to what already occupies that slot. `P2`
wants column 1 (right next to `P1`) — but `C4` is already there. The generic collision
avoidance in `.deCollideIndividualPoints()` (`R/makePedigreeDiagramData.R:866-`, S647) then
bumps `P2` outward with no concept of family boundaries either, landing it at column 2 —
squarely inside `C4`'s family's territory. `P6` (wanting column 2, next to `C4`) collides
with the now-relocated `P2` and gets bumped to column 3. The chain (`P1@0, C4@1, P2@2,
P6@3`) is exactly the interleaved row in the screenshot.

This is a genuinely different defect class from the one `.expectNoOverlap()`
(`tests/testthat/test_positionMatingUnitForest.R`) checks: every node in this fixture *is*
at a distinct, non-overlapping coordinate — the existing test suite would pass on this exact
broken rendering. The suite's one related test, `"...positions a fully isolated founder ...
distinct from an unrelated family's positions"` (same file, ~line 382), covers a founder
with **zero mating units** — a materially narrower case than two mated founder-pairs each
needing B1 relative placement, which is what actually triggers this chain.

**Why the FULL 16-subject fixture doesn't show this:** there, `P1`'s subtree is wide (4
children: `C1, C2, C3, M1`), so `P1`'s own tree column is naturally many units away from the
second family's root column — enough incidental clearance that the same B1-relative-offset
mechanism never collides across families. The bug has been latent and undetected because
the one fixture exercising it structurally (Track B full) happens to have a wide-enough
first family to hide it, and nobody built a fixture with two *narrow* disconnected families
until `shrinkPedigree()` produced one live, by accident, during this session.

## Decision (RATIFIED: Option C)

### Option A — Pre-widen: reserve extra clearance between root-level siblings at Tier 1

Before Tier 3 runs, inspect which root-level tree siblings are each a mating-unit anchor
with a known B1 mate, and insert extra abstract-x spacing between such siblings (beyond the
plain `minSep` sibling gap) sized to the maximum possible B1-relative excursion.

- **Pros:** Change is localized to the point where roots are laid out; doesn't touch the
  B1 formula or collision search at all.
- **Cons:** Only helps at the *root* level — two components can still collide deeper in the
  tree if a non-root node's B1 mate reaches sideways into a sibling subtree (not proven to
  happen, but not proven not to, either, without a fuller audit). Sizing "maximum possible
  excursion" requires reasoning about `.deCollideIndividualPoints()`'s own bounded search
  (`.kMaxIndividualPush = 2`) — coupling two independently-tuned pieces of the algorithm.

### Option B — Constrain the collision search to same-component space only

Modify `.deCollideIndividualPoints()` so its bidirectional search never proposes a
candidate position inside another weakly-connected component's occupied x-range; if the
capped search can't find a same-component slot, fall back to the original (pre-push) value
rather than crossing the boundary.

- **Pros:** Fixes the defect at its most precise point — the exact function that does the
  cross-family bump.
- **Cons:** Touches the same heavily-tuned, extensively-commented function S647 already
  hardened three times (unbounded push → bidirectional search → capped search, each
  fixing a real regression the previous fix introduced). Highest risk of a new regression
  in exactly the code with the most fragile prior history in this file.

### Option C — Post-hoc rigid separation of components (RECOMMENDED)

After Tiers 1–3 finish (all positions final, including any B1 excursions), identify
weakly-connected components of the pedigree graph (sire/dam/mate edges — new, self-contained
helper; grepped, no such general-purpose helper exists yet in `R/`), compute each
component's occupied x-range, and if any two components' ranges are closer than a fixed
minimum family gap (several `minSep` units — sized to comfortably exceed the observed 2–3
unit chain here and the `.kMaxIndividualPush = 2` cap elsewhere), apply a single rigid
horizontal translation to every node in the rightward component(s). Re-run
`.addRectilinearWaypoints()`'s jog computation after translation (relative intra-component
distances are unchanged by a rigid shift, so this should be routing-neutral for edges
*within* a component).

- **Pros:** Doesn't touch the delicate 3-tier apportioning math or the collision search at
  all — pure post-pass, easy to reason about and to unit-test in isolation. Generalizes:
  fixes this defect class for *any* future narrow-component pairing, not just this
  fixture, and makes explicit (rather than accidental, as it is today) the separation the
  Track B *full* fixture currently gets "for free" from subtree width alone. Matches how
  kinship2's own `align.pedigree()` conceptually treats multiple families as independent
  blocks.
- **Cons:** New code path (component detection + translation), so it is not "zero new
  surface area" — but the surface area is a plain, independently testable graph
  traversal, not a change to tuned formulas.

**Recommendation: Option C.** It isolates the fix to new, independently-verifiable code
rather than perturbing either of the two already-fragile mechanisms (root ordering, B1
collision search) that a wrong touch could regress elsewhere on the real 375-individual
production fixture referenced throughout this file's own commit history.

## Alternatives Considered

| Alternative | Pros | Cons | Why not recommended first |
|---|---|---|---|
| A — pre-widen root siblings | Localized | Doesn't cover non-root collisions; couples to collision-search internals | Narrower guarantee than C |
| B — constrain collision search | Most precise fix point | Modifies the most regression-prone function in the file | Highest risk given documented history |
| C — post-hoc rigid separation | Isolated, general, testable alone | New code path | **Recommended** |
| Do nothing, document as accepted difference | No engineering cost | Owner has already rejected an "acceptable difference" framing once for this file (the `P5` isolated-node case) for a visibly-wrong rendering | Rejected — matches a precedent the owner already overturned |

## Impact Analysis

| Surface | Impact | Action Required |
|---|---|---|
| `R/makePedigreeDiagramData.R` | New component-detection + translation step added after Tier 3, before `.addRectilinearWaypoints()` | New internal function(s), `@noRd` |
| `tests/testthat/test_positionMatingUnitForest.R` | New test(s) for the disconnected-two-narrow-families case (this exact shape); existing tests must remain green unchanged | RED phase |
| `tests/testthat/test_makePedigreeMatingLayout.R` | Possible new end-to-end assertion that two components' bounding boxes never overlap/near-touch | RED phase |
| `data-raw/kinship2FidelityValidation.R` Track B shrunk image | Will change once fixed — regenerate and re-commit `trackB-nprc-shrunk.png` | Same session as GREEN |
| Real 375-individual production fixture | Should be unaffected structurally (single connected pedigree in the normal case) but must be re-verified after the change — this project's own established regression discipline | Full clean regression + visual spot-check before close-out |
| `.expectNoOverlap()` test helper | Does not currently catch this defect class at all | Consider whether a `.expectComponentsSeparated()`-style helper is worth adding alongside the fix (not required, but flagged) |

## Verification Plan

- Full clean regression (`devtools::test()` / the project's documented clean-regression
  command) — 0 failed/0 error beyond the one pre-existing unrelated
  `test_wordlist_coverage.R` failure.
- `lintr::lint_package()` — 0 lints on touched files.
- Regenerate `data-raw/kinship2FidelityValidation.R`'s Track B shrunk images and visually
  confirm (send actual images, per this session's own established practice) the two
  families now render with a real, unambiguous gap and no cross-family jog routing.
- Spot-check the real production fixture's rendering is visually unchanged (it is a single
  connected pedigree, so this fix should be a no-op there, but "should" is not "confirmed"
  until actually looked at).

## Scope boundary

**In scope:** fixing the disconnected-component interleaving/jog-crossing defect described
above.
**Out of scope (explicitly not this fix):** Track C's duplicate-node placement difference
from kinship2 (already investigated this session, found structurally correct — a valid
alternate layout choice, not a defect); any other pedigree-diagram fidelity question not
raised by this specific finding; the live Shiny app demo (deferred until this fix is
designed/ratified, per the owner's own staged request this session).
