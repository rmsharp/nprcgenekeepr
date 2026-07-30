# Issue #129 Plan — Pedigree-diagram/tree visualization (currently table-only)

**Tracks:** GitHub issue **[#129](https://github.com/rmsharp/nprcgenekeepr/issues/129)**
(filed S422, 2026-07-29, from
`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md` Dimension 7).
Sibling of issues #126 (DONE, S429), #127 (DONE, S431), #130 — owner-ratified
sequencing (S428, reconfirmed S429/S431): #126 and #127 shipped first;
**#129 is next**; planning #130 follows #129.

**Authored:** Session 432 (2026-07-29), **planning session**, following
`ARCHITECTURE_WORKSTREAM.md` (chosen over `DESIGN_WORKSTREAM.md`: the load
-bearing decision here is a technology-fit / data-model / module-contract
call, not a layout/panel-arrangement call — matching S430's own reasoning
for #127, applied here to a case that leans architecture even more clearly
since a real rendering-library and dependency decision is in scope). TDD
phases (RED/GREEN/REFACTOR) are inapplicable to this document — it is a
plan, per this project's own S423/S426/S428/S430 precedent. The
implementation below is its own strict-TDD session(s) (RED -> GREEN ->
REFACTOR), one per slice.

**Evidence base:** a 4-agent parallel research `Workflow` this session
(pedigree data-flow/rendering-surface inventory; CRAN-verified
diagram-library technology survey; module-contract + Shiny wiring review;
prior-plan-convention + full issue/audit-text research), followed by
firsthand verification of every load-bearing claim before publication —
per `PROJECT_LEARNINGS.md` Learning 399's explicit, named instruction to
budget this as a standing step for #129's own planning session specifically
— a named risk in this audit-derived issue family given a 2-for-2 citation
-drift hit rate in #118/#126, a pattern #127's own check (Learning 401)
found clean, and this session's own check (below) also found clean. Confirmed directly (not trusted from agent output alone): `grep`
across every `mod*.R` file's `render*` calls shows `R/modPedigree.R:349`
(`DT::renderDT`) is the sole pedigree-table/diagram rendering surface in the
entire app; `R/modGeneticDiversity.R`'s heatmap is a kinship-matrix heat
map (a different population/capability), not a competing tree/diagram;
`R/appServer.R` has zero occurrences of `focalAnimals` (confirming that
reactive, already returned by `modPedigreeServer`, has no consumer today);
`docs/architecture/module-contract.md`'s six rules and
`tests/testthat/test_moduleContract.R`'s `modPedigree` entry read exactly
as characterized; `R/modPyramid.R:66-69`'s `tabsetPanel` Plot/Statistics
precedent is real; `DESCRIPTION:38` confirms `Depends: R (>= 4.1.0)`;
`R/createPedTree.R` (read in full) confirms its `PedTree` is a sire/dam
parent-pointer map for `findLoops()`, not a diagram-ready edge list;
`R/findGeneration.R` (read in full) confirms `gen = 0` for founders,
increasing away from founders — i.e. ancestors have LOWER generation
numbers than descendants, which orients naturally to a top-down (ancestors
above, descendants below) hierarchical diagram layout with no inversion
needed.

> **Scope.** This is the planning deliverable. **No `R/`, `tests/`, `man/`,
> `NAMESPACE`, or `data/` content is changed by writing it.** `visNetwork`
> is **not currently installed** in this development environment — this
> plan's mechanism design is built from the package's live-verified CRAN
> metadata (dependency list, license, Shiny-binding existence) and its
> documented API surface, **not from a hands-on prototype run in this
> session**. This is flagged explicitly, not glossed over — see Dragon P1.

> **RATIFIED this session (2026-07-29), via `AskUserQuestion`.** See §3 for
> the record. Decisions are documented directly below as ratified, not as
> open recommendations, since ratification happened before this document
> was written.

---

## 1. Context

### What issue #129 says (verbatim)

> **Source:** `docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md`, Dimension 7.
>
> The 2015 NHP Genetics and Genomics Working Group PDF names **Pedigree/Draw**
> (pedigree diagram visualization) as a tool colony managers might already use.
> `nprcgenekeepr` renders pedigrees only as a sortable data table
> (`DT::renderDT`) -- there is no graphical family-tree/diagram view, and no
> diagram-drawing dependency exists in `DESCRIPTION`.
>
> **Scope note:** a real, named capability gap relative to a comparable tool
> the source document explicitly cites -- not addressed in the audit's own
> numbered Recommendations list, so it had not yet been triaged into a
> tracked item before this session. Scope (static image export vs.
> interactive Shiny widget vs. an existing R graph/pedigree-plotting
> package) is an open design question for a future scoping session.
>
> _Triage decision authored by an AI agent during session 422 -- review
> before relying on this for human-facing work._

The full Dimension 7 audit section
(`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md:154-179`,
"7. Tooling Comparison & Additional Package Capabilities") is a
tool-by-tool comparison table; only the "Pedigree/Draw" row (Missing) is
issue #129's source. The issue has **zero comments** — the triage body
above is the entire discussion record (`gh api
repos/rmsharp/nprcgenekeepr/issues/129/comments` returns an empty array,
confirmed directly this session).

`BACKLOG.md:329-339`'s live sequencing note explicitly flags this issue
differently from its siblings: **"needs its own scoping/architecture-or
-design session first, not straight-to-implementation (READY, Effort
M/L)"** — a heavier signal than #127 (single small planning + single
implementation session) got. This planning session, and its multi-slice
result (§4), is that signal playing out as expected.

