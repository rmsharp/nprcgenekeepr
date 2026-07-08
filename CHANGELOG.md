# Changelog

Development / process history for the **nprcgenekeepr** project,
following the [methodology](https://github.com/rmsharp/methodology)
model: `BACKLOG.md` holds open work, **this file** holds completed
history, and `ROADMAP.md` holds the feature inventory and future plans.

> **Note:** User-facing R-package release notes (the CRAN / pkgdown
> “Changelog”) live in `NEWS.md` / `NEWS.Rmd`. This file tracks the
> development *process* and methodology history, not package releases.

Format loosely follows [Keep a Changelog](https://keepachangelog.com/).
When completing work, remove the item from `BACKLOG.md` and add an entry
here.

## \[Unreleased\]

### 2026-07-08 — issue \#103 — verify harmonization completeness; fix overlooked `set_seed.R` `@returns`-\>`@return` (Finding 1) (Session 318)

- **Deliverable (owner scope-gate via `AskUserQuestion` = “fix the
  one-liner, leave \#103 open for the internal-title sweep”):** the
  owner asked whether \#103 might be complete. Verified against the S244
  audit’s 8-stage roadmap
  (`docs/audits/ROXYGEN_HARMONIZATION_AUDIT_2026-06-29.md` §6) rather
  than trusting the changelog trail alone. **REFACTOR-class, doc-only;
  TDD RED/GREEN N/A** (no implementation code, no testable behavior
  change — matches the established \#103-stage precedent). 0 stakeholder
  corrections.
- **Confirmed complete via firsthand spot-checks (not just changelog
  claims):** all 6 `#103`-tagged PRs (#104, \#105, \#106, \#107, \#108,
  \#113) show `MERGED`, no open PRs remain; `R/getSimSires.R` confirmed
  deleted; the only remaining `@keywords internal` is the
  correctly-exempt `nprcgenekeepr-package.R`; two backtick hits in
  `geneDrop.R`/`getGVGenotype.R` are inside `@examples` R-comment text
  (never markdown-processed), not the Finding-4 prose-backtick defect
  class — false positive, no action needed.
- **Found genuinely incomplete: two items.** (1) **Finding 1’s
  `@returns`-\>`@return` one-liner was never applied** —
  `R/set_seed.R`’s internal `R_version()` helper (`@noRd`) still used
  `@returns`; `git log --follow` confirmed this tag predates the entire
  harmonization effort (commit `031ff714`) and was never touched by any
  \#103-stage commit. **Fixed this session** (1-line change, `@noRd` so
  zero rendered-doc impact, `man/` diff empty). (2) **Finding 3’s
  internal-title-voice tail** (Stage 8a scoped to *exported* titles
  only, per S257/258) was never resumed — **72 `@noRd` markers across 62
  files** remain un-normalized. Owner chose to leave **\#103 OPEN** for
  this (not exempt it like the Shiny `mod*` carve-out) — it needs its
  own dedicated session, comparable in size/judgment to Stage 8a’s
  original 100-file exported sweep.
- **Verify:** `devtools::document()` — NAMESPACE + `man/` diff both
  empty (the fixed tag is on an `@noRd` function);
  `lintr::lint("R/set_seed.R")` = 0;
  [`spelling::spell_check_package()`](https://docs.ropensci.org/spelling//reference/spell_check_package.html)
  clean; **`devtools::check(cran=TRUE)` — `Status: OK`, 0 errors / 0
  warnings / 0 notes**; fast regression read — 0 failed / 0 error / 0
  warning, 3092 passed.
- **\#103 remains OPEN** — the internal-title-voice sweep (Finding 3
  tail) is the one concretely-scoped remaining item; see
  `SESSION_NOTES.md` “Session 318” for the file/marker count and
  precedent-sizing note.

### 2026-07-08 — Close issue \#120 — delete orphan vignette duplicates (F12) + add citation-checklist process rule (Session 317)

- **Deliverable:** REFACTOR-class, doc/housekeeping-only close-out of
  the two items the S316 session explicitly scope-gated out of \#120.
  TDD RED/GREEN N/A (no implementation code, no testable behavior change
  — same precedent as S316/S273/S274/S275/S278). 1 `AskUserQuestion`
  gate at session start (owner picked “finish \#120: F12 + Process” over
  closing now with both waived, or working a different issue). 0
  stakeholder corrections.
- **F12:** deleted the two confirmed-orphan vignette source files —
  `vignettes/manual_components/_bg_algorithm.Rmd` (byte-identical
  duplicate of the built `_breeding_group_algorithm.Rmd`) and
  `_bg_formation.Rmd` (a stale 2017 draft of the built, 2025-updated
  `_breeding_group_formation.Rmd`). Confirmed via
  `grep child= vignettes/a3manual.Rmd` (neither orphan is referenced)
  and a repo-wide grep for the two filenames (only prose mentions in
  audit/session docs, no functional references) before removal.
- **Process:** added a new “Additional close-out checks” subsection to
  `CLAUDE.md`’s Project-Specific Methodology Adaptations — any session
  adding a new displayed statistic/estimator must update
  `inst/extdata/ui_guidance/population_genetics_terms.html` and the
  statistic’s own roxygen `@references` in the same session that ships
  it, per the audit’s Structural Observation 1 (citation gaps correlate
  with recency, not centrality).
- **Verification:** `R CMD build` (twice — once `--no-build-vignettes`,
  once full) both clean, confirming vignette rebuild is unaffected by
  the deletion; `devtools::check(cran=TRUE)` — **0 errors / 0 warnings /
  0 notes**, `testthat.R` and `spelling.R` both OK; fast regression read
  (`test_dir` + offender isolation) — **0 failed / 0 error / 0
  warning**, 3092 passed, 169 skipped (baseline e2e/app noise), zero
  non-baseline offenders.
- **Issue \#120 CLOSED** — all 12 citation-coverage audit findings now
  addressed (F1–F11 in S316, F12 + Process here).
- **Files:** 2 vignette source files deleted; `CLAUDE.md` (+4 lines, new
  subsection); `SESSION_NOTES.md`, `CHANGELOG.md` (this entry).

### 2026-07-08 — Fix issue \#120 §6 — apply 11/12 citation-coverage audit findings (F1–F11) (Session 316)

- **Deliverable:** REFACTOR-class, doc-only fix of the S315 audit’s §6
  priority list. TDD RED/GREEN N/A (no implementation code, no testable
  behavior change — matches the S273/S274/S275/S278 precedent for
  audit-driven doc fixes). 2 `AskUserQuestion` gates: (1) session scope
  — owner picked **F1–F11 citation fixes only**, deferring F12 (delete 2
  orphan vignette files) and the Process recommendation (a standing
  citation-checklist note); bundled with 3 owner decisions — **F4** cite
  Vinson & Raboin (2015) for
  [`rankSubjects()`](https://github.com/rmsharp/nprcgenekeepr/reference/rankSubjects.md)
  (not document-as-original), **F2** derive Gene Diversity’s citation
  from Lacy (1989) via FG (not Nei 1973), **F11** standardize on the
  Lange **1997** edition; (2) mid-session scope-shape check — owner
  chose to execute directly this session rather than write a separate
  plan document first. 0 stakeholder corrections.
- **Fixed:** `calcNeSexRatio.R`, `calcGeneDiversity.R`, `meanKinship.R`,
  `rankSubjects.R`, `groupAddAssign.R` gained `@references` (F1–F5,
  previously uncited anywhere); `modBreedingGroups.R`’s truncated Vinson
  & Raboin citation completed to the full form (F6);
  `calcFE.R`/`calcFG.R`/`calcFEFG.R`/`calcRetention.R` gained formal
  `@references` promoting the Lacy (1989) citation out of `@examples`
  comments (F8); `population_genetics_terms.html` gained citations for
  Gene Diversity and Sex-Ratio Ne plus two brand-new glossary entries
  (Genome Uniqueness, Mean Kinship) matching the existing FE/FG/GD/Ne
  format (F2, F1, F9); `gvAndBgDesc.html` gained a ranking-scheme
  citation and the Lange 1997 correction (F4, F11); `calcGU.R`/`calcA.R`
  gained the MacCluer et al. (1986) co-citation (F10);
  `_breeding_group_algorithm.Rmd` and `_genome_uniqueness_algorithm.Rmd`
  gained closing citations (F7, F9); `_summary_statistics.Rmd` gained
  inline citations for Sex-Ratio Ne and GD (F1, F2); `kinship.R`’s
  self-flagged-stale Mayo Clinic URL was dropped, keeping the durable
  `kinship2` CRAN pointer (F11).
- **Verification:** `devtools::document()` (NAMESPACE diff empty) →
  [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html) on all 13
  regenerated `.Rd` files (0 warnings) →
  [`spelling::spell_check_package()`](https://docs.ropensci.org/spelling//reference/spell_check_package.html)
  (1 new word, “JW”, hand-added to `inst/WORDLIST`) → `lintr` on all 13
  changed `R/` files (0) →
  [`tools::Rd2txt()`](https://rdrr.io/r/tools/Rd2HTML.html) spot-checks
  confirming citation prose/italics render correctly → full
  `R CMD build` (all 3 changed vignettes rebuild clean) →
  `R CMD check --as-cran` (2 NOTEs = the standing benign pair, 0 WARN/0
  ERROR; `testthat.R` 3112 PASS/0 FAIL/0 WARN).
- **\#120 left OPEN** — F12 (delete
  `_bg_algorithm.Rmd`/`_bg_formation.Rmd` orphans) and the Process
  recommendation remain; see `SESSION_NOTES.md` “Session 316” for the
  two ways to finish it out.
- **Files:** 13 `R/` roxygen edits + 13 regenerated `man/*.Rd` +
  `inst/WORDLIST` (+1 word) + 2 `inst/extdata/ui_guidance/*.html` + 3
  `vignettes/manual_components/*.Rmd`. No `R/` logic changed
  (roxygen-only).

### 2026-07-08 — Audit issue \#120 — citation coverage across computed quantities (Session 315)

- **Deliverable:** AUDIT_WORKSTREAM report (TDD N/A — no code/docs
  changed): does every computed quantity/statistic/estimator in the
  package cite its source, consistently, across the parallel doc
  surfaces (roxygen `@references`, the built vignette manual,
  `inst/extdata/ui_guidance/*.html`)? Scope gate (owner, one
  `AskUserQuestion`): broad — classify all 50 candidate files, not just
  the issue’s 8 named items. Report:
  `docs/audits/ISSUE_120_CITATION_COVERAGE_AUDIT_2026-07-08.md`.
- **Coverage:** 50/50 `R/calc*.R` / kinship / demographic /
  breeding-group-formation files + 8/8 `inst/extdata/ui_guidance/*.html`
  pages + 8/8 built/orphan vignette `manual_components/*.Rmd` files
  classified (100%).
- **Findings:** 12 total (5 High, 5 Moderate, 2 Minor). Headline: 5
  statistics have **no citation on any doc surface** — `calcNeSexRatio`
  (sex-ratio Ne), `calcGeneDiversity` (GD), `meanKinship`,
  `rankSubjects` (the core GVA ranking scheme), and `groupAddAssign`
  (the breeding-group MIS algorithm — the namesake algorithm of the
  package’s own Vinson & Raboin 2015 key reference) — despite sibling
  statistics in the same doc panel (`calcNeVariance`, `calcGU`) being
  correctly and fully cited. Moderate findings: a truncated
  `@references` on `modBreedingGroups.R`; the Lacy (1989) citation
  present only inside `@examples` comments (not a formal `@references`
  field) for `calcFE`/`calcFG`/`calcFEFG`/`calcRetention`; two live,
  built manual pages (`_breeding_group_algorithm.Rmd`,
  `_genome_uniqueness_algorithm.Rmd`) describing algorithms with zero
  citations even though a third page (`gvAndBgDesc.html`) correctly
  cites both; `population_genetics_terms.html` doesn’t define Genome
  Uniqueness or Mean Kinship at all; `calcGU`/`calcA` missing the
  MacCluer et al. (1986) co-citation `gvAndBgDesc.html` gives the same
  gene-drop algorithm. Minor: a Lange 1997-vs-2002 edition mismatch
  across two doc surfaces plus a self-flagged-stale URL in `kinship.R`;
  two orphan duplicate vignette source files not wired into the built
  manual.
- **No fixes applied this session** (audit and fix are separate sessions
  per AUDIT_WORKSTREAM and the \#109 precedent) — issue **\#120 left
  open**; report §6 gives a priority-ordered, per-finding fix list for a
  follow-on session.
- **Files:**
  `docs/audits/ISSUE_120_CITATION_COVERAGE_AUDIT_2026-07-08.md` (new).
  No `R/`, `vignettes/`, or `inst/` files changed.

### 2026-07-08 — Fix issue \#121 — test suite now WARN 0; guard `getPedMaxAge()` empty/all-NA input (Session 314)

- **Deliverable:** Eliminate the 7 unasserted test warnings so the suite
  runs `WARN 0` (keeping `FAIL 0`), under strict TDD (PRE-RED → RED →
  GREEN → concluded no-refactor). 1 scope/approach `AskUserQuestion` + 3
  phase-gate `AskUserQuestion`s; 0 stakeholder corrections.
- **Root cause (modPyramid, 5 warnings):**
  [`getPedMaxAge()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedMaxAge.md)
  (`R/getPedMaxAge.R:25`) ran `max(ped$age, na.rm = TRUE)` on a pedigree
  with no `age` column or all-NA ages, returning `-Inf` and emitting
  `no non-missing arguments to max; returning -Inf`. The pyramid
  module’s `renderPlot` re-fired on each `setInputs`, leaking 5 copies.
  Runtime-reachable (a colony import lacking birth dates), risking a
  `-Inf` axis bound — so fixed at the source, not the test.
- **GREEN:**
  [`getPedMaxAge()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedMaxAge.md)
  now returns `NA_real_` when there are no non-missing ages (its sole
  caller, `getPyramidPlot.R:52`, already maps `NA` → `binWidth`);
  `@return` roxygen updated and `man/getPedMaxAge.Rd` regenerated.
- **gvaConvergence (2 warnings):** the deliberately-invalid PSD-bound
  override path emits the `checkKinshipOverrides` “\>0.5” diagnostic
  twice (via `prepareKinshipOverrides` + `applyKinshipOverrides`) before
  erroring; the test asserted the error but leaked the warnings.
  Tightened `test_gvaConvergence_kinshipOverrides.R:157` to
  `expect_warning(expect_error(...))`, asserting both (test-only
  hygiene; no source change).
- **RED:** new `test_getPedMaxAge.R` block asserting `NA` + no warning
  on no-age-column and all-NA-age input (4 failures under the old
  source).
- **Verification:** full suite `FAIL 0 · ERROR 0 · WARN 0` (3740 passed,
  167 skipped); `devtools::check()` 0/0/0; lint 0 on `R/getPedMaxAge.R`;
  Phase-3E runtime probe rendered
  [`getPyramidPlot()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPyramidPlot.md)
  on all-NA / no-age / real-age pedigrees with 0 warnings.
- **Files:** `R/getPedMaxAge.R`, `man/getPedMaxAge.Rd`,
  `tests/testthat/test_getPedMaxAge.R`,
  `tests/testthat/test_gvaConvergence_kinshipOverrides.R`, `NEWS.Rmd`,
  `NEWS.md`. Closes \#121.

### 2026-07-08 — Implement issue \#118 Slice 4 — publish / user documentation; **closes \#118** (Session 313)

- **Deliverable:** Slice 4 (the final slice) of the \#118 plan
  (`docs/planning/issue118-effective-population-size-plan.md` §8) under
  strict TDD (PRE-RED → RED → GREEN → concluded no-refactor). 4
  `AskUserQuestion` gates (surface scope, PRE-RED→RED, RED→GREEN,
  GREEN→REFACTOR); 0 stakeholder corrections. Plain-language user
  documentation for the three effective-population-size metrics (gene
  diversity, sex-ratio Ne, variance Ne) *where they display*. **This
  slice closes \#118** (E1–E3 scope; E4 rate-of-coancestry remains
  deferred to a future effort, plan §11).
- **RED (strict TDD, docs-as-tests):** new
  `tests/testthat/test_effectivePopulationSizeDocs.R` — a static
  source-scanning guard mirroring `test_kinshipOverrideDocs.R` (the S285
  precedent):
  [`system.file()`](https://rdrr.io/r/base/system.file.html) +
  [`readLines()`](https://rdrr.io/r/base/readLines.html) +
  [`grepl()`](https://rdrr.io/r/base/grep.html) asserting each metric is
  defined/explained in the surface where it renders. RED = 19
  phrase-absent failures with the file-found checks passing
  (structurally sound).
- **GREEN (documentation, house style):**
  `inst/extdata/ui_guidance/population_genetics_terms.html` — three new
  definition blocks (mirroring the Founder Equivalents / Lacy blocks):
  Gene Diversity (`GD = 1 − 1/(2·FG)`, expected heterozygosity
  retained), Sex-Ratio effective size (`4·Nm·Nf/(Nm+Nf)`, over current
  living breeders, balanced-vs-harem, 0 when a sex is absent), Variance
  effective size (the general Crow & Kimura 1970 form, over living
  breeders of all sexes, N/A when fewer than two), a shared
  Wright-Fisher idealization caveat, and a plain-language
  rate-of-coancestry forward-pointer. `summary_stats.html` — a note on
  the GD column and the “Effective Population Size” block over *current
  living breeders* vs the analysis set. `genetic_value.html` — a
  cross-reference to the definitions panel.
  `vignettes/manual_components/_summary_statistics.Rmd` — the three
  metrics listed with their assumptions (rendered via `a3manual.Rmd`).
- **NEWS (source-of-truth fix):** added the user-facing bullet to
  `NEWS.Rmd` (the human-authored, build-ignored source) and rendered
  `NEWS.md` from it. A trial render surfaced a pre-existing divergence —
  S307 had hand-added the `minSireAge`/`minDamAge` (#119) bullet to
  `NEWS.md` only — so backfilled \#119 into `NEWS.Rmd` before rendering,
  leaving `NEWS.md` a faithful render with nothing dropped. (Owner
  directive: edit `NEWS.Rmd`, not `NEWS.md`.)
- **Verification:** new guard **23 pass / 0 fail**; full suite **3735
  pass / 0 fail / 0 error / 167 skip** (0 true offenders excl. app/e2e
  noise); spelling clean (no WORDLIST change needed — “coancestry” lives
  only in the non-scanned HTML); `devtools::check()` **0/0/0** (builds
  the vignettes). Phase 3E: rendered both module UIs and confirmed the
  guidance HTML is embedded at runtime
  (`includeHTML(system.file(...))`), so the running app serves the new
  text.
- **Also (close-out, owner-directed):** filed issue **\#121** — the
  suite is `FAIL 0` but emits 7 unasserted warnings (`test_modPyramid.R`
  ×5: [`max()`](https://rdrr.io/r/base/Extremes.html) on an empty vector
  → `-Inf` during a reactive re-render;
  `test_gvaConvergence_kinshipOverrides.R` ×2: the deliberately-invalid
  PSD-bound override path). Pre-existing test-hygiene, unrelated to this
  slice; owner deferred it to a later session. Also noted for my own
  routine: the close-out “clean regression read” should inspect the
  `warning` column, not just `failed`/`error`/`skipped`.

### 2026-07-08 — Implement issue \#118 Slice 3 — E3 variance effective size (`calcNeVariance`) (Session 312)

- **Deliverable:** Slice 3 of the \#118 plan
  (`docs/planning/issue118-effective-population-size-plan.md` §8) under
  strict TDD (PRE-RED → RED → GREEN → concluded no-refactor). 5
  `AskUserQuestion` gates (pre-RED scope D-d formula + N\<2 degeneracy,
  then PRE-RED→RED, RED→GREEN, GREEN→REFACTOR); 0 stakeholder
  corrections. ONE slice — Slice 4 (publish/docs) not started.
- **Load-bearing owner decision (D-d), and a plan correction:** the plan
  (Dragon D-7 / D-d) recommended the “mean-adjusted Crow-Kimura form”
  *on the rationale that the bare `(4N-4)/(Vk+2)` “overstates” Ne*.
  Computing all candidates on the real bundled pedigree (N=156, k̄=5.28,
  Vk=16.54) showed that rationale is **inverted**: the bare form gives
  the **lowest** value (33.4), the mean-adjusted general form gives
  **110.9**, and a rescale-to-replacement variant gives 141.7. The
  plan’s headline “skew drags E3 far below E2” only holds under the
  dimensionally-inconsistent bare form (which mixes a k̄=5.28-scale
  variance into a k̄=2 formula). Presented the three candidates with real
  values and the correction; **owner ratified the general Crow-Kimura
  form** `Ne = (N·k̄ − 1)/(k̄ − 1 + Vk/k̄)` (the standard generalization;
  reduces to the classic `(4N−2)/(Vk+2)` at replacement) and **N\<2 →
  NA**.
- **New (`R/calcNeVariance.R`, exported):** `calcNeVariance(ped)` over
  the current living breeders — reuses the S311 `getLivingBreeders(ped)`
  helper (N = number of living breeders; k̄, Vk from
  [`findOffspring()`](https://github.com/rmsharp/nprcgenekeepr/reference/findOffspring.md)
  lifetime offspring counts, all sexes counted); `NA` when fewer than 2
  living breeders (variance undefined). Roxygen states the formula, the
  living-breeder population, the Wright-Fisher idealizing assumptions,
  and `@references Crow & Kimura (1970)`. `1.0` house-style literals
  (implicit_integer_linter).
- **Wired additively:**
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  bundle gains the colony-level scalar `neVariance` (after
  `neSexRatio`) + `@return` clause; threaded through the `founderStats`
  reactive into a SECOND “Variance Ne” column in the existing
  `modSummaryStats` “Effective Population Size” block (not a third
  block) and a `Variance Ne (living breeders)` row in the
  `modGeneticValue` GV-tab summary.
  `fe`/`fg`/`fgSE`/`neGD`/`neSexRatio`/founder-count golden-master
  unchanged.
- **Verification:** full suite **3712 pass / 0 fail / 0 error** (touched
  files 0 skipped under `NOT_CRAN=true`); lint **0** on all 4 changed R
  files; spelling clean (`Kimura` hand-added to `inst/WORDLIST` sorted —
  `update_wordlist` NOT run); `devtools::check()` **0/0/0**;
  `man/calcNeVariance.Rd` + `NAMESPACE` `export(calcNeVariance)`
  regenerated. Phase 3E on real `qcPed`: 18 living breeders →
  `neVariance = 26.41` rendered live beside `neSexRatio = 17.78` in the
  Effective Population Size block. (Note: on qcPed Ne_v 26.41 \> E2
  17.78 \> census 18 — families are more even than Poisson, so the
  variance Ne legitimately exceeds the census.)
- **Also (unrelated, owner-requested):** filed issue **\#120** — an
  AUDIT_WORKSTREAM task for a future session: “are there reference
  citations for each calculation in the package?”

### 2026-07-08 — Implement issue \#118 Slice 2 — E2 demographic sex-ratio Ne (`calcNeSexRatio`) (Session 311)

- **Deliverable:** Slice 2 of the \#118 plan
  (`docs/planning/issue118-effective-population-size-plan.md` §8) under
  strict TDD (PRE-RED → RED → GREEN → concluded no-refactor). 4
  `AskUserQuestion` gates (pre-RED scope D-b/D-c/D-a + PRE-RED→RED +
  RED→GREEN + GREEN→REFACTOR); 0 stakeholder corrections. ONE slice — E3
  (Slice 3) not started.
- **Owner scope decisions (this session, via `AskUserQuestion`):** **D-b
  — living breeders in the whole pedigree** (living animals appearing as
  a sire/dam anywhere in `ped`, U-ids excluded, all-living when no
  `exit` column), independent of the proband/population selection. **D-c
  — `Ne_sr = 0`** when one breeding sex is absent (`Nm==0` or `Nf==0`,
  including no living breeders at all). **D-a (E2) — a separate
  “Effective Population Size” block** labeled “current living breeders”;
  Gene Diversity (GD) stays beside FG (the separate block deferred from
  Slice 1 is introduced here, the first living-breeder metric).
- **New functions:** `getLivingBreeders(ped)` (`@noRd` shared helper,
  reused by Slice 3/E3) returns the ids of living breeders;
  `calcNeSexRatio(ped)` (`@export`) = `4·Nm·Nf/(Nm+Nf)` over living
  breeders with known sex, `0` when a breeding sex is absent.
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  bundle gains the colony-level scalar `neSexRatio` (additively, after
  `neGD`); threaded through the `founderStats` reactive into a separate
  labeled block in `modSummaryStats` and a
  `Sex-Ratio Ne (living breeders)` row in the `modGeneticValue` GV-tab
  summary.
- **Verification:** full suite pass / 0 fail / 0 error (touched files 0
  skipped under `NOT_CRAN=true`); `fe`/`fg`/`fgSE`/`neGD`/founder-count
  golden-master unchanged; lint 0 on changed files; spelling clean;
  `devtools::check()` 0/0/0. Phase 3E on real `qcPed` data: 18 living
  breeders (Nm=8, Nf=10) → `neSexRatio = 17.78`, rendered in both live
  surfaces.

### 2026-07-08 — Implement issue \#118 Slice 1 — E1 gene diversity (`calcGeneDiversity`) (Session 310)

- **Deliverable:** Slice 1 (the tracer bullet) of the \#118 plan
  (`docs/planning/issue118-effective-population-size-plan.md` §8) under
  strict TDD (PRE-RED → RED → GREEN → concluded no-refactor). 4
  `AskUserQuestion` gates (pre-RED scope D-a/D-e/D-f + PRE-RED→RED +
  RED→GREEN + GREEN→REFACTOR); 0 stakeholder corrections. ONE slice —
  E2/E3 (Slices 2/3) not started.
- **Owner scope decisions (this session, via `AskUserQuestion`):** **D-a
  — GD displays *beside FG*** (not in a separate “Effective Population
  Size” block): firsthand, GD is over the SAME population as FG (the
  analysis set), unlike E2/E3 which are over living breeders, so the
  Dragon D-1 population-conflation concern that motivated the separate
  block does not apply to E1; the separate block is deferred to Slice 2
  (E2), the first living-breeder metric. **D-e —
  `calcGeneDiversity(fg)`** exported, bundle field `neGD`. **D-f —
  `gdSE` deferred** (a trivial function of the existing `fgSE`; addable
  later without rework).
- **New (`R/calcGeneDiversity.R`, exported):**
  `calcGeneDiversity(fg) = 1 - 1/(2*fg)` — gene diversity (expected
  heterozygosity retained relative to the founding gene pool), a pure
  deterministic function of the founder genome equivalents `FG`. `NA`
  propagates from a degenerate (`NA`) `FG`. Mirrors the
  `calcFE`/`calcFG`/`calcFGSE` idiom. `1L`/`2L` house-style literals
  (implicit_integer_linter).
- **Wired additively (`R/reportGV.R`):**
  `neGD = calcGeneDiversity(feFg$FG)` added to the `nprcgenekeeprGV`
  bundle after `fgSE` (before `maleFounders`) + documented in `@return`.
  A colony-level scalar like `fgSE` — NOT a per-animal `$report`/`$gu`
  column. Golden-master: `fe`/`fg`/`fgSE`/founder counts and the
  `$report` columns unchanged (the bundled-report `fg=52.75` tests still
  pass).
- **Display (both live surfaces):** `R/modGeneticValue.R` —
  `founderStats` reactive now threads `neGD = fr$neGD`; `gvSummary`
  appends a “Gene Diversity (GD)” Metric/Value row (`%.4f`, N/A-guarded
  for older results / degenerate `FG`). `R/modSummaryStats.R` — the
  Summary-Statistics founder table gains a “Gene Diversity (GD)”
  `<th>` + `<td>` (`%.4f`, same guard), mirroring the existing
  `FG +/- SE` inline pattern.
  [`makeFounderStatsTable()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeFounderStatsTable.md)
  (dead helper, no runtime caller) intentionally NOT touched — not in
  the plan’s Slice-1 GREEN; it silently ignores the extra `neGD` field,
  so no breakage.
- **Tests (strict TDD, all RED-verified failing for the right reason
  first):** new `tests/testthat/test_calcGeneDiversity.R` (exact
  `calcGeneDiversity(20)==0.975`, `(0.5)==0`, `(1)==0.5`,
  NA-propagation, monotonicity, scalar type); extended `test_reportGV.R`
  (both `expect_named` bundle assertions gain `neGD`; new test
  `neGD == 1-1/(2*fg)`, scalar, in `(0,1)`, not a per-animal column);
  extended `test_modSummaryStats.R` (founder table renders the GD
  header + value `0.9905`); extended `test_modGeneticValue.R`
  (`gvSummary` shows a Gene Diversity row).
- **Verify:** full suite **3657 pass / 0 fail / 0 error / 0 true
  offenders** (run with `NOT_CRAN=true` so the `skip_on_cran` module
  test files actually execute); lint **0** real findings on all 4
  changed R files;
  [`spelling::spell_check_package`](https://docs.ropensci.org/spelling//reference/spell_check_package.html)
  **clean** (`heterozygosity` hand-added to `inst/WORDLIST` in sorted
  position — `update_wordlist` NOT run); `devtools::check()` **0 ERROR /
  0 WARNING / 0 NOTE**; `man/calcGeneDiversity.Rd` + `NAMESPACE`
  `export(calcGeneDiversity)` regenerated.
- **Phase 3E (runtime behavior changed — display):** drove the real
  end-to-end render on **real qcPed data** — `reportGV(qcPed)` →
  `neGD=0.990528` → threaded through `founderStats` →
  `modSummaryStatsServer` renders the founder table
  `Known Founders 81 | Female 61 | Male 20 | FE 77.04 | FG 52.79 +/- 0.04 | Gene Diversity (GD) 0.9905`.
  GD renders beside FG with the actual computed value, not just the test
  fixture.

### 2026-07-07 — Plan issue \#118 — effective population size (Ne) estimates (Session 309)

- **Deliverable:** Planning document
  `docs/planning/issue118-effective-population-size-plan.md` (planning
  session — the plan is the deliverable; implementation is separate
  later sessions, one estimator each, per FM \#18). Seed: the S308
  triage.
- **Owner decisions (gathered this session via `AskUserQuestion`):**
  implement **E1** (gene diversity `GD = 1 - 1/(2·FG)`) + **E2**
  (demographic sex-ratio `4·Nm·Nf/(Nm+Nf)`) + **E3** (variance effective
  size) as a labeled multi-metric set over **current living breeders**,
  displayed in the GVA founder-stats surface. **E4**
  (rate-of-coancestry) **deferred**; its future-work avenues (generation
  length computed-from-data + user slider; cross-generation
  coancestry-rate estimate) posted as a comment on \#118.
- **Plan built from firsthand evidence** (read `reportGV.R`,
  `makeFounderStatsTable.R`, `findOffspring.R`, `offspringCounts.R`,
  `modGeneticValue.R`, `modSummaryStats.R`; an Explore wiring/test map;
  and a worked numeric Ne on the bundled example pedigree: living
  breeders `Nm=35`, `Nf=121` → **E2=108.6**; `N=156`, `Vk=16.5` →
  **E3=33.5** — skew drags Ne ~3× below the sex-ratio figure). 4
  implementation slices (E1 → E2 → E3 → publish/docs) with per-slice
  completion criteria + 8 consolidated dragons.
- **Corrections to the triage (firsthand):** (1) the triage’s stated
  display home
  [`makeFounderStatsTable()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeFounderStatsTable.md)/`modFounderStats`
  is a **dead helper** —
  [`makeFounderStatsTable()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeFounderStatsTable.md)
  has no runtime caller and `modFounderStats.R` does not exist; the live
  surface is `modSummaryStats.R:623-651` + `modGeneticValue.R:394-478`,
  fed from the `reportGV.R:264-276` bundle. (2) `sex` is a factor
  `{F,M,H,U}` (`NA→"U"`), so E2 must count only
  `sex=="M"`/`sex=="F"`. (3) `kbar≈5.3≠2` on the real colony, so E3
  needs the mean-adjusted variance form, not the bare `(4N-4)/(Vk+2)`.
- **No code changed** (planning deliverable): Phase-3E runtime smoke
  N/A; package build/spelling unaffected (`docs/` is not part of the
  R-package build). Close-out: this entry + PROJECT_LEARNINGS 287 +
  handoff.

### 2026-07-07 — Triage issue \#118 — “Add the effective population size estimate” (Session 308)

- **Deliverable:** Triage / scoping of \#118 (analysis only — no code
  changed):
  `docs/audits/ISSUE_118_EFFECTIVE_POPULATION_SIZE_TRIAGE_2026-07-07.md` +
  a condensed comment on \#118. Close-out: this CHANGELOG entry +
  PROJECT_LEARNINGS 286 + handoff.
- **Verdict:** A well-motivated **enhancement** (not a bug, not
  blocked), but **under-specified in two ways**: (1) “effective
  population size” is a *family* of estimators (E1
  founder-genome-equivalent/gene-diversity, E2 demographic sex-ratio
  `4NmNf/(Nm+Nf)`, E3 variance/reproductive-skew, E4 rate-of-coancestry
  `1/(2·dCbar)`), each answering a different question and needing
  different inputs; (2) the issue itself notes “place to locate output
  has not been determined.”
- **Evidence-based inventory:** most inputs already exist — FG + its SE
  (`calcFG`/`calcFGSE`), FE (`calcFE`), founder sex counts (`reportGV`),
  per-animal offspring counts (`findOffspring`, for E3’s Vk), mean
  kinship (`meanKinship`), gene-drop retention
  (`geneDrop`/`calcRetention`), generation *numbers* (`findGeneration`).
  **Gap:** no generation *length* in years / no longitudinal baseline,
  so E4 needs new data or a scoped assumption. Natural output home: the
  GVA founder-stats table (`makeFounderStatsTable`/`modFounderStats`/the
  `reportGV` bundle), where Ne sits beside FE/FG as another colony-level
  scalar — directly answering the issue’s open “location” question.
- **Recommendation (direction, not decision):** owner picks the
  estimator(s) and population in a short planning/`/grill-me` session,
  then a `docs/planning/issue118-*-plan.md` with per-slice completion
  criteria drives one-estimator-per-session TDD slices. The
  genetics-management choice (which Ne, which population) is the
  owner’s. **No implementation this session.**

### 2026-07-07 — Implement issue \#119 Slice 5 — docs/vignettes/screenshot/WORDLIST/NEWS migration to `minSireAge`/`minDamAge` (Session 307)

- **Deliverable:** Slice 5 (final) of the \#119 plan
  (`docs/planning/issue119-sex-specific-min-breeding-age-plan.md` §3
  Slice 5) under strict TDD (PRE-RED → RED → GREEN → concluded
  no-refactor). Gates: one scope `AskUserQuestion` (guard-test
  approach + screenshot handling + archived-script disposition) +
  PRE-RED→RED + RED→GREEN; 0 stakeholder corrections. ONE slice —
  **\#119 is now complete (Slices 1–5 all delivered).**
- **RED (new guard test
  `tests/testthat/test_vignettes_no_deprecated_minParentAge.R`):** scans
  every `.Rmd`/`.qmd` under `vignettes/` and fails if any code chunk
  still passes the deprecated `minParentAge=` argument (prose/backtick
  mentions excluded; `inst/extdata` archived scripts out of scope by
  design). Failed on 8 sites (RED), passes after migration (GREEN) — a
  durable regression guard for the deprecation window.
- **GREEN — migrated 8 vignette code calls** `minParentAge = X` →
  `minSireAge = X, minDamAge = X` (numeric floor preserved verbatim,
  incl. the `a2interactive.Rmd` `= 0.0` calls that deliberately use a
  low floor to flag impossible negative-age parents — mapped to `0.0`,
  NOT `NULL`): `a2interactive.Rmd` (×5: L148/766/794/807/826 post-edit),
  `articles/studbook-quality-control.qmd`,
  `articles/breeding-group-formation.qmd`,
  `articles/genetic-value-analysis.qmd`.
- **Prose/tables updated:** `a2interactive.Rmd` arg list (four→five
  args) + the “3.5 causes an error” footnote **empirically re-verified**
  — the error is triggered by **dams** (two dams ~3.3 yr in
  `ExamplePedigree.csv`; all sires older), so the footnote now names
  `minDamAge` and notes that `minSireAge = 3.5` alone does not error,
  illustrating the new sex-specific control.
  `studbook-quality-control.qmd` — the “minimum parent age” bullet, the
  `suspiciousParents` prose, the “stops” table row, and the
  Key-arguments table (`minParentAge` row split into
  `minSireAge`/`minDamAge` rows, default `NULL`).
  `manual_components/_input.Rmd` — the `modInput` return now exposes
  `minSireAge`/`minDamAge` (Slice 4 renamed the reactive).
- **Screenshot (owner: re-caption):** `ColonyManagerTutorial.Rmd` prose
  rewritten to describe the two new blank fields (blank = species+sex
  default; type a number to override a sex); the old single-field
  `input_minParentAgeSequence.png` kept with prose noting it depicts the
  earlier single-field layout (a faithful two-field screenshot cannot be
  regenerated headlessly).
- **WORDLIST / NEWS:** `inst/WORDLIST` — `minDamAge`, `minSireAge`
  hand-added in sorted position (curated file;
  [`spelling::update_wordlist`](https://docs.ropensci.org/spelling//reference/wordlist.html)
  NOT run). `NEWS.md` — user-facing entry describing the sex-specific
  breeding-age change (issue-ref `#119`; no dev-process terms in the
  prose).
- **Archived script (owner: leave):**
  `inst/extdata/trulyUnknownParents.R` kept as-is (historical working
  notes, not built by check; the deprecated alias still works).
  `vignettes/*.R`/`.html` are untracked/ignored purl/knit build
  artifacts — not edited.
- **Verify:** full suite **3633 pass / 0 fail / 0 error / 0 true
  offenders** (+1 vs S306 = the new guard; 7 warnings are the
  pre-existing `test_gvaConvergence`/`test_modPyramid` baseline); guard
  RED→GREEN confirmed;
  [`spelling::spell_check_package`](https://docs.ropensci.org/spelling//reference/spell_check_package.html)
  **clean**; `devtools::check(document = TRUE, cran = TRUE)` **0 ERROR /
  0 WARNING / 0 NOTE** with the a2interactive vignette rebuilt and
  **zero deprecation warnings in the build log**;
  `studbook-quality-control.qmd` re-rendered via quarto `--no-execute`
  (the execute path needs the package installed — env limitation,
  unrelated to the edits) confirming the split table + prose render as
  valid HTML.

### 2026-07-07 — Implement issue \#119 Slice 4 — Shiny two-field sire/dam age UX + `modPotentialParents`/`appServer` wiring (Session 306)

- **Deliverable:** Slice 4 of the \#119 plan
  (`docs/planning/issue119-sex-specific-min-breeding-age-plan.md` §3
  Slice 4) under strict TDD (PRE-RED → RED → GREEN → concluded
  no-refactor). 4 `AskUserQuestion` gates (R2 ratification +
  PRE-RED→RED + RED→GREEN + GREEN→REFACTOR); 0 stakeholder corrections.
  ONE slice — Slice 5 not started.
- **R2 ratified (owner):** (1) **blank = table default** — the two
  fields start blank, meaning “use the species+sex breeding-age table
  default” (a typed number overrides that sex); this is what actually
  resolves \#119 in the app (the old single field prefilled `2.0`,
  forcing a flat floor). (2) **Potential Parents follows the Input-tab
  fields** (one source of truth). (3) **Sire/Dam labels.**
- **Changed (`R/modInput.R`):** the single `textInput("minParentAge")`
  (prefilled `"2.0"`) becomes two optional blank fields, `minSireAge`
  (“Minimum Sire Age (years)”) and `minDamAge` (“Minimum Dam Age
  (years)”), with help text “Leave blank to use the species-specific
  default for each sex”. New `@noRd` helper `parseOptionalAge()` turns a
  field value into a numeric floor or `NULL` (blank / whitespace / `NA`
  / non-numeric → `NULL`). The `getData` observer now threads
  `parseOptionalAge(input$minSireAge)`/`parseOptionalAge(input$minDamAge)`
  into `qcStudbook`/`runQcStudbook` (blank → `NULL` → the species+sex
  table default). The single exposed `minParentAge` reactive is replaced
  by `minSireAge`/`minDamAge` reactives (return list grows 9 → 10; the
  retired reactive had **no consumer** in `appServer.R`).
- **Changed (`R/modPotentialParents.R`):**
  [`modPotentialParentsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsServer.md)
  signature `minParentAge = 2.0` →
  `minSireAge = NULL, minDamAge = NULL`; each floor is normalized with
  `if (is.function(x)) x() else x` so it accepts either a reactive
  (wired from the Input tab) or a plain scalar/`NULL`, then forwarded to
  `getPotentialParents`. `NULL` → the species+sex table default.
- **Wired (`R/appServer.R:345`):** `modPotentialParentsServer` is now
  passed `minSireAge = inputResults$minSireAge`,
  `minDamAge = inputResults$minDamAge` (previously invoked with no age
  argument → a hardcoded 2.0, unwired to the Input tab). QC and
  Potential Parents now honor the same user-set floors.
- **Tests:** two new files — `test_modInput_sexSpecificAge.R`
  (parseOptionalAge unit; two-field UI render + old field retired; the
  two reactives; blank→NULL / typed→numeric / invalid→NULL; getData
  threads the floors into the QC callees via mock-capture) and
  `test_modPotentialParents_sexSpecificAge.R` (module forwards scalar
  AND reactive floors, defaults to NULL, and honors an impossibly-high
  sire floor end-to-end). Migrated the retired single-field API in
  `test_modInput.R`, `test_modInput_coverage.R`,
  `test_modInput_qcStudbook.R`, `test_modInput_incomplete_final_line.R`,
  `test_modPotentialParents(_coverage).R`, `stubInput` in
  `test_appServer_server.R`, and **five `test-e2e-*` files** (the
  app-driver layer referenced the old `dataInput-minParentAge` input id
  and the “Minimum Parent Age” label). Deprecated-alias
  `runQcStudbook(minParentAge=)` calls (R-level, Slices 1–3 scope)
  intentionally kept.
- **Verify:** full suite 3632 pass / 0 fail / 0 error / 0 true offenders
  (7 warnings are the pre-existing
  `test_gvaConvergence`/`test_modPyramid` baseline);
  `devtools::check(--as-cran)` **0 ERROR / 0 WARNING / 0 NOTE**; lint 0
  on all 3 changed R files; `man/modInputServer.Rd` +
  `man/modPotentialParentsServer.Rd` regenerated (NAMESPACE unchanged).
- **Phase 3E (MANDATORY — runtime behavior changed, FM \#24):**
  installed the working tree and drove the **real app in headless
  Chrome** via the opt-in `shinytest2` e2e suite — 44 live-browser
  assertions across four files pass: the “Minimum Sire Age” field
  renders, `dataInput-minSireAge` accepts numeric / non-numeric / zero
  input without crashing, and the full wiring yields the locked
  50-candidate Potential-Parents regression (the species-less demo
  fixture resolves the blank floors to the table default of 2, so the
  count is preserved).
- **Deferred (per plan):** Slice 5 —
  docs/vignettes/screenshot/WORDLIST/NEWS (the vignettes and
  `inst/extdata/trulyUnknownParents.R:23` still use `minParentAge`; they
  rebuild without tripping the deprecation as build-log warnings only).

### 2026-07-07 — Implement issue \#119 Slice 3 — `minDamAge` in `getProductionStatus` (Session 305)

- **Deliverable:** Slice 3 of the \#119 plan
  (`docs/planning/issue119-sex-specific-min-breeding-age-plan.md` §3
  Slice 3) under strict TDD (PRE-RED → RED → GREEN → concluded
  no-refactor). 4 `AskUserQuestion` gates (R1 ratification +
  PRE-RED→RED + RED→GREEN + GREEN→REFACTOR); 0 stakeholder corrections.
  ONE slice — Slices 4–5 not started.
- **R1 ratified (owner): preserve 3.** The production-status dam floor
  of **3** is kept as a distinct demographic threshold
  (breeding-capacity females for the Production = Births/Dams ratio) —
  NOT unified to the species+sex breeding-age table (which would drop it
  to 2 / 2.5 and change every production ratio). `getProductionStatus`’
  dam floor keeps `default = 3`; the caller keeps passing `3L`. Every
  production golden is unchanged.
- **Changed:** `getProductionStatus()` (internal, `@noRd`) renames its
  scalar `minParentAge` parameter to `minDamAge` (default `3L`);
  `minParentAge` becomes a **deprecated alias**
  (`lifecycle::deprecate_warn(when = "2.0.0")`) that sets `minDamAge`.
  The dam-count filter is now `sex == "F" & age >= minDamAge`. Its only
  caller
  [`getGeneticDiversityStats()`](https://github.com/rmsharp/nprcgenekeepr/reference/getGeneticDiversityStats.md)
  migrates its internal call from `minParentAge = 3L` to
  `minDamAge = 3L` (production output identical). No `minSireAge` param
  — production status is females-only (plan Dragon).
- **Tests:** `test_getProductionStatus.R` — 11 golden calls migrated to
  `minDamAge` (counts byte-identical), plus a new override test
  (`minDamAge = 100` → 0 dams → NA / green, proving the parameter drives
  the filter) and a deprecation-path test (`minParentAge = 3.0` still
  reproduces the floor-3 result and warns via
  [`lifecycle::expect_deprecated`](https://lifecycle.r-lib.org/reference/expect_deprecated.html)).
- **Verification:** full suite 2944 pass / 0 fail / 0 error / 0 true
  offenders; `devtools::check(--as-cran)` 0 ERROR / 0 WARNING / 0 NOTE;
  lint 0 on both changed R files; `document()` produced no man/NAMESPACE
  diff (`@noRd`; the lifecycle imports already existed). No man page
  (the function is `@noRd`); no runtime app change — the change is
  behavior-preserving and its runtime path (`modGeneticDiversity` →
  `getGeneticDiversityStats` → `getProductionStatus`) is covered by the
  passing `test_modGeneticDiversity` / `test_getGeneticDiversityStats`
  tests.

### 2026-07-07 — Implement issue \#119 Slice 2 — sex-specific `minSireAge`/`minDamAge` in `getPotentialParents` (Session 304)

- **Deliverable:** Slice 2 of the \#119 plan
  (`docs/planning/issue119-sex-specific-min-breeding-age-plan.md` §3
  Slice 2) under strict TDD (PRE-RED → RED → GREEN → concluded
  no-refactor). 3 `AskUserQuestion` gates; 0 stakeholder corrections.
  ONE slice — Slices 3–5 not started.
- **Changed:**
  [`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
  gains `minSireAge`/`minDamAge` (default `NULL` → per-candidate
  species+sex floor via the Slice-1 `resolveBreedingAge()` helper),
  replacing the single flat age cutoff. Each candidate is now judged
  against its OWN species+sex floor before the sire/dam split, so a 3-yr
  rhesus male is not proposed as a sire (floor 4) while species-less
  pedigrees reproduce the flat-2 behavior exactly. `minParentAge`
  becomes a **deprecated alias**
  (`lifecycle::deprecate_warn(when = "2.0.0")`) that sets both new
  params; `minParentAge = NULL` still disables the age gate (legacy
  skip, mapped to `-Inf` floors). Gestation logic
  (`maxGestationalPeriod`, dam-exclusion window) untouched.
- **Internal caller:** `modPotentialParentsServer`
  (`R/modPotentialParents.R:263`) rewired to pass its `minParentAge`
  through the new `minSireAge`/`minDamAge` params so the app never trips
  `getPotentialParents`’s own deprecation warning (mirrors Slice 1’s
  `modInput` rewire; the two-field UX stays Slice 4).
- **Back-compat:** species-less `rhesusPedigree` goldens unchanged — the
  13 existing `minParentAge=` test calls migrated to explicit
  `minSireAge = 2, minDamAge = 2` (numerically identical, since an
  explicit override wins over the table even when species is present);
  only species-aware assertions were added (sire/dam exclusion + per-sex
  overrides + deprecation path). The Slice-1 `tests/testthat/setup.R`
  (`lifecycle_verbosity = "quiet"`) already covers Slice 2’s new
  deprecation warnings.
- **Verify:** full suite 2939 pass / 0 fail / 0 error / 0 true
  offenders; `devtools::check(--as-cran)` 0 ERROR / 0 WARNING / 0 NOTE
  (vignettes rebuilt, no deprecation tripped); lint 0 on changed files;
  `man/getPotentialParents.Rd` regenerated. Phase-3E: the module rewire
  is behavior-preserving and exercised by 87 passing
  `test_modPotentialParents*` server tests (the interactive app smoke
  belongs to Slice 4’s actual UX change).
- **Deferred (per plan):** Slice 3 `getProductionStatus` (+ RATIFY R1
  the 2-vs-3 default); Slice 4 Shiny two-field UX (mandatory interactive
  smoke) & `modPotentialParents`/`appServer` wiring; Slice 5
  docs/vignettes/NEWS/WORDLIST. `inst/extdata/trulyUnknownParents.R:23`
  still uses `minParentAge = 2L` (archived example script — not package
  runtime or a vignette, so it never trips the build; left for Slice 5
  or as archived).

### 2026-07-07 — Implement issue \#119 Slice 1 — QC vertical: sex-specific `minSireAge`/`minDamAge` in `checkParentAge`/`qcStudbook`/`runQcStudbook` (Session 303)

- **Deliverable:** Slice 1 of the \#119 plan
  (`docs/planning/issue119-sex-specific-min-breeding-age-plan.md` §3)
  under strict TDD (PRE-RED → RED → GREEN → concluded no-refactor). 4
  `AskUserQuestion` gates; 0 stakeholder corrections. ONE slice — Slices
  2–5 not started.
- **Added:** internal `resolveBreedingAge()` (`R/resolveBreedingAge.R`,
  `@noRd`) wraps the tested
  [`getSpeciesMinBreedingAge()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesMinBreedingAge.md)
  — both overrides `NULL` → per-(species, sex) table floor; an explicit
  `minSireAge`/`minDamAge` overrides that sex. New
  `tests/testthat/test_resolveBreedingAge.R` (15 assertions).
- **Changed:**
  [`checkParentAge()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkParentAge.md),
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md),
  [`runQcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/runQcStudbook.md)
  gain `minSireAge`/`minDamAge` (default `NULL` → species+sex table
  lookup, keyed on the **parent’s** species via a sire/dam species map
  built before the merges). `checkParentAge` now applies per-parent,
  sex- and species-specific floors instead of one flat cutoff —
  resolving \#119. `minParentAge` becomes a **deprecated alias**
  (`lifecycle::deprecate_warn(when = "2.0.0")`) that sets both new
  params; `minParentAge = NULL` still disables the check (legacy skip
  preserved exactly, mapped to `-Inf` floors). Internal Shiny caller
  `modInput.R` (2 QC call sites) rewired to the new params (single UI
  field feeds both — the two-field UX is Slice 4) so the app never trips
  its own deprecation warning (which `modInput`’s `tryCatch(warning=)`
  would swallow into an empty errorLst).
- **Back-compat:** species-less fixtures (`qcPed`, `pedGood`, …) behave
  exactly as before (table lookup falls back to floor 2); every existing
  golden count is unchanged — only species-aware assertions were added.
  New `tests/testthat/setup.R` sets
  `options(lifecycle_verbosity = "quiet")` so the package’s own test
  suite is deterministically clean while external callers still see the
  deprecation (deprecation-asserting tests force `"warning"` locally).
- **Verify:** full suite 2929 pass / 0 fail / 0 error;
  `R CMD check --as-cran` 0 ERROR / 0 WARNING / 1 baseline NOTE
  (archived-on-CRAN); vignettes rebuild OK; lint 0 on changed files;
  `man/*.Rd` regenerated; Phase-3E runtime smoke of the rewired QC calls
  PASS.
- **Deferred (per plan):** Slice 2 `getPotentialParents`; Slice 3
  `getProductionStatus` (+ RATIFY R1 2-vs-3); Slice 4 Shiny two-field UX
  (mandatory interactive smoke) & `modPotentialParents`/`appServer`
  wiring; Slice 5 docs/vignettes/NEWS/WORDLIST.

### 2026-07-07 — Plan issue \#119 — replace scalar `minParentAge` with sex-specific `minSireAge`/`minDamAge` (Session 302)

- **Deliverable:** implementation plan
  `docs/planning/issue119-sex-specific-min-breeding-age-plan.md`
  (multi-slice, strict TDD). **Planning only; no code changed** — the
  plan is the deliverable, implementation is separate
  one-slice-per-session work. Two `AskUserQuestion` ratifications with
  the owner; 0 stakeholder corrections. Seeded by the S301 triage
  (`docs/audits/ISSUE_119_MINPARENTAGE_TRIAGE_2026-07-07.md`).
- **Ratified direction (owner, S302):** **(D1) table-backed sex
  scalars** — `minSireAge`/`minDamAge` default to `NULL`, meaning “look
  up the floor per *parent* species+sex via
  [`getSpeciesMinBreedingAge()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesMinBreedingAge.md)”;
  an explicit number overrides that sex’s floor; absent/unknown species
  falls back to `2` (unchanged behavior for species-less data). Resolves
  BOTH halves of \#119 (sex AND species) with one source of truth — no
  third parallel notion of breeding age. **(D2) back-compat split by
  surface** — keep `minParentAge` as a deprecated alias (sets both,
  warns) in the exported R signatures so external scripts don’t break,
  but fully migrate the package-internal Shiny UI to
  `minSireAge`/`minDamAge` now.
- **Plan shape:** one shared internal resolver (`resolveBreedingAge`,
  wrapping the existing tested `getSpeciesMinBreedingAge`) +
  [`lifecycle::deprecate_warn`](https://lifecycle.r-lib.org/reference/deprecate_soft.html)
  (pattern mirrors `runModularApp.R:25`). Five vertical slices, one
  session each: **S1** QC vertical (`checkParentAge` + `qcStudbook` +
  `runQcStudbook` + resolver), **S2** `getPotentialParents`, **S3**
  `getProductionStatus` + `getGeneticDiversityStats` caller, **S4**
  Shiny UI migration (`modInput`/`modPotentialParents`/`appServer`
  wiring — runtime Phase-3E mandatory), **S5**
  docs/vignettes/screenshot/WORDLIST/NEWS. Each slice preserves
  species-less goldens exactly and only *adds* species-aware assertions.
- **Evidence-based inventory (mandatory for signature-change plans):**
  firsthand `git grep` over `R/ tests/ man/ vignettes/ inst/` — 3
  decision sites (`checkParentAge.R:94-95`, `getPotentialParents.R:97`,
  `getProductionStatus.R:64`), the QC plumbing
  (`qcStudbook`/`runQcStudbook`), the Shiny surface
  (`modInput.R:127,448-472,659`, `modPotentialParents.R:223,264`,
  `appServer.R:345`), plus all tests/man/vignette references, tabulated
  in the plan.
- **Deferred RATIFY points** (settled during their named slice): the
  2-vs-3 `getProductionStatus` default (recommend preserve 3 as an
  explicit dam override — don’t silently unify), the two-field Shiny UX,
  and the deprecation version string. **Load-bearing finds:**
  `checkParentAge` floor must key on the *parent’s* species (add a
  sire/dam species merge, mirroring `sireBirth`/`damBirth`);
  `modPotentialParentsServer` at `appServer.R:345` is invoked WITHOUT
  `minParentAge` (unwired to the Input field) and the `minParentAge`
  reactive `modInput.R:659` exposes has NO consumer in `appServer.R` — a
  latent loose thread the UI slice resolves.

### 2026-07-07 — Triage issue \#119 — `minParentAge` vs. sex-specific breeding ages (Session 301)

- **Deliverable:** triage/scope GitHub issue **\#119** (“Use of
  `minParentAge` seems to conflict with newer sex specific minimum
  reproductive ages”) — the issue had no body. **Analysis only; no code
  changed.** Produced
  `docs/audits/ISSUE_119_MINPARENTAGE_TRIAGE_2026-07-07.md` and posted a
  condensed version as a comment on \#119. One `AskUserQuestion`
  (direction + whether to post); 0 stakeholder corrections.
- **Finding:** the conflict is real, already known, and was deliberately
  deferred. The package holds two independent notions of “minimum age to
  be a parent”: **(A)** the legacy scalar `minParentAge`
  (sex/species-agnostic; default 2, but 3 in `getProductionStatus`)
  driving QC (`checkParentAge.R:94-95`), candidate-finding
  (`getPotentialParents.R:97`), and production status
  (`getProductionStatus.R:64`); and **(B)** a newer species+sex table
  (`speciesGestation$minMaleBreedingAge`/`minFemaleBreedingAge` via
  `getSpeciesMinBreedingAge`, e.g. rhesus male 4.0 / female 2.5) used by
  only the \#9 GVA unknown-parent correction. A rhesus male sire at age
  3 passes QC (3 ≥ 2) but is below breeding age for (B) (floor 4);
  `getPotentialParents` is even internally inconsistent (species-aware
  gestation, flat-scalar breeding age).
- **Not a defect:** the plan that introduced (B) explicitly fenced this
  off — `docs/planning/issue9-gva-unknown-parent-ranking-plan.md` §8-D
  (line 229): *“Do NOT retrofit `getPotentialParents`/`checkParentAge` …
  Unifying breeding-age determination package-wide is a follow-up.”*
  **\#119 is that follow-up.**
- **Options laid out** (unify-on-table / sex-scalars-only /
  document-only / won’t-fix); high blast radius (both QC sites sit under
  `qcStudbook`, `getPotentialParents` feeds breeding-group formation) →
  any fix is vertical slices under strict TDD. **Owner decision
  (S301):** the resolution direction is **deferred to a dedicated
  planning session**; the triage recommends that planning session
  (settle Option + override precedence + unknown-species fallback +
  slice order) as the ratified next step. Not blocked (no missing data
  source, unlike \#116).

### 2026-07-07 — Remove the now-dead `fixGenotypeCols()` function (Session 300)

- **Deliverable (the tail of the S297/S299 \#117 spinoff):** delete the
  orphaned `@noRd fixGenotypeCols()` function (`R/fixGenotypeCols.R`) +
  its test (`tests/testthat/test_fixGenotypeCols.R`) + its two dangling
  `inst/_pkgdown.yml` reference-index entries. **REFACTOR-only
  (dead-code deletion, S298 grep-branch: nothing executed in-package
  changes); one `AskUserQuestion` PRE-RED→REFACTOR gate, one landing
  gate; 0 stakeholder corrections.** Landed as `374d08c5` on master
  (owner chose direct-commit); this docs close-out records that hash.
- **Why removable:** `fixGenotypeCols()` was a self-admitted band-aid —
  its `@noRd` note said “This is not a good fix. A better solution is to
  avoid the problem. Currently qcStudbook() blindly changes all of the
  column names by removing the underscores.” It repaired the genotype
  headers `first_name`/`second_name` that
  [`fixColumnNames()`](https://github.com/rmsharp/nprcgenekeepr/reference/fixColumnNames.md)’s
  blanket underscore strip (`R/fixColumnNames.R:28`) collapsed to
  `firstname`/`secondname` — actively producing the *un-documented*
  spelling of columns that `data.R`, `getPossibleCols.R`,
  `checkGenotypeFile.R`, `geneDrop.R`, and `headerDisplayNames.R` all
  document canonically *with* underscores. S297 (`fdcfc042`, \#117)
  fixed that at the source (restore on the returned `newCols`), and S299
  (`436dc749`) removed the redundant `fixGenotypeCols(sb)` call from
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md).
  After S299 the function had **zero in-package callers**
  (grep-confirmed across `R/`, `tests/`, `man/`, `NAMESPACE`, `inst/`,
  `vignettes/`) — only its own test exercised it. Dead code kept alive
  by its own test.
- **Evidence-based inventory (mandatory for deletions):**
  `git grep fixGenotypeCols` over code paths returned only the
  definition, its own test, and two explanatory comments in
  `test_qcStudbook.R:340-342` (left intact — they stay accurate and
  explain the S299 guard). It also surfaced two `inst/_pkgdown.yml`
  entries (lines 60, 156) that S299’s notes did not mention — dangling
  references, since a `@noRd` topic has no man page for pkgdown to link;
  removing the function makes removing them mandatory.
- **Coverage not lost:** the `first_name`/`second_name` invariant is
  covered end-to-end by the S299 guard test in `test_qcStudbook.R` (5
  header spellings through
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)),
  and
  [`fixColumnNames()`](https://github.com/rmsharp/nprcgenekeepr/reference/fixColumnNames.md)
  keeps its own `test_fixColumnNames.R`. `test_fixGenotypeCols.R` only
  exercised the deleted function.
- **Verify (firsthand):** full suite (`NOT_CRAN=true`) **0 failed / 0
  error** (7 baseline warnings — 2
  `test_gvaConvergence_kinshipOverrides` + 5 `test_modPyramid` —
  unchanged, none new); `document()` **zero `man/`/`NAMESPACE` delta**
  (the fn was `@noRd`, no man page → deletion is doc-inert);
  `spell_check_package` clean; **`R CMD check --as-cran` Status: OK —
  0/0/0** (repo root, WITH vignettes; 3m12s). **Phase-3E covered by
  `--as-cran`** (it rebuilt vignettes and ran examples
  incl. [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  with the function gone — Status OK is the runtime proof no path
  referenced it); no app launch needed (the deletion removed no runtime
  behavior — the function already had no caller after S299). `lintr`
  **N/A** — deletions only; no R source lines added or modified (the one
  edited file, `_pkgdown.yml`, is YAML).

### 2026-07-06 — Remove the redundant `fixGenotypeCols()` call from `qcStudbook()` (Session 299)

- **Deliverable (owner picked the OTHER S297 spinoff):** remove the
  redundant `sb <- fixGenotypeCols(sb)` call at `R/qcStudbook.R:288`.
  **REFACTOR (behavior-inert removal of executed-but-inert code,
  S295/S298 precedent); one `AskUserQuestion` PRE-RED→REFACTOR gate, one
  landing gate; 0 stakeholder corrections.** Landed as `436dc749` on
  master (owner chose direct-commit); this docs close-out records that
  hash.
- **Why redundant:** S297’s
  [`fixColumnNames()`](https://github.com/rmsharp/nprcgenekeepr/reference/fixColumnNames.md)
  fix (`fdcfc042`, \#117) now restores every spelling of the genotype
  headers — `first_name`/`second_name`, the space form (`First Name`),
  the period form (`first.name`), the already-collapsed form
  (`firstname`), and upper-case (`FIRSTNAME`) — to canonical
  `first_name`/`second_name` *before* line 288. `fixGenotypeCols()` only
  renames a column literally named `firstname`/`secondname`, and no such
  column ever reaches line 288, so the call was a provable no-op. Its
  `@noRd` note already said “a better solution is to avoid the problem”
  — S297’s fix IS that better solution.
- **Behavior-inertness PROVEN before the edit (not reasoned):** an
  identity-override
  [`identical()`](https://rdrr.io/r/base/identical.html) battery
  (replacing `fixGenotypeCols` with `function(ped) ped` is exactly
  equivalent to removing the call) over 10 inputs (7 genotype-header
  spellings + the shipped 31-row
  `obfuscated_rhesus_mhc_breeder_genotypes.csv` fixture +
  `examplePedigree` + `pedGood`) returned `identical()==TRUE` under
  `reportErrors=FALSE/TRUE` and `reportChanges=TRUE`; a trace showed
  `fixGenotypeCols` **fires 0 times** at line 288 (never sees a bare
  `firstname`/`secondname`). An adversarial refutation workflow (4
  independent agents running real R across exotic spellings, the
  reintroduction paths through
  `addUIds`/`addParents`/`removeDuplicates`, the `reportErrors=TRUE` and
  missing-column branches, real shipped fixtures, and
  duplicate/collision inputs) **could not refute it (0/4)**; one agent
  confirmed the proof is non-vacuous (with `fixGenotypeCols` forced to
  identity, a `firstname` input still emerges as `first_name` —
  [`fixColumnNames()`](https://github.com/rmsharp/nprcgenekeepr/reference/fixColumnNames.md)
  does the work).
- **Added a durable end-to-end guard test** to
  `tests/testthat/test_qcStudbook.R`:
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  on an `id/sire/dam/sex/birth + first_name/second_name` input keeps
  `first_name`/`second_name` and never `firstname`/`secondname`, across
  5 header spellings. It passed WITH the call present (locking the
  invariant), then stayed green after removal — so a future
  [`fixColumnNames()`](https://github.com/rmsharp/nprcgenekeepr/reference/fixColumnNames.md)
  regression is caught now that the `fixGenotypeCols()` safety net is
  gone.
- **Scope kept surgical (FM \#8):** the **call only**. The
  now-only-tested `@noRd fixGenotypeCols()` function + its
  `test_fixGenotypeCols.R` are left intact for a separate session’s own
  strict-TDD evaluation.
- **Verify:** full suite (`NOT_CRAN=true`) **0 failed / 0 error** (3733
  tests; 7 baseline warnings — 2
  `test_gvaConvergence_kinshipOverrides` + 5 `test_modPyramid` —
  unchanged, none new); `lintr` 0 on both changed files;
  `spell_check_package` clean; `document()` **zero `man/`/`NAMESPACE`
  delta** (call removal is roxygen-inert); **`R CMD check --as-cran`
  Status: OK — 0/0/0** (repo root, WITH vignettes). **Phase-3E covered
  by `--as-cran`** (examples + vignettes + full suite exercise
  `qcStudbook` with the call removed) plus the new guard test and the
  `test_modInput_qcStudbook.R` genotype-merge integration test.

### 2026-07-06 — NAMESPACE cleanup — drop the two redundant `lubridate` day/month imports (Session 298)

- **Deliverable (owner picked cleanup \#1 from S297’s SUGGESTED NEXT):**
  regenerate `NAMESPACE` via `devtools::document()` to drop the two
  redundant lines `importFrom(lubridate, day)` and
  `importFrom(lubridate, month)`. **REFACTOR-only (generated-file
  regeneration, no behavior change); one `AskUserQuestion`
  PRE-RED→REFACTOR gate, one landing gate; 0 stakeholder corrections.**
- **Why redundant (verified firsthand):** of the 13
  `importFrom(lubridate, …)` lines, only `day` and `month` had no
  corresponding roxygen `@importFrom lubridate` tag anywhere in `R/`
  (the other 11 all do). Both symbols are used only as fully-qualified
  [`lubridate::month`](https://lubridate.tidyverse.org/reference/month.html)/[`lubridate::day`](https://lubridate.tidyverse.org/reference/day.html)
  (`getPyramidPlot.R:99,101`) — grep confirms no bare `month()`/`day()`
  call exists in `R/` — so the two imports were dead weight
  (behavior-inert to remove).
- **Change:** `devtools::document()` produced exactly the two deletions
  with **zero `man/` delta**. A second `document()` run left `NAMESPACE`
  byte-identical, so **`document()` is now idempotent for `NAMESPACE`**
  — resolving the standing non-idempotency gotcha carried since S295.
- **Verify (firsthand):** NAMESPACE diff = exactly the 2 deletions;
  `man/` zero delta; full-suite regression read (`NOT_CRAN=true`) **0
  failed / 0 error** (7 baseline warnings —
  `test_gvaConvergence_kinshipOverrides` + `test_modPyramid`, none new);
  `spell_check_package` clean; `R CMD check --as-cran` (repo root, WITH
  vignettes, via `devtools::check(document=FALSE)`) **Status: OK —
  0/0/0**.
- **Phase-3E (runtime):** covered — the `--as-cran` run rebuilt
  vignettes and ran examples + the full test suite, exercising
  `getPyramidPlot` (the
  [`lubridate::month`](https://lubridate.tidyverse.org/reference/month.html)/[`lubridate::day`](https://lubridate.tidyverse.org/reference/day.html)
  caller); the package loads and runs correctly with the two imports
  removed. Landed as `aff4d262` on master (owner chose direct-commit).
- **Closes the “Separate finding” flagged in the Session 295 entry
  below** (the redundant `lubridate` day/month NAMESPACE lines).

### 2026-07-06 — \#117 — fix `fixColumnNames()` first_name/second_name overreach cleanup so the restoration reaches newColNames (Session 297)

- **Deliverable:** fix the ineffective “clean up possible overreach”
  block in `R/fixColumnNames.R` (L31-36). The block restored the
  genotype-bearing headers `first_name`/`second_name` (which the
  underscore-strip pass at L28 collapses to `firstname`/`secondname`)
  but wrote to the local `cols`, which L39 (`cols <- newCols`)
  immediately overwrote; the function returns `newCols`, so the
  restoration never reached `newColNames`. Both the space form
  (`"First Name"`) and the underscore form (`"first_name"`) came back
  `firstname`/`secondname`. **Strict TDD bug fix; one `AskUserQuestion`
  PRE-RED→RED gate (with the surgical-scope decision), one RED→GREEN
  gate, one landing gate; 0 stakeholder corrections.**
- **Root cause + fix:** retarget the block from `cols` to `newCols` (the
  returned vector) — `if (any(tolower(newCols) == "firstname"))` /
  `newCols[...] <- "first_name"` and the `secondname` twin. A minimal
  in-body change (2 condition + 2 assignment lines retargeted; the
  inline comment expanded to state the intent + issue). Now every
  spelling of the two genotype headers — space (`First Name`),
  underscore (`first_name`), period (`First.Name`), and the
  already-collapsed form (`firstname`) — normalizes to canonical
  `first_name`/`second_name` in `newColNames`. The block now mirrors the
  downstream `fixGenotypeCols()` workaround exactly.
- **RED → GREEN:** rewrote `tests/testthat/test_fixColumnNames.R` from
  the 2 characterization tests (which pinned the *defective* output per
  the \#111 coverage-slice note) to 8 blocks / 10 assertions asserting
  the *corrected* contract — all four input spellings, only-first,
  only-second, mixed-with-canonical (`EGO`/`Sire_ID` + genotype), the
  `underScoreRemoved == character(0)` diagnostic for the underscore form
  (the previously spurious record is gone), plus a no-genotype invariant
  guard. RED: 7/8 blocks fail (9 assertion failures), the invariant
  guard passes. GREEN: all 10 assertions pass, invariant stays green.
- **Verify (firsthand):** `test_fixColumnNames.R` 8/8 pass; full-suite
  regression read (`NOT_CRAN=true`) **244 files, 0 failed / 0 error** (7
  baseline warnings — `test_gvaConvergence_kinshipOverrides` +
  `test_modPyramid`, none new); `lintr::lint()` on both changed files =
  **0**; `spell_check_package` clean; `devtools::document()` **zero
  `man/` delta** (the fix is inside the function body, roxygen-inert) —
  reverted the known pre-existing `lubridate` day/month NAMESPACE drift
  `document()` re-surfaced; `R CMD check --as-cran` (repo root, WITH
  vignettes) **Status: OK — 0/0/0**.
- **Phase-3E (integration):**
  [`fixColumnNames()`](https://github.com/rmsharp/nprcgenekeepr/reference/fixColumnNames.md)’s
  only production caller is
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  (`:179`), which also runs the idempotent `fixGenotypeCols()`
  workaround (`:288`), so the fix leaves `qcStudbook`’s *net* output
  unchanged — proven by
  `test_qcStudbook`/`test_species_first_class`/`test_exampleData_columnNames`
  all passing unchanged, and by a live
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  run on a genotype-bearing pedigree returning
  `first_name`/`second_name` with no collapsed forms. Scope kept
  surgical: `fixGenotypeCols` left as a harmless safety net for a
  separate future evaluation.

### 2026-07-06 — \#111 — remove the last uncovered line (proven-dead branch in dataframe2string.R) → package 100% coverage (Session 295)

- **Deliverable (owner directed the removal over a `# nocov` waive):**
  delete the genuinely-dead defensive branch `R/dataframe2string.R`
  L47-50
  (`if (is.null(rowNames)) rowNames <- as.character(seq_len(NROW(m)))`).
  **REFACTOR-only (dead-code removal, no behavior change); one
  `AskUserQuestion` PRE-RED→REFACTOR gate, one landing gate; 0
  stakeholder corrections.**
- **Why it is dead:** for a data frame with ≥1 row,
  `dimnames(object)[[1L]]` (==
  [`row.names()`](https://rdrr.io/r/base/row.names.html)) is never NULL;
  the 0-row case already exits at L36-37; a matrix either has 0 rows (→
  L37) or has row names (→ the `is.null` guard is FALSE). So the `if`
  never fires for any input the function can process (S293 first proved
  this; S294 flagged it as a waive-or-remove decision).
- **Verify (firsthand):** **behavior-inert proof** —
  [`identical()`](https://rdrr.io/r/base/identical.html) output between
  the current and guard-removed versions over 10 inputs (data frames
  with default + custom row names, 1-column, 1-row, 0-column, 0-row,
  matrices with and without row names, and `addRowNames=FALSE`) — ALL
  identical; existing `test_dataframe2string.R` + full suite **0 failed
  / 0 error / 0 true offenders** (7 baseline warnings, none new); `covr`
  (`NOT_CRAN=true`) confirms `dataframe2string.R` **100%** and **overall
  package coverage 99.99% → 100.00%**; `lintr::lint()` = **0**;
  `devtools::document()` produced **zero `man/` delta** (roxygen-inert);
  `R CMD check --as-cran` (repo root, WITH vignettes) **Status: OK —
  0/0/0**. Phase-3E N/A — pure exported function, no runtime wiring (the
  only caller is `test_dataframe2string.R`). Landed as `dfedaa90` on
  master (owner chose direct-commit).
- **This brings the package to 100% line coverage package-wide,
  effectively completing issue \#111.**
- **Separate finding (NOT fixed here — outside scope):** the committed
  `NAMESPACE` carries two redundant lines, `importFrom(lubridate, day)`
  and `importFrom(lubridate, month)`, that no roxygen `@importFrom`
  declares (`getPyramidPlot.R` uses
  [`lubridate::day`](https://lubridate.tidyverse.org/reference/day.html)/[`lubridate::month`](https://lubridate.tidyverse.org/reference/month.html)
  via explicit `::`, needing no import). `document()` removes them, so
  it is currently non-idempotent for `NAMESPACE`. Harmless (checks 0/0/0
  with them); a ~30-second cleanup for its own session.

### 2026-07-06 — \#111 code-coverage campaign, slice 10 — the last two Shiny modules (modPedigree + modBreedingGroups) backfilled to 100% (Session 294)

- **Deliverable (owner said “continue \#111”, then approved batching
  both remaining modules):** the two remaining sub-100% Shiny modules
  driven to 100% line coverage via
  [`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)
  backfill tests. **Test-only (no production code changed); one
  `AskUserQuestion` PRE-RED→RED + scope gate, one landing gate; 0
  stakeholder corrections.**
- **Files and the exact branch each test reached** (uncovered lines
  dumped with
  [`covr::zero_coverage`](http://covr.r-lib.org/reference/zero_coverage.md),
  `NOT_CRAN=true`; each proven reachable by a
  [`covr::function_coverage`](http://covr.r-lib.org/reference/function_coverage.md)
  probe before writing):
  - `modPedigree.R` 97.72% → **100%** — L274-277, the focal-file
    `read.csv` error handler (existing tests only upload valid CSVs);
    and L371/L374, the export `downloadHandler` filename + content
    (never invoked). New `test_modPedigree_coverage.R` (2 `testServer`
    tests): a `focalAnimalFile$datapath` pointing at a nonexistent path
    makes `read.csv` throw → the `tryCatch` error branch runs, leaving
    the typed IDs intact; `path <- output$exportPedigree` runs both
    handler fns → a real 5-row CSV.
  - `modBreedingGroups.R` 98.56% → **100%** — L175, the
    `getKinshipMatrix` branch that returns a geneticValues-supplied
    kinship matrix (every existing test passes `geneticValues=NULL`,
    forcing the pedigree recompute); L505/510/515, the
    NULL-`groupResults` guards in the returned
    `score`/`unassigned`/`groupKinship` reactives (existing tests always
    form groups first); and L269, the `currentGroups` truncation guard.
    New `test_modBreedingGroups_coverage.R` (3 `testServer` tests):
    `geneticValues=reactive(list(id, kinship=kmat))` → L175 (proven via
    `groupResults()$kmat` identical to the supplied matrix); reading
    `score()`/`unassigned()`/`groupKinship()` before `formGroups` → the
    three NULL guards at once; `nGroups=0` → the truncation guard L269.
- **L269 was TESTED, not waived** (unlike `dataframe2string` L49, which
  S293 proved unreachable). The guard fires only when `currentGroups`
  (length 1 when unseeded) exceeds `numGp`, i.e. `numGp < 1`; the sole
  trigger is `nGroups=0` (below the UI `min=1`). The `function_coverage`
  probe proved it reachable without an uncaught error. The degenerate
  input also makes the downstream formation warn (“items to replace”),
  suppressed at the test since the guard itself is clean.
- **Verify (firsthand):** both new files 5 tests / 0 failed / 0 error /
  0 warning; `covr` (full suite, `NOT_CRAN=true`) confirms both files
  **100%** and overall **99.83% → 99.99%**; full-suite regression read
  **0 failed / 0 error / 0 true offenders** (7 baseline warnings —
  `test_gvaConvergence_kinshipOverrides` + `test_modPyramid`, none from
  the new files); `lintr::lint()` on both new files = **0**;
  `R CMD check --as-cran` (repo root, WITH vignettes) **Status: OK —
  0/0/0**. Phase-3E N/A — test-only, no `R/` or runtime change (FM \#24
  has no target). Landed as `2613af12` on master (owner chose
  direct-commit).
- **This closes the last two sub-100% Shiny modules.** The only file now
  below 100% package-wide is `dataframe2string.R` (96.88%, the
  proven-unreachable L49 — a `# nocov` waive decision, a separate 1-line
  production choice).

### 2026-07-06 — \#111 code-coverage campaign, slice 9 — six single-file helpers backfilled to 100% in one batched session (Session 293)

- **Deliverable (owner said “continue \#111 with checkKinshipOverrides”,
  then approved batching the remaining trivial single-file residuals
  into one session):** the first post-Shiny-module tier — six
  plain-function helper files driven to 100% line coverage via ordinary
  `test_that` backfill tests. **Test-only (no production code changed);
  three `AskUserQuestion` gates — a PRE-RED→RED for
  `checkKinshipOverrides`, then a batch-scope decision, then a combined
  PRE-RED→RED for the other five; 0 stakeholder corrections.**
- **Files and the exact branch each test reached** (uncovered lines
  dumped with
  [`covr::zero_coverage`](http://covr.r-lib.org/reference/zero_coverage.md),
  `NOT_CRAN=true`, before writing):
  - `checkKinshipOverrides.R` 96.43% → **100%** — L47, the non-numeric
    `kinship`-column [`stop()`](https://rdrr.io/r/base/stop.html)
    (existing tests only pass numeric / NA / negative kinship). New
    test: a character and a factor kinship column →
    `expect_error(..., "must be numeric")`.
  - `correctUnknownParentMeanKinship.R` 97.30% → **100%** — L146
    (unnamed `indivMeanKin` → early return) and L152 (a ped with no
    `exit` column → `exit` defaulted to `as.Date(NA)`). Two `test_that`
    cases on separate branches.
  - `loadSpeciesOverrides.R` 96.72% → **100%** — L139–140, the internal
    `mergeSpeciesOverrides` append branch for a species absent from the
    bundled table (every existing test overrides “RHESUS”, already
    present). New test: append a novel “GORILLA” row.
  - `orderReport.R` 97.73% → **100%** — L42, the `getFounders(ped)`
    fallback taken when the report has no `parentage` column.
  - `getPyramidPlot.R` 98.36% → **100%** — L40, the
    `ageUnit == "months"` age-conversion branch.
  - `getPotentialParents.R` 96.88% → **100%** — L151–152, the
    empty-`potentialDams` fallback to all old-enough females (a
    candidate dam with no offspring is dropped by the proven-breeder
    filter, emptying the set and forcing the fallback, which re-admits
    her).
- **`dataframe2string.R` L49 was investigated and PROVEN unreachable for
  the documented input type, and left untouched** (this was NOT a
  production change): `dimnames.data.frame(x)` is
  `list(row.names(x), names(x))`, so `dimnames(object)[[1L]]` mirrors
  [`row.names()`](https://rdrr.io/r/base/row.names.html) and is NULL
  only when `nRows == 0`, which is already intercepted upstream at
  L36–37; a matrix cannot reach it either. It is inherited defensive
  code from `print.data.frame`. Waiving it (or a `# nocov`) is a
  separate future decision, not a coverage-backfill task. The file stays
  at 96.88%.
- **Method:** the six single-file investigations were fanned out to
  parallel probe agents (a `Workflow`), each of which PROVED its fixture
  reaches the target line with `covr::function_coverage(fn, code)`
  before any repo file was touched; the one unreachable line was caught
  and dropped by that proof step.
- **Result:** all six target files at **100%**; overall coverage 99.71%
  → **99.83%** (`NOT_CRAN=true`). Only three files remain sub-100%:
  `dataframe2string` (the unreachable defensive line) and the two
  deferred Shiny modules `modPedigree` (97.72%) and `modBreedingGroups`
  (98.56%), which need `testServer` slices.
- **Verified:** the 6 modified test files run 0 failed / 0 error / 0
  warning; `covr` (full suite, `NOT_CRAN=true`) confirms all six at 100%
  and overall 99.83%; full-suite regression read 0 failed / 0 error / 0
  true offenders (7 baseline warnings, none from the changed files);
  `lintr::lint()` on all six changed files = 0; `R CMD check --as-cran`
  (repo root, WITH vignettes, via `devtools::check`) Status: OK — 0
  errors / 0 warnings / 0 notes. Phase-3E N/A (test-only, no runtime
  surface).
- **Campaign status:** \#111 stays OPEN. Slices done: S1–S8 (helper
  tier + all seven Shiny modules), **S9 six single-file helpers (this
  session)**. Remaining: `modPedigree` and `modBreedingGroups`
  (`testServer` slices), and the `dataframe2string` L49 waive decision.

### 2026-07-06 — \#111 code-coverage campaign, slice 8 — `modGeneticValue` backfilled 96.26% → 100%, closing the last residual Shiny module (Session 292)

- **Deliverable (owner said “continue \#111” → `modGeneticValue`, the
  last residual Shiny module at 96.26%):** add a headless
  [`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)
  suite covering the residual branches the two existing modGeneticValue
  suites never reached — the kinship-override warning handler, the
  empty-probands fallback, and several defensive report-shape guards.
  **Test-only (no production code changed); PRE-RED→RED gate via
  `AskUserQuestion`; 0 stakeholder corrections.**
- **Gap pinpointed by exact uncovered-line dump
  ([`covr::zero_coverage`](http://covr.r-lib.org/reference/zero_coverage.md),
  `NOT_CRAN=true`):** 13 uncovered lines, all in
  `modGeneticValueServer`, in five groups — (1) the
  `kinshipOverrideData` `> 0.5` warning handler (`R/modGeneticValue.R`
  L193–197); (2) the `gvResults` empty-probands fallback (L244–245); (3)
  the `return(report)` guard when the report lacks `indivMeanKin` (L286)
  and the three NULL-report guards in
  `gvaView`/`geneticValues`/`topAnimals` (L319, L442, L454); (4) the
  demote `else` branch when the report has no `value` column (L298); (5)
  the `gvSummary` `genomeUniquenessSE` fallback when `guSE` is absent
  (L366). The two existing suites drive the happy path exhaustively but
  always supply a valid override (≤ 0.5), a live population, and a
  well-formed report, so these guards never ran.
- **New `tests/testthat/test_modGeneticValue_coverage.R`** (5
  `testServer` tests / 15 expectations): (1) upload a valid override CSV
  with kinship 0.6 and read `kinshipOverrideData()` → the warning is
  muffled and the override still applied (L193–197); (2) a pedigree
  whose `population` column is all-FALSE + a mocked `reportGV` →
  empty-probands fallback to all ids (L244–245); (3) a mocked `reportGV`
  returning `report = NULL` →
  `gvResults()`/`gvaView()`/`geneticValues()`/`topAnimals()` all NULL
  (L286, L319, L442, L454) — one mock covering four lines; (4) a mocked
  `reportGV` report with no `value` column → demote-`else` rank path
  (L298); (5) a mocked `reportGV` report carrying `genomeUniquenessSE`
  (no `guSE`) → the Summary panel reports that column’s worst-case value
  (L366).
- **Result:** `R/modGeneticValue.R` 96.26% → **100%** (zero uncovered
  lines); overall coverage 99.53% → **99.71%** (`NOT_CRAN=true`). **This
  closes the last residual Shiny module** — every remaining gap is now a
  small single-file helper.
- **Verified:** new file 5 tests / 15 expectations green, 0 warnings
  (all mechanisms de-risked with a throwaway `load_all`/`testServer`
  probe before writing); `covr` confirms 100% + overall 99.71%; full
  suite (`NOT_CRAN=true`, package loaded) 0 failed / 0 error / 0 true
  offenders (7 baseline warnings, none from this file); `lintr::lint()`
  on the new file = 0; `R CMD check --as-cran` (repo root, WITH
  vignettes, via `devtools::check`) Status: OK — 0 errors / 0 warnings /
  0 notes. Phase-3E N/A (test-only, no runtime surface).
- **Campaign status:** \#111 stays OPEN. Slices done: S1 helper tier
  (S285), S2 `modORIPReporting` (S286), S3 `appServer` (S287), S4
  `modInput` (S288), S5 `modPyramid` (S289), S6 `modSummaryStats`
  (S290), S7 `modPotentialParents` (S291), **S8 `modGeneticValue` (this
  session)** — all residual Shiny modules now at 100%. Remaining: small
  single-file residuals (`checkKinshipOverrides` 96.43%,
  `loadSpeciesOverrides` 96.72%, `dataframe2string` 96.88%,
  `getPotentialParents` 96.88%, `correctUnknownParentMeanKinship`
  97.30%, `modPedigree` 97.72%, and others).

### 2026-07-06 — \#111 code-coverage campaign, slice 7 — `modPotentialParents` backfilled 94.67% → 100% via a mixed-branch `testServer` suite (Session 291)

- **Deliverable (owner said “continue \#111” → `modPotentialParents`,
  the lowest-coverage residual module at 94.67%):** add a headless
  [`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)
  suite covering the residual eventReactive input guards, the
  no-pedigree status branch, and the never-invoked download handler.
  **Test-only (no production code changed); PRE-RED→RED gate via
  `AskUserQuestion`; 0 stakeholder corrections.**
- **Gap pinpointed by exact uncovered-line dump
  ([`covr::zero_coverage`](http://covr.r-lib.org/reference/zero_coverage.md),
  `NOT_CRAN=true`):** 9 uncovered lines, all in
  `modPotentialParentsServer`, in three groups — (1) the
  `potentialParents` eventReactive’s NULL-pedigree `return(NULL)`
  (`R/modPotentialParents.R` L257) and NULL/NA gestation fallback to 210
  (L261); (2) the `statusMessage` “No pedigree is loaded” warning branch
  (L283-287); (3) the `downloadParents` filename + content handlers
  (L321, L324). The existing `test_modPotentialParents.R` exhaustively
  covers the four pure helpers and drives
  `tableData()`/`gestationDefault()`, but its fixtures always pass a
  valid pedigree + numeric gestation and never invoke the download, so
  these branches never ran.
- **New `tests/testthat/test_modPotentialParents_coverage.R`** (3
  `testServer` tests / 10 expectations): (1) a NULL pedigree + Find
  click → empty table (L257) AND the no-pedigree warning (L283-287) in
  one state; (2) a rhesus pedigree with an NA gestation input → the
  210-day fallback (L261) still yields the full candidate set
  (incl. `BRI2MW`); (3) invoking `output$downloadParents` → a real
  50-row CSV with the expected columns (L321, L324).
- **Result:** `R/modPotentialParents.R` 94.67% → **100%** (zero
  uncovered lines); overall coverage 99.41% → **99.53%**
  (`NOT_CRAN=true`).
- **Verified:** new file 3 tests / 10 expectations green, 0 warnings;
  `covr` confirms 100% + overall 99.53%; full suite (`NOT_CRAN=true`,
  package loaded) 0 failed / 0 error / 0 true offenders (7 baseline
  warnings, none from this file); `lintr::lint()` on the new file = 0;
  `R CMD check --as-cran` (repo root, WITH vignettes, via
  `devtools::check`) Status: OK — 0 errors / 0 warnings / 0 notes (its
  `spelling.Rout` comparison passed → spell clean). Phase-3E N/A
  (test-only, no runtime surface).
- **Campaign status:** \#111 stays OPEN. Slices done: S1 helper tier
  (S285), S2 `modORIPReporting` (S286), S3 `appServer` (S287), S4
  `modInput` (S288), S5 `modPyramid` (S289), S6 `modSummaryStats`
  (S290), **S7 `modPotentialParents` (this session)**. Remaining:
  `modGeneticValue` (96.26%, the new lowest and last residual module) +
  small single-file residuals.

### 2026-07-06 — \#111 code-coverage campaign, slice 6 — `modSummaryStats` backfilled 94.34% → 100% via a scattered-branch `testServer` suite (Session 290)

- **Deliverable (owner said “proceed with next candidate slice” →
  `modSummaryStats`, the lowest-coverage residual module at 94.34%):**
  add a headless
  [`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)
  suite covering the scattered residual lines the six existing
  modSummaryStats suites never reached. **Test-only (no production code
  changed); PRE-RED→RED gate via `AskUserQuestion`; 0 stakeholder
  corrections.**
- **Gap pinpointed by exact uncovered-line dump
  ([`covr::zero_coverage`](http://covr.r-lib.org/reference/zero_coverage.md),
  `NOT_CRAN=true`):** 36 uncovered lines in three groups — (1)
  `asDataFrame()`’s `data.table` branch (`R/modSummaryStats.R`
  L350); (2) the two boxplot NULL guards (`meanKinshipBoxPlotGG` L510,
  `guBoxPlotGG` L570); (3) eleven download-handler content/filename
  bodies (L748–847). Only `downloadKinship` was driven before (parity
  suite); the other download handlers were never invoked via
  `output$downloadX`.
- **New `tests/testthat/test_modSummaryStats_coverage.R`** (8
  `testServer` tests / 34 expectations): a `data.table` pedigree
  exercising `getKinshipMatrix`; each boxplot reactive returning NULL
  for its missing column; the founder / first-order / relationship CSV
  exports (asserting real content); and the six histogram / box-plot PNG
  exports (asserting the PNG file signature).
- **Result:** `R/modSummaryStats.R` 94.34% → **100%** (zero uncovered
  lines); overall coverage 98.91% → **99.41%** (`NOT_CRAN=true`).
- **Verified:** new file 8 tests / 34 expectations green, 0 warnings;
  `covr` confirms 100% + overall 99.41%; full suite (`NOT_CRAN=true`,
  package loaded) 0 failed / 0 error / 0 true offenders (7 baseline
  warnings, none from this file); `lintr::lint()` on the new file = 0;
  `spell_check_package` clean (no `R/`/`man/` change);
  `R CMD check --as-cran` Status: OK — 0 errors / 0 warnings / 0 notes.
  Phase-3E N/A (test-only, no runtime surface).

### 2026-07-06 — \#111 code-coverage campaign, slice 5 — `modPyramid` backfilled 89.72% → 100% via a `downloadPlot` `testServer` suite (Session 289)

- **Deliverable (owner picked \#111 and this slice — `modPyramid`, the
  lowest-coverage residual module at 89.72%):** add a headless
  [`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)
  suite driving the `downloadPlot` handler that the existing suite never
  invokes. **Test-only (no production code changed); PRE-RED→RED gate
  via `AskUserQuestion`; 0 stakeholder corrections.**
- **Gap pinpointed by exact uncovered-line dump
  ([`covr::zero_coverage`](http://covr.r-lib.org/reference/zero_coverage.md),
  `NOT_CRAN=true`):** the only uncovered lines were the `downloadPlot`
  content function body (`R/modPyramid.R` L140, L142–151) — the
  PNG-writing download path. The plot/stats/UI renderers and the
  `observe` block were already covered by the existing suite’s
  `testServer` flush cycles; only the download handler, which runs
  solely when invoked, was untested.
- **New `tests/testthat/test_modPyramid_coverage.R` (2 `testServer`
  tests / 6 expectations):** drive `output$downloadPlot` in both
  plot-height branches — (A) explicit `plotHeight = 900L` (non-null
  branch of L140) and (B) `plotHeight` unset (`else 600L` branch) — each
  asserting the written file exists, is non-empty, and carries the PNG
  file signature. Fixture: a minimal `id`/`sex`/`age` data.frame
  ([`getPyramidPlot()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPyramidPlot.md)
  requires `sex` and `age`), validated warning-free with a throwaway
  `load_all`/`testServer` probe before the file was written.
- **Result:** `R/modPyramid.R` **89.72% → 100%** (zero uncovered lines);
  **overall coverage 98.76% → 98.91%** (`NOT_CRAN=true`).
- **Verified (firsthand):** new file green (0 warnings); full suite
  (`NOT_CRAN=true`) **1466 tests, 0 failed / 0 error, 0 true offenders**
  (7 baseline warnings unchanged); `lintr::lint` on the new file = 0;
  `spell_check_package` clean; **`R CMD check --as-cran` (repo root,
  WITH vignettes, via `devtools::check`) Status: OK — 0 errors / 0
  warnings / 0 notes**. Phase-3E N/A (test-only; no runtime surface).
- **Campaign status:** \#111 stays OPEN. Slices done: S1 helper tier
  (S285), S2 `modORIPReporting` (S286), S3 `appServer` (S287), S4
  `modInput` (S288), **S5 `modPyramid` (this session)**. Remaining
  residual modules for future slices: `modSummaryStats` (94.34%),
  `modPotentialParents` (94.67%), `modGeneticValue` (96.26%) + small
  single-file residuals.

### 2026-07-06 — \#111 code-coverage campaign, slice 4 — `modInput` backfilled 87.89% → 100% via a residual-branch `testServer` suite (Session 288)

- **Deliverable (owner picked \#111; owner chose this session’s slice
  via `AskUserQuestion` over the residual Shiny modules {`modInput`
  87.89% / `modPyramid` / `modSummaryStats` / `modPotentialParents`}:
  `modInput` — the lowest-coverage residual):** add a headless
  [`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)
  suite driving the error/guard handlers, output renderers, and download
  handlers that the three existing `modInput` suites never reach.
  **Test-only (no production code changed); PRE-RED→RED gate via
  `AskUserQuestion`; 0 stakeholder corrections.**
- **Gap pinpointed by exact uncovered-line dump
  ([`covr::zero_coverage`](http://covr.r-lib.org/reference/zero_coverage.md),
  `NOT_CRAN=true`):** the 62 uncovered lines were the `readDataFile`
  NULL/Excel/read-error paths, the getData “no file” / unreadable-file /
  blank-minParentAge branches, the raw-QC error and warning handlers
  (`qcStudbook` / `runQcStudbook`), and the `qcSummaryUI` / `qcErrors`
  renderers + three `downloadHandler`s — all reachable only via inputs
  the existing suites do not supply.
- **New `tests/testthat/test_modInput_coverage.R` (9 `testServer` tests
  / 22 expectations).** `R/modInput.R` **87.89% → 100%** (zero uncovered
  lines); **overall coverage 97.91% → 98.76%** (`NOT_CRAN=true`).
- **Two mechanisms were load-bearing:** (i) the observer’s QC-error
  handler needed `runQcStudbook` itself mocked to
  [`stop()`](https://rdrr.io/r/base/stop.html) (mocking `qcStudbook`
  alone is absorbed by `runQcStudbook`’s own internal `tryCatch`); (ii)
  the `qcErrors` debug-string branches (`modInput.R:595/597`) live
  inside a lazy
  [`futile.logger::flog.debug()`](https://rdrr.io/pkg/futile.logger/man/flog.logger.html)
  message, so covering them required raising the logger to `DEBUG` (as
  the app’s “Debug on” checkbox does) before rendering, with the
  appender routed to a temp file and restored via
  [`withr::defer`](https://withr.r-lib.org/reference/defer.html).
- **Verified:** new file green (0 warnings); full suite
  (`NOT_CRAN=true`) 0 failed / 0 error / 0 true offenders; `lintr::lint`
  on the new file = 0; `spell_check_package` clean;
  **`R CMD check --as-cran` (repo root, WITH vignettes) 0 errors / 0
  warnings / 0 notes (Status: OK)**. Phase-3E N/A (test-only; no runtime
  surface).

### 2026-07-06 — \#111 code-coverage campaign, slice 3 — `appServer` backfilled 0% → 100% via a full-app `testServer` suite (Session 287)

- **Deliverable (owner picked \#111; owner chose this session’s slice
  via `AskUserQuestion` over {`appServer` 0% / residual-modules bundle /
  `modInput` only}: the `appServer` server body — the biggest genuine
  gap at 0% local):** add a headless
  `shiny::testServer(appServer, {...})` suite exercising the entire main
  application server. **Test-only (no production code changed);
  PRE-RED→RED gate via `AskUserQuestion`; 0 stakeholder corrections.**
- **Gap characterized firsthand (Learning 265 shape, at the app
  level):** the existing `test_appServer_dynamicTabs.R` covers only the
  tab helper functions
  (`shouldShowChangedColsTab`/`getErrorTab`/`getChangedColsTab`) plus a
  `deparse(appServer)` structural grep and
  [`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
  HTML greps — nothing ever drives `appServer` through `testServer`, so
  the whole server body (logger/config init, the six navigation
  `observeEvent`s, every child-module mount, and the wiring observers
  that manage the dynamic Error List / Changed Columns tabs and
  propagate child outputs into shared state) ran only under the opt-in
  browser e2e that skips without shinytest2 + chromote. That is why the
  file read 0% local.
- **New `tests/testthat/test_appServer_server.R` (6 `testServer`
  tests):** (1) a bare boot with all real modules +
  `session$setInputs(goto_*=1)` for the six nav handlers; (2)
  child-output → `shared` wiring
  (studbook/pedigree/genetic-values/breeding-groups) via
  `with_mocked_bindings` stubs of the four read-from child servers; (3)
  QC pass/error/warning notifications via a `showNotification`
  recorder; (4) Error List tab insert/remove; (5) Changed Columns tab in
  both target positions (after Error List and after Input) + remove; (6)
  ORIP module mount gating (not mounted by default; mounted when
  `shouldShowOripTab` is TRUE).
- **Coverage:** `R/appServer.R` **0% → 100%** (zero uncovered lines);
  **overall 95.03% → 97.91%** (`NOT_CRAN=true`) — a single 354-line file
  at 0% was dragging overall down ~3 points.
- **Verify (firsthand):** new suite 6 tests / 20 expectations green, 0
  warnings; full suite (`NOT_CRAN=true`) **1455 tests, 0 failed / 0
  error, 0 true offenders**; `lintr::lint()` on the new file = 0;
  `spell_check_package` clean; **`R CMD check --as-cran` (repo root,
  WITH vignettes, via `devtools::check`) Status: OK — 0/0/0**.
  **Phase-3E N/A** — test-only, no `R/` source or runtime change (no
  smoke-test target; FM \#24 has no target).
- **Files:** new `tests/testthat/test_appServer_server.R`;
  `CHANGELOG.md`, `PROJECT_LEARNINGS.md` (Learning 266),
  `SESSION_NOTES.md`. Issue **\#111 stays OPEN** (multi-session
  campaign; remaining slices are the residual modules `modInput` 87.9% /
  `modPyramid` 89.7% / `modSummaryStats` 94.3% / `modPotentialParents`
  94.7% / `modGeneticValue` 96.3%).

### 2026-07-06 — \#111 code-coverage campaign, slice 2 — `modORIPReportingServer` backfilled to 100% via a headless `testServer` suite (Session 286)

- **Deliverable (owner picked \#111; owner chose this session’s slice
  via `AskUserQuestion` over {modORIPReporting / appServer / small
  residuals}: the `modORIPReporting` server body — the biggest genuine
  gap at 31.7%):** add a headless
  [`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)
  suite exercising the entire `modORIPReportingServer` body. **Test-only
  (no production code changed); PRE-RED→RED gate via `AskUserQuestion`;
  0 stakeholder corrections.**
- **Gap characterized firsthand (verified S285’s claim before acting):**
  the existing tests never drove the server through `testServer` —
  `test_modORIPReporting.R` covers only UI tab-gating (`#47`/`#49`) plus
  a `deparse(appServer)` structural grep, and `test_modSiteConfig.R`
  only checks the module functions exist with the right formals. The
  whole server body — the three output renderers (`siteInfo`,
  `colonySummary`, `geneticDiversity`), both `downloadHandler`s, and the
  returned `colonySummary` reactive — ran only under the opt-in browser
  e2e (`test-e2e-orip-module.R`), which skips without shinytest2 +
  chromote. That is why the file read 31.7% while looking “tested”.
- **New file `tests/testthat/test_modORIPReporting_server.R` — 12
  `testServer` tests:** siteInfo (populated config table / `getSiteInfo`
  NULL-fallback / `tryCatch`→“not available” on error); colonySummary
  (populated counts / empty “No data”); geneticDiversity (populated
  metrics / empty “Run genetic value analysis” prompt);
  `downloadORIPReport` (full site+colony+diversity CSV / NULL-ped+gv,
  which also hits the `getSiteInfo` else-branch); `downloadDemographics`
  (pedigree CSV / placeholder); returned `colonySummary()` reactive.
  renderUI/renderTable read via
  `any(grepl(..., as.character(output$x)))` (note `as.character` of a
  rendered UI yields a length-2 vector — html + `"list()"` deps),
  downloadHandlers via `path <- output$downloadX; read.csv(path)`.
  Fixtures validated with a throwaway `load_all`/`testServer` probe
  before the file was written.
- **Result:** `R/modORIPReporting.R` **31.7% → 100%** (zero uncovered
  lines); overall coverage **92.96% → 95.03%** (`NOT_CRAN=true`).
- **Verify (firsthand):** new file **12/12** green; `covr` re-measure
  confirms `modORIPReporting.R` at 100% under the full suite; **full
  suite (`NOT_CRAN=true`) 1449 tests, 0 failed / 0 error, 0 true
  offenders**; **lint** new file 0 (`.lintr` excludes `tests/`, and no
  `R/` source changed → non-regressing); `spell_check_package`
  **clean**; **`R CMD check --as-cran` (repo root, WITH vignettes)
  Status: OK — 0 errors / 0 warnings / 0 notes** (cleaner than the
  documented 0/0/2 baseline; the CRAN-incoming “archived/New
  submission” + HTML-Tidy NOTEs do not fire under `devtools::check`).
  **Phase-3E N/A:** test-only, no `R/` source changed, no runtime
  behavior — no runtime surface to smoke-test (not a skipped check).
- **Campaign status:** \#111 stays OPEN. Slices done: S1 helper tier
  (S285), **S2 `modORIPReporting` server (this session)**. Remaining
  genuine gaps for future slices: `appServer` (0% local — needs a
  full-app `testServer` harness) and small residuals (`modInput` 87.3%,
  `modPyramid` 89.7%, `modSummaryStats` 94.3%, `modPotentialParents`
  94.7%, `modGeneticValue` 96.3%).

### 2026-07-06 — \#111 code-coverage campaign, slice 1 — deterministic helper tier backfilled to 100% + dead-code removal (Session 285)

- **Deliverable (owner picked \#111, then clarified scope = increase
  coverage across *all* R code lacking quality coverage, the three named
  examples being illustrative; owner then chose this session’s slice via
  `AskUserQuestion`: the “deterministic helper tier”):** add
  test-backfill for the genuinely-untested helper functions and remove
  one dead file. **Test-only (no production logic changed) + one
  dead-code deletion; PRE-RED→RED gate via `AskUserQuestion`; 0
  stakeholder corrections.**
- **Measurement correction (load-bearing):** an initial
  [`covr::package_coverage()`](http://covr.r-lib.org/reference/package_coverage.md)
  read 83.54%, but that *undercounts* — 39 test files carry
  [`testthat::skip_on_cran()`](https://testthat.r-lib.org/reference/skip.html)
  (the module `testServer` suites) and covr does not set `NOT_CRAN`, so
  those tests were skipped. Re-measured with `NOT_CRAN=true`: **true
  baseline 91.23%**. This corrected the target list: `set_seed.R` and
  `applyKinshipOverridesToMatrix.R` (flagged low by the artifact read)
  are actually already 100% under `NOT_CRAN=true` and were dropped from
  scope, and the “low” Shiny modules (`modBreedingGroups` 98.6%,
  `modGeneticValue` 96.3%, `modInput` 87.3%) are mostly the same
  artifact, not genuine gaps.
- **16 helper files backfilled to 100%** (each targeting its exact
  uncovered lines — mostly error/guard/format/fallback branches no prior
  fixture reached): `logModuleEvent`, `safeExecute`, `savePlotToFile`,
  `summarizeKinshipValues`, `makeGeneticSummaryTable`,
  `shouldShowChangedColsTab`, `fixColumnNames`, `getConfigApiKey`,
  `hasNetrc`, `readKinshipOverrides`, `getGenoDefinedParentGenotypes`,
  `saveDataframesAsFiles`, `makeExamplePedigreeFile`, `gvaConvergence`,
  `runQcStudbook`, `getLkDirectAncestors`. Six new `test_*.R` files,
  nine appended. Mocking used where a branch needs it:
  [`testthat::local_mocked_bindings`](https://testthat.r-lib.org/reference/local_mocked_bindings.html)
  (mock
  `qcStudbook`/`create_wkbk`/[`shiny::showNotification`](https://rdrr.io/pkg/shiny/man/showNotification.html)),
  [`mockery::stub`](https://rdrr.io/pkg/mockery/man/stub.html) (mock
  `getDemographics` for the LabKey walk), `withr` for
  option/env/tempfile isolation, and a null plot device.
- **Dead-code removal:** deleted `R/agePyramidPlot.R` — an unexported
  (`@noRd`), **zero-caller** duplicate of the live
  [`getPyramidPlot()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPyramidPlot.md)
  (verified no references in `R/`, `tests/`, `NAMESPACE`, or `man/`;
  committed since `fb9a92ab`); removed its two stale `inst/_pkgdown.yml`
  reference-index entries (it has no man page, so pkgdown referenced a
  non-existent topic). No `NAMESPACE` change (it was internal).
- **Bug found, filed, not fixed (scope discipline):** while writing the
  `fixColumnNames` test, found that its “clean up possible overreach”
  block (lines 30–36) is **ineffective** — it restores
  `first_name`/`second_name` into the local `cols`, but line 39
  (`cols <- newCols`) overwrites it and the function returns `newCols`,
  so the restoration never reaches `newColNames` (both `"First Name"`
  and `"first_name"` inputs collapse to `"firstname"`). Filed as
  **\#117** (`bug`); the coverage test **characterizes the current
  (defective) behavior** (clearly commented, pointing at \#117) rather
  than fixing it in a coverage slice.
- **Result:** overall coverage **91.23% → 92.96%** (`NOT_CRAN=true`);
  all 16 target files at 100%.
- **Verify (firsthand):** each new/changed test file run green
  individually; **full suite (`NOT_CRAN=true`) 1437 tests, 0 failed / 0
  error, 0 true offenders** (the `test-app-*`/`test-e2e-*` baseline
  excluded); `covr` re-measure confirms every target file at 100%;
  **lint non-regressing** (`.lintr` excludes `tests/`; no `R/` source
  was added or modified — only a deletion; new files lint 0);
  `spell_check_package` **clean**; **`R CMD check --as-cran` (repo root)
  GREEN — 0 errors / 0 warnings / 2 benign NOTEs** (archived “New
  submission” + HTML-Tidy) with `testthat.R OK`. **Phase-3E N/A:** no
  runtime behavior changed — the deletion removes a zero-caller function
  (verified) and the rest is test-only, so there is no runtime surface
  to smoke-test (not a skipped check).
- **Campaign status:** \#111 stays OPEN. This is slice 1 (helper tier).
  Remaining genuine gaps for future slices: `modORIPReporting` (31.7%,
  genuinely uncovered — no `testServer` tests) and `appServer` (0% local
  — needs a full-app `testServer` harness).

### 2026-07-06 — \#112 disposition — closed as complete (S1–S4 dashboard shipped) + opened \#116 for the deferred S5 Flags column (Session 284)

- **Deliverable (issue hygiene; owner-directed via `AskUserQuestion`:
  “Close \#112, open S5 issue”):** dispose of issue \#112 now that all
  four implementation slices (S1–S4) have shipped and the genetic
  diversity dashboard is live in the app. **No package code changed; no
  TDD phase; Phase-3E N/A (no runtime surface touched).**
- **Closed \#112** (“finish development of the genetic diversity heatmap
  or dashboard”) as *completed*, with a summary comment listing the four
  shipped slices: S1
  [`makeGeneticDiversityHeatmap()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGeneticDiversityHeatmap.md)
  (`5667f9c8`), S2 `getKinshipWithMaleStatus()` (`2b11f112`), S3
  [`getGeneticDiversityStats()`](https://github.com/rmsharp/nprcgenekeepr/reference/getGeneticDiversityStats.md)
  4-column assembler (`cb7eb1a6`), S4 `modGeneticDiversity` module +
  “Genetic Diversity” tab (`7d410468`).
- **Opened \#116** (`enhancement`) to track the one deferred piece — the
  5th **Flags (genotype/phenotype)** column (plan Slice S5). It is
  blocked because no genotype/phenotype flagged-animal data source
  exists in the package (plan decision D5 / §6 Q4); the new issue scopes
  the work for when a data source is identified.
- Updated `ROADMAP.md` “What’s Built” to record the shipped genetic
  diversity dashboard feature.
- **Process fact confirmed:** on this repo `gh issue create` /
  `gh issue comment` / `gh issue close` all work; only `gh issue view`
  and `gh pr edit` hit the deprecated-projectCards exit-1 bug (use
  `gh api` for those).

### 2026-07-06 — \#112 Slice S4 — Shiny module `modGeneticDiversity` + new tab + `shared$breedingGroups` wiring (strict TDD) (Session 283)

- **Deliverable (3 pre-RED scope decisions + 3 TDD phase-gates, all via
  `AskUserQuestion`; preceded by a read-only ultracode evidence
  Workflow):** implement Slice S4 (the last implementation slice) of the
  issue \#112 plan — a new Shiny module `R/modGeneticDiversity.R`
  (`modGeneticDiversityUI`/`modGeneticDiversityServer`, both
  `@export`ed) that assembles the live breeding-group, genetic-value,
  and kinship reactives into the S3
  [`getGeneticDiversityStats()`](https://github.com/rmsharp/nprcgenekeepr/reference/getGeneticDiversityStats.md)
  statistics and renders the S1
  [`makeGeneticDiversityHeatmap()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGeneticDiversityHeatmap.md);
  a new **“Genetic Diversity”** tab in `appUI.R` + `appServer.R`; and
  capture of `modBreedingGroupsServer`’s previously-discarded return
  into `shared$breedingGroups`. **NEW MODULE + RUNTIME/REGISTRATION
  CHANGE → STRICT TDD (RED→GREEN→REFACTOR, each gated) + MANDATORY
  Phase-3E; 0 stakeholder corrections / 0 owner overrides.**
- **Pre-RED evidence (read-only Workflow, TDD-safe — 6 investigate +
  adversarial-verify agents, 0 empty investigators; every load-bearing
  wiring claim CONFIRMED):** established firsthand (i) every existing
  module exports BOTH its UI and Server, so S4 adds exactly **2
  exports**; (ii) the exact module/tab/test idioms
  (`div(id=ns("moduleContainer"), data-ready/data-module)`,
  `shiny::testServer(ServerFn, args=list(...reactive...), {...})` with
  `session$getReturned()`, plots asserted via the returned reactive + a
  `GeomTile` layer check — never by reading a `renderPlot`
  output); (iii) the reactive contracts — `modBreedingGroupsServer`
  returns `groups` as a **list of character ID vectors** (matching the
  assembler’s `groups`), `modGeneticValueServer` exposes the GV report
  frame (id+value) as `geneticValues` and the **full** kinship matrix as
  `kinshipMatrix` (NOT the usually-NULL `groupKinship`, and NOT stored
  in `shared` — passed as the reactive directly); (iv) `appServer.R:315`
  discards the breeding-group return (a bare call), so S4 must capture
  it; (v) adding a tab breaks no existing test (the “all tabs” e2e test
  is presence-only `grepl`; the switch-list tests are subset walks;
  `navigate_to_tab` accepts any label).
- **Owner scope decisions (pre-RED):** (1) tab title **“Genetic
  Diversity”**; (2) a **single housing selector for all groups** (a
  scalar `selectInput` recycled by the assembler; per-group
  deferred); (3) **no Home-page card in S4** (the Home row is a full 3×4
  Bootstrap grid; a card is optional per D3 and several existing tabs
  have none — deferred as a tiny follow-up). Also folded in (author’s
  discretion, for test determinism): the server takes a plain
  `currentDate = Sys.Date()` arg forwarded to the assembler, so tests
  pin the date (Production’s birth window is relative to “now”) and
  reuse the S3 assembler’s proven fixture.
- **RED:** new `tests/testthat/test_modGeneticDiversity.R` — 15 tests /
  (34 expectations at GREEN) reusing the S3 deterministic fixture
  (`currentDate = 2020-07-01`): UI returns a `shiny.tag`, shows the
  heading, exposes the namespaced `heatmap`/`housing`/`guidance` ids,
  marks the container `data-module="geneticDiversity"`/`data-ready`, and
  offers both housing values; the server returns reactive
  `stats`+`heatmap`; happy path yields a `colorIndex` data frame and a
  `ggplot` with a `GeomTile` layer; unset housing defaults to
  `shelter_pens` (no error); the housing input threads through
  (shelter→red vs corral→yellow on a boundary group); and four
  graceful-degradation paths (no groups / empty group list / analysis
  not run / kinship not ready → NULL stats + guidance shown, and
  guidance hidden once data is present). All 15 failed against the
  missing module (correct RED). *(A latent defect in the RED server
  blocks — reading `result` before binding it via
  `session$getReturned()` — was masked by the missing-function error and
  surfaced at GREEN; corrected with no assertion change.)*
- **GREEN:** `R/modGeneticDiversity.R` — UI (housing `selectInput`,
  `uiOutput` guidance, `plotOutput` heat map inside the module
  container) + server that reads the four reactives defensively (an
  upstream not-ready reactive is treated as NULL so the module degrades
  to guidance rather than erroring), calls the assembler with the
  housing default, renders the heat map, and returns
  `list(stats, heatmap)`. App wiring: `shared$breedingGroups = NULL`
  added; `appServer.R:315` becomes
  `bgResults <- modBreedingGroupsServer(...)` + an `observe` storing
  `bgResults$groups()` into `shared$breedingGroups`;
  `modGeneticDiversityServer("geneticDiversity", groups=reactive(shared$breedingGroups), pedigree=reactive(shared$currentPedigree), geneticValues=reactive(shared$geneticValues), kinshipMatrix=gvResults$kinshipMatrix)`
  mounted; a
  `tabPanel("Genetic Diversity", icon("th"), modGeneticDiversityUI("geneticDiversity"))`
  registered after Breeding Groups. `document()` → NAMESPACE **+2
  exports** + 2 new `man/*.Rd` (the 18 sibling `mod*.Rd` gain only the
  `@family` cross-reference). All 15 tests pass (34 expectations).
- **REFACTOR (no behavior change):** fixed 2 enforced lints on the new
  file (housing labels `"Shelter / pens"`→`"Shelter pens"` clears
  `nonportable_path_linter`; unquote `Corral` clears
  `keyword_quote_linter` — the `shelter_pens`/`corral` values are
  unchanged) + reworded “kinship reactives”→“kinship reactive inputs” in
  the server roxygen to clear `spell_check` (no WORDLIST churn), then
  re-documented.
- **Verify (firsthand):** single-file 15/15 (34 expectations);
  `lintr::lint()` **0** on all 3 changed `R/` files;
  `spell_check_package` **clean** (no WORDLIST churn); NAMESPACE diff =
  **+2 exports** only; full-suite clean read **1170 tests, 0 fail / 0
  error, no true offenders**; **`R CMD check --as-cran` (repo root)
  GREEN — 0 err / 0 warn / 2 benign NOTEs** (archived “New submission” +
  HTML-Tidy) with `testthat.R [85s] OK`. **Phase-3E (MANDATORY —
  runtime/registration change, done not skipped):**
  [`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
  renders the tab (title, module container, heatmap, housing all
  present); `shinyApp(appUI(), appServer)` constructs; the **entire
  `appServer` body executed at session init via
  [`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)**
  — every module mounted (incl. `modGeneticDiversityServer`, the
  `bgResults` capture, and the `shared$breedingGroups` observe) with no
  error, the `shared$breedingGroups` field present, and the
  `geneticDiversity-guidance` output rendering the “Form breeding
  groups…” message at startup (graceful degradation live). The
  shinytest2 e2e suite **skips** in this sandbox (no chromote), so
  `testServer` on the full app is the headless substitute.
  `PROJECT_LEARNINGS.md` Learning 262.
- Issue \#112 stays OPEN (S1 + S2 + S3 + S4 done — the dashboard is now
  live in the app; only the deferred Flags column S5, blocked on §6 Q4
  with no genotype/phenotype data source, remains).

### 2026-07-05 — \#112 Slice S3 — genetic diversity per-group assembler `getGeneticDiversityStats()` (strict TDD); D7 `getProductionStatus` doc fix (Session 282)

- **Deliverable (3 pre-RED owner decisions + 3 TDD phase-gates, all via
  `AskUserQuestion`; preceded by a read-only ultracode evidence
  Workflow):** implement Slice S3 of the issue \#112 plan — a new
  **exported**
  `getGeneticDiversityStats(groups, ped, geneticValues, kmat, housing = "shelter_pens", currentDate = Sys.Date())`
  that, for each breeding group, calls all 4 providers
  (`getProportionLow`, `getIndianOriginStatus`, `getProductionStatus`,
  `getKinshipWithMaleStatus`) and returns the group × 4-metric
  `colorIndex` data frame (`group`, `Value`, `Origin`, `Production`,
  `Inbreeding`) that
  [`makeGeneticDiversityHeatmap()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGeneticDiversityHeatmap.md)
  (S1) renders. **NEW EXPORT → STRICT TDD (RED→GREEN→REFACTOR, each
  gated); 0 stakeholder corrections / 0 owner overrides.**
- **Pre-RED evidence (read-only Workflow, TDD-safe — 8 agents: 4
  investigate + 4 adversarial verify, 0 errors):** resolved the 3
  blocking §6 questions firsthand and corrected 3 plan assumptions. (Q1)
  The shipped `getProductionStatus` implements the **20190810**
  thresholds on a rolling 2-year birth window; owner kept 20190810 → D7
  is doc-only. (Q2) **No housing data source exists anywhere** (data
  model, group result, or config) → `housing` is caller-supplied. (Q3)
  The “Low” label producer **was located** — `rankSubjects.R:37/39/41`
  emits `"Low Value"`/`"High Value"`/`"Undetermined"`, surfaced via
  `reportGV(ped)$report`; not an owner gap. Corrections applied: Origin
  must be fed `ped$ancestry` (not `ped$origin` — the param name
  misleads; its yellow band is unreachable from live data because
  `convertAncestry` never emits `BORDERLINE_HYBRID`); the exposed
  `groupKinship` is NULL unless a UI box is checked → the assembler
  takes the full `kmat`; only `getKinshipWithMaleStatus` can return an
  NA colorIndex (`getProductionStatus` maps NA→green).
- **Owner ratifications (pre-RED):** (1) keep the 20190810 Production
  thresholds (D7 doc-only); (2) an undefined metric (a group with no
  breeding-age females → Inbreeding NA) is scored **red (1)**, not
  NA/green, so the heat map still renders and missing data is
  surfaced; (3) the function is **exported + pure** (takes ready-made
  group ID lists, pedigree, GV report frame, and full kinship matrix),
  housing caller-supplied (scalar recycled or one per group), age
  derived from `birth` + `currentDate`.
- **RED:** new `tests/testthat/test_getGeneticDiversityStats.R` — 16
  tests / 29 expectations on deterministic hand-built fixtures (a
  21-animal `ped`; a `gv` id/value report frame; a named `kmat`;
  `currentDate = 2020-07-01`): happy path (an all-green 3/3/3/3 and an
  all-red 1/1/1/1 group; frame shape, column names, nrow, integer
  columns); default `"Group N"` labels + honoring list names;
  `"Undetermined"` excluded from the Value denominator (→ yellow) and an
  all-`"Undetermined"` group → red; undefined Inbreeding → red (not NA);
  housing scalar corral-vs-shelter (production 0.5 → yellow vs red) + a
  per-group housing vector; Origin column omitted when the pedigree
  lacks `ancestry`; 5 error guards (empty groups, ped missing column,
  member absent, invalid housing length, `geneticValues` missing
  `value`); and end-to-end
  `getGeneticDiversityStats(...) |> makeGeneticDiversityHeatmap()`
  returns a `ggplot`. All 16 failed against the missing function
  (correct RED).
- **GREEN:** `R/getGeneticDiversityStats.R` — validates inputs, derives
  age from `birth`+`currentDate` (not the `today()`-hardwired
  `getCurrentAge`), synthesizes labels, and per group maps each
  provider’s `colorIndex` (undefined → red) into the output frame;
  NAMESPACE gained exactly one export + new
  `man/getGeneticDiversityStats.Rd`. All 16 tests pass (29
  expectations).
- **REFACTOR (no behavior change):** fixed 2 enforced lints on the new
  file (`rep(..., length.out=)` → `rep_len`; `any(!nzchar())` →
  `!all(nzchar())`) + American “color” spelling in the roxygen; applied
  the **D7** doc-only fix to `R/getProductionStatus.R` (rewrote the
  fixed-2019 `@details` prose to the implemented rolling
  `currentYear-2..currentYear-1` window; `@param minParentAge` “2 years”
  → “3 years”; aligned the `@return` “at least 30 days” phrasing) —
  `@noRd`, no man page, no behavior change.
- **Verify (firsthand):** single-file 16/16 (29 expectations);
  `lintr::lint()` **0** on both changed `R/` files;
  `spell_check_package` **clean** (no WORDLIST churn); NAMESPACE diff =
  **+1 export** only; full-suite clean read **0 fail / 0 error, no true
  offenders**; **`R CMD check --as-cran` (repo root) GREEN — 0 err / 0
  warn / 2 benign NOTEs** (archived-maintainer + HTML-Tidy) with
  `code/documentation mismatches … OK`, examples OK,
  `testthat.R [84s] OK`, vignettes rebuilt. **Phase-3E (stated, not
  skipped):** the assembler is an exported *pure* function with no
  direct app/runtime surface until its S4 caller — its runtime exercise
  is the 16 tests running against the built+installed package inside
  `--as-cran`’s `testthat.R`, plus the end-to-end test that calls
  [`makeGeneticDiversityHeatmap()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGeneticDiversityHeatmap.md)
  on real assembler output; a full app launch is an S4 concern.
  `PROJECT_LEARNINGS.md` Learning 261.
- Issue \#112 stays OPEN (S1 + S2 + S3 of 4 slices done; S4 Shiny
  module + app wiring, + deferred Flags remain).

### 2026-07-05 — \#112 Slice S2 — inbreeding data provider `getKinshipWithMaleStatus()` (strict TDD) (Session 281)

- **Deliverable (3 pre-RED `[RATIFY]` points + 3 TDD phase-gates, all
  via `AskUserQuestion`):** implement Slice S2 of the issue \#112 plan —
  a new **internal** (`@noRd`, unexported)
  `getKinshipWithMaleStatus(group, kmat, minFemaleAge = 3L, minMaleAge = 5L, threshold = 0.015625)`
  that reports, among the group’s breeding-age females (sex `"F"`, age ≥
  `minFemaleAge`), the fraction essentially unrelated (kinship ≤
  `threshold`) to at least one breeding-age male (sex `"M"`, age ≥
  `minMaleAge`), and maps it to a heat-map color: red (\< 0.6), yellow
  (\[0.6, 0.9\]), green (\> 0.9). Returns
  `list(fraction, color, colorIndex)` — a pure peer to the 3 existing
  orphaned providers. **NEW INTERNAL PROVIDER → STRICT TDD
  (RED→GREEN→REFACTOR, each gated); 0 stakeholder corrections / 0 owner
  overrides.**
- **Ratified (pre-RED, 3 owner gates):** (1) name/signature
  `getKinshipWithMaleStatus(group, kmat, ...)` — a **pure** provider
  that consumes a ready-made per-group kinship matrix (`kmat`, dimnames
  = ids; e.g. one element of `modBreedingGroups`’ `groupKinship`, or
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  output), leaving the in-app-vs-out-of-app source choice to the S3
  assembler; (2) **empty-denominator behavior** — a group with no
  breeding-age females returns `fraction`/`color`/`colorIndex` all `NA`
  (deliberately **not** green, avoiding `getProductionStatus`’s NA→green
  trap flagged in plan §8.2); (3) inclusive-yellow boundaries (endpoints
  0.6 and 0.9 are yellow, matching `getProportionLow`’s convention).
- **RED:** new `tests/testthat/test_getKinshipWithMaleStatus.R` — 12
  tests / 26 expectations using hand-built named kinship matrices +
  id/sex/age group frames for full determinism: green (fraction 1.0) +
  return names/types; red all-related (fraction 0); red because the only
  male is \< `minMaleAge` (male-age filter); yellow at exactly 0.6 (3
  of 5) and exactly 0.9 (9 of 10); the 0.015625 threshold edge (kinship
  == threshold counts; just-above does not); a female \< `minFemaleAge`
  excluded from the denominator; a `sex == "U"` member counted as
  neither female nor eligible male; the empty-denominator NA case; and
  two error guards (missing id/sex/age column; a group id absent from
  `kmat` dimnames). All 12 failed against the missing function (correct
  RED).
- **GREEN:** `R/getKinshipWithMaleStatus.R` — base-R only (no new
  import); validates columns + `kmat` coverage, selects the two eligible
  pools, short-circuits the empty denominator to NA, else computes the
  fraction via `vapply` over females
  (`any(kmat[f, males] <= threshold)`) and maps to the 1/2/3 color
  index. All 12 tests pass.
- **REFACTOR (no behavior change):** fixed the 2 enforced style lints on
  the new file (`paste(..., collapse=", ")` →
  [`toString()`](https://rdrr.io/r/base/toString.html); `0` → `0.0`) —
  confirmed both are `.lintr`-enabled and the sibling code is clean of
  them; roxygen `@param`/`@return`/`@details` header matching the
  sibling providers.
- **Verify (firsthand):** single-file 12/12; `lintr::lint()` **0** on
  the new file + `lint_package()` **0** on changed files;
  `spell_check_package` **clean** (no WORDLIST churn); **NAMESPACE diff
  EMPTY** (proven via `document()` — `@noRd`, no new `man/*.Rd`);
  full-suite clean read **0 fail / 0 error, no true offenders**;
  **`R CMD check --as-cran` (repo root) GREEN — 0 err / 0 warn / 2
  benign NOTEs** (archived-maintainer + HTML-Tidy) with
  `testthat.R [70s] OK`, examples OK, vignettes rebuilt. **Phase-3E
  (stated, not skipped):** a pure `@noRd` provider has no app/runtime
  surface until its first caller S3 — its runtime exercise is the 12
  tests running against the built + installed package inside
  `--as-cran`’s `testthat.R`. Direct-merged to `master` + pushed.
  `PROJECT_LEARNINGS.md` Learning 260.
- Issue \#112 stays OPEN (S1 + S2 of 4 slices done; S3 assembler
  \[blocked on §6 Q1–Q3\], S4 module + wiring, + deferred Flags remain).

### 2026-07-05 — \#112 Slice S1 — genetic diversity heatmap renderer `makeGeneticDiversityHeatmap()` (strict TDD); dead dashboard scaffolding deleted (Session 280)

- **Deliverable (S1 `[RATIFY]` points + 3 TDD phase-gates + a naming
  reconsideration + a delete-confirmation, all via `AskUserQuestion`):**
  implement Slice S1 of the issue \#112 plan — the tracer bullet: a new
  **exported** `makeGeneticDiversityHeatmap(stats)` that turns a group ×
  metric `colorIndex` data frame (column 1 = group label, remaining
  columns = color indices 1/2/3) into a
  [`ggplot2::geom_tile`](https://ggplot2.tidyverse.org/reference/geom_tile.html)
  red/yellow/green stoplight heat map (metric headers across the top at
  45°, group labels down the left, discrete `scale_fill_manual`
  1=red/2=yellow/3=green). **NEW EXPORT → STRICT TDD
  (RED→GREEN→REFACTOR, each gated); 0 stakeholder corrections / 0 owner
  overrides.**
- **Ratified (pre-RED):** name `makeGeneticDiversityHeatmap` — kept
  after the owner re-raised “is `Dashboard` more descriptive since only
  part is a heatmap?”; resolved that this function draws *only* the
  heatmap and returns one `ggplot`, while the composite report/dashboard
  is the future S4 module `modGeneticDiversity`, so the function name
  stays literal. D1
  [`ggplot2::geom_tile`](https://ggplot2.tidyverse.org/reference/geom_tile.html)
  (no new dependency); D2 delete the dead code; D6 color-only cells for
  S1 (the S1 input is a `colorIndex`-only matrix, so there are no raw
  values to overlay yet — deferred to S3).
- **RED:** new `tests/testthat/test_makeGeneticDiversityHeatmap.R` — 12
  tests / 21 expectations: happy path, the `GeomTile` layer, tile count,
  column-count-agnosticism (2×5 → 10 tiles), the discrete
  1/2/3→red/yellow/green mapping (per-color tile counts + single-value
  inputs), a discrete (not gradient) fill scale, metric/group axis
  ordering, a 1×1 edge, and 3 error paths (no metric column /
  `colorIndex` ∉ {1,2,3} incl. `NA` / non-data-frame). The ggplot2
  introspection API was validated against the installed **ggplot2
  4.0.3** (S7) *before* writing RED, so the assertions were provably
  satisfiable in GREEN.
- **GREEN:** `R/makeGeneticDiversityHeatmap.R` — validates input, builds
  a long data frame (group/metric/colorIndex factors, input order
  preserved), returns the `geom_tile` plot. NAMESPACE gained exactly one
  export (+ ggplot2 `importFrom`s matching the `modSummaryStats` house
  style).
- **REFACTOR (D2 housekeeping, no behavior change):** deleted the dead,
  fully-commented, build-ignored `R/makeGeneticDiversityDashboard.R` +
  `tests/testthat/test_makeGeneticDiversityDashboard.R`, and removed
  their now-stale references in **both** `.Rbuildignore` and `.lintr`
  (the `.lintr` one found only by a broad grep). **A broad grep surfaced
  a prior author “do not delete” decision (issue \#30, S53-56); both
  premises are now void — deletion causes zero NAMESPACE change (proven
  firsthand; the dead imports were already removed) and S1 IS the
  replacement — so the owner re-confirmed the deletion with that context
  (SAFEGUARDS: surface the contradiction before deleting).**
- **Verify (firsthand):** single-file test 21/21; `lintr::lint()` 0 on
  the new file (fixed 5 real `implicit_integer` lints — that linter *is*
  enforced by `.lintr`’s tag set) and `lintr::lint_package()` **0**;
  `spell_check_package` clean (roxygen reworded to American spelling —
  no WORDLIST churn); full-suite clean read **0 fail / 0 error, no true
  offenders**; **`R CMD check --as-cran` (repo root) GREEN — 0 err / 0
  warn / 2 benign NOTEs** (archived-maintainer + HTML-Tidy) with
  `code/documentation mismatches … OK`, examples ran,
  `testthat.R [73s] OK`, vignettes rebuilt. **Phase-3E runtime smoke
  DONE (plot deliverable):**
  [`makeGeneticDiversityHeatmap()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGeneticDiversityHeatmap.md)
  renders a real ~8.5 KB PNG end-to-end (it draws, not just builds — FM
  \#24). Direct-merged to `master` + pushed. `PROJECT_LEARNINGS.md`
  Learning 259.
- Issue \#112 stays OPEN (S1 of 4 slices done; S2 Inbreeding provider,
  S3 assembler \[blocked on §6 Q1–Q3\], S4 module + wiring, + deferred
  Flags remain).

### 2026-07-05 — \#112 Genetic Diversity Dashboard — design & implementation plan authored (planning session; no code) (Session 279)

- **Deliverable (owner scope-gate via one `AskUserQuestion`):** the
  owner picked issue \#112 (“finish development of the genetic diversity
  heatmap or dashboard”) and at the scope gate chose **“Design/plan doc
  first”** (over build-the-heatmap-renderer-now /
  build-the-data-assembler-now). Deliverable = a design document; **no
  code or tests written** (planning-workstream discipline —
  implementation happens in the separate per-slice sessions the plan
  defines; FM \#18/#19 avoided). **0 stakeholder corrections / 0 owner
  overrides.**
- **Investigation (ultracode, read-only, TDD-safe at pre-RED — two
  Workflows):** (1) a 4-agent scope investigation of the reference
  material + plumbing (meeting notes, GV pipeline, app wiring, dead
  code/deps — 2 agents returned placeholder junk, load-bearing facts
  recovered firsthand); (2) a 3-agent adversarial review of the drafted
  plan (accuracy / completeness / slice-structure lenses, 0 errors)
  surfacing **10 evidence-backed findings, ALL applied**.
- **What \#112 is (from `inst/extdata/meeting_notes.qmd`):** a
  red/yellow/green stoplight heat map, rows = breeding groups, 5 metric
  columns (Value/High-Low, Origin/Indian, Production/Fecundity,
  Inbreeding/Kinship-with-male, Flags/Genotype-Phenotype), each cell
  colored by per-metric thresholds (20190810).
- **Key evidence:** 3 of 5 columns already have working,
  individually-tested but **orphaned** `@noRd` providers
  (`getProportionLow`/`getIndianOriginStatus`/`getProductionStatus`) — a
  half-built feature, not greenfield; column 4 (Inbreeding) has no
  provider but is buildable from
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md) +
  `modBreedingGroups`’ existing `groupKinship`; column 5 (Flags) has no
  provider **and no data source** → deferred. `ggplot2` is a dependency,
  `gplots` is not → recommend `geom_tile` (no new dep) over reviving the
  dead build-ignored `heatmap.2` PNG renderer. `modBreedingGroups`
  already returns `groups`+`groupKinship` but `appServer.R:315` discards
  it (one-line capture). Two doc/code mismatches noted in
  `getProductionStatus`.
- **The plan**
  (`docs/planning/issue112-genetic-diversity-dashboard-plan.md`): spec +
  thresholds, evidence-based inventory (<file:line>), 7 design decisions
  (all `[RATIFY]`-marked), 6 open spec questions (owner input), and **4
  vertical implementation slices** (S1 ggplot2 heatmap renderer = tracer
  bullet; S2 Inbreeding provider; S3 per-group assembler; S4 Shiny
  module + wiring) + a deferred Flags column, each with concrete DONE
  criteria, verification commands, and a STOP boundary.
- **Verify:** plan proofread for internal consistency; all 10 review
  findings applied; no code/tests/NAMESPACE touched (planning-only;
  build-equivalent = doc consistency). Phase-3E N/A (no runtime
  surface). Direct-merge to `master` + pushed. Issue \#112 stays OPEN
  (plan authored, implementation pending).

### 2026-07-05 — \#109 follow-up — AlleleTable column-order docs reconciled to `geneDrop()`’s V-first output; the 5 remaining “code-fix candidates” investigated and declined with evidence (Session 278)

- **Deliverable (owner scope-gate via one `AskUserQuestion`):** the
  owner asked to take on the “remaining \#109-audit doc-fixed *code-fix*
  candidates” (the 5 findings S276/S277 listed where the audit offered a
  code-change alternative to S274’s doc fix: **A**
  `saveDataframesAsFiles`/`makeExamplePedigreeFile` `"xlsx"` alias,
  **B** `geneDrop` column reorder, **C**
  `getPedMaxAge`/`getPyramidAgeDist` living-filter, **D**
  `assignAlleles` `n = 5000` default, **E** `is_valid_date_str`
  `format`). A pre-RED **ultracode read-only investigation** (10 agents:
  5 investigate + 5 adversarial verify, 0 errors; no code/tests written)
  found **all 5 are `no-docfix-correct`** — S274’s doc fix was the right
  resolution in every case, matching the audit’s own §6 (“every
  remaining fix is a pure-doc REFACTOR-class edit”). Adversarially
  confirmed with concrete reproductions (B’s reorder breaks a positional
  test and diverges from the frozen V-first `.rda` data; C’s filter is
  self-defeating and duplicates `fillBins`’s existing `is.na(exit)`; D’s
  `5000` is the value the owner deliberately abandoned in S201/#2). **Do
  not re-litigate the 5 candidates — they were investigated and declined
  with evidence.**
- **What the investigation surfaced as genuinely real (the
  deliverable):** S274 corrected
  [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)’s
  `@return` to the actual V-first order (`V1..Vn, id, parent`) but left
  the CONSUMER docs describing the same allele table as
  `id, parent, V1..Vn` — an internal doc contradiction. Owner chose
  **“Fix AlleleTable doc mismatch.”** **REFACTOR-class, doc-only;
  NAMESPACE diff EMPTY; no signature/logic/behavior change; TDD
  RED/GREEN N/A; 0 stakeholder corrections / 0 owner overrides.**
- **The fix (4 `R/` roxygen blocks → 4 regenerated `man/*.Rd`):** an
  evidence-based grep of the whole allele-table doc surface (broader
  than the 2 files the investigation named) found four exported
  consumers describing the order id/parent-first — `calcGU.R`
  (@itemize), `calcA.R` (“The first 2 columns provide the animal ID…”),
  `calcFGSE.R`, `calcGUSE.R`. All reordered to
  [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)’s
  canonical `V1..Vn, id, parent`. Left unchanged, with reasons:
  `calcFG.R`/`calcFEFG.R`/`calcRetention.R` reference “AlleleTable”
  abstractly with no column order stated; `R/data.R` already describes
  the example objects V-first (id/parent as the last columns);
  `geneDrop.R` is the corrected source of truth.
- **Flagged for a future session (NOT fixed here):**
  `getGenoDefinedParentGenotypes.R` (`@noRd`, internal) has
  `@param`/`@return` that mis-describe the *intermediate list* object
  (`$alleles`/`$counter`) as “data.frame `id, parent, V1 ... Vn`” —
  wrong at a deeper level than column order, so half-fixing the order
  alone would still mislead; deserves its own doc-correctness pass.
- **Verify (firsthand):** `devtools::document()` touched only the 4
  intended `R/`+`man/` pairs; **NAMESPACE diff EMPTY**; `lintr` **0** on
  all 4 changed R files; `spell_check_package` **clean** (no WORDLIST
  churn); **`R CMD check --as-cran` (clean tree) GREEN — 0 errors / 0
  warnings / 2 NOTEs** (standing benign pair: archived-maintainer CRAN
  false positive + environmental HTML-Tidy) with
  `code/documentation mismatches … OK`, `Rd cross-references … OK` (the
  reworded `\link{calcFG}`/`\link{calcGU}` lines still resolve),
  `Rd line widths … OK`, examples \[21s\] / `testthat.R [68s] OK` /
  vignettes rebuilt.
- **Phase-3E (runtime smoke): N/A (stated, not skipped)** — doc-only
  REFACTOR; all four function bodies unchanged; empty NAMESPACE diff
  proven; no runtime/behavior surface. `PROJECT_LEARNINGS.md` Learning
  257.

### 2026-07-05 — makeSimPed \#31 — `makeSimPed()` now preserves known parents instead of overwriting them (Session 277)

- **Deliverable (owner scope-gate + 3 TDD phase-gates + landing-gate,
  all via `AskUserQuestion`; ultracode read-only investigation Workflow
  at pre-RED):** the issue \#109 audit’s finding \#31 flagged
  [`makeSimPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeSimPed.md)’s
  `@description` as a doc-vs-code mismatch; S274 (doc-only) had
  reconciled the DOC to the buggy code (“Existing known parents are
  overwritten”). This session determined the CODE was the defect and
  fixed it.
  [`makeSimPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeSimPed.md)’s
  loop assigned every listed id’s sire/dam unconditionally
  (`sample(vec, 1L)`, or `NA` for an empty vector), never checking
  whether the existing parent was already known — so an animal with one
  KNOWN and one unknown parent had its known parent silently overwritten
  (or erased to `NA`) in the simulated-kinship pipeline, biasing the
  estimate. The production builder
  [`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
  selects `is.na(sire) | is.na(dam)` (an OR → mixed known/unknown
  animals ARE listed) and emits full candidate pools, so the corruption
  bit end-to-end (reproduced: a known sire lost in 661/1000 sims). The
  intended “impute only UNKNOWN parents” contract is stated by the
  original doc, the `@examples` comment, `createSimKinships`’s
  `@return`, and `getPotentialParents`’s title. Owner scope-gate =
  **“Guard makeSimPed”** (over fix-`getPotentialParents` / doc-only).
  **BEHAVIOR change → STRICT TDD (RED→GREEN→REFACTOR); direct-merge
  landing; 0 stakeholder corrections / 0 owner overrides.**
- **The fix:** `R/makeSimPed.R`’s loop now imputes a parent ONLY when
  the existing value is `NA` (unknown); a known sire/dam is preserved
  unchanged; robust to an id absent from `ped`. `@description` rewritten
  (reversing S274’s now-false line); `man/makeSimPed.Rd` regenerated.
  NAMESPACE diff EMPTY (no signature/export change).
- **Tests:** 4 new preserve-known tests in `test_makeSimPed.R` (RED
  against the overwrite code). 7 downstream characterization goldens
  re-baselined across `test_createSimKinships.R`,
  `test_cumulateSimKinships.R`, `test_countKinshipValues.R`,
  `test_summarizeKinshipValues.R` — they shift because `smallPed`’s `A`
  (known sire `Q`) is now correctly preserved; the audit predicted 2,
  the full suite found all 7; each recomputed from the corrected code
  and verified (A’s sire == `Q`; raw kinship(A,J)==0 across sims).
- **Vignette:** `--as-cran` caught that `simulatedKValues.Rmd` joined
  two `sd>0`-filtered summary frames by ROW POSITION (a latent bug the
  behavior change exposed → `data.frame` “differing number of rows”);
  both comparison chunks fixed with
  [`merge()`](https://rdrr.io/r/base/merge.html) by `(id_1, id_2)`.
- **NEWS:** dev-version bug-fix bullet (edited `NEWS.Rmd`, re-rendered
  `NEWS.md`).
- **Ultracode investigation (pre-RED, read-only):** a 9-agent Workflow
  (5 investigate + 4 adversarial verify incl. firsthand R reproduction)
  confirmed the hazard, showed the primitive is defensible under the
  vignette’s singleton convention, and located the root cause at the
  `getPotentialParents → makeSimPed` boundary before any edit.
- **Verify:** full suite 0 fail / 0 error / 0 true offenders; `lintr` 0
  on the changed R file; `spell_check_package` clean; NAMESPACE diff
  empty; **`R CMD check --as-cran` (clean tree) GREEN — 0 errors / 0
  warnings / 2 benign NOTEs** (archived-maintainer + HTML-Tidy),
  `code/documentation mismatches … OK`, `testthat.R [67s] OK`, vignettes
  rebuilt. Phase-3E done (behavior change; installed-namespace
  testthat + example + direct smoke). `PROJECT_LEARNINGS.md` Learning
  256.

### 2026-07-05 — issue \#110 — make `runGeneKeepR()` the canonical Shiny entry point again; `runModularApp()` becomes the soft-deprecated alias (Session 276)

- **Deliverable (owner design-gate + 3 TDD phase-gates + landing-gate,
  all via `AskUserQuestion`):** issue \#110 questioned the 2.0.0
  decision to deprecate the informative name
  [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
  in favor of the low-information
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md).
  Owner chose **“Reverse, keep both names”** (over
  reverse-and-remove-`runModularApp` / keep-as-is):
  [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
  becomes the canonical, undeprecated function holding the Shiny app
  body;
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  becomes a `lifecycle::deprecate_soft(with = "runGeneKeepR()")` alias
  forwarding to it. Both stay exported, so existing
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  callers keep working (soft warning, no hard break). **BEHAVIOR/API
  change (deprecation direction reversed) → STRICT TDD
  (RED→GREEN→REFACTOR); direct-merge landing; 0 stakeholder corrections
  / 0 owner overrides.**
- **RED:** renamed `tests/testthat/test_runGeneKeepR_alias.R` →
  `test_runModularApp_alias.R` (runModularApp is the alias now) and
  rewrote it to pin the reversed contract (6 tests, all Shiny launches
  mocked):
  [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
  does NOT deprecate (forced `lifecycle_verbosity="warning"` +
  `expect_no_warning`), launches via
  [`shiny::runApp`](https://rdrr.io/pkg/shiny/man/runApp.html), forwards
  `port`/`launch.browser`;
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  DOES `expect_deprecated`, delegates to
  [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md),
  forwards args. The 4 flipped-contract blocks failed as designed; the 2
  regression guards passed.
- **GREEN:** swapped the two bodies — `R/runGenekeepr.R` now holds
  `shiny::shinyApp(appUI(), appServer)` +
  [`shiny::runApp`](https://rdrr.io/pkg/shiny/man/runApp.html) (no
  deprecation; `@importFrom shiny` moved here; roxygen rewritten as the
  production entry point); `R/runModularApp.R` now
  `deprecate_soft(when="2.0.0", what="runModularApp()", with="runGeneKeepR()")`
  then `runGeneKeepR(...)`. `devtools::document()` regenerated both
  `.Rd`; **NAMESPACE diff EMPTY** (both stay `export()`ed). All 6 tests
  pass.
- **REFACTOR (doc consistency, no behavior change):** flipped the shared
  `_running_shiny_application.Rmd` (child chunk of README + 2 vignettes)
  to recommend
  [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md);
  updated 9
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  mentions across 5 `vignettes/articles/*.qmd`; added a
  development-version `NEWS.Rmd` bullet (`(#110)` issue-ref);
  `R/loadSiteConfig.R` doc `\link` → `runGeneKeepR`; CLAUDE.md 2 lines;
  re-rendered `README.md` + `NEWS.md`.
- **Verify (firsthand):** full test suite 0 fail / 0 error / 0 true
  offenders; `lintr` 0 on the 3 changed R files; `spell_check_package`
  clean; **NAMESPACE diff empty**; **`R CMD check --as-cran` (clean
  tree) GREEN — 0 errors / 0 warnings / 2 NOTEs** (standing benign pair:
  archived-maintainer CRAN false positive + HTML-Tidy/V8 environmental)
  with `code/documentation mismatches … OK`, `Rd cross-references … OK`
  (both `\link` targets resolve), examples / `testthat.R [68s/68s]` /
  vignettes OK. (A first `--as-cran` run showed a transient 3rd NOTE — a
  stray `README.html` render byproduct left in the tree when
  `R CMD build` snapshotted; removed it and re-ran clean. See
  PROJECT_LEARNINGS Learning 255.)
- **Phase-3E (installed-namespace runtime smoke): DONE** (behavior
  change, not N/A). The reversed contract runs against the
  built+installed package via `testthat.R` inside `--as-cran`; a direct
  `load_all` behavioral smoke additionally confirmed
  [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
  emits no deprecation while
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  emits one whose message names
  [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md).
- **issue \#110 CLOSED** — resolved by the owner-chosen reversal;
  direct-merged to `master` and pushed.

### 2026-07-05 — issue \#109 — fix the last audit finding (#9 `runModularApp`) and CLOSE the issue (Session 275)

- **Deliverable (owner scope-gate via one `AskUserQuestion`):** finish
  issue \#109. S272 fixed the reported rendering bug, S273 audited all
  203 man pages (38 findings), S274 fixed 37 of 38 (+1 sibling) and
  deferred finding **\#9** to \#110. The owner chose **“Fix \#9 now +
  close \#109”** — over close-only (defer \#9 to \#110) or
  fix-without-closing. **REFACTOR-class, doc-only; NAMESPACE diff EMPTY;
  no signature/logic/behavior change; TDD RED/GREEN N/A; 0 stakeholder
  corrections / 0 owner overrides.**
- **The fix (1 `R/` line + 1 regenerated `.Rd`, direct-merge to
  `master`):** `R/runModularApp.R:23` `@details` said *“Use
  `\code{\link{runGeneKeepR}}` to run the original monolithic version”*
  — false today:
  [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
  (`R/runGenekeepr.R`) is a
  [`lifecycle::deprecate_soft`](https://lifecycle.r-lib.org/reference/deprecate_soft.html)
  alias whose body just calls `runModularApp(...)`, and its own doc
  states the monolithic app was retired. Replaced with
  *“`\code{\link{runGeneKeepR}}` is a soft-deprecated alias for this
  function”* — the audit’s recommended fix (report §4 \#9), factually
  true now, and \#110-neutral (states current reality without
  pre-judging \#110’s rename question). Mirrors `runGeneKeepR`’s
  reciprocal `@seealso`.
- **Why \#9 was safe to finish despite the \#110 defer:** S274 deferred
  \#9 because a full *replacement wording* could depend on \#110’s
  rename decision. But the stale sentence is wrong regardless of \#110,
  and stating the current alias relationship neither presumes the
  deprecation persists nor blocks a future rename (that rename would
  rewrite this doc as part of \#110). So finishing \#9 completes all 38
  audit findings without touching the \#110 design question — the
  defer-reason (“ideal *replacement* is uncertain”) did not block the
  *minimal correct* fix (“state today’s reality”).
- **Verify (firsthand):** `devtools::document()` touched only the two
  intended files; **NAMESPACE diff empty**; the `.Rd` diff is exactly
  the one-line change; `lintr` 0 on the changed file (new line 75 chars
  ≤80); `spell_check_package` clean (no WORDLIST churn);
  **`R CMD check --as-cran` GREEN — 0 errors / 0 warnings / 2 NOTEs**
  with `code/documentation mismatches … OK`, `Rd cross-references … OK`
  (`\link{runGeneKeepR}` still resolves), `Rd line widths … OK`,
  examples (21s) / `testthat.R [67s/67s] OK` / vignettes all OK. The 2
  NOTEs are the standing benign pair (archived-maintainer CRAN false
  positive + environmental HTML-Tidy/V8 note) — absent on CI, impossible
  for a doc edit to cause.
- **Phase-3E (runtime smoke): N/A (stated, not skipped)** — doc-only
  REFACTOR; the `runModularApp` function body is unchanged (only its
  `@details` comment changed); empty NAMESPACE diff proven; no
  runtime/Shiny/behavior surface.
- **issue \#109 CLOSED** — all three clauses resolved: the reported
  `addAnimalsWithNoRelative` rendering bug (S272), the “audit for
  similar errors” clause (S273), and all 38 findings fixed (S274 + this
  session). Finding \#9’s *naming* question lives on as **\#110**; the
  doc-fixed *code-fix* candidates (`makeSimPed` \#31, `"xlsx"`-accept
  \#2/#14, `geneDrop` reorder \#20, living-only filter \#5/#29,
  `assignAlleles` \#10, `is_valid_date_str` \#13) are noted for possible
  future STRICT-TDD behavior sessions. (Operational note: the
  `--as-cran` gate must run from the repo root — renv activates via the
  repo-root `.Rprofile`; running it from the scratchpad fails on missing
  deps. See PROJECT_LEARNINGS Learning 254.)

### 2026-07-05 — issue \#109 — fix 37 of the 38 audited documentation errors (+1 audit-missed sibling) (Session 274)

- **Deliverable (owner scope-gate via one `AskUserQuestion`, 4
  questions):** apply the fixes for the 38 doc-vs-code errors the S273
  audit (`docs/audits/ISSUE_109_DOC_ERROR_AUDIT_2026-07-04.md`)
  confirmed. Owner chose: **all in one session**; **doc-fix direction**
  (correct the docs to match the code — keeps it doc-only); **defer \#9
  `runModularApp`** to issue \#110 (its wording depends on the
  `runGeneKeepR` deprecation decision); **direct-merge** to `master`. So
  **37 findings fixed** this session (all but \#9). **REFACTOR-class,
  doc-only; NAMESPACE diff EMPTY; no signatures/logic/behavior changed;
  TDD RED/GREEN N/A; 0 stakeholder corrections / 0 owner overrides.**
- **34 `R/` files edited → 38 `man/*.Rd` regenerated.** The extra 4 man
  pages are the **`@inheritParams` donor cascade**: fixing
  `getPotentialSires` `@param ped` (`\code{candidates}`→`\code{ids}`,
  \#34) propagated to `calculateSexRatio` (#26), `removePotentialSires`
  (#32), and **three pages the audit never separately flagged**
  (`groupAddAssign`, `fillGroupMembersWithSexRatio`, `makeGroupMembers`)
  that inherit the same `ped` text — one donor edit, six corrected
  pages.
- **Discovered + fixed a 39th instance the audit missed.** The audit’s
  §4 said the `@inheritParams` callees “fix themselves” from the donor,
  but `removePotentialSires` carried a **LOCAL** `@param minAge` (not
  inherited) with the identical stale “group formation / pairwise
  kinships ignored” text as \#11 — the donor fix could not reach it.
  Deleted the local duplicate so `minAge` now inherits the corrected
  donor text (the pattern fix the audit intended). A completeness grep
  confirmed the other multi-hit patterns (7 genuine group-formation
  `minAge` pages, `xlsx` in file-readers, “live animals” in `calcGU`,
  `POSIXct`/`YYYYMMDD` in date functions) are legitimately correct — the
  audit scoped them out correctly; left untouched.
- **The 3 Critical fixed:** `checkChangedColsLst` `@return` (NULL/list →
  `TRUE`/`FALSE`); `getFocalAnimalPedFromFile` `@details` (returns-NULL
  → classed `nprcgenekeeprFileErr`, consistent with its own `@return`);
  `saveDataframesAsFiles` `@param fileType` (`"xlsx"` → `"excel"`,
  matching the `stopifnot`).
- **Method (find → apply → verify):** (a) a 35-agent read-only Workflow
  produced byte-exact edit specs (each verified against the function
  body); (b) a strict exact-match apply script (each anchor must match
  exactly once, else abort) landed 36 edits (35 specs + the
  `removePotentialSires` completion) with zero mismatches; (c)
  `devtools::document()` = **0 warnings, empty NAMESPACE diff**; (d) a
  37-agent adversarial verification Workflow read every regenerated
  `.Rd` against the code → **37/37 CONFIRMED_FIXED, 0 problems**, and
  correctly left pre-existing \#103-class typos (`kinshipMatricies`,
  `columms`, “length on”) untouched.
- **Spelling handled without WORDLIST churn:** `spell_check_package()`
  flagged only `ignoreHerm` and `proc` (identifiers I placed in prose);
  wrapped them in `\code{}` (proper style — `spelling` skips `\code{}`),
  avoiding a WORDLIST edit and leaving the owner’s uncommitted `errored`
  WORDLIST addition untouched (FM \#22).
- **Verify:** `lintr` = 0 real lints on the 34 changed files; all
  changed roxygen lines ≤80; `spell_check_package` clean; **NAMESPACE
  diff empty**; **`R CMD check --as-cran` GREEN — 0 errors / 0 warnings
  / 1 NOTE** with `code/documentation mismatches … OK`, `Rd files … OK`,
  `Rd cross-references … OK`, `Rd line widths … OK`, examples (21s) /
  `testthat.R [67s/67s]` / vignettes (20s) all OK. The 1 NOTE is the
  benign archived-maintainer CRAN false positive (absent on CI).
- **Phase-3E (runtime smoke): N/A (stated, not skipped)** — doc-only
  REFACTOR, empty NAMESPACE diff proven; no runtime/Shiny/behavior
  surface. The meaningful verification is
  `code/documentation mismatches … OK` + the 37/37 adversarial
  doc-vs-code re-verification.
- **issue \#109 remains OPEN** (closing is the owner’s outward call).
  \#9 `runModularApp` deferred to \#110; several findings the owner may
  want as *code* fixes later (`makeSimPed` \#31, `"xlsx"`-accept
  \#2/#14, `geneDrop` reorder \#20, living-only filter \#5/#29) were
  doc-fixed per the owner’s choice and are noted for follow-up.

### 2026-07-04 — issue \#109 — broad documentation-error audit (all 203 man pages): 38 confirmed doc-vs-code errors (Session 273)

- **Deliverable (owner scope-gate via `AskUserQuestion` = “Broad
  audit”):** issue \#109’s second clause, *“Audit the code for similar
  documentation errors.”* S272 fixed the reported instance and
  deterministically swept its *rendering* class (0 remaining); this
  session audits the broader, judgment-heavy class the automated gate
  cannot see — **documentation that is factually wrong about what the
  code does** (valid Rd that passes `R CMD check`/`checkRd`/`document()`
  yet misleads). **Analysis-only, REFACTOR-class; no `R/` modified; the
  fixes are a separate owner-gated session; TDD RED/GREEN N/A; 0
  corrections / 0 overrides.**
- **Deliverable artifact:**
  `docs/audits/ISSUE_109_DOC_ERROR_AUDIT_2026-07-04.md`
  (developer-facing, `.Rbuildignore`d — like the S244
  `ROXYGEN_HARMONIZATION_AUDIT`).
- **Result: 38 confirmed documentation errors — 3 Critical, 22 Moderate,
  13 Minor** (15 factual-mismatch, 12 wrong-return, 10 wrong-param, 1
  misleading-render; 0 broken-example, 0 broken-xref). The 3 Critical
  break a caller who follows the docs: `checkChangedColsLst` (`@return`
  says “NULL / the list” but returns `TRUE`/`FALSE`),
  `getFocalAnimalPedFromFile` (`@details` says returns `NULL` but
  returns a classed `nprcgenekeeprFileErr`, contradicting its own
  `@return`), `saveDataframesAsFiles` (documents `fileType="xlsx"` but
  the code’s `stopifnot` accepts only `"excel"`).
- **Dominant root cause = copy-paste drift between sibling functions**
  (and code that evolved past its doc). Clusters: a `getPotentialSires`
  `@param ped`/`minAge` donor bug that cascades via `@inheritParams` (4
  findings, 1 fix); logical-scalar checkers documented as NULL/list;
  `reportErrors=TRUE` alternate returns undocumented; `@return`
  list-element names not matching the code; return-type mislabels;
  `"xlsx"` vs `"excel"`; a “live animals only” filter the code never
  applies;
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  self-kinship is 0.5 documented as 1.0.
- **Method:** deterministic pre-pass (confirmed all 8 S244 defects D1–D8
  fixed; `\link` xrefs 100% resolve; doubled-`.Rd`/empty-`\code{}` = 0;
  data-doc columns match; `document()` zero warnings/drift) → a 17-batch
  multi-agent semantic sweep (doc read against source + running
  function) → adversarial per-finding verification (default-refute) →
  session-author firsthand re-verification of all 3 Critical + a
  cross-class sample + the 1 refuted candidate (`getRequiredCols`,
  correctly refuted — “(optional)” qualifies the value, not the column).
  56 agents, 0 errors; 39 candidates → 38 confirmed, 1 refuted.
- **This is the delta, not a re-run** of the S244 harmonization audit
  (voice/de-dup/ordering, largely implemented): \#109’s lens is
  *errors*, distinct from \#103’s *harmonization*.

### 2026-07-04 — issue \#109 — fix roxygen `\code{}` rendered literally inside a `\preformatted{}` code block (`addAnimalsWithNoRelative`) (Session 272)

- **Deliverable (owner scope-gate + fix-form-gate + landing-gate via
  `AskUserQuestion`):** fix the roxygen2 rendering error issue \#109
  reports — in `R/addAnimalsWithNoRelative.R:11` a blank-line-preceded,
  4-space-indented `@details` line becomes a markdown **code block**
  (`\preformatted{}`) in this markdown-mode package, and the author had
  *also* wrapped it in `\code{}`; inside `\preformatted{}` the `\code{}`
  is verbatim, so `man/addAnimalsWithNoRelative.Rd` rendered the literal
  text `\code{available[[i]] <- setdiff(available[[i]], kin[[id]])}`
  instead of the code. **REFACTOR-class documentation rendering fix — no
  R-logic / NAMESPACE / behavior change (NAMESPACE diff empty); TDD
  RED/GREEN N/A; 0 corrections / 0 overrides** (3 owner gates: audit
  scope = confirmed-class-only; fix form = drop the `\code{}` wrapper;
  landing = direct-merge).
- **Audit for “similar errors” (deterministic, all 203 man pages):** the
  reported class has **exactly 1 instance** repo-wide. Three independent
  cross-checks: (a) a brace-matched detector for Rd markup (`\code`,
  `\link`, `\strong`, …) rendered literally inside a `\preformatted{}`
  block → **1 hit** (`addAnimalsWithNoRelative.Rd`); (b)
  [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html) over all
  203 `.Rd` → only a non-ASCII note in `getPyramidAgeDist.Rd`, a **false
  positive** (`Encoding: UTF-8` is declared, so `--as-cran` accepts it —
  clean per S270); (c) an R/-source scan of the *cause* pattern (~40
  indented `\code{}` lines) → **all false positives** (list items and
  wrapped `@param`/`@return` prose that render correctly — proven
  because the `.Rd` detector flags none of them; they are not
  blank-line-preceded code blocks).
- **The change (1 `R/` line + 1 regenerated `.Rd`, direct-merge to
  `master`):** removed the `\code{` … `}` wrapper on
  `R/addAnimalsWithNoRelative.R:11`, leaving the indented line as a
  plain code block. `man/addAnimalsWithNoRelative.Rd` now renders
  `\preformatted{available[[i]] <- setdiff(available[[i]], kin[[id]])}`
  (the code, not its markup). The `@description`’s inline
  `\code{}`/`\strong{}` uses render correctly and were left untouched
  (raw-Rd-vs-markdown style, not rendering errors — scope discipline).
- **Verify (firsthand):** `devtools::document()` touched **only** the
  two intended files; **NAMESPACE diff empty**; the `.Rd` diff is
  exactly the one-line de-wrapping; the \#109 detector re-run reports
  **0** occurrences across all 203 man pages; new source line 59 chars
  (≤80), `lintr` = 0 on the changed file; `spell_check_package` — the
  changed file’s flagged words (`groupAddAssign`, `kinships`) are
  already in `inst/WORDLIST`, so no new spelling;
  **`R CMD check --as-cran` GREEN 0 errors / 0 warnings / 2 NOTEs** with
  `Rd files … OK`, `Rd cross-references … OK`,
  `code/documentation mismatches … OK`, examples (21s)/tests
  (`testthat.R [68s/68s] OK`)/Rd/vignettes/PDF all OK. The 2 NOTEs are
  the same benign pair as S264–S270 (archived-maintainer false
  positive + environmental HTML-Tidy/V8 note — not caused by the edit,
  absent on CI).
- **Surfaced-not-acted (out of scope):** `spell_check_package()` also
  flags `errored` in `NEWS.md`/`NEWS.Rmd` (entered at S270’s `ce9edad0`)
  — a valid tech-English word missing from `inst/WORDLIST`; a WORDLIST
  add, unrelated to this markup fix. Flagged, not touched. issue \#109’s
  reported error class is now fully clean.

### 2026-07-04 — issue \#114 — land PR \#115 (rebase-merge to `master`) + branch cleanup (Session 271)

- **Deliverable (owner-directed; merge method owner-gated via
  `AskUserQuestion`):** merge **PR \#115** — the S270
  `getPedDirectRelatives(unrelatedParents = TRUE)` fix — into `master`.
  A landing/merge of already-complete, CI-certified code (no new `R/`
  change), so **no local re-gate**: the PR’s **10/10 green CI checks**
  plus a proven byte-identical branch tree are the certification. **0
  corrections / 0 overrides** (1 owner gate: merge method = **Rebase**,
  deleting the branch).
- **What landed:** re-verified the PR green (`MERGEABLE / CLEAN`, all
  checks pass, body “Fixes \#114”) before merging; owner-gated the
  method (all 3 enabled, master history strictly linear) → **Rebase**.
  Result: **PR \#115 MERGED** (`mergeCommit 79125a0b`), **issue \#114
  auto-CLOSED**, `master` == `origin/master` at `79125a0b` (fix commit
  `ce9edad0` + close-out docs), feature branch deleted **local +
  remote**.
- **Snag + clean recovery (self-inflicted, nothing lost):**
  `gh pr merge --rebase --delete-branch` was run from the PR branch with
  an uncommitted S271 stub in `SESSION_NOTES.md`; the **remote merge ran
  first and succeeded** (issue closed), then the **local** branch-delete
  checkout aborted on the dirty file. Recovery: confirmed the merge via
  `gh pr view` before any git surgery, stashed/popped carefully
  (preserving an unrelated `dev` stash), proved
  `git diff <branch> 79125a0b` **empty**, then completed the delete
  manually (`git push origin --delete` + `git branch -D` — force, since
  rebase gives non-ancestor SHAs). `delete_branch_on_merge` is off at
  repo level, so the branch never auto-deletes.
- **Verify (firsthand):** PR MERGED + issue CLOSED (`gh`); `master`
  local == origin; both fix commits on master; branch absent local +
  remote; **Phase-3E runtime smoke on the merged master tree** —
  `test_getPedDirectRelatives.R` all pass.
- **Learning 250** (`gh pr merge --delete-branch` needs a fully clean
  tree; complete cleanup manually if it aborts) + memory pointer added.
  **No open landing remains** — issue \#114 closed.

### 2026-07-04 — issue \#114 — fix `getPedDirectRelatives(unrelatedParents = TRUE)` crash (Session 270)

- **Deliverable (owner-gated throughout via `AskUserQuestion`):** fix
  the behavior bug S269 surfaced —
  `getPedDirectRelatives(unrelatedParents = TRUE)` errored
  (`replacement has 1 row, data has 0`) whenever a referenced parent had
  no ego record, and was a silent no-op equal to the `FALSE` result
  otherwise. **Behavior fix to an exported function — STRICT TDD (RED →
  GREEN; REFACTOR = none needed); 0 stakeholder corrections / 0
  overrides** (owner gates: open issue \#114 first; approach = implement
  the documented placeholder behavior; PRE-RED→RED, RED→GREEN,
  GREEN→REFACTOR gates; NEWS entry = yes; landing = PR-for-CI).
- **The change (`R/getPedDirectRelatives.R` body; PR \#115):** the
  `unrelatedParents = TRUE` branch now synthesizes one all-`NA` row per
  referenced-but-absent parent (`id` set, `sire`/`dam` = `NA`) and
  `rbind`s them, returning a data.frame — instead of discarding a
  misapplied
  [`addIdRecords()`](https://github.com/rmsharp/nprcgenekeepr/reference/addIdRecords.md)
  call.
  [`addIdRecords()`](https://github.com/rmsharp/nprcgenekeepr/reference/addIdRecords.md)
  is untouched (it is correct for its other caller
  `addBackSecondParents.R:51`, which passes ids that exist in `fullPed`;
  it is simply the wrong tool here). The `FALSE` result is unchanged. No
  roxygen / signature / NAMESPACE change.
- **Root cause (firsthand, proven by running it):**
  [`addIdRecords()`](https://github.com/rmsharp/nprcgenekeepr/reference/addIdRecords.md)
  retrieves rows *from* `fullPed` (`fullPed[fullPed$id %in% ids, ]`);
  with `fullPed == ped` and `ids == unrelated` (ids **not** in `ped$id`
  by construction), that is always 0 rows, and `addToPed$sire <- NA`
  then errors on a 0-row frame. So S269’s suggested “just assign the
  return” fix would **not** have worked — it errors at the same spot.
  RED (the failing test) exposed this before any implementation.
- **TDD:** RED — two `test_that` blocks added to
  `tests/testthat/test_getPedDirectRelatives.R`: (1) a ped where `Z` is
  referenced as a dam with no ego record → asserts `TRUE` returns the
  `Z` placeholder with `sire`/`dam` = `NA` and is a superset of the
  `FALSE` result (failed with the documented error); (2) a guard that
  with no unrelated parents `TRUE` == `FALSE` (passed then and now).
  GREEN — the synthesize fix; both new tests pass.
- **Verify (firsthand):** target test file all pass; **full suite 0 real
  failed / 0 real errors** (1166 real contexts, `NOT_CRAN=true`);
  `lintr` = 0 on the changed file; `spell_check_package` clean;
  **NAMESPACE diff empty** (signature unchanged);
  **`R CMD check --as-cran` GREEN 0 errors / 0 warnings / 2 NOTEs** with
  `code/documentation mismatches … OK`, examples (20s) /
  `testthat.R [66s/66s] OK` / vignettes / PDF all OK; **Phase-3E
  installed-namespace smoke** (against the `.Rcheck` build, imports
  enforced) — `getPedDirectRelatives(unrelatedParents = TRUE)` returns
  the `Z` placeholder row with NA parents. The 2 NOTEs are the same
  benign pair as S264–S269 (archived-maintainer false positive +
  environmental HTML-Tidy/V8 note — not caused by the fix, absent on
  CI).
- **NEWS + landing:** added a development-version “Changes” bullet in
  `NEWS.Rmd` and regenerated `NEWS.md` (clean 8-line diff). Landed via
  **PR \#115** (`fix/issue-114-unrelated-parents`, fix commit
  `4bbfb32a`) for cross-platform CI — awaiting CI + owner merge
  (behavior change → PR-for-CI per the project rubric).

### 2026-07-04 — issue \#103 — `getPedDirectRelatives` `@param unrelatedParents` grammar fix (Session 269)

- **Deliverable (owner approach-gate + landing-gate via
  `AskUserQuestion`):** fix the `getPedDirectRelatives.R`
  `@param unrelatedParents` sentence fragment S267 surfaced — the `TRUE`
  clause (“a place holder record where parent (`sire`, `dam`) IDs are
  set to `NA`”) had no main verb. **REFACTOR-class documentation grammar
  fix — no R-logic / NAMESPACE / behavior change (NAMESPACE diff empty);
  TDD RED/GREEN N/A; 0 corrections / 0 overrides** (2 owner gates:
  approach = parallel-to-`FALSE`-clause wording; landing =
  direct-merge).
- **The change (1 `R/` + 1 regenerated `.Rd`, direct-merge to
  `master`):** the `@param unrelatedParents` `TRUE` clause → “when
  `TRUE` they get a place holder record as an ego in which the parent
  (`sire`, `dam`) IDs are set to `NA`.” Supplies the missing subject +
  verb and mirrors the `FALSE` clause’s structure; the *meaning* is
  unchanged (the text already described the intended placeholder-ego
  semantics). The `FALSE` clause, `@param ped`, title, `@return`, and
  every other block were left untouched (scope discipline).
- **Evidence (firsthand, read-before-edit):** re-read the body and the
  helper first — when `unrelatedParents = TRUE` (lines 62–69) the
  function collects the referenced-but-absent parents (`ids` not in
  `ped$id`) and calls
  [`addIdRecords()`](https://github.com/rmsharp/nprcgenekeepr/reference/addIdRecords.md),
  which pulls their records, sets `sire`/`dam` to `NA`, and appends them
  as ego records (“Add ego records with NA parent IDs”). So the intended
  semantics — the unrelated parents *get* a placeholder ego record with
  NA parent IDs — matches the corrected wording. **Surfaced-not-acted
  observation (own issue, needs TDD):**
  [`addIdRecords()`](https://github.com/rmsharp/nprcgenekeepr/reference/addIdRecords.md)’s
  return value is *discarded* (lines 65–68 don’t assign it; line 70
  returns `ped[ped$id %in% ids, ]`), so `unrelatedParents = TRUE`
  currently has no effect on output — a latent *behavior* bug, out of
  scope for a grammar fix; flagged, not touched.
- **Verify (firsthand):** `devtools::document()` clean, no collateral
  roxygen drift (only `getPedDirectRelatives.Rd` regenerated);
  **NAMESPACE diff empty** (sha `2560cecd…` identical before/after);
  `man/getPedDirectRelatives.Rd` diff changes **only**
  `\item{unrelatedParents}`; all new source lines ≤80 chars, `lintr` = 0
  on the changed file; `spell_check_package` clean;
  **`R CMD check --as-cran` GREEN 0 errors / 0 warnings / 2 NOTEs** with
  `code/documentation mismatches … OK`, `R code … OK`, examples
  (21s)/tests (testthat 67s)/vignettes/PDF all OK. The 2 NOTEs are the
  same benign pair as S264–S268 (archived-maintainer false positive +
  environmental HTML-Tidy/V8 note — not caused by the edit, absent on
  CI).
- **Remaining \#103 items:** with this fix, **all** S267-surfaced \#103
  items are complete (the `@param ped` / description accuracy + de-dup
  clusters are done; the last non-doc-only item `getSimSires.R` was
  deleted S268). The rest of \#103 is bespoke-by-design. Newly surfaced
  (its own issue): the discarded-`addIdRecords`-return behavior bug
  above.

### 2026-07-04 — issue \#103 — delete duplicate `getSimSires.R` (redundant `getPotentialSires` definition) (Session 268)

- **Deliverable (owner approach-gate + landing-gate via
  `AskUserQuestion`):** remove `R/getSimSires.R` — the last
  **non-doc-only** issue \#103 surfaced item. The file was misnamed
  (`getSimSires.R`) but defined/exported a **byte-identical duplicate**
  of `getPotentialSires`, whose canonical definition lives in
  `R/getPotentialSires.R`. **REFACTOR-class dead-duplicate removal —
  zero behavior change; NAMESPACE diff empty; TDD RED/GREEN N/A; 0
  corrections / 0 overrides** (2 owner gates: approach = delete +
  re-document; landing = direct-merge).
- **The change (1 `R/` deletion + 1 regenerated `.Rd`, direct-merge to
  `master`):** `git rm R/getSimSires.R`, then `devtools::document()`.
  Because roxygen2 had silently **merged** the two same-topic `@export`
  blocks, `man/getPotentialSires.Rd` was **doubled** — its `\usage`,
  `\value`, `\description`, and `\examples` each rendered twice and line
  2 cited both source files. Re-documenting **collapsed each to a single
  copy** (the \#103 harmonization win) and the source line now cites
  only `R/getPotentialSires.R`.
- **Evidence (firsthand, five-part deletion-safety chain):** (a) `diff`
  of the two files — the function **body is byte-identical** (only
  cosmetic roxygen whitespace and a `1L` vs `1` example differ), so
  source load order is immaterial to runtime; (b) the surviving
  `getPotentialSires.R` is canonical (name matches, owns the `.Rd`, uses
  the correct integer `1L`); (c) all 20+ references across `R/`,
  `tests/`, vignettes, and `inst/_pkgdown.yml` are to the **function**
  `getPotentialSires` (survives) — a bare-string sweep for `getSimSires`
  hit only `SESSION_NOTES.md`; (d)
  `git log --all -S "getSimSires <- function"` is **empty across all
  history** — the function named by the file never existed, so there was
  nothing to restore (the filename was aspirational, cf. issue \#10
  breeding-sim); (e) the file was committed/tracked with no
  [`source()`](https://rdrr.io/r/base/source.html)/`Collate` path
  reference.
- **Verify (firsthand):** `devtools::document()` clean; **NAMESPACE diff
  empty** (sha `2560cecd…` identical before/after — roxygen dedupes the
  two `@export`s to one `export()` line); **only `getPotentialSires.Rd`
  changed** (no downstream `@inheritParams getPotentialSires` churn);
  `lintr` = 0 on the surviving file; `spell_check_package` clean; **full
  test suite 0 failed / 0 errors** (1334 contexts;
  `test_groupAddAssign` + `test_makeGroupMembers` are the
  getPotentialSires regression gate); **`R CMD check --as-cran` GREEN 0
  errors / 0 warnings / 2 NOTEs** with
  `code/documentation mismatches … OK`, examples (21s)/tests (testthat
  67s)/Rd/vignettes/PDF all OK; **Phase-3E installed-namespace smoke**
  (against the `.Rcheck` build, imports enforced) — `getPotentialSires`
  still exported and callable end-to-end (returned a length-3 vector),
  `getSimSires` correctly absent. The 2 NOTEs are the same benign pair
  as S264–S267 (archived-maintainer false positive + environmental
  HTML-Tidy/V8 note — not caused by the deletion, absent on CI).
- **Remaining \#103 items (each its own small session):**
  `getPedDirectRelatives.R`’s `@param unrelatedParents` prose is a
  grammatically incomplete sentence fragment (surfaced S267, doc-only).
  With this deletion, **all** the \#103-surfaced non-doc-only work is
  complete; the `@param ped` / description accuracy + de-dup clusters
  are otherwise done — the rest is bespoke-by-design.

### 2026-07-04 — issue \#103 — `getPedDirectRelatives` description + `@return` source-agnostic + ancestors→relatives fix (Session 267)

- **Deliverable (owner scope-gate + landing-gate via
  `AskUserQuestion`):** fix the `getPedDirectRelatives.R` documentation
  defects the S265/S266 handoffs surfaced — its `@description` claimed
  the function “Gets direct ancestors from labkey `study` schema and
  `demographics` table” (it never queries LabKey; it walks the supplied
  `ped` dataframe), and **both** the `@description` and `@return` said
  “direct **ancestors**” when the body returns relatives in **both**
  directions. **REFACTOR-class documentation accuracy fix — no R-logic /
  NAMESPACE / behavior change (NAMESPACE diff empty); TDD RED/GREEN N/A;
  0 corrections / 0 overrides** (2 owner gates: scope = full accuracy
  fix; landing = direct-merge).
- **The change (1 `R/` + 1 regenerated `.Rd`, direct-merge to
  `master`):** `@description` → “Gets the direct relatives (ancestors
  and descendants) of the selected animals from the supplied pedigree
  (`ped`).”; `@return` → “A data.frame of pedigree records for the
  selected animals and their direct relatives (ancestors and
  descendants) in `ped`.” A **bespoke** rewrite. The `@param ped`
  (“pedigree dataframe object … source of pedigree information”) and the
  title (“Get the direct relatives of selected animals from a pedigree”)
  were already accurate and source-agnostic, so both were left untouched
  (scope discipline).
- **Evidence (firsthand, read-before-edit):** re-read the body first —
  the closure loop (lines 50–52) unions `getParents(ped, ids)` (parents
  / ancestors) **and** `getOffspring(ped, ids)` (offspring /
  descendants) transitively until no new IDs, then returns
  `ped[ped$id %in% ids, ]` (line 70). Zero LabKey/schema/`demographics`
  references anywhere in the body, so the source claim was copy-paste
  drift. Confirmed the two helpers’ directions firsthand from their own
  roxygen (`getParents` → “the IDs of the parents”; `getOffspring` →
  “all of the offspring IDs”), so “ancestors and descendants” is
  accurate and “ancestors” alone understated it — matching the function
  name and its `@family direct relatives`.
- **Verify (firsthand):** `devtools::document()` clean, no collateral
  roxygen drift (only `getPedDirectRelatives.Rd` regenerated);
  **NAMESPACE diff empty** (sha `2560cecd…` identical);
  `man/getPedDirectRelatives.Rd` diff changes **only** `\value` and
  `\description`; new source lines 72/51/72/68 chars (all ≤80), `lintr`
  = 0 on the changed file; `spell_check_package` clean;
  **`R CMD check --as-cran` GREEN 0 errors / 0 warnings / 2 NOTEs** with
  `code/documentation mismatches … OK`, examples (21s)/tests (testthat
  67s)/Rd/vignettes/PDF all OK. The 2 NOTEs are both benign
  (archived-maintainer false positive + environmental HTML-Tidy/V8 note
  — not caused by the edit, absent on CI).
- **Remaining \#103 surfaced defects (each its own small session):**
  `getSimSires.R` duplicate `getPotentialSires` (likely delete after a
  ref-check — **not** doc-only, so runtime-smoke the installed
  namespace + diff NAMESPACE). Surfaced-but-deferred this session:
  `getPedDirectRelatives`’s `@param unrelatedParents` prose is a
  grammatically incomplete sentence fragment (not
  source/accuracy-related — left untouched). The `@param ped`
  accuracy/de-dup work for \#103 is otherwise complete except those
  items — the rest is bespoke-by-design.

### 2026-07-04 — issue \#103 — `filterPairs` `@param ped` accuracy fix (Session 266)

- **Deliverable (owner approach-gate + landing-gate via
  `AskUserQuestion`):** fix the `filterPairs.R` `@param ped` accuracy
  defect S263/S264/S265 surfaced — it falsely said “including the IDs
  listed in `candidates`” (the function has **no** `candidates` formal)
  and never named the `sex` column the body requires. **REFACTOR-class
  documentation accuracy fix — no R-logic / NAMESPACE / behavior change
  (NAMESPACE diff empty); TDD RED/GREEN N/A; 0 corrections / 0
  overrides** (2 owner gates: approach = columns + kin note; landing =
  direct-merge).
- **The change (1 `R/` + 1 regenerated `.Rd`, direct-merge to
  `master`):** `@param ped` → “Dataframe of pedigree information that
  must contain an `id` column and a `sex` column. The `id` values should
  include the animals referenced in `kin`.” A **bespoke** rewrite: the
  body uses only `ped$id` (merge key, lines 39–40) and `ped$sex`
  (extracted, lines 42–43). Confirmed firsthand there is **no** id+sex
  `@param ped` donor to `@inheritParams` (every `ped` block naming `sex`
  also requires `sire`/`dam`, which `filterPairs` does not use), so
  bespoke was correct, not a collapse.
- **Evidence (firsthand, read-before-edit):** re-read the body first —
  `merge(kin, ped, by.y = "id")` requires `ped$id`; the subsequent
  `[, "sex"]` extraction requires `ped$sex`; zero sire/dam/demographic
  references. The phantom `candidates` clause was copy-paste drift from
  a group-formation function (grep: 0 `candidates` occurrences in
  `filterPairs.R`). The sole caller `getAnimalsWithHighKinship` passes a
  `ped` that carries `sex`, consistent with the corrected requirement.
- **Verify (firsthand):** `devtools::document()` clean, no collateral
  roxygen drift (only `filterPairs.Rd` regenerated); **NAMESPACE diff
  empty** (sha `3ba035c3…` identical); `man/filterPairs.Rd` diff changes
  **only** `\item{ped}`; new source lines 68/72/48 chars, `lintr` = 0 on
  the changed file; `spell_check_package` clean;
  **`R CMD check --as-cran` GREEN 0 errors / 0 warnings / 2 NOTEs** with
  `code/documentation mismatches … OK`, examples (21s)/tests (testthat
  66s)/Rd/vignettes all OK. The 2 NOTEs are both benign
  (archived-maintainer false positive + environmental HTML-Tidy/V8 note
  — not caused by the edit, absent on CI).
- **Remaining \#103 surfaced defects (each its own small session):**
  `getPedDirectRelatives.R` description + `@return` still say “labkey
  `study` schema/`demographics`” (wrong for the source-agnostic fn);
  `getSimSires.R` duplicate `getPotentialSires` (likely delete after a
  ref-check — not doc-only, so runtime-smoke + diff NAMESPACE). Finding
  6 `@param ped` de-dup + the id/sire/dam + parameter-accuracy clusters
  are now complete except those two — the rest is bespoke-by-design.

### 2026-07-04 — issue \#103 — `removeDuplicates` `@param ped` understatement fix (Session 265)

- **Deliverable (owner approach-gate + landing-gate via
  `AskUserQuestion`):** fix the `removeDuplicates.R` `@param ped`
  understatement S263/S264 surfaced — it said only “The `id` column is
  required.” while the body requires **both** `id` and `recordStatus`.
  **REFACTOR-class documentation accuracy fix — no R-logic / NAMESPACE /
  behavior change (NAMESPACE diff empty); TDD RED/GREEN N/A; 0
  corrections / 0 overrides** (2 owner gates: approach = minimal
  wording; landing = direct-merge).
- **The change (1 `R/` + 1 regenerated `.Rd`, direct-merge to
  `master`):** `@param ped` → “The `id` and `recordStatus` columns are
  required.” — a **bespoke** rewrite mirroring the body’s own guard
  (`stop("ped must have columns \"id\" and \"recordStatus\".")`).
  Confirmed firsthand there is **no** id+recordStatus `@param ped` donor
  to `@inheritParams` (grep of every `#'` line in `R/`), so bespoke was
  correct, not a collapse.
- **Evidence (firsthand, read-before-edit):** re-read the body first —
  line 31’s guard
  `if (!all(c("id", "recordStatus") %in% names(ped))) stop(...)`
  requires **both** columns *unconditionally* (before the `reportErrors`
  branch), so `recordStatus` is required in every call path; the
  `reportErrors = TRUE` branch additionally reads `ped$recordStatus`
  (line 35), and the `@example` prepends `recordStatus` before calling.
  The old `@param` naming only `id` was a genuine understatement.
- **Verify (firsthand):** `devtools::document()` clean, no collateral
  roxygen drift (only `removeDuplicates.Rd` regenerated); **NAMESPACE
  diff empty** (sha `3ba035c3…` identical); `man/removeDuplicates.Rd`
  diff changes **only** `\item{ped}`; `lintr` = 0 on the changed file
  (new line 75 chars); `spell_check_package` clean;
  **`R CMD check --as-cran` GREEN 0 errors / 0 warnings / 2 NOTEs** with
  `code/documentation mismatches … OK`, examples (21s)/tests (testthat
  66s)/Rd/vignettes all OK. The 2 NOTEs are both benign
  (archived-maintainer false positive + environmental HTML-Tidy/V8 note
  — not caused by the edit, absent on CI).
- **Remaining \#103 surfaced defects (each its own small session):**
  `filterPairs.R` `@param ped` falsely claims an “IDs listed in
  `candidates`” linkage it has no formal for; `getPedDirectRelatives.R`
  description + `@return` still say “labkey `study`
  schema/`demographics`” (wrong for the source-agnostic fn);
  `getSimSires.R` duplicate `getPotentialSires` (likely delete after a
  ref-check — not doc-only, so runtime-smoke + diff NAMESPACE). Finding
  6 `@param ped` de-dup + the id/sire/dam accuracy cluster are now
  complete — the rest is bespoke-by-design.

### 2026-07-04 — issue \#103 — `createPedTree` `@param ped` accuracy fix (Session 264)

- **Deliverable (owner approach-gate + landing-gate via
  `AskUserQuestion`):** fix the `createPedTree.R` `@param ped` accuracy
  defect S263 surfaced — its description claimed demographic columns
  (`birth`/`death`/`departure`) the function never uses.
  **REFACTOR-class documentation accuracy fix — no R-logic / NAMESPACE /
  behavior change (NAMESPACE diff empty); TDD RED/GREEN N/A; 0
  corrections / 0 overrides** (2 owner gates: approach =
  `@inheritParams`; landing = direct-merge).
- **The change (1 `R/` + 1 regenerated `.Rd`, direct-merge to
  `master`):** `createPedTree`’s 4-line demographic `@param ped` block →
  `@inheritParams getDescendantPedigree` (the same exported id/sire/dam
  house-style donor S263 landed). This both **corrects** (the rendered
  `\item{ped}` now reads “datatable that is the `Pedigree` … `id`,
  `sire` and `dam` are required”) **and de-dups**. The function’s own
  line-21 description prose (“This function uses only `id`, `sire`, and
  `dam` columns”) is retained, so no information is lost. Donor
  `getDescendantPedigree` untouched.
- **Evidence (firsthand, per S263’s own lesson):** re-read
  `createPedTree` before editing — body (lines 36–45) uses only
  `ped$id`/`ped$sire`/`ped$dam`, zero demographic references, confirming
  the `@param` was copy-paste drift. Confirmed the donor is exported
  (has an `.Rd`), accurate, and that `createPedTree` has no `probands`
  formal (so `@inheritParams` supplies only `ped`, no collision / no
  over-inheritance).
- **Verify (firsthand):** `devtools::document()` clean (donor resolved,
  no warning); **NAMESPACE diff empty** (sha identical);
  `man/createPedTree.Rd` diff changes **only** `\item{ped}` (no
  `\item{probands}` leaked → over-inheritance ruled out); `lintr` = 0 on
  the changed file; `spell_check_package` clean;
  **`R CMD check --as-cran` GREEN 0 errors / 0 warnings / 2 NOTEs** with
  `code/documentation mismatches … OK`, examples/tests (testthat
  70s)/Rd/vignettes all OK. The 2 NOTEs are both benign: the
  archived-maintainer false positive, plus an environmental
  HTML-Tidy/V8-unavailable note (local toolchain, not caused by the
  edit, absent on CI).
- **Remaining \#103 surfaced defects (each its own small session):**
  `removeDuplicates.R` `@param ped` says “id column is required” but the
  body also requires `recordStatus`; `filterPairs.R` `@param ped`
  falsely claims a `candidates` linkage it has no formal for;
  `getPedDirectRelatives.R` description + `@return` still say “labkey
  `study` schema/`demographics`” (wrong for the source-agnostic fn);
  `getSimSires.R` duplicate `getPotentialSires` (likely delete after a
  ref-check). Finding 6 `@param ped` de-dup itself is now effectively
  complete — the rest is bespoke-by-design.

### 2026-07-04 — issue \#103 Stage 8b-`ped` continued — id/sire/dam phrasing cluster de-duped; C6 “demographic pair” refuted (Session 263)

- **Deliverable (owner scope-gate via `AskUserQuestion` = “id/sire/dam
  cluster (3)”):** collapse the 3 body-verified id/sire/dam
  phrasing-variant `@param ped` blocks to
  `@inheritParams getDescendantPedigree`. **REFACTOR-class documentation
  de-dup — no R-logic / NAMESPACE / behavior change (NAMESPACE diff
  empty); TDD RED/GREEN N/A; 0 corrections / 0 overrides** (2 owner
  gates: scope; landing = direct-merge).
- **The change (3 `R/` + 3 regenerated `.Rd`, direct-merge to
  `master`):** `convertRelationships`, `getFounders`, `removeAutoGenIds`
  → `@inheritParams getDescendantPedigree` (exported donor; house-style
  “datatable … `id`, `sire` and `dam` are required”). The
  `removeAutoGenIds` collapse also **fixes its “dame” typo** (“dame” →
  “dam”). Donor `getDescendantPedigree` untouched.
- **C6 “demographic pair” refuted (the session’s key catch):** S262’s
  handoff suggested collapsing `createPedTree` ↔︎ `setExit` as a
  near-identical pair (1-word Oxford-comma diff). Reading the bodies
  showed `createPedTree` uses **only** id/sire/dam (its own line-21
  comment says so; zero demographic body references) — its demographic
  `@param ped` is copy-paste drift from `setExit` (which genuinely
  computes `exit` from `death`/`departure`). Collapsing them would have
  **cemented** `createPedTree`’s wrong description. So the demographic
  cluster yields **no** safe collapse; `createPedTree`’s inaccuracy is
  surfaced as a defect for its own session (a generalization of S262’s
  own Learning 246 to the handoff’s cluster claims).
- **Method (evidence + adversarial verify):** firsthand census
  (corrected blank-`#'`-continuation extractor) → a **3-agent read-only
  Workflow** (each agent tries to *refute* one collapse; reads callee
  body + donor; **3/3 CONFIRM**) → guarded in-place `@param ped`-block
  replacement. Verified the donor is exported and that `meanKinship`
  documents no `ped`, so `convertRelationships`’s second
  `@inheritParams` supplies `ped` with no first-match collision.
- **Verify (firsthand):** `devtools::document()` clean; **NAMESPACE diff
  empty**; each of the 3 `.Rd` changes **only** `\item{ped}`
  (`\item{kmat}`/`\item{ids}` intact and in order → over-inheritance
  ruled out); source re-census `@param ped` 35 → 32 (exactly 3 removed);
  `lintr` = 0 on all 3 files; `spell_check_package` clean;
  **`R CMD check --as-cran` GREEN `Status: 1 NOTE`**
  (archived-maintainer false positive) with
  `code/documentation mismatches … OK`, examples/tests (testthat
  66s)/Rd/vignettes all OK, 0 warnings / 0 errors.
- **Kept bespoke (scope discipline):** `getPedigreeSource`
  (dataframe-only qualifier + `@noRd`), `isFounder` (sire+dam only, no
  id), and all 6 demographic fns (`setExit`, `convertDate`,
  `correctUnknownParentMeanKinship`, `getProductionStatus`,
  `runQcStudbook`). **Surfaced defects (each its own session):**
  `createPedTree`’s copy-paste demographic `@param ped`;
  `removeDuplicates` `@param ped` says “id column is required” but the
  body also requires `recordStatus`.

### 2026-07-04 — issue \#103 Stage 8b-`ped` continued — byte-identical `@param ped` clusters de-duped (Session 262)

- **Deliverable (owner scope-gate = “byte-identical clusters only”):**
  collapse the SHA1-identical `@param ped` clusters among the
  requirement-bearing `ped` functions S259/S260 deferred.
  **REFACTOR-class documentation de-dup — no R-logic / NAMESPACE /
  behavior change (NAMESPACE diff empty, 0 `man/` changes); TDD
  RED/GREEN N/A; 0 corrections / 0 overrides** (2 owner gates: scope;
  landing = direct-merge).
- **The change (5 `R/`, direct-merge to `master`):** 5 `@param ped`
  blocks → `@inheritParams` across 3 byte-identical clusters — **C3a**
  sire+dam-required → `@inheritParams trimPedigree` (addUIds,
  getProbandPedigree, removeUninformativeFounders); **C5-base** GVA
  req-fields → `@inheritParams calcFE` (calcFounderContributions,
  `@noRd`); **C4** id-only → `@inheritParams setPopulation` (resetGroup,
  `@noRd`). Donors (trimPedigree, calcFE, setPopulation) untouched.
- **Census-bug catch (Learning 246):** the first census extractor
  stopped a `@param ped` block at the first blank `#'` line, hiding the
  caveat paragraphs on **calcFEFG** (“must have no partial parentage;
  stops with an error”) and **calcRetention** (“assumed … no partial
  parentage”) — so they mis-clustered as byte-identical with `calcFE`.
  Reading the files before editing caught it; a blind collapse would
  have ERASED both caveats. Corrected extractor + direct reads → those
  two correctly EXCLUDED (they stay bespoke).
- **Verify (firsthand):** `devtools::document()` clean (donors resolved,
  no warning, incl. `@inheritParams`-into-`@noRd`); **NAMESPACE + `man/`
  diff EMPTY** (byte-identical collapses render identically; inherited
  `\item{ped}` confirmed present in the 3 rendering inheritors; no
  orphan `.Rd` for the 2 `@noRd`); source re-census `@param ped` 40 →
  35; `lintr` = 0 on all 5 files; `spell_check_package` CLEAN;
  **`R CMD check --as-cran` GREEN `Status: 1 NOTE`**
  (archived-maintainer false positive) with
  `code/documentation mismatches … OK`, examples/tests/Rd/vignettes all
  OK.
- **Remaining \#103 `ped` clusters (deferred):** C3b id/sire/dam
  phrasing variants (6, incl. removeAutoGenIds “dame” typo), C4-variant
  (removeDuplicates, unknown2NA), C6 demographic (createPedTree+setExit
  pair + 4 distinct), the 6 caveat-bearing GVA fns
  (calcFG/calcFGSE/findOffspring/offspringCounts/getPotentialParents/orderReport
  — `@inheritParams` can’t inherit-plus-append), the C7 bespoke set, and
  the 2 surfaced defects (filterPairs, getPedDirectRelatives).

### 2026-07-04 — issue \#103 Stage 8b LANDED on `master` (PR \#113 merged, both slices) (Session 261)

- **Deliverable (owner-directed = “merge it when green”):** merge **PR
  \#113** — issue \#103 **Stage 8b**, both slices (Session 259 “safe
  formals + `@family`” `bafaa1e8` + Session 260 “`@param ped` de-dup
  C1/C2” `5952d0b4`) — into `master`. Landing/process action for
  already-CI-certified REFACTOR-class documentation content; TDD N/A; 0
  corrections / 0 overrides.
- **Merged clean:** re-confirmed **10 checks pass** (R CMD check on
  Windows/macOS/Ubuntu release+devel+oldrel-1, plus
  lint/pkgdown/test-coverage/codecov) + `mergeStateStatus CLEAN`
  immediately before merging. `gh pr merge 113 --merge --delete-branch`
  → merge commit **`b9e39ddb`** (parents `b8d7f6ce` + `0fc3e536`);
  `master` == origin/master; feature branch deleted.
- **Landed-tree sanity check:** NAMESPACE + DESCRIPTION diff across the
  merge **empty** (doc-only, both slices NAMESPACE-neutral); merge
  touched exactly **58 `R/` + 52 `man/` + 3 process docs** (both slices
  combined, with file overlap). Issue \#103 Stages 1–8b are now all on
  `master`.
- **Note:** `gh pr edit` exits 1 on this repo (deprecated `projectCards`
  GraphQL field) — PR \#113’s title/body were updated via
  `gh api --method PATCH` instead.

### 2026-07-04 — issue \#103 Stage 8b-`ped` (`@param ped` de-dup, Finding 6, C1+C2) (Session 260)

- **Deliverable (owner scope-gate via `AskUserQuestion` = “Two wording
  groups”):** issue \#103 **Stage 8b-`ped`** — collapse the two large
  *pure-phrasing-drift* `@param ped` clusters to `@inheritParams` across
  **27 exported functions**, each verified per-callee by a read-only
  workflow (donor-accuracy + no meaning loss). The requirement-bearing
  `ped` clusters (required-fields, complete-pedigree, demographic,
  one-off) are intentionally deferred. **REFACTOR-class documentation
  work — no R-logic / NAMESPACE / behavior change (NAMESPACE diff
  empty); TDD RED/GREEN N/A; 0 corrections / 0 overrides** (1 owner
  scope-gate; landing deferred to the owner).
- **The change (27 `R/` + 15 regenerated `.Rd`; code commit `5952d0b4`,
  branch `issue103-stage8b-dedup`):**
  - **C1 generic → `@inheritParams reportGV`** (17 fns):
    `createSimKinships`, `cumulateSimKinships`, `fixGenotypeCols`,
    `getGVGenotype`, `getGVPopulation`, `addParents`,
    `addSexAndAgeToGroup`, `getPedMaxAge`, `getPyramidAgeDist`,
    `getRecordStatusIndex`, `removeUnknownAnimals`,
    `getAnimalsWithHighKinship`, `getPyramidPlot`, `hasBothParents`,
    `makeSimPed`, `obfuscatePed`, `countFirstOrder` (the last also fixes
    a malformed `: \code{Pedigree}` leading-colon `@param`).
  - **C2 candidates → `@inheritParams getPotentialSires`** (10 fns):
    `addGroupOfUnusedAnimals`, `fillGroupMembers`,
    `fillGroupMembersWithSexRatio`, `initializeHaremGroups`,
    `makeGroupMembers`, `removePotentialSires`, `calculateSexRatio`,
    `getSexRatioWithAdditions`, `filterAge`, `groupAddAssign`.
  - **`filterPairs` kept bespoke** — the 28th candidate: it has no
    `candidates` formal/linkage, so the candidates donor text would be
    factually inaccurate (adversarial-verify catch). Surfaced as a
    candidate for C1 reclassification / accuracy fix in a later session.
- **Method (evidence + adversarial verify):** firsthand deterministic
  census sized the drift (67 `@param ped` / 66 files / 46 distinct) and
  drove the scope gate; a **28-agent read-only Workflow** verified every
  proposed inherit (reads callee body + donor; judges donor-accuracy AND
  meaning-loss → 27 CONFIRM / 1 KEEP_BESPOKE); a **guarded apply
  script** deleted only each target `@param ped` block and added one
  `@inheritParams` line (collision-proof — local params always win; the
  3 files that also `@inheritParams getParents` keep `ids` from
  `getParents` by order).
- **Verify (firsthand):** `devtools::document()` clean (every donor
  resolved); **NAMESPACE diff empty**; each changed `.Rd` changes
  **only** `\item{ped}` (verified `\item{ids}` unchanged in the 3
  collision files); re-census proved collapse (`@param ped` 67→40
  occurrences / 46→33 distinct, exactly 27 removed); `lintr` = 0 across
  all 27 changed files; `spell_check_package` clean;
  **`R CMD check --as-cran` `Status: 1 NOTE`** (archived-maintainer “New
  submission” false positive) with
  `code/documentation mismatches ... OK`, examples/tests/Rd/vignettes
  all OK.

### 2026-07-04 — issue \#103 Stage 8b (`@inheritParams`/`@family` de-dup, Finding 6) on PR (Session 259)

- **Deliverable (owner scope-gate via `AskUserQuestion` = slice “Safe
  formals + @family”):** issue \#103 **Stage 8b — Finding 6
  (`@inheritParams`/`@family` de-duplication)** — kill the copy-paste
  `@param` drift for the *safe* formals via `@inheritParams`, and add
  `@family` cross-links; the big `@param ped` drift (66 files, ~46
  genuine-variant meanings) intentionally deferred to its own session.
  **REFACTOR-class documentation work — no R-logic / NAMESPACE /
  behavior change (NAMESPACE diff empty); TDD RED/GREEN N/A; 0
  corrections / 0 overrides** (2 owner gates via `AskUserQuestion`:
  scope = safe formals + `@family`; landing = PR-for-CI).
- **The change (38 `R/` + 42 regenerated `.Rd`; code commit `bafaa1e8`,
  branch `issue103-stage8b-dedup`):**
  - **`@inheritParams` (20 conversions / 19 files):** `ids` →
    `@inheritParams getParents` (12 generic callees; the 12 genuine
    variants — “or NULL to restrict”, “to be flagged as part of the
    group”, “original IDs”, … — kept bespoke); `kmat` →
    `@inheritParams meanKinship` (5 callees; 3 “dense, symmetric,
    id-named”/“proband” variants kept bespoke); `threshold` →
    `@inheritParams calcGU` for the **allele-rarity** meaning (`calcA`,
    `calcGUSE`) and `@inheritParams filterThreshold` for the
    **min-kinship** meaning (`getAnimalsWithHighKinship`) — the two
    distinct meanings of one formal deliberately kept on *separate*
    donors.
  - **`@family` (25 exported functions, the package’s first `@family`
    tags):** `direct relatives` (4), `obfuscation` (4),
    `genetic value analysis` (8 exported `calc*`; the `@noRd`
    `calcFounderContributions` excluded as inert), `Shiny modules` (18
    UI+Server exports across 9 `mod*` files — the tag added to BOTH
    blocks per file, not the `@noRd` helpers).
- **Method (evidence + adversarial verification):** a deterministic
  Python census sized the drift firsthand (`@param ids` 24 occ/15
  distinct, `kmat` 9/6, `threshold` 6/4-but-**two-meanings**, `ped`
  66/46 → deferred). A **24-agent read-only Workflow** then verified
  every proposed change: one agent per `@inheritParams` (reads callee
  body + donor; confirms donor text accurate AND no callee-specific
  meaning lost) → **20/20 CONFIRM**; one agent per family (membership +
  export structure). Edits applied by a **guarded script** (each
  `@param` formal must occur exactly once; each `@family` anchored on
  the function definition; 38 files, 0 guard failures).
- **Key `@inheritParams` insight:** because the edit deletes *only* the
  target `@param` line, inheritance can pull in *only* that one shared
  param (roxygen skips locally-documented params) — so donor choice
  carries **zero collision risk** regardless of the donor’s other
  formals.
- **Verify (firsthand):** `devtools::document()` clean — every donor
  resolved (an unresolved `@inheritParams` would warn); **NAMESPACE diff
  empty** (predicted — no `@export`/import change); rendered `.Rd`
  confirmed (inherited donor text + `\seealso{Other …}` family lists);
  the duplicate `getPotentialSires`/`getSimSires` pair converted
  identically so `man/getPotentialSires.Rd` stays deterministic; `lintr`
  = **0** across all 38 changed files (pkg loaded);
  `spell_check_package` = **CLEAN**; **`R CMD check --as-cran` GREEN
  `Status: 1 NOTE`** (the documented archived-maintainer “New
  submission” false-positive) with `checking examples ... OK`,
  `checking tests ... OK`, `code/documentation mismatches ... OK`, all
  Rd checks OK, and `re-building of vignette outputs ... OK`.
- **Phase-3E (runtime smoke): N/A (stated).** REFACTOR-class doc-only —
  no R-logic / runtime / Shiny / NAMESPACE change (empty diff proven).
  FM \#24 does not apply.
- **Surfaced (out of scope, deferred):** (1) `getPedDirectRelatives.R`’s
  **description body + `@return` still say “Gets direct ancestors from
  labkey `study` schema …”** — a wrong copy-paste description for this
  source-agnostic pedigree function (its *title* was fixed in Stage 8a);
  a Finding-3-adjacent description-accuracy defect for a future
  session. (2) Optional: adding `reportGV` (and possibly
  `meanKinship`/`geneDrop`) to the `genetic value analysis` family as
  its aggregator anchor. (3) Stage 8b’s **big remaining half —
  `@param ped`** (66 files, ~46 meanings) needs its own session with
  multiple donors + per-callee verification (blind inheritance would
  corrupt docs). (4) The older `getSimSires.R` duplicate-*file* code
  defect.
- **Landing = PR-for-CI (owner gate):** large `man/` churn (42 pages) +
  the package’s first `@family` tags benefit from cross-platform Rd
  checks; local `--as-cran` is macOS-only. Merge left to the owner (FM
  \#13).

### 2026-06-30 — issue \#103 Stage 8a (title/description voice, Finding 3) landed on `master` (Session 258)

- **Deliverable (owner-directed = “merge PR \#108”):** merge **PR
  \#108** — issue \#103 **Stage 8a — title/description voice
  normalization (audit Finding 3)** — into `master`. **Landing/process
  action for already-verified REFACTOR-class documentation content
  (written + gated by S257); TDD RED/GREEN/REFACTOR N/A; 0 corrections /
  0 overrides.** The owner selected the merge from S257’s suggested-next
  list; no further gate needed (PR-for-CI was already S257’s chosen
  landing method).
- **Merged clean:** PR \#108 confirmed **10/10 checks SUCCESS +
  mergeStateStatus CLEAN** immediately before merging (the CI that was
  in-flight at S257 close-out finished green cross-platform — R CMD
  check on Windows / macOS / Ubuntu release+devel+oldrel-1, plus lint /
  pkgdown / test-coverage / codecov).
  `gh pr merge 108 --merge --delete-branch` → merge commit
  **`0978d405`** (“Merge pull request \#108 …”); local `master`
  fast-forwarded `c623cbfa..0978d405`, remote+local feature branch
  `issue103-stage8a-title-voice` deleted, `.DS_Store` + the Phase-1B
  stub stashed pre-merge and popped cleanly onto `master` (Learning 233
  — master’s `SESSION_NOTES.md` post-merge == the branch’s, so no
  collision).
- **Landed-tree sanity check (this is a PR-for-CI merge, but confirmed
  anyway):** `git diff c623cbfa..0978d405 -- NAMESPACE DESCRIPTION`
  **empty** (title-only, as S257 predicted); the merge touched exactly
  **100 `R/` + 99 `man/` + 3 process docs** (`CHANGELOG.md`,
  `SESSION_NOTES.md`, `PROJECT_LEARNINGS.md`) = 202 files, matching
  S257’s claim; merge commit parents = `c623cbfa` (S256 master base) +
  `d6521165` (S257 branch tip); local `master` == origin/master.
- **Phase-3E (runtime smoke): N/A (stated).** No runtime/behavior change
  merged (empty NAMESPACE diff proven) and the exact tip was already
  CI-certified 10/10 cross-platform. FM \#24 does not apply.
- **Stages 1–8a of issue \#103 are now all on `master`.** Remaining for
  \#103: **Stage 8b — Finding 6** (`@inheritParams`/`@family` de-dup —
  the ~20-way `@param ped` description drift across ~66 files; big +
  judgment-heavy, own scope-gate advisable), plus the Finding-3 tails
  (internal-`@noRd` titles; Shiny `mod*` titles if the owner later
  converts them) and the surfaced `getSimSires.R` duplicate-file code
  defect. No new `PROJECT_LEARNINGS` entry — a pure PR-merge following
  the established S256 pattern produced no novel learning.

### 2026-06-30 — issue \#103 Stage 8a (title/description voice, Finding 3) on PR \#108 (Session 257)

- **Deliverable (owner scope-gate via `AskUserQuestion` = slice “Finding
  3: title voice”):** issue \#103 **Stage 8a — title/description voice
  normalization (audit Finding 3), exported functions only.** Stage 8 as
  the audit scopes it (Findings 3 **and** 6) is ~60–70 title rewrites
  *plus* a 66-file `@param` de-dup + `@family` — too large for one clean
  session (the audit says “consider splitting”); the owner picked the
  title-voice slice. **REFACTOR-class documentation work — no R-logic /
  NAMESPACE / behavior change; TDD RED/GREEN N/A; but INTENTIONALLY
  rendered-drift (changes `man/` titles), so the success test is “titles
  harmonized + gate green”, not zero-drift. 0 corrections / 0
  overrides** (3 owner gates via `AskUserQuestion`: slice = Finding 3;
  Shiny handling = exempt; approve-table = approve-all-as-shown; then
  landing = PR-for-CI).
- **The change (100 R/ + 99 regenerated `.Rd`; code commit `8e76e49a`,
  branch `issue103-stage8a-title-voice`):** normalized **100 exported
  titles** onto one imperative-voice convention — 61 3rd-person →
  imperative, 18 function-name prefixes stripped, 10 noun-phrase →
  imperative, 10 imperative-but-flawed tightened (markup removed /
  run-on shortened / inaccurate corrected, e.g. `getPedDirectRelatives`
  “ancestors” → “relatives”), 1 mixed-voice; **reverted 4 explicit
  `@description` to implicit** (2 inline, 2 malformed braced
  `@description{...}` whose secondary paragraphs move cleanly into
  `\details`); **synced the `getSimSires`/`getPotentialSires`
  duplicate** to one title so the rendered `.Rd` is deterministic.
- **Scope from evidence (Learning 231/242):** a deterministic census + a
  16-agent read-only Workflow (per-batch draft reading each file + a
  2-lens adversarial review — convention + accuracy/consistency) built
  the old→new table; the review adjusted 5 titles and surfaced 2
  out-of-scope **code** defects (the `getSimSires.R` duplicate *file*;
  multi-export `mod*` files each hide a 2nd Server title). The census
  undercounted until multi-export files were re-scanned.
- **Shiny exempted (owner):** the 20 `mod*`/app UI+Server noun-phrase
  titles (“Breeding Groups Module - UI Function”) left unchanged,
  consistent with the Stage-7 `mod*`/app `@examples` exemption.
  **Deferred to later sessions:** Finding 6 (`@inheritParams`/`@family`
  de-dup — the ~20-way `ped` description drift across 66 files) and
  internal-`@noRd` titles.
- **Verify (firsthand):** every title re-extracted and matched to the
  approved target (0 mismatches), all title lines ≤80 chars;
  `devtools::document()` → **NAMESPACE diff empty** (predicted —
  title-only), 99 `.Rd` regenerated; the 2 braced reverts render with no
  literal braces and no lost text (moved to `\details`); `lintr` = **0**
  across all 100 changed files (pkg loaded); `spell_check_package` =
  **CLEAN**; **`R CMD check --as-cran --run-donttest` GREEN
  `Status: 2 NOTEs` = 0/0/2** (the 2 documented false-positives) with
  `checking examples ... OK` and all Rd checks
  (files/metadata/line-widths/cross-references) OK.
- **Phase-3E (runtime smoke): N/A (stated).** Doc-only — no R-logic /
  runtime / Shiny / NAMESPACE change (empty diff proven); the meaningful
  verification is rendered titles + `--as-cran` examples OK. FM \#24
  does not apply.

### 2026-06-30 — issue \#103 Stage 7 (examples policy, Finding 1 / §7) landed on `master` (Session 256)

- **Deliverable (owner pick = “Stage 7 — examples policy”; via
  `AskUserQuestion`: scope = complete Stage 7, policy-doc home = new
  `docs/` file, landing = PR-for-CI):** issue \#103 **Stage 7 — examples
  policy (audit Finding 1 / §7)**: add `@examples` to the
  directly-callable exported utilities, document the Shiny/app/tab-UI
  exemption, choose one guard ladder, retire `if(interactive())` guards.
  **REFACTOR-class documentation work — no R-logic / NAMESPACE /
  behavior change; TDD RED/GREEN N/A; 0 corrections / 0 overrides** (3
  owner gates via `AskUserQuestion`: scope, policy-doc location, landing
  method). **DONE + LANDED on `master`** — branch
  `issue103-stage7-examples` (code commit `d6e6b8dc` + close-out
  `035bd755`); PR \#107 merged after CI 10/10 green + CLEAN via merge
  commit **`84923846`**; local `master` == origin/master.
- **The change (20 R/ files + 20 regenerated `.Rd`):** (a) **added
  `@examples`** to **9** callable utilities — `loadSiteConfig`,
  `loadSpeciesOverrides`, `saveDataframesAsFiles` (writes to
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html)),
  `getPotentialParents`, `makeGroupMembers`, `makeGroupNum`,
  `makeSimPed`, plus `shouldShowChangedColsTab` and
  `processQcStudbookResult` (the audit mislabeled these two “tab-UI” but
  their bodies contain no Shiny code — one returns a logical, the other
  a list of data.frames — so they are plain callable functions); (b)
  **retired 2 `if(interactive())`** launcher guards → `\dontrun`
  (`runModularApp`, `runGeneKeepR`); (c) **harmonized existing guards**
  onto one ladder — 5 `\dontrun` → bare-runnable
  (`makeFounderStatsTable`, `makeGeneticSummaryTable`, `logModuleEvent`,
  `safeExecute`, `runQcStudbook`), 4 LabKey `\donttest` → `\dontrun`
  (`getDemographics`, `getLkDirectAncestors`, `getLkDirectRelatives`,
  `setLabKeyDefaults`).
- **Policy ratified** in `docs/conventions/ROXYGEN_EXAMPLES_POLICY.md`
  (developer-facing; `docs/` is `.Rbuildignore`d so it ships nowhere).
  The `docs/conventions/` path was git-ignored (`.gitignore` `docs/*` +
  per-subdir whitelists), so a `!docs/conventions/` +
  `!docs/conventions/**` whitelist entry was added to make the file
  trackable.
- **Live-tree census confirmed the audit with ZERO drift** (180 exported
  functions, 148 with `@examples`, 32 without; the audit’s 7 utilities
  all still example-less), EXCEPT the 2 mislabeled tab-UI functions →
  add-examples set of 9, not 7. Correctly-exempt (unchanged): 18
  `mod*UI/Server`, `appUI`/`appServer`, the genuine `tabPanel()`
  builders `getChangedColsTab`/`getErrorTab`, the deprecated alias
  `makeGrpNum`.
- **Verified (empirical + build-equivalent):** every runnable example (9
  new + 5 newly-un-guarded) empirically run clean via `load_all` BEFORE
  placement; `devtools::document()` → **NAMESPACE diff empty**
  (predicted — no `@export`/`@importFrom` change); `lintr` = 0 across
  all 20 changed files; `spell_check_package` clean;
  **`R CMD check --as-cran --run-donttest` = `Status: 2 NOTEs` (0/0/2)**
  with **`checking examples ... OK`** + all Rd checks /
  code-documentation mismatches / S3 method consistency / tests all OK.
- **Keyword-safe** PR body (“Part of \#103. Stage 7 of 8 — does **not**
  close the tracking issue”). Learning 242 added to
  `PROJECT_LEARNINGS.md`. **Stages 1–7 of \#103 are now all on
  `master`** (Stage 7 via merge commit `84923846`). Remaining: Stage 8
  (title voice + `@inheritParams`/`@family` de-dup — judgment-heavy,
  last).

### 2026-06-30 — `get_and_or_list` rendered-doc defect fixed (`\sQuote{}`) landed on `master` (Session 255)

- **Deliverable (owner pick = “get_and_or_list”):** fix the carried-open
  rendered-doc defect in `R/get_and_or_list.R:10` — the troff/LaTeX
  single-quote idiom `` `and' ``/`` `or' `` (open-backtick,
  close-apostrophe) that roxygen markdown mode (`DESCRIPTION`
  `markdown = TRUE`, each backtick = an inline-code delimiter)
  mis-parsed into the garbled
  `\verb{and' or }or' with`and’`at`man/get_and_or_list.Rd:15`. **REFACTOR-class documentation fix — no logic / NAMESPACE / behavior change; TDD RED/GREEN N/A; NOT zero-drift (it intentionally changes the rendered`.Rd`); 0 corrections / 0 overrides** (2 owner gates via`AskUserQuestion`: fix approach →`\`;
  landing method → direct-merge).
- **The change (3 spans, 1 R file + regenerated `.Rd`; code commit
  `b0d8e3e8`):** replaced `` `and' or `or' with `and' `` with
  `\sQuote{and} or \sQuote{or} with \sQuote{and}` (wrapped across two
  `#'` lines to stay ≤80 cols, \[\[avoid-new-lints-r-package\]\]).
  `\sQuote{}` is the canonical Rd macro for typographic single quotes:
  it survives markdown mode and renders ‘and’/‘or’/‘and’ in both HTML
  and PDF.
- **Verify (deterministic + build-equivalent, firsthand):**
  `devtools::document()` → only `man/get_and_or_list.Rd` drifted
  (NAMESPACE diff empty);
  [`tools::Rd2txt`](https://rdrr.io/r/tools/Rd2HTML.html) renders ‘and’
  or ‘or’ with ‘and’ (was garbled `\verb{...}`);
  `lintr::lint("R/get_and_or_list.R")` (pkg loaded) = 0;
  `spell_check_package` = clean; **`R CMD check --as-cran` GREEN
  `Status: 2 NOTEs` = 0/0/2** (the 2 documented false-positives:
  CRAN-incoming archived-maintainer + HTML-Tidy-too-old/V8-unavailable)
  with Rd files / Rd metadata / Rd line widths / Rd cross-references /
  code-documentation mismatches / R code / examples / `--run-donttest`
  all OK.
- **Landed (direct-merge, owner-gated):** branch
  `fix-get-and-or-list-squote` (code `b0d8e3e8`) direct-merged onto
  `master` via merge commit `a23e4eb9` (`--no-ff`). Direct-merge has no
  CI → landed-tree sanity check: rendered `.Rd` on `master` shows
  ‘and’/‘or’/‘and’; `git diff be9280b6..a23e4eb9 -- NAMESPACE` empty;
  only the 2 files touched; no `` `word' `` defect remains in `R/`.

### 2026-06-30 — issue \#103: merge PR \#106 (Stage 5) + Stage 6 (internal-marker cleanup, Finding 5) landed on `master` (Session 254)

- **Deliverable (owner-directed, two items: “merge pr \#106” then “then
  stage 6”):** (1) merge **PR \#106** (issue \#103 Stage 5 — import
  conversion) into `master`; (2) issue \#103 **Stage 6 — internal-marker
  cleanup (audit Finding 5)**: drop the redundant `@keywords internal`
  from the two files carrying both `@noRd` AND `@keywords internal`.
  **(1) landing/process; (2) REFACTOR-class doc-metadata — no R-logic /
  NAMESPACE / behavior / rendered-doc change; TDD RED/GREEN N/A; 0
  corrections / 0 overrides** (1 owner gate via `AskUserQuestion`: the
  Stage-6 landing method → owner chose **direct-merge**). The owner
  directed both items (owner-set session scope), handled as two
  sequential deliverables with full verification each and one combined
  close-out.
- **(1) PR \#106 merged:** waited for CI **10/10 green +
  mergeStateStatus CLEAN** (the re-run on close-out commit `e8574fa6`
  finished green — did not merge while UNSTABLE, honoring S253’s
  PR-for-CI cert), then `gh pr merge 106 --merge --delete-branch` →
  merge commit **`fc0b2b72`** (“Merge pull request \#106 …”); local
  `master` fast-forwarded, remote+local branch deleted. Stage 5’s
  NAMESPACE delta (`import(futile.logger)` removed) confirmed present on
  `master`.
- **(2) Stage 6:** removed **5** `@keywords internal` lines — **4** in
  `modPotentialParents.R` (helpers `flattenPotentialParents`,
  `firstPedigreeSpecies`, `pedigreeGestationDefault`,
  `prefillGuardAllows`) + **1** in `readFocalAnimalIds.R` — each on an
  `@noRd` block; **kept** `nprcgenekeepr-package.R:4` (policy: reserve
  `@keywords internal` for the package-level doc). Code commit
  `b3a3fbe0`, direct-merged via merge commit **`318ed491`** (“Merge
  issue \#103 Stage 6 … into master”, `--no-ff`).
- **Zero-impact, proven:** `@keywords` on an `@noRd` block is inert
  (roxygen generates no `.Rd` for it; the tag never reaches NAMESPACE),
  so `devtools::document()` left `man/` and `NAMESPACE` untouched and
  `git diff fc0b2b72..318ed491 -- NAMESPACE man/` is empty.
- **Scope corrected from the live tree (Learning 231):** the audit’s
  Finding 5 “4 files” included `nprcgenekeeper.R` (the duplicate legacy
  package doc, Finding D2) which no longer exists, and implied ~1
  occurrence in `modPotentialParents.R` (since grown to 4 helpers) →
  real scope = 5 removals across 2 files, not the audit’s implied ~2.
- **Verified:** `document()` zero `man/`/`NAMESPACE` diff; `lintr` 0 on
  both changed files; `spell_check_package` clean;
  **`R CMD check --as-cran` = `Status: 2 NOTEs` (0/0/2)** with
  R-code-problems / dependencies-in-R-code / S3 method consistency / all
  Rd checks / code-documentation mismatches / examples /
  `--run-donttest` / tests all OK. Direct-merge has no CI → confirmed on
  the landed tree with a deterministic sanity check
  (`@keywords internal` census = only the package doc; merge touched
  only the 2 R/ files; empty NAMESPACE/man diff). Learning 240 added to
  `PROJECT_LEARNINGS.md`.
- **Stages 1–6 of issue \#103 are now all on `master`.** Remaining:
  Stage 7 (examples policy — Finding 1 / §7), Stage 8 (title voice +
  `@inheritParams`/`@family` de-dup — Findings 3, 6, judgment-heavy).
  Deferred sub-work: the shiny/Matrix `@import` → `@importFrom`
  conversions (each a judgment call). Carried defect:
  `get_and_or_list.R:10` garbled typographic quotes (keep out of any
  zero-drift stage).

### 2026-06-30 — issue \#103 Stage 5 (import conversion, Finding 7) — PR \#106 open, CI green (Session 253)

- **Deliverable (owner pick = “stage 5”; via `AskUserQuestion`: scope =
  futile.logger only, landing = PR-for-CI):** issue \#103 **Stage 5 —
  import conversion (audit Finding 7)**: convert the whole-package
  `@import futile.logger` holdouts to explicit `@importFrom`.
  **REFACTOR-class import-declaration refactoring — no new behavior; TDD
  RED/GREEN N/A; 0 corrections / 0 overrides** (2 owner gates via
  `AskUserQuestion`: the scope, and the landing method). **DONE +
  VERIFIED on branch `issue103-stage5-imports` (code commit `9811a945` +
  this close-out commit); PR \#106 open, CI green 10/10, mergeable/CLEAN
  — the merge is the owner’s call.**
- **The change:** 6 files (`getFocalAnimalPed`,
  `getFocalAnimalPedFromFile`, `getGenotypes`, `getLkDirectAncestors`,
  `getPedigree`, `getPedigreeSource`) call only bare `flog.debug` →
  `@importFrom futile.logger flog.debug`; `getPedDirectRelatives.R`
  carried a **dead** `@import futile.logger` (no usage) → removed (a
  whole-package import survives in NAMESPACE if any file keeps
  `@import`, so all 7 must go to drop it). `shiny` (package-level) and
  `Matrix` (`kinship.R`) **deferred** as the audit’s verified judgment
  calls; the audit’s RColorBrewer holdout was already gone (earlier D7
  cleanup), so the real scope was 7, not the audit’s “8 easy”.
- **NAMESPACE diff is exactly one line removed,
  `import(futile.logger)`** — `flog.debug` (the only bare-name
  dependency) stays imported via existing `@importFrom`; all other
  futile.logger refs are `futile.logger::`-qualified. **Zero `man/`
  drift** (import tags are NAMESPACE-only, never in `.Rd`).
- **Verified (deterministic + runtime):** NAMESPACE delta exactly as
  predicted; `lintr::lint_package()` (changed files) = 0;
  `spell_check_package` clean; **`R CMD check --as-cran` =
  `Status: 2 NOTEs` (0/0/2)** with `checking dependencies in R code` /
  `checking R code for possible problems` / examples / `--run-donttest`
  / tests all **OK**; full `NOT_CRAN` suite 0 failed / 0 error (225
  files); runtime smoke on the freshly-installed namespace
  (`import(futile.logger)` absent, bare `flog.debug` resolves,
  [`getPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedigree.md)
  → 280 rows). **CI on PR \#106: 10/10 green first run** (lint +
  5-platform R-CMD-check incl. devel + pkgdown + test-coverage +
  codecov{patch,project}).
- **Keyword-safe** PR body (“Part of \#103. Stage 5 of 8 — does **not**
  close the tracking issue”). Learning 239 added to
  `PROJECT_LEARNINGS.md`. **Stages 1–4 of \#103 are on `master`; Stage 5
  is on PR \#106 awaiting the owner’s merge.**

### 2026-06-30 — issue \#103 Stage 4 landed on `master` (direct-merge) (Session 252)

- **Deliverable (owner: “land stage 4”; landing method “direct-merge”
  via `AskUserQuestion`):** land issue \#103 **Stage 4** (roxygen markup
  unification) from branch `issue103-stage4-markup` onto `master`.
  **Landing/process — no R-logic / NAMESPACE / behavior change; TDD
  RED/GREEN N/A; 0 corrections / 0 overrides** (1 owner gate via
  `AskUserQuestion`: the landing method — direct-merge vs PR-for-CI vs
  review-first → owner chose direct-merge, the Stage-3 precedent).
- **Landed:** stashed the 1B stub (+ `.DS_Store`), checked out `master`,
  merged `--no-ff` (merge commit **`ff0ca8fd`**, “Merge issue \#103
  Stage 4 (roxygen markup unification) into master”), pushed `master` to
  origin (`87abc0fc..ff0ca8fd`), popped the stub, deleted the merged
  local-only branch. `master` == `origin/master`.
- **No re-gate (proven, not assumed):** the merged tree is exactly
  S251’s two commits (`002b77c9` + `3f8c1865`) — `master` never moved
  since the branch forked, so S251’s local `--as-cran` 0/0/2
  certification covers the exact landed commits (Learning 233 §2).
  Direct-merge has no CI, so confirmed the merge brought the converted
  content with a cheap deterministic sanity check on `master`: backtick
  chars on `#'` lines = 15 (the 6 intended exclusions, == S251’s
  105→15), `\code{Pedigree}` = 25, `\code{kValue}` = 10, and the
  deferred `get_and_or_list.R:10` defect still present (correctly not
  folded in).
- **Stages 1–4 of issue \#103 are now all on `master`.** Learning 238
  added to `PROJECT_LEARNINGS.md`. Next stage (owner’s pick): Stage 5
  (import conversion, Finding 7) — NOT rendered-neutral, can affect
  masking/dispatch → needs a full `--as-cran` + tests +
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  smoke.

### 2026-06-30 — issue \#103 Stage 4 (roxygen markup unification, Finding 4) (Session 251)

- **Deliverable (owner pick = “stage 4”; sweep approved via
  `AskUserQuestion`):** issue \#103 **Stage 4 — markup unification
  (audit Finding 4)**: convert stray roxygen markup backticks to
  `\code{}`. **REFACTOR-class doc-markup — no R logic / NAMESPACE /
  behavior change; rendered docs unchanged; TDD RED/GREEN N/A; 0
  corrections / 0 overrides** (2 owner gates via `AskUserQuestion`:
  apply-the-sweep, and defer the newly-found `get_and_or_list` defect).
  **DONE + VERIFIED on branch `issue103-stage4-markup` (code commit
  `002b77c9` + this close-out commit); landing is the owner’s next
  decision.**
- **The change:** 45 backtick spans → `\code{}` across **30 R/ files**
  (`` `Pedigree` `` ×25 in `@param ped`; `` `kValue` `` ×10; the 4
  status codes in `convertStatusCodes`; `` `set.seed` ``; `` `"F"` ``
  beside `\code{"M"}`; and 4 in the `gatedSeed` `@noRd` block).
  **Rendered-doc-neutral:** `markdown = TRUE` (DESCRIPTION:81, no
  `@noMd`) already expands `` `x` `` → `\code{x}` in the `.Rd`, so
  re-`document()` left **26 of 30** `.Rd` byte-identical; the **4**
  files whose source lines crossed 80 chars after the +5-char `\code{}`
  expansion were reflowed (minimal non-cascading word-moves) and their
  `.Rd` differ **only by intra-paragraph line breaks** (Rd fills
  paragraphs → rendered text identical, proven by whitespace-normalized
  comparison).
- **Excluded (6 occurrences, left untouched):** backtick-quoted
  non-syntactic R names *inside* `@examples` (`checkChangedColsLst`
  `` `si re` ``, `makeRelationClassesTable` `` `Relationship Class` ``,
  `geneDrop`/`getGVGenotype` `` `n` `` in `##` example comments); the
  inline-R lifecycle badge `getPotentialParents`
  `` `r lifecycle::badge('experimental')` `` (converting would break
  it); and the broken `` `word' `` typographic quotes in
  `get_and_or_list` (render garbled as `\verb{and' or }…` — a
  newly-found rendered defect, **deferred per owner** to a separate
  fix).
- **Verify (deterministic, firsthand):** backtick count **105 → 15**
  (exactly the 6 exclusions); **word-sequence projection = 0 drift**
  across all 30 files (canonicalize `` `x` ``/`\code{x}` + collapse
  whitespace, HEAD == working — no word dropped/added/reordered);
  **`man/` drift** = 26 byte-identical + 4 whitespace-only (normalized
  comparison identical); `lintr::lint_package()` = **0**;
  `spell_check_package` = **CLEAN**; **`R CMD check --as-cran` =
  `Status: 2 NOTEs` (0/0/2)** with Rd files / Rd metadata / Rd line
  widths / Rd cross-references / code-documentation mismatches / Rd /
  examples / tests all **OK**.
- Learning 237 added to `PROJECT_LEARNINGS.md`. Stages 1–4 of \#103 are
  now complete (1–3 landed on `master`; Stage 4 on branch, landing
  owner-gated).

### 2026-06-30 — merge PR \#105 + issue \#103 Stage 3 (roxygen block-order normalization) (Session 250)

- **Deliverable (owner: “merge PR \#105; work on \#103 this
  session”):** (1) merged **PR \#105** to land issue \#103 **Stage 2**
  (copyright-placement sweep) on `master` (merge commit `12c7c353`),
  synced local `master`, deleted the merged Stage 2 branch; (2) issue
  \#103 **Stage 3 — block-order normalization (audit Finding 2)**: a
  deterministic R transform reordered roxygen tags to the standard block
  order across **194 files / 206 blocks**. **REFACTOR-class
  doc-structure — no behavior change, no rendered-doc change; TDD
  RED/GREEN N/A; 0 corrections / 0 overrides** (1 owner gate via
  `AskUserQuestion`: the `@examples`/`@export` order — audit was
  self-contradictory; owner chose `@examples` LAST).
- **The transform:** per block, keep the preamble (title + description
  prose) verbatim, split the tag region into tag-chunks (a `@tag` line +
  its continuation `#'` lines), and stable-sort the chunks by a
  canonical key — `@details`/`@usage` → `@param` (signature order) →
  `@return` → `@seealso`/`@references`/`@author` (last three keep source
  order) → `@importFrom` (grouped) →
  `@export`/`@noRd`/`@keywords`/`@rdname`/`@method` → `@examples`
  (LAST). The headline change is moving `@return` after `@param` (199
  blocks).
- **Edge cases handled:** `@description`/`@usage` kept early; `data.R`
  dataset docs unchanged (already ordered); kinship.R
  `@author`/`@references` (interleaved across `# nolint` comment splits)
  preserved in source order via equal sort keys — the one file that
  drifted on the first pass, fixed before commit.
- **Verified (deterministic + adversarial):** zero `man/` drift after
  `devtools::document()` (rendered docs byte-identical); zero
  code/plain-comment change (projection diff); `lintr::lint_package()` =
  0; `spell_check_package` clean; re-characterization shows 0 residual
  block-order deviations; **`R CMD check --as-cran` = `Status: 2 NOTEs`
  (0/0/2)** with Rd files / cross-references / code-documentation
  mismatches / Rd all OK; a 9-agent adversarial review of the 45 changed
  `@noRd` diffs (no `.Rd` to verify) found 0 defects.
- **Keyword-safe** (“Part of \#103. Stage 3 of 8”) so the landing did
  not auto-close the multi-stage tracker. Stage 3 transform `fb9a92ab`;
  landing method owner-gated (`AskUserQuestion`) -\> owner chose
  **direct-merge** -\> landed on `master` via merge commit `72f5391e`,
  Stage 3 branch deleted. Stages 1-3 of 8 now on `master`.

### 2026-06-29 — open PR \#105 for CI validation: issue \#103 Stage 2 landing (Session 249)

- **Deliverable (owner pick = “1” = Land Stage 2; landing method = “open
  a PR for CI” via `AskUserQuestion`):** land the S248 Stage-2
  copyright-placement sweep by pushing branch
  `issue103-stage2-copyright-placement` to origin and opening **PR
  \#105** against `master` for full CI validation. **Landing/process
  action on already-locally-verified doc-structure work — no R-logic
  change; TDD RED/GREEN N/A; 0 corrections / 0 overrides** (1 owner gate
  via `AskUserQuestion`: the landing method — PR vs direct-merge vs
  review-first).
- **CI GREEN 10/10 on the FIRST run** — `lint` PASS (3m44s), the full
  5-platform R-CMD-check matrix (macOS / Windows / Ubuntu
  release+devel+oldrel-1) PASS, pkgdown / test-coverage /
  codecov{patch,project} PASS. `gh pr view 105`: state OPEN, mergeable
  MERGEABLE, mergeStateStatus CLEAN. No Stage-1-style lint regression —
  S248’s post-sweep `lintr::lint_package()` = 0 held end-to-end
  (Learning 235), so the line-shifting sweep did not trip a `.lintr`
  line-keyed exclusion.
- **Keyword-safe PR body** (“Part of \#103. Stage 2 of 8 — does **not**
  close the tracking issue”) so the eventual merge will not auto-close
  the multi-stage harmonization tracker.
- **Merge is owner-gated** (a future session, matching the S246→S247
  Stage-1 split). After merge, the next \#103 stage per the audit §6
  roadmap is Stage 3 (block-order normalization, Finding 2).
- Branch pushed; `master` untouched (== origin/master, no local-ahead
  drift). Process docs (this entry, Learning 235, the S249 handoff) are
  committed on the branch and ride the PR.

### 2026-06-29 — copyright-placement sweep: issue \#103 Stage 2 (Session 248)

- **Deliverable (owner pick = “stage 2”; full-sweep approved via
  `AskUserQuestion`):** the copyright-placement sweep from the S244
  audit (Finding 8) — move the `## Copyright(c) 2017-2026 R. Mark Sharp`
  / `## This file is part of nprcgenekeepr` pair from inside each
  roxygen block to the top of the file, above the first `#'` line with
  one blank separator (the `getSpeciesGestation.R` exemplar).
  **REFACTOR-class doc-structure — no behavior change, no rendered-doc
  change; TDD RED/GREEN N/A; 0 corrections / 0 overrides** (1 owner
  gate: full-sweep vs sample-first).
- **Scope:** 203 of 225 R files moved (22 already correct, skipped); the
  2 double-pair files (`autoIdFormat.R`, `makeGroupNum.R`) de-duplicated
  to one pair at top; 9 `mod*.R` get the pair above their `#` section
  banner; `flagOverriddenRelationships.R` gains the previously-missing
  separator blank. All 225 R files now place the copyright above the
  block.
- **Verified (deterministic, whole-corpus):** `devtools::document()` →
  **ZERO `man/` drift** (rendered docs byte-identical — roxygen ignores
  `##`); **zero R-code-line changes** across all 204 files
  (comment-stripped projection diff); `lintr::lint_package()` = **0**;
  `spell_check_package` **clean**; `R CMD check --as-cran` = **0 errors
  / 0 warnings / 2 documented-false-positive NOTEs**;
  NAMESPACE/DESCRIPTION unchanged.
- **Branch `issue103-stage2-copyright-placement`** (code commit
  `af08b5bf`), **UNPUSHED** — landing (PR / merge) owner-gated, matching
  the Stage 1 precedent. Learning 234 added.

### 2026-06-29 — merge PR \#104: land Stage 1 of issue \#103 onto `master` (Session 247)

- **Deliverable (owner pick = “merge PR \#104”):** merge the
  CI-validated PR \#104 (issue \#103 Stage 1 — defects D1–D8 plus the
  `.lintr` whole-file-exclusion fix) into `master`, sync local `master`
  to origin, and delete the merged branch `issue103-stage1-defects`.
  **Landing/process action on already-CI-green doc work — no R-logic
  change; TDD RED/GREEN N/A; 0 corrections / 0 overrides.**
- **Merge strategy = merge commit**, matching the repo’s precedent for
  landing `R/`+`man/` work via PR (`a4de6a84 Merge pull request #101`);
  preserves the well-formed S245/S246 commits. Result: merge commit
  `9b512b1e` (parents `170324d5` master + `3beaf2bc` branch tip);
  `gh pr view 104` → **MERGED**.
- **No local re-gate needed:** `git diff 9b512b1e 3beaf2bc` is **empty**
  — master never moved after the branch forked, so the merged tree is
  byte-identical to the tip CI validated **10/10** green (full
  5-platform R-CMD-check matrix + lint + pkgdown + coverage). That CI
  run satisfies the “`R/`+`man/` ship → re-gate” rule; re-running the
  local `--as-cran` gate would only re-certify an identical tree.
- **Branch cleanup:** `gh pr merge --merge --delete-branch` deleted both
  the local and remote branch; confirmed the remote branch is gone
  (`gh api .../branches/issue103-stage1-defects` → 404) and pruned the
  stale remote-tracking ref with `git fetch --prune`. Local `master` ==
  origin/master == `9b512b1e`.
- **Procedure note:** the mandatory Phase-1B stub written to
  `SESSION_NOTES.md` was an uncommitted edit on the branch being merged;
  since that file differs between branch and `master`, it was stashed
  before the merge and popped back onto `master` afterward (clean
  apply). See `PROJECT_LEARNINGS.md` Learning 233.

### 2026-06-29 — open PR \#104 for CI validation of Stage 1 + fix a CI-surfaced lint regression (Session 246)

- **Deliverable (issue \#103, Stage 1, owner pick = “open a PR for CI
  validation”):** push branch `issue103-stage1-defects` and open **PR
  \#104** against `master` so the full CI suite validates the S245 D1–D8
  `R/`+`man/` edits. **Landing/process action + a 1-line `.lintr` fix —
  no R-logic change; TDD RED/GREEN N/A; 0 corrections / 0 overrides** (1
  owner gate: the lint-fix approach). PR body is keyword-safe (“Part of
  \#103”) so the merge will not auto-close the multi-stage tracking
  issue.
- **CI caught a genuine Stage-1-introduced lint regression that the
  local `--as-cran` gate could not.** First CI run: the R-CMD-check
  matrix passed on all 5 platforms (macOS/Windows release, Ubuntu
  devel/release/oldrel-1) plus pkgdown/test-coverage/codecov, but
  **`lint` failed** — `commented_code_linter` at
  `R/makeGeneticDiversityDashboard.R:11`. `master` lint is green and the
  prior `normalize-copyright-headers` PR passed lint, so this PR was the
  first lint failure → the regression was Stage 1’s.
- **Root cause:** `.lintr` excluded that file by a hardcoded line range
  `12L:55L`, calibrated to its dead, fully-commented function body (the
  file has zero live code). S245’s D7 deleted 3 dead
  `@importFrom`/`@import` lines *above* the body, shifting it up 3 lines
  so the flagged line moved from 14 to 11 — outside the exclusion
  window. The local `--as-cran` gate does **not** run
  `lintr::lint_package()` (lint is a separate CI workflow), so the
  regression rode in silently.
- **Fix (owner chose “exclude whole file”):** changed
  `"R/makeGeneticDiversityDashboard.R" = 12L:55L` →
  `"R/makeGeneticDiversityDashboard.R"` (unnamed whole-file exclusion,
  removing the brittle line-number coupling). `lintr::lint_package(".")`
  = **0 lints** locally; committed `fc188d38`, pushed.
- **Result:** second CI run = **10/10 checks PASS**; `gh pr view 104`
  reports **state OPEN, mergeable MERGEABLE, mergeStateStatus CLEAN**.
  The merge/landing decision is the owner’s. The full cross-platform
  R-CMD-check matrix + lint + pkgdown + coverage being green is a
  stronger certification than the local gate alone.

### 2026-06-29 — roxygen2 doc defects D1–D8: Stage 1 implementation (Session 245)

- **Deliverable (issue \#103, Stage 1, owner pick):** fix the **8
  classes of genuine rendered-doc DEFECT** (D1–D8) surfaced by the S244
  audit (`docs/audits/ROXYGEN_HARMONIZATION_AUDIT_2026-06-29.md` §4),
  regenerate `man/`, re-clear the `--as-cran` gate. **REFACTOR-class
  doc-correctness — no behavior change; TDD RED/GREEN N/A; 0 corrections
  / 0 overrides** (1 owner gate: D2 approach = “delete the legacy
  package-doc file”). Branch `issue103-stage1-defects` (landing
  owner-gated).
- **The fixes:** D1 removed `calcGU.R`’s malformed
  `@description \{Genome Uniqueness Functions\}\{\}` (it had overridden
  ~34 lines of real description); D2 deleted the legacy
  duplicate-`_PACKAGE` file `R/nprcgenekeeper.R` (roxygen had merged it
  into `nprcgenekeepr-package.Rd`, injecting the wrong title +
  escaped-brace `\seealso` garbage) — the regenerated package page now
  has the CRAN-standard auto title, a clean description, both
  `\alias{nprcgenekeepr}` + `\alias{nprcgenekeepr-package}` (so
  [`?nprcgenekeepr`](https://github.com/rmsharp/nprcgenekeepr/reference/nprcgenekeepr-package.md)
  still resolves), and clean “Useful links”; D3 converted **every**
  escaped-brace `\item\{X\} \{Y\}` pseudo-list to real Rd
  `\item \code{X} ...`; D4 removed the bogus `\code{candidates}`
  reference from three `@param ped` blocks; D5 corrected wrong
  copy-pasted `@return` text (`findPedigreeNumber` “generation numbers”
  → pedigree/family-group numbers; `getOffspring` “ancestor IDs” →
  offspring IDs); D6 fixed six title typos (`obfucate`→`obfuscate`,
  `portential`→`potential`, “an file”→“a file”, “a empty”→“an empty”,
  “names and into”→“names into”); D7 removed dead
  `@importFrom gplots`/`@import RColorBrewer`/`@importFrom grDevices` on
  a commented-out function (zero NAMESPACE impact — those pkgs are
  absent from DESCRIPTION + NAMESPACE, and the block had no code object
  to attach to); D8 repaired four roxygen blocks broken by bare non-`#'`
  lines (`geneDrop`, `kinshipMatrixToKValues`, `makeCEPH`, stray `#` in
  `kinshipMatricesToKValues`).
- **D3 scope was larger than the audit enumerated.** The audit cited 6
  files; grepping the whole tree for the escaped-brace pattern found
  three more sites — `calcGU.R`’s AlleleTable list, the **uncited**
  `getRequiredCols.R`, and **four additional lists inside
  `qcStudbook.R`** beyond the one column list the audit pointed at. All
  fixed; a full-tree rescan shows **zero** escaped-brace patterns
  remaining in `R/` or `man/`. (8 files total carried D3.)
- **Spelling:** `inst/WORDLIST` held the *old* typos (`obfucateDate`,
  `obfucateId`, `portential`) — added previously to pass spell-check on
  the typo’d titles; surgically replaced the two function-name entries
  with the corrected spelling and dropped `portential` (never
  `update_wordlist` — \[\[avoid-reconcile-tools-on-curated-files\]\]).
  `spell_check_package` now **CLEAN**.
- **Verification:** `devtools::document()` ran without warnings;
  NAMESPACE unchanged; firsthand-confirmed every fix against the
  regenerated `.Rd` (the rendered output is the proof); **`--as-cran`
  gate GREEN `Status: 2 NOTEs` = 0/0/2** (the two documented
  false-positives — incoming-feasibility “New submission”, local
  HTML-Tidy), with
  `Rd files OK / Rd cross-references OK / code-documentation mismatches OK / Rd \usage OK`.
  Scope: 23 `R/` (one deleted) + 21 `man/` (one deleted,
  `nprcgenekeepr.Rd`) + `inst/WORDLIST`. **`R/`+`man/` ship → any later
  stage re-stales the gate.**

### 2026-06-29 — roxygen2 documentation harmonization: analysis + recommendation (Session 244)

- **Deliverable (issue \#102, owner pick):** a written **assessment** of
  roxygen2 documentation-block consistency across all 226 `R/` files,
  with a single recommended harmonized convention — **analysis only; the
  edits are a separate follow-on session**, per the issue’s own scoping.
  Output: `docs/audits/ROXYGEN_HARMONIZATION_AUDIT_2026-06-29.md`
  (`.Rbuildignore`d `^docs$`, does not ship → `--as-cran` gate
  untouched). **AUDIT-class — TDD code-phases N/A; 0 corrections / 0
  overrides.**
- **Method:** authoritative grep counts over all 226 files → a 15-agent
  parallel deep-read (one structured record per file) → synthesis → an
  **independent adversarial verification** pass → firsthand
  re-verification of every headline claim. The adversarial pass caught a
  material error in my own ground-truth count (examples coverage) which
  was corrected firsthand before the report was written.
- **Headline:** the package is **well-documented**; the problem is style
  **consistency**, framed as a two-era convergence (legacy vs. an
  already-emerging modern house style). 8 harmonization dimensions (1
  already-consistent, 5 moderate, 2 low) + **8 classes of genuine
  rendered-doc DEFECT** worth fixing regardless (e.g. `calcGU.R:42` a
  malformed explicit `@description` that overrides ~34 lines of real
  description in `man/calcGU.Rd`; a duplicate `_PACKAGE` block;
  escaped-brace pseudo-Rd lists; `@param` documenting a nonexistent
  `candidates` arg; title typos).
- **Corrected finding:** examples coverage is **145/167** exported
  (~87%), not the initially-miscounted 166/167 — the 22 gaps cluster in
  Shiny `mod*` modules + app entry points (a defensible exemption) plus
  ~7 callable utilities (a real gap). Reframed as a moderate finding
  with a stated carve-out.
- **Recommendation incorporates owner CRAN guidance:** standardize on
  `@importFrom` over `@import` (8 of 10 holdouts convert mechanically;
  `shiny`/`Matrix` are a verified judgment call).
- **Tracker (owner-directed):** posted the assessment as a comment on
  \#102; **closed \#102** (analysis-only deliverable complete) and
  opened **\#103** to track the staged, defects-first implementation
  (deferred until after CRAN resubmission).

### 2026-06-29 — Normalize copyright headers + fix roxygen man-page leak (Session 243)

- **Deliverable (PIVOTED mid-session; owner-ratified “Full
  normalization”):** oriented for CRAN Phase 5b, but while verifying
  prereqs the owner observed the copyright notices had not been updated.
  A firsthand audit found two problems — (1) a **CRAN-facing
  rendered-doc leak**: 25 R files wrote the copyright as roxygen (`#'`),
  so it leaked into 22 man pages, and in 2 exported functions
  (`getSpeciesGestation`, `getSpeciesMinBreedingAge`) it had become the
  man-page `\title{}`; (2) **stale / inconsistent years**: 197 `R/`
  headers below `2017-2026` (ranging 2021–2026, one malformed bare
  `2026`), plus 16 `R/` files with no header. Treated the observation as
  a question (\[\[observation-vs-decision\]\], FM \#23) — audited, then
  `AskUserQuestion` ratified scope. **REFACTOR-class docs/metadata — no
  behavior change; TDD RED/GREEN N/A. 0 corrections / 0 overrides.**
- **The fix (uniform, dry-run-verified transform):** converted every
  `#'` copyright/part-of line to a plain `##` comment — turning the
  leaking “Pattern B” into the dominant non-leaking “Pattern A” (a `##`
  line sandwiched in a roxygen block is silently ignored by roxygen2) —
  bumped every year to `2017-2026` (matching `LICENSE` / `LICENSE.md`),
  added the uniform 2-line header to the 16 bare files, and regenerated
  `man/`. Dry-ran the perl transform on all 4 representative header
  shapes before applying.
- **The leak was structural, not cosmetic.** Removing it not only
  restored the 2 hijacked titles but also moved ~17 functions’ real
  description text out of a spurious `\details{}` block back into
  `\description{}` (the leaked copyright + blank line had displaced the
  first paragraph), and corrected 3 module descriptions — a genuine
  man-page-quality improvement surfaced by the independent audit.
- **Scope:** 215 `R/` + 195 `tests/` + 3 `data-raw/` source files
  (copyright/part-of lines only — diff-cleanliness confirmed zero code
  lines changed) + 22 regenerated `man/*.Rd`. Two separable commits:
  `0c77f4d1` (`R/` + `man/`, the CRAN-relevant core) and `d7556d5e`
  (`tests/` + `data-raw/`, whole-package consistency).
- **Verification:** zero `#'` copyright/part-of lines remain; all 429
  copyright lines now read `## Copyright(c) 2017-2026 R. Mark Sharp`;
  zero copyright notices remain in `man/`; NAMESPACE unchanged; suite
  **0/0** (7 baseline warnings, 169 skips); **re-gate GREEN
  `Status: 2 NOTEs` = 0/0/2** (the two documented false-positives;
  `00check.log` “code/documentation mismatches … OK”). **Independent
  blind adversarial audit = PASS on all checks A–I**, decisively
  confirmed by re-running `devtools::document()` → empty
  `git status man/` (zero drift).
- **CRAN Phase 5b deferred** to a follow-up session on this corrected,
  re-gated tree. Prereqs verified this session:
  `master==origin/master`@2.0.0; `devtools`/`rhub`/`gitcreds` present;
  **the GitHub PAT is already satisfied** (the `gh` token carries
  `repo`+`workflow` scopes — corrects the carried “PAT still needed”);
  only owner-confirmable gap is an unfiltered `rmsharp@me.com`. Branch
  `normalize-copyright-headers` is unpushed — landing is owner-gated.
  See `PROJECT_LEARNINGS.md` Learning 229.

### 2026-06-29 — Refresh the stale CRAN Phase 5b runbook + reconcile cran-comments NOTE 1 (Session 242)

- **Deliverable (owner pick — option A “Refresh runbook +
  cran-comments”):** docs-only Phase 5b readiness prep so the owner’s
  outward CRAN run is frictionless. The core Phase 5b steps (win-builder
  ×3, R-hub v2, `submit_cran()`) remain **owner-run** (outward-facing;
  HARD STOP) — this session corrected the local artifacts they depend
  on. **Docs-only REFACTOR-class — no behavior change; TDD RED/GREEN
  N/A. 0 corrections / 0 overrides.**
- **`docs/planning/cran-2.0.0-phase5-runbook.md` was materially stale
  and is now refreshed** (10 surgical edits): submission tooling
  **“absent” → “installed”** (verified `devtools`/`rhub`/`gitcreds` all
  load; install lines commented out as fresh-clone-only); the obsolete
  R-hub branch caveat — the long-gone `add-methodology` branch,
  `origin/master@1.1.0.9000`, “PR \#53”, “open a new PR to master” —
  replaced with verified current reality: R-hub checks **`master`** (the
  2.0.0 default branch, `0 0` ahead/behind `origin/master`), no push or
  branch gymnastics; §1’s stale “unchanged since S134” gate note → the
  current S240/S241 GREEN gate; §4.2 now names **GNU `aspell`** as
  CRAN’s checker. Old wording explicitly flagged as obsolete so it is
  not mistaken for live instruction.
- **`cran-comments.md` NOTE 1 reconciled** against the actual local
  incoming-feasibility spell output: dropped the unverified
  `"studbooks"` (in DESCRIPTION but not flagged by the speller), added
  the prominent flagged species name `"Macaca mulatta"`. Final example
  set = the firsthand-verified flagged words
  `Raboin, EHR, LabKey, kinships, Macaca, mulatta` — exactly what
  `utils::aspell(filter="dcf", program="hunspell")` reports (the same
  call `R CMD check` makes; the `<URL>` is correctly filtered out). Kept
  the “for example” hedge; the authoritative list still comes from
  win-builder.
- **No re-gate needed:** both files are `.Rbuildignore`d
  (`cran-comments.md` line 10, `docs` line 15), so they do not ship in
  the tarball and the S241 `--as-cran` gate (0/0/2) is untouched — a
  clean contrast to S241, where `README.md` *does* ship.
- **Independently audited:** a fresh adversarial agent re-verified every
  factual claim (tooling presence, branch sync `0 0`, `rhub.yaml`
  exists, the 6-word spell set, internal consistency) against the live
  repo — **PASS on all six checks, no misdirecting defects.** Two minor
  polish items from the audit applied (`~74` → `dozens`; §3 push
  clarified as optional housekeeping).

### 2026-06-29 — Fix the 3 README badge defects surfaced by the S240 audit (Session 241)

- **Deliverable (owner pick):** fix the three `README.Rmd` badge defects
  S240 surfaced and deliberately left as a separate deliverable — `:18`
  CRAN grand-total downloads pointed at the wrong package
  (`grand-total/kableExtra` → `grand-total/nprcgenekeepr`); `:19`
  malformed markdown (stray leading `[`) removed; `:20` bogus
  prefix-only DOI (`doi-10.32614` / `doi.org/10.32614`) → the canonical
  CRAN package DOI. Then `devtools::build_readme()` to regenerate
  `README.md`. **Docs-only REFACTOR-class — no behavior change; TDD
  RED/GREEN N/A. 0 corrections / 0 overrides.**
- **DOI = owner decision.** The DOI target was the one genuine fork
  (CRAN-package-DOI / cited-paper-DOI / drop-the-badge), posed as an
  `AskUserQuestion` (\[\[observation-vs-decision\]\]); owner chose the
  canonical CRAN package DOI `10.32614/CRAN.package.nprcgenekeepr`. The
  badge image encodes the slash as `%2F` (shields.io static-badge
  requirement); the link target uses the plain DOI and resolves HTTP 200
  → the CRAN package page.
- **Verify (firsthand — the fix-side of S240’s audit method):** fetched
  each changed badge SVG and read its `aria-label` — grand-total now
  renders “CRAN downloads 13K” (not kableExtra’s 8.7M); the DOI badge
  renders “doi: 10.32614/CRAN.package.nprcgenekeepr”; the DOI link
  resolves 200 → CRAN page. `README.md` regenerated from source; the
  diff is exactly the 3 badges + the expected `build_readme()`
  version-date re-stamp (`(2026-06-19)` → `(2026-06-29)`); the YAML
  front-matter `date:` was left untouched.
- **Re-cleared the CRAN gate** (README.md ships in the tarball, so a
  badge change re-stales the S240 gate — Learning 226):
  `R CMD build .` + `R CMD check --as-cran --timings` =
  `Status: 2 NOTEs` = **0/0/2**, both documented false-positives; no URL
  NOTE (`grep URL|doi|cranlogs|shields|kableExtra 00check.log` empty).
  Build artifacts removed; close-out docs to master. See
  `PROJECT_LEARNINGS.md` Learning 227.

### 2026-06-29 — Re-establish the local CRAN `--as-cran` gate on current master (Session 240)

- **Deliverable (owner pick — “walk through the steps that remain” for
  CRAN → “run the local re-gate now”):** re-ran `R CMD build` +
  `R CMD check --as-cran --timings` on current `master` (2.0.0) because
  the documented S134 `0/0/2` gate certified a tree ~74 commits stale
  (kinship-overrides + FG-SE validation + S238 lint + S239 doc-tag strip
  all landed after it, touching most of `R/`, all `man/`, NEWS, `data/`,
  ~50 test files, and the vignettes). **VERIFICATION session — TDD
  code-phases N/A. 0 corrections / 0 overrides.**
- **Result: GREEN.** `Status: 2 NOTEs` = 0 ERROR / 0 WARNING / 2 NOTE,
  both the documented false-positives (CRAN incoming-feasibility
  “archived / new submission”; local HTML-tidy+V8 manual note). No new
  notes — the S134 gate still holds on current master.
- **Timing (the archival cause) intact but grew with the suite:**
  examples 19→22s, donttest 19→22s, tests 43→74s (suite 1853→3173
  assertions), vignette rebuild 16→24s. Still inside CRAN limits; Phase
  5b (win-builder/R-hub on slower hardware) remains the true
  timing-retirement step.
- **Surfaced (separate deliverable, not fixed) — 3 README badge
  defects** (CRAN-relevant since `README.md` ships): `README.Rmd:18`
  CRAN grand-total downloads points to the wrong package (`kableExtra`);
  `:19` malformed markdown (stray leading `[`); `:20` bogus prefix-only
  DOI (`10.32614`). Fixes + the owner’s DOI decision documented in
  `SESSION_NOTES.md`.
- **No package change** (verification only); build artifacts removed;
  close-out docs to master. See `PROJECT_LEARNINGS.md` Learning 226.

### 2026-06-29 — Remove development-process tags from published documentation (Session 239)

- **Deliverable (owner request):** the owner observed that user-facing
  documentation leaked references to *how the code was developed* —
  GitHub issue numbers and “Slice N” vertical-slice jargon (e.g. “issue
  \#82, Slice 1”) — and asked whether their inclusion could be defended.
  Treated as a question, not an instruction
  (\[\[observation-vs-decision\]\], FM \#23): inventoried every
  reference firsthand, gave an honest defend/concede analysis, then
  ratified scope via `AskUserQuestion` = **“Published surfaces only.”**
  **REFACTOR-class docs-only — no behavior change; TDD RED/GREEN N/A.**
  **0 corrections / 0 overrides** (1 audit-surfaced reword refinement,
  self-fixed).
- **The load-bearing scope distinction — PUBLISHED vs INTERNAL.** A
  roxygen `#'` block renders to a man page (and the pkgdown reference /
  `?fn`) only when the function is exported / `@`-documented; a `@noRd`
  block is stripped at build, so it is maintainer-only — the same
  category as a plain source comment (extends S238 gotcha \#2 / Learning
  224(3)). Of 23 R files carrying issue/slice tags, **7 are `@noRd`**
  (`applyKinshipOverridesToMatrix`, `flagOverriddenRelationships`,
  `prepareKinshipOverrides`, `classifyParentage`,
  `getSpeciesOverridesPath`, `correctUnknownParentMeanKinship`,
  `checkFgDegeneracy`) → **left untouched**; **16 render to man pages**
  → cleaned + `man/` regenerated.
- **Kept (out of scope, by the ratified choice):** the 7 `@noRd`
  docstrings, the 36 plain `#` source comments (maintainer breadcrumbs),
  and **issue NUMBERS in NEWS** (standard R changelog convention) — only
  “slice 1/2/3” removed from NEWS.
- **Reworded for meaning, not blind-deleted:** dropped bare “(issue
  \#NN)” parentheticals; kept policy names (“decline-to-credit policy”,
  dropped “issue \#76”); reworded a now-dangling antecedent (`data.R`
  “the remaining part of that issue” → “a separate planned
  enhancement”); kept the `compute → validate → surface` concept in the
  fg-se article while dropping “the issue \#82 plan (Slice 2 of three)”;
  named the gu de-inflation by mechanism (`gu = 0`) instead of “issue
  \#76”.
- **Verify:** rendered `man/` + 3 pkgdown articles + NEWS = **0**
  issue/slice tags; `devtools::check(vignettes=FALSE)` **0/0/0**; full
  suite **3173/0/0** (7 baseline-noise warnings); `spell_check_package`
  clean; lint **0** across the 16 files; all 16 `man/*.Rd` parse via
  [`tools::parse_Rd()`](https://rdrr.io/r/tools/parse_Rd.html),
  re-`document()` shows zero drift. An independent **4-agent adversarial
  audit** (`wf_b3fff352-1be`) confirmed no leaks / no over-reach / no
  broken markup.
- **Audit-surfaced refinement (self-fixed):** the fg-se article’s
  “ratified in the issue \#82 plan” → “set for this validation study”
  softened the *pre-registration* nuance (bands fixed in advance — a
  calibration-credibility point); reworded to “specified in advance for
  this validation study”.
- **Self-inflicted + fixed:** renaming the `simulatedKValues.Rmd`
  footnote label to `[^transloc]` tripped `spell_check` (it tokenizes
  pure-letter labels; the old digit-bearing `issue28` slipped through) →
  used the real word `[^location]`.
- **Surfaced for a possible future pass (NOT done):**
  `inst/extdata/example_nprcgenekeepr_config:55` carries “(issue \#73
  Part 2)” in a user-copyable config-template comment — matches the
  out-of-scope source-comment / issue-number KEEP pattern, so left
  as-is.
- **5 commits on branch `docs-strip-process-tags`** (`f7cc1f6a` roxygen,
  `0ee62a2a` articles+NEWS.Rmd, `3d2e6dda` regen man+NEWS.md, `cb18fefa`
  spell-safe label, `e94f6604` audit-nuance fix). **Outward push/PR is
  owner-gated** (not pushed). Carried as applied:
  \[\[observation-vs-decision\]\],
  \[\[consult-project-source-of-truth\]\],
  \[\[avoid-new-lints-r-package\]\],
  \[\[avoid-reconcile-tools-on-curated-files\]\],
  \[\[edit-files-in-reverse-line-order\]\],
  \[\[push-close-out-docs-to-origin\]\]. (Learning 225.)

### 2026-06-29 — Systematic whole-package lint pass: clear the standing lint-CI red (Session 238)

- **Deliverable (owner pick):** a systematic whole-package lint pass
  clearing the standing `lint`-CI red (the `lint.yaml` job, red for many
  sessions; it errors because `LINTR_ERROR_ON_LINT: true` turns any lint
  into a non-zero exit). **REFACTOR-class cleanup — style / readability
  only, no behavior change**; the existing test suite + the `lintr` gate
  are the safety net (no new RED). Remaining open GitHub issues are
  explicitly deferred until after CRAN resubmission (owner directive).
  **Strict-TDD: REFACTOR-class, code-phases RED/GREEN N/A.** **0
  corrections / 0 overrides.**
- **Artifact vs. real (the load-bearing distinction):** `lint_package()`
  reports **74** lints locally, but **31** are `object_usage_linter` “no
  visible global function definition for ” artifacts that vanish when
  the package namespace resolves
  ([`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  → object_usage 0) and never appear in CI (which installs the package
  via `local::.`). Confirmed against the actual `lint.yaml` CI log: it
  lists exactly the **43 real** lints and zero object_usage. The 43 are
  what was fixed; the 31 artifacts were left untouched (memory:
  avoid-new-lints-r-package).
- **The 43 fixes (all behavior-preserving), 10 files, 3 lint-batch
  commits + 1 man regen:** line_length (22) reflowed (long `sprintf`
  format strings split via `paste0` or bound to a variable, printed
  output unchanged); `paste(., collapse = ", ")` → `toString(.)` (5);
  `any(is.na(x))` → `anyNA(x)` (1); implicit `0`/`2` → `0L`/`2L` (5);
  `any(!x)` → `!all(x)` (1); `gsub("\r", …)` → `fixed = TRUE` (1);
  `nonportable_path` →
  [`file.path()`](https://rdrr.io/r/base/file.path.html) (3);
  commented-code prose (1); `data-raw/fgSEValidation.R`
  [`source()`](https://rdrr.io/r/base/source.html)-test-helpers +
  `system.time(x <- …)` timing idioms wrapped in justified `# nolint`
  ranges (owner-confirmed — splitting either would be wrong: sourcing
  test helpers is correct, and `system.time(x <- …)` both times and
  captures an ~11-min study).
- **Files:** `R/{calcFEFG,calcFG,calcFGSE,reportGV,modSummaryStats}.R`
  (batch 1 `23160dc5`: wraps + one `0L`);
  `R/{checkKinshipOverrides,checkFgDegeneracy,applyKinshipOverrides,applyKinshipOverridesToMatrix}.R`
  (batch 2 `bec858e9`: style swaps); `data-raw/fgSEValidation.R` (batch
  3 `17b92321`); regenerated
  `man/{applyKinshipOverrides,calcFEFG,calcFG,calcFGSE,modSummaryStatsServer,reportGV}.Rd`
  (`7e30a01f`; whitespace-only reflow of exported-function roxygen;
  rendered help unchanged).
- **Verify:** whole-package `lint_package()` (package loaded) **0 total
  lints**; targeted tests green (calcFEFG 15 / calcFG 9 / calcFGSE 20 /
  applyKinshipOverrides 12 / checkKinshipOverrides 11); full suite
  **3173 pass / 0 fail / 0 error** (7 warnings = documented baseline
  noise: 5 `test_modPyramid`, 2 `test_gvaConvergence_kinshipOverrides`
  PSD-bound); `data-raw` script parses;
  `devtools::check(vignettes=FALSE)` **0/0/0**. **Phase-3E:** N/A — no
  runtime behavior change.
- **Result:** branch `lint-whole-package` → **PR \#99** → **all CI green
  incl. the `lint` job (4m7s)** and the full R-CMD-check matrix (macOS /
  Ubuntu devel-oldrel-release / Windows) + pkgdown + coverage →
  **merged** (merge commit `8deeecf`) → branch deleted (local + remote;
  verify-merged-firsthand). **The standing `lint`-CI red is cleared on
  `master`.** `master == origin/master`.
- **Learnings:** Learning 224 (PROJECT_LEARNINGS.md).

### 2026-06-28 — FU3 maintainer docstring note landed; issue \#95 dispositioned end-to-end (issue \#95, Session 237)

- **Deliverable (owner pick — “§10C docstring + close \#95”):** the
  implementation tail of the S236 decision split (plan
  `docs/planning/issue95-optionC-targeted-suppression-plan.md` §10C,
  decision D4). Added a maintainer `@noRd` docstring note to
  `R/correctUnknownParentMeanKinship.R` recording follow-up 2
  (both-unknown → one-unknown promotion) and follow-up 3
  (shared-unknown-parent sib-pair coupling) as considered-and-not-built,
  then **deliberately set issue \#95 to its terminal state**.
  **Documentation/admin session — TDD code-phases N/A** (a `@noRd`
  roxygen comment is stripped at build, produces no `.Rd`, and no test
  pins it — all verified firsthand). **0 corrections / 0 overrides.**
  Committed direct to `master` (the docs-to-master pattern;
  behavior/code changes get a PR, a no-behavior docstring does not).
- **The docstring note** (commit `d55ffc51`; inserted after `:102`,
  before the `@param` block): FU3 — each one-unknown animal is corrected
  independently, so two animals sharing the same unrecorded parent each
  receive the full `sexMean / 2` prior (a small over-estimate of joint
  relatedness); the coupling is deliberately not modeled because the
  premise is undetectable (an unrecorded parent has no id). FU2 — for
  the same path-agnostic reason an override cannot reclassify a
  both-unknown animal to one-unknown (a kinship value cannot identify
  which parent it informs).
- **House-style normalizations of §10C’s “recommended” (not
  verbatim-mandated) text:** em-dash → ASCII `--` (protects the
  non-ASCII R-source check), markdown backticks → `\code{}` (this file’s
  roxygen style), US “modeled” (cf. `:85`). ASCII-clean, all lines ≤80.
- **Verify:** the 3 relevant test files green
  (`test_correctUnknownParentMeanKinship.R`,
  `test_kinshipOverrideDocs.R`,
  `test_gvaConvergence_kinshipOverrides.R`); changed-file lint clean;
  `devtools::check(vignettes=FALSE)` **0/0/0** (the lone NOTE named only
  a misplaced check-log I had written into the package root, since
  relocated to scratchpad). **Phase-3E:** N/A — no runtime behavior
  change.
- **Result:** the \#95 follow-up arc is complete end-to-end — S234
  (reframe + revert decision) → S235 (revert impl, PR \#98) → S236
  (FU2/FU3 grill) → S237 (FU3 docstring + deliberate close). **Issue
  \#95 is no longer open** (deliberate, keyword-safe `gh api` PATCH;
  state verified). \#9/#13 stay closed. A future molecular-parentage /
  transactional-location parentage capability (cf. issue \#28) would be
  a fresh issue.
- **Learnings:** Learning 223 (PROJECT_LEARNINGS.md).

### 2026-06-28 — Grill: \#95 follow-ups 2 & 3 dispositioned (FU2 won’t-build, FU3 accept+document) (issue \#95, Session 236)

- **Deliverable (owner pick — “#95 follow-ups 2 / 3”):** a `/grill-me`
  decision session settling the two remaining \#95 follow-ups, bundled
  (owner scope call): **2** (both-unknown → one-unknown promotion) and
  **3** (shared-unknown-parent sib-pair coupling). Output = a ratified
  decisions list written to
  `docs/planning/issue95-optionC-targeted-suppression-plan.md` **§10**
  (+ a follow-up-resolution pointer at D11 in
  `issue13-kinship-overrides-plan.md`). **Decision/design session — TDD
  code-phases N/A** (no `R/`/tests/`man`/`NAMESPACE`/`data` change).
- **Grounding (read-only workflow `wf_964f8ea1-4bb`, 6 agents +
  firsthand re-verification):** the workflow’s synthesis step
  degenerated to placeholder output and was recovered from the agent
  transcripts; the load-bearing claims were then re-verified firsthand
  against current `master` — code dataflow (both-unknown excluded via
  `xor` at `correctUnknownParentMeanKinship.R:145`; independent
  per-focal loop `:155`; pipeline order override→meanKinship→correction
  in `reportGV`/`gvaConvergence`; option-C symbols all removed) and
  `qcPed` numerics (280 probands: 43 one-unknown all sire-missing, 124
  both-unknown, 113 both-known; prior median ≈1.34 SD).
- **The decisive FU3 finding (firsthand on `qcPed`):** the 2 candidate
  sib-pairs (`KY0D3C`/`HN5YTI`; `JPKPJC`/`PUS6EL`) each share a known
  *dam* and both miss the *sire* — so whether they share the *same*
  unknown sire is **unknowable**. The “shared unknown parent” premise is
  itself undetectable.
- **Ratified decisions (0 corrections / 0 overrides):** **D1** FU2 =
  **won’t-build** (a path-agnostic `id1`/`id2`/`kinship` override cannot
  identify which parent it informs; promotion conflates a relatedness
  observation with knowing a parent — a category error; no methodology
  supports it); **D2** FU3 = **accept** (keep the independent per-focal
  loop) **+ document** (premise undetectable, effect negligible / below
  `guSE`, residual ~1/N); **D3** documentation surface = **maintainer
  docstring only** (avoids the pinned `test_kinshipOverrideDocs.R`);
  **D4** = **close \#95 after the FU3 docstring note lands**
  (deliberate, keyword-safe).
- **Result:** all \#95 follow-ups are now dispositioned (FU1 / rule (ii)
  / C1.2 won’t-build at S234; FU2 won’t-build, FU3 accept+document at
  S236). The only remaining action is the FU3 maintainer-docstring note
  (§10C — a separate small implementation session), after which \#95
  closes. **\#95 stays OPEN** this session (keyword-safe comment posted,
  state verified). \#9/#13 stay closed.
- **Learnings:** Learning 222 (PROJECT_LEARNINGS.md).

### 2026-06-28 — Revert option C kinship-override suppression to keep-all (issue \#95, Session 235)

- **Deliverable (owner pick — “S234’s suggested next”):** the strict-TDD
  **revert implementation** ratified by S234 (plan
  `docs/planning/issue95-optionC-targeted-suppression-plan.md` §9C). An
  outside kinship override no longer drops a one-unknown animal’s
  `+ sexMean / 2` unknown-parent prior; it only refines the named
  kinship cell (issue \#13). **Strict-TDD DEVELOPMENT session** (RED
  `034de14b` → GREEN `cae27e94`; REFACTOR — none needed); all phase
  gates via `AskUserQuestion`; **0 corrections / 0 overrides.** On
  branch `issue95-revert-keepall` (not yet pushed).
- **Grounding (read-only workflow `wf_9298eddb-3a4`, 19 agents):**
  re-ran the §9C grep inventory firsthand against current `master` —
  complete and accurate (empty `planRefsNotFound`); surfaced 3 roxygen
  source lines the plan’s line-ranges did not enumerate (handled) and
  two author’s-call forks the plan left open (owner chose: **drop** the
  now-unused `ped`/`candidateIds` params; **ignore** a stray
  `missingSideFor` column rather than reject it).
- **Source changes:** `correctUnknownParentMeanKinship` drops the
  `overriddenIds` param + suppress guard (corrects every one-unknown
  animal); `prepareKinshipOverrides` drops the
  `suppressIds`/`classifyOverrideMissingSide` machinery and the
  `ped`/`candidateIds` params, returning `list(kmat)`;
  `reportGV`/`gvaConvergence` drop the suppress read + `overriddenIds`
  arg in lockstep (the issue-#13 cell-write stays);
  `R/classifyOverrideMissingSide.R` deleted; `checkKinshipOverrides`
  ignores any extra column. The override helpText, `genetic_value.html`,
  and `NEWS` are rewritten to the keep-all story with the honest
  underestimate limitation (Vinson & Raboin 2015); `man/*.Rd` +
  `NEWS.md` regenerated.
- **Verify:** affected tests GREEN (198 assertions); full suite **3173
  pass / 0 fail / 0 error** (no true offenders); `spell_check_package`
  clean; `devtools::check(vignettes=FALSE)` **0/0/0**; **Phase-3E**
  runtime smoke (FM \#24) — app boots, live UI shows the keep-all
  helpText (no `missingSideFor`), and `reportGV` with an override keeps
  the one-unknown animal’s prior (0.0092 \> 0.0060) while applying the
  cell-write.
- **Result:** option C (Slices 1–2, S229–S233) + the D11 blanket
  supersession are reverted before any tagged release. **\#95 stays
  OPEN** for follow-ups **2** (both-unknown→one-unknown) and **3**
  (sib-pair coupling). Branch pushed and **PR \#98** (“Relates to \#95”,
  base `master`) opened, then **merged** (merge commit `89d6bddd`) after
  the full R-CMD-check matrix went green — the lone `lint` red was
  proven pre-existing whole-package noise via the check-run annotations
  API (none in this PR’s changed files); `#95` verified OPEN post-merge.
  `master == origin/master`. Branch `issue95-revert-keepall` then
  **deleted** (local + remote; verify-merged-firsthand against both
  refs, safe `git branch -d`, `git ls-remote` empty). The revert arc is
  closed end-to-end: RED → GREEN → PR \#98 → merge `89d6bddd` → branch
  deleted. **\#95 stays OPEN** (follow-ups 2/3).
- **Learnings:** Learning 221 (PROJECT_LEARNINGS.md).

### 2026-06-28 — Grill: rule (ii) / partial-residual → REVERT option C to keep-all (issue \#95, Session 234)

- **Deliverable (owner pick — live-thread \#2 → rule (ii)):** a
  `/grill-me` decision session for \#95 follow-up **rule (ii)
  (partial-residual / scaled add-back)**, bundled with the **C1.2
  `"both"` / two-rows-per-pair** encoding. Output = a ratified decisions
  list + Phase-3 revert design written to
  `docs/planning/issue95-optionC-targeted-suppression-plan.md` **§9** (+
  a superseded-in-part pointer at D11 in
  `issue13-kinship-overrides-plan.md`). **Decision/design session — TDD
  code-phases N/A** (no `R/`/tests/`man`/`NAMESPACE`/`data` change).
- **Grounding (workflow `wf_1a1f64ba-976`, 4 read-only agents +
  firsthand verification):** re-ran §8B on current `qcPed` (280
  probands, 43 one-unknown; prior median ≈1.34 SD) and **verified
  firsthand** the load-bearing pipeline ordering — overrides are written
  into `kmat` (`prepareKinshipOverrides.R:49`) *before* `meanKinship`
  (`reportGV.R:148`) and *before* the `+ sexMean / 2` correction
  (`:157`).
- **The reframing (firsthand-verified):** a missing-side override pins
  **one of N** colony relationships and that value is **already in
  `original`**, so the prior should shrink by only ~1/N per override
  (~0.0048 SD), not be dropped wholesale (~1.33 SD). Shipped rule (i) —
  and its parent, D11 blanket supersession — **over-correct by ~N
  (≈280×)**, moving an affected animal’s GV rank a median of ~86/280 in
  the *wrong* direction. No conservation-genetics literature supports a
  partial-residual estimator; the `+ sexMean / 2` prior is itself a
  package-only addition (not in Vinson & Raboin 2015).
- **Ratified decisions (0 corrections / 0 overrides):** **D1** accept
  the over-correction reframing; **D2** revert prior-suppression to
  **keep-all** (every one-unknown animal keeps `+ sexMean / 2`;
  issue-#13 override-the-cell stays) **with good user documentation**;
  **D3** moot (no graded `w`); **D4** **remove** the option-C machinery
  cleanly (`missingSideFor` column, `classifyOverrideMissingSide()`, the
  suppress path — **drops C1.2 / won’t-build**); **D5** document the PMx
  pair-level model as **considered-and-not-needed** (#13 already does
  replace-cell+recompute for observed pairs).
- **Result:** rule (ii) and C1.2 **resolved (won’t-build → revert)**;
  **\#95 stays OPEN** for follow-ups **2** (both-unknown→one-unknown)
  and **3** (sib-pair coupling) only. The revert is a separate
  strict-TDD implementation session (plan §9C: evidence-based inventory,
  behavior invariant = keep-all, one atomic session, Phase-3E required).
  Option C (Slices 1–2, S229–S233) is thus superseded before any tagged
  release.

### 2026-06-28 — Branch hygiene: deleted merged branch `issue95-optionC-slice2` (issue \#95, Session 233)

- **Deliverable (owner pick):** the deferred branch-hygiene step from
  S232’s SUGGESTED NEXT — deleted the merged branch
  `issue95-optionC-slice2` (local + remote). **Admin/branch-hygiene
  session — TDD code-phases N/A** (no `R/`/tests change). Third run of
  the S229→S230(a) deferred-hygiene pattern (slice1 deleted in S230(a);
  slice2 now).
- **Verify-merged-firsthand (four checks):** branch tip `421f80f2` is an
  ancestor of BOTH `master` and `origin/master`
  (`git merge-base --is-ancestor`), local and remote branch tips
  identical, and `git log master..issue95-optionC-slice2` empty —
  against `master == origin/master == cd20817e`.
- **Local delete:** safe `git branch -d issue95-optionC-slice2` (exit 0)
  — the documented `-D`-forcing “ahead 1” quirk (Learning 207/208) did
  not bite because PR \#97 was a true merge commit, so the tip is a
  literal ancestor of master.
- **Remote delete (outward-facing — owner-confirmed first via
  `AskUserQuestion`):**
  `git push origin --delete issue95-optionC-slice2`. Verified gone:
  `git ls-remote origin issue95-optionC-slice2` empty; the
  `origin/issue95-optionC-slice2` remote-tracking ref also pruned.
  GitHub had not auto-deleted the branch on PR merge.
- **Scope held (1-and-done):** deleted only the named merged branch;
  left the other stale branches (`dev`, `module`,
  `rlabkey-version-floor`) untouched. This closes the option C Slice 2
  arc end-to-end: S230 RED/GREEN → S231 push+PR → S232 merge → S233
  hygiene. \#95 stays **OPEN** (rule (ii) + follow-ups 2/3 remain).
- **Learnings:** Learning 219 (PROJECT_LEARNINGS.md) — the deferred
  branch-hygiene step is a clean ~5-command admin task when you
  verify-merged-firsthand against BOTH refs first; try `git branch -d`
  first (only fall back to merge-base-check-then-`-D` if `-d` refuses);
  confirm the outward-facing remote delete before running it, then
  verify removal with `git ls-remote`.

### 2026-06-28 — Merged option C Slice 2 to master (issue \#95, Session 232)

- **Deliverable (owner pick “go with next suggested”):** integrated
  option C Slice 2 to `master` — watched the PR \#97 R-CMD-check matrix
  to green, then **merged** (merge commit `e893c90d`, 23:00:45).
  **Admin/merge session — TDD code-phases N/A** (no `R/`/tests change;
  the merged code is S230’s). The 5th run of the careful-admin
  push→PR→CI→merge arc (S218/S221/S224/S229) — and the **first clean run
  since S229’s triple closing-keyword firing**.
- **Verify-then-merge held (did not merge on `MERGEABLE`):** full
  R-CMD-check matrix green (macOS/Windows/Ubuntu release + oldrel-1 +
  **devel**, completed 22:58:53), plus pkgdown + test-coverage + both
  codecov. The lone `lint` red was proven pre-existing whole-package
  noise via the check-run **annotations API** (12 findings: 10 in
  `data-raw/fgSEValidation.R`, 2 `.github` workflow warnings; **none**
  in this PR’s changed files).
- **Closing-keyword discipline held — no firing (Learning 215/217):** no
  branch commit carried any `#N` ref (bare-word “issue 95”), so the lone
  “close-out” token was provably inert; the rendered PR body grep
  returned empty; the **merge commit message was authored keyword-free**
  via `gh pr merge --subject/--body`. Post-merge
  `gh api .../issues/95 --jq .state` → **open**; \#9/#13 stay
  **closed**.
- **Local sync via stash-the-stub (Learning 210(2)), not
  `reset --hard`:** re-checked `git status` first (no unexplained
  modified file), stashed the 1B stub, fast-forwarded `master`
  (d3854083..e893c90d), popped the stub cleanly. **local master ==
  origin/master == `e893c90d`**; Slice-2 code present.
- **Result:** **\#95 stays OPEN** (rule (ii) + follow-ups 2/3 remain).
  Branch `issue95-optionC-slice2` merged but **not deleted** (deletion
  is the deferred separate hygiene step, Learning 208/210(4)).
- **Learnings:** Learning 218 (PROJECT_LEARNINGS.md) — the careful-admin
  arc ran clean on the 5th run by reading 207/210/215/217 *before*
  acting; airtight closing-keyword proof + keyword-free authored
  merge-commit message; env nugget: **zsh `status` is a read-only
  special variable** (never assign to it in a Bash snippet — use
  `st`/`cc`); a `run_in_background` poll loop is the mechanism for
  waiting on an external CI leg.

### 2026-06-28 — Pushed option C Slice 2 + opened PR \#97 (issue \#95, Session 231)

- **Deliverable (owner pick):** outward-facing admin — pushed branch
  `issue95-optionC-slice2` to origin and opened **PR \#97** (“Relates to
  \#95”, base `master`). **Admin/PR session — TDD code-phases N/A** (no
  `R/`/tests change; the code is S230’s, already verified). Scoped to
  **push + open PR**; watching the CI matrix to green and merging is a
  separate owner-gated step.
- **Closing-keyword discipline (Learning 215 → refined as 217):**
  grepped the branch commit messages AND the rendered PR body for
  `clos|fix|resolv` BEFORE pushing/creating. The 3 branch commits carry
  zero `#N` refs (they write “issue 95”, not “#95”), so the lone
  “close-out” substring was provably safe (no adjacent `#N`). The PR
  body was authored with **zero** `clos|fix|resolv` tokens (rephrased a
  harmless hyphenated “close-out” → “docs/handoff” so the broad grep
  returns empty — no adjacency judgment needed). After creation,
  re-fetched the **rendered** PR body from GitHub (clean) and confirmed
  via REST that **\#95 is still OPEN**.
- **Result:** branch `issue95-optionC-slice2` on origin (tip
  `1992bb8b`); **PR \#97 OPEN** (base `master`, head
  `issue95-optionC-slice2`); **\#95 OPEN**. Not merged (owner-gated next
  step). master == origin/master == `d3854083` unchanged.
- **Learnings:** Learning 217 (PROJECT_LEARNINGS.md) — for a PR body /
  issue comment you author fresh, make the broad `clos|fix|resolv` grep
  return EMPTY (strip every such token, even harmless
  hyphenated/non-adjacent ones) instead of reasoning about adjacency to
  `#N`; verify against the RENDERED artifact (`gh pr view --json body`)
  plus `gh api .../issues/<n> --jq .state`.

### 2026-06-28 — Branch hygiene + option C Slice 2: diagnostic lockstep + app delivery (issue \#95, Session 230)

- **Deliverable (owner pick “a then b”):** (a) deleted the merged branch
  `issue95-optionC-slice1` (local + remote, verify-merged-firsthand
  against both `master` and `origin/master` → safe `-d`); (b) **option C
  Slice 2** per the RATIFIED plan
  (`docs/planning/issue95-optionC-targeted-suppression-plan.md` §4
  Slice 2) on branch `issue95-optionC-slice2`.
- **Slice 2 (strict-TDD DEVELOPMENT session; RED → GREEN →
  REFACTOR-skipped):** brought
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
  into **lockstep** with
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)’s
  option-C behavior and documented the `missingSideFor` column in the
  app. New `@noRd` helper **`prepareKinshipOverrides()`** (validate →
  warn-drop → apply to matrix → compute the option-C suppress set) is
  now the SINGLE override-preparation path both
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  and
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
  route through, so the report and the convergence diagnostic cannot
  disagree on an overridden one-missing-parent animal. Helptext
  (`modGeneticValue.R`) + `inst/extdata/ui_guidance/genetic_value.html`
  document the optional `missingSideFor` column;
  `test_kinshipOverrideDocs.R` updated in lockstep (phrase-pinning).
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  behavior unchanged (routed through the helper; Slice-1 suite is the
  regression net). No `missingSideFor` column / no upload ⇒
  byte-identical (D10).
- **All three phase gates via `AskUserQuestion`** (PRE-RED→RED,
  RED→GREEN, GREEN→REFACTOR), plus a pre-RED approach `AskUserQuestion`
  (the shared-helper design, owner-chosen) and a mid-GREEN “review the
  helper body first” hold. **0 stakeholder corrections / 1 owner
  course-correction** (stopped
  [`spelling::update_wordlist()`](https://docs.ropensci.org/spelling//reference/wordlist.html)
  which had pruned 31 curated WORDLIST words as a side effect →
  reverted, did a surgical +2 add).
- **TDD commits (branch `issue95-optionC-slice2`):** RED, GREEN,
  close-out (this).
- **Verify (all clean):** the 4 touched/new test files +
  `reportGV`/correction/validator/classify suites green; clean
  regression read **0 failed / 0 error** (1352 results, incl. & excl.
  `test-app-`/`test-e2e-`, `NOT_CRAN=true`);
  `devtools::check(vignettes=FALSE)` **0/0/0**; `spell_check_package`
  **0** (surgical `inst/WORDLIST` +2: `focals`, `supersession`); **lint
  net reduction** (new helper 0; gvaConvergence 0; modGeneticValue 0;
  reportGV 1 = pre-existing `:65`); `document()` regenerated
  `gvaConvergence.Rd` + `reportGV.Rd` (no NAMESPACE delta — helper is
  `@noRd`); NEWS bullet added + rendered.
- **Phase-3E runtime smoke (REQUIRED — done):** functional smoke — on
  real `qcPed` a known-side override KEEPS the focal’s `+ sexMean / 2`
  (meanKin 0.009198) while a missing-side override SUPPRESSES it
  (0.006027), via both
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  and
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md);
  app-boot smoke —
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  served HTTP 200 with `missingSideFor` present in the live HTML
  (helptext + guidance render).
- **Issue state:** \#95 stays **OPEN** (Slice 2 closes follow-up 1, but
  rule (ii) + follow-ups 2/3 remain). Branch `issue95-optionC-slice2`
  **NOT pushed** (push → PR “Relates to \#95” → CI → merge is a separate
  admin session, per the S228→S229 arc).
- **Learnings:** Learning 216 (PROJECT_LEARNINGS.md) — making a
  non-observable diagnostic’s behavior change testable via a shared
  helper (test the helper, route both callers through it = structural
  lockstep) when the public output can’t show the change; and the
  [`spelling::update_wordlist()`](https://docs.ropensci.org/spelling//reference/wordlist.html)
  destructive-prune trap (it rewrites WORDLIST to exactly the
  currently-flagged set, removing curated entries → add words surgically
  instead).

### 2026-06-28 — Merged option C Slice 1 to `master` via PR \#96 (issue \#95, Session 229)

- **Deliverable (owner pick “1”, then “merge it once devel passes”):**
  integrated S228’s option C Slice 1 to `master` — pushed branch
  `issue95-optionC-slice1`, opened **PR \#96** (“Relates to \#95”),
  watched the CI matrix to green, merged (merge commit `6f305f37`).
  **Admin/merge session — TDD code-phases N/A** (no `R/`/tests change;
  the merged code is S228’s). The 4th run of the careful-admin
  push→PR→CI→merge arc (S218/S221/S224/S229; Learning 207/210).
- **CI (verify-then-merge):** full R-CMD-check matrix green —
  `ubuntu (devel/oldrel-1/release)`, `macos (release)`,
  `windows (release)` — plus `test-coverage`, `pkgdown`,
  `codecov (patch+project)`. The lone `lint` red is the long-standing
  whole-package noise (Learning 207/210; nothing from this PR). Merged
  only after the matrix was green.
- **Two self-inflicted process errors, both caught and recovered
  (regressions against Learning 207/210):** (1) the PR body wrote “does
  **not** close \#95” — GitHub’s parser ignores negation and auto-closed
  the issue on merge; reopened (`gh issue reopen 95`), corrected the
  body via `gh api` REST (the `gh pr edit` path 401s on the
  Projects-classic deprecation), added an explanatory comment — then the
  SAME error recurred a third time in the first close-out commit message
  (“auto-closed \#95”), re-closing the issue on push; reopened again.
  File contents do not trigger the parser (only commit messages +
  PR/issue bodies); the routine final-state `gh issue view 95` check
  caught both firings. (2) `git reset --hard origin/master` discarded an
  **owner edit** to `data-raw/fgSEValidation.R` made during the CI wait
  (owner confirmed it was minor lint cleanup to be redone systematically
  — no recovery needed); the Learning 210(2) stash-the-stub sync would
  have preserved it.
- **Issue state:** \#95 **OPEN** (rule (ii) + follow-ups 2/3 + Slice 2
  remain); \#9, \#13 CLOSED. Merged branch `issue95-optionC-slice1` left
  undeleted (branch hygiene is the deferred separate step, Learning
  210(4)).
- **Learnings:** Learning 215 (PROJECT_LEARNINGS.md) — the
  closing-keyword NEGATION trap (run the Learning 207/210 body+commit
  grep before every merge; negation does not save you) and the
  external-edit `reset --hard` trap (re-check `git status` immediately
  before any `reset --hard`; an unexplained modified tracked file is
  likely the owner’s edit → stash, surface, ask); on a “routine” arc,
  read the prior learnings for that arc first.

### 2026-06-28 — Option C Slice 1: script-core targeted suppression (issue \#95, Session 228)

- **Deliverable (owner pick: “Slice 1 of option C”):** the script-core
  of option C per the RATIFIED plan
  (`docs/planning/issue95-optionC-targeted-suppression-plan.md` §4 Slice
  1).
  **[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  now suppresses the issue-#9 `+ sexMean / 2` unknown-parent correction
  *targeted* by override side:** a one-missing-parent animal keeps the
  correction for a known-side override (case b — previously wrongly
  dropped by D11 blanket-A) and has it suppressed only when an override
  stands in for its *missing* side (case a), via an optional
  `missingSideFor` column on the override table. No `missingSideFor`
  column ⇒ byte-identical to today (blanket-A, D10). **Strict-TDD
  DEVELOPMENT session (RED `5448a1a8` → GREEN `4cd3e509`; REFACTOR
  offered, owner chose skip).** All three phase gates via
  `AskUserQuestion`. **0 stakeholder corrections / 0 owner overrides.**
  On branch `issue95-optionC-slice1`.
- **RED (`5448a1a8`):** NEW `test_classifyOverrideMissingSide.R` (7
  cases → error, helper absent); `test_checkKinshipOverrides.R` (a
  `missingSideFor` not naming id1/id2 → stop — fails at HEAD; +
  accept/NA-blank/dedup-C1.2 stays-green); `test_reportGV.R` (the
  discriminating case-(b) test: a blank-`missingSideFor` override KEEPS
  the prior — fails at HEAD where blanket-A drops it; only 1/280 animals
  differ; + an independent `i13_correctOptionC` oracle + a case-(a)
  suppress test); `test_correctUnknownParentMeanKinship.R`
  (redefined-`overriddenIds`-contract characterization — passes at HEAD,
  the guard already does membership).
- **GREEN (`4cd3e509`, minimal):** `checkKinshipOverrides` validates the
  optional `missingSideFor` column (NA→““; each non-blank cell must name
  id1/id2 of its row; dedup key UNCHANGED, C1.2); NEW
  `R/classifyOverrideMissingSide.R` (`@noRd`, C5 — the one-unknown
  focals named by a non-blank side, via `isU(ped$sire/dam)`); `reportGV`
  computes `suppressIds` (present column → missing-side subset; absent →
  full set = blanket-A/D10) and passes it as `overriddenIds` (C3);
  `correctUnknownParentMeanKinship` `@param` docstring redefined to”the
  set to suppress” (C3, guard unchanged — no behavior change).
  `gvaConvergence` stays blanket-A until Slice 2.
- **Verify (all clean):** the 4 touched test files green; clean
  regression read **0 failed / 0 error** (1172 real files,
  `NOT_CRAN=true`); `devtools::check(vignettes=FALSE)` **0/0/0**;
  `spell_check_package` **0**; **lint net-zero** (HEAD-vs-current
  in-place: 6/4/2 → 6/4/1; new file 0); `document()` regenerated only
  `man/checkKinshipOverrides.Rd`. **Phase-3E N/A (stated):** no Shiny
  wiring changed (script-core only — the in-app upload is Slice 2); the
  `reportGV` behavior is covered by the test suite. NEWS bullet added
  (issue \#95 option C slice 1).
- **Learnings:** Learning 214 (PROJECT_LEARNINGS.md) — a
  targeted-suppression slice where the genetically-load-bearing function
  is UNCHANGED (only its caller and a new classifier change); design the
  discriminating RED on the case the refinement flips (case b), keep the
  unchanged-behavior cases as stays-green characterization; reconstruct
  RED/GREEN/close-out as separate commits even when implemented in one
  working-tree pass; net-zero lint via in-place stash (the /tmp-copy
  method loses `.lintr`).

### 2026-06-28 — Phase 0: ratified C1 + C2 for issue \#95 option C via `/grill-me` (Session 227)

- **Deliverable (owner pick: “ratify C1 + C2 via `/grill-me`”):** the
  Phase-0 ratification of the two owner/geneticist gates S226’s plan
  left UNRATIFIED.
  `docs/planning/issue95-optionC-targeted-suppression-plan.md` updated:
  STATUS flipped DRAFT → **RATIFIED (S227)**, §7 checklist filled with
  the decided values, and a new **§8 ratification record** added
  (firsthand numeric evidence + a re-runnable reproduction recipe + the
  reframing). **Planning / Phase-0 decision session — TDD code-phases
  N/A.** No `R/`/tests/`NAMESPACE`/`man/`/`data`/`DESCRIPTION` change
  (plan markdown + close-out docs only). **0 stakeholder corrections / 0
  owner overrides** — every recommendation ratified as written.
- **Firsthand numeric check on real `qcPed` (the D11/S214 evidentiary
  bar), recorded in plan §8 so it is not lost as S214’s was:**
  replicated the `reportGV.R:118-180` mean-kinship path; the
  `+ sexMean/2` prior is **median ~1.34 SD** of the mean-kinship spread,
  a single half-sib override justifies only **~10%** of that prior
  (prior/raw ~9.9×), and dropping one animal’s prior swings its rank
  49–121 of 280. Independently reproduces S214’s “~1 SD” / “8.4×”
  numbers.
- **Decisions ratified:** upstream judgment = real override use is a
  **genuine mix** (⇒ option C worth building). **C1=(a)**
  side-annotation column **`missingSideFor`** (C1.1 two opposite
  absent-column defaults; C1.2 the both/diffuse case documented as a v1
  limitation; C1.3 optional column — C1.1/C1.3 forced by the D10
  byte-identical invariant). **C2=(i)** full-drop side-gated — ratified
  because rule (i) suppresses a strict *subset* of blanket-A’s
  suppressions, so it is a **strict (Pareto) improvement over today**
  (fixes the known-side case b; leaves the missing-side case a, whose
  ~1.2 SD residual is pre-existing, unchanged). **(ii)**
  partial-residual **deferred** to a new \#95 follow-up (needs a
  pair-decomposition model `sexMean` lacks). **C3**
  caller-computes-the-suppress-set; **C4** pin the `(X,Y)=0.25` fixture
  as case (a); **C5** shared `classifyOverrideMissingSide()` via
  `isU(ped$sire/dam)`; **C6** deferred. Slice order Phase 0 (DONE) →
  Slice 1 → Slice 2; **D10** invariant confirmed. **Slice-1 RED is now
  unblocked as a separate later session.**
- **Learnings:** Learning 213 (PROJECT_LEARNINGS.md) — do the firsthand
  numeric check before the grill and preserve its evidence in the plan;
  lead the grill with the upstream domain judgment; reframe a
  targeted-suppression rule as a strict subset (Pareto improvement) of
  the blanket it refines; reserve `AskUserQuestion` for genuinely-open /
  genetics calls and confirm invariant-forced sub-decisions in prose.

### 2026-06-28 — Plan-mode design for issue \#95 option C (targeted suppression of the kinship-override / unknown-parent \#9 correction) (Session 226)

- **Deliverable (owner pick: “plan option C design for issue \#95”):**
  one planning/architecture document,
  `docs/planning/issue95-optionC-targeted-suppression-plan.md`, for
  **option C** — suppress the issue-#9 `+ sexMean / 2` mean-kinship
  correction ONLY when an override informs the focal animal’s
  **missing** parent side (case a), and KEEP it for known-side-only
  overrides (case b), which the shipped v1 blanket-A (D11) wrongly
  discards. **Planning session — TDD code-phases N/A** (the plan is the
  deliverable; implementation is a SEPARATE later session, gated on
  Phase-0 ratification). No
  `R/`/tests/`NAMESPACE`/`man/`/`data`/`DESCRIPTION` change. 0
  stakeholder corrections / 0 owner overrides.
- **Firsthand evidence inventory (two read-only workflows + a
  completeness grep):** a 9-agent inventory (`wf_4012d83a-551`) captured
  current `file:line` across the ~12 affected files, correcting the
  parent plan’s drifted citations (the `+ sexMean / 2` add is
  `correctUnknownParentMeanKinship.R:190`, not the plan’s stale `:175`).
  Confirmed the two behavior-bearing call sites (`reportGV`,
  `gvaConvergence`); the matrix-apply layer is side-agnostic (no
  change); the schema choke point is the single validator
  `checkKinshipOverrides`.
- **Adversarial verification (`wf_38c97263-a2e`, 3 agents — citation /
  design red-team / completeness; the project’s S213 bar):** ~60
  citations exact; the pass found and the plan now fixes **6 substantive
  issues** — (1) a HIGH-severity D10 contradiction in the C1
  absent-column default (must be blanket-A/suppress, not keep — resolved
  as two opposite defaults); (2) a cleaner C3 threading design
  (caller-computes-the-suppress-set, no new param, no NULL-vs-empty
  trap); (3) a WRONG directional claim (gvaConvergence computes
  parentage AFTER its correction, not before — confirmed firsthand; both
  callers symmetric); (4) the side classification uses
  `isU(ped$sire/dam)`, not a `classifyParentage` hoist; (5) honest
  framing that rule (i) trades the case-(b) over-credit for a scoped
  missing-side one; (6) three missed doc/test surfaces
  (`genetic_value.html`, `summary_stats.html`,
  `test_kinshipOverrideDocs.R`).
- **Two owner/geneticist ratification gates surfaced, NOT decided (the
  plan is a DRAFT, FM \#19):** **C1** (the irreversible 4th-column
  schema encoding + sub-decisions) and **C2** (the residual
  genetics-modeling rule: full-drop-on-any-missing-side vs
  partial-residual) — settled via `/grill-me` against a firsthand
  numeric check, the way D11 was. The §7 checklist is UNRATIFIED; no
  Slice-1 RED until Phase 0 closes. Vertical slices: Phase 0 (ratify) →
  Slice 1 (script core) → Slice 2 (diagnostic lockstep + app + close
  \#95 follow-up 1).
- **Learnings:** Learning 212 (PROJECT_LEARNINGS.md) — run the
  adversarial verification before a schema-extension plan is “done”;
  re-verify a recon subagent’s directional/semantic claims firsthand
  even when its line numbers are right; red-teaming improves the design,
  not just catches errors.

### 2026-06-28 — Branch hygiene + filed issue \#95 tracking the three deferred D11 follow-ups (Session 225)

- **Deliverable (owner pick: “Branch hygiene; Item-3 follow-up”; two
  bounded items):** (1) deleted the now-merged branch
  `issue13-item3-r13-flag-overridden` (local + remote); (2) recon’d the
  remaining issue-#13 item-3 (D11) “follow-up” and — finding **no
  ready-to-implement TDD slice** — filed **issue \#95** to track the
  three deferred v1 limitations with full evidence. **Admin /
  disposition session — TDD code-phases N/A** (no
  `R/`/tests/`NAMESPACE`/`man/`/`data`/`DESCRIPTION` change). 0
  stakeholder corrections / 0 owner overrides.
- **Branch hygiene (verify-before-delete, Learning 208):** confirmed the
  branch tip `68db38c9` (the S223 close-out — the ORIGINAL feature tip,
  NOT moved to the merge commit) is an ancestor of BOTH `master` and
  `origin/master`, so safe `git branch -d` deleted it cleanly (no `-D`
  force needed, unlike S222’s gvaconv branch);
  `git push origin --delete` removed the remote. No issue-13 branches
  remain; `master` unchanged at `6cb18ddb`.
- **D11 follow-up recon (5-agent read-only workflow `wf_c1143706-b45`; 3
  of 5 returned, 2 filled by hand):** the D11 **core** (blanket
  supersession, option A) is **already shipped and 4-part-tested**
  (`correctUnknownParentMeanKinship.R:164-171` guard; threaded from
  `reportGV.R:159,179` + `gvaConvergence.R:151-163`; regression
  `test_reportGV.R:539-610`). What remained as “follow-up” is THREE
  deferred v1 limitations, **none a drop-in slice:** (1) **option C**
  (targeted suppression) is blocked on a schema change — the
  missing-parent side cannot be derived (unrecorded parent → no pedigree
  edges; path-agnostic kinship value), so it needs a new 4th override
  column + a residual genetics choice (plan-mode); (2)
  **both-unknown→one-unknown promotion** and (3) **shared-parent
  sib-pair coupling** are genetics-methodology decisions (#9 defers
  both-unknown; the one-unknown loop is per-animal independent) needing
  owner/geneticist ratification like D11 itself. Surfaced via a pre-RED
  scope `AskUserQuestion` (\[\[observation-vs-decision\]\]); owner
  picked “File tracking issue(s)”.
- **Process-history delta
  (\[\[check-process-history-before-rerunning-work\]\]):** the three
  follow-ups were tracked ONLY as prose (`plan.md:153,212,230`;
  CHANGELOG S214) with no issue number; filed **issue \#95**
  (`enhancement`, “Follow-up from \#13 (D11)”, **no** closing keyword —
  \#13 and \#9 confirmed CLOSED before and after). The issue body
  carries each follow-up’s blocker, blast-radius <file:line> inventory,
  and disposition so a future session can act without re-running the
  recon. Learning 211 recorded.

### 2026-06-28 — Merged the R13 relationship-flag slice to master (PR \#94; Session 224)

- **Deliverable (admin/merge):** integrated the completed S223 R13 slice
  into `master`. Pushed branch `issue13-item3-r13-flag-overridden`,
  opened **PR \#94** (“Relates to \#13”, **no** closing keyword),
  verified the full CI matrix green, and **merged to `master`** via
  merge commit `33b0b09f`. **\#13 stayed CLOSED.** 0 stakeholder
  corrections / 0 owner overrides. Admin/merge session — TDD code-phases
  N/A.
- **Verify-then-merge (careful-admin bar):** confirmed the full
  R-CMD-check matrix (macOS release; Windows release; Ubuntu
  devel/oldrel-1/release) + pkgdown + test-coverage + both codecov
  checks all PASS; the only red was the long-standing non-blocking
  `lint`, **proven pre-existing via the check-run annotations API** (all
  12 findings in `data-raw/fgSEValidation.R` (10) + `.github`
  workflow/exit-code (2); none in this PR’s changed files
  `flagOverriddenRelationships.R`/`modSummaryStats.R`).
- **PR-body hygiene for a CLOSED tracking issue:** body says “Relates to
  \#13”; grep-scanned the commit messages and the rendered body for
  closing keywords (none); verified \#13 CLOSED before and after merge.
  **Clean local sync:** stashed just the 1B stub, fast-forwarded
  `master` to `33b0b09f`, restored the stub (avoids the S221
  uncommitted-stub `switch` trap while preserving the ghost-session
  marker). Learning 210 recorded.

### 2026-06-28 — Relationship table flags overridden pairs (issue \#13 item-3 follow-up R13; Session 223)

- **Deliverable (owner picks: Flag, not relabel; Display-layer, not
  core):** the Summary Statistics relationship output now flags
  outside-information overrides. A new display-layer helper
  `flagOverriddenRelationships()` appends a logical `overridden` column
  to the “Export All Relationships” CSV and the returned `relationships`
  reactive, marking the pairs whose kinship VALUE came from an override
  so a user can see which rows carry one even though the `relation`
  LABEL stays pedigree-derived (label and value can disagree).
  `convertRelationships` is **untouched** (its other callers and the
  relationship-class table are unaffected). With no override supplied
  the output is byte-identical (D10). **Strict-TDD DEVELOPMENT session
  (RED `7d8998e2` → GREEN `9fee8620`; REFACTOR offered, owner chose
  skip; phase declared each response; all three phase gates + one
  pre-RED scope gate via `AskUserQuestion`).** 0 stakeholder corrections
  / 0 owner overrides.
- **Why flag, not relabel:** a single kinship coefficient does not
  identify a unique relationship (0.25 = parent-offspring or full-sib;
  0.125 = half-sib, grandparent, or avuncular), so relabeling from the
  value would be genetically unsound — surfaced as the owner’s genetics
  call at a pre-RED scope `AskUserQuestion`. Recon also recovered that
  R13’s “narrow + document” fork already shipped (S217 decision, S219
  in-app docs); this session implements the remaining flag fork.
- **Scope/verification:** new `@noRd` helper (no NAMESPACE change; only
  `man/modSummaryStatsServer.Rd` regenerated); the override reaches the
  relationship table via the `kinshipMatrix = NULL` fallback recompute
  (the app path) — the new `testServer` tests exercise that path. Added
  a “flagged” sentence to `inst/extdata/ui_guidance/summary_stats.html`
  (pinned by a new doc-test). Full clean regression read **0 failed / 0
  error** (3151 pass), `devtools::check(vignettes=FALSE)` **0/0/0**,
  `spell_check_package` 0, **0 new lints**, and Phase-3E (real
  `runModularApp`) confirmed the app starts clean and serves the flag
  guidance. Branch `issue13-item3-r13-flag-overridden` is local only
  (push/PR/merge is the next admin session; \#13 stays CLOSED — no
  closing keyword in the PR body). Learning 209 recorded.

### 2026-06-28 — Branch hygiene: deleted the 5 merged issue-13 feature branches (local + remote; Session 222)

- **Deliverable (owner pick: “All 5 issue-13 branches”; single admin
  item):** deleted the issue-13 feature branches that were fully merged
  into `master` — `issue13-slice1-kinship-overrides`,
  `issue13-slice2-shiny-upload`, `issue13-slice3-fallbacks`,
  `issue13-item3-inapp-docs`, `issue13-item3-gvaconv-overrides` — both
  **local and remote (origin)**. **Admin / branch-hygiene session — TDD
  code-phases N/A** (no
  `R/`/tests/`NAMESPACE`/`man/`/`data`/`DESCRIPTION` change). 0
  stakeholder corrections / 0 owner overrides.
- **Verify-before-delete (SAFEGUARDS):** confirmed all 5 merged into
  BOTH `master` and `origin/master` before deleting; the commits live in
  `master`’s history so nothing was lost. The S221 handoff named only 4
  — `git branch --merged master` surfaced the 5th (`slice1`, merged via
  PR \#89), and the owner confirmed the full set.
- **`git branch -d` upstream quirk:** 4 deleted cleanly with safe `-d`;
  `issue13-item3-gvaconv-overrides` refused (`-d` compares against the
  branch’s *upstream*, and S221’s `reset --hard` had moved its local tip
  to the merge commit `daa7728b` — the “ahead 1” quirk). Proved
  containment with `git merge-base --is-ancestor daa7728b master` (exit
  0), then force-deleted with `-D`. Remote deletions via
  `git push origin --delete`. Post-state: no issue-13 branches remain
  (local or remote); `master` unchanged at `92cd34bd`. Learning 208
  recorded.

### 2026-06-28 — Merged the gvaConvergence kinship-override slice to master (PR \#93; Session 221)

- **Deliverable (outward-facing admin; owner picked the full arc S220
  suggested):** pushed branch `issue13-item3-gvaconv-overrides`, opened
  **PR \#93** (“Relates to \#13”, **no** closing keyword so \#13 stayed
  CLOSED), watched the full CI matrix to green, and **merged to
  `master`** via merge commit `daa7728b`. The S220
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
  kinship-override work (RED `a9e89027` → GREEN `87eae950` → close-out
  `404ace3c`) is now on `master`. **Admin/merge session — TDD
  code-phases N/A** (no
  `R/`/tests/`NAMESPACE`/`man/`/`data`/`DESCRIPTION` change). 0
  stakeholder corrections / 0 owner overrides.
- **Verify-then-merge (careful-admin bar, Learning 204):** confirmed the
  full R-CMD-check matrix green (macOS release; Windows release; Ubuntu
  devel/oldrel-1/release) plus `pkgdown`, `test-coverage`, and both
  `codecov` checks before merging. The sole red was the long-standing
  non-blocking `lint` check; confirmed via the check-run **annotations
  API** (`gh run view --log` came back empty — a known gh quirk) that
  all 12 lint findings are pre-existing whole-package noise
  (`data-raw/fgSEValidation.R` + a Node.js-20 workflow-deprecation
  warning) with **none** in this PR’s changed files.
- **Post-merge:** synced local `master` to `origin/master` (`daa7728b`);
  re-verified \#13 stayed CLOSED and the `kinshipOverrides` argument is
  present in `R/gvaConvergence.R` on `master`. Merged branch
  `issue13-item3-gvaconv-overrides` (local + remote) is deletable (owner
  hygiene). Learning 207 recorded.

### 2026-06-28 — gvaConvergence() honors kinship overrides (issue \#13 item-3 follow-up; Session 220)

- **Deliverable (the most self-contained of the three issue-#13 item-3
  follow-ups S219 documented as limits):**
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
  now applies outside-information kinship overrides the same way
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  does — it writes them into the proband kinship matrix (via the
  existing `applyKinshipOverridesToMatrix()` helper) before mean kinship
  AND threads the surviving overridden ids into
  `correctUnknownParentMeanKinship()` so an overridden
  one-unknown-parent animal keeps its override-influenced value (owner
  chose “Match reportGV” fidelity, not matrix-only). Out-of-set override
  ids are warn-dropped without aborting (D5); the strict
  positive-semidefinite-bound error propagates; a `NULL` override leaves
  the convergence curve byte-identical. **Strict-TDD DEVELOPMENT session
  (RED `a9e89027` → GREEN `87eae950`; REFACTOR offered — cross-module
  de-dup — owner chose skip; phase declared each response; all three
  phase gates + two pre-RED scope gates via `AskUserQuestion`).** 1
  owner mid-session quality correction (lint standards); 0
  technical/scope corrections; 0 owner overrides.
- Corrected the two now-false S219 in-app doc statements (the Genetic
  Value tab `helpText` in `modGeneticValue.R` and
  `inst/extdata/ui_guidance/genetic_value.html`) that said the
  convergence check ignores overrides, plus the matching
  `test_kinshipOverrideDocs.R` assertions; `man/gvaConvergence.Rd` and
  `NEWS` (`.Rmd` + render) regenerated.
- **Lint:** fixed two `line_length_linter(80)` violations introduced in
  `gvaConvergence.R` (the new `@param`; a former-last-arg line pushed to
  81 by an added trailing comma); both changed R files lint clean with
  the package loaded. Recorded the standard as a durable agent memory.
- **Verify:** new override tests 14/14; `gvaConvergence` 35/35;
  `test_kinshipOverrideDocs` 15/15; full clean regression read 0 failed
  / 0 error (3132 pass / 167 skip, incl. & excl. baseline,
  `NOT_CRAN=true`); `devtools::check(vignettes=FALSE)` 0/0/0;
  `spell_check_package` 0; Phase-3E launched the real app and confirmed
  the served page carries the corrected text. Branch
  `issue13-item3-gvaconv-overrides` (not yet PR’d — owner admin).

### 2026-06-27 — Documented issue \#13 kinship-override behavior + limits in the in-app UI (Session 219)

- **Deliverable (owner ask: “Documentation should appear at a minimum in
  the UI where the kinship coefficient(s) are supplied”; single
  documentation item):** added user-facing documentation of the issue
  \#13 kinship-override feature’s behavior and limitations to the three
  surfaces a user sees inside the running app — the override-upload
  `helpText` in the Genetic Value tab (the supply point),
  `inst/extdata/ui_guidance/genetic_value.html`, and
  `inst/extdata/ui_guidance/summary_stats.html`. **Strict-TDD
  DEVELOPMENT (documentation) session (RED `ed05a0cd` → GREEN
  `3a506772`; REFACTOR offered, owner chose skip; phase declared each
  response; all three phase gates via `AskUserQuestion`).** **0
  stakeholder corrections / 0 owner overrides.**
- **Audit first (false-negative discipline):** the item-3 implications
  (gvaConvergence ignores overrides; relationship label-vs-value
  divergence; unknown-parent \#9 edge cases) were documented only
  DEVELOPER-facing (roxygen + code comments in `modSummaryStats.R`) and
  PACKAGE-level (NEWS, planning doc) — **ZERO in-app coverage**; the
  override-upload helpText covered file FORMAT only. Enumerated every
  in-app surface (helpText, `includeHTML` guidance assets, About tab)
  and grepped each broadly before concluding “absent.”
- **Content (owner-ratified = all limitations + how it flows):**
  overrides change the kinship VALUE only (off-diagonal, symmetric,
  coefficient *f*); they apply to rankings, breeding groups, and summary
  statistics regardless of tab order; the relationship-table LABEL stays
  pedigree-derived so a label and its overridden value can disagree
  (item 3b); the gene-drop convergence check
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
  ignores overrides (3a); overrides on an animal missing a parent are
  supported, with a few edge cases (both parents unknown, or siblings
  sharing an unknown parent) as current limitations (3c).
- **RED (`ed05a0cd`):** `tests/testthat/test_kinshipOverrideDocs.R` — 14
  assertions across the three surfaces; **12 failed (documentation
  absent), 0 errors**. Asserted phrases verified absent from the current
  rendered UI first; helpText-EXCLUSIVE discriminators chosen because
  `as.character(modGeneticValueUI())` embeds `genetic_value.html` (which
  already names gvaConvergence — asserting it would FALSE-PASS).
- **GREEN (`3a506772`, minimal):** a second `helpText` at the override
  upload (each caveat built with a single
  [`paste()`](https://rdrr.io/r/base/paste.html) so it renders as one
  contiguous text node — `helpText()` renders each argument as a
  separate, newline-separated node) + an override paragraph in each of
  the two guidance HTML files. No `man/`/`NAMESPACE` change (function
  body + static assets only). **NEWS** updated (`.Rmd` + render).
- **Verify (all clean):** doc tests 14/14; full clean regression read
  **0 failed / 0 error** (3289 assertions, incl. & excl. baseline
  `test-app-`/`test-e2e-`); `devtools::check(vignettes = FALSE)`
  **0/0/0**; `spell_check_package` **0**.
- **Phase-3E (REQUIRED — UI-text change, FM \#24): DONE.** Launched the
  real
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md);
  the app started clean (0 error lines) and the served page carried all
  six new caveat strings. Read the app’s ACTUAL port (6013) from its
  “Listening on” log line (`runModularApp` overrode the requested
  `shiny.port`).
- **Learning 205** added to `PROJECT_LEARNINGS.md`. **Previous-session
  handoff (S218) scored 9/10.** Carried
  \[\[consult-project-source-of-truth\]\],
  \[\[observation-vs-decision\]\],
  \[\[ascii-only-in-question-options\]\],
  \[\[check-process-history-before-rerunning-work\]\],
  \[\[push-close-out-docs-to-origin\]\].
- **Merged to `master` via PR \#92** (merge commit `38bf1915`; pushed +
  CI watched to green — full R-CMD-check matrix +
  `pkgdown`/`test-coverage`/`codecov` green, only the long-standing
  non-blocking `lint` red; PR body used “Relates to \#13” with no
  closing keyword, so \#13 stayed CLOSED). The three deeper item-3
  follow-ups remain UNIMPLEMENTED on the backlog — this session
  documented their limits, it did not implement them.

### 2026-06-27 — Completed the issue \#13 merge arc: merged Slices 2 + 3 to master; \#13 CLOSED (Session 218)

- **Deliverable (owner pick: “merge PR \#90”, then “Reopen, then merge
  PR \#91”; single admin item):** completed the outward-facing merge arc
  for issue \#13 — all three slices are now on `master` and **issue \#13
  is CLOSED** (via PR \#91, with Slice 3 actually merged). **Admin /
  merge session — TDD code-phases N/A** (two PR merges + issue-state
  admin + close-out docs only; no `R/`/test/`NAMESPACE`/`man`/`data`
  change). **0 stakeholder corrections / 0 owner overrides.**
- **Merged PR \#90 (Slice 2) carefully** (Learning 202 §0 practice):
  confirmed `MERGEABLE` / `UNSTABLE` with the **full R-CMD-check matrix
  green** (macOS, Windows, Ubuntu devel/oldrel-1/release;
  `pkgdown`/`test-coverage`/`codecov/project`) and surfaced that the
  only reds are the known non-blocking `lint` + `codecov/patch` before
  merging. **Merge commit `9bf615e9`** (matching the PR \#89 precedent);
  **kept the base branch** to protect the stacked PR \#91.
- **Accidental issue close caught + handled:** merging PR \#90
  **auto-closed \#13**, because \#90’s body contains the literal
  `closes #13` substring (inside “Slice 3 closes \#13”) — GitHub treats
  any `closes/fixes/resolves #N` in a PR body as a closing keyword and
  fires it on merge to the default branch. Since Slice 3 was not yet
  merged, \#13 read “done” prematurely. **Surfaced as an owner
  `AskUserQuestion`** (reopen-and-pause / reopen-then-merge-#91 /
  leave-closed) rather than silently reopening — issue lifecycle is the
  owner’s call. Owner chose “Reopen, then merge PR \#91.”
- **Reopened \#13, then merged PR \#91 (Slice 3):** reopened \#13
  **first** (so \#91’s `closes #13` fires on an OPEN issue → proper
  PR-linked close). Merging \#90 had moved \#91’s base and
  **re-triggered its CI**; **waited for the re-run matrix to go green**
  (`windows-latest (release)` + `ubuntu-latest (devel)` were `pending`)
  rather than merge over a pending correctness signal. **Merge commit
  `7cabd8e1`.** **\#13 is now CLOSED** with Slice 3 on master.
- **Synced local `master`** via `fetch` + `reset --hard origin/master`
  (not `pull`); verified both merge commits and Slice 3’s
  `R/applyKinshipOverridesToMatrix.R` on master; tree clean except the
  standing untracked `PED_GV_AUDIT_2026-05-30.html`.
- **Phase-3E:** N/A for the session’s own work (no `R/`/runtime code
  authored — merged already-tested, CI-green code; the merged code’s
  runtime is covered by S216/S217 Phase-3E and PR \#91’s green
  post-merge matrix). **Build-equivalent not run** (markdown-only
  changes; same logic as the S214 docs-only session).
- **Learning 204** added to `PROJECT_LEARNINGS.md`. **Previous-session
  handoff (S217) scored 9/10.** Carried
  \[\[consult-project-source-of-truth\]\],
  \[\[observation-vs-decision\]\],
  \[\[ascii-only-in-question-options\]\],
  \[\[check-process-history-before-rerunning-work\]\],
  \[\[push-close-out-docs-to-origin\]\].

### 2026-06-27 — Implemented issue \#13 Slice 3: breeding-group + summary-stats fallback kinship-override paths (Session 217, FINAL slice)

- **Deliverable (owner pick: “1” = Slice 3, the final slice that closes
  \#13; single development item):** the secondary-consumer slice of
  issue \#13 per the RATIFIED
  `docs/planning/issue13-kinship-overrides-plan.md` §4 Slice 3 — thread
  outside-information kinship overrides into the breeding-group and
  summary-statistics **fallback recompute** paths so overrides hold
  regardless of tab order. **Strict-TDD DEVELOPMENT session (RED
  `fcdaf20c` → GREEN `21264277`; REFACTOR offered, owner chose skip;
  phase declared each response; all three phase gates via
  `AskUserQuestion`).** **0 stakeholder corrections / 0 owner
  overrides.**
- **Two pre-RED owner scope decisions (surfaced via `AskUserQuestion`,
  not assumed):** (a) **R13 (relation label-vs-value divergence) =
  “narrow + document”** — the override moves the kinship VALUE
  everywhere (matrix, relationship table, CSV export); the relation
  LABEL stays pedigree-derived; **no change to `convertRelationships`**
  (which has other callers); the divergence is documented in roxygen +
  NEWS. (b) **Branching = stack Slice 3 on the unmerged slice2 branch**
  (PR \#90 open) rather than block on a merge.
- **New internal helper
  `applyKinshipOverridesToMatrix(kmat, overrides)`**
  (`R/applyKinshipOverridesToMatrix.R`, `@noRd`): the soft wrapper
  `reportGV` uses inline (intersect the override id-set with
  `rownames(kmat)`, **warn-drop ids absent from the matrix without
  aborting — D5**, then `applyKinshipOverrides`), now shared by both
  modules. `NULL`/empty ⇒ no-op.
- **`modBreedingGroupsServer` + `modSummaryStatsServer` gain a
  `kinshipOverrides = NULL` reactive param;** each module’s
  `getKinshipMatrix` applies overrides **on the fallback recompute
  branch only** (the GV-output / passed-matrix branch already carries
  them via Slice 1/2). Default `NULL` ⇒ byte-identical to before (D10).
- **Plumbing:** `modGeneticValueServer` now **exposes
  `kinshipOverrides`** (the validated upload reactive) in its return
  list; `appServer.R` threads `gvResults$kinshipOverrides` to both
  consumer modules (mirroring `founderStats = gvResults$founderStats`).
  Because reading the upload does not require running the GV analysis,
  overrides hold even when those tabs run first — **removing the slice-2
  “run the GV tab first” caveat (R9).**
- **D11 (issue-#9 correction) does not apply here** — the modules
  consume the raw kinship matrix (group-formation threshold /
  relationship table / export), not the mean-kinship scalar; Slice 3 is
  pure matrix-cell replacement.
- **Tests (RED-first):** new `test_modBreedingGroups_kinshipOverrides.R`
  (3 tests: fallback applies symmetrically; no-override byte-identical —
  D10; non-matrix id warn-drops without aborting — D5) and
  `test_modSummaryStats_kinshipOverrides.R` (4 tests: fallback applies;
  relationship table reflects the override VALUE; **R13 narrow** —
  overriding parent-offspring `(F1,O1)` moves the value to 0.1 but the
  relation LABEL stays “Parent-Offspring”; no-override byte-identical).
  Assertions target the deterministic
  `getKinshipMatrix`/`relationshipData` (the matrix that feeds the
  stochastic `groupAddAssign`), not the RNG-driven group output. All
  failed RED with `unused argument (kinshipOverrides=...)`.
- **Verify:** full clean regression read **0 failed / 0 error** (incl. &
  excl. baseline `test-app-`/`test-e2e-`; 3103 pass / 167 skip);
  `devtools::check(vignettes = FALSE)` **0/0/0**; `spell_check_package`
  **0** (reworded the noun “recomputation” to the verb “recompute”
  rather than pad WORDLIST). **Phase-3E runtime smoke (REQUIRED —
  done):**
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  launches clean and a connected session runs
  [`appServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/appServer.md)
  — instantiating both modules with the new `kinshipOverrides` arg
  without error — and serves the override `fileInput`; the
  override→matrix→table behavior is covered by the `testServer`
  integration tests (a browser file-picker click-through needs a
  GUI/Chrome driver unavailable headlessly — stated, not skipped).
- **Issue state:** committed on branch `issue13-slice3-fallbacks`
  (stacked on `issue13-slice2-shiny-upload`); PR uses **“Closes \#13”**
  (the final slice).
- **Learning 203** added to `PROJECT_LEARNINGS.md`. **Previous-session
  handoff (S216) scored 9/10.** Carried
  \[\[consult-project-source-of-truth\]\],
  \[\[observation-vs-decision\]\],
  \[\[ascii-only-in-question-options\]\],
  \[\[check-process-history-before-rerunning-work\]\],
  \[\[push-close-out-docs-to-origin\]\].

### 2026-06-27 — Implemented issue \#13 Slice 2: outside-information kinship-override upload in the Genetic Value tab (Session 216)

- **Deliverable (owner pick: “merge PR \#89; reopen \#13 and continue
  the work”; single development item = Slice 2):** the app-delivery
  slice of issue \#13 per the RATIFIED
  `docs/planning/issue13-kinship-overrides-plan.md` §4 Slice 2 (D7 =
  Shiny upload). **Strict-TDD DEVELOPMENT session (RED `81dec135` →
  GREEN `d1dabbd6`; REFACTOR offered, owner chose skip; phase declared
  each response; all three phase gates via `AskUserQuestion`).** **0
  stakeholder corrections / 0 owner overrides.**
- **Admin first (owner-directed, outward-facing):** merged **PR \#89**
  (Slice 1) into `master` (merge commit `0438c2d5`) after confirming the
  full R-CMD-check matrix green across all platforms (the red `lint`
  check is the long-standing, non-blocking, whole-codebase informational
  job), and **reopened issue \#13** to track Slices 2–3.
- **New exported reader `readKinshipOverrides(fileName, sep)`**
  (`R/readKinshipOverrides.R`, mirrors `getGenotypes`): reads an
  `id1,id2,kinship` CSV/text/Excel file into a data frame;
  structure/domain validation is `checkKinshipOverrides`’s job, not the
  reader’s.
- **`modGeneticValueUI` gains a `fileInput`** (“Kinship Overrides
  (optional)”, accepts `.csv/.txt/.xlsx/.xls`, with help text stating
  `kinship` is the coefficient *f*, not relatedness *r* = 2*f*).
- **`modGeneticValueServer` gains a soft `kinshipOverrideData`
  reactive** that reads + validates the upload and threads the result
  into the existing
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  call as `kinshipOverrides`. Non-fatal in the app (D5): a malformed
  file is reported via `showNotification` and ignored without aborting
  the GV run; a `> 0.5` warning (D6) is surfaced but the override still
  applies. An explicit [`is.null()`](https://rdrr.io/r/base/NULL.html)
  guard (NOT `req()`) keeps the no-upload path from aborting
  `gvResults()`; no upload ⇒ `NULL` ⇒ rankings identical to before
  (D10).
- **R9 intermediate-state caveat surfaced (NEWS):** until Slice 3 wires
  overrides into the breeding-group / summary-stats fallback recompute
  paths, run the Genetic Value tab first so those tabs consume the
  override-adjusted GV results.
- **Tests (RED-first):** new `test_readKinshipOverrides.R` (reader reads
  the CSV; its output validates) and
  `test_modGeneticValue_kinshipOverrides.R` (`testServer`: a valid
  `(F1,F2,0.4)` upload raises the overridden both-unknown founder’s
  `indivMeanKin` vs an in-test baseline — deterministic since mean
  kinship is read off the matrix, not the gene-drop; a malformed file is
  non-fatal and identical to baseline — D5; no upload is unaffected —
  D10). **Regression caught + fixed inside GREEN:** two issue-#73
  `reportGV` mocks in `test_modGeneticValue.R` hardcoded a signature
  lacking `kinshipOverrides` and errored once the module passed it —
  mock signatures updated to mirror the real `reportGV`.
- **Verify:** full clean regression read **0 failed / 0 error** (incl. &
  excl. baseline `test-app-`/`test-e2e-`);
  `devtools::check(vignettes = FALSE)` **0/0/0**; `spell_check_package`
  **0** (reworded one roxygen possessive rather than pad WORDLIST).
  **Phase-3E runtime smoke (REQUIRED — done):**
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  launches clean and the GV tab serves the new `fileInput` (namespaced
  `geneticValue-kinshipOverrideFile`) in the live page; the
  upload→ranking-change / no-upload / malformed behaviors are covered by
  the `testServer` integration test driving the real server with the
  actual `fileInput` data shape (a browser file-picker click-through
  needs a GUI/Chrome driver unavailable headlessly — stated, not
  skipped).
- **Issue state:** committed on branch `issue13-slice2-shiny-upload`; PR
  uses **“Relates to \#13”** (Slice 2 of 3; Slice 3 closes \#13).
- **Learning 202** added to `PROJECT_LEARNINGS.md`. **Previous-session
  handoff (S215) scored 9/10.** Carried
  \[\[consult-project-source-of-truth\]\],
  \[\[observation-vs-decision\]\],
  \[\[ascii-only-in-question-options\]\],
  \[\[check-process-history-before-rerunning-work\]\],
  \[\[push-close-out-docs-to-origin\]\].

### 2026-06-27 — Implemented issue \#13 Slice 1: outside-information kinship overrides in `reportGV()` (Session 215)

- **Deliverable (owner pick: “implement \#13 Slice 1”; single item):**
  the script-level core of issue \#13 per the RATIFIED
  `docs/planning/issue13-kinship-overrides-plan.md` §4 Slice 1.
  **Strict-TDD DEVELOPMENT session (RED → GREEN; REFACTOR offered, owner
  chose skip; phase declared each response; all three phase gates via
  `AskUserQuestion`).** **0 stakeholder corrections / 0 owner
  overrides.**
- **New exported leaf `applyKinshipOverrides(kmat, overrides)`**
  (`R/applyKinshipOverrides.R`): symmetric-writes each
  `(id1, id2, kinship)` cell (and its twin) into a computed kinship
  matrix; `NULL`/empty ⇒ no-op returning `kmat` unchanged; strict —
  [`stop()`](https://rdrr.io/r/base/stop.html) on an id absent from the
  matrix and on a value above the exact bound `sqrt(diag_ii·diag_jj)`;
  [`message()`](https://rdrr.io/r/base/message.html) the count (D9).
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  is never modified (6-caller blast-radius boundary, D1).
- **New exported validator `checkKinshipOverrides(overrides)`**
  (`R/checkKinshipOverrides.R`, mirrors `checkGenotypeFile`):
  [`stop()`](https://rdrr.io/r/base/stop.html) on missing column,
  NA/negative kinship, `id1 == id2` (D4), duplicate unordered pair;
  **warns** (does not stop) on an off-diagonal value `> 0.5` per the
  two-tier D6 (the exact bound is the leaf’s job); documents `kinship`
  is the coefficient `f`, not relatedness `r`.
- **[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  gains `kinshipOverrides = NULL`** (`R/reportGV.R`, mirroring the \#73
  `breedingTable` `NULL`-default params): after the matrix is built
  (`:118`) and before `meanKinship` (`:124`), it validates, **warn-drops
  override rows referencing ids outside the proband set (D5 — the run is
  not aborted)**, applies the survivors via the leaf, and threads the
  surviving overridden id-set into the issue-#9 correction.
- **D11 (ratified blanket supersession) implemented:**
  `correctUnknownParentMeanKinship()` gains an `overriddenIds` parameter
  and skips the `+ sexMean / 2` add for any overridden one-unknown
  animal (its known outside value supersedes the random-mating prior),
  while non-overridden one-unknown animals keep their correction and
  overridden animals remain valid cohort peers (no cascade — the
  suppression touches only that animal’s own value).
- **Tests (RED-first):** `test_applyKinshipOverrides.R` (12 assertions),
  `test_checkKinshipOverrides.R` (10), and 4 new `reportGV` tests in
  `test_reportGV.R` — the no-override path is byte-identical (D10), a
  non-proband id warn-drops without aborting (D5), and the **4-part D11
  regression** (overridden animal’s add suppressed
  `corrected == original`; a non-overridden one-unknown animal still
  corrected; the overridden animal still a cohort peer;
  suppress-vs-no-suppress differ only at that animal — no cascade) is
  validated against an independent base-R model on real `qcPed` (fixture
  `X=0K7VJN`, `Y=N2XF08`, `Z=K0ACWS`, override 0.25). All fixtures were
  validated firsthand on `qcPed` before the RED tests were frozen.
- **Verify:** full clean regression read **0 failed / 0 error** (incl. &
  excl. baseline `test-app-`/`test-e2e-`);
  `devtools::check(vignettes = FALSE)` **0/0/0**;
  `spell_check_package(".")` **0** (reworded one roxygen word rather
  than pad the shared WORDLIST). **Phase-3E runtime smoke: N/A** (Slice
  1 is script-level; no Shiny/runtime wiring — stated, not skipped).
- **Spec reconciliation (recorded):** the plan’s §4 RED bullet loosely
  said the validator “rejects \> 0.5”; the precise ratified D6/§7 says
  the standalone validator **warns** while the leaf rejects via the
  exact bound. Implemented per D6/§7 and surfaced at the PRE-RED gate.
- **Issue state:** \#13 was CLOSED-as-completed by the owner (2026-06-27
  20:09) before this session; left as-is. Committed on branch
  `issue13-slice1-kinship-overrides` (feat `4a0c3a38`), PR uses
  **“Relates to \#13”** (Slice 1 of 3; Slice 3 closes \#13). Reopen to
  track implementation is the owner’s call.
- **Learning 201** added to `PROJECT_LEARNINGS.md`. **Previous-session
  handoff (S214) scored 9/10.** Carried
  \[\[consult-project-source-of-truth\]\],
  \[\[observation-vs-decision\]\],
  \[\[ascii-only-in-question-options\]\],
  \[\[check-process-history-before-rerunning-work\]\],
  \[\[push-close-out-docs-to-origin\]\].

### 2026-06-27 — Ratified the issue \#13 kinship-overrides design plan; D11 settled via `/grill-me` (Session 214)

- **Deliverable (owner pick: “ratify the \#13 design draft”, then “batch
  recs, grill D11”; single item):** moved
  `docs/planning/issue13-kinship-overrides-plan.md` from **DRAFT →
  RATIFIED**, recording every resolved decision into the doc so the
  Slice-1 RED session can proceed. **Ratification/design session — TDD
  code-phases N/A** (no `R/`, test, `NAMESPACE`, `man/`, `DESCRIPTION`,
  `data/`, or issue-state change; phase declared N/A / PRE-RED each
  response). **0 stakeholder corrections / 0 owner overrides** (every
  recommendation accepted as written).
- **Batch ratification (`AskUserQuestion`, 10 items over 3 calls,
  recommendation-first):** D1 separate leaf
  ([`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  untouched) · D2 schema `id1`/`id2`/`kinship` · D4 off-diagonal only ·
  D5 strict leaf + `reportGV`/app warn-drop of non-member ids · D6
  two-tier range (validator *warns* off-diagonal `> 0.5`;
  `applyKinshipOverrides` *rejects* `> sqrt(diag·diag)`) +
  duplicate-pair [`stop()`](https://rdrr.io/r/base/stop.html) + document
  `f`-not-`r` · D7 Shiny upload (config-path deferred) · D8 scope
  `reportGV → app → fallbacks`, simulations excluded, `gvaConvergence`
  optional · D9 [`message()`](https://rdrr.io/r/base/message.html) count
  · slice order confirmed (1 script core → 2 app upload → 3 fallbacks +
  close \#13).
- **D11 (the \#1 dragon, a genetics call) settled via `/grill-me`,**
  grounded in a 4-agent firsthand analysis (`wf_a3c184ee-92b`:
  correction mechanics + issue-9 S177 rationale + an **executed numeric
  model on real `qcPed`** + synthesis). The analysis **quantified** the
  override/#9-correction stacking (the `+sexMean/2` term ≈ **1 SD** of
  the colony distribution, ~8.4× the override’s own effect, flipping a
  worked animal **GV rank \#6 → \#179**) and **corrected** a
  load-bearing mechanics claim in the S213 draft (the spurious
  `+sexMean/2` is written to `corrected`, never the `original`/`sexMean`
  that peers read, so it **cannot cascade** — contrary to the draft’s
  “propagates into other animals’ corrections”). **Ratified: blanket
  supersession (option A)** — skip `+sexMean/2` for any overridden
  one-unknown-parent animal; **keep** overridden animals as cohort
  peers; **document** the both-unknown-promotion and
  shared-unknown-parent sib-pair edges as v1 limitations; **track
  targeted option C** (suppress only when the override stands in for the
  missing-parent side — needs schema metadata) **as a follow-up**; pin
  with a 4-part regression test.
- **Doc edits (DRAFT → RATIFIED):** status banner + ratification-record
  paragraph; §3 header + per-`Dn` `→ RATIFIED (S214)` tags; D11 fully
  rewritten; Slice-1 scope/RED sharpened to the specific blanket-A
  behavior; §6 R11 + the §7 checklist (all 12 boxes `[x]`).
- **Learning 200** added to `PROJECT_LEARNINGS.md` (ratification
  pattern: batch recs + ground the grill in a firsthand executed
  analysis + offer the premise-reversing option + record the resolved
  spec back into the plan). **Previous-session handoff (S213) scored
  9/10.**
- Carried \[\[consult-project-source-of-truth\]\],
  \[\[observation-vs-decision\]\],
  \[\[ascii-only-in-question-options\]\],
  \[\[check-process-history-before-rerunning-work\]\],
  \[\[push-close-out-docs-to-origin\]\].

### 2026-06-27 — Design document for issue \#13 (assign kinship coefficients from outside information) (Session 213)

- **Deliverable (owner pick: “#13”, then via `AskUserQuestion`
  deliverable = Design document, semantics = pair-level overrides;
  single item):** `docs/planning/issue13-kinship-overrides-plan.md` — a
  design/plan for letting a user inject externally-known kinship
  coefficients into the kinship matrix. **Planning/design session — TDD
  code-phases N/A** (no `R/`, test, `NAMESPACE`, `man/`, `DESCRIPTION`,
  `data/`, or issue-state change; phase declared N/A). **0 stakeholder
  corrections.**
- **Empty-bodied issue → asked, did not invent.** \#13 (filed
  2020-11-20) has only a title. The spec was reconstructed from the
  title + two owner Phase-1 `AskUserQuestion` decisions (deliverable
  shape; pair-level-override semantics). Process-history scan
  (\[\[check-process-history-before-rerunning-work\]\]) found no prior
  \#13 work beyond the S62/S95 backlog audits’ “genuinely open, large”
  classification.
- **Project source of truth for the doc home
  (\[\[consult-project-source-of-truth\]\]):** `DESIGN_WORKSTREAM.md` is
  UI/layout-specific (star component, column balance) — wrong fit for a
  backend feature; the project’s actual convention is
  `docs/planning/issueN-<slug>-plan.md`, so the doc matches the
  issue9/issue73 house style (status banner, firsthand evidence
  inventory, `Dn` decisions with recommendations flagged for
  ratification, vertical slices with RED/GREEN/DONE/Verify/Dragons,
  consolidated dragons, ratification checklist). Drafting and
  ratification are separate sessions; this is the draft.
- **Design core:** a leaf `applyKinshipOverrides(kmat, overrides)` +
  `checkKinshipOverrides` validator, threaded into `reportGV` as a
  `NULL`-default `kinshipOverrides` param (mirroring the `breedingTable`
  params \#73 already added) —
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  (`R/kinship.R:69`) stays untouched (6 callers; the \#9 blast-radius
  boundary). Three vertical slices: (1) script-level core; (2) Shiny
  upload in the GV tab; (3) breeding-group/summary-stats fallback
  paths + close \#13. Every load-bearing `file:line` verified firsthand.
- **Adversarial verification (3-agent workflow over the DRAFT):** core
  symmetric-REPLACE-at-`reportGV:118` mechanism confirmed sound; the
  pass caught 4 real issues my firsthand drafting missed, all folded in
  pre-commit: (a) **D11** — applying before `meanKinship` STACKS the
  override with the issue-#9 `+sexMean/2` correction for the feature’s
  own primary case (one-unknown-parent animals); (b) **D5** —
  `filterKinMatrix` narrows `kmat` to probands, so a strict
  [`stop()`](https://rdrr.io/r/base/stop.html) leaf aborts `reportGV`
  for the canonical sire–dam case → soft-drop must live in `reportGV`,
  not only the file loader; (c) **D6** — `[0,1]` kinship range is too
  loose (off-diagonal `≤ 0.5`; the `r`-vs-`f` confusion silently
  corrupts the matrix); (d) the Slice-3 `convertRelationships` label is
  pedigree-derived, so a value override yields self-contradictory rows.
  New citations re-verified firsthand before folding in (FM \#11).
- **Phase-3E runtime smoke:** N/A (planning doc only; no
  runtime/wiring/`R/` change). Stated, not skipped.
- **Files:** `docs/planning/issue13-kinship-overrides-plan.md` (new);
  close-out — `CHANGELOG.md` (this entry), `PROJECT_LEARNINGS.md`
  (Learning 199), `SESSION_NOTES.md` (handoff). No tracked
  source/test/data files changed.

### 2026-06-27 — Delta re-verification audit of issue \#37 (exported functions not used by the app) (Session 212)

- **Deliverable (owner pick: “Issue \#37 audit”; single item):**
  `docs/audits/ISSUE_37_UNUSED_EXPORTS_AUDIT_2026-06-27.md` — a
  read-only **delta** re-verification of \#37 against the S97 audit
  (2026-06-16), recomputing call-graph reachability at HEAD `600e166d`
  and auditing only what moved. **TDD code-phases N/A** (no `R/`, test,
  `NAMESPACE`, `man/`, `DESCRIPTION`, or issue-state change; phase
  declared N/A each response). **0 stakeholder corrections.** **0 closes
  performed** (closing/updating \#37 is owner judgment, per the report’s
  recommendation).
- **Process-history first
  (\[\[check-process-history-before-rerunning-work\]\]):** \#37 had
  already been audited at S65/S78/S97, and S97 declared the actionable
  surface fully drained. So the non-redundant deliverable was the
  **delta**, not a full re-run.
- **Recompute (documented method —
  `codetools::findGlobals(merge = TRUE)` transitive closure seeded at
  `runModularApp`/`runGeneKeepR`/`appUI`/`appServer`; 220/220 `R/*.R`
  sourced cleanly):** **176 exported / 137 app-used / 39 app-unused**
  (was 166 / 127 / 39 at S97). The unused count held at 39 across the
  fourth re-verification.
- **Delta — exactly 4 exports moved (`39 − 2 + 2 = 39`):** 10 new
  exports since S97 (`calcFGSE`, `calcGUSE`, `getFileDirectRelatives`,
  `getFocalAnimalPedFromFile`, `getSpeciesGestation`,
  `getSpeciesMinBreedingAge`, `gvaConvergence`, `loadSpeciesOverrides`,
  `makeGroupNum`, `setLabKeyDefaults`) — **9 wired into the app at
  birth**; only `gvaConvergence` (a vignette diagnostic helper) is
  app-unreachable → keep-as-public-API. **2 S97 keep-as-public-API
  exports are now app-reached** (`getPedigree`, `getPedDirectRelatives`)
  — wired in *for free* by the file-pedigree-source refactor (first \#37
  export to graduate via an unrelated refactor, not a dedicated
  wire-in). `makeGrpNum` moved *used → unused* by the deliberate **\#29
  rename** — it is now the soft-deprecated alias
  (`.Deprecated("makeGroupNum")` wrapper, `R/makeGroupNum.R:32`);
  keep-as-public-API.
- **Disposition unchanged: 0 wire-in · 39 keep-as-public-API · 0
  retire.** No accidental regression (no previously-reached export fell
  out of the call graph; the one used→unused move, `makeGrpNum`, is the
  intended rename). Logging island stable (0 live callers).
  `safeExecute` + `makeGrpNum` (post-deprecation-cycle) are the only
  conditional future-retire candidates.
- **Adversarial verification:** the 13-export delta was put through a
  26-agent evidence-then-refute workflow; 12/13 verdicts agreed, and the
  one refutation corrected a `loadSpeciesOverrides` downstream-consumer
  mis-attribution but **confirmed “used”** (the function is called
  directly at `appServer.R:74`). Every call path was re-confirmed
  firsthand by the session.
- **Phase-3E runtime smoke:** N/A (read-only audit; no runtime/wiring
  change — no `R/` touched). Stated, not skipped.
- **Recommendation surfaced (owner judgment):** **close \#37** (its
  actionable surface is drained and has stayed drained across two more
  re-verifications) **or keep it open** as the living public-API catalog
  and **refresh its now-staler body** (last updated S98) to the HEAD
  snapshot 176 / 137 / 39.
- **Files:** `docs/audits/ISSUE_37_UNUSED_EXPORTS_AUDIT_2026-06-27.md`
  (new); close-out — `CHANGELOG.md` (this entry), `PROJECT_LEARNINGS.md`
  (Learning 198), `SESSION_NOTES.md` (handoff). No tracked
  source/test/data files changed.

### 2026-06-27 — Verified, documented, and closed issue \#88: the GVA article’s published `fgSE` was never stale (Session 211)

- **Deliverable (owner pick: “Verify, document, close”; single item):**
  dispose of issue \#88 (“the GVA article’s Quarto `_freeze` is stale →
  the published article omits `fgSE`”). **Verification + documentation
  session — no production code, no tests; TDD code-phases N/A** (phase
  declared N/A each response). **0 stakeholder corrections.** Owner
  directed “work on issue \#88” at Phase 1; one `AskUserQuestion`
  disposition gate (the issue premise was found false) → owner chose
  **“Verify, document, close.”**
- **Finding — the issue premise was FALSE for the published site.** The
  live article already renders all three values:
  `fe 109.67 / fg 47.62 / fgSE 0.29`
  (`https://rmsharp.github.io/nprcgenekeepr/articles/genetic-value-analysis.html`).
  Three independent confirmations: (1) the live page shows `fgSE`; (2)
  `pkgdown.yaml` does a clean `checkout@v4` with **no freeze
  restore/cache step** and installs the current source via `local::.`,
  so CI **re-executes every article fresh** (the freeze lives under
  gitignored `.quarto/`, `.gitignore:44`, and never reaches CI); (3) the
  pkgdown CI run on the S210 merge **succeeded after `fgSE` shipped**
  (run 28264621260, 2026-06-26 20:52).
- **Root cause of the stale LOCAL freeze (no repo/published impact).**
  The article loads
  [`library(nprcgenekeepr)`](https://rmsharp.github.io/nprcgenekeepr/)
  (the **installed** package); the local renv library held a stale 2.0.0
  that predated `fgSE`
  ([`renv::status`](https://rstudio.github.io/renv/reference/status.html)
  out-of-sync — `calcFGSE` not exported, `reportGV` body has no `fgSE`),
  so `gv$fgSE` was `NULL` at local freeze time. The stale output existed
  only in the gitignored local freeze cache.
- **Action:** cleared the stale local GVA freeze (gitignored,
  regenerable — **commits nothing**; regenerating in place would
  reproduce the stale output since the installed package still lacks
  `fgSE`, so the correct refresh is to clear and let CI / a
  post-`install()` build regenerate it). **Sibling audit:** all 6
  articles publish (HTTP 200); GVA was the only one with a live
  `fgSE`-dependent value (correct); `fg-se-validation` uses static
  recorded numbers (`data-raw/fgSEValidation-results.rds`) so it is
  unaffected. **No sibling is stale on the published site.**
- **Closed issue \#88** as verified-correct with the full explanation.
  **No repo/code change required.**
- **Phase-3E runtime smoke:** N/A (no runtime/wiring change — closed an
  issue + cleared a gitignored cache + docs). The “runtime” equivalent
  (the published article render) was verified directly against the live
  site. **Stated, not skipped.**
- **Files:** close-out only — `CHANGELOG.md` (this entry),
  `PROJECT_LEARNINGS.md` (Learning 197), `SESSION_NOTES.md` (handoff).
  No tracked source/test/data files changed.

### 2026-06-26 — Regenerated the bundled GV example reports to carry `fgSE` and corrected a non-reproducible `fg` (Session 210)

- **Deliverable (owner-directed, single item):** regenerate the two
  bundled Genetic Value reports (`data/qcPedGvReport.RData`,
  `data/pedWithGenotypeReport.RData`) so they carry `fgSE` (added to
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)’s
  return in S208) and make the necessary corrections. **Strict TDD**
  (RED → GREEN; phase declared each response; PRE-RED→RED + RED→GREEN
  `AskUserQuestion`-gated; the `fg`-correction fork re-surfaced +
  re-gated mid-GREEN; no REFACTOR). **0 stakeholder corrections.** On
  branch `regen-bundled-gvreports-fgse`. Commit `e8c6745f`.
- **Discovery — S206 had saved a NON-reproducible `fg`.** The bundled
  `fg` was `52.7641277`, but the documented recipe
  (`set_seed(10); reportGV(ped, guIter = 10000)`) deterministically
  yields **`52.7546854`** (display `52.75`) at BOTH S206’s own code
  state (commit `83d8640d`, verified in an isolated `git worktree`) and
  HEAD. So S206’s value was a contaminated RNG-state artifact, never
  reproducible from its own recipe — and was the value S206’s
  investigation agent originally computed before S206 “corrected” it.
  The regeneration adopts the reproducible value, making the bundled
  data match its documented recipe for the first time. `fe`
  (deterministic) unchanged at `77.0402760`; new `fgSE` = `0.0130413278`
  (display `0.01`).
- **Purely additive to the user-visible tables.** Old-vs-new comparison:
  `$report` (`gu`/`rank`/`value`), the `$gu` vector, and `$kinship` are
  byte-identical (`gu` is integer-percent, too coarse to register the
  small gene-drop difference; kinship is deterministic). ONLY `fg`
  changed (+ `fgSE` added). **No vignette or `@example` output changes**
  — confirmed: no vignette/example reads `fg` from these objects (the
  GVA article computes `fg`/`fgSE` LIVE on `examplePedigree`, not the
  bundled reports).
- **Tests (RED-first):** added a bundled-report `fgSE`
  present/finite/\>0 assertion (`test_reportGV.R`) + a
  [`summary()`](https://rdrr.io/r/base/summary.html) `52.75 +/- <SE>`
  surfacing assertion (`test_summary.nprcgenekeeprGV.R`); rewrote the
  absent-`fgSE` backward-compat fixture to STRIP `fgSE` from a copy
  (degrade-to-bare-FG tested independent of the bundled object);
  corrected the \#86 value pin `52.7641277 → 52.7546854` and the
  `52.76 → 52.75` display patterns. `test_modSummaryStats.R` unchanged
  (synthetic `52.76` fixture, independent of bundled data).
- **`resaveRdaFiles` scoped to the two files** —
  `tools::resaveRdaFiles("data/")` recompresses the WHOLE directory
  (touched all 19 `.RData`); restored via `git checkout -- data/` and
  re-ran scoped to the two report paths so only they changed.
- **Verify:** `devtools::check(vignettes=FALSE)` = **0/0/0** (ran all
  `@examples` + spelling); full suite **0 failed / 0 error**;
  `spell_check_package(".")` = **0**; only `data/qcPedGvReport.RData` +
  `data/pedWithGenotypeReport.RData` modified. **Phase-3E:** the
  `test_summary` assertion drives the real
  [`summary()`](https://rdrr.io/r/base/summary.html) render on the
  regenerated object showing `52.75 +/- 0.01` — runtime path exercised.
- **Follow-up filed:** issue **\#88** — the GVA article’s Quarto
  `_freeze` cache is stale (frozen output omits `fgSE`, predating S208);
  a doc-cache re-render, found incidentally, NOT caused by this change.
- **Files:** `data/qcPedGvReport.RData`,
  `data/pedWithGenotypeReport.RData`, `tests/testthat/test_reportGV.R`,
  `tests/testthat/test_summary.nprcgenekeeprGV.R`, `NEWS.md` (commit
  `e8c6745f`); close-out — `CHANGELOG.md` (this entry),
  `PROJECT_LEARNINGS.md` (Learning 196), `SESSION_NOTES.md` (handoff).

### 2026-06-26 — Published the issue \#82 branch: opened PR \#87 (FG `+/- SE` + \#86 fix) for owner merge; **\#82 and \#86 close on merge** (Session 209)

- **Deliverable (owner pick, single item):** the \#82 PUBLISH session —
  land the whole `issue-82-fgse` branch (Slice 1 `calcFGSE` + D2 guard /
  \#86 founder name-align / Slice 2 validation gate / Slice 3 surface
  `FG +/- SE`) on `master`. **Publish session** — no production code
  changed; TDD code-phases N/A (added the deferred `NEWS.md` bullets +
  close-out docs). **0 stakeholder corrections.** Owner directed “#82
  PUBLISH session” at Phase 1, then chose **“open PR, you merge it”** +
  **“merge commit, keep S205-S208”** at the publish-method
  `AskUserQuestion`.
- **NEWS.md bullets added (the Learning 157a deferral, realized at
  publish):** two **Changes** bullets — FG now shown as `FG +/- SE`
  across the GV report, Shiny summary, text
  [`summary()`](https://rdrr.io/r/base/summary.html), and
  [`makeFounderStatsTable()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeFounderStatsTable.md)
  HTML, with
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  returning `fgSE`; and the **\#86 correctness fix** (calcFG/calcFEFG
  founder alignment; bundled `qcPedGvReport`/`pedWithGenotypeReport`
  `fg` corrected 39.92 → 52.76) — plus one **New features** bullet
  (exported
  [`calcFGSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md)),
  mirroring the
  `guSE`/[`calcGUSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md)
  precedent. Commit `df7d54eb`.
- **Merge gate re-run on the branch TIP (authoritative, not a stale
  slice’s gate):** `devtools::check(vignettes = FALSE)` = **0 errors / 0
  warnings / 0 notes** (Status: OK); full suite **0 failed / 0 error**
  (true offenders excl. `test-app-`/`test-e2e-` baseline = 0);
  `spell_check_package(".")` = **0**. Ran in the background while the
  owner answered the publish-method question.
- **PR \#87** (`https://github.com/rmsharp/nprcgenekeepr/pull/87`): base
  `master`, head `issue-82-fgse`, body carried `Closes #82` and
  `Closes #86`. **Verified GitHub linked BOTH** via the GraphQL
  `closingIssuesReferences` query (the
  `gh pr view --json closingIssuesReferences` field is unavailable in
  the installed gh). Body instructed **“Create a merge commit” (not
  squash)** to preserve S205-S208.
- **Merged in-session at the owner’s direction** (changed from the “you
  merge it” pick): `gh pr merge 87 --merge` → **PR \#87 MERGED** (merge
  commit `a841ff1f`, “Merge pull request \#87 from
  rmsharp/issue-82-fgse”; the four slice commits + the two S209 commits
  preserved) → **\#82 and \#86 CLOSED**. `master` advanced `19e4b3d2` →
  `a841ff1f`; local resynced via
  `git fetch origin && git reset --hard origin/master`; the merged
  `issue-82-fgse` branch deleted locally and on origin. **Issue \#82 +
  \#86: DONE and shipped to `master`.**
- **Phase-3E runtime smoke:** N/A for the publish action (no
  runtime/wiring change — merges already-smoke-tested code; S208 drove
  the `FG +/- SE` UI end-to-end on real `reportGV(qcPed)` data,
  re-confirmed by this session’s green `check` + suite). **Stated, not
  skipped.**
- **Files:** edited `NEWS.md` (publish commit `df7d54eb`); close-out —
  `CHANGELOG.md` (this entry), `PROJECT_LEARNINGS.md` (Learning 195),
  `SESSION_NOTES.md` (handoff). `master` stays at `19e4b3d2` ==
  origin/master (no local-ahead drift); the close-out commit rides the
  PR branch to origin. **Issue \#82 + \#86: OPEN until PR \#87 merges.**

### 2026-06-26 — Implemented Slice 3 of issue \#82: surface `FG +/- SE` (report + Shiny + text + HTML + docs) (Session 208)

- **Deliverable (owner pick, single item):** Slice 3 of the ratified
  \#82 plan — surface the founder-genome-equivalent sampling SE
  ([`calcFGSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md),
  Slice 1; calibrated in Slice 2) wherever FG is shown, as the ratified
  **inline `FG +/- SE`** (ASCII, 2-decimal SE). **Strict TDD** (RED →
  GREEN; phase declared each response; PRE-RED scope + PRE-RED→RED +
  RED→GREEN all `AskUserQuestion`-gated; no REFACTOR — the four display
  sites’ bare-FG formats differ, so a shared formatter would force a
  behavior change). **0 stakeholder corrections.** Additive —
  golden-master FG/FE byte-unchanged. On LOCAL branch `issue-82-fgse`
  (continues Slice 1 + \#86 + Slice 2) — NOT on master, NOT pushed;
  publishes with the whole \#82 branch (FM \#18). **Issue \#82 stays
  OPEN** (publish session remains).
- **Compute/return (`R/reportGV.R`):** after
  [`calcFEFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md),
  compute `fgSE <- calcFGSE(ped, alleles)` from the SAME gene drop and
  return it next to `fg` (a single colony-level scalar — NOT a
  per-animal `$report`/`$gu` column, plan F2); `@return` documents it.
  `NA` (with warning) on zero-retention degeneracy, same as FG.
- **Display (inline `FG +/- SE`, each surface guarded on `fgSE` present
  & finite → else bare FG):** GV-tab summary (`modGeneticValue`
  `output$gvSummary`) + `founderStats()` re-export (`fgSE = fr$fgSE`);
  Summary-Statistics founder table (`modSummaryStats`); text
  `summary.nprcgenekeeprGV`; `makeFounderStatsTable` HTML (+`@param`).
  Owner-ratified format `52.79 +/- 0.05`.
- **Backward-compat:** bundled `pedWithGenotypeReport`/`qcPedGvReport`
  left **unchanged** (owner pick — additive, not regenerated); display
  degrades to bare FG for objects predating `fgSE`.
- **Docs (D6 broadest):** added the FG-SE note + finite-K (Jensen)
  caveat to `genetic_value.html`; reconciled
  `population_genetics_terms.html`, `summary_stats.html`, the GVA
  article (`vignettes/articles/genetic-value-analysis.qmd`, now also
  prints `fgSE`), and `_summary_statistics.Rmd`. (`gvAndBgDesc.html` and
  `_genetic_value_analysis.Rmd` describe no FG — nothing to reconcile.)
- **Tests:** new `test_makeFounderStatsTable.R`; `fgSE` integration in
  `test_reportGV.R` (scalar, finite, \>0 on qcPed; not in
  `$report`/`$gu`; two structure name-pins updated to include `fgSE`);
  inline + backward-compat/NA cases in `test_summary.nprcgenekeeprGV.R`;
  display + guidance-content + `founderStats()$fgSE` in
  `test_modGeneticValue.R`; founder-table display in
  `test_modSummaryStats.R`.
- **Verify:** full suite 0 failed / 0 error;
  `devtools::check(vignettes=FALSE)` = 0/0/0; `spell_check_package` = 0;
  lintr clean on touched lines; GVA article renders. **Phase-3E runtime
  smoke PASSED** — all four display surfaces render `FG +/- SE`
  end-to-end on real `reportGV(qcPed)` data (e.g. `52.79 +/- 0.04`).
  `document()` also corrected two stale auto-`@format` lines
  (`pedWithGenotypeReport.Rd`/`qcPedGvReport.Rd`: class + length 10),
  incidental to S206’s data regen.

### 2026-06-26 — Implemented Slice 2 of issue \#82: the `calcFGSE()` validation gate (multi-seed study; PASS) (Session 207)

- **Deliverable (owner pick, single item):** Slice 2 of the ratified
  \#82 plan — the “validate before expose” gate that proves the
  founder-genome-equivalent sampling SE
  ([`calcFGSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md))
  is calibrated on a real deep pedigree before it is surfaced (Slice 3).
  **Strict TDD** (RED → GREEN; phase declared each response; PRE-RED
  scope + PRE-RED→RED + RED→GREEN all `AskUserQuestion`-gated; no
  REFACTOR — the harness is cohesive). **0 stakeholder corrections.** On
  LOCAL branch `issue-82-fgse` (continues Slice 1 + \#86) — NOT on
  master, NOT pushed; publishes with the whole \#82 branch (FM \#18).
  **Issue \#82 stays OPEN** (Slice 3 + publish remain).
- **Gate result — PASS on both pedigrees, all seven checks.** `lacy1989`
  (fast deterministic anchor): agreement `mean(SE)/sd(FG)` 1.0076,
  coverage 0.9333, scaling emp/delta 1.846/2.004, degeneracy 0,
  bootstrap 0.9910, off-diag full/diag 1.001. `examplePedigree` (the
  real deep/bottlenecked ped): agreement 1.0169, coverage 0.9500,
  scaling 1.981/2.008, degeneracy 0, bootstrap 1.0043, off-diag
  full/diag **0.692**. So
  [`calcFGSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md)
  is calibrated — it matches the Monte Carlo spread of FG, covers a
  high-K reference at ~95%, shrinks as 1/√K, never reports a finite SE
  for a collapsed FG, and agrees with an independent column bootstrap.
- **Headline finding (off-diagonal materiality, Dragon D-4/D-5):** on
  the real pedigree the diagonal/independence SE approximation
  **overestimates by ~45%** (`0.0945/0.0654`), vs 0.1% on lacy —
  confirming the ~46% Learning-189 prediction. The full covariance-aware
  influence form is mandatory, and validating on `lacy1989` alone would
  have falsely blessed the diagonal shortcut. The validation pedigree
  was chosen by **measuring** the off-diagonal/bottleneck signature
  (examplePed full/diag 0.692, min r 0.013 with 5 founders r\<0.10) —
  qcPed (full/diag 1.013, min r 0.50) structurally cannot exercise it,
  so it was rejected, not posed as an owner question.
- **Harness design (purely additive — zero new `R/` source, golden
  master untouched):** the validation harness lives in
  `tests/testthat/helper-fgSEValidation.R` (pure scorers
  `fgSEAgreementRatio`/`fgSECoverage`/`fgSEScalingRatio`/`fgSEFullFromMatrix`/`fgSEDiagFromMatrix`/`fgSEBootstrapFromMatrix`/`fgSEVerdict` +
  orchestrator `fgSEValidate`); `fgSEFullFromMatrix` is pinned equal to
  the shipped
  [`calcFGSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md)
  so the study validates what users get. The slow B=300-seed study runs
  once via the build-ignored `data-raw/fgSEValidation.R` runner
  (reproducible, fixed seeds, ~7 min); the recorded numbers are embedded
  statically in the pkgdown article
  `vignettes/articles/fg-se-validation.qmd`.
- **Tests (RED-first, 8 tests / 45 assertions failing for the right
  reason — functions undefined — before GREEN):**
  `tests/testthat/test_fgSEValidation.R` covers the pure scorers
  (hand-computed answers), the full-vs-diagonal
  equality-iff-uncorrelated property, the harness-ties-to-shipped
  equality (`fgSEFullFromMatrix == calcFGSE` on lacy), bootstrap
  determinism + tracking, the verdict bands (PASS in-band / FAIL
  out-of-band), and the orchestrator’s shape + determinism. One RED test
  had a floating-point boundary bug (`11.96 - 10` ≠ `1.96`); corrected
  the test constants to exactly-representable values during GREEN
  (implementation was correct).
- **Verify:** full suite 0 failed / 0 error (incl. the 8 new tests);
  `devtools::check(vignettes = FALSE)` = 0/0/0;
  `spell_check_package(".")` = 0 (added
  `bottlenecked`/`diag`/`retentions` to `inst/WORDLIST` via radix sort,
  +3-line diff); `lintr` 0 on the new files; the article renders (quarto
  1.7.33). **Phase-3E runtime smoke: N/A** — Slice 2 changes no runtime
  behavior (no `R/` source, no wiring/startup/dispatch; the harness is
  test infra, the runner/rds/article are build-ignored);
  [`calcFGSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md)
  is surfaced in Slice 3.
- **Files:** NEW `tests/testthat/test_fgSEValidation.R`,
  `tests/testthat/helper-fgSEValidation.R`, `data-raw/fgSEValidation.R`,
  `data-raw/fgSEValidation-results.rds`,
  `vignettes/articles/fg-se-validation.qmd`; edited `inst/WORDLIST` (+3
  words); close-out — `CHANGELOG.md` (this entry),
  `PROJECT_LEARNINGS.md` (Learning 193), `SESSION_NOTES.md` (handoff).
  **Issue \#82 OPEN; the SE is cleared to surface in Slice 3.**

### 2026-06-26 — Fixed issue \#86: `calcFG`/`calcFEFG` founder positional misalignment (wrong `fg` on unsorted-founder pedigrees) + regenerated bundled reports (Session 206)

- **Deliverable (owner pick, single item):** the founder-alignment bug
  S205’s adversarial review found. **Strict TDD** (RED → GREEN; every
  transition `AskUserQuestion`-gated; phase declared each response; no
  REFACTOR — two minimal one-liners). **0 stakeholder corrections.** On
  LOCAL branch `issue-82-fgse` (continues Slice 1) — NOT on master, NOT
  pushed; publishes with the \#82 work (FM \#18). **Issue \#86 stays
  OPEN** until the branch merges.
- **The bug:** `calcFG.R`/`calcFEFG.R` divided the founder-contribution
  vector `p` (in
  [`getFounders()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFounders.md)
  pedigree-row order) by the retention vector `r` (id-sorted via
  `tapply`) BY POSITION, so `FG = 1/sum(p^2/r)` paired the wrong
  founders on any unsorted-founder pedigree. The \#82 zero-retention
  guard already name-aligns, but the point estimates did not. Confirmed
  firsthand: on the crafted unsorted fixture the shipped code returned a
  **silent `FG = 0`** (a contributor with `p=0.25` paired against a
  phantom `r=0` → `Inf` → `1/Inf = 0`, with NO warning — the guard does
  not fire because the truly-unretained founder has `p=0`), so \#86 also
  closes a second degeneracy path the \#82 guard misses.
- **The fix:** one line in each function — `r <- r[names(fc$p)]` before
  the sum (the same name-alignment
  [`calcFGSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md)/`checkFgDegeneracy()`
  already use). Golden master `lacy1989` FG = `2.180096626`
  byte-unchanged (sorted founders); FE (no retention term) unaffected
  everywhere.
- **Data regenerated (owner pick: full recipe regen):** the only two
  bundled objects embedding `fg` — `qcPedGvReport` and
  `pedWithGenotypeReport` — re-saved via the documented recipe
  `set_seed(10); reportGV(<ped>, guIter = 10000)` under the fixed code:
  `fg` corrected **39.9164644 → 52.7641277** (both reports), `fe`
  unchanged at `77.0402760`; the regeneration also refreshes the
  otherwise-stale objects (they predated `guSE` / `nMaleFounders` /
  `nFemaleFounders` / `parentage`).
  [`tools::resaveRdaFiles()`](https://rdrr.io/r/tools/checkRdaFiles.html)
  kept compression optimal.
- **Tests (RED-first, 6 new assertions failing for the right reason
  before GREEN):** alignment value-pin (`32/21` on the unsorted
  fixture), silent-collapse-closed, and order-invariance blocks in
  `test_calcFG.R` / `test_calcFEFG.R`; bundled-report `fg ≈ 52.76`
  (`> 50`, not the old 39.92) + refreshed-structure blocks in
  `test_reportGV.R`.
- **Blast-radius audit (ultracode 4-agent workflow + firsthand
  spot-checks):** exactly 2 bundled objects embed `fg`; NO
  source/test/vignette hardcodes the old/new values (only process-doc
  narrative); 0 tests break on the value change or the structure refresh
  (`test_reportGV.R` already pins the current full structure). The
  documented recipe is reproducible, and `set_seed(10)` (the package
  wrapper, `sample.kind="Rounding"`) and base `set.seed(10)` give the
  identical draw in this pipeline (verified, not assumed — `set_seed` is
  a real function, not a typo).
- **Verify:** `devtools::check(vignettes = FALSE)` = 0/0/0 (data passes
  the ASCII/compression check); full suite 1045 tests, 0 failed / 0
  error; `spell_check_package(".")` = 0; golden-master FG + both `$fe`
  byte-unchanged. **Phase-3E runtime smoke:** the app surfaces a FRESH
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  `$fg` (now correct); the reportGV end-to-end path is exercised by the
  suite + `--run-donttest` examples; no startup/wiring/dispatch/config
  changed, so no UI launch required (stated, not skipped).
- **Files:** edited `R/calcFG.R`, `R/calcFEFG.R`,
  `tests/testthat/test_calcFG.R`, `test_calcFEFG.R`, `test_reportGV.R`;
  regenerated `data/qcPedGvReport.RData`,
  `data/pedWithGenotypeReport.RData`; close-out — `CHANGELOG.md` (this
  entry), `PROJECT_LEARNINGS.md` (Learning 192), `SESSION_NOTES.md`
  (handoff). **Issue \#86 fixed-on-branch (OPEN until merge); issue \#82
  OPEN.**

### 2026-06-26 — Implemented Slice 1 of issue \#82: `calcFGSE()` (`fg` sampling SE) + the D2 zero-retention guard (Session 205)

- **Deliverable (owner pick, single item):** Slice 1 of the ratified
  \#82 plan — the founder-genome-equivalent sampling-SE math core.
  **Strict-TDD** (RED → GREEN → REFACTOR, every transition
  `AskUserQuestion`-gated; phase declared each response). **0
  stakeholder corrections.** On LOCAL branch `issue-82-fgse` — NOT
  published (the publish PR is the final \#82 session, FM \#18). **Issue
  \#82 stays OPEN** (Slices 2–3 remain).
- **New `R/calcFGSE.R` (influence/score-form delta SE):** returns one
  scalar — the colony FG sampling SE — via
  `sd(crossprod(g, R)) / sqrt(K)` with `g_f = FG^2 * p_f^2 / r_f^2`,
  folding in the within-iteration founder covariance without forming the
  F×F matrix (plan Section 2.5). Name-aligned (Dragon D-3). HARD-FAIL
  `NA` + warning when a contributing founder (`p>0`) has `r==0`; drops
  non-contributing (`p==0` → `0/0`) founders so the SE refers to the
  same founder set as FG. On `lacy1989` = `0.00621305577`.
- **D2 silent-collapse guard (`R/checkFgDegeneracy.R`, `@noRd`):** a
  shared name-aligned check folded into `calcFG`/`calcFEFG` — a
  contributing founder retained in 0 drops (`p^2/0 = Inf`, and `na.rm`
  strips only `NaN`) now yields `FG = NA` + warning instead of a silent
  0; `calcFEFG`’s `FE` stays valid. The point-estimate formula is
  UNCHANGED for healthy pedigrees (golden master `lacy1989` FG =
  2.180096626 / FE = 2.909090909 held).
- **Tests (RED-first, 11 new assertions all confirmed failing for the
  right reason before GREEN):** new `tests/testthat/test_calcFGSE.R` (6
  groups: exact value vs an INDEPENDENT sandwich-form oracle;
  deterministic column-doubling shrinkage `sqrt((K-1)/(2K-1))`;
  scalar/finite/≥0; founder-order alignment on an unsorted-founder
  fixture; crafted degeneracy fixtures (D5) hard-fail + clean `p==0`
  drop; seeded column-bootstrap agreement within 15%) + crafted fixtures
  and the sandwich oracle in `helper-fgSEFixtures.R`; D2 guard tests
  appended to `test_calcFG.R`/`test_calcFEFG.R`.
- **Wiring/docs:** `@export` + `NAMESPACE` + `man/calcFGSE.Rd` +
  `inst/_pkgdown.yml` (2 blocks); `calcFG`/`calcFEFG` `@return` document
  the NA-on-degeneracy behavior; stale `n=5000` examples → `n=1000`
  (F7/D-9). (Note: `calcGUSE`, the precedent, is NOT in `_pkgdown.yml` —
  a pre-existing gap, left as-is.)
- **Adversarial review (ultracode) surfaced a MATERIAL pre-existing bug
  → filed issue \#86:** `calcFG`/`calcFEFG` combine `p` (getFounders
  order) and `r` (id-sorted) by POSITION, so FG is wrong on
  unsorted-founder pedigrees — `qcPed` ships **39.92** vs correct
  **52.79**; the wrong value is baked into
  `pedWithGenotypeReport`/`qcPedGvReport` (`fg = 39.916464`). The suite
  never caught it (it pins `fg` only as a column *name*, not a value, on
  the unsorted fixtures; `lacy1989`/`smallPed` founders are sorted). Out
  of Slice 1’s ratified scope (needs shipped-data regeneration) → filed
  as **\#86**, which MUST land before \#82 Slice 3 surfaces `FG ± SE`
  (else a wrong FG pairs with a correct SE). The new name-aligned guard
  does NOT catch this positional path.
- **Verify:** `devtools::check(vignettes = FALSE)` = 0/0/0; full suite 0
  failed / 0 error (2356 passed); `spell_check_package(".")` = 0;
  golden-master FG/FE unchanged; `calcFGSE` == the independent oracle.
  **Phase-3E runtime smoke: N/A** (calcFGSE is not yet surfaced — no
  UI/startup/dispatch change; surfacing is Slice 3).
- **Files:** NEW `R/calcFGSE.R`, `R/checkFgDegeneracy.R`,
  `tests/testthat/test_calcFGSE.R`,
  `tests/testthat/helper-fgSEFixtures.R`, `man/calcFGSE.Rd`; edited
  `R/calcFG.R`, `R/calcFEFG.R`, `NAMESPACE`, `man/calcFG.Rd`,
  `man/calcFEFG.Rd`, `inst/_pkgdown.yml`,
  `tests/testthat/test_calcFG.R`, `test_calcFEFG.R`; close-out —
  `CHANGELOG.md` (this entry), `PROJECT_LEARNINGS.md` (Learning 191),
  `SESSION_NOTES.md` (handoff). **Issue \#82 OPEN; issue \#86 NEW.**

### 2026-06-25 — Ratified the issue \#82 plan (D1–D6 + slice plan) — `docs/planning/issue82-fg-se-plan.md` (Session 204)

- **Deliverable (owner pick, single item):** owner ratification of the
  six decisions (D1–D6) and the slice plan in the S203 `fg`-SE plan.
  **Ratification session** — the recorded decisions ARE the deliverable;
  TDD code-phases N/A (no production code); implementation (Slice 1) is
  a separate session (FM \#18). **0 stakeholder corrections.** Owner
  directed “ratify the \#82 plan (D1–D6)” at Phase 1.
- **Adversarial re-verification before posing (ultracode, 3-agent
  workflow `wf_3d099409-d67`):** before forwarding the recommendations,
  re-grounded the load-bearing facts firsthand (confirmed the
  `calcFG.R:61`/`calcFEFG.R:52` silent-collapse bug — `p^2/0=Inf`,
  `na.rm` strips `NaN` not `Inf`; the `calcRetention.R:43`
  id-sort-vs-position misalignment; the `calcGUSE` precedent) and ran
  one independent reviewer per decision-pair to try to find a flaw or an
  unshown tradeoff. **All six verdicts: sound.** Two useful catches: (1)
  **D4’s recipe pseudocode contradicted its own policy** — Section 2.5’s
  `keep <- rhat > 0` silently implemented *soft-success* while the text
  specified *hard-fail*; surfaced as the explicit owner choice. (2) **D6
  doc-reconciliation scope was ambiguous** (include the longer-form
  docs + vignette?) — surfaced as a 3-way scope choice.
- **Ratified outcomes (recorded in the plan, Section 5.1 + checked
  Section 9):** **D1** influence-form delta SE + mandatory bootstrap
  cross-check (accepted); **D2** fold the silent-collapse guard into
  Slice 1 (not a separate issue); **D3** surface in all 5 places,
  display **inline `FG +/- SE`**; **D4 HARD-FAIL** — `any(p>0 & r==0)` →
  `NA` + warning for FG *and* SE, advise raising K (NOT soft-drop), skew
  threshold `n_f<~5-10` adopted as a documented heuristic; **D5** build
  the crafted deterministic fixture; **D6 broadest** doc scope (all FG
  surfaces incl. `gvAndBgDesc.html` + the GVA vignette); **slice plan**
  confirmed (4 sessions, compute → validate → surface).
- **Plan reconciled to the ratified choices:** Status flipped to
  RATIFIED; Section 2.5 recipe step 5 gained an explicit pre-`keep`
  hard-fail guard so the executor codes the ratified behavior (matching
  Section 2.6 case 3), not the soft-success the old pseudocode implied;
  Slice 3’s doc list expanded to the broad D6 set.
- **Files:** `docs/planning/issue82-fg-se-plan.md` (ratification
  recorded: Status, Section 2.5 recipe, Section 5.1, Slice 3, Section
  9); close-out — `CHANGELOG.md` (this entry), `PROJECT_LEARNINGS.md`
  (Learning 190), `SESSION_NOTES.md` (handoff). No code changed; nothing
  implemented (FM \#18). **Issue \#82 stays OPEN** — Slice 1 is the next
  session.

### 2026-06-25 — Planned issue \#82: sampling SE for founder genome equivalents (`fg`) — `docs/planning/issue82-fg-se-plan.md` (Session 203)

- **Deliverable (owner pick, single item):** a planning document for
  issue \#82 (the `fg`-SE follow-up deferred from \#2, D6/Finding 5).
  **Planning session** — the plan IS the deliverable; TDD code-phases
  N/A (no production code); implementation is separate sessions (FM
  \#18). **0 stakeholder corrections.** Owner picked “#82” at
  orientation and “Planning session” at the scope gate.
- **Research (ultracode workflow `wf_8672ccdd-2bf`, 8 agents):**
  evidence-based grep inventory of every
  `fg`/`FG`/`calcFG`/`calcFEFG`/`calcRetention` surface; an end-to-end
  trace of the `calcGUSE`/`guSE` wiring precedent; tests/fixtures
  survey; current-FG-surfacing map; a 3-way INDEPENDENT delta-method
  derivation panel; and an adversarial math reconciler that **ran R** to
  verify the gradient by finite differences against `calcFG` and
  empirically validate the recommended estimator on `lacy1989Ped`
  (agreement ratio 1.020, 95% coverage 0.953, 1/sqrt(K) scaling 1.94).
  Cross-checked against the session author’s own hand-derivation; all
  surfacing line numbers verified firsthand.
- **The math (high confidence):** `FG = 1/sum(p^2/r)` with `p`
  deterministic and only `r` (per-founder gene-drop retention mean)
  stochastic. SE via the delta method in the **influence/score form**
  `fgSE = sd(crossprod(g, R))/sqrt(K)`, `g_f = FG^2*p_f^2/r_f^2`, which
  folds in the (required) within-iteration founder covariance and is
  `O(K*F)`. A naive per-iteration `FG_k` is **degenerate** (a single
  lost founder allele → `Inf` → `FG_k=0`) and must NOT be used.
- **Findings folded into the plan:** (1) **latent silent-collapse bug**
  in `calcFG`/`calcFEFG` — `r_f=0,p_f>0` → `p^2/0=Inf`, and `na.rm=TRUE`
  strips only `NaN` not `Inf` → `FG` silently becomes 0 (likelier at the
  new K=1000); (2) `FG` is a colony-level **scalar**, so the SE is one
  number — no `orderReport` pass-through / per-animal column / issue-#76
  zeroing (unlike `guSE`); (3) the within-iteration covariance is
  **material** (~46% on a deep pedigree vs ~3% on the too-small
  `lacy1989`), so validation must use a real deep pedigree; (4) **no
  fast deterministic fixture** exercises the degeneracy path — the plan
  crafts one; (5) `git grep -niE '\bfg\b'` returns nothing (POSIX ERE
  `\b` is backspace) — use `-w`.
- **Plan structure:** 6 decisions to ratify (D1 estimator, D2 fold the
  bug-guard into the work, D3 surfacing scope, D4 degeneracy policy, D5
  crafted fixture, D6 user-facing docs) + 3 vertical slices (Slice 1
  estimator+guard+fixture → Slice 2 multi-seed validation gate → Slice 3
  surface `FG +/- SE`) each with completion criteria, verification
  commands, and a STOP boundary + an 11-item “here be dragons” + an
  owner-ratification checklist. Expect 4 implementation/publish sessions
  after ratification.
- **Files:** `docs/planning/issue82-fg-se-plan.md` (new); close-out —
  `CHANGELOG.md` (this entry), `PROJECT_LEARNINGS.md` (Learning 189),
  `SESSION_NOTES.md` (handoff). No code changed; nothing published
  (planning session).

### 2026-06-25 — Published Slice 3 of issue \#2: default 5000→1000 + doc reconciliation merged to `master` via PR \#85; **issue \#2 CLOSED** (Session 202)

- **Deliverable (owner pick, single item):** publish S201’s Slice 3 (the
  gene-drop iteration default `5000L → 1000L` + the stale-“5000” doc
  reconciliation + the
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
  vignette) from branch `issue-2-slice3-default-reconciliation` to
  `master` via PR, folding a user-facing NEWS *Changes* bullet into the
  SAME PR (Learning 157a). This is the slice whose merge **CLOSES issue
  \#2** (“Closes \#2” is correct and intended here — Learning 184).
  **Publish/docs session** — TDD code-phases N/A every response
  (S199–S201 wrote + tested the code under strict TDD). **0 stakeholder
  corrections.** SOLO (a serial, irreversible git sequence — the
  standing publish-session judgment, held under ultracode). Owner
  directed “Publish Slice 3” at orientation, chose NEWS “Changes bullet
  only” at the content gate, and “Yes, merge PR \#85 now” at the
  `AskUserQuestion` merge gate.
- **NEWS (one PR, Learning 157a):** one dev-version *Changes* bullet
  documenting the FUNCTION-default change
  ([`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)/[`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
  now default to 1000 gene-drop iterations, was 5000; pointer to
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)),
  appended at the END of the dev Changes list (append-don’t-rewrite,
  Learning 171). The only prior “1000” mention sits in the RELEASED
  2.0.0 section and documents the *UI tab* default — left untouched
  (released notes are immutable; the scopes are distinct — Learning
  188). Re-rendered `NEWS.md`
  (`html_preview:false`+`md_extensions:"-smart"`, Learning 155) → pure
  insertion (+6/+6, 0 deletions), 0 non-ASCII, no stray `.html`;
  `spell_check_package(".")` = **0 before AND after** (Learning 175).
  Committed as `af86d38f`.
- **PR + CI (did NOT merge blind, Learning 157b):** opened **PR \#85** →
  `master`. The body was authored in a file and grep-scanned
  (Learning 186) to confirm `Closes #2` is the SOLE closing reference
  (other refs `#82`/`#84` carry no closing keyword); the GraphQL
  `closingIssuesReferences` query independently confirmed the PR would
  close **only \#2**. BOTH `gh pr checks 85 --watch` AND a FRESH
  non-watch re-query returned **all 10 checks PASS** (lint, pkgdown,
  test-coverage, macOS/Windows/Ubuntu release + oldrel-1 + ubuntu-devel,
  `codecov/patch`, `codecov/project`); `mergeStateStatus` UNSTABLE →
  CLEAN.
- **Merge (owner-gated) + issue closed:** fresh pre-merge re-check
  (OPEN/MERGEABLE/CLEAN, head `af86d38f`, `origin/master`==`c77eb540`,
  \#2 OPEN); `gh pr merge 85 --merge` → merge commit **`b2b0c934`**
  (MERGED); immediate post-merge `gh issue view 2` = **CLOSED** (the
  intended close fired correctly on the sole reference).
- **Reconcile (Learning 146):** reverted the uncommitted 1B stub;
  `git checkout master`; `fetch`; ancestor-gated `reset --hard` (both
  old-master `c77eb540` AND branch tip `af86d38f` asserted ancestors of
  `b2b0c934`, and `b2b0c934`==`origin/master`);
  verified-merged-before-delete cleanup (local `-d` “was af86d38f” +
  remote `--delete`; `git ls-remote` empty).
- **Phase-3E (build-equivalent / runtime smoke): SATISFIED.** PR \#85’s
  `R CMD check` ×5 matrix all PASS (stronger than a single local check);
  confirmed FIRSTHAND on `master` after the reset that the deliverable
  is live: the NEWS *Changes* bullet on `NEWS.md`,
  `vignettes/gvaConvergence.Rmd` present, and
  `eval(formals(reportGV)$guIter)` == `eval(formals(geneDrop)$n)` ==
  **1000** at runtime under `load_all`.
- **Files:** `NEWS.Rmd`/`NEWS.md` (in PR \#85 as `af86d38f`); close-out
  — `CHANGELOG.md` (this entry), `PROJECT_LEARNINGS.md` (Learning 188),
  `SESSION_NOTES.md` (this handoff), pushed to origin/master FF. **Issue
  \#2 is now CLOSED** — all three slices (the `guSE` precision column,
  the
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
  diagnostic, and the default + doc reconciliation) are on `master`.

### 2026-06-25 — Implemented Slice 3 of issue \#2: default 5000→1000 + doc reconciliation + `gvaConvergence()` vignette (Session 201)

- **Deliverable (owner pick, single item):** Slice 3 — the slice whose
  merge CLOSES \#2. Implements the ratified D3 decision (align the
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)/[`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
  gene-drop iteration default DOWN from `5000L` to `1000L`, matching the
  Shiny UI default and the NEWS/CHANGELOG claim), reconciles every stale
  “5000” user-facing doc, rewrites the `ColonyManagerTutorial.Rmd` TODO
  into evidence-based guidance, reconciles the two in-app doc surfaces,
  and writes the deferred
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
  vignette. **Strict-TDD implementation** for the code change (RED →
  GREEN, every transition `AskUserQuestion`-gated; the doc
  reconciliation is TDD code-phases N/A). **0 stakeholder corrections.**
  On LOCAL branch `issue-2-slice3-default-reconciliation` — **NOT
  published** (the publish PR, with “Closes \#2”, is a separate session,
  FM \#18/#25). **Issue \#2 stays OPEN** until that merge.
- **The code change (RED→GREEN, `557fe423`):** RED added default-pinning
  tests — `eval(formals(reportGV)$guIter) == 1000L` (`test_reportGV.R`),
  `eval(formals(geneDrop)$n) == 1000L` + a behavioral check that a
  default-`n`
  [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
  run yields exactly 1000 `V` columns (`test_geneDrop.R`) — all failing
  at 5000L for the right reason. GREEN changed the two function defaults
  to `1000L` + the coupled “Default is 5000” roxygen → 1000 and
  regenerated `man/`. Blast radius nil: every `reportGV`/`geneDrop` call
  in the suite passes an explicit `guIter`/`n`, and no internal caller
  relies on the default (`reportGV` and `gvaConvergence` both pass `n`
  explicitly), so the change breaks no value-pinned test; the shipped
  example data (built at 5000/10000) is stored, not regenerated by a
  default change.
- **Doc reconciliation (`1c9f8434`, TDD code-phases N/A):** (a) “we
  usually defined n \>= 5000” guidance → “\>= 1000” (`geneDrop.R`,
  `getGVGenotype.R` + man); (b) stale “default is 5000” docs → 1000
  (`a2interactive.Rmd`, `manual_components/_genetic_value_analysis.Rmd`,
  **`articles/genetic-value-analysis.qmd`** — missed by the plan’s 2D
  grep, which omitted `*.qmd`; caught by the completeness audit);
  illustrative count in `_genome_uniqueness_algorithm.Rmd` aligned to
  1000; (c) test-stub signature mirrors
  (`test_modGeneticValue.R:1529,1579`) synced 5000L→1000L (asserts no
  behavior); (d) `ColonyManagerTutorial.Rmd` verbatim issue-text TODO
  rewritten into evidence-based guidance referencing
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md); (e)
  **doc-surface reconciliation (D5/2F):** `genetic_value.html` now
  references the shipped
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
  (was “a future release will add a tool”); `gvAndBgDesc.html` extended
  with the estimate/`guSE`/precision-vs-order story.
- **New vignette `vignettes/gvaConvergence.Rmd`:** contrasts a
  half-sib-web fixture (selection order needs the higher iteration
  counts to settle) against `qcPed` (converges at the grid floor; no
  rankable `gu` signal), in the `simulatedKValues` kableExtra idiom;
  renders clean, uses only exported functions (`gvaConvergence`,
  `findGeneration`), founders excluded from `pop` (Dragon \#2), prose
  kept qualitative so seed/RNG drift cannot falsify it.
- **Adversarial completeness audit (3-agent workflow) surfaced +
  fixed:** the missed `.qmd` default site (above); a range contradiction
  (“2 to 100,000” vs the modular UI’s 100–10,000) in
  `gvAndBgDesc.html` + `ColonyManagerTutorial.Rmd` → “100 to 10,000”; a
  drift-prone vignette prose tied to a marginal convergence result →
  qualitative + a fuller grid (nMax=3000, to N=1500) showing *sustained*
  convergence; a grammar slip in the reconciled `a2interactive`
  `reportGV` paragraph.
- **Intentionally left per ratified scope (owner: “Core + reconcile
  guidance”):** the deferred-`fg` machinery
  (`calcFG`/`calcFEFG`/`assignAlleles` — `fg` SE is issue \#82) and
  factual data provenance (`lacy1989PedAlleles` genuinely has 5000
  columns; example reports built at `guIter=10000`). The
  `assignAlleles.R` “Default is 5000.” is a pre-existing latent doc
  inaccuracy (`assignAlleles` has no default for `n`) — out of scope,
  like the `getConfigApiKey` comment-strip bug.
- **Verification:** `devtools::check(vignettes = FALSE)` = **0/0/0**
  (verifies man/usage consistency after the default change); full clean
  regression **0 failed / 0 error**; `spell_check_package(".")` = **0**;
  the new vignette renders; completeness grep confirms **no surviving
  `reportGV`/`geneDrop` “default 5000”** across
  `R/ man/ inst/ vignettes/`; Phase-3E firsthand (`reportGV`/`geneDrop`
  default to 1000 at runtime; the GVA tab UI wires the reconciled
  `genetic_value.html` mentioning
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md);
  `gvAndBgDesc.html` carries the reconciled story;
  [`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
  builds).
- **Files:** code (`557fe423`) — `R/reportGV.R`, `R/geneDrop.R`,
  `man/reportGV.Rd`, `man/geneDrop.Rd`,
  `tests/testthat/test_reportGV.R`, `tests/testthat/test_geneDrop.R`.
  Docs (`1c9f8434`) — `R/geneDrop.R`, `R/getGVGenotype.R`,
  `man/geneDrop.Rd`, `man/getGVGenotype.Rd`,
  `inst/extdata/ui_guidance/genetic_value.html`,
  `inst/extdata/ui_guidance/gvAndBgDesc.html`,
  `tests/testthat/test_modGeneticValue.R`,
  `vignettes/ColonyManagerTutorial.Rmd`, `vignettes/a2interactive.Rmd`,
  `vignettes/articles/genetic-value-analysis.qmd`, **new**
  `vignettes/gvaConvergence.Rmd`,
  `vignettes/manual_components/_genetic_value_analysis.Rmd`,
  `vignettes/manual_components/_genome_uniqueness_algorithm.Rmd`.
  Close-out — `CHANGELOG.md` (this entry), `PROJECT_LEARNINGS.md`
  (Learning 187), `SESSION_NOTES.md` (handoff). **NOT pushed.** The
  publish session opens a PR with “Closes \#2”.

### 2026-06-25 — Published Slice 2 of issue \#2: `gvaConvergence()` is on `master` via PR \#84 (Session 200)

- **Deliverable (owner pick, single item):** publish S199’s Slice 2 (the
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
  iteration-convergence diagnostic) from branch
  `issue-2-slice2-gvaconvergence` to `master` via PR, folding a
  user-facing NEWS *New features* bullet into the SAME PR (Learning
  157a). **Publish/docs session** — TDD code-phases N/A every response
  (S199 wrote + tested the code under strict TDD). **0 stakeholder
  corrections.** SOLO (a serial, irreversible git sequence — the
  standing publish-session judgment, held under ultracode). Owner
  directed “Publish Slice 2” at orientation and “Yes, merge PR \#84 now”
  at the `AskUserQuestion` merge gate.
- **NEWS (one PR, Learning 157a):** a *New features* bullet for the
  newly exported
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md),
  appended at the END of the dev-version New features list
  (append-don’t-rewrite, Learning 171). Plain-language (no “Monte Carlo”
  jargon for a user-facing note), backticked identifiers. Re-rendered
  `NEWS.md` (`html_preview:false`+`md_extensions:"-smart"`,
  Learning 155) → pure insertion (NEWS.Rmd +13 / NEWS.md +14, 0
  deletions), 0 non-ASCII, no stray `.html`; `spell_check_package(".")`
  = **0 before AND after** (Learning 175). Committed as `9079478c`.
- **PR + CI (did NOT merge blind, Learning 157b):** opened **PR \#84** →
  `master` (body “Part of \#2”, **no** closing keyword). BOTH
  `gh pr checks 84 --watch` AND a FRESH non-watch re-query returned
  **all 10 checks PASS** (lint, pkgdown, test-coverage,
  macOS/Windows/Ubuntu release + oldrel-1 + ubuntu-devel,
  `codecov/patch`, `codecov/project`); `mergeStateStatus` UNSTABLE →
  CLEAN. **`codecov/patch` GREEN** — the new code ships
  `test_gvaConvergence.R`.
- **Auto-close trap PREVENTED (Learning 184 → new Learning 186):**
  unlike S198 (which auto-closed \#2 twice), the PR body was written to
  a scratch file and grep-scanned for any closing-keyword-plus-number
  substring BEFORE creation — clean, so the merge left **issue \#2
  OPEN** (confirmed by the standing immediate post-merge
  `gh issue view 2 --json state` re-query). The proactive guard worked;
  no reopen was needed.
- **Merge (owner-gated):** fresh pre-merge re-check
  (OPEN/MERGEABLE/CLEAN, `headRefOid`==`9079478c`,
  `origin/master`==`9e78e055`, \#2 OPEN); `gh pr merge 84 --merge` →
  merge commit **`743f2459`** (MERGED); immediate issue re-query =
  **OPEN**.
- **Reconcile (Learning 146):** reverted the uncommitted 1B stub
  (superseded by the handoff); `git checkout master`; `fetch`
  (`9e78e055..743f2459`); ancestor-gated `reset --hard` (both old-master
  `9e78e055` AND tip `9079478c` asserted ancestors of `743f2459`, and
  `743f2459`==`origin/master`); verified-merged-before-delete cleanup
  (local `-d` “was 9079478c” + remote `--delete`; `git ls-remote`
  empty).
- **Phase-3E (build-equivalent / runtime smoke): SATISFIED.** PR \#84’s
  `R CMD check` ×5 matrix all PASS (stronger than a single local check);
  confirmed FIRSTHAND on `master` after the reset that the deliverable
  is live (`gvaConvergence` exported in `NAMESPACE` line 105,
  `man/gvaConvergence.Rd` present, the NEWS bullet on `NEWS.md`) + an
  end-to-end `gvaConvergence(qcPed, nMax = 120, grid = c(25, 40, 60))`
  returning an `nprcgenekeeprGVConv` object (recommendedIter 25 = grid
  floor, overlap=tau=1 at every `N`, 124 Undetermined / 156 rankable —
  matching S199’s documented qcPed behavior).
- **Files:** `NEWS.Rmd`/`NEWS.md` (in PR \#84 as `9079478c`); close-out
  — `CHANGELOG.md` (this entry), `PROJECT_LEARNINGS.md` (Learning 186),
  `SESSION_NOTES.md` (this handoff), pushed to origin/master FF. **Issue
  \#2 stays OPEN** (Slice 2 of 3; Slice 3’s merge is the one that closes
  it).

### 2026-06-25 — Implemented Slice 2 of issue \#2: `gvaConvergence()` iteration-convergence diagnostic (Session 199)

- **Deliverable (owner pick, single item):**
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
  — a new exported Genetic Value Analysis diagnostic that answers issue
  \#2’s literal ask (“define reproducible and automate finding the
  needed number of iterations”). **Strict-TDD implementation** — PRE-RED
  firsthand grounding + a dense-fixture parameter-search workflow, then
  RED → GREEN → REFACTOR plus an owner-approved hardening micro-cycle,
  every transition `AskUserQuestion`-gated; TDD phase declared every
  response. **0 stakeholder corrections.** On LOCAL branch
  `issue-2-slice2-gvaconvergence` — **NOT published** (the publish PR +
  the NEWS bullet are a separate session, FM \#18/#25). **Issue \#2
  stays OPEN** (Slice 2 of 3; the merge that closes \#2 is Slice 3).
- **What it does:** on the ratified D1 definition that the
  decision-relevant quantity is the *selection order* (not the precision
  of the `gu` number),
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
  runs ONE gene drop at `nMax`, computes the per-iteration rare-allele
  matrix ONCE via
  [`calcA()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcA.md),
  and for each candidate iteration count `N` splits the columns into two
  disjoint `N`-halves, ranks each half through the real `orderReport()`
  pipeline, and measures whether the two independent half-runs agree on
  the selection order — top-`k` set overlap (`oMin=0.90`) AND Kendall
  rank agreement / tau-b (`rhoMin=0.95`). It returns the metric-vs-`N`
  curve, `recommendedIter` (smallest `N` meeting both), `converged`, the
  criteria, and the rankable / issue-#76-Undetermined diagnostics. The
  i.i.d. columns make every nested prefix’s `gu` exact, so **no
  `calcA`/`reportGV`/`geneDrop` change** was needed (Finding 7 is
  satisfied by calling `calcA` once); the function orchestrates the same
  deterministic building blocks `reportGV` uses, leaving the central
  path untouched. Purely additive.
- **The dense-mid-range fixture (Dragon \#2 / Finding 4 — the
  load-bearing part):** no bundled pedigree can validate a `gu`-based
  ranking tool (all are order-stable at tiny `N`). The RED test fixture
  `makeConvergenceFixture()` builds a deterministic half-sib web (14
  founder sires × overlapping 5-dam windows over 15 founder dams;
  **founders excluded from `pop`** so their private gene-drop alleles
  among probands are carried only by descendants → rankable mid-range
  `gu` straddling the `gu=10` cutoff). Found by a 7-strategy parallel
  parameter-search workflow + a judge, then **re-validated firsthand**:
  order unstable at `N=25` (top-20 overlap ~0.75) and converges by
  `N≈800` (seed 11), with a monotone curve — while qcPed (no rankable
  `gu` signal) is reproducible at the grid floor. The RED tests assert
  ROBUST properties (fixture `recommendedIter` finite AND \> qcPed’s;
  small-`N` instability; determinism), never a brittle exact
  recommended-`N` (it varies 200–800 by seed).
- **Tests (RED-first):** new `tests/testthat/test_gvaConvergence.R` — 7
  tests / 35 assertions: object contract/shape+class; determinism under
  a fixed seed; the discrimination (anti-tautology) test (hard fixture
  needs finitely more iterations than qcPed, qcPed overlap=tau=1 at
  every `N`); recommendedIter = smallest `N` meeting both criteria;
  issue-#76 Undetermined excluded from the order + count == 124 on
  qcPed; agreement improves from smallest to largest `N`; and a
  grid-guard test (non-positive iteration counts filtered, no `NaN`
  row).
- **Adversarial verification:** a fresh-agent code review independently
  confirmed the half-split math, row alignment, that `buildOrder`
  reproduces `reportGV`’s ranking exactly, `nRankable`/`nUndetermined`
  correctness, determinism, and the `k>nRankable`/empty-grid edge cases
  — no primary-path bug. It surfaced one latent defect (a user-supplied
  `grid` value of `0` leaked past the upper-bound-only filter →
  `colsB = 1:0` reversal + divide-by-zero `NaN` row), fixed via the
  gated hardening micro-cycle (positive-integer lower bound on `grid`).
- **Verification:** new file 7 tests / 35 assertions all pass; full
  regression **0 failed / 0 error**;
  `devtools::check(vignettes = FALSE)` = **0/0/0**;
  `spell_check_package(".")` = **0**; `lintr` clean on both changed
  files; [`tools::checkRd`](https://rdrr.io/r/tools/checkRd.html) 0
  issues; firsthand runtime smoke =
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
  on the fixture (recommendedIter 800, monotone curve) and qcPed
  (recommendedIter floor, overlap=tau=1, 124 Undetermined / 156
  rankable), discrimination confirmed.
- **Files:** new `R/gvaConvergence.R`,
  `tests/testthat/test_gvaConvergence.R`, `man/gvaConvergence.Rd`
  (generated); `NAMESPACE` (export `gvaConvergence`). Close-out —
  `CHANGELOG.md` (this entry), `PROJECT_LEARNINGS.md` (Learning 185),
  `SESSION_NOTES.md` (handoff + the 1B stub it overwrote). No
  `reportGV`/`calcA`/`orderReport`/`geneDrop` change. The ratified D3
  default `5000 → 1000L` change and the longer-doc/vignette
  reconciliation (including the gvaConvergence vignette) are Slice 3.

### 2026-06-25 — Published Slice 1 of issue \#2: per-animal genome-uniqueness SE (`guSE`) is on `master` via PR \#83 (Session 198)

- **Deliverable (owner pick, single item):** publish S197’s Slice 1
  (per-animal genome-uniqueness sampling standard error) from branch
  `issue-2-slice1-guse` to `master` via PR, folding the user-facing NEWS
  entry into the SAME PR (Learning 157a). **Publish/docs session** — TDD
  code-phases N/A every response (S197 wrote + tested the code under
  strict TDD). **0 stakeholder corrections.** SOLO (a serial,
  irreversible git sequence — the standing publish-session judgment,
  held under ultracode). Owner directed “Publish Slice 1” at orientation
  and “Merge PR \#83 now” at the `AskUserQuestion` merge gate.
- **NEWS (one PR, Learning 157a):** a *New features* bullet for the new
  exported
  [`calcGUSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md)
  and a *Changes* bullet for the
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  `guSE` column / “Genome Uniqueness SE (max)” GVA Summary row / in-app
  guidance, both appended at the END of their lists
  (append-don’t-rewrite, Learning 171 — end-placement preserves the GVA
  bullets’ “described above” cross-references). Re-rendered `NEWS.md`
  (`html_preview:false`+`md_extensions:"-smart"`, Learning 155) → pure
  insertion (NEWS.md +26), 0 non-ASCII, no stray `.html`;
  `spell_check_package(".")` = **0 before AND after** (Learning 175).
  Committed as `c8a1cf16`.
- **PR + CI (did NOT merge blind, Learning 157b):** opened **PR \#83** →
  `master` (body “Part of \#2”, **no** closing keyword). BOTH
  `gh pr checks 83 --watch` AND a FRESH non-watch re-query returned
  **all 10 checks PASS** (lint, pkgdown, test-coverage,
  macOS/Windows/Ubuntu release + oldrel-1 + ubuntu-devel 15m50s,
  `codecov/patch`, `codecov/project`); `mergeStateStatus` UNSTABLE →
  CLEAN. **`codecov/patch` GREEN** — the new code ships its own tests
  (`test_calcGUSE.R` + the `reportGV`/`gvSummary` tests exercise the
  changed lines), exactly as S197 predicted.
- **Merge (owner-gated):** fresh pre-merge re-check
  (OPEN/MERGEABLE/CLEAN, `headRefOid`==`c8a1cf16`,
  `origin/master`==`f5378caf`, \#2 OPEN); `gh pr merge 83 --merge` →
  merge commit **`00500a5a`** (MERGED 10:23:26Z).
- **Auto-close trap + recovery (Learning 184):** the merge
  **unexpectedly CLOSED issue \#2** — the PR body’s sentence “does not
  close \#2” contains the substring “close \#2”, and GitHub’s auto-close
  parser triggers on it (it ignores the negation). Caught within seconds
  by the standing post-merge state re-query; **`gh issue reopen 2`**
  restored it to OPEN, with a clarifying comment. It then **recurred**
  because the first close-out commit message quoted the offending token
  while documenting the trap and re-fired the parser on push; reopened
  again. The refined rule (Learning 184): keep the literal
  closing-keyword token out of the PR body AND any commit message
  landing on the default branch, even ones explaining the trap (file
  contents are safe). **Issue \#2 stays OPEN** (Slice 1 of 3; Slice 3’s
  merge closes it).
- **Reconcile (Learning 146):** `git checkout master`; `fetch`
  (`f5378caf..00500a5a`); ancestor-gated `reset --hard` (both old-master
  `f5378caf` AND tip `c8a1cf16` asserted ancestors of `00500a5a`);
  verified-merged-before-delete cleanup (local `-d` “was c8a1cf16” +
  remote `--delete`; `git ls-remote` empty).
- **Phase-3E (build-equivalent / runtime smoke): SATISFIED.** PR \#83’s
  `R CMD check` ×5 matrix all PASS (stronger than a single local check);
  confirmed FIRSTHAND on `master` after the reset that the deliverable
  is live (`calcGUSE` exported in `NAMESPACE`, `reportGV` carries
  `guSE`, the gvSummary “Genome Uniqueness SE (max)” row, the two NEWS
  bullets) + an end-to-end `calcGUSE(ped1Alleles, threshold = 3)`
  returning a populated `guSE` data.frame (277 rows, non-zero SE).
- **Files:** `NEWS.Rmd`/`NEWS.md` (in PR \#83 as `c8a1cf16`); close-out
  — `CHANGELOG.md` (this entry), `PROJECT_LEARNINGS.md` (Learning 184),
  `SESSION_NOTES.md` (this handoff + the 1B stub it overwrote), pushed
  to origin/master FF. Issue \#2 reopened + commented.

### 2026-06-25 — Implemented Slice 1 of issue \#2: per-animal genome-uniqueness standard error (`guSE`) (Session 197)

- **Deliverable (owner pick, single item):** the additive per-animal
  Monte Carlo sampling standard error of the genome-uniqueness (`gu`)
  estimate, threaded through the Genetic Value Analysis. **Strict-TDD
  implementation** — PRE-RED scope + RED → GREEN → REFACTOR, every
  transition `AskUserQuestion`-gated; TDD phase declared every response.
  **0 stakeholder corrections.** On LOCAL branch `issue-2-slice1-guse` —
  **NOT published** (the publish PR + the NEWS bullet are a separate
  session, FM \#18/#25). **Issue \#2 stays OPEN** (Slice 1 of 3; the
  merge that closes \#2 is Slice 3).
- **New exported helper
  [`calcGUSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md)**
  (`R/calcGUSE.R`): `guSE_i = 100 * sqrt(var(m_i.) / K)` with
  `m_ik = rare[i,k]/2`, computed from the same
  [`calcA()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcA.md)
  rare matrix
  [`calcGU()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md)
  averages, so it is correct for any `guThresh` / `byID` (D4). Mirrors
  [`calcGU()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md)
  (single-column data.frame named `guSE`, rownames = ids; an animal with
  no per-iteration variation has SE 0).
- **[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)**
  now carries a `guSE` column in BOTH `$report` (immediately after `gu`)
  and the returned `$gu` element (now two columns: `gu`, `guSE`). The
  issue \#76 “Undetermined” de-inflation zeroes `guSE` in step with `gu`
  (a policy constant has no sampling error). `gu` values and all
  existing signatures are unchanged; `@return` roxygen updated.
- **Shiny GVA Summary tab** (`R/modGeneticValue.R`): a “Genome
  Uniqueness SE (max)” row reports the worst-case precision for the run,
  guarded on the column’s presence.
- **In-app guidance** (`inst/extdata/ui_guidance/genetic_value.html`,
  D5): plain-language explanation that genome uniqueness is a gene-drop
  (Monte Carlo) estimate whose reported `+/-` standard error shrinks
  with more iterations and depends on the pedigree, and that
  precision-of-the-number is distinct from stability of the selection
  order (what governs breeder choice; a future tool will check it).
- **Tests (RED-first):** new `test_calcGUSE.R` (exact golden match vs an
  independent `calcA` recomputation; `threshold`/`byID`/`pop` parity;
  deterministic `1/sqrt(K)` shrink via column duplication, exact factor
  `sqrt((K-1)/(2K-1))`, no RNG); `test_reportGV.R` (both `expect_named`
  report lists updated to include `guSE`; new `$report`/`$gu` +
  de-inflation test); `test_modGeneticValue.R` (gvSummary SE row;
  guidance-HTML content).
- **Verification:** full regression **1237 tests, 0 failed / 0 error**
  (167 skipped opt-in); `devtools::check(vignettes = FALSE)` =
  **0/0/0**; `spell_check_package(".")` = **0**; `lintr` clean on the
  changed files; Phase-3E runtime smoke = the gvSummary `testServer`
  render + an end-to-end `reportGV` showing populated `guSE`
  (e.g. `gu=48.8 ±1.10`, a founder import at `±0`, the Undetermined set
  at `0/0`).
- **Deferred by design:**
  [`calcGUSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md)
  recomputes the rare matrix (a second `calcA` per `reportGV`);
  factoring `rare` out of `calcA` so `gu`/`guSE` share one build is
  Slice 2’s job (Finding 7). The ratified D3 default `5000 → 1000L`
  change and the longer-doc/vignette reconciliation are Slice 3.
- **Commit:** `1fd951a7` (feat). **Learning 183** added.

### 2026-06-25 — Ratified §8 of the issue \#2 plan + re-established its empirical basis firsthand (Session 196)

- **Deliverable (owner pick, single item):** ratify the six open §8
  decisions in `docs/planning/issue2-gva-iteration-convergence-plan.md`,
  grounded in firsthand-verified evidence. **Decision/planning session**
  — TDD code-phases N/A; implementation slices remain SEPARATE later
  sessions (FM \#18). **0 stakeholder corrections.** **Slice 1 is now
  unblocked.**
- **Decisions ratified (owner via `AskUserQuestion`; all recommended
  option):** **D3** = align the
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)/[`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
  function default down to **1000L** (match the Shiny UI +
  NEWS/CHANGELOG); **D1 metric** = **Kendall’s tau-b** with provisional
  `k=20`/`o_min=0.90`/`rho_min=0.95` (finalized against the Slice-2
  fixture); **D5** = Slice 1 updates the in-app `genetic_value.html`
  only; **fg** = deferred to a follow-up issue. **D2** (ship C then A, B
  out) and **D4** (compute `guSE` from the real `rare` matrix; scope the
  recommendation to defaults) recorded as recommended.
- **Firsthand re-verification corrected three plan errors** (S195
  flagged its `qcPed` numbers as subagent-sourced; Learning 182): the
  `qcPed` Undetermined count is **124/280, not 156**; on `qcPed`
  `{gu>0}` == `{founders}` == `{the #76 Undetermined set}` (identical
  124), so **after the issue \#76 de-inflation all 280 animals are at
  `gu=0`** — `qcPed`/`pedWithGenotype`/`rhesusPedigree` have **zero
  rankable `gu` signal**, and `examplePedigree` (the only bundled
  pedigree with signal) is order-stable at **N=5**. So **no bundled
  pedigree can validate a `gu`-based convergence/rank tool** — the
  dense-mid-range fixture (Slice 2 RED) is mandatory. The D3 “qcPed
  converges by N~250-500” justification was vacuous; grounded instead on
  `examplePedigree` (order stable `<<1000`; SE `~1/sqrt(N)`:
  <0.79pp@1000> → <0.56pp@2000> → ~<0.35pp@5000>). Claims that held
  firsthand: SE `~1/sqrt(N)`, `SE_exact/SE_approx` ~0.82–0.85 at
  `guThresh>=2`, the column-prefix trick, and `byID` no-op at
  `guThresh=1`.
- **Phase-3E:** N/A — a planning/decision document changes no runtime
  behavior (no code touched). Not a defect.
- **Files:** `docs/planning/issue2-gva-iteration-convergence-plan.md`
  (status → §8 RATIFIED; D1–D6 + §8 checklist resolved; §2C/Findings
  3–4/Dragons 2–3 corrected; new §9A firsthand-evidence table);
  close-out — `CHANGELOG.md` (this entry), `PROJECT_LEARNINGS.md`
  (Learning 182), `SESSION_NOTES.md` (handoff + the 1B stub it
  overwrote). Issue \#2 stays OPEN (planned + ratified, not
  implemented); an `fg`-SE follow-up issue opened.

### 2026-06-24 — Planned issue \#2: evidence-based GVA gene-drop iteration-count advice (`docs/planning/issue2-gva-iteration-convergence-plan.md`) (Session 195)

- **Deliverable (owner pick, single item):** a PLAN for the 6-year-open
  issue \#2 (“evidence-based advice on the number of gene-drop
  iterations needed for the Genetic Value Analysis”). **Planning
  session** — TDD code-phases N/A every response; implementation + the
  empirical study are SEPARATE later sessions (FM \#18). **0 stakeholder
  corrections.** Used a 7-agent investigate/design/critique workflow
  (`wf_fdb7c410-95f`, ultracode); all load-bearing code citations
  (`calcGU`/`calcA`/`reportGV`/`orderReport`/`modGeneticValue`)
  re-verified FIRSTHAND before authoring.
- **What the plan decides:** genome uniqueness
  `gu = rowSums(rare)/(2*iterations)*100` (`calcGU.R:97`) is a Monte
  Carlo proportion, so precision is `f(iterations, pedigree)` — there is
  no universal iteration count. Recommended design = **C then A**:
  (Slice 1, C) an additive per-animal `guSE` column computed from the
  real `rare` matrix + an in-app explanation; (Slice 2, A) an exported
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
  that recomputes `gu`/ranking on nested iteration-column prefixes
  `V1..Vk` of ONE `Nmax` run (the columns are i.i.d., so the whole
  convergence curve comes free — no replicate experiment); (Slice 3)
  reconcile the default contradiction + docs. True in-loop streaming /
  early-stop (B) is OUT OF SCOPE (infeasible + breaks `geneDrop`’s
  `V1..Vn` contract).
- **Owner steers folded in (each recorded with attribution):** (1)
  precision = `f(iterations, pedigree)` → Monte Carlo; (2) “report
  convergence rate during the calculation phase” → realized faithfully
  via the post-run column-prefix sweep (true streaming is blocked
  because rare-allele classification needs the whole-population
  frequency table per iteration); (3) the estimate must be explained in
  the **in-app user-facing docs where it is displayed** — mapped to
  `inst/extdata/ui_guidance/genetic_value.html` (rendered at
  `modGeneticValue.R:65-68`); (4) **“selection order is the best measure
  of stability”** + “numeric precision is of interest to the user but of
  little value for breeder selection” → D1 defines “reproducible” on
  selection-order (top-`k` set overlap + order agreement), with
  per-animal SE demoted to a displayed, informational diagnostic.
- **Adversarial critique overturned two first-pass claims** (Learning
  181): the `sqrt(2)` homozygote SE-inflation is false at
  `guThresh = 1`; and the rank tool cannot be validated on the bimodal
  `qcPed` (Spearman = 1.0 at N \>= 125) so a dense-mid-range fixture
  must be built in RED first.
- **Evidence inventory (mandated):** 84 iteration-count sites; the
  unresolved default contradiction documented —
  `reportGV.R:93`/`geneDrop.R:90` = 5000 vs `modGeneticValue.R:38` =
  1000 vs NEWS/CHANGELOG claiming “changed to 1000” vs example data at
  10000.
- **Phase-3E:** N/A — a planning document changes no runtime behavior
  (no code touched). Not a defect.
- **Files:** `docs/planning/issue2-gva-iteration-convergence-plan.md`
  (new, the deliverable); close-out — `CHANGELOG.md` (this entry),
  `PROJECT_LEARNINGS.md` (Learning 181), `SESSION_NOTES.md` (handoff +
  the 1B stub it overwrote). Issue \#2 stays OPEN (planned, not
  implemented).

### 2026-06-25 — Published issue \#1: “Clear Focal Animals” file/text reset is on `master` via PR \#81; **issue \#1 CLOSED** (Session 194)

- **Deliverable (owner pick, single item):** publish S193’s issue \#1
  fix (the Pedigree Browser “Clear Focal Animals” option now also clears
  an uploaded focal-animals file + its displayed name + any typed focal
  IDs) from branch `issue-1-clear-focal-animals` to `master`, folding
  the user-facing NEWS *Changes* bullet into the SAME PR (Learning
  157a), PR body **“Closes \#1”** so the merge auto-closes \#1.
  **Admin/publish + docs** (the code was written/tested under strict TDD
  in S193 → TDD code-phases N/A every response). **0 stakeholder
  corrections.** SOLO (a serial, irreversible git sequence — a workflow
  adds risk, not coverage; the standing S179/S181/S183/S187/S189/S192
  judgment, held despite ultracode). Owner directed “Publish \#1” at
  orientation and “wait for CI then merge.”
- **Pre-publish content (one PR, Learning 157a):** appended one
  dev-version `NEWS.Rmd` *Changes* bullet at the END of the *Changes*
  list (append-don’t-rewrite, Learning 171 — the \#1 UI fix has no
  topical companion among the species/GVA/config bullets, and
  end-placement keeps the GVA bullets’ “described above”
  cross-references intact). No new exported function → **no** *New
  features* bullet. Re-rendered `NEWS.md` (permanent
  `html_preview:false`+`md_extensions:"-smart"`, Learning 155) → **0
  non-ASCII**, no stray `.html`, confined pure-insertion (NEWS.Rmd +8 /
  NEWS.md +9). `spell_check_package(".")` = **0 before AND after**
  (Learning 175 — 0-delta; no WORDLIST change). Committed NEWS as
  `54e03f86`; kept the S194 1B stub OUT of the PR (stash-carried, popped
  clean post-merge; the pre-existing `WIP on dev` stash untouched
  throughout).
- **No push-master-first:** `master`==`origin/master`==`ae3b80df`
  verified FIRSTHAND (after `fetch`); PR diff came out \#1-only = 3
  commits (S193 feat `2038facb` + S193 close-out `573028b8` + S194 NEWS
  `54e03f86`).
- **PR + CI (did NOT merge blind — Learning 157b):** opened **PR \#81**
  → `master` (body “Closes \#1”). BOTH `gh pr checks 81 --watch` AND the
  FRESH non-watch re-query returned **all 10 checks PASS** (lint,
  pkgdown, test-coverage, macOS/Windows/Ubuntu release+oldrel-1,
  ubuntu-devel 14m19s, `codecov/patch`, `codecov/project`);
  `mergeStateStatus` UNSTABLE → CLEAN. **`codecov/patch` was GREEN
  here** — the 5 new `testServer` tests exercise the changed
  `renderUI` + clear-branch lines, so the patch ships its own coverage
  (confirms Learning 177’s positive side, exactly as S192/#76; no new
  numbered learning warranted).
- **Merge (owner-directed “then merge”):** guarded fresh pre-merge
  re-check (OPEN/MERGEABLE/CLEAN, `headRefOid`==local `54e03f86`,
  `origin/master`==`ae3b80df` — all asserted); `gh pr merge 81 --merge`
  → merge commit **`dffe5690`** (verified MERGED, `mergedAt 02:24:18Z`);
  **\#1 verified CLOSED** (`closedAt 02:24:19Z` ≈ merge time — “Closes
  \#1” worked).
- **Reconcile (Learning 146):** `git checkout master`; verified `fetch`
  (`ae3b80df..dffe5690`); **ancestor-gated `reset --hard`** (both
  old-master `ae3b80df` AND tip `54e03f86` asserted ancestors of
  `dffe5690`); `git stash pop` restored the stub cleanly (`WIP on dev`
  preserved as `stash@{0}`); verified-merged-before-delete cleanup
  (local `-d` “was 54e03f86” + remote `--delete`; `git ls-remote`
  empty).
- **Phase-3E (build-equivalent / runtime smoke): SATISFIED.** The merge
  tree was build-verified by PR \#81’s `R CMD check` x5 matrix
  (macOS/Windows/Ubuntu release + oldrel-1 + ubuntu-devel 14m19s), all
  PASS — stronger than a single local check. Confirmed FIRSTHAND on
  `master` after the reset: the fix is live (`R/modPedigree.R:73`
  `uiOutput("focalAnimalFileUI")`, `:211` `renderUI`, `:238-239`
  `updateTextAreaInput`/`fileInputKey` bump, `:250`/`:260`
  [`identical()`](https://rdrr.io/r/base/identical.html)-to-cleared read
  guards) and the NEWS bullet is on `NEWS.md:133`;
  `master`==`origin/master`==`dffe5690`. (No browser click — the e2e
  harness is baseline-flaky and unchanged by a publish session; the CI
  matrix + firsthand master grep are the runtime evidence, per
  S188/S189/S192.)
- **Files:** `NEWS.Rmd` (+1 dev-version *Changes* bullet, at the end of
  *Changes*), `NEWS.md` (re-rendered) — both in PR \#81 as `54e03f86`;
  close-out docs (this S194 docs commit, direct to local `master`, then
  pushed to origin) `CHANGELOG.md` (this entry), `SESSION_NOTES.md`
  (this handoff + the 1B stub it overwrote).

### 2026-06-24 — Implemented issue \#1: “Clear Focal Animals” now resets the uploaded file + typed text (Pedigree Browser); strict TDD (Session 193)

- **Deliverable (owner pick, single item):** fix issue \#1 — after
  “Clear Focal Animals,” a previously-loaded focal CSV (and typed IDs)
  must not silently re-read on the next “Update Focal Animals,” and the
  file-name display must clear. The list-clearing checkbox already
  worked since 2020 (`R/modPedigree.R`); the residual the owner flagged
  in 2020 (“does not clear file names read in with the file browser”) is
  what this fixes. **Strict TDD** (RED→GREEN→REFACTOR; every transition
  `AskUserQuestion`-gated; phase declared each response). **0
  stakeholder corrections.** SOLO.
- **Two pre-RED owner decisions (`AskUserQuestion`):** (1) reset
  approach = **no new dependency** (server-side guard + `renderUI` +
  `updateTextAreaInput`) over adding `shinyjs` — the package is
  CRAN-archived and the chosen approach is fully unit-testable; (2)
  clear scope = **file + textarea (everything)**.
- **RED (5 tests in `tests/testthat/test_modPedigree.R`):** 3
  new-behavior tests (cleared file not re-read; cleared text not
  re-read; the file input is now a dynamic `uiOutput`) confirmed failing
  for the right reason (IDs reappear; static UI still carries
  `type="file"`); 2 regression guards (a newly chosen file/text after a
  clear still loads) confirmed passing. RED tally: 74 pass / 4 fail / 0
  error.
- **GREEN (`R/modPedigree.R`):** the focal file input is now rendered
  server-side via
  `output$focalAnimalFileUI <- renderUI({ fileInputKey(); fileInput(session$ns("focalAnimalFile"), ...) })`;
  checking “Clear Focal Animals” records
  `clearedFilePath`/`clearedText`, blanks the textarea via
  `updateTextAreaInput`, and bumps `fileInputKey` (re-renders a fresh
  widget → the displayed file name clears); the text/file read paths
  skip content [`identical()`](https://rdrr.io/r/base/identical.html) to
  the cleared values (a newly chosen file gets a new temp path → still
  loads). `@importFrom shiny uiOutput updateTextAreaInput`;
  `devtools::document()` updated `NAMESPACE` only (no `.Rd` change). All
  33 `test_modPedigree.R` tests pass (78 assertions).
- **REFACTOR:** skipped (owner-gated) — `lintr` clean on both changed
  files, no duplication, no behavior-neutral improvement identified.
- **E2E (owner-requested, real Chrome):** added “E2E: Clear Focal
  Animals resets the file input and typed IDs” to
  `tests/testthat/test-e2e-pedigree-tutorial.R`; ran the pedigree E2E
  suite with `NPRC_RUN_E2E=true` + `NOT_CRAN=true` → **9 tests, 13
  assertions, all pass** in a real browser, confirming the file-name
  display AND textarea clear at the DOM level (the half `testServer`
  cannot verify). The first run silently skipped 9/9 until
  `NOT_CRAN=true` was also set (`skip_on_cran`). Learning 180.
- **Verification:** full regression **1016 tests / 2271 pass / 0 fail /
  0 error**; `devtools::check(vignettes = FALSE)` **0/0/0**;
  `spell_check_package(".")` **0**; lint clean.
- **NOT published:** implement session — code + tests + close-out docs
  committed to branch `issue-1-clear-focal-animals`, NOT pushed/PR’d
  (publish is a separate owner-decided session, FM \#18/#25; the publish
  PR uses “Closes \#1” + a user-facing NEWS *Changes* bullet, Learning
  157a).
- **Files:** `R/modPedigree.R`, `NAMESPACE`,
  `tests/testthat/test_modPedigree.R` (+5 tests),
  `tests/testthat/test-e2e-pedigree-tutorial.R` (+1 E2E test); close-out
  docs `CHANGELOG.md` (this entry), `PROJECT_LEARNINGS.md` (Learning
  180), `SESSION_NOTES.md` (handoff).

### 2026-06-24 — Published issue \#76 (Reading A): genome-uniqueness de-inflation is on `master` via PR \#80; **issue \#76 CLOSED** (Session 192)

- **Deliverable (owner pick, single item):** publish S191’s issue \#76
  Reading A (genome uniqueness reported as 0 for unknown-origin
  both-unknown “Undetermined” animals) from `issue-76-gu-deinflation` to
  `master`, folding the user-facing NEWS entry into the SAME PR
  (Learning 157a), PR body **“Closes \#76”** (the last line).
  **Admin/publish + docs** (the Reading A code was written/tested under
  strict TDD in S191 → TDD code-phases N/A). **0 stakeholder
  corrections.** SOLO (a serial, irreversible git sequence — a workflow
  adds risk, not coverage; the S179/S181/S183/S187/S189 judgment). Owner
  picked “Publish \#76” at orientation and “Merge now (merge commit)” at
  the `AskUserQuestion` merge gate.
- **Pre-publish content (one PR, Learning 157a):** appended one
  dev-version `NEWS.Rmd` *Changes* bullet — the Genetic Value Analysis
  now reports a genome uniqueness of 0 for the “Undetermined” animals
  (both parents unknown and no recorded origin): such an animal enters
  the gene-drop simulation as a founder whose alleles are all freshly
  minted and therefore unique, so its computed genome uniqueness
  measures only that modeling artifact and the report declines to credit
  it. Genuine imports (carrying an `origin`) and animals with one or
  both parents known are unaffected. Placed immediately after the
  existing “Undetermined” ranking bullet (Reading B / Slice 3) as its
  genome-uniqueness companion (append-don’t-rewrite, Learning 171 — the
  prior bullet untouched). Reading A added no new exported function, so
  **no** *New features* bullet. Re-rendered `NEWS.md` (permanent
  `html_preview:false`+`md_extensions:"-smart"`, Learning 155) → **0
  non-ASCII**, no stray `.html`, confined pure-insertion (NEWS.Rmd +13 /
  NEWS.md +14). `spell_check_package(".")` = 0 before AND after
  (Learning 175 — 0-delta; no WORDLIST change). Committed NEWS as
  `b289776c`; kept the S192 1B stub OUT of the PR (stash-carried, popped
  clean post-merge; the pre-existing `WIP on dev` stash untouched).
- **No push-master-first:** `master` == `origin/master` == `45457961`
  verified firsthand; the PR diff came out \#76-only = 3 commits (S191
  feat `7d1e9b4f` + S191 close-out `d4de9026` + S192 NEWS `b289776c`).
- **PR + CI (did NOT merge blind — Learning 157b):** opened **PR \#80**
  → `master` (body “Closes \#76”). The `--watch` AND the FRESH non-watch
  `gh pr checks 80` both returned exit 0 — **all 11 checks PASS**,
  including `codecov/patch` and `codecov/project`. Contrast
  S189/Learning 177 (`codecov/patch` failed there on appServer
  boot-wiring covr cannot execute): this Reading A patch SHIPS ITS OWN
  TESTS (`test_reportGV.R` + `test_modGeneticValue.R`) that exercise the
  changed `reportGV.R` lines, so the diff is covered and `codecov/patch`
  is green — confirming 177’s “patch-composition-sensitive” thesis from
  the positive side (no new learning warranted). `mergeStateStatus` went
  UNSTABLE → CLEAN.
- **Merge (owner-decided via `AskUserQuestion` — “Merge now (merge
  commit)”):** guarded fresh pre-merge re-check (state OPEN, mergeable
  MERGEABLE, `headRefOid`==local `b289776c`,
  `origin/master`==`45457961`); `gh pr merge 80 --merge` → merge commit
  **`9f1e4687`** (verified MERGED, `mergedAt 2026-06-24T21:58:04Z`).
  **Issue \#76 verified CLOSED** (`closedAt 2026-06-24T21:58:05Z` ==
  merge time — “Closes \#76” worked).
- **Reconcile (Learning 146):** `git checkout master`; verified `fetch`
  (`45457961..9f1e4687`); **ancestor-gated the reset** (both old-master
  `45457961` AND merged branch tip `b289776c` asserted ancestors of
  `origin/master` `9f1e4687`) → `git reset --hard origin/master`;
  `git stash pop` restored the S192 stub cleanly (pre-existing
  `WIP on dev` stash preserved); verified-merged-before-delete branch
  cleanup (local `-d` + remote `--delete`; `git ls-remote` empty).
  **Issue \#76 is CLOSED**; no dangling branches.
- **Files:** `NEWS.Rmd` (+1 *Changes* bullet) + `NEWS.md` (re-rendered)
  shipped via PR \#80; close-out docs (`CHANGELOG.md` this entry,
  `SESSION_NOTES.md` S192 handoff) committed direct to `master` and
  pushed to origin (\[\[push-close-out-docs-to-origin\]\]). No `R/`
  logic, test, or `man/` change this session (the code shipped as S191
  wrote it).

### 2026-06-24 — Implemented issue \#76 (Reading A): genome uniqueness de-inflated to 0 for unknown-origin both-unknown (“Undetermined”) animals (Session 191)

- **Deliverable (owner pick, single item, strict-TDD IMPLEMENTATION
  session):** the ratified Reading A from
  `docs/planning/issue76-gu-deinflation-ratification.md` §E — `reportGV`
  now reports genome uniqueness (`gu`) as **0** for the Undetermined /
  `noParentage` set (`classifyParentage == "both unknown"`, U-id aware,
  AND `origin` NA/absent), in BOTH the report’s `gu` column and the
  returned `$gu` element. Committed to branch `issue-76-gu-deinflation`;
  **not published** (PR → CI → merge is a separate session, FM \#18/#25,
  PR body “Closes \#76”). Every TDD transition `AskUserQuestion`-gated
  (PRE-RED→RED→GREEN→REFACTOR). **0 stakeholder corrections.**
- **GREEN (report-layer, ~12 lines):** in `R/reportGV.R`, after
  `parentage <- classifyParentage(...)` (`:184`) and before the `cbind`,
  compute `undetermined <- parentage == "both unknown" & is.na(origin)`
  (origin = `demographics$origin` if present, else
  `rep(NA_character_, n)` — mirrors `orderReport.R:43-47`’s
  origin-absence handling) and set `gu$gu[undetermined] <- 0.0`.
  Mutating the single `gu` data.frame updates both surfaces.
  `calcGU`/`calcA`/`geneDrop` and all their golden tests are UNTOUCHED
  and the `calcGU.R:10-34` stance is NOT reversed — added one clarifying
  roxygen sentence to `calcGU` (it computes the textbook statistic for
  every animal; `reportGV` applies the report-layer policy) and
  documented the decline-to-credit policy in `reportGV`’s roxygen;
  regenerated `man/reportGV.Rd` + `man/calcGU.Rd`.
- **RED (3 tests, verified failing for the right reason first):** (1)
  `test_reportGV.R` — a new origin-carrying fixture (ONPRC both-unknown
  founders origin NA, a both-unknown import origin “CHINA”, a
  U-id-parented both-unknown proband, known offspring) at `guThresh = 2`
  / `set.seed(17)`: ONPRC founders’ `gu` == 0 in `$report` AND `$gu`,
  imports preserved (\> 0, `$report` gu == `$gu`), a known animal
  preserved; (2) `test_reportGV.R` — the U-id-parented proband is
  de-inflated to 0, proving the predicate is
  `classifyParentage`/U-id-aware not raw `is.na`; (3) extended
  `test_modGeneticValue.R`’s demotion test (`:776`) to assert the
  displayed `results$gu` == 0 for the Undetermined founders (the
  demotion assertions still pass).
- **`guThresh = 2` is load-bearing for the U-id RED test (Learning
  179):** a U-id-parented proband is a gene-drop NON-founder, so at the
  default `guThresh = 1` its inherited alleles are always shared with
  its in-population parent → its `gu` is structurally 0 already → the
  de-inflation would be invisible (the “failing” assertion would
  silently pass on unchanged code). At `guThresh = 2` (alleles held by ≤
  2 animals count as rare) the proband carries `gu` = 100 on the
  pre-change code, making the de-inflation observable and the test
  RED-meaningful.
- **REFACTOR:** the 2 style lints introduced by GREEN fixed (re-wrapped
  the issue-#76 comment ≤ 80 chars; `0` → `0.0` for the double `gu`
  percentage column, silencing `implicit_integer_linter`). No behavior
  change.
- **Verification:** the 3 targeted tests green; full regression
  **1225/0/0** (no true offenders; even the baseline
  `test-app-`/`test-e2e-` files passed this run);
  `devtools::check(vignettes = FALSE)` = **0/0/0** (run after GREEN and
  again after REFACTOR); `spell_check_package(".")` = 0; lintr clean on
  the changed lines. **Phase-3E (changes a displayed value, FM \#24):**
  booted `modGeneticValueServer` via `testServer` on the origin fixture
  — the displayed GVA rankings table shows `gu` = 0 for the Undetermined
  set (ranked LAST, 6–10 of 10), imports preserved at 100/75 (ranked
  1–2), known animals preserved; the `origin` column survives
  `trimPedigree → reportGV` so import-preservation holds end-to-end; the
  Slice-3 demotion still ranks Undetermined last (the two corrections
  compose). No browser click (e2e harness baseline-flaky; the
  `testServer` boot is the established runtime evidence).
- **Files (feat):** `R/reportGV.R` (de-inflation + roxygen),
  `R/calcGU.R` (clarifying roxygen), `man/reportGV.Rd`, `man/calcGU.Rd`,
  `tests/testthat/test_reportGV.R` (+`makeOriginTestPed` helper +2
  tests), `tests/testthat/test_modGeneticValue.R` (+1 assertion).
  **Issue \#76 stays OPEN** until the publish session merges (PR “Closes
  \#76”).

### 2026-06-24 — Ratified issue \#76 (Reading A): de-inflate genome uniqueness for both-unknown founders — design agreed, implementation pending (Session 190)

- **Deliverable (owner pick, single item):** the **ratification design
  document** required by issue \#76 acceptance criterion \#1, written to
  `docs/planning/issue76-gu-deinflation-ratification.md` in the §8-E
  (S177) house style. **DESIGN/ratification session → TDD code-phases
  N/A, Phase-3E N/A** (no production code/tests; strict-TDD
  implementation is the next session). **0 stakeholder corrections.**
  Ran a 10-agent research + adversarial-critique workflow
  (`wf_67d4c94a-691`) under ultracode, then surfaced the genuine
  modeling decisions to the owner via four `AskUserQuestion` gates.
- **Ratified design — targeted decline-to-credit, report layer:**
  reported genome uniqueness (`gu`) is set to **0** for the
  **Undetermined / `noParentage`** set —
  `classifyParentage == "both unknown"` (U-id aware) AND `origin`
  NA/absent, i.e. exactly the set Reading B (Slice 3) already demotes —
  applied in `reportGV` after `classifyParentage` (`reportGV.R:184`), to
  both the report `gu` column and the returned `$gu`. Imports
  (both-unknown with a recorded `origin`) are preserved.
- **Key reframing (Learning 178):** the issue body and the S189 handoff
  assumed Reading A had to change `calcGU`/`calcA`/gene-drop, reverse
  the `calcGU.R:10-34` stance, and supply replacement gene-drop golden
  values (acceptance criterion \#1). The adversarial review + firsthand
  pipeline reads showed the clean realization changes **none** of those
  — `calcGU`/`calcA`/`geneDrop` and all their golden tests stay
  byte-identical; the stance is not reversed. Criterion \#1 is met by
  the agreed design + new report-layer tests, with **zero** gene-drop
  golden churn.
- **Candidates rejected (verified fatal flaws):** A4 rescales the wrong
  term (inflation is the numerator `rowSums(rare)`, not the
  `/(2L*iterations)` denominator); A3 injects per-iteration randomness
  and breaks seeded goldens; A2 mis-targets all founders (the gene-drop
  founder set ≠ the classification “both unknown” set after
  `addParents`). Adopted survivor: refined A1 (target `noParentage`,
  preserving imports).
- **Firsthand verification (FM \#11):** read
  `reportGV`/`orderReport`/`classifyParentage`/`rankSubjects`/`calcGU`/`calcA`/`geneDrop`/`getIncludeColumns`;
  confirmed `origin` ∈
  [`getIncludeColumns()`](https://github.com/rmsharp/nprcgenekeepr/reference/getIncludeColumns.md)
  (`:16`) and that existing goldens hold
  (`test_modGeneticValue.R:742-743,798-808,1394-1395`;
  `test_reportGV.R:20,45`).
- **Files:** created
  `docs/planning/issue76-gu-deinflation-ratification.md`; added a
  one-line cross-ref to
  `docs/planning/issue9-gva-unknown-parent-ranking-plan.md` §8-F;
  `PROJECT_LEARNINGS.md` (Learning 178); this entry; `SESSION_NOTES.md`
  (S190 handoff). No `R/`, test, or `man/` change. **Issue \#76 stays
  OPEN** (ratified, not implemented). Next: strict-TDD implementation
  per the doc’s §E charter (then a separate publish session, PR “Closes
  \#76”).

### 2026-06-24 — Published issue \#73 Part 2 Slice 2: user-configurable Potential Parents gestation override is on `master` via PR \#79; **issue \#73 CLOSED** (Session 189)

- **Deliverable (owner pick, single item):** publish S188’s issue \#73
  Part 2 Slice 2 (the user-configurable gestation override wired through
  the Potential Parents tab) from
  `issue-73-part2-slice2-potential-parents` to `master`, folding the
  user-facing NEWS entry into the SAME PR (Learning 157a), PR body
  **“Closes \#73”** (the last line). **Admin/publish + docs** (the Slice
  2 code was written/tested under strict TDD in S188 → TDD code-phases
  N/A). **0 stakeholder corrections.** SOLO (a serial, irreversible git
  sequence — a workflow adds risk, not coverage; held solo despite
  ultracode, the S179/S181/S183/S187 judgment). Owner picked “Publish
  \#73 Part 2 Slice 2” at orientation and “Merge now (merge commit)” at
  the `AskUserQuestion` merge gate.
- **Pre-publish content (one PR, Learning 157a):** appended one
  dev-version `NEWS.Rmd` *Changes* bullet — the Potential Parents tab’s
  “Maximum Gestational Period (days)” default now honors the same
  `speciesOverridesPath` CSV + `gestationDefault` config entry the
  Genetic Value Analysis uses, and is unchanged with no configuration.
  **Self-framed to supersede the Slice 1 “making the Potential Parents
  tab configurable is the remaining part of issue \#73” line**
  (append-don’t-rewrite, Learning 171, fulfilling 171’s own prediction)
  — “This completes issue \#73: both the Genetic Value Analysis and the
  Potential Parents tab are now configurable.” Slice 2 added no new
  exported function, so **no** *New features* bullet. Re-rendered
  `NEWS.md` (permanent `html_preview:false`+`md_extensions:"-smart"`,
  Learning 155) → **0 non-ASCII**, no stray `.html`, confined
  pure-insertion (NEWS.Rmd +11 / NEWS.md +13).
  `spell_check_package(".")` = 0 before AND after (Learning 175 — verb
  idiom + backticked identifiers, 0-delta; no WORDLIST change).
  Committed NEWS as `8ce3f937`; kept the S189 1B stub OUT of the PR
  (stash-carried, popped clean post-merge).
- **No push-master-first:** `master` == `origin/master` == `c512771a`
  verified firsthand; the PR diff came out Slice-2-only = 3 commits
  (S188 feat `e012e6ad` + S188 close-out `866b0a7f` + S189 NEWS
  `8ce3f937`).
- **PR + CI (did NOT merge blind — Learning 157b earned its keep):**
  opened **PR \#79** → `master` (body “Closes \#73”). The `--watch`
  exited 0, but the FRESH non-watch `gh pr checks 79` returned exit 1:
  **`codecov/patch` FAILED — 76.93% of diff hit vs auto target 90.01%.**
  All 9 `R CMD check`/lint/pkgdown/test-coverage jobs PASS
  (incl. ubuntu-devel 16m29s) and `codecov/project` passes (89.99%,
  −0.02%, flat). **Diagnosed firsthand:** the shortfall is the 2 new
  `appServer` boot-wiring lines (`gestationTable`/`gestationDefault`
  passed to the module), which `covr` cannot execute — verified instead
  by S188’s deparse-match test + the Phase-3E runtime smoke; the module
  logic (both `pedigreeGestationDefault` branches, the reactive) IS
  covered. Slice 1’s PR \#78 had the same wiring blind spot but passed
  at 94.24% — its large reader-heavy patch diluted it; Slice 2’s
  ~13-line patch could not. A patch-composition artifact, not a
  deliverable defect. `codecov/patch` is NOT a required check (no branch
  protection on `master`; `mergeStateStatus` UNSTABLE, `mergeable`
  MERGEABLE). **Learning 177** added.
- **Merge (owner-decided via `AskUserQuestion` — “Merge now (merge
  commit)”):** surfaced the red `codecov/patch` + its diagnosed cause to
  the owner BEFORE merging (not papered over, no test code added in a
  publish session — FM \#18/#25); owner chose merge now. Guarded fresh
  pre-merge re-check (state OPEN, mergeable MERGEABLE,
  `headRefOid`==local `8ce3f937`, `origin/master`==`c512771a`);
  `gh pr merge 79 --merge` → merge commit **`0980a028`** (verified
  MERGED firsthand, `mergedAt 2026-06-24T18:00:22Z`). **Issue \#73
  verified CLOSED** (`closedAt 2026-06-24T18:00:23Z` == merge time —
  “Closes \#73” worked).
- **Reconcile (Learning 146):** `git checkout master`; verified `fetch`
  (exit 0, `c512771a..0980a028`); **ancestor-gated the reset** (both
  old-master `c512771a` AND merged branch tip `8ce3f937` asserted
  ancestors of `origin/master` `0980a028`) →
  `git reset --hard origin/master`; `git stash pop` restored the S189
  stub cleanly (pre-existing `WIP on dev` stash untouched).
- **Branch cleanup (verified-merged-before-delete):** confirmed PR \#79
  MERGED + tip ancestor of master; `git branch -d` (was `8ce3f937`) +
  `git push origin --delete`; verified remote gone (`gh api` → **404**
  “Branch not found”).
- **Verification (Phase-3E):** the merge tree was build-verified by PR
  \#79’s `R CMD check` x5 matrix (incl. ubuntu-devel 16m29s), all PASS —
  stronger than a single local check; confirmed the deliverable
  firsthand on `master` after the reset — the appServer wiring
  (`R/appServer.R:319-320`), the renamed internal reactive
  `gestationDefaultReactive`, the `gestationDefault = NULL` param, and
  the Slice 2 NEWS bullet are all live. **Issue \#73 is CLOSED** — Part
  1 (data) + Part 2 Slice 1 (GVA tab) + Part 2 Slice 2 (Potential
  Parents tab) are all on `master`.

### 2026-06-24 — Implemented issue \#73 Part 2 Slice 2: user-configurable gestation override wired through the Potential Parents tab (Session 188)

- **Deliverable (owner pick, single item, strict-TDD IMPLEMENTATION
  session):** the user-configurable species gestation override now
  reaches the Potential Parents tab’s gestation-window prefill, per
  `docs/planning/issue73-part2-user-configurable-plan.md` Slice 2.
  Committed to branch `issue-73-part2-slice2-potential-parents`; **not
  published** (PR → CI → merge is a separate session, FM \#18/#25).
  Every TDD transition `AskUserQuestion`-gated (PRE-RED→RED→GREEN; no
  REFACTOR needed — 0 lints, code already clean). **0 stakeholder
  corrections.** Owner picked “implement Slice 2” at orientation,
  “plan-literal plain params” at the pre-RED approach gate, and approved
  each phase transition.
- **Reused Slice 1’s reader (no re-merge):**
  [`loadSpeciesOverrides()`](https://github.com/rmsharp/nprcgenekeepr/reference/loadSpeciesOverrides.md)
  already runs at boot into `shared$speciesOverrides` (Slice 1),
  carrying the merged `gestationTable` (D4 — user CSV merged onto
  bundled `speciesGestation`) and the `gestationDefault` fallback. Slice
  2 only wires those two fields down to the existing prefill seam.
- **Threading (R2 honored):** added a `gestationDefault = NULL` argument
  to `pedigreeGestationDefault` and `modPotentialParentsServer`,
  threaded to `getSpeciesGestation`’s `default` via omit-when-NULL
  (`if (is.null(gestationDefault)) accessor(...) else accessor(..., default = gestationDefault)`)
  so the accessor’s built-in 210 applies for no-config; wired
  `appServer` (`R/appServer.R:313-318`) to pass
  `gestationTable = shared$speciesOverrides$gestationTable` and
  `gestationDefault = shared$speciesOverrides$gestationDefault` (today
  it passed NEITHER).
- **Name-collision fix (Learning 176):** the module already had a local
  reactive `gestationDefault` that is ALSO its public returned key — a
  same-named argument would have shadowed it inside the closure and
  silently passed the reactive object instead of the value. Renamed the
  internal reactive to `gestationDefaultReactive` (kept the public key
  `gestationDefault`); the argument stays a lazily-forced promise so the
  boot-loaded override (populated by an `observe` after module
  construction) is read correctly.
- **D5 prefill-only scope respected:**
  `gestationTable`/`gestationDefault` drive only the suggested-window
  prefill, never the computed window (the module forces
  `maxGestationalPeriod` non-NULL, so `getPotentialParents` never
  consults the table) — `R/modPotentialParents.R:242` untouched. No
  scope creep to per-animal windows.
- **Backward-compatibility invariant (hard acceptance test):** both new
  arguments default `NULL`; no config file ⇒
  `shared$speciesOverrides$gestationTable`/`$gestationDefault` are
  `NULL` ⇒ bundled table + built-in 210, byte-identical to today.
- **Verification:** 6 new tests in `test_modPotentialParents.R` (RED
  confirmed failing for the right reason — unused argument / unwired
  appServer); targeted file green (77 expectations, 0/0); clean
  regression read **2986 expectations / 0 failed / 0 error** across 210
  files (0 true offenders); `spell_check_package(".")` = 0 (Learning 175
  reflex); build-equivalent `devtools::check(vignettes = FALSE)` =
  **0/0/0**; 0 lints on all changed files; **Phase-3E runtime smoke** —
  a config CSV overriding RHESUS gestation (210→999) +
  `gestationDefault = 300` drives the prefill to 999 (override) / 300
  (species-less fallback), unlisted CYNOMOLGUS keeps its bundled 170,
  `appServer` boots clean with `shared$speciesOverrides` populated, and
  a no-config boot prefills 210 (identical to today).
- **Issue \#73 stays OPEN** — Part 1 (data) + Part 2 Slice 1 (GVA tab)
  live on `master`; Slice 2 (Potential Parents tab) now implemented on
  the branch (unpublished). Its PR uses **“Closes \#73”** (the last
  part).

### 2026-06-24 — Published issue \#73 Part 2 Slice 1: user-configurable GVA species overrides are on `master` via PR \#78; NEWS added; \#73 stays OPEN (Session 187)

- **Deliverable (owner pick, single item):** publish S186’s issue \#73
  Part 2 Slice 1 (the config-file → app → accessor override path for the
  Genetic Value Analysis) from `issue-73-part2-slice1-gva-overrides` to
  `master`, folding the user-facing NEWS entry into the SAME PR
  (Learning 157a). **Admin/publish + docs** (the Slice 1 code was
  written/tested under strict TDD in S186 → TDD code-phases N/A). **0
  stakeholder corrections.** SOLO (a serial, irreversible git sequence —
  a workflow adds risk, not coverage; held solo despite ultracode, the
  S179/S181/S183 judgment). Owner picked “Publish \#73 Part 2 Slice 1”
  at orientation and “Merge (merge commit)” at the `AskUserQuestion`
  merge gate.
- **Pre-publish content (one PR, Learning 157a):** appended two
  dev-version `NEWS.Rmd` bullets — a *Changes* bullet (the minimum
  male/female breeding ages, maximum gestation, and absent-species
  values the Genetic Value Analysis uses to correct unknown-parent mean
  kinship are now user-configurable via the configuration file: a
  `speciesOverridesPath` CSV plus optional
  `minBreedingAgeDefault`/`gestationDefault`) and a *New features*
  bullet (the exported
  [`loadSpeciesOverrides()`](https://github.com/rmsharp/nprcgenekeepr/reference/loadSpeciesOverrides.md)
  reader). **Self-framed the Changes bullet** to supersede the Part 1
  “Making these values user-configurable is the remaining part of issue
  \#73” line — narrowing “the remaining part” to the Potential Parents
  tab — WITHOUT rewriting the prior bullet (append-don’t-rewrite,
  Learning 171, whose prediction this fulfills). Re-rendered `NEWS.md`
  (permanent `html_preview:false`+`md_extensions:"-smart"`,
  Learning 155) → **0 non-ASCII**, no stray `.html`, a confined
  pure-insertion diff (NEWS.Rmd +20 / NEWS.md +23). Committed NEWS +
  WORDLIST as `7e4404e8`; kept the S187 1B stub OUT of the PR
  (stash-carried, popped clean post-merge).
- **Spelling (Learning 159 / new Learning 175):** the publish-session
  `spell_check_package(".")` flagged one word, `fallbacks`, introduced
  by S186’s `man/loadSpeciesOverrides.Rd` — S186’s
  `devtools::check(vignettes = FALSE)` 0/0/0 did NOT surface it because
  the spelling test `skip_on_cran`s under `--as-cran`. Added `fallbacks`
  to `inst/WORDLIST` → 0 unrecognized; the two new NEWS bullets used the
  verb idiom “fall back” + backticked identifiers → 0 new flagged words
  (verified before and after). A 0/0/0 build-equivalent does not imply
  spelling-clean — the publish session’s independent
  `spell_check_package` is the catch.
- **No push-master-first this cycle:** `master` == `origin/master` ==
  `32155f3a` verified firsthand and the branch was cut directly off
  master, so the routine FF-first step did not apply. The PR diff came
  out Slice-1-only = 3 commits (S186 feat `2ec4c329` + S186 close-out
  `81319c10` + S187 NEWS `7e4404e8`).
- **PR + CI (did NOT merge blind):** opened **PR \#78** → `master` (body
  “Relates to \#73”, NOT `Closes` — Slice 2 remains). **All 10 checks
  PASS** — lint 3m47s; `R CMD check` x5 (macos 7m42s / ubuntu release
  20m35s + oldrel-1 7m08s + **devel 17m26s** / windows 10m09s); pkgdown
  6m02s; test-coverage 4m20s; codecov/patch + codecov/project. Per
  Learning 157b re-queried FRESH with a non-watch `gh pr checks 78` (10
  `pass`, exit 0) before the merge — never trusted the `--watch` exit.
- **Merge (the one irreversible step — `AskUserQuestion`-gated):** owner
  chose “Merge (merge commit).” Guarded fresh pre-merge re-check (state
  OPEN, mergeable MERGEABLE, mergeStateStatus CLEAN, `headRefOid`==local
  `7e4404e8`, `origin/master`==`32155f3a`); `gh pr merge 78 --merge` →
  merge commit **`54b11740`**; verified landed firsthand (state MERGED,
  `mergedAt 2026-06-24T15:12:59Z`, `mergedBy rmsharp`). **Issue \#73
  verified still OPEN** (no closing keyword; Slice 2 remains).
- **Reconcile (Learning 146):** stash-carried the S187 stub;
  `git checkout master`; `git fetch`; **ancestor-gated the reset** (both
  old-master `32155f3a` AND merged branch tip `7e4404e8` asserted
  ancestors of `origin/master` `54b11740`) →
  `git reset --hard origin/master`; `git stash pop` restored the S187
  stub cleanly onto master.
- **Branch cleanup (verified-merged-before-delete):** `git branch -d`
  (was `7e4404e8`) + `git push origin --delete` + `git fetch --prune`;
  verified NO ref remains (local 0, remote-tracking 0, `gh api` →
  **404** “Branch not found”).
- **Verification (Phase-3E):** the merge tree was build-verified by PR
  \#78’s `R CMD check` x5 matrix (incl. ubuntu-devel), all PASS;
  confirmed firsthand on `master` after the reset (via
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)):
  [`loadSpeciesOverrides()`](https://github.com/rmsharp/nprcgenekeepr/reference/loadSpeciesOverrides.md)
  is exported and no-config → all members `NULL` (backward-compat),
  `reportGV`/`correctUnknownParentMeanKinship` carry the four/two
  override params, and both NEWS bullets are live on `master`.
  **Learning 175 added.** **Issue \#73 stays OPEN** (Slice 2 — Potential
  Parents tab — remains; its PR will use “Closes \#73”).

### 2026-06-24 — Implemented issue \#73 Part 2 Slice 1: user-configurable species overrides wired through the GVA tab end-to-end (Session 186)

- **Deliverable (owner pick, single item, strict-TDD IMPLEMENTATION
  session):** the config-file → app → accessor override path for the
  Genetic Value Analysis, per
  `docs/planning/issue73-part2-user-configurable-plan.md` §4 Slice 1.
  Committed to branch `issue-73-part2-slice1-gva-overrides`; **not
  published** (PR → CI → merge is a separate session, FM \#18/#25).
  **Slice 2 (Potential Parents tab) NOT bundled.** Every TDD transition
  `AskUserQuestion`-gated (PRE-RED→RED→GREEN→REFACTOR). **0 stakeholder
  corrections.**
- **New reader (the shared infra, built with its first consumer):**
  `R/loadSpeciesOverrides.R` (exported) reads up to three optional
  config keys — `speciesOverridesPath` (CSV with the four
  `speciesGestation` columns), `minBreedingAgeDefault`,
  `gestationDefault` — via a `getConfigApiKey`-style soft-lookup
  (`R/getSpeciesOverridesPath.R`, internal); validates + type-coerces
  the CSV, **MERGES it onto the bundled `speciesGestation` (D4 —
  unlisted species keep bundled values)**, and soft-fails (warn +
  bundled) like `loadSiteConfig`. Returns
  `list(breedingTable, gestationTable, breedingAgeDefault, gestationDefault)`
  with `NULL` members when absent.
- **Threading (R2 honored — never thread a bare `NULL` into the
  accessors’ `default`):** added `breedingAgeDefault`/`gestationDefault`
  to `getBreedingPeerCohort` + `correctUnknownParentMeanKinship`
  (omit-the-argument-when-NULL at the accessor call, so the accessor’s
  built-in 2.0/210 applies); added all four override params to
  `reportGV` (threaded at `R/reportGV.R:117`); added a
  `speciesOverrides = reactive(NULL)` param to `modGeneticValueServer`
  (threaded into `reportGV`); wired `appServer` to load
  `shared$speciesOverrides` at boot and pass it to the GVA module (D7
  sibling reactive). Documented the three keys + CSV format in
  `inst/extdata/example_nprcgenekeepr_config`.
- **Mid-GREEN defect caught + fixed (mini RED→GREEN):** `getTokenList`
  does not strip `#` comments, so the commented
  `# speciesOverridesPath = ...` example line was parsed as an ACTIVE
  key by the first-match soft-lookup (surfaced in the Phase-3E boot
  smoke). Fixed by stripping full-line comments in the soft-lookup
  before tokenizing; added two regression tests. **Learning 174** added.
- **Backward-compatibility invariant (hard acceptance test):** every new
  param defaults to `NULL`/`reactive(NULL)`; no config file ⇒ overrides
  `NULL` ⇒ output byte-identical to today (verified: explicit-NULL
  `reportGV` == default; no-config GVA correction identical).
- **Verification:** new + amended tests green
  (`test_loadSpeciesOverrides.R` 11 tests,
  `test_correctUnknownParentMeanKinship.R` +4, `test_reportGV.R` +5,
  `test_modGeneticValue.R` +2); clean regression read 1217 tests / 2808
  pass / **0 failed / 0 error**; build-equivalent
  `devtools::check(vignettes = FALSE)` = **0/0/0**; lint clean on
  changed files; **Phase-3E runtime smoke** — a real config CSV drives
  the GVA correction (RHESUS 4→2, CYNOMOLGUS kept at bundled 4) and
  `appServer` boots clean loading the merged 14-row table; no-config
  launch byte-identical.
- **Issue \#73 stays OPEN** — Part 1 (data) live; Part 2 Slice 1
  implemented on the branch (unpublished), Slice 2 not started. The Part
  2 publish (after Slice 2) uses **“Closes \#73”** (the last part);
  Slice 1’s PR uses **“Relates to \#73”** with a NEWS entry folded in
  (Learning 157a).

### 2026-06-23 — Ratified the issue \#73 Part 2 plan: all design decisions resolved; plan is ready-to-RED (Session 185)

- **Deliverable (owner pick, single item, RATIFICATION session):**
  flipped `docs/planning/issue73-part2-user-configurable-plan.md` from
  `Status: DRAFT` to `Status: RATIFIED — ready to RED`. The owner
  ratified all open design decisions via `AskUserQuestion`; the §7
  checklist is resolved and the plan may now declare Slice 1 RED. **No
  implementation** (FM \#18/#25 — ratification is a discrete session in
  the plan → ratify → implement arc; Slice 1 is a separate strict-TDD
  session). **TDD code-phases N/A** (docs-only, no R/ change). **0
  stakeholder corrections.**
- **Decisions ratified (all as recommended):** **D1** = CSV file path
  (one optional config key, `getConfigApiKey`-style soft-lookup; no
  `getSiteInfo` change); **D2** = four bundled columns, header required,
  matched by name, rows-partial only; **D3** = two optional fallback
  keys `minBreedingAgeDefault` (2.0) / `gestationDefault` (210); **D4**
  = **merge** (a user CSV overrides only listed species; unlisted keep
  bundled values); **D5** = gestation override = prefill the suggested
  window only (per-animal deferred); **D6** = GVA tab first (Slice 1),
  Potential Parents second (Slice 2); **D7** = sibling
  `shared$speciesOverrides` passed to modules as a reactive. Confirmed:
  config file only (no Settings-tab UI), backward-compat invariant (no
  config ⇒ identical to today) as a hard acceptance test per slice.
- **Firsthand re-verification before ratifying (FM \#11/#20):**
  confirmed the load-bearing claims directly —
  `getSpeciesMinBreedingAge.R:39-41` / `getSpeciesGestation.R:30-32`
  substitute the bundled table only when the override is NULL and then
  match against ONLY the supplied table (so absent species fall to
  `default`, confirming **D4-replace is real** — the \#1 dragon);
  `getParamDef.R:12` STOPs on a missing key and `getConfigApiKey.R` is
  the optional soft-lookup (confirming **D1**). All recommendations
  held; the firsthand read **sharpened R2** — the accessors have no
  `NULL` handling on `default` (`rep(NULL, n)` = `numeric(0)`), so an
  upper layer must translate “no configured default” into not passing
  `default` to the accessor; this caveat was added to the plan’s R2 for
  the Slice 1 implementer.
- **Issue \#73 stays OPEN** — Part 1 (data) is live; Part 2 (this plan)
  is ratified but unimplemented. A future Part 2 publish uses **“Closes
  \#73”** (the last part). **Learning 173** added to
  `PROJECT_LEARNINGS.md`.

### 2026-06-23 — Planned issue \#73 Part 2: user-configurable species overrides via the config file (Session 184)

- **Deliverable (owner pick, single item, PLANNING session):** wrote
  `docs/planning/issue73-part2-user-configurable-plan.md` — the plan for
  making the species minimum-breeding-age / gestation /
  absent-species-fallback values user-configurable (issue \#73 Part 2).
  **No implementation** (FM \#18/#25; the plan is the deliverable,
  implementation is a separate session per slice). **TDD code-phases
  N/A** (planning doc, no R/ change). **0 stakeholder corrections.**
- **Two owner decisions taken at orientation** (`AskUserQuestion`):
  mechanism = **config file** (extend `~/.nprcgenekeepr_config`, loaded
  at boot via
  [`loadSiteConfig()`](https://github.com/rmsharp/nprcgenekeepr/reference/loadSiteConfig.md);
  the empty Settings-tab UI is out of scope); scope = **all three value
  groups** (breeding ages, gestation, fallback).
- **Grounding:** a 4-mapper read-only workflow (`wf_c21598f3-932`:
  config-file / breeding-age-chain / gestation-chain / test-validation)
  plus **firsthand verification of every load-bearing call site** —
  `reportGV.R:103` (no override),
  `correctUnknownParentMeanKinship.R:96`/`getBreedingPeerCohort:31`
  (thread both tables, no configurable `default`),
  `modGeneticValue.R:121,185` (no config param),
  `modPotentialParents.R:208,242` (accepts `gestationTable` but uses it
  only for the prefill; the `getPotentialParents` call passes none, a
  no-op while `maxGestationalPeriod` is non-NULL),
  `getPotentialParents.R:63-69` (consults `gestationTable` only when
  `maxGestationalPeriod` is NULL), `appServer.R:106,266,307` (the
  `modInputServer` config-reactive precedent vs. the two un-wired target
  modules), and the config subsystem (`getSiteInfo` fixed-schema,
  `getParamDef` STOPs on missing keys, `getConfigApiKey`
  optional-soft-lookup precedent).
- **Plan content:** evidence-based inventory (§2) with verified
  `file:line`; seven design decisions for ratification (§3) — headline
  recommendations: **D1 CSV-path key** (a `getConfigApiKey`-style
  helper; no `getSiteInfo` change) over inline keys, and **D4
  merge-onto-bundled** (not replace) so a partial CSV does not silently
  mis-age unlisted species; two **vertical slices** (§4, FM \#25) each
  with RED/GREEN/DONE/Verify/boundary/dragons — Slice 1 GVA tab
  end-to-end (builds the shared reader), Slice 2 Potential Parents tab
  end-to-end (reuses it); here-be-dragons (§6) and an owner ratification
  checklist (§7). Backward-compat invariant (no config ⇒ identical to
  today) is the through-line; **Phase-3E runtime smoke required for both
  implementation slices** (Shiny wiring changes).
- **Issue \#73 stays OPEN** — Part 1 (data) is live; Part 2 (this plan)
  is unimplemented. A future Part 2 publish uses **“Closes \#73”** (it
  is the last part). **Learning 172** added to `PROJECT_LEARNINGS.md`.

### 2026-06-23 — Published issue \#73 Part 1: the 14-species reproductive-parameter table is on `master` via PR \#77; NEWS entry added; \#73 stays OPEN (Session 183)

- **Deliverable (owner pick, single item):** publish S182’s issue \#73
  Part 1 (feat `2cee7fa4` — generalize `speciesGestation` from
  rhesus-only to 14 common colony NHP species; breeding-age columns
  integer → numeric) from `issue-73-populate-breeding-age-table` to
  `master`, folding the user-facing NEWS entry into the SAME PR
  (Learning 157a). **Admin/publish + docs** (the Part 1 code was
  written/tested under strict TDD in S182 → TDD code-phases N/A). **0
  stakeholder corrections.** SOLO (a serial, irreversible git sequence —
  a workflow adds risk, not coverage; held solo despite ultracode, the
  S179/S181 judgment). Owner picked “Publish \#73 Part 1” at orientation
  and “Merge (merge commit)” at the `AskUserQuestion` merge gate.
- **Pre-publish content (one PR, Learning 157a):** read S182’s changed
  files firsthand (`data-raw/speciesGestation.R`,
  `R/getSpeciesMinBreedingAge.R`, `R/data.R`) and diffed them vs
  `master`, then appended ONE dev-version *Changes* bullet to `NEWS.Rmd`
  describing BOTH consumers the single shared table feeds — per-species
  maximum gestation
  ([`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
  via
  [`getSpeciesGestation()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesGestation.md))
  AND per-species minimum male/female breeding ages (the GVA
  unknown-parent mean-kinship correction via
  [`getSpeciesMinBreedingAge()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesMinBreedingAge.md))
  — plus the integer → numeric move (fractional minima like rhesus
  female 2.5 exact) and the unchanged-for-species-less-data fallback.
  **Self-framed the bullet (“previously seeded with only rhesus macaque
  … now populated for 14 species”)** so it reads coherently with the
  earlier dev-version “only rhesus” bullets WITHOUT rewriting them
  (append-don’t-rewrite; Learning 171). Re-rendered `NEWS.md` (permanent
  `html_preview:false`+`md_extensions:"-smart"`, Learning 155) → **0
  non-ASCII**, no stray `.html`, a confined pure-insertion diff
  (NEWS.Rmd +13 / NEWS.md +15, nothing reflowed, no date churn).
  `spell_check_package(".")` = **0 unrecognized** before AND after → no
  WORDLIST change (held the bullet at summary level rather than
  enumerating species names, which would have needed WORDLIST entries).
  Committed NEWS only as `f13da525`; kept the S183 1B stub OUT of the PR
  (stash-carried, popped clean post-merge).
- **No “push master first” step this cycle:** `master` ==
  `origin/master` == `3937a918` (S181 ended the local-ahead drift per
  \[\[push-close-out-docs-to-origin\]\]) and the branch was cut DIRECTLY
  off master, so the routine S178/S180 FF-first Gotcha did NOT apply.
  The PR diff came out Part-1-only = 3 commits (S182 feat `2cee7fa4` +
  S182 close-out `068aeba5` + S183 NEWS `f13da525`), verified firsthand
  (commit list + changed-file list).
- **PR + CI (did NOT merge blind):** opened **PR \#77** → `master` (body
  “Relates to \#73”, NOT `Closes #73` — Part 2 remains). **All 10 checks
  PASS** — lint 4m40s; `R CMD check` x5 (macos 5m54s / ubuntu release
  7m38s + oldrel-1 7m42s + **devel 16m12s** the long pole / windows
  9m28s); pkgdown 5m56s; test-coverage 4m24s; **codecov/patch +
  codecov/project PASS**. The background watch exited 0, but per
  Learning 157 I re-queried FRESH with non-watch `gh pr checks 77` (10
  `pass`, exit 0) before proceeding.
- **Merge (the one irreversible step — `AskUserQuestion`-gated):** owner
  chose “Merge (merge commit).” Guarded fresh pre-merge re-check (state
  OPEN, mergeable MERGEABLE, mergeStateStatus CLEAN, `headRefOid`==local
  `f13da525`, `origin/master`==`3937a918`); `gh pr merge 77 --merge` →
  merge commit **`5082df83`**; verified landed firsthand (state MERGED,
  `mergedAt 2026-06-23T19:22:05Z`, `mergedBy rmsharp`). **Issue \#73
  verified still OPEN** after the merge (no closing keyword; Part 2
  remains).
- **Reconcile (Learning 146):** stash-carried the S183 stub;
  `git checkout master`; `git fetch`; **ancestor-gated the reset** (both
  old-master `3937a918` AND merged branch tip `f13da525` asserted
  ancestors of `origin/master` `5082df83`) →
  `git reset --hard origin/master`; `git stash pop` restored the S183
  stub cleanly onto master.
- **Branch cleanup (verified-merged-before-delete):** `git branch -d`
  (was `f13da525`) + `git push origin --delete` + `git fetch --prune`;
  verified NO ref remains (local 0, remote-tracking 0, `gh api` →
  **404** “Branch not found”).
- **Verification (Phase-3E):** re-verified on the merge-result tree by
  PR \#77’s `R CMD check` x5 matrix (incl. ubuntu-devel), all PASS;
  confirmed firsthand on `master` after the reset (via
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)):
  `speciesGestation` has 14 rows, both breeding-age columns numeric,
  `getSpeciesMinBreedingAge("RHESUS","F")` = 2.5 (numeric), rhesus M =
  4, `getSpeciesGestation("BONOBO")` = 240, unknown species → 210
  fallback, and the NEWS bullet is live on `master`. **Learning 171
  added.** **Issue \#73 stays OPEN** (Part 2 user-configurable override
  path remains).

### 2026-06-23 — Implemented issue \#73 Part 1: populated the species reproductive-parameter table for all common colony NHP species; breeding-age columns moved to numeric (Session 182)

- **Deliverable (owner pick, single item):** generalize the bundled
  `speciesGestation` lookup from rhesus-only to all 14 common colony NHP
  species (issue \#73 Part 1 — the data population), moving the two
  breeding-age columns integer → numeric to hold fractional minima.
  Strict TDD (RED→GREEN→REFACTOR, every transition
  `AskUserQuestion`-gated). **0 stakeholder corrections.** Committed on
  branch `issue-73-populate-breeding-age-table`; **UNPUBLISHED** —
  `master` unchanged. **Part 2 (user-configurable override path)
  deferred to a separate session — issue \#73 stays OPEN.**
- **Owner supplied the biological values (a methodology/veterinary call,
  not a code default):** 14 species with minimum female/male
  breeding-age ranges and gestation ranges. Conversion rules
  (owner-confirmed via `AskUserQuestion`): minimum breeding age = LOW
  end of each range; gestation column = conservative maximum = HIGH end
  of each range. Rhesus gestation kept at its existing conservative 210
  (owner chose “keep 210” over the supplied 164–166 typical figure — the
  issue scopes gestation to “where missing” and rhesus is not missing;
  avoids changing `getPotentialParents` behavior + its tests).
- **What changed:** `data-raw/speciesGestation.R` now builds a 14-row
  table (RHESUS, CYNOMOLGUS, JAPANESE MACAQUE, PIG-TAILED MACAQUE,
  BABOON, VERVET, AFRICAN GREEN MONKEY, SQUIRREL MONKEY, COMMON
  MARMOSET, COTTON-TOP TAMARIN, OWL MONKEY, CAPUCHIN, CHIMPANZEE,
  BONOBO); the `minMaleBreedingAge`/`minFemaleBreedingAge` columns moved
  **integer → numeric** to hold fractional minima (rhesus female 2.5,
  squirrel-monkey male 3.5, marmoset 1.0, tamarin 1.5).
  [`getSpeciesMinBreedingAge()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesMinBreedingAge.md)
  coercions [`as.integer()`](https://rdrr.io/r/base/integer.html) →
  [`as.numeric()`](https://rdrr.io/r/base/numeric.html) (the two age
  columns, the `default`, and the empty-input return `integer(0L)` →
  `numeric(0L)`); the gestation column stays integer. Roxygen
  (`R/data.R`, both accessors) + `man/*.Rd` regenerated; NAMESPACE
  byte-identical.
- **Rhesus female moved 3 → 2.5 — confirmed zero real-data/GVA impact
  (verified firsthand, not assumed):** no shipped pedigree
  (`qcPed`/`breederPed`/`examplePedigree`) carries a `species` column,
  so the GVA unknown-parent mean-kinship correction uses the
  species-absent default cutoff of 2 on real data; the rhesus and
  new-species cutoffs are exercised only by the accessor unit tests +
  the synthetic species-bearing fixture in
  `test_correctUnknownParentMeanKinship.R` (which uses the rhesus MALE
  cutoff 4, unchanged). The change is therefore contained to two test
  files.
- **Files:** `data-raw/speciesGestation.R`,
  `data/speciesGestation.RData` (regenerated),
  `R/getSpeciesMinBreedingAge.R`, `R/getSpeciesGestation.R` (doc/example
  only), `R/data.R` (doc), `man/speciesGestation.Rd` +
  `man/getSpeciesMinBreedingAge.Rd` + `man/getSpeciesGestation.Rd`
  (regenerated). Tests: `test_getSpeciesMinBreedingAge.R` (rewritten to
  numeric + 14-species assertions) and `test_getSpeciesGestation.R`
  (new-species gestation assertions; `JAPANESE MACAQUE` repointed off
  the unknown-species fallback case).
  `test_correctUnknownParentMeanKinship.R` + `test_reportGV.R` unchanged
  (verified unaffected).
- **Verification:** RED = 49 failing assertions across the two files,
  failing for the right reason, no collateral (the 2 unaffected files
  stayed green — 20/0 and 25/0). GREEN = data + accessor coercion only.
  REFACTOR = doc/roxygen + lint (`.lintr` excludes `tests/` but not
  `data-raw/`, so the data vectors use explicit doubles `4.0`). Full
  clean regression **2183 pass / 0 fail / 0 error** (203 files); **0
  lints** (namespace-loaded, Learning 167); **0 spelling** (no WORDLIST
  change); build-equivalent `devtools::check(vignettes = FALSE)` =
  **0/0/0** (Learning 161). **NEWS deferred to the publish PR**
  (Learning 157a). Learning 170 added. **Issue \#73 stays OPEN** (Part 2
  user-config remains).

### 2026-06-23 — Published issue \#9 Slice 3: classify unknown-parent animals + classification-aware GVA rank is on `master` via PR \#75; NEWS added; \#9 CLOSED; filed Reading A follow-up \#76 (Session 181)

- **Deliverable (owner pick, single item):** publish S180’s issue \#9
  Slice 3 (feat `3be9f818`) — classify each animal’s parentage and
  demote both-unknown founders in the displayed Genetic Value rank —
  from `issue-9-slice3-classify-rank-aware` to `master`, folding the
  user-facing NEWS entry into the SAME PR (Learning 157a).
  **Admin/publish + docs** (the Slice 3 code logic was written/tested
  under strict TDD in S180 → TDD code-phases N/A). **0 stakeholder
  corrections.** SOLO (a serial, irreversible git sequence — a workflow
  adds risk, not coverage; held solo despite ultracode). Owner picked
  “Publish Slice 3” at orientation, “Closes \#9” at the issue-close
  gate, and “Merge (merge commit)” at the merge gate.
- **Pre-publish content (one PR, Learning 157a):** read the four changed
  `R/` files firsthand and added a dev-version *Changes* bullet to
  `NEWS.Rmd` describing BOTH user-facing effects — the new `parentage`
  column (`known`/`one unknown parent`/`both unknown`) in the report and
  both CSV exports, AND the displayed-rank demotion of both-unknown
  founders (marked “Undetermined”, ranked last) with genuine imports
  still ranked. Re-rendered `NEWS.md` (permanent
  `html_preview:false`+`md_extensions:"-smart"`, Learning 155) → 0
  non-ASCII, no stray `.html`, a confined pure-insertion diff (NEWS.Rmd
  +11 / NEWS.md +12, nothing reflowed, no date churn).
  `spell_check_package(".")` = 0 unrecognized before AND after → no
  WORDLIST change. Committed NEWS only as `3b1c7d9f`; kept the S181 1B
  stub OUT of the PR (stash-carried, popped clean post-merge).
- **Push master first (S180 Gotcha 2):** local `master` was 1 ahead of
  `origin/master` (S179 close-out docs `25d0d191`, unpushed) and the
  branch was cut from it → FF-verified
  (`merge-base --is-ancestor 800fb98c 25d0d191`) and pushed `master`
  first (`800fb98c`→`25d0d191`); the PR diff came out Slice-3-only = 3
  commits (S180 feat `3be9f818` + S180 close-out `29854331` + S181 NEWS
  `3b1c7d9f`), no S176/S177/S179 bundling.
- **Issue-close decision (owner gate):** Reading B resolves \#9’s
  displayed-ranking complaint, so the owner chose “Closes \#9” — the PR
  body carries `Closes #9` (auto-close on merge). The deferred Reading A
  (genuine `gu` de-inflation) was filed as a SEPARATE follow-up so \#9
  does not stay open as a vague catch-all (see below).
- **PR + CI (did NOT merge blind):** opened **PR \#75** → `master` (body
  `Closes #9`). **All 10 checks PASS** — lint 3m47s; `R CMD check` x5
  (macos 4m51s / ubuntu release 7m40s + oldrel-1 7m11s + **devel
  16m35s** the long pole / windows 9m16s); pkgdown 6m14s; test-coverage
  4m28s; **codecov/patch + codecov/project PASS**. The background watch
  exited 0, but per Learning 157 I re-queried FRESH with non-watch
  `gh pr checks 75` (10 `pass`, exit 0) before proceeding.
- **Merge (the one irreversible step — `AskUserQuestion`-gated):** owner
  chose “Merge (merge commit).” Guarded fresh pre-merge re-check (state
  OPEN, mergeable MERGEABLE, mergeStateStatus CLEAN, `headRefOid`==local
  `3b1c7d9f`, `origin/master`==`25d0d191`); `gh pr merge 75 --merge` →
  merge commit **`5ada4b71`**; verified landed firsthand (state MERGED,
  `mergedAt 2026-06-23T13:52:05Z`, `mergedBy rmsharp`). **Issue \#9
  verified CLOSED** after the merge (`closedAt 2026-06-23T13:52:06Z`,
  auto-closed by `Closes #9`).
- **Reconcile (Learning 146):** stash-carried the S181 stub;
  `git checkout master`; `git fetch`; **ancestor-gated the reset** (both
  old-master `25d0d191` AND merged branch tip `3b1c7d9f` asserted
  ancestors of `origin/master` `5ada4b71`) →
  `git reset --hard origin/master`; `git stash pop` restored the S181
  stub cleanly onto master.
- **Branch cleanup (verified-merged-before-delete):** `git branch -d`
  (was `3b1c7d9f`) + `git push origin --delete` + `git fetch --prune`;
  verified NO ref remains (local 0, remote-tracking 0,
  `gh api .../git/refs/heads/issue-9-slice3-classify-rank-aware` →
  **404**).
- **Filed the deferred Reading A as a NEW issue \#76** (“GVA: de-inflate
  the genome-uniqueness statistic for both-unknown founders — Reading A,
  deferred from \#9 Slice 3”, labeled `enhancement`): a deep-genetics
  change that reverses the documented `calcGU.R:10-34` stance and breaks
  golden invariants, so it needs a §8-E-style ratification (formula +
  replacement `calcGU`/`calcA` golden values) FIRST, then a separate
  implement. This keeps \#9 honestly closed (its surface complaint is
  met) while not dropping the deferred deeper scope. (Learning 169.)
- **Verification (Phase-3E):** the deliverable was re-verified on the
  merge-result tree by PR \#75’s `R CMD check` x5 matrix
  (incl. ubuntu-devel), all PASS; confirmed firsthand on `master` after
  the reset: `R/classifyParentage.R` present,
  `R/reportGV.R`/`R/orderReport.R`/`R/modGeneticValue.R` carry the Slice
  3 logic, `NEWS.md` has the Slice 3 bullet, and the 4 targeted test
  files pass locally on the merged master — `test_modGeneticValue.R`
  (with `NOT_CRAN=true`) is 148 pass / 0 fail / 0 skip / 0 error and the
  “demotes both-unknown founders to the bottom (#9 Slice 3)”
  `testServer` test runs and passes. **No browser smoke** (consistent
  with the §8-A/Slice 2 precedent + baseline e2e noise) — stated, not
  silently skipped. **Learning 169 added.**

### 2026-06-23 — Implemented issue \#9 Slice 3: classify unknown-parent animals + demote both-unknown founders in the displayed rank (Session 180)

- **Deliverable (owner pick, single item):** implement Slice 3 of the
  issue \#9 plan per the §8-F charter — classify each animal’s parentage
  and make the Shiny-displayed Genetic Value rank classification-aware
  so both-unknown founders no longer falsely top-rank. Strict TDD
  (RED→GREEN→REFACTOR, every transition `AskUserQuestion`-gated). **0
  stakeholder corrections.** Committed on branch
  `issue-9-slice3-classify-rank-aware`; **UNPUBLISHED** — `master`
  unchanged. Did NOT publish and did NOT recompute `gu` (FM \#18/#25).
- **Two owner decisions surfaced by real-data grounding (a charter is
  not a spec):** §8-F’s “address the `gu` inflation” had no ratified
  algorithm. Grounding offered **Reading B** (rank *around* `gu` — make
  the display classification-aware, `gu` untouched, implementable now)
  vs **Reading A** (recompute founder `gu` in `calcGU`/`calcA` —
  reverses the documented `calcGU.R:10-34` stance, breaks golden
  invariants, needs a §8-E-style ratification first). Owner chose
  **Reading B**. Then grounding revealed all 124 both-unknown founders
  on `qcPed` HAVE offspring, so the existing `noParentage`
  `totalOffspring==0` gate would make the fix a no-op; owner chose
  **demote-all-keep-imports** (drop the offspring gate; keep genuine
  imports ranked).
- **What the change does:** new internal `classifyParentage(sire, dam)`
  (U-id aware) adds a `parentage` column to the report (`known` /
  `one unknown parent` / `both unknown`); `orderReport` now treats an
  absent `origin` column as all-NA and flags no-origin both-unknown
  founders (regardless of offspring) as `noParentage`/“Undetermined”
  while keeping genuine imports; `modGeneticValue.R:204-206` ranks
  “Undetermined” animals LAST (`order(demote, indivMeanKin - gu)` then
  reseq) so they no longer top-rank the displayed table. `gu`,
  `calcGU`/`calcA`, and
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  are untouched.
- **Files:** new `R/classifyParentage.R`; edits to `R/reportGV.R`,
  `R/orderReport.R`, `R/modGeneticValue.R`. Tests: new
  `tests/testthat/test_classifyParentage.R`; `test_orderReport.R`
  rewritten (D8 brittle `34`/`21` golden counts → named-animal behavior
  assertions on an `origin`-bearing fixture); `test_reportGV.R` +
  `test_modGeneticValue.R` extended (parentage column + D7 demotion via
  `testServer`).
- **Verification:** 4 targeted test files green; full clean regression
  read **0 failed / 0 errors** (209 files, 1192 tests); **0 lints**
  (namespace-loaded, Learning 167); **0 spelling**; build-equivalent
  `devtools::check(vignettes = FALSE)` = **0/0/0** (Learning 161).
  **Phase-3E:** the real `modGeneticValueServer` on shipped `qcPed`
  (`testServer`) shows the displayed top-20 is now 18 known + 2
  one-unknown (0 both-unknown), all 45 living both-unknown founders
  demoted to ranks 45-89; `shinyApp(appUI(), appServer)` builds. **NEWS
  deferred to the publish PR** (Learning 157a). Learning 168 added.
  **Issue \#9 can close on publish of this slice** (the displayed top no
  longer shows both-unknown founders); confirm at publish.

### 2026-06-23 — Published issue \#9 Slice 2: one-unknown-parent mean-kinship correction is on `master` via PR \#74; NEWS entry added; \#9 stays open (Session 179)

- **Deliverable (owner pick, single item):** publish S178’s issue \#9
  Slice 2 – the Genetic Value Analysis mean-kinship correction for
  animals missing **exactly one** parent (feat `af4b7f69`) – from
  `issue-9-slice2-unknown-parent-mean-kinship` to `master`, folding the
  user-facing NEWS entry into the SAME PR (Learning 157a).
  **Admin/publish + docs** (the Slice 2 code logic was written/tested
  under strict TDD in S178 -\> TDD code-phases N/A). **0 stakeholder
  corrections.** SOLO (a serial, irreversible git sequence – a workflow
  adds risk, not coverage; held solo despite ultracode). Owner picked
  option 1 (publish) at orientation, then chose “Merge (merge commit)”
  at the `AskUserQuestion` merge gate.
- **Pre-publish content (one PR, Learning 157a):** added a dev-version
  *Changes* bullet to `NEWS.Rmd` – the GVA now corrects the mean kinship
  of animals missing one parent (it adds an estimate of the missing
  parent’s contribution from a contemporaneous breeding-age peer cohort
  of the same sex), so these animals no longer falsely rank low on mean
  kinship; both-parents-known and both-unknown animals are unchanged.
  Re-rendered `NEWS.md` (permanent
  `html_preview:false`+`md_extensions:"-smart"`, Learning 155) -\> **0
  non-ASCII**, no stray `.html`, a confined pure-insertion diff
  (NEWS.Rmd +9 / NEWS.md +10, exactly the bullet, nothing reflowed, no
  date churn). `spell_check_package(".")` = **0 unrecognized** before
  AND after -\> no WORDLIST change. Committed NEWS only as `d683bbfc`;
  kept the S179 1B stub OUT of the PR (stash-carried, popped clean
  post-merge).
- **Push master first (S178 Gotcha 3):** `master` was 2 ahead of
  `origin/master` (S176 `488f2b09` + S177 `2bee0f03` close-out docs,
  unpushed) and the branch was cut from that master -\> pushed `master`
  first (FF `origin/master` `0d559d3b` -\> `2bee0f03`) so the PR diff is
  S178-only; the PR diff came out = 3 commits (S178 feat `af4b7f69` +
  S178 close-out `19ac25ed` + S179 NEWS `d683bbfc`), no S176/S177
  bundling.
- **PR + CI (did NOT merge blind):** opened **PR \#74** -\> `master`
  (body “Relates to \#9”, NOT `Closes #9` – only Slice 2 of the
  remaining 2). **All 10 checks PASS** – lint 5m5s; `R CMD check` x5
  (macos 5m2s / ubuntu release 8m12s + oldrel-1 7m1s + **devel 16m42s**
  the long pole / windows 9m21s); pkgdown 5m36s; test-coverage 4m8s;
  **codecov/patch + codecov/project PASS**. The background watch exited
  0, but per Learning 157 I re-queried FRESH with non-watch
  `gh pr checks 74` (10 `pass`, exit 0) before proceeding.
- **Merge (the one irreversible step – `AskUserQuestion`-gated):** owner
  chose “Merge (merge commit).” Guarded fresh pre-merge re-check (state
  OPEN, mergeable MERGEABLE, mergeStateStatus CLEAN, `headRefOid`==local
  `d683bbfc`, `origin/master`==`2bee0f03`); `gh pr merge 74 --merge` -\>
  merge commit **`800fb98c`**; verified landed firsthand (state MERGED,
  `mergedAt 2026-06-23T04:37:15Z`, `mergedBy rmsharp`). **Issue \#9
  verified still OPEN** after the merge (no closing keyword).
- **Reconcile (Learning 146):** stash-carried the S179 stub;
  `git checkout master`; `git fetch`; **ancestor-gated the reset** (both
  old-master `2bee0f03` AND merged branch tip `d683bbfc` asserted
  ancestors of `origin/master` `800fb98c`) -\>
  `git reset --hard origin/master`; `git stash pop` restored the S179
  stub cleanly onto master.
- **Branch cleanup (verified-merged-before-delete):** `git branch -d`
  (was `d683bbfc`) + `git push origin --delete` + `git fetch --prune`;
  verified NO ref remains (local 0, remote-tracking 0,
  `gh api .../git/refs/heads/issue-9-slice2-unknown-parent-mean-kinship`
  -\> **404**).
- **Verification (Phase-3E):** the deliverable was re-verified on the
  merge-result tree by PR \#74’s `R CMD check` x5 matrix
  (incl. ubuntu-devel), all PASS; confirmed firsthand on `master` after
  the reset: `R/correctUnknownParentMeanKinship.R` +
  `R/getSpeciesMinBreedingAge.R` present, `R/reportGV.R:103` carries the
  `correctUnknownParentMeanKinship(...)` injection, `NEWS.md:55` has the
  Slice 2 bullet, and `test_reportGV.R` passes locally on the merged
  master. **No new numbered learning** (clean re-execution of the
  documented publish convention 133/135/146/152/155/157/157a/159/161).
  **Issue \#9 stays OPEN** (Slice 3 remains; \#9 does not close on Slice
  2 per §8-A).

### 2026-06-22 — Implemented issue \#9 Slice 2: mean-kinship correction for one-unknown-parent animals (Session 178)

- **Deliverable (owner pick, single item):** implement Slice 2 of the
  issue \#9 plan per the authoritative **§8-E** spec — correct the
  Genetic Value Analysis mean kinship of animals missing **exactly one**
  parent. Strict TDD (RED→GREEN→REFACTOR, every transition
  `AskUserQuestion`-gated). **0 stakeholder corrections.** Committed on
  branch `issue-9-slice2-unknown-parent-mean-kinship` (feat `af4b7f69`);
  **UNPUBLISHED** — `master` unchanged at `2bee0f03`. Did NOT publish
  and did NOT start Slice 3 (FM \#18/#25).
- **What the fix does:** `reportGV` now raises a one-unknown animal’s
  individual mean kinship by `sexMean/2` — half the mean individual mean
  kinship of its *contemporaneous breeding-age peers of the missing
  parent’s sex* — modeling the unknown parent as a typical opposite-sex
  colony member (the owner’s 2020 remedy). Known-parentage and
  both-unknown founders are unchanged (both-unknown deferred to Slice
  3). Injected at the shared `indivMeanKin` choke point
  (`R/reportGV.R:94`), so both rank paths and the report column reflect
  it;
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  untouched (5 callers).
- **New infrastructure:** exported
  `getSpeciesMinBreedingAge(species, sex)` (mirrors
  `getSpeciesGestation`); `speciesGestation` gains
  `minMaleBreedingAge`/`minFemaleBreedingAge` (rhesus 4/3;
  absent/unknown species or non-M/F sex → default 2); internal
  `getBreedingPeerCohort()` + `correctUnknownParentMeanKinship()`
  (U-id-aware targeting; present-at-conception cohort;
  `pmin(MK+sexMean/2, 1)` clamp; empty/no-birth cohort → flag + add 0,
  never NA). Tier-2 same-era fallback **deferred** (owner decision S178
  — never fires on `qcPed`, no era mechanism exists; documented
  limitation).
- **Owner decision (pre-RED scope gate):** the ratified §8-C 3-tier
  fallback ladder → **tier 1 + tier 3 only**; tier 2 deferred (verified
  firsthand the strict cohort never empties on `qcPed` — all 43
  one-unknown animals get male cohorts of 17–26).
- **Verification:** 3 targeted test files green (29+20+19); clean
  regression read 0 failed / 0 error (real files); lint clean under the
  namespace-loaded CI mode; build-equivalent
  `devtools::check(vignettes = FALSE)` = **0/0/0**. **NEWS deferred to
  the publish PR** (Learning 157a; user-facing: corrected mean kinship
  for partial-parentage animals). **Issue \#9 stays OPEN** (Slice 3
  remains; \#9 does not close on Slice 2 per §8-A). Learning 167 added.

### 2026-06-22 — Ratified issue \#9 §7 design decisions via `/grill-me`; reshaped Slice 2; filed follow-up \#73 (Session 177)

- **Deliverable (owner pick, single item):** ratify §7 of the issue \#9
  plan (`docs/planning/issue9-gva-unknown-parent-ranking-plan.md`)
  BEFORE implementing Slice 2 – resolve D1/D3/D4/D6/D7/D8 + slice order
  and run a `/grill-me` on D2 (the substitution algebra).
  **Design/ratification deliverable -\> TDD code-phases N/A; NO
  production code changed.** **0 stakeholder corrections** (the owner
  materially reshaped the design during the grill). Did NOT implement
  (FM \#18/#25 – Slice 2 is a separate future session).
- **Load-bearing finding (precompute workflow `wf_7f819b92-a12` on real
  `qcPed`):** the DISPLAYED GVA rank is dominated by genome uniqueness
  (`gu` 0..50), not mean kinship (~0.003..0.017), by 3-4 orders of
  magnitude – so the mean-kinship fix corrects the number but does NOT
  move the visible top-20. \#9’s false top-ranking has TWO causes
  (deflated mean kinship + inflated `gu`); the 2020 remedy fixes only
  the first. (Learning 166.)
- **Ratified (plan §8, authoritative):** D1 scalar-level fix; D2 =
  per-focal CONTEMPORANEOUS peer cohort (NOT a global mean –
  era-specificity in line-bred colonies),
  `MK_corrected = pmin(MK_current + sexMean/2, 1)`, `sexMean` = mean of
  the cohort’s individual mean-kinships, self-term -\> `(1+sexMean)/2`;
  **Slice 2 corrects ONE-unknown animals only** (both-unknown deferred);
  a species/sex breeding-age table (extend `speciesGestation` +
  `getSpeciesMinBreedingAge`, rhesus male 4 / female 3, fallback 2)
  replaces the scalar `minParentAge`; D6 `gu` axis flips IN-SCOPE
  (expanded Slice 3); D7 deferred to Slice 3; D8
  `test_orderReport:24,42` NOT changed by Slice 2 (verified – they count
  both-unknown U-stubs on a frozen fixture).
- **Adversarial self-review (workflow `wf_1408109e-bf8`, 4 reviewers):**
  GO-WITH-FIXES – caught a MAJOR implementability gap (the `species`
  column is absent on `qcPed`/`breederPed`, so the helper must guard it
  and the seeded rhesus values are not exercised on the fixture) + three
  stale §3/§6 statements contradicting the ratified §8; all fixes
  applied (per-item SUPERSEDED banners + the §8 corrections).
- **Owner-requested follow-up filed as \#73** (species breeding-age
  values for all common colony NHP + user-configurable). **Phase-3E
  N/A** (ratification document; no runtime behavior changed). Issue \#9
  stays OPEN (Slice 2 + Slice 3 remain).

### 2026-06-22 — Published issue \#9 Slice 1 (S3): Sire/Dam GVA columns are on `master` via PR \#72; NEWS entry added; \#9 stays open (Session 176)

- **Deliverable (owner pick, single item):** publish S175’s issue \#9
  Slice 1 (S3) – the `sire`/`dam` columns in the GVA report + both CSV
  exports – from `issue-9-s3-sire-dam-columns` to `master`, folding the
  user-facing NEWS entry into the SAME PR (Learning 157a).
  **Admin/publish + docs** (no production-code logic -\> TDD N/A). **0
  stakeholder corrections.** SOLO (a serial, irreversible git sequence –
  a workflow adds risk, not coverage). Owner picked option 1 (publish),
  then approved the merge (merge commit) at the `AskUserQuestion` gate.
- **Pre-publish content (one PR, Learning 157a):** added a dev-version
  *Changes* bullet to `NEWS.Rmd` – the GVA report and both of its CSV
  exports now include `sire`/`dam` columns, so it is visible which
  animals have an unknown parent. Column names backtick-wrapped
  (spell_check skips code spans). Re-rendered `NEWS.md` (permanent
  `html_preview:false`+`md_extensions:"-smart"`, Learning 155) -\> **0
  non-ASCII**, no stray `.html`, a confined pure-insertion diff (NEWS.md
  +6 / NEWS.Rmd +5). `spell_check_package(".")` = **0 unrecognized**
  before and after -\> no WORDLIST change. Committed NEWS only as
  `823617ae`; kept the S176 1B stub OUT of the PR (stash-carried).
- **Push master first (S175 Gotcha 2):** `master` was 2 ahead of
  `origin/master` (S173 `658f32d9` + S174 `20f51391`, unpushed) and the
  branch was cut from that master -\> pushed `master` first (FF
  `origin/master` `c7f6ea86` -\> `20f51391`) so the PR diff is
  S175-only; verified the PR diff = 3 commits (S175 feat + close-out +
  S176 NEWS) / 8 expected files, no S173/S174 bundling.
- **PR + CI (did NOT merge blind):** opened **PR \#72** -\> `master`
  (body uses “Relates to \#9”, NOT `Closes #9` – only Slice 1 of 3).
  **All 10 checks PASS** – lint 3m35s; `R CMD check` x5 (macos 6m44s /
  ubuntu release 6m28s + oldrel-1 6m33s + **devel 16m5s** the long pole
  / windows 9m2s); pkgdown 5m17s; test-coverage 4m26s; **codecov/patch
  PASS**; **codecov/project PASS**. The background watch exited 0, but
  per Learning 157 I re-queried FRESH with non-watch `gh pr checks 72`
  (10 `pass`, exit 0) before proceeding.
- **Merge (the one irreversible step – `AskUserQuestion`-gated):** owner
  chose “Yes, merge commit.” Guarded fresh pre-merge re-check (state
  OPEN, mergeable MERGEABLE, mergeStateStatus CLEAN, `headRefOid`==local
  `823617ae`, `origin/master`==`20f51391`); `gh pr merge 72 --merge` -\>
  merge commit **`0d559d3b`**; verified landed firsthand (state MERGED,
  `mergedAt 2026-06-23T00:45:42Z`, `mergedBy rmsharp`). **Issue \#9
  verified still OPEN** after the merge (no closing keyword).
- **Reconcile (Learning 146):** stash-carried the S176 stub;
  `git checkout master`; `git fetch`; **ancestor-gated the reset** (both
  old-master `20f51391` AND merged-head `823617ae` asserted ancestors of
  `origin/master` `0d559d3b`) -\> `git reset --hard origin/master`;
  `git stash pop` restored the S176 stub cleanly onto master.
- **Branch cleanup (verified-merged-before-delete):** `git branch -d`
  (was `823617ae`) + `git push origin --delete` + `git fetch --prune`;
  verified NO ref remains (local 0, remote-tracking 0,
  `gh api .../branches/issue-9-s3-sire-dam-columns` -\> **404**).
- **Verification (Phase-3E):** the deliverable was re-verified on the
  merge-result tree by PR \#72’s `R CMD check` x5 matrix
  (incl. ubuntu-devel), all PASS; confirmed firsthand on `master`:
  `R/reportGV.R:132` carries `sire`/`dam`, `NEWS.md` has the GVA bullet,
  both test files present, `test_reportGV.R` passes locally on master.
  The runtime data flow (sire/dam to the table + CSV) is exercised by
  the S175 `testServer` integration test, now on master and green in CI.
  A full browser
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  smoke is the pre-existing shinytest2 baseline-noise harness, not run –
  stated, not silently skipped. **No new numbered learning** (clean
  re-execution of the documented publish convention
  133/135/146/152/155/157/157a/159/161).

### 2026-06-22 — Issue \#9 Slice 1 (S3): Sire and Dam columns in the Genetic Value Analysis report and CSV exports (Session 175)

- **Deliverable (owner pick, single item):** implement the first
  vertical slice of the issue \#9 plan
  (`docs/planning/issue9-gva-unknown-parent-ranking-plan.md`) – **S3:
  add `sire` and `dam` columns to the GVA report** so users can see
  which top-ranked animals have unknown (U-id) parents. **Code change**
  (`R/reportGV.R` + 2 test files) -\> **strict TDD**, every transition
  gated via `AskUserQuestion` (pre-RED scope/approach \[2 owner
  decisions\] -\> PRE-RED-\>RED -\> RED-\>GREEN -\> GREEN-\>REFACTOR
  \[skipped, owner-approved\]). **0 stakeholder corrections.** SOLO (a
  one-line, fully test-anchored data-flow change – a multi-agent sweep
  adds no coverage). Committed on feature branch
  `issue-9-s3-sire-dam-columns`; **UNPUBLISHED**; `master` unchanged.
- **Scope decision (owner, `AskUserQuestion`):** Slice 1 (S3) is
  independent of the §7 ratification (D1-D3 only gate Slice 2’s
  number-asserting RED, not the additive S3 columns). Owner chose
  “implement Slice 1 now; hold the full D1-D8 ratification and the D2
  `/grill-me` for the session right before Slice 2”, and mechanism “add
  sire/dam directly in `reportGV`” over broadening the exported
  [`getIncludeColumns()`](https://github.com/rmsharp/nprcgenekeepr/reference/getIncludeColumns.md).
- **Implementation (minimum, one line):** `R/reportGV.R:129`
  `demographics <- ped[probands, c(includeCols, "sire", "dam")]`
  (sire/dam guaranteed present since
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  at `:87` already consumes them). They `cbind` into `finalData`,
  survive `orderReport`/`rankSubjects` (column-preserving) into
  `report`, and propagate AUTOMATICALLY through
  `gvResults`/`geneticValues`/`gvaView` and both CSV download handlers
  because every `modGeneticValue.R` consumer passes whole data frames –
  so NO `modGeneticValue.R`, `getIncludeColumns`, or man-page change was
  needed (Learning 165).
- **Tests (RED -\> GREEN):** updated both
  `expect_named(gvReport$report, ...)` blocks in `test_reportGV.R` to
  require `sire`/`dam` after `population`; added a new `testServer`
  integration test in `test_modGeneticValue.R` asserting
  `c("sire","dam")` reach `gvResults()`, the returned `geneticValues()`,
  and `gvaView()`. 5 assertions RED for the right reason, all GREEN
  after the fix.
- **Verification:** `test_reportGV.R` 12/0/0 + `test_modGeneticValue.R`
  144/0/0; full clean regression read 0 failed / 0 error (real, excl
  `test-app-`/`test-e2e-`); build-equivalent
  `devtools::check(vignettes = FALSE)` = **0/0/0**. New learning **165**
  added to `PROJECT_LEARNINGS.md`. **NEWS** entry (user-facing new
  columns) deferred to the publish PR per Learning 157a.
- **Phase-3E:** the runtime data flow is verified at the server-reactive
  level by the new `testServer` test (real `modGeneticValueServer`
  reactives in-process) + the build-equivalent; a full browser
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  smoke of the rendered table is the pre-existing shinytest2
  baseline-noise harness, not run – stated, not silently skipped.

### 2026-06-22 — Planning doc for issue \#9 (animals missing a parent falsely top-rank in the GVA) covering all three solutions (Session 174)

- **Deliverable (owner pick, single item):** a planning document,
  `docs/planning/issue9-gva-unknown-parent-ranking-plan.md`, for GitHub
  issue \#9. **Planning session** -\> TDD code-phases inapplicable to
  the doc; each implementation slice is its own future strict-TDD
  session. **0 stakeholder corrections.** Owner chose “write a planning
  doc” covering **all three** issue solutions (S1 sex-stratified
  breeding-age mean kinship for unknown parents; S2 flag/classify
  unknown-parent animals; S3 add Sire/Dam columns) via
  `AskUserQuestion`, after I scoped the work firsthand.
- **Scoping (firsthand):** a 6-agent understanding workflow
  (`wf_e8ff66e0-7ed`) + adversarial premise-verification + a `git grep`
  blast-radius inventory mapped the GVA / mean-kinship /
  genome-uniqueness / U-id-founder subsystem. Confirmed the premise on
  real `qcPed` (top-20 ranks are 100% founders), the single choke point
  (`indivMeanKin` at `R/reportGV.R:93`), the **two rank paths** (the
  Shiny `modGeneticValue.R:204` rank overrides the library `orderReport`
  rank), and the test that hard-codes the bug
  (`test_orderReport.R:24,42`).
- **The plan:** evidence inventory with <file:line>; **8 design
  decisions** with recommendations flagged for owner ratification (§3/§7
  checklist) – the deepest (D2, the substitution algebra) is
  genetics/methodology and a `/grill-me` candidate; **3 vertical
  slices** (one session each) with completion criteria, verification
  commands, session-boundary STOPs, and here-be-dragons; recommended
  order S3 (visibility) -\> S1 (core fix) -\> S2 (classify + reconcile
  the two rank paths).
- **No production code changed** (planning deliverable). New learning
  **164** added to `PROJECT_LEARNINGS.md` (the GVA two-rank-paths /
  single-choke-point structure + the scope-before-plan reflex).
  **Phase-3E N/A** (no runtime behavior changed – a plan document).

### 2026-06-22 — Closed umbrella \#45 (parent identification via estimated conception date): all four acceptance criteria met; \#28 stays open and gated (Session 173)

- **Deliverable (owner pick, single item):** close umbrella issue \#45
  (principled parent identification in `getPotentialParents` via
  estimated conception date = birth - gestation). **Admin/docs** – a
  public GitHub close-out comment + closing the issue, no production
  code -\> **TDD N/A** (confirmed docs/admin-only before declaring). **0
  stakeholder corrections.** SOLO (a contained, serial firsthand
  verification of issue states + code – a fan-out adds no coverage over
  targeted reads). Owner chose “Close umbrella \#45” at the deliverable
  `AskUserQuestion`, then approved the exact comment text at the
  post+close gate.
- **Why closeable (verified firsthand, NOT from the umbrella body, which
  predates the sessions that completed its children):** all four
  umbrella acceptance criteria are met – (1) \#31’s dam-exclusion window
  is gestation-derived from the existing `maxGestationalPeriod`, no
  parallel parameter (`R/getPotentialParents.R:108-131`); (2) a
  regression test shows dam selection responds to `maxGestationalPeriod`
  (`tests/testthat/test_getPotentialParents.R:163`); (3) the former
  `:92-93` “hack” TODO is gone and the dam logic is principled +
  documented; (4) \#28 has a written, ratified colocation data-model
  spec recorded on the issue (S76/S77). Sub/related issues \#31 (CLOSED
  2026-06-14), \#46 (species-keyed gestation, CLOSED 2026-06-22), and
  \#48 (app wire-in, CLOSED 2026-06-16) are all done.
- **Action:** posted the evidence-backed close-out comment (issue \#45
  comment `4773497458`), then `gh issue close 45` -\> verified
  `state=CLOSED` (`closedAt 2026-06-22T22:06:29Z`). Verified the
  umbrella’s one open child **\#28 remains OPEN** – it tracks
  independently and stays gated for implementation on a concrete
  location source (#11 Oracle / \#12 ARMS).
- **Verification (Phase-3E):** N/A – no runtime behavior changed (an
  issue close-out, no code touched). The package build/runtime is
  unchanged from `master` `c7f6ea86`.

### 2026-06-22 — Published S171 (PR \#71): the `makeGrpNum()` -\> `makeGroupNum()` rename is on `master`; NEWS entry added; issue \#29 closed (Session 172)

- **Deliverable (owner pick, single item):** publish S171’s issue \#29
  rename
  ([`makeGrpNum()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGrpNum.md)
  -\>
  [`makeGroupNum()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGroupNum.md)
  with a deprecated alias) from `issue-29-rename-makegrpnum` to
  `master`. **Admin/publish + docs** (no production-code logic -\> TDD
  N/A), folding the user-facing NEWS entry into the SAME PR (Learning
  157a). **0 stakeholder corrections.** SOLO (a serial, irreversible git
  sequence – a workflow adds risk, not coverage). Owner picked option 1
  (publish), then approved the merge (merge commit) at the
  `AskUserQuestion` gate.

- **Pre-publish content (one PR, Learning 157a):** added a dev-version
  *Changes* bullet to `NEWS.Rmd` – the exported
  [`makeGrpNum()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGrpNum.md)
  is renamed to
  [`makeGroupNum()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGroupNum.md)
  for consistency with
  [`makeGroupMembers()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGroupMembers.md),
  with the old name kept as a deprecated alias that still works but
  warns. Both names backtick-wrapped (so spell_check skips them) and
  `makeGroupNum` was already in `inst/WORDLIST` (S171). Re-rendered
  `NEWS.md` (permanent `html_preview:false`+`md_extensions:"-smart"`,
  Learning 155) -\> **0 non-ASCII**, no stray `.html`, a confined
  pure-insertion diff (+6/+6, line-wrap only).
  `spell_check_package(".")` = **0 unrecognized** before and after -\>
  no WORDLIST change needed. Committed NEWS only as `d5f58d01`; kept the
  S172 1B stub OUT of the PR (stash-carried).

- **Pre-flight (Learning 133/135):** `git fetch` (`origin/master`
  unchanged at `25c8a14d`); branch **3 ahead / 0 behind** (clean FF,
  `origin/master` a strict ancestor of HEAD);
  `git merge-tree --write-tree` **0 conflict markers**; 17-file blast
  radius = S171’s rename deliverable + S171 close-out docs + the S172
  NEWS, all accounted for.

- **Publish + CI (did NOT merge blind):** pushed; opened **PR \#71** -\>
  `master` (body uses `Closes #29`); **all 10 checks PASS** – `lint`
  3m33s; `R CMD check` x5 (`macos` 6m5s / `ubuntu` release 7m3s +
  oldrel-1 7m28s + **devel 16m34s** / `windows` 9m44s); **`pkgdown`
  5m44s** (confirms the two-name `inst/_pkgdown.yml` change, S171 Gotcha
  4); `test-coverage` 4m51s; **`codecov/patch` + `codecov/project`
  PASS** (test-adding PR -\> coverage stayed green, Learning 152). The
  background `--watch` exited 0 but I re-queried FRESH with non-watch
  `gh pr checks 71` (10 `pass`, exit 0) before proceeding (Learning
  157).

- **Merge + reconcile (Learning 133/146):** `AskUserQuestion`-gated the
  irreversible merge (owner: “Yes, merge commit”); guarded fresh
  pre-merge re-check (state OPEN, MERGEABLE, CLEAN, `headRefOid` ==
  local `d5f58d01`, `origin/master` still `25c8a14d`);
  `gh pr merge 71 --merge` -\> merge commit **`ae3b8bb6`** (verified
  `state: MERGED`, `mergedBy: rmsharp` firsthand); **issue \#29
  auto-closed** by `Closes #29` (`closedAt` 21:48:51, one second after
  the merge). Reconciled local `master` via verified `git fetch` +
  ancestor-gated `reset --hard` (asserted both old-master `25c8a14d` AND
  merged-head `d5f58d01` are ancestors of `origin/master` BEFORE
  resetting); popped the S172 stub.

- **Branch cleanup (verified-merged-before-delete, S154/S157):** deleted
  `issue-29-rename-makegrpnum` local (`git branch -d`, was `d5f58d01`) +
  remote (`git push origin --delete`) + `fetch --prune`; verified **NO
  ref remains** (local + remote-tracking empty;
  `gh api .../branches/issue-29-rename-makegrpnum` -\> **404**).

- **Verification (Phase-3E):** no NEW runtime behavior introduced by
  S172 – the runtime change is S171’s rename, re-verified on the exact
  merge-result tree by PR \#71’s `R CMD check` x5 matrix
  (incl. ubuntu-devel), all PASS -\> `master` at `ae3b8bb6` builds clean
  and contains the deliverable (confirmed firsthand: `R/makeGroupNum.R`
  present, `R/makeGrpNum.R` gone, NAMESPACE exports both, NEWS entry
  present, `test_makeGroupNum.R` present). The NEWS change is docs
  (render clean, 0 non-ASCII, 0 spell delta).

- **Deliverable (owner pick, single item):** issue \#29 – rename the
  exported convenience helper
  [`makeGrpNum()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGrpNum.md)
  to
  [`makeGroupNum()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGroupNum.md)
  for naming consistency with the sibling export
  [`makeGroupMembers()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGroupMembers.md).
  **Code change** (`R/` + tests + regenerated `man/`/`NAMESPACE` +
  `inst/_pkgdown.yml`/`inst/WORDLIST`) -\> **strict TDD**, every
  transition gated via `AskUserQuestion` (pre-RED scope/approach \[2
  owner decisions\] -\> PRE-RED-\>RED -\> RED-\>GREEN -\>
  GREEN-\>REFACTOR \[skipped, owner-approved\]). **0 stakeholder
  corrections.** SOLO (a contained, fully `git grep`-inventoried,
  test-anchored rename – a multi-agent sweep adds no coverage over the
  exhaustive grep).

- **Decisions (pre-RED `AskUserQuestion` gates):** (1) **backward
  compatibility** – keep
  [`makeGrpNum()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGrpNum.md)
  as a DEPRECATED ALIAS (both exported; the old name calls
  `.Deprecated("makeGroupNum")` then delegates) over a hard rename,
  because `makeGrpNum` is public API (shipped on CRAN before the
  2025-07-29 archive) so a hard rename would break external scripts; (2)
  **deliverable shape** – implement this session via TDD (the grep
  inventory was complete and the blast radius is 8 contained code
  locations with existing coverage) over a separate plan doc; (3) **doc
  structure** (at the GREEN gate) – document the alias on its OWN man
  page (`man/makeGrpNum.Rd`, deprecation note + `@seealso`) over merging
  onto one page via `@rdname`.

- **Evidence-based inventory (`git grep`, exhaustive over tracked
  files):** 8 code locations – `R/makeGrpNum.R` (def),
  `R/fillGroupMembers.R:40` (the one real in-package caller),
  `R/fillGroupMembersWithSexRatio.R:68` (roxygen `@examples`),
  `tests/testthat/test_fillGroupMembersWithSexRatio.R:47` (test call),
  `NAMESPACE:119`, `man/makeGrpNum.Rd`,
  `man/fillGroupMembersWithSexRatio.Rd:92`, `inst/_pkgdown.yml:217`.
  Historical docs (`SESSION_NOTES.md`, `20250504_cran-comments.md`,
  `TECH_DEBT_AUDIT_*`, `docs/audits/*`) describe the past state and were
  NOT rewritten. The target name `makeGroupNum` was unused everywhere
  beforehand.

- **Change:** `git mv R/makeGrpNum.R R/makeGroupNum.R`;
  `makeGroupNum(numGp)` is the canonical function (original body
  unchanged, full roxygen, `@export`); `makeGrpNum(numGp)` is a thin
  deprecated wrapper (`.Deprecated("makeGroupNum")` then
  `makeGroupNum(numGp)`, own roxygen with `@seealso`, still `@export`).
  Switched the 3 in-package callers to the new name.
  `devtools::document()` regenerated `NAMESPACE` (now exports BOTH) +
  the three man pages (`man/makeGroupNum.Rd` new, `man/makeGrpNum.Rd`
  now the deprecation note, `man/fillGroupMembersWithSexRatio.Rd`
  example updated). `inst/_pkgdown.yml` reference index lists both
  names. `inst/WORDLIST` += `makeGroupNum` (the function name appears as
  bare prose in the alias page `\title{}`; same lever as the
  already-present `grpNum`, Learning 159).

- **Tests (RED -\> GREEN, new `tests/testthat/test_makeGroupNum.R`, 2
  blocks / 4 expectations):** `makeGroupNum(3L) == list(1L,2L,3L)` and
  `makeGroupNum(1L) == list(1L)` (RED failed: function did not exist);
  the deprecated `makeGrpNum(3L)` still returns the same list AND emits
  a deprecation warning naming `makeGroupNum` (RED failed: the old
  function did not warn). Both pass at GREEN; the existing
  `test_fillGroupMembersWithSexRatio.R` (its call switched to
  `makeGroupNum`) stays green with no deprecation-warning leak.

- **Verification:** build-equivalent
  `devtools::check(vignettes = FALSE)` (Learning 161) = **0 errors / 0
  warnings / 0 notes**; full suite **0 failed / 0 errors** (5 warnings =
  the pre-existing `test_modPyramid.R` baseline; the new deprecation
  warning is captured by `expect_warning`, confirmed by isolating
  warning sources to `test_modPyramid.R`); `lintr` **0 lints** on the
  changed files WITH the package loaded – the bare single-file
  `object_usage` “no visible global function ‘makeGroupNum’” is a
  stale-namespace artifact (a newly-added cross-file function, resolved
  once the package is installed/loaded, exactly as CI does and as the
  sibling `makeGroupMembers` already resolves;
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html) +
  re-lint -\> 0); `spell_check_package(".")` **0 unrecognized**; **0
  non-ASCII** across all changed files.

- **Committed on feature branch `issue-29-rename-makegrpnum`** (not
  `master`); the **NEWS entry** (user-facing: a renamed exported
  function with a soft-deprecated alias) is the publish session’s
  pre-publish step to fold into the same PR (Learning 157a), matching
  the implementation-\>CHANGELOG, publish-\>NEWS rhythm. Publish (PR -\>
  CI -\> owner-gated merge) is a separate session.

### 2026-06-22 — Published S169 (PR \#70): species-keyed UI gestation prefill is on `master`; NEWS entry added (Session 170)

- **Deliverable (owner pick, single item):** publish S169’s issue \#46
  **item 2b** (species-keyed UI prefill of the gestation window) from
  `issue-46-ui-prefill` to `master`. **Admin/publish + docs** (no
  production-code logic -\> TDD N/A), folding the S169-flagged NEWS
  entry into the same PR. **0 stakeholder corrections.** SOLO (a serial,
  irreversible git sequence – a workflow adds risk, not coverage). Owner
  picked option 1 (publish), then approved the merge (merge commit) at
  the `AskUserQuestion` gate.
- **Pre-publish content (one PR, Learning 157a):** a dev-version
  *Changes* bullet for the UI prefill – the Potential Parents tab’s
  “Maximum Gestational Period (days)” input now defaults from the loaded
  pedigree’s species via
  [`getSpeciesGestation()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesGestation.md),
  user-editable and preserved across pedigree reloads; phrased honestly
  to match item 2’s “no-op on shipped data” framing. Re-rendered
  `NEWS.md` (permanent `html_preview:false`+`md_extensions:"-smart"`,
  Learning 155) -\> **0 non-ASCII**, no stray `.html`, a confined
  pure-insertion diff; avoided the non-dictionary word “overridable”.
  `spell_check_package(".")` = **0 unrecognized** before and after (only
  coinages need WORDLIST, and “prefill” was already added by S169) -\>
  no WORDLIST change.
- **Build-equivalent pre-flight (-\> Learning 161):** the fast
  `R CMD check` (`--as-cran`, no-build-vignettes) returned 3 WARNINGs +
  1 NOTE, all proven NOT in the publishable git tree: the
  portable-file-names WARNING was the untracked stray
  `tests/testthat/test_species_first_class 2.R` (a macOS/cloud-sync ” 2”
  duplicate swept into `R CMD build`; isolated by moving it aside +
  re-checking, then restored as-found), the two vignette WARNINGs were
  the `--no-build-vignettes` empty-`inst/doc` artifact (CI builds
  vignettes), and the NOTE was the standing archived-on-CRAN NOTE. PR
  \#70’s clean 5-platform `R CMD check` confirmed none is a defect.
- **Pre-flight + publish (Learning 133/135):** committed NEWS only
  (`9c8e0d0f`); stash-carried the S170 stub; `git fetch` exit 0
  (`origin/master` `866da44f`); branch **3 ahead / 0 behind** (clean FF,
  ancestor-confirmed), `git merge-tree` **0 conflicts**; 10-file blast
  radius = S169 feature + S169 close-out docs + the S170 NEWS. Pushed;
  opened **PR \#70** (`Refs #46`); **all 10 checks PASS** – `lint`
  4m16s, `R CMD check` x5 (`macos` 7m0s / `ubuntu` release 7m40s +
  oldrel-1 8m3s + **devel 21m54s** / `windows` 9m26s), `pkgdown` 5m58s,
  `test-coverage` 4m55s, **`codecov/patch` + `codecov/project` PASS**
  (test-adding PR, Learning 152). The `--watch` exited 0 but I
  re-queried fresh non-watch (Learning 157).
- **Merge + reconcile (Learning 133/146):** `AskUserQuestion`-gated the
  irreversible merge (owner: “Yes, merge commit”); guarded fresh
  pre-merge re-check (MERGEABLE/CLEAN, `headRefOid` == local `9c8e0d0f`,
  `origin/master` still `866da44f`); `gh pr merge 70 --merge` -\> merge
  commit **`3446577a`** (verified `state: MERGED`, `mergedBy: rmsharp`
  firsthand); reconciled local `master` via verified `git fetch` +
  ancestor-gated `reset --hard` (asserted both old-master `866da44f` and
  merged-head `9c8e0d0f` are ancestors of `origin/master` **before**
  resetting); popped the S170 stub.
- **Branch cleanup (verified-merged-before-delete, S154/S157):** deleted
  `issue-46-ui-prefill` local (`git branch -d`, was `9c8e0d0f`) + remote
  (`git push origin --delete`) + `fetch --prune`; verified **no ref
  remains** (local + remote-tracking empty;
  `gh api .../branches/issue-46-ui-prefill` -\> **404**).
- **Verification (Phase-3E):** no NEW runtime behavior introduced by
  S170 – S169’s prefill was re-verified on the exact merge-result tree
  by PR \#70’s `R CMD check` x5 matrix (incl. ubuntu-devel), all PASS
  -\> `master` at `3446577a` builds clean and contains the deliverable.
  The NEWS change is docs (render clean, 0 non-ASCII, 0 spell delta).
  -\> Learning 161.

### 2026-06-22 — Issue \#46 item 2b: species-keyed prefill of the gestation window in the Potential Parents module (Session 169)

- **Deliverable (owner pick, single item):** issue \#46 **item 2b** –
  reactively default the gestation `numericInput` in
  `R/modPotentialParents.R` from the loaded pedigree’s species via
  [`getSpeciesGestation()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesGestation.md),
  kept user-overridable, guarding against clobbering a manual edit when
  the pedigree reactive re-fires. **Code change** (`R/` + tests) -\>
  **strict TDD**, every transition gated via `AskUserQuestion` (pre-RED
  scope/approach -\> PRE-RED-\>RED -\> RED-\>GREEN; REFACTOR skipped,
  owner-approved). **0 stakeholder corrections.** HYBRID under
  ultracode: a read-only 4-agent grounding workflow, then SOLO for the
  file-mutating TDD work.
- **Design (pre-RED `AskUserQuestion` gate, 3 owner decisions):** (1)
  **architecture** – keep the static UI `numericInput` and add a server
  `observeEvent(pedigree())` + `updateNumericInput` + override guard
  (smallest blast radius; the existing UI test stays green), over a more
  invasive server-rendered `uiOutput`; (2) **representative species** –
  the **first non-NA/non-empty** value of the pedigree’s `species`
  column (absent/all-NA -\> 210L); (3) **override guard** – a user’s
  manual edit **always wins** (a pedigree re-fire never clobbers it; a
  genuinely new pedigree re-prefills only if the user has not
  customized).
- **Testability (the load-bearing call, per Learning 158):** in
  [`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html),
  `updateNumericInput()` does NOT echo back into
  `input$maxGestationalPeriod` (no browser round-trip), so a “read the
  input after prefill” test would never see the change. Fix: factor the
  logic that matters into **pure helpers** and expose the computed
  default as a reactive – the side-effect is driven by tested logic, not
  asserted directly. And because the shipped `speciesGestation` table
  collapses every species to the 210 fallback (Learning 158),
  differentiation is proven by an **injected `gestationTable`**
  (RHESUS=210 vs TESTSP=90).
- **Change (`R/modPotentialParents.R`):** three internal `@noRd` helpers
  – `firstPedigreeSpecies(ped)` (first usable species or
  `NA_character_`; handles NULL/non-df/no-column),
  `pedigreeGestationDefault(ped, gestationTable = NULL)`
  (`= getSpeciesGestation(firstPedigreeSpecies(ped), gestationTable)`),
  and `prefillGuardAllows(current, lastAuto)` (the override-guard
  decision: TRUE when `current` is NULL/NA or equals `lastAuto`, else
  FALSE). `modPotentialParentsServer` gained a trailing
  `gestationTable = NULL` param, a `lastAutoSet <- reactiveVal(210L)`
  sentinel, a `gestationDefault` reactive (added to the returned list),
  and an `observeEvent(pedigree(), ...)` that calls `updateNumericInput`
  only when the guard allows, recording `lastAutoSet`. No loop risk: the
  observer keys on `pedigree()`, not on the input it writes. The static
  UI numericInput (value 210L) is unchanged.
- **Tests (RED -\> GREEN, 21 new blocks / 27 expectations in
  `tests/testthat/test_modPotentialParents.R`):** `firstPedigreeSpecies`
  (6: first non-NA, skips empty/whitespace, all-NA -\> NA, no column -\>
  NA, NULL/non-df -\> NA); `pedigreeGestationDefault` (7: injected-table
  TESTSP -\> 90 \[differentiation\], RHESUS -\> 210, no column -\> 210,
  all-NA -\> 210, integer length 1, bundled-table default);
  `prefillGuardAllows` (4: NULL/NA/equal -\> TRUE, differs -\> FALSE);
  `modPotentialParentsServer` via testServer (4: returned list exposes
  `gestationDefault`, `gestationDefault()` == 90 for an injected-table
  TESTSP pedigree, == 210 for a species-less pedigree, and a
  user-override + pedigree-reload scenario exercising the guard’s skip
  branch). Each failed for the right reason before GREEN; the existing
  flatten/UI/server tests stayed green throughout.
- **Verification:** full suite **2642 passed / 0 failed / 0 errors** (5
  warnings pre-existing in `test_modPyramid.R`); `lintr` **0 lints** on
  both changed files (no `object_usage` issue – the helpers are
  same-file and `getSpeciesGestation` is already installed); all changed
  files **0 non-ASCII**; `document()` regenerated `NAMESPACE` (+1
  `importFrom(shiny,updateNumericInput)`) and
  `man/modPotentialParentsServer.Rd` (both confined). The regenerated
  man page introduced one new PROSE word, “prefill”
  (`modPotentialParentsServer.Rd:34`), which `R CMD check` flagged as a
  spelling NOTE – cleared by adding “prefill” to `inst/WORDLIST` (the
  same lever S168 used for “untyped”; Learning 159), so the word ships
  with the change that introduced it. After that, fast `R CMD check`
  (`--as-cran`, no vignettes/manual) = **0 errors / 0 warnings / 0
  notes**. Phase-3E: the prefill observer’s runtime reactive path is
  exercised by the testServer suite (the observer fires,
  `updateNumericInput` runs, the guard skips on a user edit); a full
  browser E2E is the pre-existing `test-e2e-*` baseline-noise harness,
  not a clean smoke in this environment.
- **Deferred (flagged, not omitted):** the **NEWS entry** for this
  user-facing change is the **publish session’s** pre-publish step (the
  implementation-session -\> CHANGELOG, publish-session -\> NEWS
  convention, S165-\>S166 / S167-\>S168). The app still passes the (now
  species-defaulted) scalar `maxGestationalPeriod` to
  [`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md),
  so per-animal multi-species windows in the app remain a possible later
  enhancement, out of this slice’s scope.
- **Committed on feature branch `issue-46-ui-prefill`** (not `master`);
  publish (PR -\> CI -\> gated merge) is a separate owner-gated session
  per the standing convention.

### 2026-06-22 — Published S167 (PR \#69): species-keyed gestation is on `master`; NEWS entry added; pre-existing spelling NOTE cleared (Session 168)

- **Deliverable (owner pick, single item):** publish S167’s issue \#46
  **item 2** (species-keyed gestation period) from
  `issue-46-species-gestation` to `master`. **Admin/publish +
  docs/config** (no production-code logic -\> TDD N/A), folding in the
  three S167-flagged pre-publish steps so they ship in one PR. **0
  stakeholder corrections.** SOLO (a serial, irreversible git sequence –
  a workflow adds risk, not coverage). Owner picked “1 then 2”, then
  directed “if 2 deliverables, only do 1” -\> published this session;
  **item 2b UI prefill remains owner’s-pick** for a future session.
- **Pre-publish content (one PR):** (a) **NEWS entry** for the
  user-facing change – a dev-version *Changes* bullet for the
  species-keyed
  [`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
  window (phrased honestly: the shipped rhesus-only table falls back to
  210, so existing data is unchanged; the mechanism is the extensible
  part) + two *New features* bullets for the exported
  [`getSpeciesGestation()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesGestation.md)
  and the `speciesGestation` data object; re-rendered `NEWS.md` with the
  permanent `html_preview:false`+`md_extensions:"-smart"` config
  (Learning 155) -\> **0 non-ASCII**, no `.html`, a confined
  pure-insertion diff. (b) **Spelling NOTE fix:** added “untyped” (from
  S166’s NEWS prose) to `inst/WORDLIST`. **Correction:** the S167
  handoff said to also “regenerate `tests/spelling.Rout.save`”, but that
  file does not exist – `inst/WORDLIST` is the only lever (the check is
  `spelling::spell_check_test(error = FALSE)`) -\> Learning 159. (c)
  **New-word check:** `spell_check_package(".")` before/after the NEWS
  edit flagged only “untyped” (code spans are skipped, so the new
  backticked identifiers needed no entry); after the WORDLIST add -\>
  **0 unrecognized**.
- **Pre-flight (Learning 133/135):** stash-carried the S168 stub;
  `git fetch` exit 0 (`origin/master` unchanged at `cae02dde`); branch
  **3 ahead / 0 behind** (clean FF, ancestor-confirmed),
  `git merge-tree` **0 conflict markers**; 17-file blast radius = S167
  feature (R/tests/man/data/NAMESPACE) + S167 close-out docs + the S168
  NEWS/WORDLIST; deliverable symbols confirmed firsthand at HEAD
  (`export(getSpeciesGestation)`, `maxGestationalPeriod = NULL`,
  `data/speciesGestation.RData`, NEWS bullets + 0 non-ASCII).
- **Publish + CI:** committed NEWS+WORDLIST (`a89e9e2e`), pushed, opened
  **PR \#69** -\> `master`; **all 10 checks PASS** first try – `lint`
  (4m20s), `R CMD check` x5 (`macos` 6m59s / `ubuntu` release 8m6s +
  oldrel-1 8m28s + **devel 17m24s** / `windows` 10m8s), `pkgdown`
  (6m37s), `test-coverage` (4m44s), **`codecov/patch` PASS**,
  **`codecov/project` PASS** (test-adding PR -\> coverage stayed green,
  Learning 152). The `--watch` exited 0 but I re-queried fresh non-watch
  anyway (Learning 157).
- **Merge + reconcile (Learning 133/146):** `AskUserQuestion`-gated the
  irreversible merge (owner: “Yes, merge (merge commit)”); ran a fresh
  pre-merge re-check (MERGEABLE/CLEAN, `headRefOid` == local `a89e9e2e`,
  `origin/master` still `cae02dde`); `gh pr merge 69 --merge` -\> merge
  commit **`baf916cb`** (verified `state: MERGED`, `mergedBy: rmsharp`
  firsthand); reconciled local `master` via verified `git fetch` +
  ancestor-gated `reset --hard` (asserted both old-master `cae02dde` and
  merged-head `a89e9e2e` are ancestors of `origin/master` **before**
  resetting); popped the S168 stub.
- **Branch cleanup (verified-merged-before-delete, S154/S157):** deleted
  `issue-46-species-gestation` local (`git branch -d`, was `a89e9e2e`) +
  remote (`git push origin --delete`) + `fetch --prune`; verified **no
  ref remains** (local + remote-tracking empty;
  `gh api .../branches/issue-46-species-gestation` -\> **404**).
- **Verification (Phase-3E):** local fast `R CMD check` (`--as-cran`, no
  vignettes/manual) on the deliverable tree = **0 errors / 0 warnings /
  0 notes** (the spelling NOTE cleared); the full PR \#69 `R CMD check`
  x5 matrix (incl. ubuntu-devel) ran on the exact merge-result tree, all
  PASS -\> `master` at `baf916cb` builds clean and contains the
  deliverable. No Shiny/runtime startup behavior changed (UI prefill
  deferred) -\> no app launch needed. -\> Learning 159.

### 2026-06-22 — Issue \#46 item 2: species-keyed gestation period (Session 167)

- **Deliverable (owner pick, single item):** make the gestation window
  species-keyed – issue \#46 **item 2**. Replace the rhesus-specific
  scalar `maxGestationalPeriod` (210) with a per-species lookup keyed on
  the now-first-class `species` column. **Code change** (`R/` + tests +
  a new `data/` object) -\> **strict TDD**, every transition gated via
  `AskUserQuestion` (PRE-RED design -\> PRE-RED-\>RED -\> RED-\>GREEN;
  REFACTOR skipped, owner-approved). **0 stakeholder corrections.**
  Grounding was a read-only 4-agent workflow; the file-mutating TDD work
  was SOLO.
- **Design (pre-RED `AskUserQuestion` gate):** owner chose (1) an
  **exported `data/` object** for the lookup (matches the 24 existing
  data objects, not an `inst/extdata` config), (2) seed **rhesus = 210**
  with a **210 fallback** (ship the mechanism; the table is the
  extensible home), (3) make `maxGestationalPeriod` **optional** with a
  **per-focal-animal** species lookup. UI prefill was deferred to a
  follow-up slice (vertical-slice discipline – this slice is end-to-end
  for scripted use).
- **Change:** new `data/speciesGestation.RData` (built by
  `data-raw/speciesGestation.R`; one row `RHESUS` -\> 210L) documented
  in `R/data.R`; new exported
  `getSpeciesGestation(species, gestationTable = NULL, default = 210L)`
  (`R/getSpeciesGestation.R`) – vectorized, case/whitespace-insensitive
  [`match()`](https://rdrr.io/r/base/match.html), NA/unknown/empty -\>
  default 210, integer return, with
  `utils::globalVariables("speciesGestation")` to suppress the
  data-object check NOTE (precedent `modSummaryStats.R`).
  `R/getPotentialParents.R` gained `maxGestationalPeriod = NULL` +
  `gestationTable = NULL`: when `maxGestationalPeriod` is NULL it
  precomputes a per-focal-animal window vector via
  `getSpeciesGestation(pUnknown$species, gestationTable)` (no species
  column -\> all default 210) and applies `mgp <- mgpVec[i]` at the sire
  (`:69`) and dam (`:84-85`) windows; an explicit value recycles as
  before. All existing callers pass `210L` explicitly -\> unchanged
  behavior.
- **Tests (RED -\> GREEN, 13 new expectations + fixtures):**
  `tests/testthat/test_getSpeciesGestation.R` (new, 10 blocks: shipped
  rhesus-\>210, case/whitespace-insensitive, unknown/NA/““-\>default,
  vectorized, injected-table differentiation, custom default,
  `character(0)`-\>`integer(0)`, integer type);
  `tests/testthat/test_getPotentialParents.R` (+3: NULL on a
  species-less ped == explicit 210 \[back-compat\]; NULL on a
  rhesus-species ped == explicit 210; **per-animal discriminator** – a
  mixed-species RHESUS=210 vs TESTSP=90 fixture via an injected
  `gestationTable` where one shared candidate dam is excluded for the
  RHESUS focal but retained for the TESTSP focal, guarding against
  an”ignores species, one fixed window” false GREEN). Each failed for
  the right reason before GREEN.
- **Verification:** target files 23 + 27 pass; full suite **0 failed / 0
  errors** (5 warnings pre-existing in `test_modPyramid.R`); `lintr` **0
  lints** on changed files (after `devtools::install(quick=TRUE)`
  resolves the new cross-file symbols); all changed/new files **0
  non-ASCII**; `document()` regenerated `man/getSpeciesGestation.Rd`,
  `man/speciesGestation.Rd`, `man/getPotentialParents.Rd` + `NAMESPACE`
  (`export(getSpeciesGestation)`); `R CMD check` (no-vignette/-manual) =
  **0 errors / 0 warnings / 1 NOTE**. The single NOTE is **pre-existing
  and not from this session** – a spelling-wordlist gap on “untyped” in
  `NEWS.md` introduced by S166’s NEWS entry (`d2ea5919`);
  `NEWS.md`/`inst/WORDLIST`/`tests/spelling.Rout.save` are unchanged
  here and none of this session’s files contain “untyped”. -\> Learning
  158.
- **Deferred (flagged, not omitted):** (i) the **NEWS entry** for this
  user-facing change is the **publish session’s** pre-publish step (the
  S165-\>S166 convention: implementation session -\> CHANGELOG, publish
  session -\> NEWS); (ii) the **UI prefill** in `modPotentialParents.R`
  (reactively default the gestation input from the loaded pedigree’s
  species) is a separate vertical slice; (iii) the pre-existing
  **“untyped” spelling NOTE** is a tiny follow-up (add to
  `inst/WORDLIST` + regenerate `spelling.Rout.save`) – best folded into
  the publish session, which already touches `NEWS.md`.
- **Committed on feature branch `issue-46-species-gestation`** (not
  `master`; publish is a separate owner-gated session per the
  S165-\>S166 convention).

### 2026-06-22 — Published S165 (PR \#68): `species` first-class column is on `master`; full CI matrix green; user-facing NEWS entry added (Session 166)

- **Deliverable (owner pick, single item):** publish S165’s issue \#46
  item 1 (`species` as a first-class pedigree column) from
  `issue-46-species-first-class` to `master`. **Admin/publish** (no
  production-code logic → TDD N/A), with one pre-publish content
  decision: per \[\[news-vs-changelog\]\] this is a real **user-facing**
  package change, so a `NEWS.md` entry was warranted (unlike the recent
  NEWS-infra-only publishes S155/S163/S164). **0 stakeholder
  corrections.** SOLO (a serial, irreversible git sequence). Owner
  picked “publish now, item 2 next” over bundling publish + \#46 item 2
  (two workstreams → FM \#18/#25).
- **NEWS entry (owner-approved via `AskUserQuestion`):** added a bullet
  under the dev-version *Changes* subhead of `NEWS.Rmd`, re-rendered
  `NEWS.md` with the permanent `html_preview:false` +
  `md_extensions:"-smart"` config (Learning 155) — **0 non-ASCII**, no
  `NEWS.html` byproduct, the diff a confined 6-line pure insertion;
  committed on the branch as `d2ea5919` so it ships with the feature in
  one PR.
- **Pre-flight (Learning 133/135):** stash-carried the S166 1B stub so
  the branch published exactly the reviewed commits; `git fetch`
  verified (only `gh-pages` moved, `origin/master` unchanged at
  `5f4bcbe9`); branch **2 ahead / 0 behind** (clean fast-forward),
  `git merge-tree --write-tree` **0 conflict markers**;
  firsthand-confirmed the deliverable at HEAD (`getPossibleCols.R:53`
  `species` after `sex`, `qcStudbook.R:232-233`, `NEWS.md` bullet + 0
  non-ASCII, test file present). 10-file blast radius = item-1
  code/tests/man + S165 close-out docs + the S166 NEWS entry.
- **Publish + CI:** pushed the branch, opened **PR \#68** → `master`,
  watched CI — **all 10 checks PASS**: `lint` (3m49s), `R CMD check` ×5
  (`macos` release 6m46s / `ubuntu` release 7m50s + oldrel-1 6m58s +
  **devel 17m5s** / `windows` 9m3s), `pkgdown` (5m58s), `test-coverage`
  (4m58s), **`codecov/patch` PASS**, **`codecov/project` PASS** (this PR
  ADDS tests → coverage stayed green, Learning 152). **Gotcha:** the
  first `gh pr checks --watch` died mid-run on a transient HTTP 401 with
  ~half the matrix still pending; re-queried fresh and re-watched to a
  clean exit 0 before merging → Learning 157.
- **Merge + reconcile (Learning 133/146):** owner pre-authorized “merge
  once devel passes”; still ran a fresh pre-merge re-check
  (MERGEABLE/CLEAN, `headRefOid` == local `d2ea5919`, `origin/master`
  still `5f4bcbe9`), `gh pr merge 68 --merge` → merge commit
  **`0574648b`** (verified `state: MERGED`, `mergedBy: rmsharp`
  firsthand); reconciled local `master` via verified `git fetch` +
  ancestor-gated `reset --hard` (asserted both old-master `5f4bcbe9` and
  merged-head `d2ea5919` are ancestors of `origin/master` **before**
  resetting); popped the S166 stub (pre-existing `WIP on dev` stash
  untouched).
- **Branch cleanup (verified-merged-before-delete, S154/S157):** deleted
  `issue-46-species-first-class` local (`git branch -d`, merged-only
  safe form) + remote (`git push origin --delete`) + `fetch --prune`;
  verified **no ref remains** (local + remote-tracking empty;
  `gh api .../branches/issue-46-species-first-class` → **404**).
- **Verification (Phase-3E via CI):** the deliverable is
  library-function behavior (`qcStudbook`/`getPossibleCols`), exercised
  by the full `testthat` suite across the PR \#68 `R CMD check` ×5
  matrix on the exact merge-result tree, all PASS → `master` at
  `0574648b` builds clean and contains the deliverable. → Learning 157.

### 2026-06-22 — Issue \#46 item 1: `species` is now a first-class pedigree column (Session 165)

- **Deliverable (owner pick, single item):** make `species` a
  first-class column in file-based pedigree ingestion — issue \#46
  **item 1 only**. **Code change** (`R/` + tests) → **strict TDD** (RED
  → GREEN → REFACTOR, all three transitions gated via
  `AskUserQuestion`). **0 stakeholder corrections.** Grounding was a
  read-only 4-agent workflow; the file-mutating TDD work was SOLO.
- **Dependency direction corrected (owner-flagged):** the issue says
  \#46 is a **“Dependency for” \#28** → **\#28 depends on \#46**, not
  the reverse (and \#28 v1, rhesus-only, does not block on \#46).
  Grounding confirmed **\#28 has zero code** (S76 spec + S77
  ratification only — no colocation/co-housing/postnatal/location logic
  in `R/` or `tests/`), so \#46 **item 3** (species-keyed postnatal
  co-housing window, “the multi-species generalization of \#28’s
  missing-dam parameter”) is **premature groundwork for an unbuilt
  consumer → deferred**. Item 2 (species-keyed gestation) builds on item
  1 and is a separate session.
- **Why item 1 needed real work, not just retention:** a `species`
  column already *survived*
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  as a trailing, untyped `novelCol`. “First-class” means recognized in
  the column registry **and** sorted into canonical position **and**
  typed — so the discriminator the tests pin is **order + type**, not
  mere presence.
- **Change (2 production edits):** `R/getPossibleCols.R` — added
  `"species"` to the canonical vector immediately after `"sex"` (+ a
  roxygen `\item{species}`); `R/qcStudbook.R` — added
  `if (any("species" %in% cols)) sb$species <- as.character(sb$species)`
  beside the sibling optional-column conversions, so a factor `species`
  is coerced to character.
- **Tests (RED → GREEN):** updated
  `tests/testthat/test_getPossibleCols.R` (expected vector now 24 cols)
  and added `tests/testthat/test_species_first_class.R` (6 expectations:
  species in
  [`getPossibleCols()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPossibleCols.md);
  `qcStudbook` places it immediately after `sex`; a genuine novel column
  still trails it; a factor `species` is coerced to character; the
  shipped JMAC header maps `species` into the canonical set). Each
  failed for the right reason before GREEN.
- **Scoped out (deferred, evidence-based — not guessed):** speculative
  [`fixColumnNames()`](https://github.com/rmsharp/nprcgenekeepr/reference/fixColumnNames.md)
  aliases (the literal `species` header already normalizes) and the
  LabKey `mapPedColumns` species mapping (the source column name is
  unknown). Noted for follow-on.
- **Verification:** full test suite **0 failed / 0 errors**; `lintr` **0
  lints** on all changed files; all changed/new files **0 non-ASCII**;
  `document()` confined to `man/getPossibleCols.Rd`; `R CMD check`
  (no-vignette/-manual) run as the Phase-3E build-equivalent. →
  Learning 156. **Discovered (unrelated to \#46):** the shipped
  `deidentified_jmac_ped.csv` halts a full
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  run on a pre-existing “Subject(s) listed as both sire and dam”
  conflict.

### 2026-06-22 — Published S163 (PR \#67): the permanent NEWS render fix is on `master`; full CI matrix green (Session 164)

- **Deliverable (owner pick, single item):** publish S163’s permanent
  NEWS render fix (`html_preview: false` + `md_extensions: "-smart"` in
  `NEWS.Rmd`, `NEWS.md` re-rendered to pure ASCII) from
  `fix-news-render` to `master`. **Admin/publish** (no production-code
  logic → TDD N/A). **0 stakeholder corrections.** SOLO (a serial,
  irreversible git sequence — a workflow adds risk, not coverage).
- **Pre-flight (Learning 133/135):** stash-carried the S164 1B stub so
  the branch/PR published exactly S163’s reviewed commit; `git fetch`
  (verified exit 0; only `gh-pages` moved, `origin/master` unchanged at
  `509529c0`); confirmed the branch **1 ahead / 0 behind**
  `origin/master` (`509529c0` a strict ancestor → clean fast-forward),
  `git merge-tree --write-tree` **0 conflict markers**, the single
  published commit exactly S163’s `1be6a350`, its **5-file** diff
  matching S163’s documented key-files set (`NEWS.Rmd`, `NEWS.md`,
  `CHANGELOG.md`, `PROJECT_LEARNINGS.md`, `SESSION_NOTES.md` — no
  `R/`/test/`man/`/NAMESPACE/DESCRIPTION change). Firsthand-confirmed
  the deliverable at HEAD: `NEWS.md` **0 non-ASCII**, the two `NEWS.Rmd`
  knobs set, no stray `NEWS.html`.
- **Publish + CI:** pushed `fix-news-render`, opened **PR \#67** →
  `master`, watched CI via a background `gh pr checks 67 --watch` —
  **all 10 checks PASS**: `lint` (3m49s), `R CMD check` ×5 (`macos`
  release / `ubuntu` release + oldrel-1 + **devel 13m57s** / `windows`),
  `pkgdown`, `test-coverage`, **`codecov/patch` PASS**,
  **`codecov/project` PASS**. As predicted for a pure encoding/config
  change, coverage is unaffected (both codecov checks green), and the
  full-vignette CI matrix supplies the full-build confirmation that
  S163’s local `--no-build-vignettes` check deferred — **no NEWS-related
  finding anywhere**.
- **Merge + reconcile (Learning 133/146):** did NOT merge blind — fresh
  pre-merge re-check (MERGEABLE/CLEAN, `headRefOid` == local
  `1be6a350`), surfaced the irreversible merge via `AskUserQuestion`
  (owner: merge now, merge commit), `gh pr merge 67 --merge` → merge
  commit **`fdbe1158`** (verified `state: MERGED`, `mergedAt` set);
  reconciled local `master` via verified `git fetch` + ancestor-gated
  `reset --hard` (asserted `1be6a350` is an ancestor of `origin/master`
  **before** resetting); confirmed the fix on `master` (`NEWS.md` 0
  non-ASCII; `NEWS.Rmd` knobs present).
- **Branch cleanup (verified-merged-before-delete, S154/S157):** deleted
  `fix-news-render` local (`git branch -d`, merged-only safe form) +
  remote (`git push origin --delete`) + `fetch --prune`; verified **no
  ref remains** (local + remote-tracking empty;
  `gh api .../branches/fix-news-render` → **404**).
- **Verification (Phase-3E via CI):** no runtime/production code changed
  (publish only); the full PR \#67 CI matrix ran `R CMD check` ×5 +
  pkgdown + coverage on the exact merge-result tree, all PASS → `master`
  at `fdbe1158` builds clean and contains the deliverable. No new
  learning warranted — a clean application of the documented publish
  convention (Learnings 133/135/146/152).

### 2026-06-21 — Permanent NEWS render fix: `html_preview:false` + pandoc smart-off in `NEWS.Rmd`, re-rendered `NEWS.md` to pure ASCII (Session 163)

- **Deliverable (owner pick, single item):** fix the two recurring NEWS
  render traps **at the source** instead of working around them on every
  render. **Build-config/docs hygiene** — `NEWS.Rmd` is the
  `.Rbuildignore`d source (`.Rbuildignore:39`) for the shipped
  `NEWS.md`; no package R code, no tests → **TDD N/A** (confirmed in
  grounding before declaring). **0 stakeholder corrections.** SOLO (a
  small surgical config + re-render; grounding was firsthand reads + a
  throwaway-file mechanism test, not a fan-out). Committed on feature
  branch `fix-news-render` (owner pick); publish is a separate
  decision/session.
- **The two traps (both confirmed live in grounding):** (1) **Learning
  139** — `github_document` defaults to `html_preview: true`, dropping a
  top-level `NEWS.html` that `R CMD check` flags as a non-standard-file
  NOTE; the standing workaround was deleting it after every render. (2)
  **Learning 132** — pandoc’s `smart` extension turned source `--` →
  en-dash and straight quotes → curly in `NEWS.md` (**40 non-ASCII
  lines**), and a quote sitting against a word became a bogus spell/lint
  token.
- **Mechanism verified before touching anything tracked:** on throwaway
  `/tmp` Rmds (pandoc 3.1.1 / rmarkdown 2.31), `md_extensions: "-smart"`
  rendered the same input to pure ASCII and `html_preview: false`
  suppressed the `.html` byproduct — a verified plan, not a hypothesis.
- **Change (4 source edits to `NEWS.Rmd`):** set the `github_document`
  output to `html_preview: false` + `md_extensions: "-smart"`; fixed the
  2 source lines (`:189`, `:213`) carrying **literal** curly quotes
  baked into the source (a smart-off re-render alone would not touch
  those). Re-rendered `NEWS.Rmd` → `NEWS.md`.
- **Verification (content-invariance + both build-equivalents):**
  `NEWS.md` is now **0 non-ASCII** (was 40 lines); **no `NEWS.html`
  byproduct** is created; normalizing the old `NEWS.md`’s smart-bytes
  back to ASCII and diffing vs the new render left only **one benign
  soft-wrap shift** (`--as-cran` is 4 columns wider than `–as-cran`, so
  “system.” breaks one word later) — **zero content change**. The
  package build-equivalent (`R CMD build` + `R CMD check --as-cran`)
  passed with **no NEWS-related finding** (no top-level `NEWS.html`
  NOTE; full `testthat` suite OK); the 2 WARNINGs + the vignette-index
  part of the 1 NOTE are artifacts of the fast `--no-build-vignettes`
  build, and the remaining NOTE items are standing (archived-on-CRAN,
  new-submission).
- **No NEWS entry:** a NEWS infrastructure/encoding change is not a
  user-facing package change → CHANGELOG only
  (\[\[news-vs-changelog\]\]; mirrors how S139 handled the original
  render fix). **Standing gotchas 132/139 are now closed** —
  re-rendering NEWS no longer needs a manual delete/reword. → Learning
  155.

### 2026-06-21 — Documentation cross-link pass: consistent “See also” sections across the five scripting articles (Session 162)

- **Deliverable (owner pick, single item):** make the “See also”
  sections consistent across all five `vignettes/articles/*.qmd`
  scripting articles so each one points to its four siblings. **Pure
  website-only docs** (`vignettes/articles/` is `.Rbuildignore`d → **TDD
  N/A**, confirmed docs-only before declaring). **0 stakeholder
  corrections.** SOLO (file-mutating prose editing; grounding was five
  firsthand reads, not a fan-out).
- **Why one deliverable, not bundling:** the owner first asked whether
  several small carried-over items could be done together under
  1-and-done. They can — but only when they collapse into ONE coherent
  deliverable with a single definition-of-done, which the See-also items
  do (one theme, one verification) and the unrelated carryovers (NEWS
  render fix, codecov token, a feature issue) do not. So this session
  did exactly the cross-link pass and nothing else (anti-FM \#18/#25).
- **Grounding (read-only, firsthand):** built the actual FROM→TO link
  matrix before editing. It was genuinely uneven — **Forming Breeding
  Groups linked to zero siblings**; Offline Focal and Genetic Value
  linked to one each; Studbook QC and Age-Sex Pyramid linked to three.
  Two articles named siblings only as bare functions
  ([`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)/[`rankSubjects()`](https://github.com/rmsharp/nprcgenekeepr/reference/rankSubjects.md),
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md))
  rather than as the article. The established convention is **bold-title
  prose mentions, not hyperlinks** (S161 deliberately avoided crossrefs)
  — matched, not redesigned.
- **Change:** every article’s See-also now names all four siblings in
  one canonical workflow order (Studbook QC → Offline Focal → Genetic
  Value → Breeding Groups → Age-Sex Pyramid, each omitting itself), each
  bullet naming the article and its primary function, with the article’s
  own functions and
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  preserved. The most-coupled relationships keep their specific prose
  (e.g. GV↔︎Breeding, “the kinship matrix this analysis returns”).
- **Verification (the doc build-equivalent):** a grep confirmed each
  article’s See-also names exactly its four siblings (5/5); all five
  `.qmd` are pure ASCII; `quarto render` of the articles project
  produced all five HTML with the sibling links present and **zero error
  markers**; then removed the render litter (`.html`, `_files/`, the
  quarto-created `.gitignore`, `.quarto/`, plus a pre-existing empty
  `_files` litter dir) — only the `.qmd` are tracked.
- **No NEWS entry:** website-only articles get a CHANGELOG entry, not a
  NEWS line (S116 precedent + `[[news-vs-changelog]]`). → Learning 154.

### 2026-06-21 — Documented/exposed the offline focal-animal workflow as a website article (Session 161)

- **Deliverable (owner pick, single item):** make the offline
  focal-animal pedigree workflow
  ([`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md))
  discoverable for end users. The function was already **exported** with
  a full man page but covered by no vignette/article and missing from
  the pkgdown reference index — so “expose” meant documentation, not a
  code/NAMESPACE change (**TDD N/A** — pure docs). **0 stakeholder
  corrections.**
- **Grounding (read-only 4-agent sweep):** mapped (1) the app exposure —
  Input tab “Focal animals only; pedigree built from database” radio →
  the “Optional: Pedigree File (build offline; no database)” upload
  (`modInput.R:331-343`); a returned `nprcgenekeeprFileErr` surfaces as
  a “File Read Error” row; (2) the two doc systems — 4 website-only
  `.qmd` scripting articles vs 4 shipped `.Rmd` CRAN vignettes; (3) the
  exact input formats (focal-id file: first column = IDs; pedigree file
  requires `id`/`sire`/`dam`) and all six `nprcgenekeeprFileErr`
  messages; (4) the shipped example pair `focalAnimalsShortList.csv` +
  `ExamplePedigree.csv`.
- **Scope decision (pre-RED `AskUserQuestion`):** owner chose a
  **website-only Quarto article** over a new shipped CRAN vignette or a
  section in `a2interactive.Rmd`.
- **Wrote** `vignettes/articles/offline-focal-animal-workflow.qmd` — the
  5th in the scripting-article series, mirroring
  `genetic-value-analysis.qmd` (overview; the two inputs; a
  self-contained [`tempfile()`](https://rdrr.io/r/base/tempfile.html)
  example; the shipped colony pair; the fail-soft error table; the
  Shiny-app steps; Key arguments; See also; References).
  **Cross-linked** it from `studbook-quality-control.qmd`’s See also,
  and **added** `getFocalAnimalPedFromFile` to both `inst/_pkgdown.yml`
  reference lists (it was missing → `pkgdown` would warn “topic missing
  from index”).
- **Verification (the doc build-equivalent):** ran every chunk
  in-session under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)
  first — focal `"C"` → 4 rows (incl. the full-sibling collateral `D`);
  the shipped 5-ID list → a 2922×11 connected component; all six error
  messages reproduced — then `quarto render` (all 19 steps clean; HTML
  contains the outputs; the `.qmd` is pure ASCII; no unresolved `@sec-`
  ref). Removed the render litter (`.html`, `_files/`, quarto
  `.gitignore`, `.quarto/`) — only the `.qmd` is tracked.
- **No NEWS entry:** the article is website-only (`vignettes/articles/`
  is `.Rbuildignore`d), so per the Session 116 precedent and
  `[[news-vs-changelog]]` it gets this CHANGELOG entry, not a NEWS line
  — which also avoids the NEWS smart-quote/en-dash render traps. →
  Learning 153.

### 2026-06-21 — Published S159 (PR \#66): the offline focal-id warning-muffle is on `master` — and `codecov/project` PASSED, confirming the \#65 fix live (Session 160)

- **Deliverable (owner pick, single item):** publish S159’s
  warning-muffle (`muffleCannotOpenFile()` in `readFocalAnimalIds()`)
  from `quiet-focal-read-warning` to `master`. **Admin/publish** (no
  production-code logic → TDD N/A). **0 stakeholder corrections.** SOLO
  (a serial, irreversible git sequence — a workflow adds risk, not
  coverage). Owner picked “Publish S159 first” (1-and-done; documenting
  the offline focal workflow is a separate next session).
- **Pre-flight (Learning 133/135):** stash-carried the S160 1B stub so
  the branch/PR published exactly S159’s reviewed commit; `git fetch`
  (verified exit 0); confirmed the branch **1 ahead / 0 behind**
  `origin/master` (`2d1c19b1` a strict ancestor → clean fast-forward),
  `git merge-tree --write-tree` **0 conflict markers**, the single
  published commit exactly S159’s `363cf9a2`, its **8-file** diff
  matching S159’s documented key-files set (NAMESPACE / DESCRIPTION /
  the shared `muffleIncompleteFinalLine` / the online
  `getFocalAnimalPed` sibling all untouched).
- **Publish + CI:** pushed `quiet-focal-read-warning`, opened **PR
  \#66** → `master`, watched CI via a background
  `gh pr checks 66 --watch` — **all 10 checks PASS**: `lint`,
  `R CMD check` ×5 (`macos` / `ubuntu` release + oldrel-1 + **devel
  15m6s** / `windows`), `pkgdown`, `test-coverage`, **`codecov/patch`
  100% of diff**, **`codecov/project` PASS**.
- **\#65 confirmed live (the headline):** on PR \#64 (S156)
  `codecov/project` FAILED on a −0.18% dip because the two-config
  precedence bug meant the 1% threshold was not applied; S158
  consolidated to one `codecov.yml` and verified at the config layer
  (codecov `/validate` echoed `threshold: 1.0`). This PR — the first
  coverage-changing PR since — is the **live PR-level confirmation**:
  `codecov/project` now **PASSES**. The \#65 saga (S156 diagnosed → S158
  fixed → S160 confirmed) is closed end-to-end. → Learning 152.
- **Merge + reconcile (Learning 133/146):** did NOT merge blind — fresh
  pre-merge re-check (still MERGEABLE/CLEAN, `headRefOid` == local
  `363cf9a2`, no non-pass checks), surfaced the irreversible merge via
  `AskUserQuestion` (owner: merge now), `gh pr merge 66 --merge` → merge
  commit **`201217ed`** (verified `state: MERGED`, `mergedAt` set);
  reconciled local `master` via verified `git fetch` + ancestor-gated
  `reset --hard` (asserted `363cf9a2` is an ancestor of `origin/master`
  **before** resetting); confirmed `muffleCannotOpenFile` present on
  `master`.
- **Branch cleanup (verified-merged-before-delete, S154/S157):** deleted
  `quiet-focal-read-warning` local (`git branch -d`, merged-only safe
  form) + remote (`git push origin --delete`) + `fetch --prune`;
  verified **no ref remains** (local + remote-tracking empty;
  `gh api .../branches/quiet-focal-read-warning` → **404**).
- **Verification (Phase-3E via CI):** no runtime/production code changed
  (publish only); S159 firsthand-smoke-tested the feature. The full PR
  \#66 CI matrix ran `R CMD check` ×5 + pkgdown + coverage on the exact
  merge-result tree, all PASS → `master` at `201217ed` builds clean and
  contains the deliverable.

### 2026-06-21 — Quieted the benign `read.csv` “cannot open file” warning on the offline focal-id read (Session 159)

- **Deliverable (owner pick, single item):** silence the benign
  `read.csv` “cannot open file …” **warning** that leaked to the console
  on the offline focal path when the focal-id list file is
  missing/unreadable. The function already returned the correct classed
  `nprcgenekeeprFileErr`; only the deferred warning printed ahead of the
  caught error (S155 carryover, the queued 2nd item). **Strict TDD**
  (RED → GREEN → REFACTOR, all phase gates via `AskUserQuestion`). **0
  stakeholder corrections.** SOLO.
- **Root cause:** `readFocalAnimalIds()` calls
  `read.csv(fileName, ...)`; on a missing/unreadable path `read.csv`
  signals a `cannot open file` **warning** *and then* an error. The
  existing `muffleIncompleteFinalLine()` wrapper muffles only the
  “incomplete final line” warning, so the “cannot open file” warning
  deferred to the top level and printed. The error was caught by the
  `tryCatch` in
  [`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
  and turned into `nprcgenekeeprFileErr`. Only the *focal-id* read
  leaked — the pedigree read is already guarded by
  `getPedigreeSource()`’s
  [`file.exists()`](https://rdrr.io/r/base/files.html) pre-check.
- **Fix (control-flow-neutral):** added a small `@noRd` sibling muffler
  `muffleCannotOpenFile()` (a `withCallingHandlers` that
  `invokeRestart("muffleWarning")`s only on the `cannot open file`
  message) and nested it around the existing
  `muffleIncompleteFinalLine(read.csv(...))` in `readFocalAnimalIds()`.
  The accompanying error still propagates, so the caught classed error
  is unchanged; only the console warning is removed. Covers both missing
  and exists-but-unreadable files. Chose this over a
  [`file.exists()`](https://rdrr.io/r/base/files.html) pre-check, which
  would change the thrown error of a SHARED helper (also used by the
  online
  [`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md))
  and miss the unreadable case. The shared `muffleIncompleteFinalLine`
  and its 4 callers are untouched (Learning 145).
- **Tests (RED → GREEN):** added 2 tests to
  `test_getFocalAnimalPedFromFile.R` — a boundary test
  ([`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
  on a missing focal-id file emits no warning yet still returns the
  classed error) and a helper test (`readFocalAnimalIds()` still throws
  but emits no warning). RED: both failed for the right reason (warning
  leaked; function resolved — no false-pass), 0 errored (Learning 145).
  GREEN: all 13 file tests pass, and the pre-existing test 8’s
  leaked-warning count dropped 1 → 0.
- **Verification:** lint 0; full suite 1120 tests, 0 failed / 0 error;
  `devtools::check()` **0/0/0**; Phase-3E cold-call smoke (installed
  package) — a missing focal-id file is **silent** and returns
  `nprcgenekeeprFileErr`, happy path unchanged. Incidental: the standard
  `document()` step re-synced a stale `man/getFocalAnimalPedFromFile.Rd`
  (an S155-era `@return` reword never re-documented; pure text reflow,
  no semantic change). → Learning 151.

### 2026-06-21 — Consolidated the two codecov configs into one so the 1% threshold applies (issue \#65, Session 158)

- **Deliverable (owner directive, single item):** fix **issue \#65** —
  the repo had **two** root codecov configs (`codecov.yml` with the
  `status.project/patch` `threshold: 1%` block + `.codecov.yml` with no
  `status` block), so the status-less file won precedence and codecov
  fell back to its default **0%** threshold, failing `codecov/project`
  on any coverage dip (empirically: PR \#64’s −0.18% dip with a
  100%-covered patch). **Config-only** (no production-code logic → TDD
  N/A). **0 stakeholder corrections.** SOLO (trivial mechanical config
  edit — a workflow would be theater).
- **Fix:** consolidated to a **single** `codecov.yml` — folded the
  display settings from `.codecov.yml` (`round: up`, `range: 20..100`,
  `precision: 2`) into the `coverage:` block, kept the explicit
  `status.project`/`status.patch` `threshold: 1%`, added a header
  comment documenting why one file matters, and **deleted
  `.codecov.yml`** (verified committed — `58a9db26` — before `git rm`).
  Removed the now-dead `^\.codecov\.yml$` line from `.Rbuildignore`
  (complete-job; kept `^codecov\.yml$`).
- **Token preserved, flagged not removed:** `codecov.yml` carries an
  embedded upload token that is **redundant** with the workflow’s
  `secrets.CODECOV_TOKEN` (`test-coverage.yaml` authenticates the
  `codecov/codecov-action@v4` upload via the GitHub secret, not the YAML
  token). Preserved it verbatim — removing/rotating a committed
  credential is a separate owner’s-call security decision, out of scope
  for \#65 (FM \#8). Flagged for the owner.
- **Verification (config-layer, this session):** local YAML parse
  confirmed valid + **no duplicate keys** (the root cause); **codecov’s
  own validator** (`https://codecov.io/validate`, token redacted so no
  secret transmitted) returned **`Valid!`** and echoed the parsed
  `coverage.status.project.default.threshold: 1.0` +
  `patch.default.threshold: 1.0` — conclusive proof codecov now reads
  and will apply the 1% thresholds. Full PR-level confirmation (a sub-1%
  dip passing `codecov/project`) happens on the next PR with a coverage
  delta — e.g. the queued strict-TDD read.csv fix. → Learning 150.

### 2026-06-21 — renv bump 1.1.4 → 1.2.3 (caught + fixed a broken `activate.R`) and deleted the merged `richer-offline-focal-errors` branch (Session 157)

- **Deliverable (owner directive, two hygiene items):** (1) commit the
  uncommitted `renv` self-upgrade (1.1.4 → 1.2.3) the owner ran between
  sessions; (2) delete the merged branch `richer-offline-focal-errors`
  (PR \#64), local + remote. **Admin/hygiene** (no production-code logic
  → no TDD gates). **0 stakeholder corrections.** SOLO.
- **renv bump + a caught runtime regression (→ Learning 149):**
  committed `renv.lock` + `renv/activate.R`, then ran the **Phase-3E
  smoke test** (`activate.R` runs at every R startup). A fresh `Rscript`
  in the project root **failed** — `object '..md5..' not found` from
  `source("renv/activate.R")`: the regenerated `activate.R` had an
  **unsubstituted `..md5..` template placeholder** at line 6 (the
  sibling `version <- "1.2.3"` was substituted; only the md5 leaked).
  Confirmed a regression (the old 1.1.4 `activate.R` sourced cleanly
  under `--vanilla`). Regenerated via the installed renv 1.2.3
  (`renv::activate(project=getwd())` under `--vanilla` — no `.Rprofile`
  source, no restore/snapshot; only `activate.R` changed, `renv.lock`
  untouched); line 6 became a real md5 and a fresh startup loaded **renv
  1.2.3 cleanly**. The broken file lived only in a local-unpushed
  commit, so it was **`--amend`ed away** — the broken bytes never
  reached the remote. Renv commit `5d72138f`.
- **Branch deletion (verified-merged-before-delete, S154/S156
  pattern):** confirmed branch tip `cd39be9a` is a strict ancestor of
  `origin/master` (merged via PR \#64, merge commit `d2c1e5e3`); deleted
  local (`git branch -d`) + remote (`git push origin --delete`);
  `git fetch --prune`; verified **no ref remains** (local +
  remote-tracking lists empty;
  `gh api .../branches/richer-offline-focal-errors` → **404**). History
  preserved in `d2c1e5e3` on `master`.
- **Verification:** Phase-3E cold-start of R in the project root (the
  check that caught the break) now prints “renv: 1.2.3 – startup OK”; no
  package source changed. Close-out docs committed direct to `master`
  (owner-authorized bookkeeping). → Learning 149.

### 2026-06-21 — Published S155 (PR \#64): richer offline-focal error messages (`nprcgenekeeprFileErr`) now on `master` (Session 156)

- **Deliverable (owner directive, single item):** publish S155’s work
  ([`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
  returns a classed `nprcgenekeeprFileErr` naming WHY the offline focal
  read failed + the `modInput.R` dispatch) from
  `richer-offline-focal-errors` to `master`. **Admin/publish** (no
  production-code logic → no TDD gates). **0 stakeholder corrections.**
  SOLO.
- **Pre-flight (Learning 133/135):** `git stash` the S156 1B stub
  (stash-carry); `git fetch` (verified); confirmed the branch **1 ahead
  / 0 behind** `origin/master` (`791c51e4` a strict ancestor → clean
  fast-forward), `git merge-tree --write-tree` **0 conflict markers**,
  the single published commit exactly S155’s `cd39be9a`, its 11-file
  diff matching S155’s key-files set (no NAMESPACE, no stray files).
- **Publish + CI:** pushed `richer-offline-focal-errors`, opened **PR
  \#64** → `master`, watched CI via a background
  `gh pr checks 64 --watch` — **8/8 real jobs PASS** (`lint`, all 5
  `R CMD check` platforms incl. ubuntu-devel 16m25s, `pkgdown`,
  `test-coverage`) + `codecov/patch` **PASS (100% of diff hit)**.
  `codecov/project` **FAILED** on a −0.18% total-coverage dip.
- **Codecov triage:** diagnosed the red as a **config artifact** (two
  codecov configs — `codecov.yml` threshold 1% + `.codecov.yml`
  no-status — so the intended 1% is not applied; default 0%, any dip
  fails), **non-blocking** (`master` unprotected) and **advisory** (the
  coverage-generating workflow passed; `codecov/patch` 100%). Surfaced
  the merge call via `AskUserQuestion` (did not merge blind — Learning
  133); owner chose merge. Logged the config fix as its own **issue
  \#65** (not scope-crept — FM \#8).
- **Merge + reconcile:** fresh `MERGEABLE`/headRefOid re-check,
  `gh pr merge 64 --merge` → merge commit **`d2c1e5e3`** (verified
  `state: MERGED` firsthand); reconciled local `master` via a
  verified-successful `git fetch` + ancestor-gated
  `git reset --hard origin/master` (Learning 146). `master` =
  `origin/master` = `d2c1e5e3`; S155’s feature confirmed present.
- **Verification (Phase-3E via CI):** no runtime code changed (publish
  only; S155 firsthand-smoke-tested the feature). The full PR \#64 CI
  matrix ran `R CMD check` ×5 + pkgdown + test-coverage on the exact
  merge-result tree, all **PASS** → `master` builds clean and contains
  the deliverable. Close-out docs committed **direct to `master`**
  (owner-authorized bookkeeping — `AskUserQuestion`). Branch
  `richer-offline-focal-errors` left as a deletion candidate (owner’s
  call). → Learning 148.

### 2026-06-21 — Richer offline-focal error messages: `getFocalAnimalPedFromFile()` returns a classed `nprcgenekeeprFileErr` naming WHY (Session 155)

- **Deliverable (owner-picked, single item):** the app’s offline
  focal-animal file path previously fail-softed to a generic “File Read
  Error” / “Could not read the uploaded file.” — surface the SPECIFIC
  reason instead. **Strict-TDD** (RED → GREEN → REFACTOR, all three
  phase gates + a pre-RED scope/approach decision, each via
  `AskUserQuestion`). **0 stakeholder corrections.** SOLO mutation; a
  read-only 4-agent grounding sweep (run first) informed the scope/shape
  decision.
- **Scope (owner-chosen — all three failure modes found in
  grounding):** (a) the focal-id list file read — previously an
  **uncaught throw** inside `observeEvent` (the read sat outside the
  `tryCatch`); (b) pedigree-file problems (missing/NULL argument,
  not-found, wrong-column, unreadable); (c) the silent 0-row “no focal
  IDs matched” case. Error shape (owner-chosen): a **dedicated** classed
  object, NOT the shared `nprcgenekeeprErr` studbook-QC object.
- **Implementation:**
  [`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
  now wraps BOTH the focal-id read and the relatives walk; on any
  failure it returns an `nprcgenekeeprFileErr` (an internal
  constructor + a `pedigreeReadReason()` mapper that translates the
  low-level `getPedigreeSource()`
  [`stop()`](https://rdrr.io/r/base/stop.html) text into a clean
  user-facing message) instead of `NULL` / throwing / returning a 0-row
  frame. `R/modInput.R` gained an
  `inherits(built, "nprcgenekeeprFileErr")` branch (mirroring, and
  placed before, the existing `nprcgenekeeprErr` branch) that puts the
  specific `message` into the error table’s `Details` column. **No
  NAMESPACE change** (the class registers no exported methods);
  [`getEmptyErrorLst()`](https://github.com/rmsharp/nprcgenekeepr/reference/getEmptyErrorLst.md)
  deliberately untouched.
- **Verification:** RED proved each new/changed test failed for the
  right reason (function returned `NULL` / threw / 0-row; modInput
  showed the generic detail), no false-pass. GREEN →
  `test_getFocalAnimalPedFromFile.R` **27 passed**, `test_modInput.R`
  **173 passed**; the regression guard (4 unchanged function tests + 167
  other modInput tests) stayed green. `lint_package()` **0** (project
  `.lintr`); **`devtools::check()` Status OK (0/0/0)** (full testthat +
  spelling + examples incl. `--run-donttest` + vignette rebuild).
  **Phase-3E** smoke exercised the real un-mocked function across all
  seven paths (happy + six classed errors with the exact messages) and a
  `testServer` check confirmed the specific `Details` reaches the app.
  NEWS.Rmd entry updated in place + NEWS.md re-rendered (pure ASCII;
  NEWS.html byproduct removed). → Learning 147.

### 2026-06-21 — Deleted the two merged file-pedigree-source carrier branches (Session 154)

- **Deliverable (owner directive, single hygiene item):** delete
  `wire-focal-file-source` (S152, merged via PR \#63) and
  `wire-file-pedsource` (S151, merged via PR \#62), local + remote.
  **Admin/hygiene** (no production-code logic → no TDD gates). **0
  stakeholder corrections.**
- **Verified-merged-before-delete (S143/S146/S149–S152 pattern):**
  confirmed both branches (`4f362be9`, `1145d3ef`) are strict ancestors
  of `origin/master` (`43822c80`); deleted local (`git branch -d` — the
  safe merged-only form) + remote (`git push origin --delete`);
  `git fetch --prune`; verified **no ref remains** either side (local +
  remote-tracking lists empty; `gh api .../branches/<b>` → **404** for
  both). History preserved in merge commits `e1780c02`/`cb46616e` on
  `master`.
- **Net:** the S150–S152 file-pedigree-source line
  (`getPedigreeSource()` `"file"` provider →
  [`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md)
  →
  [`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md) +
  modInput offline-focal wiring) is fully landed on `master` with no
  dangling branches. Close-out docs committed direct to `master`
  (owner-authorized bookkeeping).

### 2026-06-21 — Published S152 (PR \#63): `getFocalAnimalPedFromFile()` + modInput offline-focal wiring now on `master` (Session 153)

- **Deliverable (owner directive, single item):** publish S152’s Option
  C work
  ([`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md) +
  `readFocalAnimalIds()` + the modInput `focalPedigreeFile` UI/dispatch
  — the app’s offline focal-animal path) from `wire-focal-file-source`
  to `master`. **Admin/verification** (no production-code logic → no TDD
  gates). **0 stakeholder corrections.**
- **Pre-flight (Learning 133/135):** `git fetch`; confirmed
  `wire-focal-file-source` **1 ahead / 0 behind** `origin/master`
  (`cb46616e` a strict ancestor → clean fast-forward),
  `git merge-tree --write-tree` dry-run clean (**0 conflict markers**);
  confirmed the single published commit was exactly S152’s `4f362be9`
  and the 15-file diff matched S152’s key-files list.
- **Publish:** pushed `wire-focal-file-source` (new remote tracking
  branch), opened **PR \#63** → `master`, watched CI go green via a
  background `gh pr checks 63 --watch` (**10/10**: `lint` 3m51s, all 5
  `R CMD check` platforms incl. ubuntu-devel 15m58s, `pkgdown`,
  `test-coverage`, `codecov` patch+project), a fresh re-check confirmed
  `failingChecks: 0` + `mergeStateStatus: CLEAN` + `MERGEABLE` (did not
  merge blind — Learning 133), merged (merge commit **`e1780c02`**);
  verified `state: MERGED` firsthand.
- **Reconcile + a caught silent failure (→ Learning 146):** the first
  post-merge `git fetch` hit a transient DNS error
  (`Could not resolve host`), leaving local `origin/master` STALE at
  `cb46616e`; `git reset --hard origin/master` then reset to that OLD
  commit *without erroring*. Caught it via an ancestor assertion
  (`4f362be9` reported NOT an ancestor of `origin/master` — impossible
  post-merge → stale ref); retried `git fetch` to success
  (`cb46616e..e1780c02`), re-asserted the merged commit IS now an
  ancestor, `reset --hard` → local `master` = `e1780c02`. Confirmed
  `R/getFocalAnimalPedFromFile.R` + `R/readFocalAnimalIds.R` present on
  `master`.
- **Verification (Phase-3E via CI):** no runtime code changed this
  session (publish only; S152 firsthand-smoke-tested the feature). The
  full PR \#63 CI matrix ran `R CMD check` x5 + pkgdown + test-coverage
  on the exact merge-result tree, all **PASS** → `master` at `e1780c02`
  builds clean and contains the deliverable. Close-out docs
  (`SESSION_NOTES.md`, this entry, `PROJECT_LEARNINGS.md` Learning 146)
  committed **direct to `master`** (owner-authorized via
  `AskUserQuestion` — master unprotected, docs-only). Both now-merged
  branches (`wire-focal-file-source` PR \#63, `wire-file-pedsource` PR
  \#62) left as deletion candidates (owner’s call).

### 2026-06-21 — Published S151 (PR \#62) + deleted merged `pedsource-file-provider` + wired a file pedigree source through the focal-animal app pipeline (Option C) (Session 152)

- **Deliverable (owner directive, a 3-item pairing — two admin/hygiene +
  one substantive deliverable):** (1) publish S151’s
  [`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md)
  to `master`; (2) delete the merged `pedsource-file-provider`
  branch; (3) **Option C** — wire a file pedigree source through the
  focal-animal **app pipeline** so the app’s focal path no longer
  requires LabKey. Items 1–2 = VERIFICATION/admin; item 3 =
  **strict-TDD** (RED → GREEN → REFACTOR, all three gates via
  `AskUserQuestion`, plus a pre-RED **scope** `AskUserQuestion`). **0
  stakeholder corrections.**
- **Item 1 — publish:** pushed `wire-file-pedsource`, opened **PR \#62**
  → `master`, watched CI go green (**10/10**: `lint`, all 5
  `R CMD check` platforms incl. ubuntu-devel 16m21s, `pkgdown`,
  `test-coverage`, `codecov` patch+project), confirmed
  `mergeStateStatus: CLEAN` + `MERGEABLE` (did not merge blind —
  Learning 133), merged (merge commit **`cb46616e`**). Reconciled local
  `master` via `git fetch` + strict-ancestor `reset --hard` (Learning
  135). S151’s
  [`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md)
  is now on `master`.
- **Item 2 — branch deletion:** confirmed `pedsource-file-provider`
  (local + remote, `4af5e020`, merged via PR \#61) is a strict ancestor
  of `origin/master`, deleted local (`git branch -d`) + remote
  (`git push origin --delete`); verified no ref remains either side.
  (Same hygiene S143/S146/S149/S150/S151 did.)
- **Item 3 scope (pre-RED `AskUserQuestion`, owner-chosen “Sibling +
  full app wiring”):** grounded the wiring shape via a read-only 4-agent
  sweep + firsthand reads of `getFocalAnimalPed.R`, `modInput.R`, the
  relatives family, and the test surface. Two load-bearing constraints
  decided the shape: (a) the positional 7-column rename at
  `getFocalAnimalPed.R:76` is **LabKey-shaped**, so a file pedigree
  (with its own named columns) cannot share it — favoring a separate
  function over parameterizing the existing one; (b)
  [`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md)
  errors **loudly** but the focal-ped layer is fail-soft, so a
  loud→fail-soft boundary is needed. Owner chose a clean symmetric
  sibling + full pipeline wiring over a function-only tracer or
  parameterizing the LabKey-named function. → Learning 145.
- **Item 3 implementation (branch `wire-focal-file-source`,
  strict-TDD):** **RED** — new
  `tests/testthat/test_getFocalAnimalPedFromFile.R` (7 tests:
  connected-component read from a focal-id file + pedigree file
  incl. collateral; equivalence to `getFileDirectRelatives`; a `mockery`
  delegation check with `ids`/`fileName`/`sep` threaded; fail-soft
  `NULL` on NULL/missing pedigree file, nonexistent file, and missing
  id/sire/dam columns; a `sep=";"` round-trip) plus 2 new
  `test_modInput.R`
  [`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)
  tests (offline focal-file path builds the pedigree with
  `getLkDirectRelatives` mocked to
  [`stop()`](https://rdrr.io/r/base/stop.html) to prove no EHR call; a
  bad pedigree file surfaces a “File Read Error”) all failed for the
  right reason (no `getFocalAnimalPedFromFile`; `modInput` ignored the
  pedigree-file input) with no false-pass. **GREEN** — new exported
  `R/getFocalAnimalPedFromFile(fileName, pedigreeFileName = NULL, sep = ",")`
  = read focal Ids →
  `tryCatch(getFileDirectRelatives(ids, pedigreeFileName, sep), error = NULL)`;
  `modInput` UI gains an optional `focalPedigreeFile` input and its
  focal server branch dispatches to the offline function when a pedigree
  file is supplied, else the unchanged LabKey path (a `NULL` flows to
  the existing “File Read Error” handler). **REFACTOR** — extracted the
  duplicated focal-id file read into a shared internal
  `readFocalAnimalIds()` used by both
  [`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md)
  and
  [`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
  (behavior-neutral); roxygen `@export`/@param/@return + a runnable
  example; `roxygenise` regenerated `NAMESPACE`
  (+`export(getFocalAnimalPedFromFile)`) and
  `man/getFocalAnimalPedFromFile.Rd`; NEWS.Rmd “New features” entry +
  re-rendered NEWS.md.
- **Verification:** new function file 7/7 (15 expectations);
  `test_getFocalAnimalPed.R` 62, `test_modInput.R` 168 (incl. the 2
  new); full testthat suite **0 failed / 0 error**; `lint_package()`
  **0**; **`devtools::check()` OK (0/0/0)**; Phase-3E runtime smoke
  exercised the real (un-mocked) `getFocalAnimalPedFromFile` (focal-id
  file + `ExamplePedigree` → connected component; fail-soft `NULL` paths
  fire) and confirmed the optional pedigree-file input renders in
  `modInput`. Committed on `wire-focal-file-source` (unpushed —
  publishing is the owner’s call).

### 2026-06-20 — Published S150 (PR \#61) + deleted merged `walk-unification` + wired the `"file"` provider to a first-class caller `getFileDirectRelatives()` (Session 151)

- **Deliverable (owner directive, a 3-item pairing — two admin/hygiene +
  one substantive deliverable):** (1) publish S150’s
  `getPedigreeSource()` `"file"` provider to `master`; (2) delete the
  merged `walk-unification` branch; (3) **wire the `"file"` provider to
  a production caller** (S150 left it capability-only —
  [`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
  hardcodes `"labkey"`). Items 1–2 = VERIFICATION/admin; item 3 =
  **strict-TDD** (RED → GREEN → REFACTOR, all three gates via
  `AskUserQuestion`, plus a pre-RED **scope** `AskUserQuestion`). **0
  stakeholder corrections.**
- **Item 1 — publish:** pushed `pedsource-file-provider`, opened **PR
  \#61** → `master`, watched CI go green (**10/10**: `lint`, all 5
  `R CMD check` platforms incl. ubuntu-devel 17m3s, `pkgdown`,
  `test-coverage`, `codecov` patch+project), confirmed
  `mergeStateStatus: CLEAN` + `MERGEABLE` (did not merge blind —
  Learning 133), merged (merge commit **`b8a6a5ec`**). Reconciled local
  `master` via `git fetch` + strict-ancestor `reset --hard` (Learning
  135). S150’s `"file"` provider is now on `master`.
- **Item 2 — branch deletion:** confirmed `walk-unification` (local +
  remote, both `17a3ee24`, merged via PR \#60) is a strict ancestor of
  `origin/master`, deleted local (`git branch -d`) + remote
  (`git push origin --delete`); verified no ref remains either side.
  (Same hygiene S143/S146/S149/S150 did.)
- **Item 3 scope (pre-RED `AskUserQuestion`, owner-chosen “New
  [`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md)”):**
  grounded the wiring options via a read-only 4-agent sweep + firsthand
  reads. Key findings:
  [`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
  is a thin wrapper (fetch → `getPedDirectRelatives` walk); its sole
  production consumer is
  [`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md)
  whose `fileName` is the focal-**ID list**, not a pedigree; the
  fail-soft NULL contract is LabKey-only (the `"file"` source errors
  loudly); an offline focal-subset is already composable via
  `getPedDirectRelatives(ids, getPedigree(file))`; and the research doc
  framed the `"file"` source as a test/offline-pluggability provider, so
  production wiring is new owner-directed scope. The owner chose a clean
  symmetric sibling over parameterizing the LabKey-named function (no
  naming smell, no new params on existing functions) and over the larger
  `getFocalAnimalPed`/app-pipeline wiring (deferred). → Learning 144.
- **Item 3 implementation (branch `wire-file-pedsource`, strict-TDD):**
  **RED** — new `tests/testthat/test_getFileDirectRelatives.R` (7 tests:
  full-component read from a CSV incl. collateral O2; equivalence to
  `getPedDirectRelatives` over the same file; a `mockery` delegation
  check that `getPedigreeSource(sourceType="file", fileName, sep)` then
  `getPedDirectRelatives(ids, ped, unrelatedParents)` are called with
  the right args; constrained-message errors for NULL/missing
  `fileName`, missing file, missing id/sire/dam; a `sep=";"` round-trip)
  all failed, with the error-contract regexps NOT matched by “could not
  find function” (genuine RED, no false-pass — the S148 lesson).
  **GREEN** — new exported `R/getFileDirectRelatives.R`:
  `getFileDirectRelatives(ids, fileName = NULL, sep = ",", unrelatedParents = FALSE)`
  = `getPedigreeSource(sourceType = "file", fileName, sep)` then
  `getPedDirectRelatives(ids, ped, unrelatedParents)`; no NULL guard
  (the file source errors loudly by design). **REFACTOR** — no
  structural change needed (the wrapper is already minimal, mirroring
  `getLkDirectRelatives` minus the fail-soft guard); roxygen
  `@export`/@param/@return + a runnable tempfile example; `roxygenise`
  regenerated `NAMESPACE` (+`export(getFileDirectRelatives)`) and
  `man/getFileDirectRelatives.Rd`; NEWS.Rmd “New features” entry +
  re-rendered NEWS.md.
- **Verification:** new test file 7/7 (17 expectations); full testthat
  suite **0 failed / 0 error**; `lint_package()` **0**;
  **`devtools::check()` OK (0/0/0)**; Phase-3E runtime smoke exercised
  the real (un-mocked) `getFileDirectRelatives` (reads a CSV → full
  connected component; all three loud-error paths fire). Committed on
  `wire-file-pedsource` (unpushed — publishing is the owner’s call).

### 2026-06-20 — Published S149 (PR \#60) + deleted merged `labkey-pedsource-adapter` + `getPedigreeSource()` gains a `"file"` source (LabKey research Rec \#4/#5) (Session 150)

- **Deliverable (owner directive, a 3-item pairing — two admin/hygiene +
  one substantive deliverable):** (1) publish S149’s walk-unification to
  `master`; (2) delete the merged `labkey-pedsource-adapter` branch; (3)
  **LabKey research Rec \#4/#5** — add a `"file"` provider to the
  `getPedigreeSource()` seam. Items 1–2 = VERIFICATION/admin; item 3 =
  **strict-TDD** (RED → GREEN → REFACTOR, all three gates via
  `AskUserQuestion`, plus a pre-RED **scope** `AskUserQuestion`). **0
  stakeholder corrections.**
- **Item 1 — publish:** pushed `walk-unification`, opened **PR \#60** →
  `master`, watched CI go green (**10/10**: `lint`, all 5 `R CMD check`
  platforms incl. ubuntu-devel 16m27s, `pkgdown`, `test-coverage`,
  `codecov` patch+project), confirmed `mergeStateStatus: CLEAN` (did not
  merge blind — Learning 133), merged (merge commit **`1c883d16`**).
  Reconciled local `master`; S149’s walk-unification is now on `master`.
- **Item 2 — branch deletion:** confirmed `labkey-pedsource-adapter`
  (merged via PR \#59) is a strict ancestor of `origin/master`, deleted
  local (`git branch -d`) + remote (`git push origin --delete`);
  verified no ref remains either side. (Same hygiene S143/S146 did.)
- **Item 3 scope (pre-RED `AskUserQuestion`, owner-chosen “Add ‘file’
  sourceType”):** grounded BOTH offered directions (a read-only 4-agent
  sweep + firsthand reads). The evidence was lopsided: the file provider
  is the research doc’s prioritized Rec \#4 (the walk-delegation half
  landed in S149), reuses the exported
  [`getPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedigree.md),
  and is fully offline-deterministic; server-side filtering /
  `executeSql` is **explicitly deferred** by the doc (benefit
  unmeasured; `executeSql` needs per-center dot-notation SQL), cannot be
  tested/observed without a live LabKey server, and a naive focal-id
  server filter is incompatible with the client-side connected-component
  walk (filtering to focal rows leaves nothing to traverse). → Learning
  143.
- **Item 3 implementation (branch `pedsource-file-provider`,
  strict-TDD):** **RED** — 5 new tests in `test_getPedigreeSource.R` for
  `sourceType = "file"` (CSV tempfile round-trip; constrained-message
  errors for NULL `fileName` / missing file / missing id/sire/dam; a
  `mockery` delegation + `sep`-threading check) failed on
  `match.arg`/unused-argument + message mismatch (genuine RED —
  constrained regexps, not false-passes). **GREEN** — added `"file"` to
  the `sourceType` choices + params `fileName = NULL, sep = ","`
  (defaults → backward-compatible); the `"file"` branch errors loudly on
  NULL/missing-file/missing-columns, delegates to
  `getPedigree(fileName, sep)`, returns the un-curated ped (mirrors the
  `dataframe` branch’s loud-error contract and the `labkey`/`dataframe`
  un-curated return — downstream
  [`runQcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/runQcStudbook.md)
  curates). **REFACTOR** — extracted the now-duplicated id/sire/dam
  check into a local helper (both exact messages preserved), documented
  `@param fileName`/`@param sep` + updated the <title/@return>/@param
  sourceType, NEWS.Rmd “Internal changes” entry + re-rendered NEWS.md
  (deleted the `NEWS.html` byproduct — Learning 139; pure ASCII —
  Learning 132), and whitelisted `pluggable` + `collaterals` in
  `inst/WORDLIST`.
- **Verification:** full testthat suite **0 failed / 0 error** (1979
  passed); `lint_package()` **0**; `roxygenise` made **no**
  `NAMESPACE`/`man` change (`@noRd`); **`devtools::check()` OK
  (0/0/0)**; Phase-3E runtime smoke exercised the real (un-mocked)
  `"file"` branch (reads a CSV → returns id/sire/dam; both error paths
  fire; existing `dataframe`/`bogus` branches intact). The `"file"`
  provider is a new internal capability on the seam (not yet wired to a
  production caller —
  [`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
  still uses `"labkey"`). Committed on `pedsource-file-provider`
  (unpushed — publishing is the owner’s call).

### 2026-06-20 — Published S148 (PR \#59) + deleted merged `labkey-config-defaults` + walk-unification: `getLkDirectRelatives()` now returns the full connected component (LabKey research Rec \#4) (Session 149)

- **Deliverable (owner directive, a 3-item pairing — two admin/hygiene +
  one substantive behavior-change deliverable):** (1) publish S148’s
  `getPedigreeSource` fetch-adapter to `master`; (2) delete the merged
  `labkey-config-defaults` branch; (3) **LabKey research Rec \#4
  walk-unification** — make
  [`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)’s
  pedigree walk match
  [`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)’s.
  Items 1–2 = VERIFICATION/admin; item 3 = **strict-TDD** (RED → GREEN →
  REFACTOR, all three gates via `AskUserQuestion`, plus a pre-RED
  **approach** `AskUserQuestion`). **0 stakeholder corrections.**
- **Item 1 — publish:** pushed `labkey-pedsource-adapter`, opened **PR
  \#59** → `master`, watched CI go green (**10/10**: `lint`, all 5
  `R CMD check` platforms incl. ubuntu-devel 16m7s, `pkgdown`,
  `test-coverage`, `codecov` patch+project), confirmed
  `mergeStateStatus: CLEAN` (did not merge blind — Learning 133), merged
  (merge commit **`6424509b`**). Reconciled local `master` via
  `git fetch` + strict-ancestor `reset --hard` (Learning 135). S148’s
  `getPedigreeSource` adapter is now on `master`.
- **Item 2 — branch deletion:** confirmed `labkey-config-defaults`
  (merged via PR \#58) is a strict ancestor of `origin/master`, deleted
  local (`git branch -d`) + remote (`git push origin --delete`);
  verified no ref remains either side. (Same hygiene S143/S146 did.)
- **Item 3 grounding (the load-bearing analysis):** the two walks differ
  —
  [`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
  walked a strict ancestor/descendant lineage;
  [`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)
  walks the full connected component (adds collaterals). Unifying GROWS
  the live LabKey result set (a behavior change, owner-accepted; S148’s
  Learning 141). The sole production consumer is
  [`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md)
  — a larger pedigree is more complete for kinship/GVA, not breaking;
  every other reference mocks `getLkDirectRelatives` wholesale
  (walk-agnostic). **Proof that delegate ≡ in-place:** after a
  full-component walk the trailing `addIdRecords(unrelated, …)` is a
  guaranteed no-op (the walk’s fixpoint is exactly
  `getParents(ids) ⊆ ids`, so no referenced parent is ever missing) — so
  “delegate to `getPedDirectRelatives`” and “widen the walk in-place”
  produce identical results in all cases. Owner (pre-RED approach
  `AskUserQuestion`) chose **delegate**. → Learning 142.
- **Item 3 implementation (branch `walk-unification`, strict-TDD):**
  **RED** — flipped the strict-lineage guard in
  `test_getLkDirectRelatives.R` to assert the full component for focal
  O1 (`{S1,D1,X1,O1,O2,GC1}` incl. the previously-excluded sibling O2,
  plus equivalence to
  `getPedDirectRelatives(ids="O1", ped=fixture)$id`); ran → 3 assertions
  fail (Absent: O2). **GREEN** —
  [`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
  now fetches `pedSourceDf` via `getPedigreeSource("labkey")` then
  returns
  `getPedDirectRelatives(ids, ped=pedSourceDf, unrelatedParents)`; the
  in-line strict-lineage while-loop + `addIdRecords` tail removed.
  **REFACTOR** — updated the roxygen (@return/title now describe the
  full connected component + delegation), removed the now-dead
  `getSiteInfo`/`getDemographics` test stubs, added a NEWS.Rmd “Changes”
  entry + re-rendered NEWS.md (deleted the `NEWS.html` artifact —
  Learning 139; reworded to avoid the `--`→en-dash smart-render artifact
  — Learning 132).
- **Verification:** full testthat suite **0 failed / 0 error** (1960
  passed / 167 skipped); `lint_package()` **0**; `roxygenise` changed
  only `man/getLkDirectRelatives.Rd` (no `NAMESPACE` change);
  **`devtools::check()` OK (0/0/0)**; Phase-3E runtime smoke exercised
  the real `getLkDirectRelatives` (full-component result
  incl. collateral O2, 7-column positional contract preserved, fail-soft
  NULL path intact, body delegates). Committed on `walk-unification`
  (unpushed — publishing is the owner’s call).

### 2026-06-20 — Published S147 (PR \#58) + data-source adapter on the `getPedDirectRelatives` fetch boundary (LabKey research Rec \#4/#5) (Session 148)

- **Deliverable (owner directive “Publish S147”, re-scoped via
  `AskUserQuestion` after the owner flagged that a publish is admin, not
  a true deliverable):** the S146/S147 2-item pairing — (1) publish
  S147’s Rec \#2 work to `master`; (2) **LabKey research Rec \#4/#5** —
  formalize a data-source adapter on the `getPedDirectRelatives` fetch
  boundary + a deterministic mocked integration test. Item 1 =
  VERIFICATION/admin; item 2 = **strict-TDD** (RED → GREEN → REFACTOR,
  all three gates via `AskUserQuestion`, plus pre-RED **scope** and
  **approach** `AskUserQuestion`s). **0 stakeholder corrections.**
- **Item 1 — publish:** pushed `labkey-config-defaults`, opened **PR
  \#58** → `master`, watched CI go green (**10/10**: `lint`, all 5
  `R CMD check` platforms, `pkgdown`, `test-coverage`, `codecov`
  patch+project), confirmed `mergeStateStatus: CLEAN` (did not merge
  blind — Learning 133), merged (merge commit **`1dd0c7e6`**). The Rec
  \#2 centralization is now on `master`.
- **Item 2 grounding (→ Learning 141):** the research doc’s Rec \#4 said
  to “make
  [`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
  delegate its walk to
  [`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md),”
  but reading both walks firsthand showed they are NOT equivalent —
  [`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
  walks a strict ancestor-up/descendant-down lineage (re-seeds from the
  previous generation only) while
  [`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)
  walks the full connected-component closure (re-seeds from all
  accumulated ids, pulling in collaterals). So “delegate the walk” is a
  **behavior change**, not a refactor — deferred. Owner (pre-RED scope
  `AskUserQuestion`) chose the true-refactor slice: the **fetch boundary
  only**, walk byte-identical; (approach `AskUserQuestion`) an
  **internal `@noRd`** adapter.
- **Item 2 implementation (branch `labkey-pedsource-adapter`):** new
  internal
  `getPedigreeSource(sourceType = c("labkey","dataframe"), siteInfo, ped)`
  (`R/getPedigreeSource.R`, `@noRd`) — the `labkey` source pulls via
  [`getDemographics()`](https://github.com/rmsharp/nprcgenekeepr/reference/getDemographics.md)
  in the existing `tryCatch`→NULL idiom and renames via `mapPedColumns`;
  the `dataframe` source is the offline/deterministic seam.
  [`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
  now obtains `pedSourceDf` from the adapter; its walk + `addIdRecords`
  tail are **byte-identical** (the ignored `unrelatedParents` arg
  preserved). RED-first: new `tests/testthat/test_getPedigreeSource.R`
  (6 tests) + a deterministic walk test in `test_getLkDirectRelatives.R`
  (asserts the strict-lineage id set and the EXCLUDED collateral sibling
  — the guard against silently swapping the walk; Rec \#5 satisfied).
  The selector param is `sourceType` (not `source`) to satisfy
  `undesirable_function_linter`.
- **Verification:** full testthat suite **0 failed / 0 error** (1959
  passed / 167 skipped); `lint_package()` **0**; `roxygenise` made
  **no** `NAMESPACE`/`man` change (`@noRd`; verified after also removing
  the now-unused `@import`/`@importFrom` tags from
  `getLkDirectRelatives`); **`devtools::check()` OK (0/0/0)**; Phase-3E
  runtime smoke exercised the real `getPedigreeSource` (dataframe
  passthrough; the three error branches; the `getLkDirectRelatives`
  rewiring). The Rec \#4 work is committed on `labkey-pedsource-adapter`
  (unpushed — publishing is the owner’s call).

### 2026-06-20 — Published S146 (PR \#57) + config-ized the ONPRC defaults (LabKey research Rec \#2) (Session 147)

- **Deliverable (owner directive “Publish S146; LabKey Rec \#2”, an
  owner-authorized 2-item pairing):** (1) publish S146’s
  `Rlabkey (>= 3.2.0)` floor to `master`; (2) **LabKey research Rec
  \#2** — config-ize the hardcoded ONPRC defaults in
  [`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md) +
  reconcile the example-config drift. Item 1 = VERIFICATION/admin (push
  → PR → CI → merge); item 2 = **strict-TDD** (RED → GREEN → REFACTOR,
  all three gates via `AskUserQuestion`, plus a pre-RED scope
  `AskUserQuestion`). **0 stakeholder corrections.**
- **Item 1 — publish:** pushed `rlabkey-version-floor`, opened **PR
  \#57** → `master`, watched CI go green (**11/11**: `lint`, all 5
  `R CMD check` platforms, `pkgdown`, `test-coverage`, `codecov`
  patch+project), confirmed `mergeStateStatus: CLEAN`, merged (merge
  commit **`c12cfafd`**). Reconciled local `master` via `git fetch` +
  (strict-ancestor confirmed) `reset --hard` (Learning 135). The floor
  `Rlabkey (>= 3.2.0)` is now on `master` (`DESCRIPTION:52`).
- **Item 2 scope (pre-RED `AskUserQuestion`, owner-chosen):**
  “Centralize, no behavior change” + “Document the center-specific
  form.” Firsthand grounding showed the research doc’s literal
  alternatives are wrong for this codebase: the no-config ONPRC fallback
  is **load-bearing** (it backs the Shiny app’s default launch and is
  pinned by 5 test files + examples + the `expectConfigFile = FALSE`
  contract), so “reduce the fallback to a clear error” would be a
  **breaking** change, not a quick win; and flat `dam`/`sire` is
  **correct** for SNPRC (direct columns, doc §4.3), so “align the
  example to the lookup form” would make the SNPRC example wrong. →
  Learning 140.
- **Item 2 implementation (branch `labkey-config-defaults`):** new
  internal `defaultSiteParams()` (`R/defaultSiteParams.R`, `@noRd`) is
  the single source of truth for the seven ONPRC fallback params;
  [`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)’s
  no-config branch now sources them from it, with the returned list
  **byte-identical** (names/order/values), so the app + all 5
  structure-pinning test files + examples stay green. RED-first:
  `tests/testthat/test_defaultSiteParams.R` (canonical values/names + a
  fallback-equals-source agreement test, made deterministic with
  `withr::local_envvar(HOME = tempdir)`). The example config now
  documents that `lkPedColumns` is center-specific (SNPRC flat
  `dam`/`sire` = direct columns; ONPRC `Id/parents/dam` = curated
  lookup); a characterization guard in `test_loadSiteConfig.R` pins the
  SNPRC example’s flat form.
- **Verification:** full testthat suite **0 failed / 0 error** (1943
  passed; +17 vs S144 = the new assertions); `lint_package()` **0** (the
  lone `object_usage_linter` flag on `defaultSiteParams` was the
  stale-install artifact — clean once loaded; Learning 137);
  `roxygenise` made **no** `NAMESPACE`/`man` change (`@noRd`);
  **`devtools::check()` OK (0/0/0)**; runtime smoke confirmed
  `getSiteInfo(expectConfigFile = FALSE)` returns values identical to
  the pre-change literals. (Caught + removed a stray `NEWS.html` render
  artifact that R CMD check flagged as a top-level NOTE —
  `github_document` `html_preview` byproduct; → Learning 139.)

### 2026-06-20 — Pinned `Rlabkey (>= 3.2.0)` version floor + deleted the merged `labkey-apikey-auth` branch (LabKey research Rec \#1) (Session 146)

- **Deliverable (owner directive “1 then 2”, an owner-authorized 2-item
  pairing):** (1) delete the merged-dormant `labkey-apikey-auth`
  branch; (2) **LabKey research Rec \#1** — pin an `Rlabkey` version
  floor in `DESCRIPTION`. Item 1 = VERIFICATION/admin (a ref op); item 2
  = a **config/packaging change** (owner pick “Config change, R CMD
  check” — a `DESCRIPTION` version floor has no behavioral logic to
  unit-test, so **no TDD gates**). **0 stakeholder corrections.**
- **Item 1 — branch deletion:** confirmed `labkey-apikey-auth` (local +
  remote at `6b0e892b`) was a strict ancestor of `origin/master` (fully
  merged via PR \#56), deleted local (`git branch -d`) + remote
  (`git push origin --delete`); verified no ref remains and `master`
  still carries the auth feature. (Same hygiene S143 did for
  `add-methodology`.)
- **Item 2 — `Rlabkey (>= 3.2.0)` floor (`DESCRIPTION:52`, commit
  `4fd9bd40` on branch `rlabkey-version-floor`):** the package calls
  `labkey.setDefaults(apiKey=, baseUrl=)` (S144) +
  `labkey.selectRows()`; the minimal client-correctness floor is
  **2.1.131** (apiKey landed in `Rlabkey` 2.1.130, baseUrl in 2.1.131 —
  both verified firsthand in `Rlabkey` NEWS; the S143 research doc’s
  “2.1.130” missed the `baseUrl=` arg). The owner chose the conservative
  policy floor **3.2.0** (`Rlabkey` 3.2.0 assumes LabKey Server ≥ 24.1).
- **Version research (workflow):** to resolve research-doc Open Q §8.1
  (“what LabKey version do the centers run”), mined the four vendor
  EHR-module repos (base + ONPRC + SNPRC + NIRC) via `gh api` — none
  pins a server version in-file (`ManageVersion`/centralized Gradle), so
  the signal is the highest non-SNAPSHOT `release` branch: **all four
  target LabKey 26.6** (maintained range ~19.x..26.6; corroborated by
  the newest `*-26.000-26.001.sql` dbscripts), adversarially verified
  per repo. **Caveat:** module-target ≠ deployed production version (a
  center can run older) — Open Q §8.1 remains strictly unobserved.
- **Verification:** `devtools::check()` **Status OK (0/0/0)** — full
  testthat suite + spelling + examples + `--run-donttest` + vignette
  rebuild all passed; installed `Rlabkey` 3.4.6 satisfies the floor. A
  `>=` floor removes the unversioned-dependency CRAN concern +
  guarantees the client API the code calls is present; it cannot
  constrain a too-new client against an old server (deployment matter;
  CRAN discourages upper bounds). → Learning 138. The floor change is
  committed on `rlabkey-version-floor` (unpushed — publishing is the
  owner’s call).

### 2026-06-20 — Published S143 + S144 to `master` via PR \#56 (LabKey API-key auth now green across 5 platforms) (Session 145)

- **Deliverable (owner pick “Publish S144”; publish path “PR, CI, then
  merge” via `AskUserQuestion`):** push the local `labkey-apikey-auth`
  branch (2 unpushed commits — S143 close-out `1a61dd4a` + S144 auth
  feature `6b0e892b`), open a PR to `master`, watch CI go green, merge.
  **VERIFICATION/admin phase** — no production-code change, no TDD
  gates; **0 stakeholder corrections.**
- **PR \#56 (`labkey-apikey-auth` → `master`):** pushed the branch,
  opened the PR with a scoped body. Watched all checks → **10/10 PASS**
  (`lint` 4m6s; all 5 `R CMD check` platforms — macOS / Windows / Ubuntu
  devel+oldrel+release; `pkgdown`; `test-coverage`; `codecov/patch`;
  `codecov/project`). This is the first time the S144 API-key auth
  feature is verified green across **all 5 platforms** (S144 had only a
  local single-platform `R CMD check` OK + mocked tests). Confirmed
  `mergeStateStatus: CLEAN` before merging (did not merge blind —
  Learning 133).
- **Merge + reconcile:** `gh pr merge 56 --merge` → merge commit
  **`a39e73dc`**; verified it landed (`state: MERGED`; both `6b0e892b`
  and `1a61dd4a` are ancestors of `origin/master`; `DESCRIPTION` Version
  still 2.0.0). Reconciled local `master` with `git fetch` +
  (strict-ancestor confirmed) `git reset --hard origin/master` — not
  `git pull` (Learning 135). The 3 auth files (`R/setLabKeyDefaults.R`,
  `R/getConfigApiKey.R`, `R/hasNetrc.R`) confirmed present on `master`.
- **State:** `master` (local + `origin`) at `a39e73dc`, 2.0.0. The
  feature branch `labkey-apikey-auth` is now merged & dormant (local +
  remote still exist — a deletion candidate, owner’s call, the same
  hygiene S143 did for `add-methodology`). The live LabKey-server
  handshake remains unverified-from-here (inherited from S144); CI now
  confirms build/test/lint green across 5 platforms. **No new project
  learning warranted** (executed the S142-established publish pattern
  cleanly).

### 2026-06-19 — Explicit optional LabKey API-key authentication with netrc fallback (Session 144)

- **Deliverable (owner pick from the LabKey research doc’s three
  quick-wins, Rec \#3):** add explicit optional API-key authentication
  to the `Rlabkey` data path, with a `.netrc` fallback and a clear
  fail-fast error when no credential is found. **Strict-TDD** (RED →
  GREEN → REFACTOR, all three gates via `AskUserQuestion`); **0
  stakeholder corrections.** Owner decisions (separate pre-RED
  `AskUserQuestion`): credential source = env var
  `NPRCGENEKEEPR_LABKEY_APIKEY` (precedence) then config-file `apiKey`
  token;
  [`getDemographics()`](https://github.com/rmsharp/nprcgenekeepr/reference/getDemographics.md)
  auto-configures auth (fail-fast).
- **New exported `setLabKeyDefaults(siteInfo = getSiteInfo())`**
  (`R/setLabKeyDefaults.R`): sources an API key from the env var, else
  the config `apiKey` token; if present calls
  `Rlabkey::labkey.setDefaults(apiKey=, baseUrl=)` (returns
  `method = "apiKey"`); else if a netrc file is present (`$NETRC`, then
  home `.netrc`/`_netrc`) returns `method = "netrc"`; else
  `stop("No LabKey credential found." ...)`. Plus internal
  `getConfigApiKey()` (soft optional token read — `getParamDef()` stops
  on absent, so it could not be reused) and `hasNetrc()`.
- **[`getDemographics()`](https://github.com/rmsharp/nprcgenekeepr/reference/getDemographics.md)
  now calls `setLabKeyDefaults(siteInfo)`** before
  `labkey.selectRows()`, so a missing credential fails fast with the
  clear message instead of an opaque `Rlabkey` error mid-call.
  [`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
  was deliberately **not** modified (its exact field set is asserted by
  `test_getSiteInfo.R`, and it is used across the Shiny modules) — the
  helper reads the `apiKey` token itself.
- **Tests (RED-first, off-network, deterministic):**
  `tests/testthat/test_setLabKeyDefaults.R` (7 tests / 25 assertions —
  env-var, config-token, env-over-config precedence, netrc via `$NETRC`
  and via home dir, no-credential error, empty-string-env-as-absent)
  using `mockery` (stubs only `labkey.setDefaults`) + `withr` (env
  control); added
  [`getDemographics()`](https://github.com/rmsharp/nprcgenekeepr/reference/getDemographics.md)
  wiring tests (auto-auth + error propagation) to
  `test_getDemographics.R`. All credential sources routed through a
  controlled `siteInfo` so every branch is deterministic regardless of
  the host machine’s real netrc/env.
- **Docs:** new setup guide `docs/setup/labkey-authentication.md`;
  documented the optional `apiKey` token in
  `inst/extdata/example_nprcgenekeepr_config` (comment only — **not**
  the separate Rec \#2 “move hardcoded defaults” work, which stays on
  the backlog); `NEWS.Rmd` “(development version)” entry + re-rendered
  `NEWS.md` (Learning 132 applied: error message wrapped in a code span
  to avoid the pandoc smart-quote artifact).
- **Verification:** full testthat suite 0 failed / 0 error (1926+
  passed); `lint_package()` 0 lints (the 4 transient
  `object_usage_linter` warnings were stale-install artifacts — clean
  once the package is loaded/installed, and CI installs `local::.`
  before linting); `spell_check_package()` 0 flags; `R CMD check` Status
  OK. The live-server auth path itself is not verifiable from here (no
  server access); the branch logic is fully covered by the mocked tests.
  → Learning 137.

### 2026-06-19 — Deleted the dormant `add-methodology` branch + LabKey integration research (one cited document, with a recommendation) (Session 143)

- **Deliverable (owner directive, 2-item pairing in one message):** (1)
  delete the fully-merged, dormant `add-methodology` branch; (2) a
  RESEARCH_DOCUMENTATION pass on the `BACKLOG.md` “Research LabKey
  integration options” item. **VERIFICATION/RESEARCH phase** — no
  production-code change, no TDD gates; 0 stakeholder corrections. Noted
  as a “1 and done” exception (owner-authorized; research is the
  substantive deliverable).
- **Item 1 — branch deletion:** confirmed `add-methodology` was a strict
  ancestor of `origin/master` (fully merged via PR \#55 / merge
  `f44a5322`), then deleted local (`git branch -d`) + remote
  (`git push origin --delete`); verified no ref remains and `master`
  still carries the work (lint fix `507de407` in history).
- **Item 2 — LabKey research →
  `docs/research/labkey-integration-options-2026-06-19.md`:** produced
  via a multi-agent workflow (5 parallel investigators — Rlabkey/CRAN,
  base `LabKey/ehrModules`, ONPRC, SNPRC/NIRC, architecture — →
  adversarial per-claim verification → synthesis), then finalized +
  firsthand-verified by the author. **37 load-bearing claims: 33
  confirmed, 3 refuted (corrected inline), 1 uncertain.** Owner supplied
  the four EHR-module repos as primary sources.
- **Key findings:** the entire integration is ONE
  [`Rlabkey::labkey.selectRows()`](https://rdrr.io/pkg/Rlabkey/man/labkey.selectRows.html)
  pull of `study.demographics` + a pure-R client-side pedigree walk.
  `Rlabkey` is vendor-maintained (LabKey Corp) and CRAN-clean (3.4.6,
  2026-02-21, 13/13 platforms) and every option nprcgenekeepr uses is
  current/non-deprecated. The real risks are (a) the **unversioned
  `Rlabkey` dependency** vs `Rlabkey` 3.x’s ratcheting LabKey-**server**
  floor (3.4.1 needs server ≥ 24.12); (b) **no documented/tested
  credential strategy** — it relies on `Rlabkey`’s default
  `.netrc`/API-key resolution (the example config explicitly requires a
  `.netrc`); (c) **silent cross-center schema divergence** (ONPRC
  curates genetic-preferred parentage via an overridden
  `study.demographicsParents.sql`; SNPRC/NIRC collapse method to
  `'Observed'`; gender encoding and `lastDayAtCenter` provenance
  differ). `Id/parents/dam`/`sire` resolve through a base
  `DefaultEHRCustomizer` → `study.demographicsParents` lookup (NOT
  `study.parents` and NOT `ParentsDemographicsProvider`).
- **Recommendation:** do **NOT** rewrite onto a direct REST/`httr2`
  client; make four low-risk changes (pin `Rlabkey`; config-ize the
  hardcoded ONPRC defaults; explicit optional API-key auth; formalize a
  data-source adapter on the existing `getPedDirectRelatives` seam)
  before CRAN re-submission, and defer server-side query optimization
  until pull size is measured. → Learning 136; follow-up tracked in
  `BACKLOG.md`.

### 2026-06-19 — Branch reconciliation: pushed S141, merged PR \#55 (lint fix → `master`, `lint` now GREEN), switched the working line to `master` (Session 142)

- **Deliverable (owner directive “work on 1, 2, and 3”):** (1) push
  S141’s 2 local commits, (2) get `lint` green on `master`, (3) settle
  the branch-strategy decision. **VERIFICATION/admin phase** — git
  operations + a PR, no production-code change; 0 stakeholder
  corrections. Owner picked branch plan **“Merge now, switch to
  master”** via `AskUserQuestion` (the one owner decision, posed before
  any merge).
- **Item 1 — push:** verified branch state firsthand (Learning 129) then
  pushed `add-methodology` (`fb91e739..7016c376`); re-verified `0/0` vs
  origin.
- **Item 2 — lint green on master (did not merge blind, Learning 133):**
  opened **PR \#55** (`add-methodology`→`master`); watched all checks →
  **11/11 PASS**, crucially **`lint` PASS** (4m28s) +
  `mergeStateStatus: CLEAN` (vs PR \#54’s UNSTABLE) — the S141 fix
  verified green end-to-end (the `lint` workflow runs only on a PR /
  push-to-master, so a PR was the only way to see it pass). Merged with
  a merge commit → **`f44a5322`**; verified it landed (`state: MERGED`;
  `merge-base --is-ancestor 507de407 origin/master` = YES; master still
  `Version: 2.0.0`).
- **Item 3 — switch to master (recovered a stale-branch trap → Learning
  135):** local `master` was 215 commits stale and `git pull` choked
  (`pull.rebase=true` + the standing `.DS_Store` change); after
  confirming local master was a strict ancestor of `origin/master`,
  `git reset --hard origin/master` (ff-equivalent, no local commits to
  lose) → at `f44a5322`, lint fix present, clean tree. `add-methodology`
  is now merged & dormant (NOT deleted).
- **Backlog (owner mid-session add):** added a **LabKey integration
  research** item to `BACKLOG.md` “Up Next” (literal “backlog” → the
  file; no unrequested public issue filed).

### 2026-06-19 — Lint cleanup → green CI: cleared all 57 `lintr` warnings + the `cyclocomp` config wart (behavior-neutral REFACTOR) (Session 141)

- **Deliverable (owner pick):** make the `lint` GitHub Actions check
  pass — the state Learning 133 flagged as RED on `master`. **Strict-TDD
  REFACTOR**, behavior-neutral; phase-gate `AskUserQuestion` posed
  before any edit, plus a separate scope `AskUserQuestion` for three
  owner decisions. **0 stakeholder corrections.** A firsthand
  `lint_package()` found **57** lints (the CI log’s “~30” undercounted)
  across 33 files.
- **Owner decisions:** (1) `coalesce_linter` (11) — **disable in
  `.lintr`** (`%||%` needs R ≥ 4.4 but the package
  `Depends: R (>= 4.1.0)` and shiny 1.13 dropped its export; consistent
  with the 7 linters `.lintr` already disables); (2) `data-raw` (5) —
  **fix** ([`file.path()`](https://rdrr.io/r/base/file.path.html) +
  wrap); (3) **continue on `add-methodology`**.
- **Fixes (46 code lints across 28 files):** 31 `return_linter` (drop
  terminal [`return()`](https://rdrr.io/r/base/function.html),
  restructure terminal `if/else` branches), 6 `seq_along`, 5
  [`file.path()`](https://rdrr.io/r/base/file.path.html) (1 in
  `R/modPedigree.R`\* + 4 in `data-raw/`), 2 line wraps (`R/data.R`
  roxygen + `data-raw/`), 2 `sum(...)==0L` → `!any(...)`. Applied via a
  fix→adversarial-review workflow (one fixer + one independent
  behavior-neutrality reviewer per file), then centrally re-verified.
  \*`modPedigree`: the flagged string is a **MIME type**, not a path
  (the author had already `# nolint`-ed the adjacent line) — kept the
  readable string + extended the `# nolint` rather than wrapping a MIME
  type in [`file.path()`](https://rdrr.io/r/base/file.path.html).
- **Cascade caught by the central re-lint (→ Learning 134):** the
  `boolean_arithmetic` autofix in `removeDuplicates.R` cleared its
  target but triggered `if_not_else` + `any_duplicated` +
  `unnecessary_nesting`; rewrote to `anyDuplicated(x) > 0L` + a guard
  clause (behavior-identical) → 0.
- **cyclocomp wart:** added `any::cyclocomp` to
  `.github/workflows/lint.yaml` (the `.lintr` already NULLs the linter;
  `linters_with_tags()` warns at config-load when the package is absent
  — non-fatal, but silenced for a clean log).
- **`man/` regenerated** for the one roxygen line wrap (roxygen2 ==
  pinned 8.0.0; diff confined to `man/rhesusPedigree.Rd`).
- **Verified:** `lintr::lint_package()` = **0** (was 57); full test
  suite **0 failed / 0 error**; `R CMD check`
  (`--no-manual --ignore-vignettes`) **Status: OK** (0/0/0); entire
  `git diff` read firsthand. **Committed on `add-methodology`; `lint`
  will go green when CI next runs on a PR (push to `add-methodology`
  alone does not trigger the workflow).**

### 2026-06-19 — Merged PR \#54: the 2.0.0 release reached `master` (owner directive “merge \#54”) (Session 140)

- **Deliverable (owner directive):** merge PR \#54 (`add-methodology` →
  `master`). **Pre-merge triage (→ Learning 133):** PR MERGEABLE (no
  conflicts); all R-CMD-check platforms (macOS / Windows / Ubuntu
  devel+oldrel+release) + test-coverage + codecov + pkgdown PASS; the
  lone red check is the **non-required** `lint`
  (`mergeStateStatus: UNSTABLE`, not BLOCKED) — ~30 pre-existing `lintr`
  style warnings in core files + a `cyclocomp` CI config wart, none
  introduced by S139 (docs only). Surfaced the finding, then merged per
  the explicit directive.
- **Result:** merge commit `46dfc766`; `origin/master` is now
  `Version: 2.0.0` (was `1.1.0.9000`). Verified firsthand
  (`git show origin/master:DESCRIPTION`;
  `git merge-base --is-ancestor e7e41700 origin/master` = YES). Used a
  merge commit (preserves the 22-commit session history); branch **not**
  deleted.
- **Still owner-gated:** CRAN Phase 5 (win-builder / R-hub /
  `submit_cran()`). **New known state:** `lint` is RED on `master`
  (pre-existing style debt) — a future REFACTOR session could clear it
  to green. **Branch note:** `add-methodology` is now behind `master` by
  the merge commit — the owner decides whether development continues on
  `add-methodology` (re-sync with master) or moves to `master` / feature
  branches.

### 2026-06-19 — Cleared S138’s punch-list (owner directive “perform S138’s next steps”): NEWS `names'` spell flag fixed at source, README citation de-duplicated, CRAN plan §9 Phase-3 reconciled, PR \#54 opened (Session 139)

- **Deliverable (owner directive):** clear the remaining items on S138’s
  suggested-next menu in one batched session. The owner explicitly
  overrode the usual “1 and done” to do the whole punch-list; executed
  in a safe order with verification between items. **VERIFICATION/docs
  phase** — no production logic; no RED→GREEN→REFACTOR transition. Issue
  \#53 was already CLOSED by the owner earlier today, so no action
  there.
- **NEWS `names'` spell flag — fixed at source, not whitelisted (→
  Learning 132):** the flag was a *render* artifact, not a source typo.
  `NEWS.Rmd` already used straight quotes, but pandoc smart-quotes
  curled `'row.names'` → `‘row.names’` on render, producing the bogus
  `names’` token. Wrapped the literal base-R message in backticks in
  `NEWS.Rmd` (code spans bypass smart-quotes; also reads as the verbatim
  message) and re-rendered `NEWS.md` (github_document,
  `html_preview=FALSE`) → single-line diff.
  [`spelling::spell_check_package()`](https://docs.ropensci.org/spelling//reference/spell_check_package.html)
  now **0 flags** (was 1).
- **README de-dup:** the Vinson/Raboin “For more information” citation
  rendered **twice** — once from the shared child
  `vignettes/manual_components/_introduction.Rmd` (also used by
  `a3manual.Rmd` + `ColonyManagerTutorial.Rmd`) and once from
  README.Rmd’s own hardcoded block. Removed **only README.Rmd’s block**
  (README-only blast radius; the manual/tutorial vignettes untouched)
  and re-rendered via `devtools::build_readme()`. Citation now appears
  once (Introduction); diff = removed block + an incidental, correct
  version-date refresh (`2026-06-17` → `2026-06-19`). Carried S132→S138
  as FM \#8.
- **CRAN plan §9 Phase-3 reconcile:** marked
  `docs/planning/cran-2.0.0-submission-plan.md` §9 row 3 ✅ and added a
  Phase-3 STATUS block — verified firsthand that DESCRIPTION / README.md
  / CITATION.cff are all at 2.0.0, NEWS re-renders, and version-tests
  are green (S138 0/0).
- **PR \#54 opened:** `add-methodology` → `master` (master was still
  `1.1.0.9000` with none of the 2.0.0 work; 22 commits, 50 files).
  <https://github.com/rmsharp/nprcgenekeepr/pull/54> — **opened, not
  merged** (merge timing is the owner’s call; CRAN Phase 5 remains
  owner-gated).

### 2026-06-19 — `si.re` example-data defect FIXED (owner pick: option 2, the real fix for issue \#53): renamed the malformed sire column to `sire.id` across 6 datasets under strict TDD; removed S137’s `si` whitelist (Session 138)

- **Deliverable (owner pick — option 2 / the real fix for issue \#53):**
  rename the malformed sire column (`si.re` period ×5, `si re` space in
  `pedOne`) to **`sire.id`** across all 6 example pedigree datasets,
  sweep the dependent source/docs, and remove the now-unneeded `si`
  `inst/WORDLIST` whitelist S137 added. **Supersedes S137’s deferral** —
  the owner chose to do the real fix now rather than ship the typo.
  **Strict TDD**, full RED→GREEN→REFACTOR with phase gates (one
  `AskUserQuestion` per transition).
- **Target name `sire.id` (owner-chosen):** a period in a column name is
  a realistic “inexperienced data provider” messy header, so the fix
  *keeps* a period-bearing header under test rather than removing it —
  but in a sensible place that tokenizes to real words (`sire`+`id`) so
  it no longer spell-flags. `fixColumnNames("sire.id")` → `sire`
  (verified); it exercises *more* normalization than `si.re` did
  (periodRemoved + sireIdToSire vs periodRemoved only).
- **RED:** new `tests/testthat/test_exampleData_columnNames.R` — a
  data-contract test pinning all 6 datasets’ exact column names to
  include `sire.id` (+ a normalization-invariant guard). Failed as
  expected (names held `si.re`/`si re`).
- **GREEN:** regenerated the 6 `.RData` (load → rename the column →
  re-save gzip, **values byte-identical**, verified via
  [`identical()`](https://rdrr.io/r/base/identical.html)); updated
  `R/createPedOne.R:17` (`` `si re` `` → `sire.id`). 18/18 assertions
  green.
- **REFACTOR:** `si.re` → `sire.id` in the 5 `R/data.R` roxygen blocks →
  `devtools::document()` regenerated exactly the 5 `man/*.Rd` (NAMESPACE
  untouched); removed the `si` line from `inst/WORDLIST` (no longer
  needed — `si.re` is gone from the docs); updated the website-only
  vignette prose (`vignettes/articles/studbook-quality-control.qmd`);
  its executed change-log output regenerates at site build (the quarto
  freeze cache is git-ignored, `.gitignore:40`).
- **Necessitated test update:** `test_summary.nprcgenekeeprErr.R`
  asserted the summary change-log has 9 newlines; `sire.id` adds the
  `sireIdToSire` line, so it is now 10 (`9L` → `10L`, with a clarifying
  comment). Caught by the full-suite VERIFY — the pre-flight grep scan
  missed it because it asserts on output *shape*, not the literal name
  (→ Learning 131).
- **VERIFY:** full clean-regression read **0 failed / 0 error** (866
  blocks, incl. the app/e2e baseline); **`R CMD check` Status: OK** (0
  errors / 0 warnings / 0 notes); `spell_check_package()` now flags only
  the unrelated `names’` (`NEWS.md:51`). Package installs + loads with
  the new data.
- **Issue \#53** can now be closed (the defect is fixed).
  **PROJECT_LEARNINGS.md:** Learning 131 (a data/fixture change can
  break output-SHAPE assertions without referencing the changed value;
  the full suite — not a token grep — is the real breakage check).
  \[\[consult-project-source-of-truth\]\]

### 2026-06-19 — `si.re` example-data defect: filed issue \#53, then (owner decision) cleared the spell-check flag the least-disruptive way by whitelisting `si` in `inst/WORDLIST` — data regeneration deferred as low-priority (owner pick F) (Session 137)

- **Deliverable (owner pick F):** investigate the `si.re`
  example-dataset defect, file a precise evidence-based GitHub issue,
  and — per the owner’s mid-session decision — resolve the immediate
  (developer-facing) spell-check flag with the **least-disruptive**
  change rather than the heavy data regeneration. **Audit/verification
  phase** (no RED→GREEN→REFACTOR; **no
  `R/`/`man/`/`data/`/`tests/`/`NEWS` change** — the only
  shipped-content edit is **one line added to `inst/WORDLIST`**, a
  gate-invariant dictionary file consumed only by the
  `error=FALSE`+`skip_on_cran` `tests/spelling.R`; `R CMD check` never
  reads it). Filed as **issue \#53** (`bug` + `low priority`):
  <https://github.com/rmsharp/nprcgenekeepr/issues/53>
- **Resolution (owner’s call):** added `si` to `inst/WORDLIST` (C-locale
  position, between `sexRatioWithAddions` and `simParent`).
  [`spelling::spell_check_package()`](https://docs.ropensci.org/spelling//reference/spell_check_package.html)
  before = 2 flags (`si` in 5 `man/*.Rd`, plus an unrelated `names’`
  curly-apostrophe in `NEWS.md:51`); after = `si` cleared, only the
  pre-existing `names’` remains (left untouched — separate item; the
  real fix there is the NEWS curly-quote, not a whitelist). This
  **silences** the spell-check symptom while leaving the malformed names
  in the shipped data; the underlying naming inconsistency is now
  tracked by **issue \#53** (low priority). It deliberately reverses
  S134’s “leave `si` flagged to keep the defect visible” — appropriate
  now that \#53 captures it.
- **The defect, verified firsthand (corrects the inherited “5 of 6”
  note):** **6** example datasets carry a malformed sire column —
  `pedGood`, `pedDuplicateIds`, `pedFemaleSireMaleDam`,
  `pedMissingBirth`, `pedSameMaleIsSireAndDam` use `si.re` (a period
  inside `sire`), and **`pedOne` uses `si re` (a space)** — the prior
  note missed `pedOne`. The malformed name appears in the source tree
  **only** in `R/data.R` roxygen + the generated `man/*.Rd` + one
  website-only vignette; nowhere in `R/` logic or `tests/`.
- **Not a CRAN blocker, not functionally broken.** Empirically
  ([`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
  [`fixColumnNames()`](https://github.com/rmsharp/nprcgenekeepr/reference/fixColumnNames.md)):
  `si.re`, `si re`, `sire_id`, `Sire_ID`, `Sire Id`, `sire` **all
  normalize to canonical `sire`**, and
  `ego_id, si.re, dam_id, sex, birth_date` →
  `id, sire, dam, sex, birth`.
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  (`R/qcStudbook.R:174`) normalizes at ingestion, so the column is valid
  downstream. The real defect is **internal inconsistency**: the repo
  already ships two messy-sire conventions — `si re` (space, in
  `createPedOne` + ~8 local fixtures) and `Sire_ID` (underscore, the
  `fixColumnNames` `@example`) — and the five `.RData` files use a
  *third* spelling (`si.re`, period) matching neither.
- **Issue contents:** affected-dataset table, the not-broken evidence, a
  full blast-radius inventory (shipped `.RData` + `R/data.R`/`man/`; the
  website-only `vignettes/articles/studbook-quality-control.qmd` labeled
  `.Rbuildignore`’d; verify-only tests that auto-follow the shipped
  names), the **maintainer decisions** the fix needs (target name
  `si re`/`sire_id`/`sire`, `pedOne` uniformity, whether to author the
  missing `data-raw/` generator for the five), and a RED-first fix
  approach for the next session.
- **Adversarial verification + firsthand cross-check:** ran a 4-reader →
  synthesize → adversarial-verify workflow, then re-verified the
  adversary’s own corrections against the files — caught that the
  skeptic’s cited evidence (`R/fixColumnNames.R:16` `@example`) actually
  uses `Sire_ID`, the opposite of its claim; both proposer and adversary
  were partly wrong, so the issue **frames the target-name choice for
  the owner** rather than asserting one. (→ Learning 130.)
- **PROJECT_LEARNINGS.md:** Learning 130 added (cross-check a verify
  pass’s own corrections firsthand; frame contested decisions for the
  owner; re-derive inherited counts).
  \[\[consult-project-source-of-truth\]\]
  \[\[check-process-history-before-rerunning-work\]\]

### 2026-06-18 — CRAN Phase 5 local prep (owner pick Phase5-finish, scope “prep + hand off”): verified the R-hub push prerequisite is already satisfied, rebuilt/verified the final tarball, tightened the runbook (Session 136)

- **Deliverable (owner pick Phase5-finish, scope “prep + hand off”):**
  the Claude-doable prerequisites for the CRAN plan’s **Phase 5**, plus
  a tightened owner runbook. **Verification phase** (no new
  code/behavior). The outward-facing win-builder/R-hub triggers + the
  final `submit_cran()` remain the owner’s (need the owner’s GitHub
  PAT + email; SAFEGUARDS + plan decision \#3). Scoped to
  **`docs/planning/cran-2.0.0-phase5-runbook.md`** +
  **`docs/planning/cran-2.0.0-submission-plan.md`** +
  CHANGELOG/learnings/notes; **no
  `R/`/`man/`/`NAMESPACE`/`DESCRIPTION`/`tests/`/`data/`/`NEWS`/`cran-comments.md`
  change.**
- **Resolved a branch-state contradiction → the push prerequisite is
  already done.** Orientation `git status` said “up to date with
  origin/add-methodology”, which contradicted S135’s “2 commits behind —
  push before R-hub.” A `git fetch` +
  `git rev-list --left-right --count origin/add-methodology...HEAD` →
  **`0 / 0`**: `origin/add-methodology` is **fully in sync** with local
  HEAD `24175785`, so the remote already carries S133’s `withr` fix
  (`b93a5b4c`) + S134 (`56b66ae0`) + S135 (`24175785`). The branch was
  pushed after S135’s handoff was written; **no `git push` is needed**
  before `rhub_check()`. (`origin/master` is still `1.1.0.9000`,
  unchanged.)
- **Rebuilt + verified the final tarball:** `R CMD build .` → **clean**
  `nprcgenekeepr_2.0.0.tar.gz` (1.9 MB; vignettes created OK; no
  errors/warnings) on macOS R 4.6.0. The code/data/metadata tree is
  **unchanged since the S134 gate**
  (`git diff --name-only 56b66ae0..HEAD` = docs only), so that gate’s
  `0 errors | 0 warnings | 2 notes` still applies. Artifact removed, not
  committed.
- **Re-confirmed every cover-note fact firsthand** (not from the handoff
  chain): DESCRIPTION `Version: 2.0.0`; maintainer `rmsharp@me.com` via
  the `cre` role (DESCRIPTION:9-11); `revdep/README.md` Revdeps section
  empty (no reverse dependencies). The cover note `cran-comments.md`
  needs no change — it is already a correct CRAN-facing template.
- **Tightened the runbook:** added a copy-paste **Quick sequence**
  (install → build → win-builder ×3 → R-hub → submit) at the top;
  **corrected the §3 branch caveat** to “verified current — no push
  needed” and marked S135’s “2 commits behind / push first” note
  **superseded**; added a build-confirmation note in §1.
- **Status:** **Phase 5 local prep DONE + verified; cross-platform
  runs + submission PENDING (owner).** The owner now runs the runbook’s
  Quick sequence (win-builder ×3 + R-hub need the PAT/email), folds real
  results into `cran-comments.md`, then submits (HARD STOP).
  \[\[consult-project-source-of-truth\]\]
  \[\[check-process-history-before-rerunning-work\]\]
- **PROJECT_LEARNINGS.md:** Learning 129 added (a firsthand-verified
  remote-state claim still expires — re-`fetch` before acting on an
  inherited “push first” prerequisite).

### 2026-06-18 — CRAN Phase 5 (cover note + runbook): rewrote `cran-comments.md` for the 2.0.0 archived-package resubmission and wrote the owner-run win-builder/R-hub runbook; adversarially verified (Session 135)

- **Deliverable (owner pick B-Phase5, scope A “cover note + runbook”):**
  the local, fully-completable half of the CRAN plan’s **Phase 5**.
  **Verification phase** (no new code/behavior). Outward-facing
  win-builder/R-hub submissions + the final CRAN upload remain the
  owner’s (SAFEGUARDS + plan decision \#3). Scoped to
  **`cran-comments.md`** + a new
  **`docs/planning/cran-2.0.0-phase5-runbook.md`** +
  plan/CHANGELOG/learnings docs; **no
  `R/`/`man/`/`NAMESPACE`/`DESCRIPTION`/`tests/`/`data/`/`NEWS`
  change.**
- **`cran-comments.md` rewritten** (the old file was the stale 1.0.8
  “bug fix in unit test” note with a doubled “Reverse dependencies”
  block and 1.0.8-era R-hub `pak` results): now a 2.0.0 archived-package
  resubmission note per plan §7 — addresses the **2025-07-29 archival**
  (date, “Tested elapsed times” reason, and that the 2.0.0 tree no
  longer reproduces the timing condition), reports the **S134 local gate
  `0 errors | 0 warnings | 2 notes`** with each NOTE explained (NOTE 1 =
  incoming feasibility incl. the PMC-403 URL + correctly-spelled
  DESCRIPTION words; NOTE 2 = the local-only HTML-manual tidy/V8
  artifact, absent on CRAN), drops the now-moot NEWS `http→https`
  false-positive (**verified: no `http://` in `NEWS.md`**, so
  pre-explaining it would describe a NOTE that won’t appear), and
  records “no reverse dependencies.” The file is **CRAN-facing-only** —
  no embedded process notes, placeholders, or “delete-before-pasting”
  blocks.
- **Runbook written** (`docs/planning/cran-2.0.0-phase5-runbook.md`):
  exact, ordered commands for the owner — install
  `devtools`/`rhub`/`gitcreds` (absent here) + set a GitHub PAT;
  `R CMD build`; `devtools::check_win_devel/release/oldrelease()`
  (uploads the local tarball; emails results); `rhub::rhub_doctor()` +
  `rhub_check(platforms=c("linux","windows","macos"))`; fold real
  results into the cover note; submit (HARD STOP, owner only).
- **Adversarially verified** (3-lens background workflow — repo
  fact-check + runbook-command/API + skeptical-CRAN-reviewer; all repo
  facts confirmed). Acted on its findings: scoped the timing “3-5x
  headroom” claim to **per-example** (the tests phase at ~43s is not
  3-5x under a minute); reworded the archival section so it does **not**
  imply a structural timing fix that was never made (the cause does not
  reproduce; win-builder/R-hub on slower hardware re-confirm before
  submission); softened the misspelled-words list to “for example …”
  (CRAN computes its own list and does not read `inst/WORDLIST`) and
  added a runbook step to reconcile it against the real check log; moved
  all result-staging guidance out of the cover note into the runbook (a
  “delete-before-pasting” block in a file pasted to CRAN is a foot-gun).
- **Branch/PR correction (verified firsthand; supersedes the standing
  handoff assumption):** the long-carried “future **PR \#53**” **does
  not exist** (`gh pr view 53` → no such PR); **PR \#52 is merged but
  carried only S101-S117** — `origin/master` is still **`1.1.0.9000`**
  and has **none** of the 2.0.0 commits. `origin/add-methodology` is at
  2.0.0 but lacks S133’s `withr` fix + S134’s Phase-4 commit (the 2
  unpushed local commits), so **R-hub must check a pushed
  `add-methodology`** or it re-reports the `withr` WARNING. The
  runbook + Learning 128 capture this.
- **Status:** **Phase 5 cover note + runbook DONE; cross-platform runs +
  submission PENDING (owner).** Noticed drift (flagged, not fixed, FM
  \#8): plan §9 **row 3** (NEWS Major/Minor + 2.0.0 bump) lacks its ✅
  though S130/S131 committed it and the tree is at 2.0.0 — a future
  reconciliation (verify README/CITATION.cff at 2.0.0 too).
  \[\[consult-project-source-of-truth\]\]
  \[\[check-process-history-before-rerunning-work\]\]
- **PROJECT_LEARNINGS.md:** Learning 128 added.

### 2026-06-18 — CRAN Phase 4 (full local `--as-cran` gate): true gate is 0 ERROR / 0 WARNING / 2 false-positive NOTEs; reconciled `inst/WORDLIST` (+35); found the `si.re` dataset-column defect (Session 134)

- **Deliverable (owner pick A):** the CRAN plan’s **Phase 4** — a full
  local `R CMD check --as-cran` gate on the built 2.0.0 tarball.
  **Verification phase** (no new code); the spell reconciliation touched
  one shipped non-code file. Scoped to **`inst/WORDLIST`** + the
  plan/CHANGELOG/learnings docs; **no
  `R/`/`man/`/`NAMESPACE`/`DESCRIPTION`/`tests/`/`data/`/`NEWS`
  change.**
- **True gate, not a forced check:** installed the 4 missing Suggests
  (`covr`, `shinytest2`, `shinyWidgets`, `spelling`) + `urlchecker` into
  the renv library, so `R CMD check --as-cran` ran with **no
  `_R_CHECK_FORCE_SUGGESTS_=false`** (the condition CRAN checks under).
  Installing the *package* `shinytest2` does not install Chrome —
  chromote fetches it lazily and the e2e tests `skip_on_cran`, so the
  check never launches a browser. (The installs land in the renv
  library, not `renv.lock` — no
  [`renv::snapshot()`](https://rstudio.github.io/renv/reference/snapshot.html)
  run.)
- **Result — `Status: 2 NOTEs` = 0 ERROR / 0 WARNING, both NOTEs
  false-positive.** Timings all comfortable: examples `[19s/19s]`,
  `--run-donttest [19s/19s]`, tests `[41s/43s]`, vignette rebuild
  `[15s/16s]`, PDF manual OK. **NOTE 1** = CRAN incoming feasibility
  (“New submission / Package was archived on CRAN”) — expected,
  CRAN-persistent, pre-explain in Phase-5 `cran-comments.md`. **NOTE 2**
  = “checking HTML version of manual” (`'tidy' not recent enough` +
  `package 'V8' unavailable` → both sub-checks skipped) — a
  **local-toolchain** NOTE; CRAN has recent HTML Tidy + V8, so it will
  **not** appear there. **Verified twice** (initial build, then a
  rebuild after the WORDLIST change — identical result; WORDLIST is
  consumed only by the `skip_on_cran` spell test, so it is
  gate-invariant).
- **Pre-gate hygiene (captured evidence):**
  [`roxygen2::roxygenise()`](https://roxygen2.r-lib.org/reference/roxygenize.html)
  → **zero diff** (`man/`+`NAMESPACE` already in sync);
  `urlchecker::url_check()` → **all 17 URLs correct**; full
  clean-regression read **0 failed / 0 error** (863 result rows; 167
  skipped = e2e/app via `skip_on_cran`+opt-in gate; 5 benign warnings,
  all in one passing test `test_modPyramid.R`, pre-existing baseline).
- **`inst/WORDLIST` reconciled (+35 terms, 310→345 lines, owner-approved
  “reconcile now”):** the plan expected “only EHR/Raboin/kinships
  remain,” but
  [`spelling::spell_check_package()`](https://docs.ropensci.org/spelling//reference/spell_check_package.html)
  flagged **37** words — the dictionary had drifted ~35 legitimate code
  identifiers behind the S100–S133 work (`changedCols`, `femaleSires`,
  `qcResult`, `mulatta`, `magrittr`, `BG`/`FG`/`GV`, …). Each was
  verified against its source before adding. **Two left deliberately
  flagged:** `names'` (a curly-quote tokenizer artifact from the quoted
  base-R error `'row.names'` in NEWS — a faithful quote, not a word) and
  `si` (see next).
- **NEW FINDING — `si.re` dataset-column defect (out of scope; needs its
  own session):** the flagged token `si` traced to a column literally
  named **`si.re`** in 5 of the 6 example pedigrees (`pedGood`,
  `pedDuplicateIds`, `pedFemaleSireMaleDam`, `pedMissingBirth`,
  `pedSameMaleIsSireAndDam`); the 6th (`pedInvalidDates`) correctly uses
  `sire`. Almost certainly a data defect (should be `sire`/`sire_id`, to
  pair with `ego_id`/`dam_id`). `si` was **left out** of WORDLIST so the
  flag stays visible —
  [`spelling::update_wordlist()`](https://docs.ropensci.org/spelling//reference/wordlist.html)
  would have enshrined it and masked the defect. Not a CRAN blocker (odd
  column names are legal). Candidate for a GitHub issue + its own
  RED-first fix session (regenerate the `.rda` data with the corrected
  column + sweep dependent code/tests/docs).
- **Status:** **CRAN Phase 4 is COMPLETE.** **Remaining for CRAN:**
  Phase 5 (cross-platform: win-builder ×3 + R-hub + author
  `cran-comments.md`; the cover note must address the 2025-07-29
  archival; **owner triggers the final upload**).
  \[\[check-process-history-before-rerunning-work\]\]
  \[\[consult-project-source-of-truth\]\]
- **PROJECT_LEARNINGS.md:** Learning 127 added.

### 2026-06-18 — CRAN Phase 2 (archival timing root cause): measured timing is within limits — fixed the one real CRAN-blocker, an undeclared `withr` test dependency (strict TDD) (Session 133)

- **Deliverable (owner pick B-Phase2, re-scoped):** the owner picked
  “CRAN Phase 2 — archival timing root cause.” Profiling first (the
  plan’s mandated step + dragon \#1) showed the **archival timing defect
  does NOT reproduce** in the 2.0.0 tree, so per the Phase-2
  STOP-and-re-scope rule the owner re-scoped the session to the one
  **real CRAN-blocking** finding the profile exposed: an **undeclared
  `withr`** test dependency. Scoped to **`DESCRIPTION`** (one `Suggests`
  line) + the plan/CHANGELOG/learnings docs; **no
  `R/`/`man/`/`NAMESPACE`/`tests/`/`data/`/`NEWS` change.**
- **Measurement (authoritative `R CMD check --as-cran --timings`, this
  tree):** examples `[19s/20s]`, `--run-donttest [19s/19s]`, tests
  `[42s/43s]`, vignette re-build `[15s/16s]` — **no timing flag**;
  slowest example `countLoops` 1.43s (0 examples ≥ 5s; sum 7.0s across
  145). The gene-drop vignettes
  (`simulatedKValues`/`ColonyManagerTutorial`, the plan’s prime
  suspects) rebuild in 16s total — cheap on the tiny `smallPed`, **not**
  the offender. Archival reason confirmed firsthand in the CRAN db
  override: *“Archived on 2025-07-29 as issues were not corrected in
  time. / Tested elapsed times.”*
- **The real CRAN-blocker:** `--as-cran` reported
  `Status: 1 WARNING — checking for unstated dependencies in 'tests' ... '::' import not declared from: 'withr'`.
  `tests/testthat/test_loadSiteConfig.R` calls
  [`withr::local_tempdir()`](https://withr.r-lib.org/reference/with_tempfile.html)/[`withr::local_envvar()`](https://withr.r-lib.org/reference/with_envvar.html)
  (6 uses) but `withr` was in neither Imports nor Suggests (it ran only
  because it is installed transitively via testthat). CRAN rejects on
  any WARNING.
- **What changed (1 line):** added `withr` to `DESCRIPTION` `Suggests`
  (alphabetical, after `testthat`). Suggests is correct — `withr` is
  used only in tests. The pre-existing `shinytest2` mis-ordering in
  `Suggests` was left alone (out of scope, FM \#8).
- **TDD:** a pre-RED re-scope gate (fix-withr-and-document vs
  document-only vs +guard-heavy-examples; owner chose **fix +
  document**) + the three transitions (`PRE-RED→RED`, `RED→GREEN`;
  `GREEN→REFACTOR` declared **N/A** — a single metadata line, no
  structure). RED: a file-based probe (`_s133_red.R`) encoding the CRAN
  “unstated test deps” invariant via R’s **parser** (`SYMBOL_PACKAGE`
  tokens — comment/string-immune, adopted after a first regex draft
  false-flagged `devtools` in comments and the `shinytest2.R` filename);
  2 assertions (withr declared; no undeclared `pkg::` in `tests/`) → **2
  failures** naming only `withr`, **0** after the fix. No permanent
  testthat guard (owner chose the temp-probe path; matches the S131/S132
  metadata-fix class).
- **Verified:** probe green (declared deps 34→35; no undeclared test
  deps); **re-run `R CMD check --as-cran` → `Status: 2 NOTEs`, i.e. 0
  ERROR / 0 WARNING** — the `withr` WARNING resolved, timing still
  clean; **full clean-regression read 0 failed / 0 error** (699 test
  blocks excl. `test-app-`/`test-e2e-`; 0/0 across all 863). The 2 NOTEs
  are the expected archived/new-submission incoming-feasibility note + a
  non-standard-files note listing only the `_s133_*` session transients
  (removed before commit) → true package status is **0 / 0 /
  1-expected-NOTE**. **Phase-3E:** the `--as-cran` check ran the full
  runtime (install + 136 examples + the testthat suite + vignette
  rebuild) — the strongest available runtime verification; the change
  itself alters no runtime behavior.
- **Env note:** the renv library IS materialized here (correcting the
  S131/S132 “renv not materialized / Phase 2 blocked” baseline).
  Installed one missing build-only Suggest, `markdown` (+ `litedown`),
  into the renv library so `a3manual.Rmd` builds — env-setup gap, not a
  package defect.
  `devtools`/`rcmdcheck`/`shinytest2`/`shinyWidgets`/`spelling`/`covr`
  remain absent; the `--as-cran` check ran with
  `_R_CHECK_FORCE_SUGGESTS_=false`.
- **Status:** **CRAN Phase 2 is COMPLETE** — timing
  measured-and-within-limits (archival cause already resolved), the one
  real CRAN-blocker fixed. **Residual:** machine-speed variance on CRAN
  re-checks is only retired in Phase 5 (win-builder/R-hub).
- **Remaining for CRAN:** Phase 4 (full `--as-cran` gate — now 0/0
  locally modulo the expected NOTE; re-confirm with the missing Suggests
  installed), Phase 5 (cross-platform + `cran-comments.md`; owner
  submits). \[\[check-process-history-before-rerunning-work\]\]
  \[\[consult-project-source-of-truth\]\]
- **PROJECT_LEARNINGS.md:** Learning 126 added.

### 2026-06-18 — Completed the `mulatto`-\>`mulatta` species-typo fix across shipped README + vignette + CITATION; reconciled CRAN Phase-1 status (strict TDD) (Session 132)

- **Deliverable (owner pick B-Phase1, re-scoped):** the owner picked
  “CRAN Phase 1 static hygiene”, but a process-history check found
  **Phase 1 was already executed by S102** (commit `a3cf3623`): the
  `.Rbuildignore` build-cruft lines, the DESCRIPTION
  `mulatto`-\>`mulatta` typo, the renv `Config/*` reordering,
  `VignetteBuilder: knitr`, the `@return`/`\value` docs for
  [`appServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/appServer.md)/[`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md),
  and the LICENSE-year reconcile (`LICENSE` + `LICENSE.md` both
  `2017-2026`) are all in place — verified firsthand against the live
  tree. The only Phase-1 remnant is the **optional** DESCRIPTION DOI
  (the plan marks `<https:>` acceptable). A tree-wide `mulatto` sweep,
  however, found S102 fixed the typo in DESCRIPTION **only**: the same
  species name survived in **four** more tracked places —
  `README.Rmd:48` (rendering into the shipped `README.md` twice), the
  shipped vignette child
  `vignettes/manual_components/_introduction.Rmd:48` (built into
  `a3manual.Rmd`), `CITATION.cff:16`, and `_pkgdown.yml:16` (the website
  `description:` field). The owner chose to finish the typo fix
  tree-wide (and approved a +1 when a close-out `git ls-files` pass
  surfaced `_pkgdown.yml`, which the RED probe’s dir-scoped sweep had
  missed).
- **What changed (5 tracked content files, 6 lines):** `README.Rmd:48` +
  `vignettes/manual_components/_introduction.Rmd:48`
  `*Macaca mulatto*`-\>`*Macaca mulatta*`; `CITATION.cff:16`
  `''mulatto''`-\>`''mulatta''` (hand-edit; cffr absent);
  `_pkgdown.yml:16` `'Macaca' 'mulatto'`-\>`'Macaca' 'mulatta'`.
  Re-rendered `README.md` via
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
  `rmarkdown::render(github_document, html_preview=FALSE)`, which fixed
  **both** README.md occurrences (one from README.Rmd’s own line, one
  from the `_introduction` child included at `README.Rmd:32`). The
  `README.md` diff is confined to exactly the two typo lines — the auto
  [`getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md)
  date line did not churn. (`CITATION.cff` and `_pkgdown.yml` are
  `.Rbuildignore`d — they do not ship to CRAN, but `_pkgdown.yml` is
  published to the pkgdown website.)
- **TDD:** a pre-RED scope gate (re-scope: typo-fix-tree-wide vs
  doc-reconcile-only vs typo-only; owner chose tree-wide) + the three
  transitions (`PRE-RED→RED`, `RED→GREEN`; `GREEN→REFACTOR` declared
  **N/A** — prose content, no structure to refactor). RED: a file-based
  probe (`_s132_red.R`) bound to the no-`mulatto` invariant — per-file
  (each of the 4 files: zero `mulatto`, \>=1 `mulatta`) + a tree-wide
  sweep over git-tracked `R/`/`man/`/`vignettes/` + `README.md` +
  `DESCRIPTION` — **9 failures** on the current tree, **0** after the
  edits + re-render. The sweep was scoped to git-tracked files after RED
  surfaced an over-broad hit on untracked, git-ignored render litter
  (`vignettes/a3manual.html|md`) — but the dir-scoped sweep then proved
  too *narrow*, missing `_pkgdown.yml`; a close-out
  `git ls-files | grep mulatto` belt-and-suspenders pass caught it
  (owner-approved scope+1) → Learning 125. No permanent testthat test
  added (prose; matches the S126–S131 doc-fix class — the owner chose
  the temp-probe path over a permanent guard in the PRE-RED→RED gate).
  **0 stakeholder corrections.**
- **Verified:** probe 9/9 pass; **full clean-regression read 0 failed /
  0 error** (no true offenders excluding `test-app-`/`test-e2e-`);
  `git diff` confined to the 3 sources + regenerated `README.md`; no
  `README.html`/figure litter; removed the transient probe/render/suite
  scripts. **Phase-3E N/A** — a content/doc change alters no runtime
  behavior; the README re-render IS the doc build-equivalent
  (SAFEGUARDS). Full `R CMD check` not run (`devtools` absent).
- **Status reconciliation:** **CRAN Phase 1 is now COMPLETE** (S102 +
  this S132 typo tail). The untracked, git-ignored
  `vignettes/a3manual.html|md` still carry the old typo, but they are
  local render litter — not committed, absent from a clean CRAN tarball
  — and regenerate clean on the next vignette build; left as-is.
- **Remaining for CRAN:** Phase 2 (archival timing root cause), Phase 4
  (`R CMD check --as-cran` gate), Phase 5 (cross-platform +
  `cran-comments.md`; owner submits).
  \[\[check-process-history-before-rerunning-work\]\]
  \[\[news-vs-changelog\]\] \[\[backlog-vs-changelog-placement\]\]
- **PROJECT_LEARNINGS.md:** Learning 125 added.

### 2026-06-18 — Bumped version to 2.0.0 across DESCRIPTION / README / CITATION (CRAN Phase 3b, strict TDD) (Session 131)

- **Deliverable (owner pick B-cont, Phase 3b):** the version-consistency
  half of the CRAN plan’s Phase 3 — bumped `DESCRIPTION:4` Version
  `1.1.0.9000` → `2.0.0`, re-rendered `README.md` (its version line
  auto-tracks
  [`getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md)),
  and set `CITATION.cff` version (**stale at 1.0.7**) → `2.0.0` plus a
  new `date-released: '2026-06-18'`. Scoped to **`DESCRIPTION` +
  `README.md` + `CITATION.cff`**; **no
  `R/`/`man/`/`NAMESPACE`/`data/`/test/`NEWS` change.** This resolves
  the intentional Phase-3a mismatch (NEWS said 2.0.0 while DESCRIPTION
  still said 1.1.0.9000) — the package is now version-consistent at
  **2.0.0**.
- **Owner decisions (two pre-RED gates):** scope = **version-consistency
  only** (no new permanent guard test); the carried maintainer-judgment
  NEWS promotion (`secondQuartile` / rhesus data-type Minor → Major) =
  **deferred** (NEWS untouched).
- **TDD:** pre-RED scope question + the three transitions
  (`PRE-RED→RED`, `RED→GREEN`; `GREEN→REFACTOR` declared **N/A** —
  mechanical metadata bump, no structure to refactor). RED: a file-based
  version-consistency probe (`_s131_red.R`) parsing `DESCRIPTION`
  (`read.dcf`), `CITATION.cff`, and `README.md` — 7 assertions (all
  three == 2.0.0; stale `1.1.0.9000` / `1.0.7` absent; CITATION has a
  `date-released`) → **7 failures** on the current tree, **0** after the
  two Edits + re-render. GREEN: two deterministic `Edit`s +
  `rmarkdown::render(output_format = github_document(html_preview = FALSE))`
  (no litter). **0 stakeholder corrections.**
- **Verified:** probe 7/7; `test_getVersion.R` (7 checks) +
  `test_appUI_version.R` (3 checks) green at 2.0.0; **full
  clean-regression read 191 files, 0 failed / 0 error**;
  `git diff README.md` confined to the single version line
  (`1.1.0.9000 (2026-06-01)` → `2.0.0 (2026-06-17)`), no `README.html`
  litter, no figure drift. **Phase-3E satisfied** —
  `test_appUI_version.R` renders the
  [`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
  About tab and confirms it now shows “Version 2.0.0” (a real runtime
  path), not the stale “1.0.8”.
- **Dates provisional:** README’s `(2026-06-17)` is
  [`getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md)/`sessioninfo`-derived
  (not literal today); CITATION `date-released` is today’s `2026-06-18`.
  Both reconfirmed at the actual CRAN submission (Phase 5).
- **Flagged for follow-up (out of locked scope — `.Rbuildignore`d dev
  docs, not CRAN artifacts; not touched, FM \#8):** stale “(Version
  1.1.0.9000)” prose in `CLAUDE.md:18`; a now-**dangling** “NEWS.md
  1.1.0.9000” cross-reference in `ROADMAP.md:6` (consequence of S130’s
  NEWS retitle to 2.0.0); a now-resolved TODO note in
  `nprcgenekeepr_notes.txt:5`. Historical `1.0.7` build logs in
  `inst/extdata/submission.txt` / `meeting_notes.html` correctly left
  (§3.1 “must NOT be bumped”).
- **Remaining for CRAN:** Phase 4 (`R CMD check --as-cran` gate), Phase
  5 (cross-platform + `cran-comments.md`; owner submits), and Phase 2
  (archival timing root cause). *(Correction by S132: Phase 1 static
  hygiene was NOT open — it was completed in S102; this entry’s claim
  was inaccurate. The `'mulatto'`→`'mulatta'` typo and `\value` docs
  were done in S102, except the typo’s README/vignette/CITATION copies,
  which S132 finished.)* \[\[news-vs-changelog\]\]
  \[\[backlog-vs-changelog-placement\]\]
- **PROJECT_LEARNINGS.md:** Learning 124 added.

### 2026-06-18 — Rewrote the NEWS 1.1.0.9000 section into a terse 2.0.0 Major/Minor entry (CRAN Phase 3a, strict TDD) (Session 130)

- **Deliverable (owner pick B, Phase 3a — split per plan line 154):**
  rewrote the single post-1.0.8 `NEWS` section (the dev tag
  `1.1.0.9000`) into one terse `# nprcgenekeepr 2.0.0 (20260618)` entry
  organized as **Major changes / Minor changes** per the plan’s §6.2
  style and §6.3 classification, and re-rendered `NEWS.md` from
  `NEWS.Rmd`. Scoped to **`NEWS.Rmd` + `NEWS.md`**; **no
  `DESCRIPTION`/`R/`/`man/`/`data/`/test/README/CITATION change** — the
  version bump + README/CITATION regen + version-dependent tests are the
  deferred **Phase 3b** (next session).
- **What the rewrite did:** merged the doubled topic-block +
  Major/Minor-block (dragon \#4) into one de-duplicated section; dropped
  the 9 internal tracker codes (`NEW-xx`/`PED-x`/`XARCH-x`) while
  keeping the `(#NN)` GitHub refs; dropped developer-internal mechanics
  per §6.3 (calcFE/FG/FEFG de-dup, `mod*.R` file lists/`moduleServer`
  internals,
  `runQcStudbook`/`processQcStudbookResult`/`shouldShowChangedColsTab`,
  `safeExecute`/`logModuleEvent`/table-makers, “Testing
  Improvements”/~145 test files, internal test/CI fixes); and **folded
  in the S112–S129 user-facing delta** — the
  `rhesusPedigree`/`rhesusGenotypes` canonical-column-type re-exports
  (S123/S124, Minor with a maintainer-judgment flag), the
  [`addGenotype()`](https://github.com/rmsharp/nprcgenekeepr/reference/addGenotype.md)
  allele-coercion behavior change (S125, Minor), and one omnibus
  “Documentation” Minor bullet for the shipped help/data-doc corrections
  (S112/S114–S117/S120–S122/S126–S127). S113/S118/S119/S128/S129 are
  tooling/VCS/test/website-only and correctly not surfaced.
- **Date provisional:** the `(20260618)` heading date is today’s;
  reconfirm/adjust at the actual CRAN submission (Phase 5).
- **TDD:** one pre-RED scope gate (full Phase 3 vs split; owner chose
  split) + the three transitions (`PRE-RED→RED`, `RED→GREEN`,
  `GREEN→REFACTOR`). RED: a file-based probe bound to the rendered
  `NEWS.md` — 1 precondition (prior 1.0.8 history present) + 6
  assertions (one 2.0.0 heading; 1.1.0.9000 gone; Major+Minor present;
  no NEW-/PED-/XARCH-; delta folded incl. `addGenotype` + rhesus data;
  module mechanics dropped) — **6 failures** on the current file, **0
  (7/7)** after the rewrite+render. GREEN: authored the section
  (write-section-file + R splice by heading boundary, avoiding a fragile
  178-line Edit match), re-rendered. REFACTOR: tightened the verbose
  Major bullets to the §6.2 one-sentence form (probe stayed 7/7; all
  facts preserved). **0 stakeholder corrections.**
- **Adversarially verified (workflow — 3 independent lenses):**
  completeness (vs OLD `git show HEAD:NEWS.md`, plan §6.3, CHANGELOG
  S112–S129), accuracy (every named function exists/exported per
  `NAMESPACE`/`R/`; behavior + issue numbers cross-checked against
  code), and dedup/house-style → **0 completeness, 0 accuracy issues, 0
  double-counts**; only 6 style nits (verbose bullets), all resolved by
  the REFACTOR tighten. A post-tighten token sweep confirmed every
  user-facing fact survived.
- **Verified:** probe 7/7;
  `rmarkdown::render(output_format="github_document")` clean (pandoc
  3.1.1); both `NEWS.Rmd`/`NEWS.md` carry exactly one `2.0.0` heading
  and zero `1.1.0.9000`; prior history (1.0.8 → 1.0.4.9003 …) intact;
  `git diff` confined to the two NEWS files; removed the github_document
  `NEWS.html` preview litter + transient probe/splice files. **Phase-3E
  N/A** — a docs-content change alters no runtime behavior; the render
  IS the doc build-equivalent (SAFEGUARDS). Version-dependent tests not
  run this session (no version bump yet; both are dynamic and deferred
  to Phase 3b).
- **Flagged for Phase 3b (next session):** bump `DESCRIPTION:4`
  1.1.0.9000 → 2.0.0; regenerate `README.md` (rmarkdown::render;
  `devtools::build_readme` absent); set `CITATION.cff` version
  (currently **stale at 1.0.7**) → 2.0.0 (hand-edit; cffr absent); run
  `test_getVersion.R` + `test_appUI_version.R` (both dynamic → green).
  Maintainer judgment for the owner: whether to promote the
  [`summarizeKinshipValues()`](https://github.com/rmsharp/nprcgenekeepr/reference/summarizeKinshipValues.md)
  `secondQuartile` change and/or the rhesus data-type change from Minor
  to Major. \[\[news-vs-changelog\]\]
  \[\[backlog-vs-changelog-placement\]\]
- **PROJECT_LEARNINGS.md:** Learning 123 added.

### 2026-06-18 — Corrected the studbook-QC vignette’s `pedGood` column description (DOC fix, strict TDD) (Session 129)

- **Deliverable (owner pick A3):** carried from S116 — the *Studbook
  Quality Control* article
  (`vignettes/articles/studbook-quality-control.qmd:90-91`) introduced
  the `pedGood` example as having “deliberately messy headers (`ego_id`,
  `si.re`, `dam_id`, `birth_date`)”, listing only four of the data set’s
  **five** columns and never telling the reader `pedGood` also carries a
  `sex` column. Reworded the lead-in to “…has five columns – four with
  deliberately messy headers (`ego_id`, `si.re`, `dam_id`, `birth_date`)
  and an already-canonical `sex` that QC leaves untouched:”.
  Website-only article (`vignettes/articles/` is `.Rbuildignore`d) —
  **no
  `R/`/`man/`/`NAMESPACE`/`DESCRIPTION`/`NEWS`/`data/`/test/CRAN-vignette
  change**; a single 3-line prose edit.
- **Correctness nuance (verified firsthand):** S116 framed this as
  “omits the `sex` column”, but `sex` is NOT one of the messy headers —
  a probe on the live object shows `names(pedGood)` = `ego_id`, `si.re`,
  `dam_id`, `sex`, `birth_date`, and the `changes` chunk renames exactly
  the four non-`sex` columns (`sex` is absent from `changedCols`).
  Naively inserting `sex` into the parenthetical would have mislabeled
  it as messy and contradicted the chunk’s own output. The owner chose
  the lead-in rewrite (five columns: four messy + already-clean `sex`)
  over a minimal appended clause.
- **TDD:** one pre-RED approach gate (rewrite lead-in vs append a
  clause) + the three mandatory transitions (`PRE-RED→RED`, `RED→GREEN`;
  `GREEN→REFACTOR` declared **N/A** — prose content, structure
  preserved). RED: a file-based probe bound to ground truth — parses the
  lead-in paragraph from the `.qmd` and asserts (preconditions, must
  pass) `names(pedGood)` has 5 columns incl. `sex` and the 4 listed
  headers are exactly the non-`sex` columns, and (RED assertions, must
  fail) the lead-in mentions `sex` and states the count “five” —
  confirmed **2 failures** against the current prose, 3 preconditions
  passing. GREEN: the 3-line edit; re-ran the probe → **0 failures (all
  5 pass)**. No permanent testthat test added (matches the S120–S127
  doc-fix class; testthat does not execute this website-only article).
  **0 stakeholder corrections.**
- **Verified:** probe 0 failures; **build-equivalent render** via
  `pkgdown::build_article("articles/studbook-quality-control")` — clean
  render; the rendered HTML (`pkgdown_site/articles/...`, gitignored)
  contains the new sentence and the `changedCols` output still shows
  exactly the four renames with no `sex` rename (prose now matches what
  the chunk demonstrates); `git diff` confined to the single `.qmd`.
  Cleaned the render litter (`pkgdown/`,
  `vignettes/articles/.gitignore`, the `*.rmarkdown` intermediate)
  before commit. **Phase-3E N/A** — a documentation-content change
  alters no runtime behavior; the render IS the doc build-equivalent
  (SAFEGUARDS “Verify the Build Equivalent”). Full testthat suite not
  run — no `R/`/test/`data/` change, and testthat does not execute the
  website-only article.
- **Flagged for the future:** website-only article — does **not** ship
  to CRAN, so **no `NEWS.md` line warranted** (unlike the S123–S125
  user-facing changes). \[\[news-vs-changelog\]\]
  \[\[backlog-vs-changelog-placement\]\]
- **PROJECT_LEARNINGS.md:** Learning 122 added.

### 2026-06-18 — Removed redundant `as.character`/`as.Date` no-op conversions from two test fixtures (REFACTOR, strict TDD) (Session 128)

- **Deliverable (owner pick A8):** carried from S123 — deleted the
  redundant `as.character(id/sire/dam)` / `as.Date(birth)`
  self-assignments that re-coerced `rhesusPedigree`-sourced fixtures to
  types the object already ships (S123 re-exported `rhesusPedigree` with
  canonical column types, Learning 116, making these conversions
  no-ops). Removed **12 lines** across **three** identical-class blocks:
  `tests/testthat/test_getPotentialParents.R:4-7` (`pedOne`) and
  `:116-119` (`pedDF`), plus
  `tests/testthat/test_modPotentialParents.R:121-124` (`pedOne`). Kept
  every `$fromCenter <- TRUE` line and the `pedDF`
  [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html)
  precondition. **Test code only — no production / `R/` / `man/` /
  `NAMESPACE` / `DESCRIPTION` / `NEWS` / `data/` change.**
- **Scope (gated):** S127’s handoff named two blocks; a robust ERE sweep
  found a third identical block in the same file (`pedDF`), which the
  owner chose to include (all three) so the file is internally
  consistent. Two look-alikes were classified out and left alone — an
  `as.Date` inside age arithmetic at `test_fillBins.R:22` and an
  `as.character` inside an `expect_setequal` at
  `test_modGeneticValue.R:1274` (not redundant self-assignments).
- **No-op proven firsthand:** `rhesusPedigree` ships `id`/`sire`/`dam`
  as character and `birth` as Date; `identical(as.character(col), col)`
  and `identical(as.Date(birth), birth)` are all TRUE, and
  `identical(frame-with-all-conversions, frame-without)` is TRUE — so
  the deletions are strictly behavior-preserving.
- **TDD:** a REFACTOR-only deliverable, so **NO RED phase** (the
  existing green suite is the safety net). One pre-REFACTOR scope gate
  (two named blocks vs all three) + the GREEN→REFACTOR transition gate.
  **0 stakeholder corrections.**
- **Verified:** GREEN baseline both files pass → 12-line deletion → both
  files pass with identical test counts; full-suite clean-regression
  read **failed=0 error=0** (no offenders; baseline
  `test-app-`/`test-e2e-` clean this run too); `git diff` confined to
  the 12 intended deletions. **Phase-3E N/A** — a test-only change
  alters no runtime/production behavior; the proportionate
  build-equivalent is the targeted files green + full suite 0/0 + the
  confined diff.
- **Flagged for the future:** internal test cleanup — fold into the CRAN
  Phase 3 NEWS rewrite at 2.0.0 only if a NEWS line is warranted (almost
  certainly not — no user-facing change). \[\[news-vs-changelog\]\]
  \[\[backlog-vs-changelog-placement\]\]
- **PROJECT_LEARNINGS.md:** Learning 121 added.

### 2026-06-18 — Corrected the `rhesusPedigree` data-doc `@source` citation (DOC fix, strict TDD) (Session 127)

- **Deliverable (owner pick A11):** the `rhesusPedigree` documentation
  cited a nonexistent source file `rhesusPedigree.csv`; corrected it to
  the real, value-identical export `obfuscated_rhesus_mhc_ped.csv`. This
  closes the sibling phantom flagged by S126 (Learning 119) and
  **completes the data-doc `@source` phantom-citation class for
  `R/data.R`** (a post-fix sweep confirms all three `\emph{...csv}`
  citations now resolve). Scoped to **`R/data.R` (one roxygen token) +
  `man/rhesusPedigree.Rd` (regenerated)**; **no
  `NAMESPACE`/`DESCRIPTION`/`NEWS`/`data/`/code change** (`NAMESPACE`
  proven byte-identical). Owner chose **filename-swap-only** (sentence
  structure preserved) over a grammar-clarifying rewrite.
- **Verified firsthand (overturned a filename-based assumption):**
  `find` confirms no `rhesusPedigree.csv` exists anywhere. Both
  candidate files carry the SAME obfuscated ids as the bundled object,
  so neither is pre-obfuscation data — there is no un-obfuscated source
  shipped. `inst/extdata/obfuscated_rhesus_mhc_ped.csv` is 375×8 and
  **value-identical to the bundled `rhesusPedigree` across all 8
  columns** (ordered-by-id compare).
  `inst/extdata/rhesusPedigree_fromCenter.csv` (the file
  `data-raw/rhesusPedigree.R` names as the obfuscation source) is
  value-identical only on the 8 shared columns but is 375×9 (extra
  `fromCenter` column) — a superset, not the exact twin — so the minimal
  exact match was cited.
- **TDD:** one pre-RED scope gate (which file + swap-only vs
  grammar-clarify) + the three mandatory transitions (`PRE-RED→RED`,
  `RED→GREEN`, `GREEN→REFACTOR`). RED: a file-based probe parsing
  `man/rhesusPedigree.Rd` for its `\emph{}` source token and
  asserting (a) the phantom `rhesusPedigree.csv` is absent from both
  `R/data.R` and the man page, (b) the cited
  `obfuscated_rhesus_mhc_ped.csv` is present in both, (c) it exists in
  `inst/extdata` **and** is value-identical to the object — confirmed
  **4 failures** (A1–A4) against the current doc, preconditions A5–A6
  passing. GREEN: swapped the one token; regenerated `man/` via the rd
  roclet only (NAMESPACE untouched); re-ran the probe → **0 failures
  (all 6 pass)**. REFACTOR: **N/A** (single-token doc fix; structure
  intentionally preserved). No permanent testthat test added — matches
  the S120–S122 / S126 data-doc audit class. **0 stakeholder
  corrections.**
- **Verified:** probe 0 failures; full-suite clean-regression read
  **failed=0 error=0** (no offenders; baseline `test-app-`/`test-e2e-`
  clean); `tools::checkRd("man/rhesusPedigree.Rd")` **0 problems**;
  **`NAMESPACE` byte-identical** (md5 unchanged); `git diff` confined to
  the two intended lines (`R/data.R`, `man/rhesusPedigree.Rd`).
  **Phase-3E N/A** — a doc-only change alters no runtime behavior (no
  code/data/startup/dispatch); the build-equivalent (checkRd +
  load_all + full suite + NAMESPACE byte-diff + the man-source probe) is
  the proportionate verification.
- **Flagged for the future:** the `@source` phantom-citation class is
  now **CLOSED** for `R/data.R`. Fold S127 into the CRAN Phase 3 NEWS
  rewrite at 2.0.0 (doc-only; may not warrant a NEWS line).
  \[\[news-vs-changelog\]\] \[\[backlog-vs-changelog-placement\]\]
- **PROJECT_LEARNINGS.md:** Learning 120 added.

### 2026-06-18 — Corrected the `rhesusGenotypes` data-doc `@source` citation (DOC fix, strict TDD) (Session 126)

- **Deliverable (owner pick A10):** the `rhesusGenotypes` documentation
  cited a nonexistent source file `rhesusGenotypes.csv`; corrected it to
  the real, value-identical export
  `obfuscated_rhesus_mhc_breeder_genotypes.csv`. Scoped to **`R/data.R`
  (one roxygen token) + `man/rhesusGenotypes.Rd` (regenerated)**; **no
  `NAMESPACE`/`DESCRIPTION`/`NEWS`/`data/`/code change** (`NAMESPACE`
  proven byte-identical). Owner chose **filename-swap-only** (sentence
  structure preserved) over a grammar-clarifying rewrite.
- **Verified firsthand (not from S124/S125 memory):** `find` confirms no
  `rhesusGenotypes.csv` exists anywhere in the repo;
  `inst/extdata/obfuscated_rhesus_mhc_breeder_genotypes.csv` is 31×3
  (`id`/`first_name`/`second_name`) and **value-identical** to the
  bundled `rhesusGenotypes` in all three columns (ordered-by-id,
  all-character compare). `data-raw/rhesusGenotypes.R` (S124)
  independently documents this CSV as the value-identical export.
- **TDD:** one pre-RED scope gate (filename-swap-only vs
  +grammar-clarify) + the three mandatory transitions (`PRE-RED→RED`,
  `RED→GREEN`, `GREEN→REFACTOR`). RED: a file-based probe parsing
  `man/rhesusGenotypes.Rd` for its `\emph{}` source token and
  asserting (a) the cited file exists in `inst/extdata` **and** is
  value-identical to `rhesusGenotypes`, (b) the wrong name
  `rhesusGenotypes.csv` is absent from both `R/data.R` and the man page
  — confirmed **4 failures** against the current doc. GREEN: swapped the
  one token; regenerated `man/` via the rd roclet only (NAMESPACE
  untouched); re-ran the probe → **0 failures**. REFACTOR: **N/A**
  (single-token doc fix; structure intentionally preserved). No
  permanent testthat test added — matches the S120–S122 data-doc audit
  class. **0 stakeholder corrections.**
- **Verified:** probe 0 failures; full-suite clean-regression read
  **failed=0 error=0** (no offenders; baseline `test-app-`/`test-e2e-`
  clean this run too); `tools::checkRd("man/rhesusGenotypes.Rd")` **0
  problems**; **`NAMESPACE` byte-identical** (sha256 unchanged);
  `git diff` confined to the two intended lines (`R/data.R`,
  `man/rhesusGenotypes.Rd`). **Phase-3E N/A** — a doc-only change alters
  no runtime behavior (no code/data/startup/dispatch); the
  build-equivalent (checkRd + load_all + full suite + NAMESPACE
  byte-diff + the man-source probe) is the proportionate verification.
- **Flagged for the future (NOT done, FM \#8):** **the sibling
  `rhesusPedigree` `@source` (`R/data.R:358`) cites the same phantom
  class** — `rhesusPedigree.csv` does NOT exist anywhere; candidate real
  source is `rhesusPedigree_fromCenter.csv` (the obfuscation source) or
  `obfuscated_rhesus_mhc_ped.csv` (a likely value-identical obfuscated
  export — needs a value-identity check) — call it **A11**.
  `ExamplePedigree.csv` (`R/data.R:18`) was checked and **does** exist
  (fine). Fold S126 into the CRAN Phase 3 NEWS rewrite at 2.0.0
  (doc-only; may not warrant a NEWS line). \[\[news-vs-changelog\]\]
  \[\[backlog-vs-changelog-placement\]\]
- **PROJECT_LEARNINGS.md:** Learning 119 added.

### 2026-06-17 — Hardened `addGenotype()` against factor allele columns (CODE fix, strict TDD) (Session 125)

- **Deliverable (owner pick A9):** hardened
  [`addGenotype()`](https://github.com/rmsharp/nprcgenekeepr/reference/addGenotype.md)
  so its integer allele encoding is consistent regardless of whether the
  two allele columns arrive as character or factor. This realizes the
  code fragility S124 surfaced and flagged (Learning 117): the
  dictionary lookup `genoDict[genotype[, 2L]]` / `[, 3L]` indexes a
  name-keyed vector by a factor, so R uses the factor’s **integer
  codes** instead of its labels, yielding an encoding that is
  inconsistent between the two columns (and between callers). Scoped to
  **`R/addGenotype.R` + `tests/testthat/test_addGenotype.R` +
  `man/addGenotype.Rd`**; **no
  `NAMESPACE`/`DESCRIPTION`/`NEWS`/`data/`/`checkGenotypeFile.R`
  change** (`NAMESPACE` proven byte-identical).
- **Fix (2 lines):** coerce both allele columns to character at the top
  of
  [`addGenotype()`](https://github.com/rmsharp/nprcgenekeepr/reference/addGenotype.md)
  (by their names, `genotypeNames[1L]`/`[2L]`), so both the dictionary
  build (`sort(unique(c(...)))`) and the lookup operate on labels.
  Coercing at the top — rather than only wrapping the two index
  expressions — also neutralizes the version-fragile
  [`c()`](https://rdrr.io/r/base/c.html)-on-factors behavior in the
  dictionary build.
- **Scope decision (gated):** the coercion lives in `addGenotype` only,
  **not** `checkGenotypeFile`. A read-only breadth scan confirmed (a)
  the bug pattern is **isolated to `addGenotype`** — no sibling genotype
  function indexes a named vector by a possibly-factor column; (b)
  `addGenotype` has **direct callers that bypass the `checkGenotypeFile`
  gate** (the roxygen example, `test_addGenotype.R`, `test_geneDrop.R`),
  so a gate-only fix would not protect them; (c) `checkGenotypeFile` is
  a structural validator that does not coerce types. Owner chose
  addGenotype-only (point-of-use); `checkGenotypeFile` stays a pure
  validator.
- **TDD:** one pre-RED scope gate (addGenotype-only vs
  +checkGenotypeFile) + the three mandatory transitions (`PRE-RED→RED`,
  `RED→GREEN`, `GREEN→REFACTOR`). RED: two new failing tests in
  `test_addGenotype.R` — (1) factor-input output **identical** to
  character-input output, (2) the same allele (`"b"`, appearing as
  `first_name` in one row and `second_name` in another) gets the
  **same** code in both — on a minimal deterministic fixture
  (`first_name = c("a","b")`, `second_name = c("b","c")` as factors;
  globally a→10001, b→10002, c→10003). Confirmed **2 failed / 0 error**
  on the unhardened function while the existing character-input test
  stayed green. GREEN: the 2-line coercion; all 3 tests pass. REFACTOR:
  added a one-line `@details` note documenting the internal coercion;
  regenerated `man/addGenotype.Rd`. **0 stakeholder corrections.**
- **Verified:** all 3 `addGenotype` tests pass; full-suite
  clean-regression read **failed=0 error=0** (no offenders; baseline
  `test-app-`/`test-e2e-` clean this run too);
  `tools::checkRd("man/addGenotype.Rd")` **0 problems**; **`NAMESPACE`
  byte-identical**; `git diff` confined to the three intended files.
  **Phase-3E runtime smoke DONE** (runtime-behavior change): ran
  `addGenotype(rhesusPedigree, rhesusGenotypes)` on a factor-coerced
  copy of the real bundled object → `first`/`second` **identical** to
  the character path, the combined 35-allele dictionary (codes
  10001–10035), **max distinct codes per allele = 1** (consistent) —
  computed at the genotype-row level to avoid the S124
  short-logical-recycling trap (gotcha \#11).
- **Flagged for the future (NOT done):** fold S125 into the CRAN Phase 3
  NEWS rewrite at 2.0.0 (this CODE fix **ships** and changes
  `addGenotype` output for any factor-columned input). Still open: the
  `R/data.R:345` data-doc nit (cites a nonexistent
  `rhesusGenotypes.csv`; real source is
  `obfuscated_rhesus_mhc_breeder_genotypes.csv`) (A10), the redundant
  test no-ops in
  `test_getPotentialParents.R`/`test_modPotentialParents.R` (A8), and
  the vignette sex-column nit (A3). \[\[news-vs-changelog\]\]
  \[\[backlog-vs-changelog-placement\]\]
- **PROJECT_LEARNINGS.md:** Learning 118 added.

### 2026-06-17 — Re-exported `rhesusGenotypes` with character column types (DATA change, strict TDD) (Session 124)

- **Deliverable (owner pick A7):** re-exported the bundled
  `rhesusGenotypes` object (31 animals, two haplotypes each) so all
  three columns carry the canonical **character** type, **preserving
  every value**. They shipped as `stringsAsFactors`-era factors (`id` 31
  levels, `first_name` 18, `second_name` 23). Same coerce-in-place +
  `data-raw/` + atomic-doc/man/test pattern as S123 (Learning 116).
  Scoped to **`data/rhesusGenotypes.RData` + new
  `data-raw/rhesusGenotypes.R` + new
  `tests/testthat/test_rhesusGenotypes.R` + the `rhesusGenotypes` `id`
  doc line in `R/data.R` + `man/rhesusGenotypes.Rd`**; **no
  `NAMESPACE`/`DESCRIPTION`/`NEWS`/`.Rbuildignore`/other-data-object/`addGenotype.R`
  change** (`^data-raw$` was already build-ignored from S123).
- **The firsthand investigation reframed A7 (Learning 117):** S123
  flagged A7 as “de-factor `id`”. Probing showed the object has
  **three** factor columns, and that `id` is the column that does NOT
  matter (`merge(ped, genotype, by="id")` coerces it either way; every
  consumer is id-agnostic). The columns that matter are the two
  **allele** columns:
  [`addGenotype()`](https://github.com/rmsharp/nprcgenekeepr/reference/addGenotype.md)’s
  dictionary lookup `genoDict[genotype[, 2L]]` indexes a name-keyed
  vector by a factor, so R uses the factor’s INTEGER CODES instead of
  its labels — yielding an **inconsistent** encoding (same allele →
  different codes in `first` vs `second`). With character columns the
  lookup is by name and the encoding is **consistent** (verified: same
  allele → same code = TRUE for character / FALSE for factor; combined
  dictionary 35 alleles, codes 10001–10035 vs the buggy per-column
  10001–10018 / 10001–10023). The package’s own `test_addGenotype.R`
  already feeds `stringsAsFactors = FALSE` input — the shipped factor
  object was the anomaly. **Owner chose to coerce all three columns**
  (full type-correctness), making the shipped
  `addGenotype(rhesusPedigree, rhesusGenotypes)` example produce
  correct, consistent codes.
- **Provenance → coerce-in-place:** `data/rhesusGenotypes.RData` has a
  single 2020 commit (`31c4679d`), no scripted generator, and shares all
  31 obfuscated ids with `rhesusPedigree` (re-deriving via the
  non-deterministic
  [`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)
  would change ids and desync the sibling). The new idempotent
  `data-raw/rhesusGenotypes.R` coerces the three columns via
  [`as.character()`](https://rdrr.io/r/base/character.html) and re-saves
  in place (`compress="xz"`, 734→608 bytes). The value-identical
  `inst/extdata/obfuscated_rhesus_mhc_breeder_genotypes.csv` serves as
  an independent cross-check.
- **TDD:** one pre-RED scope gate (id-only vs all-three; owner chose all
  three) + the three mandatory transitions (`PRE-RED→RED`, `RED→GREEN`,
  `GREEN→REFACTOR`). RED: wrote `test_rhesusGenotypes.R` (22 assertions
  pinning corrected types **and** preserved values — dim 31×3, names,
  unique counts 31/18/23, NA counts 0, membership spot-checks),
  confirmed it **failed** on the factor object (the 6 type assertions).
  GREEN: ran the coercion, reverted the `id` doc line
  (`factor`→`character`; `first_name`/`second_name` make no type claim),
  regenerated `man/`. REFACTOR: **N/A** (own code clean; the change
  introduced no redundant conversions — no test references the bundled
  genotype object). **0 stakeholder corrections.**
- **Verified:** new test **all-pass** (22); full-suite regression read
  **failed=0 error=0** (no offenders, baseline `test-app-`/`test-e2e-`
  included); `tools::checkRd("man/rhesusGenotypes.Rd")` **0 problems**;
  **`NAMESPACE` byte-identical**; `git diff --stat` confined to the
  intended files. **Phase-3E runtime smoke test DONE** (this is a
  runtime-behavior change):
  [`addGenotype()`](https://github.com/rmsharp/nprcgenekeepr/reference/addGenotype.md)
  runs cleanly on the **shipped corrected object** (no conversions;
  375×12, 31 genotype rows), the allele encoding is consistent (same
  allele → same code, TRUE), the coercion is idempotent (no-op on
  re-run), and the CSV cross-check confirms
  `id`/`first_name`/`second_name` all identical.
- **Flagged for the future (NOT fixed, FM \#8):** (a) **`addGenotype.R`
  is fragile to factor inputs** — it would mis-encode any
  factor-columned genotype, not just the bundled one; hardening it
  (coerce the allele columns inside the function or in
  `checkGenotypeFile`) is a separate code-fix deliverable with its own
  tests; (b) the `rhesusGenotypes` doc (`R/data.R:345`) cites a
  nonexistent source file `rhesusGenotypes.csv` — the real
  value-identical export is
  `obfuscated_rhesus_mhc_breeder_genotypes.csv` (a separate data-doc
  nit); (c) fold S124 into the CRAN Phase 3 NEWS rewrite at 2.0.0 (this
  DATA change **ships**). \[\[news-vs-changelog\]\]
  \[\[backlog-vs-changelog-placement\]\]
- **PROJECT_LEARNINGS.md:** Learning 117 added.

### 2026-06-17 — Re-exported `rhesusPedigree` with corrected canonical column types (DATA change, strict TDD) (Session 123)

- **Deliverable (owner pick A6):** S122’s audit surfaced that the
  bundled `rhesusPedigree` object ships **degraded column types** (an
  obfuscation/`stringsAsFactors`-era artifact). Re-exported the object
  so its columns carry the canonical pedigree types matching
  `examplePedigree`, **preserving every value**. This is the first item
  in the S118–S123 run that is a real **DATA change** — it touches
  `data/`, adds tests, and runs the full **RED → GREEN → REFACTOR**
  cycle (not roxygen prose). Scoped to **`data/rhesusPedigree.RData` + a
  new `data-raw/` script + `tests/testthat/test_rhesusPedigree.R` + the
  `rhesusPedigree` doc in `R/data.R` + `man/rhesusPedigree.Rd` +
  `.Rbuildignore`**; **no `NAMESPACE`/`DESCRIPTION`/`NEWS` or
  other-data-object change**.
- **Type fixes (375×8, values preserved):** `id`/`sire`/`dam` factor →
  **character**; `birth` factor-of-date-strings (282 levels) →
  **`Date`** (every level parsed cleanly; NA pattern unchanged); `exit`
  all-NA logical → **`Date`** all-NA (kept as a column —
  [`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
  reads `ba$exit`; dropping it would break that consumer). `sex` (factor
  F,M), `gen` (integer), `age` (numeric) were already correct and left
  unchanged (owner chose **Type-correctness**, not full canonical match
  — no gratuitous widening of `sex` to F,M,H,U).
- **Reproducibility (owner choice):** added committed
  **`data-raw/rhesusPedigree.R`** (+ `^data-raw$` in `.Rbuildignore`).
  The `.rda` has **no reproducible generator** (obfuscated from
  `inst/extdata/rhesusPedigree_fromCenter.csv` via
  [`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md),
  hand-saved 2020-02-02, never scripted/seeded), and the obfuscation is
  non-deterministic — so the script **coerces the existing object’s
  types without altering values** (idempotent) rather than re-deriving
  from the CSV (which would change the shipped obfuscated ids/dates).
- **TDD:** four gated `AskUserQuestion`s (pre-RED scope:
  Type-correctness; pre-RED reproducibility: add data-raw script; then
  `PRE-RED→RED`, `RED→GREEN`, `GREEN→REFACTOR`). RED: wrote
  `test_rhesusPedigree.R` (31 assertions pinning corrected types **and**
  preserved values — dim 375×8, id all-unique, sire/dam 124 NA, birth
  range 1970-07-03..2013-12-21, BRI2MW birth 1998-12-06, exit all-NA),
  confirmed it **failed** on the degraded object. GREEN: ran the
  coercion, updated the doc (id `factor`→`character`; birth
  `factor of birth-date strings`→`Date vector`; exit `logical`→`Date`),
  regenerated `man/`. REFACTOR: **N/A** (own code clean) — the
  now-redundant `as.character`/`as.Date` conversions in
  `test_getPotentialParents.R`/`test_modPotentialParents.R` are harmless
  no-ops, **flagged** for a future cleanup (out of scope, FM \#8). **0
  stakeholder corrections.**
- **Verified:** new test file **all-pass**; full-suite regression read
  **failed=0 error=0** (true offenders excl. baseline
  `test-app-`/`test-e2e-` noise: NONE);
  `tools::checkRd("man/rhesusPedigree.Rd")` **0 problems**;
  **`NAMESPACE` byte-identical**;
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  **162 exports**; `git diff --stat` confined to the intended files.
  **Phase-3E runtime smoke test DONE** (this is a runtime-behavior
  change):
  [`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
  runs cleanly on the **shipped corrected object directly** (no
  conversions; `birth` is `Date`, `id` is character; 50-element result),
  and the suite’s positional dam/sire assertions pass.
- **Flagged for the future:** (a) re-`man`/NEWS at CRAN Phase 3 — fold
  S123 into the 2.0.0 NEWS rewrite (these doc/data changes
  **ship**); (b) the redundant conversion no-ops in the two
  potential-parents test files can be removed in a later cleanup; (c)
  `data-raw/` now establishes the reproducibility pattern — other opaque
  `.rda`s (e.g. `rhesusGenotypes`) could follow.
  \[\[news-vs-changelog\]\] \[\[backlog-vs-changelog-placement\]\]
- **PROJECT_LEARNINGS.md:** Learning 116 added.

### 2026-06-17 — One-pass factual-claim audit of all 24 data docs vs live objects; fixed 9 discrepancies (Session 122)

- **Deliverable (owner pick A5, promoted to full sweep):** S121 flagged
  a 3rd same-class data-doc bug (sex factor levels) and suggested
  promoting it to a one-pass audit of all 24 data docs. Owner chose the
  **full 24-doc audit + fix** over the narrow 2-doc fix. Audited **every
  factual claim** (dims, column names, types, factor levels, counts,
  prose) in all 24 `\docType{data}` blocks against the live objects,
  fixed all confirmed discrepancies, regenerated the 4 affected `man/`
  pages. Scoped to **`R/data.R` + 4 data `man/` pages**;
  `NAMESPACE`/`DESCRIPTION`/`data/` unchanged. **TDD phase N/A**
  (roxygen prose; only `#'` comment lines changed — no executable R; RED
  vacuous; declared every response). **0 stakeholder corrections.**
  **Two gated `AskUserQuestion`s** — (1) scope: narrow vs. full sweep
  (owner chose full); (2) how to handle the 2 data-artifact findings
  (owner chose “document actual types now”).
- **Method (ultracode):** computed authoritative ground truth for all 24
  objects with one oracle probe
  ([`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
  direct inspection), then ran a workflow — **5 independent lens
  scanners** (dims/counts, column-names, types/levels, prose/crossref,
  free-roam) over all 24 docs for completeness, then an **adversarial
  refuter per unique discrepancy** (12 candidates → 10 confirmed, 2
  rejected). The adversarial pass prevented over-reach: it **rejected**
  flagging `rhesusPedigree` `sire`/`dam` (they make no type claim —
  adding “factor” would invent a correction).
- **9 fixes across 4 objects (each verified firsthand against the live
  object before authoring, Learning 109/111):** `examplePedigree`
  `\item{sex}` `"M","F","U"` → `"F","M","H","U"` (live factor has 4
  levels incl. zero-count `H`) and `\item{ancestry}` “character …
  free-form text” → “factor with levels: INDIAN, CHINESE, HYBRID,
  JAPANESE, OTHER, UNKNOWN” (a closed factor, not free-form character);
  `rhesusPedigree` `\item{id}` “character” → “factor”, `\item{sex}`
  `"M","F","U"` → `"F","M"` (no `U` level), `\item{birth}` “Date vector”
  → “factor of birth-date strings (282 levels)”, `\item{exit}` “Date
  vector” → “logical vector, all `NA` (no exit dates recorded in this
  obfuscated pedigree)”; `rhesusGenotypes` `\item{id}` “character” →
  “factor”; `qcBreeders` `@description` + `@source` “A list of …” → “A
  character vector of …” (counts 3 males/26 females confirmed correct).
  The genuinely-correct sibling claims
  (`examplePedigree`/`lacy1989Ped`/`qcPed` id as character;
  `examplePedigree` birth/exit as Date) were verified and left
  untouched.
- **Owner decision — the 2 data-artifacts (gated):** `rhesusPedigree`
  ships `birth` as a factor (not Date) and `exit` as all-NA logical (no
  dates) — the data itself looks degraded by obfuscation. Owner chose
  **document the actual types now** (docs made accurate); the underlying
  data oddity is flagged for a possible future data re-export (separate
  session, not a doc change).
- **Verified (build-equivalent for a generated-doc change):**
  `roxygenise()` regen confined to exactly the 4 intended pages
  (`git diff --stat`); **`NAMESPACE` byte-identical**
  (`git diff --quiet`);
  [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html) on the 4
  pages — **0 problems**;
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  OK (**162 exports**); full-suite regression read **failed=0 error=0**
  (189 files; 164 excluding the usually-noisy app/e2e files). **Phase-3E
  N/A** — roxygen/Rd prose changes no package/app runtime behavior. Full
  `R CMD check` not run (`devtools` absent; the above is the
  proportionate equivalent).
- **\[news-vs-changelog\]:** dev-process history → CHANGELOG here. These
  help pages **ship** → fold S122’s 9 fixes into the CRAN Phase 3 NEWS
  rewrite at 2.0.0 (flagged, not edited now).
  \[\[backlog-vs-changelog-placement\]\]
- **PROJECT_LEARNINGS.md:** Learning 115 added.

### 2026-06-17 — Repaired 2 same-class data-doc bugs flagged in S120; flagged a 3rd (sex factor levels) (Session 121)

- **Deliverable (owner pick A4):** fixed the two newly-flagged
  same-class data-doc bugs S120 found and deliberately left (FM \#8),
  then regenerated the 4 affected `man/` pages. Scoped to **`R/data.R` +
  4 data `man/` pages**; `NAMESPACE`/`DESCRIPTION`/`data/` unchanged.
  **TDD phase N/A** (roxygen prose; only `#'` comment lines changed — no
  executable R; RED vacuous; declared every response). **0 stakeholder
  corrections.** **No gated `AskUserQuestion`** — both fixes were fully
  determined by ground truth (4 distinct iteration columns;
  correctly-spaced parallel `sire` items), so per Learning 113
  over-gating was avoided (the owner’s “(A4)” pick was the
  authorization).
- **The two fixes (each verified against the live object before
  authoring, Learning 109/111):** `ped1Alleles` `\item{V2}/{V3}/{V4}`
  “iteration 1” → “iteration 2/3/4” (object 554×6; V1–V4 are 4 distinct
  columns — all 6 pairwise
  [`identical()`](https://rdrr.io/r/base/identical.html)=FALSE, 290/554
  rows differ; `\item{parent}` says “4 gene dropping iterations”; V1
  correctly stays “iteration 1”); the `dam` `\item` “column.Unknown
  dams” → “column. Unknown dams” in
  `examplePedigree`/`lacy1989Ped`/`rhesusPedigree` (R/data.R 24/97/365;
  the parallel `sire` items were already correctly spaced).
- **Adversarial verification (workflow — 2 independent refutation
  agents + 4 completeness scanners over all 24 data docs):** both fixes
  **CONFIRMED** (refuted 0/2 each; ground truth re-derived independently
  — V1–V4 distinct, `\item{parent}` corroborates “4 iterations”,
  repo-wide grep for “column.Unknown” returns NONE; source ↔︎ rendered
  `.Rd` in sync).
- **Out of scope — flagged, NOT fixed (FM \#8):** the completeness scan
  found a **third same-class bug** for a future session — the
  `\item{sex}` of both `examplePedigree` (R/data.R:25) and
  `rhesusPedigree` (R/data.R:366) claims
  `factor with levels: "M", "F", "U"`, but the live factors are
  `F,M,H,U` (examplePedigree — 4 levels, H empty) and `F,M`
  (rhesusPedigree — 2 levels, no U); neither matches. **Firsthand
  verification BROADENED the scanner’s flag** (it caught only
  examplePedigree; rhesusPedigree shares the doc text and is also wrong
  — Learning 114). All other 24-doc factual claims verified correct.
- **Verified (build-equivalent for a generated-doc change):**
  `roxygenise()` regen confined to exactly the 4 intended pages
  (`git diff --stat`); **`NAMESPACE` byte-identical**
  (`git diff --quiet`);
  [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html) on the 4
  pages — **0 problems**;
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  OK (**162 exports**); full-suite regression read **failed=0 error=0**
  (incl. the usually-noisy app/e2e files). **Phase-3E N/A** — roxygen/Rd
  prose changes no package/app runtime behavior. Full `R CMD check` not
  run (`devtools` absent; the above is the proportionate equivalent).
- **\[news-vs-changelog\]:** dev-process history → CHANGELOG here. These
  help pages **ship** → fold into the CRAN Phase 3 NEWS rewrite at 2.0.0
  (flagged, not edited now). \[\[backlog-vs-changelog-placement\]\]
- **PROJECT_LEARNINGS.md:** Learning 114 added.

### 2026-06-17 — Repaired 3 data-doc content bugs flagged in S117; flagged 2 more same-class bugs (Session 120)

- **Deliverable (owner pick A):** fixed the three adjacent roxygen
  data-doc content bugs S117 flagged but deliberately left (FM \#8),
  then regenerated the 3 affected `man/` pages. Scoped to **`R/data.R` +
  3 data `man/` pages**; `NAMESPACE`/`DESCRIPTION`/`data/` unchanged.
  **TDD phase N/A** (roxygen prose; only `#'` comment lines changed — no
  executable R; RED vacuous; declared every response). **0 stakeholder
  corrections.** One gated pre-RED `AskUserQuestion` (the only genuine
  fork — how to repair the garbled `rhesusGenotypes` fragment; owner
  chose “fill in the real count”).
- **The three fixes (each verified against the live object before
  authoring, Learning 109/111):** `examplePedigree` `\item{recordStats}`
  → `\item{recordStatus}` (real 12th column is `recordStatus`;
  `recordStats` absent); `rhesusGenotypes`’s garbled “There are object.”
  → “There are 31 rows and 3 columns.” (`dim` = 31×3, 31 unique ids,
  consistent with “Represents 31 animals” and the auto-`\format`);
  `exampleNprcgenekeeprConfig`’s “…configuration file created the
  SNPRC.” → “…created at the SNPRC.” (missing locative preposition).
- **Adversarial verification (workflow — 3 independent refutation
  agents + 1 completeness critic):** all three fixes **CONFIRMED** by
  independent ground-truth re-derivation (source ↔︎ rendered `.Rd` in
  sync; broken strings gone everywhere in `R/`+`man/`; no new issues
  introduced).
- **Out of scope — flagged, NOT fixed (FM \#8):** the completeness
  critic scanned all 24 data docs against their live objects and found
  **two more same-class bugs** for a future session: (1) `ped1Alleles`
  V2/V3/V4 `\item`s all say “iteration 1” though V1≠V2≠V3≠V4 and the
  block says “4 iterations” — should be iterations 2/3/4 (R/data.R
  134–142); (2) missing space “column.Unknown dams” in the `dam` item of
  `examplePedigree`/`lacy1989Ped`/`rhesusPedigree` (R/data.R 24/97/365;
  the parallel `sire` items are correctly spaced). All other 24-doc
  counts and `\item` names verified correct.
- **Verified (build-equivalent for a generated-doc change):**
  `roxygenise()` regen confined to exactly the 3 intended pages
  (`git diff --stat`); **`NAMESPACE` byte-identical**
  (`git diff --quiet`);
  [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html) on the 3
  pages — **0 problems**;
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  OK (**162 exports**); full-suite regression read **failed=0 error=0**
  (incl. the usually-noisy app/e2e files). **Phase-3E N/A** — roxygen/Rd
  prose changes no package/app runtime behavior. Full `R CMD check` not
  run (`devtools` absent; the above is the proportionate equivalent).
- **\[news-vs-changelog\]:** dev-process history → CHANGELOG here. These
  help pages **ship** → fold into the CRAN Phase 3 NEWS rewrite at 2.0.0
  (flagged, not edited now). \[\[backlog-vs-changelog-placement\]\]
- **PROJECT_LEARNINGS.md:** Learning 113 added.

### 2026-06-17 — Merged PR \#52: `add-methodology` → `master` (S101–S117 now on master) (Session 119)

- **Deliverable (owner instruction):** merged **PR \#52** with a merge
  commit (`gh pr merge 52 --merge`), bringing **S101–S117** into
  `master`. Owner explicitly directed the merge (delegating what S118
  had left to them). **TDD phase N/A** (VCS operation; no code
  authored). **0 stakeholder corrections.**
- **Result:** `origin/master` advanced
  `7a8433b3 → 85b3f4f6 "Merge pull request #52 from rmsharp/add-methodology"`
  — a 2-parent merge commit (parents `7a8433b3` + `55331c17`), matching
  the \#41/#43/#51 pattern. Confirmed `origin/master` now contains
  `55331c17` (S117). PR \#52 state MERGED.
- **Branch hygiene:** `add-methodology` NOT deleted (stays the ongoing
  dev branch) and NOT reconciled backward (stays linear; it now shows
  “behind” `origin/master` by the `85b3f4f6` merge bubble — normal per
  Learning 112). Pushed the held S118 close-out (`e17b62ee`) + this S119
  close-out to `origin/add-methodology`.
- **Phase-3E N/A** — branch/PR operation, no runtime behavior change.
  **No new learning** (Learning 112 already covers the topology and PR
  mechanism).

### 2026-06-17 — Open PR \#52 to merge `add-methodology` → `master` (push + open; owner merges) (Session 118)

- **Deliverable (owner pick C):** opened **PR \#52** (base `master` ←
  head `add-methodology`) to merge the 18 unmerged commits **S101–S117**
  into `master`, following the established \#41/#43/#51 PR workflow.
  Owner chose **“push + open PR, owner merges”** via a gated
  `AskUserQuestion`; I pushed and opened the PR and **stopped before
  merging** (owner reviews/merges on GitHub). **TDD phase N/A** (VCS
  operation; no code authored). **0 stakeholder corrections.**
- **Topology (discovered via `git fetch`, read-only):** local `master`
  (4790b64f) was STALE — 168 behind `origin/master` (7a8433b3 = the PR
  \#51 merge); the real target is `origin/master`. `add-methodology`
  (55331c17) and `origin/master` diverged 18-ahead / 3-behind, where the
  3 “behind” are only the PR \#41/#43/#51 merge bubbles (add-methodology
  stays linear, never pulling them back). Fork point `14032640` (S100).
  → Learning 112.
- **Actions:** `git push origin add-methodology` (fast-forward
  `ef1b86e8..55331c17`, publishing S112–S117 to the remote branch);
  `gh pr create --base master --head add-methodology` → **PR \#52**
  (OPEN, MERGEABLE, 18 commits). URL:
  <https://github.com/rmsharp/nprcgenekeepr/pull/52>. **Did NOT merge**
  — owner’s call.
- **Phase-3E N/A** — no runtime behavior change (branch/PR operation).
- **PROJECT_LEARNINGS.md:** Learning 112 added.

### 2026-06-17 — Data-doc short-`@title` rewrite: all 24 datasets given proper short titles, detail moved to `@description` (Session 117)

- **Deliverable (owner pick A2):** rewrote the roxygen TITLE of all 24
  datasets in `R/data.R` from long “X is a …” run-on sentences into
  short noun-phrase titles, moving the descriptive detail into
  `@description`; regenerated the 24 data `man/` pages. Owner chose
  **all 24 docs** (scope) and **short noun phrase, no object-name
  prefix** (style) via a gated pre-RED `AskUserQuestion`. Scoped to
  **`R/data.R` + 24 data `man/` pages**; `NAMESPACE`, `DESCRIPTION`,
  `data/` unchanged. **TDD phase N/A** (roxygen prose; no executable R
  line changed — only `#'` comments; RED vacuous; declared every
  response). **0 stakeholder corrections.**
- **The 24 new titles** span the worst offenders (`finalRpt`’s
  4-sentence title with no `@description` at all; the 6 QC error-set “…N
  rows and M columns (…) representing a full pedigree with…” run-ons) to
  the moderate “X is a …” one-liners. Examples: `pedGood` → “Valid
  example studbook (no QC errors)”; `finalRpt` → “Genetic-value report
  list prior to ranking”; `qcPed` → “Example quality-controlled baboon
  pedigree”; `smallPed` → “Hypothetical 17-animal pedigree”.
- **`qcPed` dimension claim corrected (verify-and-correct, Learning
  109/111):** the old title said “277 rows and 6 columns”; the object is
  **280×8** (and roxygen’s auto-`\format` already read 280×8 — the page
  contradicted itself). The new description states the accurate 280×8.
  Every other count-bearing doc was verified accurate against the loaded
  object before authoring.
- **`ped1Alleles` block made well-formed:** the two `## Copyright`
  comment lines that interrupted its roxygen block (between title and
  `@format`) were relocated above the block, so the block is contiguous.
- **Adversarial quality review (3-lens critic panel — accuracy /
  completeness / style+consistency):** returned **0 block, 0 should-fix,
  3 nits**. Acted on: `smallPed` retitled “Hypothetical 17-animal
  pedigree” (was a confusable near-duplicate of `lacy1989Ped`’s “Small
  hypothetical pedigree (Lacy 1989)”). Kept (owner-approved in the style
  preview): “studbook” for the 6 QC fixtures (panel preferred “pedigree”
  for file consistency — noted for future).
- **Verified (build-equivalent for a generated-doc change):**
  `roxygenise()` regen confined to exactly the 24 intended data pages
  (`git diff --stat`); **`NAMESPACE` byte-identical** to HEAD
  (`git diff --quiet`); `DESCRIPTION`/`data/` untouched;
  [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html) on all 24
  changed pages — **0 problems**;
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  OK (**162 exports**); full-suite regression read **failed=0 error=0**
  (incl. the usually-noisy app/e2e files); no stray `Rplots.pdf`.
  **Phase-3E N/A** — roxygen/Rd prose changes no package/app runtime
  behavior. Full `R CMD check` not run (`devtools` absent; the above is
  the proportionate equivalent).
- **\[news-vs-changelog\]:** dev-process history → CHANGELOG here. These
  help pages **ship**, so fold the new titles into the CRAN Phase 3 NEWS
  rewrite at 2.0.0 (flagged, not edited now).
  \[\[backlog-vs-changelog-placement\]\]
- **Out of scope (flagged, FM \#8 — not fixed):** (1)
  `examplePedigree`’s `\describe` documents `\item{recordStats}` but the
  actual column is `recordStatus` (pre-existing; surfaced by the critic
  panel and verified against the data); (2) the “studbook” vs “pedigree”
  term split for the 6 QC fixtures (owner-approved “studbook” kept;
  revisit if uniform “pedigree” preferred); (3) pre-existing wording
  bugs preserved verbatim — `rhesusGenotypes`’s garbled “There are
  object.” and `exampleNprcgenekeeprConfig`’s “created the SNPRC”; (4)
  `vignettes/articles/studbook-quality-control.qmd:91` still omits the
  `sex` column (S116’s A3 nit).
- **PROJECT_LEARNINGS.md:** Learning 111 added.

### 2026-06-17 — Adjacent doc/data-doc repair: pedGood cross-ref case, data-doc column accuracy, and 20 wrapped `@importFrom` tags (Session 116)

- **Deliverable (owner pick A):** repaired the three adjacent
  doc/data-doc bugs S115 flagged but deliberately left (FM \#8), then
  regenerated the affected `man/`. Scoped to **`R/data.R` + 10 `R/`
  source files + 6 data `man/` pages**; `NAMESPACE`, `DESCRIPTION`, and
  `data/` unchanged. **TDD phase N/A** (roxygen/data-doc prose +
  `@importFrom` source reformatting; no executable R line changed — only
  `#'` comments — so no package logic or test surface; RED vacuous;
  declared every response). **Two gated pre-RED `AskUserQuestion`s**
  (the item-2 data-vs-doc fork; the item-3 3-vs-10-file scope, posed
  after the scope/nature discovery). **0 stakeholder corrections.**
- **Item 1 — `pedgood` -\> `pedGood` cross-reference case (6×):** the
  “one of six pedigrees” boilerplate in all six error-set data docs
  (`pedDuplicateIds`, `pedFemaleSireMaleDam`, `pedGood`,
  `pedInvalidDates`, `pedMissingBirth`, `pedSameMaleIsSireAndDam`) wrote
  `\code{pedgood}`; the dataset is `pedGood`. Fixed in `R/data.R`,
  regenerated the 6 pages.
- **Item 2 — data-doc column lists corrected to the ACTUAL columns
  (owner chose full accuracy):** the five raw-fixture datasets store
  column `si.re` (and `pedOne` stores `si re`), not `sire`; the docs
  said `sire`. `si.re`/`si re` is an **intentional raw studbook-input
  fixture** — `fixColumnNames` strips spaces then periods (`si re` -\>
  `si.re` -\> `sire`) and `qcStudbook(pedGood)` returns canonical
  `sire`, confirming the messy header is what the QC pipeline exists to
  normalize. So the fix is doc-only (renaming the data would gut the
  fixture): `sire` -\> `si.re` in
  `pedGood`/`pedDuplicateIds`/`pedFemaleSireMaleDam`/`pedMissingBirth`/`pedSameMaleIsSireAndDam`.
  Also fixed `pedInvalidDates`’ separate divergence (doc said
  `(ego_id, sire, dam_id, sex, birth_date)`; data is
  `(id, sire, dam, sex, birth)` — corrected the column list and the
  `\code{birth_date}` -\> `\code{birth}` reference). Row counts verified
  already-correct. `pedOne`’s doc makes no column claim, so it needed no
  edit.
- **Item 3 — split 20 wrapped `@importFrom` tags across 10 files (owner
  chose all 10):** the flag named 3 `mod*.R` files; a codebase scan
  found **20 multi-line `@importFrom` tags across 10 files** (every
  `mod*.R` plus `appServer.R` and `appUI.R`) triggering roxygen 8.0.0’s
  `@importFrom must be only 1 line long`. **Corrected the inherited
  characterization: this is cosmetic lint, NOT a NAMESPACE hazard** — a
  reverted regen probe proved roxygen 8.0.0 still captures every
  continuation line (`NAMESPACE` byte-identical, 140 `importFrom`, 0
  removed). Split each wrapped tag into multiple single-line
  `@importFrom pkg ...` tags wrapped at \<=80 chars (matching the
  authors’ style; deterministic dry-run-first script, every before/after
  audited before writing). Regen emits **0** `@importFrom` errors.
- **Verified (build-equivalent for a generated-doc/source change):**
  `roxygenise()` regen confined to exactly the 6 intended data pages
  (`git diff --stat`); **`NAMESPACE` byte-identical** to HEAD
  (`git diff --quiet`) — proving the item-3 reformat is import-neutral;
  `DESCRIPTION` and `data/` untouched; per-page
  [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html)
  HEAD-vs-working on all 6 changed pages — **0 problems, 0 new**;
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  OK (**162 exports**); full-suite regression read **failed=0 error=0**
  (incl. the usually-noisy app/e2e files); 0 wrapped `@importFrom` tags
  remain; no stray `Rplots.pdf`. **Phase-3E N/A** — no runtime behavior
  change (doc prose + `NAMESPACE`-neutral `@importFrom` reformat; proven
  byte-identical). Full `R CMD check` not run (`devtools` absent;
  `checkRd` + `load_all` + the `NAMESPACE`/man diff + the regression
  read is the proportionate equivalent).
- **\[news-vs-changelog\]:** dev-process history -\> CHANGELOG here.
  These help pages **ship**, so fold these corrections into the CRAN
  Phase 3 NEWS rewrite at 2.0.0 (flagged, not edited now).
  \[\[backlog-vs-changelog-placement\]\]
- **Out of scope (flagged, FM \#8 — not fixed):**
  `vignettes/articles/studbook-quality-control.qmd:91` lists
  `(ego_id, si.re, dam_id, birth_date)` (correct `si.re`, but omits the
  `sex` column) — a vignette accuracy nit, separate artifact; S114’s
  still-deferred data-doc short-title rewrite (A2) — several titles
  remain long run-ons.
- **PROJECT_LEARNINGS.md:** Learning 110 added.

### 2026-06-17 — Roxygen content-bug repair: corrected 4 wrong/garbled doc descriptions S114 flagged (Session 115)

- **Deliverable (owner pick A):** repaired the four adjacent roxygen
  CONTENT bugs S114 flagged but deliberately left (FM \#8), then
  regenerated the affected `man/` pages. Scoped to **3 `R/` files (5
  edits) + 5 `man/` pages**; `data/`, `NAMESPACE`, `DESCRIPTION`
  unchanged. **TDD phase N/A** (roxygen prose; no package logic or test
  surface, so RED is vacuous; declared every response). **One gated
  `AskUserQuestion`** (a pre-RED wording/scope decision for
  `pedMissingBirth`; owner chose full accuracy). **0 stakeholder
  corrections** (one mid-session owner constraint, already satisfied —
  see below).
- **What changed (5 source edits):**
  - `R/findPedigreeNumber.R` title — was byte-identical to
    `findGeneration`’s (“Determines the generation number for each id”);
    now “Determines the pedigree number for each id” (the function
    numbers disjoint connected sub-pedigrees, the `pedNum` vector).
  - `R/convertSexCodes.R` title — “Converts sex indicator for an
    individual to a standardized codes” (number-agreement error) →
    “Converts a sex indicator for an individual to a standardized code”.
  - `R/data.R` `focalAnimals` — “containing the of animal Ids” (stray
    word) → “containing the animal Ids”.
  - `R/data.R` `pedMissingBirth` — “8 rows and 5 columns (ego_id, sire,
    dam_id, sex, birth_date) representing a full pedigree with no
    errors” → “8 rows and 4 columns (ego_id, sire, dam_id, sex)
    representing a full pedigree that is missing the birth_date column”.
    It is an error-demo set, not error-free; and the data object
    genuinely has only 4 columns (`birth_date` absent), so the old “5
    columns” was itself wrong — the auto-generated `\format` block
    already read “4 columns”, confirming the correction.
  - `R/data.R` `pedSameMaleIsSireAndDam` — “…representing a full
    pedigree with no errors” → “…representing a full pedigree in which
    the same male animal is listed as both a sire and a dam” (verified:
    male `s1` sires `o1`/`o2` and is the dam of `o3`). Column count (5)
    is correct, unchanged.
- **Ground-truth verification before editing (Learning 105/106).**
  Loaded the data objects: `pedMissingBirth` has columns
  `ego_id, si.re, dam_id, sex` and NO `birth_date` (4 columns, 8 rows);
  `pedSameMaleIsSireAndDam` row `o3` has `dam_id = s1` (a male);
  `focalAnimals` is 1 column (`id`), 327 rows. `findPedigreeNumber`
  source confirmed to assign a connected-component number, not a
  generation. Each fix states what the data actually is — not just what
  the flag named.
- **Owner constraint addressed:** mid-session the owner required
  `pedMissingBirth` to **retain the characteristic of not having a Birth
  column**. Only documentation changed — the data object is untouched
  and still has no `birth_date` column (verified post-edit: 4 columns,
  `birth_date` absent). The new doc accurately states this intended demo
  characteristic.
- **Verified (build-equivalent for a generated-doc change):** per-page
  [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html)
  HEAD-vs-working comparison on all 5 changed pages — **0 problems, 0
  new vs HEAD**;
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  OK (**162 exports** — NAMESPACE consistent); `data/` unchanged; no
  stray `Rplots.pdf`; regen confined to the 5 intended pages
  (`git diff --stat`), no roxygen version blast radius (baseline 8.0.0).
  **Phase-3E N/A** — roxygen/Rd prose changes no package/app runtime
  behavior. Full `R CMD check` not run (`devtools` absent; `checkRd` +
  `load_all` + the per-page HEAD-vs-working diff is the proportionate
  equivalent for an artifact-only change).
- **\[news-vs-changelog\]:** dev-process history → CHANGELOG here. These
  help pages **ship**, so fold these corrections into the CRAN Phase 3
  NEWS rewrite at 2.0.0 (flagged, not edited now).
  \[\[backlog-vs-changelog-placement\]\]
- **Out of scope (flagged, FM \#8 — newly discovered this session, not
  fixed):** (1) the cross-reference boilerplate in all six error-set
  data docs writes `\code{pedgood}` (wrong case; the dataset is
  `pedGood`); (2) the data objects’ actual sire column is named `si.re`
  though every doc says `sire`; (3) roxygen2 8.0.0 emits
  `@importFrom must be only 1 line long` errors for `mod*.R`
  (`modPotentialParents`, `modPyramid`, `modSummaryStats`) — multi-line
  `@importFrom` tags need splitting; (4) several data-doc titles remain
  long run-ons (S114’s deferred A2 short-title rewrite).
- **PROJECT_LEARNINGS.md:** Learning 109 added.

### 2026-06-17 — Roxygen doc-nit mop-up: cleared all 62 `\title`-period checkRd NOTEs + 3 genetic-value `@return` nits (Session 114)

- **Deliverable (owner pick A2 — full sweep):** removed the trailing
  period from every roxygen title flagged by
  [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html) as
  `\title should not end in a period` (**62 of 190 `.Rd`**: 51 function
  docs + 11 data docs), and fixed three genetic-value `@return` nits
  S112 had flagged. Then regenerated `man/`. **TDD phase N/A** (roxygen
  prose; no package logic or test surface, so RED is vacuous; declared
  every response). **One gated `AskUserQuestion`** (a pre-RED *scope*
  decision — full sweep vs. a narrower bite; owner chose the full
  sweep). **0 stakeholder corrections.**
- **What changed:** **`R/` (55 files):** 51 function files lost one
  trailing title period each; `R/data.R` lost it from 11 data-doc
  titles; `R/calcFE.R` `@return` dropped the spurious `\code{r}` clause
  (`FE = 1/sum(p^2)` uses only `p`); `R/calcFEFG.R` + `R/calcFG.R`
  `@return` closed the unbalanced paren in the FG formula
  (`sum( (p ^ 2) / r}` → `sum( (p ^ 2) / r)`). **`man/` (65 pages
  regenerated):** the 62 title pages + the 3 GV `\value` pages.
  `NAMESPACE` and `DESCRIPTION` unchanged.
- **Method (deterministic + dry-run + oracle).** The 51 single-block
  function titles were de-periodized by a dry-run-first script whose
  every before/after was audited before writing (each picked the correct
  title paragraph, incl. multi-line); `R/data.R` (11 titles) and the 3
  `@return` blocks were hand-edited. Each function file changed exactly
  one line (51 insertions / 51 deletions, no encoding rewrite).
- **Verified (build-equivalent for a generated-doc change):** a per-page
  `checkRd` comparison of all **65** changed pages vs their HEAD
  versions proved **62 pages had ONLY the title-period NOTE removed and
  0 pages gained any new problem** (the 3 GV pages changed `\value`
  prose with no `checkRd` impact). Title-period NOTEs package-wide: **62
  → 0**.
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  OK (**162 exports** — NAMESPACE consistent). No stray `Rplots.pdf`.
  **Phase-3E N/A** — roxygen/Rd prose changes no package/app runtime
  behavior. Full `R CMD check` not run (`devtools` absent; `checkRd` +
  `load_all` + the per-page HEAD-vs-working diff is the proportionate
  equivalent for an artifact-only change).
- **\[news-vs-changelog\]:** dev-process history → CHANGELOG here. These
  help pages **ship**, so fold the title/return corrections into the
  CRAN Phase 3 NEWS rewrite at 2.0.0 (flagged, not edited now).
  \[\[backlog-vs-changelog-placement\]\]
- **Out of scope (flagged, FM \#8 — period-removal left these intact):**
  copy-paste/garbled CONTENT in titles & data docs —
  `R/findPedigreeNumber.R` title duplicates `findGeneration`’s
  (“Determines the generation number for each id”);
  `pedMissingBirth`/`pedSameMaleIsSireAndDam` data docs say
  “representing a full pedigree with no errors” though they are
  error-demo sets; `focalAnimals` “containing the of animal”;
  `convertSexCodes` “to a standardized codes”. Several data-doc titles
  are now checkRd-clean but still long run-ons (a proper short-title
  rewrite is a separate task).
- **PROJECT_LEARNINGS.md:** Learning 108 added.

### 2026-06-17 — Roxygen tooling migration: adopted roxygen2 8.0.0, regenerated `man/` (Session 113)

- **Deliverable (owner pick A):** the deliberate, gated roxygen
  `7.3.2 → 8.0.0` migration that S112 isolated and deferred. Regenerated
  `man/` with the installed roxygen2 8.0.0 and migrated the
  `DESCRIPTION` version field — a small, reviewable diff (**26 `.Rd`
  pages + `DESCRIPTION`; `NAMESPACE` unchanged**), taken as its own
  deliverable rather than bundled into a content fix. **TDD phase N/A**
  (regenerating generated artifacts + a `DESCRIPTION` field migration;
  no package logic or test surface, so RED is vacuous; declared every
  response). **One gated `AskUserQuestion`** (adopt 8.0.0 vs pin 7.3.2 —
  a pre-implementation *approach* decision, not a TDD gate); owner chose
  **adopt**. **0 stakeholder corrections.**
- **What changed:** `DESCRIPTION` — `RoxygenNote: 7.3.2` →
  `Config/roxygen2/version: 8.0.0` (the 8.0.0 field rename) and the
  `Suggests` floor `roxygen2 (>= 7.3.2)` → `(>= 8.0.0)`. `man/` (26
  pages): **24 dataset docs** adopt 8.0.0’s canonical usage form
  (`\usage{ qcPed }` → `\usage{ data(qcPed) }`); `man/appUI.Rd` re-wraps
  its `\value` text (cosmetic, identical content).
- **The regen also repaired stale committed content** (drift between
  source and the committed 7.3.2 `.Rd`): `man/nprcgenekeepr-package.Rd`
  now reads `'Macaca' 'mulatta'` (the committed page had the typo
  `'mulatto'`; `DESCRIPTION` already read `mulatta`) and lists the
  maintainer **R. Mark Sharp** under Authors (he is `aut` in
  `DESCRIPTION` but was absent from the rendered list). No content was
  lost; S112’s four hand-edited `\value` pages produced **zero diff** —
  their content already matched source, the clean reconciliation S112
  predicted.
- **Verified (build-equivalent for a generated-doc change):** the
  **complete** 27-file diff was read line-by-line — every change is one
  of the four intended kinds, nothing unexpected; `NAMESPACE` unchanged
  (162 exports,
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  OK); [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html) on
  **all 26** changed pages introduces **zero new problems** — the 11
  reported `\title`-ends-in-period NOTEs are pre-existing (confirmed
  identical on the committed HEAD versions; **62 of 190** `.Rd` carry it
  package-wide). `renv.lock` unchanged (roxygen2 is a dev-only dep, not
  snapshotted). **Phase-3E N/A** — Rd/`DESCRIPTION` regeneration changes
  no package/app runtime behavior; the appropriate verification is Rd
  validity + load + full-diff audit, done. Full `R CMD check` not run
  (`devtools` absent; `checkRd` + `load_all` is the proportionate
  equivalent for an artifact-only change).
- **\[news-vs-changelog\]:** dev-process history → CHANGELOG here. These
  help pages **ship**, so fold the content repairs (typo + author list)
  into the CRAN Phase 3 NEWS rewrite at 2.0.0 (flagged, not edited now —
  the CRAN plan owns the NEWS pipeline).
  \[\[backlog-vs-changelog-placement\]\]
- **Out of scope (flagged, FM \#8):** the **62** pre-existing
  `\title`-period `checkRd` NOTEs and S112’s other A2 mop-up nits
  (`calcFE.R` `@return` mentions `r`; the unbalanced-paren `fg` formula)
  — a separate A2 session.
- **PROJECT_LEARNINGS.md:** Learning 107 added.

### 2026-06-17 — Roxygen repair: corrected drifted `@return`/`p` descriptions for the genetic-value functions (Session 112)

- **Deliverable (owner pick A2):** corrected long-drifted roxygen
  documentation, and regenerated the affected `man/` pages, for the
  genetic-value functions — fixing three confirmed `@return`/parameter
  drifts plus the identical defect in two sibling files, and **refuting
  the fourth inherited flag**. Scoped to **5 `R/` + 4 `man/` files**.
  **TDD phase N/A** (roxygen prose corrected to match already-correct
  behavior — the code was right, only the docs were wrong, so RED is
  vacuous; declared every response).
  - `R/orderReport.R` `@return` — the High-Value tier was described as
    raw “mean kinship less than 0.25, ranked by ascending mk”; it
    actually gates on the **z-score** of mean kinship
    (`zScores <= 0.25`) and orders by ascending `zScores`. Both
    `@return` bullets carried the “ascending mk” error (the second tier
    is also sorted by `zScores`); both corrected.
  - `R/calcFEFG.R`, `R/calcFG.R`, `R/calcFE.R` `@return` — `p` was
    described as “average number of descendants”; it is the vector of
    each founder’s **mean genetic contribution** to the current
    descendants (`colMeans` of the contributions matrix; verified
    `sum(p) = 1` on `lacy1989Ped`). Fixed in all three — the owner
    approved extending the agreed fix to the two `calcFE`/`calcFG`
    siblings, which share the `calcFounderContributions()` helper and
    carried the identical wording.
  - `R/reportGV.R` `@return` — said “A dataframe”;
    [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
    returns a **list** of class `nprcgenekeeprGV` with 10 named elements
    (`report`, `kinship`, `gu`, `fe`, `fg`, `maleFounders`,
    `femaleFounders`, `nMaleFounders`, `nFemaleFounders`, `total`). Now
    documents the list and its elements (verified against the
    `list(...)` constructor and the function’s own examples).
- **Re-verified the inherited flags before acting (Learning 105/106).**
  The four drifts were code-read claims (three from S108, one from S110)
  never confirmed against runtime. An 8-agent workflow (one verifier +
  one adversarial cross-checker per claim) confirmed three and **refuted
  the fourth**: `getPyramidPlot.R`’s `@return` (“the return value of
  `par('mar')`”) is **correct** — the function returns
  [`plotrix::pyramid.plot()`](https://plotrix.github.io/plotrix/reference/pyramid.plot.html)’s
  value, and `pyramid.plot` ends with `return(oldmar)` where
  `oldmar <- par("mar")`, so the returned value *is* a `par("mar")`
  vector (verified: returns `c(5.1, 4.1, 4.1, 2.1)`). Left unchanged.
  Trusting the flag would have replaced a correct `@return` with a wrong
  one.
- **`man/` regenerated without a tooling migration.** The dev `roxygen2`
  (8.0.0) is newer than the committed baseline (`RoxygenNote: 7.3.2`),
  so a full `roxygenise()` reformatted all 30 `.Rd` files and migrated
  the DESCRIPTION field. That version migration was reverted
  (`git checkout -- man/ DESCRIPTION`) and the four affected `\value`
  sections were edited surgically to match the source — keeping the
  change scoped. The 7.3.2→8.0.0 roxygen migration is flagged as a
  separate, deliberate task (coordinate with the CRAN plan).
- **Verified (build-equivalent for a doc change):**
  [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html) clean on
  all four changed pages (the one note — `reportGV.Rd` `\title` ends in
  a period — is pre-existing, on a line not touched);
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  succeeds; the rendered `\value` text reads correctly. **Phase-3E N/A**
  — documentation prose changes no package/app runtime behavior; the
  appropriate verification is Rd validity + render, done.
- **\[news-vs-changelog\]:** dev-process history → CHANGELOG here.
  Unlike the website articles, these help pages **do ship**, so this
  correction should be folded into the CRAN Phase 3 NEWS rewrite at
  2.0.0 (flagged, not edited now — the CRAN plan owns the NEWS
  pipeline). \[\[backlog-vs-changelog-placement\]\]
- **Discovered, not fixed (flagged, FM \#8):** (a) `R/calcFE.R`
  `@return` still mentions `r`, which does not appear in its
  `FE = 1/sum(p^2)` formula; (b) the formula `sum( (p ^ 2) / r}` has
  unbalanced parentheses in `calcFEFG`/`calcFG`; (c) `reportGV.Rd`
  `\title` ends in a period (`checkRd` -5).
- **PROJECT_LEARNINGS.md:** Learning 106 added.

### 2026-06-17 — Doc fix: corrected inverted focal-population description in the breeding-group article (Session 111)

- **Deliverable:** one prose fix in
  `vignettes/articles/breeding-group-formation.qmd` — the focal
  population was described as “the founders still in the colony,” but
  the filter `!(is.na(sire) & is.na(dam)) & is.na(exit)` selects
  **non-founders** (animals with at least one known parent) still in the
  colony. Corrected to “the non-founders still in the colony (those with
  at least one known parent).” Resolves the S108-discovered inversion
  (open since then; carried forward as option A’ through S109/S110).
  **One-line fix only** (FM \#18/#25). **TDD phase N/A** (documentation
  prose; no `R/` logic or test surface; declared every response).
- **Verified two ways:** (1) internal corroboration — the same sentence
  trims the pedigree to the focal set “plus the ancestors needed to
  compute their kinships,” and founders have no ancestors, so the focal
  set must be non-founders; (2) ground truth on the example data —
  `qcStudbook(examplePedigree)` then the article’s own filter yields 327
  focal animals, **none** of which are founders and **all** of which
  have at least one known parent (the studbook has 1,668 founders, zero
  in the focal set). The article re-rendered cleanly (`quarto render` —
  all 19 chunks executed; prose-only change, output unchanged).
- **\[news-vs-changelog\]:** website-only documentation = dev-process
  history → CHANGELOG only, no NEWS (the article never ships;
  \[\[backlog-vs-changelog-placement\]\]). **Phase-3E N/A** — a
  build-ignored website article changes no package/app runtime behavior;
  the appropriate verification is the render, done.
- **PROJECT_LEARNINGS.md:** Learning 105 added.

### 2026-06-17 — Quarto Hybrid §7.1: fourth Quarto article — Age-Sex Pyramid Plots (Session 110)

- **Deliverable:** a fourth Quarto pkgdown article,
  `vignettes/articles/age-sex-pyramid.qmd` — a scripted
  [`getPyramidPlot()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPyramidPlot.md)
  demographic walkthrough on the shipped `qcPed` data: building the
  pyramid, reading colony age/sex structure, the `binWidth` /
  `colorScheme` / `ageUnit` options, and the living-and-aged animal
  selection. Drop-in `.qmd` on the slice-2 mixed-mode infra (S107) — no
  new config. **One article only** (FM \#18/#25). **TDD phase N/A**
  (documentation using an existing exported function + shipped data; no
  `R/` logic or test surface; declared every response).
- **Authored ground-truth-first:** ran
  [`getPyramidPlot()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPyramidPlot.md)
  (and `fillBins`) on `qcPed` and let the actual numbers drive the
  prose. The key catch the run surfaced: the pyramid plots only the
  **living animals with a known age** — 46 of `qcPed`’s 89 living
  animals — because 43 living animals (all male) lack a birth date and
  so cannot be aged or placed. That makes the example’s apparent ~3:1
  *female* skew **reversed** from the true living population (54 males
  to 35 females) — used as the article’s honesty / QC-tie-in lesson
  (missing data can *invert* a pyramid, not just shrink it).
- **Verified end-to-end through the same paths as S107–S109:**
  `quarto render` (Quarto 1.7.33) executes the chunks on shipped data →
  clean HTML with both figures (deterministic *shape*:
  [`getPyramidPlot()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPyramidPlot.md)
  runs no simulation, needs no seed, and `qcPed` ships a fixed `age`
  column; the only nondeterministic element is the plot **title date**
  via
  [`lubridate::now()`](https://lubridate.tidyverse.org/reference/now.html)
  — a cosmetic “census on render date” label);
  `pkgdown::build_article("articles/age-sex-pyramid")` (pkgdown 2.2.0)
  wraps it in the site template; an `R CMD build` tarball confirms
  `vignettes/articles/` does **not** ship — zero CRAN risk, the 21
  shipping vignette files unaffected.
- **Adversarial review (two independent lenses — code-correctness +
  pedagogy/render-determinism):** code-correctness = ship (all 8
  challenged claims verified by re-running against `qcPed`: 280/89/46,
  35F/11M, the 43 all-male-no-birth chain, the title / left-right /
  defaults). Pedagogy = ship-with-fixes; two grounded honesty fixes
  applied + re-rendered: strengthened the sex-skew caveat to state the
  apparent skew is *reversed* (not merely inflated), and reframed the
  Reference so V&R 2015 is the *package’s* origin rather than implying
  the pyramid method derives from it (the pyramid is general demography
  via
  [`plotrix::pyramid.plot()`](https://plotrix.github.io/plotrix/reference/pyramid.plot.html)).
- **Discovered, not mine — flagged for a future session:**
  `getPyramidPlot.R` `@return` roxygen says “the return value of
  `par('mar')`” but the function actually returns
  [`plotrix::pyramid.plot()`](https://plotrix.github.io/plotrix/reference/pyramid.plot.html)’s
  value — a roxygen drift (joins the S108-discovered set); left
  untouched (FM \#8; the article documents no return value).
- **\[news-vs-changelog\]:** website-only documentation = dev-process
  history → CHANGELOG only, no NEWS (the article never ships;
  \[\[backlog-vs-changelog-placement\]\]). **Phase-3E N/A** — a
  build-ignored website article changes no package/app runtime behavior;
  the appropriate verification is render + pkgdown build + tarball, all
  done.
- **PROJECT_LEARNINGS.md:** Learning 104 added. **ROADMAP.md / analysis
  §7.1:** articles-so-far note extended to record the fourth article.

### 2026-06-17 — Quarto Hybrid §7.1: third Quarto article — Studbook Quality Control (Session 109)

- **Deliverable:** a third Quarto pkgdown article,
  `vignettes/articles/studbook-quality-control.qmd` — a scripted,
  non-Shiny walkthrough of studbook quality control
  ([`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md))
  on the shipped `examplePedigree` plus the purpose-built error-demo
  data sets: the required-column / sex-consistency / date / duplicate /
  parent-age checks, the production vs diagnostic (`reportErrors`)
  modes, and column/code standardization. Drop-in `.qmd` on the slice-2
  mixed-mode infrastructure (S107) — no new config. **One article only**
  (FM \#18/#25). **TDD phase N/A** (documentation using existing
  exported functions + shipped data; no `R/` logic or test surface;
  declared every response).
- **Authored ground-truth-first:** ran
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  on real data in BOTH modes and let the actual output drive the prose —
  `examplePedigree` (3,694 rows) → standardized 3,694-row data frame;
  `reportErrors = TRUE` returns a diagnostic list (or `NULL` when the
  studbook is clean) and each shipped error-demo set triggers exactly
  one finding (`pedFemaleSireMaleDam` → `femaleSires`/`maleDams`;
  `pedInvalidDates` → `invalidDateRows = 3,4`; `pedDuplicateIds` →
  `duplicateIds`; `pedMissingBirth` → `missingColumns`;
  `pedSameMaleIsSireAndDam` → `sireAndDam`); `reportErrors = FALSE`
  (production) auto-corrects female-sire/male-dam and removes exact
  duplicates but **stops** on missing column, invalid date, sire==dam,
  young parent, and period-in-ID. Running it corrected a wrong
  assumption — invalid dates *stop* the function; they are not silently
  coerced to `NA`.
- **Verified end-to-end through the same paths as S107/S108:**
  `quarto render` (Quarto 1.7.33) executes the chunks on shipped data →
  clean HTML (deterministic —
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  runs no simulation, needs no seed, and `examplePedigree` ships an
  `age` column so no
  [`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html) value enters the
  output; confirmed byte-identical across two renders);
  `pkgdown::build_article("articles/studbook-quality-control")` (pkgdown
  2.2.0) wraps it in the site template; an `R CMD build` tarball
  confirms `vignettes/articles/` does **not** ship — zero CRAN risk, the
  21 shipping vignette files unaffected.
- **Adversarial review (two independent lenses — code-correctness +
  pedagogy/render-determinism):** no must-fix; all nine challenged
  behavioral claims confirmed against `qcStudbook.R` + ~18 helpers, and
  render determinism confirmed empirically. Two grounded fixes applied
  and re-rendered: corrected the sex-standardization claim
  ([`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  calls `convertSexCodes(ignoreHerm = TRUE)`, folding `H` into `U` — it
  never *outputs* `H`), and added a `## Setup {#sec-setup}` section
  (house-style parallel with the two sibling articles) noting QC needs
  no seed. Left the “defensible digest” column-rename nit as-is.
- **\[news-vs-changelog\]:** website-only documentation = dev-process
  history → CHANGELOG only, no NEWS (the article never ships;
  \[\[backlog-vs-changelog-placement\]\]). **Phase-3E N/A** — a
  build-ignored website article changes no package/app runtime behavior;
  the appropriate verification is render + pkgdown build + tarball, all
  done.
- **PROJECT_LEARNINGS.md:** Learning 103 added. **ROADMAP.md / analysis
  §7.1:** articles-so-far note extended to record the third article.

### 2026-06-17 — Quarto Hybrid §7.1: second Quarto article — Genetic Value Analysis (Session 108)

- **Deliverable:** a second Quarto pkgdown article,
  `vignettes/articles/genetic-value-analysis.qmd` — a scripted,
  non-Shiny walkthrough of the genetic value analysis
  ([`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md))
  on the shipped `examplePedigree` data: quality control → population of
  interest → mean kinship and genome uniqueness → the ranked report,
  plus the colony-level founder-equivalent (`fe`) /
  founder-genome-equivalent (`fg`) diversity summaries. Content
  production enabled by the slice-2 mixed-mode infrastructure stood up
  in S107 — adding an article is a drop-in `.qmd` in
  `vignettes/articles/`, no new config. **One article only** (FM
  \#18/#25). **TDD phase N/A** (documentation using existing exported
  functions + shipped data; no `R/` logic or test surface; declared
  every response).
- **Authored ground-truth-first:** ran the actual
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  pipeline on `examplePedigree` and let the real output drive the prose
  (327-animal population of interest; 199 High Value / 128 Low Value;
  `fe` 109.67 / `fg` 47.62; the rank-1 animal has higher genome
  uniqueness but *not* the lowest mean kinship — used to illustrate why
  the ranking uses both metrics). Source-checked the scoring scheme
  directly in `orderReport.R` + `rankSubjects.R` (the High-Value
  mean-kinship tier is gated on the **z-score** ≤ 0.25, not raw mean
  kinship — the article is correct where the `orderReport` roxygen
  wording is not) and the fe/fg formulas in `calcFEFG.R` (Lacy 1989).
- **Verified end-to-end through the same two build paths as S107 + a
  tarball:** `quarto render` (Quarto 1.7.33, knitr engine) executes the
  chunks on shipped data → clean HTML, deterministic via `set_seed(1L)`
  (the gene-drop behind genome uniqueness / fe / fg is stochastic);
  `pkgdown::build_article("articles/genetic-value-analysis")` (pkgdown
  2.2.0) wraps it in the site template; an `R CMD build` tarball
  confirms `vignettes/articles/` (hence this article) does **not** ship
  — **zero CRAN risk** proven, shipped CRAN vignettes unaffected.
- **Adversarial review:** a fresh reviewer checked every
  technical/genetics claim against the code — **no must-fix errors**;
  the article is *more* correct than the package’s own roxygen in three
  places (the z-score gate, the meaning of founder contribution `p`, and
  `reportGV` returning a list rather than a data frame). Three
  low-severity precision fixes applied and re-verified against the code:
  mean kinship averages over *all* animals including self
  (`meanKinship.R`), tier-2 ranking ties break on ascending mean kinship
  (`orderReport.R`), and the imports tier also requires the animal to be
  a founder.
- **Discovered, not mine — flagged for a future session:** the sibling
  article `breeding-group-formation.qmd` (S107) comments that its focal
  set is “the founders still in the colony,” but the same filter
  `!(is.na(sire) & is.na(dam))` actually selects **non-founders**
  (animals with ≥ 1 known parent). A one-line prose inversion; left
  untouched (not this session’s deliverable; FM \#8).
- **\[news-vs-changelog\]:** website-only documentation = dev-process
  history → **CHANGELOG only**, no NEWS (the article never ships;
  \[\[backlog-vs-changelog-placement\]\]). **Phase-3E N/A** — a
  build-ignored website article changes no package/app runtime behavior;
  the appropriate verification is render + pkgdown build + tarball, all
  done.
- **PROJECT_LEARNINGS.md:** Learning 102 added. **ROADMAP.md / analysis
  §7.1:** slice-2 note extended to record the second article.

### 2026-06-17 — Quarto Hybrid §7.1 Slice 2: stand up pkgdown mixed mode + first Quarto article (Session 107)

- **Deliverable:** the second implementation slice of the adopted Hybrid
  documentation policy (analysis doc §7.1, slice 2) — stood up pkgdown
  **mixed `.qmd`/`.Rmd` mode** and authored the first Quarto pkgdown
  article, `vignettes/articles/breeding-group-formation.qmd` (a
  scripted, non-Shiny walkthrough of breeding-group formation via
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  — harem and target-sex-ratio strategies — on the shipped
  `examplePedigree` data). **One slice only** (FM \#18/#25) — slices 3–4
  are separate, owner-approved sessions. **TDD phase N/A**
  (documentation + website-config deliverable; no `R/` logic or test
  surface; declared every response).
- **What changed (zero CRAN risk):** new
  `vignettes/articles/breeding-group-formation.qmd` +
  `vignettes/articles/_quarto.yml` (`project: render: ['*.qmd']`, so
  RMarkdown keeps building the `.Rmd` vignettes); `.Rbuildignore` gained
  the single line `^vignettes/articles$` (covers the article AND the
  `_quarto.yml` AND any `.quarto/` cache — the whole dir is
  website-only); `DESCRIPTION` gained `Config/Needs/website: quarto` and
  `.github/workflows/pkgdown.yaml` a
  `quarto-dev/quarto-actions/setup@v2` step so the pkgdown CI job
  installs Quarto; `.gitignore` gained `.quarto/`.
- **Config placement corrected from the general policy note:** the
  `_quarto.yml` belongs **inside `vignettes/articles/`** (pkgdown turns
  that dir into a Quarto project), not at the package root — so one
  `.Rbuildignore` line excludes everything and the root/`.Rmd` vignettes
  are untouched.
- **Verified end-to-end through two independent build paths:** (1)
  `quarto render` (Quarto CLI 1.7.33, knitr engine) executes the
  article’s R chunks on shipped `examplePedigree` data → clean HTML,
  ~1.7 s, deterministic via `set_seed(1L)`; (2)
  `pkgdown::build_article("articles/breeding-group-formation")`
  (installed pkgdown **2.2.0** + `quarto` R pkg locally) discovers the
  `.qmd`, runs `quarto render`, and wraps it in the pkgdown template →
  clean HTML with navbar. **Zero CRAN risk proven by a real
  `R CMD build` tarball** (the `vignettes/articles/` tree is absent; the
  shipping vignettes are unaffected).
- **Article accuracy:** built around
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)’s
  own roxygen `@examples` pipeline (the code `R CMD check` already
  exercises) and source-checked — `threshold` default `0.015625` (=
  1/64, second-cousin kinship),
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  does not seed internally (hence
  [`set_seed()`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)),
  `$group` is a `numGp + 1`-element list (last = unplaced pool). One
  owner correction applied (`minParentAge = 2.0` as a float). The
  unverified “`sexRatio` in steps of 0.5” claim (an app-UI constraint,
  not enforced by the function) was removed after reading the source.
- **\[news-vs-changelog\]:** website-only documentation/config =
  dev-process history → **CHANGELOG only**, no NEWS (the article never
  ships; \[\[backlog-vs-changelog-placement\]\]). **Phase-3E N/A** — a
  build-ignored website article changes no package/app runtime behavior;
  the appropriate verification is the render + pkgdown build + tarball,
  all done.
- **PROJECT_LEARNINGS.md:** Learning 101 added. **ROADMAP.md / analysis
  §7.1:** slice 2 marked done.

### 2026-06-17 — Quarto Hybrid §7.1 Slice 1: standardize a dev doc to `.qmd` (Session 106)

- **Deliverable:** the first implementation slice of the adopted Hybrid
  documentation policy (analysis doc §7.1, slice 1) — converted the
  developer doc `inst/extdata/meeting_notes.Rmd` →
  `inst/extdata/meeting_notes.qmd` (Quarto), making the three
  `inst/extdata/` dev docs uniformly `.qmd` (`claude_code.qmd` +
  `software_design_doc.qmd` were already converted). **One slice only**
  (FM \#18/#25) — slices 2–4 are separate, owner-approved sessions.
  **TDD phase N/A** (format conversion; no code/test surface; declared
  every response).
- **Faithful, reversible change:** `git mv` (preserves history) + a
  single YAML line, `output: html_document` → `format: html` (matching
  the two sibling `.qmd`); the document body is byte-for-byte unchanged
  (`git diff -M` reports `similarity index 99%`).
- **Zero CRAN risk — verified, not assumed:** both the old `.Rmd` and
  the new `.qmd` are build-ignored (`.Rbuildignore` line
  `^inst/extdata/meeting_notes\.` is extension-agnostic, plus
  `^inst/extdata/.*\.qmd$`), so the package source tarball contents are
  unchanged. Confirmed authoritatively by applying every `.Rbuildignore`
  regex to both filenames (`ships=FALSE` for both). No `.Rbuildignore`
  edit was needed.
- **Build-equivalent (render) verified honestly:** Quarto 1.7.33 renders
  the `.qmd` to HTML via `--no-execute`. The five embedded R chunks are
  *not* reproducibly executable in any current environment — they
  hardcode 2020-era absolute machine paths
  (`/Users/rmsharp/.../20160816_GeneticManagementTools`) and need
  packages that aren’t in the default library — so this is a historical
  meeting-notes log, not a live computational document; making it
  re-executable would be a behavior change beyond a format
  standardization and was deliberately *not* done (FM \#8). The render
  limitation is stated, not silently skipped.
- **Rmd→qmd semantic difference caught by the render:** Quarto warned
  that `nprcgenekeepr:::` (an R internal-function token quoted from a
  2020 CRAN review, in prose) looked like a malformed `:::` fenced div —
  `:::` is meaningful in Quarto but inert in R Markdown. Verified in the
  rendered HTML that the text renders correctly (a heuristic
  false-positive, no output defect); left byte-faithful rather than
  rewrite the author’s historical prose for a cosmetic warning (FM
  \#22).
- **\[news-vs-changelog\]:** a developer-doc format standardization is
  dev-process history → **CHANGELOG only**, no NEWS (the file is
  build-ignored, never user-facing;
  \[\[backlog-vs-changelog-placement\]\]). **Phase-3E N/A** — converting
  a build-ignored doc changes no package/app runtime behavior; the
  appropriate verification is the render + build-ignore check, both
  done.
- **PROJECT_LEARNINGS.md:** Learning 100 added. **ROADMAP.md / analysis
  §7.1:** slice 1 marked done.

### 2026-06-17 — Decision: adopt the Hybrid documentation strategy (Quarto analysis §7 Option B) (Session 105)

- **Deliverable:** recorded the owner’s decision to adopt **Option B
  (Hybrid)** from the Session 104 analysis. Flipped
  `docs/planning/quarto-documentation-future-proofing-analysis.md` from
  “recommendation awaiting a decision” to **ADOPTED policy** (Status
  header + TL;DR + §7 table), resolved the open §6.3 manual
  sub-decision, corrected §8, and added a §7.1 implementation-slices
  table. **No documents were converted** — each slice is a separate,
  owner-approved session (FM \#18). **TDD phase N/A**
  (decision-recording / documentation deliverable, no code surface;
  declared every response).
- **Adopted policy:** the four CRAN vignettes stay on
  `knitr`/`rmarkdown` (officially supported, zero CRAN risk); new and
  non-CRAN documentation moves to Quarto — pkgdown articles via mixed
  mode, slide decks (`revealjs`), the `inst/extdata/` dev docs.
- **§6.3 manual — resolved to option (b):** the long-form manual
  (`a3manual.Rmd` + 13 `manual_components/_*.Rmd`) is repositioned onto
  the Quarto website and dropped from the CRAN vignette set. Because
  this changes what ships to CRAN, the §8 claim that “only Option A
  intersects the submission” was **corrected**: the adopted path now
  does touch the resubmission via the manual, and that slice must be
  sequenced with `cran-2.0.0-submission-plan.md`.
- **Implementation slices (analysis §7.1), recorded in the doc + ROADMAP
  only — no GitHub issues (owner’s call):** (1) standardize the third
  `inst/extdata` dev doc to `.qmd` — no CRAN risk; (2) author new
  pkgdown articles in Quarto via mixed mode — no CRAN risk; (3) slide
  decks in Quarto `revealjs` as needed — no CRAN risk; (4) reposition
  the manual — CRAN-touching, gated on resubmission coordination.
- **ROADMAP.md:** added the documentation-engine policy under “Planned.”
- **\[news-vs-changelog\]:** a documentation-process decision is
  dev-process history → **CHANGELOG only**, no NEWS (the S104
  analysis-doc precedent; \[\[backlog-vs-changelog-placement\]\]).
  **Phase-3E N/A** — recording a decision changes no runtime behavior
  (stated, not skipped).
- **PROJECT_LEARNINGS.md:** Learning 99 added.

### 2026-06-17 — Analysis: Quarto vs. R Markdown documentation future-proofing (Session 104)

- **Deliverable:**
  `docs/planning/quarto-documentation-future-proofing-analysis.md` — an
  analysis + recommendation answering the owner’s question: should the
  package’s documentation migrate from R Markdown to Quarto to
  **future-proof** it? (Owner reframed away from build timing.)
  Research-only session; **no documents were converted** (conversion
  would be a separate, owner-approved session — FM \#18).
- **Recommendation: hybrid / partial adoption.** Keep the four CRAN
  vignettes on `knitr`/`rmarkdown` (officially supported indefinitely,
  zero CRAN risk); adopt Quarto on the non-CRAN surface where it carries
  no CRAN dependency and its benefits land — the pkgdown site, new
  long-form docs, slide decks, and the `inst/extdata/` dev docs (two
  already `.qmd`). The long-form manual is flagged as a deliberate owner
  fork (keep as a knitr vignette vs. reposition onto the website as
  Quarto).
- **Evidence base:** two adversarial research Workflows (9 + 8 agents).
  All six load-bearing claims survived an explicit attempt to refute
  them at high confidence: (a) R Markdown is *not* being deprecated —
  `rmarkdown` 2.31 / `knitr` 1.51 are actively maintained CRAN-critical
  infrastructure (“not going away, no deprecation”); the only cost of
  staying is feature stagnation. (b) A Quarto CRAN vignette adds a
  `SystemRequirements` Quarto-CLI dependency that CRAN’s check machines
  don’t guarantee (missing on macOS flavors in 2025), with a documented
  transient “no vignettes” NOTE; the Quarto maintainer himself advises
  against it for CRAN vignettes. (c) For simple single-language HTML
  vignettes the realized Quarto benefit is narrow (the CRAN engine
  disables callouts/tabsets/Bootstrap/multi-language). (d) Migration is
  mechanical and reversible; pkgdown supports a mixed `.qmd`/`.Rmd` set.
- **Relationship to the CRAN plan:** does NOT change Phases 1–6 of
  `cran-2.0.0-submission-plan.md`. The deferred Phase 2b vignette-timing
  fix is precompute on the existing `knitr` engine (`.Rmd.orig` →
  committed `.Rmd`), orthogonal to a Quarto decision; Quarto cannot help
  timing (same knitr R-chunk cost + added overhead).
- **\[news-vs-changelog\]:** an analysis/planning document is
  dev-process history → **CHANGELOG only**, no NEWS (S101 plan
  precedent). **Phase-3E:** N/A — an analysis doc changes no runtime
  behavior; verification is the adversarially-verified research +
  firsthand vignette inventory, stated not skipped.
- **PROJECT_LEARNINGS.md:** Learning 98 added.

### 2026-06-17 — CRAN Phase 2a: archival timing root cause (tests) + native pipe (Session 103)

- **Deliverable:** Phase 2 of
  `docs/planning/cran-2.0.0-submission-plan.md` (§4 Phase 2) — the
  archival root cause (CRAN “tested elapsed times”). Scoped with the
  owner to **Phase 2a (tests + native pipe + NEWS)**; **Phase 2b
  (vignette rebuild timing) deferred** to a numeric-preserving
  precompute pass. **TDD phase = REFACTOR/mechanical** (no numeric
  change → RED-first did not apply; the plan’s simulation-number risk
  was avoided, not triggered).
- **Measure-first profile (cause named by data, not assumption):**
  examples 6.6s total (slowest 1.28s — none flag); the CRAN-running slow
  tests are the **shiny module `testServer` tests** (`modGeneticValue`
  4.4s / `modBreedingGroups` 4.6s / `modInput` 2.7s /
  `modBreedingGroups_groupAddAssign` 2.2s / `modPedigree_processing`
  1.2s; no `skip_on_cran`); the raw-slowest test files are
  `skip_if_not(user=="rmsharp")` (owner-only, never on CRAN); vignettes
  ~21s (deferred to 2b). Three profiling traps documented in Learning 97
  (test harness must be
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html);
  `skip_if_not(rmsharp)` guards; `NOT_CRAN`).
- **Tests:** added file-level
  [`testthat::skip_on_cran()`](https://testthat.r-lib.org/reference/skip.html)
  to the 5 slow shiny-module integration test files — removes ~15s of
  CRAN check time; they still run on CI/locally (`NOT_CRAN=true`). The
  analytical functions they exercise have their own unit tests that stay
  on CRAN.
- **Native pipe (owner-directed):** replaced the magrittr pipe `%>%`
  with the base R native pipe `|>` throughout —
  `vignettes/simulatedKValues.Rmd` (5; dropped
  [`library(magrittr)`](https://magrittr.tidyverse.org)),
  `vignettes/ColonyManagerTutorial.Rmd` (3),
  `tests/testthat/test_makeRelationsClasses.R` (2), and the
  [`makeRelationClassesTable()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeRelationClassesTable.md)
  `@examples` (2) + hand-synced `man/makeRelationClassesTable.Rd`. R≥4.1
  floor guarantees `|>`; magrittr was the vignette’s only direct user
  (never declared), so no Suggests entry was needed.
- **NEWS (owner-directed):** added a Minor-changes “Code modernization”
  bullet for the native-pipe adoption to `NEWS.Rmd`; re-rendered
  `NEWS.md` (only the new bullet changed — no reformat).
- **Verification:** full core suite via
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)
  at `NOT_CRAN=true` (CI): **169 files, 0 failed, 0 errors** (after
  installing the missing `shinyBS` Suggest in the dev lib); at
  `NOT_CRAN=false` (CRAN): the 5 mod files skip, affected-file test time
  **14.82s → 0.01s**. `simulatedKValues.Rmd` renders with the native
  pipe (no magrittr); the `makeRelationClassesTable` example runs;
  `man/*.Rd` parses; no `%>%` remains in any converted file.
- **\[news-vs-changelog\]:** the native-pipe adoption is user-facing →
  **NEWS** (done, owner-directed); the test `skip_on_cran` is dev/CI
  infrastructure → **CHANGELOG only**. **Phase-3E:** the changed code is
  executed (vignette/example/test) and was run-verified; no `R/`
  function body or app/runtime path changed (the
  `makeRelationClassesTable` edit is roxygen only) — N/A for an app
  launch, stated not skipped.
- **Discovered (NOT done — owner’s call):** `RSelenium` is
  **undeclared** (used in e2e tests, absent from Suggests); the
  `skip_if_not(user=="rmsharp")` tests run only on the owner’s machine
  (an anti-pattern); **Phase 2b (vignette rebuild timing)** remains.
- **PROJECT_LEARNINGS.md:** Learning 97 added.

### 2026-06-17 — CRAN Phase 1: static hygiene (Session 102)

- **Deliverable:** Phase 1 of
  `docs/planning/cran-2.0.0-submission-plan.md` (§4 Phase 1) — static
  CRAN hygiene (build cruft + DESCRIPTION/metadata defects + `\value`
  docs), verified by a real `R CMD build` source tarball. **No version
  bump** (Phase 3; FM \#18/#25 held — Version stays `1.1.0.9000`,
  NEWS/CITATION.cff untouched). **TDD phase = REFACTOR/mechanical** (no
  behavioral test surface).
- **`.Rbuildignore`** (+13 lines, end-anchored & paren-free per the
  perl-regex hazard): excludes macOS/R junk via `\.DS_Store$` and
  `\.Rapp\.history$` (front-unanchored, so they also catch
  `man/.DS_Store` + `inst/extdata/.Rapp.history` — the plan’s
  root-anchored form would have missed `man/.DS_Store`) plus dev-only
  `inst/extdata` files (`*.qmd`, `README_modules.md`, `example_usage.R`,
  `trulyUnknownParents.R`, `submission.txt`) and `inst/_pkgdown.yml`.
  Deleted the stale untracked `..Rcheck/` build artifact
  (owner-approved).
- **DESCRIPTION:** fixed species typo `'Macaca' 'mulatto'` →
  `'mulatta'`; moved the renv `Config/...` field from line 1 (illegally
  before `Package:`) to the end + normalized spacing;
  `VignetteBuilder: knitr, rmarkdown` → `knitr` (rmarkdown stays in
  Suggests).
- **Docs:** added `@return`/`\value` to the two exported functions that
  lacked it —
  [`appServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/appServer.md)
  (side-effect Shiny server) and
  [`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
  (returns a `shiny.tag.list`); roxygen source + hand-synced `.Rd`
  (roxygen2 unavailable until renv; Phase 4 will canonicalize).
- **LICENSE:** reconciled copyright year — `LICENSE` `2017-2021` and
  `LICENSE.md` `2017-2024` → both `2017-2026`.
- **Verification:** `R CMD build --no-build-vignettes --no-manual`
  (base-R only, no
  [`renv::restore()`](https://rstudio.github.io/renv/reference/restore.html))
  → tarball (708 entries) ships **0 cruft, 0 hidden files**; `read.dcf`
  parses with `Package:` first; both `.Rd` parse with `\value`; guard
  tests `test_appUI_version.R`/`test_getVersion.R` unaffected (verified
  by reading — no version/logic change; full suite deferred to Phase 4
  renv gate). See Learning 96.
- **\[news-vs-changelog\]:** packaging/metadata hygiene → **CHANGELOG
  only**; the user-facing NEWS rewrite is Phase 3. **Phase-3E N/A** — no
  runtime/app behavior changed (stated, not skipped).
- **PROJECT_LEARNINGS.md:** Learning 96 added.

### 2026-06-16 — CRAN 2.0.0 submission plan (Session 101)

- **Deliverable:** `docs/planning/cran-2.0.0-submission-plan.md` — a
  planning-workstream document to prepare `nprcgenekeepr` for CRAN:
  version → 2.0.0, `NEWS.Rmd` reorganized into user-facing Major/Minor
  changes since 1.0.8, and full CRAN readiness. **The plan is the
  deliverable** — no `R/`, test, `DESCRIPTION`, `NEWS.Rmd`, or
  `.Rbuildignore` change this session (FM \#18). **TDD phase N/A**
  (planning doc, no code surface).
- **Headline (firsthand-verified, reshapes the task):** the package is
  **ARCHIVED on CRAN** — `WebFetch` of the CRAN index page shows
  “Archived on 2025-07-29 as issues were not corrected in time” (last
  published 1.0.8, 2025-07-26; prior 2022-11-03 archive / 2025-04-24
  unarchive cycle). So this is a **resubmission of an archived package**
  whose root cause (CRAN example/test/vignette ELAPSED-TIME limits, per
  the R-pkg-devel thread) must be measured-and-fixed — a clean one-time
  local check is necessary-but-not-sufficient (FM \#24 at CRAN scale).
- **Method:** a 9-agent research+audit Workflow (`wy9xitgt6`, 5
  web-research over CRAN Policy / Writing R Extensions / r-pkgs.org /
  the two named skills / CRAN status + 4 read-only codebase auditors
  over DESCRIPTION+version-strings, `NEWS.Rmd`, R-CMD-check readiness,
  build cruft); the author re-fetched the pivotal CRAN-status claim
  firsthand. Plan = 6 phases (hygiene → timing root-cause → NEWS+2.0.0 →
  local `--as-cran` gate → cross-platform+cran-comments →
  post-acceptance), each a separate strict-TDD session with completion
  criteria, verification commands, and a STOP point; owner performs the
  actual CRAN upload (Phase 5 STOP).
- **Evidence-based inventory** included: every version-string location
  for the bump (+ the historical markers NOT to bump),
  DESCRIPTION/metadata defects (incl. the `'mulatta'` typo and missing
  `\value` on
  [`appServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/appServer.md)/[`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)),
  the `.Rbuildignore` gaps (`.DS_Store`, `.Rapp.history`, loose
  `inst/extdata` dev files), the three recurring false-positive NOTEs to
  pre-explain, and the no-reverse-dependencies fact.
- **\[news-vs-changelog\]:** a planning document is dev-process history
  → **CHANGELOG only**, no `NEWS` (no user-facing or package change; the
  actual NEWS rewrite is Phase 3). **Phase-3E N/A** — writing a plan
  changes no runtime behavior (stated, not silently skipped).
- **PROJECT_LEARNINGS.md:** Learning 95 added.

### 2026-06-16 — Audit of issue \#37 (exported functions not used by the app) — delta re-verification (Session 97)

- **Deliverable:**
  `docs/audits/ISSUE_37_UNUSED_EXPORTS_AUDIT_2026-06-16.md` — a
  read-only delta re-verification of \#37 against the S78 triage
  (2026-06-14). **TDD phase N/A** (no `R/`, test, `NAMESPACE`, `man/`,
  or issue-state change). **0 closes performed** (closing \#37 requires
  owner confirmation).
- **Headline — \#37’s actionable surface is fully drained:** both S78
  wire-in candidates shipped + their tracking issues CLOSED (**\#47**
  ORIP module mounted at `appUI.R:181`/`appServer.R:286`; **\#48**
  `getPotentialParents` via new `modPotentialParents` at
  `appUI.R:200`/`appServer.R:302`); the one docfix \#37 surfaced is
  fixed (`getPedDirectRelatives` `@examples`, S87 `2a64770f`); the
  logging island (`safeExecute`/`logModuleEvent`/`savePlotToFile`) still
  has **0 live callers**. Current reachability: **127 app-used / 39
  unused** = **0 wire-in · 39 keep-as-public-API · 0 retire**
  (`safeExecute` the lone conditional future-retire candidate).
- **Method note (→ Learning 92):** the renv project library isn’t
  materialized in this checkout
  ([`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)
  bootstraps an empty renv and fails), so reachability was recomputed
  statically — `sys.source` the 202 `R/*.R` files +
  [`codetools::findGlobals`](https://rdrr.io/pkg/codetools/man/findGlobals.html)
  under `Rscript --vanilla` (base lib only). **A method bug was
  caught:** `findGlobals(merge = FALSE)$functions` false-flagged
  `chooseDate` unused (it’s passed as a value to
  [`Map()`](https://rdrr.io/r/base/funprog.html) in `setExit.R:54` →
  lands in `$variables`); `merge = TRUE` is the correct conservative
  test and reconciled the result with S78.
- **Scope (Learning 91 applied at scoping):** read the issue body + its
  S65/S78 triage comments + both prior audit reports + CHANGELOG
  **before** any work → scoped a delta, not a re-run of S78’s verified
  per-function disposition. Right-sized **SOLO** under ultracode (a
  fan-out would repeat S78’s adversarially-verified triage = the
  Learning-91 redundancy).
- **Recommendation:** owner judgment — **close \#37** (no actionable
  work remains) **or keep it open + update the now-stale body** (it
  predates the wire-ins; lists 3 unused S3 methods, not the verified 4 —
  adds `summary.nprcgenekeeprGV`).
- **\[news-vs-changelog\]:** internal audit findings doc = dev-process
  history, **CHANGELOG only**, no `NEWS` (no user-facing or package
  change). **Phase-3E N/A** — read-only audit changes no runtime
  behavior (stated, not silently skipped).
- **PROJECT_LEARNINGS.md:** Learning 92 added.

### 2026-06-16 — Implemented-but-open audit of all 14 open issues (Learning 90 follow-through) (Session 95)

- **Deliverable:**
  `docs/audits/IMPLEMENTED_BUT_OPEN_AUDIT_2026-06-16.md` — a read-only
  audit classifying every open GitHub issue by implementation status to
  find any \#49-style work that shipped but was never closed. Motivated
  by S94’s discovery that \#49 had been fully implemented in S84 yet
  stayed OPEN ~10 sessions. Method: a 14-agent
  classify→adversarial-verify workflow; the two “criteria appear met”
  findings (#45, \#37) re-verified firsthand by the session. **TDD phase
  N/A** (read-only audit, no code surface). **0 closes performed**
  (closing requires owner confirmation).
- **Headline result — the implemented-but-open backlog is DRAINED:**
  **0** fully-implemented-but-open closeable candidates (no second
  \#49). Classifications: not-implemented **9** (#2, \#10, \#11, \#12,
  \#13, \#28, \#29, \#36, \#46 — genuinely unbuilt, mostly
  external-system/methodology features), policy-hold **4** (#45, \#9,
  \#5, \#1), ambiguous **1** (#37). Coverage 14/14 (100%).
- **Two owner-judgment items surfaced (not auto-closes):** **\#45**
  (umbrella — its four written acceptance criteria are met via closed
  sub-task \#31 `0eeee3f6` + spec on \#28, but it intentionally parents
  still-deferred \#28 → owner decides whether the umbrella closes);
  **\#37** (standing inventory — its only actionable wire-ins \#47/#48
  are both shipped and closed, the rest are keep-as-public-API by
  decision → owner decides whether to retire the inventory issue).
  **\#1/#5/#9** confirmed genuinely partial (a tested first increment
  shipped; a specific owner-named criterion still unmet) — correctly
  open.
- **Process note (→ Learning 91):** this audit substantially re-ran
  S62’s `docs/audits/BACKLOG_STALENESS_AUDIT_2026-06-12.md` (same
  question, all then-open issues, 4 days prior). The right scope was a
  delta against that baseline; the prior audit + the CHANGELOG/handoff
  record of the issue-by-issue drain (#4/#33/#49) should have been
  checked at Phase 1 before a full sweep. Owner directed: keep the
  report as-is (it stands as the firsthand “no second \#49”
  confirmation + S62 trend comparison).
- **\[news-vs-changelog\]:** internal audit findings doc = dev-process
  history, **CHANGELOG only**, no `NEWS` (no user-facing or package
  change). **Phase-3E N/A** — read-only audit changes no runtime
  behavior (stated, not silently skipped).
- **PROJECT_LEARNINGS.md:** Learning 91 added.

### 2026-06-16 — Complete the `fillBins()` `@return` documentation (#33) (Session 92)

- **Deliverable:** Completed the `@return` roxygen for the `@noRd`
  internal `fillBins()` (`R/fillBins.R:6`) — replaced the
  `#' @return A list with two TODO: RMS provide description` placeholder
  with a `\describe{}` block documenting both returned elements
  (`males`/`females` = integer vectors of counts per age bin).
  **Docs-only on a non-exported internal** (no `R/` behavior, NAMESPACE,
  `man/`, or DESCRIPTION change). Workstream = development under
  **Strict TDD** — phase declared every response; gates via
  `AskUserQuestion` (pre-RED test-approach scope, PRE-RED→RED,
  RED→GREEN, GREEN→REFACTOR); **0 stakeholder corrections**.
- **RED driver (since `@noRd` ⇒ no `man/*.Rd` for the S87 `Rd2ex`
  pattern):** a doc-completeness test in
  `tests/testthat/test_fillBins.R` reads `R/fillBins.R` via
  `testthat::test_path("..","..","R","fillBins.R")` with
  `skip_if(!file.exists(...))` for the installed context, **extracts
  only the `@return` block** (between the `@return` tag and the next
  roxygen tag), and asserts no `TODO` plus both
  `\bmales\b`/`\bfemales\b` — scoping to the block so the title’s
  existing `\code{males}`/`\code{females}` can’t falsely satisfy it (3
  failures RED at HEAD, all for the right reason; the failure output
  proved the extractor isolated only the `@return` line).
- **Contract-lock guard (green at HEAD, honestly classified):** a
  behavioral `test_that` asserting `fillBins(pedOne, seq(0L,20L,5L))`
  returns a list named `c("males","females")`, both `expect_type`
  `"integer"`, `expect_length == length(lowerAges)` — verifies the docs
  match real behavior and guards future drift.
- **Verification:** `test_fillBins.R` 11/11 green;
  `devtools::document()` produced **no** NAMESPACE/`man/`/DESCRIPTION
  change (confirms the `@noRd` path); `lintr` 0 on `R/fillBins.R` and
  the test file; full clean-regression read **0 failed / 0 error** (5
  warnings = the designed `loadSiteConfig` safety-net logs; 169 skips).
  **\[news-vs-changelog\]:** `@noRd` internal docs never render to a
  user-facing man page → **CHANGELOG only**, no `NEWS`. Phase-3E
  (runtime smoke test) **N/A** — a roxygen comment on a `@noRd` internal
  changes no runtime behavior (stated, not silently skipped). \#33 left
  OPEN pending owner confirmation.

### 2026-06-16 — Behavioral upload-path regression tests for \#4; close \#4 (Session 90)

- **Deliverable:** Finalized issue **\#4** — CLOSED it on owner
  confirmation (the fix shipped in S89, `8a3e3631`, was
  Phase-3E-verified) and added behavioral regression coverage for the
  Shiny UPLOAD path that S89 had covered only structurally (a
  `deparse(body(modInputServer))` grep). Two NEW test files;
  **test-only** (no `R/`/NAMESPACE/`man/`/DESCRIPTION change).
  Workstream = development under **Strict TDD** — phase declared every
  response, gates via `AskUserQuestion` (pre-RED scope, PRE-RED→RED,
  RED→GREEN, GREEN→REFACTOR, **+ a mid-GREEN reframe** when
  investigation changed what was testable), **0 stakeholder
  corrections**.
- **NEW `tests/testthat/test_modInput_incomplete_final_line.R` (normal
  suite, in-process):** drives `modInputServer`’s `getData` observer via
  [`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)
  with a TINY (4-line) no-trailing-newline upload through both reader
  branches (read.csv + read.table) and asserts (a) the
  `"incomplete final line"` warning does NOT escape the read and (b) all
  3 founder records survive QC. **Carries the fix-specific teeth:**
  un-muffling either read site makes both blocks RED (round-trip
  verified S90); restoring → green.
- **NEW `tests/testthat/test-e2e-input-incomplete-final-line.R` (opt-in
  `NPRC_RUN_E2E`, browser):** drives the assembled app via
  [`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html),
  uploads a no-trailing-newline copy of `ExamplePedigree.csv` through
  both reader paths, and asserts the cleaned studbook flows end-to-end
  into the Pedigree Browser table (all **3,694** records). Full-stack
  data-integrity net.
- **Key discovery (drove the two-test design; cost several cycles):**
  the `"incomplete final line"` warning is (1) a *console-only* artifact
  that never reaches the DOM or `app$get_logs()` in the assembled app,
  AND (2) only fires for *small* files — `read.table`/`read.csv` warn
  only when the header/type-detection scan actually reaches the
  unterminated final line, so a realistic-size file (e.g. 3694-row
  `ExamplePedigree.csv`) never triggers it. ⇒ the warning-suppression
  cannot be teeth-tested in a browser; the **testServer** test (tiny
  fixture, in-process where the warning IS observable) owns that teeth,
  and the **browser E2E** owns end-to-end processing.
- **Verification:** testServer test 6/6 green; teeth round-trip
  (un-muffle both sites → both blocks RED → restore → green) confirmed;
  browser E2E 2/2 green (opt-in, drives the INSTALLED app via real
  Chrome); full clean-regression read **0 failed / 0 error** (195 files;
  5 warnings = the designed `loadSiteConfig` safety-net logs); all test
  lines ≤80. **Phase-3E:** the browser E2E IS the runtime verification
  (drove the installed app); the testServer test drives the real module
  server. **Issue \#4 CLOSED.**
- **\[news-vs-changelog\]:** test-only (the user-facing fix landed in
  NEWS at S89) → **CHANGELOG only**.
- **PROJECT_LEARNINGS.md:** Learning 88 added.

### 2026-06-16 — Fix \#4: suppress the “incomplete final line” warning on files with no trailing newline (Session 89)

- **Deliverable:** Fixed issue **\#4** — reading an animal list or
  pedigree file whose final line lacks a trailing newline emitted
  `"incomplete final line found by readTableHeader on '...'"`
  (originally reported from a Shiny text upload, `0.txt`). Reproduced
  firsthand that this is **noise, not data loss**: every row, including
  the last, is read correctly (`nrow == 3`); only the warning is the
  problem. Owner chose the **root-cause fix across all readers via a
  shared helper** (over fixing only the reported upload path).
  Workstream = development under **Strict TDD** — phase declared every
  response, **3 gates** via `AskUserQuestion` (PRE-RED→RED, RED→GREEN,
  GREEN→REFACTOR) **+ a separate pre-RED scope question**
  (all-readers-via-helper vs named-readers vs app-only), **0 stakeholder
  corrections**.
- **RED:** NEW `tests/testthat/test_muffleIncompleteFinalLine.R` (7
  tests): helper unit teeth — a no-trailing-newline read emits **no**
  warning *and* preserves every row; an unrelated `warning("...")`
  **still propagates** (proves it is surgical, not blanket
  `suppressWarnings`); the helper returns `expr`’s value unchanged.
  Integration —
  [`getPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedigree.md)/[`getGenotypes()`](https://github.com/rmsharp/nprcgenekeepr/reference/getGenotypes.md)
  emit no warning + preserve rows;
  [`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md)
  emits no `"incomplete final line"` warning (its post-read LabKey call
  returns an error list without a DB; the unrelated config-missing
  warning is acceptable); and `modInputServer`’s body references the
  helper (structural lock for the server-internal `readDataFile`
  closure). All 7 failed at HEAD for the right reason (helper missing →
  3 errors; readers still warn → fail; body lacks the wrap → fail).
- **GREEN:** NEW non-exported `@noRd` internal helper
  `R/muffleIncompleteFinalLine.R` =
  `withCallingHandlers(expr, warning = ...)` that
  `invokeRestart("muffleWarning")` **only** when `conditionMessage`
  matches `"incomplete final line"` (all other warnings propagate).
  Wrapped the read call at each of the four sites: `getPedigree.R`,
  `getGenotypes.R` (`read.table`), `getFocalAnimalPed.R` (`read.csv`),
  and `modInput.R`’s `readDataFile` (both the text `read.table` and CSV
  `read.csv` branches). No new imports (base functions). `document()`
  produced **no** NAMESPACE/`man/`/DESCRIPTION change (helper is
  `@noRd`; reader signatures unchanged). **REFACTOR = confirmed no-op**
  (helper + wraps already minimal/idiomatic/lint-clean).
- **Verification:** new file **7/7 green** (12 expectations); full
  clean-regression read **0 failed / 0 error** (192 files, 1046 tests,
  167 skips; the 5 warnings are S85’s designed `loadSiteConfig`
  safety-net logs); `lintr` **0 lints** on all 5 changed `R/` files.
  **Phase-3E = PERFORMED, PASS:** `devtools::install()` then exercised
  the exported readers in the **installed** package —
  `getPedigree`/`getGenotypes` on no-newline files emit no warning and
  preserve all rows; `getFocalAnimalPed` no longer emits the
  incomplete-final-line warning **but its unrelated config-missing
  warning still propagates** (surgical proof); a control file *with* a
  trailing newline still reads cleanly.
- **\[news-vs-changelog\]:** user-facing file-reading bug fix → **BOTH**
  `NEWS.Rmd`→`NEWS.md` (new bullet under `1.1.0.9000` → Data input /
  quality control; rendered from source, diff = only that bullet)
  **and** this CHANGELOG entry. **Issue \#4 left OPEN** pending owner
  confirmation (standing close-only-on-owner-confirmation rule).
- **PROJECT_LEARNINGS.md:** Learning 87 added.

### 2026-06-16 — Housekeeping: About-tab version derived from DESCRIPTION (stale “Version 1.0.8” → dynamic getVersion()) (Session 88)

- **Deliverable:** Replaced the stale hard-coded `Version 1.0.8` strings
  (carried since S56) with the current package version. The runtime fix:
  the Shiny **About** panel (`R/appUI.R:230`) now renders
  `paste("Version", getVersion(date = FALSE))`, reusing the existing
  exported
  [`getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md)
  helper (which reads `packageVersion("nprcgenekeepr")`) so the
  displayed version tracks `DESCRIPTION` (`1.1.0.9000`) and can never
  drift again — the root-cause fix the owner chose over a hard-coded
  literal. The `CLAUDE.md` project-overview prose was updated to
  `1.1.0.9000` as a plain doc edit. Workstream = development under
  **Strict TDD** — phase declared every response, 3 gates via
  `AskUserQuestion` (PRE-RED→RED, RED→GREEN, GREEN→REFACTOR) + a
  separate pre-RED approach question (dynamic vs hard-coded), **0
  stakeholder corrections**.
- **RED:** NEW `tests/testthat/test_appUI_version.R` renders
  `as.character(appUI())` and, **scoped to the About panel** (the region
  following its `About GeneKeepR` heading), asserts it shows
  `Version <packageVersion>` and not the stale `Version 1.0.8`. Scoping
  was essential: the app already shows a *dynamic* version in its title
  bar (`appUI.R:47`,
  [`getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md)
  with build date), so an un-scoped positive assertion was a **false
  pass** at HEAD — it matched the title-bar string, not the About tab.
  After scoping, both assertions failed for the right reason at HEAD.
- **GREEN (2 edits, no `document()`):** `R/appUI.R:230`
  `p("Version 1.0.8")` →
  `p(paste("Version", getVersion(date = FALSE)))`; `CLAUDE.md` overview
  `(Version 1.0.8)` → `(Version 1.1.0.9000)`. Body-only change to
  [`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
  → no `.Rd`/NAMESPACE/DESCRIPTION change (`utils` already imported;
  `getVersion` already exported). **REFACTOR = confirmed no-op** (the
  fix reuses the existing helper and is minimal/idiomatic).
- **Verification:** new test 3/3 green; full clean-regression read **0
  failed / 0 error** (5 warnings = the designed `loadSiteConfig`
  safety-net logs from S85); `lintr` **0 lints** on `R/appUI.R`.
  **Phase-3E = PERFORMED, PASS:** `devtools::install()` + a
  [`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html)
  boot of the **installed** stock app confirmed the live About panel
  renders `<p>Version 1.1.0.9000</p>` with the stale `1.0.8` absent.
- **\[news-vs-changelog\]:** user-facing (the displayed app version) →
  **BOTH** `NEWS.Rmd`→`NEWS.md` (new bullet under `1.1.0.9000` → Shiny
  application; rendered from source, diff = only that bullet) **and**
  this CHANGELOG entry.
- **PROJECT_LEARNINGS.md:** Learning 86 added.

### 2026-06-16 — Docfix sweep: roxygen @examples corrections + dedicated tests for two zero-coverage functions (Session 87)

- **Deliverable:** Owner-scoped **full sweep + tests**. (1) Corrected
  the roxygen `@examples` for three exported functions whose documented
  example never invoked the function it documents; (2) added dedicated
  unit tests for
  [`kinshipMatrixToKValues()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinshipMatrixToKValues.md)
  and
  [`getAncestors()`](https://github.com/rmsharp/nprcgenekeepr/reference/getAncestors.md),
  which previously had **zero direct test references** in
  `tests/testthat/`. Workstream = development (documentation + test
  backfill) under **Strict TDD** — phase declared every response, 3
  gates via `AskUserQuestion` (PRE-RED→RED, RED→GREEN, GREEN→REFACTOR) +
  a separate pre-RED scope question, **0 stakeholder corrections**.
- **Evidence-based scope (read-only sweep across all exported
  functions):** 5 functions had an `@examples` block that never calls
  its own function; 3 are real defects, 2 are S3-dispatch false
  positives (`summary.nprcgenekeeprErr` /
  `print.summary.nprcgenekeeprErr`, correctly demonstrated via the
  [`summary()`](https://rdrr.io/r/base/summary.html)/auto-print generic
  — left untouched).
- **@examples fixes (3, GREEN):** `getPedDirectRelatives` (severe —
  example called `getLkDirectRelatives(ids = ...)`, the wrong function,
  and omitted the required `ped`; now
  `getPedDirectRelatives(ids = "E", ped = nprcgenekeepr::lacy1989Ped)`);
  `cumulateSimKinships` (final call was `createSimKinships(...)` → now
  `cumulateSimKinships(ped, allSimParents, pop, n = 10)`);
  `getIdsWithOneParent` (added a closing `getIdsWithOneParent(p)` call).
  `document()` regenerated only the 3 corresponding `man/*.Rd`;
  NAMESPACE unchanged (no new exports).
- **RED:** NEW `tests/testthat/test_examples_invoke_documented_fn.R`
  extracts each function’s `@examples` from `man/<fn>.Rd` via
  [`tools::Rd2ex`](https://rdrr.io/r/tools/Rd2HTML.html) (skips under an
  installed package with no `man/`) and asserts the example calls
  `<fn>(`, plus that `getPedDirectRelatives` does **not** call
  `getLkDirectRelatives(`. 4 assertions failed for the right reason at
  HEAD; all GREEN after the fixes.
- **Coverage backfill (honest degenerate cycle, declared):** NEW
  `tests/testthat/test_kinshipMatrixToKValues.R` (shape, `n + n(n-1)/2`
  row count, orientation-agnostic coefficient lookups, named/unnamed
  matrices) and `tests/testthat/test_getAncestors.R` (founder/NA →
  `character(0)`, one- and multi-generation lineages with exact order +
  setequal, and a `createPedTree(lacy1989Ped)` integration check). The
  functions already ship correctly, so these pass from the start;
  expected values were independently hand-derived and **teeth-checked**
  (perturbing an expected value fails).
- **Verification:** all 3 fixed examples run clean end-to-end
  ([`tools::Rd2ex`](https://rdrr.io/r/tools/Rd2HTML.html) → `source`),
  the docs build-equivalent per SAFEGUARDS; full clean-regression read
  **0 failed / 0 error** (the 5 warnings are the designed
  `loadSiteConfig` safety-net logs from S85); `lintr` **0 lints** on the
  3 changed `R/` files; new test files ≤80 cols by hand (`.lintr`
  excludes `tests/`). **REFACTOR = confirmed no-op** (edits and tests
  already minimal and idiomatic). **Phase-3E runtime smoke = N/A** —
  documentation + tests only, no runtime behavior change (stated, not
  silently skipped).
- **\[news-vs-changelog\]:** the `getPedDirectRelatives` example was a
  user-facing help defect (wrong function shown in
  [`?getPedDirectRelatives`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md))
  → **BOTH** `NEWS.Rmd`→`NEWS.md` (new Documentation bullet under
  `1.1.0.9000` Minor changes; rendered from source, diff = only that
  bullet) **and** this CHANGELOG entry.
- **PROJECT_LEARNINGS.md:** Learning 85 added.

### 2026-06-16 — Durable opt-in E2E for the ONPRC-gated ORIP Reporting tab (#47, \#49, Session 86)

- **Deliverable:** NEW `tests/testthat/test-e2e-orip-module.R` — a
  durable, opt-in (`NPRC_RUN_E2E=true`) browser-driven regression test
  for the **ORIP Reporting** tab wired in S83 (#47) and ONPRC-gated in
  S84 (#49). Drives the assembled modular app
  ([`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)/`appServer`)
  through
  [`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html)
  and asserts the build-time gate **end-to-end, both polarities**.
  Workstream = development (regression backfill) under **Strict TDD** —
  phase declared every response, 3 gates via `AskUserQuestion`, **0
  stakeholder corrections**. **Test-only — no `R/`, `man/`, `NAMESPACE`,
  or `NEWS` changes.**
- **Four opt-in blocks** (each
  `skip_if_not_installed("shinytest2"/"chromote")` + `skip_on_cran()` +
  the `create_test_app()` opt-in gate): (1) **ONPRC config → tab
  accessible** (active pane + the module’s unique body text); (2)
  **ONPRC → content + download** — `#oripReporting-siteInfo` reports
  `Center=ONPRC`, the Export ORIP Report button is present, and
  `app$get_download("oripReporting-downloadORIPReport")` yields a
  `Category/Metric/Value` CSV with a `Center=ONPRC` Site row
  (deterministic — the handler writes the Site section even with no
  pedigree loaded); (3) **no config (stock app) → tab ABSENT**
  (`navigate_to_tab` returns FALSE AND `oripReporting-` absent from the
  body); (4) **SNPRC config → tab ABSENT** (proves the gate keys on
  `center`, not mere config presence).
- **Config-injecting fixture:** a local `build_config_app_dir(center)`
  writes a temp `app.R` that
  `Sys.setenv(HOME=<temp dir with a complete documented-format .nprcgenekeepr_config>)`
  BEFORE `shinyApp(appUI(), appServer)` — S84/S85’s HOME-override
  Phase-3E recipe promoted to a reusable test fixture (the positive case
  can’t use the stock app, which has no config → tab hidden; the
  no-config negative case rides the stock `create_test_app()` app for
  free). It reuses the opt-in gate by calling `create_test_app()` for
  its skip side-effect — **no change to the shared
  `helper-shinytest2.R`**.
- **RED (honest degenerate cycle):** behavior already ships, so RED =
  author teeth-bearing assertions + confirm all 4 blocks self-skip
  cleanly with opt-in OFF (`SSSS`, 0 fail/error) — no literal
  red-to-green.
- **GREEN:** independently confirmed the three gate outcomes in-process
  FIRST
  ([`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
  parse →
  [`shouldShowOripTab()`](https://github.com/rmsharp/nprcgenekeepr/reference/shouldShowOripTab.md):
  ONPRC→TRUE, SNPRC→FALSE, no-config→FALSE),
  `devtools::install(quick=TRUE)`, then ran all 4 blocks with
  `NOT_CRAN=true NPRC_RUN_E2E=true` against the installed app → **9/9
  expectations PASS** (real Chrome via `chromote`).
- **REFACTOR:** reflowed 6 over-length lines to ≤80 (split the long
  `lkPedColumns` config line into the shipped example config’s
  multi-line format); re-verified parsing + a fresh 9/9 browser run.
- **Verification:** full clean-regression read **0 failed / 0 error**
  with this file **4-skipped** in the normal (opt-in-off) run; `lintr`
  clean (`tests/` is excluded in `.lintr`, consistent with prior
  sessions). The browser E2E run IS the Phase-3E runtime verification
  (FM \#24 answered head-on).
- **\[news-vs-changelog\]:** test-only addition (no `R/` code, no
  user-facing feature; the ORIP feature itself landed in `NEWS.md` at
  S83/S84) → **CHANGELOG only**.
- **PROJECT_LEARNINGS.md:** Learning 84 added.

### 2026-06-15 — Fix modular-app boot crash on a documented-format config file (#50, Session 85)

- **Deliverable:** Fixed **\#50** — the modular app’s config-loading
  observer (`R/appServer.R:58-68`) used
  `read.table(configFile, header=TRUE, sep="=")`, which cannot parse the
  **documented** config format
  (`inst/extdata/example_nprcgenekeepr_config`: comment lines, blank
  lines, multi-line / quoted / comma-separated values) and stopped with
  *“line N did not have 2 elements”*. The observer was not wrapped in
  `tryCatch`, so the error propagated and
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  failed to reach a stable state on boot for any deployment with such a
  config file present. Workstream = development under **Strict TDD** —
  phase declared every response, 3 gates via `AskUserQuestion` + a
  separate pre-RED approach question, 0 stakeholder corrections.
- **Decision (owner, via `AskUserQuestion`):** **Single source of
  truth** (issue’s suggested fix \#1) over a minimal `tryCatch`-only
  patch — parse via the tolerant
  [`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
  path so documented-format configs actually load, not merely fail-soft.
  Safe because `shared$config` is passed to
  `modInputServer`/`modPedigreeServer` but **referenced by neither
  module body** (verified by grep), so changing its shape from
  data.frame to the
  [`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
  named list has no runtime consumer impact.
- **RED:** NEW `tests/testthat/test_loadSiteConfig.R` (5 tests / 8
  expectations): no-file → `NULL`; documented
  `example_nprcgenekeepr_config` → list with `center=="SNPRC"` &
  `lkPedColumns>=6` (THE crash case); malformed config (missing
  `center`) → `NULL`, no throw (`tryCatch` safety net); a
  characterization guard that `read.table(sep="=")` errors on the
  documented file (root-cause lock, green throughout); and a structural
  `deparse(appServer)` assertion (uses `loadSiteConfig`, not
  `read.table`). The behavioral + structural assertions failed for the
  right reason at HEAD (undefined function / observer still on
  `read.table`); the characterization guard passed.
- **GREEN (2 edits + document()):** NEW exported `R/loadSiteConfig.R` =
  `getConfigFileName(Sys.info())` → `NULL` if no file, else
  `tryCatch(getSiteInfo(expectConfigFile = FALSE), error → flog.warn + NULL)`;
  rewrote the `appServer` observer to
  `shared$config <- loadSiteConfig()`. `document()` regenerated
  NAMESPACE export + `man/loadSiteConfig.Rd`. **REFACTOR:** added a
  bidirectional `@seealso \link{loadSiteConfig}` to `appServer`’s
  roxygen (re-documented); no behavior change.
- **Verification:** new tests 8/8 green; full clean-regression read **0
  failed / 0 error**; `lintr` **0 lints** on all 3 changed files (the
  transient `object_usage` warning for the brand-new function cleared
  after `devtools::install()`).
- **Phase-3E (runtime smoke): PERFORMED — PASS.** `AppDriver` boot of
  the installed app with the **real documented
  `example_nprcgenekeepr_config` (SNPRC) present**
  (HOME-override-in-`app.R` recipe) — the exact file that crashed boot
  before. App reached a stable state (`mainNavbar`=“Home”), navigation
  to “Genetic Value Analysis” worked, **0** `read.table`/“did not have 2
  elements” crash lines, **0** non-`shinyBS` error-level logs. This is
  the boot S84 had to sidestep with a stripped single-line config; the
  documented format now boots clean.
- **\[news-vs-changelog\]:** user-facing (a startup-crash bug fix) →
  **BOTH** `NEWS.Rmd`→`NEWS.md` (new bug-fix bullet under `1.1.0.9000`,
  rendered from source; diff = only that bullet) **and** this CHANGELOG
  entry.
- **PROJECT_LEARNINGS.md:** Learning 83 added.

### 2026-06-15 — Gate the ORIP Reporting tab to ONPRC-only (#49) + owner-confirmed close of \#47 (Session 84)

- **Deliverable (1):** Owner-confirmed close of **\#47** (the ORIP
  wire-in shipped S83). The owner accepted the always-visible v1; **\#47
  CLOSED** with a comment referencing commit `6fd16715` and the 13/13
  Phase-3E smoke, noting the ONPRC-gating follow-up is \#49.
- **Deliverable (2):** Implemented **\#49** — the **ORIP Reporting** tab
  is now shown **only for ONPRC**. Workstream = development under
  **Strict TDD** — phase declared every response, 3 gates via
  `AskUserQuestion` + a separate pre-RED scope/approach question, 0
  stakeholder corrections.
- **Decisions (owner, via `AskUserQuestion`):** (a) **Hide unless a real
  ONPRC config** — show only when an actual config file exists AND its
  `center` is ONPRC; the
  [`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
  default fallback (`center="ONPRC"` with no file, true in dev/CI) hides
  the tab. (b) **Build-time conditional `tabPanel`** (not dynamic
  `insertTab`) — the deployment center is fixed per server and
  [`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
  is evaluated once at construction, so the tab’s presence is a
  per-deployment constant.
- **RED:** NEW `tests/testthat/test_shouldShowOripTab.R` (5
  pure-predicate cases) + rewrote
  `tests/testthat/test_modORIPReporting.R` to inject a `siteInfo` list
  and assert the tab is PRESENT under ONPRC+real-file and ABSENT under
  SNPRC / no-file, plus a `deparse(appServer)` assertion that the server
  mount is gated on `shouldShowOripTab`. All failed for the right reason
  (undefined function / unused `siteInfo` arg / un-gated mount).
- **GREEN (3 edits):** NEW exported `R/shouldShowOripTab.R`
  (`isTRUE(hasConfigFile) && isTRUE(center == "ONPRC")`, mirroring
  `shouldShowChangedColsTab`); parameterized
  `appUI(siteInfo = getSiteInfo(expectConfigFile = FALSE))` with a
  conditional ORIP `tabPanel`; gated the `modORIPReportingServer` mount
  in `appServer.R` on the same predicate. `document()` regenerated
  NAMESPACE + `man/`. REFACTOR = no-op (kept the inline-call idiom; no
  helper extraction).
- **Verification:** new tests pass (5/5 + 4/4); full clean-regression
  read **0 failed / 0 error**; `lintr` **0 lints** on all 5 changed
  files (the transient `object_usage` warning for the brand-new function
  clears once the package is installed).
- **Phase-3E (runtime smoke): PERFORMED — PASS (3/3 scenarios).**
  `AppDriver` boots of the installed app under three real config-file
  scenarios (each generated `app.R` sets `HOME` to a temp config dir):
  **ONPRC** → tab present, navigable, all 5 ORIP outputs register
  values, 4 siblings intact; **SNPRC** → tab absent (UI + server),
  siblings intact; **no config** → tab absent, siblings intact. 0
  ORIP-namespaced errors (only the pre-existing app-wide `shinyBS`
  noise).
- **Discovered (out of scope) → filed \#50:** the pre-existing
  config-loading observer (`appServer.R:63`, from commit `6457a3a3`)
  calls `read.table(configFile, header=TRUE, sep="=")`, which CANNOT
  parse the documented config format (comments, blank lines, multi-line
  quoted values) and **crashes the modular app on boot** whenever such a
  config file is present. Surfaced by this session’s Phase-3E (first app
  boot WITH a config file). NOT fixed here (unrelated to \#49); filed as
  **\#50**.
- **\[news-vs-changelog\]:** user-facing (visible-tab behavior change) →
  **BOTH** `NEWS.Rmd`→`NEWS.md` (ORIP bullet augmented with the
  ONPRC-gating note, rendered from source; diff = only that bullet)
  **and** this CHANGELOG entry.
- **PROJECT_LEARNINGS.md:** Learning 82 added.

### 2026-06-15 — Wire in the ORIP Reporting module (#47, Session 83)

- **Deliverable:** Mounted the existing-but-unwired `modORIPReporting`
  module pair into the application — a new **ORIP Reporting** tab (after
  Summary Statistics). Two production edits: `R/appUI.R` (`tabPanel`
  with `modORIPReportingUI("oripReporting")`) and `R/appServer.R`
  (`modORIPReportingServer("oripReporting", pedigree=…, geneticValues=…, siteConfig=…)`).
  Implements **\#47** (left OPEN pending owner-confirmed close, per the
  standing rule + the \#48 precedent). Workstream = development under
  **Strict TDD** — phase declared every response, 3 gates via
  `AskUserQuestion` + a separate PRE-RED UX-fork question (tab
  placement), 0 stakeholder corrections.
- **RED:** New `tests/testthat/test_modORIPReporting.R` — 2 wiring tests
  (4 expectations) mirroring `test_modGvAndBgDesc.R`’s mount idiom: (1)
  `as.character(appUI())` must contain the `oripReporting-` namespace
  **and** “Office of Research Infrastructure Programs”; (2)
  `deparse(appServer)` must contain `modORIPReportingServer` **and**
  `oripReporting`. All 4 failed for the right reason at HEAD (markers
  absent); no module unit tests needed (the module is already tested in
  `test_modSiteConfig.R`).
- **GREEN/REFACTOR:** 2 edits matching the 7 sibling
  tabPanel/server-call idioms → 4/4 pass; full suite 0 failed / 0 error;
  `lintr` 0 lints on all 3 changed files; `document()` no-op (module
  already `@export`’d, NAMESPACE/man unchanged). REFACTOR was a
  confirmed no-op (edits already idiomatic).
- **Phase-3E (runtime smoke): PERFORMED — PASS (13/13).** Headless
  `AppDriver` boot of the installed app: ORIP tab link + all 5
  namespaced outputs/buttons + body text render; `mainNavbar` navigates
  to it (active pane shows “Export ORIP Report”); 4 sibling tabs intact;
  **0 `oripReporting`-namespaced JS errors** (the 12 `shinyBS` errors
  are pre-existing app-wide noise, separated by namespace grep). Reused
  Learning 78’s recipe (`NOT_CRAN=true` + `devtools::install()` first).
- **Owner-clarified follow-up → \#49 filed:** the tab ships
  **always-visible** this session; the owner clarified ORIP reporting is
  **ONPRC-specific** and the tab should be **gated on an Oregon-specific
  config**. That conditional-presentation change is deferred to new
  issue **\#49** (out of scope here, per 1-and-done).
- **\[news-vs-changelog\]:** user-facing (a new visible tab) → **BOTH**
  `NEWS.Rmd`→`NEWS.md` (new “Shiny application” bullet under
  `1.1.0.9000`, rendered from source) **and** this CHANGELOG entry. The
  module was previously listed in NEWS only as an existing *module
  file*, never as a reachable feature.

### 2026-06-15 — Durable opt-in E2E test for the Potential Parents tab (Session 82)

- **Deliverable:** Added
  `tests/testthat/test-e2e-potential-parents-module.R` — a durable,
  opt-in browser E2E test for the shipped **\#48** “Potential Parents”
  tab, mirroring the sibling `test-e2e-*-module.R` pattern. Closes the
  literal full-browser-chain gap S80 (mount-only AppDriver smoke +
  `testServer`) and S81 (one owner click-through) both flagged.
  Workstream = development (test backfill) under **Strict TDD** — phase
  declared every response, 3 gates via `AskUserQuestion`, 0 stakeholder
  corrections.
- **Regression backfill ⇒ no production code:** the feature already
  shipped (S80) and was owner-verified (S81), so this adds only a test
  (no `R/`, `man/`, `NAMESPACE`, or `NEWS.md` changes). The degenerate
  RED→GREEN was declared honestly at the gate: RED = assertions with
  teeth that self-skip when `NPRC_RUN_E2E` is off; GREEN = run against
  the shipped feature; REFACTOR = lint.
- **4 opt-in `AppDriver` blocks:** (1) tab accessible; (2) controls
  present (gestation input / Find button / Download CSV); (3)
  **populated path** — upload `rhesusPedigree_fromCenter.csv` → Pedigree
  Browser → Potential Parents → `maxGestationalPeriod=210` → Find →
  assert status *“Found candidate parents for 50 animal”* + table *“of
  50 entries”* + downloaded CSV = 50 rows & header
  `id,nSires,nDams,sires,dams`; (4) graceful degradation —
  `ExamplePedigree.csv` → Find → *“colony-origin”* warning. The `50`
  regression lock was independently re-derived through the app’s exact
  pipeline (both the filtered `pedigreeData` and full
  `processedPedigree` variants give 50) before the browser run.
- **Verification:** `devtools::install(quick=TRUE)` (E2E drives the
  installed copy) → `NOT_CRAN=true NPRC_RUN_E2E=true` single-file run →
  **7/7 expectations PASS, 0 fail/skip/error** in a real Chrome browser
  (this is the Phase-3E runtime verification) → clean-regression read
  **0 failed / 0 error / 0 true offenders** with the file skipping
  cleanly in the normal suite → `lintr` 0 lints.
- **PROJECT_LEARNINGS.md:** Learning 80 added (backfilling a regression
  E2E under strict TDD: honest degenerate cycle, re-derive the locked
  value through the exact pipeline, browser-E2E-is-Phase-3E, preserve
  the sibling idiom).

### 2026-06-15 — Owner-confirmed close of \#48 + clean fromCenter example dataset (Session 81)

- **Deliverable:** Owner-confirmed close of **\#48** (the
  getPotentialParents “Potential Parents” tab shipped S80), gated on a
  **live owner click-through** verified end-to-end. Workstream =
  verification + issue-management (**TDD phase = N/A** — added an
  example dataset + diagnosis, no production logic/tests).
- **Live click-through (Phase 3E, owner-run): PASS.** Part A graceful
  degradation (`ExamplePedigree.csv` → “no fromCenter field”
  empty-state); Part B populated path (new fromCenter file → 50-animal
  sortable table, status “Found candidate parents for 50 animal(s)…”,
  CSV downloaded as `potential_parents_2026-06-15.csv`). Existing tabs
  intact.
- **New shipped data:** `inst/extdata/rhesusPedigree_fromCenter.csv`
  (`rhesusPedigree` + `fromCenter=TRUE`, 375 animals, unknown parents as
  **literal `NA`**) — a purpose-built clean fixture, because every
  shipped pedigree example is a deliberate input-error QC fixture and
  none reaches the feature’s happy path. Owner chose the
  `rhesusPedigree` source via `AskUserQuestion`.
- **Defect caught by the click-through (FM \#24):** the first staged
  file wrote unknowns as **empty cells**; the app’s reader (`read.table`
  default `na.strings="NA"`, `modInput.R:274`) reads `""` as the empty
  string, so `""` landed in both the sire and dam columns →
  `correctParentSex.R:71` *“both sire and dam”* error. My headless
  pre-check had used `na.strings=c("","NA")`, masking it. Rewrote with
  literal `NA` and re-verified against the app’s exact reader → clean +
  50 candidates.
- **Diagnosed non-defects firsthand:** the *“fromCenter → fromcenter”*
  case-change warning is cosmetic (`fixColumnNames.R:20` lowercases all
  headers, `:61` restores `fromCenter`; the cleaned studbook keeps
  `fromCenter`); *“No data available in table”* = the empty Errors-tab
  placeholder.
- **GitHub:** **\#48 CLOSED** (owner-confirmed). Umbrella **\#45**’s
  getPotentialParents line now delivers verified app value. Open issues
  18 → 17.
- **PROJECT_LEARNINGS.md:** Learning 79 added (click-through-first +
  replicate-the-app’s-exact-reader).

### 2026-06-15 — Implement \#48: wire getPotentialParents into a new Potential Parents tab (Session 80)

- **Deliverable:** Implemented the owner-ratified (S79)
  `getPotentialParents` Shiny wire-in under **Strict TDD** (RED → GREEN
  → REFACTOR with phase gates). Turns shipped package-API logic (the S74
  \#31 gestation-derived dam window) into user-visible app value. The
  build-from-scratch second session that S79’s Learning 77 predicted.
- **TDD phase: full RED → GREEN → REFACTOR**, every transition gated via
  `AskUserQuestion` (PRE-RED→RED, RED→GREEN, GREEN→REFACTOR). 0
  stakeholder corrections.
- **New code:** `R/modPotentialParents.R` — a pure
  `flattenPotentialParents()` helper (list-of-lists → render/CSV-ready
  data.frame, `NULL`/empty → 0-row),
  [`modPotentialParentsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsUI.md)
  (numeric `maxGestationalPeriod` input default 210, “Find Potential
  Parents” button, sortable `DT` table, CSV download, graceful
  empty-state messages), and
  `modPotentialParentsServer(id, pedigree, minParentAge = 2.0)`.
- **Tests:** `tests/testthat/test_modPotentialParents.R` — 14 tests / 43
  expectations covering the helper (cols, NULL/empty, multi-animal
  flatten, empty-sires, CSV round-trip), the UI (controls + namespace +
  default 210), and the server via
  [`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)
  (happy path on the rhesus fixture, no-`fromCenter` empty state,
  no-unknowns empty state, return shape). All pass.
- **Wiring (2 edits):** `appUI.R` —
  `tabPanel("Potential Parents", icon("search"), modPotentialParentsUI("potentialParents"))`
  after Breeding Groups; `appServer.R` —
  `modPotentialParentsServer("potentialParents", pedigree = reactive(shared$currentPedigree))`.
- **Data seams honored** (from \#48): no `fromCenter` column →
  `getPotentialParents` returns `NULL` → empty-state, not error;
  `minParentAge` reuses the QC 2-year default as a server param (owner
  ratified only the gestation UI input, so no second UI input added —
  scope held); empty results → empty-state message.
- **Verification:** `devtools::check()` clean (0 errors / 0 warnings / 0
  notes); full clean-regression read 0 real failed/error; `lintr` clean
  on the new module + test files; docs regenerated
  (`modPotentialParents*` exported, `flattenPotentialParents` kept
  internal via `@noRd`).
- **Phase-3E runtime smoke test (mandatory, performed):** booted the
  assembled app headlessly via
  [`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html)
  (`inst/shinytest/app.R`, `NOT_CRAN=true` to bypass the CRAN guard, dev
  package installed first). Confirmed: app boots with full server init
  (incl. the new module), the tab + all four controls mount, default 210
  set, navigation works, existing tabs intact, module outputs
  (`statusMessage`/`resultsTable`/`downloadParents`) register
  error-free. The only log “errors” are pre-existing
  `shinyBS is not defined` JS reference errors (app-wide, not from this
  module).
- **\[news-vs-changelog\]:** user-facing feature → **also** `NEWS.md`
  (new “Shiny application” bullet under `1.1.0.9000`), plus this
  CHANGELOG process entry. \#48 remains OPEN pending owner-confirmed
  close; umbrella \#45 unchanged.
- **NEWS source-sync fix (owner-flagged mid-session):** `NEWS.md` is
  generated from `NEWS.Rmd` (`github_document`), but prior sessions had
  edited the generated `NEWS.md` directly, leaving `NEWS.Rmd` missing
  three shipped entries — **NEW-47** (`getDescendantPedigree`),
  **NEW-48/#44/#38** (`getAutoIdFormat`/`setAutoIdFormat`),
  **NEW-49/#31** (`getPotentialParents` gestation window). Back-ported
  all three into `NEWS.Rmd`, added the \#48 entry to the source, and
  regenerated `NEWS.md` via
  [`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html);
  verified `NEWS.md == render(NEWS.Rmd)` (escaping now consistently
  `\#`). Going forward, edit `NEWS.Rmd` and regenerate — not `NEWS.md`
  directly.

### 2026-06-14 — Resolve UX forks for the getPotentialParents wire-in; deprioritize ORIP (Session 79)

- **Deliverable:** Resolved the three UX/design forks for the
  **getPotentialParents wire-in** (the \#37 integration of the S74 \#31
  logic, scoped under umbrella \#45) with the owner via
  `AskUserQuestion`, and recorded the ratified design on a new tracking
  issue **\#48** so a following session can implement under TDD.
  Design/decisions only — **no code**. Also deprioritized **\#47
  (ORIP)** per owner direction. Open issues **17 → 18** (one new issue,
  \#48).
- **TDD phase = N/A** (design/decisions; no production code or tests —
  same classification as S76/S77/S78).
- **Owner decisions (via `AskUserQuestion`, all applied, 0
  corrections):** (1) **`maxGestationalPeriod` source** = a **numeric
  input** prefilled with the rhesus default 210, user-overridable (v1
  single-species per \#45; species-keyed gestation stays \#46); (2)
  **location** = a **new top-level “Potential Parents” tab** (peer to
  the 8 existing module tabs); (3) **trigger/output** = a **“Find
  Potential Parents” button** → sortable table (animal → candidate
  sires/dams) → **CSV download** (the app’s `downloadHandler` idiom).
- **Firsthand grounding (recompute-don’t-inherit):** read
  `getPotentialParents.R` in full (gestation dam window `:83-85`,
  exclusion `:106`; zero production callers), `appUI.R` (8 mounted
  module tabs), `appServer.R:104-293` (the
  `modXxxServer(id, <reactives>)` wiring + `shared$currentPedigree`
  flow), and the `fromCenter` producers (`convertFromCenter` /
  `qcStudbook`). Confirmed the data seams for the implementer
  (`fromCenter`-absent → `NULL`; `minParentAge` has no signature
  default; empty-results state). Noted \#45’s body line-map predates S74
  and is stale.
- **Deprioritization (#47 ORIP):** the repo had **no priority labels**
  and no `BACKLOG.md` (Issues are the backlog), so created a
  `low priority` label and applied it to \#47 (owner-directed). ORIP’s
  module already exists — a **mount-only** wire-in, correctly deferred
  behind the larger **build-from-scratch** \#48 (→ Learning 77).
- **New issue:** **\#48** “Wire in getPotentialParents — new Shiny
  surface for animals with unknown parents” (`enhancement`) — captures
  the three ratified forks, the from-scratch module/test/wiring task,
  the data seams, the \#28/#46 out-of-scope boundary, and the mandatory
  Phase-3E smoke test; references \#37/#45.
- **Issue tracker:** \#48 filed; register-ratified **link comment** on
  umbrella **\#45** (additive — prior comments preserved, FM \#22).
  Nothing closed; \#45 stays OPEN. Verified: \#48 OPEN, \#45 OPEN (3
  comments), \#47 labeled `low priority`, open count 18.
- **\[news-vs-changelog\]:** CHANGELOG only — resolving design forks +
  filing an issue is dev-process history, not a user-facing release note
  (no `NEWS.md` entry); no `BACKLOG.md` file (open work lives in GitHub
  Issues).

### 2026-06-14 — Triage \#37: wire-in / keep / retire the unused exports (Session 78)

- **Deliverable:** Triaged GitHub issue **\#37** (“Exported functions
  not currently used by app”) — a firsthand, clustered disposition of
  every exported-but-app-unreachable function as **wire-in /
  keep-as-public-API / retire**, recorded as an [additive triage
  comment](https://github.com/rmsharp/nprcgenekeepr/issues/37#issuecomment-4703983124).
  Grooming/triage only — **no code**. \#37 stays **OPEN** (the standing
  inventory). One new issue filed (#47). Open issues **16 → 17**.
- **TDD phase = N/A** (grooming/triage; no production code or tests —
  same classification as S73/S76/S77).
- **Recompute-don’t-inherit:** re-ran the issue’s own documented method
  firsthand (call-graph reachability seeded at
  `runModularApp`/`runGeneKeepR`/`appUI`/`appServer`, transitive closure
  of
  [`codetools::findGlobals`](https://rdrr.io/pkg/codetools/man/findGlobals.html)).
  **The S65 (2026-06-12) snapshot had drifted:** now **158 exports / 119
  reached / 39 unused** (was 155/116/39); `setAutoIdFormat` (S71
  \#44/#38) is a new unused export the issue body predates; `chooseDate`
  is no longer unused. Reachability confirmed clean (no
  S3/`do.call`/`match.fun`/[`get()`](https://rdrr.io/r/base/get.html)
  path reaches any of the 39).
- **Method:** a Workflow (`wf_be838846-794`) — **9 parallel cluster
  investigators** (each gathering firsthand: definition,
  roxygen/`@examples`, tests, vignette/`inst` use, non-app package
  callers, git provenance, related issue) + an adversarial
  **completeness critic**. The critic earned its keep (→ **Learning
  76**): it (1) **overturned a fabricated caller-edge** —
  `calcFE`/`calcFG` were claimed “called by `calcFEFG`” but have **no
  live callers** (`calcFEFG` computes via
  `calcFounderContributions`+`calcRetention`; `reportGV` calls
  `calcFEFG`); (2) surfaced two **closed islands** (obfuscation trio
  rooted at `obfuscatePed`; logging/error/export trio
  `logModuleEvent`←`safeExecute`/`savePlotToFile`, reachable from
  nothing live) whose dispositions are coupled; (3) downgraded the
  investigators’ uniform “high-confidence wire-in” on the infra island
  to a genuine owner-decision; (4) corrected the cluster’s roadmap issue
  (#8 is CLOSED; **\#10** is the open sim-kinship home). Every
  load-bearing critic claim re-verified firsthand against the working
  tree before recording.
- **Result: 2 wire-in · 37 keep-as-public-API · 0 retire.** “Exported
  but app-unreachable” is not “dead code” — the package deliberately
  exposes script/interactive API, so the default is
  **keep-as-public-API** and nothing reached the breaking-change retire
  bar.
- **Owner decisions (via `AskUserQuestion`, applied):** (1) **ORIP
  reporting module** (`modORIPReportingUI`+`modORIPReportingServer`, a
  complete-but-never-mounted module) → **wire-in** as a grant-reporting
  tab (filed as **\#47**); (2) **logging/error/plot-export island** →
  **keep as-is / defer** (adopt incrementally; `safeExecute`, zero
  callers, is a future-cleanup retire candidate); (3) **founder/genetic
  summary table helpers**
  (`makeFounderStatsTable`/`makeGeneticSummaryTable`) →
  **keep-as-public-API** (the app already renders founder stats inline
  at `modSummaryStats.R:583-638`; wiring in = DRY refactor of working
  code, no functional gain). The other wire-in —
  **`getPotentialParents`** — is the S74 \#31 feature already homed
  under umbrella **\#45** (#37 wiring gates its app value).
- **Docfixes surfaced (not done — separate session):**
  `getPedDirectRelatives` `@examples` (`R/getPedDirectRelatives.R:27`)
  calls `getLkDirectRelatives`, not itself; optional dedicated tests for
  `kinshipMatrixToKValues` and `getAncestors` (currently
  transitive-only).
- **New issue:** **\#47** “Wire in the ORIP reporting module (mount
  modORIPReporting\* in appUI/appServer)” (`enhancement`) — captures the
  owner-ratified wire-in; references \#37.
- **Issue tracker:** triage posted as an **additive comment** on \#37
  (the owner’s S65 re-verification body/comment preserved — FM \#22);
  \#47 filed. Nothing closed; \#37 remains OPEN. Verified: \#37 OPEN (2
  comments), \#47 OPEN, open count 17.
- **\[news-vs-changelog\]:** CHANGELOG only — a triage recorded on an
  issue + filing an issue is dev-process history, not a user-facing
  release note (no `NEWS.md` entry); no `BACKLOG.md` file (open work
  lives in GitHub Issues).

### 2026-06-14 — Ratify \#28 open-decisions register (Session 77)

- **Deliverable:** Ratified the **8 `[OPEN]` items** in \#28’s §13
  open-decisions register (the S76 colocation data-model spec) via owner
  sign-off, and recorded the decisions back onto **\#28** ([ratification
  comment](https://github.com/rmsharp/nprcgenekeepr/issues/28#issuecomment-4703716881))
  — every item moves **\[OPEN\] → \[DECIDED\]**. Design/grooming only —
  **no code**. \#28 stays **OPEN** (the register clears the
  *design/semantics* gate; implementation remains gated on
  \#11/#12/#37/#46). Open issues **15 → 16** (one new issue filed —
  \#46, below).
- **TDD phase = N/A** (design/grooming; no production code or tests —
  same classification as S73/S76).
- **Method:** a verify-and-sharpen Workflow (`wf_b8035a53-5be`) — **8
  parallel item-verifiers** (one per register item, each re-reading the
  spec’s code claims firsthand against the working tree and
  adversarially stress-testing its `[REC]`) + an adversarial
  **completeness critic**. The critic reduced an over-asked 8-item
  register to **4 genuine owner-decisions** (items 1/2/3 + item 6’s
  provenance half), with the rest as ratifiable corollaries/deferrals;
  it also surfaced two §7 policy gaps absent from §13. Decisions posed
  via `AskUserQuestion` (2 rounds, staggered so item 2 could be informed
  by item 1’s answer); rubber-stamps folded into one batch ratification.
- **Owner decisions (all ratified as recommended):** (1) **missing-dam
  inference** = mother–infant co-housing model with a required,
  no-default, species-tunable `postnatalCoHousingWindow` +
  gestation-presence, strictly **soft-rank** (hard-filter rejected); (2)
  **both-unknown** = **dam-side only** via the focal-animal anchor
  (soft-rank), sire side unranked; (3) **output** = additive-only
  invariant locked, concrete carrier deferred to implementation; (4)
  **coherent obfuscation** = one shared per-animal delta + alias
  FK-remap, built with \#28; (5) **v1 single-species**, \#28 does not
  block on first-class species; (6) **provenance** = stamp pull-date +
  source id (full bitemporal deferred); (7+8) **defer flat-file
  ingestion & POSIXct** (LabKey-only, Date resolution) pending a
  concrete source; **§7 QC policy** = open-start contributes no overlap,
  contradictory rows raise a QC warning.
- **Two firsthand corrections to the S76 spec** (caught by the
  verification workflow): **(a)** item 2’s written `[REC]` (“require ≥1
  known parent — case 3 is anchorless”) is **unsound** —
  `getPotentialParents.R:46-48`’s inclusive-OR filter means a
  both-unknown infant’s *own* birth-time location is a valid
  **dam-side** anchor (only the sire side is anchorless); so the
  decision flips to dam-side colocation. **(b)** §10 **mis-cited \#36**
  as the “make species first-class” prerequisite — \#36 is actually the
  chimpanzee age-pyramid *display* ticket; first-class species support
  was un-ticketed and is now **\#46**.
- **Sizing notes recorded for the eventual \#28 implementer:**
  `postnatalCoHousingWindow` is a NEW required, species-dependent
  parameter (no default, mirrors `maxGestationalPeriod`);
  `obfuscateDate.R:49-57`’s per-element re-draw-to-floor must be
  reworked into a per-animal draw (changes existing obfuscation output,
  breaks current `obfuscatePed`/`obfuscateDate` test expectations); the
  scored-output carrier/columns are deferred until \#37’s app consumer +
  items 1/2 are concrete.
- **New issue:** **\#46** “Make species a first-class attribute
  (ingestion + species-keyed gestation/postnatal window)”
  (`enhancement`) — the real multi-species dependency, distinct from
  \#36’s display scope; owns the corrected §10 dependency.
- **Issue tracker:** ratification posted as an **additive comment** on
  \#28 (S76 spec body/comments preserved — FM \#22); register-ratified
  link comment on **\#45**; **\#46** filed. Nothing closed; \#45/#28
  remain OPEN. Verified: \#28 OPEN (3 comments), \#45 OPEN (2 comments),
  \#46 OPEN, open count 16.
- **\[news-vs-changelog\]:** CHANGELOG only — ratifying a register on an
  issue + filing an issue is dev-process history, not a user-facing
  release note (no `NEWS.md` entry); no `BACKLOG.md` file (open work
  lives in GitHub Issues).

### 2026-06-14 — Spec \#28: colocation data model (Session 76)

- **Deliverable:** Wrote a colocation data-model spec onto GitHub issue
  **\#28** (the deferred sub-task under umbrella **\#45**), satisfying
  umbrella **acceptance criterion \#4** (“#28 has a written data-model
  spec — grain of colocation; source query — recorded on \#28 before any
  implementation”). Design/grooming only — **no code**. \#28 stays
  **OPEN** (a spec clears the design gate; it does not complete the
  data-dependent sub-task). Open issues unchanged at **15**.
- **TDD phase = N/A** (design/grooming; no production code or tests —
  same classification as S73’s consolidation).
- **Method:** firsthand subsystem map via a Workflow (5 parallel facet
  readers — conception primitive / pedigree data-model+ingestion /
  LabKey-Oracle-ARMS sourcing / existing location+temporal constructs /
  colocation semantics — + an adversarial completeness critic), then
  firsthand re-verification of every load-bearing claim before the
  outward-facing post (Learning 70 / recompute-don’t-inherit → new
  **Learning 74**). Re-read firsthand: `getPotentialParents.R` (full,
  post-S74), `getPossibleCols`, `getDateColNames`, `getSiteInfo`,
  `getDemographics`, `obfuscateDate`, `obfuscatePed`, `fixColumnNames`,
  `qcStudbook` column-handling.
- **Owner decisions (via `AskUserQuestion`, applied):** temporal model =
  **Date-ranged residency intervals** (day resolution, matching every
  existing date column); colocation grain = **configurable,
  finest-available default** (cage/room/enclosure/building); colocation
  effect = **soft rank with fallback** (never empties an age-eligible
  set; no-location candidates retained as `colocation-unknown`); v1
  scope = **source-agnostic model + optional `location` arg that
  degrades to byte-identical (`location = NULL`) behavior** — not
  hard-blocked on \#11/#12.
- **Spec content (13 sections + acceptance criteria):** a separate
  many-rows-per-id location entity `{id, location, grain, start, end}`
  (exempt from `removeDuplicates`); the
  interval-overlap-vs-conception-window predicate reusing the existing
  `maxGestationalPeriod` primitive; ingestion mirroring
  `getDemographics`/`getSiteInfo` (new
  `lkLocationColumns`/`mapLocationColumns`/`locationQueryName`); a
  null/partial-coverage matrix; and the **obfuscation-coherence
  requirement** (the critic+firsthand finding — `obfuscatePed` jitters
  each Date column independently ±30 d and covers only the pedigree,
  which would corrupt overlap math). Carries an **open-decisions
  register** (missing-dam inference model + postnatal co-housing window
  — flagged as *invented design awaiting husbandry ratification*, not
  derived; output reshape coordinated with \#37; species/#36 ordering;
  bitemporal handling; flat-file ingestion) for sign-off before sizing.
- **Honest scope notes recorded on \#28:** \#11 (Oracle) is
  demographic-only/unspecified and \#12 (ARMS) is an empty stub, so the
  gating is *nominal* — the spec defines the model source-agnostically;
  “source query” is satisfied at the idiom level (mirror
  `getDemographics`), not a concrete query; the JMAC `species` column
  survives ingestion as a trailing `novelCol` (`qcStudbook.R:281-283`)
  but is read nowhere.
- **Issue tracker:** spec posted as a **comment** on \#28 (additive —
  owner’s body/comment preserved, FM \#22); criterion-#4-satisfied link
  comment on **\#45**. Nothing closed; no issue state changed.
- **\[news-vs-changelog\]:** CHANGELOG only — a spec recorded on an
  issue is dev-process history, not a user-facing release note (no
  `NEWS.md` entry); no `BACKLOG.md` file (open work lives in GitHub
  Issues).

### 2026-06-13 — Close \#31: gestation-derived dam-exclusion window (Session 75)

- **Deliverable:** Closed GitHub issue **\#31** (“Use gestational length
  instead of hack for dam identification”) as completed — the
  gestation-derived dam-exclusion window shipped in S74 (`0eeee3f6`) and
  the owner confirmed the close this session. Open issues **16 → 15**.
  Completes the \#31 lifecycle: S73 consolidate (under umbrella \#45) →
  S74 implement → S75 close (one deliverable per session).
- **TDD phase = N/A** (administrative issue-close; no production code —
  same classification as S69/S72).
- **Firsthand verification before the irreversible close** (per the
  standing “don’t close an OPEN issue without firsthand evidence” rule +
  Learning 69): mapped the committed tree (`0eeee3f6`) against umbrella
  \#45’s acceptance criteria 1–3 (#31’s scope) — (1) the dam window is
  driven by the existing `maxGestationalPeriod` scalar, no parallel
  param (`getPotentialParents.R:83-85`, signature unchanged); (2) two
  tests demonstrate dam selection responds to `maxGestationalPeriod`
  (synthetic-exclusion + the explicitly-named criterion-2 test,
  `test_getPotentialParents.R:131-190`); (3) the `:92-93` “hack” TODO is
  resolved, the roxygen documents the dual use + intentional sire/dam
  asymmetry, and every dropped-dam fixture delta carries a per-delta
  biological justification. Re-ran the target file (21/21) and the full
  suite (0 failed / 0 error) firsthand.
- **Close comment** (with `0eeee3f6` pointer): criterion-by-criterion
  map + honest scope notes — \#31’s original “add a `gestationalLength`
  parameter” suggestion was intentionally superseded by the owner’s S73
  decision to extend the existing `maxGestationalPeriod`;
  species-specific gestation remains a documented dependency under \#45;
  the function is exported-but-unwired (#37).
- **Issue tracker:** **15 open** (was 16). \#31 `state=CLOSED`
  (verified). Umbrella \#45 + sub-task \#28 remain OPEN.
- **\[news-vs-changelog\]:** CHANGELOG only — closing an issue is
  dev-process history, not a user-facing release note (no `NEWS.md`
  entry); no `BACKLOG.md` file (open work lives in GitHub Issues).

### 2026-06-13 — Implement \#31: gestation-derived dam-exclusion window in getPotentialParents (Session 74)

- **Deliverable:** Replaced the “hack” in
  [`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
  (a fixed ±½-year birth window for excluding candidate dams, flagged
  with a TODO at `:92-93`) with a principled gestation-derived window
  driven by the **existing** `maxGestationalPeriod` parameter — the dam
  side now gets the gestation treatment the sire side already had.
  Resolves the near-term, low-lift sub-task of umbrella **\#45**.
  `devtools::check()` clean (0/0/0); full suite 0 failed / 0 error.
- **TDD phase = RED→GREEN→REFACTOR(skipped)** — a real TDD code session
  (first since S71). All three transition gates + a separate pre-RED
  scope decision posed via `AskUserQuestion`; phase declared atop every
  response; **0 stakeholder corrections**.
- **The change (one rule):** a female who delivered another offspring
  within `maxGestationalPeriod` days of the focal birth cannot have
  gestated the focal animal (a female bears one offspring at a time), so
  she is excluded as a candidate dam. The `births` window
  (`getPotentialParents.R`) now uses
  `pUnknown$birth[i] ± maxGestationalPeriod` instead of `± dYear/2L`
  (182.5 d).
- **Scope (owner-decided, minimal):** only the `births` exclusion window
  changed. The sire/dam exit-check asymmetry (`exit ≥ birth − gestation`
  for sires vs `exit ≥ birth` for dams) is **biologically correct**
  (sire→conception, dam→birth) and was documented, not changed. The
  preferential band (`births_plus_minus_one`) was left untouched —
  analysis proved moving its inner edge is a behavioral no-op (the wider
  exclusion always removes the overlap region first).
- **Behavior change, verified + justified firsthand (not silently
  regenerated):** the exact-set fixtures `dams_1` (BRI2MW) drop `0B7XRI`
  (−193 d) / `PHCADH` (+195 d); `dams_4` (FEEN9W) drop `1SIP4V` (+183 d)
  / `DMI0QY` (+192 d) / `HV7LZ3` (−192 d) — each delivered another
  offspring inside the new ±210 d window. No dams added, no fallback
  triggered, sires unchanged. Backed by two from-first-principles
  driving tests: a hand-verifiable synthetic-pedigree exclusion test and
  a differential-responsiveness test (acceptance criterion \#2).
- **\[news-vs-changelog\]:** BOTH — a behavior change to an exported
  function is user-facing → `NEWS.md` NEW-49; this entry is the
  dev-process record. \#31 left **OPEN** (implemented, check-green;
  close is a separate owner-confirmed step).

### 2026-06-13 — Consolidate parent-ID cluster \#31 + \#28 → umbrella \#45 (Session 73)

- **Deliverable:** Created umbrella design issue **\#45** (“Principled
  parent identification in getPotentialParents via estimated conception
  date”) consolidating the two open parent-identification issues —
  **\#31** (replace the dam-exclusion “hack” with gestational length)
  and **\#28** (timestamped colocation at birth − gestation). Both kept
  **OPEN** as distinct, cross-linked sub-tasks — they are **not**
  duplicates. Open issues **15 → 16**. Analogous to S70’s \#44
  consolidation, but the disposition differs: the research showed
  \#31/#28 are distinct work (a linking umbrella), not
  duplicates-to-close.
- **TDD phase = N/A** (grooming/design; no production code or tests —
  same classification as S70).
- **Method:** firsthand subsystem map via a Workflow (4 parallel facet
  readers — core fn / callers / gestation+location data infra / tests
  — + an adversarial completeness critic), then firsthand
  re-verification of every load-bearing claim before the outward-facing
  create/link (Learning 70 / recompute-don’t-inherit). The verification
  corrected an overstatement (a `species` column DOES exist in some
  example inputs, just not the canonical fixtures).
- **Key findings (verified firsthand):** the shared primitive
  (conception date = birth − gestation) is **already half-implemented**
  as the existing `maxGestationalPeriod` param, applied sire-side only
  (`getPotentialParents.R:62`); \#31 is a bounded in-function refactor
  (the dam side never got the treatment) while \#28 needs a
  timestamped-colocation data model the package **lacks** (blocked on
  \#11/#12); `getPotentialParents` is experimental + **unwired** (→
  \#37); \#31 is a **behavior change** (the test asserts exact dam/sire
  sets via `expect_identical`), not a pure refactor.
- **Owner decisions (via `AskUserQuestion`):** linking umbrella with
  both sub-tasks open; narrow scope (`getPotentialParents` only);
  reuse/extend the existing `maxGestationalPeriod` (no parallel
  parameter).
- **\[news-vs-changelog\]:** CHANGELOG only — issue consolidation is
  dev-process history, not a user-facing release note (no `NEWS.md`
  entry); no `BACKLOG.md` file (open work lives in GitHub Issues).

### 2026-06-13 — Close \#44 + \#38: configurable auto-ID format (Session 72)

- **Deliverable:** Closed GitHub issues **\#44** (umbrella) and **\#38**
  (generation sub-task) as completed — the configurable auto-ID feature
  shipped in S71 (`14c8e84d`) and the owner confirmed the close this
  session. Open issues **17 → 15**. Completes the \#44 lifecycle: S70
  consolidate → S71 implement → S72 close (one deliverable per session).
- **TDD phase = N/A** (administrative issue-close; no production code —
  same classification as S69/S70).
- **Firsthand verification before the irreversible close** (per the
  standing “don’t close an OPEN issue without firsthand evidence” rule +
  Learning 69): confirmed the committed tree (`14c8e84d`) against
  **each** of \#44’s 8 acceptance criteria — exports in `NAMESPACE`, the
  predicate routing all 7 detection sites + 2 generators, the round-trip
  tests, the docstring/tooltip updates — and that the full suite +
  `devtools::check()` passed on exactly that state. Mapped criteria →
  code in the close comment.
- **Close comments** (with `14c8e84d` pointer): \#44 carries the
  criterion-by-criterion map + the documented known limitation
  (prefix-only detection still over-matches real prefix-IDs — the
  owner-approved byte-identical tradeoff); \#38 maps
  `setAutoIdFormat`/`getAutoIdFormat`/`addUIds`-format-param to its
  asks. `gh issue close --reason completed`.
- **Issue tracker:** **15 open** (was 17). \#44/#38 `state=CLOSED`
  (verified).

### 2026-06-13 — Implement \#44/#38: configurable auto-generated unknown-ID format (Session 71)

- **Deliverable:** Implemented umbrella issue **\#44** (and its **\#38**
  sub-task) via strict TDD (RED→GREEN→REFACTOR-skipped). The
  auto-generated placeholder-ID format for unknown parents is now
  configurable from a single source of truth, default `"U%04d"`,
  **byte-identical with no configuration**. Executes S70 SUGGESTED-NEXT
  candidate (1). Owner decisions (via `AskUserQuestion`): **full \#44**
  scope; **prefix-only byte-identical** detection; **case-sensitive**
  reconciliation.
- **TDD:** first code session since S68. Three phase gates posed via
  `AskUserQuestion` (PRE-RED→RED, RED→GREEN, GREEN→REFACTOR-skipped)
  plus a separate pre-RED scope/approach decision (3 questions). **0
  stakeholder corrections.**
- **New code:** `R/autoIdFormat.R` —
  [`getAutoIdFormat()`](https://github.com/rmsharp/nprcgenekeepr/reference/getAutoIdFormat.md)
  /
  [`setAutoIdFormat()`](https://github.com/rmsharp/nprcgenekeepr/reference/setAutoIdFormat.md)
  (exported, over `getOption("nprcgenekeepr.autoIdFormat", "U%04d")`,
  mirroring the `.debug`/`.verbose`/`.gva_seed` convention) + internal
  `getAutoIdPrefix()` and `isGeneratedUnknownId()` (case-sensitive,
  NA-preserving like the `startsWith`/`stri_sub` it replaces).
- **Threaded through:**
  [`addUIds()`](https://github.com/rmsharp/nprcgenekeepr/reference/addUIds.md)
  gains a `format =` param and mints via `sprintf(format, …)` (≡
  default);
  [`obfuscateId()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateId.md)
  mints with `getAutoIdPrefix()` and detects via the predicate;
  [`removeAutoGenIds()`](https://github.com/rmsharp/nprcgenekeepr/reference/removeAutoGenIds.md)
  (×3), `modPedigree.R` display filter, and
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  founder counts all route detection through the single predicate —
  replacing all 7 detection literals + 2 generators.
  [`removeAutoGenIds()`](https://github.com/rmsharp/nprcgenekeepr/reference/removeAutoGenIds.md)’s
  standing “use a function call” TODO is resolved.
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  unchanged (its `addUIds(sb)` picks up the option via the default —
  smallest blast radius). Out-of-scope conventions (textual
  `"UNKNOWN"`/`unknown2NA`, `recordStatus`/`getRecordStatusIndex`)
  deliberately untouched.
- **Tests (TDD):** NEW `tests/testthat/test_autoIdFormat.R`
  (default/set/validation/predicate/prefix + a non-default-format
  `"AUTO%05d"` round-trip: configure→generate→detect→remove); NEW
  `tests/testthat/test_removeAutoGenIds.R` (none existed — default
  removal + case-sensitivity + non-default prefix);
  `test_obfuscateId.R:27-32` updated to the case-sensitive contract
  (lowercase `"u001"` is now a real ID, the **only** existing test that
  changed — `test_addUIds.R`/`test_qcStudbook.R`/`test_modPedigree.R`
  pass unchanged = back-compat proof). **Full suite: 0 failed, 0 error,
  159 skip** (985 results); the 5 warnings are pre-existing
  `test_modPyramid.R` baseline. Lint clean under `load_all` (the
  [`options()`](https://rdrr.io/r/base/options.html) setter carries
  `# nolint: undesirable_function_linter` per the project’s
  `getPyramidPlot.R` precedent — a public permanent setter, not a scoped
  change).
- **Docs/exports:** `devtools::document()` → `man/getAutoIdFormat.Rd` +
  `man/setAutoIdFormat.Rd` + NAMESPACE exports;
  `man/addUIds.Rd`/`man/removeAutoGenIds.Rd` regenerated. **NEWS.md**
  NEW-48 (user-facing). `modPedigree.R:112` tooltip notes the format is
  configurable.

### 2026-06-13 — Consolidate the ID cluster into umbrella \#44 (Session 70)

- **Deliverable:** Consolidated the three overlapping
  auto-generated-unknown-ID issues — **\#26**, **\#32**, **\#38** — into
  one umbrella design issue **\#44** (*“Configurable auto-generated
  unknown-ID format (default `"U%04d"`) — single source of truth for
  generation + detection”*). Executes S69 SUGGESTED-NEXT candidate (1).
  Per owner decisions (via `AskUserQuestion`): configurability =
  **prefix + number format**, default `"U%04d"`; scope = the
  `"U"`-prefix convention only; **\#26 + \#32 closed** as duplicates of
  \#44, **\#38 kept open** and linked as the concrete generation
  sub-task. Open issues **18 → 17** (−2 closed, +1 umbrella created).
- **TDD phase = N/A** (grooming/design; no production code or tests —
  same classification as S57/S61–S67/S69).
- **Firsthand subsystem map (Workflow under ultracode):** 4 parallel
  facet readers (generation / detection / callers-config / tests) + an
  adversarial completeness critic. The critic overturned the mappers on
  two material points: the package has **three** independent
  unknown/auto-gen conventions (textual `"UNKNOWN"` in `unknown2NA`; the
  `"U%04d"` prefix with **two** producers — `addUIds.R:47,54` +
  `obfuscateId.R:38-43` — and **7** case-divergent detection sites with
  no centralized predicate; and `recordStatus="added"` in `addParents.R`
  with the already-centralized `getRecordStatusIndex()`), coupled only
  by ordering in `qcStudbook.R:188→198→199`.
- **Verify-before-publish:** re-read the 8 load-bearing files firsthand
  (`addUIds`, `removeAutoGenIds`, `addParents`, `getRecordStatusIndex`,
  `obfuscateId`, `unknown2NA`, the `qcStudbook` ordering, the
  `modPedigree.R:112` tooltip) before creating \#44 / closing \#26/#32 —
  did not publish subagent findings unverified.
- **\#44** captures the verified current-state map, a
  single-source-of-truth design
  ([`getAutoIdFormat()`](https://github.com/rmsharp/nprcgenekeepr/reference/getAutoIdFormat.md)/[`setAutoIdFormat()`](https://github.com/rmsharp/nprcgenekeepr/reference/setAutoIdFormat.md)
  per \#38 + an internal `isGeneratedUnknownId()` predicate replacing
  the 8 literals), acceptance criteria (incl. byte-identical back-compat
  with no config, and a non-default-format round-trip test), the tests
  that bake in `"U"`, and an explicit **out-of-scope** section for the
  textual-`"UNKNOWN"` and `recordStatus` conventions.
- **Issue tracker:** **17 open** (was 18). \#26/#32 `state=CLOSED`
  (verified); \#38 OPEN with link comment; \#44 OPEN, label
  `enhancement`.

### 2026-06-13 — Close \#35: descendants in pedigree filtering (Session 69)

- **Deliverable:** Closed GitHub issue \#35 (*“Include descendants in
  pedigree filtering (ancestors already implemented)”*) as completed —
  the feature shipped in S68 (`d4320643`) and the owner confirmed the
  close this session. Open issues **19 → 18**. Completes the \#35
  lifecycle: S67 re-scope → S68 implement → S69 close (one deliverable
  per session).
- **TDD phase = N/A** (administrative issue-close; no production code or
  tests — same classification as S57/S61–S67).
- **Firsthand verification before the irreversible close** (per the
  standing “don’t close an OPEN issue without firsthand evidence” rule):
  ran the three covering test files — `test_getDescendantPedigree.R`,
  `test_modPedigree_processing.R`, `test_modPedigree.R` — **all pass**;
  read the implementation (`R/getDescendantPedigree.R`, the union at
  `R/modPedigree.R:299-305`, the help text at `:124-126`) and confirmed
  it satisfies **each** of the issue’s re-scoped asks: descendant set
  unioned with the existing ancestor set; **Option A** strict-lineal (no
  collaterals); UI label aligned from “only relatives” to “ancestors and
  descendants”.
- **Close comment** posted with a commit pointer (`d4320643`) mapping
  the shipped code to the issue’s acceptance criteria;
  `gh issue close --reason completed`.
- **Issue tracker:** **18 open** (was 19).

### 2026-06-13 — Implement \#35: descendants in pedigree filtering (Session 68)

- **Deliverable:** Implemented GitHub issue \#35 (*“Include descendants
  in pedigree filtering (ancestors already implemented)”*) via strict
  TDD (RED→GREEN→REFACTOR-skipped). The Pedigree Browser’s “Trim
  pedigree based on focal animals” option now includes both the
  **ancestors and descendants** of the focal animals (previously
  ancestors only). Owner chose **Option A — strict lineal** (no
  collateral relatives). Executes S67 SUGGESTED-NEXT \#1.
- **TDD:** first real code session after S57–S67’s non-code run. Three
  phase gates posed via `AskUserQuestion` (PRE-RED→RED, RED→GREEN,
  GREEN→REFACTOR) plus a separate pre-RED Option A/B approach decision.
  **0 stakeholder corrections.**
- **New/changed code:** `R/getDescendantPedigree.R` — new exported
  transitive-offspring closure, the downward mirror of
  [`getProbandPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getProbandPedigree.md).
  `R/modPedigree.R:292-307` — trim block now unions the ancestor closure
  (`trimPedigree`) with the descendant closure:
  `ped[ped$id %in% union(ancestors$id, descendants$id), ]`. UI help text
  (`:125`) and module docstring (`:166`) updated from the “only
  relatives” over-promise to “ancestors and descendants”.
- **Tests (TDD):** NEW `tests/testthat/test_getDescendantPedigree.R` (6
  unit tests on `lacy1989Ped`: transitive offspring, leaf,
  multi-proband, empty, absent, circular-terminates); 2 integration
  tests added to `test_modPedigree_processing.R` (descendants included;
  strict-lineal excludes sibling + mate). One stale pre-existing test in
  `test_modPedigree.R` updated to the new contract — surfaced by the
  full-suite clean-regression read (Learning 68). **Full suite: 972
  tests, 0 failed, 0 error, 159 skip.**
- **Docs/exports:** `devtools::document()` →
  `man/getDescendantPedigree.Rd` + NAMESPACE export;
  `man/modPedigreeServer.Rd` regenerated. **NEWS.md** NEW-47 entry
  (user-facing). Lint clean (lone `object_usage_linter` warning proven
  an install-staleness artifact). Phase 3E:
  `shiny::testServer(modPedigreeServer, …)` integration tests exercise
  the changed reactive.
- **Issue tracker:** \#35 implemented — to be closed (19 → 18 open) once
  the owner confirms.

### 2026-06-13 — Re-scope \#35 to descendants (ancestor-inclusion verified done) (Session 67)

- **Deliverable:** Re-scoped GitHub issue \#35 (was *“Include ancestors
  and descendants in pedigree filtering”*) to **“Include descendants in
  pedigree filtering (ancestors already implemented)”** and kept it
  **open**. Firsthand-verified that ancestor-inclusion is live and
  descendants are not, rewrote the body to current reality, corrected
  two stale references, documented two implementation options, and
  posted a dated verification comment (`#issuecomment-4699260833`).
  Executes S66 SUGGESTED-NEXT \#1.
- **TDD phase = N/A** (issue-grooming; no production code or tests —
  same classification as S57/S61–S66).
- **What’s verified (firsthand):** Ancestors **DONE** —
  `R/modPedigree.R:292-302`: when the “Trim pedigree” checkbox is on it
  calls `trimPedigree(probands, ped, …)` →
  [`getProbandPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getProbandPedigree.md)
  (`R/getProbandPedigree.R:24-40`), an upward `sire`/`dam` closure
  (ancestors only; the module docstring at `:166` already says
  “ancestors”). Descendants **NOT** implemented — neither function walks
  downward.
- **Two stale references corrected in the body:** (1) the issue’s cited
  “Current Code” (lines 246-253, a
  `# TODO: Include ancestors and descendants` placeholder) no longer
  exists — replaced by the ancestor logic at 292-302; (2) its “Suggested
  Implementation” called
  `trimPedigree(…, ancestors = TRUE, descendants = TRUE)` — a signature
  that **does not exist**
  (`trimPedigree(probands, ped, removeUninformative, addBackParents)`).
- **Implementation options documented (owner chose “document
  both”):** (A) strict lineal — add a downward closure mirroring
  `getProbandPedigree`’s loop (repeated
  [`getOffspring()`](https://github.com/rmsharp/nprcgenekeepr/reference/getOffspring.md)
  to closure) and union with the ancestor set; (B) reuse
  [`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)
  (`R/getPedDirectRelatives.R:46-59`), which already loops
  parents+offspring to closure but also pulls in collateral relatives
  (sibs/cousins/mates), broadening beyond lineal. Left for the
  implementation session.
- **Form (owner-chosen via `AskUserQuestion`):** rewrite the body +
  retitle + dated verification comment; issue kept open.
- **Issue tracker:** 19 open issues (unchanged — \#35 updated, not
  closed).

### 2026-06-13 — Merge methodology PR \#25/#27 wording branch into add-methodology (Session 66)

- **Deliverable:** Merged the local out-of-band branch
  `chore/methodology-pr2527-wording` (one wording-only commit
  `ce7d6779`) into `add-methodology`, then deleted it. Adopts the
  merged-upstream methodology PR \#25/#27 wording — **no migration**
  (this repo’s learnings extraction was done in Sessions 10/28; it is
  the reference end-state).
- **TDD phase = N/A** (docs/methodology merge; no `R/`, `tests/`,
  `man/`, or `NEWS.md` changes — same non-code classification as
  S57/S61–S65).
- **What landed (4 files, +10/−5):** SESSION_RUNNER.md §3C body → the
  canonical adopter-vs-canonical learnings-routing text + the
  Learnings-table caption reworded (3C section now byte-identical to
  canonical; the 6 seed rows already matched);
  `docs/methodology/HOW_TO_USE.md` 3C bullet → matching routing text;
  CLAUDE.md + PROJECT_LEARNINGS.md → replace the empirical “40k-char
  limit” justification with the documented size-budget language (“Claude
  Code targets ~200 lines / ~25 KB”); counts and history preserved.
- **Merge mechanics:** true merge commit `0f9728e3` (`--no-ff`; the base
  had diverged — Sessions 63–65 added commits after the branch point
  `b7f45901`). Pre-merge `git merge-tree` dry run showed **0** conflict
  markers; 3 of 4 files were byte-identical to the branch base, and
  PROJECT_LEARNINGS.md auto-merged **keep-both** (branch’s line-3 header
  rewording + the S63/64/65 tail-appended Learning rows —
  non-overlapping hunks).
- **Verified:** all 4 task-spec greps pass — “Adopter project” in
  SESSION_RUNNER.md (3C body + table caption), no “40k” in
  CLAUDE.md/PROJECT_LEARNINGS.md, one “200 lines” in each, and the
  HOW_TO_USE.md 3C routing bullet. Branch deleted with safe
  `git branch -d` (confirmed merged).
- **Build impact:** none — all 4 files are build-ignored
  (`.Rbuildignore` patterns `^CLAUDE.*\.md$`,
  `^PROJECT_LEARNINGS.*\.md$`, `^SESSION_RUNNER.*\.md$`, `^docs$`),
  verified firsthand; `R CMD check` unaffected.
- **Issue tracker:** 19 open issues (unchanged — no issue activity this
  session).

### 2026-06-12 — Update \#37 (exported-functions-unused inventory: 45 of 70 now used) (Session 65)

- **Deliverable:** Updated GitHub issue \#37 (“Exported functions not
  currently used by app”) to current reality and **kept it open**.
  Struck the **45 of 70** listed functions now reached by the app, kept
  the 22 still-unused + 3 S3 methods, corrected the totals (**116 / 155
  used, 39 unused**; was 38 / 108 / 70), fixed the 5 “Notable findings”,
  added a dated re-verification note, and folded in the **17 unused
  exports created since** the issue was filed (2026-01-25). Executes S64
  SUGGESTED-NEXT \#1.
- **TDD phase = N/A** (issue-grooming; no production code or tests
  written — same classification as S57/S61/S62/S63/S64).
- **Method (firsthand, reproducible):** app reachability by call-graph
  closure —
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html),
  seed at `{runModularApp, runGeneKeepR, appUI, appServer}`, transitive
  closure of
  [`codetools::findGlobals`](https://rdrr.io/pkg/codetools/man/findGlobals.html)
  over package functions; exported names outside the closure are
  “unused.” Concrete call paths were produced for the flipped set
  (e.g. `rankSubjects` via
  `appServer → modGeneticValueServer → reportGV → orderReport`; the 4
  Shiny modules called directly by `appServer`; the genotype trio via
  `modInputServer`; `filterKinMatrix/Report/Threshold` via the
  breeding-group + GV modules).
- **Adversarial check of the static method’s blind spots:** the only
  string-dispatched call in `R/` is `do.call("rbind", …)`, and none of
  the 22 still-unused names appear as string literals → no
  dynamic-dispatch invocation the closure missed; the S3 methods aren’t
  dispatched on the app path (the app’s
  [`summary()`](https://rdrr.io/r/base/summary.html) calls hit
  `summary.default` on numeric vectors).
- **Re-grade vs the handoff:** S64 (inheriting the S62 audit) framed
  \#37 as “strike the resolved Shiny-module + genotype rows; keep the
  still-accurate inventory” — implying ≈7 functions flipped and the bulk
  held. Firsthand recomputation found **45/70 flipped** — ~64% stale,
  not 2 clusters. Same classifier-stops-at-the-headline calibration miss
  documented for S62→#14 and S63→#8.
- **Applied form (owner-chosen via `AskUserQuestion`):**
  strikethrough-in-place + dated verification note in the body
  (`gh issue edit 37 --body-file`), plus the 17 newer unused exports; a
  timeline pointer comment (`#issuecomment-4696756359`) makes the
  correction visible to watchers. Issue kept **open** — the 39
  genuinely-unused exports remain the actionable surface (largest
  clusters: the simulated-kinship subsystem and the ORIP reporting
  module).
- **Issue tracker:** 19 open issues (unchanged — \#37 updated, not
  closed).

### 2026-06-12 — Verify + close \#8 (non-founder no-parents handling — caveated close) (Session 64)

- **Deliverable:** Closed GitHub issue \#8 (“Improve handling of
  non-founder animals without either parents assigned”) as
  **implemented**, with a strengthened-caveat resolution comment.
  Executes S63 SUGGESTED-NEXT \#1 (the other STALE candidate from the
  S62 audit) — but firsthand verification + a reproduction re-graded it
  from the audit’s footnote-caveat to a **strengthened caveat with a
  reproduced silent-failure case**.
- **TDD phase = N/A** (verify-and-close; no production code or tests
  written — same classification as S57/S61/S63).
- **What’s implemented (verified firsthand):** both of the issue’s
  proposed solutions are live in the GVA report-ordering path. Solution
  1 (origin/“From Center” segregation) — ONPRC-born founders with no
  offspring are split into a `noParentage` bucket
  (`R/orderReport.R:31,44-54`). Solution 2 (don’t rank them) — those
  animals get `value = "Undetermined"`, `rank = NA`
  (`R/rankSubjects.R:38,44`). Live wiring:
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  → `orderReport(finalData, ped)` (`R/reportGV.R:146`). Tests green
  against source via
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html):
  `test_orderReport.R` 8/0/0/0, `test_rankSubjects.R` 5/0/0/0.
- **The caveats (firsthand, beyond the audit’s note):** (1) **The fix is
  gated on the optional `origin` column and silently does nothing
  without it.** The whole `noParentage` block is wrapped in
  `if ("origin" %in% names(rpt))` (`R/orderReport.R:31`); `origin`
  reaches the report only when the source pedigree carries it
  (`R/reportGV.R:119` `intersect(getIncludeColumns(), names(ped))`) and
  is documented optional. **Reproduced:** a no-parent founder with no
  offspring → `value = "High Value", rank = 1` (the original bug)
  without `origin`, vs `"Undetermined"/NA` with it — no warning when the
  safeguard doesn’t apply. (2) **No regression test pins the
  `Undetermined`/`rank = NA` branch** — `test_orderReport` exercises the
  path but asserts only positional unknown-ID counts;
  `test_rankSubjects` never exercises `noParentage`. (3) **The 2021
  simulated-kinship subsystem is orphaned** — `getPotentialParents`,
  `createSimKinships`, `kinshipMatricesToKValues`,
  `summarizeKinshipValues`, `countKinshipValues`,
  `addKinshipValueCount`, `cumulateSimKinships` are exported but have no
  live caller in `R/` (present only in tests,
  `inst/extdata/trulyUnknownParents.R`,
  `vignettes/simulatedKValues.Rmd`); the issue’s “discuss with Matt”
  design item is unresolved. These remaining items are recorded in the
  close comment as candidate enhancements but **not filed** (new-issue
  creation outside the approved “close with caveat” scope — S63 lesson).
- **Method (right-sized under ultracode):** firsthand source read + a
  direct **reproduction** of the origin-gating failure + `load_all` test
  runs + a 3-lens adversarial refute-the-close workflow
  (`wf_f37f1b72-b6a`). The gate split 1 hold-open / 2 close-with-caveat;
  the hold-open verdict (origin-gating makes the fix illusory in the
  common case) was reconciled firsthand via the reproduction, which
  upgraded the caveat and was surfaced to the owner via
  `AskUserQuestion` before the irreversible close.
- **Issue tracker:** 19 open issues remain (was 20).

### 2026-06-12 — Verify + close \#14 (genotype provide+track — caveated close) (Session 63)

- **Deliverable:** Closed GitHub issue \#14 (“Add ability to provide
  genotypes for animals within the pedigree and track them”) as
  **implemented**, with a caveat resolution comment. Executes S62 audit
  recommendation \#1 — but firsthand verification re-graded it from the
  audit’s “clean” classification to **close-with-caveat**.
- **TDD phase = N/A** (verify-and-close; no production code or tests
  written — same classification as S57/S61).
- **Verified firsthand:** the genotype provide+track ability is
  live-wired and test-pinned.
  `getGenotypes`/`checkGenotypeFile`/`addGenotype` read + integer-code +
  merge in the modular app’s separate-genotype-file mode
  (`R/modInput.R:384-396`); the integer `first`/`second` columns ride
  the cleaned studbook into
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  → `getGVGenotype` (`R/reportGV.R:78`) → `geneDrop(genotype=…)` (`:92`)
  → `calcGU`/`calcFG`; the functions are exported for scripting; **278
  genotype-path assertions pass (0 fail / 0 err / 0 skip)**, including
  the end-to-end `modInputServer` separate-file test
  (`tests/testthat/test_modInput_qcStudbook.R:536-545`). Live entry
  point:
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  → `shinyApp(appUI(), appServer)` → `modInputUI/Server("dataInput")`.
- **The caveat (deliberate, owner-authored):** the combined-file UI mode
  (`commonPedGenoFile`) does **not** integer-code string alleles, so
  genotypes supplied in a single combined file don’t reach gene-drop —
  at parity with the legacy monolith (per commit `c9019d51`’s own
  rationale). Documented in the close comment; extending tracking to the
  combined-file mode is noted there as a candidate future enhancement
  (not filed — new-issue creation was outside the approved scope).
- **Method (right-sized under ultracode):** firsthand source read +
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)
  test run + a 3-lens adversarial refute-the-close workflow
  (`wf_9d00a37a-6d0`). The refute pass earned its keep: the
  intent-completeness lens surfaced the combined-file caveat that
  re-graded the close, and a test-authenticity “tests are failing”
  refutation was correctly traced to a **stale installed binary** (the
  source tests pass green) rather than a real regression.
- **Issue tracker:** 20 open issues remain (was 21).

### 2026-06-12 — Backlog-staleness audit of all 21 open GitHub issues (Session 62)

- **Deliverable:** `docs/audits/BACKLOG_STALENESS_AUDIT_2026-06-12.md` —
  a read-only audit classifying every open issue as **STALE** (already
  implemented), **PARTIAL**, or **OPEN** against the current code,
  motivated by S61’s finding that \#34 was resolved in code but stayed
  open. Generalizes that one-issue check to the whole tracker. **No
  code, tests, or issues changed** (closing is a recommended follow-up,
  not executed — 1-and-done).
- **TDD phase = N/A** (read-only audit; no production code or tests
  written — same classification as the S57/S61 non-code sessions).
- **Result:** **2 STALE / close candidates** (#14 genotype provide+track
  — clean close, \#34-grade; \#8 non-founder no-parents handling — close
  *with caveat*: both proposed solutions are live but gated on the
  optional `origin` column and lack a direct test assertion); **5
  PARTIAL** (#1, \#5, \#9, \#35, \#37 — keep open with narrowed scope;
  \#37 should be *updated*, not closed); **14 genuinely OPEN** (#2, \#4,
  \#10, \#11, \#12, \#13, \#26, \#28, \#29, \#31, \#32, \#33, \#36, \#38
  — cited TODOs still present verbatim or no implementation exists).
- **Method:** 24-agent classify→adversarial-verify workflow (one
  classifier per issue, searching by *content* not stale line numbers;
  every STALE call handed to an independent skeptic told to refute it).
  The adversarial pass **knocked down a false-STALE on \#1** — its
  `Clear Focal Animals` checkbox clears the IDs reactive but not the
  file-browser input, exactly as the owner’s own 2020 GitHub comment
  notes — and downgraded \#8 to a caveated close. All close-relevant
  calls (#14, \#8, \#1) were re-verified firsthand by the session
  against source + `gh api`.
- **Structural findings:** the issue tracker lags the code only in the
  resolved→still-open direction (no false “open”); the auto-generated-ID
  cluster (#38/#32/#26 + dam-ID \#31) is one feature split across four
  issues — recommend consolidating; the old external-system requests
  (#10/#11/#12/#13/#28) are correctly open and large. Report placed
  under `docs/audits/` (build-ignored via `^docs$`) so it does not
  regress S60’s top-level-files-NOTE elimination.

### 2026-06-12 — Verify and close issue \#34 (`qcStudbook` already integrated in `modInput`) (Session 61)

- **Closed issue \#34** (“Integrate qcStudbook() in modInput Shiny
  module”, bug/high). The placeholder QC logic the issue describes
  (`# TODO: Replace with actual qcStudbook() call` +
  `results$cleaned <- rawData`) was already replaced by a real
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)/[`runQcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/runQcStudbook.md)
  integration during the Shiny-module conversion (commit `7da01afe`,
  extended `c9019d51`/`bb7f2be6`); CHANGELOG’s Session-20 entry already
  noted \#34 as “stale (already integrated)” but the GitHub issue was
  never formally closed. This session verified the resolution firsthand
  and closed it with a resolution comment. **No code changed.**
- **TDD phase = N/A** (verify-and-close; no production code or tests
  written — same classification as the S57 close of \#30).
- **What’s wired:** `R/modInput.R:408` calls
  `qcStudbook(rawData, minParentAge, reportChanges=TRUE, reportErrors=TRUE)`;
  `:423` calls the two-pass wrapper
  [`runQcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/runQcStudbook.md)
  (`R/runQcStudbook.R`); `R/processQcStudbookResult.R` shapes results
  for the UI; `minParentAge` is read from the UI input with safe
  coercion (`:398-404`); live path confirmed `appUI.R:123`
  (`modInputUI("dataInput")`) → `appServer.R:104` (`modInputServer`).
- **Verification (firsthand):** `test_qcStudbook.R` 38/0/0/0 +
  `test_modInput_qcStudbook.R` 90/0/0/0 (pass/fail/err/skip). The
  [`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)
  module tests ran (**0 skips**; `shiny` installed), driving
  `modInputServer` and asserting the cleaned studbook carries the `gen`
  column that only
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  adds (`test_modInput_qcStudbook.R:296`) — that assertion would FAIL if
  the module were reverted to the placeholder, so the integration is
  regression-pinned. A 3-lens adversarial refute-the-close workflow
  (residual-placeholder/live-path ‖ functional-completeness ‖
  test-authenticity) returned refuted=false / high confidence / 0 gaps
  on all three lenses.

### 2026-06-12 — `.Rbuildignore` excludes all non-shipping top-level dev/audit files — “non-standard top-level files” NOTE eliminated (Session 60)

- **Deliverable:** added `.Rbuildignore` patterns for the 8
  currently-shipping non-standard top-level files so they are dropped
  from the build tarball, **eliminating** the R CMD check “non-standard
  files/directories found at top level” NOTE entirely — the built
  tarball’s top level is now only the 5 standard files (`DESCRIPTION`,
  `NAMESPACE`, `NEWS.md`, `README.md`, `LICENSE`). Excluded:
  `20250504_cran-comments.md` (the 8th dated cran-comments file — its 7
  siblings were already individually ignored),
  `methodology_dashboard.py`, `dashboard.html`,
  `nprcgenekeepr_notes.txt`, `RECOMMENDED_SKILLS.md`,
  `PED_GV_AUDIT_2026-05-30.{md,html}`, `TECH_DEBT_AUDIT_2026-05-30.md`.
  This is the deferred “scope-B” follow-up S58/S59 surfaced (a
  tarball-contents change, distinct from the pure dupe-guards of
  S58/S59).
- **Owner decisions (`AskUserQuestion`):** (1) scope = exclude **all 8**
  (none are package content) → eliminate the NOTE; (2) style = broad
  dupe-guarded + consolidate — the 7 dated
  `^YYYYMMDD_cran-comments\.md$` exact lines replaced by one
  `^[0-9]+_cran-comments\.md$` regex (covers 20250504 + any future dated
  file, so a new one never silently ships again), and the synced
  methodology/audit files use `<NAME>.*` forms
  (`^RECOMMENDED_SKILLS.*\.md$`, `^PED_GV_AUDIT.*`,
  `^TECH_DEBT_AUDIT.*`) that also catch macOS sync dupes; the non-synced
  files (`methodology_dashboard.py`, `dashboard.html`,
  `nprcgenekeepr_notes.txt`) use tight exact-match.
- **TDD phase = N/A** (build-config only; `.Rbuildignore` is dropped
  from the built tarball → no shippable `testthat` assertion; same
  rationale as S58/S59).
- **Verification (firsthand, authoritative at the build level):** staged
  3 real spaced dupes (`RECOMMENDED_SKILLS 2.md`,
  `PED_GV_AUDIT_2026-05-30 2.md`, `TECH_DEBT_AUDIT_2026-05-30 2.md`),
  ran `R CMD build --no-build-vignettes --no-manual .` (RC=0 → no
  regex-comment abort); the resulting tarball’s top level contained
  **exactly** the 5 standard files — none of the 8 excluded files and
  none of the 3 staged dupes (685 files, down from the 693-file baseline
  = the 8 removed). The “non-standard top-level files” NOTE is a pure
  function of the tarball’s top-level entries, so this directly confirms
  the NOTE is gone (full `devtools::check()` not re-run — nothing
  affecting tests/examples/metadata changed; consistent with S58/S59).
  The complete 8-file set was enumerated by building the baseline
  tarball first (S59’s candidate list named only 4 of the 8). Temp
  dupes + tarballs removed via `trap cleanup`; tree clean.

### 2026-06-12 — `.Rbuildignore` macOS-dupe guard generalized to the whole methodology `.md` cluster (Session 59)

- **Deliverable:** generalized Session 58’s SESSION_NOTES dupe-guard to
  the rest of the top-level methodology/doc `.md` files. Broadened 7
  exact-match `.Rbuildignore` patterns to the `<NAME>.*\.md$` form —
  `PROJECT_LEARNINGS`, `CLAUDE`, `SESSION_RUNNER`, `SAFEGUARDS`,
  `BACKLOG`, `ROADMAP`, `CHANGELOG` (`.Rbuildignore:78-85`) — so macOS
  file-sync duplicates (`CLAUDE 2.md`, `CHANGELOG copy.md`, …) of any of
  them are build-ignored and can never re-raise the R CMD check
  “non-portable file names” WARNING. After S58 only `SESSION_NOTES` was
  `.*`-guarded; this kills the dupe-WARNING class for the whole
  methodology cluster. (Owner decisions via `AskUserQuestion`: loose
  `.*` style to match the S58 line; scope limited to the already-ignored
  cluster — adding currently-unignored docs such as
  `RECOMMENDED_SKILLS.md` deferred as a separate tarball-contents
  change.)
- **TDD phase = N/A** (build-config only; same rationale as S58 —
  `.Rbuildignore` is dropped from the built tarball, so there is no
  shippable `testthat` assertion).
- **Verification (firsthand, both levels):** (1) regex probe across all
  7 names — OLD exact patterns miss every dupe form (the leak); NEW `.*`
  form matches `<NAME> 2.md` and `<NAME> copy.md` while NOT
  over-matching `<NAME>.Rmd` / `<NAME>_archive.txt`, and canonical names
  stay excluded. (2) build-equivalent (authoritative) — staged 14 real
  spaced dupes (both forms × 7 names), ran
  `R CMD build --no-build-vignettes --no-manual` (RC=0); the resulting
  tarball (693 files) contained **zero** of the 7 names as `.md` → all
  dupes + canonicals excluded, real content (DESCRIPTION/NAMESPACE)
  present. Temp files + tarball removed via `trap cleanup`; tree clean.
- **In-flight finding (caught by the build step, not shipped):**
  `.Rbuildignore` lines are *all* perl regexes — including `#` comment
  lines (they simply match no real path). An initial multi-line comment
  with an unbalanced `(` made `R CMD build` abort with
  `invalid regular expression`; fixed to regex-safe comment lines, plus
  an inline NOTE warning future editors. (See PROJECT_LEARNINGS Learning
  59.)

### 2026-06-12 — `.Rbuildignore` permanent macOS-dupe fix (Session 58)

- **Deliverable:** broadened `.Rbuildignore`’s `^SESSION_NOTES\.md$` →
  `^SESSION_NOTES.*\.md$` so macOS file-sync duplicates
  (`SESSION_NOTES 2.md`, `SESSION_NOTES 3.md`, `SESSION_NOTES copy.md`,
  …) are build-ignored and can never again re-enter the build tarball to
  re-raise the R CMD check “non-portable file names” WARNING that
  Session 57 had to clear by hand. This is the permanent fix S57
  deferred (root cause: an exact-match build-ignore pattern doesn’t
  cover the space-name); the prior `^\.Rhistory\ 2$` entry shows the
  same class was patched narrowly once before.
- **TDD phase = N/A** (build-config only; no R code, no shippable unit
  test — `.Rbuildignore` is dropped from the built tarball, so a
  `testthat` assertion on it can’t run under R CMD check).
- **Verification (firsthand):** (1) regex probe — OLD pattern matches
  `SESSION_NOTES.md` only; NEW matches all dupe variants and
  over-matches nothing (`CHANGELOG.md`, `SESSION_NOTES_archive.txt` stay
  excluded; canonical `SESSION_NOTES.md` still excluded). (2)
  build-equivalent — staged a real `SESSION_NOTES 2.md`, ran
  `R CMD build` (RC=0); the resulting tarball contained **zero**
  SESSION_NOTES entries → the dupe is excluded and the WARNING cannot
  fire. Temp file + tarball removed; tree clean. (Full
  `devtools::check()` intentionally skipped — the WARNING is a pure
  function of tarball contents, verified directly.)

### 2026-06-12 — Close issue \#30 + repo hygiene (Session 57)

- **Closed issue \#30** (“work on use of lintr until satisfied with code
  style”). The plan deliverable
  (`docs/planning/issue30-lintr-exclusion-cleanup-plan.md`) is complete:
  `lintr::lint_package()` = **0** (re-verified firsthand this session),
  every `R/`-file `.lintr` line-specific exclusion removed except the
  deliberately-kept `makeGeneticDiversityDashboard` (author
  won’t-delete, `.Rbuildignore`’d). The CI `lint` check is GREEN. Closed
  with a resolution comment summarizing Phases 1–4 (Sessions 53–56).
  Optional trivial follow-up noted on the issue: convert the lone
  remaining range-exclusion to an inline `# nolint start/end` block
  (plan §4C \#16).
- **Repo hygiene:** removed the untracked macOS-duplicate
  `SESSION_NOTES 2.md` (563 KB, never committed, content fully contained
  in `SESSION_NOTES.md`). Its space-in-filename was the sole cause of
  the `devtools::check()` “portable file names” **WARNING**
  (`.Rbuildignore`’s `^SESSION_NOTES\.md$` exact-match does not cover
  the space-name, so the dupe entered the build tarball). **Verified
  firsthand:** post-removal `devtools::check()` = **0 errors / 0
  warnings / 3 NOTEs** (was 1 WARNING at S56) → the WARNING is cleared.
  The 3 residual NOTEs are all pre-existing/environmental (clock-skew
  future-timestamps, spelling, and “non-standard top-level files” — the
  latter now lists only no-space methodology/audit files:
  `20250504_cran-comments.md`, `PED_GV_AUDIT_2026-05-30.{html,md}`,
  `RECOMMENDED_SKILLS.md`, `TECH_DEBT_AUDIT_2026-05-30.md`,
  `dashboard.html`, `methodology_dashboard.py`,
  `nprcgenekeepr_notes.txt`; the build-ignored `..Rcheck/` does not
  appear).

### 2026-06-12 — Issue \#30 Phase 4: behavior-sensitive lint refactors + de-exclude (Session 56)

- **Deliverable:** implemented Phase 4 (the final exclusion-cleanup
  phase) of the issue \#30 plan — the **6 behavior-sensitive `.lintr`
  line-exclusions** (5 §4B + the reclassified `checkRequiredCols`).
  After this, the **only** `R/`-file line exclusion left is
  `makeGeneticDiversityDashboard` (deliberately kept);
  `lintr::lint_package()` stays **0**.
- **`checkRequiredCols.R` (RED→GREEN→REFACTOR, commit `17e3fa06`):**
  `as.character(unlist(sapply(...)))` →
  `requiredCols[!requiredCols %in% cols]`. Owner-chosen robust contract:
  on out-of-contract `NA`-in-`cols` (reportErrors=TRUE) it now returns
  the missing cols cleanly instead of erroring
  (`"missing value where TRUE/FALSE needed"`); non-NA output
  byte-identical, `reportErrors=FALSE` untouched. Pinned by a RED
  NA-contract test; `@details` documents it.
- **4 behavior-none REFACTORs (commit `69c8d759`, all adversarially
  verified):** `correctParentSex.R` (if/else inverted to a guard clause;
  6000-iter fuzz identical incl. error messages);
  `fillGroupMembersWithSexRatio.R` (`else { if }` → `else if`, inline
  `# nolint` deleted; 146 seeded cases identical); `setExit.R` (`mapply`
  → `unlist(Map(...))`, `chooseDate` always length-1; 21 inputs
  identical).
- **`addSexAndAgeToGroup.R` (adopted-robust REFACTOR, commit
  `69c8d759`):** `sapply` → `ped$sex[match(ids, ped$id)]`. Adversarial
  verification found that on **empty `ids`** the old `sapply` form
  dropped the `sex` column (2-col result), which **crashed** the one
  caller (`modBreedingGroups.R:438` `colnames(gp) <- c(<3 names>)`) on
  an empty group; the [`match()`](https://rdrr.io/r/base/match.html)
  form returns the documented 3-column schema (sex an empty factor) and
  renders an empty table. Owner adopted the new behavior as intentional;
  pinned by an empty-ids contract test + a happy-path characterization
  test; `@details` documents it.
- **`create_wkbk.R` (accepted-divergence REFACTOR, commit `69c8d759`):**
  inner `if (replace)` → guard clause `if (!replace)`. Owner-accepted
  cosmetic divergence: on a non-logical non-coercible `replace` while
  the file exists, both versions error but the message text differs
  (`"argument is not interpretable as logical"` →
  `"invalid argument type"`); `replace` is documented logical, coercible
  values identical.
- **Verification:** `lint_package()` = 0; the 6 files lint-clean
  (`parse_settings=FALSE`); full suite **0 fail / 0 err / 159 skip**
  (S49 baseline + 5 new passing expectations from the
  contract/characterization tests → zero regression);
  `devtools::check()` **0 errors** (1 pre-existing-environmental
  WARNING + 2 NOTEs from stray top-level files incl. the macOS
  `SESSION_NOTES 2.md` dupe — not from this change); adversarial
  behavior-verification workflow `wf_168f8dcf-1e5` (6 skeptics, each
  told to refute). Phase-3E: `addSexAndAgeToGroup`’s runtime integration
  is covered by `test_modBreedingGroups.R:1015-1122` (the
  breeding-groups member view), green in the full suite.

### 2026-06-11 — Issue \#30 Phase 3: behavior-none lint refactors + `.lintr` casing fix (Session 55)

- **Deliverable:** implemented Phase 3 of the issue \#30 plan — **6
  behavior-none lint refactors**, each removing its `.lintr`
  line-exclusion in the same change (\[lint-net-zero\]).
  `lintr::lint_package()` stays **0**.
- **Refactors (all adversarially verified behavior-preserving):**
  `convertFromCenter.R` + `fillGroupMembers.R` + `hasGenotype.R`
  (`unnecessary_nesting` collapses — drop an `else` after an
  unconditional
  [`stop()`](https://rdrr.io/r/base/stop.html)/[`return()`](https://rdrr.io/r/base/function.html);
  `else { if }` → `else if`); `getLkDirectAncestors.R` +
  `getLkDirectRelatives.R` (rename local var `source` → `msgSource`,
  which `undesirable_function_linter` flagged as shadowing
  [`base::source`](https://rdrr.io/r/base/source.html); also dropped 2
  now-redundant inline nolints); `saveDataframesAsFiles.R`
  (`unnecessary_lambda` →
  `vapply(dfList, inherits, logical(1L), what = "data.frame")`).
- **`.lintr` casing bug fixed** (owner-flagged): `R/CheckRequiredCols.R`
  → `R/checkRequiredCols.R` — the capital-`C` entry matched nothing on
  case-sensitive CI, so the L34 lint would fire on the Linux `lint`
  runner.
- **`checkRequiredCols.R` (planned Phase 3 \#1) reclassified to Phase
  4:** adversarial verification + firsthand repro proved its
  `sapply`→`%in%` fix is NOT behavior-none — on out-of-contract
  `NA`-in-`cols` it turns a thrown error into a clean missing-columns
  return (exported fn). Owner-approved deferral (`AskUserQuestion`) to a
  RED→GREEN→REFACTOR slice in Phase 4; the file’s code + `.lintr` entry
  left as-is (casing now correct).
- **Verification:** `lint_package()` = 0; the 6 files lint-clean
  (`parse_settings=FALSE`); full suite **2140 pass / 0 fail / 0 err /
  159 skip** (= S49 baseline → zero regression); `devtools::check()` **0
  errors** (1 pre-existing-environmental WARNING + NOTE from stray
  top-level files incl. a macOS `SESSION_NOTES 2.md` dupe — not from
  this change); `man/` untouched.

### 2026-06-11 — Implement issue \#30: drive the R/ lint check to GREEN (Session 54)

- **Deliverable:** implemented the issue \#30 cleanup plan;
  `lintr::lint_package()` now reports **0 lints** in `R/` (was 193 = 41
  suppressed by `.lintr` line-excludes + 152 residual) → the CI `lint`
  check goes green.
- **Phase 1 (commit `74a46d4c`):** removed dead commented code in
  `getErrorTab.R`, `get_elapsed_time_str.R`,
  `print.summary.nprcgenekeeprErr.R`; stripped a stray `#'` in
  `set_seed.R` (also fixed a `#'` leak into `man/set_seed.Rd`); removed
  the 4 now-unneeded `.lintr` line exclusions + the dead
  `#commented_code_linter = NULL` no-op; kept
  `makeGeneticDiversityDashboard` (author won’t-delete, NEW-20).
- **Residual (this commit):** fixed the 154 firing lints across 17 `R/`
  files + `inst/shinytest/app.R` via a per-file
  editor→adversarial-verifier workflow (one editor + one verifier per
  file; 150+ fixes, all 18 files verified behavior-preserved). **Owner
  decisions (`AskUserQuestion`):** (1) keep `implicit_integer_linter` ON
  and fix all 74 with `L` (counts/indices/widths) or `.0` (reals,
  e.g. `ped$age * 12.0`) — NOT disable;
  2.  targeted inline `# nolint` for the 16 verified false-positives /
      justified idioms. Mechanical fixes: `line_length` wraps, `brace`,
      `keyword_quote`, `return`,
      `paste(collapse=)`→[`toString()`](https://rdrr.io/r/base/toString.html),
      `sapply`→`vapply`, `if`/`else if` chain →
      [`switch()`](https://rdrr.io/r/base/switch.html) in
      `logModuleEvent.R`; removed the stale `getPyramidPlot.R = 25:27`
      exclusion.
- **`# nolint` (verified non-bugs):** `object_usage` ×6
  (package-internal `calcFounderContributions`/`gatedSeed` lintr can’t
  resolve + `founderStats` which IS a `modSummaryStatsServer` formal),
  `nonportable_path` ×3 (MIME strings), `object_name` ×2 (base-R
  `launch.browser` arg),
  [`library()`](https://rdrr.io/r/base/library.html) ×2 (shinytest
  harness), [`par()`](https://rdrr.io/r/graphics/par.html) ×3 (CRAN
  save/restore idiom).
- **Verification (firsthand):** `lint_package()` = 0; full test suite
  **2140 pass / 0 fail / 0 err / 159 skip** (S49 baseline held exactly —
  zero behavior regression); `document()` regenerated 3 man pages
  (roxygen reflow, content identical); **Phase-3E** — booted the app
  from `load_all` source: all 7 module UI builders constructed and
  `runModularApp` served HTTP 200 / 92 KB.
- Issue \#30 remains OPEN pending owner confirmation to close (the
  `lint` check is now green).

### 2026-06-11 — Plan issue \#30: resolve the `.lintr` line-specific exclusions (Session 53)

- **Deliverable (planning):**
  `docs/planning/issue30-lintr-exclusion-cleanup-plan.md` — an
  evidence-based plan to remove most of the 18 `"file" = line` entries
  in `.lintr`’s `exclusions: list()` by fixing the underlying lint, plus
  a strategy for the 152 residual lints. **No `R/`, `tests/`, or
  `.lintr` content changed** (plan only; implementation is the
  subsequent sessions, one phase at a time — FM \#18/#25).
- **Evidence base:** firsthand `lint_package(parse_settings=FALSE)`
  (bypassing the exclusions so the suppressed lints are visible) = **41
  lints suppressed by the 18 line-excludes + 152 residual = 193 total in
  `R/`**; cross-checked by an 18-file parallel examination workflow
  (`wf_c7863094-8f1`, one agent per file proposing the exact fix + risk
  rating) with adversarial verification of every behavior-affecting fix
  and commented-code deletion. **Three agent conclusions were
  corrected** by verification/reproduction (see plan §6).
- **Dispositions:** FIX 15 entries (~38 lints; 10 behavior-none, 5
  low-risk verified-safe), KEEP-EXCLUDE 1
  (`makeGeneticDiversityDashboard.R` — author won’t-delete, NEW-20),
  REMOVE-STALE + fix real lints 1 (`getPyramidPlot.R = 25:27` suppressed
  0 lints).
- **Config bugs found:** (1) `.lintr` lists `"R/CheckRequiredCols.R"`
  (wrong case) → the exclusion misses on case-sensitive CI; (2) the
  `getPyramidPlot.R = 25:27` exclusion is dead config; (3) the `source`
  “undesirable function” hits are a local variable named `source`,
  fixable by rename (zero behavior change); (4) `commented_code_linter`
  IS active via the tag set — the `#commented_code_linter = NULL` line
  is a dead no-op (resolves the issue \#30 confusion).
- **Learning \#53** (parse_settings=FALSE auditing trap; line-number
  drift both ways; verify-first over agent headlines). \#30 stays OPEN
  (planning deliverable; implementation pending).

### 2026-06-11 — Fix issue \#42: repoint pkgdown output off `docs/`; fix unmasked vignette bug; pkgdown GREEN on master (Session 52)

- **Deliverable (CI config + vignette fix / run-and-observe):** the
  `pkgdown` workflow failed its Build-site step on a fresh CI clone
  because `docs/methodology/` + `docs/planning/` are git-tracked inside
  pkgdown’s default `docs/` output dir (no `pkgdown.yml` sentinel →
  `clean_site()` refuses to wipe a dir it didn’t build → exit 1).
- **Fix = Option 2 (repoint pkgdown), not the issue’s recommended Option
  1 (relocate the doc trees).** Surfaced the choice via
  `AskUserQuestion`: Option 1 conflicts with the methodology framework’s
  own `docs/methodology/` convention — the synced
  `methodology_dashboard.py` scores that path and the synced
  `SESSION_RUNNER.md`/ `SAFEGUARDS.md` cross-link it (none durably
  editable in-repo). Verified from pkgdown 2.1.1 source + empirically
  that `build_site_github_pages()` overrides `_pkgdown.yml`’s
  `destination:` via `override = list(destination = dest_dir)`, so the
  yml alone is insufficient for CI. Commit `fcc154e8`: workflow
  `dest_dir = "pkgdown_site"` + deploy `folder: docs → pkgdown_site`;
  `_pkgdown.yml destination: pkgdown_site`;
  `.gitignore += pkgdown_site/`; `.Rbuildignore += ^pkgdown_site$`. No
  file moves; `docs/methodology`/`docs/planning`/dashboard/synced
  cross-refs untouched; gh-pages URL unchanged; no `R/` or `tests/`
  change.
- **Unmasked + fixed a separate latent bug** (commit `e89975c8`): with
  `clean_site` resolved, the build reached vignette rendering and failed
  on `ColonyManagerTutorial.Rmd` — its error table paired
  `names(getEmptyErrorLst())` (10 types) with 9 hardcoded descriptions
  (“arguments imply differing number of rows: 10, 9”). The NEW-45 “no
  period in IDs” feature added the `invalidIdChars` type without
  updating the vignette; added the missing description. This vignette is
  `.Rbuildignore`’d, so R CMD check never builds it — only pkgdown does
  (it ignores `.Rbuildignore`) — which is why it was green on all 5
  R-CMD-check platforms yet fatal to pkgdown.
- **Validation (firsthand):** PR \#43 pkgdown run `27361729368`
  (fresh-clone) SUCCESS → merged `--merge` to master `c6ad23dd` → master
  push run `27362288625` Build site **SUCCESS** + Deploy **SUCCESS**.
  **Closed issue \#42.** Remaining CI red is lint (#30, known/accepted).

### 2026-06-11 — Promote `add-methodology` → master (PR \#41) and live-validate `shinytest2`; close issue \#40 (Session 51)

- **Deliverable (integration / run-and-observe):** promoted the
  long-lived `add-methodology` branch (105 commits / 356 files /
  +44,473−2,892; master a strict ancestor → 0 behind → clean
  conflict-free merge) to **master via PR \#41** (merge commit
  `0363ffe3`, `--merge` to preserve the multi-session TDD history —
  never squashed). Pre-flight build-equivalent gate (non-e2e
  clean-regression read) = **2140 pass / 0 fail / 0 err / 0 non-e2e
  offenders** (S49 baseline held); no branch protection on master.
- **Held the merge for the PR’s first-ever remote CI**, triaging each
  red to root cause: **R-CMD-check passed on all 5 platforms** (macOS,
  Windows, ubuntu release/devel/oldrel-1) + test-coverage passed →
  package correctness intact; **pkgdown FAIL** = real but
  doc-site-deploy-only (`docs/methodology`+`docs/planning` tracked
  inside pkgdown’s `docs/` output dir → `clean_site()` refuses to clean
  a non-pkgdown `docs/`) → logged as **issue \#42**; **lint FAIL** =
  known style debt (#30); **codecov/patch+project FAIL** =
  external/advisory thresholds. Owner decision (`AskUserQuestion`):
  “merge now, fix pkgdown later”.
- **Live validation (owner-designated gate):** `workflow_dispatch`-ed
  `shinytest2` on master → run `27356752221` **SUCCESS** (~19 min). All
  **13 per-module groups** (fresh `Rscript` each) reported
  `passed>0 failed=0 error=0` (“All 13 E2E module groups passed.”). Both
  Session-34 live-runner watch items resolved on the first run:
  1.  renv lib-path resolution under
      `RENV_CONFIG_AUTOLOADER_ENABLED=false` (`R CMD INSTALL` + every
      AppDriver subprocess booted the app); (2) the 23-in-one-process
      Chrome flake — the 8e-7 per-module fresh-process grouping produced
      ZERO transient errors (first environmental confirmation; per-group
      isolation contains any future transient).
- **Closed issue \#40** (“Strengthen shinytest2 E2E assertions”) with a
  full validation comment — the §8e assertion-strengthening +
  CI-stability campaign is code-complete and live-validated on master.
- **Follow-ups logged (not done this session):** **\#42** (relocate
  methodology docs out of pkgdown’s `docs/`), **\#30** (lintr cleanup) —
  both independent of package correctness.

### 2026-06-10 — Phase 8e-7 (CI per-module fresh-process grouping): run the 23-file shinytest2 E2E tier in 13 per-module groups, each in a fresh R process, to defang the 23-in-one-process Chrome flake (issue \#40, Session 50)

- **Deliverable (CI config / run-and-observe):** plan slice **8e-7**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §8/§8e-7 —
  the FINAL §8e slice) — replaced the single
  `test_dir(filter = "^(app|e2e)-", stop_on_failure = TRUE)` run step in
  `.github/workflows/shinytest2.yaml` with a **single job that loops
  over 13 per-module group regexes, each run in a fresh `Rscript`
  process**, so no one process accumulates 23 Chrome/AppDriver instances
  (the S34 “process-count dragon”: ~1 transient error / 5 full-tier
  single-process runs). Caps any process at ≤3 files.
- **Per group:** `test_dir(filter = rx, stop_on_failure = FALSE)` → a
  `passed/failed/skipped/error` report → fail/error \> 0 ⇒
  `quit(status = 1)` (checked FIRST, so a real failure is never
  mislabeled) → passed == 0 ⇒
  [`stop()`](https://rdrr.io/r/base/stop.html) **per-group silent-skip
  guard** (stronger than the old whole-run guard; a zero-match regex is
  caught separately by `test_dir`’s own “No test files found” abort).
  The bash loop runs ALL groups (full signal, one flake doesn’t skip the
  rest) and reds the job if ANY group failed — preserving
  `stop_on_failure` semantics + the job env / Chrome provisioning /
  `R CMD INSTALL` / `timeout-minutes: 30` / removed `continue-on-error`
  (R6).
- **Owner-gated topology** (`AskUserQuestion`): single-job loop chosen
  over a 13-leg `strategy.matrix` (cheapest, plan-faithful,
  root-cause-sufficient — the matrix’s 13× setup wasn’t worth it for a
  nightly job). TDD = run-and-observe (CI config; no RED→GREEN, plan
  §6), gated `PRE-RED→run-and-observe`.
- **Verified locally:** the COMMITTED 13-regex partition selects EXACTLY
  the 23 `^(app|e2e)-` files — union == tier, no overlap / gap / stray —
  against the full 182-file dir (replicating testthat’s stripped-name
  match, Learning \#33c); YAML parses (`yaml.safe_load`); run-step
  `bash -n` clean; the `Rscript -e '...'` block is single-quote-free;
  the run-step logic smoked on a throwaway dir (pass→exit 0, fail→exit
  1, skip / nomatch → nonzero) — all four branches.
- **⚠ Live-runner-only (FM \#24’s cousin):** the flake mitigation is
  environmental — the partition / guard / exit logic is proven locally,
  but the 23-in-one-process flake can only be confirmed gone on the
  first live GitHub run (which requires the workflow on `master`). Ships
  UNVALIDATED locally; not claimed fixed until a live run shows it.
  Pushing `add-methodology` → master remains a SEPARATE deliverable.
- **Scope:** CI-config only (no `R/` / `tests/` change → the test suite
  is byte-identical). CHANGELOG-only (no package/source change).

### 2026-06-10 — Phase 8e-6c (real breeding-group flow): the 3 export-NULL’d Breeding-Groups E2E blocks become genuine data-bearing assertions → 8e-6 COMPLETE (issue \#40, Session 49)

- **Deliverable (implementation):** plan slice **8e-6c**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §5/§8e-6)
  — the **third and final vertical 8e-6 flow**, completing the triad
  (pedigree ✓8e-6a, GVA ✓8e-6b, breeding ✓8e-6c). Drives the real
  breeding pipeline opt-in:
  `upload_and_wait(app, obfuscated_rhesus_mhc_ped.csv)` →
  `navigate_to_tab("Breeding Groups")` →
  `set_inputs(animalSource = "all", nIterations = 5)` →
  `click_element_safe("#breedingGroups-formGroups")` →
  `wait_for_module_ready("breedingGroups")` →
  `click_element_safe("a[data-value='Group Detail']")`, then asserts the
  rendered Group-Detail export buttons + DTs. Revives the 3
  export-NULL’d Breeding-Groups blocks from Session 43 (D5
  `test-e2e-breeding-groups-detailed.R:89` export functionality, T7
  `-tutorial.R:135` group export options, T9 `-tutorial.R:178`
  kinship-matrix export per group) from pane-active-only into
  data-bearing checks. Scope fixed by the owner’s “8e-6c” instruction;
  full **RED→GREEN** (3 `AskUserQuestion` phase gates), REFACTOR
  declined (precedent + the GVA and breeding run-flows diverge on the
  nested-tab activation, so a “shared” run-flow helper is messier than a
  clean abstraction).
- **Hard gate first (the breeding spike):** a live-browser spike
  captured the recon’s two open items firsthand before any RED. The
  Group-Detail nested `tabsetPanel` (`modBreedingGroups.R:72`) has **no
  `id`**, so it cannot be driven by `set_inputs` — it is activated via
  the unique DOM link `a[data-value='Group Detail']` (spike:
  `count == 1`). The spike proved both steps are required:
  post-formation but pre-activation, the export labels and rendered
  tables are still absent (the nested pane is `display:none`); only
  after the tab click do they enter the top-level active pane’s
  innerText. `animalSource = "all"` uses `ped$id` directly, isolating
  breeding from the GVA dependency (the `topRanked` branch’s
  `req(geneticValues())`, `appServer.R:272`).
- **Assertions (mutation-proven discriminating, RNG/seed-independent):**
  a static-UI download button is made data-bearing by PAIRING its
  visibility-gated label (matched via active-pane innerText, absent
  until the nested tab is activated) with a `suspendWhenHidden` rendered
  DT (which needs both group formation AND tab visibility). D5:
  `"Export Current Group"` + `grepl("Ego ID",` rendered
  `#breedingGroups-groupMemberTable)`. T7: `"Export Current Group"` +
  `"Age in Years"` member-table header. T9:
  `"Export Current Group Kinship Matrix"` + `grepl("<table",` rendered
  `#breedingGroups-groupKinTable)`. All tokens are static labels /
  rendered column-headers / table structure → verified GREEN with **no
  `NPRC_BG_SEED`** set. Group count and the within-group kinship
  invariant are deliberately NOT asserted (the algorithm formed one
  large MIS group from `numGp = 3`, and the strict kinship bound is
  unattainable because the module hardcodes `ignore = F–F`).
- **Verification:** D5/T7/T9 all GREEN live
  (`test-e2e-breeding-groups-detailed.R` 8/0/0,
  `test-e2e-breeding-groups-tutorial.R` 11/0/0); **\[mutation-check\]
  13/13 all pass** (correct tokens → TRUE; wrong export label +
  imaginary column + right-token-wrong-table `"Ego ID"`-in-kin → FALSE;
  foreign pane (Pedigree Browser) → FALSE; pre-flow RED re-confirmed →
  FALSE). Non-e2e regression **2140 `expectation_success` / 0 failed / 0
  error / 159 skipped / 5 pre-existing `modPyramid` warnings / 0 non-e2e
  offenders**, proven byte-identical with and without the edit via a
  `git stash` diff (the edit touches only e2e blocks, which skip at
  `create_test_app()` before any assertion). The
  2140-vs-Session-48’s-2180 figure is a measurement-method difference
  ([`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)
  under renv vs the bare system lib’s missing Suggests deps), not a
  regression. Phase-3E = the live GREEN AppDriver runs (the real
  upload→QC→kinship→group-formation→Group-Detail render) + the mutation
  spike ARE the runtime check (#31). Test-tree-only → no
  `document()`/NEWS; `tests/` lint-exempt.

### 2026-06-10 — Phase 8e-6b (real GVA-run flow): the 2 NULL’d Genetic-Value E2E blocks become genuine data-bearing assertions (issue \#40, Session 48)

- **Deliverable (implementation):** plan slice **8e-6b**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §5/§8e-6)
  — the **second of three vertical 8e-6 flows** (upload+QC ⊂ GVA ⊂
  breeding). Drives the real Genetic Value Analysis pipeline opt-in:
  `upload_and_wait(app, obfuscated_rhesus_mhc_ped.csv)` →
  `navigate_to_tab("Genetic Value Analysis")` → set `nIterations = 100`
  (minimum allowed, for speed) →
  `click_element_safe("#geneticValue-runAnalysis")` →
  `wait_for_module_ready("geneticValue")`, then asserts the **rendered
  `#geneticValue-rankingsTable`** DOM. Revives the 2 NULL’d
  Genetic-Value blocks from Session 42 (B1
  `test-e2e-genetic-value-tutorial.R:99` Value Designation, B2 `:144`
  Z-score) from pane-active-only into data-bearing checks. Scope fixed
  by the owner’s “8e-6b” instruction; full **RED→GREEN** (3
  `AskUserQuestion` phase gates), REFACTOR declined (a reusable GVA-run
  helper should co-design with 8e-6c).
- **Hard gate first (the GVA spike):** a live-browser spike settled the
  rendered-table facts before any RED, correcting a static-read trap:
  `reportGV.R:144`
  `cbind(demographics, indivMeanKin, zScores, gu, offspring)` shows no
  `value` column, but `reportGV.R:146` wraps it as
  `orderReport(finalData, ped)`, which splits the frame →
  [`rankSubjects()`](https://github.com/rmsharp/nprcgenekeepr/reference/rankSubjects.md)
  adds the `value` (“High/Low/Undetermined”) + `rank` columns → `rbind`
  re-flattens, so the rendered DT carries both `value` and `zScores`.
  The spike confirmed the default `topN = 20` view
  (`modGeneticValue.R:240`) truncates to the top-ranked (best) rows,
  which are **all “High Value”** — “Low Value”/“Undetermined” are
  truncated away, so the only faithful Value-designation token in the
  default render is `"High Value"`.
- **Assertions (mutation-proven discriminating, RNG/seed-independent):**
  B1 `"High Value"` (the Value designation rendered for the top-ranked
  rows); B2 `"zScores"` (the z-score DT column header). Both are
  structural invariants (a fixed column header; a designation guaranteed
  for the top rows) — verified by running GREEN with **no
  `NPRC_GVA_SEED`** set, so neither the 8e-5 seed hook nor value-stable
  RNG is required.
- **Verification:** 8/8 blocks GREEN in
  `test-e2e-genetic-value-tutorial.R` (the 6 static-UI blocks
  unaffected); **\[mutation-check\] all pass** (correct
  `"High Value"`/`"zScores"` → TRUE; wrong designation
  `"Low Value"`/`"Undetermined"` → FALSE; foreign-pane `"Form Groups"`
  (Breeding Groups) / `"Focal Animals"` (Pedigree) → FALSE; RED
  re-confirmed pre-run → both FALSE). Non-e2e regression **2180
  `expectation_success` / 0 failed / 0 error / 156 skipped / 5
  pre-existing `modPyramid` warnings / 0 non-e2e offenders** — Session
  47 baseline held exactly (test-only change; the e2e file self-skips
  without `NPRC_RUN_E2E`). Phase-3E = the live GREEN AppDriver run (the
  real upload→QC→GVA pipeline) + the mutation spike ARE the runtime
  check (#31). Test-tree-only → no `document()`/NEWS; `tests/`
  lint-exempt.
- **Lib currency:** the AppDriver subprocess resolves the package from
  the SYSTEM lib (`/Library/Frameworks/.../R-4.5/...`) under
  `RENV_CONFIG_AUTOLOADER_ENABLED=false`; that install was already
  current (`gatedSeed` present, v1.1.0.9000) because `R/` was unchanged
  since Session 47’s reinstall → no reinstall needed this session
  (verified currency firsthand; did not assume).

### 2026-06-10 — Phase 8e-6a (real upload+QC → pedigree-table flow): the 3 NULL’d pedigree E2E blocks become genuine data-bearing assertions (issue \#40, Session 47)

- **Deliverable (implementation):** plan slice **8e-6a**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §5/§8e-6)
  — the **first of three vertical 8e-6 flows** (upload+QC ⊂ GVA ⊂
  breeding). Drives the real pipeline opt-in for the first time in the
  E2E suite: `upload_and_wait(app, obfuscated_rhesus_mhc_ped.csv)` →
  `#dataInput-getData` → `navigate_to_tab("Pedigree Browser")`, then
  asserts the **rendered `#pedigree-pedigreeTable`** DOM. Revives the 3
  NULL’d pedigree blocks from Session 40 (A1
  `test-e2e-pedigree-module.R`, A2 `-detailed.R`, A3 `-tutorial.R`) from
  pane-active-only into data-bearing checks. Owner-gated scope (8e-6a
  only); full **RED→GREEN** (4 `AskUserQuestion` gates), REFACTOR
  declined (idiomatic 3-line driver, no helper).
- **Hard gate first (the 8e-6 spike):** a live-browser spike settled the
  recon critic’s blockers before any RED — (G4) the default
  `pedFile`/`pedigreeFileOne` upload flips `dataInput` ready and QC runs
  clean; (G5) the pedigree output is `suspendWhenHidden` (NULL until the
  Pedigree Browser tab is active, then renders all 375 rows — so the
  driver must `navigate` AFTER upload); (G2)
  `get_value(output="pedigree-pedigreeTable")` is a `json`-class string
  that **un-suspends to non-NULL even without data**, so the genuine
  data discriminator is the rendered-DOM content via
  `get_html_safe(app, "#pedigree-pedigreeTable")` — a refinement of the
  plan’s §2.3 “output tier”.
- **Assertions (all mutation-proven discriminating):** A1
  `"of 375 entries"` (row count) + `"sire"` column; A2 + `"dam"` column;
  A3 `"dataTables_length"` (the “Show N entries” length menu) +
  `"of 375 entries"`. A4 (“status filter”) left honest pane-active — no
  filter control exists (the table does render a `recordStatus` column,
  a future data-bearing option).
- **Fixture:** `inst/extdata/obfuscated_rhesus_mhc_ped.csv` (375 rows,
  canonical CSV; recon-verified to flow clean QC→GVA→breeding and
  already asserted error-free through the real `modInputServer`).
- **Verification:** 3/3 files GREEN (module 6/6, detailed 8/8, tutorial
  9/9); **\[mutation-check\] all pass** (correct content TRUE; wrong
  row-counts 999/374, foreign column `genotype`, foreign-pane
  `Breeding Groups`, and the same pattern on a different element → all
  FALSE). Non-e2e regression **2180 `expectation_success` / 0 failed / 0
  error / 156 skipped / 5 pre-existing `modPyramid` warnings / 0 non-e2e
  offenders** — Session 46 baseline held exactly (test-only change; the
  e2e files self-skip without `NPRC_RUN_E2E`). Phase-3E = the live GREEN
  AppDriver run (the real upload→QC→pedigree-render pipeline) + a
  mutation-check spike. Test-tree-only → no `document()`/NEWS; `tests/`
  is lint-exempt.
- **Environment note:** the AppDriver subprocess resolves
  `nprcgenekeepr` from the **system library**
  (`/Library/Frameworks/...`), not the renv cache, under
  `RENV_CONFIG_AUTOLOADER_ENABLED=false`; current source was reinstalled
  there first (the prior system-lib install was from Jul 2025).
- **Scope boundary:** GVA (8e-6b) and breeding-group (8e-6c) flows +
  their deferred blocks (2 GV from S42, 3 BG from S43) are deliberately
  deferred to their own sessions (FM \#18/#25). `add-methodology` still
  not on remote.

### 2026-06-10 — Phase 8e-5 (Stochastic determinism hook): env/option-gated `set_seed()` in the GVA + breeding-group module servers — the FIRST 8e PRODUCTION `R/` change (issue \#40, Session 46)

- **Deliverable (implementation):** plan slice **8e-5**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §7) — the
  **only 8e slice that edits production `R/`**
  (`modGeneticValueServer` + `modBreedingGroupsServer`, both exported).
  Adds an **env/option-gated
  [`set_seed()`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)
  hook** (Option A) so the stochastic GVA / breeding-group engines can
  be made reproducible on demand for E2E exact-value assertions, while
  the **default path is provably unchanged** (gate unset ⇒ no-op).
  Owner-gated (`AskUserQuestion` go/no-go chose Option A over Option B’s
  user-facing UI seed input and Option C-only’s no-production-change
  invariants), then full **RED→GREEN→REFACTOR**, every transition gated.
- **The gate (Option A):** at the top of each `eventReactive` body,
  immediately after `req()` and ahead of `withProgress` (so nothing
  between the seed and the engine consumes RNG):
  `seed <- getOption("nprcgenekeepr.gva_seed", as.integer(Sys.getenv("NPRC_GVA_SEED", NA))); if (!is.na(seed)) set_seed(seed)`
  — `modGeneticValue.R` ahead of
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  (gene-drop `sample`), `modBreedingGroups.R` ahead of
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  (MIS `sample`), with `nprcgenekeepr.bg_seed` / `NPRC_BG_SEED`. Uses
  the existing **exported
  [`set_seed()`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)**
  (pins `sample.kind="Rounding"`). Option precedence over the env-var
  fallback; both unset ⇒ `NA` ⇒ no seed.
- **REFACTOR:** the duplicated 3-line gate factored into one internal
  `@noRd` helper `gatedSeed(optionName, envName)` in `R/set_seed.R`;
  both module call sites now call it. Structure only — no behavior
  change, no new tests (the 8 tests validate the refactored helper via
  the `set_seed` mock + determinism). `gatedSeed` is `@noRd` ⇒ **no
  NAMESPACE / man delta**.
- **Tests (8 new, browser-free `testServer`; 3 RED + 1 guard per
  module):** determinism — with the option set, two `gvResults()` /
  `groups()` runs are `identical` (RED at HEAD: unseeded runs differ
  because RNG state carries across `testServer` invocations; a
  `length(.) > 0` assertion proves the capture is non-vacuous);
  `set_seed` mock — called once with the seed when the option is set
  (RED at HEAD: never called); env-var fallback — `NPRC_GVA_SEED` /
  `NPRC_BG_SEED` read when the option is absent (RED at HEAD); and the
  default-path **guard** — neither option nor env set ⇒ `set_seed` not
  called (green-on-arrival). RED confirmed firsthand (6 genuine
  failures + 2 guards passing) before GREEN; no synthetic RED.
- **Enabling baseline commit (separate, `d0989408`):** committed the
  owner’s concurrent 14-file `R/`
  - `test_modPyramid.R` automated formatter pass (integer literals,
    quote style) on owner request, to give 8e-5 a clean baseline;
    re-verified behaviorally inert (regression held at 2166). A
    follow-on `docs:` commit regenerated 3 man pages (`appServer`,
    `modSummaryStatsServer`, `savePlotToFile`) the reformat desynced —
    the formatter had also rewrapped `#'` roxygen comments and changed
    `savePlotToFile`’s defaults to integer (`width=8L`), which would
    have tripped `R CMD check` codoc.
- **Verify:** non-e2e regression **2180 `expectation_success` / 0 failed
  / 0 error / 156 skip / 5 pre-existing `modPyramid` warnings / 0
  non-e2e offenders** (= the 2166 baseline + 14 new expectations;
  default analytical path unchanged — every existing test passes with
  the gate unset). **`devtools::check()` = 0 errors / 0 warnings / 3
  NOTEs** (all pre-existing or environmental: the stale
  `spelling.Rout.save` baseline, “future file timestamps”, non-standard
  top-level dev files — the S35 baseline; no new `gatedSeed` “no visible
  global” NOTE, confirming the lintr single-file flag is a
  stale-namespace artifact resolved by full-package analysis). Phase-3E
  runtime smoke:
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  (working-tree source via `load_all`, so the hook is active) serves
  **HTTP 200** on the default gate-unset path. Lint net-zero on the
  changed `R/`.
- **Scope / docs:** the default analytical numerics are unchanged (gate
  is a no-op by default) → **CHANGELOG only, no `NEWS.md` bullet**
  (consistent with the modular-parity precedent). 8e-5 enables the
  *optional exact-value* assertion tier in 8e-6 but does not block it
  (8e-6 can use Option-C structural invariants regardless).

### 2026-06-10 — Phase 8e-4 (Error-States + Boundary-Conditions): namespace fix + interaction revival; boot tautologies → behavioral active-pane assertions (issue \#40, Session 45)

- **Deliverable (implementation):** plan slice **8e-4**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §5) — the
  FIRST 8e slice that is **not pure run-and-observe**: a HYBRID of
  **RED→GREEN** (the `input-`→`dataInput-` namespace fix) and
  **run-and-observe** (the assertion conversions). Two files:
  `test-e2e-error-states.R` (13) + `test-e2e-boundary-conditions.R` (13)
  = **26** browser-booting `test_that` blocks, plus the
  `upload_and_wait` helper + its browser-free unit tests.
- **Namespace fix (§2.4, RED→GREEN, 5 sites):** the input module is
  mounted under the **`dataInput`** namespace (`appUI.R:123`
  `modInputUI("dataInput")`); `data-module="input"` (`modInput.R:31`) is
  a label, not the namespace. Fixed: `helper-shinytest2.R`
  `upload_and_wait` default `module_id` `"input"`→`"dataInput"` + the
  hardcoded `input-pedigreeFileOne` now DERIVED from
  `module_id`/`file_input_id` via `do.call`; `error-states`
  `#input-getData`→`#dataInput-getData` and
  `input-minParentAge`→`dataInput-minParentAge`; `boundary`
  `input-minParentAge`→ `dataInput-minParentAge`. A new browser-free
  recording-stub unit test in `test_helper_shinytest2.R` anchors the
  helper fix in the always-run layer (+4 expectations).
- **Discriminators (firsthand-spiked):** for a namespaced **textInput**
  the wrong-id discriminator is the **value read-back** — shinytest2
  `set_inputs` on an unbound id WARNS and never sets (it does NOT
  throw), so `get_value("dataInput-minParentAge")` stays at the default
  with the wrong id; for the **actionButton** it is the `app$click`
  **throw** (→ `click_element_safe`→FALSE). A no-file `getData` click
  surfaces the transient
  `showNotification("Please select a file first.")` warning, asserted
  via `#shiny-notification-panel`.
- **Conversions (23, run-and-observe):** the `nchar(html)>100`
  near-tautologies + dead-grepl + `interaction-noop-tryCatch` blocks now
  call `assert_active_pane(app, <pane>, <static-label>)` —
  Input/Pedigree/Pyramid/GV/BG control labels confirmed against the real
  active-pane innerText. The rapid-switch / repeat-click blocks assert
  the final pane (Home / Input); the narrow/short-window blocks assert
  Home active on boot. **Zero blocks deferred to 8e-6** (all static-pane
  assertions are available pre-data).
- **Verification:** helper unit tests **63/0/0** (the 2 new
  `upload_and_wait` tests green); e2e error+boundary browser run **26
  blocks / 29 expectations GREEN, 0 failed / 0 error / 0 skip**
  (`filter="^e2e-(error|boundary)"`, `NPRC_RUN_E2E=true NOT_CRAN=true`).
  **\[mutation-check\] PASS** (correct GV pane→TRUE; wrong-pane /
  foreign-content “Number of groups”→FALSE; OLD whole-body grepl→TRUE
  content-blind contrast; namespace read-back + notification +
  wrong-selector→FALSE). Non-e2e regression **2166 `expectation_success`
  / 0 failed / 0 error / 156 skip / 5 pre-existing `modPyramid` warn / 0
  non-e2e offenders** — S40–S44 baseline + exactly the +4 new helper
  expectations. Phase-3E satisfied (the live browser run + 2 spikes ARE
  the runtime, \#31).
- **⚠ Concurrent formatter (not part of this deliverable):** at session
  start the tree was clean; mid-session an external automated style pass
  (`'…'`→`"…"`, `0`→`0L`) rewrote **14 `R/` production files** and
  briefly broke 2 (`makeFounderStatsTable.R:68`,
  `makeGeneticSummaryTable.R:58` — inner HTML quotes unescaped). Per
  SAFEGUARDS / FM \#22 those unauthored uncommitted edits were NOT
  touched; the formatter self-healed both files and settled, and the
  regression confirmed the reformat is behaviorally inert. The 8e-4
  commit stages ONLY the test-tree files + docs via explicit `git add`,
  leaving the owner’s reformat as their in-progress work.
- **Scope:** test-tree-only (2 e2e files + helper + helper unit test) →
  no `document()`/NEWS; `tests/` is `.lintr`-excluded. Strict TDD, gated
  `PRE-RED→RED` then `RED→GREEN` via `AskUserQuestion`.

### 2026-06-09 — Phase 8e-3 FINAL (Settings-About + Workflow-Integration): boot-level tautologies → behavioral active-pane assertions; navbarMenu finalized (issue \#40, Session 44)

- **Deliverable (implementation):** the **LAST two 8e-3 files** of plan
  slice 8e-3
  (`docs/planning/phase8e-assertion-strengthening-subplan.md`) —
  `test-e2e-settings-about.R` (4) +
  `test-e2e-workflow-integration.R` (7) = **11 browser-booting
  `test_that` blocks**. Converts the content-blind
  `navigate_to_tab → grepl(get_html_safe(app,"body"))` idiom to
  behavioral `assert_active_pane(...)`. **8e-3 is now COMPLETE**
  (genetic-value S42 + breeding-groups S43 + settings-about/workflow
  S44).
- **Dragon resolved firsthand (R1 / §2.3 item 4, carried as a 🐉 by
  S42/S43):** a live-DOM spike (Rscript→AppDriver) confirmed a
  `navbarMenu("More")` child **becomes the lone active top-level
  `.tab-pane`** via `set_inputs(mainNavbar=child)` — top-level
  `.tab-content` count == 1, `get_active_pane_value`/innerText == the
  child (Settings/About/Help) content. So `navigate_to_menu_item`’s
  delegate body was already a genuine visible-pane switch; **only its
  docstring’s shallow-coverage caveat needed retiring**
  (`helper-shinytest2.R:283-292`, body unchanged) → PURE
  run-and-observe, not a helper RED→GREEN.
- **Strict TDD — PURE run-and-observe** (no defect; all panes already
  render) → green-on-arrival `[refactor-only]` conversion, gated
  `PRE-RED→run-and-observe` via `AskUserQuestion`; rigor from a
  `[mutation-check]` (no synthetic RED).
- **Conversion map — 10 keep-regex-rescope · 1 navbar-chrome
  carve-out:**
  - **settings-about (4): all genuine grepl → keep verbatim, rescope to
    the navbarMenu child pane** — S1
    `(Settings,"Settings|Configuration|options")`, S2
    `(About,"About|Version|GeneKeepR|Oregon|Primate")`, S3
    `(Help,"Help|Documentation|Online")`, S4
    `(About,"NIH|funded|grant")`.
  - **workflow-integration (7):** W1 “visits N tabs” loop → 6 per-pane
    `assert_active_pane` checks with the threshold raised `>= 3` →
    `== 6L` (so a single failed nav reds the block); W2/W3
    [`is.list()`](https://rdrr.io/r/base/list.html) responsiveness
    tautologies → genuine pane-switch asserts (Input-then-Home;
    final-pane after a 4-switch loop); W4 navbar brand → **CARVE-OUT**
    scoped to `.navbar-brand`
    (`grepl("GeneKeepR", get_html_safe(app, ".navbar-brand"))` —
    strictly stronger than the old whole-body grepl, since the brand
    lives outside any pane); W5 `(Input,"upload|file|browse")`, W6
    `(Genetic Value Analysis,"Genetic|Value|Analysis|kinship|population")`,
    W7 `(Breeding Groups,"Breeding|Groups|formation|animals")`.
- **Helper:** `navigate_to_menu_item` docstring finalized (records the
  8e-3 navbarMenu confirmation; no body change).
- **Verification:** browser run **11/11 GREEN / 12 expectations** (net-0
  swap), 0 error / 0 skip (`filter="^e2e-(settings|workflow)"`).
  `[mutation-check]` PASS — settings-about arms via the spike
  (wrong-pane→FALSE, wrong-content→FALSE); workflow arms: W1
  wrong-pane→FALSE (count would miss 6L), W4 scoped
  `grepl("Breeding", brand)`→FALSE while old whole-body
  `grepl("Breeding", body)`→TRUE (proves the old check was
  content-blind). Non-e2e regression **2162 `expectation_success` / 0
  failed / 0 error / 156 skipped / 5 pre-existing `modPyramid` warnings
  / 0 non-e2e offenders** — S40–S43 baseline held EXACTLY (read via
  `expectation_success`, not `sum(nb)`, per Learning \#43e). Phase-3E:
  the live browser run + two DOM spikes + the mutation-check spike ARE
  the runtime (#31 pattern).
- **Scope:** test-tree only (3 files: 2 test files + a test-helper
  docstring); `tests/` `.lintr`-excluded → lint-exempt; no `R/` change →
  no `document()`/NEWS (CHANGELOG only). Next: **8e-4** (namespace
  `input-`→`dataInput-` fix + error-states/boundary interaction
  revival), a separate session.
- See `PROJECT_LEARNINGS.md` Learning \#44 for the full per-block detail
  and the navbarMenu/brand/threshold findings.

### 2026-06-09 — Phase 8e-3 part B-2 (Breeding-Groups family): boot-level tautologies → behavioral active-pane assertions (issue \#40, Session 43)

- **Deliverable (implementation):** the **Breeding-Groups family** of
  plan slice 8e-3
  (`docs/planning/phase8e-assertion-strengthening-subplan.md`) —
  `test-e2e-breeding-groups-module.R` (7),
  `test-e2e-breeding-groups-detailed.R` (7),
  `test-e2e-breeding-groups-tutorial.R` (9) = **23 browser-booting
  `test_that` blocks**. All converted from the content-blind
  `navigate_to_tab → grepl(get_html_safe(app, "body"))` idiom to
  `assert_active_pane(app, "Breeding Groups", <pattern>)`. The 2nd of
  three 8e-3 cuts (genetic-value done S42; settings-about +
  workflow-integration remain).
- **Strict TDD — PURE run-and-observe** (no defect; the Breeding Groups
  pane already renders and “Breeding Groups” IS the `tabPanel` title
  `appUI.R:166`) → green-on-arrival `[refactor-only]` conversion, gated
  `PRE-RED→run-and-observe` via `AskUserQuestion`; rigor from a
  `[mutation-check]` (no synthetic RED).
- **Conversion map by the Learning \#40/#41/#42 split — 12 KEEP · 6
  REVIVE · 1 ANCHOR · 4 NULL:**
  - **12 genuine `grepl` asserts → keep regex verbatim, rescope haystack
    to the active pane** (module M1–M7; detailed D1🐉/D3/D7; tutorial
    T2/T3).
  - **6 tautologies with a dead computed grepl → REVIVE that pattern,
    rescoped + pruned** (Learning \#42a): D2 `harem` (✓“Harem (1M:NF)”),
    D4 `result|group|table|output|formed` (✓“group”; rest data-dependent
    → 8e-6), T1 `group.*formation|source.*animal` (✓h3/guidance), T4
    `Seed.*Group|seed.*animal|specific.*animal` (✓“Seed groups with
    specific animals”), T6 `Include.*kinship|kinship.*display`
    (✓“Include kinship in display of groups”), T8 `top.*ranked` (✓“Top
    ranked”). Pruned: inputId artifacts (`seedGroups`, `showKinship`),
    never-rendered framing words (`workflow`, `Choose.*group`,
    `pre.*seed`), and the foreign-module token `genetic.*analysis`.
  - **1 content-length tautology (`nchar(html) > 200`) → ANCHOR** to the
    always-visible guidance phrase “algorithm” (D6;
    `inst/extdata/ui_guidance/group_formation.html` “The algorithm
    ignores…”).
  - **4 NULL-pattern (pane-active only):** D5/T7 (export) + T9 (export
    kinship matrix) — the `downloadButton`s live in the INACTIVE “Group
    Detail” nested tab (`display:none`, not in active-pane `innerText`;
    guidance has no export tokens) → defer to 8e-6 / nested-tab
    navigation; **T5** (infants-with-dam) — no such control exists in
    the modular UI (tutorial-only concept). Each NULL still upgrades the
    old `expect_true(TRUE)` by confirming the Breeding Groups pane is
    the active/visible one.
- **1 dragon kept verbatim, flagged in a comment, never renamed**
  (Learning \#41a): D1 `size|number|count| animals` — no literal “size”
  control; matches via “number”/“animals” (“Number of groups:”, “Number
  of top animals:”, “Seed groups with specific animals”).
- **Nested-tab visibility distinction (new this cut):** the nested
  tabsetPanel’s NAV labels (“Groups”, “Statistics”, “Group Detail”) ARE
  in the active-pane `innerText` (always visible), so M7 `statistic`
  anchors on the “Statistics” nav label and D4 “group” on the “Groups”
  nav label — but the inactive nested tabs’ CONTENT (the export buttons)
  is hidden. The pre-gate critic settled this by RENDERING the actual
  Shiny `navbarPage`+`tabsetPanel` DOM; the browser run confirmed it
  firsthand (M7 GREEN).
- **Pre-gate adversarial verification (0 corrections, dispute resolved
  firsthand):** a 4-agent refutation workflow (3 source-grounded
  skeptics defaulting-to-refuted + a cross-checking critic) over the
  23-block map BEFORE the TDD gate confirmed all 23 verdicts. It earned
  its keep by resolving the one genuine dispute (M7: is the nested nav
  label in `innerText`?) via a real Shiny DOM render and dismissing two
  skeptic refutations that rested on the opposite false premise — robust
  to 2/3 skeptics hitting stream-idle timeouts (1 full skeptic + 1
  partial + the critic sufficed).
- **Verification:** browser run **23/23 blocks GREEN / 23 expectations**
  (1:1 swap, net 0), 0 error / 0 skip (`filter="^e2e-breeding-groups"`,
  env
  `NPRC_RUN_E2E=true NOT_CRAN=true RENV_CONFIG_AUTOLOADER_ENABLED=false`).
  **\[mutation-check\] PASS** (inverted — Breeding Groups is the TARGET
  pane): correct `(Breeding Groups,"Form Groups")`→TRUE; wrong-pane
  `(Pedigree Browser,"Form Groups")`→FALSE; wrong-content
  `(Breeding Groups,"Focal Animals")`→FALSE (“Focal Animals” is
  Pedigree/Input-only `modPedigree.R:52`/`modInput.R:114`,
  grep-confirmed foreign to BG); old whole-body
  `grepl("Focal Animals",body)`→TRUE (content-blind contrast);
  active-pane innerText grepl→FALSE (sanity). Non-e2e regression
  (`NOT_CRAN=true`) — canonical testthat tally **2162
  `expectation_success` / 0 failed / 0 error / 156 skipped / 5
  pre-existing `modPyramid` warnings / 0 non-e2e offenders** — the
  S40–S42 baseline held EXACTLY (the 3 BG files self-skip at
  `create_test_app()`).
- **⚠ Measurement note (refines Learning \#42d):**
  `sum(res$nb) - sum(res$failed)` is NOT the passed count — `nb` counts
  skip and warning rows too (2162 success + 156 skip + 5 warning =
  2323). The canonical passed count is `expectation_success` (or the
  testthat reporter’s `PASS` line). A “+161 pass” delta from a test-only
  e2e edit (provably impossible) was this formula artifact, diagnosed
  firsthand, not a regression.
- **Phase 3E:** test-tree-only deliverable — the live browser run (23
  blocks via real AppDriver) + the live mutation-check spike ARE the
  runtime (#31 pattern); drove the real app, not just build-clean. No
  `R/` change → no `document()`/NEWS; `tests/` is `.lintr`-excluded.

### 2026-06-08 — Phase 8e-3 part B-1 (Genetic-Value family): boot-level tautologies → behavioral active-pane assertions (issue \#40, Session 42)

- **Deliverable (implementation):** the **Genetic-Value family** of plan
  slice 8e-3
  (`docs/planning/phase8e-assertion-strengthening-subplan.md`) —
  `test-e2e-genetic-value-module.R` (7),
  `test-e2e-genetic-value-detailed.R` (7),
  `test-e2e-genetic-value-tutorial.R` (8) = **22 browser-booting
  `test_that` blocks**. All converted from the content-blind
  `navigate_to_tab → grepl(get_html_safe(app, "body"))` idiom to
  `assert_active_pane(app, "Genetic Value Analysis", <pattern>)`.
- **Owner-scoped to ONE family** (`AskUserQuestion`): 8e-3 censused
  firsthand at **8 files / ~56 blocks** (~3× an 8e-2 session) — far past
  the family-per-session boundary the 8e-2 sessions (S38–S41)
  established — so it is split per the plan §5 “may split if
  oversized” + the don’t-bundle dragon (FM \#18/#25). This session did
  genetic-value only; **deferred to follow-on sessions:**
  breeding-groups family (3 files, ~23) and settings-about +
  workflow-integration (the navbarMenu finalization of
  `navigate_to_menu_item` + visit-N conversion, 2 files, ~11).
- **Strict TDD — PURE run-and-observe** (no defect; the GV pane already
  renders and
  `navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")`
  already targets the right tab — “Genetic Value Analysis” IS the
  `tabPanel` title `appUI.R:148` == the module h3
  `modGeneticValue.R:32`) → green-on-arrival `[refactor-only]`
  conversion, gated `PRE-RED→run-and-observe` via `AskUserQuestion`;
  rigor from a `[mutation-check]` (no synthetic RED).
- **Conversion map by the Learning \#40/#41 split** — 16 KEEP · 3 REVIVE
  · 1 ANCHOR · 2 NULL:
  - **16 genuine `expect_true(grepl(orig))` → keep regex verbatim,
    rescope haystack to the active pane** (module M1–M7; detailed
    D1/D2/D4/D5; tutorial T1–T4/T6).
  - **3 tautologies with a DEAD computed grepl pattern → REVIVE that
    exact pattern, rescoped** (new sub-case vs S41’s “tautology → fresh
    anchor”): D3 `founder|equivalent|FE|genetic` (✓“founder” in the
    guidance “rare founder alleles” + “genetic” in the h3), D6
    `report|export|download|summary` (✓“Export All/Subset” + “Summary”
    nested-tab label), T8 narrowed to `filter` (✓“Filter View”/“Filter
    by IDs”).
  - **1 content-length tautology (`nchar(html) > 200`) → ANCHOR** to the
    distinctive always-rendered guidance phrase “ranks animals” (D7;
    `inst/extdata/ui_guidance/genetic_value.html`).
  - **2 NULL-pattern (pane-active only, data-bearing deferred to
    8e-6):** T5 “Value Designation” and T7 “Z-score” are data-dependent
    results concepts absent from the static UI/guidance — no faithful
    default-visible pattern exists, so assert only that the GV pane is
    active (Learning \#41a).
- **4 dragons keep their genuine regex verbatim** (Learning \#41a — flag
  in a comment, never rename): M4 `minimum|breeding|age` (no min-age
  control in GV; “breeding” matches guidance “breeding colony”); D1
  `population|select|animals|subset` (population is server-derived
  `modGeneticValue.R:148-162`; “animals” matches guidance “ranks
  animals” and “subset” matches “Export Subset”); T4
  `dataTable|DTOutput|table| results|ranking` (the rendered table is
  `req(gvaView())`-gated → 8e-6; “ranking” matches the static “Rankings”
  nested-tab label).
- **Pre-gate adversarial verification narrowed the map** (Learning
  \#40d/#41d): a 4-agent refutation workflow (3 source-grounded skeptics
  defaulting-to-refuted + a cross-checking critic) over the 22-block map
  BEFORE the TDD gate confirmed 21/22 and corrected **T8** — the revived
  dead pattern carried four alternatives
  (focal/display/Show.\*entries/search) FOREIGN to the GV pane
  (copy-paste from another module); only “filter” matches
  default-visible innerText, so the revive was narrowed to `filter`. The
  critic also dismissed a skeptic’s bogus newline-spanning false
  positive (R `grepl` `.` does not cross the newlines `innerText`
  inserts) and confirmed the two NULLs.
- **Verification:** browser run **22/22 blocks GREEN / 22 expectations**
  (1:1 swap, net 0), 0 error / 0 skip (`filter="^e2e-genetic-value"`,
  env
  `NPRC_RUN_E2E=true NOT_CRAN=true RENV_CONFIG_AUTOLOADER_ENABLED=false`).
  **`[mutation-check]` PASS** (inverted — Genetic Value Analysis is the
  TARGET pane): correct `(Genetic Value Analysis,"Run Analysis")`→TRUE;
  wrong-pane `(Pedigree Browser,"Run Analysis")`→FALSE; wrong-content
  `(Genetic Value Analysis,"Focal Animals")`→FALSE (Pedigree-only label
  `modPedigree.R:52`, absent from the GV pane); old whole-body
  `grepl("Focal Animals")`→TRUE (content-blind contrast); active-pane
  innerText grepl→FALSE (sanity). Non-e2e regression **2162 passed / 0
  failed / 0 error / 0 non-e2e offenders** (156 skipped, 5 pre-existing
  `modPyramid` warnings; the e2e-only change self-skips at
  `create_test_app()` `helper-shinytest2.R:196` — the 3 GV files showed
  0/0/0/22-skip — so non-e2e counts are unaffected; S40/S41 baseline
  held EXACTLY).
- **Static UI only** (data-bearing GV outputs — rankings table, scatter
  plot, Summary table incl. Founder Equivalents/Value-Designation — are
  `req()`-gated and deferred to 8e-6). Test-tree-only → no
  `document()`/NEWS; `tests/` is lint-exempt (`.lintr:35`).

### 2026-06-08 — Phase 8e-2 (Pyramid family — the LAST 8e-2 cut → 8e-2 COMPLETE): boot-level tautologies → behavioral active-pane assertions (issue \#40, Session 41)

- **Deliverable (implementation):** the **Pyramid family** of plan slice
  8e-2 (`docs/planning/phase8e-assertion-strengthening-subplan.md`) —
  `test-e2e-pyramid-module.R` (6), `test-e2e-pyramid-detailed.R` (6) =
  **12 browser-booting `test_that` blocks**. Completes 8e-2
  (home-nav+app S38 + Input S39 + Pedigree S40 + Pyramid S41); the next
  slice is **8e-3** (genetic-value / breeding-groups / menu / workflow),
  a separate session.
- **Strict TDD — PURE run-and-observe** (no defect; the Pyramid pane
  already renders and
  `navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")` already targets
  the right tab — “Age-Sex Pyramid” IS the `tabPanel` title
  `appUI.R:139`, 3rd `fallback` arg a documented no-op
  `helper-shinytest2.R:250`) → green-on-arrival `[refactor-only]`
  conversion, gated `PRE-RED→run-and-observe` via `AskUserQuestion`;
  rigor from a `[mutation-check]` (no synthetic RED).
- All 12 blocks converted from the content-blind
  `navigate_to_tab → grepl(get_html_safe(app,"body"))` idiom to
  `assert_active_pane(app, "Age-Sex Pyramid", <pattern>)`, by the
  Learning \#40 principled split: **(i) 10 genuine
  `expect_true(grepl(orig))` asserts** keep their original regex
  verbatim, only rescoping the haystack to the active pane (module
  L6/L25/L42/L59/L76/L93; detailed L6/L25\[🐉\]/L44\[🐉\]/L80); **(ii) 2
  tautologies** upgrade to a precise default-visible anchor — detailed
  L63 `expect_true(TRUE)` → “Download Plot”, detailed L99
  `nchar(html) > 100` → “Age Plot”.
- **0 NULL-pattern blocks** — unlike the Pedigree family (4 NULLs). The
  pyramid pane’s static content is rich enough (sidebar controls + an
  UNCONDITIONAL guidance HTML panel) that every block has a
  default-visible anchor; none of the 12 blocks targets the
  data-dependent rendered plot / Statistics table (those
  `req(pedigreeData())`-gated outputs, `modPyramid.R:90-118`, are not
  what these tests assert), so nothing defers to 8e-6.
- **The two dragons** keep their keywords against always-rendered static
  text: detailed:25 `male|female|sex` is satisfied by the guidance HTML
  (“…males are plotted on the left and females on the right”,
  `inst/extdata/ui_guidance/pyramidPlot.html` via
  `modPyramid.R:55-58`) + the h3 “Age-Sex Pyramid Analysis” — NOT the
  data-dependent plot axis labels; detailed:44 `max|maximum|age|limit`
  (“maximum age setting”) is satisfied by the always-visible age labels
  (“Age Unit:”, “Age Label Size:”) — there is NO dedicated max-age
  control, so the genuine regex is kept verbatim and rescoped rather
  than renamed (out of scope for a haystack-rescope slice).
- **Pre-gate adversarial verification materially CORRECTED the map** (vs
  S40’s 0/19-refuted confirmation): a 4-agent refutation workflow (3
  source-grounded skeptics defaulting-to-refuted + a critic) over the
  12-block map BEFORE the TDD gate flagged **2/12** — both proposed
  NULLs (D3 “maximum age setting”, D6 “data requirement message”).
  Correctly: D3’s regex matches static “age” (→ KEEP, don’t NULL) and
  D6’s pane has always-rendered guidance (→ anchor “Age Plot”, don’t
  NULL+defer). Adopting both corrections yielded the 0-NULL outcome. The
  browser run remained the authoritative `[verify-first]`.
- **Static UI only** (data-bearing plot/table deferred to 8e-6 by virtue
  of not being targeted here).
- **Verification:** browser run **12/12 blocks GREEN / 12 expectations**
  (1:1 swap, net 0), 0 error / 0 skip (`filter="^e2e-pyramid"`, env
  `NPRC_RUN_E2E=true NOT_CRAN=true RENV_CONFIG_AUTOLOADER_ENABLED=false`).
  **`[mutation-check]` PASS** (inverted vs the Pedigree slice — Pyramid
  is now the TARGET pane) — correct `(Age-Sex Pyramid,"Bin Size")`→TRUE;
  wrong-pane `(Pedigree Browser,"Bin Size")`→FALSE; wrong-content
  `(Age-Sex Pyramid,"Focal Animals")`→FALSE (Pedigree-only label
  `modPedigree.R:52`, absent from the Pyramid pane); old whole-body
  `grepl("Focal Animals")`→TRUE (content-blind contrast); active-pane
  innerText grepl→FALSE (sanity). Non-e2e regression **2162 passed / 0
  failed / 0 error / 0 non-e2e offenders** (156 skipped, 5 pre-existing
  `modPyramid` warnings; the e2e-only change self-skips at
  `create_test_app()` so non-e2e counts are unaffected — S40 baseline
  held exactly).
- **Test-tree-only** → no `document()`/NEWS bullet, `tests/`
  lint-exempt. Phase-3E satisfied by the live browser run +
  mutation-check spike (the \#31 pattern — drove the real app).

### 2026-06-08 — Phase 8e-2 (Pedigree family): boot-level tautologies → behavioral active-pane assertions (issue \#40, Session 40)

- **Deliverable (implementation):** the **Pedigree family** of plan
  slice 8e-2
  (`docs/planning/phase8e-assertion-strengthening-subplan.md`) —
  `test-e2e-pedigree-module.R` (5), `test-e2e-pedigree-detailed.R` (6),
  `test-e2e-pedigree-tutorial.R` (8) = **19 browser-booting `test_that`
  blocks**. Continues S38 (home-nav+app) and S39 (Input); 8e-2 now has
  only the **Pyramid family** (module/detailed = 12) left, as a separate
  session (plan R3 / FM \#18/#25).
- **Strict TDD — PURE run-and-observe** (no defect; the Pedigree pane
  already renders and
  `navigate_to_tab(app, "Pedigree Browser", "Pedigree")` already targets
  the right tab — “Pedigree Browser” IS the `tabPanel` title
  `appUI.R:130`, and the 3rd `fallback` arg is an explicit no-op,
  `helper-shinytest2.R:250`) → green-on-arrival `[refactor-only]`
  conversion, gated `PRE-RED→run-and-observe` via `AskUserQuestion`;
  rigor from a `[mutation-check]` (no synthetic RED).
- All 19 blocks converted from the content-blind
  `navigate_to_tab → grepl(get_html_safe(app,"body"))` idiom to
  `assert_active_pane(app, "Pedigree Browser", <pattern>)`, by a
  principled split: **(i) genuine `expect_true(grepl(orig))` asserts**
  keep their original regex verbatim, only rescoping the haystack to the
  active pane (module L6/L25/L42/L76; detailed L6/L25/L44\[🐉\]/L82;
  tutorial L155\[🐉\]); **(ii) `expect_true(TRUE)` tautologies** upgrade
  to a precise default-visible anchor — “Display Unknown IDs”, “Focal
  Animals”, “Choose CSV file”, “Trim pedigree”, “Update Focal Animals”,
  “Clear Focal Animals” (`modPedigree.R:52,72,79,86,105,118`); **(iii)
  honest NULL-pattern** `assert_active_pane(app, "Pedigree Browser")`
  for 4 blocks whose target is data-dependent or nonexistent — the DT
  table (module L59, detailed L63: renders only after
  `req(pedigreeData())` → deferred to 8e-6), DataTables “Show X entries”
  pagination (tutorial L28 → 8e-6), and the “status filter” (detailed
  L101: no such static control exists).
- **The two dragons** (`pedigree-detailed:57`
  `sire|dam|parent|offspring|ancestor|descendant`,
  `pedigree-tutorial:174` `sire|dam|sex|birth|exit|age|gen|population`)
  keep their keywords — the column names are listed in the
  always-rendered `inst/extdata/ui_guidance/pedigree_browser.html`
  guidance panel (“Ego ID, Sire ID, Dam ID, Sex, Generation, and
  Population… Birth Date, Exit Date, Age”).
- **Pre-gate adversarial verification:** ran a 4-agent refutation
  workflow (3 per-file skeptics + critic) over the 19-block map BEFORE
  posing the TDD gate — **0/19 refuted**, critic GO, all patterns
  confirmed default-visible, the 4 NULLs confirmed honest, and the
  mutation labels “Color Scheme”/“Bin Size” confirmed foreign
  (Pyramid-only). De-risks a slow browser cycle
  (`[right-sized-orchestration]` / `[completeness-workflow]`).
- **Static UI only** (data-bearing tables/plots deferred to 8e-6).
- **Verification:** baseline browser run 19/19 green → post-conversion
  **19/19 blocks GREEN / 19 expectations** (1:1 swap, net 0), 0 error /
  0 skip (`filter="^e2e-pedigree"`, env
  `NPRC_RUN_E2E=true NOT_CRAN=true RENV_CONFIG_AUTOLOADER_ENABLED=false`).
  **`[mutation-check]` PASS** — correct
  `(Pedigree Browser,"Focal Animals")`→TRUE; wrong-pane
  `(Age-Sex Pyramid,…)`→FALSE; wrong-content
  `(Pedigree Browser,"Color Scheme")`→FALSE (Pyramid-only label, absent
  from the Pedigree pane); old whole-body `grepl("Color Scheme")`→TRUE
  (content-blind contrast); active-pane innerText grepl→FALSE (sanity).
  Non-e2e regression **2162 passed / 0 failed / 0 error / 0 non-e2e
  offenders** (156 skipped, 5 pre-existing `modPyramid` warnings; the
  e2e-only change self-skips at `create_test_app()` so non-e2e counts
  are unaffected).
- **Test-tree-only** → no `document()`/NEWS bullet, `tests/`
  lint-exempt. Phase-3E satisfied by the live browser run +
  mutation-check spike (the \#31 pattern — drove the real app).

### 2026-06-08 — Phase 8e-2 (Input family): boot-level tautologies → behavioral active-pane assertions (issue \#40, Session 39)

- **Deliverable (implementation):** the **Input family** of plan slice
  8e-2 (`docs/planning/phase8e-assertion-strengthening-subplan.md`) —
  `test-e2e-input-module.R` (5), `test-e2e-input-detailed.R` (6),
  `test-e2e-input-tutorial.R` (8) = **19 browser-booting `test_that`
  blocks**. Continues S38’s home-nav+app sub-slice; 8e-2 is now ~half
  done. Pedigree and Pyramid families remain for later 8e-2 sessions
  (owner-directed scope: Input family only — plan R3 / FM \#18/#25).
- **Strict TDD — PURE run-and-observe** (no defect; the Input pane
  already renders and `navigate_to_tab("Input")` already targets the
  right tab — “Input” IS the `tabPanel` title, `appUI.R:120-124`) →
  green-on-arrival `[refactor-only]` conversion, gated
  `PRE-RED→run-and-observe` via `AskUserQuestion`; rigor from a
  `[mutation-check]` (no synthetic RED).
- All 19 blocks converted from the content-blind
  `navigate_to_tab → grepl(get_html_safe(app,"body"))` idiom to
  `assert_active_pane(app, "Input", <static pattern>)`. Patterns sourced
  firsthand from the **`innerText` visibility-map** of the Input pane —
  default-visible sidebar controls (h3 “Data Input and Quality Control”,
  “File Type”, “Select Pedigree File”, “Minimum Parent Age”, “Read and
  Check Pedigree”), the nested-tab nav labels (“QC Summary”, “Errors”,
  “Cleaned Data”, “Input Format”), and the active “Input Format” tab’s
  `includeHTML(input_format.html)` guidance (“comma-delimited”,
  “tab-delimited”, “Excel”, “genotype”). Conditionally-hidden controls
  (the Separator radio, non-default fileInputs) and non-active nested
  tabs are `display:none` → deliberately avoided.
- **Honest tautology conversion:** `input-detailed` “has example data
  option” (`expect_true(TRUE)`) names a feature the module does NOT have
  → converted to NULL-pattern `assert_active_pane(app, "Input")`
  (asserts navigation genuinely landed on the visible Input pane), not a
  forced match on incidental doc text. `input-tutorial` “genotype file
  support” (also a tautology) DOES have real backing → real
  `"genotype"`.
- **Static UI only** (data-bearing tables/plots deferred to 8e-6).
- **Verification:** baseline browser run 19/19 green → post-conversion
  **19/19 blocks GREEN / 19 expectations**, 0 error / 0 skip
  (`filter="^e2e-input"`, env
  `NPRC_RUN_E2E=true NOT_CRAN=true RENV_CONFIG_AUTOLOADER_ENABLED=false`).
  **`[mutation-check]` PASS** — correct→TRUE; wrong-pane
  `(Age-Sex Pyramid)`→FALSE; wrong-content
  `(Input,"Color Scheme")`→FALSE (Pyramid-only label, absent from the
  Input pane); old whole-body `grepl("Color Scheme")`→TRUE
  (content-blind contrast — exactly the defect the conversion closes).
  Non-e2e regression **2122 passed / 0 failed / 0 error** (159
  e2e-skipped, 5 pre-existing `modPyramid` warnings — unchanged S38
  baseline).
- **Test-tree-only** → no `document()`/NEWS bullet, `tests/`
  lint-exempt. Phase-3E satisfied by the live browser run +
  mutation-check spike (the \#31 pattern — drove the real app).

### 2026-06-07 — Phase 8e-2 (home-nav + app-file sub-slice): boot-level tautologies → behavioral active-pane assertions (issue \#40, Session 38)

- **Deliverable (implementation):** the home-navigation + light-app-file
  sub-slice of plan slice 8e-2
  (`docs/planning/phase8e-assertion-strengthening-subplan.md`). 8e-2
  spans 11 files / 64 browser-booting `test_that` blocks (plan risk R3 /
  §5 8e-2 dragon = oversized) → split by owner `AskUserQuestion`; this
  session did **home-navigation (10 blocks) + test-app-loading (2) +
  test-app-navigation (2)**. Input, pedigree, and pyramid families
  remain for later 8e-2 sessions.
- **Strict TDD — PURE run-and-observe** (no defect in scope; the app
  already behaves and every navigation targets the correct tab) →
  green-on-arrival `[refactor-only]` conversion, gated
  `PRE-RED→run-and-observe` via `AskUserQuestion`; rigor supplied by a
  `[mutation-check]` (no synthetic RED).
- **`test-e2e-home-navigation.R`** — 5 Home-pane content checks →
  `assert_active_pane(app, "Home", …)`; the 3 `#goto_*` clicks →
  `assert_active_pane(app, "Input" / "Pedigree Browser" / "Age-Sex Pyramid", …)`,
  turning a no-op-tolerant body-grepl into a real pane-switch assertion
  (the buttons are wired to `updateNavbarPage(...)`,
  `appServer.R:72-94`). The 2 navbar-label tests (“Navbar has all main
  tabs”, “More menu exists”) stay whole-DOM `grepl` **carve-outs**
  (navbar `<ul>`/dropdown labels live outside every `.tab-pane`;
  documented inline).
- **`test-app-loading.R`** — block 1 now also asserts the app boots to
  the **Home pane** (`assert_active_pane`); block 2’s navbar body-grepl
  strengthened **structurally** to assert the real tab anchors exist
  (`wait_for_element(app, 'a[data-value="Input"]')` …), not a substring
  the Home pane’s “Go to Input” button also satisfies.
  **`test-app-navigation.R`** — the two `nchar>0` tautologies become a
  real Input tab-anchor click → pane-switch assertion; the
  `is.list(values)` check gains
  `expect_identical(app$get_value(input="mainNavbar"), "Home")`.
- **Static UI only** (data-bearing tables/plots deferred to 8e-6);
  patterns sourced from each pane’s module UI (`modInput.R:42`,
  `modPedigree.R:52,103`, `modPyramid.R:25-32`).
- **Verification:** opt-in browser run of the 3 files **14/14 blocks
  GREEN, 22 expectations** (net +2 vs the 20-expectation baseline), 0
  error / 0 skip. **Mutation check passed** — after `#goto_input`,
  asserting the wrong pane (`"Home"`/`"Age-Sex Pyramid"`) returns FALSE
  and a Pyramid-only pattern (`"Color Scheme"`) returns FALSE, while the
  old whole-body `grepl` for a Pyramid keyword passes on Input
  (content-blind). Non-e2e regression unchanged: **2122 passed / 0
  failed / 0 error** (159 e2e-skipped, 5 pre-existing `modPyramid`
  warnings). Test-tree-only → no `document()`, no `NEWS.md` bullet,
  `tests/` is lint-exempt.

### 2026-06-07 — Phase 8e-1: active-pane assertion foundation + summary-statistics conversion (issue \#40, Session 37)

- **Deliverable (implementation):** slice 8e-1 of
  `docs/planning/phase8e-assertion-strengthening-subplan.md` — the
  load-bearing foundation for converting the shinytest2 E2E suite from
  boot-level tautologies to behavioral active-pane assertions. Strict
  TDD (PRE-RED→RED, RED→GREEN gated) + a spike-failure scope-fork owner
  gate.
- **4 active-pane helpers** added to
  `tests/testthat/helper-shinytest2.R` — `get_active_pane_text`,
  `get_active_pane_value`, `wait_for_active_pane`, `assert_active_pane`
  (+ an internal `.active_pane_js()` builder), following the existing
  `*_safe` never-throw convention. `assert_active_pane()` is the drop-in
  replacement for the `get_html(app,"body")` +
  [`grepl()`](https://rdrr.io/r/base/grep.html) tautology: it asserts
  the NAMED top-level navbar pane is the single visible/active one
  (catching a wrong-tab or silent-no-op navigation) and optionally that
  its visible `innerText` matches a pattern. **11 browser-free unit
  tests / 59 expectations** in `test_helper_shinytest2.R`
  (fake-AppDriver stubs, the Phase-8a idiom).
- **Spike-corrected mechanism (HARD GATE).** The live-Chrome spike
  FALSIFIED the plan’s §2.3/§4 selector
  (`.tab-content > .tab-pane.active`): the modules nest their own
  `tabsetPanel`s, so `.tab-content` is non-unique (5 containers;
  first-match `querySelector` latches onto a nested pane). Corrected to
  the only `.tab-content` not inside a `.tab-pane` → its direct-child
  `.tab-pane.active` (structural; no dependence on the dynamic
  `data-tabsetid`). Owner-approved deviation; re-confirmed 17/17 through
  the real helpers (all navs incl. the navbarMenu “More” children;
  innerText honors visibility when correctly scoped).
- **`test-e2e-summary-statistics-module.R` converted** — fixed the 7
  wrong-tab navigations (tests 2–8 went to “Genetic Value Analysis”;
  “Summary Statistics” is its own `tabPanel`, appUI.R:156-159) + dropped
  the false “embedded in another tab” fallback, and replaced all 8
  tautologies/hidden-DOM asserts with `assert_active_pane()` on STATIC
  UI (export-button labels, the heading, the population-genetics
  guidance). Data-bearing content (summary/founder tables, rendered
  plots) deferred to slice 8e-6.
- **Verification:** helper unit tests 59/0/0; live spike 17/17;
  converted e2e file 8/8/0 (opt-in); mutation check PASS
  (wrong-tab→FALSE, correct-tab→TRUE — the old `expect_true(TRUE)`
  passed both); non-e2e regression 2122 passed / 0 failed / 0 error (159
  e2e-skipped, 5 pre-existing `modPyramid` warnings).
- **Scope:** test-infra only (no `R/` change) → `document()` N/A,
  `tests/` lint-exempt, CHANGELOG only (no NEWS). See
  `PROJECT_LEARNINGS.md` Learning \#37 + glossary `[hard-gate-spike]`.

### 2026-06-06 — Phase 9: retire the legacy monolithic Shiny app (declare modular canonical) + \#27 CLOSED (Session 35)

- **Deliverable (implementation):** the FINAL phase of the shiny-module
  conversion (`docs/planning/shiny-module-conversion-plan.md` §9
  Phase 9) — retire the monolith now that the modular app is canonical
  and at parity (Phases 1–8). Strict TDD (RED→GREEN gated) + 4 owner
  `AskUserQuestion` gates + the pre-RED→RED / RED→GREEN TDD gates.
  **This completes the entire XARCH-1 / issue-#27 modularization
  campaign (Phases 1–9).**
- **[`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
  → deprecated alias.** Rewrote it as a
  [`lifecycle::deprecate_soft()`](https://lifecycle.r-lib.org/reference/deprecate_soft.html)
  alias launching `runModularApp(port=6013L, launch.browser=TRUE)`;
  zero-arg callers keep working. New
  `tests/testthat/test_runGeneKeepR_alias.R` (deprecation + delegation +
  port/launch.browser forwarding) and `test_monolith_removed.R`
  (`system.file("application")==""`).
- **Deleted `inst/application/`** (server.r, ui.r, global.R, 8 uitp\*.R,
  example_1.R, the dead modPyramid.R stub, www/ — 17 tracked files) as
  its own revertible commit (§15). `inst/www/` (the modular app’s
  `data-ready.js`) preserved.
- **Removed confirmed orphans (owner-approved):** `getMinParentAge`
  (unexported, 0 callers), `getLogo` (exported, monolith-only — a
  public-API removal), `shouldShowErrorTab` (exported but bypassed by
  `checkErrorLst`; also dropped the dead `qcResults` build in
  appServer.R + the `@seealso` refs), `modMinimalTest` (unmounted
  scaffold) + their tests. `document()` dropped 4 exports + 4 man pages.
- **NAMESPACE fallout fixed:** `getMinParentAge.R` was the SOLE carrier
  of `@import shiny`, so its deletion dropped `import(shiny)` and the
  modular UI failed (`h5` not found); relocated `@import shiny` to
  `R/nprcgenekeepr-package.R`. Caught by the regression run, not the
  inventory (Learning \#35).
- **Pre-flight (irreversible delete):** re-ran the §10 grep-inventory as
  a read-only multi-modal sweep + completeness critic
  (`wf_48a6f152-f0f`); firsthand-verified the sole `system.file`
  reference, `inst/www` ≠ `inst/application/www`, the lifecycle dep, and
  that all 17 files are tracked/revertible.
- **Docs:** `_pkgdown.yml` (drop getLogo/getMinParentAge),
  `inst/WORDLIST`, `CLAUDE.md`, `ROADMAP.md` (milestone marked
  complete), `NEWS.Rmd`/`NEWS.md` (monolith-retirement bullet), vignette
  `_running_shiny_application.Rmd` →
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md);
  `README.md` re-knit. (`a3manual`/`a2interactive` `.md/.html/.R` are
  stale-by-design release artifacts — rebuilt from source at release;
  `check()` builds vignettes from source regardless.)
- **Verification:** non-e2e regression **2135 passed / 0 failed / 0
  error** (5 pre-existing modPyramid warnings); runtime smoke
  [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
  → modular app **HTTP 200**; **`devtools::check()` = 0 errors / 0
  warnings**, `creating vignettes ... OK` (pre-existing NOTEs only:
  non-standard top-level dev files; a stale `spelling.Rout.save`
  baseline); grep confirms no `system.file("application")`.
- **Pre-existing fix (separate `fix:` commit, owner-approved):**
  `a2interactive.Rmd` error-list table was missing the `invalidIdChars`
  description (NEW-45 drift:
  [`getEmptyErrorLst()`](https://github.com/rmsharp/nprcgenekeepr/reference/getEmptyErrorLst.md)
  has 10 fields vs 9 hardcoded) — failed the vignette build; surfaced by
  the full `check()`.
- **Issue \#27 (Modularize code using shiny modules) CLOSED.**
- Commits: `3db018d1` (refactor!: alias + orphans), `24992e0b` (feat!:
  delete monolith), `53a9e5e0` (docs), `a1618c48` (fix: a2interactive
  vignette), + this `docs:` close-out.

### 2026-06-06 — Implement Phase 8d of the conversion E2E harness: interaction/menu tier green + CI filter broadened to the full tier + \#39 CLOSED (Session 34)

- **Deliverable (implementation):** the FINAL sub-phase of the Phase 8
  E2E mini-campaign (`docs/planning/phase8-e2e-harness-subplan.md`
  §5(8d)) — the **5 interaction/menu E2E files** (home-navigation,
  settings-about, workflow-integration, error-states,
  boundary-conditions; 47 blocks / 53 expectations) green-or-clean-skip
  opt-in, **broaden the CI run-step filter** to the full `^(app|e2e)-`
  tier (all 23 files), **close issue \#39**, and file the 8e follow-on
  (#40). **Config / run-and-observe** (TDD code-phases INAPPLICABLE —
  owner-approved gate, like 8b/8c): the §8.2 navbarMenu spike + the
  53/53 green run proved the provisional `navigate_to_menu_item` is
  already correct, so the only code touch is a comment-only docstring +
  the CI YAML filter — no R unit to write test-first.
- **§8.2 navbarMenu spike — RESOLVED (verify-first, before
  classifying).** `set_inputs(mainNavbar="Settings"/"About"/"Help")` →
  `get_value(input="mainNavbar")` reads back the child label TRUE for
  all 3 → `navigate_to_menu_item`’s delegate-to-`navigate_to_tab` body
  is final (no DOM dropdown-open+click). `click("#goto_input")`
  navigates for real. **Honesty nuance (→ 8e/#40):** the input value
  reaches the navbarMenu child but the VISIBLE pane does not truly
  switch — `grepl(body)` passes only via the §2.3 hidden-DOM (§8.3
  navigation-false-positive).
- **The 5 8d files — green opt-in.** `NPRC_RUN_E2E=true NOT_CRAN=true` →
  47 test_that blocks / 53 expectations, 0 fail / 0 error / 0 skip. All
  four S33 Watch items confirmed benign firsthand (E2E_TIMEOUT defined +
  only used inside test blocks; the 6 `#goto_*` observers wired
  `appServer.R:73-95`; boundary’s named `height/width` handled by
  `create_app_driver`; the `input-` selectors stay tryCatch-swallowed
  no-ops — 8e).
- **CI filter broadened** to `^(app|e2e)-` (verified firsthand it
  selects EXACTLY the 23 test-{app,e2e}-\* files — replicating
  testthat’s stripped-name match in R — and excludes the `appServer`
  near-miss via the trailing `-`); job env + `stop_on_failure=TRUE` +
  the `sum(passed)==0` silent-skip guard unchanged. Full tier
  re-validated in ONE process: **193 passed / 0 fail / 0 error / 0
  skip**, 23 files.
- **⚠ Low-rate Chrome process-count FLAKE found + handled.** An
  ultracode 4-lens adversarial review (`wf_ef031b1d-edc`) caught that
  the 23-in-one-process run is intermittently flaky — ~1 transient
  Chrome error in 5 local full-tier runs (`workflow-integration.R` “App
  maintains state when switching tabs”; isolated 8/8/8) — the §5(8c)/R2
  dragon; under `stop_on_failure=TRUE` it can red the scheduled job.
  Reproduced firsthand (2 fresh dedicated runs clean → low-rate +
  contention-sensitive). **Owner decision (`AskUserQuestion`): close
  \#39 now + document the flake**; CI-stability hardening (per-group
  fresh processes) routed to \#40.
- **Issue tracker:** **\#39 CLOSED** (`--reason completed`, with a
  validation/watch-item comment). **8e filed as \#40** (“Strengthen
  shinytest2 E2E assertions…”, label `enhancement`) capturing the
  §2.4/§2.5/§6 deferred items + today’s navbarMenu false-positive, plus
  a CI-stability comment for the flake.
- **Validation:** §8.2 read-backs TRUE; 53/53 8d green; 193/0/0/0
  full-tier single-process; non-e2e regression (`NOT_CRAN=true`,
  NPRC_RUN_E2E unset → e2e clean-skip) = **0 failed / 0 error**, 0
  non-e2e offenders, 2159 passed, 156 e2e-skipped, 5 pre-existing
  `modPyramid` warnings (unchanged S31/S32/S33 baseline). Diff is
  comment-only (helper docstring) + the CI filter → `document()` N/A,
  `tests/`+`.github` lint-exempt, no `* 2.*` source dupes; committed
  `d254a91c` with **explicit `git add`** of only the 2 files (the
  review’s `.DS_Store` BLOCKER). **Live GitHub run DEFERRED** (branch
  not on remote) — TWO watch items now (renv lib-path + the flake).
- **Next:** parent **Phase 9** (declare the modular app canonical +
  DELETE the monolith — IRREVERSIBLE, its own session, do NOT bundle;
  confirm with the owner + grep-inventory first). The \#39 E2E
  mini-campaign (8a–8d) is COMPLETE.

### 2026-06-05 — Implement Phase 8c of the conversion E2E harness: per-module shallow tier green + CI filter broadened (issue \#39) (Session 33)

- **Deliverable (implementation):** the third sub-phase of the Phase 8
  E2E mini-campaign (`docs/planning/phase8-e2e-harness-subplan.md`
  §5(8c)) — run-and-observe the **15 shallow per-module E2E files** (103
  tests) green opt-in, and **broaden the CI run-step filter** in
  `.github/workflows/shinytest2.yaml` from the 3 boot-smoke files to the
  **18 verified 8b+8c files**. **Config / run-and-observe** (TDD
  code-phases INAPPLICABLE — approved gate, like 8b): the 15 files + the
  8a helpers already exist and pass trivially via the §2.3 navbarPage
  hidden-DOM, so there is **no new R unit to write test-first**; the
  browser spike is the verification and the only artifact change is the
  CI YAML filter.
- **8c browser spike — green opt-in.** With
  `NPRC_RUN_E2E=true NOT_CRAN=true`, run per module-group: `e2e-input`
  (19), `e2e-pedigree` (19), `e2e-pyramid` (12), `e2e-genetic-value`
  (22), `e2e-summary-statistics` (8), `e2e-breeding-groups` (23) = **103
  tests across 15 files, 0 fail / 0 error / 0 skip.** Chrome launches
  and the modular app boots for every test.
- **Helper corner-cases verified firsthand (§5(8c) DONE):** (a)
  `navigate_to_tab`’s 3rd arg is the ignored `fallback` — the pyramid
  files navigate to the top-level “Age-Sex Pyramid” tab and pass
  (modPyramid’s “Plot”/“Statistics” sub-tabs are never targeted); (b)
  the only content-coupled assertions (`pedigree-detailed.R:57`,
  `pedigree-tutorial.R:169`) pass on the always-rendered
  `pedigree_browser.html` guidance — noted, not changed; (c)
  `summary-statistics-module`’s wrong-tab navigation (7/8 tests go to
  “Genetic Value Analysis”, §2.4) still passes via the hidden-DOM — a
  known 8e item, not an 8c blocker.
- **CI filter broadened** (owner-approved): the run-step `filter` goes
  from `^(app-loading|app-navigation|e2e-data-ready)$` to
  `^(app-loading|app-navigation|e2e-data-ready|e2e-input|e2e-pedigree|e2e-pyramid|e2e-genetic-value|e2e-summary-statistics|e2e-breeding-groups)`.
  Verified firsthand the regex selects **exactly the 18 files** (3 8b +
  15 8c) and **excludes exactly the 5 Phase-8d files** (home-navigation,
  settings-about, workflow-integration, error-states,
  boundary-conditions) — those enter CI only once 8d verifies them. The
  `stop_on_failure=TRUE` + `sum(passed)==0` silent-skip guard and the
  job env block are unchanged.
- **Validation:** the **exact broadened run-step re-run locally in a
  single process** (the §5(8c) AppDriver-process-count dragon — 18 files
  × drivers in one `test_dir`) → **18 files, passed=140 / failed=0 /
  skipped=0 / error=0** (37 8b + 103 8c), exit 0. Full non-e2e suite
  under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)+`NOT_CRAN=true`
  = **0 failed / 0 error**, 0 non-e2e offenders, 156 e2e-skipped, 2154
  passed, 5 pre-existing `modPyramid` warnings (unchanged S31/S32
  baseline). YAML parses; no R/test code changed → `document()` N/A,
  `tests/`+`.github` lint-exempt, no `* 2.*` source dupes. **Live GitHub
  run deferred** (branch not on remote; same posture as S32) — the
  run-step is validated locally end-to-end. **No adversarial workflow**
  (no ultracode opt-in; a one-line filter broadening validated
  end-to-end is “already verified” — a multi-agent review would be
  ceremony for this change surface).
- **Next:** Phase 8d (5 interaction/menu files, 47 tests — needs the
  secondary helpers + the navbarMenu spike → **close \#39** + file the
  8e assertion-strengthening issue). Then parent Phase 9 (monolith
  deletion, irreversible).

### 2026-06-05 — Implement Phase 8b of the conversion E2E harness: first browser run + CI rewire (issue \#39) (Session 32)

- **Deliverable (implementation):** the second sub-phase of the Phase 8
  E2E mini-campaign (`docs/planning/phase8-e2e-harness-subplan.md`
  §5(8b)) — the **first-ever real browser run** of the modular GeneKeepR
  app under `shinytest2`/`chromote`, plus the **CI rewire** of
  `.github/workflows/shinytest2.yaml`. **Config-only** (TDD code-phases
  INAPPLICABLE — approved gate): the 3 boot-smoke files use
  `create_test_app()` + `AppDriver$new` directly / `testServer` (no new
  helpers), so the deliverable is the empirical spike + the CI YAML, not
  RED→GREEN code.
- **🐉 First browser run — green opt-in.** With
  `NPRC_RUN_E2E=true NOT_CRAN=true`, all 3 boot-smoke files run green:
  `test-app-loading.R` (2), `test-app-navigation.R` (3),
  `test-e2e-data-ready.R` (32) = **37 tests, 0 fail / 0 error / 0
  skip.** Chrome launches and the modular app boots. The **navigation
  spike (§8.1) resolved positively** — `a[data-value="Input"]` clicks
  against the live bslib navbar (no self-skip).
- **CI `shinytest2.yaml` rewired** (owner decision: scheduled + manual):
  triggers → `schedule` (`0 7 * * *`) + `workflow_dispatch` (dropped
  per-PR push/pull_request); `NPRC_RUN_E2E:'true'` at **job-level
  `env:`**; `continue-on-error` **removed**; Chrome via
  **`browser-actions/setup-chrome@v2`** (`install-dependencies:true`) +
  `CHROMOTE_CHROME` via `$GITHUB_ENV` + a `find_chrome()`
  resolve-assert; runs only the 3 smoke files with
  `stop_on_failure=TRUE`; `_snaps/`+`*.png` artifact upload kept.
- **Adversarial review caught a HIGH blocker I missed** (4-lens +
  completeness-critic workflow, re-verified firsthand): the rewrite
  added `NPRC_RUN_E2E` but **not `NOT_CRAN`** → on the non-interactive
  `Rscript` runner `skip_on_cran()` fires → all 3 files **silently
  skip** → `stop_on_failure` doesn’t catch skips → the job goes green
  having run nothing. Reproduced firsthand (NOT_CRAN unset → 4 skipped,
  0 run). Fixed: `NOT_CRAN:'true'` at job env. Also hardened: (a)
  `RENV_CONFIG_AUTOLOADER_ENABLED:'false'` so the package installs to
  the **site** lib (the renv autoloader otherwise targets renv’s private
  lib, which the AppDriver subprocess can’t see); (b) an
  **executed-count guard** ([`stop()`](https://rdrr.io/r/base/stop.html)
  if `sum(res$passed)==0`) to make the silent-skip class fail loud; (c)
  a stronger `find_chrome()` assert (single existing path, not bare
  `nzchar` which passes vacuously on `NULL`).
- **Package-install step added** (was missing): `R CMD INSTALL .` after
  `setup-r-dependencies`, since the app subprocess does
  [`library(nprcgenekeepr)`](https://rmsharp.github.io/nprcgenekeepr/)
  and `create_test_app()` uses `system.file(package=)`.
- **No R/test code changed** (sub-plan §11 — the E2E files are
  run/triaged, not rewritten). Full non-e2e suite under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)+`NOT_CRAN=true`
  = **0 failed / 0 error**, 0 non-e2e offenders, e2e skipped (156), only
  the 5 pre-existing `modPyramid` warnings — unchanged from the S31
  baseline.
- **Verification limit (stated, not skipped — not FM \#24):** the CI
  YAML is verified **statically** (YAML parse + 4-lens adversarial
  review + the exact run-step R validated locally) but **not by a live
  GitHub run** — branch `add-methodology` isn’t on the remote and a live
  run would create a remote feature branch (owner chose static +
  adversarial only). The renv lib-path / AppDriver-subprocess
  interaction is the \#1 item to confirm on the first live run.
  `schedule`/`workflow_dispatch` activate once merged to master.
- **Files:** `.github/workflows/shinytest2.yaml` (rewritten);
  `docs/planning/phase8-e2e-harness-subplan.md` §7 (synced — the spec
  had omitted `NOT_CRAN`). Next: **Phase 8c** (15 shallow per-module
  files).

### 2026-06-05 — Implement Phase 8a of the conversion E2E harness: define the 6 driver helpers + E2E_TIMEOUT (issue \#39) (Session 31)

- **Deliverable (implementation):** the first sub-phase of the Phase 8
  E2E mini-campaign (`docs/planning/phase8-e2e-harness-subplan.md`
  §5(8a)) — defined the 6 shinytest2 driver helpers
  - the `E2E_TIMEOUT` constant in `tests/testthat/helper-shinytest2.R`,
    **browser-free RED→GREEN** under strict TDD (resumed after the two
    planning sessions \#21/#30).
- **Helpers added:**
  `create_app_driver(app_dir, name, height=800, width=1200, ...)`,
  `navigate_to_tab(app, tab_label, fallback=NULL)` (sets `mainNavbar`,
  returns TRUE only if the tab reads back — catches a silent no-op nav),
  `get_html_safe`/`get_values_safe`/`click_element_safe`
  (`tryCatch`-guarded →
  `""`/[`list()`](https://rdrr.io/r/base/list.html)/`FALSE`),
  `navigate_to_menu_item` (provisional delegate to `navigate_to_tab`;
  finalized in 8d), and `E2E_TIMEOUT <- 30000L`.
- **Caught a latent bug in the plan’s §4 pseudo-code** (\[verify-first\]
  on the approved plan): the literal
  `create_app_driver(app_dir, name, ...)` hardcodes `height`/`width`
  then splices `...`, so the 2 `test-e2e-boundary-conditions.R` calls
  passing `height=`/`width=` would duplicate-crash `AppDriver$new`
  (*“formal argument ‘height’ matched by multiple actual arguments”* —
  verified that `AppDriver$new` has explicit `height`/`width` formals).
  Fixed by exposing them as named formals; the deviation was approved in
  the PRE-RED→RED phase gate.
- **Tests (browser-free, new file
  `tests/testthat/test_helper_shinytest2.R`):** 14 `test_that` / 32
  assertions using fake-AppDriver
  [`list()`](https://rdrr.io/r/base/list.html) stubs (throwing /
  recording-ok / silent-no-op) to discriminate the existence, signature,
  `*_safe` error, success, and read-back contracts — no Chrome needed
  (mirrors `test_create_test_app.R`). All RED at HEAD, GREEN after.
- **Verification:** full non-e2e suite `0 failed / 0 error`, **2154
  passed** (+32), e2e skipped (156), only the 5 pre-existing
  `modPyramid` warnings; `document()` zero `man/`/`NAMESPACE` delta;
  `tests/` is `.lintr`-excluded → lint-exempt. Phase 3E N/A (helpers
  live only in the test tree — the suite is the runtime). Learning \#31.
  **Next: Phase 8b** (boot-smoke tier + CI rewire — first browser run).

### 2026-06-05 — PLAN: Phase 8 sub-plan — enable the shinytest2 E2E harness (XARCH-1 / issue \#39) (Session 30)

- **Deliverable (planning, not implementation):**
  `docs/planning/phase8-e2e-harness-subplan.md` — a sub-plan for the
  conversion campaign’s Phase 8 (make the dormant shinytest2 browser E2E
  tier executable). The campaign’s second planning/architecture
  deliverable. No code written (FM \#18/#19).
- **Corrected the parent plan §9 Phase 8** via firsthand discovery
  (greps + R one-liners + a read-only workflow: 5-agent census of all 23
  E2E files + adversarial completeness-critic, 16 findings re-verified
  firsthand): the gap is **6 undefined helpers + 1 undefined constant**
  (`create_app_driver` with `...`→height/width,
  `navigate_to_tab(app, label, fallback=NULL)` \[109/137 calls 3-arg\],
  `get_html_safe`, `click_element_safe`, `navigate_to_menu_item`,
  `get_values_safe`, `E2E_TIMEOUT`), **not the “3 helpers”** the parent
  plan claimed — and Phase 8 is a **4-session mini-campaign (8a–8d)**,
  not one session.
- **Key findings:** the `navbarPage` renders ALL tabs’ static UI into
  the DOM at boot
  ([`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
  = 85 KB), so the suite’s dominant `grepl(keyword, "body")` checks
  **pass trivially once the app boots** → “harness runs green” ≠
  “validates behavior” (41 `expect_true(TRUE)` tautologies;
  `summary-statistics-module` navigates to the wrong tab in 7/8 tests
  yet passes). The `input` vs `dataInput` namespace mismatch is real but
  **inert** (polling helpers never called).
- **Owner decisions (`AskUserQuestion`):** (1) scope = **harness-enable
  (8a–8d)** → assertion-strengthening filed as a separate follow-on
  issue (“8e”); (2) CI gating = **scheduled + manual dispatch** (not
  per-PR), drop `continue-on-error`, keep fast unit CI as the per-PR
  gate.
- **Plan structure:** 8a helpers/constant (browser-free RED→GREEN) · 8b
  boot-smoke + CI rewire (first browser run) · 8c 15 shallow per-module
  files · 8d 5 interaction/menu files → close \#39. Each sub-phase has
  DONE + verify-command + session boundary; 23 files / 159 tests fully
  assigned. Updated parent plan §9 + `BACKLOG.md` to point at the
  sub-plan. Learning \#30.

### 2026-06-05 — Implement Phase 7 of the Shiny-module conversion: Input parity, focal-animal / LabKey pedigree build (Session 29)

- **Deliverable (implementation):** wired the modular **Data Input**
  module’s “Focal animals only; pedigree built from database” path so an
  uploaded focal-animal ID list builds a pedigree from the ONPRC LabKey
  EHR — bringing modular `modInput` to monolith parity (plan §9 Phase 7;
  monolith server.r:86-113). All in `R/modInput.R`, inside
  `observeEvent(input$getData)`:
  1.  **Server-side gap fixed.** The UI option already existed
      (`modInput.R:70` radio / `:111-116` `breederFile` / `:244`
      `activeFile`) but was **broken**: the focal-ID file was read *as a
      pedigree* by `readDataFile()` → a spurious “missing columns” QC
      error. Now, when `input$fileContent == "focalAnimals"`, the module
      calls `getFocalAnimalPed(file$datapath, sep)` to build the
      pedigree from the EHR, then feeds it into the existing
      `qcStudbook`/`runQcStudbook` machinery unchanged.
  2.  **DB-failure routing.** A `getLkDirectRelatives` connection
      failure makes `getFocalAnimalPed` return an `nprcgenekeeprErr`
      errorLst; the module routes it to `storedErrorLst()` (cleaned =
      NULL, early return) so the already-wired appServer dynamic **Error
      List** tab surfaces `failedDatabaseConnection` (“Database
      connection failed…”). No new renderer/appServer code.
- **Built more correctly than the monolith.** The monolith detects the
  error shape with `is.element("nprckeepErr", class(...))` — a **typo**
  (the real class is `nprcgenekeeprErr`), so its DB-failure branch never
  fired. The modular wiring uses `inherits(built, "nprcgenekeeprErr")`
  and drops the monolith’s dead bare-`NULL` branch (`getFocalAnimalPed`
  only returns a data.frame or an errorLst).
- **Strict TDD** (RED→GREEN→REFACTOR, all gated + 2 pre-RED
  author-decision `AskUserQuestion`s — the owner-consult fork
  \[mock-wire vs live-integration vs descope\] → **mock-wire/full
  parity**): 2 new tests in `tests/testthat/test_modInput.R` drive
  `testServer(modInputServer)` and mock the LabKey seam via
  `testthat::local_mocked_bindings(getLkDirectRelatives = …, .package = "nprcgenekeepr")`
  so the real `getFocalAnimalPed` body runs (no live EHR). Both **RED at
  HEAD** (happy: `cleaned` NULL because the focal file is read as a
  1-column pedigree; sad: `failedDatabaseConnection` never set),
  **GREEN** after. REFACTOR gated, skipped (minimal/idiomatic).
- **Verification:** `test_modInput.R` 0/0/0 (162 passed); full suite
  under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
  `NOT_CRAN=true` = **0 failed / 0 error**, 0 non-e2e offenders, e2e
  skipped (156), only the 5 pre-existing `modPyramid` warnings (added
  zero), **2122 passed**. Lint **net-zero** on `R/modInput.R` (41 = 41,
  touched-file stash; explicit-`L` on the copied empty-warnings df),
  `document()` **zero** man/NAMESPACE delta, no macOS `* 2.*` dupes,
  **Phase-3E runtime smoke** —
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  binds + HTTP 200, served HTML renders
  `dataInput-breederFile`/`-fileContent`/`-getData` +
  `value="focalAnimals"`. **Verification is environmentally limited**
  (no live EHR): the mock covers everything on the module’s side of the
  ONPRC boundary; the live `getLkDirectRelatives` → `getDemographics`
  call is owner-verifiable only (stated, not skipped — not FM \#24).
  **No NEWS bullet** — input-wiring/display parity for the modular app,
  no analytical-pipeline numeric change (consistent with S22/S23/S25).

### 2026-06-04 — Implement Phase 6 of the Shiny-module conversion: Breeding Groups parity B (Session 27)

- **Deliverable (implementation):** brought the modular **Breeding Group
  Formation** module to monolith parity for seed-group pre-seeding and
  the previously-inert formation controls, all in
  `R/modBreedingGroups.R` (plan §9 Phase 6):
  1.  **Seed-group “current groups” widget** — a `seedGroups` checkbox
      reveals one per-group `textAreaInput` (`curGrp1..N`, count driven
      by `nGroups`). Their IDs build a length-`numGp` `currentGroups`
      list passed to
      [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
      in place of the hardcoded `list(character(0L))`, so groups can be
      pre-seeded (the monolith’s `textAreaWidget`/ `getCurrentGroups`,
      server.r:1019-1056).
  2.  **Exposed three previously-inert controls** the server already
      read (`modBreedingGroups.R` L201-203) but no UI declared, so they
      had silently defaulted: `minAge` (numericInput, value 1),
      `nIterations` (numericInput, value 10L), `withKinship` (checkbox).
      The new control ids match the server reads
      (`minAge`/`nIterations`/`withKinship`), **not** the monolith’s
      `gpIter`/`withKin`.
  3.  **Breeding-sim iteration default `1000L → 10L`** — the modular
      fallback was a 100× drift from the monolith’s `gpIter`
      (value=10L); now matches. This is a **real numeric change** to
      formed groups (the MIS sampler runs 100× fewer iterations by
      default).
- **Built robustly, not faithfully.** The monolith’s `getCurrentGroups`
  is doubly buggy (`seq_along(input$numGp)` is a length-1 scalar → only
  `curGrp1` is ever read; `vapply(...)` yields a matrix not a list); the
  modular widget uses `seq_len(numGp)` so every group’s textarea is
  honored (RED test asserts the 2nd seed group is honored).
  `length(currentGroups)` can never exceed `numGp` (built with
  `seq_len(numGp)` + truncation), so `groupAddAssign`’s length guard is
  unreachable.
- **More robust than the monolith — validate-and-block.** Seed IDs
  absent from the pedigree are rejected with a notification and
  formation aborts. Verified: a phantom seed otherwise survives into the
  group and **crashes** the Phase-5 Group Detail member view
  (`addSexAndAgeToGroup` → `getCurrentAge` on a length-0 birth). The
  monolith has only a partial `validate(need())` guard
  (server.r:1124-1133); the modular module previously had none.
- **Strict TDD** (RED→GREEN→REFACTOR, all gated + 4 pre-RED
  author-decision `AskUserQuestion`s): 7 new tests — 5 RED at HEAD (UI
  controls present; `nIterations` renders `value="10"`; seeding lands
  animals in their group; multi-group seeding \[proves the
  `curGrp1`-only bug not copied\]; phantom seed blocks formation) + 2
  green-at-HEAD coverage (blank-seed no-op; `withKinship=TRUE`→non-NULL
  kinship, green-at-HEAD because the server already reads
  `input$withKinship`). REFACTOR considered + skipped.
- **Verification:** `test_modBreedingGroups.R` 41 tests **0 failed / 0
  error / 0 warning**; full suite under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
  `NOT_CRAN=true` **0 failed / 0 error**, e2e skipped (156), only the 5
  pre-existing `modPyramid` warnings. R6 validate-and-block guard
  **mutation-verified** (disabling it lets the phantom seed survive).
  Lint **net-zero** on `R/modBreedingGroups.R` (31 = 31, touched-file
  stash); `document()` zero man/NAMESPACE delta (`import(shiny)` covers
  the new controls); **Phase 3E runtime smoke** —
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  HTTP 200 with `seedGroups`/`minAge`/`nIterations` (value 10)/
  `withKinship`/`seedTextareas` rendered and the Phase-5 Group Detail
  tab intact.
- A read-only 5-agent discovery + adversarial-completeness recon
  (`wf_e8e1176c-320`) confirmed the parity surface and sharpened the
  dragon (the phantom-seed crash); every load-bearing claim was verified
  firsthand.
- **Files:** `R/modBreedingGroups.R`,
  `tests/testthat/test_modBreedingGroups.R`. **Next: Phase 7**
  (focal-animal / LabKey pedigree build — risk HIGH 🐉, owner consult at
  phase start; see plan §9).

### 2026-06-04 — Implement Phase 5 of the Shiny-module conversion: Breeding Groups parity A (Session 26)

- **Deliverable (implementation):** brought the modular **Breeding Group
  Formation** module to monolith parity for the per-group display/export
  half, all in `R/modBreedingGroups.R` (plan §9 Phase 5). A new **“Group
  Detail” tab** (additive — the existing all-groups “Groups” and
  “Statistics” tabs are untouched) adds:
  1.  **`viewGrp` group selector** (`selectInput`), populated when
      groups form (“Group 1..N”, with the last labelled “Unused” only
      when the appended unused-animals group is non-empty).
  2.  **Per-group annotated member view** —
      [`addSexAndAgeToGroup()`](https://github.com/rmsharp/nprcgenekeepr/reference/addSexAndAgeToGroup.md)
      → rounded age → columns “Ego ID”/“Sex”/“Age in Years”, ordered by
      ID (the monolith’s `bgGroupView`).
  3.  **Per-group kinship matrix view** —
      `filterKinMatrix(groupIds, kmat)` rounded to 6 dp (the monolith’s
      `bgGroupKinView`).
  4.  **`downloadGroup`** (member CSV, `na=""`/`row.names=FALSE`) and
      **`downloadGroupKin`** (kinship CSV, `na=""`/`row.names=TRUE`)
      handlers.
- **Dragon (threading the kinship matrix) discharged.** The kinship view
  computes each group’s submatrix from the module’s already-computed
  full `kmat` (now retained in `groupResults` with a `hasUnused` flag),
  NOT from `result$groupKin` (still NULL — `withKin` defaults FALSE
  until the Phase-6 `withKinship` control). This is **byte-identical**
  to the monolith’s `groupKin[[i]]` (each group’s members ⊆ candidates),
  and the group-**formation** compute path is **unchanged** — proven
  [`identical()`](https://rdrr.io/r/base/identical.html) across three
  `set.seed`ed scenarios (nGroups 3/4/1) vs a pre-change reference
  (`groups`/`score`/`unassigned`/`nGroups`). Display/download only.
- **More robust than the monolith.** Both views clamp `viewGrp` via
  `withinIntegerRange(., 1, length(breedingGroups()))` (the monolith
  clamps the member view to the *requested* `numGp` and leaves the
  kinship view unclamped — a latent out-of-range bug). The
  selector-populating `observe` guards on
  `length(breedingGroups()) >= 1L` (an empty result is a zero-length
  list, which `req()` treats as truthy — the naive guard warned on the
  degenerate harem-with-no-eligible-sires case).
- **TDD:** 5 new tests in `tests/testthat/test_modBreedingGroups.R` (UI
  structure; member-download content; kinship-download content +
  `filterKinMatrix`-equivalence; selector switches group; out-of-range
  clamp) — all red at HEAD, green after. Founders-with-birth fixture
  gives a deterministic kinship submatrix (0.5 diagonal / 0
  off-diagonal); assertions key on the *actual* formed group. Full suite
  under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
  `NOT_CRAN=true`: **0 failed / 0 error**, 156 e2e skipped, 5
  pre-existing `modPyramid` warnings, 2264 passed. Lint net-zero on
  `R/modBreedingGroups.R` (31 = 31); `document()` zero man/NAMESPACE
  delta; **Phase 3E runtime smoke** —
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  HTTP 200 with the Group Detail tab + selector + downloads rendered.
- **Housekeeping:** removed two stray untracked macOS “filename 2”
  duplicates (`R/modBreedingGroups 2.R`,
  `tests/testthat/test_modBreedingGroups 2.R`) that had appeared
  mid-session and were doubling the generated `.Rd` docs and
  double-running the test file (moved aside to `/tmp`, not in git).
- **No `NEWS.md` bullet** — this is display/download parity for the
  not-yet-canonical modular app with no change to the analytical
  pipeline (NEWS is reserved for numeric changes + the Phase 9
  deprecation). Plan §9 Phase 5 → DONE; next is Phase 6 (seed-groups +
  inert controls).

### 2026-06-04 — Implement Phase 4 of the Shiny-module conversion: genotype file merge in modInput (Session 25)

- **Deliverable (implementation):** brought the modular **Data Input**
  module to monolith parity for the **separate pedigree/genotype**
  upload path, all in `R/modInput.R` (plan §9 Phase 4).
  1.  **Genotype file merge.** Inside `observeEvent(input$getData)`,
      before the `qcStudbook`/ `runQcStudbook` calls, the
      `separatePedGenoFile` path now reads `input$genotypeFile` via
      [`getGenotypes()`](https://github.com/rmsharp/nprcgenekeepr/reference/getGenotypes.md),
      validates with
      [`checkGenotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkGenotypeFile.md)
      (degrading to no-merge on warning/error, mirroring the monolith),
      and merges it into the raw pedigree via
      [`addGenotype()`](https://github.com/rmsharp/nprcgenekeepr/reference/addGenotype.md).
      The integer `first`/`second` columns then ride the cleaned
      studbook into
      [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
      (via
      [`getGVGenotype()`](https://github.com/rmsharp/nprcgenekeepr/reference/getGVGenotype.md)/[`hasGenotype()`](https://github.com/rmsharp/nprcgenekeepr/reference/hasGenotype.md)),
      so genome-uniqueness uses the real genotypes. Previously
      `activeFile()` silently dropped `input$genotypeFile`.
  2.  **`genotypeData()` populated.** Added
      `genotype = getGVGenotype(qcResult$cleaned)` to the module’s
      stored results, so the `genotypeData()` reactive (formerly always
      NULL) returns the id/first/second extract (NULL when no genotype,
      preserving the prior contract).
  3.  **More robust than the monolith.** The merge is **NULL-guarded** —
      `addGenotype(ped, NULL)` crashes
      (`"'by' must specify a uniquely valid column"`), a latent
      unguarded crash in the monolith; a malformed genotype file now
      degrades to no-merge instead of crashing the QC run.

  - **Common-mode unchanged (proven at parity):** neither app
    integer-codes string allele names for a combined ped+genotype file,
    so common-mode genotypes never reach `reportGV`’s gene-drop in
    either app — adding `addGenotype` to the common branch would be a
    behavior change beyond parity. Phase 4 touches only the
    `separatePedGenoFile` path.
- **Tests:** 2 new tests in `tests/testthat/test_modInput_qcStudbook.R`
  — a discriminating happy-path (upload the shipped
  `obfuscated_rhesus_mhc_ped.csv` + `…_breeder_genotypes.csv`; assert
  the cleaned studbook gains `first`/`second`,
  [`hasGenotype()`](https://github.com/rmsharp/nprcgenekeepr/reference/hasGenotype.md)
  TRUE, `genotypeData()` populated) and a malformed-genotype
  graceful-degradation test (NULL-guard mutation-verified).
- **Method (TDD, ultracode):** RED→GREEN→REFACTOR with all gates + 2
  pre-RED author decisions via `AskUserQuestion` (populate
  `genotypeData()` too; reader =
  [`getGenotypes()`](https://github.com/rmsharp/nprcgenekeepr/reference/getGenotypes.md));
  a 5-agent read-only discovery + adversarial-completeness recon
  (`wf_37c91d78-d24`) settled the
  common-mode/NULL-crash/testServer-harness questions, all verified
  firsthand.
- **Verification:** full suite under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
  `NOT_CRAN=true` = 0 failed / 0 error, 0 non-e2e offenders, 2085
  passed, e2e skipped (156); lint net-zero on `R/modInput.R` (41 = 41);
  `devtools::document()` no man/NAMESPACE delta; **Phase 3E runtime
  smoke**
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  binds + HTTP 200 (modInput mounts with the `genotypeFile` input). No
  NEWS bullet (modular app not yet canonical; no analytical-pipeline
  numeric change).
- **Files:** `R/modInput.R`,
  `tests/testthat/test_modInput_qcStudbook.R`. **Next: Phase 5**
  (Breeding Groups downloads + per-group kinship + group selector).

### 2026-06-04 — Implement Phase 3 of the Shiny-module conversion: GVA genome-uniqueness threshold + subset/filter export (Session 24)

- **Deliverable (implementation):** brought the modular **Genetic Value
  Analysis** tab to monolith parity across four verified gaps, all in
  `R/modGeneticValue.R` (plan §9 Phase 3).
  1.  **Genome-uniqueness threshold control.** Added a
      `selectInput(ns("threshold"))` (choices 1–5, default 4) threaded
      via a new `guThreshold()` reactive into
      [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md),
      replacing the hard-coded `guThresh = 1L`. This changes default
      genome-uniqueness output for the modular app (intended parity —
      the monolith default is the threaded integer 4).
  2.  **Subset/filter view.** Added a `viewIds` textarea + “Filter View”
      button + a `gvaView()` reactive that filters the report by entered
      IDs via the exported
      [`filterReport()`](https://github.com/rmsharp/nprcgenekeepr/reference/filterReport.md)
      (monolith `gvaView`/`filterReport`, server.r:462-477); the
      rankings table now reflects the filter.
  3.  **Export Subset.** Added `downloadGVASubset` (writes the filtered
      view, `na=""`); relabeled the existing `downloadRankings`
      “Download” → “Export All” to pair with it.
  4.  **Gene-drop iterations default** 5000 → 1000 (monolith parity);
      **removed** the inert `minAge` slider (never read; no monolith GVA
      counterpart).
- **Author decisions (USER, via `AskUserQuestion`):** direct threshold
  mapping (choices 1–5, default 4 — drops the monolith’s confusing
  label-offset while keeping the threaded integer 4); iterations default
  1000; remove minAge only (the 2 sibling inert checkboxes
  `calcGenomeUniqueness`/`calcMeanKinship` deferred); whole Phase 3 in
  one session.
- **TDD:** strict RED→GREEN→REFACTOR with phase gates (each via
  `AskUserQuestion`). 6 new discriminating tests in
  `tests/testthat/test_modGeneticValue.R`; minAge removal in REFACTOR
  deleted 2 tautological tests + 3 assertion lines (no real coverage
  lost — they only echoed the inert input back).
- **Discriminating-RED traps (verify-first, Learnings \#15/#20):** (a)
  no existing test pinned the threshold, so all pass on the buggy
  `guThresh=1L` — the RED keys on the threaded integer via an internal
  `guThreshold()` reactive (empirically guThresh 1 vs 4 changes every
  `gu` row); (b) the flipped iterations assertion `grepl("1000")` first
  PASSED on the bug because `max="10000"` contains “1000” — re-keyed on
  the rendered `value="1000"` attribute.
- **Recon:** a read-only discovery + adversarial-completeness workflow
  (`wf_a1f5fdb4-b8e`, 4 agents) re-derived the parity surface and
  flagged three implementation blockers, all verified firsthand: `%||%`
  is not portable (not in shiny/this package; base only since R 4.4) →
  used an explicit `is.null` guard; `stri_trim` is not the imported
  symbol (`stri_trim_both` is) → used base `trimws`; `import(shiny)`
  (NAMESPACE:168) covers the new `selectInput`/`textAreaInput`.
- **Verification:** `test_modGeneticValue.R` 53/53; full suite under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
  `NOT_CRAN=true` = 0 failed / 0 error, 0 non-e2e offenders, e2e skipped
  (156), 5 pre-existing `modPyramid` warnings; lint net-zero on
  `R/modGeneticValue.R` (HEAD 23 = NOW 23, via touched-file stash);
  `document()` no man/NAMESPACE delta; Phase 3E runtime smoke —
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  binds + HTTP 200, the new threshold/viewIds/Export-Subset controls
  render and the minAge slider is gone. NEWS bullet added (the plan
  reserves NEWS for this numeric change). Commit `280d1df0` (impl) + the
  `docs:` close-out.

### 2026-06-03 — Implement Phase 2 of the Shiny-module conversion: wire the GvAndBgDesc description tab (Session 23)

- **Deliverable (implementation):** mounted the already-built
  `modGvAndBgDesc` module as a navbar tab so the modular app gains the
  monolith’s **Genetic Value Analysis and Breeding Group Description**
  tab (plan §9 Phase 2).
  - `R/appUI.R`: a `tabPanel` after “Breeding Groups” (monolith-parity
    placement, per `inst/application/ui.r`) calling
    `modGvAndBgDescUI("gvAndBgDesc")`.
  - `R/appServer.R`: `modGvAndBgDescServer("gvAndBgDesc")`
    (informational module — returns NULL, no reactive state).
- **TDD:** strict RED→GREEN (REFACTOR skipped — author decision; the
  change is minimal/idiomatic). Two new integration tests in
  `tests/testthat/test_modGvAndBgDesc.R`.
- **Discriminating-RED gotcha (verify-first, Learning \#15/#20/#23):**
  the module’s H3 heading (“Genetic Value Analysis and Breeding Group
  Description”) is NOT a discriminating marker — `genetic_value.html`,
  already mounted by `modGeneticValue`, contains that exact phrase, so a
  naive heading assertion is a tautology that passes at HEAD. The
  discriminating marker is `gvAndBgDesc.html`’s own body text
  (`"kinship coefficients"` / `"genetic value analysis proceeds"`),
  unique among the mounted guidance HTML and absent from
  [`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
  at HEAD. (`modGvAndBgDescUI` does not call `NS()`, so there is no
  namespaced container to assert on — the included content IS the mount
  marker.)
- **Verification:** `test_modGvAndBgDesc.R` 10/10,
  `test_appServer_dynamicTabs.R` 23/23 (the dynamic insert/remove-tab
  interaction is unaffected — the new tab is far from the “Input” insert
  target); full suite under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
  `NOT_CRAN=true` = 0 failed / 0 error, 2073 passed (+2), e2e skipped
  (156), 5 pre-existing `modPyramid` warnings; lint net-zero (appUI 0=0,
  appServer 18=18); `document()` no man/NAMESPACE delta; Phase 3E
  runtime smoke —
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  binds + HTTP 200. Commit `ef6a9f4c`.
- **NEWS deferred** to the Phase 9 canonical switch (modular app not yet
  canonical).

### 2026-06-03 — Implement Phase 1 of the Shiny-module conversion: Summary Statistics tab parity (Session 22)

- **Deliverable (implementation):** brought the modular app’s **Summary
  Statistics tab** (`R/modSummaryStats.R`) to legacy-monolith parity
  across four verified gaps (plan §9 Phase 1):
  1.  **Z-score plots** now render.
      [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
      emits the column `zScores` (plural), but `modSummaryStats` checked
      `zScore` (singular) — so the z-score histogram + boxplot were
      always NULL (“Z-scores not available”). Fixed with a dual-name
      lookup (prefer `zScores`, fall back to `zScore`), matching
      `modGeneticValue`’s existing `indivMeanKin`/`meanKinship` idiom.
      (Real column name confirmed empirically before the fix.)
  2.  **Mean-Kinship / Genome-Uniqueness quartile tables**
      (Min/1st-Q/Mean/Median/3rd-Q/Max) rendered on the Summary tab
      (monolith `server.r:545-630`); previously only 3 scalars showed.
  3.  **Founder table** (Known/Female/Male counts + FE + FG) rendered on
      the Summary tab (monolith `server.r:558-570`) by threading
      `modGeneticValue`’s `founderStats` reactive into
      `modSummaryStatsServer` (new `founderStats` param; wired in
      `R/appServer.R`).
  4.  **Kinship-matrix download** fixed: was a dead button (`req()` on a
      NULL `kinshipMatrix` arg with `appServer.R` passing `NULL`); now
      writes the module’s internal `getKinshipMatrix()`.
- **TDD:** strict RED→GREEN (REFACTOR skipped — author decision). New
  discriminating tests in `tests/testthat/test_modSummaryStats_parity.R`
  (6 tests / 22 expectations); the z-score test uses ONLY the real
  `zScores` column so it fails on the singular-name bug — a pre-existing
  `_ggplots` test passed on the bug because its fixture injects both
  names (Learning \#15/#20).
- **Author decisions (`AskUserQuestion`):** founder table → add to
  Summary tab (keep GVA subtab); kinship download → use the module’s
  internal kinship (smallest change, no relationship-basis change —
  avoided the plan’s “thread reportGV kinship” dragon).
- **Verification:** full suite under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
  `NOT_CRAN=true` = 0 failed / 0 error, 2071 passed (+22), e2e skipped;
  lint net-zero (modSummaryStats 60=60, appServer 18=18);
  `devtools::document()` (only `man/modSummaryStatsServer.Rd`); runtime
  smoke —
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  binds + HTTP 200. NEWS deferred to the Phase 9 canonical switch
  (modular app not yet canonical).
- **Files:** `R/modSummaryStats.R`, `R/appServer.R`,
  `man/modSummaryStatsServer.Rd`,
  `tests/testthat/test_modSummaryStats_parity.R`. Plan:
  `docs/planning/shiny-module-conversion-plan.md` §9 Phase 1.

### 2026-06-02 — PLAN: complete the Shiny-module conversion (XARCH-1 / issue \#27) (Session 21)

- **Deliverable (planning, not implementation):**
  `docs/planning/shiny-module-conversion-plan.md` — a 9-phase,
  vertical-slice plan to declare the modular app
  (`runModularApp`/`appUI`/ `appServer`/`mod*`) canonical, reach feature
  parity with the legacy monolith (`inst/application/`), enable the
  shinytest2 E2E tier, then delete the monolith and make
  [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
  a
  [`lifecycle::deprecate_soft`](https://lifecycle.r-lib.org/reference/deprecate_soft.html)
  alias. Followed the ARCHITECTURE workstream + the SESSION_RUNNER
  Planning protocol (evidence-based grep inventory, per-phase
  done-criteria, vertical slices). The project’s first
  planning/architecture deliverable.
- **Method:** a read-only 8-mapper discovery workflow + firsthand
  verification of every load-bearing claim + a 3-agent
  completeness-critic that caught 4 real parity gaps the single-pass
  synthesis missed (dead kinship-download button; dropped MK/GU quartile
  tables; FE/FG founder-table placement; a 100× breeding-`gpIter`
  default drift).
- **Author scope decisions (via `AskUserQuestion`):** full conversion
  (parity + E2E + retire); exclude ORIP/Settings (parity = match the
  monolith); re-expose the GU-threshold selector (default 4).
- **Key findings (reframe the audit):** the modular app is far more
  complete than `TECH_DEBT_AUDIT_2026-05-30.md` implied; the audit’s “do
  XARCH-3/4/7 before XARCH-1” sequencing is moot (verified); the E2E
  suite is unwritten scaffolding (its driver helpers are defined
  nowhere) — this is the real scope of issue \#39; issue \#34
  (“integrate qcStudbook in modInput”) is stale (already integrated). No
  code changed this session.
- **Next:** implement **Phase 1 only** (Summary Statistics tab parity)
  under strict TDD.

### 2026-06-02 — Fix vacuous “no potential parent” assertion in `test_getPotentialParents.R` (Session 20)

- **Defect (found Session 4, fixed now):** the test “works with records
  with no potential parent” pushed BRI2MW’s birth to 1950 into a local
  `ped` but then asserted the old top-level `potentialParents[[1L]]$id`
  from the *unmodified* fixture — a tautology already covered by the
  first test that never inspected `ped` and verified nothing about its
  named scenario (copy/paste slip).
- **Fix (REFACTOR-only under strict TDD; no production change):**
  replace the assertion with a discriminating one. BRI2MW is a
  from-center founder with both parents unknown that normally appears in
  the output; with its birth at 1950 its breeding-age candidate set is
  empty, so `getPotentialParents` correctly drops it via the
  no-breeding-age-candidate skip. The test now asserts BRI2MW is present
  in the unmodified fixture (precondition), absent from the scenario
  result, and that the result has exactly one fewer entry (50 → 49).
- **Why REFACTOR-only:** `getPotentialParents` is already correct, so a
  correct assertion is green-on-arrival; strict TDD forbids declaring
  RED on a passing test, and forcing a fail with a wrong expectation
  would be a synthetic RED (Learning \#18c). Rigor instead came from a
  mutation check: disabling the skip makes both new assertions fail,
  proving the test discriminates (the old assertion passed against that
  same mutant).
- **Verification:** full suite under `load_all` + `NOT_CRAN=true`: **0
  failed / 0 error**, zero non-e2e offenders, **2049 passed** (+2 vs
  Session 19), 5 pre-existing `modPyramid` warnings, e2e files skipped.
  Commit `6049445d`.

### 2026-06-02 — Resolve the E2E test-infra debt: add `create_test_app()` with an opt-in gate (Session 19)

- **Root cause:** the 23 `test-app-*`/`test-e2e-*` files call
  `create_test_app()` at **154 sites**, but the helper was never defined
  (it never existed in git history; the e2e scaffolding landed in
  `7da01afe` without it). Result: **154 suite ERRORS** under
  `devtools::test()`/CI (`NOT_CRAN=true`), masked only by
  `skip_on_cran()` under a bare
  [`testthat::test_dir()`](https://testthat.r-lib.org/reference/test_dir.html)
  — a suite that was clean or broken depending on the runner.
- **Fix (strict TDD, RED→GREEN; no REFACTOR needed):** define
  `create_test_app()` in `tests/testthat/helper-shinytest2.R`. It
  **skips** the calling test unless `NPRC_RUN_E2E=true`, and when opted
  in returns the existing `inst/shinytest` app dir (`app.R` =
  `shinyApp(appUI(), appServer)`) for
  [`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html).
  The browser E2E suite stays **opt-in** (slow, needs Chrome, and
  depends on the modular-vs-monolith consolidation, XARCH-1) but is now
  one env var away from running; the default suite is honestly clean
  (154 errors → skips).
- **Discovery:** the prior E2E effort was ~90% complete, not lost
  scaffolding — the app is instrumented (`data-ready.js` + all six
  modules signal readiness), 159 `test_that` blocks + wait/upload
  helpers + `.github/workflows/shinytest2.yaml` CI all exist; only
  `create_test_app()` was missing. Captured the remaining campaign
  (validate the 159 tests; wire CI; sequence with XARCH-1) as **GitHub
  issue \#39** so the plan can’t be lost again.
- **Verification:** new browser-free
  `tests/testthat/test_create_test_app.R` (opt-in returns app dir; gate
  raises a `skip` condition). Full suite under `load_all` +
  `NOT_CRAN=true`: **0 failed / 0 error**, 154 e2e errors → skips, zero
  non-e2e offenders, 2047 passed, 5 pre-existing `modPyramid` warnings.
  Lint net-zero (helper-shinytest2.R = 0 in-place). No `document()`
  (test helper, not package API).
- Commits: `a1ee8497` (test: helper + tests), + this `docs:` close-out.

### 2026-06-01 — Document the Mendelian ½ factor; drop the dead UID.founders block (NEW-22/NEW-30, Session 18)

- **NEW-22 (Mendelian ½ “hardcoded in 5 places”):** Session 17’s
  NEW-13/NEW-23 consolidation already removed the
  `calcFE`/`calcFG`/`calcFEFG` triplication, so the remaining `/ 2L`
  sites are *distinct* Mendelian formulas (parental- contribution
  average, parental-kinship average, self-kinship `(1+f)/2`, founder
  self-kinship init), **not** duplicated logic. Per the package author’s
  decision the self-documenting literals are kept and a one-line
  Mendelian-½ comment is added at each site in
  `calcFounderContributions.R` and `kinship.R`; **no** named constant —
  one would over-couple distinct formulas across the GV compute and the
  kinship engine.
- **NEW-30 (dead/unused computed variables):** removed the
  genuinely-dead `## UID.founders <- …` commented block (and its
  `# nolint: commented_code_linter` wrapper) from
  `calcFounderContributions.R`. **Kept** `founderMatrix <- NULL` — it is
  an intentional memory free (drops the founders×founders identity block
  before the generation loop), not a dead variable as the audit claimed
  — now annotated.
- Comment + dead-code only; **zero behavior change**, proven
  byte-[`identical()`](https://rdrr.io/r/base/identical.html) on
  `calcFE`/`calcFG`/`calcFEFG` (character+factor),
  `calcFounderContributions` `$p` and `$ped`,
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  dense+sparse, and the full `set.seed(42)`
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  object. Full suite under `load_all`: 0 failed / 0 error, 2001 passed;
  lint net-zero on both files; `document()` produced no man/NAMESPACE
  change. No `NEWS.md` entry — the change is internal-only with no
  user-facing effect. Commit `04115d97`.

### 2026-06-01 — Consolidate calcFE/calcFG/calcFEFG founder-contribution code (NEW-13/NEW-23, Session 17)

- The founder-contribution algorithm that
  [`calcFE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md),
  [`calcFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md),
  and
  [`calcFEFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md)
  shared near-verbatim (~45 lines each), together with the triplicated
  Session-7 partial-parentage
  [`stop()`](https://rdrr.io/r/base/stop.html) guard, now lives once in
  a new `@noRd` helper `calcFounderContributions(ped, caller)` that
  returns `list(p, ped)`. The three functions become thin wrappers (net
  -118 lines).
- Behaviour-preserving with no public-API change: signatures, return
  types, and the per-function error messages are byte-identical, and
  [`calcFE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md)
  stays gene-drop-free. Proven
  [`identical()`](https://rdrr.io/r/base/identical.html) on FE/FG over
  lacy1989Ped (character AND factor), the full `set.seed(42)`
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  object (the live `calcFEFG` caller), and all three guard messages;
  independently re-verified by a 3-agent adversarial equivalence
  workflow (static body-diff, 20 empirical OLD-vs-NEW edge tests,
  contract/guard/namespace) with 0 divergences.
- Full suite under `load_all`: 0 failed / 0 error, 2001 passed (+10
  helper assertions). Lint net-zero; no man/NAMESPACE churn (`@noRd`).
- Out of scope (sibling audit items, not opted into): NEW-22 (hardcoded
  Mendelian 1/2), NEW-30 (dead vars - the `UID.founders` comment block
  was relocated intact), NEW-29/61 (founder-definition `^U` handling).
- Done under strict TDD (RED-\>GREEN-\>REFACTOR). Commits: `022afc8b`
  (helper + tests, GREEN), `2b27f4c3` (thin wrappers, REFACTOR), plus
  this close-out.

### 2026-06-01 — Extract getFounders()/isFounder() founder-detection helpers (PED-1/NEW-17, Session 16)

- Added two exported helper functions that define the founder predicate
  (an animal whose sire and dam are both unknown) in a single place:
  `isFounder(ped)` returns the logical mask
  `is.na(ped$sire) & is.na(ped$dam)`, and `getFounders(ped)` returns
  `ped$id[isFounder(ped)]`.
- Replaced the inline founder-detection idiom at 12 call sites across 9
  files:
  [`getFounders()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFounders.md)
  in
  [`calcFE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md),
  [`calcFEFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md),
  [`calcFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md),
  [`calcRetention()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcRetention.md),
  `orderReport()`, and
  [`removeUninformativeFounders()`](https://github.com/rmsharp/nprcgenekeepr/reference/removeUninformativeFounders.md);
  [`isFounder()`](https://github.com/rmsharp/nprcgenekeepr/reference/isFounder.md)
  for the founder-row subset in
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md),
  the male/female founder exports in `modSummaryStats` (×2), and the
  founder counts in `modORIPReporting` (×4).
  [`findPedigreeNumber()`](https://github.com/rmsharp/nprcgenekeepr/reference/findPedigreeNumber.md)
  was left as-is: it operates on bare `id`/`sire`/`dam` vectors with no
  `ped` object, so the `ped`-argument helpers do not fit it.
  [`calcRetention()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcRetention.md)’s
  adjacent `descendants` line was deliberately untouched — it alone
  filters by `ped$population`.
- Behaviour-preserving by construction and verified empirically: every
  refactored output proven
  [`identical()`](https://rdrr.io/r/base/identical.html) to a
  pre-refactor reference — the four `calc*` functions on the lacy1989
  fixture, the full seeded
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  output, and the Shiny-module expressions on the qcPed fixture. Full
  suite 0 failed / 0 error / 1991 passed; lint net-zero on all 11 files
  (the two new files and the seven compute files are lint-free; the two
  Shiny modules carry only pre-existing style debt, count unchanged
  between HEAD~1 and HEAD).
- An independent 4-angle completeness sweep (read-only workflow)
  re-derived the founder-detection inventory and converged on a single
  remaining inline site — `findPedigreeNumber.R:35`, the intentional
  exclusion — confirming no `R/` site was missed.
- Done under strict TDD (RED→GREEN→REFACTOR). Commits: `2758ffe6`
  (helpers + tests + NAMESPACE + man), `77f13d51` (calc\* +
  orderReport), `a95828d6` (reportGV + removeUninformativeFounders +
  Shiny modules), plus this close-out.

### 2026-06-01 — Fix lower-quartile mislabel + bind-once refactor in summarizeKinshipValues (NEW-16, Session 15)

- Fixed NEW-16:
  [`summarizeKinshipValues()`](https://github.com/rmsharp/nprcgenekeepr/reference/summarizeKinshipValues.md)
  reported the `secondQuartile` column as `fivenum()[1]` (the minimum)
  instead of `fivenum()[2]` (the lower hinge), so the lower-quartile
  column silently duplicated `min`. It affected 5 of 153 rows in the
  documented example pipeline. As with NEW-45, the audit’s mechanism and
  prescribed fix were both correct; the pre-existing test happened to
  pass on the buggy output (its row-10 lower hinge equals that row’s
  min), so a new synthetic test (`numbers = 1:5`, where the lower hinge
  2 ≠ the min 1) was added to detect the mislabel. Fixed by `tukeys[1L]`
  → `tukeys[2L]` (`R/summarizeKinshipValues.R:106`); `thirdQuartile`
  (the upper hinge) was already correct.
- Refactored the O(n²) `rbind`-in-loop into a preallocated row list
  bound once with `do.call(rbind, …)` (O(n)). Proven
  behaviour-preserving:
  [`identical()`](https://rdrr.io/r/base/identical.html) output on the
  seeded example pipeline, the synthetic input, and the
  all-skipped/empty case (which still returns an empty
  [`data.frame()`](https://rdrr.io/r/base/data.frame.html)).
- Decision (author): `R/makeGeneticDiversityDashboard.R` (NEW-20) is
  **retained** as early-development work rather than deleted. It is
  already excluded from the package build via `.Rbuildignore` and
  defines no live function, so NEW-20 is closed as won’t-delete (not the
  audit’s “delete dead code”). A whitespace-only comment realignment in
  that file was committed first (`926f4606`).

### 2026-06-01 — Reject duplicate animal IDs in geneDrop (NEW-46, Session 14)

- Fixed NEW-46:
  [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
  crashed with the cryptic base-R error “duplicate ‘row.names’ are not
  allowed” (at `rownames(ped) <- ids`, `geneDrop.R:97`) when given
  duplicate animal ids — before any allele logic ran. The audit’s
  “parent lookup by rowname; duplicate ids → wrong values” was
  empirically a hard crash, not silent corruption, and at the rownames
  assignment rather than the lookup (the NEW-48 pattern: audit mechanism
  wrong).
- Added an upfront guard (alongside the NEW-45 period guard) that
  rejects duplicate ids with a clear, actionable message (“animal IDs
  must be unique; duplicated id(s): …”), consistent with
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  (“All id values must be unique”) and
  [`removeDuplicates()`](https://github.com/rmsharp/nprcgenekeepr/reference/removeDuplicates.md).
  The unique-id invariant is a domain rule.
- Reachability was
  direct-[`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)-call
  only: the canonical `qcStudbook → reportGV → geneDrop` path is doubly
  masked —
  [`removeDuplicates()`](https://github.com/rmsharp/nprcgenekeepr/reference/removeDuplicates.md)
  (qcStudbook) and
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)’s
  own unique-id guard (called in `reportGV` before `geneDrop`). So no
  reportGV change was needed.
- Contract-preserving: today’s behavior is already a crash, so no
  currently-succeeding call changes — only the diagnostic improves
  (Learning \#8b).
- Strict TDD (RED→GREEN→REFACTOR). Full suite 0 failed / 0 error / 1971
  passed; lint net-zero; `man/geneDrop.Rd` regenerated; no NAMESPACE
  change.

### 2026-05-31 — Enforce “no period in IDs” rule (NEW-45, Session 13)

- Fixed NEW-45:
  [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
  silently corrupted allele assignment for any `id` containing a period
  (“.”) — it rebuilt the id/parent columns by splitting flattened
  data.frame rownames on “.”, so a period-bearing id was truncated and
  lost its sire/dam distinction. The documented ID domain forbids “.”
  (`inst/extdata/ui_guidance/input_format.html`: id/sire/dam are
  “Alphanumeric characters (no symbols)”).
- Enforced the rule rather than re-engineering `geneDrop` to support
  periods. New internal `hasInvalidIdChar()` defines the rule once and
  is used by:
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  (rejects period-bearing `id`/`sire`/`dam` at data input —
  [`stop()`](https://rdrr.io/r/base/stop.html) in default mode,
  `errorLst$invalidIdChars` when `reportErrors = TRUE`) and
  [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
  (defense-in-depth [`stop()`](https://rdrr.io/r/base/stop.html) for
  callers that bypass `qcStudbook`, e.g. the genetic-value Shiny
  module). Auto-generated IDs (`addUIds` `U####`, `obfuscateId`) are
  already period-free; locked with tests.
- Documented the feature with rationale (periods break across software
  environments) in roxygen, the live `input_format.html` spec, and
  `NEWS`.
- Strict TDD (RED→GREEN→REFACTOR). Full suite 0 failed / 0 error / 1961
  passed; lint 0. Code commit `5e228bd9` (fix) + docs commit.

### 2026-05-31 — Methodology framework update (Session 10)

- Updated the embedded methodology to canonical `rmsharp/methodology`
  `f32d780`: synced `SESSION_RUNNER.md`, `SAFEGUARDS.md`, and
  `methodology_dashboard.py` byte-identical to canonical via `bin/sync`.
- Refreshed `docs/methodology/` framework docs
  (`ITERATIVE_METHODOLOGY.md`, `HOW_TO_USE.md`, `README.md`) and
  workstreams; added 4 new upstream workstreams
  (`INHERITED_CODEBASE_FAMILIARIZATION_CAMPAIGN`,
  `RESEARCH_DOCUMENTATION_WORKSTREAM`,
  `RESEARCH_EXHAUSTIVE_VERIFICATION_CAMPAIGN`, `TEMPLATE_CAMPAIGN`).
- Relocated the 10 project Learnings (from `SESSION_RUNNER.md`) and the
  R-package build-equivalent (from `SAFEGUARDS.md`) into `CLAUDE.md`’s
  “Project-Specific Methodology Adaptations” and “Build / Test / Verify”
  sections, so the synced files stay byte-identical to canonical.
- Created `CHANGELOG.md`, `ROADMAP.md`, `RECOMMENDED_SKILLS.md`; split
  `BACKLOG.md` (completed work → here; feature inventory →
  `ROADMAP.md`).

### 2026-05-30 – 2026-05-31 — PED/GV audit-fix campaign (Sessions 1–9, strict TDD)

- **Audits produced:** `TECH_DEBT_AUDIT_2026-05-30.md` (Session 1,
  read-only) and `PED_GV_AUDIT_2026-05-30.md` (Session 2 — re-audit of
  the PED & GV clusters; 61 confirmed / 2 refuted findings).
- **Correctness bugs fixed** (each test-first under strict TDD, with
  regression tests):
  - NEW-15 — `countKinshipValues` wrong loop index corrupted accumulated
    kinship counts (the audit’s only HIGH-severity bug). `b05133ca`
  - NEW-34 — `getPotentialParents` unbound-`j` crash when `pUnknown` is
    empty. `dc695a3b`
  - NEW-40 — `findGeneration` returned silent NA generations on cyclic
    pedigrees; now warns at the choke point. `ea5d28fa`
  - NEW-37 — `correctParentSex` silently overwrote recorded H/U parent
    sex to M/F. `6b0ae333`
  - NEW-48 — `calcFEFG`/`calcFE`/`calcFG` crashed on partial parentage;
    now a clear [`stop()`](https://rdrr.io/r/base/stop.html). `19350559`
  - NEW-25 — `getProportionLow` crashed on empty input; now a clear
    [`stop()`](https://rdrr.io/r/base/stop.html). `587ba042`
  - NEW-52 — `cumulateSimKinships` standard deviation undefined for
    n\<2: n=1 → NA matrix + warning, n\<1 → clear
    [`stop()`](https://rdrr.io/r/base/stop.html). (Audit’s
    catastrophic-cancellation mechanism empirically disproved as
    unreachable for dyadic-rational kinship values.) `e3c7e8b3`

## Earlier work (pre-methodology, migrated from BACKLOG.md history)

- Pyramid plot module update.
- Lint cleanup and unused-code removal.
- Changed package name to mprcgenekeepr for side-by-side development.
- Initial Shiny module commit structure.
