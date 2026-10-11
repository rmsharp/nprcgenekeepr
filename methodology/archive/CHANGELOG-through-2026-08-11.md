# CHANGELOG.md — archive: 2026-08-10 → 2026-08-11

Retired records from [`CHANGELOG.md`](../../CHANGELOG.md), moved here so the live ledger stays small enough to read
in one pass. Same format, same newest-on-top order — this is the same ledger, continued.

Holds **11 record(s), 2026-08-10 → 2026-08-11**. Cut key: `2026-08-11`. Counts here are computed from the file
itself, never carried forward. This shard is frozen: it states no forward-looking rule,
because the live file owns those and a copy of one was wrong a day after it was written.

---

### 2026-08-11 · [issue #152] Pre-RED design/architecture document -- whole-genome/whole-exome sequence input + sequence-based genetic metrics (Session 517)
- **Deliverable:** `docs/planning/issue152-sequence-input-genetic-metrics-plan.md` -- ratified design/architecture document, following `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`, matching the #133/#136/#137/#145/#146/#147/#149/#150/#151 precedent. Design-only session, zero `R/`/`tests/`/`man/` changes. Picked from this session's own Phase 0 priorities list as the sole Deferred-tier READY item, per the ratified `docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` ordering (#152 > #153 > #148).
- **Research:** two parallel background agents (a codebase-inventory `Explore` agent; a domain-research `general-purpose` agent), plus direct verification of the single most load-bearing prior decision (`docs/planning/issue130-marker-kinship-crosscenter-identity-plan.md` D2, the ratified Bioconductor-Imports decline). Found `markerKinship()`'s O(n²·L) nested-pair loop and `markerParentageLikelihood()`'s O(F·C·L·n) redundant per-candidate allele-frequency rescan as the real, previously-unflagged scale bottlenecks (`PROJECT_LEARNINGS.md` Learning 519); a directly-applicable captive-pedigreed-macaque-colony precedent (Bimber et al. 2016, ~22,455-marker GBS panel + pedigree-aware imputation) grounding a realistic scope-tier ceiling; raw VCF ingestion infeasible on pure file-size grounds (144 GB-900 TiB class); summary statistics from genotype data are not an automatic privacy safe-harbor (Homer et al. 2008), so any sequence-derived export must route through the same curator-controlled gate issue #150 already shipped.
- **Design decisions:** 10 decisions (D1-D10), 5 forced by evidence, 5 judgment calls (D1/D3/D6/D7/D8), 4 of which (D1/D3/D6/D8) were put to a single `AskUserQuestion` ratification round -- owner selected the document's own recommended option in all four: sparse/GBS-scale ingestion tier (~50,000-locus ceiling, no Bioconductor dependency reopened); a new `locusMetadata` (`locus, chrom, pos[, cM]`) sidecar built now as shared vocabulary for sibling issue #153; genome-wide F_ROH (new, Ceballos et al. 2018) plus genome-scale reruns of the existing kinship/heterozygosity/Fst functions, ceding effective-population-size-from-LD to #153; a new tab inside the existing `modMarkerGenetics.R`, not a dedicated new module.
- **Implementation plan:** 5 future vertical slices (ingestion + fixture; a required `markerKinship()`/`markerParentageLikelihood()` performance rewrite; the new F_ROH metric; a new de-identification primitive; the full module tab + documentation), each its own future session.
- **Verified:** all 16 cited file paths (7 `docs/`, 9 `R/`) confirmed to exist via direct checks before close-out.
- **Issue #152 stays open** (design ratified, not implemented) -- no `gh issue close` this session, matching every precedent design session in this cluster.
- Model: Claude Sonnet 5.

