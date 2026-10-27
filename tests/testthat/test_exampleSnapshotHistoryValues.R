## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:237 (found S1070, picked at the S1071 Phase 0 picker): the
## shipped example snapshot history, written by hand at S757, holds values the
## package never makes. Measured S1071 against the package's definitions and
## against createColonySnapshot() rows of qcPed and of the example colony's
## living animals:
## - neGD was 42.5, 43.1, 43.8 and 30.4, where reportGV() gives gene
##   diversity, 1 - 1 / (2 * fg) (calcGeneDiversity()), a share between 0 and
##   1, as the Trends tab's "Reading the trend" box says;
## - meanGu, medianGu and meanGuSE were about 0.2, 0.2 and 0.004: shares, where
##   calcGU() reports genome uniqueness as a percentage (the example colony:
##   22.8, 14.4 and 0.28);
## - the two kurtosis columns were 2.8 to 3.2, where calcKurtosis() gives
##   excess kurtosis, 0 for a bell curve (the example colony: -0.28 and 0.88).
## Owner ruling (S1071, "All three"): neGD from each row's own fg, rounded to
## 4 decimals; genome uniqueness multiplied by 100; kurtosis lowered by 3, so
## every panel keeps the direction the example was written to show. The
## provenance columns, the dates and the four rows stay as they were.

## validatedSnapshotHistory() is in helper-snapshotHistory.R.

test_that("every row's neGD is the gene diversity its own fg gives", {
  history <- validatedSnapshotHistory()
  expect_equal(history$neGD, round(1 - 1 / (2 * history$fg), 4L))
  expect_equal(history$neGD, c(0.9419, 0.9432, 0.9444, 0.9194))
})

test_that("genome uniqueness is a percentage on every row", {
  history <- validatedSnapshotHistory()
  expect_equal(history$meanGu, c(21.3, 21.9, 22.4, 19.8))
  expect_equal(history$medianGu, c(20.5, 21.1, 21.6, 19.2))
  expect_equal(history$meanGuSE, c(0.41, 0.40, 0.28, 0.33))
})

test_that("kurtosis is excess kurtosis, 0 for a bell curve, on every row", {
  history <- validatedSnapshotHistory()
  expect_equal(history$kurtosisIndivMeanKin, c(-0.1, -0.2, -0.2, 0.2))
  expect_equal(history$kurtosisGu, c(0.1, 0.0, 0.0, 0.1))
})
