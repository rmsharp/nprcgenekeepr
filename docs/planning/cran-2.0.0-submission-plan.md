# CRAN 2.0.0 Submission Plan — resubmit `nprcgenekeepr` (archived) to CRAN

**Tracks:** Owner directive (Session 101, 2026-06-16): *"prepare this package for submission to CRAN; version goes to 2.0.0; `NEWS.Rmd` since 1.0.8 reorganized into Major/Minor changes, tightened for package users."*
**Authored:** Session 101 (2026-06-16), **planning session**. The TDD code-phases (RED/GREEN/REFACTOR) are **inapplicable to this document** — it is a plan. Each implementation phase below is its own strict-TDD session, with its TDD classification stated per phase.
**Evidence base:** every claim below is from a firsthand source verified this session — a 9-agent research+audit workflow (`wy9xitgt6`: 5 web-research agents over CRAN Policy / Writing R Extensions / r-pkgs.org / the two named skills / CRAN status, + 4 read-only codebase auditors over DESCRIPTION+version-strings, `NEWS.Rmd`, R-CMD-check readiness, and build cruft), **plus a firsthand `WebFetch` of the CRAN package page by the session author** to confirm the archival status the whole plan pivots on. Source URLs and `file:line` evidence are inline and in §10.

> **Scope.** This is the planning deliverable. **No `R/`, `tests/`, `DESCRIPTION`, `NEWS.Rmd`, `.Rbuildignore`, or any package content is changed by writing it.** Implementation happens in the subsequent sessions, ONE phase at a time (FM #18 planning-to-implementation bleed; FM #25 horizontal slicing — do **not** bundle plan + implementation, and do **not** bundle phases). The version bump to 2.0.0 and the NEWS rewrite are the owner's headline asks; they are **Phase 3** here, gated behind the cheaper hygiene fixes and the archival root-cause fix that must precede a real check.

---

## 1. Context — the fact that reshapes the task

### `nprcgenekeepr` is ARCHIVED on CRAN, not published

Firsthand (`WebFetch` of <https://cran.r-project.org/web/packages/nprcgenekeepr/index.html>, 2026-06-16):

> "Package 'nprcgenekeepr' was removed from the CRAN repository."
> "Archived on 2025-07-29 as issues were not corrected in time."

The live check-results page (`.../web/checks/check_results_nprcgenekeepr.html`) returns **HTTP 404** (CRAN removes check pages for archived packages — consistent with archival).

**Timeline** (CRAN Archive dir `.../src/contrib/Archive/nprcgenekeepr/` + R-pkg-devel thread, agent R5):

| Date | Event | Version |
|---|---|---|
| 2020-06-02 … 2021-03-31 | Early CRAN releases | 1.0.3, 1.0.5 |
| **2022-11-03** | **Archived** (check problems not corrected despite reminders) | — |
| **2025-04-24** | **Un-archived** | 1.0.7 |
| 2025-07-26 | Accepted & published | **1.0.8** (last CRAN version, = `CRAN-SUBMISSION` file) |
| **2025-07-29** | **RE-archived** (~3 days later) — *"issues were not corrected in time"*; the R-pkg-devel thread attributes the trigger to **"Tested elapsed times"** (CRAN timing limits) | — |

### What this changes about the task

This is **not** a routine version update and **not** a first submission. It is a **resubmission of a (twice-)archived package**. Three consequences drive the plan:

1. **The archival root cause must be fixed and proven.** The most-cited trigger is **CRAN example/test/vignette ELAPSED-TIME limits** (Policy: *"Examples should run for no more than a few seconds each"*; long tests/vignettes must be made optional). The 1.0.8 submission *passed* its one-time check (repo `cran-comments.md` shows `0 errors | 0 warnings | 0 note`) but CRAN's **periodic re-checks** later flagged timing → archival. **A clean local check is necessary but NOT sufficient; the deliverable is fast-under-`--as-cran` examples/tests/vignettes.** (FM #24 build-passes-ship-it, at CRAN scale.)
2. **The cover note (`cran-comments.md`) must explicitly address the archival.** CRAN reviewers see the history; a multiply-archived package gets stricter human review. The comment must state: it was archived 2025-07-29 for timing, exactly what was changed to fix it, and that local + cross-platform checks now pass.
3. **A major (2.0.0) bump is well-justified** — there are genuine breaking changes in the post-1.0.8 work (period-in-ID rejection, removed exports, `runGeneKeepR()` deprecation, a changed numeric output). This is the version to clear the archived 1.0.8.

### The acceptance bar (CRAN Policy + Writing R Extensions, agent R1)

- `R CMD check --as-cran` on **current R-devel**, built from a `R CMD build` tarball: **0 ERRORs, 0 WARNINGs, 0 significant NOTEs**. Any unavoidable NOTE must be explained in the submission's *Optional comment* field (the `cran-comments.md` convention). *"If there are any errors or warnings, your package will not be accepted."*
- Submission is **web-form only** (<https://cran.r-project.org/submit.html> → the WU form), `.tar.gz` ≤ 100 MB (source ideally ≤ 10 MB; no data/doc item > 5 MB), followed by a **maintainer-email confirmation link** that must be clicked. **The owner performs the actual upload + confirmation** (outward-facing; not an agent action).
- The DESCRIPTION maintainer email (`rmsharp@me.com`, confirmed firsthand in DESCRIPTION:10) must be unfiltered/monitored — CRAN automated mail must reach it.

---

## 2. The submission path (archived-package resubmission)

The modern devtools/usethis pipeline (r-pkgs.org ch. "Releasing to CRAN", agent R4), adapted for this archived resubmission and the project's renv + Strict-TDD + SESSION_RUNNER constraints:

```
[hygiene] fix build cruft + DESCRIPTION/doc defects        → Phase 1
[ROOT CAUSE] make examples/tests/vignettes fast under check → Phase 2   ⚠ critical path
[headline] rewrite NEWS.Rmd (Major/Minor) + bump to 2.0.0   → Phase 3
[gate] renv::restore() → full local R CMD check --as-cran    → Phase 4
[cross-platform] win-builder ×3 + R-hub v2 + cran-comments   → Phase 5  → OWNER submits
[post-acceptance] git tag + GitHub release + dev-version bump → Phase 6  (after CRAN accepts)
```

Each `[...]` is one session with a STOP point. The pipeline is necessarily **mostly sequential** (you cannot run the final check before the fixes), but each phase delivers a **complete, independently-verifiable** improvement ("if I stop here, this aspect is CRAN-ready and verified") — vertical by *aspect*, not horizontal layers (FM #25).

---

## 3. Evidence-based inventory (MANDATORY for a change plan)

### 3.1 Version-string inventory — every place to change for the 2.0.0 bump (agent A1)

| File:line | Current text | Action |
|---|---|---|
| `DESCRIPTION:5` | `Version: 1.1.0.9000` | **Edit → `Version: 2.0.0`** (the single canonical source) |
| `NEWS.Rmd:13` | `# nprcgenekeepr 1.1.0.9000 (20260126)` | **Retitle → `# nprcgenekeepr 2.0.0 (YYYYMMDD)`** (Phase 3) |
| `NEWS.md:6` | `# nprcgenekeepr 1.1.0.9000 (20260126)` | **Re-rendered** from NEWS.Rmd (do not hand-edit) |
| `README.md:8` | `Version 1.1.0.9000 (2026-06-01)` | **Re-render** README.Rmd after the bump (README.Rmd:10 calls `getVersion()`) |
| `CITATION.cff:11` | `version: 1.0.7` (**stale!**) | **Regenerate** via `cffr::cff_write()` → 2.0.0 + `date-released` |
| README.Rmd:10, `R/appUI.R` About panel | use `nprcgenekeepr::getVersion()` | **NO edit** — auto-tracks DESCRIPTION |

**Historical markers that must NOT be bumped** (verified A1): `R/runGenekeepr.R:26` `when = "1.1.0"` (a `lifecycle::deprecate_soft` marker recording *when* the deprecation happened); prior NEWS release headers (1.0.8 etc.); `inst/extdata/submission.txt` (1.0.7 logs); `inst/extdata/meeting_notes.Rmd` (1.0.3); `docs/planning/shiny-module-conversion-plan.md:50`; the entire `docs/` pkgdown HTML site (build-ignored, regenerated by pkgdown — never hand-edit); `..Rcheck/` (untracked build artifact — **delete**, don't edit).

### 3.2 DESCRIPTION / metadata defects (agents A1, A3)

| Defect | Evidence | Severity |
|---|---|---|
| Species typo `'Macaca' 'mulatto'` → should be **`'mulatta'`** | `DESCRIPTION:23` (+ propagated to `CITATION.cff:15`). NOT in the EHR/Raboin/kinships spelling whitelist → genuine fresh-NOTE / reviewer risk | **high** |
| `appServer()` / `appUI()` missing `@return` (`\value`) | `man/appServer.Rd`, `man/appUI.Rd` have `\usage` but no `\value`; the only two exported *functions* lacking it. Modern `--as-cran` emits a "Missing \value" NOTE | **high** |
| `VignetteBuilder: knitr, rmarkdown` | `DESCRIPTION:81` — rmarkdown is not a registered vignette *engine*; convention is `VignetteBuilder: knitr` (rmarkdown stays in Suggests). NOTE risk | medium |
| renv `Config/...` field on **line 1, before `Package:`** | `DESCRIPTION:1` — `Config/*` is CRAN-legal but must not precede `Package:`; also inconsistent spacing | medium |
| `LICENSE` year `2017-2021` vs `LICENSE.md` `2017-2024` | `LICENSE:1` vs `LICENSE.md:3` — reconcile to current year; keep canonical two-line MIT form | medium |
| Description reference is a PMC URL not a DOI | `DESCRIPTION:21` `<https://pmc.ncbi.nlm.nih.gov/articles/PMC4671785/>` — CRAN *prefers* `<doi:...>`; `<https:>` is acceptable | low |

### 3.3 Build cruft — files that WOULD ship and draw a NOTE (agent A4)

`.Rbuildignore` is already strong (91 lines; covers all methodology/audit/dev top-level files, `NEWS.Rmd`, dated cran-comments, `..Rcheck`, `revdep/`, `docs/`, the 680 KB `meeting_notes.html`, macOS `* 2.md` dupes). **Already covered — do NOT re-add.** The gaps that still ship:

| Path | Add this anchored, paren-free regex line | Severity |
|---|---|---|
| `.DS_Store` | `^\.DS_Store$` | **blocker** (hidden file → NOTE) |
| `.Rapp.history` | `^\.Rapp\.history$` | **blocker** |
| `inst/extdata/.Rapp.history` | `^inst/extdata/\.Rapp\.history$` | **blocker** |
| `inst/extdata/claude_code.qmd`, `software_design_doc.qmd` | `^inst/extdata/.*\.qmd$` | high |
| `inst/extdata/README_modules.md` | `^inst/extdata/README_modules\.md$` | high |
| `inst/extdata/example_usage.R`, `trulyUnknownParents.R` | `^inst/extdata/example_usage\.R$`, `^inst/extdata/trulyUnknownParents\.R$` | high |
| `inst/extdata/submission.txt` | `^inst/extdata/submission\.txt$` | high |
| `inst/_pkgdown.yml` | `^inst/_pkgdown\.yml$` (root `^_pkgdown\.yml$` only anchors the root copy) | medium |

⚠ **`.Rbuildignore` hazard (existing in-file comment, S58/S59):** every line is a **perl regex** — an unbalanced paren *even in a comment* aborts `R CMD build`. Keep additions anchored (`^...$`) and paren-free. Legitimate shipped content (NOT to ignore): `inst/WORDLIST`, all `inst/extdata/*.csv/.txt/.xlsx` example/test data, `inst/extdata/ui_guidance/*.html`, `data/` (24 datasets), `inst/testdata/`, `inst/shinytest/app.R`, `inst/www/`.

### 3.4 R-CMD-check readiness baseline (agent A3)

- **Known-good:** repo `cran-comments.md` → `0 errors | 0 warnings | 0 note` locally; `test_results_summary.md` → 1,853 passed / 0 failed / 2 skipped / 0 warnings across 147 executed files (136.6 s).
- **Recurring false-positive NOTEs to pre-explain in the new `cran-comments.md`:** (1) NEWS historical `http→https` URL (`NEWS.md:298-299`, Therneau page); (2) `PMC4671785` URL returns **403** to automated checkers, reachable interactively (`DESCRIPTION:21`); (3) DESCRIPTION "misspellings" **EHR / Raboin / kinships** are correct.
- **Stale artifact to ignore:** `..Rcheck/00check.log` shows an "Author/Maintainer missing" ERROR — a build-env artifact from checking an unbuilt source tree (Authors@R is well-formed); **do not trust it**, delete `..Rcheck/`.
- **Doc sync:** all 162 NAMESPACE exports have an `man/*.Rd` alias (0 undocumented). 40 `R/*.R` are mtime-newer than their `.Rd` but git shows no drift (checkout-order artifact) — a `roxygen2::roxygenise()` is cheap insurance.
- **renv NOT materialized** (Learning 92): `devtools`/`pkgload`/full check fail until `renv::restore()`. Static analysis only until then.

### 3.5 Reverse dependencies (agent A4)

**None.** `revdep/README.md` Revdeps section empty; `cran-comments.md` states "no downstream dependencies" (twice — de-dup that doubled block when authoring the new file). **`revdepcheck` is NOT required**; the cover note simply records "no reverse dependencies on CRAN."

---

## 4. Phases (each a separate strict-TDD session with a STOP point)

> Per phase: **Deliverable · DONE-looks-like · Steps · TDD classification · Verification commands · Session boundary.** Build-equivalent (CLAUDE.md): `devtools::check()` / `R CMD check`; fast single-file test per CLAUDE.md.

### Phase 1 — Static CRAN hygiene (build cruft + DESCRIPTION + `\value` docs)

> **STATUS: COMPLETE** (verified against the live tree by S132). Executed by **S102** (commit `a3cf3623`): all §3.3 `.Rbuildignore` build-cruft lines, the §3.2 DESCRIPTION fixes (`mulatto`→`mulatta`, renv `Config/*` reordering, `VignetteBuilder: knitr`), the `@return`/`\value` docs for `appServer()`/`appUI()`, and the LICENSE-year reconcile (both files `2017-2026`). **S132** finished the one tail S102 missed — the species typo survived in `README.Rmd`/`README.md`, the `_introduction.Rmd` vignette child, `CITATION.cff`, and `_pkgdown.yml` (website description) — S102 fixed only DESCRIPTION. The **only** remaining §3.2 item is the **optional** DOI (this plan marks `<https:>` acceptable), so Phase 1 needs no further session.

- **Deliverable:** a CRAN-clean DESCRIPTION, complete exported-function docs, and a tarball that ships no stray files — all verifiable by build + static inspection without `renv::restore()`.
- **DONE looks like:** `R CMD build .` then `tar tzf nprcgenekeepr_*.tar.gz` shows **none** of the §3.3 paths; DESCRIPTION has `Package:` first, `mulatta`, `VignetteBuilder: knitr`; `man/appServer.Rd` + `man/appUI.Rd` have `\value`; `LICENSE` year reconciled.
- **Steps:** (a) append the §3.3 `.Rbuildignore` lines + `rm -rf ..Rcheck`; (b) DESCRIPTION fixes §3.2 (mulatto→mulatta, move renv `Config` line below standard fields, `VignetteBuilder: knitr`, LICENSE year; DOI optional); (c) add `@return` to `R/appServer.R` + `R/appUI.R`, `devtools::document()`. **Do NOT bump the version here** (Phase 3).
- **TDD classification:** mostly **REFACTOR / mechanical** (metadata + docs; no runtime-logic change). The `@return` text and DESCRIPTION fixes have **no unit-test surface** — they are verified by `R CMD check`, not testthat (state this honestly; do not invent tests for prose). Guard existing tests: `test_appUI_version.R`, `test_getVersion*` must stay green.
- **Verify:** `R CMD build .` + `tar tzf` grep (per A4 action item); after `renv::restore()` is available, a targeted `R CMD check` confirms no "Missing \value" / hidden-file / VignetteBuilder NOTE. `git diff DESCRIPTION` shows `Package:` first.
- **Session boundary:** one session. Close out when the tarball is clean and docs build.

### Phase 2 — Archival root cause: example/test/vignette timing  ⚠ critical path / here-be-dragons

> **STATUS: MEASURED & RE-SCOPED (S133) — the archival timing defect does NOT reproduce in the 2.0.0 tree.** S133 ran the authoritative `R CMD check --as-cran --timings` here (R 4.6.0; the renv library *is* materialized and base-R `R CMD build`/`check --as-cran` need no `devtools`, so the S131/S132 "Phase 2 blocked here" premise was stale). Measured: `checking examples [19s/20s] OK`, `--run-donttest [19s/19s] OK`, `checking tests [42s/43s] OK`, `checking re-building of vignette outputs [15s/16s] OK` — **no timing flag anywhere**; slowest single example `countLoops` = 1.43s (zero examples ≥ 5s; sum per-example elapsed 7.0s across 145). The plan's "prime suspect" gene-drop vignettes rebuild in 16s total — gene-drop on the tiny `smallPed` is cheap, so they are **not** the offender (exactly the dragon-#1 "measure first" outcome). Archival reason confirmed firsthand in the CRAN db override: *"Archived on 2025-07-29 as issues were not corrected in time. / Tested elapsed times."* Per the session-boundary STOP-and-re-scope rule, the owner re-scoped S133 to the one **real CRAN-blocking** finding the profile exposed: a `1 WARNING` for an **undeclared `withr`** test dependency (`tests/testthat/test_loadSiteConfig.R` uses `withr::local_tempdir()`/`local_envvar()`; `withr` was in neither Imports nor Suggests). **Fixed under strict TDD: added `withr` to `Suggests`** → a re-run `--as-cran` drops to **0 ERROR / 0 WARNING** (lone remaining NOTE = the expected archived/new-submission incoming-feasibility note). **No `\donttest` guarding or iteration reduction was done** — the profile showed no unit near the limit, so guarding would solve a non-problem and risk dragon #2 (changed numeric output). **Residual risk:** CRAN re-checks on slower hardware — the ~3–5× headroom here makes a re-archival-for-timing unlikely, but only **Phase 5** (win-builder/R-hub) retires it. *(Aside: one missing build-only Suggest, `markdown`, was installed into the renv library so the package's own `a3manual.Rmd` vignette builds — an env-setup gap, not a package defect.)*

- **Deliverable:** every example, test, and vignette runs within CRAN timing limits under `R CMD check --as-cran` — the specific defect that got the package archived.
- **DONE looks like:** `R CMD check --as-cran` reports **no "checking examples ... elapsed time" / "checking re-building of vignette outputs" timing flags**; per-example elapsed times are seconds, not minutes; the full check completes well inside CRAN's window using ≤ 2 cores.
- **Steps (measure first — do NOT assume the cause):**
  1. **Profile.** Run `R CMD check --as-cran` (or `tools::testInstalledPackage` / `devtools::run_examples()` with timing) and read the per-example/vignette elapsed-time table. Identify the actual slow units. **Prime suspects** (A3): `vignettes/simulatedKValues.Rmd` (runs gene-drop *simulations* — likely the dominant cost), the building vignettes `a2interactive.Rmd` / `a3manual.Rmd`, and unguarded examples `R/getFocalAnimalPed.R` (lines 14-31), `R/getSiteInfo.R`, `R/getTokenList.R`.
  2. **Fix by mechanism:** wrap genuinely slow examples in `\donttest{}`; gate long tests with `testthat::skip_on_cran()`; reduce simulation iterations / pre-compute / cache slow vignette chunks (`knitr` `cache=TRUE` or precomputed results); confirm every filesystem-writing example (`createExampleFiles`, `create_wkbk`, `makeExamplePedigreeFile`, `qcStudbook`) writes only to `tempdir()`.
  3. **Preserve coverage** — Policy: the checks left enabled must still exercise the features. Don't blanket-`\dontrun` real examples; prefer `\donttest` (still run under `--run-donttest`) + smaller inputs.
- **TDD classification:** **RED→GREEN→REFACTOR where logic changes** (e.g. if a simulation default is parameterized to reduce work, pin the contract with a test first). Most of this is example/test *annotation* + data-size reduction (REFACTOR), but **any change to a simulation default or sampling that alters numeric output needs a RED test first** (this is where dragons live — a "speed-up" that changes GVA results is a correctness regression).
- **Verify:** `R CMD check --as-cran` timing section clean; `as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE))` clean-regression read (exclude `test-app-|test-e2e-`) still 0 true failures; the GVA-bearing tests prove numeric outputs unchanged.
- **Session boundary:** one session. If profiling reveals the cause is NOT timing (e.g. a URL/check change), STOP and re-scope before fixing — the archival reason on the index page is generic ("issues were not corrected in time"); "elapsed times" is from the mailing list, so **let the profile, not this plan, name the offender.**

### Phase 3 — `NEWS.Rmd` rewrite (Major/Minor, user-facing) + version bump to 2.0.0  (owner's headline)

- **Deliverable:** the single post-1.0.8 `NEWS` section reorganized into user-facing **Major changes / Minor changes** for **2.0.0**, re-rendered to `NEWS.md`; DESCRIPTION at 2.0.0; README + CITATION.cff regenerated. Full spec in **§6**.
- **DONE looks like:** `NEWS.Rmd` has one `# nprcgenekeepr 2.0.0 (YYYYMMDD)` section with `- Major changes` / `- Minor changes` sub-bullets matching the project's historical terse style (§6.2), de-duplicated, with breaking changes flagged; `NEWS.md` re-rendered from it; `DESCRIPTION:5` = `2.0.0`; `README.md` + `CITATION.cff` regenerated to 2.0.0; prior version sections untouched.
- **Steps:** (a) edit **`NEWS.Rmd`** (source) per §6 — author plain ASCII, then re-render to `NEWS.md` (github_document); (b) `usethis::use_version("major")` *or* hand-edit `DESCRIPTION:5` → 2.0.0; (c) `devtools::build_readme()`; (d) `cffr::cff_write()`.
- **TDD classification:** NEWS is **prose** (no test surface — verified by render + read). The version bump touches `getVersion()`-dependent tests: **run `test_getVersion*` / `test_appUI_version.R`** — they must reflect 2.0.0 (REFACTOR; if any asserts a literal old version, update with the bump).
- **Verify:** `NEWS.md` re-renders cleanly; `news(package="nprcgenekeepr")`-style read shows the 2.0.0 entry; `packageVersion()` = 2.0.0 after install; version-dependent tests green.
- **Session boundary:** one session. (NEWS rewrite is substantial — if it cannot be done well in one session, split *content rewrite* from *version bump+regenerate*, but keep both before Phase 4.)

### Phase 4 — Full local `R CMD check --as-cran` gate

> **STATUS: COMPLETE (S134) — true-gate `R CMD check --as-cran` is `Status: 2 NOTEs` = 0 ERROR / 0 WARNING, both NOTEs false-positive.** S134 installed the 4 missing Suggests (`covr`, `shinytest2`, `shinyWidgets`, `spelling`) + `urlchecker` into the renv library, so the check ran a **true gate — no `_R_CHECK_FORCE_SUGGESTS_=false`**. Pre-check: `roxygen2::roxygenise()` produced **zero diff** (`man/`+`NAMESPACE` already in sync); `urlchecker::url_check()` → **all 17 URLs correct**; `spelling::spell_check_package()` reconciled `inst/WORDLIST` (**+35 legitimate terms**, 310→345 lines). Gate timings all comfortable: examples `[19s/19s]`, `--run-donttest [19s/19s]`, tests `[41s/43s]`, vignette rebuild `[15s/16s]`, PDF manual OK. Full clean-regression read **0 failed / 0 error** (863 result rows; 167 skipped = e2e/app via `skip_on_cran`+opt-in gate). **NOTE 1** = CRAN incoming feasibility ("New submission / Package was archived on CRAN") — expected, CRAN-persistent, pre-explain in Phase-5 `cran-comments.md`. **NOTE 2** = "checking HTML version of manual" (`'tidy' not recent enough` + `package 'V8' unavailable` → both sub-checks *skipped*) — a **local-toolchain** NOTE; CRAN's machines have recent HTML Tidy + V8, so it will **not** appear there. **Verified twice** (initial build, then a rebuild after the WORDLIST change — identical result; WORDLIST is consumed only by the `skip_on_cran` spell test, so it is gate-invariant). **NEW FINDING (out of scope — own session):** 5 of the 6 example pedigree datasets (`pedGood`, `pedDuplicateIds`, `pedFemaleSireMaleDam`, `pedMissingBirth`, `pedSameMaleIsSireAndDam`) have a column literally named **`si.re`** (the 6th, `pedInvalidDates`, correctly uses `sire`). Almost certainly a data defect (should be `sire`/`sire_id` to pair with `ego_id`/`dam_id`). `si` was deliberately **left out** of WORDLIST so the flag stays visible; not a CRAN blocker (odd column names are legal). See PROJECT_LEARNINGS Learning 127.

- **Deliverable:** a clean `R CMD check --as-cran` on the built 2.0.0 tarball (0/0/0, or only the three pre-explained NOTEs).
- **DONE looks like:** `devtools::check(args = "--as-cran", remote = TRUE, manual = TRUE)` → 0 ERROR, 0 WARNING, only the documented false-positive NOTEs (§3.4).
- **Steps:** `renv::restore()` first (Learning 92); `roxygen2::roxygenise()`; `devtools::spell_check()` (reconcile `inst/WORDLIST`, confirm only EHR/Raboin/kinships remain after the `mulatta` fix); `urlchecker::url_check()`; `devtools::run_examples()`; build vignettes; `devtools::check(args="--as-cran", remote=TRUE, manual=TRUE)`; full `devtools::test()` clean-regression read.
- **TDD classification:** **verification phase** (N/A for new code) — but any defect surfaced here that needs a code fix re-enters RED→GREEN→REFACTOR in *this or a follow-up* session.
- **Verify:** the check log itself is the deliverable; capture it for the `cran-comments.md`.
- **Session boundary:** one session. If new ERRORs/WARNINGs appear, fix the smallest set and re-run; if a fix is large, STOP and scope it as its own phase.

### Phase 5 — Cross-platform checks + `cran-comments.md` + submission package

> **STATUS: COVER NOTE + RUNBOOK DONE (S135); cross-platform runs PENDING (owner-triggered).** Owner chose scope **A** ("cover note + runbook"). S135 rewrote `cran-comments.md` for the 2.0.0 archived-package resubmission — addresses the 2025-07-29 archival, reports the S134 local gate `0 errors | 0 warnings | 2 notes` with each NOTE explained (NOTE 2 flagged as a local-toolchain artifact absent on CRAN), drops the now-moot NEWS http→https false-positive (verified: no `http://` in `NEWS.md`), and removes the old doubled "Reverse dependencies" block. The file is CRAN-facing-only (no embedded process notes / placeholders). The exact win-builder ×3 + R-hub v2 commands, prerequisites, and submission HARD STOP live in `docs/planning/cran-2.0.0-phase5-runbook.md`. **A 3-lens adversarial verification** (repo fact-check + runbook-command/API + skeptical-CRAN-reviewer) confirmed the facts and caught: the headroom claim is per-example not per-phase (scoped); the timing wording must not imply a structural fix that wasn't made (reworded — the cause does not reproduce, win-builder/R-hub on slower hardware re-confirm before submission); and a **branch/PR correction** — `origin/master` is still **1.1.0.9000** (PR #52 merged only S101-S117, not the 2.0.0 bump) and the long-assumed **"PR #53" does not exist**; `origin/add-methodology` is at 2.0.0 but lacks S133's `withr` fix, so the tree must be pushed before R-hub runs (see Learning 128). **REMAINING (owner):** run the 3 win-builder uploads + R-hub v2, paste real results into `cran-comments.md`, reconcile the misspelled-words list against the real check log, then submit (the upload + email confirmation is the owner's, plan decision #3).

- **Deliverable:** green win-builder (devel + release + oldrelease) and R-hub v2 results, plus a `cran-comments.md` ready to paste into the submission form. **Spec in §7.**
- **DONE looks like:** `devtools::check_win_devel()`/`check_win_release()`/`check_win_oldrelease()` emails clean; `rhub::rhub_doctor()` + `rhub::rhub_check()` (the GHA workflow at `.github/workflows/rhub.yaml` already exists) clean on CRAN-relevant platforms; `cran-comments.md` written per §7.
- **Steps:** run the three win-builder uploads (~30 min each, results by email); `rhub::rhub_doctor()` then `rhub::rhub_check()` (needs a GitHub PAT via `gitcreds::gitcreds_set()`; ensure containers have `pak` — prior failures were all infra "no package called pak", not code); author `cran-comments.md` (§7); `R CMD build` the final tarball.
- **TDD classification:** verification/packaging (N/A). Outward-facing (uploads to win-builder/R-hub) — these are checks, not the submission; fine for the agent to run, but **the owner triggers the final CRAN upload**.
- **Verify:** all platform reports captured and referenced in `cran-comments.md`.
- **Session boundary:** one session to assemble the package + comments. **HARD STOP before the actual CRAN upload** — the upload + email-confirmation is the **owner's** outward-facing action (`devtools::submit_cran()` or the web form), not the agent's.

### Phase 6 — Post-acceptance (after CRAN accepts)

- **Deliverable:** tagged release + GitHub release + dev-version bump.
- **Steps:** `usethis::use_github_release()` (tags the `CRAN-SUBMISSION` commit, notes from `NEWS.md`, deletes `CRAN-SUBMISSION`); `usethis::use_dev_version()` → `2.0.0.9000`; push; verify the CRAN landing page builds binaries across flavors after a few days.
- **Session boundary:** one session, only after the CRAN acceptance email.

---

## 5. Here be dragons (load-bearing risks the executor must respect)

1. **The archival cause is assumed, not yet measured (Phase 2).** The index page says only "issues were not corrected in time"; "Tested elapsed times" is a mailing-list attribution. **Profile first; let the data name the offender.** A plan that "fixes timing" without measuring could miss the real cause and get re-archived.
2. **Speed-ups that change numbers are correctness regressions.** Reducing gene-drop iterations or sampling to make a vignette/example fast can silently alter GVA / kinship outputs. Any such change is RED-first with a numeric-contract test (Phase 2).
3. **`NEWS.md` is generated from `NEWS.Rmd`.** Edit the `.Rmd` and re-render; **never edit `NEWS.md` directly** (it will be overwritten). Author plain ASCII — the renderer produces the en-dashes / `\#` escapes (A2).
4. **The single 1.1.0.9000 NEWS section double-counts changes** (ORIP wiring, `getPotentialParents()` gestation window, `isFounder()`/`getFounders()`, `getPyramidPlot()` each appear in both the top topic block AND the bottom Major/Minor block). The rewrite must **merge** these, not list twice (§6.3, A2).
5. **`.Rbuildignore` is perl-regex; an unbalanced paren in a comment aborts the build** (§3.3). Anchored, paren-free lines only.
6. **renv library is not materialized** (Learning 92) — `renv::restore()` is a prerequisite for Phases 4-5 (and the only reason Phases 1-2 lean on static checks first).
7. **Version-bump blast radius is small but has traps** (§3.1): do not bump the `runGenekeepr.R:26` deprecation marker or historical NEWS/inst strings; let `getVersion()`-driven files (README.Rmd, About panel) auto-track.
8. **Don't run `revdepcheck`** — there are no reverse dependencies (§3.5); record the fact, don't burn a session on it.

---

## 6. NEWS rewrite spec (the headline deliverable — detail for Phase 3)

### 6.1 Decision: all post-1.0.8 work becomes the 2.0.0 entry

There was never a 1.1.0 *CRAN* release — `1.1.0.9000` is a dev tag and the only section after the last CRAN version 1.0.8 (A2). So **the existing `1.1.0.9000` section is retitled/rolled into `# nprcgenekeepr 2.0.0 (YYYYMMDD)`**; 1.0.8 and earlier stay as history.

### 6.2 Style to match (the maintainer's "see prior entries", verbatim from A2)

- Heading: `# nprcgenekeepr <version> (<YYYYMMDD>)` — package name in the heading, bare 8-digit date.
- Body: two top bullets `- Major changes` and `- Minor changes`, each with nested `-` sub-bullets; when empty use the literal `- Major changes -- none`.
- Voice: **terse past-tense fragments** (Style A: *"Added unit tests for `trimPedigree()`."*, *"Removed dependency on gdata."*). The current 1.1.0.9000 entry's multi-sentence explanatory paragraphs are **too verbose for the rewrite** — tighten to one user-facing sentence per bullet.
- Function/object names in backticks with `()`; reference issues as `(#NN)`. **Drop the internal `NEW-xx` / `PED-x` / `XARCH-x` tracker codes** from the user-facing file (keep `#NN` GitHub refs).
- Exemplar to emulate (A2, NEWS.Rmd 256-262): `# nprcgenekeepr 1.0.5.9001 (20210830)` → `- Major changes` → one-sentence capability bullet → `- Minor changes` → terse bullets.

### 6.3 Major / Minor classification (Phase 3 raw material — from A2, deduped)

**`- Major changes`** (user-visible behavior, API, breaking, new capabilities):

- **(breaking)** IDs may no longer contain a period — `qcStudbook()` and `geneDrop()` now reject `id`/`sire`/`dam` containing `.` (offenders in `errorLst$invalidIdChars`). *(#27-era; rejects formerly-accepted input.)*
- **(breaking)** `runModularApp()` is the new Shiny entry point; `runGeneKeepR()` is a soft-deprecated alias (zero-arg calls still work); removed exports `getLogo()`, `shouldShowErrorTab()`, `modMinimalTestUI()`, `modMinimalTestServer()` (#27).
- New **Potential Parents** tab — identifies in-colony animals with ≥1 unknown parent and lists candidate sires/dams screened by estimated conception date; wires the exported `getPotentialParents()` into the app. `getPotentialParents()` dam selection now uses a gestation-derived exclusion window driven by `maxGestationalPeriod` (was a fixed ±182.5-day window) (#48, #31). *(merge the two duplicate mentions.)*
- New **ORIP Reporting** tab — ONPRC colony summaries for NIH ORIP (site info, colony table, genetic-diversity metrics, exports) (#47, #49).
- Pedigree Browser "trim based on focal animals" now includes **descendants as well as ancestors**; new exported `getDescendantPedigree()` (#…).
- New exported founder helpers `isFounder()` and `getFounders()`.
- New exported `getAutoIdFormat()` / `setAutoIdFormat()` — the auto-generated placeholder-ID format is now configurable (default `U%04d`) (#44, #38).
- Genetic Value Analysis tab parity — genome-uniqueness threshold is now a user control (default 4); added a subset filter + "Export Subset"; default gene-drop iterations changed to 1000; removed an inert "Minimum breeding age" slider.
- Improved visualizations — box-plot educational popovers (`getBoxWhiskerDescription()`), plot export to PNG/PDF/SVG (`savePlotToFile()`), enhanced age-sex pyramid (`getPyramidPlot()`).

**`- Minor changes`** (fixes / deps / docs, user-visible):

- Fixed a startup crash when a documented-format site-config file is present (new tolerant `loadSiteConfig()`) (#50).
- The **About** panel now shows the installed version dynamically (was hard-coded "Version 1.0.8").
- `geneDrop()` now reports duplicate animal IDs with a clear error instead of the cryptic base-R "duplicate row.names" message.
- Reading a file whose final line lacks a trailing newline no longer emits the spurious "incomplete final line" warning (#4).
- `summarizeKinshipValues()` `secondQuartile` now reports the lower hinge (`fivenum()[2]`) instead of duplicating `min`. ⚠ **maintainer judgment:** this changes reported numbers — consider promoting to Major / flag as a fix users should notice.
- New dependencies: Imports `bslib`, `DT`, `ggplot2`; Suggests `shinytest2`.
- Documentation — corrected `@examples` for `getPedDirectRelatives()`, `cumulateSimKinships()`, `getIdsWithOneParent()` so each calls its own function.

**DROP from the user-facing NEWS** (developer-internal — A2): `calcFE()`/`calcFG()`/`calcFEFG()` internal-helper de-dup; the modular-architecture file-by-file/`moduleServer()`/"Phase 9" internals (state the outcome — `runModularApp()` + retired monolith — under Major, not the mechanics); internal wrappers `runQcStudbook()`/`processQcStudbookResult()`/`shouldShowChangedColsTab()`; internal utilities `safeExecute()`/`logModuleEvent()`/`makeFounderStatsTable()`/`makeGeneticSummaryTable()`; "Testing Improvements" (~145 test files, TDD process); internal test/CI fixes (ggplot2 `aes()` globals, test column expectations, network-test skips).

> **Naming note:** the owner asked for "Major changes / Minor changes" — that is **also the project's own historical NEWS convention** (every prior entry uses it), so the plan keeps it (over tidyverse's "Breaking changes / New features / Minor improvements"). Breaking changes are surfaced via a `(breaking)` lead tag inside Major changes so CRAN/users still see them prominently. *(Consult-project-source-of-truth: follow the project's established style.)*

---

## 7. `cran-comments.md` spec (Phase 5)

Rewrite the existing `cran-comments.md` (fixing its doubled "## Reverse dependencies" block) to contain:

1. **`## Resubmission of an archived package`** — state: archived 2025-07-29 for test/example elapsed times; what was changed to fix it (the Phase 2 specifics — e.g. wrapped slow examples in `\donttest{}`, gated long tests with `skip_on_cran()`, reduced vignette simulation cost); this is version 2.0.0.
2. **`## R CMD check results`** — `0 errors | 0 warnings | 0 notes` (or list + explain).
3. **Pre-explain the three recurring false-positive NOTEs** (§3.4): the NEWS historical `http→https` URL; the `PMC4671785` 403-to-bots URL; the EHR/Raboin/kinships DESCRIPTION words.
4. **`## Test environments`** — local (macOS, R 4.6.0), win-builder devel/release/oldrelease, R-hub v2 platforms.
5. **`## Downstream dependencies`** — "None on CRAN."

---

## 8. Decisions for the owner (defaults chosen; redirect if wrong)

| # | Decision | Default taken in this plan | Why |
|---|---|---|---|
| 1 | Target version | **2.0.0** | Owner-directed; *and* justified by real breaking changes (period-in-ID rejection, removed exports, `runGeneKeepR()` deprecation, `secondQuartile` change). |
| 2 | NEWS section names | **"Major changes" / "Minor changes"** (with `(breaking)` tags) | Owner-directed; matches the project's own historical NEWS style. |
| 3 | Who submits to CRAN | **Owner** does the web-form upload + email confirmation (Phase 5 STOP) | Outward-facing publish (SAFEGUARDS); maintainer-email confirmation is the maintainer's. |
| 4 | `secondQuartile` change | Listed under **Minor** with a maintainer-judgment flag | It changes reported numbers — owner may want it under Major. |
| 5 | Phase grain | **6 phases** as above | Adjustable — Phases 1+ can split if a session can't finish cleanly; do NOT merge Phase 2 (timing) into another. |

---

## 9. Phase → completion-criteria → session-boundary summary

| Phase | Deliverable | Verify | TDD | Session? |
|---|---|---|---|---|
| 1 ✅ | Build cruft + DESCRIPTION + `\value` clean **(DONE: S102 + typo tail S132)** | `R CMD build` + `tar tzf` grep; targeted check | REFACTOR/mechanical | 1 |
| 2 ✅ | Examples/tests/vignettes fast under `--as-cran` **(MEASURED S133: timing within limits — archival cause already resolved; fixed the lone real CRAN-blocker, an undeclared `withr` test dep)** | `--as-cran` 0 ERROR / 0 WARNING; regression read 0/0 | RED→GREEN (`withr` in Suggests); REFACTOR N/A | 1 |
| 3 | NEWS Major/Minor + 2.0.0 bump | NEWS re-renders; version-tests green | prose + REFACTOR | 1 |
| 4 ✅ | Clean local `--as-cran` **(DONE: S134 true gate — 4 Suggests installed, `Status: 2 NOTEs` = 0 ERROR / 0 WARNING, both false-positive; WORDLIST +35; roxygenise/URL clean)** | the check log (0/0/2-NOTE explained) | verification | 1 |
| 5 ◑ | win-builder ×3 + R-hub + cran-comments | platform reports captured | verification/packaging | 1 → owner submits |
| 5a ✅ | `cran-comments.md` rewrite (§7) + cross-platform **runbook** **(DONE: S135, scope A; adversarially verified)** | cover note CRAN-facing-only; runbook commands verified | verification | 1 |
| 5b ☐ | win-builder ×3 + R-hub v2 runs + paste results + submit **(PENDING — owner-triggered; `docs/planning/cran-2.0.0-phase5-runbook.md`)** | clean platform reports; owner submits | verification/packaging | owner |
| 6 | tag + GH release + dev bump | CRAN landing page builds | N/A | 1 (post-accept) |

---

## 10. Sources

**Authoritative (web, agents R1/R4/R5):** CRAN Repository Policy <https://cran.r-project.org/web/packages/policies.html>; Writing R Extensions <https://cran.r-project.org/doc/manuals/r-release/R-exts.html>; submission form <https://cran.r-project.org/submit.html>; R Packages 2e "Releasing to CRAN" <https://r-pkgs.org/release.html> + "Lifecycle" <https://r-pkgs.org/lifecycle.html>; tidyverse NEWS style <https://style.tidyverse.org/news.html>; R-hub v2 <https://blog.r-hub.io/2024/04/11/rhub2/>; win-builder `check_win` <https://devtools.r-lib.org/reference/check_win.html>.
**CRAN status (firsthand `WebFetch` by author + agent R5):** <https://cran.r-project.org/web/packages/nprcgenekeepr/index.html> ("Archived on 2025-07-29"); Archive dir <https://cran.r-project.org/src/contrib/Archive/nprcgenekeepr/>; R-pkg-devel thread (elapsed-times reason).
**The two named skills:** `agent-almanac submit-to-cran` — canonical source <https://raw.githubusercontent.com/pjt222/agent-almanac/main/skills/submit-to-cran/SKILL.md> (the lobehub mirror is JS-blocked); `cran-submission-preparation` (mcpmarket) — **page bot-blocked (HTTP 429 Vercel checkpoint), verbatim checklist NOT retrieved**; its workflow was reconstructed from r-pkgs.org + the marinedatascience re-submission checklist. *(Re-fetch from a browser to confirm the mcpmarket wording before relying on it.)*
**Repo (read firsthand, agents A1-A4 + author):** `DESCRIPTION`, `LICENSE`/`LICENSE.md`, `NEWS.Rmd`/`NEWS.md`, `CITATION.cff`, `cran-comments.md`, `CRAN-SUBMISSION`, `.Rbuildignore`, `README.md`/`README.Rmd`, `NAMESPACE`, `man/appServer.Rd`/`man/appUI.Rd`, `R/runGenekeepr.R:26`, `test_results_summary.md`, `..Rcheck/00check.log`, `revdep/README.md`, `inst/` tree.
**Full agent findings:** workflow `wy9xitgt6` → `/private/tmp/claude-501/.../tasks/wy9xitgt6.output`.
