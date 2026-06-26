#' Copyright(c) 2017-2024 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)

test_that("summary.nprcgenekeeprGV provides expected output", {
  skip_on_cran()
  set_seed(10L)
  ped <- nprcgenekeepr::pedOne
  ped$birth_date[ped$ego_id == "d2"] <- "2000-04-13"
  ped$birth_date[ped$ego_id == "o4"] <- "2016-04-13"
  ped <- suppressWarnings(qcStudbook(ped, reportErrors = FALSE))
  gvReport <- reportGV(ped, guIter = 10L)
  summaryGV <- summary(gvReport)
  expect_identical(summaryGV[1L], "The genetic value report")
  expect_length(summaryGV, 8L)
})

# Issue #82 Slice 3: the text summary shows the founder-genome-equivalent
# sampling SE inline ("Founder Genome Equivalents: FG +/- SE") when the object
# carries fgSE, and degrades to the bare FG (no dangling "+/-") for objects that
# lack it or carry NA. As of S210 the bundled GV reports are regenerated and
# carry fgSE, so qcPedGvReport surfaces the SE inline; the absent-fgSE
# backward-compat path (a user's pre-2.0.0 saved report) is exercised by
# stripping fgSE from a copy.
test_that("summary.nprcgenekeeprGV shows FG +/- SE inline when fgSE present (issue #82 Slice 3)", {
  gv <- nprcgenekeepr::qcPedGvReport
  gv$fgSE <- 0.05
  out <- summary(gv)
  fgLine <- out[grepl("Founder Genome Equivalents:", out)]
  expect_length(fgLine, 1L)
  expect_match(fgLine, "Founder Genome Equivalents: 52.75 \\+/- 0.05")
})

test_that("summary.nprcgenekeeprGV surfaces the regenerated bundled fgSE inline (issue #82, S210)", {
  ## the regenerated bundled object carries its own fgSE -> shown inline,
  ## value-agnostic (the exact SE is golden data, pinned by test_reportGV.R)
  out <- summary(nprcgenekeepr::qcPedGvReport)
  fgLine <- out[grepl("Founder Genome Equivalents:", out)]
  expect_length(fgLine, 1L)
  expect_match(fgLine, "^Founder Genome Equivalents: 52\\.75 \\+/- [0-9]+\\.[0-9]{2}$")
})

test_that("summary.nprcgenekeeprGV degrades to bare FG when fgSE absent or NA (issue #82 Slice 3)", {
  ## absent (a user's pre-2.0.0 saved report, predating fgSE) -> bare FG,
  ## nothing trailing. Construct it by stripping fgSE from a copy so the
  ## backward-compat path is tested independent of the bundled object.
  gvabs <- nprcgenekeepr::qcPedGvReport
  gvabs$fgSE <- NULL
  out <- summary(gvabs)
  fgLine <- out[grepl("Founder Genome Equivalents:", out)]
  expect_match(fgLine, "Founder Genome Equivalents: 52\\.75$")
  expect_false(grepl("\\+/-", fgLine))

  ## NA fgSE -> still bare FG, no dangling "+/- NA"
  gvna <- nprcgenekeepr::qcPedGvReport
  gvna$fgSE <- NA_real_
  outna <- summary(gvna)
  fgLineNa <- outna[grepl("Founder Genome Equivalents:", outna)]
  expect_false(grepl("\\+/-", fgLineNa))
})
