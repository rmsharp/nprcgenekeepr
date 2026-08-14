# Pedigree Diagram Track 4: gen-aware anchor selection (generation-row alignment)

**Status:** RATIFIED 2026-08-14 -- proceed to implementation as written. See §9.
**Session:** S572 (2026-08-14). **Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`
(chosen over `DESIGN_WORKSTREAM.md`, matching this project's own established precedent for
pedigree-diagram positioning work -- S432's issue #129 plan, S458's Option 2 layout plan, S464's
rectilinear-waypoint plan, and S471/S473's issue #143/#144 plans all made the same call for the
same reason: this is a technical/algorithm-correctness decision, not a panel-arrangement one).
**Origin:** Track 4 of `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md`
§4 -- "the architecturally significant item," explicitly flagged there as needing its own
dedicated design session before any RED/GREEN work. TDD phases (RED/GREEN/REFACTOR) are
inapplicable to this document -- it is a plan, per this project's own established precedent.
**The implementation is its own separate future session** (RED -> GREEN -> REFACTOR), not this one.
**Touches (for the future implementation session):** `R/makePedigreeDiagramData.R`'s
`.buildMatingUnitForest()` (`:347-546`, D1/D2 anchor selection) and `.positionMatingUnitForest()`
(`:610-1056`, specifically the `effGenOf`/`dispGenOf` mechanism issue #144 added). Does **not**
touch `findGeneration()`, `makePedigreeDiagramData()`, or any Diagram-tab UI/render-chain code.

---

## 1. Context

### 1.1 What is already decided (do not re-litigate)

- D1-D6 of the mating-unit-forest transformation and contour-merge positioning algorithm
  (`docs/planning/pedigree-diagram-option2-layout-design-plan.md`) are ratified and shipped; this
  plan does not propose replacing them.
- Track 1 (default unaffected fill) and Track 3 (minimum mate-spacing sweep) are DONE (S570,
  S571) and orthogonal to this decision: Track 1 touches color assignment only; Track 3's
  `sweepMinSep()` operates on final `x` positions within a display row, not on which row (`gen`)
  a node occupies -- no interaction expected, re-verified as a Phase 2/implementation-session
  concern (§6).
- **D2's gen-blindness is explicitly NOT a protected, load-bearing property of the ratified
  Option 2 design.** `docs/planning/issue144-anchor-row-mismatch-fix-plan.md` §1.2(d) already
  established this precisely: the Option 2 plan ratifies D2 only at the level of "a fixed,
  deterministic, non-search-based tie-break exists and is applied consistently pre-recursion" --
  it does not state or imply gen-blindness is itself protected. D2's implementation has already
  evolved once post-ratification (the `KUENM8`/`IM1B5T` double-anchor fallback, added as a
  correctness fix, not treated as a plan amendment). Revisiting D2's tie-break criteria for this
  decision does not reopen the ratified Option 2 document.
- Issue #143 (non-anchor row correction) and issue #144 (anchor row correction via `effGenOf`)
  are both closed and shipped. This plan does not relitigate their own adopted decisions -- it
  resolves the residual their own planning sessions explicitly predicted, characterized, and
  deliberately left open (§1.3 below).

### 1.2 What this document decides

One question: **when a mating unit's two candidate parents have different `gen` values (an
ordinary, common real-world pattern -- confirmed at 62% of real-fixture mating units,
`docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md` §2.4a), which parent
becomes the mating unit's *anchor*, and does the anchor's own displayed row need any further
adjustment once selected?** This is D2 (anchor-selection tie-break) plus the `effGenOf` mechanism
issue #144 layered on top of it.

### 1.3 Full history: how the current defect arose

1. **Issue #143** (shipped, commit `904d74b7`): a *non-anchor* occurrence (free-pass or
   duplicate) now renders at its own mating unit's `gen`, not the underlying individual's global
   `ped$gen`. Deliberately left the anchor side untouched.
2. **Issue #144** (shipped): characterized the anchor-side sibling defect -- 51 of 237
   real-fixture mating units (22%) have an anchor whose own raw `gen` differs from its unit's
   `gen`, because `preferAnchor()` (`R/makePedigreeDiagramData.R:412-420`, current numbering)
   never consults `gen`, only founder status, then mate count, then id. Three candidates were
   designed and empirically validated in that planning session (full detail in
   `docs/planning/issue144-anchor-row-mismatch-fix-plan.md` §5):
   - **Candidate A** (gen-aware D2 tie-break, upstream prevention) -- fully resolves the 51
     mismatches *and provably* (not just empirically) eliminates the general mismatch class as a
     structural invariant, but forces a measured redistribution: duplicate-node count -20%
     (128->103), multi-anchor individuals 2->21 (up to 5-way).
   - **Candidate B** (adopted for #144) -- `effGenOf`, a per-anchor "effective row" =
     `max(own raw gen, every unit they anchor)`, applied only at the anchor's own contour
     reservation and display, never touching D2/who-anchors-what. Resolves the 51 mismatches with
     a small, localized code change (~11 lines) and zero redistribution.
   - **Candidate C** (connector/dogleg reframe) -- leaves rows untouched; signposts the resulting
     cross-generation mate-line visually instead. Does not satisfy #144's own literal success
     criterion; explicitly requires its own fresh owner product-level sign-off, not adopted then.
   - Candidate B was adopted for #144 on minimal-blast-radius grounds. Its own §6 "Here Be
     Dragons" **explicitly predicted and left open** the exact residual Track 4 now addresses: "an
     anchor that anchors 2 mating units at differing `unitGen`... the max-rule resolves the deeper
     unit but relocates (does not eliminate) the mismatch to the shallower one" -- confirmed not
     reachable in the real bundled fixture at the time, but real and reachable in general.
     Committed as a **regression test asserting deterministic, non-crashing, non-NA behavior**
     (i.e. accepting the defect, not fixing it) -- `tests/testthat/test_positionMatingUnitForest.R:809-862`
     (multi-unit case) and `:864-893` (a widened trigger: a single-unit anchor whose relocated
     `effGen` is deeper than a D5 direct child's own gen, rendering the child "above" its own
     parent).
3. **The kinship2-fidelity remediation plan's Claim 4a** (`docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md`
   §2.4a) independently rediscovered this exact predicted residual via the
   `test_makePedigreeMatingLayout.R:1075-1082` Track C fixture (built for a different bug's
   regression test, S563) and named it "the single most consequential finding" of that audit,
   spinning it out as Track 4 -- this document.

**Track 4 is therefore not a new defect investigation. It is the deferred resolution of a
dragon #144's own planning session already fully characterized, at the point where #144 itself
said the decision "needs its own dedicated design session."**

### 1.4 Fresh evidence gathered this session (not assumed carried forward)

Re-ran `.buildMatingUnitForest()` directly against the live source and the real 375-individual
bundled fixture (`inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv`) to confirm the baseline is
unchanged since #144's own session (Track 1/Track 3 do not touch D1/D2):

| Metric | Value | Matches #144 plan's own figures |
|---|---|---|
| Total mating units | 237 | Yes |
| Total duplicate nodes | 128 | Yes |
| Multi-anchor individuals | 2 (`IM1B5T`, `KUENM8`) | Yes |
| Anchor-side raw mismatches (pre-`effGenOf`) | 51 of 237 | Yes |
| Multi-anchor individuals whose units span *differing* gens | 0 (both `IM1B5T`/`KUENM8` anchor units sharing one gen) | Yes |

Confirms: Track 4's own motivating scenario does not yet manifest on the real bundled fixture --
it is demonstrated via the Track C synthetic fixture and the 2 committed synthetic regression
tests above, matching #144's own "real but not reachable in bundled data" characterization
verbatim, unchanged 1 session later.

**Candidate A's own trade-off figures independently re-simulated this session (not merely carried
forward from #144's session):** a throwaway R script (not a change to tracked source, matching
this project's own established "isolated validation script" precedent from #143/#144's own
sessions) reimplementing §2.1/§2.2's exact new rule was run directly against the real fixture:

| Metric | #144 plan's own figure (S473) | This session's fresh re-simulation | Delta |
|---|---|---|---|
| Anchor-side mismatches under the new rule | 0 (claimed provable) | **0**, confirmed live | Matches -- structural claim independently verified, not merely trusted |
| Multi-anchor individuals | 21 | **22** | Off by 1 -- expected: this session's script is a simplified reimplementation that does not replicate every dangling-parent/orphan-unit edge case `.buildMatingUnitForest()`'s full pipeline handles |
| Max anchors held by one individual | 5 (`WCPXHD`) | **5** (`WCPXHD`, confirmed the same individual) | Exact match |
| Duplicate-node count | 103 | **102** | Off by 1, same expected cause as above |

The exact figures should still be treated as approximate until the implementation session's own
full-pipeline run (§7 step 4) -- this re-simulation's purpose is to independently corroborate the
*structural* claim (0 mismatches, achievable by construction) and confirm the *order of magnitude*
of the redistribution is accurate, not to replace that final measurement.

**A structural realization made this session, not present in either prior plan:** a founder (0
known parents) always has `gen == 0` by `findGeneration()`'s own definition (`R/findGeneration.R:46-54`)
-- the shallowest possible value. This means **founder-status and "has the shallower gen" are the
same predicate whenever a founder is one of the two candidates.** D2's existing rule 1 ("prefer
the non-founder") is already, in effect, a special case of "prefer the deeper-gen parent" for
every pairing that involves a true founder. This directly informs the Decision below: gen-first
comparison does not *discard* the founder-preference rationale ("keep that lineage structurally
connected to its own ancestors"), it *generalizes and subsumes* it -- the two rules agree on every
founder-vs-non-founder pairing, and only diverge (meaningfully) on the two-non-founder ties that
are exactly the 42/51 mismatch population #144 characterized.

---

## 2. Decision

**Adopt Candidate A: make D2's anchor-selection tie-break gen-first, and remove the
already-used/elimination shortcut so every mating unit's anchor is decided purely on merit,
independent of any other unit's already-resolved anchor.**

### 2.1 The new `preferAnchor(a, b)` rule

Replaces `R/makePedigreeDiagramData.R:412-420` (current numbering):

```r
# before
preferAnchor <- function(a, b) {
  fa <- isFounderOf(a)
  fb <- isFounderOf(b)
  if (fa != fb) return(!fa)
  ca <- mateCountTab[[a]]
  cb <- mateCountTab[[b]]
  if (ca != cb) return(ca < cb)
  a < b
}

