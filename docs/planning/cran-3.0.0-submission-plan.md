# CRAN 3.0.0 Submission Plan: finish the preparations to submit `nprcgenekeepr` 3.0.0

**Session:** S1091, 2026-10-29. A planning session: nothing under `R/`, `tests/`, `man/`, `vignettes/`,
`inst/` or `data/` changed.
**Status:** DRAFT. Phases 1, 2, 3 and 4 are DONE (S1093; S1092 to S1096; S1097; S1098). The owner has ruled on all of D1 to D6 (section 6;
D4 at S1092, the rest at S1097), each the recommended option. They shape Phase 2's measurement (D4), Phases 3 to 5, and
Phase 8 (D5).
**Owner's direction (S1091):** "This session make a plan to complete preparations to submit version
3.0.0 to CRAN"; mid-session: "Consider removing all old cran-comments.md files or storing them in
/cran/archive (not yet created)."
**Workstream:** `methodology/SESSION_RUNNER.md` §Planning Sessions: a measured inventory, and for
each phase what DONE looks like, the commands that verify it, the surface it is shown on and the
session boundary. Each phase below is its own session. Strict TDD (`CLAUDE.md`) applies wherever
code or tests change, with the three gates put to the owner.
**Builds on:** `docs/planning/cran-2.0.0-submission-plan.md` (the 2.0.0 resubmission, S102 to S410)
and its owner-run runbook `docs/planning/cran-2.0.0-phase5-runbook.md`. Their phase shape, their
"here be dragons" list and the S395/S397 timing fixes carry over. This plan repeats only what is
new or has changed.
**Code measured:** HEAD `801d1e4fc` (the `R/` and `tests/` trees of `3d5270b4f`), and the `v2.0.0`
tag (`db54d3257`) for the comparison run in section 3.

---

## 1. Summary

**Where things stand.** CRAN has 2.0.0. It was published 2026-07-26 and is OK on all 13 check
flavors. This repository is at 2.0.0.9000, 3,504 commits later. It has 54 new exported functions
and has removed none. There are 336 R files (234 at 2.0.0) and 488 test files (264). The version
number 3.0.0 was the owner's S855 decision (`BACKLOG.md:8`).

**What stands between this tree and a submission, highest risk first:**

1. **CRAN's linux-arm64 check fails 2.0.0** (section 2.2). Four expectations fail in
   `test_modInput_incomplete_final_line.R`; the last run was 2026-10-25. The failure is listed as
   an "additional issue" on the package's CRAN page. If nothing changes, 3.0.0 carries it.
   → Phase 1.
2. **Check time is a certain blocker as the tree stands** (section 3).
   - CRAN's automatic incoming check rejected the first 2.0.0 submission on 2026-07-16 with
     "Overall checktime 12 min > 10 min".
   - The accepted 2.0.0 took 588 s on win-builder r-devel, of a 600 s limit.
   - Checked on this Mac in CRAN mode, today's test step takes 309 s. On the same machine and
     command, `v2.0.0` takes 66 s (4.7×).
   - Scaled to win-builder, 3.0.0 comes to roughly 1,300 to 1,450 s.

   About 85 to 95 percent of the CRAN-mode test time has to go. CI keeps running every test.
   → Phase 2, the critical path.
3. **One invalid DOI** in a help page, which produces an incoming NOTE (section 3). → Phase 3.
4. **Release housekeeping:**
   - the old cover notes (the owner's suggestion);
   - the 599-line development block of `NEWS.Rmd`;
   - the version bump;
   - a new `cran-comments.md`.

   → Phases 3, 5, 6 and 8.
5. **A Suggests package used unconditionally by the app** (section 4.4).
   - `R/modSummaryStats.R:17` (`shinyBS::popify()`) and `:356`, `:365`, `:374`
     (`shinyBS::addPopover()`) call `shinyBS` with no `requireNamespace()` guard.
   - `shinyBS` is in Suggests, and a default `install.packages()` does not install Suggests.
   - The same was true at 2.0.0.

   → Phase 4a, fix per D6.
6. **"noSuggests"**, a check CRAN runs after publication with the Suggests packages removed.
   Seven new test files use `kinship2` with no guard in the file itself. → Phase 4b, if the
   owner wants it (D2).

**How many sessions:** 10 to 12 agent sessions, plus the owner's win-builder runs and the upload
(section 7). Phase 2 should come first, because it is the largest and decides the release's
timeline. Phase 1 can follow it or come in between. Everything else follows the order in
section 7.

---

## 2. What CRAN has today (measured S1091)

### 2.1 Check results for 2.0.0

Source: <https://cloud.r-project.org/web/checks/check_results_nprcgenekeepr.html>, "Last updated on
2026-10-29 04:57:35 CET". Times are seconds.

| Flavor | T install | T check | T total | Status |
|---|---:|---:|---:|---|
| r-devel-linux-x86_64-debian-clang | 21.80 | 512.62 | 534.42 | OK |
| r-devel-linux-x86_64-debian-gcc | 14.93 | 336.31 | 351.24 | OK |
| r-devel-linux-x86_64-fedora-clang | 19.00 | 366.47 | 385.47 | OK |
| r-devel-linux-x86_64-fedora-gcc | 15.00 | 356.45 | 371.45 | OK |
| r-devel-windows-x86_64 | 28.00 | 542.00 | 570.00 | OK |
| r-patched-linux-x86_64 | 25.87 | 476.21 | 502.08 | OK |
| r-release-linux-x86_64 | 20.65 | 473.13 | 493.78 | OK |
| r-release-macos-arm64 | 5.00 | 404.00 | 409.00 | OK |
| r-release-macos-x86_64 | 14.00 | 772.00 | 786.00 | OK |
| r-release-windows-x86_64 | 30.00 | 554.00 | 584.00 | OK |
| r-oldrel-macos-arm64 | 5.00 | 243.00 | 248.00 | OK |
| r-oldrel-macos-x86_64 | 16.00 | 580.00 | 596.00 | OK |
| r-oldrel-windows-x86_64 | 39.00 | 668.00 | 707.00 | OK |

"Additional issues: linux-arm64" (section 2.2).

- **Reverse dependencies:** none. `tools::package_dependencies("nprcgenekeepr", db = available.packages(), reverse = TRUE, which = "all")` returns an empty vector.
- **Dependencies:** every Imports and Suggests package is on CRAN. `Rlabkey` is at 3.5.0, and DESCRIPTION asks for `>= 3.2.0`.
- **Update frequency:** CRAN asks for updates no more often than every one to two months. 2.0.0 was published 95 days before this plan.

### 2.2 The linux-arm64 additional issue

Source: <https://github.com/r-devel/linux-arm64-checks/tree/HEAD/nprcgenekeepr> (`README.md`,
`00check.log`). That run was checking version 2.0.0:
<https://github.com/r-devel/linux-arm64-checks/actions/runs/40155622811>. AMD64 is OK. ARM64 gives
`checking tests ... ERROR`, with the summary `[ FAIL 4 | WARN 0 | SKIP 231 | PASS 3096 ]`. The
log shows only the last 13 lines of output:

```
  Expected `res$rows` to equal 3L.
  [1] 0 - 3 == -3
  all 3 founder records survive the read + QC
  ── Failure ('test_modInput_incomplete_final_line.R:81:3'): read.table upload path muffles incomplete-final-line, keeps rows ──
  Expected `res$errors` to equal 0L.
  [1] 1 - 0 == 1
```

Here is how the four failures line up with the test file. That file has not changed since 2.0.0
except for a path move in `6f87d91bf`.

- It has two tests: the `read.csv` upload at `:62-71` and the `read.table` upload at `:73-82`.
- Each test makes three checks:
  - the warning check (`:64`, `:75`), which passes;
  - the row count (`:68`, `:79`);
  - the error count (`:70`, `:81`).
- So the four failures are the row and error counts in both tests.

The upload therefore muffles the warning correctly. What differs is QC: it reports 0 records and
1 error for a three-founder file that passes everywhere else. That three-founder file is the
first four lines of `inst/extdata/examples/ExamplePedigree.csv`, written without a final newline.

**Hypothesis (unverified; Phase 1 tests it first).** Linux on ARM64 treats C's `char` as
unsigned, while Apple's ARM64 treats it as signed. That would explain why both macOS arm64
flavors are OK on CRAN and Linux arm64 fails. If so, a compiled dependency on the read or QC
path would compute something different, and date parsing is the first suspect. This is a guess
from the platform pattern. Nobody has reproduced the failure yet.

