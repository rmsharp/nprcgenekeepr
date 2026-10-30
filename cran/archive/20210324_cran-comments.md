## Bug fix and additional unit tests
This is a bug fix to allow the shiny app to run under shiny 1.6

* Changed the use of an internal `shiny:::%OR%` function to exported
  `rlang::%||%`.
* Added some unit tests and enhanced the rigor of some unit tests
* Updated all documentation (NEWS, README, and tutorials) with minor technical
  edits.

## Test environments
* local OS X install, R 4.0.4
* travis-ci R version 4.0.2 (2020-06-22) platform: x86_64-pc-linux-gnu (64-bit)
* travis-ci R Under development (unstable) (2021-03-19 r80100) platform: 
  x86_64-pc-linux-gnu (64-bit)
* travis-ci R version 4.0.4 (2021-02-15) using platform: 
  x86_64-apple-darwin17.0 (64-bit)
* R-hub Fedora Linux, R-devel, clang, gfortran
* R-hub Ubuntu Linux 20.04.1 LTS, R-release, GCC
* R-hub Windows Server 2008 R2 SP1, R-devel, 32/64 bit
* winbuilder using R version 3.6.3 (2020-02-29)
  using platform: x86_64-w64-mingw32 (64-bit)
* winbuilder R Under development (unstable) (2021-03-19 r80100)
  using platform: x86_64-w64-mingw32 (64-bit)
* winbuilder R version 4.0.4 (2021-02-15) using platform: 
  x86_64-w64-mingw32 (64-bit)

## R CMD check results

0 errors | 0 warnings | 0 note

-  Some test systems are reading historical sections of the NEWS file and 
   falsely identifying an old URL as possibly incorrect. Please ignore the note.
   
## Reverse dependencies

* There are currently no downstream dependencies for this package.

