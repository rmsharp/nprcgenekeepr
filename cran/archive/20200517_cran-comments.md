## Resubmission
This is a resubmission. In this version I have:

* Responded to both requests provided by the reviewer
  - I have not changed the capitalization of `Shiny` in the description section
    of the DESCRIPTION file as it is the name of the type of application and is
    not being used as the name of the package. The use of the capitalization is
    consistent with the capitalization used within the documentation for the
    `shiny` package (?shiny, See the Details section, first sentence where it
    is used as the type of tutorial.) and all documentation and tutorials 
    provided by the author and RStudio where it is capitalized everywhere 
    except when referring to the package.
  - I have continued to use dontrun for the following examples:
    - runGeneKeepr(), which starts the Shiny application
    - getFocalAnimalPed(), which is dependent on a valid LabKey instance,
      a proper configuration file, and a .netrc or _netrc authentication file.
  - I have exchanged dontrun for donttest for the following examples:
    - create_wkbk()
    - createPedTree()
    - findLoops()
    - countLoops()
    - All 11 examples in data.R
    - makeExamplePedigreeFile()
* I have incremented the version from 1.0.1 to 1.0.2

## Test environments
* local OS X install, R 4.0.0
* travis-ci R version 4.0.0 (2020-04-24) platform: x86_64-pc-linux-gnu (64-bit)
* travis-ci R Under development (unstable) (2020-05-10 r78399) platform: 
* travis-ci R version 4.0.0 (2020-04-24) using platform: 
  x86_64-apple-darwin17.0 (64-bit)
* R-hub Fedora Linux, R-devel, clang, gfortran
* R-hub Ubuntu Linux 16.04 LTS, R-release, GCC
* winbuilder R version 3.6.3 (2020-02-29) using platform: 
  x86_64-w64-mingw32 (64-bit)
* winbuilder R Under development (unstable) (2020-05-15 r78473)
  using platform: x86_64-w64-mingw32 (64-bit)
* winbuilder R version 4.0.0 (2020-04-24) using platform: 
  x86_64-w64-mingw32 (64-bit)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Reverse dependencies

* There are currently no downstream dependencies for this package.