---

## 3. A CRAN-mode check of today's tree (measured S1091)

### 3.1 Today's tree against `v2.0.0`, on the same machine

Both trees were checked on this Mac (macOS arm64, R 4.6.1), with today's package library and the
same command. The `v2.0.0` tree is `git archive v2.0.0` extracted to a scratch folder. The load
average was between about 4 and 14 during the runs, so the absolute times run high. The ratios
compare like with like.

```r
options(repos = c(CRAN = "https://cloud.r-project.org"))   # dragon 1, section 8
devtools::check(pkg = "<tree>", document = FALSE, cran = TRUE, remote = TRUE,
                incoming = TRUE, args = "--timings", check_dir = "<scratch folder>",
                env_vars = c(NOT_CRAN = "false"), error_on = "never")
```

| Step (elapsed) | `v2.0.0` | HEAD | HEAD / v2.0.0 |
|---|---:|---:|---:|
| checking tests | 66 s | 309 s | 4.7 |
| testthat summary | `[ FAIL 0 \| WARN 0 \| SKIP 208 \| PASS 3210 ]` | `[ FAIL 0 \| WARN 10 \| SKIP 706 \| PASS 14895 ]` | 4.6 (PASS) |
| checking examples | 27 s | 32 s | 1.2 |
| re-building of vignette outputs | 18 s | 18 s | 1.0 |
| CRAN incoming feasibility (network) | 94 s | 47 s | (network) |
| everything else | 54 s | 74 s | 1.37 |
| whole `R CMD check` (devtools "Duration") | 4 m 19 s | 8 m 0 s | 1.85 |
| installed size (INFO, not a NOTE) | 5.7 MB | 7.5 MB | |
| `00check.log` `Status:` | 1 WARNING | 1 NOTE | |

- **`v2.0.0`'s WARNING is expected.** It is "Insufficient package version (submitted: 2.0.0,
  existing: 2.0.0)", plus one 404 URL (the GitHub path of
  `inst/extdata/example_nprcgenekeepr_config`). Today's tree no longer has that URL.
- **HEAD's NOTE** has two parts:
  - "Version contains large components (2.0.0.9000)", which is expected and goes away at the
    bump;
  - "Found the following (possibly) invalid DOIs: 10.1016/0040-5809(86)90007-1, from
    `man/markerParentageLikelihood.Rd`, Status 404" (Phase 3).
- **No URL problem** is reported for today's tree.
- **Examples:** 215 were timed and their elapsed times sum to 11.4 s. The slowest are
  `getGeneticDiversityStats` (2.5 s) and `countLoops` (2.4 s). None reaches CRAN's 5 s flag.
- **Installed size:**
  - `doc` 2.5 MB, mostly `a2interactive.html` at 2.08 MB;
  - `extdata` 2.4 MB, mostly `examples/example_sequence_genotypes.csv` at 1.22 MB, which is new
    since 2.0.0;
  - `help` 1.1 MB and `R` 1.0 MB.

  CRAN reports this as INFO and accepted 2.0.0 at 5.7 MB, so it is a watch item, not a blocker.
- **The 10 test warnings** are also in CI's test-coverage run. CRAN does not fail on them.

### 3.2 What this means for CRAN's 10-minute incoming check (an estimate)

The accepted 2.0.0 took 588 s on win-builder r-devel: tests 200 s, examples 80 s, vignettes 65 s,
and 243 s for everything else (`cran-comments.md`, "Test environments"). Scaling each step by the
section 3.1 ratios gives:

| Step | 2.0.0 on win-builder (measured) | 3.0.0 on win-builder (estimate) |
|---|---:|---:|
| tests | 200 s | 200 × 4.7 ≈ 940 s |
| examples | 80 s | 80 × 1.2 ≈ 95 s |
| vignettes | 65 s | 65 s |
| everything else | 243 s | 243 × 1.37 ≈ 333 s |
| **total** | **588 s** | **≈ 1,430 s (about 24 min)** |

Scaling only the test step gives about 1,320 s. **As the tree stands, CRAN's automatic incoming
check would reject 3.0.0 for time**, as it rejected the first 2.0.0 upload on 2026-07-16.

On the same estimate, the steps other than tests come to about 495 s on win-builder. That leaves
the CRAN-mode test step roughly 100 s there (about 30 s on this Mac) to stay under 600 s, and
less if we want a margin. These figures come from two machines and one ratio. Phase 2 replaces
them with a measurement (D4).

### 3.3 Where the test time goes (measured S1091)

Command: `Sys.setenv(NOT_CRAN = "false"); pkgload::load_all("."); testthat::test_dir("tests/testthat", reporter = "silent", stop_on_failure = FALSE)`,
with the times summed by file. The load average was 12 to 14, so the 389 s total runs above the
check's 309 s.

- **Total:** 456 files, 389 s. The top 10 files take 52% of it, the top 30 take 78% and the top
  50 take 88%.
- **The long tail is cheap.** 57 files take 1 s or more. The other 399 take 38.7 s together, and
  the 378 files under 0.5 s take 24.6 s.
- **The ten largest:**
  - `test_modSnapshotTrends.R` 36.7 s
  - `test_perfHarness.R` 34.9 s
  - `test_modMarkerGenetics.R` 22.1 s
  - `test_groupAddAssignEquivalence.R` 20.1 s
  - `test_positionMatingUnitForest.R` 16.4 s
  - `test_kinshipMemoryEquivalence.R` 16.3 s
  - `test_appServer_server.R` 14.3 s
  - `test_resolveEdgeNodeCollisions.R` 14.1 s
  - `test_convertRelationshipsEquivalence.R` 14.1 s
  - `test_makePedigreeMatingLayout.R` 12.8 s
- **The performance campaign's tests run on CRAN today.** Six of the top 25 are its harness and
  equivalence tests: `test_perfHarness.R`, `test_groupAddAssignEquivalence.R`,
  `test_kinshipMemoryEquivalence.R`, `test_convertRelationshipsEquivalence.R`,
  `test_founderStatsEquivalence.R` and `test_diagramSolverEquivalence.R`. Together they take
  92.9 s, 24% of the total. They compare new code with frozen copies (`helper-perfReference.R`),
  which is worth doing on CI but not on CRAN.
- **Caveat: this ran from the source tree.** `R CMD check` runs the tests from the installed
  copy, where repository files such as `NEWS.Rmd`, `_pkgdown.yml` and the guides are absent, and
  the tests that read them skip. Two examples measured here are `test_guideExportTables.R`
  (10.0 s; skip at `:145`) and `test_pkgdown_reference_config.R` (7.1 s; skip at `:31`). Phase 2
  re-ranks in the check's own layout before choosing.

So the time is concentrated. Skipping the 57 files of 1 s or more on CRAN would leave about 39 s
here, or about 31 s scaled to the check's run (309/389). That is the size section 3.2 allows.
Phase 2 decides the exact list.

### 3.4 Measured on win-builder (S1094)

| Step | 2.0.0, R-devel | uncut `2d3dc2f26`, R-release 4.6.2 | uncut, R-devel r90783 | cut `9fa5df13c`, R-devel r90783 |
|---|---:|---:|---:|---:|
| Check time | 588 s | 1,384 s | 1,722 s | **652 s** |
| tests | 200 s | 15 min | 20 min | 156 s |
| examples | 80 s | 108 s | 113 s | 109 s |
| re-building vignettes | 65 s | 40 s | 67 s | 67 s |
| R code check | | 69 s | 81 s | 81 s |
| PDF + HTML manuals | | 89 s | 69 s | 70 s |

- **The steps other than tests took about 496 s** for the cut tree (522 s uncut; 480 s on
  R-release), so 540 s leaves the tests about 45 s there and 600 s about 105 s. Run-to-run
  noise is about 30 s. On this Mac the cut tree's CRAN-mode check now matches `v2.0.0`'s (2 m
  49 s against 2 m 55 s, same command, load 5-6; tests 36 s against 65 s, examples 33 s
  against 23 s, R code 16 s against 10 s).
- **Errors:** the uncut tree's two wall-clock benchmarks (`skip_on_cran()` since S1092); the cut
  tree's `test_readWithFinalNewline.R:46`, where `cat()` appended `"\r\n"` on Windows (fixed
  S1094 with a binary append).
- **NOTEs:** the version; "de" (`DESCRIPTION:37`); the thoughtco.com URL, status 402 (2.0.0's
  note already explained it, `cran-comments.md:47-49`); the DOI (Phase 3); the
  `getGeneticDiversityStats` example, 15.2 s.

