## Resubmission
This is a resubmission. In this version I have:

* Responded to each request provided by the reviewer
  - Requests from 20250419:
    -  Used ::: in documentation:
         man/fillGroupMembersWithSexRatio.Rd:
            groupMembers <- nprcgenekeepr:::makeGroupMembers(numGp, 
              currentGroups, candidates, ped, harem = harem, minAge = minAge)
         man/fillGroupMembersWithSexRatio.Rd:
            grpNum <- nprcgenekeepr:::makeGrpNum(numGp)
         Please omit one colon.
      - I have exported both makeGroupMembers() and makeGrpNum() to remove the 
        use of ::: in the documentation.
    - Use suppressable messages to the console.
      - I have changed the use of cat() to message() in R/createPedOne.R and
        R/makeSimPed.R
  - Please do not set a seed to a specific number within a function.
    -> R/createPedOne.R; R/createPedSix.R
    -  These two functions are dynamically generating pedigrees with functions
       that use psuedo-random number generators. The purpose of these functions
       is to generate the same pedigrees each time for testing and instructional
       purposes. Thus, I continue to set the seed to a specific number within
       these functions.
  - Request from 20250415: Please reduce each example to less than 5 sec.
    I have dramatically shortened the example code run time for
    makeRelationClassesTable and fillGroupMembersWithSexRatio by truncating
    the pedigrees used. I have added a comment to the user to comment out the
    truncation code to see a more genetically realistic example.
  - Request: please write 'Shiny' as 'shiny', as package names are 
    case-sensitive.
    -   I have not changed the capitalization of `Shiny` in the description 
        section of the DESCRIPTION file as it is the name of the type of 
        application and is not being used as the name of the package. The use
        of the capitalization is consistent with the capitalization used within
        the documentation for the `shiny` package (?shiny, See the Details 
        section, first sentence where it is used as the type of tutorial.) 
        and all documentation and tutorials provided by the author and RStudio
        where it is capitalized everywhere except when referring to the package.
  - Request: It seems like you have too many spaces in your description field. 
    Probably because linebreaks count as spaces too. Please remove unecassary 
    ones.
    -  I have removed the extra spaces from the description field in the 
       DESCRIPTION file, which occurred at the end of some of the lines. The 
       remaining occurrences of multiple consecutive spaces are at the
       beginning of lines, which are required for their mandatory indentation.
  - Request: Please add \value to .Rd files regarding exported methods and
    explain the functions results in the documentation. Please write about the
    structure of the output (class) and also what the output means. (If a
    function does not return a value, please document that too, e.g.,
    \value{No return value, called for side effects} or similar).
    -  I have provided \value elements to all functions except the following,
       which are documentation elements:
       - data.R
       - nprcgenekeeper.R
       - nprcgenekeepr-package.R
    -  Running checkhelper::find_missing_tags() found there is no missing or
       empty return value for exported functions and no missing `@export` or 
       `@noRd` in the documentation
  - Request: Please unwrap the examples if they are executable in < 5 sec, or
    replace dontrun{} with \donttest{}.
    \dontrun{} should only be used if the example really cannot be executed
    (e.g. because of missing additional software, missing API keys, ...) by the
    user. That's why wrapping examples in \dontrun{} adds the comment 
    ("# Not run:") as a warning for the user. Does not seem necessary. 
    Please replace \dontrun with \donttest.
    -   I have removed all instances of \dontrun.
    -   I have replaced \dontrun with wrapping with if (interactive()) {} for 
        its use in the example for runGeneKeepR() because Shiny apps don't run 
        in R CMD check.
  - Request: Please do not set a seed to a specific number within a function.
    For more details: <https://contributor.r-project.org/cran-cookbook/code_issues.html#setting-a-specific-seed>
    -  I have not made any changes based on this request as I have restricted 
       the use of setting a seed to those situations where each function's 
       purpose is to dynamically create a data set for instructional or unit 
       testing purposes. In both cases, producing identical results each time
       is critical to the purpose of the function.

* I have incremented the version from 1.0.6 to 1.0.7, updated NEWS to reflect
  the changes, and updated all documentation to reflect the version change.

## Test environments
* Rhub environments on 2025-04-12
  * success with R Under development (unstable) (2025-04-04 r88112):
     * atlas on Fedora Linux 38
     * c23 on Ubuntu 22.04.5
     * clang-asan on Ubuntu 22.04.5
     * clang-ubsan on Ubuntu 22.04.5
     * clang16 on Ubuntu 22.04.5
     * clang17 on Ubuntu 22.04.5
     * clang18 on Ubuntu 22.04.5
     * clang19 on Ubuntu 22.04.5
     * clang20 on Ubuntu 22.04.5
     * donttest on Ubuntu 22.04.5
     * gcc-asan on Fedora Linux 40
     * gcc13 on Fedora Linux 38
     * gcc14 on Fedora Linux 40
     * intel on Fedora Linux 38
     * mkl on Fedora Linux 38
     * nold on Ubuntu 22.04.5
     * noremap on Ubuntu 22.04.5
     * valgrind on Fedora Linux 38
  * success on Ubuntu 22.04.5
     * ubuntu-clang  [r-devel-linux-x86_64-debian-clang]
     * ubuntu-gcc12  [r-devel-linux-x86_64-debian-gcc]
     * ubuntu-next  [r-next, r-patched, r-patched-linux-x86_64]
     * ubuntu-release  [r-release, r-release-linux-x86_64, ubuntu] R version 4.4.3 (2025-02-28)
  * success windows R Under development (unstable) (2025-04-11 r88138 ucrt)
  * failure with R Under development (unstable) (2025-04-04 r88112):
     * gcc15 on Fedora Linux 42 dependency httpuv could not be built
     * nosuggests on Fedora Linux 38 dplyr was not available (in Suggests)
     * rchk on Ubuntu 22.04.5 I was unable to understand the output
* devtools::check_mac_release()
  * Build system: r-release-macosx-arm64|4.4.2|macosx|macOS 13.3.1 (22E261)|
    Mac mini|Apple M1||en_US.UTF-8|macOS 11.3|clang-1403.0.22.14.1|
    GNU Fortran (GCC) 14.2.0
  * Status OK
* devtools::check_win_devel() and devtools::check_win_release() both had the 
  same two notes. The 1st about possible misspelled words is addressed below.
  The 2nd indicates that an URL may be inaccessable and it is accessable as of
  2025-04-12 15:58:38 CDT
    
## R CMD check results
── R CMD check results ───────────────────────────────────────────────── nprcgenekeepr 1.0.7 ────
Duration: 1m 40.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

* Words identified as possible misspellings in DESCRIPTION: EHR, Raboin, and 
  kinships are all correctly spelled.
   
## Reverse dependencies
### revdepcheck results

We checked 0 reverse dependencies, comparing R CMD check results across CRAN 
and dev versions of this package.

 * We saw 0 new problems
 * We failed to check 0 packages
