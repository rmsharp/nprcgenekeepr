## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Issue #123 (XARCH-5) Phase 1: single internal source of truth for
## getRequiredCols()/getPossibleCols()/getIncludeColumns(), which become
## one-line pass-throughs over this list. A named list, not a data.frame: the
## three roles have independently load-bearing element orders (callers rely
## on intersect()'s x-order to fix output column order; see
## test_reportGV.R's exact-name pin, test_getPossibleCols.R,
## test_getIncludeColumns.R) -- a single row-per-column table can only
## preserve one role's order for free. Vectors are byte-identical to the
## pre-consolidation getters' return values; the existing expect_identical()
## pins in test_getPossibleCols.R/test_getIncludeColumns.R are the regression
## guard that nothing about them (including order) changed.
.nprcColumnSchema <- list(
  required = c("id", "sire", "dam", "sex", "birth"),
  include  = c("id", "sex", "age", "birth", "exit", "population",
               "condition", "origin", "first_name", "second_name"),
  possible = c("id", "sire", "dam", "sex", "species", "gen", "birth",
               "exit", "death", "age", "ancestry", "population", "origin",
               "status", "condition", "departure", "spf", "vasxOvx",
               "pedNum", "first", "second", "first_name", "second_name",
               "recordStatus")
)