The levers left, measured here; the R-devel savings are estimates scaled from the table:

| Lever | Measured | R-devel saving | Cost |
|---|---|---:|---|
| `getGeneticDiversityStats` example (`R/getGeneticDiversityStats.R:69-84`) | 2.6 s here, nearly all `reportGV(ped, guIter = 10L)` on 3,694 rows; the call itself 0.02 s | about 14 s | a smaller input |
| `findLoops()`/`countLoops()` back to 2.0.0's speed | 0.51 to 1.04 s and 0.61 to 1.20 s since `v2.0.0`; 88% of `findLoops()` is `.getAncestorsOnPath()`, 46% its `%in%` path check (S783's cycle guard) | about 14 s (4 examples 19.9 s there, 2 vignette chunks) | a cheaper cycle check, same results |
| skip 10 / 20 / 26 / 40 more test files | 8.4 / 12.8 / 14.8 / 18.2 s of the 30.4 s CRAN-run sum here | about 40 / 65 / 75 / 90 s | 10 / 12 / 13 / 26 exports left with no CRAN-run test |
| `a2interactive` vignette | 11.1 s of the 19 s step here; five chunks 7.4 s | part of 67 s | changes the tutorial's numbers |

The 10-file skip strands `appServer`, seven module servers (`modGvAndBgDescServer`,
`modMarkerGeneticsServer`, `modMatePairServer`, `modSnapshotTrendsServer`,
`modORIPReportingServer`, `modGeneticDiversityServer`, `modGeneticValueServer`),
`backfillColonySnapshots` and `previewBackfillSupport` (S1094 traced every export over the
CRAN-run files; all 236 are called today).

### 3.5 The second cut, measured on win-builder (S1095)

The owner picked "Example+loops+skip 315" and kept the 540 s target. Strict TDD: RED
`8c5d253f5`; GREEN `51cf42616`, `7588d7ebd`, `3478dfc81`; REFACTOR `a10594f15`, `4072b38d9`.

- **The `getGeneticDiversityStats` example** reads `qcPed`, its `kinship()` and the stored
  `qcPedGvReport$report`: 3.2 s to 0.04 s here (gate `test_getGeneticDiversityStatsExample.R`).
- **The ancestor walk** (`.getAncestorsOnPath()`, `R/getAncestors.R`) looks a text id up once
  with `ptree[[id]]`. The twofold slowdown since 2.0.0 was `id %in% names(ptree)` at every
  step, not the cycle check's path test. `findLoops()` went 1.01 to 0.37 s and `countLoops()`
  1.31 to 0.50 s on the example, with identical results (guard
  `test_getAncestorsEquivalence.R`; opt-in budget `test_perfBudget_loops.R`).
- **The skip list** names 382 files, so a CRAN check runs 79 test files that between them call
  all 236 exports. A run-time trace of every export over the CRAN-run files of the installed
  package chose them: slowest first, a file is skipped only while every export is still reached.
  Skipping the slowest files without that rule strands exports (the slowest 10 / 20 / 26 / 40
  strand 10 / 12 / 13 / 26), because the slowest file is the only CRAN-run test that starts the
  app.

| Step | `9fa5df13c`, R-devel (S1094) | `4072b38d9`, R-devel (S1095) | this Mac, CRAN mode, S1094 / S1095 |
|---|---:|---:|---:|
| Check time | 652 s | **564 s** | |
| tests | 156 s | 56 s | 36 s / 12 s |
| examples | 109 s | 90 s | 33 s / 28 s |
| re-building vignettes | 67 s | 66 s | 19 s / 17 s |
| R code check | 81 s | 89 s | 16 s / 17 s |
| PDF + HTML manuals | 70 s | 78 s | |

- **The tests and examples saved what the scaled estimate said** (119 s against about 121 s).
  The steps nothing changed came in about 32 s slower than in S1094's run (R code +8 s, manuals
  +8 s, the rest +16 s), which is the run-to-run noise. Hence 564 s, not the 506 s of the
  picker's preview, which held those steps fixed.
- **NOTEs:** the version, "de", the thoughtco.com URL (status 402) and the DOI, as before. The
  example NOTE is gone.
- **Against CRAN's limit:** 564 s is 36 s under 600 s. 2.0.0's own CRAN pretest read 604 s and
  was not rejected; the gate fires on the log's "Overall checktime ... > 10 min" (Learning 367).
  The 540 s target (D4 = A) is the owner's 10% margin, missed by 24 s.
- **Levers left** (measured here; the R-devel savings are scaled estimates):
  - three more help examples run `findLoops()` on the 3,694-animal example (`createPedTree`,
    `examplePedigree`, `findLoops`; about 0.5 s each here): a smaller pedigree, about 5 s;
  - the tutorial's `full-geneticValue` chunk (2.3 s here, about 8 s there; fewer iterations
    change its printed numbers);
  - its two `shrinkPedigree()` chunks (2.5 s here, about 9 s there; 98% of the time is the
    third trim, so this is a rewrite);
  - a smaller set of the 79 test files that still calls every export (chosen by time rather
    than the greedy order; not measured).

### 3.6 The third cut: two packages loaded when first needed (S1096)

The owner picked "Load 2 packages later" over accepting 564 s or also cutting the loop
examples. Strict TDD: RED `005369eba`; GREEN `2383292f2` (Matrix), `8b1b8fd90` (ggplot2);
REFACTOR `20b38f346`; NEWS `c10391571`.

- **Where the examples step's time went.** On win-builder (`a1AV26256EC9`) the 215 examples
  add up to 26.2 s of the 90 s step (`nprcgenekeepr-Ex.timings`), and the examples process
  ran 89.4 s (`-Ex.Rout`). The other 63 s is `cleanEx()`, which R runs before each example:
  under `--as-cran` (`_R_CHECK_CONNECTIONS_LEFT_OPEN_`) it calls `showConnections()`, which
  calls `gc()`. A full collection here took 81 ms with the package loaded and 8 ms in bare R.
  Nearly all of it was the packages loaded with it: Matrix 30 ms, ggplot2 20 ms, the six app
  packages 5 ms, the package's own code about 1 ms.
- **The change.** No example uses Matrix, and the first that uses ggplot2 is the 140th of 215
  (a trace of their entry points). Neither is loaded with the package now:
  `kinship(sparse = TRUE)` loads Matrix and a plot loads ggplot2 when first needed.
  `import(Matrix)` had also routed 94 functions' calls of `which()`, `unname()`, `mean()`,
  `t()`, `diag()`, `rowSums()` and others through Matrix's generics. For a dense matrix base R
  gives the same answer. Two places read a sparse matrix and now name Matrix's version:
  `meanKinship()` (`Matrix::colMeans()`) and `kinshipGeneral()`'s twin step
  (`Matrix::diag()`). The 11 kinship-matrix exports, probed with a dense and a sparse matrix
  on both builds, behave as before (7 fail on a sparse one, before and after).
- **Gates.** `test_packageLoadLight.R`: the NAMESPACE imports nothing from either, and a
  fresh R loading the installed package leaves both unloaded. It skips under `load_all()`,
  which loads every Imports package, and under covr; CRAN skips the file. Guards:
  `meanKinship()` of a sparse matrix (`test_meanKinship.R`) and `kinshipGeneral()` with
  `sparse = TRUE` and MZ twins (`test_kinship.R`).

| `--as-cran` examples run, this Mac, alternating | before | after |
|---|---:|---:|
| the examples process | 25.9 s | 17.1 s |
| `cleanEx()`, 216 calls | 18.9 s | 10.6 s |
| the examples themselves | 5.8 s | 6.1 s |
| `library(nprcgenekeepr)`, fresh session | 0.92 s | 0.39 s |

**Measured on win-builder R-devel, the same tarball (`c10391571`) twice:**

| Step | S1095 `a1AV26256EC9` | S1096 `nTbGkc6hP4VM` (01:34 CDT) | S1096 `6tYpEEb12W8l` (09:49 CDT) |
|---|---:|---:|---:|
| Check time | 564 s | 617 s | **520 s** |
| examples | 90 s | 65 s | 60 s |
| tests | 56 s | 86 s | 51 s |
| R code check | 89 s | 94 s | 81 s |
| re-building vignettes | 66 s | 71 s | 64 s |
| PDF + HTML manuals | 78 s | 75 s | 70 s |
| incoming feasibility | 21 s | 22 s | 55 s |
| steps with no time shown | 164 s | 204 s | 139 s |
| examples process, elapsed / CPU | 89.4 / 84.5 s | 64.2 / 59.4 s | 59.8 / 59.0 s |
| tests process, elapsed / CPU | 54.4 / 50.0 s | 83.6 / 54.2 s | 49.6 / 48.9 s |

