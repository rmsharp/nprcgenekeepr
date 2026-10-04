# Diagnosis: the red CI on `master` after the S890 push (S891, 2026-10-04)

**Deliverable of S891:** why four CI runs on `2e2046efd` (the S890 close-out; pushed
`f0bcb9f48..2e2046efd`, 128 commits) were red, with the evidence and a proposed fix for each cause.
Nothing was fixed here: a red run is reported, and each fix is its own strict-TDD change.

## In plain words

There are **two separate causes**, not one. S890's brief guessed that test-coverage failed on
the same test as R-CMD-check; it did not.

1. **R-CMD-check on ubuntu oldrel-1 and devel** (a *flaky* test): the layout test
   `test_positionMatingUnitForest.R:645` asserts that the layout solver holds its spacing floors to
   within 1e-6 layout units. The solver is an ill-conditioned quadratic program, and on this fixture the
   rounding noise has a heavy tail that reaches 1e-4. About 1 equivalent arithmetic path in 8
   puts one pair over the line. The last green push and this red one ran the **same** code
   on this fixture, the same runner image, the same R and the same 129 packages; what differed
   is not visible in the logs.
2. **test-coverage** (a *deterministic* defect): `test_sexCodes.R:110` and `:115`, added by S879,
   scan `../../R/*.R` and skip only if that directory is missing. Under coverage the tests run from an
   installed copy of the package, where `R/` exists but holds only `.rdb`/`.rdx` files, so the
   scan finds no source and fails. It fails every time that job runs, and could not have been seen
   in any local run or in R-CMD-check (where `../../R` does not exist and the test skips).

## What was red

| Run | Result | Failing assertion |
|---|---|---|
| R-CMD-check `37179033145`, ubuntu **oldrel-1** (R 4.5.3) | red | `test_positionMatingUnitForest.R:645:3`, `sum(shortfall > 1e-06)` got 1, expected 0 |
| R-CMD-check `37179033145`, ubuntu **devel** (R 4.7.0) | red | the same assertion, same message |
| R-CMD-check, ubuntu / macOS / windows **release** (R 4.6.1) | green | |
| test-coverage `37179033148` (ubuntu, R 4.6.1) | red | `test_sexCodes.R:110:3` and `:115:3` (the "Show testthat output" step prints it; `--log-failed` does not) |
| lint `37179033168`, pkgdown `37179033154`, shinytest2 (scheduled, 09:05 UTC) | green | |

