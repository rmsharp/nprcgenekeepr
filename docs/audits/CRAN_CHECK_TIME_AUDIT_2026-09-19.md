# CRAN Check-Time Audit — 2026-09-19 (Session 730)

**One example is the entire problem.** A full `R CMD check --timings` of the clean-export
tarball, run on the CRAN-visible surface (no `NOT_CRAN`), completes **Status: OK in 1,037 s
wall / 1,032 s CPU (17.3 min)** — and **734 s (71 %) of it is the single
`makePedigreeMatingLayout` Rd example**, which lays out the full 3,694-individual
`examplePedigree` (an input ~5× larger than the Shiny app's own 750-individual diagram
ceiling, `R/modPedigree.R:406`). Every one of the other 201 timed examples finishes in
under 2 s (8.9 s combined). Tests are healthy: 215 s under check, no per-file NOTE
threshold applies, and ~14 % of local test blocks already stay home on CRAN. Fixing the
one example takes the measured check from ~17.3 min to **~5 min**, clearing CRAN's
incoming-pretest "Overall checktime > 10 min" NOTE with headroom. Research only: no
remedy applied, no `.R`/`man/` change, no TDD phases.

Measurement platform: Apple M2 Max, macOS 26.6.2, R 4.6.1 (2026-06-24), renv project
library. Artifact: `nprcgenekeepr_2.0.0.9000.tar.gz`, 3,485,111 B, built with
`pkgbuild::build()` from a clean `git archive HEAD` export at `c8397845` (the S727 §7
recipe). CRAN's own farm (esp. win-builder) is typically slower than this machine, so
these numbers are a *floor* for what incoming pretests would measure. Reproduction
commands are in §7.

---

## 1. Audit Summary

- **Scope:** the three CRAN-timed surfaces of the package — 202 Rd examples (of 256 Rd
  files), the test suite as CRAN runs it (`NOT_CRAN` unset: `spelling.R` +
  `testthat.R`), and the vignette rebuild — plus a per-file testthat attribution run on
  each side of the `NOT_CRAN` switch.
