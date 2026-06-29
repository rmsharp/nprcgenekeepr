## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

data("qcBreeders")
data("qcPed")
skip_if_not(exists("qcBreeders"))
skip_if_not(exists("qcPed"))
test_that("addSexAndAgeToGroup forms the correct dataframe", {
  df <- addSexAndAgeToGroup(ids = qcBreeders, ped = qcPed)
  expect_length(df, 3L)
  expect_length(df[["ids"]], 29L)
  expect_named(df, c("ids", "sex", "age"))
  expect_identical(df$ids[1L], "Q0RGP7")
  expect_identical(as.character(df$sex[1L]), "F")
})
test_that("addSexAndAgeToGroup pins sex as a factor matching the pedigree", {
  # Characterization guard (REFACTOR): locks the factor sex + full levels and
  # the per-id sex values against the pedigree, so the sapply -> match() change
  # is provably contract-preserving. Passes on both the old and new forms.
  df <- addSexAndAgeToGroup(ids = qcBreeders, ped = qcPed)
  expect_s3_class(df$sex, "factor")
  expect_identical(levels(df$sex), levels(qcPed$sex))
  expect_identical(df$sex, qcPed$sex[match(qcBreeders, qcPed$id)])
})
test_that("addSexAndAgeToGroup keeps the full 3-column schema for empty ids", {
  # Empty group: the result keeps all three documented columns (sex an empty
  # factor) rather than dropping sex, so callers that set three colnames (e.g.
  # the modBreedingGroups group-member view) handle empty groups without
  # crashing. Fails on the pre-match() sapply form, which returned two columns.
  df <- addSexAndAgeToGroup(ids = character(0), ped = qcPed)
  expect_named(df, c("ids", "sex", "age"))
  expect_identical(nrow(df), 0L)
  expect_s3_class(df$sex, "factor")
})
