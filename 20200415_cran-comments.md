## Resubmission
This is a resubmission. In this version I have:

* Responded to all requests provided by the reviewer
  -  Removed redundant "Implements" in the title
  -  Enclosed all package names, software names and API names in single
     quotes in the DESCRIPTION file Description
  -  Added executable examples wrapped in \donttest() in all exported functions
  -  Ensured changes to the user's par() settings were reset using on.exit as 
     directed
  -  Ensured my functions are not modifying in the user's home filespace. I am
     using a path provided by tempdir()
*    Major changes
     -   Changed the name of the package from **nprcmanager** to 
         **nprcgenekeepr**
     -   Added ability to export figures
*    Minor changes
     -   Made changes to allow a clean build and check --as-cran under R 4.0.0
         alpha
     -  Refactored several functions 
     -  Added 12 more unit tests because of what I learned making examples.
     -  Added new functions to improve code and in response to user requests
     -  Corrected several spelling errors
     
## Test environments
* local OS X install, R 3.6.3
* ubuntu 14.04 (on travis-ci), R 3.6.3
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Reverse dependencies

* There are currently no downstream dependencies for this package.

