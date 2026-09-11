# Sibling-order appetite measurement — evidence (Session 686)

**Status:** measurement only — no engine change ships from this session.
**Provenance:** design Open Question 3 of
[`pedigree-diagram-provisional-order-plan.md`](pedigree-diagram-provisional-order-plan.md)
("Sibling order within sibships — OPEN, deliberately unmeasured … measure owner
appetite only after the wDup item ships"). wDup shipped S683; the census floor
after S685 is Real 375 jogs 95 / c2 0 / d 0 / b 12. Owner-picked at Phase 0
(S686, 2026-09-11) over the S679 ascender-stub cosmetic.
**Tooling:** `scratchpad/s686_*.R` (instrument, root analysis, optimizer
library, iterate driver, census copies, crop renderer) — untracked scratch;
take before cleaning `scratchpad/`. A/B renders delivered in-session
(baseline/optimized overview + meso pairs).

## 1. Structural fact: every sibling-order lever is ped ROW order

Verified by reading the engine (no assumption):

- Children of a mating unit enter `childEdges` in ped row order
  (`.buildMatingUnitForest()`, `R/makePedigreeDiagramData.R:594-599`).
- `childrenOf()` reads `childEdges` row order
  (`R/makePedigreeDiagramData.R:896-907`); the BJL walk freezes it
  (`.buildForestChildrenOf()` → `.positionTreeApportion()`, `:985-987`).
- Root order = founder filter over `realIds` in ped row order (`:961,983`);
  component packing = smallest ped row index (`.forestComponents()` roxygen,
  `:621-625`); a polygamous parent's unit order = unit first-appearance row
  order (`:426-433`).

Consequence: the whole lever family — within-sibship order, root-subtree
order, unit order, family packing — is expressible as a **pure input
permutation**. Every measurement below ran through the completely unmodified
engine.

## 2. The literal Open Question 3 lever (within-sibship) is nearly empty

Instrument: `scratchpad/s686_sibling_instrument.R` on Real 375.

- Only **13** sibships have ≥2 rendered children; **5** show an order
  inversion against their children's pulls (pull = barycenter of curved
  duplicate-connector far ends attached to the child's cluster).
- Only **2** of the 170 curved connectors are intra-root-subtree (1,240 px of
  570,645 px total, 0.2%) — within-sibship reorder cannot shorten the rest.

## 3. Where the artifact actually lives: root-subtree order

Instrument: `scratchpad/s686_root_analysis.R`.

- 5 weakly-connected components; **57 root subtrees**; 124 founders (67 B1
  marry-ins are not roots).
- **168 of 170** connectors (569,405 px, 99.8% of ink) are cross-root.
- 55/57 roots have cross-root pulls; **644 of 1,485** pulled-root pairs are
  inverted in the current (ped-row, i.e. arbitrary) order.
- Crossing counts under the current order (session metric — the census does
  not measure crossings): straight×straight 192, chord×straight 1,740,
  chord×chord 931.

## 4. Negative result: the naive kinship2-autohint analogue FAILS here

`scratchpad/s686_spike_permute.R` — single-pass barycenter reorder (root
groups + sibships), iterated 3×: span sum 570,645 → 580,161 → 585,812 →
634,615 (**worse every round**). With 168 connectors over 57 subtrees the
problem is a dense minimum-linear-arrangement instance, not kinship2's sparse
case where barycenter hints suffice. Any design session that reaches for
autohint's literal mechanism should expect this result.

## 5. Positive result: a real optimizer recovers a third of the connector ink

`scratchpad/s686_order_lib.R` + `s686_order_iterate.R`: per-component block
model (measured cluster widths + connector-endpoint offsets), spectral seed
(Fiedler vector of the connector-graph Laplacian) + swap/move local search on
the proxy, realized as a row permutation, recalibrated against the true layout
each round; converged round 3. Census verification via a byte-faithful harness
copy (`s686_census_base_findings.csv` proved `identical()` to the committed
baseline CSV).

| metric (Real 375) | current order | optimized order | Δ |
|---|---|---|---|
| connector ink (px) | 570,645 | **382,911** | **−33%** |
| connector mean span (px) | 3,357 | 2,252 | −33% |
| spans > 2,000 px | 110 | 69 | −37% |
| census cCurved (chords through symbols) | 1,996 | **1,278** | **−36%** |
| chord×chord crossings | 931 | 604 | −35% |
| chord×straight crossings | 1,740 | 1,316 | −24% |
| straight×straight crossings | 192 | 233 | +21% (n small) |
| census c1Pre | 10 | 6 | −4 |
| jog repairs | 95 | 102 | +7 |
| census a / b / c1Post / c2 / d / e / f | 0/12/0/0/0/0/0 | 0/12/0/0/0/0/0 | unchanged |
| layout width (px) | 13,740 | 13,740 | unchanged |

Visual: the connector dome thins visibly (A/B overviews delivered
in-session) but does **not** vanish — mean span is still ~2,250 px. That is
the honest ceiling of ordering alone: 170 connectors among 57 subtrees cannot
all be adjacent. Removing the dome outright would need a different mechanism
(connector routing, duplicate-policy change), not order.

## 6. Pinned-fixture safety (checked, not assumed)

Running the optimizer on the 6 small census fixtures: **identity permutation
on 5** (Track B full/shrunk, D1–D3 — no or too-few connectors, so every root
keeps its current position as its sort key). Track C (3 duplicates) permutes
but its measured layout metrics are **identical** (span 510, crossings, width
— a proxy tie broken arbitrarily). A shipped version therefore plausibly
preserves packing-fixture byte-identity **by construction** if it adds a
prefer-current-order tie-break; that is a design-session verification item,
not proven here.

## 7. What shipping would involve (for a future design session — not decided)

- **Shape A — pre-layout ordering pass** inside `makePedigreeMatingLayout()`:
  pass-1 layout → optimize → re-layout (~2× layout cost; Real 375 ~5 s → ~10 s,
  plus optimizer seconds). Needs: the tie-break above; a decision on the
  proxy-vs-true objective; determinism guarantees.
- **Shape B — exported utility** (order a ped before rendering): zero
  engine risk, but users must call it; app integration decision.
- **Shape C — decline**: accept the dome; close Open Question 3 as measured.
- Known costs either way: `__union_N` ids renumber under any row permutation
  (first-appearance order), so test pins and the 5 Diagram-tab screenshots
  churn; polygamous parents' unit order changes ride along (an uncontrolled
  secondary effect of row permutation, measured harmless here: b stayed 12);
  jog repairs +7; the S685 zero-corridor-disc-violations suite guard held in
  the census re-run (c2 0, c1Post 0).

## 8. Disposition

Open Question 3's literal within-sibship lever: measured ≈ empty at the
current floor (§2). The same mechanism at the root-subtree level: measured
real (−33% ink, −36% cCurved, −24/−35% chord crossings) with a demonstrated
optimizer and a demonstrated-false naive shortcut (§4). Owner appetite
decision recorded below.

**Owner decision (S686, via `AskUserQuestion`): Shape A — design the engine
pass.** A future design session (ARCHITECTURE_WORKSTREAM, matching every prior
`.positionMatingUnitForest()` decision) designs the pre-layout ordering pass:
objective (proxy vs true), the prefer-current-order tie-break (§6), determinism,
the union-id renumbering / test-pin / screenshot churn inventory, and the ~2×
layout-cost budget. Tracked as a `BACKLOG.md` Up Next item (S686). Shapes B/C
remain the recorded fallbacks if the design session finds a blocker.
