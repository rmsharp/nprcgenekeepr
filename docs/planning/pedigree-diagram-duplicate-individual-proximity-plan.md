# Design: Duplicate-vs-unrelated-individual proximity near-misses

**Status:** DRAFT — pending owner ratification (`AskUserQuestion`, this session).
**Session:** S658 (2026-08-30). Planning-only session (`ARCHITECTURE_WORKSTREAM.md`) — no code
or test changes ship in this session; implementation is a separate future session, per
`SESSION_RUNNER.md`'s Planning Sessions rule ("the plan is the deliverable, do not start
implementing it").
**BACKLOG item:** "6 pre-existing duplicate-vs-INDIVIDUAL proximity near-misses on the real
375-individual fixture, unrelated to and unaffected by Track 7 Phase 2/4" (found S654,
2026-08-30, `BACKLOG.md` Housekeeping — "READY tag, but needs its own design session first").

---

## 1. Context

### 1.1 Problem statement (as originally filed)

`.deCollideIndividualPoints()` (a closure nested inside `.positionMatingUnitForest()`,
`R/makePedigreeDiagramData.R:866-940`) is the only de-collision mechanism for individual-shaped
render nodes (genuine/B1 individuals and `__dup_*` duplicates, both rendered as 25px-radius
circles). It intervenes **only on an exact tie** (`abs(x0-forbidden) < 1e-9`) — it has no
near-miss radius check at all, unlike the union-side mechanism Track 7 Phase 2/4 added for
union-vs-individual and union-vs-duplicate proximity (`unionClearanceIndividual =
(25+6)/120 = 0.2583`).

S654's own incidental measurement, made while empirically grounding the Track 7 Phase 4 design,
reported **6 duplicate-vs-individual cases** at 0.099–0.100 raw units apart (well inside a
proper two-25px-radius clearance), using `unionClearanceIndividual` (0.2583, the *union*-radius
proxy) as a "visually close enough to matter" detection threshold — explicitly flagged in that
finding as not the correctly-calibrated value for two full-size nodes, which would be
`(25+25)/120 = 0.41667`.

### 1.2 Pre-RED re-measurement (this session) — the filed count does not survive family-relationship exclusion

Re-running the measurement with the **geometrically correct** `individualClearance =
(25+25)/120 = 0.41667` threshold, over every same-generation pair of individual-shaped nodes on
the real 375-individual/237-mating-unit/102-duplicate fixture
(`obfuscated_rhesus_mhc_ped.csv`), surfaces **121 pairs**, not 6 — because 0.41667 is close to
several *intentional, by-construction* formulaic offsets already in the codebase. Classifying
each pair by the real relationship between the two underlying individuals (own-mating-unit
parent, parent-child, sibling, mate, or unrelated) resolves the apparent explosion:

| Relationship | Count | Verdict |
|---|---|---|
| **`dup-own-parent`** — a duplicate sitting `minSep*0.4 = 0.4` from its own mating unit's sire/dam (`derivedX()`'s B3 formula, `:816`) | 90 | **By design**, not a defect — Track 7 Phase 3's revert made a qualifying union's `x` bit-exact to its own anchor, so its duplicate's fixed `+0.4` offset lands almost exactly at the union's own radius-sum boundary. |
| **`mate`** — two co-parents of the same mating unit, both rendered ~0.4 apart | 25 | **By design**, Track 7's own territory (mate-spacing), not this item's concern. |
| **`UNRELATED`** — no mating-unit, parent-child, sibling, or mate relationship on either side | **6** | The genuine defect class — see §1.3. |

Independently re-verified this session by a separate adversarial-verification agent, run from
scratch against the same fixture: **exact same 6 pairs, same ids, same distances to 3 decimal
places.** No half-sibling, grandparent, avuncular, or duplicate-of-a-duplicate relationship
applies to any of the 6 (checked explicitly) — the classification is not missing a relation type
that would shrink the list further.

### 1.3 The corrected 6 — and why 4 of the *original* 6 were never real

