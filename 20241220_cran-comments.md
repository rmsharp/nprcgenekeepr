## Bug fix and additional unit tests

* Escaped braces in roxygen2 comments to prevent lost braces errors
* Cleaned code based in lintr feedback and added use of lintr in GitHub Actions
  CICD pipeline
* Added additional unit tests
* Added some experimental functions for simulation use
* Added two example deidentified pedigree data sets
* Added Rhub.yaml file for checking on Rhub.

## Test environments
* winbuilder using R Under development (unstable) (2024-12-19 r87451 ucrt)
  using platform: x86_64-w64-mingw32 (64-bit)
* winbuilder using R version 4.4.2 (2024-10-31 ucrt)
  using platform: x86_64-w64-mingw32
* winbuilder using R version 4.3.3 (2024-02-29 ucrt)
  using platform: x86_64-w64-mingw32 (64-bit)
* Rhub environments on 2024-12-19
  * success:
    * linux, macos, macos-arm64, windows, atlas, c23, clang-asan, 
      clang16, clang17, clang18, clang19, clang20, donttest, 
      gcc13, gcc14, intel, mkl, nold, noremap, ubuntu-clang, 
      ubuntu-gcc12, ubuntu-next, ubuntu-release, valgrind
  * failed:
    * nosuggests, rchk
    
## R CMD check results
0 errors | 0 warnings | 1 note

* Words identified as possible misspellings in DESCRIPTION: EHR, Raboin, and 
  kinships are all correctly spelled.
   
## Reverse dependencies

* There are currently no downstream dependencies for this package.

