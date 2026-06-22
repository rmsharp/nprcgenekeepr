#' Copyright(c) 2017-2024 R. Mark Sharp
# This file is part of nprcgenekeepr
#
# Tests for issue #46 item 1: make `species` a first-class pedigree column.
# A first-class column is (a) recognized by getPossibleCols(), and
# (b) retained, ordered into canonical position, and character-typed by
# qcStudbook() -- NOT relegated to a trailing, untyped novelCol.
library(testthat)

# Minimal, QC-clean pedigree carrying a species column. OFF1's parents both
# have their own rows, so addParents() adds nothing and every row keeps its
# species value.
makeSpeciesPed <- function() {
  data.frame(
    id = c("DAM1", "SIRE1", "OFF1"),
    sire = c(NA, NA, "SIRE1"),
    dam = c(NA, NA, "DAM1"),
    sex = c("F", "M", "F"),
    birth = c("2000-01-15", "2000-02-20", "2005-06-10"),
    species = c("rhesus", "rhesus", "rhesus"),
    stringsAsFactors = FALSE
  )
}

test_that("getPossibleCols() includes species as a canonical column", {
  expect_true("species" %in% getPossibleCols())
})

test_that("qcStudbook keeps species as a first-class column right after sex", {
  ped <- suppressWarnings(qcStudbook(makeSpeciesPed(), minParentAge = NULL))
  expect_true("species" %in% names(ped))
  expect_true(is.character(ped$species))
  expect_setequal(ped$species, "rhesus")
  # First-class => positioned in canonical order (immediately after sex),
  # not appended after every canonical column the way a novelCol would be.
  expect_identical(names(ped)[match("sex", names(ped)) + 1L], "species")
})

test_that("a genuine novel column still trails the canonical species column", {
  base <- makeSpeciesPed()
  # Place the novel column BEFORE species in the input. Were species treated
  # as a novelCol, it would sort AFTER mynote (input order); first-class
  # species must instead sort BEFORE it. (fixColumnNames() lowercases headers,
  # so a lowercase novel name survives the rename unchanged.)
  p <- data.frame(
    id = base$id, sire = base$sire, dam = base$dam, sex = base$sex,
    birth = base$birth,
    mynote = c("x", "y", "z"),
    species = base$species,
    stringsAsFactors = FALSE
  )
  ped <- suppressWarnings(qcStudbook(p, minParentAge = NULL))
  expect_lt(match("species", names(ped)), match("mynote", names(ped)))
})

test_that("species supplied as a factor is coerced to character", {
  p <- makeSpeciesPed()
  p$species <- factor(p$species)
  ped <- suppressWarnings(qcStudbook(p, minParentAge = NULL))
  expect_true(is.character(ped$species))
})

test_that("the shipped JMAC header maps species into a canonical column", {
  # The deidentified JMAC example is the shipped pedigree that carries a
  # species column. Its full QC run halts on a pre-existing sire/dam data
  # conflict unrelated to #46, so we assert on the import column mapping --
  # exactly the "recognized/retained as a first-class field" requirement.
  f <- system.file("extdata", "deidentified_jmac_ped.csv",
                   package = "nprcgenekeepr")
  skip_if(!nzchar(f) || !file.exists(f), "shipped JMAC example not found")
  hdr <- names(read.csv(f, nrows = 1L, stringsAsFactors = FALSE,
                        check.names = FALSE))
  fixed <- fixColumnNames(hdr, getEmptyErrorLst())$newColNames
  expect_true("species" %in% fixed)
  # First-class => species is in the canonical set, so it survives the
  # qcStudbook() canonical intersect rather than trailing as a novelCol.
  expect_true("species" %in% intersect(getPossibleCols(), fixed))
})