| Pair | dist | In BACKLOG's original 6? | Relationship |
|---|---|---|---|
| `TTE0Z7` / `__dup_MY1AEU_2` | 0.099 | Yes | **UNRELATED — genuine** |
| `M0YNUR` / `__dup_L31S6S_5` | 0.100 | Yes | **UNRELATED — genuine** |
| `__dup_1X40V5_2` / `0Q077X` | 0.100 | Yes | `dup-own-parent` (own dam) — **not a defect** |
| `__dup_7NBKWE_3` / `IM1B5T` | 0.100 | Yes | `dup-own-parent` (own dam) — **not a defect** |
| `__dup_M5DJVP_1` / `45YQV5` | 0.100 | Yes | `dup-own-parent` (own dam) — **not a defect** |
| `__dup_KCBMY9_2` / `665C2Y` | 0.100 | Yes | `dup-own-parent` (own dam) — **not a defect** |
| `D0Z114` / `S0022Z` | 0.100 | **No — new** | **UNRELATED — genuine** |
| `XEE9GT` / `JB7EW2` | 0.100 | **No — new** | **UNRELATED — genuine** |
| `PQX22G` / `Y7IUMX` | 0.400 | **No — new** | **UNRELATED — genuine** |
| `HKTQ40` / `8P17E3` | 0.401 | **No — new** | **UNRELATED — genuine** |

**Net correction:** the original filing's 6 cases were measured without any family-relationship
exclusion. 4 of those 6 are the duplicate sitting next to its own parent — an intentional,
formulaic placement, not a coincidental collision — and are not defects. The filing's *count*
(6) survives only by coincidence: this session's wider, correct-threshold sweep found 4 
different genuine cases (all real-individual-vs-real-individual, none involving a duplicate)
that the original 0.2583 proxy threshold was too narrow to see (`PQX22G`/`Y7IUMX` at 0.400 and
`HKTQ40`/`8P17E3` at 0.401 are both above 0.2583).

### 1.4 A second correction: the defect is not duplicate-specific

Adversarial verification (this session) confirmed, by reading `sweepMinSep()`
(`R/makePedigreeDiagramData.R:734-749`) and reproducing the `b1Ids` population standalone (it is
an internal closure variable, never returned by `.positionMatingUnitForest()`): **two genuine
Tier-1 individuals can never be closer than `minSep = 1`** at the same generation — comfortably
above `individualClearance = 0.41667` — so a real-vs-real near-miss is only possible when **at
least one side is a B1-tier "free pass" individual**, which is positioned via `tier3X` /
`.deCollideIndividualPoints()` (the same weak, exact-tie-only mechanism duplicates use), not the
`sweepMinSep()`-guaranteed Tier-1 sweep.

Confirmed directly: of the 4 real-real UNRELATED pairs, `D0Z114` (genuine) vs `S0022Z` (B1) is
B1-vs-genuine; `XEE9GT`/`JB7EW2`, `PQX22G`/`Y7IUMX`, `HKTQ40`/`8P17E3` are all B1-vs-B1. **Zero
genuine-vs-genuine pairs exist or can exist.**

This means the true defect class is **"any tier3-positioned point (B1 individual *or*
duplicate) can land near an unrelated tier1/tier3 point, because `.deCollideIndividualPoints()`
never checks a near-miss radius, only an exact tie."** Of the 6 confirmed genuine cases, only
**2 involve a duplicate** (`TTE0Z7`/`__dup_MY1AEU_2`, `M0YNUR`/`__dup_L31S6S_5`); the other
**4 are B1-vs-individual, no duplicate involved at all** — outside what the BACKLOG item's own
"duplicate-vs-INDIVIDUAL" title describes, and outside what either fix option below can reach.

---

## 2. Decision

**Fix scope, this design (ratification item 1):** the **2 duplicate-vs-unrelated-individual
cases only** (`TTE0Z7`/`__dup_MY1AEU_2`, `M0YNUR`/`__dup_L31S6S_5`). The 4 B1-vs-individual
cases are filed as a **separate, disclosed follow-up item** (§6), not fixed here — matching
this project's own established narrow-scoping precedent (Track 7 Phase 2 deferred "symmetric
individual-side hardening" for the identical reason: disproportionate blast radius for the
evidence in hand).

**Mechanism, this design (ratification item 2) — Option B, RECOMMENDED:** extend Track 7 Phase
4's existing post-hoc duplicate-side push loop (`R/makePedigreeDiagramData.R:1125-1160`) to
*also* check each duplicate against nearby **unrelated** individual-shaped points (`tier1X` and
`tier3X[b1Ids]` at that duplicate's generation, excluding the duplicate's own mating unit's
sire/dam), combined into the *same* rightward capped search the union-check already uses:

