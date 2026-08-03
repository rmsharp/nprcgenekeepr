# Pedigree Diagram Option 2: kinship2-parity layout design

**Status:** RATIFIED 2026-08-02 -- proceed to implementation as written (D1-D6). See §10.
**Session:** S458 (2026-08-02). **Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`.
**Origin:** `BACKLOG.md` "Pedigree Diagram: full kinship2-parity layout (Option 2 design session)"
(filed S457); this is the dedicated follow-up planning session
`docs/planning/pedigree-diagram-mating-lines-plan.md` §3/§7 named as Option 2's required next
step -- design (a) a crossing-minimization node-ordering algorithm, (b) multi-mate/half-sib
fan-out representation, and (c) a loop-safety re-verification approach. This document answers
all three. It does not implement them.
**Touches:** `R/makePedigreeDiagramData.R` (additive -- a new sibling function, existing function
untouched), `R/modPedigree.R:387-468` (render chain switches to the new pipeline). Does **not**
touch `R/findGeneration.R` (consumed as-is; see §1.3 evidence-based inventory for why it must not
change).

---

## 1. Context

### 1.1 What is already decided (do not re-litigate)

S457 ratified **Option 2** (full kinship2-parity layout, built on top of visNetwork) over
reopening D2, over a smaller `visNetworkProxy`-only step (Option 3), and over declining. S457 also
empirically proved (Case C2, 3 `chromote`-screenshotted POCs) that the target convention -- a
horizontal mate-line, a vertical drop, a horizontal sibship bar, vertical drops to each child, all
true right angles -- **is** achievable inside visNetwork, but **only** by abandoning
`visHierarchicalLayout()` entirely and computing every node's x/y by hand (`visPhysics(enabled =
FALSE)`, `visNodes(physics = FALSE)`, edges `smooth = FALSE`). That finding is a **hard constraint**
on everything below: whatever algorithm this document designs must produce **explicit, final x/y
coordinates for every node**, not merely an ordering hint fed to vis.js's own layout engine.

### 1.2 What this document decides

Three D-series decisions, per the BACKLOG item's own scope:

- **D1/D2** -- how the pedigree's DAG structure (individuals can have 2 parents and more than one
  mate) gets transformed into something a tree-positioning algorithm can consume, and how
  crossing-minimization is achieved.
- **D1** (same mechanism) -- how multi-mate/half-sib fan-out is represented.
- **D1** (same mechanism, again) -- how loop-safety is re-established.

A key finding of this session's research (§2): **(b) and (c) are the same problem.** An
individual who mates with more than one partner, and an individual who is a shared ancestor
reached via two reconverging descent paths, are structurally identical from the layout
algorithm's point of view -- both are "an individual who needs to attach to more than one mating
unit." One mechanism (§3 D1) resolves both, and this session found a **real fixture** that already
exercises both simultaneously (§1.4).

### 1.3 Evidence-based inventory (this session, blast-radius confirmation)

Grepped every reference to the functions this design touches or must not touch, across `R/`,
`tests/testthat/`, `vignettes/`, `NEWS.Rmd` (required before any deletion/migration/rename-shaped
plan, `SESSION_RUNNER.md` §Evidence-Based Inventory; this plan is additive, not a rename, but the
same rigor applies to confirm the "additive, not breaking" claim below):

- **`makePedigreeDiagramData()`**: exactly **one** production call site (`R/modPedigree.R:391`),
  one vignette demo (`vignettes/a2interactive.Rmd:349-419`), one `NEWS.Rmd` mention, and its own
  185-line, ~18-`test_that()` test file (`tests/testthat/test_makePedigreeDiagramData.R`). Small,
  contained, exported, and documented as a general-purpose "convert a pedigree into
  visNetwork-ready diagram data" function -- not a good candidate to silently change behavior
  underneath its existing contract (§6 D6, §7 Migration Path resolves this as "new sibling
  function," not "modify in place").
- **`visHierarchicalLayout`**: exactly **one** reference in the entire package
  (`R/modPedigree.R:393`) -- confirms the blast radius really is contained to the Diagram tab's
  own render chain.
- **`findGeneration()`**: referenced from **41 files** across `R/` and `tests/testthat/` --
  kinship calculations, GVA/founder-contribution code, breeding-group logic, relationship
  classification, and more. **This function must not be modified by this design.** The new
  layout algorithm consumes its `gen` output as an input, exactly as `makePedigreeDiagramData()`
  already does today; it does not need `findGeneration()` to do anything different.
- A useful, verified-this-session compatibility fact: `findGeneration()`'s own algorithm (re-read
  in full, `R/findGeneration.R:40-77`) assigns `gen[child] = 1 + max(gen(sire), gen(dam))` whenever
  both parents are known (by construction of its generation-by-generation BFS walk). Since a
  mating unit (§3 D1) only ever exists for a parent pair with at least one recorded child, **every
  mating unit's natural generation level (`max(parent1.gen, parent2.gen)`) is automatically exactly
  one level above every one of its children's `gen`** -- no conflict, no new invariant to enforce,
  confirmed directly from the untouched, already-shipped source rather than assumed.

### 1.4 A real fixture already exercises both (b) and (c) together

`inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv` (the E2E fixture already used by
`tests/testthat/test-e2e-pedigree-module.R`, 375 animals, 9 generations 0-8, verified this session
via `read.csv()` + `findGeneration()`) contains:

- **237 distinct mating pairs** (sire/dam combinations with at least one recorded child).
- **73 individuals with more than one distinct mate** -- 58 sires (one with 7 distinct dams,
  several with 5-6) and 15 dams (up to 3 distinct sires each).
- The **exact** consanguineous-mating case issue #134 already hand-verified for loop-safety under
  today's auto-layout: `GA204Z` (F = 0.25), whose sire `8LKBV9` is also his maternal grandfather.
  **This session confirms `8LKBV9` is himself one of the 58 multi-mate sires (3 distinct dams)** --
  i.e., the SAME real individual that anchors issue #134's loop-safety fixture is simultaneously a
  concrete instance of the multi-mate case. This is not a coincidence to explain away; it is the
  structural identity named in §1.2: "8LKBV9 is his own daughter's grandfather" and "8LKBV9 has
  3 mates" are the same fact (an individual belonging to more than one mating unit) viewed from two
  different starting points in the pedigree.

No synthetic fixture is needed for either the multi-mate or the loop-safety verification (§8) --
one already-bundled, already-QC-pipeline-vetted file covers both, matching this project's own
established "check bundled data first" convention (`PROJECT_LEARNINGS.md` Learning 442).

---

## 2. Research summary (this session)

Full findings (kinship2 source, with `align.pedigree.R`/`alignped1-4.R`/`besthint.R`/`autohint.R`
citations down to specific line numbers; general crossing-minimization literature) are preserved in
this session's workflow journal; condensed here to what drives §3's decisions.

### 2.1 kinship2's `align.pedigree` is NOT a crossing-minimization algorithm

Read directly from the real kinship2 1.9.6.2 source (downloaded from CRAN this session, since the
system-installed copy is R-version-incompatible with this project's renv environment -- see
Learning at close-out) plus its `align_code_details.Rmd` vignette:

- **`besthint()`** (the founder-order search) scores candidate layouts by a 3-part "dotted arc"
  penalty -- (1) count of individuals plotted twice on one level, weighted 1000; (2) the
  horizontal distance between duplicate copies, weighted 10; (3) parent-child centering,
  weighted 1 -- and searches for the **founder order** that minimizes it via an **uncapped
  factorial permutation enumeration** (`besthint.R:23-38`, no pruning, no memoization, only a
  random shuffle + early-exit-on-tolerance as mitigation). This is explicitly named in source as a
  real risk, not a documented-and-accepted one.
- **`autohint()`** (sibling/mate ordering for a fixed founder order) is a single top-to-bottom
  greedy per-level "fixup" pass that relocates duplicate-causing individuals and re-runs
  `align.pedigree()` after each level. The vignette itself concedes this heuristic "works 9 times
  out of 10" (`align_code_details.Rmd:171`) -- i.e., it does not guarantee a duplicate-free (hence
  crossing-free) result.
- Multi-mate handling is real and instructive: each mating is its own row in an internal
  `spouselist` (male-parent idx, female-parent idx, plot-order, **anchor** code); half-sib children
  are grouped by which specific mating (`fam` index), not merely by shared parent, so half-sib
  sibships are never intermingled. The **anchor** concept -- which mate "owns" a mating, i.e. whose
  subtree processes it -- is adopted directly into this design's D2.
- Loop handling is two distinct mechanisms: a **consanguineous mating** (mates share a common
  ancestor) upgrades that mating's line to a double line, no duplication; a **true reconvergence**
  (someone reachable via two structural paths -- exactly the multi-mate case, viewed from the
  child's side) is represented by **literal duplication** of the plain id within the internal grid,
  stitched back visually with a dashed "dotted arc" -- and per the "9 times out of 10" concession
  above, not always successfully collapsed.
- **No published algorithm description or complexity analysis exists** for kinship2's own layout
  engine (confirmed via its own reference publication, Sinnwell/Therneau/Schaid 2014, which
  documents the interface, not the mechanics) -- "porting" it means reverse-engineering
  undocumented internals with nothing to validate the port against, and it is GPL-licensed (the
  same reason every other purpose-built alternative was declined at D2).

### 2.2 The field-standard fix: duplicate/mating-unit transformation, then a tree algorithm

- Classic tree-layout algorithms (Reingold-Tilford 1981; Walker 1990, generalizing to arbitrary
  arity; Buchheim-Jünger-Leipert 2002, fixing Walker's algorithm to genuine linear time) are all
  **tree** algorithms -- their correctness depends on every node having exactly one parent, so
  sibling subtrees are disjoint and can be positioned independently then merged. A pedigree
  violates this at the most basic level (two parents per child, before any loop even exists).
- **CraneFoot** (Mäkinen et al. 2005, `inst/extdata/reference/5201430.pdf`, re-read in full this
  session) solves this by transformation, not by a smarter tree algorithm: collapse every mating
  into its own **mating-unit node**; re-parent every child to link to exactly one mating unit
  (never two separate edges to sire and dam); an individual belonging to more than one mating unit
  is **duplicated**, with dashed lines marking "these are the same physical individual" purely as a
  visual annotation, not a structural edge. The paper states the resulting invariant directly:
  "every child is linked to exactly one mating unit and any pedigree is reduced to a forest of
  rooted trees." Once transformed, a genuine tree algorithm applies with its published correctness
  and complexity guarantees intact -- CraneFoot's own Discussion section names Buchheim-Jünger-
  Leipert's O(n) fix specifically as what makes this "ideal for... interactive applications that
  may have strict restrictions on response time."
- Generic Sugiyama-style layered-graph crossing reduction (the barycenter/median heuristics --
  what vis.js's own opaque, undocumented `visHierarchicalLayout()` almost certainly already runs,
  per this project's own prior research into vis-network GitHub issue #181) approximates an
  NP-hard problem with no crossing-free guarantee and documented local-optimum/initial-order
  sensitivity. Once the mating-unit transformation has run, the resulting structure is a genuine
  tree/forest -- the exact case where crossing-minimization stops being NP-hard and becomes the
  **easy, exactly-solvable** case (keep each subtree contiguous; crossings are zero by
  construction). Layering a full Sugiyama pass on top of an already-tree-shaped structure would be
  solving a harder, more general problem than the one actually remaining, for a weaker
  (heuristically-reduced, not guaranteed-zero) result.
- **License check (this session, not previously done):** the obvious "reuse an existing R
  package" shortcuts are not free. `igraph::layout_as_tree()` implements Reingold-Tilford, but
  `igraph` is `License: GPL (>= 2)`. `data.tree` is also GPL. `ggraph` is MIT, but hard-`Imports`
  `igraph` (confirmed via its own `DESCRIPTION`), so it transitively pulls in the same GPL
  dependency anyway. **No off-the-shelf R tree-layout package is available without introducing a
  GPL dependency**, which directly conflicts with this project's own D2 precedent (MIT project,
  every GPL alternative explicitly declined). Hand-implementing a small, well-specified algorithm
  directly from the published literature is therefore not just appropriately right-sized -- it is
  the only license-clean path available.

---

## 3. Decision

### D1 -- Mating-unit + individual-duplication transformation

A new internal function (working name `.buildMatingUnitForest(ped)`, same `id`/`sire`/`dam`/
`sex`/`gen` input contract as `makePedigreeDiagramData()`) performs the CraneFoot-style
transformation:

1. **Identify mating units.** Every distinct `(sire, dam)` pair with at least one recorded child
   becomes one mating-unit node. Id convention: a sequential, package-generated id
   (`sprintf("__union_%d", i)`, not a string built from the parents' own ids) to make a
   real-id collision structurally impossible rather than merely unlikely, with a loud `stop()` if
   any real pedigree id is ever found to already start with `"__union_"` or `"__dup_"` (the same
   fail-loud convention this package already uses elsewhere, e.g.
   `getFocalAnimalPedFromFile()`'s classed error).
2. **Anchor selection (D2 below)** picks exactly one of the two parents as the mating unit's
   *anchor* -- the parent whose own recursively-positioned subtree structurally owns this mating
   unit as a tree-child.
3. **Re-parent every child** of that mating unit to link to the mating-unit node with a single
   edge (not two edges to sire and dam, as today).
4. **Duplicate every non-anchor attachment.** An individual who is anchor for mating unit A but is
   also a parent in mating units B, C, ... gets one non-participating **duplicate node** at each of
   B, C, ... (id convention: `sprintf("__dup_%s_%d", realId, k)`). A duplicate node carries the
   same `sex`/label/tooltip content as the real individual (§6 D6) but contributes no subtree of
   its own to the recursive layout (§3 D3) -- it is positioned adjacent to its mating unit, not
   derived from lineage.
5. **The same mechanism handles loops.** A consanguineous mating (§1.4's `GA204Z`/`8LKBV9`) is not
   a separate code path: `8LKBV9` is anchor at exactly one of his 3 mating units (by D2's rule)
   and gets 2 duplicate nodes at the other 2 -- one of which is the mating unit that produced
   `GA204Z`'s dam, the structural fact that makes `8LKBV9` "also his maternal grandfather." No
   cycle-detection or special-case loop logic is needed; it falls out of "every individual is
   anchor at most once" applied uniformly.

### D2 -- Anchor selection rule (deterministic, not searched)

For each mating unit, the anchor is chosen by this fixed rule, evaluated once per individual
across all their mating units (not per-pair independently, since an individual's anchor status
must be consistent across all of their own mating units):

1. Prefer the parent who is **not** a founder (has at least one known parent themselves) over one
   who is a founder -- keeps that lineage structurally connected to its own ancestors rather than
   floating detached.
2. If both or neither parent is a founder, prefer the parent with **fewer total distinct mating
   units** (a simpler subtree to anchor).
3. Remaining ties broken by a stable, deterministic key (e.g. `id` string sort) -- not by search.

Each individual is anchor at their earliest-resolved mating unit under this rule and duplicated at
every other one. **This deliberately does not attempt kinship2's `besthint()`-style search for a
globally optimal founder/anchor order.** A fixed, explainable, linear-time rule is preferred over
an uncapped factorial search (§2.1) -- the visual cost of an occasionally-non-minimal arrangement
is bounded and already visually communicated by the dashed duplicate-connector (§6 D6), matching
CraneFoot's own accepted trade-off ("a drawing satisfying all... aesthetics may not be as narrow as
possible... the phenomenon has little practical relevance," Mäkinen et al. 2005).

### D3 -- Tree-native positioning algorithm

After D1's transformation, the structure is a genuine forest rooted at founder individuals
(an isolated founder with no recorded children is its own trivial one-node tree). Position it with
a Reingold-Tilford/Walker-style recursive contour-merge, computed bottom-up (post-order):

1. **Leaf case:** an individual who is not anchor for any mating unit (no children as anchor) is a
   leaf; width = 1 unit.
2. **Recursive case:** for each mating unit `M` where individual `I` is anchor (in D4's order, for
   the rare case `I` anchors more than one): recursively lay out each of `M`'s children (§D1 step
   3); merge the children's subtrees left-to-right via contour merging (shift each subsequent
   subtree right just enough to clear the running right-contour of everything already placed --
   the standard, small, well-specified Reingold-Tilford/Walker step); position `M`'s x at the
   midpoint of its children's merged span.
3. Merge all of `I`'s own mating-unit subtrees (if more than one) left-to-right the same way, then
   position `I` at the midpoint of that merged span (standard centering).
4. **After** every anchor individual's x is fixed, set each mating unit's final x to the midpoint
   of its two parents' x (the anchor parent's position from step 2/3, and the non-anchor parent's
   x = wherever their duplicate node was placed, immediately adjacent to the mating unit). This is
   the exact geometry S457's Case C2 already proved renders correctly in visNetwork with
   `visPhysics(enabled = FALSE)` + fixed coordinates + `smooth = FALSE` edges.
5. Duplicate nodes (D1 step 4) are positioned immediately adjacent to their mating unit, offset to
   one side; they are not recursively laid out and contribute no width to their "home" parent's
   subtree.
6. `y` (vertical position / vis.js `level`) is `gen` for every real/duplicate individual node
   (unchanged from today) and `max(parent1.gen, parent2.gen)` for every mating-unit node (§1.3's
   verified compatibility fact).

This is deliberately a **simplified** Reingold-Tilford/Walker adaptation, not a from-scratch
implementation of Buchheim-Jünger-Leipert's full linear-time algorithm. At this project's actual
scale (375-node real fixture today, 1,500-node cap, §7 revises the practical ceiling), a
straightforward recursive contour-merge is very unlikely to need BJL's specific optimization
(which exists to fix a case where Walker's *original* implementation could degrade to O(n^2) on
pathological inputs); if a future session's profiling at the node-count ceiling shows a real
problem, upgrading the merge step to BJL's apportioning technique is a well-scoped, isolated
follow-up, not something to build speculatively now -- tracked as
[issue #141](https://github.com/rmsharp/nprcgenekeepr/issues/141), labeled `premature
optimization` specifically so it is not picked up until profiling/evidence shows the need is
real.

### D4 -- Founder/root ordering

Founders are ordered by their existing row order in the input pedigree data frame -- matching
kinship2's own stated simplest default ("founders/children in data-set row order" when no hints
are supplied) and explicitly rejecting `besthint()`'s uncapped factorial permutation search (§2.1)
as a known anti-pattern to avoid, not a target to reach parity with. If a future session finds this
produces poor visual results on some real colony pedigree, a cheap non-factorial improvement (e.g.
sorting founders by descendant count, or a single barycenter-style pass across only the founder
set -- a much smaller *n* than the whole pedigree) is a well-scoped, separate follow-up.

### D5 -- Partial-parentage fallback

- **0-parent founders** are roots under D3 with no incoming mating-unit edge (no special casing
  needed beyond "this node has no parent edge").
- **Exactly one known parent** (sire *xor* dam): no mating-unit node is synthesized -- there is no
  pair to represent. The child attaches directly to its one known parent via an ordinary edge,
  identical to today's existing one-edge-per-known-parent behavior for this specific shape.
  `tests/testthat/test_makePedigreeDiagramData.R`'s existing "omits edges for unknown parents" test
  (`tests/testthat/test_makePedigreeDiagramData.R:59-69`) is a direct template for the new test
  covering this fallback.

### D6 -- Integration with the 4 already-shipped Diagram-tab features

Each must keep working against the new node population (real individuals + mating units +
duplicate nodes), not just against real individuals as today:

- **Click-to-navigate (#129 Slice 2):** union-node ids (prefix `"__union_"`) get no click
  affordance / are excluded before the existing `Shiny.setInputValue()` handler's downstream
  lookup runs. Duplicate-node ids (prefix `"__dup_"`) resolve to their real individual's id (a
  lookup table returned alongside the layout, `duplicateNodeId -> realId`) before reaching that
  same downstream logic, so clicking any occurrence of a duplicated individual navigates
  identically to clicking their anchor occurrence.
- **Hover tooltip (#135, `title` field):** union nodes get a minimal tooltip (e.g. offspring
  count) or none. Duplicate nodes show the **same** tooltip content as their real individual's
  anchor node (via the same lookup table), plus a short textual cue that this is a duplicate
  occurrence (vis.js/HTML has no native dashed-arc-between-arbitrary-nodes primitive as
  compact as base-R graphics; the connector itself is an ordinary vis.js edge with `dashes = TRUE`
  between the duplicate node and its anchor -- a real, already-available edge option, not a new
  capability).
- **Shape-to-sex legend (#132):** union nodes need a shape/style clearly distinct from all 5
  existing sex-coded shapes (e.g. small, unlabeled, no legend entry needed if visually minimal
  enough not to be mistaken for an animal -- an implementation session should verify this live,
  not assume it). Duplicate nodes keep their real individual's existing shape/sex-color so they
  still visually "read" as that person; the dashed connector communicates "duplicate," not a shape
  change.
- **1,500-node cap (#138):** see §7 Impact Analysis -- the transformation materially changes what
  "node count" means and the existing cap must be re-measured against the new model, not assumed
  unchanged.

---

## 4. Rationale

The mating-unit/duplicate transformation (D1) is preferred over every alternative in §5 because it
is the **one mechanism that resolves both of the BACKLOG item's remaining open questions at once**
(multi-mate/half-sib representation and loop-safety) rather than requiring two separate solutions,
it is confirmed as the field-standard technique (independently named "union node"/"family node"
elsewhere -- some general graph-drawing literature calls the same pattern a "marriage node," a
term this document does not otherwise use -- per S457's own prior research, and directly documented
as CraneFoot's core idea), and it is the only approach compatible with both this project's hard
fixed-coordinate
constraint (§1.1, from S457's own empirical proof) and its MIT-license precedent (§2.2's license
check rules out every off-the-shelf shortcut). The deterministic anchor/founder-ordering rules
(D2/D4) are chosen specifically to avoid importing kinship2's uncapped factorial search (§2.1) --
this project's own "astronaut architecture"/"right amount of abstraction is the minimum needed
now" value applies directly: a fixed rule that is occasionally non-optimal, with the optionality
visually signaled by a dashed connector, is a better engineering trade than an expensive search for
a marginal, hard-to-perceive visual improvement.

---

## 5. Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|---|---|---|---|
| Port kinship2's `align.pedigree`/`alignped1-4` internals | Mature, battle-tested on real pedigree messiness (twins, an individual with additional matings, arbitrary topology) for years | GPL-licensed (same reason every purpose-built alternative was declined at D2); no published algorithm description or complexity analysis to port against -- confirmed this session via kinship2's own reference publication; founder-order search is an uncapped factorial enumeration; sibling/mate refinement "works 9 times out of 10," not guaranteed | Same license conflict D2 already resolved against every purpose-built alternative; nothing to validate a from-scratch reimplementation against; imports a known unbounded-search anti-pattern |
| Generic Sugiyama-style crossing-reduction pass (barycenter/median heuristic) on top of the mating-unit transformation | Well-studied, widely implemented (Graphviz `dot`, vis.js's own opaque internals) | Approximates an NP-hard problem with no crossing-free guarantee, documented local-optimum and initial-order sensitivity; solves a *harder*, more general problem than what remains after the transformation already converts the structure to a tree (where crossing-minimization is the easy, exactly-solvable case) | Once transformed, the input is a tree/forest -- a full multi-sweep heuristic pass is strictly more machinery, with a weaker (heuristic, not guaranteed-zero) result, than a tree-native positioning algorithm |
| Reuse an existing R tree-layout package (`igraph::layout_as_tree()`, `data.tree`, `ggraph`) | No new algorithm code to write or test | `igraph`/`data.tree` are `GPL (>= 2)`; `ggraph` is MIT but hard-`Imports` `igraph`, pulling in the same GPL dependency transitively (confirmed via each package's own `DESCRIPTION`, this session) | No off-the-shelf option avoids a GPL dependency, conflicting directly with this project's own D2 precedent |
| Implement the full Buchheim-Jünger-Leipert linear-time algorithm from day one | Proven worst-case O(n), matches CraneFoot's own published recommendation exactly | Meaningfully larger, harder-to-verify implementation than a straightforward recursive contour-merge, for a guarantee this project's actual scale (375 nodes today, 1,500-node cap) is very unlikely to need | Right-sized for now: a simpler contour-merge (D3) is adopted, with BJL's specific optimization deferred to a scoped follow-up if profiling ever shows a real problem, not built speculatively |
| Keep `visHierarchicalLayout()`, add only invisible union nodes at the same `level` (S457's Case B) | Smallest possible change; no new positioning algorithm | S457 already empirically proved (Case B) this does not guarantee midpoint placement and cannot produce a horizontal sibship bar at all -- `visHierarchicalLayout()` and fixed/manual coordinates are mutually exclusive in practice (confirmed from the bundled vis.js source) | Already ruled out by S457's own empirical finding; restated here only to confirm this design does not silently reopen it |

---

## 6. Migration Path

Additive, not a replacement of `makePedigreeDiagramData()`'s existing contract (§1.3's inventory
confirms the blast radius supports this):

1. **New internal functions** (`.buildMatingUnitForest()` for D1/D2, a positioning function for
   D3/D4/D5) added to `R/makePedigreeDiagramData.R` or a new sibling file, independently
   unit-testable against synthetic fixtures before any rendering change (rollback: delete the new
   file/functions, zero impact on shipped behavior).
2. **New exported function** (working name `makePedigreeMatingLayout()` or similar) wraps 1 into
   the same `list(nodes, edges)` shape `makePedigreeDiagramData()` already returns, plus the
   `duplicateNodeId -> realId` lookup table D6 needs. `makePedigreeDiagramData()` itself is
   **left unchanged** -- still available for any future lightweight/non-Shiny use, still the
   function `vignettes/a2interactive.Rmd`'s existing demo uses (rollback: this step is purely
   additive; nothing existing depends on the new function yet).
3. **`R/modPedigree.R`'s render chain** (`R/modPedigree.R:387-468`) switches its
   `makePedigreeDiagramData(data)` call to the new function, and its
   `visNetwork::visHierarchicalLayout(...)` pipe step is replaced with
   `visNetwork::visPhysics(enabled = FALSE) |> visNetwork::visNodes(physics = FALSE)` plus fixed
   `x`/`y` columns in the new function's node output (per S457's proven Case C2 geometry); the
   click/export/legend/search pipe steps (D6) get their small adaptations in place. (Rollback: this
   is the one step that changes shipped behavior -- a single commit, revertible independently of
   steps 1-2.)
4. **Documentation checklists** (per `CLAUDE.md`'s citation/tutorial/`NEWS.Rmd` checklists) --
   owed once step 3 ships, not before.

Each step is independently committable and revertible; step 3 is the only one with user-visible
runtime impact, matching this project's "small, additive, per-session slice" precedent
(#131/#132/#135).

---

## 7. Impact Analysis

| Surface | Impact | Action Required |
|---|---|---|
| Click-to-navigate (#129 S2) | Must handle 2 new node-id classes (union, duplicate) | D6 adaptation: id-prefix check + duplicate-to-real lookup before existing handler logic |
| PNG export (#131) | No `visExport()` behavior change -- exports whatever the widget renders | None; verify visually that the new layout exports correctly (§8) |
| Shape-to-sex legend (#132) | Union/duplicate nodes must not be visually confused with real, unmapped-sex individuals | D6: distinct union-node style; duplicate nodes keep real sex-color/shape |
| Hover tooltip + search (#135) | Union/duplicate nodes need tooltip content decisions; `nodesIdSelection` search dropdown should probably exclude union/duplicate ids (a real individual should appear once in the searchable list, not once per occurrence) | D6 adaptation; **new, not previously flagged:** confirm during implementation whether `visOptions(nodesIdSelection = ...)`'s dropdown needs an explicit id filter to avoid listing duplicate/union ids alongside real ones |
| Inbreeding-loop rendering (#134) | Re-established by construction (D1 step 5), not inherited from vis.js's auto-layout -- must be re-verified, not assumed | §8 Verification Plan, reusing the exact `GA204Z`/`8LKBV9` fixture issue #134 already used |
| 1,500-node cap (#138) | **Materially changes.** The transformation adds 1 union node per distinct mating pair plus 1 duplicate node per non-anchor mating a multi-mate individual holds. Measured this session against the real 375-individual/9-generation E2E fixture: 237 union nodes + 130 duplicate nodes = **742 total nodes for 375 individuals (~2x)**. **Corrected S459 (2026-08-02):** implementing and actually running D1/D2's anchor-assignment algorithm against this same fixture (not just the combinatorial estimate above) found the anchor rule collides twice on real data -- 2 mating units where *both* parents had already anchored a different, earlier unit, resolved via the double-anchor fallback D3 step 2 already names as its "rare case." This gives those 2 individuals (`KUENM8`, `IM1B5T`) an extra free anchor slot each, so the verified count is **128 duplicate nodes = 740 total nodes (not 742)** -- a 2-node/~0.3% correction, immaterial to the "~2x" conclusion. The existing cap was calibrated against the old per-individual-only count | Implementation session must re-measure and either reinterpret the existing 1,500 raw-node cap under the new node-counting model, or phrase a new cap in terms of original individual count (e.g. ~750 individuals to keep total nodes near the existing 1,500) -- **do not silently keep "1,500" without re-deriving what it now bounds** |
| `findGeneration()` | **Unaffected** -- consumed as-is (§1.3); 41 other call sites across kinship/GVA/breeding-group code are completely untouched by this design | None |
| `makePedigreeDiagramData()` | **Unaffected** -- left in place as a still-exported, still-simpler function; the new layout is a sibling, not a replacement (§6 Migration Path) | None |
| New dependency | None -- §2.2's license check ruled out every off-the-shelf tree-layout package; the new algorithm is hand-implemented from the published literature | None |
| Engineering scope | Comparable to the original issue #129 implementation (2 slices, S433/S434) or larger, confirmed by this design's own D1-D6 scope, not to the smaller #131/#132/#135 additions | Expect multiple implementation sessions (vertical-slice-gated per `SESSION_RUNNER.md`), not one |

---

## 8. Verification Plan

- **Transformation unit tests** (`.buildMatingUnitForest()`): reuse the existing 6-node
  half-sib-mating synthetic fixture from issue #134's data-layer check (no duplication, no drops,
  `level` values matching `findGeneration()`) plus new tests for: a 2-mate individual (exactly 1
  duplicate node created, at the correct mating unit); the `GA204Z`/`8LKBV9` real-fixture loop case
  extracted as a small standalone fixture (confirms `8LKBV9` gets exactly 2 duplicate nodes, per
  §1.4's finding of 3 total mating units); the 1-known-parent fallback (D5, no union node
  synthesized); the 0-parent founder case (root, no incoming edge). Mirrors the existing test
  file's pattern (`tests/testthat/test_makePedigreeDiagramData.R`).
- **Positioning unit tests**: verify the contour-merge produces no horizontal overlap between
  sibling subtrees on a multi-child, multi-generation synthetic fixture; verify a mating unit's
  final x is exactly the midpoint of its two parents' x on a simple 2-parent/3-child fixture
  (the geometry S457's Case C2 already proved renders correctly).
- **Live `shinytest2`/`chromote` re-verification, matching issue #134's own methodology exactly**:
  drive the shipped app end-to-end against `inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv`
  (the same `AppDriver` helpers `tests/testthat/test-e2e-pedigree-module.R` already uses) and query
  the live `vis.js` `Network` instance's own `DataSet`s directly -- confirm the real individual
  count is unchanged (375), the union/duplicate node counts match this session's measured 237/130,
  no dropped edges, zero console errors, and a visually legible right-angle mate-line/sibship-bar
  render for at least one multi-mate family and the `GA204Z`/`8LKBV9` loop specifically (a dashed
  connector should be visibly present at `8LKBV9`'s 2 duplicate occurrences).
  Also verify **integration behaviors** newly introduced by D6: clicking a duplicate node navigates
  identically to its anchor; clicking a union node is a no-op; the search dropdown does not list
  duplicate/union ids as separate selectable entries (or, if it does, this is a documented,
  owner-reviewed trade-off, not a silent regression).
- **Colony-scale check** before issue #138's node-count cap is revisited: render the full
  375-individual fixture under the new pipeline and confirm the diagram remains visually legible
  (not just non-crashing) -- a subjective check, but a required one, since D3/D4's deterministic
  (non-search-based) ordering rules are the exact place this design accepts a small optimality
  trade-off (§3 D2/D4) that a real render should confirm stays acceptable in practice, not just in
  theory.

---

## 9. Here be dragons (flagging the non-obvious risk, per `SESSION_RUNNER.md` Learning #3)

- **D2's anchor rule interacting with D3's recursion is the least-obvious part of this whole
  design.** An individual's anchor status must be resolved consistently across *all* of their own
  mating units before recursion starts (§3 D2), not decided independently per-pair during the
  recursive walk -- getting this ordering wrong (e.g. computing anchor status lazily inside the
  recursion) risks an individual appearing anchor at zero or more than one position, silently
  breaking the "genuine forest" invariant the rest of D3 depends on. An implementation session
  should compute and validate the full anchor assignment (every individual anchor at exactly one
  mating unit, or zero if they are never a parent) as a **separate, tested step** before writing
  any positioning code, with an explicit assertion/error if the invariant fails on real data --
  not an implicit assumption. **Resolved S459 (2026-08-02):** `.buildMatingUnitForest()`'s
  anchor-assignment pass, run against the real 375-individual fixture, found the invariant does
  *not* hold universally as "exactly one, or zero" -- 2 individuals (`KUENM8`, `IM1B5T`) anchor 2
  mating units each, via the exact collision D3 step 2 already names as its "rare case" (both
  parents of a shared mating unit had already anchored a different, earlier unit). Implemented as
  a deterministic fallback (re-apply the same founder/mate-count/id criteria, ignoring
  already-anchored status, so the unit still gets exactly one anchor) rather than an error, since
  D3 already anticipates and positions for this case. See §7's corrected node-count figures.
- **The 1,500-node cap's re-derivation (§7) is easy to skip silently** because nothing in the code
  will visibly break if it is skipped -- the app will simply start rejecting/warning on pedigrees
  around half the size it used to handle, with no obvious signal pointing back to this design
  change as the cause, unless an implementation session deliberately re-measures and documents the
  new ratio (measured this session at ~2x for one real fixture; the ratio is data-dependent, since
  it scales with how multi-mate the specific colony's breeding structure is, not a fixed constant).
  **Resolved S461 (2026-08-02):** re-derived to **750 individuals** (owner-directed via
  `AskUserQuestion`), keeping the total rendered node count near the original ~1,500 ceiling this
  cap was actually calibrated for. This is BELOW the 962-individual focal-trim example in
  `vignettes/articles/colony-manager-guide.qmd` -- accepted knowingly, since that example was only
  ever evidenced through the Table tab, never proven to render through the Diagram tab itself.
- **§1.1/§8's "right-angle mate-line/sibship-bar" language describes a technique D1-D6's own
  decision text (§3) never specifies.** S457's original Case C2 proof-of-concept (cited in §1.1)
  achieved true right angles using extra invisible waypoint nodes; D3's actual positioning
  algorithm creates no such nodes. An implementation session should not assume citing §1.1/§8 is
  equivalent to having a specified rendering technique -- this is a real gap, not an oversight to
  silently paper over. **Resolved S461 (2026-08-02):** rendered as direct edges (parent -> mating
  unit, mating unit -> child, no waypoint nodes) -- owner-directed via `AskUserQuestion` after a
  live `chromote` POC against the real `GA204Z`/`8LKBV9` loop fixture and a wide fan-out fixture
  confirmed this reads clearly as a family group without literal right angles. The fuller
  rectilinear waypoint style is tracked as a deferred, additive follow-up,
  [issue #142](https://github.com/rmsharp/nprcgenekeepr/issues/142), not built speculatively here.
- **New dragon found S461, not previously flagged:** a "free-pass" individual (an individual whose
  one non-anchor mating-unit occurrence needed no duplicate node, per S460's own resolution) can
  render visually close to an unrelated same-generation node, since D3's contour-merge guarantees
  only "no exact collision" (verified numerically), not a minimum visual spacing. Found via this
  session's own live POC render of the real `GA204Z`/`8LKBV9` fixture (5A6DFT and G8EBU9 land only
  0.25 layout units apart at gen 0, both free-pass-adjacent nodes nested at different recursion
  depths). This is inherited from Slice 2's already-shipped, already-tested positioning algorithm --
  Slice 3 (render-chain wiring) did not reopen or fix it, matching kinship2's own accepted "not
  always successfully collapsed" trade-off for duplicate placement. A future session revisiting D3
  would need a genuine minimum-separation guarantee (not just non-collision) to close this gap.
- **New dragon found S461, live-verification-only (not reachable by any self-contained-fixture unit
  test): `.buildMatingUnitForest()`'s D2 anchor tie-break is ROW-ORDER-sensitive, and
  `qcStudbook()` (already-shipped, pre-dating Option 2 entirely) reorders rows relative to the raw
  uploaded file.** Slices 1/2's own "740 total nodes for the real 375-individual fixture" figure is
  specific to reading the raw CSV directly (`read.csv()`, the unit tests' own input path); the LIVE
  APP feeds `.buildMatingUnitForest()` the QC-CLEANED, reordered pedigree instead, which resolves
  one anchor tie-break differently (a rare "both parents equally eligible" case whose winner depends
  on which one is processed first) -- yielding **739** total nodes for the identical underlying
  data. Both counts are internally self-consistent, valid applications of the same deterministic
  algorithm to two different (but equally correct) row orderings; neither is "wrong." A future
  session writing a NEW unit test against "the real bundled fixture" should state explicitly whether
  it means the raw CSV or the QC-cleaned pedigree, since the two now yield different (both correct)
  figures -- confirmed via a direct comparison this session
  (`runQcStudbook()` -> identical id/sire/dam content, `identical(ped$id, raw$id)` is FALSE).
- **New defect found and fixed S461, live-verification-only: `.buildMatingUnitForest()` crashed
  ("missing value where TRUE/FALSE needed") on any pedigree where a sire/dam value has no own row**
  -- e.g. `R/modPedigree.R`'s own pre-existing "Trim pedigree based on focal animals" feature
  (`trimPedigree(..., addBackParents = FALSE)`, unchanged, not introduced by Option 2), which keeps
  a blood relative's row but not that relative's own mate's row. `isFounderOf()`'s `match(x, ids)`
  returned `NA` for such a "dangling" reference, propagating into an `if (fa != fb)` comparison.
  Slices 1/2 never exercised this path -- both were `@noRd`, tested only against self-contained
  fixtures (every referenced parent also has its own row) -- so Slice 3 wiring the code into the
  live render chain for the first time is what surfaced it, exactly the kind of gap Phase 3E's live
  verification (not skippable for this slice) exists to catch. Root-cause fix landed in Slice 1's
  own file (`.buildMatingUnitForest()`/`.positionMatingUnitForest()`), not worked around in Slice
  3's wrapper: a dangling reference is now treated as a founder (no information says otherwise) and
  can never become an anchor (there is no individual to recursively position for them -- their real
  mate always wins outright); a dangling free-pass/duplicate node's gen falls back to its own
  mating unit's gen. A dangling individual gets no rendered node of their own (nothing real to
  show) -- only their mating unit's geometry uses their position as an input. 6 new unit tests
  (`test_buildMatingUnitForest.R`, `test_positionMatingUnitForest.R`); the exact live crash (click
  `8LKBV9` to trim, re-render the Diagram tab) re-verified fixed via `shinytest2`/`chromote` after
  the fix. See `PROJECT_LEARNINGS.md` Learning 457.
- **D3's simplified contour-merge is genuinely new code, not a port of a citable algorithm's
  reference implementation** -- unlike D1 (CraneFoot's published transformation, precisely
  specified) it is *inspired by* Reingold-Tilford/Walker/Buchheim-Jünger-Leipert rather than a
  direct implementation of any one of them. An implementation session should expect this to need
  its own careful edge-case testing (deeply unbalanced trees, a founder with many mating units,
  wide sibships) rather than assuming citing the literature is equivalent to having verified
  behavior against it. If that testing (or later production profiling) surfaces a genuine
  quadratic-degradation case, [issue #141](https://github.com/rmsharp/nprcgenekeepr/issues/141)
  tracks upgrading to Buchheim-Jünger-Leipert's apportioning technique -- filed but deliberately
  not scheduled (`premature optimization` label) until that evidence exists.
  **Resolved S460 (2026-08-02):** implemented as `.positionMatingUnitForest()`, edge-case-tested
  (not just literature-cited) against 8 toy fixtures -- a simple trio, a multi-mate anchor with
  uneven-depth subtrees, a D5-mixed subtree, the real `GA204Z`/`8LKBV9` loop, a half-sib convergent
  loop, an isolated founder beside an unrelated family, an 8-mate wide fan-out, and a deeply
  unbalanced 6-generation chain -- plus the full real 375-individual fixture, all clean (~26ms, no
  quadratic-degradation signal at this scale). Found and resolved 2 gaps this section's own text did
  not anticipate: contour occupancy must be indexed by each node's absolute real `gen`, not relative
  recursive depth (D3 step 6 pins y to real `gen`, which diverges from recursive depth once a
  duplicate/free-pass node is re-attached deep inside another individual's subtree -- impossible in
  a genuine tree, possible here); and even gen-indexed contours leave a residual ancestor-vs-nested
  -descendant exact-coincidence edge case (12/740 nodes, ~1.6%, on the real fixture), resolved with
  a small deterministic post-placement nudge applied only to individual/union nodes. See
  `PROJECT_LEARNINGS.md` Learnings 451-453.

---

## 10. Owner ratification record

- [x] **Proceed to implementation following this design (D1-D6) as written**
- [ ] Proceed with modifications (specify which D-decision(s) to revisit)
- [ ] Hold -- more research needed before implementation begins

Ratified via `AskUserQuestion`, S458 (2026-08-02), with one editorial direction applied in the same
turn: use non-human-centric terminology throughout (`sire`/`dam`/`male`/`female`/`mate`/`mating`,
not `husband`/`wife`/`marriage`/`spouse`) -- applied across §2.1's description of kinship2's own
internal data structures and §5's Alternatives table; kinship2's actual `spouselist` variable name
is preserved verbatim only where this document cites the literal identifier from its source code.
No D-decision was revisited; the design (D1-D6) is ratified as written.
