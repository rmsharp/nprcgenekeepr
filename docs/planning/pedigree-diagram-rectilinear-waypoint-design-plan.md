# Pedigree Diagram Option 2: full rectilinear mate-line/sibship-bar waypoint style (issue #142)

**Status:** RATIFIED 2026-08-03 -- proceed to implementation as written (D1-D5). See §10.
**Session:** S464 (2026-08-03). **Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`.
**Origin:** [issue #142](https://github.com/rmsharp/nprcgenekeepr/issues/142), filed S461
(2026-08-02) as a deferred, additive follow-up to Option 2 Slice 3's direct-edge render
chain. Picked up this session via the S463 close-out `AskUserQuestion` picker.
**Touches:** `R/makePedigreeDiagramData.R` (additive -- a new parameter/helper on
`makePedigreeMatingLayout()`, `.buildMatingUnitForest()`/`.positionMatingUnitForest()`
untouched), `R/modPedigree.R` (a new edge-style toggle control + reactive wiring). Does
**not** touch the D1-D6 mating-unit-forest structure or positioning algorithm
(`docs/planning/pedigree-diagram-option2-layout-design-plan.md`) -- issue #142's own scope
note requires reusing Slices 1/2's already-computed x/y, and this document honors that.

---

## 1. Context

### 1.1 What is already decided (do not re-litigate)

S457 ratified Option 2 (full kinship2-parity layout on visNetwork) and empirically proved
(Case C2) that a strict right-angle mate-line/sibship-bar convention is achievable inside
visNetwork via invisible waypoint nodes and hand-computed coordinates. S458 designed and
S459-461 implemented D1-D6: a CraneFoot-style mating-unit/duplicate-node transformation
(`​.buildMatingUnitForest()`) plus a Reingold-Tilford/Walker-style contour-merge positioning
pass (`.positionMatingUnitForest()`), wrapped by the exported `makePedigreeMatingLayout()`.
S461 shipped this with **direct edges** (parent -> mating-unit, mating-unit -> child, no
waypoints) as a deliberate, owner-verified choice -- not a placeholder -- and filed the
fuller rectilinear style as issue #142, explicitly scoped as additive: *"New invisible
waypoint nodes reusing Slice 1/2's already-computed x/y positions (no rework of the
positioning algorithm itself). Edge routing through the new waypoints instead of direct
parent/union/child edges. Likely a diagram-style toggle so both conventions remain
available."* This document designs exactly that.

### 1.2 Current implementation (re-read in full this session)

`R/makePedigreeDiagramData.R:650-788`, `makePedigreeMatingLayout()`:

- `nodes$x <- pos$x[posMatch] * xScale` (`xScale = 120`), `nodes$y <- pos$gen[posMatch] *
  yScale` (`yScale = 150`) -- every node (real individual, duplicate, mating-unit) gets a
  final, fixed `(x, y)` from `.positionMatingUnitForest()`'s output, consumed by
  `R/modPedigree.R:409-412`'s `visPhysics(enabled = FALSE)` / `visNodes(physics = FALSE)` /
  `visEdges(smooth = FALSE)` chain -- no hierarchical auto-layout, no curve interpolation.
- A mating-unit node's `x` is **already** the midpoint of its anchor and non-anchor
  parent's `x` (`R/makePedigreeDiagramData.R:562-580`, D3 step 4); its `y` is
  `unitGen * yScale` where `unitGen = max(sireGen, damGen)`
  (`R/makePedigreeDiagramData.R:248-250`, `.buildMatingUnitForest()`).
- Current edges (`R/makePedigreeDiagramData.R:743-783`): `mateEdges` (anchor -> unit,
  non-anchor-or-its-duplicate -> unit, both `dashes = FALSE`), `childEdgesOut` (unit -> child,
  or a single known parent -> child under D5, `dashes = FALSE`), `dupEdges` (duplicate ->
  real, `dashes = TRUE`). All are plain 2-node edges; none pass through a waypoint.
- Reserved id prefixes `"__union_"` / `"__dup_"` are validated exclusive of real ids at
  `.buildMatingUnitForest()`'s own entry point (`R/makePedigreeDiagramData.R:144-149`), and
  consumed downstream by click-to-navigate (`R/modPedigree.R:512`, excludes `"__union_"`;
  resolves `"__dup_"` via the `duplicateToReal` lookup) and the search dropdown
  (`R/modPedigree.R:487-489`, excludes both prefixes from `nodesIdSelection`'s `values`).
- **No diagram-style toggle exists today** -- `R/modPedigree.R`'s render chain always calls
  `makePedigreeMatingLayout(data)` with no style parameter.

### 1.3 Verified this session: vis.js genuinely supports a `hidden` node/edge option

Read directly from the version bundled with this project's installed `visNetwork` 2.1.4
(not assumed): `docjs/network/nodes.html:226` and `docjs/network/edges.html:249` both list
`hidden: false,` as a real top-level option in vis.js's own documented full-options JSON
(cross-checked against 6 occurrences of `"hidden"` in the bundled
`vis-network.min.js`). This means new waypoint nodes can be made genuinely invisible
(`hidden = TRUE`) while the edges connecting them remain visible and draw the rectilinear
path -- the same "small, unlabeled dot" compromise D6 used for mating-unit nodes is not
needed here; waypoints carry no semantic content (no tooltip, no click affordance, no
legend entry) and should be fully hidden, confirmed as a real, not assumed, capability.

### 1.4 A load-bearing gap this session found: the mate-line is only guaranteed horizontal
### when both parents share the same generation

Re-reading `.buildMatingUnitForest()`'s own `unitGen <- pmax(genOf[unitSire],
genOf[unitDam])` (`R/makePedigreeDiagramData.R:248-250`): a mating unit's `y` is the
**later** (larger) of its two parents' generations. When both parents share one generation
(the common case), the unit's `y` equals both parents' `y`, so a direct anchor->unit or
non-anchor->unit edge is *already* horizontal today (`smooth = FALSE` draws it as a literal
straight line with equal endpoints' `y`). But when the two parents are at **different**
generations -- an ordinary, real case (an age-gap mating; structurally the same root
condition as the not-yet-fixed founder-positioning defect below) -- the earlier parent's own
`y` does **not** equal the unit's `y`, so a plain 2-node edge between them is unavoidably
diagonal, regardless of waypoints added elsewhere. A rectilinear design that only handles
the equal-generation case would produce a **mixed** style (some mate-lines a clean right
angle, others silently still diagonal) with no visible signal that this is happening --
exactly the kind of gap this project's own "here be dragons" convention exists to surface
before implementation, not after.

**Measured this session against the real 375-individual fixture (not assumed): this is not
a rare corner case -- it is the majority case.** Running `.buildMatingUnitForest()` /
`.positionMatingUnitForest()` directly against `inst/extdata/examples/
obfuscated_rhesus_mhc_ped.csv` found **147 of 237 mating units (62%)** have anchor and
non-anchor parents at different generations. This follows directly from D2's own anchor
rule (Option 2 design doc §3 D2: "prefer the parent who is not a founder") -- whenever one
parent of a mating is a founder (always `gen == 0`) and the other is not, the anchor is
the non-founder parent by rule, and a founder's mate can be at any generation greater than
0. An outside/founder animal mating into an established line is an ordinary breeding-colony
pattern, not a synthetic edge case. §3 D2 resolves this generally.

### 1.5 Explicit scope boundary: the founder-positioning defect is a separate, unpicked item

`BACKLOG.md`'s "Founder-positioning defect" item (found S463,
`docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`) is a **different, still
undecided** piece of work: `.positionMatingUnitForest()` does not move a marry-in founder's
own `x`/`gen` to reflect the generation they actually mate into, so their existing position
can land inside an unrelated couple's own mate-line span. That defect is in **D3's
coordinate assignment**; this document is about **edge routing** given whatever coordinates
D3 already assigned. **The two are orthogonal, not sequenced**: implementing this design
does not fix that defect (a rectilinear connector will route correctly to the founder's
existing, possibly-wrong position, exactly as today's diagonal edge does); fixing that
defect does not require touching anything this design adds. This document proceeds
independent of that item's resolution, per the owner's own session-selection this round
(picked #142, not the founder-positioning-defect item). §1.4's different-generation case is
a **distinct**, more general fact (age-gap matings occur even with fully correct
positioning) -- not a symptom of that defect.

### 1.6 What must not regress

The same four shipped Diagram-tab features named in the Option 2 design doc's §1.4
(click-to-navigate #129 S2, PNG export #131, shape-to-sex legend #132, hover-tooltip +
search/highlight #135), plus D6's own already-shipped integration (duplicate-node click
resolution, union-node click no-op, real-ids-only search dropdown) and the two correctness
properties re-verified for the *direct-edge* style specifically (inbreeding-loop rendering
#134, the 750-individual node cap #138) -- **these must be re-verified for the rectilinear
style separately, not assumed inherited**, since #142's own waypoint nodes materially change
what "node count" means yet again (§7).

---

## 2. Research summary (this session)

### 2.1 Generation semantics for the D5 (single-known-parent) case, verified against
### `findGeneration()`'s actual algorithm

`R/findGeneration.R:40-77`'s breadth-first walk places `id` at generation `i` as soon as
*every known* parent (an `NA` parent trivially satisfies its own membership test) is already
resolved -- so a child with exactly one known parent gets `gen[child] = 1 + gen(known
parent)`, the identical relationship as the two-known-parent case. Consequence, verified
directly from source rather than assumed: **all children who share one single known parent
(D5) are automatically at the same `gen`**, exactly as all children of one two-parent mating
unit are (already established in the Option 2 design doc §1.3). The sibship-bar mechanism
(§3 D1) therefore generalizes to D5 groups with no special case beyond "there is no second
parent to draw a mate-line to."

### 2.2 Re-confirming Case C2's technique is what this document formalizes, not a new idea

S457's Case C2 proof-of-concept (`docs/planning/pedigree-diagram-mating-lines-plan.md` §2.3)
already empirically proved the general technique -- invisible waypoint nodes, hand-computed
coordinates, `smooth = FALSE` -- renders the target convention correctly in visNetwork. That
POC pre-dated the D1-D6 mating-unit-forest model (built directly against 2 parents/3
children with no union/duplicate concept) and its exact node/edge counts do not transfer
1:1 onto the now-existing model; this document's §3 designs the waypoint mechanism fresh
against the *actual* `makePedigreeMatingLayout()` node/edge shapes rather than assuming
Case C2's counts still apply.

---

## 3. Decision

### D1 -- Sibship-bar waypoint chain (generalizes to both mating-unit and D5 origins)

For every distinct `childEdges$from` value `F` (a mating-unit id **or**, under D5, a single
real parent id) with children `C1..Ck` (`k >= 1`, all sharing one `gen`, per §2.1):

1. **Drop node** `D_F`: one new invisible node per `F`, at `(F.x, childGen * yScale)` where
   `childGen` is the children's shared generation. Since `F.x` is reused verbatim from the
   already-computed layout (mating-unit `x` or the single real parent's own `x`), and
   `D_F.y` differs from `F.y` by construction, edge `F -- D_F` is a **guaranteed vertical**
   (equal `x`, unequal `y`).
2. **Bar-point nodes** `B_1..B_k`: one new invisible node per child, at `(Ci.x, childGen *
   yScale)` -- i.e., each child's own `x`, projected onto the shared child row. Edge
   `B_i -- Ci` is a **guaranteed vertical** (equal `x` by construction).
3. **The bar itself**: sort `{D_F} union {B_1..B_k}` by `x` and connect consecutive pairs
   with plain edges. Every point in this set shares the same `y` (`childGen * yScale`), so
   every connecting edge is a **guaranteed horizontal** segment, and the full sorted chain
   reads visually as one continuous sibship bar regardless of where `D_F.x` falls relative
   to the children's span (leftmost, rightmost, or between two children -- no special case
   needed; a plain `order()` on `x` handles all three).
4. **Degenerate case (`k == 1`, one child):** the chain has exactly 2 points (`D_F`, `B_1`),
   i.e. one horizontal segment plus 2 verticals -- still a real right angle at both corners,
   not a bar that degrades to a single diagonal line. No special case needed; step 3's
   generic sort-and-chain logic already produces this shape for `k == 1`. **Verified this
   session (constructed minimal fixture, not assumed): `D_F` and `B_1` can land at the exact
   same `x`** when `F` has only this one subtree (`.positionMatingUnitForest()`'s
   `finalizeNode()` collapses a single child's offset to 0) -- 224 of the real fixture's 237
   groups are single-child, though none happen to tie in that specific fixture (a 2-parent
   unit's `x` is overridden to the parents' own midpoint, decoupling it from the child's `x`
   in that case; a tie is more reachable under D5). This is harmless, not a defect: a
   zero-length "bar" segment plus two stacked verticals still renders as one straight vertical
   line, not a diagonal -- but an implementation session should not be surprised to see it and
   should not treat it as a bug to special-case away.

This replaces `childEdgesOut` (§1.2) as the rectilinear style's child-side routing. It adds
`k + 1` new invisible nodes (`D_F` plus `B_1..B_k`) and `2k + 1` new edges per distinct
`childEdges$from` group: `k` chain segments connecting the `k + 1` sorted bar-row points,
`k` verticals from each `B_i` down to its child, and 1 vertical from `F` up to `D_F` -- see
§7 for the aggregate impact.

### D2 -- Mate-line dogleg for parents at different generations

For each mating unit `U` with anchor `A` and non-anchor `N` (or `N`'s duplicate node, if one
was placed at `U`, per the existing `mateEdges` lookup, `R/makePedigreeDiagramData.R:749-767`):

- **The rule applies uniformly to each side independently -- it must not assume the anchor
  is always the on-row parent.** `U.gen = max(A.gen, N.gen)` (D1) guarantees *at least one*
  of `A`/`N` equals `U.gen`, but the anchor-selection rule (Option 2 design doc §3 D2:
  founder-status first, then mate count, then id) is **not** generation-aware, so either
  side can be the one that matches. **Verified this session against the real fixture, not
  assumed:** of 237 mating units, 90 (38%) have both parents already at `U.gen` (no waypoint
  needed on either side), **96 (41%) have the non-anchor off-row, and 51 (22%) have the
  anchor itself off-row** -- an earlier draft of this design incorrectly presumed the anchor
  always coincides with `U.gen`; the rule below is written to require no such assumption.
- For **each** of `A`/`N` independently, **the relevant `x`/`gen` are always the ACTUAL
  rendered node's own values, not necessarily the real individual's** -- for the anchor side
  this is always `A`'s own real node (the anchor is never itself substituted with a
  duplicate); for the non-anchor side it is whichever node the existing `mateEdges` lookup
  already resolved to (`R/makePedigreeDiagramData.R:757-761`): `N`'s real node if no
  duplicate was placed at `U`, or `N`'s **duplicate node at `U`** if one was (using the
  duplicate's own `dupX`/`gen`, not `N`'s real `x`, which can sit far away at `N`'s own
  anchored subtree elsewhere in the forest). **This is not a rare distinction to gloss over:
  verified this session against the real fixture, 57 of the 96 non-anchor-off-row mating
  units have the non-anchor represented by a duplicate at that unit** -- using the wrong
  (real, distant) `x` instead of the duplicate's own nearby `x` would silently break the
  "guaranteed vertical" property this whole mechanism depends on. Gen-wise there is no
  ambiguity (a duplicate's `gen` always equals its real individual's `gen`, confirmed at
  `R/makePedigreeDiagramData.R:585`, including for a dangling parent's duplicate via
  `.positionMatingUnitForest()`'s own gen back-fill) -- only the `x` lookup must resolve to
  the specific node actually drawn at this unit.
- With that node identified: if its `gen == U.gen`, its edge to `U` is already horizontal
  (equal `y`) -- **no waypoint needed for that side**. If its `gen != U.gen`, add one new
  invisible **projection node** `P` at `(thatNode.x, U.gen * yScale)` -- that node's own `x`
  (per the paragraph above), projected onto the mate-line's row. Route `thatNode -- P`
  (guaranteed **vertical**, equal `x`) then `P -- U` (guaranteed **horizontal**, equal `y`,
  since `P.y = U.y` by construction) instead of the single diagonal `thatNode -- U` edge.
  Since at most one side can differ from `U.gen` at a time (by construction of `max()`), at
  most one projection node is ever needed per mating unit -- but which side needs it must be
  checked per-unit, not assumed fixed to non-anchor.
- **This is a strict generalization, not a special case bolted on**: when `thatNode.gen ==
  U.gen` already, `P` would coincide exactly with `thatNode`'s own position, so the rule is
  simply "only synthesize `P` when `gen != U.gen`, checked independently per side." The
  fully-aligned case (38% measured) needs no extra node at all; the other 62% (either side
  off-row) gets a genuine two-segment right-angle dogleg instead of a silently-still-diagonal
  line.
- This resolves §1.4's gap generally, for any generation gap on either side (not just a
  1-level age difference, and not just the non-anchor side), without touching D1-D6's
  positioning algorithm or the founder-positioning defect (§1.5) -- it routes correctly to
  whatever `x`/`gen` D3 already assigned, right or wrong.

### D3 -- Reserved id prefix and D6 re-adaptation for the new waypoint node classes

New reserved prefixes, validated the same way `.buildMatingUnitForest()` already validates
`"__union_"`/`"__dup_"` (`R/makePedigreeDiagramData.R:144-149` extends to include the three
below):

- `"__drop_<unionId-or-parentId>"` (D1's per-group drop node)
- `"__bar_<childId>"` (D1's per-child bar-point node)
- `"__proj_<parentId>"` (D2's projection node)

All three get `hidden = TRUE` (§1.3) and are excluded from:
- **Click-to-navigate** (`R/modPedigree.R:512`): extend the `startsWith()` filter (or switch
  to a single `grepl("^__union_|^__drop_|^__bar_|^__proj_", ids)` exclusion, folding in the
  existing `"__union_"` check) -- these nodes carry no clickable identity. **Verified this
  session: this exclusion must stay separate from `"__dup_"`, which today's click handler
  deliberately does NOT exclude** (a duplicate node stays clickable so it resolves to its
  real individual via `duplicateToReal`, `R/modPedigree.R:514-516`) -- an implementer
  "folding both existing filters into one shared regex" for convenience must not accidentally
  widen the click-handler's exclusion to include `"__dup_"`, which would silently break
  duplicate-node navigation.
- **Search dropdown** (`R/modPedigree.R:487-489`): extend the existing
  `!grepl("^__union_|^__dup_", ...)` regex to also exclude the three new prefixes.
- **Shape-to-sex legend** (#132): unaffected -- `hidden = TRUE` nodes do not register as a
  distinct visible shape needing a legend entry (an implementation session should confirm
  this live, matching this project's own "verify hands-on, do not assume" precedent for
  every prior D6 integration decision).
- **Hover/search highlight (#135, `visOptions(highlightNearest = list(degree = 1, hover =
  TRUE, ...))`)** -- **a real regression risk this session found, not previously
  considered.** Today, a hovered individual's nearest edge-graph neighbor is a mating-unit
  node (visible, `shape = "dot"`, `size = 6`) or another individual -- always something
  visible. Under the rectilinear style, D1 replaces every direct child edge with a multi-hop
  chain through `hidden = TRUE` drop/bar nodes, so a real individual's nearest neighbor by
  edge-degree becomes an invisible node. Degree-1 highlighting could dim the entire
  surrounding neighborhood with nothing visibly lighting up in return -- a materially worse
  experience than today's shipped behavior, not a neutral side effect. This must be
  re-verified live (§8) and, if confirmed, may need `highlightNearest`'s `degree` raised (to
  hop past the invisible waypoints) or a different mechanism entirely for the rectilinear
  style specifically -- this document does not resolve which, only flags that #135's existing
  verification does not cover it.

Duplicate-node click resolution (`R/modPedigree.R:514-516`) and hover-tooltip content are
**unaffected** -- waypoint nodes are never a duplicate node's own identity, and having
`hidden = TRUE` means no hover event reaches them in the first place.

### D4 -- A diagram-style toggle, defaulting to today's shipped behavior

Per issue #142's own scope note ("likely a diagram-style toggle, per owner feedback"), add
a new reactive UI control to `R/modPedigree.R`'s Diagram tab -- a `shiny::radioButtons()` or
equivalent, namespaced, with two choices: **"Direct" (current, default)** and
**"Rectilinear (kinship2-style)"**. `makePedigreeMatingLayout()` gains a new parameter
`edgeStyle = c("direct", "rectilinear")`, default `"direct"` -- preserving its existing
contract. **Verified this session (correcting an earlier draft's false claim): every real
caller of `makePedigreeMatingLayout()` -- `tests/testthat/test_makePedigreeMatingLayout.R`'s
12+ call sites, and `vignettes/a2interactive.Rmd:423`, which calls this exact function (not
`makePedigreeDiagramData()`, as an earlier draft of this document incorrectly stated) and
prints its node/edge counts as rendered tutorial output -- invokes it positionally with only
the pedigree argument**, so adding `edgeStyle` with a trailing default is genuinely
non-breaking for all of them; the vignette's own printed counts are unaffected since it never
passes `edgeStyle`. `diagramLayout()` (`R/modPedigree.R:396-401`) passes `edgeStyle =
input$<newControlId>` through. **Defaulting to "Direct" is a deliberate risk-reduction
choice**, not an arbitrary pick: every already-shipped correctness/legibility verification
(issue #134's loop rendering, issue #138's 750-individual cap) was performed against the
direct style specifically; making "Direct" the default means no existing user sees any
behavior change unless they explicitly opt into the new style, and the rectilinear style's
own re-verification (§8) is scoped and owned by this feature rather than silently inherited.

**A genuine UI-placement gap, found this session, not previously acknowledged: there is no
existing "obvious home" for this control.** `R/modPedigree.R`'s "Display Options"
`wellPanel` (around lines 98-141) is shared across the Table and Diagram tabs (rendered
regardless of which is selected), so placing the new toggle there would surface it,
irrelevantly, on the Table tab too. The Diagram `tabPanel` itself contains only a bare
`uiOutput` whose reactive body is either a warning `div` (over the node cap) or a
`visNetworkOutput` -- no existing sibling-control area. An implementation session should
treat this as **net-new UI layout to design** (e.g. a small control row rendered inside the
Diagram tab's own `uiOutput`, alongside the widget, only when a diagram is actually shown),
not as slotting a control into a place that already exists for it.

### D5 -- Waypoint construction is a pure post-processing step, not a `.positionMatingUnitForest()` change

D1's drop/bar nodes and D2's projection nodes are computed **entirely from already-final**
`x`/`gen` values (`pos$x`, `pos$gen`) that `.positionMatingUnitForest()` already returns --
no change to that function's own contour-merge algorithm, its D2 anchor rule, or its D4/D5
fallbacks. This is implemented as a new step inside `makePedigreeMatingLayout()` (guarded by
`edgeStyle == "rectilinear"`), or a new internal helper it calls
(`.addRectilinearWaypoints(nodes, edges, forest, pos)`) -- consistent with the Option 2
design doc's own "additive sibling function, not a modification" migration precedent (§6
there; §6 here).

---

## 4. Rationale

D1's generalized "sort-and-chain" bar construction is preferred over a per-arity-count
special case (e.g. hand-coding the 1-child, 2-child, N-child shapes separately) because it
collapses every shape -- single child, small sibship, wide fan-out -- into one small,
uniformly-correct rule with no branching on `k`, matching this project's own "right amount
of abstraction is the minimum needed now" value already applied to D2/D4's anchor and
founder-ordering rules in the Option 2 design doc. D2's projection-node rule is preferred
over either (a) silently leaving the different-generation case diagonal (a **mixed** style
with no visible signal it is happening, contradicting the entire point of an explicitly
opt-in "Rectilinear" style choice) or (b) requiring D3's positioning algorithm to force
same-generation alignment for all mates (which would be a genuine rework of the ratified,
already-shipped positioning algorithm -- explicitly out of scope per issue #142's own text,
and would re-open the founder-positioning-defect question this document deliberately keeps
separate, §1.5). Defaulting the new toggle to "Direct" (D4) is preferred over defaulting to
"Rectilinear" because it is the only choice that ships with zero re-verification debt at
merge time -- every user's rendered diagram is byte-for-byte unchanged until they opt in.

---

## 5. Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|---|---|---|---|
| Leave different-generation mate-lines diagonal (skip D2 entirely) | Smaller implementation; fewer new nodes | Produces a **mixed** style with no visual explanation of why some mate-lines are square and others are not -- a real, common case (§1.4), not an edge case to hand-wave away | Contradicts the entire premise of an explicit style choice; a viewer who opts into "Rectilinear" should get a consistently rectilinear diagram |
| One shared "junction" node per group instead of a chained bar (single node where the drop meets the bar, with each child's vertical edge fanning out from that one node) | Fewer nodes for small sibships | Only produces a true horizontal bar when every child's edge to the junction happens to be horizontal, i.e. only when every child shares the junction's exact `x` -- false in general (children are spread across the contour-merge's span); reduces to the already-shipped, already-rejected "diagonal fan from one point" look for any sibship of 2+ children at different `x` | Does not achieve the target convention (a real bar spanning the sibship's width) except in a degenerate 1-child case, which D1's generalized chain already handles correctly with no special case |
| Force D3's positioning algorithm to align both mates to one shared row (fixing §1.4's gap at the source instead of routing around it with D2's dogleg) | Would make every mate-line trivially horizontal, no projection nodes ever needed | A genuine rework of the ratified, already-shipped D1-D6 positioning algorithm (out of scope per issue #142's own text); risks the same class of regression D3's contour-merge already had to work through (Learnings 451-453); conflates this document's scope with the separate founder-positioning-defect question (§1.5) | Issue #142 explicitly scopes this as additive, reusing already-computed `x`/`y`; §3 D2 already achieves a fully general, always-square mate-line without touching positioning |
| Default the new toggle to "Rectilinear" (make it the new default look) | Matches the owner's originally-cited kinship2 references most closely out of the box | Ships with unre-verified loop-safety (#134) and node-cap (#138) behavior as the DEFAULT experience for every existing user, the first time this diagram tab silently looks and scales differently after an update | "Direct" as default isolates all re-verification risk to users who explicitly opt in; matches this project's own low-risk-first precedent (Option 3 in the original mating-lines plan was preferred specifically for being the smaller, safer step before Option 2 was chosen) |

---

## 6. Migration Path

1. **New internal waypoint-construction helper** (working name
   `.addRectilinearWaypoints()`), independently unit-testable against synthetic fixtures
   (mirroring `test_positionMatingUnitForest.R`'s pattern) before any rendering change.
   Rollback: delete the new function, zero impact on shipped behavior.
2. **`makePedigreeMatingLayout()` gains the `edgeStyle` parameter** (D4), default
   `"direct"` -- calls the new helper only when `edgeStyle == "rectilinear"`. Existing
   behavior for every current caller (with no `edgeStyle` argument) is byte-for-byte
   unchanged. Rollback: this step is purely additive; nothing existing depends on the new
   parameter.
3. **`R/modPedigree.R`'s render chain** gains the new `radioButtons()` control and passes
   its value through to `diagramLayout()`'s call (D4); the click-to-navigate and search-
   dropdown id-prefix filters extend to the 3 new reserved prefixes (D3). Rollback: this is
   the one step with user-visible runtime impact -- a single commit, revertible
   independently of steps 1-2, same as the Option 2 design doc's own precedent for its
   analogous step 3.
4. **Documentation checklists** (`CLAUDE.md`'s citation/tutorial/`NEWS.Rmd` checklists) --
   owed once step 3 ships (a new user-facing control), not before.

---

## 7. Impact Analysis

| Surface | Impact | Action Required |
|---|---|---|
| Click-to-navigate (#129 S2) | New waypoint ids must be excluded, same treatment as existing `"__union_"` handling | D3: extend the id-prefix filter |
| PNG export (#131) | No `visExport()` behavior change | None; verify visually that the rectilinear style exports correctly (§8) |
| Shape-to-sex legend (#132) | `hidden = TRUE` waypoints should not register as an unmapped visible shape | D3: confirm live, not assumed |
| Hover tooltip + search (#135) | Search dropdown must exclude 3 new reserved prefixes alongside the existing 2. **New risk found this session:** `highlightNearest`'s degree-1 hover highlighting may dim a neighborhood with nothing visibly lighting up, since a real individual's nearest edge-graph neighbor becomes a `hidden = TRUE` waypoint under the rectilinear style -- not covered by issue #135's existing verification | D3; §8 requires a live re-check of `highlightNearest` specifically, not just tooltip content and the dropdown |
| Inbreeding-loop rendering (#134) | **Must be independently re-verified for the rectilinear style** -- issue #134's own verification was against the direct-edge style specifically; a waypoint chain routing to a duplicated individual's position is new code, not proven by the existing result | §8, reusing the same `GA204Z`/`8LKBV9` fixture, rendered under `edgeStyle = "rectilinear"` |
| 1,500-node-derived 750-individual cap (#138) | **Materially changes again -- measured this session, not estimated.** Running the real algorithm's own output (`.buildMatingUnitForest()`/`.positionMatingUnitForest()`) against `inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv` (375 individuals, 740 total nodes today under the direct style, S459's verified count): D1 adds one drop node per distinct `childEdges$from` group (237) plus one bar-point node per child (251 total childEdges rows in this fixture -- confirmed zero of them are D5 single-parent groups, all 237 groups are 2-parent mating units) = **488 new nodes**; D2 adds one projection node per mating unit with mismatched parent generations, measured at **147 of 237 (62%)**. **Verified total: 740 + 488 + 147 = 1,375 rendered nodes for the same 375 individuals -- a 1.86x increase over the already-shipped direct style's own total, and 3.67x the raw individual count** (vs. the direct style's already-known ~2x). At the existing 750-individual cap (calibrated to keep the *direct* style near ~1,500 total nodes), a rectilinear-style render of a similarly-structured 750-individual pedigree would be expected to approach **~2,750 total rendered nodes** -- a scale this diagram has never been legibility-tested at, in either style. **This is not a footnote; it is the single most consequential number in this document** (§9) | Implementation session: re-run this same measurement once waypoint construction is implemented (confirm 1,375 or explain any drift); bring the concrete ratio to the owner via `AskUserQuestion` to decide the rectilinear-specific individual cap -- this document's own math (`750 * 1.86 / 3.67 = 380`) suggests roughly **~380 individuals**, not the rounder ~400 an earlier draft of this document misstated, to keep rectilinear-mode total nodes near the same ~1,500 ceiling the existing cap targets; the owner should ratify the actual number, and a future session should re-measure on a second real fixture before treating 62%/3.67x as a general constant rather than this one colony's own breeding-structure signature |
| `.buildMatingUnitForest()` / `.positionMatingUnitForest()` | **Unaffected** -- D1/D2/D5 (this document) consume their output as-is; no change to anchor selection, contour-merge, or the founder-positioning defect (§1.5, tracked separately) | None |
| `makePedigreeDiagramData()` | **Unaffected** -- untouched since the Option 2 design doc's own migration path; this document only extends `makePedigreeMatingLayout()` | None |
| New dependency | None -- `hidden` is a native vis.js/visNetwork option (§1.3), no new package | None |
| Engineering scope | Smaller than the original D1-D6 implementation (no new positioning algorithm, no new crossing-minimization concern) but larger than the #131/#132/#135 UI-only additions, since it touches both the data layer (new nodes/edges) and the render chain (new control + re-verification of 2 correctness properties) -- comparable to one focused implementation slice, not a multi-slice campaign | Expect 1-2 implementation sessions (vertical-slice-gated per `SESSION_RUNNER.md`) |

---

## 8. Verification Plan

- **Waypoint-construction unit tests** (new function): a 1-child mating unit (2-point chain,
  no special case per D1 step 4); a 3-child sibship (4-point chain, verify sort order
  handles the drop node landing left/middle/right of the children); a D5 single-known-parent
  group with 2 children (no mate-line, sibship-bar only); a mating unit with both parents at
  the same `gen` (zero projection nodes, D2's no-op case); a synthetic mating unit with
  parents at different `gen` (exactly one projection node, on the correct side); the reserved
  -prefix collision guard extended to the 3 new prefixes, mirroring
  `test_buildMatingUnitForest.R`'s existing pattern for `"__union_"`/`"__dup_"`.
- **`edgeStyle` parameter tests** on `makePedigreeMatingLayout()`: default (`"direct"`, no
  argument) produces byte-identical output to today's shipped behavior; `"rectilinear"`
  produces the expected additional node/edge counts for a small synthetic fixture with a
  known, hand-computed expected shape.
- **Live `shinytest2`/`chromote` re-verification, matching issues #134/#135's own
  methodology exactly**: drive the shipped app against
  `inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv` with the new toggle set to
  "Rectilinear," and confirm: a visually legible right-angle mate-line/sibship-bar for at
  least one multi-child family and for the `GA204Z`/`8LKBV9` loop specifically; zero console
  errors; click-to-navigate and the search dropdown behave identically to the direct style
  (waypoints invisible and non-interactive); PNG export produces a valid file under the new
  style; **`highlightNearest` hover-highlighting on a real individual actually lights up a
  visibly connected neighbor, not just "no error"** -- the specific new risk found this
  session (§3 D3) that issue #135's own prior verification never exercised, since it predates
  any hidden-node routing. This is the re-verification §1.6/§7 requires -- issue #134's own
  prior result does **not** cover this style.
- **Node-count re-measurement** (§7): once waypoint construction is actually implemented,
  re-run the same measurement this document already performed analytically against
  `.buildMatingUnitForest()`/`.positionMatingUnitForest()`'s real output (488 + 147 = 635 new
  nodes, 1,375 total) directly against the implemented `edgeStyle = "rectilinear"` code path,
  and confirm it matches (or explain any drift). Bring the confirmed number to the owner via
  `AskUserQuestion` to ratify the rectilinear-specific individual cap (§7 suggests ~380 as a
  starting point, not a final answer).
- **A synthetic age-gap-mating fixture** (D2's dogleg case) -- since the real bundled fixture
  may or may not contain a same-anchor-different-generation mating naturally, an
  implementation session should construct one explicitly to exercise D2's projection-node
  path, rather than relying on incidental coverage from the real fixture alone.

---

## 9. Here be dragons (flagging the non-obvious risk, per `SESSION_RUNNER.md` Learning #3)

- **§7's node-count impact is this document's single most consequential number, and it is
  measured against the real fixture's own group/mismatch counts this session -- but not yet
  measured against actually-implemented waypoint-construction code**, since that code does
  not exist yet. The 1,375-node/3.67x figure is derived from real `.buildMatingUnitForest()`/
  `.positionMatingUnitForest()` output (237 mating units, 251 childEdges rows, 147
  mismatched-generation pairs are all real, not estimated), combined with this document's own
  D1/D2 counting rules (`k+1` nodes per group, `+1` per mismatched pair) -- an implementation
  session must still confirm the actual generated node count matches once the code is
  written, as a cheap sanity check, not because the underlying counting logic is expected to
  be wrong. An implementation session must treat "re-confirm the number before deciding the
  cap" as a hard gate, not a nice-to-have -- shipping this feature without that confirmation
  risks silently regressing #138's already-once-corrected cap the same way the *original*
  1,500-node cap was calibrated against the wrong node-counting model before Option 2 shipped
  (Option 2 design doc §7/§9). **The 62% mismatched-generation rate is itself worth flagging
  to the owner independent of this document's own decision** -- it is a strong, real-data
  signal that the not-yet-picked-up founder-positioning defect (§1.5) is also likely common
  in practice, not rare, directly relevant to that item's own still-open "not yet confirmed
  against a real bundled fixture" question. This document surfaces that signal but does not
  act on it -- the founder-positioning-defect item remains a separate, unpicked decision.
- **D2's dogleg only handles a two-segment right angle (vertical then horizontal); it does
  not attempt to make the *overall* mate-line visually symmetric** (e.g. a projection on only
  one side means the mate-line's "corner" is offset toward whichever parent is off-row, not
  centered the way it would be if both parents were on the same row). This is a legitimate,
  smaller aesthetic question an implementation session should render and eyeball (matching
  D3/D4's own accepted "small optimality trade-off, confirm it stays acceptable in practice"
  precedent) rather than assume away.
- **This design deliberately does not fix the founder-positioning defect (§1.5)** and an
  implementation or review session should resist the temptation to fold that fix in "since
  we're already touching this area" -- doing so would conflate two analytically separate
  BACKLOG items and violate this project's mode-switch/scope-creep discipline
  (`SAFEGUARDS.md` §The Two-Mode Problem). If the rectilinear style's own live verification
  (§8) happens to render the founder-positioning defect *more* visually obvious (a true right
  -angle connector to a wrong position may look more jarring than today's diagonal one), that
  is useful evidence to report back to the owner, not a license to fix it in the same
  session.
- **`hidden = TRUE` is confirmed as a real vis.js option (§1.3) but not yet confirmed to
  compose correctly with `visPhysics(enabled = FALSE)` + fixed `x`/`y` + `smooth = FALSE`
  specifically** -- this project's own established discipline (every prior D6 integration
  decision was verified live, not assumed) means an implementation session's Pre-RED should
  render one minimal waypoint-containing widget via `chromote` and confirm hidden nodes
  truly render invisibly (no stray dot) while their edges draw correctly, before writing the
  full waypoint-construction function against that assumption.

---

## 10. Owner ratification record

- [x] **Proceed to implementation following this design (D1-D5) as written**
- [ ] Proceed with modifications (specify which D-decision(s) to revisit)
- [ ] Hold -- more research needed before implementation begins
- [ ] Decline -- close issue #142 without implementing

Ratified via `AskUserQuestion`, S464 (2026-08-03). No D-decision was revisited; the design
(D1-D5) is ratified as written, including its own flagged open item (the exact
rectilinear-mode individual cap, suggested ~380, to be confirmed by re-measuring against
actually-implemented code before an implementation session ships it) and its explicit
scope boundary (the founder-positioning defect, `BACKLOG.md`, remains separate and
unpicked). This document itself was adversarially reviewed this session by 3 independent
agents checking its claims against the real source and the real bundled fixture before
ratification -- findings incorporated: a real correctness gap in D2 (which node's `x`/`gen`
to use when the non-anchor side is a duplicate, affecting 57/96 cases), a previously
unconsidered regression risk in issue #135's `highlightNearest` hover-highlighting, a false
claim about which function `vignettes/a2interactive.Rmd` demos, an arithmetic rounding
overstatement (~400 corrected to ~380), and 2 minor prose/count fixes.

---

## 11. Implementation addendum (Session 465, 2026-08-03): the `hidden = TRUE`
## mechanism does not work as designed -- corrected before RED

**§1.3/§9's "not yet confirmed to compose correctly" dragon fired for real.**
Session 465's mandatory Pre-RED live-verification (a minimal `visNetwork` widget
reproducing `R/modPedigree.R`'s exact render chain -- `visPhysics(enabled =
FALSE)` / `visNodes(physics = FALSE)` / `visEdges(smooth = FALSE)`, fixed
`x`/`y`, driven via `shinytest2`/`chromote`) found that **a node with
`hidden = TRUE` causes vis.js to suppress every edge connected to it,
regardless of the edge's own `hidden` setting.** Confirmed with 4 isolation
tests (screenshots plus live `network.body.edges`/`network.redraw()`
inspection): an `A -- W -- B` right-angle chain with `W.hidden = TRUE` rendered
**zero edges** -- not just a hidden `W` node, the connecting edges themselves
never drew, even though each edge's own `options.hidden` read `false`. This
is undocumented on vis.js's own `hidden` option pages (both node and edge) but
is real, reproducible, unaffected by a forced `network.redraw()`.

**Working alternative, verified this session:** give each waypoint node
`size = 0` and fully transparent `color.background`/`color.border`
(`"rgba(0,0,0,0)"`) instead of `hidden = TRUE` -- vis.js still computes and
draws edges connected to it (it is not flagged `hidden`), and a zero-size,
fully-transparent node renders no visible mark. **A second, related gotcha
found in the same investigation:** vis.js edges default to
`color.inherit = "from"` (undocumented interaction, confirmed from the
bundled docs' own text: "the edge will inherit the color from the border of
the node on the 'from' side") -- so an edge whose `from` endpoint is the new
transparent waypoint node silently inherits that transparent color and still
renders invisible, **even with `hidden` no longer involved at all**. Isolated
across 7 throwaway POC apps: the failure depended specifically on which side
the transparent node occupied (`from` broke it, `to` did not), matching this
inheritance rule exactly, not a size-related rendering degeneracy (a
non-zero `size = 1` transparent-colored `from` node still failed; a fully
opaque `size = 0` `from` node still succeeded) -- ruling out node size itself
as the cause. **Fix:** give every new waypoint-touching edge (D1's
`F -- D_F`, the bar chain, `B_i -- C_i`; D2's `thatNode -- P`, `P -- U`) an
explicit `color` value (matching the existing default edge color,
`"#2B7CE9"`, for visual consistency with the direct style's own
inherited-from-node-border color) -- per the bundled docs, defining `color`
at all disables inheritance automatically ("When color, highlight or hover
are defined, inherit is set to false").

**What changes in D1/D3, what does not:** D1's and D2's own *geometry*
(node positions, which edges connect which points, the sort-and-chain
mechanism, the projection-node rule) is **unaffected** -- this is a
node/edge-*styling* correction only. D3's reserved-id-prefix validation,
click-to-navigate exclusion, and search-dropdown exclusion are **unaffected**
-- they operate on id string prefixes, not the `hidden` flag. The
`highlightNearest` regression risk D3 already flagged is, if anything,
**slightly more load-bearing** now: a `size = 0`/transparent node is not
flagged `hidden` at all (unlike the originally-designed mechanism), so it is
in every sense a normal graph node to vis.js's interaction layer, and D3's
own live re-verification requirement (deferred to the UI-wiring session)
still applies, unchanged in scope.
