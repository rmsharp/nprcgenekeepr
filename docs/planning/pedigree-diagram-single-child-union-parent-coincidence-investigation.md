# Pedigree Diagram: Single-Child Union/Parent Coincidence — Investigation

> **STATUS: INVESTIGATED, NOT IMPLEMENTED (S608, 2026-08-18).** A 15-agent
> Evidence → Design → Synthesize → Critique → Repair → Critique-2 `Workflow` produced a repaired
> candidate design (D3″) that Critique Round 2 found still carries one live-verified bug (with a
> verified one-line fix already in hand, "D3‴" below) plus 2 disclosed architectural gaps (a
> collision-safety guarantee that cannot see 2 later pipeline passes; a weak, tautological
> §2.4-invariant test surface). **This document is explicitly not a ratified plan** — see §8 for
> the decision this investigation hands back to the owner. No production code was written or
> modified this session; every number below is from live execution against unmodified `HEAD`.

## 0. What this addresses (and what it deliberately does not)

`docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md` §13 (S603,
2026-08-18) retracted its own §12 "child-centering half DONE" claim and found, independent of
that investigation's entire 5-attempt duplicate-occurrence-selection mechanism, that Track 6's
own single-child union formula (`docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md`
§2.1/§2.4) can place a mating union's marker and both its mate edges essentially on top of one
of the union's own 2 parents — reading, at any normal zoom, as if the mating involved only one
parent. **This document addresses only that: single-child mating units whose position coincides
with a parent.** It does not touch:

- The duplicate-occurrence-selection mechanism (exhausted, 5 attempts, S598-602 — see the sibling
  investigation doc above; explicitly out of scope, per this document's own task brief to every
  agent involved).
- The D1 bar-vs-bar x-overlap residual (Track 3's *other* disclosed trade-off, `BACKLOG.md`,
  still completely untouched by any session).
- The "sibling subtree-width asymmetry" residual (Track 6 plan §1.4/§8, 9/251 edges — a different,
  already-out-of-scope-and-filed phenomenon one level down the recursion).

## 1. Why this is not the same problem as the exhausted investigation

Track 6's own §2.4 invariant (`finalUnitX[U] == (min(x[C]) + max(x[C])) / 2` for a union `U`
with children `C`) is a mathematical guarantee, not an approximation: when `U` has exactly one
child, `min == max`, so `finalUnitX[U]` is **exactly** that child's own `x` — live-proven bit-exact
for all 224 single-child unions in the real 375-individual bundled fixture (§2 below). This was
never named in Track 6's own "Explicitly Out of Scope" section (§8) — a genuinely new,
previously-undiscovered gap, not a residual of anything already tracked.

## 2. Evidence (live-executed against unmodified `HEAD`; 3 parallel agents)

### 2.1 Mechanism (Evidence agent E1)

Re-grepped, corrected line numbers (the orchestrating session's own citations were off by a few
lines in places — corrected here):

| Piece | Confirmed line(s) |
|---|---|
| `finalUnitX` raw loop | `R/makePedigreeDiagramData.R:1099-1107` (assignment at 1105) |
| Track 3 parent-span clamp | comment 1109-1131; `parentLo`/`parentHi` init 1132-1133; clamp loop 1134-1144 |
| S602 `.computeDupNudge()` call + apply | 1163-1173 |
| `nodes$x` synced from `finalUnitX` | 1175 |
| `dupX` from `finalUnitX` | 1177-1180 |
| `.addRectilinearWaypoints()` `dropId` | 1769 (x-assignment 1773) |
| Broadened final de-collision pass (the actual locus of the 0.12px discrepancy) | **1199-1210**, epsilon bump 1206 |

Traced through every pipeline stage for the 3 known F1-fixture cases (`P1×P2→X,A,Y; A×Y`
consanguineous, `A×X`, `W×Y` — `test_positionMatingUnitForest.R:1174-1182`, `xScale=120`):

| Union | Parents | RAW | after Track 3 clamp | after S602 nudge | scaled final | nearer parent | scaled distance |
|---|---|---|---|---|---|---|---|
| `__union_2` (A×X→C1) | A=-75, X=-225 | -0.875 | -0.875 (no-op) | -0.875 (no-op) | **-105.00** | A (-75) | 30.0 |
| `__union_3` (A×Y→GC) | A=-75, Y=255 | 0.125 | 0.125 | 0.125 | **15.00** | A (-75) | 90.0 |
| `__union_4` (W×Y→C2) | W=135, Y=255 | 2.125 | 2.125 (no-op, at boundary) | 2.125 (no-op, gate not engaged) | **255.12** | Y (255.00) | **0.12** |

