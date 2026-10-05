## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

test_that("getPedDirectRelatives throws an error with no pedigree", {
  expect_error(
    getPedDirectRelatives(),
    "Need to specify IDs"
  )
})

test_that("getPedDirectRelatives throws an error with no pedigree", {
  expect_null(getPedDirectRelatives(ids = "E", ped = NULL))
})

ped <- c("A", "B")
test_that("getPedDirectRelatives throws an error with no IDs", {
  expect_error(
    getPedDirectRelatives(ped = ped),
    "Need to specify IDs"
  )
})

test_that("getPedDirectRelatives throws an error with pedigree argument", {
  expect_error(
    getPedDirectRelatives(ids = "E"),
    "Need to specify pedigree"
  )
})

test_that(paste0(
  "getPedDirectRelatives throws an error with no data.frame ",
  "for pedigree"
), {
  expect_error(
    getPedDirectRelatives(ids = "E", ped = ped),
    "ped must be a data.frame object"
  )
})

ped <- nprcgenekeepr::lacy1989Ped
test_that("getPedDirectRelatives throws an error with no pedigree", {
  expect_error(
    getPedDirectRelatives(ped = ped),
    "Need to specify IDs"
  )
})

ped <- nprcgenekeepr::lacy1989Ped
ids <- "E"
relatives <- getPedDirectRelatives(
  ids = ids, ped = ped,
  unrelatedParents = FALSE
)
test_that("getPedDirectRelatives creates correct pedigree", {
  expect_setequal(relatives$id, c("A", "B", "C", "D", "E", "F", "G"))
})

ids <- "B"
relatives <- getPedDirectRelatives(
  ids = ids, ped = ped,
  unrelatedParents = FALSE
)
test_that("getPedDirectRelatives creates correct pedigree", {
  expect_setequal(relatives$id, c("A", "B", "C", "D", "E", "F", "G"))
})
ids <- "C"
relatives <- getPedDirectRelatives(
  ids = ids, ped = ped,
  unrelatedParents = FALSE
)
test_that("getPedDirectRelatives creates correct pedigree", {
  expect_setequal(relatives$id, c("A", "B", "C", "D", "E", "F", "G"))
})

ped2 <- rbind(ped, data.frame(
  id = c("H", "I", "J", "K", "L", "M"),
  sire = c("K", "K", "L", NA, NA, NA),
  dam = c(NA, "M", "M", NA, NA, NA),
  gen = rep(2L, 6L),
  population = rep(TRUE, 6L),
  stringsAsFactors = FALSE
))

ids <- "E"
relatives <- getPedDirectRelatives(
  ids = ids, ped = ped2,
  unrelatedParents = FALSE
)
test_that("getPedDirectRelatives creates correct pedigree", {
  expect_setequal(relatives$id, c("A", "B", "C", "D", "E", "F", "G"))
})

ids <- "B"
relatives <- getPedDirectRelatives(
  ids = ids, ped = ped2,
  unrelatedParents = FALSE
)
test_that("getPedDirectRelatives creates correct pedigree", {
  expect_setequal(relatives$id, c("A", "B", "C", "D", "E", "F", "G"))
})
ids <- "C"
relatives <- getPedDirectRelatives(
  ids = ids, ped = ped2,
  unrelatedParents = FALSE
)
test_that("getPedDirectRelatives creates correct pedigree", {
  expect_setequal(relatives$id, c("A", "B", "C", "D", "E", "F", "G"))
})
ids <- "M"
relatives <- getPedDirectRelatives(
  ids = ids, ped = ped2,
  unrelatedParents = FALSE
)
test_that("getPedDirectRelatives creates correct pedigree", {
  expect_setequal(relatives$id, c("H", "I", "J", "K", "L", "M"))
})

test_that(paste0(
  "getPedDirectRelatives adds NA-parent placeholder ",
  "records for unrelated parents when unrelatedParents = TRUE"
), {
  pedU <- data.frame(
    id   = c("A", "B", "C"),
    sire = c(NA,  "A", "A"),
    dam  = c(NA,  "Z", "B"),   # Z referenced, no ego record
    sex  = c("M", "F", "F"),
    stringsAsFactors = FALSE
  )
  withParents <- getPedDirectRelatives(
    ids = "C", ped = pedU, unrelatedParents = TRUE
  )
  expect_true("Z" %in% withParents$id)          # placeholder present
  expect_true(is.na(withParents$sire[withParents$id == "Z"]))
  expect_true(is.na(withParents$dam[withParents$id == "Z"]))
  withoutParents <- getPedDirectRelatives(
    ids = "C", ped = pedU, unrelatedParents = FALSE
  )
  expect_true(all(withoutParents$id %in% withParents$id)) # TRUE superset FALSE
})

# Guard: no unrelated parents -> TRUE equals FALSE, no error, no extra rows
test_that(paste0(
  "getPedDirectRelatives unrelatedParents = TRUE with no ",
  "unrelated parents matches the FALSE result"
), {
  pedClean <- nprcgenekeepr::lacy1989Ped
  withT <- getPedDirectRelatives(ids = "E", ped = pedClean,
                                 unrelatedParents = TRUE)
  withF <- getPedDirectRelatives(ids = "E", ped = pedClean,
                                 unrelatedParents = FALSE)
  expect_setequal(withT$id, withF$id)
})

