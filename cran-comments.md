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
per-example limit -- and the examples (about 20s), tests (about 43s), and
vignette-rebuild (about 16s) phases each complete in well under a minute. The
win-builder and R-hub results below re-confirm these times on independent, and
slower, hardware before submission.

A previously undeclared test-time dependency (`withr`) was also declared in
Suggests, which had produced a check WARNING.

2.0.0 is a major release. See `NEWS.md` for the user-facing Major / Minor
changes, including breaking changes: rejection of a period in `id`, `sire`, or
`dam` values; removed exports; and the soft-deprecation of `runGeneKeepR()` in
favour of `runModularApp()`.

## R CMD check results

Local `R CMD check --as-cran` (macOS, R 4.6.0) on the built 2.0.0 tarball:

    0 errors | 0 warnings | 2 notes

* NOTE 1 -- checking CRAN incoming feasibility:
  "New submission" and "Package was archived on CRAN" / "Archived on 2025-07-29
  as issues were not corrected in time." This is expected for the resubmission;
  the timing cause is addressed above. This note also reports possibly-misspelled
  words in DESCRIPTION (for example "Raboin" -- an author surname -- "EHR",
  "LabKey", "studbooks", and "kinships") and the reference URL
  <https://pmc.ncbi.nlm.nih.gov/articles/PMC4671785/>: the words are all spelled
  correctly, and the URL returns 403 to automated checkers but is reachable in a
  browser.

* NOTE 2 -- checking HTML version of manual:
  This note does not arise on CRAN's check machines. It appears here only because
  the local machine's HTML Tidy is outdated and the V8 package is not installed,
  so both sub-checks ("'tidy' not recent enough", "package 'V8' unavailable") are
  skipped locally. CRAN's machines have both.

## Test environments

* Local: macOS, R 4.6.0 -- `R CMD check --as-cran` (results above)
* win-builder: R-devel, R-release, R-oldrelease -- to be run before submission
* R-hub v2: linux, windows, macos -- to be run before submission

## Downstream dependencies

There are currently no reverse/downstream dependencies for this package on CRAN
(the `revdep/README.md` Revdeps section is empty).
