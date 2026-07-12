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

## R CMD check results

Local `R CMD check --as-cran --timings` (macOS, R 4.6.1) on the built 2.0.0 tarball:

    0 errors | 0 warnings | 1 note

* NOTE -- checking CRAN incoming feasibility:
  "New submission" and "Package was archived on CRAN" / "Archived on 2025-07-29
  as issues were not corrected in time." This is expected for the resubmission;
  the timing cause is addressed above. This check also reports possibly-
  misspelled words in DESCRIPTION -- "EHR", "Raboin" (an author surname), and
  "kinships" -- confirmed as the exact set flagged identically across all three
  win-builder runs, both this resubmission cycle and the prior one. All three
  are spelled correctly. Two
  reference URLs, <https://pmc.ncbi.nlm.nih.gov/articles/PMC4671785/> and
  <https://www.thoughtco.com/age-sex-pyramids-and-population-pyramids-1435272>,
  return 403 to automated checkers (confirmed via `curl` with a browser user
  agent and an independent fetch, both blocked) but are reachable in a browser.

  (The local-only HTML-manual-Tidy note previously listed here no longer
  appears on this machine's current toolchain.)

## Test environments

* Local: macOS, R 4.6.1 -- `R CMD check --as-cran --timings` (results above)
* win-builder R-devel (R Under development (unstable), 2026-07-10 r90234): 0
  errors | 0 warnings | 1 note (incoming feasibility, as above)
* win-builder R-release (R 4.6.1): 0 errors | 0 warnings | 1 note (incoming
  feasibility, as above)
* win-builder R-oldrelease (R 4.5.3): 0 errors | 0 warnings | 2 notes (incoming
  feasibility, as above; plus one timing note -- `groupAddAssign` example ran
  10.06s on win-builder's slower hardware, just over the 10s reporting
  threshold. Not a check failure; the example itself completes and passes)
* R-hub v2 (R-devel; linux, windows, macos): all three platforms `Status: OK`,
  0 test failures

## Downstream dependencies

There are currently no reverse/downstream dependencies for this package on CRAN
(the `revdep/README.md` Revdeps section is empty).
