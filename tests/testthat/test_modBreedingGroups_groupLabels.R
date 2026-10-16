## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

library(testthat)
library(nprcgenekeepr)

## The name of each Breeding Groups box (S1000, docs-audit part 2 flag CA3).
## Breeding Groups calls its boxes "Group 1", "Group 2" and so on, and the last
## one "Unused animals" when some animals fit no group, on its three pages. The
## module returned only the groups, so the Genetic Diversity heat map drew that
## last box as the next group number. The owner ruled: leave groups() as the
## plain, unnamed list it has always been, and return one more item,
## groupLabels, holding the name of each box of groups().

## Twenty unrelated living animals, so every group formation succeeds.
glPed <- function(ids = paste0("A", 1:20)) {
  data.frame(
    id = ids,
    sire = NA_character_,
    dam = NA_character_,
    sex = rep(c("M", "F"), length.out = length(ids)),
    birth = as.Date("2015-01-01"),
    exit = as.Date(NA),
    stringsAsFactors = FALSE
  )
}

## What groupAddAssign() returns. It ends every candidate with a box of the
## animals that fit no group (empty when none were left over); `candidates` is
## a list of such candidates, each one a list of boxes.
glMockFormation <- function(candidates) {
  function(...) {
    list(
      group = candidates[[1L]], score = 5L,
      candidates = lapply(candidates, function(g) {
        list(group = g, score = 5L)
      })
    )
  }
}

## Form groups the way the tab does.
glForm <- function(session) {
  session$setInputs(animalSource = "all", nGroups = 2, maxKinship = 0.25,
                    sexRatio = "none")
  session$setInputs(formGroups = 1)
}

## What a returned reactive gives, or the error it raised, so a missing item
## shows as a failed comparison and not as a crash.
glRead <- function(r) tryCatch(r(), error = function(e) e)

## Form groups from the mocked candidates, then read the returned groups() and
## groupLabels(); once more after each choice in `switchTo`. Returns one
## list(labels, groups) per reading.
glReturned <- function(candidates, switchTo = character(0L)) {
  readings <- list()
  take <- function(result) {
    list(labels = glRead(result$groupLabels), groups = glRead(result$groups))
  }
  testthat::with_mocked_bindings(
    shiny::testServer(
      modBreedingGroupsServer,
      args = list(pedigree = shiny::reactive(glPed()), geneticValues = NULL),
      {
        glForm(session)
        result <- session$getReturned()
        readings[[1L]] <<- take(result)
        for (choice in switchTo) {
          session$setInputs(candidateChoice = choice)
          readings[[length(readings) + 1L]] <<- take(result)
        }
      }
    ),
    groupAddAssign = glMockFormation(candidates),
    .package = "nprcgenekeepr"
  )
  readings
}

glLeftover <- list(c("A1", "A2"), c("A3", "A4"), "A5")
glNoLeftover <- list(c("A1", "A2"), c("A3", "A4"), character(0L))

test_that("with a leftover box, groupLabels() names the last box Unused animals", {
  skip_if_not_installed("shiny")

  got <- glReturned(list(glLeftover))[[1L]]

  expect_identical(got$labels, c("Group 1", "Group 2", "Unused animals"))
  expect_length(got$groups, 3L)
})

test_that("with nobody left over, every box is a numbered group", {
  skip_if_not_installed("shiny")

  got <- glReturned(list(glNoLeftover))[[1L]]

  expect_identical(got$labels, c("Group 1", "Group 2"))
  expect_length(got$groups, 2L)
})

test_that("a lone box is named for what it is", {
  skip_if_not_installed("shiny")

  loneGroup <- glReturned(list(list(c("A1", "A2"), character(0L))))[[1L]]
  loneLeftover <- glReturned(list(list(c("A1", "A2"))))[[1L]]

  expect_identical(loneGroup$labels, "Group 1")
  expect_identical(loneLeftover$labels, "Unused animals")
})

test_that("groupLabels() follows the selected candidate", {
  skip_if_not_installed("shiny")

  readings <- glReturned(list(glLeftover, glNoLeftover), switchTo = "2")

  expect_identical(readings[[1L]]$labels,
                   c("Group 1", "Group 2", "Unused animals"))
  expect_identical(readings[[2L]]$labels, c("Group 1", "Group 2"))
  # One name for every box shown, whichever candidate is selected.
  expect_identical(length(readings[[1L]]$labels),
                   length(readings[[1L]]$groups))
  expect_identical(length(readings[[2L]]$labels),
                   length(readings[[2L]]$groups))
})

test_that("groups() stays the plain, unnamed list, leftover box included", {
  skip_if_not_installed("shiny")

  got <- glReturned(list(glLeftover))[[1L]]

  expect_null(names(got$groups))
  expect_identical(got$groups, glLeftover)
})

test_that("before any run, groupLabels() waits as quietly as groups() does", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive(glPed()), geneticValues = NULL),
    {
      result <- session$getReturned()
      silent <- function(r) {
        inherits(tryCatch(r(), error = function(e) e), "shiny.silent.error")
      }

      # What groups() does today, so the comparison below means something.
      expect_true(silent(result$groups))
      expect_true(silent(result$groupLabels))
    }
  )
})
