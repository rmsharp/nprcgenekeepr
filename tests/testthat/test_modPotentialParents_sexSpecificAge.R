## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Issue #119 Slice 4 -- modPotentialParentsServer() takes sex-specific floors
## (minSireAge / minDamAge) in place of the single minParentAge, accepting
## either a plain scalar or a reactive, and forwards them to
## getPotentialParents(). Absent/NULL -> the species+sex table default.

# Minimal from-center fixture; content is irrelevant to the forwarding tests
# (getPotentialParents is mocked to capture the floor arguments).
ppAgeFixture <- function() {
  data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, NA),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    birth = as.Date(c("2005-01-01", "2005-01-01", "2010-01-01")),
    exit = as.Date(NA),
    fromCenter = c(TRUE, TRUE, TRUE),
    stringsAsFactors = FALSE
  )
}

test_that("modPotentialParentsServer forwards scalar floors to getPotentialParents", {
  skip_if_not_installed("shiny")
  ped <- ppAgeFixture()
  captured <- new.env()
  testthat::local_mocked_bindings(
    getPotentialParents = function(ped, minSireAge = NULL, minDamAge = NULL,
                                   ...) {
      captured$sire <- minSireAge
      captured$dam <- minDamAge
      NULL
    },
    .package = "nprcgenekeepr"
  )
  shiny::testServer(
    modPotentialParentsServer,
    args = list(pedigree = shiny::reactive(ped),
                minSireAge = 4, minDamAge = 2.5),
    {
      session$setInputs(maxGestationalPeriod = 210, findParents = 1)
      session$getReturned()$tableData()
      expect_equal(captured$sire, 4)
      expect_equal(captured$dam, 2.5)
    }
  )
})

test_that("modPotentialParentsServer forwards reactive floors to getPotentialParents", {
  skip_if_not_installed("shiny")
  ped <- ppAgeFixture()
  captured <- new.env()
  testthat::local_mocked_bindings(
    getPotentialParents = function(ped, minSireAge = NULL, minDamAge = NULL,
                                   ...) {
      captured$sire <- minSireAge
      captured$dam <- minDamAge
      NULL
    },
    .package = "nprcgenekeepr"
  )
  shiny::testServer(
    modPotentialParentsServer,
    args = list(pedigree = shiny::reactive(ped),
                minSireAge = shiny::reactive(3),
                minDamAge = shiny::reactive(NULL)),
    {
      session$setInputs(maxGestationalPeriod = 210, findParents = 1)
      session$getReturned()$tableData()
      expect_equal(captured$sire, 3)
      expect_null(captured$dam)
    }
  )
})

test_that("modPotentialParentsServer defaults to NULL floors (table default)", {
  skip_if_not_installed("shiny")
  ped <- ppAgeFixture()
  captured <- new.env()
  testthat::local_mocked_bindings(
    getPotentialParents = function(ped, minSireAge = NULL, minDamAge = NULL,
                                   ...) {
      captured$sire <- minSireAge
      captured$dam <- minDamAge
      NULL
    },
    .package = "nprcgenekeepr"
  )
  shiny::testServer(
    modPotentialParentsServer,
    args = list(pedigree = shiny::reactive(ped)),
    {
      session$setInputs(maxGestationalPeriod = 210, findParents = 1)
      session$getReturned()$tableData()
      expect_null(captured$sire)
      expect_null(captured$dam)
    }
  )
})

test_that("modPotentialParentsServer honors an impossibly high sire floor", {
  skip_if_not_installed("shiny")
  ped <- nprcgenekeepr::rhesusPedigree
  ped$fromCenter <- TRUE
  shiny::testServer(
    modPotentialParentsServer,
    args = list(pedigree = shiny::reactive(ped),
                minSireAge = 100, minDamAge = 2),
    {
      session$setInputs(maxGestationalPeriod = 210, findParents = 1)
      td <- session$getReturned()$tableData()
      # No male is 100 years old, so no candidate sire is ever proposed.
      expect_true(all(td$nSires == 0L))
    }
  )
})
