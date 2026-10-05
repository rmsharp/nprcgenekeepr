## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## notifyProgress() is the one place that says "call the progress function if
## one was given". Seven blocks of `if (!is.null(updateProgress))` used to say
## it inline: three in reportGV(), two in geneDrop(), one in
## convertRelationships() and one in groupAddAssign(). They must now call the
## helper, so the rule cannot drift between them (BACKLOG, NEW-62; owner
## decision S911, Decision record 12; scope settled at the S914 pre-RED gate).
##
## Three kinds of test, in this order:
##   1. the helper itself;
##   2. one recording test per function: a stand-in progress function saves
##      every call it receives, so today's messages and their order are pinned
##      before any block moves (these pass at the commit that adds this file);
##   3. one test per function that replaces the helper with a stand-in and
##      checks the function goes through it, and no longer calls the progress
##      function directly.

## A progress function that saves every call it receives, arguments by name.
makeRecorder <- function() {
  calls <- list()
  list(
    callback = function(...) {
      calls[[length(calls) + 1L]] <<- list(...)
      invisible(NULL)
    },
    calls = function() calls
  )
}

## The calls each function sends today, written once. geneDrop() sends one
## start call, then one per animal; reportGV() then sends three step messages;
## convertRelationships() and groupAddAssign() send argument-free calls.
geneDropStart <- list(
  detail = "Performing Gene-drop Simulation", value = 0L, reset = TRUE
)
perAnimalCalls <- function(nAnimals) {
  rep(list(list(n = nAnimals)), nAnimals)
}
geneDropCalls <- function(nAnimals) {
  c(list(geneDropStart), perAnimalCalls(nAnimals))
}
reportGVSteps <- list(
  list(detail = "Calculating Genome Uniqueness", value = 1L, reset = TRUE),
  list(detail = "Calculating Numbers of Offspring", value = 1L, reset = TRUE),
  list(detail = "Calculating Founder Equivalents", value = 1L, reset = TRUE)
)
noArgCalls <- function(n) rep(list(list()), n)

## What a stand-in for the helper recorded (mockery::mock_args()): TRUE when
## every call had the progress function as its first argument and, with
## only = TRUE, no other argument.
allCallsLeadWith <- function(args, callback, only = FALSE) {
  all(vapply(args, function(a) {
    identical(a[[1L]], callback) && (!only || length(a) == 1L)
  }, logical(1L)))
}

## The calls to the function under test are made through these, which take the
## function as an argument: mockery::stub() replaces a function in the scope of
## the test that stubs it, so a call made by name from here would miss the stub.
callGeneDrop <- function(geneDropFn, callback) {
  ped <- nprcgenekeepr::lacy1989Ped
  geneDropFn(ped$id, ped$sire, ped$dam, ped$gen,
    n = 3L, updateProgress = callback
  )
}
callGroupAddAssign <- function(groupAddAssignFn, callback) {
  set_seed(10L)
  groupAddAssignFn(
    candidates = qcBreeders, kmat = pedWithGenotypeReport$kinship,
    ped = pedWithGenotype, currentGroups = list(qcBreeders[1L:3L]),
    ignore = NULL, minAge = 1.0, numGp = 1L, harem = FALSE, sexRatio = 0L,
    withKin = FALSE, iter = 25L, updateProgress = callback
  )
}
smallPedKinship <- function() {
  ped <- nprcgenekeepr::smallPed
  kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
}

## ---------------------------------------------------------------------------
## 1. The helper
## ---------------------------------------------------------------------------
test_that("notifyProgress does nothing when no progress function was given", {
  result <- withVisible(notifyProgress(NULL, detail = "x", value = 1L))
  expect_null(result$value)
  expect_false(result$visible)
})

test_that("notifyProgress never evaluates its arguments when none is given", {
  ## geneDrop() sends n = nrow(ped) once per animal; with no progress function
  ## that work must stay undone, exactly as it is today.
  expect_no_error(
    notifyProgress(NULL, n = stop("evaluated"), detail = stop("evaluated"))
  )
})

test_that("notifyProgress passes a progress function the arguments given", {
  rec <- makeRecorder()
  notifyProgress(rec$callback, detail = "d", value = 1L, reset = TRUE)
  notifyProgress(rec$callback, n = 7L)
  notifyProgress(rec$callback)
  expect_identical(
    rec$calls(),
    list(
      list(detail = "d", value = 1L, reset = TRUE),
      list(n = 7L),
      list()
    )
  )
})

test_that("notifyProgress returns NULL invisibly, whatever the callback does", {
  result <- withVisible(notifyProgress(function(...) "stub", detail = "x"))
  expect_null(result$value)
  expect_false(result$visible)
})

test_that("notifyProgress stops on a non-function as the blocks do today", {
  ## Only NULL means "no progress bar". Anything else that is not a function
  ## fails on the first call, and the message names the argument
  ## `updateProgress`, so the helper's parameter keeps that name.
  for (bad in list(TRUE, "x", 1L)) {
    expect_error(
      notifyProgress(bad),
      'could not find function "updateProgress"',
      fixed = TRUE,
      info = deparse(bad)
    )
  }
})

test_that("notifyProgress is internal, not exported", {
  expect_false("notifyProgress" %in% getNamespaceExports("nprcgenekeepr"))
})