### 2026-08-10 · [issue #150] Slice 2 -- De-Identified Export UI module, docs, closes #150 (Session 516)
- **Deliverable:** new **De-Identified Export** Shiny module (`R/modDeidentifiedExport.R`), per `docs/planning/issue150-deidentified-pedigree-export-plan.md` §5 Slice 2 -- `modDeidentifiedExportUI`/`modDeidentifiedExportServer` (D1: reads `shared$currentPedigree`, no fresh upload). Configure & Preview tab (alias-id length / max date shift / `linkedDateShift` controls, live de-identified preview, static D6 institutional-responsibility warning text) plus an Export tab gated by a `shiny::modalDialog()` confirm (mirroring `modCrossCenterIdentityServer`'s own Confirm->Export shape) with 3 downloadable artifacts: the de-identified pedigree, the D4 transformation manifest, and a distinctly labeled "DO NOT SHARE" re-identification key (D5). Fields outside id/dam/sire/dates/name pass through unchanged, disclosed per D8 rather than silently scrubbed. Two forced correctness requirements found during Pre-RED (not owner judgment calls, same category as the plan's own D1/D2/D4/D5/D7/D9): (1) the manifest snapshots the exact params used to produce the current preview at Generate-Preview time rather than re-reading live input state, so a curator who tweaks the configuration after previewing but before exporting cannot get a manifest describing different parameters than what was actually exported; (2) regenerating the preview resets the `confirmed` reactive to `FALSE`, mirroring `modCrossCenterIdentityServer`'s own D5 stale-confirmation-reset pattern. Downloads are not hard-gated on `confirmed` (mirrors the Cross-Center Identity precedent exactly -- this issue's own ratified framing is "a confirmation dialog and warning text, not real access control"). Wired into `R/appUI.R` (new "De-Identified Export" tab immediately after "Cross-Center Identity", D10) and `R/appServer.R`. Full strict TDD PRE-RED->RED->GREEN->REFACTOR cycle, each transition `AskUserQuestion`-gated; REFACTOR: no candidate identified, implementation already mirrors established module conventions directly.
- **Tests:** 16 new `test_that` blocks (14 in `tests/testthat/test_modDeidentifiedExport.R` -- UI shape, no-pedigree req() gate, module-level non-negative-age proof reusing the `pedGood`/`exit=birth+10`/`set_seed(3L)` fixture from `test_obfuscatePed.R`, manifest-params-snapshot regression, confirm-gate start/flip/reset, all 3 download-content round-trips; 1 in `tests/testthat/test_moduleContract.R` registering the module against the return-shape guard), 0 regressions.
- **Verified:** full clean regression 0 failed/0 error (5233 passed, was 5186 baseline, 15 pre-existing warnings unchanged); `devtools::check()` 0 errors/0 warnings/1 pre-existing NOTE (confirmed byte-identical to unmodified `HEAD` via `git stash -u` before/after, including the raw-log spelling-diff NOTE, a pre-existing environment quirk unrelated to this diff); `lintr::lint_package()` 0 lints on all 5 touched files (fixed 3 style lints: one 80-char line, two `brace_linter` multi-line function-body wraps); `devtools::document()` clean (2 new `.Rd` pages, `NAMESPACE` +2 exports, only expected `@family` cross-reference churn across sibling modules). `_pkgdown.yml` reference-coverage gap caught live by `test_pkgdown_reference_config.R` (matching this project's own checklist for new exported functions) -- fixed, alphabetically inserted.
- **Phase 3E live smoke test (mandatory this slice):** an ad hoc script (not committed, matching the #149 Cross-Center Identity precedent of no permanent E2E file) drove the real running app via this project's own `tests/testthat/helper-shinytest2.R` conventions -- loaded the bundled example pedigree through Input, navigated to De-Identified Export, confirmed the config inputs and D6 warning text render, generated a preview (de-identified rows confirmed, no original ids leaked), confirmed the modal shows the warning text, clicked through to a scoped confirmation the module's own Export sub-tab is active (a first, unscoped `a[data-value='Export']` selector attempt warned of multiple matches -- `modCrossCenterIdentity` also has a tab literally named "Export" -- caught and fixed with a module-scoped selector before trusting the result), and confirmed all 3 download buttons render with the map correctly labeled "DO NOT SHARE". 0 console errors (SEVERE/throw/error) across the entire sequence.
- **Docs:** `NEWS.Rmd`/`NEWS.md` entry (re-rendered via `rmarkdown::render("NEWS.Rmd")` honoring its own YAML `output: github_document` -- an earlier attempt that overrode `output_format = "md_document"` silently dropped the file's title header and reflowed every line, caught by inspecting the diff before trusting it, not assumed insertion-only); new "De-Identified Export" subsection in `vignettes/articles/colony-manager-guide.qmd` (text-only, matching the Cross-Center Identity precedent's own no-screenshot convention for this governance/export-tool category), re-rendered clean via `quarto render`. `a2interactive.Rmd` coverage deferred per its own standing rule (Shiny-UI-only feature). Citation checklist N/A (no new displayed statistic).
- **Both slices of issue #150 are now shipped; issue #150 closed** as part of this session's close-out (https://github.com/rmsharp/nprcgenekeepr/issues/150#issuecomment-5249162437).
- Model: Claude Sonnet 5.

### 2026-08-10 · [issue #150] Slice 1 -- `obfuscatePed()` `linkedDateShift` fix + `.buildDeidentificationManifest()` helper (Session 515)
- **Deliverable:** `obfuscatePed()` gained a `linkedDateShift` parameter (default `TRUE`), per `docs/planning/issue150-deidentified-pedigree-export-plan.md` §5 Slice 1 -- draws one `runif()` offset per individual and applies it via `ddays()` to every Date column for that row, closing the Session 514 negative-age defect (`PROJECT_LEARNINGS.md` Learning 515) by construction: inter-column date gaps are preserved exactly, proven by an invariance RED test (`exit - birth` unchanged), not just a bounds check. `linkedDateShift = FALSE` keeps the exact old per-column-independent behavior for any caller that needs it. New `R/modDeidentifiedExport.R` (internal, `@noRd`): `.buildDeidentificationManifest(pedRows, size, maxDelta, linkedDateShift, warningText)`, mirroring `.buildCrossCenterMergeProvenance()`'s existing shape (`R/modCrossCenterIdentity.R`). Full strict TDD PRE-RED->RED->GREEN->REFACTOR cycle, each transition `AskUserQuestion`-gated; REFACTOR: owner-confirmed no candidate identified.
- **Found and fixed a genuine order-dependence bug in this session's own new tests** (not the production code): a bare `set.seed()` in a new RNG-seeded test silently inherits whatever `RNGkind()` an earlier-run test file left behind, because this package's own `set_seed()` helper (`R/set_seed.R`, used throughout the suite for cross-R-version RNG parity) permanently mutates `RNGkind(sample.kind = "Rounding")` for the rest of the `testthat` session -- diagnosed by direct experiment (not assumed), fixed by switching to `set_seed()` and re-deriving a seed that reproduces the defect deterministically under that `RNGkind`, verified order-independent via a deliberate RNG-perturbation-then-rerun check. See `PROJECT_LEARNINGS.md` Learning 516.
- **Verified:** full clean regression 0 failed/0 error (5186 passed, 15 pre-existing warnings unchanged, up from a 5172-passed baseline); `devtools::check()` 0 errors/0 warnings/1 pre-existing NOTE (the `a2interactive.Rmd` vignette-engine NOTE, confirmed unrelated via a `git stash -u` before/after baseline comparison -- a bare `git stash` gives a false result since it does not stash untracked new files); `lintr::lint_package()` 0 lints on touched files. `NEWS.Rmd`/`NEWS.md` entry done (diff-clean, insertion-only). No `_pkgdown.yml` change needed (`.buildDeidentificationManifest` is internal; `obfuscatePed` already listed).
- Phase 3E runtime smoke test: n/a, stated explicitly -- Slice 1 is script-callable-function-level only, no Shiny UI/runtime wiring changed (the module ships in Slice 2, where a live smoke test is mandatory).
- **`BACKLOG.md` housekeeping:** found Session 514's own design-only close-out did not append a "Progress" note to `BACKLOG.md`'s issue #150 narrative, unlike every other design-session precedent in this cluster (S495/S503/S511) -- reconstructed it retroactively (clearly labeled as a reconstruction, not passed off as original), then added this session's own Slice 1 progress note alongside it.
- Issue #150 stays open -- Slice 2 (full UI module, confirm gate, exports, documentation) is a separate future session.
- Model: Claude Sonnet 5.

### 2026-08-10 · [issue #150] Pre-RED design/architecture document -- de-identified pedigree export workflow (Session 514)
- **Deliverable:** `docs/planning/issue150-deidentified-pedigree-export-plan.md`, ratified via `AskUserQuestion`. Design-only session, matching the #133/#136/#137/#145/#146/#147/#149/#151 precedent -- zero `R/`/`tests/`/`man/` changes. Issue #150 stays intentionally open (design ratified, not yet implemented).
- **Policy gate resolved first:** `docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` Finding #3 placed issue #150 outside its own priority table, framing it as an owner decision ("do we want to formalize a curator-controlled de-identified sharing export, understanding that 'curator-controlled' means a confirmation dialog and warning text, not real access control?") rather than an engineering one. This session put exactly that question to the owner via `AskUserQuestion` before any technical research; owner answered yes.
- **Design summary:** a new `modDeidentifiedExport` Shiny module reuses the existing, already-shipped `obfuscateId()`/`obfuscateDate()`/`obfuscatePed()`/`mapIdsToObfuscated()` against `shared$currentPedigree` (D1 -- the currently loaded pedigree, not a fresh upload, unlike issue #149's own shape). Configure & Preview tab -> `modalDialog()` confirm gate (mirroring `R/modCrossCenterIdentity.R`'s existing precedent) -> Export tab with 3 downloadable artifacts (de-identified pedigree, a separately-labeled re-identification map, and a non-sensitive transformation manifest).
- **Defect found and empirically verified (not assumed):** `obfuscatePed()` shifts each Date column (`birth`/`exit`/`death`) independently, which can invert an individual's birth/exit order and produce a negative recomputed `age` -- confirmed via a seeded `Rscript` against the bundled `pedGood` fixture (25% hit rate on a realistic 10-day birth-exit gap, default `maxDelta = 30L`). No prior caller of `obfuscatePed()` needed the output to survive external, scientifically-scrutinized sharing, so this shipped undetected. The ratified fix (D3) adds a `linkedDateShift` parameter (default `TRUE`) drawing one shared per-individual date offset, preserving inter-column gaps and `age` exactly. No existing test pinned the old independent-shift behavior (confirmed by reading `tests/testthat/test_obfuscatePed.R` in full), so this ships as a safe, `NEWS.Rmd`-documented additive default-behavior change. See `PROJECT_LEARNINGS.md` Learning 515.
- **4 judgment calls ratified via one `AskUserQuestion` round** (owner selected this document's own recommended option in all four): D3 (fix the date defect now, in Slice 1); D6 (an explicit institutional-responsibility warning -- this app's first such disclaimer -- shown in the modal confirm gate and on the Configure tab); D8 (disclose, don't scrub, non-id/date fields like `origin`/`population`/`status`/`condition`); D10 (mount the new tab immediately after Cross-Center Identity).
- **Implementation plan:** 2 vertical slices, each a separate future session -- Slice 1 (the `obfuscatePed()` date fix + a new internal manifest-builder helper, R-only, script-callable) and Slice 2 (full UI module, confirm gate, exports, documentation).
- Posted a ratified-design summary comment on GitHub issue #150 (https://github.com/rmsharp/nprcgenekeepr/issues/150#issuecomment-5248437483), matching the #149/#151 precedent.
- **Housekeeping:** a stray `__pycache__/` byproduct from this session's own `methodology_dashboard.py`/`methodology_trim.py` runs (never previously gitignored) added to `.gitignore` and removed.
- Model: Claude Sonnet 5.

### 2026-08-10 · [issue #151] Slice 2 -- Mate Pair Analysis tab, D6 marker-kinship wiring, docs -- closes #151 (Session 513)
- **Deliverable:** `R/modMatePair.R` (new, exported `modMatePairUI`/`modMatePairServer`), per `docs/planning/issue151-individual-mate-pair-analysis-plan.md` §5 Slice 2 -- the final planned slice. A curator-facing UI over Slice 1's `reportMatePairs()`: a required population-scope radio (D4 -- "All alive" via `is.na(ped$exit)`, "Top ranked by genetic value," or a pasted "Custom list"), a minimum-age numeric input (D2), a toggleable exclude-list textarea (D5), server-side-filtered `DT` Eligible Pairs and Excluded tables (this package's first `DT::renderDT(server = TRUE)` usage), and a CSV export of exactly the currently-filtered rows via `pairsTable_rows_all` (Dragon 4). `R/appServer.R` now captures `markerResults <- modMarkerGeneticsServer(...)` (D6) -- its `markerKinshipMatrix` reactive was computed but never read by any caller until now -- and mounts the new module; `R/appUI.R` gained a "Mate Pair Analysis" tab directly after Breeding Groups (§2.8).
- **Bug found and fixed (Slice 1 regression):** `R/reportMatePairs.R`'s 5 scalar column assignments (`kin$col <- NA_real_`) threw `"replacement has 1 row, data has 0"` whenever the age filter alone reduced the candidate table to exactly 0 rows -- a case Slice 1's own test suite never exercised. Found via Slice 2's own new module-level test coverage, surfaced to the owner (outside GREEN's approved file scope) before fixing; fixed to `rep(NA_real_, nrow(kin))` x5, with its own dedicated regression test in `tests/testthat/test_reportMatePairs.R`. See `PROJECT_LEARNINGS.md` Learning 513.
- **TDD cycle:** full strict PRE-RED->RED->GREEN->REFACTOR, each transition `AskUserQuestion`-gated. RED: `tests/testthat/test_modMatePair.R` (15 `test_that` blocks) plus the `modMatePair` entry in `tests/testthat/test_moduleContract.R`; both failed genuinely ("could not find function/module"). GREEN found the `geneticValues` shape mismatch (`shared$geneticValues` is the flat `reportGV()$report` data.frame, not `reportMatePairs()`'s expected `list(report = ...)`) by reading `R/modGeneticValue.R`'s actual reactive body, with a RED test fixture specifically designed to catch a silent-`NA` regression if the wrap were ever dropped. REFACTOR: one real, narrow simplification (`geneticValues()` read once per observer invocation instead of twice).
- **Verification:** full clean regression 0 failed/0 error, 5172 passed, 15 pre-existing baseline warnings unchanged; `devtools::check()` 0 errors/0 warnings/1 pre-existing note (a separate, pre-existing `spelling.Rout`/`.Rout.save` mismatch confirmed unrelated to this session via a `git stash` baseline check; only this session's own new "textarea" `inst/WORDLIST` gap was fixed, matching the S502 precedent); `lintr::lint_package()` 0 lints on touched files. A full, untargeted regression read (as opposed to the targeted file run) additionally caught and fixed 2 guard-test regressions: `test_pkgdown_reference_config.R` (`_pkgdown.yml` missing the 2 new exported functions) and `test_shinytest2_workflow_coverage.R` (the new opt-in E2E test file not yet matched by any `.github/workflows/shinytest2.yaml` group regex).
- **Live Phase 3E smoke test:** `tests/testthat/test-e2e-mate-pair-analysis-module.R` (new, opt-in via `NPRC_RUN_E2E=true`) drives the real running app end to end -- uploads the example pedigree, uploads a small genotype file for 2 real breeding-age ids on Marker Genetics (confirming Marker Genetics itself still renders after the D6 wiring change), configures and runs Mate Pair Analysis against a real 6-id population with one exclusion, and asserts the genotyped pair's marker kinship populates, the excluded id is routed to the Excluded tab with `"user-excluded"`, and zero related console errors. Ran live: 8/8 assertions passed. `vignettes/articles/colony-manager-guide-screenshots.R` gained a matching capture block (the first in that script to upload a genotype file) and all 81 article screenshots were regenerated, including 2 new ones for the Mate Pair Analysis tab -- visually confirmed the D6 wiring live (a real, non-`NA` `markerKinship` value in the captured table).
- **Documentation:** `NEWS.Rmd`/`NEWS.md` entry; a new "### Mate Pair Analysis" section in `vignettes/articles/colony-manager-guide.qmd`; `_pkgdown.yml` reference coverage; `a2interactive.Rmd` deferred per its own standing rule (Shiny-UI-only feature). `PROJECT_LEARNINGS.md` gained Learnings 513 (the `reportMatePairs()` 0-row bug) and 514 (an inaccurate citation found in S512's own `HANDOFFS.md` receipt during Phase 3A evaluation).
- **Scope:** issue #151 is now fully shipped. **Closed this session.**
- **Model:** Claude Sonnet 5.

### 2026-08-10 · [issue #151] Slice 1 -- core `reportMatePairs()` function (individual mate-pair candidate report) (Session 512)
- **Deliverable:** `R/reportMatePairs.R` (new, exported), per `docs/planning/issue151-individual-mate-pair-analysis-plan.md` §5 Slice 1. Composes the existing, unmodified pair-eligibility pipeline (`kinMatrix2LongForm()`/`filterPairs()`/`filterAge()`/`filterKinMatrix()`) into opposite-sex, minimum-age-eligible mate-pair candidates, each row carrying pedigree kinship plus `NA`-safe marker-kinship (`markerKinship()`) and per-parent genetic-value context (`reportGV()`'s `indivMeanKin`/`gu`); no invented composite ranking score. A closed-vocabulary `excluded` frame reports why a pair was dropped ("under minimum age" or "user-excluded"). Script-callable only -- no Shiny UI (Slice 2).
- **TDD cycle:** full strict PRE-RED->RED->GREEN->REFACTOR, each transition `AskUserQuestion`-gated. RED: 8 `test_that` blocks / 37 expectations in `tests/testthat/test_reportMatePairs.R`, including a regression test directly reproducing the ratified plan's own Dragon #1 (`filterAge()`'s NA-passes semantics means `minAge` alone cannot bound table size; the `populationIds` D4 scope control is what actually does) against an 11-individual hand-built fixture. Confirmed RED failures were genuine ("could not find function"), not setup errors -- including tightening a bare `expect_error()` with a regexp pattern after noticing it would otherwise spuriously pass. GREEN found and fixed one genuine test-design bug during verification (an `all()` assertion wrongly conflated "excluded because of C's own user-exclusion" with "any excluded row mentioning C," when a pair can independently fail the age screen for an unrelated reason; fixed to `any()`, matching per-pair reason semantics). REFACTOR removed 2 redundant `nrow(kin) > 0L` guards (R's vectorized indexing is already 0-row-safe).
- **Verification:** full clean regression 0 failed/0 error, 5118 passed (+37 vs. baseline), 15 pre-existing baseline warnings confirmed unchanged via `git stash -u` before/after comparison; `devtools::check()` 0 errors/0 warnings/1 pre-existing note (fixed one genuine new WARNING along the way -- an Rd `\link{filterAge}` cross-reference to a `@noRd` function with no `.Rd` page); `lintr::lint_package()` 0 lints on touched files (fixed 2 line-length lints). `_pkgdown.yml` reference-coverage checklist and `NEWS.Rmd`/`NEWS.md` (new exported function) checklist both satisfied same-session.
- **Scope:** issue #151 intentionally stays open -- Slice 2 (UI, `appServer.R` D6 marker-kinship wiring, `appUI.R` tab mount, tutorial/article documentation, live `shinytest2` smoke test, `gh issue close 151`) is the final planned slice, a separate future session.
- **Model:** Claude Sonnet 5.

### 2026-08-10 · [issue #151] Pre-RED design/architecture document -- individual mate-pair analysis (Session 511)
- **Deliverable:** `docs/planning/issue151-individual-mate-pair-analysis-plan.md`, RATIFIED. Tier 2 step 3 of `GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` -- #146/#147/#149 (the rest of Tier 1/2) are all now shipped and closed.
- **Key findings (original research this session):** the reusable pair-eligibility pipeline (`kinMatrix2LongForm()`/`filterPairs()`/`filterAge()`/`filterThreshold()`) already exists entirely outside `R/modBreedingGroups.R`, correcting the sequencing audit's own "shared-file risk" flag; `modMarkerGeneticsServer()` already computes and returns a `markerKinshipMatrix` reactive that `R/appServer.R` currently discards -- wiring it into this feature is a one-line capture, not new computation; an original benchmark against the bundled `examplePedigree` found an unscoped pair-reshape produces 1,744,722 rows in 54.0s, and that `filterAge()`'s NA-passes-the-filter semantics (81% of "alive" fixture individuals have no recorded age) means the age control alone cannot bound table size; no continuous composite-score ranking precedent exists anywhere in the package (`reportGV()`'s own `orderReport()` is a rule-based tier classification, not a weighted formula).
- **Decisions:** D1 module boundary (own standalone `modMatePairUI`/`modMatePairServer`, not folded into `modBreedingGroups.R`), D2 eligibility screen (`filterPairs`/`filterAge`, `sexCodes`-based, XARCH-4-compliant), D6 marker-kinship wiring, D7 return-shape/column vocabulary, D8 export format all forced by evidence/precedent. Three genuine judgment calls (D3 ranking, D4 population-scope control, D5 exclusion transparency) ratified via a single `AskUserQuestion` round -- owner selected this document's own recommended option in all three cases, no changes requested.
- **Verification:** Architecture Workstream's own checklist self-applied (interface catalog, dependency/impact analysis, failure-mode dragons, honest alternatives, explicit scope boundary). No code, test, or `man/` content changed -- design/planning only, matching the #133/#136/#137/#145/#147/#149/#146 precedent. Implementation is 2 vertical slices (core `reportMatePairs()` function; UI + `appServer.R` wiring + documentation), each its own future session. Issue #151 intentionally left open.
- **Model:** Claude Sonnet 5.

### 2026-08-10 · [issue #146] Slice 2 -- exhaustive enumeration mode + UI toggle for breeding-group candidate retention, closes #146 (Session 510)
- **Deliverable:** `groupAddAssign()` gained `exhaustive`/`maxExhaustiveCandidates`/
  `exhaustiveTimeLimit` arguments (default `FALSE`/20L/10s) per the ratified
  `docs/planning/issue146-configurable-exhaustive-breeding-group-retention-plan.md` §5
  Slice 2. New `.enumerateMaximalIndependentSets()` helper (`R/enumerateMaximalIndependentSets.R`,
  `@noRd`) implements a hand-rolled Bron-Kerbosch-style maximal-independent-set search
  directly on the existing `kin` conflict-adjacency list (D4, no new `igraph` dependency,
  no complement graph materialized), citing Bron & Kerbosch (1973) / Tomita, Tanaka &
  Takahashi (2006). Scoped to `numGp = 1`/no harem/no custom `sexRatio` (D2); an
  out-of-scope or over-ceiling request `stop()`s with a message naming the specific reason
  (D9) rather than silently falling back to sampling; a wall-clock deadline elapsed
  mid-search degrades gracefully to a truncated, non-exhaustive result (D5) instead of
  erroring. `groupMembersReturn()` gained `exhaustive`/`examined`/`retentionRule` optional
  parameters, adding those 3 top-level fields only when supplied -- ordinary sampling
  calls are byte-identical to before (D7). The Breeding Group Formation tab
  (`R/modBreedingGroups.R`) gained a matching **Exhaustive enumeration mode** checkbox
  (visible only when the current configuration is D2-eligible) and a status callout
  reporting the search outcome after each run (D8, shipped same-session as the algorithm,
  per the ratified §11 Q4 decision).
- **Process:** followed `DEVELOPMENT_WORKSTREAM.md` under this project's Strict TDD
  contract (PRE-RED→RED→GREEN, `AskUserQuestion`-gated at every transition; REFACTOR
  owner-confirmed skip -- implementation already matches the ratified design). RED caught
  and fixed a genuine false-green risk before GREEN began: the D5 ceiling test's regexp
  (`"maxExhaustiveCandidates|20"`) accidentally matched R's own auto-generated "unused
  arguments" error, so it would have passed before any implementation existed; tightened to
  a phrase (`"exceeds"`) only the real implementation could produce. GREEN caught and fixed
  a real test-fixture defect (not a package defect): a synthetic `ped` fixture lacking an
  `age` column silently made `filterAge()` drop every kinship pair, due to a base R
  indexing quirk (`df[i, "missingCol"]` returns `NULL` for a row-index vector `i`, unlike
  `df[, "missingCol"]`, which errors) -- fixed by adding `age` to the fixture, not by
  touching `filterAge()` itself.
- **Verification:** 11 new/extended test blocks across 4 files (`test_enumerateMaximalIndependentSets.R`
  new; `test_groupAddAssign.R`, `test_modBreedingGroups.R`, `test_modBreedingGroups_groupAddAssign.R`
  extended) -- a hand-verified 5-cycle conflict-graph fixture (exact 5-maximal-independent-set
  membership match), a deadline-truncation case, a brute-force-cross-checked sparse-vs-dense
  density-robustness case (the plan's own §2.10 counter-intuitive finding: sparser graphs have
  MORE maximal independent sets, asserted structurally), 3 D2 scope-refusal `stop()` cases, 1 D5
  ceiling-refusal `stop()` case, 1 deadline-truncation integration case, a UI-presence test, and 2
  `testServer` mocked-binding tests (default-FALSE and explicit-TRUE threading). Full clean
  regression suite 0 failed/0 error (5081 passed, up from 5050; 175 skipped; 15 pre-existing
  baseline warnings unchanged); `lintr::lint_package()` 0 lints (4 found and fixed on touched
  files: 3 line-length, 1 `implicit_integer_linter`); `devtools::check()` 0 errors/0 warnings/2
  notes, both pre-existing and unrelated to this session's diff (vignette-engine NOTE, and a
  top-level-files NOTE for `FRAMEWORK_LEARNINGS.md`/`methodology_trim.py` dating to an earlier
  methodology-sync commit). **Live `shinytest2`/`chromote` smoke test** against the real running
  app: toggle renders and is readable/settable when D2-eligible; a genuine exhaustive run (real
  candidate pool, real browser click) produced the correct live status text ("Exhaustive: examined
  1 partition(s). top-5 by score (min group size), N = 1", green/completed styling); toggle
  confirmed `HIDDEN` (not just visually styled) via computed-style JS check when `numGp = 2`
  (D2-ineligible); 0 `SEVERE` console entries throughout. The live truncated-search case was not
  reproduced (the deadline isn't user-configurable in the UI; already covered by unit tests) --
  an explicit judgment call the ratified plan itself grants ("implementing session's own
  judgment, not gated here").
- **Documentation:** `NEWS.Rmd`/`NEWS.md` (re-rendered via the frontmatter's own `github_document`
  format -- a first attempt with an explicit `output_format` override produced a 943/878-line
  reflow diff from format mismatch, caught before committing and redone correctly);
  `vignettes/manual_components/_breeding_group_formation.Rmd` gained new **Candidates to
  retain**/**Exhaustive enumeration mode** coverage (text-only, satisfying the tutorial/article
  checklist's established "and/or" allowance -- no screenshot re-capture in
  `colony-manager-guide.qmd`, matching the `_pedigree_browser.Rmd` precedent). Citation checklist
  (#120) N/A (stated explicitly, not silently omitted): `.enumerateMaximalIndependentSets()`'s
  `@references` is a documentation-quality matter, not the issue-120 UI-guidance-page trigger,
  since the function is `@noRd`/never user-facing. `_pkgdown.yml` N/A (`groupAddAssign` already
  listed; the new helper is `@noRd`). `a2interactive.Rmd` coverage deferred per its own standing
  rule (new parameters on an already-documented, script-callable function).
- **Files:** new `R/enumerateMaximalIndependentSets.R`, `tests/testthat/test_enumerateMaximalIndependentSets.R`;
  edited `R/groupAddAssign.R`, `R/groupMembersReturn.R`, `R/modBreedingGroups.R`,
  `tests/testthat/test_groupAddAssign.R`, `tests/testthat/test_modBreedingGroups.R`,
  `tests/testthat/test_modBreedingGroups_groupAddAssign.R`, `man/groupAddAssign.Rd` (regenerated),
  `NEWS.Rmd`/`NEWS.md`, `vignettes/manual_components/_breeding_group_formation.Rmd`. **Issue #146
  is now fully implemented across both slices; closed as part of this session's close-out.**

### 2026-08-10 · [ad hoc] Trim CHANGELOG.md/HANDOFFS.md via methodology_trim.py -- HANDOFFS.md fully resolved (Session 509)
- **Deliverable:** losslessly trimmed `CHANGELOG.md` and `HANDOFFS.md` (both files' first-ever
  archive), addressing the dashboard's HIGH risk flag (both past the 2,000-line agent-`Read`
  truncation cap) and MEDIUM byte-budget flags. `HANDOFFS.md`: 832,849 B/4,877 lines →
  28,806 B/409 lines, 181 of 187 records archived to
  [`docs/archive/HANDOFFS-through-2026-08-10.md`](../../docs/archive/HANDOFFS-through-2026-08-10.md) --
  trigger now **does not fire**, fully resolved. `CHANGELOG.md`: 1,534,418 B/10,523 lines →
  945,639 B/3,723 lines, 288 of 289 records archived (entry immediately below) -- trigger **still
  fires** post-trim, expected and not a defect: the frozen `## Legacy history (pre-ledger format,
  Sessions 1-324)` footer (935,287 B/3,568 lines, the Session 325 "freeze legacy, go forward"
  decision) is pinned to the live file by design and this tool has no grammar to parse or migrate
  it; only a separate, deliberately-scoped future migration campaign could shrink it further, and
  none is planned. Picked via `AskUserQuestion` "Other" over this session's own 4 rendered BACKLOG
  priority options (issue #146 Slice 2, issue #150, LabKey, NPRC outreach).
- **Verification:** both trims' write-time `L1_OK`/`L2_OK`/`L3_OK` assertions passed. The
  independently-regenerated `verify.sh` for `HANDOFFS.md` also passed clean (exit 0). For
  `CHANGELOG.md`, `verify.sh`'s `L1`/`L3` (the byte-exact checks) passed; its separate `L2`
  "front matter leaked into shard" heuristic reported a false positive, investigated and confirmed
  harmless via direct `grep` (2 archived records quote the front-matter heading `## Size, and when
  to archive` verbatim in backticks while narrating an unrelated, already-committed prior action;
  the real heading is unchanged, exactly once, in the live front matter) -- see
  `PROJECT_LEARNINGS.md` Learning 507 for the full proof and a general rule for future trims.
- **Incidental fix:** `.gitignore`'s blanket `docs/*` rule had no `!docs/archive/` exception, so
  this tool's own required output directory was silently untrackable on this project's first-ever
  run -- added, matching the 7 other `docs/` subdirectory exceptions already present.
- Commits: `7a423398` (claim), `9113dd48` (CHANGELOG.md entry for the claim commit, satisfying the
  trim tool's own P1 pre-check), `d07814a7` (HANDOFFS.md trim + gitignore fix), `0929172a`
  (CHANGELOG.md trim), plus this close-out commit (`SESSION_NOTES.md`/`HANDOFFS.md`/
  `PROJECT_LEARNINGS.md`). See `SESSION_NOTES.md` "What Session 509 Did" and `HANDOFFS.md`'s S509
  receipt for full narrative detail.

**Archived 288 record(s), 2026-07-08 → 2026-08-10** into [`docs/archive/CHANGELOG-through-2026-08-10.md`](../../docs/archive/CHANGELOG-through-2026-08-10.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-08-10.md.verify.sh`](../../docs/archive/CHANGELOG-through-2026-08-10.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

### 2026-08-10 · [ad hoc] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-08-10.md` (288 record(s), 1,534,418 B → 945,639 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **288** record(s) (2026-07-08 → 2026-08-10) out of [`CHANGELOG.md`](../../CHANGELOG.md) into
[`docs/archive/CHANGELOG-through-2026-08-10.md`](../../docs/archive/CHANGELOG-through-2026-08-10.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/CHANGELOG-through-2026-08-10.md.verify.sh`](../../docs/archive/CHANGELOG-through-2026-08-10.md.verify.sh)
rather than trusting a digest printed here. Live file 1,534,418 B → 945,639 B (−38.4%).

### 2026-08-10 · [ad hoc] Ledger trim: `HANDOFFS.md` → `docs/archive/HANDOFFS-through-2026-08-10.md` (181 record(s), 832,849 B → 28,806 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **181** record(s) (2026-07-08 → 2026-08-10) out of [`HANDOFFS.md`](../../HANDOFFS.md) into
[`docs/archive/HANDOFFS-through-2026-08-10.md`](../../docs/archive/HANDOFFS-through-2026-08-10.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/HANDOFFS-through-2026-08-10.md.verify.sh`](../../docs/archive/HANDOFFS-through-2026-08-10.md.verify.sh)
rather than trusting a digest printed here. Live file 832,849 B → 28,806 B (−96.5%).

