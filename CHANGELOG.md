# Changelog

Development / process history for the **nprcgenekeepr** project, following the
[methodology](https://github.com/rmsharp/methodology) model: `BACKLOG.md` holds open
work, **this file** holds completed history, and `ROADMAP.md` holds the feature
inventory and future plans.

> **Note:** User-facing R-package release notes (the CRAN / pkgdown "Changelog") live in
> `NEWS.md` / `NEWS.Rmd`. This file tracks the development *process* and methodology
> history, not package releases.

Format loosely follows [Keep a Changelog](https://keepachangelog.com/).
When completing work, remove the item from `BACKLOG.md` and add an entry here.

## [Unreleased]

### 2026-06-05 — PLAN: Phase 8 sub-plan — enable the shinytest2 E2E harness (XARCH-1 / issue #39) (Session 30)
- **Deliverable (planning, not implementation):** `docs/planning/phase8-e2e-harness-subplan.md` —
  a sub-plan for the conversion campaign's Phase 8 (make the dormant shinytest2 browser E2E tier
  executable). The campaign's second planning/architecture deliverable. No code written (FM #18/#19).
- **Corrected the parent plan §9 Phase 8** via firsthand discovery (greps + R one-liners + a read-only
  workflow: 5-agent census of all 23 E2E files + adversarial completeness-critic, 16 findings
  re-verified firsthand): the gap is **6 undefined helpers + 1 undefined constant** (`create_app_driver`
  with `...`→height/width, `navigate_to_tab(app, label, fallback=NULL)` [109/137 calls 3-arg],
  `get_html_safe`, `click_element_safe`, `navigate_to_menu_item`, `get_values_safe`, `E2E_TIMEOUT`),
  **not the "3 helpers"** the parent plan claimed — and Phase 8 is a **4-session mini-campaign (8a–8d)**,
  not one session.
- **Key findings:** the `navbarPage` renders ALL tabs' static UI into the DOM at boot
  (`appUI()` = 85 KB), so the suite's dominant `grepl(keyword, "body")` checks **pass trivially once the
  app boots** → "harness runs green" ≠ "validates behavior" (41 `expect_true(TRUE)` tautologies;
  `summary-statistics-module` navigates to the wrong tab in 7/8 tests yet passes). The `input` vs
  `dataInput` namespace mismatch is real but **inert** (polling helpers never called).
- **Owner decisions (`AskUserQuestion`):** (1) scope = **harness-enable (8a–8d)** → assertion-strengthening
  filed as a separate follow-on issue ("8e"); (2) CI gating = **scheduled + manual dispatch** (not per-PR),
  drop `continue-on-error`, keep fast unit CI as the per-PR gate.
- **Plan structure:** 8a helpers/constant (browser-free RED→GREEN) · 8b boot-smoke + CI rewire (first
  browser run) · 8c 15 shallow per-module files · 8d 5 interaction/menu files → close #39. Each sub-phase
  has DONE + verify-command + session boundary; 23 files / 159 tests fully assigned. Updated parent plan
  §9 + `BACKLOG.md` to point at the sub-plan. Learning #30.

### 2026-06-05 — Implement Phase 7 of the Shiny-module conversion: Input parity, focal-animal / LabKey pedigree build (Session 29)
- **Deliverable (implementation):** wired the modular **Data Input** module's "Focal animals only;
  pedigree built from database" path so an uploaded focal-animal ID list builds a pedigree from the
  ONPRC LabKey EHR — bringing modular `modInput` to monolith parity (plan §9 Phase 7; monolith
  server.r:86-113). All in `R/modInput.R`, inside `observeEvent(input$getData)`:
  1. **Server-side gap fixed.** The UI option already existed (`modInput.R:70` radio /
     `:111-116` `breederFile` / `:244` `activeFile`) but was **broken**: the focal-ID file was read
     *as a pedigree* by `readDataFile()` → a spurious "missing columns" QC error. Now, when
     `input$fileContent == "focalAnimals"`, the module calls `getFocalAnimalPed(file$datapath, sep)`
     to build the pedigree from the EHR, then feeds it into the existing `qcStudbook`/`runQcStudbook`
     machinery unchanged.
  2. **DB-failure routing.** A `getLkDirectRelatives` connection failure makes `getFocalAnimalPed`
     return an `nprcgenekeeprErr` errorLst; the module routes it to `storedErrorLst()` (cleaned =
     NULL, early return) so the already-wired appServer dynamic **Error List** tab surfaces
     `failedDatabaseConnection` ("Database connection failed…"). No new renderer/appServer code.
- **Built more correctly than the monolith.** The monolith detects the error shape with
  `is.element("nprckeepErr", class(...))` — a **typo** (the real class is `nprcgenekeeprErr`), so its
  DB-failure branch never fired. The modular wiring uses `inherits(built, "nprcgenekeeprErr")` and
  drops the monolith's dead bare-`NULL` branch (`getFocalAnimalPed` only returns a data.frame or an
  errorLst).
- **Strict TDD** (RED→GREEN→REFACTOR, all gated + 2 pre-RED author-decision `AskUserQuestion`s — the
  owner-consult fork [mock-wire vs live-integration vs descope] → **mock-wire/full parity**): 2 new
  tests in `tests/testthat/test_modInput.R` drive `testServer(modInputServer)` and mock the LabKey seam
  via `testthat::local_mocked_bindings(getLkDirectRelatives = …, .package = "nprcgenekeepr")` so the
  real `getFocalAnimalPed` body runs (no live EHR). Both **RED at HEAD** (happy: `cleaned` NULL because
  the focal file is read as a 1-column pedigree; sad: `failedDatabaseConnection` never set), **GREEN**
  after. REFACTOR gated, skipped (minimal/idiomatic).
