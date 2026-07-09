# CRAN 2.0.0 Submission Plan — resubmit `nprcgenekeepr` (archived) to CRAN

**Tracks:** Owner directive (Session 101, 2026-06-16): *"prepare this package for submission to CRAN; version goes to 2.0.0; `NEWS.Rmd` since 1.0.8 reorganized into Major/Minor changes, tightened for package users."*
**Authored:** Session 101 (2026-06-16), **planning session**. The TDD code-phases (RED/GREEN/REFACTOR) are **inapplicable to this document** — it is a plan. Each implementation phase below is its own strict-TDD session, with its TDD classification stated per phase.
**Refreshed:** Session 320 (2026-07-08), **planning session** — owner directive: *"All remaining current issues will not be addressed prior to the next CRAN release; current session is to plan for that release."* Reconciles the plan against 124 commits of work landed since the last gate (S240-S242) and scopes the release to exclude all currently-open issues. See **§0** for the full refresh; phases 1-2 unaffected, phase 3 superseded by new **Phase 3b**, phases 4/5a flagged for re-verification, phase 5b unchanged in mechanics but now gated behind 3b/4/5a.
**Evidence base:** every claim below is from a firsthand source verified this session — a 9-agent research+audit workflow (`wy9xitgt6`: 5 web-research agents over CRAN Policy / Writing R Extensions / r-pkgs.org / the two named skills / CRAN status, + 4 read-only codebase auditors over DESCRIPTION+version-strings, `NEWS.Rmd`, R-CMD-check readiness, and build cruft), **plus a firsthand `WebFetch` of the CRAN package page by the session author** to confirm the archival status the whole plan pivots on. Source URLs and `file:line` evidence are inline and in §10.

> **Scope.** This is the planning deliverable. **No `R/`, `tests/`, `DESCRIPTION`, `NEWS.Rmd`, `.Rbuildignore`, or any package content is changed by writing it.** Implementation happens in the subsequent sessions, ONE phase at a time (FM #18 planning-to-implementation bleed; FM #25 horizontal slicing — do **not** bundle plan + implementation, and do **not** bundle phases). The version bump to 2.0.0 and the NEWS rewrite are the owner's headline asks; they are **Phase 3** here, gated behind the cheaper hygiene fixes and the archival root-cause fix that must precede a real check.

---

## 0. Session 320 refresh (2026-07-08) — scoping the actual next release

**Owner directive (verbatim intent):** "All remaining current issues will not be addressed prior to the next CRAN release; current session is to plan for that release." **Planning-only session — no `R/`, `tests/`, `DESCRIPTION`, or `NEWS.Rmd` content changed by this refresh.**

### 0.1 What changed since the last time this plan was touched

The plan's Phase 4/5a gates were last executed **S240-S242** (2026-06-29), against commit `83233265`. Since then: **124 commits**, **235 files touched under `R/` and `tests/`** (`R/`: +2968/−1977 lines; `tests/`: +5384/−769 lines), **9 new exported `R/` files**, and edits to `vignettes/simulatedKValues.Rmd` (50 lines changed — this is the vignette Phase 2's profiling step, §4, named the "prime suspect" for the archival timing cause). **The Phase 4 local `--as-cran` gate and the Phase 5a `cran-comments.md` numbers are therefore STALE** — they describe a tree that no longer exists. See §0.4.

The accumulating evidence is `NEWS.Rmd`'s `# nprcgenekeepr (development version)` section (lines 15-364 as of this session, verified firsthand) — **350 lines**, larger than the entire 2.0.0 entry it sits on top of. It was never folded into a version bump; `git tag` confirms no `v2.0.0` tag exists and `CRAN-SUBMISSION` still records `Version: 1.0.8` — **nothing between archived 1.0.8 and today has ever shipped to CRAN.**

### 0.2 Owner decisions (this session, `AskUserQuestion`)

| # | Decision | Answer | Why |
|---|---|---|---|
| 6 | Roll the unreleased dev-version content into one release, or ship 2.0.0 as originally scoped and treat the rest as a later release? | **Roll everything into one release.** | Nothing has shipped since 1.0.8; splitting would create an intermediate "2.0.0" no user ever sees, for no benefit. |
| 7 | Version number for the merged release? | **Keep 2.0.0.** | Same reasoning as Decision 1 (original plan): 2.0.0 is "the version that clears the archived 1.0.8" — the full accumulated diff still qualifies, since no intermediate version was ever published. |

### 0.3 Scope: issues explicitly deferred past this release

Per the owner directive, **none** of the currently-open GitHub issues are in scope for this release — the release consists only of what has already landed on `master` plus the release mechanics (NEWS reconciliation, re-gate, submission). Deferred (unchanged, re-addressed in a future session):

| Issue | Title | Note |
|---|---|---|
| #116 | Add Flags (genotype/phenotype) column to Genetic Diversity dashboard | Already BLOCKED per S319 handoff |
| #37 | Exported functions not currently used by app | |
| #36 | Chimpanzee-specific age pyramid plot settings | |
| #28 | Timestamped transactional location data for missing-parent identification | |
| #12 | Pull data from ARMS | |
| #11 | Pull demographic data from Oracle database | |
| #10 | Predict future GVA through breeding simulation | |
| #5 | LabKey query feedback | |

### 0.4 Evidence-based inventory — what the reconciliation must cover

**New exported `R/` files since the S242 gate** (`git diff --name-status 83233265..HEAD -- R/ | grep '^A'`): `applyKinshipOverrides.R`, `checkKinshipOverrides.R`, `readKinshipOverrides.R`, `gvaConvergence.R`, `calcGUSE.R`, `setLabKeyDefaults.R`, `getFileDirectRelatives.R`, `getFocalAnimalPedFromFile.R`, `getSpeciesGestation.R` (plus the `speciesGestation`/`loadSpeciesOverrides` additions noted in NEWS but not necessarily new files — confirm file-by-file in Phase 3b execution, this list is not asserted exhaustive beyond the `git diff --name-status` grep).

