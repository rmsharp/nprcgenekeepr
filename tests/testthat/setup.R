## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Issue #119 Slice 1: the quality-control entry points (checkParentAge,
## qcStudbook, runQcStudbook) now deprecate the scalar `minParentAge` alias via
## lifecycle::deprecate_warn() in favor of the sex-specific minSireAge /
## minDamAge parameters. Many tests still exercise `minParentAge` as legacy
## setup, or as the historical "disable the age check" idiom
## (minParentAge = NULL). Keep the package's OWN test run quiet about its OWN
## deprecations: external callers still see the warning (they do not set this
## option), and every test that asserts a deprecation forces
## `lifecycle_verbosity = "warning"` locally (via lifecycle::expect_deprecated()
## or withr::local_options()), so those are unaffected by this global default.
options(lifecycle_verbosity = "quiet")
