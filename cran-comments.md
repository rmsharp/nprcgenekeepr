## Resubmission

This is a resubmission of an archived package as a new major version, 2.0.0.

`nprcgenekeepr` was archived on CRAN on 2025-07-29 ("Archived ... as issues
were not corrected in time"). It had been accepted and published as 1.0.8 on
2025-07-26; the issue was "Tested elapsed times" (CRAN example/test/vignette
timing limits).

A real submission attempt on 2026-07-16 was rejected by CRAN's incoming
automatic check for Windows r-devel with the same failure class: "Overall
checktime 12 min > 10 min". Fixed by:

* Gating 10 true gene-drop convergence-stress tests behind `skip_on_cran()`
  (`test_gvaConvergence.R`, `test_gvaConvergence_kinshipOverrides.R`).
* Reducing `guIter` from 100L to 20L at ~23 `test_reportGV.R` call sites
  whose assertions don't depend on gu magnitude.
* Reducing `nMax` from 3000L to 1600L in `vignettes/gvaConvergence.Rmd`.
* Reducing `n` from 1000L to 500L in `vignettes/simulatedKValues.Rmd`.
* Removing redundant fixture computation and stubbing un-stubbed child
  modules in the Shiny `testServer()` tests (`test_appServer_*.R`,
  `test_reportGV.R`).
* Shrinking the fixture in `test_addAnimalsWithNoRelative.R` from the full
  3694-row colony to the smaller `qcPed` fixture already used in that
  function's own `@examples`.

A previously undeclared test-time dependency (`withr`) was also declared in
Suggests, fixing a check WARNING.

2.0.0 is a major release. See `NEWS.md` for the user-facing Major/Minor
changes, including breaking changes: rejection of a period in `id`, `sire`,
or `dam` values; removed exports; and `runGeneKeepR()` remaining the primary
Shiny entry point, with `runModularApp()` as a soft-deprecated alias.

## R CMD check results

Local `R CMD check --as-cran --timings` (macOS, R 4.6.1) on the built 2.0.0
tarball: `examples` 22s, `tests` 59s, `re-building of vignette outputs` 17s.

    0 errors | 0 warnings | 1 note

* NOTE -- checking CRAN incoming feasibility: "New submission" and "Package
  was archived on CRAN" / "Archived on 2025-07-29 as issues were not
  corrected in time." Expected for the resubmission. Also reports
  possibly-misspelled words in DESCRIPTION -- "EHR", "Raboin" (an author
  surname), and "kinships" -- all spelled correctly. One reference URL,
  <https://www.thoughtco.com/age-sex-pyramids-and-population-pyramids-1435272>,
  returns a 400 to automated checkers but is reachable in a browser.

## Test environments

* Local: macOS, R 4.6.1 -- `R CMD check --as-cran --timings` (results above)
* win-builder R-devel (R Under development (unstable), 2026-07-16 r90264):
  0 errors | 0 warnings | 1 note (incoming feasibility, as above);
  `checking tests` 200s, `checking examples` 80s, `checking re-building of
  vignette outputs` 65s. Installation time in seconds: 30. Check time in
  seconds: 588 -- under CRAN's 10-minute (600s) mark.
* win-builder R-release (R 4.6.1): 0 errors | 0 warnings | 1 note (incoming
  feasibility, as above).
* win-builder R-oldrelease (R 4.5.3): 0 errors | 0 warnings | 1 note
  (incoming feasibility, as above).
* R-hub v2 (R-devel; linux, windows, macos): all three platforms
  `Status: OK` (0 notes), `[ FAIL 0 | WARN 0 | SKIP 221 | PASS 3140 ]`.

## Downstream dependencies

There are currently no reverse/downstream dependencies for this package on
CRAN (the `revdep/README.md` Revdeps section is empty).