**`NEWS.Rmd` dev-section content** (verified firsthand, `NEWS.Rmd:15-364`) groups into the file's own existing headers — `Changes` (~25 bullets: #121, #118 three new Ne/GD estimators, #119 sex-specific breeding ages, a `makeSimPed()` correctness fix, **#110**, the `#13` kinship-overrides feature across ~7 bullets, #95, species-column/gestation-table work closing #73, #114), `New features` (7 bullets — the exported functions above), `Documentation` (1 bullet), `Internal changes` (3 bullets). This structure already mirrors the original plan's Major/Minor split (§6) and should drive the Phase 3b classification directly.

### 0.5 Dragon #9 — issue #110 nets out to nothing; do not list both directions

The 2.0.0 entry's own Major-changes bullet says: *"`runModularApp()` is the new Shiny entry point... `runGeneKeepR()` is now a soft-deprecated alias."* The dev-section directly reverses this: *"`runGeneKeepR()` is again the primary Shiny entry point... `runModularApp()` is now the soft-deprecated alias... This reverses the deprecation direction introduced in 2.0.0."* **Since neither direction ever shipped to CRAN, a user of the actual 2.0.0 release will see only the net end-state** — `runGeneKeepR()` primary, `runModularApp()` a deprecated alias (i.e., unchanged from pre-2.0.0 naming). Phase 3b must **rewrite** this bullet to describe only the end state, not concatenate both bullets in sequence (that would read as a self-contradicting release to a CRAN reviewer and to `NEWS.md` readers — the exact failure the plan's existing Dragon #4 warns about for double-counted changes, now recurring at the direction-reversal level, not just duplicate-mention level).

### 0.6 Updated phase sequence

```
[hygiene] fix build cruft + DESCRIPTION/doc defects              → Phase 1  ✅ (unaffected by the refresh)
[ROOT CAUSE] examples/tests/vignettes fast under check            → Phase 2  ✅ (unaffected — but see Phase 4 re-gate note; timing was last MEASURED before 124 commits of new test/example surface)
[NEW] reconcile dev-version NEWS into the 2.0.0 entry              → Phase 3b  ✅ COMPLETE (S321)
[gate] renv::restore() → full local R CMD check --as-cran          → Phase 4  ✅ RE-GATE COMPLETE (S322)
[cross-platform] win-builder x3 + R-hub v2 + cran-comments         → Phase 5a/5b  ◐ cran-comments RESYNC COMPLETE (S323); win-builder/R-hub still PENDING, owner-run
[post-acceptance] git tag + GitHub release + dev-version bump      → Phase 6  (unchanged, after CRAN accepts)
```