### What this session's research confirmed

- **The gap is real, not a stale citation.** Per Learning 399's standing
  instruction, confirmed `DT::renderDT` (`R/modPedigree.R:349`) is the sole
  pedigree rendering call site app-wide, and that
  `R/modGeneticDiversity.R`'s existing heatmap is a distinct capability
  (kinship-matrix heat map, not a family-tree diagram).
- **No existing diagram-ready data structure.** `createPedTree()`
  (`R/createPedTree.R:33-42`) builds a `PedTree` — a named list of
  `{sire, dam}` per id, used only by `findLoops()` for inbreeding-loop
  detection — not an edge list, and not consumed by any display code. A
  diagram-ready `{nodes, edges}` structure needs to be built fresh from
  the pedigree data frame; `createPedTree`'s sire/dam pairs and `ped$gen`
  (generation depth) are usable raw material, not a ready-made input.
- **Two divergent focal-scoping algorithms already exist** in the
  codebase, and they disagree: `modPedigree.R`'s own strict-lineal trim
  (`trimPedigree()` + `getDescendantPedigree()`, ancestors ∪ descendants
  only, explicitly commented "collateral relatives ... are not included",
  `R/modPedigree.R:335-337`) vs. the broader connected-component-with
  -collaterals semantics behind `getFocalAnimalPed()`/
  `getFocalAnimalPedFromFile()` (via `getPedDirectRelatives()`'s
  iterative-union-to-fixed-point algorithm, `R/getPedDirectRelatives.R:47
  -60`). §3 D3 ratifies which one the diagram uses.
- **Pedigree sizes matter for the design.** Full-colony pedigrees run
  2,000–6,000+ rows (`examplePedigree` = 3,694 rows;
  `vignettes/articles/colony-manager-guide.qmd:266` cites a live 2,322-row
  view; the kinship calculation's own documented cap is ~6,000
  individuals). The **focal-animal-trimmed** working set the UI already
  narrows to is commonly in the hundreds: 327 animals in one R-script
  -driven example, trimming further to 704 in the same walkthrough
  (`vignettes/a2interactive.html:1737` and `:1810` respectively), and
  separately 327 IDs uploaded via the Shiny UI trimming to a 962-animal
  "larger focal group" in a different example
  (`vignettes/articles/colony-manager-guide.qmd:282,284,290`). A diagram
  of the full,
  untrimmed colony pedigree is a large-N graph-layout problem this plan
  does not attempt to solve; the diagram scopes to the same
  focal-animal-trimmed population the table already shows (§3 D3), which
  is the size the app already treats as "the readable working set."
- **A rendering-technology dependency must be added — none exists today.**
  Confirmed via `grep -rniE
  "igraph|DiagrammeR|visNetwork|networkD3|ggraph|kinship2|pedtools|data\.tree|collapsibleTree"
  R/ DESCRIPTION tests/ NAMESPACE`: the only hit is a roxygen `@references`
  citation in `R/kinship.R:42-43` pointing at CRAN's `kinship2` page as
  the historical basis for this package's own from-scratch kinship
  implementation — not a dependency.
- **A real, evidenced architectural shortcut exists**: `R/modPyramid.R:66
  -69` already ships a `tabsetPanel(tabPanel("Plot", ...), tabPanel(
  "Statistics", ...))` — a plot-view/table-view toggle inside one module,
  fed by one shared reactive argument. `R/modGeneticValue.R:124-149` does
  the same with three tabs (Rankings/Visualizations/Summary). This is
  direct, already-shipped precedent for adding a diagram view to
  `modPedigree.R` itself rather than building a new module (§3 D1).

### Prior process history (relevant precedent, reused throughout)

- `docs/planning/issue127-surface-uncorrected-kinship-flag-plan.md`
  (S430) — single-slice plan structure (front matter, `## 1. Context`
  through `## 8. References`, ratified-decisions table, dragons table).
- `docs/planning/issue125-ranking-priority-multi-candidate-plan.md`
  (S423) — **multi-slice** plan structure: lettered evidence-inventory
  subsections (`2A`–`2F`), prose-bullet (not table) ratified-decisions
  section, a full repeated `Scope / RED / GREEN / DONE looks like / Verify
  / Session boundary / Dragons` block per slice, a `## Cross-slice notes`
  section, a flat-bulleted dragons list, and an owner-ratification
  checklist closing (no separate References section). **This plan follows
  the #125 structure**, since §3 D4 ratifies a multi-slice split.
