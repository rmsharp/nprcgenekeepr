# Plan — Completing the Shiny-Module Conversion (XARCH-1 / issue #27)

**Status:** PLAN (deliverable of Session 21, 2026-06-02). Not yet executed. Implementation happens in later sessions, one phase per session.
**Author decision basis:** Session 21 `AskUserQuestion` (scope, ORIP/Settings, GU threshold — see §3).
**Related:** GitHub issue **#27** (Modularize code using shiny modules), issue **#39** (Complete & validate the shinytest2 E2E suite), issue **#34** (Integrate `qcStudbook()` in modInput — *now stale, see §6*), audit findings **XARCH-1/2/7**, **APP-3/7/8/13/14/16/17**, **MISC-9** in `TECH_DEBT_AUDIT_2026-05-30.md`.
**Evidence:** built from a read-only 8-mapper discovery workflow (`wf_2b9863c9-615`) plus firsthand verification of every load-bearing claim by Session 21 (the audit is stale in places — see §11).

---

## 1. Context

`nprcgenekeepr` ships **two coexisting Shiny applications** (XARCH-1, the audit's single highest-risk finding):

| App | Launcher | Entry | Port | Tests |
|---|---|---|---|---|
| **Legacy monolith** | `runGeneKeepR()` (`R/runGenekeepr.R:18-29`) | `system.file("application")` → `inst/application/server.r` (1304 L) + `ui.r` (53 L, sources 8 `uitp*.R`) | 6012 | ~none direct |
| **Modular (target)** | `runModularApp()` (`R/runModularApp.R:38-44`) | `shinyApp(appUI(), appServer)` (`R/appUI.R` 205 L + `R/appServer.R` 287 L + 9 `R/mod*.R`) | 6013 | extensive `test_mod*` units + (unwritten) E2E tier |

Every feature exists twice; the two have drifted (different navbar ids, different defaults, one fixes a bug the other has). Maintaining both is the single biggest friction for adding features.

**"Completing the conversion" = declare the modular app canonical, bring it to feature parity with the monolith, validate it, then retire the monolith** (make `runGeneKeepR` a deprecated alias and delete `inst/application/`). This closes issue #27 and XARCH-1.

### Constraints (hard)
- **Strict TDD** (CLAUDE.md "Development Process Contract"): every implementation session is RED→GREEN→REFACTOR with phase gates. Each parity slice needs a **discriminating RED test** — on an input where *missing-feature ≠ present-feature* (Learnings #15/#20: a pre-existing test can pass on the absent/NULL output).
- **One deliverable per session** (`SESSION_RUNNER.md`): each phase below is **one session**; close out when its done-criteria are met. Do not bundle phases (FM #18).
- **Vertical slices, not horizontal layers** (FM #25): each phase ships one feature end-to-end (UI + server + test) and leaves the app working. No "all tests then all impl."
- **Build-equivalent** (CLAUDE.md "Build / Test / Verify"): `devtools::check()` clean for the final phase; the per-phase regression read is the fast gate (§13).
- **Backward compatibility for users**: `runGeneKeepR()` must keep working (as an alias) after retirement — current users and the vignette call it.

---

## 2. Target end state (the Decision)

The **modular app is canonical**. Concretely, when this campaign completes:

1. The modular app (`appUI`/`appServer`/`mod*`) implements every monolith feature (the §6 parity gap closed).
2. The shinytest2 E2E tier is **executable and green** (or cleanly skipped) — the missing driver helpers authored (§9 Phase 8).
3. `inst/application/` is **deleted** (server.r, ui.r, global.R, 8 `uitp*.R`, `example_1.R`, the dead `modPyramid.R` stub, `www/`).
4. `runGeneKeepR()` is a **thin `lifecycle::deprecate_soft` alias** that launches the modular app. (Its current signature is zero-arg with port hardcoded to 6012; the alias **adds** optional `port`/`launch.browser` args defaulting to the modular app's — existing zero-arg callers keep working.)
5. Confirmed orphans removed (§10): `getMinParentAge` (true dead code), `getLogo` (monolith-only), and `modMinimalTest`/`shouldShowErrorTab` per the decisions in §16.
6. Docs/vignettes/CI/pkgdown updated; issues #27 closed, #39 closed/relabeled.

---

## 3. Scope decisions (Session 21 author/owner calls — locked)

| # | Decision | Choice | Consequence |
|---|---|---|---|
| 1 | Plan scope | **Full: parity + E2E + retire monolith** | All 9 phases below, ending in deletion + alias. |
| 2 | ORIP reporting + Settings/About/Help | **Exclude both** — parity means matching the monolith, which has neither functional | `modORIPReporting` stays **unwired, undeleted** (future feature, own issue). Settings/About/Help placeholders stay as-is (out of scope; the stale "Version 1.0.8" string in `appUI.R:181-203` vs DESCRIPTION `1.1.0.9000` is a trivial aside, not a phase). |
| 3 | GVA genome-uniqueness threshold | **Re-expose the user selector, default 4** (monolith parity) | Phase 3 restores the `selectInput` control + threads `guThresh` from input, replacing the hardcoded `1L`. |

**Explicitly OUT of scope:** wiring `modORIPReporting`; functional Settings/About/Help; the XARCH-4 species-profile schema (orthogonal — §8); the XARCH-2 *full* "typed module contract" formalization (only the parity-breaking parts are touched — §8); the broad lint debt (issue #30); deep behavior-equivalence refactors of the compute core (only prove-`identical()` touch-ups where a parity slice forces them).

---

## 4. Current architecture (verified)

**Modular core (`R/appServer.R`):** one `shared <- reactiveValues(config, currentStudbook, currentPedigree, qcResults, geneticValues)` (L47-53). Modules are wired in order: `modInputServer` → (dynamic-tab observer) → `modPedigreeServer` → `modPyramidServer` → `modGeneticValueServer` → `modSummaryStatsServer` → `modBreedingGroupsServer`. appServer bridges modules by writing each module's returned reactives into `shared` and passing `reactive(shared$…)` downstream (the **implicit module contract**, XARCH-2). `shared$qcResults` is written (L111) but never read — dead write.

**Module contract (XARCH-2):** each `modXServer(id, <reactive args>)` returns a **named list of `reactive()` closures**. Cross-module renames happen at the consumer: `modGeneticValue` renames `indivMeanKin`→`meanKinship`, `gu`→`genomeUniqueness` (`R/modGeneticValue.R:262-267`) for `modSummaryStats`. `kinshipMatrix=NULL` is passed to `modSummaryStats` (`appServer.R:278`), forcing it + `modBreedingGroups` to **re-derive kinship** independently (correct but redundant; the rename also dead-codes the breeding module's reuse branch at `modBreedingGroups.R:132`).

**Dynamic tabs (APP-14):** `appServer.R:161-240` insert/remove "Error List" + "Changed Columns" tabs on navbar `id="mainNavbar"`, gated by `checkErrorLst()` + `shouldShowChangedColsTab()`. Covered by `test_appServer_dynamicTabs.R` (19 tests). Note the exported `shouldShowErrorTab()` is **bypassed** (appServer uses `checkErrorLst` instead) yet appServer builds a `qcResults` struct "for" it — half-wired (§16).

**9 modules** (`modInput`, `modPedigree`, `modPyramid`, `modGeneticValue`, `modSummaryStats`, `modBreedingGroups`, `modGvAndBgDesc`, `modORIPReporting`, `modMinimalTest`) — only the first 6 are mounted in `appUI`/`appServer`.

---

## 5. Module-contract note (XARCH-2, light)

This plan does **not** formalize a typed module contract (out of scope, §3). It touches the contract surface **only** where a parity gap lives on it:
- the `zScores`/`zScore` name mismatch (Phase 1) is a contract bug;
- the `kinshipMatrix=NULL` double-derivation (Phase 5) is optionally cleaned only if Phase 5 needs the matrix threaded — and then **proven `identical()`** vs current group output, never riding along untested in a parity slice (dragon).

The full typed-contract / column-standardize-at-source work (XARCH-2) is deferred to a separate issue after the monolith is gone.

---

## 6. Feature-parity gap (the crux — verified firsthand)

Status legend: ✅ parity · ◐ partial/broken · ✗ missing in modular · ⊖ monolith-only-dead (no parity owed).

| Feature | Status | Monolith | Modular | Phase |
|---|---|---|---|---|
| Studbook QC (`qcStudbook`) | ✅ | server.r:171,204 | `modInput.R:344-390` calls `qcStudbook` **and** `runQcStudbook` (up to 3 passes) — **real QC is integrated; issue #34's "placeholder" is STALE** | — (XARCH-6 redundancy = future polish) |
| Pedigree browser (DT, focal textarea, trim, U-id toggle, export) | ✅ | server.r:250-335,402-409 | `modPedigree.R:194-348` — full match incl. export | — |
| Age-Sex pyramid | ✅ (modular is superset) | server.r:1302 (bare plot, no controls/download) | `modPyramid.R:84-153` real `getPyramidPlot` + controls + stats + PNG | — |
| **Z-score histogram + boxplot** | ◐ **dead bug** | server.r:664,747 read `zScores` correctly | `modSummaryStats.R:396,477` check `"zScore"` (singular); `reportGV.R:89,144` emit `zScores` (plural) → plots return NULL | **1** |
| GvAndBgDesc info tab | ✅ (mounted S23) | `uitpGvAndBgDesc.R` live tab | `modGvAndBgDesc` built + tested; **mounted** in appUI/appServer (S23 `ef6a9f4c`) | **2 ✅** |
| GVA genome-uniqueness threshold | ✅ (S24) | user `selectInput` default 4 (`uitpGeneticValueAnalysis.R:38-49`) | `selectInput` (choices 1–5, default 4) threaded via `guThreshold()` reactive (`modGeneticValue.R`); replaced hardcoded `1L` (S24 `596f6bc9`→Phase 3) | **3 ✅** |
| GVA subset/filter view + "Export Subset" | ✅ (S24) | `gvaView`+`filterReport`+`downloadGVASubset` (server.r:462-511) | `gvaView()` + `viewIds` textarea + "Filter View" + `downloadGVASubset` added to the Rankings tab (S24) | **3 ✅** |
| **Genotype file merge** (separate / common ped+geno) | ✗ | `getGenotypes`/`checkGenotypeFile`/`addGenotype` (server.r:117-156) | UI offers the radio options but `activeFile` ignores `genotypeFile`; **no `getGenotypes`/`addGenotype` call anywhere in modular** | **4** |
| Breeding groups: downloads (group CSV, group-kinship CSV) | ✗ | server.r:1283-1297 | **0 download handlers** in `modBreedingGroups.R` | **5** |
| Breeding groups: per-group kinship matrix + `viewGrp` selector | ✗ | server.r:1197-1280 | Statistics tab is counts-only (`modBreedingGroups.R:282-300`) | **5** |
| Breeding groups: seed-animal "current groups" pre-seeding | ✗ | `textAreaWidget`/`getCurrentGroups`/`output$currentGroups` (server.r:1019-1051) | `currentGroups=list(character(0))` hardcoded (`modBreedingGroups.R:203`) | **6** |
| Breeding groups: inert controls (`minAge`/`nIterations`/`withKinship`) | ◐ | exposed | read by server (`modBreedingGroups.R:187-189`) but **UI never declares them** → silently default 1.0/1000/FALSE | **6** |
| **Focal-animal / LabKey pedigree build** | ✗ | `getFocalAnimalPed`/`getLkDirectRelatives` (server.r:86-113) | UI offers "Focal animals only; pedigree built from database" but **no LabKey/focal call anywhere in modular** | **7** (dragon) |
| Summary-stats downloads: founders, first-order, relationships, 6 PNGs | ✅ (modular fixes monolith's empty-`write.csv` bug & adds RelationClasses) | server.r:402-532,857-899 | `modSummaryStats.R:593-691` (12 handlers) | — |
| **Summary-stats download: kinship matrix** | ◐ **dead button** | server.r:524-532 writes `geneticValue()[['kinship']]` | `modSummaryStats.R:595` does `req(kinshipMatrix)` but `appServer.R:278` passes `kinshipMatrix = NULL` → `req(NULL)` halts → CSV never written (and `kinshipMatrix()` would error — NULL isn't a function) | **1** |
| **Summary-stats MK/GU distribution tables** (Min/Q1/Mean/Median/Q3/Max) | ✗ **dropped** | server.r:545-630 renders both `summary(indivMeanKin)` + `summary(gu)` HTML tables | `modSummaryStats.R:532-535` renderUI shows only 3 scalars (Animals analyzed / Mean kinship / Genome uniqueness) — no quartile table | **1** |
| Founder table: Known/Female/Male counts + FE/FG | ◐ **placement gap** | server.r:558-570 renders it in the **Summary Statistics** tab | modular renders FE/FG (+counts) on the **GVA Summary subtab** (`modGeneticValue.R:220-232`); `modSummaryStats` summaryData omits it (`founderStats` not threaded) | **1** (thread to Summary tab; confirm placement w/ owner) |
| Debug toggle (logger threshold) | ◐ inert | server.r:19-23 `flog.threshold(DEBUG)` on `input$debugger` | `modInput.R:533` returns `debugMode` but **no consumer** calls `flog.threshold` | out-of-scope cosmetic (§3) — note only |
| Boxplot popovers (shinyBS) | ◐ | server.r:800-818 | popover plumbing exists; z-score box dead until Phase 1 | folded into **1** |
| ORIP reporting tab | ⊖ | `uitpOripReporting.R` commented-out/DEAD; server.r has **zero** ORIP logic | `modORIPReporting` exists, unwired, under development | **out of scope** (§3) |
| Home landing tab | modular-only | none | `appUI.R:24-115` jumbotron + 6 goto buttons | — (enhancement, keep) |
| Settings/About/Help | modular-only placeholders | none | static stubs (`appUI.R:174-203`), stale "1.0.8" | **out of scope** (§3) |

---

## 7. Drift (same feature, different behavior — resolve during the relevant phase)

- **Navbar id:** monolith `tab_pages` vs modular `mainNavbar` — monolith tab code is **not** portable; rebuild against `mainNavbar`.
- **minParentAge:** monolith mutable global `globalMinParentAge<<-` default 3.0 (`global.R:3`, `server.r:73`) vs modular `input$minParentAge` reactive, NA→2.0 fallback (`modInput.R:337-342`). Modular has **no global** — retired by deletion (XARCH-7).
- **GU threshold default:** 4 (monolith) vs 1 (modular) → resolved to **4 + user control** (decision §3).
- **GVA gene-drop iterations default:** 1000 (monolith `uitpGeneticValueAnalysis.R:27`) vs 5000 (modular `modGeneticValue.R:37`) — confirm in Phase 3 (recommend 1000 for parity).
- **Breeding-sim iterations default:** **10** (monolith `gpIter`, `uitpBreedingGroupFormation.R:155-161`) vs 1000 (modular fallback `modBreedingGroups.R:188`) — a 100× drift; resolve to 10 in Phase 6. **Distinct** from the GVA gene-drop count above — do not conflate.
- **Debug toggle:** monolith toggles `flog.threshold(DEBUG)` (server.r:19-23); modular `debugMode` reactive (`modInput.R:533`) has no consumer → inert. Out-of-scope cosmetic (§3); wire to `flog.threshold` in appServer only if owner wants it.
- **downloadRelations:** monolith broken (empty `write.csv`, server.r:897); modular correct — modular wins, no action.
- **Plot/table code:** `modSummaryStats.R:367-522` ggplot builders are duplicated from server.r — the duplicate vanishes when the monolith is deleted (Phase 9); do **not** pre-refactor.

---

## 8. Prerequisite assessment — the audit's sequencing is largely MOOT (verified)

The audit advised doing XARCH-3/4/7 *before* XARCH-1. Verified firsthand, that advice no longer applies:

| Item | Classification | Why |
|---|---|---|
| **XARCH-3** (Shiny out of compute) | **SEPARABLE / mostly done** | `reportGV` + `groupAddAssign` are already shiny-free with an injected `updateProgress` hook; modules supply the Progress adapter. The only real leak, `getMinParentAge` (`@import shiny`), is a **dead orphan** (0 callers) → handled as cleanup in Phase 9, not a prerequisite. |
| **XARCH-4** (species profile) | **SEPARABLE** | Concept doesn't exist anywhere; orthogonal to module conversion. Do not block on it. |
| **XARCH-7** (kill global / site registry) | **SEPARABLE / auto-resolved** | `globalMinParentAge<<-` lives **only** in the monolith → **retired by deletion**. The modular app already uses `shared` reactiveValues. |
| **XARCH-2** (module contract) | **ENTANGLED (partial)** | Touched only where parity lives on it (Phase 1 `zScores`; optional Phase 5 kinship threading). Full formalization deferred. |
| **XARCH-1** (this campaign) | **THE DELIVERABLE** | Real prerequisites are the §6 parity gaps + the E2E blocker — **not** XARCH-3/4. |

**Conclusion:** proceed directly to parity slices; no schema/decoupling pre-work required.

---

## 9. Migration path — 9 vertical-slice phases (each = ONE session)

Each phase: one TDD session (RED→GREEN→REFACTOR with gates), leaves the app working, has explicit done-criteria + a verification command + a session boundary. Phases 1–7 are parity (largely independent — order is low→high risk, not a hard dependency chain). Phase 8 validates. Phase 9 retires (irreversible; depends on **all** prior).

> **Per-phase regression read** (the fast gate, from CLAUDE.md + Learnings #15b/#19b):
> ```r
> NOT_CRAN=true Rscript -e 'suppressMessages(pkgload::load_all(".", quiet=TRUE));
>   r <- as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE));
>   cat("failed:", sum(r$failed), " error:", sum(r$error), "\n");
>   o <- r[!grepl("test-app-|test-e2e-", r$file) & (r$failed>0 | r$error>0), c("file","failed","error")]; print(o)'
> ```
> Pass = 0 failed / 0 error among non-e2e files (the e2e files skip without `NPRC_RUN_E2E=true`).

---

### Phase 1 — Summary Statistics tab parity · risk LOW–MEDIUM · ✅ DONE (Session 22, commit `596f6bc9`)
This phase brings the modular **Summary Statistics tab** to monolith parity across **four** verified gaps (all in `modSummaryStats`). **May split into 1a/1b if one TDD session runs long** (see split note).

> **✅ Implemented in Session 22 (`596f6bc9`), all four items, no split.** Decisions taken: founder table **added to the Summary tab** (§16.6) + kinship download uses the **module-internal `getKinshipMatrix()`** (§16.8 — avoided the thread-`reportGV`-kinship dragon). The z-score column is confirmed **`zScores`** (plural) end-to-end; fixed via a dual-name lookup. Tests: `tests/testthat/test_modSummaryStats_parity.R` (6 / 22). Suite 0/0, runtime-smoked. **Next: Phase 2.**
- **Goal (four items):**
  1. **Z-score plots:** the z-score histogram + boxplot (+ popover + 2 PNG downloads) render. Resolve the `zScores`(plural, `reportGV.R:89,144`)/`zScore`(singular, `modSummaryStats.R:396,400,477,481`) mismatch. ⚠ **Trace the real column name first:** data flows `reportGV` (`zScores`) → `modGeneticValue` (renames *some* cols — confirm it passes `zScores` through unchanged) → `modSummaryStats`; read the name that **actually arrives** (print `names(gv)`).
  2. **MK/GU distribution tables:** render the Mean-Kinship and Genome-Uniqueness Min/1st-Q/Mean/Median/3rd-Q/Max tables (`summary()` of each), matching server.r:545-630. Currently `modSummaryStats.R:532-535` shows only 3 scalars.
  3. **Founder table:** render Known/Female/Male founder counts + FE + FG on the Summary Statistics tab (server.r:558-570), threading `modGeneticValue`'s `founderStats` (currently only on the GVA Summary subtab). **Owner confirm:** duplicate on Summary tab (monolith parity) vs leave on GVA tab.
  4. **Fix the kinship download:** `downloadKinship` is a dead button (`req(kinshipMatrix)` with `kinshipMatrix=NULL` from `appServer.R:278`). Either thread `gvResults$kinshipMatrix` into `modSummaryStatsServer` (appServer.R:278) or have the handler use the module's internally-derived kinship. If threading the matrix, **prove `identical()`** the display kinship is unchanged.
- **RED (discriminating, per item):** (1) z-score hist + box reactives return a `ggplot` (non-NULL) on a seeded GV result — a pre-existing `test_modSummaryStats_ggplots.R` test may **pass on the NULL** path, so RED must fail on the singular-name bug (Learning #15/#20); (2) the MK/GU table output contains the quartile labels for a seeded result; (3) founder counts+FE+FG present in the Summary tab output; (4) the kinship CSV download writes a non-empty matrix.
- **DONE:** all four render/work for seeded input; mean-kinship + GU plots unchanged; the 3rd box popover target is live.
- **Verify:** `NOT_CRAN=true Rscript -e 'suppressMessages(pkgload::load_all(".")); testthat::test_file("tests/testthat/test_modSummaryStats.R", reporter="summary"); testthat::test_file("tests/testthat/test_modSummaryStats_ggplots.R", reporter="summary")'` + the regression read.
- **Split note (one-deliverable safety, cf. FM #18):** if the single session runs long, split into **1a** (visualizations: z-score plots + popovers) and **1b** (tables + download: MK/GU quartile tables, founder table threading, kinship-download fix). Each is independently shippable.
- **Session boundary:** close out when the Summary Statistics tab matches the monolith + regression clean.

### Phase 2 — Wire the GvAndBgDesc description tab · risk LOW · ✅ DONE (Session 23, commit `ef6a9f4c`)

> **✅ Implemented in Session 23 (`ef6a9f4c`).** Mounted `modGvAndBgDescUI("gvAndBgDesc")` as a `tabPanel` after "Breeding Groups" (monolith-parity placement, per `inst/application/ui.r`) in `appUI`, and `modGvAndBgDescServer("gvAndBgDesc")` in `appServer`. **Verify-first gotcha (Learning #23):** the module's H3 heading collides with `genetic_value.html` (mounted by `modGeneticValue`), so the discriminating RED keys on `gvAndBgDesc.html`'s unique body text, not the heading. `modGvAndBgDescUI` does not call `NS()` → no namespaced container; the included content is the mount marker. Dynamic insert/remove tabs unaffected (new tab far from the "Input" target). Suite 0/0, runtime-smoked (HTTP 200). **Next: Phase 3.**
- **Goal:** mount the already-built `modGvAndBgDesc` as a tab so the modular app has the monolith's GV-and-BG description tab.
- **RED:** assert `appUI()` HTML contains the GvAndBgDesc tab/namespaced container (currently absent — `grep GvAndBgDesc R/appUI.R` = none).
- **DONE:** `appUI` renders the tab via `modGvAndBgDescUI`; `appServer` calls `modGvAndBgDescServer`; content shows; **tab order documented** and its interaction with the dynamic insert/remove tabs (after "Input") confirmed not to break `test_appServer_dynamicTabs.R`.
- **Verify:** `testthat::test_file("tests/testthat/test_appServer_dynamicTabs.R")` + a new appUI-contains-tab test + regression read.
- **Session boundary:** close out when the tab renders + dynamic-tab tests pass.

### Phase 3 — GVA parity: GU-threshold control + subset/filter export · risk MEDIUM · ✅ DONE (Session 24)

> **✅ Implemented in Session 24, whole phase (no split).** All in `R/modGeneticValue.R`.
> Author decisions (USER): **direct** threshold mapping (`selectInput` choices 1–5, `selected=4` →
> threads the integer 4 directly, dropping the monolith's confusing label-offset while keeping
> numeric parity); gene-drop iterations default **1000**; **remove** the inert `minAge` slider
> (the 2 sibling inert checkboxes `calcGenomeUniqueness`/`calcMeanKinship` deferred — same class,
> noted for a future cleanup); whole Phase 3 in one session. Threshold threaded via a new
> `guThreshold()` reactive (default `is.null`-guarded to 4L). Subset = `gvaView()` filtering
> `gvResults()` by parsed `viewIds` (base `trimws`, not the unimported `stri_trim`) via the
> exported `filterReport()`; `downloadGVASubset` writes it; `downloadRankings` relabeled
> "Export All". **Discriminating-RED**: keyed the threshold on the internal `guThreshold()`
> reactive (no existing test pinned guThresh → all passed on the buggy `1L`); the iterations
> assertion re-keyed on `value="1000"` (`grepl("1000")` matched `max="10000"`). Suite 0/0;
> lint net-zero; `document()` no delta; runtime-smoked (HTTP 200, controls render, minAge gone).
> **Next: Phase 4.**
- **Goal:** re-expose the genome-uniqueness threshold as a user `selectInput` **default 4** (decision §3), threading `guThresh` from input (replacing `modGeneticValue.R:165` `1L`); add the filtered-subset view (`filterReport` by selected ids) + an "Export Subset" download (monolith `gvaView`/`downloadGVASubset`, server.r:462-511). Resolve the inert `minAge` slider (`modGeneticValue.R:43`, `input$minAge` never read) — wire it or remove it.
- **⚠ Offset-mapping trap:** the monolith `selectInput` maps **display label N → value N+1** (`uitpGeneticValueAnalysis.R:38-49`: choices `"0"=1L … "4"=5L`, `selected=4L`) and threads `guThresh = as.integer(input$threshold)` (server.r:447). So "default 4" means the **threaded integer `guThresh` = 4** (which the monolith displays as label "3"). Decide whether to preserve this confusing offset or use a direct `0..4`/`1..5` mapping — and make the RED assert the **threaded integer**, not the selectInput label.
- **RED:** (a) `reportGV` called with `guThresh = the threaded integer` (= 4, not 1L) — assert on a fixture where threshold 4 vs 1 give different `gu`; (b) subset filter returns the filtered rows; (c) the inert-slider decision is tested (read or gone).
- **DONE:** threshold control present + threaded (integer 4); subset view filters rankings; `downloadGVASubset` writes the filtered table; `minAge` resolved; **gene-drop iterations default confirmed** (§7: monolith 1000 vs modular 5000 — recommend 1000 for parity).
- **Verify:** `NOT_CRAN=true Rscript -e 'suppressMessages(pkgload::load_all(".")); testthat::test_file("tests/testthat/test_modGeneticValue.R", reporter="summary")'` + new tests + regression read.
- **Dragon:** changing `guThresh` 1→4 changes numeric output — this is *intended* parity (decision §3); document it in the phase's NEWS bullet.
- **Split note:** Phase 3 bundles three separable sub-features (GU-threshold thread; subset/filter view + Export Subset; inert-`minAge` resolution). They share `modGeneticValue` + one TDD cycle, but if the session runs long, split **3a** (GU-threshold thread — the highest-value numeric-parity item) and **3b** (subset view + Export Subset + `minAge`).
- **Session boundary:** close out when threshold control + subset export work.

### Phase 4 — Input parity: genotype file merge · risk MEDIUM
- **Goal:** make the `separatePedGenoFile` and `commonPedGenoFile` paths actually merge genotypes — wire `getGenotypes`/`checkGenotypeFile`/`addGenotype` (none called in modular today) so `input$genotypeFile` is read and merged, and `genotypeData` (`modInput.R:513-516`, currently always NULL) is populated.
- **RED:** assert that uploading a pedigree + a genotype file yields a studbook with the genotype columns attached (`modInput`'s `genotypeData()` non-NULL; cleaned studbook carries genotypes) — fails today because `activeFile` drops `genotypeFile`.
- **DONE:** genotype merge works for both common and separate file modes; QC + downstream GV unaffected when no genotype file is supplied.
- **Verify:** `testthat::test_file("tests/testthat/test_modInput.R")` + `test_modInput_qcStudbook.R` + new genotype-merge test + regression read.
- **Session boundary:** close out when genotype merge works end-to-end.

### Phase 5 — Breeding Groups parity A: downloads + per-group kinship + group selector · risk MEDIUM
- **Goal:** close the largest parity hole's display/export half: add `downloadGroup` (group CSV) + `downloadGroupKin` (group-kinship CSV) handlers; render the **per-group kinship matrix**; add the `viewGrp` group selector + sex/age-annotated member view (monolith server.r:1197-1297).
- **RED:** after forming groups, assert (a) the group-CSV and group-kinship-CSV download contents are non-empty/correct; (b) selecting a group yields its kinship matrix. Today: `grep downloadHandler R/modBreedingGroups.R` = 0.
- **DONE:** user selects a group, sees its kinship matrix + annotated members, downloads both CSVs; **group-formation compute path unchanged** (prove `identical()` vs current `groups()` output — display/download only).
- **⚠ Dragon:** this threads `gvResults`/kinship into the view (XARCH-2 surface). If you thread `gvResults$kinshipMatrix` to avoid re-derivation, that's a behavior-equivalence refactor — **prove `identical()`**, don't let it ride untested.
- **Verify:** `testthat::test_file("tests/testthat/test_modBreedingGroups.R")` + new tests + regression read.
- **Session boundary:** close out when downloads + per-group kinship view work.

### Phase 6 — Breeding Groups parity B: seed-group pre-seeding + expose inert controls · risk MEDIUM
- **Goal:** add the monolith's seed-animal "current groups" widget (pre-seed groups before formation — `textAreaWidget`/`getCurrentGroups`, server.r:1019-1051), replacing the hardcoded `currentGroups=list(character(0))` (`modBreedingGroups.R:203`); surface the controls the server reads but the UI never declares (`minAge`/`nIterations`/`withKinship`, `modBreedingGroups.R:187-189`) so they stop silently defaulting.
- **⚠ Iteration default is 10, NOT 1000:** the monolith breeding-simulation count is `gpIter` **value=10L** (`uitpBreedingGroupFormation.R:155-161`, "Number of simulations") — distinct from the GVA gene-drop iterations (1000, §7/§16). The modular fallback is `1000L` (`modBreedingGroups.R:188`) — a 100× drift. Set the breeding `nIterations` control default to **10** for parity.
- **RED:** assert (a) seeded groups change `groupAddAssign`'s result vs empty seeds; (b) the three inputs are actually passed to `groupAddAssign` (not the 1.0/1000/FALSE fallbacks).
- **DONE:** dynamic `numGp`-driven seed textareas feed `currentGroups`; the 3 controls exist + are read; defaults match the monolith (**breeding iterations default 10**, minAge per monolith, withKinship FALSE).
- **⚠ Dragon:** the dynamic variable-count seed textareas are fiddly (monolith builds `input$numGp` of them) — risk of breaking the formation path; RED-test seeded-vs-empty difference.
- **Verify:** `testthat::test_file("tests/testthat/test_modBreedingGroups.R")` + new tests + regression read.
- **Session boundary:** close out when pre-seeding + controls work.

### Phase 7 — Input parity: focal-animal / LabKey pedigree build · risk HIGH 🐉
- **Goal:** implement the "Focal animals only; pedigree built from database" path — wire `getFocalAnimalPed`/`getLkDirectRelatives` so `input$breederFile` builds a pedigree from the LabKey EHR (monolith server.r:86-113). None of these are called in the modular path today.
- **🐉 HERE BE DRAGONS — likely needs its own sub-plan / owner consult before implementing:**
  - Requires `Rlabkey` + a **live or mocked EHR**; ONPRC-specific; **cannot be unit/E2E tested without a LabKey mock**. Confirm with the owner: mock (`mockery::stub` `getLkDirectRelatives`, as `test_getFocalAnimalPed.R` already does) vs a live integration test vs gating this source behind site config.
  - This is the parity item most likely to need a dedicated planning sub-session. If the owner decides focal-animal is **not** required for the modular app (e.g. scripts use `getFocalAnimalPed` directly), this phase may be **descoped** and the radio option removed instead — a smaller parity decision to confirm at phase start.
- **RED:** with `getLkDirectRelatives` stubbed, assert the focal-animals upload yields a built pedigree (mirrors `test_getFocalAnimalPed.R`'s mocking).
- **DONE:** focal-animals path builds a pedigree (under mock); **or** owner-approved descope (remove the radio option + RED becomes "option absent").
- **Verify:** `testthat::test_file("tests/testthat/test_modInput.R")` + mocked focal-animal test + regression read. **Verification is limited** (no live EHR) — state this explicitly in the session notes (not FM #24).
- **Session boundary:** close out when the focal path works under mock (or is descoped).

### Phase 8 — Enable the shinytest2 E2E harness end-to-end · risk HIGH 🐉
- **Goal:** make the E2E tier executable. Author the **missing driver helpers** `create_app_driver`/`navigate_to_tab`/`get_html_safe` (defined nowhere; never in git — verified), fix the namespace mismatch, get the suite to run green (or skip cleanly) under `NPRC_RUN_E2E=true`.
- **🐉 DRAGONS (verified):**
  - **The E2E suite is unwritten theatre:** 20/22 AppDriver files (155 `test_that`) call the 3 undefined helpers → they **error before asserting**. "shinytest2 coverage exists" is false; authoring the helpers is the deliverable.
  - **Namespace mismatch:** `appUI` mounts input as namespace `dataInput` (`appUI.R:123`) → real selectors are `#dataInput-…`; but `helper-shinytest2.R` hardcodes `module_id="input"`/`input-pedigreeFileOne` (the static `data-module="input"` attr is **not** the namespace). Selectors won't resolve until fixed.
  - **Assertions are shallow:** the AppDriver tests use `grepl`-on-body-HTML keyword checks, not behavioral assertions; the data-ready polling infra (`wait_for_module_ready`/`upload_and_wait`) is referenced by **zero** driving tests. True parity-via-E2E means *strengthening* assertions, not just running them.
  - **Browser-dependent + never-run:** needs chromote/Chromium; triage first-run failures iteratively. Gate behind `NPRC_RUN_E2E=true` (S19's opt-in gate) so non-E2E CI stays green.
- **DONE:** under `NPRC_RUN_E2E=true` the e2e files reach assertions (no "could not find function"); at minimum the smoke files (`test-app-loading`/`test-app-navigation` + the 6 module files) pass against `inst/shinytest/app.R`; CI updated to run them opt-in.
- **Verify:** `NPRC_RUN_E2E=true NOT_CRAN=true Rscript -e 'suppressMessages(pkgload::load_all(".")); testthat::test_dir("tests/testthat", filter="^(app|e2e)-", reporter="summary")'` — 0 "could not find function". (Use the **hyphen** prefix `^(app|e2e)-`: testthat strips `test[-_]`, so the e2e tier files `test-app-*`/`test-e2e-*` become `app-…`/`e2e-…`; a bare `e2e|app` would also pull in the unit files `test_appServer_dynamicTabs.R`/`test_create_test_app.R`.)
- **Note:** this is the work issue **#39** tracks; this phase *is* #39's resolution. May itself need decomposition (smoke first, then per-module, then assertion-strengthening) — consider a sub-plan if first-run triage explodes.
- **Session boundary:** close out when the smoke tier runs green opt-in.

### Phase 9 — Declare canonical: alias `runGeneKeepR`, delete monolith + orphans, update docs · risk HIGH (irreversible) 🐉
- **Goal:** retire the monolith. Make `runGeneKeepR()` a `lifecycle::deprecate_soft` alias to the modular app. **Note the current `runGeneKeepR()` is zero-arg** (port hardcoded 6012, `R/runGenekeepr.R:21,28`); the alias **adds** optional `port`/`launch.browser` args (defaulting to the modular app's) — backward-compatible since existing zero-arg callers (vignette, README) keep working. `lifecycle` is already a dep. Delete `inst/application/` (server.r, ui.r, global.R, 8 `uitp*.R`, `example_1.R`, dead `modPyramid.R`, `www/`). Remove confirmed orphans (§10, §16). Update docs/vignettes/CI/pkgdown. Close #27, #39.
- **PRE-FLIGHT (do not delete until all true):** Phases 1–8 complete (parity reached, E2E smoke green); `getLogo()`/`www` dependency confirmed monolith-only (verified §10 — safe to delete together); the grep inventory (§10) re-run to catch any reference added since.
- **RED:** assert `runGeneKeepR()` emits a deprecation condition and returns/launches the modular app (not the monolith); assert no `system.file("application")` reference remains.
- **DONE:** `runGeneKeepR()` soft-deprecates + launches modular; `inst/application/` gone; orphans removed; NAMESPACE/man regenerated (`devtools::document()`); README + `vignettes/manual_components/_running_shiny_application.Rmd` updated and **re-knitted** (not hand-edited); `_pkgdown.yml` reference index updated; **`devtools::check()` clean**.
- **Verify:** `devtools::check()` (no errors/warnings/notes) + full `NOT_CRAN=true` suite + manual smoke (`runGeneKeepR()` warns + opens modular UI) + `grep -rn "system.file(\"application\")\|runGeneKeepR" R/` shows only the alias.
- **🐉 DRAGONS:** irreversible deletion (the monolith is the only reference implementation — hence parity must be *done*); alias port (monolith hardcodes 6012, modular 6013 — **add** a `port` arg defaulting to the modular app's); re-knit vignettes (don't hand-edit `.md`/`.html`); commit the deletion as its own commit (easy revert).
- **Session boundary:** close out when `devtools::check()` is clean and the alias works.

---

## 10. Evidence-based inventory (MANDATORY — deletion/migration references)

Run `grep` re-confirmed at Phase 9 start; this is the Session-21 baseline (verified firsthand).

### Files to DELETE (Phase 9)
| Path | Action | Referenced by (must update/confirm) | Risk |
|---|---|---|---|
| `inst/application/server.r` (1304 L) | delete | `runGeneKeepR` via `system.file("application")` only | high (only ref impl) |
| `inst/application/ui.r` (53 L) | delete | sources the 8 `uitp*.R` | high |
| `inst/application/global.R` | delete | defines `globalMinParentAge`, `MAXGROUPS` (monolith-only) | retires XARCH-7 global |
| `inst/application/uitp*.R` (8 files) | delete | `ui.r` only | med |
| `inst/application/example_1.R` | delete | nothing `source()`s it; calls undefined `create_sample_pedigree` | low (dead) |
| `inst/application/modPyramid.R` (dead stub, APP-17) | delete | only the dead `example_1.R`; name-collides with live `R/modPyramid.R` | low |
| `inst/application/www/*` (logo, GeneDrop.png, app_style.js, under_construction.jpg) | delete | `getLogo()`→`uitpInput.R` only (monolith-only) | low (verified) |
| `R/getLogo.R` (+ `man/getLogo.Rd`, test, **`NAMESPACE:80` export**) | delete (becomes orphan) | **only** `inst/application/uitpInput.R` (verified) — modular app never calls it; remove the export via `document()` | low |
| `R/getMinParentAge.R` (+ `test_getMinParentAge.R`) | delete (true orphan, XARCH-3) | **zero** code callers (verified); it is **`@noRd` so there is NO man page and it is NOT in NAMESPACE** — no export to remove. Only `inst/WORDLIST:149` + `_pkgdown.yml` reference it (a broken pkgdown ref to an undocumented fn) | low |

### Symbols/docs to UPDATE (Phase 9)
| Reference | File | Change |
|---|---|---|
| `runGeneKeepR` definition | `R/runGenekeepr.R:18-29` | replace body with `deprecate_soft` + call modular |
| `\link{runGeneKeepR}` cross-ref | `R/runModularApp.R` docstring | keep (alias still exists) |
| vignette example | `vignettes/manual_components/_running_shiny_application.Rmd` | update to `runModularApp()`/note deprecation; **re-knit** |
| README example | `README.md` | update launcher reference |
| pkgdown index | `inst/_pkgdown.yml` | drop `getMinParentAge`/`getLogo` refs; keep `runGeneKeepR`/`runModularApp` |
| release notes | `NEWS.Rmd`/`NEWS.md` | add deprecation + parity bullets (CRAN-facing) |
| man pages | `man/runGeneKeepR.Rd`, `man/getMinParentAge.Rd`, `man/getLogo.Rd` | regenerate / remove via `document()` |
| roadmap/changelog/audit | `ROADMAP.md`, `CHANGELOG.md`, `TECH_DEBT_AUDIT_*.md` | mark XARCH-1 done (docs, not code) |
| project instructions | `CLAUDE.md:49` | the line describing `inst/application/` as "Original monolithic Shiny application" becomes inaccurate post-deletion — update to point at the modular app |
| spelling dict | `inst/WORDLIST:149` | remove the `getMinParentAge` entry when deleting it (or let `devtools::check()` spelling re-derive) |

> Note: `runGeneKeepR` appears in the **knitted vignette outputs** `vignettes/a3manual.{R,md,html}` (verified) **and** the source child `vignettes/manual_components/_running_shiny_application.Rmd`. `a3manual.Rmd` child-includes that component; **edit the `.Rmd` child, then re-knit `a3manual.Rmd`** — do NOT hand-edit the `.R`/`.md`/`.html` outputs (FM #22). `SESSION_NOTES.md`/cran-comments mentions are historical — leave as-is.

### To INVESTIGATE (not blind-delete)
- `R/shouldShowErrorTab.R` — exported but **bypassed** by `appServer` (uses `checkErrorLst`); referenced by `appServer.R` + `shouldShowChangedColsTab.R`. Decide in Phase 9 / §16: delete the half-wired path or refactor appServer to use it. **Do not leave the `appServer.R:172` `qcResults` struct built "for" a function that's never called.**
- `R/modMinimalTest.R` (+ `man/modMinimalTestUI.Rd`, `man/modMinimalTestServer.Rd`, 2 NAMESPACE exports) — click-counter scaffold, wired into no app, referenced nowhere. §16 decision: delete (drop both man pages + both exports via `document()`) vs keep as a documented module template.

---

## 11. The audit is stale — plan against the real files (verified)

Three audit premises that **overstate the work** (do not plan from them):
1. `ui.r` is **53 lines** (sources 8 `uitp*.R`), **not 1631**.
2. There are **no uppercase `server.R`/`ui.R` duplicates** — git tracks only lowercase `server.r`/`ui.r`; the "stale duplicate" is a **macOS case-insensitive-filesystem artifact** (one inode shown under two names). (Aside: on a case-sensitive Linux/CRAN checkout only the lowercase exists — confirm Shiny still resolves `server.r`/`ui.r`; this becomes moot once deleted.)
3. `server.r` has **no ORIP logic** and **no `write.csv`-to-tempdir anti-pattern** (all `write.csv` target download-handler file connections).

Also stale: **issue #34** ("Integrate `qcStudbook()` in modInput") — `modInput` already calls `qcStudbook` + `runQcStudbook` (verified `modInput.R:344-390`). #34 should be closed or relabeled (the real issue is the XARCH-6 triple-call redundancy, a future polish).

---

## 12. Impact analysis

| Surface | Impact | Action |
|---|---|---|
| `runGeneKeepR()` callers (users, vignette, README) | behavior change: launches modular + warns | alias keeps it working; document |
| Modular app users | gain genotype/focal/breeding-group/z-score features | parity phases |
| Compute core (`R/` non-app) | **unchanged** except orphan removals (`getMinParentAge`, `getLogo`) | no compute behavior change |
| `modORIPReporting`, Settings/About | **unchanged** (out of scope) | left as-is |
| Tests | +parity unit tests; E2E tier activated | per phase |
| CRAN | NAMESPACE shrinks (orphan exports removed); `inst/application` gone (smaller tarball) | `document()` + `check()` |

**Explicitly NOT changed:** the analytical pipeline (`qcStudbook`/`reportGV`/`kinship`/`groupAddAssign`), the species-profile question (XARCH-4), the lint debt (#30), the XARCH-2 typed contract (beyond parity touch-ups).

---

## 13. Verification plan (per phase + final)
- **Per phase:** the regression read in §9 (0 failed / 0 error among non-e2e files) + the named `test_file` for the touched module + new discriminating RED tests gone green.
- **Behavior-equivalence touch-ups** (e.g. Phase 5 kinship threading): prove `identical()` vs a captured pre-change reference, including a seeded stochastic caller where relevant (Learnings #15c/#16b/#17d).
- **Phase 8 (E2E):** `NPRC_RUN_E2E=true` reaches assertions; smoke tier green.
- **Phase 9 (final):** `devtools::check()` clean (no errors/warnings/notes); full `NOT_CRAN=true` suite; manual smoke of the deprecated `runGeneKeepR()`; grep confirms no dangling monolith reference.

---

## 14. Alternatives considered

| Alternative | Pros | Cons | Verdict |
|---|---|---|---|
| **Big-bang rewrite** of the modular app | clean slate | discards working modules + tests; huge risk; no incremental value | rejected (FM #25, astronaut) |
| **Keep both apps** (status quo) | no migration cost | the duplicate-maintenance tax XARCH-1 names; ongoing drift | rejected (the problem) |
| **Do XARCH-3/4/7 first** (audit's order) | "clean foundation" | verified moot/already-done; delays the actual deliverable | rejected (§8) |
| **Parity slices → validate → retire** (this plan) | each slice ships working value; bounded rework; deletion last | many sessions | **chosen** — matches strict-TDD/one-deliverable/vertical-slice constraints |
| **Defer E2E to #39** (a scope option) | smaller plan | retirement without an E2E safety net is riskier | not chosen (owner picked full incl. E2E) |

---

## 15. Rollback strategy
- Each phase is its own commit(s); revert = `git revert`/`checkout` of that phase.
- Phase 9's deletion is a **standalone commit** — if the modular app proves insufficient post-deletion, revert that single commit to restore `inst/application/` and the monolith body of `runGeneKeepR`.
- The alias keeps `runGeneKeepR()` callable throughout, so no user workflow breaks even mid-campaign.

---

## 16. Open decisions deferred INTO phases (not blockers for this plan)
1. **Gene-drop iterations default** (Phase 3): ✅ RESOLVED (Session 24) → **1000** (monolith parity; owner confirmed via `AskUserQuestion`).
2. **Focal-animal/LabKey** (Phase 7): mock vs live vs descope-the-radio-option — owner consult at phase start (likely a sub-plan).
3. **`shouldShowErrorTab`** (Phase 9): delete the bypassed path vs refactor appServer to use it.
4. **`modMinimalTest`** (Phase 9): delete vs keep as a documented module template.
5. **Stale "Version 1.0.8"** in `appUI.R` About stub: out of scope (§3) but a trivial opportunistic fix if Phase 2 touches `appUI`.
6. **FE/FG founder table placement** (Phase 1): the modular app shows FE/FG on the *GVA Summary* subtab; the monolith shows it on the *Summary Statistics* tab. Duplicate it onto the Summary tab (monolith parity) vs leave it on the GVA tab — owner confirm.
7. **Debug toggle** (cosmetic): wire `modInput`'s `debugMode` to `flog.threshold(DEBUG)` in `appServer` (monolith parity) vs leave inert — owner confirm; out-of-scope cosmetic per §3 unless opted in.
8. **Kinship-download fix approach** (Phase 1): thread `gvResults$kinshipMatrix` into `modSummaryStatsServer` (fixes the double-derivation too — prove `identical()`) vs have `downloadKinship` use the module's internally-derived kinship (smaller change).

---

## 17. Planning Session Checklist (`SESSION_RUNNER.md`)
- [x] Plan document written with file paths and line numbers
- [x] Grep-based inventory completed for all affected symbols/files (§10) — references run, not assumed
- [x] Each phase has explicit done-criteria + verification command (§9)
- [x] Each phase marked as a separate session with a STOP point (§9)
- [x] Here-be-dragons flagged (Phases 7, 8, 9; the inert-controls/guThresh/E2E-theatre traps)
- [x] Vertical slices, not horizontal layers (each phase ships a working feature)
- [ ] Close-out: evaluate predecessor, self-assess, commit, STOP (Session 21 close-out, in progress)

---

*End of plan. **Phases 1–3 complete (Sessions 22–24).** Next session implements **Phase 4** only (Input parity: genotype file merge — wire `getGenotypes`/`checkGenotypeFile`/`addGenotype` so `input$genotypeFile` is read and merged; see §9 Phase 4). Do not bundle phases.*
