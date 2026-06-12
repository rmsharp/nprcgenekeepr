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

### 2026-06-12 — Verify and close issue #34 (`qcStudbook` already integrated in `modInput`) (Session 61)
- **Closed issue #34** ("Integrate qcStudbook() in modInput Shiny module", bug/high). The placeholder QC logic the issue describes (`# TODO: Replace with actual qcStudbook() call` + `results$cleaned <- rawData`) was already replaced by a real `qcStudbook()`/`runQcStudbook()` integration during the Shiny-module conversion (commit `7da01afe`, extended `c9019d51`/`bb7f2be6`); CHANGELOG's Session-20 entry already noted #34 as "stale (already integrated)" but the GitHub issue was never formally closed. This session verified the resolution firsthand and closed it with a resolution comment. **No code changed.**
- **TDD phase = N/A** (verify-and-close; no production code or tests written — same classification as the S57 close of #30).
- **What's wired:** `R/modInput.R:408` calls `qcStudbook(rawData, minParentAge, reportChanges=TRUE, reportErrors=TRUE)`; `:423` calls the two-pass wrapper `runQcStudbook()` (`R/runQcStudbook.R`); `R/processQcStudbookResult.R` shapes results for the UI; `minParentAge` is read from the UI input with safe coercion (`:398-404`); live path confirmed `appUI.R:123` (`modInputUI("dataInput")`) → `appServer.R:104` (`modInputServer`).
- **Verification (firsthand):** `test_qcStudbook.R` 38/0/0/0 + `test_modInput_qcStudbook.R` 90/0/0/0 (pass/fail/err/skip). The `shiny::testServer` module tests ran (**0 skips**; `shiny` installed), driving `modInputServer` and asserting the cleaned studbook carries the `gen` column that only `qcStudbook()` adds (`test_modInput_qcStudbook.R:296`) — that assertion would FAIL if the module were reverted to the placeholder, so the integration is regression-pinned. A 3-lens adversarial refute-the-close workflow (residual-placeholder/live-path ‖ functional-completeness ‖ test-authenticity) returned refuted=false / high confidence / 0 gaps on all three lenses.

### 2026-06-12 — `.Rbuildignore` excludes all non-shipping top-level dev/audit files — "non-standard top-level files" NOTE eliminated (Session 60)
- **Deliverable:** added `.Rbuildignore` patterns for the 8 currently-shipping non-standard top-level files so they are dropped from the build tarball, **eliminating** the R CMD check "non-standard files/directories found at top level" NOTE entirely — the built tarball's top level is now only the 5 standard files (`DESCRIPTION`, `NAMESPACE`, `NEWS.md`, `README.md`, `LICENSE`). Excluded: `20250504_cran-comments.md` (the 8th dated cran-comments file — its 7 siblings were already individually ignored), `methodology_dashboard.py`, `dashboard.html`, `nprcgenekeepr_notes.txt`, `RECOMMENDED_SKILLS.md`, `PED_GV_AUDIT_2026-05-30.{md,html}`, `TECH_DEBT_AUDIT_2026-05-30.md`. This is the deferred "scope-B" follow-up S58/S59 surfaced (a tarball-contents change, distinct from the pure dupe-guards of S58/S59).
- **Owner decisions (`AskUserQuestion`):** (1) scope = exclude **all 8** (none are package content) → eliminate the NOTE; (2) style = broad dupe-guarded + consolidate — the 7 dated `^YYYYMMDD_cran-comments\.md$` exact lines replaced by one `^[0-9]+_cran-comments\.md$` regex (covers 20250504 + any future dated file, so a new one never silently ships again), and the synced methodology/audit files use `<NAME>.*` forms (`^RECOMMENDED_SKILLS.*\.md$`, `^PED_GV_AUDIT.*`, `^TECH_DEBT_AUDIT.*`) that also catch macOS sync dupes; the non-synced files (`methodology_dashboard.py`, `dashboard.html`, `nprcgenekeepr_notes.txt`) use tight exact-match.
- **TDD phase = N/A** (build-config only; `.Rbuildignore` is dropped from the built tarball → no shippable `testthat` assertion; same rationale as S58/S59).
- **Verification (firsthand, authoritative at the build level):** staged 3 real spaced dupes (`RECOMMENDED_SKILLS 2.md`, `PED_GV_AUDIT_2026-05-30 2.md`, `TECH_DEBT_AUDIT_2026-05-30 2.md`), ran `R CMD build --no-build-vignettes --no-manual .` (RC=0 → no regex-comment abort); the resulting tarball's top level contained **exactly** the 5 standard files — none of the 8 excluded files and none of the 3 staged dupes (685 files, down from the 693-file baseline = the 8 removed). The "non-standard top-level files" NOTE is a pure function of the tarball's top-level entries, so this directly confirms the NOTE is gone (full `devtools::check()` not re-run — nothing affecting tests/examples/metadata changed; consistent with S58/S59). The complete 8-file set was enumerated by building the baseline tarball first (S59's candidate list named only 4 of the 8). Temp dupes + tarballs removed via `trap cleanup`; tree clean.

### 2026-06-12 — `.Rbuildignore` macOS-dupe guard generalized to the whole methodology `.md` cluster (Session 59)
- **Deliverable:** generalized Session 58's SESSION_NOTES dupe-guard to the rest of the top-level methodology/doc `.md` files. Broadened 7 exact-match `.Rbuildignore` patterns to the `<NAME>.*\.md$` form — `PROJECT_LEARNINGS`, `CLAUDE`, `SESSION_RUNNER`, `SAFEGUARDS`, `BACKLOG`, `ROADMAP`, `CHANGELOG` (`.Rbuildignore:78-85`) — so macOS file-sync duplicates (`CLAUDE 2.md`, `CHANGELOG copy.md`, …) of any of them are build-ignored and can never re-raise the R CMD check "non-portable file names" WARNING. After S58 only `SESSION_NOTES` was `.*`-guarded; this kills the dupe-WARNING class for the whole methodology cluster. (Owner decisions via `AskUserQuestion`: loose `.*` style to match the S58 line; scope limited to the already-ignored cluster — adding currently-unignored docs such as `RECOMMENDED_SKILLS.md` deferred as a separate tarball-contents change.)
- **TDD phase = N/A** (build-config only; same rationale as S58 — `.Rbuildignore` is dropped from the built tarball, so there is no shippable `testthat` assertion).
- **Verification (firsthand, both levels):** (1) regex probe across all 7 names — OLD exact patterns miss every dupe form (the leak); NEW `.*` form matches `<NAME> 2.md` and `<NAME> copy.md` while NOT over-matching `<NAME>.Rmd` / `<NAME>_archive.txt`, and canonical names stay excluded. (2) build-equivalent (authoritative) — staged 14 real spaced dupes (both forms × 7 names), ran `R CMD build --no-build-vignettes --no-manual` (RC=0); the resulting tarball (693 files) contained **zero** of the 7 names as `.md` → all dupes + canonicals excluded, real content (DESCRIPTION/NAMESPACE) present. Temp files + tarball removed via `trap cleanup`; tree clean.
- **In-flight finding (caught by the build step, not shipped):** `.Rbuildignore` lines are *all* perl regexes — including `#` comment lines (they simply match no real path). An initial multi-line comment with an unbalanced `(` made `R CMD build` abort with `invalid regular expression`; fixed to regex-safe comment lines, plus an inline NOTE warning future editors. (See PROJECT_LEARNINGS Learning 59.)

### 2026-06-12 — `.Rbuildignore` permanent macOS-dupe fix (Session 58)
- **Deliverable:** broadened `.Rbuildignore`'s `^SESSION_NOTES\.md$` → `^SESSION_NOTES.*\.md$` so macOS file-sync duplicates (`SESSION_NOTES 2.md`, `SESSION_NOTES 3.md`, `SESSION_NOTES copy.md`, …) are build-ignored and can never again re-enter the build tarball to re-raise the R CMD check "non-portable file names" WARNING that Session 57 had to clear by hand. This is the permanent fix S57 deferred (root cause: an exact-match build-ignore pattern doesn't cover the space-name); the prior `^\.Rhistory\ 2$` entry shows the same class was patched narrowly once before.
- **TDD phase = N/A** (build-config only; no R code, no shippable unit test — `.Rbuildignore` is dropped from the built tarball, so a `testthat` assertion on it can't run under R CMD check).
- **Verification (firsthand):** (1) regex probe — OLD pattern matches `SESSION_NOTES.md` only; NEW matches all dupe variants and over-matches nothing (`CHANGELOG.md`, `SESSION_NOTES_archive.txt` stay excluded; canonical `SESSION_NOTES.md` still excluded). (2) build-equivalent — staged a real `SESSION_NOTES 2.md`, ran `R CMD build` (RC=0); the resulting tarball contained **zero** SESSION_NOTES entries → the dupe is excluded and the WARNING cannot fire. Temp file + tarball removed; tree clean. (Full `devtools::check()` intentionally skipped — the WARNING is a pure function of tarball contents, verified directly.)

### 2026-06-12 — Close issue #30 + repo hygiene (Session 57)
- **Closed issue #30** ("work on use of lintr until satisfied with code style"). The plan deliverable (`docs/planning/issue30-lintr-exclusion-cleanup-plan.md`) is complete: `lintr::lint_package()` = **0** (re-verified firsthand this session), every `R/`-file `.lintr` line-specific exclusion removed except the deliberately-kept `makeGeneticDiversityDashboard` (author won't-delete, `.Rbuildignore`'d). The CI `lint` check is GREEN. Closed with a resolution comment summarizing Phases 1–4 (Sessions 53–56). Optional trivial follow-up noted on the issue: convert the lone remaining range-exclusion to an inline `# nolint start/end` block (plan §4C #16).
- **Repo hygiene:** removed the untracked macOS-duplicate `SESSION_NOTES 2.md` (563 KB, never committed, content fully contained in `SESSION_NOTES.md`). Its space-in-filename was the sole cause of the `devtools::check()` "portable file names" **WARNING** (`.Rbuildignore`'s `^SESSION_NOTES\.md$` exact-match does not cover the space-name, so the dupe entered the build tarball). **Verified firsthand:** post-removal `devtools::check()` = **0 errors / 0 warnings / 3 NOTEs** (was 1 WARNING at S56) → the WARNING is cleared. The 3 residual NOTEs are all pre-existing/environmental (clock-skew future-timestamps, spelling, and "non-standard top-level files" — the latter now lists only no-space methodology/audit files: `20250504_cran-comments.md`, `PED_GV_AUDIT_2026-05-30.{html,md}`, `RECOMMENDED_SKILLS.md`, `TECH_DEBT_AUDIT_2026-05-30.md`, `dashboard.html`, `methodology_dashboard.py`, `nprcgenekeepr_notes.txt`; the build-ignored `..Rcheck/` does not appear).

### 2026-06-12 — Issue #30 Phase 4: behavior-sensitive lint refactors + de-exclude (Session 56)
- **Deliverable:** implemented Phase 4 (the final exclusion-cleanup phase) of the issue #30 plan — the **6 behavior-sensitive `.lintr` line-exclusions** (5 §4B + the reclassified `checkRequiredCols`). After this, the **only** `R/`-file line exclusion left is `makeGeneticDiversityDashboard` (deliberately kept); `lintr::lint_package()` stays **0**.
- **`checkRequiredCols.R` (RED→GREEN→REFACTOR, commit `17e3fa06`):** `as.character(unlist(sapply(...)))` → `requiredCols[!requiredCols %in% cols]`. Owner-chosen robust contract: on out-of-contract `NA`-in-`cols` (reportErrors=TRUE) it now returns the missing cols cleanly instead of erroring (`"missing value where TRUE/FALSE needed"`); non-NA output byte-identical, `reportErrors=FALSE` untouched. Pinned by a RED NA-contract test; `@details` documents it.
- **4 behavior-none REFACTORs (commit `69c8d759`, all adversarially verified):** `correctParentSex.R` (if/else inverted to a guard clause; 6000-iter fuzz identical incl. error messages); `fillGroupMembersWithSexRatio.R` (`else { if }` → `else if`, inline `# nolint` deleted; 146 seeded cases identical); `setExit.R` (`mapply` → `unlist(Map(...))`, `chooseDate` always length-1; 21 inputs identical).
- **`addSexAndAgeToGroup.R` (adopted-robust REFACTOR, commit `69c8d759`):** `sapply` → `ped$sex[match(ids, ped$id)]`. Adversarial verification found that on **empty `ids`** the old `sapply` form dropped the `sex` column (2-col result), which **crashed** the one caller (`modBreedingGroups.R:438` `colnames(gp) <- c(<3 names>)`) on an empty group; the `match()` form returns the documented 3-column schema (sex an empty factor) and renders an empty table. Owner adopted the new behavior as intentional; pinned by an empty-ids contract test + a happy-path characterization test; `@details` documents it.
- **`create_wkbk.R` (accepted-divergence REFACTOR, commit `69c8d759`):** inner `if (replace)` → guard clause `if (!replace)`. Owner-accepted cosmetic divergence: on a non-logical non-coercible `replace` while the file exists, both versions error but the message text differs (`"argument is not interpretable as logical"` → `"invalid argument type"`); `replace` is documented logical, coercible values identical.
- **Verification:** `lint_package()` = 0; the 6 files lint-clean (`parse_settings=FALSE`); full suite **0 fail / 0 err / 159 skip** (S49 baseline + 5 new passing expectations from the contract/characterization tests → zero regression); `devtools::check()` **0 errors** (1 pre-existing-environmental WARNING + 2 NOTEs from stray top-level files incl. the macOS `SESSION_NOTES 2.md` dupe — not from this change); adversarial behavior-verification workflow `wf_168f8dcf-1e5` (6 skeptics, each told to refute). Phase-3E: `addSexAndAgeToGroup`'s runtime integration is covered by `test_modBreedingGroups.R:1015-1122` (the breeding-groups member view), green in the full suite.

### 2026-06-11 — Issue #30 Phase 3: behavior-none lint refactors + `.lintr` casing fix (Session 55)
- **Deliverable:** implemented Phase 3 of the issue #30 plan — **6 behavior-none lint refactors**, each removing its `.lintr` line-exclusion in the same change ([lint-net-zero]). `lintr::lint_package()` stays **0**.
- **Refactors (all adversarially verified behavior-preserving):** `convertFromCenter.R` + `fillGroupMembers.R` + `hasGenotype.R` (`unnecessary_nesting` collapses — drop an `else` after an unconditional `stop()`/`return()`; `else { if }` → `else if`); `getLkDirectAncestors.R` + `getLkDirectRelatives.R` (rename local var `source` → `msgSource`, which `undesirable_function_linter` flagged as shadowing `base::source`; also dropped 2 now-redundant inline nolints); `saveDataframesAsFiles.R` (`unnecessary_lambda` → `vapply(dfList, inherits, logical(1L), what = "data.frame")`).
- **`.lintr` casing bug fixed** (owner-flagged): `R/CheckRequiredCols.R` → `R/checkRequiredCols.R` — the capital-`C` entry matched nothing on case-sensitive CI, so the L34 lint would fire on the Linux `lint` runner.
- **`checkRequiredCols.R` (planned Phase 3 #1) reclassified to Phase 4:** adversarial verification + firsthand repro proved its `sapply`→`%in%` fix is NOT behavior-none — on out-of-contract `NA`-in-`cols` it turns a thrown error into a clean missing-columns return (exported fn). Owner-approved deferral (`AskUserQuestion`) to a RED→GREEN→REFACTOR slice in Phase 4; the file's code + `.lintr` entry left as-is (casing now correct).
- **Verification:** `lint_package()` = 0; the 6 files lint-clean (`parse_settings=FALSE`); full suite **2140 pass / 0 fail / 0 err / 159 skip** (= S49 baseline → zero regression); `devtools::check()` **0 errors** (1 pre-existing-environmental WARNING + NOTE from stray top-level files incl. a macOS `SESSION_NOTES 2.md` dupe — not from this change); `man/` untouched.

### 2026-06-11 — Implement issue #30: drive the R/ lint check to GREEN (Session 54)
- **Deliverable:** implemented the issue #30 cleanup plan; `lintr::lint_package()` now reports **0 lints** in
  `R/` (was 193 = 41 suppressed by `.lintr` line-excludes + 152 residual) → the CI `lint` check goes green.
- **Phase 1 (commit `74a46d4c`):** removed dead commented code in `getErrorTab.R`, `get_elapsed_time_str.R`,
  `print.summary.nprcgenekeeprErr.R`; stripped a stray `#'` in `set_seed.R` (also fixed a `#'` leak into
  `man/set_seed.Rd`); removed the 4 now-unneeded `.lintr` line exclusions + the dead
  `#commented_code_linter = NULL` no-op; kept `makeGeneticDiversityDashboard` (author won't-delete, NEW-20).
- **Residual (this commit):** fixed the 154 firing lints across 17 `R/` files + `inst/shinytest/app.R` via a
  per-file editor→adversarial-verifier workflow (one editor + one verifier per file; 150+ fixes, all 18 files
  verified behavior-preserved). **Owner decisions (`AskUserQuestion`):** (1) keep `implicit_integer_linter` ON
  and fix all 74 with `L` (counts/indices/widths) or `.0` (reals, e.g. `ped$age * 12.0`) — NOT disable;
  (2) targeted inline `# nolint` for the 16 verified false-positives / justified idioms. Mechanical fixes:
  `line_length` wraps, `brace`, `keyword_quote`, `return`, `paste(collapse=)`→`toString()`, `sapply`→`vapply`,
  `if`/`else if` chain → `switch()` in `logModuleEvent.R`; removed the stale `getPyramidPlot.R = 25:27` exclusion.
- **`# nolint` (verified non-bugs):** `object_usage` ×6 (package-internal `calcFounderContributions`/`gatedSeed`
  lintr can't resolve + `founderStats` which IS a `modSummaryStatsServer` formal), `nonportable_path` ×3
  (MIME strings), `object_name` ×2 (base-R `launch.browser` arg), `library()` ×2 (shinytest harness),
  `par()` ×3 (CRAN save/restore idiom).
- **Verification (firsthand):** `lint_package()` = 0; full test suite **2140 pass / 0 fail / 0 err / 159 skip**
  (S49 baseline held exactly — zero behavior regression); `document()` regenerated 3 man pages (roxygen reflow,
  content identical); **Phase-3E** — booted the app from `load_all` source: all 7 module UI builders constructed
  and `runModularApp` served HTTP 200 / 92 KB.
- Issue #30 remains OPEN pending owner confirmation to close (the `lint` check is now green).

### 2026-06-11 — Plan issue #30: resolve the `.lintr` line-specific exclusions (Session 53)
- **Deliverable (planning):** `docs/planning/issue30-lintr-exclusion-cleanup-plan.md` — an evidence-based plan to
  remove most of the 18 `"file" = line` entries in `.lintr`'s `exclusions: list()` by fixing the underlying lint,
  plus a strategy for the 152 residual lints. **No `R/`, `tests/`, or `.lintr` content changed** (plan only;
  implementation is the subsequent sessions, one phase at a time — FM #18/#25).
- **Evidence base:** firsthand `lint_package(parse_settings=FALSE)` (bypassing the exclusions so the suppressed
  lints are visible) = **41 lints suppressed by the 18 line-excludes + 152 residual = 193 total in `R/`**;
  cross-checked by an 18-file parallel examination workflow (`wf_c7863094-8f1`, one agent per file proposing the
  exact fix + risk rating) with adversarial verification of every behavior-affecting fix and commented-code
  deletion. **Three agent conclusions were corrected** by verification/reproduction (see plan §6).
- **Dispositions:** FIX 15 entries (~38 lints; 10 behavior-none, 5 low-risk verified-safe), KEEP-EXCLUDE 1
  (`makeGeneticDiversityDashboard.R` — author won't-delete, NEW-20), REMOVE-STALE + fix real lints 1
  (`getPyramidPlot.R = 25:27` suppressed 0 lints).
- **Config bugs found:** (1) `.lintr` lists `"R/CheckRequiredCols.R"` (wrong case) → the exclusion misses on
  case-sensitive CI; (2) the `getPyramidPlot.R = 25:27` exclusion is dead config; (3) the `source` "undesirable
  function" hits are a local variable named `source`, fixable by rename (zero behavior change); (4)
  `commented_code_linter` IS active via the tag set — the `#commented_code_linter = NULL` line is a dead no-op
  (resolves the issue #30 confusion).
- **Learning #53** (parse_settings=FALSE auditing trap; line-number drift both ways; verify-first over agent
  headlines). #30 stays OPEN (planning deliverable; implementation pending).

### 2026-06-11 — Fix issue #42: repoint pkgdown output off `docs/`; fix unmasked vignette bug; pkgdown GREEN on master (Session 52)
- **Deliverable (CI config + vignette fix / run-and-observe):** the `pkgdown` workflow failed its Build-site step on
  a fresh CI clone because `docs/methodology/` + `docs/planning/` are git-tracked inside pkgdown's default `docs/`
  output dir (no `pkgdown.yml` sentinel → `clean_site()` refuses to wipe a dir it didn't build → exit 1).
- **Fix = Option 2 (repoint pkgdown), not the issue's recommended Option 1 (relocate the doc trees).** Surfaced the
  choice via `AskUserQuestion`: Option 1 conflicts with the methodology framework's own `docs/methodology/`
  convention — the synced `methodology_dashboard.py` scores that path and the synced `SESSION_RUNNER.md`/
  `SAFEGUARDS.md` cross-link it (none durably editable in-repo). Verified from pkgdown 2.1.1 source + empirically
  that `build_site_github_pages()` overrides `_pkgdown.yml`'s `destination:` via `override = list(destination =
  dest_dir)`, so the yml alone is insufficient for CI. Commit `fcc154e8`: workflow `dest_dir = "pkgdown_site"` +
  deploy `folder: docs → pkgdown_site`; `_pkgdown.yml destination: pkgdown_site`; `.gitignore += pkgdown_site/`;
  `.Rbuildignore += ^pkgdown_site$`. No file moves; `docs/methodology`/`docs/planning`/dashboard/synced cross-refs
  untouched; gh-pages URL unchanged; no `R/` or `tests/` change.
- **Unmasked + fixed a separate latent bug** (commit `e89975c8`): with `clean_site` resolved, the build reached
  vignette rendering and failed on `ColonyManagerTutorial.Rmd` — its error table paired `names(getEmptyErrorLst())`
  (10 types) with 9 hardcoded descriptions ("arguments imply differing number of rows: 10, 9"). The NEW-45 "no
  period in IDs" feature added the `invalidIdChars` type without updating the vignette; added the missing
  description. This vignette is `.Rbuildignore`'d, so R CMD check never builds it — only pkgdown does (it ignores
  `.Rbuildignore`) — which is why it was green on all 5 R-CMD-check platforms yet fatal to pkgdown.
- **Validation (firsthand):** PR #43 pkgdown run `27361729368` (fresh-clone) SUCCESS → merged `--merge` to master
  `c6ad23dd` → master push run `27362288625` Build site **SUCCESS** + Deploy **SUCCESS**. **Closed issue #42.**
  Remaining CI red is lint (#30, known/accepted).

### 2026-06-11 — Promote `add-methodology` → master (PR #41) and live-validate `shinytest2`; close issue #40 (Session 51)
- **Deliverable (integration / run-and-observe):** promoted the long-lived `add-methodology` branch
  (105 commits / 356 files / +44,473−2,892; master a strict ancestor → 0 behind → clean conflict-free merge) to
  **master via PR #41** (merge commit `0363ffe3`, `--merge` to preserve the multi-session TDD history — never
  squashed). Pre-flight build-equivalent gate (non-e2e clean-regression read) = **2140 pass / 0 fail / 0 err /
  0 non-e2e offenders** (S49 baseline held); no branch protection on master.
- **Held the merge for the PR's first-ever remote CI**, triaging each red to root cause: **R-CMD-check passed on
  all 5 platforms** (macOS, Windows, ubuntu release/devel/oldrel-1) + test-coverage passed → package correctness
  intact; **pkgdown FAIL** = real but doc-site-deploy-only (`docs/methodology`+`docs/planning` tracked inside
  pkgdown's `docs/` output dir → `clean_site()` refuses to clean a non-pkgdown `docs/`) → logged as **issue #42**;
  **lint FAIL** = known style debt (#30); **codecov/patch+project FAIL** = external/advisory thresholds. Owner
  decision (`AskUserQuestion`): "merge now, fix pkgdown later".
- **Live validation (owner-designated gate):** `workflow_dispatch`-ed `shinytest2` on master → run `27356752221`
  **SUCCESS** (~19 min). All **13 per-module groups** (fresh `Rscript` each) reported `passed>0 failed=0 error=0`
  ("All 13 E2E module groups passed."). Both Session-34 live-runner watch items resolved on the first run:
  (1) renv lib-path resolution under `RENV_CONFIG_AUTOLOADER_ENABLED=false` (`R CMD INSTALL` + every AppDriver
  subprocess booted the app); (2) the 23-in-one-process Chrome flake — the 8e-7 per-module fresh-process grouping
  produced ZERO transient errors (first environmental confirmation; per-group isolation contains any future
  transient).
- **Closed issue #40** ("Strengthen shinytest2 E2E assertions") with a full validation comment — the §8e
  assertion-strengthening + CI-stability campaign is code-complete and live-validated on master.
- **Follow-ups logged (not done this session):** **#42** (relocate methodology docs out of pkgdown's `docs/`),
  **#30** (lintr cleanup) — both independent of package correctness.

### 2026-06-10 — Phase 8e-7 (CI per-module fresh-process grouping): run the 23-file shinytest2 E2E tier in 13 per-module groups, each in a fresh R process, to defang the 23-in-one-process Chrome flake (issue #40, Session 50)
- **Deliverable (CI config / run-and-observe):** plan slice **8e-7**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §8/§8e-7 — the FINAL §8e slice) — replaced the
  single `test_dir(filter = "^(app|e2e)-", stop_on_failure = TRUE)` run step in
  `.github/workflows/shinytest2.yaml` with a **single job that loops over 13 per-module group regexes, each run
  in a fresh `Rscript` process**, so no one process accumulates 23 Chrome/AppDriver instances (the S34
  "process-count dragon": ~1 transient error / 5 full-tier single-process runs). Caps any process at ≤3 files.
- **Per group:** `test_dir(filter = rx, stop_on_failure = FALSE)` → a `passed/failed/skipped/error` report →
  fail/error > 0 ⇒ `quit(status = 1)` (checked FIRST, so a real failure is never mislabeled) → passed == 0 ⇒
  `stop()` **per-group silent-skip guard** (stronger than the old whole-run guard; a zero-match regex is caught
  separately by `test_dir`'s own "No test files found" abort). The bash loop runs ALL groups (full signal, one
  flake doesn't skip the rest) and reds the job if ANY group failed — preserving `stop_on_failure` semantics +
  the job env / Chrome provisioning / `R CMD INSTALL` / `timeout-minutes: 30` / removed `continue-on-error` (R6).
- **Owner-gated topology** (`AskUserQuestion`): single-job loop chosen over a 13-leg `strategy.matrix` (cheapest,
  plan-faithful, root-cause-sufficient — the matrix's 13× setup wasn't worth it for a nightly job). TDD =
  run-and-observe (CI config; no RED→GREEN, plan §6), gated `PRE-RED→run-and-observe`.
- **Verified locally:** the COMMITTED 13-regex partition selects EXACTLY the 23 `^(app|e2e)-` files — union ==
  tier, no overlap / gap / stray — against the full 182-file dir (replicating testthat's stripped-name match,
  Learning #33c); YAML parses (`yaml.safe_load`); run-step `bash -n` clean; the `Rscript -e '...'` block is
  single-quote-free; the run-step logic smoked on a throwaway dir (pass→exit 0, fail→exit 1, skip / nomatch →
  nonzero) — all four branches.
- **⚠ Live-runner-only (FM #24's cousin):** the flake mitigation is environmental — the partition / guard / exit
  logic is proven locally, but the 23-in-one-process flake can only be confirmed gone on the first live GitHub
  run (which requires the workflow on `master`). Ships UNVALIDATED locally; not claimed fixed until a live run
  shows it. Pushing `add-methodology` → master remains a SEPARATE deliverable.
- **Scope:** CI-config only (no `R/` / `tests/` change → the test suite is byte-identical). CHANGELOG-only (no
  package/source change).

### 2026-06-10 — Phase 8e-6c (real breeding-group flow): the 3 export-NULL'd Breeding-Groups E2E blocks become genuine data-bearing assertions → 8e-6 COMPLETE (issue #40, Session 49)
- **Deliverable (implementation):** plan slice **8e-6c**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §5/§8e-6) — the **third and final vertical
  8e-6 flow**, completing the triad (pedigree ✓8e-6a, GVA ✓8e-6b, breeding ✓8e-6c). Drives the real
  breeding pipeline opt-in: `upload_and_wait(app, obfuscated_rhesus_mhc_ped.csv)` →
  `navigate_to_tab("Breeding Groups")` → `set_inputs(animalSource = "all", nIterations = 5)` →
  `click_element_safe("#breedingGroups-formGroups")` → `wait_for_module_ready("breedingGroups")` →
  `click_element_safe("a[data-value='Group Detail']")`, then asserts the rendered Group-Detail export
  buttons + DTs. Revives the 3 export-NULL'd Breeding-Groups blocks from Session 43 (D5
  `test-e2e-breeding-groups-detailed.R:89` export functionality, T7 `-tutorial.R:135` group export
  options, T9 `-tutorial.R:178` kinship-matrix export per group) from pane-active-only into data-bearing
  checks. Scope fixed by the owner's "8e-6c" instruction; full **RED→GREEN** (3 `AskUserQuestion` phase
  gates), REFACTOR declined (precedent + the GVA and breeding run-flows diverge on the nested-tab
  activation, so a "shared" run-flow helper is messier than a clean abstraction).
- **Hard gate first (the breeding spike):** a live-browser spike captured the recon's two open items
  firsthand before any RED. The Group-Detail nested `tabsetPanel` (`modBreedingGroups.R:72`) has **no
  `id`**, so it cannot be driven by `set_inputs` — it is activated via the unique DOM link
  `a[data-value='Group Detail']` (spike: `count == 1`). The spike proved both steps are required:
  post-formation but pre-activation, the export labels and rendered tables are still absent (the nested
  pane is `display:none`); only after the tab click do they enter the top-level active pane's innerText.
  `animalSource = "all"` uses `ped$id` directly, isolating breeding from the GVA dependency (the
  `topRanked` branch's `req(geneticValues())`, `appServer.R:272`).
- **Assertions (mutation-proven discriminating, RNG/seed-independent):** a static-UI download button is
  made data-bearing by PAIRING its visibility-gated label (matched via active-pane innerText, absent
  until the nested tab is activated) with a `suspendWhenHidden` rendered DT (which needs both group
  formation AND tab visibility). D5: `"Export Current Group"` + `grepl("Ego ID",` rendered
  `#breedingGroups-groupMemberTable)`. T7: `"Export Current Group"` + `"Age in Years"` member-table
  header. T9: `"Export Current Group Kinship Matrix"` + `grepl("<table",` rendered
  `#breedingGroups-groupKinTable)`. All tokens are static labels / rendered column-headers / table
  structure → verified GREEN with **no `NPRC_BG_SEED`** set. Group count and the within-group kinship
  invariant are deliberately NOT asserted (the algorithm formed one large MIS group from `numGp = 3`,
  and the strict kinship bound is unattainable because the module hardcodes `ignore = F–F`).
- **Verification:** D5/T7/T9 all GREEN live (`test-e2e-breeding-groups-detailed.R` 8/0/0,
  `test-e2e-breeding-groups-tutorial.R` 11/0/0); **[mutation-check] 13/13 all pass** (correct tokens →
  TRUE; wrong export label + imaginary column + right-token-wrong-table `"Ego ID"`-in-kin → FALSE;
  foreign pane (Pedigree Browser) → FALSE; pre-flow RED re-confirmed → FALSE). Non-e2e regression **2140
  `expectation_success` / 0 failed / 0 error / 159 skipped / 5 pre-existing `modPyramid` warnings / 0
  non-e2e offenders**, proven byte-identical with and without the edit via a `git stash` diff (the edit
  touches only e2e blocks, which skip at `create_test_app()` before any assertion). The 2140-vs-Session-48's-2180
  figure is a measurement-method difference (`pkgload::load_all` under renv vs the bare system lib's
  missing Suggests deps), not a regression. Phase-3E = the live GREEN AppDriver runs (the real
  upload→QC→kinship→group-formation→Group-Detail render) + the mutation spike ARE the runtime check
  (#31). Test-tree-only → no `document()`/NEWS; `tests/` lint-exempt.

### 2026-06-10 — Phase 8e-6b (real GVA-run flow): the 2 NULL'd Genetic-Value E2E blocks become genuine data-bearing assertions (issue #40, Session 48)
- **Deliverable (implementation):** plan slice **8e-6b**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §5/§8e-6) — the **second of three vertical
  8e-6 flows** (upload+QC ⊂ GVA ⊂ breeding). Drives the real Genetic Value Analysis pipeline opt-in:
  `upload_and_wait(app, obfuscated_rhesus_mhc_ped.csv)` → `navigate_to_tab("Genetic Value Analysis")` →
  set `nIterations = 100` (minimum allowed, for speed) → `click_element_safe("#geneticValue-runAnalysis")`
  → `wait_for_module_ready("geneticValue")`, then asserts the **rendered `#geneticValue-rankingsTable`**
  DOM. Revives the 2 NULL'd Genetic-Value blocks from Session 42 (B1
  `test-e2e-genetic-value-tutorial.R:99` Value Designation, B2 `:144` Z-score) from pane-active-only into
  data-bearing checks. Scope fixed by the owner's "8e-6b" instruction; full **RED→GREEN** (3
  `AskUserQuestion` phase gates), REFACTOR declined (a reusable GVA-run helper should co-design with
  8e-6c).
- **Hard gate first (the GVA spike):** a live-browser spike settled the rendered-table facts before any
  RED, correcting a static-read trap: `reportGV.R:144` `cbind(demographics, indivMeanKin, zScores, gu,
  offspring)` shows no `value` column, but `reportGV.R:146` wraps it as `orderReport(finalData, ped)`,
  which splits the frame → `rankSubjects()` adds the `value` ("High/Low/Undetermined") + `rank` columns →
  `rbind` re-flattens, so the rendered DT carries both `value` and `zScores`. The spike confirmed the
  default `topN = 20` view (`modGeneticValue.R:240`) truncates to the top-ranked (best) rows, which are
  **all "High Value"** — "Low Value"/"Undetermined" are truncated away, so the only faithful
  Value-designation token in the default render is `"High Value"`.
- **Assertions (mutation-proven discriminating, RNG/seed-independent):** B1 `"High Value"` (the Value
  designation rendered for the top-ranked rows); B2 `"zScores"` (the z-score DT column header). Both are
  structural invariants (a fixed column header; a designation guaranteed for the top rows) — verified by
  running GREEN with **no `NPRC_GVA_SEED`** set, so neither the 8e-5 seed hook nor value-stable RNG is
  required.
- **Verification:** 8/8 blocks GREEN in `test-e2e-genetic-value-tutorial.R` (the 6 static-UI blocks
  unaffected); **[mutation-check] all pass** (correct `"High Value"`/`"zScores"` → TRUE; wrong
  designation `"Low Value"`/`"Undetermined"` → FALSE; foreign-pane `"Form Groups"` (Breeding Groups) /
  `"Focal Animals"` (Pedigree) → FALSE; RED re-confirmed pre-run → both FALSE). Non-e2e regression
  **2180 `expectation_success` / 0 failed / 0 error / 156 skipped / 5 pre-existing `modPyramid`
  warnings / 0 non-e2e offenders** — Session 47 baseline held exactly (test-only change; the e2e file
  self-skips without `NPRC_RUN_E2E`). Phase-3E = the live GREEN AppDriver run (the real upload→QC→GVA
  pipeline) + the mutation spike ARE the runtime check (#31). Test-tree-only → no `document()`/NEWS;
  `tests/` lint-exempt.
- **Lib currency:** the AppDriver subprocess resolves the package from the SYSTEM lib
  (`/Library/Frameworks/.../R-4.5/...`) under `RENV_CONFIG_AUTOLOADER_ENABLED=false`; that install was
  already current (`gatedSeed` present, v1.1.0.9000) because `R/` was unchanged since Session 47's
  reinstall → no reinstall needed this session (verified currency firsthand; did not assume).

### 2026-06-10 — Phase 8e-6a (real upload+QC → pedigree-table flow): the 3 NULL'd pedigree E2E blocks become genuine data-bearing assertions (issue #40, Session 47)
- **Deliverable (implementation):** plan slice **8e-6a**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §5/§8e-6) — the **first of three vertical
  8e-6 flows** (upload+QC ⊂ GVA ⊂ breeding). Drives the real pipeline opt-in for the first time in the
  E2E suite: `upload_and_wait(app, obfuscated_rhesus_mhc_ped.csv)` → `#dataInput-getData` →
  `navigate_to_tab("Pedigree Browser")`, then asserts the **rendered `#pedigree-pedigreeTable`** DOM.
  Revives the 3 NULL'd pedigree blocks from Session 40 (A1 `test-e2e-pedigree-module.R`, A2
  `-detailed.R`, A3 `-tutorial.R`) from pane-active-only into data-bearing checks. Owner-gated scope
  (8e-6a only); full **RED→GREEN** (4 `AskUserQuestion` gates), REFACTOR declined (idiomatic 3-line
  driver, no helper).
- **Hard gate first (the 8e-6 spike):** a live-browser spike settled the recon critic's blockers
  before any RED — (G4) the default `pedFile`/`pedigreeFileOne` upload flips `dataInput` ready and QC
  runs clean; (G5) the pedigree output is `suspendWhenHidden` (NULL until the Pedigree Browser tab is
  active, then renders all 375 rows — so the driver must `navigate` AFTER upload); (G2)
  `get_value(output="pedigree-pedigreeTable")` is a `json`-class string that **un-suspends to non-NULL
  even without data**, so the genuine data discriminator is the rendered-DOM content via
  `get_html_safe(app, "#pedigree-pedigreeTable")` — a refinement of the plan's §2.3 "output tier".
- **Assertions (all mutation-proven discriminating):** A1 `"of 375 entries"` (row count) + `"sire"`
  column; A2 + `"dam"` column; A3 `"dataTables_length"` (the "Show N entries" length menu) +
  `"of 375 entries"`. A4 ("status filter") left honest pane-active — no filter control exists (the
  table does render a `recordStatus` column, a future data-bearing option).
- **Fixture:** `inst/extdata/obfuscated_rhesus_mhc_ped.csv` (375 rows, canonical CSV; recon-verified to
  flow clean QC→GVA→breeding and already asserted error-free through the real `modInputServer`).
- **Verification:** 3/3 files GREEN (module 6/6, detailed 8/8, tutorial 9/9); **[mutation-check] all
  pass** (correct content TRUE; wrong row-counts 999/374, foreign column `genotype`, foreign-pane
  `Breeding Groups`, and the same pattern on a different element → all FALSE). Non-e2e regression
  **2180 `expectation_success` / 0 failed / 0 error / 156 skipped / 5 pre-existing `modPyramid`
  warnings / 0 non-e2e offenders** — Session 46 baseline held exactly (test-only change; the e2e files
  self-skip without `NPRC_RUN_E2E`). Phase-3E = the live GREEN AppDriver run (the real
  upload→QC→pedigree-render pipeline) + a mutation-check spike. Test-tree-only → no
  `document()`/NEWS; `tests/` is lint-exempt.
- **Environment note:** the AppDriver subprocess resolves `nprcgenekeepr` from the **system library**
  (`/Library/Frameworks/...`), not the renv cache, under `RENV_CONFIG_AUTOLOADER_ENABLED=false`;
  current source was reinstalled there first (the prior system-lib install was from Jul 2025).
- **Scope boundary:** GVA (8e-6b) and breeding-group (8e-6c) flows + their deferred blocks (2 GV from
  S42, 3 BG from S43) are deliberately deferred to their own sessions (FM #18/#25). `add-methodology`
  still not on remote.

### 2026-06-10 — Phase 8e-5 (Stochastic determinism hook): env/option-gated `set_seed()` in the GVA + breeding-group module servers — the FIRST 8e PRODUCTION `R/` change (issue #40, Session 46)
- **Deliverable (implementation):** plan slice **8e-5**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §7) — the **only 8e slice that edits
  production `R/`** (`modGeneticValueServer` + `modBreedingGroupsServer`, both exported). Adds an
  **env/option-gated `set_seed()` hook** (Option A) so the stochastic GVA / breeding-group engines
  can be made reproducible on demand for E2E exact-value assertions, while the **default path is
  provably unchanged** (gate unset ⇒ no-op). Owner-gated (`AskUserQuestion` go/no-go chose Option A
  over Option B's user-facing UI seed input and Option C-only's no-production-change invariants),
  then full **RED→GREEN→REFACTOR**, every transition gated.
- **The gate (Option A):** at the top of each `eventReactive` body, immediately after `req()` and
  ahead of `withProgress` (so nothing between the seed and the engine consumes RNG):
  `seed <- getOption("nprcgenekeepr.gva_seed", as.integer(Sys.getenv("NPRC_GVA_SEED", NA)));
  if (!is.na(seed)) set_seed(seed)` — `modGeneticValue.R` ahead of `reportGV()` (gene-drop `sample`),
  `modBreedingGroups.R` ahead of `groupAddAssign()` (MIS `sample`), with
  `nprcgenekeepr.bg_seed` / `NPRC_BG_SEED`. Uses the existing **exported `set_seed()`** (pins
  `sample.kind="Rounding"`). Option precedence over the env-var fallback; both unset ⇒ `NA` ⇒ no seed.
- **REFACTOR:** the duplicated 3-line gate factored into one internal `@noRd` helper
  `gatedSeed(optionName, envName)` in `R/set_seed.R`; both module call sites now call it. Structure
  only — no behavior change, no new tests (the 8 tests validate the refactored helper via the
  `set_seed` mock + determinism). `gatedSeed` is `@noRd` ⇒ **no NAMESPACE / man delta**.
- **Tests (8 new, browser-free `testServer`; 3 RED + 1 guard per module):** determinism — with the
  option set, two `gvResults()` / `groups()` runs are `identical` (RED at HEAD: unseeded runs differ
  because RNG state carries across `testServer` invocations; a `length(.) > 0` assertion proves the
  capture is non-vacuous); `set_seed` mock — called once with the seed when the option is set (RED at
  HEAD: never called); env-var fallback — `NPRC_GVA_SEED` / `NPRC_BG_SEED` read when the option is
  absent (RED at HEAD); and the default-path **guard** — neither option nor env set ⇒ `set_seed` not
  called (green-on-arrival). RED confirmed firsthand (6 genuine failures + 2 guards passing) before
  GREEN; no synthetic RED.
- **Enabling baseline commit (separate, `d0989408`):** committed the owner's concurrent 14-file `R/`
  + `test_modPyramid.R` automated formatter pass (integer literals, quote style) on owner request, to
  give 8e-5 a clean baseline; re-verified behaviorally inert (regression held at 2166). A follow-on
  `docs:` commit regenerated 3 man pages (`appServer`, `modSummaryStatsServer`, `savePlotToFile`) the
  reformat desynced — the formatter had also rewrapped `#'` roxygen comments and changed
  `savePlotToFile`'s defaults to integer (`width=8L`), which would have tripped `R CMD check` codoc.
- **Verify:** non-e2e regression **2180 `expectation_success` / 0 failed / 0 error / 156 skip /
  5 pre-existing `modPyramid` warnings / 0 non-e2e offenders** (= the 2166 baseline + 14 new
  expectations; default analytical path unchanged — every existing test passes with the gate unset).
  **`devtools::check()` = 0 errors / 0 warnings / 3 NOTEs** (all pre-existing or environmental: the
  stale `spelling.Rout.save` baseline, "future file timestamps", non-standard top-level dev files —
  the S35 baseline; no new `gatedSeed` "no visible global" NOTE, confirming the lintr single-file
  flag is a stale-namespace artifact resolved by full-package analysis). Phase-3E runtime smoke:
  `runModularApp()` (working-tree source via `load_all`, so the hook is active) serves **HTTP 200** on
  the default gate-unset path. Lint net-zero on the changed `R/`.
- **Scope / docs:** the default analytical numerics are unchanged (gate is a no-op by default) →
  **CHANGELOG only, no `NEWS.md` bullet** (consistent with the modular-parity precedent). 8e-5
  enables the *optional exact-value* assertion tier in 8e-6 but does not block it (8e-6 can use
  Option-C structural invariants regardless).

### 2026-06-10 — Phase 8e-4 (Error-States + Boundary-Conditions): namespace fix + interaction revival; boot tautologies → behavioral active-pane assertions (issue #40, Session 45)
- **Deliverable (implementation):** plan slice **8e-4**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §5) — the FIRST 8e slice that is
  **not pure run-and-observe**: a HYBRID of **RED→GREEN** (the `input-`→`dataInput-` namespace fix)
  and **run-and-observe** (the assertion conversions). Two files: `test-e2e-error-states.R` (13) +
  `test-e2e-boundary-conditions.R` (13) = **26** browser-booting `test_that` blocks, plus the
  `upload_and_wait` helper + its browser-free unit tests.
- **Namespace fix (§2.4, RED→GREEN, 5 sites):** the input module is mounted under the **`dataInput`**
  namespace (`appUI.R:123` `modInputUI("dataInput")`); `data-module="input"` (`modInput.R:31`) is a
  label, not the namespace. Fixed: `helper-shinytest2.R` `upload_and_wait` default `module_id`
  `"input"`→`"dataInput"` + the hardcoded `input-pedigreeFileOne` now DERIVED from
  `module_id`/`file_input_id` via `do.call`; `error-states` `#input-getData`→`#dataInput-getData`
  and `input-minParentAge`→`dataInput-minParentAge`; `boundary` `input-minParentAge`→
  `dataInput-minParentAge`. A new browser-free recording-stub unit test in
  `test_helper_shinytest2.R` anchors the helper fix in the always-run layer (+4 expectations).
- **Discriminators (firsthand-spiked):** for a namespaced **textInput** the wrong-id discriminator is
  the **value read-back** — shinytest2 `set_inputs` on an unbound id WARNS and never sets (it does
  NOT throw), so `get_value("dataInput-minParentAge")` stays at the default with the wrong id; for the
  **actionButton** it is the `app$click` **throw** (→ `click_element_safe`→FALSE). A no-file
  `getData` click surfaces the transient `showNotification("Please select a file first.")` warning,
  asserted via `#shiny-notification-panel`.
- **Conversions (23, run-and-observe):** the `nchar(html)>100` near-tautologies + dead-grepl +
  `interaction-noop-tryCatch` blocks now call `assert_active_pane(app, <pane>, <static-label>)` —
  Input/Pedigree/Pyramid/GV/BG control labels confirmed against the real active-pane innerText. The
  rapid-switch / repeat-click blocks assert the final pane (Home / Input); the narrow/short-window
  blocks assert Home active on boot. **Zero blocks deferred to 8e-6** (all static-pane assertions are
  available pre-data).
- **Verification:** helper unit tests **63/0/0** (the 2 new `upload_and_wait` tests green); e2e
  error+boundary browser run **26 blocks / 29 expectations GREEN, 0 failed / 0 error / 0 skip**
  (`filter="^e2e-(error|boundary)"`, `NPRC_RUN_E2E=true NOT_CRAN=true`). **[mutation-check] PASS**
  (correct GV pane→TRUE; wrong-pane / foreign-content "Number of groups"→FALSE; OLD whole-body
  grepl→TRUE content-blind contrast; namespace read-back + notification + wrong-selector→FALSE).
  Non-e2e regression **2166 `expectation_success` / 0 failed / 0 error / 156 skip / 5 pre-existing
  `modPyramid` warn / 0 non-e2e offenders** — S40–S44 baseline + exactly the +4 new helper
  expectations. Phase-3E satisfied (the live browser run + 2 spikes ARE the runtime, #31).
- **⚠ Concurrent formatter (not part of this deliverable):** at session start the tree was clean;
  mid-session an external automated style pass (`'…'`→`"…"`, `0`→`0L`) rewrote **14 `R/` production
  files** and briefly broke 2 (`makeFounderStatsTable.R:68`, `makeGeneticSummaryTable.R:58` — inner
  HTML quotes unescaped). Per SAFEGUARDS / FM #22 those unauthored uncommitted edits were NOT touched;
  the formatter self-healed both files and settled, and the regression confirmed the reformat is
  behaviorally inert. The 8e-4 commit stages ONLY the test-tree files + docs via explicit `git add`,
  leaving the owner's reformat as their in-progress work.
- **Scope:** test-tree-only (2 e2e files + helper + helper unit test) → no `document()`/NEWS;
  `tests/` is `.lintr`-excluded. Strict TDD, gated `PRE-RED→RED` then `RED→GREEN` via `AskUserQuestion`.

### 2026-06-09 — Phase 8e-3 FINAL (Settings-About + Workflow-Integration): boot-level tautologies → behavioral active-pane assertions; navbarMenu finalized (issue #40, Session 44)
- **Deliverable (implementation):** the **LAST two 8e-3 files** of plan slice 8e-3
  (`docs/planning/phase8e-assertion-strengthening-subplan.md`) —
  `test-e2e-settings-about.R` (4) + `test-e2e-workflow-integration.R` (7) = **11 browser-booting
  `test_that` blocks**. Converts the content-blind `navigate_to_tab → grepl(get_html_safe(app,"body"))`
  idiom to behavioral `assert_active_pane(...)`. **8e-3 is now COMPLETE** (genetic-value S42 +
  breeding-groups S43 + settings-about/workflow S44).
- **Dragon resolved firsthand (R1 / §2.3 item 4, carried as a 🐉 by S42/S43):** a live-DOM spike
  (Rscript→AppDriver) confirmed a `navbarMenu("More")` child **becomes the lone active top-level
  `.tab-pane`** via `set_inputs(mainNavbar=child)` — top-level `.tab-content` count == 1,
  `get_active_pane_value`/innerText == the child (Settings/About/Help) content. So
  `navigate_to_menu_item`'s delegate body was already a genuine visible-pane switch; **only its
  docstring's shallow-coverage caveat needed retiring** (`helper-shinytest2.R:283-292`, body
  unchanged) → PURE run-and-observe, not a helper RED→GREEN.
- **Strict TDD — PURE run-and-observe** (no defect; all panes already render) → green-on-arrival
  `[refactor-only]` conversion, gated `PRE-RED→run-and-observe` via `AskUserQuestion`; rigor from a
  `[mutation-check]` (no synthetic RED).
- **Conversion map — 10 keep-regex-rescope · 1 navbar-chrome carve-out:**
  - **settings-about (4): all genuine grepl → keep verbatim, rescope to the navbarMenu child pane** —
    S1 `(Settings,"Settings|Configuration|options")`, S2 `(About,"About|Version|GeneKeepR|Oregon|Primate")`,
    S3 `(Help,"Help|Documentation|Online")`, S4 `(About,"NIH|funded|grant")`.
  - **workflow-integration (7):** W1 "visits N tabs" loop → 6 per-pane `assert_active_pane` checks with
    the threshold raised `>= 3` → `== 6L` (so a single failed nav reds the block); W2/W3 `is.list()`
    responsiveness tautologies → genuine pane-switch asserts (Input-then-Home; final-pane after a
    4-switch loop); W4 navbar brand → **CARVE-OUT** scoped to `.navbar-brand`
    (`grepl("GeneKeepR", get_html_safe(app, ".navbar-brand"))` — strictly stronger than the old
    whole-body grepl, since the brand lives outside any pane); W5 `(Input,"upload|file|browse")`,
    W6 `(Genetic Value Analysis,"Genetic|Value|Analysis|kinship|population")`,
    W7 `(Breeding Groups,"Breeding|Groups|formation|animals")`.
- **Helper:** `navigate_to_menu_item` docstring finalized (records the 8e-3 navbarMenu confirmation;
  no body change).
- **Verification:** browser run **11/11 GREEN / 12 expectations** (net-0 swap), 0 error / 0 skip
  (`filter="^e2e-(settings|workflow)"`). `[mutation-check]` PASS — settings-about arms via the spike
  (wrong-pane→FALSE, wrong-content→FALSE); workflow arms: W1 wrong-pane→FALSE (count would miss 6L),
  W4 scoped `grepl("Breeding", brand)`→FALSE while old whole-body `grepl("Breeding", body)`→TRUE
  (proves the old check was content-blind). Non-e2e regression **2162 `expectation_success` / 0 failed
  / 0 error / 156 skipped / 5 pre-existing `modPyramid` warnings / 0 non-e2e offenders** — S40–S43
  baseline held EXACTLY (read via `expectation_success`, not `sum(nb)`, per Learning #43e). Phase-3E:
  the live browser run + two DOM spikes + the mutation-check spike ARE the runtime (#31 pattern).
- **Scope:** test-tree only (3 files: 2 test files + a test-helper docstring); `tests/` `.lintr`-excluded
  → lint-exempt; no `R/` change → no `document()`/NEWS (CHANGELOG only). Next: **8e-4** (namespace
  `input-`→`dataInput-` fix + error-states/boundary interaction revival), a separate session.
- See `PROJECT_LEARNINGS.md` Learning #44 for the full per-block detail and the navbarMenu/brand/threshold findings.

### 2026-06-09 — Phase 8e-3 part B-2 (Breeding-Groups family): boot-level tautologies → behavioral active-pane assertions (issue #40, Session 43)
- **Deliverable (implementation):** the **Breeding-Groups family** of plan slice 8e-3
  (`docs/planning/phase8e-assertion-strengthening-subplan.md`) — `test-e2e-breeding-groups-module.R` (7),
  `test-e2e-breeding-groups-detailed.R` (7), `test-e2e-breeding-groups-tutorial.R` (9) = **23 browser-booting
  `test_that` blocks**. All converted from the content-blind `navigate_to_tab → grepl(get_html_safe(app,
  "body"))` idiom to `assert_active_pane(app, "Breeding Groups", <pattern>)`. The 2nd of three 8e-3 cuts
  (genetic-value done S42; settings-about + workflow-integration remain).
- **Strict TDD — PURE run-and-observe** (no defect; the Breeding Groups pane already renders and
  "Breeding Groups" IS the `tabPanel` title `appUI.R:166`) → green-on-arrival `[refactor-only]` conversion,
  gated `PRE-RED→run-and-observe` via `AskUserQuestion`; rigor from a `[mutation-check]` (no synthetic RED).
- **Conversion map by the Learning #40/#41/#42 split — 12 KEEP · 6 REVIVE · 1 ANCHOR · 4 NULL:**
  - **12 genuine `grepl` asserts → keep regex verbatim, rescope haystack to the active pane** (module
    M1–M7; detailed D1🐉/D3/D7; tutorial T2/T3).
  - **6 tautologies with a dead computed grepl → REVIVE that pattern, rescoped + pruned** (Learning #42a):
    D2 `harem` (✓"Harem (1M:NF)"), D4 `result|group|table|output|formed` (✓"group"; rest data-dependent →
    8e-6), T1 `group.*formation|source.*animal` (✓h3/guidance), T4 `Seed.*Group|seed.*animal|specific.*animal`
    (✓"Seed groups with specific animals"), T6 `Include.*kinship|kinship.*display` (✓"Include kinship in
    display of groups"), T8 `top.*ranked` (✓"Top ranked"). Pruned: inputId artifacts (`seedGroups`,
    `showKinship`), never-rendered framing words (`workflow`, `Choose.*group`, `pre.*seed`), and the
    foreign-module token `genetic.*analysis`.
  - **1 content-length tautology (`nchar(html) > 200`) → ANCHOR** to the always-visible guidance phrase
    "algorithm" (D6; `inst/extdata/ui_guidance/group_formation.html` "The algorithm ignores...").
  - **4 NULL-pattern (pane-active only):** D5/T7 (export) + T9 (export kinship matrix) — the
    `downloadButton`s live in the INACTIVE "Group Detail" nested tab (`display:none`, not in active-pane
    `innerText`; guidance has no export tokens) → defer to 8e-6 / nested-tab navigation; **T5** (infants-with-dam)
    — no such control exists in the modular UI (tutorial-only concept). Each NULL still upgrades the old
    `expect_true(TRUE)` by confirming the Breeding Groups pane is the active/visible one.
- **1 dragon kept verbatim, flagged in a comment, never renamed** (Learning #41a): D1 `size|number|count|
  animals` — no literal "size" control; matches via "number"/"animals" ("Number of groups:", "Number of top
  animals:", "Seed groups with specific animals").
- **Nested-tab visibility distinction (new this cut):** the nested tabsetPanel's NAV labels ("Groups",
  "Statistics", "Group Detail") ARE in the active-pane `innerText` (always visible), so M7 `statistic` anchors
  on the "Statistics" nav label and D4 "group" on the "Groups" nav label — but the inactive nested tabs'
  CONTENT (the export buttons) is hidden. The pre-gate critic settled this by RENDERING the actual Shiny
  `navbarPage`+`tabsetPanel` DOM; the browser run confirmed it firsthand (M7 GREEN).
- **Pre-gate adversarial verification (0 corrections, dispute resolved firsthand):** a 4-agent refutation
  workflow (3 source-grounded skeptics defaulting-to-refuted + a cross-checking critic) over the 23-block map
  BEFORE the TDD gate confirmed all 23 verdicts. It earned its keep by resolving the one genuine dispute (M7:
  is the nested nav label in `innerText`?) via a real Shiny DOM render and dismissing two skeptic refutations
  that rested on the opposite false premise — robust to 2/3 skeptics hitting stream-idle timeouts (1 full
  skeptic + 1 partial + the critic sufficed).
- **Verification:** browser run **23/23 blocks GREEN / 23 expectations** (1:1 swap, net 0), 0 error / 0 skip
  (`filter="^e2e-breeding-groups"`, env `NPRC_RUN_E2E=true NOT_CRAN=true RENV_CONFIG_AUTOLOADER_ENABLED=false`).
  **[mutation-check] PASS** (inverted — Breeding Groups is the TARGET pane): correct `(Breeding Groups,"Form
  Groups")`→TRUE; wrong-pane `(Pedigree Browser,"Form Groups")`→FALSE; wrong-content `(Breeding Groups,"Focal
  Animals")`→FALSE ("Focal Animals" is Pedigree/Input-only `modPedigree.R:52`/`modInput.R:114`, grep-confirmed
  foreign to BG); old whole-body `grepl("Focal Animals",body)`→TRUE (content-blind contrast); active-pane
  innerText grepl→FALSE (sanity). Non-e2e regression (`NOT_CRAN=true`) — canonical testthat tally
  **2162 `expectation_success` / 0 failed / 0 error / 156 skipped / 5 pre-existing `modPyramid` warnings /
  0 non-e2e offenders** — the S40–S42 baseline held EXACTLY (the 3 BG files self-skip at `create_test_app()`).
- **⚠ Measurement note (refines Learning #42d):** `sum(res$nb) - sum(res$failed)` is NOT the passed count —
  `nb` counts skip and warning rows too (2162 success + 156 skip + 5 warning = 2323). The canonical passed
  count is `expectation_success` (or the testthat reporter's `PASS` line). A "+161 pass" delta from a
  test-only e2e edit (provably impossible) was this formula artifact, diagnosed firsthand, not a regression.
- **Phase 3E:** test-tree-only deliverable — the live browser run (23 blocks via real AppDriver) + the live
  mutation-check spike ARE the runtime (#31 pattern); drove the real app, not just build-clean. No `R/` change
  → no `document()`/NEWS; `tests/` is `.lintr`-excluded.

### 2026-06-08 — Phase 8e-3 part B-1 (Genetic-Value family): boot-level tautologies → behavioral active-pane assertions (issue #40, Session 42)
- **Deliverable (implementation):** the **Genetic-Value family** of plan slice 8e-3
  (`docs/planning/phase8e-assertion-strengthening-subplan.md`) — `test-e2e-genetic-value-module.R` (7),
  `test-e2e-genetic-value-detailed.R` (7), `test-e2e-genetic-value-tutorial.R` (8) = **22 browser-booting
  `test_that` blocks**. All converted from the content-blind `navigate_to_tab → grepl(get_html_safe(app,
  "body"))` idiom to `assert_active_pane(app, "Genetic Value Analysis", <pattern>)`.
- **Owner-scoped to ONE family** (`AskUserQuestion`): 8e-3 censused firsthand at **8 files / ~56 blocks**
  (~3× an 8e-2 session) — far past the family-per-session boundary the 8e-2 sessions (S38–S41) established —
  so it is split per the plan §5 "may split if oversized" + the don't-bundle dragon (FM #18/#25). This
  session did genetic-value only; **deferred to follow-on sessions:** breeding-groups family (3 files, ~23)
  and settings-about + workflow-integration (the navbarMenu finalization of `navigate_to_menu_item` +
  visit-N conversion, 2 files, ~11).
- **Strict TDD — PURE run-and-observe** (no defect; the GV pane already renders and
  `navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")` already targets the right tab —
  "Genetic Value Analysis" IS the `tabPanel` title `appUI.R:148` == the module h3 `modGeneticValue.R:32`)
  → green-on-arrival `[refactor-only]` conversion, gated `PRE-RED→run-and-observe` via `AskUserQuestion`;
  rigor from a `[mutation-check]` (no synthetic RED).
- **Conversion map by the Learning #40/#41 split** — 16 KEEP · 3 REVIVE · 1 ANCHOR · 2 NULL:
  - **16 genuine `expect_true(grepl(orig))` → keep regex verbatim, rescope haystack to the active pane**
    (module M1–M7; detailed D1/D2/D4/D5; tutorial T1–T4/T6).
  - **3 tautologies with a DEAD computed grepl pattern → REVIVE that exact pattern, rescoped** (new
    sub-case vs S41's "tautology → fresh anchor"): D3 `founder|equivalent|FE|genetic` (✓"founder" in the
    guidance "rare founder alleles" + "genetic" in the h3), D6 `report|export|download|summary`
    (✓"Export All/Subset" + "Summary" nested-tab label), T8 narrowed to `filter`
    (✓"Filter View"/"Filter by IDs").
  - **1 content-length tautology (`nchar(html) > 200`) → ANCHOR** to the distinctive always-rendered
    guidance phrase "ranks animals" (D7; `inst/extdata/ui_guidance/genetic_value.html`).
  - **2 NULL-pattern (pane-active only, data-bearing deferred to 8e-6):** T5 "Value Designation" and
    T7 "Z-score" are data-dependent results concepts absent from the static UI/guidance — no faithful
    default-visible pattern exists, so assert only that the GV pane is active (Learning #41a).
- **4 dragons keep their genuine regex verbatim** (Learning #41a — flag in a comment, never rename): M4
  `minimum|breeding|age` (no min-age control in GV; "breeding" matches guidance "breeding colony"); D1
  `population|select|animals|subset` (population is server-derived `modGeneticValue.R:148-162`; "animals"
  matches guidance "ranks animals" and "subset" matches "Export Subset"); T4 `dataTable|DTOutput|table|
  results|ranking` (the rendered table is `req(gvaView())`-gated → 8e-6; "ranking" matches the static
  "Rankings" nested-tab label).
- **Pre-gate adversarial verification narrowed the map** (Learning #40d/#41d): a 4-agent refutation
  workflow (3 source-grounded skeptics defaulting-to-refuted + a cross-checking critic) over the 22-block
  map BEFORE the TDD gate confirmed 21/22 and corrected **T8** — the revived dead pattern carried four
  alternatives (focal/display/Show.*entries/search) FOREIGN to the GV pane (copy-paste from another
  module); only "filter" matches default-visible innerText, so the revive was narrowed to `filter`. The
  critic also dismissed a skeptic's bogus newline-spanning false positive (R `grepl` `.` does not cross the
  newlines `innerText` inserts) and confirmed the two NULLs.
- **Verification:** browser run **22/22 blocks GREEN / 22 expectations** (1:1 swap, net 0), 0 error / 0 skip
  (`filter="^e2e-genetic-value"`, env `NPRC_RUN_E2E=true NOT_CRAN=true RENV_CONFIG_AUTOLOADER_ENABLED=false`).
  **`[mutation-check]` PASS** (inverted — Genetic Value Analysis is the TARGET pane): correct
  `(Genetic Value Analysis,"Run Analysis")`→TRUE; wrong-pane `(Pedigree Browser,"Run Analysis")`→FALSE;
  wrong-content `(Genetic Value Analysis,"Focal Animals")`→FALSE (Pedigree-only label `modPedigree.R:52`,
  absent from the GV pane); old whole-body `grepl("Focal Animals")`→TRUE (content-blind contrast);
  active-pane innerText grepl→FALSE (sanity). Non-e2e regression **2162 passed / 0 failed / 0 error /
  0 non-e2e offenders** (156 skipped, 5 pre-existing `modPyramid` warnings; the e2e-only change self-skips
  at `create_test_app()` `helper-shinytest2.R:196` — the 3 GV files showed 0/0/0/22-skip — so non-e2e counts
  are unaffected; S40/S41 baseline held EXACTLY).
- **Static UI only** (data-bearing GV outputs — rankings table, scatter plot, Summary table incl. Founder
  Equivalents/Value-Designation — are `req()`-gated and deferred to 8e-6). Test-tree-only → no
  `document()`/NEWS; `tests/` is lint-exempt (`.lintr:35`).

### 2026-06-08 — Phase 8e-2 (Pyramid family — the LAST 8e-2 cut → 8e-2 COMPLETE): boot-level tautologies → behavioral active-pane assertions (issue #40, Session 41)
- **Deliverable (implementation):** the **Pyramid family** of plan slice 8e-2
  (`docs/planning/phase8e-assertion-strengthening-subplan.md`) — `test-e2e-pyramid-module.R` (6),
  `test-e2e-pyramid-detailed.R` (6) = **12 browser-booting `test_that` blocks**. Completes 8e-2
  (home-nav+app S38 + Input S39 + Pedigree S40 + Pyramid S41); the next slice is **8e-3**
  (genetic-value / breeding-groups / menu / workflow), a separate session.
- **Strict TDD — PURE run-and-observe** (no defect; the Pyramid pane already renders and
  `navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")` already targets the right tab — "Age-Sex Pyramid"
  IS the `tabPanel` title `appUI.R:139`, 3rd `fallback` arg a documented no-op `helper-shinytest2.R:250`)
  → green-on-arrival `[refactor-only]` conversion, gated `PRE-RED→run-and-observe` via `AskUserQuestion`;
  rigor from a `[mutation-check]` (no synthetic RED).
- All 12 blocks converted from the content-blind `navigate_to_tab → grepl(get_html_safe(app,"body"))`
  idiom to `assert_active_pane(app, "Age-Sex Pyramid", <pattern>)`, by the Learning #40 principled split:
  **(i) 10 genuine `expect_true(grepl(orig))` asserts** keep their original regex verbatim, only rescoping
  the haystack to the active pane (module L6/L25/L42/L59/L76/L93; detailed L6/L25[🐉]/L44[🐉]/L80);
  **(ii) 2 tautologies** upgrade to a precise default-visible anchor — detailed L63 `expect_true(TRUE)` →
  "Download Plot", detailed L99 `nchar(html) > 100` → "Age Plot".
- **0 NULL-pattern blocks** — unlike the Pedigree family (4 NULLs). The pyramid pane's static content is
  rich enough (sidebar controls + an UNCONDITIONAL guidance HTML panel) that every block has a
  default-visible anchor; none of the 12 blocks targets the data-dependent rendered plot / Statistics table
  (those `req(pedigreeData())`-gated outputs, `modPyramid.R:90-118`, are not what these tests assert), so
  nothing defers to 8e-6.
- **The two dragons** keep their keywords against always-rendered static text: detailed:25 `male|female|sex`
  is satisfied by the guidance HTML ("…males are plotted on the left and females on the right",
  `inst/extdata/ui_guidance/pyramidPlot.html` via `modPyramid.R:55-58`) + the h3 "Age-Sex Pyramid Analysis"
  — NOT the data-dependent plot axis labels; detailed:44 `max|maximum|age|limit` ("maximum age setting") is
  satisfied by the always-visible age labels ("Age Unit:", "Age Label Size:") — there is NO dedicated
  max-age control, so the genuine regex is kept verbatim and rescoped rather than renamed (out of scope for
  a haystack-rescope slice).
- **Pre-gate adversarial verification materially CORRECTED the map** (vs S40's 0/19-refuted confirmation):
  a 4-agent refutation workflow (3 source-grounded skeptics defaulting-to-refuted + a critic) over the
  12-block map BEFORE the TDD gate flagged **2/12** — both proposed NULLs (D3 "maximum age setting",
  D6 "data requirement message"). Correctly: D3's regex matches static "age" (→ KEEP, don't NULL) and D6's
  pane has always-rendered guidance (→ anchor "Age Plot", don't NULL+defer). Adopting both corrections
  yielded the 0-NULL outcome. The browser run remained the authoritative `[verify-first]`.
- **Static UI only** (data-bearing plot/table deferred to 8e-6 by virtue of not being targeted here).
- **Verification:** browser run **12/12 blocks GREEN / 12 expectations** (1:1 swap, net 0), 0 error / 0 skip
  (`filter="^e2e-pyramid"`, env `NPRC_RUN_E2E=true NOT_CRAN=true RENV_CONFIG_AUTOLOADER_ENABLED=false`).
  **`[mutation-check]` PASS** (inverted vs the Pedigree slice — Pyramid is now the TARGET pane) —
  correct `(Age-Sex Pyramid,"Bin Size")`→TRUE; wrong-pane `(Pedigree Browser,"Bin Size")`→FALSE;
  wrong-content `(Age-Sex Pyramid,"Focal Animals")`→FALSE (Pedigree-only label `modPedigree.R:52`, absent
  from the Pyramid pane); old whole-body `grepl("Focal Animals")`→TRUE (content-blind contrast);
  active-pane innerText grepl→FALSE (sanity). Non-e2e regression **2162 passed / 0 failed / 0 error /
  0 non-e2e offenders** (156 skipped, 5 pre-existing `modPyramid` warnings; the e2e-only change self-skips
  at `create_test_app()` so non-e2e counts are unaffected — S40 baseline held exactly).
- **Test-tree-only** → no `document()`/NEWS bullet, `tests/` lint-exempt. Phase-3E satisfied by the live
  browser run + mutation-check spike (the #31 pattern — drove the real app).

### 2026-06-08 — Phase 8e-2 (Pedigree family): boot-level tautologies → behavioral active-pane assertions (issue #40, Session 40)
- **Deliverable (implementation):** the **Pedigree family** of plan slice 8e-2
  (`docs/planning/phase8e-assertion-strengthening-subplan.md`) — `test-e2e-pedigree-module.R` (5),
  `test-e2e-pedigree-detailed.R` (6), `test-e2e-pedigree-tutorial.R` (8) = **19 browser-booting `test_that`
  blocks**. Continues S38 (home-nav+app) and S39 (Input); 8e-2 now has only the **Pyramid family**
  (module/detailed = 12) left, as a separate session (plan R3 / FM #18/#25).
- **Strict TDD — PURE run-and-observe** (no defect; the Pedigree pane already renders and
  `navigate_to_tab(app, "Pedigree Browser", "Pedigree")` already targets the right tab — "Pedigree Browser"
  IS the `tabPanel` title `appUI.R:130`, and the 3rd `fallback` arg is an explicit no-op,
  `helper-shinytest2.R:250`) → green-on-arrival `[refactor-only]` conversion, gated `PRE-RED→run-and-observe`
  via `AskUserQuestion`; rigor from a `[mutation-check]` (no synthetic RED).
- All 19 blocks converted from the content-blind `navigate_to_tab → grepl(get_html_safe(app,"body"))` idiom
  to `assert_active_pane(app, "Pedigree Browser", <pattern>)`, by a principled split:
  **(i) genuine `expect_true(grepl(orig))` asserts** keep their original regex verbatim, only rescoping the
  haystack to the active pane (module L6/L25/L42/L76; detailed L6/L25/L44[🐉]/L82; tutorial L155[🐉]);
  **(ii) `expect_true(TRUE)` tautologies** upgrade to a precise default-visible anchor — "Display Unknown IDs",
  "Focal Animals", "Choose CSV file", "Trim pedigree", "Update Focal Animals", "Clear Focal Animals"
  (`modPedigree.R:52,72,79,86,105,118`); **(iii) honest NULL-pattern** `assert_active_pane(app, "Pedigree Browser")`
  for 4 blocks whose target is data-dependent or nonexistent — the DT table (module L59, detailed L63: renders
  only after `req(pedigreeData())` → deferred to 8e-6), DataTables "Show X entries" pagination (tutorial L28
  → 8e-6), and the "status filter" (detailed L101: no such static control exists).
- **The two dragons** (`pedigree-detailed:57` `sire|dam|parent|offspring|ancestor|descendant`,
  `pedigree-tutorial:174` `sire|dam|sex|birth|exit|age|gen|population`) keep their keywords — the column
  names are listed in the always-rendered `inst/extdata/ui_guidance/pedigree_browser.html` guidance panel
  ("Ego ID, Sire ID, Dam ID, Sex, Generation, and Population… Birth Date, Exit Date, Age").
- **Pre-gate adversarial verification:** ran a 4-agent refutation workflow (3 per-file skeptics + critic)
  over the 19-block map BEFORE posing the TDD gate — **0/19 refuted**, critic GO, all patterns confirmed
  default-visible, the 4 NULLs confirmed honest, and the mutation labels "Color Scheme"/"Bin Size" confirmed
  foreign (Pyramid-only). De-risks a slow browser cycle (`[right-sized-orchestration]` / `[completeness-workflow]`).
- **Static UI only** (data-bearing tables/plots deferred to 8e-6).
- **Verification:** baseline browser run 19/19 green → post-conversion **19/19 blocks GREEN / 19 expectations**
  (1:1 swap, net 0), 0 error / 0 skip (`filter="^e2e-pedigree"`, env
  `NPRC_RUN_E2E=true NOT_CRAN=true RENV_CONFIG_AUTOLOADER_ENABLED=false`). **`[mutation-check]` PASS** —
  correct `(Pedigree Browser,"Focal Animals")`→TRUE; wrong-pane `(Age-Sex Pyramid,…)`→FALSE; wrong-content
  `(Pedigree Browser,"Color Scheme")`→FALSE (Pyramid-only label, absent from the Pedigree pane); old whole-body
  `grepl("Color Scheme")`→TRUE (content-blind contrast); active-pane innerText grepl→FALSE (sanity). Non-e2e
  regression **2162 passed / 0 failed / 0 error / 0 non-e2e offenders** (156 skipped, 5 pre-existing
  `modPyramid` warnings; the e2e-only change self-skips at `create_test_app()` so non-e2e counts are unaffected).
- **Test-tree-only** → no `document()`/NEWS bullet, `tests/` lint-exempt. Phase-3E satisfied by the live
  browser run + mutation-check spike (the #31 pattern — drove the real app).

### 2026-06-08 — Phase 8e-2 (Input family): boot-level tautologies → behavioral active-pane assertions (issue #40, Session 39)
- **Deliverable (implementation):** the **Input family** of plan slice 8e-2
  (`docs/planning/phase8e-assertion-strengthening-subplan.md`) — `test-e2e-input-module.R` (5),
  `test-e2e-input-detailed.R` (6), `test-e2e-input-tutorial.R` (8) = **19 browser-booting `test_that`
  blocks**. Continues S38's home-nav+app sub-slice; 8e-2 is now ~half done. Pedigree and Pyramid families
  remain for later 8e-2 sessions (owner-directed scope: Input family only — plan R3 / FM #18/#25).
- **Strict TDD — PURE run-and-observe** (no defect; the Input pane already renders and
  `navigate_to_tab("Input")` already targets the right tab — "Input" IS the `tabPanel` title,
  `appUI.R:120-124`) → green-on-arrival `[refactor-only]` conversion, gated `PRE-RED→run-and-observe`
  via `AskUserQuestion`; rigor from a `[mutation-check]` (no synthetic RED).
- All 19 blocks converted from the content-blind `navigate_to_tab → grepl(get_html_safe(app,"body"))`
  idiom to `assert_active_pane(app, "Input", <static pattern>)`. Patterns sourced firsthand from the
  **`innerText` visibility-map** of the Input pane — default-visible sidebar controls (h3 "Data Input and
  Quality Control", "File Type", "Select Pedigree File", "Minimum Parent Age", "Read and Check Pedigree"),
  the nested-tab nav labels ("QC Summary", "Errors", "Cleaned Data", "Input Format"), and the active
  "Input Format" tab's `includeHTML(input_format.html)` guidance ("comma-delimited", "tab-delimited",
  "Excel", "genotype"). Conditionally-hidden controls (the Separator radio, non-default fileInputs) and
  non-active nested tabs are `display:none` → deliberately avoided.
- **Honest tautology conversion:** `input-detailed` "has example data option" (`expect_true(TRUE)`) names a
  feature the module does NOT have → converted to NULL-pattern `assert_active_pane(app, "Input")` (asserts
  navigation genuinely landed on the visible Input pane), not a forced match on incidental doc text.
  `input-tutorial` "genotype file support" (also a tautology) DOES have real backing → real `"genotype"`.
- **Static UI only** (data-bearing tables/plots deferred to 8e-6).
- **Verification:** baseline browser run 19/19 green → post-conversion **19/19 blocks GREEN / 19
  expectations**, 0 error / 0 skip (`filter="^e2e-input"`, env
  `NPRC_RUN_E2E=true NOT_CRAN=true RENV_CONFIG_AUTOLOADER_ENABLED=false`). **`[mutation-check]` PASS** —
  correct→TRUE; wrong-pane `(Age-Sex Pyramid)`→FALSE; wrong-content `(Input,"Color Scheme")`→FALSE
  (Pyramid-only label, absent from the Input pane); old whole-body `grepl("Color Scheme")`→TRUE
  (content-blind contrast — exactly the defect the conversion closes). Non-e2e regression **2122 passed /
  0 failed / 0 error** (159 e2e-skipped, 5 pre-existing `modPyramid` warnings — unchanged S38 baseline).
- **Test-tree-only** → no `document()`/NEWS bullet, `tests/` lint-exempt. Phase-3E satisfied by the live
  browser run + mutation-check spike (the #31 pattern — drove the real app).

### 2026-06-07 — Phase 8e-2 (home-nav + app-file sub-slice): boot-level tautologies → behavioral active-pane assertions (issue #40, Session 38)
- **Deliverable (implementation):** the home-navigation + light-app-file sub-slice of plan slice 8e-2
  (`docs/planning/phase8e-assertion-strengthening-subplan.md`). 8e-2 spans 11 files / 64 browser-booting
  `test_that` blocks (plan risk R3 / §5 8e-2 dragon = oversized) → split by owner `AskUserQuestion`; this
  session did **home-navigation (10 blocks) + test-app-loading (2) + test-app-navigation (2)**. Input,
  pedigree, and pyramid families remain for later 8e-2 sessions.
- **Strict TDD — PURE run-and-observe** (no defect in scope; the app already behaves and every navigation
  targets the correct tab) → green-on-arrival `[refactor-only]` conversion, gated `PRE-RED→run-and-observe`
  via `AskUserQuestion`; rigor supplied by a `[mutation-check]` (no synthetic RED).
- **`test-e2e-home-navigation.R`** — 5 Home-pane content checks → `assert_active_pane(app, "Home", …)`;
  the 3 `#goto_*` clicks → `assert_active_pane(app, "Input" / "Pedigree Browser" / "Age-Sex Pyramid", …)`,
  turning a no-op-tolerant body-grepl into a real pane-switch assertion (the buttons are wired to
  `updateNavbarPage(...)`, `appServer.R:72-94`). The 2 navbar-label tests ("Navbar has all main tabs",
  "More menu exists") stay whole-DOM `grepl` **carve-outs** (navbar `<ul>`/dropdown labels live outside
  every `.tab-pane`; documented inline).
- **`test-app-loading.R`** — block 1 now also asserts the app boots to the **Home pane**
  (`assert_active_pane`); block 2's navbar body-grepl strengthened **structurally** to assert the real tab
  anchors exist (`wait_for_element(app, 'a[data-value="Input"]')` …), not a substring the Home pane's
  "Go to Input" button also satisfies. **`test-app-navigation.R`** — the two `nchar>0` tautologies become
  a real Input tab-anchor click → pane-switch assertion; the `is.list(values)` check gains
  `expect_identical(app$get_value(input="mainNavbar"), "Home")`.
- **Static UI only** (data-bearing tables/plots deferred to 8e-6); patterns sourced from each pane's module
  UI (`modInput.R:42`, `modPedigree.R:52,103`, `modPyramid.R:25-32`).
- **Verification:** opt-in browser run of the 3 files **14/14 blocks GREEN, 22 expectations** (net +2 vs the
  20-expectation baseline), 0 error / 0 skip. **Mutation check passed** — after `#goto_input`, asserting the
  wrong pane (`"Home"`/`"Age-Sex Pyramid"`) returns FALSE and a Pyramid-only pattern (`"Color Scheme"`)
  returns FALSE, while the old whole-body `grepl` for a Pyramid keyword passes on Input (content-blind).
  Non-e2e regression unchanged: **2122 passed / 0 failed / 0 error** (159 e2e-skipped, 5 pre-existing
  `modPyramid` warnings). Test-tree-only → no `document()`, no `NEWS.md` bullet, `tests/` is lint-exempt.

### 2026-06-07 — Phase 8e-1: active-pane assertion foundation + summary-statistics conversion (issue #40, Session 37)
- **Deliverable (implementation):** slice 8e-1 of `docs/planning/phase8e-assertion-strengthening-subplan.md`
  — the load-bearing foundation for converting the shinytest2 E2E suite from boot-level tautologies to
  behavioral active-pane assertions. Strict TDD (PRE-RED→RED, RED→GREEN gated) + a spike-failure scope-fork
  owner gate.
- **4 active-pane helpers** added to `tests/testthat/helper-shinytest2.R` — `get_active_pane_text`,
  `get_active_pane_value`, `wait_for_active_pane`, `assert_active_pane` (+ an internal `.active_pane_js()`
  builder), following the existing `*_safe` never-throw convention. `assert_active_pane()` is the drop-in
  replacement for the `get_html(app,"body")` + `grepl()` tautology: it asserts the NAMED top-level navbar
  pane is the single visible/active one (catching a wrong-tab or silent-no-op navigation) and optionally
  that its visible `innerText` matches a pattern. **11 browser-free unit tests / 59 expectations** in
  `test_helper_shinytest2.R` (fake-AppDriver stubs, the Phase-8a idiom).
- **Spike-corrected mechanism (HARD GATE).** The live-Chrome spike FALSIFIED the plan's §2.3/§4 selector
  (`.tab-content > .tab-pane.active`): the modules nest their own `tabsetPanel`s, so `.tab-content` is
  non-unique (5 containers; first-match `querySelector` latches onto a nested pane). Corrected to the only
  `.tab-content` not inside a `.tab-pane` → its direct-child `.tab-pane.active` (structural; no dependence
  on the dynamic `data-tabsetid`). Owner-approved deviation; re-confirmed 17/17 through the real helpers
  (all navs incl. the navbarMenu "More" children; innerText honors visibility when correctly scoped).
- **`test-e2e-summary-statistics-module.R` converted** — fixed the 7 wrong-tab navigations (tests 2–8 went
  to "Genetic Value Analysis"; "Summary Statistics" is its own `tabPanel`, appUI.R:156-159) + dropped the
  false "embedded in another tab" fallback, and replaced all 8 tautologies/hidden-DOM asserts with
  `assert_active_pane()` on STATIC UI (export-button labels, the heading, the population-genetics guidance).
  Data-bearing content (summary/founder tables, rendered plots) deferred to slice 8e-6.
- **Verification:** helper unit tests 59/0/0; live spike 17/17; converted e2e file 8/8/0 (opt-in); mutation
  check PASS (wrong-tab→FALSE, correct-tab→TRUE — the old `expect_true(TRUE)` passed both); non-e2e
  regression 2122 passed / 0 failed / 0 error (159 e2e-skipped, 5 pre-existing `modPyramid` warnings).
- **Scope:** test-infra only (no `R/` change) → `document()` N/A, `tests/` lint-exempt, CHANGELOG only (no
  NEWS). See `PROJECT_LEARNINGS.md` Learning #37 + glossary `[hard-gate-spike]`.

### 2026-06-06 — Phase 9: retire the legacy monolithic Shiny app (declare modular canonical) + #27 CLOSED (Session 35)
- **Deliverable (implementation):** the FINAL phase of the shiny-module conversion
  (`docs/planning/shiny-module-conversion-plan.md` §9 Phase 9) — retire the monolith now that the
  modular app is canonical and at parity (Phases 1–8). Strict TDD (RED→GREEN gated) + 4 owner
  `AskUserQuestion` gates + the pre-RED→RED / RED→GREEN TDD gates. **This completes the entire
  XARCH-1 / issue-#27 modularization campaign (Phases 1–9).**
- **`runGeneKeepR()` → deprecated alias.** Rewrote it as a `lifecycle::deprecate_soft()` alias
  launching `runModularApp(port=6013L, launch.browser=TRUE)`; zero-arg callers keep working. New
  `tests/testthat/test_runGeneKeepR_alias.R` (deprecation + delegation + port/launch.browser
  forwarding) and `test_monolith_removed.R` (`system.file("application")==""`).
- **Deleted `inst/application/`** (server.r, ui.r, global.R, 8 uitp*.R, example_1.R, the dead
  modPyramid.R stub, www/ — 17 tracked files) as its own revertible commit (§15). `inst/www/`
  (the modular app's `data-ready.js`) preserved.
- **Removed confirmed orphans (owner-approved):** `getMinParentAge` (unexported, 0 callers),
  `getLogo` (exported, monolith-only — a public-API removal), `shouldShowErrorTab` (exported but
  bypassed by `checkErrorLst`; also dropped the dead `qcResults` build in appServer.R + the
  `@seealso` refs), `modMinimalTest` (unmounted scaffold) + their tests. `document()` dropped 4
  exports + 4 man pages.
- **NAMESPACE fallout fixed:** `getMinParentAge.R` was the SOLE carrier of `@import shiny`, so its
  deletion dropped `import(shiny)` and the modular UI failed (`h5` not found); relocated
  `@import shiny` to `R/nprcgenekeepr-package.R`. Caught by the regression run, not the inventory
  (Learning #35).
- **Pre-flight (irreversible delete):** re-ran the §10 grep-inventory as a read-only multi-modal
  sweep + completeness critic (`wf_48a6f152-f0f`); firsthand-verified the sole `system.file`
  reference, `inst/www` ≠ `inst/application/www`, the lifecycle dep, and that all 17 files are
  tracked/revertible.
- **Docs:** `_pkgdown.yml` (drop getLogo/getMinParentAge), `inst/WORDLIST`, `CLAUDE.md`,
  `ROADMAP.md` (milestone marked complete), `NEWS.Rmd`/`NEWS.md` (monolith-retirement bullet),
  vignette `_running_shiny_application.Rmd` → `runModularApp()`; `README.md` re-knit.
  (`a3manual`/`a2interactive` `.md/.html/.R` are stale-by-design release artifacts — rebuilt from
  source at release; `check()` builds vignettes from source regardless.)
- **Verification:** non-e2e regression **2135 passed / 0 failed / 0 error** (5 pre-existing
  modPyramid warnings); runtime smoke `runGeneKeepR()` → modular app **HTTP 200**;
  **`devtools::check()` = 0 errors / 0 warnings**, `creating vignettes ... OK` (pre-existing NOTEs
  only: non-standard top-level dev files; a stale `spelling.Rout.save` baseline); grep confirms no
  `system.file("application")`.
- **Pre-existing fix (separate `fix:` commit, owner-approved):** `a2interactive.Rmd` error-list
  table was missing the `invalidIdChars` description (NEW-45 drift: `getEmptyErrorLst()` has 10
  fields vs 9 hardcoded) — failed the vignette build; surfaced by the full `check()`.
- **Issue #27 (Modularize code using shiny modules) CLOSED.**
- Commits: `3db018d1` (refactor!: alias + orphans), `24992e0b` (feat!: delete monolith),
  `53a9e5e0` (docs), `a1618c48` (fix: a2interactive vignette), + this `docs:` close-out.

### 2026-06-06 — Implement Phase 8d of the conversion E2E harness: interaction/menu tier green + CI filter broadened to the full tier + #39 CLOSED (Session 34)
- **Deliverable (implementation):** the FINAL sub-phase of the Phase 8 E2E mini-campaign
  (`docs/planning/phase8-e2e-harness-subplan.md` §5(8d)) — the **5 interaction/menu E2E files**
  (home-navigation, settings-about, workflow-integration, error-states, boundary-conditions; 47 blocks /
  53 expectations) green-or-clean-skip opt-in, **broaden the CI run-step filter** to the full
  `^(app|e2e)-` tier (all 23 files), **close issue #39**, and file the 8e follow-on (#40).
  **Config / run-and-observe** (TDD code-phases INAPPLICABLE — owner-approved gate, like 8b/8c): the
  §8.2 navbarMenu spike + the 53/53 green run proved the provisional `navigate_to_menu_item` is already
  correct, so the only code touch is a comment-only docstring + the CI YAML filter — no R unit to write
  test-first.
- **§8.2 navbarMenu spike — RESOLVED (verify-first, before classifying).**
  `set_inputs(mainNavbar="Settings"/"About"/"Help")` → `get_value(input="mainNavbar")` reads back the
  child label TRUE for all 3 → `navigate_to_menu_item`'s delegate-to-`navigate_to_tab` body is final
  (no DOM dropdown-open+click). `click("#goto_input")` navigates for real. **Honesty nuance (→ 8e/#40):**
  the input value reaches the navbarMenu child but the VISIBLE pane does not truly switch — `grepl(body)`
  passes only via the §2.3 hidden-DOM (§8.3 navigation-false-positive).
- **The 5 8d files — green opt-in.** `NPRC_RUN_E2E=true NOT_CRAN=true` → 47 test_that blocks /
  53 expectations, 0 fail / 0 error / 0 skip. All four S33 Watch items confirmed benign firsthand
  (E2E_TIMEOUT defined + only used inside test blocks; the 6 `#goto_*` observers wired `appServer.R:73-95`;
  boundary's named `height/width` handled by `create_app_driver`; the `input-` selectors stay
  tryCatch-swallowed no-ops — 8e).
- **CI filter broadened** to `^(app|e2e)-` (verified firsthand it selects EXACTLY the 23 test-{app,e2e}-*
  files — replicating testthat's stripped-name match in R — and excludes the `appServer` near-miss via
  the trailing `-`); job env + `stop_on_failure=TRUE` + the `sum(passed)==0` silent-skip guard unchanged.
  Full tier re-validated in ONE process: **193 passed / 0 fail / 0 error / 0 skip**, 23 files.
- **⚠ Low-rate Chrome process-count FLAKE found + handled.** An ultracode 4-lens adversarial review
  (`wf_ef031b1d-edc`) caught that the 23-in-one-process run is intermittently flaky — ~1 transient Chrome
  error in 5 local full-tier runs (`workflow-integration.R` "App maintains state when switching tabs";
  isolated 8/8/8) — the §5(8c)/R2 dragon; under `stop_on_failure=TRUE` it can red the scheduled job.
  Reproduced firsthand (2 fresh dedicated runs clean → low-rate + contention-sensitive). **Owner decision
  (`AskUserQuestion`): close #39 now + document the flake**; CI-stability hardening (per-group fresh
  processes) routed to #40.
- **Issue tracker:** **#39 CLOSED** (`--reason completed`, with a validation/watch-item comment).
  **8e filed as #40** ("Strengthen shinytest2 E2E assertions…", label `enhancement`) capturing the
  §2.4/§2.5/§6 deferred items + today's navbarMenu false-positive, plus a CI-stability comment for the flake.
- **Validation:** §8.2 read-backs TRUE; 53/53 8d green; 193/0/0/0 full-tier single-process; non-e2e
  regression (`NOT_CRAN=true`, NPRC_RUN_E2E unset → e2e clean-skip) = **0 failed / 0 error**, 0 non-e2e
  offenders, 2159 passed, 156 e2e-skipped, 5 pre-existing `modPyramid` warnings (unchanged
  S31/S32/S33 baseline). Diff is comment-only (helper docstring) + the CI filter → `document()` N/A,
  `tests/`+`.github` lint-exempt, no `* 2.*` source dupes; committed `d254a91c` with **explicit
  `git add`** of only the 2 files (the review's `.DS_Store` BLOCKER). **Live GitHub run DEFERRED**
  (branch not on remote) — TWO watch items now (renv lib-path + the flake).
- **Next:** parent **Phase 9** (declare the modular app canonical + DELETE the monolith — IRREVERSIBLE,
  its own session, do NOT bundle; confirm with the owner + grep-inventory first). The #39 E2E
  mini-campaign (8a–8d) is COMPLETE.

### 2026-06-05 — Implement Phase 8c of the conversion E2E harness: per-module shallow tier green + CI filter broadened (issue #39) (Session 33)
- **Deliverable (implementation):** the third sub-phase of the Phase 8 E2E mini-campaign
  (`docs/planning/phase8-e2e-harness-subplan.md` §5(8c)) — run-and-observe the **15 shallow per-module
  E2E files** (103 tests) green opt-in, and **broaden the CI run-step filter** in
  `.github/workflows/shinytest2.yaml` from the 3 boot-smoke files to the **18 verified 8b+8c files**.
  **Config / run-and-observe** (TDD code-phases INAPPLICABLE — approved gate, like 8b): the 15 files +
  the 8a helpers already exist and pass trivially via the §2.3 navbarPage hidden-DOM, so there is **no new
  R unit to write test-first**; the browser spike is the verification and the only artifact change is the
  CI YAML filter.
- **8c browser spike — green opt-in.** With `NPRC_RUN_E2E=true NOT_CRAN=true`, run per module-group:
  `e2e-input` (19), `e2e-pedigree` (19), `e2e-pyramid` (12), `e2e-genetic-value` (22),
  `e2e-summary-statistics` (8), `e2e-breeding-groups` (23) = **103 tests across 15 files,
  0 fail / 0 error / 0 skip.** Chrome launches and the modular app boots for every test.
- **Helper corner-cases verified firsthand (§5(8c) DONE):** (a) `navigate_to_tab`'s 3rd arg is the
  ignored `fallback` — the pyramid files navigate to the top-level "Age-Sex Pyramid" tab and pass
  (modPyramid's "Plot"/"Statistics" sub-tabs are never targeted); (b) the only content-coupled assertions
  (`pedigree-detailed.R:57`, `pedigree-tutorial.R:169`) pass on the always-rendered `pedigree_browser.html`
  guidance — noted, not changed; (c) `summary-statistics-module`'s wrong-tab navigation (7/8 tests go to
  "Genetic Value Analysis", §2.4) still passes via the hidden-DOM — a known 8e item, not an 8c blocker.
- **CI filter broadened** (owner-approved): the run-step `filter` goes from
  `^(app-loading|app-navigation|e2e-data-ready)$` to
  `^(app-loading|app-navigation|e2e-data-ready|e2e-input|e2e-pedigree|e2e-pyramid|e2e-genetic-value|e2e-summary-statistics|e2e-breeding-groups)`.
  Verified firsthand the regex selects **exactly the 18 files** (3 8b + 15 8c) and **excludes exactly the
  5 Phase-8d files** (home-navigation, settings-about, workflow-integration, error-states,
  boundary-conditions) — those enter CI only once 8d verifies them. The `stop_on_failure=TRUE` +
  `sum(passed)==0` silent-skip guard and the job env block are unchanged.
- **Validation:** the **exact broadened run-step re-run locally in a single process** (the §5(8c)
  AppDriver-process-count dragon — 18 files × drivers in one `test_dir`) → **18 files, passed=140 /
  failed=0 / skipped=0 / error=0** (37 8b + 103 8c), exit 0. Full non-e2e suite under
  `pkgload::load_all`+`NOT_CRAN=true` = **0 failed / 0 error**, 0 non-e2e offenders, 156 e2e-skipped,
  2154 passed, 5 pre-existing `modPyramid` warnings (unchanged S31/S32 baseline). YAML parses; no R/test
  code changed → `document()` N/A, `tests/`+`.github` lint-exempt, no `* 2.*` source dupes. **Live GitHub
  run deferred** (branch not on remote; same posture as S32) — the run-step is validated locally
  end-to-end. **No adversarial workflow** (no ultracode opt-in; a one-line filter broadening validated
  end-to-end is "already verified" — a multi-agent review would be ceremony for this change surface).
- **Next:** Phase 8d (5 interaction/menu files, 47 tests — needs the secondary helpers + the navbarMenu
  spike → **close #39** + file the 8e assertion-strengthening issue). Then parent Phase 9 (monolith
  deletion, irreversible).

### 2026-06-05 — Implement Phase 8b of the conversion E2E harness: first browser run + CI rewire (issue #39) (Session 32)
- **Deliverable (implementation):** the second sub-phase of the Phase 8 E2E mini-campaign
  (`docs/planning/phase8-e2e-harness-subplan.md` §5(8b)) — the **first-ever real browser run** of the
  modular GeneKeepR app under `shinytest2`/`chromote`, plus the **CI rewire** of
  `.github/workflows/shinytest2.yaml`. **Config-only** (TDD code-phases INAPPLICABLE — approved gate):
  the 3 boot-smoke files use `create_test_app()` + `AppDriver$new` directly / `testServer` (no new
  helpers), so the deliverable is the empirical spike + the CI YAML, not RED→GREEN code.
- **🐉 First browser run — green opt-in.** With `NPRC_RUN_E2E=true NOT_CRAN=true`, all 3 boot-smoke
  files run green: `test-app-loading.R` (2), `test-app-navigation.R` (3), `test-e2e-data-ready.R` (32)
  = **37 tests, 0 fail / 0 error / 0 skip.** Chrome launches and the modular app boots. The
  **navigation spike (§8.1) resolved positively** — `a[data-value="Input"]` clicks against the live
  bslib navbar (no self-skip).
- **CI `shinytest2.yaml` rewired** (owner decision: scheduled + manual): triggers → `schedule`
  (`0 7 * * *`) + `workflow_dispatch` (dropped per-PR push/pull_request); `NPRC_RUN_E2E:'true'` at
  **job-level `env:`**; `continue-on-error` **removed**; Chrome via **`browser-actions/setup-chrome@v2`**
  (`install-dependencies:true`) + `CHROMOTE_CHROME` via `$GITHUB_ENV` + a `find_chrome()` resolve-assert;
  runs only the 3 smoke files with `stop_on_failure=TRUE`; `_snaps/`+`*.png` artifact upload kept.
- **Adversarial review caught a HIGH blocker I missed** (4-lens + completeness-critic workflow,
  re-verified firsthand): the rewrite added `NPRC_RUN_E2E` but **not `NOT_CRAN`** → on the non-interactive
  `Rscript` runner `skip_on_cran()` fires → all 3 files **silently skip** → `stop_on_failure` doesn't
  catch skips → the job goes green having run nothing. Reproduced firsthand (NOT_CRAN unset → 4 skipped,
  0 run). Fixed: `NOT_CRAN:'true'` at job env. Also hardened: (a) `RENV_CONFIG_AUTOLOADER_ENABLED:'false'`
  so the package installs to the **site** lib (the renv autoloader otherwise targets renv's private lib,
  which the AppDriver subprocess can't see); (b) an **executed-count guard** (`stop()` if
  `sum(res$passed)==0`) to make the silent-skip class fail loud; (c) a stronger `find_chrome()` assert
  (single existing path, not bare `nzchar` which passes vacuously on `NULL`).
- **Package-install step added** (was missing): `R CMD INSTALL .` after `setup-r-dependencies`, since the
  app subprocess does `library(nprcgenekeepr)` and `create_test_app()` uses `system.file(package=)`.
- **No R/test code changed** (sub-plan §11 — the E2E files are run/triaged, not rewritten). Full non-e2e
  suite under `pkgload::load_all`+`NOT_CRAN=true` = **0 failed / 0 error**, 0 non-e2e offenders, e2e
  skipped (156), only the 5 pre-existing `modPyramid` warnings — unchanged from the S31 baseline.
- **Verification limit (stated, not skipped — not FM #24):** the CI YAML is verified **statically** (YAML
  parse + 4-lens adversarial review + the exact run-step R validated locally) but **not by a live GitHub
  run** — branch `add-methodology` isn't on the remote and a live run would create a remote feature branch
  (owner chose static + adversarial only). The renv lib-path / AppDriver-subprocess interaction is the #1
  item to confirm on the first live run. `schedule`/`workflow_dispatch` activate once merged to master.
- **Files:** `.github/workflows/shinytest2.yaml` (rewritten); `docs/planning/phase8-e2e-harness-subplan.md`
  §7 (synced — the spec had omitted `NOT_CRAN`). Next: **Phase 8c** (15 shallow per-module files).

### 2026-06-05 — Implement Phase 8a of the conversion E2E harness: define the 6 driver helpers + E2E_TIMEOUT (issue #39) (Session 31)
- **Deliverable (implementation):** the first sub-phase of the Phase 8 E2E mini-campaign
  (`docs/planning/phase8-e2e-harness-subplan.md` §5(8a)) — defined the 6 shinytest2 driver helpers
  + the `E2E_TIMEOUT` constant in `tests/testthat/helper-shinytest2.R`, **browser-free RED→GREEN**
  under strict TDD (resumed after the two planning sessions #21/#30).
- **Helpers added:** `create_app_driver(app_dir, name, height=800, width=1200, ...)`,
  `navigate_to_tab(app, tab_label, fallback=NULL)` (sets `mainNavbar`, returns TRUE only if the tab
  reads back — catches a silent no-op nav), `get_html_safe`/`get_values_safe`/`click_element_safe`
  (`tryCatch`-guarded → `""`/`list()`/`FALSE`), `navigate_to_menu_item` (provisional delegate to
  `navigate_to_tab`; finalized in 8d), and `E2E_TIMEOUT <- 30000L`.
- **Caught a latent bug in the plan's §4 pseudo-code** ([verify-first] on the approved plan): the
  literal `create_app_driver(app_dir, name, ...)` hardcodes `height`/`width` then splices `...`, so the
  2 `test-e2e-boundary-conditions.R` calls passing `height=`/`width=` would duplicate-crash
  `AppDriver$new` (*"formal argument 'height' matched by multiple actual arguments"* — verified that
  `AppDriver$new` has explicit `height`/`width` formals). Fixed by exposing them as named formals; the
  deviation was approved in the PRE-RED→RED phase gate.
- **Tests (browser-free, new file `tests/testthat/test_helper_shinytest2.R`):** 14 `test_that` /
  32 assertions using fake-AppDriver `list()` stubs (throwing / recording-ok / silent-no-op) to
  discriminate the existence, signature, `*_safe` error, success, and read-back contracts — no Chrome
  needed (mirrors `test_create_test_app.R`). All RED at HEAD, GREEN after.
- **Verification:** full non-e2e suite `0 failed / 0 error`, **2154 passed** (+32), e2e skipped (156),
  only the 5 pre-existing `modPyramid` warnings; `document()` zero `man/`/`NAMESPACE` delta; `tests/`
  is `.lintr`-excluded → lint-exempt. Phase 3E N/A (helpers live only in the test tree — the suite is
  the runtime). Learning #31. **Next: Phase 8b** (boot-smoke tier + CI rewire — first browser run).

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
