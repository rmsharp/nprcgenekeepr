## Resubmission

This is a resubmission of an archived package as a new major version, 2.0.0.

`nprcgenekeepr` was archived on CRAN on 2025-07-29 ("Archived ... as issues were
not corrected in time"). It had been accepted and published as 1.0.8 on
2025-07-26; the issue subsequently raised on the R-package-devel list was
"Tested elapsed times" (CRAN example / test / vignette timing limits).

For 2.0.0, the elapsed times were re-profiled under
`R CMD check --as-cran --timings`. The timing condition that led to archival no
longer reproduces on the 2.0.0 codebase: the slowest single example runs in about
1.4 seconds (no example exceeds 5 seconds) -- roughly 3-5x inside CRAN's soft
per-example limit -- and the examples (about 23s), tests (about 86s), and
vignette-rebuild (about 21s) phases all complete with comfortable headroom and no
timing flags from the check itself. Win-builder and R-hub re-confirm these times
on independent, and slower, hardware before submission.

A previously undeclared test-time dependency (`withr`) was also declared in
Suggests, which had produced a check WARNING.

2.0.0 is a major release. See `NEWS.md` for the user-facing Major / Minor
changes, including breaking changes: rejection of a period in `id`, `sire`, or
`dam` values; removed exports; and `runGeneKeepR()` remaining the primary Shiny
entry point, with `runModularApp()` as a soft-deprecated alias.

**2026-07-16 update:** a real submission attempt (via `devtools::submit_cran()`)
was rejected by CRAN's actual incoming automatic check -- distinct from the
win-builder pretests below, which do not run this gate -- for Windows r-devel
"Overall checktime 12 min > 10 min", driven mainly by `checking tests`
(334s), with `checking examples` (79s) and `checking re-building of vignette
outputs` (79s) also contributing; Debian's equivalent run stayed under 5 min,
so this is specific to Windows win-builder's slower VM, not a universal
regression. This is the same failure class ("Tested elapsed times") that
archived this package in 2025. Fixed by gating the true gene-drop
convergence-stress tests behind `skip_on_cran()` and trimming gene-drop
iteration counts at test call sites whose assertions do not depend on the
gu-magnitude they'd affect (full regression suite re-confirmed 0 errors/0
warnings in both dev and CRAN test modes). The local timing figures below
predate this fix and this rejection cycle; they will be refreshed once a
fresh win-builder Windows run confirms the real checktime improvement.

**2026-07-16 follow-up:** the fresh win-builder Windows-devel run confirmed the fix
works as intended (verbatim `testthat.Rout`: all 10 new `skip_on_cran()` guards
fired, 0 FAIL/0 WARN) -- `checking tests` dropped `334s -> 245s` -- but the reported
total check time landed at `655s` (10 min 55s), still ~55s over the 10-minute mark.
Found and fixed one more real contributor: `vignettes/simulatedKValues.Rmd`'s
`createSimKinships(n = 1000L)` call (4.07s alone on a 17-row pedigree, superlinear
in `n`) reduced to `n = 500L` (1.28s), preserving the short-vs-long convergence
narrative it illustrates. A broader sweep of all vignettes and roxygen `@examples`
for other large iteration-like parameters found no further safe lever -- the
`examples` phase's ~45s of its 78s is fixed per-topic overhead, not attributable to
any single example, and `ColonyManagerTutorial.Rmd` (the largest local vignette
render) is `.Rbuildignore`'d and irrelevant to the real build. A fresh win-builder
run is needed to measure this additional trim's real impact.

**2026-07-16 second follow-up (S394, final for this cycle):** the second fresh
win-builder run confirmed the `simulatedKValues.Rmd` trim is real (`checking
re-building of vignette outputs` dropped `79s -> 66s`), but the gain was fully
offset by run-to-run noise elsewhere (`examples`/`checking R code`/HTML manual all
moved up a few seconds between runs) -- reported total landed at `656s`, essentially
unchanged from the prior `655s`. A further investigation of the "tests" phase's
long tail of small Shiny-`testServer()`-driven files (the dominant remaining cost at
245-246s) found only ~17s of local headroom, all of it genuine test coverage
(deliberately added by prior sessions to close a real `appServer()` coverage gap),
not redundant overhead -- not a safe trade to consolidate for that size of payoff.
**Net result across three sessions (S392-394):** `tests` reduced `334s -> 245s`
(robust, reproducible), `vignette rebuild` reduced `79s -> 66s` (robust,
reproducible); total check time reduced from an extrapolated ~720s to a stable
~655-656s -- real, meaningful progress, but still ~55s over CRAN's 10-minute mark.
No further safe, mechanical lever was found after three rounds of investigation.
Remaining path forward (resubmit anyway, wait for a quieter win-builder day, or
hold for new ideas) is an owner decision, not a further engineering task.

