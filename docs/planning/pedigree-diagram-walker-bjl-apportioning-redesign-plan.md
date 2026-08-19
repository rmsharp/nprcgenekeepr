# Pedigree Diagram D3 Layout: Complete Walker/Buchheim–Jünger–Leipert Redesign — Architecture & Migration Plan

**Suggested path:** `docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md`
**Status:** PLANNING ONLY. No production code touched. Implementation begins in a separate future session (Phase 1 below). **This is the critique-repaired final version.** The first draft went through this session's own 3-lens adversarial critique (correctness/failure-mode, migration/blast-radius/TDD, algorithm-fidelity) before publication — see "This plan's own adversarial critique," immediately below, for what it found and how this version responds, matching this project's own established transparency precedent for algorithm-level planning documents.
**Supersedes/completes:** GitHub issue #141; closes the redirect recorded in `docs/planning/pedigree-diagram-single-child-union-parent-coincidence-investigation.md` §11.
**Owner directive this plan executes:** *"go with CraneFoot / the Reingold-Tilford–Walker–BJL family this whole approach is built on"* (S609, 2026-08-18, quoted in full in §11 of the source investigation; re-verified directly against `docs/planning/pedigree-diagram-single-child-union-parent-coincidence-investigation.md:492` this session).

---

## This plan's own adversarial critique (this session)

Per this project's own transparency precedent for algorithm-level planning — and matching the adversarial-critique discipline the six prior *implementation* attempts (S598–609) were already held to — this plan's first draft was reviewed by 3 independent lenses (correctness/failure-mode, migration/blast-radius/TDD, algorithm-fidelity) before publication. **All three returned `designSound: false`.** None found the plan's overall shape wrong — the additive-first/cutover-last phasing, the GPL-avoidance license reasoning, the BJL-over-Walker choice, and the elimination of the *substitution*-collision pattern that sank Attempts 1–4 were each independently corroborated. Each found specific, concrete content defects, one of them foundational enough to change the Migration Path itself, not just the prose.

**What the critiques got right, credited before the fix list:**

- **Correctness lens** confirmed the plan's elimination of Track 6's `finalUnitX` substitution, Track 3's clamp, and `.computeDupNudge()` genuinely dissolves the specific collision shape that doomed Attempts 1–4 (S598–601): a locally-computed correction silently overwriting an already-correct value computed elsewhere. But it found the plan's proposed mechanism for reconciling cross-branch and same-generation conflicts (a "global LEFTNEIGHBOR table") does not actually deliver the "correct by construction" guarantee the plan used to justify deleting every remaining safety net, and it produced a concrete, realistic adversarial fixture the pseudocode as drafted does not resolve correctly.
- **Migration/TDD lens** independently re-verified a large, load-bearing sample of this plan's own citations directly against the repository — every one checked out exactly as claimed, down to line numbers. It found the phase structure itself sound but under-scoped in two places: Phase 3 implied a 6-file cutover against this project's 5-file guardrail with one file's fate never addressed, and the plan's single most load-bearing, least-automatable verification step (live-rendered confirmation) was specified only in prose, with no concrete deliverable, despite the plan itself calling it essential.
- **Algorithm-fidelity lens** independently verified the pseudocode against Walker's own 1989 primary source and two real, working tree-layout implementations (one built directly from the BJL paper). It confirmed the overwhelming majority of the port — `firstWalk`, the leaf case, the centering rule, and critically the `moveSubtree`/`executeShifts` linear-time mechanism itself — is a faithful, verified port, not "Walker relabeled." But it found one centrally-positioned claim stated backwards (real BJL *replaces* Walker's global per-level lookup with a purely local sibling lookup; it does not "keep it unchanged," as the draft asserted), and an independent structural gap: this plan's own duplicate-participation recommendation makes a single node's own `CHILDREN()` set span two different rendered generations, which neither paper's no-overlap proof anticipates.

**How this version responds.** Every "major" finding is either fixed in place below or moved honestly into "Open Questions for a Future Session" *together with* a concrete Migration Path change for how it actually gets resolved — not left as a bare caveat the rest of the document quietly ignores. "Minor" findings are fixed where straightforward. The Evidence-Based Inventory, Migration Path completion criteria, and Verification Plan are not weakened anywhere below; several are strengthened (a new blocking research phase, a concrete reusable verification helper, stricter test-oracle requirements, atomic-green cutover commits). Disposition of every finding:

| # | Critique | Severity | Finding (one line) | Disposition |
|---|---|---|---|---|
| C1-1 | Correctness | major | `CHILDREN()` can mix a same-gen and a next-gen edge under one node (individual→own union vs. individual→D5 child) | **Fixed by restructuring**: elevated to the plan's top structural risk; a new Phase 1b is required before Phase 2 begins (§Decision, §Migration Path) |
| C1-2 | Correctness | major | The proposed global-LEFTNEIGHBOR fix has no counterpart in BJL/d3-hierarchy and breaks `moveSubtree`/`executeShifts`'s sibling-indexed math | **Fixed**: the false attribution is removed; the mechanism is reopened as Phase 1b's own research question, not asserted as already solved (§Decision, §Algorithm) |
| C1-3 | Correctness | major | Safety-net removal (sweep/epsilon-pass) was justified by an unproven "correct by construction" claim | **Fixed**: removal is now conditional on Phase 1b/Phase 2's own empirical gate passing on the real fixture, never asserted in advance (§Decision "which patches," §Migration Path Phase 2/3) |
| C1-4 | Correctness | minor | Phase 1's d3-hierarchy cross-check cannot validate the forest-specific extension | **Fixed**: scope of what the cross-check does/does not cover is now explicit; 1b gets its own, separate validation requirement (§Migration Path Phase 1b) |
| C1-5 | Correctness | minor | Full-width duplicate participation amplifies the mixed-gen gap; the PRE-RED gate needs to be told this | **Fixed**: the duplicate-width open question is now explicitly sequenced after, and dependent on, 1b (§Decision, §Open Questions 1) |
| C1-6 | Correctness | nit | Post-trim founders might carry nonzero gen, hitting the mixed-gen problem even at the forest root | **Investigated further this session**, not merely noted — see Evidence-Based Inventory for a directly-traced, more concrete mechanism than originally speculated; added as a required Phase 1b test case |
| C2-1 | Migration/TDD | major | Phase 3 implies ≥6 files against the 5-file guardrail; `test_positionMatingUnitForestBJL.R`'s fate unaddressed | **Fixed**: explicit commit-by-commit file lists (4 files, then 2), with the BJL test file's merge-then-delete disposition stated (§Migration Path Phase 3) |
| C2-2 | Migration/TDD | major | The 3a/3b split can leave the suite RED at a phase checkpoint from stale literals, not an intentional RED test | **Fixed**: re-sequenced so each commit independently must leave a clean regression read; the split is now conditional on confirming Track 1/2's literals are actually unaffected, never assumed (§Migration Path Phase 3) |
| C2-3 | Migration/TDD | major | Phase 1's non-golden synthetic tests had no stated oracle-strength requirement — could pass vacuously | **Fixed**: an explicit strong-oracle requirement now covers every Phase 1 synthetic fixture, not only the Walker worked example (§Migration Path Phase 1a) |
| C2-4 | Migration/TDD | major | The live-render chromote check was prose-only, never captured as a reusable deliverable | **Fixed**: a concrete, named, reusable helper is now a first-class Phase 2 deliverable, reused (not reinvented) in Phase 3 (§Migration Path Phase 2) |
| C2-5 | Migration/TDD | minor | Duplicate-node non-participation was mis-attributed to D1; it is actually a D3 decision | **Fixed** (§Decision, §Evidence-Based Inventory) |
| C2-6 | Migration/TDD | minor | `nextLeft`/`nextRight`/`commonAncestor` are used but never defined | **Fixed**: explicit definitions added, carrying the same not-yet-primary-source-verified caveat as the rest of `apportion` (§Algorithm) |
| C2-7 | Migration/TDD | minor | Phase 2 implicitly treats Phase 1's engine file as frozen | **Fixed**: an explicit note that revisiting it mid-Phase-2 is expected, and stays within file-count bounds (§Migration Path Phase 2) |
| C2-8 | Migration/TDD | minor | Phase 4 carries comparable file-count risk to Phases 1–3 but had no split fallback | **Fixed**: added (§Migration Path Phase 4) |
| C3-1 | Algorithm-fidelity | major | "LEFTNEIGHBOR… Walker's own, kept unchanged by BJL" is stated backwards — BJL replaces it with local-sibling lookup | **Fixed**: corrected throughout; same underlying issue as C1-2, fixed together (§Decision, §Algorithm) |
| C3-2 | Algorithm-fidelity | major | The duplicate/phantom-leaf recommendation makes one node's children span 2 gens, unaddressed by either paper's no-overlap proof | **Fixed by restructuring**: same underlying issue as C1-1, fixed together; additionally credits the *current* code's own gen-indexed contour arrays as already, narrowly, immune to this (§Decision, §Evidence-Based Inventory) |
| C3-3 | Algorithm-fidelity | minor | The mating-unit gen formula is stated two different (equivalent, but uncross-referenced) ways in two sections | **Fixed**: cross-reference added, citing the invariant that makes the two equivalent (§Algorithm) |

The cluster C1-1/C1-2/C3-1/C3-2 — all one underlying gap — could not be *fixed* outright in the sense of supplying a verified replacement mechanism: doing that is implementation research, outside a planning session's mandate, and inventing a plausible-looking fix here would repeat exactly the "test-green, not actually right" pattern that sank six prior attempts, just one level up the document stack. It is handled the way the task instructions require: named plainly as this plan's single biggest open technical risk (§Decision, §Rationale, §Open Questions 1), *and* given a concrete, gated place in the Migration Path to get resolved (Phase 1b) rather than left as an unacted-upon caveat.

---

## Context

### Problem statement

`R/makePedigreeDiagramData.R`'s `.positionMatingUnitForest()` (lines 717–1226, read in full this session, both in the prior research and directly again this session) computes pedigree-diagram node coordinates through a **recursive contour-merge followed by a five-stage sequential patch stack**, not a complete, self-reconciling tree-positioning algorithm:

