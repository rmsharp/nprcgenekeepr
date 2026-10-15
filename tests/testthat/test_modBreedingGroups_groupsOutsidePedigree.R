## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

library(testthat)
library(nprcgenekeepr)

## Formed groups stay in Breeding Groups after a new file is read or the
## Pedigree Browser is trimmed (S996; BACKLOG.md "Formed breeding groups
## outlive a new pedigree and a trimmed view"; the owner ruled "say it, keep
## the groups" and approved the sentence below). Measured in the real app:
## the Groups page kept "Group 1 (18 animals)" over an empty table, the
## Statistics page said 18 / 0 / 0, and Group Detail's "Group members" showed
## the red error "values must be length 1, but FUN(X[[1]]) result is length 0".
## When a box of the shown candidate (a formed group or "Unused animals") holds
## an animal the loaded pedigree lacks, each of the three pages now says one
## plain sentence in place of those; the groups stay in memory, so bringing the
## earlier pedigree back shows them again.

gopNote <- paste(
  "Some animals in these breeding groups are not in the pedigree now loaded",
  "(a new file or a trimmed view). Form the groups again, or bring back the",
  "earlier pedigree, to see them."
)

## Twenty unrelated living animals, so every group formation succeeds.
gopPed <- function(ids = paste0("A", 1:20)) {
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

## What an output shows, as text: an output that raises an error shows that
## error's message (a silent error shows nothing, and an output the module
## does not have shows nothing).
gopText <- function(expr) {
  tryCatch(paste(as.character(expr), collapse = " "),
           error = function(e) conditionMessage(e))
}

## How many times a fixed string occurs in a text.
gopCount <- function(pattern, text) {
  hits <- gregexpr(pattern, text, fixed = TRUE)[[1L]]
  sum(hits > 0L)
}

## Form two groups from the 20 animals the way the tab does.
gopForm <- function(session) {
  session$setInputs(animalSource = "all", nGroups = 2, maxKinship = 0.25,
                    sexRatio = "none", viewGrp = "1")
  session$setInputs(formGroups = 1)
}

## The three pages as text.
gopPages <- function(output) {
  list(
    groups = gopText(output$groupsDisplay),
    stats = gopText(output$groupStatsNote),
    detail = gopText(output$groupDetailNote)
  )
}

test_that("a new file with none of the group animals: the Groups page says the sentence once, no group box", {
  skip_if_not_installed("shiny")
  set.seed(42)
  pedRv <- shiny::reactiveVal(gopPed())

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = pedRv, geneticValues = NULL),
    {
      gopForm(session)
      before <- gopText(output$groupsDisplay)
      expect_match(before, "Group 1", fixed = TRUE)
      expect_equal(gopCount(gopNote, before), 0L)

      pedRv(gopPed(paste0("B", 1:20)))
      session$flushReact()

      after <- gopText(output$groupsDisplay)
      expect_equal(gopCount(gopNote, after), 1L)
      expect_false(grepl("panel-heading", after, fixed = TRUE))
    }
  )
})

test_that("a new file with none of the group animals: the Statistics page says the sentence once, no table", {
  skip_if_not_installed("shiny")
  set.seed(42)
  pedRv <- shiny::reactiveVal(gopPed())

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = pedRv, geneticValues = NULL),
    {
      gopForm(session)
      expect_match(gopText(output$groupStats), "Total", fixed = TRUE)

      pedRv(gopPed(paste0("B", 1:20)))
      session$flushReact()

      expect_equal(gopCount(gopNote, gopPages(output)$stats), 1L)
      expect_false(grepl("Total", gopText(output$groupStats), fixed = TRUE))
    }
  )
})

test_that("a new file with none of the group animals: Group Detail says the sentence once and the member table shows no error", {
  skip_if_not_installed("shiny")
  set.seed(42)
  pedRv <- shiny::reactiveVal(gopPed())

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = pedRv, geneticValues = NULL),
    {
      gopForm(session)
      firstId <- session$getReturned()$groups()[[1L]][1L]
      expect_match(gopText(output$groupMemberTable), "Ego ID", fixed = TRUE)

      pedRv(gopPed(paste0("B", 1:20)))
      session$flushReact()

      expect_equal(gopCount(gopNote, gopPages(output)$detail), 1L)
      members <- gopText(output$groupMemberTable)
      expect_false(grepl("values must be length 1", members, fixed = TRUE))
      expect_false(grepl("Ego ID", members, fixed = TRUE))
      ## The kinship table comes from the run's own matrix, so it stays.
      expect_match(gopText(output$groupKinTable), firstId, fixed = TRUE)
    }
  )
})