```r
individualClearance <- (25L + 25L) / 120L                      # new constant, beside :996-997

for (dupId in dupIds) {
  unitId <- duplicates$matingUnitId[duplicates$id == dupId]
  g <- tier3Gen[[dupId]]
  unrelatedUnionsAtGen <- ...                                   # unchanged (:1128-1130)
  ownParents <- c(unname(unitSire[[unitId]]), unname(unitDam[[unitId]]))
  unrelatedIndividualsAtGen <- c(tier1X[dispGenOf == g],
                                  tier3X[b1Ids[tier3Gen[b1Ids] == g]])
  unrelatedIndividualsAtGen <- unrelatedIndividualsAtGen[
    !is.na(unrelatedIndividualsAtGen) &
    !(names(unrelatedIndividualsAtGen) %in% ownParents)]
  if (length(unrelatedUnionsAtGen) == 0L &&
      length(unrelatedIndividualsAtGen) == 0L) next            # widened guard -- see §3 gotcha
  collidesUnrelatedUnion <- function(x0) ...                    # unchanged
  collidesUnrelatedIndividual <- function(x0) {
    length(unrelatedIndividualsAtGen) > 0L &&
      any(abs(x0 - unrelatedIndividualsAtGen) < individualClearance)
  }
  collides <- function(x0) collidesUnrelatedUnion(x0) || collidesUnrelatedIndividual(x0)
  x0 <- tier3X[[dupId]]
  if (collides(x0)) {                                           # was collidesUnrelatedUnion(x0)
    ... same capped rightward search, gated by collides() instead of collidesUnrelatedUnion() ...
  }
  tier3X[[dupId]] <- x0
}
```

One new constant, one new forbidden-set variable (with the own-family exclusion this design
requires), one new closure, one `||`. Both existing call sites inside the search switch from
`collidesUnrelatedUnion` to the combined `collides`.

---

## 3. Rationale

**Why Option B, not Option A (widen `.deCollideIndividualPoints()`'s own threshold for the
`dupIds` call):** measured this session, Option A as originally conceivable — replacing the
exact-tie epsilon with `individualClearance` inside the shared closure — is **not viable**:

