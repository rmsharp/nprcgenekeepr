# Issue #151 Plan — Individual Mate-Pair Analysis Alongside Breeding-Group Optimization

**Status:** RATIFIED (2026-08-10, this session). All three judgment-call decisions (Q1-Q3) were ratified via a single `AskUserQuestion` round; the owner selected this document's own recommended option in all three cases, with no changes requested. See §11 for the recorded outcome. This plan is ready for Slice 1 implementation in a future session.
**Session:** S511 (2026-08-10)
**Origin:** GitHub issue #151, Tier 2 item 3 ("Ready-to-Build Medium-Priority Features") of `docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` — sequenced after #146 "to let it branch from a settled `modBreedingGroups.R` rather than run concurrently against it," and named there as needing "its own pre-RED scope decisions (exclusion granularity, which ranking criteria to expose) before RED tests can be written." Picked up this session because #146/#147/#149 (the rest of Tier 1/2) are all now shipped and closed.
**Touches (planned, future sessions):** `R/reportMatePairs.R` (new, exported), `R/modMatePair.R` (new — `modMatePairUI`/`modMatePairServer`), `R/appServer.R` (capture `modMarkerGeneticsServer()`'s currently-*discarded* `markerKinshipMatrix` return element; mount the new module), `R/appUI.R` (new navbar tab), `tests/testthat/test_reportMatePairs.R` (new), `tests/testthat/test_modMatePair.R` (new), `NEWS.Rmd` → `NEWS.md`, `vignettes/articles/colony-manager-guide.qmd` and/or the matching `vignettes/manual_components/*.Rmd` component.
**Does NOT touch:** `R/modBreedingGroups.R` — **zero shared code**, correcting the sequencing audit's own "shared-file risk" framing (§2.1); `R/filterPairs.R` / `R/filterAge.R` / `R/kinMatrix2LongForm.R` / `R/filterThreshold.R` / `R/markerKinship.R` (all consumed as-is, unmodified); `R/reportGV.R` / `R/orderReport.R` (consumed as-is via `shared$geneticValues$report`); `R/modMarkerGenetics.R` (consumed via its existing, already-implemented `markerKinshipMatrix` return element — zero change to that module's own behavior, inputs, or outputs).
**Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` — a data-flow/module-boundary decision (which existing reactives/helpers compose into a new report, how "marker kinship where available" merges with pedigree data, population-scoping for a tractable table), not a `DESIGN_WORKSTREAM.md` visual-layout question, matching the #133/#136/#137/#145/#147/#149/#146 precedent for this shape of decision.

> **Scope.** Design (not implement) a curator-facing individual mate-pair analysis workflow: enumerate eligible sex-compatible pairs after age, pedigree, and user-selected exclusions; report pedigree kinship and, where available, marker kinship, alongside each parent's genetic-value inputs; support sorting/filtering by these criteria; show exclusions (not just eligible pairs); and export a reviewable table — kept structurally and file-wise separate from group formation, per the issue's own instruction.

---

## 1. Context

### 1.1 What issue #151 says (verbatim)

> ## Source
>
> `GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`: MateRx-style per-pair analysis is partial.
>
> The package optimizes multi-animal breeding groups, but does not provide a curator-facing table of feasible individual male/female pairings ranked by genetic criteria.
>
> Design a pair-analysis workflow that enumerates eligible sex-compatible pairs after age, pedigree, and user-selected exclusions; reports pedigree and, where available, marker kinship alongside genetic-value inputs; ranks or filters pairs using selected criteria; shows exclusions; and exports a reviewable pair table without conflating it with group formation.

Confirmed verbatim via `gh issue view 151 --json title,body,comments` at this session's Phase 1 (zero comments on the issue).

### 1.2 What is already decided (do not re-litigate)

- **Priority/sequencing:** Tier 2 ("Ready-to-Build Medium-Priority Features"), item 3 of 3, sequenced deliberately after #146 (`GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` line 208-210) — #146 is now shipped and closed (issue #146, both slices, S508/S510), so that ordering constraint is satisfied.
- **This is a genuinely different capability than group formation, not an alternate view of it.** The 08-06 capability audit's own priority table (`GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-06.md` line 90) states it plainly: "Add a distinct pair-analysis workflow rather than overloading group formation." The issue's own closing clause — "without conflating it with group formation" — is not a stylistic preference; it is the scope boundary this document treats as forced (D1, §3).
- **Scope boundary named by the issue itself:** (a) enumerate eligible sex-compatible pairs after age, pedigree, and user-selected exclusions; (b) report pedigree kinship and, where available, marker kinship; (c) alongside genetic-value inputs; (d) rank/filter by selected criteria; (e) show exclusions; (f) export a reviewable table. All six are addressed in §3 below.

### 1.3 What this session's research confirmed

This session read every function in the relevant call graph directly (§2) and ran an original empirical benchmark against the bundled `examplePedigree` fixture (§2.6) — not derived from any prior document; no prior session or audit measured mate-pair table scale.

**Headline findings:**

1. **The reusable pair-eligibility pipeline already exists**, and — contrary to the sequencing audit's own "shared-file risk" flag — it lives entirely *outside* `R/modBreedingGroups.R`, in four small standalone files already composed together by `getAnimalsWithHighKinship()`: `kinMatrix2LongForm()`, `filterPairs()`, `filterAge()`, `filterThreshold()`. A new module can call these directly with zero edits to `modBreedingGroups.R`.
2. **Marker kinship is already computed by `modMarkerGeneticsServer` and already returned in its module-contract-compliant reactive list** (`markerKinshipMatrix = reactive(markerKmat())`, `R/modMarkerGenetics.R:320`) — but `R/appServer.R`'s own call site (`:435-439`) discards the entire return value; nothing captures it. Wiring "marker kinship where available" into this new feature is a one-line capture at an existing call site, not new computation, and it changes nothing about how Marker Genetics itself behaves.
3. **Population scoping before the pair-reshape matters enormously**, both for correctness and for performance, in a way the issue text does not spell out. An unscoped run — the full 3,694-row bundled `examplePedigree`, opposite-sex-only, `minAge = 1` — produced **1,744,722 candidate-pair rows in 54.0 s**. Scoping to just the 1,704 "alive" (no-`exit`-date) individuals *before* building the kinship matrix cut that to **315,023 rows in 8.6 s** — better, but still large, and for a reason that is not obvious: **`filterAge()` treats a missing age as "pass" (keep), not "exclude"** (`R/filterAge.R:26`, `(a1 >= minAge) | is.na(a1)`), and **81% of the "alive" individuals in this fixture have no recorded age at all** (1,372 of 1,704). The age filter is very nearly a no-op on real, imperfectly-curated data — an explicit population-scope control is not a nice-to-have, it is load-bearing for keeping the table both meaningful and tractable (§2.6, §7 Dragon 1).
4. **No continuous composite-score ranking precedent exists anywhere in this package for individual-level metrics.** `reportGV()`'s own `orderReport()` — the closest analogue — produces `value`/`rank` via a rule-based tier classification (imports → high-genome-uniqueness → low-mean-kinship → everything else → no-parentage), never a weighted numeric formula (§2.7). This directly informs D3/Q1's recommendation.

## 2. Evidence-based inventory

### 2.1 The reusable pair-eligibility pipeline already exists, and lives entirely outside `modBreedingGroups.R`

`R/getAnimalsWithHighKinship.R:41-59` composes exactly the eligibility pipeline the issue describes, already, for Breeding Groups' own use:

```r
kin <- kinMatrix2LongForm(kmat)
kin <- filterThreshold(kin, threshold = threshold)
kin <- filterPairs(kin, ped, ignore = ignore)   # sex-pair exclusion
kin <- filterAge(kin, ped, minAge = minAge)     # age-floor exclusion
```

Each of the four functions is its own standalone file (`R/kinMatrix2LongForm.R`, `R/filterThreshold.R`, `R/filterPairs.R`, `R/filterAge.R`) — **none is defined inside `R/modBreedingGroups.R`**, confirmed by direct read of all four files and a `grep` sweep. `filterPairs()` takes a `kin` long-format `id1`/`id2`/`kinship` data.frame plus `ped` (needs `id`/`sex`) and an `ignore` list of sex-pair vectors to drop (default `list(c(sexCodes[["female"]], sexCodes[["female"]]))`, Breeding Groups' own choice, tuned for group formation where multiple related females can coexist). `filterAge()` takes the same `kin`/`ped` shape plus a scalar `minAge`.

**This means the sequencing audit's "Shared-file risk: #146 and #151 both likely touch `R/modBreedingGroups.R`" (line 74) does not hold for #151 as scoped here.** #146 touched `modBreedingGroups.R` because it *is* the Breeding Groups feature. #151, built as its own module (D1, §3) calling these four already-exported/internal standalone functions directly, touches `modBreedingGroups.R` **not at all** — a correction to the source audit's own risk framing, in the same spirit as #136's plan correcting three premises in its own source issue.

### 2.2 `markerKinship()` — an independent, genotype-only estimator, already wired but its return value discarded

`R/markerKinship.R:64-109` (issue #130) computes a KING-robust pairwise kinship matrix directly from genotype data, independent of pedigree. `R/modMarkerGenetics.R:162-168` already wraps it in a reactive (`markerKmat`) that safely returns `NULL` — not an error — when no genotype file has been uploaded (`genotypeMatrixR()` returns `NULL` first, per `R/modMarkerGenetics.R:146-160`), matching module-contract rule 5 ("upstream absence is `req()`"). The module's own return list already exposes it: `markerKinshipMatrix = reactive(markerKmat())` (`R/modMarkerGenetics.R:320`).

`R/appServer.R:435-439` calls the module but assigns nothing:

```r
modMarkerGeneticsServer(
  "markerGenetics",
  kinshipMatrix = sharedKinshipMatrix,
  pedigree = reactive(shared$currentPedigree)
)
```

The comment directly above this call site (`R/appServer.R:430-434`) already states the module's intent in almost exactly this feature's own words: *"an independent, genotype-driven check on relatedness, alongside (not in place of) the pedigree-based kinship already computed above."* No prior session has had a second consumer for that reactive — #151 is the first. Capturing it (`markerResults <- modMarkerGeneticsServer(...)`) and threading `markerResults$markerKinshipMatrix` into the new module is additive, not a behavior change to Marker Genetics.

**Shape note:** the matrix's row/column names are the *genotyped* subset of ids only (whatever the user uploaded on the Marker Genetics tab) — typically far smaller than the full pedigree. "Marker kinship where available" for a given pair `(sireId, damId)` therefore means: if both ids are present in `dimnames(markerKmat)`, look up the value; otherwise the marker-kinship cell is `NA` — a simple membership check plus matrix indexing, not new computation, and never an error (§4).

### 2.3 `reportGV()`'s per-animal genetic-value columns — the canonical vocabulary to reuse

Confirmed by direct execution against the bundled `examplePedigree` (not read from documentation): `reportGV(...)$report` carries columns `id, sex, age, birth, exit, population, origin, sire, dam, indivMeanKin, zScores, gu, guSE, totalOffspring, livingOffspring, parentage, flagged, value, rank`. Per module-contract rule 3 ("data-frame columns use the canonical vocabulary... never a per-consumer rename"), the "genetic-value inputs" issue #151 asks for are `indivMeanKin` and `gu` (mean kinship and genome uniqueness — exactly the two axes `orderReport()` itself ranks on, §2.7), read per-parent from `shared$geneticValues$report`, keyed on `id`. No new genetic-value computation is needed; this feature is a consumer of `shared$geneticValues`, already populated for every other module that needs it (Summary Stats, Breeding Groups, Genetic Diversity).

### 2.4 Module-contract compliance requirements for the new module

`docs/architecture/module-contract.md`: `modMatePairUI(id)` returns a `tagList`; `modMatePairServer(id, <named reactive args>)` returns a named list of reactives over the stable vocabulary (`pedigree`, `kinship`, `errors`, `isReady` are the canonical names where applicable — this module returns a new pair table, which is not yet a named concept in the vocabulary and should be named plainly, e.g. `pairs`/`excluded`, §4). Every server argument that carries data must be a `reactive()` (rule 1); every returned element must be a `reactive()` (rule 2); a blanket `tryCatch(..., error = function(e) NULL)` at the module seam is forbidden — upstream malformedness must surface (rule 5). `modInput` (`R/modInput.R`) is the reference implementation to consult when writing the new module.

### 2.5 `modBreedingGroups.R`'s established UI conventions — the precedent to *mirror*, not the file to *touch*

Read in full (`R/modBreedingGroups.R:1-140`, plus the Group Detail tab further down). Relevant, reusable conventions for the new module's own UI (a sibling, not an extension):

- **Scalar breeding-age floor:** `numericInput(ns("minAge"), "Minimum breeding age (years):", value = 1L, min = 0L, max = 40L, step = 0.1)` — Breeding Groups' own established age-eligibility control, backed by `filterAge()`'s simple scalar `minAge` (not `getPotentialParents()`'s richer per-species/sex breeding-age + gestation-window machinery, which screens *retrospective* candidate-parent eligibility for an already-existing animal, a different question than *prospective* pairing eligibility). This is the natural reuse target (§3 D2).
- **Textarea-based exclusion list:** `checkboxInput(ns("seedGroups"), "Seed groups with specific animals", value = FALSE)` + `uiOutput(ns("seedTextareas"))` — the established pattern for "let the user paste/type a list of specific animal IDs" in this app. The natural precedent for a user-supplied pair-analysis exclude-list (§3 D4).
- **`DT::DTOutput`/`DT::renderDT` for scored tables, `downloadButton`/`downloadHandler` for CSV export** — used throughout (`groupMemberTable`, `groupKinTable`, `downloadGroup`, `downloadGroupKin`) and in `modMarkerGenetics.R`'s five tabs. The established table+export convention this feature reuses verbatim, not reinvents.

### 2.6 Empirical benchmark: population scoping and `filterAge()`'s NA-passes semantics (this session's original measurement)

Run against the bundled `examplePedigree` (3,694 total animals) via `qcStudbook()` + `kinship()`, `pkgload::load_all()`, real execution (not estimated):

| Scenario | Candidate pairs (M×F, opposite-sex only) | Wall time |
|---|---:|---:|
| Full pedigree (3,694 ids), no population scope, `minAge = 1` | 1,744,722 | 54.0 s |
| Scoped to "alive" (no `exit` date, 1,704 ids) via `filterKinMatrix()` *before* the reshape, `minAge = 1` | 315,023 | 8.6 s |
| Naive `M × F` count among "alive" ids with `age ≥ 1` (age present *and* passes) | 25,707 | — (illustrative only) |

The third row is the number of pairs that would exist if `filterAge()`'s age screen were actually exclusionary for missing data — it is not (row 2's 315,023 far exceeds it), because **1,372 of the 1,704 "alive" individuals (81%) have no recorded `age` at all**, and `R/filterAge.R:26`'s `(a1 >= minAge) | is.na(a1)` explicitly keeps an `NA`-age individual rather than dropping it. This is documented, pre-existing, correct-as-designed behavior (Breeding Groups relies on the same semantics) — not a bug to fix here — but it means **age alone cannot be relied on to bound this feature's table size**, a genuine architectural finding this design must answer (§3 D4, §7 Dragon 1).

`filterKinMatrix(ids, kmat)` (`R/filterKinMatrix.R:26-28`) — a one-line subsetting helper already used by `reportGV()` itself to scope its kinship matrix to the population of interest — is the mechanism that produced row 2's improvement: scope the *matrix* to the relevant population before `kinMatrix2LongForm()` reshapes it to long form, not filter the long-form pairs after the fact. This is the direct precedent for D4's recommended population-scope control.

### 2.7 No composite-score ranking precedent exists in this package

`R/orderReport.R` (`reportGV()`'s own ranking logic) produces its `value`/`rank` columns via a **rule-based tier classification** — imports, then high-genome-uniqueness (`gu > guCutoff`), then low-mean-kinship (`zScores <= zScoreCutoff`), then everything else, then no-parentage — never a weighted blend of `gu` and `zScores` into one continuous number. `modBreedingGroups.R`'s own "candidate comparison" table (§2.5) likewise presents raw per-candidate metrics for the curator to sort/compare, not a single invented score. Confirmed by direct read of `R/orderReport.R` in full — no `*` or `+` combination of `gu` and `zScores`/`indivMeanKin` exists anywhere in it. This is the grounding evidence behind D3/Q3's recommendation against inventing a first-of-its-kind composite mate-pair score.

### 2.8 `appUI.R` navbar-tab mounting convention

Every existing module is mounted identically (`R/appUI.R:226-266`): `tabPanel("<Display Name>", icon = icon("<fa-icon>"), mod<X>UI("<id>"))`, inside the top-level `navbarPage(...)` call, in file order matching the navbar's left-to-right order. The natural insertion point is directly after the "Breeding Groups" tab (`:226-230`) and before "Genetic Diversity" (`:235-239`), keeping the two breeding-decision-support tabs adjacent without merging them — reinforcing D1's "distinct but neighboring" framing rather than literally combining the two.

## 3. Design decisions

**D1 — Module boundary (forced).** A new, standalone `modMatePairUI`/`modMatePairServer` pair in a new file `R/modMatePair.R`, mounted as its own navbar tab — not a new sub-tab inside `modBreedingGroups.R`, and not folded into `modMarkerGenetics.R`. Forced by (a) the issue's own explicit closing instruction ("without conflating it with group formation"), (b) the capability audit's own table entry ("a distinct pair-analysis workflow rather than overloading group formation"), (c) §2.1's finding that the reusable pipeline lives entirely outside `modBreedingGroups.R`, so nothing is actually shared at the file level, and (d) the established one-capability-one-module precedent (#133/#136/#137/#149, each its own tab).

**D2 — Eligibility screen composition (forced, evidence-grounded).** Opposite-sex-only pairs via `filterPairs(kin, ped, ignore = list(c(sexCodes[["male"]], sexCodes[["male"]]), c(sexCodes[["female"]], sexCodes[["female"]])))` (both same-sex combinations excluded — a mate pair is definitionally opposite-sex; this is a structural requirement of the feature, not a user-configurable option) composed with `filterAge(kin, ped, minAge = <user input>)`, mirroring Breeding Groups' own scalar `minAge` convention (§2.5) rather than `getPotentialParents()`'s richer per-species/sex + gestation machinery (a different, retrospective question — see §2.5's rationale). Uses `sexCodes[["male"]]`/`sexCodes[["female"]]` (`R/sexCodes.R:13`), not raw `"M"`/`"F"` literals, per the already-completed XARCH-4 sex-code-centralization architecture fix (`BACKLOG.md` Architecture follow-ups, S367) — a real regression this design must not reintroduce.

**D3/Q1 — Ranking: raw sortable columns, no invented composite score.** See §11 Q1 (genuine judgment call, though this document has a clear recommendation grounded in §2.7).

**D4/Q2 — Population-scope control before the pair-reshape.** See §11 Q2 (genuine judgment call, directly answering §2.6's benchmark finding).

**D5/Q3 — Exclusion transparency mechanism.** See §11 Q3 (genuine judgment call).

**D6 — Marker-kinship wiring (forced, low-risk but changes an existing call site).** `R/appServer.R`'s `modMarkerGeneticsServer("markerGenetics", ...)` call is captured into a variable (e.g. `markerResults <- modMarkerGeneticsServer(...)`) and `markerResults$markerKinshipMatrix` is threaded into the new module, exactly as `gvResults`/`bgResults` already are for Genetic Value/Breeding Groups (§2.2). This is additive — zero behavior change to Marker Genetics itself — but it is a real edit to an existing, shipped call site, so it is named as its own decision rather than folded silently into "new module wiring," and its own regression test (Marker Genetics' existing test suite passes unchanged) is a named DONE criterion (§5).

**D7 — Return-shape and column vocabulary (forced by module-contract rule 3, §2.4).** The new function's output re-uses `indivMeanKin`/`gu` verbatim from `shared$geneticValues$report` (§2.3) for each parent — never renamed per-consumer (e.g. not `sireKinship`/`damUniqueness`, but `sireIndivMeanKin`/`sireGu`/`damIndivMeanKin`/`damGu`, keeping the canonical root name and only prefixing which parent it belongs to).

**D8 — Export format (forced by precedent, §2.5).** CSV via `downloadButton`/`downloadHandler`, matching every other module's export convention verbatim. No new export format under consideration.

## 4. Interface catalog

| Interface | Input | Output | Error contract | Consumers |
|---|---|---|---|---|
| `reportMatePairs()` (new, exported) | `ped` (standard `id`/`sire`/`dam`/`sex`/`age`/`exit`/`gen` pedigree shape), `kmat` (pedigree kinship matrix, e.g. `shared$currentPedigree`'s `sharedKinshipMatrix`), `markerKmat` (optional, `NULL`-safe, the genotype-only KING matrix), `geneticValues` (optional, `NULL`-safe, `reportGV()`'s `$report`), `minAge` (scalar, D2), `populationIds` (character vector — the D4 population scope, applied via `filterKinMatrix()` *before* the reshape, §2.6), `exclude` (character vector of user-supplied ids to drop entirely, D5) | A list with two data.frames: `pairs` (one row per eligible opposite-sex pair surviving every screen: `sireId, damId, kinship, markerKinship [NA if unavailable], sireIndivMeanKin, sireGu, damIndivMeanKin, damGu`) and `excluded` (one row per pair/individual dropped, with a `reason` column — `"same sex"` is structurally impossible to reach given D2's `ignore` list, so realistic reasons are `"under minimum age"`, `"user-excluded"`, and any upstream `NA`-sex/missing-data case) | Errors loudly on a malformed `ped`/`kmat` shape (matching every sibling function's precedent, e.g. `markerParentageExclusion()`); a pair missing marker data is `NA` in `markerKinship`, never dropped or erroring; an empty `populationIds` (zero eligible individuals) returns a zero-row `pairs` frame with the full column shape, not an error | `R/modMatePair.R` (Slice 2); script-callable directly, matching every sibling design's own script-first precedent |
| `modMatePairUI(id)` / `modMatePairServer(id, pedigree, kinshipMatrix, markerKinshipMatrix, geneticValues)` (new Shiny module) | Reactives per module-contract rule 1 | A named list of reactives (module-contract rule 2) — at minimum `pairs`, `excluded`, `isReady` | Upstream absence (`req()`); a genuinely malformed upload/shape surfaces, not silently swallowed (rule 5) | `R/appServer.R`, `R/appUI.R` |
| `R/appServer.R`'s `modMarkerGeneticsServer(...)` call site (existing — modified) | *(unchanged)* | Now captured into `markerResults`; `markerResults$markerKinshipMatrix` threaded to the new module | *(unchanged — no behavior change to Marker Genetics)* | The new module (first-ever consumer) |

## 5. Implementation plan — vertical slices (one session each)

```
Slice 1 (core function: reportMatePairs(), population-scoping helper reuse, pair-eligibility
         composition, exclusion-reason reporting, no-marker-data-yet / no-genotype-yet NULL
         handling, report-only contract test)
  `-- Slice 2 (UI: new modMatePair.R tab, appServer.R marker-kinship capture (D6), appUI.R
               mount, citation N/A (no new statistic — see §9), NEWS.Rmd, tutorial/article
               documentation)
```