- **Verification:** `test_modInput.R` 0/0/0 (162 passed); full suite under `pkgload::load_all` +
  `NOT_CRAN=true` = **0 failed / 0 error**, 0 non-e2e offenders, e2e skipped (156), only the 5
  pre-existing `modPyramid` warnings (added zero), **2122 passed**. Lint **net-zero** on `R/modInput.R`
  (41 = 41, touched-file stash; explicit-`L` on the copied empty-warnings df), `document()` **zero**
  man/NAMESPACE delta, no macOS `* 2.*` dupes, **Phase-3E runtime smoke** — `runModularApp()` binds +
  HTTP 200, served HTML renders `dataInput-breederFile`/`-fileContent`/`-getData` + `value="focalAnimals"`.
  **Verification is environmentally limited** (no live EHR): the mock covers everything on the module's
  side of the ONPRC boundary; the live `getLkDirectRelatives` → `getDemographics` call is owner-verifiable
  only (stated, not skipped — not FM #24). **No NEWS bullet** — input-wiring/display parity for the
  modular app, no analytical-pipeline numeric change (consistent with S22/S23/S25).

### 2026-06-04 — Implement Phase 6 of the Shiny-module conversion: Breeding Groups parity B (Session 27)
- **Deliverable (implementation):** brought the modular **Breeding Group Formation** module to
  monolith parity for seed-group pre-seeding and the previously-inert formation controls, all in
  `R/modBreedingGroups.R` (plan §9 Phase 6):
  1. **Seed-group "current groups" widget** — a `seedGroups` checkbox reveals one per-group
     `textAreaInput` (`curGrp1..N`, count driven by `nGroups`). Their IDs build a length-`numGp`
     `currentGroups` list passed to `groupAddAssign()` in place of the hardcoded
     `list(character(0L))`, so groups can be pre-seeded (the monolith's `textAreaWidget`/
     `getCurrentGroups`, server.r:1019-1056).
  2. **Exposed three previously-inert controls** the server already read (`modBreedingGroups.R`
     L201-203) but no UI declared, so they had silently defaulted: `minAge` (numericInput, value 1),
     `nIterations` (numericInput, value 10L), `withKinship` (checkbox). The new control ids match the
     server reads (`minAge`/`nIterations`/`withKinship`), **not** the monolith's `gpIter`/`withKin`.
  3. **Breeding-sim iteration default `1000L → 10L`** — the modular fallback was a 100× drift from
     the monolith's `gpIter` (value=10L); now matches. This is a **real numeric change** to formed
     groups (the MIS sampler runs 100× fewer iterations by default).
- **Built robustly, not faithfully.** The monolith's `getCurrentGroups` is doubly buggy
  (`seq_along(input$numGp)` is a length-1 scalar → only `curGrp1` is ever read; `vapply(...)` yields
  a matrix not a list); the modular widget uses `seq_len(numGp)` so every group's textarea is honored
  (RED test asserts the 2nd seed group is honored). `length(currentGroups)` can never exceed `numGp`
  (built with `seq_len(numGp)` + truncation), so `groupAddAssign`'s length guard is unreachable.
- **More robust than the monolith — validate-and-block.** Seed IDs absent from the pedigree are
  rejected with a notification and formation aborts. Verified: a phantom seed otherwise survives into
  the group and **crashes** the Phase-5 Group Detail member view (`addSexAndAgeToGroup` →
  `getCurrentAge` on a length-0 birth). The monolith has only a partial `validate(need())` guard
  (server.r:1124-1133); the modular module previously had none.
- **Strict TDD** (RED→GREEN→REFACTOR, all gated + 4 pre-RED author-decision `AskUserQuestion`s):
  7 new tests — 5 RED at HEAD (UI controls present; `nIterations` renders `value="10"`; seeding lands
  animals in their group; multi-group seeding [proves the `curGrp1`-only bug not copied]; phantom seed
  blocks formation) + 2 green-at-HEAD coverage (blank-seed no-op; `withKinship=TRUE`→non-NULL kinship,
  green-at-HEAD because the server already reads `input$withKinship`). REFACTOR considered + skipped.
- **Verification:** `test_modBreedingGroups.R` 41 tests **0 failed / 0 error / 0 warning**; full suite
  under `pkgload::load_all` + `NOT_CRAN=true` **0 failed / 0 error**, e2e skipped (156), only the 5
  pre-existing `modPyramid` warnings. R6 validate-and-block guard **mutation-verified** (disabling it
  lets the phantom seed survive). Lint **net-zero** on `R/modBreedingGroups.R` (31 = 31, touched-file
  stash); `document()` zero man/NAMESPACE delta (`import(shiny)` covers the new controls); **Phase 3E
  runtime smoke** — `runModularApp()` HTTP 200 with `seedGroups`/`minAge`/`nIterations` (value 10)/
  `withKinship`/`seedTextareas` rendered and the Phase-5 Group Detail tab intact.
- A read-only 5-agent discovery + adversarial-completeness recon (`wf_e8e1176c-320`) confirmed the
  parity surface and sharpened the dragon (the phantom-seed crash); every load-bearing claim was
  verified firsthand.
- **Files:** `R/modBreedingGroups.R`, `tests/testthat/test_modBreedingGroups.R`. **Next: Phase 7**
  (focal-animal / LabKey pedigree build — risk HIGH 🐉, owner consult at phase start; see plan §9).

### 2026-06-04 — Implement Phase 5 of the Shiny-module conversion: Breeding Groups parity A (Session 26)
- **Deliverable (implementation):** brought the modular **Breeding Group Formation** module to
  monolith parity for the per-group display/export half, all in `R/modBreedingGroups.R` (plan §9
  Phase 5). A new **"Group Detail" tab** (additive — the existing all-groups "Groups" and
  "Statistics" tabs are untouched) adds:
  1. **`viewGrp` group selector** (`selectInput`), populated when groups form ("Group 1..N",
     with the last labelled "Unused" only when the appended unused-animals group is non-empty).
  2. **Per-group annotated member view** — `addSexAndAgeToGroup()` → rounded age → columns
     "Ego ID"/"Sex"/"Age in Years", ordered by ID (the monolith's `bgGroupView`).
  3. **Per-group kinship matrix view** — `filterKinMatrix(groupIds, kmat)` rounded to 6 dp
     (the monolith's `bgGroupKinView`).
  4. **`downloadGroup`** (member CSV, `na=""`/`row.names=FALSE`) and **`downloadGroupKin`**
     (kinship CSV, `na=""`/`row.names=TRUE`) handlers.
- **Dragon (threading the kinship matrix) discharged.** The kinship view computes each group's
  submatrix from the module's already-computed full `kmat` (now retained in `groupResults` with a
  `hasUnused` flag), NOT from `result$groupKin` (still NULL — `withKin` defaults FALSE until the
  Phase-6 `withKinship` control). This is **byte-identical** to the monolith's `groupKin[[i]]`
  (each group's members ⊆ candidates), and the group-**formation** compute path is **unchanged** —
  proven `identical()` across three `set.seed`ed scenarios (nGroups 3/4/1) vs a pre-change
  reference (`groups`/`score`/`unassigned`/`nGroups`). Display/download only.
- **More robust than the monolith.** Both views clamp `viewGrp` via
  `withinIntegerRange(., 1, length(breedingGroups()))` (the monolith clamps the member view to the
  *requested* `numGp` and leaves the kinship view unclamped — a latent out-of-range bug). The
  selector-populating `observe` guards on `length(breedingGroups()) >= 1L` (an empty result is a
  zero-length list, which `req()` treats as truthy — the naive guard warned on the degenerate
  harem-with-no-eligible-sires case).
- **TDD:** 5 new tests in `tests/testthat/test_modBreedingGroups.R` (UI structure; member-download
  content; kinship-download content + `filterKinMatrix`-equivalence; selector switches group;
  out-of-range clamp) — all red at HEAD, green after. Founders-with-birth fixture gives a
  deterministic kinship submatrix (0.5 diagonal / 0 off-diagonal); assertions key on the *actual*
  formed group. Full suite under `pkgload::load_all` + `NOT_CRAN=true`: **0 failed / 0 error**,
  156 e2e skipped, 5 pre-existing `modPyramid` warnings, 2264 passed. Lint net-zero on
  `R/modBreedingGroups.R` (31 = 31); `document()` zero man/NAMESPACE delta; **Phase 3E runtime
  smoke** — `runModularApp()` HTTP 200 with the Group Detail tab + selector + downloads rendered.
- **Housekeeping:** removed two stray untracked macOS "filename 2" duplicates
  (`R/modBreedingGroups 2.R`, `tests/testthat/test_modBreedingGroups 2.R`) that had appeared
  mid-session and were doubling the generated `.Rd` docs and double-running the test file
  (moved aside to `/tmp`, not in git).
- **No `NEWS.md` bullet** — this is display/download parity for the not-yet-canonical modular app
  with no change to the analytical pipeline (NEWS is reserved for numeric changes + the Phase 9
  deprecation). Plan §9 Phase 5 → DONE; next is Phase 6 (seed-groups + inert controls).

### 2026-06-04 — Implement Phase 4 of the Shiny-module conversion: genotype file merge in modInput (Session 25)
- **Deliverable (implementation):** brought the modular **Data Input** module to monolith parity
  for the **separate pedigree/genotype** upload path, all in `R/modInput.R` (plan §9 Phase 4).
  1. **Genotype file merge.** Inside `observeEvent(input$getData)`, before the `qcStudbook`/
     `runQcStudbook` calls, the `separatePedGenoFile` path now reads `input$genotypeFile` via
     `getGenotypes()`, validates with `checkGenotypeFile()` (degrading to no-merge on
     warning/error, mirroring the monolith), and merges it into the raw pedigree via
     `addGenotype()`. The integer `first`/`second` columns then ride the cleaned studbook into
     `reportGV()` (via `getGVGenotype()`/`hasGenotype()`), so genome-uniqueness uses the real
     genotypes. Previously `activeFile()` silently dropped `input$genotypeFile`.
  2. **`genotypeData()` populated.** Added `genotype = getGVGenotype(qcResult$cleaned)` to the
     module's stored results, so the `genotypeData()` reactive (formerly always NULL) returns the
     id/first/second extract (NULL when no genotype, preserving the prior contract).
  3. **More robust than the monolith.** The merge is **NULL-guarded** — `addGenotype(ped, NULL)`
     crashes (`"'by' must specify a uniquely valid column"`), a latent unguarded crash in the
     monolith; a malformed genotype file now degrades to no-merge instead of crashing the QC run.
  - **Common-mode unchanged (proven at parity):** neither app integer-codes string allele names
    for a combined ped+genotype file, so common-mode genotypes never reach `reportGV`'s gene-drop
    in either app — adding `addGenotype` to the common branch would be a behavior change beyond
    parity. Phase 4 touches only the `separatePedGenoFile` path.
- **Tests:** 2 new tests in `tests/testthat/test_modInput_qcStudbook.R` — a discriminating
  happy-path (upload the shipped `obfuscated_rhesus_mhc_ped.csv` + `…_breeder_genotypes.csv`;
  assert the cleaned studbook gains `first`/`second`, `hasGenotype()` TRUE, `genotypeData()`
  populated) and a malformed-genotype graceful-degradation test (NULL-guard mutation-verified).
- **Method (TDD, ultracode):** RED→GREEN→REFACTOR with all gates + 2 pre-RED author decisions via
  `AskUserQuestion` (populate `genotypeData()` too; reader = `getGenotypes()`); a 5-agent
  read-only discovery + adversarial-completeness recon (`wf_37c91d78-d24`) settled the
  common-mode/NULL-crash/testServer-harness questions, all verified firsthand.
- **Verification:** full suite under `pkgload::load_all` + `NOT_CRAN=true` = 0 failed / 0 error,
  0 non-e2e offenders, 2085 passed, e2e skipped (156); lint net-zero on `R/modInput.R` (41 = 41);
  `devtools::document()` no man/NAMESPACE delta; **Phase 3E runtime smoke** `runModularApp()`
  binds + HTTP 200 (modInput mounts with the `genotypeFile` input). No NEWS bullet (modular app
  not yet canonical; no analytical-pipeline numeric change).
- **Files:** `R/modInput.R`, `tests/testthat/test_modInput_qcStudbook.R`. **Next: Phase 5**
  (Breeding Groups downloads + per-group kinship + group selector).

### 2026-06-04 — Implement Phase 3 of the Shiny-module conversion: GVA genome-uniqueness threshold + subset/filter export (Session 24)
- **Deliverable (implementation):** brought the modular **Genetic Value Analysis** tab to
  monolith parity across four verified gaps, all in `R/modGeneticValue.R` (plan §9 Phase 3).
  1. **Genome-uniqueness threshold control.** Added a `selectInput(ns("threshold"))` (choices
     1–5, default 4) threaded via a new `guThreshold()` reactive into `reportGV()`, replacing the
     hard-coded `guThresh = 1L`. This changes default genome-uniqueness output for the modular
     app (intended parity — the monolith default is the threaded integer 4).
  2. **Subset/filter view.** Added a `viewIds` textarea + "Filter View" button + a `gvaView()`
     reactive that filters the report by entered IDs via the exported `filterReport()` (monolith
     `gvaView`/`filterReport`, server.r:462-477); the rankings table now reflects the filter.
  3. **Export Subset.** Added `downloadGVASubset` (writes the filtered view, `na=""`); relabeled
     the existing `downloadRankings` "Download" → "Export All" to pair with it.
  4. **Gene-drop iterations default** 5000 → 1000 (monolith parity); **removed** the inert
     `minAge` slider (never read; no monolith GVA counterpart).
- **Author decisions (USER, via `AskUserQuestion`):** direct threshold mapping (choices 1–5,
  default 4 — drops the monolith's confusing label-offset while keeping the threaded integer 4);
  iterations default 1000; remove minAge only (the 2 sibling inert checkboxes
  `calcGenomeUniqueness`/`calcMeanKinship` deferred); whole Phase 3 in one session.
- **TDD:** strict RED→GREEN→REFACTOR with phase gates (each via `AskUserQuestion`). 6 new
  discriminating tests in `tests/testthat/test_modGeneticValue.R`; minAge removal in REFACTOR
  deleted 2 tautological tests + 3 assertion lines (no real coverage lost — they only echoed the
  inert input back).
- **Discriminating-RED traps (verify-first, Learnings #15/#20):** (a) no existing test pinned the
  threshold, so all pass on the buggy `guThresh=1L` — the RED keys on the threaded integer via an
  internal `guThreshold()` reactive (empirically guThresh 1 vs 4 changes every `gu` row); (b) the
  flipped iterations assertion `grepl("1000")` first PASSED on the bug because `max="10000"`
  contains "1000" — re-keyed on the rendered `value="1000"` attribute.
- **Recon:** a read-only discovery + adversarial-completeness workflow (`wf_a1f5fdb4-b8e`, 4
  agents) re-derived the parity surface and flagged three implementation blockers, all verified
  firsthand: `%||%` is not portable (not in shiny/this package; base only since R 4.4) → used an
  explicit `is.null` guard; `stri_trim` is not the imported symbol (`stri_trim_both` is) → used
  base `trimws`; `import(shiny)` (NAMESPACE:168) covers the new `selectInput`/`textAreaInput`.
- **Verification:** `test_modGeneticValue.R` 53/53; full suite under `pkgload::load_all` +
  `NOT_CRAN=true` = 0 failed / 0 error, 0 non-e2e offenders, e2e skipped (156), 5 pre-existing
  `modPyramid` warnings; lint net-zero on `R/modGeneticValue.R` (HEAD 23 = NOW 23, via
  touched-file stash); `document()` no man/NAMESPACE delta; Phase 3E runtime smoke —
  `runModularApp()` binds + HTTP 200, the new threshold/viewIds/Export-Subset controls render and
  the minAge slider is gone. NEWS bullet added (the plan reserves NEWS for this numeric change).
  Commit `280d1df0` (impl) + the `docs:` close-out.

### 2026-06-03 — Implement Phase 2 of the Shiny-module conversion: wire the GvAndBgDesc description tab (Session 23)
- **Deliverable (implementation):** mounted the already-built `modGvAndBgDesc` module as a navbar
  tab so the modular app gains the monolith's **Genetic Value Analysis and Breeding Group
  Description** tab (plan §9 Phase 2).
  - `R/appUI.R`: a `tabPanel` after "Breeding Groups" (monolith-parity placement, per
    `inst/application/ui.r`) calling `modGvAndBgDescUI("gvAndBgDesc")`.
  - `R/appServer.R`: `modGvAndBgDescServer("gvAndBgDesc")` (informational module — returns NULL,
    no reactive state).
- **TDD:** strict RED→GREEN (REFACTOR skipped — author decision; the change is minimal/idiomatic).
  Two new integration tests in `tests/testthat/test_modGvAndBgDesc.R`.
- **Discriminating-RED gotcha (verify-first, Learning #15/#20/#23):** the module's H3 heading
  ("Genetic Value Analysis and Breeding Group Description") is NOT a discriminating marker —
  `genetic_value.html`, already mounted by `modGeneticValue`, contains that exact phrase, so a
  naive heading assertion is a tautology that passes at HEAD. The discriminating marker is
  `gvAndBgDesc.html`'s own body text (`"kinship coefficients"` / `"genetic value analysis
  proceeds"`), unique among the mounted guidance HTML and absent from `appUI()` at HEAD.
  (`modGvAndBgDescUI` does not call `NS()`, so there is no namespaced container to assert on —
  the included content IS the mount marker.)
- **Verification:** `test_modGvAndBgDesc.R` 10/10, `test_appServer_dynamicTabs.R` 23/23 (the
  dynamic insert/remove-tab interaction is unaffected — the new tab is far from the "Input"
  insert target); full suite under `pkgload::load_all` + `NOT_CRAN=true` = 0 failed / 0 error,
  2073 passed (+2), e2e skipped (156), 5 pre-existing `modPyramid` warnings; lint net-zero
  (appUI 0=0, appServer 18=18); `document()` no man/NAMESPACE delta; Phase 3E runtime smoke —
  `runModularApp()` binds + HTTP 200. Commit `ef6a9f4c`.
- **NEWS deferred** to the Phase 9 canonical switch (modular app not yet canonical).

### 2026-06-03 — Implement Phase 1 of the Shiny-module conversion: Summary Statistics tab parity (Session 22)
- **Deliverable (implementation):** brought the modular app's **Summary Statistics tab**
  (`R/modSummaryStats.R`) to legacy-monolith parity across four verified gaps (plan §9 Phase 1):
  1. **Z-score plots** now render. `reportGV()` emits the column `zScores` (plural), but
     `modSummaryStats` checked `zScore` (singular) — so the z-score histogram + boxplot were
     always NULL ("Z-scores not available"). Fixed with a dual-name lookup (prefer `zScores`,
     fall back to `zScore`), matching `modGeneticValue`'s existing `indivMeanKin`/`meanKinship`
     idiom. (Real column name confirmed empirically before the fix.)
  2. **Mean-Kinship / Genome-Uniqueness quartile tables** (Min/1st-Q/Mean/Median/3rd-Q/Max)
     rendered on the Summary tab (monolith `server.r:545-630`); previously only 3 scalars showed.
  3. **Founder table** (Known/Female/Male counts + FE + FG) rendered on the Summary tab
     (monolith `server.r:558-570`) by threading `modGeneticValue`'s `founderStats` reactive into
     `modSummaryStatsServer` (new `founderStats` param; wired in `R/appServer.R`).
  4. **Kinship-matrix download** fixed: was a dead button (`req()` on a NULL `kinshipMatrix`
     arg with `appServer.R` passing `NULL`); now writes the module's internal `getKinshipMatrix()`.
- **TDD:** strict RED→GREEN (REFACTOR skipped — author decision). New discriminating tests in
  `tests/testthat/test_modSummaryStats_parity.R` (6 tests / 22 expectations); the z-score test
  uses ONLY the real `zScores` column so it fails on the singular-name bug — a pre-existing
  `_ggplots` test passed on the bug because its fixture injects both names (Learning #15/#20).
- **Author decisions (`AskUserQuestion`):** founder table → add to Summary tab (keep GVA subtab);
  kinship download → use the module's internal kinship (smallest change, no relationship-basis
  change — avoided the plan's "thread reportGV kinship" dragon).
- **Verification:** full suite under `pkgload::load_all` + `NOT_CRAN=true` = 0 failed / 0 error,
  2071 passed (+22), e2e skipped; lint net-zero (modSummaryStats 60=60, appServer 18=18);
  `devtools::document()` (only `man/modSummaryStatsServer.Rd`); runtime smoke — `runModularApp()`
  binds + HTTP 200. NEWS deferred to the Phase 9 canonical switch (modular app not yet canonical).
- **Files:** `R/modSummaryStats.R`, `R/appServer.R`, `man/modSummaryStatsServer.Rd`,
  `tests/testthat/test_modSummaryStats_parity.R`. Plan: `docs/planning/shiny-module-conversion-plan.md` §9 Phase 1.

### 2026-06-02 — PLAN: complete the Shiny-module conversion (XARCH-1 / issue #27) (Session 21)
- **Deliverable (planning, not implementation):** `docs/planning/shiny-module-conversion-plan.md`
  — a 9-phase, vertical-slice plan to declare the modular app (`runModularApp`/`appUI`/
  `appServer`/`mod*`) canonical, reach feature parity with the legacy monolith
  (`inst/application/`), enable the shinytest2 E2E tier, then delete the monolith and make
  `runGeneKeepR()` a `lifecycle::deprecate_soft` alias. Followed the ARCHITECTURE workstream +
  the SESSION_RUNNER Planning protocol (evidence-based grep inventory, per-phase done-criteria,
  vertical slices). The project's first planning/architecture deliverable.
- **Method:** a read-only 8-mapper discovery workflow + firsthand verification of every
  load-bearing claim + a 3-agent completeness-critic that caught 4 real parity gaps the
  single-pass synthesis missed (dead kinship-download button; dropped MK/GU quartile tables;
  FE/FG founder-table placement; a 100× breeding-`gpIter` default drift).
- **Author scope decisions (via `AskUserQuestion`):** full conversion (parity + E2E + retire);
  exclude ORIP/Settings (parity = match the monolith); re-expose the GU-threshold selector
  (default 4).
- **Key findings (reframe the audit):** the modular app is far more complete than
  `TECH_DEBT_AUDIT_2026-05-30.md` implied; the audit's "do XARCH-3/4/7 before XARCH-1"
  sequencing is moot (verified); the E2E suite is unwritten scaffolding (its driver helpers are
  defined nowhere) — this is the real scope of issue #39; issue #34 ("integrate qcStudbook in
  modInput") is stale (already integrated). No code changed this session.
- **Next:** implement **Phase 1 only** (Summary Statistics tab parity) under strict TDD.

### 2026-06-02 — Fix vacuous "no potential parent" assertion in `test_getPotentialParents.R` (Session 20)
- **Defect (found Session 4, fixed now):** the test "works with records with no
  potential parent" pushed BRI2MW's birth to 1950 into a local `ped` but then
  asserted the old top-level `potentialParents[[1L]]$id` from the *unmodified*
  fixture — a tautology already covered by the first test that never inspected
  `ped` and verified nothing about its named scenario (copy/paste slip).
- **Fix (REFACTOR-only under strict TDD; no production change):** replace the
  assertion with a discriminating one. BRI2MW is a from-center founder with both
  parents unknown that normally appears in the output; with its birth at 1950 its
  breeding-age candidate set is empty, so `getPotentialParents` correctly drops it
  via the no-breeding-age-candidate skip. The test now asserts BRI2MW is present
  in the unmodified fixture (precondition), absent from the scenario result, and
  that the result has exactly one fewer entry (50 → 49).
- **Why REFACTOR-only:** `getPotentialParents` is already correct, so a correct
  assertion is green-on-arrival; strict TDD forbids declaring RED on a passing
  test, and forcing a fail with a wrong expectation would be a synthetic RED
  (Learning #18c). Rigor instead came from a mutation check: disabling the skip
  makes both new assertions fail, proving the test discriminates (the old
  assertion passed against that same mutant).
- **Verification:** full suite under `load_all` + `NOT_CRAN=true`: **0 failed /
  0 error**, zero non-e2e offenders, **2049 passed** (+2 vs Session 19), 5
  pre-existing `modPyramid` warnings, e2e files skipped. Commit `6049445d`.

### 2026-06-02 — Resolve the E2E test-infra debt: add `create_test_app()` with an opt-in gate (Session 19)
- **Root cause:** the 23 `test-app-*`/`test-e2e-*` files call `create_test_app()`
  at **154 sites**, but the helper was never defined (it never existed in git
  history; the e2e scaffolding landed in `7da01afe` without it). Result: **154
  suite ERRORS** under `devtools::test()`/CI (`NOT_CRAN=true`), masked only by
  `skip_on_cran()` under a bare `testthat::test_dir()` — a suite that was clean
  or broken depending on the runner.
- **Fix (strict TDD, RED→GREEN; no REFACTOR needed):** define `create_test_app()`
  in `tests/testthat/helper-shinytest2.R`. It **skips** the calling test unless
  `NPRC_RUN_E2E=true`, and when opted in returns the existing `inst/shinytest`
  app dir (`app.R` = `shinyApp(appUI(), appServer)`) for `shinytest2::AppDriver`.
  The browser E2E suite stays **opt-in** (slow, needs Chrome, and depends on the
  modular-vs-monolith consolidation, XARCH-1) but is now one env var away from
  running; the default suite is honestly clean (154 errors → skips).
- **Discovery:** the prior E2E effort was ~90% complete, not lost scaffolding —
  the app is instrumented (`data-ready.js` + all six modules signal readiness),
  159 `test_that` blocks + wait/upload helpers + `.github/workflows/shinytest2.yaml`
  CI all exist; only `create_test_app()` was missing. Captured the remaining
  campaign (validate the 159 tests; wire CI; sequence with XARCH-1) as **GitHub
  issue #39** so the plan can't be lost again.
- **Verification:** new browser-free `tests/testthat/test_create_test_app.R` (opt-in
  returns app dir; gate raises a `skip` condition). Full suite under `load_all` +
  `NOT_CRAN=true`: **0 failed / 0 error**, 154 e2e errors → skips, zero non-e2e
  offenders, 2047 passed, 5 pre-existing `modPyramid` warnings. Lint net-zero
  (helper-shinytest2.R = 0 in-place). No `document()` (test helper, not package API).
- Commits: `a1ee8497` (test: helper + tests), + this `docs:` close-out.

### 2026-06-01 — Document the Mendelian ½ factor; drop the dead UID.founders block (NEW-22/NEW-30, Session 18)
- **NEW-22 (Mendelian ½ "hardcoded in 5 places"):** Session 17's NEW-13/NEW-23
  consolidation already removed the `calcFE`/`calcFG`/`calcFEFG` triplication, so
  the remaining `/ 2L` sites are *distinct* Mendelian formulas (parental-
  contribution average, parental-kinship average, self-kinship `(1+f)/2`, founder
  self-kinship init), **not** duplicated logic. Per the package author's decision
  the self-documenting literals are kept and a one-line Mendelian-½ comment is
  added at each site in `calcFounderContributions.R` and `kinship.R`; **no** named
  constant — one would over-couple distinct formulas across the GV compute and the
  kinship engine.
- **NEW-30 (dead/unused computed variables):** removed the genuinely-dead
  `## UID.founders <- …` commented block (and its `# nolint: commented_code_linter`
  wrapper) from `calcFounderContributions.R`. **Kept** `founderMatrix <- NULL` — it
  is an intentional memory free (drops the founders×founders identity block before
  the generation loop), not a dead variable as the audit claimed — now annotated.
- Comment + dead-code only; **zero behavior change**, proven byte-`identical()` on
  `calcFE`/`calcFG`/`calcFEFG` (character+factor), `calcFounderContributions` `$p`
  and `$ped`, `kinship()` dense+sparse, and the full `set.seed(42)` `reportGV()`
  object. Full suite under `load_all`: 0 failed / 0 error, 2001 passed; lint
  net-zero on both files; `document()` produced no man/NAMESPACE change. No
  `NEWS.md` entry — the change is internal-only with no user-facing effect.
  Commit `04115d97`.

### 2026-06-01 — Consolidate calcFE/calcFG/calcFEFG founder-contribution code (NEW-13/NEW-23, Session 17)
- The founder-contribution algorithm that `calcFE()`, `calcFG()`, and
  `calcFEFG()` shared near-verbatim (~45 lines each), together with the
  triplicated Session-7 partial-parentage `stop()` guard, now lives once in a
  new `@noRd` helper `calcFounderContributions(ped, caller)` that returns
  `list(p, ped)`. The three functions become thin wrappers (net -118 lines).
- Behaviour-preserving with no public-API change: signatures, return types, and
  the per-function error messages are byte-identical, and `calcFE()` stays
  gene-drop-free. Proven `identical()` on FE/FG over lacy1989Ped (character AND
  factor), the full `set.seed(42)` `reportGV()` object (the live `calcFEFG`
  caller), and all three guard messages; independently re-verified by a 3-agent
  adversarial equivalence workflow (static body-diff, 20 empirical OLD-vs-NEW
  edge tests, contract/guard/namespace) with 0 divergences.
- Full suite under `load_all`: 0 failed / 0 error, 2001 passed (+10 helper
  assertions). Lint net-zero; no man/NAMESPACE churn (`@noRd`).
- Out of scope (sibling audit items, not opted into): NEW-22 (hardcoded
  Mendelian 1/2), NEW-30 (dead vars - the `UID.founders` comment block was
  relocated intact), NEW-29/61 (founder-definition `^U` handling).
- Done under strict TDD (RED->GREEN->REFACTOR). Commits: `022afc8b` (helper +
  tests, GREEN), `2b27f4c3` (thin wrappers, REFACTOR), plus this close-out.

### 2026-06-01 — Extract getFounders()/isFounder() founder-detection helpers (PED-1/NEW-17, Session 16)
- Added two exported helper functions that define the founder predicate (an
  animal whose sire and dam are both unknown) in a single place:
  `isFounder(ped)` returns the logical mask `is.na(ped$sire) & is.na(ped$dam)`,
  and `getFounders(ped)` returns `ped$id[isFounder(ped)]`.
- Replaced the inline founder-detection idiom at 12 call sites across 9 files:
  `getFounders()` in `calcFE()`, `calcFEFG()`, `calcFG()`, `calcRetention()`,
  `orderReport()`, and `removeUninformativeFounders()`; `isFounder()` for the
  founder-row subset in `reportGV()`, the male/female founder exports in
  `modSummaryStats` (×2), and the founder counts in `modORIPReporting` (×4).
  `findPedigreeNumber()` was left as-is: it operates on bare `id`/`sire`/`dam`
  vectors with no `ped` object, so the `ped`-argument helpers do not fit it.
  `calcRetention()`'s adjacent `descendants` line was deliberately untouched —
  it alone filters by `ped$population`.
- Behaviour-preserving by construction and verified empirically: every
  refactored output proven `identical()` to a pre-refactor reference — the four
  `calc*` functions on the lacy1989 fixture, the full seeded `reportGV()` output,
  and the Shiny-module expressions on the qcPed fixture. Full suite
  0 failed / 0 error / 1991 passed; lint net-zero on all 11 files (the two new
  files and the seven compute files are lint-free; the two Shiny modules carry
  only pre-existing style debt, count unchanged between HEAD~1 and HEAD).
- An independent 4-angle completeness sweep (read-only workflow) re-derived the
  founder-detection inventory and converged on a single remaining inline site —
  `findPedigreeNumber.R:35`, the intentional exclusion — confirming no `R/` site
  was missed.
- Done under strict TDD (RED→GREEN→REFACTOR). Commits: `2758ffe6` (helpers +
  tests + NAMESPACE + man), `77f13d51` (calc* + orderReport), `a95828d6`
  (reportGV + removeUninformativeFounders + Shiny modules), plus this close-out.

### 2026-06-01 — Fix lower-quartile mislabel + bind-once refactor in summarizeKinshipValues (NEW-16, Session 15)
- Fixed NEW-16: `summarizeKinshipValues()` reported the `secondQuartile` column
  as `fivenum()[1]` (the minimum) instead of `fivenum()[2]` (the lower hinge),
  so the lower-quartile column silently duplicated `min`. It affected 5 of 153
  rows in the documented example pipeline. As with NEW-45, the audit's mechanism
  and prescribed fix were both correct; the pre-existing test happened to pass on
  the buggy output (its row-10 lower hinge equals that row's min), so a new
  synthetic test (`numbers = 1:5`, where the lower hinge 2 ≠ the min 1) was added
  to detect the mislabel. Fixed by `tukeys[1L]` → `tukeys[2L]`
  (`R/summarizeKinshipValues.R:106`); `thirdQuartile` (the upper hinge) was
  already correct.
- Refactored the O(n²) `rbind`-in-loop into a preallocated row list bound once
  with `do.call(rbind, …)` (O(n)). Proven behaviour-preserving: `identical()`
  output on the seeded example pipeline, the synthetic input, and the
  all-skipped/empty case (which still returns an empty `data.frame()`).
- Decision (author): `R/makeGeneticDiversityDashboard.R` (NEW-20) is **retained**
  as early-development work rather than deleted. It is already excluded from the
  package build via `.Rbuildignore` and defines no live function, so NEW-20 is
  closed as won't-delete (not the audit's "delete dead code"). A whitespace-only
  comment realignment in that file was committed first (`926f4606`).

### 2026-06-01 — Reject duplicate animal IDs in geneDrop (NEW-46, Session 14)
- Fixed NEW-46: `geneDrop()` crashed with the cryptic base-R error
  "duplicate 'row.names' are not allowed" (at `rownames(ped) <- ids`,
  `geneDrop.R:97`) when given duplicate animal ids — before any allele logic
  ran. The audit's "parent lookup by rowname; duplicate ids → wrong values" was
  empirically a hard crash, not silent corruption, and at the rownames
  assignment rather than the lookup (the NEW-48 pattern: audit mechanism wrong).
- Added an upfront guard (alongside the NEW-45 period guard) that rejects
  duplicate ids with a clear, actionable message ("animal IDs must be unique;
  duplicated id(s): …"), consistent with `kinship()` ("All id values must be
  unique") and `removeDuplicates()`. The unique-id invariant is a domain rule.
- Reachability was direct-`geneDrop()`-call only: the canonical
  `qcStudbook → reportGV → geneDrop` path is doubly masked — `removeDuplicates()`
  (qcStudbook) and `kinship()`'s own unique-id guard (called in `reportGV` before
  `geneDrop`). So no reportGV change was needed.
- Contract-preserving: today's behavior is already a crash, so no
  currently-succeeding call changes — only the diagnostic improves (Learning #8b).
- Strict TDD (RED→GREEN→REFACTOR). Full suite 0 failed / 0 error / 1971 passed;
  lint net-zero; `man/geneDrop.Rd` regenerated; no NAMESPACE change.

### 2026-05-31 — Enforce "no period in IDs" rule (NEW-45, Session 13)
- Fixed NEW-45: `geneDrop()` silently corrupted allele assignment for any `id`
  containing a period (".") — it rebuilt the id/parent columns by splitting
  flattened data.frame rownames on ".", so a period-bearing id was truncated and
  lost its sire/dam distinction. The documented ID domain forbids "."
  (`inst/extdata/ui_guidance/input_format.html`: id/sire/dam are "Alphanumeric
  characters (no symbols)").
- Enforced the rule rather than re-engineering `geneDrop` to support periods.
  New internal `hasInvalidIdChar()` defines the rule once and is used by:
  `qcStudbook()` (rejects period-bearing `id`/`sire`/`dam` at data input —
  `stop()` in default mode, `errorLst$invalidIdChars` when `reportErrors = TRUE`)
  and `geneDrop()` (defense-in-depth `stop()` for callers that bypass
  `qcStudbook`, e.g. the genetic-value Shiny module). Auto-generated IDs
  (`addUIds` `U####`, `obfuscateId`) are already period-free; locked with tests.
- Documented the feature with rationale (periods break across software
  environments) in roxygen, the live `input_format.html` spec, and `NEWS`.
- Strict TDD (RED→GREEN→REFACTOR). Full suite 0 failed / 0 error / 1961 passed;
  lint 0. Code commit `5e228bd9` (fix) + docs commit.

### 2026-05-31 — Methodology framework update (Session 10)
- Updated the embedded methodology to canonical `rmsharp/methodology` `f32d780`: synced
  `SESSION_RUNNER.md`, `SAFEGUARDS.md`, and `methodology_dashboard.py` byte-identical to
  canonical via `bin/sync`.
- Refreshed `docs/methodology/` framework docs (`ITERATIVE_METHODOLOGY.md`,
  `HOW_TO_USE.md`, `README.md`) and workstreams; added 4 new upstream workstreams
  (`INHERITED_CODEBASE_FAMILIARIZATION_CAMPAIGN`, `RESEARCH_DOCUMENTATION_WORKSTREAM`,
  `RESEARCH_EXHAUSTIVE_VERIFICATION_CAMPAIGN`, `TEMPLATE_CAMPAIGN`).
- Relocated the 10 project Learnings (from `SESSION_RUNNER.md`) and the R-package
  build-equivalent (from `SAFEGUARDS.md`) into `CLAUDE.md`'s "Project-Specific
  Methodology Adaptations" and "Build / Test / Verify" sections, so the synced files
  stay byte-identical to canonical.
- Created `CHANGELOG.md`, `ROADMAP.md`, `RECOMMENDED_SKILLS.md`; split `BACKLOG.md`
  (completed work → here; feature inventory → `ROADMAP.md`).

### 2026-05-30 – 2026-05-31 — PED/GV audit-fix campaign (Sessions 1–9, strict TDD)
- **Audits produced:** `TECH_DEBT_AUDIT_2026-05-30.md` (Session 1, read-only) and
  `PED_GV_AUDIT_2026-05-30.md` (Session 2 — re-audit of the PED & GV clusters;
  61 confirmed / 2 refuted findings).
- **Correctness bugs fixed** (each test-first under strict TDD, with regression tests):
  - NEW-15 — `countKinshipValues` wrong loop index corrupted accumulated kinship counts
    (the audit's only HIGH-severity bug). `b05133ca`
  - NEW-34 — `getPotentialParents` unbound-`j` crash when `pUnknown` is empty. `dc695a3b`
  - NEW-40 — `findGeneration` returned silent NA generations on cyclic pedigrees;
    now warns at the choke point. `ea5d28fa`
  - NEW-37 — `correctParentSex` silently overwrote recorded H/U parent sex to M/F. `6b0ae333`
  - NEW-48 — `calcFEFG`/`calcFE`/`calcFG` crashed on partial parentage; now a clear
    `stop()`. `19350559`
  - NEW-25 — `getProportionLow` crashed on empty input; now a clear `stop()`. `587ba042`
  - NEW-52 — `cumulateSimKinships` standard deviation undefined for n<2: n=1 → NA matrix +
    warning, n<1 → clear `stop()`. (Audit's catastrophic-cancellation mechanism empirically
    disproved as unreachable for dyadic-rational kinship values.) `e3c7e8b3`

## Earlier work (pre-methodology, migrated from BACKLOG.md history)
- Pyramid plot module update.
- Lint cleanup and unused-code removal.
- Changed package name to mprcgenekeepr for side-by-side development.
- Initial Shiny module commit structure.
