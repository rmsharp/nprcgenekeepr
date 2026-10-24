## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 3, the relationship
## table" (owner pick S1055; plan docs/planning/performance-memory-campaign-
## plan.md, Phase 3 and section 5.1). convertRelationships() classified one
## pair at a time and grew its result one value at a time: 6.4 s on the
## example's first 300 animals and 66 s on its first 600, so the app's two
## relationship downloads never finished on the example's 3,694 animals
## (6,824,665 pairs; S1055, this Mac). A fast path classifies every pair with
## vector comparisons in the rule order, where the first matching rule wins.
##
## The owner's rulings: every result stays exactly today's (D1), and the
## exported functions keep their arguments and results (D3). So each block
## compares convertRelationships() with the frozen copy of today's function
## (convertRelationshipsReference(), helper-perfReference.R) using
## identical(). The fast path is for ordinary pedigrees; any other input goes
## through convertRelationshipsGeneral(), today's code unchanged (owner ruling
## S1055), so it gives today's result, or today's error, by construction.
## The example's first 300 animals are checked in every run; its first 600
## (66 s of today's code) only with the opt-in time budgets (owner ruling
## S1055). pedWithGenotype is left out: it has qcPed's animals and parents in
## another row order.

pedKinship <- function(ped) {
  kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
}

## The plan's grid for this function: three shipped pedigrees, two with ids,
## and the example's first 300 animals as the app's Summary Statistics sees
## them.
gridInputs <- function() {
  sp <- nprcgenekeepr::smallPed
  qc <- nprcgenekeepr::qcPed
  lacy <- nprcgenekeepr::lacy1989Ped
  spKmat <- pedKinship(sp)
  qcKmat <- pedKinship(qc)
  list(
    smallPed = list(kmat = spKmat, ped = sp),
    `smallPed, 12 ids` = list(
      kmat = spKmat, ped = sp,
      ids = c("A", "B", "D", "E", "F", "G", "I", "J", "L", "M", "O", "P")
    ),
    `smallPed, 3 ids` = list(kmat = spKmat, ped = sp,
                             ids = c("A", "B", "D")),
    lacy1989Ped = list(kmat = pedKinship(lacy), ped = lacy),
    qcPed = list(kmat = qcKmat, ped = qc),
    `qcPed, 2 ids` = list(kmat = qcKmat, ped = qc,
                          ids = c("4LFS70", "DD1U77")),
    `the example's first 300 animals` = exampleRelationsInput(300L)
  )
}

## The frozen copy's tables for the grid, built once: today's code takes about
## 11 s on them.
gridReference <- local({
  tables <- NULL
  function() {
    if (is.null(tables)) {
      tables <<- lapply(gridInputs(), function(args) {
        do.call(convertRelationshipsReference, args)
      })
    }
    tables
  }
})

expectGridMatchesReference <- function() {
  inputs <- gridInputs()
  reference <- gridReference()
  for (name in names(inputs)) {
    expect_identical(do.call(convertRelationships, inputs[[name]]),
                     reference[[name]], info = name)
  }
}