- **Criteria (verified at source this session):**
  - CRAN Repository Policy, revision 6875
    (<https://cran.r-project.org/web/packages/policies.html>): "Checking the package
    should take as little CPU time as possible"; examples "should run for no more than a
    few seconds each"; never "more than two [threads/cores] simultaneously";
    "Long-running tests and vignette code can be made optional for checking, but do
    ensure that the checks that are left do exercise all the features of the package."
  - `R CMD check` mechanics (read from `tools/R/check.R`, r-devel master): the per-Rd
    example table/NOTE threshold is `_R_CHECK_EXAMPLE_TIMING_THRESHOLD_` = **5 s**,
    flagged when user+system > 5 s **or** elapsed > 5 s, ranked by CPU. Tests carry
    elapsed *timeouts* (`_R_CHECK_TESTS_ELAPSED_TIMEOUT_`), not a per-file NOTE.
    `_R_CHECK_DONTTEST_EXAMPLES_` defaults to `as_cran` — **`\donttest{}` examples are
    still run at incoming** (a second `--run-donttest` pass); they escape only CRAN's
    regular daily checks.
  - CRAN incoming pretest practice: an "Overall checktime N min > 10 min" NOTE
    (observed threshold **10 min**; CRAN-side scripting, not published in R's sources —
    evidenced by R-pkg-devel threads, e.g.
    <https://www.mail-archive.com/r-package-devel@r-project.org/msg02696.html>).
- **Coverage:** all 202 example-bearing Rd files timed (the `--timings` file covers every
  one); all 330 test files swept (329 register locally, 310 on the CRAN surface — the
  gap is measured, §3 F2); vignette rebuild included in the whole-check wall time. CI
  step-level durations were not retrievable (the GitHub API returns no step timestamps
  for run 35485603672); the whole-job ~32–34 min duration stays a dependency-install-
  inflated trend line only, as the BACKLOG item already cautioned.
- **Finding count:** 1 critical · 1 moderate · 3 informational.

### Criteria grid

| # | Criterion | Measured | Verdict |
|---|---|---|---|
| T1 | Per-Rd example ≤ 5 s CPU-or-elapsed | 201 of 202 pass (worst other: 1.6 s); `makePedigreeMatingLayout` **734.1 s elapsed / 733.2 s CPU ≈ 147× threshold** | **Fail (1 file)** — Finding 1 |
| T2 | Examples "a few seconds each" (policy) | same one outlier | **Fail (1 file)** — Finding 1 |
| T3 | Overall check time vs the 10-min incoming NOTE | 17.3 min measured on faster-than-farm hardware | **Fail as-is; ~5 min after Finding 1's fix** |
| T4 | "As little CPU time as possible" | 71 % of all check CPU is one example call | **Fail as-is** — Finding 1 |
| T5 | ≤ 2 cores | CPU/wall = 1,032/1,037 = 0.995 — effectively single-threaded | **Pass** (measured, not assumed) |
| T6 | Tests: no timeout risk, CRAN-side exclusions working | 215 s total; 19 files bare-skip + 200 block-skips without `NOT_CRAN` | **Pass** — Finding 2 |

---

## 2. Where the 1,037 s goes

| Stage | Elapsed | Share | Note |
|---|---|---|---|
| Examples (202 Rd files) | 743.0 s | 71.6 % | 734.1 s is ONE Rd file; the other 201 total 8.9 s |
| Tests (`spelling.R` + `testthat.R`) | ~215 s | 20.7 % | `testthat.Rout` `proc.time`: 207.0 user + 7.2 sys / 214.7 elapsed; 6,141 expectations pass, 249 reporter-skips, 0 fail |
| Everything else (install, ~60 static checks, vignette rebuild, PDF manual) | ~79 s | 7.6 % | not individually timed; vignette rebuild is bounded above by this lump |

Per-Rd example timings, top of `nprcgenekeepr-Ex.timings` (user / system / elapsed, s):

| Rd file | user | system | elapsed |
|---|---|---|---|
| **makePedigreeMatingLayout** | **725.803** | **7.425** | **734.138** |
| groupAddAssign | 1.558 | 0.054 | 1.613 |
| countLoops | 1.259 | 0.030 | 1.289 |
| reportGV | 0.879 | 0.009 | 0.890 |
| summary | 0.859 | 0.003 | 0.862 |
| findLoops | 0.661 | 0.010 | 0.672 |
| examplePedigree | 0.657 | 0.012 | 0.670 |
| createPedTree | 0.658 | 0.009 | 0.668 |
| (194 more, each < 0.3 s) | | | |

The check itself printed the enforcement view: `Examples with CPU (user + system) or
elapsed time > 5s` lists exactly one row — `makePedigreeMatingLayout 725.803 7.425
734.138`. Under `--as-cran`/incoming this table is a NOTE.

---

## 3. Findings

### Finding 1 (Critical): the `makePedigreeMatingLayout` example is 71 % of the whole check and ~147× CRAN's per-example threshold

- **Location:** `R/makePedigreeDiagramData.R:1659-1662` (roxygen `@examples`), rendered
  to `man/makePedigreeMatingLayout.Rd`.
- **Evidence:** the example is one call — `makePedigreeMatingLayout(nprcgenekeepr::examplePedigree)`
  — on the full 3,694-row bundled colony. Measured 734.1 s elapsed / 733.2 s CPU
  (`nprcgenekeepr-Ex.timings`). Scaling is strongly superlinear: the same call on the
  280-row `pedWithGenotype` measures **1.0 s** (13× rows → ~730× time).
- **Impact:** guarantees the per-example >5 s NOTE at incoming, and by itself pushes
  overall check time past the 10-min incoming NOTE line (17.3 min measured here, on
  hardware faster than the farm). Submission-blocking in practice: pretest NOTEs go to
  a human reviewer.
- **Context that sharpens the fix:** the Shiny app itself refuses to *render* a diagram
  above **750 individuals** (`pedigreeDiagramMaxNodes <- 750L`, `R/modPedigree.R:406`) —
  the example exercises an input ~5× the app's own ceiling, so the full-colony call
  does not even demonstrate a supported end-to-end path.
- **Recommendation:** replace the example input with a smaller shipped pedigree
  (measured drop-in: `pedWithGenotype`, 280 rows, has all required columns, 1.0 s —
  note it emits a benign edge-collision warning the remedy session may want to avoid
  by choosing/subsetting differently). Do **not** reach for `\donttest{}` — Finding 3.

### Finding 2 (Informational): the CRAN-side test exclusions work; ~14 % of local blocks stay home; 215 s total is comfortably clear of every enforcement line

- **Evidence — identical-currency comparison** (`as.data.frame(testthat::test_dir(...))`,
  block currency, same machine, sequential runs):

| | `NOT_CRAN=true` (local baseline) | `NOT_CRAN` unset (CRAN surface) |
|---|---|---|
| wall time | 260.3 s | 187.6 s (−28 %) |
| files registering | 329 | 310 (19 bare-skip out) |
| test blocks (rows) | 2,437 | 2,141 |
| block-skips | 184 | 200 |
| blocks actually run | 2,253 | 1,941 (−312, −13.8 %) |
| passing expectations | 7,029 | 6,166 |

  The local baseline reproduced the project's standing `2437/0/0/184/0` exactly, which
  also settles that baseline's currency: rows/failed/error/skipped in
  `as.data.frame()` terms. Under check (installed package, not `load_all()`) the same
  surface ran in 214.7 s with 0 failures.
- **Impact:** none adverse. No per-file NOTE threshold exists for tests (§1); the
  relevant enforcement is overall time (Finding 1's domain) and elapsed timeouts (far
  away).

### Finding 3 (Informational): `\donttest{}` is not an escape hatch at submission time

- **Evidence:** `tools/R/check.R` (r-devel master): `_R_CHECK_DONTTEST_EXAMPLES_`
  defaults to `as_cran`, so incoming checks run `\donttest` examples in a dedicated
  `--run-donttest` pass. The package currently uses `\donttest` in 0 Rd files and
  `\dontrun` in 9.
- **Impact:** wrapping Finding 1's example in `\donttest{}` would hide it from the >5 s
  timing table but incoming would still pay the ~12 min in the donttest pass — the
  overall-checktime NOTE remains. Shrinking the input is strictly better; `\dontrun{}`
  would work mechanically but draws reviewer scrutiny and demonstrates nothing live.

### Finding 4 (Moderate): 10 of the 11 slowest test files run unguarded on CRAN — the one cheap optional lever if more headroom is ever wanted

- **Evidence:** per-file wall times on the CRAN surface (top of
  `test-file-times-cran-surface.csv`): `test_positionMatingUnitForest.R` 29.4 s (the
  only one of the eleven with any `skip_on_cran()` — 3 of ~57 blocks),
  `test_resolveEdgeNodeCollisions.R` 20.0 s, `test_addRectilinearWaypoints.R` 13.5 s,
  `test_modMarkerGenetics.R` 11.7 s, `test_makePedigreeMatingLayout.R` 10.0 s,
  `test_comparePedigreeStructure.R` 8.9 s, `test_groupAddAssign.R` 8.1 s,
  `test_modPedigree.R` 6.2 s, `test_fillGroupMembers.R` 5.8 s,
  `test_fillGroupMembersWithSexRatio.R` 5.6 s, `test_pkgdown_reference_config.R` 5.4 s.
  Together: ~125 s of the 178 s per-file total (~70 %).
- **Impact:** optional only. After Finding 1's fix the check sits near ~5 min and
  nothing forces test trimming. If CRAN's slower farm still lands near the 10-min line,
  guarding the top few files with `skip_on_cran()` buys ~1–2 min at zero real coverage
  cost (CI runs the full suite with `NOT_CRAN=true` on every push). The BACKLOG item's
  own constraint stands: never degrade the local/CI baseline, which stays authoritative.

### Finding 5 (Informational): thread-count compliance is measured, not assumed

- **Evidence:** whole-check CPU/wall = 1,032/1,037 = 0.995 (`/usr/bin/time -l`).
- **Impact:** the ≤2-core policy line is satisfied by construction (effectively
  single-threaded); no `OMP`/BLAS thread capping work is needed.

---

## 4. Structural Observations

1. **The expensive path was never wired to a small demo input.** `makePedigreeDiagramData`
   (nodes/edges tables only, no layout) costs 0.005 s on the same full colony; the cost
   lives entirely in the layout stack (`.buildMatingUnitForest()` →
   `.positionMatingUnitForest()` → `.addRectilinearWaypoints()` →
   `.resolveEdgeNodeCollisions()`). Any future example/vignette touching the layout
   should default to a few-hundred-row input.
2. **Superlinear layout scaling is now measured** (280 rows → 1.0 s; 3,694 → 734 s) —
   relevant beyond CRAN: it is the same cost curve behind the app's 750-individual cap
   and issue #138's full-colony ambition.
3. **The examples surface is otherwise exemplary:** 201 files in 8.9 s combined shows
   the existing example style (small bundled fixtures) works; the outlier is a one-off,
   not a pattern.

---

## 5. Comparison with Prior Audits

The S727 tarball-size audit (`docs/audits/TARBALL_SIZE_AUDIT_2026-09-19.md`) cleared the
byte axis: 3.49 MB vs the 10 MB line, "the package is not oversized." This audit is the
time axis of the same submission story, and the verdict inverts: **size passes, time
fails — for exactly one, fully-localized reason.** Both audits used the same clean-export
build recipe (§7 there, reused here), and this build's 3,485,111 B is consistent with
S727's 3,485,185 B at `f8ffa40b` (drift = docs-only commits since).

---

## 6. Recommendations (ranked; remedies are the follow-up session's, none applied here)

1. **Replace the `makePedigreeMatingLayout` example input with a small shipped pedigree**
   (`R/makePedigreeDiagramData.R:1659-1662` + `devtools::document()`). Measured
   candidate: `pedWithGenotype` (280 rows, 1.0 s, benign collision warning); or subset
   `examplePedigree` to a few hundred rows if a cleaner demo is preferred. Effort S.
   This single change moves the check from ~17.3 min to ~5 min and clears T1–T4.
2. **Re-measure after the fix with the §7 recipe** — confirm the >5 s table is empty and
   the wall time landed near the predicted ~5 min. Effort trivial (rides remedy 1's
   verification).
3. **Optional, only if the farm still crowds 10 min:** `skip_on_cran()` on the top
   Finding-4 files (~1–2 min back, CI coverage unchanged). Effort S.
4. **Not indicated on the evidence:** shared fixtures (no repeated expensive setup
   dominates — the slow test files are algorithmic layout tests), vignette work (the
   rebuild is inside a 79 s lump), `\donttest{}` (Finding 3), and any change that trims
   the local/CI suite itself.

---

## 7. Reproduction

```sh
# Clean-export build + CRAN-surface check (run from the repo root so renv applies)
X=$(mktemp -d); mkdir "$X/src" "$X/out"; git archive HEAD | tar -x -C "$X/src"
Rscript -e "pkgbuild::build('$X/src', dest_path = '$X/out')"
cd "$X/out"
export R_LIBS="$(cd - >/dev/null; Rscript -e 'cat(.libPaths()[1])')"
unset NOT_CRAN
/usr/bin/time -l R CMD check --timings nprcgenekeepr_*.tar.gz
# Per-Rd ranking and the >5s set
awk 'NR>1 {cpu=$2+$3; print cpu, $0}' nprcgenekeepr.Rcheck/nprcgenekeepr-Ex.timings | sort -rn | head
awk 'NR>1 {if ($2+$3 > 5 || $4 > 5) print}' nprcgenekeepr.Rcheck/nprcgenekeepr-Ex.timings
```

```r
# Per-file test attribution, CRAN surface (from the repo root; the identical run with
# Sys.setenv(NOT_CRAN = "true") gives the local-baseline side of Finding 2's table)
Sys.unsetenv("NOT_CRAN")
pkgload::load_all(".", quiet = TRUE)
res <- as.data.frame(testthat::test_dir("tests/testthat", reporter = "silent",
                                        stop_on_failure = FALSE))
byf <- aggregate(cbind(real = res$real) ~ res$file, FUN = sum)
byf[order(-byf$real), ]
```

**Limits of this audit:** all times are one run each on an M2 Max — no variance
estimate, and CRAN's farm is slower by an unmeasured factor (the 10-min comparison is
therefore conservative in direction but not calibrated). The ~79 s "everything else"
lump was not decomposed per stage. The `--run-donttest` incoming pass was reasoned from
`check.R`, not exercised (the package has no `\donttest` today). Win-builder / CRAN
incoming were not actually run.