Each phase remains its own session with a STOP point (FM #18/#25). **Phase 5b is next** — win-builder ×3 + R-hub v2, owner-triggered per the plan's Phase 5 HARD STOP (the upload + email confirmation is the owner's outward-facing action, not an agent action).

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

> **STATUS: COMPLETE for the June-2026 scope — verified firsthand S139.** `NEWS.Rmd` carries a single `# nprcgenekeepr 2.0.0 (20260618)` section with **Major changes / Minor changes** sub-bullets, re-rendered to `NEWS.md`; `DESCRIPTION:5` = `2.0.0` (bumped S131, `e24a53a2`); `README.md` ("Version 2.0.0") + `CITATION.cff` (`version: 2.0.0`) regenerated; prior version sections untouched. Version-dependent tests green (S138 full regression 0/0).
>
> **SUPERSEDED as the full release scope (S320, 2026-07-08).** 124 commits since S242 added a `# nprcgenekeepr (development version)` NEWS section (350 lines, `NEWS.Rmd:15-364`) that was never folded into a version bump. Per owner decision (§0.2), this and the existing 2.0.0 section merge into **one** 2.0.0 release — see **Phase 3b** below, which must run before Phase 4 is re-gated.

- **Deliverable:** the single post-1.0.8 `NEWS` section reorganized into user-facing **Major changes / Minor changes** for **2.0.0**, re-rendered to `NEWS.md`; DESCRIPTION at 2.0.0; README + CITATION.cff regenerated. Full spec in **§6**.
- **DONE looks like:** `NEWS.Rmd` has one `# nprcgenekeepr 2.0.0 (YYYYMMDD)` section with `- Major changes` / `- Minor changes` sub-bullets matching the project's historical terse style (§6.2), de-duplicated, with breaking changes flagged; `NEWS.md` re-rendered from it; `DESCRIPTION:5` = `2.0.0`; `README.md` + `CITATION.cff` regenerated to 2.0.0; prior version sections untouched.
- **Steps:** (a) edit **`NEWS.Rmd`** (source) per §6 — author plain ASCII, then re-render to `NEWS.md` (github_document); (b) `usethis::use_version("major")` *or* hand-edit `DESCRIPTION:5` → 2.0.0; (c) `devtools::build_readme()`; (d) `cffr::cff_write()`.
- **TDD classification:** NEWS is **prose** (no test surface — verified by render + read). The version bump touches `getVersion()`-dependent tests: **run `test_getVersion*` / `test_appUI_version.R`** — they must reflect 2.0.0 (REFACTOR; if any asserts a literal old version, update with the bump).
- **Verify:** `NEWS.md` re-renders cleanly; `news(package="nprcgenekeepr")`-style read shows the 2.0.0 entry; `packageVersion()` = 2.0.0 after install; version-dependent tests green.
- **Session boundary:** one session. (NEWS rewrite is substantial — if it cannot be done well in one session, split *content rewrite* from *version bump+regenerate*, but keep both before Phase 4.)

### Phase 3b — Reconcile the accumulated `(development version)` NEWS content  (NEW, S320)

> **STATUS: COMPLETE (S321, 2026-07-08).** All 40 dev-section bullets
> (`NEWS.Rmd:15-364` as of S320) classified and merged: 16 Major + 19 Minor
> bullets in the single `# nprcgenekeepr 2.0.0 (20260708)` entry (2 pure-internal
> bullets dropped per §6.3's drop-list pattern — the `getPedigreeSource()`
> adapter/`"file"`-source plumbing bullets, plus one redundant in-app-copy
> bullet already covered by the merged kinship-override bullet). **Dragon #9
> resolved**: the `runModularApp()`/`runGeneKeepR()` bullet pair collapsed to
> one net-end-state Major bullet (`runGeneKeepR()` remains primary; the real
> breaking change — 4 removed exports — is preserved) (#27, #110); a
> post-merge `grep` of `NEWS.md` for `runModularApp`/`runGeneKeepR` confirms no
> contradictory second mention survives. Two items are flagged inline in the
> rendered NEWS (not asked as a separate `AskUserQuestion` — the owner approved
> the full draft, including these flags, via one scope-gate question before any
> file was touched) as changing reported numbers, per the existing
> `secondQuartile` precedent (Decision 4): the GVA missing-parent mean-kinship
> correction (Major) and the `makeSimPed()` known-parent-preservation fix
> (Minor). Also folded in 3 new exported functions
> (`calcGeneDiversity()`/`calcNeSexRatio()`/`calcNeVariance()`, #118) beyond the
> 9 the §0.4 inventory had already found, confirming that list's own
> not-asserted-exhaustive caveat. **Steps executed:** edited `NEWS.Rmd` (head
> lines 1-14 + merged 2.0.0 section + unchanged historical tail from
> `# nprcgenekeepr 1.0.8` on, assembled via `sed`/`cat` rather than a giant
> hand-typed `Edit` match, to avoid a whitespace-mismatch risk on a ~400-line
> block); re-rendered `NEWS.Rmd` → `NEWS.md`
> (`rmarkdown::render(..., quiet=TRUE)`); re-rendered `README.Rmd` → `README.md`
> (**note:** must pass `output_format = "github_document"` explicitly —
> `devtools::build_readme()` failed on 2 missing transitive deps (`bit`,
> `bit64`, Learning 92's renv-not-materialized symptom recurring), and a first
> attempt with `output_format = "md_document"` silently produced a
> differently-formatted file — indented code blocks instead of fenced,
> underscore-escaping, no author/date header — reverted via `git checkout` and
> redone correctly); regenerated `CITATION.cff` via `cffr::cff_write()` (cffr
> was not installed in the renv project library — installed it fresh, a
> reversible dev-tool add, not a `renv.lock`/`DESCRIPTION` change). `Version:`
> in both `DESCRIPTION` and `CITATION.cff` confirmed unchanged (`git diff
> DESCRIPTION` empty) — only rendered prose/dates moved, exactly as this
> phase's DONE-criteria requires. **Verification:** `test_getVersion.R` (7/7)
> and `test_appUI_version.R` (3/3) green; full clean-regression read via
> `test_dir(reporter="silent")` — **0 failed / 0 error / 0 warning** (169
> skipped = the usual `test-app-`/`test-e2e-` baseline); `cran-comments.md` /
> `CRAN-SUBMISSION` confirmed untouched (no bundling into this session). A
> stray `README.html` byproduct from the manual `rmarkdown::render()` call was
> deleted before commit (not gitignored, never previously tracked).

- **Deliverable:** `NEWS.Rmd`'s `# nprcgenekeepr (development version)` section (`NEWS.Rmd:15-364`) merged into the `# nprcgenekeepr 2.0.0` section, producing one release entry that reflects the full diff since archived 1.0.8. Version stays **2.0.0** (Decision 7, §0.2) — no `DESCRIPTION` edit needed unless Phase 3b execution discovers the merged scope changes the calculus (state explicitly if so; do not silently second-guess §0.2).
- **DONE looks like:** `NEWS.Rmd` has exactly one `# nprcgenekeepr 2.0.0 (YYYYMMDD)` section (dev-section heading removed, date refreshed to the actual release-prep date), `Major changes` / `Minor changes` sub-bullets covering the union of the old 2.0.0 content and the dev-section content, re-rendered to `NEWS.md`; `README.md`/`CITATION.cff` re-render cleanly (already at 2.0.0, so only the rendered prose/date should move, not the version number).
- **Steps:**
  1. Classify every dev-section bullet Major vs. Minor using the same rubric as the original Phase 3 (§6.3): user-visible behavior/API/breaking/new-capability → Major; fixes/deps/docs → Minor; pure-internal → drop from NEWS entirely (§6.3's existing drop-list already covers the pattern — apply the same test to `Internal changes` bullets here, e.g. the `getPedigreeSource()` adapter seam is textbook drop-material; the console-warning-suppression bullet is user-visible and should stay, as Minor).
  2. **Resolve Dragon #9 (§0.5) first**, before merging anything else: rewrite the `runModularApp()`/`runGeneKeepR()` bullet pair down to the single net end-state bullet. Do not concatenate.
  3. Merge the `New features` dev-section bullets (7 new exported functions, §0.4) into Major changes, in the same terse-fragment style as the existing entry (§6.2 voice guide).
  4. De-duplicate against the existing 2.0.0 Major/Minor content the way §6.3/Dragon #4 already required for the first rewrite — check for any bullet that describes the same capability from two angles (e.g. the Genetic Value Analysis tab already got several dev-section bullets on top of the 2.0.0 "GVA tab parity" bullet; these likely merge into an expanded single GVA bullet-group, not a duplicate).
  5. Re-render `NEWS.Rmd` → `NEWS.md` (`devtools::build_readme()` equivalent / the project's existing NEWS render step); `devtools::build_readme()`; `cffr::cff_write()` (both should be no-ops on `Version:` since it stays 2.0.0, but will refresh embedded dates/prose).
- **TDD classification:** prose (N/A for testable behavior) + REFACTOR for anything mechanical (README/CITATION.cff regen). No `R/` behavior changes in this phase — the behavior already shipped in the sessions that authored issues #110/#118/#119/#121/#13/#95/#73/#114; this phase only documents it. If classification work surfaces an actual undocumented behavior gap (a dev-section bullet whose described behavior doesn't match current `R/` code), STOP and flag it — do not silently "fix" code during a documentation-merge phase (Two-Mode Problem, SAFEGUARDS.md).
- **Verify:** `NEWS.md` re-renders cleanly with one 2.0.0 section; `git diff DESCRIPTION` is empty (version unchanged); `test_getVersion*`/`test_appUI_version.R` still green; a read-through confirms no bullet pair says two contradictory things about the same function (the Dragon #9 check).
- **Session boundary:** one session. This is a content-heavy rewrite (350+ lines to classify and merge) — if it cannot finish cleanly, stop after classification + the Dragon #9 resolution and leave the actual re-render for a continuation session rather than bundling into Phase 4.

### Phase 4 — Full local `R CMD check --as-cran` gate

> **STATUS: COMPLETE (S134) — true-gate `R CMD check --as-cran` is `Status: 2 NOTEs` = 0 ERROR / 0 WARNING, both NOTEs false-positive.** S134 installed the 4 missing Suggests (`covr`, `shinytest2`, `shinyWidgets`, `spelling`) + `urlchecker` into the renv library, so the check ran a **true gate — no `_R_CHECK_FORCE_SUGGESTS_=false`**. Pre-check: `roxygen2::roxygenise()` produced **zero diff** (`man/`+`NAMESPACE` already in sync); `urlchecker::url_check()` → **all 17 URLs correct**; `spelling::spell_check_package()` reconciled `inst/WORDLIST` (**+35 legitimate terms**, 310→345 lines). Gate timings all comfortable: examples `[19s/19s]`, `--run-donttest [19s/19s]`, tests `[41s/43s]`, vignette rebuild `[15s/16s]`, PDF manual OK. Full clean-regression read **0 failed / 0 error** (863 result rows; 167 skipped = e2e/app via `skip_on_cran`+opt-in gate). **NOTE 1** = CRAN incoming feasibility ("New submission / Package was archived on CRAN") — expected, CRAN-persistent, pre-explain in Phase-5 `cran-comments.md`. **NOTE 2** = "checking HTML version of manual" (`'tidy' not recent enough` + `package 'V8' unavailable` → both sub-checks *skipped*) — a **local-toolchain** NOTE; CRAN's machines have recent HTML Tidy + V8, so it will **not** appear there. **Verified twice** (initial build, then a rebuild after the WORDLIST change — identical result; WORDLIST is consumed only by the `skip_on_cran` spell test, so it is gate-invariant). **NEW FINDING (out of scope — own session):** 5 of the 6 example pedigree datasets (`pedGood`, `pedDuplicateIds`, `pedFemaleSireMaleDam`, `pedMissingBirth`, `pedSameMaleIsSireAndDam`) have a column literally named **`si.re`** (the 6th, `pedInvalidDates`, correctly uses `sire`). Almost certainly a data defect (should be `sire`/`sire_id` to pair with `ego_id`/`dam_id`). `si` was deliberately **left out** of WORDLIST so the flag stays visible; not a CRAN blocker (odd column names are legal). See PROJECT_LEARNINGS Learning 127. Tracked as issue #53 — **out of this release's scope** per §0.3 (not one of the 8 currently-open issues listed there because it was filed after; still deferred under the same owner directive).
>
> **RE-GATE REQUIRED (S320, 2026-07-08).** This gate describes commit `83233265` (S242). 124 commits and 235 R+test files have changed since, including 9 new exported functions and 50 changed lines in `vignettes/simulatedKValues.Rmd` (Dragon #10, §5). **Must re-run in full after Phase 3b lands** — do not treat the 0/0/2-NOTE result above as still current.
>
> **Phase 3b has now landed (S321, 2026-07-08)** — this gate is the next session. Only `NEWS.Rmd`/`NEWS.md`/`README.md`/`CITATION.cff` changed in Phase 3b (prose + metadata regen, no `R/`/`tests/` edits), so the 124-commit/235-file drift this note describes is otherwise unchanged since S320's refresh — the re-gate still needs to run against the current tree, not against the stale S134/S240/S241 result.
>
> **RE-GATE COMPLETE (S322, 2026-07-08), against commit `2abfc783` (S321).** `devtools::check(args="--as-cran", remote=TRUE, manual=TRUE)` → **`Status: 2 NOTEs` = 0 ERROR / 0 WARNING** — the same two pre-known false-positives as S134 (CRAN incoming feasibility for the archived package; local HTML Tidy version — and the V8 sub-check that also flagged in S134 is now clean in this environment, one fewer sub-flag). Pre-check steps: `renv::restore()` — library already synchronized, no-op; `roxygen2::roxygenise()` — zero diff (`man/`/`NAMESPACE` already in sync); `devtools::spell_check()` — one new word flagged, **`erroring`** (`NEWS.md:157`, a legitimate gerund from Phase 3b's merged content) — added to `inst/WORDLIST` surgically (single line, alphabetical placement confirmed), re-run clean; `urlchecker::url_check()` — **17/18 URLs OK**, one new 403 (`README.md:170`, `thoughtco.com`) confirmed bot-blocking not a dead link (curl with browser UA + WebFetch both 403/blocked) — same false-positive class as the existing PMC4671785 note (§3.4), **add to the Phase-5 `cran-comments.md` pre-explained-NOTEs list**; `devtools::run_examples()` — clean (exit 0), only expected `minParentAge` deprecation + low-iteration `checkFgDegeneracy` warnings from demo settings; vignette build — needed `bit`/`bit64` installed into the renv library first (Learning 92 recurrence, same class as S134's `markdown` install — env-setup gap, not a package defect; `renv.lock`/`DESCRIPTION` diff confirmed empty) — then all 4 vignettes (`a3manual`, `a2interactive`, `gvaConvergence`, `simulatedKValues`) built clean. Gate timings: examples `[22s/22s]`, tests `[106s/106s]` (up from S134's 41-43s — expected, 124 commits added +5384 lines to `tests/`), vignette rebuild `[20s/21s]` (up from 15-16s — one more vignette than S134, `gvaConvergence.Rmd`). No timing flags anywhere; still comfortable headroom. Full clean-regression read (`test_dir(reporter="silent")`) — **0 failed / 0 error / 0 warning**, 169 skipped (baseline), 3261 total tests (up from S134's 863 result rows — reflects the same test-suite growth). `test_getVersion.R` (7/7) and `test_appUI_version.R` (3/3) green; `packageVersion("nprcgenekeepr")` = 2.0.0. `git diff DESCRIPTION` empty (this phase doesn't bump version). Two stray build byproducts (`Rplots.pdf` from `run_examples()`, never gitignored) removed before commit; vignette-build byproducts (`doc/`, `vignettes/*.html`, `vignettes/*.R`) confirmed already gitignored, no new stray files. **`cran-comments.md` NOT touched this session** (Phase 5, gated behind this result per the plan's own Phase 5 STATUS note). **Next: Phase 5's `cran-comments.md` re-sync** (update the "Resubmission" section for Dragon #9's Phase 3b fix, the "R CMD check results" section with this session's numbers, and add the new `thoughtco.com` 403 to the pre-explained-NOTEs list) — **then** win-builder/R-hub (owner-triggered).

- **Deliverable:** a clean `R CMD check --as-cran` on the built 2.0.0 tarball (0/0/0, or only the three pre-explained NOTEs).
- **DONE looks like:** `devtools::check(args = "--as-cran", remote = TRUE, manual = TRUE)` → 0 ERROR, 0 WARNING, only the documented false-positive NOTEs (§3.4).
- **Steps:** `renv::restore()` first (Learning 92); `roxygen2::roxygenise()`; `devtools::spell_check()` (reconcile `inst/WORDLIST`, confirm only EHR/Raboin/kinships remain after the `mulatta` fix); `urlchecker::url_check()`; `devtools::run_examples()`; build vignettes; `devtools::check(args="--as-cran", remote=TRUE, manual=TRUE)`; full `devtools::test()` clean-regression read.
- **TDD classification:** **verification phase** (N/A for new code) — but any defect surfaced here that needs a code fix re-enters RED→GREEN→REFACTOR in *this or a follow-up* session.
- **Verify:** the check log itself is the deliverable; capture it for the `cran-comments.md`.
- **Session boundary:** one session. If new ERRORs/WARNINGs appear, fix the smallest set and re-run; if a fix is large, STOP and scope it as its own phase.

### Phase 5 — Cross-platform checks + `cran-comments.md` + submission package

> **STATUS: COVER NOTE + RUNBOOK DONE (S135); LOCAL PREP VERIFIED (S136); cross-platform runs PENDING (owner-triggered).** Owner chose scope **A** ("cover note + runbook"). S135 rewrote `cran-comments.md` for the 2.0.0 archived-package resubmission — addresses the 2025-07-29 archival, reports the S134 local gate `0 errors | 0 warnings | 2 notes` with each NOTE explained (NOTE 2 flagged as a local-toolchain artifact absent on CRAN), drops the now-moot NEWS http→https false-positive (verified: no `http://` in `NEWS.md`), and removes the old doubled "Reverse dependencies" block. The file is CRAN-facing-only (no embedded process notes / placeholders). The exact win-builder ×3 + R-hub v2 commands, prerequisites, and submission HARD STOP live in `docs/planning/cran-2.0.0-phase5-runbook.md`. **A 3-lens adversarial verification** (repo fact-check + runbook-command/API + skeptical-CRAN-reviewer) confirmed the facts and caught: the headroom claim is per-example not per-phase (scoped); the timing wording must not imply a structural fix that wasn't made (reworded — the cause does not reproduce, win-builder/R-hub on slower hardware re-confirm before submission); and a **branch/PR correction** — `origin/master` is still **1.1.0.9000** (PR #52 merged only S101-S117, not the 2.0.0 bump) and the long-assumed **"PR #53" does not exist**; `origin/add-methodology` is at 2.0.0 but lacks S133's `withr` fix, so the tree must be pushed before R-hub runs (see Learning 128). **REMAINING (owner):** run the 3 win-builder uploads + R-hub v2, paste real results into `cran-comments.md`, reconcile the misspelled-words list against the real check log, then submit (the upload + email confirmation is the owner's, plan decision #3). **S136 (owner chose "prep + hand off"):** re-verified the branch with `git fetch` + `git rev-list --left-right --count origin/add-methodology...HEAD` → `origin/add-methodology` is **fully in sync** with local HEAD `24175785` (0/0), so the remote already carries the `withr` fix — **the "push before R-hub" prerequisite is already satisfied** (S135's "2 commits behind / push first" caveat is superseded; the branch was pushed after S135's handoff); rebuilt the final tarball via `R CMD build .` (clean → `nprcgenekeepr_2.0.0.tar.gz`, 1.9 MB, vignettes OK; artifact removed, not committed); re-confirmed every cover-note fact firsthand (Version 2.0.0; maintainer `rmsharp@me.com` via the `cre` role; empty `revdep/README.md` Revdeps; the `0/0/2` gate still applies since the code/data/metadata tree is unchanged since the S134 gate); and tightened the runbook (added a copy-paste **Quick sequence**, corrected the §3 branch caveat to "verified current — no push needed", and added a build-confirmation note in §1). The cover note `cran-comments.md` is unchanged (already CRAN-facing-only).
>
> **RE-SYNC REQUIRED (S320, 2026-07-08) — do not run win-builder/R-hub against the current cover note yet.** `cran-comments.md`'s "Resubmission" section describes only the original 2.0.0 breaking changes (period-in-ID, `runModularApp()` primary) — the last one is now **factually wrong** post-Phase-3b (Dragon #9, §0.5: `runGeneKeepR()` is primary again). Its "R CMD check results" section reports the stale S134/S240/S241 numbers. **Sequence: Phase 3b → Phase 4 re-gate → THEN update `cran-comments.md`'s Resubmission + R CMD check sections to match → THEN Phase 5b (win-builder/R-hub/submit).** Running win-builder/R-hub before this resync would burn the owner's ~30-min-per-platform budget checking a tarball whose cover note no longer matches its own NEWS.
>
> **Phase 4 re-gate now landed (S322, 2026-07-08)** — the resync is unblocked. `cran-comments.md` needs: (1) the "Resubmission" section's `runModularApp()`-primary claim corrected to the post-Dragon-#9 net end-state (`runGeneKeepR()` primary; see Phase 4's S322 STATUS note above for the exact fix already in `NEWS.md`); (2) the "R CMD check results" section updated to S322's `2 NOTEs = 0 ERROR / 0 WARNING` numbers; (3) the pre-explained-NOTEs list gains a fourth entry — the new `thoughtco.com` 403 (bot-blocking, confirmed not a dead link) found by this session's `urlchecker::url_check()`, alongside the existing NEWS http→https / PMC4671785 403 / EHR-Raboin-kinships entries. This resync + the win-builder/R-hub runs is the next session (Phase 5b).
>
> **Phase 3b landed (S321, 2026-07-08)** — the Dragon #9 fix referenced above is in `NEWS.Rmd`/`NEWS.md` now (`runGeneKeepR()` primary, no entry-point-direction contradiction). This resync is still blocked on the **Phase 4 re-gate**, not on Phase 3b — do not update `cran-comments.md` until Phase 4 produces current check numbers.
>
> **PHASE 5a RESYNC COMPLETE (S323, 2026-07-08).** `cran-comments.md` updated: (1) "Resubmission" section's entry-point claim corrected to `runGeneKeepR()` remaining primary / `runModularApp()` a soft-deprecated alias (verified against `NEWS.md:15-16`); (2) NOTE 1's URL list gained the `thoughtco.com` 403 alongside the existing PMC4671785 entry, and NOTE 2's wording dropped the now-stale V8 sub-flag (clean in S322's re-gate environment); (3) the "Resubmission" section's own timing-narrative prose — not just the NOTE list — was also stale: it claimed all three phases complete "in well under a minute," which is no longer true now that tests take ~106s (up from ~43s, per S322's re-gate); reworded to report S322's actual aggregate timings (examples ~22s, tests ~106s, vignette-rebuild ~21s) with a "comfortable headroom, no timing flags" framing instead of the now-false "under a minute" claim — a resync must check narrative timing claims for staleness, not only the structured NOTE/URL lists (see PROJECT_LEARNINGS Learning 300). Phase 5b (win-builder ×3 + R-hub v2 + paste results + submit) remains **PENDING, owner-triggered** — not started this session, per the plan's own Phase 5 HARD STOP.
>
> **PHASE 5b READINESS RE-VERIFIED, STILL PENDING/OWNER-TRIGGERED (S326, 2026-07-08).** Owner asked to resume Phase 5b; per the runbook's own framing (outward-facing, needs the owner's GitHub PAT, win-builder results arrive by email to the owner) and this exact precedent across S135/S242/S320/S323, put the scope to the owner via `AskUserQuestion`; **owner chose verification-only, not a live run.** Re-checked for drift since S323: `git log --oneline 2abfc783..HEAD -- R/ tests/ DESCRIPTION` is empty (no package/test/version changes since the S322 gate); `origin/master`/`HEAD` are `0  0` apart; `DESCRIPTION` Version is still `2.0.0`; `cran-comments.md` (last touched S323) re-read clean, with only the two expected win-builder/R-hub placeholders remaining under "Test environments"; `docs/planning/cran-2.0.0-phase5-runbook.md` (last touched S242) re-read clean. Also confirmed no API drift in the runbook's tool calls against the installed library (`devtools` 2.5.2, `rhub` 2.0.1, `gitcreds` 0.1.2) — `devtools::check_win_devel/check_win_release/check_win_oldrelease/build/submit_cran`, `rhub::rhub_doctor/rhub_check(platforms=...)`, `gitcreds::gitcreds_set()` all exist with signatures matching the runbook's usage. **No code, test, or cover-note change was needed** — everything verified accurate as-is. Phase 5b remains exactly where S323 left it: PENDING, owner-triggered, ready to run whenever the owner executes the runbook's Quick sequence.
>
> **CORRECTION (S327, 2026-07-09) — S326's "no change needed" call was incomplete.** The owner then actually ran the Phase 5b runbook. All three win-builder results (R-devel, R-release, R-oldrelease) came back `0 errors | 0 warnings | 2 NOTEs`: NOTE 1 matched the already-pre-explained content in `cran-comments.md` exactly (no new issue), but **NOTE 2 was not the anticipated local-HTML-manual-tidy note** (that one correctly did not reproduce) — it was a real, new one: *"Non-standard files/directories found at top level: 'BOOTSTRAP.md' 'CONTEXT_TEMPLATE.md' 'HANDOFFS.md' 'dashboard_history.jsonl'"*, identical across all three logs. Root cause: these 4 files were all introduced by the S324 methodology sync (three new root docs, plus a generated dashboard-snapshot file that is `.gitignore`d but was never `.Rbuildignore`d — a locally-present, gitignored file still ships in the tarball unless `.Rbuildignore` excludes it separately) — **after** the S322 local gate ran (commit `2abfc783`), so that gate never tested against them, and S326's drift check was scoped to `R/`/`tests/`/`DESCRIPTION` only, which does not cover new root-level files. Fixed in `.Rbuildignore` (4 new anchored, paren-free lines in the existing "Methodology framework files" section, matching that section's established `^NAME.*\.md$` style); verified via `R CMD build .` + `tar tzf` grep — the 4 files no longer ship, top-level listing is back to the standard `DESCRIPTION`/`LICENSE`/`NAMESPACE`/`NEWS.md`/`README.md` set. See **Dragon #11** (§5) for the generalized lesson. **The three win-builder checks need to be re-run against the corrected tarball before their results go into `cran-comments.md`** — the runs already completed reflect the pre-fix tree and should not be pasted in as final. R-hub v2 (checks `origin/master` directly) was also in flight against the pre-fix tree when this was found; it likely surfaces the same NOTE 2 and should be re-run too once this fix is pushed.
>
> **PHASE 5b CROSS-PLATFORM CHECKS COMPLETE, ALL CLEAN (S328, 2026-07-09).** The owner re-ran the full Phase 5b runbook against the `.Rbuildignore`-fixed tree. **win-builder** (R-devel, R-release, R-oldrelease): all three `0 errors | 0 warnings | 1 note` — confirmed via each `00check.log` that the remaining note is exactly the expected CRAN-incoming-feasibility note (new submission, previously archived, misspelled-but-correct words `EHR`/`Raboin`/`kinships`), no top-level-files NOTE, no other issue. **R-hub v2** (linux, windows, macos): windows and macos came back `Status: OK` (0/0/0) on the first run; linux initially failed at the `setup-deps` step (`Failed to download Pandoc 3.8.3: Unexpected HTTP response: 504` — confirmed infra flakiness, matching the runbook's own documented precedent, not a code defect) and came back `Status: OK` (0/0/0) on a linux-only re-run. All three platforms now clean. Folded the real results into `cran-comments.md`'s "Test environments" section (replacing both placeholders) and tightened NOTE 1's misspelled-words list to the exact set win-builder actually flagged (`EHR`, `Raboin`, `kinships` — dropped `LabKey`/`Macaca mulatta`, which no run this round flagged), per the runbook §4.2 reconciliation instruction. `cran-comments.md` is now fully populated, CRAN-facing-only, and ready to paste into the submission form. **Remaining: the owner's `submit_cran()` HARD STOP action** (plan Decision #3, §8) — outward-facing, maintainer-only, not an agent action.

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
9. **Issue #110 nets out to nothing — don't list both directions of the reversal.** See §0.5. A user of the actual 2.0.0 release never saw the intermediate `runModularApp()`-primary state; the NEWS entry must describe only the end state.
10. **The archival-timing profile (Phase 2, §4) is now 124 commits and 9 new exported functions stale**, and one of the changed files is `vignettes/simulatedKValues.Rmd` — the plan's own original prime suspect for the archival cause. Phase 4's re-gate (below) is not just a formality; treat its timing table with the same "measure first" discipline as the original Phase 2, not as an assumed-pass rerun.
11. **A build-cruft audit (§3.3) goes stale the moment a new root-level file appears, regardless of who added it or why.** S327 (2026-07-09): the S324 methodology sync added 3 new root docs plus a `.gitignore`d generated snapshot file, none added to `.Rbuildignore`; nothing re-checked build-cruft coverage until an actual win-builder run flagged them (NOTE: "Non-standard files/directories found at top level"). A `git log`-scoped drift check against `R/`/`tests/`/`DESCRIPTION` (as S326 ran) does **not** catch this class of gap — new root files are invisible to it. **Before any cross-platform run, diff the current root-level file listing against `.Rbuildignore` coverage**, not just check for package-code drift; a `.gitignore`d file is not automatically `.Rbuildignore`d — they are separate mechanisms, and `R CMD build` bundles whatever exists locally regardless of git tracking status.

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
| 6 | Roll accumulated dev-version content into one release, or ship 2.0.0 as originally scoped and treat the rest as a later release? | **Roll into one release** (S320, `AskUserQuestion`) | Nothing has shipped since 1.0.8; an intermediate "2.0.0" no user ever sees provides no benefit. See §0.2. |
| 7 | Version number for the merged release | **Keep 2.0.0** (S320, `AskUserQuestion`) | Same logic as Decision 1, re-confirmed at 350 lines' more scope: it's still "the version that clears the archived 1.0.8" since nothing intermediate ever shipped. See §0.2. |

---

## 9. Phase → completion-criteria → session-boundary summary

| Phase | Deliverable | Verify | TDD | Session? |
|---|---|---|---|---|
| 1 ✅ | Build cruft + DESCRIPTION + `\value` clean **(DONE: S102 + typo tail S132)** | `R CMD build` + `tar tzf` grep; targeted check | REFACTOR/mechanical | 1 |
| 2 ✅ | Examples/tests/vignettes fast under `--as-cran` **(MEASURED S133: timing within limits — archival cause already resolved; fixed the lone real CRAN-blocker, an undeclared `withr` test dep)** | `--as-cran` 0 ERROR / 0 WARNING; regression read 0/0 | RED→GREEN (`withr` in Suggests); REFACTOR N/A | 1 |
| 3 ✅◑ | NEWS Major/Minor + 2.0.0 bump **(DONE for June scope: S139. SUPERSEDED as full release scope: 350 lines of unreconciled dev-version content — see Phase 3b)** | NEWS re-renders; version-tests green | prose + REFACTOR | 1 |
| 3b ✅ | **NEW (S320), DONE (S321):** reconciled `(development version)` NEWS content into the 2.0.0 entry, resolved Dragon #9 (#110 net-out) | NEWS re-renders to one 2.0.0 section; no contradictory bullet pairs (verified by grep); `test_getVersion`/`test_appUI_version` green; full regression 0/0/0 | prose + REFACTOR | 1 |
| 4 ✅ | Clean local `--as-cran` **(RE-GATE COMPLETE S322 against commit `2abfc783`: `2 NOTEs` = 0 ERROR / 0 WARNING, same two pre-known false-positives as S134; `bit`/`bit64` installed for vignette build, Learning 92 recurrence; one new WORDLIST word `erroring`; one new bot-blocked URL `thoughtco.com` for the Phase-5 NOTE list)** | the check log (0/0/2-NOTE explained, re-confirmed on current tree) | verification | 1 |
| 5 ◑ | win-builder ×3 + R-hub + cran-comments | platform reports captured | verification/packaging | 1 → owner submits |
| 5a ✅ | `cran-comments.md` rewrite (§7) + cross-platform **runbook** **(DONE for June scope: S135/S136. RESYNC COMPLETE (S323): entry-point claim corrected to `runGeneKeepR()`-primary net end-state; R CMD check NOTE 1/2 wording updated to S322's numbers (`thoughtco.com` 403 added, V8 sub-flag dropped); Resubmission-section timing prose corrected — the stale "well under a minute" claim no longer held once tests grew to ~106s)** | cover note CRAN-facing-only; runbook commands verified; **matches the post-3b NEWS/gate numbers** | verification | 1 |
| 5b ◑ | win-builder ×3 + R-hub v2 runs + paste results + submit **(CROSS-PLATFORM CHECKS COMPLETE, ALL CLEAN (S328) — win-builder x3 at 0/0/1 expected NOTE; R-hub linux/windows/macos at 0/0/0 (one linux infra retry, matching documented precedent). `cran-comments.md` fully populated with real results. Only REMAINING: the owner's `submit_cran()` HARD STOP.)** | clean platform reports; owner submits | verification/packaging | owner |
| 6 | tag + GH release + dev bump | CRAN landing page builds | N/A | 1 (post-accept) |

---

## 10. Sources

**Authoritative (web, agents R1/R4/R5):** CRAN Repository Policy <https://cran.r-project.org/web/packages/policies.html>; Writing R Extensions <https://cran.r-project.org/doc/manuals/r-release/R-exts.html>; submission form <https://cran.r-project.org/submit.html>; R Packages 2e "Releasing to CRAN" <https://r-pkgs.org/release.html> + "Lifecycle" <https://r-pkgs.org/lifecycle.html>; tidyverse NEWS style <https://style.tidyverse.org/news.html>; R-hub v2 <https://blog.r-hub.io/2024/04/11/rhub2/>; win-builder `check_win` <https://devtools.r-lib.org/reference/check_win.html>.
**CRAN status (firsthand `WebFetch` by author + agent R5):** <https://cran.r-project.org/web/packages/nprcgenekeepr/index.html> ("Archived on 2025-07-29"); Archive dir <https://cran.r-project.org/src/contrib/Archive/nprcgenekeepr/>; R-pkg-devel thread (elapsed-times reason).
**The two named skills:** `agent-almanac submit-to-cran` — canonical source <https://raw.githubusercontent.com/pjt222/agent-almanac/main/skills/submit-to-cran/SKILL.md> (the lobehub mirror is JS-blocked); `cran-submission-preparation` (mcpmarket) — **page bot-blocked (HTTP 429 Vercel checkpoint), verbatim checklist NOT retrieved**; its workflow was reconstructed from r-pkgs.org + the marinedatascience re-submission checklist. *(Re-fetch from a browser to confirm the mcpmarket wording before relying on it.)*
**Repo (read firsthand, agents A1-A4 + author):** `DESCRIPTION`, `LICENSE`/`LICENSE.md`, `NEWS.Rmd`/`NEWS.md`, `CITATION.cff`, `cran-comments.md`, `CRAN-SUBMISSION`, `.Rbuildignore`, `README.md`/`README.Rmd`, `NAMESPACE`, `man/appServer.Rd`/`man/appUI.Rd`, `R/runGenekeepr.R:26`, `test_results_summary.md`, `..Rcheck/00check.log`, `revdep/README.md`, `inst/` tree.
**Full agent findings:** workflow `wy9xitgt6` → `/private/tmp/claude-501/.../tasks/wy9xitgt6.output`.
