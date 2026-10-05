## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Test-harness support (S915, BACKLOG PED-3): what the tests for
## walkPedigree() and for the four functions that use it share. Those are
## getProbandPedigree(), getDescendantPedigree(), getPedDirectRelatives() and
## getLkDirectAncestors().

## Runs `expr` under a wall-clock limit. A call that never returns then fails
## with R's "reached elapsed time limit" error, instead of hanging the suite.
withinSeconds <- function(expr, seconds = 5) {
  setTimeLimit(elapsed = seconds, transient = TRUE)
  on.exit(setTimeLimit(elapsed = Inf, transient = FALSE), add = TRUE)
  expr
}

## What a stand-in for walkPedigree() recorded on one call (an element of
## mockery::mock_args()), as a list with the three arguments by name, whether
## the function under test passed them by position or by name.
walkerCall <- function(args) {
  do.call(
    function(ids, ped, direction) {
      list(ids = ids, ped = ped, direction = direction)
    },
    args
  )
}

## The delegation check, written once: the stand-in was called exactly once,
## with these three arguments.
expectOneWalk <- function(walker, ids, ped, direction) {
  mockery::expect_called(walker, 1L)
  args <- mockery::mock_args(walker)
  if (length(args) == 0L) {
    return(invisible(NULL))
  }
  call <- walkerCall(args[[1L]])
  expect_identical(call$ids, ids)
  expect_identical(call$ped, ped)
  expect_identical(call$direction, direction)
}

## Two animals that are each other's sire.
circlePed <- function() {
  data.frame(
    id = c("A", "B"), sire = c("B", "A"), dam = NA_character_,
    stringsAsFactors = FALSE
  )
}

## One animal that is its own sire.
selfParentPed <- function() {
  data.frame(
    id = "A", sire = "A", dam = NA_character_,
    stringsAsFactors = FALSE
  )
}

## The Lacy (1989) pedigree plus one row whose id is missing (a child of A and
## B). Not valid input; the exported functions are still handed such tables.
missingIdPed <- function() {
  rbind(
    nprcgenekeepr::lacy1989Ped,
    data.frame(
      id = NA_character_, sire = "A", dam = "B", gen = 1, population = TRUE,
      stringsAsFactors = FALSE
    )
  )
}

## L's sire K has a sire (GONE) that has no row of its own.
danglingParentPed <- function() {
  data.frame(
    id = c("K", "L"), sire = c("GONE", "K"), dam = NA_character_,
    stringsAsFactors = FALSE
  )
}

## O's parents are S and D, and S is also D's sire, so S is O's parent (one
## generation up) and O's grandparent (two up). S and D have the parent H, S
## also has the parent G. The rows are in an order (G, H, D, S, O) that is
## neither discovery order nor generation order. `sex` tells a repeated row
## from its twin.
diamondPed <- function() {
  data.frame(
    id = c("G", "H", "D", "S", "O"),
    sire = c(NA, NA, "S", "G", "S"),
    dam = c(NA, NA, "H", "H", "D"),
    sex = c("M", "F", "F", "M", "F"),
    stringsAsFactors = FALSE
  )
}
