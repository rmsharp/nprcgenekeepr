# Scoping: factoring the pedigree-diagram layout code into a separate R package

**Date:** 2026-09-02 (Session 667)
**Trigger:** `BACKLOG.md` Up Next item "Investigate factoring out the pedigree-diagram drawing
functionality into a separate R package that `nprcgenekeepr` depends on" (found 2026-08-19,
owner-directed, READY, Effort M — "a research/scoping session, not an implementation session").
**Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` (package-boundary /
migration decision; its Refactor Heuristics — deepening and the Deletion Test — are applied in §5).
**Scope:** Investigation and decision support only. No `R/`/`tests/` package code changed — TDD
RED/GREEN/REFACTOR gates do not apply (matches the research-spike precedent of
`docs/research/issue-145-kinship2-sire-dam-placement-spike-2026-08-08.md`). **No split decision is
made here**; the decision is the owner's, and this document exists to make it on evidence rather
than instinct. If a split is ever chosen, it needs its own planning session (`SESSION_RUNNER.md`
FM #18/#19) — §7 sketches what that plan would have to contain, but is not that plan.

The `BACKLOG.md` item's own precondition — "probably after the Walker/BJL apportioning redesign
(issue #141)" — is met: [issue #141](https://github.com/rmsharp/nprcgenekeepr/issues/141) was
closed 2026-08-21 (`gh issue view 141`, checked this session).

---

## Method

Every number below was measured this session against the working tree at `94ae26c8`
(S666's close-out), not recalled or estimated. The reproducible commands are collected in §8.

1. **Dependency inventory by `codetools::findGlobals()`** on the *loaded* package
   (`pkgload::load_all()`), not by grep: for every function defined in the candidate files, the
   set of other package functions it references (forward coupling); for every other package
   function, whether it references a candidate-file function (reverse coupling); and the origin
   (base / imported package / unknown) of every non-package symbol. Grep was used only where a
   symbol is a string or a comment (roxygen cross-references, `::`-qualified calls, test files).
2. **Line and file counts** via `wc -l`; **churn** via `git log --since`/`--oneline -- <path>`.
3. **Ecosystem facts** verified against the CRAN package pages directly (not a search summary).
4. **Prior decisions** searched across `docs/planning`, `docs/research`, `docs/audits`,
   `BACKLOG.md`, `PROJECT_LEARNINGS.md`, `ROADMAP.md` (the pkgdown site under `docs/` excluded).

---

## 1. Context

### 1.1 Problem statement

`R/makePedigreeDiagramData.R` has become the largest and most actively changed file in the
package (§2.7). It implements a self-contained problem — laying out a pedigree as a
kinship2-style mating-unit diagram for an interactive `visNetwork` widget — that is conceptually
independent of colony-management genetics (kinship, genetic value, breeding-group formation). The
owner asked whether that code should live in its own package, with `nprcgenekeepr` depending on
it, and specifically for "the possibility, advantages, and disadvantages" covering: reuse
potential outside this project, a cleaner dependency graph, versioning/release overhead,
cross-package test/CI complexity, and `@noRd`/internal-function visibility loss across a package
boundary.

### 1.2 Hard constraints that shape the answer

- **CRAN.** `nprcgenekeepr` 2.0.0 is on CRAN (published 2026-07-26). Its CRAN `Imports` list does
  **not** contain `visNetwork` — the entire Pedigree Diagram tab is post-2.0.0, unreleased dev
  work (`DESCRIPTION` is at 2.0.0.9000). A new package in `Imports:` must itself be on CRAN before
  `nprcgenekeepr` can be submitted, so a split *before* the next CRAN release makes that release
  wait on a first-time CRAN submission of a second package.
- **This project's own process model.** Every repository the owner runs under this methodology
  carries its own `SESSION_RUNNER.md`/`SESSION_NOTES.md`/`HANDOFFS.md`/`CHANGELOG.md`/`BACKLOG.md`,
  and a session writes to the notes of the directory it runs in (`SESSION_RUNNER.md` §Phase 0,
  "session-notes boundary"). A change that spans two repositories is, under this model, at least
  two sessions plus a version-floor bump in the consumer.
- **Standing priority.** `BACKLOG.md`'s "STANDING TOP PRIORITY (owner-directed, 2026-08-26,
  S643)" note keeps pedigree-drawing fidelity work first until the owner says it is done. As of
  S666 every numbered pedigree item is closed, but the note itself stands, and the code has been
  changing daily (§2.7).

### 1.3 Current state, in one diagram

```
                 nprcgenekeepr (one package, one repo)
 ┌──────────────────────────────────────────────────────────────────────┐
 │  Shiny app                                                           │
 │   appUI / appServer ──► modPedigreeUI / modPedigreeServer            │
 │                                │   (R/modPedigree.R, 882 lines;      │
 │                                │    Diagram tab ≈ 262 server lines)  │
 │        calls 8 package fns ◄───┤                                     │
 │        (findGeneration,        │  makePedigreeMatingLayout(ped,      │
 │         trimPedigree, ...)     │      edgeStyle, twinRelations)      │
 │                                ▼                                     │
 │  ┌────────────────────────────────────────────────────────────────┐  │
 │  │ LAYOUT CORE                                                    │  │
 │  │  R/makePedigreeDiagramData.R  (2,537 lines, 2 exported + 11)   │  │
 │  │  R/positionTreeApportion.R    (  277 lines, 13 internal)       │  │
 │  │  runtime deps: base R + stats::setNames — NO visNetwork call   │  │
 │  │  reaches back into the package at ONE point: kinship()         │  │
 │  └────────────────────────────────────────────────────────────────┘  │
 │                                │ kinship(id, sire, dam, gen,          │
 │                                ▼         twinRelations)               │
 │  GENETICS CORE  R/kinship.R (228 lines) ... reportGV, groupAddAssign  │
 │                                                                      │
 │  VALIDATION     R/comparePedigreeStructure.R (378 lines, 4 internal) │
 │                 consumes layout OUTPUT via parameter; uses kinship2  │
 └──────────────────────────────────────────────────────────────────────┘
