## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md Housekeeping (found S643, confirmed identical on 3 consecutive
## pushes): lint.yaml red on master -- lintr::lint_package()'s
## object_usage_linter reports "no visible global function definition for
## '.formatStructuralDiscrepancy'" at data-raw/kinship2FidelityValidation.R,
## exit code 31 (LINTR_ERROR_ON_LINT: true).
##
## Root cause, confirmed live (S653): CI's lint.yaml runs
## `Rscript -e 'lintr::lint_package()'` directly, with no pkgload::load_all()
## step -- but EVERY local repro this session (lint_package() after
## load_all(), and lint() on the single file in total isolation) showed 0
## lints, because pkgload::load_all()'s own default `helpers = TRUE` silently
## auto-sources tests/testthat/helper-*.R files, attaching
## .formatStructuralDiscrepancy() to the package:nprcgenekeepr search-path
## entry -- masking the exact gap CI's helper-less invocation exposes. This is
## deterministic, not a stale-session artifact (weakens BACKLOG's own
## "stale globalenv" hypothesis to zero): the function genuinely does not
## live in R/, only in a testthat helper, so any caller outside tests/ that
## isn't itself running under load_all()'s helper-sourcing default sees it as
## undefined.
##
## This guard asserts the fix directly and structurally -- the function must
## be defined IN THE PACKAGE NAMESPACE ITSELF (inherits = FALSE rules out
## resolving it via the search path, which is exactly how every local repro
## was fooled) -- following the established test_r_cmd_check_clean_baseline.R
## precedent (S637): parse/probe the actual state a CI check depends on,
## rather than trusting a local repro that a load-order side effect can mask.

test_that(
  ".formatStructuralDiscrepancy is defined in the nprcgenekeepr namespace
   itself, not only via a testthat helper (lint.yaml guard)", {
  expect_true(
    exists(".formatStructuralDiscrepancy",
      where = asNamespace("nprcgenekeepr"), inherits = FALSE),
    info = paste(
      ".formatStructuralDiscrepancy() must be defined in R/ (package",
      "namespace), not only in tests/testthat/helper-",
      "comparePedigreeStructure.R -- otherwise any caller outside tests/",
      "(e.g. data-raw/kinship2FidelityValidation.R) is invisible to",
      "lintr::lint_package()'s object_usage_linter under CI's",
      "helper-less `Rscript -e 'lintr::lint_package()'` invocation",
      "(lint.yaml), even though pkgload::load_all()'s own default",
      "helpers = TRUE masks the gap in every local repro"
    )
  )
})