1. **`mergeSubtrees()`/`finalizeNode()`** (790–821): a post-order, pairwise-fold merge across each node's own direct children, with contour arrays (`left`/`right`) indexed by **absolute display generation** (`gen + 1L`, arrays of length `maxGen+1`), not recursive depth. This part is a genuine, reasonably faithful single-parent-at-a-time adaptation of Reingold–Tilford's own two-subtree contour merge, generalized to n-ary via **repeated pairwise folding**: subtree `i` is merged against the *already-merged* contour of subtrees `1..i-1` by shifting subtree `i` as a rigid whole. `finalizeNode()`'s own centering rule — `ownX = (xs[1] + xs[length(xs)]) / 2` — is *exactly* Walker's own internal-node `PRELIM` rule (midpoint of the leftmost and rightmost child), already correctly implemented for the **provisional** pass.
2. This provisional value is then **discarded and recomputed from scratch, repeatedly**, by a five-step sequential patch stack (all inside the same function, in this exact order, line numbers re-confirmed by direct re-read this session): `sweepMinSep()` (997–1015, a global per-generation minimum-separation sweep over real individuals only) → an `orderBySex` left/right swap of two real parents' `x` (1054–1078, issue #145) → **Track 6's `finalUnitX` override** (1099–1107, re-derives each mating unit's `x` as the midpoint of its *final*, already-swept children — silently reusing the same midpoint formula `finalizeNode()` already computed once, now applied to different, later-mutated input) → **Track 3's parent-span clamp** (1109–1144, forces `finalUnitX` into `[min(parentX), max(parentX)]`) → **`.computeDupNudge()`'s** Track-3-Engagement-Gated nudge (1146–1173) → a final all-node de-collision epsilon pass (1187–1210, nudging any exact `x` coincidence apart by `1e-3`) → a final re-application of `sweepMinSep()` (1221–1223) to repair what the epsilon pass just eroded.

**Root cause, confirmed independently by four lines of evidence now** (the failure history's own root-cause finding; the algorithm research's literature comparison; my own direct reading of the code this session; and this session's own 3-lens critique of the first draft, which found the *replacement* pseudocode's own proposed reconciliation mechanism was still susceptible to a related, if more subtle, version of the same class of problem — see "Decision" below): every stage after step 1 computes a correction using **only locally available information**, and **nothing in the pipeline ever re-derives an earlier stage's output once a later stage changes an input it depended on.** A real Walker/Buchheim–Jünger–Leipert (BJL) implementation has no analogue to this sequence at all — every node's position is computed **exactly once**, via a genuine apportion/reconciliation mechanism woven into the *same* recursive pass that produces the provisional value, not bolted on afterward. Six independent design attempts (S598, S599, S600, S601, S609×2) to fix defects in this stack by adding a *seventh* local correction have **all failed adversarial critique**, each discovering a new way two locally-computed corrections collide (full history in §"Evidence-Based Inventory" below). The owner-directed conclusion, reached only after re-reading the primary algorithm-family sources directly, is to stop patching and implement a complete, correct family member instead — and this document's own first draft needed a second, harder look before its *own* replacement mechanism could be trusted, which is exactly the discipline this section's critique table above is applying.

### Constraints

1. **MIT license, no GPL dependency.** `igraph::layout_as_tree()` (Reingold–Tilford) is `GPL (>= 2)`; `data.tree` is GPL; `ggraph` is MIT but hard-`Imports` `igraph` transitively. No off-the-shelf R tree-layout package is available without introducing a GPL dependency — confirmed independently by the original Option 2 design session (`pedigree-diagram-option2-layout-design-plan.md` §2.2, re-affirmed in the redirect's own §11 point 3). Hand-implementing from the published literature (Reingold–Tilford 1981; Walker 1990; Buchheim–Jünger–Leipert 2002) is the only license-clean path.
2. **Must not silently regress the pinned regression-number checklist** (full list in Evidence-Based Inventory §6 below) — any number that changes must be **consciously re-pinned with a stated reason**, not silently patched or left broken.
3. **Must keep Track 1 (`.addRectilinearWaypoints()`) and Track 2 (`.resolveEdgeNodeCollisions()`) compatible.** Both are structurally orthogonal to the *value* `.positionMatingUnitForest()` returns — they depend only on the **output contract shape**: one numeric `x` and one `gen`-derived `y` (`gen * yScale`, an exact integer multiple) per node id, `sibshipBarFraction`'s intermediate row staying uniquely non-integer-multiple, and exact floating-point `y` equality for nodes nominally on the same generation row. Any redesign preserving this contract shape needs zero changes to either Track.
4. **Grep-confirmed zero downstream dependents on specific coordinate values.** `.buildMatingUnitForest`, `.positionMatingUnitForest`, and `.computeDupNudge` each have exactly one production call site, all inside `makePedigreeMatingLayout()` (1307–1652, the sole `@export`ed consumer). `R/modPedigree.R` touches only reserved-id-prefix strings for click-selection, never `x`/`gen` values. No screenshot/golden-image test exists for the Diagram tab (confirmed by grep this session: no `_snaps/` entries and no `screenshot`/`expect_snapshot` calls in `test-e2e-pedigree-module.R` or `test-e2e-pedigree-detailed.R`).

### Current state (precise, from direct reading of `R/makePedigreeDiagramData.R:300–1226`, re-confirmed a second time this session)

**`.buildMatingUnitForest()`** (347–523, D1/D2 — **not in scope for this redesign**, described here only as the fixed input the new algorithm consumes): transforms a pedigree into a CraneFoot-style forest. Every `(sire, dam)` pair with ≥1 child becomes one `__union_N` node; every child is re-parented to a single edge from that union; an individual belonging to 2+ mating units anchors exactly one (D2's `preferAnchor()`: gen → mate count → radix-order id tie-break, `R/makePedigreeDiagramData.R:403–414`) and gets a non-participating `__dup_realId_k` node at each other. A dangling parent (no row in `ped`) never anchors; if both parents are dangling, `anchor`/`nonAnchor` are `NA` (issue #154) and the unit is positioned as its own root. `matingUnits$gen <- pmax(genOf[sire], genOf[dam], na.rm = TRUE)` (line 456–458), and D2's own anchor preference explicitly prefers the **deeper**-gen parent first (`preferAnchor()`: `if (ga != gb) return(ga > gb)`) — this is *why* `genOf[[anchor]] == unitGen` always, exactly, by construction, re-verified directly this session (not merely re-stated from a prior pass). Returns `matingUnits`/`duplicates`/`childEdges` data frames — structure only, no coordinates.

**`.positionMatingUnitForest()`** (717–1226, D3/D4/D5 — **the redesign's target**): the pipeline described in "Problem statement" above, in exact execution order:

| Step | Lines | What it does |
|---|---|---|
| Contour-merge (`mergeSubtrees`/`finalizeNode`) | 790–821 | Provisional `x`, gen-indexed contours, Walker-equivalent midpoint centering |
| Free-pass folding | 823–849 | A never-anchoring individual with no D5 child folds into their one unit's merge as a leaf, **already at the unit's own gen, not the individual's recursive depth** (`leafContour(unitGenOf[[unitId]])` inside `positionUnit()`, line 895 — re-confirmed by direct read this session; see the new evidence item in the Inventory below) |
| `dispGenOf` override (issue #143) | 851–874 | Every non-anchor occurrence renders at its mating unit's gen, not its own raw gen |
| Recursive descent (`positionUnit`/`positionIndividual`) | 889–966 | Top-down `assignAbs()` converts relative offsets to absolute provisional `x` |
| `sweepMinSep()` (Track 3) | 997–1015 | Global per-display-gen minimum-separation sweep, **real individuals only** |
| `orderBySex` swap (issue #145) | 1054–1078 | Post-hoc value-swap of exactly 2 real parents' `x`, sequenced *before* the next step specifically so it doesn't go stale |
| Track 6 `finalUnitX` override | 1099–1107 | Re-derives union `x` = midpoint of **final**, already-swept children — structurally redundant re-application of step 1's own formula |
| Track 3 parent-span clamp | 1109–1144 | Forces `finalUnitX` into `[min(parentX), max(parentX)]`, skipped for dangling-parent units |
| `.computeDupNudge()` application | 1146–1173 | Track-3-Engagement-Gated reclamp for a narrow duplicate-occurrence case |
| Sync + `dupX` | 1175–1185 | `nodes$x` set from `finalUnitX`; `dupX = finalUnitX[unit] + minSep*0.4` — computed **entirely outside the recursive merge**, not via `childEdges`/`CHILDREN()` at all (see Decision's duplicate-node correction below) |
| Final de-collision epsilon pass | 1187–1210 | `(gen, id)`-radix-ordered, nudges any exact coincidence apart by `1e-3`, across all node types |
| Re-applied `sweepMinSep()` | 1221–1223 | Repairs gaps the epsilon pass just eroded, real individuals only |

`minSep = 1L` (778, abstract units); `sibshipBarFraction = 0.4` (Track 1's own constant, `:1759`, untouched by this redesign).

---

## Decision

### Which family member: Buchheim–Jünger–Leipert, and why concretely

**Recommendation: implement BJL (2002), not plain Walker (1990), as the default target — with one honest qualification this critique round added.**

1. **BJL and Walker share their entire outer shape.** Per the algorithm-fidelity critique's own independent verification against Walker's 1989 primary source and two real implementations: `firstWalk`/`secondWalk`, the leaf case, and the "parent = midpoint of leftmost/rightmost child" centering rule are **identical** between the two, and the `moveSubtree`/`executeShifts` linear-time mechanism is a faithful port, not a relabeling. The only thing BJL replaces is the `apportion` mechanism's comparison-partner sourcing and bookkeeping. Choosing BJL therefore costs nothing in overall algorithm shape for the *genuine-tree* core.
2. **BJL provides Walker's own correctness properties, plus a provable bound Walker lacks, for a bounded extra implementation cost — for the genuine-tree core.** This part of the justification is now independently confirmed, not merely asserted: `firstWalk`, `moveSubtree`, and `executeShifts` are verified faithful (algorithm-fidelity critique). **Qualification added this round:** the *forest-specific* extension this project needs (§"The gen-vs-depth adaptation" below) is not yet designed, so BJL's provable O(n) bound is established for the genuine-tree core only — whether the full pedigree-forest adaptation retains it depends on what Phase 1b's mechanism turns out to be. This does not change the recommendation (a bounded core plus an unbounded, presumably small, forest-reconciliation add-on is still very likely to beat Walker's O(n²) worst case in practice), but the plan no longer states the bound as settled for the adapted algorithm — only for the part actually verified.
3. **This project's own duplicate/free-pass re-attachment mechanism makes irregular tree shapes *more* likely here than in an arbitrary tree, undercutting issue #141's original deferral reasoning.** Issue #141 deferred BJL because "a straightforward recursive contour-merge is very unlikely to hit the specific pathological-shape conditions." But this forest is not an arbitrary tree: a duplicate or free-pass node can be re-attached at a display generation shallower than its recursion depth, and a highly polygamous anchor (this project's own real fixture has individuals anchoring up to 5 distinct mating units, `WCPXHD` at `anchorCounts[["WCPXHD"]] == 5L`) produces exactly the "one very deep, narrow lineage alongside one very wide, shallow one" shape issue #141 names as pathological. This is not a re-opening of the performance question issue #141 deferred — it is a reason the *original deferral's own risk estimate* should not be trusted uncritically going forward.
4. **Building Walker first and upgrading later would mean building the single hardest, most error-prone piece of this whole algorithm family twice.** Implementing the apportion mechanism once, deliberately checked against a real, working, MIT-licensed reference implementation (`d3-hierarchy`), is lower total risk than implementing a simpler-but-still-nontrivial version now and re-deriving the harder one later under time pressure from a live defect. This reasoning is unaffected by the qualification in point 2 — the genuine-tree core is the hard part either way, and it's the part verified faithful this round.

### The gen-vs-depth adaptation: what is genuinely already solved, and what critique found is a new, deeper gap

**Part A — already solved, confirmed correct a second time this session, must be preserved as-is.** The current code's own docstring states directly: *"Contour occupancy is tracked per absolute real `gen`, not recursive tree depth… a genuine tree cannot hit this… but this forest can"* — and `leafContour()`/`mergeSubtrees()`/`finalizeNode()` (782–821) confirm this precisely: contour arrays are `length(maxGen+1)`, indexed by `gen+1L` throughout, never by recursion depth. This was S460's own finding. **The redesign must preserve this exact discipline for whatever mechanism Phase 1b settles on** — Walker's own `Level` parameter must map to this project's absolute `gen` (or, more precisely, `dispGenOf`) everywhere a *rendered row* is what matters, never to recursion depth.

**Part B — a new, deeper gap the first draft got wrong, found by this session's own critique, not previously identified anywhere in this investigation's history.** The first draft's proposed fix for cross-branch/gen-jump reconciliation — a "global LEFTNEIGHBOR table, keyed by absolute dispGen… queried as whoever was most recently visited at this exact gen, anywhere in the forest," described as "Walker's own mechanism, kept unchanged by BJL" — is **wrong on both the attribution and the mechanics**, and the underlying problem it was trying to solve is both broader and more structural than the first draft characterized it.

**On attribution** (algorithm-fidelity critique, independently verified against 3 sources this session's critique round did not have to re-derive, since its citations are specific and checkable): Walker's 1989 UNC TR89-034 does use a global, per-level, mutable `LEFTNEIGHBOR`/`GETPREVNODEATLEVEL` table, "not reset between subtrees" — that part of the plan's factual claim about Walker himself is correct. But **BJL's own restructuring replaces this global table with a purely local, structural left-sibling lookup** (`w = v.prevSibling()` / `w = v.left_brother()`, confirmed in two independent real implementations, one built directly from the BJL paper, with the Java source's own comment that "no depth or level calculations" occur anywhere in its core `apportion`/`ancestor`/`moveSubtree`/`executeShifts` logic). BJL does not "keep Walker's mechanism unchanged" — replacing it is a central part of what makes BJL linear-time. The first draft had this exactly backwards.

**On mechanics**, independent of the attribution error: grafting a globally-sourced, non-structural `w` into `apportion`'s downstream `moveSubtree`/`executeShifts` machinery is unsound on its own terms. That machinery distributes a shift via `number(wRight) - number(wLeft)` and `change`/`shift` accumulators keyed to a node's own literal sibling list — ill-defined once `w` is not actually one of the current node's siblings. And a single mutable registry where "whoever visits a gen-slot most recently" becomes the reconciliation reference for everyone else is structurally the same shape as "a one-directional sweep with no fixed-point iteration, first one wins, everyone else collapses" — the root cause the source investigation's own §10.3/§11 name explicitly as Attempt 6/D3‴'s failure mode. The first draft's proposed fix, in other words, risked reintroducing this project's own signature failure pattern **one layer down, inside the "complete" algorithm's own bookkeeping**, while the surrounding rhetoric claimed the opposite.

**Why the underlying problem is broader than either the first draft or the original critique framing suggested — confirmed by direct code reading this session, not asserted:**

1. **Individual→own-anchored-union is a same-gen ("0-delta") tree edge, confirmed by direct code trace.** `positionIndividual(id)`'s own `subIds <- c(unitSub, directSub)` (line 915) mixes `unitSub <- matingUnits$id[matingUnits$anchor %in% id]` (mating units this individual anchors — rendered at `unitGenOf[[unitId]] == genOf[[id]]`, i.e. the *same* gen as the individual, per the exact invariant re-verified above) with `directSub` (D5 direct children, rendered one gen below). A concrete, realistic, already-anticipated-by-the-existing-code adversarial fixture: a founder `P` who anchors mating unit `P×M` (with child `C2`) and separately has a directly-recorded child `C1` with no second parent. `CHILDREN(P) = {P×M-union (gen(P)), C1 (gen(P)+1)}` — literal tree-siblings under one `apportion()` call, at different rendered gens. That this is a *realistic*, not contrived, shape is independently corroborated by the existing code itself: `hasOwnDirectChild()` (line 836–838) already treats "anchors a union AND has a direct child" as a condition worth checking for — it is the exclusion guard on `orderBySex`'s own qualifying rule (line 1062) — meaning the current implementation's authors already knew this combination occurs in real data, just for a different, narrower purpose than the one this gap concerns.
2. **The mating-unit's own phantom-leaf child (this plan's duplicate-participation recommendation) has the identical anomaly, one level down.** `CHILDREN(mating-unit U)` mixes real children at `U.gen + 1` with a non-anchor parent's phantom-leaf representation at `U.gen` itself (issue #143's already-shipped, must-preserve rule: "every non-anchor occurrence renders at its own mating unit's gen"). Both anomalies are the *same* structural shape — a node's own children spanning two rendered gens, not one — not two unrelated problems.
3. **This is not a hypothetical the redesign introduces — the free-pass case already has it today, and the current mechanism's fix for it does not port.** Directly confirmed by re-reading `positionUnit()` (889–904) this session: a free-pass individual folds in via `leafContour(unitGenOf[[unitId]])` (line 895) — **already, today, in shipped code, a 0-delta phantom leaf**, handled correctly only because `leafContour()` returns a **full absolute-gen-length array** (`length(maxGen+1)`, all `Inf`/`-Inf` except at the leaf's own gen slot) that `mergeSubtrees()` folds via elementwise `pmin`/`pmax` at every step of the recursion. This trick is exactly what Walker/BJL's `apportion` avoids by design — comparing via local sibling/thread hops rather than carrying a full per-gen array through the recursion is *why* BJL is O(n) rather than O(n·maxGen). **Porting to BJL's local mechanism therefore loses, rather than merely fails to extend, a trick the current code already relies on for a real, already-shipped case.** This is new evidence, verified directly against the code this session, not present in either the first draft or the three original critiques — it strengthens finding C1-1/C3-2 considerably: the gap is not confined to the *new* duplicate-participation recommendation, it already exists for free-pass nodes in the currently-shipped algorithm, which happens to handle it correctly today only via a mechanism the redesign is specifically replacing.
4. **A further, distinct wrinkle found by tracing this session: forest roots under the synthetic super-root are not guaranteed to sit at a single, uniform gen either.** `gen` is computed once, via `findGeneration()`, on the *pre-trim* pedigree (`R/modPedigree.R:346–348`) — and, more sharply, that computation is itself **conditional**: `if (!"gen" %in% names(ped)) { ped$gen <- findGeneration(...) }`, so if an incoming `ped` object already carries a `gen` column from any earlier processing step, it is silently reused rather than recomputed against the *current* sire/dam graph. Tracing `trimPedigree()`/`getProbandPedigree()`/`modPedigree.R`'s own ancestors-∪-descendants trim (`getProbandPedigree()` only ever subsets rows via `ped[ped$id %in% probands, ]`, and its own upward walk is self-consistent — a kept individual's real parent is always pulled into the ancestor set too) did **not** turn up a confirmed instance of a genuine D4 "founder" (no parent edge at all) carrying nonzero gen via *that specific* trim path alone, since `hasParentEdge` is driven by the *string values* of `sire`/`dam` on a kept row, which trimming never blanks — only the mate's own *row* can go missing (the already-handled "dangling parent" case), not the child's own edge. But the **conditional gen-recomputation** at `modPedigree.R:346` is a directly-verified, more concrete route to the same underlying risk (a stale `gen` column disagreeing with the pedigree structure actually being positioned), and it was not checked against every call site this session (`modGeneticValue.R:296`, `modBreedingGroups.R:261`, `modSummaryStats.R:388` all pair `trimPedigree()`/`findGeneration()` similarly but were not individually traced). **Net effect on this plan: the "nit" is upgraded from speculative to plausible-and-partially-traced, and is folded into Phase 1b's required test matrix below as a synthetic forest whose top-level roots span more than one gen** — rather than resolved outright, since full resolution needs either a dedicated code trace across all four call sites or, more robustly, a defensive check inside `.positionMatingUnitForest()` itself that does not assume root-uniformity regardless of the answer.

**Conclusion for this section:** the redesign's job is not merely "substitute `gen` for `Level` everywhere," as the first draft's now-corrected framing implied — it is to design, from scratch, a reconciliation mechanism for tree edges that do not advance exactly one rendered generation, a case neither Reingold–Tilford, Walker, nor BJL's published no-overlap proofs address at all, because a genuine tree never has this shape. This is now Phase 1b in the Migration Path below, explicitly gating Phase 2, rather than a "solved, preserve don't rediscover" adaptation point as the first draft claimed.

### Uniform tree-accessor: node type is a non-issue, but edge "distance" is not always one gen

Walker/BJL are defined purely in terms of parent/children/sibling accessors — they have no opinion about what a node represents. A single `CHILDREN()` accessor closes the gap between "generic tree algorithm" and "alternating individual/mating-unit forest," **with the explicit caveat, new this round, that not every edge it returns advances exactly one rendered gen** (see previous subsection):

```
CHILDREN(individual I):
    { mating units U where U.anchor == I }, in D4/id order   -- SAME gen as I
  ∪ { D5 direct children of I }   -- childEdges$to where from == I and I is not a union id  -- I.gen + 1

CHILDREN(mating-unit U):
    { real pedigree children of U }   -- childEdges$to where from == U   -- U.gen + 1
  ∪ { U's non-anchor parent's phantom-leaf representation }   -- see "Duplicate nodes" below   -- SAME gen as U
```

`gen(node)` is **known input, never computed** by the algorithm — `ped$gen` for an individual, `max(sire.gen, dam.gen)` for a mating unit (D2/Track 4's existing, unchanged rule — see the cross-reference to the Track 4 invariant in the Algorithm section below) — substituted directly for Walker's `Level` **only where the mechanism actually needs a rendered row, never as a stand-in for recursion depth inside `apportion`'s own stepping**, which is the exact distinction Phase 1b must resolve. Only the `x`-positioning half of Walker/BJL is needed; `y = dispGen * yScale` is looked up, not computed by `secondWalk`.

### Forest handling: synthetic super-root replaces D4's mechanics, not D4's decision

D1 produces a forest (isolated founders are trivial one-node trees; orphan units — both parents dangling, issue #154 — are additional roots), and Walker/BJL are defined for one tree with one apex. The standard fix: attach an invisible synthetic super-root `SR` whose `CHILDREN(SR) = rootIds ++ orphanUnitIds`, in exactly D4's existing order (founders by input row order, then orphan units — `R/makePedigreeDiagramData.R:934–947`, re-confirmed this session) — run the algorithm once, discard `SR`'s own coordinates (never rendered). **New caveat this round:** per the previous subsection's point 4, `SR`'s own children are not guaranteed to sit at a uniform gen (a post-trim founder can plausibly retain a stale nonzero gen) — Phase 1b's synthetic test matrix must include a forest whose top-level roots span more than one gen, so this is exercised deliberately rather than discovered live against the real fixture. This replaces D4's mechanical integration point only — it does not change what D4 decided (row-order founder placement is unchanged; it is now simply "the super-root's children, in that order").

### Duplicate nodes: not addressed by the literature at all — recommendation stands, but its dependency on Phase 1b is now explicit

D1/D3 deliberately exclude duplicate nodes from the recursive merge today (**correction from the first draft, per the migration/TDD critique's minor finding: this is a `.positionMatingUnitForest()` [D3] decision, not `.buildMatingUnitForest()` [D1]** — `.buildMatingUnitForest()` only ever produces the `duplicates` data frame as inert structure, "structure only, no coordinates," per its own docstring; `dupX` is computed entirely inside `.positionMatingUnitForest()`, outside `childEdges`/the recursive merge, as `finalUnitX[unit] + minSep * 0.4`, confirmed at line 1177–1180 this session). This exclusion is genuinely **not addressed by Reingold–Tilford/Walker/BJL at all** — those papers assume every node in the tree participates in width/overlap accounting.

**Recommendation, unchanged from the first draft: make duplicate nodes (and, symmetrically, free-pass folded-in parents) participate as full-width ordinary leaf children of their own mating unit**, not a near-zero-width phantom leaf. Reasoning, unchanged: a duplicate renders at the same radius as a real individual (D6's own integration spec), so giving it an artificially shrunk width in the apportion accounting would mean its true rendered footprint is never actually reserved — reopening, for one node type, exactly the overlap risk this whole redesign exists to close.

**What changes this round: this recommendation's dependency on Phase 1b is now explicit, not implicit.** The critique's own minor finding (C1-5) is correct: full-width duplicate/free-pass participation is exactly the choice that most directly exercises the mixed-gen mechanism gap (a duplicate's phantom leaf is, structurally, the clearest instance of a 0-delta child), so **this decision is not well-defined, and its own PRE-RED gate should not be run, until Phase 1b has a chosen, tested mechanism for 0-delta children in general.** The trade-off argument itself (full-width vs. near-zero-width) is still worth recording now so Phase 1b's own gate is not derived from scratch later — but it is explicitly sequenced *after* 1b in the Migration Path below, not treated as an independent, parallel decision.

### `orderBySex` (issue #145): preserved unchanged, sequencing simplifies — unaffected by this round's findings

Re-confirmed directly this session (`R/makePedigreeDiagramData.R:1054–1078`, `hasOwnDirectChild()` at 836–838): `orderBySex` swaps two co-parents' rendered `x` directly; those two individuals are *not* tree-siblings of each other in general — it is a genuinely cross-cutting, post-hoc cosmetic value-swap, not a sibling-order input, and neither critique round disputed this classification or the reasoning below it.

The reason Track 6 had to move this swap *earlier* in today's pipeline — "a child can itself be a swapped parent in a different, deeper mating unit; computing `finalUnitX` from a pre-swap child position would silently go stale" — is a symptom of Track 6's own separate, *later* re-derivation step existing at all. Under BJL, `secondWalk` computes every node's final `x` exactly once, from `prelim` + accumulated `mod`; nothing downstream ever re-reads a node's finished `x` to compute another node's position. Since `orderBySex` only ever swaps two already-fully-positioned nodes' output `x` (never touching `prelim`/`mod` internals, never moving any child, duplicate, or ancestor), it can simply run **once, after `secondWalk` completes**, exactly as harmlessly as it runs today — but *without* needing to precede anything, because the thing it needed to precede (Track 6's recompute) no longer exists. Same rule, same mechanism, simpler required sequencing.

### Which current patches the new algorithm makes unnecessary by construction — now stated as conditional targets, not guaranteed outcomes

**Correction from the first draft, per the correctness critique's major finding C1-3:** every "Eliminated entirely" claim below describes this redesign's **design intent and expected outcome**, which remains the right target — but elimination of any safety net is **conditional on Phase 1b/Phase 2's own empirical, real-fixture gate passing first** (see Migration Path), not asserted as a settled consequence of switching algorithms. If the real-fixture zero-coincidence property test (Evidence-Based Inventory, and Phase 2's own required gate) finds violations once the mixed-gen mechanism is actually implemented, the corresponding row below does not ship as "eliminated" until the mechanism is fixed — Phase 3's cutover explicitly may not proceed past this gate.

| Current patch | Under the new design | Why | Elimination gated on |
|---|---|---|---|
| `sweepMinSep()` (both applications) | **Target: eliminated entirely** | `apportion`'s own separation parameters *are* the minimum-separation guarantee, applied once, for every node including duplicates (given full-width participation) — **once Phase 1b's mechanism is shown to actually deliver this for every 0-delta/cross-branch case in this forest, not merely for the genuine-tree core** | Phase 2's real-fixture zero-coincidence gate |
| Track 6's `finalUnitX` override | **Eliminated entirely — structurally redundant, not merely simplified away** | `firstWalk`'s own non-leaf case already sets `prelim(v) = midpoint(leftmost, rightmost child)` at every recursion level including mating units, by construction. This part is not gated — it does not depend on the 0-delta mechanism at all, only on the genuine-tree core, which is verified faithful | Phase 1a alone (genuine-tree core) |
| Track 3's parent-span clamp | **Target: eliminated — a deliberate, understood behavior change** | A union's tree-parent (its anchor) and its pedigree co-parent (reached only via the duplicate/free-pass mechanism) are structurally different relationships; clamping a correctly child-centered position back toward an unrelated co-parent's position elsewhere re-introduces the "clamp toward a parent" instinct Track 6 was built to move away from. Some mate-line edges to a distant non-anchor parent will get **visibly longer** — correct, not a defect; Track 1's existing dogleg mechanism already handles this gracefully | Not gated on 1b directly, but Phase 3 must re-confirm no new coincidence appears once the clamp is actually gone on the real fixture |
| `.computeDupNudge()` (Track-3-Engagement-Gated nudge) | **Eliminated entirely** | Exists specifically to correct fallout from Track 3's clamp; with the clamp gone, both the defect it targets and its own gating condition cease to exist | Same as Track 3's clamp, above |
| Final all-node de-collision epsilon pass | **Target: eliminated for every participating node type** | A correct apportion with strictly positive separation parameters guarantees a real minimum gap — **conditional on the same real-fixture gate as `sweepMinSep()`, since this pass today is precisely what catches the residual coincidences a naive port's mixed-gen gap would reintroduce** | Phase 2's real-fixture zero-coincidence gate |
| Final re-applied `sweepMinSep()` | **Eliminated** | Existed only to repair what the epsilon pass eroded; both cease to exist together | Same as the epsilon pass, above |
| **The entire "single-child union coincides with its parent" defect class** (6 failed attempts, S598–609) | **Not "fixed" by a targeted mechanism — dissolved, because its root formula is gone** | The defect was chasing a symptom of Track 6's parent-span clamp forcing a correctly child-centered union back toward a coincidentally nearby parent. Once positioning is genuinely child-centered by construction with no clamp, a single-child union's `x` is *exactly* that child's `x`. **Important honesty point, unchanged from the first draft and still correct: this does NOT mean 100% of the 224/237 currently-measured "near a parent" single-child unions resolve.** 83/224 (37.1%) are "mathematically deterministic from Track 3's clamp" — eliminated by removing the clamp. 87/224 (38.8%) are "naturally close (anchor-chain structure)" — genuine, structurally correct closeness, which a correct algorithm has no reason to artificially separate, and may legitimately remain close post-redesign; 54/224 (24.1%) already separated (all three figures re-verified directly against the source investigation this session). Conflating the first two populations is precisely the mistake several of the six failed attempts made | This class does not depend on 1b's own mixed-gen mechanism — it depends only on the clamp being gone, which is a genuine-tree-core-only change |
| `orderBySex` | **Preserved unchanged** — same qualifying rule, same swap mechanism | Sequencing simplifies; not a position-value patch to begin with | N/A — unaffected by 1b |
| `preferAnchor()` (D2), D4 founder ordering | **Preserved unchanged**, feed the new algorithm as pure sibling/child-order input | Walker/BJL take sibling order as given | N/A — D1/D2/D4 out of scope |

### The algorithm, adapted (procedural detail)

**Per-node fields** (every participating node: individuals, mating units, and — per the recommendation above, pending Phase 1b — duplicate/free-pass phantom leaves):

```
prelim    -- preliminary x, relative to this node's own local sibling group
mod       -- modifier accumulated at this node, propagated down to descendants
shift     -- BJL deferred-shift accumulator (meaningful only among siblings)
change    -- BJL deferred-shift-rate accumulator (meaningful only among siblings)
ancestor  -- contour bookkeeping pointer; defaults to the node itself
number    -- this node's 1-based ordinal among CHILDREN(its own parent)
thread    -- contour-jump pointer, used when one side's contour is shallower than the other's
gen       -- ALREADY KNOWN, never computed here (dispGenOf) -- used ONLY for y-lookup and for
             whatever mechanism Phase 1b designs for 0-delta/cross-branch reconciliation --
             NOT substituted for apportion's own stepping, which remains structural (see below)
```

**Separation constants**, mapped onto this project's existing geometry: `SiblingSeparation = SubtreeSeparation = minSep = 1` (abstract units), matching today's `sweepMinSep()`'s own uniform constant exactly — a deliberate scope-narrowing choice (see "what does NOT change" in Impact Analysis): per-node-type width accounting is a genuine, separate future enhancement, not bundled into this migration.

```
nodeGap(a, b):
    return minSep     -- uniform for now; the extension point for future per-type widths

Helper accessors (BJL-standard; corrected/added this round -- C2-6):
    nextRight(v):  v has children ? rightmost child of v : thread(v)
    nextLeft(v):   v has children ? leftmost child of v  : thread(v)
    commonAncestor(vim, v, defaultAncestor):
        return ancestor(vim).parent == v.parent ? ancestor(vim) : defaultAncestor
    -- Standard BJL definitions, consistent with the algorithm-fidelity critique's own
    -- cited sources, but NOT independently re-verified against a primary or real-implementation
    -- source by this planning session -- Phase 1a's own d3-hierarchy cross-check must confirm
    -- these exactly, not merely assume this pseudocode is right (per C2-6's own concern about
    -- a future session inventing plausible-but-wrong definitions instead of actually checking).

firstWalk(v):
    kids = CHILDREN(v)
    if kids is empty:
        w = left sibling of v (within its own parent's CHILDREN order), if any
        prelim(v) = w == null ? 0 : prelim(w) + nodeGap(w, v)
    else:
        defaultAncestor = kids[1]
        for c in kids (left to right):
            firstWalk(c)
            defaultAncestor = apportion(c, defaultAncestor)
        executeShifts(v)
        midpoint = (prelim(kids[1]) + prelim(kids[last])) / 2
        w = left sibling of v, if any
        if w != null:
            prelim(v) = prelim(w) + nodeGap(w, v)
            mod(v) = prelim(v) - midpoint
        else:
            prelim(v) = midpoint      -- Aesthetic 4, "parent centered over children," by construction

apportion(v, defaultAncestor):
    -- CORRECTED THIS ROUND (C1-2/C3-1): w is v's LOCAL, structural left sibling -- exactly as
    -- real BJL implementations source it (v.prevSibling() / v.left_brother()), NOT a global,
    -- gen-indexed lookup. The first draft's "LEFTNEIGHBOR, Walker's own, kept unchanged by BJL"
    -- was wrong on both halves of that claim (see Decision section above) and is removed.
    -- This local-only form is what Phase 1a implements and verifies against d3-hierarchy --
    -- it handles the GENUINE-TREE core correctly and is what BJL's own O(n) bound is proven for.
    -- It does NOT, by itself, reconcile a 0-delta child against its own tree-sibling, or a
    -- duplicate/free-pass node against an unrelated node elsewhere in the forest that happens to
    -- render at the same gen -- THAT mechanism is Phase 1b's own required deliverable, not
    -- given here, because no verified design for it exists yet (see Decision section and
    -- Migration Path Phase 1b).
    w = left sibling of v (structural, local -- see note above)
    if w == null: return defaultAncestor
    vip = vop = v ; vim = w ; vom = leftmost sibling of v
    (accumulate vim_mod, vip_mod, vom_mod, vop_mod from mod() at each step)
    while nextRight(vim) != null and nextLeft(vip) != null:
        vim = nextRight(vim) ; vip = nextLeft(vip)
        vom = nextLeft(vom)  ; vop = nextRight(vop)
        ancestor(vop) = v
        shiftVal = (prelim(vim)+vim_mod) - (prelim(vip)+vip_mod) + nodeGap(vim, vip)
        if shiftVal > 0:
            moveSubtree(commonAncestor(vim, v, defaultAncestor), v, shiftVal)
        vim_mod += mod(vim) ; vip_mod += mod(vip)
        vom_mod += mod(vom) ; vop_mod += mod(vop)
    if nextRight(vim) != null and nextRight(vop) == null:
        thread(vop) = nextRight(vim) ; mod(vop) += vim_mod - vop_mod
    if nextLeft(vip) != null and nextLeft(vom) == null:
        thread(vom) = nextLeft(vip) ; mod(vom) += vip_mod - vom_mod
        defaultAncestor = v
    return defaultAncestor

moveSubtree(wLeft, wRight, shiftVal):
    n = number(wRight) - number(wLeft)
    change(wRight) -= shiftVal / n ; shift(wRight) += shiftVal
    change(wLeft)  += shiftVal / n
    prelim(wRight) += shiftVal ; mod(wRight) += shiftVal

executeShifts(v):                              -- called once per parent, after all its
    s = c = 0                                   -- children have been apportion()ed
    for child in CHILDREN(v), RIGHT TO LEFT:
        prelim(child) += s ; mod(child) += s
        c += change(child) ; s += shift(child) + c

secondWalk(v, accumMod):
    x(v) = prelim(v) + accumMod
    for c in CHILDREN(v):
        secondWalk(c, accumMod + mod(v))

Top level:
    build synthetic super-root SR, CHILDREN(SR) = rootIds ++ orphanUnitIds (D4 order)
    firstWalk(SR)
    secondWalk(SR, 0)      -- discard SR's own x; every other node's x is final
    apply orderBySex() once, as today's post-hoc 2-node value swap, on the final x values

    ** THIS TOP-LEVEL SEQUENCE, AS WRITTEN, ONLY CORRECTLY RECONCILES A NODE'S CHILDREN WHEN
    EVERY CHILD ADVANCES EXACTLY ONE REN­DERED GEN FROM ITS PARENT -- true for D5 direct
    children and true real mating-unit children, NOT true for an individual's own anchored
    union or a mating unit's own phantom-leaf non-anchor parent. Phase 1b must supply
    (and this document does not yet supply) the mechanism that makes 0-delta children and
    cross-branch/gen-jump conflicts (duplicates, free-pass nodes) actually reconcile
    correctly under this recursion, before this pseudocode can be trusted end-to-end
    against the real forest. **
```

**Honesty note on this pseudocode's own verification status, sharpened this round.** `firstWalk`, the leaf case, and the centering rule are verified directly against Walker's 1989 UNC tech report's own pseudocode (high confidence, independently re-confirmed by this session's own critique round via primary-source page images, not merely re-stated from the first draft). The `moveSubtree`/`executeShifts` mechanism is cross-checked across three independent secondary sources plus two real, from-the-paper implementations (upgraded from "one" in the first draft, per the algorithm-fidelity critique's own additional cross-check) — this part is now **higher** confidence than the first draft claimed, not lower. `apportion`'s comparison-partner sourcing (`w = left sibling of v`) is corrected this round to match real BJL exactly, per the same two implementations. **What remains genuinely unverified, and is now stated as such rather than glossed:** the mechanism for reconciling 0-delta and cross-branch/gen-jump conflicts has **no precedent in BJL's own published algorithm, in either real implementation checked, or in `d3-hierarchy`** (which, like nearly every general-purpose tree-layout library, assumes a genuine tree where level and recursion depth coincide by construction) — this is not a primary-source gap to close by reading harder, it is a genuinely novel extension this project needs that the literature does not supply, and Phase 1b must treat it as original design work with its own adversarial check, not as an implementation detail to fill in mechanically from a source.

---

## Rationale

**Why this approach over alternatives**, and **why this is a difference in kind, not degree, from the six failed attempts — qualified this round to say exactly what is, and is not, yet proven:** every prior attempt computed one node's or one union's position via a single local formula, then left that computation to interact — unreconciled — with every other locally-computed correction elsewhere in the tree. The structural property that fixes this, **for the genuine-tree core, now independently verified**, is that in BJL, reconciliation is not a separate, later cleanup step bolted onto an already-computed value — it is how the value gets computed at all: `firstWalk`'s own recursive definition of `prelim` for any non-leaf node structurally *requires* calling `apportion` against every earlier-positioned sibling as it is encountered, not as an afterthought once something already looks wrong. There is no point in the algorithm's execution, **for a genuine tree**, where a node has a "provisional" position that a later, separate mechanism then "corrects."

**What this round's critique changed about this claim, stated plainly so the document does not overclaim:** this "correct by construction" property is **proven for the genuine-tree core** (every edge advances exactly one gen) and is this redesign's **design goal**, not yet a demonstrated fact, for this project's specific forest shape, which has at least two confirmed structural features (0-delta individual→union edges; 0-delta mating-unit→phantom-leaf edges) that neither Reingold–Tilford's, Walker's, nor BJL's own no-overlap proofs cover. The redesign is still the right direction — it isolates the *entire* remaining risk into one well-scoped, explicitly-gated research question (Phase 1b) instead of leaving it smeared across an ever-growing patch stack — but this document no longer asserts the property holds for the adapted algorithm before that research question is actually answered and tested.

**Trade-offs accepted:**
- More new code than any single prior patch attempt (a genuine algorithm, not a local correction) — deliberately offset by the phased, parallel-implementation migration path below, which keeps every step small, rollback-safe, and independently verifiable rather than one large, high-risk cutover.
- Some mate-line edges will get visibly longer once Track 3's clamp is removed — an accepted, understood, correct consequence, not a hidden regression.
- Duplicate nodes (under the full-width-participation recommendation, once Phase 1b unblocks it) may no longer sit flush against their mating unit — an accepted trade-off in exchange for closing the one gap in the algorithm's own no-overlap guarantee.
- `MEANWIDTH`/per-node-type spacing is deliberately deferred, not solved by this migration.
- **New this round:** the migration now includes a dedicated research phase (1b) whose outcome is not fully predictable in advance — it is possible 1b concludes with a mechanism that is more complex, or has a weaker guarantee, than the genuine-tree core alone. This is an honest cost of fixing the actual gap rather than asserting it away, not a defect in this plan.

**Risks identified, specific to this design, reordered this round to put the critique's own top finding first:**
1. **(Elevated from an implicit assumption to the plan's top named risk, per C1-1/C1-2/C1-3/C3-1/C3-2):** the mixed-gen-sibling/cross-branch reconciliation mechanism has no existing design, no literature precedent, and no verified reference implementation to port. Mitigated by Phase 1b being a required, gated, standalone research phase — with its own explicit deliverable (a short design note with a chosen, justified mechanism) and its own required test matrix — rather than an assumption baked silently into Phase 2's implementation.
2. The `apportion`/`moveSubtree`/`executeShifts` mechanism's genuine-tree-core fidelity is now independently verified against Walker's primary source and two real implementations (upgraded confidence from the first draft) — residual risk is now concentrated in Phase 1a's own from-scratch R port introducing a transcription bug, not in the algorithm's own correctness; mitigated by the mandatory d3-hierarchy cross-check and Walker's own worked-example golden test.
3. The duplicate-participation decision is explicitly sequenced after, and dependent on, risk 1's resolution (see Decision section) — no longer an independent risk with its own PRE-RED gate run in isolation.
4. My own reasoning that `orderBySex`'s sequencing simplifies under the new design is analysis, not yet execution — mitigated by requiring `test_positionMatingUnitForest.R`'s existing `orderBySex` fixtures to be re-run against the new engine in Phase 2/3, not merely reasoned about on paper.
5. Larger code volume, now larger still with Phase 1b added, raises the temptation to bundle phases or rush verification — exactly the failure mode `SESSION_RUNNER.md`'s "1 and done" and Vertical Slice Session gates exist to prevent. The phasing below is deliberately conservative for this reason, more so than the first draft.
6. **Meta-risk, stated honestly and reconfirmed this round:** this document has now been through two rounds of scrutiny (the original 3-lens critique, and this session's own verification-against-code pass) and still cannot claim to have solved risk 1 — only to have named it correctly and given it a proper place to be solved. A third round of critique, run against Phase 1b's own eventual design note, is not optional; this document's own history (six implementation attempts, one planning draft) is itself the argument for why.

---

## Alternatives Considered

*(Unchanged from the first draft — the migration/TDD critique independently re-verified several of this table's own citations and found no fault with its reasoning; the correctness and algorithm-fidelity critiques did not challenge this section either.)*

| Alternative | Pros | Cons | Why Rejected |
|---|---|---|---|
| Continue patching the current stack (a 7th local correction) | Smallest incremental diff; matches the instinct to "just fix the one bug" | Six independent attempts (S598–601, S609×2) have **all** failed adversarial critique, each for a *new* way two locally-computed corrections collide — the failure mode is structural, not a matter of finding the right patch | Rejected by explicit owner directive (S609 §11); the *pattern* itself, not any one patch's specific bug, is the demonstrated problem |
| Revert to kinship2-style parent-centering (the *original* D3 step 4 formula, before Track 6) | Matches a well-known, community-standard visual convention; less code than a full rewrite | Reopens Track 6's own already-measured, **larger** defect: a polygamous anchor's cross-union centroid substituted as union position produced sibship-bar drift up to 10,687 scaled units (100/251 real-fixture child edges >200 units off), vs. child-centering's 9/251 (max 4,121). kinship2 itself is GPL, and its own source contains an uncapped factorial founder-order search plus a heuristic its own vignette admits "works 9 times out of 10" | Rejected — known-worse on the metric that matters, and the GPL wall means it cannot be adopted wholesale even where it might look better |
| Adopt an off-the-shelf R tree-layout package (`igraph::layout_as_tree()`, `data.tree`, `ggraph`) | Battle-tested; less hand-implementation risk | `igraph` is `GPL (>= 2)`; `data.tree` is GPL; `ggraph` is MIT but hard-`Imports` `igraph` transitively | Rejected on license grounds alone, independent of technical merit |
| Full generic Sugiyama layered-graph pass (barycenter/median crossing-reduction; `igraph::layout_with_sugiyama()`) | Handles arbitrary DAGs; well-studied heuristic family | Already spiked **three times** independently (S588–590) — all three closed **NOT FEASIBLE**, regressing the real 375-fixture on offset metric, max offset, layout width, *and* crossings simultaneously. Also solves a strictly harder problem than the one actually remaining: after D1's transformation the structure is an exact tree/forest, where crossing-minimization is trivially exact, not NP-hard | Rejected — already closed by three independent prior spikes; this redesign completes the *existing* rigid-subtree contour-merge model's missing apportioning step, it does not revisit whether the model should be rigid-subtree at all |
| Plain Walker's algorithm (1990), without BJL's O(n) fix | Simpler apportion mechanism on paper | Same correctness/completeness properties as BJL, but without BJL's provable O(n) bound for the genuine-tree core; this project's own duplicate/free-pass mechanism plausibly makes irregular shapes *more* likely here, undercutting issue #141's "very unlikely to hit pathological shape" reasoning. Also means building the hardest-to-verify piece of this algorithm family twice if a future session needs to upgrade anyway | Viable as a fallback, but BJL is preferred: identical outer shape either way, same correctness risk profile for the genuine-tree core (now independently verified), strictly better asymptotic guarantee there for bounded extra cost |

---

## Evidence-Based Inventory

*(Grep/`gh`/direct-read evidence gathered across the original planning session and this critique-response session; every claim below has now been directly re-confirmed against the current repository state at least once, several twice, with new items marked accordingly.)*

### Call-site graph (grep-confirmed, single call site each)

```
R/makePedigreeDiagramData.R:1322   forest <- .buildMatingUnitForest(ped)
R/makePedigreeDiagramData.R:1323   pos <- .positionMatingUnitForest(ped, forest, orderBySex = orderBySex)
R/makePedigreeDiagramData.R:1163   nudge <- .computeDupNudge(...)          # inside .positionMatingUnitForest itself
R/makePedigreeDiagramData.R:1629   waypoints <- .addRectilinearWaypoints(nodes, edges, forest, pos)
R/makePedigreeDiagramData.R:1636   resolved <- .resolveEdgeNodeCollisions(waypoints$nodes, waypoints$edges)
```

All five live inside or are called from `makePedigreeMatingLayout()` (1307–1652, the sole `@export`ed consumer). Grep for `matingUnits`/`duplicates$`/`childEdges` outside this file: **zero hits.** `R/modPedigree.R` touches only reserved-id-prefix strings (`__union_`/`__dup_`) for click-selection, never `x`/`gen` values — confirmed independently by two separate reads, which additionally confirmed **no golden-image test exists for the Diagram tab**.

### Downstream consumers and their exact assumptions (Track 1 / Track 2)

- **`.addRectilinearWaypoints()`** (1716–1967): D1 sibship-bar row (`barY = childY - (childY - parentY) * 0.4`, constant at `:1759`) assumes every node's `y` is an exact integer multiple of `yScale` "by construction, not heuristic." D2 mate-line dogleg (1795–1864) looks up each side's own `gen` defensively and inserts a projection node when it differs from the unit's own gen — this is the mechanism that already, today, handles a parent positioned at a different gen or a very different `x` than its mating unit; it requires no change for Track 3's removal to render correctly.
- **`.resolveEdgeNodeCollisions()`** (2042–2306): never moves an existing node (only adds `__jog_*` waypoints); same-row detection (`.detectStraight()`) uses **exact** floating equality on `y`, so any redesign must keep exactly-equal `y` for nodes nominally on the same generation row — automatically satisfied since this redesign does not touch how `y` is derived from `gen`.
- **Net implication:** both tracks are compatible with any replacement that (a) still emits one `x` and one `gen`-derived, integer-multiple `y` per node id, (b) leaves `sibshipBarFraction`'s intermediate row uniquely non-coincident, (c) keeps exact same-generation `y` equality. This redesign satisfies all three by construction (`y` computation is untouched entirely) — **unaffected by this round's findings**, since Phase 1b concerns `x` reconciliation only.

### New evidence, gathered this session in direct response to the critique (not present in the first draft)

| # | Finding | How verified | Implication |
|---|---|---|---|
| E1 | The free-pass 0-delta phantom leaf is **already live in shipped code today**, not merely a hypothetical the redesign's duplicate-participation recommendation introduces | Direct read, `R/makePedigreeDiagramData.R:889–904` (`positionUnit()`): `fpHere <- freePassOfUnit[[unitId]]`, positioned via `leafContour(unitGenOf[[unitId]])` — a full absolute-gen-length array, all `Inf`/`-Inf` except at the unit's own gen slot | Strengthens C1-1/C3-2 considerably: today's correct handling of this case depends on a full-array trick BJL's local mechanism specifically avoids carrying, so porting to BJL loses a working mechanism for an already-real case, not merely fails to anticipate a new one |
| E2 | `hasOwnDirectChild()` (line 836–838) is already used elsewhere in the same file (the `orderBySex` qualifying-exclusion at line 1062) to guard against exactly the "anchors a union AND has a direct child" shape C1-1's adversarial fixture describes | Direct read, cross-referenced | Corroborates that this shape is realistic in real pedigree data, from the existing code's own design, independent of the critique's own reasoning |
| E3 | `gen` recomputation in the Diagram tab's own pipeline is conditional: `if (!"gen" %in% names(ped)) { ped$gen <- findGeneration(...) }` (`R/modPedigree.R:346–348`) — a `ped` object already carrying a `gen` column is never re-derived against its current sire/dam graph | Direct read of `R/modPedigree.R:335–382`, `R/getProbandPedigree.R:24–40`, `R/trimPedigree.R:51–63`, `R/findGeneration.R:40–58` | Upgrades C1-6 from speculative to a directly-traced, plausible mechanism; the specific ancestors-∪-descendants trim path itself was checked and did not independently reproduce it (row-subsetting never blanks a kept row's own `sire`/`dam` fields), but the conditional-recompute route was not ruled out and was not checked against `modGeneticValue.R:296`, `modBreedingGroups.R:261`, or `modSummaryStats.R:388` |
| E4 | `findGeneration()`'s own algorithm (`R/findGeneration.R:40–58`) guarantees `gen(child) == max(gen(sire), gen(dam)) + 1` exactly whenever both parents are known, and `gen == 0` exactly and only for both-parents-NA rows, **on the pedigree it is run against** | Direct read | No single-edge, >1-gen skip is introduced by `findGeneration()` itself; any multi-gen anomaly this project could hit is a same-gen (0-delta) edge, not a skip-a-generation edge — relevant to Phase 1b's own choice of mechanism (dummy-node layer padding, the standard fix for edges spanning ≥2 layers, is very likely the WRONG tool here; a same-rank/flat-edge treatment, a different and less standard technique, is the more plausible direction — Phase 1b must verify this rather than assume either) |

### Full pinned-value/test inventory (file:line, what's pinned)

*(Unchanged from the first draft — re-confirmed this session: `wc -l` on `test_positionMatingUnitForest.R` (1583), `test_buildMatingUnitForest.R` (444), `test_makePedigreeMatingLayout.R` (1363) match within 1 line of the first draft's own citations.)*

| File | What's pinned | Expected fate under the redesign |
|---|---|---|
| `test_buildMatingUnitForest.R` (444 lines, 19 blocks) | Structural counts only: `237L` mating units, `102L` duplicates, `22`-member multi-anchor id set, per-id anchor counts (`WCPXHD`→5, `HV7LZ3`/`KUENM8`/`LVK7AI`→3, `IM1B5T`→2), D2 tie-break behavior, issue #154 dangling-parent handling | **Unchanged** — D1/D2 is not in this redesign's scope |
| `test_positionMatingUnitForest.R` (1583 lines, 37 blocks) | Specific `x`/`gen` literals throughout, including the "highest-risk" 4-unit single-child fixture, the S583 headline clamp case, `.computeDupNudge()`'s own unit tests, the "3-way OR" invariant, and **all three `makePedigreeMatingLayout()`-level gate-behavior pins — `90` (`:1491`), `129.06` (`:1524`), and the F1 strict-regression `-6.0` (`:1582`)**, which live in *this* file, not in `test_makePedigreeMatingLayout.R` (correction, see the verification note below this table) | **Positional literals expected to change — consciously re-pin, don't silently patch.** `.computeDupNudge()`'s own tests are **deleted**. The "3-way OR" invariant is **replaced** by a single exact-equality assertion. The S583 clamp case's pinned values are **expected to change**, with the reasoning recorded in the test's own comment |
| `test_positionMatingUnitForest.R:358–390` | `all(minGaps >= 1L - 1e-6)` general property, real fixture | **Preserved as a stronger, structural guarantee — conditional on Phase 1b's own gate passing** (see Decision, "which patches become unnecessary," now explicitly conditional) |
| `test_positionMatingUnitForest.R:1185–1205` | Zero exact `x`/`gen` coincidence among real+duplicate+union nodes together — **the direct regression gate D3‴ broke (0→3 violations, S609)** | **Preserved, and this remains the single most important test to keep green at every phase boundary — now explicitly the load-bearing gate for whether Phase 1b's mechanism is actually sufficient, not merely a nice-to-have** |
| `test_positionMatingUnitForest.R:610–631` | `nrow(pos) == 714L` (`375 + 102 + 237`), no `NA` `x`/`gen` | **Unchanged** |
| `test_positionMatingUnitForest.R:1000–1017` | Track 4 invariant: `matingUnits$gen == genOf[anchor]`, 0 exceptions | **Unchanged** — this is the exact invariant this document's Algorithm section cross-references for why `gen(union) == gen(anchor)` (see below) |
| `test_positionMatingUnitForest.R:1021–1051` | Issue #162 locale-independence (radix, not `Scollate()`) | **Unchanged** |
| `test_makePedigreeDiagramData.R` (487 lines) | Tests a **separate, independent** code path, zero references to `.buildMatingUnitForest`/`.positionMatingUnitForest` | **Out of this redesign's blast radius entirely** |
| `test_makePedigreeMatingLayout.R` (1363 lines, 46 blocks) | `nrow(result$nodes) == 714L` (`:500`, direct style); `1412L` rectilinear (`:615`); `sum(grepl("^__jog_", ...)) == 210L` (`:618`). **Does NOT pin `-6.0`/`90`/`129.06`** — those are in `test_positionMatingUnitForest.R` (see the row above and the verification note below) | Structural node counts (`714`) **unchanged**; jog-node count (`210`) **expected to change** — must be re-measured |
| `test_addRectilinearWaypoints.R` | `714L` input, `1202L` rectilinear pre-jog; `gap1Collisions == 0L`, `totalResidual == 2L` (out of scope); bar-vs-bar hits `348L`/`116L` (post-Track-3 baseline; pre-Track-3 was `42`/`9`) | Input count unchanged. Bar-vs-bar hit counts **expected to change**, plausibly toward the pre-Track-3 figures or better — must be re-measured, not assumed |
| `test_resolveEdgeNodeCollisions.R` | `105L` colliding edges / `1431L` obstacle-pairs (post-Track-3 baseline) | **Expected to change** — re-measure, re-pin with rationale |

**Independent verification pass on this table (S610 session author, after the repair round, before publication).** Every row above was re-checked directly against the repository rather than accepted from the workflow's own agents — per `SESSION_RUNNER.md` §Vertical Slice Sessions' standing warning that "sub-agents emit confident-but-wrong claims. Apply adversarial refutation to your own agents' output, not only to the primary work." Confirmed exactly as stated: all five call sites (`:1322`/`:1323`/`:1163`/`:1629`/`:1636`); `.addRectilinearWaypoints()` at `:1716` and `.resolveEdgeNodeCollisions()` at `:2042`; `sibshipBarFraction <- 0.4` at `:1759`; `preferAnchor()`'s `if (ga != gb) return(ga > gb)` at `:403–414`; `unitGen <- pmax(...)` at `:456–458`; the conditional `gen` recompute at `R/modPedigree.R:346–348`; the zero-coincidence gate at `test_positionMatingUnitForest.R:1185–1205`; `test_addRectilinearWaypoints.R`'s `714L`/`1202L`/`0L`/`2L`/`348L`/`116L` (`:534`/`:538`/`:605`/`:606`/`:718`/`:719`); and `test_resolveEdgeNodeCollisions.R`'s `105L`/`1431L` (`:390`/`:391`).

**Two corrections were required and are applied above.** (1) **A real file misattribution:** the pre-correction table (and Phase 3's Commit 3-1 file list, also corrected below) placed the `-6.0`/`90`/`129.06` gate-behavior pins in `test_makePedigreeMatingLayout.R`. They are in `test_positionMatingUnitForest.R` (`:1582`/`:1491`/`:1524`); `test_makePedigreeMatingLayout.R` is only 1,363 lines and contains none of them. This traces to one of this session's own critique agents reporting it had "independently re-verified... the F1 `-6.0` regression pin at line 1583" of `test_makePedigreeMatingLayout.R` — conflating that file's name with the *other* file's line count (`test_positionMatingUnitForest.R` is exactly 1,583 lines). An executor trusting the uncorrected text would have searched the wrong file. (2) **Two `test_that()` block counts were off** (18→19, 44→46). Both corrections are recorded rather than silently applied, since this document's own credibility rests on its inventory being checkable — and since the error's origin (a *verification* agent's confidently-stated false claim, inside a critique whose other checks were all accurate) is itself the most transferable lesson this session produced.

**Cross-reference added this round (fixes C3-3):** the Algorithm section states `gen(mating-unit U) = max(sire.gen, dam.gen)`; this table's own Track 4 row states the equivalent invariant as `matingUnits$gen == genOf[anchor]`. These are the same value by construction: D2's `preferAnchor()` (`R/makePedigreeDiagramData.R:403–414`) always prefers the parent with the **deeper** gen as anchor (`if (ga != gb) return(ga > gb)`), so `genOf[[anchor]] == max(genOf[[sire]], genOf[[dam]]) == unitGen`, exactly, with no exceptions — re-verified directly this session, not merely re-stated. A future change to D2's own tie-break order would need to re-establish this equivalence; it is out of scope for this redesign to touch, but worth flagging for whoever next touches D2.

### Track 1–6 registry (from `BACKLOG.md` + `docs/planning/*.md`)

| Track | Shipped | Fate under this redesign |
|---|---|---|
| Track 1 | D1 sibship-bar row offset, `.addRectilinearWaypoints()` | **Untouched** |
| Track 2 | Same-row detect-and-jog framework, `.resolveEdgeNodeCollisions()` | **Untouched**; its own pinned defect-counts will shift |
| Track 3 | Parent-span clamp on `finalUnitX` | **Removed** — see Decision above |
| Track 4 | `preferAnchor()` gen→mateCount→id tie-break | **Untouched** |
| Track 5 | Broadened rectilinear routing coverage | **Untouched**, already closed |
| Track 6 | Child-centered mating-unit position formula | **The target quantity is preserved exactly** — only *how* it's reliably achieved changes |

`GitHub issue #141` (state `open`, labels `enhancement` + `premature optimization`): scope, comment, and non-authority-to-relabel-unilaterally are all unchanged from the first draft — flagged again in Open Questions below.

### Cumulative failure tally

Six independent design attempts (S598–601, S608, S609) have each failed adversarial critique, every one tracing to the same root cause: a one-directional sweep/merge with no reconciliation between two or more locally-computed corrections that turn out to overlap. **This session adds a seventh data point, of a different kind: this planning document's own first draft, on its own first attempt at a replacement mechanism, reproduced a related failure shape one level up the stack (a global, unreconciled lookup table proposed as the fix for a reconciliation problem) — caught by critique before any code was written, which is the entire point of running this critique at the planning stage rather than after Phase 1b ships.**

---

## Migration Path

Each phase below follows this project's own established precedent and this plan's own safety principle: **the old function stays completely intact and callable until one single, late, well-tested cutover phase.** Every phase before cutover is purely additive — rollback at any point before Phase 3 is "delete the new files," full stop, zero production impact.

Every implementation phase runs its own `PRE-RED → RED → GREEN → REFACTOR` cycle with `AskUserQuestion` gates at each transition, per `CLAUDE.md`'s Development Process Contract override — this planning document does not and cannot satisfy those gates; it only identifies where they fall.

**Structural change from the first draft (fixes C1-1/C1-2/C1-3/C3-1/C3-2 together):** Phase 1 is now explicitly split into **1a** (genuine-tree core — the part independently verified faithful this round) and a new, required **1b** (forest/mixed-gen reconciliation — the part this round's critique found undesigned). Phase 2 cannot begin until 1b has a chosen, tested mechanism.

### Phase 1a — Standalone BJL apportioning engine, genuine trees only

**What DONE looks like:** a new, self-contained, pedigree-agnostic module (proposed: `R/positionTreeApportion.R`) implementing `firstWalk`/`apportion`/`moveSubtree`/`executeShifts`/`secondWalk` exactly per the corrected pseudocode above (local-sibling `apportion`, explicit `nextLeft`/`nextRight`/`commonAncestor`), operating on a **generic** tree interface (a `CHILDREN()`-style accessor and a node-width function passed in), plus a synthetic-super-root helper for forests — **scoped deliberately to genuine trees only: every edge in every test fixture this phase writes advances exactly one level, matching what the algorithm's own published no-overlap proof actually covers.** This scoping is not a limitation to apologize for; it is what makes Phase 1a's own correctness independently checkable against real, published sources, cleanly separated from Phase 1b's genuinely novel work.

A new test file (proposed: `tests/testthat/test_positionTreeApportion.R`) covering:
- A single node; a simple balanced n-ary tree.
- An asymmetric tree (one deep-narrow branch, one wide-shallow branch — the shape both Walker's own paper and issue #141 name as the interesting case).
- A forest of several disconnected small trees via the super-root, specifically exercising cross-branch conflict at the same level.
- **Required, not optional:** a golden-value test reproducing Walker's own worked 15-node example from the primary UNC tech-report source (re-extract the example and its expected output directly from the primary source, not a secondary summary).
- **New this round, fixing C2-3:** every one of the fixtures above — not only the Walker worked example — must carry a **strong, exact-value oracle**, independently derived (by actually running a reference implementation such as `d3-hierarchy` on the same input and recording its output, or by hand-computing and cross-checking against it), not a weak structural assertion ("no `NA`", "all distinct"). The asymmetric-tree and multi-tree-forest cases are named explicitly here because the plan's own rationale (and issue #141, and Walker's paper) identifies them as the shapes most likely to expose a broken apportion mechanism — a future session satisfying this test list with weak assertions would defeat the entire purpose of this phase.

**Before writing GREEN code, cross-check `apportion`/`moveSubtree`/`executeShifts`/`nextLeft`/`nextRight`/`commonAncestor` directly against `d3-hierarchy`'s real, working, MIT-licensed tree-layout source.** This is not optional polish — it is how this phase closes the primary-source gap disclosed in the Algorithm section's own honesty note, and it is now explicitly required to confirm the three helper accessors this round added definitions for (C2-6), not merely the functions the first draft already had.

**Scope boundary, stated explicitly this round:** this cross-check validates the genuine-tree core only. It cannot and does not validate Phase 1b's own mechanism, because `d3-hierarchy` (like nearly every general-purpose tree-layout library) assumes a genuine tree where level and depth coincide — it has no 0-delta or cross-branch case to check against at all.

Zero changes to `R/makePedigreeDiagramData.R` or any existing test file.

**Verification commands:**
```
Rscript -e 'Sys.setenv(NOT_CRAN = "true"); pkgload::load_all(".", quiet=TRUE); testthat::test_file("tests/testthat/test_positionTreeApportion.R", reporter="summary")'
Sys.setenv(NOT_CRAN = "true"); pkgload::load_all(".", quiet=TRUE); as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE))   # confirm sum(failed)==0, sum(error)==0
lintr::lint_package()   # on the new file, package loaded first (Learning 224 methodology)
```

**Rollback:** delete the new file(s). Nothing else was touched.

**Session boundary: this phase is one session.**

### Phase 1b — Forest/mixed-gen/cross-branch reconciliation: research and design spike (NEW — required, gates Phase 2)

**Why this phase exists, stated plainly:** this session's own 3-lens critique found the first draft's proposed mechanism for this exact problem factually wrong (misattributed to Walker/BJL) and mechanically broken (incompatible with `moveSubtree`/`executeShifts`'s own sibling-indexed bookkeeping). No verified mechanism exists anywhere in this investigation's history, the published literature, or any implementation checked so far. Proceeding to Phase 2 without resolving this would mean implementing `CHILDREN(individual)`/`CHILDREN(mating-unit)` — which concretely produce the 0-delta edges this gap concerns — against an unverified foundation, exactly the pattern that sank six prior implementation attempts one level down the stack.

**What DONE looks like:** a short, dedicated design note (markdown, not full production code — a minimal prototype in the Phase 1a engine's own test harness is acceptable if it clarifies the mechanism, but is not the deliverable) that:

1. **Enumerates every confirmed instance of this project's forest violating the "every child is exactly one level deeper" assumption**, using the concrete evidence already gathered this session as a starting inventory, not a blank slate: (a) an individual's own anchored mating union (0-delta); (b) a mating unit's own non-anchor-parent phantom leaf (0-delta, symmetric to (a)); (c) a duplicate node's true position elsewhere in the forest, reached only through its anchor occurrence (a "same real entity at multiple tree positions" problem, distinct in kind from (a)/(b), not merely a variant of them); (d) the possibility of multiple top-level roots (forest children of the synthetic super-root) sitting at different, nonzero gens after certain pedigree trims (Evidence-Based Inventory E3) — this must be added as an explicit synthetic test fixture (a forest whose roots span 2+ gens under `SR`), not left as a theoretical possibility untested.
2. **Evaluates candidate mechanisms**, each checked against the specific mechanical objection this round's critique raised (that grafting a non-structural comparison partner into `moveSubtree`/`executeShifts` breaks their sibling-indexed math) rather than assumed to sidestep it:
   - A deliberately-scoped, justified revival of something like Walker's own global per-level table — but *only* as an independent, post-`apportion` verification/separation step for non-sibling same-gen nodes, structurally distinct from feeding it directly into `moveSubtree`'s shift bookkeeping the way the first draft's proposal did. Must be explicitly checked against whether this reintroduces an unreconciled-sweep shape (this round's own finding about the first draft) or genuinely differs from one.
   - Restructuring `CHILDREN()` so that 0-delta edges are **not** modeled as tree-recursion children at all — closer to how `dupX` already works *today*, entirely outside the recursive merge, as a fixed deterministic offset computed once `secondWalk` has finished for the node it's attached to. This trades away duplicates/free-pass participating in width apportioning (reopening a version of the current "duplicates contribute no width" trade-off this redesign otherwise wants to close) in exchange for a structurally clean recursion — a real trade-off to weigh explicitly, not a free win.
   - A same-rank/"flat edge" treatment adapted from general layered-graph-drawing literature. **Note, corrected this round from the original critique's own more tentative "dummy-node padding" suggestion:** direct tracing of `findGeneration()` this session (Evidence-Based Inventory E4) found every confirmed anomaly in this forest is a **same-gen (0-delta)** edge, never a multi-gen-skip edge — so classic Sugiyama dummy-node layer padding, which targets edges spanning ≥2 layers, is very likely the *wrong* tool here regardless of its prominence in the general literature; same-rank/flat-edge handling is a different, less standard technique that Phase 1b must actually identify and verify, not assume by analogy.
3. **Concludes with a recommended mechanism**, demonstrated (not merely asserted) to correctly handle the full enumerated case list from step 1, including the "multiple gen-spanning roots" fixture — **or an honest conclusion that no clean mechanism was found**, in which case Phase 1b's own output is a clearly-scoped harder problem statement for a dedicated follow-up session, not a forced, under-verified answer produced to keep the Migration Path moving.
4. **Gets its own fresh, skeptical read before Phase 2 proceeds** — not necessarily a full repeat of this session's 3-lens critique process, but at minimum a review this project's own established discipline would recognize as adversarial, not confirmatory, given this exact planning document's own history of a first attempt not surviving scrutiny.

**Verification commands:** none in the traditional sense — this phase's deliverable is a design document plus, optionally, a minimal prototype exercised against Phase 1a's own test harness (`test_positionTreeApportion.R`, extended with the new mixed-gen fixtures from step 1 above) using the same commands as Phase 1a.

**Rollback:** delete the design note and any prototype code; Phase 1a is entirely unaffected.

**Session boundary: this phase is one session, and may reasonably conclude "more research needed" rather than a finished mechanism — that is an acceptable, honest outcome, not a failure of the phase.**

### Phase 2 — Pedigree adapter, parallel to production, A/B verified

**Blocked on Phase 1b.** This phase implements `CHILDREN(individual)`/`CHILDREN(mating-unit)` using whichever mechanism Phase 1b's design note settles on — it cannot meaningfully begin before that exists, since the accessor definitions themselves are what Phase 1b's own research question is about.

**What DONE looks like:** a new adapter (living in `R/makePedigreeDiagramData.R` alongside `.buildMatingUnitForest`/`.positionMatingUnitForest`, proposed temporary name `.positionMatingUnitForestBJL()`) implementing the `CHILDREN()` accessor (per Phase 1b's chosen mechanism), the `gen`-as-row-lookup substitution, the synthetic-super-root replacing D4's mechanics, and the duplicate-participation mechanism (its own PRE-RED gate, informed by but not run before Phase 1b — see Decision section) — callable **side by side** with the existing, completely untouched `.positionMatingUnitForest()`.

A new test file (proposed `tests/testthat/test_positionMatingUnitForestBJL.R`) runs the new adapter against every fixture `test_positionMatingUnitForest.R` already uses and asserts **property-level invariants**, not byte-for-byte parity with the old (defect-laden) function's pinned literals:
- Provable minimum separation for every node pair at the same gen.
- **Zero exact `x`/`gen` coincidence among real+duplicate+union nodes together, on every fixture including the real 375-individual one — this is the single most important test in the whole migration, and it is now explicitly the gate that determines whether Phase 1b's mechanism is actually sufficient, not a formality run after the fact.** If this fails on the real fixture, Phase 2 does not close out GREEN — it returns to Phase 1b with the specific counter-example in hand.
- Every mating unit's `x` equals the exact midpoint of its own children's `x` — one formula, no OR-branches, no clamp exceptions, including every single-child union.
- `orderBySex`-qualifying fixtures produce the same qualifying-pair swap behavior as today.
- Re-measure single-child-union "near a parent" prevalence on the real fixture — confirm the ~83/224 clamp-caused cases resolve, and explicitly characterize (not silently absorb) whatever the ~87/224 "naturally close" population measures as post-redesign.
- **New, required by Phase 1b's step 1 enumeration:** a synthetic forest whose top-level roots span 2+ gens under the super-root (Evidence-Based Inventory E3), specifically exercising whatever Phase 1b's mechanism does for this case.

**New deliverable this round, fixing C2-4:** a reusable, checked-in helper (proposed: `tests/testthat/helper-live-render-positions.R`, using testthat's own `helper-*.R` auto-source convention) that renders a given `nodes`/`edges` pair via the same `visNetwork` call the app makes, drives a headless `chromote` session against it, and calls the widget's own live `getPositions()` method — returning a plain data frame of `id`/`x`/`y` actual rendered positions. This captures, as a first-class, reusable deliverable, the exact methodology this project has used bespoke and uncommitted at least twice before (`test_makePedigreeMatingLayout.R:124`'s own comment; the duplicate-occurrence investigation's own narrated before/after `getPositions()` comparison across git worktrees) — built here, in Phase 2, where it is first needed (to verify the BJL adapter's real-fixture behavior against ground truth, not just internal `x`/`gen` values), and reused without modification by Phase 3's own live-render check below.

**This phase carries its own dedicated PRE-RED `AskUserQuestion` gate** ratifying full-width vs. near-zero-width duplicate participation (§"Decision" above) before RED tests are written — this is the one open design choice this planning document could not close unilaterally, and it is now explicitly informed by whatever Phase 1b concluded, not decided independently of it.

**Note, fixing C2-7:** Phase 1a's generic engine file (`R/positionTreeApportion.R`) is not necessarily frozen once this phase begins — pedigree-forest integration commonly surfaces bugs or missing generality in an engine tested only against synthetic trees. Revisiting it here is expected, not an out-of-plan surprise, and stays within this phase's own file-count bounds (it is still only 1 additional file touched, not a new one).

Zero changes to the existing `.positionMatingUnitForest()`, `.computeDupNudge()`, or any existing test file — production still calls the old path exclusively.

**Verification commands:**
```
Rscript -e 'Sys.setenv(NOT_CRAN = "true"); pkgload::load_all(".", quiet=TRUE); testthat::test_file("tests/testthat/test_positionMatingUnitForestBJL.R", reporter="summary")'
Sys.setenv(NOT_CRAN = "true"); pkgload::load_all(".", quiet=TRUE); as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE))   # confirm the OLD path's own tests are bit-for-bit unaffected
lintr::lint_package()
# live-render ground-truth check, using the new helper above, on at least the F1 and real-375 fixtures
```

**Rollback:** delete the new adapter code, its test file, and the helper file. Production behavior is provably unaffected since the call site hasn't moved yet.

**Session boundary: this phase is one session.** Splittable (adapter mechanics vs. the duplicate-participation PRE-RED deliberation + its own implementation) if it proves too large.

### Phase 3 — Cutover

**Restructured this round, fixing C2-1/C2-2:** instead of one undifferentiated "what DONE looks like" implying an unbounded file count, this phase is now two explicit, individually-scoped commits, each of which must independently leave a clean regression read before the next begins.

**Commit 3-1 (4 files — the mechanically-coupled core):**
1. `R/makePedigreeDiagramData.R` — the single production call site switched to the new engine; the old `.positionMatingUnitForest()`, `.computeDupNudge()`, and the entire patch-stack code block deleted; `.positionMatingUnitForestBJL()` renamed to replace `.positionMatingUnitForest()` outright (clean — no permanent parallel-naming debt, matching the confirmed single-call-site finding).
2. `tests/testthat/test_positionMatingUnitForest.R` — becomes the merged, final test file: old defect-laden positional literals removed, `.computeDupNudge()`'s own now-dead unit tests removed, Phase 2's property-based tests merged in, positional literals that changed as a **direct, mechanical** consequence of the engine swap re-measured (by actually running the new engine, never hand-derived) and re-pinned with a one-line rationale in the test's own comment. **Note (corrected, see the Inventory's verification note): this file is also where the `90` (`:1491`), `129.06` (`:1524`), and F1 `-6.0` (`:1582`) gate-behavior pins live** — so they are re-pinned here, in this same file, not in file #4 below.
3. `tests/testthat/test_positionMatingUnitForestBJL.R` — **deleted, its content fully merged into #2 above.** This resolves the first draft's own unaddressed gap (C2-1): the file's fate is no longer left to discovery mid-session.
4. `tests/testthat/test_makePedigreeMatingLayout.R` — re-pin the jog-node count (`210L`, `:618`) and the rectilinear node count (`1412L`, `:615`) if the engine swap moves them; the direct-style `714L` (`:500`) is a structural count and should **not** move. **Corrected from the pre-verification draft, which also listed `-6.0` here** — that pin is in file #2, not this one.

**Commit 3-1 must leave `sum(failed)==0 && sum(error)==0` (clean regression read) before Commit 3-2 begins.** This is not optional sequencing color — it is the direct fix for C2-2: the first draft's 3a/3b split was asserted, not demonstrated, to avoid a RED checkpoint from stale literals; requiring Commit 3-1 itself to absorb every re-pin that its own engine swap mechanically forces removes the gap.

**Commit 3-2 (2 files — genuinely deferrable only if actually independent):**
5. `tests/testthat/test_addRectilinearWaypoints.R` — re-pin Track 1 bar-vs-bar defect counts.
6. `tests/testthat/test_resolveEdgeNodeCollisions.R` — re-pin Track 2 collision/obstacle-pair counts.

**Explicit condition on the split, fixing C2-2's core objection:** Commit 3-2 is only a legitimately separate commit if, after Commit 3-1 lands, the full suite is **already green** on these two files without touching them — i.e., the new engine's `x`/`gen` output happens not to change what Track 1/2 measure. **This must be confirmed by actually running the suite after Commit 3-1, not assumed in advance.** If `test_addRectilinearWaypoints.R`/`test_resolveEdgeNodeCollisions.R` go red as a direct, mechanical consequence of Commit 3-1's engine swap, their re-pinning is not deferrable — pull it into Commit 3-1 (raising that commit to 6 files, at which point split it instead into 3-1a/3-1b along some other, genuinely-independent boundary, per `SAFEGUARDS.md`'s 5-file-before-committing rule) rather than landing a known-RED intermediate state.

**Live-rendered verification, required, not optional:** using Phase 2's own `helper-live-render-positions.R` (no new file needed here — this is why that helper was built in Phase 2, not deferred to this phase, fixing C2-4), screenshots/coordinate dumps for at least the F1, Track-C, and real-375-fixture cases, directly confirming the rendered image shows correct child-centering and no new visual overlap — per this project's own memory note that code-level correctness is not evidence of a correct rendered image, and per the S602→S603 precedent of a test-green, code-correct fix that was visually inert.

A fresh `grep` re-confirming the call-site/downstream-consumer inventory above hasn't drifted since this planning session is part of both commits' own verification, not a separate step.

**Verification commands (both commits):**
```
devtools::check()                                                          # full package check, 0 errors/warnings/notes target
Sys.setenv(NOT_CRAN = "true"); pkgload::load_all(".", quiet=TRUE); as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE))
lintr::lint_package()
gh run list --branch master --limit 10                                     # confirm CI green post-push
# plus the live-render check described above, on F1 / Track-C / real fixture, via helper-live-render-positions.R
```

**Rollback:** since Phases 1–2 left the old function intact until this exact phase, rollback is a single revert of the relevant commit — the old function's code still exists immediately prior in git history. Because Commit 3-1 and Commit 3-2 are separately committed, a problem discovered only in Track 1/2's own re-measurement (Commit 3-2) can be rolled back without touching Commit 3-1's already-verified core cutover.

**Session boundary: this phase is one session**, now more realistically sized than the first draft's single undifferentiated block, given the explicit 2-commit structure above.

### Phase 4 — Cleanup and documentation

**What DONE looks like:** `docs/planning/pedigree-diagram-option2-layout-design-plan.md`'s D3 section updated to describe the completed BJL implementation; GitHub issue #141 closed with a citation to this migration's commits and the regression-number re-pin evidence; `BACKLOG.md`'s "Track 3's 2 disclosed trade-offs" item updated; stale in-code comments referencing Track 3/Track 6/`.computeDupNudge()`/the patch-stack removed or updated; `NEWS.Rmd`/`CHANGELOG.md` entries added (this is an internal, `@noRd`-only change with no new exported function and no new Shiny control, so the tutorial/article and `a2interactive.Rmd` checklists likely do not apply — confirm this reading explicitly rather than assume it).

**Verification commands:**
```
grep -rn "Track 6\|Track 3\|computeDupNudge\|finalUnitX" R/ docs/ --include="*.R" --include="*.md"   # confirm no dangling stale references
gh issue view 141 --json state,labels   # or gh api repos/{owner}/{repo}/issues/141 if the GraphQL bug persists -- confirm closed
```

**Session boundary: this phase is one session. New this round, fixing C2-8: acceptable split** if the doc/comment sweep and the issue/BACKLOG/NEWS updates prove too large for one sitting — split into **4a** (docs/planning + BACKLOG.md + in-code comment sweep) and **4b** (issue #141 close-out + NEWS.Rmd/CHANGELOG.md + the a2interactive.Rmd applicability check), matching the same "acceptable split, not a rigid requirement" framing already given to Phases 1–3.

---

## Impact Analysis

### What changes

- `R/makePedigreeDiagramData.R`: `.positionMatingUnitForest()` reimplemented (same name, same input/output contract); `.computeDupNudge()` deleted; the `finalUnitX`/Track-3-clamp/nudge-apply/de-collision/re-sweep block deleted, replaced by one call into the new engine.
- New file(s): the generic apportioning engine (Phase 1a); the forest/mixed-gen design note and any prototype (Phase 1b, not necessarily production code); folded adapter glue (Phase 2, merged at Phase 3 cutover); a reusable live-render verification helper (Phase 2, new this round).
- Tests: `test_positionMatingUnitForest.R`'s positional literals re-pinned; `.computeDupNudge()`'s own tests deleted; `test_positionMatingUnitForestBJL.R` deleted (merged); `test_makePedigreeMatingLayout.R`/`test_addRectilinearWaypoints.R`/`test_resolveEdgeNodeCollisions.R`'s defect-count literals re-pinned with rationale.
- `docs/planning/pedigree-diagram-option2-layout-design-plan.md`, `BACKLOG.md`, GitHub issue #141, `NEWS.Rmd`/`CHANGELOG.md` (Phase 4).

### What does NOT change (explicit scope boundary)

- **D1** (`.buildMatingUnitForest()`'s mating-unit/duplication transformation) — untouched; Walker/BJL take any tree shape as given input.
- **D2** (anchor selection, `preferAnchor()`, including its known LC_COLLATE locale-dependence bug, issue #162) — untouched; feeds sibling/child order as input. The duplicate-occurrence-**selection** mechanism (*which* occurrence anchors) is explicitly out of scope — this migration only changes *positioning* given an already-fixed structure.
- **D4** (founder ordering) — the *decision* is untouched; only its mechanical integration point changes, and (new this round) its own root list is no longer assumed uniform-gen — Phase 1b must handle a multi-gen root list explicitly.
- **D5** (partial-parentage/one-known-parent fallback) — untouched, ordinary leaf attachment either way.
- **D6** (click-navigate, hover tooltip, shape-to-sex legend, 1,500-node cap integration) — untouched; all depend only on the `id`/`x`/`gen` output contract shape, not on how positions were computed.
- **Track 1, Track 2, Track 5** — untouched, per the structural-orthogonality argument confirmed in Evidence-Based Inventory above.
- **`orderBySex` (issue #145)** — same qualifying rule and swap mechanism; only its required sequencing simplifies.
- **The "sibling subtree-width asymmetry" residual** (9/251 edges, Track 6 §1.4/§8) — explicitly not a target; an inherent, already-accepted property of this algorithm family on unevenly-shaped input. Not reopened.
- **The D1 bar-vs-bar x-overlap residual** — explicitly out of scope, untouched, remains its own separate, still-open `BACKLOG.md` item.
- **The Sugiyama/non-rigid-layout investigation's closure** (S588–590, NOT FEASIBLE) — not reopened; this migration completes the existing rigid-subtree contour-merge model, it does not revisit whether that model is the right paradigm.

### What might break (risk assessment)

- **Any test with a hardcoded positional literal from the old algorithm's defect-laden output** — expected to break, must be consciously re-pinned, never silently patched.
- **Track 1/Track 2's own pinned defect-count numbers** — expected to change, very likely improve; re-pin with rationale, don't assume a specific new number in advance.
- **Downstream code relying on a specific numeric `x` value rather than the id/x/gen contract shape** — grep-confirmed zero such dependents outside the file itself; risk assessed low/contained, but Phase 3 must re-grep to confirm this hasn't drifted since this planning session.
- **Live-rendered visual appearance will change** — that is the explicit point of this redesign. No golden-image/screenshot test exists to break, but Phase 3's own live-render verification step (now backed by a concrete, reusable helper, not prose) exists precisely because the absence of an automated golden-image test means a human/live-render check is the *only* check that catches a visually-wrong-but-technically-green result.
- **New this round: Phase 1b concluding "no clean mechanism found."** This is a real possible outcome, not merely a formality — if it happens, the entire Migration Path from Phase 2 onward is blocked until a follow-up research session resolves it, or until the owner accepts a narrower mechanism with a disclosed, lesser guarantee (e.g., the genuine-tree core plus a bounded, explicitly-flagged residual safety-net sweep for the 0-delta/cross-branch cases specifically, rather than eliminating every safety net). This possibility is deliberately not hidden in this document — see Open Questions 1.

---

## Verification Plan

### How the executor confirms each phase and the whole migration is complete

1. **Per-phase verification commands** — listed explicitly under each phase in the Migration Path above; none deferred to "the end."
2. **The full pinned regression-number checklist** (Evidence-Based Inventory table above), each number classified and handled as follows:
   - **Structural counts** (`237` mating units, `102` duplicates, `714` total nodes, edge counts, id sets, anchor counts, gen invariants) — **must remain exactly unchanged**; any drift here is a real regression, since D1/D2/D4/D5 are out of scope.
   - **Positional literals** — **expected to change**; the new value must be derived by actually running the new engine, never hand-derived or guessed, and the test's own comment must state *why* the old value is gone.
   - **Defect-count literals** (Track 1 bar-vs-bar hits, Track 2 collision/obstacle-pair counts, jog-node counts) — **expected to change, plausibly improve**; re-measured and re-pinned the same way, with an explicit note if any of these counts get *worse* (needing its own investigation before Phase 3 closes, not a shrug-and-ship).
   - **The zero-exact-coincidence invariant** — must remain green throughout, and is now explicitly the gate for whether Phase 1b's own mechanism is sufficient (see Phase 2 above), not merely an epistemic-status upgrade to note in passing.
3. **Standard build-equivalent**, per `CLAUDE.md`:
   ```
   devtools::check()                              # 0 errors/warnings/notes target
   devtools::test()  /  testthat::test_local()    # all tests pass
   lintr::lint_package()                          # package loaded first (Learning 224)
   gh run list --branch master --limit 10         # CI status, unconditional every session
   ```
4. **New test cases the redesign specifically adds**, beyond the real 375-individual fixture:
   - Synthetic trees stress-testing the apportion mechanism directly (Phase 1a) — asymmetric deep/shallow shapes, multi-tree forests, the Walker worked-example golden test, **each with a strong, independently-derived exact-value oracle, not a weak structural assertion** (new requirement this round, fixing C2-3).
   - **New this round:** synthetic fixtures specifically exercising every case Phase 1b's design note enumerates — 0-delta individual→union edges, 0-delta mating-unit→phantom-leaf edges, cross-branch duplicate/free-pass reconciliation, and a multi-gen-rooted forest under the synthetic super-root.
   - A duplicate-heavy synthetic fixture exercising full-width phantom-leaf participation specifically (Phase 2).
   - A live-rendered (chromote) visual re-verification of the F1/Track-C/real fixtures (Phase 3), **now via a concrete, reusable, checked-in helper built in Phase 2** rather than a bespoke one-off.
   - A direct assertion that the single-child-union prevalence numbers (83/224 clamp-caused, 87/224 naturally-close, 54/224 already-separated) land where this plan predicts post-redesign — the clamp-caused population should resolve, the naturally-close population should be explicitly characterized rather than silently declared "fixed" or "not fixed."
5. **Performance validation, light-touch, not a hard blocker**: Phase 3 or 4 should include a brief profiling pass at or near the 1,500-node cap — **now explicitly scoped to measure the FULL adapted algorithm (genuine-tree core plus whatever Phase 1b's mechanism turns out to cost), not just the genuine-tree core's own O(n) bound**, per the Decision section's qualification that the bound is proven for the core alone until 1b's mechanism is known.

---

## Open Questions for a Future Session

1. **The mixed-gen/cross-branch apportion mechanism itself — this plan's single biggest open technical risk, elevated from an unstated assumption in the first draft to the top-named item here.** This document identifies the problem precisely (four confirmed instances: individual→own-union, mating-unit→phantom-leaf, duplicate/free-pass cross-branch reattachment, and possibly multi-gen-rooted forests post-trim), corrects two wrong candidate mechanisms (the first draft's global-LEFTNEIGHBOR proposal; naive dummy-node layer padding, which this session's own tracing shows doesn't fit the anomaly's actual shape), and gives Phase 1b a concrete required deliverable and test matrix — but it does not, and cannot, supply the answer itself. This is honest planning-stage scoping, not a gap papered over: resolving it is real design work belonging to a future, dedicated session.
2. **Duplicate-node participation: full-width vs. near-zero-width phantom leaf.** This document gives a reasoned recommendation (full-width) but explicitly defers final ratification to Phase 2's own PRE-RED gate — now also explicitly sequenced *after*, and informed by, question 1's resolution, not decided independently of it.
3. **`SiblingSeparation`/`SubtreeSeparation` differentiation.** This plan recommends both equal to `minSep = 1`, matching today's uniform constant. Whether Walker's own suggestion that `SubtreeSeparation` be "somewhat larger" would improve this project's visual output is untested and left as a future tuning question.
4. **`MEANWIDTH`/per-node-type width accounting** — deliberately deferred, out of this migration's scope.
5. **File organization.** `R/makePedigreeDiagramData.R` is already 2,307 lines. This plan recommends the new generic engine live in its own file but leaves splitting the existing file's other concerns into separate files as an optional, unscoped future opportunity.
6. **Issue #141's `premature optimization` label.** Every prior document in this investigation, including this one, has explicitly declined to change it unilaterally. A human should make this call, informed by — but not dictated by — Phase 1b's eventual asymptotic finding (point 1 above).
7. **The D1 bar-vs-bar x-overlap residual** — explicitly out of scope here. Once this redesign ships, a future session should re-measure it and decide separately whether the pre-existing "bar-aware detect-and-jog repair" idea recorded in `BACKLOG.md` (`:182–198`) is still the right next step.
8. **Whether the "naturally close" single-child-union population (~87/224) should be considered fully resolved, partially resolved, or a distinct, still-open item** once Phase 3's live-render verification actually measures it — this document predicts the shape of the outcome but the real number can only come from running the engine.
9. **New this round: is a deliberately-scoped, well-justified hybrid reviving something like Walker's own global per-level table — but structurally decoupled from `moveSubtree`/`executeShifts`'s sibling-indexed bookkeeping — a legitimate direction for Phase 1b, or does the mechanical objection this session's critique raised rule out that whole family of approach?** This document's own position: the *first draft's specific proposal* was unsound (both misattributed and mechanically broken as grafted), but that does not by itself prove no adaptation of a global-lookup idea can ever work — only that the naive version doesn't. Phase 1b should evaluate this honestly, on its own merits, rather than either resurrecting the first draft's proposal unexamined or discarding the whole idea family because one specific instance of it failed critique.
10. **New this round: does the conditional `gen` recomputation at `R/modPedigree.R:346–348` (`if (!"gen" %in% names(ped))`) actually produce a stale-gen forest root anywhere in practice**, via the three call sites this session did not trace (`R/modGeneticValue.R:296`, `R/modBreedingGroups.R:261`, `R/modSummaryStats.R:388`)? This session upgraded the concern from speculative to plausible but did not resolve it; a future session (most naturally, whoever picks up Phase 1b) should either trace these paths directly or add a defensive assertion inside `.positionMatingUnitForest()`/its replacement that does not assume root-uniformity regardless of the answer.

---

**Files read this session (context, not modified):** `R/makePedigreeDiagramData.R` (lines 300–523 and 655–1226, read in full a second time, independently of the first draft's own citations); `R/findGeneration.R` (1–70, read in full); `R/trimPedigree.R` (1–63, read in full); `R/getProbandPedigree.R` (1–40, read in full); `R/modPedigree.R` (335–382); `docs/planning/pedigree-diagram-single-child-union-parent-coincidence-investigation.md` (owner-directive quote at line 492, and the 83/224 · 87/224 · 54/224 prevalence figures at lines 99–102, both re-verified directly rather than trusted from the candidate plan's own citation); `tests/testthat/test_makePedigreeMatingLayout.R` (110–135, the chromote-POC comment cited by the migration/TDD critique); test file line counts (`test_positionMatingUnitForest.R` 1583, `test_buildMatingUnitForest.R` 444, `test_makePedigreeMatingLayout.R` 1363) re-confirmed via `wc -l`. All three critiques' own findings were treated as inputs to verify against this direct evidence, not accepted or rejected on authority alone — in one place (Phase 1b's own candidate-mechanism discussion, point 3), this session's own tracing of `findGeneration()`'s exact semantics led to a correction of the correctness critique's own suggested literature parallel (dummy-node padding), narrowing it to the more specific same-rank/flat-edge framing the evidence actually supports. No production code was written or modified.