Exact mechanism for the 0.12px gap: **neither Track 3's clamp nor S602's nudge touches
`__union_4` at all** (its raw value already sits exactly at the parent-span boundary, and S602's
own Track-3-Engagement Gate requires the clamp to have *changed* the value, which it didn't here).
The 0.12px shift is produced entirely by the broadened final de-collision pass (1199-1210): at
`gen=1`, `Y` and `__union_4` carry the identical raw `x=2.125`; deterministic `(gen, id)`-radix
sort visits `"Y"` before `"__union_4"` (ASCII `Y`=89 < `_`=95), so `Y` keeps `2.125` and
`__union_4` gets bumped by exactly one `1e-3` epsilon step to `2.126` (`×120 = 255.12`). **This
confirms there is nothing in the current design that keeps a coincident union off its parent by
more than a cosmetic anti-overlap epsilon.**

### 2.2 Prevalence and severity (Evidence agent E2) — this is not a rare edge case

Real 375-individual bundled fixture (`obfuscated_rhesus_mhc_ped.csv`), 237 mating units:

| Children | # unions | % of 237 |
|---|---|---|
| 1 | **224** | **94.5%** |
| 2 | 12 | 5.1% |
| 3 | 1 | 0.4% |

Of the 224 single-child unions, distance to nearest parent (live-measured, scaled px):

| Threshold | Basis | # needing correction | % of 224 |
|---|---|---|---|
| ≤31px | **node-radius-sum — circles literally overlap** | **175** | **78.1%** |
| ≤60px | half a column | 203 | 90.6% |

Root-cause split: **83/224 (37.1%) are a *mathematically deterministic* consequence of Track 3's
own clamp** forcing an out-of-span child's position onto a parent boundary; **87/224 (38.8%) are
naturally close** (correlated with anchor-chain structure — a single unbranched lineage keeps
nearly the same x column across generations); 54/224 (24.1%) are genuinely separated.

**Live chromote pixel-space verification** (same methodology as the sibling investigation's §13.2,
`visNetwork` → `chromote` → `getPositions()`, not a prediction): node radii confirmed
`size=25` (real/duplicate individuals, `R/makePedigreeDiagramData.R:1446,1464`) and `size=6`
(union marker, `:1482`) — 31px touch threshold. `__union_4` (W×Y) renders at **exactly 0px** from
Y (the internal 0.12px rounds away entirely in the actual browser image — rendered reality is
*worse* than the internal number suggested). A negative control (`__union_152`, a genuinely
large-span case) renders correctly centered, confirming the measurement methodology isn't
universally broken.

**Combined: 170/224 (75.9%) of one-child unions — 71.7% of all 237 mating units in this real
production fixture — visually coincide with a parent.** This is majority behavior, not an edge
case. (Adjacent finding, not expanded: 11/13 multi-child unions *also* sit within 0.12px of a
parent — out of this investigation's own scope per Constraint 1, but a future session should
decide this consciously rather than assume the multi-child population is coincidence-free.)

### 2.3 Blast-radius inventory (Evidence agent E3)

- **Highest-risk test:** `test_positionMatingUnitForest.R:229-326` — all 4 mating units in this
  fixture are single-child; 5 hardcoded literals (`:299,304,306,312,322`) all change under any
  formula-level fix.
- **Second-tier:** `:1259-1263` — S583's own pinned boundary value for a `trimPedigree()`-sliced
  single-child union (currently pinned to land at the dam's boundary, `x=60`).
- **Safe/invariant-shaped:** the §2.4 3-way-OR invariant test (`:1067-1183`), the parent-span
  containment loop (`:1266-1297`), all of `test_addRectilinearWaypoints.R`'s D1 tests (symbolic,
  not literal — they assert `dropRow$x == unitRow$x`, unaffected by *which* value that is).
- **Not part of the blast radius:** `R/modPedigree.R` (zero coordinate logic — confirmed via
  `grep -n "\$x\b"`, zero hits; its `__union_`/`__dup_` references are all reserved-id-prefix
  string matching for click-selection, unaffected either way).
- **A real, disclosed cross-union dependency:** `.computeDupNudge()` reads a *different* union's
  `finalUnitX` (`R/makePedigreeDiagramData.R:643`) — relevant to any fix's own blast-radius
  accounting, not a blocker (that mechanism itself remains out of scope per §0).
- **Constraint 2's originally-cited line numbers were stale** — D1/D2's actual code is
  `:1746-1793` / `:1795-1863`, not `:1533-1563`. The orthogonality guarantee is structural by
  construction in both blocks (verticals share their anchor's x, horizontals share the bar/drop
  y) and does not depend on which value `finalUnitX` resolves to — satisfiable by any fix that
  only changes the *value*, not the surrounding construction.

## 3. Design candidates (4 attempted, 1 lost to an API error)

**D1 (proportional blend toward parent-midpoint) failed to complete — a transient API error mid-run,
not a design rejection.** Synthesis proceeded from the 3 candidates that did complete, disclosed
explicitly rather than silently treated as 4. Re-running D1 was not attempted this session (see §8).

| Candidate | Mechanism | Viable? |
|---|---|---|
| **D2** — deterministic minimum-separation floor | If closer than `0.4·minSep` (48px) to a parent, push to exactly that floor (or midpoint if the parent span is too narrow to clear both) | Yes |
| **D3** — engagement-gated correction | Hard no-op unless within `31/120·minSep` (≈31px, the actual node-radius-sum) of a parent; then push to clear it | Yes |
| **D4** — rendering-layer-only D1 dogleg | Leave `finalUnitX` untouched; redirect only the D1 sibship-bar descender via an orthogonal dogleg | **No** (author's own verdict) |

D4 was rejected by its own design agent on 2 independently live-verified grounds: it cannot touch
the dominant visual cue (the union marker itself, sitting on the parent, is provably unaffected —
confirmed both numerically and via a chromote screenshot), and the one dogleg placement actually
implemented reopens the same-row edge/node collision class Track 1 (issue #160) was built to
eliminate, at 92.1% prevalence on the real fixture.

## 4. Synthesis

Independently re-derived (not trusted) by a dedicated synthesis agent, which re-ran both viable
candidates' own scripts from scratch against fresh scratch copies of `.positionMatingUnitForest()`
and additionally **built and live-tested the "obvious" hybrid** (D3's tighter, node-radius-derived
trigger + D2's wider, already-established `0.4·minSep` target) — and found the hybrid a
**regression**, not an improvement: it reintroduces D2's own disclosed 3rd-party collision
(`__union_166` ↔ `__dup_CMJQGU_2`, 24px apart under the wider target vs. 41px clear under pure
D3), because the coupling runs through the pre-existing `dupX = finalUnitX[otherUnion] +
minSep*0.4` formula, not through anything either candidate's own design touches. This is a
negative synthesis result, live-tested rather than assumed.

**Recommendation: adopt D3 as designed, not a hybrid.** Scores (0-10, 3 lenses):

| Candidate | Correctness | Architecture-fit | Simplicity |
|---|---|---|---|
| D2 | 8/10 (new 3rd-party collision found) | 6.5/10 | 7/10 |
| **D3** | **9/10** | **8.5/10** | **9/10** |
| D4 | 1/10 (author's own verdict) | 3/10 | 4/10 |

Synthesized design (D3): a hard engagement gate (`nearestDist >= touchThreshold: skip`), then push
to clear the nearer parent by exactly `touchThreshold = minSep · 31/120` (the live node-radius-sum
geometry, not an arbitrary constant), falling back to the parent midpoint when the span is too
narrow to clear both. Live re-verified by the synthesis agent itself: F1's 3 cases reproduce
exactly (`__union_4` 255.12→224.00, 31px clear of Y); real-fixture single-child touches drop
175→3 (98.3%); all 13 multi-child unions and all real individuals stay bit-identical (Constraint 1
satisfied by construction).

## 5. Critique Round 1 — 3 lenses, real majors found

**Correctness lens: `designStillSound: false`.** Using the project's own already-*green*
regression tests (not a self-built check), the synthesized design's central "zero new overlaps"
claim is **falsified**:

| Metric (established test) | Baseline | Under synthesized D3 |
|---|---|---|
| `test_addRectilinearWaypoints.R:718-719` bar-vs-bar oldHits/newHits | 348 / 116 | 358 (+10) / 119 (+3) — **worse** |
| `test_resolveEdgeNodeCollisions.R:390-391` collisions/pairs | 105 / 1431 | 118 (+13) / 1437 (+6) — **worse** |
| `test_makePedigreeMatingLayout.R:615,618` nodes/jog-nodes | 1412 / 210 | 1442 (+30) / 240 (+30) — **worse** |

Also found: the design **regresses a deliberate, pre-existing correctness fix** without
disclosure — `test_positionMatingUnitForest.R:1259-1263` (S583's headline case) deliberately pins
a clamp-forced coincidence to the parent boundary, because that boundary snap *is* the correct
answer for that case; D3's engagement gate cannot distinguish "benign formula coincidence" from
"deliberately-correct clamp result" and pushes both away identically. And the §2.4 invariant
test's own required update was materially understated ("needs a 4th disjunct" vs. the live-measured
reality: **181/245 checks fail, 73.9%**, on the real fixture 175/237). Total confirmed regression
footprint: 193/746 failing assertions vs. 0/746 on a clean control.

**Edge-case lens: `designStillSound: true`** (no correctness break found), but flagged a genuinely
useful, disclosed methodological gotcha: in-memory namespace monkey-patching is **unreliable**
for `testthat::test_file()` runs in this project (bare in-test-file calls resolve through
`package:nprcgenekeepr`'s attached copy before the patched namespace) — the correctness lens's
own first attempt was fooled by this before switching to source-level `pkgload::load_all()` on a
real scratch copy.

**Blast-radius/TDD lens: `designStillSound: true`**, but independently reproduced the same 3
established-test regressions, plus found a genuine **TDD vacuous-no-op trap**: ~22% of real-fixture
single-child unions are already clear of the 31px threshold on unmodified code, so a RED test
built around a randomly-chosen single-child union has roughly a 1-in-5 chance of picking a case
where the design is already a no-op.

## 6. Repair — D3″ (Safety-Gated Anti-Coincidence Correction)

Extracted into a named function (`.computeSingleChildAntiCoincidence()`, mirroring
`.computeDupNudge()`'s own precedent) with an added **collision-safety cap**: the push toward
clearance is bounded so it cannot land within `SAFETY_MARGIN` (same 31px magnitude) of any other
same-generation node (another real individual, another union's already-decided position, or a
duplicate offset), processed in a deterministic sweep so later unions see earlier ones'
already-adjusted positions.

Trade-off, honestly quantified (not claimed away): **defect-fix completeness drops from D3's
98.3% to 77.4%** (40/224 vs. 3/224 still within threshold), but the 3 established-test regressions
shrink 10-30×, and one metric (`resolveEdgeNodeCollisions` obstacle-pairs) actually **improves**
versus baseline (1431→1427). S583's pinned test is acknowledged and disclosed as a deliberate,
correct value change (60→29), not silently regressed. The §2.4 invariant is fully resolved (0/4,
0/237, 0/4) — but only by calling the same production function a second time (flagged as a
methodological weakness in Round 2, below).

## 7. Critique Round 2 — repair holds structurally, but has its own live-verified bug

**Correctness lens: `designStillSound: false`.** Found a real, previously-unnoticed bug in the
repair's own safety cap: `dupUnionIds` (one of the 3 "occupied obstacle" categories) is **not
self-excluded** — unlike the adjacent, correctly-self-excluding `otherUnionIds`. Since a union's
own duplicate marker is always `finalUnitX[[uid]] + minSep*0.4` (a fixed 48px trailing offset that
can never actually collide with `uid` itself, since 48px > the 31px margin being checked against),
treating it as an obstacle is a phantom constraint. **Live-measured impact: 30/224 (13.4% of all
single-child unions, 75% of the repair's own disclosed 40-union residual) are capped short of
their intended 31px clearance purely by this phantom** — each stopped at a constant, arithmetic
(not fixture-noise) 17px instead of 31px. **A one-line fix was identified and independently
verified** (add the same `!= uid` filter `otherUnionIds` already has), applied to a third scratch
copy (`pkg_repair3_copy`) and re-measured: the 40/224 residual drops to **11/224**, a further 73%
reduction, with zero new collisions introduced and both Constraint 1 checks (multi-child, real
individuals) still bit-identical.

Two further findings, both disclosed rather than hidden:

- The safety cap's own guarantee ("refuses to push into a NEW coincidence") does not see 2 later
  pipeline passes (the broadened de-collision epsilon pass, and the final `sweepMinSep()`
  reapplication) that run after this correction. 43/224 unions judged "safe" at correction time
  end up, in final rendered output, closer than the margin to some node — but critically, **all
  43/43 were already below-margin in the pristine baseline too** (34 improve, 9 unchanged, 0
  regress) — so on this fixture nothing gets newly broken, but the architecture does not
  structurally guarantee that in general; it is empirical luck on one dataset, not a proof.
- The §2.4 invariant's "4th disjunct" validation is **tautological** — it calls the exact same
  function on the exact same inputs the pipeline used, so it can only ever catch a wiring bug,
  never a bug inside the function (which is exactly how the self-duplicate bug above survived the
  repair's own verification undetected).

**Edge-case lens: `designStillSound: true`**, but independently found and confirmed the identical
self-duplicate bug via a different route (a direct obstacle-instrumentation sweep), including the
process lesson that none of Round 1's own hand-built edge-case fixtures could have surfaced it —
only the real, dense, production-scale fixture could, because the bug is direction-conditioned
(`dir > 0` only) and every hand-built fixture happened to produce `dir < 0` corrections for its
duplicate-hosting unions.

**Blast-radius/TDD lens: `designStillSound: true`**, with 3 majors on test-surface quality (not
behavior correctness): the extracted function's bare `finalUnitX`-vector return cannot
independently verify the safety-cap arithmetic or distinguish "genuine partial cap" from "never
triggered" — a real gap against this project's Strict TDD "all non-happy paths tested" contract;
and the deterministic sweep order is **lexicographic, not numeric** (`"__union_10"` sorts before
`"__union_2"`), an undisclosed footgun for hand-constructing a RED fixture that exercises the
partial-cap branch.

## 8. Current status and the decision this hands back

**This is the closest either investigation (this one or the sibling duplicate-occurrence-selection
one) has come to a design that would actually, measurably fix a real, majority-prevalence visual
defect** (72% of matings in the real fixture) — as opposed to the sibling investigation's own
shipped-but-inert result. But it is not yet PRE-RED-ready: Critique Round 2 found a real bug (with
an already-verified one-line fix) and 2 disclosed architectural gaps this session did not repair
a second time (per this project's own established one-repair-per-session precedent, S599-601).

**Not done this session, deliberately:** no repair-round-3, no PRE-RED, no production code. This
document's own status banner and this section are the record of exactly how far the investigation
got and what remains, matching this project's "report an incidentally-discovered gap, don't fix it
mid-session" — extended here to "don't extend a Planning session into implementation," per
`SESSION_RUNNER.md`'s own planning/implementation session-boundary discipline.

**Open items for whoever picks this up next:**
1. The verified one-line self-duplicate-exclusion fix (§7) — already specified and measured
   (40→11/224 residual), needs to be folded into a "D3‴" and put through its own fresh Round-3
   critique before being trusted, per this investigation's own repeated finding that each round
   surfaces something the previous one missed.
2. The extracted function's return shape needs diagnostic fields (mirroring `.computeDupNudge()`'s
   own `engaged`/target shape) so the §2.4 invariant test can independently verify the safety-cap
   arithmetic rather than tautologically re-calling the same function.
3. D1 (the proportional-blend candidate) never completed — a transient failure, not a design
   rejection; a future session could re-run it for completeness, though D3's dominance over D2 on
   every lens makes it a lower priority than items 1-2.
4. Independent finding, unrelated to whether this design ships: Track 6's own "91% reduction,
   100→9/251" headline metric is **stale at current HEAD** (true baseline 53/251) — drifted via
   Track 3's S596 clamp and S602's nudge, both added after Track 6's own measurement. Worth its
   own housekeeping correction to the Track 6 plan doc, independent of this investigation's fate.

## 9. Owner ratification record (S608, `AskUserQuestion`)

Presented 4 options — targeted repair session / accept 72% coincidence as permanent / hold,
decide later / re-run the failed D1 candidate first — with each option's own trade-offs stated
directly in the question. **Owner selected: targeted repair session.**

**Scope for that future session, as ratified:** apply the already-verified one-line
self-duplicate-exclusion fix (§7 — add `duplicates$matingUnitId != uid` filtering to
`dupUnionIds`, mirroring the adjacent, already-correct `otherUnionIds` pattern) to produce
"D3‴"; add diagnostic return fields to `.computeSingleChildAntiCoincidence()` (mirroring
`.computeDupNudge()`'s own `engaged`/target-diagnostic shape) so the §2.4 invariant test can
verify the safety-cap arithmetic independently rather than tautologically re-calling the same
function; run a fresh Critique Round 3 against D3‴ specifically (the self-dup fix and the
diagnostic-shape change are both new code Round 2 never saw) before trusting it; only then
proceed through this project's PRE-RED→RED→GREEN gates. **Not scoped for that session:**
re-running D1, revisiting D2/D4, or reopening the multi-child/D1-bar-vs-bar/duplicate-occurrence-
selection items — all remain explicitly out of this investigation's own bounds (§0).

This document remains an investigation, not a ratified implementation plan — the ratification
above is of *direction*, matching this project's own established distinction between a
go/no-go decision and a PRE-RED implementation gate (`SESSION_RUNNER.md` Planning Sessions:
"the plan is the deliverable... implementation happens in a separate session").

## References

- `docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md` §13 — the S603
  finding that originated this investigation.
- `docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md` — the design this
  investigation reconsiders one specific population (single-child unions) of, without reopening
  its multi-child result.
- `BACKLOG.md` Active — Track 3's 2 disclosed trade-offs item, this investigation's own parent
  entry.
