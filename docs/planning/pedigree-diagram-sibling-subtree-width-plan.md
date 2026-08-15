# Pedigree Diagram: sibling subtree-width asymmetry

**Status:** DESIGN, session S588 (2026-08-15). **Decision: COMMIT to a redesign -- recommend
replacing the current rigid-subtree layout paradigm with a non-rigid/constraint-aware one, scoped as
a dedicated follow-up effort (§6, §9). This session ships no code -- the plan is the deliverable, per
the project's planning/implementation session boundary.**

**Mid-session correction (owner-directed, transparently recorded):** this document's decision was
originally ratified as DEFER -- no fix, file a low-priority tracking issue, matching issue #141's own
"premature optimization" framing (see §9 for the full original ratification record, kept rather than
deleted). The owner corrected this mid-session: "these layout issues are a high priority and may
require a lot of work -- the work cost is not a deterrent." That correction changed the recommendation
below from DEFER to COMMIT; it did not change any of this session's own technical findings (the
tested candidate is still a real regression -- see §1.5, unchanged by the correction). Re-ratified
via a second `AskUserQuestion` (§9).

**Origin:** `BACKLOG.md` Housekeeping (found S576, 2026-08-14, incidental to Track 6's own empirical
validation of the child-centered union-position design,
`docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md` §1.4/§8) -- explicitly
flagged there as needing its own dedicated design session, distinct from and not resolved by Track
6's own fix, because "even a union perfectly centered between its children cannot keep both edges
short when the children themselves are positioned far apart."

**Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` (matching this project's
own established precedent for pedigree-diagram positioning-algorithm decisions -- Track 6's own plan
document lists 6 prior sessions that made the same call for the same reason: this is a
technical/algorithm-correctness decision, not a panel/visual-arrangement one).

**Evidence document:** `docs/planning/pedigree-diagram-sibling-subtree-width-evidence.qmd` (a
runnable Quarto document -- render it directly to reproduce every number and figure cited below,
rather than trusting this document's prose).

---

## 1. Context

### 1.1 What is already decided (do not re-litigate)

- Track 6's child-centered union-position fix (`.positionMatingUnitForest()`'s `finalUnitX` formula)
  is ratified and shipped (S578). This document does not revisit that decision -- it addresses the
  residual, structurally distinct problem Track 6's own §1.4/§8 explicitly carved out as out of
  scope.
- Issue [#141](https://github.com/rmsharp/nprcgenekeepr/issues/141) ("upgrade D3's tree-positioning
  merge to Buchheim-Jünger-Leipert if profiling shows a real need") already exists and covers a
  **different** concern on the **same function** -- Walker's algorithm's worst-case O(n²) *runtime*
  on pathological tree shapes. That issue is explicitly "not scheduled," deferred pending profiling
  evidence. **This document's problem is not that one.** Buchheim-Jünger-Leipert produces the
  *identical layout* to a correctly-implemented Reingold-Tilford/Walker merge in less time -- it
  would not change the sibling-spacing numbers investigated here at all, since the phenomenon is a
  property of the *layout the algorithm computes*, not how long it takes to compute it. The two
  issues should stay separately tracked (see §9); do not fold this one into #141's scope.

### 1.2 What this document decides

Whether a **low-risk** algorithmic change to `.positionMatingUnitForest()` (`R/makePedigreeDiagramData.R`,
the recursive contour-merge shared by every diagram render regardless of `edgeStyle`) can reduce how
far direct siblings land from each other when their descendant-subtree sizes differ -- without
introducing new defects (crossings, real-fixture regressions) worse than the problem it fixes.

### 1.3 The measured phenomenon

Track 6's own §1.4 (measured against the real 375-individual bundled fixture,
`inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv`, *after* Track 6's own fix): of 251 child
edges, 9 (3.6%) still exceed a 200-scaled-unit horizontal offset from their own union's position,
concentrated in unions with only 2-3 children. Example cited there: `__union_15`'s 2 children sit
at raw `x` 29.88 and 98.56 -- a 68.68-raw-unit gap between direct siblings.

This session confirmed the same mechanism independently (`docs/planning/pedigree-diagram-kinship2-
fidelity-remediation-plan.md`-class reproduction was not attempted -- see §1.4 below for why a
**synthetic**, not the real fixture's own subgraph, was used) and additionally established, **new
evidence beyond Track 6's own framing**, that:

1. The gap is not simply a function of *descendant count* -- `__union_15`'s own 2 children have
   nearly identical descendant counts (8 vs. 9, measured live) and identical max generation depth
   (7 vs. 7), yet still produce a 68.68-unit gap. The mechanism is about how *wide* a subtree's
   descendants branch at shared generation rows, not how *many* descendants it has.
2. The layout `.positionMatingUnitForest()` produces at this scale is a **correct, non-overlapping**
   layout -- the connecting lines remain fully traceable and unambiguous; the diagram is wider than
   it needs to be, not misleading. This distinguishes the severity of this finding from Track 6's
   own original problem (a union rendered so far from its own children that the connecting line's
   direction could be misread) and from the sibling BACKLOG item "union outside its own parents'
   x-range" (S583, also open, a genuine kinship2-parity gap) -- see §8.

### 1.4 Why a synthetic reproduction, not the real fixture's own subgraph

`__union_15`'s subgraph cannot be cleanly isolated: `getPedDirectRelatives()` (the project's own
full-connected-component walk) returns essentially the entire 375-individual fixture starting from
`__union_15`'s parents, because the real pedigree is one large connected component through many
generations of collateral relatives. A small, hand-constructed 13-individual pedigree
(`P1`x`P2` -> children `A` [a childless leaf] and `B` [anchors a 2-generation-deep, 2-child-per-union
subtree]) isolates the mechanism cleanly for visual inspection while remaining small enough to
reason about by hand. The real fixture is still used directly for the candidate's own real-scale
regression check (§1.5, §3).

### 1.5 Candidate mitigation tested and rejected

One candidate was identified and empirically tested (full detail: evidence doc §"Candidate
mitigation"): **bounded-depth contour-merge lookahead** -- only compare sibling subtrees' contours
within `K` generations of the merge point (instead of the full remaining depth), trusting the
existing row-based `sweepMinSep()` post-pass (Track 3) to resolve any resulting same-row crowding at
deeper generations.

- **On the synthetic example:** `K = 0` closes the `A`-`B` gap from 2.5 raw units (`K = Inf`, matches
  the shipped algorithm) to 1.0 -- a real, measured improvement in isolation.
- **But it introduces a strictly worse defect:** at `K = 0`, `B1`'s and `B2`'s own connecting lines
  **cross** in the rendered diagram (evidence doc, "Candidate rendering at K = 0") -- a defect the
  shipped algorithm's rendering of the identical data does not have. Edge crossings break the one
  property a pedigree diagram cannot compromise on: an uninterrupted line the reader can trace
  parent-to-child without ambiguity.
- **And it regresses, rather than improves, the real 375-individual fixture** under a simplified but
  internally-consistent proxy measurement: `K = 0`'s violating-edge percentage (3.2%) is *higher*
  than `K = Inf`'s (0.8%) under the same methodology -- the opposite direction from the synthetic
  example. (Caveat, stated in the evidence doc too: this proxy measurement does not apply the
  shipped algorithm's `orderBySex` swap or final de-collision pass, so its absolute percentages are
  not directly comparable to Track 6's own published 3.6% baseline figure -- the *trend* across `K`
  under this one consistent methodology is the evidence being relied on here, not the absolute
  numbers.)

### 1.6 Why no low-risk *tuning* of the current algorithm can fix this (found after the mid-session correction)

The bounded-lookahead candidate's failure is not just "the wrong depth cutoff" -- it reveals a
structural limit. `.positionMatingUnitForest()` uses a **rigid-subtree** model: every subtree is
treated as an opaque, immovable block, and two adjacent subtrees are placed exactly as close as
their *full* contours (silhouettes, every generation row) allow without ever overlapping.
`mergeSubtrees()`'s own `needed <- max(contour$right[finite] - ci$left[finite] + minSep)` computes
the **mathematically minimal** safe gap between any two subtrees under that model -- there is no
slack left to recover by tuning a parameter. The bounded-lookahead experiment did not find "a smaller
safe gap the shipped algorithm was leaving on the table" -- it found a gap that is smaller but
**unsafe**, and the row-based `sweepMinSep()` post-pass papered over the resulting collision in a
way that (for `B1`/`B2`'s own deeper subtrees) produced a crossing instead of a clean re-space.

**This rigid-subtree model is the same one used by Reingold-Tilford (1981), Walker (1990), and
Buchheim-Jünger-Leipert (2002)** -- the algorithm family issue #141 itself names as the target for a
future *runtime* improvement. None of the three would fix this: they are faster ways to compute the
*same* rigid-subtree-minimal-gap layout, not a different, tighter layout. **Genuinely closing this
gap requires abandoning the rigid-subtree model** -- allowing subtrees to interleave or compact
against each other locally, which needs an algorithm with real crossing-avoidance logic built in
(closer to constraint-based or force-directed graph layout than to any tidy-tree variant), not an
adjustment to the current one.

---

## 2. Decision

**Commit to a redesign.** Given the owner's explicit priority correction (work cost is not a
deterrent), this document recommends pursuing a real fix rather than deferring -- but a real fix
means replacing the rigid-subtree layout paradigm itself (§1.6), not tuning the current algorithm,
and that is genuinely large, uncertain-scope work. This session's own deliverable stays the plan:

1. **The next session is a bounded feasibility spike, not an open-ended redesign.** Its own,
   single-session deliverable: prototype ONE candidate non-rigid/constraint-aware layout approach
   (§4 names the leading candidate direction) against both this document's synthetic example
   (checking for crossings, not just gap size -- Learning 596) and the real 375-individual fixture
   (checking for regressions, not just improvement on the toy case) -- exactly the two-pronged
   verification this session's own investigation validated as necessary (§1.5). No production code
   ships from the spike either; it answers "is this feasible at all, and roughly how large," closing
   the uncertainty this document cannot close without prototyping.
2. **That spike's own close-out decides whether a dedicated `*_CAMPAIGN.md` is warranted**
   (`docs/methodology/workstreams/TEMPLATE_CAMPAIGN.md`) per `SESSION_RUNNER.md`'s own
   Multi-Session Campaign Check -- this document does not draft one now, since drafting a
  multi-phase campaign with real per-phase completion criteria requires knowing, from the spike,
  what the new algorithm's shape actually is. Committing to a campaign structure before that
  evidence exists risks the same "plan without evidence" failure this project has repeatedly guarded
  against elsewhere (Track 6's own pre-RED discipline; the grep-based-inventory requirement for
  migration plans).
3. **The companion GitHub issue is filed as a genuine, prioritized tracker** (§9), not a deferred
   "premature enhancement" placeholder -- labeled and worded to reflect that a follow-up session is
   expected, not merely permitted.

---

## 3. Rationale

- **The owner's own priority signal governs the defer-vs-commit axis.** Cost/effort is explicitly
  not a deterrent for this item -- that removes the primary reason (§1.6's "large rewrite,
  disproportionate to a 3.6%, non-misleading gap") the original DEFER recommendation relied on. The
  technical facts underneath are unchanged by that correction (see below); what changed is which
  facts are dispositive.
- **The one candidate identified and tested is still a real regression, not a fix -- this is why the
  next step is a spike, not straight-to-implementation.** §1.5/§1.6 show the rigid-subtree paradigm
  has no low-risk tuning available; a genuine fix needs a different paradigm entirely. That is a
  larger, less certain undertaking than "add a parameter" -- exactly the shape of work that benefits
  from its own bounded feasibility spike (§2 item 1) before committing to a full campaign, so that
  the real shape and size of the work is known before it is scoped in detail.
- **The measured real-world impact remains small and non-misleading** (9/251 edges, 3.6%, on the
  real fixture, all still correct/traceable) -- this bounds how urgent the spike is relative to other
  `BACKLOG.md` work, even though the owner has now marked it high priority; it does not change
  whether pursuing a fix is worthwhile now that cost is not the limiting factor.
- **Issue #141 remains a distinct, separately-tracked concern** (§1.1) -- a future spike/campaign
  session should not conflate "implement Buchheim-Jünger-Leipert for runtime" with "replace the
  layout paradigm for tighter packing"; §1.6 establishes they are not the same fix.

---

## 4. Alternatives Considered

| Alternative | Pros | Cons | Status |
|---|---|---|---|
| **Bounded-depth contour-merge lookahead** (tested, §1.5) | Simple, small isolated code change; measurably closes the gap on the toy example | Introduces edge crossings; regresses the real fixture's own measure under a consistent proxy; §1.6 shows this class of fix (tuning the rigid-subtree model) structurally cannot work | **Rejected** -- net regression, confirmed empirically; not revisited by the priority correction, since the defect is technical, not a cost/priority judgment |
| **Do nothing / accept as inherent** | Zero risk; matches issue #141's own established precedent for this same function | Diagrams with wide-asymmetry sibships stay wider than strictly necessary | **Superseded** -- this was the session's original recommendation before the owner's mid-session priority correction (§9); no longer adopted |
| **A fundamentally different, non-rigid width-allocation algorithm** (e.g. a constraint-based/compaction layout that allows subtrees to interleave, with explicit crossing-avoidance; or a force-directed layout constrained to generation rows) | The only direction identified this session that could plausibly close the gap without the rigid-subtree model's structural ceiling (§1.6) | Large rewrite of the shared core positioning algorithm; the biggest lift of the alternatives considered; unvalidated -- no prototype was built or measured this session | **RECOMMENDED -- scoped as the next session's feasibility spike** (§2 item 1, §9) |
| **A visual/interaction mitigation instead of a geometric fix** (e.g. a sibling-group visual affordance that doesn't change node positions) | Very low risk -- no change to positioning logic at all | Investigated only at the concept level, not prototyped; the shipped rectilinear sibship-bar edge style (issue #142, already shipped) already provides an unbroken traceable line between distant siblings, so it is unclear this would add anything beyond what already exists | **Deferred, low priority** -- a fallback if the spike (above) finds the paradigm change infeasible or too costly even with cost not being the primary constraint |

---

## 5. Impact Analysis

| System | Impact | Action Required |
|---|---|---|
| `R/makePedigreeDiagramData.R` (`.positionMatingUnitForest()`, `makePedigreeMatingLayout()`) | **None this session** -- a future spike/campaign session will touch this | None now; §6 scopes what's next |
| Pedigree Diagram Shiny tab (`R/modPedigree.R`) | **None this session** -- no behavior change | None now |
| `BACKLOG.md` | This design-session item is DONE; a new, high-priority follow-up item (the feasibility spike) replaces it | Mark the S576 item DONE citing this document; add a new READY item for the spike, tagged high priority per the owner's correction |
| GitHub Issues | New issue filed, as a genuine prioritized tracker (not deferred) | File at close-out (§9) |

**What does not change:** every shipped diagram (`edgeStyle = "direct"` and `"rectilinear"`) renders
exactly as it does today. No test, fixture, or documented behavior is affected.

---

## 6. Migration Path

This document ships no code change, but -- unlike the original DEFER decision -- it does commit to a
concrete next step:

1. **Next session: feasibility spike, one session, bounded scope.** Deliverable: a working prototype
   (script-level, not integrated into `R/`) of ONE non-rigid/constraint-aware layout candidate,
   tested against (a) this document's own 13-individual synthetic example -- rendered, checked
   visually for crossings, not just measured for gap size (Learning 596) -- and (b) the real
   375-individual fixture, measured for regressions using a *faithful* reproduction of
   `.positionMatingUnitForest()`'s actual final-position pipeline (including `orderBySex` and the
   final de-collision pass -- §8 notes this session's own proxy measurement was simplified; the
   spike should not repeat that simplification for its own go/no-go evidence). Close out with a
   clear verdict: feasible (name the candidate, rough size) or not (name why, and whether a
   different candidate is worth a second spike).
2. **Spike close-out decides the campaign question.** If the spike confirms feasibility, its own
   close-out should draft (or explicitly decline, with reasoning) a `PEDIGREE_DIAGRAM_LAYOUT_
   CAMPAIGN.md`-style document from `docs/methodology/workstreams/TEMPLATE_CAMPAIGN.md`, since a full
   paradigm replacement is very likely to span multiple implementation sessions (schema/contour
   representation, the merge algorithm itself, crossing-avoidance logic, re-verification of every
   existing pedigree-diagram test and E2E fixture, and the still-open S583 item this document
   deliberately left out of scope, §8 -- which the new paradigm may or may not resolve as a side
   effect, itself worth checking once a candidate exists).
3. **This document and its evidence doc are that spike's own Pre-RED starting point** -- §1.6's
   "why rigid-subtree tuning cannot work" finding does not need to be rediscovered; the spike should
   start from "what non-rigid model" rather than re-testing bounded lookahead.

---

## 7. Verification Plan

Not applicable in the classic build/test sense -- this document ships no production code change.
This session's own verification obligations, discharged:

- The evidence document (`docs/planning/pedigree-diagram-sibling-subtree-width-evidence.qmd`)
  renders clean via `quarto render` (confirmed this session, 0 errors) -- this document's build
  equivalent per `SAFEGUARDS.md` "Verify the Build Equivalent" (a documentation deliverable).
  Re-render it to reproduce every number and figure cited in §1.3-§1.5.
- `git status` confirms no `R/`, `tests/`, or other package-source file is touched by this session's
  changes -- consistent with a planning-session deliverable that recommends no implementation.

---

## 8. Explicitly Out of Scope (report, don't fix here -- `PROJECT_LEARNINGS.md` Learning 382)

- **The "union outside its own parents' x-range" BACKLOG item** (found S583, still open) -- a
  distinct, separately-tracked kinship2-parity gap (a union can render outside its own two parents'
  span, not merely off-center between them). Not addressed here; a different axis of the same
  broader "pedigree-diagram positioning" problem space, with its own open `BACKLOG.md` entry and its
  own likely-needs-its-own-design-session note.
- **The rectilinear sibship-bar's own visual overlap with unrelated same-row nodes** -- observed
  incidentally while producing this session's own rendering (the evidence doc's "nprcgenekeepr's
  current rendering" figure shows the sibship bar passing visually near `BM`, a spouse, not a
  child). Not investigated further -- an existing, already-shipped rendering characteristic of the
  `edgeStyle = "rectilinear"` sibship-bar mechanism (issue #142), orthogonal to the sibling-spacing
  question this document addresses, and not confirmed as a new defect distinct from already-known
  rectilinear-routing behavior.
- **A full, faithful re-measurement of the bounded-lookahead candidate against the shipped
  pipeline's exact final positions** (including `orderBySex` and the final de-collision pass) -- not
  performed this session (this is a design document, not an implementation attempt); the simplified
  proxy measurement in §1.5/evidence-doc is judged sufficient to support rejecting that one
  candidate, since the trend (worse, not better) is unambiguous even accounting for the methodology
  gap. A faithful re-measurement is owed for whatever NEW candidate the feasibility spike (§6)
  tests -- the spike should not repeat this session's own simplification.

---

## 9. Owner ratification record

### Round 1 (superseded -- kept for the record, not deleted)

- [x] **Defer, document, file issue** -- conclude no low-risk fix exists yet; document the
  phenomenon as inherent; file a companion GitHub issue mirroring #141's own "premature
  enhancement"-style framing, deferred until real usage evidence justifies the risk; no code changes
- [ ] Scope a bigger redesign effort now (don't decide the algorithm question; write this document
      concluding a real fix needs its own, larger future design session)
- [ ] Hold -- continue investigating a different algorithmic candidate before concluding

Ratified via `AskUserQuestion`, S588 (2026-08-15): presented all 3 options with the full evidence
(3 renderings shown directly -- kinship2 reference, nprcgenekeepr's shipped behavior, and the
bounded-lookahead candidate's rendering showing the introduced edge crossing -- plus the real-fixture
regression numbers) stated directly in the question. Owner selected "Defer, document, file issue."

### Round 2 (current, supersedes Round 1)

Immediately after Round 1 was ratified, the owner corrected: *"I may have answered you wrong.
Fixing these layout issues are a high priority and may require a lot of work. The work cost is not
a deterrent."* This session then established the additional §1.6 finding (no low-risk tuning of the
current rigid-subtree paradigm can work, full stop -- a fact independent of priority) and re-posed
the decision:

- [x] **Recommend a full redesign effort** -- commit to replacing the rigid-subtree layout paradigm
      with a non-rigid/constraint-aware one; scope it as its own follow-up effort (likely
      multi-session, possibly its own `*_CAMPAIGN.md`); this session still ends with the plan, not
      code, per the project's planning/implementation session boundary
- [ ] I (the assistant) prototype a candidate paradigm now, in this same session, before writing the
      final recommendation
- [ ] Also fold in the related S583 item ("union outside parent span") into one combined redesign
      effort

Ratified via a second `AskUserQuestion`, S588 (2026-08-15): owner selected "Recommend a full redesign
effort." The decision in §2 and the migration path in §6 reflect this round, not Round 1. S583 stays
explicitly out of scope for now (§8) -- not rejected as part of a future paradigm change, just not
folded into this document's own scope.

**Companion GitHub issue:** [#159](https://github.com/rmsharp/nprcgenekeepr/issues/159), filed
originally under Round 1's framing (labeled `enhancement` + `premature optimization`, "do not
implement speculatively"); updated at this session's close-out to reflect Round 2 -- reworded to
describe the feasibility spike as the concrete next step and the priority correction, with the
`premature optimization` label removed (see `CHANGELOG.md` for the exact edit).
