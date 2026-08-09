## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
#
# Tests for issue #136 Slice 1: make `name` a first-class, optional pedigree
# column (docs/planning/issue136-name-labels-pedigree-diagram-plan.md).
# A first-class column is (a) recognized by getPossibleCols(), and
# (b) retained, ordered ahead of genuine novel columns, and character-typed
# by qcStudbook() -- NOT relegated to a trailing, untyped novelCol.
# Modelled on test_species_first_class.R (issue #46).
library(testthat)

# Minimal, QC-clean pedigree carrying a name column. OFF1 has no name
# recorded (NA) -- exercising the "some centers, inconsistently" case (D4)
# even at unit-test scale. Parents both have their own rows, so
# addParents() adds nothing and every row keeps its own name value.
makeNamePed <- function() {
  data.frame(
    id = c("DAM1", "SIRE1", "OFF1"),
    sire = c(NA, NA, "SIRE1"),
    dam = c(NA, NA, "DAM1"),
    sex = c("F", "M", "F"),
    birth = c("2000-01-15", "2000-02-20", "2005-06-10"),
    name = c("Willow", "Ranger", NA),
    stringsAsFactors = FALSE
  )
}

test_that("getPossibleCols() includes name as a canonical column", {
  expect_true("name" %in% getPossibleCols())
})

test_that("qcStudbook keeps name first-class: character-typed, ahead of any genuine novel column", {
  base <- makeNamePed()
  # Place a genuine novel column BEFORE name in the input. Were name treated
  # as a novelCol, it would sort AFTER mynote (input order); first-class name
  # must instead sort BEFORE it, regardless of input order.
  p <- data.frame(
    id = base$id, sire = base$sire, dam = base$dam, sex = base$sex,
    birth = base$birth,
    mynote = c("x", "y", "z"),
    name = base$name,
    stringsAsFactors = FALSE
  )
  ped <- suppressWarnings(qcStudbook(p, minParentAge = NULL))
  expect_true("name" %in% names(ped))
  expect_true(is.character(ped$name))
  expect_identical(ped$name[ped$id == "DAM1"], "Willow")
  expect_true(is.na(ped$name[ped$id == "OFF1"]))
  expect_lt(match("name", names(ped)), match("mynote", names(ped)))
})

test_that("name supplied as a factor is coerced to character", {
  p <- makeNamePed()
  p$name <- factor(p$name)
  ped <- suppressWarnings(qcStudbook(p, minParentAge = NULL))
  expect_true(is.character(ped$name))
})

test_that("fixColumnNames rewrites ego_name to idname, not name (trap 4)", {
  # Pre-RED verified (docs/planning/issue136-name-labels-pedigree-diagram-
  # plan.md sec 2.7 trap 4): fixColumnNames() is schema-agnostic, so this
  # already holds today with zero implementation change -- included here as
  # disclosed documentation/regression coverage, not a RED-driving test.
  # It pins the collision hazard: only the bare spelling "name" is safe;
  # "ego_name" collapses onto the id-rename rule ("ego" -> "id"), same as any
  # other "*ego*"-containing header.
  fixed <- fixColumnNames(c("ego_name", "name", "Name"),
                          getEmptyErrorLst())$newColNames
  expect_identical(fixed, c("idname", "name", "name"))
})

test_that("removeDuplicates errors on duplicate ids with differing name values (trap 3)", {
  # Pre-RED verified (plan sec 2.7 trap 3): removeDuplicates() dedups via
  # unique() on the whole row, so two rows sharing an id but differing only
  # in name survive that step as distinct rows, then trip the existing
  # anyDuplicated(id) check -- already true today with zero implementation
  # change. Included here as disclosed documentation/regression coverage
  # (the plan's own DONE criterion), not a RED-driving test.
  ped <- nprcgenekeepr::smallPed
  newPed <- cbind(ped, recordStatus = rep("original", nrow(ped)),
                  name = NA_character_)
  dupRow <- newPed[1L, ]
  dupRow$name <- "Different Name"
  pedWithDupNameMismatch <- rbind(newPed, dupRow)
  expect_error(removeDuplicates(pedWithDupNameMismatch))
})