## Inputs a script can pass to convertRelationships() that the app never does:
## each was run through today's function and a vector prototype before RED
## (S1055). The prototype stopped with an error on one of them (a kinship
## matrix whose cells are all missing, which gives no pairs). The last four
## fast-path inputs were added after GREEN's mutation check: each tells one
## changed rule apart from today's, which the others did not.
## Each element: the arguments, and the path the fast version must take.
unusualInputs <- function() {
  sp <- nprcgenekeepr::smallPed
  spKmat <- pedKinship(sp)
  square <- function(ids, value) {
    matrix(value, length(ids), length(ids), dimnames = list(ids, ids))
  }
  pedOf <- function(id, sire, dam) {
    data.frame(id = id, sire = sire, dam = dam, stringsAsFactors = FALSE)
  }
  ## a parent named by a prefix of one id ("A" of "AB") or of two ("AC")
  partial <- pedOf(c("AB", "AC9", "Q", "R", "S", "T"),
                   c(NA, NA, "A", "A", "AC", "AC"),
                   c(NA, NA, NA, NA, "Z", "Z"))
  ambiguous <- partial
  ambiguous$id[1L] <- "ACx"
  ## parents given as empty text, or not in the pedigree at all
  emptyParent <- pedOf(c("GS", "GD", "P1", "P2", "K1", "K2", "K3"),
                       c(NA, NA, "GS", "GS", "P1", "P1x", "Pq"),
                       c(NA, NA, "GD", "GD", "", "", "P2"))
  ## an exact id that is also a prefix of another
  exactAndPrefix <- pedOf(c("A", "AB", "C", "D"), c(NA, NA, "A", "A"),
                          c(NA, NA, "AB", "AB"))
  selfParent <- pedOf(c("X", "Y", "Z"), c("X", NA, "X"), c(NA, "Y", "Y"))
  sireIsDam <- pedOf(c("M", "N", "O", "P"), c(NA, NA, "M", "M"),
                     c(NA, NA, "M", "N"))
  naText <- pedOf(c("NA", "B1", "C1"), c(NA, "NA", "NA"),
                  rep(NA_character_, 3L))
  naTextLogicalDam <- naText
  naTextLogicalDam$dam <- NA
  ## an unknown sire beside an id that starts with "NA" and has parents:
  ## pmatch() would take the missing sire for that id
  naPrefix <- pedOf(c("P", "Q", "NAx", "D1", "K"), c(NA, NA, "P", NA, NA),
                    c(NA, NA, "Q", NA, "D1"))
  ## a sire named "A", a prefix of AB, whose parents are known
  prefixKnown <- pedOf(c("GS", "GD", "AB", "Q", "R"),
                       c(NA, NA, "GS", "A", "AB"), c(NA, NA, "GD", NA, NA))
  ## C1 and C2: their dams are full sisters, their sires unrelated
  damsSisters <- pedOf(c("GS", "GD", "D1", "D2", "S1", "S2", "C1", "C2"),
                       c(NA, NA, "GS", "GS", NA, NA, "S1", "S2"),
                       c(NA, NA, "GD", "GD", NA, NA, "D1", "D2"))
  ## U's dam GD is a grandparent of A1, which comes first in the matrix
  secondDam <- pedOf(c("A1", "X", "M", "GS", "GD", "U", "Y"),
                     c("X", NA, "GS", NA, NA, "Y", NA),
                     c("M", NA, "GD", NA, NA, "GD", NA))
  factors <- sp
  factors$id <- factor(sp$id)
  factors$sire <- factor(sp$sire)
  factors$dam <- factor(sp$dam)
  numeric <- data.frame(id = 1L:5L, sire = c(NA, NA, 1L, 1L, 3L),
                        dam = c(NA, NA, 2L, 2L, 4L))
  missingId <- sp
  missingId$id[2L] <- NA
  repeatedId <- sp
  repeatedId$id[2L] <- repeatedId$id[1L]
  emptyId <- sp
  emptyId$id[2L] <- ""
  withClass <- sp
  class(withClass) <- c("pedigreeTable", "data.frame")
  oneMissing <- spKmat
  oneMissing[3L, 1L] <- NA
  allMissing <- spKmat
  allMissing[] <- NA_real_
  integerKmat <- spKmat
  storage.mode(integerKmat) <- "integer"
  textKmat <- spKmat
  storage.mode(textKmat) <- "character"
  noNames <- spKmat
  dimnames(noNames) <- NULL
  repeatedNames <- spKmat
  dimnames(repeatedNames) <- list(
    c("A", rownames(spKmat)[-1L]),
    c("A", "A", colnames(spKmat)[-(1L:2L)])
  )
  args <- function(kmat, ped, ...) list(kmat = kmat, ped = ped, ...)
  fast <- function(args) list(args = args, path = "fast")
  general <- function(args) list(args = args, path = "general")
  list(
    `matrix ids not in the pedigree` = fast(args(spKmat, sp[-(1L:3L), ])),
    `no matrix id in the pedigree` =
      fast(args(square(c("Q1", "Q2"), 0.1), sp)),
    `a parent named by a prefix of one id` =
      fast(args(square(partial$id, 0.1), partial)),
    `a parent named by a prefix of two ids` =
      fast(args(square(ambiguous$id, 0.1), ambiguous)),
    `parents as empty text or outside the pedigree` =
      fast(args(square(emptyParent$id, 0.05), emptyParent)),
    `an exact id that is also a prefix of another` =
      fast(args(square(exactAndPrefix$id, 0.1), exactAndPrefix)),
    `an animal its own parent` =
      fast(args(square(selfParent$id, 0.2), selfParent)),
    `an animal both sire and dam` =
      fast(args(square(sireIsDam$id, 0.2), sireIsDam)),
    `the text "NA" as an id` = fast(args(square(naText$id, 0.2), naText)),
    `a data frame with a class of its own` = fast(args(spKmat, withClass)),
    `one missing kinship` = fast(args(oneMissing, sp)),
    `every kinship missing` = fast(args(allMissing, sp)),
    `integer kinships` = fast(args(integerKmat, sp)),
    `negative kinships` = fast(args(spKmat - 0.2, sp)),
    `a matrix with no names` = fast(args(noNames, sp)),
    `a matrix with a repeated name` = fast(args(repeatedNames, sp)),
    `a one-cell matrix` = fast(args(spKmat[1L, 1L, drop = FALSE], sp)),
    `a kinship data frame` = fast(args(as.data.frame(spKmat), sp)),
    `a progress function` =
      fast(args(spKmat, sp, updateProgress = function() NULL)),
    `a progress value that is not a function` =
      fast(args(spKmat, sp, updateProgress = 5)),
    `an unknown sire beside an id that starts with "NA"` =
      fast(args(square(naPrefix$id, 0.1), naPrefix)),
    `a parent named by a prefix of an animal with parents` =
      fast(args(square(prefixKnown$id, 0.1), prefixKnown)),
    `dams who are full sisters` =
      fast(args(square(damsSisters$id, 0.1), damsSisters)),
    `the second animal's dam a grandparent of the first` =
      fast(args(square(secondDam$id, 0.1), secondDam)),
    `factor ids and parents` = general(args(spKmat, factors)),
    `numeric ids and parents` =
      general(args(square(1L:5L, 0.1), numeric)),
    `a missing id` = general(args(spKmat, missingId)),
    `a repeated id` = general(args(spKmat, repeatedId)),
    `an empty id` = general(args(spKmat, emptyId)),
    `a pedigree with no rows` = general(args(spKmat, sp[0L, ])),
    `a pedigree as a list` =
      general(args(spKmat, as.list(sp[, c("id", "sire", "dam")]))),
    `no dam column` = general(args(spKmat, sp[, c("id", "sire")])),
    `dams all NA (logical)` =
      general(args(square(naText$id, 0.2), naTextLogicalDam)),
    `parents all NA (logical)` = general(args(
      square(c("a", "b"), 0.5),
      data.frame(id = c("a", "b"), sire = NA, dam = NA)
    )),
    `TRUE/FALSE kinships` = general(args(spKmat > 0.1, sp)),
    `text kinships` = general(args(textKmat, sp))
  )
}