## PED-3 (BACKLOG; owner decision S912, Decision record 13; strict TDD, S915):
## the loop that collects the relatives in both directions moves into
## walkPedigree(). The tests below record what the function returns today (they
## pass at the commit that adds them, except the one that names a row with a
## missing id, which never returns today) and check it asks walkPedigree() for
## its ids. The fixtures are in helper-walkPedigree.R.

pedLacy <- nprcgenekeepr::lacy1989Ped
pedExtended <- rbind(pedLacy, data.frame(
  id = c("H", "I", "J", "K", "L", "M"),
  sire = c("K", "K", "L", NA, NA, NA),
  dam = c(NA, "M", "M", NA, NA, NA),
  gen = rep(2L, 6L),
  population = rep(TRUE, 6L),
  stringsAsFactors = FALSE
))

test_that("getPedDirectRelatives returns the pedigree's own rows in the pedigree's order", {
  expect_identical(
    getPedDirectRelatives(ids = "E", ped = pedLacy)$id,
    c("A", "B", "C", "D", "E", "F", "G")
  )
  expect_identical(
    getPedDirectRelatives(ids = "M", ped = pedExtended),
    pedExtended[pedExtended$id %in% c("H", "I", "J", "K", "L", "M"), ]
  )
})

test_that("getPedDirectRelatives puts the placeholder records last and renumbers the rows", {
  pedU <- data.frame(
    id = c("A", "B", "C"), sire = c(NA, "A", "A"), dam = c(NA, "Z", "B"),
    stringsAsFactors = FALSE
  )
  result <- getPedDirectRelatives(ids = "C", ped = pedU, unrelatedParents = TRUE)
  expect_identical(result$id, c("A", "B", "C", "Z"))
  expect_identical(rownames(result), c("1", "2", "3", "4"))
})

test_that("getPedDirectRelatives copes with absent, repeated and missing ids", {
  expect_identical(nrow(getPedDirectRelatives(ids = "ZZZ", ped = pedLacy)), 0L)
  expect_identical(
    getPedDirectRelatives(ids = "ZZZ", ped = pedLacy, unrelatedParents = TRUE)$id,
    "ZZZ"
  )
  expect_identical(
    nrow(getPedDirectRelatives(ids = character(0L), ped = pedLacy)), 0L
  )
  expect_identical(
    getPedDirectRelatives(ids = c("F", NA), ped = pedLacy)$id,
    c("A", "B", "C", "D", "E", "F", "G")
  )
  ## A missing id never gets a placeholder record.
  expect_identical(
    getPedDirectRelatives(
      ids = c("G", NA), ped = pedLacy, unrelatedParents = TRUE
    )$id,
    c("A", "B", "C", "D", "E", "F", "G")
  )
})

test_that("getPedDirectRelatives leaves out a parent that has no row of its own", {
  pedDangling <- danglingParentPed()
  expect_identical(
    getPedDirectRelatives(ids = "L", ped = pedDangling)$id,
    c("K", "L")
  )
  expect_identical(
    getPedDirectRelatives(
      ids = "L", ped = pedDangling, unrelatedParents = TRUE
    )$id,
    c("K", "L", "GONE")
  )
})

test_that("getPedDirectRelatives stops on circular data", {
  expect_identical(
    withinSeconds(getPedDirectRelatives(ids = "A", ped = circlePed()))$id,
    c("A", "B")
  )
  expect_identical(
    withinSeconds(getPedDirectRelatives(ids = "A", ped = selfParentPed()))$id,
    "A"
  )
})

test_that("getPedDirectRelatives stops when a row of the pedigree has a missing id", {
  ## Today the missing-id row is found as an offspring of A on every pass, the
  ## loop drops it from `ids`, and it is found again, so the call never returns.
  result <- withinSeconds(
    getPedDirectRelatives(ids = "A", ped = missingIdPed())
  )
  expect_setequal(result$id, c(pedLacy$id, NA))
})

test_that("getPedDirectRelatives asks walkPedigree() for the relatives in both directions", {
  skip_if_not_installed("mockery")
  ## Control: the real rule gives the whole family of E.
  expect_identical(
    getPedDirectRelatives(ids = "E", ped = pedLacy)$id,
    c("A", "B", "C", "D", "E", "F", "G")
  )
  ## A stand-in that finds no relatives leaves only E.
  walker <- mockery::mock(list("E"))
  mockery::stub(getPedDirectRelatives, "walkPedigree", walker)
  result <- getPedDirectRelatives(ids = "E", ped = pedLacy)
  expectOneWalk(walker, ids = "E", ped = pedLacy, direction = "both")
  expect_identical(result$id, "E")
})

test_that("getPedDirectRelatives makes its placeholder records from the ids walkPedigree() found", {
  skip_if_not_installed("mockery")
  ## Control: E has no relative outside the pedigree, so no placeholder.
  expect_identical(
    getPedDirectRelatives(
      ids = "E", ped = pedLacy, unrelatedParents = TRUE
    )$id,
    c("A", "B", "C", "D", "E", "F", "G")
  )
  ## A stand-in that also finds Q, which has no row, adds a placeholder for Q.
  walker <- mockery::mock(list("E", "Q"))
  mockery::stub(getPedDirectRelatives, "walkPedigree", walker)
  result <- getPedDirectRelatives(
    ids = "E", ped = pedLacy, unrelatedParents = TRUE
  )
  expectOneWalk(walker, ids = "E", ped = pedLacy, direction = "both")
  expect_identical(result$id, c("E", "Q"))
})
