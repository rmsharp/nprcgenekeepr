# Issue #112 — Genetic Diversity Dashboard: Design & Implementation Plan

**Issue:** #112 "finish development of the genetic diversity heatmap or dashboard" (enhancement)
**Authored:** Session 279 (2026-07-05)
**Status:** DRAFT plan (design deliverable). **No code written.** Implementation happens in the separate, per-slice sessions defined in §7. Owner-ratification points are marked **[RATIFY]**.
**Package version:** 2.0.0 (archived on CRAN 2025-07-29).

---

## 1. Executive summary

The meeting notes describe a **"Genetic Diversity Graphic"**: a red/yellow/green stoplight **heat map** with **breeding groups as rows** and **five genetic-diversity metrics as columns**, each cell colored to flag a problem (red) or a healthy condition (green). Its purpose is to let colony managers spot breeding-group problems proactively.

The feature is **partially built and then abandoned**, not greenfield:

- **3 of the 5 columns already have working, individually-tested data-provider functions** (`getProportionLow`, `getIndianOriginStatus`, `getProductionStatus`) that each return a `colorIndex` ∈ {1,2,3}. Each has a live unit test but **no production/app caller** — the only code that would call them (a renderer) is the commented-out `test_makeGeneticDiversityDashboard.R`.
- **1 column (Inbreeding / kinship-with-male) has no provider but is buildable** from the exported `kinship()` function plus demographics.
- **1 column (Flags / genotype-phenotype) has no provider and no data source** in the package. It should be **deferred** from the first working version.
- The original renderer (`R/makeGeneticDiversityDashboard.R`) is **dead, commented-out, build-ignored** code using `heatmap.2` (from `gplots`) to write a PNG file. `gplots` is **not** a dependency; `ggplot2` **is**. Recommendation is to replace it with a `ggplot2::geom_tile` heatmap that renders inside Shiny (no new dependency, no file I/O).

**This is a multi-session feature.** Building it end-to-end in one session would be horizontal slicing (SESSION_RUNNER failure mode #25). §7 decomposes it into 4 vertical slices (each an independently-useful, strict-TDD session) plus 1 deferred column.

---

## 2. The specification (from the meeting notes)

Source: `inst/extdata/meeting_notes.qmd`. The graphic is named at `:424` ("Genetic Diversity Graphic"); it is a heat map for genetic diversity reporting (`:442-445`, the 20190810 ad hoc meeting existed to clarify heat-map development). Rows are breeding groups with labels down the left (`:426`, `:432`); column headers sit across the top at 45° (`:433`). The column label→field mapping was discussed under the 20190826 header (`:426-431`) with the labels marked done 20190908 (`:425`); the per-cell RED/YELLOW/GREEN thresholds were defined 20190810 (`:449-492`). In every column **red marks the problem condition and green the healthy one.** Note `:434` ("Genetic Diversity - Genetic Diversity Report") names the graphic's title and its containing report — **not** a sixth metric column (both the dead renderer's headings and the 20190810 notes define exactly five metrics); it bears on naming, see §5 D3.

| # | Column (display / source) | Metric | Red (problem) | Yellow | Green (healthy) |
|---|---|---|---|---|---|
| 1 | **Value** / High-Low | Proportion of **Low** genetic-value breeding-age adults in the group | > 0.5 | 0.30–0.50 | < 0.30 |
| 2 | **Origin** / Indian Origin | Non-Indian ancestry among members | ≥ 1 hybrid or Chinese | ≥ 1 borderline & 0 hybrid/Chinese | 0 hybrid/Chinese & 0 borderline |
| 3 | **Production** / Fecundity | Births living >30 d ÷ dams (females ≥ 3 yr) | *housing-dependent* (see below) | | |
| 4 | **Inbreeding** / Kinship With Male | % of females ≥ 3 yr with kinship ≤ 0.0156 to ≥ 1 male ≥ 5 yr in group | < 0.6 | 0.6–0.9 | > 0.9 |
| 5 | **Flags** / Genotype Phenotype | Count of members flagged for genotype/phenotype | ≥ 3 | 1–2 | 0 |

