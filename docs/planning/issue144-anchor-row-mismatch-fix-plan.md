# Issue #144 Plan — Anchor-side row mismatch fix (Pedigree Diagram)

**Tracks:** GitHub issue **[#144](https://github.com/rmsharp/nprcgenekeepr/issues/144)** (filed
S471, 2026-08-04, spun out of the issue #143 founder-positioning fix design session).

**Authored:** Session 473 (2026-08-04), **planning session**, following
`docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` — chosen over `DESIGN_WORKSTREAM.md`,
matching this project's own precedent for pedigree-diagram positioning work (S432's issue #129
plan, S458's Option 2 layout plan, and S471's issue #143 plan all made the same call for the
same reason: this is a technical/algorithm-correctness call, not a panel-arrangement call). TDD
phases (RED/GREEN/REFACTOR) are inapplicable to this document — it is a plan, per this project's
own established precedent. **The implementation below is its own separate session** (RED ->
GREEN -> REFACTOR), not this one.

**Status:** DRAFT — pending owner ratification. Revised once, after a 3-agent adversarial review
(mechanism-fidelity, empirical gap-check, workstream-checklist compliance — mirroring S471's own
review pattern for the sibling #143 plan): corrected a factual miscount (3, not 4, directly-
affected test files), corrected an over-broad "provable no-op" claim about Edit 3's guard (true
only for the one-dangling-parent case; the both-dangling case is a separate pre-existing crash,
now filed in §8), widened §6's disclosed residual to include a single-mating-unit-plus-D5-child
trigger (not only multi-unit anchors), and added 2 newly-found pre-existing/unrelated bugs plus
one documentation-staleness gap to §8. None of the review findings changed the adopted Decision,
the 3 edits themselves, or any of the plan's core numeric claims — all were independently
re-verified against live source and held up exactly.

**Method:** this plan was produced by a research-then-design workflow (7 subagents): 4 parallel
characterization agents (mechanism verification against live source, empirical enumeration of
all 51 real-fixture mismatches, a grep-based test/callsite inventory, and a full read of prior
context/dragons), followed by 3 independently-generated candidate designs, each empirically
validated in its own isolated git worktree (patched, run against the real fixture, run against
the full existing test suite). This mirrors — and extends — the adversarial-review discipline
S471 used for the issue #143 plan (3 independent reviewers). The author (this session) read the
core algorithm (`.buildMatingUnitForest()`/`.positionMatingUnitForest()`) directly from source
before dispatching any subagent, and independently re-verified the winning candidate's mechanism
claim against that same source before adopting it — not delegated wholesale.

---

## 1. Context

### 1.1 Problem statement

Issue #143 (already shipped, commit `904d74b7`) fixed the **non-anchor** side of the
founder-positioning defect: a non-anchor occurrence (free-pass or duplicate) rendered at the
underlying individual's own global tree-native `gen`, not its mating unit's `gen`. That fix
deliberately left the **anchor** side untouched. Issue #144 is the anchor-side sibling: **51 of
237 real-fixture mating units (22%)** have an anchor occurrence whose own displayed row (`gen`)
differs from its mating unit's `gen` (`unitGen = max(sire's gen, dam's gen)`).

Root cause, independently re-verified this session against live source
(`R/makePedigreeDiagramData.R`), with one correction to the originally-hypothesized mechanism:

- `unitGen = pmax(genOf[sire], genOf[dam], na.rm = TRUE)` per mating unit (`:251-253`).
- `preferAnchor(a, b)` (`:199-207`), the D2 anchor-selection tie-break, never consults `gen` —
  only founder status, then total mate count, then ascending id.