- `individualOccupied` (the closure's forbidden set, `:877`) has **no family exclusion at all**.
  Measured directly: **90 of 102 duplicates** would newly collide with their *own* mating-unit
  parent (since a qualifying union's `x` is bit-exact to its anchor post-Track-7-Phase-3, and a
  duplicate's own `+minSep*0.4=0.4` offset from that union is `< 0.41667`) — a **45:1
  collateral-to-benefit ratio** against the 2 genuinely intended fixes.
- This directly breaks a pinned test (`test_positionMatingUnitForest.R:313`, confirmed by
  execution, not conjecture) and would very likely perturb several more count-based pins
  (`:1081`'s 27L exact-tie count, `:1284`'s Phase-4 residual count, and
  `test_resolveEdgeNodeCollisions.R:487-488`'s edge/node counts).
- Because the `dupIds` call's `pushSign` is always `+1` (mirroring `derivedX()`'s
  always-rightward B3 convention), any of the 90 that trip would be pushed a full `minSep` or
  more away — **detaching the duplicate from the very union it represents**, a worse visual
  defect than the 0.1-raw-unit overlap being fixed.
- Option A is viable only with an added family exclusion mirroring the one this design adds to
  Option B anyway — at which point it is strictly more code than Option B (touches a shared,
  heavily-relied-on closure instead of an already-narrow, already-precedented post-hoc pass) for
  no additional benefit.

**Why Option B is safe against the 3 already-shipped Track 7 Phase 4 cases:** proven two ways
this session, not assumed. (1) An OR-monotonicity argument — combining `collidesUnrelatedUnion`
with a new `|| collidesUnrelatedIndividual` can only *enlarge* the rejected-candidate set, so
the search's chosen `x` can only move *later* (larger `k`), never earlier; if the shipped
algorithm's own chosen candidate already clears the new individual check too, the combined
search picks the identical `x`. (2) Direct simulation: reconstructing Phase 4 from the identical
pre-Phase-4 snapshot, once as shipped and once with Option B's combined check, produced
byte-identical final `x` for all 3 named cases (`__dup_L31S6S_3`, `__dup_WDBGPF_2`,
`__dup_YPHFHF_1`). The margin is real but not enormous (~4%, each sits `0.4333` from its nearest
unrelated individual vs. the new `0.41667` threshold) — an empirical fact about this fixture's
current lattice, re-confirm on any different fixture, not a structural guarantee.

**Blast radius, measured directly:** exactly **2 of 102** duplicates move under Option B
(`__dup_MY1AEU_2`, `__dup_L31S6S_5`), each by one clean push step
(`+individualClearance=0.5167`, no cap exhaustion against `.kMaxUnionPush=5`), and neither
newly collides with a union or another duplicate afterward.

---

## 4. Alternatives Considered

| Alternative | Pros | Cons | Why Rejected / Deferred |
|---|---|---|---|
| **A. RECOMMENDED — extend Track 7 Phase 4's existing post-hoc duplicate loop with a combined union+individual check (§2)** | Reuses an already-shipped, already-tested pattern exactly; provably inert against the 3 known Phase-4 cases; smallest measured blast radius (2/102 duplicates, 1 step each) | Needs the early-exit guard at `:1131` widened (an easy-to-miss pitfall, not a design flaw) | — (this is the recommendation) |
| **B. Widen `.deCollideIndividualPoints()`'s own threshold for the `dupIds` call, with an added family exclusion** | Fixes the same 2 cases; arguably more "in the same place" as the existing weak protection | Strictly more invasive than A for the identical result — touches the shared closure's contract instead of an isolated post-hoc pass, and needs the *same* family exclusion A already carries | **Rejected** — no benefit over A, larger surface touched |
| **C. Widen `.deCollideIndividualPoints()`'s threshold with NO family exclusion (the original framing of "Option A")** | Simplest code | Measured: 90/102 duplicates collide with their own parent, 45:1 collateral-to-benefit, breaks a pinned test directly, pushes duplicates away from their own union — a worse defect than the one being fixed | **Rejected** — not viable, confirmed by direct execution |
| **D. Also extend the widened threshold to the `b1Ids` call, fixing all 6 known cases (2 duplicate + 4 B1) in one change** | Fully resolves every currently-known near-miss, not just the duplicate-involving 2 | `b1Ids` is a heavily-tuned population (Track 7 Phases 1/2, S647/S649: widened offset, direction-preserving `pushSign`, its own empirically-derived `.kMaxIndividualPush=2` cap) with ~20 hardcoded position assertions and the `nColliding=27L` regression count depending on its current behavior; needs its own empirical cap re-derivation and re-verification, not a drop-in alongside an unrelated duplicate-side fix | **Deferred** — file as its own follow-up (§6), matching this project's own repeated "file, don't fix out-of-scope findings" precedent (the `__jog_*` waypoint bug, Track 7 Phase 2's own deferred Alternative D) |
| **E. Do nothing — accept the 2 duplicate cases as an existing, small, disclosed residual** | Zero risk | Leaves a ~76%-overlap visual defect (12px center distance for two 50px-diameter circles) uncorrected, when a narrow, provably-safe fix is available | **Rejected** — the fix is small and well-understood enough to be worth shipping |

---

## 5. Impact Analysis

| System / surface | Impact | Action Required |
|---|---|---|
| Track 7 Phase 4's post-hoc duplicate loop (`R/makePedigreeDiagramData.R:1125-1160`) | Gains one new forbidden-set check, combined via `||` with the existing union check | Implementing session's own RED/GREEN |
| `.deCollideIndividualPoints()`, `sweepMinSep()`, B1/B3 individual formulas | **No change** — this decision touches only the existing Phase-4 post-hoc loop | None |
| The 3 already-shipped Track 7 Phase 4 union-vs-duplicate cases | Provably unaffected (OR-monotonicity + byte-identical simulation, §3) | Re-confirm via the existing pinned tests, not a new analysis |
| `test_resolveEdgeNodeCollisions.R:487-488` (`nrow(baselineEdges)`/`nrow(baseline)`) | 2 duplicates' `x` change — counts likely shift, matching Phase 4's own precedent (95→98/1759→1762 when 3 duplicates moved) | Implementing session: re-measure live, do not assume unchanged |
| `test_makePedigreeMatingLayout.R:658,666` (node count / `__jog_` count) | Same 2 duplicates moving may reshape jog-repair counts | Implementing session: re-measure live |
| `test_positionMatingUnitForest.R:1284` (Phase-4 residual count, `0L`) | Confirmed unchanged by direct simulation (neither moved duplicate newly collides with a union) | Re-run to confirm, not expected to change |
| Real-colony rendering | 2/102 duplicates (2.0%) visibly move by ~62px (0.5167 raw × 120); the remaining 100 are untouched | None — scoped, disclosed trade-off |
| `BACKLOG.md`'s own item text | The original "6 duplicate-vs-individual" framing is materially corrected (4 of 6 were never defects; 4 *different*, newly-found cases are B1-related, not duplicate-related) | Rewrite the item at ratification (this session) to reflect §1.3/§1.4, regardless of which mechanism ships |

---

## 6. Explicitly Out of Scope (report, don't fix here)

- **The 4 B1-vs-unrelated-individual cases** (`D0Z114`/`S0022Z`, `XEE9GT`/`JB7EW2`,
  `PQX22G`/`Y7IUMX`, `HKTQ40`/`8P17E3`) — same root cause (`.deCollideIndividualPoints()`'s
  exact-tie-only guard), different call site (`b1Ids`, `R/makePedigreeDiagramData.R:958-960`).
  **To be filed as a new, separate `BACKLOG.md` Housekeeping item** at ratification: extending
  the same widened-clearance idea to the `b1Ids` population needs its own empirical cap
  re-derivation (Track 7 Phase 1/2 already tuned `.kMaxIndividualPush=2` against a *different*
  problem — sibling-bar-overlap avoidance for the widened B1 offset, not near-miss avoidance)
  and re-verification against ~20 hardcoded B1-position assertions plus the `nColliding=27L`
  regression count — a materially larger, separately-scoped effort.
- **Duplicate-vs-duplicate proximity** — currently 0 near-misses on the real fixture (checked
  all 102×101/2 same-gen pairs, before and after simulating this design's 2 pushes), but
  **not structurally prevented** by either the shipped mechanism or this design. Disclosed as a
  known-clear-today, unguarded residual, not a defect to fix now.
- **The early-exit guard at `:1131`** (`if (length(unrelatedUnionsAtGen) == 0L) next`) must be
  widened to also check the new individual forbidden-set, or a duplicate in a generation with no
  *other* mating units would silently skip the new check entirely. Does not bite on the current
  fixture (verified) but is a real edge case on a sparser one — the implementing session's own
  RED phase must cover it with a dedicated test, not just the real-375 regression.

---

## 7. Verification Plan (for the implementing session)

- **Pre-RED empirical re-validation**, matching this design's own methodology: re-run the exact
  measurement in §1.2/§1.3 against unmodified `HEAD` at implementation time (do not assume this
  design doc's counts are still current — re-derive).
- **RED:** a new test reproducing the 2 named cases directly (mirroring Track 7 Phase 4's own
  precedent of one dedicated case-reproduction test alongside the aggregate counts), plus updates
  to the aggregate pins named in §5 confirmed genuinely failing against unmodified `HEAD`.
- **GREEN:** the code change in §2. Re-run this design's own simulation methodology
  (reconstruct Phase 4 twice, shipped vs. modified, from an identical snapshot) as part of GREEN
  verification, not just trust the design doc's own numbers.
- **Mandatory live chromote render check** (matching every prior Track 7 phase's own bar): both
  of the 2 moved duplicates render at >= 50px from their nearest unrelated individual's own DOM
  position, sampled through the full R → htmlwidgets → vis.js pipeline, not R-side math alone.
- **`lintr::lint_package()`** on all touched files, 0 lints (or documented `# nolint`).
- File the §6 B1-vs-individual follow-up item in `BACKLOG.md` in the same close-out, per this
  project's own "disclose, don't silently drop" convention.

---

## 8. Owner ratification record

**Ratified S658 (2026-08-30), via `AskUserQuestion` ("Yes, ratify Option B as scoped
(Recommended)").** Scope: fix only the 2 genuine duplicate-vs-unrelated-individual cases
(§2/§3); file the 4 B1-vs-individual cases as a separate follow-up item (§6), not folded into
this design. `BACKLOG.md`'s own item text corrected in the same session to replace the original
"6 duplicate-vs-individual" framing with the §1.3/§1.4 breakdown. **Status: design ratified,
implementation READY for a future session** (this was a planning-only session per
`ARCHITECTURE_WORKSTREAM.md` — no code or test changes ship here).
