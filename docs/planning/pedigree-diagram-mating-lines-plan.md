# Pedigree Diagram: kinship2-style mating-line / sibship-line rendering

**Status:** RATIFIED 2026-08-02 — **Option 2 (full kinship2-parity layout on visNetwork)**
selected. This session did not implement it: per Option 2's own scope note (§3) and
`SESSION_RUNNER.md`'s planning/implementation boundary, full parity is a multi-slice feature
comparable in size to the original issue #129 implementation and needs its **own dedicated
planning session** first (its own D-series decisions: the crossing-minimization algorithm,
multi-mate/half-sib representation, and loop-safety re-verification approach) before any code is
written.
**Session:** S457 (2026-08-02). **Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`.
**Origin:** `BACKLOG.md` "Pedigree Diagram tab does not visually indicate mating/couple
relationships" (owner-observed, filed S456, 2026-08-02, DECISION NEEDED, Effort M).
**Touches:** the ratified D2 (visNetwork) decision in
`docs/planning/issue129-pedigree-diagram-tree-visualization-plan.md`.

---

## 1. Context

### 1.1 Problem statement

The Diagram tab (`R/modPedigree.R`, `R/makePedigreeDiagramData.R`, shipped across issue #129
Slices 1-2 and follow-ups #131/#132/#134/#135) renders each parent-to-child relationship as its
own directly-sloped `visNetwork` edge. Two mates who share children have **no visual connection
to each other** — a viewer cannot tell which two individuals are a breeding pair just by looking
at the diagram; that information can only be inferred by mentally grouping edges that converge on
the same children.

The owner cited two reference pages illustrating the alternative, long-standing convention used
by pedigree-charting tools (kinship2's `plot.pedigree()` and similar): a **horizontal line**
joins two mates, a **vertical line** drops from the midpoint of that line to a **horizontal
sibship line**, and each child hangs from the sibship line by its own vertical drop. This
immediately shows both "who is a breeding pair" and "who are full/half siblings" at a glance.

### 1.2 Current implementation (read in full this session)

**`R/makePedigreeDiagramData.R:67-73`** — edge construction is one edge per known parent, not one
edge per parent *pair*:

```r
hasSire <- !is.na(ped$sire)
hasDam <- !is.na(ped$dam)
edges <- data.frame(
  from = c(ped$sire[hasSire], ped$dam[hasDam]),
  to = c(ped$id[hasSire], ped$id[hasDam]),
  stringsAsFactors = FALSE
)
```

A fully-known-parentage child gets 2 separate edges (sire→child, dam→child); there is no
union/couple node and no concept of "this sire and this dam are the same mating." `ped$gen`
(from `findGeneration()`) is copied directly into vis.js's `level` field
(`R/makePedigreeDiagramData.R:62`) — `findGeneration()` computes generation number only (a
breadth-first, ego/parents-set walk from founders), nothing about horizontal ordering or
edge-crossing minimization exists anywhere in this codebase today.

**`R/modPedigree.R:387-468`** — the render pipe chain is `visNetwork()` →
`visHierarchicalLayout(direction = "UD", sortMethod = "directed")` → `visEvents(click = ...)`
(click-to-navigate, issue #129 Slice 2) → `visExport(png, ...)` (issue #131) → `visLegend(...)`
(issue #132) → `visOptions(nodesIdSelection, highlightNearest)` (issue #135). **No `visPhysics()`
or `visNodes()` call exists in this chain** — node placement is entirely delegated to vis.js's
hierarchical auto-layout heuristics. `pedigreeDiagramMaxNodes <- 1500L`
(`R/modPedigree.R:366`) caps the diagram at 1,500 nodes (issue #138 tracks lifting this).

### 1.3 The original D2 decision already named this exact tradeoff

`docs/planning/issue129-pedigree-diagram-tree-visualization-plan.md` §3, D2 (read in full,
verbatim):

> **D2 — Rendering technology: visNetwork.** Rationale: MIT license matches the project exactly
> (unlike every purpose-built genetics candidate, all GPL); lean, actively-maintained dependency;
> native Shiny interactivity (pan/zoom/click-to-select feeding back into the server) comes for
> free via its htmlwidget bindings, which purpose-built static plotters (kinship2, pedtools,
> ggpedigree's static mode) do not offer without a render-to-image workaround. **Accepted
> tradeoff: pedigree-specific semantics (sex-to-shape mapping, sire/dam edge styling, generation-
> to-level mapping) must be hand-built on top of vis.js's generic hierarchical layout — no
> kinship2-style specialized inbreeding-loop compact alignment.** Declined: kinship2 (static-only,
> a real interactivity gap given the ratified goal); pedtools (same static-only limitation, plus
> forces an R-version-floor bump to ≥ 4.2); ggpedigree (heaviest new-dependency footprint of any
> candidate, and a very recent, less battle-tested release history); deferring the pick to a
> prototype spike (adds a slice without a compelling reason once visNetwork's fit was judged
> sufficient from live-verified CRAN evidence).

**This matters for framing the decision below: the gap the owner observed is not an oversight.**
It is the literal, named consequence of a tradeoff the project already evaluated and accepted at
D2 ratification, now visible because the feature has shipped. The question this session answers
is not "was D2 a mistake" but "given D2 stands, can the missing convention be added on top of it,
and at what cost."

### 1.4 What must not regress

Four features have shipped on top of visNetwork's hierarchical layout since D2 and must not
break: click-to-navigate (issue #129 Slice 2), PNG export (issue #131), the shape-to-sex legend
(issue #132), and hover-tooltip + search/highlight (issue #135). Two correctness properties must
also hold: inbreeding-loop/consanguinity rendering, hands-on verified correct under the *current*
auto-layout (issue #134), and the 1,500-node practical-scale cap (issue #138, a deliberate,
not-yet-lifted limit — a real bundled fixture already populates a 375-ID search dropdown,
S454).

### 1.5 The related, narrower prior audit finding

The kinship2-comparison audit's checklist table row 8, "Multiple mates/spouses"
(`docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md:67` — **not** its prose
"Finding #8," which is a different, unrelated item about node labels; this session found and
corrects the loose citation in the BACKLOG item that prompted this plan), scored the absence of a
union/couple node **"Equivalent-different-approach,"** reasoning "nprcgenekeepr's model has no
'childless union' concept to lose in the first place, since it only draws edges backed by actual
child records." That framing was narrowly about *childless/remarriage unions* kinship2 can
represent and this package's data model doesn't need to. It did not evaluate the broader
visual-clarity question this plan addresses — whether *all* mated pairs, including ones with
recorded children, should be visually distinguishable as a unit. Whatever this plan's decision
adds should be read as superseding/extending that table row, not contradicting it.

---

## 2. Research: what the literature and the library actually support

### 2.1 Prior art (papers supplied by the owner this session)

- **Mäkinen et al. 2005, "High-throughput pedigree drawing"** (*Eur. J. Hum. Genet.* 13:987-989;
  `inst/extdata/reference/5201430.pdf` this session, not committed — see §6). CraneFoot's
  "pedigree transformation" (Fig. 1) collapses every mated pair into a single **mating-unit
  node**; every child is re-parented to link to exactly one mating unit, reducing any pedigree
  (including cyclic/inbred ones) to a forest of rooted trees before a Walker-II-derived
  node-positioning algorithm runs. This is the textbook version of the "invisible union node"
  technique the owner anticipated this session, confirming it as the standard technique, not
  a novel idea specific to this project's situation.
- **Fuchsberger et al. 2008, "PedVizApi"** (*Bioinformatics* 24(2):279-281;
  `inst/extdata/reference/bioinformatics_24_2_279.pdf` this session, not committed). Uses a
  **Sugiyama layered-graph algorithm** — the same general algorithm family vis.js's hierarchical
  layout itself implements — to lay out extended pedigrees. Its own published figure (Fig. 1, a
  1,270-individual pedigree) renders as a dense, heavily-crossing generic network diagram, **not**
  a clean orthogonal chart — i.e., even a purpose-built pedigree tool using a generic layered
  algorithm doesn't get the clean kinship2 look "for free" from the algorithm alone; kinship2's
  distinctive clarity comes from further pedigree-specific refinement on top, not from the layered
  layout family in general.
- kinship2 itself: the two owner-cited pages (an epilepsygenetics.blog anecdote, an RPubs code
  demo) were fetched in full this session and, on inspection, neither explains kinship2's
  algorithm. Independent knowledge fills the gap: kinship2's plotting is a custom recursive
  **auto-alignment** algorithm (`align.pedigree`/`alignped*` internals) that explicitly reasons
  about mating pairs and sibships — a purpose-built, domain-specific layout engine, not a generic
  graph-drawing library. This is the core asymmetry underlying this whole question: kinship2 is a
  pedigree-shaped hammer; vis.js is a general graph-shaped hammer being asked to drive a
  pedigree-shaped nail.

### 2.2 vis.js's actual technical capabilities (verified against the bundled source, this session)

Read directly from the version bundled with this project's installed `visNetwork` 2.1.4
(`htmlwidgets/lib/vis/vis-network.min.js`, `docjs/network/edges.html`,
`docjs/network/layout.html`) and cross-checked against the upstream vis-network source:

| Question | Finding |
|---|---|
| Can an edge render as a true right-angle polyline? | **No.** Every `smooth`-enabled type — including `'horizontal'` and `'vertical'` — is drawn via `ctx.quadraticCurveTo()`/`ctx.bezierCurveTo()` (confirmed in `bezier-edge-static.ts`); `type` only moves the curve's control point, it never produces a hard corner. The **only** literal straight-line primitive is `smooth.enabled = false` (`StraightEdge`, a plain `ctx.lineTo()`) — a diagonal unless the two endpoints happen to share an exact x or y coordinate. |
| Can hierarchical layout pin a node to an exact free-axis position (e.g., the midpoint of two other nodes)? | **No.** `direction` fixes one axis by `level`; the other ("free") axis is entirely delegated to the `edgeMinimization`/`blockShifting` heuristics, with no config option to force a value. `nodes.html` states plainly that a node's `x`/`y` "has no effect... when using hierarchical layout." |
| Is there a documented technique for this exact use case? | **No official one.** GitHub issue [visjs/vis-network#181](https://github.com/visjs/vis-network/issues/181), "recommended configuration for vis-network for family tree graph" (opened 2019, unresolved through 2021), is the closest thing to an authoritative discussion — the maintainer describes the needed capability (custom same-level node ordering + crossing reduction) as a **library-internal feature that was never built**, not an existing option. Independent community attempts (a CodePen family-tree demo; a production Russian-language genealogy site) both use small connector/"marriage" nodes but with ordinary curved vis.js edges, not a strict orthogonal look — and the genealogy site's own author explicitly names "several marriages" (i.e., this project's multi-mate case) as still unsolved in a live deployment. |
| Is there a real escape hatch? | **Yes, but partial.** `network.moveNode(id, x, y)` can reposition a node *after* hierarchical layout stabilizes (read the mates' settled positions via `getPositions()`, compute the midpoint, move the invisible union node there). visNetwork's R wrapper exposes this via `visNetworkProxy` + `visMoveNode()`/`visGetPositions()` — but **only inside a live Shiny reactive session**, not a static/knitr render. That is not a blocker here: `R/modPedigree.R`'s Diagram tab is already a live `renderVisNetwork()` inside a Shiny module, so this R-native (not hand-injected JS) path is genuinely available. It does not, by itself, produce right-angle edges (§2.2 row 1 still applies) or solve sibship-bar alignment for >2 children (below). |

### 2.3 Empirical verification (this session, not taken on faith)

Built and screenshotted three minimal `visNetwork` widgets (2 mates, 3 children) via `chromote`,
matching this project's established "verify actually functional, not just plausible" standard
(`PROJECT_LEARNINGS.md` Learnings 419/445):

- **Case A — today's shipped behavior** (direct sire/dam→child edges, `visHierarchicalLayout`):
  reproduces exactly the owner's complaint — 6 directly-sloped, crossing edges, no visual mate
  cue.
- **Case B — a union node added at the SAME `level` as both parents, otherwise still under
  `visHierarchicalLayout`'s automatic layout, no manual coordinates:** the level constraint keeps
  parents and the union node on one row "for free," but the `sortMethod = "directed"` heuristic
  placed the union node *adjacent to* one parent, not centered between the two — and the
  fan-out from the union node to 3 children is still 3 diagonal lines, not a horizontal bar. A
  partial visual improvement (one shared connection point instead of criss-crossing lines) but not
  the target convention, and midpoint placement is not guaranteed in general (would need the
  `moveNode()` post-processing step from §2.2 to fix, even for this simplest 1-couple case).
- **Case C2 — union node + a sibship-bar waypoint chain, all coordinates computed and fixed by
  hand, `visHierarchicalLayout()` not used at all (`visPhysics(enabled = FALSE)` +
  `visNodes(physics = FALSE)`, edges `smooth = FALSE`):** produces the **exact** target
  convention — a strict horizontal mate-line, a vertical drop, a strict horizontal sibship bar,
  and vertical drops to each child, all true right angles. This proves the convention **is**
  achievable inside visNetwork. It required 4 invisible helper nodes and 8 edges to represent
  what a "2 parents, 3 children" family would otherwise need only 6 edges for under today's
  model, and — critically — it required **abandoning `visHierarchicalLayout()` entirely** and
  computing every node's x/y by hand. There is no combination of documented vis.js options that
  gets this result while still delegating layout to the library.

**Conclusion: the technique is achievable, and the owner's "invisible nodes" hypothesis is
correct — but only jointly with abandoning vis.js's automatic hierarchical layout for a
hand-rolled, pedigree-specific positioning algorithm.** "Add invisible nodes" alone (Case B)
gets partial credit; the full convention (Case C2) additionally requires solving exact
coordinate placement, which this project has no existing capability for (`findGeneration()`
computes generation/level only, never horizontal ordering).

---

## 3. Decision options

### Option 1 — Reopen D2, switch the Diagram tab to kinship2 (or a similar static plotter)

kinship2's `align.pedigree` is a mature, purpose-built algorithm that already solves this exact
problem, including compact inbreeding-loop rendering — zero new layout-algorithm engineering.

**Cost:** loses the interactivity D2 was ratified specifically to gain — click-to-navigate,
in-widget pan/zoom, the PNG export button, hover tooltips, and search/highlight would all need a
render-to-static-image workaround (`shiny::plotOutput(click = ..., hover = ...)` +
`nearPoints()`), the exact category of workaround D2's own rationale rejected for every
purpose-built alternative it declined. kinship2 is GPL, the reason every other purpose-built
candidate was declined at D2 time. None of D2's original decline reasons have changed since
ratification — reopening it now would be re-deciding the same question with no new information,
at the cost of regressing 4 already-shipped, working features.

A further, distinct cost the owner raised this session: kinship2's node "metadata" is limited to
what its plotting call accepts as fixed arguments at draw time (id, sex, affected-status matrix,
relationship codes) — there is no mechanism to **dynamically** expose additional per-individual
metadata after the fact (e.g., a hover panel or hyperlink showing arbitrary current-app-state
fields), because a base-R plot has no live DOM/event layer to attach one to. `R/modPedigree.R`'s
current `title` field (`R/makePedigreeDiagramData.R:52-56`, issue #135) is exactly this kind of
dynamic exposure — it is generated per-render from live data (ID, sex, generation, sire, dam) and
rendered as real interactive HTML, a pattern kinship2 has no analog for. Any future feature
wanting to expose more per-node fields (e.g. a future "affected"/phenotype/genotype status, issue
#133) inherits the same gap under kinship2 that #135 already had to solve for visNetwork. This
compounds the interactivity cost above rather than standing apart from it — it is a second,
independent reason to expect a static-plotter switch to keep costing new workarounds every time a
future feature wants to show more, not less.

**Not recommended.**

### Option 2 — Full kinship2-parity layout, built on top of visNetwork

Write a new, dedicated pedigree-layout algorithm (informed by CraneFoot's duplicate-transformation
and kinship2's `align.pedigree`, both sourced above) that computes explicit x/y coordinates for
every real node plus invisible union/sibship-bar waypoint nodes, disables
`visHierarchicalLayout()` in favor of fixed positions (as proven in Case C2), and feeds the result
to the existing rendering pipe chain.

**What this must additionally solve, none of which this codebase has today:**
- **Crossing minimization at colony scale.** Real fixtures already reach 375 individuals in a
  single search dropdown (S454); a hand-rolled x-ordering must avoid the aesthetic degradation
  CraneFoot/Walker-II/Buchheim's published work exists specifically to solve (§2.1) — this is a
  nontrivial algorithm, not a formula.
- **Multi-mate / half-sib fan-out.** An individual with more than one mate needs more than one
  union node, each with its own sibship bar — unsolved even in the independent production example
  found this session (§2.2).
- **Inbreeding-loop safety.** Issue #134 hand-verified the *current* auto-layout renders a real
  consanguineous mating correctly; a hand-rolled positioning algorithm must independently
  reestablish this, not merely inherit it.
- **Partial-parentage founders.** Single-known-parent children and 0-parent founders need a
  defined no-union-node fallback.

**Scope:** comparable to the original issue #129 implementation itself (2 slices,
S433/S434) or larger, not to the smaller #131/#132/#135 UI-polish additions. This session found no
existing algorithm in the codebase or an off-the-shelf library to lean on for the crossing
-minimization piece specifically — it would need its own Pre-RED research pass.

**Recommended only if the owner wants full kinship2 parity and is willing to fund it as its own
multi-slice feature**, with a dedicated planning session before implementation (this document is
not that plan — it would need its own D-series decisions: how crossing-minimization is computed,
how multi-mate fan-out is represented, how loop-safety is re-verified).

### Option 3 — Partial, lower-risk step: a `visNetworkProxy`-repositioned mate-line only

Keep `visHierarchicalLayout()` exactly as-is (preserving today's scale and loop-correctness
behavior unchanged). Add one invisible union node per distinct mating pair at the same `level` as
its two parents (as in Case B). After the widget stabilizes, use `visNetworkProxy` +
`visGetPositions()`/`visMoveNode()` (both genuinely available here, §2.2) to reposition each union
node to the horizontal midpoint of its two parents' settled positions, and route the two
parent→union edges with `smooth = FALSE` so they render as a true straight line rather than a
curve (a real right angle is guaranteed only when the three points end up exactly colinear, which
`moveNode()` can enforce for the parent-to-union segment specifically).

**What this does NOT achieve:** the horizontal sibship bar. Forcing every child under a shared bar
row would require moving each child's x-position too — but a child is frequently *also a parent*
in the next generation, so satisfying one sibship's bar alignment can conflict with a different
mating-pair or sibship-bar constraint elsewhere in a densely-interconnected colony pedigree. That
is exactly the crossing-minimization problem Option 2 has to solve in full; Option 3 deliberately
does not attempt it. Children would still fan out from the union node as ordinary (curved)
vis.js edges, as in Case B/C — an incremental clarity improvement (viewers can now see which two
parents are a pair), not full parity with the owner's cited convention.

**Cost:** small and additive — a new `observeEvent`/proxy block in `R/modPedigree.R` plus new
union-node construction in `makePedigreeDiagramData()` (or a sibling function). No change to
`visHierarchicalLayout()`, no new crossing-minimization algorithm, no independent re-verification
of loop-safety needed (the real parent/child edges and their levels are untouched — only new,
additive union nodes/edges are introduced). Comparable in size to the already-shipped
#131/#132/#135 additions.

**Recommended as the right-sized first step**, if the owner wants a concrete, low-risk
improvement now rather than committing to Option 2's larger scope.

### Option 4 — Decline

Leave the Diagram tab as-is. The BACKLOG item's own framing was about visual *clarity*, not
correctness — the diagram is not wrong today, only less immediately legible about mating pairs
than kinship2's convention.

---

## 4. Impact analysis

| Surface | Option 1 (reopen D2) | Option 2 (full parity) | Option 3 (partial, proxy-based) | Option 4 (decline) |
|---|---|---|---|---|
| Click-to-navigate (#129 S2) | Needs reimplementing (static plot) | Unaffected (interaction layer untouched) | Unaffected | Unaffected |
| PNG export (#131) | Needs reimplementing | Unaffected | Unaffected | Unaffected |
| Legend (#132) | Needs reimplementing | Unaffected | Unaffected | Unaffected |
| Hover/search (#135) | Needs reimplementing | Unaffected | Unaffected | Unaffected |
| Loop rendering (#134) | N/A (new engine) | Must be re-verified | Unaffected (real edges/levels untouched) | Unaffected |
| 1,500-node cap (#138) | N/A | Must be re-verified/likely tightened | Unaffected | Unaffected |
| New dependency | kinship2 (GPL) | None | None | None |
| Engineering scope | Large (also a UI rewrite) | Large (new algorithm) | Small-medium | None |
| Resolves owner's concern | Fully (different tool) | Fully | Partially (mate-line only, no sibship bar) | Not at all |

---

## 5. Verification plan (for whichever option is ratified)

- **Option 2/3 (any code path):** unit tests on `makePedigreeDiagramData()`'s new union-node
  output (node/edge counts, id/level correctness) mirroring the existing test file's pattern;
  live `shinytest2`/`chromote` verification against the real app (matching the standard this
  project already applies, e.g. issue #134/#135) — not just that it renders without error, but
  that the mate-line genuinely appears where expected for a known fixture.
  Issue #134's consanguineous-mating fixture (`inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv`,
  `GA204Z`/`8LKBV9`) should be re-run through whichever new code path is chosen, to confirm no
  loop-rendering regression.
- **Option 2 specifically:** an additional crossing-count or visual-inspection check at colony
  scale (the existing 375-ID fixture, and ideally a synthetic multi-mate/half-sib fixture) before
  the 1,500-node cap (#138) is revisited.
- **Option 1:** would need its own interactivity re-verification plan from scratch (out of scope
  for this document, since Option 1 is not recommended).

---

## 6. A note on this session's reference material

The owner supplied two journal papers as research input during this session (Mäkinen et al. 2005;
Fuchsberger et al. 2008, both cited in §2.1). Both are copyrighted works (Nature Publishing Group;
Oxford University Press) that appeared, untracked, under `inst/extdata/reference/` — this
session's Phase 0 investigated them (confirmed genuinely on-topic, not incidental) before use, per
this project's "check before acting on unfamiliar files" convention. They were used as research
input and cited bibliographically above; **they were deliberately not committed to the
repository** (unlike `inst/extdata/reference/Master_Genetic_metrics_2_14_15.pdf`, which this
package already ships as end-user reference material) — the two new PDFs are third-party
copyrighted journal articles with no established need to ship inside the package itself. They
remain on disk, untracked, for the owner's own reference; flagged here rather than silently
deleted or silently committed, so the owner can direct their disposition.

---

## 7. Owner ratification record

- [ ] Option 1 — reopen D2, switch to kinship2/static plotting
- [x] **Option 2 — full kinship2-parity layout on visNetwork (own planning session first)**
- [ ] Option 3 — partial `visNetworkProxy` mate-line only
- [ ] Option 4 — decline

Ratified via `AskUserQuestion`, S457 (2026-08-02). **Next step:** a dedicated follow-up planning
session to design the crossing-minimization algorithm, multi-mate/half-sib fan-out
representation, and loop-safety re-verification approach for Option 2 (its own D-series
decisions, not resolved by this document) — filed as a `BACKLOG.md` item at this session's
close-out.
