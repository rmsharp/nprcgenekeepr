# Pedigree Diagram layout: SECOND feasibility spike (igraph::layout_with_sugiyama())

**Status:** SPIKE, session S590 (2026-08-15). **Verdict: NOT FEASIBLE as prototyped.**
**Recommendation: close the non-rigid-layout investigation as inherent. Retain the shipped
rigid-subtree model. Do not pursue a third from-scratch spike on this thread without new evidence
that changes the picture (ratified via `AskUserQuestion` -- see §9).**

**Origin:** `BACKLOG.md` (found S589, HIGH PRIORITY) -- the bounded, second feasibility spike the
first spike's own plan document (`docs/planning/pedigree-diagram-nonrigid-layout-spike-plan.md`
§6) scoped: adapt a proven, convergence-guaranteed layout implementation instead of tuning the
first spike's own hand-rolled barycenter/median candidate further, and test it against the SAME
two fixtures (the 13-individual synthetic example and the real 375-individual bundled fixture),
using the first spike's own faithful full-pipeline metric.

**Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` (continuing the same
technical-decision thread the two prior design/spike documents used).

**Evidence document:**
[`docs/planning/pedigree-diagram-layout-sugiyama-spike-evidence.qmd`](pedigree-diagram-layout-sugiyama-spike-evidence.qmd)
(a runnable Quarto document -- render it directly to reproduce every number and figure cited
below, rather than trusting this document's prose).

---

## 1. Context

### 1.1 What is already decided (do not re-litigate)

- The sibling design document (S588) established that no low-risk *tuning* of the shipped
  rigid-subtree contour-merge model can close the sibling subtree-width gap.
- The first spike (S589) prototyped a hand-rolled barycenter/median candidate: improved the small
  synthetic example (20% gap reduction, 0 new crossings) but regressed the real fixture (9/251 ->
  15/251 threshold-violating edges, 6.1x width growth), diagnosed to a convergence-instability
  failure at high-mate-count "hub" individuals. Owner ratified: recommend a second, narrower spike
  adapting a proven, convergence-guaranteed implementation rather than tuning further.
- Owner selected `igraph::layout_with_sugiyama()` for this spike over a ported Brandes-Köpf (2002)
  alternative, via `AskUserQuestion` at this session's Phase 1 -- `igraph` was confirmed
  installable in this environment (not previously installed) and its `layout_with_sugiyama()`
  sanity-checked working on a toy DAG before the choice was presented.

### 1.2 What this document decides

Whether the `igraph::layout_with_sugiyama()` candidate prototyped this session is feasible to
build into a production replacement for `.positionMatingUnitForest()`'s current rigid-subtree
model, and if not, what the next step should be.

### 1.3 The candidate's design

Build the same parent-union-child DAG the shipped recursive contour-merge walks (vertices = real
individuals + mating units; edges = sire/dam -> unit, unit/individual -> child), with each
vertex's layer fixed to its display generation (identical generation accounting to the shipped
function). Hand this graph to `igraph::layout_with_sugiyama()`, extract only the real individuals'
`x`, and feed those through the **identical** downstream pipeline the shipped function uses
(`orderBySex` swap, Track 6 `finalUnitX`-from-children, duplicate offset, final de-collision,
final sweep) -- reusing the first spike's own harness byte-for-byte, for a fair, faithful
comparison.

**Multi-restart, found necessary this session (§1.4):** `layout_with_sugiyama()`'s own
crossing-minimization heuristic is sensitive to input vertex order. The natural construction order
hit an avoidable local optimum (4 crossings where 0 is achievable) on the small synthetic example.
Standard mitigation for layered-graph heuristics -- run N random-order trials, keep whichever
minimizes actual crossings -- was applied throughout (`restarts = 20`, this session's own
`countCrossings()`, not a proxy). This is standard practice for using the underlying heuristic,
not a new algorithm layered on top of it.

### 1.4 One real, checked limitation found en route

`layout_with_sugiyama()`'s `weights` parameter -- tried at multiple ratios (up to 10:1, favoring
union-to-child edges to encourage tighter full-sibling grouping) -- had **zero measurable effect**
on the resulting layout when explicit `layers` are also supplied to the function, in this igraph
version. Confirmed via byte-identical results across 4 distinct weight configurations (evidence
doc, "Sensitivity" section). Not a candidate design bug -- a checked, reported limitation of this
specific knob for this use case, not exploited further.

### 1.5 Results

**Synthetic 13-individual example**: the candidate closes the `A`-`B` gap from 2.5 to 2.0 raw
units (a 20% reduction) with **zero edge crossings** (best of 20 restarts) -- matching the first
spike's own barycenter/median candidate's exact toy-example improvement, now achieved via a
properly published, proven crossing-minimization algorithm instead of a hand-rolled relaxation.

**Real 375-individual fixture, faithful full-pipeline measurement** (identical methodology to the
first spike -- baseline reproduces the first spike's own published 9/251, 3.6%, max 4,121.25
exactly, confirming harness fidelity):

| Metric | Baseline (shipped) | Candidate (igraph sugiyama, best of 20 restarts) |
|---|---|---|
| Edges exceeding 200-unit threshold | 9/251 (3.6%) | 25/251 (9.96%) |
| Max offset | 4,121.25 | 10,110.00 |
| Overall real-node x range | 126.8 | ~307 (2.4x) |
| Edge crossings | 3,174 | 5,916 |

**The candidate regresses the real fixture on every axis measured** -- including crossings, this
algorithm's own stated optimization objective. A 4-point restart-count/seed sensitivity sweep
(evidence doc, "Sensitivity" section) never produced a result better than 25/251, confirming this
is not a tuning artifact.

### 1.6 Why it fails: a proven algorithm's own objective doesn't preserve full-sibling compactness

The single worst-regressed edge again traces to a high-mate-count hub individual (4 separate
mating unions -- a different individual from the first spike's own hub, but the same STRUCTURAL
feature). The mechanism differs from the first spike's convergence instability: sugiyama's
crossing-minimization and horizontal-coordinate assignment optimize for overall graph
straightness/crossing count across the WHOLE graph, with no explicit preference for keeping any
one mating unit's own full siblings close together. A hub individual's several subtrees compete
for horizontal space across the whole layout, and the algorithm can -- and does -- scatter one
union's full-sibling group widely if doing so serves its own global objective. The shipped
rigid-subtree model achieves tight full-sibling grouping BY CONSTRUCTION (each subtree recursively
reserves a compact, contiguous span); a proven algorithm optimizing a genuinely different
objective does not inherit that property for free, and this project's own metric (which measures
exactly that property) penalizes it accordingly.

---

## 2. Decision

**NOT FEASIBLE as prototyped.** `igraph::layout_with_sugiyama()` does not qualify as a production
replacement for the shipped rigid-subtree algorithm: it regresses the real fixture on every axis
measured (offset metric, max offset, layout width, AND crossings -- its own stated objective),
and the regression is not fixable by restart-count/seed tuning or by the one edge-weighting knob
this session checked.

**Recommendation: close the non-rigid-layout investigation as inherent.** This is now the THIRD
independently-designed candidate -- three different paradigms (bounded-lookahead contour-merge,
hand-rolled barycenter/median relaxation, and now a proven published library's own Sugiyama
implementation), three different specific failure mechanisms (edge crossings; convergence
instability; full-sibling scattering under a global objective) -- to show the SAME qualitative
pattern: improves the small synthetic example, regresses the real 375-individual fixture. Owner
ratified (§9): treat this convergence across three genuinely independent approaches as sufficient
evidence that the current rigid-subtree layout is a reasonable local optimum for this project's
real, highly-connected pedigree data, and stop pursuing further non-rigid spikes on this thread
without new evidence that changes the picture.

**One untested idea worth recording for a future revisit, not pursued here (owner-named
alternative, not selected -- §9):** a hybrid "order-then-compact" approach -- use sugiyama's
crossing-minimized row ORDER (from a proven algorithm) as a FIXED input to a contour-merge-style
COMPACTION pass (like the shipped model's own `mergeSubtrees()`, which guarantees tight sibling
grouping) instead of sugiyama's own coordinate assignment. This combines a proven low-crossing
ordering with the shipped model's own compactness guarantee, and was not tried by any of the three
candidates evaluated so far. Recorded here so a future session does not need to rediscover it, but
NOT scoped as an active next step -- the owner's decision this session was to close the
investigation, not queue a fourth candidate.

---

## 3. Rationale

- **The regression is severe and multi-axis**, not marginal or single-metric: the candidate is
  worse than baseline on the offset metric (9.96% vs 3.6%), max offset (2.5x), layout width
  (2.4x), AND crossings (1.9x) simultaneously -- including the one metric (crossings) this
  algorithm is specifically designed to minimize.
- **The regression is reproducible and not a tuning artifact.** Four distinct restart-count/seed
  combinations all regressed to 25-27/251; none approached the baseline. A separate edge-weight
  check (up to 10:1) had zero effect.
- **The failure has a diagnosed, specific cause** (full-sibling scattering under sugiyama's own
  global objective, at exactly the high-mate-count hub topology the small synthetic example cannot
  exercise) -- directly actionable evidence, matching the diagnostic rigor of both prior
  candidates' own failure analyses.
- **Three independently-designed candidates, three different mechanisms, the same qualitative
  pattern.** This is a stronger convergence of evidence than after 2 failures: a proven,
  published, battle-tested implementation -- specifically recommended by the FIRST spike as the
  lower-risk path precisely BECAUSE it removes hand-rolled-bug risk -- still fails, for a reason
  that has nothing to do with implementation bugs (this candidate has none of the two bug classes
  the first spike found) and everything to do with a genuine mismatch between what a general
  layered-DAG algorithm optimizes for and what this project's own fidelity metric requires
  (full-sibling compactness around each mating union).
- **The synthetic-example improvement is not in dispute** -- all three candidates, including this
  one, genuinely improve the small toy case. The real fixture's own additional structural
  complexity (high-mate-count hubs, entirely absent from the toy example) is the consistent
  explanatory factor across all three failures, not a property specific to any one candidate's
  implementation.

---

## 4. Alternatives Considered

| Alternative | Pros | Cons | Status |
|---|---|---|---|
| **This session's igraph::layout_with_sugiyama() candidate** (tested, §1.5) | Proven, published, crossing-minimization-guaranteed implementation; genuinely improves the toy example (0 crossings, 20% gap reduction); found no implementation bugs of its own | Regresses the real fixture on every axis measured, including crossings; the `weights` knob does not help; the underlying mismatch (global objective vs. local sibling compactness) is structural, not a bug to fix | **Rejected** -- real, reproducible, multi-axis regression |
| **A hybrid order-then-compact approach** (named, not tested -- §2) | Combines a proven low-crossing ORDER with the shipped model's own proven compactness guarantee; addresses this candidate's own diagnosed failure mode directly | Untested; would need its own spike; adds implementation complexity (two algorithms stitched together) | **Named for the record, not selected this session** (§9) |
| **A ported Brandes-Köpf (2002) horizontal coordinate assignment** (the other option `BACKLOG.md` named alongside igraph) | The other well-established published algorithm for this problem class | No existing implementation to lean on in this R environment -- carries the SAME hand-rolled-bug risk this project's own candidates have already hit twice (S588, S589); this session's own finding (a proven library ALSO fails, for a structural, non-bug reason) makes it less likely a from-scratch port of a different algorithm in the same general family would fare better | **Not selected -- owner ratified closing the investigation instead** (§9) |
| **Close the investigation as inherent** (this document's own recommendation) | Zero further risk/cost; matches 3 independent paradigms converging on the same real-fixture failure pattern; the current rigid-subtree model, while imperfect, has known, well-understood behavior in production | Does not resolve issue #159's own underlying finding (sibling subtree-width asymmetry still exists in the shipped layout); a genuinely better fix may exist and simply wasn't found by these 3 specific attempts | **RECOMMENDED -- owner-ratified** (§2, §9) |

---

## 5. Impact Analysis

| System | Impact | Action Required |
|---|---|---|
| `R/makePedigreeDiagramData.R` (`.positionMatingUnitForest()`, `makePedigreeMatingLayout()`) | **None this session** -- all candidate code lived in `/private/tmp` scratchpad and this document's own evidence `.qmd`, never `R/` | None now |
| Pedigree Diagram Shiny tab (`R/modPedigree.R`) | **None this session** -- no behavior change | None now |
| `BACKLOG.md` | This spike item is DONE; the broader non-rigid-layout redesign thread is closed (not replaced with a new READY item, per the owner-ratified verdict) | Mark this item DONE citing this document; do not add a new active spike item |
| GitHub issue [#159](https://github.com/rmsharp/nprcgenekeepr/issues/159) | The redesign effort this issue tracks is now closed per 3 independent negative findings | Comment with this session's verdict and the cumulative 3-candidate evidence; close the issue (matches `CLAUDE.md`'s GitHub issue close-out checklist -- this session's own close-out decision, not a code fix) |
| `DESCRIPTION` / `renv.lock` | **None this session** -- `igraph` was installed and used for this one-off comparison only, never added as a dependency | None -- matches the `kinship2` reference-only precedent |

**What does not change:** every shipped diagram (`edgeStyle = "direct"` and `"rectilinear"`)
renders exactly as it does today. No test, fixture, or documented behavior is affected. The known
sibling subtree-width asymmetry (issue #159's own origin finding) remains present and unfixed --
this document recommends accepting it, not that it has been resolved.

---

## 6. Migration Path

This document ships no code change and, per the owner-ratified verdict, does not scope a next
implementation session on this thread:

1. **No next session is scoped by this document.** The investigation is closed. A future session
   should NOT pick up a "third spike" as a default next action -- that would contradict this
   session's own close-out decision.
2. **If new evidence emerges that changes the picture** (e.g., a specific production pedigree
   where the current model's sibling-width asymmetry causes a real, reported problem -- not a
   toy-example demonstration), a future session could revisit this thread. The hybrid
   order-then-compact idea (§2) is the most promising untested direction if that happens; the
   3 rejected candidates' own specific failure mechanisms (§1.6 here, plus the two prior
   documents') do not need to be rediscovered.
3. **This document, the first spike's document, and the sibling design document together are the
   complete record of this investigation** -- three fixtures' worth of faithful measurement
   methodology, three candidates' worth of diagnosed failure mechanisms, available in full to
   whoever revisits this.

---

## 7. Verification Plan

Not applicable in the classic build/test sense -- this document ships no production code change.
This session's own verification obligations, discharged:

- The evidence document
  ([`pedigree-diagram-layout-sugiyama-spike-evidence.qmd`](pedigree-diagram-layout-sugiyama-spike-evidence.qmd))
  renders clean via `quarto render` (confirmed this session, 0 errors) -- this document's build
  equivalent per `SAFEGUARDS.md` "Verify the Build Equivalent." Re-render it to reproduce every
  number and figure cited above; spot-checked the rendered HTML output against the scratchpad
  computations before trusting it.
- The seed reproduction was cross-checked against the REAL shipped `.positionMatingUnitForest()`
  at both scales (synthetic example and real fixture), confirmed byte-identical (max diff 0 at
  both) -- via `pkgload::load_all()`, not `library(nprcgenekeepr)` (see the incidental finding,
  §8).
- The faithful full-pipeline metric was cross-checked against the first spike's own published
  baseline (9/251, 3.6%, max 4,121.25) and reproduced it exactly.
- `git status` confirms no `R/`, `tests/`, or other package-source file is touched by this
  session's changes.

---

## 8. Explicitly Out of Scope (report, don't fix here -- `PROJECT_LEARNINGS.md` Learning 382)

- **The S583 "union outside its own parents' x-range" item** -- deliberately kept out of scope by
  both prior documents in this thread and not folded in here either; a distinct axis of the same
  broader positioning problem space, with its own open `BACKLOG.md` entry.
- **A fourth candidate implementation** (the hybrid order-then-compact idea, §2, or a ported
  Brandes-Köpf) -- not attempted this session, matching the "one candidate per spike" scope this
  session's own `BACKLOG.md` item set, and consistent with the owner's own decision to close the
  investigation rather than queue a next attempt.
- **Incidental finding: the renv-cached installed `nprcgenekeepr` build is stale.** Built
  2026-08-14 18:24, ~3.5h before Track 6 shipped (`f65ecbea`, 2026-08-14 21:56:10) --
  `library(nprcgenekeepr)` silently loads that pre-Track-6 build rather than current source. This
  session used `pkgload::load_all()` throughout instead (matching `CLAUDE.md`'s own documented
  build-equivalent convention) and confirmed 0-diff crosschecks against TRUE current source at
  both fixture scales. The FIRST spike's own evidence `.qmd` used `library(nprcgenekeepr)` for its
  crosscheck; not re-verified this session whether that affected its own reported numbers (its
  crosscheck also reported 0 diff, so its own harness may simply have been built and rendered
  before the installed copy went stale, or the discrepancy may not reach real-individual x values
  the way it reaches mating-unit x values -- see this session's own debugging trail). A future
  session touching that document, or refreshing the renv-cached install generally (e.g. via
  `devtools::install()` or equivalent), should be aware of this gap.

---

## 9. Owner ratification record

Presented via `AskUserQuestion` after the full investigation above (both fixtures, the
restart/seed sensitivity sweep, the edge-weight check, and the hub-node diagnosis) was complete:

- [x] **Close as inherent** -- 3 independent paradigms, 3 different specific failure mechanisms,
      same qualitative real-fixture regression; treat this as sufficient evidence the current
      rigid-subtree layout is a reasonable local optimum for this project's real, highly-connected
      pedigrees; stop pursuing further non-rigid spikes on this thread; document the pattern for
      whoever revisits it
- [ ] Recommend a third spike: hybrid order-then-compact (§2's own named idea)
- [ ] Recommend a third spike: ported Brandes-Köpf (2002)
- [ ] Hold -- tune this candidate further (more restarts/weight configurations, or a custom
      sibling-compaction post-process bolted onto sugiyama's output)

Owner selected **"Close as inherent."** This document and its recommendation (§2, §6) reflect that
selection.
