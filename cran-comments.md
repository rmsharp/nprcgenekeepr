## Update

This is an update from 2.0.0 (on CRAN since 2026-07-26) to 3.0.0, a major
release. It adds interactive pedigree diagrams, marker-based genetic analysis,
MHC haplotype reporting, cross-center identity matching, ancestry-aware
breeding safeguards, de-identified export workflows and longitudinal monitoring
of colony genetic health. It adds 54 exported functions and removes none. See
`NEWS.md`.

## The linux-arm64 additional issue on 2.0.0

CRAN's check page for 2.0.0 lists an additional issue on linux-arm64: failed
expectations in `test_modInput_incomplete_final_line.R`. The cause is in R's
own file reader, not in this package. On Linux ARM64, `read.csv()` and
`read.table()` add a stray 0xFF byte to a quoted last value in a file that has
no final newline (utils `readtablehead()`, `src/library/utils/src/io.c`):

    f <- tempfile()
    writeChar('a,b\n1,"x"', f, eos = NULL)
    charToRaw(read.csv(f)$b)
    ## 78 ff on Linux ARM64, R 4.6.1
    ## 78    on macOS arm64, R 4.6.1

3.0.0 works around this: every `read.csv()` and `read.table()` in the package
now reads through a copy that ends in a newline when the file does not. In that
job's own container image (`ghcr.io/r-devel/rcheckserver/ubuntu:latest`,
R 4.6.1), `R CMD check --as-cran --no-manual` of the 3.0.0 tarball reads
`Status: OK`. That job checks published versions only, so CRAN's own run can
confirm the fix only after this release.

## Check time

The first 2.0.0 submission was rejected for "Overall checktime 12 min > 10 min",
and the package has grown since. A CRAN check therefore runs about 80 of the 496
test files, chosen by a run-time trace so that each of the 236 exported functions
is still called by a test it runs. Continuous integration runs every test file.

* win-builder "Check time in seconds" for 3.0.0: R-devel 284, R-release 303,
  R-oldrelease 599. One earlier tarball read 617 and 520 on R-devel, so the
  figure varies from run to run.

## R CMD check results

Local `R CMD check --as-cran` (macOS arm64, R 4.6.1) of the built 3.0.0 tarball:

    0 errors | 0 warnings | 0 notes

    [ FAIL 0 | WARN 0 | SKIP 54 | PASS 1923 ]

win-builder gives 1 NOTE on all three R versions, from incoming feasibility:

* Possibly misspelled in DESCRIPTION: "de", from "de-identified", which is
  correct.
* The reference URL
  <https://www.thoughtco.com/age-sex-pyramids-and-population-pyramids-1435272>
  returns an error status to automated checkers (402 on win-builder) but is
  reachable in a browser.

## Test environments

* Local: macOS arm64, R 4.6.1: `Status: OK` (results above).
* Linux ARM64, the image named above, R 4.6.1: `Status: OK`,
  `[ FAIL 0 | WARN 0 | SKIP 54 | PASS 1923 ]`.
* GitHub Actions, the same code: windows-latest (release), macos-latest
  (release), ubuntu-latest (devel, release, oldrel-1): all passed.
* win-builder R-devel (2026-10-30 r90805): 0 errors, 0 warnings, 1 NOTE (above).
* win-builder R-release (4.6.2): 0 errors, 0 warnings, 1 NOTE (above).
* win-builder R-oldrelease (4.5.3): 0 errors, 0 warnings, 1 NOTE (above).
* R-hub v2 (linux, windows, macos; R-devel 4.7.0): `Status: OK` on each,
  `[ FAIL 0 | WARN 0 | SKIP 54 | PASS 1923 ]`.

## Downstream dependencies

There are no reverse dependencies on CRAN
(`tools::package_dependencies(reverse = TRUE, which = "all")` returns none).