- **The cut is steady; the total is not.** Both readings show the examples process using about
  59 s of CPU against 84.5 s before, as the scaled estimate said (about 27 s). The same tarball
  read 617 s and then 520 s: in the first, the tests did 4 s more work and took 29 s longer
  (1.54 s of elapsed time per CPU second against 1.09), and the steps with no time shown took
  40 s more, so win-builder was busier. Run-to-run noise on one tarball is about 100 s, not the
  30 s section 3.4 assumed.
- **Owner ruling (S1096): Phase 2 is DONE on the 520 s reading.** The NOTE is unchanged: the
  version, "de", the thoughtco.com URL (status 402) and the DOI (Phase 3).
- **Windows on CI:** R-CMD-check's windows-latest leg read the examples step at 57 s (S1095,
  run `40993029586`) and 38 s (S1096, run `41012406472`), and its tests ran the new fresh-R
  block (`PASS 16670` = 16,662 + 8).
- **Levers left, if Phase 8's reading is high:** the three `findLoops()` help examples and
  `countLoops` (8.6 s of examples on win-builder), and the tutorial's `full-geneticValue` and
  two `shrinkPedigree()` chunks (about 20 s there; their printed numbers change).

---

## 4. Evidence-based inventory

### 4.1 Where the version number lives (for Phase 6)

From `git grep -n -F '2.0.0.9000'` and `git grep -n -E 'getVersion\(|packageVersion\("nprcgenekeepr"\)|development version'`
over the tracked tree (the methodology ledgers and dated audit and planning records excluded).

**Change at the bump:**

| Place | Today | At the bump |
|---|---|---|
| `DESCRIPTION:4` | `Version: 2.0.0.9000` | `Version: 3.0.0` |
| `NEWS.Rmd:14` | `# nprcgenekeepr 2.0.0.9000 (development version)` | `# nprcgenekeepr 3.0.0 (YYYYMMDD)`, the date the bump lands, in the format of `NEWS.Rmd:613` `# nprcgenekeepr 2.0.0 (20260721)`; then re-knit `NEWS.md` (its `:5`) |
| `README.md:8` | `Version 2.0.0.9000 (2026-10-11)` | generated by `README.Rmd` from `getVersion()`; reinstall the package first, then re-render (Learning 376) |
| `CITATION.cff:11` | `version: 2.0.0` | `version: 3.0.0` (hand edit; `cffr` is not installed, section 4.7) |
| `methodology/ROADMAP.md:11` | "the package is now at 2.0.0.9000" | the released state |
| `BACKLOG.md:8-14` | the "Move the version to 3.0.0" item | removed in the same commit (completed-item checklist) |
| `BACKLOG.md:207` | papers item: "`DESCRIPTION` reads 2.0.0.9000 today" | updated: the release it waits on exists |
| `tests/testthat/test_docsAuditSixRulings.R:80` | SR3 requires the phrase "Move the version to 3.0.0 just before release" in `BACKLOG.md` | move the phrase to that block's `gone` list. **This is a trap:** removing the BACKLOG item without this edit fails the test |

**Leave alone.** These record the version under which data or a fixture was made, or are dated
records:

- `inst/extdata/examples/example_snapshot_history.csv:4-5`, the shipped example history;
- the test fixtures `test_appendColonySnapshot.R:17`, `test_calcSnapshotDeltas.R:49` and
  `test_plotSnapshotTrends.R:35`. Also `test_calcSnapshotDeltas.R:162,170`, which read the shipped
  history through `validatedSnapshotHistory()` and not the live version;
- `docs/research/pedigree-diagram-package-split-scoping-2026-09-02.md:60`;
- every NEWS block below the newest;
- the dated audit and planning documents.

**Follow the live version on their own.** Run these after the bump; each should stay green:

- `test_getVersion.R`
- `test_appUI_version.R:11`
- `test_createColonySnapshot.R:55`
- `test_ancestryOverrides.R:222`
- `test_buildMhcExportManifest.R:50`
- `test_modCrossCenterIdentity.R:374`

**No `inst/CITATION` and no `codemeta.json` exist.** CRAN builds the citation from DESCRIPTION.

### 4.2 `NEWS.Rmd` (for Phases 5 and 6)

The development block is `NEWS.Rmd:14-612`, 599 lines. The whole 2.0.0 block is 185 lines
(`:613-797`). The development block's sections:

| Lines | Count | Section |
|---|---:|---|
| 22-95 | 74 | Pedigree Diagram |
| 96-121 | 26 | Kinship & Pedigree Calculations |
| 122-176 | 55 | Marker Genetics |
| 177-201 | 25 | MHC Haplotype Reporting |
| 202-219 | 18 | Cross-Center Identity Matching |
| 220-252 | 33 | Genetic Value Analysis |
| 253-342 | 90 | Breeding Group Formation |
| 343-372 | 30 | Mate Pair Analysis |
| 373-386 | 14 | De-Identified Export |
| 387-421 | 35 | Longitudinal Monitoring |
| 422-437 | 16 | Speed and Memory |
| 438-612 | 175 | General Fixes |

Two guards read this block:

- **`test_newsReleaseState.R`** (`newsTopBlock()` reads the newest heading, whatever its name, so
  the retitle in Phase 6 does not break it). It forbids in-progress milestone phrases and holds
  the Pedigree Diagram section's style rules.
- **`test_newsGeneralFixesGrouped.R`** holds the seven "Fixed (area):" bullets (S1024).

`NEWS.md` is generated from `NEWS.Rmd`. Never edit `NEWS.md` by hand (2.0.0 dragon 3).

### 4.3 The old cover notes (the owner's S1091 suggestion; for Phase 3, D1)

Nine `cran-comments` files are tracked at the root:

| File | Date |
|---|---|
| `20200415_cran-comments.md` | 2020-04-15 |
| `20200510_cran-comments.md` | 2020-05-10 |
| `20200517_cran-comments.md` | 2020-05-17 |
| `20201107_cran-comments.md` | 2020-11-07 |
| `20210324_cran-comments.md` | 2021-03-24 |
| `20210330_cran-comments.md` | 2021-03-30 |
| `20241220_cran-comments.md` | 2024-12-20 |
| `20250504_cran-comments.md` | 2025-05-04 |
| `cran-comments.md` | the live note, last changed `db54d3257` (2026-07-17, the `v2.0.0` commit) |

What refers to them, from `git grep -n -I -E '[0-9]{8}_cran-comments|cran-comments'`:

- `.Rbuildignore:10` (`^cran-comments\.md$`) and `:11-13` (the comment and the regex
  `^[0-9]+_cran-comments\.md$` that covers every dated file);
- `.gitignore:5`, a dead line: `^cran-comments\.md$` is a regex in a glob file, matches no
  file, and the live note is tracked anyway;
- dated audit and planning records, which stay as written.

Nothing else reads the files, and no test does.

**Constraints for any move:**

- `devtools::submit_cran()` reads `cran-comments.md` at the package root, so the live note stays
  there.
- A new `cran/` folder needs a `^cran$` line in `.Rbuildignore`. Without it `R CMD build` ships
  the folder and the check NOTEs a non-standard top-level directory (2.0.0 dragon 11, S327).
- `.Rbuildignore` lines are perl regexes: no unbalanced parenthesis, not even in a comment
  (2.0.0 dragon 5).

**Not part of D1, FYI only:** `revdep/` at the root holds untracked local leftovers from an
earlier `revdepcheck` run (`cran.md`, `failures.md`, `problems.md`, `data.sqlite`,
`checks.noindex/`, `library.noindex/`). It is build-ignored (`^revdep$`). The package has no
reverse dependencies, so nothing regenerates it.

### 4.4 Suggests packages used in tests and code (for Phase 4, D2 and D6)

Method:

- Count the test files that name each Suggests package with `pkg::`, `library(pkg)` or
  `require(pkg)`.
- Count how many of those files also call `skip_if_not_installed("pkg")` or
  `requireNamespace("pkg")`.
- Run the same grep over `R/` and `vignettes/*.Rmd`.

These are grep counts, not a measured failure.

