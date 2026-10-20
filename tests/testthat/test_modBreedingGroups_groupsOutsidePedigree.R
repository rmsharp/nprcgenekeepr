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

## Twenty unrelated living animals, so every group formation succeeds (the
## shared fixture in helper-unrelatedLivingPed.R).
gopPed <- unrelatedLivingPed

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

## What Group Detail holds below the sentence: the member table, the kinship
## heading and table, and both Export buttons. One output holds them all, so
## the sentence can stand in place of every one of them (S1019: the owner
## ruled "sentence only"; S996 had kept the kinship table on screen and the
## kinship export writing the old group's matrix).
gopBodyHolds <- function(output) {
  body <- gopText(output$groupDetailBody)
  c(memberTable = grepl("groupMemberTable\"", body, fixed = TRUE),
    kinshipHeading = grepl("Within-group kinship", body, fixed = TRUE),
    kinshipTable = grepl("groupKinTable\"", body, fixed = TRUE),
    exportMembers = grepl("downloadGroup\"", body, fixed = TRUE),
    exportKinship = grepl("downloadGroupKin\"", body, fixed = TRUE))
}

## The parts named FALSE (for "missing" messages) or TRUE (for "still shown").
gopLacks <- function(held) paste(names(held)[!held], collapse = ", ")
gopStill <- function(held) paste(names(held)[held], collapse = ", ")

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

test_that("a new file with none of the group animals: Group Detail says the sentence once and both tables show nothing", {
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
      expect_match(gopText(output$groupKinTable), firstId, fixed = TRUE)

      pedRv(gopPed(paste0("B", 1:20)))
      session$flushReact()

      expect_equal(gopCount(gopNote, gopPages(output)$detail), 1L)
      members <- gopText(output$groupMemberTable)
      expect_false(grepl("values must be length 1", members, fixed = TRUE))
      expect_false(grepl("Ego ID", members, fixed = TRUE))
      ## S1019: the kinship table goes too. S996 kept it ("the run's own
      ## matrix"), but it listed animals the loaded pedigree lacks under a
      ## sentence that says to form the groups again.
      expect_false(grepl(firstId, gopText(output$groupKinTable), fixed = TRUE))
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

test_that("a new file with none of the group animals: Group Detail shows no tables and no Export buttons", {
  skip_if_not_installed("shiny")
  set.seed(42)
  pedRv <- shiny::reactiveVal(gopPed())

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = pedRv, geneticValues = NULL),
    {
      gopForm(session)
      before <- gopBodyHolds(output)
      expect_true(all(before), info = paste("missing before:", gopLacks(before)))

      pedRv(gopPed(paste0("B", 1:20)))
      session$flushReact()

      after <- gopBodyHolds(output)
      expect_false(any(after), info = paste("still shown:", gopStill(after)))
      expect_equal(gopCount(gopNote, gopPages(output)$detail), 1L)
    }
  )
})

test_that("a pedigree that lacks only one group animal: Group Detail shows no tables and no Export buttons", {
  skip_if_not_installed("shiny")
  set.seed(42)
  pedRv <- shiny::reactiveVal(gopPed())

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = pedRv, geneticValues = NULL),
    {
      gopForm(session)
      lost <- session$getReturned()$groups()[[1L]][1L]
      before <- gopBodyHolds(output)
      expect_true(all(before), info = paste("missing before:", gopLacks(before)))

      pedRv(gopPed()[gopPed()$id != lost, ])
      session$flushReact()

      after <- gopBodyHolds(output)
      expect_false(any(after), info = paste("still shown:", gopStill(after)))
      expect_equal(gopCount(gopNote, gopPages(output)$detail), 1L)
    }
  )
})

test_that("with the sentence showing, neither export writes a file", {
  skip_if_not_installed("shiny")
  set.seed(42)
  pedRv <- shiny::reactiveVal(gopPed())

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = pedRv, geneticValues = NULL),
    {
      gopForm(session)
      expect_true(file.exists(output$downloadGroup))
      expect_true(file.exists(output$downloadGroupKin))

      pedRv(gopPed(paste0("B", 1:20)))
      session$flushReact()

      ## A silent stop, as the members export already does: the kinship
      ## export wrote the old group's matrix (S996 measured it; S1019 re-ran
      ## it in the real app: 121 animals, none in the new file).
      expect_error(output$downloadGroup, class = "shiny.silent.error")
      expect_error(output$downloadGroupKin, class = "shiny.silent.error")
    }
  )
})

test_that("before any group is formed, Group Detail holds its tables and Export buttons and no sentence", {
  skip_if_not_installed("shiny")
  pedRv <- shiny::reactiveVal(gopPed())

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = pedRv, geneticValues = NULL),
    {
      held <- gopBodyHolds(output)
      expect_true(all(held), info = paste("missing:", gopLacks(held)))
      expect_equal(gopCount(gopNote, gopPages(output)$detail), 0L)
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
      firstId <- session$getReturned()$groups()[[1L]][1L]
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
      ## The tables and both Export buttons come back with the groups.
      held <- gopBodyHolds(output)
      expect_true(all(held), info = paste("missing:", gopLacks(held)))
      expect_match(gopText(output$groupKinTable), firstId, fixed = TRUE)
      expect_true(file.exists(output$downloadGroup))
      expect_true(file.exists(output$downloadGroupKin))
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