**2026-07-17 (S395): owner re-opened the effort with wider scope** -- test
STRUCTURE changes and previously-protected iteration counts, both explicitly
avoided by S392-394, were put back on the table. A 7-agent investigation
found several candidate fixes; one (`test_pkgdown_reference_config.R`,
hoisting 3 redundant `pkgdown::as_pkgdown()` calls to 1) looked like the
single biggest local win (13.1s -> 3.76s) but turned out, on verification
against the real built-tarball `R CMD check` run, to be **irrelevant to CRAN**
-- `_pkgdown.yml` is `.Rbuildignore`'d and never ships in the tarball, so all
3 of that file's tests already skip on every real CRAN/win-builder check
(`_pkgdown.yml absent; guard not applicable`, confirmed in the real
`testthat.Rout`); the fix is a harmless local-dev-loop speedup only, same
class of dead end as the `groupAddAssign()` finding below. **Two changes
confirmed genuinely CRAN-relevant** (verified: neither appears in any skip
category of the real `R CMD check` run): several `test_appServer_*`/
`test_reportGV.R` tests left downstream Shiny child modules un-stubbed or
repeated identical fixture computation despite reading nothing new from
them (several seconds each, structural fixes only, no coverage loss); and
`test_addAnimalsWithNoRelative.R` ran an expensive full-3694-row-colony
kinship computation unconditionally (no CRAN skip guard, unlike sibling
files that turned out to be `rmsharp`-login-gated and so contribute zero
real CRAN cost) -- swapped to the smaller `qcPed` fixture already used in
the same function's own roxygen `@examples`, with no historical-bug reason
found for the larger scale (~5.85s -> ~0.01s locally, the single largest
genuinely-CRAN-relevant fix found this session). A proposed `groupAddAssign()`
`iter=1000->50` change was investigated, verified safe, then DROPPED before
implementation once discovered that `test_groupAddAssign.R`'s entire file is
gated the same `rmsharp`-login-only way -- it already contributes zero time
to any real CRAN check, so the fix would have been pointless for this goal.
Full local regression suite re-confirmed clean throughout (`0 failed | 0
error | 0 warning`, identical `1387` tests / `179` skipped coverage under
dev-mode profiling). **Real `R CMD check --as-cran --timings` on the built
tarball** (the authoritative check, run from a renv-activated working
directory after an earlier attempt failed on a stale library path):
`examples` 22s, `tests` 59s, `re-building of vignette outputs` 17s,
`0 errors | 0 warnings | 1 note` (the same expected incoming-feasibility
note), `[ FAIL 0 | WARN 0 | SKIP 208 | PASS 3210 ]`. **Not yet confirmed
against win-builder** -- the CRAN-relevant local savings (appServer*/
reportGV structural fixes plus the addAnimalsWithNoRelative fixture swap,
excluding the CRAN-irrelevant pkgdown fix) total ~13.8s local; at this
project's own established ~2.5-3x local-to-Windows-VM scaling that's
directionally ~35-40s off the 245s win-builder `tests` phase, but a fresh
win-builder run is needed to measure the real combined impact before any
resubmission decision.

## R CMD check results

Local `R CMD check --as-cran --timings` (macOS, R 4.6.1) on the built 2.0.0 tarball:

    0 errors | 0 warnings | 1 note

* NOTE -- checking CRAN incoming feasibility:
  "New submission" and "Package was archived on CRAN" / "Archived on 2025-07-29
  as issues were not corrected in time." This is expected for the resubmission;
  the timing cause is addressed above. This check also reports possibly-
  misspelled words in DESCRIPTION -- "EHR", "Raboin" (an author surname), and
  "kinships" -- confirmed as the exact set flagged identically across all three
  win-builder runs, both this resubmission cycle and the two prior ones. All
  three are spelled correctly. One
  reference URL, <https://www.thoughtco.com/age-sex-pyramids-and-population-pyramids-1435272>,
  returns a 400 to automated checkers (confirmed identically across all three
  win-builder environments this cycle) but is reachable in a browser. A second
  reference URL, <https://pmc.ncbi.nlm.nih.gov/articles/PMC4671785/>, was
  flagged (403) in an earlier check cycle but was NOT flagged in this cycle's
  win-builder runs -- automated URL-reachability checks against PMC appear
  intermittent rather than a fixed pass/fail; it too is reachable in a
  browser.

  (The local-only HTML-manual-Tidy note previously listed here no longer
  appears on this machine's current toolchain.)

## Test environments

**Note:** the results below predate the 2026-07-16 real-submission rejection and
subsequent checktime fix (see the update note above) -- none of these pretest
runs exercise CRAN's incoming "Overall checktime" gate. A fresh win-builder
Windows run is needed to confirm the fix before resubmission.

* Local: macOS, R 4.6.1 -- `R CMD check --as-cran --timings` (results above)
* win-builder R-devel (R Under development (unstable), 2026-07-15 r90261): 0
  errors | 0 warnings | 1 note (incoming feasibility, as above). Re-run
  2026-07-16 (Session 390/391) to confirm the deprecated `structure(...,
  .Names=...)` NOTE fixed in Session 389 is resolved -- confirmed: `checking R
  code for possible problems ... OK` on this run.
* win-builder R-release (R 4.6.1): 0 errors | 0 warnings | 1 note (incoming
  feasibility, as above). Same re-run and confirmation as R-devel above.
* win-builder R-oldrelease (R 4.5.3): 0 errors | 0 warnings | 1 note (incoming
  feasibility, as above). Same re-run and confirmation as R-devel above; the
  prior cycle's `groupAddAssign` >10s timing note on this platform's slower
  hardware did NOT recur this cycle.
* R-hub v2 (R-devel; linux, windows, macos): all three platforms `Status: OK`
  (0 notes), `[ FAIL 0 | WARN 0 | SKIP 221 | PASS 3140 ]` -- fully clean, an
  improvement over the prior cycle's 1 WARN (the intermittent Windows
  `WriteXLS` flake, fixed S363 by switching to `openxlsx`, does not recur
  here). Run "hillocked-veery",
  <https://github.com/rmsharp/nprcgenekeepr/actions/runs/29473979892>.

## Downstream dependencies

There are currently no reverse/downstream dependencies for this package on CRAN
(the `revdep/README.md` Revdeps section is empty).
