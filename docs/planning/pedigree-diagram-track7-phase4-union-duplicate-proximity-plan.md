# Track 7 Phase 4: union-vs-duplicate proximity fix

**Status: DESIGN RATIFIED (S654, 2026-08-30, via `AskUserQuestion`).** Continues `docs/planning/pedigree-diagram-track7-mate-spacing-plan.md` §12 (Phase 2, S648/S649) and its scoped revert, `docs/planning/pedigree-diagram-track7-phase3-child-centering-plan.md` (Phase 3, S651/S652). Follows `ARCHITECTURE_WORKSTREAM.md`, matching this project's own established precedent that every touch to `.positionMatingUnitForest()` (Tracks 1–6, the Walker/BJL migration, Track 7 Phases 1–3) goes through a dedicated, owner-ratified design session before implementation. **Implementation is a separate future session.**

**Owner ratification record:** presented 3 options via `AskUserQuestion` — (A) ratify Option A as scoped (§2's recommendation: duplicate-side, post-hoc, unidirectional push), (B) ratify Option B instead (§4's alternative: the union-sweep-side, look-backward approach `BACKLOG.md` originally sketched, adversarially confirmed incomplete — resolves only 2/3 cases, §9), (C) hold/discuss further. **The owner picked Option A, as recommended.** The decision rested on §9's own adversarially-re-verified numeric evidence (a corrected 3-agent workflow, after a first pass's worktree-isolation artifact — a stale base commit, §9 — was caught and re-run pinned to the exact commit): Option A resolves all 3 known cases with 0 unexpected collateral; Option B leaves 1 of 3 permanently unresolved by construction. **Ready for a Phase 4 implementation session** (TDD-gated RED/GREEN/REFACTOR, per this project's Development Process Contract), following §2's decision, §5's impact analysis, and §6/§7's migration/verification plans above.

Fixes the disclosed, narrower trade-off Phase 2 shipped with (`BACKLOG.md` Housekeeping, found S649, composition updated S652): 3/237 mating-union dots on the real 375-individual fixture now sit visually too close to an unrelated duplicate node. The Track B fixture the owner personally reviewed has no duplicates in play and is unaffected either way (plan §12.11).

---

## 1. Context

### 1.1 Problem statement

Track 7 Phase 2 (S649) added a capped bidirectional push that moves a mating-union dot away from any unrelated individual or union it lands too close to. Its own occupied-set has no visibility into duplicate-node positions, because a duplicate's `x` is computed strictly *after* the entire union sweep finishes (plan §12.7/§12.11, already disclosed as a genuine data dependency, not an oversight). The result: Phase 2 fully resolved the 20 individual-/union-vs-union proximity cases it targeted, but introduced a new class of residual — a union landing close enough to a duplicate node (belonging to a *different*, unrelated mating unit) that the two visually overlap.

### 1.2 Current numbers (re-measured live against `HEAD`, commit `2e3a05b2` — never taken on the plan doc's own prior word)

Real 375-individual bundled fixture (`obfuscated_rhesus_mhc_ped.csv`), via the exact counting method `tests/testthat/test_positionMatingUnitForest.R:1223-1275` already uses (a union's own nearest same-generation neighbor, excluding its own anchor/non-anchor, checked against the appropriate radius-proportionate clearance for that neighbor's kind):

| Union | x | Colliding duplicate | Duplicate's real individual | Owning union | Owning union's x | Distance | Threshold |
|---|---|---|---|---|---|---|---|
| `__union_14` (gen 0, sweep-order #6) | 11.0010 | `__dup_L31S6S_3` | L31S6S | `__union_47` (sweep-order #42) | 10.5167 | 0.0843 | 0.2583 |
| `__union_43` (gen 0, sweep-order #38) | 13.0010 | `__dup_WDBGPF_2` | WDBGPF | `__union_36` (sweep-order #30) | 12.5167 | 0.0843 | 0.2583 |
| `__union_126` (gen 2, sweep-order #126) | 47.3760 | `__dup_YPHFHF_1` | YPHFHF | `__union_108` (sweep-order #108) | 46.8917 | 0.0843 | 0.2583 |

All 3 confirm `PROJECT_LEARNINGS.md`'s own load-bearing point about the S652 revert (BACKLOG.md): the composition shifted from 4 (pre-S652) to 3 (post-S652), and remains 3 on the current `HEAD`. **The offending pair is not symmetric in sweep order**: 2 of 3 cases have the duplicate's owning union placed *before* the colliding union in the sweep; 1 case (`__union_14`/`__union_47`) has the owning union placed *after*. This asymmetry is structurally important — see §4.

### 1.3 What is already decided (do not re-litigate)

- **Union side only, radius-proportionate clearance, capped bidirectional search** — Phase 2's own core mechanism (§12.2, ratified S648) — is not reopened here.
- **Alternative D (fully symmetric individual-side hardening — `.deCollideIndividualPoints()` gains general `unionOccupied` visibility for *every* individual point)** was considered and rejected in Phase 2's own design (§12.4) as disproportionate blast radius for a cosmetic dot-adjacency problem. This document does not reopen that decision (see §4 for why this document's own recommendation is narrower than, and does not resurrect, Alternative D).
- **The `__jog_*` waypoint invisible-styling gap** (`BACKLOG.md` Housekeeping, found S648) is a separate, unrelated rendering-layer defect, already filed, not addressed here.

### 1.4 A second, unrelated residual found incidentally during this session's own grounding work (not fixed here)

While measuring §1.2 above, a duplicate-vs-*individual* (not union) near-miss check surfaced **6 pre-existing cases**, present on unmodified `HEAD`, that have nothing to do with Phase 2's own union-side mechanism and are **unaffected by either fix direction evaluated below**:

`__dup_MY1AEU_2` (0.0990 from TTE0Z7), `__dup_1X40V5_2` (0.1000 from 0Q077X), `__dup_7NBKWE_3` (0.1000 from IM1B5T), `__dup_L31S6S_5` (0.1000 from M0YNUR), `__dup_M5DJVP_1` (0.1000 from 45YQV5), `__dup_KCBMY9_2` (0.1000 from 665C2Y) — all measured against the `unionClearanceIndividual` (0.2583) threshold used here as a "visually close enough to matter" proxy, not a claim that this is the correctly-calibrated threshold for two full-size (25px-radius) nodes (a proper individual-vs-individual clearance would be `(25+25)/120 = 0.4167`, wider still). `.deCollideIndividualPoints()`'s own de-collision push only fires on an *exact* tie (`< 1e-9`); it has no near-miss radius check at all for individual/duplicate-shaped points, unlike the union-side mechanism Phase 2 added. **Not investigated or fixed in this document's own scope** — filed as a new `BACKLOG.md` Housekeeping item at ratification (see §8).

---

## 2. Decision

**Recommended: push the DUPLICATE away from the union, post-hoc, unidirectionally, in the same rightward (`+minSep*0.4`-relative) direction `derivedX()`'s B3 branch already always uses.**

Concretely (implementing session's own exact mechanism, subject to its own TDD RED/GREEN): immediately after the existing duplicate positioning + de-collision block (`R/makePedigreeDiagramData.R:1098-1111`), for each duplicate whose position now collides with an unrelated union at the same generation (radius-proportionate clearance, `unionClearanceIndividual`, matching Phase 2's own threshold), search `+k * unionClearanceIndividual` for `k = 1 .. .kMaxUnionPush` (reusing Phase 2's own cap, not inventing a new one) and take the first non-colliding candidate; fall back to the raw (uncapped-search) value if the cap is exhausted, matching every other capped search in this function.

This is a **duplicate-side, post-sweep, order-independent fix** — it runs after both the union sweep AND the duplicate positions are finalized, so it has full information and does not depend on sweep order at all (contrast §4's rejected alternative, which is order-dependent and provably incomplete).

---

## 3. Rationale

### 3.1 Why the duplicate side, not the union side

BACKLOG.md's own sketch (found S652) proposed tracking a prospective duplicate offset as an occupied-set member *during the union sweep* — moving the union, not the duplicate, to avoid the future collision. This document evaluated that direction empirically (§4) and found it **structurally incomplete**: a single forward sweep can only see a duplicate belonging to an *already-placed* union. Of the 3 real cases, 1 (`__union_14` vs. `__dup_L31S6S_3`) has its offending duplicate's owning union (`__union_47`) placed *later* in the same generation's sweep order — invisible to a look-backward-only occupied-set by construction, not by omission. A full fix on the union side would need either a second (reverse) pass or an iterate-to-fixed-point loop — real added complexity for a mechanism Phase 2's own design already kept intentionally simple (capped, single-direction search).

Operating on the duplicate side instead sidesteps the ordering problem entirely: by the time duplicates are positioned, **every** union's final `x` is already known, so there is no "not yet placed" case to miss. This also matches this project's established preference for the **narrowest blast radius that resolves the evidence** (§12.2's own rationale for Option A over Option B): a duplicate node carries no `__drop_`/`__bar_` waypoint of its own (only a real mating unit does — see §5), so moving one has no D1 sibship-bar-geometry side effect, unlike moving a union (Phase 1/2's own repeatedly-hit source of collateral iterations).

### 3.2 Why this is not a re-opening of Alternative D

Alternative D (Phase 2 §12.4, rejected) proposed making `.deCollideIndividualPoints()` — the shared machinery for *both* B1 free-pass individuals and B3 duplicates — aware of `unionOccupied` in general, for every individual-shaped point. This document's recommendation is narrower on two axes: (a) it applies only to duplicates (B3), never to B1 free-pass individuals or genuine Tier-1 individuals, and (b) it is a separate, dedicated post-pass, not a change to the shared `.deCollideIndividualPoints()` function's own general-purpose occupied-set. Nothing here reopens Phase 2's rejection of general individual-side hardening.

### 3.3 A documented false start (unidirectional, not bidirectional)

An initial spike used a bidirectional search (mirroring Phase 2's own union-side mechanism exactly). Live measurement found this creates a **new** collision on all 3 cases: the "away from the colliding union" direction happened, in every case, to be *toward* the duplicate's own owning union — landing it newly within 0.1417 raw units of the union it is deliberately supposed to sit near (`minSep*0.4 = 0.4` by design). Corrected to unidirectional (always `+k*unionClearanceIndividual`, matching `derivedX()`'s own always-rightward B3 convention) — re-measured clean, §5.

---

## 4. Alternatives Considered

| Alternative | Pros | Cons | Why rejected/deferred |
|---|---|---|---|
| **A. RECOMMENDED — duplicate-side post-pass, unidirectional, radius-proportionate (§2)** | Order-independent (full information available); no D1 sibship-bar interaction (duplicates own no waypoint); reuses Phase 2's own cap and threshold constants; resolves all 3 known cases (empirically confirmed, §5) | Adds a second push mechanism (duplicate-side) alongside Phase 2's existing union-side one — 2 places instead of 1 | — (this is the recommendation) |
| **B. Union-side prospective-duplicate-offset in the sweep's occupied-set (BACKLOG.md's own literal sketch)** | Single mechanism, extends Phase 2's existing sweep rather than adding a new pass | **Empirically confirmed incomplete**: resolves only 2/3 real cases — the 1 case whose owning union sorts *after* the colliding union in the same-gen sweep order is structurally invisible to a single forward pass (§3.1). Would need a second pass or fixed-point iteration to close the gap, real added complexity | **Rejected** — incomplete by construction, not a coding gap; the fix that closes it is no simpler than Option A |
| **C. Bidirectional duplicate-side push (first-drafted, not ratified)** | Mirrors Phase 2's own union-side mechanism byte-for-byte | **Empirically confirmed broken**: on all 3 real cases, the escape direction lands the duplicate newly-too-close to its OWN owning union (§3.3) | **Rejected** — a live measurement finding, not a hypothetical risk |
| **D. Symmetric individual-side hardening (Phase 2's own Alternative D, §12.4)** | Fully general — would also resolve the incidentally-found duplicate-vs-individual near-misses (§1.4) | Reopens a mechanism Phase 2 already rejected as disproportionate for a cosmetic dot-adjacency problem; blast radius far exceeds what the 3 known cases need | **Deferred, not resurrected** — Option A alone resolves every currently-known union-vs-duplicate case; revisit only if a future measurement finds a case Option A cannot reach |
| **E. Accept as a permanent, disclosed limitation (no fix)** | Zero implementation cost or risk | 3/237 is a small but real, disclosed visual defect on the same class of colony data the owner has already flagged fidelity issues in; Track 7 Phase 1/2/3 all treated comparable residuals as worth closing when a scoped, low-risk fix existed | **Rejected** — Option A's own cost/risk profile (§6) is low enough that "accept" is not the better trade-off here, unlike Phase 3's genuinely-forced binary (§2.4 of that document) |

---

## 5. Impact Analysis

### 5.1 What changes

- `R/makePedigreeDiagramData.R`, immediately after the existing duplicate-positioning block (currently `:1098-1111`): a new post-pass, scoped to duplicate nodes only.
- 5 pinned test assertions across 3 files need live re-measurement (§5.3) — normal maintenance for this class of change, matching every prior Track 7 phase.
- `NEWS.Rmd`: one plain-language bullet in the Pedigree Diagram group (this is now the **second** missing Phase-2-adjacent entry — S649's own Phase 2 bullet is also still outstanding, `BACKLOG.md` Housekeeping — the implementing session should add both, in true shipping order).

### 5.2 What does not change

- The union sweep itself (`:1009-1096`) — untouched; Option A operates entirely after it.
- `.deCollideIndividualPoints()` — untouched; not reused, not modified (contrast Alternative D).
- B1 free-pass individual positions, genuine Tier-1 individual positions, union-vs-union and union-vs-individual proximity (Phase 2's own already-resolved 20 cases) — no interaction, confirmed empirically (§5.4).
- The Track B shrunk fixture (the owner's own directly-reviewed fixture) — has zero duplicates in play (plan §12.11); unaffected either way.

### 5.3 Consumer / test inventory (grep-based, per `SESSION_RUNNER.md`'s evidence-based inventory requirement)

| File:line | Current value | Measured under Option A | Note |
|---|---|---|---|
| `test_positionMatingUnitForest.R:1274` | `expect_equal(unname(counts["duplicate"]), 3L)` | **0L** | The residual this document exists to close |
| `test_makePedigreeMatingLayout.R:651` | `expect_equal(nrow(result$nodes), 1450L)` | **1456L** (+6) | 6 new `__jog_` waypoints from the 3 newly-repaired same-row collisions (2 waypoints per repaired edge) |
| `test_makePedigreeMatingLayout.R:658` | `expect_equal(sum(grepl("^__jog_", ...)), 192L)` | **198L** (+6) | Same cause as above |
| `test_resolveEdgeNodeCollisions.R:433` | `expect_equal(nrow(baselineEdges), 95L)` | **98L** (+3) | Pre-jog-repair baseline; moving 3 duplicates introduces 3 new same-row obstacle edges, fully absorbed by the existing (unchanged) jog-repair mechanism — confirmed 0 residual beyond it, §5.4 |
| `test_resolveEdgeNodeCollisions.R:434` | `expect_equal(nrow(baseline), 1759L)` | **1762L** (+3) | Obstacle-pair count, same cause |

Grepped `vignettes/`, `NEWS.Rmd`, and `docs/planning/` for these exact counts (1,450 / 192 / 95 / 1,759) — no documentation cites them outside these 5 test assertions.

### 5.4 What might break (risk assessment) — empirically measured, not estimated

A full spike (backed up via `cp` first; `shasum`-confirmed byte-identical to `HEAD` after every restore, matching §12.9's own established discipline) was run against the real 375-individual fixture and the full `test_positionMatingUnitForest.R` (54 `test_that()` blocks), `test_addRectilinearWaypoints.R` (102 assertions), and `test_resolveEdgeNodeCollisions.R` (37 assertions) files:

- **All 3 known union-vs-duplicate cases resolve to 0 residual** (§1.2's counting method, re-run against the spike).
- **0 unexpected collateral** — every failing assertion is exactly one of the 5 in §5.3; nothing else in any of the 3 test files regressed.
- **The 3 new pre-jog same-row collisions (§5.3) are fully absorbed by the existing, unchanged jog-repair mechanism**: post-repair, `.resolveEdgeNodeCollisions()`'s own `residuals` data frame contains exactly **47** rows, every one `kind == "curved-heuristic"` — the same pre-existing, unrelated curved-duplicate-connector residual this project's own history already documents as "unaffected throughout" across Track 7 Phase 1/2/3. **0 new unresolved residual of any kind.**
- **No new exact-tie collision anywhere** — confirmed via the full regression run, not assumed.
- **§1.4's 6 pre-existing duplicate-vs-individual near-misses are completely unaffected** (identical positions/distances measured with and without the spike) — Option A only ever touches a duplicate that collides with a *union*, never one that is merely near another individual.

Residual risk carried into implementation: the empirical push-direction bug found in §3.3 (Alternative C) shows this exact mechanism has already surprised a first-draft attempt once; the implementing session should re-run this same live-measurement discipline in its own GREEN phase rather than trusting this document's numbers as a substitute (matching every prior Track 7 phase's own "measure live, never assume" practice, e.g. Phase 1's 3 iterations, Phase 2's 2 GREEN-phase corrections).

---

## 6. Migration Path (for the implementing session)

1. **Pre-RED**: re-run this document's own §1.2/§5.4 measurements live against the implementation's working tree — confirm nothing drifted since this document was written.
2. **RED**: update the 5 pinned assertions in §5.3 to their measured Option-A values (all 5 confirmed genuinely failing against unmodified `HEAD` first — the standard "confirm real RED" discipline); add a new assertion reproducing this document's own §1.2 findings directly (the 3 named union/duplicate pairs, or the general "0 union-vs-duplicate residual" count).
3. **GREEN**: implement §2's post-pass. Re-run the full regression suite; confirm §5.3's 5 values land exactly as measured, 0 other regressions.
4. **Mandatory live-render check** (matching §12.6/this project's own established bar for any change to this function): confirm via `chromote` that all 3 previously-colliding duplicates now render as visually distinct from their formerly-adjacent union, and that the 3 newly-jogged edges route sensibly (no new visual artifact).
5. `NEWS.Rmd`: add both this fix's own bullet AND S649's still-missing Phase 2 bullet (`BACKLOG.md` Housekeeping), in true shipping order.
6. File `BACKLOG.md` Housekeeping item for §1.4's 6 pre-existing duplicate-vs-individual near-misses (do not fix in this same session — out of this document's own scope).
7. `lintr::lint_package()` (loaded first, per this project's established methodology).

---

## 7. Verification Plan

Reusing this project's own established methodology for this exact function (matching Track 7 Phase 1/2/3's own precedent — a future implementing session should not invent a new approach):

1. Pre-RED empirical re-validation (§6 step 1).
2. Full clean regression — 0 new failures/errors beyond §5.3's 5 known, budgeted-for pinned-value updates and the pre-existing, unrelated `test_wordlist_coverage.R` baseline.
3. **Mandatory live-render check** (§6 step 4) — not optional, matching this project's own standing bar for any change touching `.positionMatingUnitForest()`'s output.
4. Confirm `.resolveEdgeNodeCollisions()`'s own `residuals` data frame contains only the pre-existing 47 `curved-heuristic` rows post-fix — 0 residual of any other kind (reproducing §5.4 directly, not assuming this document's numbers still hold).
5. `lintr::lint_package()` (loaded first).
6. `NEWS.Rmd` entries (§6 step 5), `CLAUDE.md` checklist.

---

## 8. Explicitly Out of Scope (report, don't fix here)

- **§1.4's 6 pre-existing duplicate-vs-individual near-misses** — a separate, unrelated residual class this session's own grounding work incidentally surfaced. To be filed as a new `BACKLOG.md` Housekeeping item at ratification, not fixed by this document's own implementation.
- **S649's own still-missing `NEWS.Rmd` entry for Phase 2** (`BACKLOG.md` Housekeeping, found S650) — the implementing session should add it alongside this fix's own entry (§6 step 5), but it is a pre-existing gap, not created by this document.
- **The `NEWS.Rmd` dangling sibling-consanguineous-mating bullet question** (`BACKLOG.md` Housekeeping, found S652) and **the Track C table discrepancy** (`BACKLOG.md` Housekeeping, found S645) — unrelated Housekeeping items from the same standing pedigree-fidelity cluster; not addressed here.

---

## 9. Post-draft adversarial verification (this session)

Matching §12.8's own established practice: before presenting this document for ratification, a
3-agent adversarial-verification workflow independently re-derived every quantitative claim above
— own scripts, own git worktree, not copying this document's own scratch scripts.

**First pass found a real methodology gap, corrected before re-running:** the first run's
worktree-isolated agents checked out a stale base commit (5 commits behind, predating the S652
revert) without an explicit pin — one agent's "baseline" measurement came back self-consistently
wrong (4 cases, not 3, matching that *older* commit's own then-current pinned test value) purely
because it was measuring different code, not because the claim itself was wrong. The other 2
agents failed outright on a transient network error. Re-run with each agent instructed to
explicitly `git checkout` this session's exact commit (`2e3a05b2`) and verify the SHA before
measuring anything.

**Second pass — all 3 agents CONFIRMED, independently, on the correct commit:**

- **§1.2 baseline**: the residual is exactly 3, the 3 pairs are exactly as named, and exactly 1 of
  the 3 (`__union_14`/`__dup_L31S6S_3`) has its duplicate's owning union placed *after* it in
  sweep order — reproduced by an independently-written script re-implementing the test's own
  counting method from a fresh reading of `test_positionMatingUnitForest.R:1223-1275`, not by
  running this document's own script or trusting its prose.
- **§2/§5.4 (Option A, recommended)**: an independently-implemented version of the unidirectional
  duplicate-side post-pass resolved all 3 cases to 0, produced exactly the 5 predicted test
  failures (§5.3) with exactly the predicted expected-vs-actual numbers, 0 other regressions
  across all 4 relevant test files, and exactly 47 `curved-heuristic`-only residual rows after
  jog-repair — matching this document's own numbers exactly.
- **§4 (Option B, BACKLOG's literal wording)**: an independently-implemented version of the
  look-backward union-sweep-side alternative resolved exactly 2 of 3 cases, leaving exactly
  `__union_14`/`__dup_L31S6S_3` unresolved for exactly the claimed structural reason (its owning
  union sorts after it in the same-generation sweep) — confirming §4's incompleteness claim is a
  real structural property of the ordering, not an artifact of this document's own particular
  implementation.

**0 discrepancies survived on the corrected commit.** Every file each agent temporarily modified
was confirmed restored to the committed content via `sha256`/`git status`/`git diff` before that
agent finished — matching this project's own established spike discipline.

---

## References

- `docs/planning/pedigree-diagram-track7-mate-spacing-plan.md` §12 (Phase 2 design and ratification, S648) and §12.11 (Phase 2 implementation findings, S649 — first documented this exact residual).
- `docs/planning/pedigree-diagram-track7-phase3-child-centering-plan.md` (Phase 3, the scoped revert that changed this residual's composition from 4 to 3, S651/S652).
- `BACKLOG.md` Housekeeping — "Track 7 Phase 2's own union-side proximity push (S649) introduces union-vs-DUPLICATE proximity cases" (this document's own subject).
- `R/makePedigreeDiagramData.R:790-818` (`derivedX()`/`qualifies()`/`b1AnchorRelativeX()`), `:866-940` (`.deCollideIndividualPoints()`), `:1009-1111` (the union sweep and duplicate-positioning blocks this document's own fix sits adjacent to).
- `tests/testthat/test_positionMatingUnitForest.R:1223-1275` (the union-vs-{individual,union,duplicate} counting method this document reuses verbatim for its own §1.2 measurement).