- An anchor's own displayed row is always its raw, unmodified `ped$gen` (`dispGenOf <-
  genOf[realIds]`, `:596`) — never overridden. Only free-pass ids are overridden (the #143 fix,
  `:597-600`).
- **Correction (confirmed empirically, not merely reasoned):** it is not only `preferAnchor()`'s
  own tie-break rule that produces mismatches. The anchor-assignment loop's `used`/elimination
  branch (`:224-241`) sits **structurally before** `preferAnchor()` is ever consulted: if exactly
  one of a unit's two parent candidates was already claimed as anchor by an earlier-processed
  unit, "the unused one wins by elimination," full stop — bypassing `preferAnchor()` entirely,
  including its founder-preference rule. On the real fixture this produces 2 distinct root
  causes within the same 51-mismatch population: **42/51** are ordinary `preferAnchor()` ties
  between two non-founders that happen to land on the lower-gen parent; **9/51** are the
  elimination branch overriding a would-be-correct founder-preference outcome (concrete example:
  unit `__union_65` anchors `8LKBV9`, marking it `used`; unit `__union_68`
  (`8LKBV9` x `8P17E3`) then has `8P17E3`, a founder with `gen=0`, win by elimination over the
  non-founder `8LKBV9` (`gen=1`), even though `preferAnchor("8LKBV9","8P17E3")` alone would
  prefer the non-founder). Both are real, both are present in the shipped 51-mismatch count.

Gap distribution (empirically confirmed against `inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv`,
reusing `test_positionMatingUnitForest.R`'s own committed issue #144 regression-guard detection
method verbatim): gap=1: 23 units (45%), gap=2: 21 (41%), gap=3: 6 (12%), gap=4: 1 (2%). All 51
anchor ids are pairwise distinct — no anchor individual anchors more than one mismatched unit,
and (checked across the *whole* 237-unit forest, not just the 51) **no anchor individual anchors
multiple units at genuinely different `unitGen` values anywhere in this fixture** — the 2 real
double-anchor individuals (`KUENM8`, `IM1B5T`) each anchor units that already share one common
`unitGen`. By construction of `unitGen = max(...)`, the "neither parent matches `unitGen`" case
is structurally impossible — confirmed absent (0 of 237 units).

### 1.2 Constraints

(a) Must not regress the ratified D1-D6 mechanism (`docs/planning/pedigree-diagram-option2-layout-design-plan.md`,
S458, RATIFIED) for any part this fix does not intend to change. (b) Must not silently reopen
D2/D4's already-documented row-order-sensitivity dragon without addressing it explicitly. (c)
MIT-license / no-GPL constraint (inherited, not directly implicated — this fix is pure R). (d)
**Governance note, resolved this session:** the Option 2 plan ratifies D2 only at the level of
"a fixed, deterministic, non-search-based tie-break exists and is applied consistently
pre-recursion" (`docs/planning/pedigree-diagram-option2-layout-design-plan.md` §3/§10) — it does
not state or imply that gen-blindness is itself a protected, load-bearing property. D2's
implementation has already evolved once post-ratification without reopening the plan (the
`KUENM8`/`IM1B5T` double-anchor fallback was added after ratification as a correctness fix, not
treated as a plan amendment). A change to `preferAnchor()`'s criteria — the path **not** taken
by this plan's adopted Decision (§2), but seriously evaluated as Candidate A (§5) — would
therefore not require reopening the ratified Option 2 document, but would still need its own
dedicated design rigor, which is exactly what this document (and the empirical work behind it)
provides for the alternative that *is* adopted below.

### 1.3 Current state — verified directly, not from the audit's or issue's summary alone

`.positionMatingUnitForest()`'s `positionIndividual(id)` (`R/makePedigreeDiagramData.R:505-522`)
has two `genOf[[id]]` references that determine an individual's own row-reservation and display:

```r
positionIndividual <- function(id) {
    ...
    if (length(subIds) == 0L) {
      relNode[[id]] <- list(childIds = character(0L), childOffsets = numeric(0L))
      return(leafContour(genOf[[id]]))                                    # :513
    }
    subResults <- lapply(subIds, function(sid) {
      if (sid %in% unitIds) positionUnit(sid) else positionIndividual(sid)
    })
    fin <- finalizeNode(mergeSubtrees(subResults), genOf[[id]])            # :518
    ...
}
```

Critically — and this is the load-bearing fact this plan's Decision rests on, verified directly
by reading `finalizeNode()`/`mergeSubtrees()` (`:427-458`) and by empirical validation (§7 of
the workflow's Candidate B report, reproduced in this plan's §2/§4): **the `ownGen` argument to
`leafContour()`/`finalizeNode()` affects only contour *row-occupancy bookkeeping* (which
absolute-`gen` row this node claims horizontal width at, for future sibling-merge collision
avoidance) — it has zero effect on the node's own `x` (computed purely from `xs`, the merged
children's offsets) and is never passed down into the recursion.** Each recursive callee
(`positionUnit(sid)`/`positionIndividual(sid)`) resolves its own row entirely independently, from
its own `genOf[[sid]]`/`unitGenOf[[sid]]`. The "reserve my own row" concern and the "recurse into
my children" concern are already fully decoupled in the existing code.

This directly contradicts the standing assumption in `BACKLOG.md` and issue #144's own body —
"moving an anchor's displayed row would require restructuring D3's recursive positioning itself
... materially larger than issue #143's point-patch" — which was a reasonable *a priori* guess
(an anchor "has a subtree," so surely relocating it is entangled with that subtree) that this
session's empirical work shows is **false** for this specific implementation. See §2/§4.

The final `nodes` constructor (`:602-608`) already has a `dispGenOf` override mechanism, added by
the #143 fix, currently applied only to free-pass ids (`:596-600`):

```r
dispGenOf <- genOf[realIds]                                                # :596
realFreePassIds <- intersect(freePassIds, realIds)                         # :597
if (length(realFreePassIds) > 0L) {
  dispGenOf[realFreePassIds] <- unname(unitGenOf[freePassUnitOf[realFreePassIds]])
}
```

`.addRectilinearWaypoints()` already has a D2 mate-line "dogleg" (issue #142, shipped) that
reroutes the connecting edge — but does not move the node — for exactly these 51 anchor-mismatched
units under `edgeStyle="rectilinear"`; `test_addRectilinearWaypoints.R:301-360` already exercises
and locks in this compensating behavior. `edgeStyle="direct"` gets no compensating treatment at
all today.

### 1.4 Why this is being designed now, not deferred further

Owner-directed priority (issue #144's own body, and this session's orientation-report picker):
near-term follow-up, not a low-priority residual, given the confirmed substantial (not
theoretical) real-data prevalence (22% of all real-fixture mating units).

---

## 2. Decision

**Adopt Candidate B — extend the #143 `dispGenOf`-override pattern to anchors, via a new
per-individual "effective row" (`effGenOf`) that changes only where an anchor's own contour
reservation and display happen — not who anchors what.** `.buildMatingUnitForest()` (D1/D2,
anchor *selection*) is **untouched**. Confirmed via `git diff` (1 file, `R/makePedigreeDiagramData.R`)
and via `test_buildMatingUnitForest.R`'s full 66/66 passing expectations against the patched tree.

### 2.1 The three synchronized edits (all inside `.positionMatingUnitForest()`)

**Edit 1 — compute `effGenOf`**, immediately after the existing `freePassOfUnit <- split(...)`
line (`:480`), before `positionIndividual`/`positionUnit` are defined. Reuses data already fully
computed at this point (`matingUnits$anchor`, `unitGenOf`) — no new upstream computation:

```r
# before (nothing — new code)
# after
anchorUnitsOf <- split(matingUnits$id, matingUnits$anchor)
effGenOf <- genOf
for (aid in names(anchorUnitsOf)) {
  effGenOf[[aid]] <- max(genOf[[aid]], unitGenOf[anchorUnitsOf[[aid]]])
}
```

`effGenOf(id)` degrades to `genOf[[id]]` unchanged for every individual who never anchors
anything (`max()` over an empty `unitGenOf` slice plus the scalar returns the scalar) — a
provable no-op for every free-pass/duplicate-only individual, matching the #143 fix's own
already-narrow scope.

**Edit 2 — thread `effGenOf` through the anchor's own two row-reservation call sites**, inside
`positionIndividual(id)` (`:513`, `:518`). The recursion into `subIds` (two lines above/below,
unchanged) is **not** touched — each child continues to resolve its own row from its own
`genOf`/`unitGenOf`/`effGenOf`, independent of the parent. (Precision note: `:513`'s
`leafContour()` branch is only reachable when `subIds` is empty — i.e. `id` anchors nothing and
has no D5 child — which by definition never applies to an anchor; under the algorithm's current
invariants an anchor always reaches the `:518` `finalizeNode()` call instead, so `:513`'s edit is
defensive/symmetry-only, not independently load-bearing. Harmless either way; noted so a future
reader doesn't overweight its practical effect.)

```r
# before
      return(leafContour(genOf[[id]]))                                # :513
    ...
    fin <- finalizeNode(mergeSubtrees(subResults), genOf[[id]])        # :518
