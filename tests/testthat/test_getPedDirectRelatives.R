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