| Package | Test files | Guarded in-file | 2.0.0 test files |
|---|---:|---:|---:|
| `withr` | 47 | 0 | 16 |
| `mockery` | 20 | 0 | 10 |
| `shinytest2` | 12 | 0 | not measured (opt-in E2E tier) |
| `chromote` | 8 | 0 | not measured (opt-in E2E tier) |
| `kinship2` | 7 | 0 | 0 |
| `htmltools` | 4 | 0 | 0 |
| `yaml` | 2 | 0 | 0 |
| `htmlwidgets`, `rmarkdown`, `shinyBS` | 2 each | 0 | not measured |
| `dplyr` | 1 | 0 | not measured |

- **`R/` has one unguarded Suggests package: `shinyBS`.**
  - Every `kinship2::`, `htmlwidgets::` and `withr::` in `R/` is in a comment or roxygen text
    (`R/autoIdFormat.R:87`, `R/comparePedigreeStructure.R:16,18`, `R/computeGenomicROH.R:132`,
    `R/drawPedigreeDiagram.R:23,44`, `R/makePedigreeDiagramData.R:715,870`,
    `R/shrinkPedigree.R:10`).
  - The live code is in the Summary Statistics module: `R/modSummaryStats.R:17`
    (`shinyBS::popify()` in `.exportButtonPopover()`) and `:356`, `:365`, `:374`
    (`shinyBS::addPopover()`).
  - The only `requireNamespace("shinyBS")` is `R/zzz.R:5`, which guards a resource path in
    `.onLoad()`, not these calls. `runGeneKeepR()` checks for nothing.
  - `v2.0.0` had the same unguarded calls (`R/modSummaryStats.R:55-98` there) with `shinyBS` in
    Suggests. `shinyBS` was added to Imports in 2019 (`0e89fe35f`) and is in Suggests today.
  - **Measured S1098:** the whole app fails to start without `shinyBS`, in today's code and in
    released 2.0.0. `appUI()` stops with "there is no package called 'shinyBS'".
- **Some guards live in helpers.** `helper-comparePedigreeStructure.R:45` guards `kinship2`, and
  `helper-shinytest2.R:738` guards `chromote`. The in-file count above misses those.
- **2.0.0 already shipped unguarded tests.** It had 10 `mockery` and 16 `withr` test files (25
  files; one uses both) with no guard, and CRAN lists no noSuggests issue for it. So the new exposure is mainly `kinship2`
  and `htmltools`. The faithful measurement is Phase 4b's check run, not this grep.

### 4.5 Help pages with `\dontrun{}` (for Phase 3)

8 of 270 Rd files: `getDemographics`, `getLkDirectAncestors`, `getLkDirectRelatives`,
`setLabKeyDefaults` (all need a live LabKey server), `runGeneKeepR`, `runModularApp` (launch the
app), `readKinshipOverrides` (`man/readKinshipOverrides.Rd:42`) and `readTwinRelations`
(`man/readTwinRelations.Rd:38`). The last two are the ones to review. CRAN reviewers ask for
`\donttest{}` or a runnable example when code can run in under 5 s. 2.0.0 was accepted with all
eight, so this is a should-do, not a blocker. **S1097:** those last two now run, so 6 of 270 remain.

### 4.6 The built tarball (measured S1091 from the section 3.1 build)

`nprcgenekeepr_2.0.0.9000.tar.gz` is 3,494,453 B. Its top level holds only:

- `DESCRIPTION`, `LICENSE`, `NAMESPACE`, `NEWS.md`, `README.md`;
- `R/`, `build/`, `data/`, `inst/`, `man/`, `tests/`, `vignettes/`.

No stray root file ships today. `inst/` holds `doc/`, `extdata/`, `shinytest/`, `testdata/`,
`WORDLIST` and `www/`. The installed size is in section 3.1.

### 4.7 Tools on this machine (S1091)

| Tool | Installed | Needed for |
|---|---|---|
| `urlchecker`, `gitcreds` | yes | Phase 7; R-hub's GitHub token |
| `rhub` | **no** | Phase 8's R-hub v2 runs (`.github/workflows/rhub.yaml` exists) |
| `cffr` | no | not needed (hand-edit `CITATION.cff:11`) |
| `revdepcheck` | no | not needed (no reverse dependencies) |
| LaTeX (`pdflatex`, `xelatex` in `/Library/TeX/texbin`) | yes | Phase 7's PDF manual |
| Docker | yes: server 29.8.2, `aarch64` Linux, images `r-base:4.6.1` and `rocker/r-ver:4.5.3` already pulled | Phase 1's Linux/ARM64 reproduction |

Install `rhub` into a scratch library rather than renv, so `renv.lock` stays as it is. If it ever
goes into renv, use `renv::snapshot(dev = TRUE)` (`CLAUDE.md`).

### 4.8 Guards that a release edit can trip

- **`test_docsAuditSixRulings.R:80`.** Removing the version item from `BACKLOG.md` (section 4.1)
  trips it.
- **`test_descriptionCopies.R`.** DESCRIPTION's Description paragraph is copied by hand into
  three more places: `man/nprcgenekeepr-package.Rd`, `_pkgdown.yml` (`home: description:`) and
  `CITATION.cff` (`abstract:`). If the Description field changes, all four change together or
  this test fails.
- **`test_newsReleaseState.R` and `test_newsGeneralFixesGrouped.R`** (section 4.2).
- **The context-budget and ledger tests** (`test_contextBudgetLedgers.R`,
  `test_handoffsReceiptPlacement.R`) on every close-out.

---

## 5. Phases

Each phase lists: **why**, **DONE**, **steps**, **TDD**, **verify**, **surface** (where the DONE
criterion is shown, and what that surface cannot enforce), and **session boundary**. The
build-equivalent is in `CLAUDE.md` "Build / Test / Verify". The fast single-file test and the
clean regression read both set `NOT_CRAN = "true"` and run `load_all()` first.

### Phase 1. The linux-arm64 failure: reproduce, name the cause, fix (strict TDD)

- **Why:** CRAN shows the failure on the package's page today (section 2.2). A new version that
  still fails it invites a request to fix by a deadline. That is how 1.0.8 came to be archived in
  2025 ("issues were not corrected in time").
- **DONE:** `test_modInput_incomplete_final_line.R` passes in a Linux/ARM64 R session; the cause
  is named (package code, a test assumption, or a dependency); and the full suite on macOS is
  still 0 failed and 0 errors.
- **Steps:**
  1. Reproduce. Run a `linux/arm64` container from `r-base:4.6.1` on this Mac (Docker runs it
     natively, section 4.7). Mount the repository read-only. Install the package, its
     Imports and `testthat`, and run only this test file with `NOT_CRAN=false`, as CRAN does. If R 4.6.1 does
     not reproduce it, CRAN's job runs R-devel. Try an R-devel arm64 image, or a GitHub Actions
     job on an `ubuntu-24.04-arm` runner with `r-lib/actions/setup-r` set to `r-version: devel`.
     That runner's availability is unverified; check it when the phase starts.
  2. Narrow it down. Inside the container, compare each stage with macOS: the upload's
     `read.csv` and `read.table` output, then QC's error list (`qcStudbook(reportErrors = TRUE)`).
     Test the `char` signedness hypothesis (section 2.2) first and discard it if wrong.
  3. Fix at the cause. A package bug gets a RED unit test at the failing function. A test that
     assumes something platform-bound is corrected in the test. A dependency bug gets a
     workaround with a comment and a line in `cran-comments.md`.
- **TDD:** RED is the failure reproduced in the container, like S1090's "RED is the red run".
  If the cause is in package code, add a unit test at the cause that fails there. GREEN is the
  smallest fix. REFACTOR follows as usual. Each gate goes to the owner.
- **Verify:** the one file in the container, both `NOT_CRAN=false` and `true`. Then on macOS:
  the clean regression read, `lintr::lint_package()` and `devtools::check()`.
- **Surface:** a Linux/ARM64 container is the same operating system and processor family as
  CRAN's failing job. It cannot reproduce CRAN's exact R-devel build or machine. CRAN's own
  linux-arm64 job checks only published versions, so the fix is confirmed on CRAN only after
  3.0.0 is out (Phase 10). Say so in `cran-comments.md`.
- **Session boundary:** one session to reproduce and name the cause. If the fix is in package
  code and the session runs long, the TDD fix is a second session.
- **Effort:** M. Installing the Imports from source in a fresh container may take most of an
  hour. Keep the container image for Phase 7.

