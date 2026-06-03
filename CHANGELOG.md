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
