# Issue #143 Plan — Founder-positioning defect fix (non-anchor occurrence row assignment)

**Tracks:** GitHub issue **[#143](https://github.com/rmsharp/nprcgenekeepr/issues/143)** (filed
S470, 2026-08-03, from `docs/audits/FOUNDER_POSITIONING_DEFECT_AUDIT_2026-08-03.md`).

**Authored:** Session 471 (2026-08-03), **planning session**, following
`docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` (chosen over `DESIGN_WORKSTREAM.md`,
matching this project's own precedent for pedigree-diagram positioning work — S432's issue #129
plan and S458's Option 2 layout plan both made the same call for the same reason: this is a
technical/algorithm-correctness call, not a panel-arrangement call). TDD phases (RED/GREEN/
REFACTOR) are inapplicable to this document — it is a plan, per this project's own S423/S426/
S428/S430/S432 precedent. **The implementation below is its own separate session** (RED -> GREEN
-> REFACTOR), not this one.

**Status:** DRAFT — pending owner ratification. Revised twice:

1. After an in-session adversarial review (3 independent agents: mechanism-fidelity check against
   live source, an empirical gap-check that reproduced a real crash by applying the proposed patch
   to a scratch copy and running it against existing tests, and an `ARCHITECTURE_WORKSTREAM.md`
   checklist/anti-pattern compliance score) found a correctness bug in the originally-proposed
   Edit 2 (dangling free-pass parents) — corrected in §2.1/§2.2/§6/§7.
2. After this session's own direct empirical verification of the corrected patch (applying it to a
   scratch package copy and running it against the real fixture and full test files, not just
   reasoning about it) found the review's own "anchor-side mismatches are theoretical/unobserved"
   claim was **itself wrong** — anchor-side mismatches are real and substantial (51 of 237 real
   mating units, 22%), not a zero-prevalence edge case. This was reconciled against the S470
   audit's own reported numbers (§1.4) and confirmed to the exact integer: the audit's own
   detection script could not distinguish an anchor's mismatched real-id node from a free-pass
   individual's mismatched real-id node (both lack the `__dup_` prefix duplicate nodes carry), so
   its `onFreePassLeaf=90` figure silently combines 39 genuine free-pass mismatches with 51 anchor
   mismatches. Owner reviewed this finding via `AskUserQuestion` and directed: ship the non-anchor
   fix as originally scoped, with the anchor-side gap flagged as a confirmed, substantial,
   near-term follow-up rather than a theoretical residual — reflected throughout §3/§4/§6/§8 below.

---

## 1. Context

### 1.1 Problem statement

`R/makePedigreeDiagramData.R`'s `.buildMatingUnitForest()` / `.positionMatingUnitForest()` render
each individual who mates more than once as multiple node **occurrences** in the Diagram tab: one
"anchor" occurrence (their true recursively-positioned node) plus, for every other mating unit
they're a parent in, either a **duplicate node** (`__dup_*`, if they anchor elsewhere too) or a
**free-pass** reuse of their own real node (if they never anchor anywhere) — this is the ratified
D1/D6 mechanism (`docs/planning/pedigree-diagram-option2-layout-design-plan.md`, S458).