### Phase 2. Cut the CRAN-mode test time (the critical path; strict TDD)

- **Why:** as built, 3.0.0 would exceed CRAN's 10-minute incoming limit by a wide margin
  (section 3.2). This is the largest piece of release work.
- **DONE (D4 = A):** win-builder r-devel's "Check time in seconds" for the cut tree is at or
  under 540 s, measured, not estimated. **(D4 = B):** the CRAN-mode test step is at or under
  30 s on this Mac, with the win-builder confirmation left to Phase 8. Either way:
  - each file skipped on CRAN is listed with its CRAN-mode time;
  - every exported function is still exercised by at least one test that CRAN runs;
  - the `NOT_CRAN=true` suite runs the same tests as before the phase.
- **Steps:**
  1. **(D4 = A) Calibrate.** The owner uploads today's tree once with
     `devtools::check_win_devel()` (about 30 minutes; the results go by email to the
     maintainer). Its `00check.log` gives each step's time on the machine that enforces the
     limit. That replaces section 3.2's estimate and sets the exact test budget.
  2. **Re-rank by file in the check's own layout** (section 3.3, caveat). Use S1090's recipe:
     - `R CMD INSTALL --no-docs --install-tests --library=<scratch> .`;
     - then, outside the repository, with `R_LIBS=<scratch>:<renv lib>`,
       `RENV_CONFIG_AUTOLOADER_ENABLED=false` and `NOT_CRAN=false`, run
       `testthat::test_dir("<scratch>/nprcgenekeepr/tests/testthat", package = "nprcgenekeepr", load_package = "installed", reporter = "silent", stop_on_failure = FALSE)`;
     - sum `real` by file;
     - read `uptime` first, and repeat if the load is high.
  3. **Put `skip_on_cran()` at the top of the slowest files** until the budget is met. Start
     with the performance campaign's harness and equivalence tests (section 3.3), then the
     Shiny-module and layout files at the top of the ranking.
     - Never lower iterations or fixture sizes in a way that changes a computed number (2.0.0
       dragon 2).
     - Then list the exported functions whose every test now skips on CRAN, and keep or add one
       fast test for each.
  4. Re-run the section 3.1 command and read its timings. If D4 = A, a second
     `check_win_devel()` confirms the result before Phase 6.
- **TDD:** test-only. RED is the measured over-budget run: the calibration log, or the section 3
  run. GREEN is the skips plus any fast test added for an otherwise-uncovered export. Those
  fast tests follow RED, GREEN, REFACTOR on their own: they must pass, and must fail with the
  function stubbed out.
- **Verify:**
  - the section 3.1 command;
  - the clean regression read with `NOT_CRAN=true`, where the `PASS` count is unchanged;
  - `lint_package()`;
  - CI green (it runs with `NOT_CRAN=true`, so the skipped files still run there).
- **Surface:** this Mac gives ratios. The 10-minute limit is enforced only on win-builder
  r-devel, which is why D4 = A measures there at the start and end of this phase instead of
  first meeting the limit at Phase 8.
- **Session boundary:** one session for steps 2 to 4 with per-file skips; the owner's
  calibration upload can happen before it or during it. Two sessions if the export-coverage
  check finds gaps that need new fast tests. **Effort L.**

### Phase 3. Static hygiene (one session; metadata and help text)

**DONE (S1097, D1 = A; strict TDD, `tests/testthat/test_cranHygiene.R`).** The DOI is now
`10.1016/0040-5809(86)90006-7`, and the local CRAN-mode check's incoming NOTE no longer lists it. The eight dated notes
are in `cran/archive/`, kept out of the tarball by `^cran$`. The `readKinshipOverrides()` and `readTwinRelations()`
examples run on a temporary file; a CRAN check still runs 216 examples, since pages with `\dontrun{}` were already
counted, so they add 0.001 to 0.002 s each. The tarball's top level is exactly section 4.6's 12 entries. That
check's NOTE now holds the version and `api.reuse.software` ("Could not resolve host", a one-time lookup failure; the
address returned HTTP 200 when tried again the same hour). **Run `devtools::run_examples()` after a check, or delete its `Rplots.pdf`
first:** a check that follows it NOTEs that file at the top level (found S1097; relevant to Phase 7).

- **Why:** each item below is a NOTE, a reviewer request or the owner's request.
- **DONE:** these items, each verified:
  1. **The DOI.** `R/markerParentageLikelihood.R:131` cites `\doi{10.1016/0040-5809(86)90007-1}`.
     doi.org answers "handle not found" (response code 100). Crossref's record of the cited
     paper (Meagher and Thompson 1986, *Theoretical Population Biology* 29(1):87-106) has
     `10.1016/0040-5809(86)90006-7`. Correct it, run `devtools::document()`, then `git status`
     (restore `man/nprcgenekeepr-package.Rd` if roxygen rewrites it).
  2. **The old cover notes, per D1.** If moving: `git mv` the eight dated files into
     `cran/archive/` and add `^cran$` to `.Rbuildignore`. Replace `.Rbuildignore:11-13` with
     one comment line and keep `^[0-9]+_cran-comments\.md$`, so a dated note left at the root
     still never ships. Delete the dead `.gitignore:5` line. The live `cran-comments.md` stays
     at the root, and its 2.0.0 text is archived in Phase 8, just before it is rewritten.
  3. **The two `\dontrun{}` pages** (section 4.5): make them runnable examples on a temporary
     file, or keep `\dontrun{}` and write down why.
  4. **A root-listing check** against `.Rbuildignore` (2.0.0 dragon 11): build, then
     `tar tzf <tarball> | cut -d/ -f2 | sort -u` shows only the section 4.6 entries.