The previous push (`f0bcb9f48`, S858's close-out) was green on all of these: R-CMD-check
`36964390307` (all 5 jobs) and test-coverage.

## Cause 1: the QP-floor test's tolerance sits inside the solver's noise

**Mechanism.** `.solveJointQP()` (`R/makePedigreeDiagramData.R:1578-1581`) solves one
`quadprog::solve.QP()` per connected family with `Dmat = t(pmat) %*% pmat + 1e-8 * diag(n)`. The
`pmat` part has a translation direction with no cost of its own, so the 1e-8 ridge (plus a 1e-5
anti-degeneracy row) sets the smallest eigenvalue and `Dmat` is badly conditioned.
Measured on the bundled 375-animal fixture (5 solves): smallest eigenvalue 1.0e-8 each time, largest
4.955, 4.790, 4.000, 5.032 and **15.776** for the 733-node family, so cond(Dmat) is **1.6e9**.
A 1.6e9 condition number amplifies rounding differences, and the test (`:645`) allows a shortfall of
only 1e-6 layout units (1 unit = 120 px, so 1.2e-4 px).

**Evidence (all on the fixture the test uses; probe scripts were scratch files, not committed).**

| Probe | Result | Reading |
|---|---|---|
| Local R 4.6.1 arm64, reference BLAS, HEAD | max shortfall 4.3e-8; 0 pairs over 1e-6 | the test passes here, 23x under the tolerance |
| Same at `f0bcb9f48` (last green) | max 4.6e-8; **identical** `Dmat` spectrum on all 5 solves | the QP instance did not change across the 128 commits (S859 is not the cause) |
| Add ulp-scale noise to `Dmat`, 30 seeds x 2 scales | max 2.2e-8 to 1.3e-7; 0 of 60 over 1e-6 | rounding noise in `Dmat` alone does not reach 1e-6 |
| Linux amd64 container, R 4.5.3, OpenBLAS 0.3.26 (the CI's version), force kernel `Haswell` / `Sandybridge` / `Nehalem` | 1.03e-7 / 7.0e-8 / 1.20e-7; thread count (1, 4, default) changes nothing | the BLAS kernel moves the result about 3x; still under 1e-6 |
| **Re-order the variables** of the same QP (identical in exact arithmetic; different rounding at every step), 100 runs, seed 2026 | median 1.15e-7, 90th 3.4e-6, 95th 1.8e-5, 99th 5.1e-5, **max 1.09e-4**; **12 of 100 runs have a pair over 1e-6** | the tolerance is inside the noise tail |
| Same 100 runs: pairs over 1e-6 per run | 0 pairs in 88 runs, **exactly 1 pair in 12 runs, never 2+** | matches CI's "got 1" |
| Same: which pair | `IYYFP6\|3XP1ZD` in 9 of the 12 | one recurring near-binding pair, not diffuse noise |

**What this proves and does not prove.** It proves the test's premise is wrong: its comment calls
1e-6 "solver precision" on the strength of one measured run (6.8e-8, S675), but across equivalent
arithmetic paths the shortfall reaches 1e-4. It reproduces the CI symptom (one pair over). It does
**not** show which path CI took or the failing value: the CI log prints only "got 1". The 12 in
100 is for random variable re-ordering, a much bigger change than a different CPU kernel, so the
per-runner failure rate is unknown. Two of the six jobs that ran this test failed (oldrel-1 and
devel); the other four passed (the three release R-CMD-check jobs and test-coverage, which ran the
test and did not fail on it). Two in six is unremarkable against a rate near 12%, and it is not a
measured CI rate.

**Why green, then red.** Not the code (cause above), and not what the logs show of the environment:
for oldrel-1 the green and red jobs have the same runner image (`20260927.320.1`), R 4.5.3,
OpenBLAS `0.3.26+ds-1ubuntu0.1`, `quadprog` 1.5-8, a cache miss both times and **zero differences in
129 installed package versions**. The one input the logs do not show is the runner's CPU, which
selects OpenBLAS's kernels. That is the remaining candidate; it is **unobserved**, not confirmed.

### Proposed fix 1 (its own strict-TDD change, READY, Effort S-M)

- Change the tolerance at `tests/testthat/test_positionMatingUnitForest.R:645` from 1e-6 to **1e-3
  layout units (0.12 px)** and rewrite its comment (`:637-641`) to state the measured tail (max
  1.09e-4 over 100 re-orderings, 10x headroom). The exact geometric property it protects, no
  overlapping symbols, is still asserted exactly below it (a 1.0-unit floor between 50 px symbols leaves
  70 px = 0.58 units, so 1e-3 cannot hide an overlap).
- **RED seam (it exists):** the test file can call `.positionMatingUnitForest()` with
  `quadprog::solve.QP` replaced by a wrapper that re-orders the variables with a fixed seed (the
  wrapper is about 10 lines: permute `Dmat`, `dvec`, rows of `Amat`; un-permute the solution). A RED
  test asserts the **old** 1e-6 bound over a fixed set of permutation seeds known to exceed it on
  the dev machine (seed 2026's 12 are findable in about 3 minutes); GREEN is the new bound.
  Platform-dependent outcomes are fine for the RED side; the GREEN bound holds everywhere.
- **Same tolerance elsewhere, unmeasured:** `test_solveJointQP.R:210` (`req - 1e-6`) and `:440`
  (`tolerance = 1e-6`). Their fixtures are small hand-built QPs; they were green on CI, but the same
  re-ordering probe has not been run on them. Measure before touching.
- **Alternatives, not recommended now:** (a) improve `Dmat`'s conditioning or add a post-solve floor
  repair in production code: Architect Mode, plan-mode approval, changes every layout by at most 1e-4
  units (0.013 px, invisible), no user benefit; (b) re-run the failed CI jobs: a same-CPU re-run
  would likely fail the same way, a different-CPU re-run pass, which tests the CPU theory but fixes
  nothing (an outward action, needs your say-so).

## Cause 2: the `sexCodes` guard test cannot tell an installed package from a source tree

**Mechanism.** `tests/testthat/test_sexCodes.R:93-94` and `:108-109` use
`rDir <- testthat::test_path("..", "..", "R")` then `skip_if(!dir.exists(rDir), ...)`. Under
test-coverage the tests run from `<lib>/nprcgenekeepr/nprcgenekeepr-tests/testthat/`, so `rDir` is the
installed package's `R/`, which exists. It holds `nprcgenekeepr`, `nprcgenekeepr.rdb` and
`nprcgenekeepr.rdx`, no `.R` files. `:110` (all four allowlisted files exist) is FALSE and `:115`
(`setdiff(...)` of the 6 allowlisted lines) has length 6. The first test, "no bare sex-code literals
remain", passes vacuously there, because it scans nothing.

**Evidence.** (1) The coverage log's failures are exactly `:110:3` and `:115:3` with "Lengths differ: 6 is
not 0". (2) **Reproduced locally:** `git archive HEAD` into a scratch dir, `install.packages(..., lib =
<scratch lib>)`, copy `test_sexCodes.R` to `<lib>/nprcgenekeepr/nprcgenekeepr-tests/testthat/`, run it
with `testthat::test_file(..., package = "nprcgenekeepr", load_package = "installed")`: **the same two
failures, same messages**, about 2 minutes. (3) The guard was added in S879 (`2ea50611a`, RED), which
is **not** an ancestor of `f0bcb9f48`, so it is new in the pushed range. This is why the previous push was
green.

### Proposed fix 2 (its own strict-TDD change, READY, Effort S)

- Replace both `skip_if(!dir.exists(rDir), ...)` with a skip that checks for source, e.g. a helper
  `sexCodeSourceAvailable(rDir)` returning `length(list.files(rDir, pattern = "\\.[Rr]$")) > 0L`.
- **RED seam (it exists, test-only):** a test that builds a temp dir containing only `x.rdb` and
  `x.rdx` and asserts the helper reports "no source" (RED: the helper does not exist yet); a second
  with a `.R` file asserts "source". Final check: the scratch-install loop above, then the
  test-coverage job on CI after the owner pushes.
- The first test's vacuous pass under coverage is closed by the same helper.

## Corrections to the S890 brief

- "test-coverage ... the same one is likely": **wrong**. Different test, different cause.
- Hypotheses, as ranked in the brief: **H1** (S859 moved a pair): not supported, the QP instance is
  unchanged. **H2** (tolerance always marginal): supported and sharpened (heavy tail, 12 in 100).
  **H3** (different `quadprog` or BLAS version): not supported as stated (identical versions on all
  jobs); the CPU kernel is the unobserved remainder. **H4** (`order(..., method = "radix")`
  tie-break): not tested, and not needed: a valid solution keeps adjacent nodes at least the
  smallest floor (0.25 units) apart, so equal positions to break a tie on do not occur.

## Not established

- The actual failing shortfall value and pair on CI (the log prints only the count). One CI run with
  the value printed would settle it; that needs a throwaway branch or a re-run, which is yours to approve.
- The runner CPU model of the failing jobs.
- Whether `test_solveJointQP.R:210` / `:440` have the same exposure.

## Checked and cleared

`quadprog` version (1.5-8 on every job), OpenBLAS package (0.3.26+ds-1ubuntu0.1 on every Ubuntu job),
runner image, R version, package set (129 packages, identical), thread count, S859's effect on this
fixture, the number of adjacent pairs (773 on CI and locally).

## Cleanup

All instrumentation (tag `[DEBUG-q7k2]`) lived in scratch files outside the repo; none is in the
tree. The only artifact left outside the scratchpad is the Docker image `rocker/r-ver:4.5.3`
(about 1 GB, pulled for the kernel test); `docker rmi rocker/r-ver:4.5.3` removes it.

## Addendum (S893, 2026-10-04): what the repair measured, and what it overturned

S893 made both repairs (test-only; see `CHANGELOG.md`). Causes 1 and 2 stand. Three figures above do not:

| This diagnosis said | S893 measured (300 shuffles of the QP's variables, seeds 1-300) |
|---|---|
| 12 of 100 runs over 1e-6, max 1.09e-4 | **42 of 300** over 1e-6, max **5.98e-4** (seed 198); the tail grows with the sample |
| "exactly 1 pair in 12 runs, never 2+" | up to **2** pairs in a run (seeds 198 and 147) |
| Fix 1: tolerance **1e-3**, "10x headroom" | 1e-3 clears the worst of 300 by only 1.7x; the owner chose **1e-2** (1.2 px, 16x; still 58x under the 0.58-unit overlap margin) |

Also found: `test_solveJointQP.R:437-439` allows only **1e-9**, and the `trackBFull` fixture misses it in **23 of 300**
shuffles (worst 1.2e-8), a third exposure not listed above; the owner put it in scope and it now allows 1e-6. The two
bounds this diagnosis asked to measure are safe: `:210` (worst 1.1e-8 over all fixtures) and `:440` (worst 2.7e-9),
both against 1e-6. The shuffle seam is `tests/testthat/helper-reorderedSolveQP.R`. Still **not established**: the CI
runners' own tails (nothing was pushed, so no CI run has seen the fixes).