Every **non-anchor** occurrence — free-pass or duplicate — is currently assigned its rendered row
(`gen`, and therefore `y`) from the underlying *individual's own global tree-native `gen`*
(`findGeneration()`'s output for that person), not from the *specific mating unit that occurrence
represents*. When a mating unit's own generation (`max(sire's gen, dam's gen)`) differs from that
individual's personal `gen` — which happens routinely, since mates are not required to share an
ancestry depth (age gaps, a founder marrying into a later generation) — the occurrence renders at
the wrong row, visually implying the wrong pairing.

`docs/audits/FOUNDER_POSITIONING_DEFECT_AUDIT_2026-08-03.md` (S470) confirmed this against real
bundled fixtures: **147 of 237 mating units (62%) on the real 375-individual rhesus fixture
(`obfuscated_rhesus_mhc_ped.csv`) have at least one mis-positioned parent** — 90 on free-pass real
nodes, 57 on genuine duplicate nodes (i.e. the defect affects both mechanisms, not just founders).
The general rule, confirmed by an independent blind re-derivation in that audit: **a parent
occurrence mismatches iff that parent's own `gen` != its mating unit's `gen`**, with zero
exceptions across 474 parent-occurrences checked.

### 1.2 Constraints

- **Must not regress the ratified D1–D6 mechanism** (`pedigree-diagram-option2-layout-design-plan.md`
  §3) — the mating-unit/duplicate-node transformation, anchor selection, and inbreeding-loop
  safety (which is a direct consequence of D1 step 5, "every individual is anchor at most once")
  are all out of scope and must remain byte-for-byte behaviorally unchanged.
- **Must not reopen D2/D4's row-order-sensitive determinism** — anchor tie-breaking and founder
  ordering are both explicitly sensitive to input row order (already a documented dragon, §9 of
  the Option 2 plan); this fix touches neither.
- **Must fix BOTH the free-pass case and the duplicate-node case** — the audit's Finding #2 is
  explicit that a fix touching only the duplicate-creation trigger, without also fixing the
  underlying row formula, would still leave 57 duplicate-node instances broken.
- **MIT-licensed project** — no GPL dependency may be introduced (a standing constraint from the
  original D2 rendering-technology decision; not directly implicated here since this fix touches
  only this package's own R code, but restated because every prior document in this chain
  restates it).

### 1.3 Current state — verified directly, not from the audit's summary

Read `.buildMatingUnitForest()` (`R/makePedigreeDiagramData.R:134-318`) and
`.positionMatingUnitForest()` (`:373-614`) in full this session (not merely re-cited from the
audit). Confirmed line-for-line:

- A mating unit's own `gen` is `pmax(sire's own gen, dam's own gen)` (`:251-253`), stored in
  `matingUnits$gen` and re-keyed into `unitGenOf` (`:409`) — **already computed and already in
  scope** at every point relevant to this fix; no new data is needed.
- **Both defect call sites are in `.positionMatingUnitForest()`:**
  1. `positionUnit()`'s free-pass leaf-contour reservation, `:494`:
     `leafContour(genOf[[sid]])` — uses the person's own global gen, when `unitGenOf[[unitId]]`
     is already available (see below).
  2. The final `nodes` constructor, `:585-591`:
     ```r
     gen = c(unname(genOf[realIds]), unname(genOf[duplicates$realId]),
             matingUnits$gen)
     ```
     Both the free-pass term (`genOf[realIds]`, applied uniformly to every real id) and the
     duplicate term (`genOf[duplicates$realId]`, keyed by the *individual*) ignore the
     mating-unit-specific lookups that already exist and are already used correctly three lines
     earlier for **x** (`dupX <- unname(unitProvX[duplicates$matingUnitId]) + minSep * 0.4`, `:562`).
- **The two lookups a fix needs already exist, unused, at exactly this call site:**
  `duplicates$matingUnitId` (built at `:295-297`, already the correct key for duplicate rows) and
  `freePassUnitOf` (built at `:472-479`, maps each free-pass individual's real id to the single
  unit they should render against — never ambiguous, confirmed by construction: it is always
  `setdiff(ownUnits, dupUnits)[1L]` over a non-empty `ownUnits`, so it can return an empty
  character only if `ownUnits` itself were empty, which cannot happen for an id that is a member
  of `freePassIds`, itself derived from `matingUnits$sire`/`dam`).
- **`unitId` (Edit 1's target) is a parameter of the enclosing `positionUnit(unitId)`** (signature
  at `:488`), so it is in scope at `:494` from the function's own argument, not from a nearby
  line; `unitGenOf[[unitId]]` is additionally already read once more inside the same function,
  5 lines later at `:499` (`finalizeNode(mergeSubtrees(subResults), unitGenOf[[unitId]])`),
  confirming the same lookup is already trusted for the union node's own position.
- **Dangling parents (no own row in `ped`) need a guard, not a new mechanism.** `genOf` is
  back-filled for dangling ids at `:401-407` with the gen of the *first* mating unit that
  references them (`matingUnits$gen[matingUnits$sire == x | matingUnits$dam == x][1L]`) — i.e. a
  dangling individual's `genOf[[id]]` is already a mating-unit gen, not an individual tree-native
  one, since `findGeneration()` never produced a value for them in the first place. `freePassIds`
  is **not** guaranteed to be a subset of `realIds`: it derives from
  `neverAnchorIds <- setdiff(unique(c(matingUnits$sire, matingUnits$dam)), everAnchor)` (`:465-466`),
  and `matingUnits$sire`/`dam` can and do contain dangling ids (confirmed live by
  `tests/testthat/test_positionMatingUnitForest.R:272-297`'s `DANGLING_DAM` fixture). This matters
  directly for Edit 2 below (§2.1, §6).
- **`.addRectilinearWaypoints()` already contains a parallel gen-mismatch check** (`:947-976`,
  read in full this session): its D2 mate-line "dogleg" inserts a projection node whenever
  `side$gen != Ugen` for either parent of a unit (`if (identical(side$gen, Ugen)) next`, `:962`).
  This is the edge-routing layer's *visual workaround* for exactly this defect — it reroutes the
  connecting edge but does not move the mispositioned node itself, which is why the audit found
  the defect edge-style-independent. **This resolves only partially once occurrence rows are
  corrected** (§4.3, §8): it stops firing for **non-anchor** mismatches (the cases this fix
  addresses), but keeps firing, unmodified, for **anchor-side** mismatches — a case this fix does
  not touch (see §4.4/§8). Both sub-cases are already independently exercised by existing tests
  (`tests/testthat/test_addRectilinearWaypoints.R:260-300` and `:301-360` respectively); do not
  assume both need the same treatment (corrected in this revision after a review pass found the
  original draft conflated them — see §8).
- **Verified test lock-in of the current (buggy) behavior:** `tests/testthat/test_positionMatingUnitForest.R:236-265`, `.positionMatingUnitForest's gen column matches each node's source of truth`, explicitly asserts `realRows$gen == genOf[realRows$id]` (own global gen) and the equivalent for duplicates — i.e. it currently locks in the defect as correct.

### 1.4 The real, empirically-confirmed split between non-anchor and anchor mismatches

This session independently re-ran a mismatch check against the real `obfuscated_rhesus_mhc_ped.csv`
fixture (raw CSV, matching the audit's own `duplicateNodes=128` figure exactly) to verify the
corrected patch, and in doing so found a discrepancy with the S470 audit's own published numbers
worth reconciling precisely rather than silently accepting either figure:

| Category | This session's count | Audit's reported bucket |
|---|---|---|
| Duplicate-node mismatches | 57 | `onDuplicateNode = 57` (exact match) |
| Genuine free-pass mismatches | 39 | folded into `onFreePassLeaf = 90` |
| **Anchor mismatches** | **51** | **folded into `onFreePassLeaf = 90`** (39 + 51 = 90, exact) |
| Total (union, ≥1 side mismatched per unit) | 147, zero overlap between anchor- and non-anchor-mismatched units | 147 (exact match) |

**Reconciliation:** the audit's own `onFreePassLeaf=90` figure is not "90 free-pass mismatches" —
it is 39 genuine free-pass mismatches **plus** 51 anchor mismatches, indistinguishable in the
audit's own detection method because both are plain real-id nodes carrying no `__dup_` prefix (the
only signal that method used to classify "which kind of node is wrong"). The audit's top-line
"147 of 237 mating units (62%) have at least one mis-positioned parent" is correct and independently
reproduced exactly (union of 51 anchor-mismatched + 96 non-anchor-mismatched units, zero overlap
between the two sets) — but its own Finding #1/#2 narrative, framed entirely in terms of
"non-anchor" occurrences, never actually separated out the anchor component. This is not a defect
in the audit's headline prevalence claim (62% stands, confirmed independently again here); it is a
gap in how that 62% was broken down by cause, discovered only because this session verified the
proposed fix's *coverage* empirically rather than assuming the audit's category labels matched code
reality.

**Consequence for this plan:** Candidate 1 (§2) resolves 96 of the 147 real-fixture mismatches
(57 duplicate + 39 free-pass) — **65%** of the originally-confirmed defect population, not all of
it. The remaining **51 mating units (22% of all 237, 35% of the original 147)** are anchor-side
mismatches this fix does not and structurally cannot address as a point-patch (§4.4). This is a
real, substantial, already-quantified gap, not a theoretical edge case — see §8 for the
owner-directed handling of this finding.

---

## 2. Decision

**Adopt Candidate 1 — point-patch: assign every non-anchor occurrence's row from its own mating
unit's `gen`, using the mating-unit-keyed lookups that already exist**, at exactly the two call
sites identified in §1.3. This is the audit's own Recommendation #1, verified against the real
mechanism rather than accepted on the audit's summary alone.

### 2.1 The two synchronized edits

**Edit 1 — free-pass leaf-contour reservation** (`:494`, inside `positionUnit(unitId)`, where
`unitId` is already a parameter in scope):

```r
# before
leafContour(genOf[[sid]])
# after
leafContour(unitGenOf[[unitId]])
```

**Edit 2 — final displayed row** (`:585-591`), building an override vector before constructing
`nodes`:

```r
dispGenOf <- genOf[realIds]
realFreePassIds <- intersect(freePassIds, realIds)
if (length(realFreePassIds) > 0L) {
  dispGenOf[realFreePassIds] <- unname(unitGenOf[freePassUnitOf[realFreePassIds]])
}

nodes <- data.frame(
  id = c(realIds, duplicates$id, unitIds),
  x = c(unname(realX), dupX, finalUnitX),
  gen = c(unname(dispGenOf), unname(unitGenOf[duplicates$matingUnitId]),
          matingUnits$gen),
  stringsAsFactors = FALSE
)
```

**The `intersect(freePassIds, realIds)` guard is required, not optional (correction from the
adversarial review, §6).** `freePassIds` can contain dangling ids (§1.3) that are not in
`realIds` — `dispGenOf <- genOf[realIds]` is indexed only by `realIds`, and assigning into it by
a name absent from that index does not error in R; it silently **appends** a new named element,
growing `dispGenOf` past `length(realIds)` and misaligning it with `nodes$id`, corrupting `gen`
for unrelated real rows. Confirmed by direct reproduction: applying the unguarded version against
`tests/testthat/test_positionMatingUnitForest.R:272-297`'s existing `DANGLING_DAM` fixture throws
`"arguments imply differing number of rows"`. The guard is safe precisely because dangling ids
don't need the override in the first place — their `genOf[[id]]` is already a mating-unit gen via
the existing `:401-407` fallback (§1.3), not an individual tree-native one.

Anchor occurrences (`positionIndividual()`'s own `genOf[[id]]`, `:518`) are **not** touched —
that is an individual's true tree-native row and is what every other subtree hangs off; changing
it is out of scope and would require restructuring D3's recursive positioning itself, not a
point-patch (see §4.4/§8 for why this leaves a known, separate residual case unaddressed).

### 2.2 Why both edits are required together, and why Edit 2 needs its own guard (§6)

Patching only Edit 2 without Edit 1 is **worse than the status quo**: the contour-merge machinery
would still reserve x-position width at the free-pass leaf's *old* (wrong) row, while the node
itself renders at the *corrected* row with zero width reserved there — a concrete new risk of
overlapping an unrelated node that legitimately occupies that row. The two edits must ship
together, in the same commit, verified together. This subtlety is not visible from the audit's
one-sentence candidate description and was only surfaced by reading the actual recursive-descent
code this session.

Independently, **Edit 2 on its own is incomplete without the `realIds` guard** (§2.1) — an
adversarial review pass on this plan's first draft found the unguarded version crashes on any
pedigree with a dangling free-pass parent, a scenario this codebase already has a dedicated
regression test for. Both requirements (Edit 1+2 synchronization, and Edit 2's own guard) are
restated in §6 as the plan's two highest-risk points.

---

## 3. Rationale

Chosen over the two other candidates surveyed (full evaluation in §5):

- It is the **minimal-blast-radius fix that resolves the non-anchor majority of the confirmed
  defect** — 96 of the S470 audit's 147 real-fixture mismatches (57 duplicate + 39 genuine
  free-pass, §1.4), 65% of the confirmed population. It does **not** satisfy the audit's literal
  framing ("does every parent's row match its own mating unit's row?") in full — **anchor**-side
  mismatches are real and substantial (51 of 237 units, 22%, §1.4), not theoretical, and are not
  fixed here; that is a deliberate, owner-directed scope boundary (§8), reached after this session
  quantified the anchor-side population precisely rather than assuming it was rare. A bugfix
  addressing the majority case now, with the confirmed remainder tracked as an urgent named
  follow-up, was judged preferable to either shipping nothing while a larger combined design is
  built, or expanding this point-patch into a materially riskier restructuring of anchor
  positioning (`ARCHITECTURE_WORKSTREAM.md`'s "astronaut architecture" anti-pattern applies to
  growing one bugfix's scope reactively, not to deferring a distinct, harder problem).
- It **reuses data structures that already exist and are already correctly used for `x`** at the
  same call site — no new bookkeeping, no new traversal, no new column. This is the strongest
  possible evidence the fix is structurally sound: the pattern it needs is already proven correct
  three lines away.
- It leaves the **D1–D6 mechanism, inbreeding-loop safety, and crossing-minimization ordering
  structurally untouched** — the fix changes which *value* a `gen` lookup returns for
  already-decided occurrences, never which ids get recursively expanded, which occurrence becomes
  a duplicate vs. free-pass, or how founders/anchors are ordered.
- It correctly and naturally handles an individual with **more than one non-anchor occurrence at
  different generations** (e.g. 1 free-pass + 2 duplicates): each occurrence is independently keyed
  to its own mating unit via `duplicates$matingUnitId`, so it can legitimately render at 3
  different rows, one per mating unit. This is in fact the *intended* completion of what D6's
  node-duplication mechanism was meant to represent all along, not a new problem introduced by
  this fix.

---

## 4. Impact Analysis

### 4.1 What changes

- `R/makePedigreeDiagramData.R:494` and `:585-591` (the two edits in §2.1).
- `gen`/`y` values for **96 of 237 mating units (40%)** on the real bundled fixture — the
  non-anchor subset of the audit's original 147 (§1.4); this is a deliberate, expected,
  wide-blast-radius *value* change, not a regression signal. The remaining 51 mismatched units
  (anchor-side, §1.4/§4.4) are unchanged by this fix.
- **`.positionMatingUnitForest()`'s own node/edge counts do not change** (this fix reassigns `y`
  for existing nodes; it creates none — `nrow(pos)` stays `740L` on the real fixture, verified in
  §7). **The full `edgeStyle="rectilinear"` pipeline's total node count DOES change**, and this was
  originally missed in this plan's first draft: `.addRectilinearWaypoints()`'s D2 dogleg creates
  one projection node per still-mismatched side, so fewer mismatches after the fix means fewer
  projection nodes. Empirically confirmed by applying the corrected patch to a scratch copy and
  running it against `tests/testthat/test_addRectilinearWaypoints.R`'s real-fixture count assertion
  (`:382`): total nodes drop from **1375 to 1279** (740 direct-style + 488 D1 waypoints + 51
  remaining D2 projections, down from 147 — matching the 51 anchor mismatches exactly, §1.4). The
  `edgeStyle="direct"` pipeline is unaffected (no waypoint nodes exist under that style).

### 4.2 What does not change (explicit scope boundary)

- `.buildMatingUnitForest()` (anchor selection D2, duplicate-creation trigger, D5 partial-parentage
  fallback) — **entirely untouched**. `.positionMatingUnitForest()`'s own node count
  (`nrow(pos) == 740L` on the real fixture) is unaffected — a cheap sanity check that this fix
  stayed in its lane. **`nrow(result$nodes)` for the full `edgeStyle="rectilinear"` pipeline is
  NOT unaffected** — see §4.1's correction (1375 → 1279, empirically confirmed); this is an
  expected consequence of fewer dogleg projections being needed, not a scope violation.
- Anchor occurrences' own rows (`positionIndividual()`'s `genOf[[id]]`, `:518`) — unchanged by
  design (§2.1).
- `x`-coordinate computation for duplicates (`dupX`, `:560-563`) — already correctly keyed by
  `matingUnitId`; untouched.
- The final de-collision nudge pass (`:592-611`) — operates on whatever `gen`/`x` values it's
  given; needs no code change, but its *output* will differ for the 96 affected units (§4.1) since
  its inputs changed.

### 4.3 What might break — evidence-based inventory of affected callers/tests

Grep-based inventory (this session) of every caller of `.buildMatingUnitForest`,
`.positionMatingUnitForest`, `makePedigreeMatingLayout`, and `.addRectilinearWaypoints`:

**Production caller (unaffected in shape, affected in output values):**
- `R/modPedigree.R:446` — the live Shiny server call site via `makePedigreeMatingLayout()`. No
  code change needed here; the rendered diagram's row layout changes for affected fixtures.
- `tests/testthat/test_modPedigree.R:1494,1531` — calls `.buildMatingUnitForest()` directly (for
  union/duplicate id lookups, not position assertions), but more importantly this file is the
  primary regression suite exercising the production call site end-to-end through
  `modPedigreeServer` (dozens of `pedigreeDiagram`/`widgetJson` tests) — the natural place to look
  for live-pipeline no-crash coverage. No `gen`/`x`/`y`-hardcoding assertions found in this file
  (confirmed via targeted grep), so no rewrite expected, but it should be included in every full
  regression run (§7) as the closest thing to an integration test this pipeline has.

**Tests that hardcode/assert the CURRENT (defective) formula as correct — must be rewritten, not
just re-run:**
- `tests/testthat/test_positionMatingUnitForest.R:236-265` — asserts
  `realRows$gen == genOf[realRows$id]` and the duplicate equivalent (own global gen). This
  precisely locks in the defect; must change to assert per-mating-unit gen for non-anchor
  occurrences, own gen for anchors.
- `tests/testthat/test_positionMatingUnitForest.R:132` (`all(kDup$gen == 1L)  # 8LKBV9's own real
  gen`) — a hardcoded duplicate-node gen assertion whose own comment names the current (wrong)
  semantics explicitly; needs hand-verification against `8LKBV9`'s actual mating-unit gens under
  the corrected formula, not a mechanical find-replace.
  **Correction from the adversarial review:** `:87` (`pos$gen[pos$id == "C2"] == 1L`) is **not**
  part of this bucket — `C2` in that fixture has `sire="P", dam=NA`, a D5 one-known-parent direct
  child who is never a sire/dam of any mating unit and is therefore untouched by either edit; the
  original draft of this plan incorrectly grouped it with `:132`.
- `tests/testthat/test_addRectilinearWaypoints.R:260-300` (section `"D2: non-anchor parent
  off-row (the common 96/237 real case)"`) — the mismatched party here is the **non-anchor**
  (free-pass) parent, exactly the case this fix corrects. Once the fix lands, the projection/dogleg
  this test asserts (`expect_equal(projRow$y, unitRow$y)`, `:288`) will no longer trigger for this
  scenario (the parent now renders on-row directly) — this test needs rewriting to construct a
  different residual scenario (if one still exists through the non-anchor path) or removal if none
  does. This is a judgment call for the implementation session, not resolvable from the plan alone.
- `tests/testthat/test_addRectilinearWaypoints.R:301-360` (`"D2: anchor parent off-row,
  non-anchor represented by a duplicate"`) — **correction from the adversarial review: this test's
  mismatched party is the ANCHOR** (its own comment at `:302-303` says so — "the harder combined
  case: exercises both the ... anchor-off-row case"). Anchor rows are explicitly untouched by this
  fix (§2.1): D2's anchor-selection tie-break (`preferAnchor()`) never consults gen, so an anchor's
  own gen can legitimately differ from its unit's `max(sire, dam)` gen (e.g. a sire with fewer
  total matings can anchor over a higher-gen dam). **This test should need NO changes** — its
  dogleg continues to fire exactly as before. A still-passing, unmodified result here is the
  expected, correct outcome, not evidence the fix missed something; the original draft of this
  plan incorrectly grouped this test with the one above and predicted both would need the same
  treatment.

**Tests asserting counts or structural invariants — split by whether they're actually stable:**
- `tests/testthat/test_positionMatingUnitForest.R:228` (`nrow(pos) == 740L`) — **stable**, expected
  unaffected (§4.2), verify by running.
- `tests/testthat/test_makePedigreeMatingLayout.R:338-360` (the `y = gen * yScale` linear-relationship
  test) — the *relationship* should survive; the values feeding it change.
- `tests/testthat/test_makePedigreeMatingLayout.R:396-419` (`edgeStyle="direct"`, `nrow(result$nodes)
  == 740L`) — **stable**, no waypoint nodes exist under this style.
- `tests/testthat/test_makePedigreeMatingLayout.R:481-494` (`edgeStyle="rectilinear"`,
  `nrow(result$nodes) == 1375L`) and `tests/testthat/test_addRectilinearWaypoints.R:367-382`
  (same assertion via the internal helper) — **correction from this session's own empirical
  verification (§4.1, §1.4): these are NOT stable.** Applying the corrected patch to a scratch copy
  and running it against the real fixture drops the count to **1279** (740 + 488 D1 waypoints + 51
  remaining D2 projections, down from 147 — matching the 51 confirmed anchor mismatches exactly).
  Both assertions must be updated to `1279L`, not merely re-run for pass/fail; a naive re-run would
  report a "regression" that is actually the fix working as intended.
- `tests/testthat/test_buildMatingUnitForest.R:296-310,373-382` — `.buildMatingUnitForest()`'s own
  counts (`237L` units, `128L` duplicates); this function is untouched by the fix, so these should
  be exactly unaffected — **stable**, a red flag if they aren't.

**Confirmed unaffected (separate rendering path):**
- `tests/testthat/test_makePedigreeDiagramData.R` — exercises `makePedigreeDiagramData()`, the
  simpler non-mating-unit function, structurally unrelated to this fix.

**No e2e/shinytest2 test references this pipeline by function name** (`grep` across
`tests/testthat/test-e2e-*.R`/`test-app-*.R` returned zero matches) — no live-app test file needs
editing, but Phase 3E live verification (§7) is still required per this project's own runtime
-behavior-change convention.

**Documentation/vignettes describing the current (buggy) layout — flagged, not this fix's scope:**
- `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd` — the defect-discovery
  document itself narrates specific current (wrong) coordinates and node ids as its own worked
  examples; becomes stale/historical once the fix ships. **Out of scope for the implementation
  session** — file as a separate, low-priority housekeeping item (§8) rather than bundling a doc
  rewrite into the bugfix, per this project's own scope-discipline precedent
  (`PROJECT_LEARNINGS.md` Learning 382).
- `vignettes/articles/colony-manager-guide.qmd:310`'s embedded screenshot
  (`pb_diagram_legend.png`) was captured from the current (buggy) rendering — **this is already an
  existing, separate open `BACKLOG.md` item** (found S461, stale-screenshot re-capture), not
  newly created by this plan; note only, no new item needed.
- `vignettes/a2interactive.Rmd:355-441` — describes the *shape* of `makePedigreeMatingLayout()`'s
  return value, not specific gen/row values; needs re-verification that its runnable example
  still executes cleanly, not a content rewrite.

**No detection script exists in the repository to reuse** — the audit's own detection method
(comparing each parent's rendered row against its mating unit's own row) was never committed
(confirmed via `git log --diff-filter=A` on the audit's commit). The implementation session should
re-derive it from the audit's Method section and commit it as a proper regression test this time,
per §7.

### 4.4 Interaction with inbreeding-loop safety and crossing-minimization

- **Inbreeding-loop safety**: unaffected by construction — this fix changes only the `gen` *value*
  attached to already-decided leaf/anchor occurrences; it never changes which ids get recursively
  expanded vs. treated as leaves (that decision is entirely `.buildMatingUnitForest()`'s, untouched).
  The real `GA204Z`/`8LKBV9` consanguineous-mating fixture (`pedigree-diagram-option2-layout-design-plan.md`
  §1.4; also `test_buildMatingUnitForest.R`'s loop test) should still be re-run as a hard gate
  (§7), not because the mechanism is expected to change, but because it is this codebase's
  canonical safety fixture and `8LKBV9` (3 distinct mates) is exactly the kind of multi-occurrence
  individual this fix directly touches.
- **Crossing-minimization / x-placement**: Edit 1 (§2.1) changes *which absolute-gen row* a
  free-pass leaf's contour reserves width at, inside `mergeSubtrees()`. This can shift x-placement
  for **sibling subtrees within the same mating unit's children-merge**, even though the fix's
  stated purpose is purely a `y`/`gen` change — the blast radius is not strictly limited to the
  mismatched node's own row. Full re-verification against the same real fixtures the audit used
  (§7) is required, not optional.
- **Anchor-side mismatches are NOT fixed by this change, and are confirmed real, not theoretical
  (owner-reviewed scope boundary — see §8):** D2's anchor-selection tie-break (`preferAnchor()`,
  `:199-207`) never consults gen — only founder status, then mate count, then id. An anchor's own
  gen can therefore legitimately differ from its unit's `max(sire, dam)` gen (e.g. a sire with
  fewer total matings anchors over a higher-gen dam). Moving an anchor's displayed row would
  require restructuring D3's recursive positioning itself (the anchor's row is the root every other
  node in its own subtree hangs off) — materially larger than this point-patch, closer to
  Candidate 2/3's territory (§5). **This session's own direct empirical re-check found 51 of 237
  real-fixture mating units (22%) have an anchor-side mismatch** (§1.4) — the S470 audit's original
  write-up did not separate this out (its detection method could not distinguish an anchor's
  mismatched real-id node from a free-pass individual's, §1.4), so the audit read as if this case
  were absent; it is not. The owner reviewed this finding directly (via `AskUserQuestion`, this
  session) and directed shipping the non-anchor fix now with the anchor gap tracked as a named,
  urgent follow-up (§8) rather than expanding this plan's scope to cover both.

---

## 5. Alternatives Considered

| Alternative | Fixes free-pass | Fixes duplicate | Touches D3 contour math | Touches D6 decision logic | Size | Why rejected |
|---|---|---|---|---|---|---|
| **1. Point-patch (adopted)** | Yes | Yes | Minimally (2 call sites) | No | Small | — |
| **2. Structural unification** — fold duplicate nodes into the same recursive descent as free-pass leaves, replacing the post-hoc `dupX` offset with real contour-based collision protection | Yes | Yes, plus closes an adjacent pre-existing duplicate-collision gap | Substantially | Yes (mechanism, not the anchor/duplicate decision itself) | Large | Exceeds what the audit actually asked for; would need its own explicit owner scope decision rather than riding in as a bugfix; materially higher regression risk on a mechanism with several already-documented "found live" edge cases (dangling parents, the double-anchor collision, S461 fixes) for a correctness gain the audit did not report as broken. A legitimate future enhancement, not a rejection of its merits — just out of THIS fix's scope. |
| **3. Reframe: leave positions alone, redesign the connector edge to explicitly span generations** — extend the rectilinear dogleg into a clearly-drawn "this mate-line spans N generations" visual instead of relocating nodes | Reframes, doesn't eliminate the mismatch | Reframes, doesn't eliminate | Zero | Zero | Large, different subsystem | Does not satisfy the audit's own literal success criterion (does the parent's row match its unit's row?) — every occurrence still renders at exactly one row (its own global gen), never its unit's. This is the *current* dogleg mechanism's own behavior, formalized rather than fixed; it needs an explicit product-level sign-off from the owner that a multi-generation-spanning connector is an acceptable redesign, not an engineering call this plan can make. |

Candidate 2 in particular is not a straw man — it is arguably a *better* long-term mechanism (it
also closes the duplicate-node collision-avoidance gap the D3 docstring already flags,
`R/makePedigreeDiagramData.R:352-361`, as "not always successfully collapsed"). It is rejected here
purely on scope grounds: this plan's job is to fix issue #143 as reported, not to redesign D6.

---

## 6. Here Be Dragons

- **The two-edit synchronization (§2.2) is the single highest-risk part of an otherwise small
  fix.** A reviewer or implementer who reads only the audit's one-sentence "assign every
  non-anchor occurrence's row from its own mating unit's gen" candidate could reasonably
  under-scope this as a one-line change. It is not — Edit 1 and Edit 2 must land together.
- **Edit 2 needs its own `realIds` guard (§2.1, §2.2) — this is not optional polish.** An
  adversarial review of this plan's first draft applied the unguarded version to a scratch copy
  of the source and ran it against this codebase's own existing `DANGLING_DAM` fixture
  (`tests/testthat/test_positionMatingUnitForest.R:272-297`), reproducing a confirmed crash
  (`"arguments imply differing number of rows"`). The implementation session's RED phase must
  include this exact fixture (or an equivalent dangling-free-pass-parent case) as one of its
  tests, not just the corrected-gen-value assertions.
- **The RED-phase overlap check must assert a MINIMUM SEPARATION, not mere non-identity.** The
  existing helper `.expectNoOverlap()` (`tests/testthat/test_positionMatingUnitForest.R:25-29`)
  only flags exact `(x, gen)` coincidence (rounded to 6 decimals) — it would **not** catch the
  Edit-2-only partial-fix failure mode described above (a contour-width miscalculation shifting a
  neighbor by less than `minSep`, not necessarily to an identical `x`). A new test reusing this
  existing helper's pattern would very plausibly pass on a broken partial fix, defeating its own
  purpose; the new test must explicitly assert `abs(x1 - x2) >= minSep` (`minSep <- 1L`, `:415`)
  among same-row nodes, not just non-identity.
- **Existing tests currently assert the defect as correct behavior** (§4.3). The implementation
  session must positively confirm each rewritten test asserts what SHOULD happen, not merely
  "whatever the new code produces" — a test rewritten by pattern-matching the new formula without
  independently reasoning about the expected value would silently re-encode a different bug.
- **`.addRectilinearWaypoints()`'s two D2 dogleg test sections have DIFFERENT fates — do not
  treat them identically** (§4.3, corrected from this plan's first draft): `:260-300`'s non-anchor
  scenario needs rewriting or removal; `:301-360`'s anchor-side scenario needs no change at all,
  since anchor rows are untouched by this fix. Misjudging which is which risks either leaving a
  now-obsolete test silently green for the wrong reason, or unnecessarily rewriting a test that
  was never broken.
- **Anchor-side mismatches are a real, substantial (51 of 237 units, 22%), confirmed-not-theoretical,
  owner-reviewed out-of-scope case** (§1.4, §4.4, §8) — this fix resolves 65% of the audit's
  originally-confirmed 147 mismatches, not all of them; do not describe this fix as "closing" the
  audit's finding without that qualifier.
- **The `edgeStyle="rectilinear"` real-fixture node-count assertions will change (1375 → 1279), not
  stay stable** (§4.1, §4.3) — this plan's own first empirical check (not just reasoning) caught
  this after an earlier draft assumed node counts were unaffected; treat any node-count assertion
  in this pipeline as something to re-derive, not assume, until actually run.
- **Crossing-minimization interaction (§4.4) is not zero-risk** despite this being nominally a
  "row assignment" fix — full real-fixture re-verification is mandatory, not a formality.

---

## 7. Verification Plan (for the implementation session)

1. **RED**: write/update tests asserting the corrected per-mating-unit gen semantics for both
   free-pass and duplicate occurrences (replacing `test_positionMatingUnitForest.R:236-265` and the
   hardcoded duplicate-node assertion at `:132`; `:87` is unaffected, §4.3), including:
   - a dangling-free-pass-parent case (reusing or extending `DANGLING_DAM`,
     `test_positionMatingUnitForest.R:272-297`) that would fail against an unguarded Edit 2 (§6);
   - a same-row **minimum-separation** check (`abs(x1 - x2) >= minSep`, not mere non-identity — the
     existing `.expectNoOverlap()` helper is insufficient for this purpose, §6) that would fail
     under an Edit-1-only or Edit-2-only partial fix.
2. **GREEN**: implement both edits, with Edit 2's `realIds` guard (§2.1), together, in one commit.
3. **REFACTOR**: as needed; no behavior change.
4. **Regression-test the defect directly**: re-derive the audit's own detection method, refined to
   separate anchor from non-anchor (§1.4 — the original audit's own method could not), as a
   committed test against the real `obfuscated_rhesus_mhc_ped.csv` fixture, asserting **zero
   non-anchor mismatches AND exactly 51 anchor mismatches** post-fix (this both closes the
   "detection script was never committed" gap found in §4.3 and gives this fix a durable regression
   guard — including a guard that the *known, accepted* anchor gap doesn't silently grow or shrink
   for an unrelated reason). If the anchor count differs from 51, treat that as a signal worth
   investigating, not noise.
5. **Re-run and hand-verify** (not just re-run for pass/fail) `test_addRectilinearWaypoints.R`'s
   two D2 sections against the corrected mechanism — expect `:260-300` to need rewriting/removal
   and `:301-360` to need no change (§4.3, §6); confirm this expectation before treating either
   outcome as correct. Update the real-fixture node-count assertions (`:382` and
   `test_makePedigreeMatingLayout.R:494`) from `1375L` to `1279L` (§4.1, §4.3) — empirically
   confirmed this session, not a prediction.
6. **Re-verify the inbreeding-loop fixture** (`GA204Z`/`8LKBV9`) still positions with zero overlap
   and zero non-termination.
7. **Full regression suite + `devtools::check()`** — confirm the ONLY differences from baseline are
   the intentionally-updated tests in steps 1/5; any other file's test result changing is a signal
   the fix leaked outside its stated scope (§4.2).
8. **Live verification (Phase 3E)** — load the real 375-individual fixture in the running app,
   both `edgeStyle` values, confirm via `shinytest2`/`chromote`: (a) `FD3BB6`'s mating unit (the
   audit's manually-spot-checked example, a genuine free-pass case fixed by this patch) now renders
   at the correct row; (b) zero diagram-related console errors; (c) a small hand-picked sample of
   the other 95 now-fixed non-anchor mating units also correctly repositioned; (d) spot-check one
   of the 51 still-broken anchor-side units to confirm it renders exactly as before (unchanged, not
   worse) — the fix must not accidentally perturb the cases it isn't supposed to touch.

**Error contract.** `unitGenOf`/`freePassUnitOf`/`duplicates$matingUnitId` are never `NA` or
missing for any id the fix indexes them with, by construction (§1.3): `freePassUnitOf` is always
`setdiff(ownUnits, dupUnits)[1L]` over a non-empty set for any id in `freePassIds`, and
`duplicates$matingUnitId` is populated for every row of `duplicates` at creation time
(`:262-297`). The one real failure path — a dangling free-pass id present in `dispGenOf`'s index
but absent from `realIds` — is what the `realIds` guard (§2.1) exists to prevent; no other NA/
missing-key path was found.

**Rollback strategy.** Both edits ship in a single, atomic commit (code + rewritten tests
together); this is pure computation with no persisted state or data migration, so rollback is a
plain `git revert` of that one commit — no partial-rollback or multi-step unwind is needed.

**What DONE looks like for the implementation session:** the regression test from step 4 passes
(zero non-anchor mismatches, exactly 51 confirmed-and-accepted anchor mismatches remaining on the
real fixture); full suite + `devtools::check()` at exact pre-existing baseline elsewhere; live
verification confirms the specific audited example is visually corrected AND that an anchor-side
case is unchanged. This resolves 96 of the audit's 147 originally-confirmed real-fixture
mismatches (65%) — not all of them; the remaining 51 (22% of all mating units) are the owner
-directed follow-up in §8, not a defect in this session's own completion. This is scoped as **one
implementation session** (not a multi-phase slice) — the code change itself is two small,
co-located edits; the size is in verification breadth, not layer count.

---

## 8. Explicitly Out of Scope (report, don't fix here — `PROJECT_LEARNINGS.md` Learning 382)

- Rewriting `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`'s now-stale worked
  examples (§4.3) — file as its own low-priority `BACKLOG.md` housekeeping item at this plan's
  close-out.
- Regenerating `pb_diagram_legend.png` — already tracked (found S461); no new item needed.
- Candidate 2's structural unification (§5) — a legitimate future enhancement to D6's duplicate
  collision-avoidance, not part of this fix.
- Candidate 3's connector-redesign reframing (§5) — would need an explicit owner product decision,
  not an engineering call.
- **Ancillary structural gap found while reading the code this session, unrelated to the row-mismatch
  question**: `.positionMatingUnitForest()`'s free-pass filter (`freePassIds`, requires
  `!hasOwnDirectChild(id)`, `:467-471`) is *stricter* than `.buildMatingUnitForest()`'s free-vs-duplicate
  decision (which only looks at anchor status, not D5 direct-child ownership, `:262-297`). An
  individual who never anchors, whose first occurrence was marked free by `.buildMatingUnitForest()`,
  but who also owns a D5 direct child, would be excluded from `freePassIds` and — if not a root —
  never positioned at all by the recursive descent. This is a separate, likely-rare structural
  inconsistency between the two functions' free-pass criteria, outside this fix's own scope; file
  as its own new `BACKLOG.md` item at close-out.
- **Anchor-side row mismatches — CONFIRMED REAL AND SUBSTANTIAL, owner-directed urgent follow-up,
  not a low-priority residual (§1.4, §4.4, §6).** An anchor's own gen can legitimately differ from
  its mating unit's `max(sire, dam)` gen, since D2's anchor-selection tie-break never consults gen.
  This fix, by design, does not move anchor rows (doing so would require restructuring D3's
  recursive positioning itself, since the anchor's row is what every other node in its subtree
  hangs off — closer to Candidate 2/3's scope than a point-patch). **This session's own direct
  empirical check found 51 of 237 real-fixture mating units (22%) have an anchor-side mismatch** —
  the S470 audit's write-up did not distinguish this from free-pass mismatches (its detection
  method had no way to tell an anchor's mismatched real-id node apart from a free-pass
  individual's, §1.4), so it read as absent when it is not.
  `test_addRectilinearWaypoints.R:301-360` already exercises the dogleg's continued visual
  compensation for this case (unchanged by this fix). **Owner directed (via `AskUserQuestion`,
  this session): ship this fix now; treat the anchor-side gap as its own, near-term follow-up
  plan-mode session — not deferred indefinitely as a low-priority housekeeping item like the other
  bullets in this section.** File as its own new GitHub issue at close-out (mirroring how #143
  itself was filed after S470's audit), referencing this plan's §1.4 numbers directly rather than
  re-deriving them from scratch.

---

## References

- `docs/audits/FOUNDER_POSITIONING_DEFECT_AUDIT_2026-08-03.md` (S470) — the defect characterization
  this plan designs a fix for.
- `docs/planning/pedigree-diagram-option2-layout-design-plan.md` (S458, RATIFIED) — the D1–D6
  mechanism this fix operates inside without modifying.
- `docs/planning/pedigree-diagram-mating-lines-plan.md` (S457) — feasibility predecessor.
- `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd` (S463) — where the defect was
  first observed.
- GitHub issue [#143](https://github.com/rmsharp/nprcgenekeepr/issues/143).