- **TDD:** help text, metadata and file moves have no production-logic test surface. The DOI is
  verified by the incoming-feasibility check, which must no longer list it. Any example that
  becomes runnable must pass `devtools::run_examples()`. If D1 adds a guard (for example "no
  dated cover note at the root"), it follows RED, GREEN, REFACTOR.
- **Verify:** the section 3.1 command (incoming NOTE shows no DOI), `devtools::run_examples()`,
  the tarball listing, and the tests that read `.Rbuildignore`. S1091 found four, from
  `git grep -n '.Rbuildignore' -- tests/testthat` with comment lines dropped:
  `test_docsAuditLooseEnds.R`, `test_perfHarness.R`, `test_rbuildignore.R` and
  `test_workflowPathsIgnore.R`. Twenty more mention it only in comments. Print that grep whole;
  never cut it with `head`.
- **Surface:** local. CRAN's incoming DOI check runs the same code (`tools:::.check_package_CRAN_incoming`)
  over the network, so a clean local run is faithful for the DOI. The listing is
  machine-independent.
- **Session boundary:** one session.

### Phase 4. Suggests packages used conditionally (4a always; 4b if D2 = A)

- **Why:** *Writing R Extensions* asks that Suggests packages be used conditionally. A default
  `install.packages("nprcgenekeepr")` installs Depends and Imports, not Suggests. CRAN also runs
  a check with the Suggests packages unavailable, after publication, and emails a deadline if
  it fails (section 4.4).
- **4a. `shinyBS` in package code (strict TDD; always):**
  1. **Measure.** Install the package into a scratch library that lacks `shinyBS`, then build
     `appUI()` and `modSummaryStatsUI()` there. Record whether the app or only the tab fails,
     and the error text.
  2. **RED.** Add a guard test: every package that `R/` code calls with `pkg::`, outside
     comments, is in Imports, or the call sits under `requireNamespace("pkg")`. It fails on
     `R/modSummaryStats.R:19,355,364,373`. Skip it with `rSourceAvailable()`
     (`tests/testthat/helper-rSource.R`), as every whole-`R/` scan does since S1090.
  3. **GREEN per D6:**
     - **(A)** move `shinyBS` from Suggests to Imports;
     - **(B)** guard the four calls, so the tab draws plain buttons with no popovers when
       `shinyBS` is absent.
  4. **REFACTOR** as usual.

  **DONE:** the guard test passes, and the step 1 measurement shows the app working without
  `shinyBS` (B), or `shinyBS` installed by default (A).
- **4b. noSuggests (if D2 = A):**
  1. Run the section 3.1 command with `env_vars = c(NOT_CRAN = "false",
     `_R_CHECK_DEPENDS_ONLY_` = "true")`. Confirm in *R Internals* (§ Tools) exactly what that
     variable leaves installed before reading the result.
  2. Guard each failing file with `skip_if_not_installed()`, at the top of the file or in the
     helper it uses.

  **DONE:** that check passes tests, examples and vignettes, or the owner rules the remaining
  failures acceptable. **TDD:** test-only. RED is the failing run; GREEN is the guards.
- **Surface:** local is faithful for "which code needs which package". It cannot show CRAN's
  exact noSuggests machine.
- **Session boundary:** one session for 4a and 4b together; 4a alone if D2 = B.
- **DONE (S1098; D6 = A, D2 = A).** Measured first: without `shinyBS` the whole app fails to start,
  in today's code and in 2.0.0 (section 4.4). `shinyBS` moved from Suggests to Imports, which is now
  20 non-base packages and draws no NOTE. `test_packageCallsDeclared.R` is the guard
  (`helper-packageCalls.R` reads `R/` with R's parser; base packages and this package are exempt, as
  R's check exempts them). With Suggests absent, the check went from 2 ERRORs to `Status: OK`,
  `[ FAIL 0 | WARN 0 | SKIP 76 | PASS 1863 ]` at GREEN. The fixes differ from step 2 above: the
  `makeRelationClassesTable()` example now uses base R, and the two vignettes style their 7 tables
  only when `kableExtra` is installed (owner pick; a normal build's tables are unchanged, plain
  otherwise). No `skip_if_not_installed()` was owed, because testthat already skips a test on a
  missing package (`{mockery} is not installed (22)`).
  **The step 1 command is not faithful on this Mac** (dragon 9): run it under a scratch R home whose
  `library` holds only the 29 base and recommended packages. Build it from symlinks to
  `R.home()`'s entries, except a copy of `bin/R` with `R_HOME_DIR` pointed at the scratch folder.
  Build the tarball with the normal R, then check it with `R_LIBS` naming the renv library. That
  surface shows which code needs which package on macOS with R 4.6.1, in about 2 minutes. It cannot
  show CRAN's noSuggests machine, whose result comes after publication (Phase 10).

### Phase 5. NEWS release pass (per D3)

- **Why:** NEWS states the finished release against 2.0.0, in plain words (memory: NEWS.Rmd
  states release state, not milestones). The block is 599 lines (section 4.2).
- **DONE (D3 = B):** the three largest sections are condensed: General Fixes (175 lines),
  Breeding Group Formation (90) and Pedigree Diagram (74). The owner approves the text section by
  section, and both NEWS guards pass. **(D3 = A):** nothing here; Phase 6 only retitles.
- **Steps:** propose replacement text one section at a time (the owner writes or approves
  wording). Edit `NEWS.Rmd`, re-knit with
  `Rscript -e 'rmarkdown::render("NEWS.Rmd", quiet = TRUE)'`, and compare `NEWS.md`'s head and
  tail with HEAD.
- **TDD:** prose. The two NEWS guards and `test_wordlist_coverage.R` hold it.
- **Session boundary:** one session; if it runs long, two (one per two sections).

### Phase 6. The version bump (`BACKLOG.md:8`; "just before release")

- **When:** after Phases 1 to 5 have landed and nothing else is due to change in `R/`, `tests/`,
  `man/` or `vignettes/`.
- **DONE:** every "change" row of section 4.1 is done, and every "leave" row is unchanged.
  `packageVersion("nprcgenekeepr") == "3.0.0"` after a reinstall. `README.md` shows 3.0.0, and
  CI on the pushed bump is green (R-CMD-check's five legs, test-coverage, lint, pkgdown).
- **Steps:**
  1. RED: in `test_docsAuditSixRulings.R`, move "Move the version to 3.0.0 just before release"
     from `now` to `gone`. It fails while `BACKLOG.md:8` exists.
  2. GREEN, in one commit:
     - `DESCRIPTION:4`;
     - `NEWS.Rmd:14`, then re-knit `NEWS.md`;
     - `CITATION.cff:11`;
     - `methodology/ROADMAP.md:11`;
     - `BACKLOG.md`: remove `:8-14` and update `:207`;
     - reinstall (`R CMD INSTALL --no-docs --library=<scratch> .` with `R_LIBS` set; see the
       notes' gotchas), then re-render `README.Rmd`.
  3. Run the six follow-the-version tests (section 4.1).
- **TDD:** release metadata with no production logic. RED and GREEN are as in the steps. A
  version-agreement guard (DESCRIPTION, NEWS.Rmd's newest heading and `CITATION.cff` agree on a
  release version) is optional; put it to the owner at the scope question.
- **Verify:** the clean regression read, `lint_package()`, `devtools::check()`, and CI after the
  push. Per the owner's push rule, push once after the last real-work commit.
- **Surface:** local plus GitHub CI. Neither runs CRAN's incoming check; that is Phase 7.
- **Session boundary:** one session. Note: the pkgdown site shows 3.0.0 from this push on,
  before CRAN does. The 2.0.0 cycle did the same.

### Phase 7. The full local gate

- **DONE:** the section 3.1 command, plus `manual = TRUE`, on the bumped tree. `00check.log` ends
  with `Status: OK`, or lists only NOTEs explained in writing.
- **Also:**
  - the clean regression read (`NOT_CRAN=true`): 0 failed and 0 errors, apart from the two
    wall-clock benchmarks if the load is high (read `uptime`);
  - `lintr::lint_package()`;
  - `urlchecker::url_check()`;
  - `spelling::spell_check_package()`;
  - the tarball listing (Phase 3, item 4);
  - the ARM64 container run of the whole suite, as a last look.
- **TDD:** verification. A defect found here goes back to RED in a session of its own.
- **Surface:** macOS arm64, R 4.6.1. It cannot enforce Windows, Linux, R-devel or the 10-minute
  limit; that is Phase 8.
- **Session boundary:** one session. **Freeze:** after this gate, any change to `R/`, `tests/`,
  `man/`, `vignettes/`, `inst/`, `data/` or `DESCRIPTION` repeats this phase.

### Phase 8. `cran-comments.md` for 3.0.0, and the cross-platform runs (owner-run)

- **DONE:**
  - `cran-comments.md` describes an *update* (not a resubmission) with the Phase 7 results;
  - every cross-platform result is folded in;
  - the 2.0.0 text is kept: as `cran/archive/20260717_cran-comments.md` if D1 = A, otherwise in
    git history.
- **The note covers:**
  - one line on what 3.0.0 is;
  - the linux-arm64 issue and how Phase 1 fixed it;
  - R CMD check results;
  - test environments;
  - reverse dependencies (none);
  - any NOTE, explained.
- **Runs** (the 2.0.0 runbook, `docs/planning/cran-2.0.0-phase5-runbook.md`, with these
  changes):
  - install `rhub` (section 4.7);
  - `devtools::check_win_devel()`, `check_win_release()` and `check_win_oldrelease()`;
  - `rhub::rhub_check()` (needs the owner's GitHub token through `gitcreds`);
  - `devtools::check_mac_release()`;
  - optionally, the ARM64 container or arm runner from Phase 1.
  - The win-builder r-devel result's "Check time in seconds" must be 540 s or less (D4).
    One tarball read 617 s and 520 s (section 3.6), so a reading over 540 s is uploaded again
    before anything is cut; the levers left are at the end of section 3.6.
- **Who:** per D5.
- **Surface:** win-builder r-devel is the same class of machine as CRAN's incoming pretest.
- **Session boundary:** one session prepares the note and runbook; the owner runs; one session
  folds in the results. **HARD STOP before the upload.**

### Phase 9. Submission (owner action)

- The owner runs `devtools::submit_cran()`, which builds, uploads and writes `CRAN-SUBMISSION`,
  then clicks the confirmation link that CRAN emails to the maintainer address.
- An agent session records the submission in `CHANGELOG.md`. It never uploads.
- If CRAN's automatic pretest fails, go back to the phase that owns the failure.

### Phase 10. After acceptance

- `usethis::use_github_release()` tags `v3.0.0` at the `CRAN-SUBMISSION` SHA, takes its notes
  from `NEWS.md` and deletes `CRAN-SUBMISSION`.
- `usethis::use_dev_version()` → `3.0.0.9000`, plus a new `# nprcgenekeepr 3.0.0.9000
  (development version)` NEWS block. Then re-render the README and update
  `methodology/ROADMAP.md`.
- After a few days, read CRAN's check page: 13 flavors plus additional issues, including the
  linux-arm64 job, which is Phase 1's real surface.
- This unblocks the papers item (`BACKLOG.md:185`, "a released 3.0.0 to cite") and the outreach
  item.
- **Session boundary:** one session, after the acceptance email.

---

## 6. Decisions for the owner (recommendation first)

**D1. The old cover notes.** Ruled A (S1097).
- **(A, recommended)** Move the eight dated files to `cran/archive/` and add `^cran$` to
  `.Rbuildignore`. In Phase 8, save the 2.0.0 note there as `20260717_cran-comments.md` before
  rewriting it. This is the owner's own suggestion. It keeps every past note one folder away,
  which helps when wording the next one, and costs one commit.
- **(B)** Delete the eight files. Git keeps them (`git log --all -- 20200415_cran-comments.md`),
  and nothing reads them (section 4.3).

**D2. noSuggests before release.** Ruled A (S1097).
- **(A, recommended)** Run Phase 4b: one check run, then guards where it fails. This retires the
  new `kinship2` exposure before CRAN finds it.
- **(B)** Skip it. 2.0.0 shipped with 25 unguarded test files and no noSuggests issue is listed
  (section 4.4). Phase 4a (`shinyBS`) happens either way.

**D3. NEWS before release.** Ruled B (S1097).
- **(B, recommended)** Phase 5 condenses the three largest sections. The owner approves the
  text, and has already asked for the Pedigree Diagram section to be condensed in stages.
- **(A)** Retitle only (Phase 6). This is fastest, and 599 lines stay as they are.

**D4. How the check-time budget is measured** (Phase 2 cuts either way; section 3 shows it
must).
- **(A, recommended)** Measure on the machine that enforces the limit. The owner runs one
  win-builder r-devel check of today's tree at the start of Phase 2 and one after the cut. The
  target is at most 540 s, 10% under the 600 s limit. This costs two uploads of about
  30 minutes each, but the budget becomes a measured number before the bump.
- **(B)** No early uploads. Cut the local CRAN-mode test step to 30 s or less (section 3.2's
  estimate), and learn the real number at Phase 8. A miss there sends the work back to Phase 2
  after the version bump.

**D5. Who runs the cross-platform checks (Phase 8).** Ruled A (S1097).
- **(A, recommended)** The owner, following the runbook, as for 2.0.0. The results email the
  maintainer, and R-hub needs the owner's GitHub token.
- **(B)** An agent runs `devtools::check_win_*()` and `rhub::rhub_check()` after the owner says
  go in that session. The emails still go to the owner.

**D6. `shinyBS` (Phase 4a).** Ruled A (S1097).
- **(A, recommended)** Move it from Suggests to Imports. The app needs it on every run of the
  Summary Statistics tab, so Imports is where it belongs, and the change is one DESCRIPTION line.
  Imports would then hold 20 packages that are not part of base R. `--as-cran` notes "excessive
  imports" above a threshold of 20 (`_R_CHECK_EXCESSIVE_IMPORTS_`). Exactly 20 draws no NOTE
  (measured S1097 on R 4.6.1: the test is `length(imps) > lim`, and
  `tools:::.check_package_depends()` on a scratch copy with `shinyBS` added reports nothing).
- **(B)** Keep it in Suggests and guard the four calls. The tab then shows plain Export buttons
  and boxplots with no hover help when `shinyBS` is missing.

---

## 7. Session map

| # | Phase | State now | Needs first | Effort |
|---|---|---|---|---|
| 2 | cut the CRAN-mode test time (do first) | DONE (S1096, owner ruling): 520 s on R-devel (`6tYpEEb12W8l`); the same tarball also read 617 s (section 3.6) | nothing | |
| 1 | linux-arm64 failure | DONE (S1093; its Windows byte fixed S1094) | nothing | |
| 3 | static hygiene | DONE (S1097; D1 = A) | nothing | |
| 4 | 4a `shinyBS` (always); 4b noSuggests | DONE (S1098; D6 = A, D2 = A) | nothing | |
| 5 | NEWS release pass | next (D3 = B) | nothing | M |
| 6 | version bump | after 1-5 | Phases 1-5 landed | S |
| 7 | full local gate | after 6 | Phase 6 pushed, CI green | S |
| 8 | cover note + cross-platform runs | after 7 (D5 = A) | the owner's runs | S + owner time |
| 9 | submission | after 8 | the owner | owner |
| 10 | after acceptance | after CRAN accepts | the acceptance email | S |

Phases 1 to 5 change the tree and come first. Phase 6 is "just before release", as the owner set
at S855. Phase 7 freezes the tree.

---

## 8. Here be dragons

New this cycle (S1091):

1. **A halted check reads as clean.** With renv active, R's repository option points at Posit
   Package Manager. That server has no `src/contrib/Meta/current.rds`, so `R CMD check` stopped
   at "checking CRAN incoming feasibility" with `Execution halted`, yet `devtools::check()`
   printed `0 errors ✔ | 0 warnings ✔ | 0 notes ✔` after 33 s (S1091's first run). Two rules
   follow:
   - Set `options(repos = c(CRAN = "https://cloud.r-project.org"))` before any `incoming = TRUE`
     check.
   - A check counts only if `00check.log` ends with a `Status:` line.
2. **`devtools::check()` sets `NOT_CRAN = "true"` by default.** A CRAN-mode timing needs
   `env_vars = c(NOT_CRAN = "false")`; without it, every `skip_on_cran()` test runs and the time
   is not CRAN's.
3. **CRAN's linux-arm64 job checks published versions only.** No CRAN surface exists for Phase 1
   before the upload; the container is the stand-in (Phase 1, surface).
4. **Local timings carry the machine's load.** Read `uptime` and record it with every timing.
   Compare two trees only when both were measured on the same machine under similar load
   (section 3).
5. **Removing the version item from `BACKLOG.md` trips `test_docsAuditSixRulings.R:80`**
   (section 4.1).
6. **Do not bump version strings that record data:** the example snapshot history and the test
   fixtures (section 4.1).
7. **A source-tree timing is not the check's timing.** Tests that read repository files run
   from the source tree and skip under `R CMD check` (section 3.3, caveat). Rank and budget in
   the installed layout.
8. **`skip_on_cran()` hides a test from CRAN, not from us.** CI and the clean regression read
   set `NOT_CRAN=true`, so every skipped file still runs there. Without Phase 2 step 3's export
   check, though, an export could end up with no test on CRAN at all.
9. **`_R_CHECK_DEPENDS_ONLY_` cannot hide what is in R's own library (S1098).** `tools:::setRlibs()`
   links only the dependencies into a temporary library, but `.Library` stays visible. This Mac's
   holds 226 non-base packages, including 16 of the 17 Suggests, so the plain command would have
   hidden only `kinship2` and passed for the wrong reason. Check `installed.packages(lib.loc =
   .Library)` first; Phase 4's DONE paragraph has the scratch R home that fixes it.

Carried from 2.0.0 (numbers are that plan's §5):

- **2: speed-ups that change numbers are correctness regressions.**
- **3: `NEWS.md` is generated from `NEWS.Rmd`.**
- **5: `.Rbuildignore` is perl regex.**
- **11: new root files are build cruft until `.Rbuildignore` covers them.** Check the tarball
  listing before any cross-platform run.
- **The S395/S397 lesson:** win-builder ran about 3.4 to 3.8 times slower than this machine for
  each check step (2.0.0's cover note: examples 22 s vs 80 s, tests 59 s vs 200 s, vignettes 17 s
  vs 65 s).

---

## 9. Out of scope

- New features. The owner's delayed items (contributor tutorial, both LabKey items, the
  kinship2-like package, outreach, papers) stay delayed; papers and outreach wait on Phase 9.
- Issue #138 and the other open issues.
- The held-back methodology sync (`BACKLOG.md:143`).
- `revdep/` (section 4.3, FYI).
- The DESCRIPTION Description text: it already names every tab (`DESCRIPTION:20-37`), and
  Crossref has no DOI for Vinson and Raboin (2015), so the PMC link stays.

## 10. Sources

- CRAN check results and package page, read 2026-10-29: section 2.1 URLs.
- linux-arm64 checks: section 2.2 URLs.
- Crossref works API, `10.1016/0040-5809(86)90006-7`; doi.org handle API for `…90007-1`
  (`responseCode: 100`).
- `docs/planning/cran-2.0.0-submission-plan.md` (§4 phases, §5 dragons) and
  `docs/planning/cran-2.0.0-phase5-runbook.md`; `cran-comments.md` (the 2.0.0 timing figures).
- Section 3's check logs and the per-file timing table: scratch only, not committed. The numbers
  are copied into section 3.
