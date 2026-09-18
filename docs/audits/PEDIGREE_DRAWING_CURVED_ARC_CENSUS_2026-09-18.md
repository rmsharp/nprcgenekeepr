# Curved duplicate-connector arc census — replacing the 1,668-chord upper bound (S714, 2026-09-18)

**Scope:** every curved duplicate-connector edge the current engine draws, across all 7
census fixtures (Track B full/shrunk, Track C, Real 375, D1–D3) — 173 curved edges
total (170 Real 375 + 3 Track C; the other fixtures have no duplicates).
**Criterion:** does the arc vis-network actually paints pass strictly inside the disc
of a visible node that is neither an endpoint nor graph-adjacent to an endpoint —
the same disc-and-exclusion convention every other class-(c) census predicate uses.
**Coverage:** 173 of 173 curved edges, against every visible node of their layouts
(same-row AND cross-row; the retired chord heuristic only ever saw same-row).
**Finding counts:** 587 arc-inside-symbol events on 117 distinct arcs, all on
Real 375; Track C is arc-clean (its single chord-flagged row is a false positive).

Produced by the S714 measurement pass for the `BACKLOG.md` item "Census curved-chord
heuristic: arc-modelling measurement pass (1,668 findings, upper bound)" (itemized
S699). The reproducible measurement now lives in
`data-raw/pedigreeDrawingErrorCensus.R` (subclass `c-arc-inside`, scoreboard columns
`cArc`/`cArcEdges`); its re-run output CSV is
`docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-18_findings.csv` (595 rows).
The 2026-09-02 census doc and CSV are frozen audit records, untouched.

## Method — the modelled arc is the painted arc

The render layer draws each duplicate connector as a vis.js edge with
`smooth = {enabled: TRUE, type: "curvedCW", roundness: 0.2}` (endpoints x-ordered,
`R/makePedigreeDiagramData.R`), bumped to roundness 0.5 by the collision-repair
pass's disclosed heuristic when the chord has a same-row obstacle. vis-network
paints ONE quadratic Bézier: `quadraticCurveTo(via, toPoint)`, with the control
("via") point computed from node centers by `_getViaCoordinates()`'s `curvedCW`
branch. Transcribed from the bundled `vis-network.min.js` (the app's actual
renderer, byte offset ≈252640):

```
dx = to.x − from.x;   dy = from.y − to.y;   L = √(dx² + dy²)
g  = (atan2(dy, dx) + (0.5·r + 0.5)·π) mod 2π          # r = roundness
via = (from.x + (0.5·r + 0.5)·L·sin(g),  from.y + (0.5·r + 0.5)·L·cos(g))
```

**Verification (two independent checks):**

1. **Live widget:** the layouts rendered with the app's own widget construction,
   then every curved edge's `edgeType.getViaNode()` and `options.smooth.*` queried
   from the running vis-network instance via chromote. Max |via(model) − via(live)|
   = **1.1e-13 px** across all 173 curved edges; `smooth.type` is `curvedCW` on
   every one; per-edge roundness (0.2 / bumped 0.5) matches the R edges frame
   exactly (`scratchpad/s714_verify_via.R`).
2. **Painted-ink form:** `_bezierCurve()` in the same bundle confirms a single-via
   `quadraticCurveTo` (a cubic path is used only for the two-via `dynamic` type this
   app never sets). Ink is border-trimmed along the same curve; re-running the hit
   test with border-trimmed endpoints (model M2) changes **zero** counts.

Min distance from a disc center to the quadratic is computed exactly (stationary
points of the squared distance are the real roots of a cubic; `polyroot()` plus the
endpoints), not sampled.

**Render-layer quantization (new incidental discovery):** vis-network applies
JavaScript `parseInt()` to predefined node coordinates, so every symbol and arc
endpoint is truncated toward zero to a whole pixel at render time (measured live:
layout x = −149.8251 renders at −149; pathologically, an x serialized in scientific
notation, e.g. `2.322026e-07`, parses to **2** — no Real-375 coordinate is in that
regime). The census stays on unquantized layout coordinates — its convention for
every class. Sensitivity: parseInt-emulated coordinates move the event count
587 → 586 with the arc count unchanged at 117; ±1-px uniform jitter over 10 draws
gives 588–596 events and **117 arcs in every draw**.

## Findings

### 1. Every one of the 1,667 + 1 chord-heuristic pairs is a false positive

The frozen 2026-09-02 census flagged 1,668 `c-curved-chord` rows (1,667 Real 375 +
1 Track C): same-row curved edges with an unrelated visible node inside the
*chord*'s x-span. The chord predicate was reproduced exactly on fresh layouts
(1,667 + 1, continuity to the row), then each flagged (edge, obstacle) pair was
tested against the modelled arc: **overlap = 0 of 1,667**. The arc always bows up
and over its same-row chord obstacles — at roundness 0.2 its apex is ≈0.185·L above
the row, and even near the endpoints it climbs fast enough to clear the 25-px discs
that sit ≥ minSep (120 px) into the span.

### 2. The true defect population is 587 events on 117 of 170 arcs — invisible to the chord heuristic

Every single true hit is in a region the chord heuristic structurally could not
see:

| population | events | arcs | why the chord test was blind |
|---|---|---|---|
| cross-row connectors (duplicate and real occurrence on different rows) | 485 | 93 | chord test required `y[from] == y[to]`; `c2` skips curved edges entirely |
| same-row connectors, obstacle on a **different** row | 102 | 24 | all at bumped roundness 0.5 — the raised arc swings through the row(s) above; the chord span only ever contained same-row nodes |

Obstacle kinds: 358 individuals + 170 duplicates (25-px discs) + 59 union dots
(6-px). Penetration is deep, not grazing: median 10.9 px of a 25-px radius, 261
events deeper than half the radius, and the worst sites pass within 0.4 px of a
symbol's *center* (e.g. arc `8NQX52 → __dup_8NQX52_1` through `QQ24T8`, min
distance 0.001 px; `__dup_FIL6AB_3 → FIL6AB` through `P49ZD1`, 0.034 px). Crops of
the two deepest sites (`scratchpad/s714_crop_site1_QQ24T8.png`,
`s714_crop_site2_P49ZD1.png`) show the familiar picture: the long dashed chords
crossing symbol interiors are exactly the legibility clutter S712 noted at its
Real-375 class-(d) site.

### 3. The roundness bump can *create* collisions

Of the 56 Real-375 arcs the repair pass bumped to roundness 0.5 (its
`curved-heuristic` residuals): **21** would hit ≥1 symbol at base roundness 0.2,
but **24** hit at the shipped 0.5 — the blind +0.3 bump lifts arcs into upper rows
and hits things there, a net *negative* on this fixture. (Track C's single bumped
arc is the success case: hit at 0.2, clean at 0.5.) The doc-comment's own caveat —
"no closed-form clearance proof … confirmed only by rendered-image inspection" — is
now quantified: the heuristic fires 57 times (56 + 1; the BACKLOG item's "47" was a
stale count) and makes Real 375 slightly worse.

### 4. Re-run scoreboard (2026-09-18) vs the frozen 2026-09-02 baseline

| fixture | a | b | c1Post | c2 | cCurved (2026-09-02, chord) | **cArc (events / arcs)** | d | e | f |
|---|---|---|---|---|---|---|---|---|---|
| Track B full | 0 | 0 | 0 | 0 | 0 | 0 / 0 | 0 | 0 | 0 |
| Track B shrunk | 0 | 0 | 0 | 0 | 0 | 0 / 0 | 0 | 0 | 0 |
| Track C | 0 | 0 | 0 | 0 | 1 | **0 / 0** | 1 | 0 | 0 |
| Real 375 | 0 | **6** | 0 | 0 | 1,667 | **587 / 117** | 1 | 0 | 0 |
| D1–D3 | 0 | 0 | 0 | 0 | 0 | 0 / 0 | 0 | 0 | 0 |

Class (b) reports **6** (was 8), confirming the S713-ratified 1e-3 raw-unit
solver-dust floor at its first re-run — the S713 forward-carry trigger. Classes
(d), (e), (f) and the class-(a)/straight-edge counts are unchanged. The d rows are
measurements, not re-opened items — both were dispositioned CLOSED by S712
(closures live in `CHANGELOG.md`; the census keeps measuring them).

**Coupled prose (updated with this pass):** the fidelity article's mate-line
paragraph now cites 6 of 237 unions (`vignettes/articles/
kinship2-fidelity-validation.qmd`); its Track B "all four union dots exactly
centered" claim re-verifies (class (b) = 0 on both Track B fixtures in this re-run;
S713's live measurement: max residual 1.9e-11 px). The caveats bullet is
count-free and stays accurate as written.

## Recommendation

**A fix item is warranted, and it is narrower than the old number suggested.** The
1,668 figure implied an intractable chord-density problem; the measured population
is 117 arcs whose *drawn* path crosses symbols, concentrated in two mechanisms
(cross-row connectors, and the bump's own overshoot). Concretely recommended
follow-up (one BACKLOG item, Effort M):

- **Replace the blind +0.3 roundness bump with arc-verified roundness selection.**
  The exact painted-arc model now lives in the census script; the engine can try a
  small roundness ladder (e.g. 0.05–0.6) per connector, score true arc-disc hits
  with the same cubic-solve predicate, and keep the best — turning the disclosed
  "no clearance proof" heuristic into a measured choice. Finding 3 shows the
  current bump is net-negative on the bundled fixture, so this is a correctness
  improvement to an existing repair pass, not a new layout objective; the
  no-weight-tuning mandate (S675) is untouched. Residual disclosure
  (`curved-heuristic`) stays for arcs no ladder step can clear.
- Not recommended now: rerouting curved connectors rectilinearly (destroys the
  owner-ratified kinship2 arc convention, S577) or adding arc-avoidance terms to
  the QP (weight-tuning mandate).

## Artifacts

- `data-raw/pedigreeDrawingErrorCensus.R` — arc model + `c-arc-inside` predicate
  (committed, lint-clean; chord heuristic retired from the census).
- `docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-18_findings.csv` — re-run
  findings (595 rows: 587 c-arc-inside + 6 b + 2 d).
- `scratchpad/s714_probe.R` / `s714_probe_results.rds` — chord-vs-arc overlap,
  M1/M2 models, bump counterfactual; `s714_verify_via.R` — live-widget via check;
  `s714_sensitivity.R` — parseInt/jitter sensitivity; `s714_crop_site*.png` — the
  two deepest sites; `s714_census_rerun_output.md` — full re-run console output.