## ---------------------------------------------------------------------------
## 2. Today's calls, recorded at the current commit
## ---------------------------------------------------------------------------
test_that("geneDrop sends one start call, then n = nrow(ped) per animal", {
  rec <- makeRecorder()
  callGeneDrop(geneDrop, rec$callback)
  expect_identical(
    rec$calls(),
    geneDropCalls(nrow(nprcgenekeepr::lacy1989Ped))
  )
})

test_that("reportGV sends the gene-drop calls, then three step messages", {
  rec <- makeRecorder()
  reportGV(nprcgenekeepr::qcPed, guIter = 20L, updateProgress = rec$callback)
  calls <- rec$calls()
  nAnimals <- nrow(nprcgenekeepr::qcPed)
  expect_length(calls, 1L + nAnimals + 3L)
  expect_identical(calls[[1L]], geneDropStart)
  expect_identical(calls[2L:(1L + nAnimals)], perAnimalCalls(nAnimals))
  expect_identical(calls[(2L + nAnimals):(1L + nAnimals + 3L)], reportGVSteps)
})

test_that("convertRelationships sends one argument-free call per pair", {
  ped <- nprcgenekeepr::smallPed
  kmat <- smallPedKinship()
  rec <- makeRecorder()
  rel <- convertRelationships(kmat, ped, updateProgress = rec$callback)
  expect_gt(nrow(rel), 0L)
  expect_identical(rec$calls(), noArgCalls(nrow(rel)))
  recSome <- makeRecorder()
  relSome <- convertRelationships(kmat, ped,
    ids = c("A", "B", "D"),
    updateProgress = recSome$callback
  )
  expect_identical(recSome$calls(), noArgCalls(nrow(relSome)))
})

test_that("groupAddAssign sends one argument-free call per iteration", {
  skip_if_not(exists("pedWithGenotypeReport"))
  rec <- makeRecorder()
  callGroupAddAssign(groupAddAssign, rec$callback)
  expect_identical(rec$calls(), noArgCalls(25L))
})

## ---------------------------------------------------------------------------
## 3. Each function goes through the helper
## ---------------------------------------------------------------------------
## Each test stubs the helper with a stand-in that records its arguments and
## does NOT call the progress function. The recording tests above are the
## control: the same call, unstubbed, produces the sequences they pin. So the
## progress function the function was given must receive nothing directly, and
## the stand-in must receive the same calls, each with the progress function
## first.

test_that("geneDrop sends its progress calls through notifyProgress", {
  nAnimals <- nrow(nprcgenekeepr::lacy1989Ped)
  rec <- makeRecorder()
  helper <- mockery::mock(NULL, cycle = TRUE)
  mockery::stub(geneDrop, "notifyProgress", helper)
  callGeneDrop(geneDrop, rec$callback)
  mockery::expect_called(helper, 1L + nAnimals)
  args <- mockery::mock_args(helper)
  expect_true(allCallsLeadWith(args, rec$callback))
  expect_identical(
    lapply(args, function(a) a[-1L]),
    geneDropCalls(nAnimals)
  )
  expect_length(rec$calls(), 0L)
})

test_that("reportGV sends its three step messages through notifyProgress", {
  rec <- makeRecorder()
  helper <- mockery::mock(NULL, cycle = TRUE)
  mockery::stub(reportGV, "notifyProgress", helper)
  reportGV(nprcgenekeepr::qcPed, guIter = 20L, updateProgress = rec$callback)
  mockery::expect_called(helper, 3L)
  args <- mockery::mock_args(helper)
  expect_true(allCallsLeadWith(args, rec$callback))
  expect_identical(lapply(args, function(a) a[-1L]), reportGVSteps)
  ## The stub covers reportGV()'s own calls only. geneDrop(), which reportGV()
  ## hands the progress function to, still calls it: one start call and one per
  ## animal, and none of the three step messages.
  nAnimals <- nrow(nprcgenekeepr::qcPed)
  expect_length(rec$calls(), 1L + nAnimals)
  expect_false(any(vapply(
    rec$calls(),
    function(x) isTRUE(grepl("^Calculating", x$detail)),
    logical(1L)
  )))
})

test_that("convertRelationships sends its per-pair call via notifyProgress", {
  rec <- makeRecorder()
  helper <- mockery::mock(NULL, cycle = TRUE)
  mockery::stub(convertRelationships, "notifyProgress", helper)
  rel <- convertRelationships(
    smallPedKinship(), nprcgenekeepr::smallPed,
    updateProgress = rec$callback
  )
  mockery::expect_called(helper, nrow(rel))
  expect_true(
    allCallsLeadWith(mockery::mock_args(helper), rec$callback, only = TRUE)
  )
  expect_length(rec$calls(), 0L)
})

test_that("groupAddAssign sends its per-iteration call via notifyProgress", {
  skip_if_not(exists("pedWithGenotypeReport"))
  rec <- makeRecorder()
  helper <- mockery::mock(NULL, cycle = TRUE)
  mockery::stub(groupAddAssign, "notifyProgress", helper)
  callGroupAddAssign(groupAddAssign, rec$callback)
  mockery::expect_called(helper, 25L)
  expect_true(
    allCallsLeadWith(mockery::mock_args(helper), rec$callback, only = TRUE)
  )
  expect_length(rec$calls(), 0L)
})