### Slice 1 — Core statistical/reporting function

**Scope:** `R/reportMatePairs.R` (new, exported, D2/D3/D7/D8's interface, §4). Script-callable only — no Shiny UI. `minLoci`-style low-power gating is not applicable here (this is a kinship *report*, not a likelihood assignment — no analogue to #147's Dragon 1/2 exists).

**What does NOT change:** `R/filterPairs.R`, `R/filterAge.R`, `R/kinMatrix2LongForm.R`, `R/filterThreshold.R`, `R/filterKinMatrix.R`, `R/markerKinship.R`, `R/reportGV.R`, `R/orderReport.R` — all consumed as-is, unmodified (confirmed by this plan's own §2 inventory). `R/modBreedingGroups.R` — untouched (§2.1).

**Files to touch:**
- `R/reportMatePairs.R` (new) — the core function, D2/D3/D7/D8.
- `tests/testthat/test_reportMatePairs.R` (new) — eligibility composition (opposite-sex-only via `sexCodes`, D2); the D4 population-scope parameter actually bounds output size (a direct regression test reproducing §2.6's benchmark finding at small scale — full pedigree vs. scoped, asserting the scoped result is a strict subset); `markerKinship` correctly `NA` when a pair lacks genotype data and correctly populated when both ids are genotyped (a hand-verified fixture); `sireIndivMeanKin`/`damGu`-style column presence and correct per-id lookup from a `geneticValues$report` fixture; the `excluded` frame's `reason` column for an under-age case and a user-`exclude`d case; a `NULL`-`markerKmat`/`NULL`-`geneticValues` graceful-degradation case (columns present, all `NA`, no error) — mirrors modMarkerGenetics' own established "not yet uploaded" NULL contract (§2.2).

**RED:** all unit tests above, written against a function that doesn't exist yet; confirm failures are genuinely "could not find function" / assertion mismatches, not setup/typo errors.

**GREEN:** implement exactly enough to pass — the eligibility composition, exclusion-reason reporting, marker/GV column merge. No UI.

**DONE looks like:** `reportMatePairs()` correctly composes the existing eligibility pipeline (§2.1) with zero behavior change to any function it calls; the population-scope parameter measurably bounds output size on a real fixture, closing the loop on §2.6's own benchmark finding; `NULL` `markerKmat`/`geneticValues` degrade gracefully (never an error); `devtools::check()` 0 errors/0 warnings; full clean regression read shows no new failures.

**Verify:** targeted test file run; full clean regression read; full `devtools::check()`; `lintr::lint_package()` on touched files.

**Session boundary:** one session. Close out when Slice 1's DONE criteria are met. Slice 2 is a separate future session.

### Slice 2 — UI, appServer wiring, and documentation

**Scope:** `R/modMatePair.R` (new — `modMatePairUI`/`modMatePairServer`, module-contract-compliant, §2.4), mounted in `R/appUI.R` directly after the Breeding Groups tab (§2.8) and wired in `R/appServer.R` — including capturing `modMarkerGeneticsServer`'s previously-discarded return value (D6) and threading `pedigree`/`kinshipMatrix`/`geneticValues`/`markerKinshipMatrix` into the new module, matching every sibling module's `shared$...`-reactive wiring pattern. UI: the D4-ratified population-scope radio control, `minAge` numeric input (§2.5), a D5-ratified exclude-list textarea (§2.5), a sortable/filterable `DT::DTOutput` "Eligible Pairs" table plus a separate D5-ratified `DT::DTOutput` "Excluded" table with its `reason` column, and a `downloadButton` CSV export (D8) — `DT::renderDT(..., server = TRUE)` given §2.6's real row-count findings.

**What does NOT change:** `reportMatePairs()`'s own signature or behavior (Slice 1 is complete and stable before Slice 2 begins); Marker Genetics' own tabs/behavior (D6 is additive-only, proven by its own regression test).

**Files to touch:**
- `R/modMatePair.R` (new) — UI + Server.
- `R/appServer.R` — capture `modMarkerGeneticsServer()`'s return (D6); mount the new module.
- `R/appUI.R` — new tab (§2.8).
- `tests/testthat/test_modMatePair.R` (new) — module renders; reactive calls `reportMatePairs()` correctly with real (unmocked) upstream reactives per the established `testServer` convention (`tests/testthat/test_modBreedingGroups_groupAddAssign.R`'s mocked-terminal-call-only pattern — only `reportMatePairs()` itself mocked where a test needs to isolate wiring from computation); absent marker-genotype data renders a valid table with an all-`NA`/"not available" marker-kinship column, not an error.
- `tests/testthat/test_appServer.R` / `tests/testthat/test_modMarkerGenetics.R` (existing) — confirm D6's capture is behavior-preserving: Marker Genetics' own existing assertions pass unchanged.
- `NEWS.Rmd` → re-rendered `NEWS.md`.
- `vignettes/articles/colony-manager-guide.qmd` and/or `vignettes/manual_components/*.Rmd`.

**DONE looks like:** the new tab renders a sortable/filterable eligible-pairs table and a separate excluded-pairs table (with reasons) against a live pedigree, with marker kinship populated when a genotype file has been uploaded on the Marker Genetics tab and gracefully absent when not; a live `shinytest2`/`chromote` smoke test confirms real, correctly-computed values with zero console errors, **and specifically confirms Marker Genetics' own tabs still render and compute correctly after the D6 wiring change** (the one live-risk this slice introduces to already-shipped behavior); CSV export downloads a file matching the displayed (filtered/sorted) table; documentation present in the same session's close-out; `gh issue close 151` in this session, citing the `CHANGELOG.md` entry.

**Verify:** targeted test file runs; full clean regression read; full `devtools::check()`; live `shinytest2`/`chromote` E2E smoke test (including the Marker Genetics regression check above); `lintr::lint_package()` on touched files.

**Session boundary:** one session, separate from Slice 1.

---

## 6. Impact analysis

**Blast radius is small and additive for the core function (Slice 1); Slice 2's UI addition plus the D6 `appServer.R` capture is the larger surface, but D6 itself is a one-line, behavior-preserving change proven by its own regression test.** No existing exported function's signature or documented behavior changes. `R/modBreedingGroups.R` is untouched in both slices (§2.1) — a smaller footprint than the sequencing audit's own "shared-file risk" flag anticipated.

**Performance:** directly informed by §2.6's real benchmark, not assumed. A full-colony, unscoped run is measurably too large (54 s / 1.7M rows on the bundled fixture) to be the default; the D4-ratified population-scope control plus `filterKinMatrix()`-before-reshape (§2.6) plus `DT::renderDT(server = TRUE)` (§5) together are this design's direct, evidence-grounded answer — not a speculative concern.

**Backward compatibility:** trivially preserved for Slice 1 (pure addition). Slice 2's one edit to an existing call site (D6) is additive by construction (capturing a return value that was previously discarded changes nothing about what that return value contains or how it is computed) and is directly regression-tested.

**Close-out checklists triggered** (`CLAUDE.md`): NEWS.Rmd entry required at both slices (new exported function at Slice 1, new UI control at Slice 2); tutorial/article documentation checklist applies at Slice 2; `a2interactive.Rmd` checklist is deferred per its own standing rule; citation checklist (#120) is **N/A** — this feature reports existing, already-cited statistics (`kinship()`, `markerKinship()`'s KING-robust estimator, `reportGV()`'s `indivMeanKin`/`gu`) and introduces no new displayed statistic or estimator of its own (§9); lint on touched files each slice; a `CHANGELOG.md` `[issue #151]`-tagged entry each slice; `gh issue close 151` at Slice 2's close-out.

---

## 7. Here be dragons

1. **`filterAge()`'s NA-passes-the-filter semantics means the age control cannot, by itself, bound table size** (§2.6) — a real, measured finding (81% of "alive" `examplePedigree` individuals have no recorded age), not a hypothetical. The D4-ratified population-scope control is this design's direct answer; the implementing session must not treat `minAge` alone as sufficient population control, and RED tests must exercise a case where most candidates have `NA` age to prove the scope control (not the age filter) is what bounds the result.
2. **A demographically-eligible opposite-sex pair with very high pedigree kinship (parent-offspring, full siblings) is not specially flagged or hidden by this design — it is simply visible with a high `kinship` value in the sortable table**, exactly like every other pair. This is intentional (kinship *is* the signal a curator uses to avoid such a pairing; no separate "is this incestuous" boolean is proposed) but should be stated explicitly in the module's own UI guidance text so a curator does not mistake "appears in the table" for "recommended."
3. **`markerKinship()`'s KING-robust estimator can return a negative value** (documented in its own roxygen, `R/markerKinship.R:24-26`, "more divergent ancestry than the reference sample, not an error") and can return `NA` per-pair when neither individual has a shared heterozygous locus (`R/markerKinship.R:96-100`, with its own `warning()`). Both must render sensibly in the new table (a negative number is a valid, meaningful value; `NA` must read as "undetermined," not "0" or a blank that looks like zero kinship) — the implementing session's RED tests must cover both.
4. **`DT::renderDT(server = TRUE)` changes the sort/filter contract** (sorting happens server-side, not on the full client-side dataset) — any client-side sort/filter UI copy must not imply otherwise, and the CSV export (D8) must export the *filtered* result set the curator is looking at, not the unfiltered full table, matching the principle-of-least-surprise every other export in this app already follows.
5. **The "excluded" table's `reason` column must stay a closed, enumerable vocabulary** (`"under minimum age"`, `"user-excluded"`, plus whatever D5's ratified mechanism adds) — an open-ended free-text reason would be harder to filter/summarize and harder to test exhaustively than a small closed set.
6. **A colony with very few eligible individuals after scoping (e.g., 0 males or 0 females survive the population-scope + age screen) must render a clear, non-crashing empty state**, not a zero-row DT table with no explanation — `calculateSexRatio()`'s own existing "no males"/"no females" handling (`R/calculateSexRatio.R:81`) is a precedent worth reading before Slice 2's UI copy is written.

---

## 8. Alternatives considered

| Decision | Recommended | Rejected alternative(s) | Why rejected |
|---|---|---|---|
| D1 module boundary | New standalone `modMatePairUI`/`modMatePairServer`, own tab | A new sub-tab inside `modBreedingGroups.R`'s existing `tabsetPanel` | Directly contradicts the issue's own "without conflating it with group formation" instruction; §2.1 shows there is no shared-file reason to co-locate them either |
| D2 eligibility screen | `filterPairs()` (opposite-sex-only) + `filterAge()` (scalar `minAge`), Breeding Groups' own convention | `getPotentialParents()`'s per-species/sex breeding-age + gestation-window screen | Answers a different question (retrospective: "who could have produced this already-existing animal") than this feature's prospective "who is eligible to be paired going forward"; would also silently diverge from Breeding Groups' own sibling age-eligibility convention |
| D3/Q1 ranking | Raw sortable/filterable columns, no composite score | A single blended "compatibility score" | No precedent anywhere in the package (§2.7); would be this package's first-ever unvalidated cross-metric weighted formula, the exact risk class `markerFst()`'s own wrong-formula incident warns against |
| D4 population scope | A required, explicit population-scope control before the reshape | Rely on `minAge` alone to bound the table | §2.6's own benchmark directly disproves this — `minAge` is nearly a no-op when age data is 81% missing |
| D6 marker-kinship source | Capture and reuse `modMarkerGeneticsServer`'s existing, already-computed, already-tested `markerKinshipMatrix` reactive | Give the new module its own separate genotype-file upload | Would duplicate an upload UI and a computation that already exists and is already the single source of truth for marker kinship elsewhere in the app; violates DRY for no benefit |

---

## 9. Close-out checklist mapping

1. **Citation checklist (issue #120)** — **N/A.** No new displayed statistic or estimator is introduced; `kinship()`, `markerKinship()` (already cited, `R/markerKinship.R:45-48`), and `reportGV()`'s `indivMeanKin`/`gu` (already cited/documented) are consumed as-is.
2. **Tutorial/article documentation checklist (Session 436)** — applies at Slice 2 (new Shiny tab/control); `vignettes/articles/colony-manager-guide.qmd` and/or the matching `vignettes/manual_components/*.Rmd` component.
3. **NEWS.Rmd entry checklist (Session 448)** — applies at Slice 1 (new exported function `reportMatePairs()`) and again at Slice 2 (new UI control).
4. **`a2interactive.Rmd` script-callable-function checklist (Session 450/478)** — deferred, not same-session, per its own standing rule; a future dedicated documentation pass once the feature has stabilized.
5. **`_pkgdown.yml` reference-coverage checklist (Learning 495/506)** — applies at Slice 1: `reportMatePairs()` must be added to a `_pkgdown.yml` reference group in the same session it ships (the "All exposed functions" catch-all satisfies the guard test absent a more specific curated group).
6. **GitHub issue close-out checklist** — `gh issue close 151 --reason completed --comment "..."` citing the `CHANGELOG.md` entry and verification evidence, at Slice 2's own close-out (the final planned slice).
7. **Lint close-out checklist** — `lintr::lint_package()` on touched files, each slice.
8. **CHANGELOG.md ledger-format resolution (Session 325)** — each slice's own close-out prepends a dated `### YYYY-MM-DD · [issue #151] ...` entry above `## Legacy history`.

---

## 10. Provenance

This document is grounded in a direct read of every function, module, and app-wiring call site it cites (§2), not a summary reconstructed from memory — six files were read in full (`R/filterPairs.R`, `R/filterAge.R`, `R/kinMatrix2LongForm.R`, `R/filterThreshold.R`, `R/getAnimalsWithHighKinship.R`, `R/markerKinship.R`), three more were read for their relevant sections (`R/reportGV.R`/`R/orderReport.R`, `R/modMarkerGenetics.R`, `R/modBreedingGroups.R`, `R/appServer.R`, `R/appUI.R`), and `docs/architecture/module-contract.md` and both prior sequencing audits were re-read for this session rather than recalled from earlier orientation. §2.6's benchmark (population-scoping and `filterAge()`'s NA-passes semantics) is an original measurement taken this session against the bundled `examplePedigree` fixture via `pkgload::load_all()` and real function calls — not derived from any prior document, matching the established "verify assumptions, don't guess" discipline this project's own #146 plan (S507) set with its own original combinatorial-search benchmark.

No `PROJECT_LEARNINGS.md` entries exist yet specific to mate-pair analysis or `reportMatePairs()` (confirmed by `grep` for "mate-pair," "MateRx," and "reportMatePairs" — only this issue's own prior audit/sequencing mentions, §1). This document is the first substantive design work on #151's actual topic.

---

## 11. Ratification status — forced vs. judgment-call decisions

**Forced by the evidence (no real choice, not put to a vote):** D1 (module boundary — issue's own explicit instruction plus §2.1's zero-shared-file finding), D2 (eligibility-screen composition — direct reuse of an existing, precedent-matching pipeline, with the sex-code-literal-centralization constraint already settled by XARCH-4), D6 (marker-kinship wiring — reuse-discipline finding, additive and regression-tested), D7 (return-shape/column vocabulary — module-contract rule 3), D8 (export format — universal precedent).

**Genuine judgment calls requiring an `AskUserQuestion` ratification round:**

**Q1 (D3) — Ranking: raw sortable columns, or a computed composite score?**
- **Option A — No invented composite score; a `DT` sortable/filterable table over raw columns** (`kinship`, `markerKinship`, each parent's `indivMeanKin`/`gu`). *(This document's recommendation — matches every existing ranking precedent in the package, §2.7; avoids inventing this package's first-ever unvalidated cross-metric weighted formula.)*
- **Option B — A single blended numeric "compatibility score"** combining pedigree kinship, marker kinship (where available), and mean parental kinship/genome uniqueness into one rank-by number. *(More directly satisfies the issue's literal "ranks... pairs" wording in one column, but introduces an unprecedented, unvalidated formula with no citable weighting scheme — a real correctness/credibility risk given this project's own `markerFst()` wrong-formula history.)*

**Q2 (D4) — What should the module's default candidate population be?**
- **Option A — A required, explicit population-scope control** (radio: "All alive [no recorded exit date]" / "Top ranked by genetic value" / "Upload list," mirroring Breeding Groups' own `animalSource` convention), applied via `filterKinMatrix()` *before* the pair-reshape, plus `DT::renderDT(server = TRUE)` for whatever remains. *(This document's recommendation — directly answers §2.6's benchmark: bounds both correctness — no long-dead founders in a prospective mate-pair table — and performance.)*
- **Option B — No population-scope control; always operate on the full "alive" (no-exit-date) pedigree**, relying solely on server-side `DT` pagination to keep the browser responsive. *(Simpler UI, but ships a 315,000-row backend computation by default on real colony-scale data, per §2.6's own measurement — and still includes any long-retired-but-not-marked-exited individuals.)*
- **Option C — A fixed top-N-by-genetic-value cap, with no "all available" escape hatch at all.** *(Simplest and safest performance-wise, but removes a legitimate curator use case — deliberately reviewing the complete eligible pool — that Option A preserves as a selectable choice.)*

**Q3 (D5) — Exclusion mechanism and transparency?**
- **Option A — Two-part transparency:** (1) automatic exclusions (under-age, sex-mismatch structurally impossible per D2) computed by the same screen and shown in a **separate "Excluded" table with a `reason` column**, not silently dropped; (2) a user-supplied exclude-list **textarea**, mirroring Breeding Groups' own "Seed groups with specific animals" convention (§2.5). *(This document's recommendation — directly satisfies the issue's explicit "shows exclusions" requirement and reuses an established UI pattern verbatim.)*
- **Option B — Automatic exclusions applied silently (not shown in a separate table), plus the same textarea exclude-list.** *(Simpler UI surface, but does not satisfy "shows exclusions" as written in the issue.)*
- **Option C — A per-row interactive "exclude" checkbox directly inside the main pairs table** (persisted in reactive state), instead of a separate textarea. *(A richer, more discoverable interaction, but introduces this package's first stateful per-row table-interaction pattern, with no existing precedent to build on or test against.)*

Until Q1-Q3 are answered via `AskUserQuestion` (or the owner's plain-language equivalent), this document remains a **draft proposal**, not a ratified plan.

### Ratification outcome (2026-08-10, this session)

All three questions were posed via a single `AskUserQuestion` call. The owner selected **this document's own recommended option in all three cases, with no changes requested**:

- **Q1 (D3):** Option A — raw sortable/filterable columns (`kinship`, `markerKinship`, per-parent `indivMeanKin`/`gu`); no invented composite score. **RATIFIED.**
- **Q2 (D4):** Option A — a required, explicit population-scope control (radio: All alive / Top ranked by genetic value / Upload list, mirroring Breeding Groups' own `animalSource` convention), applied via `filterKinMatrix()` before the pair-reshape, plus `DT::renderDT(server = TRUE)`. **RATIFIED.**
- **Q3 (D5):** Option A — a separate "Excluded" table with a `reason` column for automatic exclusions, plus a user-supplied exclude-list textarea mirroring Breeding Groups' own "seed groups" convention. **RATIFIED.**

This plan is now **RATIFIED** in full (all forced decisions D1/D2/D6/D7/D8 plus all three judgment calls D3/D4/D5). Implementation begins with Slice 1 in a future session, per the vertical-slice plan in §5. This document itself changes no `R/`, `tests/`, or `man/` content — ratification closes the *design* session, not an implementation one, matching the #133/#136/#137/#147/#149/#146 precedent.