# after
preferAnchor <- function(a, b) {
  ga <- genOf[[a]]
  gb <- genOf[[b]]
  if (ga != gb) return(ga > gb)   # deeper gen wins -- subsumes founder-preference (§1.4)
  ca <- mateCountTab[[a]]
  cb <- mateCountTab[[b]]
  if (ca != cb) return(ca < cb)
  a < b
}
```

`isFounderOf()` is no longer called from `preferAnchor()` under this rule (§2.3 addresses whether
it is still needed elsewhere). `genOf` must be available at `.buildMatingUnitForest()`'s call
site -- confirmed already the case (`ped$gen`, the function's own required input column).

### 2.2 Remove the elimination/"used" shortcut

Replaces the anchor-assignment loop's `used`-elimination decision branch
(`R/makePedigreeDiagramData.R:444-459`, current numbering, the `else` arm of the `p1Real != p2Real`
check at `:441-442`) -- the `p1Used`/`p2Used` bookkeeping and its 2 elimination branches are
deleted; every unit's `winner` (when both candidates are real, `:443` `else {`) is decided by
`preferAnchor()` alone (the `p1Real`/`p2Real`/dangling-parent handling at `:429-442` is unaffected
and stays):

```r
# before (:444-459)
        p1Used <- used[[p1]]
        p2Used <- used[[p2]]
        if (p1Used && !p2Used) {
          p2
        } else if (p2Used && !p1Used) {
          p1
        } else if (preferAnchor(p1, p2)) {
          p1
        } else {
          p2
        }

# after
        if (preferAnchor(p1, p2)) p1 else p2
```

The `used <- stats::setNames(rep(FALSE, ...), parentIds)` initialization (`:423`) and the
`used[[winner]] <- TRUE` bookkeeping (`:461-463`, current numbering) are removed entirely -- no
downstream code reads `used` outside this branch (`hasAnchorAnywhere`, `:497`, is computed from
`anchorOf` directly, confirmed by direct inspection this session).

### 2.3 Delete the now-redundant `effGenOf`/anchor-`dispGenOf` mechanism

**This is a direct, provable consequence of §2.1-2.2, not a separate design choice.** Under the
new rule, every mating unit's anchor has, by construction, `genOf[[anchor]] >= genOf[[nonAnchor]]`
for every unit they anchor -- i.e. `genOf[[anchor]] == unitGen` for every one of their units
(since `unitGen = pmax(genOf[sire], genOf[dam])`, and the anchor is by definition whichever side
is `pmax`). This holds **regardless of how many units an individual anchors**, since each unit's
anchor decision is now fully local (§2.2 removed the only piece of cross-unit state). Therefore:

- `effGenOf` (`R/makePedigreeDiagramData.R:752-756`, current numbering: `for (aid in
  names(anchorUnitsOf)) effGenOf[[aid]] <- max(genOf[[aid]], unitGenOf[anchorUnitsOf[[aid]]])`)
  collapses to `effGenOf == genOf` for every anchor, unconditionally -- delete the block; `effGenOf`
  is replaced by `genOf` at its 2 remaining call sites (`positionIndividual()`'s `:831`/`:836`,
  current numbering).
- The anchor-side `dispGenOf` override (`R/makePedigreeDiagramData.R:782-793`, current numbering
  -- the issue #144 addition) is deleted; `dispGenOf` for anchors is simply their own `genOf`,
  which is already `dispGenOf`'s own initialization (`dispGenOf <- genOf[realIds]`, `:776`). The
  free-pass override (issue #143's own fix, `:776-781`) is **unaffected and stays** -- it addresses
  a structurally different case (non-anchor occurrences) untouched by this decision.

**Net effect: this decision does not add a compensating mechanism on top of #144's -- it removes
#144's `effGenOf` compensating mechanism as no longer necessary, because the upstream cause (D2's
gen-blind anchor choice) is fixed instead of its downstream symptom.** The implementation
session's diff is expected to be a net simplification (removing more lines than it adds), not
purely additive -- confirm this expectation rather than assume it once the edit is drafted (§7).

### 2.4 Invariant this decision establishes (new committed regression test)

`matingUnits$gen == genOf[[matingUnits$anchor]]` for every mating unit, unconditionally -- no
exceptions, no residual. This directly resolves both committed regression tests at
`tests/testthat/test_positionMatingUnitForest.R:809-862` and `:864-893` (§1.3), which currently
assert *acceptance* of the mismatch; the implementation session's RED phase must flip both to
assert the mismatch is *resolved* (§7 details the exact expected values for each fixture).

---

## 3. Rationale

Chosen over Candidates B (status quo) and C (dogleg signposting) on this project's own
established design principle, applied at one level up from where #144 applied it: **a decision
that structurally closes a defect class is preferred over one that patches or signposts its
current known instances, when the structural fix is already validated and its cost is bounded and
measured, not speculative.**

- **Provably complete, not empirically incomplete.** Candidate B (status quo) is known,
  demonstrated, and committed-as-accepted to leave a residual (§1.3) -- Candidate A closes it as a
  structural invariant (§2.4), covering both the multi-unit-differing-gen case *and* the D5-direct-child
  case with the same single mechanism (traced by hand this session, §1.4/§2.3 -- neither prior
  plan's own analysis connected these two committed regression tests to one root cause before).
- **Net simplification, not net addition.** Unlike layering Candidate C's signposting on top of
  the status quo (remediation plan's own framing of option "(a)"), adopting Candidate A **removes**
  #144's own `effGenOf` compensating code (§2.3) rather than adding a second compensating layer on
  top of the first. Two compensating mechanisms stacked on the same root cause (gen-blind anchor
  selection) is a worse long-term shape than fixing the root cause once.
- **No new visual language.** Reuses the existing, already-shipped, already-understood duplicate-node
  and dashed-arc convention (D1/D6) for every individual who now anchors more than one unit --
  visually, "appearing twice with a dashed connector" is not a new concept this diagram
  introduces; it is the same mechanism every other multi-mate individual already uses.
- **The cost is real, measured, and disclosed -- not hidden.** Duplicate-node count -20%
  (128->103), multi-anchor individuals 2->21 (up to 5-way) on the real fixture, per #144's own
  validated figures (§1.4 reconfirms the *baseline* these deltas apply to is unchanged). This is a
  genuine visual-character shift in which individuals become the diagram's "hub" points, and it
  was surfaced to the owner directly (not decided unilaterally) via this session's own
  `AskUserQuestion`, exactly the kind of product call #144's own plan explicitly declined to make
  without dedicated deliberation -- which is what this document *is*.
- **Rejected: Candidate C alone.** Lowest engineering risk, already validated (including a real
  ~37% rectilinear-mode performance regression found and fixed during its original design,
  `BACKLOG.md:782-794`), but never resolves the row-mismatch metric -- every occurrence still
  renders at exactly one row, the defect is reframed as intentional rather than closed. Remains
  independently valuable as a general diagram-readability enhancement (BACKLOG.md's own standing
  item) and is **not precluded by this decision** -- see §5's explicit non-exclusion note.
- **Rejected: a narrower, unvalidated "duplicate only the differing-gen anchor" idea** (raised and
  set aside during this session's own analysis, not carried from either prior plan) -- would
  resolve Track 4's specific trigger without D2 changes, but requires genuinely new D1/D3
  duplication logic with no existing prototype (closer to the #143 plan's own "Candidate 2"
  structural-unification territory, twice already declined as out-of-scope for a point-patch).
  Given Candidate A already resolves the same defect class via a smaller, already-validated
  mechanism, this idea is not worth its own validation investment.

---

## 4. Alternatives Considered

| Alternative | Resolves Track 4's residual | Touches D2 | Net code change | Visual cost | Status |
|---|---|---|---|---|---|
| **A. Gen-first anchor selection (adopted)** | Yes, provably (structural invariant, §2.4) | Yes | Net simplification (removes `effGenOf`, §2.3) | Duplicate nodes -20% (128->103), multi-anchor 2->21 (up to 5-way) | Adopted |
| B. Status quo (`effGenOf`, issue #144 as shipped) | No -- known, committed-as-accepted residual (§1.3) | No | none (already shipped) | None beyond what's already shipped | Rejected -- the residual this plan exists to close |
| C. Dogleg/connector signposting, extended to `edgeStyle="direct"` | No -- reframes, does not eliminate | No | Additive (new styling logic in a different subsystem) | None to node positions; adds a 2nd visual convention (span-signposting) alongside the existing duplicate/dashed-arc one | Rejected as *this* decision's answer; remains independently available (§5) |
| D. Targeted duplicate-anchor (new idea, unvalidated) | Yes, in principle (narrower scope than A) | No (D1-adjacent, new mechanism) | Additive, new D1/D3 code, no prototype | Unknown -- not built | Rejected -- redundant with A at higher risk/cost |

---

## 5. Impact Analysis

| Surface | Impact | Action Required |
|---|---|---|
| `.buildMatingUnitForest()` (D1/D2) | `preferAnchor()` rewritten (§2.1); elimination shortcut removed (§2.2) | Full `test_buildMatingUnitForest.R` suite (66 expectations, per #144's own measurement) must be reviewed -- some anchor assignments will change by design; each changed expectation must be re-derived from the new rule, not mechanically flipped |
| `.positionMatingUnitForest()` (D3) | `effGenOf` and the anchor `dispGenOf` override deleted (§2.3); `positionIndividual()`'s 2 call sites revert to `genOf` | The 2 committed residual-acceptance regression tests (§1.3/§2.4) flip to residual-resolved assertions |
| Duplicate-node population (D1 step 4) | Real, measured redistribution: 128->103 nodes on the real fixture (#144's own validated figure, re-derive fresh since D1 itself changes, not just D3) | Implementation session must re-measure on the current codebase (Track 1/Track 3 landed since #144's own validation run) rather than trust the carried-forward number as exact |
| Multi-anchor individuals | 2->21 (up to 5-way) on the real fixture (#144's own validated figure, same re-measurement caveat) | Live render verification (§7) should visually confirm this reads acceptably, not just confirm the count -- this is the one part of this decision that is a genuine judgment call, already made by the owner (§9), but worth a sanity screenshot before considering the implementation done |
| Track 3 (minimum mate-spacing sweep, `sweepMinSep()`) | Orthogonal by construction (operates on `x` within a row, not on `gen`/row assignment) -- not expected to need changes | Implementation session should still re-run Track 3's own regression tests against the new node population as part of full-suite verification, not skip on the "orthogonal" assumption alone |
| `edgeStyle="rectilinear"` dogleg mechanism (issue #142) | The anchor-side dogleg (`.addRectilinearWaypoints()`'s D2 loop, exercised by `test_addRectilinearWaypoints.R:366-423`) fires for far fewer units once anchor mismatches are structurally eliminated -- mirrors #144's own precedent (that fix reduced rectilinear-mode node count 1279->1228) | Re-measure the rectilinear node count fresh; update the corresponding hardcoded test expectation |
| `edgeStyle="direct"` (current default) | No change to edge routing (this decision changes node *positions*, not edge-drawing logic) | None beyond position-value re-verification |
| Track 2 (flip default `edgeStyle` to `"rectilinear"`, not yet started) | The remediation plan's own §5 recommends sequencing Track 2 *after* this decision lands, specifically so Track 2's "must not regress" list is verified once against the corrected node population, not twice | No action this session; carries forward as the remediation plan's own next-pickup guidance |
| Candidate C (dogleg signposting) | **Not precluded by this decision.** If, after a live render of Candidate A's redistribution, the owner judges some remaining cross-generation mate-lines still benefit from visual signposting (e.g. for legibility, independent of correctness), Candidate C remains a valid, separately-validated, additive follow-up -- this decision does not need to be revisited to add it | None this session; note carried into §8 |

---

## 6. Migration Path (for the implementation session)

Single-commit change, matching #143/#144's own precedent (small, synchronized, atomic):

1. **Edit `.buildMatingUnitForest()`**: rewrite `preferAnchor()` (§2.1), delete the elimination
   shortcut and `used` bookkeeping (§2.2). `isFounderOf()` -- confirm whether it is still
   referenced elsewhere in the function (the dangling-parent guard, `:398-408`, current numbering,
   is a distinct helper reused by other logic; re-verify at implementation time whether it survives
   unchanged, is merged into the new `preferAnchor()`, or becomes dead code to remove).
2. **Edit `.positionMatingUnitForest()`**: delete `effGenOf`'s computation and both call sites,
   revert to `genOf` (§2.3); delete the anchor `dispGenOf` override block, leaving the free-pass
   override (issue #143's) untouched.
3. **Rewrite the 2 residual-acceptance regression tests** (§2.4) to residual-resolved assertions,
   re-deriving exact expected values from the fixed implementation's own live output (matching
   Track 3's own established practice, not hand-derivation) rather than predicting them in advance.
4. **Re-run and update every test in `test_buildMatingUnitForest.R`/`test_positionMatingUnitForest.R`/
   `test_addRectilinearWaypoints.R`/`test_makePedigreeMatingLayout.R`** whose hardcoded expectations
   encode the old anchor-selection outcome -- #144's own session measured ~38 failures across 13
   blocks for this exact candidate; treat that as an expected order-of-magnitude, not an exact
   count to match (3 commits have landed in the interim).
5. Rollback: pure computation, no persisted state or migration -- a plain `git revert` of the one
   commit, matching #143/#144's own precedent.

This is scoped as its own implementation session (or, if the vertical-slice gates in
`SESSION_RUNNER.md` §Vertical Slice Sessions are satisfied against this document as the
pre-declared contract, potentially one session covering steps 1-4 as layers of one capability) --
not a multi-phase campaign. The remediation plan's own §4 Track 4 entry already estimated
"Effort: L (design) + L (implementation), likely 2+ further sessions beyond [the remediation]
plan" -- this document is the first of those.

---

## 7. Verification Plan (for the implementation session)

1. **RED**: update the 2 residual-acceptance tests (§2.4) to residual-resolved assertions; add a
   new committed test asserting the invariant `matingUnits$gen == genOf[matingUnits$anchor]` holds
   for every unit on the real 375-individual fixture (0 exceptions) -- the direct, general-property
   test this decision's own correctness claim rests on, not fixture-specific alone.
2. **GREEN**: implement the edits (§2.1-2.3) together in one commit.
3. **REFACTOR**: confirm rather than assume none is needed (matching #143/#144's own precedent of
   checking, not skipping this phase by default).
4. **Re-measure, don't assume, every carried-forward number**: duplicate-node count (2 prior
   estimates bracket it -- 103 from #144's own session, 102 from this session's fresh
   re-simulation, §1.4 -- confirm the full-pipeline exact value), multi-anchor count (bracketed at
   21/22 the same way, confirm exactly and list them), rectilinear node count (expect a drop from
   the current 1228 baseline -- Track 3 has not changed this figure -- confirm the new exact
   value).
5. **Re-verify the `GA204Z`/`8LKBV9` inbreeding-loop fixture**: zero overlap, zero non-termination
   -- `8LKBV9` (3 distinct mates) is exactly the kind of individual this decision directly affects.
6. **Re-verify Track 3's minimum-separation guarantee** on the new node population (§5) -- expected
   to hold unmodified, confirm rather than assume.
7. **Full regression suite + `devtools::check()`**: confirm every changed test traces to exactly
   this decision's own root cause (a stale hardcoded anchor-choice value), no unrelated files
   affected.
8. **Live verification (Phase 3E)**: render the real fixture under both `edgeStyle` values via
   `shinytest2`/`chromote`. Confirm (a) the Track 4 motivating scenario (an anchor with 2+ unions
   at differing gens) now renders every union on-row for its own generation; (b) zero
   diagram-related console errors; (c) a visual spot-check of at least 3-5 of the newly-created
   multi-anchor individuals, to give the owner (not just the numeric count) a real look at the
   redistribution's visual character before considering this decision's implementation complete;
   (d) issue #143's own already-fixed non-anchor units are still correctly positioned (no
   regression).

**What DONE looks like**: the new invariant test (step 1) passes on the real fixture (0 exceptions);
the 2 residual regression tests assert resolution, not acceptance; full suite + `devtools::check()`
at baseline elsewhere; live verification confirms the motivating scenario renders correctly and the
owner has seen the multi-anchor redistribution rendered, not just counted.

---

## 8. Explicitly Out of Scope (report, don't fix here -- `PROJECT_LEARNINGS.md` Learning 382)

- **Candidate C (dogleg/connector signposting)** -- not adopted as this decision's answer, but
  explicitly not precluded either (§5). Remains available as a future, separately-scoped,
  already-validated enhancement if a live render of Candidate A's redistribution (§7 step 8) leads
  the owner to want additional visual signposting for legibility. `BACKLOG.md`'s existing
  "Candidate C" item (found S473) already tracks this -- no new item needed; that entry should be
  annotated at this plan's close-out to note Track 4 chose A instead, without closing Candidate C
  out as declined.
- **Candidate D (targeted duplicate-anchor)** -- raised and set aside this session (§3) as
  redundant with Candidate A at strictly higher risk/cost. Not validated, no prototype exists,
  nothing to preserve or reference beyond this document's own §3/§4 record of why it was not
  pursued.
- **`isFounderOf()`'s ultimate fate** (§6 step 1) -- whether it becomes dead code, gets merged into
  the new `preferAnchor()`, or is reused elsewhere is an implementation-session detail this
  document intentionally leaves open rather than over-specifying ahead of seeing the actual diff.
- **Re-deriving the exact ~38-failure/13-block test blast radius figure from #144's own session**
  -- carried forward as an order-of-magnitude expectation (§6 step 4), not re-validated this
  session (D1/D2 source has not changed since #144, confirmed by this session's own baseline
  re-check, §1.4, but 3 commits' worth of *other* file changes since then could still shift the
  exact count) -- the implementation session's own full regression run is the authoritative count.
  (The duplicate-node/multi-anchor *counts* themselves, by contrast, **were** independently
  re-simulated this session against the real fixture, §1.4 -- confirmed closely matching #144's own
  figures, off by exactly 1 in each direction, attributable to this session's simplified script not
  replicating every dangling-parent edge case. Only the *test-file* blast-radius figure remains
  purely carried forward.)

---

## 9. Owner ratification record

- [x] **Proceed to implementation following this decision (Candidate A, §2) as written**
- [ ] Proceed with modifications (specify which part to revisit)
- [ ] Hold -- more research needed before implementation begins

Ratified via `AskUserQuestion`, S572 (2026-08-14): presented 3 options (Candidate A/recommended,
Candidate C, hold-for-more-evidence) with the measured trade-offs of each stated directly in the
question itself (duplicate-node/multi-anchor redistribution for A; unresolved-metric caveat for
C). Owner selected Candidate A. No further modification requested; the decision is ratified as
written in §2.

---

## References

- `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md` §2.4a, §4 Track 4 -- the
  origin of this design session and its own evidence base (reused, not re-derived).
- `docs/planning/issue144-anchor-row-mismatch-fix-plan.md` -- the sibling planning session whose
  own Candidate A/B/C characterization, empirical validation, and explicitly-predicted residual
  (§6) this document builds directly on rather than re-deriving from scratch.
- `docs/planning/issue143-founder-positioning-fix-plan.md` -- the non-anchor sibling fix; its own
  "Candidate 2" (structural unification) and "Candidate 3" (connector reframe) are the ancestors
  of #144's Candidate A/C naming, referenced in §3 for why "Candidate D" (this document's own new
  idea) was set aside as redundant/higher-risk than an already-validated alternative.
- `docs/planning/pedigree-diagram-option2-layout-design-plan.md` -- the D1-D6 mechanism this
  decision operates inside; §1.1 of the #144 plan already established D2's gen-blindness is not a
  protected property of that ratification (reused in §1.1 above).
- `tests/testthat/test_positionMatingUnitForest.R:809-893` -- the 2 committed regression tests
  this decision's implementation session must rewrite from residual-acceptance to
  residual-resolution (§2.4, §7).
- `BACKLOG.md:782-794` -- the standing "Candidate C" tracking item, not closed by this decision
  (§8).
