# Pedigree Diagram layout: non-rigid feasibility spike

**Status:** SPIKE, session S589 (2026-08-15). **Verdict: NOT FEASIBLE as prototyped.**
**Recommendation: a second, narrower spike adapting a proven, convergence-guaranteed
implementation (e.g. `igraph::layout_with_sugiyama()`, checked and confirmed available on CRAN
though not installed in this environment) rather than tuning this session's own hand-rolled
candidate further. Defer the full `*_CAMPAIGN.md` document until that second spike has evidence
(ratified via `AskUserQuestion` -- see §9).**

**Origin:** `BACKLOG.md` (found S588, HIGH PRIORITY) -- the bounded, single-session follow-on the
sibling design document (`docs/planning/pedigree-diagram-sibling-subtree-width-plan.md` §6)
scoped: prototype ONE non-rigid/constraint-aware layout candidate and test it against (a) that
document's own 13-individual synthetic example and (b) the real 375-individual bundled fixture,
using a *faithful* reproduction of the shipped algorithm's actual final-position pipeline -- not
the design session's own simplified proxy.

**Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` (continuing the same
technical-decision thread the sibling design document used).

**Evidence document:**
[`docs/planning/pedigree-diagram-nonrigid-layout-spike-evidence.qmd`](pedigree-diagram-nonrigid-layout-spike-evidence.qmd)
(a runnable Quarto document -- render it directly to reproduce every number and figure cited
below, rather than trusting this document's prose).

---

## 1. Context

### 1.1 What is already decided (do not re-litigate)

- The sibling design document (S588) established that no low-risk *tuning* of the shipped
  rigid-subtree contour-merge model can close the sibling subtree-width gap -- the model's
  `mergeSubtrees()` computes the mathematically minimal safe gap under that model, with no slack
  left to recover, and Reingold-Tilford/Walker/Buchheim-Jünger-Leipert (issue #141's own named
  target) all share the same rigid-subtree model, so none of them would help either. Genuinely
  closing the gap requires a different layout paradigm.
- The owner ratified COMMIT to a redesign effort (correcting an initial DEFER recommendation:
  "these layout issues are a high priority and may require a lot of work -- the work cost is not
  a deterrent"), scoped as a bounded feasibility spike before any campaign commitment. This
  document is that spike.
- Owner selected the candidate paradigm for this spike -- **barycenter/median layered-DAG
  compaction** (a Sugiyama-style technique, the `Graphviz dot` family) -- over a force-directed
  alternative, via `AskUserQuestion` at this session's Phase 1.

### 1.2 What this document decides

Whether the barycenter/median candidate prototyped this session is feasible to build into a
production replacement for `.positionMatingUnitForest()`'s current rigid-subtree model, and if
not, what the next step should be.

### 1.3 The candidate's design

Seed from the shipped recursive contour-merge's own output (a valid, non-crossing layout --
byte-identical logic to `.positionMatingUnitForest()` through Track 3's first `sweepMinSep()`,
cross-checked live against the real function on both the synthetic example and the real fixture,
0 diff at both scales -- evidence doc, "Cross-check" section). Fix the left-right order within
each generation row from that seed permanently, then iteratively refine `x` via alternating
down-sweeps (each row pulled toward its own parent row's midpoint) and up-sweeps (each row pulled
toward its own mating unit's live child-mean), re-enforcing order-preserving `minSep` after every
row update. The refined positions feed through the **identical** downstream pipeline the shipped
function uses (`orderBySex` swap, Track 6 `finalUnitX`-from-children, duplicate offset, final
de-collision, final sweep) for a fair, faithful comparison.

**Structural guarantee, verified empirically at both scales:** because the row order is fixed
from a proven-correct seed and never changes, the candidate cannot introduce a NEW edge crossing
beyond what the seed already has -- confirmed via a direct rank-order check (0 mismatches on the
synthetic example, 0 mismatches on the real 375-individual fixture).

### 1.4 Two real implementation bugs found and fixed en route

1. **Unbounded ratchet from a fully-simultaneous ("Jacobi") update.** An initial design updated
   every node's position simultaneously each iteration, each toward a target computed from the
   PREVIOUS iteration's state. Two nodes sharing their only pull source (e.g. two parents of the
   same one mating unit, nothing else tying either down) then computed an IDENTICAL target every
   iteration; since the order-preserving sweep can only push right (never left) to restore
   `minSep`, this re-separated them by exactly `minSep` every iteration -- an unbounded linear
   drift (layout "range" grew from 6 to 400+ raw units over 800 iterations on the toy example,
   never converging). Fixed by switching to a row-sequential alternating down-sweep/up-sweep
   design (the standard Sugiyama structure), where generation 0 (no parents) never moves during a
   down-sweep and so acts as a natural anchor.
2. **Self-referential down-target.** An intermediate version used the SAME "unit x" (mean of a
   unit's own children) for both the down-sweep and up-sweep pulls. This made a child's down-pull
   target trivially include its own value (a union's child-mean, by definition, includes the very
   child being updated) instead of referencing its actual PARENTS, breaking the down/up coupling
   entirely and reproducing the same kind of unbounded drift as bug 1, just slower. Fixed by
   introducing two distinct notions of "a unit's own x" -- `liveUnitParentX()` (mean of the
   unit's real sire/dam, for the down-sweep) and `liveUnitChildX()` (mean of the unit's real
   children, for the up-sweep, matching the shipped Track 6 `finalUnitX` intent).

Both bugs are documented inline in the evidence document's own embedded code. Their existence is
itself informative: a hand-rolled iterative relaxation is easy to get subtly wrong even when the
underlying paradigm (layered-DAG barycenter/median layout) is a standard, published technique --
see §4/§9.

### 1.5 Results

**Synthetic 13-individual example** (the sibling design document's own reproduction): the
candidate closes the `A`-`B` gap from 2.5 to 2.0 raw units (a 20% reduction) with **zero edge
crossings**, confirmed both by direct visual inspection (evidence doc, "Synthetic example"
section) and by the row-order-preservation check.

**Real 375-individual fixture, faithful full-pipeline measurement** (the exact Track 6
methodology -- `tests/testthat/test_positionMatingUnitForest.R`'s own per-child-edge
`|childX - unitX|` measure against the FULL-pipeline `finalUnitX`, scaled by `xScale = 120` to
match Track 6's own "200 units" threshold; the baseline reproduction exactly matches Track 6's
own published 9/251 edges, 3.6%, max 4,121.25, confirming the harness itself is faithful, not an
approximation):

| Metric | Baseline (shipped) | Candidate (barycenter/median) |
|---|---|---|
| Edges exceeding 200-unit threshold | 9/251 (3.6%) | 15/251 (5.98%) |
| Max offset | 4,121.25 | 5,344.38 |
| Overall real-node x range | 126.8 | 773.7 (**6.1x**) |
| Row-order mismatches vs. seed | -- | 0 |

**The candidate regresses the real fixture**, and not marginally -- the overall layout width for
real individuals more than sextuples. A 5-point hyperparameter sweep (`alpha` 0.15-0.6, rounds
30-300) never produced a result better than 15/251 (evidence doc, "Hyperparameter sweep"
section), confirming this is not a tuning artifact fixable by different settings of THIS
candidate's own parameters.

### 1.6 Why it fails to converge at real-fixture scale (found, not just observed)

The single worst-regressed edge pair (offset 195 -> 5,344 scaled units, a 27x worsening) traces to
a mating unit whose sire has **5 separate mating unions** -- a highly-connected "hub" individual
entirely absent from the 13-individual synthetic example (max 1 mate per individual there, by
construction). A hub like this couples many different subtrees' barycenter targets together each
round; this session's row-sequential damped-relaxation design has no formal convergence guarantee
for that topology, unlike a properly-implemented, published algorithm. This is a genuinely new,
more specific finding than the general "toy-example trends can invert at scale" lesson
(`PROJECT_LEARNINGS.md` Learning 596, from the sibling design session): it names the SPECIFIC
structural feature -- mate-count degree -- that breaks this candidate's convergence, which is
directly actionable for whoever attempts a second candidate (test against a fixture with
high-mate-count individuals from the start, not only after a real-fixture regression surfaces it).

---

## 2. Decision

**NOT FEASIBLE as prototyped.** The barycenter/median candidate built this session does not
qualify as a production replacement for the shipped rigid-subtree algorithm: it regresses the
real fixture's own measured layout quality by a wide margin (6x width growth, not a marginal
tradeoff), and the regression is not fixable by hyperparameter tuning within this candidate's own
design.

**Recommendation: a second, narrower spike, adapting a proven implementation rather than tuning
this one further.** The underlying PARADIGM (non-rigid, layered-DAG barycenter/median layout)
remains plausible in principle -- it is the standard, published technique for exactly this class
of layout problem, and this candidate's own toy-example result (20% gap reduction, provably zero
new crossings) shows the paradigm CAN help in the case it was designed to fix. What failed is this
session's own from-scratch iterative implementation, which found and fixed two real bugs and
still hit an unresolved convergence failure at the exact structural feature (high-mate-count hubs)
the small toy example cannot exercise. `igraph::layout_with_sugiyama()` (checked this session:
not installed in this environment, but a well-established CRAN package) or a properly-ported
Brandes-Köpf (2002) horizontal coordinate assignment -- both of which carry their own formal
convergence properties, unlike an ad hoc relaxation -- are concrete, lower-risk starting points
for that second spike.

**Defer the campaign document.** Per this document's own §6 (Migration Path) and the design
doc's own §2 item 2 precedent, drafting a full `*_CAMPAIGN.md` before a working candidate exists
would repeat the "plan without evidence" pattern this project has repeatedly guarded against
elsewhere.

---

## 3. Rationale

- **The regression is large and structural, not marginal.** A 6x increase in overall layout width
  and a 66% increase in threshold-violating edges (9 -> 15 of 251) is not a tradeoff a reasonable
  reader would accept in exchange for a 20% gap reduction on one hand-picked toy case.
- **The regression is reproducible and not a tuning artifact.** Five different `(rounds, alpha)`
  combinations all regressed; none approached the baseline, let alone improved on it.
- **The failure has a diagnosed, specific cause** (high-mate-count hub individuals), not just an
  observed symptom -- this is directly actionable evidence for scoping a second attempt, not a
  dead end.
- **Crossing-freedom held by construction at both scales** -- a genuine structural advantage over
  the sibling design session's bounded-lookahead candidate (which introduced an edge crossing).
  This candidate's failure mode is convergence/stability, not correctness-of-output-when-it-
  converges, which is a more tractable class of problem for a properly-implemented algorithm to
  solve than "produces a visibly wrong diagram."
- **Two independently-designed candidates, two different mechanisms, the same qualitative
  pattern.** The sibling design session's bounded-lookahead candidate and this session's
  barycenter/median candidate share nothing in their mechanics, yet both improved the small
  synthetic example while regressing the real fixture. That convergence across genuinely
  different approaches is itself evidence that closing this gap is harder than either individual
  candidate's own failure would suggest -- worth naming explicitly for whoever scopes the next
  attempt, so it isn't read as "just try a third idea from scratch."
- **A proven implementation changes the risk profile.** This session's own two real bugs (found
  and fixed) demonstrate that a hand-rolled iterative relaxation is easy to get subtly wrong even
  when the underlying algorithm class is standard and published. A battle-tested implementation
  (a CRAN package with existing users, or a careful port of a peer-reviewed algorithm's published
  pseudocode) removes that specific risk class from a second attempt.

---

## 4. Alternatives Considered

| Alternative | Pros | Cons | Status |
|---|---|---|---|
| **This session's barycenter/median candidate** (tested, §1.5) | Genuinely different paradigm from rigid-subtree contour-merge; toy-example improvement with provably zero new crossings; found and fixed 2 real implementation bugs along the way | Regresses the real fixture by a wide, non-tunable margin (6x width growth); no formal convergence guarantee, confirmed failing at real-fixture scale via a diagnosed mechanism (hub individuals) | **Rejected** -- real, reproducible, structural regression |
| **Tune this candidate further** (e.g. per-node adaptive damping, a Gauss-Seidel variant) | Reuses existing, partially-working code; owner asked about this explicitly at ratification | Presented to the owner via `AskUserQuestion` (§9) and NOT selected -- the regression's cause (unbounded-ish convergence at hub nodes) is a property of the ad hoc relaxation approach itself, not a single tunable parameter, so further tuning is unlikely to be a low-risk path relative to adapting a proven implementation | **Declined by owner ratification** |
| **Adapt a proven, convergence-guaranteed implementation** (`igraph::layout_with_sugiyama()` or a properly-ported Brandes-Köpf) | Removes the "hand-rolled algorithm has subtle bugs" risk class this session's own experience demonstrated; formal convergence properties instead of empirical trial-and-error; still tests the same underlying paradigm this session showed CAN help on the toy case | Unvalidated against THIS project's own fixture/pipeline -- still needs its own spike; `igraph` is not currently an installed/declared dependency | **RECOMMENDED -- scoped as a second, narrower spike** (§2, §9) |
| **Accept the current layout as inherent, stop pursuing a fix** | Zero further risk/cost; matches issue #141's own original "premature optimization" framing | Contradicts the owner's explicit, twice-ratified priority correction ("high priority... work cost is not a deterrent") from the sibling design session; two candidates' shared toy-example success suggests the paradigm itself is not hopeless, only this session's specific implementation | **Presented to owner via `AskUserQuestion`, NOT selected** (§9) |

---

## 5. Impact Analysis

| System | Impact | Action Required |
|---|---|---|
| `R/makePedigreeDiagramData.R` (`.positionMatingUnitForest()`, `makePedigreeMatingLayout()`) | **None this session** -- all candidate code lived in `/private/tmp` scratchpad and this document's own evidence `.qmd`, never `R/` | None now; §6 scopes the next spike |
| Pedigree Diagram Shiny tab (`R/modPedigree.R`) | **None this session** -- no behavior change | None now |
| `BACKLOG.md` | This spike item is DONE; a new item for the second, narrower spike replaces it | Mark the S588 spike item DONE citing this document; add a new READY item scoping the second spike |
| GitHub issue [#159](https://github.com/rmsharp/nprcgenekeepr/issues/159) | Still the correct tracker for this redesign effort -- update with this spike's own outcome | Comment with this session's verdict and the recommended next step; do not close (work continues) |
| `DESCRIPTION` / `renv.lock` | **None this session** -- `igraph` was checked for availability, not installed or added as a dependency | A second spike that adopts `igraph` would need to add it (`Suggests`, matching the `kinship2` reference-only precedent) at that time, not now |

**What does not change:** every shipped diagram (`edgeStyle = "direct"` and `"rectilinear"`)
renders exactly as it does today. No test, fixture, or documented behavior is affected.

---

## 6. Migration Path

This document ships no code change, and unlike the sibling design document, does not yet commit
to a specific next-session implementation -- it commits to a **second spike**, narrower in scope
than "a full paradigm replacement":

1. **Next session (if picked up): a second, bounded feasibility spike.** Adapt
   `igraph::layout_with_sugiyama()` (add `igraph` to `Suggests`, matching the `kinship2`
   reference-only precedent if it stays investigation-only, or as a real dependency if the
   candidate is judged worth shipping) OR a properly-ported Brandes-Köpf horizontal coordinate
   assignment to this project's own mating-unit-forest data structures. Test against the SAME two
   fixtures this spike used (the synthetic example, checked for crossings; the real 375-individual
   fixture, measured with the SAME faithful full-pipeline metric this document established) so
   results are directly comparable across all three candidates now on record (bounded-lookahead,
   barycenter/median, and whatever this next one is).
2. **That second spike's own close-out decides the campaign question**, exactly as this spike's
   own predecessor scoped it (`docs/planning/pedigree-diagram-sibling-subtree-width-plan.md` §6
   item 2) -- draft (or explicitly decline, with reasoning) a `PEDIGREE_DIAGRAM_LAYOUT_
   CAMPAIGN.md`-style document only once a working, non-regressing candidate exists.
3. **This document, its evidence doc, and the sibling design document together are that second
   spike's own Pre-RED starting point** -- the two rejected candidates' specific failure
   mechanisms (edge crossings; hub-node convergence instability) do not need to be rediscovered,
   and the faithful full-pipeline measurement methodology (§1.5's table) should be reused
   as-is, not re-derived.

---

## 7. Verification Plan

Not applicable in the classic build/test sense -- this document ships no production code change.
This session's own verification obligations, discharged:

- The evidence document
  ([`pedigree-diagram-nonrigid-layout-spike-evidence.qmd`](pedigree-diagram-nonrigid-layout-spike-evidence.qmd))
  renders clean via `quarto render` (confirmed this session, 0 errors) -- this document's build
  equivalent per `SAFEGUARDS.md` "Verify the Build Equivalent" (a documentation deliverable).
  Re-render it to reproduce every number and figure cited above.
- The seed reproduction was cross-checked against the REAL shipped `.positionMatingUnitForest()`
  at both scales (synthetic example and real fixture), confirmed byte-identical (max diff 0 at
  both), before any comparison built on it was trusted.
- The faithful full-pipeline metric was cross-checked against Track 6's own independently
  published baseline (9/251, 3.6%, max 4,121.25) and reproduced it exactly, confirming the
  measurement methodology itself (not just the seed) is correct.
- `git status` confirms no `R/`, `tests/`, or other package-source file is touched by this
  session's changes -- consistent with a spike deliverable that recommends no production code
  yet.

---

## 8. Explicitly Out of Scope (report, don't fix here -- `PROJECT_LEARNINGS.md` Learning 382)

- **The S583 "union outside its own parents' x-range" item** -- deliberately kept out of scope by
  the sibling design document (§8) and not folded in here either; a distinct axis of the same
  broader positioning problem space, with its own open `BACKLOG.md` entry.
- **A third candidate implementation** (e.g. an actual `igraph`-based or Brandes-Köpf-based
  prototype) -- not attempted this session, matching the "one candidate per spike" scope this
  session's own `BACKLOG.md` item set. Scoped as the recommended next spike (§6), not started
  here.
- **Root-causing every one of the 15 candidate-regressed edges individually** -- only the single
  worst offender (`__union_69`) was diagnosed (§1.6), sufficient to identify the general
  structural cause (high-mate-count hubs) without needing to trace all 15.

---

## 9. Owner ratification record

Presented via `AskUserQuestion` after the full investigation above (both fixtures, the
hyperparameter sweep, and the hub-node diagnosis) was complete:

- [x] **Not feasible; recommend a second spike using a proven library** -- reject this session's
      candidate; recommend the next attempt adapt an established, convergence-proven
      implementation (e.g. `igraph::layout_with_sugiyama()`) rather than hand-roll another one;
      defer the campaign document until that spike has evidence
- [ ] Not feasible; close this investigation, document as inherent -- treat 2 independently-failed
      candidates as sufficient evidence to stop pursuing further spikes on this thread
- [ ] Hold -- tune this candidate further before concluding (e.g. per-node adaptive damping, a
      Gauss-Seidel variant)

Owner selected **"Not feasible; recommend a second spike using a proven library."** This document
and its recommendation (§2, §6) reflect that selection.
