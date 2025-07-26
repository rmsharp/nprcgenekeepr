## Bug fix in unit test plus minor code style improvements
This is a bug fix in the unit test `test-get_elapsed_time_str.R`, which was
unnecessarily using `proc.time()` to measure elapsed time. Its use has
been replaced by mocking `proc.time()` using the `mockery` package.

## Test environments (P/F; Pass/Fail)

*  There were 18 Passes (P)
*  There were 12 Failures (F)
   *   2 m1-san and macos-arm64 had "ERROR: compilation failed for package ‘httpuv’"
   *   1 rchk had "No files were found with the provided path: check."
   *   9 had "there is no package called ‘pak’"
 
── Virtual machines ─────────────────

*  P  1 linux
   All R versions on GitHub Actions ubuntu-latest
*  F  2 m1-san ERROR: compilation failed for package ‘httpuv’
   All R versions on GitHub Actions macos-15, ASAN + UBSAN on macOS
*  P  3 macos
   All R versions on GitHub Actions macos-13
*  F  4 macos-arm64 ERROR: compilation failed for package ‘httpuv’
   All R versions on GitHub Actions macos-latest
*  P  5 windows
   All R versions on GitHub Actions windows-latest

── Containers ────────────────────────

*  F  6 atlas  [ATLAS] - there is no package called ‘pak’
   R Under development (unstable) (2025-07-15 r88411) on Fedora Linux 38 (Container Image)
   ghcr.io/r-hub/containers/atlas:latest
*  P  7 c23  [C23]
   R Under development (unstable) (2025-07-15 r88411) on Ubuntu 22.04.5 LTS
   ghcr.io/r-hub/containers/c23:latest
*  P  8 clang-asan  [asan, clang-ASAN]
   R Under development (unstable) (2025-07-15 r88411) on Ubuntu 22.04.5 LTS
   ghcr.io/r-hub/containers/clang-asan:latest
*  P  9 clang-ubsan  [clang-UBSAN, ubsan]
   R Under development (unstable) (2025-07-15 r88411) on Ubuntu 22.04.5 LTS
   ghcr.io/r-hub/containers/clang-ubsan:latest
*  P 10 clang16  [clang16]
   R Under development (unstable) (2025-07-15 r88411) on Ubuntu 22.04.5 LTS
   ghcr.io/r-hub/containers/clang16:latest
*  P 11 clang17  [clang17]
   R Under development (unstable) (2025-07-15 r88411) on Ubuntu 22.04.5 LTS
   ghcr.io/r-hub/containers/clang17:latest
*  P 12 clang18  [clang18]
   R Under development (unstable) (2025-07-15 r88411) on Ubuntu 22.04.5 LTS
   ghcr.io/r-hub/containers/clang18:latest
*  P 13 clang19  [clang19]
   R Under development (unstable) (2025-07-15 r88411) on Ubuntu 22.04.5 LTS
   ghcr.io/r-hub/containers/clang19:latest
*  P 14 clang20  [clang20]
   R Under development (unstable) (2025-06-03 r88266) on Ubuntu 22.04.5 LTS
   ghcr.io/r-hub/containers/clang20:latest
*  P 15 donttest  [donttest]
   R Under development (unstable) (2025-07-15 r88411) on Ubuntu 22.04.5 LTS
   ghcr.io/r-hub/containers/donttest:latest
*  F 16 gcc-asan  [gcc-ASAN, gcc-UBSAN] there is no package called ‘pak’
   R Under development (unstable) (2025-07-15 r88411) on Fedora Linux 40 (Container Image)
   ghcr.io/r-hub/containers/gcc-asan:latest
*  F 17 gcc13  [gcc13] there is no package called ‘pak’
   R Under development (unstable) (2025-07-15 r88411) on Fedora Linux 38 (Container Image)
   ghcr.io/r-hub/containers/gcc13:latest
*  F 18 gcc14  [gcc14] there is no package called ‘pak’
   R Under development (unstable) (2025-07-15 r88411) on Fedora Linux 40 (Container Image)
   ghcr.io/r-hub/containers/gcc14:latest
*  F 19 gcc15  [gcc15] there is no package called ‘pak’
   R Under development (unstable) (2025-07-15 r88411) on Fedora Linux 42 (Container Image)
   ghcr.io/r-hub/containers/gcc15:latest
*  F 20 intel  [Intel] there is no package called ‘pak’
   R Under development (unstable) (2025-07-15 r88411) on Fedora Linux 38 (Container Image)
   ghcr.io/r-hub/containers/intel:latest
*  F 21 mkl  [MKL] there is no package called ‘pak’
   R Under development (unstable) (2025-07-15 r88411) on Fedora Linux 38 (Container Image)
   ghcr.io/r-hub/containers/mkl:latest
*  P 22 nold  [noLD]
   R Under development (unstable) (2025-07-15 r88411) on Ubuntu 22.04.5 LTS
   ghcr.io/r-hub/containers/nold:latest
*  P 23 noremap  [noRemap]
   R Under development (unstable) (2025-07-15 r88411) on Ubuntu 22.04.5 LTS
   ghcr.io/r-hub/containers/noremap:latest
*  F 24 nosuggests  [noSuggests] there is no package called ‘pak’
   R Under development (unstable) (2025-07-15 r88411) on Fedora Linux 38 (Container Image)
   ghcr.io/r-hub/containers/nosuggests:latest
*  F 25 rchk  [rchk] No files were found with the provided path: check.
   R Under development (unstable) (2025-07-15 r88411) on Ubuntu 22.04.5 LTS
   ghcr.io/r-hub/containers/rchk:latest
*  P 26 ubuntu-clang  [r-devel-linux-x86_64-debian-clang]
   R Under development (unstable) (2025-07-15 r88411) on Ubuntu 22.04.5 LTS
   ghcr.io/r-hub/containers/ubuntu-clang:latest
*  P 27 ubuntu-gcc12  [r-devel-linux-x86_64-debian-gcc]
   R Under development (unstable) (2025-07-15 r88411) on Ubuntu 22.04.5 LTS
   ghcr.io/r-hub/containers/ubuntu-gcc12:latest
*  P 28 ubuntu-next  [r-next, r-patched, r-patched-linux-x86_64]
   R version 4.5.1 Patched (2025-07-14 r88411) on Ubuntu 22.04.5 LTS
   ghcr.io/r-hub/containers/ubuntu-next:latest
*  P 29 ubuntu-release  [r-release, r-release-linux-x86_64, ubuntu]
   R version 4.5.1 (2025-06-13) on Ubuntu 22.04.5 LTS
   ghcr.io/r-hub/containers/ubuntu-release:latest
*  F 30 valgrind  [valgrind] there is no package called ‘pak’
   R Under development (unstable) (2025-07-15 r88411) on Fedora Linux 38 (Container Image)
   ghcr.io/r-hub/containers/valgrind:latest

## Local R CMD check results

0 errors | 0 warnings | 0 note

*  Some test systems are reading historical sections of the NEWS file and 
   falsely identifying an old URL as possibly incorrect. Please ignore the note.
*  Automated tests indicate that 
   URL: https://pmc.ncbi.nlm.nih.gov/articles/PMC4671785/
   is inaccessable (403) and it is accessable as of 2025-07-25 CST.
   I suspect the website is blocked to the automated access request.
*  Words identified as possible misspellings in DESCRIPTION: EHR, Raboin, and
   kinships are all correctly spelled.


## Reverse dependencies

* There are currently no downstream dependencies for this package.

## Reverse dependencies

* There are currently no downstream dependencies for this package.

