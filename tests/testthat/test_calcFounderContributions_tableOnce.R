## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Founder statistics: their memory peak rose a little on larger
## inputs while their time fell" (S1075). calcFounderContributions() fills a
## table of founder contributions, one row per animal and one column per
## founder. Since S1058 the fill runs in founderContributionMatrix(), which
## receives the table as an argument while calcFounderContributions() still
## holds it, so R copies the whole table at the first write and two tables are
## alive at once (S1075, measured with a full gc() after each generation: 94.1
## MB live during the fill on all 3,694 example animals, whose table is 47.0
## MB; 30.6 MB on the synthetic 10,000-animal colony, table 15.2 MB). The
## fallback fill receives the table the same way and copies it too. Each block
## below counts, with Rprofmem(), the allocations the size of the whole table:
## one when the table is built once and never copied.

## The bytes of a pedigree's contribution table: one double for each animal
## and founder.
contributionTableBytes <- function(ped) {
  founders <- getFounders(toCharacter(ped, headers = c("id", "sire", "dam")))
  8 * nrow(ped) * length(founders)
}

## How many allocations of a whole contribution table `run()` makes. Rprofmem()
## logs each large allocation's bytes with R's vector header added (48 bytes
## on a 64-bit build), so a table counts when its size is within 128 bytes.
tableAllocations <- function(run, bytes) {
  log <- withr::local_tempfile()
  utils::Rprofmem(log, threshold = bytes - 1)
  on.exit(utils::Rprofmem(NULL), add = TRUE)
  run()
  utils::Rprofmem(NULL)
  sizes <- suppressWarnings(as.numeric(sub(" :.*", "", readLines(log))))
  sum(sizes >= bytes & sizes < bytes + 128, na.rm = TRUE)
}

skipWithoutMemoryProfiling <- function() {
  skip_if_not(capabilities("profmem"),
              "R was built without memory profiling (Rprofmem)")
}

## The example as the app trims it, with one generation-3 animal moved to
## generation 2.5: a generation number the main fill does not take, so the
## fallback fill runs (as "gen 1.5" in test_founderStatsEquivalence.R).
fallbackAnalysisPed <- function() {
  ped <- exampleAnalysisPed()
  ped$gen <- as.double(ped$gen)
  ped$gen[which(ped$gen == 3)[1L]] <- 2.5
  ped
}

## How many allocations of `bytes` (by default a whole table)
## calcFounderContributions() makes on `ped`.
contributionAllocations <- function(ped, bytes = contributionTableBytes(ped)) {
  tableAllocations(function() calcFounderContributions(ped, "calcFEFG"), bytes)
}

## Which fill calcFounderContributions() runs on `ped`: "main", or "fallback"
## when the call reaches the fallback fill, mocked to stop there. Any other
## error is returned as its message.
fillTaken <- function(ped) {
  local_mocked_bindings(founderContributionMatrixGeneral = function(...) {
    stop("fallback")
  })
  tryCatch({
    calcFounderContributions(ped, "calcFEFG")
    "main"
  }, error = conditionMessage)
}

test_that("calcFounderContributions() builds its contribution table once", {
  skipWithoutMemoryProfiling()
  ped <- exampleAnalysisPed()
  expect_identical(fillTaken(ped), "main")
  expect_identical(contributionAllocations(ped), 1L)
})

test_that("the fallback fill builds the contribution table once", {
  skipWithoutMemoryProfiling()
  ped <- fallbackAnalysisPed()
  expect_identical(fillTaken(ped), "fallback")
  expect_identical(contributionAllocations(ped), 1L)
})

test_that("calcFEFG() and calcFGSE() each build the table once", {
  skipWithoutMemoryProfiling()
  ped <- exampleAnalysisPed()
  alleles <- withr::with_seed(1L, geneDrop(
    ped$id, ped$sire, ped$dam, ped$gen, n = 1000L
  ))
  bytes <- contributionTableBytes(ped)
  expect_identical(
    tableAllocations(function() calcFEFG(ped, alleles), bytes), 1L
  )
  expect_identical(
    tableAllocations(function() calcFGSE(ped, alleles), bytes), 1L
  )
})

## A starting table of whole numbers (0L, 1L) gives the same contributions:
## the first fill turns it into doubles, a new table, and the whole-number one,
## half the size, is thrown away (S1075 mutation probe: 23.5 MB more allocated
## on all 3,694 example animals, and every other block passed).
test_that("the contribution table starts as doubles, not whole numbers", {
  skipWithoutMemoryProfiling()
  ped <- exampleAnalysisPed()
  wholeNumberTable <- contributionTableBytes(ped) / 2
  expect_identical(contributionAllocations(ped, wholeNumberTable), 0L)
})

test_that("both fills give the frozen pre-campaign contributions", {
  for (ped in list(exampleAnalysisPed(), fallbackAnalysisPed())) {
    expect_identical(calcFounderContributions(ped, "calcFEFG"),
                     calcFounderContributionsReference(ped, "calcFEFG"))
  }
})