**Production thresholds by housing** (20190810, `:481-487`): shelter/pens — red <0.6, yellow 0.6–0.63, green >0.63; corrals — red <0.5, yellow 0.5–0.53, green >0.53.

> **Spec conflict (Production):** a later meeting (20190916, `:364-383`) re-defined Production with a different formula (fixed-date 2017–2018 birth window, dams born on/before 2016-09-09) **and** different thresholds (shelter 0.51/0.54, corral 0.61/0.65). The shipped `getProductionStatus()` uses the **20190810 thresholds**, so the code has already de-facto chosen 20190810. See §5 D7 and §6 Q1.

---

## 3. Evidence-based inventory (verified this session)

All line numbers verified by direct read/grep during Session 279.

### 3.1 Dead renderer + its test (to be replaced)
- `R/makeGeneticDiversityDashboard.R` — 54 lines, **entirely commented out** (`:10-53`): an unqualified `heatmap.2(...)` call (`:32`, resolving to `gplots` via an attached library — no `gplots::` prefix in the source) writing a PNG (`grDevices::png`, `:27`) of a group × dimension matrix, palette `colorRampPalette(c("red","yellow","green"))` (`:12`), headings `c("Breeding Group","Value","Origin","Production","Inbreeding","Flags")` (`:14`). `@noRd`, not exported.
- `.Rbuildignore:21` → `^R/makeGeneticDiversityDashboard\.R$` — **excluded from the built package.**
- `tests/testthat/test_makeGeneticDiversityDashboard.R` — 28 lines, **entirely commented out**; models the intended input (one row per `Group_`/`Corral_`, columns of `colorIndex` from the 3 helpers).

### 3.2 Data providers (Columns 1–3): built + tested, but orphaned
| Helper | File | Returns | Live test | Callers in live code |
|---|---|---|---|---|
| `getProportionLow(geneticValues)` | `R/getProportionLow.R:15` | `list(proportion, color, colorIndex)` | `tests/testthat/test_getProportionLow.R` | **none** (only the dead test) |
| `getIndianOriginStatus(origin)` | `R/getIndianOriginStatus.R:18` | `list(ancestry, color, colorIndex)` | `tests/testthat/test_getIndianOriginStatus.R` | **none** |
| `getProductionStatus(ped, minParentAge=3L, maxOffspringAge=NULL, housing="shelter_pens", currentDate=Sys.Date())` | `R/getProductionStatus.R:54` | `list(production, color, colorIndex)` | `tests/testthat/test_getProductionStatus.R` | **none** |

All three are internal (`@noRd`, absent from `NAMESPACE`) and each maps to `colorIndex` 1/2/3 with the meeting-note thresholds. Notes on each:

- **`getProportionLow`** (`:20-33`): "low" is **not a numeric cutoff** — it counts value labels matching the literal string `"Low"` (`stri_detect_fixed(geneticValues, "Low")`). The proportion is (# labeled "Low") / (length). So the "low value" question is decided upstream by whatever produces the genetic-value labels. Boundary behavior: >0.5 red, [0.3, 0.5] yellow, <0.3 green (`:23-31`). Empty input errors (`:16-18`).
- **`getIndianOriginStatus`** (`:19-45`): implements a **count-based** rule — `(chinese + hybrid) >= 1` → red; else `borderline >= 1` → yellow; else green. It relies on the upstream `origin` vector already carrying ancestry categories, and the matching is **not uniform**: `HYBRID` uses `stri_startswith_fixed(origin, "HYBRID")` (`:21`) while `CHINESE` and `BORDERLINE_HYBRID` use `stri_detect_fixed` (`:19`, `:22`). The start-anchored HYBRID match is load-bearing — it keeps a `"BORDERLINE_HYBRID"` label (which contains the substring `"HYBRID"`) from also being counted as a hybrid and flipping the group to red. Consequence: the S3 assembler must supply hybrid labels that **begin** with `"HYBRID"`. The meeting-notes' "10–15% Chinese = borderline" percentage rule is assumed pre-computed into those category labels, not done here.
- **`getProductionStatus`** (`:54-113`): requires `ped` columns `id, dam, sex, age` (`:57`) and reads `ped$birth`, `ped$exit` (`:71-77`). Needs a `housing` value per call. **`production == NA` (0 dams) maps to green** (`:85`, `:96`) — a data-quality trap (no data reads as "healthy"). Threshold code (`:84-105`) = 20190810 numbers.

### 3.3 Column 4 (Inbreeding): no provider, but buildable
- **No** `getKinshipWithMaleStatus`-type helper exists (grep for `kinshipWithMale` / inbreeding-status found none).
- Building blocks exist: `kinship(id, father.id, mother.id, pdepth, sparse=FALSE)` — **exported**, returns a square kinship matrix (`R/kinship.R:67`, `:32`). The package threshold constant appears throughout as `0.015625` (= 1/64 ≈ the notes' 0.0156), e.g. `filterThreshold(kin, threshold = 0.015625)` (`R/filterThreshold.R:28`).
- A new internal helper must combine: within-group kinship matrix + `sex`/`age` demographics + the 0.015625 threshold → the fraction of females ≥3 unrelated to ≥1 male ≥5 → `colorIndex` per §2 (red <0.6 / yellow 0.6–0.9 / green >0.9).

### 3.4 Column 5 (Flags): no provider, no data source → **defer**
- No genotype/phenotype flag helper or column exists. The meeting notes themselves say this "likely does not reside in demographics" (`meeting_notes.qmd:529`). Ship the first version without it (§5 D5).

### 3.5 App wiring & integration points
- Modular Shiny app: one `navbarPage(id = "mainNavbar")` (`R/appUI.R:35-37`); each tab embeds a module UI, e.g. `tabPanel("Summary Statistics", ..., modSummaryStatsUI("summaryStats"))` (`:175-179`). Server side calls `modXxxServer("nsId", ...)` in `R/appServer.R`, threading shared state through `shared <- reactiveValues(...)` (`appServer.R:56-63`).
- The Home page already **promises** this feature: the "Summary Statistics" panel says *"View genetic diversity metrics and plots"* with a `goto_summary` button (`appUI.R:115-119`; handler `appServer.R:101-103` switches tabs via `updateNavbarPage`).
- `modSummaryStats` renders **six ggplot2 plots** (histograms + box plots) but **no heatmap** and is **population-level**, not group-level (`R/modSummaryStats.R:132-197`, `:698-737`).
- `modORIPReporting` has a "Genetic Diversity Metrics" section but the tab is **site-gated** (shown only for ONPRC; `appUI.R:184-190`), so it is the wrong home for a general feature.
- **Breeding-group results are computed but discarded, not missing.** `modBreedingGroupsServer` already **returns** a documented reactive contract — `list(groups, nGroups, score, unassigned, groupKinship)`, where `groupKinship` is a *list of per-group kinship matrices* (`R/modBreedingGroups.R:141-152` doc, `:500-518` code). But `appServer.R:315` calls it with **no assignment**, so the return is thrown away and `shared` has no groups field (`:56-63`). Consequences: (a) capturing groups is a **one-line assignment** of an existing return (§7 S4), not new return plumbing; (b) the Inbreeding column can consume the existing per-group `groupKinship` matrices rather than recomputing `kinship()` (§7 S2).
- Module conventions to follow: `R/modXxx.R` exporting `modXxxUI(id)` (a `div` with `data-ready`/`data-module` attrs for E2E) + `modXxxServer(id, ...)` via `shiny::moduleServer` (`modSummaryStats.R:23-29`, `:308-311`). Conditional tabs use `insertTab`/`removeTab` on `"mainNavbar"` (`appServer.R:197-235`).

### 3.6 Dependencies
- `ggplot2` **is** in `DESCRIPTION` Imports (`:45`) and already imported across `modSummaryStats`. `gplots`, `pheatmap`, `plotly`, `lattice` are **absent**. → A `geom_tile` heatmap adds **no** new dependency; reviving `heatmap.2` would add `gplots` (§5 D1).

---

## 4. Data readiness at a glance

| Col | Metric | Provider status | Extra inputs still needed |
|---|---|---|---|
| 1 | Value | ✅ `getProportionLow` (tested) | Source of the genetic-value "Low"/"High" labels (see §6 Q3) |
| 2 | Origin | ✅ `getIndianOriginStatus` (tested) | `origin` vector carrying ancestry categories incl. `BORDERLINE_HYBRID` |
| 3 | Production | ✅ `getProductionStatus` (tested) | `housing` type **per group** (§6 Q2); resolve doc/code mismatch (D7) |
| 4 | Inbreeding | ⚙ buildable — **new helper** | within-group kinship (reuse `modBreedingGroups`' `groupKinship`, else `kinship()`) + `sex`/`age` + 0.015625 |
| 5 | Flags | ⛔ no provider, **no data source** | a genotype/phenotype flag data source — **defer** (D5) |

**Cross-cutting input for every column: breeding-group membership** (which animals are in which group). Already produced by `modBreedingGroups` (returned as `groups`, with per-group kinship as `groupKinship`) but currently discarded by `appServer.R:315` — captured via a one-line assignment in S4 (§3.5).

---

## 5. Design decisions

Each decision lists a recommendation and its rationale. **[RATIFY]** marks decisions the owner should confirm before the relevant slice begins.

- **D1 — Visualization technology: `ggplot2::geom_tile`.** Recommend rewriting the renderer as a `ggplot2` `geom_tile` heatmap (red/yellow/green fill from `colorIndex`, group labels on the y-axis, 45° column headers via `theme(axis.text.x = element_text(angle = 45))`). Rationale: `ggplot2` is already a dependency and is the app's plotting library; it renders directly to a Shiny `plotOutput`/`renderPlot` with no file I/O; reviving `heatmap.2` would add a `gplots` dependency to an archived package for no benefit. **[RATIFY]**
- **D2 — Dead code: delete and replace.** Recommend deleting `R/makeGeneticDiversityDashboard.R` and its dead test after the new renderer lands (they are build-ignored, PNG-oriented, and superseded). Verify committed history first per SAFEGUARDS before removal. Alternative: keep as a `docs/`-side reference snippet. **[RATIFY]** (fold into S1)
- **D3 — Home: a new dedicated tab + module `modGeneticDiversity`.** Recommend a new tab/module rather than extending `modSummaryStats` (population-level, wrong granularity — the dashboard is group-level) or `modORIPReporting` (site-gated, would hide it for most sites). Follow the ORIP-tab registration pattern. Note the Home "Summary Statistics" panel copy may want a companion "Genetic Diversity" entry. The meeting notes frame the deliverable as the **"Genetic Diversity Report"** graphic (`meeting_notes.qmd:434`; the 20190810 header reads "GENETIC DIVERSITY REPORTING"), so name the tab/module accordingly (e.g. tab "Genetic Diversity", module `modGeneticDiversity`) rather than an unrelated name. **[RATIFY]**
- **D4 — Group source.** The dashboard operates on formed breeding groups. `modBreedingGroupsServer` **already returns** `groups` plus per-group `groupKinship`, so capturing it is a one-line assignment into `shared$breedingGroups` (S4); the dashboard then reads it. When no groups are formed, the tab shows guidance instead of an empty plot. **[RATIFY]**
- **D5 — Flags column: defer.** Ship the first working version with **4 columns** (Value, Origin, Production, Inbreeding). Add Flags only once a genotype/phenotype data source is identified (§6 Q4). Rationale: no data source exists; blocking the whole feature on it is unjustified. **[RATIFY]**
- **D6 — Cell contents: color + value.** Recommend each cell show the underlying number (proportion/percent/count) on the colored tile for interpretability, not color alone. Minor; can change in S1.
- **D7 — `getProductionStatus` doc/code mismatch.** Its `@details` prose (`getProductionStatus.R:8-30`) describes a fixed-2019-date formula (from the 20190916 notes) while the **code** implements a rolling `currentDate`-relative birth window (`:64-77`) with 20190810 thresholds. Resolve during the Production integration (S3): make the doc match the implemented behavior (a small REFACTOR-class doc fix, like the recent #109 work). **A second, independent doc/code mismatch lives in the same file:** `@param minParentAge` says "Defaults to 2 years" (`getProductionStatus.R:40`) but the actual default is `3L` (`:54`) — fix both in S3. Do **not** silently change thresholds. **[RATIFY the canonical definition]**

---

## 6. Open spec questions (owner input needed before the dependent slice)

1. **Production definition (blocks S3’s Production column).** Confirm the **20190810 thresholds** the code already implements are canonical (recommended, since the code chose them), or switch to 20190916. Also confirm the birth-window formula: keep the code’s rolling `currentYear-2 … currentYear-1` window, or the fixed 2017–2018 window in the doc?
2. **Housing type per group (blocks S3’s Production column).** `getProductionStatus` needs `housing ∈ {"shelter_pens","corral"}` per group. How does the app learn each group's housing type — a column on the group data, a per-group user selection in the UI, or a colony-config lookup?
3. **Genetic-value "Low" label source (blocks S3’s Value column).** `getProportionLow` counts labels equal to `"Low"`. Where are those labels produced (the genetic-value report’s value category)? The value-assembler slice must locate/confirm this. (No literal `"Low"`/`"High"` value-label assignment was found in `R/` this session outside `getProportionLow` itself — needs tracing.)
4. **Flags data source (blocks the deferred S5).** Is there any genotype/phenotype "flagged animal" data available (LabKey field, uploaded column)? If not, S5 stays deferred.
5. **Row scope.** Rows are breeding groups. Should corrals appear as their own rows too (the notes treat "corral" both as a row candidate and as a housing category for thresholds)?
6. **Value 0.3 boundary (already code-resolved; confirm).** The 20190810 note reads "GREEN =< 0.3" (green *includes* 0.3) yet also "YELLOW >= 0.30" — self-contradictory at exactly 0.3 (`meeting_notes.qmd:453-454`). The shipped `getProportionLow` resolves it to **yellow** (green only for `proportion < 0.3`, `getProportionLow.R:29`). Confirm 0.3 → yellow is intended. Low priority — no code change unless rejected.

---

## 7. Vertical implementation slices

Each slice is **one session**, strict TDD (RED → GREEN → REFACTOR, each gated per CLAUDE.md), and passes the "if I stop here, does something work?" test. Ordering front-loads the visible, low-risk renderer (tracer bullet), then thickens the data path behind it. **S1 and S2 are independent and may be reordered; S2 → S3 is a hard order** — S3's assembler calls S2's `getKinshipWithMaleStatus`, so S3 cannot run first without shipping a 3-column assembler (contradicting D5) or absorbing S2.

### Slice 1 — Heatmap renderer (the tracer bullet)
- **Goal:** a new exported function `makeGeneticDiversityHeatmap(stats)` (name **[RATIFY]**) that takes a group × metric data frame of `colorIndex` values (first column = group label, remaining columns = 1/2/3) and returns a **`ggplot`** object: `geom_tile` filled red/yellow/green, group labels on the y-axis, metric headers at 45° on top, optional value labels (D6).
- **Also (D2):** delete the dead `R/makeGeneticDiversityDashboard.R` + `tests/testthat/test_makeGeneticDiversityDashboard.R` after confirming they are in committed history (`git log --oneline -- <file>`).
- **DONE looks like:** the function exists, is `@export`ed + documented (`man/*.Rd` regenerated), and unit tests feed it a hand-built matrix and assert it returns a `ggplot` whose data/fill mapping and tile count match the input; the discrete 3-color scale maps 1→red, 2→yellow, 3→green.
- **Verification:** `Rscript -e 'pkgload::load_all("."); testthat::test_file("tests/testthat/test_makeGeneticDiversityHeatmap.R", reporter="summary")'`; `lintr::lint("R/makeGeneticDiversityHeatmap.R")` = 0; `devtools::document()` → NAMESPACE gains exactly the one export; `spell_check_package()` clean. Independently useful: `makeGeneticDiversityHeatmap(handBuiltMatrix)` renders a real heatmap in an R session.
- **Session boundary:** close out here. Do not start S2.
- **Risk / non-obvious:** ggplot fill needs a discrete scale keyed to `colorIndex` (use `scale_fill_manual` with named values), not a continuous gradient, or 1/2/3 will render as a blue gradient. Tests should assert the built plot object, not pixels.

### Slice 2 — Inbreeding data provider
- **Goal:** a new internal (`@noRd`) helper `getKinshipWithMaleStatus(group, kmat, ...)` (name/signature **[RATIFY]**) returning `list(fraction, color, colorIndex)`: among females ≥ 3 yr in the group, the fraction with kinship ≤ 0.015625 to at least one male ≥ 5 yr in the group; color per §2 (red <0.6, yellow 0.6–0.9, green >0.9).
- **DONE looks like:** helper + `test_getKinshipWithMaleStatus.R` covering happy path, boundaries (exactly 0.6 and 0.9), no-eligible-females and no-eligible-males edge cases, and the 0.015625 threshold edge. Consumes a per-group kinship matrix — reuse `modBreedingGroups`' `groupKinship` in the app; fall back to `kinship()` when called outside the app (§3.5). No new dependency.
- **Verification:** single-file test run + `lintr` 0 + `spell_check` clean.
- **Independent value (honest framing):** a tested internal provider — a peer to the 3 existing `@noRd` providers — that **de-risks the high-uncertainty S3**. It advances no end-to-end user capability alone and has no live caller until S3 (callable directly only as `nprcgenekeepr:::getKinshipWithMaleStatus`). It still passes the "something works" test as a self-contained, tested unit.
- **Session boundary:** close out. **Risk:** decide NA/empty-denominator behavior deliberately (do **not** copy `getProductionStatus`'s NA→green trap; see §3.2). Confirm age/sex column names against the pedigree schema before writing RED.

### Slice 3 — Per-group stats assembler
- **Goal:** a function `getGeneticDiversityStats(ped, groups, geneticValues, housing, ...)` (signature **[RATIFY]**) that, for each group, calls the 4 providers (`getProportionLow`, `getIndianOriginStatus`, `getProductionStatus`, `getKinshipWithMaleStatus`) and returns the group × 4-metric `colorIndex` data frame that S1 consumes. Resolve §6 Q1–Q3 here; apply the D7 doc fix to `getProductionStatus`.
- **DONE looks like:** assembler + tests on a small fixture pedigree with ≥2 groups, asserting each column's `colorIndex` for known inputs; end-to-end `getGeneticDiversityStats(...) |> makeGeneticDiversityHeatmap()` renders a real heatmap. Because `getProductionStatus` re-baselines nothing seeded, no golden-shift sweep is expected — but run the full suite once to confirm (the 3 helpers gain their first live callers here).
- **Verification:** single-file test + full-suite clean read (`test_dir`, filter `!grepl("test-app-|test-e2e-", file)`); `lintr` 0; `spell_check` clean; `R CMD check --as-cran` from repo root.
- **Session boundary:** close out. **Risk (highest-uncertainty slice):** the value-label source (Q3), housing-per-group (Q2), and origin-category availability (§3.2) are all real unknowns — this slice must resolve them with the owner or the assembler will encode guesses. Do not start until Q1–Q3 are answered.

### Slice 4 — Shiny module + app wiring
- **Goal:** `R/modGeneticDiversity.R` (`modGeneticDiversityUI`/`Server`) rendering the heatmap via `renderPlot`, registered as a new tab in `appUI.R` + `appServer.R`, fed by `shared`. Capture breeding-group results into `shared$breedingGroups` (D4). Show guidance when no groups/data.
- **DONE looks like:** the tab appears in the running app and renders the heatmap from live data; module tests (mocking reactives) pass. **Phase 3E runtime smoke is mandatory** (this is a runtime/registration change — FM #24): launch via `runGeneKeepR()`, confirm the tab mounts and renders, scan for startup errors.
- **Verification:** module test file + full-suite clean read + `R CMD check --as-cran` + a live app launch. `lintr` 0 on all changed files; NAMESPACE diff reviewed (2 new exports); `spell_check` clean.
- **Session boundary:** close out. **Risk:** the group-capture plumbing touches `appServer.R` shared state — keep the diff to the wiring; do not refactor adjacent modules (SAFEGUARDS mode-switch rule).

### Slice 5 — Flags column (**deferred**)
- **Blocked on §6 Q4** (a genotype/phenotype data source). When available: a `getGenotypeFlagStatus` provider (red ≥3 / yellow 1–2 / green 0), added to the assembler and as a 5th heatmap column. Not scheduled.

---

## 8. Risks & non-obvious areas (read before implementing)

1. **The whole feature is group-level; group state is computed but discarded, not missing.** `modBreedingGroups` already returns `groups` + `groupKinship`; `appServer.R:315` throws the return away. Capturing it (S4) is a one-line assignment, so the plumbing risk is low — but every data slice (S3, S4) still *depends* on groups having been formed, so the dashboard must degrade gracefully (show guidance, not an empty/broken plot) when none exist.
2. **`getProductionStatus` NA→green trap** (`:85`, `:96`): a group with zero dams reads as healthy green. Surface this to the owner during S3; it may warrant a "grey / insufficient data" state rather than green.
3. **Production has a live doc/code mismatch** (D7) and a **spec conflict** (Q1). The code already picked 20190810 thresholds; treat that as the default but get explicit ratification — thresholds are clinical judgment, not a code detail.
4. **Origin depends on upstream ancestry categorization** the package may not produce end-to-end. `getIndianOriginStatus` assumes the `origin` vector already carries `CHINESE`/`HYBRID`/`BORDERLINE_HYBRID` labels; confirm the real data supplies them before trusting Column 2.
5. **Discrete color scale, not a gradient** (S1): map `colorIndex` through `scale_fill_manual`, or a numeric 1/2/3 will render as a continuous ramp.
6. **Archived-package discipline:** version is 2.0.0, archived on CRAN. Adding an export is fine locally, but do not treat any of this as a CRAN-resubmission trigger — that is owner-gated and out of scope.

---

## 9. Grep-based inventory (appendix)

Commands run this session and their material results (for the executor to re-verify):

- `grep -rn '<helper>' R/ tests/ vignettes/` for each of the 3 providers → **only** hits are their own defs, their own test files, and the commented-out `test_makeGeneticDiversityDashboard.R`. → the providers are orphaned; no live caller will break when they gain callers in S3.
- `grep -rnE '0\.0156' R/` → threshold constant is `0.015625` in `filterThreshold.R:28`, `groupAddAssign.R:120`, and docs — reuse it in S2.
- `grep -rilE 'genotypePhenotype|flagged' R/` → only unrelated QC code (`setPopulation`, `resetGroup`, `runQcStudbook`, …); **no** genotype/phenotype breeding-flag source → confirms Column 5 defer.
- `grep -n 'gplots|ggplot2|pheatmap' DESCRIPTION` → `ggplot2` only (`:45`) → confirms D1.
- `grep -n 'makeGeneticDiversityDashboard' .Rbuildignore` → `:21` build-ignored → confirms it is not in the shipped package.
- `ls R/kinship.R; grep -n '^kinship <- function' R/kinship.R` → `:67`, exported (`:59`) → confirms S2 building block.

**Before S1/S3/S4 code:** re-run the per-helper grep and `git log --oneline -- R/makeGeneticDiversityDashboard.R tests/testthat/test_makeGeneticDiversityDashboard.R` (D2 delete safety) to confirm nothing changed since this plan.
