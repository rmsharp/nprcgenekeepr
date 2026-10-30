## Resubmission
This is a resubmission. In this version I have:

* Responded to all requests provided by the reviewer
  -  Reduced the time required for unit test from over 12 minutes to 21.6 
     seconds by skipping those test dependent on stochastic creation of 
     simulated pedigrees and breeding groups when not running on my system.
  -  Reduced the time to run examples and create vignettes by reducing the 
     number of stochastic modeling iterations by orders of magnitude without 
     reducing the examples provided for user-facing functions.
  -  Checking (--as-cran --run-donttest) Duration: 2m 21.8s on my system.
  -  The files with the Rd-tag of \arguments missing do not take arguments.
  -  Corrected private referencing (:::) for exported functions.
  -  Exported all functions used in examples to remove private referencing 
     (:::).
  -  Removed all single quotes on names, abbreviations, initialisms, and,
     acronyms.
  -  The phrase Electronic Health Records (EHR) is the name of a module within
     LabKey, which this software can use as a source of pedigree information
     so the capitalization is appropriate.
  -  The words suspected of being misspelled (EHR, Roboin, and kinships) are
     an initialism of a module in LabKey, a proper name, and a genetic term 
     respectively.

## Test environments
* local OS X install, R 4.0.0
* travis-ci R version 4.0.0 (2020-04-24) platform: x86_64-pc-linux-gnu (64-bit)
* travis-ci R Under development (unstable) (2020-05-10 r78399) platform: 
* travis-ci R version 4.0.0 (2020-04-24) using platform: 
  x86_64-apple-darwin17.0 (64-bit)
* R-hub Fedora Linux, R-devel, clang, gfortran
* R-hub Ubuntu Linux 16.04 LTS, R-release, GCC
* winbuilder R version 3.6.3 (2020-02-29)
* winbuilder R Under development (unstable) (2020-05-08 r78391)
* winbuilder R version 4.0.0 (2020-04-24)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Reverse dependencies

* There are currently no downstream dependencies for this package.