- `PROJECT_LEARNINGS.md` Learning 399 (S428) — names #127/#129/#130 by
  number as the sessions that must budget a runtime-call-site verification
  pass on the issue's own cited evidence before treating it as the
  implementation target, given a 2-for-2 (now, with this session's
  confirmation that the citation held, arguably a "verified clean" case
  rather than a third drift instance) hit rate within this audit family.
- `PROJECT_LEARNINGS.md` Learning 401 (S430) — a hand-built synthetic
  pedigree that passes a narrow unit test can still fail inside
  `reportGV()`'s full pipeline (`calcFEFG()`/`calcFounderContributions()`
  have stricter contracts). Not directly load-bearing here (this feature
  doesn't call `reportGV()`), but the general discipline — verify a worked
  example against the real pipeline the feature actually touches, not a
  narrower stand-in — applies to Slice 1's worked example (§4).

---

## 2. Evidence-based inventory (firsthand, this session + the research workflow)

### 2A. Core pedigree data model & current rendering surface

The pedigree data frame's columns, confirmed via `man/examplePedigree.Rd`
and `inst/extdata/examples/ExamplePedigree.csv:1`: `id` (character),
`sire`/`dam` (character, `NA` if unknown), `sex` (factor, levels `F/M/H
/U`), `gen` (integer, 0 = founders — confirmed directly against
`R/findGeneration.R`'s algorithm), `birth`/`exit` (Date), `age` (numeric),
`ancestry`, `origin`, `status`, `recordStatus`, `fromCenter`.
`modPedigree.R`'s server bolts on two more downstream: `population`
(`setPopulation()`, `R/setPopulation.R:29-38`) and `pedNum`
(`findPedigreeNumber()`, `R/findPedigreeNumber.R:36-67`).

`R/modPedigree.R`'s current reactive chain, confirmed directly:
1. `focalIds` `reactiveVal`, populated from `input$focalAnimalIds`
   (textarea) / `input$focalAnimalFile` (CSV) inside
   `observeEvent(input$updateFocalAnimals, ...)` (lines 225-293).
2. `processedPedigree <- reactive(...)` (296-315): `studbook()` (the
   cleaned/QC'd data from `modInput`, arriving as
   `reactive(shared$currentStudbook)` per `R/appServer.R:299-302`) →
   `setPopulation()` → `findPedigreeNumber()` → `findGeneration()` if
   `gen` is absent.
3. `pedigreeData <- reactive(...)` (318-346): drops auto-generated
   "Unknown" IDs unless `input$displayUnknownIds`; if
   `input$trimPedigree` and focal IDs exist, computes `ancestors <-
   trimPedigree(probands, ped, removeUninformative = FALSE,
   addBackParents = FALSE)` and `descendants <-
   getDescendantPedigree(probands, ped)`, then keeps
   `ped[ped$id %in% union(ancestors$id, descendants$id), ]` — **strict
   lineal**, no collaterals (comment at lines 335-337 says so explicitly).
4. `output$pedigreeTable <- DT::renderDT({ pedigreeData() }, options =
   list(pageLength = 15, scrollX = TRUE, search = list(regex = TRUE)))`
   (349-356, verified directly — line 349 is exactly the render call).
   This is the **only** transformation of pedigree data into a display —
   the filtered data frame goes straight into `DT::renderDT`, with no
   intermediate graph/tree object anywhere in the current code.
5. Module returns 6 named reactives (378-398, verified against
   `tests/testthat/test_moduleContract.R:26-31`'s exact expected-names
   vector): `pedigree`, `processedPedigree`, `focalAnimals`, `nAnimals`,
   `populationCount`, `isReady`.

**`focalAnimals` has zero consumers today** — confirmed via `grep -n
focalAnimals R/appServer.R` returning no hits. A diagram consuming it
(§3 D1/D3) gives this already-returned, currently-dead reactive its first
real use — itself a small, positive side effect of this feature, not a
new liability (module-contract.md rule 4, "return only what a consumer
reads," is presently unsatisfied for this one reactive; this plan fixes
that as a byproduct rather than as its own goal).

### 2B. `createPedTree()` — not diagram-ready

`R/createPedTree.R` (read in full, 42 lines): builds a `PedTree`, a named
list keyed by `id`, each element `list(sire = <id-or-NA>, dam =
<id-or-NA>)`. Consumed only by `findLoops()` (inbreeding-loop detection
for pedigree sampling/kinship calc, per the file's own header comment) —
never by table/display code. It is a parent-pointer map, not an edge list
or `{nodes, edges}` structure; a diagram needs the latter, built fresh
(§4 Slice 1 mechanism).

### 2C. Two divergent focal-scoping algorithms

- **`modPedigree.R`'s own trim** (used today, §2A step 3): strict-lineal
  ancestors ∪ descendants only.
- **`getPedDirectRelatives()`** (`R/getPedDirectRelatives.R:29-76`):
  iteratively unions `getParents()` + `getOffspring()` closures to a fixed
  point (lines 47-60) — the true bidirectional connected component,
  including collaterals (siblings, mates). This is what backs
  `getFocalAnimalPed()` (`R/getFocalAnimalPed.R:32-61`, LabKey-sourced)
  and `getFocalAnimalPedFromFile()` (`R/getFocalAnimalPedFromFile.R:54
  -94`, offline; its own docstring at lines 29-31 says the result
  includes "ancestors, descendants, and collaterals").

These diverge for any individual with siblings or multiple mates. §3 D3
ratifies which one the diagram shows.

### 2D. Module contract & app wiring

`docs/architecture/module-contract.md` (81 lines, read in full) is a
ratified living-standards doc (origin: issue #122/XARCH-2) with six rules:
(1) data-bearing server args must be `reactive()`; (2) every returned
element must be `reactive()` (the one rule `test_moduleContract.R`
mechanically enforces); (3) returned vocabulary is stable/canonical
(`pedigree`, `gvReport`, `kinship`, `errors`, `isReady`); (4) return only
what a consumer reads; (5) upstream absence → `req()`, upstream
malformedness → a surfaced error, no blanket `tryCatch`-swallow at module
seams; (6) every declared parameter is read, every returned element is
documented. `R/modInput.R` is the named reference implementation.
`modPedigree.R` is independently confirmed fully compliant on all six
rules (review-time rules checked directly; rule 2 checked via the passing
guard test).

`test_moduleContract.R`'s `moduleContractServers` list (18-77) is
**hand-maintained, not auto-discovered** — a new module needs its own
entry added or the guard test doesn't cover it at all.

App wiring (`R/appServer.R`, `R/appUI.R`, both read directly): a single
`shared <- reactiveValues(...)` bag (`appServer.R:47-54`) holds
cross-module state; modules receive `reactive(shared$xxx)` wrapper
closures, never the bare `reactiveValues` object (module-contract rule 1),
with one documented exception unrelated to this feature. UI is a single
`shiny::navbarPage(...)` (`appUI.R:58-284`) with one `tabPanel(<label>,
icon = icon(...), mod*UI(<id>))` per module —
`modPedigree`: `appUI.R:171-175`. Server wiring: `modPedigreeServer(
"pedigree", studbook = reactive(shared$currentStudbook))`
(`appServer.R:299-302`), then `shared$currentPedigree <-
pedigreeResults$pedigree()` inside an `observe()` (305-308), which is what
`modPyramidServer`/`modGeneticValueServer` downstream consume.

**Two viable integration shapes**, both contract-satisfying:

1. **Extend `modPedigree.R`** with a third `tabPanel("Diagram", ...)`,
   mirroring `R/modPyramid.R:66-69`'s Plot/Statistics `tabsetPanel` and
   `R/modGeneticValue.R:124-149`'s three-way tabsetPanel exactly. No new
   module, no new `appUI.R` tab, no new `appServer.R` wiring line, no new
   `test_moduleContract.R` entry (unless the return list itself grows).
2. **New `modPedigreeDiagram.R`** module: its own `mod*UI`/`mod*Server`
   pair, its own `appUI.R` tab, its own `appServer.R` wiring line, its own
   `test_moduleContract.R` entry. Keeps the diagram independently
   reachable/linkable but duplicates the focal-animal-selection UI/
   reactive chain `modPedigree.R` already has.

§3 D1 ratifies option 1.

### 2E. Rendering-technology survey (CRAN-live-verified, 2026-07-29)

Baseline: `DESCRIPTION` `Depends: R (>= 4.1.0)` (confirmed directly,
`DESCRIPTION:38`); `Imports` has `ggplot2`, `Matrix`, `data.table` already
— relevant since several candidates below would otherwise add those as
new deps. License `MIT + file LICENSE`.

| Package | CRAN status (live-verified) | License | Net-new deps | Native Shiny? | Pedigree-fit |
|---|---|---|---|---|---|
| **kinship2** | v1.9.6.2 (2025-09-04), active | GPL-2/3 | `quadprog` only (`Matrix` already present) | No — static base/grid graphics | Purpose-built: sex shapes, sire/dam lines, generation rows, inbreeding-loop-safe compact alignment, all for free |
| **pedtools**/pedsuite | v2.11.0 (2026-06-19), active | GPL-3 | imports `kinship2`+`pedmut`; **requires R ≥ 4.2** (current floor 4.1.0 — a version-floor bump) | No — same static model | Same core semantics as kinship2 (imports its layout code) plus refinements |
| **BGmisc** | v1.6.0.1 (2026-03-13), active | GPL-3 | `igraph`, `stringr` (`data.table`/`Matrix` already present) | No — analysis layer, not a renderer | N/A (not a renderer by itself) |
| **ggpedigree** | v1.2.0 (2026-05-30), active, very recent | GPL(≥3) | `BGmisc`, `rlang`, `dplyr`, `stringr`, `plotly`, `scales`, `tidyr` (`ggplot2` already present) — heaviest footprint here (`stringr` is a genuine net-new dep here, distinct from the already-imported `stringi`) | **Partial** — `ggPedigreeInteractive()` via plotly (`renderPlotly`/`event_data`) | Built on kinship2's own alignment logic; claims duplicated-individual (inbreeding-loop) support |
| **visNetwork** | v2.1.4 (2025-09-04), active | **MIT** (license-matches project) | `htmlwidgets`, `htmltools`, `jsonlite`, `magrittr` — lean | **Yes, natively** — `visNetworkOutput`/`renderVisNetwork`, click events bind to `input$...` | DAG-capable hierarchical layout (`level` + direction `"UD"`) gets generation-ordering "for free"; sex-shape/sire-dam-edge semantics must be hand-built |
| networkD3 | v0.4.1 (2025-04-14) | GPL(≥3) | `data.tree`, `igraph` | Yes | Poor fit — strict single-parent-tree assumption, pedigrees are DAGs |
| DiagrammeR | v1.0.12 (2026-04-27) | MIT | imports **visNetwork** itself + 17 more (full live `Imports:` is 18 packages incl. `igraph`/`dplyr`/`tidyr`/`purrr`/`stringr`/`rlang`/`glue`/`readr`/`tibble`/`cli`/`rstudioapi`/`RColorBrewer`/`viridisLite`/`scales`/`htmltools`/`magrittr`) — substantially heavier than the plan's own first-pass estimate | Yes, natively (`DiagrammeROutput`/`renderDiagrammeR`) — its own generic htmlwidget binding, usable whether the graph was built via its default grViz/viz.js engine or the optional visNetwork engine | Good static Sugiyama layout (Graphviz/`dot`); strictly heavier than depending on visNetwork directly for the same interactivity — confirmed even more true once the full 18-package import list is counted |
| collapsibleTree | v0.1.8 (2023-11-13, ~2.5yr stale) | GPL(≥3) | `data.tree` | Yes | Poor fit + maintenance-staleness flag |
| ggraph+tidygraph | v2.2.2/v1.3.1, active | MIT both | `igraph`, `dplyr`, `ggforce`, `graphlayouts`, others (`ggplot2` already present) | No natively (static ggplot2; needs `ggiraph`/`plotly` for interactivity, neither currently a dep) | Good Sugiyama layout via `igraph`/`graphlayouts`; same hand-built-semantics cost as visNetwork |

The tradeoff, stated once: purpose-built genetics packages
(kinship2-family) get pedigree-correct semantics for free but are
static-only; general graph libraries (visNetwork-family) get native Shiny
interactivity for free but need pedigree-specific layout/shape logic
hand-built on top. §3 D2 ratifies visNetwork.

### 2F. Tests that pin current behavior / TDD anchors

- `tests/testthat/test_moduleContract.R:26-31` — `modPedigree`'s expected
  return-name vector. **Unchanged by Slice 1** (§4) since the diagram adds
  a UI output, not a new returned reactive; would need a new entry
  appended if Slice 2's click-to-navigate work adds a returned reactive
  (e.g. a `selectedNode`-style value).
- No existing test exercises `modPedigreeServer`'s UI beyond the return
  -shape guard (`shiny::testServer()` doesn't render UI). A new pure
  conversion function (pedigree data frame → `{nodes, edges}`, §4 Slice 1)
  is the natural, easily-unit-testable RED target — a standard project
  convention (one function per `R/` file, e.g. `createPedTree.R`,
  `findGeneration.R`) applies directly here.
- No test currently reads `focalAnimals` from `modPedigreeServer`'s
  return list (confirmed by the same `appServer.R` grep in §2A) — Slice 1
  does not change this; Slice 2 (if it wires click-to-navigate through
  `focalAnimals`) would need new test coverage for that consumption.

---

## 3. Design decisions — RATIFIED (Session 432, 2026-07-29, via `AskUserQuestion`)

- **D1 — Module structure: extend `modPedigree.R`.** Add a third
  `tabPanel("Diagram", ...)` inside the existing module (§2D option 1),
  not a new `modPedigreeDiagram.R` module. Rationale: direct, already
  -shipped precedent (`modPyramid.R`, `modGeneticValue.R`) for exactly
  this multi-view-within-one-module shape; reuses the module's existing
  `pedigree`/`pedigreeData`/`focalAnimals` reactives with zero new
  `appUI.R` tab, zero new `appServer.R` wiring, and no new
  `test_moduleContract.R` entry required for Slice 1.
- **D2 — Rendering technology: visNetwork.** Rationale: MIT license
  matches the project exactly (unlike every purpose-built genetics
  candidate, all GPL); lean, actively-maintained dependency; native Shiny
  interactivity (pan/zoom/click-to-select feeding back into the server)
  comes for free via its htmlwidget bindings, which purpose-built static
  plotters (kinship2, pedtools, ggpedigree's static mode) do not offer
  without a render-to-image workaround. Accepted tradeoff: pedigree
  -specific semantics (sex-to-shape mapping, sire/dam edge styling,
  generation-to-level mapping) must be hand-built on top of vis.js's
  generic hierarchical layout — no kinship2-style specialized
  inbreeding-loop compact alignment. **Declined:** kinship2 (static-only,
  a real interactivity gap given the ratified goal); pedtools (same
  static-only limitation, plus forces an R-version-floor bump to ≥ 4.2);
  ggpedigree (heaviest new-dependency footprint of any candidate, and a
  very recent, less battle-tested release history); deferring the pick to
  a prototype spike (adds a slice without a compelling reason once
  visNetwork's fit was judged sufficient from live-verified CRAN
  evidence).
- **D3 — Diagram population: reuse the existing strict-lineal trim.** The
  Diagram tab visualizes exactly the same `pedigreeData()` reactive the
  Table tab already renders (ancestors ∪ descendants of the selected
  focal animal(s), §2A step 3) — zero new data plumbing, and Table/Diagram
  views of the same focal selection are guaranteed to show the same
  animals. **Declined:** the broader `getPedDirectRelatives()`-based
  connected-component-with-collaterals semantics (§2C) — richer, but a
  second, currently-`modPedigree`-unused code path that would show the
  Diagram tab a different population than the Table tab for the same
  selection, which was judged more confusing than the collateral-relative
  richness is worth.
- **D4 — Slicing: multi-slice.** Two vertical slices, each its own future
  implementation session (§4): **Slice 1** — core diagram render (node/
  edge construction, sex-shape mapping, sire/dam edges, generation
  -ordered hierarchical layout, wired into the new Diagram tab; native
  vis.js pan/zoom already comes along for free as an inherent property of
  using the widget, no extra work). **Slice 2** — click-to-navigate
  (clicking a node in the diagram re-centers the focal-animal selection,
  re-driving both the Table and Diagram views) — a genuinely separate,
  deferrable capability requiring new reactive wiring (`visNetworkProxy`/
  `visEvents`, an `observeEvent` writing back into the existing `focalIds`
  reactiveVal) that Slice 1 does not need. Rationale: D2's choice of
  visNetwork already bundles "native interactivity" into the base widget
  render, so the natural multi-slice boundary for *this* technology choice
  is not "static then interactive" (that framing fit a kinship2-style
  choice); it's "diagram renders correctly" vs. "diagram becomes a
  navigation control," which are two independently shippable, independently
  reversible capabilities. This also matches `BACKLOG.md`'s own Effort M/L
  tag and its explicit "needs its own scoping session" flag (heavier than
  #127 got), and reuses the #125 plan's lettered-inventory +
  repeated-per-slice structure (§1 Prior process history).

---

## 4. Implementation plan — vertical slices (one session each)

### Slice 1 (first, ratified) = Core pedigree diagram render

**Scope.** Add a "Diagram" tab to `modPedigree.R`'s existing pedigree
-browser UI, rendering the same `pedigreeData()` population the Table tab
shows, as a visNetwork hierarchical graph: sex-coded node shapes, sire/dam
directed edges, generation-ordered layout (founders at top). Native pan/
zoom/hover come from the widget itself. Clicking a node does **not**
change the app's focal-animal selection in this slice (that's Slice 2).

**What does NOT change:** `modPedigreeServer`'s returned reactive
vocabulary (still exactly `pedigree`, `processedPedigree`, `focalAnimals`,
`nAnimals`, `populationCount`, `isReady` — §2F); `appUI.R`/`appServer.R`
wiring for `modPedigree` (unchanged — D1); the Table tab's existing
behavior; any other module.

**Files to touch:**
- `DESCRIPTION` — add `visNetwork` to `Imports` (it is load-bearing in the
  shipped app, matching how `DT` is already an `Imports`, not a
  `Suggests`).
- A new, single-purpose `R/` file (project convention: one function per
  file, e.g. `createPedTree.R`, `findGeneration.R`) — a pure function
  converting a pedigree data frame (`id`/`sire`/`dam`/`sex`/`gen`) into a
  visNetwork-ready `list(nodes = data.frame(...), edges = data.frame(...))`:
  - **nodes**: one row per `id`, `label = id`, `shape` mapped from `sex`
    (`"M" -> "square"`, `"F" -> "dot"`; `"U"`/`"H"` need an explicit,
    documented convention — this plan recommends `"triangle"` for `"U"`
    and `"star"` for `"H"`, but the implementing session should confirm
    this against `nprcgenekeepr::examplePedigree`'s actual `sex` factor
    levels and pick shapes visNetwork actually supports before writing
    the RED test), `level = gen` (vis.js's hierarchical-layout level;
    `gen = 0` founders land at the top with direction `"UD"`, confirmed
    by §1's `findGeneration.R` reading — no inversion needed).
  - **edges**: one directed edge `(from = sire, to = id)` for every row
    with non-`NA` `sire`, and `(from = dam, to = id)` for every row with
    non-`NA` `dam` — two edges per fully-known-parentage individual, one
    for a single-known-parent individual, zero for a founder.
- `R/modPedigree.R`:
  - UI (currently lines 145-151's flat `DT::DTOutput` area): wrap the
    existing table inside `tabsetPanel(tabPanel("Table",
    DT::DTOutput(ns("pedigreeTable"))), tabPanel("Diagram",
    visNetwork::visNetworkOutput(ns("pedigreeDiagram"))))`, mirroring
    `modPyramid.R:66-69`'s exact shape.
  - Server: new `output$pedigreeDiagram <-
    visNetwork::renderVisNetwork({ ... })`, built by feeding
    `pedigreeData()` through the new conversion function, then
    `visNetwork::visNetwork(nodes, edges) |> visNetwork::visHierarchicalLayout(direction = "UD", sortMethod = "directed")`.
- `tests/testthat/test_<newConversionFunction>.R` — RED first: unit tests
  for the pure conversion function against a small hand-built pedigree
  (a trio: 2 founders + 1 offspring is enough to assert node count, edge
  count, shape mapping, and level assignment) and against
  `nprcgenekeepr::examplePedigree` (assert node/edge counts match
  `nrow(ped)` and the known sire/dam-non-NA counts).
- `NAMESPACE`/`man/` — regenerated via `devtools::document()` once the
  new function is `@export`ed (internal-only if the conversion function
  is `@noRd`, matching e.g. `isGeneratedUnknownId`'s pattern — the
  implementing session should decide export status based on whether any
  test or vignette needs to call it directly, not by default).

**RED (tests only):** write the conversion-function unit tests above
(node/edge/shape/level assertions on a hand-built trio and on
`examplePedigree`); confirm they fail because the function doesn't exist
yet.

**GREEN:** implement the conversion function; wire the UI tab and
`renderVisNetwork` output in `modPedigree.R`; add the `visNetwork` import.
No changes to `modPedigreeServer`'s return list.

**DONE looks like:** `devtools::check()` 0 errors/0 warnings; the new
unit tests pass; a live `shinytest2`/`chromote` smoke test (Phase 3E)
confirms the Diagram tab renders a visNetwork widget for the bundled
`obfuscated_rhesus_mhc_ped.csv` fixture (Learning 400's proven E2E
fixture) without a console error, showing sex-shaped nodes and sire/dam
edges for at least one known trio in that fixture.

**Verify:** targeted test file run; full clean regression read
(`CLAUDE.md`'s documented recipe); `devtools::check()`; live E2E smoke
test per Phase 3E.

**Session boundary:** this slice is one session. Close out when Slice 1's
DONE criteria are met. Slice 2 is a separate future session.

### Slice 2 (deferred) = Click-to-navigate interactivity

**Scope.** Clicking a node in the Diagram tab sets that animal as the new
focal-animal selection, re-driving `focalIds` (the same `reactiveVal`
`observeEvent(input$updateFocalAnimals, ...)` already writes to,
`R/modPedigree.R:225-293`) so both the Table and Diagram tabs re-render
centered on the newly-clicked individual — turning the diagram into a
navigation control, not just a picture.

**What does NOT change:** Slice 1's node/edge conversion function or
shape/level conventions; the Table tab; any other module.

**Mechanism (design-level, to be confirmed hands-on at this slice's own
Pre-RED — see Dragon P4):** visNetwork's Shiny binding is documented to
expose click events as `input[[paste0(<outputId>, "_click")]]$nodes` (a
vector of clicked node IDs) without extra JavaScript. An
`observeEvent(input$pedigreeDiagram_click, ...)` would read the clicked
node id and write it into `focalIds`, reusing the exact same downstream
recompute path (`processedPedigree` → `pedigreeData`) the existing
focal-animal-textarea path already drives — no duplicate logic. Consider
`visNetworkProxy()` for an in-place update (avoiding a full widget
teardown/rebuild on every click) once the basic version works.

**RED (tests only):** a `shiny::testServer()` test simulating the click
input and asserting `focalIds()` (or the equivalent internal state)
updates to the clicked id, and that `pedigreeData()` recomputes
accordingly.

**GREEN:** wire the `observeEvent`; confirm the Table tab visibly changes
in lockstep with a Diagram-tab click in a live smoke test.

**DONE looks like:** clicking any rendered node in a live app instance
changes the Table tab's contents to that individual's own ancestor/
descendant set; `devtools::check()` clean; regression suite clean.

**Verify:** same matrix as Slice 1, plus the live click-through smoke
test above.

**Session boundary:** separate future session, after Slice 1 has shipped
and been used, so this slice's Pre-RED can confirm the click-event input
-binding convention against Slice 1's actual, already-live widget rather
than against documentation alone (Dragon P4).

---

## 5. Cross-slice notes

- **Slice independence.** Slice 1 is fully useful on its own — a
  read-only diagram is strictly more than the table-only status quo, and
  satisfies issue #129's stated gap by itself. Slice 2 is a pure addition
  on top; if Slice 2 is never picked up, Slice 1 alone still closes the
  issue's core ask.
- **Shared invariant across both slices:** the Diagram tab always shows
  exactly the population `pedigreeData()` currently holds (D3) — Slice 2
  changes *which* focal selection drives that population, never the
  population-selection semantics itself (still strict-lineal, still no
  collaterals) without a separate, future decision to revisit D3.
- **NEWS/PR linkage:** if shipped as two separate PRs, Slice 1's PR
  "Closes #129" only if the issue is considered satisfied by a read-only
  diagram (recommend confirming this reading with the owner at Slice 1's
  own close-out, rather than assuming); otherwise Slice 1 "Relates to
  #129" and Slice 2 "Closes #129", matching the #125 plan's own
  per-slice PR-linkage convention.
- **Dependency floor consequence of D2:** choosing visNetwork (MIT, no
  R-version-floor requirement) instead of pedtools means this plan does
  **not** need to touch `DESCRIPTION`'s `Depends: R (>= 4.1.0)` line at
  all — flagged here explicitly since it was a live risk under a
  different D2 answer.

---

## 6. Here be dragons (consolidated load-bearing risks)

- **P1 — visNetwork is not hands-on verified in this session.** It is not
  installed in this development environment; the mechanism above is
  designed from live-verified CRAN metadata (version, license,
  dependency list, documented function names) and the research agent's
  characterization of its API, not from running actual code. **The Slice
  1 implementing session's Pre-RED must install `visNetwork` and confirm
  `visNetworkOutput()`/`renderVisNetwork()`/`visHierarchicalLayout()`
  exist and behave as described before writing the RED tests** — treat
  this as unverified, not as settled fact.
- **P2 — Inbreeding-loop rendering is unverified.** The research found
  that vis.js's hierarchical layout handles DAGs (not just strict trees)
  "gracefully," but this project's real pedigrees plausibly contain
  individuals reachable via more than one path (loops), and no worked
  example of this specific case was run this session (blocked by P1).
  **Slice 1's worked-example verification must include at least one
  known-loop case** (e.g. a half-sib mating in `examplePedigree`, if one
  exists — grep for it) and visually/structurally confirm the layout
  doesn't break, duplicate nodes unexpectedly, or silently drop an edge.
- **P3 — Unbounded diagram size if trimming is off.** `modPedigree.R`'s
  existing `input$trimPedigree` toggle can be unchecked by the user,
  in which case `pedigreeData()` could be the full, untrimmed pedigree
  (thousands of rows, §1). Rendering that as a diagram is a real
  readability/performance risk this plan does not fully resolve — the
  implementing session should pick a concrete mitigation (e.g., the
  Diagram tab shows an informative message instead of a widget above
  some node-count threshold, or the Diagram tab always applies the
  strict-lineal trim regardless of the Table tab's toggle state) and
  document the choice, rather than shipping an unbounded render.
- **P4 — Slice 2's click-event input-binding convention is
  documentation-derived, not confirmed.** The exact `input$<id>_click`
  shape (and whether it needs `visEvents()` wired explicitly vs. coming
  for free) should be confirmed against a real, running Slice-1 widget at
  Slice 2's own Pre-RED — this is exactly why Slice 2 is scheduled after
  Slice 1 ships (§4 Session boundary), not designed further blind here.
- **P5 — Sex-shape convention for `"U"`/`"H"` is this plan's own proposal,
  not a verified industry standard.** kinship2's convention (diamond =
  unknown) is well-established for the binary M/F + unknown case, but
  this project's 4-level `sex` factor (`F/M/H/U`) doesn't map onto that
  1:1. The implementing session should treat the `"triangle"`/`"star"`
  proposal in §4 Slice 1 as a starting point to confirm against real data
  (how often do `H`/`U` actually occur in bundled/live pedigrees?), not a
  final decision already made by this plan.
- **P6 — `visNetwork` is a new GPL-vs-MIT license mix.** Not itself a
  CRAN-policy blocker (arms-length `Imports:` of a GPL package by an MIT
  package is routine), but it's the project's first GPL dependency
  (confirmed: `DESCRIPTION`'s current full dependency list is entirely
  permissive-licensed) — worth a one-line acknowledgment in `NEWS.Rmd`/
  release notes rather than treated as silently equivalent to prior
  dependency additions.

---

## 7. Owner ratification record

- [x] D1 — Extend `modPedigree.R` with a new Diagram tab (not a new
      module).
- [x] D2 — Rendering technology: visNetwork.
- [x] D3 — Diagram population: reuse the existing strict-lineal trim.
- [x] D4 — Slicing: multi-slice (Slice 1 core render; Slice 2
      click-to-navigate, deferred to a future session).
