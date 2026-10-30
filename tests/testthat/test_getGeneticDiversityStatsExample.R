## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Prepare the 3.0.0 CRAN submission", plan Phase 2 (owner pick
## S1095, "Example+loops+skip 315"; docs/planning/cran-3.0.0-submission-plan.md
## section 3.4). The getGeneticDiversityStats() help example took 15.2 s on
## win-builder, a NOTE in its incoming check (S1094): it built a genetic-value
## report and a kinship matrix of the whole shipped example (3,694 animals),
## 3.2 s here, 2.5 s of it in reportGV(). The example now reads the stored
## report of the 280-animal qcPed (qcPedGvReport), 0.04 s here. That it still
## runs clean and returns the group table is test_docsAuditLeftoverWording.R's
## DA3 block.

## exampleLines() reads the source tree's man page (helper-pageText.R).

test_that("the getGeneticDiversityStats() example builds no genetic-value report", {
  code <- exampleLines("getGeneticDiversityStats")
  expect_gt(length(code), 0L)
  expect_false(any(grepl("reportGV(", code, fixed = TRUE)))
})

test_that("the getGeneticDiversityStats() example does not read the 3,694-animal example pedigree", {
  code <- exampleLines("getGeneticDiversityStats")
  expect_gt(length(code), 0L)
  expect_false(any(grepl("examplePedigree", code, fixed = TRUE)))
})