test_that("convertRelationships() gives the frozen copy's table on the grid", {
  expectGridMatchesReference()
})

test_that("the grid takes the fast path, never today's code", {
  local_mocked_bindings(
    convertRelationshipsGeneral = function(...) {
      stop("convertRelationshipsGeneral() was called")
    }
  )
  expectGridMatchesReference()
})

test_that("unusual inputs give the frozen copy's table, or its error", {
  cases <- unusualInputs()
  expect_length(cases, 36L)
  for (name in names(cases)) {
    expect_identical(outcome(convertRelationships, cases[[name]]$args),
                     outcome(convertRelationshipsReference,
                             cases[[name]]$args),
                     info = name)
  }
})

test_that("an unusual input goes to today's code unless the fast path is safe", {
  cases <- unusualInputs()
  general <- convertRelationshipsGeneral
  current <- NULL
  used <- character()
  local_mocked_bindings(convertRelationshipsGeneral = function(...) {
    used <<- c(used, current)
    general(...)
  })
  for (name in names(cases)) {
    current <- name
    outcome(convertRelationships, cases[[name]]$args)
  }
  paths <- vapply(cases, `[[`, character(1L), "path")
  expect_identical(used, names(cases)[paths == "general"])
  expect_identical(sum(paths == "fast"), 24L)
  expect_identical(sum(paths == "general"), 12L)
})

test_that("pairs classified in several blocks give the frozen copy's table", {
  ## qcPed's 39,340 pairs in blocks of 1,000: every other input fits in one
  ## block of relationBlockSize, so a block boundary is checked only here.
  local_mocked_bindings(relationBlockSize = 1000L)
  qc <- nprcgenekeepr::qcPed
  expect_identical(convertRelationships(pedKinship(qc), qc),
                   gridReference()$qcPed)
})

test_that("the example's first 600 animals give the frozen copy's table", {
  skip_on_cran()
  skip_if_not(identical(Sys.getenv("NPRC_RUN_PERF"), "true"),
              "set NPRC_RUN_PERF=true: today's code takes 66 s here")
  input <- exampleRelationsInput(600L)
  expect_identical(do.call(convertRelationships, input),
                   do.call(convertRelationshipsReference, input))
})