```

---

## 2. Evidence inventory

### 2.1 Code surface — what "the pedigree-diagram drawing functionality" actually is

| File | Lines | Functions | Exported | Role | Would move? |
|---|---:|---:|---|---|---|
| `R/makePedigreeDiagramData.R` | 2,537 | 13 (+1 constant `.nameLabelCharBudget`, `:198`) | `makePedigreeDiagramData()` `:32`, `makePedigreeMatingLayout()` `:1461` | Layout engine: mating-unit forest (`.buildMatingUnitForest()` `:389`), Walker/BJL positioning + Tier 1/2/3 + collision avoidance (`.positionMatingUnitForest()` `:627`), rectilinear waypoints (`.addRectilinearWaypoints()` `:1927`), edge/node de-collision (`.resolveEdgeNodeCollisions()` `:2253`), plus helpers (`.findIsolatedIds()` `:327`, `.buildTwinConnectorEdges()` `:279`, `.affectedColor()`/`.affectedLabel()`, `.nameLabel()`/`.nameTooltipLine()`, `.escapeHtml()`) | Yes — this is the core |
| `R/positionTreeApportion.R` | 277 | 13 (all internal; no roxygen `@export`/`@noRd` markers at all) | none | Walker/Buchheim-Jünger-Leipert tree apportioning engine (`.positionTreeApportion()` `:238`, `.buildForestChildrenOf()` `:260`), called only by `.positionMatingUnitForest()` | Yes — inseparable from the core |
| `R/comparePedigreeStructure.R` | 378 | 4 (all `@noRd`) | none | Structural comparison of a layout's output against `kinship2::pedigree()` (Track B fidelity validation). Takes the layout's return value as a *parameter*; its only references to the layout functions are roxygen prose (`:11, :35, :90, :98, :105, :118, :241`), not calls | Either — belongs with the core's fidelity apparatus, but has no code coupling |
| `R/modPedigree.R` | 882 | 2 (`modPedigreeUI()` `:22`, `modPedigreeServer()` `:233`) | both | The Pedigree Browser Shiny module: focal-animal trimming, pedigree table, twin relations upload, **and** the Diagram tab (`tabPanel("Diagram", ...)` `:178`; `output$pedigreeDiagramUI` `:500`; `diagramLayout` reactive `:621`; `renderVisNetwork` `:646`; click/highlight observers `:821`/`:834`) | **No** — see §2.2 |

Totals: the layout core is **2,814 lines = 9.7 %** of `R/` (29,140 lines); with
`comparePedigreeStructure.R`, 3,192 lines = 11.0 %. The diagram is the 2nd- and 3rd-largest
concerns in the package by file (`R/makePedigreeDiagramData.R` is the largest single file; the
next largest, `R/modSummaryStats.R`, is 959 lines).

### 2.2 Coupling — measured, not assumed

**Forward: what the candidate code calls elsewhere in the package** (`findGlobals`, §8 cmd 1):

| From | Calls into package | Kind |
|---|---|---|
| `.positionMatingUnitForest()` | `.positionTreeApportion()`, `.buildForestChildrenOf()` (`R/positionTreeApportion.R`) | internal → moves with the core |
| `makePedigreeMatingLayout()` | **`kinship()`** (`R/kinship.R:104`), at `R/makePedigreeDiagramData.R:1551` — computes the full kinship matrix to flag consanguineous mating units for the vermillion mate-line marker (S549 Finding #2, fixed S555), threading `twinRelations` through | **the one genuine core → genetics dependency** |
| `makePedigreeDiagramData()` | nothing | — |
| `modPedigreeServer()` | `checkTwinRelations()`, `findGeneration()`, `findPedigreeNumber()`, `getDescendantPedigree()`, `readTwinRelations()`, `setPopulation()`, `trimPedigree()` (all exported) and `isGeneratedUnknownId()` (**internal**, `R/autoIdFormat.R`, used at `R/modPedigree.R:361`) | 8 functions — the module is a nprcgenekeepr *consumer*, not part of the layout |

External (non-package) symbols used by the layout core: base R and `stats::setNames` (39 uses)
only. The single `visNetwork::` string in `R/makePedigreeDiagramData.R` is roxygen prose (`:6`,
"consumed by `visNetwork::visNetwork()`"). **The layout core has no runtime `visNetwork`
dependency** — it builds `visNetwork`-shaped `nodes`/`edges` data frames. All 11
`visNetwork::` calls (`visNetwork`, `visNodes`, `visEdges`, `visOptions`, `visPhysics`,
`visLegend`, `visExport`, `visEvents`, `visNetworkOutput`, `renderVisNetwork`) are in
`R/modPedigree.R`, plus 2 `DT::` calls for the table tab.

**Reverse: who in `R/` calls the candidate code** (`findGlobals`, §8 cmd 1):

| Caller | Calls | Where |
|---|---|---|
| `modPedigreeServer()` | `makePedigreeMatingLayout(data, edgeStyle = .currentEdgeStyle(), twinRelations = ...)` | `R/modPedigree.R:642` |
| `appServer()` / `appUI()` | `modPedigreeServer()` / `modPedigreeUI()` | wiring only |
| *(nothing else)* | | |

`makePedigreeDiagramData()` — the original issue #129 Slice 1 hierarchical layout — has **zero**
in-package callers. It survives as an exported, script-callable function (documented in
`vignettes/a2interactive.Rmd`) and as the `nodes`/`edges` shape contract
`makePedigreeMatingLayout()` extends. `R/comparePedigreeStructure.R` does not call the layout
either; it receives the layout's return value.

**Verdict on the boundary:** the layout core is a genuinely deep module (§5.1) with a one-function
consumer and a one-function back-reference. That is close to the ideal shape for a package
boundary — *except* for the `kinship()` call, which would be a circular dependency
(`newpkg → nprcgenekeepr → newpkg`) unless inverted (§4, §7 step 1).

### 2.3 The interface as it exists today

Input (`makePedigreeMatingLayout()`, `R/makePedigreeDiagramData.R:1407-1425, :1467`):

- `ped`: data frame with **`id`, `sire`, `dam`, `sex`, `gen`** required. `gen` is "as produced by
  `findGeneration()`" (`:14`) — i.e. the caller is expected to run a nprcgenekeepr function first.
  Optional columns consumed: `affected` (issue #133), name columns for labels (issue #136, via
  `.nameLabel()`).
- `sex` codes are hard-wired to nprcgenekeepr's convention inside the core: `shapeMap <- c(F =
  "dot", M = "square", H = "star", U = "triangle")` (`:1567`, and `:44` in the older function).
- `edgeStyle = c("rectilinear", "direct")`; `twinRelations` sidecar data frame (`id1`, `id2`,
  `code`), validated by the *caller* with `checkTwinRelations()` (`:1418-1425`).

Output (`:1426-1454`): `list(nodes, edges, duplicateToReal, isolatedIds)`, where `nodes` carries
`id, label, shape, title, size, x, y` (+ `color.background`/`color.border` under rectilinear) and
`edges` carries `from, to, dashes, color, width` (+ `label` with twins). The module reads exactly
`$nodes`, `$edges`, `$isolatedIds` (`R/modPedigree.R:522`) and `$duplicateToReal` (`:827`).

Two things in this contract are nprcgenekeepr-specific and would have to be either generalized or
documented as a convention by a standalone package: the `F/M/H/U` sex codes, and the expectation
that `gen` comes from `findGeneration()` (77 lines, `R/findGeneration.R:40`).

### 2.4 Tests

Total `tests/testthat`: 56,802 lines. Test files whose *subject* is the layout core:

| File | Lines | Direct calls to core fns | Calls to *internal* (dot-prefixed) core fns |
|---|---:|---:|---:|
| `test_positionMatingUnitForest.R` | 3,250 | 143 | 137 |
| `test_makePedigreeMatingLayout.R` | 1,651 | 108 | 45 |
| `test_addRectilinearWaypoints.R` | 861 | 33 | 29 |
| `test_resolveEdgeNodeCollisions.R` | 610 | 34 | 27 |
| `test_makePedigreeDiagramData.R` | 487 | 30 | 0 |
| `test_buildMatingUnitForest.R` | 444 | 23 | 23 |
| `test_positionTreeApportion.R` | 137 | 7 | 7 |
| `test_findIsolatedIds.R` | 126 | 13 | 11 |
| `helper-live-render-positions.R` (+ its teardown test, 100) | 171 | — | — (chromote live-render harness for the core) |
| **Subtotal** | **7,837 (13.8 %)** | | |
| `test_comparePedigreeStructure.R` + helper | 1,305 | 25 | 4 (comments only) |

What these tests lean on that a standalone package would not have:

- **The real 375-individual fixture** `inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv`,
  loaded **27 times** across the core test files via `system.file(..., package =
  "nprcgenekeepr")` (plus `..._twins.csv` once). It is the fixture every collision-avoidance,
  proximity, and midpoint rule since S593 was pinned against.
- **`examplePedigree`** (package data; also both exported functions' `@examples`, `:29`, `:1458`),
  and nprcgenekeepr's own preprocessing chain — `qcStudbook()`, `findGeneration()`, `kinship()` —
  used to build fixtures inside the tests (17 such references in `test_positionMatingUnitForest.R`
  alone; 4, 3, 2, 3 in the next four files).
- **`kinship2`** (`Suggests:`) for the live Track B/C fidelity tests, which would move with the
  core.

Tests that would *stay* in nprcgenekeepr but reach into the core: of the 8 non-core files that
mention an internal core function, **all references are comments except two real calls** —
`tests/testthat/test_modPedigree.R:1669` and `:1706`, each `forest <-
.buildMatingUnitForest(cbind(test_studbook, gen = 0L))`. Under a split those two would need
`newpkg:::` (a CRAN NOTE-free but fragile pattern) or a small exported accessor.

### 2.5 Documentation and data surface

- `man/`: 4 pages (`makePedigreeDiagramData.Rd`, `makePedigreeMatingLayout.Rd`,
  `modPedigreeServer.Rd`, `modPedigreeUI.Rd`).
- `_pkgdown.yml`: 2 reference entries for the core (`:311-312`), 2 for the module (`:345-346`),
  1 article (`:63`).
- Vignettes/articles referencing the diagram: `vignettes/articles/pedigree-diagram.qmd` (15
  references), `vignettes/articles/kinship2-fidelity-validation.qmd` (17),
  `vignettes/a2interactive.Rmd` (37 — the script-callable tutorial's "Pedigree Diagram" section),
  `vignettes/articles/colony-manager-guide.qmd` (3); plus
  `data-raw/kinship2FidelityValidation.R` (14) which regenerates the Track B/C images.
- Design history: **36 files** under `docs/planning/` (`issue129-…`, `issue133-…`, `issue136-…`,
  `issue137-…`, `issue150-…`, and 31 `pedigree-diagram-*` plans/spikes/evidence files) plus the
  `docs/research/issue-145-…` spike. This history is repo-bound; a new package would start with
  none of it in-tree.
- Prior discussion of a split: **none** before the 2026-08-19 `BACKLOG.md` item (§8 cmd 6). This
  document is the first treatment.

### 2.6 Churn — the timing signal

| Path | Commits since 2026-06-01 | Commits in the last 30 days (since 2026-08-03) |
|---|---:|---:|
| `R/makePedigreeDiagramData.R` (created 2026-07-30, `39eb441e`) | **49** | **41** |
| `R/modPedigree.R` | 29 | — |
| `R/positionTreeApportion.R` (created 2026-08-19, `8ac50a4e`) | 1 | 1 |
| all of `R/` | 272 | 86 |

**41 of the last 30 days' 86 `R/` commits (48 %) touched the layout engine** — roughly 1.4
commits per day since the file was created, spanning the Walker/BJL migration (#141, S620/S621),
isolated-individual suppression (S643-S650), Track 7 mate-spacing Phases 1-4 (S646-S655),
duplicate/B1 proximity (S658-S662), and the mating-union midpoint rule (S664-S666). Every one of
those was a cross-file change (core + 2-4 test files + regenerated images + a `NEWS.Rmd` bullet).

### 2.7 Ecosystem and reuse potential (verified against CRAN pages this session)

| Package | Version / published | Layout approach | Output | Relevant fact |
|---|---|---|---|---|
| [kinship2](https://cran.r-project.org/web/packages/kinship2/index.html) | 1.9.6.2 / 2025-09-04, maintainer Jason Sinnwell | `align.pedigree()` QP alignment (`alignped4`) | static base graphics | **No** orphaned/archived/deprecation notice on CRAN. The "impending deprecation" language circulating about it is [ggpedigree](https://cran.r-project.org/web/packages/ggpedigree/index.html)'s own description, not CRAN's. |
| [ggpedigree](https://cran.r-project.org/web/packages/ggpedigree/index.html) | 1.2.0 / 2026-05-30 | absorbed kinship2's layout helpers | `ggplot2` + `plotly` (interactive) | Imports `plotly`; explicitly interactive. Closest existing thing to "interactive pedigree drawing in R". |
| [pedtools](https://cran.r-project.org/web/packages/pedtools/vignettes/pedtools.html) | current | imports kinship2's alignment, own plotting | static | The owner has a fork (`rmsharp/pedtools`, last push 2025-07-13, dormant). |
| [visPedigree](https://cran.r-project.org/package=visPedigree) | on CRAN | `igraph` | static/igraph | Animal/plant pedigrees; not vis.js. |

Nothing on CRAN offers a **`visNetwork`/vis.js-targeted, mating-unit, kinship2-parity layout with
same-row collision avoidance** — which is what this core is. So a standalone package would be
genuinely novel in the ecosystem, and kinship2's uncertain future (per ggpedigree's authors)
would give it a reason to exist. But the *demand* side is, today, hypothetical: the owner's other
active repositories (`gh repo list rmsharp`, §8 cmd 8) contain no second pedigree or genetics
consumer — `wsfct`, `mts`, `methodology`, `model_project_constructor`, and older statistics/
insurance projects — and no external request for the layout code is on record. Reuse potential
is therefore a *possible future benefit with no present beneficiary*, not a present advantage.

### 2.8 Release and CI footprint a second package would replicate

- 7 GitHub Actions workflows (`R-CMD-check`, `R-CMD-check-scheduled`, `lint`, `pkgdown`,
  `test-coverage`, `shinytest2`, `rhub`); current per-push wall-clock: R-CMD-check ≈ 20 min on 5
  platforms, test-coverage ≈ 8 min, pkgdown ≈ 7 min, lint ≈ 4 min; scheduled shinytest2 ≈ 22-26
  min.
- `renv.lock` 5,808 lines (with `renv::snapshot(dev = TRUE)` discipline, `CLAUDE.md`);
  `_pkgdown.yml` 392 lines; `NEWS.Rmd` with its plain-language checklist; `CHANGELOG.md`,
  `HANDOFFS.md`, `SESSION_NOTES.md`, `BACKLOG.md`, `PROJECT_LEARNINGS.md`.
- CRAN: `nprcgenekeepr` 2.0.0 on CRAN since 2026-07-26; `visNetwork` not yet in the CRAN
  release's `Imports`.

---

## 3. Options considered

Honest alternatives, per `ARCHITECTURE_WORKSTREAM.md` §Common Anti-Patterns #7 — each has real
trade-offs; none is a straw man.

| Option | What it is | Pros | Cons |
|---|---|---|---|
| **A. Status quo** — one package | Leave the layout core where it is. | Zero migration cost; one repo, one CI, one CRAN submission; every fix stays one session; the 375-fixture, `examplePedigree`, `kinship()`, `findGeneration()` remain directly available to tests. | `R/` keeps a 2,800-line concern unrelated to colony genetics; `nprcgenekeepr` cannot be a lighter dependency for anyone wanting only the layout; the layout's one back-reference (`kinship()`) stays an implicit convention. |
| **B. Full split** — core **and** Shiny module move | New package owns layout + the Diagram tab UI. | Cleanest-sounding boundary. | **Not viable as stated**: the module calls 8 nprcgenekeepr functions (§2.2), one internal; moving it creates a real circular dependency or forces those 8 into the new package. The Diagram tab is also ~30 % of a module whose other 70 % (focal trimming, table, twin upload) is nprcgenekeepr business logic. |
| **C. Core-only split** — `makePedigreeDiagramData.R` + `positionTreeApportion.R` (± `comparePedigreeStructure.R`) → new package; module stays and `Imports:` it | The boundary the code's own coupling suggests. | The core is a deep module with a 2-function public surface and no `visNetwork` runtime dependency; a reusable, novel CRAN package; `nprcgenekeepr`'s `R/` shrinks ~10 %. | Requires inverting `kinship()` (§4 D3); duplicates the 375-fixture and example data or introduces a `Suggests:` cycle; two `test_modPedigree.R` calls need `:::`/an accessor; 2 `@examples` need new data; gates the next CRAN release on a first submission; doubles CI/renv/pkgdown/methodology overhead; every fidelity change becomes a 2-repo, 2-session, version-floor-bump change **while the file is changing 1.4×/day**. |
| **D. Prepare-to-split without splitting** — harden the boundary in place | Inside `nprcgenekeepr`: invert the `kinship()` call (accept a consanguinity/kinship input), export or replace the two test-only internal reaches, document the sex-code/`gen` contract as a stated convention, keep core tests self-contained. | Each step is small, independently TDD-able, reversible, and valuable on its own (a cleaner, injectable interface); makes a later Option C a mechanical file move; no new repo, no CRAN gating, no churn tax. | Not free: each step is a real behavior-preserving change to a file under daily fidelity work (SAFEGUARDS' "refactoring requires plan mode" rule applies); benefits only materialize if a split eventually happens or if the injectable interface is used. |

---

## 4. Advantages and disadvantages of a split, against the item's own criteria

**D1. Reuse potential outside this project** — *Advantage, hypothetical today.* The core is the
only vis.js-targeted kinship2-parity layout engine in the R ecosystem (§2.7), and its
`visNetwork`-free design means a standalone package would be light (base R + `stats`). But no
second consumer exists — not in the owner's repositories, not as an external request. The value
is an option, not a return.

**D2. Cleaner dependency graph** — *Advantage, modest and already mostly true.* The coupling
inventory (§2.2) shows the graph is *already* clean in the direction that matters: one consumer
(`modPedigreeServer`) through one function. A split would make that explicit and enforced by
`NAMESPACE`, and would let `nprcgenekeepr`'s `DESCRIPTION` drop nothing (the core has no
package deps of its own to shed; `visNetwork` stays with the module). The one thing it *would*
force is the `kinship()` inversion (D3) — arguably the graph's only real wart, and fixable without
a split.

**D3. The `kinship()` back-reference** — *Disadvantage unless inverted first.* A new package cannot
call `nprcgenekeepr::kinship()` (circular). The options are: (i) reimplement kinship in the new
package — 228 lines today, with `twinRelations`/`chrtype`/`sex` semantics that S551-S553/S564
deliberately put in one place (duplication is exactly the kind of drift `PROJECT_LEARNINGS.md`
warns about); (ii) inject — `makePedigreeMatingLayout(ped, ..., consanguineous = NULL)` or a
`kinshipFn` argument, with the module passing `kinship(...)`'s result. Option (ii) is a small,
good change in its own right and is Option D's first step.

**D4. Versioning / release overhead** — *Disadvantage, concrete and immediate.* Two packages means
two `DESCRIPTION` versions, an `Imports: newpkg (>= x.y.z)` floor that must be bumped in
`nprcgenekeepr` for every fix the app needs, two `NEWS`, two pkgdown sites, two `renv.lock`s, and
— the sharp edge — the next `nprcgenekeepr` CRAN release (which is what finally ships the Diagram
tab) waits on a first-time CRAN submission of the new package.

**D5. Cross-package test / CI complexity** — *Disadvantage, concrete.* 7,837 test lines (13.8 % of
the suite) and the chromote live-render harness move. They lean on `inst/extdata/examples/
obfuscated_rhesus_mhc_ped.csv` (27 loads), `examplePedigree`, `qcStudbook()`, `findGeneration()`,
and `kinship()` (§2.4). The new package would either copy the fixture and reimplement the
fixture-building chain, or `Suggests: nprcgenekeepr` (a Suggests cycle — legal, but it makes the
new package's own tests depend on its consumer). CI doubles (§2.8), and `shinytest2` E2E tests
for the Diagram tab stay in `nprcgenekeepr` while the code they exercise lives elsewhere.

**D6. `@noRd` / internal-function visibility loss** — *Disadvantage, small and precisely bounded.*
Only two real cross-boundary reaches exist outside the core's own tests
(`test_modPedigree.R:1669`, `:1706` → `.buildMatingUnitForest()`); the module itself uses only
the exported function and 4 documented return fields. The `positionTreeApportion.R` functions
have no roxygen at all and would need at least `@noRd` blocks in a package that must pass
`R CMD check --as-cran` on its own.

**D7. Timing / churn (not in the item's list, but the dominant factor)** — *Disadvantage, now.*
48 % of the last month's `R/` commits touched the core (§2.6). Under this project's one-repo,
one-session, TDD-gated model, each of those would have been: a RED/GREEN session in the new
repo, a release/tag, a version-floor bump + `renv.lock` update + re-verification session in
`nprcgenekeepr`, and image regeneration split across both. The standing pedigree-fidelity
priority is still in force. Splitting a module while it is the most volatile code in the system is
the "big-bang migration" anti-pattern's quieter cousin: not one risky cutover, but a tax on every
subsequent change.

**D8. Documentation split** — *Disadvantage, moderate.* The 36 planning/spike documents, the
fidelity-validation article and its generator script, and the `a2interactive.Rmd` tutorial section
would either stay behind (history without code) or be duplicated. The kinship2-fidelity article in
particular compares the *layout* to kinship2 — it belongs with the core, but it is published on
`nprcgenekeepr`'s pkgdown site.

**Summary table**

| Criterion | Direction | Weight today |
|---|---|---|
| Reuse outside project | + | low (no consumer exists) |
| Dependency-graph clarity | + | low (already nearly clean; the one wart is fixable in place) |
| `kinship()` inversion | − unless done first | medium (small change, but a prerequisite) |
| Versioning / release | − | **high** (CRAN gating of the next release) |
| Test / CI | − | **high** (fixture + preprocessing dependence; doubled CI) |
| Internal visibility | − | low (2 test calls) |
| Churn timing | − | **high** (48 % of recent `R/` commits) |
| Documentation | − | medium |

---

## 5. Refactor heuristics (`ARCHITECTURE_WORKSTREAM.md` §Refactor Heuristics)

### 5.1 Deepening

The layout core is a **deep module** by the workstream's own signal table: a 2-function public
interface (really 1 in live use) in front of ~2,800 lines of non-trivial algorithmic logic
(Walker/BJL apportioning, three-tier positioning, collision avoidance, waypoint routing), with a
small, documented `list(nodes, edges, duplicateToReal, isolatedIds)` output. Depth is the shape
you *want* at a package boundary — this is the strongest structural argument *for* eventual
extraction. It is also the reason the code is already comfortable where it is: a deep module
imposes little on its host.

### 5.2 The Deletion Test — where would the complexity go?

Mentally delete `makePedigreeDiagramData.R` + `positionTreeApportion.R`. Their work does not
*disperse* (nothing else in `R/` does any layout) and does not *concentrate at a neighbor* (the
module would not absorb 2,800 lines). It would land in a new, focused module that does not exist
yet — the workstream's third case, "the original module's name was wrong, but a deep abstraction
exists nearby." The heuristic therefore says the code is a real abstraction and its *location*
(file vs. package) is a packaging choice, not a design smell. A split moves a boundary; it does not
fix one.

### 5.3 Coupling test

"Would changes to one part require changes to another?" In the last 30 days: **every** layout
change required changes to test files, regenerated images, and `NEWS.Rmd` — and roughly one in
three touched `R/modPedigree.R` too (29 commits since June on the module vs. 49 on the core).
Today the answer is "frequently yes", which argues for keeping the two in one repository until the
fidelity work settles.

---

## 6. Recommendation (decision support — the owner decides)

**Do not split now.** The code's structure is *favourable* to a split (§5.1, §2.2), but the
present-tense costs (D4, D5, D7) are high and concrete while the present-tense benefits (D1, D2)
are low and hypothetical. The decisive fact is timing: the core is the most volatile code in the
package under a standing priority that is not yet declared done, and this project's own process
model makes cross-repository change expensive by design.

**Revisit when all three of these hold** (recorded so a future session does not re-derive them):

1. The owner has lifted the standing pedigree-fidelity priority, **and** `git log --since=<60 days
   ago> --oneline -- R/makePedigreeDiagramData.R R/positionTreeApportion.R | wc -l` is in single
   digits — i.e. the engine has been stable for two months.
2. `nprcgenekeepr`'s next CRAN release (the one that ships `visNetwork` and the Diagram tab) has
   been accepted, so a split no longer gates a release.
3. A **named** second consumer exists — a specific repository or an external request — or the
   owner decides the ecosystem argument (§2.7) is reason enough on its own.

**Optional, low-cost preparation the owner may choose to queue now** (Option D; each is its own
small TDD session and is worthwhile whether or not a split ever happens):

- D-1: invert the `kinship()` dependency in `makePedigreeMatingLayout()` — accept a precomputed
  kinship matrix or consanguinity flags (default: compute via `kinship()` as today, so no caller
  changes), making the core `visNetwork`-free **and** genetics-free.
- D-2: replace the two direct `.buildMatingUnitForest()` calls in `test_modPedigree.R:1669/:1706`
  with a test that goes through `makePedigreeMatingLayout()`'s public surface, or an exported
  accessor.
- D-3: add `@noRd` roxygen blocks to `R/positionTreeApportion.R`'s 13 functions (documentation
  hygiene; also removes the file's inconsistency with the rest of `R/`).

These are candidates for `BACKLOG.md` Housekeeping, not commitments. This session adds none of
them without the owner's say-so.

---

## 7. If a split is ever chosen — what the planning session must produce

Not a plan (FM #18/#19); a checklist of what that plan cannot omit, derived from §2. Each step is
a separate session with a rollback point, per `ARCHITECTURE_WORKSTREAM.md` §Migration Path.

| Step | Content | Rollback | Verification |
|---|---|---|---|
| 0 | Option D-1/D-2/D-3 landed in `nprcgenekeepr` first (in place, TDD) | `git revert` per step | full clean regression (`CLAUDE.md` "Clean regression read") 0 failed/0 error attributable |
| 1 | Create the new package skeleton (name TBD — check CRAN/GitHub availability then; do not decide here), MIT license, `R (>= 4.1.0)`, **no** `visNetwork`/`shiny` in `Imports` | delete repo | `R CMD check --as-cran` clean on the empty skeleton |
| 2 | Move `R/makePedigreeDiagramData.R`, `R/positionTreeApportion.R` (± `R/comparePedigreeStructure.R` with `kinship2` in `Suggests`), the 9 core test files + `helper-live-render-positions.R` + teardown test, a copy of `inst/extdata/examples/obfuscated_rhesus_mhc_ped{,_twins}.csv`, and a small example dataset replacing `examplePedigree` in both `@examples` | `git revert` in both repos | core suite green in the new package, byte-identical pinned values (§2.4 table) |
| 3 | `nprcgenekeepr`: delete the moved files, add `Imports: newpkg (>= 0.1.0)`, `importFrom(newpkg, makePedigreeMatingLayout, makePedigreeDiagramData)`, update `_pkgdown.yml:311-312`, `man/`, the 2 `test_modPedigree.R` calls, `a2interactive.Rmd`, `pedigree-diagram.qmd`, `kinship2-fidelity-validation.qmd`, `data-raw/kinship2FidelityValidation.R`, `renv.lock` | `git revert` | full regression + `shinytest2` E2E (`test-e2e-pedigree-module.R`) + `devtools::check()` 0/0/0 + all 7 workflows green |
| 4 | New package to CRAN; only then bump `nprcgenekeepr`'s floor to the released version | keep dev-only `Remotes:` until accepted | CRAN acceptance email; `R-CMD-check.yaml` green with the CRAN build |

The grep-based inventory a planning session needs is already in §2 (§8 reproduces it); the plan
must re-run it against the tree at that time, since the engine changes daily.

---

## 8. Reproducibility — the commands behind every number

1. **Coupling inventory** (forward, reverse, external origin): the R script this session wrote and
   ran, reproduced here in full so it can be re-run without the scratchpad:

   ```r
   Sys.setenv(NOT_CRAN = "true"); suppressMessages(pkgload::load_all(".", quiet = TRUE))
   ns <- asNamespace("nprcgenekeepr"); all <- ls(ns, all.names = TRUE)
   fns <- all[vapply(all, function(f) is.function(get(f, ns)), logical(1))]
   src <- vapply(fns, function(f) { s <- attr(get(f, ns), "srcref")
     if (is.null(s)) NA_character_ else basename(utils::getSrcFilename(s, TRUE)) }, "")
   core <- fns[grepl("makePedigreeDiagramData|modPedigree", src)]; other <- setdiff(fns, core)
   g <- function(f) { x <- codetools::findGlobals(get(f, ns), merge = FALSE); unique(c(x$functions, x$variables)) }
   for (f in core)  { o <- intersect(g(f), other); if (length(o)) cat(f, "->", o, "\n") }   # forward
   for (f in other) { o <- intersect(g(f), core);  if (length(o)) cat(f, "->", o, "\n") }   # reverse
   ```
2. **Sizes:** `wc -l R/*.R | sort -rn | head`; `cat R/*.R | wc -l`; `cat tests/testthat/*.R | wc -l`.
3. **Function/export listing:** `grep -n "^[.A-Za-z][A-Za-z0-9._]* *<- *function" R/makePedigreeDiagramData.R R/positionTreeApportion.R R/modPedigree.R R/comparePedigreeStructure.R` cross-referenced with the preceding `#' @export` / `#' @noRd` line.
4. **External calls per file:** `grep -c "visNetwork::" R/<file>`; `grep -oh "[A-Za-z0-9.]*::[A-Za-z0-9._]*" R/makePedigreeDiagramData.R R/modPedigree.R R/positionTreeApportion.R | sort | uniq -c`.
5. **Test coupling:** `grep -c "makePedigreeMatingLayout(\|makePedigreeDiagramData(\|\.positionMatingUnitForest(\|\.buildMatingUnitForest(\|\.addRectilinearWaypoints(\|\.resolveEdgeNodeCollisions(\|\.findIsolatedIds(\|\.positionTreeApportion(\|\.buildForestChildrenOf(\|\.buildTwinConnectorEdges(\|\.affectedColor(\|\.nameLabel(\|\.escapeHtml(" tests/testthat/*.R | grep -v ":0$"`; fixture loads: `grep -oh 'system.file("extdata", *"[^)]*' tests/testthat/test_*.R | sort | uniq -c`.
6. **Prior discussion:** `grep -rn -i "separate package\|standalone package\|its own package\|own R package\|split.*into.*package\|factor.*out.*package" docs/planning docs/research docs/audits BACKLOG.md PROJECT_LEARNINGS.md ROADMAP.md` (only `BACKLOG.md:457`, the item itself, is a real hit).
7. **Churn:** `git log --since=2026-06-01 --oneline -- R/makePedigreeDiagramData.R | wc -l` (49); `... -- R/ | wc -l` (272); `--since=2026-08-03` (41 / 86); `git log --reverse --format='%h %ad' --date=short -- R/makePedigreeDiagramData.R | head -1` (`39eb441e` 2026-07-30).
8. **Ecosystem / reuse:** CRAN pages for `kinship2`, `nprcgenekeepr`, `ggpedigree` fetched
   2026-09-02; `gh repo list rmsharp --limit 200 --json name,description,isArchived,pushedAt`;
   `gh issue view 141 --json state,closedAt`.
9. **CI:** `ls .github/workflows`; `gh run list --branch master --limit 10` (durations).

---

## 9. Scope boundary

This document does **not**: decide whether to split; pick a package name; change any code, test,
`DESCRIPTION`, or `BACKLOG.md` item beyond what the close-out records; evaluate moving the Shiny
module (ruled out on evidence, §3 B); or plan the migration (§7 is a checklist for a future
planning session, not a plan). It also does not re-open any ratified pedigree-layout design
decision — every design document under `docs/planning/pedigree-diagram-*` stands as written.
