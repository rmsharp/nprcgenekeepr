# Pedigree Diagram (issue #129) vs. kinship2 Feature Comparison

**Date:** 2026-07-30 · **Session:** S435 · **Type:** capability-comparison audit (not a
code-defect audit — no severity ratings; findings carry a **gap direction** instead)

**Compared:**
- **nprcgenekeepr's shipped feature** — the Pedigree Browser's new "Diagram" tab
  (`R/makePedigreeDiagramData.R` + `R/modPedigree.R`), a `visNetwork`-based interactive
  pedigree visualization delivered as issue #129 Slice 1 (S433, core render) and Slice 2
  (S434, click-to-navigate). Issue #129 is closed.
- **kinship2** v1.9.6.2 (CRAN, published 2025-09-04) — a long-established, static,
  genetics-specialized pedigree-plotting package. This project's own issue #129 planning
  session (S432) evaluated kinship2 and explicitly declined it in favor of `visNetwork`
  (design decision D2, `docs/planning/issue129-pedigree-diagram-tree-visualization-plan.md:364-381`),
  trading kinship2's specialized pedigree semantics for native Shiny interactivity.

**Question asked (owner-directed, not from `BACKLOG.md`'s sequencing chain):** now that
the pedigree-diagram feature has shipped, how does its actual feature set compare to
kinship2's pedigree-drawing capabilities? What did nprcgenekeepr's `visNetwork` choice
cost, and what did it buy?

---

## Method

Ran a 3-agent research-then-synthesize workflow: one agent surveyed the shipped
implementation firsthand (`R/makePedigreeDiagramData.R`, `R/modPedigree.R`,
`tests/testthat/test_modPedigree.R`, `NEWS.md`, `DESCRIPTION`, `NAMESPACE`, and the
ratified issue #129 plan document), a second agent researched kinship2's actual
pedigree-drawing feature set from its CRAN reference manual, its three vignettes, its
GitHub-mirrored source (`plot.pedigree.R`), and its `NAMESPACE` — cross-checking against,
but not relying solely on, this project's own prior kinship2 research in the issue #129
plan (which was written to justify a technology choice, not to fully inventory kinship2).
A third agent synthesized both independently-produced inventories, itemized on the same
17-point checklist, into the comparison below.

**Verification performed in-session (not delegated to the workflow):** every
nprcgenekeepr-side file:line citation below was independently re-read and confirmed
against the live source (`R/makePedigreeDiagramData.R`, `R/modPedigree.R:360-413`).
Three of the report's more consequential kinship2 claims were independently re-verified
via direct `WebFetch` against live CRAN/GitHub sources rather than trusted from the
workflow's citations alone: (1) the claim that no `plot.pedigreeList` S3 method exists in
the current package — confirmed directly from kinship2's live `NAMESPACE`
(`S3method(plot, pedigree)` and `S3method(plot, pedigree.shrink)` are the only two `plot`
methods registered); (2) the `pedigree()` `sex` argument's four codes
(1=male/2=female/3=unknown/4=terminated) — confirmed verbatim against the CRAN reference
manual PDF, p.21-22; (3) the sex-to-shape `polylist` (square/circle/diamond/triangle) and
the deceased-status diagonal-slash and duplicate-instance dashed-arc (`arcconnect()`)
drawing code — confirmed verbatim against the live `plot.pedigree.R` source on GitHub.

**Coverage:** 17 of 17 checklist items examined for both packages, each independently
sourced. No item skipped or marked not-applicable on either side.

---

## Feature Comparison Table

| # | Feature | nprcgenekeepr (issue #129) | kinship2 | Gap / Note |
|---|---|---|---|---|
| 1 | Rendering engine / technology | Interactive JS widget: `visNetwork`/vis.js, hierarchical layout (`visHierarchicalLayout(direction="UD")`), declared `Imports` dependency (`R/modPedigree.R:383-402`, `DESCRIPTION:58`) | Static base-`graphics` output only (`polygon()`/`segments()`/`text()`/`lines()`); no grid/ggplot2/htmlwidget layer | **Equivalent-different-approach** — explicit ratified tradeoff (D2), not a gap |
| 2 | Node shapes / sex encoding | Shape only: `F`→dot, `M`→square, `H`→star, `U`→triangle, other/NA→diamond (`R/makePedigreeDiagramData.R:35-37`); no separate deceased/status overlay | Shape by sex code 1-4: square/circle/diamond/triangle, plus a diagonal-slash overlay on top of the shape for deceased `status` | **kinship2-only** additional axis (deceased-status overlay); core shape-per-sex concept present in both |
| 3 | Affected/phenotype/genotype status | Not present — no color/fill/shading channel exists in the node data at all (`R/makePedigreeDiagramData.R:27,39-53`) | Up to 4 simultaneous affected traits per node, rendered as shaded pie-slice sections with configurable `density`/`angle` | **kinship2-only** |
| 4 | Handling of unknown/missing parents | `NA` sire/dam simply yields no edge; separate "Display Unknown IDs" checkbox can filter auto-generated unknown-parent placeholder rows before they reach the diagram (`R/makePedigreeDiagramData.R:47-51`, `R/modPedigree.R:102-114,325-329`) | `NA`/`missid`-coded parents yield no edge; founders get `kindepth()` depth 0; `fixParents()` utility can add back a missing second parent | **Equivalent-different-approach** — both simply omit the edge; kinship2 additionally offers a repair utility nprcgenekeepr doesn't need (its data pipeline already produces placeholder IDs upstream) |
| 5 | Multiple generations / hierarchical layout | Node `level` = pedigree's `gen` column; vis.js hierarchical layout renders founders at top (`R/makePedigreeDiagramData.R:43`, `R/modPedigree.R:393-395`); fully automatic, no manual override | `kindepth()` computes generation depth; `align.pedigree()` runs a 4-stage algorithm with a tunable quadratic centering penalty and an optional `hints` list for manual sibling/spouse ordering | **kinship2-only** refinement (manual-hint tunability); both packages achieve correct generation rows |
| 6 | Inbreeding loops / individual appearing twice | Not specifically handled; one node per `id`, no duplicate-node/loop convention; flagged as an **unverified risk** by the plan itself (Dragon P2), no loop-fixture test exists | Purpose-built: duplicates the plotted symbol at each needed position and connects instances with a dashed quadratic arc (`arcconnect()`); `align.pedigree`'s `spouse` matrix flags inbred-spouse pairs | **kinship2-only** — this is *both* a known, plan-ratified tradeoff (D2) *and* a genuinely unverified open risk (Dragon P2 was never resolved) |
| 7 | Twins | Not addressed anywhere in the data model, code, plan, tests, or NEWS.md | `relation` argument with MZ/DZ/unknown-zygosity codes; diverging-line-from-a-point rendering, with a connector line for MZ and a "?" for unknown zygosity | **kinship2-only** |
| 8 | Multiple mates/spouses | No union/couple node concept; multiple mates fall out naturally as multiple outgoing sire/dam edges (`R/makePedigreeDiagramData.R:47-53`) | Spouse pairs with children inferred automatically; childless/remarriage unions must be explicitly declared via `relation` code 4 or are silently dropped from the plot; `hints$spouse` allows manual left/right reordering | **Equivalent-different-approach** — nprcgenekeepr's model has no "childless union" concept to lose in the first place, since it only draws edges backed by actual child records |
| 9 | ID labels on nodes | Only `ped$id`, used as both node id and label; no name field exists in the pedigree data model (`R/makePedigreeDiagramData.R:41`) | `id` argument defaults to `x$id` but is freely substitutable; vignette demonstrates embedding name + ID via `\n`-joined text | **kinship2-only**, gated by nprcgenekeepr's data model lacking a name column |
| 10 | Legend / key | Not present anywhere in the UI or code; shape-to-sex mapping documented only in code comments/NEWS.md prose (`NEWS.md:58-59`) | Two dedicated functions: `pedigree.legend()` (corner-placed affected-status key) and `legendPlot()` (combined plot+legend wrapper) | **kinship2-only** |
| 11 | Interactivity (pan/zoom, click, hover, search) | Pan/zoom free from vis.js; click-to-navigate implemented and tested (Slice 2, `R/modPedigree.R:398-413`, `tests/testthat/test_modPedigree.R:1114-1193`); no hover tooltips, no search/highlight wired | None of any kind — architectural, not a documentation gap: no JS/event-binding layer exists in `Imports`/`NAMESPACE` at all | **nprcgenekeepr-only** |
| 12 | Subsetting/trimming controls | Reuses one shared `pedigreeData()` reactive: focal-animal entry + strict-lineal ancestors∪descendants trim + unknown-ID filter; diagram clicks re-drive the same trim (D3, `R/modPedigree.R:64-127,333-346,404-413`) | `subregion` (plot-coordinate crop) plus availability/informativeness-driven `pedigree.trim()`/`findUnavailable()`/`pedigree.shrink()`; no lineal ancestors-only/descendants-only filter exists | **Equivalent-different-approach** — different subsetting *purposes* (lineage-direction vs. computational-tractability), neither strictly a superset of the other |
| 13 | Scale / performance limits | Hard cap: 1,500 nodes, informative warning message above the cap (`R/modPedigree.R:366-390`, tested at `tests/testthat/test_modPedigree.R:1047-1079`) | No numeric cap, but multi-page splitting is explicitly "not yet completely understood, and certainly not implemented"; mitigations only (`subregion`, small `cex`/`symbolsize`, `pedigree.shrink()`) | **Both-lack** a true large-scale/full-colony solution |
| 14 | Export / print / save-as-image | CSV export of tabular `pedigreeData()` only (`R/modPedigree.R:129-133,425-432`); no image export of the diagram itself | No dedicated export function either, but base-graphics output means any `pdf()`/`png()`/`svg()` device wrap gets an image "for free" | **kinship2-only**, via general R mechanics rather than a kinship2-specific feature |
| 15 | Customization exposed to end user | None for diagram appearance — shape map, layout direction, node cap all hardcoded (`R/makePedigreeDiagramData.R:35`, `R/modPedigree.R:366,393-395`) | Extensive script-level arguments: `cex`, `col`, `symbolsize`, `branch`, `packed`, `align`, `width`, `density`, `angle`, `subregion`, `pconnect` | **kinship2-only among script/R users** — but kinship2 has no GUI either, so this isn't "end-user" customization in the Shiny sense for either package |
| 16 | Integration: standalone vs. Shiny-only | Split: `makePedigreeDiagramData()` is a standalone exported pure function (data transform only); full interactive rendering + click-nav is Shiny-module-only (`R/makePedigreeDiagramData.R:4-56,18-23`, `R/modPedigree.R:368-413`) | Fully standalone: ordinary base-R S3 `plot()` method, zero special setup, usable in any script; mechanically compatible with `shiny::renderPlot()` but with no built-in reactive/click hooks | **Equivalent-different-approach** — nprcgenekeepr trades a fully standalone render for Shiny-native interactivity; kinship2 trades interactivity for full standalone portability |
| 17 | Explicitly deferred/declined vs. documented non-support | Plan explicitly declined: new/separate module (D1), purpose-built genetics plotters (D2), collateral-inclusive semantics (D3), a pre-implementation prototype spike, `visNetworkProxy()` in-place updates, a UI legend, unbounded full-colony rendering, and loop-verification | Documented non-support: no native interactivity of any kind (§11), no `plot.pedigreeList` S3 method in the current package (contra the plan's own survey note — verified live), no `doubleFirstCousinPedigree()`, no arrowhead rendering, no multi-page splitting, no dedicated export API | **Meta-row** — distinguishes "already a known, ratified tradeoff" from "genuinely open/unverified" per package |

---

## Findings

### Finding #1: Inbreeding-loop / consanguinity rendering is unverified, not just unimplemented
- **Gap direction:** kinship2-only
- **Description:** kinship2 has a documented, purpose-built mechanism for an individual appearing more than once in a pedigree due to consanguineous mating: it duplicates the plotted symbol at each position needed and connects the instances with a dashed quadratic arc (`arcconnect()`), with `align.pedigree()`'s layout engine explicitly flagging inbred-spouse pairs. nprcgenekeepr's diagram renders exactly one node per `id` with no analogous mechanism, and — critically — this is not simply "not built yet": the ratified plan itself flagged (Dragon P2) that vis.js's hierarchical layout was *claimed* to handle DAGs gracefully but that "no worked example of this specific case was run this session," and required Slice 1 verification that was never actually completed (no loop-fixture test exists in `test_modPedigree.R`).
- **Evidence:** kinship2 — `align.pedigree` Value doc, "2 = subject plotted to the immediate right is an inbred spouse"; `plot.pedigree` Value doc, "If they appear multiple times one of the instances is chosen"; `arcconnect()` dashed-arc source (verified live). nprcgenekeepr — one node per id (`R/makePedigreeDiagramData.R:39-45`); Dragon P2 (plan lines 581-589); only tree/DAG fixtures used in Diagram tests (`tests/testthat/test_modPedigree.R:1021-1027, 1087-1093`).
- **Impact:** NPRC colonies (e.g., rhesus macaque breeding programs) routinely include consanguineous matings — this is precisely the scenario the package's own mean-kinship/genome-uniqueness analysis exists to manage. A colony manager viewing the Diagram tab for such a pedigree today gets an unverified rendering, with no visual signal a loop even exists if the layout does degrade unexpectedly.
- **Recommendation:** File a GitHub issue to construct a known-loop pedigree fixture and run it through the shipped Diagram tab, resolving the plan's own open Dragon P2 item. If the resulting rendering proves adequate, close as "verified, no change needed"; if misleading, scope a small follow-up. This is closing an already-identified verification gap, not proposing new scope.

### Finding #2: No visual indication of affected/phenotype/genotype status
- **Gap direction:** kinship2-only (and gated by nprcgenekeepr's own data model, which has no affected-status field to encode)
- **Description:** kinship2 lets a caller pass up to 4 simultaneous affected-trait indicators per subject, each rendered as a shaded section of the node symbol with matching `pedigree.legend()` support. nprcgenekeepr's `makePedigreeDiagramData()` reads only `id`, `sire`, `dam`, `sex`, `gen` and has no color/fill/shading channel of any kind.
- **Evidence:** kinship2 — `affected` argument, up to 4-column matrix, shaded sections; `density`/`angle` shading params. nprcgenekeepr — `makePedigreeDiagramData()` input/output columns (`R/makePedigreeDiagramData.R:27,39-53`); no affected/phenotype field in the pedigree column model.
- **Impact:** A geneticist doing disease-risk or genetic-value work cannot see which animals in a displayed pedigree are affected by a condition of interest directly on the diagram — they'd need a separate table lookup. This is a two-layer gap: the data model has no affected field to begin with, so the rendering gap is downstream of a data-model gap.
- **Recommendation:** No action in the immediate term — out of scope for issue #129 as ratified. If phenotype-aware pedigrees become a real need, file it as a new feature proposal that starts at the data-model layer before extending the diagram's node encoding to consume it.

### Finding #3: No diagram image/print export
- **Gap direction:** kinship2-only, via general R graphics-device mechanics rather than a kinship2-specific export function
- **Description:** The Pedigree Browser's only export is a CSV download of the tabular `pedigreeData()` — there is no way to save, print, or screenshot the rendered network diagram itself. kinship2 has no dedicated export function either, but because `plot.pedigree()` draws onto "the current plotting device" using ordinary base-graphics calls, any caller gets image export for free simply by wrapping the call in `pdf()`/`png()`/`svg()` + `dev.off()`.
- **Evidence:** nprcgenekeepr — only export is `downloadButton(ns("exportPedigree"), "Export Pedigree (CSV)", ...)` writing `pedigreeData()` via `write.csv()` (`R/modPedigree.R:129-133,425-432`); no `visSave()`/`visExport()` call anywhere in `modPedigree.R`.
- **Impact:** A colony manager who wants a pedigree chart image for a husbandry report, IACUC document, or presentation currently cannot get one out of the Diagram tab at all.
- **Recommendation:** File a GitHub issue for a follow-on slice adding a diagram-image export (e.g., `visNetwork`'s PNG export hook, or a headless render-to-PNG helper) as a second download button alongside the existing CSV export. Scope as its own small slice — not a blocker to the shipped Slices 1-2.

### Finding #4: Click-to-navigate and pan/zoom interactivity
- **Gap direction:** nprcgenekeepr-only
- **Description:** The shipped feature lets a user click any node to re-focus the entire Pedigree Browser (table + diagram) on that individual, re-driving the same strict-lineal trim, and gets pan/zoom "for free" from the underlying vis.js widget. kinship2, as static base-graphics output, has no click events, no pan/zoom beyond re-plotting with different `xlim`/`ylim`/`subregion`, and no event-binding mechanism of any kind — this is architectural, not a documentation gap.
- **Evidence:** nprcgenekeepr — `visEvents(click = ...)` (`R/modPedigree.R:398-401`), `observeEvent(input$pedigreeDiagram_click, ...)` (`R/modPedigree.R:409-413`), background-click guard (`R/modPedigree.R:411`), tests at `tests/testthat/test_modPedigree.R:1114-1155,1157-1193`. kinship2 — `Imports: graphics, stats, methods, knitr` only; no event-binding anywhere in `NAMESPACE` (verified live).
- **Impact:** This is the core differentiator and the value proposition of choosing visNetwork over kinship2 for this module — a colony manager can now explore a pedigree by clicking through relatives interactively instead of re-running a form/script for every new focal animal, something kinship2's architecture cannot offer under any configuration.
- **Recommendation:** No action needed on the core capability — already shipped and working as the plan intended. As a genuinely incremental follow-on (not a correction), consider a future issue for hover tooltips and `visOptions(highlightNearest=...)` search/highlight — both natively available from the same `visNetwork` dependency already in use, at low marginal cost. `visNetwork` also exposes an optional `visOptions(manipulation = TRUE)` interactive graph-editing mode (add/remove/edit nodes) that is not enabled anywhere in the current implementation — not recommended for a read-only pedigree-browsing tool, noted here only because it is "free" capability already present in the loaded dependency, should an editing use case ever arise.

### Finding #5: No twin/zygosity encoding
- **Gap direction:** kinship2-only
- **Description:** kinship2 has a dedicated `relation` argument with numeric codes for monozygotic/dizygotic/unknown-zygosity twins, rendered as diverging lines from a shared point (with a connecting line for MZ, a question mark for unknown zygosity). nprcgenekeepr's diagram has no twin concept anywhere in its data model, code, plan, tests, or NEWS — twins would render as ordinary same-generation siblings with no marker.
- **Evidence:** kinship2 — `relation` codes 1-3 for twin zygosity (verified live, `pedigree` Arguments p.22); diverging-line/question-mark rendering per vignette and source. nprcgenekeepr — no twin-relationship column in the `id/sire/dam/sex/gen` model consumed by `makePedigreeDiagramData()`.
- **Impact:** Low-to-moderate for this project's typical subject species — macaques rarely produce twins, unlike the human-pedigree use case kinship2 was primarily built for — but any twin births in a colony would be visually indistinguishable from non-twin siblings.
- **Recommendation:** No action — out of scope for issue #129, and the underlying pedigree data model has no twin/zygosity field to encode regardless of rendering choice. Revisit only if a future data-model change adds twin-relationship tracking.

### Finding #6: No legend/key in the app UI
- **Gap direction:** kinship2-only
- **Description:** kinship2 ships two dedicated legend functions — `pedigree.legend()` (corner-placed shading key) and `legendPlot()` (combined plot+legend wrapper). nprcgenekeepr's Diagram tab has no legend UI element anywhere; the shape-to-sex mapping is documented only in code comments and NEWS.md prose, never surfaced inside the running app.
- **Evidence:** kinship2 — `pedigree.legend()`/`legendPlot()` signatures. nprcgenekeepr — no `visLegend()` call or legend UI in `R/modPedigree.R:145-155,368-402` or `makePedigreeDiagramData.R`; mapping only in NEWS.md prose (`NEWS.md:58-59`).
- **Impact:** A first-time user of the Diagram tab has no in-app way to learn that a star means hermaphrodite or a triangle means unknown sex — they must consult external documentation. This is a genuine usability gap, independent of the visNetwork-vs-kinship2 architecture choice, and inexpensive to close.
- **Recommendation:** File a GitHub issue for a small follow-on slice: add a static shape-key panel next to the Diagram tab listing the sex-to-shape mapping. Low effort; also addresses the plan's own Dragon P5 note that the H/U shape choices (triangle/star) were never validated against real data — a visible legend makes any future remap easier to communicate to users.

### Finding #7: No solution for very large ("full-colony") pedigrees
- **Gap direction:** both-lack
- **Description:** Neither package fully solves rendering an arbitrarily large pedigree. nprcgenekeepr caps the Diagram tab at 1,500 nodes and shows an informative message above that, requiring the user to narrow their focal-animal selection. kinship2 has no numeric cap but candidly documents that multi-page splitting is "not yet completely understood, and certainly not implemented," leaving only partial mitigations (`subregion` cropping, shrinking symbol/text size, or algorithmically cutting the pedigree via `pedigree.shrink()`).
- **Evidence:** nprcgenekeepr — `pedigreeDiagramMaxNodes <- 1500L` (`R/modPedigree.R:366`), warning message (`R/modPedigree.R:368-385`), test at `tests/testthat/test_modPedigree.R:1047-1079`. kinship2 — "not yet completely understood, and certainly not implemented" (plot_code_details vignette); `pedigree.shrink()`; `subregion` crop.
- **Impact:** A colony manager wanting to see an entire large colony's pedigree at once (thousands of animals) cannot do so in either tool without narrowing scope first. This is a shared, structural limitation of pedigree-diagram visualization in general, not a defect unique to either package.
- **Recommendation:** No action — the ratified plan's Dragon P3 already frames the 1,500-node cap as a deliberate scope limit, not an oversight, and kinship2 offers no better off-the-shelf answer to point to instead. If full-colony visualization becomes a real user need later, it warrants its own dedicated design session (e.g., a colony-level summary/aggregate view rather than a full node-per-animal diagram), not simply raising the cap.

### Finding #8: Node labels limited to ID (no name/multi-line detail)
- **Gap direction:** kinship2-only, gated by nprcgenekeepr's data model
- **Description:** kinship2's `id` argument is positionally substitutable, letting a caller pass any string per node — the vignette demonstrates embedding a name alongside the ID via `\n`-joined text. nprcgenekeepr's diagram always shows exactly `ped$id` as both node id and label, because the pedigree data model it consumes has no "name" column at all.
- **Evidence:** kinship2 — `id` argument "used for labeling," substitutable; multi-line name example in vignette. nprcgenekeepr — `label = ped$id` (`R/makePedigreeDiagramData.R:41`); no name field in the pedigree data model.
- **Impact:** Minor for a studbook-ID-driven colony-management workflow, where IDs already are the primary key colony managers work from — but would matter if a future workflow wants human-readable names shown directly on the diagram.
- **Recommendation:** No action — gated by the pedigree data model lacking a name field, not by a diagram-rendering limitation. Revisit only if/when a name column is added to the underlying pedigree data structure.

---

## Structural Observations

1. **Interactive vs. static is the core tradeoff driving nearly every other difference.** nprcgenekeepr's wins (click-to-navigate, free pan/zoom — Finding #4) and kinship2's wins (affected-status shading, twin brackets, loop-safe duplicate-node alignment, dedicated legend functions — Findings #2, #5, #6, and #1) both trace back to the same ratified D2 decision to prioritize Shiny-native interactivity over a genetics-specialized static renderer.
2. **kinship2's genetics-domain conventions have no equivalent in the shipped feature because visNetwork is a generic graph-drawing library, not a pedigree-specific one.** Affected-status shading, twin zygosity brackets, and inbred-spouse flagging don't come "for free" the way pan/zoom did from vis.js — every one of them would need to be hand-built on top of visNetwork's generic node/edge model if ever wanted.
3. **The most consequential single item on the checklist is where these two patterns collide.** The shipped feature's biggest unresolved risk — inbreeding-loop rendering (Finding #1) — is exactly the one case kinship2 was purpose-built to handle correctly, and it is the one item the ratified plan itself flagged as unverified rather than deliberately declined (visNetwork wasn't even installed at planning time to check). Every other kinship2-only capability in this comparison is either a genuinely out-of-scope tradeoff or gated by a missing data-model field; this one is neither — it is open.
4. **kinship2's value to this project is not limited to plotting, and this audit intentionally didn't compare that part.** kinship2 also computes kinship/inbreeding coefficients — a computational capability, not a drawing one, and nprcgenekeepr already has its own independent implementation of that (`R/kinship.R`, which cites kinship2/CRAN as prior art in its own roxygen `@references`, `R/kinship.R:42-43`). This audit's scope was pedigree *drawing* only, per the question asked; the two packages' kinship-computation capabilities were not compared here and would be a separate audit if ever needed.

---

## Recommendations

1. **File a GitHub issue: verify inbreeding-loop rendering behavior (Finding #1).** Construct a known-loop pedigree fixture, run it through the shipped Diagram tab, and document actual vis.js behavior — resolving the plan's own unresolved Dragon P2. Highest priority given this directly touches the package's core genetic-management purpose.
2. **File a GitHub issue: add diagram image export (Finding #3).** A PNG/image download button alongside the existing CSV `downloadButton`, using `visNetwork`'s own export capability. Addresses a common, concrete colony-management reporting need.
3. **File a GitHub issue: add an in-app shape-to-sex legend (Finding #6).** Small, low-effort UI addition; also resolves the plan's own Dragon P5 note about unvalidated H/U shape choices.
4. **No action: affected/phenotype/genotype status encoding (Finding #2).** Blocked on a data-model change (no affected field exists in the pedigree structure today), not a rendering choice — revisit only if that data need arises.
5. **No action: twin/zygosity encoding (Finding #5).** Same reasoning — data-model gated, and low practical relevance to this project's primate colonies.
6. **No action: full-colony rendering at arbitrary scale (Finding #7).** Already a deliberate, plan-ratified scope limit (Dragon P3); kinship2 offers no better off-the-shelf solution to adopt instead.
7. **No action: node label content beyond ID (Finding #8).** Data-model gated; revisit only if a name field is ever added to the pedigree structure.
8. **Optional, low-priority follow-on: hover tooltips and search/highlight.** Not a kinship2-comparison gap (kinship2 has neither either), but a low-cost enhancement to the existing visNetwork widget's own unused capabilities (item 11), worth a future issue if UI polish time becomes available.

Recommendations 1-3 and 8 are candidates for new `BACKLOG.md`/GitHub-issue items; none imply reopening issue #129 or revisiting the visNetwork-vs-kinship2 technology decision (D2), which stands as ratified.