# after
      return(leafContour(effGenOf[[id]]))
    ...
    fin <- finalizeNode(mergeSubtrees(subResults), effGenOf[[id]])
```

**Edit 3 — extend the existing `dispGenOf` override block** (`:596-600`) with a mirror-image
override for anchors, alongside the pre-existing free-pass override:

```r
dispGenOf <- genOf[realIds]
realFreePassIds <- intersect(freePassIds, realIds)
if (length(realFreePassIds) > 0L) {
  dispGenOf[realFreePassIds] <- unname(unitGenOf[freePassUnitOf[realFreePassIds]])
}
# NEW
realAnchorIds <- intersect(names(anchorUnitsOf), realIds)
if (length(realAnchorIds) > 0L) {
  dispGenOf[realAnchorIds] <- unname(effGenOf[realAnchorIds])
}
```

The `intersect(names(anchorUnitsOf), realIds)` guard is harmless in practice, but is **not, as an
earlier draft of this plan claimed, a provable no-op by the reasoning "a dangling parent can
never win anchor status."** That reasoning (`.buildMatingUnitForest()`'s `p1Real != p2Real`
branch, `:222-224`, hands anchor status to the real side unconditionally) only covers the
**one-dangling-parent** case. Adversarial testing during this plan's review found that when
**both** of a unit's parents are dangling, `p1Real == p2Real == FALSE`, so that branch is skipped
entirely; `isFounderOf()` (`:185-195`) treats a dangling id as founder-like rather than erroring,
so the ordinary `preferAnchor()`/elimination logic runs and **can** select a dangling id as
anchor — confirmed by direct construction. The guard remains harmless for an unrelated reason:
`.positionMatingUnitForest()`'s own root-finding (`mergeSubtrees(rootResults)` on an empty
`rootIds`, since a dangling-anchored unit is unreachable from any real root id or `childEdges$to`
target, `:527-533`) already crashes for any pedigree shaped this way, for reasons entirely
unconnected to anchor selection or this fix's 3 edits — confirmed byte-identical on unpatched
`master` via `git stash`. So Edit 3's guard is defensive against a case the pipeline cannot
currently reach intact regardless, not a proof that the case is impossible — included for
symmetry with the #143 fix's own (live, load-bearing) `realFreePassIds` guard. This
both-parents-dangling crash is itself a genuine, pre-existing, unrelated bug — see §8.

### 2.2 Why all three edits are required together

Same synchronization discipline the #143 plan established (§2.2 of that plan) and this plan
inherits: Edit 3 without Edit 2 would be worse than the status quo (the node renders at the
corrected row while its contour reservation still claims width at the old row — a new overlap
risk with whatever else occupies the corrected row). Edit 2 without Edit 3 changes contour
bookkeeping with no visible effect (the node still displays at its old row). Edit 1 is a pure
precomputation both 2 and 3 depend on. All three ship in one commit, verified together — matching
this project's own two-edits-together precedent from #143.

---

## 3. Rationale

Chosen over the two other candidates surveyed (full comparison in §5), on this project's own
explicitly-stated design principle from the #143 plan's own Rationale (§3): **the
minimal-blast-radius fix that fully resolves the reported defect.**

- **Fully resolves the literal, filed defect.** 51 -> 0 anchor mismatches on the real fixture,
  0 non-anchor mismatches maintained, matching issue #144's own success criterion exactly — no
  redefinition of "fixed" is required (unlike Candidate C, §5).
- **Zero change to anchor/duplicate identity.** `.buildMatingUnitForest()` — D1/D2, WHO anchors
  WHICH mating unit, and the entire duplicate-node population (128 unchanged) — is untouched,
  confirmed by the full `test_buildMatingUnitForest.R` suite passing unmodified. This avoids the
  substantial, empirically-confirmed redistribution a D2-based fix (Candidate A) forces:
  duplicate-node count -20% (128 -> 103) and multi-anchor individuals rising from 2 to 21 (one,
  `WCPXHD`, to 5-way) — a mathematically forced consequence of *any* complete D2-based fix, not
  an artifact of one specific tie-break choice (see §5), and a genuine product/visual-design
  question this plan does not need to force a decision on.
- **Small, comparably-scoped-to-#143 code change.** ~11 non-comment lines across 3 synchronized
  edits, entirely inside `.positionMatingUnitForest()` — directly disproving the standing
  "materially larger... requires restructuring D3" assumption (§1.3) that was the stated reason
  issue #144 was split off from #143 in the first place. This is the single most important
  finding of this planning session: the anchor's own row-reservation and the recursion into its
  children were already decoupled in the existing code; nothing about "the anchor's row is the
  root every other node hangs off" required them to be coupled.
- **Narrow, well-characterized test-blast-radius.** 11 failed expectations across 6 `test_that`
  blocks in the 3 directly-affected test files (vs. Candidate A's 38 failures across 13 blocks),
  every one directly and exclusively attributable to a hardcoded pre-fix value (a specific gen,
  a specific "51 accepted mismatches" count, or a downstream node-count total) — no test outside
  those 3 files is affected (confirmed via a full >1500-test clean regression read on the patched
  worktree).
- **One honestly-bounded residual, not reachable in either bundled real fixture.** An anchor that
  anchors 2+ mating units at genuinely *different* `unitGen` values is not well-defined under a
  single-node point-patch (see §6) — proven absent from `obfuscated_rhesus_mhc_ped.csv` (all
  multi-anchor individuals' anchored units share one `unitGen`) — a materially smaller and more
  honestly-scoped gap than Candidate A's forced redistribution or Candidate C's complete
  non-resolution of the filed metric.

---

## 4. Impact Analysis

### 4.1 What changes

The three edits at `:480`, `:513`/`:518`, and `:596-600` (new lines, inside
`.positionMatingUnitForest()` only). `gen`/`y` values for exactly the 51 originally-mismatched
anchor occurrences (deliberate, expected). `.positionMatingUnitForest()`'s own node count is
**unchanged at 740** (no node created or destroyed — only `gen` reassigned for already-existing
nodes, exactly like the #143 fix). The `edgeStyle="rectilinear"` pipeline's total node count
**does** change, empirically confirmed (not merely reasoned, matching Learning 470's discipline):
**1,279 -> 1,228** (740 direct-style + 488 D1 sibship-bar waypoints, unaffected by anchor choice,
+ 0 D2 projections, down from 51, since every anchor-mismatch the dogleg existed to compensate
for is now resolved at the source). `edgeStyle="direct"` node count is unaffected (740, both
before and after).

**Important, non-obvious finding to carry into the implementation session:** although the *code*
diff is small and localized, the *rendered* diff is not — 648 of 740 nodes (87.6%) shift
`x`-coordinate as a side effect of the contour-merge's inherent cascading recomputation (a
changed row-occupancy claim anywhere shifts sibling-merge offsets, propagating through the
top-down `assignAbs()` pass to descendants and later siblings). This is **precedented, not a
Candidate-B-specific problem** — the already-shipped #143 fix produces an even larger cascade on
the same fixture (729/740 nodes, 98.5%, confirmed by direct comparison this session). "The code
diff is small" must not be read as "the rendered diagram looks nearly identical" when reviewing
this change.

### 4.2 What does not change

`.buildMatingUnitForest()` in its entirety (D1 unit identification, D2 anchor selection, the
`used`/elimination fallback, duplicate-node creation, D5 direct-child re-parenting) — confirmed
byte-identical and fully passing its own test file. Any individual's own `x`-computation *logic*
(the mechanism, not the resulting values — see the cascade note above) — `ownGen` never reaches
`ownX` or the recursion, confirmed by direct inspection of `finalizeNode()`/`mergeSubtrees()`.
The base 740-node count. Issue #143's own non-anchor fix (0 non-anchor mismatches maintained).
The final de-collision nudge pass (`:614-628`) — still fires generically on whatever `x`/`gen` it
is given, confirmed still catching zero surviving overlaps under this fix.

### 4.3 What might break — evidence-based inventory (grep-based, per this project's own Planning
Session Checklist requirement for any plan touching existing algorithm code)

Full grep inventory of `.buildMatingUnitForest`, `.positionMatingUnitForest`, `preferAnchor`,
`makePedigreeMatingLayout`, `anchorOf`, `matingUnits$anchor`, `matingUnits$nonAnchor` across
`R/`, `tests/`, `vignettes/`, `docs/` was run in full this session (raw output preserved in the
planning workflow's transcript). The single production (non-test, non-internal) call site of
`makePedigreeMatingLayout()` is `R/modPedigree.R:446` — the entire live Shiny Pedigree Diagram tab
depends on it; no code change needed there, only re-verification (§7).

**Tests that hardcode the current (defective) anchor-row value and must be rewritten** (all 6
confirmed by empirical re-run against the patched worktree; every failure traces to exactly one
of these root causes, none reflect a bug in the fix):

| File:lines | What it currently asserts | Why it fails | Fix needed |
|---|---|---|---|
| `test_positionMatingUnitForest.R` "exact x/gen values for the real GA204Z/8LKBV9 loop fixture" (Learning-470-style strong discriminator) | `expectPos("8P17E3", 2.00, 0L)` | `8P17E3` anchors `__union_3`-equivalent unit (`8LKBV9` x `8P17E3`, `unitGen=1`) but her own raw gen is 0 — one of the 51 real mismatches, embedded in this smaller fixture | Update to `expectPos("8P17E3", 2.00, 1L)` — her `x` (2.00) is unaffected, only `gen` moves 0->1 |
| `test_positionMatingUnitForest.R` "gen column matches each occurrence's CORRECTED source of truth" | `pos$gen[pos$id == "8P17E3"]` expected `0L` | Same root cause/node, different assertion | Update to `1L`; update the docstring's current claim that anchors "keep their own `ped$gen`, untouched by the fix" |
| `test_positionMatingUnitForest.R:436-474` "resolves every NON-ANCHOR mismatch...leaving exactly the 51 ANCHOR-side mismatches" (issue #144's own regression guard) | `sum(...&isAnchor)` expected `51L` | This IS issue #144's headline result | Update to `0L`; retitle to "issue #144 — RESOLVED" |
| `test_addRectilinearWaypoints.R:311-365` "adds exactly one projection node on the ANCHOR side when the anchor is at a different gen" | Synthetic SIRE/DAM fixture engineered so SIRE anchors off-row | SIRE is now correctly on-row (no mismatch); no projection node is created, the dogleg edges don't exist | **Full rewrite needed**, not a value tweak — the fixture's entire premise (this unit exhibits an anchor mismatch) is obsolete under this fix |
| `test_addRectilinearWaypoints.R:373-398` full real fixture node count | `nrow(result$nodes)` expected `1279L` | 51 D2 projections eliminated | Update to `1228L` |
| `test_makePedigreeMatingLayout.R` full real fixture, `edgeStyle="rectilinear"` node count | expected `1279L` | Same root cause, verified through the public API entry point | Update to `1228L` |

**Tests confirmed unaffected (hand-verified before running, then confirmed passing unchanged):**
`test_buildMatingUnitForest.R` in full (66/66 — this file exercises only D1/D2 anchor
*selection*, never touched); `test_positionMatingUnitForest.R`'s other 13 blocks, including all
`.expectNoOverlap()` calls (including on the full 375-individual real fixture), the half-sib
convergent-loop test, the wide-fan-out-8-mating-units test, and both dangling-parent tests;
`test_addRectilinearWaypoints.R`'s D1-only tests (sibship-bar construction, anchor-agnostic) and
the "non-anchor parent now on-row" test (its SIRE/DAM pairing already had the higher-gen parent
as anchor by coincidence, unaffected by this fix); `test_makePedigreeMatingLayout.R`'s
anchor-choice-agnostic mate-line-edge test (iterates `forest$matingUnits` generically rather than
hardcoding ids) and the rectilinear-matches-`.addRectilinearWaypoints()`-directly
self-consistency test. `test-e2e-pedigree-module.R`'s "known trio" test is unaffected by
construction — it deliberately captures the union id via regex rather than hardcoding it, and
asserts both parents have an edge into the union regardless of which one anchors.

Full clean regression read beyond the 3 directly-affected files (extra diligence, matching this
project's own "Clean regression read" convention): zero failures/errors anywhere else in >1500
other tests; 10 pre-existing warnings, entirely confined to `test_modMarkerGenetics.R` (unrelated
module, confirmed unreachable from this fix).

### 4.4 Interaction with inbreeding-loop safety and crossing-minimization

**Inbreeding-loop safety**: unaffected by construction, same reasoning as the #143 plan — this
fix changes only the `gen` value attached to already-decided anchor occurrences; it never changes
which ids get recursively expanded vs. treated as leaves (`.buildMatingUnitForest()`'s job,
untouched). The canonical `GA204Z`/`8LKBV9` consanguineous-mating fixture must still be re-run as
a hard gate (§7) — `8LKBV9` (3 distinct mates, one of which is an anchor mismatch in this smaller
fixture too) is exactly the kind of individual this fix directly touches.

**Crossing-minimization / x-placement**: not zero-risk, same caution as #143's own plan — Edit 2
changes *which absolute-gen row* an anchor's contour reserves width at, inside
`mergeSubtrees()`. Empirically confirmed this session: 87.6% of nodes shift `x` as a side effect
(§4.1) — full real-fixture re-verification is mandatory, not optional, matching #143's own
precedent (which showed an even larger cascade).

**Performance**: Edit 1's precompute is a single `O(number of anchors)` pass over data already
fully computed at that point (`matingUnits$anchor`, `unitGenOf`) — immaterial next to the
existing `O(n log n)`-ish recursive contour merge. No new component or module boundary is
introduced (pure intra-function computation inside `.positionMatingUnitForest()`), so no new
circular-dependency risk exists.

---

## 5. Alternatives Considered

| Alternative | Resolves the 51 mismatches | Touches D2 (anchor selection) | Touches D3 contour math | Size | Why rejected / status |
|---|---|---|---|---|---|
| **B. Effective-row threading (adopted)** | Yes, fully (51 -> 0) | No | Minimally (2 call sites + 1 new precompute) | Small | — |
| **A. Gen-aware D2 tie-break** (upstream prevention) | Yes, fully (51 -> 0), and *provably* eliminates the multi-unit-differing-gen edge case as a structural invariant (not just empirically absent) | Yes — required extending gen-awareness into the `used`/elimination branch itself, not just `preferAnchor()`, or the fix is provably incomplete (the elimination branch bypasses `preferAnchor()` entirely for exactly-one-candidate-already-used cases — the same mechanism behind the 9 founder-elimination mismatches in §1.1) | No | Small code diff (1 file, ~67/-32 lines including docs), but **forces a substantial, mathematically-necessary redistribution**: duplicate-node count -20% (128 -> 103), multi-anchor individuals 2 -> 21 (up to 5-way) | Empirically validated and fully working, but rejected for THIS plan on minimal-blast-radius grounds (§3) — not a straw man. Its own author's honest assessment: "any complete D2-based fix — not just this one — would produce essentially this same redistribution," reframing the real choice as "is solving #144 upstream (prevention, D2) an acceptable strategy given this forced redistribution, versus downstream (correction, D3)" — a legitimate product/visual-design question (does a diagram with hub individuals consolidated as single multi-mate anchors read better?) this plan resolves in favor of D3 (Candidate B) precisely because it needs no such judgment call. Preserved here as a live future direction if the owner ever wants full duplicate-node consolidation (adjacent to the #143 plan's own "Candidate 2" structural-unification idea) — not adopted now. |
| **C. Connector/dogleg reframe** (leave anchor rows alone; visually signpost the span instead) | **No** — 51/51 unchanged by design; does not satisfy issue #144's own literal, filed success criterion | No | No | Small, different subsystem (`makePedigreeMatingLayout()`'s edge construction + `.addRectilinearWaypoints()`) | This is exactly "Candidate 3" from the #143 plan's own Alternatives table, re-evaluated fresh for #144 (not inherited). Well-executed and empirically low-risk (fully validated, including a real ~37% rectilinear-style performance regression found and fixed during design) — but its own author's honest conclusion stands: it requires an **explicit, fresh product-level sign-off from the owner** to redefine #144's success criterion as "clearly-signposted intentional span" rather than "row matches unit's row" — not an engineering call this plan can make unilaterally, same reasoning the #143 plan itself used to reject the identical alternative. See §8 for disposition. |

---

## 6. Here Be Dragons

- **The three-edit synchronization (§2.2) is the single highest-risk part of an otherwise small
  fix**, exactly mirroring #143's own dragon #1 — a reviewer who reads only a one-sentence
  description could under-scope this as a one-line change. Edits 1, 2, and 3 must land together.
- **The multi-unit-anchor-at-differing-`unitGen` residual is real, not hypothetical, even though
  it does not occur in either bundled real fixture.** Two purpose-built synthetic fixtures
  (constructed and run during this planning session's Candidate B validation) confirmed: (a) a
  2-unit double-anchor at gens 1 and 4 — the max-rule resolves the deeper unit but *relocates*
  (does not eliminate) the mismatch to the shallower one, net count unchanged; (b) a 3-unit
  double-anchor (2 shallow units already matching + 1 deep outlier) — the max-rule can make that
  one anchor's own mismatch count strictly **worse** (1 -> 2), by un-matching units that were
  already fine. Neither is reachable on `obfuscated_rhesus_mhc_ped.csv` (confirmed: zero anchors
  there anchor multiple units at differing gens — checked across the whole 237-unit forest, not
  just the 51 mismatches) — but the implementation session's RED phase should still assert
  deterministic, non-crashing, non-NA behavior for this shape (§7), not merely leave it
  unexercised. **This plan's own review found the true trigger condition is broader than "an
  anchor anchoring 2+ mating units": the same parent-below-child inversion is also reachable with
  only ONE mating unit, when that anchor also has a D5 direct (one-known-parent) child at a `gen`
  shallower than the anchor's relocated `effGen`** — confirmed by direct construction during
  review (an anchor at own `gen` 1, anchoring a union with `unitGen` 4, with a D5 child at `gen`
  2, renders that child 2 rows above its own relocated parent). Not reachable in either bundled
  real fixture (0 D5 direct-child edges exist at all in `obfuscated_rhesus_mhc_ped.csv`) — same
  "real but not reachable in bundled data" character as the multi-unit case, just a broader
  trigger surface than originally stated. The implementation session's new regression test (§7
  step 1) should cover both shapes, not only the multi-unit one. A full resolution of either
  shape would require node duplication (the #143 plan's own "Candidate 2" structural-unification
  territory) — explicitly out of scope here (§8).
- **The `abs(x1-x2) >= minSep` minimum-separation check is NOT a valid global invariant of this
  algorithm — do not reach for it as a verification pattern here without re-deriving it first**
  (`PROJECT_LEARNINGS.md` Learning 470, directly inherited from the #143 implementation session):
  the recursive contour-merge only guarantees minimum separation between direct siblings sharing
  one merge call, never globally; 300+ close-but-non-identical same-row pairs exist in the real
  fixture under *every* variant, including the fully correct one. Any new geometric/structural
  invariant proposed for this fix's own RED phase must be prototyped against real + synthetic
  data with deliberately-broken variants before being committed as a test — matching the exact
  discipline Learning 470 documents.
- **Existing tests currently assert the defect (or its downstream node counts) as correct
  behavior** (§4.3) — the implementation session must positively confirm each rewritten test
  asserts what SHOULD happen, not merely "whatever the new code produces."
- **The `test_addRectilinearWaypoints.R` anchor-side dogleg test (`:311-365`) needs a genuine
  rewrite, not a value tweak** — its entire fixture premise (this unit exhibits an anchor
  mismatch) becomes obsolete once this fix ships; a mechanical find-replace on its hardcoded
  values would leave a test asserting something that can no longer happen.
- **The rendered-diagram visual diff is much larger than the code diff** (87.6% of nodes shift
  `x`) — see §4.1. Any manual/screenshot-based review of this change should expect this, not
  treat it as a red flag; it is precedented by #143's own (larger) cascade on the same fixture.
- **The multi-unit-differing-gen synthetic fixtures used to validate this residual during
  planning were throwaway scripts in an isolated worktree, not committed tests** — the
  implementation session should decide whether to commit a version of them (§7) rather than
  re-deriving from scratch or, worse, skipping this edge case's verification entirely.

---

## 7. Verification Plan (for the implementation session)

1. **RED**: write/update tests asserting the corrected per-anchor gen semantics — rewrite the 6
   `test_that` blocks catalogued in §4.3 (2 exact-value updates on the `GA204Z`/`8LKBV9` fixture,
   1 headline regression-guard flip from `51L` to `0L`, 1 full rewrite of the anchor-side dogleg
   scenario, 2 node-count updates from `1279L` to `1228L`). Add a new committed regression test
   asserting deterministic, non-crashing, non-NA behavior for a synthetic multi-unit-anchor
   -at-differing-gen fixture (§6) — do not leave this residual unexercised by any committed test.
2. **GREEN**: implement all three edits (§2.1) together, in one commit.
3. **REFACTOR**: as needed; no behavior change expected (3 small, co-located edits — likely none
   needed, matching #143's own precedent, but confirm rather than assume).
4. **Regression-test the defect directly**: re-run/confirm the committed detection method now
   asserts `0L` anchor mismatches (and `0L` non-anchor mismatches, unchanged) on the real fixture.
5. **Re-verify the `GA204Z`/`8LKBV9` inbreeding-loop fixture**: zero overlap, zero non-termination,
   hand-confirm the loop-safety property is unaffected (§4.4).
6. **Full regression suite + `devtools::check()`**: confirm ONLY the 6 catalogued tests (plus any
   new test from step 1) differ from baseline; any other file's result changing signals scope
   leakage. Expect `740` base nodes (unchanged), `1228` rectilinear nodes (down from `1279`).
7. **Live verification (Phase 3E)** — load the real fixture in the running app, both `edgeStyle`
   values, via `shinytest2`/`chromote`: (a) at least 3 of the 51 previously-mismatched anchor
   units (e.g. `__union_68`/`8P17E3`, `__union_176`, `__union_191` — gap 1/3/4 respectively) now
   render on-row; (b) zero diagram-related console errors; (c) the `edgeStyle="rectilinear"`
   dogleg no longer fires for these units (no visible jog where there used to be one); (d) a
   spot-check that issue #143's own already-fixed non-anchor units are still correctly positioned
   (no regression). **Note the expected large visual diff (§4.1)** when comparing before/after
   screenshots — this is not itself evidence of a bug.
8. **Error contract**: `effGenOf`/`anchorUnitsOf` are never `NA`/missing for any id the fix
   indexes by construction (every anchor is, by `.buildMatingUnitForest()`'s own guard, a real,
   non-dangling id) — the `intersect(names(anchorUnitsOf), realIds)` guard in Edit 3 is
   defensive, not a live failure path; confirm this remains true rather than assuming it.
9. **Rollback**: all three edits ship in a single atomic commit (code + rewritten tests
   together), matching #143's own precedent. Pure computation, no persisted state or migration —
   rollback is a plain `git revert`.

**What DONE looks like**: the regression test from step 4 passes (`0L` anchor mismatches, `0L`
non-anchor mismatches); the new multi-unit-differing-gen residual test (step 1) passes
deterministically; full suite + `devtools::check()` at exact pre-existing baseline elsewhere; live
verification confirms previously-mismatched units now render on-row under both `edgeStyle`
values, with the dogleg correctly no longer firing for them. This is scoped as **one
implementation session** (not a multi-phase slice) — the code change is three small, co-located
edits; the size is in verification breadth, not layer count, exactly matching #143's own
precedent.

---

## 8. Explicitly Out of Scope (report, don't fix here — `PROJECT_LEARNINGS.md` Learning 382)

- **Candidate A (gen-aware D2 tie-break / upstream prevention)** — fully validated, working, and
  preserved as a legitimate future direction (§5) if the owner ever wants full duplicate-node
  consolidation (hub individuals rendered as single multi-mate anchors rather than spread across
  several duplicate nodes). Not adopted now — the forced 128->103 duplicate-count / 2->21
  multi-anchor redistribution is a genuine product/visual-design trade-off this plan does not
  need to force a decision on, given Candidate B fully resolves the filed defect without it.
- **Candidate C (connector/dogleg visual reframe)** — fully validated, working, and low-risk, but
  requires its own fresh owner product-level sign-off to be considered a "fix" for #144's literal
  criterion (§5). Independently valuable as a diagram-readability enhancement (extends the
  existing dogleg mechanism to `edgeStyle="direct"`, which currently gets zero compensating
  treatment for ANY cross-generation connector) — worth a future session/owner decision on
  whether to pursue on its own merits, decoupled from #144's resolution. File as its own new
  low-priority `BACKLOG.md` enhancement item at this plan's close-out, referencing this section.
- **A genuine, pre-existing, unrelated bug found incidentally by Candidate C's design work**:
  `.addRectilinearWaypoints()`'s existing D2 loop (`genOf[[A]]`/`genOf[[Nnode]]` double-bracket
  indexing) throws `"subscript out of bounds"` when a mating unit's non-anchor parent is a
  dangling, never-duplicated reference, under `edgeStyle="rectilinear"` — confirmed reproducible
  identically on unpatched `master` (via `git stash`), so entirely independent of any candidate
  in this plan. Not fixed here, per Learning 382's "report, don't fix mid-session" precedent —
  file as its own new `BACKLOG.md`/GitHub issue item at this plan's close-out.
- **Two more pre-existing, unrelated bugs found incidentally by this plan's own adversarial
  review**, same family as the one above (dangling-parent edge cases in code this plan does not
  touch — D1/D2 anchor selection and D4 root-finding — confirmed byte-identical on unpatched
  `master` via `git stash` in both cases, not introduced or worsened by any of the 3 edits): (a)
  any individual with `ped$gen = NA` anywhere in the input crashes `maxGen <- max(ped$gen, ...)`
  (`:410`) with `"invalid 'times' argument"` from the downstream `rep(Inf, maxGen + 1L)`; (b) a
  mating unit whose sire AND dam are both dangling (no own row in `ped`) can have a dangling id
  selected as anchor (see §2.1's corrected Edit 3 discussion) and then crashes
  `mergeSubtrees(rootResults)` on an empty `rootIds` (`:527-533`) — and separately,
  `matingUnits$gen` itself comes back `NA` (not the intended `0L` fallback) for such a unit,
  since `pmax(NA, NA, na.rm = TRUE)` returns `NA` rather than the `-Inf` the existing
  `unitGen[is.infinite(unitGen)] <- 0L` guard (`:253`) assumes will fire. Not fixed here, same
  Learning 382 precedent — file both as new `BACKLOG.md`/GitHub issue items at this plan's
  close-out, alongside the item above.
- **`docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`'s worked examples become
  further stale once this fix ships, compounding on top of #143's own already-noted staleness.**
  The #143 plan's own §8 flagged this same document's worked examples as stale from #143's
  row-value changes and directed filing a `BACKLOG.md` housekeeping item at that plan's
  close-out — checking at this plan's own close-out found that item was **never actually
  filed** (only the original DONE item that cites this `.qmd` as the discovery source exists in
  `BACKLOG.md`, not a distinct staleness-tracking item). File one `BACKLOG.md` item now covering
  both #143's and #144's compounding effect on this document, rather than two separate ones.
  `vignettes/a2interactive.Rmd`'s runnable example needs the same re-verification-not-rewrite
  check #143's own plan gave it (confirm it still executes; not a content rewrite) — fold into
  the same housekeeping item.
- **The multi-unit-anchor-at-differing-`unitGen` residual's full resolution** (§6) — bounded,
  well-documented, not reachable in either bundled real fixture; a full fix would need node
  duplication (Candidate 2/A territory), out of scope for this point-patch by design. The
  implementation session should add a *regression* test asserting deterministic behavior (§7 step
  1), not a *fix*.
- **Re-deriving Candidate A's or Candidate C's own throwaway synthetic validation fixtures as
  committed tests** — neither candidate was adopted; their empirical validation work lives only
  in this planning session's workflow transcript, not in the repository. No action needed unless
  a future session revisits Candidate A or C directly.

---

## References

- `docs/audits/FOUNDER_POSITIONING_DEFECT_AUDIT_2026-08-03.md` (S470) — the original defect
  characterization, later split into #143 (non-anchor) and #144 (anchor).
- `docs/planning/issue143-founder-positioning-fix-plan.md` (S471, RATIFIED and shipped as
  commit `904d74b7`, S472) — the sibling non-anchor fix this plan's adopted Decision directly
  mirrors in structure (the `dispGenOf`-override pattern), and whose own §5/§8 first named
  "Candidate 2" (structural unification) and "Candidate 3" (connector reframe) as directions
  this plan re-evaluates fresh as Candidates A and C respectively.
- `docs/planning/pedigree-diagram-option2-layout-design-plan.md` (S458, RATIFIED) — the D1-D6
  mechanism this fix operates inside without modifying D1/D2.
- `PROJECT_LEARNINGS.md` Learning 470 — the minimum-separation-check-is-not-a-global-invariant
  lesson, directly inherited as this plan's own §6 dragon.
- GitHub issue [#144](https://github.com/rmsharp/nprcgenekeepr/issues/144), spun out of
  [#143](https://github.com/rmsharp/nprcgenekeepr/issues/143).