test_that("a pedigree that lacks only one group animal still gets the sentence on all three pages", {
  skip_if_not_installed("shiny")
  set.seed(42)
  pedRv <- shiny::reactiveVal(gopPed())

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = pedRv, geneticValues = NULL),
    {
      gopForm(session)
      lost <- session$getReturned()$groups()[[1L]][1L]
      expect_equal(gopCount(gopNote, gopText(output$groupsDisplay)), 0L)

      pedRv(gopPed()[gopPed()$id != lost, ])
      session$flushReact()

      pages <- gopPages(output)
      expect_equal(gopCount(gopNote, pages$groups), 1L)
      expect_equal(gopCount(gopNote, pages$stats), 1L)
      expect_equal(gopCount(gopNote, pages$detail), 1L)
      expect_false(grepl("panel-heading", pages$groups, fixed = TRUE))
    }
  )
})

test_that("an animal missing only from the Unused animals box counts too", {
  skip_if_not_installed("shiny")
  set.seed(42)
  pedRv <- shiny::reactiveVal(gopPed())

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = pedRv, geneticValues = NULL),
    {
      gopForm(session)
      ## Move one animal of the last group into a box of its own and mark the
      ## candidate as having an Unused animals box, as a real run does.
      res <- groupResults()
      cand <- res$candidates[[1L]]
      grps <- cand$validGroups
      unusedId <- grps[[length(grps)]][1L]
      cand$validGroups <- list(grps[[1L]],
                               setdiff(grps[[2L]], unusedId),
                               unusedId)
      cand$hasUnused <- TRUE
      res$candidates[[1L]] <- cand
      groupResults(res)
      session$flushReact()
      expect_match(gopText(output$groupsDisplay), "Unused animals",
                   fixed = TRUE)

      pedRv(gopPed()[gopPed()$id != unusedId, ])
      session$flushReact()

      expect_equal(gopCount(gopNote, gopText(output$groupsDisplay)), 1L)
    }
  )
})

test_that("bringing the earlier pedigree back shows the groups again on all three pages", {
  skip_if_not_installed("shiny")
  set.seed(42)
  pedRv <- shiny::reactiveVal(gopPed())

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = pedRv, geneticValues = NULL),
    {
      gopForm(session)
      pedRv(gopPed(paste0("B", 1:20)))
      session$flushReact()
      expect_equal(gopCount(gopNote, gopPages(output)$groups), 1L)

      pedRv(gopPed())
      session$flushReact()

      pages <- gopPages(output)
      expect_equal(gopCount(gopNote, pages$groups), 0L)
      expect_equal(gopCount(gopNote, pages$stats), 0L)
      expect_equal(gopCount(gopNote, pages$detail), 0L)
      expect_match(pages$groups, "Group 1", fixed = TRUE)
      expect_match(gopText(output$groupStats), "Total", fixed = TRUE)
      expect_match(gopText(output$groupMemberTable), "Ego ID", fixed = TRUE)
    }
  )
})

test_that("the groups the module returns are the same after a new file (Genetic Diversity reads them)", {
  skip_if_not_installed("shiny")
  set.seed(42)
  pedRv <- shiny::reactiveVal(gopPed())

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = pedRv, geneticValues = NULL),
    {
      gopForm(session)
      returned <- session$getReturned()
      groupsBefore <- returned$groups()
      expect_gte(length(groupsBefore), 1L)

      pedRv(gopPed(paste0("B", 1:20)))
      session$flushReact()

      expect_identical(returned$groups(), groupsBefore)
      expect_identical(returned$nGroups(), length(groupsBefore))
    }
  )
})

test_that("groups that match the pedigree show no sentence on any page", {
  skip_if_not_installed("shiny")
  set.seed(42)
  pedRv <- shiny::reactiveVal(gopPed())

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = pedRv, geneticValues = NULL),
    {
      gopForm(session)

      pages <- gopPages(output)
      expect_equal(gopCount(gopNote, pages$groups), 0L)
      expect_equal(gopCount(gopNote, pages$stats), 0L)
      expect_equal(gopCount(gopNote, pages$detail), 0L)
      expect_match(pages$groups, "Group 1", fixed = TRUE)
      expect_match(gopText(output$groupStats), "Total", fixed = TRUE)
      expect_match(gopText(output$groupMemberTable), "Ego ID", fixed = TRUE)
    }
  )
})
